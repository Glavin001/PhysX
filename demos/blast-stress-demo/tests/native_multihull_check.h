// One authored moving part has two hulls. Impact either hull: both must migrate
// together, with one mass contribution and ordinary query ownership intact.
void multiHullFracture(float impactZ) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true);
    auto& scene=context.scene();auto& physics=context.physics();
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(0,3,0)));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    parent->setMass(3);parent->setMassSpaceInertiaTensor(PxVec3(7.0f/6,.5f,7.0f/6));
    parent->setCMassLocalPose(PxTransform(PxVec3(0,-1.0f/3,0)));
    PxShape* shapes[3];
    for(unsigned i=0;i<3;++i) {
        shapes[i]=physics.createShape(PxBoxGeometry(.5f,.5f,i?.25f:.5f),context.material(),true);
        require(shapes[i],"multihull shape creation failed");
        shapes[i]->setLocalPose(PxTransform(i?PxVec3(0,0,i==1?-.25f:.25f):PxVec3(0,-1,0)));
        require(parent->attachShape(*shapes[i]),"multihull shape attachment failed");
    }
    scene.addActor(*parent);
    auto* shot=PxCreateDynamic(physics,PxTransform(PxVec3(-2,3,impactZ)),PxSphereGeometry(.15f),context.material(),1);
    shot->setMass(2);shot->setMassSpaceInertiaTensor(PxVec3(.018f));
    shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(PxVec3(12,0,0));scene.addActor(*shot);
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"multihull initial step failed");
    auto* stage=scene.getDestructionScene();require(stage,"multihull native stage missing");
    PxDestructionStressChunk chunks[2]={{PxVec3(0,-1,0),0,0,0,stage->getShapeContactIndex(*shapes[0])},
        {PxVec3(0),2,1.0f/3,0,stage->getShapeContactIndex(*shapes[1]),1,0}};
    PxDestructionStressShape extra{1,stage->getShapeContactIndex(*shapes[2])};
    PxDestructionChunkMassProperties mass[2]{};
    mass[0].supported=1;mass[0].center[1]=-1;mass[0].mass=1;
    mass[1].mass=2;
    for(unsigned i=0;i<3;++i){mass[0].inertia[i]=1.0f/6;mass[1].inertia[i]=1.0f/3;}
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0,-1.0f/3,0)};
    PxDestructionStressBond bond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};
    PxDestructionMaterial material;material.compressionElasticLimit=100;material.compressionFatalLimit=200;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=&bond;desc.bondCount=1;
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;
    desc.additionalShapes=&extra;desc.additionalShapeCount=1;
    const auto identity=extra.contactIndex;
    extra.chunk=2;require(!stage->configureStress(desc),"accepted out-of-range hull owner");extra.chunk=1;
    extra.contactIndex=chunks[1].contactIndex;require(!stage->configureStress(desc),"accepted duplicate hull identity");
    extra.contactIndex=identity;require(stage->configureStress(desc),"multihull configuration rejected");
    BodyObserver observer(*context.cudaContextManager());unsigned corrections=0;bool detached=false;
    for(unsigned tick=0;tick<60;++tick) {
        scene.simulate(1.0f/60);PxU32 error=0;
        require(scene.fetchResults(true,&error)&&!error&&!stage->getLastStatus().error,"multihull corrected step failed");
        const auto status=stage->getLastStatus();require(status.correctionPasses<=1,"excess multihull corrections");
        corrections+=status.correctionPasses;
        require(shapes[1]->getActor()==shapes[2]->getActor(),"one authored part split between hull owners");
        if(shapes[1]->getActor()!=parent) {
            detached=true;auto* fragment=shapes[1]->getActor()->is<PxRigidDynamic>();
            require(fragment && fragment->getNbShapes()==2,"fragment lost a hull");
            require(PxAbs(fragment->getMass()-2)<1e-5f,"hulls duplicated authored mass");
            observer.verify(*stage,*fragment);
            for(unsigned h=1;h<3;++h) {
                const auto center=(fragment->getGlobalPose()*shapes[h]->getLocalPose()).p;
                PxOverlapHit hits[8];PxOverlapBuffer overlap(hits,8);
                require(scene.overlap(PxSphereGeometry(.01f),PxTransform(center),overlap),"fragment hull missing in scene query");
                bool found=false;for(unsigned j=0;j<overlap.getNbAnyHits();++j)
                    found|=overlap.getAnyHit(j).shape==shapes[h] && overlap.getAnyHit(j).actor==fragment;
                require(found,"fragment hull has stale query owner");
            }
        }
    }
    require(detached && corrections==1,"impact did not fracture the multihull part exactly once");
    require(stage->clearStress(),"multihull teardown failed");
    parent->release();shot->release();for(auto* shape:shapes)shape->release();
    require(context.healthy(),"multihull GPU errors");
    std::printf("multihull impact z=%g: 2 chunks, 3 hulls, 1 bond, one corrected fracture passed\n",impactZ);
}
