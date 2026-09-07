// Native PxScene fracture task owns allocation; the application never allocates
// candidate actors or reads graph/motion data to drive this transaction.
#include "../physx_scene.h"
#include "NpScene.h"
#include "NpDestructionBodyAllocator.h"
#include "NpRigidDynamic.h"
#include "ScBodySim.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include <cmath>
#include <cstring>
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
void near(float a,float b,const char* message){
    if(!std::isfinite(a) || !std::isfinite(b) || std::abs(a-b)>2e-4f*PxMax(1.0f,std::abs(b))) {
        std::fprintf(stderr,"%s: %g != %g\n",message,a,b);throw std::runtime_error(message);
    }
}
void check(CUresult result){require(result==CUDA_SUCCESS,"CUDA observation failed");}
void step(PxScene& scene){scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"ordinary step failed");}
struct Deleted : PxDeletionListener {
    unsigned count=0;
    void onRelease(const PxBase*,void*,PxDeletionEventFlag::Enum) override {++count;}
};
void run(bool sleeping,bool accelerations) {
    blast_demo::SceneCapacity capacity;blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,sleeping,sleeping,PxSolverType::eTGS,accelerations);
    auto& scene=context.scene();auto& internal=static_cast<NpScene&>(scene);auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    auto& controller=*static_cast<PxgSimulationController*>(internal.getScScene().getSimulationController());
    auto& core=*controller.getSimulationCore();
    scene.setGravity(PxVec3(0,-9.81f,0));
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(0,20,0)));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    parent->setLinearDamping(.17f);parent->setAngularDamping(.31f);
    parent->setMaxLinearVelocity(123);parent->setMaxAngularVelocity(45);
    parent->setMaxDepenetrationVelocity(7);parent->setMaxContactImpulse(19);
    parent->setContactReportThreshold(2.3f);parent->setStabilizationThreshold(.012f);parent->setSleepThreshold(.021f);
    auto* shape=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);require(parent->attachShape(*shape),"geometry setup failed");shape->release();
    scene.addActor(*parent);step(scene);auto* stage=scene.getDestructionScene();require(stage,"native scene missing");
    const auto parentIndex=parent->getGPUIndex();const auto shapeIndex=scene.getDirectGPUAPI().getShapeContactIndex(*shape);
    Deleted deleted;physics.registerDeletionListener(deleted,PxDeletionEventFlag::eUSER_RELEASE|PxDeletionEventFlag::eMEMORY_RELEASE);
    float expectedLinearDamping=.17f;
    auto configure=[&](unsigned n,bool fractures,bool reverseSupport=false){
        std::vector<PxDestructionStressChunk> chunks(n);std::vector<PxDestructionChunkMassProperties> mass(n);
        std::vector<PxDestructionStressBond> bonds(n-1);
        for(unsigned i=0;i<n;++i) {
            const bool supported=reverseSupport?i==n-1:i==0;
            const PxVec3 position(0,float(i),0);chunks[i]={position,supported?0.0f:1.0f,supported?0.0f:1.0f,0,PX_INVALID_U32};
            mass[i]={};mass[i].center[1]=i;mass[i].mass=supported?0:1;mass[i].supported=supported?1:0;
            mass[i].inertia[0]=mass[i].inertia[1]=mass[i].inertia[2]=supported?0:1;
            if(i)bonds[i-1]={0,i,position*.5f,PxVec3(0,1,0),1,1,1};
        }
        const PxDestructionStressCluster cluster{parentIndex,PxVec3(0)};PxDestructionMaterial material;
        if(!fractures){material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;}
        PxDestructionStressDesc desc;desc.chunks=chunks.data();desc.chunkCount=n;desc.chunkMassProperties=mass.data();desc.bonds=bonds.data();desc.bondCount=n-1;
        desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
        require(stage->configureStress(desc),"native allocation graph configuration failed");
        auto invalid=desc;auto bad=cluster;bad.body=0xfffffffeu;invalid.clusters=&bad;
        require(!stage->configureStress(invalid),"unallocated GPU body index accepted as a source");
    };
    auto observe=[&](unsigned n){
        const auto view=stage->getDeviceView();require(view.bodyAllocation && view.trialBodyIndices,"allocation device view missing");
        PxDestructionBodyAllocationStatus status;PxDestructionTopologyStatus accepted;std::vector<PxU32> indices(n);
        {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));
            check(cuMemcpyDtoH(&status,reinterpret_cast<CUdeviceptr>(view.bodyAllocation),sizeof(status)));
            check(cuMemcpyDtoH(&accepted,reinterpret_cast<CUdeviceptr>(view.acceptedTopology.status),sizeof(accepted)));
            require(status.valid && !status.error && status.count==n && status.reserved==n-1 && status.initialized==n-1 && !status.initializationError && status.generation==1,"native reservation batch mismatch");
            check(cuMemcpyDtoH(indices.data(),reinterpret_cast<CUdeviceptr>(view.trialBodyIndices),n*sizeof(PxU32)));
        }
        require(!accepted.generation && accepted.clusterCount==1,"reservation committed fracture topology");
        require(indices[0]==parentIndex,"existing owner was needlessly replaced");
        require(internal.getNbDestructionBodyCandidates()==n-1,"native candidate count mismatch");
        require(scene.getNbActors(PxActorTypeFlag::eRIGID_DYNAMIC)==1,"uncommitted reservations published as actors");
        require(parent->getNbShapes()==1 && shape->getActor()==parent && scene.getDirectGPUAPI().getShapeContactIndex(*shape)==shapeIndex,"reservation changed persistent geometry ownership");
        for(unsigned i=1;i<n;++i) {
            auto* candidate=internal.getDestructionBodyCandidate(i);require(candidate,"native BodySim reservation missing");
            require(candidate->getNpScene()==&internal && candidate->getCore().getInternalIslandNodeIndex().index()==indices[i],"reserved node mapping invalid");
            require(candidate->getCore().getSim() && !candidate->getCore().getSim()->isActive() && !candidate->getShapeManager().getNbShapes(),"reserved candidate participates in ordinary dynamics");
            require(indices[i]!=parentIndex,"candidate aliased accepted motion owner");
            PxgBodySim physical;{PxScopedCudaLock lock(cuda);
                check(cuMemcpyDtoH(&physical,CUdeviceptr(core.getBodySimBufferDevicePtr().getPointer()+indices[i]),sizeof(physical)));
                if(accelerations) {
                    PxgBodySimVelocities previous;PxgRigidBodyAcceleration acceleration;
                    check(cuMemcpyDtoH(&previous,CUdeviceptr(core.getBodySimPrevVelocitiesBufferDevicePtr().getPointer()+indices[i]),sizeof(previous)));
                    check(cuMemcpyDtoH(&acceleration,CUdeviceptr(core.getRigidBodyAccelerationsDevice()+indices[i]),sizeof(acceleration)));
                    require(!std::memcmp(&previous.linearVelocity,&physical.linearVelocityXYZ_inverseMassW,sizeof(float4))
                        && !std::memcmp(&previous.angularVelocity,&physical.angularVelocityXYZ_maxPenBiasW,sizeof(float4)),"new body acceleration history mismatch");
                    require(acceleration.linear.isZero() && acceleration.angular.isZero(),"new body has a fictitious acceleration spike");
                }
            }
            near(physical.body2World.p.x,0,"initialized COM x");near(physical.body2World.p.y,20+float(i),"initialized COM y");
            near(physical.body2Actor_maxImpulseW.p.y,float(i),"initialized local COM");near(physical.linearVelocityXYZ_inverseMassW.w,1,"initialized inverse mass");
            near(physical.inverseInertiaXYZ_contactReportThresholdW.x,1,"initialized inverse inertia");
            const auto limits=physical.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW;
            near(limits.x,123*123,"inherited linear limit");near(limits.y,45*45,"inherited angular limit");
            near(limits.z,expectedLinearDamping,"inherited linear damping");near(limits.w,.31f,"inherited angular damping");
            near(physical.angularVelocityXYZ_maxPenBiasW.w,-7,"inherited depenetration setting");
            near(physical.body2Actor_maxImpulseW.p.w,19,"inherited contact impulse setting");
            near(physical.inverseInertiaXYZ_contactReportThresholdW.w,2.3f,"inherited contact report threshold");
            near(physical.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.x,.012f,"inherited stabilization threshold");
            near(physical.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.z,.021f,"inherited sleep threshold");
            require(!(candidate->getCore().getSim()->getLowLevelBody().mInternalFlags&PxsRigidBody::eFIRST_BODY_COPY_GPU),"placeholder first upload remained pending");
            require(!controller.getBodySimManager().mUpdatedMap.boundedTest(indices[i]),"placeholder update remained queued");
        }
        require(!deleted.count,"private allocation leaked a user deletion event");return indices;
    };
    auto fracture=[&]{scene.simulate(1.0f/60);PxU32 error=0;require(!scene.fetchResults(true,&error)&&error&&stage->getLastStatus().error==8,"unimplemented correction falsely completed or reservation failed");};
    configure(2,false);step(scene);require(!internal.getNbDestructionBodyCandidates(),"intact cluster allocated per-chunk motion slots");
    configure(2,true);fracture();const auto first=observe(2);
    // An uncommitted slot must not be accepted as a new graph's source:
    // reconfiguration would release that reservation while retaining its ID.
    PxDestructionStressChunk privateChunk{PxVec3(0),1,1,0,PX_INVALID_U32};
    PxDestructionStressCluster privateBinding{first[1],PxVec3(0)};
    PxDestructionStressDesc privateDesc;privateDesc.chunks=&privateChunk;privateDesc.chunkCount=1;
    privateDesc.clusters=&privateBinding;privateDesc.clusterCount=1;
    require(!stage->configureStress(privateDesc),"uncommitted reserved node accepted as a source body");
    require(observe(2)==first,"rejected source binding changed pending reservations");
    physics.unregisterDeletionListener(deleted);
    auto* removed=physics.createRigidDynamic(PxTransform(PxIdentity));scene.addActor(*removed);
    const PxU32 removedIndex=removed->getGPUIndex();removed->release();
    physics.registerDeletionListener(deleted,PxDeletionEventFlag::eUSER_RELEASE|PxDeletionEventFlag::eMEMORY_RELEASE);
    privateBinding.body=removedIndex;
    require(!stage->configureStress(privateDesc),"released source survived deferred island-node deletion");
    require(observe(2)==first,"rejected deleted source changed reservations");
    for(unsigned i=0;i<3;++i){fracture();require(observe(2)==first,"identical verdict retry replaced its reserved node IDs");}
    if(sleeping) {
        // Kinematic property edits previously changed only the CPU backup. They
        // must now reach the GPU without disturbing its effective zero damping.
        expectedLinearDamping=.29f;parent->setLinearDamping(expectedLinearDamping);fracture();observe(2);
        PxgBodySim source;{PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(&source,CUdeviceptr(core.getBodySimBufferDevicePtr().getPointer()+parentIndex),sizeof(source)));}
        near(source.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW.z,0,"kinematic effective damping changed");
        near(source.dynamicLimitsDamping.z,expectedLinearDamping,"kinematic dynamic settings stale on GPU");
    }
    // Clear a GPU-initialized reservation before the next step, then grow
    // far past the first request. No truncation and no public actor inflation.
    configure(257,true);require(!internal.getNbDestructionBodyCandidates(),"reconfiguration retained old reservations");fracture();const auto grown=observe(257);
    fracture();require(observe(257)==grown,"grown reservations were not reused");
    configure(3,true);fracture();observe(3);
    configure(2,true,true);fracture();
    {const auto view=stage->getDeviceView();PxU32 ids[2];PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));
        check(cuMemcpyDtoH(ids,CUdeviceptr(view.trialBodyIndices),sizeof(ids)));PxgBodySim support;
        check(cuMemcpyDtoH(&support,CUdeviceptr(core.getBodySimBufferDevicePtr().getPointer()+ids[1]),sizeof(support)));
        require(internal.getDestructionBodyCandidate(1)->getCore().getFlags()&PxRigidBodyFlag::eKINEMATIC,"supported candidate lost kinematic reservation");
        require(support.linearVelocityXYZ_inverseMassW.w==0 && support.inverseInertiaXYZ_contactReportThresholdW.x==0
            && support.inverseInertiaXYZ_contactReportThresholdW.y==0 && support.inverseInertiaXYZ_contactReportThresholdW.z==0,"supported native slot has nonzero inverse mass/inertia");
        near(support.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW.z,0,"supported native slot has dynamic damping");}
    require(stage->clearStress(),"clear native graph failed");require(!internal.getNbDestructionBodyCandidates() && !deleted.count,"clear leaked reservations or trial events");
    step(scene);require(!deleted.count,"delayed private deletion event leaked after upload");
    // Only one split among many existing clusters: the GPU returns one body
    // allocation request and retains every other node binding on device.
    constexpr unsigned retained=64;
    std::vector<PxRigidDynamic*> unchanged;std::vector<PxDestructionStressCluster> clusterBindings(1+retained);
    clusterBindings[0]={parentIndex,PxVec3(0)};
    for(unsigned i=0;i<retained;++i) {
        auto* actor=physics.createRigidDynamic(PxTransform(PxVec3(float(i),50,0)));
        actor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*actor);unchanged.push_back(actor);
        clusterBindings[i+1]={actor->getGPUIndex(),PxVec3(0)};
    }
    step(scene);
    std::vector<PxDestructionStressChunk> quietChunks(2+retained);
    std::vector<PxDestructionChunkMassProperties> quietMass(2+retained);
    for(unsigned i=0;i<quietChunks.size();++i) {
        quietChunks[i]={PxVec3(0),i==1?1.0f:0.0f,i==1?1.0f:0.0f,i<2?0:i-1,PX_INVALID_U32};
        quietMass[i]={};quietMass[i].mass=i==1?1:0;quietMass[i].supported=i==1?0:1;
        for(unsigned k=0;k<3;++k)quietMass[i].inertia[k]=i==1?1:0;
    }
    quietChunks[0].position.y=-1;quietMass[0].center[1]=-1;
    PxDestructionStressBond quietBond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};PxDestructionMaterial quietMaterial;
    PxDestructionStressDesc quietDesc;quietDesc.chunks=quietChunks.data();quietDesc.chunkCount=unsigned(quietChunks.size());quietDesc.chunkMassProperties=quietMass.data();
    quietDesc.clusters=clusterBindings.data();quietDesc.clusterCount=unsigned(clusterBindings.size());quietDesc.bonds=&quietBond;quietDesc.bondCount=1;
    quietDesc.materials=&quietMaterial;quietDesc.materialCount=1;require(stage->configureStress(quietDesc),"quiet world configuration failed");fracture();
    const auto quietView=stage->getDeviceView();PxDestructionBodyAllocationStatus quietAllocation;PxDestructionBodyPreparationStatus quietPreparation;PxU32 quietIndices[retained+2];
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(quietView.readyEvent));
        check(cuMemcpyDtoH(&quietAllocation,reinterpret_cast<CUdeviceptr>(quietView.bodyAllocation),sizeof(quietAllocation)));
        check(cuMemcpyDtoH(&quietPreparation,reinterpret_cast<CUdeviceptr>(quietView.bodyPreparation),sizeof(quietPreparation)));
        check(cuMemcpyDtoH(quietIndices,reinterpret_cast<CUdeviceptr>(quietView.trialBodyIndices),sizeof(quietIndices)));}
    require(quietAllocation.valid && quietAllocation.count==retained+2 && quietAllocation.reserved==1 && quietAllocation.initialized==1 && !quietAllocation.initializationError && quietPreparation.allocationRequests==1,
        "unchanged clusters entered the host allocation request set");
    require(quietIndices[0]==parentIndex && quietIndices[1]!=parentIndex && internal.getNbDestructionBodyCandidates()==1,"sparse split reservation mapping failed");
    for(unsigned i=0;i<retained;++i)require(quietIndices[i+2]==clusterBindings[i+1].body,"unchanged cluster binding was replaced");
    require(scene.getNbActors(PxActorTypeFlag::eRIGID_DYNAMIC)==retained+1 && !deleted.count,"sparse split published trial actors/events");
    require(stage->clearStress() && !internal.getNbDestructionBodyCandidates() && !deleted.count,"sparse split cleanup leaked");
    physics.unregisterDeletionListener(deleted);for(auto* actor:unchanged)actor->release();parent->release();require(context.healthy(),"native allocation GPU health failed");
    std::puts("native cluster allocation: intact no allocation, real node reservations, unchanged owner reuse, retry stability, 256-child growth, pending-upload removal, private actor/event isolation passed");
}
void moving(PxSolverType::Enum solver) {
    blast_demo::SceneCapacity capacity;blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true,solver,true);
    auto& scene=context.scene();auto& internal=static_cast<NpScene&>(scene);auto& cuda=*context.cudaContextManager();auto& api=scene.getDirectGPUAPI();
    auto& controller=*static_cast<PxgSimulationController*>(internal.getScScene().getSimulationController());auto& core=*controller.getSimulationCore();
    scene.setGravity(PxVec3(0));
    auto* parent=context.physics().createRigidDynamic(PxTransform(PxVec3(10,20,-5),PxQuat(.43f,PxVec3(0,0,1))));
    constexpr float inertia=1.0f/24.0f;
    parent->setMass(2);parent->setMassSpaceInertiaTensor(PxVec3(2*inertia,2+2*inertia,2+2*inertia));
    parent->setCMassLocalPose(PxTransform(PxVec3(1,0,0)));parent->setLinearDamping(0);parent->setAngularDamping(0);
    parent->setLinearVelocity(PxVec3(3,4,1));parent->setAngularVelocity(PxVec3(0,0,2));
    parent->setActorFlag(PxActorFlag::eDISABLE_GRAVITY,true);
    parent->setRigidBodyFlag(PxRigidBodyFlag::eENABLE_GYROSCOPIC_FORCES,true);
    parent->setRigidBodyFlag(PxRigidBodyFlag::eRETAIN_ACCELERATIONS,true);
    scene.addActor(*parent);step(scene);const PxU32 parentId=parent->getGPUIndex();
    const PxDestructionStressChunk chunks[2]={{PxVec3(0),1,inertia,0,PX_INVALID_U32,.125f,0},{PxVec3(2,0,0),1,inertia,0,PX_INVALID_U32,.125f,0}};
    const PxDestructionChunkMassProperties mass[2]={{{0,0,0},1,{inertia,inertia,inertia,0,0,0},0},{{2,0,0},1,{inertia,inertia,inertia,0,0,0},0}};
    const PxDestructionStressBond bond{0,1,PxVec3(1,0,0),PxVec3(1,0,0),1,1,1};
    const PxDestructionStressCluster cluster{parentId,PxVec3(1,0,0)};PxDestructionMaterial material;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;desc.bonds=&bond;desc.bondCount=1;
    desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
    auto* stage=scene.getDestructionScene();require(stage->configureStress(desc),"moving graph configuration failed");
    // Set a physical parameter only in authoritative GPU storage. Its CPU copy
    // deliberately differs, so cloning CPU properties cannot pass this check.
    {PxScopedCudaLock lock(cuda);const auto p=core.getBodySimBufferDevicePtr().getPointer()+parentId;PxgBodySim b;
        check(cuMemcpyDtoH(&b,CUdeviceptr(p),sizeof(b)));b.offsetSlop=.037f;check(cuMemcpyHtoD(CUdeviceptr(p),&b,sizeof(b)));}
    CUdeviceptr data{},index{};{PxScopedCudaLock lock(cuda);check(cuMemAlloc(&data,sizeof(PxTransform)));check(cuMemAlloc(&index,sizeof(PxU32)));}
    for(unsigned retry=0;retry<3;++retry) {
        scene.simulate(1.0f/60);PxU32 error=0;require(!scene.fetchResults(true,&error)&&error&&stage->getLastStatus().error==8,"moving split accepted before correction");
        const auto view=stage->getDeviceView();PxU32 ids[2];PxgBodySim source,child;PxDestructionBodyAllocationStatus allocation;
        {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));
            check(cuMemcpyDtoH(&allocation,CUdeviceptr(view.bodyAllocation),sizeof(allocation)));
            check(cuMemcpyDtoH(ids,CUdeviceptr(view.trialBodyIndices),sizeof(ids)));
            require(allocation.valid && allocation.initialized==1 && !allocation.initializationError,"moving native initialization incomplete");
            const auto pool=core.getBodySimBufferDevicePtr().getPointer();
            check(cuMemcpyDtoH(&source,CUdeviceptr(pool+ids[0]),sizeof(source)));check(cuMemcpyDtoH(&child,CUdeviceptr(pool+ids[1]),sizeof(child)));
        }
        require(ids[0]==parentId,"moving parent replaced");near(source.linearVelocityXYZ_inverseMassW.w,.5f,"retained parent inverse mass overwritten");
        near(source.body2Actor_maxImpulseW.p.x,1,"retained parent COM overwritten");near(child.linearVelocityXYZ_inverseMassW.w,1,"moving child inverse mass");
        near(child.inverseInertiaXYZ_contactReportThresholdW.x,1/inertia,"moving child inertia");near(child.offsetSlop,.037f,"GPU-only physical parameter inheritance");
        require(child.disableGravity && (child.internalFlags&PxsRigidBody::eENABLE_GYROSCOPIC_GPU)
            && (child.internalFlags&PxsRigidBody::eRETAIN_ACCELERATION_GPU),"native physical flags lost");
        const PxVec3 w(source.angularVelocityXYZ_maxPenBiasW.x,source.angularVelocityXYZ_maxPenBiasW.y,source.angularVelocityXYZ_maxPenBiasW.z);
        const PxVec3 v(source.linearVelocityXYZ_inverseMassW.x,source.linearVelocityXYZ_inverseMassW.y,source.linearVelocityXYZ_inverseMassW.z);
        const PxVec3 delta(child.body2World.p.x-source.body2World.p.x,child.body2World.p.y-source.body2World.p.y,child.body2World.p.z-source.body2World.p.z);
        const PxVec3 expected=v+w.cross(delta);
        near(child.linearVelocityXYZ_inverseMassW.x,expected.x,"native child point velocity x");near(child.linearVelocityXYZ_inverseMassW.y,expected.y,"native child point velocity y");near(child.linearVelocityXYZ_inverseMassW.z,expected.z,"native child point velocity z");
        near(child.angularVelocityXYZ_maxPenBiasW.z,w.z,"native child angular velocity");
        near(child.body2Actor_maxImpulseW.p.x,2,"native child asset COM");
        require(!internal.getDestructionBodyCandidate(1)->getCore().getSim()->isActive(),"provisional moving body became active");
        // Use a normal public Direct GPU pose command immediately after pool
        // growth. A stale actor descriptor writes to the old allocation instead.
        const PxTransform pose(PxVec3(source.body2World.p.x,source.body2World.p.y,source.body2World.p.z),
            PxQuat(source.body2World.q.q.x,source.body2World.q.q.y,source.body2World.q.q.z,source.body2World.q.q.w));
        const PxTransform actor=pose*PxTransform(PxVec3(1,0,0)).getInverse();const PxTransform shifted(actor.p+PxVec3(0,0,1),actor.q);
        {PxScopedCudaLock lock(cuda);check(cuMemcpyHtoD(index,&parentId,sizeof(parentId)));check(cuMemcpyHtoD(data,&shifted,sizeof(shifted)));}
        require(api.setRigidDynamicData(reinterpret_cast<void*>(data),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIWriteType::eGLOBAL_POSE,1),"post-growth GPU pose command failed");
        require(api.getRigidDynamicData(reinterpret_cast<void*>(data),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,1),"post-growth GPU pose read failed");
        PxTransform observed;{PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(&observed,data,sizeof(observed)));}
        near(observed.p.z,shifted.p.z,"GPU pose descriptor retained old allocation");
    }
    require(stage->clearStress(),"moving cleanup failed");parent->release();step(scene);
    {PxScopedCudaLock lock(cuda);check(cuMemFree(data));check(cuMemFree(index));}
    require(context.healthy(),"moving initialization GPU health failed");
    std::puts("native body initialization: actual GPU mass/COM/motion, point velocity, GPU settings, retained parent and post-growth descriptors passed");
}

