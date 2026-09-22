// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
//
// Interactive PhysX GPU destruction on Apple silicon.
//
// A window, a live scene and the same instanced Metal renderer the offline video
// path uses. Drag to orbit, scroll to zoom, click to fire a projectile along the
// view ray, R to rebuild the wall.
//
// This is an inspection tool, not an evidence path: nothing here is recorded and
// no result from it should be quoted. Use native_wall_capture for anything that
// needs to be verified, and note that a live session's projectile aim is
// whatever the viewer clicked rather than an authored value.
#include "encoder.h"
#include "renderer.h"
#include "twstate_reader.h"
#include "wall_scene.h"

#import <AppKit/AppKit.h>
#import <Metal/Metal.h>
#import <QuartzCore/CAMetalLayer.h>

#include <algorithm>
#include <chrono>
#include <cstdio>
#include <string>
#include <vector>

namespace
{

struct LiveState
{
    blast_demo::PhysXScene* context{nullptr};
    wall_live::WallScene* wall{nullptr};
    wall_render::Renderer* renderer{nullptr};
    std::vector<wall_render::Pose> poses;

    id<MTLCommandQueue> queue{nil};
    float azimuth{35.0f};
    float elevation{16.0f};
    float framing{0.85f};
    bool paused{false};
    bool failed{false};
    bool reported{false};
    std::string failure;

    // Rolling display so the title bar shows a steady number rather than noise.
    double stepAverage{0};
    double frameAverage{0};
    unsigned ticks{0};

    // Unattended self-check. Drives the same shoot() and reset paths the mouse
    // and keyboard drive, so the interactive code is what gets exercised rather
    // than a parallel test-only path, and reports what the scene actually did.
    unsigned selftestFrames{0};
    unsigned resetTick{0};
    bool resetDone{false};
    unsigned bondsBeforeReset{0};
    std::vector<float> startHeights;

    // Optional recording of exactly what the window shows.
    wall_render::Encoder* encoder{nullptr};
    std::uint64_t recorded{0};
};

LiveState g;

void applyCamera()
{
    if (g.renderer != nullptr)
    {
        g.renderer->setOrbit(g.azimuth, g.elevation, g.framing);
    }
}

// Fires at whatever is under a normalized device coordinate.
//
// Spawning at the eye looks right and behaves wrong: from a framing distance of
// tens of metres a 30 m/s shot spends most of a second in flight and gravity
// bends it metres below the aim point, so a click on the middle of the wall
// lands in the dirt. Release it a short way in front of the wall plane instead,
// which cuts the drop to centimetres and makes a click hit what it points at.
bool fireThrough(float ndcX, float ndcY)
{
    float origin[3], direction[3];
    g.renderer->cameraRay(ndcX, ndcY, origin, direction);
    constexpr float standoff = 6.0f;
    if (std::abs(direction[2]) > 1e-4f)
    {
        const float toPlane = (g.wall->wallFront() - origin[2]) / direction[2]; // the structure's front face
        if (toPlane > standoff)
        {
            for (int k = 0; k < 3; ++k)
            {
                origin[k] += direction[k] * (toPlane - standoff);
            }
        }
    }
    return g.wall->shoot(origin, direction);
}

// The renderer roster is fixed at open, so poses mirror it one for one and an
// unfired projectile slot is simply hidden.
void syncPoses()
{
    const std::vector<wall_live::BodyView>& bodies = g.wall->bodies();
    g.poses.resize(bodies.size());
    for (std::size_t i = 0; i < bodies.size(); ++i)
    {
        wall_render::Pose& pose = g.poses[i];
        for (int k = 0; k < 3; ++k) pose.position[k] = bodies[i].position[k];
        for (int k = 0; k < 4; ++k) pose.rotation[k] = bodies[i].rotation[k];
        pose.hidden = bodies[i].live ? 0 : 1;
        pose.group = bodies[i].group;
    }
}

} // namespace

