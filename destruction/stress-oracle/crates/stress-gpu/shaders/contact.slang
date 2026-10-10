// Penalty contact of the standalone world (stress-ref contact.rs, world.rs
// `apply_contacts`, `penalty_force`, `pair_contact`), evaluated every substep for the
// islands that can touch something this segment, from the state at the substep start:
//
//   contact_pairs       per candidate chunk pair (chunks of different clusters): sphere
//                       and separating-axis rejection, the 14 sample points of each box
//                       inside the other, pre-existing overlap offsets (ratcheting, per
//                       pair state), penalty forces with regularised Coulomb friction;
//   contact_impactors   per impactor: sphere/box impactors against candidate chunks with
//                       the crush cap on the impactor's total force, and the impactor on
//                       the ground; the impactor's load for its integration;
//   contact_gather      per chunk: its contact loads summed in the reference's order
//                       (impactors, ground, chunk pairs) for the island kernel; travel
//                       check (a chunk leaving its candidate budget stops the batch so the
//                       host can re-plan the candidates);
//   impactor_integrate  per impactor, after the island substep (world.rs `substep`).
//
// Geometry is computed relative to a nearby point with compensated positions: world
// coordinates in f32 resolve ~1e-6 m at 10 m, too coarse for contact depths.

import common;

static const float MAX_SET_VISCOSITY = 1.0;
static const float FACE_PAIR_POINTS = 10.0;
static const float FRICTION_REGULARIZATION = 1e-3;
static const uint SAMPLE_POINTS = 14;

// Batch control, in the sentinel island `islands[halt_index]`: `info.z` bit STOP_NOW
// (a chunk left its candidate budget: skip everything from this substep on, the host
// re-plans), `info.y` the substep at which a contact island split (that substep
// completes everywhere, then everything stops).
static const uint STOP_NOW = 1;

struct ContactParams
{
    float4 gravity;
    float dt;
    float zeta;              // damping ratio of the contact restitution
    float pair_friction;     // sim.contact_friction, or < 0 for min of the materials
    uint halt_index;         // sentinel island index
    float ground_hi;         // ground height (compensated pair)
    float ground_lo;
    float ground_friction;   // resolved (contact_friction or the ground's)
    float ground_modulus;    // E' of the ground material (scaled)
    uint has_ground;
    uint pair_count;
    uint impactor_count;
    uint chunk_count;
    uint loads_base;         // float4 index of the chunk contact loads in `contact_out`
    uint ledger_base;        // float4 index of the pair and chunk ledgers in `contact_out`
    uint step_start;         // absolute substep count when the host's step began
    uint record_stride;      // substeps per impactor record row (multiple of 1)
};

// Contact data of a chunk (indexed like the chunks).
struct ContactChunk
{
    float4 half;     // half extents; w: bounding radius
    float4 rot0;     // chunk rotation rows (body frame of the structure)
    float4 rot1;
    float4 rot2;
    float4 mat;      // E' (scaled), friction, mass, -
    float4 start_hi; // world position at the segment start; w: travel budget
    float4 start_lo;
    uint4 info;      // contribution list [x, y) in `contact_static`; z: flags (1: in a contact island, 2: on the ground list)
};

struct Impactor
{
    float4 position;     // compensated with position_err
    float4 position_err;
    float4 velocity;     // compensated with velocity_err
    float4 velocity_err;
    float4 angular_velocity;
    float4 rotation;     // quaternion (x, y, z, w)
    float4 inertia0;     // body inertia rows
    float4 inertia1;
    float4 inertia2;
    float4 inv0;         // body inverse inertia rows
    float4 inv1;
    float4 inv2;
    float4 shape;        // x: 0 sphere, 1 box; y: radius
    float4 half;         // box half extents (sphere: radius); w: bounding radius
    float4 mat;          // E' (scaled), friction, mass, -
    float4 crush;        // max force (0: none), energy, used, depth
    float4 load_force;   // this substep's contact load (world)
    float4 load_torque;
    float4 ledger;       // dissipated (compensated x + y), crush (z + w)
    uint4 cand;          // candidate list [x, y) in `contact_static`; z: driven
};

