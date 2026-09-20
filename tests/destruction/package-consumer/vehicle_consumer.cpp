// SPDX-License-Identifier: BSD-3-Clause
// The packaged vehicle on a native GPU scene: create, drive, read back,
// release. Built only against the installed PhysXDestruction package.
#include <PxPhysicsAPI.h>
#include <PxNativeVehicle.h>
#include <extensions/PxDefaultCpuDispatcher.h>
#include <cstdio>

int main() {
    using namespace physx;
    PxDefaultAllocator allocator;PxDefaultErrorCallback errors;
    auto* foundation=PxCreateFoundation(PX_PHYSICS_VERSION,allocator,errors);if(!foundation)return 1;
    auto* physics=PxCreatePhysics(PX_PHYSICS_VERSION,*foundation,PxTolerancesScale());if(!physics)return 2;
    if(!PxInitExtensions(*physics,nullptr))return 3;
    PxCudaContextManagerDesc cudaDesc;
    auto* cuda=PxCreateCudaContextManager(*foundation,cudaDesc);
    if(!cuda || !cuda->contextIsValid())return 6;
    auto* dispatcher=PxDefaultCpuDispatcherCreate(1);
    PxSceneDesc desc(physics->getTolerancesScale());
    desc.gravity=PxVec3(0,-9.81f,0);desc.cpuDispatcher=dispatcher;desc.filterShader=PxDefaultSimulationFilterShader;
    desc.cudaContextManager=cuda;desc.flags|=PxSceneFlag::eENABLE_GPU_DYNAMICS|PxSceneFlag::eENABLE_PCM;desc.broadPhaseType=PxBroadPhaseType::eGPU;
    auto* scene=physics->createScene(desc);if(!scene)return 4;
    if(!scene->getDestructionScene())return 5;
    auto* material=physics->createMaterial(0.6f,0.6f,0);
    auto* ground=PxCreatePlane(*physics,PxPlane(0,1,0,0),*material);scene->addActor(*ground);
    PxCookingParams cooking(physics->getTolerancesScale());cooking.buildGPUData=true;
    native::NativeVehicleDesc carDesc;carDesc.sweepRoadQueries=true;
    auto* car=native::NativeVehicle::create(*physics,*scene,cooking,*material,carDesc,PxTransform(PxVec3(0,0.1f,0)),"consumer");
    if(!car)return 7;
    bool ok=car->constraintCount()==1 && car->chassisShape() && car->actor();
    car->setCommands(1,0,0,0);
    for(unsigned i=0;i<120 && ok;++i){car->step(1.0f/60);scene->simulate(1.0f/60);PxU32 error=0;ok&=scene->fetchResults(true,&error)&&!error;}
    const auto state=car->state();
    ok&=state.forwardSpeed>3 && state.pose.p.z>3 && state.pose.p.y>-0.2f && state.pose.p.y<0.3f;
    for(unsigned w=0;w<4;++w)ok&=state.wheels[w].onRoad && state.wheels[w].roadActor==ground;
    ok&=scene->getDestructionScene()->getLastStatus().correctionBlockers==0;
    std::printf("native vehicle consumer: speed=%.2f m/s z=%.2f m constraints=%u blockers=%u\n",
        state.forwardSpeed,state.pose.p.z,car->constraintCount(),scene->getDestructionScene()->getLastStatus().correctionBlockers);
    car->release();ground->release();material->release();scene->release();dispatcher->release();cuda->release();
    PxCloseExtensions();physics->release();foundation->release();
    return ok?0:8;
}
