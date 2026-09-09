// Compare native GPU kinematic inputs with the unchanged ordinary PhysX path.
// Public targets, rotation, settling, wake and scene reconfiguration are real
// simulation commands; no diagnostic pose writes drive the solver.
void nativeKinematicInputs(PxSolverType::Enum solver,const char* capturePath=nullptr,unsigned activation=0) {
    struct Sample {PxTransform platform,cargo,ccd;PxVec3 velocity;PxgSolverBodyData input;};
    const auto capture=[&](bool native) {
        Fixture f(2,0,true,solver,false,true);
        f.scene.setGravity(PxVec3(0,-9.81f,0));
        f.material.compressionElasticLimit=1e12f;f.material.compressionFatalLimit=2e12f;
        f.desc.internalCorrectionLimit=1;
        if(native && activation!=2)f.configure();
        auto* platform=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(0,2,0)),
            PxBoxGeometry(2,.5f,2),f.context.material(),1);
        auto* cargo=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(0,2.75f,0)),
            PxSphereGeometry(.25f),f.context.material(),1);
        require(platform && cargo,"moving platform setup failed");
        platform->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        platform->setCMassLocalPose(PxTransform(PxVec3(.2f,0,0)));
        platform->setSolverIterationCounts(7,3);cargo->setSolverIterationCounts(7,3);
        f.scene.addActor(*platform);f.scene.addActor(*cargo);
        auto& gpu=*static_cast<PxgGpuContext*>(static_cast<NpScene&>(f.scene).getScScene().getDynamicsContext());
        std::vector<Sample> samples;
        for(unsigned tick=0;tick<64;++tick) {
            // Exercise both directions without creating another simulation or
            // changing the authored physical commands between the two runs.
            if(native && activation==0 && tick==24)require(f.stage->clearStress(),"native input teardown failed");
            if(native && activation!=1 && tick==40)f.configure();
            const bool activeTarget=tick<28 || tick>=44;
            if(activeTarget)platform->setKinematicTarget(PxTransform(PxVec3(.012f*float(tick+1),2,0),
                PxQuat(.004f*float(tick+1),PxVec3(0,1,0))));
            step(f.scene);
            const bool resident=native && (activation==1 || tick>=40 || (activation==0 && tick<24));
            if(resident) {
                if(!capturePath)require(gpu.mSolverBodyDataPool.size()==1,"native kinematic solver inputs still require CPU records");
                else if(activeTarget)require(gpu.mSolverBodyDataPool.size()>1,"reference capture requires the committed CPU-input baseline");
                const auto status=f.stage->getLastStatus();
                require(!status.error && !status.brokenBonds && !status.correctionPasses,
                    "platform comparator unexpectedly fractured");
            } else if(activeTarget)require(gpu.mSolverBodyDataPool.size()>1,"ordinary kinematic input path was changed");
            const auto& body=static_cast<NpRigidDynamic*>(platform)->getCore().getSim()->getLowLevelBody();
            PxgSolverBodyData input;PxMemZero(&input,sizeof(input));
            for(PxU32 i=0;i<gpu.mActiveNodeIndex.size();++i)if(gpu.mActiveNodeIndex[i].index()==platform->getGPUIndex()) {
                PxScopedCudaLock lock(f.cuda);
                check(cuMemcpyDtoH(&input,gpu.getGpuSolverCore()->getSolverBodyData()->getDevicePtr()+i*sizeof(input),sizeof(input)));
            }
            samples.push_back({platform->getGlobalPose(),cargo->getGlobalPose(),body.getLastCCDTransform(),cargo->getLinearVelocity(),input});
        }
        require((samples.back().cargo.p-samples.front().cargo.p).magnitude()>.05f,
            "moving kinematic did not produce a meaningful interaction");
        platform->release();cargo->release();require(f.context.healthy(),"kinematic input path became unhealthy");
        return samples;
    };
    const auto reference=capture(false),candidate=capture(true);
    for(unsigned i=0;i<reference.size();++i) {
        const auto& a=reference[i].input;const auto& b=candidate[i].input;
        if(!a.flags && !b.flags)continue; // Sleeping kinematics have no solver row.
        require((a.initialLinVel-b.initialLinVel).magnitude()<1e-6f
            && (a.initialAngVel-b.initialAngVel).magnitude()<1e-6f
            && (a.body2World.getTransform().p-b.body2World.getTransform().p).magnitude()<1e-6f
            && PxAbs(a.body2World.q.dot(b.body2World.q))>1-1e-6f
            && a.invMass==b.invMass && a.penBiasClamp==b.penBiasClamp
            && a.reportThreshold==b.reportThreshold && a.maxImpulse==b.maxImpulse
            && a.flags==b.flags && a.offsetSlop==b.offsetSlop,
            "GPU kinematic inputs differ from the ordinary CPU producer");
    }
    const unsigned mode=2*activation+(solver==PxSolverType::ePGS?0:1);
    const auto unpack=[](const Sample& sample,float* values) {
        unsigned n=0;
        for(const auto* pose:{&sample.platform,&sample.cargo,&sample.ccd}) {
            values[n++]=pose->p.x;values[n++]=pose->p.y;values[n++]=pose->p.z;
            values[n++]=pose->q.x;values[n++]=pose->q.y;values[n++]=pose->q.z;values[n++]=pose->q.w;
        }
        values[n++]=sample.velocity.x;values[n++]=sample.velocity.y;values[n++]=sample.velocity.z;
    };
    if(capturePath) {
        FILE* file=std::fopen(capturePath,mode?"a":"w");require(file,"reference capture open failed");
        for(unsigned i=0;i<candidate.size();++i) {
            float values[24];unpack(candidate[i],values);std::fprintf(file,"%u,%u",mode,i);
            for(float value:values)std::fprintf(file,",%.9g",double(value));
            std::fprintf(file,"\n");
        }
        require(std::fclose(file)==0,"reference capture write failed");return;
    }
    // Native-vs-ordinary trajectories already differ on the committed baseline.
    // Keep the independent input comparison above; use the mode-matched native
    // baseline for actual contact motion, without relaxing its tight tolerance.
    FILE* file=std::fopen(NATIVE_KINEMATIC_REFERENCE_FILE,"r");require(file,"kinematic reference is missing");
    unsigned rows=0,referenceMode=0,tick=0;
    while(std::fscanf(file,"%u,%u",&referenceMode,&tick)==2) {
        float expected[24];for(float& value:expected)require(std::fscanf(file,",%f",&value)==1,"invalid reference row");
        if(referenceMode!=mode)continue;
        require(tick==rows && tick<candidate.size(),"reference tick order mismatch");
        float actual[24];unpack(candidate[tick],actual);
        for(unsigned component=0;component<24;++component) {
            if(!std::isfinite(actual[component]) || PxAbs(actual[component]-expected[component])>=1e-5f)
                std::fprintf(stderr,"native kinematic trajectory mode %u tick %u component %u: %.9g != %.9g\n",mode,tick,component,double(actual[component]),double(expected[component]));
            require(std::isfinite(actual[component]) && PxAbs(actual[component]-expected[component])<1e-5f,
                "GPU input migration changed native motion or CCD history");
        }
        ++rows;
    }
    std::fclose(file);require(rows==candidate.size(),"incomplete kinematic reference");
    std::puts("2 chunks / 1 bond plus ordinary platform, cargo and sentinel: 64-step translation/rotation, COM offset, settling/wake, clear/reconfigure; GPU inputs match ordinary producer and motion/CCD match native baseline");
}

