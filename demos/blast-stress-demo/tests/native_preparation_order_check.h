// Observe actual production CUDA output before the host completion boundary.
// Two load levels exercise capacity growth, then an allocation without growth.
void preparationBeforeCompatibility() {
    struct Observe final:PxProfilerCallback {
        Fixture* fixture=nullptr;
        std::atomic<bool> observed{false},failed{false},constructed{false};
        unsigned expectedNew=1,expectedOwners=2,expectedShapes=4,growths=0;
        bool normalBoundary=false;
        std::string error;
        Observe(){require(!PxGetProfilerCallback(),"ordering profiler already occupied");PxSetProfilerCallback(this);}
        ~Observe()override{PxSetProfilerCallback(nullptr);}
        void inspect(bool normal) {
            if(!fixture || observed)return;
            try {
                const auto view=fixture->stage->getDeviceView();
                PxDestructionBodyAllocationStatus allocation;
                PxDestructionCollisionPreparationStatus collision;
                PxDestructionCorrectionPreparationStatus correction;
                PxScopedCudaLock lock(fixture->cuda);check(cuEventSynchronize(view.readyEvent));
                check(cuMemcpyDtoH(&allocation,CUdeviceptr(view.bodyAllocation),sizeof(allocation)));
                if(!allocation.valid && normal)return; // first capacity shortage, or no fracture
                check(cuMemcpyDtoH(&collision,CUdeviceptr(view.collisionPreparation),sizeof(collision)));
                check(cuMemcpyDtoH(&correction,CUdeviceptr(view.correctionPreparation),sizeof(correction)));
                if(!(allocation.valid && allocation.reserved==expectedNew && allocation.initialized==expectedNew))
                    throw std::runtime_error("motion allocation: valid="+std::to_string(allocation.valid)
                        +" reserved="+std::to_string(allocation.reserved)+" initialized="+std::to_string(allocation.initialized)
                        +" expected="+std::to_string(expectedNew)+" error="+std::to_string(allocation.error));
                require(collision.valid && collision.migrating==expectedNew && correction.valid && correction.count==expectedOwners,
                    "complete GPU preparation still depends on a host wait/resubmission");
                require(!static_cast<NpScene&>(fixture->scene).getNbDestructionBodyCandidates(),
                    "CPU fragment objects still precede GPU preparation");
                require(fixture->parent->getNbShapes()==expectedShapes && !constructed,
                    "ownership or compatibility mutated before GPU preparation");
                normalBoundary=normal;observed=true;
            }catch(const std::exception& e){error=e.what();failed=true;}
        }
        void* zoneStart(const char* name,bool,PxU64)override {
            if(!std::strcmp(name,"GpuDestruction.finishAndReserve"))inspect(true);
            if(fixture && !std::strcmp(name,"GpuDestruction.compatibility.allocateNativeBodies")) {
                if(!observed || failed)failed=true;
                try {
                    CUcontext current=nullptr;check(cuCtxGetCurrent(&current));
                    require(current==fixture->cuda.getContext(),
                        "compatibility CUDA observations lost the scene context");
                    require(!static_cast<NpScene&>(fixture->scene).getNbDestructionBodyCandidates(),
                        "GPU ownership requires prior CPU fragment construction");
                    const auto bindings=fixture->bindings(expectedShapes);
                    PxScopedCudaLock lock(fixture->cuda);unsigned migrated=0;
                    for(const auto& binding:bindings) {
                        PxgShapeSim shape;
                        check(cuMemcpyDtoH(&shape,CUdeviceptr(fixture->core.mPxgShapeSimManager.getShapeSimsDeviceTypedPtr()
                            +binding.shape),sizeof(shape)));
                        require(shape.mBodySimIndex.index()==binding.targetBody,
                            "GPU ownership not installed before CPU compatibility");
                        require(fixture->shapes[binding.chunk]->getActor()->is<PxRigidDynamic>()->getGPUIndex()==binding.sourceBody,
                            "CPU ownership changed before compatibility construction");
                        migrated+=binding.sourceBody!=binding.targetBody;
                    }
                    require(migrated==expectedNew,"wrong number of installed native owners");
                }catch(const std::exception& e){error=e.what();failed=true;}
                constructed=true;
            }
            return nullptr;
        }
        void zoneEnd(void*,const char* name,bool,PxU64)override {
            if(fixture && !std::strcmp(name,"GpuDestruction.finishDetail.growMotionSlots")){++growths;inspect(false);}
        }
    } observe;
    Fixture f(4,2,false,PxSolverType::eTGS,true);f.desc.internalCorrectionLimit=1;
    f.bonds[1].area=f.bonds[1].health=f.bonds[2].area=f.bonds[2].health=100;f.configure();observe.fixture=&f;
    step(f.scene);
    if(observe.failed)throw std::runtime_error("GPU preparation/CPU compatibility ordering failed: "+observe.error);
    require(observe.observed && observe.constructed && observe.growths==1,"initial growth ordering was not exercised");
    auto status=f.stage->getLastStatus();
    require(status.brokenBonds==1 && status.correctionPasses==1 && status.stressPasses==2,
        "first load did not leave two intact bonds for the resident retry-free path");
    observe.observed=false;observe.constructed=false;observe.normalBoundary=false;
    observe.expectedNew=2;observe.expectedOwners=3;observe.expectedShapes=3;
    f.scene.setGravity(PxVec3(0,-100000,0));step(f.scene);
    if(observe.failed)throw std::runtime_error("GPU preparation/CPU compatibility ordering failed: "+observe.error);
    require(observe.observed && observe.constructed && observe.normalBoundary && observe.growths==1,
        "normal GPU preparation still needs allocation growth or host resubmission");
    status=f.stage->getLastStatus();
    require(status.brokenBonds==2 && status.correctionPasses==1 && status.stressPasses==2,
        "second load lost fracture or corrected stress evaluation");
    require(f.context.healthy(),"ordering fixture became unhealthy");
    std::puts("6 chunks / 3 bonds plus one ordinary body: growth then no-growth fracture; complete GPU preparation before CPU completion/construction; one correction/two stress evaluations per step passed");
}
