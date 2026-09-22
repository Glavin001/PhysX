// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// The authored bonded wall, driven live instead of captured to a file.
//
// This mirrors the asset native_wall_capture.cpp authors: a kinematic wall of
// bonded cubes whose bottom course is the support, a separate stronger mortar
// on the row-0/1 ties, and one PhysX destruction stress cluster over all of it.
// Fracture, correction and motion are PhysX's; nothing here scripts damage.
//
// Header-only so an interactive front end can own a scene without the capture
// CLI's file plumbing. The capture CLI should eventually be migrated onto this
// rather than keeping two copies of the authoring.
#pragma once

#include "physx_scene.h"

#include <PxDestructionScene.h>
#include <PxPhysicsAPI.h>

#include <cmath>
#include <cstdint>
#include <string>
#include <vector>

namespace wall_live
{

struct WallOptions
{
    unsigned width{21};
    unsigned height{5};
    float materialStrength{1.5f};
    float foundationStrength{8.0f};
    unsigned stressIterations{8192};
    // Blast's CPU stress solver converges to 1e-3; the GPU solve asks the same.
    float stressTolerance{1e-3f};
    // Projectile defaults; a click can override the aim but not the physics.
    float projectileMass{600.0f};
    float projectileSpeed{30.0f};
    float projectileRadius{0.6f};
    // Fired projectiles are recycled, so the render roster stays a fixed size.
    unsigned maxProjectiles{24};
};

// One drawable body: either a wall chunk or a projectile.
struct BodyView
{
    float position[3]{0, 0, 0};
    float rotation[4]{0, 0, 0, 1};
    float half[3]{0.48f, 0.48f, 0.48f};
    bool sphere{false};
    bool live{false};
    // Stable per-owner id so chunks of one fragment share a colour and keep it
    // as the fragment moves. Derived from the owning actor, which is exactly
    // what fracture changes.
    std::uint32_t group{0};
};

class WallScene
{
public:
    explicit WallScene(const WallOptions& options) : m_options(options) {}

    ~WallScene() { teardown(); }

    WallScene(const WallScene&) = delete;
    WallScene& operator=(const WallScene&) = delete;

    const WallOptions& options() const { return m_options; }
    const std::vector<BodyView>& bodies() const { return m_bodies; }
    unsigned chunkCount() const { return m_options.width * m_options.height; }
    unsigned brokenBonds() const { return m_brokenBonds; }
    unsigned firedProjectiles() const { return m_fired; }
    double lastStepMilliseconds() const { return m_lastStepMs; }
    const std::string& error() const { return m_error; }

    float wallSpan() const { return float(m_options.width); }
    float wallHeight() const { return float(m_options.height); }

    bool build(blast_demo::PhysXScene& context)
    {
        using namespace physx;
        teardown();
        // A fresh asset starts from a clean slate; a previous failure must not
        // make this scene unteardownable.
        m_failed = false;
        m_error.clear();
        m_context = &context;
        PxPhysics& physics = context.physics();
        PxScene& scene = context.scene();

        const unsigned count = chunkCount();
        const PxVec3 half(0.48f);
        const float volume = 8 * half.x * half.y * half.z;
        const float blockMass = 1000 * volume;
        const float inertia = blockMass * (half.x * half.x + half.y * half.y) / 3;

        m_wall = physics.createRigidDynamic(PxTransform(PxIdentity));
        if (m_wall == nullptr)
        {
            return fail("wall allocation failed");
        }
        m_wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC, true);
        m_wall->setLinearDamping(0);
        m_wall->setAngularDamping(0);

        std::vector<PxDestructionStressChunk> chunks;
        std::vector<PxDestructionChunkMassProperties> properties;
        std::vector<PxDestructionStressBond> bonds;
        const PxVec3 centre(0, float(m_options.height) * 0.5f, 0);
        PxVec3 totalInertia(0);

