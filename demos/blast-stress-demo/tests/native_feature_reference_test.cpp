// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// The rigid-body features vibe-land's city relies on, on the GPU pipeline,
// qualified against the CPU one. Both run the PGS solver the game uses.
//
// heightfield: a sphere, a box, a capsule and a convex rock dropped into a
//   heightfield bowl. The GPU must not let any of them sink further into the
//   terrain than the CPU does, and each must come to rest on the surface.
// vehicle: the Vehicle SDK car the game drives (PxNativeVehicle), dropped from
//   height onto its suspension limit and parked on a gentle slope. Its custom
//   constraint rows -- suspension limit and sticky tyre -- are prepared on the
//   CPU and solved on the GPU; the GPU car must land and park as the CPU one
//   does. `--drop-constraints` runs the car without them, as a control.
#include "../physx_scene.h"
#include "PxNativeVehicle.h"

#include <PxPhysicsAPI.h>
#include <cooking/PxCooking.h>

#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <string>
#include <vector>

using namespace physx;

namespace
{
void require(bool value, const std::string& message)
{
    if (!value) throw std::runtime_error(message);
}

constexpr float kDt = 1.0f / 60.0f;
constexpr float kLift = 2.0f; // heightfield raised above the helper's y = 0 plane
constexpr float kSide = 32.0f;
constexpr PxU32 kSamples = 33;

float bowl(float x, float z) { return 0.02f * (x * x + z * z); }

// PX_FEATURE_CONTACTS=1 prints every contact the host receives, for tracing.
struct ContactPrinter final : PxSimulationEventCallback
{
    void onContact(const PxContactPairHeader&, const PxContactPair* pairs, PxU32 count) override
    {
        for (PxU32 i = 0; i < count; ++i)
        {
            PxContactPairPoint points[16];
            const PxU32 n = pairs[i].extractContacts(points, 16);
            std::printf("CONTACT_REPORT pair %u points %u", i, n);
            if (n) std::printf(" sep %.4f normal (%.3f %.3f %.3f) impulse %.4f", points[0].separation,
                               points[0].normal.x, points[0].normal.y, points[0].normal.z, points[0].impulse.magnitude());
            std::printf("\n");
        }
    }
    void onConstraintBreak(PxConstraintInfo*, PxU32) override {}
    void onWake(PxActor**, PxU32) override {}
    void onSleep(PxActor**, PxU32) override {}
    void onTrigger(PxTriggerPair*, PxU32) override {}
    void onAdvance(const PxRigidBody* const*, const PxTransform*, const PxU32) override {}
};
ContactPrinter gContactPrinter;

std::unique_ptr<blast_demo::PhysXScene> makeScene(blast_demo::PhysicsMode mode)
{
    blast_demo::SceneCapacity capacity;
    capacity.maxBodies = 64;
    capacity.maxShapes = 64;
    const bool gpu = mode == blast_demo::PhysicsMode::Gpu;
    const bool reports = std::getenv("PX_FEATURE_CONTACTS") != nullptr;
    auto context = std::make_unique<blast_demo::PhysXScene>(mode, gpu, capacity, reports ? &gContactPrinter : nullptr,
                                                            false, false, false, false, PxSolverType::ePGS, false, reports);
    require(!gpu || context->gpuActive(), "a GPU scene is required");
    return context;
}

void step(blast_demo::PhysXScene& context)
{
    PxScene& scene = context.scene();
    scene.simulate(kDt);
    PxU32 error = 0;
    require(scene.fetchResults(true, &error) && error == 0, "simulation step failed");
    require(context.healthy(), "the pipeline reported an error: " + context.errors().lastMessage());
}

// ---------------------------------------------------------------- heightfield

struct TerrainOutcome
{
    std::vector<std::string> names;
    std::vector<float> worstDepth, restGap, speed;
};

TerrainOutcome terrain(blast_demo::PhysicsMode mode)
{
    if (std::getenv("PX_FEATURE_CONTACTS"))
        std::printf("TERRAIN_RUN %s\n", mode == blast_demo::PhysicsMode::Gpu ? "gpu" : "cpu");
    auto context = makeScene(mode);
    PxPhysics& physics = context->physics();
    PxScene& scene = context->scene();

    std::vector<PxHeightFieldSample> samples(kSamples * kSamples);
    const float spacing = kSide / float(kSamples - 1), origin = -kSide * 0.5f, heightScale = 0.001f;
    for (PxU32 row = 0; row < kSamples; ++row)
    {
        for (PxU32 column = 0; column < kSamples; ++column)
        {
            PxHeightFieldSample& sample = samples[row * kSamples + column];
            sample.height = PxI16(std::lround(bowl(origin + float(row) * spacing, origin + float(column) * spacing) / heightScale));
            sample.materialIndex0 = sample.materialIndex1 = 0;
            sample.clearTessFlag();
        }
    }
    PxHeightFieldDesc desc;
    desc.nbRows = desc.nbColumns = kSamples;
    desc.samples.data = samples.data();
    desc.samples.stride = sizeof(PxHeightFieldSample);
    PxHeightField* field = PxCreateHeightField(desc, physics.getPhysicsInsertionCallback());
    require(field != nullptr, "heightfield creation failed");
    const PxHeightFieldGeometry fieldGeometry(field, PxMeshGeometryFlags(), heightScale, spacing, spacing);
    const PxTransform fieldPose(PxVec3(origin, kLift, origin));
    PxRigidStatic* ground = PxCreateStatic(physics, fieldPose, fieldGeometry, context->material());
    scene.addActor(*ground);

    std::vector<PxVec3> rock;
    for (int k = 0; k < 24; ++k)
    {
        const float a = float(k) * 0.7f, b = float(k) * 1.3f;
        rock.push_back({0.35f * std::cos(a) * std::sin(b), 0.3f * std::cos(b), 0.35f * std::sin(a) * std::sin(b)});
    }
    PxConvexMeshDesc convex;
    convex.points.count = PxU32(rock.size());
    convex.points.stride = sizeof(PxVec3);
    convex.points.data = rock.data();
    convex.flags = PxConvexFlag::eCOMPUTE_CONVEX;
    PxCookingParams params = context->cookingParams();
    params.buildGPUData = true;
    PxConvexMesh* hull = PxCreateConvexMesh(params, convex, physics.getPhysicsInsertionCallback());
    require(hull && hull->isGpuCompatible(), "rock hull is not GPU compatible");

    struct Body { PxRigidDynamic* actor; PxShape* shape; std::string name; };
    std::vector<Body> bodies;
    // PX_FEATURE_ONLY=<name> keeps one body, for tracing a single pair.
    const char* only = std::getenv("PX_FEATURE_ONLY");
    auto add = [&](const PxGeometry& geometry, float x, float z, const std::string& name) {
        if (only && name != only) return;
        const PxTransform pose(PxVec3(x, kLift + bowl(x, z) + 2.0f, z));
        PxRigidDynamic* actor = PxCreateDynamic(physics, pose, geometry, context->material(), 500);
        scene.addActor(*actor);
        PxShape* shape = nullptr;
        actor->getShapes(&shape, 1);
        bodies.push_back({actor, shape, name});
    };
    add(PxSphereGeometry(0.5f), 5, -2, "sphere");
    add(PxBoxGeometry(0.5f, 0.5f, 0.5f), -4, 3, "box");
    add(PxCapsuleGeometry(0.3f, 0.5f), 3, 5, "capsule");
    add(PxConvexMeshGeometry(hull), -6, -5, "rock");

    TerrainOutcome out;
    out.worstDepth.assign(bodies.size(), 0.0f);
    for (unsigned frame = 0; frame < 300; ++frame)
    {
        step(*context);
        for (std::size_t i = 0; i < bodies.size(); ++i)
        {
            PxVec3 direction;
            PxReal depth = 0;
            if (PxGeometryQuery::computePenetration(direction, depth, bodies[i].shape->getGeometry(),
                                                    bodies[i].actor->getGlobalPose(), fieldGeometry, fieldPose))
                out.worstDepth[i] = std::max(out.worstDepth[i], depth);
        }
    }
    for (const Body& b : bodies)
    {
        const PxTransform pose = b.actor->getGlobalPose();
        // Height of the body's lowest point above the terrain directly under it.
        PxBounds3 bounds;
        PxGeometryQuery::computeGeomBounds(bounds, b.shape->getGeometry(), pose);
        out.names.push_back(b.name);
        out.restGap.push_back(bounds.minimum.y - (kLift + bowl(pose.p.x, pose.p.z)));
        out.speed.push_back(b.actor->getLinearVelocity().magnitude());
    }
    for (const Body& b : bodies) b.actor->release();
    ground->release();
    hull->release();
    field->release();
    return out;
}

// -------------------------------------------------------------------- vehicle

// vibe-land's city car, mapped exactly as physx-bridge/src/physx_bridge.cc does.
native::NativeVehicleDesc cityCar(bool constraints)
{
    native::NativeVehicleDesc car;
    const float mass = 600.0f, comY = -0.2f, restLoad = 150.0f * 9.81f;
    const PxVec3 half(0.9f, 0.3f, 1.8f);
    car.mass = mass;
    car.moi = PxVec3(mass * (half.y * half.y + half.z * half.z) / 3.0f, mass * (half.x * half.x + half.z * half.z) / 3.0f,
                     mass * (half.x * half.x + half.y * half.y) / 3.0f);
    car.cMassLocalPose = PxTransform(PxVec3(0, comY, 0));
    car.chassisHalfExtents = half;
    car.chassisLocalPose = PxTransform(PxIdentity);
    car.chassisSimulationFilterData = PxFilterData(1u << 3, ~0u, 6, 0);
    car.chassisQueryFilterData = PxFilterData(1u << 3, 6, 0, 0);
    // The helper's ground and this test's slab carry no query filter data, so
    // the wheels query with none; the chassis stays out of queries instead of
    // being excluded by group as the game does.
    car.chassisSceneQueryShape = false;
    car.frontAxleZ = 1.1f;
    car.rearAxleZ = -1.1f;
    car.halfTrack = 0.9f;
    car.suspensionAttachmentY = -0.17f - comY;
    car.suspensionTravel = 0.2f;
    car.wheelRadius = 0.35f;
    car.wheelHalfWidth = 0.15f;
    car.wheelMass = 0.02f * mass;
    car.wheelMoi = 0.5f * car.wheelMass * 0.35f * 0.35f;
    car.frontSprungMass = car.rearSprungMass = 0.25f * mass;
    car.frontStiffness = car.rearStiffness = 22000.0f;
    car.frontDamping = car.rearDamping = 3600.0f;
    car.tyreFriction = 1.4f;
    car.frontLateralStiffness = 28.0f * restLoad;
    car.rearLateralStiffness = 32.0f * restLoad;
    car.longitudinalStiffness = 12.0f * restLoad;
    car.maxSteerRadians = 0.5f;
    car.maxDriveTorque = 450.0f;
    car.maxBrakeTorque = 900.0f;
    car.maxHandbrakeTorque = 1800.0f;
    car.driveTopSpeed = 30.0f;
    car.sweepRoadQueries = true;
    car.roadQueryFlags = PxQueryFlags(PxQueryFlag::eSTATIC | PxQueryFlag::eDYNAMIC);
    car.roadQueryFilterData = PxFilterData();
    car.keepConstraints = constraints;
    return car;
}

struct VehicleOutcome
{
    float lowest{1e9f}, landedJounce{0}, crept{0}, parkedSpeed{0};
    PxU32 constraints{0};
};

VehicleOutcome vehicle(blast_demo::PhysicsMode mode, bool constraints)
{
    VehicleOutcome out;
    {
        // Drop from 6 m onto the helper's y = 0 ground plane.
        auto context = makeScene(mode);
        native::NativeVehicle* car = native::NativeVehicle::create(context->physics(), context->scene(),
                                                                   context->cookingParams(), context->material(),
                                                                   cityCar(constraints), PxTransform(PxVec3(0, 6.7f, 0)));
        require(car != nullptr, "vehicle creation failed");
        out.constraints = car->constraintCount();
        for (unsigned frame = 0; frame < 240; ++frame)
        {
            car->setCommands(0, 0, 0, 0);
            car->step(kDt);
            step(*context);
            const native::NativeVehicleState state = car->state();
            out.lowest = std::min(out.lowest, state.pose.p.y);
            for (const auto& wheel : state.wheels) out.landedJounce = std::max(out.landedJounce, wheel.jounce);
        }
        car->release();
    }
    {
        // Parked on a 1 degree slope: a tilted slab above the helper's plane.
        auto context = makeScene(mode);
        const float angle = 1.0f * PxPi / 180.0f;
        const PxQuat tilt(angle, PxVec3(1, 0, 0));
        PxRigidStatic* slope = PxCreateStatic(context->physics(), PxTransform(PxVec3(0, 1, 0), tilt),
                                              PxBoxGeometry(100, 0.5f, 100), context->material());
        context->scene().addActor(*slope);
        native::NativeVehicle* car = native::NativeVehicle::create(
            context->physics(), context->scene(), context->cookingParams(), context->material(), cityCar(constraints),
            PxTransform(tilt.rotate(PxVec3(0, 0.5f + 0.75f, 0)) + PxVec3(0, 1, 0), tilt));
        require(car != nullptr, "vehicle creation failed");
        PxVec3 settled(0);
        for (unsigned frame = 0; frame < 360; ++frame)
        {
            car->setCommands(0, 0, 0, 0);
            car->step(kDt);
            step(*context);
            if (frame == 179) settled = car->state().pose.p;
        }
        const native::NativeVehicleState state = car->state();
        out.crept = PxVec3(state.pose.p.x - settled.x, 0, state.pose.p.z - settled.z).magnitude();
        out.parkedSpeed = state.linearVelocity.magnitude();
        car->release();
        slope->release();
    }
    return out;
}
} // namespace

