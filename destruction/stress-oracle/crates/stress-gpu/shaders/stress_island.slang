// The stress solver's explicit substep with the full model (stress-ref
// `ReferenceSolver::substep`, explicit mode): one threadgroup per island (cluster)
// runs every substep of a segment in one dispatch, in the reference's order:
//
//   1. rigid acceleration of a free cluster from its net load (group reductions);
//   2. bond phase: kinematics, the joint law (joint.slang) with its history, secant
//      dashpots, loads on both chunks, energies (compensated sums) and events;
//   3. chunk phase: fixed-order gather of bond loads (CSR, no atomics), frame loads
//      (gravity, rigid-motion inertial loads, Coriolis and gyroscopic terms) and the
//      central-difference update by support kind;
//   4. rigid integration of the cluster (angular momentum, exact rotation);
//   5. drift removal: the best-fit rigid motion of the hidden field folded into the
//      cluster's pose and velocity (group reductions).
//
// An island stops after a substep in which a bond disconnected, so the host can split
// it before the next one (as the reference splits at the end of that substep). Cluster
// position and velocity are kept as compensated pairs (value + rounding error): their
// per-substep increments are far below f32 resolution at world scale.

import joint;
import common;

static const uint THREADS = 256;

struct Params
{
    float4 gravity;     // world, w unused
    float dt;
    uint fracture;      // 0/1
    uint rigid_motion_loads; // 0/1
    uint step_start;    // absolute substep count when the host's step began
    float t_hi;         // time when the host's step began (compensated pair)
    float t_lo;
    uint probe_base;    // first float4 of the probe outputs in `scratch`
    uint probe_stride;  // floats per probe item (multiple of 4)
    uint max_steps;     // substeps per island in this dispatch at most
    uint contact_mode;  // 0: islands outside the contact pipeline; 1: contact islands
    uint contact_base;  // float4 index of the chunk contact loads in `contact_out`
    uint halt_index;    // sentinel island (batch control, see contact.slang)
};

// Load terms (in `loads`, 5 float4 each).
static const uint LOAD_WORLD_FORCE = 0;   // world-fixed direction, lever arm in the body frame
static const uint LOAD_FACE = 1;          // body-fixed outward normal, -p(t) * area, lever arm
static const uint LOAD_REPLACEMENT = 2;   // body-frame force and moment ramping to zero

// Time functions (stress-ref `TimeFunction`, blast `FaceBlast::pressure`, replacement ramp).
static const uint FN_CONSTANT = 0;
static const uint FN_RAMP = 1;
static const uint FN_HALF_SINE = 2;
static const uint FN_FRIEDLANDER = 3;
static const uint FN_TABLE = 4;
static const uint FN_BLAST = 5;
static const uint FN_REPLACEMENT = 6;

// Probe items (in `loads`, 4 float4 each).
static const uint PROBE_DISPLACEMENT = 0;
static const uint PROBE_VELOCITY = 1;
static const uint PROBE_SECTION_BOND = 2;
static const uint PROBE_REACTION = 3;

struct MaterialTable
{
    JointMaterial m[64];
};

// Static data of a bond (body frame of its cluster).
struct BondStatic
{
    float4 t1;
    float4 t2;
    float4 normal;
    float4 ra;       // centroid - centre of a
    float4 rb;       // centroid - centre of b
    float4 centroid; // body frame
    float4 c_lin;    // dashpots
    float4 c_ang;
    JointBond law;   // ids: x material, y chunk a, z chunk b, w island
};

// Dynamic data of a bond.
struct BondDyn
{
    JointState js;
    float4 force_lin;  // last force incl. dashpots; w: stored energy
    float4 force_ang;  // w: largest utilization seen
    float4 sums;       // dissipated, overshoot, damped (compensated with `comps`)
    float4 comps;
    uint4 events;      // absolute substep of: crack, creak, break (0: none); w: mode at crack
};

