// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// Convex-hull contacts on the GPU pipeline, qualified against the CPU one.
//
// The same scene -- stacks, pyramids and piles of cooked convex hulls, mixed
// with boxes, resting on a ground plane -- runs on the CPU and then on the GPU.
// The GPU run must stay finite, must not interpenetrate (hull against ground,
// hull against hull), must come to rest, and its stable structures must end
// where the CPU's do. Tumbling bodies are chaotic, so for them only the rest
// height and the absence of penetration are compared.
#include "../physx_scene.h"

#include <PxPhysicsAPI.h>
#include <cooking/PxCooking.h>

#include <algorithm>
#include <cmath>
#include <cstdio>
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

enum class Role
{
    Stable,  // compared pose-for-pose with the CPU
    Tumbling // compared by rest height only
};

struct Body
{
    PxRigidDynamic* actor{nullptr};
    PxShape* shape{nullptr};
    Role role{Role::Stable};
    std::string name;
};

struct Outcome
{
    std::vector<PxTransform> poses, authored;
    std::vector<float> speeds;
    std::vector<std::string> names;
    std::vector<Role> roles;
    float groundPenetration{0};
    float pairPenetration{0};
    std::string deepestPair;
    std::string deepestGround;
    // Deepest ground penetration once everything has settled (last 60 frames).
    float restingGround{0};
};

std::vector<PxVec3> prismPoints(float radius, float height)
{
    std::vector<PxVec3> points;
    for (int k = 0; k < 6; ++k)
    {
        const float a = float(k) * PxPi / 3;
        points.push_back({radius * std::cos(a), -height * 0.5f, radius * std::sin(a)});
        points.push_back({radius * std::cos(a), height * 0.5f, radius * std::sin(a)});
    }
    return points;
}

// A deterministic irregular hull, like a Voronoi shard: points on an ellipsoid.
std::vector<PxVec3> rockPoints(unsigned seed, PxVec3 axes)
{
    std::vector<PxVec3> points;
    std::uint32_t state = seed * 2654435761u + 12345u;
    auto next = [&] {
        state = state * 1664525u + 1013904223u;
        return float(state >> 8) / float(1u << 24);
    };
    for (int k = 0; k < 24; ++k)
    {
        const float z = next() * 2 - 1, t = next() * 2 * PxPi, r = std::sqrt(std::max(0.0f, 1 - z * z));
        points.push_back({axes.x * r * std::cos(t), axes.y * z, axes.z * r * std::sin(t)});
    }
    return points;
}

std::vector<PxVec3> boxPoints(PxVec3 half)
{
    std::vector<PxVec3> points;
    for (int k = 0; k < 8; ++k)
    {
        points.push_back({(k & 1) ? half.x : -half.x, (k & 2) ? half.y : -half.y, (k & 4) ? half.z : -half.z});
    }
    return points;
}

PxConvexMesh* cook(blast_demo::PhysXScene& context, const std::vector<PxVec3>& points)
{
    PxConvexMeshDesc desc;
    desc.points.count = PxU32(points.size());
    desc.points.stride = sizeof(PxVec3);
    desc.points.data = points.data();
    desc.flags = PxConvexFlag::eCOMPUTE_CONVEX;
    PxCookingParams params = context.cookingParams();
    params.buildGPUData = true;
    PxConvexMesh* mesh = PxCreateConvexMesh(params, desc, context.physics().getPhysicsInsertionCallback());
    require(mesh != nullptr, "convex cooking failed");
    require(mesh->isGpuCompatible(), "cooked convex hull is not GPU compatible");
    return mesh;
}

