// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// One bonded structure, authored once for both the capture CLI and the live
// app: a list of box bricks and the bonds between them, turned into a single
// kinematic PhysX actor and one destruction stress cluster.
//
// The wall is the grid the capture always built. Any box-only ScenePack
// (blast/blast-stress-demo-rs/assets/scenes) is the same shape of data, so the
// brick building and anything like it go through the identical path. Fracture,
// correction and motion stay PhysX's; nothing here scripts damage.
#pragma once

#include "physx_scene.h"
#include "scene_pack.h"

#include <PxDestructionScene.h>
#include <PxPhysicsAPI.h>

#include <algorithm>
#include <cmath>
#include <cstdint>
#include <stdexcept>
#include <string>
#include <vector>

namespace blast_demo
{

struct StructureBrick
{
    physx::PxVec3 centre{0.0f};
    physx::PxVec3 half{0.5f};
    float mass{0.0f};         // mass of the free brick, also for supports
    bool foundation{false};   // an authored support node (stress mass zero)
};

struct StructureBond
{
    std::uint32_t chunk0{0}, chunk1{0}; // chunk0 < chunk1
    physx::PxVec3 centroid{0.0f};
    physx::PxVec3 normal{0.0f, 1.0f, 0.0f};
    float area{1.0f};
    std::uint32_t material{0}; // 0 = structure, 1 = foundation mortar
};

struct Structure
{
    std::string name;
    std::vector<StructureBrick> bricks;
    std::vector<StructureBond> bonds;
    physx::PxVec3 centre{0.0f}; // cluster-local centre of mass for centrifugal loading
    physx::PxVec3 lower{0.0f}, upper{0.0f}; // collider bounds
    // The plane the projectile is launched towards: the lowest brick centre z.
    float front{0.0f};
    // Default impact point on that face.
    float aimHeight{0.0f};
    // Nonzero only for the grid wall, whose reports are laid out by row.
    unsigned gridWidth{0}, gridHeight{0};

