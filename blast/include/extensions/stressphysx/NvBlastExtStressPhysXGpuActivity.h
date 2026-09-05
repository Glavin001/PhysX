#ifndef NVBLASTEXTSTRESSPHYSXGPUACTIVITY_H
#define NVBLASTEXTSTRESSPHYSXGPUACTIVITY_H

#include "NvBlastExtStressPhysX.h"
#include <PxDirectGPUAPI.h>

namespace Nv { namespace Blast {

/** Native rigid-body sleeping with GPU-owned motion (patched PhysX 5.10).
 * Ordinary and stock Direct GPU scenes are not changed by this interface.
 * All calls run outside simulate/fetchResults, on the scene-owning thread.
 */
class NV_DLL_EXPORT ExtStressPhysXGpuActivity
{
public:
    /// Opt in after configuring GPU dynamics/broadphase. Fails without changing
    /// the descriptor if the SDK lacks the extension or flags are incompatible.
    static bool configureScene(physx::PxSceneDesc& desc);
    static ExtStressPhysXGpuActivity* create(physx::PxScene& scene);
    virtual bool available() const = 0;
    virtual void release() = 0;

    /** Wake the named dynamics and write device-owned command values.
     * Validates the complete batch before waking any actor. Actors are borrowed
     * and must remain alive throughout the call; removed actors, kinematics and
     * duplicate actors are rejected. Requires initialized Direct GPU indices.
     * Only indices cross H2D; values remain on device. producerReady is an
     * optional same-context CUevent. This method completes synchronously, so
     * the device values/event may be reused after return. Use this method for
     * commands to sleeping bodies; raw Direct GPU writes do not wake CPU islands.
     */
    virtual bool write(physx::PxRigidDynamic* const* bodies, uint32_t count,
        const void* deviceValues, physx::PxRigidDynamicGPUAPIWriteType::Enum type,
        void* producerReady = nullptr) = 0;
protected:
    virtual ~ExtStressPhysXGpuActivity() {}
};

}} // namespace Nv::Blast
#endif
