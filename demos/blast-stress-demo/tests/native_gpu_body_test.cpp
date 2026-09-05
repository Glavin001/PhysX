// GPU-native material verdict -> solver-body candidate -> actual GPU response.
// Host readback/actor creation/rebinding below are deliberately test scaffolding:
// the scene's allocation/correction task has not yet been connected.
#include "../physx_scene.h"
#include "NpShapeManager.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cmath>
#include <cstdio>
#include <stdexcept>
using namespace physx;
namespace {
void require(bool v,const char* message){if(!v)throw std::runtime_error(message);}
void check(CUresult r){require(r==CUDA_SUCCESS,"CUDA observation failed");}
void near(float a,float b,const char* message){
    if(!std::isfinite(a) || !std::isfinite(b) || std::abs(a-b)>2e-4f*PxMax(1.0f,std::abs(b))) {
        std::fprintf(stderr,"%s: %g != %g\n",message,a,b);throw std::runtime_error(message);
    }
}
PxVec3 vec(const float* p){return PxVec3(p[0],p[1],p[2]);}
PxQuat quat(const float* p){return PxQuat(p[0],p[1],p[2],p[3]);}
void step(PxScene& s){s.simulate(1.0f/60);PxU32 e=0;require(s.fetchResults(true,&e)&&!e,"native step failed");}
struct Observer {
    PxDirectGPUAPI& api;PxCudaContextManager& cuda;CUdeviceptr index{},data{};
    Observer(PxScene& scene,PxCudaContextManager& context,PxRigidDynamic& actor):api(scene.getDirectGPUAPI()),cuda(context) {
        PxScopedCudaLock lock(cuda);check(cuMemAlloc(&index,sizeof(PxU32)));check(cuMemAlloc(&data,sizeof(PxTransform)));
        const PxU32 id=actor.getGPUIndex();check(cuMemcpyHtoD(index,&id,sizeof(id)));
    }
    ~Observer(){PxScopedCudaLock lock(cuda);cuMemFree(index);cuMemFree(data);}
    PxVec3 read(PxRigidDynamicGPUAPIReadType::Enum type){
        require(api.getRigidDynamicData(reinterpret_cast<void*>(data),reinterpret_cast<const PxU32*>(index),type,1),"GPU body read failed");
        PxVec3 out;PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(&out,data,sizeof(out)));return out;
    }
    void write(PxVec3 value,PxRigidDynamicGPUAPIWriteType::Enum type){
        {PxScopedCudaLock lock(cuda);check(cuMemcpyHtoD(data,&value,sizeof(value)));}
        require(api.setRigidDynamicData(reinterpret_cast<const void*>(data),reinterpret_cast<const PxU32*>(index),type,1),"GPU body write failed");
    }
};
void run() {
    blast_demo::SceneCapacity capacity;blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto& scene=context.scene();auto& cuda=*context.cudaContextManager();auto& api=scene.getDirectGPUAPI();
    const PxTransform asset(PxVec3(10,7,-2),PxQuat(.63f,PxVec3(2,1,3).getNormalized()));
    const PxQuat principal(.71f,PxVec3(1,2,3).getNormalized());const PxVec3 center(1.3f,-.2f,.7f);
    const PxVec3 moments(5,7,10);const float physicalMass=6;
    auto* parent=context.physics().createRigidDynamic(asset);require(parent,"create parent");
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    auto* shape=context.physics().createShape(PxBoxGeometry(std::sqrt(3.0f),std::sqrt(2.0f),std::sqrt(.5f)),context.material(),true);
    shape->setLocalPose(PxTransform(center,principal));require(parent->attachShape(*shape),"attach original geometry");scene.addActor(*parent);step(scene);
    const PxU32 contact=api.getShapeContactIndex(*shape);require(contact!=PX_INVALID_U32,"missing shape identity");
    PxDestructionStressChunk chunks[2]={{center+PxVec3(0,-4,0),0,0,0,PX_INVALID_U32},
        {center,physicalMass,7,0,contact,1,0}};
    PxDestructionChunkMassProperties properties[2]{};
    properties[0].supported=1;properties[1].mass=physicalMass;
    for(unsigned k=0;k<3;++k){properties[0].center[k]=chunks[0].position[k];properties[1].center[k]=center[k];}
    const PxMat33 rotation(principal);const PxMat33 tensor=rotation*PxMat33::createDiagonal(moments)*rotation.getTranspose();
    const double packed[]={tensor[0][0],tensor[1][1],tensor[2][2],tensor[1][0],tensor[2][0],tensor[2][1]};
    for(unsigned k=0;k<6;++k)properties[1].inertia[k]=packed[k];
    PxDestructionStressBond bond{0,1,center+PxVec3(0,-2,0),PxVec3(0,1,0),1,1,1};
    PxDestructionStressCluster cluster{parent->getGPUIndex(),center};PxDestructionMaterial material;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.bonds=&bond;desc.bondCount=1;
    desc.clusters=&cluster;desc.clusterCount=1;desc.chunkMassProperties=properties;desc.materials=&material;desc.materialCount=1;
    desc.maxIterations=128;desc.tolerance=1e-5f;
    auto* stage=scene.getDestructionScene();require(stage->configureStress(desc),"configure native graph");
    scene.setGravity(PxVec3(0,-9.81f,0));scene.simulate(1.0f/60);PxU32 error=0;
    require(!scene.fetchResults(true,&error) && error && stage->getLastStatus().error==8,"unimplemented correction falsely completed");
    PxDestructionClusterBodyState bodies[2];PxDestructionBodyPreparationStatus prepared;PxDestructionTopologyStatus accepted;
    auto readBatch=[&]{const auto view=stage->getDeviceView();require(view.trialBodies && view.bodyPreparation,"missing native body candidates");
        PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));
        check(cuMemcpyDtoH(&prepared,reinterpret_cast<CUdeviceptr>(view.bodyPreparation),sizeof(prepared)));
        if(prepared.valid && prepared.count)check(cuMemcpyDtoH(bodies,reinterpret_cast<CUdeviceptr>(view.trialBodies),prepared.count*sizeof(*bodies)));
        check(cuMemcpyDtoH(&accepted,reinterpret_cast<CUdeviceptr>(view.acceptedTopology.status),sizeof(accepted)));
    };readBatch();
    require(prepared.valid && !prepared.error && prepared.count==2 && prepared.generation==1,"native body candidate batch invalid");
    require(!accepted.generation && accepted.clusterCount==1 && parent->getNbShapes()==1,"candidate preparation mutated accepted body ownership");
    require(bodies[0].supported && bodies[0].mass==0 && bodies[0].inverseMass==0 && vec(bodies[0].inverseInertia).isZero(),"massless support candidate lost");
    const auto child=bodies[1];require(child.cluster==1 && child.sourceBody==parent->getGPUIndex() && !child.supported,"body candidate provenance lost");
    near(child.mass,physicalMass,"candidate physical mass");near(child.inverseMass,1/physicalMass,"candidate inverse mass");
    for(unsigned k=0;k<3;++k){near(child.principalInertia[k],moments[k],"candidate principal moment");near(child.inverseInertia[k],1/moments[k],"candidate inverse inertia");}
    const PxTransform com(vec(child.bodyToActorPosition),quat(child.bodyToActorOrientation));
    const PxTransform world(vec(child.bodyToWorldPosition),quat(child.bodyToWorldOrientation));
    const PxTransform actor=world*com.getInverse();near((actor.p-asset.p).magnitude(),0,"candidate actor origin");near(std::abs(actor.q.dot(asset.q)),1,"candidate actor orientation");
    const PxMat33 candidateRotation(com.q);const PxMat33 candidateTensor=candidateRotation*PxMat33::createDiagonal(vec(child.principalInertia))*candidateRotation.getTranspose();
    for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j)near(candidateTensor[i][j],tensor[i][j],"full inertia reconstruction");
    require(stage->clearStress(),"clear candidate trial");
    // Mixed valid/invalid candidates must reject the ENTIRE batch, leaving
    // accepted damage, topology and ordinary collision membership untouched.
    properties[1].inertia[0]=-1;
    require(stage->configureStress(desc),"configure invalid candidate fixture");scene.simulate(1.0f/60);
    require(!scene.fetchResults(true,&error) && error && stage->getLastStatus().error==(8u|128u),"invalid candidate inertia was accepted");readBatch();
    require(!prepared.valid && (prepared.error&2) && prepared.count==2 && !accepted.generation && parent->getNbShapes()==1,"body failure did not reject entire candidate batch");
    {const auto view=stage->getDeviceView();float health;PxScopedCudaLock lock(cuda);check(cuMemcpyDtoH(&health,reinterpret_cast<CUdeviceptr>(view.bondHealth),sizeof(health)));require(health==1,"body preparation failure committed material damage");}
    require(stage->clearStress(),"clear invalid candidate trial");
    // A later non-fracturing frame must not expose the failed batch as current.
    properties[1].inertia[0]=packed[0];material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;
    require(stage->configureStress(desc),"configure healthy candidate fixture");step(scene);readBatch();
    require(!prepared.valid && !prepared.count && !prepared.error && !prepared.generation,"non-fracturing frame exposed stale body records");
    require(stage->clearStress(),"clear healthy fixture");scene.setGravity(PxVec3(0));
    // Exercise the exact GPU-generated mass/COM frames in real PhysX dynamics.
    // Only this fixture creates the compatibility actor and reads candidates.
    auto* target=context.physics().createRigidDynamic(actor);require(target,"create solver-body fixture");
    target->setMass(child.mass);target->setMassSpaceInertiaTensor(vec(child.principalInertia));target->setCMassLocalPose(com);
    target->setLinearVelocity(vec(child.linearVelocity));target->setAngularVelocity(vec(child.angularVelocity));
    target->setLinearDamping(0);target->setAngularDamping(0);scene.addActor(*target);
    require(NpShapeManager::rebindShape(*parent,*target,*shape,PxTransform(center,principal)),"bind persistent geometry to GPU-prepared body failed");
    require(api.getShapeContactIndex(*shape)==contact && shape->getActor()==target,"body preparation changed cooked collision identity");
    parent->release();step(scene);
    Observer observer(scene,cuda,*target);const PxVec3 force(12,-18,6),torque(7,11,-5);
    const PxVec3 before=observer.read(PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY);
    const PxVec3 spinBefore=observer.read(PxRigidDynamicGPUAPIReadType::eANGULAR_VELOCITY);
    observer.write(force,PxRigidDynamicGPUAPIWriteType::eFORCE);observer.write(torque,PxRigidDynamicGPUAPIWriteType::eTORQUE);step(scene);
    const PxVec3 after=observer.read(PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY);
    const PxVec3 spinAfter=observer.read(PxRigidDynamicGPUAPIReadType::eANGULAR_VELOCITY);
    const PxQuat physicalWorld=asset.q*principal;const PxVec3 localTorque=physicalWorld.rotateInv(torque);
    const PxVec3 expectedSpin=spinBefore+physicalWorld.rotate(PxVec3(localTorque.x/moments.x,localTorque.y/moments.y,localTorque.z/moments.z))/60;
    for(unsigned k=0;k<3;++k){near(after[k],before[k]+force[k]/(physicalMass*60),"native GPU candidate linear impulse response");near(spinAfter[k],expectedSpin[k],"native GPU candidate tensor torque response");}
    target->release();shape->release();step(scene);require(context.healthy(),"GPU body fixture unhealthy");
    std::puts("native verdict body candidates: full inertia/COM/provenance, batch rejection, stale-state invalidation, persistent shape transfer and analytic GPU force/torque response passed");
}
}
int main(){try{run();return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
