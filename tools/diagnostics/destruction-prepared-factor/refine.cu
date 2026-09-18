// FP32 current factors with FP64 outer residuals and accumulated corrections.
// Fixed ten corrections are an experimental cost/quality bound. The independent
// checker still uses original B, recovered FP32 forces and original thresholds.
#define PREPARED_REFACTOR_LIBRARY
#include "refactor.cu"
#include <nvtx3/nvToolsExt.h>

__global__ void currentResidual(int n, int nnz, const int* rows, const int* columns,
    const double* values, const double* rhs, const double* x, float* residual) {
    const unsigned row=blockIdx.x*blockDim.x+threadIdx.x, matrix=blockIdx.y;
    if(row>=unsigned(n))return;
    double value=rhs[size_t(matrix)*n+row];
    for(int entry=rows[row];entry<rows[row+1];++entry)
        value=fma(-values[size_t(matrix)*nnz+entry],x[size_t(matrix)*n+columns[entry]],value);
    residual[size_t(matrix)*n+row]=float(value);
}
__global__ void addCorrection(unsigned count, const float* delta, double* x) {
    const unsigned row=blockIdx.x*blockDim.x+threadIdx.x;
    if(row<count)x[row]+=double(delta[row]);
}

int main(int argc,char** argv) { try {
    if(argc!=7)throw std::runtime_error("inputs n nnz nrhs output uniform-batch");
    const std::string in=argv[1],out=argv[5];
    const int n=std::stoi(argv[2]),nnz=std::stoi(argv[3]),loads=std::stoi(argv[4]),batch=std::stoi(argv[6]);
    if(n<=0 || nnz<=0 || loads!=1 || batch<=0 || batch>1024)throw std::runtime_error("dimensions");
    constexpr int corrections=10;
    auto millis=[](auto begin){return std::chrono::duration<double,std::milli>(Clock::now()-begin).count();};
    auto start=Clock::now();cudaCheck(cudaSetDevice(0));cudaCheck(cudaFree(nullptr));
    cudaStream_t stream;cudaCheck(cudaStreamCreate(&stream));
    {
        auto hr=read<int>(in+"/pattern.rows.i32",n+1),hc=read<int>(in+"/pattern.cols.i32",nnz);
        auto h0=read<double>(in+"/solve-0.values.f64",size_t(nnz)*batch),h1=read<double>(in+"/solve-1.values.f64",size_t(nnz)*batch);
        std::vector<float> f0(h0.begin(),h0.end()),f1(h1.begin(),h1.end());
        Buffer<int> rows(hr),columns(hc);
        Buffer<double> A0(h0),A1(h1),b0(read<double>(in+"/solve-0.rhs.f64",size_t(n)*batch)),b1(read<double>(in+"/solve-1.rhs.f64",size_t(n)*batch));
        Buffer<float> factor0(f0),factor1(f1),residual(size_t(n)*batch);
        Buffer<double> x(size_t(n)*batch);
        SymbolicOperator<float> op(stream,n,1,hr,hc,f0,batch);
        double setup=millis(start);start=Clock::now();op.analyze();double analysis=millis(start);
        std::ofstream json(out+"/metrics.json");
        json<<std::setprecision(17)<<"{\"scope\":\"FP32 factors, FP64 residual correction; not native ticks\",\"setup_ms\":"<<setup
            <<",\"analysis_ms\":"<<analysis<<",\"uniform_batch\":"<<batch<<",\"corrections\":"<<corrections<<",\"numeric_epochs\":[";
        std::vector<double> host(size_t(n)*batch);
        for(int repeat=0;repeat<6;++repeat)for(int step=0;step<2;++step){
            nvtxRangePushA("prepared_stress/current_factor_fp32");
            start=Clock::now();op.replace(step?factor1.get():factor0.get());double factor=millis(start);
            nvtxRangePop();nvtxRangePushA("prepared_stress/current_refinement_fp64");
            start=Clock::now();cudaCheck(cudaMemsetAsync(x.get(),0,x.bytes(),stream));
            for(int iteration=0;iteration<corrections;++iteration){
                currentResidual<<<dim3((n+255)/256,batch),256,0,stream>>>(n,nnz,rows.get(),columns.get(),step?A1.get():A0.get(),step?b1.get():b0.get(),x.get(),residual.get());
                op.solve(residual.get());
                addCorrection<<<(size_t(n)*batch+255)/256,256,0,stream>>>(n*batch,op.solution(),x.get());
            }
            cudaCheck(cudaStreamSynchronize(stream));double solve=millis(start);
            nvtxRangePop();
            start=Clock::now();cudaCheck(cudaMemcpyAsync(host.data(),x.get(),x.bytes(),cudaMemcpyDeviceToHost,stream));cudaCheck(cudaStreamSynchronize(stream));double download=millis(start);
            std::ofstream output(out+"/solve-"+std::to_string(step)+".solution-"+std::to_string(repeat)+".f64",std::ios::binary);
            output.write(reinterpret_cast<char*>(host.data()),host.size()*sizeof(double));
            if(!output)throw std::runtime_error("output write");
            if(repeat || step)json<<',';
            json<<"{\"repeat\":"<<repeat<<",\"solve\":"<<step<<",\"factor_ms\":"<<factor<<",\"solve_ms\":"<<solve
                <<",\"download_ms\":"<<download<<",\"library_peak_bytes\":"<<op.peakLibraryBytes()<<'}';json.flush();
        }
        json<<"]}\n";
    }
    cudaCheck(cudaStreamDestroy(stream));return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;} }
