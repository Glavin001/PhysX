// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgContactManager.h"
#include "PxNodeIndex.h"
#include "cudamanager/PxCudaTypes.h"
namespace physx {
struct PxsContactManagerOutput;
struct PxgShapeSim;
// Borrowed solved NP streams, valid until this scene's destruction consumer
// completes. CPU-address bases are tokens for offsets, never dereferenced on
// device. The producer records readyEvent after the streams' last writers;
// no compacted PxGpuContactPair array or count buffer is materialized.
struct PxgDestructionSolvedContacts {
    const PxgContactManagerInput* inputs=NULL;
    const PxsContactManagerOutput* outputs=NULL;
    const PxNodeIndex* shapeToRigid=NULL;
    const PxU8* cpuPatches=NULL;
    const PxU8* cpuPoints=NULL;
    const PxReal* cpuForces=NULL;
    const PxU8* patches=NULL;
    const PxU8* points=NULL;
    const PxReal* forces=NULL;
    const PxU8* friction=NULL;
    PxU32 pairCount=0;
};
// Bit values from PxcNpWorkUnitFlag, checked at the host integration boundary.
struct PxgDestructionContactFlags {
    enum { eARTICULATION = (1u<<3)|(1u<<4), eSOFT_BODY=1u<<7,
        eKINEMATIC_PAIR=1u<<11, eDISABLE_RESPONSE=1u<<12, eRETIRED=1u<<31 };
};
// Native contact edges without an active NP manager. Stored persistently on
// CUDA and updated at ordered lifecycle boundaries, not inferred from touch.
struct PxgDestructionRetainedEdge {
    enum { eACCURATE=1, eKINEMATIC=2, eUNSUPPORTED=4, eREMOVED=8 };
    PxU32 edgeIndex,node0,node1,flags;
};
struct PxgDestructionContactEdge {
    PxgContactGraphIdentity identity;
    PxU32 node0, node1, flags, touching;
};
// Borrowed current-pass NP buffers. Retirements are pinned host lifecycle
// indices, consumed on the solver stream before geometry is dereferenced.
struct PxgDestructionPreSolveContacts {
    const PxgContactManagerInput* inputs=NULL;
    const PxgContactGraphIdentity* identities=NULL;
    const PxsContactManagerOutput* outputs=NULL;
    const PxgShapeSim* shapes=NULL;
    const PxU32* retired=NULL;
    PxU32 pairCount=0,shapeCapacity=0,retiredCount=0;
    bool deriveStaticSupport=false;
};
struct PxgDestructionContactGraphObservationStats {
    // Lifetime counters; status bytes count even if incomplete input falls back.
    PxU64 observations=0, sortedGraphs=0, deviceToHostBytes=0;
    PxU64 retainedEdgesUploaded=0, retainedHostToDeviceBytes=0, retainedDeltaUpdates=0;
    PxU32 retainedSlotCapacity=0;
    PxU32 peakRetainedEdges=0;
};
struct PxgDestructionContactGraphStatus {
    enum { eMISSING_PAIRS=1, eINVALID_IDENTITY=2, eUNSUPPORTED_ENDPOINT=4, eLIFETIME_EXHAUSTED=8 };
    PxU32 error, omittedPairs;
};
// Snapshot of rigid contact connectivity, not yet a complete solver-island
// replacement: joints, sleeping registries and non-rigid edges remain separate.
// Labels are minimum node IDs. Static/kinematic contacts do not bridge dynamic
// components. Kinematic endpoints and unused capacity retain singleton labels;
// callers must use their live dynamic-node registry to interpret the domain.
// Regenerated for each narrowphase pass, including correction. Consume borrowed
// geometry at the producer boundary, before NP mutation or destruction ownership
// changes, which may occur again within this step. readyEvent orders production;
// it does not pin a snapshot through fetchResults. Owned labels describe this
// generation until rebuilt and do not extend the borrowed geometry lifetime.
struct PxgDestructionContactGraphView {
    // Borrow the resident NP/shape buffers instead of duplicating every edge.
    // Test the retirement bit before dereferencing a row's shape references:
    // a retired manager may outlive its geometry until deferred compaction.
    const PxgContactManagerInput* inputs = NULL;
    const PxgContactGraphIdentity* identities = NULL;
    const PxsContactManagerOutput* outputs = NULL;
    const PxgShapeSim* shapes = NULL;
    const PxU32* retiredMask = NULL; // one bit per pair; NULL when none retired
    const PxU32* accurateLabels = NULL;
    const PxU32* speculativeLabels = NULL;
    const PxgDestructionContactGraphStatus* status = NULL;
    PxU32 pairCount=0, shapeCapacity=0, nodeCapacity=0;
    PxU64 generation=0;
    CUevent readyEvent=NULL;
    const PxgDestructionRetainedEdge* retainedEdges=NULL;
    // Native edge-indexed resident slots. Only mask bits identify valid rows;
    // slot count is capacity, not the number of live edges. View generation
    // scopes these private indices across removal/reuse and reconfiguration.
    const PxU32* retainedActiveMask=NULL;
    PxU32 retainedSlotCount=0;
};
}
