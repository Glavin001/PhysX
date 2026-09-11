// Replay probe-generated physical snapshots in a new process. The fixture scene
// configuration is fixed by PhysXScene; each sample reconstructs and runs ONE tick.
void replayFiles(const std::string& prefix,const char* directory,unsigned repetitions,bool impulse){
    require(repetitions>=2 && repetitions<=1000,"replay repetitions must be 2..1000");
    // PhysX streams use its allocator, so the foundation must outlive them.
    const auto harnessStart=std::chrono::steady_clock::now();
    Events environmentEvents;blast_demo::SceneCapacity capacity;bool contactReports=true;
    std::ifstream settings(prefix+".scene");
    if(settings){unsigned version=0;settings>>version>>capacity.maxBodies>>capacity.maxShapes>>capacity.maxContactPairs
        >>contactReports>>replayPreIslands>>replayPreContacts>>replayPreSupport>>replayConnectivity;
        require(bool(settings) && version==1 && capacity.maxBodies && capacity.maxShapes && capacity.maxContactPairs,"invalid fixture scene settings");}

    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&environmentEvents,false,false,false,false,PxSolverType::eTGS,false,contactReports);
    PxDefaultMemoryOutputStream bytes,destruction;
    auto read=[](const std::string& path,PxDefaultMemoryOutputStream& stream){
        std::ifstream file(path,std::ios::binary|std::ios::ate);require(bool(file),"snapshot file missing");
        const auto size=file.tellg();require(size>=0 && size<=1024LL*1024*1024,"snapshot file size invalid");
        std::vector<char> data(static_cast<size_t>(size));file.seekg(0);
        if(size){file.read(data.data(),size);require(bool(file),"snapshot file read failed");stream.write(data.data(),PxU32(size));}
    };
    read(prefix+".pxbin",bytes);read(prefix+".destruction",destruction);
    const auto setupEnd=std::chrono::steady_clock::now();
    const bool destructive=destruction.getSize()!=0;require(bytes.getSize(),"empty PhysX snapshot");
    auto* registry=PxSerialization::createSerializationRegistry(context.physics());require(registry,"replay registry");
    std::ofstream report(std::string(directory)+"/replay.json");report<<std::setprecision(17);
    report<<"{\"contract\":\"physical-file-replay-v20-complete-step\",\"steps_per_restore\":1,\"repetitions\":"<<repetitions
        <<",\"projectile_impulse\":"<<(impulse?"true":"false")<<",\"samples\":[";
    bool allRepeated=true;
    {
        std::vector<ObjectObservation> baselineObjects;DestructionObservation baselineDestruction;PxDestructionStageStatus baselineStatus{};
        World world;Events events;
        for(unsigned i=0;i<repetitions;++i){
            const auto begin=std::chrono::steady_clock::now();if(!i){world.load(context.physics(),*registry,context.scene(),events,bytes);world.prepareReuse();}
            else {world.resetObjects();world.deserializeMs=world.sceneCreateMs=world.insertMs=0;}
            const auto importStart=std::chrono::steady_clock::now();
            if(destructive){PxDefaultMemoryInputData input(destruction.getData(),destruction.getSize());
                require(world.scene->getDestructionScene()->importState(input,*world.objects),"file destruction import failed");}
            const auto restoreEnd=std::chrono::steady_clock::now();
            const double importMs=std::chrono::duration<double,std::milli>(restoreEnd-importStart).count();
            const double restoreMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-begin).count();
            const auto previous=destructive?health(*world.scene):std::vector<float>();
            const auto frame=world.scene->getDestructionScene()->getLastStatus().frame;
            if(destructive){PxDefaultMemoryOutputStream again;
                require(world.scene->getDestructionScene()->exportState(again,*world.objects),"file restore re-export failed");
                require(again.getSize()==destruction.getSize() && !std::memcmp(again.getData(),destruction.getData(),again.getSize()),"file physical state changed during import");}
            // Input submission belongs to the full application tick measurement.
            const auto start=std::chrono::steady_clock::now();
            if(impulse){auto* object=world.objects->find(102);auto* target=object?object->is<PxRigidDynamic>():nullptr;
                require(target,"replay projectile missing");target->setAngularVelocity(PxVec3(0,.25f,0));target->addForce(PxVec3(.1f,0,0),PxForceMode::eIMPULSE);}
            const auto simulationStart=std::chrono::steady_clock::now();
            step(*world.scene);
            const auto simulationEnd=std::chrono::steady_clock::now();
            auto status=world.scene->getDestructionScene()->getLastStatus();
            PxDestructionTopologyStatus topology{};PxDestructionStressTopologyStatus stressTopology{};
            if(destructive){const auto view=world.scene->getDestructionScene()->getDeviceView();
                require(cuCtxPushCurrent(world.scene->getCudaContextManager()->getContext())==CUDA_SUCCESS,"replay stats context");
                require(cuEventSynchronize(view.readyEvent)==CUDA_SUCCESS,"replay stats ready");
                require(cuMemcpyDtoH(&topology,CUdeviceptr(view.acceptedTopology.status),sizeof(topology))==CUDA_SUCCESS,"replay topology stats");
                require(cuMemcpyDtoH(&stressTopology,CUdeviceptr(view.stressTopology),sizeof(stressTopology))==CUDA_SUCCESS,"replay stress stats");
                CUcontext prior;require(cuCtxPopCurrent(&prior)==CUDA_SUCCESS,"replay stats context pop");}
            // Match the native application's mandatory completion boundary.
            require(!topology.slotError,"incomplete GPU cluster slot allocation");
            if(destructive)require(!status.error && status.converged && status.frame==frame+1
                    && status.correctionPasses<=1 && status.stressPasses==1+status.correctionPasses,"file replay quality/correction failed");
            const auto completeEnd=std::chrono::steady_clock::now();
            const double commandMs=std::chrono::duration<double,std::milli>(simulationStart-start).count();
            const double simulationMs=std::chrono::duration<double,std::milli>(simulationEnd-simulationStart).count();
            const double completionMs=std::chrono::duration<double,std::milli>(completeEnd-simulationEnd).count();
            const double tickMs=std::chrono::duration<double,std::milli>(completeEnd-start).count();
            if(destructive){const auto after=health(*world.scene);for(unsigned j=0;j<after.size();++j)
                    require(std::isfinite(after[j]) && after[j]>=0 && after[j]<=previous[j],"file replay healed damage");}
            auto observedObjects=observeObjects(*world.objects);
            auto observedDestruction=destructive?observeDestruction(*world.scene):DestructionObservation{};
            dumpReplayObservations(*world.scene,*world.objects,directory,i,destructive);
            MotionError error;bool repeatPassed=true,motionMeasured=!i;
            if(i)try{error=compareObservedObjects(baselineObjects,observedObjects);motionMeasured=true;
                if(destructive){compareObservedDestruction(baselineDestruction,observedDestruction);
                    require(status.brokenBonds==baselineStatus.brokenBonds && status.correctionPasses==baselineStatus.correctionPasses && status.stressPasses==baselineStatus.stressPasses,"repeated fracture/correction outcome differs");}}
            catch(const std::exception& e){if(!motionMeasured)error.position=error.linear=error.angular=-1;repeatPassed=false;allRepeated=false;std::cerr<<"repeat "<<i<<" comparison failed: "<<e.what()<<std::endl;}
            if(!i){baselineStatus=status;baselineObjects=std::move(observedObjects);baselineDestruction=std::move(observedDestruction);}
            const auto validationEnd=std::chrono::steady_clock::now();
            if(i)report<<',';
            report<<"{\"repeat\":"<<i<<",\"restore_ms\":"<<restoreMs<<",\"complete_step_ms\":"<<tickMs
                <<",\"deserialize_ms\":"<<world.deserializeMs<<",\"scene_create_ms\":"<<world.sceneCreateMs<<",\"insert_ms\":"<<world.insertMs<<",\"destruction_import_ms\":"<<importMs
                <<",\"pre_tick_validation_ms\":"<<std::chrono::duration<double,std::milli>(start-restoreEnd).count()
                <<",\"post_tick_validation_ms\":"<<std::chrono::duration<double,std::milli>(validationEnd-completeEnd).count()
                <<",\"command_ms\":"<<commandMs<<",\"simulate_fetch_ms\":"<<simulationMs<<",\"completion_ms\":"<<completionMs
                <<",\"stress_iterations\":"<<status.iterations<<",\"broken_bonds\":"<<status.brokenBonds
                <<",\"correction_passes\":"<<status.correctionPasses<<",\"stress_passes\":"<<status.stressPasses
                <<",\"output_clusters\":"<<topology.clusterCount<<",\"stress_islands\":"<<stressTopology.islandCount
                <<",\"stress_active_nodes\":"<<stressTopology.activeNodeCount<<",\"stress_active_bonds\":"<<stressTopology.activeBondCount
                <<",\"normal_contacts\":"<<status.normalContacts<<",\"friction_anchors\":"<<status.frictionAnchors
                <<",\"repeatability_passed\":"<<(repeatPassed?"true":"false")
                <<",\"motion_comparison_measured\":"<<(motionMeasured?"true":"false")
                <<",\"position_error_m\":"<<error.position<<",\"linear_error_m_s\":"<<error.linear<<",\"angular_error_rad_s\":"<<error.angular<<'}';report.flush();
        }
    }
    const bool gpuHealthy=context.healthy();
    report<<"],\"simulation_completed\":true,\"gpu_healthy\":"<<(gpuHealthy?"true":"false")<<",\"repeatability_passed\":"<<(allRepeated?"true":"false")<<",\"passed\":"<<((allRepeated&&gpuHealthy)?"true":"false")<<"}\n";report.close();registry->release();
    require(gpuHealthy,"PhysX error during file replay");require(allRepeated,"one-tick repeatability gate failed; all samples retained");
    std::cout<<"completed "<<repetitions<<" independent one-tick file restores"<<std::endl;
}