@interface LiveView : NSView
@end

@implementation LiveView
{
    NSPoint m_lastDrag;
    bool m_dragged;
}

- (BOOL)acceptsFirstResponder { return YES; }
- (BOOL)isFlipped { return YES; }

- (void)mouseDown:(NSEvent*)event
{
    m_lastDrag = [event locationInWindow];
    m_dragged = false;
}

- (void)mouseDragged:(NSEvent*)event
{
    const NSPoint now = [event locationInWindow];
    const CGFloat dx = now.x - m_lastDrag.x;
    const CGFloat dy = now.y - m_lastDrag.y;
    if (std::abs(dx) + std::abs(dy) > 2.0)
    {
        m_dragged = true;
    }
    m_lastDrag = now;
    g.azimuth += float(dx) * 0.4f;
    // Stop just short of the poles, where a look-at basis degenerates.
    g.elevation = std::clamp(g.elevation + float(dy) * 0.3f, -12.0f, 85.0f);
    applyCamera();
}

- (void)mouseUp:(NSEvent*)event
{
    if (m_dragged || g.wall == nullptr || g.renderer == nullptr)
    {
        return;
    }
    // A click without a drag fires along the ray through that pixel.
    const NSPoint local = [self convertPoint:[event locationInWindow] fromView:nil];
    const NSSize size = self.bounds.size;
    if (size.width <= 0 || size.height <= 0)
    {
        return;
    }
    const float ndcX = float(local.x / size.width) * 2.0f - 1.0f;
    // The view is flipped, so y already runs downward like a texture.
    const float ndcY = 1.0f - float(local.y / size.height) * 2.0f;
    if (!fireThrough(ndcX, ndcY))
    {
        g.failed = true;
        g.failure = g.wall->error();
    }
}

- (void)scrollWheel:(NSEvent*)event
{
    g.framing = std::clamp(g.framing * (1.0f - float([event scrollingDeltaY]) * 0.01f), 0.25f, 3.0f);
    applyCamera();
}

- (void)keyDown:(NSEvent*)event
{
    const NSString* characters = [event charactersIgnoringModifiers];
    if ([characters length] == 0)
    {
        return;
    }
    switch ([characters characterAtIndex:0])
    {
        case 'r':
        case 'R':
        {
            // Rebuild the asset in the existing scene: the expensive part of
            // startup is shader and pipeline warm-up, which survives a reset.
            g.wall->teardown();
            if (!g.wall->build(*g.context))
            {
                g.failed = true;
                g.failure = g.wall->error();
            }
            else
            {
                syncPoses();
            }
            break;
        }
        case ' ':
            g.paused = !g.paused;
            break;
        case 27:
            [NSApp terminate:nil];
            break;
        default:
            break;
    }
}
@end

@interface LiveDelegate : NSObject <NSApplicationDelegate>
@property(nonatomic, strong) NSWindow* window;
@property(nonatomic, strong) LiveView* view;
@property(nonatomic, strong) CAMetalLayer* layer;
@property(nonatomic, strong) NSTimer* timer;
@end

@implementation LiveDelegate

