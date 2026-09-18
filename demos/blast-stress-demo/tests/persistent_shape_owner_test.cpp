// Tests the internal ownership boundary using actual GPU collision/rigid solves.
// No stress/replay adapter participates. The native fracture task will own this
// boundary once solver-body allocation and checkpoint/correction are connected.
#include "../physx_scene.h"
#include "NpShapeManager.h"
#include "PxContact.h"
#include "cooking/PxCooking.h"
#include <cuda.h>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool ok, const char* message) { if(!ok) throw std::runtime_error(message); }
void step(PxScene& s) { s.simulate(1.0f/60); PxU32 error=~0u; require(s.fetchResults(true,&error) && !error,"simulation failed"); }
void setGpuPoses(PxDirectGPUAPI& gpu,PxCudaContextManager& cuda,const std::vector<PxU32>& ids,const std::vector<PxTransform>& poses)
{
    require(ids.size()==poses.size() && !ids.empty(),"invalid GPU pose fixture");
    CUdeviceptr index=0,data=0;
    {PxScopedCudaLock lock(cuda);
        require(cuMemAlloc(&index,ids.size()*sizeof(PxU32))==CUDA_SUCCESS && cuMemAlloc(&data,poses.size()*sizeof(PxTransform))==CUDA_SUCCESS,"GPU pose fixture allocation failed");
        require(cuMemcpyHtoD(index,ids.data(),ids.size()*sizeof(PxU32))==CUDA_SUCCESS && cuMemcpyHtoD(data,poses.data(),poses.size()*sizeof(PxTransform))==CUDA_SUCCESS,"GPU pose fixture upload failed");}
    require(gpu.setRigidDynamicData(reinterpret_cast<void*>(data),reinterpret_cast<const PxU32*>(index),PxRigidDynamicGPUAPIWriteType::eGLOBAL_POSE,PxU32(ids.size())),"GPU-only pose edit failed");
    {PxScopedCudaLock lock(cuda);cuMemFree(index);cuMemFree(data);}
}
PxShape* makeShape(blast_demo::PhysXScene& context,unsigned kind)
{
    auto& physics=context.physics();auto& material=context.material();
    if(kind==0)return physics.createShape(PxBoxGeometry(.5f,.5f,.5f),material,true);
    if(kind==1)return physics.createShape(PxSphereGeometry(.5f),material,true);
    if(kind==2)return physics.createShape(PxCapsuleGeometry(.3f,.2f),material,true);
    const PxVec3 vertices[]={PxVec3(-.5f,-.5f,-.5f),PxVec3(.5f,-.5f,-.5f),PxVec3(-.5f,.5f,-.5f),PxVec3(.5f,.5f,-.5f),
        PxVec3(-.5f,-.5f,.5f),PxVec3(.5f,-.5f,.5f),PxVec3(-.5f,.5f,.5f),PxVec3(.5f,.5f,.5f)};
    PxConvexMeshDesc desc;desc.points.count=8;desc.points.stride=sizeof(PxVec3);desc.points.data=vertices;desc.flags=PxConvexFlag::eCOMPUTE_CONVEX;
    auto* mesh=PxCreateConvexMesh(context.cookingParams(),desc,physics.getPhysicsInsertionCallback());
    require(mesh && mesh->isGpuCompatible(),"fixture convex cooking failed");
    auto* shape=physics.createShape(PxConvexMeshGeometry(mesh,PxMeshScale(PxVec3(1,.8f,1.2f),PxQuat(.25f,PxVec3(1,0,0)))),material,true);
    mesh->release();return shape;
}
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
unsigned contactCount(PxDirectGPUAPI& gpu,PxCudaContextManager& cuda,PxU32 firstID,PxU32 secondID,PxRigidDynamic* original,PxRigidDynamic* separated,const PxVec3* expectedCenter=nullptr)
{
    CUdeviceptr pairBuffer=0,countBuffer=0;
    { PxScopedCudaLock lock(cuda);
      require(cuMemAlloc(&pairBuffer,1024*sizeof(PxGpuContactPair))==CUDA_SUCCESS,"allocate observer");
      require(cuMemAlloc(&countBuffer,sizeof(PxU32))==CUDA_SUCCESS,"allocate observer count"); }
    require(gpu.copyContactData(reinterpret_cast<PxGpuContactPair*>(pairBuffer),reinterpret_cast<PxU32*>(countBuffer),1024),"contact observation failed");
    unsigned observed=0,matchingPairs=0;
    { PxScopedCudaLock lock(cuda);PxU32 count=0;
      require(cuMemcpyDtoH(&count,countBuffer,sizeof(count))==CUDA_SUCCESS && count<=1024,"contact observation overflow");
      std::vector<PxGpuContactPair> pairs(count);if(count)require(cuMemcpyDtoH(pairs.data(),pairBuffer,count*sizeof(PxGpuContactPair))==CUDA_SUCCESS,"contact read failed");
      for(const auto& p:pairs) {
        if((p.transformCacheRef0==firstID && p.transformCacheRef1==secondID) || (p.transformCacheRef1==firstID && p.transformCacheRef0==secondID)) {
          const bool forward=p.transformCacheRef0==firstID;
          require((forward?p.actor0:p.actor1)==original && (forward?p.actor1:p.actor0)==separated,"GPU contact retained old actor ownership");
          require((forward?p.nodeIndex1:p.nodeIndex0).index()==separated->getGPUIndex(),"GPU contact retained old solver body");
          if(expectedCenter && p.nbContacts) {
            PxContact point;
            require(cuMemcpyDtoH(&point,CUdeviceptr(p.contactPoints),sizeof(point))==CUDA_SUCCESS,"contact point read failed");
            require(point.contact.isFinite() && (point.contact-*expectedCenter).magnitude()<2.0f,"contact geometry used stale body pose");
          }
          observed+=p.nbContacts;++matchingPairs;
        }
      }
      cuMemFree(pairBuffer);cuMemFree(countBuffer);
    }
    require(matchingPairs<=1,"duplicate contact manager after ownership refresh");
    return observed;
}
void run(bool rotated,bool staleGpuPose=false,unsigned geometry=0,bool freshTarget=false,unsigned hostCommand=0) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,true);
    auto& physics=context.physics();auto& scene=context.scene();scene.setGravity(PxVec3(0));
    PxTransform asset(PxVec3(10,5,3),rotated?PxQuat(0.6f,PxVec3(0.2f,0.3f,1).getNormalized()):PxQuat(PxIdentity));
    PxVec3 axis=asset.q.rotate(PxVec3(1,0,0));
    auto* original=physics.createRigidDynamic(asset);
    original->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    auto* separated=physics.createRigidDynamic(asset*PxTransform(PxVec3(0.45f,0,0)));
    if(rotated)separated->setCMassLocalPose(PxTransform(PxVec3(0.2f,-0.3f,0.1f),PxQuat(0.4f,PxVec3(0,0,1))));
    separated->setMass(1);separated->setMassSpaceInertiaTensor(PxVec3(1.0f/6));
    separated->setLinearDamping(0);separated->setAngularDamping(0);
    auto* first=makeShape(context,geometry);
    auto* second=makeShape(context,geometry);
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
    if(staleGpuPose) {
        const PxTransform cpuPose=original->getGlobalPose();
        asset=PxTransform(PxVec3(110,45,33),PxQuat(.37f,PxVec3(1,0,0))*asset.q);axis=asset.q.rotate(PxVec3(1,0,0));
        setGpuPoses(gpu,*context.cudaContextManager(),{original->getGPUIndex(),separated->getGPUIndex()},
            {asset,asset*PxTransform(PxVec3(.45f,0,0))});
        require((original->getGlobalPose().p-cpuPose.p).magnitude()<1e-6f,"fixture accidentally published GPU poses to CPU");
    }
    const auto hostPoseCommand=[&] {
        asset=PxTransform(PxVec3(-80,75,-40),PxQuat(.31f,PxVec3(0,1,0))*asset.q);axis=asset.q.rotate(PxVec3(1,0,0));
        original->setGlobalPose(asset);separated->setGlobalPose(asset*PxTransform(PxVec3(.45f,0,0)));
    };
    if(hostCommand==1)hostPoseCommand();
    require(NpShapeManager::rebindShape(*original,*separated,*second,PxTransform(PxIdentity)),"persistent ownership transfer rejected");
    if(freshTarget) {
        // A queued GPU refresh must be cancelled if the final owner has not
        // been uploaded. Its only authoritative initial pose is still on CPU.
        auto* fresh=physics.createRigidDynamic(asset*PxTransform(PxVec3(.45f,0,0)));
        if(rotated)fresh->setCMassLocalPose(separated->getCMassLocalPose());
        fresh->setMass(1);fresh->setMassSpaceInertiaTensor(PxVec3(1.0f/6));
        fresh->setLinearDamping(0);fresh->setAngularDamping(0);scene.addActor(*fresh);
        require(NpShapeManager::rebindShape(*separated,*fresh,*second,PxTransform(PxIdentity)),"fresh-body owner transfer rejected");
        separated->release();separated=fresh;
    }
    if(hostCommand==2)hostPoseCommand();
    require(original->getNbShapes()==1 && separated->getNbShapes()==1 && second->getActor()==separated,"CPU membership stale after transfer");
    require(second->getReferenceCount()==references,"transfer changed geometry lifetime count");
    require(gpu.getShapeContactIndex(*first)==firstID && gpu.getShapeContactIndex(*second)==secondID,"transfer recreated contact identity");
    step(scene);
    const unsigned observed=contactCount(gpu,*context.cudaContextManager(),firstID,secondID,original,separated,&asset.p);
    require(observed>0,"newly separated overlapping fragments missed GPU contact");
    observeMotion(gpu,*context.cudaContextManager(),original,separated);
    std::printf("accepted GPU motion: x=%g vx=%g\n",separated->getGlobalPose().p.x,separated->getLinearVelocity().x);
    require((separated->getGlobalPose().p-asset.p).dot(axis)>0.45f,"depenetration did not move separated body's GPU motion");
    require((original->getGlobalPose().p-asset.p).magnitude()<2e-4f,"prescribed source cluster moved");
    PxRaycastBuffer hit;require(scene.raycast(asset.p+5.0f*axis,-axis,5,hit),"transferred query shape missing");
    require(hit.block.actor==separated && hit.block.shape==second,"query mirror retained old owner");
    if(hostCommand) {
        // Another commanded pose must refresh collision bounds even when no
        // shape instance or ownership mapping changes during this step.
        hostPoseCommand();step(scene);
        require(contactCount(gpu,*context.cudaContextManager(),firstID,secondID,original,separated,&asset.p)>0,"standalone host pose command missed GPU contact");
        observeMotion(gpu,*context.cudaContextManager(),original,separated);
        require((separated->getGlobalPose().p-asset.p).dot(axis)>.45f,"standalone host pose command lost collision response");
        require((original->getGlobalPose().p-asset.p).magnitude()<2e-4f,"standalone host command moved prescribed body");
    }
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
    std::printf("persistent shape owner: geometry=%u rotated=%u GPU-pose=%u fresh-target=%u host-command=%u passed\n",geometry,rotated,staleGpuPose,freshTarget,hostCommand);
}
void growth() {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,true,false);
    auto& physics=context.physics();auto& scene=context.scene();scene.setGravity(PxVec3(0));
    constexpr unsigned count=257;
    const PxTransform cpuPose(PxVec3(10,40,20)),gpuPose(PxVec3(210,60,-10));
    auto* original=physics.createRigidDynamic(cpuPose);original->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    std::vector<PxRigidDynamic*> bodies;std::vector<PxShape*> first,second;
    for(unsigned i=0;i<count;++i) {
        const float x=3.0f*i;
        auto* a=makeShape(context,0);auto* b=makeShape(context,0);
        a->setLocalPose(PxTransform(PxVec3(x-.45f,0,0)));b->setLocalPose(PxTransform(PxVec3(x+.45f,0,0)));
        require(original->attachShape(*a) && original->attachShape(*b),"growth geometry setup failed");first.push_back(a);second.push_back(b);
        auto* body=physics.createRigidDynamic(cpuPose*PxTransform(PxVec3(x+.45f,0,0)));
        body->setMass(1);body->setMassSpaceInertiaTensor(PxVec3(1.0f/6));body->setLinearDamping(0);body->setAngularDamping(0);
        bodies.push_back(body);scene.addActor(*body);
    }
    // An ordinary GPU pose command must survive update-flag capacity growth.
    // This pair is outside the destruction/rebinding request set.
    auto* marker=physics.createRigidDynamic(PxTransform(PxVec3(1490,40,0)));
    auto* anchor=physics.createRigidDynamic(PxTransform(PxVec3(1500,40,0)));
    anchor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    auto* markerShape=makeShape(context,0);auto* anchorShape=makeShape(context,0);
    require(marker->attachShape(*markerShape) && anchor->attachShape(*anchorShape),"ordinary growth control setup failed");
    scene.addActor(*marker);scene.addActor(*anchor);
    scene.addActor(*original);step(scene);
    auto& gpu=scene.getDirectGPUAPI();auto& cuda=*context.cudaContextManager();
    std::vector<PxU32> ids{original->getGPUIndex()},firstIDs,secondIDs;std::vector<PxTransform> poses{gpuPose};
    for(unsigned i=0;i<count;++i) {
        ids.push_back(bodies[i]->getGPUIndex());poses.push_back(gpuPose*PxTransform(PxVec3(3.0f*i+.45f,0,0)));
        firstIDs.push_back(gpu.getShapeContactIndex(*first[i]));secondIDs.push_back(gpu.getShapeContactIndex(*second[i]));
    }
    setGpuPoses(gpu,cuda,ids,poses);
    require(NpShapeManager::rebindShape(*original,*bodies[0],*second[0],PxTransform(PxIdentity)),"single refresh setup failed");
    step(scene);require(contactCount(gpu,cuda,firstIDs[0],secondIDs[0],original,bodies[0])>0,"initial refresh contact missing");
    // Grow the persistent request buffer from one to 257 and collapse repeated
    // edits. All CPU poses still describe the old location of the building.
    setGpuPoses(gpu,cuda,{bodies[0]->getGPUIndex()},{poses[1]});
    for(unsigned i=0;i<count;++i) {
        if(i)require(NpShapeManager::rebindShape(*original,*bodies[i],*second[i],PxTransform(PxIdentity)),"batch split failed");
        for(unsigned repeat=0;repeat<3;++repeat) {
            require(NpShapeManager::rebindShape(*bodies[i],*original,*second[i],PxTransform(PxVec3(3.0f*i+.45f,0,0))),"batch merge failed");
            require(NpShapeManager::rebindShape(*original,*bodies[i],*second[i],PxTransform(PxIdentity)),"repeated batch split failed");
        }
    }
    // Force shape/transform/bounds storage to grow during the same step. These
    // ordinary new shapes use their initial CPU poses and do not overlap.
    auto* fresh=physics.createRigidStatic(PxTransform(PxVec3(0,200,1000)));
    for(unsigned i=0;i<1100;++i) {
        auto* shape=makeShape(context,0);shape->setLocalPose(PxTransform(PxVec3(3.0f*i,0,0)));
        require(fresh->attachShape(*shape),"growth static setup failed");shape->release();
    }
    setGpuPoses(gpu,cuda,{marker->getGPUIndex()},{PxTransform(PxVec3(1499.8f,40,0))});
    scene.addActor(*fresh);step(scene);
    require(contactCount(gpu,cuda,gpu.getShapeContactIndex(*markerShape),gpu.getShapeContactIndex(*anchorShape),marker,anchor)>0,
        "bounds capacity growth lost an ordinary GPU pose command update");
    require((original->getGlobalPose().p-cpuPose.p).magnitude()<1e-6f,"growth fixture published CPU poses");
    for(unsigned i=0;i<count;++i) {
        require(gpu.getShapeContactIndex(*first[i])==firstIDs[i] && gpu.getShapeContactIndex(*second[i])==secondIDs[i],"growth changed persistent shape identity");
        require(contactCount(gpu,cuda,firstIDs[i],secondIDs[i],original,bodies[i])>0,"grown refresh batch missed contact or retained wrong owner");
        require(NpShapeManager::rebindShape(*bodies[i],*original,*second[i],PxTransform(PxVec3(3.0f*i+.45f,0,0))),"queued teardown merge failed");
    }
    // Cancel every outstanding refresh by releasing the actual geometry before
    // upload, then advance again to exercise empty compaction after growth.
    original->release();for(auto* body:bodies)body->release();
    for(auto* shape:first)shape->release();for(auto* shape:second)shape->release();fresh->release();
    marker->release();anchor->release();markerShape->release();anchorShape->release();step(scene);
    require(context.healthy(),"grown GPU ownership scene failed");
    std::puts("persistent GPU bounds: 1-to-257 queue growth, repeated edits, simultaneous shape storage growth and cancelled teardown passed");
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
int main(int argc,char** argv){try{if(argc>1 && std::strcmp(argv[1],"--gpu-bounds")==0){for(unsigned kind=0;kind<4;++kind){run(false,true,kind);run(true,true,kind);}run(false,true,0,true);run(true,true,0,true);}else if(argc>1 && std::strcmp(argv[1],"--host-pose-bounds")==0){for(unsigned when:{1u,2u}){run(false,true,0,false,when);run(true,true,0,false,when);}}else if(argc>1 && std::strcmp(argv[1],"--gpu-bounds-growth")==0)growth();else if(argc>1)overflow(std::strcmp(argv[1],"--overflow-split")==0);else {run(false);run(true);}return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
