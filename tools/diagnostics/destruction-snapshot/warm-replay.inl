// Warming advances real physical time. Never rewind physical state under warm caches.
struct WarmTick {
    double commandMs, simulationMs, completionMs, tickMs;
    PxDestructionStageStatus status;
    PxDestructionTopologyStatus topology;
    PxDestructionStressTopologyStatus stressTopology;
};
void writeWarmTick(std::ostream& report,const WarmTick& t,unsigned repeat,unsigned offset,unsigned warmup){
    report<<"{\"repeat\":"<<repeat<<",\"tick_offset\":"<<offset
        <<",\"measured\":"<<(offset>=warmup?"true":"false")<<",\"frame\":"<<t.status.frame
        <<",\"complete_step_ms\":"<<t.tickMs<<",\"command_ms\":"<<t.commandMs
        <<",\"simulate_fetch_ms\":"<<t.simulationMs<<",\"completion_ms\":"<<t.completionMs
        <<",\"stress_iterations\":"<<t.status.iterations<<",\"broken_bonds\":"<<t.status.brokenBonds
        <<",\"correction_passes\":"<<t.status.correctionPasses<<",\"stress_passes\":"<<t.status.stressPasses
        <<",\"output_clusters\":"<<t.topology.clusterCount<<",\"stress_islands\":"<<t.stressTopology.islandCount
        <<",\"stress_active_nodes\":"<<t.stressTopology.activeNodeCount<<",\"stress_active_bonds\":"<<t.stressTopology.activeBondCount
        <<",\"normal_contacts\":"<<t.status.normalContacts<<",\"friction_anchors\":"<<t.status.frictionAnchors<<'}';
}
bool sameWarmWork(const WarmTick& a,const WarmTick& b){
    return a.status.frame==b.status.frame && a.status.brokenBonds==b.status.brokenBonds
        && a.status.correctionPasses==b.status.correctionPasses && a.status.stressPasses==b.status.stressPasses
        && a.topology.clusterCount==b.topology.clusterCount && a.stressTopology.islandCount==b.stressTopology.islandCount
        && a.stressTopology.activeNodeCount==b.stressTopology.activeNodeCount && a.stressTopology.activeBondCount==b.stressTopology.activeBondCount
        && a.status.normalContacts==b.status.normalContacts && a.status.frictionAnchors==b.status.frictionAnchors;
}
void replayWarmFiles(const std::string& prefix,const char* directory,unsigned repetitions,bool impulse,unsigned warmupTicks,unsigned measureTicks){
    require(warmupTicks<=10000 && measureTicks>=1 && measureTicks<=10000,"warmup 0..10000 and measured 1..10000 ticks required");
    require(repetitions>=2 && repetitions<=1000,"replay repetitions must be 2..1000");
    // PhysX streams use its allocator, so the foundation must outlive them.
    const auto harnessStart=std::chrono::steady_clock::now();
    Events environmentEvents;blast_demo::SceneCapacity capacity;bool contactReports=true;
    std::ifstream settings(prefix+".scene");
    if(settings){unsigned version=0;settings>>version>>capacity.maxBodies>>capacity.maxShapes>>capacity.maxContactPairs
        >>contactReports>>replayPreIslands>>replayPreContacts>>replayPreSupport>>replayConnectivity;
        require(bool(settings) && version==1 && capacity.maxBodies && capacity.maxShapes && capacity.maxContactPairs,"invalid fixture scene settings");}

    SnapshotPinnedPool pinnedPool;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&environmentEvents,false,false,false,false,PxSolverType::eTGS,false,contactReports,&pinnedPool);
    FinishSnapshotPool finishPool{pinnedPool,*context.cudaContextManager()};
    PxDefaultMemoryOutputStream bytes,destruction;
    auto read=[](const std::string& path,PxDefaultMemoryOutputStream& stream){
        std::ifstream file(path,std::ios::binary|std::ios::ate);require(bool(file),"snapshot file missing");
        const auto size=file.tellg();require(size>=0 && size<=1024LL*1024*1024,"snapshot file size invalid");
        std::vector<char> data(static_cast<size_t>(size));file.seekg(0);
        if(size){file.read(data.data(),size);require(bool(file),"snapshot file read failed");stream.write(data.data(),PxU32(size));}
    };
    read(prefix+".pxbin",bytes);read(prefix+".destruction",destruction);
    struct ObjectStorage {void* memory=nullptr;~ObjectStorage(){free(memory);}} objectStorage;
    require(posix_memalign(&objectStorage.memory,PX_SERIAL_FILE_ALIGN,bytes.getSize())==0,"reusable object storage failed");
    const auto setupEnd=std::chrono::steady_clock::now();
    const bool destructive=destruction.getSize()!=0;require(bytes.getSize(),"empty PhysX snapshot");
    auto* registry=PxSerialization::createSerializationRegistry(context.physics());require(registry,"replay registry");
    std::ofstream report(std::string(directory)+"/replay.json");report<<std::setprecision(17);
    report<<"{\"contract\":\"physical-warm-window-v1\",\"steps_per_restore\":"<<(warmupTicks+measureTicks)<<",\"repetitions\":"<<repetitions
        <<",\"warmup_ticks\":"<<warmupTicks<<",\"measure_ticks\":"<<measureTicks
        <<",\"warmup_advances_physics\":true,\"profile_tick_offset\":"<<warmupTicks
        <<",\"context_setup_ms\":"<<std::chrono::duration<double,std::milli>(setupEnd-harnessStart).count()
        <<",\"object_storage_reused\":true,\"pinned_storage_reused\":true,\"fresh_scene_per_restore\":true,\"import_validation_every_sample\":true"
        <<",\"projectile_impulse\":"<<(impulse?"true":"false")
        <<",\"impulse_tick_offset\":"<<(impulse?int(warmupTicks):-1)<<",\"trajectories\":[";
    std::vector<WarmTick> baselineTicks,measuredTicks;
    bool allRepeated=true;
    {
        std::vector<ObjectObservation> baselineObjects;DestructionObservation baselineDestruction;PxDestructionStageStatus baselineStatus{};
        for(unsigned i=0;i<repetitions;++i){
            World world;Events events;
            const auto begin=std::chrono::steady_clock::now();world.load(context.physics(),*registry,context.scene(),events,bytes,objectStorage.memory);
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
            const auto preValidationEnd=std::chrono::steady_clock::now();
            std::vector<WarmTick> ticks; ticks.reserve(warmupTicks+measureTicks);
            // No full observations or file output between these ticks.
            for(unsigned k=0;k<warmupTicks+measureTicks;++k){
            SnapshotProfileTick profileTick(*world.scene,i==0 && k==warmupTicks);
            const auto start=std::chrono::steady_clock::now();
            if(impulse && k==warmupTicks){auto* object=world.objects->find(102);auto* target=object?object->is<PxRigidDynamic>():nullptr;
                require(target,"replay projectile missing");target->setAngularVelocity(PxVec3(0,.25f,0));target->addForce(PxVec3(.1f,0,0),PxForceMode::eIMPULSE);}
            profileTick.stage("snapshot/simulate_fetch");
            const auto simulationStart=std::chrono::steady_clock::now();
            step(*world.scene);
            const auto simulationEnd=std::chrono::steady_clock::now();
            profileTick.stage("snapshot/completion");
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
            if(destructive)require(!status.error && status.converged && status.frame==frame+k+1
                    && status.correctionPasses<=1 && status.stressPasses==1+status.correctionPasses,"file replay quality/correction failed");
            const auto completeEnd=std::chrono::steady_clock::now();
            profileTick.finish();
            const double commandMs=std::chrono::duration<double,std::milli>(simulationStart-start).count();
            const double simulationMs=std::chrono::duration<double,std::milli>(simulationEnd-simulationStart).count();
            const double completionMs=std::chrono::duration<double,std::milli>(completeEnd-simulationEnd).count();
            const double tickMs=std::chrono::duration<double,std::milli>(completeEnd-start).count();
            ticks.push_back({commandMs,simulationMs,completionMs,tickMs,status,topology,stressTopology});
            }
            const auto windowEnd=std::chrono::steady_clock::now();
            const auto& status=ticks.back().status;
            if(destructive){const auto after=health(*world.scene);for(unsigned j=0;j<after.size();++j)
                    require(std::isfinite(after[j]) && after[j]>=0 && after[j]<=previous[j],"file replay healed damage");}
            auto observedObjects=observeObjects(*world.objects);
            auto observedDestruction=destructive?observeDestruction(*world.scene):DestructionObservation{};
            dumpReplayObservations(*world.scene,*world.objects,directory,i,destructive);
            MotionError error;bool repeatPassed=true,motionMeasured=!i;
            if(i)try{error=compareObservedObjects(baselineObjects,observedObjects);motionMeasured=true;
                if(destructive){compareObservedDestruction(baselineDestruction,observedDestruction);
                    require(status.brokenBonds==baselineStatus.brokenBonds && status.correctionPasses==baselineStatus.correctionPasses && status.stressPasses==baselineStatus.stressPasses,"repeated fracture/correction outcome differs");}
                for(unsigned k=0;k<ticks.size();++k)require(sameWarmWork(ticks[k],baselineTicks[k]),"repeated trajectory work differs");}
            catch(const std::exception& e){if(!motionMeasured)error.position=error.linear=error.angular=-1;repeatPassed=false;allRepeated=false;std::cerr<<"repeat "<<i<<" comparison failed: "<<e.what()<<std::endl;}
            if(!i){baselineTicks=ticks;baselineStatus=status;baselineObjects=std::move(observedObjects);baselineDestruction=std::move(observedDestruction);}
            const auto validationEnd=std::chrono::steady_clock::now();
            world.release();const auto teardownEnd=std::chrono::steady_clock::now();
            if(i)report<<',';
            report<<"{\"repeat\":"<<i<<",\"restore_ms\":"<<restoreMs
                <<",\"teardown_ms\":"<<std::chrono::duration<double,std::milli>(teardownEnd-validationEnd).count()
                <<",\"pinned_allocations\":"<<pinnedPool.allocations<<",\"pinned_reuses\":"<<pinnedPool.reuses<<",\"pinned_retained_peak_bytes\":"<<pinnedPool.retainedPeak
                <<",\"deserialize_ms\":"<<world.deserializeMs<<",\"scene_create_ms\":"<<world.sceneCreateMs<<",\"insert_ms\":"<<world.insertMs<<",\"destruction_import_ms\":"<<importMs
                <<",\"pre_tick_validation_ms\":"<<std::chrono::duration<double,std::milli>(preValidationEnd-restoreEnd).count()
                <<",\"post_tick_validation_ms\":"<<std::chrono::duration<double,std::milli>(validationEnd-windowEnd).count()
                <<",\"repeatability_passed\":"<<(repeatPassed?"true":"false")
                <<",\"motion_comparison_measured\":"<<(motionMeasured?"true":"false")
                <<",\"position_error_m\":"<<error.position<<",\"linear_error_m_s\":"<<error.linear<<",\"angular_error_rad_s\":"<<error.angular
                <<",\"ticks\":[";
            for(unsigned k=0;k<ticks.size();++k){if(k)report<<',';writeWarmTick(report,ticks[k],i,k,warmupTicks);
                if(k>=warmupTicks)measuredTicks.push_back(ticks[k]);}
            report<<"]}";report.flush();
        }
    }
    finishPool.finish();
    const bool gpuHealthy=context.healthy() && pinnedPool.healthy;
    report<<"],\"samples\":[";
    for(unsigned k=0;k<measuredTicks.size();++k){if(k)report<<',';writeWarmTick(report,measuredTicks[k],k/measureTicks,warmupTicks+k%measureTicks,warmupTicks);}
    report<<"],\"simulation_completed\":true,\"gpu_healthy\":"<<(gpuHealthy?"true":"false")<<",\"repeatability_passed\":"<<(allRepeated?"true":"false")<<",\"passed\":"<<((allRepeated&&gpuHealthy)?"true":"false")<<"}\n";report.close();registry->release();
    require(gpuHealthy,"PhysX error during file replay");require(allRepeated,"warm-window repeatability gate failed; all ticks retained");
    std::cout<<"completed "<<repetitions<<" independent warmed file trajectories"<<std::endl;
}
