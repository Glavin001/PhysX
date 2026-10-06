// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// Chunk commands through a chained fracture: more than one corrected solve in
// one tick while every chunk carries an apportioned command, as on a
// destructible Vehicle2 car (weightless carrier, gravity supplied per chunk).
//
// A free three-chunk bar along x, chunks 0 1 2 at x = -1 0 1, one kilogram
// each. Every chunk carries its weight as an impulse (the actor ignores scene
// gravity); chunk 0 is pulled by -F along x, chunk 2 by +F and twisted about
// z. The intact bar does not accelerate along x, so each bond carries F:
// bond 0-1 (fatal F/2) breaks on the trial evaluation. Once chunk 0 is its own
// body the pair 1-2 accelerates at F/2 per kilogram and bond 1-2 carries only
// F/2, but with damageRate*dt == 1 the trial took F/F12 of its section, so the
// corrected evaluation sees (F/2)/(1-F/F12): fatal there for F12 in (F, 1.5F].
//
// Limit 1 re-solves the first split and applies the second at the corrected
// end-of-tick motion: chunks 1 and 2 share the pair's motion. Limit 2 re-solves
// the second split too, so each chunk ends the tick with exactly its own
// command applied once: v_i = J_i/m_i, w_i = L_i/I_i. Limit 3 stops early with
// the same result. Any duplicated, dropped or misplaced command changes these
// velocities, and the stage's own per-pass command audit (status 16384)
// checks every evaluation against the bodies' actual rigid inputs.
void chunkLoadsChainedFracture(PxU32 limit) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(0,5,0)));
    parent->setMass(3);parent->setMassSpaceInertiaTensor(PxVec3(.5f,2.5f,2.5f));
    parent->setLinearDamping(0);parent->setAngularDamping(0);parent->setSleepThreshold(0);parent->setStabilizationThreshold(0);
    parent->setActorFlag(PxActorFlag::eDISABLE_GRAVITY,true);
    PxShape* shapes[3];const float x[3]={-1,0,1};
    for(PxU32 i=0;i<3;++i) {
        shapes[i]=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        shapes[i]->setLocalPose(PxTransform(PxVec3(x[i],0,0)));
        require(parent->attachShape(*shapes[i]),"chained command attachment failed");
    }
    scene.addActor(*parent);scene.simulate(1.0f/60);require(scene.fetchResults(true),"chained command initialization failed");
    parent->setLinearVelocity(PxVec3(0));parent->setAngularVelocity(PxVec3(0));
    auto* stage=scene.getDestructionScene();require(stage,"chained command stage missing");
    PxDestructionStressChunk chunks[3];PxDestructionChunkMassProperties mass[3]{};
    for(PxU32 i=0;i<3;++i) {
        chunks[i]={PxVec3(x[i],0,0),1,1.0f/6,0,stage->getShapeContactIndex(*shapes[i]),1,i?1u:0u};
        mass[i].center[0]=x[i];mass[i].mass=1;for(PxU32 k=0;k<3;++k)mass[i].inertia[k]=1.0/6;
    }
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bonds[2]={{0,1,PxVec3(-.5f,0,0),PxVec3(1,0,0),1,1,1,0},{1,2,PxVec3(.5f,0,0),PxVec3(1,0,0),1,1,1,1}};
    const float F=20;
    PxDestructionMaterial materials[2];
    materials[0].compressionElasticLimit=0;materials[0].compressionFatalLimit=F/2;
    materials[1].compressionElasticLimit=0;materials[1].compressionFatalLimit=1.25f*F;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=3;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=bonds;desc.bondCount=2;
    desc.materials=materials;desc.materialCount=2;desc.damageRate=60;desc.maxIterations=128;desc.tolerance=1e-6f;
    desc.internalCorrectionLimit=limit;desc.enableChunkLoads=true;
    require(stage->configureStress(desc),"chunk commands rejected at this correction limit");
    scene.setGravity(PxVec3(0,-9.81f,0));
    const float dt=1.0f/60,g=9.81f,twist=1;
    PxDestructionChunkLoad loads[3];
    for(PxU32 i=0;i<3;++i)loads[i].impulse=PxVec3(0,-g*dt,0);
    loads[0].impulse.x=-F*dt;loads[2].impulse.x=F*dt;loads[2].angularImpulse=PxVec3(0,0,twist*dt);
    require(stage->setChunkLoads(loads,3),"chained chunk commands rejected");
    PxVec3 impulse(0),angular(0);
    for(PxU32 i=0;i<3;++i){impulse+=loads[i].impulse;angular+=loads[i].angularImpulse+PxVec3(x[i],0,0).cross(loads[i].impulse);}
    parent->addForce(impulse,PxForceMode::eIMPULSE);parent->addTorque(angular,PxForceMode::eIMPULSE);
    scene.simulate(dt);PxU32 error=0;const bool fetched=scene.fetchResults(true,&error);
    const auto status=stage->getLastStatus();
    std::fprintf(stderr,"chained commands limit=%u fetched=%u error=%u stage=%u broken=%u later=%u correction=%u stress=%u\n",
        limit,unsigned(fetched),error,status.error,status.brokenBonds,status.postCorrectionBrokenBonds,status.correctionPasses,status.stressPasses);
    require(fetched && !error && !status.error,"chained command fracture failed");
    const PxU32 corrections=PxMin(limit,2u);
    require(status.brokenBonds==2 && status.postCorrectionBrokenBonds==1,"chained command verdicts missing or duplicated");
    require(status.correctionPasses==corrections && status.stressPasses==corrections+1,"wrong corrected solve count");
    PxRigidDynamic* pieces[3];
    for(PxU32 i=0;i<3;++i){pieces[i]=shapes[i]->getActor()->is<PxRigidDynamic>();require(pieces[i],"chunk lost its actor");}
    require(pieces[0]!=pieces[1] && pieces[1]!=pieces[2] && pieces[0]!=pieces[2],"chained fracture did not split three owners");
    PxVec3 linear[3],spin[3];
    for(PxU32 i=0;i<3;++i){linear[i]=loads[i].impulse;spin[i]=loads[i].angularImpulse*6;}
    if(limit==1) {
        // The pair 1-2 was re-solved as one body carrying both commands, then
        // split at its corrected end-of-tick motion without another solve.
        const PxVec3 v=(loads[1].impulse+loads[2].impulse)/2,w=loads[2].angularImpulse/(5.0f/6);
        linear[1]=v+w.cross(PxVec3(-.5f,0,0));linear[2]=v+w.cross(PxVec3(.5f,0,0));spin[1]=spin[2]=w;
    }
    for(PxU32 i=0;i<3;++i) {
        const auto v=pieces[i]->getLinearVelocity(),w=pieces[i]->getAngularVelocity();
        std::fprintf(stderr,"  chunk %u: velocity %g %g %g (expected %g %g %g) spin %g %g %g (expected %g %g %g)\n",i,
            v.x,v.y,v.z,linear[i].x,linear[i].y,linear[i].z,w.x,w.y,w.z,spin[i].x,spin[i].y,spin[i].z);
        require((v-linear[i]).magnitude()<2e-3f,"a chunk's command was not applied exactly once to its owner (linear)");
        require((w-spin[i]).magnitude()<2e-3f,"a chunk's command was not applied exactly once to its owner (angular)");
    }
    BodyObserver observer(*context.cudaContextManager());for(auto* piece:pieces)observer.verify(*stage,*piece);
    // No new commands next tick: nothing may leak into it.
    PxVec3 before[3];for(PxU32 i=0;i<3;++i)before[i]=pieces[i]->getLinearVelocity();
    scene.simulate(dt);require(scene.fetchResults(true,&error) && !error && !stage->getLastStatus().error,"tick after chained commands failed");
    require(!stage->getLastStatus().brokenBonds,"no bond was left to break");
    for(PxU32 i=0;i<3;++i)require((pieces[i]->getLinearVelocity()-before[i]).magnitude()<2e-3f,"chunk command leaked into the next tick");
    require(stage->clearStress(),"chained command cleanup failed");
    parent->release();for(auto* shape:shapes)shape->release();require(context.healthy(),"chained command GPU health failed");
    std::printf("chunk commands through a chained fracture: limit=%u, 2 bonds, %u corrected solves passed\n",limit,corrections);
}
