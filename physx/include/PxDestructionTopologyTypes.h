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
// Solver-body candidates, in compact activeClusters order. The actor frame
// remains the immutable asset frame; principal axes only change the COM frame.
// These are GPU-calculated candidates, not allocated/committed PhysX bodies.
struct PxDestructionClusterBodyState {
    float bodyToWorldPosition[3], bodyToWorldOrientation[4];
    float bodyToActorPosition[3], bodyToActorOrientation[4];
    float linearVelocity[3], angularVelocity[3]; // world space, velocity at stored COM
    float mass, principalInertia[3], inverseMass, inverseInertia[3];
    std::uint32_t cluster, sourceBody, supported;
};
struct PxDestructionBodyPreparationStatus {
    std::uint64_t generation;
    std::uint32_t count, valid, error, allocationRequests;
    // error bits: 1 invalid mass, 2 invalid/nonconverged inertia,
    // 4 invalid motion, 8 not representable as a PhysX float body.
    // Entire batch is usable only when valid != 0; errors never clamp physics.
};
// A GPU candidate-to-native-node mapping. These are private inactive BodySim
// reservations. initialized counts only new slots with physical GPU state;
// retained owners are unchanged until correction. Neither status commits actors.
struct PxDestructionBodyAllocationStatus {
    std::uint64_t generation;
    std::uint32_t count, reserved, valid, error;
    std::uint32_t initialized, initializationError; // 1 invalid mapping, 2 CUDA/storage failure
};
// GPU-owned native motion index allocation. Capacity contains granted addresses,
// not independently simulated bodies. Pending entries are private to correction;
// committed advances only with an accepted step. Clear invalidates this view.
struct PxDestructionMotionSlotStatus {
    std::uint32_t capacity, committed, pending, error;
};
// Persistent shape edits in stable authored chunk order. A target of
// UINT32_MAX removes collision for a destroyed chunk. A retained target still
// needs its changed cluster mass/COM and solver rows handled by correction.
struct PxDestructionCollisionBinding {
    std::uint32_t chunk, shape, sourceBody, targetBody;
};
struct PxDestructionCollisionPreparationStatus {
    std::uint64_t generation;
    std::uint32_t count, migrating, removed, affectedClusters, valid, error;
    // error: 1 invalid shape, 2 changed source ownership, 4 invalid target,
    // 8 unsupported collision geometry/flags, 16 CUDA failure, 32 invalid native remap,
    // 64 rejected fragment initialization prerequisite.
    // No physical shape ownership is changed by preparing this batch.
};
// Fractured solver-body inputs rewound to the saved pre-solve state. Geometry
// and mass come from the actual trial verdict; motion comes from its checkpoint.
struct PxDestructionCorrectionBody {
    PxDestructionClusterBodyState body;
    std::uint32_t targetBody;
};
struct PxDestructionCorrectionPreparationStatus {
    std::uint64_t generation, checkpointGeneration;
    std::uint32_t count, loadedSources, valid, error;
    // error: 1 missing/invalid checkpoint source, 2 native mapping,
    // 4 invalid/unrepresentable motion, 8 nonfinite input load, 16 CUDA failure,
    // 32 rejected collision prerequisite (originating collision error is retained),
    // 64 invalid original command-history receipt.
    // loadedSources counts affected source bodies with unapportioned external
    // accelerations or ordinary additive velocity commands. Count each source
    // once even when both representations are present. Those commands cannot
    // be cloned onto every fragment.
};
// A handle is valid in its asset/scene view only when slotRoots[slot] is live
// and slotGenerations[slot] matches. Authored chunk IDs remain independent.
struct PxDestructionClusterHandle {
    std::uint64_t generation;
    std::uint32_t slot;
};
struct PxDestructionTopologyStatus {
    std::uint64_t generation;
    std::uint32_t clusterCount, invalidEdit, changed;
    std::uint32_t slotError; // 1 capacity, 2 generation exhausted; never use an incomplete view

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
    // Stable motion-slot storage, NOT packed activeClusters order. Resolve
    // slot = clusterSlots[chunkCluster[chunk]], then read motions[slot].
    // A root retaining its authored minimum keeps its slot/generation. A root
    // that disappears retires its handle; reused slots advance generation.
    PxDestructionClusterMotion* motions;
    const std::uint32_t* clusterSlots; // authored root -> motion slot
    const std::uint32_t* slotRoots; // motion slot -> root, UINT32_MAX when free
    const std::uint64_t* slotGenerations;
    std::uint32_t slotCapacity;
    std::uint32_t chunkCount, bondCount;
    void* readyEvent;
};
// Accepted per-tick observation delta, ordered by immutable chunk/bond index.
// Every member of a changed source cluster is included, including retained
// members whose cluster handle survived but whose COM/membership changed.
struct PxDestructionChangedChunk {
    std::uint64_t generation;
    std::uint32_t chunk, root, slot, active;
};
struct PxDestructionCommittedChangesStatus {
    std::uint64_t frame, topologyGeneration;
    std::uint32_t chunkCount, bondCount, clusterCount, stressIslandCount;
    std::uint32_t error, fullSnapshot;
};
struct PxDestructionCommittedChangesView {
    const PxDestructionChangedChunk* chunks = nullptr;
    const std::uint32_t* brokenBonds = nullptr;
    const PxDestructionCommittedChangesStatus* status = nullptr;
    std::uint32_t chunkCapacity = 0, bondCapacity = 0;
};
struct PxDestructionTopologyTransactionStatus {
    std::uint64_t rebuilds, commits;
    std::uint32_t prepared, error, changed, editCount;
    // error bits: 1 invalid edit, 2 device count exceeds capacity, 4 producer
    // rejected the trial, 8 motion-slot allocation. Only prepared trials have valid candidate arrays.
};
} // namespace physx
