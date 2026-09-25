// A localized command breaks a free assembly. The corrected solve must apply
// the command to its own piece, not duplicate the parent's acceleration on both.
void chunkCommandFracture(bool rotated,bool mismatch=false,bool parallel=false,bool moving=false) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    const PxTransform pose(PxVec3(4,5,-2),rotated?PxQuat(PxHalfPi,PxVec3(0,1,0)):PxQuat(PxIdentity));
    auto* parent=physics.createRigidDynamic(pose);
    parent->setMass(2);parent->setMassSpaceInertiaTensor(PxVec3(1.0f/3,5.0f/6,5.0f/6));
    parent->setLinearDamping(0);parent->setAngularDamping(0);parent->setSleepThreshold(0);
    if(moving){parent->setLinearVelocity(PxVec3(3,0,2));parent->setAngularVelocity(PxVec3(0,.4f,0));}
    PxShape* shapes[2];
    for(PxU32 i=0;i<2;++i) {
        shapes[i]=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        shapes[i]->setLocalPose(PxTransform(PxVec3(i?.5f:-.5f,0,0)));
        require(parent->attachShape(*shapes[i]),"command fixture attachment failed");
    }
    scene.addActor(*parent);scene.simulate(1.0f/60);require(scene.fetchResults(true),"command fixture initialization failed");
    const PxVec3 baseLinear=parent->getLinearVelocity(),baseAngular=parent->getAngularVelocity();
    const PxQuat commandOrientation=parent->getGlobalPose().q;
    auto* stage=scene.getDestructionScene();require(stage,"command fixture stage missing");
    PxDestructionStressChunk chunks[2];PxDestructionChunkMassProperties mass[2]{};
    for(PxU32 i=0;i<2;++i) {
        const float x=i?.5f:-.5f;
        chunks[i]={PxVec3(x,0,0),1,1.0f/6,0,stage->getShapeContactIndex(*shapes[i]),1,0};
        mass[i].center[0]=x;mass[i].mass=1;
        for(PxU32 k=0;k<3;++k)mass[i].inertia[k]=1.0/6;
    }
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bonds[2]={{0,1,PxVec3(0,-.2f,0),PxVec3(1,0,0),1,1,1},
        {0,1,PxVec3(0,.2f,0),PxVec3(1,0,0),1,1,1,1}};
    PxDestructionMaterial material;material.compressionElasticLimit=1;material.compressionFatalLimit=2;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=bonds;desc.bondCount=parallel?2:1;
    PxDestructionMaterial materials[2]={material,material};
    materials[1].compressionElasticLimit=100;materials[1].compressionFatalLimit=200;
    desc.materials=materials;desc.materialCount=parallel?2:1;desc.maxIterations=128;desc.tolerance=1e-6f;
    desc.internalCorrectionLimit=1;desc.enableChunkLoads=true;
    auto invalid=desc;invalid.internalCorrectionLimit=0;require(!stage->configureStress(invalid),"command inputs accepted without correction");
    invalid=desc;invalid.materialCount=0;require(!stage->configureStress(invalid),"command inputs accepted without material topology");
    require(stage->configureStress(desc),"chunk command configuration rejected");
    PxDestructionChunkLoad loads[2];loads[0].impulse=PxVec3(0,100.0f/60,0);
    require(!stage->setChunkLoads(loads,1),"wrong command count accepted");
    require(stage->setChunkLoads(loads,2),"valid chunk command rejected");
    parent->addForce(PxVec3(0,mismatch?50:100,0));
    parent->addTorque(commandOrientation.rotate(PxVec3(-.5f,0,0)).cross(PxVec3(0,100,0)));
    scene.simulate(1.0f/60);PxU32 error=0;const bool fetched=scene.fetchResults(true,&error);
    const auto status=stage->getLastStatus();
    std::printf("chunk command status: fetched=%u error=%u stage=%u broken=%u correction=%u\n",unsigned(fetched),error,status.error,status.brokenBonds,status.correctionPasses);
    if(parallel) {
        require(fetched&&!error&&!status.error,"parallel joint evaluation failed");
        require(status.brokenBonds==1,"weak parallel interface did not fail independently");
        require(shapes[0]->getActor()==parent && shapes[1]->getActor()==parent,"one failed interface disconnected a surviving parallel joint");
        const auto view=stage->getDeviceView();float health[2];
        {PxScopedCudaLock lock(*context.cudaContextManager());require(cuEventSynchronize(view.readyEvent)==CUDA_SUCCESS,"parallel observation wait");
            require(cuMemcpyDtoH(health,reinterpret_cast<CUdeviceptr>(view.bondHealth),sizeof(health))==CUDA_SUCCESS,"parallel bond observation");}
        require(health[0]<=0 && health[1]>0,"parallel bond identities were merged");
        loads[0].impulse=PxVec3(0,10000.0f/60,0);
        require(stage->setChunkLoads(loads,2),"second parallel command rejected");
        parent->addForce(PxVec3(0,10000,0));
        parent->addTorque(parent->getGlobalPose().q.rotate(PxVec3(-.5f,0,0)).cross(PxVec3(0,10000,0)));
        scene.simulate(1.0f/60);require(scene.fetchResults(true)&&!stage->getLastStatus().error,"last parallel interface step failed");
        require(stage->getLastStatus().brokenBonds==1 && shapes[0]->getActor()!=shapes[1]->getActor(),"last parallel joint did not disconnect its physical bodies");
    } else if(mismatch) {
        require(status.error&16384u,"unapportioned native command was silently accepted");
        require(shapes[0]->getActor()==parent && shapes[1]->getActor()==parent,"bad commands changed physical ownership");
    } else {
        require(fetched&&!error&&!status.error,"apportioned command correction failed");
        require(status.brokenBonds==1 && status.correctionPasses==1,"localized command did not cause one corrected fracture");
        auto* left=shapes[0]->getActor()->is<PxRigidDynamic>();auto* right=shapes[1]->getActor()->is<PxRigidDynamic>();
        require(left&&right&&left!=right,"command fracture did not split physical owners");
        require((left->getLinearVelocity()-baseLinear-baseAngular.cross(commandOrientation.rotate(PxVec3(-.5f,0,0)))-PxVec3(0,100.0f/60,0)).magnitude()<.002f,"loaded piece lost its force");
        require((right->getLinearVelocity()-baseLinear-baseAngular.cross(commandOrientation.rotate(PxVec3(.5f,0,0)))).magnitude()<.002f,"parent force was cloned onto the unloaded piece");
        require((left->getAngularVelocity()-baseAngular).magnitude()<.002f && (right->getAngularVelocity()-baseAngular).magnitude()<.002f,"force lever arm was not recentered");
        BodyObserver observer(*context.cudaContextManager());observer.verify(*stage,*left);observer.verify(*stage,*right);
        // No setter and no new actor command on the next tick: the load must
        // expire, while the velocity produced by the previous impulse remains.
        const PxVec3 before=left->getLinearVelocity();
        scene.simulate(1.0f/60);require(scene.fetchResults(true)&&!stage->getLastStatus().error,"expired command step failed");
        require((left->getLinearVelocity()-before).magnitude()<.002f,"chunk command leaked into the next frame");
    }
    require(stage->clearStress(),"command fixture cleanup failed");parent->release();for(auto* shape:shapes)shape->release();
    std::printf("chunk command: rotated=%u mismatch=%u parallel=%u moving=%u passed\n",unsigned(rotated),unsigned(mismatch),unsigned(parallel),unsigned(moving));
}