[[vk::binding(0, 0)]] ConstantBuffer<ContactParams> params;
[[vk::binding(1, 0)]] StructuredBuffer<ChunkStatic> chunks;
[[vk::binding(2, 0)]] StructuredBuffer<ContactChunk> contact_chunks;
[[vk::binding(3, 0)]] StructuredBuffer<float4> state;
[[vk::binding(4, 0)]] RWStructuredBuffer<Island> islands;
// Pair candidates (2 float4 each), impactor candidate entries, chunk contribution lists.
[[vk::binding(5, 0)]] StructuredBuffer<uint4> contact_static;
// Per pair: 28 sample-point offsets (offset, normal; NaN offset: not in contact).
[[vk::binding(6, 0)]] RWStructuredBuffer<float4> contact_state;
[[vk::binding(7, 0)]] RWStructuredBuffer<Impactor> impactors;
// Output slots (force, torque), pair and chunk ledgers, chunk contact loads.
[[vk::binding(8, 0)]] RWStructuredBuffer<float4> contact_out;

// Stop before this substep's contacts: re-plan pending, or a split in the last one.
bool stopped()
{
    Island sentinel = islands[params.halt_index];
    return (sentinel.info.z & STOP_NOW) != 0 || sentinel.info.y != 0;
}

// ------------------------------------------------------------------ chunk geometry

// A box in a local frame: centre relative to a reference point, axes (columns), half.
struct Box
{
    float3 center;
    float3 axis0;
    float3 axis1;
    float3 axis2;
    float3 half;
};

float3 box_axis(Box b, uint k)
{
    return k == 0 ? b.axis0 : (k == 1 ? b.axis1 : b.axis2);
}

float comp3(float3 v, uint k)
{
    return k == 0 ? v.x : (k == 1 ? v.y : v.z);
}

// World position of a chunk centre as (hi, lo, local offset): hi + lo + rel.
struct WorldPoint
{
    float3 hi;
    float3 lo;
    float3 rel;
};

WorldPoint chunk_world(uint c)
{
    ChunkStatic ch = chunks[c];
    Island isl = islands[ch.info.y];
    Quat q = quat_of(isl.rotation);
    WorldPoint w;
    w.hi = isl.position.xyz;
    w.lo = isl.position_err.xyz;
    w.rel = rotate(q, ch.center.xyz + state[4 * c].xyz);
    return w;
}

// a - b without cancellation.
float3 world_diff(WorldPoint a, WorldPoint b)
{
    return ((a.hi - b.hi) + (a.lo - b.lo)) + (a.rel - b.rel);
}

// The chunk's box (world.rs `chunk_box`: cluster rotation x hidden rotation x chunk
// rotation) centred at `center`.
Box chunk_box(uint c, float3 center)
{
    ChunkStatic ch = chunks[c];
    ContactChunk cc = contact_chunks[c];
    Island isl = islands[ch.info.y];
    Quat q = quat_of(isl.rotation);
    float3 th = state[4 * c + 1].xyz;
    Quat hidden = from_axis_angle(th, length(th));
    Box b;
    b.center = center;
    // Columns of the chunk rotation, turned by the hidden then the cluster rotation.
    b.axis0 = rotate(q, rotate(hidden, float3(cc.rot0.x, cc.rot1.x, cc.rot2.x)));
    b.axis1 = rotate(q, rotate(hidden, float3(cc.rot0.y, cc.rot1.y, cc.rot2.y)));
    b.axis2 = rotate(q, rotate(hidden, float3(cc.rot0.z, cc.rot1.z, cc.rot2.z)));
    b.half = cc.half.xyz;
    return b;
}

// World velocity of chunk c (solver.rs `chunk_velocity`) and of a point at `r` from its centre.
void chunk_velocity(uint c, out float3 v, out float3 w)
{
    ChunkStatic ch = chunks[c];
    Island isl = islands[ch.info.y];
    Quat q = quat_of(isl.rotation);
    float3 r = rotate(q, ch.center.xyz + state[4 * c].xyz - isl.com.xyz);
    v = (isl.velocity.xyz + isl.velocity_err.xyz) + cross(isl.angular_velocity.xyz, r) + rotate(q, state[4 * c + 2].xyz);
    w = isl.angular_velocity.xyz + rotate(q, state[4 * c + 3].xyz);
}