Outcome run(blast_demo::PhysicsMode mode, unsigned frames)
{
    blast_demo::SceneCapacity capacity;
    capacity.maxBodies = 64;
    capacity.maxShapes = 64;
    const bool gpu = mode == blast_demo::PhysicsMode::Gpu;
    blast_demo::PhysXScene context(mode, gpu, capacity, nullptr, false, true, false, false, PxSolverType::eTGS,
                                   false, false);
    require(!gpu || context.gpuActive(), "a GPU scene is required");
    PxPhysics& physics = context.physics();
    PxScene& scene = context.scene();

    // PhysXScene provides the y = 0 ground plane.
    PxConvexMesh* prism = cook(context, prismPoints(0.4f, 0.3f));
    PxConvexMesh* brick = cook(context, boxPoints({0.45f, 0.2f, 0.25f}));
    std::vector<PxConvexMesh*> rocks;
    for (unsigned k = 0; k < 4; ++k) rocks.push_back(cook(context, rockPoints(k + 1, {0.35f, 0.25f, 0.3f})));

    std::vector<Body> bodies;
    std::vector<PxTransform> authoredPoses;
    auto add = [&](const PxGeometry& geometry, const PxTransform& pose, Role role, const std::string& name,
                   PxVec3 velocity = PxVec3(0), PxVec3 spin = PxVec3(0)) {
        PxRigidDynamic* actor = PxCreateDynamic(physics, pose, geometry, context.material(), 1000);
        require(actor != nullptr, "body creation failed: " + name);
        actor->setLinearVelocity(velocity);
        actor->setAngularVelocity(spin);
        scene.addActor(*actor);
        PxShape* shape = nullptr;
        actor->getShapes(&shape, 1);
        bodies.push_back({actor, shape, role, name});
        authoredPoses.push_back(pose);
    };

    // A. Stack of four hexagonal prisms, hull on hull, face down.
    for (int k = 0; k < 4; ++k)
    {
        add(PxConvexMeshGeometry(prism), PxTransform(PxVec3(0, 0.155f + 0.305f * float(k), 0)), Role::Stable,
            "prism stack " + std::to_string(k));
    }
    // B. Mixed pairs: box on hull, hull on box.
    add(PxConvexMeshGeometry(prism), PxTransform(PxVec3(3, 0.155f, 0)), Role::Stable, "prism under box");
    add(PxBoxGeometry(0.3f, 0.2f, 0.3f), PxTransform(PxVec3(3, 0.515f, 0)), Role::Stable, "box on prism");
    add(PxBoxGeometry(0.5f, 0.2f, 0.5f), PxTransform(PxVec3(6, 0.205f, 0)), Role::Stable, "box under prism");
    add(PxConvexMeshGeometry(prism), PxTransform(PxVec3(6, 0.565f, 0)), Role::Stable, "prism on box");
    // C. A 3-2-1 pyramid of convex bricks, running bond, hull on hull.
    for (int row = 0; row < 3; ++row)
    {
        for (int k = 0; k < 3 - row; ++k)
        {
            const float x = 9 + (float(k) - float(2 - row) * 0.5f) * 0.92f;
            add(PxConvexMeshGeometry(brick), PxTransform(PxVec3(x, 0.205f + 0.405f * float(row), 0)), Role::Stable,
                "pyramid " + std::to_string(row) + "." + std::to_string(k));
        }
    }
    // D. Irregular shards dropped with a spin onto the ground and each other.
    for (unsigned k = 0; k < 3; ++k)
    {
        add(PxConvexMeshGeometry(rocks[k]), PxTransform(PxVec3(12 + 0.2f * float(k), 0.6f + 0.8f * float(k), 0.1f * float(k)),
                                                       PxQuat(0.4f * float(k + 1), PxVec3(1, 0, 1).getNormalized())),
            Role::Tumbling, "shard " + std::to_string(k), PxVec3(0), PxVec3(1.5f, 0, -1));
    }
    // E. A shard sliding along the ground until friction stops it.
    add(PxConvexMeshGeometry(rocks[3]), PxTransform(PxVec3(15, 0.3f, 0)), Role::Tumbling, "sliding shard",
        PxVec3(3, 0, 0));

    const PxTransform groundPose = PxTransformFromPlaneEquation(PxPlane(0, 1, 0, 0));
    Outcome outcome;
    for (unsigned frame = 0; frame < frames; ++frame)
    {
        scene.simulate(1.0f / 60.0f);
        PxU32 error = 0;
        require(scene.fetchResults(true, &error) && error == 0, "simulation step failed");
        require(context.healthy(), "GPU pipeline reported an error: " + context.errors().lastMessage());
        // Penetration is checked every frame, not only at rest: a missing
        // contact shows up as a body sinking through something mid-run.
        for (const Body& a : bodies)
        {
            const PxTransform pose = a.actor->getGlobalPose();
            require(pose.isValid(), a.name + " has a non-finite pose");
            PxVec3 direction;
            PxReal depth = 0;
            if (PxGeometryQuery::computePenetration(direction, depth, a.shape->getGeometry(), pose, PxPlaneGeometry(),
                                                    groundPose))
            {
                if (depth > outcome.groundPenetration)
                {
                    outcome.groundPenetration = depth;
                    outcome.deepestGround = a.name + " at frame " + std::to_string(frame);
                }
                if (frame + 60 >= frames) outcome.restingGround = std::max(outcome.restingGround, depth);
            }
        }
        for (std::size_t i = 0; i < bodies.size(); ++i)
        {
            for (std::size_t j = i + 1; j < bodies.size(); ++j)
            {
                const PxTransform pi = bodies[i].actor->getGlobalPose(), pj = bodies[j].actor->getGlobalPose();
                if ((pi.p - pj.p).magnitude() > 1.5f) continue;
                PxVec3 direction;
                PxReal depth = 0;
                if (PxGeometryQuery::computePenetration(direction, depth, bodies[i].shape->getGeometry(), pi,
                                                        bodies[j].shape->getGeometry(), pj)
                    && depth > outcome.pairPenetration)
                {
                    outcome.pairPenetration = depth;
                    outcome.deepestPair = bodies[i].name + " / " + bodies[j].name + " at frame "
                                          + std::to_string(frame);
                }
            }
        }
    }
    outcome.authored = authoredPoses;
    for (const Body& b : bodies)
    {
        outcome.poses.push_back(b.actor->getGlobalPose());
        outcome.speeds.push_back(b.actor->getLinearVelocity().magnitude());
        outcome.names.push_back(b.name);
        outcome.roles.push_back(b.role);
    }
    for (const Body& b : bodies)
    {
        scene.removeActor(*b.actor);
        b.actor->release();
    }
    prism->release();
    brick->release();
    for (PxConvexMesh* rock : rocks) rock->release();
    return outcome;
}
} // namespace