[[vk::binding(0, 0)]] ConstantBuffer<Params> params;
[[vk::binding(1, 0)]] ConstantBuffer<MaterialTable> materials;
[[vk::binding(2, 0)]] StructuredBuffer<BondStatic> bonds;
[[vk::binding(3, 0)]] StructuredBuffer<ChunkStatic> chunks;
// CSR incidence: [chunk_count + 1 offsets into this buffer], then entries 2 * bond + side.
[[vk::binding(4, 0)]] StructuredBuffer<uint> csr;
// 4 per chunk: u (w: largest bond stress), theta, v, w.
[[vk::binding(5, 0)]] RWStructuredBuffer<float4> state;
[[vk::binding(6, 0)]] RWStructuredBuffer<BondDyn> bond_dyn;
// 3 per bond: f on a (w: peak normal stress), moment on a, moment on b (force on b: -f);
// then the probe outputs (from params.probe_base).
[[vk::binding(7, 0)]] RWStructuredBuffer<float4> bond_loads;
[[vk::binding(8, 0)]] RWStructuredBuffer<Island> islands;
// Load terms, table data and probe items.
[[vk::binding(9, 0)]] StructuredBuffer<float4> loads;
// Contact outputs (contact.slang): the chunk contact loads from params.contact_base.
[[vk::binding(10, 0)]] StructuredBuffer<float4> contact_out;

// ------------------------------------------------------------------ loads

// Time since a function's origin (compensated pair) at substep k of the host's step.
float time_since(float4 origin, uint k, float dt)
{
    return ((params.t_hi - origin.x) + (params.t_lo - origin.y)) + float(k) * dt;
}

float table_eval(uint offset, uint count, float tau)
{
    // Points (t - origin, value), clamped at both ends.
    float4 first = loads[offset];
    if (tau <= first.x)
        return first.y;
    for (uint i = 1; i < count; i++)
    {
        float4 b = loads[offset + i];
        if (tau <= b.x)
        {
            float4 a = loads[offset + i - 1];
            float f = (tau - a.x) / max(b.x - a.x, 1e-30);
            return a.y + f * (b.y - a.y);
        }
    }
    return loads[offset + count - 1].y;
}

// Value of a term's time function at substep k (substep start time) plus `shift`.
float eval_function(uint term, uint k, float dt, float shift)
{
    uint4 info = asuint(loads[5 * term]);
    float4 origin = loads[5 * term + 3];
    float4 p = loads[5 * term + 4];
    uint kind = info.z;
    if (kind == FN_CONSTANT)
        return origin.z;
    float tau = time_since(origin, k, dt) + shift;
    if (kind == FN_RAMP)
        return tau <= 0.0 ? 0.0 : (tau >= p.x ? p.y : p.y * tau / p.x);
    if (kind == FN_HALF_SINE)
        return (tau < 0.0 || tau > p.x) ? 0.0 : p.y * sin(3.14159265358979 * tau / p.x);
    if (kind == FN_FRIEDLANDER)
    {
        float sn = tau / p.y;
        return (sn < 0.0 || sn > 1.0) ? 0.0 : p.x * (1.0 - sn) * exp(-p.z * sn);
    }
    if (kind == FN_TABLE)
        return table_eval(info.w, asuint(p.x), tau);
    if (kind == FN_BLAST)
    {
        // FaceBlast::pressure: duration, decay, peak, stagnation; clearing time in origin.w.
        if (tau < 0.0)
            return 0.0;
        float sn = tau / p.x;
        float shape = (sn < 0.0 || sn > 1.0) ? 0.0 : (1.0 - sn) * exp(-p.y * sn);
        float clearing = origin.w;
        float relax = clearing > 0.0 ? max(1.0 - tau / clearing, 0.0) : 0.0;
        return (p.w + (p.z - p.w) * relax) * shape;
    }
    // FN_REPLACEMENT: ReplacementLoad::factor.
    if (p.x <= 0.0)
        return 0.0;
    return clamp(1.0 - tau / p.x, 0.0, 1.0);
}