        for (unsigned y = 0; y < m_options.height; ++y)
        {
            for (unsigned x = 0; x < m_options.width; ++x)
            {
                const unsigned id = y * m_options.width + x;
                const PxVec3 p(float(x) - float(m_options.width - 1) * 0.5f, float(y) + 0.5f, 0);
                PxShape* shape = physics.createShape(PxBoxGeometry(half), context.material(), true);
                if (shape == nullptr)
                {
                    return fail("wall shape allocation failed");
                }
                shape->setLocalPose(PxTransform(p));
                if (!m_wall->attachShape(*shape))
                {
                    return fail("wall shape attachment failed");
                }
                m_shapes.push_back(shape);
                chunks.push_back({p, y ? blockMass : 0.0f, y ? inertia : 0.0f, 0, PX_INVALID_U32, volume, 0});
                PxDestructionChunkMassProperties prop{};
                prop.mass = blockMass;
                prop.supported = y == 0;
                for (unsigned k = 0; k < 3; ++k)
                {
                    prop.center[k] = p[k];
                    prop.inertia[k] = inertia;
                }
                properties.push_back(prop);
                const PxVec3 delta = p - centre;
                totalInertia += PxVec3(inertia + blockMass * (delta.y * delta.y + delta.z * delta.z),
                                       inertia + blockMass * (delta.x * delta.x + delta.z * delta.z),
                                       inertia + blockMass * (delta.x * delta.x + delta.y * delta.y));
                auto bond = [&](unsigned other) {
                    const PxVec3 d = p - chunks[other].position;
                    // A separate stronger mortar, only on the vertical row-0/1 ties.
                    const bool foundation = y == 1 && other == id - m_options.width;
                    bonds.push_back({other, id, (p + chunks[other].position) * 0.5f, d.getNormalized(),
                                     4 * half.x * half.y, 1, 1, foundation ? 1u : 0u});
                };
                if (x) bond(id - 1);
                if (y) bond(id - m_options.width);
            }
        }
        m_wall->setMass(blockMass * float(count));
        m_wall->setCMassLocalPose(PxTransform(centre));
        m_wall->setMassSpaceInertiaTensor(totalInertia);
        scene.addActor(*m_wall);

        // The asset must be configured against a stepped scene before it can be
        // hit, exactly as the capture CLI does.
        scene.simulate(1.0f / 60.0f);
        PxU32 setupError = 0;
        if (!scene.fetchResults(true, &setupError) || setupError != 0 || !context.healthy())
        {
            return fail("wall setup step failed");
        }

        m_destruction = scene.getDestructionScene();
        if (m_destruction == nullptr)
        {
            return fail("integrated destruction is unavailable");
        }
        for (unsigned i = 0; i < count; ++i)
        {
            chunks[i].contactIndex = m_destruction->getShapeContactIndex(*m_shapes[i]);
            if (chunks[i].contactIndex == PX_INVALID_U32)
            {
                return fail("wall collision identity missing");
            }
        }

        PxDestructionStressCluster cluster{m_wall->getGPUIndex(), centre};
        PxDestructionMaterial materials[2];
        PxDestructionMaterial& material = materials[0];
        material.compressionElasticLimit = 250000 * m_options.materialStrength;
        material.compressionFatalLimit = 500000 * m_options.materialStrength;
        material.tensionElasticLimit = 30000 * m_options.materialStrength;
        material.tensionFatalLimit = 60000 * m_options.materialStrength;
        material.shearElasticLimit = 80000 * m_options.materialStrength;
        material.shearFatalLimit = 160000 * m_options.materialStrength;
        PxDestructionMaterial& foundation = materials[1];
        foundation = material;
        foundation.compressionElasticLimit *= m_options.foundationStrength;
        foundation.compressionFatalLimit *= m_options.foundationStrength;
        foundation.tensionElasticLimit *= m_options.foundationStrength;
        foundation.tensionFatalLimit *= m_options.foundationStrength;
        foundation.shearElasticLimit *= m_options.foundationStrength;
        foundation.shearFatalLimit *= m_options.foundationStrength;

