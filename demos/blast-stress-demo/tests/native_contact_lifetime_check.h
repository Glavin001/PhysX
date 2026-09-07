// Included after Fixture in native_gpu_collision_test.cpp's test namespace.
// Deliberate fault injection is diagnostic only; it never runs in production.
void contactLifetimeExhaustion() {
    {
        Fixture f(1,0,false);f.desc.internalCorrectionLimit=1;f.configure();
        auto& np=*static_cast<PxgNphaseImplementationContext*>(static_cast<NpScene&>(f.scene).getScScene().getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
        const PxgContactGraphSequence exhausted={~PxU64(0),0,0};
        {PxScopedCudaLock lock(f.cuda);check(cuMemcpyHtoD(np.mContactGraphSequence.getDevicePtr(),&exhausted,sizeof(exhausted)));check(cuCtxSynchronize());}
        auto* projectile=f.context.physics().createRigidDynamic(PxTransform(PxVec3(10,20,-5)));
        auto* shape=f.context.physics().createShape(PxSphereGeometry(.5f),f.context.material(),true);
        require(projectile && shape && projectile->attachShape(*shape),"exhaustion projectile setup failed");shape->release();f.scene.addActor(*projectile);
        f.scene.simulate(1.0f/60);PxU32 error=0;
        require(!f.scene.fetchResults(true,&error) && error,"exhausted contact allocation accepted a scene step");
        require(f.stage->getLastStatus().error&8192u,"contact lifetime exhaustion missing from mandatory status");
        PxgContactGraphSequence observed;
        {PxScopedCudaLock lock(f.cuda);check(cuMemcpyDtoH(&observed,np.mContactGraphSequence.getDevicePtr(),sizeof(observed)));}
        require(observed.next==~PxU64(0) && observed.error,"production pair allocator wrapped its lifetime counter");
        projectile->release();
    }
    {
        // PhysX caches the profiler when constructing the scene. Install first;
        // arm only after the fixture has provided its CUDA context and sequence.
        struct Fault final:PxProfilerCallback {
            PxCudaContextManager* cuda=nullptr;CUdeviceptr sequence=0;std::atomic<bool> injected{false},failed{false};
            Fault(){require(!PxGetProfilerCallback(),"fault test profiler already occupied");PxSetProfilerCallback(this);}
            ~Fault()override{PxSetProfilerCallback(nullptr);}
            void* zoneStart(const char* name,bool,PxU64)override {
                if(sequence && std::strcmp(name,"GpuDestruction.correctedCollisionSolve")==0 && !injected.exchange(true)) {
                    PxScopedCudaLock lock(*cuda);const PxgContactGraphSequence exhausted={~PxU64(0),1,0};
                    failed=cuMemcpyHtoD(sequence,&exhausted,sizeof(exhausted))!=CUDA_SUCCESS;
                    if(cuCtxSynchronize()!=CUDA_SUCCESS)failed=true;
                }
                return nullptr;
            }
            void zoneEnd(void*,const char*,bool,PxU64)override{}
        } fault;
        Fixture f(4,0,false);f.desc.internalCorrectionLimit=1;f.configure();
        auto& np=*static_cast<PxgNphaseImplementationContext*>(static_cast<NpScene&>(f.scene).getScScene().getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
        fault.cuda=&f.cuda;fault.sequence=np.mContactGraphSequence.getDevicePtr();
        f.scene.simulate(1.0f/60);PxU32 error=0;
        require(!f.scene.fetchResults(true,&error) && error && fault.injected && !fault.failed,
            "correction lifetime-failure injection was not exercised");
        require(f.stage->getLastStatus().error&8192u,"corrected step ignored fatal GPU lifecycle state");
        const auto view=f.stage->getDeviceView();PxDestructionTopologyStatus accepted;
        std::vector<float> health(f.bonds.size());
        {PxScopedCudaLock lock(f.cuda);check(cuEventSynchronize(view.readyEvent));
            check(cuMemcpyDtoH(&accepted,CUdeviceptr(view.acceptedTopology.status),sizeof(accepted)));
            check(cuMemcpyDtoH(health.data(),CUdeviceptr(view.bondHealth),health.size()*sizeof(float)));}
        require(!accepted.generation && accepted.clusterCount==1,"failed correction committed fracture topology");
        for(float h:health)require(h==1,"failed correction committed material damage");
    }
    std::puts("native contact lifetime exhaustion: trial and correction fail without committing topology/damage passed");
}