// Exercise membership transitions independently of physical initialization.
// Runtime initialization, momentum and collision acceptance have separate native
// fixtures; this fixture isolates source validation and pooled-object reuse.
void membership() {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,true,false,false);
    auto& scene=context.scene();auto& internal=static_cast<NpScene&>(scene);
    auto* parent=context.physics().createRigidDynamic(PxTransform(PxIdentity));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*parent);step(scene);
    NpDestructionBodyAllocator allocator(internal);
    constexpr PxU32 count=257;
    std::vector<PxvDestructionBodyRequest> requests(count);std::vector<PxU32> ids(count);
    for(PxU32 i=0;i<count;++i)requests[i]={i,parent->getGPUIndex(),1,1,i};
    for(unsigned cycle=0;cycle<3;++cycle) {
        require(allocator.prepare(requests.data(),count,ids.data()),"membership reservations failed");
        for(auto id:ids)require(!allocator.isValidSource(id),"uncommitted reservation accepted as a source");
        const auto reserved=ids;
        require(allocator.prepare(requests.data(),count,ids.data()) && ids==reserved,"membership lookup changed reservation reuse");
        // No geometry or motion is installed here. Reserve acceptance storage
        // through the same bridge used by a real candidate transaction.
        require(allocator.applyBindings(nullptr,0,nullptr,nullptr,0),"membership acceptance storage failed");
        allocator.acceptReservations();
        for(auto id:ids)require(allocator.isValidSource(id),"accepted private owner missing from source lookup");
        const PxvDestructionBodyRequest child{count,ids.back(),1,1,count};PxU32 childID;
        require(allocator.prepare(&child,1,&childID),"accepted fragment could not source another split");
        require(!allocator.isValidSource(childID),"new child inherited accepted membership");
        allocator.discardReservations();
        require(!allocator.isValidSource(childID),"discarded child retained source membership");
        for(auto id:ids)require(allocator.isValidSource(id),"discarding reservations erased an accepted owner");
        allocator.clear();
        for(auto id:ids)require(!allocator.isValidSource(id),"cleared owner survived deferred node deletion");
        require(allocator.isValidSource(parent->getGPUIndex()),"private clear invalidated ordinary source");
        step(scene); // recycle deferred island IDs before the next pool-reuse cycle
    }
    parent->release();require(context.healthy(),"membership lifecycle GPU health failed");
    std::puts("native membership: reservations, acceptance, fragment sources, discard, clear and reuse passed");
}

