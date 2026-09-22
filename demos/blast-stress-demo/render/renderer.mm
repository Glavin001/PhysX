// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause

#include "renderer.h"

#import <Metal/Metal.h>

#include <algorithm>
#include <cmath>
#include <cstring>
#include <limits>

namespace wall_render
{
namespace
{

// Instance layout shared with the shader. Rotation stays a quaternion and is
// expanded on the GPU: 48 bytes per body rather than a 64-byte matrix, which
// matters once a frame carries tens of thousands of them.
struct Instance
{
    float position[4]; // xyz, w unused
    float rotation[4]; // quaternion xyzw
    float scale[4];    // half-extents or radius, w unused
    float colour[4];   // rgb, a = shadow-caster flag
};

struct Uniforms
{
    float viewProjection[16];
    float lightViewProjection[16];
    float lightDirection[4];
    float cameraPosition[4];
    float groundColour[4];
    float shadowTexel;
    float pad[3];
};

const char* kShaderSource = R"METAL(
#include <metal_stdlib>
using namespace metal;

struct Instance {
    float4 position;
    float4 rotation;
    float4 scale;
    float4 colour;
};

struct Uniforms {
    float4x4 viewProjection;
    float4x4 lightViewProjection;
    float4 lightDirection;
    float4 cameraPosition;
    float4 groundColour;
    float shadowTexel;
    float pad0;
    float pad1;
    float pad2;
};

static inline float3 rotate(float4 q, float3 v)
{
    const float3 u = q.xyz;
    return v + 2.0 * cross(u, cross(u, v) + q.w * v);
}

// packed_float3, not float3: MSL aligns float3 to 16 bytes, which would read
// this tightly packed 24-byte vertex at the wrong stride.
struct Vertex {
    packed_float3 position;
    packed_float3 normal;
};

struct Varyings {
    float4 position [[position]];
    float3 world;
    float3 normal;
    float3 colour;
};

vertex Varyings body_vertex(uint vertexId [[vertex_id]],
                            uint instanceId [[instance_id]],
                            const device Vertex* vertices [[buffer(0)]],
                            const device Instance* instances [[buffer(1)]],
                            constant Uniforms& uniforms [[buffer(2)]])
{
    const Instance inst = instances[instanceId];
    const Vertex v = vertices[vertexId];
    const float3 world = inst.position.xyz + rotate(inst.rotation, v.position * inst.scale.xyz);
    Varyings out;
    out.position = uniforms.viewProjection * float4(world, 1.0);
    out.world = world;
    out.normal = normalize(rotate(inst.rotation, v.normal));
    out.colour = inst.colour.rgb;
    return out;
}

vertex float4 shadow_vertex(uint vertexId [[vertex_id]],
                            uint instanceId [[instance_id]],
                            const device Vertex* vertices [[buffer(0)]],
                            const device Instance* instances [[buffer(1)]],
                            constant Uniforms& uniforms [[buffer(2)]])
{
    const Instance inst = instances[instanceId];
    const Vertex v = vertices[vertexId];
    const float3 world = inst.position.xyz + rotate(inst.rotation, v.position * inst.scale.xyz);
    return uniforms.lightViewProjection * float4(world, 1.0);
}

// Ground is a single full-extent quad; its vertices arrive pre-placed.
vertex Varyings ground_vertex(uint vertexId [[vertex_id]],
                              const device Vertex* vertices [[buffer(0)]],
                              constant Uniforms& uniforms [[buffer(2)]])
{
    const Vertex v = vertices[vertexId];
    Varyings out;
    out.position = uniforms.viewProjection * float4(v.position, 1.0);
    out.world = v.position;
    out.normal = v.normal;
    out.colour = uniforms.groundColour.rgb;
    return out;
}

static inline float shadow_factor(float3 world, constant Uniforms& uniforms,
                                  depth2d<float> shadowMap, sampler shadowSampler)
{
    const float4 light = uniforms.lightViewProjection * float4(world, 1.0);
    float3 projected = light.xyz / light.w;
    float2 uv = projected.xy * float2(0.5, -0.5) + 0.5;
    if (uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0 || uv.y > 1.0 || projected.z > 1.0) {
        return 1.0;
    }
    // Slope-independent bias; the scene is axis-aligned boxes on a flat ground,
    // so a constant depth bias is enough to avoid acne without peter-panning.
    const float bias = 0.0015;
    float lit = 0.0;
    for (int y = -1; y <= 1; ++y) {
        for (int x = -1; x <= 1; ++x) {
            const float2 offset = float2(x, y) * uniforms.shadowTexel;
            const float depth = shadowMap.sample(shadowSampler, uv + offset);
            lit += (projected.z - bias <= depth) ? 1.0 : 0.0;
        }
    }
    return mix(0.35, 1.0, lit / 9.0);
}

fragment float4 body_fragment(Varyings in [[stage_in]],
                              constant Uniforms& uniforms [[buffer(2)]],
                              depth2d<float> shadowMap [[texture(0)]],
                              sampler shadowSampler [[sampler(0)]])
{
    const float3 normal = normalize(in.normal);
    const float3 toLight = -normalize(uniforms.lightDirection.xyz);
    const float diffuse = max(dot(normal, toLight), 0.0);
    // Hemispheric ambient keeps downward faces readable without a second light.
    const float hemisphere = 0.5 + 0.5 * normal.y;
    const float3 ambient = mix(float3(0.16, 0.17, 0.20), float3(0.34, 0.36, 0.40), hemisphere);
    const float shadow = shadow_factor(in.world, uniforms, shadowMap, shadowSampler);
    float3 colour = in.colour * (ambient + diffuse * shadow * float3(1.05, 1.0, 0.92));

    // Subtle rim so adjacent same-coloured chunks stay distinguishable.
    const float3 toEye = normalize(uniforms.cameraPosition.xyz - in.world);
    colour += in.colour * 0.12 * pow(1.0 - saturate(dot(normal, toEye)), 3.0);

    // Filmic-ish shoulder, then sRGB encode is done by the render target format.
    colour = colour / (colour + 0.85);
    return float4(colour, 1.0);
}
)METAL";

void multiply(const float* a, const float* b, float* out)
{
    for (int c = 0; c < 4; ++c)
    {
        for (int r = 0; r < 4; ++r)
        {
            float sum = 0;
            for (int k = 0; k < 4; ++k)
            {
                sum += a[k * 4 + r] * b[c * 4 + k];
            }
            out[c * 4 + r] = sum;
        }
    }
}

void normalise(float* v)
{
    const float length = std::sqrt(v[0] * v[0] + v[1] * v[1] + v[2] * v[2]);
    if (length > 1e-6f)
    {
        v[0] /= length;
        v[1] /= length;
        v[2] /= length;
    }
}

void cross(const float* a, const float* b, float* out)
{
    out[0] = a[1] * b[2] - a[2] * b[1];
    out[1] = a[2] * b[0] - a[0] * b[2];
    out[2] = a[0] * b[1] - a[1] * b[0];
}

// Column-major look-at, matching Metal's float4x4 convention.
void lookAt(const float* eye, const float* target, float* out)
{
    float forward[3]{target[0] - eye[0], target[1] - eye[1], target[2] - eye[2]};
    normalise(forward);
    const float up[3]{0, 1, 0};
    float right[3];
    cross(forward, up, right);
    if (std::fabs(right[0]) + std::fabs(right[1]) + std::fabs(right[2]) < 1e-5f)
    {
        // Looking straight down: pick any stable basis rather than degenerating.
        right[0] = 1;
        right[1] = 0;
        right[2] = 0;
    }
    normalise(right);
    float trueUp[3];
    cross(right, forward, trueUp);

    out[0] = right[0];  out[4] = right[1];  out[8]  = right[2];  out[12] = -(right[0]  * eye[0] + right[1]  * eye[1] + right[2]  * eye[2]);
    out[1] = trueUp[0]; out[5] = trueUp[1]; out[9]  = trueUp[2]; out[13] = -(trueUp[0] * eye[0] + trueUp[1] * eye[1] + trueUp[2] * eye[2]);
    out[2] = -forward[0]; out[6] = -forward[1]; out[10] = -forward[2]; out[14] = (forward[0] * eye[0] + forward[1] * eye[1] + forward[2] * eye[2]);
    out[3] = 0; out[7] = 0; out[11] = 0; out[15] = 1;
}

// Metal clip space is z in [0,1], unlike OpenGL's [-1,1].
void perspective(float fovRadians, float aspect, float nearZ, float farZ, float* out)
{
    const float f = 1.0f / std::tan(fovRadians * 0.5f);
    std::memset(out, 0, sizeof(float) * 16);
    out[0] = f / aspect;
    out[5] = f;
    out[10] = farZ / (nearZ - farZ);
    out[11] = -1;
    out[14] = (farZ * nearZ) / (nearZ - farZ);
}

void orthographic(float halfWidth, float halfHeight, float nearZ, float farZ, float* out)
{
    std::memset(out, 0, sizeof(float) * 16);
    out[0] = 1.0f / halfWidth;
    out[5] = 1.0f / halfHeight;
    out[10] = 1.0f / (nearZ - farZ);
    out[14] = nearZ / (nearZ - farZ);
    out[15] = 1;
}

struct MeshRange
{
    std::uint32_t first{0};
    std::uint32_t count{0};
};

void appendBox(std::vector<float>& vertices, MeshRange& range)
{
    range.first = std::uint32_t(vertices.size() / 6);
    const float faces[6][6] = {
        {1, 0, 0, 1, 0, 0},  {-1, 0, 0, -1, 0, 0}, {0, 1, 0, 0, 1, 0},
        {0, -1, 0, 0, -1, 0}, {0, 0, 1, 0, 0, 1},  {0, 0, -1, 0, 0, -1},
    };
    for (const auto& face : faces)
    {
        const float n[3]{face[3], face[4], face[5]};
        // Two in-plane axes for this face.
        float a[3]{n[1], n[2], n[0]};
        float b[3];
        cross(n, a, b);
        cross(b, n, a);
        const float corners[6][2] = {{-1, -1}, {1, -1}, {1, 1}, {-1, -1}, {1, 1}, {-1, 1}};
        for (const auto& corner : corners)
        {
            for (int k = 0; k < 3; ++k)
            {
                vertices.push_back(n[k] + a[k] * corner[0] + b[k] * corner[1]);
            }
            for (int k = 0; k < 3; ++k)
            {
                vertices.push_back(n[k]);
            }
        }
    }
    range.count = std::uint32_t(vertices.size() / 6) - range.first;
}

void appendSphere(std::vector<float>& vertices, MeshRange& range, int segments, int rings)
{
    range.first = std::uint32_t(vertices.size() / 6);
    const float pi = 3.14159265358979323846f;
    auto point = [&](int ring, int segment, float* out) {
        const float phi = pi * float(ring) / float(rings);
        const float theta = 2.0f * pi * float(segment) / float(segments);
        out[0] = std::sin(phi) * std::cos(theta);
        out[1] = std::cos(phi);
        out[2] = std::sin(phi) * std::sin(theta);
    };
    for (int ring = 0; ring < rings; ++ring)
    {
        for (int segment = 0; segment < segments; ++segment)
        {
            float a[3], b[3], c[3], d[3];
            point(ring, segment, a);
            point(ring + 1, segment, b);
            point(ring + 1, segment + 1, c);
            point(ring, segment + 1, d);
            const float* triangles[6] = {a, b, c, a, c, d};
            for (const float* v : triangles)
            {
                for (int k = 0; k < 3; ++k) vertices.push_back(v[k]);
                for (int k = 0; k < 3; ++k) vertices.push_back(v[k]);
            }
        }
    }
    range.count = std::uint32_t(vertices.size() / 6) - range.first;
}

} // namespace

