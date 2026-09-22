// Optional CuMetal feature boundaries apply in release builds too.
#ifndef NP_CUMETAL_FEATURES_H
#define NP_CUMETAL_FEATURES_H
#include "PxRigidActor.h"
#include "PxShape.h"
#include "foundation/PxFoundation.h"

namespace physx
{
PX_INLINE bool checkCuMetalGeometry(PxGeometryType::Enum type)
{
#if defined(PX_CUMETAL_DISABLE_CONVEX_CORE)
    if(type == PxGeometryType::eCONVEXCORE)
        return PxGetFoundation().error(PxErrorCode::eINVALID_OPERATION, PX_FL,
            "ConvexCore geometry is disabled in this CuMetal build (PX_CUMETAL_ENABLE_CONVEX_CORE=OFF).");
#else
    PX_UNUSED(type);
#endif
    return true;
}

// Also guard deserialized actors, whose shapes bypass factory creation.
PX_INLINE bool checkCuMetalActor(const PxRigidActor& actor)
{
#if defined(PX_CUMETAL_DISABLE_CONVEX_CORE)
    for(PxU32 i = 0; i < actor.getNbShapes(); ++i)
    {
        PxShape* shape = NULL;
        if(actor.getShapes(&shape, 1, i) != 1 || !shape || !checkCuMetalGeometry(shape->getGeometry().getType()))
            return false;
    }
#else
    PX_UNUSED(actor);
#endif
    return true;
}
}
#endif