- (void)tick
{
    if (g.failed)
    {
        // Report once to the log as well as the title: a window title is not
        // somewhere a failure can be read from a script or a transcript.
        if (!g.reported)
        {
            g.reported = true;
            std::fprintf(stderr, "native_wall_live: %s\n", g.failure.c_str());
            std::fflush(stderr);
            // A self-test is driven by a script; a failed one must not sit on
            // screen waiting for someone to read the title bar.
            if (g.selftestFrames != 0)
            {
                std::exit(1);
            }
        }
        self.window.title = [NSString stringWithFormat:@"PhysX destruction - FAILED: %s", g.failure.c_str()];
        return;
    }
    const auto frameStart = std::chrono::steady_clock::now();
    if (!g.paused)
    {
        if (!g.wall->step(1.0f / 60.0f))
        {
            g.failed = true;
            g.failure = g.wall->error();
            return;
        }
    }
    syncPoses();

    @autoreleasepool
    {
        id<CAMetalDrawable> drawable = [self.layer nextDrawable];
        if (drawable == nil)
        {
            return;
        }
        if (g.encoder != nullptr)
        {
            // Draw once into the encoder's surface and blit that to the window,
            // so the recording is the very image presented rather than a second
            // render that could differ.
            wall_render::EncoderFrame frame{};
            if (!g.encoder->acquire(frame))
            {
                g.failed = true;
                g.failure = g.encoder->error();
                return;
            }
            id<MTLCommandBuffer> commands = g.renderer->draw(g.poses, frame.texture);
            if (commands == nil)
            {
                g.failed = true;
                g.failure = g.renderer->error();
                return;
            }
            [commands waitUntilCompleted];
            id<MTLCommandBuffer> copy = [g.queue commandBuffer];
            id<MTLBlitCommandEncoder> blit = [copy blitCommandEncoder];
            [blit copyFromTexture:frame.texture toTexture:drawable.texture];
            [blit endEncoding];
            [copy presentDrawable:drawable];
            [copy commit];
            if (!g.encoder->submit(frame, g.recorded++))
            {
                g.failed = true;
                g.failure = g.encoder->error();
                return;
            }
        }
        else
        {
            id<MTLCommandBuffer> commands = g.renderer->draw(g.poses, drawable.texture, drawable);
            if (commands == nil)
            {
                g.failed = true;
                g.failure = g.renderer->error();
                return;
            }
        }
    }

    [self advanceSelftest];

    const double frameMs =
        std::chrono::duration<double, std::milli>(std::chrono::steady_clock::now() - frameStart).count();
    g.stepAverage += (g.wall->lastStepMilliseconds() - g.stepAverage) * 0.1;
    g.frameAverage += (frameMs - g.frameAverage) * 0.1;
    if (g.ticks == 0)
    {
        // Prove the loop is actually running, not just that a window appeared.
        std::printf("native_wall_live: first frame drawn; physics %.1f ms, frame %.1f ms\n",
                    g.wall->lastStepMilliseconds(), frameMs);
        std::fflush(stdout);
    }
    ++g.ticks;
    // Periodic line to the log as well as the title, so a session's real rate
    // can be read without a screenshot or accessibility access.
    if ((g.ticks % 240) == 0)
    {
        std::printf("native_wall_live: physics %.1f ms, frame %.1f ms (%.0f fps), %u bonds broken, %u fired\n",
                    g.stepAverage, g.frameAverage, g.frameAverage > 0 ? 1000.0 / g.frameAverage : 0.0,
                    g.wall->brokenBonds(), g.wall->firedProjectiles());
        std::fflush(stdout);
    }
    if ((g.ticks % 15) == 0)
    {
        self.window.title = [NSString
            stringWithFormat:@"PhysX destruction - %s (%u chunks) - physics %.1f ms - frame %.1f ms (%.0f fps) - "
                             @"%u bonds broken - %u fired%s",
                             g.wall->structure().name.c_str(), g.wall->chunkCount(), g.stepAverage, g.frameAverage,
                             g.frameAverage > 0 ? 1000.0 / g.frameAverage : 0.0, g.wall->brokenBonds(),
                             g.wall->firedProjectiles(), g.paused ? " - PAUSED" : ""];
    }
}

