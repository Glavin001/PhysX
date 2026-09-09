// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <foundation/PxProfiler.h>
// Two independent loaded columns. The weak bond fails on the trial; the
// subfatal bond loses section once and fails only when stress is re-evaluated.
// The latter must split at the accepted pose without a third physics pass.
void postCorrectionFracture(bool reports) {
    PxRigidDynamic* owners[2]{};PxShape* shapes[4]{};
    struct Observe final:PxProfilerCallback {
        PxRigidDynamic** owners;PxShape** shapes;unsigned bindings=0,publications=0;bool failed=false,watching=false;
        Observe(PxRigidDynamic** o,PxShape** s):owners(o),shapes(s) {require(!PxGetProfilerCallback(),"shape observer occupied");PxSetProfilerCallback(this);}
        ~Observe()override{PxSetProfilerCallback(nullptr);}
        void* zoneStart(const char* name,bool,PxU64)override {
            if(watching && !std::strcmp(name,"GpuDestruction.finalShapePublication")) {
                ++publications;if(bindings!=2)failed=true;
            }
            return nullptr;
        }
        void zoneEnd(void*,const char* name,bool,PxU64)override {
            if(watching && !std::strcmp(name,"GpuDestruction.applyBindings")) {
                ++bindings;
                for(unsigned c=0;c<2;++c)if(shapes[2*c+1]->getActor()!=owners[c])failed=true;
            }
        }
    } publication(owners,shapes);
    Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&events,false,false,false,false,PxSolverType::eTGS,false,reports);
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    PxDestructionStressChunk chunks[4]{};PxDestructionChunkMassProperties mass[4]{};
    PxDestructionStressCluster clusters[2]{};PxDestructionStressBond bonds[2]{};
    for(unsigned c=0;c<2;++c) {
        auto* owner=physics.createRigidDynamic(PxTransform(PxVec3(10*c,5,0)));owners[c]=owner;
        owner->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        owner->setMass(3);owner->setMassSpaceInertiaTensor(PxVec3(7.0f/6,.5f,7.0f/6));
        owner->setCMassLocalPose(PxTransform(PxVec3(0,-1.0f/3,0)));
        owner->setLinearDamping(0);owner->setAngularDamping(0);
        owner->setMaxLinearVelocity(20+c);owner->setMaxAngularVelocity(30+c);
        for(unsigned j=0;j<2;++j) {
            const unsigned i=2*c+j;const PxVec3 local(0,float(j)-1,0);
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
    scene.simulate(1.f/60);require(scene.fetchResults(true),"post-stress warmup failed");
    auto* stage=scene.getDestructionScene();
    for(unsigned c=0;c<2;++c) {
        clusters[c]={owners[c]->getGPUIndex(),PxVec3(0,-1.f/3,0)};
        for(unsigned j=0;j<2;++j)chunks[2*c+j].contactIndex=stage->getShapeContactIndex(*shapes[2*c+j]);
    }
    PxDestructionMaterial materials[2];
    materials[0].compressionElasticLimit=0;materials[0].compressionFatalLimit=1;
    materials[1].compressionElasticLimit=0;materials[1].compressionFatalLimit=30;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=4;desc.chunkMassProperties=mass;
    desc.clusters=clusters;desc.clusterCount=2;desc.bonds=bonds;desc.bondCount=2;
    desc.materials=materials;desc.materialCount=2;desc.damageRate=60;
    desc.preserveUnchangedContactPairs=true;
    desc.maxIterations=128;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;
    require(stage->configureStress(desc),"post-stress configuration failed");
    scene.setGravity(PxVec3(0,-9.81f,0));sentinel->setLinearVelocity(PxVec3(3,0,0));
    publication.watching=true;
    const auto before=sentinel->getGlobalPose().p;
    scene.simulate(1.f/60);PxU32 error=0;const bool complete=scene.fetchResults(true,&error);
    publication.watching=false;
    std::fprintf(stderr,"shape publication: bindings=%u publications=%u failed=%u\n",publication.bindings,publication.publications,publication.failed);
    require(!publication.failed && publication.bindings==2 && publication.publications==1,
        "public shape owners did not wait for the union of both fracture evaluations");
    const auto status=stage->getLastStatus();
    std::fprintf(stderr,"post-stress complete=%u error=%u stage=%u passes=%u correction=%u broken=%u second=%u\n",
        complete,error,status.error,status.stressPasses,status.correctionPasses,status.brokenBonds,status.postCorrectionBrokenBonds);
    require(complete && !error && !status.error,"post-correction fracture did not commit");
    require(status.frame==1 && status.correctionPasses==1 && status.stressPasses==2,"wrong physics/stress pass budget");
    require(status.brokenBonds==2 && status.postCorrectionBrokenBonds==1,"second stress verdict missing or applied twice");
    require(PxAbs(sentinel->getGlobalPose().p.x-before.x-.05f)<1e-4f
        && PxAbs(sentinel->getLinearVelocity().y+9.81f/60)<1e-5f,"ordinary body integrated/forced more than once");
    auto* late=shapes[3]->getActor()->is<PxRigidDynamic>();
    require(late && late!=owners[1],"second-pass fragment kept original owner");
    require((late->getGlobalPose().transform(shapes[3]->getLocalPose().p)-PxVec3(10,5,0)).magnitude()<1e-5f
        && late->getLinearVelocity().magnitude()<1e-5f,"second-pass fragment was rewound or integrated a third time");
    // Final CPU observation must not overwrite the exposed last-trial binding
    // batch with a different, two-pass publication batch (whose source is unset).
    {
        const auto view=stage->getDeviceView();
        PxScopedCudaLock lock(*context.cudaContextManager());
        require(cuEventSynchronize(view.readyEvent)==CUDA_SUCCESS,"trial binding view event failed");
        PxDestructionCollisionPreparationStatus prepared{};
        require(cuMemcpyDtoH(&prepared,CUdeviceptr(view.collisionPreparation),sizeof(prepared))==CUDA_SUCCESS,
            "trial binding status readback failed");
        require(prepared.count>0 && prepared.count<=4,"missing final trial binding view");
        std::vector<PxDestructionCollisionBinding> bindings(prepared.count);
        require(cuMemcpyDtoH(bindings.data(),CUdeviceptr(view.trialCollisionBindings),bindings.size()*sizeof(bindings[0]))==CUDA_SUCCESS,
            "trial binding view readback failed");
        for(const auto& binding:bindings) {
            require(binding.chunk<4 && binding.shape==chunks[binding.chunk].contactIndex,
                "final observation overwrote trial collision identity");
            require(binding.sourceBody!=PX_INVALID_U32 && binding.targetBody!=PX_INVALID_U32,
                "final observation overwrote trial collision ownership");
        }
    }
    BodyObserver observer(*context.cudaContextManager());
    // Final observation must include owners changed by EITHER pass, once each.
    // The second verdict must not replace the first pass's pending publication.
    for(unsigned c=0;c<2;++c) {
        auto* fragment=shapes[2*c+1]->getActor()->is<PxRigidDynamic>();
        require(fragment && fragment!=owners[c],"fracture owner union is incomplete");
        require(PxAbs(fragment->getMass()-2)<1e-5f && PxAbs(owners[c]->getMass()-1)<1e-5f,
            "final physical properties lost one fracture pass");
        require((owners[c]->getCMassLocalPose().p-PxVec3(0,-1,0)).magnitude()<1e-5f,
            "supported owner's final mass frame is stale");
        for(auto* actor:{owners[c],fragment})require(PxAbs(actor->getLinearDamping())<1e-7f
            && PxAbs(actor->getAngularDamping())<1e-7f
            && PxAbs(actor->getMaxLinearVelocity()-(20+c))<1e-5f
            && PxAbs(actor->getMaxAngularVelocity()-(30+c))<1e-5f,
            "GPU physical settings observation lost a fracture evaluation");
        observer.verify(*stage,*owners[c]);observer.verify(*stage,*fragment);
    }
    observer.verify(*stage,*late);
    PxRaycastBuffer hit;require(scene.raycast(PxVec3(10,7,0),PxVec3(0,-1,0),2,hit)
        && hit.block.shape==shapes[3] && hit.block.actor==late,"second-pass query ownership stale");
    scene.simulate(1.f/60);require(scene.fetchResults(true),"step following second-pass fracture failed");
    require(stage->getLastStatus().stressPasses==1 && !stage->getLastStatus().brokenBonds
        && !stage->getLastStatus().correctionPasses,"second-pass cuts leaked into next tick");
    observer.verify(*stage,*late);
    require(stage->clearStress(),"post-stress cleanup failed");
    for(auto* owner:owners)owner->release();sentinel->release();for(auto* shape:shapes)shape->release();
    require(context.healthy(),"post-stress GPU health failed");
    std::puts("post-correction: 4 chunks, 2 bonds, 2 columns, ordinary sentinel; both verdicts and one-time motion passed");
}