int main(int argc, char** argv)
{
    try
    {
        const unsigned frames = argc > 1 ? unsigned(std::stoul(argv[1])) : 300u;
        const Outcome cpu = run(blast_demo::PhysicsMode::Cpu, frames);
        const Outcome gpu = run(blast_demo::PhysicsMode::Gpu, frames);
        // Contact offsets and TGS position iterations let resting bodies sit a
        // few millimetres into each other on either pipeline; the CPU run sets
        // the scale and the GPU may not exceed it by more than a centimetre.
        const float slack = 0.01f;
        std::printf("ground penetration: cpu %.4f (%s) gpu %.4f (%s) m; resting cpu %.4f gpu %.4f m\n",
                    cpu.groundPenetration, cpu.deepestGround.c_str(), gpu.groundPenetration,
                    gpu.deepestGround.c_str(), cpu.restingGround, gpu.restingGround);
        std::printf("pair penetration: cpu %.4f (%s) gpu %.4f (%s) m\n", cpu.pairPenetration,
                    cpu.deepestPair.c_str(), gpu.pairPenetration, gpu.deepestPair.c_str());
        float worstStable = 0, worstHeight = 0;
        for (std::size_t i = 0; i < gpu.poses.size(); ++i)
        {
            // A stable structure should stay where it was authored, give or take
            // settling into contact; the CPU's own drift sets the allowance.
            const PxVec3 d = gpu.poses[i].p - cpu.poses[i].p;
            const float gpuDrift = (gpu.poses[i].p - gpu.authored[i].p).magnitude();
            const float cpuDrift = (cpu.poses[i].p - cpu.authored[i].p).magnitude();
            const float error = gpu.roles[i] == Role::Stable ? gpuDrift : std::fabs(d.y);
            std::printf("  %-18s cpu (%6.3f %6.3f %6.3f) gpu (%6.3f %6.3f %6.3f) drift cpu %.4f gpu %.4f speed %.4f\n",
                        gpu.names[i].c_str(), cpu.poses[i].p.x, cpu.poses[i].p.y, cpu.poses[i].p.z, gpu.poses[i].p.x,
                        gpu.poses[i].p.y, gpu.poses[i].p.z, cpuDrift, gpuDrift, gpu.speeds[i]);
            require(gpu.speeds[i] < 0.05f, gpu.names[i] + " did not come to rest on the GPU");
            if (gpu.roles[i] == Role::Stable)
            {
                worstStable = std::max(worstStable, error);
                require(gpuDrift <= std::max(0.02f, cpuDrift + slack), gpu.names[i] + " did not stay where it was built");
            }
            else
            {
                worstHeight = std::max(worstHeight, error);
                // A shard may land on a different face; its height stays within
                // the spread of its own extents.
                require(error < 0.2f, gpu.names[i] + " came to rest at a different height than on the CPU");
            }
        }
        require(gpu.restingGround <= cpu.restingGround + slack, "GPU hull rests sunk into the ground");
        require(gpu.groundPenetration <= cpu.groundPenetration + 2 * slack, "GPU hull fell through the ground");
        require(gpu.pairPenetration <= cpu.pairPenetration + slack, "GPU hulls interpenetrated: " + gpu.deepestPair);
        std::printf("PASS: %zu bodies, %u frames; stable structures within %.4f m of where they were built, shard rest heights "
                    "within %.4f m, no interpenetration beyond the CPU's own\n",
                    gpu.poses.size(), frames, worstStable, worstHeight);
        return 0;
    }
    catch (const std::exception& e)
    {
        std::fprintf(stderr, "FAIL: %s\n", e.what());
        return 1;
    }
}