// A new actor reusing a GPU node must never inherit prescribed input from the
// removed actor. Analytic commands make this independent of recorded motion.
void nativeKinematicInputReuse(PxSolverType::Enum solver) {
    Fixture f(2,0,true,solver,false,true);f.scene.setGravity(PxVec3(0,-9.81f,0));
    f.material.compressionElasticLimit=1e12f;f.material.compressionFatalLimit=2e12f;
    f.desc.internalCorrectionLimit=1;f.configure();
    auto& gpu=*static_cast<PxgGpuContext*>(static_cast<NpScene&>(f.scene).getScScene().getDynamicsContext());
    std::vector<PxU32> prior;unsigned reused=0;
    for(unsigned lifetime=0;lifetime<12;++lifetime) {
        auto* actor=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(100+16*float(lifetime),10,0)),
            PxBoxGeometry(2,.5f,2),f.context.material(),1);
        require(actor,"kinematic reuse actor allocation failed");
        actor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);f.scene.addActor(*actor);
        // A contact with a dynamic participant requires a real solver row.
        // An isolated kinematic legitimately has no collision-solve work.
        auto* cargo=PxCreateDynamic(f.context.physics(),PxTransform(actor->getGlobalPose().p+PxVec3(0,.75f,0)),
            PxSphereGeometry(.25f),f.context.material(),1);
        require(cargo,"kinematic reuse cargo allocation failed");f.scene.addActor(*cargo);
        for(unsigned command=0;command<2;++command) {
            const PxTransform before=actor->getGlobalPose();
            actor->setKinematicTarget(PxTransform(before.p+PxVec3(.125f,0,0)));
            step(f.scene);bool found=false;const PxU32 node=actor->getGPUIndex();
            if(command==0){reused+=std::find(prior.begin(),prior.end(),node)!=prior.end();prior.push_back(node);}
            for(PxU32 i=0;i<gpu.mActiveNodeIndex.size();++i)if(gpu.mActiveNodeIndex[i].index()==node) {
                PxgSolverBodyData input;
                {PxScopedCudaLock lock(f.cuda);check(cuMemcpyDtoH(&input,
                    gpu.getGpuSolverCore()->getSolverBodyData()->getDevicePtr()+i*sizeof(input),sizeof(input)));}
                require((input.body2World.getTransform().p-before.p).magnitude()<1e-5f
                    && (input.initialLinVel-PxVec3(7.5f,0,0)).magnitude()<1e-5f
                    && input.initialAngVel.magnitude()<1e-5f && input.invMass==0,
                    "reused kinematic slot inherited old prescribed motion");found=true;
            }
            require(found && gpu.mSolverBodyDataPool.size()==1,"reused kinematic required CPU solver inputs");
        }
        actor->release();cargo->release();step(f.scene);
    }
    require(reused>0,"kinematic lifetime fixture did not reuse a GPU index");
    require(f.context.healthy(),"kinematic reuse scene became unhealthy");
    std::printf("2 chunks / 1 bond: 12 kinematic lifetimes, %u reused node IDs; input storage %zu bytes per allocated node\n",reused,sizeof(PxgKinematicMotionInput));
}
