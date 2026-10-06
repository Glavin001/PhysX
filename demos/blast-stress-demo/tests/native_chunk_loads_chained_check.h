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
//
// far: the same bar 2.5 km from the origin, turned about its own axis, with
// thin chunks (inertia 0.01, an inverse inertia of 100): shares apportioned
// and audited from rounded world-position arms, where rounding counts most.
void chunkLoadsChainedFracture(PxU32 limit,bool far=false) {
    const PxVec3 origin=far?PxVec3(2017.37f,5.13f,-1493.71f):PxVec3(0,5,0);const float I=far?.01f:1.0f/6;
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    // Far: also turned about the bar's own axis, so world arms carry rotation
    // rounding (the expected motion is unchanged: y and z inertias are equal).
    auto* parent=physics.createRigidDynamic(PxTransform(origin,far?PxQuat(.7f,PxVec3(1,0,0)):PxQuat(PxIdentity)));
    parent->setMass(3);parent->setMassSpaceInertiaTensor(PxVec3(3*I,3*I+2,3*I+2));
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
        chunks[i]={PxVec3(x[i],0,0),1,I,0,stage->getShapeContactIndex(*shapes[i]),1,i?1u:0u};
        mass[i].center[0]=x[i];mass[i].mass=1;for(PxU32 k=0;k<3;++k)mass[i].inertia[k]=I;
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
    const float dt=1.0f/60,g=9.81f,twist=6*I; // 0.1 rad/s on its own: a slow spin, not a collision with its neighbour
    PxDestructionChunkLoad loads[3];
    for(PxU32 i=0;i<3;++i)loads[i].impulse=PxVec3(0,-g*dt,0);
    loads[0].impulse.x=-F*dt;loads[2].impulse.x=F*dt;loads[2].angularImpulse=PxVec3(0,0,twist*dt);
    require(stage->setChunkLoads(loads,3),"chained chunk commands rejected");
    PxVec3 impulse(0),angular(0);
    for(PxU32 i=0;i<3;++i){impulse+=loads[i].impulse;angular+=loads[i].angularImpulse+PxVec3(x[i],0,0).cross(loads[i].impulse);}
    parent->addForce(impulse,PxForceMode::eIMPULSE);parent->addTorque(angular,PxForceMode::eIMPULSE);
    scene.simulate(dt);PxU32 error=0;const bool fetched=scene.fetchResults(true,&error);
    const auto status=stage->getLastStatus();
    std::fprintf(stderr,"chained commands far=%u limit=%u fetched=%u error=%u stage=%u broken=%u later=%u correction=%u stress=%u\n",
        unsigned(far),limit,unsigned(fetched),error,status.error,status.brokenBonds,status.postCorrectionBrokenBonds,status.correctionPasses,status.stressPasses);
    require(fetched && !error && !status.error,"chained command fracture failed");
    const PxU32 corrections=PxMin(limit,2u);
    require(status.brokenBonds==2 && status.postCorrectionBrokenBonds==1,"chained command verdicts missing or duplicated");
    require(status.correctionPasses==corrections && status.stressPasses==corrections+1,"wrong corrected solve count");
    PxRigidDynamic* pieces[3];
    for(PxU32 i=0;i<3;++i){pieces[i]=shapes[i]->getActor()->is<PxRigidDynamic>();require(pieces[i],"chunk lost its actor");}
    require(pieces[0]!=pieces[1] && pieces[1]!=pieces[2] && pieces[0]!=pieces[2],"chained fracture did not split three owners");
    PxVec3 linear[3],spin[3];
    for(PxU32 i=0;i<3;++i){linear[i]=loads[i].impulse;spin[i]=loads[i].angularImpulse/I;}
    if(limit==1) {
        // The pair 1-2 was re-solved as one body carrying both commands, then
        // split at its corrected end-of-tick motion without another solve.
        const PxVec3 v=(loads[1].impulse+loads[2].impulse)/2,w=loads[2].angularImpulse/(2*I+.5f);
        linear[1]=v+w.cross(PxVec3(-.5f,0,0));linear[2]=v+w.cross(PxVec3(.5f,0,0));spin[1]=spin[2]=w;
    }
    bool exact=true;
    for(PxU32 i=0;i<3;++i) {
        const auto v=pieces[i]->getLinearVelocity(),w=pieces[i]->getAngularVelocity();
        std::fprintf(stderr,"  chunk %u (%s): velocity %g %g %g (expected %g %g %g) spin %g %g %g (expected %g %g %g)\n",i,
            pieces[i]==parent?"source body":"fragment",v.x,v.y,v.z,linear[i].x,linear[i].y,linear[i].z,w.x,w.y,w.z,spin[i].x,spin[i].y,spin[i].z);
        exact=exact && (v-linear[i]).magnitude()<2e-3f && (w-spin[i]).magnitude()<2e-3f;
    }
    require(exact,"a chunk's command was not applied exactly once to its owner");
    BodyObserver observer(*context.cudaContextManager());for(auto* piece:pieces)observer.verify(*stage,*piece);
    // No new commands next tick: nothing may leak into it.
    PxVec3 before[3];for(PxU32 i=0;i<3;++i)before[i]=pieces[i]->getLinearVelocity();
    scene.simulate(dt);require(scene.fetchResults(true,&error) && !error && !stage->getLastStatus().error,"tick after chained commands failed");
    require(!stage->getLastStatus().brokenBonds,"no bond was left to break");
    for(PxU32 i=0;i<3;++i)require((pieces[i]->getLinearVelocity()-before[i]).magnitude()<2e-3f,"chunk command leaked into the next tick");
    require(stage->clearStress(),"chained command cleanup failed");
    parent->release();for(auto* shape:shapes)shape->release();require(context.healthy(),"chained command GPU health failed");
    std::printf("chunk commands through a chained fracture: far=%u limit=%u, 2 bonds, %u corrected solves passed\n",unsigned(far),limit,corrections);
}
// A weightless carrier (Vehicle2: its weight arrives as chunk commands) with
// fragmentGravity sheds a free fragment. On the split tick the fragment's
// command share already carries its weight, so the corrected solve must not
// add scene gravity as well; from the next tick the fragment falls under scene
// gravity and nobody describes its weight any more. The carrier remnant stays
// weightless. Before the fix the fragment fell 2 g dt on the split tick.
void fragmentGravityCommandFracture(PxU32 limit) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(4,5,-2)));
    parent->setMass(2);parent->setMassSpaceInertiaTensor(PxVec3(1.0f/3,5.0f/6,5.0f/6));
    parent->setLinearDamping(0);parent->setAngularDamping(0);parent->setSleepThreshold(0);parent->setStabilizationThreshold(0);
    parent->setActorFlag(PxActorFlag::eDISABLE_GRAVITY,true);
    PxShape* shapes[2];
    for(PxU32 i=0;i<2;++i) {
        shapes[i]=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        shapes[i]->setLocalPose(PxTransform(PxVec3(i?.5f:-.5f,0,0)));
        require(parent->attachShape(*shapes[i]),"fragment gravity attachment failed");
    }
    scene.addActor(*parent);scene.simulate(1.0f/60);require(scene.fetchResults(true),"fragment gravity initialization failed");
    parent->setLinearVelocity(PxVec3(0));parent->setAngularVelocity(PxVec3(0));
    auto* stage=scene.getDestructionScene();require(stage,"fragment gravity stage missing");
    PxDestructionStressChunk chunks[2];PxDestructionChunkMassProperties mass[2]{};
    for(PxU32 i=0;i<2;++i) {
        const float x=i?.5f:-.5f;
        chunks[i]={PxVec3(x,0,0),1,1.0f/6,0,stage->getShapeContactIndex(*shapes[i]),1,0};
        mass[i].center[0]=x;mass[i].mass=1;for(PxU32 k=0;k<3;++k)mass[i].inertia[k]=1.0/6;
    }
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bond{0,1,PxVec3(0),PxVec3(1,0,0),1,1,1};
    PxDestructionMaterial material;material.compressionElasticLimit=1;material.compressionFatalLimit=2;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=&bond;desc.bondCount=1;
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-6f;
    desc.internalCorrectionLimit=limit;desc.enableChunkLoads=true;desc.fragmentGravity=true;
    require(stage->configureStress(desc),"fragment gravity configuration rejected");
    const float dt=1.0f/60,g=9.81f;scene.setGravity(PxVec3(0,-g,0));
    PxDestructionChunkLoad loads[2];
    for(PxU32 i=0;i<2;++i)loads[i].impulse=PxVec3(0,-g*dt,0);
    loads[0].impulse.y+=100*dt;
    require(stage->setChunkLoads(loads,2),"fragment gravity commands rejected");
    parent->addForce(loads[0].impulse+loads[1].impulse,PxForceMode::eIMPULSE);
    parent->addTorque(PxVec3(-.5f,0,0).cross(loads[0].impulse)+PxVec3(.5f,0,0).cross(loads[1].impulse),PxForceMode::eIMPULSE);
    scene.simulate(dt);PxU32 error=0;const bool fetched=scene.fetchResults(true,&error);
    const auto status=stage->getLastStatus();
    std::fprintf(stderr,"fragment gravity limit=%u fetched=%u error=%u stage=%u broken=%u correction=%u\n",
        limit,unsigned(fetched),error,status.error,status.brokenBonds,status.correctionPasses);
    require(fetched && !error && !status.error && status.brokenBonds==1 && status.correctionPasses==1,"fragment gravity split failed");
    PxRigidDynamic* pieces[2];
    for(PxU32 i=0;i<2;++i){pieces[i]=shapes[i]->getActor()->is<PxRigidDynamic>();require(pieces[i],"chunk lost its actor");}
    require(pieces[0]!=pieces[1],"fragment gravity fixture did not split");
    require(pieces[0]==parent || pieces[1]==parent,"the carrier remnant was not its source body");
    for(PxU32 i=0;i<2;++i) {
        const auto v=pieces[i]->getLinearVelocity();
        std::fprintf(stderr,"  split tick %s %u: velocity %g %g %g (expected %g %g %g)\n",pieces[i]==parent?"carrier":"fragment",i,
            v.x,v.y,v.z,loads[i].impulse.x,loads[i].impulse.y,loads[i].impulse.z);
        require((v-loads[i].impulse).magnitude()<2e-3f,"split tick applied a fragment's weight twice (or not at all)");
    }
    // Next tick: only the carrier's weight is a command; the fragment has scene gravity.
    const PxU32 carrier=pieces[0]==parent?0:1;PxDestructionChunkLoad next[2];next[carrier].impulse=PxVec3(0,-g*dt,0);
    require(stage->setChunkLoads(next,2),"next-tick commands rejected");parent->addForce(next[carrier].impulse,PxForceMode::eIMPULSE);
    PxVec3 before[2];for(PxU32 i=0;i<2;++i)before[i]=pieces[i]->getLinearVelocity();
    scene.simulate(dt);require(scene.fetchResults(true,&error) && !error && !stage->getLastStatus().error,"tick after fragment gravity split failed");
    for(PxU32 i=0;i<2;++i) {
        const auto dv=pieces[i]->getLinearVelocity()-before[i];
        std::fprintf(stderr,"  next tick %s: dv %g %g %g\n",i==carrier?"carrier":"fragment",dv.x,dv.y,dv.z);
        require((dv-PxVec3(0,-g*dt,0)).magnitude()<2e-3f,i==carrier?"carrier did not stay weightless":"free fragment did not fall under scene gravity");
    }
    require(stage->clearStress(),"fragment gravity cleanup failed");
    parent->release();for(auto* shape:shapes)shape->release();require(context.healthy(),"fragment gravity GPU health failed");
    std::printf("fragment gravity with chunk commands: limit=%u passed\n",limit);
}
// The trial audit (status 16384) on a light, thin remnant far from the origin:
// a 3.5 kg rod whose inverse inertia about its axis is ~500, every chunk
// carrying its weight on a weightless actor, the host applying the total at
// the COM (as Vehicle2 does). The chunk sums' torque about the COM is zero up
// to the rounding of world-position arms, which that inverse inertia turned
// into more than the audit's absolute 1e-4 rad/s: correct ticks were
// rejected (vibe-land fleet: 8-24 incomplete steps at limit 1).
void thinRemnantCommandAudit() {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    const float x[3]={-.213f,.071f,.287f},m[3]={1.2f,1.3f,1.0f};
    float total=0,com=0;for(PxU32 i=0;i<3;++i){total+=m[i];com+=m[i]*x[i];}com/=total;
    const float axial=.00071f; // per chunk, about the rod axis
    float transverse=0;for(PxU32 i=0;i<3;++i)transverse+=m[i]*((x[i]-com)*(x[i]-com))+axial;
    auto* body=physics.createRigidDynamic(PxTransform(PxVec3(1234.567f,89.123f,-987.654f),PxQuat(.83f,PxVec3(.3f,.8f,-.52f).getNormalized())));
    body->setMass(total);body->setCMassLocalPose(PxTransform(PxVec3(com,0,0)));
    body->setMassSpaceInertiaTensor(PxVec3(3*axial,transverse,transverse));
    body->setLinearDamping(0);body->setAngularDamping(0);body->setSleepThreshold(0);body->setStabilizationThreshold(0);
    body->setActorFlag(PxActorFlag::eDISABLE_GRAVITY,true);
    PxShape* shapes[3];
    for(PxU32 i=0;i<3;++i) {
        shapes[i]=physics.createShape(PxBoxGeometry(.07f,.02f,.02f),context.material(),true);
        shapes[i]->setLocalPose(PxTransform(PxVec3(x[i],0,0)));require(body->attachShape(*shapes[i]),"thin remnant attachment failed");
    }
    scene.addActor(*body);scene.simulate(1.0f/60);require(scene.fetchResults(true),"thin remnant initialization failed");
    body->setLinearVelocity(PxVec3(0));body->setAngularVelocity(PxVec3(0,.3f,-.2f));
    auto* stage=scene.getDestructionScene();require(stage,"thin remnant stage missing");
    PxDestructionStressChunk chunks[3];PxDestructionChunkMassProperties mass[3]{};
    for(PxU32 i=0;i<3;++i) {
        chunks[i]={PxVec3(x[i],0,0),m[i],axial,0,stage->getShapeContactIndex(*shapes[i]),1,0};
        mass[i].center[0]=x[i];mass[i].mass=m[i];for(PxU32 k=0;k<3;++k)mass[i].inertia[k]=axial;
    }
    PxDestructionStressCluster cluster{body->getGPUIndex(),PxVec3(com,0,0)};
    PxDestructionStressBond bonds[2]={{0,1,PxVec3((x[0]+x[1])/2,0,0),PxVec3(1,0,0),.0016f,1,1},{1,2,PxVec3((x[1]+x[2])/2,0,0),PxVec3(1,0,0),.0016f,1,1}};
    PxDestructionMaterial material;material.compressionElasticLimit=1e9f;material.compressionFatalLimit=2e9f;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=3;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=bonds;desc.bondCount=2;
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=64;desc.tolerance=1e-5f;
    desc.internalCorrectionLimit=1;desc.enableChunkLoads=true;
    require(stage->configureStress(desc),"thin remnant configuration rejected");
    const float dt=1.0f/60,g=9.81f;scene.setGravity(PxVec3(0,-g,0));
    PxDestructionChunkLoad loads[3];for(PxU32 i=0;i<3;++i)loads[i].impulse=PxVec3(0,-g*m[i]*dt,0);
    PxU32 rejected=0,first=0;
    for(PxU32 tick=0;tick<120;++tick) {
        require(stage->setChunkLoads(loads,3),"thin remnant commands rejected");
        body->addForce(PxVec3(0,-g*total*dt,0),PxForceMode::eIMPULSE);
        scene.simulate(dt);PxU32 error=0;const bool fetched=scene.fetchResults(true,&error);
        const auto status=stage->getLastStatus();
        if(!fetched || error || status.error){if(!rejected++)first=tick;}
    }
    std::fprintf(stderr,"thin remnant: %u of 120 ticks rejected (first %u), velocity y %g\n",rejected,first,body->getLinearVelocity().y);
    require(!rejected,"the command audit rejected a correctly described thin remnant");
    require(PxAbs(body->getLinearVelocity().y+g*120*dt)<1e-2f,"thin remnant did not carry its weight exactly once a tick");
    require(stage->clearStress(),"thin remnant cleanup failed");
    body->release();for(auto* shape:shapes)shape->release();require(context.healthy(),"thin remnant GPU health failed");
    std::printf("thin remnant command audit: 120 ticks passed\n");
}
