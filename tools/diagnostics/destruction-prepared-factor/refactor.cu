// Current-operator numeric replacement using a prepared symbolic envelope.
// Captured equation replay only. No native integration or cached physical answer.
#include "PreparedOperator.cuh"
#include <chrono>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <array>
#include <cstring>
#include <algorithm>
#include <type_traits>
#include <cstdint>
using namespace PreparedStress;
using Clock = std::chrono::steady_clock;
template<class T> std::vector<T> read(const std::string& path, size_t count) {
    std::ifstream f(path, std::ios::binary | std::ios::ate);
    if (!f || size_t(f.tellg()) != count*sizeof(T)) throw std::runtime_error("input size: "+path);
    std::vector<T> result(count); f.seekg(0);
    f.read(reinterpret_cast<char*>(result.data()), count*sizeof(T));
    if (!f) throw std::runtime_error("read: "+path);
    return result;
}

// Coefficients can change only at a serialized topology boundary. Analysis is
// immutable; a numeric epoch becomes usable only after a successful factor.
template<class Real=double> class SymbolicOperator {
    cudssHandle_t handle = nullptr;
    cudssConfig_t config = nullptr;
    cudssData_t data = nullptr;
    cudssMatrix_t A = nullptr, X = nullptr, B = nullptr;
    cudaStream_t stream;
    Buffer<int> rows, columns;
    Buffer<Real> coefficients, rhs, output;
    bool analyzed = false, factored = false;
    struct Memory {
        size_t live = 0, peak = 0, allocations = 0;
        static int allocate(void* context, void** pointer, size_t bytes, cudaStream_t stream) {
            auto& memory = *static_cast<Memory*>(context);
            auto error = cudaMallocAsync(pointer, bytes, stream);
            if (error == cudaSuccess) { memory.live += bytes; memory.peak = std::max(memory.peak, memory.live); ++memory.allocations; }
            return error == cudaSuccess ? 0 : 1;
        }
        static int free(void* context, void* pointer, size_t bytes, cudaStream_t stream) {
            auto& memory = *static_cast<Memory*>(context);
            auto error = cudaFreeAsync(pointer, stream);
            if (error == cudaSuccess) memory.live -= bytes;
            return error == cudaSuccess ? 0 : 1;
        }
    } memory;
    void release() noexcept {
        cudaStreamSynchronize(stream);
        if (X) cudssMatrixDestroy(X);
        if (B) cudssMatrixDestroy(B);
        if (A) cudssMatrixDestroy(A);
        if (data) cudssDataDestroy(handle, data);
        if (config) cudssConfigDestroy(config);
        if (handle) cudssDestroy(handle);
        cudaStreamSynchronize(stream);
    }
    void phase(int flag) {
        auto status=cudssExecute(handle, flag, config, data, A, X, B);
        if(status!=CUDSS_STATUS_SUCCESS)throw std::runtime_error("cuDSS phase "+std::to_string(flag)+" status "+std::to_string(status));
        cudaCheck(cudaStreamSynchronize(stream));
        int info = -1; size_t written = 0;
        solverCheck(cudssDataGet(handle, data, CUDSS_DATA_INFO, &info, sizeof(info), &written));
        if (info) throw std::runtime_error("numeric status: "+std::to_string(info));
    }
public:
    SymbolicOperator(cudaStream_t s, int n, int loads, const std::vector<int>& r,
                     const std::vector<int>& c, const std::vector<Real>& initial, int batch=1, bool selective=false)
        : stream(s), rows(r), columns(c), coefficients(initial), rhs(size_t(n)*loads*batch), output(size_t(n)*loads*batch) {
        try {
            solverCheck(cudssCreate(&handle)); solverCheck(cudssSetStream(handle, stream));
            cudssDeviceMemHandler_t allocator{};
            allocator.ctx=&memory; allocator.device_alloc=Memory::allocate; allocator.device_free=Memory::free;
            std::strcpy(allocator.name,"prepared-stress-counted-async");
            solverCheck(cudssSetDeviceMemHandler(handle,&allocator));
            solverCheck(cudssConfigCreate(&config)); solverCheck(cudssDataCreate(handle, &data));
            solverCheck(cudssConfigSet(config,CUDSS_CONFIG_UBATCH_SIZE,&batch,sizeof(batch)));
            if(selective){
                // This build allocates its device mask during analysis only.
                std::vector<int> all(batch,1);
                solverCheck(cudssDataSet(handle,data,CUDSS_DATA_UBATCH_MASK,all.data(),all.size()*sizeof(int)));
            }
            constexpr auto valueType=std::is_same<Real,double>::value?CUDSS_R_64F:CUDSS_R_32F;
            solverCheck(cudssMatrixCreateCsr(&A, n,n,c.size(),rows.get(),nullptr,columns.get(),coefficients.get(),
                CUDSS_R_32I,CUDSS_R_32I,valueType,CUDSS_MTYPE_SPD,CUDSS_MVIEW_FULL,CUDSS_BASE_ZERO));
            solverCheck(cudssMatrixCreateDn(&B,n,loads,n,rhs.get(),valueType,CUDSS_LAYOUT_COL_MAJOR));
            solverCheck(cudssMatrixCreateDn(&X,n,loads,n,output.get(),valueType,CUDSS_LAYOUT_COL_MAJOR));
        } catch (...) { release(); throw; }
    }
    ~SymbolicOperator() { release(); }
    SymbolicOperator(const SymbolicOperator&) = delete;
    SymbolicOperator& operator=(const SymbolicOperator&) = delete;
    void analyze() {
        if (analyzed) throw std::runtime_error("analysis repeated");
        phase(CUDSS_PHASE_ANALYSIS); analyzed = true;
    }
    void replace(const Real* current) {
        if (!analyzed) throw std::runtime_error("no symbolic preparation");
        bool reuse = factored; factored = false;
        cudaCheck(cudaMemcpyAsync(coefficients.get(), current, coefficients.bytes(), cudaMemcpyDeviceToDevice, stream));
        phase(reuse ? CUDSS_PHASE_REFACTORIZATION : CUDSS_PHASE_FACTORIZATION);
        factored = true;
    }
    void solve(const Real* current) {
        if (!factored) throw std::runtime_error("no accepted numeric factor");
        cudaCheck(cudaMemcpyAsync(rhs.get(), current, rhs.bytes(), cudaMemcpyDeviceToDevice, stream));
        phase(CUDSS_PHASE_SOLVE);
    }
    void download(std::vector<Real>& host) {
        if (host.size()*sizeof(Real) != output.bytes()) throw std::runtime_error("output size");
        cudaCheck(cudaMemcpyAsync(host.data(),output.get(),output.bytes(),cudaMemcpyDeviceToHost,stream));
        cudaCheck(cudaStreamSynchronize(stream));
    }
    size_t peakLibraryBytes() const { return memory.peak; }
    size_t liveLibraryBytes() const { return memory.live; }
    size_t libraryAllocations() const { return memory.allocations; }
    const Real* solution() const { return output.get(); }
    void replaceSelected(const Real* current,const std::vector<int>& dirty) {
        if(!analyzed || !factored)throw std::runtime_error("Selective update needs initialized factors");
        // The installed library's execution diagnostic requires batch*sizeof(int)
        // bytes, and mask storage must be requested before analysis. Latest web
        // docs describe a different ABI. This path FAILS retained-factor quality
        // in the captured probe; do not integrate it until that is resolved.
        if(std::any_of(dirty.begin(),dirty.end(),[](int v){return v!=0 && v!=1;}))throw std::runtime_error("Invalid dirty flag");
        if(std::none_of(dirty.begin(),dirty.end(),[](int v){return v!=0;}))return;
        factored=false;
        cudaCheck(cudaMemcpyAsync(coefficients.get(),current,coefficients.bytes(),cudaMemcpyDeviceToDevice,stream));
        auto status=cudssDataSet(handle,data,CUDSS_DATA_UBATCH_MASK,dirty.data(),dirty.size()*sizeof(int));
        if(status!=CUDSS_STATUS_SUCCESS)throw std::runtime_error("cuDSS set subset mask status "+std::to_string(status));
        phase(CUDSS_PHASE_REFACTORIZATION);
        std::vector<int> all(dirty.size(),1);
        solverCheck(cudssDataSet(handle,data,CUDSS_DATA_UBATCH_MASK,all.data(),all.size()*sizeof(int)));
        factored=true;
    }
};

