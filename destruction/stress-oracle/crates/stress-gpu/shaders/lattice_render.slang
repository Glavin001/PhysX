// End-to-end demo renderer: every chunk as a lit cube at its rest position plus its
// displacement, coloured by its largest spring strain. Vertices are generated from the
// vertex index (36 per cube), so no vertex buffers are bound.

struct Camera
{
    // Column-major view-projection matrix, one column per float4.
    float4 view_proj[4];
    float4 light;      // xyz: direction towards the light
    float half_size;   // cube half extent (m)
    float exaggerate;  // displacement drawn at this multiple
    float strain_max;  // strain shown at full colour
    float pad;
};

[[vk::binding(0, 0)]] ConstantBuffer<Camera> camera;
[[vk::binding(1, 0)]] StructuredBuffer<float4> rest;
[[vk::binding(2, 0)]] StructuredBuffer<float4> displacement;
[[vk::binding(3, 0)]] StructuredBuffer<float> strain;

struct VertexOut
{
    float4 position : SV_Position;
    float3 normal;
    float3 color;
};

// Cool-to-hot ramp: blue, cyan, green, yellow, red.
float3 ramp(float t)
{
    t = saturate(t);
    float3 c0 = float3(0.15, 0.25, 0.85);
    float3 c1 = float3(0.10, 0.75, 0.85);
    float3 c2 = float3(0.25, 0.80, 0.30);
    float3 c3 = float3(0.95, 0.85, 0.20);
    float3 c4 = float3(0.90, 0.20, 0.15);
    float s = t * 4.0;
    if (s < 1.0) return lerp(c0, c1, s);
    if (s < 2.0) return lerp(c1, c2, s - 1.0);
    if (s < 3.0) return lerp(c2, c3, s - 2.0);
    return lerp(c3, c4, s - 3.0);
}

[shader("vertex")]
VertexOut lattice_vs(uint vertex: SV_VertexID, uint instance: SV_InstanceID)
{
    // Face f (0..5): axis f / 2, sign from f % 2; two triangles per face.
    uint face = vertex / 6;
    uint corner = vertex % 6;
    uint axis = face / 2;
    float sign = (face % 2 == 0) ? 1.0 : -1.0;
    // Corner (s, t) of the face's quad, wound counter-clockwise seen from outside.
    float2 quad[6] = { float2(-1, -1), float2(1, -1), float2(1, 1), float2(-1, -1), float2(1, 1), float2(-1, 1) };
    float2 st = quad[corner];
    if (sign < 0.0)
        st.x = -st.x;
    float3 n = float3(0.0);
    float3 p = float3(0.0);
    if (axis == 0) { n = float3(sign, 0, 0); p = float3(sign, st.x, st.y); }
    else if (axis == 1) { n = float3(0, sign, 0); p = float3(st.y, sign, st.x); }
    else { n = float3(0, 0, sign); p = float3(st.x, st.y, sign); }

    float3 center = rest[instance].xyz + displacement[instance].xyz * camera.exaggerate;
    float3 world = center + p * camera.half_size;
    VertexOut o;
    o.position = camera.view_proj[0] * world.x + camera.view_proj[1] * world.y + camera.view_proj[2] * world.z + camera.view_proj[3];
    o.normal = n;
    o.color = ramp(strain[instance] / camera.strain_max);
    return o;
}

[shader("fragment")]
float4 lattice_fs(VertexOut input) : SV_Target
{
    float diffuse = max(dot(normalize(input.normal), normalize(camera.light.xyz)), 0.0);
    float3 c = input.color * (0.35 + 0.65 * diffuse);
    return float4(c, 1.0);
}
