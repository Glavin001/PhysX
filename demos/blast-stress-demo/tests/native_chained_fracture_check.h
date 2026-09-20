// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// Three independent hanging columns whose bonds fail at successive stress
// evaluations. Each bond carries the same load c~19.6 over unit area; with
// damageRate*dt==1 a subfatal evaluation removes the fraction c/F of the
// section, so after k evaluations the stress is c/(1-k*c/F) and the bond is
// fatal at evaluation k exactly when F<=(k+1)*c. Fatal limits 1, 30 and 49
// therefore break one column per evaluation: this is the "one layer per
// tick" case the correction budget exists for. Limit L breaks min(L+1,3)
// columns this tick, re-solving L times when it needs every pass; what a
// lower limit leaves over breaks on the next tick's trial evaluation. The
// loaded chunk hangs below its kinematic support, so a fragment that is
// re-solved after its split falls freely for exactly one timestep.
void chainedFracture(PxU32 limit) {
    constexpr unsigned kColumns=3;
    PxRigidDynamic* owners[kColumns]{};PxShape* shapes[2*kColumns]{};
    Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&events,false,false,false,false,PxSolverType::eTGS,false,false);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    PxDestructionStressChunk chunks[2*kColumns]{};PxDestructionChunkMassProperties mass[2*kColumns]{};
    PxDestructionStressCluster clusters[kColumns]{};PxDestructionStressBond bonds[kColumns]{};
    for(unsigned c=0;c<kColumns;++c) {
        auto* owner=physics.createRigidDynamic(PxTransform(PxVec3(10.f*c,5,0)));owners[c]=owner;
        owner->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        owner->setMass(3);owner->setMassSpaceInertiaTensor(PxVec3(7.0f/6,.5f,7.0f/6));
        owner->setCMassLocalPose(PxTransform(PxVec3(0,-2.0f/3,0)));
        owner->setLinearDamping(0);owner->setAngularDamping(0);
        for(unsigned j=0;j<2;++j) {
            const unsigned i=2*c+j;const PxVec3 local(0,-float(j),0);
            auto* shape=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);shapes[i]=shape;
            shape->setLocalPose(PxTransform(local));require(owner->attachShape(*shape),"column attach failed");
            chunks[i]={local,j?2.f:0.f,j?1.f/3:0.f,c,PX_INVALID_U32,1,c};
            mass[i].mass=j?2:1;mass[i].supported=!j;mass[i].center[1]=local.y;
            mass[i].inertia[0]=mass[i].inertia[1]=mass[i].inertia[2]=mass[i].mass/6;
        }
        scene.addActor(*owner);
        bonds[c]={2*c,2*c+1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1,c};
    }
    auto* sentinel=PxCreateDynamic(physics,PxTransform(PxVec3(100,20,0)),PxSphereGeometry(.2f),context.material(),1);
    sentinel->setLinearDamping(0);sentinel->setAngularDamping(0);scene.addActor(*sentinel);
    scene.simulate(1.f/60);require(scene.fetchResults(true),"chained warmup failed");
    auto* stage=scene.getDestructionScene();
    for(unsigned c=0;c<kColumns;++c) {
        clusters[c]={owners[c]->getGPUIndex(),PxVec3(0,-2.f/3,0)};
        for(unsigned j=0;j<2;++j)chunks[2*c+j].contactIndex=stage->getShapeContactIndex(*shapes[2*c+j]);
    }
    PxDestructionMaterial materials[kColumns];
    const float fatal[kColumns]={1,30,49};
    for(unsigned c=0;c<kColumns;++c){materials[c].compressionElasticLimit=0;materials[c].compressionFatalLimit=fatal[c];}
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2*kColumns;desc.chunkMassProperties=mass;
    desc.clusters=clusters;desc.clusterCount=kColumns;desc.bonds=bonds;desc.bondCount=kColumns;
    desc.materials=materials;desc.materialCount=kColumns;desc.damageRate=60;
    desc.maxIterations=128;desc.tolerance=1e-5f;desc.internalCorrectionLimit=limit;
    require(stage->configureStress(desc),"chained configuration failed");
    scene.setGravity(PxVec3(0,-9.81f,0));sentinel->setLinearVelocity(PxVec3(3,0,0));
    const auto before=sentinel->getGlobalPose().p;
    scene.simulate(1.f/60);PxU32 error=0;const bool complete=scene.fetchResults(true,&error);
    auto status=stage->getLastStatus();
    std::fprintf(stderr,"chained limit=%u complete=%u error=%u stage=%u passes=%u correction=%u broken=%u later=%u\n",
        limit,complete,error,status.error,status.stressPasses,status.correctionPasses,status.brokenBonds,status.postCorrectionBrokenBonds);
    require(complete && !error && !status.error,"chained fracture did not commit");
    // Evaluation k breaks column k, and every break within the budget is
    // re-solved; a break at the budget's last evaluation is applied in place.
    const PxU32 brokenNow=PxMin(limit+1,kColumns),corrections=PxMin(limit,brokenNow);
    require(status.frame==1 && status.correctionPasses==corrections && status.stressPasses==corrections+1,"wrong physics/stress pass budget");
    require(status.brokenBonds==brokenNow && status.postCorrectionBrokenBonds==brokenNow-1,"chained verdicts missing or duplicated");
    require(PxAbs(sentinel->getGlobalPose().p.x-before.x-.05f)<1e-4f
        && PxAbs(sentinel->getLinearVelocity().y+9.81f/60)<1e-5f,"ordinary body integrated/forced more than once");
    for(unsigned c=0;c<kColumns;++c) {
        auto* actor=shapes[2*c+1]->getActor()->is<PxRigidDynamic>();
        require(actor,"column top lost its actor");
        if(c<brokenNow) {
            require(actor!=owners[c],"broken column kept its original owner");
            // A fragment split by the final evaluation of its tick is installed
            // at the accepted motion; every earlier split falls for one timestep.
            const bool solved=c<corrections;
            const float fall=solved?9.81f/60:0;
            const PxVec3 p=actor->getGlobalPose().transform(shapes[2*c+1]->getLocalPose().p),v=actor->getLinearVelocity();
            std::fprintf(stderr,"column %u fragment: position %g %g %g velocity %g %g %g\n",c,double(p.x),double(p.y),double(p.z),double(v.x),double(v.y),double(v.z));
            require((p-PxVec3(10.f*c,4-fall/60,0)).magnitude()<1e-4f && (v-PxVec3(0,-fall,0)).magnitude()<1e-5f,
                "fragment integrated the wrong number of times");
        } else require(actor==owners[c],"column beyond the budget split early");
    }
    // Whatever the budget left intact breaks on the next tick's trial: the
    // section loss from this tick's evaluations was committed.
    scene.simulate(1.f/60);require(scene.fetchResults(true,&error) && !error,"step following chained fracture failed");
    status=stage->getLastStatus();
    const PxU32 leftover=kColumns-brokenNow;
    require(status.brokenBonds==leftover && status.correctionPasses==(leftover?1u:0u) && status.stressPasses==status.correctionPasses+1
        && !status.postCorrectionBrokenBonds,"leftover column did not break exactly once on the next tick");
    for(unsigned c=0;c<kColumns;++c)require(shapes[2*c+1]->getActor()!=owners[c],"a column survived two ticks");
    require(stage->clearStress(),"chained cleanup failed");
    for(auto* owner:owners)owner->release();sentinel->release();for(auto* shape:shapes)shape->release();
    require(context.healthy(),"chained GPU health failed");
    std::printf("chained fracture limit=%u: %u columns, %u broken this tick with %u corrected solves, %u on the next\n",
        limit,kColumns,brokenNow,corrections,leftover);
}
