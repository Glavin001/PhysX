#pragma once
// Optional read-only collision-state audit for native_wall_capture.
// Include outside any namespace. Invoke only after fetchResults succeeded and
// the existing destruction device-view readyEvent was waited, before simulate.
#include "PxPhysicsAPI.h"
#include "NpScene.h"
#include "PxgContext.h"
#include "PxgCudaBroadPhaseSap.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "PxgShapeSim.h"
#include "PxgBodySim.h"
#include "PxgNarrowphaseCore.h"
#include "PxgShapeManager.h"
#include "PxsCachedTransform.h"
#include "PxDestructionScene.h"
#include <cuda.h>
#include <stdexcept>

namespace wall_shape_audit {
using namespace physx;
struct Record {
    PxU32 shapeId, cpuBodyIndex;
    PxgShapeSim shapeSim;
    PxNodeIndex npOwner;
    PxsCachedTransform cached;
    PxBounds3 bounds;
    PxgBodySim body;
    PxTransform gpuShapePose, cpuShapePose;
};
inline void require(bool value,const char* message) {
    if(!value)throw std::runtime_error(message);
}
template<class T> inline void copy(T& dst,CUdeviceptr base,PxU32 index) {
    require(base!=0,"shape audit missing device storage");
    require(cuMemcpyDtoH(&dst,base+PxU64(index)*sizeof(T),sizeof(T))==CUDA_SUCCESS,
        "shape audit device read failed");
}
inline Record read(PxScene& scene,PxCudaContextManager& cuda,
                   PxDestructionScene& destruction,PxShape& shape) {
    auto& sc=static_cast<NpScene&>(scene).getScScene();
    auto* controller=static_cast<PxgSimulationController*>(sc.getSimulationController());
    auto* core=controller->getSimulationCore();
    auto* gpu=static_cast<PxgGpuContext*>(sc.getDynamicsContext());
    auto* np=gpu->getNarrowphaseCore();
    Record r; // Each field is assigned below before it is observed.
    // This API returns the persistent shape/transform-cache element identity,
    // not PxShape::getGPUIndex() and not an accepted-topology cluster label.
    r.shapeId=destruction.getShapeContactIndex(shape);
    auto* actor=shape.getActor();
    require(actor && actor->getConcreteType()==PxConcreteType::eRIGID_DYNAMIC,
        "shape audit expects a native wall rigid dynamic actor");
    r.cpuBodyIndex=static_cast<PxRigidDynamic*>(actor)->getGPUIndex();
    r.cpuShapePose=actor->getGlobalPose()*shape.getLocalPose();
    const auto& shapeStorage=core->mPxgShapeSimManager;
    const auto& remap=np->mGpuShapesManager.mGpuShapesRemapTableBuffer;
    const auto& transforms=np->getTransformCache();
    require(gpu->getGpuBroadPhase()!=nullptr,"shape audit requires GPU broadphase");
    const auto* bounds=&gpu->getGpuBroadPhase()->getBoundsBuffer();
    require(r.shapeId!=PX_INVALID_U32 && r.shapeId<shapeStorage.getNbTotalShapeSims()
        && PxU64(r.shapeId)<remap.getSize()/sizeof(PxNodeIndex)
        && PxU64(r.shapeId)<transforms.getSize()/sizeof(PxsCachedTransform)
        && bounds && PxU64(r.shapeId)<bounds->getSize()/sizeof(PxBounds3),
        "shape audit persistent ID out of range");
    PxScopedCudaLock lock(cuda);
    copy(r.shapeSim,reinterpret_cast<CUdeviceptr>(shapeStorage.getShapeSimsDeviceTypedPtr()),r.shapeId);
    copy(r.npOwner,remap.getDevicePtr(),r.shapeId);
    copy(r.cached,transforms.getDevicePtr(),r.shapeId);
    copy(r.bounds,bounds->getDevicePtr(),r.shapeId);
    require(!r.shapeSim.mBodySimIndex.isStaticBody() && !r.shapeSim.mBodySimIndex.isArticulation()
        && r.shapeSim.mBodySimIndex.index()<core->getBodySimStorageCapacity(),
        "shape audit unsupported or invalid GPU owner");
    // Deliberately follow ShapeSim's actual GPU owner rather than the CPU
    // actor index, so a disagreement is observable rather than normalized away.
    copy(r.body,reinterpret_cast<CUdeviceptr>(core->getBodySimBufferDevicePtr().getPointer()),
        r.shapeSim.mBodySimIndex.index());
    // Same composition/order as gpucommon/src/CUDA/updateCacheAndBound.cuh.
    r.gpuShapePose=r.body.body2World.getTransform().transform(
        r.body.body2Actor_maxImpulseW.getTransform().transformInv(r.shapeSim.mTransform));
    return r;
}
} // namespace wall_shape_audit
