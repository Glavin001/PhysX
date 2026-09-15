// Native scheduler prerequisite for GPU-produced chunk commands. Command values
// in this fixture use ordinary APIs; this does not qualify the new GPU apply path.
#include "../physx_scene.h"
#include "NpScene.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "PxgDestructionRuntime.h"
#include <cuda.h>
#include <cmath>
#include <cstdio>
#include <stdexcept>
#include <vector>
#include <cstring>
using namespace physx;
namespace {
void require(bool v,const char* message){if(!v)throw std::runtime_error(message);}
void near(float a,float b,const char* message){require(std::isfinite(a) && std::abs(a-b)<2e-5f,message);}
void check(CUresult r){require(r==CUDA_SUCCESS,"CUDA observation failed");}
struct Events : PxSimulationEventCallback {
    unsigned wakes=0,sleeps=0;
    void onWake(PxActor**,PxU32 n)override{wakes+=n;}
    void onSleep(PxActor**,PxU32 n)override{sleeps+=n;}
    void onConstraintBreak(PxConstraintInfo*,PxU32)override{}
    void onContact(const PxContactPairHeader&,const PxContactPair*,PxU32)override{}
    void onTrigger(PxTriggerPair*,PxU32)override{}
    void onAdvance(const PxRigidBody*const*,const PxTransform*,PxU32)override{}
};
void step(PxScene& scene){scene.simulate(1.f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"native step failed");}
void run(PxSolverType::Enum solver,bool accelerations,bool correction) {
    Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&events,false,false,false,false,solver,accelerations);
    auto& scene=context.scene();auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    require(!(scene.getFlags()&PxSceneFlag::eENABLE_DIRECT_GPU_API) && !(scene.getFlags()&PxSceneFlag::eDISABLE_SLEEPING),"wrong fixture mode");
    scene.setGravity(PxVec3(0));
    auto make=[&](float x,bool kinematic) {
        auto* body=physics.createRigidDynamic(PxTransform(PxVec3(x,0,0)));require(body,"body allocation failed");
        body->setMass(2);body->setMassSpaceInertiaTensor(PxVec3(.2f,.3f,.4f));body->setLinearDamping(0);body->setAngularDamping(0);
        body->setActorFlag(PxActorFlag::eSEND_SLEEP_NOTIFIES,true);
        if(kinematic)body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        auto* shape=physics.createShape(PxSphereGeometry(.25f),context.material(),true);
        require(shape && body->attachShape(*shape),"shape allocation failed");shape->release();scene.addActor(*body);return body;
    };
    auto* target=make(10,false);auto* untouched=make(20,false);auto* support=make(30,true);step(scene);
    auto* runtime=static_cast<PxgDestructionRuntime*>(scene.getDestructionScene());require(runtime,"runtime unavailable");
    const PxU32 id=target->getGPUIndex(),other=untouched->getGPUIndex(),supportId=support->getGPUIndex();
    PxDestructionStressChunk chunk{PxVec3(0),2,.2f,0,PX_INVALID_U32};
    PxDestructionChunkMassProperties mass{{0,0,0},2,{.2,.3,.4,0,0,0},0};
    PxDestructionStressCluster cluster{id,PxVec3(0)};PxDestructionStressDesc desc;
    desc.chunks=&chunk;desc.chunkCount=1;desc.chunkMassProperties=&mass;desc.clusters=&cluster;desc.clusterCount=1;
    desc.internalCorrectionLimit=correction?1:0;
    require(runtime->configureStress(desc),"stress configuration failed");
    target->putToSleep();untouched->putToSleep();step(scene);
    require(target->isSleeping() && untouched->isSleeping(),"sleep setup failed");
    const unsigned wakes=events.wakes;
    const PxU32 invalid[2]={id,PX_INVALID_U32};
    require(!runtime->wakeCommandOwners(invalid,2) && !runtime->wakeCommandOwners(nullptr,1),"invalid owner batch accepted");
    require(target->isSleeping() && untouched->isSleeping(),"invalid batch partially woke owners");
    require(runtime->wakeCommandOwners(nullptr,0),"empty owner batch failed");
    const PxU32 selected[3]={id,id,supportId};
    require(runtime->wakeCommandOwners(selected,3),"command owner wake failed");
    require(!target->isSleeping() && untouched->isSleeping(),"wake changed the wrong owner");
    // Waking did not apply a wrench or turn a support into a dynamic body.
    near(target->getLinearVelocity().magnitude(),0,"wake invented velocity");
    require(support->getRigidBodyFlags()&PxRigidBodyFlag::eKINEMATIC,"wake changed support kind");
    target->addForce(PxVec3(12,0,0),PxForceMode::eFORCE,false);
    target->addTorque(PxVec3(0,0,6),PxForceMode::eFORCE,false);
    scene.simulate(1.f/60);
    require(!runtime->wakeCommandOwners(&other,1),"owner wake admitted during simulation");
    PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"command step failed");
    require(events.wakes==wakes+1,"duplicate owner generated extra wake events");
    require(untouched->isSleeping(),"command woke untouched body");
    near(target->getLinearVelocity().x,.1f,"force did not integrate once");
    near(target->getAngularVelocity().z,.25f,"torque did not integrate once");
    {
        PxScopedCudaLock lock(cuda);const auto input=runtime->inputRigidCheckpoint();check(cuEventSynchronize(input.ready));
        PxgBodySim body{};check(cuMemcpyDtoH(&body,CUdeviceptr(input.bodies+id),sizeof(body)));
        const auto commands=runtime->commandInputHistory();
        if(correction) {
            require(commands.generation==input.generation && commands.ready==input.ready && commands.status,"missing command input history");
            PxgDestructionCommandInputStatus status{};check(cuMemcpyDtoH(&status,CUdeviceptr(commands.status),sizeof(status)));
            require(!status.error && status.generation==input.generation && status.count==commands.count,"invalid command input receipt");
            std::vector<PxgDestructionCommandInput> rows(commands.count);
            if(commands.count)check(cuMemcpyDtoH(rows.data(),CUdeviceptr(commands.records),rows.size()*sizeof(rows[0])));
            unsigned found=0;
            for(const auto& r:rows)if(r.body==id && r.kind==1) {
                ++found;near(r.linearBefore[0],0,"pre-command linear velocity lost");near(r.angularBefore[2],0,"pre-command angular velocity lost");
                near(r.linearDelta[0],.1f,"submitted linear command lost");near(r.angularDelta[2],.25f,"submitted angular command lost");
            }
            require(found==1,"command history missing/duplicated target");
            CUstream refresh{};check(cuStreamCreate(&refresh,CU_STREAM_NON_BLOCKING));
            require(runtime->captureRigidState(input.bodies,input.previous,input.accelerations,input.count,refresh,
                PxgDestructionCheckpointPurpose::CorrectedMotion),"corrected refresh failed");
            check(cuStreamSynchronize(refresh));check(cuStreamDestroy(refresh));
            const auto retained=runtime->commandInputHistory();
            require(retained.generation==commands.generation && retained.records==commands.records && retained.count==commands.count,
                "correction replaced original command history");
            std::vector<PxgDestructionCommandInput> again(retained.count);
            if(retained.count)check(cuMemcpyDtoH(again.data(),CUdeviceptr(retained.records),again.size()*sizeof(again[0])));
            require(!std::memcmp(rows.data(),again.data(),rows.size()*sizeof(rows[0])),"correction changed original command bytes");
        } else require(!commands.generation && !commands.records,"uncaptured ordinary input mislabeled as command-free");
        // Native correction uses GPU velocity deltas for ordinary commands.
        // Without correction, optional body-acceleration reporting selects
        // the external-acceleration representation instead (Sc::updateForces).
        const bool delta=correction || !accelerations;
        near(body.linearVelocityXYZ_inverseMassW.x,delta?.1f:0,"checkpoint lost command velocity");
        near(body.angularVelocityXYZ_maxPenBiasW.z,delta?.25f:0,"checkpoint lost command angular velocity");
        near(body.externalLinearAcceleration.x,delta?0:6,"checkpoint force representation mismatch");
        near(body.externalAngularAcceleration.z,delta?0:15,"checkpoint torque representation mismatch");
        near(body.linearVelocityXYZ_inverseMassW.x+body.externalLinearAcceleration.x/60,.1f,"checkpoint command impulse mismatch");
        near(body.angularVelocityXYZ_maxPenBiasW.z+body.externalAngularAcceleration.z/60,.25f,"checkpoint command angular impulse mismatch");
        near(body.body2World.p.x,10,"checkpoint was captured after pose integration");
    }
    step(scene);near(target->getLinearVelocity().x,.1f,"force repeated next tick");near(target->getAngularVelocity().z,.25f,"torque repeated next tick");
    // Pending sleep finalization must finish before the next force is submitted.
    target->putToSleep();require(runtime->wakeCommandOwners(&id,1),"pending-sleep wake failed");
    target->addForce(PxVec3(12,0,0),PxForceMode::eFORCE,false);step(scene);
    near(target->getLinearVelocity().x,.1f,"pending sleep erased a new command");
    target->putToSleep();step(scene);untouched->release();untouched=nullptr;
    const PxU32 stale[2]={id,other};require(!runtime->wakeCommandOwners(stale,2),"deleted native owner accepted");
    require(target->isSleeping(),"deleted-owner batch partially woke target");
    require(runtime->clearStress(),"clear failed");require(!runtime->commandInputHistory().generation && !runtime->commandInputHistory().records,"clear retained command history");target->release();support->release();
    require(context.healthy(),"native command wake GPU error");
    std::printf("command wake: ordinary/sleeping, batch rejection, duplicate events, support, force/torque and pending sleep passed; solver=%u accelerations=%u correction=%u\n",unsigned(solver),unsigned(accelerations),unsigned(correction));
}
}
int main(){try{for(auto solver:{PxSolverType::eTGS,PxSolverType::ePGS})for(bool accelerations:{false,true})for(bool correction:{false,true})run(solver,accelerations,correction);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