// The shared PhysX index contains ordinary actors and empty/reused entries as
// well as destruction chunks. None may bypass all-or-nothing batch validation.
void bindingIdentityValidation() {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,true,false,false);
    auto& scene=context.scene();auto& internal=static_cast<NpScene&>(scene);
    auto* parent=context.physics().createRigidDynamic(PxTransform(PxVec3(0,10,0)));
    auto* foreign=context.physics().createRigidDynamic(PxTransform(PxVec3(20,10,0)));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    foreign->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    auto addShape=[&](PxRigidDynamic& actor) {
        auto* shape=context.physics().createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        require(shape && actor.attachShape(*shape),"identity-test shape creation failed");return shape;
    };
    auto* owned=addShape(*parent);auto* removed=addShape(*parent);auto* other=addShape(*foreign);
    scene.addActor(*parent);scene.addActor(*foreign);step(scene);
    const auto ownedID=scene.getDirectGPUAPI().getShapeContactIndex(*owned);
    const auto removedID=scene.getDirectGPUAPI().getShapeContactIndex(*removed);
    const auto otherID=scene.getDirectGPUAPI().getShapeContactIndex(*other);
    parent->detachShape(*removed);removed->release();step(scene);
    NpDestructionBodyAllocator allocator(internal);
    PxvDestructionBodyRequest request{0,parent->getGPUIndex(),1,1,0};PxU32 target=PX_INVALID_U32;
    require(allocator.prepare(&request,1,&target),"identity-test reservation failed");
    const auto source=parent->getGPUIndex();
    const PxDestructionCollisionBinding valid{0,ownedID,source,target};
    auto reject=[&](const PxDestructionCollisionBinding* bindings,PxU32 count) {
        require(!allocator.applyBindings(bindings,count,&request,&target,1),"invalid shape identity batch accepted");
        require(owned->getActor()==parent && other->getActor()==foreign && parent->getNbShapes()==1,
            "rejected batch partially changed ownership");
        require(!allocator.isValidSource(target),"rejected batch committed its reservation");
    };
    auto invalid=valid;invalid.shape=PX_INVALID_U32;reject(&invalid,1);
    invalid.shape=removedID;reject(&invalid,1); // null persistent-index entry
    invalid.shape=otherID;reject(&invalid,1); // live shape with another owner
    invalid.sourceBody=foreign->getGPUIndex();reject(&invalid,1); // owner not in request batch
    PxDestructionCollisionBinding duplicate[2]={valid,valid};reject(duplicate,2);
    PxDestructionCollisionBinding lateInvalid[2]={valid,invalid};reject(lateInvalid,2);
    allocator.discardReservations();step(scene);
    // Reuse through the real shape lifecycle must expose the new owner, never a
    // cached pointer to the old chunk. Reuse order itself is allocator-defined.
    auto* replacement=addShape(*foreign);step(scene);
    require(allocator.prepare(&request,1,&target),"identity-test second reservation failed");
    invalid={0,scene.getDirectGPUAPI().getShapeContactIndex(*replacement),source,target};reject(&invalid,1);
    allocator.clear();parent->release();foreign->release();owned->release();other->release();replacement->release();
    require(context.healthy(),"identity validation GPU health failed");
    std::puts("native identity validation: bounds, removed slots, foreign/reused shapes, duplicate and partially invalid batches passed");
}

