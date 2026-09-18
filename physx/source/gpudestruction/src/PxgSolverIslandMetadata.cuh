// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxvIslandMetadata.h"
namespace physx { namespace destructionSolverMetadata {
// One block per non-overlapping native metadata page. The upload and this
// scatter run on the solver stream before integration consumes either array.
__global__ void applyPages(const PxvIslandMetadataPage* pages,PxU32 count,
    PxU32* islandIds,PxU32 nodes,PxU32* staticTouches,PxU32 islands) {
    const PxU32 page=blockIdx.x;if(page>=count)return;
    const auto& p=pages[page];const PxU32 size=p.kind==0?nodes:islands;
    // Invalid internal commands must fail the CUDA step, never truncate rows.
    if(p.kind>1 || !p.count || p.count>PxvIslandMetadataPage::ePAGE_SIZE
        || p.offset>size || p.count>size-p.offset) { __trap();return; }
    PxU32* output=p.kind==0?islandIds:staticTouches;
    for(PxU32 i=threadIdx.x;i<p.count;i+=blockDim.x)output[p.offset+i]=p.values[i];
}
}}
