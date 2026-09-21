// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxDestructionScene.h"

// Optional additive ABI supplied by libPhysXDestructionGpuRuntime_64.so.
// Resolve these entry points on the already-loaded runtime when supporting
// both older cold-only SDKs and this extension. No existing vtable changes.
//
// count is exactly 6 * authored bondCount, in original configureStress order:
// angular xyz followed by linear xyz, in physical units and the immutable
// authored stress coordinate frame. There are no convergence certificates,
// topology, material damage, body poses or GPU addresses in these values.
//
// Import is allowed once, after configureStress and before its first step,
// outside simulation. Every value must be finite. This is only an initial
// iterate; the next ordinary solve verifies residuals and evaluates damage.
// The caller binds values to the exact graph, materials, gravity and timestep.
// Export requires a completed converged step, no pending simulation and no
// destruction since configuration. Both calls return false on invalid state.
extern "C" bool PxDestructionExportWarmStartV1(
    physx::PxDestructionScene* scene, float* values, physx::PxU32 count);
extern "C" bool PxDestructionImportWarmStartV1(
    physx::PxDestructionScene* scene, const float* values, physx::PxU32 count);