        PxDestructionStressDesc desc;
        desc.chunks = chunks.data();
        desc.chunkCount = count;
        desc.chunkMassProperties = properties.data();
        desc.clusters = &cluster;
        desc.clusterCount = 1;
        desc.bonds = bonds.data();
        desc.bondCount = PxU32(bonds.size());
        desc.materials = materials;
        desc.materialCount = 2;
        desc.maxIterations = m_options.stressIterations;
        desc.tolerance = m_options.stressTolerance;
        desc.internalCorrectionLimit = 1;
        desc.gpuIslandRepair = false;
        desc.preserveUnchangedContactPairs = false;
        if (!m_destruction->configureStress(desc))
        {
            return fail("wall stress configuration failed");
        }
        m_bondCount = unsigned(bonds.size());
        m_brokenBonds = 0;
        m_fired = 0;
        m_projectiles.assign(m_options.maxProjectiles, nullptr);
        refreshBodies();
        return true;
    }

    // Advances one tick and refreshes the drawable state. A failed step is
    // reported rather than hidden: a stalled scene must not look like a slow one.
    bool step(float dt)
    {
        using namespace physx;
        if (m_context == nullptr || m_wall == nullptr)
        {
            return fail("scene is not built");
        }
        PxScene& scene = m_context->scene();
        const auto started = std::chrono::steady_clock::now();
        scene.simulate(dt);
        PxU32 error = 0;
        const bool accepted = scene.fetchResults(true, &error);
        m_lastStepMs = std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - started).count();
        if (!accepted || error != 0)
        {
            return fail("simulation step failed");
        }
        if (m_destruction != nullptr)
        {
            m_brokenBonds += m_destruction->getLastStatus().brokenBonds;
        }
        refreshBodies();
        return true;
    }

    // Fires a projectile along a ray. Recycles the oldest slot once the roster
    // is full so the render instance count never changes.
    bool shoot(const float origin[3], const float direction[3])
    {
        using namespace physx;
        if (m_context == nullptr)
        {
            return fail("scene is not built");
        }
        PxPhysics& physics = m_context->physics();
        PxScene& scene = m_context->scene();
        const unsigned slot = m_fired % m_options.maxProjectiles;
        if (m_projectiles[slot] != nullptr)
        {
            scene.removeActor(*m_projectiles[slot]);
            m_projectiles[slot]->release();
            m_projectiles[slot] = nullptr;
        }
        const PxVec3 from(origin[0], origin[1], origin[2]);
        const PxVec3 along(direction[0], direction[1], direction[2]);
        PxRigidDynamic* ball = PxCreateDynamic(physics, PxTransform(from),
                                               PxSphereGeometry(m_options.projectileRadius),
                                               m_context->material(), 1);
        if (ball == nullptr)
        {
            return fail("projectile allocation failed");
        }
        ball->setMass(m_options.projectileMass);
        ball->setMassSpaceInertiaTensor(
            PxVec3(0.4f * m_options.projectileMass * m_options.projectileRadius * m_options.projectileRadius));
        ball->setLinearDamping(0);
        ball->setAngularDamping(0);
        ball->setLinearVelocity(along * m_options.projectileSpeed);
        scene.addActor(*ball);
        m_projectiles[slot] = ball;
        ++m_fired;
        refreshBodies();
        return true;
    }

    void teardown()
    {
        using namespace physx;
        if (m_context == nullptr)
        {
            return;
        }
        // Once the GPU context has faulted, PhysX teardown is not a cleanup
        // path any more: clearStress() reaches cudaFree, which synchronises a
        // stream that can no longer be flushed, and the process aborts inside
        // malloc instead of exiting. Drop the scene instead of unwinding it -
        // the process is on its way out and a leak beats corrupting the heap.
        if (m_failed || !m_context->healthy())
        {
            m_destruction = nullptr;
            m_wall = nullptr;
            m_shapes.clear();
            m_projectiles.clear();
            m_bodies.clear();
            m_context = nullptr;
            return;
        }
        PxScene& scene = m_context->scene();
        // Stress must be cleared before its actors go away.
        if (m_destruction != nullptr)
        {
            m_destruction->clearStress();
            m_destruction = nullptr;
        }
        for (PxRigidDynamic*& ball : m_projectiles)
        {
            if (ball != nullptr)
            {
                scene.removeActor(*ball);
                ball->release();
                ball = nullptr;
            }
        }
        m_projectiles.clear();
        // Fracture reparents shapes onto new actors, so release every actor the
        // wall's shapes now belong to, not just the original wall body.
        std::vector<PxRigidActor*> owners;
        for (PxShape* shape : m_shapes)
        {
            PxRigidActor* owner = shape != nullptr ? shape->getActor() : nullptr;
            if (owner != nullptr
                && std::find(owners.begin(), owners.end(), owner) == owners.end())
            {
                owners.push_back(owner);
            }
        }
        for (PxShape* shape : m_shapes)
        {
            if (shape != nullptr) shape->release();
        }
        m_shapes.clear();
        for (PxRigidActor* owner : owners)
        {
            scene.removeActor(*owner);
            owner->release();
        }
        m_wall = nullptr;
        m_bodies.clear();
        m_context = nullptr;
    }