// The external (non-gravity) load on chunk c at substep k, world frame (force, torque
// about the chunk centre), in the order the reference adds it.
void chunk_external(uint c, ChunkStatic ch, Quat rot, uint k, float dt, bool contact, out float3 f, out float3 t)
{
    f = float3(0.0);
    t = float3(0.0);
    for (uint term = ch.load_range.x; term < ch.load_range.y; term++)
    {
        uint4 info = asuint(loads[5 * term]);
        if (info.y == LOAD_REPLACEMENT)
            continue;
        float4 dir = loads[5 * term + 1];
        float4 arm = loads[5 * term + 2];
        float value = eval_function(term, k, dt, 0.0);
        float3 fw = info.y == LOAD_WORLD_FORCE ? dir.xyz * value : rotate(rot, dir.xyz) * (-value * dir.w);
        f += fw;
        t += cross(rotate(rot, arm.xyz), fw);
    }
    if (contact)
    {
        // Contacts, added after the scripted loads (world.rs `apply_contacts`).
        f += contact_out[params.contact_base + 2 * c].xyz;
        t += contact_out[params.contact_base + 2 * c + 1].xyz;
    }
}

// ------------------------------------------------------------------ group reductions

groupshared float4 g_red_a[THREADS];
groupshared float4 g_red_b[THREADS];

// Sums of two vectors over the group (fixed tree order: deterministic).
void group_sum2(uint tid, inout float3 a, inout float3 b)
{
    g_red_a[tid] = float4(a, 0.0);
    g_red_b[tid] = float4(b, 0.0);
    GroupMemoryBarrierWithGroupSync();
    for (uint s = THREADS / 2; s > 0; s >>= 1)
    {
        if (tid < s)
        {
            g_red_a[tid] += g_red_a[tid + s];
            g_red_b[tid] += g_red_b[tid + s];
        }
        GroupMemoryBarrierWithGroupSync();
    }
    a = g_red_a[0].xyz;
    b = g_red_b[0].xyz;
    GroupMemoryBarrierWithGroupSync();
}

// ------------------------------------------------------------------ phases

groupshared uint g_halt;
groupshared uint g_run;

float3 to_local(BondStatic b, float3 x)
{
    return float3(dot(x, b.t1.xyz), dot(x, b.t2.xyz), dot(x, b.normal.xyz));
}

float3 to_body(BondStatic b, float3 l)
{
    return b.t1.xyz * l.x + b.t2.xyz * l.y + b.normal.xyz * l.z;
}

void bond_update(uint i, float dt, bool fracture, uint abs_step)
{
    BondStatic b = bonds[i];
    BondDyn bd = bond_dyn[i];
    uint ca = b.law.ids.y;
    uint cb = b.law.ids.z;
    float3 ra = b.ra.xyz;
    float3 rb = b.rb.xyz;
    float3 ua = state[4 * ca].xyz, ta = state[4 * ca + 1].xyz, va = state[4 * ca + 2].xyz, wa = state[4 * ca + 3].xyz;
    float3 ub = state[4 * cb].xyz, tb = state[4 * cb + 1].xyz, vb = state[4 * cb + 2].xyz, wb = state[4 * cb + 3].xyz;
    float3 d_lin = to_local(b, (ub + cross(tb, rb)) - (ua + cross(ta, ra)));
    float3 d_ang = to_local(b, tb - ta);
    float3 r_lin = to_local(b, (vb + cross(wb, rb)) - (va + cross(wa, ra)));
    float3 r_ang = to_local(b, wb - wa);
    JointMaterial mat = materials.m[b.law.ids.x];
    JointState previous = bd.js;
    JointResponse resp = joint_evaluate(mat, b.law, previous, d_lin, d_ang, dt, fracture);
    float3 f_lin;
    float3 f_ang;
    secant_factors(b.law, resp.state, d_lin, f_lin, f_ang);
    float3 qd_lin = r_lin * b.c_lin.xyz * f_lin;
    float3 qd_ang = r_ang * b.c_ang.xyz * f_ang;
    float3 q_lin = resp.force_lin + qd_lin;
    float3 q_ang = resp.force_ang + qd_ang;
    float damped = (dot(qd_lin, r_lin) + dot(qd_ang, r_ang)) * dt;

    // Loads on the chunks (body frame).
    float3 f = to_body(b, q_lin);
    float3 m = to_body(b, q_ang);
    Measures em = resp.measures;
    float peak = max(em.tension, em.compression);
    bond_loads[3 * i + 0] = float4(f, peak);
    bond_loads[3 * i + 1] = float4(m + cross(ra, f), 0.0);
    bond_loads[3 * i + 2] = float4(-m + cross(rb, -f), 0.0);

    // History, energies, events.
    comp_add1(bd.sums.x, bd.comps.x, resp.dissipated);
    comp_add1(bd.sums.y, bd.comps.y, resp.overshoot);
    comp_add1(bd.sums.z, bd.comps.z, damped);
    bd.force_lin = float4(q_lin, resp.stored);
    bd.force_ang = float4(q_ang, max(bd.force_ang.w, resp.state.utilization));
    if (!is_damaged(previous) && is_damaged(resp.state) && bd.events.x == 0)
    {
        bd.events.x = abs_step;
        bd.events.w = resp.state.mode;
    }
    if (bd.events.y == 0 && fatigue_factor(mat, previous.fatigue) > 0.99 && fatigue_factor(mat, resp.state.fatigue) <= 0.99)
        bd.events.y = abs_step;
    if (resp.disconnected)
    {
        bd.events.z = abs_step;
        g_halt = 1;
    }
    bd.js = resp.state;
    bond_dyn[i] = bd;
}

