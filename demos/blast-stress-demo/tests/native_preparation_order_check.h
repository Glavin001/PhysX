// Included after Fixture. Observe actual production CUDA output at the boundary
// before compatibility construction; no replacement allocator or test kernel.
void preparationBeforeCompatibility() {
    struct Observe final:PxProfilerCallback {
        Fixture* fixture=nullptr;
        std::atomic<bool> observed{false},failed{false},constructed{false};
        Observe(){require(!PxGetProfilerCallback(),"ordering profiler already occupied");PxSetProfilerCallback(this);}
        ~Observe()override{PxSetProfilerCallback(nullptr);}
        void* zoneStart(const char* name,bool,PxU64)override {
            if(fixture && !std::strcmp(name,"GpuDestruction.compatibility.allocateNativeBodies")) {
                if(!observed || failed)failed=true;
                constructed=true;
            }
            return nullptr;
        }
        void zoneEnd(void*,const char* name,bool,PxU64)override {
            if(!fixture || std::strcmp(name,"GpuDestruction.correctionBodies") || observed)return;
            try {
                const auto view=fixture->stage->getDeviceView();
                PxDestructionBodyAllocationStatus allocation;
                PxDestructionCollisionPreparationStatus collision;
                PxDestructionCorrectionPreparationStatus correction;
                PxScopedCudaLock lock(fixture->cuda);check(cuEventSynchronize(view.readyEvent));
                check(cuMemcpyDtoH(&allocation,CUdeviceptr(view.bodyAllocation),sizeof(allocation)));
                check(cuMemcpyDtoH(&collision,CUdeviceptr(view.collisionPreparation),sizeof(collision)));
                check(cuMemcpyDtoH(&correction,CUdeviceptr(view.correctionPreparation),sizeof(correction)));
                require(allocation.valid && allocation.reserved==3 && allocation.initialized==3,
                    "native motion was not initialized before compatibility");
                require(collision.valid && collision.migrating==3 && correction.valid && correction.count==4,
                    "GPU collision/correction preparation is not complete before compatibility");
                require(!static_cast<NpScene&>(fixture->scene).getNbDestructionBodyCandidates(),
                    "CPU fragment objects still precede GPU preparation");
                require(fixture->parent->getNbShapes()==4 && !constructed,
                    "ownership or compatibility mutated before GPU preparation");
                observed=true;
            }catch(...){failed=true;}
        }
    } observe;
    Fixture f(4,2,false,PxSolverType::eTGS,true);f.desc.internalCorrectionLimit=1;f.configure();observe.fixture=&f;
    step(f.scene);
    require(observe.observed && observe.constructed && !observe.failed,"GPU preparation/CPU compatibility ordering failed");
    const auto status=f.stage->getLastStatus();
    require(status.brokenBonds==3 && status.correctionPasses==1 && status.stressPasses==2,
        "ordering fixture lost fracture or corrected stress evaluation");
    require(f.context.healthy(),"ordering fixture became unhealthy");
    std::puts("6 chunks / 3 bonds plus one ordinary body: initialized motion and complete GPU preparation precede CPU fragment construction; one correction/two stress evaluations passed");
}
