// Native fracture verdict -> pre-solve correction inputs -> private GPU body
// installation. This fixture stops before the separately tested internal resim.
#include "../physx_scene.h"
#include "NpScene.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "PxgDestructionRuntime.h"
#include "PxgNphaseImplementationContext.h"
#include "PxgNarrowphaseCore.h"
#include <extensions/PxMassProperties.h>
#include <cuda.h>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <limits>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
void check(CUresult result){if(result!=CUDA_SUCCESS){const char* name=nullptr;cuGetErrorName(result,&name);std::fprintf(stderr,"CUDA: %s\n",name?name:"");throw std::runtime_error("CUDA observation failed");}}
void near(float a,float b,const char* message){if(!std::isfinite(a) || std::abs(a-b)>2e-4f*PxMax(1.0f,std::abs(b))){std::fprintf(stderr,"%s: %.9g != %.9g\n",message,a,b);throw std::runtime_error(message);}}
void near(PxVec3 a,PxVec3 b,const char* message){for(unsigned k=0;k<3;++k)near(a[k],b[k],message);}
PxVec3 vec(const float* p){return PxVec3(p[0],p[1],p[2]);}
PxVec3 vec(float4 p){return PxVec3(p.x,p.y,p.z);}
PxQuat quat(const float* p){return PxQuat(p[0],p[1],p[2],p[3]);}
template<class T> std::vector<T> read(const T* ptr,unsigned count){std::vector<T> out(count);if(count)check(cuMemcpyDtoH(out.data(),CUdeviceptr(ptr),count*sizeof(T)));return out;}
void step(PxScene& scene){scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"ordinary step failed");}
void run(bool sleeping,bool accelerations,PxSolverType::Enum solver,bool loaded,bool invalidCheckpoint=false,bool invalidCollision=false,bool invalidInitialization=false) {
    blast_demo::SceneCapacity capacity;blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,sleeping,sleeping,solver,accelerations);
    auto& scene=context.scene();auto& physics=context.physics();auto& cuda=*context.cudaContextManager();auto& internal=static_cast<NpScene&>(scene);
    auto& controller=*static_cast<PxgSimulationController*>(internal.getScScene().getSimulationController());auto& core=*controller.getSimulationCore();
    scene.setGravity(PxVec3(0));const PxVec3 offset(2,1,-.5f),center=offset+PxVec3(.2f,0,0);
    const PxTransform asset(PxVec3(30,50,-10),PxQuat(.63f,PxVec3(1,2,3).getNormalized()));
    const PxQuat shapeRotation(.51f,PxVec3(2,1,3).getNormalized());const PxMat33 rotation(shapeRotation);
    const PxVec3 unitMoments((.16f+.25f)/3,(.09f+.25f)/3,(.09f+.16f)/3);
    const PxMat33 unitTensor=rotation*PxMat33::createDiagonal(unitMoments)*rotation.getTranspose();
    const PxMat33 parentTensor=unitTensor*5+PxMat33::createDiagonal(PxVec3(0,4.8f,4.8f));
    PxQuat parentMassFrame(PxIdentity);const auto parentMoments=PxMassProperties::getMassSpaceInertia(parentTensor,parentMassFrame);
    auto* parent=physics.createRigidDynamic(asset);parent->setMass(5);parent->setCMassLocalPose(PxTransform(center,parentMassFrame));parent->setMassSpaceInertiaTensor(parentMoments);
    parent->setLinearDamping(0);parent->setAngularDamping(0);parent->setMaxAngularVelocity(1000);parent->setLinearVelocity(PxVec3(3,-2,4));parent->setAngularVelocity(asset.q.rotate(PxVec3(0,0,20)));
    PxShape* shapes[2];for(unsigned i=0;i<2;++i){shapes[i]=physics.createShape(PxBoxGeometry(.3f,.4f,.5f),context.material(),true);shapes[i]->setLocalPose(PxTransform(offset+PxVec3(i?1.0f:-1.0f,0,0),shapeRotation));require(parent->attachShape(*shapes[i]),"parent shape setup failed");}
    scene.addActor(*parent);
    auto* quiet=physics.createRigidDynamic(PxTransform(PxVec3(100,20,0)));quiet->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*quiet);
    auto* ordinary=physics.createRigidDynamic(PxTransform(PxVec3(-30,20,0)));ordinary->setLinearVelocity(PxVec3(4,1,0));ordinary->setLinearDamping(0);ordinary->setAngularDamping(0);scene.addActor(*ordinary);step(scene);
    const PxU32 parentId=parent->getGPUIndex(),quietId=quiet->getGPUIndex(),ordinaryId=ordinary->getGPUIndex();
    PxDestructionStressChunk chunks[3];PxDestructionChunkMassProperties mass[3]{};
    for(unsigned i=0;i<2;++i) {
        const float m=i?3.0f:2.0f;const auto point=offset+PxVec3(i?1.0f:-1.0f,0,0);const auto tensor=unitTensor*m;
        chunks[i]={point,m,m*unitMoments.z,0,scene.getDirectGPUAPI().getShapeContactIndex(*shapes[i]),.48f,0};
        mass[i].mass=m;for(unsigned k=0;k<3;++k){mass[i].center[k]=point[k];mass[i].inertia[k]=tensor[k][k];}
        mass[i].inertia[3]=tensor[1][0];mass[i].inertia[4]=tensor[2][0];mass[i].inertia[5]=tensor[2][1];
    }
    chunks[2]={PxVec3(0),0,0,1,PX_INVALID_U32};mass[2].supported=1;
    PxDestructionStressCluster clusters[2]={{parentId,center},{quietId,PxVec3(0)}};
    PxDestructionStressBond bond{0,1,offset,PxVec3(1,0,0),1,1,1};PxDestructionMaterial material;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=3;desc.chunkMassProperties=mass;desc.clusters=clusters;desc.clusterCount=2;desc.bonds=&bond;desc.bondCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
    auto* runtime=static_cast<PxgDestructionRuntime*>(scene.getDestructionScene());require(runtime->configureStress(desc),"correction graph configuration failed");
    auto force=[&](PxU32 id){PxScopedCudaLock lock(cuda);CUdeviceptr index=0,value=0;check(cuMemAlloc(&index,sizeof(id)));check(cuMemAlloc(&value,sizeof(PxVec3)));const PxVec3 f(10,0,0);check(cuMemcpyHtoD(index,&id,sizeof(id)));check(cuMemcpyHtoD(value,&f,sizeof(f)));require(scene.getDirectGPUAPI().setRigidDynamicData(reinterpret_cast<void*>(value),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIWriteType::eFORCE,1),"force command failed");check(cuCtxSynchronize());check(cuMemFree(index));check(cuMemFree(value));};
    force(ordinaryId);if(loaded)force(parentId);
    scene.simulate(1.0f/60);PxU32 error=0;require(!scene.fetchResults(true,&error)&&error&&runtime->getLastStatus().error==8,"native split did not stop at incomplete correction");
    auto view=runtime->getDeviceView();const auto checkpoint=runtime->rigidCheckpoint();
    PxDestructionCorrectionPreparationStatus status;std::vector<PxDestructionCorrectionBody> inputs;std::vector<PxgBodySim> saved,before;
    std::vector<PxgBodySimVelocities> history;
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));status=read(view.correctionPreparation,1)[0];
        require(status.valid && !status.error && status.count==2 && status.generation==1 && status.checkpointGeneration==checkpoint.generation,"correction input batch missing affected retained/new bodies");
        require(status.loadedSources==unsigned(loaded),"ordinary force contaminated changed-source load accounting");
        inputs=read(view.correctionBodies,status.count);saved=read(checkpoint.bodies,checkpoint.count);
        before=read(core.getBodySimBufferDevicePtr().getPointer(),controller.getBodySimManager().mTotalNumBodies);
        if(accelerations)history=read(checkpoint.previous,checkpoint.count);
    }
    require(inputs[0].body.cluster==0 && inputs[1].body.cluster==1 && inputs[0].targetBody==parentId && inputs[1].targetBody!=parentId,"correction lost stable authored ownership/provenance");
    const auto& source=saved[parentId];const auto oldWorld=source.body2World.getTransform(),oldLocal=source.body2Actor_maxImpulseW.getTransform();const auto oldActor=oldWorld*oldLocal.getInverse();
    const auto oldV=vec(source.linearVelocityXYZ_inverseMassW),oldW=vec(source.angularVelocityXYZ_maxPenBiasW);
    PxVec3 momentum(0),angularMomentum(0);
    for(const auto& input:inputs) {
        const auto& b=input.body;require(b.sourceBody==parentId,"correction source body lost");
        near(vec(b.bodyToWorldPosition),oldActor.transform(chunks[b.cluster].position),"correction used trial pose instead of checkpoint");
        const auto delta=vec(b.bodyToWorldPosition)-oldWorld.p;near(vec(b.linearVelocity),oldV+oldW.cross(delta),"correction lost COM point velocity");near(vec(b.angularVelocity),oldW,"correction lost input angular motion");
        const auto actor=PxTransform(vec(b.bodyToWorldPosition),quat(b.bodyToWorldOrientation))*PxTransform(vec(b.bodyToActorPosition),quat(b.bodyToActorOrientation)).getInverse();near(actor.p,oldActor.p,"correction altered immutable asset frame");near(std::abs(actor.q.dot(oldActor.q)),1,"correction actor orientation mismatch");
        const auto p=vec(b.linearVelocity)*b.mass;momentum+=p;const auto q=quat(b.bodyToWorldOrientation);angularMomentum+=delta.cross(p)+q.rotate(vec(b.principalInertia).multiply(q.rotateInv(oldW)));
    }
    near(momentum,oldV*5,"correction linear momentum changed");near(angularMomentum,oldWorld.q.rotate(parentMoments.multiply(oldWorld.q.rotateInv(oldW))),"correction angular momentum changed");
    require((before[parentId].body2World.getTransform().p-oldWorld.p).magnitude()>.01f,"fixture did not advance trial motion");
    if(invalidInitialization) {
        // Populate all preparation buffers first, then submit invalid GPU input
        // without observing the new device verdict on the CPU.
        PxScopedCudaLock lock(cuda);
        auto allocation=read(view.bodyAllocation,1)[0];
        require(allocation.reserved==1 && allocation.initialized==1 && !allocation.initializationError,
            "initialization failure fixture lacks a valid prior reservation");
        auto& np=*static_cast<PxgNphaseImplementationContext*>(internal.getScScene().getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
        CUstream stream;check(cuStreamCreate(&stream,CU_STREAM_NON_BLOCKING));
        require(runtime->initializeReservedBodies(core.getBodySimBufferDevicePtr().getPointer(),
            core.getBodySimPrevVelocitiesBufferDevicePtr().getPointer(),core.getRigidBodyAccelerationsDevice(),0,stream),
            "initialization observed a device verdict instead of submitting asynchronously");
        require(runtime->getLastStatus().error==8u,"initialization unexpectedly read back its device error");
        require(runtime->prepareCollisionBindings(core.mPxgShapeSimManager.getShapeSimsDeviceTypedPtr(),
            core.mPxgShapeSimManager.getNbTotalShapeSims(),
            reinterpret_cast<const PxNodeIndex*>(np.mGpuShapesManager.mGpuShapesRemapTableBuffer.getDevicePtr()),
            PxU32(np.mGpuShapesManager.mGpuShapesRemapTableBuffer.getSize()/sizeof(PxNodeIndex)),core.getStream()),
            "device-gated collision preparation submission failed");
        require(runtime->prepareCorrectionBodies(controller.getBodySimManager().mTotalNumBodies,stream),
            "device-gated correction preparation submission failed");
        require(!runtime->completeCorrectionPreparation(),"invalid initialization reached accepted preparation");
        check(cuEventSynchronize(runtime->getDeviceView().readyEvent));
        allocation=read(view.bodyAllocation,1)[0];const auto collision=read(view.collisionPreparation,1)[0];
        const auto correction=read(view.correctionPreparation,1)[0];
        require(allocation.initializationError==1 && !allocation.initialized,"invalid allocation wrote initialized state");
        require(!collision.valid && (collision.error&64u) && !collision.count && !collision.migrating,
            "initialization failure left stale collision records");
        require(!correction.valid && (correction.error&32u) && !correction.count && !correction.loadedSources,
            "initialization failure left stale correction records");
        require(runtime->getLastStatus().error==(8u|512u|1024u),"initialization failure lost its originating status");
        const auto actual=read(core.getBodySimBufferDevicePtr().getPointer(),unsigned(before.size()));
        require(!std::memcmp(actual.data(),before.data(),actual.size()*sizeof(PxgBodySim)),"invalid initialization changed native motion");
        check(cuStreamDestroy(stream));
    } else if(invalidCollision) {
        // A previously valid batch has populated the compaction storage. Reject
        // its device prerequisite without changing the stale host observation.
        PxScopedCudaLock lock(cuda);
        auto collision=read(view.collisionPreparation,1)[0];collision.valid=0;collision.error|=2u;
        auto stage=runtime->getLastStatus();stage.error|=1024u;
        check(cuMemcpyHtoD(CUdeviceptr(view.collisionPreparation),&collision,sizeof(collision)));
        check(cuMemcpyHtoD(CUdeviceptr(view.status),&stage,sizeof(stage)));
        require(runtime->prepareCorrectionBodies(controller.getBodySimManager().mTotalNumBodies,core.getStream()),"device-gated correction submission failed");
        require(!runtime->completeCorrectionPreparation(),"invalid device prerequisite accepted through stale host observation");
        check(cuEventSynchronize(runtime->getDeviceView().readyEvent));
        const auto rejected=read(view.correctionPreparation,1)[0];
        require(!rejected.valid && (rejected.error&32u) && !rejected.count && !rejected.loadedSources,
            "invalid collision prerequisite retained stale correction records");
        require(runtime->getLastStatus().error==(8u|1024u),"collision failure lost originating error");
        const auto actual=read(core.getBodySimBufferDevicePtr().getPointer(),unsigned(before.size()));
        require(!std::memcmp(actual.data(),before.data(),actual.size()*sizeof(PxgBodySim)),"prerequisite rejection changed native motion");
    } else if(invalidCheckpoint) {
        PxScopedCudaLock lock(cuda);auto corrupted=source;corrupted.body2World.p.x=std::numeric_limits<float>::quiet_NaN();
        check(cuMemcpyHtoD(CUdeviceptr(checkpoint.bodies+parentId),&corrupted,sizeof(corrupted)));
        require(runtime->prepareCorrectionBodies(controller.getBodySimManager().mTotalNumBodies,core.getStream()),"correction validation submission failed");
        require(!runtime->completeCorrectionPreparation(),"nonfinite checkpoint accepted as correction motion");
        check(cuEventSynchronize(runtime->getDeviceView().readyEvent));const auto rejected=read(view.correctionPreparation,1)[0];
        require(!rejected.valid && (rejected.error&4) && runtime->getLastStatus().error==(8u|2048u),"bad input did not reject the correction batch explicitly");
        const auto actual=read(core.getBodySimBufferDevicePtr().getPointer(),unsigned(before.size()));
        require(!std::memcmp(actual.data(),before.data(),actual.size()*sizeof(PxgBodySim)),"correction rejection changed ordinary native state");
        check(cuMemcpyHtoD(CUdeviceptr(checkpoint.bodies+parentId),&source,sizeof(source)));
    } else
    {PxScopedCudaLock lock(cuda);auto* bodies=core.getBodySimBufferDevicePtr().getPointer();auto* previous=core.getBodySimPrevVelocitiesBufferDevicePtr().getPointer();auto* accelerationsPtr=core.getRigidBodyAccelerationsDevice();const auto count=controller.getBodySimManager().mTotalNumBodies;CUstream stream;check(cuStreamCreate(&stream,CU_STREAM_NON_BLOCKING));
        require(!runtime->installCorrectionBodies(bodies,previous,accelerationsPtr,count,checkpoint.generation,stream),"body installation bypassed rigid-state restore");
        require(runtime->restoreRigidState(bodies,previous,accelerationsPtr,count,checkpoint.generation,stream),"rigid checkpoint restore failed");check(cuEventSynchronize(runtime->rigidCheckpoint().ready));const auto restored=read(bodies,count);
        require(!runtime->installCorrectionBodies(bodies,previous,accelerationsPtr,count,checkpoint.generation+1,stream),"stale correction generation accepted");
        require(!runtime->installCorrectionBodies(bodies,previous,accelerationsPtr,count-1,checkpoint.generation,stream),"undersized correction storage accepted");
        // Preparation now precedes CPU registration and validates allocated GPU
        // storage. Observe only registered bodies, but supply the actual storage
        // extent to installation. The count-1 undersized rejection above remains.
        const bool installed=runtime->installCorrectionBodies(bodies,previous,accelerationsPtr,core.getBodySimStorageCapacity(),checkpoint.generation,stream);require(installed!=loaded,"unassigned body commands were dropped or duplicated");
        check(cuEventSynchronize(runtime->getDeviceView().readyEvent));const auto after=read(bodies,count);
        if(loaded)require(!std::memcmp(restored.data(),after.data(),count*sizeof(PxgBodySim)),"rejected command batch changed body states");
        else for(const auto& input:inputs) {
            const auto& b=input.body;const auto& actual=after[input.targetBody];near(vec(actual.linearVelocityXYZ_inverseMassW),vec(b.linearVelocity),"installed body input velocity");near(actual.linearVelocityXYZ_inverseMassW.w,b.inverseMass,"retained/new body inverse mass");near(vec(actual.inverseInertiaXYZ_contactReportThresholdW),vec(b.inverseInertia),"retained/new body inertia");near(actual.body2World.getTransform().p,vec(b.bodyToWorldPosition),"installed body COM");near(actual.body2Actor_maxImpulseW.getTransform().p,vec(b.bodyToActorPosition),"installed local COM");
            if(accelerations){const auto p=read(previous+input.targetBody,1)[0],old=history[parentId];near(vec(p.linearVelocity),vec(old.linearVelocity)+vec(old.angularVelocity).cross(vec(b.bodyToWorldPosition)-oldWorld.p),"correction lost previous velocity at new COM");}
        }
        require(!std::memcmp(&after[ordinaryId],&saved[ordinaryId],sizeof(PxgBodySim)) && !std::memcmp(&after[quietId],&saved[quietId],sizeof(PxgBodySim)),"body installation overwrote ordinary/unchanged participants");
        check(cuStreamDestroy(stream));
    }
    require(parent->getNbShapes()==2 && shapes[0]->getActor()==parent && shapes[1]->getActor()==parent,"private body installation committed shape membership");
    require(scene.getNbActors(PxActorTypeFlag::eRIGID_DYNAMIC)==3,"private body installation published trial actors");
    {PxScopedCudaLock lock(cuda);const auto accepted=read(view.acceptedTopology.status,1)[0];require(accepted.generation==0 && accepted.clusterCount==2,"private body installation committed topology");require(read(view.bondHealth,1)[0]==1,"private body installation committed damage");}
    require(runtime->clearStress(),"correction cleanup failed");parent->release();quiet->release();ordinary->release();for(auto* shape:shapes)shape->release();require(context.healthy(),"correction fixture GPU health failed");
    std::printf("native correction bodies: rotated inertia/COM, original motion, momentum, retained/new installation, load guard; sleep=%u acceleration=%u solver=%u loaded=%u invalid=%u invalidCollision=%u invalidInitialization=%u passed\n",unsigned(sleeping),unsigned(accelerations),unsigned(solver),unsigned(loaded),unsigned(invalidCheckpoint),unsigned(invalidCollision),unsigned(invalidInitialization));
}
}
int main(){try{for(bool sleeping:{false,true})for(bool accelerations:{false,true})for(auto solver:{PxSolverType::eTGS,PxSolverType::ePGS})run(sleeping,accelerations,solver,false);run(true,true,PxSolverType::eTGS,true);run(false,false,PxSolverType::eTGS,false,true);run(false,false,PxSolverType::eTGS,false,false,true);for(auto solver:{PxSolverType::eTGS,PxSolverType::ePGS})run(false,true,solver,false,false,false,true);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
