// Native ownership bridge: immutable/operator data are borrowed, never copied.
#ifdef PHYSX_RESIDENT_DESTRUCTION
struct NativeStressCycleView {
    StressHierarchy::CycleDeviceView cycle{};
    StressHierarchy::Vector *rhs=nullptr,*result=nullptr;
    AngLin *g=nullptr,*lg=nullptr;
    float *gamma=nullptr,*previous=nullptr;
    unsigned* failed=nullptr;
    const ExtStressGpuDeviceTopologyStatus* topology=nullptr;
};
__global__ void publishNativeHierarchyStatus(const StressHierarchy::Status* hierarchy,ExtStressGpuDeviceTopologyStatus* topology){
    if(!hierarchy->initialized || hierarchy->error || hierarchy->generation!=topology->generation)topology->error|=8u;
}
class NativeStressHierarchy {
    StressHierarchy::ResidentHierarchy mHierarchy;
    std::unique_ptr<StressHierarchy::ResidentCycle> mCycle;
    NativeStressCycleView mView;cudaStream_t mStream;
    template<class T>static void allocate(T*& p,unsigned count){checkCuda(cudaMalloc(&p,std::max(size_t(1),size_t(count))*sizeof(T)),"allocate native hierarchy workspace");}
    void release()noexcept{cudaFree(mView.rhs);cudaFree(mView.result);cudaFree(mView.g);cudaFree(mView.lg);cudaFree(mView.gamma);cudaFree(mView.previous);cudaFree(mView.failed);}
public:
    NativeStressHierarchy(StressHierarchy::Input input,const ExtStressGpuDeviceTopologyStatus* status,cudaStream_t stream)
        :mHierarchy(input,input.nodes>257?16:7,stream),mStream(stream){
        mView.topology=status;
        try{
            allocate(mView.rhs,input.nodes);allocate(mView.result,input.nodes);allocate(mView.g,input.nodes);allocate(mView.lg,input.nodes);
            allocate(mView.gamma,input.nodes);allocate(mView.previous,input.nodes);allocate(mView.failed,input.nodes);
            // Boundary rows remain zero. Active rows are overwritten by their
            // owning component, inside the resident iteration, before any read.
            checkCuda(cudaMemsetAsync(mView.g,0,sizeof(AngLin)*input.nodes,stream),"initialize native hierarchy boundaries");
        }catch(...){release();throw;}
    }
    ~NativeStressHierarchy(){cudaStreamSynchronize(mStream);mCycle.reset();release();}
    NativeStressHierarchy(const NativeStressHierarchy&)=delete;NativeStressHierarchy& operator=(const NativeStressHierarchy&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        prior=mHierarchy.append(graph,prior);mCycle.reset(new StressHierarchy::ResidentCycle(mHierarchy));mView.cycle=mCycle->deviceView();return prior;
    }
    NativeStressCycleView view()const{return mView;}
    const StressHierarchy::Status* status()const{return mHierarchy.status();}
};
#endif
