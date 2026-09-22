// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// Instanced Metal playback of rigid-body poses.
//
// Cost is designed to be flat in body count: every box is one instance of a
// shared unit cube and every sphere one instance of a shared UV sphere, so a
// frame is a handful of draw calls whether it holds sixty bodies or sixty
// thousand. Per frame the CPU writes one instance array and submits; there is no
// per-object traversal and nothing is read back.
#pragma once

#include <cstdint>
#include <memory>
#include <string>
#include <vector>

#include "twstate_reader.h"

#ifdef __OBJC__
#import <Metal/Metal.h>
#endif

namespace wall_render
{

struct RendererOptions
{
    std::uint32_t width{1920};
    std::uint32_t height{1080};
    std::uint32_t samples{4};
    std::uint32_t shadowResolution{2048};
    std::uint32_t camera{0};
    float groundY{0.0f};
    // When set, ignore the trajectory's authored camera and frame the whole
    // scene from an orbit around it. Azimuth 0 looks straight down the wall's
    // normal; positive degrees swing to the right. This keeps framing correct
    // for any scene size without re-capturing to change the view.
    bool orbit{false};
    float orbitDegrees{0.0f};
    float elevationDegrees{14.0f};
    float framing{1.15f};
};

// World extent used to fit the shadow frustum and the ground plane. Computed
// once over the whole trajectory so the light does not swim between frames.
struct SceneBounds
{
    float minimum[3]{0, 0, 0};
    float maximum[3]{0, 0, 0};
};

class Renderer
{
public:
    Renderer();
    ~Renderer();

    Renderer(const Renderer&) = delete;
    Renderer& operator=(const Renderer&) = delete;

#ifdef __OBJC__
    bool open(id<MTLDevice> device, const Trajectory& trajectory, const RendererOptions& options,
              const SceneBounds& bounds);

    // Draws one frame into `target`, which aliases the encoder's surface. The
    // returned command buffer has already been committed; the caller waits on it
    // before handing the surface to the encoder.
    id<MTLCommandBuffer> draw(const std::vector<Pose>& poses, id<MTLTexture> target);
#endif

    const std::string& error() const { return m_error; }

private:
    struct State;
    std::unique_ptr<State> m_state;
    std::string m_error;

    bool fail(const std::string& message);
};

// Sweeps the whole trajectory once to find the world extent, then rewinds it.
SceneBounds measure(Trajectory& trajectory);

} // namespace wall_render
