// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <PxDestructionScene.h>

namespace blast_demo {
// Immutable authored visual data. Neither this buffer nor the render buffer is
// a second simulation: ownership and motion are borrowed from acceptedTopology.
struct NativeGpuVisual { physx::PxVec3 position, half; physx::PxU32 palette; };
struct NativeGpuInstance { float position[4], orientation[4], scale[4], color[4]; };
struct NativeGpuVisualStatus { physx::PxU32 errors, visible; };
// Asynchronous, on the caller's scene-context stream. Caller must wait for the
// accepted view and publish a consumer event before its next mutation. All
// output pointers are device memory (including a mapped graphics buffer).
void writeNativeGpuInstances(physx::PxDestructionDeviceView view,
    const NativeGpuVisual* visuals, const physx::PxTransform* projectiles,
    physx::PxU32 projectileCount, NativeGpuInstance* output,
    NativeGpuVisualStatus* status, CUstream stream);
// Explicit gameplay query: only the scalar required launch height is observed
// on CPU. No pose/topology readback. Radius is a conservative bounding sphere.
void queryNativeGpuLaunch(physx::PxDestructionDeviceView view,
    const NativeGpuVisual* visuals, const physx::PxTransform* projectiles,
    physx::PxU32 projectileCount, physx::PxVec3 launch, float radius,
    float* height, CUstream stream);
}