void teardown() {
    // Leave an uncommitted reservation alive through scene teardown. Scene must
    // release it while BodySim/island/controller pools still exist.
    blast_demo::SceneCapacity capacity;blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto& scene=context.scene();auto* parent=context.physics().createRigidDynamic(PxTransform(PxIdentity));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*parent);step(scene);
    PxDestructionStressChunk chunks[2]={{PxVec3(0),0,0,0,PX_INVALID_U32},{PxVec3(0,1,0),1,1,0,PX_INVALID_U32}};
    PxDestructionChunkMassProperties mass[2]={{{0,0,0},0,{0,0,0,0,0,0},1},{{0,1,0},1,{1,1,1,0,0,0},0}};
    PxDestructionStressBond bond{0,1,PxVec3(0,.5f,0),PxVec3(0,1,0),1,1,1};PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};PxDestructionMaterial material;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;desc.bonds=&bond;desc.bondCount=1;desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;
    auto* stage=scene.getDestructionScene();require(stage->configureStress(desc),"teardown configuration failed");scene.setGravity(PxVec3(0,-9.81f,0));scene.simulate(1.0f/60);PxU32 error=0;
    require(!scene.fetchResults(true,&error)&&error&&static_cast<NpScene&>(scene).getNbDestructionBodyCandidates()==1,"teardown fixture did not reserve body");
    // Parent removal is permitted after completed fetch; its slot can outlive
    // that actor until the scene discards the uncommitted transaction.
    parent->release();
}
}
int main(){try{bindingIdentityValidation();membership();run(true,false);run(false,false);run(true,true);run(false,true);moving(PxSolverType::eTGS);moving(PxSolverType::ePGS);teardown();return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
