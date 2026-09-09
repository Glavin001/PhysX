// Included after Fixture in native_gpu_collision_test.cpp's test namespace.
// The initial capacity retry is an ordered pre-initialization seam: the first
// GPU pass has prepared candidates but cannot allocate without storage. Corrupt
// its existing candidate before the retry, without a production fault switch.
void nativeInitializationFailure() {
    struct Fault final:PxProfilerCallback {
        PxCudaContextManager* cuda=nullptr;PxDestructionScene* stage=nullptr;
        std::atomic<bool> injected{false},failed{false};
        Fault(){require(!PxGetProfilerCallback(),"fault test profiler already occupied");PxSetProfilerCallback(this);}
        ~Fault()override{PxSetProfilerCallback(nullptr);}
        void* zoneStart(const char* name,bool,PxU64)override {
            if(stage && std::strcmp(name,"GpuDestruction.finishDetail.growMotionSlots")==0 && !injected.exchange(true)) {
                PxScopedCudaLock lock(*cuda);const auto view=stage->getDeviceView();
                PxDestructionClusterBodyState candidate;
                if(cuEventSynchronize(view.readyEvent)!=CUDA_SUCCESS
                    || cuMemcpyDtoH(&candidate,CUdeviceptr(view.trialBodies+1),sizeof(candidate))!=CUDA_SUCCESS)failed=true;
                else {
                    candidate.sourceBody=PX_INVALID_U32;
                    if(cuMemcpyHtoD(CUdeviceptr(view.trialBodies+1),&candidate,sizeof(candidate))!=CUDA_SUCCESS)failed=true;
                }
            }
            return nullptr;
        }
        void zoneEnd(void*,const char*,bool,PxU64)override{}
    } fault;
    Fixture f(4,0,false);f.desc.internalCorrectionLimit=1;f.configure();
    fault.cuda=&f.cuda;fault.stage=f.stage;
    f.scene.simulate(1.0f/60);PxU32 error=0;
    require(!f.scene.fetchResults(true,&error) && error && fault.injected && !fault.failed,
        "native initialization failure was not exercised/rejected");
    require(f.stage->getLastStatus().error==(8u|4u|256u|512u),"mandatory completion lost initialization failure");
    f.assertUncommitted();
    const auto view=f.stage->getDeviceView();
    PxDestructionBodyAllocationStatus allocation;
    PxDestructionCollisionPreparationStatus collision;
    PxDestructionCorrectionPreparationStatus correction;
    PxDestructionTopologyStatus accepted;
    {PxScopedCudaLock lock(f.cuda);check(cuEventSynchronize(view.readyEvent));
        check(cuMemcpyDtoH(&allocation,CUdeviceptr(view.bodyAllocation),sizeof(allocation)));
        check(cuMemcpyDtoH(&collision,CUdeviceptr(view.collisionPreparation),sizeof(collision)));
        check(cuMemcpyDtoH(&correction,CUdeviceptr(view.correctionPreparation),sizeof(correction)));
        check(cuMemcpyDtoH(&accepted,CUdeviceptr(view.acceptedTopology.status),sizeof(accepted)));}
    require(allocation.initializationError==1 && !allocation.initialized,"rejected candidate initialized native bodies");
    require(!collision.valid && !collision.error && !collision.count && !collision.migrating,
        "rejected initialization reached collision ownership");
    require(!correction.valid && !correction.error && !correction.count,
        "rejected initialization reached corrected motion");
    require(!static_cast<NpScene&>(f.scene).getNbDestructionBodyCandidates(),
        "invalid native initialization constructed CPU compatibility bodies");
    require(!accepted.generation && accepted.clusterCount==1,"failed initialization committed topology");
    std::puts("native initialization failure: GPU prerequisite rejects before ownership, motion correction and publication passed");
}