float3 sample_point(Box b, uint i)
{
    if (i < 8)
    {
        float3 h = b.half * 0.9;
        float3 s = float3((i & 1) == 0 ? -h.x : h.x, (i & 2) == 0 ? -h.y : h.y, (i & 4) == 0 ? -h.z : h.z);
        return b.center + b.axis0 * s.x + b.axis1 * s.y + b.axis2 * s.z;
    }
    uint axis = (i - 8) / 2;
    float sign = ((i - 8) % 2) == 0 ? -1.0 : 1.0;
    return b.center + box_axis(b, axis) * (sign * comp3(b.half, axis));
}

// contact.rs `penetration`: depth to the nearest face and its outward normal.
bool penetration(Box b, float3 p, out float depth, out float3 normal)
{
    depth = 0.0;
    normal = float3(0.0);
    float3 r = p - b.center;
    if (dot(r, r) > dot(b.half, b.half) * (1.0 + 1e-5))
        return false;
    float best = 1e30;
    uint axis = 0;
    float side = 1.0;
    for (uint k = 0; k < 3; k++)
    {
        float local = dot(r, box_axis(b, k));
        float d = comp3(b.half, k) - abs(local);
        if (d <= 0.0)
            return false;
        if (d < best)
        {
            best = d;
            axis = k;
            side = local >= 0.0 ? 1.0 : -1.0;
        }
    }
    depth = best;
    normal = box_axis(b, axis) * side;
    return true;
}

// contact.rs `may_overlap` (separating axes), with a margin above f32 rounding.
bool may_overlap(Box a, Box b)
{
    float3 d = b.center - a.center;
    float margin = 1e-5 * (length(a.half) + length(b.half));
    float3 axes[6] = { a.axis0, a.axis1, a.axis2, b.axis0, b.axis1, b.axis2 };
    for (uint i = 0; i < 15; i++)
    {
        float3 l = i < 6 ? axes[i] : cross(axes[(i - 6) / 3], axes[3 + (i - 6) % 3]);
        float len = length(l);
        if (len <= 1e-6)
            continue;
        float ra = a.half.x * abs(dot(a.axis0, l)) + a.half.y * abs(dot(a.axis1, l)) + a.half.z * abs(dot(a.axis2, l));
        float rb = b.half.x * abs(dot(b.axis0, l)) + b.half.y * abs(dot(b.axis1, l)) + b.half.z * abs(dot(b.axis2, l));
        if (abs(dot(d, l)) > ra + rb + margin * len)
            return false;
    }
    return true;
}

// world.rs `half_thickness_and_area`.
float2 half_thickness_and_area(Box b, float3 d)
{
    float h = 0.0;
    float area = 0.0;
    for (uint k = 0; k < 3; k++)
    {
        float c = abs(dot(d, box_axis(b, k)));
        h += c * comp3(b.half, k);
        area += c * 4.0 * comp3(b.half, (k + 1) % 3) * comp3(b.half, (k + 2) % 3);
    }
    return float2(h, area);
}

// world.rs `contact_stiffness` with E' = E scale / (1 - nu^2) given per body.
float contact_stiffness(float ea, Box a, float eb, Box b, float3 dir)
{
    float3 d = safe_normalize(dir);
    float2 ta = half_thickness_and_area(a, d);
    float2 tb = half_thickness_and_area(b, d);
    return min(ta.y, tb.y) / (ta.x / ea + tb.x / eb);
}

