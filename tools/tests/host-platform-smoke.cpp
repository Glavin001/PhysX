// Host platform checks only; this is not GPU destruction qualification.
#include "PxPhysicsAPI.h"
#include "foundation/PxSIMDHelpers.h"
#include "foundation/PxFPU.h"
#include "SnSerialUtils.h"
#include "NpShape.h"
#include "PxgOptionalFeatures.h"
#include <cfenv>
#include <cmath>
#include <cstdio>
#include <cstring>

using namespace physx;
static bool require(bool condition, const char* reason)
{
    if (!condition) std::fprintf(stderr, "FAIL: %s\n", reason);
    return condition;
}

class FeatureErrors : public PxErrorCallback
{
public:
    PxDefaultErrorCallback fallback;
    unsigned rejected = 0;
    unsigned sdfRejected = 0;
    void reportError(PxErrorCode::Enum code, const char* message, const char* file, int line) override
    {
        if(code == PxErrorCode::eINVALID_OPERATION && std::strstr(message, "ConvexCore geometry is disabled"))
            ++rejected;
        else if(code == PxErrorCode::eINVALID_OPERATION && std::strstr(message, "GPU SDF construction is disabled"))
            ++sdfRejected;
        else
            fallback.reportError(code, message, file, line);
    }
};

static bool checkKernelScope()
{
    static const char* names[] = {
#define KERNEL_DEF(id, name) name,
#include "PxgKernelNames.h"
#undef KERNEL_DEF
    };
    unsigned optional = 0, sdfBuilder = 0;
    bool sdfCollision = false;
    bool sphere = false, box = false, convex = false;
    for(const char* name : names)
    {
        optional += std::strstr(name, "convexCore") != nullptr;
        sdfBuilder += std::strncmp(name, "sdf", 3) == 0 || std::strncmp(name, "bvh", 3) == 0;
        sdfCollision |= std::strcmp(name, "evaluatePointDistancesSDFBatch") == 0;
        sphere |= std::strcmp(name, "sphereNphase_Kernel") == 0;
        box |= std::strcmp(name, "boxBoxNphase_Kernel") == 0;
        convex |= std::strcmp(name, "convexConvexNphase_stage2Kernel") == 0;
    }
#if defined(PX_CUMETAL_DISABLE_GPU_SDF_BUILDER)
    if(!require(sdfBuilder == 0 && sdfCollision, "only SDF construction kernels excluded; collision retained")) return false;
#else
    if(!require(sdfBuilder == 18 && sdfCollision, "all SDF construction and collision kernels retained")) return false;
#endif
#if defined(PX_CUMETAL_DISABLE_CONVEX_CORE)
    return require(optional == 0 && sphere && box && convex, "only optional ConvexCore kernels excluded");
#else
    return require(optional == 5 && sphere && box && convex, "complete kernel registry retained");
#endif
}