struct Renderer::State
{
    id<MTLDevice> device{nil};
    id<MTLCommandQueue> queue{nil};
    id<MTLRenderPipelineState> bodyPipeline{nil};
    id<MTLRenderPipelineState> groundPipeline{nil};
    id<MTLRenderPipelineState> shadowPipeline{nil};
    id<MTLDepthStencilState> depthState{nil};
    id<MTLSamplerState> shadowSampler{nil};
    id<MTLBuffer> vertexBuffer{nil};
    id<MTLBuffer> groundBuffer{nil};
    id<MTLTexture> colourTarget{nil};
    id<MTLTexture> depthTarget{nil};
    id<MTLTexture> shadowMap{nil};

    // Triple buffered so the CPU can build the next frame while two are in
    // flight on the GPU; this is what keeps the pipeline from serializing.
    static constexpr std::uint32_t kInFlight = 3;
    id<MTLBuffer> instances[kInFlight]{nil, nil, nil};
    id<MTLBuffer> uniforms[kInFlight]{nil, nil, nil};
    dispatch_semaphore_t inFlight{nullptr};
    std::uint32_t slot{0};

    MeshRange box;
    MeshRange sphere;
    RendererOptions options;
    SceneBounds bounds;
    Camera camera;
    std::vector<Actor> actors;
    std::vector<Instance> scratch;
    std::uint32_t boxCount{0};
    std::uint32_t sphereCount{0};
};

