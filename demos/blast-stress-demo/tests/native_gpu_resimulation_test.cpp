// End-to-end native impact: no external stress adapter and no application replay.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cstdio>
#include <cmath>
#include <stdexcept>
using namespace physx;
namespace {
void require(bool x,const char* why){if(!x)throw std::runtime_error(why);}
void check(CUresult x){if(x!=CUDA_SUCCESS){const char* name=nullptr;cuGetErrorName(x,&name);std::fprintf(stderr,"CUDA %s\n",name?name:"");throw std::runtime_error("CUDA observation failed");}}
struct Events:PxSimulationEventCallback {
    unsigned advances=0;
    void onAdvance(const PxRigidBody*const*,const PxTransform*,const PxU32)override{++advances;}
    void onConstraintBreak(PxConstraintInfo*,PxU32)override{}
    void onWake(PxActor**,PxU32)override{}
    void onSleep(PxActor**,PxU32)override{}
    void onContact(const PxContactPairHeader&,const PxContactPair*,PxU32)override{}
    void onTrigger(PxTriggerPair*,PxU32)override{}
};
struct Result {float projectileVelocity;unsigned corrections,contacts;};
Result impact(bool fracture,bool gravity=false,bool speculative=false) {
    Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&events,true,true,false,false);
    auto& scene=context.scene();auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    scene.setGravity(gravity?PxVec3(0,-9.81f,0):PxVec3(0));
    auto* wall=physics.createRigidDynamic(PxTransform(PxVec3(0,5,0)));
    wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    wall->setMass(2);wall->setMassSpaceInertiaTensor(PxVec3(1.0f/3));
    wall->setLinearDamping(0);wall->setAngularDamping(0);
    auto* shape=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
    require(wall->attachShape(*shape),"wall shape attachment failed");scene.addActor(*wall);
    auto* shot=physics.createRigidDynamic(PxTransform(PxVec3(-2,5,0)));
    auto* sphere=physics.createShape(PxSphereGeometry(.2f),context.material(),true);
    require(shot->attachShape(*sphere),"projectile shape attachment failed");
    shot->setMass(2);shot->setMassSpaceInertiaTensor(PxVec3(.032f));
    shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(PxVec3(12,0,0));
    shot->setRigidBodyFlag(PxRigidBodyFlag::eENABLE_POSE_INTEGRATION_PREVIEW,true);
    if(speculative)shot->setRigidBodyFlag(PxRigidBodyFlag::eENABLE_SPECULATIVE_CCD,true);
    scene.addActor(*shot);
    auto* sentinel=physics.createRigidDynamic(PxTransform(PxVec3(-50,50,0)));
    sentinel->setLinearDamping(0);sentinel->setAngularDamping(0);scene.addActor(*sentinel);
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"warmup failed");events.advances=0;
    const auto identity=scene.getDirectGPUAPI().getShapeContactIndex(*shape);
    PxDestructionStressChunk chunks[2]={{PxVec3(0,-1,0),0,0,0,PX_INVALID_U32},
        {PxVec3(0),2,1.0f/3,0,identity,1,0}};
    PxDestructionChunkMassProperties mass[2]{};mass[0].supported=1;mass[0].center[1]=-1;
    mass[1].mass=2;mass[1].inertia[0]=mass[1].inertia[1]=mass[1].inertia[2]=1.0/3;
    PxDestructionStressCluster cluster{wall->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};
    PxDestructionMaterial material;if(gravity){material.compressionElasticLimit=100;material.compressionFatalLimit=200;}if(!fracture){material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;}
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=&bond;desc.bondCount=1;
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;
    auto* destruction=scene.getDestructionScene();require(destruction->configureStress(desc),"native correction configuration failed");
    CUdeviceptr index=0,value=0;
    {PxScopedCudaLock lock(cuda);check(cuMemAlloc(&index,sizeof(PxU32)));check(cuMemAlloc(&value,sizeof(PxTransform)));}
    auto velocity=[&](PxRigidDynamic& body){
        PxScopedCudaLock lock(cuda);const auto id=body.getGPUIndex();check(cuMemcpyHtoD(index,&id,sizeof(id)));
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(value),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY,1),"native velocity observation failed");
        check(cuCtxSynchronize());PxVec3 out;check(cuMemcpyDtoH(&out,value,sizeof(out)));return out;
    };
    auto cleanup=[&](){
        {PxScopedCudaLock lock(cuda);check(cuMemFree(index));check(cuMemFree(value));}
        require(destruction->clearStress(),"native accepted-fragment teardown failed");
        wall->release();shot->release();sentinel->release();shape->release();sphere->release();
        require(context.healthy(),"native impact GPU health failed");
    };
    unsigned corrections=0,contacts=0;
    for(unsigned frame=0;frame<30;++frame) {
        const auto before=events.advances;
        {PxScopedCudaLock lock(cuda);const auto id=sentinel->getGPUIndex();const PxVec3 force(1,0,0);
            check(cuMemcpyHtoD(index,&id,sizeof(id)));check(cuMemcpyHtoD(value,&force,sizeof(force)));
            require(scene.getDirectGPUAPI().setRigidDynamicData(reinterpret_cast<void*>(value),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIWriteType::eFORCE,1),"ordinary force command failed");}
        scene.simulate(1.0f/60);PxU32 error=0;const bool complete=scene.fetchResults(true,&error);
        const auto status=destruction->getLastStatus();
        std::printf("native impact fracture=%u frame=%u complete=%u error=%u stage=%u contacts=%u broken=%u corrections=%u\n",unsigned(fracture),frame,unsigned(complete),error,status.error,status.normalContacts,status.brokenBonds,status.correctionPasses);
        if(speculative && !complete) {
            require(error && status.error==8 && status.brokenBonds && status.normalContacts,"unsupported fixture did not reach real fracture verdict");
            require(!status.correctionPasses && shape->getActor()==wall,"unsupported correction changed collision ownership");
            require(events.advances==before,"unsupported trial published a callback");
            cleanup();std::puts("native correction explicitly rejects unsupported speculative CCD before split application");return {0,0,contacts};
        }
        require(complete && !error && !status.error,"native impact did not accept its correction");
        require(status.converged,"native impact accepted unconverged stress");
        require(status.frame==frame+1,"correction counted as a second timestep");
        require(status.correctionPasses<=1,"native step exceeded one correction");
        require(events.advances==before+1,"trial pass duplicated pose callback");
        corrections+=status.correctionPasses;contacts+=status.normalContacts;
        if(status.correctionPasses)require(status.normalContacts && status.brokenBonds,"fracture was not driven by actual solved contact impulses");
        require(scene.getDirectGPUAPI().getShapeContactIndex(*shape)==identity,"split recreated persistent chunk collision identity");
    }
    require(!speculative,"unsupported speculative CCD correction was silently accepted");
    const auto ordinary=velocity(*sentinel);
    require(std::abs(ordinary.x-.5f)<2e-4f,"correction duplicated or lost an ordinary body's force command");
    require(std::abs(ordinary.y-(gravity?-9.81f*31/60:0))<2e-4f,"correction integrated gravity more than once");
    auto* fragment=shape->getActor()->is<PxRigidDynamic>();require(fragment,"accepted chunk has no motion owner");
    require((fragment!=wall)==fracture,"native split did not change chunk motion ownership");
    const auto v=velocity(*shot),w=velocity(*fragment);require(v.isFinite() && w.isFinite(),"nonfinite accepted motion");
    if(fracture){require(corrections==1,"single bond did not produce exactly one correction");require(w.x>1 && v.x>1,"corrected projectile did not transfer motion to fragment");require(std::abs(2*v.x+2*w.x-24)<.02f,"native correction changed linear momentum");}
    else require(!corrections && contacts,"intact control missed the impact");
    cleanup();
    return {v.x,corrections,contacts};
}
void unconvergedStress() {
    for(bool native:{false,true}) {
        blast_demo::SceneCapacity capacity;
        blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,true,false,false);
        auto& scene=context.scene();auto* parent=context.physics().createRigidDynamic(PxTransform(PxVec3(0,10,0)));
        parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        PxDestructionStressChunk nodes[4];PxDestructionChunkMassProperties mass[4]{};
        PxDestructionStressBond bonds[3];
        for(unsigned i=0;i<4;++i) {
            nodes[i]={PxVec3(float(i),0,0),i?float(i):0.0f,i?float(i):0.0f,0,PX_INVALID_U32};
            mass[i].center[0]=i;mass[i].mass=i;mass[i].supported=i==0;
            mass[i].inertia[0]=mass[i].inertia[1]=mass[i].inertia[2]=i;
            if(i) {
                bonds[i-1]={i-1,i,PxVec3(float(i)-.5f,0,0),PxVec3(1,0,0),1,1,1};
                auto* shape=context.physics().createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
                shape->setLocalPose(PxTransform(nodes[i].position));require(parent->attachShape(*shape),"cantilever shape setup failed");shape->release();
            }
        }
        scene.addActor(*parent);scene.simulate(1.0f/60);require(scene.fetchResults(true),"cantilever warmup failed");
        PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(2.3333333f,0,0)};
        PxDestructionMaterial material;material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;
        PxDestructionStressDesc desc;desc.chunks=nodes;desc.chunkCount=4;desc.chunkMassProperties=mass;desc.bonds=bonds;desc.bondCount=3;
        desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=1;desc.tolerance=1e-5f;desc.internalCorrectionLimit=native?1:0;
        auto* stage=scene.getDestructionScene();require(stage->configureStress(desc),"cantilever stress configuration failed");
        scene.simulate(1.0f/60);PxU32 error=0;const bool accepted=scene.fetchResults(true,&error);const auto status=stage->getLastStatus();
        require(!status.converged && status.iterations==1,"fixture did not exhaust its stress budget");
        if(native)require(!accepted && error && (status.error&4096u) && !status.correctionPasses,"native mode accepted an unconverged stress result");
        else require(accepted && !error && !status.error,"diagnostic compatibility changed");
        require(stage->clearStress(),"cantilever cleanup failed");parent->release();require(context.healthy(),"cantilever GPU health failed");
    }
    std::puts("native convergence gate rejects exhausted stress budget; diagnostic reference remains selectable");
}
}
int main(){try {unconvergedStress();const auto intact=impact(false),broken=impact(true);impact(true,true);impact(true,false,true);require(broken.projectileVelocity>intact.projectileVelocity+1,"correction did not change projectile response relative to intact wall");std::printf("NATIVE RESIM PASS: intact projectile=%g fractured projectile=%g corrections=%u\n",intact.projectileVelocity,broken.projectileVelocity,broken.corrections);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