int main()
{
    const PxQuat rotation(0.63f, PxVec3(0, 1, 0));
    const PxMat33 expected(rotation);
    const PxMat33Padded actual(rotation);
    if (!require((actual.column0 - expected.column0).magnitude() < 1e-6f &&
                 (actual.column1 - expected.column1).magnitude() < 1e-6f &&
                 (actual.column2 - expected.column2).magnitude() < 1e-6f,
                 "ARM SIMD matrix stores")) return 1;
    const int original = std::fegetround();
    std::fesetround(FE_DOWNWARD);
    { PxFPUGuard guard; if (!require(std::fegetround() == FE_TONEAREST, "FPU default environment")) return 2; }
    const bool restored = std::fegetround() == FE_DOWNWARD;
    std::fesetround(original);
    if (!require(restored, "FPU environment restoration")) return 3;
    const PxU32 tag = Sn::getBinaryPlatformTag();
    if (!require(Sn::isBinaryPlatformTagValid(tag) &&
                 std::strcmp(Sn::getBinaryPlatformName(tag), "macaarch64") == 0,
                 "Apple Silicon serialization platform tag")) return 4;

    PxDefaultAllocator allocator;
    FeatureErrors errors;
    if(!checkKernelScope()) return 10;
    PxFoundation* foundation = PxCreateFoundation(PX_PHYSICS_VERSION, allocator, errors);
    if (!require(foundation != nullptr, "foundation creation")) return 5;
#if defined(PX_CUMETAL_DISABLE_GPU_SDF_BUILDER)
    if(!require(!checkCuMetalGpuSdfBuilder() && errors.sdfRejected == 1, "disabled service rejects before creation")) return 22;
#else
    if(!require(checkCuMetalGpuSdfBuilder() && errors.sdfRejected == 0, "enabled service passes feature preflight")) return 22;
#endif
    PxPhysics* physics = PxCreatePhysics(PX_PHYSICS_VERSION, *foundation, PxTolerancesScale());
    if (!require(physics != nullptr, "physics creation")) return 6;
    PxDefaultCpuDispatcher* dispatcher = PxDefaultCpuDispatcherCreate(1);
    PxSceneDesc description(physics->getTolerancesScale());
    description.gravity = PxVec3(0, -9.81f, 0);
    description.cpuDispatcher = dispatcher;
    description.filterShader = PxDefaultSimulationFilterShader;
    PxScene* scene = physics->createScene(description);
    PxMaterial* material = physics->createMaterial(0.5f, 0.5f, 0.1f);
    if (!require(scene && material, "scene and material creation")) return 7;
    const PxConvexCoreGeometry core(PxConvexCore::Point(), 0.5f);
    if(!require(PxGeometryQuery::isValid(core), "valid optional geometry fixture")) return 11;
    PxShape* optional = physics->createShape(core, *material, true);
#if defined(PX_CUMETAL_DISABLE_CONVEX_CORE)
    if(!require(!optional && errors.rejected == 1, "release factory rejects disabled geometry")) return 12;
    PxShape* sphere = physics->createShape(PxSphereGeometry(0.5f), *material, true);
    if(!require(sphere != nullptr, "ordinary sphere remains available")) return 13;
    sphere->setGeometry(core);
    if(!require(errors.rejected == 2 && sphere->getGeometry().getType() == PxGeometryType::eSPHERE,
                "geometry mutation rejected before changes")) return 14;
    // Emulate a shape restored from a binary produced by an enabled build.
    // This internal test seam deliberately bypasses the guarded public factory.
    PxRigidDynamic* restoredActor = physics->createRigidDynamic(PxTransform(PxIdentity));
    if(!require(restoredActor && restoredActor->attachShape(*sphere), "restore fixture setup")) return 15;
    static_cast<NpShape*>(sphere)->getCore().setGeometry(core);
    PxRigidDynamic* empty = physics->createRigidDynamic(PxTransform(PxIdentity));
    if(!require(empty && !empty->attachShape(*sphere) && empty->getNbShapes() == 0,
                "restoredActor shape attachment rejected")) return 16;
    if(!require(!scene->addActor(*restoredActor) && !restoredActor->getScene(), "restoredActor actor insertion rejected")) return 17;
    PxActor* batch[] = {restoredActor};
    if(!require(!scene->addActors(batch, 1) && !restoredActor->getScene(), "restoredActor batch insertion rejected")) return 18;
    PxCollection* collection = PxCreateCollection();
    collection->add(*restoredActor);
    if(!require(!scene->addCollection(*collection) && !restoredActor->getScene(), "restoredActor collection rejected")) return 19;
    collection->release();
    PxAggregate* aggregate = physics->createAggregate(1, 1, PxGetAggregateFilterHint(PxAggregateType::eGENERIC, false));
    if(!require(aggregate && aggregate->addActor(*restoredActor), "aggregate restore fixture setup")) return 20;
    if(!require(!scene->addAggregate(*aggregate) && !aggregate->getScene() && !restoredActor->getScene(),
                "restoredActor aggregate rejected before insertion")) return 21;
    aggregate->release();
    restoredActor->release();
    empty->release();
    sphere->release();
#else
    if(!require(optional != nullptr && errors.rejected == 0, "opt-in geometry remains available")) return 12;
    optional->release();
#endif
    PxRigidDynamic* box = PxCreateDynamic(*physics, PxTransform(PxVec3(0, 10, 0)), PxBoxGeometry(0.5f, 0.5f, 0.5f), *material, 1.0f);
    if (!require(box != nullptr, "box creation")) return 8;
    scene->addActor(*box);
    for (int i = 0; i < 10; ++i) { scene->simulate(1.0f / 60.0f); scene->fetchResults(true); }
    const float height = box->getGlobalPose().p.y;
    const bool advanced = height < 10.0f && height > 9.0f;
    box->release(); material->release(); scene->release(); dispatcher->release();
    physics->release(); foundation->release();
    if (!require(advanced, "CPU scene advanced under gravity")) return 9;
    std::puts("PASS: macOS host SIMD, FPU, serialization, and CPU scene smoke");
    return 0;
}