// world.rs `penalty_force`: (force, stored, dissipated).
float3 penalty_force(float k, float m_red, float friction, float depth, float3 normal, float3 rel_velocity, float dt, uint points, out float stored, out float dissipated)
{
    float c_max = MAX_SET_VISCOSITY / max(float(points), FACE_PAIR_POINTS) * m_red / dt;
    float c = min(2.0 * params.zeta * sqrt(k * m_red), c_max);
    float vn = dot(rel_velocity, normal);
    float fn_mag = max(k * depth - c * vn, 0.0);
    float3 vt = rel_velocity - normal * vn;
    float vt_mag = length(vt);
    float ft_mag = min(friction * fn_mag, min(c_max, friction * fn_mag / FRICTION_REGULARIZATION) * vt_mag);
    float3 ft = vt_mag > 0.0 ? -vt * (ft_mag / vt_mag) : float3(0.0);
    stored = 0.5 * k * depth * depth;
    float damping_power = (k * depth - c * vn > 0.0) ? c * vn * vn : k * depth * max(vn, 0.0);
    dissipated = (damping_power + length(ft) * vt_mag) * dt;
    return normal * fn_mag + ft;
}

// ------------------------------------------------------------------ chunk pairs

[shader("compute")]
[numthreads(64, 1, 1)]
void contact_pairs(uint3 id: SV_DispatchThreadID)
{
    uint i = id.x;
    if (i >= params.pair_count || stopped())
        return;
    uint4 ids = contact_static[2 * i];
    float4 law = asfloat(contact_static[2 * i + 1]);
    uint ca = ids.x;
    uint cb = ids.y;
    uint slot = ids.z;
    uint st = ids.w * 28;
    float m_red = law.x;
    float mu = law.y;
    float dt = params.dt;
    WorldPoint wa = chunk_world(ca);
    WorldPoint wb = chunk_world(cb);
    // Pair-local frame: the origin at chunk a's centre.
    float3 cb_rel = world_diff(wb, wa);
    float ra = contact_chunks[ca].half.w;
    float rb = contact_chunks[cb].half.w;
    bool touching = !(length(cb_rel) > ra + rb);
    Box ba = chunk_box(ca, float3(0.0));
    Box bb = chunk_box(cb, cb_rel);
    float3 fa = float3(0.0), ta = float3(0.0), fb = float3(0.0), tb = float3(0.0);
    float stored_sum = 0.0;
    float4 ledger = contact_out[params.ledger_base + i];
    if (touching && may_overlap(ba, bb))
    {
        // Sample points of each box inside the other.
        float3 pts[28];
        float3 nrm[28];
        float dep[28];
        uint idx[28];
        uint count = 0;
        for (uint s = 0; s < SAMPLE_POINTS; s++)
        {
            float3 p = sample_point(ba, s);
            float d;
            float3 n;
            if (penetration(bb, p, d, n))
            {
                pts[count] = p;
                nrm[count] = n;
                dep[count] = d;
                idx[count] = s;
                count++;
            }
        }
        for (uint s = 0; s < SAMPLE_POINTS; s++)
        {
            float3 p = sample_point(bb, s);
            float d;
            float3 n;
            if (penetration(ba, p, d, n))
            {
                pts[count] = p;
                nrm[count] = -n;
                dep[count] = d;
                idx[count] = SAMPLE_POINTS + s;
                count++;
            }
        }
        if (count > 0)
        {
            float k_pair = contact_stiffness(contact_chunks[ca].mat.x, ba, contact_chunks[cb].mat.x, bb, bb.center - ba.center);
            float3 va0, wa0, vb0, wb0;
            chunk_velocity(ca, va0, wa0);
            chunk_velocity(cb, vb0, wb0);
            uint inside_mask = 0;
            float eff[28];
            uint engaged = 0;
            for (uint j = 0; j < count; j++)
            {
                uint e = idx[j];
                inside_mask |= 1u << e;
                float4 entry = contact_state[st + e];
                float3 p = pts[j];
                float3 n = nrm[j];
                if (isnan(entry.x) || dot(entry.yzw, n) < 0.99)
                {
                    float3 va = va0 + cross(wa0, p);
                    float3 vb = vb0 + cross(wb0, p - bb.center);
                    float reach = 2.0 * abs(dot(va - vb, n)) * dt + 1e-9;
                    entry = float4(dep[j] > reach ? dep[j] : 0.0, n);
                }
                entry.x = min(entry.x, dep[j]);
                contact_state[st + e] = entry;
                eff[j] = dep[j] - entry.x;
                if (eff[j] > 0.0)
                    engaged++;
            }
            for (uint e = 0; e < 2 * SAMPLE_POINTS; e++)
                if ((inside_mask & (1u << e)) == 0)
                    contact_state[st + e] = float4(asfloat(0x7fc00000u), 0.0, 0.0, 0.0);
            float k = k_pair / max(float(engaged), FACE_PAIR_POINTS);
            for (uint j = 0; j < count; j++)
            {
                if (eff[j] <= 0.0)
                    continue;
                float3 p = pts[j];
                float3 va = va0 + cross(wa0, p);
                float3 vb = vb0 + cross(wb0, p - bb.center);
                float stored;
                float diss;
                float3 f = penalty_force(k, m_red, mu, eff[j], nrm[j], va - vb, dt, engaged, stored, diss);
                fa += f;
                ta += cross(p, f);
                fb += -f;
                tb += cross(p - bb.center, -f);
                stored_sum += stored;
                comp_add1(ledger.y, ledger.z, diss);
            }
        }
        else
        {
            for (uint e = 0; e < 2 * SAMPLE_POINTS; e++)
                contact_state[st + e] = float4(asfloat(0x7fc00000u), 0.0, 0.0, 0.0);
        }
    }
    else
    {
        for (uint e = 0; e < 2 * SAMPLE_POINTS; e++)
            contact_state[st + e] = float4(asfloat(0x7fc00000u), 0.0, 0.0, 0.0);
    }
    ledger.x = stored_sum;
    contact_out[params.ledger_base + i] = ledger;
    contact_out[2 * slot] = float4(fa, 0.0);
    contact_out[2 * slot + 1] = float4(ta, 0.0);
    contact_out[2 * slot + 2] = float4(fb, 0.0);
    contact_out[2 * slot + 3] = float4(tb, 0.0);
}