// Rigid-frame state every thread holds identically (computed redundantly, no broadcast).
struct Rigid
{
    Quat rot;
    float3 pos;
    float3 pos_err;
    float3 vel;
    float3 vel_err;
    float3 w;
    float3 a;
    float3 alpha;
};

void chunk_update(uint c, Island isl, Rigid rg, float dt, bool rml, uint k, inout float work, inout float work_err)
{
    ChunkStatic ch = chunks[c];
    float3 fi = float3(0.0);
    float3 mi = float3(0.0);
    float peak = 0.0;
    for (uint k = csr[c]; k < csr[c + 1]; k++)
    {
        uint e = csr[k];
        uint bond = e >> 1;
        float4 fa = bond_loads[3 * bond];
        if ((e & 1) == 0)
        {
            fi += fa.xyz;
            mi += bond_loads[3 * bond + 1].xyz;
        }
        else
        {
            fi += -fa.xyz;
            mi += bond_loads[3 * bond + 2].xyz;
        }
        peak = max(peak, fa.w);
    }
    float3 u = state[4 * c].xyz;
    float3 th = state[4 * c + 1].xyz;
    float3 v = state[4 * c + 2].xyz;
    float3 w = state[4 * c + 3].xyz;
    float mass = ch.center.w;

    // Frame loads (solver.rs `frame_loads`): external loads in the body frame minus the
    // inertial loads of the cluster's rigid motion.
    float3 r_world = rotate(rg.rot, ch.center.xyz + u - isl.com.xyz);
    float3 f_load;
    float3 t_load;
    chunk_external(c, ch, rg.rot, k, dt, (isl.info.x & ISLAND_CONTACT) != 0, f_load, t_load);
    float3 f_world = f_load + params.gravity.xyz * mass;
    float3 t_world = t_load;
    if (rml)
    {
        f_world -= (rg.a + cross(rg.alpha, r_world) + cross(rg.w, cross(rg.w, r_world))) * mass;
        float3 iw_alpha = world_mul(rg.rot, ch.inertia0, ch.inertia1, ch.inertia2, rg.alpha);
        float3 iw_w = world_mul(rg.rot, ch.inertia0, ch.inertia1, ch.inertia2, rg.w);
        t_world -= iw_alpha + cross(rg.w, iw_w);
    }
    float3 f_ext = inverse_rotate(rg.rot, f_world);
    float3 m_ext = inverse_rotate(rg.rot, t_world);
    if (rml)
    {
        float3 wb = inverse_rotate(rg.rot, rg.w);
        f_ext -= cross(wb, v) * (2.0 * mass);
        float3 i_w = rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, w);
        float3 i_wb = rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, wb);
        m_ext -= cross(wb, i_w) + cross(w, i_wb) + cross(w, i_w);
    }
    // Replacement loads (body frame) at the end of the substep (solver.rs `frame_loads`
    // is evaluated at t + dt).
    for (uint term = ch.load_range.x; term < ch.load_range.y; term++)
    {
        if (asuint(loads[5 * term]).y != LOAD_REPLACEMENT)
            continue;
        float kf = eval_function(term, k, dt, dt);
        f_ext += loads[5 * term + 1].xyz * kf;
        m_ext += loads[5 * term + 2].xyz * kf;
    }

    // Central differences by support kind (solver.rs `integrate_cluster`).
    float3 f = f_ext + fi;
    float3 m = m_ext + mi;
    uint support = ch.info.x;
    float3 reaction = float3(state[4 * c + 1].w, state[4 * c + 2].w, state[4 * c + 3].w);
    if (support == SUPPORT_FIXED)
    {
        reaction = -(f_ext + fi);
        v = float3(0.0);
        w = float3(0.0);
    }
    else
    {
        w += rows_mul(ch.inv0, ch.inv1, ch.inv2, m) * (dt * ch.scale.z);
        th += w * dt;
        if (support == SUPPORT_PINNED)
        {
            reaction = -(f_ext + fi);
            v = float3(0.0);
        }
        else
        {
            v += f * (dt * ch.scale.y);
            u += v * dt;
        }
    }
    // Reaction force (body frame) in the w lanes of theta, v and w.
    state[4 * c] = float4(u, peak);
    state[4 * c + 1] = float4(th, reaction.x);
    state[4 * c + 2] = float4(v, reaction.y);
    state[4 * c + 3] = float4(w, reaction.z);
    // Work of the external (non-gravity) loads at the chunk's world velocity.
    float3 r_new = rotate(rg.rot, ch.center.xyz + u - isl.com.xyz);
    float3 v_world = (rg.vel + rg.vel_err) + cross(rg.w, r_new) + rotate(rg.rot, v);
    float3 w_world = rg.w + rotate(rg.rot, w);
    comp_add1(work, work_err, (dot(f_load, v_world) + dot(t_load, w_world)) * dt);
}