    unsigned foundationCount() const
    {
        return unsigned(std::count_if(bricks.begin(), bricks.end(),
                                      [](const StructureBrick& b) { return b.foundation; }));
    }
};

inline void finishBounds(Structure& s)
{
    s.lower = physx::PxVec3(PX_MAX_F32);
    s.upper = physx::PxVec3(-PX_MAX_F32);
    s.front = PX_MAX_F32;
    for (const StructureBrick& b : s.bricks)
    {
        s.lower = s.lower.minimum(b.centre - b.half);
        s.upper = s.upper.maximum(b.centre + b.half);
        s.front = std::min(s.front, b.centre.z);
    }
}

// Exactly the grid native_wall_capture has always authored: 0.96 m cubes on a
// 1 m pitch, bonds to the -x and -y neighbours, and a separate stronger mortar
// on the vertical row-0/1 ties only.
inline Structure makeWall(unsigned width, unsigned height)
{
    using namespace physx;
    Structure s;
    s.name = "wall";
    s.gridWidth = width;
    s.gridHeight = height;
    const PxVec3 half(0.48f);
    const float volume = 8 * half.x * half.y * half.z;
    const float blockMass = 1000 * volume;
    for (unsigned y = 0; y < height; ++y)
    {
        for (unsigned x = 0; x < width; ++x)
        {
            const unsigned id = y * width + x;
            const PxVec3 p(float(x) - float(width - 1) * 0.5f, float(y) + 0.5f, 0);
            s.bricks.push_back({p, half, blockMass, y == 0});
            auto bond = [&](unsigned other) {
                const PxVec3 d = p - s.bricks[other].centre;
                const bool foundation = y == 1 && other == id - width;
                s.bonds.push_back({other, id, (p + s.bricks[other].centre) * 0.5f, d.getNormalized(),
                                   4 * half.x * half.y, foundation ? 1u : 0u});
            };
            if (x) bond(id - 1);
            if (y) bond(id - width);
        }
    }
    s.centre = PxVec3(0, float(height) * 0.5f, 0);
    finishBounds(s);
    s.aimHeight = float(height) * 0.55f;
    return s;
}

// A box-only ScenePack as a structure. Colliders shrink by `colliderScale` (the
// wall's 0.96) so neighbouring bricks don't start in contact once they are
// separate bodies; bond geometry is the pack's own. Pack mass zero marks a
// support; bonds touching exactly one support use the foundation mortar, as the
// wall's row-0/1 ties do.
inline Structure structureFromScenePack(const ScenePack& pack, float colliderScale = 0.96f)
{
    using namespace physx;
    Structure s;
    s.name = pack.title;
    // The native stress path needs a real mass for supports too; give them the
    // mass their volume would have at the pack's brick density.
    float density = 0;
    for (const SceneNode& n : pack.nodes)
    {
        if (n.collider.kind != SceneColliderKind::Cuboid)
        {
            throw std::runtime_error("structure: only box colliders are qualified on this backend");
        }
        if (n.mass > 0 && n.volume > 0) density = std::max(density, n.mass / n.volume);
    }
    if (!(density > 0)) throw std::runtime_error("structure: pack has no massive brick");
    for (const SceneNode& n : pack.nodes)
    {
        const PxVec3 half = n.collider.halfExtents * colliderScale;
        const float volume = n.volume > 0 ? n.volume
                                          : 8 * n.collider.halfExtents.x * n.collider.halfExtents.y
                                                * n.collider.halfExtents.z;
        const bool support = !(n.mass > 0);
        s.bricks.push_back({n.centroid, half, support ? density * volume : n.mass, support});
    }
    for (const SceneBond& b : pack.bonds)
    {
        const std::uint32_t a = std::min(b.node0, b.node1), c = std::max(b.node0, b.node1);
        if (a == c || c >= s.bricks.size()) throw std::runtime_error("structure: invalid bond");
        PxVec3 normal = b.normal.getNormalized();
        // The runtime's convention: the normal points from chunk0 to chunk1.
        if (normal.dot(s.bricks[c].centre - s.bricks[a].centre) < 0) normal = -normal;
        const bool mortar = s.bricks[a].foundation != s.bricks[c].foundation;
        s.bonds.push_back({a, c, b.centroid, normal, b.area, mortar ? 1u : 0u});
    }
    std::sort(s.bonds.begin(), s.bonds.end(), [](const StructureBond& x, const StructureBond& y) {
        return x.chunk0 != y.chunk0 ? x.chunk0 < y.chunk0 : x.chunk1 < y.chunk1;
    });
    for (std::size_t i = 1; i < s.bonds.size(); ++i)
    {
        if (s.bonds[i].chunk0 == s.bonds[i - 1].chunk0 && s.bonds[i].chunk1 == s.bonds[i - 1].chunk1)
        {
            throw std::runtime_error("structure: duplicate bond");
        }
    }
    // One stress cluster must be exactly one connected component.
    std::vector<std::uint32_t> parent(s.bricks.size());
    for (std::uint32_t i = 0; i < parent.size(); ++i) parent[i] = i;
    auto root = [&](std::uint32_t i) {
        while (parent[i] != i) i = parent[i] = parent[parent[i]];
        return i;
    };
    for (const StructureBond& b : s.bonds) parent[root(b.chunk0)] = root(b.chunk1);
    for (std::uint32_t i = 1; i < parent.size(); ++i)
    {
        if (root(i) != root(0)) throw std::runtime_error("structure: pack is not one connected piece");
    }
    float total = 0;
    for (const StructureBrick& b : s.bricks)
    {
        s.centre += b.centre * b.mass;
        total += b.mass;
    }
    s.centre *= 1.0f / total;
    finishBounds(s);
    s.aimHeight = s.lower.y + (s.upper.y - s.lower.y) * 0.55f;
    return s;
}

// The scene names the front ends accept; anything else is a ScenePack path.
inline Structure loadStructure(const std::string& scene, unsigned wallWidth, unsigned wallHeight,
                               const std::string& scenesDirectory)
{
    if (scene.empty() || scene == "wall") return makeWall(wallWidth, wallHeight);
    const bool path = scene.find('/') != std::string::npos || scene.size() > 5
                      && scene.compare(scene.size() - 5, 5, ".json") == 0;
    return structureFromScenePack(loadScenePack(path ? scene : scenesDirectory + "/" + scene + ".json"));
}

// Principal box inertia of one brick, and the scalar the stress solver takes:
// the mean of the three, which for the wall's cubes is its m(hx^2+hy^2)/3.
inline physx::PxVec3 brickInertia(const StructureBrick& b)
{
    const physx::PxVec3 h2(b.half.x * b.half.x, b.half.y * b.half.y, b.half.z * b.half.z);
    return physx::PxVec3(h2.y + h2.z, h2.x + h2.z, h2.x + h2.y) * (b.mass / 3);
}
inline float brickStressInertia(const StructureBrick& b)
{
    if (b.half.x == b.half.y && b.half.y == b.half.z)
    {
        return b.mass * (b.half.x * b.half.x + b.half.y * b.half.y) / 3;
    }
    const physx::PxVec3 i = brickInertia(b);
    return (i.x + i.y + i.z) / 3;
}

struct StructureStressSettings
{
    physx::PxDestructionMaterial materials[2];
    unsigned iterations{8192};
    float tolerance{1e-3f};
};

// Standard material limits scaled by `strength`, with the foundation mortar a
// further `foundationStrength` times stronger. The wall's values.
inline StructureStressSettings structureStressSettings(float strength, float foundationStrength,
                                                       unsigned iterations, float tolerance)
{
    StructureStressSettings s;
    physx::PxDestructionMaterial& m = s.materials[0];
    m.compressionElasticLimit = 250000 * strength;
    m.compressionFatalLimit = 500000 * strength;
    m.tensionElasticLimit = 30000 * strength;
    m.tensionFatalLimit = 60000 * strength;
    m.shearElasticLimit = 80000 * strength;
    m.shearFatalLimit = 160000 * strength;
    physx::PxDestructionMaterial& f = s.materials[1];
    f = m;
    f.compressionElasticLimit *= foundationStrength;
    f.compressionFatalLimit *= foundationStrength;
    f.tensionElasticLimit *= foundationStrength;
    f.tensionFatalLimit *= foundationStrength;
    f.shearElasticLimit *= foundationStrength;
    f.shearFatalLimit *= foundationStrength;
    s.iterations = iterations;
    s.tolerance = tolerance;
    return s;
}

struct AuthoredStructure
{
    physx::PxRigidDynamic* actor{nullptr};
    std::vector<physx::PxShape*> shapes; // parallel to Structure::bricks
    physx::PxDestructionScene* destruction{nullptr};
};

// Builds the kinematic actor, steps once (the asset must be configured against
// a stepped scene), and configures the stress cluster. On failure `error` names
// the step; whatever was created is left in `out` for the caller to release.
inline bool authorStructure(const Structure& s, PhysXScene& context, const StructureStressSettings& settings,
                            AuthoredStructure& out, std::string& error)
{
    using namespace physx;
    PxPhysics& physics = context.physics();
    PxScene& scene = context.scene();
    const unsigned count = unsigned(s.bricks.size());
    out.actor = physics.createRigidDynamic(PxTransform(PxIdentity));
    if (out.actor == nullptr) return error = "structure allocation failed", false;
    out.actor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC, true);
    out.actor->setLinearDamping(0);
    out.actor->setAngularDamping(0);
    std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionChunkMassProperties> properties;
    PxVec3 totalInertia(0);
    float totalMass = 0;
    for (const StructureBrick& b : s.bricks)
    {
        PxShape* shape = physics.createShape(PxBoxGeometry(b.half), context.material(), true);
        if (shape == nullptr) return error = "structure shape allocation failed", false;
        shape->setLocalPose(PxTransform(b.centre));
        out.shapes.push_back(shape);
        if (!out.actor->attachShape(*shape)) return error = "structure shape attachment failed", false;
        const float stressInertia = brickStressInertia(b);
        const float volume = 8 * b.half.x * b.half.y * b.half.z;
        chunks.push_back({b.centre, b.foundation ? 0.0f : b.mass, b.foundation ? 0.0f : stressInertia, 0,
                          PX_INVALID_U32, volume, 0});
        PxDestructionChunkMassProperties prop{};
        prop.mass = b.mass;
        prop.supported = b.foundation;
        const bool cube = b.half.x == b.half.y && b.half.y == b.half.z;
        const PxVec3 principal = cube ? PxVec3(stressInertia) : brickInertia(b);
        for (unsigned k = 0; k < 3; ++k)
        {
            prop.center[k] = b.centre[k];
            prop.inertia[k] = principal[k];
        }
        properties.push_back(prop);
        const PxVec3 d = b.centre - s.centre;
        totalInertia += PxVec3(principal.x + b.mass * (d.y * d.y + d.z * d.z),
                               principal.y + b.mass * (d.x * d.x + d.z * d.z),
                               principal.z + b.mass * (d.x * d.x + d.y * d.y));
        totalMass += b.mass;
    }
    std::vector<PxDestructionStressBond> bonds;
    bonds.reserve(s.bonds.size());
    for (const StructureBond& b : s.bonds)
    {
        bonds.push_back({b.chunk0, b.chunk1, b.centroid, b.normal, b.area, 1, 1, b.material});
    }
    // A uniform structure keeps the product the wall has always used, so its
    // actor mass is bit-identical to the pre-refactor capture.
    const bool uniform = std::all_of(s.bricks.begin(), s.bricks.end(),
                                     [&](const StructureBrick& b) { return b.mass == s.bricks[0].mass; });
    out.actor->setMass(uniform ? s.bricks[0].mass * float(count) : totalMass);
    out.actor->setCMassLocalPose(PxTransform(s.centre));
    out.actor->setMassSpaceInertiaTensor(totalInertia);
    scene.addActor(*out.actor);