int main(int argc, char** argv)
{
    try
    {
        const bool constraints = !(argc > 1 && std::strcmp(argv[1], "--drop-constraints") == 0);
        bool ok = true;

        const TerrainOutcome cpu = terrain(blast_demo::PhysicsMode::Cpu);
        const TerrainOutcome gpu = terrain(blast_demo::PhysicsMode::Gpu);
        for (std::size_t i = 0; i < std::min(cpu.names.size(), gpu.names.size()); ++i)
        {
            std::printf("heightfield %-8s worst depth cpu %.4f gpu %.4f m; rest gap cpu %.4f gpu %.4f m; speed cpu %.4f gpu %.4f\n",
                        cpu.names[i].c_str(), cpu.worstDepth[i], gpu.worstDepth[i], cpu.restGap[i], gpu.restGap[i],
                        cpu.speed[i], gpu.speed[i]);
            // A body resting on the terrain has its lowest point at the surface
            // under its centre, within its own curvature; the CPU sets the scale.
            const bool sank = gpu.worstDepth[i] > cpu.worstDepth[i] + 0.02f;
            const bool offSurface = std::fabs(gpu.restGap[i] - cpu.restGap[i]) > 0.1f;
            // Round bodies still roll in the bowl on the CPU too; compare to it.
            const bool restless = gpu.speed[i] > cpu.speed[i] + 0.1f;
            if (sank || offSurface || restless)
            {
                std::printf("  FAIL: %s %s on the GPU heightfield\n", gpu.names[i].c_str(),
                            sank ? "sank further than on the CPU" : offSurface ? "did not rest on the surface" : "did not come to rest");
                ok = false;
            }
        }

        const VehicleOutcome cpuCar = vehicle(blast_demo::PhysicsMode::Cpu, constraints);
        const VehicleOutcome gpuCar = vehicle(blast_demo::PhysicsMode::Gpu, constraints);
        std::printf("vehicle (%u constraints): lowest chassis cpu %.4f gpu %.4f m; max jounce cpu %.4f gpu %.4f m\n",
                    gpuCar.constraints, cpuCar.lowest, gpuCar.lowest, cpuCar.landedJounce, gpuCar.landedJounce);
        std::printf("vehicle parked on 1 degree: crept cpu %.4f gpu %.4f m in 3 s; speed cpu %.4f gpu %.4f m/s\n",
                    cpuCar.crept, gpuCar.crept, cpuCar.parkedSpeed, gpuCar.parkedSpeed);
        if (std::fabs(gpuCar.lowest - cpuCar.lowest) > 0.03f)
        {
            std::printf("  FAIL: the GPU car landed differently from the CPU car\n");
            ok = false;
        }
        if (gpuCar.crept > cpuCar.crept + 0.05f)
        {
            std::printf("  FAIL: the GPU car crept down the slope further than the CPU car\n");
            ok = false;
        }
        if (!ok) return 1;
        std::printf("PASS: heightfield contacts and vehicle constraints match the CPU pipeline\n");
        return 0;
    }
    catch (const std::exception& e)
    {
        std::fprintf(stderr, "FAIL: %s\n", e.what());
        return 1;
    }
}