Renderer::Renderer() : m_state(std::make_unique<State>()) {}

Renderer::~Renderer() = default;

bool Renderer::fail(const std::string& message)
{
    if (m_error.empty())
    {
        m_error = message;
    }
    return false;
}

SceneBounds measure(Trajectory& trajectory)
{
    SceneBounds bounds;
    for (int k = 0; k < 3; ++k)
    {
        bounds.minimum[k] = std::numeric_limits<float>::max();
        bounds.maximum[k] = -std::numeric_limits<float>::max();
    }
    const std::vector<Actor>& actors = trajectory.actors();
    trajectory.rewind();
    while (trajectory.advance())
    {
        const std::vector<Pose>& poses = trajectory.poses();
        for (std::size_t i = 0; i < poses.size() && i < actors.size(); ++i)
        {
            const Actor& actor = actors[i];
            const float reach = std::max({actor.parameters[0], actor.parameters[1], actor.parameters[2]})
                * 1.7320508f; // a rotated box reaches its half-diagonal
            for (int k = 0; k < 3; ++k)
            {
                bounds.minimum[k] = std::min(bounds.minimum[k], poses[i].position[k] - reach);
                bounds.maximum[k] = std::max(bounds.maximum[k], poses[i].position[k] + reach);
            }
        }
    }
    trajectory.rewind();
    for (int k = 0; k < 3; ++k)
    {
        if (bounds.minimum[k] > bounds.maximum[k])
        {
            bounds.minimum[k] = -1;
            bounds.maximum[k] = 1;
        }
    }
    return bounds;
}

