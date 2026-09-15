#pragma once
#include "PreparedOperator.cuh"
#include <cublas_v2.h>
namespace PreparedStress {
inline void blasCheck(cublasStatus_t status){if(status!=CUBLAS_STATUS_SUCCESS)throw std::runtime_error("cuBLAS status "+std::to_string(status));}
template<class To,class From> __global__ void convertPrepared(unsigned count,const From* source,To* destination){
    unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<count)destination[i]=To(source[i]);
}
// R is a fixed, nonsingular rounded inverse Cholesky factor. R^T R is SPD
// in exact arithmetic. Current residuals are restricted/zero-padded by caller.
// The original current-force check remains authoritative after FP32 products.
class DensePreparedOperator {
    cublasHandle_t handle=nullptr;
    cudaStream_t stream;
    int n,loads;
    Buffer<float> inverse,input32,temporary,output32;
    Buffer<double> input64,output64;
public:
    DensePreparedOperator(cudaStream_t s,int rows,int rhs,const std::vector<float>& R)
      :stream(s),n(rows),loads(rhs),inverse(R),input32(size_t(rows)*rhs),temporary(size_t(rows)*rhs),
       output32(size_t(rows)*rhs),input64(size_t(rows)*rhs),output64(size_t(rows)*rhs){
        if(rows<=0||rhs<=0||R.size()!=size_t(rows)*rows)throw std::runtime_error("Inverse-factor dimensions");
        try{blasCheck(cublasCreate(&handle));blasCheck(cublasSetStream(handle,stream));
            blasCheck(cublasSetMathMode(handle,CUBLAS_PEDANTIC_MATH));
        }catch(...){if(handle)cublasDestroy(handle);throw;}
    }
    DensePreparedOperator(const DensePreparedOperator&)=delete;
    DensePreparedOperator& operator=(const DensePreparedOperator&)=delete;
    ~DensePreparedOperator(){cudaStreamSynchronize(stream);if(handle)cublasDestroy(handle);}
    void apply(){
        const float one=1,zero=0;const unsigned count=n*loads;
        convertPrepared<<<(count+255)/256,256,0,stream>>>(count,input64.get(),input32.get());
        blasCheck(cublasSgemm(handle,CUBLAS_OP_N,CUBLAS_OP_N,n,loads,n,&one,inverse.get(),n,input32.get(),n,&zero,temporary.get(),n));
        blasCheck(cublasSgemm(handle,CUBLAS_OP_T,CUBLAS_OP_N,n,loads,n,&one,inverse.get(),n,temporary.get(),n,&zero,output32.get(),n));
        convertPrepared<<<(count+255)/256,256,0,stream>>>(count,output32.get(),output64.get());
    }
    double* input(){return input64.get();}
    const double* output()const{return output64.get();}
    size_t inputBytes()const{return input64.bytes();}
};
}
