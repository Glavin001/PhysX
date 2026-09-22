// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// Proves the zero-copy encode path in isolation, before any renderer exists.
//
// A compute shader writes a known pattern directly into the IOSurface-backed
// texture the encoder hands out; the resulting file is then decoded and checked
// against the same pattern. Colour-space and pixel-format mistakes in this chain
// fail silently (green or swapped-channel frames), so proving it separately
// keeps those faults from masquerading as renderer bugs later.
#include "encoder.h"

#import <Metal/Metal.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

namespace
{
// Deliberately asymmetric in all three channels so a channel swap cannot pass.
const char* kPatternSource = R"METAL(
#include <metal_stdlib>
using namespace metal;

struct Params { uint width; uint height; uint frame; uint frames; };

kernel void pattern(texture2d<float, access::write> target [[texture(0)]],
                    constant Params& p [[buffer(0)]],
                    uint2 gid [[thread_position_in_grid]])
{
    if (gid.x >= p.width || gid.y >= p.height) return;
    const float u = float(gid.x) / float(p.width  - 1);
    const float v = float(gid.y) / float(p.height - 1);
    const float t = float(p.frame) / float(max(p.frames - 1u, 1u));
    // Red ramps across, green down, blue advances with time.
    target.write(float4(u, v, t, 1.0), gid);
}
)METAL";

struct Params
{
    std::uint32_t width, height, frame, frames;
};

int fail(const std::string& message)
{
    std::fprintf(stderr, "encoder_probe: %s\n", message.c_str());
    return 1;
}
} // namespace

int main(int argc, char** argv)
{
    std::string output;
    std::uint32_t width = 640, height = 360, frames = 30, fps = 60;
    for (int i = 1; i < argc; ++i)
    {
        const std::string flag = argv[i];
        if (flag == "--help")
        {
            std::puts("encoder_probe --output NEW_FILE.mp4 [--width 640 --height 360 --frames 30 --fps 60]");
            return 0;
        }
        if (i + 1 >= argc)
        {
            return fail("missing option value for " + flag);
        }
        const std::string value = argv[++i];
        if (flag == "--output") output = value;
        else if (flag == "--width") width = std::uint32_t(std::stoul(value));
        else if (flag == "--height") height = std::uint32_t(std::stoul(value));
        else if (flag == "--frames") frames = std::uint32_t(std::stoul(value));
        else if (flag == "--fps") fps = std::uint32_t(std::stoul(value));
        else return fail("unknown option " + flag);
    }
    if (output.empty())
    {
        return fail("--output is required");
    }

    @autoreleasepool
    {
        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (device == nil)
        {
            return fail("no Metal device");
        }

        NSError* error = nil;
        id<MTLLibrary> library = [device newLibraryWithSource:[NSString stringWithUTF8String:kPatternSource]
                                                      options:nil
                                                        error:&error];
        if (library == nil)
        {
            return fail(std::string("pattern shader failed: ")
                        + [[error localizedDescription] UTF8String]);
        }
        id<MTLComputePipelineState> pipeline =
            [device newComputePipelineStateWithFunction:[library newFunctionWithName:@"pattern"] error:&error];
        if (pipeline == nil)
        {
            return fail(std::string("pattern pipeline failed: ")
                        + [[error localizedDescription] UTF8String]);
        }
        id<MTLCommandQueue> queue = [device newCommandQueue];

        wall_render::EncoderOptions options;
        options.path = output;
        options.width = width;
        options.height = height;
        options.fps = fps;
        wall_render::Encoder encoder;
        if (!encoder.open(device, options))
        {
            return fail(encoder.error());
        }

        for (std::uint32_t frame = 0; frame < frames; ++frame)
        {
            wall_render::EncoderFrame target{};
            if (!encoder.acquire(target))
            {
                return fail(encoder.error());
            }

            Params params{width, height, frame, frames};
            id<MTLCommandBuffer> commands = [queue commandBuffer];
            id<MTLComputeCommandEncoder> pass = [commands computeCommandEncoder];
            [pass setComputePipelineState:pipeline];
            [pass setTexture:target.texture atIndex:0];
            [pass setBytes:&params length:sizeof(params) atIndex:0];
            const MTLSize threads = MTLSizeMake(16, 16, 1);
            const MTLSize groups = MTLSizeMake((width + 15) / 16, (height + 15) / 16, 1);
            [pass dispatchThreadgroups:groups threadsPerThreadgroup:threads];
            [pass endEncoding];
            [commands commit];
            // The encoder reads the surface directly, so the GPU must be done
            // with it before the frame is handed over.
            [commands waitUntilCompleted];

            if (!encoder.submit(target, frame))
            {
                return fail(encoder.error());
            }
        }

        if (!encoder.finish())
        {
            return fail(encoder.error());
        }
        std::printf("encoder_probe: wrote %llu frames at %ux%u to %s\n",
                    static_cast<unsigned long long>(encoder.submitted()), width, height, output.c_str());
    }
    return 0;
}