// ------------------------------------------------------------------ impactors

Box impactor_box(Impactor imp, float3 center, float3 half)
{
    Quat q = quat_of(imp.rotation);
    Box b;
    b.center = center;
    b.axis0 = rotate(q, float3(1, 0, 0));
    b.axis1 = rotate(q, float3(0, 1, 0));
    b.axis2 = rotate(q, float3(0, 0, 1));
    b.half = half;
    return b;
}

// contact.rs `sphere_contact` of a sphere (centre relative to the box frame) and a box.
bool sphere_contact(Box b, float3 center, float radius, out float3 point, out float3 normal, out float depth)
{
    point = float3(0.0);
    normal = float3(0.0);
    depth = 0.0;
    float3 r = center - b.center;
    float3 local = float3(dot(r, b.axis0), dot(r, b.axis1), dot(r, b.axis2));
    float3 q = clamp(local, -b.half, b.half);
    float3 d = local - q;
    float dist = length(d);
    if (dist > 1e-12)
    {
        if (dist >= radius)
            return false;
        float3 dn = d / dist;
        normal = b.axis0 * dn.x + b.axis1 * dn.y + b.axis2 * dn.z;
        point = b.center + b.axis0 * q.x + b.axis1 * q.y + b.axis2 * q.z;
        depth = radius - dist;
        return true;
    }
    float inside;
    float3 n;
    if (!penetration(b, center, inside, n))
        return false;
    normal = n;
    point = center - n * min(radius, inside);
    depth = radius + inside;
    return true;
}

