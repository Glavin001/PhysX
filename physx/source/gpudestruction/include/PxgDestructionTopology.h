// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once

#include <cstdint>
#include "PxDestructionTopologyTypes.h"

namespace physx {

// Compatibility names for the public mass/topology PODs.
using PxgDestructionChunk = PxDestructionChunkMassProperties;
using PxgDestructionBond = PxDestructionBondEndpoints;
using PxgDestructionCluster = PxDestructionClusterMassProperties;
using PxgDestructionClusterMotion = PxDestructionClusterMotion;
using PxgDestructionTopologyStatus = PxDestructionTopologyStatus;
using PxgDestructionTopologyView = PxDestructionTopologyDeviceView;

enum class PxgDestructionEditKind : std::uint32_t { BreakBond, DestroyChunk };
struct PxgDestructionEdit {
    PxgDestructionEditKind kind;
    std::uint32_t index;
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

/** GPU-owned fracture transaction. prepare() validates the entire device batch
 * and computes candidate connectivity/mass/motion, preserving accepted state.
 * commit() copies a prepared candidate only when its device acceptance flag is
 * nonzero. No edit count, graph or cluster state is read back to the CPU.
 *
 * Device views remain borrowed until the next prepare/commit/discard/release.
 * Only a trial with status()->prepared != 0 has readable candidate arrays.
 * Empty, redundant, rejected and invalid batches do not rebuild connectivity.
 * Optional sourceMotion supplies provisional parent motion in accepted cluster
 * order, leaving accepted motion unchanged while preparing a candidate.
 * All input pointers remain alive through readyEvent. Callers order readers and
 * motion writers with consumerDone, including on discarded and empty trials.
 */
class PxgDestructionTopologyTransaction {
public:
    static PxgDestructionTopologyTransaction* create(const PxgDestructionChunk* chunks,
        std::uint32_t chunkCount, const PxgDestructionBond* bonds, std::uint32_t bondCount);
    virtual bool prepare(const PxgDestructionEdit* deviceEdits, const std::uint32_t* deviceCount,
        std::uint32_t capacity, const std::uint32_t* deviceAbortFlags = nullptr,
        std::uint32_t abortMask = 0xffffffffu, void* producerReady = nullptr,
        void* consumerDone = nullptr, const PxgDestructionClusterMotion* sourceMotion = nullptr) = 0;
    virtual bool commit(const std::uint32_t* deviceAccept, void* producerReady = nullptr,
        void* consumerDone = nullptr) = 0;
    virtual bool discard(void* producerReady = nullptr, void* consumerDone = nullptr) = 0;
    virtual PxgDestructionTopologyView accepted() const = 0;
    virtual PxgDestructionTopologyView trial() const = 0;
    virtual const PxDestructionTopologyTransactionStatus* status() const = 0;
    virtual void release() = 0;
protected:
    virtual ~PxgDestructionTopologyTransaction() = default;
};

} // namespace physx
