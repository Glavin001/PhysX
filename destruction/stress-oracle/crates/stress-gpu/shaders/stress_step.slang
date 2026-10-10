// One explicit substep of the stress solver (stress-ref `ReferenceSolver::substep`,
// explicit mode, intact bonds, anchored clusters), in two dispatches:
//
//   bond_forces      per bond: generalised deformation d and rate from the chunks'
//                    hidden displacements (u, theta) and velocities (v, w) at the start
//                    of the substep, force q = K d + C rate (local frame t1, t2, n),
//                    and the loads it puts on both chunks (body frame).
//   chunk_integrate  per chunk: the loads of its bonds gathered in a fixed order (CSR,
//                    no atomics), plus its external load, then the central-difference
//                    update (velocities at half steps) by support kind.
//
// Mirrors bond.rs (`kinematics`, `chunk_loads`), joint.rs (intact force and dashpots)
// and solver.rs (`integrate_cluster`) in f32.

static const uint SUPPORT_NONE = 0;
static const uint SUPPORT_FIXED = 1;
static const uint SUPPORT_PINNED = 2;

struct StepParams
{
    uint chunk_count;
    uint bond_count;
    float dt;
    uint pad;
};

// Static data of a bond (body frame of its cluster).
struct Bond
{
    uint4 chunks;    // x: a, y: b
    float4 t1;       // local frame: tangents and normal
    float4 t2;
    float4 normal;
    float4 ra;       // centroid - centre of a
    float4 rb;       // centroid - centre of b
    float4 k_lin;    // stiffness: ks, ks, kn
    float4 k_ang;    // kb_t1, kb_t2, kt
    float4 c_lin;    // dashpots, same components
    float4 c_ang;
    float4 section;  // area, s_t1, s_t2 (section moduli)
};

// Static data of a chunk (body frame of its cluster).
struct Chunk
{
    float4 inv_inertia0; // rows of the inverse rotational inertia
    float4 inv_inertia1;
    float4 inv_inertia2;
    float4 force;        // external force (gravity, body frame); w: 1 / (mass * inertia scale)
    float4 moment;       // external moment (body frame); w: 1 / inertia scale
    uint4 support;       // x: SUPPORT_*
};

[[vk::binding(0, 0)]] ConstantBuffer<StepParams> params;
[[vk::binding(1, 0)]] StructuredBuffer<Bond> bonds;
[[vk::binding(2, 0)]] StructuredBuffer<Chunk> chunks;
[[vk::binding(3, 0)]] StructuredBuffer<uint> chunk_bond_start; // chunk_count + 1 offsets
[[vk::binding(4, 0)]] StructuredBuffer<uint> chunk_bonds;      // 2 * bond + side (0: a, 1: b)
// Hidden state, 4 per chunk: u (w: largest bond stress, Pa), theta, v, w.
[[vk::binding(5, 0)]] RWStructuredBuffer<float4> state;
// 4 per bond: fa (w: peak normal stress, Pa), ma, fb, mb.
[[vk::binding(6, 0)]] RWStructuredBuffer<float4> bond_loads;

static const uint U = 0;
static const uint THETA = 1;
static const uint V = 2;
static const uint W = 3;

float3 get(uint chunk, uint field)
{
    return state[4 * chunk + field].xyz;
}

float3 to_local(Bond b, float3 x)
{
    return float3(dot(x, b.t1.xyz), dot(x, b.t2.xyz), dot(x, b.normal.xyz));
}

float3 to_body(Bond b, float3 l)
{
    return b.t1.xyz * l.x + b.t2.xyz * l.y + b.normal.xyz * l.z;
}