// The contacts of an impactor with one chunk (world.rs `apply_contacts`), in the
// impactor's frame (origin at its centre). Returns the number of points.
uint impactor_points(Impactor imp, Box ib, Box b, out float3 pts[28], out float3 nrm[28], out float dep[28])
{
    uint count = 0;
    if (imp.shape.x == 0.0)
    {
        float3 p;
        float3 n;
        float d;
        if (sphere_contact(b, float3(0.0), imp.shape.y - imp.crush.w, p, n, d))
        {
            pts[0] = p;
            nrm[0] = -n;
            dep[0] = d;
            count = 1;
        }
        return count;
    }
    Box shrunk = ib;
    shrunk.half = ib.half - min(float3(imp.crush.w), ib.half * 0.5);
    for (uint s = 0; s < SAMPLE_POINTS; s++)
    {
        float3 p = sample_point(b, s);
        float d;
        float3 n;
        if (penetration(shrunk, p, d, n))
        {
            pts[count] = p;
            nrm[count] = n;
            dep[count] = d;
            count++;
        }
    }
    for (uint s = 0; s < SAMPLE_POINTS; s++)
    {
        float3 p = sample_point(shrunk, s);
        float d;
        float3 n;
        if (penetration(b, p, d, n))
        {
            pts[count] = p;
            nrm[count] = -n;
            dep[count] = d;
            count++;
        }
    }
    return count;
}

[shader("compute")]
[numthreads(64, 1, 1)]
void contact_impactors(uint3 id: SV_DispatchThreadID)
{
    uint ii = id.x;
    if (ii >= params.impactor_count || stopped())
        return;
    Impactor imp = impactors[ii];
    float dt = params.dt;
    float3 load_f = float3(0.0);
    float3 load_t = float3(0.0);
    if (imp.cand.z == 0)
    {
        WorldPoint wi;
        wi.hi = imp.position.xyz;
        wi.lo = imp.position_err.xyz;
        wi.rel = float3(0.0);
        Box ib = impactor_box(imp, float3(0.0), imp.half.xyz);
        float reach = imp.half.w;
        // Pass 1: total elastic force (for the crush cap).
        float total = 0.0;
        float ksum = 0.0;
        for (uint e = imp.cand.x; e < imp.cand.y; e++)
        {
            uint c = contact_static[e].x;
            float3 rel = world_diff(chunk_world(c), wi);
            if (length(rel) > reach + contact_chunks[c].half.w)
                continue;
            Box b = chunk_box(c, rel);
            float kc = contact_stiffness(imp.mat.x, ib, contact_chunks[c].mat.x, b, b.center - ib.center);
            float3 pts[28];
            float3 nrm[28];
            float dep[28];
            uint n = impactor_points(imp, ib, b, pts, nrm, dep);
            float kp = imp.shape.x == 0.0 ? kc : kc / max(float(n), FACE_PAIR_POINTS);
            for (uint j = 0; j < n; j++)
            {
                total += kp * dep[j];
                ksum += kp;
            }
        }
        float crush_factor = 1.0;
        if (imp.crush.x > 0.0 && imp.crush.z < imp.crush.y && total > imp.crush.x)
        {
            float extra = (total - imp.crush.x) / ksum;
            imp.crush.w += extra;
            imp.crush.z += imp.crush.x * extra;
            comp_add1(imp.ledger.z, imp.ledger.w, imp.crush.x * extra);
            comp_add1(imp.ledger.x, imp.ledger.y, imp.crush.x * extra);
            crush_factor = imp.crush.x / total;
        }
        // Pass 2: forces, with the crush depth the contacts were found at.
        Impactor at = impactors[ii];
        float3 v_imp = imp.velocity.xyz + imp.velocity_err.xyz;
        for (uint e = imp.cand.x; e < imp.cand.y; e++)
        {
            uint c = contact_static[e].x;
            uint slot = contact_static[e].y;
            float3 rel = world_diff(chunk_world(c), wi);
            float3 f_sum = float3(0.0);
            float3 t_sum = float3(0.0);
            if (!(length(rel) > reach + contact_chunks[c].half.w))
            {
                Box b = chunk_box(c, rel);
                float kc = contact_stiffness(imp.mat.x, ib, contact_chunks[c].mat.x, b, b.center - ib.center);
                float3 pts[28];
                float3 nrm[28];
                float dep[28];
                uint n = impactor_points(at, ib, b, pts, nrm, dep);
                float kp = imp.shape.x == 0.0 ? kc : kc / max(float(n), FACE_PAIR_POINTS);
                uint points = imp.shape.x == 0.0 ? 1 : n;
                float m = contact_chunks[c].mat.z;
                float m_red = m * imp.mat.z / (m + imp.mat.z);
                float mu = params.pair_friction >= 0.0 ? params.pair_friction : min(imp.mat.y, contact_chunks[c].mat.y);
                float3 vc;
                float3 wc;
                chunk_velocity(c, vc, wc);
                for (uint j = 0; j < n; j++)
                {
                    float3 p = pts[j];
                    float3 v_chunk = vc + cross(wc, p - b.center);
                    float3 v_i = v_imp + cross(imp.angular_velocity.xyz, p);
                    float stored;
                    float diss;
                    float3 f = penalty_force(kp, m_red, mu, dep[j] * crush_factor, nrm[j], v_chunk - v_i, dt, points, stored, diss);
                    f_sum += f;
                    t_sum += cross(p - b.center, f);
                    load_f -= f;
                    load_t -= cross(p, f);
                    comp_add1(imp.ledger.x, imp.ledger.y, diss);
                }
            }
            contact_out[2 * slot] = float4(f_sum, 0.0);
            contact_out[2 * slot + 1] = float4(t_sum, 0.0);
        }
        // The impactor on the ground.
        if (params.has_ground != 0)
        {
            Box ib_world = ib;
            float kc = contact_stiffness(params.ground_modulus, ib, imp.mat.x, ib, float3(0.0, 0.0, 1.0));
            // Height of the impactor centre above the ground, compensated.
            float above = ((imp.position.z - params.ground_hi) + (imp.position_err.z - params.ground_lo));
            uint total_points = imp.shape.x == 0.0 ? 1 : SAMPLE_POINTS;
            float kp = kc / float(min(total_points, 5u));
            uint below = 0;
            for (uint s = 0; s < total_points; s++)
            {
                float3 p = imp.shape.x == 0.0 ? float3(0.0, 0.0, -imp.shape.y) : sample_point(ib_world, s);
                if (above + p.z < 0.0)
                    below++;
            }
            for (uint s = 0; s < total_points; s++)
            {
                float3 p = imp.shape.x == 0.0 ? float3(0.0, 0.0, -imp.shape.y) : sample_point(ib_world, s);
                float depth = -(above + p.z);
                if (depth <= 0.0)
                    continue;
                float3 v = v_imp + cross(imp.angular_velocity.xyz, p);
                float stored;
                float diss;
                float3 f = penalty_force(kp, imp.mat.z, params.ground_friction, depth, float3(0.0, 0.0, 1.0), v, dt, below, stored, diss);
                load_f += f;
                load_t += cross(p, f);
                comp_add1(imp.ledger.x, imp.ledger.y, diss);
            }
        }
    }
    imp.load_force = float4(load_f, 0.0);
    imp.load_torque = float4(load_t, 0.0);
    impactors[ii] = imp;
}