void write_probe(uint slot, uint k, float value)
{
    uint index = params.probe_base * 4 + slot * params.probe_stride + k;
    float4 v = bond_loads[index / 4];
    v[index % 4] = value;
    bond_loads[index / 4] = v;
}

void record_probes(Island isl, Rigid rg, uint k)
{
    // isl.probes: absolute float4 range of this island's items (4 float4 each).
    for (uint at = isl.probes.x; at < isl.probes.y; at += 4)
    {
        uint4 info = asuint(loads[at]);
        float4 a = loads[at + 1];
        float4 b = loads[at + 2];
        float4 c4 = loads[at + 3];
        uint kind = info.x;
        uint index = info.y;
        float value = 0.0;
        if (kind == PROBE_DISPLACEMENT)
        {
            ChunkStatic ch = chunks[index];
            float3 x = ((rg.pos - b.xyz) + (rg.pos_err - c4.xyz)) + rotate(rg.rot, ch.center.xyz + state[4 * index].xyz);
            value = dot(x, a.xyz);
        }
        else if (kind == PROBE_VELOCITY)
        {
            ChunkStatic ch = chunks[index];
            float3 r = rotate(rg.rot, ch.center.xyz + state[4 * index].xyz - isl.com.xyz);
            float3 v = (rg.vel + rg.vel_err) + cross(rg.w, r) + rotate(rg.rot, state[4 * index + 2].xyz);
            value = dot(v, a.xyz);
        }
        else if (kind == PROBE_SECTION_BOND)
        {
            float3 f = bond_loads[3 * index].xyz;
            float3 mc = info.z == 0 ? bond_loads[3 * index + 1].xyz : bond_loads[3 * index + 2].xyz;
            float3 fc = info.z == 0 ? f : -f;
            value = dot(fc, a.xyz) + dot(mc, b.xyz);
        }
        else
        {
            float3 reaction = float3(state[4 * index + 1].w, state[4 * index + 2].w, state[4 * index + 3].w);
            value = dot(rotate(rg.rot, reaction), a.xyz);
        }
        write_probe(info.w, k, value);
    }
}