[shader("compute")]
[numthreads(64, 1, 1)]
void bond_forces(uint3 id: SV_DispatchThreadID)
{
    uint i = id.x;
    if (i >= params.bond_count)
        return;
    Bond b = bonds[i];
    uint ca = b.chunks.x;
    uint cb = b.chunks.y;
    float3 ra = b.ra.xyz;
    float3 rb = b.rb.xyz;
    // Kinematics: relative displacement of the bond centroid and relative rotation.
    float3 delta = (get(cb, U) + cross(get(cb, THETA), rb)) - (get(ca, U) + cross(get(ca, THETA), ra));
    float3 d_lin = to_local(b, delta);
    float3 d_ang = to_local(b, get(cb, THETA) - get(ca, THETA));
    float3 rate_delta = (get(cb, V) + cross(get(cb, W), rb)) - (get(ca, V) + cross(get(ca, W), ra));
    float3 r_lin = to_local(b, rate_delta);
    float3 r_ang = to_local(b, get(cb, W) - get(ca, W));
    // Intact joint: elastic force plus stiffness-proportional dashpots.
    float3 q_lin = b.k_lin.xyz * d_lin + b.c_lin.xyz * r_lin;
    float3 q_ang = b.k_ang.xyz * d_ang + b.c_ang.xyz * r_ang;
    // Peak normal stress of the elastic part: axial plus both bending moments.
    float3 e_lin = b.k_lin.xyz * d_lin;
    float3 e_ang = b.k_ang.xyz * d_ang;
    float stress = abs(e_lin.z) / b.section.x + abs(e_ang.x) / b.section.y + abs(e_ang.y) / b.section.z;
    // Loads on the chunks (body frame): equal and opposite, moments about each centre.
    float3 f = to_body(b, q_lin);
    float3 m = to_body(b, q_ang);
    bond_loads[4 * i + 0] = float4(f, stress);
    bond_loads[4 * i + 1] = float4(m + cross(ra, f), 0.0);
    bond_loads[4 * i + 2] = float4(-f, 0.0);
    bond_loads[4 * i + 3] = float4(-m + cross(rb, -f), 0.0);
}

[shader("compute")]
[numthreads(64, 1, 1)]
void chunk_integrate(uint3 id: SV_DispatchThreadID)
{
    uint c = id.x;
    if (c >= params.chunk_count)
        return;
    Chunk ch = chunks[c];
    // Internal loads summed from zero in bond order, then the external load added,
    // as solver.rs does (`f_ext + fi`).
    float3 fi = float3(0.0);
    float3 mi = float3(0.0);
    float stress = 0.0;
    for (uint k = chunk_bond_start[c]; k < chunk_bond_start[c + 1]; k++)
    {
        uint e = chunk_bonds[k];
        uint bond = e >> 1;
        uint side = e & 1;
        fi += bond_loads[4 * bond + 2 * side + 0].xyz;
        mi += bond_loads[4 * bond + 2 * side + 1].xyz;
        stress = max(stress, bond_loads[4 * bond].w);
    }
    float3 f = ch.force.xyz + fi;
    float3 m = ch.moment.xyz + mi;
    float dt = params.dt;
    float3 alpha = float3(dot(ch.inv_inertia0.xyz, m), dot(ch.inv_inertia1.xyz, m), dot(ch.inv_inertia2.xyz, m)) * ch.moment.w;
    float3 uc = get(c, U);
    float3 tc = get(c, THETA);
    float3 vc = get(c, V);
    float3 wc = get(c, W);
    uint support = ch.support.x;
    if (support == SUPPORT_FIXED)
    {
        vc = float3(0.0);
        wc = float3(0.0);
    }
    else
    {
        wc += alpha * dt;
        tc += wc * dt;
        if (support == SUPPORT_PINNED)
        {
            vc = float3(0.0);
        }
        else
        {
            vc += f * (dt * ch.force.w);
            uc += vc * dt;
        }
    }
    state[4 * c + U] = float4(uc, stress);
    state[4 * c + THETA] = float4(tc, 0.0);
    state[4 * c + V] = float4(vc, 0.0);
    state[4 * c + W] = float4(wc, 0.0);
}