// ------------------------------------------------------------------ gather

[shader("compute")]
[numthreads(64, 1, 1)]
void contact_gather(uint3 id: SV_DispatchThreadID)
{
    uint c = id.x;
    if (c >= params.chunk_count || stopped())
        return;
    ContactChunk cc = contact_chunks[c];
    if ((cc.info.z & 1) == 0)
        return;
    WorldPoint wp = chunk_world(c);
    // Travel check: a chunk outside its candidate budget stops the batch (re-plan).
    float3 moved = ((wp.hi - cc.start_hi.xyz) + (wp.lo - cc.start_lo.xyz)) + wp.rel;
    if (length(moved) > cc.start_hi.w)
    {
        // Every writer stores the same bit: no atomics needed.
        islands[params.halt_index].info.z = islands[params.halt_index].info.z | STOP_NOW;
        return;
    }
    float3 f = float3(0.0);
    float3 t = float3(0.0);
    float4 ledger = contact_out[params.ledger_base + params.pair_count + c];
    float dt = params.dt;
    for (uint e = cc.info.x; e < cc.info.y; e++)
    {
        uint4 entry = contact_static[e];
        if (entry.x == 0)
        {
            f += contact_out[2 * entry.y].xyz;
            t += contact_out[2 * entry.y + 1].xyz;
            continue;
        }
        // Ground (world.rs `apply_contacts`): the box's sample points below the ground.
        float above = ((wp.hi.z - params.ground_hi) + (wp.lo.z - params.ground_lo)) + wp.rel.z;
        if (above - cc.half.w > 0.0)
            continue;
        Box b = chunk_box(c, float3(0.0));
        float kc = contact_stiffness(params.ground_modulus, b, cc.mat.x, b, float3(0.0, 0.0, 1.0));
        uint n = 0;
        for (uint s = 0; s < SAMPLE_POINTS; s++)
            if (above + sample_point(b, s).z < 0.0)
                n++;
        float3 vc;
        float3 wc;
        chunk_velocity(c, vc, wc);
        for (uint s = 0; s < SAMPLE_POINTS; s++)
        {
            float3 p = sample_point(b, s);
            float depth = -(above + p.z);
            if (!(above + p.z < 0.0))
                continue;
            float3 v = vc + cross(wc, p);
            float stored;
            float diss;
            float3 g = penalty_force(kc / float(max(n, 5u)), cc.mat.z, params.ground_friction, depth, float3(0.0, 0.0, 1.0), v, dt, n, stored, diss);
            f += g;
            t += cross(p, g);
            comp_add1(ledger.y, ledger.z, diss);
        }
    }
    contact_out[params.ledger_base + params.pair_count + c] = ledger;
    contact_out[params.loads_base + 2 * c] = float4(f, 0.0);
    contact_out[params.loads_base + 2 * c + 1] = float4(t, 0.0);
}

