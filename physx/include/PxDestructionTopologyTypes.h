// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <cstdint>
namespace physx {
// Immutable mass properties in the asset frame. Inertia is about the chunk's
// own COM, expressed in asset axes: xx, yy, zz, xy, xz, yz. Support is independent
// of physical mass (the stress solver may use zero mass for a support node).
struct PxDestructionChunkMassProperties {
    double center[3];
    double mass;
    double inertia[6];
    std::uint32_t supported;
};
struct PxDestructionBondEndpoints { std::uint32_t chunk0, chunk1; };
struct PxDestructionClusterMassProperties {
    double center[3];
    double mass;
    double inertia[6];
    std::uint32_t chunkCount, supported;
};
// One live motion per connected component. The transform maps asset to world
// space; linear velocity is at this cluster's COM, angular velocity is world-space.
struct PxDestructionClusterMotion {
    double origin[3], orientation[4];
    double linearVelocity[3], angularVelocity[3];
};
struct PxDestructionTopologyStatus {
    std::uint64_t generation;
    std::uint32_t clusterCount, invalidEdit, changed;
};
struct PxDestructionTopologyDeviceView {
    const PxDestructionChunkMassProperties* chunks;
    const PxDestructionBondEndpoints* bonds;
    const std::uint32_t* activeBonds;
    const std::uint32_t* activeChunks;
    const std::uint32_t* chunkCluster;
    const std::uint32_t* orderedChunks;
    const std::uint32_t* activeClusters;
    const PxDestructionClusterMassProperties* clusters;
    const PxDestructionTopologyStatus* status;
    PxDestructionClusterMotion* motions;
    std::uint32_t chunkCount, bondCount;
    void* readyEvent;
};
struct PxDestructionTopologyTransactionStatus {
    std::uint64_t rebuilds, commits;
    std::uint32_t prepared, error, changed, editCount;
    // error bits: 1 invalid edit, 2 device count exceeds capacity, 4 producer
    // rejected the trial. Only prepared trials have valid candidate arrays.
};
} // namespace physx
