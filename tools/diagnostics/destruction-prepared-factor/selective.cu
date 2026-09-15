// Current coefficients are compared on the GPU here as a conservative oracle.
// Native integration must use the topology producer's invalidation flags.
#define PREPARED_REFACTOR_LIBRARY
#include "refactor.cu"
#include <nvtx3/nvToolsExt.h>
#include <memory>
__global__ void changedCoefficients(unsigned nnz,const double* previous,const double* current,int* dirty){
    unsigned entry=blockIdx.x*blockDim.x+threadIdx.x,asset=blockIdx.y;
    if(entry<nnz && previous[size_t(asset)*nnz+entry]!=current[size_t(asset)*nnz+entry])atomicExch(dirty+asset,1);
}
int main(int argc,char** argv){try{
    solverCheck(cudssLoggerSetLevel(1)); // Error-only; failed calls need context.
#ifdef PREPARED_LIBRARY_DIAGNOSTIC
    solverCheck(cudssLoggerSetLevel(5));
    solverCheck(cudssLoggerSetFile(stderr));
#endif
    if(argc!=7)throw std::runtime_error("inputs n nnz nrhs output uniform-batch");
    const std::string in=argv[1],out=argv[5];
    int n=std::stoi(argv[2]),nnz=std::stoi(argv[3]),loads=std::stoi(argv[4]),batch=std::stoi(argv[6]);
    if(n<=0||nnz<=0||loads!=1||batch!=256)throw std::runtime_error("Expected 256-asset capture");
    auto millis=[](auto begin){return std::chrono::duration<double,std::milli>(Clock::now()-begin).count();};
    auto start=Clock::now();cudaCheck(cudaSetDevice(0));cudaCheck(cudaFree(nullptr));
    cudaStream_t stream;cudaCheck(cudaStreamCreate(&stream));
    {
        auto rows=read<int>(in+"/pattern.rows.i32",n+1),cols=read<int>(in+"/pattern.cols.i32",nnz);
        auto h0=read<double>(in+"/solve-0.values.f64",size_t(nnz)*batch),h1=read<double>(in+"/solve-1.values.f64",size_t(nnz)*batch);
        Buffer<double> A0(h0),A1(h1),b0(read<double>(in+"/solve-0.rhs.f64",size_t(n)*batch)),b1(read<double>(in+"/solve-1.rhs.f64",size_t(n)*batch));
        Buffer<int> changed(batch);std::vector<int> dirty(batch);
        constexpr int groupSize=256;
        std::vector<std::unique_ptr<SymbolicOperator<double>>> groups;
        for(int group=0;group<batch/groupSize;++group){
            auto begin=h0.begin()+size_t(group)*groupSize*nnz;
            groups.emplace_back(new SymbolicOperator<double>(stream,n,1,rows,cols,std::vector<double>(begin,begin+size_t(groupSize)*nnz),groupSize,true));
        }
        double setup=millis(start);start=Clock::now();for(auto& group:groups)group->analyze();double analysis=millis(start);
        std::ofstream metrics(out+"/metrics.json");metrics<<std::setprecision(17)<<"{\"scope\":\"Selective numeric refactor, current load; not native ticks\",\"setup_ms\":"<<setup
            <<",\"analysis_ms\":"<<analysis<<",\"mask_bytes\":"<<groupSize*sizeof(int)<<",\"group_size\":"<<groupSize<<",\"uniform_batch\":"<<batch<<",\"numeric_epochs\":[";
        std::vector<double> host(size_t(n)*batch),groupHost(size_t(n)*groupSize);
        for(int repeat=0;repeat<6;++repeat)for(int step=0;step<2;++step){
            const bool first=repeat==0&&step==0;
            const auto* current=step?A1.get():A0.get();const auto* previous=step?A0.get():A1.get();
            nvtxRangePushA("prepared_stress/detect_dirty_coefficients");start=Clock::now();
            if(first)std::fill(dirty.begin(),dirty.end(),1);
            else {
                cudaCheck(cudaMemsetAsync(changed.get(),0,changed.bytes(),stream));
                changedCoefficients<<<dim3((nnz+255)/256,batch),256,0,stream>>>(nnz,previous,current,changed.get());
                cudaCheck(cudaMemcpyAsync(dirty.data(),changed.get(),changed.bytes(),cudaMemcpyDeviceToHost,stream));
                cudaCheck(cudaStreamSynchronize(stream));
            }
            double detect=millis(start);nvtxRangePop();nvtxRangePushA("prepared_stress/selective_factor");start=Clock::now();
            for(int group=0;group<int(groups.size());++group){
                const double* values=current+size_t(group)*groupSize*nnz;
                if(first)groups[group]->replace(values);
                else groups[group]->replaceSelected(values,std::vector<int>(dirty.begin()+group*groupSize,dirty.begin()+(group+1)*groupSize));
            }
            double factor=millis(start);nvtxRangePop();nvtxRangePushA("prepared_stress/current_solve");start=Clock::now();
            for(int group=0;group<int(groups.size());++group)groups[group]->solve((step?b1.get():b0.get())+size_t(group)*groupSize*n);
            double solve=millis(start);nvtxRangePop();
            start=Clock::now();size_t peak=0;
            for(int group=0;group<int(groups.size());++group){
                groups[group]->download(groupHost);std::copy(groupHost.begin(),groupHost.end(),host.begin()+size_t(group)*groupSize*n);
                peak+=groups[group]->peakLibraryBytes();
            }
            double download=millis(start);
            std::ofstream f(out+"/solve-"+std::to_string(step)+".solution-"+std::to_string(repeat)+".f64",std::ios::binary);
            f.write(reinterpret_cast<char*>(host.data()),host.size()*sizeof(double));if(!f)throw std::runtime_error("output write");
            if(repeat||step)metrics<<',';
            metrics<<"{\"repeat\":"<<repeat<<",\"solve\":"<<step<<",\"dirty_assets\":"<<std::count(dirty.begin(),dirty.end(),1)<<",\"detect_and_readback_ms\":"<<detect
                <<",\"factor_ms\":"<<factor<<",\"solve_ms\":"<<solve<<",\"download_ms\":"<<download<<",\"library_peak_bytes\":"<<peak<<'}';metrics.flush();
        }
        metrics<<"]}\n";
    }
    cudaCheck(cudaStreamDestroy(stream));return 0;
}catch(const std::exception& error){std::cerr<<error.what()<<'\n';return 1;}}
