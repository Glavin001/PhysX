// Native ownership bridge: immutable/operator data are borrowed, never copied.
#ifdef PHYSX_RESIDENT_DESTRUCTION
#include "StressNativeSettled.cuh"
struct NativeStressCycleView {
    NativeSettledCache settled{};
    StressHierarchy::CycleDeviceView cycle{};
    StressHierarchy::MotionModeView modes{};
    StressHierarchy::Vector *rhs=nullptr,*result=nullptr,*solution=nullptr;
    AngLin *g=nullptr;
    float *gamma=nullptr,*previous=nullptr;
    double* normalizer=nullptr;
    // Fine rigid block: six Schur-inverse coefficients, three coupling entries, reciprocal linear diagonal.
    double* fineInverse=nullptr;unsigned inverseStride=0;
    float* mixedInverse=nullptr;unsigned* mixedEligible=nullptr;
    unsigned* inverseValid=nullptr;std::uint64_t* inverseGeneration=nullptr;
    unsigned* failed=nullptr;
    unsigned* operatorOther=nullptr; // Current per-row neighbor, Invalid for a prescribed endpoint.
    unsigned *verification=nullptr,*verificationCount=nullptr,*warmRangeKnown=nullptr;
    std::uint64_t* warmRangeGeneration=nullptr;
    const ExtStressGpuDeviceTopologyStatus* topology=nullptr;
    NativeDirectView direct{};
};
__global__ void publishNativeHierarchyStatus(const StressHierarchy::Status* hierarchy,const StressHierarchy::Status* modes,ExtStressGpuDeviceTopologyStatus* topology){
    if(!hierarchy->initialized || hierarchy->error || hierarchy->generation!=topology->generation || !modes->initialized || modes->error || modes->generation!=topology->generation)topology->error|=8u;
}
class NativeStressHierarchy {
    StressHierarchy::ResidentHierarchy mHierarchy;
    StressHierarchy::ResidentMotionModes mModes;
    std::unique_ptr<StressHierarchy::ResidentCycle> mCycle;
    NativeStressCycleView mView;cudaStream_t mStream;
    static StressHierarchy::Input coarseWorkInput(StressHierarchy::Input input){input.componentSolverMaxNodes=kResidentComponentMaxNodes;return input;}
    template<class T>static void allocate(T*& p,size_t count){checkCuda(cudaMalloc(&p,std::max(size_t(1),size_t(count))*sizeof(T)),"allocate native hierarchy workspace");}
    void release()noexcept{cudaFree(mView.settled.inputs);cudaFree(mView.settled.certificates);cudaFree(mView.settled.verifiedStoredOutput);cudaFree(mView.fineInverse);cudaFree(mView.mixedInverse);cudaFree(mView.mixedEligible);cudaFree(mView.inverseValid);cudaFree(mView.inverseGeneration);cudaFree(mView.rhs);cudaFree(mView.solution);cudaFree(mView.result);cudaFree(mView.g);cudaFree(mView.gamma);cudaFree(mView.previous);cudaFree(mView.failed);cudaFree(mView.operatorOther);cudaFree(mView.normalizer);cudaFree(mView.verification);cudaFree(mView.verificationCount);cudaFree(mView.warmRangeKnown);cudaFree(mView.warmRangeGeneration);}
public:
    NativeStressHierarchy(StressHierarchy::Input input,const unsigned* forest,const ExtStressGpuDeviceTopologyStatus* status,cudaStream_t stream)
        :mHierarchy(coarseWorkInput(input),input.nodes>257?16:7,stream),mModes(input,forest,stream),mStream(stream){
        mView.topology=status;mView.modes=mModes.view();mView.inverseStride=input.nodes;
        try{
            allocate(mView.settled.inputs,input.nodes);allocate(mView.settled.certificates,input.nodes);
            allocate(mView.settled.verifiedStoredOutput,input.nodes);
            checkCuda(cudaMemsetAsync(mView.settled.certificates,0,sizeof(NativeSettledCertificate)*input.nodes,stream),"invalidate native settled certificates");
            allocate(mView.fineInverse,size_t(input.nodes)*10);allocate(mView.mixedInverse,size_t(input.nodes)*10);allocate(mView.mixedEligible,input.nodes);allocate(mView.operatorOther,size_t(input.bonds)*2);
            allocate(mView.inverseValid,input.nodes);allocate(mView.inverseGeneration,input.nodes);
            checkCuda(cudaMemsetAsync(mView.inverseValid,0,sizeof(unsigned)*input.nodes,stream),"invalidate native local inverse cache");
            mHierarchy.setFineDiagonalReuse(mView.inverseValid,mView.inverseGeneration);
            allocate(mView.rhs,input.nodes);allocate(mView.solution,input.nodes);allocate(mView.result,input.nodes);allocate(mView.g,input.nodes);
            allocate(mView.gamma,input.nodes);allocate(mView.previous,input.nodes);allocate(mView.failed,input.nodes);allocate(mView.normalizer,input.nodes);allocate(mView.verification,input.nodes);allocate(mView.verificationCount,1);allocate(mView.warmRangeKnown,1);allocate(mView.warmRangeGeneration,1);
            checkCuda(cudaMemsetAsync(mView.warmRangeKnown,0,sizeof(unsigned),stream),"initialize native warm-range proof");
            checkCuda(cudaMemsetAsync(mView.warmRangeGeneration,0,sizeof(std::uint64_t),stream),"initialize native warm-range generation");
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
    void setDirect(const NativeDirectView& direct){mView.direct=direct;}
    const StressHierarchy::Status* status()const{return mHierarchy.status();}
    const StressHierarchy::Status* modeStatus()const{return mModes.status();}
};
#endif
