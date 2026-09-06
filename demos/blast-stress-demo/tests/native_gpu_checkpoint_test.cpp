// Captured by PhysX's native task after input upload and before solving. The
// test invokes only the internal rigid-array restore; it is not a full resim.
#include "../physx_scene.h"
#include "NpScene.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "PxgDestructionRuntime.h"
#include <extensions/PxD6Joint.h>
#include <cuda.h>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
void near(float a,float b,const char* message){if(!std::isfinite(a) || std::abs(a-b)>2e-4f*PxMax(1.0f,std::abs(b))){std::fprintf(stderr,"%s: %.9g != %.9g\n",message,a,b);throw std::runtime_error(message);}}
void check(CUresult result){if(result!=CUDA_SUCCESS){const char* name=nullptr;cuGetErrorName(result,&name);std::fprintf(stderr,"CUDA: %s\n",name?name:"");throw std::runtime_error("CUDA observation failed");}}
void step(PxScene& scene){scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"ordinary native step failed");}
template<class T> std::vector<T> read(const T* device,PxU32 count){std::vector<T> result(count);if(count)check(cuMemcpyDtoH(result.data(),CUdeviceptr(device),size_t(count)*sizeof(T)));return result;}
template<class T> void same(const std::vector<T>& a,const std::vector<T>& b,const char* message){require(a.size()==b.size() && !std::memcmp(a.data(),b.data(),a.size()*sizeof(T)),message);}
void run(bool sleeping,bool accelerations,PxSolverType::Enum solver) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,sleeping,sleeping,solver,accelerations);
    auto& scene=context.scene();auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    auto& controller=*static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController());
    auto& core=*controller.getSimulationCore();
    std::vector<PxRigidDynamic*> actors;
    auto body=[&](PxVec3 position,bool supported,bool geometry,PxVec3 velocity=PxVec3(0)) {
        auto* actor=physics.createRigidDynamic(PxTransform(position));require(actor,"body allocation failed");
        if(supported)actor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        actor->setMass(2);actor->setMassSpaceInertiaTensor(PxVec3(.2f));actor->setLinearDamping(0);actor->setAngularDamping(0);
        if(geometry){auto* shape=physics.createShape(PxSphereGeometry(.25f),context.material(),true);require(shape && actor->attachShape(*shape),"shape allocation failed");shape->release();}
        if(!supported)actor->setLinearVelocity(velocity);
        scene.addActor(*actor);actors.push_back(actor);return actor;
    };
    auto* parent=body(PxVec3(10,20,0),true,true);step(scene);
    auto* runtime=static_cast<PxgDestructionRuntime*>(scene.getDestructionScene());require(runtime,"native runtime missing");
    require(!runtime->rigidCheckpoint().count,"disabled destruction created a checkpoint");
    PxDestructionStressChunk chunk{PxVec3(0),0,0,0,PX_INVALID_U32};
    PxDestructionChunkMassProperties mass{};mass.supported=1;
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};
    PxDestructionStressDesc desc;desc.chunks=&chunk;desc.chunkCount=1;desc.chunkMassProperties=&mass;desc.clusters=&cluster;desc.clusterCount=1;
    require(runtime->configureStress(desc),"checkpoint graph configuration failed");
    auto* projectile=body(PxVec3(0,.2f,0),false,true,PxVec3(0,-6,0));
    auto* connected=body(PxVec3(0,1.2f,0),false,true,PxVec3(0,-6,0));
    auto* joint=PxD6JointCreate(physics,projectile,PxTransform(PxVec3(0,.5f,0)),connected,PxTransform(PxVec3(0,-.5f,0)));
    require(joint,"joint creation failed");
    auto* commanded=body(PxVec3(-20,10,0),false,true,PxVec3(3,0,0));
    scene.setGravity(PxVec3(0));step(scene);
    auto view=runtime->rigidCheckpoint();
    require(view.bodies && view.ready && view.generation && view.count>connected->getGPUIndex(),"ordinary scene participants missing from native checkpoint");
    require(bool(view.previous)==accelerations && bool(view.accelerations)==accelerations,"optional acceleration checkpoint mismatch");
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.ready));
        const auto saved=read(view.bodies,view.count),actual=read(core.getBodySimBufferDevicePtr().getPointer(),view.count);
        for(auto* actor:{projectile,connected}) {
            const auto id=actor->getGPUIndex();near(saved[id].linearVelocityXYZ_inverseMassW.y,-6,"checkpoint was captured after contact/joint solve");
            require(actual[id].linearVelocityXYZ_inverseMassW.y>-5,"fixture did not change contact-connected participant motion");
            near(saved[id].linearVelocityXYZ_inverseMassW.w,.5f,"checkpoint missed newly uploaded mass");
        }
        near(saved[projectile->getGPUIndex()].body2World.p.y,.2f,"checkpoint missed initial projectile pose");
    }
    // A direct GPU force command must be captured before the trial consumes it.
    const PxU64 firstGeneration=view.generation;
    const auto commandForce=[&]{PxScopedCudaLock lock(cuda);CUdeviceptr ids=0,forces=0;check(cuMemAlloc(&ids,sizeof(PxU32)));check(cuMemAlloc(&forces,sizeof(PxVec3)));
        const PxU32 id=commanded->getGPUIndex();const PxVec3 force(12,0,0);check(cuMemcpyHtoD(ids,&id,sizeof(id)));check(cuMemcpyHtoD(forces,&force,sizeof(force)));
        require(scene.getDirectGPUAPI().setRigidDynamicData(reinterpret_cast<void*>(forces),reinterpret_cast<const PxU32*>(ids),PxRigidDynamicGPUAPIWriteType::eFORCE,1),"GPU force command failed");
        check(cuCtxSynchronize());check(cuMemFree(ids));check(cuMemFree(forces));
    };
    commandForce();step(scene);view=runtime->rigidCheckpoint();require(view.generation>firstGeneration,"checkpoint generation did not advance");
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.ready));const auto saved=read(view.bodies,view.count),actual=read(core.getBodySimBufferDevicePtr().getPointer(),view.count);const auto id=commanded->getGPUIndex();
        near(saved[id].linearVelocityXYZ_inverseMassW.x,3,"input velocity was captured after trial integration");
        near(saved[id].externalLinearAcceleration.x,6,"input force was omitted or consumed before checkpoint");
        near(actual[id].linearVelocityXYZ_inverseMassW.x,3.1f,"ordinary force fixture integration mismatch");
        near(actual[id].externalLinearAcceleration.x,0,"ordinary trial did not consume transient force");
    }
    const PxU32 oldCount=view.count;const PxU64 oldGeneration=view.generation;
    for(unsigned i=0;i<257;++i)body(PxVec3(100+float(i),20,0),true,false);
    step(scene);view=runtime->rigidCheckpoint();require(view.count>=oldCount+257,"checkpoint truncated scene body-pool growth");
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.ready));const auto saved=read(view.bodies,view.count);
        for(size_t i=actors.size()-257;i<actors.size();++i)near(saved[actors[i]->getGPUIndex()].body2World.p.x,100+float(i-(actors.size()-257)),"grown checkpoint lost a native slot");
    }
    // Clearing/reinstantiating must invalidate handles even if allocation sizes
    // and raw addresses are recycled. No old generation can be restored.
    require(runtime->clearStress(),"checkpoint clear failed");require(!runtime->rigidCheckpoint().count && !runtime->rigidCheckpoint().ready,"clear exposed stale checkpoint");
    require(runtime->configureStress(desc),"checkpoint reconfiguration failed");commandForce();step(scene);view=runtime->rigidCheckpoint();require(view.generation>oldGeneration,"reconfiguration recycled checkpoint generation");
    {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.ready));
        auto* bodies=core.getBodySimBufferDevicePtr().getPointer();auto* previous=core.getBodySimPrevVelocitiesBufferDevicePtr().getPointer();auto* accel=core.getRigidBodyAccelerationsDevice();
        const auto saved=read(view.bodies,view.count),before=read(bodies,view.count);
        near(saved[commanded->getGPUIndex()].externalLinearAcceleration.x,6,"restore fixture lost its submitted force");
        near(before[commanded->getGPUIndex()].externalLinearAcceleration.x,0,"restore fixture did not consume the submitted force");
        const auto savedPrevious=accelerations?read(view.previous,view.count):std::vector<PxgBodySimVelocities>();
        const auto savedAccel=accelerations?read(view.accelerations,view.count):std::vector<PxgRigidBodyAcceleration>();
        CUstream stream;check(cuStreamCreate(&stream,CU_STREAM_NON_BLOCKING));
        require(!runtime->restoreRigidState(bodies,previous,accel,view.count,oldGeneration,stream),"stale checkpoint accepted");
        require(!runtime->restoreRigidState(bodies,previous,accel,view.count-1,view.generation,stream),"undersized restore destination accepted");
        if(accelerations)require(!runtime->restoreRigidState(bodies,nullptr,accel,view.count,view.generation,stream),"partial acceleration restore accepted");
        same(before,read(bodies,view.count),"invalid restore modified native GPU state");
        require(runtime->restoreRigidState(bodies,previous,accel,view.count,view.generation,stream),"internal rigid-state restore failed");
        check(cuEventSynchronize(runtime->rigidCheckpoint().ready));same(saved,read(bodies,view.count),"GPU body restore was incomplete");
        near(read(bodies+commanded->getGPUIndex(),1)[0].externalLinearAcceleration.x,6,"transient GPU force was not restored for correction");
        if(accelerations){same(savedPrevious,read(previous,view.count),"previous velocities were not restored");same(savedAccel,read(accel,view.count),"observed accelerations were not restored");}
        check(cuStreamDestroy(stream));
    }
    require(runtime->clearStress(),"final clear failed");joint->release();for(auto* actor:actors)actor->release();
    require(context.healthy(),"checkpoint fixture GPU failure");
    std::printf("native rigid checkpoint: contacts/joints, GPU force, 257-body growth, invalidation and full array restore; sleep=%u acceleration=%u solver=%u passed\n",unsigned(sleeping),unsigned(accelerations),unsigned(solver));
}
}
int main(){try{for(bool sleeping:{false,true})for(bool accelerations:{false,true})for(auto solver:{PxSolverType::eTGS,PxSolverType::ePGS})run(sleeping,accelerations,solver);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