[shader("compute")]
[numthreads(256, 1, 1)]
void island_frame(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    Island isl = islands[group.x];
    bool anchored = (isl.info.x & ISLAND_ANCHORED) != 0;
    bool driven = (isl.info.x & ISLAND_DRIVEN) != 0;
    bool free_motion = !anchored && !driven;
    bool contact_island = (isl.info.x & ISLAND_CONTACT) != 0;
    // Batch control (contact.slang): read once, uniformly for the whole group.
    if (tid == 0)
    {
        Island sentinel = islands[params.halt_index];
        uint run = 1;
        if (contact_island != (params.contact_mode == 1))
            run = 0;
        if (contact_island && ((sentinel.info.z & 1) != 0 || (sentinel.info.y != 0 && sentinel.info.y <= isl.info.w)))
            run = 0;
        g_run = run;
    }
    GroupMemoryBarrierWithGroupSync();
    uint steps = ((isl.info.z & ISLAND_HALTED) != 0 || g_run == 0) ? 0 : min(isl.info.y, params.max_steps);
    float dt = params.dt;
    bool fracture = params.fracture != 0;
    bool rml = params.rigid_motion_loads != 0;
    float3 g = params.gravity.xyz;
    float mass_total = isl.com.w;

    Rigid rg;
    rg.rot = quat_of(isl.rotation);
    rg.pos = isl.position.xyz;
    rg.pos_err = isl.position_err.xyz;
    rg.vel = isl.velocity.xyz;
    rg.vel_err = isl.velocity_err.xyz;
    rg.w = isl.angular_velocity.xyz;
    rg.a = float3(0.0);
    rg.alpha = float3(0.0);

    if (tid == 0)
        g_halt = 0;
    GroupMemoryBarrierWithGroupSync();
    uint done = 0;
    float work = 0.0;
    float work_err = 0.0;
    for (uint s = 0; s < steps; s++)
    {
        uint abs_step = isl.info.w + s + 1;
        uint k = abs_step - 1 - params.step_start; // substeps since the host's step began
        // 1. Rigid acceleration of a free cluster (solver.rs `rigid_acceleration`).
        if (!anchored)
        {
            float3 f = float3(0.0);
            float3 t = float3(0.0);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
            {
                ChunkStatic ch = chunks[c];
                float3 fl;
                float3 tl;
                chunk_external(c, ch, rg.rot, k, dt, contact_island, fl, tl);
                float3 fc = fl + g * ch.center.w;
                float3 r = rotate(rg.rot, ch.center.xyz + state[4 * c].xyz - isl.com.xyz);
                f += fc;
                t += cross(r, fc) + tl;
                // Replacement loads (solver.rs `net_load`), at the substep start.
                for (uint term = ch.load_range.x; term < ch.load_range.y; term++)
                {
                    if (asuint(loads[5 * term]).y != LOAD_REPLACEMENT)
                        continue;
                    float kf = eval_function(term, k, dt, 0.0);
                    float3 fw = rotate(rg.rot, loads[5 * term + 1].xyz * kf);
                    f += fw;
                    t += cross(rotate(rg.rot, ch.center.xyz - isl.com.xyz), fw) + rotate(rg.rot, loads[5 * term + 2].xyz * kf);
                }
            }
            group_sum2(tid, f, t);
            float3 iw_w = world_mul(rg.rot, isl.inertia0, isl.inertia1, isl.inertia2, rg.w);
            rg.a = f / mass_total;
            rg.alpha = world_mul(rg.rot, isl.inv0, isl.inv1, isl.inv2, t - cross(rg.w, iw_w));
        }
        // 2. Bonds.
        for (uint i = isl.range.z + tid; i < isl.range.w; i += THREADS)
            bond_update(i, dt, fracture, abs_step);
        AllMemoryBarrierWithGroupSync();
        // 3. Chunks.
        for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
            chunk_update(c, isl, rg, dt, rml, k, work, work_err);
        AllMemoryBarrierWithGroupSync();
        if (free_motion)
        {
            // 4. Rigid integration (solver.rs `integrate_rigid`).
            float3 com_world = rg.pos + rotate(rg.rot, isl.com.xyz);
            float3 iw_w = world_mul(rg.rot, isl.inertia0, isl.inertia1, isl.inertia2, rg.w);
            float3 torque = world_mul(rg.rot, isl.inertia0, isl.inertia1, isl.inertia2, rg.alpha) + cross(rg.w, iw_w);
            float3 l = iw_w + torque * dt;
            comp_add(rg.vel, rg.vel_err, rg.a * dt);
            float3 vel = rg.vel + rg.vel_err;
            float3 w_mid = world_mul(rg.rot, isl.inv0, isl.inv1, isl.inv2, l);
            Quat rot1 = integrate_rotation(rg.rot, w_mid, dt);
            // position = (com_world + v dt) - R1 com, as a compensated update of the old position.
            float3 delta = vel * dt + (rotate(rg.rot, isl.com.xyz) - rotate(rot1, isl.com.xyz));
            comp_add(rg.pos, rg.pos_err, delta);
            rg.rot = rot1;
            rg.w = world_mul(rg.rot, isl.inv0, isl.inv1, isl.inv2, l);
        }
        if (!anchored)
        {
            // 5. Drift removal (solver.rs `remove_rigid_drift`), with deformation weights.
            float3 wcom = isl.wcom.xyz;
            float wmass = isl.wcom.w;
            float3 tu = float3(0.0);
            float3 pv = float3(0.0);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
            {
                ChunkStatic ch = chunks[c];
                float m = ch.center.w * ch.scale.x;
                tu += state[4 * c].xyz * m;
                pv += state[4 * c + 2].xyz * m;
            }
            group_sum2(tid, tu, pv);
            float3 tr = tu / wmass;
            float3 dv = pv / wmass;
            float3 lu = float3(0.0);
            float3 lv = float3(0.0);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
            {
                ChunkStatic ch = chunks[c];
                float3 r = ch.center.xyz - wcom;
                float k = ch.scale.x;
                lu += (cross(r, state[4 * c].xyz - tr) * ch.center.w + rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, state[4 * c + 1].xyz)) * k;
                lv += (cross(r, state[4 * c + 2].xyz - dv) * ch.center.w + rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, state[4 * c + 3].xyz)) * k;
            }
            group_sum2(tid, lu, lv);
            float3 phi = rows_mul(isl.winv0, isl.winv1, isl.winv2, lu);
            float3 dw = rows_mul(isl.winv0, isl.winv1, isl.winv2, lv);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
            {
                float3 r = chunks[c].center.xyz - wcom;
                state[4 * c] = float4(state[4 * c].xyz - (tr + cross(phi, r)), state[4 * c].w);
                state[4 * c + 1] = float4(state[4 * c + 1].xyz - phi, state[4 * c + 1].w);
                state[4 * c + 2] = float4(state[4 * c + 2].xyz - (dv + cross(dw, r)), state[4 * c + 2].w);
                state[4 * c + 3] = float4(state[4 * c + 3].xyz - dw, state[4 * c + 3].w);
            }
            if (!driven)
            {
                Quat rot = rg.rot;
                comp_add(rg.pos, rg.pos_err, rotate(rot, tr - cross(phi, wcom)));
                rg.rot = normalized(quat_mul(rot, from_axis_angle(phi, length(phi))));
                comp_add(rg.vel, rg.vel_err, rotate(rot, dv + cross(dw, isl.com.xyz - wcom)));
                rg.w += rotate(rot, dw);
            }
            AllMemoryBarrierWithGroupSync();
        }
        // 6. Probe values after the substep (thread 0, in item order).
        if (tid == 0 && isl.probes.y > isl.probes.x)
            record_probes(isl, rg, k);
        done = s + 1;
        if (g_halt != 0)
            break;
    }
    // Island external work: per-thread compensated sums, reduced in a fixed order.
    float3 wsum = float3(work, work_err, 0.0);
    float3 unused = float3(0.0);
    group_sum2(tid, wsum, unused);
    if (tid == 0)
    {
        isl.rotation = quat_vec(rg.rot);
        isl.position = float4(rg.pos, 0.0);
        isl.position_err = float4(rg.pos_err, 0.0);
        isl.velocity = float4(rg.vel, 0.0);
        isl.velocity_err = float4(rg.vel_err, 0.0);
        isl.angular_velocity = float4(rg.w, 0.0);
        isl.done.x = done;
        isl.info.y -= done;
        if (g_halt != 0 && contact_island)
        {
            // This substep completes in every contact island; then the batch stops.
            uint at = isl.info.w + done;
            uint previous = islands[params.halt_index].info.y;
            islands[params.halt_index].info.y = previous == 0 ? at : min(previous, at);
        }
        comp_add1(isl.energy.x, isl.energy.y, wsum.x);
        isl.energy.y += wsum.y;
        isl.info.w += done;
        if (g_halt != 0)
            isl.info.z |= ISLAND_HALTED;
        islands[group.x] = isl;
    }
}
