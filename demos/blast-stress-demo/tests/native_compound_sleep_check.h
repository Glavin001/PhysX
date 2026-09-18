// Exercise sparse native sleep on a compound larger than one CUDA block.
// Observe device data only in this test; production has no body-state readback.
void compoundSleep() {
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,{},nullptr,
        false,false,false,false,PxSolverType::eTGS,true,false);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    auto* body=physics.createRigidDynamic(PxTransform(PxVec3(0,50,0),PxQuat(.37f,PxVec3(0,1,0))));
    body->setCMassLocalPose(PxTransform(PxVec3(.3f,.1f,-.2f),PxQuat(-.21f,PxVec3(1,0,0))));
    body->setMass(37);body->setMassSpaceInertiaTensor(PxVec3(40,50,60));
    body->setLinearDamping(0);body->setAngularDamping(0);
    body->setRigidBodyFlag(PxRigidBodyFlag::eRETAIN_ACCELERATIONS,true);
    for(unsigned i=0;i<513;++i){
        auto* shape=physics.createShape(PxBoxGeometry(.2f,.3f,.4f),context.material(),true);
        shape->setLocalPose(PxTransform(PxVec3(float(i%27),float(i/27),0),PxQuat(.13f,PxVec3(0,0,1))));
        require(body->attachShape(*shape),"compound sleep shape attach failed");shape->release();
    }
    scene.addActor(*body);
    // A quiet native asset initializes the actual ordinary-API destruction
    // path; the compound remains an independent ordinary participant.
    auto* support=physics.createRigidDynamic(PxTransform(PxVec3(-50,50,0)));
    support->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    support->setMass(2);support->setMassSpaceInertiaTensor(PxVec3(5.f/6,1.f/3,5.f/6));
    support->setCMassLocalPose(PxTransform(PxVec3(0,-.5f,0)));
    PxShape* supportShapes[2];
    for(unsigned i=0;i<2;++i){supportShapes[i]=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        supportShapes[i]->setLocalPose(PxTransform(PxVec3(0,i?0.f:-1.f,0)));require(support->attachShape(*supportShapes[i]),"native support attach failed");}
    scene.addActor(*support);scene.simulate(1.f/60);require(scene.fetchResults(true),"native support setup failed");
    auto* stage=scene.getDestructionScene();
    PxDestructionStressChunk chunks[2]={{PxVec3(0,-1,0),0,0,0,stage->getShapeContactIndex(*supportShapes[0])},
        {PxVec3(0),1,1.f/6,0,stage->getShapeContactIndex(*supportShapes[1]),1,0}};
    PxDestructionChunkMassProperties mass[2]{};
    for(auto& m:mass){m.mass=1;m.inertia[0]=m.inertia[1]=m.inertia[2]=1.f/6;}
    mass[0].supported=1;mass[0].center[1]=-1;
    PxDestructionStressCluster cluster{support->getGPUIndex(),PxVec3(0,-.5f,0)};
    PxDestructionStressBond bond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};
    PxDestructionMaterial material;material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;
    PxDestructionStressDesc config;config.chunks=chunks;config.chunkCount=2;config.chunkMassProperties=mass;config.clusters=&cluster;config.clusterCount=1;
    config.bonds=&bond;config.bondCount=1;config.materials=&material;config.materialCount=1;config.maxIterations=128;config.tolerance=1e-5f;
    require(stage->configureStress(config),"compound native stage configuration failed");
    // Both creation-time inactivity and explicit sleep before first upload
    // use CPU initial state. A subsequent wake command must survive unchanged.
    PxRigidDynamic* initial[3];
    for(unsigned i=0;i<3;++i){
        initial[i]=PxCreateDynamic(physics,PxTransform(PxVec3(100+float(i)*3,50,0)),PxBoxGeometry(.5f),context.material(),1);
        initial[i]->setLinearDamping(0);initial[i]->setAngularDamping(0);
        if(i==0)initial[i]->setWakeCounter(0);
        scene.addActor(*initial[i]);
        if(i){initial[i]->setLinearVelocity(PxVec3(5,0,0));initial[i]->putToSleep();}
        if(i==2)initial[i]->addForce(PxVec3(3,0,0),PxForceMode::eVELOCITY_CHANGE);
    }
    scene.simulate(1.f/60);require(scene.fetchResults(true),"initial sleep/wake upload failed");
    BodyObserver initialObserver(*context.cudaContextManager());
    for(unsigned i=0;i<3;++i){
        initialObserver.verify(*stage,*initial[i]);
        require(initial[i]->isSleeping()==(i<2),"pre-upload sleep/wake state lost");
        require((initial[i]->getLinearVelocity()-PxVec3(i==2?3.f:0.f,0,0)).magnitude()<1e-5f,"pre-upload sleep/wake velocity lost or duplicated");
        initial[i]->release();
    }
    auto* api=static_cast<NpScene&>(scene).getScScene().getSimulationController();
    auto* ctrl=static_cast<PxgSimulationController*>(api);
    auto& cuda=*context.cudaContextManager();
    // The native sleep transition is asynchronous (it completes before fetch
    // returns); reading the device body here needs the queued work finished.
    auto readBody=[&](){PxScopedCudaLock lock(cuda);PxgBodySim state{};require(cuCtxSynchronize()==CUDA_SUCCESS,"compound body sync failed");
        require(cuMemcpyDtoH(&state,reinterpret_cast<CUdeviceptr>(ctrl->getSimulationCore()->getBodySimBufferDevicePtr().getPointer()+body->getGPUIndex()),sizeof(state))==CUDA_SUCCESS,"compound body observation failed");return state;};
    for(bool rollback:{false,true}){
        const PxTransform start(PxVec3(3,50,7),PxQuat(.37f,PxVec3(0,1,0)));
        body->setGlobalPose(start);body->setLinearVelocity(PxVec3(1,2,3));body->setAngularVelocity(PxVec3(.4f,.5f,.6f));
        body->addForce(PxVec3(4,5,6));body->addTorque(PxVec3(7,8,9));
        scene.simulate(1.f/60);require(scene.fetchResults(true),"compound setup step failed");
        const auto before=readBody();const PxU32 id=body->getGPUIndex();
        require(api->finalizeSleepingRigidBodies(&id,1,rollback),"compound sleep transaction failed");
        const auto after=readBody();
        require(after.linearVelocityXYZ_inverseMassW.x==0 && after.linearVelocityXYZ_inverseMassW.y==0 && after.linearVelocityXYZ_inverseMassW.z==0
            && after.angularVelocityXYZ_maxPenBiasW.x==0 && after.angularVelocityXYZ_maxPenBiasW.y==0 && after.angularVelocityXYZ_maxPenBiasW.z==0,"compound sleep retained velocity");
        require(after.externalLinearAcceleration.x==0 && after.externalLinearAcceleration.y==0 && after.externalLinearAcceleration.z==0
            && after.externalAngularAcceleration.x==0 && after.externalAngularAcceleration.y==0 && after.externalAngularAcceleration.z==0,"compound sleep retained force/torque");
        require(after.linearVelocityXYZ_inverseMassW.w==before.linearVelocityXYZ_inverseMassW.w
            && after.angularVelocityXYZ_maxPenBiasW.w==before.angularVelocityXYZ_maxPenBiasW.w,"compound sleep changed mass/limits");
        const PxTransform actor=after.body2World.getTransform()*after.body2Actor_maxImpulseW.getTransform().getInverse();
        const PxTransform expected=rollback?start:body->getGlobalPose();
        require((actor.p-expected.p).magnitude()<1e-4f && PxAbs(actor.q.dot(expected.q))>1-1e-5f,"compound rollback pose mismatch");
        PxScopedCudaLock lock(cuda);
        PxgBodySimVelocities previous{};
        require(cuMemcpyDtoH(&previous,reinterpret_cast<CUdeviceptr>(ctrl->getSimulationCore()->getBodySimPrevVelocitiesBufferDevicePtr().getPointer()+id),sizeof(previous))==CUDA_SUCCESS,"compound previous velocity observation failed");
        require(previous.linearVelocity.x==0 && previous.linearVelocity.y==0 && previous.linearVelocity.z==0
            && previous.angularVelocity.x==0 && previous.angularVelocity.y==0 && previous.angularVelocity.z==0,"compound sleep left stale acceleration history");
        PxgUpdateActorDataDesc update{};
        require(cuMemcpyDtoH(&update,reinterpret_cast<CUdeviceptr>(ctrl->getSimulationCore()->getUpdatedActorDescDesc().getPointer()),sizeof(update))==CUDA_SUCCESS,"compound descriptor observation failed");
        const auto count=ctrl->getSimulationCore()->getNumTotalShapes();
        std::vector<PxNodeIndex> nodes(count);std::vector<PxU32> shapes(count);
        require(cuMemcpyDtoH(nodes.data(),reinterpret_cast<CUdeviceptr>(update.mRigidNodeIndices),count*sizeof(PxNodeIndex))==CUDA_SUCCESS
            && cuMemcpyDtoH(shapes.data(),reinterpret_cast<CUdeviceptr>(update.mShapeIndices),count*sizeof(PxU32))==CUDA_SUCCESS,"compound shape ranges observation failed");
        unsigned checked=0;
        for(unsigned i=0;i<count;++i)if(nodes[i]==PxNodeIndex(id) && shapes[i]!=PX_INVALID_U32){
            PxgShapeSim shape;PxsCachedTransform transform{};PxBounds3 bounds;
            require(cuMemcpyDtoH(&shape,reinterpret_cast<CUdeviceptr>(update.mShapeSimsBufferDeviceData+shapes[i]),sizeof(shape))==CUDA_SUCCESS
                && cuMemcpyDtoH(&transform,reinterpret_cast<CUdeviceptr>(update.mTransformCache+shapes[i]),sizeof(transform))==CUDA_SUCCESS
                && cuMemcpyDtoH(&bounds,reinterpret_cast<CUdeviceptr>(update.mBounds+shapes[i]),sizeof(bounds))==CUDA_SUCCESS,"compound shape observation failed");
            const PxTransform expectedShape=actor*shape.mTransform;
            require((transform.transform.p-expectedShape.p).magnitude()<2e-4f
                && PxAbs(transform.transform.q.dot(expectedShape.q))>1-1e-5f,"compound shape transform stale after sleep");
            for(unsigned corner=0;corner<8;++corner){
                const PxVec3 point=expectedShape.transform(PxVec3(corner&1?.2f:-.2f,corner&2?.3f:-.3f,corner&4?.4f:-.4f));
                for(unsigned axis=0;axis<3;++axis)require(point[axis]>=bounds.minimum[axis]-2e-4f && point[axis]<=bounds.maximum[axis]+2e-4f,"compound GPU bound misses sleep geometry");
            }
            ++checked;
        }
        require(checked==513,"compound sleep omitted shapes");
    }
    require(stage->clearStress(),"compound native teardown failed");
    body->release();support->release();for(auto* shape:supportShapes)shape->release();require(context.healthy(),"compound sleep GPU errors");
    std::printf("native compound sleep: 2 native chunks/1 bond + one ordinary body, 513 rotated/offset colliders; pose rollback, velocities, forces, history and all GPU bounds passed\n");
}
