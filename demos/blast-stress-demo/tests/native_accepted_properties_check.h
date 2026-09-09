// The corrected GPU interaction must not need fitted mass/COM/motion on CPU.
// Inspect real producer state, then require current-tick ordinary actor values.
void acceptedPropertiesOnly(PxSolverType::Enum solver=PxSolverType::eTGS) {
    struct Observe final:PxProfilerCallback {
        Fixture* fixture=nullptr;
        bool inspected=false,failed=false;
        std::string error;
        Observe(){require(!PxGetProfilerCallback(),"property profiler occupied");PxSetProfilerCallback(this);}
        ~Observe()override{PxSetProfilerCallback(nullptr);}
        void* zoneStart(const char*,bool,PxU64)override{return nullptr;}
        void zoneEnd(void*,const char* name,bool,PxU64)override {
            if(!fixture || inspected || std::strcmp(name,"GpuDestruction.restoreInstall"))return;
            try {
                const auto view=fixture->stage->getDeviceView();
                PxScopedCudaLock lock(fixture->cuda);check(cuEventSynchronize(view.readyEvent));
                PxgBodySim device;
                check(cuMemcpyDtoH(&device,CUdeviceptr(fixture->core.getBodySimBufferDevicePtr().getPointer()
                    +fixture->parent->getGPUIndex()),sizeof(device)));
                const auto& cpu=static_cast<NpRigidDynamic*>(fixture->parent)->getCore().getCore();
                require(cpu.getBody2Actor().p.magnitudeSquared()<1e-10f,
                    "fitted COM reached CPU before corrected physics completed");
                require(device.body2Actor_maxImpulseW.getTransform().p.magnitudeSquared()>1,
                    "GPU corrected COM was not installed independently");
                inspected=true;
            }catch(const std::exception& e){failed=true;error=e.what();}
        }
    } observe;
    Fixture f(4,2,true,solver,false,true);
    require(!(f.scene.getFlags() & (PxSceneFlag::eENABLE_DIRECT_GPU_API|PxSceneFlag::eDISABLE_SLEEPING)),"property test requires ordinary APIs and sleeping");f.desc.internalCorrectionLimit=1;
    for(unsigned i=1;i<4;++i){f.mass[i].mass=2;f.chunks[i].mass=2;}
    f.bonds[1].area=f.bonds[1].health=f.bonds[2].area=f.bonds[2].health=100;
    f.parent->setSolverIterationCounts(7,3);f.parent->setLinearDamping(.17f);f.parent->setAngularDamping(.23f);
    f.configure();observe.fixture=&f;
    try {step(f.scene);}catch(...) {
        const auto status=f.stage->getLastStatus();
        std::fprintf(stderr,"accepted-property fixture: error=%u correction=%u stress=%u observation=%s\n",
            status.error,status.correctionPasses,status.stressPasses,observe.error.c_str());throw;
    }
    observe.fixture=nullptr;
    if(observe.failed)throw std::runtime_error(observe.error);
    require(observe.inspected,"no corrected GPU installation observed");
    const auto status=f.stage->getLastStatus();
    require(status.correctionPasses==1 && status.stressPasses==2 && status.brokenBonds==1,
        "property fixture lost correction or changed fracture");
    auto* detached=static_cast<PxRigidDynamic*>(f.shapes[1]->getActor());
    require(detached && detached!=f.parent,"expected chunk did not detach");
    require(PxAbs(detached->getMass()-2)<1e-5f,"accepted fragment mass is stale");
    PxU32 position=0,velocity=0;detached->getSolverIterationCounts(position,velocity);
    require(position==7 && velocity==3 && PxAbs(detached->getLinearDamping()-.17f)<1e-6f,
        "scheduler settings were lost while delaying physical observations");
    for(auto* actor:{f.parent,detached}) {
        PxgBodySim device;
        {PxScopedCudaLock lock(f.cuda);check(cuMemcpyDtoH(&device,CUdeviceptr(f.core.getBodySimBufferDevicePtr().getPointer()+actor->getGPUIndex()),sizeof(device)));}
        const auto& cpu=static_cast<NpRigidDynamic*>(actor)->getCore().getCore();
        require((cpu.getBody2Actor().p-device.body2Actor_maxImpulseW.getTransform().p).magnitude()<1e-5f,
            "accepted CPU mass frame disagrees with GPU");
        require((cpu.body2World.p-device.body2World.getTransform().p).magnitude()<1e-5f,
            "CPU published provisional rather than accepted pose");
        require((cpu.linearVelocity-PxVec3(device.linearVelocityXYZ_inverseMassW.x,device.linearVelocityXYZ_inverseMassW.y,
            device.linearVelocityXYZ_inverseMassW.z)).magnitude()<1e-5f,"accepted CPU velocity is stale");
    }
    step(f.scene);require(f.context.healthy(),"next ordinary tick failed after accepted property publication");
    std::puts("6 chunks / 3 bonds plus one ordinary body: GPU correction before CPU mass/COM/motion; accepted properties and inherited settings passed");
}
