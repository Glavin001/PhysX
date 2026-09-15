// Device-resident fixed-parent PCG feasibility. This executable is a mathematical
// replay, not a replacement simulation benchmark. Setup and host status polling
// are explicitly measured; physical loads and surviving bonds remain current.
#include "PreparedOperator.cuh"
#include "DensePreparedOperator.cuh"
#include <algorithm>
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <memory>
#include <vector>
using namespace PreparedStress;
using Clock = std::chrono::steady_clock;
template<class T> std::vector<T> read(const std::string& path, size_t count) {
    std::ifstream f(path, std::ios::binary|std::ios::ate);
    if (!f || size_t(f.tellg()) != count*sizeof(T)) throw std::runtime_error("input length: " + path);
    std::vector<T> result(count); f.seekg(0);
    f.read(reinterpret_cast<char*>(result.data()),count*sizeof(T));
    if (!f) throw std::runtime_error("input read: " + path);
    return result;
}
struct Csr {
    int n, m;
    Buffer<int> rows, columns;
    Buffer<double> values;
    Csr(const std::string& prefix,int n_,int m_,int nnz): n(n_),m(m_),
        rows(read<int>(prefix+".rows.i32",n+1)), columns(read<int>(prefix+".cols.i32",nnz)),
        values(read<double>(prefix+".values.f64",nnz)) {}
};
struct State { int done, failed, updates; double gamma, previous; };
__device__ double sum(double x) {
    __shared__ double scratch[256]; scratch[threadIdx.x]=x; __syncthreads();
    for(int i=128;i;i/=2) { if(threadIdx.x<i) scratch[threadIdx.x]+=scratch[threadIdx.x+i]; __syncthreads(); }
    return scratch[0];
}
__global__ void multiply(int n,int m,const int* rows,const int* columns,const double* values,
                         const double* x,double* y,const State* state) {
    const int col=blockIdx.y, row=blockIdx.x*blockDim.x+threadIdx.x;
    if(row<n && !state[col].done) {
        double value=0;
        for(int j=rows[row];j<rows[row+1];++j) value+=values[j]*x[col*m+columns[j]];
        y[col*n+row]=value;
    }
}
__global__ void forceRound(int n,double* force,const double* warm,const State* state) {
    int i=blockIdx.x*blockDim.x+threadIdx.x,col=blockIdx.y;
    if(i<n && !state[col].done) force[col*n+i]=double(float(force[col*n+i]+warm[col*n+i]));
}
__global__ void subtract(int n,const double* original,double* balance,const State* state) {
    int i=blockIdx.x*blockDim.x+threadIdx.x,col=blockIdx.y;
    if(i<n && !state[col].done) balance[col*n+i]=original[col*n+i]-balance[col*n+i];
}
__global__ void check(int n,const double* gradient,const double* threshold,State* state) {
    int col=blockIdx.x; if(state[col].done) return;
    double v=0; for(int i=threadIdx.x;i<n;i+=blockDim.x) v+=gradient[col*n+i]*gradient[col*n+i];
    v=sum(v);
    if(!threadIdx.x) {
        if(!isfinite(v)) { state[col].failed=1; state[col].done=1; }
        else if(v<=threshold[col]) state[col].done=1;
    }
}
__global__ void pad(int n,int parent,const int* restriction,const double* r,double* padded,const State* state) {
    int i=blockIdx.x*blockDim.x+threadIdx.x,col=blockIdx.y;
    if(i<n && !state[col].done) padded[col*parent+restriction[i]]=r[col*n+i];
}
__global__ void direction(int n,int parent,const int* restriction,const double* r,const double* z,
                          double* p,State* state,int iteration) {
    int col=blockIdx.x; if(state[col].done) return;
    double gamma=0;
    for(int i=threadIdx.x;i<n;i+=blockDim.x) gamma+=r[col*n+i]*(iteration ? z[col*parent+restriction[i]] : r[col*n+i]);
    gamma=sum(gamma);
    if(!threadIdx.x) {
        state[col].gamma=gamma;
        if(!(gamma>0) || !isfinite(gamma)) { state[col].done=1;state[col].failed=1; }
    }
    __syncthreads(); if(state[col].done) return;
    double beta=iteration>1 ? gamma/state[col].previous : 0;
    for(int i=threadIdx.x;i<n;i+=blockDim.x) p[col*n+i]=(iteration ? z[col*parent+restriction[i]] : r[col*n+i])+beta*p[col*n+i];
}
__global__ void update(int n,const double* p,const double* q,double* x,double* r,State* state) {
    int col=blockIdx.x; if(state[col].done) return;
    double den=0;for(int i=threadIdx.x;i<n;i+=blockDim.x) den+=p[col*n+i]*q[col*n+i];
    den=sum(den);
    if(!threadIdx.x && (!(den>0) || !isfinite(den))) { state[col].done=1;state[col].failed=1; }
    __syncthreads(); if(state[col].done) return;
    double alpha=state[col].gamma/den;
    for(int i=threadIdx.x;i<n;i+=blockDim.x) { x[col*n+i]+=alpha*p[col*n+i];r[col*n+i]-=alpha*q[col*n+i]; }
    if(!threadIdx.x) { state[col].previous=state[col].gamma; ++state[col].updates; }
}
__global__ void coarseProjection(int n,int rank,const double* basis,const double* r,double* projected,const State* state) {
    const int col=blockIdx.y,lane=threadIdx.x%32,mode=blockIdx.x*8+threadIdx.x/32;
    if(mode>=rank || state[col].done)return;
    double dot=0;for(int i=lane;i<n;i+=32)dot+=basis[mode*n+i]*r[col*n+i];
    for(int offset=16;offset;offset/=2)dot+=__shfl_down_sync(0xffffffff,dot,offset);
    if(!lane)projected[col*rank+mode]=dot;
}
__global__ void coarseExpansion(int n,int parent,int rank,const int* restriction,const double* basis,
    const double* coarseInverse,const double* diagonalInverse,const double* projected,const double* r,
    double* z,const State* state) {
    const int col=blockIdx.y;if(state[col].done)return;
    __shared__ double coefficient[128];
    if(threadIdx.x<rank) {
        double value=0;for(int j=0;j<rank;++j)value+=coarseInverse[threadIdx.x*rank+j]*projected[col*rank+j];
        coefficient[threadIdx.x]=value;
    }
    __syncthreads();
    const int row=blockIdx.x*blockDim.x+threadIdx.x;
    if(row<n) {
        const int node=row/6,axis=row%6;
        double value=0;
        for(int j=0;j<6;++j)value+=diagonalInverse[node*36+axis*6+j]*r[col*n+node*6+j];
        for(int j=0;j<rank;++j)value+=basis[j*n+row]*coefficient[j];
        z[col*parent+restriction[row]]=value;
    }
}
int main(int argc,char** argv) { try {
    if(argc!=11 && argc!=12 && argc!=13) throw std::runtime_error("parent-prefix current-prefix parent-n parent-nnz n A-nnz bond-rows B-nnz nrhs output-prefix [inverse-cholesky-file | coarse-prefix rank]");
    const std::string parent=argv[1],in=argv[2],out=argv[10];
    int pn=std::stoi(argv[3]),pnnz=std::stoi(argv[4]),n=std::stoi(argv[5]),annz=std::stoi(argv[6]),m=std::stoi(argv[7]),bnnz=std::stoi(argv[8]),nrhs=std::stoi(argv[9]);
    if(pn<=0||n<=0||n>pn||nrhs<=0||nrhs>1024) throw std::runtime_error("invalid dimensions");
    const int rank=argc==13?std::stoi(argv[12]):0;
    if(rank<0 || rank>128 || (argc==13 && rank==0))throw std::runtime_error("invalid coarse rank");
    auto start=Clock::now(); cudaCheck(cudaSetDevice(0)); cudaCheck(cudaFree(nullptr));
    cudaStream_t stream;cudaCheck(cudaStreamCreate(&stream));
    // Scope all resources before stream destruction.
    {
    std::unique_ptr<PreparedOperator> factor;
    std::unique_ptr<DensePreparedOperator> dense;
    std::unique_ptr<Buffer<double>> basis,coarseInverse,diagonalInverse,projected,coarseResult;
    if(rank) {
        const std::string coarse=argv[11];
        basis.reset(new Buffer<double>(read<double>(coarse+"/basis.f64",size_t(n)*rank)));
        coarseInverse.reset(new Buffer<double>(read<double>(coarse+"/inverse.f64",size_t(rank)*rank)));
        diagonalInverse.reset(new Buffer<double>(read<double>(in+"/inverse.f64",size_t(n)*6)));
        projected.reset(new Buffer<double>(size_t(rank)*nrhs));coarseResult.reset(new Buffer<double>(size_t(pn)*nrhs));
    } else if(argc==12) dense.reset(new DensePreparedOperator(stream,pn,nrhs,read<float>(argv[11],size_t(pn)*pn)));
    else factor.reset(new PreparedOperator(stream,pn,nrhs,read<int>(parent+".rows.i32",pn+1),read<int>(parent+".cols.i32",pnnz),read<double>(parent+".values.f64",pnnz)));
    Csr A(in+"/A",n,n,annz),B(in+"/B",n,m,bnnz),BT(in+"/BT",m,n,bnnz);
    auto mapping=read<int>(in+"/restriction.i32",n);auto sorted=mapping;std::sort(sorted.begin(),sorted.end());
    if(sorted.front()<0 || sorted.back()>=pn || std::adjacent_find(sorted.begin(),sorted.end())!=sorted.end()) throw std::runtime_error("invalid injective restriction");
    Buffer<int> restriction(mapping);
    Buffer<double> original(read<double>(in+"/original.f64",size_t(n)*nrhs)),warm(read<double>(in+"/warm.f64",size_t(m)*nrhs)),
        rhs(read<double>(in+"/rhs.f64",size_t(n)*nrhs)),threshold(read<double>(in+"/threshold.f64",nrhs));
    Buffer<double> x(size_t(n)*nrhs),r(size_t(n)*nrhs),p(size_t(n)*nrhs),q(size_t(n)*nrhs),balance(size_t(n)*nrhs),force(size_t(m)*nrhs),gradient(size_t(m)*nrhs);
    Buffer<State> state(nrhs);std::vector<State> hostState(nrhs);
    auto factorStart=Clock::now();if(factor)factor->prepare();
    double factorMs=factor?std::chrono::duration<double,std::milli>(Clock::now()-factorStart).count():0;
    double setupMs=std::chrono::duration<double,std::milli>(Clock::now()-start).count();
    std::vector<double> timings;
    auto matvec=[&](const Csr& matrix,const double* v,double* result) {
        multiply<<<dim3((matrix.n+255)/256,nrhs),256,0,stream>>>(matrix.n,matrix.m,matrix.rows.get(),matrix.columns.get(),matrix.values.get(),v,result,state.get());
    };
    int factorApplications=0,statusReads=0;
    for(int repetition=0;repetition<6;++repetition) {
        auto begin=Clock::now();
        cudaCheck(cudaMemsetAsync(x.get(),0,x.bytes(),stream));
        cudaCheck(cudaMemsetAsync(p.get(),0,p.bytes(),stream));
        cudaCheck(cudaMemsetAsync(state.get(),0,state.bytes(),stream));
        cudaCheck(cudaMemcpyAsync(r.get(),rhs.get(),r.bytes(),cudaMemcpyDeviceToDevice,stream));
        factorApplications=0;statusReads=0;
        for(int iteration=0;iteration<=8192;++iteration) {
            matvec(BT,x.get(),force.get());
            forceRound<<<dim3((m+255)/256,nrhs),256,0,stream>>>(m,force.get(),warm.get(),state.get());
            matvec(B,force.get(),balance.get());
            subtract<<<dim3((n+255)/256,nrhs),256,0,stream>>>(n,original.get(),balance.get(),state.get());
            matvec(BT,balance.get(),gradient.get());
            check<<<nrhs,256,0,stream>>>(m,gradient.get(),threshold.get(),state.get());
            // Diagnostic host orchestration only; its cost is inside the replay
            // timing. Runtime integration must remove this per-iteration join.
            cudaCheck(cudaMemcpyAsync(hostState.data(),state.get(),state.bytes(),cudaMemcpyDeviceToHost,stream));
            cudaCheck(cudaStreamSynchronize(stream));++statusReads;
            if(std::all_of(hostState.begin(),hostState.end(),[](State s){return s.done;})) break;
            if(iteration==8192) throw std::runtime_error("iteration budget exhausted");
            if(iteration) {
                if(rank) {
                    coarseProjection<<<dim3((rank+7)/8,nrhs),256,0,stream>>>(n,rank,basis->get(),r.get(),projected->get(),state.get());
                    coarseExpansion<<<dim3((n+255)/256,nrhs),256,0,stream>>>(n,pn,rank,restriction.get(),basis->get(),coarseInverse->get(),diagonalInverse->get(),projected->get(),r.get(),coarseResult->get(),state.get());
                } else if(dense){
                    cudaCheck(cudaMemsetAsync(dense->input(),0,dense->inputBytes(),stream));
                    pad<<<dim3((n+255)/256,nrhs),256,0,stream>>>(n,pn,restriction.get(),r.get(),dense->input(),state.get());
                    dense->apply();
                } else {
                    cudaCheck(cudaMemsetAsync(factor->input(),0,factor->inputBytes(),stream));
                    pad<<<dim3((n+255)/256,nrhs),256,0,stream>>>(n,pn,restriction.get(),r.get(),factor->input(),state.get());
                    factor->apply();
                }
                ++factorApplications;
            }
            direction<<<nrhs,256,0,stream>>>(n,pn,restriction.get(),r.get(),rank?coarseResult->get():dense?dense->output():factor->output(),p.get(),state.get(),iteration);
            matvec(A,p.get(),q.get());
            update<<<nrhs,256,0,stream>>>(n,p.get(),q.get(),x.get(),r.get(),state.get());
        }
        cudaCheck(cudaGetLastError());cudaCheck(cudaStreamSynchronize(stream));
        timings.push_back(std::chrono::duration<double,std::milli>(Clock::now()-begin).count());
        for(auto s:hostState) if(!s.done || s.failed) throw std::runtime_error("failed current-force acceptance");
        std::vector<double> result(size_t(n)*nrhs);cudaCheck(cudaMemcpy(result.data(),x.get(),x.bytes(),cudaMemcpyDeviceToHost));
        std::ofstream file(out+".solution-"+std::to_string(repetition)+".f64",std::ios::binary);
        file.write(reinterpret_cast<const char*>(result.data()),x.bytes());if(!file) throw std::runtime_error("output failure");
    }
    std::ofstream json(out+".json");json<<std::setprecision(17)<<"{\"scope\":\"GPU mathematical replay; not full-step timing\",\"coarse_rank\":"<<rank<<",\"setup_ms\":"<<setupMs<<",\"factor_prepare_ms\":"<<factorMs<<",\"preconditioner_applications_last_run\":"<<factorApplications<<",\"status_reads_last_run\":"<<statusReads<<",\"solve_ms\":[";
    for(size_t i=0;i<timings.size();++i){if(i)json<<',';json<<timings[i];}json<<"],\"updates\":[";
    for(size_t i=0;i<hostState.size();++i){if(i)json<<',';json<<hostState[i].updates;}json<<"],\"status\":\"GPU_completed_independent_quality_pending\"}\n";
    if(!json) throw std::runtime_error("receipt output failure");
    }
    cudaCheck(cudaStreamDestroy(stream));return 0;
} catch(const std::exception& error) { std::cerr<<error.what()<<'\n'; return 1; } }
