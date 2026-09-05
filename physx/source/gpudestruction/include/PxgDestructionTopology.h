// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once

#include <cstdint>

namespace physx {

// Asset-frame mass properties. Geometry identity and these records never move
// when connectivity changes. The symmetric tensor is xx, yy, zz, xy, xz, yz.
struct PxgDestructionChunk {
    double center[3];
    double mass;
    double inertia[6];
    std::uint32_t supported;
};

struct PxgDestructionBond { std::uint32_t chunk0, chunk1; };
enum class PxgDestructionEditKind : std::uint32_t { BreakBond, DestroyChunk };
struct PxgDestructionEdit {
    PxgDestructionEditKind kind;
    std::uint32_t index;
};

// Slots are indexed by the smallest surviving authored chunk in a component.
// Only roots in activeClusters participate in motion/constraint solving.
struct PxgDestructionCluster {
    double center[3];
    double mass;
    double inertia[6];
    std::uint32_t chunkCount;
    std::uint32_t supported;
};

// One live motion record per active cluster, in activeClusters order. origin
// and orientation map the immutable asset frame into world space; linear
// velocity is at that cluster's COM, angular velocity is in world space.
struct PxgDestructionClusterMotion {
    double origin[3];
    double orientation[4]; // x, y, z, w
    double linearVelocity[3];
    double angularVelocity[3];
};

struct PxgDestructionTopologyStatus {
    std::uint64_t generation;
    std::uint32_t clusterCount;
    std::uint32_t invalidEdit;
    std::uint32_t changed;
};

struct PxgDestructionTopologyView {
    const PxgDestructionChunk* chunks;
    const PxgDestructionBond* bonds;
    const std::uint32_t* activeBonds;
    const std::uint32_t* activeChunks;
    const std::uint32_t* chunkCluster;
    const std::uint32_t* orderedChunks;
    const std::uint32_t* activeClusters;
    const PxgDestructionCluster* clusters;
    const PxgDestructionTopologyStatus* status;
    // Writable by the owning motion solver, after readyEvent. Order writes
    // before apply() with consumerDone. Only status->clusterCount entries are
    // live; allocation capacity permits every authored chunk to separate.
    PxgDestructionClusterMotion* motions;
    std::uint32_t chunkCount;
    std::uint32_t bondCount;
    void* readyEvent;
};

/** Persistent GPU graph and rigid-cluster mass properties, in the caller's CUDA
 * context. The current context must remain current during calls and destruction.
 * apply() takes device edits; invalid edits reject the whole batch. It never
 * invents breakage, reads back graph data or truncates a batch. Inputs and any
 * producer event must remain alive until readyEvent completes.
 *
 * Device views are borrowed until the next apply/release. The caller must order
 * all consumers before the next mutation (consumerDone); this also applies to
 * error/empty batches. No geometry is recreated and no CPU body is allocated.
 * Splits transfer the parent's rigid velocity field to each new COM on the
 * GPU. The supplied motions must be finite and orientations must be unit
 * quaternions, as for engine solver state. This primitive does not itself
 * advance motion or evaluate stress. It supports splits/removals, not merging
 * independently moving clusters or creation of new crush geometry.
 */
class PxgDestructionTopology {
public:
    static PxgDestructionTopology* create(const PxgDestructionChunk* chunks,
        std::uint32_t chunkCount, const PxgDestructionBond* bonds, std::uint32_t bondCount);
    virtual bool apply(const PxgDestructionEdit* deviceEdits, std::uint32_t editCount,
        void* producerReady = nullptr, void* consumerDone = nullptr) = 0;
    virtual PxgDestructionTopologyView view() const = 0;
    virtual void release() = 0;
protected:
    virtual ~PxgDestructionTopology() = default;
};

} // namespace physx
