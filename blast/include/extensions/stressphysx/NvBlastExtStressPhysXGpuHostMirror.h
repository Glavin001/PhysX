#ifndef NVBLASTEXTSTRESSPHYSXGPUHOSTMIRROR_H
#define NVBLASTEXTSTRESSPHYSXGPUHOSTMIRROR_H

#include "NvBlastExtStressPhysX.h"

namespace Nv { namespace Blast {

/** Explicit observation boundary for GPU-owned rigid motion.
 * Uses persistent device/pinned buffers and one host wait for a whole batch.
 * Publishes poses/velocities to native CPU getters and scene queries without
 * queuing device writes, waking bodies, or changing force accumulators.
 * Call after fetchResults, on the scene owner thread, with live, uploaded
 * actors. No actor may be removed/reinserted while this call is in progress.
 * Include newly sleeping actors: their final pose can differ from the last
 * awake observation. Call before pose-dependent metadata edits/CPU queries.
 * This is an observer, not a rollback checkpoint or a network commit decision.
 */
class NV_DLL_EXPORT ExtStressPhysXGpuHostMirror
{
public:
    static ExtStressPhysXGpuHostMirror* create(physx::PxScene& scene);
    virtual bool available() const = 0;
    virtual bool synchronize(physx::PxRigidDynamic* const* bodies, uint32_t count) = 0;
    virtual void release() = 0;
protected:
    virtual ~ExtStressPhysXGpuHostMirror() {}
};

} }
#endif