// ------------------------------------------------------------------ impactor motion

[shader("compute")]
[numthreads(64, 1, 1)]
void impactor_integrate(uint3 id: SV_DispatchThreadID)
{
    uint ii = id.x;
    if (ii >= params.impactor_count)
        return;
    Island sentinel = islands[params.halt_index];
    Impactor imp = impactors[ii];
    // cand.w: substeps integrated so far. Integrate through the substep of a split
    // (it completes), not past it; nothing after a re-plan stop.
    if (imp.cand.z != 0 || (sentinel.info.z & STOP_NOW) != 0 || (sentinel.info.y != 0 && imp.cand.w >= sentinel.info.y))
        return;
    imp.cand.w += 1;
    float dt = params.dt;
    float m = imp.mat.z;
    float3 vel = imp.velocity.xyz;
    float3 vel_err = imp.velocity_err.xyz;
    comp_add(vel, vel_err, (imp.load_force.xyz / m + params.gravity.xyz) * dt);
    Quat q = quat_of(imp.rotation);
    float3 l = world_mul(q, imp.inertia0, imp.inertia1, imp.inertia2, imp.angular_velocity.xyz) + imp.load_torque.xyz * dt;
    float3 w_mid = world_mul(q, imp.inv0, imp.inv1, imp.inv2, l);
    float3 pos = imp.position.xyz;
    float3 pos_err = imp.position_err.xyz;
    comp_add(pos, pos_err, (vel + vel_err) * dt);
    q = integrate_rotation(q, w_mid, dt);
    imp.angular_velocity = float4(world_mul(q, imp.inv0, imp.inv1, imp.inv2, l), 0.0);
    imp.rotation = quat_vec(q);
    imp.position = float4(pos, 0.0);
    imp.position_err = float4(pos_err, 0.0);
    imp.velocity = float4(vel, 0.0);
    imp.velocity_err = float4(vel_err, 0.0);
    impactors[ii] = imp;
    // Per-substep record for the impactor probes: velocity, position.
    uint k = imp.cand.w - 1 - params.step_start;
    if (k < params.record_stride)
    {
        uint at = params.loads_base + 2 * params.chunk_count + 2 * (ii * params.record_stride + k);
        contact_out[at] = float4(vel + vel_err, 0.0);
        contact_out[at + 1] = float4(pos + pos_err, 0.0);
    }
}