    scene.simulate(1.0f / 60.0f);
    PxU32 setupError = 0;
    if (!scene.fetchResults(true, &setupError) || setupError != 0 || !context.healthy())
    {
        return error = "structure setup step failed", false;
    }
    out.destruction = scene.getDestructionScene();
    if (out.destruction == nullptr) return error = "integrated destruction is unavailable", false;
    for (unsigned i = 0; i < count; ++i)
    {
        chunks[i].contactIndex = out.destruction->getShapeContactIndex(*out.shapes[i]);
        if (chunks[i].contactIndex == PX_INVALID_U32) return error = "structure collision identity missing", false;
    }
    PxDestructionStressCluster cluster{out.actor->getGPUIndex(), s.centre};
    PxDestructionStressDesc desc;
    desc.chunks = chunks.data();
    desc.chunkCount = count;
    desc.chunkMassProperties = properties.data();
    desc.clusters = &cluster;
    desc.clusterCount = 1;
    desc.bonds = bonds.data();
    desc.bondCount = PxU32(bonds.size());
    desc.materials = settings.materials;
    desc.materialCount = 2;
    desc.maxIterations = settings.iterations;
    desc.tolerance = settings.tolerance;
    desc.internalCorrectionLimit = 1;
    desc.gpuIslandRepair = false;
    desc.preserveUnchangedContactPairs = false;
    if (!out.destruction->configureStress(desc)) return error = "structure stress configuration failed", false;
    return true;
}

} // namespace blast_demo
