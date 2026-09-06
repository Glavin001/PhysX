// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "native_gpu_visuals.h"
#include "state_writer.h"
#include <memory>
namespace blast_demo {
class NativeGpuConsumer {
    struct Impl;std::unique_ptr<Impl> m;
public:
    NativeGpuConsumer(physx::PxCudaContextManager& cuda,physx::PxDestructionScene& destruction,
        const std::vector<NativeGpuVisual>& visuals,unsigned projectileCapacity);
    ~NativeGpuConsumer();
    void addProjectile(physx::PxU32 body,const physx::PxTransform& initial);
    float launchHeight(physx::PxVec3 position,float radius);
    void update(physx::PxDirectGPUAPI& api);
    // Optional OpenGL consumer. Simulation requires no EGL or pixel readback.
    void enableRenderer(unsigned width,unsigned height,const Camera& camera,const std::string& video,unsigned fps);
    void render();
    void finishVideo();
    const std::string& rendererName() const;
    unsigned renderedFrames() const;
    unsigned long long queryReadbackBytes() const;
    unsigned long long pixelReadbackBytes() const;
};
}
