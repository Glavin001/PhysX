// SPDX-License-Identifier: BSD-3-Clause
#include <PxPhysicsAPI.h>
#include <NvBlastExtStressPhysXResim.h>
#include <extensions/PxDefaultCpuDispatcher.h>

int main(int argc, char**) {
    physx::PxDefaultAllocator allocator;
    physx::PxDefaultErrorCallback errors;
    auto* foundation=PxCreateFoundation(PX_PHYSICS_VERSION,allocator,errors);
    if(!foundation)return 1;
    auto* physics=PxCreatePhysics(PX_PHYSICS_VERSION,*foundation,physx::PxTolerancesScale());
    if(!physics)return 2;
    physx::PxCudaContextManager* cuda=nullptr;
    if(argc>1) {
        physx::PxCudaContextManagerDesc cudaDesc;
        cuda=PxCreateCudaContextManager(*foundation,cudaDesc);
        if(!cuda || !cuda->contextIsValid())return 6;
    }
    auto* dispatcher=physx::PxDefaultCpuDispatcherCreate(1);
    physx::PxSceneDesc desc(physics->getTolerancesScale());
    desc.cpuDispatcher=dispatcher;
    desc.filterShader=physx::PxDefaultSimulationFilterShader;
    if(cuda) {
        desc.cudaContextManager=cuda;
        desc.flags|=physx::PxSceneFlag::eENABLE_GPU_DYNAMICS;
        desc.broadPhaseType=physx::PxBroadPhaseType::eGPU;
    }
    auto* scene=physics->createScene(desc);
    if(!scene)return 3;
    auto* stepper=Nv::Blast::ExtStressPhysXFrameStepper::create(*scene);
    if(!stepper)return 4;
    const bool ok=stepper->stepFrame(1.0f/60.0f,desc.gravity,nullptr,0,
        Nv::Blast::ExtStressPhysXResimOptions(),nullptr,nullptr);
    stepper->release();scene->release();dispatcher->release();physics->release();
    if(cuda)cuda->release();
    foundation->release();
    return ok?0:5;
}
