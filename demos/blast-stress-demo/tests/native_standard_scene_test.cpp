// Embedded CUDA destruction with ordinary actor APIs and native sleeping.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include "NpScene.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "PxsRigidBody.h"
#include "PxgDestructionRuntime.h"
#include "native_pre_solve_check.h"
#include "native_contact_graph_check.h"
#include <cuda.h>
#include <cstdio>
#include <stdexcept>
#include <cstring>
#include <atomic>
using namespace physx;
namespace {
void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
struct Events:PxSimulationEventCallback {
    unsigned advances=0,wakes=0,sleeps=0,contacts=0; bool invalidContactStream=false;
    void onAdvance(const PxRigidBody*const*,const PxTransform*,PxU32)override{++advances;}
    void onWake(PxActor**,PxU32 n)override{wakes+=n;}
    void onSleep(PxActor**,PxU32 n)override{sleeps+=n;}
    void onConstraintBreak(PxConstraintInfo*,PxU32)override{}
    void onContact(const PxContactPairHeader&,const PxContactPair* pairs,PxU32 count)override{
        for(PxU32 i=0;i<count;++i) {
            const auto& pair=pairs[i];
            if(!pair.contactCount || pair.flags&(PxContactPairFlag::eREMOVED_SHAPE_0|PxContactPairFlag::eREMOVED_SHAPE_1))continue;
            if(!pair.contactPatches || !pair.contactPoints || !pair.patchCount) {invalidContactStream=true;continue;}
            std::vector<PxContactPairPoint> points(pair.contactCount);
            const auto n=pair.extractContacts(points.data(),pair.contactCount);
            if(n!=pair.contactCount)invalidContactStream=true;
            for(const auto& point:points)if(!point.position.isFinite() || !point.normal.isFinite() || !point.impulse.isFinite())invalidContactStream=true;
            contacts+=n;
        }
    }
    void onTrigger(PxTriggerPair*,PxU32)override{}
};
// The observer owns device buffers and establishes both CUDA event boundaries.
// Readback below is test instrumentation, not part of the simulation pipeline.
struct BodyObserver {
    PxCudaContextManager& cuda;CUdeviceptr index=0,pose=0;CUstream stream=nullptr;CUevent ready=nullptr,done=nullptr;
    explicit BodyObserver(PxCudaContextManager& c):cuda(c){PxScopedCudaLock lock(cuda);
        require(cuMemAlloc(&index,sizeof(PxU32))==CUDA_SUCCESS && cuMemAlloc(&pose,sizeof(PxTransform))==CUDA_SUCCESS
            && cuStreamCreate(&stream,CU_STREAM_NON_BLOCKING)==CUDA_SUCCESS
            && cuEventCreate(&ready,CU_EVENT_DISABLE_TIMING)==CUDA_SUCCESS
            && cuEventCreate(&done,CU_EVENT_DISABLE_TIMING)==CUDA_SUCCESS,"observer allocation failed");}
    ~BodyObserver(){PxScopedCudaLock lock(cuda);cuStreamSynchronize(stream);cuEventDestroy(ready);cuEventDestroy(done);cuStreamDestroy(stream);cuMemFree(index);cuMemFree(pose);}
    bool submit(PxDestructionScene& stage){return stage.readRigidBodyData(reinterpret_cast<void*>(pose),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,1,ready,done);}
    void verify(PxDestructionScene& stage,const PxRigidDynamic& actor){PxScopedCudaLock lock(cuda);
        const PxU32 id=actor.getGPUIndex();require(cuMemcpyHtoD(index,&id,sizeof(id))==CUDA_SUCCESS
            && cuEventRecord(ready,stream)==CUDA_SUCCESS && submit(stage) && cuEventSynchronize(done)==CUDA_SUCCESS,"ordered public device observation failed");
        PxTransform observed;require(cuMemcpyDtoH(&observed,pose,sizeof(observed))==CUDA_SUCCESS,"observer readback failed");
        const auto expected=actor.getGlobalPose();require((observed.p-expected.p).magnitude()<1e-4f
            && PxAbs(observed.q.dot(expected.q))>1-1e-5f,"public GPU observation differs from ordinary actor pose");}
};
#include "native_post_correction_check.h"
#include "native_chained_fracture_check.h"
#include "native_query_publication_check.h"
#include "native_compound_sleep_check.h"
#include "native_rigid_box_stack_check.h"
#include "native_captured_box_pair_check.h"
bool boundarySleep=false;
PxVec3 boundaryPose(0),boundaryVelocity(0);
void run(bool sleeping,bool boundary=false,bool fracture=true,bool deviceGraph=false,bool wakeBoundary=false,bool lateImpact=false,bool reports=true,bool retainReportedPairs=false) {
    Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&events,false,!sleeping,false,false,PxSolverType::eTGS,false,reports);
    auto& scene=context.scene();auto& physics=context.physics();
    QueryPublicationAudit queryAudit(static_cast<NpScene&>(scene).getScScene(),!reports);
    require(!(scene.getFlags()&PxSceneFlag::eENABLE_DIRECT_GPU_API),"fixture enabled Direct GPU");
    require(bool(scene.getFlags()&PxSceneFlag::eDISABLE_SLEEPING)==!sleeping,"wrong sleep mode");
    auto* wall=physics.createRigidDynamic(PxTransform(PxVec3(0,3,0)));
    wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    wall->setMass(3);wall->setMassSpaceInertiaTensor(PxVec3(7.0f/6,.5f,7.0f/6));
    wall->setCMassLocalPose(PxTransform(PxVec3(0,-1.0f/3,0)));
    wall->setLinearDamping(0);wall->setAngularDamping(0);
    auto* shape=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
    require(wall->attachShape(*shape),"wall attachment failed");
    auto* supportShape=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
    supportShape->setLocalPose(PxTransform(PxVec3(0,-1,0)));
    require(wall->attachShape(*supportShape),"support attachment failed");scene.addActor(*wall);
    auto* shot=PxCreateDynamic(physics,PxTransform(PxVec3(-2,3,0)),PxSphereGeometry(.2f),context.material(),1);
    shot->setMass(2);shot->setMassSpaceInertiaTensor(PxVec3(.032f));
    shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(PxVec3(12,0,0));
    shot->setRigidBodyFlag(PxRigidBodyFlag::eENABLE_POSE_INTEGRATION_PREVIEW,true);scene.addActor(*shot);
    auto* resting=PxCreateDynamic(physics,PxTransform(PxVec3(100,.5f,0)),PxBoxGeometry(.5f,.5f,.5f),context.material(),1);
    resting->setActorFlag(PxActorFlag::eSEND_SLEEP_NOTIFIES,true);scene.addActor(*resting);
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"initial simulation failed");
    auto* destruction=scene.getDestructionScene();require(destruction,"native stage unavailable");
    const PxU32 identity=destruction->getShapeContactIndex(*shape);
    require(identity!=PX_INVALID_U32,"ordinary shape identity unavailable");
    PxDestructionStressChunk chunks[2]={{PxVec3(0,-1,0),0,0,0,destruction->getShapeContactIndex(*supportShape)},{PxVec3(0),2,1.0f/3,0,identity,1,0}};
    PxDestructionChunkMassProperties mass[2]{};mass[0].supported=1;mass[0].center[1]=-1;mass[0].mass=1;
    mass[0].inertia[0]=mass[0].inertia[1]=mass[0].inertia[2]=1.0/6;
    mass[1].mass=2;mass[1].inertia[0]=mass[1].inertia[1]=mass[1].inertia[2]=1.0/3;
    PxDestructionStressCluster cluster{wall->getGPUIndex(),PxVec3(0,-1.0f/3,0)};
    PxDestructionStressBond bond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};
    PxDestructionMaterial material;material.compressionElasticLimit=100;material.compressionFatalLimit=200;
    if(!fracture){material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;}
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=&bond;desc.bondCount=1;
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;desc.gpuIslandRepair=deviceGraph;desc.preserveUnchangedContactPairs=!reports||retainReportedPairs;
    require(destruction->configureStress(desc),"native configuration failed");
    auto& gpu=*static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext());
    if(deviceGraph) {
        gpu.enableCudaPreSolveSupport(true);gpu.enableCudaPreSolveContacts(true);gpu.enableCudaPreSolveIslands(true);
        gpu.enableDeviceConnectivityOwnership(false);gpu.captureSolverIslandMetadata(true);
        gpu.getIslandManager().getAccurateIslandSim().setGpuComponentAudit(true);
        gpu.getIslandManager().getSpeculativeIslandSim().setGpuComponentAudit(true);
    }
    BodyObserver observer(*context.cudaContextManager());
    observer.verify(*destruction,*shot);
    unsigned corrections=0;PxRigidDynamic* fragment=nullptr;
    for(unsigned i=0;i<(sleeping?600u:60u);++i) {
        if(boundary && i==6) {
            resting->setLinearVelocity(PxVec3(0));resting->setAngularVelocity(PxVec3(0));resting->setWakeCounter(0);
        }
        const auto wakesBefore=events.wakes;
        if(wakeBoundary && i==6) {
            resting->putToSleep();resting->addForce(PxVec3(0,4,0),PxForceMode::eVELOCITY_CHANGE);
        }
        const auto timeBefore=scene.getTimestamp();
        const auto before=events.advances;queryAudit.begin();scene.simulate(1.0f/60);PxU32 error=0;
        require(!observer.submit(*destruction),"public GPU observer accepted an uncommitted step");
        const bool complete=scene.fetchResults(true,&error);const auto status=destruction->getLastStatus();
        if(!complete||error||status.error)std::fprintf(stderr,"standard sleeping=%u step=%u complete=%u error=%u destruction=%u breaks=%u corrections=%u\n",sleeping,i,complete,error,status.error,status.brokenBonds,status.correctionPasses);
        require(complete&&!error&&!status.error,"standard scene rejected correction");
        require(scene.getTimestamp()==((timeBefore+1)&0x7fffffff),"correction advanced public scene timestamp twice");
        require(!events.invalidContactStream,"accepted contact report contains invalid trial storage");
        queryAudit.verify();
        require(status.correctionPasses<=1&&status.frame==i+1,"correction advanced time twice");
        require(status.stressPasses==1+status.correctionPasses,"missing post-correction stress evaluation or excess pass");
        require(events.advances<=before+1,"trial publication duplicated onAdvance");
        corrections+=status.correctionPasses;
        if(wakeBoundary && i==6)require(events.wakes==wakesBefore+1 && !resting->isSleeping()
            && resting->getLinearVelocity().y>3,"correction lost/duplicated an explicit wake command or event");
        if(deviceGraph){try{nativePreSolveTest::verify(gpu,*context.cudaContextManager());nativeGraphTest::verify(scene,*context.cudaContextManager());}
            catch(...){std::fprintf(stderr,"device graph audit failed at frame=%u active=%u\n",i,context.statistics().nbActiveDynamicBodies);throw;}}
        if(boundary && i==6) {
            std::fprintf(stderr,"sleep boundary fracture=%u asleep=%u wake=%g velocityY=%g\n",fracture,resting->isSleeping(),resting->getWakeCounter(),resting->getLinearVelocity().y);
            if(!fracture){boundarySleep=resting->isSleeping();boundaryPose=resting->getGlobalPose().p;boundaryVelocity=resting->getLinearVelocity();}
            else require(resting->isSleeping()==boundarySleep && (resting->getGlobalPose().p-boundaryPose).magnitude()<1e-5f
                && (resting->getLinearVelocity()-boundaryVelocity).magnitude()<1e-5f,"correction changed independent sleep transition");
        }
        if(shape->getActor()!=wall) {
            fragment=shape->getActor()->is<PxRigidDynamic>();require(fragment,"fragment has no ordinary actor");
            fragment->setActorFlag(PxActorFlag::eSEND_SLEEP_NOTIFIES,true);
            require(PxAbs(wall->getMass()-1)<1e-5f && (wall->getMassSpaceInertiaTensor()-PxVec3(1.0f/6)).magnitude()<1e-5f,
                "supported cluster physical mass/inertia is stale");
            require(fragment->getLinearDamping()==0 && fragment->getAngularDamping()==0,"fragment inherited allocation-default damping");
            require(PxAbs(fragment->getMass()-2)<1e-5f,"CPU fragment mass is stale");
            require((fragment->getMassSpaceInertiaTensor()-PxVec3(1.0f/3)).magnitude()<1e-5f,"CPU fragment inertia is stale");
            observer.verify(*destruction,*fragment);
            const auto pose=fragment->getGlobalPose()*shape->getLocalPose();
            require(pose.isValid(),"invalid CPU fragment pose");
            PxRaycastBuffer hit;
            require(scene.raycast(pose.p+PxVec3(0,2,0),PxVec3(0,-1,0),2.6f,hit)&&hit.block.shape==shape&&hit.block.actor==fragment,"ordinary raycast does not match fragment motion");
            PxSweepBuffer sweep;
            require(scene.sweep(PxSphereGeometry(.1f),PxTransform(pose.p+PxVec3(0,2,0)),PxVec3(0,-1,0),2.6f,sweep)
                && sweep.block.actor==fragment && sweep.block.shape==shape,"ordinary sweep missed committed fragment");
            PxOverlapHit overlaps[8];PxOverlapBuffer overlap(overlaps,8);
            require(scene.overlap(PxSphereGeometry(.1f),PxTransform(pose.p),overlap),"ordinary overlap missed committed fragment");
            bool found=false;for(PxU32 j=0;j<overlap.getNbAnyHits();++j)found|=overlap.getAnyHit(j).shape==shape;
            require(found,"ordinary overlap returned stale shape ownership");
            {PxScopedCudaLock lock(*context.cudaContextManager());
                auto* ctrl=static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController());
                PxgBodySim observed{};cuCtxSynchronize();
                require(cuMemcpyDtoH(&observed,reinterpret_cast<CUdeviceptr>(ctrl->getSimulationCore()->getBodySimBufferDevicePtr().getPointer()+fragment->getGPUIndex()),sizeof(observed))==CUDA_SUCCESS,"GPU audit copy failed");
                const auto gpuPose=observed.body2World.getTransform()*observed.body2Actor_maxImpulseW.getTransform().getInverse();
                require((gpuPose.p-fragment->getGlobalPose().p).magnitude()<1e-4f,"CPU and GPU fragment pose disagree");
                if(fragment->isSleeping())require(observed.linearVelocityXYZ_inverseMassW.x==0 && observed.linearVelocityXYZ_inverseMassW.y==0 && observed.linearVelocityXYZ_inverseMassW.z==0,"sleeping fragment retained GPU velocity");
            }
            if(status.correctionPasses) {
                const auto p=fragment->getGlobalPose().p,v=fragment->getLinearVelocity(),sv=shot->getLinearVelocity();
                std::fprintf(stderr,"split step=%u asleep=%u wake=%g fragment=(%g,%g,%g) velocity=(%g,%g,%g) shot=(%g,%g,%g)\n",i,fragment->isSleeping(),fragment->getWakeCounter(),p.x,p.y,p.z,v.x,v.y,v.z,sv.x,sv.y,sv.z);
                require(!fragment->isSleeping()&&v.x>1,"new fragment did not wake with corrected motion");
            }
        }
        if(fracture && i==25)require(shot->getGlobalPose().p.x>.7f&&shot->getLinearVelocity().x>1,"projectile was not corrected through the released wall");
    }
    require(fracture?(corrections==1&&fragment):corrections==0,"wrong fixture correction count");
    if(sleeping && fracture) {
        std::fprintf(stderr,"settled: fragment asleep=%u wake=%g velocity=%g rest asleep=%u wake=%g shot asleep=%u wake=%g velocity=%g\n",fragment->isSleeping(),fragment->getWakeCounter(),fragment->getLinearVelocity().magnitude(),resting->isSleeping(),resting->getWakeCounter(),shot->isSleeping(),shot->getWakeCounter(),shot->getLinearVelocity().magnitude());
        require(fragment->isSleeping()&&resting->isSleeping(),"bodies did not settle into sleep");
        const auto wakeEvents=events.wakes;
        if(lateImpact) {
            const auto center=(fragment->getGlobalPose()*shape->getLocalPose()).p;
            auto* incoming=PxCreateDynamic(physics,PxTransform(center-PxVec3(2,0,0)),PxSphereGeometry(.2f),context.material(),1);
            incoming->setMass(2);scene.addActor(*incoming);
            incoming->addForce(PxVec3(12,0,0),PxForceMode::eVELOCITY_CHANGE);
            bool collisionWake=false;
            for(unsigned step=0;step<30;++step) {
                queryAudit.begin();scene.simulate(1.0f/60);require(scene.fetchResults(true) && !destruction->getLastStatus().error,"late impact failed");queryAudit.verify();
                if(step==0)require(PxAbs(incoming->getLinearVelocity().x-12)<1e-5f,"new-body velocity command applied more than once");
                collisionWake|=!fragment->isSleeping() && fragment->getLinearVelocity().x>1;
                observer.verify(*destruction,*fragment);
            }
            require(collisionWake && events.wakes==wakeEvents+1,"incoming projectile failed to wake sleeping fragment exactly once");
            incoming->release();
        } else {
            fragment->addForce(PxVec3(0,4,0),PxForceMode::eVELOCITY_CHANGE);
            scene.simulate(1.0f/60);require(scene.fetchResults(true),"wake step failed");
            require(!fragment->isSleeping()&&fragment->getLinearVelocity().y>3&&events.wakes==wakeEvents+1,"ordinary force did not wake fragment exactly once");
        }
    }
    queryAudit.exercised();
    if(retainReportedPairs)require(events.contacts>0,"reported-pair reuse did not deliver contact points");
    if(!reports || retainReportedPairs)require(!static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController())->getDestructionContactReuseFallbackCount(),
        "reported/unreported reuse unexpectedly rebuilt all correction contact pairs");
    if(deviceGraph)require(gpu.getCudaPreSolveSupportPasses()>0 && gpu.getIslandManager().getAccurateIslandSim().getGpuSplitCount()>0,"sleep fixture did not use GPU connectivity/split certificates");
    require(destruction->clearStress(),"destruction teardown failed");
    wall->release();shot->release();resting->release();shape->release();supportShape->release();require(context.healthy(),"GPU errors");
    std::printf("standard scene sleeping=%u passed: 2 chunks, 1 bond, %u projectiles, 1 resting control, corrections=%u\n",sleeping,lateImpact?2u:1u,corrections);
}
}
int main(int argc,char** argv){try{if(argc>1&&!std::strcmp(argv[1],"--rigid-box-captured-pair")){capturedBoxPair();return 0;}if(argc>1&&!std::strcmp(argv[1],"--rigid-box-captured-pair-cpu")){capturedBoxPair(true);return 0;}if(argc>1&&!std::strcmp(argv[1],"--rigid-box-compound-stress-stack")){rigidBoxStack(true,true);return 0;}if(argc>1&&!std::strcmp(argv[1],"--rigid-box-compound-stack")){rigidBoxStack(true);return 0;}if(argc>1&&!std::strcmp(argv[1],"--rigid-box-stack")){rigidBoxStack();return 0;}if(argc>1&&!std::strcmp(argv[1],"--compound-sleep")){compoundSleep();return 0;}if(argc>1&&!std::strcmp(argv[1],"--reported-reuse")){run(false,false,true,false,false,false,true,true);run(true,true,false,false,false,false,true,true);run(true,true,true,false,false,false,true,true);return 0;}if(argc>1&&!std::strcmp(argv[1],"--reuse")){run(true,false,true,false,false,true,false);return 0;}if(argc>1&&!std::strcmp(argv[1],"--post-correction")){postCorrectionFracture(true);postCorrectionFracture(false);return 0;}if(argc>1&&!std::strcmp(argv[1],"--post-correction-multi")){postCorrectionFracture(true,2);postCorrectionFracture(false,2);postCorrectionFracture(false,3);return 0;}if(argc>1&&!std::strcmp(argv[1],"--chained-fracture")){chainedFracture(1);chainedFracture(2);chainedFracture(3);return 0;}const bool boundary=argc>1&&!std::strcmp(argv[1],"--sleep-boundary");if(boundary)run(true,true,false);run(!(argc>1&&!std::strcmp(argv[1],"--awake")),boundary,true,argc>1&&!std::strcmp(argv[1],"--device-graph"),argc>1&&!std::strcmp(argv[1],"--wake-boundary"),argc>1&&!std::strcmp(argv[1],"--late-impact"));return 0;}catch(const std::exception& e){std::fprintf(stderr,"native_standard_scene_test: %s\n",e.what());return 1;}}
