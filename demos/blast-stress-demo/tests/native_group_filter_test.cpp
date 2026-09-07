// Ordinary GPU aggregate collisions must agree with the native ownership view.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <array>
#include <cmath>
#include <cstdio>
#include <stdexcept>
using namespace physx;
namespace {
void require(bool value,const char* reason){if(!value)throw std::runtime_error(reason);}
void check(CUresult result){require(result==CUDA_SUCCESS,"CUDA observation failed");}
std::array<PxTransform,2> run(bool native,bool selfCollision) {
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,{},nullptr,true,true);
    auto& scene=context.scene();auto& physics=context.physics();auto& cuda=*context.cudaContextManager();
    scene.setGravity(PxVec3(0));
    auto* aggregate=physics.createAggregate(2,2,PxGetAggregateFilterHint(PxAggregateType::eGENERIC,selfCollision));
    require(aggregate,"aggregate allocation failed");
    std::array<PxRigidDynamic*,2> bodies{};std::array<PxRigidStatic*,2> walls{};
    for(unsigned i=0;i<2;++i) {
        const float sign=i?1.0f:-1.0f;
        bodies[i]=PxCreateDynamic(physics,PxTransform(PxVec3(sign*2,5,0)),PxBoxGeometry(.5f,.5f,.5f),context.material(),1);
        require(bodies[i],"body allocation failed");
        bodies[i]->setLinearDamping(0);bodies[i]->setAngularDamping(0);bodies[i]->setLinearVelocity(PxVec3(-sign*2,0,0));
        require(aggregate->addActor(*bodies[i]),"aggregate body insertion failed");
        walls[i]=PxCreateStatic(physics,PxTransform(PxVec3(sign*3.5f,5,0)),PxBoxGeometry(.5f,3,3),context.material());
        require(walls[i],"wall allocation failed");scene.addActor(*walls[i]);
    }
    scene.addAggregate(*aggregate);
    auto* sentinel=PxCreateDynamic(physics,PxTransform(PxVec3(100,100,0)),PxBoxGeometry(.5f,.5f,.5f),context.material(),1);
    sentinel->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*sentinel);
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"setup step failed");
    PxShape* shape=nullptr;sentinel->getShapes(&shape,1);
    const PxDestructionStressChunk chunks[]={{PxVec3(0,-1,0),0,0,0,PX_INVALID_U32},
        {PxVec3(0),1,1.0f/6,0,scene.getDirectGPUAPI().getShapeContactIndex(*shape)}};
    const PxDestructionStressBond bond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};
    const PxDestructionStressCluster cluster{sentinel->getGPUIndex(),PxVec3(0)};
    if(native) {
        // A stationary diagnostic structure enables the production GPU owner
        // view without asking the unqualified aggregate fracture path to run.
        PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.bonds=&bond;desc.bondCount=1;
        desc.clusters=&cluster;desc.clusterCount=1;desc.maxIterations=8192;desc.tolerance=1e-5f;
        require(scene.getDestructionScene()->configureStress(desc),"native grouping setup failed");
    }
    for(unsigned frame=0;frame<180;++frame) {
        scene.simulate(1.0f/60);PxU32 error=0;
        require(scene.fetchResults(true,&error) && !error && context.healthy(),"ordinary aggregate simulation failed");
        if(native) {const auto status=scene.getDestructionScene()->getLastStatus();
            require(!status.error && status.converged && !status.brokenBonds && !status.correctionPasses,"diagnostic structure changed during group test");}
    }
    const PxU32 indices[]={bodies[0]->getGPUIndex(),bodies[1]->getGPUIndex()};
    std::array<PxTransform,2> poses{};CUdeviceptr ids=0,values=0;CUevent ready=nullptr;
    {PxScopedCudaLock lock(cuda);check(cuMemAlloc(&ids,sizeof(indices)));check(cuMemAlloc(&values,sizeof(poses)));
        check(cuMemcpyHtoD(ids,indices,sizeof(indices)));check(cuEventCreate(&ready,CU_EVENT_DISABLE_TIMING));check(cuEventRecord(ready,nullptr));
        require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(values),reinterpret_cast<const PxU32*>(ids),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,2,ready),"aggregate pose observation failed");
        check(cuMemcpyDtoH(poses.data(),values,sizeof(poses)));check(cuEventDestroy(ready));check(cuMemFree(values));check(cuMemFree(ids));}
    std::printf("aggregate native=%u self=%u: x=(%.8f, %.8f)\n",native,selfCollision,poses[0].p.x,poses[1].p.x);
    aggregate->release();for(auto* body:bodies)body->release();for(auto* wall:walls)wall->release();sentinel->release();
    return poses;
}
}
int main() {try {
    for(bool self:{false,true}) {
        const auto reference=run(false,self),native=run(true,self);
        for(unsigned i=0;i<2;++i)require((reference[i].p-native[i].p).magnitude()<1e-5f,"native group identity changed an ordinary aggregate trajectory");
        if(self)require(native[0].p.x<-.45f && native[1].p.x>.45f,"aggregate self collisions were lost");
        else require(native[0].p.x>2.0f && native[1].p.x<-2.0f && native[0].p.x<2.6f && native[1].p.x>-2.6f,
            "aggregate self filtering or external wall collisions changed");
    }
    std::puts("GPU group controls passed: two aggregate bodies, two static walls; native diagnostic has two chunks/one bond; 180 measured steps per scene");return 0;
} catch(const std::exception& e){std::fprintf(stderr,"FAIL: %s\n",e.what());return 1;}}
