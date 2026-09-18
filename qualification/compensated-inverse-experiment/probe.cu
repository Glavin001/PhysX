#include "NvBlastExtStressGpu.cu"
#include <cstdio>
using namespace Nv::Blast;
#include "compensated_inverse.cuh"
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<bool compensated>__global__ void inverseProbe(NativeStressCycleView h,CompensatedInverseView split,const StressHierarchy::Vector* in,StressHierarchy::Vector* out,unsigned n){
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;if(node>=n)return;
    if constexpr(compensated)out[node]=applyCompensatedInverse(split,node,in[node]);else out[node]=applyNativeFineInverse(h,node,in[node]);
}
int main(){try{
    constexpr unsigned n=256*380; // Dynamic stress nodes of 256 intact buildings.
    std::vector<double> matrix(size_t(n)*21);std::vector<StressHierarchy::Vector> input(n),reference(n),candidate(n);
    // Symmetric diagonally dominant positive matrices, mixed-sign vectors;
    // exponents span normal/subnormal float ranges without changing FP64 inputs.
    for(unsigned node=0;node<n;++node){
        const int me=int(node%9)*60-240,ve=int(node%11)*55-275;double x[6];
        for(unsigned k=0;k<6;++k)x[k]=std::ldexp((int((node*3+k*7)%17)-8)/7.37,ve);
        input[node]={{x[0],x[1],x[2]},{x[3],x[4],x[5]}};
        for(unsigned row=0;row<6;++row)for(unsigned col=0;col<=row;++col){const double v=row==col?2.+std::sqrt(1.+double((node+row)%11))/8:(int((node*7+row*3+col)%9)-4)/31.17;matrix[size_t(row*(row+1)/2+col)*n+node]=std::ldexp(v,me);}}
    NativeStressCycleView h{};CompensatedInverseView c{};h.inverseStride=c.stride=n;StressHierarchy::Vector *in,*out;
    check(cudaMalloc(&h.fineInverse,matrix.size()*sizeof(double)));check(cudaMalloc(&c.coefficients,matrix.size()*sizeof(float2)));check(cudaMalloc(&c.exponent,n*sizeof(int)));check(cudaMalloc(&in,n*sizeof(*in)));check(cudaMalloc(&out,n*sizeof(*out)));
    check(cudaMemcpy(h.fineInverse,matrix.data(),matrix.size()*sizeof(double),cudaMemcpyHostToDevice));check(cudaMemcpy(in,input.data(),n*sizeof(*in),cudaMemcpyHostToDevice));packCompensatedInverse<<<(n+255)/256,256>>>(h.fineInverse,c);check(cudaDeviceSynchronize());
    inverseProbe<false><<<(n+255)/256,256>>>(h,c,in,out,n);check(cudaDeviceSynchronize());check(cudaMemcpy(reference.data(),out,n*sizeof(*out),cudaMemcpyDeviceToHost));
    inverseProbe<true><<<(n+255)/256,256>>>(h,c,in,out,n);check(cudaDeviceSynchronize());check(cudaMemcpy(candidate.data(),out,n*sizeof(*out),cudaMemcpyDeviceToHost));
    double worst=0;for(unsigned node=0;node<n;++node){const auto* a=reinterpret_cast<const double*>(&candidate[node]);const auto* b=reinterpret_cast<const double*>(&reference[node]);double norm=0;for(unsigned k=0;k<6;++k)norm=std::max(norm,std::abs(b[k]));for(unsigned k=0;k<6;++k){const double error=std::abs(a[k]-b[k])/std::max(norm,1e-300);if(!std::isfinite(error)||error>=2e-12)throw std::runtime_error("compensated inverse accuracy threshold failed");worst=std::max(worst,error);}}
    cudaEvent_t begin,end;check(cudaEventCreate(&begin));check(cudaEventCreate(&end));
    // Alternate arms to reduce drift; all arithmetic remains dependent on inputs.
    for(unsigned trial=0;trial<5;++trial)for(unsigned arm=0;arm<2;++arm){const bool use=(trial+arm)%2;check(cudaEventRecord(begin));for(unsigned i=0;i<100;++i){if(use)inverseProbe<true><<<(n+255)/256,256>>>(h,c,in,out,n);else inverseProbe<false><<<(n+255)/256,256>>>(h,c,in,out,n);}check(cudaEventRecord(end));check(cudaEventSynchronize(end));float ms;check(cudaEventElapsedTime(&ms,begin,end));std::printf("{\"nodes\":%u,\"matrices\":%u,\"applications_per_node\":100,\"trial\":%u,\"compensated\":%s,\"gpu_ms\":%.6f,\"worst_relative_error\":%.12g}\n",n,n,trial,use?"true":"false",ms,worst);}
    check(cudaEventDestroy(begin));check(cudaEventDestroy(end));check(cudaFree(in));check(cudaFree(out));check(cudaFree(h.fineInverse));check(cudaFree(c.coefficients));check(cudaFree(c.exponent));return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
