// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgContactManager.h"
#include "cudamanager/PxCudaTypes.h"
namespace physx {
struct PxsContactManagerOutput;
struct PxgShapeSim;
// Bit values from PxcNpWorkUnitFlag, checked at the host integration boundary.
struct PxgDestructionContactFlags {
    enum { eARTICULATION = (1u<<3)|(1u<<4), eSOFT_BODY=1u<<7,
        eKINEMATIC_PAIR=1u<<11, eDISABLE_RESPONSE=1u<<12, eRETIRED=1u<<31 };
};
struct PxgDestructionContactEdge {
    PxgContactGraphIdentity identity;
    PxU32 node0, node1, flags, touching;
};
struct PxgDestructionContactGraphStatus {
    enum { eMISSING_PAIRS=1, eINVALID_IDENTITY=2, eUNSUPPORTED_ENDPOINT=4 };
    PxU32 error, omittedPairs;
};
// Snapshot of rigid contact connectivity, not yet a complete solver-island
// replacement: joints, sleeping registries and non-rigid edges remain separate.
// Labels are minimum node IDs. Static/kinematic contacts do not bridge dynamic
// components. Kinematic endpoints and unused capacity retain singleton labels;
// callers must use their live dynamic-node registry to interpret the domain.
// Regenerated for each narrowphase pass, including correction. Views expire on
// the next simulation/configuration; wait readyEvent before reading device data.
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
};
}