void Renderer::setOrbit(float azimuthDegrees, float elevationDegrees, float framing)
{
    // Place the eye on a sphere around the scene centre and pull back far
    // enough that the bounding sphere fits the narrower of the two field axes,
    // so nothing leaves frame regardless of aspect ratio.
    State& s = *m_state;
    float centre[3];
    float diagonal = 0;
    for (int k = 0; k < 3; ++k)
    {
        centre[k] = (s.bounds.minimum[k] + s.bounds.maximum[k]) * 0.5f;
        const float span = s.bounds.maximum[k] - s.bounds.minimum[k];
        diagonal += span * span;
    }
    const float radius = std::max(std::sqrt(diagonal) * 0.5f, 1.0f);
    const float fovY = s.camera.fovDegrees * 3.14159265f / 180.0f;
    const float aspect = float(s.options.width) / float(std::max<std::uint32_t>(s.options.height, 1));
    const float fovX = 2.0f * std::atan(std::tan(fovY * 0.5f) * aspect);
    const float fit = std::tan(std::min(fovY, fovX) * 0.5f);
    const float distance = radius / std::max(fit, 1e-3f) * std::max(framing, 0.05f);

    const float azimuth = azimuthDegrees * 3.14159265f / 180.0f;
    const float elevation = elevationDegrees * 3.14159265f / 180.0f;
    float offset[3]{std::sin(azimuth) * std::cos(elevation), std::sin(elevation),
                    -std::cos(azimuth) * std::cos(elevation)};
    normalise(offset);
    for (int k = 0; k < 3; ++k)
    {
        s.camera.eye[k] = centre[k] + offset[k] * distance;
        s.camera.direction[k] = centre[k] - s.camera.eye[k];
    }
    normalise(s.camera.direction);
}

void Renderer::cameraRay(float ndcX, float ndcY, float origin[3], float direction[3]) const
{
    const State& s = *m_state;
    float forward[3]{s.camera.direction[0], s.camera.direction[1], s.camera.direction[2]};
    normalise(forward);
    const float worldUp[3]{0, 1, 0};
    float right[3];
    cross(forward, worldUp, right);
    normalise(right);
    float up[3];
    cross(right, forward, up);

    const float fovY = s.camera.fovDegrees * 3.14159265f / 180.0f;
    const float tanY = std::tan(fovY * 0.5f);
    const float aspect = float(s.options.width) / float(std::max<std::uint32_t>(s.options.height, 1));
    const float tanX = tanY * aspect;
    for (int k = 0; k < 3; ++k)
    {
        origin[k] = s.camera.eye[k];
        direction[k] = forward[k] + right[k] * ndcX * tanX + up[k] * ndcY * tanY;
    }
    normalise(direction);
}

