// Ordinary CPU/GPU queries must retain actor identity for exclusive and shared
// shapes. Exercises removal and rebuild against the native query payload change.
#pragma once
inline void queryControls(bool gpu,bool shared) {
    using namespace physx;
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(gpu?blast_demo::PhysicsMode::Gpu:blast_demo::PhysicsMode::Cpu,
        gpu,capacity,nullptr,gpu,false,gpu,gpu);
    auto& scene=context.scene();auto& physics=context.physics();
    PxRigidDynamic* actors[2];PxShape* shapes[2];
    for(unsigned i=0;i<2;++i) {
        actors[i]=physics.createRigidDynamic(PxTransform(PxVec3(10.0f*float(i),4,0)));
        actors[i]->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        shapes[i]=shared && i ? shapes[0] : physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),!shared);
        require(actors[i]->attachShape(*shapes[i]),"query control attachment failed");scene.addActor(*actors[i]);
    }
    scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"query control step failed");
    auto hit=[&](unsigned i,bool cache) {
        PxRaycastBuffer result;PxQueryCache cached;cached.actor=actors[i];cached.shape=shapes[i];
        require(scene.raycast(PxVec3(10.0f*float(i),6,0),PxVec3(0,-1,0),3,result,PxHitFlag::eDEFAULT,
            PxQueryFilterData(),nullptr,cache?&cached:nullptr) && result.hasBlock
            && result.block.actor==actors[i] && result.block.shape==shapes[i],"ordinary query payload lost actor identity");
    };
    for(unsigned i=0;i<2;++i){hit(i,false);hit(i,true);}
    scene.forceDynamicTreeRebuild(false,true);
    for(unsigned i=0;i<2;++i)hit(i,false);
    actors[0]->detachShape(*shapes[0]);scene.flushQueryUpdates();
    PxRaycastBuffer absent;require(!scene.raycast(PxVec3(0,6,0),PxVec3(0,-1,0),3,absent),"removed query shape remained visible");
    hit(1,false);hit(1,true);
    actors[0]->release();actors[1]->release();shapes[0]->release();if(!shared)shapes[1]->release();
    require(context.healthy(),"ordinary query control reported physics errors");
    std::printf("ordinary query control: gpu=%u shared=%u passed\n",unsigned(gpu),unsigned(shared));
}