// Reports what the scene did rather than that the code ran: a projectile fired
// through the same path a click uses must actually break bonds and move chunks,
// and the reset path must rebuild an intact wall after that damage.
- (void)advanceSelftest
{
    if (g.selftestFrames == 0)
    {
        return;
    }
    const unsigned fireAt = 10;
    if (g.ticks == fireAt)
    {
        // Straight at the structure's authored impact point, as the capture
        // fires: the view centre of a tiled scene can be a gap between copies.
        const blast_demo::Structure& structure = g.wall->structure();
        const float origin[3] = {structure.aimX, structure.aimHeight, structure.front - 6.0f};
        const float direction[3] = {0, 0, 1};
        if (!g.wall->shoot(origin, direction))
        {
            g.failed = true;
            g.failure = g.wall->error();
            return;
        }
        std::printf("selftest: fired at the wall\n");
        std::fflush(stdout);
    }
    if (g.ticks == g.selftestFrames && !g.resetDone)
    {
        float lowest = 0, moved = 0;
        const std::vector<wall_live::BodyView>& bodies = g.wall->bodies();
        for (std::size_t i = 0; i < g.startHeights.size() && i < bodies.size(); ++i)
        {
            const float drop = g.startHeights[i] - bodies[i].position[1];
            moved = std::max(moved, std::abs(drop));
            lowest = std::min(lowest, -drop);
        }
        g.bondsBeforeReset = g.wall->brokenBonds();
        std::printf("selftest: after %u frames, %u bonds broken, largest chunk movement %.2f m\n",
                    g.ticks, g.bondsBeforeReset, moved);
        std::fflush(stdout);

        // Exercise the reset path that R drives, which has to release actors
        // the fracture reparented rather than just the original wall body.
        g.wall->teardown();
        if (!g.wall->build(*g.context))
        {
            g.failed = true;
            g.failure = g.wall->error();
            return;
        }
        syncPoses();
        g.resetDone = true;
        g.resetTick = g.ticks;
        std::printf("selftest: reset rebuilt the wall; %u bonds broken after reset\n", g.wall->brokenBonds());
        std::fflush(stdout);
    }
    if (g.resetDone && g.ticks >= g.resetTick + 30)
    {
        // A shot that breaks nothing proves only that the loop ran.
        const bool damaged = g.bondsBeforeReset > 0;
        std::printf("selftest: survived %u frames after reset; %s\n", g.ticks - g.resetTick,
                    damaged ? "PASS" : "FAIL (the shot broke no bonds)");
        std::fflush(stdout);
        if (g.encoder != nullptr && !g.encoder->finish())
        {
            std::fprintf(stderr, "selftest: recording failed: %s\n", g.encoder->error().c_str());
        }
        if (!damaged)
        {
            std::exit(1);
        }
        [NSApp terminate:nil];
    }
}

- (void)start
{
    // 120 Hz timer: physics decides the real rate, this only avoids sleeping
    // longer than necessary between steps. Scheduled before the run loop
    // starts rather than from applicationDidFinishLaunching:, so the loop does
    // not depend on that notification being delivered.
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 120.0
                                                  target:self
                                                selector:@selector(tick)
                                                userInfo:nil
                                                 repeats:YES];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender
{
    (void)sender;
    return YES;
}
@end

