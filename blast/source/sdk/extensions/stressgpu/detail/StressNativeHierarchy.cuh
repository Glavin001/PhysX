// Native ownership bridge: immutable/operator data are borrowed, never copied.
#ifdef PHYSX_RESIDENT_DESTRUCTION
struct NativeStressCycleView {
    StressHierarchy::CycleDeviceView cycle{};
    StressHierarchy::MotionModeView modes{};
    StressHierarchy::Vector *rhs=nullptr,*result=nullptr,*solution=nullptr;
    AngLin *g=nullptr;
    float *gamma=nullptr,*previous=nullptr;
    double* normalizer=nullptr;
    unsigned* failed=nullptr;
    const ExtStressGpuDeviceTopologyStatus* topology=nullptr;
};
__global__ void publishNativeHierarchyStatus(const StressHierarchy::Status* hierarchy,const StressHierarchy::Status* modes,ExtStressGpuDeviceTopologyStatus* topology){
    if(!hierarchy->initialized || hierarchy->error || hierarchy->generation!=topology->generation || !modes->initialized || modes->error || modes->generation!=topology->generation)topology->error|=8u;
}
class NativeStressHierarchy {
    StressHierarchy::ResidentHierarchy mHierarchy;
    StressHierarchy::ResidentMotionModes mModes;
    std::unique_ptr<StressHierarchy::ResidentCycle> mCycle;
    NativeStressCycleView mView;cudaStream_t mStream;
    template<class T>static void allocate(T*& p,unsigned count){checkCuda(cudaMalloc(&p,std::max(size_t(1),size_t(count))*sizeof(T)),"allocate native hierarchy workspace");}
    void release()noexcept{cudaFree(mView.rhs);cudaFree(mView.solution);cudaFree(mView.result);cudaFree(mView.g);cudaFree(mView.gamma);cudaFree(mView.previous);cudaFree(mView.failed);cudaFree(mView.normalizer);}
public:
    NativeStressHierarchy(StressHierarchy::Input input,const unsigned* forest,const ExtStressGpuDeviceTopologyStatus* status,cudaStream_t stream)
        :mHierarchy(input,input.nodes>257?16:7,stream),mModes(input,forest,stream),mStream(stream){
        mView.topology=status;mView.modes=mModes.view();
        try{
            allocate(mView.rhs,input.nodes);allocate(mView.solution,input.nodes);allocate(mView.result,input.nodes);allocate(mView.g,input.nodes);
            allocate(mView.gamma,input.nodes);allocate(mView.previous,input.nodes);allocate(mView.failed,input.nodes);allocate(mView.normalizer,input.nodes);
            // Boundary rows remain zero. Active rows are overwritten by their
            // owning component, inside the resident iteration, before any read.
            checkCuda(cudaMemsetAsync(mView.g,0,sizeof(AngLin)*input.nodes,stream),"initialize native hierarchy boundaries");
        }catch(...){release();throw;}
    }
    ~NativeStressHierarchy(){cudaStreamSynchronize(mStream);mCycle.reset();release();}
    NativeStressHierarchy(const NativeStressHierarchy&)=delete;NativeStressHierarchy& operator=(const NativeStressHierarchy&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        prior=mModes.append(graph,prior);prior=mHierarchy.append(graph,prior);mCycle.reset(new StressHierarchy::ResidentCycle(mHierarchy));mView.cycle=mCycle->deviceView();return prior;
    }
    NativeStressCycleView view()const{return mView;}
    const StressHierarchy::Status* status()const{return mHierarchy.status();}
    const StressHierarchy::Status* modeStatus()const{return mModes.status();}
};
#endif
