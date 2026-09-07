// End-to-end native impact: no external stress adapter and no application replay.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include "NpScene.h"
#include "PxgDestructionRuntime.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "native_contact_graph_check.h"
#include "native_pre_solve_check.h"
#include "native_owner_observation_check.h"
#include "native_refilter_check.h"
#include "PxgNphaseImplementationContext.h"
#include "PxgNarrowphaseCore.h"
#include "PxsContactManager.h"
#include <set>
#include <vector>
#include <foundation/PxBroadcast.h>
#include <atomic>
#include <cuda.h>
#include <cstdio>
#include <cmath>
#include <stdexcept>
using namespace physx;
namespace {
void require(bool x,const char* why){if(!x)throw std::runtime_error(why);}
void check(CUresult x){if(x!=CUDA_SUCCESS){const char* name=nullptr;cuGetErrorName(x,&name);std::fprintf(stderr,"CUDA %s\n",name?name:"");throw std::runtime_error("CUDA observation failed");}}
// Observe accepted contact identities after internal correction. This covers
// both full contact recreation and opt-in retention of unaffected managers.
void verifyAcceptedContactIdentities(PxScene& scene,PxCudaContextManager& cuda) {
    nativeGraphTest::verify(scene,cuda);
    auto& sc=static_cast<NpScene&>(scene).getScScene();
    auto& np=*static_cast<PxgNphaseImplementationContext*>(sc.getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
    PxScopedCudaLock lock(cuda);
    check(cuStreamSynchronize(np.mStream));check(cuStreamSynchronize(np.mSolverStream));
    std::set<PxU64> live;
    for(PxU32 b=GPU_BUCKET_ID::eConvex;b<=GPU_BUCKET_ID::eConvexCoreTrimesh;++b) {
        auto& host=np.getExistingContactManagers(GPU_BUCKET_ID::Enum(b));
        auto& gpu=np.getExistingGpuContactManagers(GPU_BUCKET_ID::Enum(b));
        const PxU32 count=host.mCpuContactManagerMapping.size();if(!count)continue;
        std::vector<PxgContactGraphIdentity> ids(count);
        check(cuMemcpyDtoH(ids.data(),gpu.mContactGraphIdentities.getDevicePtr(),count*sizeof(ids[0])));
        require(host.mContactGraphIdentities.size()==count,"accepted contact identity count mismatch");
        for(PxU32 i=0;i<count;++i) {
            const auto& id=ids[i];const auto& cpu=host.mContactGraphIdentities[i];
            require(id.generation && id.edgeIndex!=PX_INVALID_U32 && id.edgeIndex==host.mCpuContactManagerMapping[i]->getWorkUnit().mEdgeIndex,
                "correction left an invalid GPU contact graph edge");
            require(id.generation==cpu.generation && id.edgeIndex==cpu.edgeIndex && live.insert(id.generation).second,
                "correction left stale or duplicated GPU contact identities");
        }
    }
}
struct AllocationAudit:PxAllocationListener {
    std::atomic<size_t> largest{0};
    AllocationAudit(){PxGetFoundation().registerAllocationListener(*this);}
    ~AllocationAudit(){PxGetFoundation().deregisterAllocationListener(*this);}
    void onAllocation(size_t size,const char*,const char*,int,void*)override {
        auto previous=largest.load();while(size>previous && !largest.compare_exchange_weak(previous,size)){}
    }
    void onDeallocation(void*)override{}
};
struct Events:PxSimulationEventCallback {
    unsigned advances=0;
    void onAdvance(const PxRigidBody*const*,const PxTransform*,const PxU32)override{++advances;}
    void onConstraintBreak(PxConstraintInfo*,PxU32)override{}
    void onWake(PxActor**,PxU32)override{}
    void onSleep(PxActor**,PxU32)override{}
    void onContact(const PxContactPairHeader&,const PxContactPair*,PxU32)override{}
    void onTrigger(PxTriggerPair*,PxU32)override{}
};
struct NoContactModification:PxContactModifyCallback {
    void onContactModify(PxContactModifyPair* const,PxU32)override{}
};
struct Result {float projectileVelocity;unsigned corrections,contacts;PxU64 constructedPairs=0;std::vector<PxVec3> contactMotion;PxU64 reuseFallbacks=0;};
Result impact(bool fracture,bool gravity=false,bool speculative=false,unsigned quietCount=0,bool reuse=false,unsigned contactCount=0,bool forceReportingFallback=false,bool massFrameWake=false) {
    NoContactModification modify;Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&events,true,true,false,false);
    auto& scene=context.scene();auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    if(forceReportingFallback)scene.setContactModifyCallback(&modify);
    scene.setGravity(gravity?PxVec3(0,-9.81f,0):PxVec3(0));
    const PxVec3 authoredOffset=massFrameWake?PxVec3(3,8,-2):PxVec3(0);
    auto* wall=physics.createRigidDynamic(PxTransform(PxVec3(0,5,0)-authoredOffset));
    wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    wall->setMass(2);wall->setMassSpaceInertiaTensor(PxVec3(1.0f/3));
    wall->setLinearDamping(0);wall->setAngularDamping(0);
    auto* shape=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
    shape->setLocalPose(PxTransform(authoredOffset));
    wall->setCMassLocalPose(PxTransform(authoredOffset));
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
    std::vector<PxRigidDynamic*> quiet;
    for(unsigned i=0;i<quietCount;++i) {
        auto* owner=physics.createRigidDynamic(PxTransform(PxVec3(100+float(i)*3,50,0)));
        owner->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        owner->setMass(2);owner->setMassSpaceInertiaTensor(PxVec3(1.0f/3));
        auto* piece=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        require(owner->attachShape(*piece),"quiet chunk setup failed");piece->release();
        scene.addActor(*owner);quiet.push_back(owner);
    }
    std::vector<PxRigidDynamic*> contactBodies;PxRigidStatic* contactFloor=nullptr;
    if(contactCount) {
        contactFloor=PxCreateStatic(physics,PxTransform(PxVec3(200+1.5f*(contactCount-1),99.5f,0)),
            PxBoxGeometry(1.5f*contactCount+1,.5f,2),context.material());
        require(contactFloor,"persistent-contact floor creation failed");scene.addActor(*contactFloor);
        for(unsigned i=0;i<contactCount;++i) {
            auto* body=PxCreateDynamic(physics,PxTransform(PxVec3(200+3*float(i),100.5f,0)),
                PxBoxGeometry(.5f,.5f,.5f),context.material(),2);
            require(body,"persistent-contact body creation failed");body->setLinearVelocity(PxVec3(.5f,0,0));
            body->setLinearDamping(0);body->setAngularDamping(0);scene.addActor(*body);contactBodies.push_back(body);
        }
    }
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"warmup failed");events.advances=0;
    const auto identity=scene.getDirectGPUAPI().getShapeContactIndex(*shape);
    auto& controller=*static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController());
    auto& shapeManager=controller.getSimulationCore()->mPxgShapeSimManager;
    const auto initialShapeUploads=shapeManager.getUploadedShapeCount();
    const auto initialBoundsUploads=controller.getSimulationCore()->getReboundShapeIndexUploadCount();
    nativeRefilterTest::Audit refilterAudit(scene);
    PxShape* projectileShape=nullptr;shot->getShapes(&projectileShape,1);
    const auto projectileShapeId=scene.getDirectGPUAPI().getShapeContactIndex(*projectileShape);
    auto& nativeShapes=static_cast<PxgNphaseImplementationContext*>(static_cast<NpScene&>(scene).getScScene().getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore()->mGpuShapesManager;
    const auto initialOwnerUploads=nativeShapes.mHostOwnerMappingUploads;
    const auto initialOwnerObservations=nativeShapes.mNativeOwnerObservations;
    PxgShapeSim originalShape;
    {PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(&originalShape,
        shapeManager.getShapeSimsDevicePtr()+identity*sizeof(PxgShapeSim),sizeof(originalShape)));}

    std::vector<PxDestructionStressChunk> chunks={{PxVec3(0,-1,0),0,0,0,PX_INVALID_U32},
        {PxVec3(0),2,1.0f/3,0,identity,1,0}};
    std::vector<PxDestructionChunkMassProperties> mass(2);mass[0].supported=1;mass[0].center[1]=-1;
    mass[1].mass=2;mass[1].inertia[0]=mass[1].inertia[1]=mass[1].inertia[2]=1.0/3;
    std::vector<PxDestructionStressCluster> clusters{{wall->getGPUIndex(),PxVec3(0)}};
    std::vector<PxU32> quietIdentities;
    for(unsigned i=0;i<quietCount;++i) {
        PxShape* piece=nullptr;quiet[i]->getShapes(&piece,1);
        const auto id=scene.getDirectGPUAPI().getShapeContactIndex(*piece);quietIdentities.push_back(id);
        chunks.push_back({PxVec3(0),0,0,i+1,id,1,0});
        PxDestructionChunkMassProperties properties{};properties.mass=2;properties.supported=1;
        properties.inertia[0]=properties.inertia[1]=properties.inertia[2]=1.0/3;mass.push_back(properties);
        clusters.push_back({quiet[i]->getGPUIndex(),PxVec3(0)});
    }
    if(massFrameWake) {
        mass[1].inertia[1]=.5;mass[1].inertia[2]=.2; // exercises a nonidentity principal frame
        for(unsigned i=0;i<2;++i) {chunks[i].position+=authoredOffset;for(unsigned k=0;k<3;++k)mass[i].center[k]+=authoredOffset[k];}
        clusters[0].centerOfMass=authoredOffset;
    }
    PxDestructionStressBond bond{0,1,authoredOffset+PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};
    PxDestructionMaterial material;if(gravity){material.compressionElasticLimit=100;material.compressionFatalLimit=200;}if(!fracture){material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;}
    PxDestructionStressDesc desc;desc.chunks=chunks.data();desc.chunkCount=PxU32(chunks.size());desc.chunkMassProperties=mass.data();
    desc.clusters=clusters.data();desc.clusterCount=PxU32(clusters.size());desc.bonds=&bond;desc.bondCount=1;
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;
    desc.preserveUnchangedContactPairs=reuse;
    auto* destruction=scene.getDestructionScene();require(destruction->configureStress(desc),"native correction configuration failed");
    CUdeviceptr index=0,value=0;CUevent inputsReady=nullptr;
    {PxScopedCudaLock lock(cuda);check(cuEventCreate(&inputsReady,CU_EVENT_DISABLE_TIMING));check(cuMemAlloc(&index,sizeof(PxU32)));check(cuMemAlloc(&value,sizeof(PxTransform)));}
    auto velocity=[&](PxRigidDynamic& body){
        PxScopedCudaLock lock(cuda);const auto id=body.getGPUIndex();check(cuMemcpyHtoD(index,&id,sizeof(id)));check(cuEventRecord(inputsReady,nullptr));
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(value),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY,1,inputsReady),"native velocity observation failed");
        check(cuCtxSynchronize());PxVec3 out;check(cuMemcpyDtoH(&out,value,sizeof(out)));return out;
    };
    auto cleanup=[&](){
        {PxScopedCudaLock lock(cuda);check(cuEventDestroy(inputsReady));check(cuMemFree(index));check(cuMemFree(value));}
        require(destruction->clearStress(),"native accepted-fragment teardown failed");
        for(auto* owner:quiet)owner->release();
        for(auto* body:contactBodies)body->release();if(contactFloor)contactFloor->release();
        wall->release();shot->release();sentinel->release();shape->release();sphere->release();
        require(context.healthy(),"native impact GPU health failed");
    };
    AllocationAudit allocations;
    unsigned corrections=0,contacts=0,observedNativeContacts=0;std::vector<PxVec3> contactMotion;
    for(unsigned frame=0;frame<30;++frame) {
        const auto before=events.advances;
        {PxScopedCudaLock lock(cuda);const auto id=sentinel->getGPUIndex();const PxVec3 force(1,0,0);
            check(cuMemcpyHtoD(index,&id,sizeof(id)));check(cuMemcpyHtoD(value,&force,sizeof(force)));check(cuEventRecord(inputsReady,nullptr));
            require(scene.getDirectGPUAPI().setRigidDynamicData(reinterpret_cast<void*>(value),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIWriteType::eFORCE,1,inputsReady),"ordinary force command failed");}
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
        verifyAcceptedContactIdentities(scene,cuda);
        require(status.converged,"native impact accepted unconverged stress");
        require(status.frame==frame+1,"correction counted as a second timestep");
        require(status.correctionPasses<=1,"native step exceeded one correction");
        require(events.advances==before+1,"trial pass duplicated pose callback");
        corrections+=status.correctionPasses;contacts+=status.normalContacts;
        if(shape->getActor()!=wall)
            observedNativeContacts+=nativeOwnerTest::observe(scene,cuda,identity,shape->getActor()->is<PxRigidDynamic>(),nativeShapes);
        // Track the entire contact trajectory, including persistence after correction.
        for(auto* body:contactBodies)contactMotion.push_back(velocity(*body));
        if(!status.correctionPasses)refilterAudit.verifyOrdinaryPass();
        if(status.correctionPasses) {
            refilterAudit.verify(*static_cast<PxgDestructionRuntime*>(destruction),cuda,identity,projectileShapeId,
                reuse && !controller.getDestructionContactReuseFallbackCount());
            require(status.normalContacts && status.brokenBonds,"fracture was not driven by actual solved contact impulses");
            auto* runtime=static_cast<PxgDestructionRuntime*>(destruction);
            require(runtime->correctionBodyCount()==2,"CPU owner bridge included unchanged clusters");
            require(controller.getSimulationCore()->getReboundShapeIndexUploadCount()==initialBoundsUploads,
                "native correction built/uploaded a CPU shape-bounds list");
            require(shapeManager.getUploadedShapeCount()==initialShapeUploads,
                "native correction re-uploaded persistent chunk geometry");
            PxgShapeSim resident;
            {PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(&resident,
                shapeManager.getShapeSimsDevicePtr()+identity*sizeof(PxgShapeSim),sizeof(resident)));}
            auto* owner=shape->getActor()->is<PxRigidDynamic>();
            require(owner && resident.mBodySimIndex.index()==owner->getGPUIndex(),
                "GPU shape owner differs from the committed fragment");
            require(nativeShapes.mNativeOwnerObservations>initialOwnerObservations
                && nativeShapes.mHostOwnerMappingUploads==initialOwnerUploads,
                "native fracture uploaded ownership through the CPU remap table");
            {PxScopedCudaLock lock(cuda);PxNodeIndex mapped;PxActor* oldActor=nullptr;
                check(cuMemcpyDtoH(&mapped,nativeShapes.mGpuShapesRemapTableBuffer.getDevicePtr()+identity*sizeof(mapped),sizeof(mapped)));
                check(cuMemcpyDtoH(&oldActor,nativeShapes.mGpuTransformCacheIdToActorTableBuffer.getDevicePtr()+identity*sizeof(oldActor),sizeof(oldActor)));
                require(mapped.index()==owner->getGPUIndex(),"narrowphase remap lost native GPU owner");
                require(oldActor==wall,"native simulation unnecessarily uploaded CPU actor observation");
                const PxU32 n=PxU32(nativeShapes.mMaxTransformCacheID+1);
                std::vector<PxNodeIndex> nodes(n);std::vector<PxU32> shapes(n);
                check(cuMemcpyDtoH(nodes.data(),nativeShapes.mGpuRigidIndiceBuffer.getDevicePtr(),n*sizeof(nodes[0])));
                check(cuMemcpyDtoH(shapes.data(),nativeShapes.mGpuShapeIndiceBuffer.getDevicePtr(),n*sizeof(shapes[0])));
                unsigned found=0;for(PxU32 i=0;i<n;++i)if(shapes[i]==identity) {
                    require(nodes[i].index()==owner->getGPUIndex(),"Direct GPU API shape index retained previous motion owner");++found;
                }
                require(found==1,"native shape missing or duplicated in sorted GPU ownership view");
            }
            require(resident.mTransform.p==originalShape.mTransform.p && resident.mTransform.q==originalShape.mTransform.q
                && resident.mLocalBounds.minimum==originalShape.mLocalBounds.minimum
                && resident.mLocalBounds.maximum==originalShape.mLocalBounds.maximum
                && resident.mHullDataIndex==originalShape.mHullDataIndex
                && resident.mShapeType==originalShape.mShapeType && resident.mShapeFlags==originalShape.mShapeFlags,
                "native ownership update changed immutable collision data");

            for(unsigned i=0;i<quietCount;++i) {
                const auto quietId=quiet[i]->getGPUIndex();
                for(PxU32 j=0;j<runtime->correctionBodyCount();++j)
                    require(runtime->correctionBodyIndices()[j]!=quietId,"quiet owner entered CPU correction work set");
                PxShape* piece=nullptr;quiet[i]->getShapes(&piece,1);
                require(piece->getActor()==quiet[i] && scene.getDirectGPUAPI().getShapeContactIndex(*piece)==quietIdentities[i],"quiet ownership changed during remote fracture");
                require(velocity(*quiet[i]).magnitudeSquared()==0,"remote fracture moved a quiet supported cluster");
            }
        }
        if(massFrameWake && corrections) {
            auto* owner=shape->getActor()->is<PxRigidDynamic>();PxgBodySim body;
            {PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(&body,
                CUdeviceptr(controller.getSimulationCore()->getBodySimBufferDevicePtr().getPointer()+owner->getGPUIndex()),sizeof(body)));}
            const auto local=body.body2Actor_maxImpulseW.getTransform();
            require(local.isValid() && body.body2World.getTransform().isValid(),"scheduler upload corrupted principal-frame orientation");
            require((local.p-authoredOffset).magnitude()<1e-5f,"scheduler upload replaced resident fragment COM with CPU placeholder");
            require(std::abs(body.linearVelocityXYZ_inverseMassW.w-.5f)<1e-5f,"scheduler upload replaced resident fragment mass");
            const auto inertia=body.inverseInertiaXYZ_contactReportThresholdW;
            require(std::abs(inertia.x-5)<1e-5f && std::abs(inertia.y-3)<1e-5f && std::abs(inertia.z-2)<1e-5f,
                "scheduler upload replaced resident fragment inertia");
            // Force a metadata upload without changing physical mass or motion.
            if(frame==15)owner->setWakeCounter(.8f);
        }
        require(scene.getDirectGPUAPI().getShapeContactIndex(*shape)==identity,"split recreated persistent chunk collision identity");
    }
    require(!speculative,"unsupported speculative CCD correction was silently accepted");
    const auto ordinary=velocity(*sentinel);
    require(std::abs(ordinary.x-.5f)<2e-4f,"correction duplicated or lost an ordinary body's force command");
    require(std::abs(ordinary.y-(gravity?-9.81f*31/60:0))<2e-4f,"correction integrated gravity more than once");
    if(fracture)require(observedNativeContacts>0,"fixture did not observe contacts with the committed native fragment");
    auto* fragment=shape->getActor()->is<PxRigidDynamic>();require(fragment,"accepted chunk has no motion owner");
    require((fragment!=wall)==fracture,"native split did not change chunk motion ownership");
    const auto v=velocity(*shot),w=velocity(*fragment);require(v.isFinite() && w.isFinite(),"nonfinite accepted motion");
    if(fracture){require(corrections==1,"single bond did not produce exactly one correction");require(w.x>1 && v.x>1,"corrected projectile did not transfer motion to fragment");require(std::abs(2*v.x+2*w.x-24)<.02f,"native correction changed linear momentum");}
    else require(!corrections && contacts,"intact control missed the impact");
    // A private fragment has no public actor-array index. Query registration
    // must use the actor/shape map, not grow a dense cache to the unused index.
    require(allocations.largest.load()<256u*1024u*1024u,"tiny native impact allocated an oversized actor query cache");
    PxTransform pose;
    {PxScopedCudaLock lock(cuda);const auto id=fragment->getGPUIndex();check(cuMemcpyHtoD(index,&id,sizeof(id)));check(cuEventRecord(inputsReady,nullptr));
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(value),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,1,inputsReady),"fragment pose observation failed");
        check(cuCtxSynchronize());check(cuMemcpyDtoH(&pose,value,sizeof(pose)));}
    // Explicit test observation: this checks query membership and lookup, not
    // automatic CPU pose freshness (outside the native awake-rigid MVP).
    static_cast<NpScene&>(scene).getSQAPI().updateSQShape(*fragment,*shape,pose*shape->getLocalPose());
    for(bool cached:{false,true}) {
        PxRaycastBuffer hit;PxQueryCache cache;cache.actor=fragment;cache.shape=shape;
        require(scene.raycast((pose*shape->getLocalPose()).p+PxVec3(0,2,0),PxVec3(0,-1,0),3,hit,PxHitFlag::eDEFAULT,PxQueryFilterData(),nullptr,cached?&cache:nullptr)
            && hit.hasBlock && hit.block.actor==fragment && hit.block.shape==shape,"accepted fragment query lookup lost its private owner");
    }
    require(scene.getNbActors(PxActorTypeFlag::eRIGID_DYNAMIC)==3+quietCount+contactCount,"query registration published a private fragment as a public actor");
    std::printf("native query ownership valid; largest impact allocation=%zu bytes\n",allocations.largest.load());
    const auto constructedPairs=controller.getDestructionContactInputCount();
    const auto reuseFallbacks=controller.getDestructionContactReuseFallbackCount();
    cleanup();
    return {v.x,corrections,contacts,constructedPairs,contactMotion,reuseFallbacks};
}
struct RepeatedResult {std::vector<unsigned> fractureSteps;std::vector<PxVec3> trajectory;};
RepeatedResult repeatedImpacts(bool reuse,bool gpuRepair=false,bool preSolve=false,bool contacts=false,bool support=false,bool ownership=false,bool retainedFixture=false) {
    Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&events,true,true,false,false);
    auto& scene=context.scene();auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    std::vector<PxRigidDynamic*> walls,shots,ordinary;std::vector<PxShape*> shapes;
    std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionChunkMassProperties> mass;
    std::vector<PxDestructionStressBond> bonds;
    for(unsigned i=0;i<2;++i) {
        const PxVec3 origin(0,10,10*float(i));
        auto* wall=PxCreateDynamic(physics,PxTransform(origin),PxBoxGeometry(.5f,.5f,.5f),context.material(),2);
        require(wall,"repeat wall allocation failed");wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        wall->setLinearDamping(0);wall->setAngularDamping(0);scene.addActor(*wall);walls.push_back(wall);
        PxShape* shape=nullptr;wall->getShapes(&shape,1);shape->acquireReference();shapes.push_back(shape);
        auto* shot=PxCreateDynamic(physics,PxTransform(origin+PxVec3(-2-2*float(i),0,0)),PxSphereGeometry(.2f),context.material(),1);
        require(shot,"repeat projectile allocation failed");shot->setMass(2);shot->setMassSpaceInertiaTensor(PxVec3(.032f));
        shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(PxVec3(12,0,0));scene.addActor(*shot);shots.push_back(shot);
        chunks.push_back({PxVec3(0,-1,0),0,0,i,PX_INVALID_U32});
        chunks.push_back({PxVec3(0),2,1.0f/3,i,PX_INVALID_U32,1,0});
        PxDestructionChunkMassProperties support{},piece{};support.supported=1;support.center[1]=-1;
        piece.mass=2;piece.inertia[0]=piece.inertia[1]=piece.inertia[2]=1.0/3;mass.push_back(support);mass.push_back(piece);
        bonds.push_back({2*i,2*i+1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1});
    }
    for(unsigned i=0;i<4;++i) {
        auto* body=PxCreateDynamic(physics,PxTransform(PxVec3(100+3*float(i),.5f,0)),PxBoxGeometry(.5f,.5f,.5f),context.material(),2);
        require(body,"repeat friction participant allocation failed");body->setLinearDamping(0);body->setAngularDamping(0);
        body->setLinearVelocity(PxVec3(.5f,0,0));scene.addActor(*body);ordinary.push_back(body);
    }
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"repeat warmup failed");
    PxDestructionStressCluster clusters[2];
    for(unsigned i=0;i<2;++i){chunks[2*i+1].contactIndex=scene.getDirectGPUAPI().getShapeContactIndex(*shapes[i]);clusters[i]={walls[i]->getGPUIndex(),PxVec3(0)};}
    PxDestructionMaterial material;material.compressionElasticLimit=100;material.compressionFatalLimit=200;
    PxDestructionStressDesc desc;desc.chunks=chunks.data();desc.chunkCount=4;desc.chunkMassProperties=mass.data();desc.clusters=clusters;desc.clusterCount=2;
    desc.bonds=bonds.data();desc.bondCount=2;desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
    desc.internalCorrectionLimit=1;desc.preserveUnchangedContactPairs=reuse;desc.gpuIslandRepair=gpuRepair;
    auto* destruction=scene.getDestructionScene();require(destruction->configureStress(desc),"repeat configuration failed");
    CUdeviceptr ids=0,data=0;CUevent uploaded=nullptr;
    {PxScopedCudaLock lock(cuda);check(cuMemAlloc(&ids,sizeof(PxU32)));check(cuMemAlloc(&data,sizeof(PxTransform)));check(cuEventCreate(&uploaded,CU_EVENT_DISABLE_TIMING));}
    auto observe=[&](PxRigidDynamic* body,PxRigidDynamicGPUAPIReadType::Enum type){
        PxScopedCudaLock lock(cuda);const auto id=body->getGPUIndex();check(cuMemcpyHtoD(ids,&id,sizeof(id)));check(cuEventRecord(uploaded,nullptr));
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(data),reinterpret_cast<const PxU32*>(ids),type,1,uploaded),"repeat GPU observation failed");
        check(cuCtxSynchronize());if(type==PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE){PxTransform pose;check(cuMemcpyDtoH(&pose,data,sizeof(pose)));return pose.p;}
        PxVec3 out;check(cuMemcpyDtoH(&out,data,sizeof(out)));return out;
    };
    auto& gpu=*static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext());
    gpu.enableCudaPreSolveSupport(support);gpu.enableCudaPreSolveContacts(contacts);gpu.enableCudaPreSolveIslands(preSolve);gpu.captureSolverIslandMetadata(preSolve);gpu.enableDeviceConnectivityOwnership(ownership);
    auto& auditIslands=*static_cast<NpScene&>(scene).getScScene().getSimpleIslandManager();
    auditIslands.getAccurateIslandSim().setGpuComponentAudit(gpuRepair);
    auditIslands.getSpeculativeIslandSim().setGpuComponentAudit(gpuRepair);
    // Deterministic managerless speculative edge alongside real impacts.
    // Do not depend on erroneous fragment sleeping to create this lifecycle case.
    const auto retainedEdge=retainedFixture?auditIslands.addContactManager(nullptr,
        PxNodeIndex(ordinary[0]->getGPUIndex()),PxNodeIndex(ordinary[1]->getGPUIndex()),nullptr,IG::Edge::eCONTACT_MANAGER):IG_INVALID_EDGE;
    RepeatedResult result;PxU64 graphGeneration=0;
    auto& graphCore=*static_cast<PxgNphaseImplementationContext*>(static_cast<NpScene&>(scene).getScScene().getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
    const PxU64 graphBuildsBefore=graphCore.getDestructionGraphBuildCount(),graphReusesBefore=graphCore.getDestructionGraphReuseCount();
    for(unsigned frame=0;frame<60;++frame) {
        scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error) && !error,"repeat correction incomplete");
        const auto status=destruction->getLastStatus();require(!status.error && status.converged && status.frame==frame+1 && status.correctionPasses<=1,"repeat stage invariant failed");
        require(!auditIslands.getAccurateIslandSim().getGpuComponentAuditFailures()
            && !auditIslands.getSpeculativeIslandSim().getGpuComponentAuditFailures(),"repeat pre-mutation graph audit failed");
        verifyAcceptedContactIdentities(scene,cuda);if(preSolve)nativePreSolveTest::verify(gpu,cuda);
        const auto generation=static_cast<PxgDestructionRuntime*>(destruction)->getContactGraphView().generation;
        require(generation==graphGeneration+1+status.correctionPasses,"contact graph rebuilt twice or reused across a trial/correction boundary");graphGeneration=generation;
        if(status.correctionPasses){require(status.normalContacts && status.brokenBonds==1,"repeat fracture lacks single actual impact verdict");result.fractureSteps.push_back(frame);}
        for(auto* body:ordinary){result.trajectory.push_back(observe(body,PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE));result.trajectory.push_back(observe(body,PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY));}
        for(unsigned i=0;i<2;++i){result.trajectory.push_back(observe(shots[i],PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY));result.trajectory.push_back(observe(shapes[i]->getActor()->is<PxRigidDynamic>(),PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY));}
    }
    require(result.fractureSteps.size()==2 && result.fractureSteps[1]>result.fractureSteps[0],"fixture did not correct two separate timesteps");
    for(unsigned i=0;i<2;++i){auto* fragment=shapes[i]->getActor()->is<PxRigidDynamic>();require(fragment && fragment!=walls[i],"repeat fragment ownership missing");
        const auto a=observe(shots[i],PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY),b=observe(fragment,PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY);
        require(std::abs(2*a.x+2*b.x-24)<.02f,"repeat correction changed projectile/fragment momentum");}
    require(graphCore.getDestructionGraphBuildCount()-graphBuildsBefore==62,"repeat fixture did not build exactly one graph per NP pass");
    require(graphCore.getDestructionGraphReuseCount()-graphReusesBefore==(gpuRepair?62u:0u),"same-pass graph reuse missing or active in reference mode");
    if(gpuRepair && !ownership) {
        const auto& islands=*static_cast<NpScene&>(scene).getScScene().getSimpleIslandManager();
        const auto& a=islands.getAccurateIslandSim();const auto& s=islands.getSpeculativeIslandSim();
        std::printf("GPU island repair repeated impact: routes=%llu splits=%llu fallbacks=%llu\n",
            (unsigned long long)(a.getGpuRouteCount()+s.getGpuRouteCount()),
            (unsigned long long)(a.getGpuSplitCount()+s.getGpuSplitCount()),
            (unsigned long long)(a.getGpuRepairFallbackCount()+s.getGpuRepairFallbackCount()));
        require(a.getGpuRouteCount()+s.getGpuRouteCount()+a.getGpuSplitCount()+s.getGpuSplitCount()>0,"GPU island repair never consumed the CUDA partitions");
        require(a.getGpuRepairFallbackCount()+s.getGpuRepairFallbackCount()==0,"supported fixture fell back to CPU routing");
    }
    if(ownership)require(gpu.getIslandManager().mDeviceConnectivityPasses>50,"repeated impacts did not use device connectivity ownership");
    if(support)require(gpu.getCudaPreSolveSupportPasses()>50,"repeated impacts did not use GPU support producer");
    if(contacts)require(gpu.getCudaPreSolveContactPasses()>50,"repeated impacts did not use GPU contact producer");
    if(preSolve)require(gpu.getCudaPreSolvePasses()>50,"repeated-impact fixture did not consume CUDA-produced solver state");
    if(retainedFixture) {
        const auto stats=static_cast<PxgDestructionRuntime*>(destruction)->getContactGraphObservationStats();
        require(stats.peakRetainedEdges>0 && stats.retainedEdgesUploaded>0,"real fracture did not exercise the retained-edge fixture");
        auditIslands.removeConnection(retainedEdge);
    }
    require(destruction->clearStress(),"repeat cleanup failed");for(auto* shape:shapes)shape->release();for(auto* body:walls)body->release();for(auto* body:shots)body->release();for(auto* body:ordinary)body->release();
    {PxScopedCudaLock lock(cuda);check(cuEventDestroy(uploaded));check(cuMemFree(ids));check(cuMemFree(data));}
    require(context.healthy(),"repeat GPU health failed");return result;
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
int main(int argc,char** argv){try {
    if(argc==2 && std::string(argv[1])=="--retained-fracture") {
        repeatedImpacts(true,true,true,true,true,true,true);
        std::puts("Real fracture with deterministic retained speculative edges and exact graph audits passed");return 0;
    }
    require(argc==1,"unknown resimulation test option");
    const auto rebuilt=impact(true,true,false,0,false,32),reused=impact(true,true,false,0,true,32);
    require(std::abs(rebuilt.projectileVelocity-reused.projectileVelocity)<.02f && rebuilt.corrections==reused.corrections,
        "pair reuse changed controlled fracture/projectile response");
    require(rebuilt.contactMotion.size()==32*30 && rebuilt.contactMotion.size()==reused.contactMotion.size(),
        "pair reuse fixture did not observe every ordinary contact participant");
    for(unsigned i=0;i<rebuilt.contactMotion.size();++i)
        require((rebuilt.contactMotion[i]-reused.contactMotion[i]).magnitude()<2e-4f,
            "pair reuse changed ordinary friction contact response during correction");
    require(rebuilt.constructedPairs>=reused.constructedPairs+32,
        "pair reuse still rebuilt unchanged ordinary contact managers");
    const auto fallback=impact(true,true,false,0,true,32,true);
    require(fallback.reuseFallbacks==1 && fallback.constructedPairs==rebuilt.constructedPairs
        && std::abs(fallback.projectileVelocity-rebuilt.projectileVelocity)<.02f,
        "contact callback scene failed to use the complete correction fallback");
    std::printf("native pair reuse: reference constructions=%llu reuse=%llu; 32 friction participants match over all 30 steps\n",
        (unsigned long long)rebuilt.constructedPairs,(unsigned long long)reused.constructedPairs);
    impact(true,true,false,0,true,0,false,true);
    const auto repeatReference=repeatedImpacts(false),repeatReuse=repeatedImpacts(true);
    // Once the first projectile/fragment contact separates, a falling fragment
    // must keep integrating gravity. Inactive allocation flags used to freeze it.
    for(unsigned frame=21;frame<60;++frame) {
        const float dv=repeatReference.trajectory[frame*12+9].y-repeatReference.trajectory[(frame-1)*12+9].y;
        require(std::abs(dv+9.81f/60)<2e-4f,"separated fragment stopped integrating gravity in a sleeping-disabled scene");
    }
    require(repeatReference.fractureSteps==repeatReuse.fractureSteps && repeatReference.trajectory.size()==repeatReuse.trajectory.size(),"pair reuse changed repeated fracture decisions");
    for(unsigned i=0;i<repeatReference.trajectory.size();++i)require((repeatReference.trajectory[i]-repeatReuse.trajectory[i]).magnitude()<2e-4f,"pair reuse changed repeated-impact trajectory");
    std::printf("native repeated correction: matching fracture steps %u and %u; %zu trajectory samples match\n",repeatReference.fractureSteps[0],repeatReference.fractureSteps[1],repeatReference.trajectory.size());
    const auto repeatGpu=repeatedImpacts(true,true);
    require(repeatGpu.fractureSteps==repeatReuse.fractureSteps && repeatGpu.trajectory.size()==repeatReuse.trajectory.size(),"GPU island repair changed fracture decisions");
    for(unsigned i=0;i<repeatGpu.trajectory.size();++i)require((repeatGpu.trajectory[i]-repeatReuse.trajectory[i]).magnitude()<2e-4f,"GPU island repair changed repeated-impact trajectory");
    const auto repeatProducer=repeatedImpacts(true,true,true);
    require(repeatProducer.fractureSteps==repeatReuse.fractureSteps && repeatProducer.trajectory.size()==repeatReuse.trajectory.size(),"CUDA pre-solve producer changed fracture decisions");
    for(unsigned i=0;i<repeatProducer.trajectory.size();++i)require((repeatProducer.trajectory[i]-repeatReuse.trajectory[i]).magnitude()<2e-4f,"CUDA pre-solve producer changed repeated-impact trajectory");
    const auto repeatContacts=repeatedImpacts(true,true,true,true);
    require(repeatContacts.fractureSteps==repeatReuse.fractureSteps && repeatContacts.trajectory.size()==repeatReuse.trajectory.size(),"CUDA pre-solve producer changed fracture decisions");
    for(unsigned i=0;i<repeatContacts.trajectory.size();++i)require((repeatContacts.trajectory[i]-repeatReuse.trajectory[i]).magnitude()<2e-4f,"CUDA pre-solve producer changed repeated-impact trajectory");
    const auto repeatSupport=repeatedImpacts(true,true,true,true,true);
    require(repeatSupport.fractureSteps==repeatReuse.fractureSteps && repeatSupport.trajectory.size()==repeatReuse.trajectory.size(),"CUDA pre-solve producer changed fracture decisions");
    for(unsigned i=0;i<repeatSupport.trajectory.size();++i)require((repeatSupport.trajectory[i]-repeatReuse.trajectory[i]).magnitude()<2e-4f,"CUDA pre-solve producer changed repeated-impact trajectory");
    const auto repeatOwner=repeatedImpacts(true,true,true,true,true,true);
    require(repeatOwner.fractureSteps==repeatReuse.fractureSteps && repeatOwner.trajectory.size()==repeatReuse.trajectory.size(),"device connectivity ownership changed fracture decisions");
    for(unsigned i=0;i<repeatOwner.trajectory.size();++i) {
        const auto a=repeatOwner.trajectory[i],b=repeatReuse.trajectory[i];
        if((a-b).magnitude()>=2e-4f)std::fprintf(stderr,"ownership trajectory step=%u sample=%u GPU=(%g,%g,%g) reference=(%g,%g,%g) error=%g\n",i/12,i%12,a.x,a.y,a.z,b.x,b.y,b.z,(a-b).magnitude());
        require((a-b).magnitude()<2e-4f,"device connectivity ownership changed repeated-impact trajectory");
    }
    std::printf("Device connectivity ownership: reference fracture decisions and %zu trajectory samples match\n",repeatOwner.trajectory.size());
    std::printf("CUDA pre-solve producer: reference fracture decisions and %zu trajectory samples match\n",repeatProducer.trajectory.size());
    unconvergedStress();const auto intact=impact(false),broken=impact(true);impact(true,true);impact(true,false,true);const auto sparse=impact(true,false,false,128);require(std::abs(sparse.projectileVelocity-broken.projectileVelocity)<.02f && sparse.corrections==broken.corrections,"unrelated clusters changed the impact response");require(broken.projectileVelocity>intact.projectileVelocity+1,"correction did not change projectile response relative to intact wall");std::printf("NATIVE RESIM PASS: intact projectile=%g fractured projectile=%g corrections=%u\n",intact.projectileVelocity,broken.projectileVelocity,broken.corrections);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
