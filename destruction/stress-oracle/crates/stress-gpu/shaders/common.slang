// Shared by the stress kernels: chunk and island data, rigid-body math in the
// reference's conventions (stress-ref math.rs), compensated arithmetic.

module common;

public static const uint SUPPORT_NONE = 0;
public static const uint SUPPORT_FIXED = 1;
public static const uint SUPPORT_PINNED = 2;

public static const uint ISLAND_ANCHORED = 1;
public static const uint ISLAND_DRIVEN = 2;
// Island status bits.
public static const uint ISLAND_HALTED = 1;
// Island flag: the island takes part in the per-substep contact pipeline.
public static const uint ISLAND_CONTACT = 4;

// Static data of a chunk (body frame of its cluster).
public struct ChunkStatic
{
    public float4 center;     // w: mass
    public float4 inertia0;   // rows of the inertia
    public float4 inertia1;
    public float4 inertia2;
    public float4 inv0;       // rows of the inverse inertia
    public float4 inv1;
    public float4 inv2;
    public float4 scale;      // inertia scale mu, 1 / (m mu), 1 / mu, -
    public uint4 info;        // support, island, structure, chunk
    public uint4 load_range;  // load terms [x, y) in `loads`
};

// An island (cluster): static mass data and dynamic rigid state.
public struct Island
{
    public uint4 range;       // chunks [x, y), bonds [z, w)
    public uint4 info;        // flags (ISLAND_*), substeps to run, status (ISLAND_HALTED), absolute substep at start
    public float4 com;        // body frame centre of mass; w: mass
    public float4 inertia0;   // rows of the body inertia about com
    public float4 inertia1;
    public float4 inertia2;
    public float4 inv0;       // rows of its inverse
    public float4 inv1;
    public float4 inv2;
    public float4 wcom;       // drift-removal weights (deformation inertia): com, w mass
    public float4 winv0;      // rows of the inverse weighted inertia
    public float4 winv1;
    public float4 winv2;
    public float4 rotation;   // quaternion (x, y, z, w)
    public float4 position;   // world, compensated with position_err
    public float4 position_err;
    public float4 velocity;   // com velocity, compensated with velocity_err
    public float4 velocity_err;
    public float4 angular_velocity;
    public uint4 done;        // x: substeps run in the last dispatch
    public uint4 probes;      // probe items [x, y) in `loads`
    public float4 energy;     // external work (compensated: x + y)
};

// ------------------------------------------------------------------ rigid math

public struct Quat
{
    public float w;
    public float x;
    public float y;
    public float z;
};

public Quat quat_of(float4 q)
{
    Quat r;
    r.x = q.x;
    r.y = q.y;
    r.z = q.z;
    r.w = q.w;
    return r;
}

public float4 quat_vec(Quat q)
{
    return float4(q.x, q.y, q.z, q.w);
}

public float3 rotate(Quat q, float3 v)
{
    float3 qv = float3(q.x, q.y, q.z);
    float3 t = cross(qv, v) * 2.0;
    return v + t * q.w + cross(qv, t);
}

public float3 inverse_rotate(Quat q, float3 v)
{
    Quat c;
    c.w = q.w;
    c.x = -q.x;
    c.y = -q.y;
    c.z = -q.z;
    return rotate(c, v);
}

public Quat quat_mul(Quat a, Quat o)
{
    Quat r;
    r.w = a.w * o.w - a.x * o.x - a.y * o.y - a.z * o.z;
    r.x = a.w * o.x + a.x * o.w + a.y * o.z - a.z * o.y;
    r.y = a.w * o.y - a.x * o.z + a.y * o.w + a.z * o.x;
    r.z = a.w * o.z + a.x * o.y - a.y * o.x + a.z * o.w;
    return r;
}

public Quat normalized(Quat q)
{
    float n = sqrt(q.w * q.w + q.x * q.x + q.y * q.y + q.z * q.z);
    Quat r;
    r.w = q.w / n;
    r.x = q.x / n;
    r.y = q.y / n;
    r.z = q.z / n;
    return r;
}

// Vec3::normalized: zero for a (near-)zero input.
public float3 safe_normalize(float3 v)
{
    float n = length(v);
    return n > 1e-30 ? v / n : float3(0.0);
}

public Quat from_axis_angle(float3 axis, float angle)
{
    float3 a = safe_normalize(axis);
    float s = sin(0.5 * angle);
    float c = cos(0.5 * angle);
    Quat q;
    q.w = c;
    q.x = a.x * s;
    q.y = a.y * s;
    q.z = a.z * s;
    return q;
}

public Quat integrate_rotation(Quat q, float3 omega, float dt)
{
    float angle = length(omega) * dt;
    if (angle < 1e-30)
        return q;
    return normalized(quat_mul(from_axis_angle(omega, angle), q));
}

public float3 rows_mul(float4 r0, float4 r1, float4 r2, float3 v)
{
    return float3(dot(r0.xyz, v), dot(r1.xyz, v), dot(r2.xyz, v));
}

// (R M R^T) v for a body-frame matrix M given by rows.
public float3 world_mul(Quat q, float4 r0, float4 r1, float4 r2, float3 v)
{
    return rotate(q, rows_mul(r0, r1, r2, inverse_rotate(q, v)));
}

// Compensated accumulation: (sum, err) += x (Neumaier).
public void comp_add(inout float3 sum, inout float3 err, float3 x)
{
    float3 t = sum + x;
    float3 big = select(abs(sum) >= abs(x), sum, x);
    float3 small = select(abs(sum) >= abs(x), x, sum);
    err += (big - t) + small;
    sum = t;
}

public void comp_add1(inout float sum, inout float err, float x)
{
    float t = sum + x;
    if (abs(sum) >= abs(x))
        err += (sum - t) + x;
    else
        err += (x - t) + sum;
    sum = t;
}
