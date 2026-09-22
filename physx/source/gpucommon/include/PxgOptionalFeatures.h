// Optional GPU services must fail explicitly before allocating or launching.
#ifndef PXG_OPTIONAL_FEATURES_H
#define PXG_OPTIONAL_FEATURES_H
#include "foundation/PxFoundation.h"
namespace physx
{
PX_INLINE bool checkCuMetalGpuSdfBuilder()
{
#if defined(PX_CUMETAL_DISABLE_GPU_SDF_BUILDER)
    return PxGetFoundation().error(PxErrorCode::eINVALID_OPERATION, PX_FL,
        "GPU SDF construction is disabled in this CuMetal build (PX_CUMETAL_ENABLE_GPU_SDF_BUILDER=OFF). Existing SDF geometry is unaffected.");
#else
    return true;
#endif
}
}
#endif
