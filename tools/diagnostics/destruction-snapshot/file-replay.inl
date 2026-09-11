// Replay probe-generated physical snapshots in a new process. The fixture scene
// configuration is fixed by PhysXScene; each sample reconstructs and runs ONE tick.
void replayFiles(const std::string& prefix,const char* directory,unsigned repetitions,bool impulse){
    require(repetitions>=2 && repetitions<=1000,"replay repetitions must be 2..1000");
    // PhysX streams use its allocator, so the foundation must outlive them.
    Events environmentEvents;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&environmentEvents,false,false,false,false,PxSolverType::eTGS,false,true);
    PxDefaultMemoryOutputStream bytes,destruction;
    auto read=[](const std::string& path,PxDefaultMemoryOutputStream& stream){
        std::ifstream file(path,std::ios::binary|std::ios::ate);require(bool(file),"snapshot file missing");
        const auto size=file.tellg();require(size>=0 && size<=1024LL*1024*1024,"snapshot file size invalid");
        std::vector<char> data(static_cast<size_t>(size));file.seekg(0);
        if(size){file.read(data.data(),size);require(bool(file),"snapshot file read failed");stream.write(data.data(),PxU32(size));}
    };
    read(prefix+".pxbin",bytes);read(prefix+".destruction",destruction);
    const bool destructive=destruction.getSize()!=0;require(bytes.getSize(),"empty PhysX snapshot");
    auto* registry=PxSerialization::createSerializationRegistry(context.physics());require(registry,"replay registry");
    std::ofstream report(std::string(directory)+"/replay.json");report<<std::setprecision(17);
    report<<"{\"contract\":\"physical-file-replay-v20\",\"steps_per_restore\":1,\"repetitions\":"<<repetitions
        <<",\"projectile_impulse\":"<<(impulse?"true":"false")<<",\"samples\":[";
    {
        World baseline;Events baselineEvents;
        for(unsigned i=0;i<repetitions;++i){
            World next;Events nextEvents;World& world=i?next:baseline;Events& events=i?nextEvents:baselineEvents;
            const auto begin=std::chrono::steady_clock::now();world.load(context.physics(),*registry,context.scene(),events,bytes);
            if(destructive){PxDefaultMemoryInputData input(destruction.getData(),destruction.getSize());
                require(world.scene->getDestructionScene()->importState(input,*world.objects),"file destruction import failed");}
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
            step(*world.scene);
            const double tickMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-start).count();
            auto status=world.scene->getDestructionScene()->getLastStatus();
            if(destructive){require(!status.error && status.converged && status.frame==frame+1
                    && status.correctionPasses<=1 && status.stressPasses==1+status.correctionPasses,"file replay quality/correction failed");
                const auto after=health(*world.scene);for(unsigned j=0;j<after.size();++j)
                    require(std::isfinite(after[j]) && after[j]>=0 && after[j]<=previous[j],"file replay healed damage");}
            MotionError error;
            if(i){error=compareObjects(*baseline.objects,*world.objects,1e-4f);
                if(destructive)compareDestruction(*baseline.scene,*world.scene);}
            if(i)report<<',';
            report<<"{\"repeat\":"<<i<<",\"restore_ms\":"<<restoreMs<<",\"complete_step_ms\":"<<tickMs
                <<",\"stress_iterations\":"<<status.iterations<<",\"broken_bonds\":"<<status.brokenBonds
                <<",\"correction_passes\":"<<status.correctionPasses<<",\"stress_passes\":"<<status.stressPasses
                <<",\"position_error_m\":"<<error.position<<",\"linear_error_m_s\":"<<error.linear<<",\"angular_error_rad_s\":"<<error.angular<<'}';report.flush();
        }
    }
    report<<"],\"passed\":true}\n";registry->release();require(context.healthy(),"PhysX error during file replay");
    std::cout<<"completed "<<repetitions<<" independent one-tick file restores"<<std::endl;
}