#ifndef PREPARED_REFACTOR_LIBRARY
int main(int argc, char** argv) { try {
    if (argc != 6 && argc != 7) throw std::runtime_error("inputs n nnz nrhs output [uniform-batch]");
    std::string in=argv[1], out=argv[5];
    int n=std::stoi(argv[2]), nnz=std::stoi(argv[3]), loads=std::stoi(argv[4]);
    const int batch=argc==7?std::stoi(argv[6]):1;
    if (n <= 0 || nnz <= 0 || loads <= 0 || batch <= 0 || batch>1024) throw std::runtime_error("dimensions");
    auto start=Clock::now(); cudaCheck(cudaSetDevice(0)); cudaCheck(cudaFree(nullptr));
    cudaStream_t stream; cudaCheck(cudaStreamCreate(&stream));
    auto millis=[](auto begin) { return std::chrono::duration<double,std::milli>(Clock::now()-begin).count(); };
    {
        auto rows=read<int>(in+"/pattern.rows.i32",n+1), cols=read<int>(in+"/pattern.cols.i32",nnz);
        auto values0=read<double>(in+"/solve-0.values.f64",size_t(nnz)*batch), values1=read<double>(in+"/solve-1.values.f64",size_t(nnz)*batch);
        Buffer<double> v0(values0), v1(values1), b0(read<double>(in+"/solve-0.rhs.f64",size_t(n)*loads*batch)),
            b1(read<double>(in+"/solve-1.rhs.f64",size_t(n)*loads*batch));
        SymbolicOperator<double> op(stream,n,loads,rows,cols,values0,batch);
        double setup=millis(start); start=Clock::now(); op.analyze(); double analysis=millis(start);
        std::ofstream json(out+"/metrics.json");
        json<<std::setprecision(17)<<"{\"scope\":\"current coefficients and current loads; not native ticks\",\"setup_ms\":"<<setup
            <<",\"analysis_ms\":"<<analysis<<",\"uniform_batch\":"<<batch<<",\"numeric_epochs\":[";
        std::vector<double> x(size_t(n)*loads*batch);
        // Alternate actual captured operators, including removal/restoration of
        // 24 active nodes. Restoration here stress-tests cache invalidation;
        // production topology remains deletion-only.
        for (int repeat=0; repeat<6; ++repeat) for (int step=0; step<2; ++step) {
            start=Clock::now(); op.replace(step?v1.get():v0.get()); double factor=millis(start);
            start=Clock::now(); op.solve(step?b1.get():b0.get()); double solve=millis(start);
            start=Clock::now(); op.download(x); double download=millis(start);
            std::string path=out+"/solve-"+std::to_string(step)+".solution-"+std::to_string(repeat)+".f64";
            std::ofstream output(path,std::ios::binary);
            output.write(reinterpret_cast<char*>(x.data()),x.size()*sizeof(double));
            if (!output) throw std::runtime_error("output write");
            if (repeat || step) json<<',';
            json<<"{\"repeat\":"<<repeat<<",\"solve\":"<<step<<",\"factor_ms\":"<<factor
                <<",\"solve_ms\":"<<solve<<",\"download_ms\":"<<download
                <<",\"library_live_bytes\":"<<op.liveLibraryBytes()<<",\"library_peak_bytes\":"<<op.peakLibraryBytes()
                <<",\"library_allocations\":"<<op.libraryAllocations()<<'}';
            json.flush();
        }
        json<<"]}\n";
    }
    cudaCheck(cudaStreamDestroy(stream)); return 0;
} catch (const std::exception& e) { std::cerr<<e.what()<<'\n'; return 1; } }
#endif
