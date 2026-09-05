// Tests the internal ownership boundary using actual GPU collision/rigid solves.
// No stress/replay adapter participates. The native fracture task will own this
// boundary once solver-body allocation and checkpoint/correction are connected.
#include "../physx_scene.h"
#include "NpShapeManager.h"
#include "PxContact.h"
#include <cuda.h>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool ok, const char* message) { if(!ok) throw std::runtime_error(message); }
void step(PxScene& s) { s.simulate(1.0f/60); PxU32 error=~0u; require(s.fetchResults(true,&error) && !error,"simulation failed"); }
// Direct GPU scenes expose solved contacts through device views; ordinary CPU
// callbacks/actor getters are not authoritative observations in this mode.
void observeMotion(PxDirectGPUAPI& api,PxCudaContextManager& cuda,PxRigidDynamic* a,PxRigidDynamic* b)
{
    CUdeviceptr indices=0,data=0;const PxU32 ids[]={a->getGPUIndex(),b->getGPUIndex()};
    PxTransform poses[2];PxVec3 linear[2],angular[2];
    {PxScopedCudaLock lock(cuda);
     require(cuMemAlloc(&indices,sizeof(ids))==CUDA_SUCCESS && cuMemAlloc(&data,sizeof(poses))==CUDA_SUCCESS,"motion observer allocation failed");
     require(cuMemcpyHtoD(indices,ids,sizeof(ids))==CUDA_SUCCESS,"observer indices failed");}
    const auto read=[&](void* out,size_t size,PxRigidDynamicGPUAPIReadType::Enum type){
      require(api.getRigidDynamicData(reinterpret_cast<void*>(data),reinterpret_cast<const PxU32*>(indices),type,2),"GPU motion observation failed");
      PxScopedCudaLock lock(cuda);require(cuMemcpyDtoH(out,data,size)==CUDA_SUCCESS,"motion observer copy failed");
    };
    read(poses,sizeof(poses),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE);
    read(linear,sizeof(linear),PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY);
    read(angular,sizeof(angular),PxRigidDynamicGPUAPIReadType::eANGULAR_VELOCITY);
    PxRigidDynamic* actors[]={a,b};require(api.publishRigidDynamicHostData(actors,poses,linear,angular,2),"committed CPU query observation rejected");
    {PxScopedCudaLock lock(cuda);cuMemFree(indices);cuMemFree(data);}
}
unsigned contactCount(PxDirectGPUAPI& gpu,PxCudaContextManager& cuda,PxU32 firstID,PxU32 secondID,PxRigidDynamic* original,PxRigidDynamic* separated)
{
    CUdeviceptr pairBuffer=0,countBuffer=0;
    { PxScopedCudaLock lock(cuda);
      require(cuMemAlloc(&pairBuffer,256*sizeof(PxGpuContactPair))==CUDA_SUCCESS,"allocate observer");
      require(cuMemAlloc(&countBuffer,sizeof(PxU32))==CUDA_SUCCESS,"allocate observer count"); }
    require(gpu.copyContactData(reinterpret_cast<PxGpuContactPair*>(pairBuffer),reinterpret_cast<PxU32*>(countBuffer),256),"contact observation failed");
    unsigned observed=0,matchingPairs=0;
    { PxScopedCudaLock lock(cuda);PxU32 count=0;
      require(cuMemcpyDtoH(&count,countBuffer,sizeof(count))==CUDA_SUCCESS && count<=256,"contact observation overflow");
      std::vector<PxGpuContactPair> pairs(count);if(count)require(cuMemcpyDtoH(pairs.data(),pairBuffer,count*sizeof(PxGpuContactPair))==CUDA_SUCCESS,"contact read failed");
      for(const auto& p:pairs) {
        if((p.transformCacheRef0==firstID && p.transformCacheRef1==secondID) || (p.transformCacheRef1==firstID && p.transformCacheRef0==secondID)) {
          const bool forward=p.transformCacheRef0==firstID;
          require((forward?p.actor0:p.actor1)==original && (forward?p.actor1:p.actor0)==separated,"GPU contact retained old actor ownership");
          require((forward?p.nodeIndex1:p.nodeIndex0).index()==separated->getGPUIndex(),"GPU contact retained old solver body");
          observed+=p.nbContacts;++matchingPairs;
        }
      }
      cuMemFree(pairBuffer);cuMemFree(countBuffer);
    }
    require(matchingPairs<=1,"duplicate contact manager after ownership refresh");
    return observed;
}
void run(bool rotated) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto& physics=context.physics();auto& scene=context.scene();scene.setGravity(PxVec3(0));
    const PxTransform asset(PxVec3(10,5,3),rotated?PxQuat(0.6f,PxVec3(0.2f,0.3f,1).getNormalized()):PxQuat(PxIdentity));
    const PxVec3 axis=asset.q.rotate(PxVec3(1,0,0));
    auto* original=physics.createRigidDynamic(asset);
    original->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    auto* separated=physics.createRigidDynamic(asset*PxTransform(PxVec3(0.45f,0,0)));
    if(rotated)separated->setCMassLocalPose(PxTransform(PxVec3(0.2f,-0.3f,0.1f),PxQuat(0.4f,PxVec3(0,0,1))));
    separated->setMass(1);separated->setMassSpaceInertiaTensor(PxVec3(1.0f/6));
    separated->setLinearDamping(0);separated->setAngularDamping(0);
    auto* first=physics.createShape(PxBoxGeometry(0.5f,0.5f,0.5f),context.material(),true);
    auto* second=physics.createShape(PxBoxGeometry(0.5f,0.5f,0.5f),context.material(),true);
    first->setLocalPose(PxTransform(PxVec3(-0.45f,0,0)));second->setLocalPose(PxTransform(PxVec3(0.45f,0,0)));
    require(original->attachShape(*first) && original->attachShape(*second),"initial geometry attachment failed");
    scene.addActor(*original);scene.addActor(*separated);
    step(scene);
    auto& gpu=scene.getDirectGPUAPI();const auto firstID=gpu.getShapeContactIndex(*first),secondID=gpu.getShapeContactIndex(*second);
    require(firstID!=PX_INVALID_U32 && secondID!=PX_INVALID_U32 && firstID!=secondID,"invalid persistent identities");
    require(!contactCount(gpu,*context.cudaContextManager(),firstID,secondID,original,original),"intact cluster produced self-contact");
    const auto references=second->getReferenceCount();
    auto* aggregate=physics.createAggregate(1,1,PxGetAggregateFilterHint(PxAggregateType::eGENERIC,false));scene.addAggregate(*aggregate);
    require(!NpShapeManager::rebindShape(*original,*separated,*second,PxTransform(PxIdentity)),"unqualified aggregate invalidation accepted");
    require(original->getNbShapes()==2 && separated->getNbShapes()==0 && second->getActor()==original,"rejected transfer mutated ownership");
    scene.removeAggregate(*aggregate);aggregate->release();
    require(!NpShapeManager::rebindShape(*original,*original,*second,PxTransform(PxIdentity)),"same-owner transfer accepted");
    require(NpShapeManager::rebindShape(*original,*separated,*second,PxTransform(PxIdentity)),"persistent ownership transfer rejected");
    require(original->getNbShapes()==1 && separated->getNbShapes()==1 && second->getActor()==separated,"CPU membership stale after transfer");
    require(second->getReferenceCount()==references,"transfer changed geometry lifetime count");
    require(gpu.getShapeContactIndex(*first)==firstID && gpu.getShapeContactIndex(*second)==secondID,"transfer recreated contact identity");
    step(scene);
    const unsigned observed=contactCount(gpu,*context.cudaContextManager(),firstID,secondID,original,separated);
    require(observed>0,"newly separated overlapping fragments missed GPU contact");
    observeMotion(gpu,*context.cudaContextManager(),original,separated);
    std::printf("accepted GPU motion: x=%g vx=%g\n",separated->getGlobalPose().p.x,separated->getLinearVelocity().x);
    require((separated->getGlobalPose().p-asset.p).dot(axis)>0.45f,"depenetration did not move separated body's GPU motion");
    require((original->getGlobalPose().p-asset.p).magnitude()<2e-4f,"prescribed source cluster moved");
    PxRaycastBuffer hit;require(scene.raycast(asset.p+5.0f*axis,-axis,5,hit),"transferred query shape missing");
    require(hit.block.actor==separated && hit.block.shape==second,"query mirror retained old owner");
    // Move it back while contact exists. Old solver rows must disappear, and
    // future same-owner overlaps must be filtered without changing identities.
    const PxTransform world=separated->getGlobalPose()*second->getLocalPose();
    require(NpShapeManager::rebindShape(*separated,*original,*second,original->getGlobalPose().getInverse()*world),"return ownership transfer rejected");
    require(separated->getNbShapes()==0 && original->getNbShapes()==2,"return membership mismatch");
    // Several ownership updates before one upload must collapse to one final
    // shape write. Intermediate owners must never leak into contact rows.
    for(unsigned i=0;i<4;++i) {
      require(NpShapeManager::rebindShape(*original,*separated,*second,separated->getGlobalPose().getInverse()*world),"queued split rejected");
      require(NpShapeManager::rebindShape(*separated,*original,*second,original->getGlobalPose().getInverse()*world),"queued merge rejected");
    }
    step(scene);
    require(!contactCount(gpu,*context.cudaContextManager(),firstID,secondID,original,original),"stale contact survived ownership merge");
    // Repeated explicit refilter requests, plus remove-before-upload, exercise
    // pending refresh lifetime and handle reuse.
    for(unsigned i=0;i<4;++i) { scene.resetFiltering(*original);step(scene);require(gpu.getShapeContactIndex(*second)==secondID,"filter reset recreated geometry identity"); }
    scene.resetFiltering(*original);
    require(NpShapeManager::rebindShape(*original,*separated,*second,separated->getGlobalPose().getInverse()*world),"last queued split rejected");
    original->release();separated->release();
    require(second->getReferenceCount()==references-1,"owner release lost or duplicated shape reference");
    // Free geometry before the queued upload, not merely before the next solve.
    first->release();second->release();step(scene);
    require(context.healthy(),"GPU scene health failure");
    std::puts("persistent shape owner: same-bound pair discovery, new-body response, queries, merge, identity and release passed");
}
void overflow(bool splitFetch) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto& physics=context.physics();
    PxSceneDesc desc(physics.getTolerancesScale());desc.gravity=PxVec3(0);
    desc.cpuDispatcher=context.scene().getCpuDispatcher();desc.cudaContextManager=context.cudaContextManager();
    desc.flags=context.scene().getFlags();desc.broadPhaseType=PxBroadPhaseType::eGPU;
    desc.filterShader=PxDefaultSimulationFilterShader;desc.gpuDynamicsConfig.foundLostPairsCapacity=4;
    auto* scene=physics.createScene(desc);require(scene,"overflow fixture scene creation failed");
    auto* a=physics.createRigidDynamic(PxTransform(PxIdentity));a->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    auto* b=physics.createRigidDynamic(PxTransform(PxIdentity));std::vector<PxShape*> shapes;
    for(unsigned i=0;i<12;++i) {
      auto* shape=physics.createShape(PxBoxGeometry(0.5f,0.5f,0.5f),context.material(),true);
      require(a->attachShape(*shape),"overflow geometry setup failed");shapes.push_back(shape);
    }
    scene->addActor(*a);scene->addActor(*b);step(*scene);
    for(unsigned i=0;i<6;++i)require(NpShapeManager::rebindShape(*a,*b,*shapes[i],PxTransform(PxIdentity)),"overflow owner preparation failed");
    scene->simulate(1.0f/60);
    if (splitFetch) {
      const PxContactPairHeader* pairs=reinterpret_cast<const PxContactPairHeader*>(size_t(1));PxU32 count=123;
      require(!scene->fetchResultsStart(pairs,count,true) && !pairs && !count,"split fetch published output from failed topology refresh");
    } else {
      PxU32 error=0;const bool completed=scene->fetchResults(true,&error);
      require(!completed && error,"truncated ownership overlap set was accepted as a complete step");
    }
    PxU32 retryError=0;
    require(!scene->fetchResults(true,&retryError) && retryError,"failed scene retry did not retain explicit error");
    require(context.errors().hadCapacityWarning(),"missing explicit capacity diagnosis");
    a->release();b->release();for(auto* shape:shapes)shape->release();scene->release();
    std::puts("persistent ownership overlap overflow failed the step explicitly");
}
}
int main(int argc,char** argv){try{if(argc>1)overflow(std::strcmp(argv[1],"--overflow-split")==0);else {run(false);run(true);}return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
