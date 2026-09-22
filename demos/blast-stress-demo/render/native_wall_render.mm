// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// Turns a committed TWSTATE1 trajectory into video on the Apple GPU.
//
// Links no PhysX and no GPU driver: this program cannot influence a simulation,
// it can only depict one that already happened. Poses are replayed exactly as
// recorded, with no interpolation, no smoothing and nothing hidden.
#include "encoder.h"
#include "renderer.h"
#include "twstate_reader.h"

#import <Metal/Metal.h>

#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <string>
#include <vector>

namespace
{
int fail(const std::string& message)
{
    std::fprintf(stderr, "native_wall_render: %s\n", message.c_str());
    return 1;
}

// Same containment rule the capture CLI applies: everything this project writes
// stays inside the two repository roots.
std::filesystem::path resolveOutput(const std::string& requested)
{
    namespace fs = std::filesystem;
    const auto source = fs::weakly_canonical(fs::absolute(fs::path(__FILE__)));
    const auto physx = source.parent_path().parent_path().parent_path().parent_path();
    const auto cumetal = fs::weakly_canonical(physx.parent_path() / "cuda-metal");
    const auto output = fs::weakly_canonical(fs::absolute(requested));
    auto inside = [](const fs::path& path, const fs::path& root) {
        auto p = path.begin();
        for (auto r = root.begin(); r != root.end(); ++r, ++p)
        {
            if (p == path.end() || *p != *r) return false;
        }
        return p != path.end();
    };
    if (!inside(output, physx) && !inside(output, cumetal))
    {
        throw std::runtime_error("output must remain inside PhysX or sibling cuda-metal");
    }
    if (fs::exists(output) || fs::is_symlink(fs::symlink_status(output)))
    {
        throw std::runtime_error("output already exists");
    }
    fs::create_directories(output.parent_path());
    return output;
}

double seconds(std::chrono::steady_clock::time_point from, std::chrono::steady_clock::time_point to)
{
    return std::chrono::duration<double>(to - from).count();
}
} // namespace

int main(int argc, char** argv)
{
    std::string statePath, outputPath;
    wall_render::RendererOptions render;
    wall_render::EncoderOptions encode;
    bool hevc = false;
    unsigned limit = 0;

    for (int i = 1; i < argc; ++i)
    {
        const std::string flag = argv[i];
        if (flag == "--help")
        {
            std::puts("native_wall_render --state IN.twstate --output NEW.mp4 "
                      "[--width 1920 --height 1080 --samples 4 --camera 0 --shadow 2048 "
                      "--frames 0 --codec h264|hevc --quality 0.75]");
            return 0;
        }
        if (i + 1 >= argc) return fail("missing value for " + flag);
        const std::string value = argv[++i];
        if (flag == "--state") statePath = value;
        else if (flag == "--output") outputPath = value;
        else if (flag == "--width") render.width = std::uint32_t(std::stoul(value));
        else if (flag == "--height") render.height = std::uint32_t(std::stoul(value));
        else if (flag == "--samples") render.samples = std::uint32_t(std::stoul(value));
        else if (flag == "--camera") render.camera = std::uint32_t(std::stoul(value));
        else if (flag == "--shadow") render.shadowResolution = std::uint32_t(std::stoul(value));
        else if (flag == "--frames") limit = unsigned(std::stoul(value));
        else if (flag == "--quality") encode.quality = std::stof(value);
        else if (flag == "--codec")
        {
            if (value == "hevc") hevc = true;
            else if (value != "h264") return fail("codec must be h264 or hevc");
        }
        else return fail("unknown option " + flag);
    }
    if (statePath.empty() || outputPath.empty()) return fail("--state and --output are required");
    if (render.samples != 1 && render.samples != 2 && render.samples != 4 && render.samples != 8)
        return fail("--samples must be 1, 2, 4 or 8");

    try
    {
        const auto output = resolveOutput(outputPath);

        wall_render::Trajectory trajectory;
        if (!trajectory.open(statePath)) return fail(trajectory.error());
        if (!trajectory.terminated())
        {
            std::fprintf(stderr,
                         "native_wall_render: warning: trajectory has no end record; "
                         "rendering the %u frames it does contain\n",
                         trajectory.recordedFrames());
        }

        const auto measureStart = std::chrono::steady_clock::now();
        const wall_render::SceneBounds bounds = wall_render::measure(trajectory);
        const auto measureEnd = std::chrono::steady_clock::now();

        @autoreleasepool
        {
            id<MTLDevice> device = MTLCreateSystemDefaultDevice();
            if (device == nil) return fail("no Metal device");

            encode.path = output.string();
            encode.width = render.width;
            encode.height = render.height;
            encode.fps = trajectory.fps();
            encode.hevc = hevc;

            wall_render::Renderer renderer;
            if (!renderer.open(device, trajectory, render, bounds)) return fail(renderer.error());
            wall_render::Encoder encoder;
            if (!encoder.open(device, encode)) return fail(encoder.error());

            const auto renderStart = std::chrono::steady_clock::now();
            std::uint64_t frames = 0;
            while (trajectory.advance())
            {
                if (limit != 0 && frames >= limit) break;
                wall_render::EncoderFrame frame{};
                if (!encoder.acquire(frame)) return fail(encoder.error());
                id<MTLCommandBuffer> commands = renderer.draw(trajectory.poses(), frame.texture);
                if (commands == nil) return fail(renderer.error());
                // The encoder reads the same surface the GPU just wrote, so the
                // frame must be complete before it is handed over.
                [commands waitUntilCompleted];
                if (commands.error != nil)
                {
                    return fail(std::string("GPU frame failed: ")
                                + [[commands.error localizedDescription] UTF8String]);
                }
                if (!encoder.submit(frame, frames)) return fail(encoder.error());
                ++frames;
            }
            const auto renderEnd = std::chrono::steady_clock::now();
            if (!encoder.finish()) return fail(encoder.error());
            const auto finishEnd = std::chrono::steady_clock::now();

            const double elapsed = seconds(renderStart, renderEnd);
            const double per = frames > 0 ? elapsed / double(frames) : 0.0;
            std::printf("native_wall_render: %llu frames %ux%u at %u fps, %zu bodies\n",
                        static_cast<unsigned long long>(frames), render.width, render.height,
                        trajectory.fps(), trajectory.actors().size());
            std::printf("  bounds scan %.3f s; render+encode %.3f s (%.3f ms/frame, %.1f fps); finalize %.3f s\n",
                        seconds(measureStart, measureEnd), elapsed, per * 1000.0,
                        per > 0 ? 1.0 / per : 0.0, seconds(renderEnd, finishEnd));
            std::printf("  output %s\n", output.string().c_str());
            if (limit == 0 && frames != trajectory.recordedFrames())
            {
                return fail("rendered frame count does not match the trajectory");
            }
        }
    }
    catch (const std::exception& e)
    {
        return fail(e.what());
    }
    return 0;
}