private:
    bool fail(const std::string& message)
    {
        if (m_error.empty())
        {
            m_error = message;
        }
        // Remembered so teardown knows the scene is not in a state it can
        // safely unwind.
        m_failed = true;
        return false;
    }

    void refreshBodies()
    {
        using namespace physx;
        const unsigned count = chunkCount();
        m_bodies.assign(count + m_options.maxProjectiles, BodyView{});
        for (unsigned i = 0; i < count; ++i)
        {
            PxShape* shape = m_shapes[i];
            PxRigidActor* owner = shape != nullptr ? shape->getActor() : nullptr;
            BodyView& body = m_bodies[i];
            if (owner == nullptr)
            {
                continue;
            }
            const PxTransform world = owner->getGlobalPose() * shape->getLocalPose();
            for (int k = 0; k < 3; ++k) body.position[k] = world.p[k];
            body.rotation[0] = world.q.x;
            body.rotation[1] = world.q.y;
            body.rotation[2] = world.q.z;
            body.rotation[3] = world.q.w;
            for (int k = 0; k < 3; ++k) body.half[k] = 0.48f;
            body.sphere = false;
            body.live = true;
            // The owning actor is the fragment identity; hash the pointer so
            // every chunk of one fragment shares a colour that follows it.
            const std::uintptr_t handle = reinterpret_cast<std::uintptr_t>(owner);
            body.group = std::uint32_t((handle >> 4) * 2654435761u);
        }
        for (unsigned i = 0; i < m_options.maxProjectiles; ++i)
        {
            BodyView& body = m_bodies[count + i];
            body.sphere = true;
            for (int k = 0; k < 3; ++k) body.half[k] = m_options.projectileRadius;
            PxRigidDynamic* ball = i < m_projectiles.size() ? m_projectiles[i] : nullptr;
            if (ball == nullptr)
            {
                body.live = false;
                continue;
            }
            const PxTransform world = ball->getGlobalPose();
            for (int k = 0; k < 3; ++k) body.position[k] = world.p[k];
            body.rotation[0] = world.q.x;
            body.rotation[1] = world.q.y;
            body.rotation[2] = world.q.z;
            body.rotation[3] = world.q.w;
            body.live = true;
            body.group = 0xFFFFFFFFu;
        }
    }

    WallOptions m_options;
    blast_demo::PhysXScene* m_context{nullptr};
    physx::PxRigidDynamic* m_wall{nullptr};
    physx::PxDestructionScene* m_destruction{nullptr};
    std::vector<physx::PxShape*> m_shapes;
    std::vector<physx::PxRigidDynamic*> m_projectiles;
    std::vector<BodyView> m_bodies;
    unsigned m_bondCount{0};
    unsigned m_brokenBonds{0};
    unsigned m_fired{0};
    double m_lastStepMs{0};
    bool m_failed{false};
    std::string m_error;
};

} // namespace wall_live
