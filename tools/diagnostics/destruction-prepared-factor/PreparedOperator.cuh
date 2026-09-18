#pragma once
// Private experimental resource. A factor represents immutable coefficients,
// never a saved physical answer. Its stream owns all applications until close.
#include <cuda_runtime.h>
#include <cudss.h>
#include <stdexcept>
#include <string>
#include <vector>

namespace PreparedStress {
inline void cudaCheck(cudaError_t e) {
    if (e != cudaSuccess) throw std::runtime_error(cudaGetErrorString(e));
}
inline void solverCheck(cudssStatus_t e) {
    if (e != CUDSS_STATUS_SUCCESS)
        throw std::runtime_error("cuDSS status " + std::to_string(int(e)));
}
template<class T> class Buffer {
    T* pointer_ = nullptr;
    size_t count_;
public:
    explicit Buffer(size_t count): count_(count) {
        if (!count || count > SIZE_MAX / sizeof(T)) throw std::runtime_error("invalid allocation length");
        cudaCheck(cudaMalloc(&pointer_, count * sizeof(T)));
    }
    explicit Buffer(const std::vector<T>& v): Buffer(v.size()) {
        cudaCheck(cudaMemcpy(pointer_, v.data(), bytes(), cudaMemcpyHostToDevice));
    }
    Buffer(const Buffer&) = delete;
    Buffer& operator=(const Buffer&) = delete;
    ~Buffer() { if (pointer_) cudaFree(pointer_); }
    T* get() const { return pointer_; }
    size_t bytes() const { return count_*sizeof(T); }
};

class PreparedOperator {
    cudssHandle_t handle_ = nullptr;
    cudssConfig_t config_ = nullptr;
    cudssData_t data_ = nullptr;
    cudssMatrix_t matrix_ = nullptr, rhs_ = nullptr, result_ = nullptr;
    cudaStream_t stream_;
    Buffer<int> rows_, columns_;
    Buffer<double> coefficients_, input_, output_;
    bool ready_ = false;
    void release() noexcept {
        // Destruction cannot invalidate storage while an application is live.
        cudaStreamSynchronize(stream_);
        if (result_) cudssMatrixDestroy(result_);
        if (rhs_) cudssMatrixDestroy(rhs_);
        if (matrix_) cudssMatrixDestroy(matrix_);
        if (data_) cudssDataDestroy(handle_, data_);
        if (config_) cudssConfigDestroy(config_);
        if (handle_) cudssDestroy(handle_);
    }
public:
    PreparedOperator(cudaStream_t stream, int n, int nrhs,
                     const std::vector<int>& rows, const std::vector<int>& columns,
                     const std::vector<double>& values)
        : stream_(stream), rows_(rows), columns_(columns), coefficients_(values),
          input_(size_t(n)*nrhs), output_(size_t(n)*nrhs) {
        try {
            if (n <= 0 || nrhs <= 0 || rows.size() != size_t(n+1) || columns.size() != values.size())
                throw std::runtime_error("invalid prepared matrix dimensions");
            solverCheck(cudssCreate(&handle_));
            solverCheck(cudssSetStream(handle_, stream_));
            solverCheck(cudssConfigCreate(&config_));
            solverCheck(cudssDataCreate(handle_, &data_));
            solverCheck(cudssMatrixCreateCsr(&matrix_, n,n,values.size(),rows_.get(),nullptr,columns_.get(),coefficients_.get(),
                CUDSS_R_32I,CUDSS_R_32I,CUDSS_R_64F,CUDSS_MTYPE_SPD,CUDSS_MVIEW_FULL,CUDSS_BASE_ZERO));
            solverCheck(cudssMatrixCreateDn(&rhs_,n,nrhs,n,input_.get(),CUDSS_R_64F,CUDSS_LAYOUT_COL_MAJOR));
            solverCheck(cudssMatrixCreateDn(&result_,n,nrhs,n,output_.get(),CUDSS_R_64F,CUDSS_LAYOUT_COL_MAJOR));
        } catch (...) { release(); throw; }
    }
    PreparedOperator(const PreparedOperator&) = delete;
    PreparedOperator& operator=(const PreparedOperator&) = delete;
    ~PreparedOperator() { release(); }
    void prepare() {
        if (ready_) throw std::runtime_error("immutable factor prepared twice");
        solverCheck(cudssExecute(handle_,CUDSS_PHASE_ANALYSIS,config_,data_,matrix_,result_,rhs_));
        solverCheck(cudssExecute(handle_,CUDSS_PHASE_FACTORIZATION,config_,data_,matrix_,result_,rhs_));
        cudaCheck(cudaStreamSynchronize(stream_));
        int info = -1; size_t written = 0;
        solverCheck(cudssDataGet(handle_,data_,CUDSS_DATA_INFO,&info,sizeof(info),&written));
        if (info != 0) throw std::runtime_error("parent factor failed SPD admission: " + std::to_string(info));
        ready_ = true;
    }
    // Caller zero-pads and scatters the *current* residual into input().
    // Gather the child rows from output(): R A_parent^-1 R^T is fixed SPD.
    void apply() {
        if (!ready_) throw std::runtime_error("unprepared operator");
        solverCheck(cudssExecute(handle_,CUDSS_PHASE_SOLVE,config_,data_,matrix_,result_,rhs_));
    }
    double* input() { return input_.get(); }
    const double* output() const { return output_.get(); }
    size_t inputBytes() const { return input_.bytes(); }
};
} // namespace PreparedStress