bool Renderer::open(id<MTLDevice> device, const Trajectory& trajectory, const RendererOptions& options,
                    const SceneBounds& bounds)
{
    if (trajectory.actors().empty())
    {
        return fail("trajectory declares no actors");
    }
    if (trajectory.cameras().empty())
    {
        return fail("trajectory declares no cameras");
    }
    return open(device, trajectory.actors(), trajectory.cameras(), options, bounds);
}

bool Renderer::open(id<MTLDevice> device, const std::vector<Actor>& actors, const std::vector<Camera>& cameras,
                    const RendererOptions& options, const SceneBounds& bounds)
{
    if (device == nil)
    {
        return fail("renderer requires a Metal device");
    }
    State& s = *m_state;
    s.device = device;
    s.options = options;
    s.bounds = bounds;
    s.actors = actors;
    if (s.actors.empty())
    {
        return fail("scene declares no actors");
    }
    if (cameras.empty())
    {
        return fail("scene declares no cameras");
    }
    s.camera = cameras[std::min<std::size_t>(options.camera, cameras.size() - 1)];
    if (options.orbit)
    {
        setOrbit(options.orbitDegrees, options.elevationDegrees, options.framing);
    }

    for (const Actor& actor : s.actors)
    {
        if (actor.shape == Actor::Sphere) ++s.sphereCount;
        else ++s.boxCount; // meshes fall back to their bounding box for now
    }

    @autoreleasepool
    {
        NSError* error = nil;
        id<MTLLibrary> library = [device newLibraryWithSource:[NSString stringWithUTF8String:kShaderSource]
                                                      options:nil
                                                        error:&error];
        if (library == nil)
        {
            return fail(std::string("render shader failed: ") + [[error localizedDescription] UTF8String]);
        }

        MTLRenderPipelineDescriptor* body = [[MTLRenderPipelineDescriptor alloc] init];
        body.vertexFunction = [library newFunctionWithName:@"body_vertex"];
        body.fragmentFunction = [library newFunctionWithName:@"body_fragment"];
        body.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        body.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        body.rasterSampleCount = options.samples;
        s.bodyPipeline = [device newRenderPipelineStateWithDescriptor:body error:&error];
        if (s.bodyPipeline == nil)
        {
            return fail(std::string("body pipeline failed: ") + [[error localizedDescription] UTF8String]);
        }

        MTLRenderPipelineDescriptor* ground = [[MTLRenderPipelineDescriptor alloc] init];
        ground.vertexFunction = [library newFunctionWithName:@"ground_vertex"];
        ground.fragmentFunction = [library newFunctionWithName:@"body_fragment"];
        ground.colorAttachments[0].pixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
        ground.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        ground.rasterSampleCount = options.samples;
        s.groundPipeline = [device newRenderPipelineStateWithDescriptor:ground error:&error];
        if (s.groundPipeline == nil)
        {
            return fail(std::string("ground pipeline failed: ") + [[error localizedDescription] UTF8String]);
        }

        MTLRenderPipelineDescriptor* shadow = [[MTLRenderPipelineDescriptor alloc] init];
        shadow.vertexFunction = [library newFunctionWithName:@"shadow_vertex"];
        shadow.fragmentFunction = nil; // depth only
        shadow.depthAttachmentPixelFormat = MTLPixelFormatDepth32Float;
        s.shadowPipeline = [device newRenderPipelineStateWithDescriptor:shadow error:&error];
        if (s.shadowPipeline == nil)
        {
            return fail(std::string("shadow pipeline failed: ") + [[error localizedDescription] UTF8String]);
        }

        MTLDepthStencilDescriptor* depth = [[MTLDepthStencilDescriptor alloc] init];
        depth.depthCompareFunction = MTLCompareFunctionLess;
        depth.depthWriteEnabled = YES;
        s.depthState = [device newDepthStencilStateWithDescriptor:depth];

        MTLSamplerDescriptor* sampler = [[MTLSamplerDescriptor alloc] init];
        sampler.minFilter = MTLSamplerMinMagFilterLinear;
        sampler.magFilter = MTLSamplerMinMagFilterLinear;
        sampler.sAddressMode = MTLSamplerAddressModeClampToEdge;
        sampler.tAddressMode = MTLSamplerAddressModeClampToEdge;
        s.shadowSampler = [device newSamplerStateWithDescriptor:sampler];

        std::vector<float> vertices;
        appendBox(vertices, s.box);
        appendSphere(vertices, s.sphere, 24, 12);
        s.vertexBuffer = [device newBufferWithBytes:vertices.data()
                                             length:vertices.size() * sizeof(float)
                                            options:MTLResourceStorageModeShared];

        // Ground spans the trajectory extent with generous margin so the plane
        // never visibly ends inside frame.
        const float spanX = std::max(bounds.maximum[0] - bounds.minimum[0], 1.0f);
        const float spanZ = std::max(bounds.maximum[2] - bounds.minimum[2], 1.0f);
        const float margin = std::max(spanX, spanZ) * 2.0f + 10.0f;
        const float cx = (bounds.minimum[0] + bounds.maximum[0]) * 0.5f;
        const float cz = (bounds.minimum[2] + bounds.maximum[2]) * 0.5f;
        const float y = options.groundY;
        const float quad[6][6] = {
            {cx - margin, y, cz - margin, 0, 1, 0}, {cx - margin, y, cz + margin, 0, 1, 0},
            {cx + margin, y, cz + margin, 0, 1, 0}, {cx - margin, y, cz - margin, 0, 1, 0},
            {cx + margin, y, cz + margin, 0, 1, 0}, {cx + margin, y, cz - margin, 0, 1, 0},
        };
        s.groundBuffer = [device newBufferWithBytes:quad length:sizeof(quad) options:MTLResourceStorageModeShared];

        MTLTextureDescriptor* colour = [MTLTextureDescriptor
            texture2DDescriptorWithPixelFormat:MTLPixelFormatBGRA8Unorm_sRGB
                                         width:options.width
                                        height:options.height
                                     mipmapped:NO];
        colour.textureType = options.samples > 1 ? MTLTextureType2DMultisample : MTLTextureType2D;
        colour.sampleCount = options.samples;
        colour.usage = MTLTextureUsageRenderTarget;
        colour.storageMode = MTLStorageModePrivate;
        s.colourTarget = [device newTextureWithDescriptor:colour];

        MTLTextureDescriptor* depthTexture = [MTLTextureDescriptor
            texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                         width:options.width
                                        height:options.height
                                     mipmapped:NO];
        depthTexture.textureType = options.samples > 1 ? MTLTextureType2DMultisample : MTLTextureType2D;
        depthTexture.sampleCount = options.samples;
        depthTexture.usage = MTLTextureUsageRenderTarget;
        depthTexture.storageMode = MTLStorageModePrivate;
        s.depthTarget = [device newTextureWithDescriptor:depthTexture];

        MTLTextureDescriptor* shadowTexture = [MTLTextureDescriptor
            texture2DDescriptorWithPixelFormat:MTLPixelFormatDepth32Float
                                         width:options.shadowResolution
                                        height:options.shadowResolution
                                     mipmapped:NO];
        shadowTexture.usage = MTLTextureUsageRenderTarget | MTLTextureUsageShaderRead;
        shadowTexture.storageMode = MTLStorageModePrivate;
        s.shadowMap = [device newTextureWithDescriptor:shadowTexture];

        const std::size_t instanceBytes = std::max<std::size_t>(s.actors.size(), 1) * sizeof(Instance);
        for (std::uint32_t i = 0; i < State::kInFlight; ++i)
        {
            s.instances[i] = [device newBufferWithLength:instanceBytes options:MTLResourceStorageModeShared];
            s.uniforms[i] = [device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
        }
        s.inFlight = dispatch_semaphore_create(State::kInFlight);
        s.queue = [device newCommandQueue];
        s.scratch.resize(s.actors.size());
    }
    return true;
}

id<MTLCommandBuffer> Renderer::draw(const std::vector<Pose>& poses, id<MTLTexture> target,
                                    id<MTLDrawable> present)
{
    State& s = *m_state;
    if (s.queue == nil || target == nil)
    {
        fail("renderer is not open");
        return nil;
    }

    dispatch_semaphore_wait(s.inFlight, DISPATCH_TIME_FOREVER);
    const std::uint32_t slot = s.slot;
    s.slot = (s.slot + 1) % State::kInFlight;

    // Boxes and spheres are drawn as two instanced ranges, so order the
    // instance array by shape rather than branching per body in the shader.
    std::uint32_t boxes = 0;
    std::uint32_t spheres = 0;
    const std::size_t count = std::min(poses.size(), s.actors.size());
    for (std::size_t i = 0; i < count; ++i)
    {
        const Actor& actor = s.actors[i];
        const Pose& pose = poses[i];
        // An unfired projectile slot occupies the roster but draws nothing.
        if (pose.hidden)
        {
            continue;
        }
        const bool sphere = actor.shape == Actor::Sphere;
        const std::size_t index = sphere ? (s.boxCount + spheres++) : boxes++;
        Instance& instance = s.scratch[index];
        for (int k = 0; k < 3; ++k) instance.position[k] = pose.position[k];
        instance.position[3] = 1;
        for (int k = 0; k < 4; ++k) instance.rotation[k] = pose.rotation[k];
        for (int k = 0; k < 3; ++k)
        {
            instance.scale[k] = sphere ? actor.parameters[0] : actor.parameters[k];
        }
        instance.scale[3] = 1;

        // Wall chunks share one colour tinted by cluster so a fragment stays
        // identifiable as it separates; the projectile keeps a fixed colour.
        float rgb[3];
        if (actor.part == 0)
        {
            const std::uint32_t group = pose.group;
            const float hash = group == 0xFFFFFFFFu ? 0.0f : float((group * 2654435761u) >> 8 & 0xFFFFu) / 65535.0f;
            rgb[0] = 0.64f + 0.16f * (hash - 0.5f);
            rgb[1] = 0.39f + 0.20f * (hash - 0.5f);
            rgb[2] = 0.22f + 0.16f * (hash - 0.5f);
        }
        else
        {
            rgb[0] = 0.12f;
            rgb[1] = 0.24f;
            rgb[2] = 0.55f;
        }
        for (int k = 0; k < 3; ++k) instance.colour[k] = rgb[k];
        instance.colour[3] = 1;
    }
    std::memcpy([s.instances[slot] contents], s.scratch.data(), s.scratch.size() * sizeof(Instance));

    // Light and shadow frustum follow the fixed scene bounds, not the frame, so
    // shadows stay stable while bodies move through them.
    float centre[3];
    float extent = 0;
    for (int k = 0; k < 3; ++k)
    {
        centre[k] = (s.bounds.minimum[k] + s.bounds.maximum[k]) * 0.5f;
        extent = std::max(extent, s.bounds.maximum[k] - s.bounds.minimum[k]);
    }
    const float radius = std::max(extent, 1.0f) * 0.9f + 2.0f;
    float lightDirection[3]{-0.45f, -0.82f, 0.35f};
    normalise(lightDirection);
    const float lightEye[3]{centre[0] - lightDirection[0] * radius * 2.0f,
                            centre[1] - lightDirection[1] * radius * 2.0f,
                            centre[2] - lightDirection[2] * radius * 2.0f};

    Uniforms uniforms{};
    float view[16], projection[16], lightView[16], lightProjection[16];
    const float aspect = float(s.options.width) / float(std::max<std::uint32_t>(s.options.height, 1));
    const float target3[3]{s.camera.eye[0] + s.camera.direction[0], s.camera.eye[1] + s.camera.direction[1],
                           s.camera.eye[2] + s.camera.direction[2]};
    lookAt(s.camera.eye, target3, view);
    perspective(s.camera.fovDegrees * 3.14159265f / 180.0f, aspect, 0.1f, radius * 12.0f + 50.0f, projection);
    multiply(projection, view, uniforms.viewProjection);

    lookAt(lightEye, centre, lightView);
    orthographic(radius, radius, 0.1f, radius * 6.0f, lightProjection);
    multiply(lightProjection, lightView, uniforms.lightViewProjection);

    for (int k = 0; k < 3; ++k)
    {
        uniforms.lightDirection[k] = lightDirection[k];
        uniforms.cameraPosition[k] = s.camera.eye[k];
    }
    uniforms.groundColour[0] = 0.30f;
    uniforms.groundColour[1] = 0.32f;
    uniforms.groundColour[2] = 0.35f;
    uniforms.shadowTexel = 1.0f / float(s.options.shadowResolution);
    std::memcpy([s.uniforms[slot] contents], &uniforms, sizeof(uniforms));

    id<MTLCommandBuffer> commands = [s.queue commandBuffer];

    MTLRenderPassDescriptor* shadowPass = [MTLRenderPassDescriptor renderPassDescriptor];
    shadowPass.depthAttachment.texture = s.shadowMap;
    shadowPass.depthAttachment.loadAction = MTLLoadActionClear;
    shadowPass.depthAttachment.storeAction = MTLStoreActionStore;
    shadowPass.depthAttachment.clearDepth = 1.0;
    id<MTLRenderCommandEncoder> shadow = [commands renderCommandEncoderWithDescriptor:shadowPass];
    [shadow setRenderPipelineState:s.shadowPipeline];
    [shadow setDepthStencilState:s.depthState];
    [shadow setCullMode:MTLCullModeNone];
    [shadow setVertexBuffer:s.vertexBuffer offset:0 atIndex:0];
    [shadow setVertexBuffer:s.instances[slot] offset:0 atIndex:1];
    [shadow setVertexBuffer:s.uniforms[slot] offset:0 atIndex:2];
    if (boxes > 0)
    {
        [shadow drawPrimitives:MTLPrimitiveTypeTriangle
                   vertexStart:s.box.first
                   vertexCount:s.box.count
                 instanceCount:boxes];
    }
    if (spheres > 0)
    {
        [shadow setVertexBufferOffset:s.boxCount * sizeof(Instance) atIndex:1];
        [shadow drawPrimitives:MTLPrimitiveTypeTriangle
                   vertexStart:s.sphere.first
                   vertexCount:s.sphere.count
                 instanceCount:spheres];
    }
    [shadow endEncoding];

    MTLRenderPassDescriptor* pass = [MTLRenderPassDescriptor renderPassDescriptor];
    pass.colorAttachments[0].texture = s.colourTarget;
    pass.colorAttachments[0].loadAction = MTLLoadActionClear;
    pass.colorAttachments[0].clearColor = MTLClearColorMake(0.052, 0.060, 0.075, 1.0);
    if (s.options.samples > 1)
    {
        pass.colorAttachments[0].storeAction = MTLStoreActionMultisampleResolve;
        pass.colorAttachments[0].resolveTexture = target;
    }
    else
    {
        pass.colorAttachments[0].texture = target;
        pass.colorAttachments[0].storeAction = MTLStoreActionStore;
    }
    pass.depthAttachment.texture = s.depthTarget;
    pass.depthAttachment.loadAction = MTLLoadActionClear;
    pass.depthAttachment.storeAction = MTLStoreActionDontCare;
    pass.depthAttachment.clearDepth = 1.0;

    id<MTLRenderCommandEncoder> scene = [commands renderCommandEncoderWithDescriptor:pass];
    [scene setDepthStencilState:s.depthState];
    [scene setCullMode:MTLCullModeBack];
    [scene setFrontFacingWinding:MTLWindingCounterClockwise];
    [scene setFragmentTexture:s.shadowMap atIndex:0];
    [scene setFragmentSamplerState:s.shadowSampler atIndex:0];
    [scene setFragmentBuffer:s.uniforms[slot] offset:0 atIndex:2];

    [scene setRenderPipelineState:s.groundPipeline];
    [scene setVertexBuffer:s.groundBuffer offset:0 atIndex:0];
    [scene setVertexBuffer:s.uniforms[slot] offset:0 atIndex:2];
    [scene drawPrimitives:MTLPrimitiveTypeTriangle vertexStart:0 vertexCount:6];

    [scene setRenderPipelineState:s.bodyPipeline];
    [scene setVertexBuffer:s.vertexBuffer offset:0 atIndex:0];
    [scene setVertexBuffer:s.instances[slot] offset:0 atIndex:1];
    if (boxes > 0)
    {
        [scene drawPrimitives:MTLPrimitiveTypeTriangle
                  vertexStart:s.box.first
                  vertexCount:s.box.count
                instanceCount:boxes];
    }
    if (spheres > 0)
    {
        [scene setVertexBufferOffset:s.boxCount * sizeof(Instance) atIndex:1];
        [scene drawPrimitives:MTLPrimitiveTypeTriangle
                  vertexStart:s.sphere.first
                  vertexCount:s.sphere.count
                instanceCount:spheres];
    }
    [scene endEncoding];

    __block dispatch_semaphore_t signal = s.inFlight;
    [commands addCompletedHandler:^(id<MTLCommandBuffer>) {
        dispatch_semaphore_signal(signal);
    }];
    if (present != nil)
    {
        // Presenting inside the same buffer keeps the window in step with the
        // frame that was just drawn, with no extra synchronisation.
        [commands presentDrawable:present];
    }
    [commands commit];
    return commands;
}

} // namespace wall_render
