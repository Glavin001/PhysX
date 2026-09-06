// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
namespace physx {
// Internal solver input transaction. Numeric values retain their native
// pre-solver meaning; this is not a replacement connectivity algorithm.
struct PxvPreSolveNode { PxU64 lifetime; PxU32 staticTouches,live; };
struct PxvPreSolveEdge { PxU32 a,b; };
struct PxvIslandMetadataPage {
    enum { ePAGE_SHIFT=8, ePAGE_SIZE=1<<ePAGE_SHIFT };
    PxU32 kind,offset,count; // kind 0: node -> native island; kind 1: static-touch counts
    PxU32 values[ePAGE_SIZE];
};
struct PxvIslandMetadataStats {
    PxU64 passes=0,fullUploads=0,pageUploads=0,quietPasses=0;
    PxU64 hostToDeviceBytes=0,fullEquivalentBytes=0,pages=0;
};
}