int main(int argc, char** argv)
{
    wall_live::WallOptions wallOptions;
    unsigned windowWidth = 1280, windowHeight = 720;
    std::string recordPath;
    for (int i = 1; i < argc; ++i)
    {
        const std::string flag = argv[i];
        if (flag == "--help")
        {
            std::puts("native_wall_live [--scene wall|brick-building|PACK.json] [--width 21 --height 5 --material-strength 1.5 "
                      "--foundation-strength 8 --stress-tolerance 0.001 --projectile-mass 600 --projectile-speed 30 "
                      "--window-width 1280 --window-height 720]\n"
                      "  drag: orbit   scroll: zoom   click: fire   R: reset   space: pause   esc: quit");
            return 0;
        }
        if (i + 1 >= argc)
        {
            std::fprintf(stderr, "native_wall_live: missing value for %s\n", flag.c_str());
            return 1;
        }
        const std::string value = argv[++i];
        if (flag == "--scene") wallOptions.scene = value;
        else if (flag == "--width") wallOptions.width = unsigned(std::stoul(value));
        else if (flag == "--height") wallOptions.height = unsigned(std::stoul(value));
        else if (flag == "--material-strength") wallOptions.materialStrength = std::stof(value);
        else if (flag == "--foundation-strength") wallOptions.foundationStrength = std::stof(value);
        else if (flag == "--stress-tolerance") wallOptions.stressTolerance = std::stof(value);
        else if (flag == "--projectile-mass") wallOptions.projectileMass = std::stof(value);
        else if (flag == "--projectile-speed") wallOptions.projectileSpeed = std::stof(value);
        else if (flag == "--window-width") windowWidth = unsigned(std::stoul(value));
        else if (flag == "--window-height") windowHeight = unsigned(std::stoul(value));
        else if (flag == "--selftest") g.selftestFrames = unsigned(std::stoul(value));
        else if (flag == "--record") recordPath = value;
        else
        {
            std::fprintf(stderr, "native_wall_live: unknown option %s\n", flag.c_str());
            return 1;
        }
    }
    if (wallOptions.scene == "wall"
        && (wallOptions.width < 3 || wallOptions.width > 32 || wallOptions.height < 3 || wallOptions.height > 32))
    {
        std::fprintf(stderr, "native_wall_live: wall dimensions must be 3..32\n");
        return 1;
    }

    // PhysX chases pointers it loaded from device memory, which on this backend
    // requires raw Metal device addresses; without it the scene dies with an
    // internal CUDA error partway through the first fracture. The app cannot
    // work without it, so it sets it rather than relying on the launcher - but
    // an explicit value from the environment still wins.
    setenv("CUMETAL_USE_METAL_DEVICE_ADDRESSES", "1", 0);

    @autoreleasepool
    {
        // Warn before the long silence: the first run after a build compiles
        // every Metal pipeline this scene touches, which dominates startup.
        std::printf("native_wall_live: preparing GPU pipelines; first launch after a build takes minutes\n");
        std::fflush(stdout);

        static wall_live::WallScene wall(wallOptions);
        if (!wall.loadError().empty())
        {
            std::fprintf(stderr, "native_wall_live: %s\n", wall.loadError().c_str());
            return 1;
        }
        blast_demo::SceneCapacity capacity;
        capacity.maxBodies = wall.chunkCount() + wallOptions.maxProjectiles + 16;
        capacity.maxShapes = capacity.maxBodies;
        static blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu, true, capacity, nullptr, false, true,
                                              false, false, physx::PxSolverType::eTGS, false, false);
        if (!context.gpuActive())
        {
            std::fprintf(stderr, "native_wall_live: a GPU scene is required\n");
            return 1;
        }
        if (!wall.build(context))
        {
            std::fprintf(stderr, "native_wall_live: %s\n", wall.error().c_str());
            return 1;
        }
        g.context = &context;
        g.wall = &wall;

        id<MTLDevice> device = MTLCreateSystemDefaultDevice();
        if (device == nil)
        {
            std::fprintf(stderr, "native_wall_live: no Metal device\n");
            return 1;
        }

        // The render roster is the wall plus every projectile slot, fixed for
        // the life of the window so instancing never has to resize.
        std::vector<wall_render::Actor> actors;
        for (const wall_live::BodyView& body : wall.bodies())
        {
            wall_render::Actor actor;
            actor.shape = body.sphere ? wall_render::Actor::Sphere : wall_render::Actor::Box;
            actor.part = body.sphere ? 1 : 0;
            for (int k = 0; k < 3; ++k) actor.parameters[k] = body.half[k];
            if (body.mesh != nullptr)
            {
                actor.shape = wall_render::Actor::Mesh;
                for (const physx::PxVec3& p : body.mesh->positions) actor.meshPositions.insert(actor.meshPositions.end(), {p.x, p.y, p.z});
                for (const physx::PxVec3& n : body.mesh->normals) actor.meshNormals.insert(actor.meshNormals.end(), {n.x, n.y, n.z});
                actor.meshIndices = body.mesh->indices;
            }
            actors.push_back(actor);
        }
        wall_render::SceneBounds bounds;
        const blast_demo::Structure& structure = wall.structure();
        // Room for thrown fragments, but sized to the structure rather than to
        // its width squared: over-padding pushes the camera far enough back that
        // a shot spends most of a second falling on its way in.
        bounds.minimum[0] = structure.lower.x - 2; bounds.maximum[0] = structure.upper.x + 2;
        bounds.minimum[1] = 0;                     bounds.maximum[1] = structure.upper.y + 2;
        bounds.minimum[2] = structure.lower.z - 3; bounds.maximum[2] = structure.upper.z + 3;

        wall_render::Camera camera;
        camera.fovDegrees = 55;
        std::vector<wall_render::Camera> cameras{camera};

        wall_render::RendererOptions renderOptions;
        renderOptions.width = windowWidth;
        renderOptions.height = windowHeight;
        renderOptions.samples = 4;
        renderOptions.orbit = true;
        renderOptions.orbitDegrees = g.azimuth;
        renderOptions.elevationDegrees = g.elevation;
        renderOptions.framing = g.framing;

        static wall_render::Renderer renderer;
        if (!renderer.open(device, actors, cameras, renderOptions, bounds))
        {
            std::fprintf(stderr, "native_wall_live: %s\n", renderer.error().c_str());
            return 1;
        }
        g.renderer = &renderer;
        g.queue = [device newCommandQueue];
        syncPoses();
        for (const wall_live::BodyView& body : wall.bodies())
        {
            g.startHeights.push_back(body.position[1]);
        }

        static wall_render::Encoder encoder;
        if (!recordPath.empty())
        {
            wall_render::EncoderOptions encodeOptions;
            encodeOptions.path = recordPath;
            encodeOptions.width = windowWidth;
            encodeOptions.height = windowHeight;
            encodeOptions.fps = 60;
            if (!encoder.open(device, encodeOptions))
            {
                std::fprintf(stderr, "native_wall_live: %s\n", encoder.error().c_str());
                return 1;
            }
            g.encoder = &encoder;
        }

        [NSApplication sharedApplication];
        [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];

        const NSRect frame = NSMakeRect(0, 0, windowWidth, windowHeight);
        NSWindow* window = [[NSWindow alloc]
            initWithContentRect:frame
                      styleMask:NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable
                        backing:NSBackingStoreBuffered
                          defer:NO];
        window.title = @"PhysX destruction";
        [window center];

        LiveView* view = [[LiveView alloc] initWithFrame:frame];
        view.wantsLayer = YES;
        CAMetalLayer* layer = [CAMetalLayer layer];
        layer.device = device;
        // Matches the renderer's colour attachment, so the same pipelines draw
        // to a window and to an encoder surface.
        layer.pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        layer.framebufferOnly = YES;
        layer.drawableSize = CGSizeMake(windowWidth, windowHeight);
        view.layer = layer;
        window.contentView = view;

        // NSApplication.delegate is a weak property, so ARC would be free to
        // release a local delegate straight after its last use and leave the
        // app with none. Hold it for the process lifetime.
        static LiveDelegate* delegate = nil;
        delegate = [[LiveDelegate alloc] init];
        delegate.window = window;
        delegate.view = view;
        delegate.layer = layer;
        NSApp.delegate = delegate;
        [delegate start];

        [window makeKeyAndOrderFront:nil];
        [window makeFirstResponder:view];
        [NSApp activateIgnoringOtherApps:YES];
        std::printf("native_wall_live: drag orbit, scroll zoom, click fire, R reset, space pause, esc quit\n");
        std::fflush(stdout);
        [NSApp run];
    }
    return 0;
}
