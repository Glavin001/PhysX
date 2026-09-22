// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// Hardware video encoding with no CPU copy of pixel data.
//
// Every frame is a CVPixelBuffer backed by an IOSurface. Metal renders straight
// into a texture that aliases that same surface, and VideoToolbox encodes the
// surface as-is, so a 1080p frame never crosses the CPU. That is the difference
// between a few milliseconds per frame and a readback-bound pipeline.
#pragma once

#include <cstdint>
#include <memory>
#include <string>

#ifdef __OBJC__
#import <Metal/Metal.h>
#endif

namespace wall_render
{

struct EncoderOptions
{
    std::string path;
    std::uint32_t width{1920};
    std::uint32_t height{1080};
    std::uint32_t fps{60};
    // Quality-targeted rather than bitrate-targeted: these are synthetic scenes
    // whose complexity varies enormously between a settled wall and an impact.
    float quality{0.75f};
    bool hevc{false};
};

// One frame's shared surface. The texture and the pixel buffer are the same
// memory; render into `texture`, then hand the frame back with submit().
struct EncoderFrame
{
    void* pixelBuffer{nullptr};
    // The CVMetalTexture that owns `texture`. Metal's texture is only valid
    // while this lives, so it is held until the frame is submitted rather than
    // released as soon as the texture is extracted.
    void* textureReference{nullptr};
#ifdef __OBJC__
    id<MTLTexture> texture{nil};
#else
    void* texture{nullptr};
#endif
};

class Encoder
{
public:
    Encoder();
    ~Encoder();

    Encoder(const Encoder&) = delete;
    Encoder& operator=(const Encoder&) = delete;

#ifdef __OBJC__
    // The device must be the one the renderer draws with, or the texture cache
    // cannot alias the surfaces.
    bool open(id<MTLDevice> device, const EncoderOptions& options);
#endif

    // Borrows the next writable frame. Blocks while the encoder is saturated,
    // which is what keeps memory bounded on long runs.
    bool acquire(EncoderFrame& frame);

    // Encodes a frame previously returned by acquire(). `index` fixes the
    // presentation time, so frames must be submitted in order.
    bool submit(const EncoderFrame& frame, std::uint64_t index);

    // Flushes the encoder and finalizes the container. Required: without it the
    // file has no moov atom and will not decode.
    bool finish();

    const std::string& error() const { return m_error; }
    std::uint64_t submitted() const { return m_submitted; }

private:
    struct State;
    std::unique_ptr<State> m_state;
    std::string m_error;
    std::uint64_t m_submitted{0};

    bool fail(const std::string& message);
};

} // namespace wall_render
