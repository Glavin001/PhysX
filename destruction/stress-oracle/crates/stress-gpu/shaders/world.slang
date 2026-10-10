// The standalone world on the GPU (stress-ref `World` / `ReferenceSolver`, explicit
// mode): every kernel shares one set of bindings and parameters.
//
// Per substep, for the islands in the contact pipeline (and impactors):
//   [impactor_shares, impactor_crush]  only when an impactor has a crush cap: the
//                       candidates' shares of the impactor's elastic force, then the cap;
//   contact_forces      chunk pairs, impactor candidates (forces on the chunk, reactions
//                       on the impactor), and every contact chunk's travel check;
//   island_frame        one threadgroup per island: rigid acceleration, the joint law per
//                       bond, the per-chunk gather of bond loads and of contact loads
//                       (impactors, ground, chunk pairs, in the reference's order), frame
//                       loads, central differences, rigid integration, drift removal,
//                       probes; islands outside the pipeline run every substep of a
//                       segment in one dispatch;
//   impactor_integrate one threadgroup per impactor: its contact reactions (tree sum),
//                       the ground, its rigid motion, its probe record.
//
// Reference: solver.rs (substep, frame_loads, rigid_acceleration, integrate_cluster,
// integrate_rigid, remove_rigid_drift), joint.rs (joint.slang), bond.rs, world.rs
// (apply_contacts, penalty_force, pair_contact, scripted loads, probes), contact.rs.
// Geometry is computed relative to nearby points with compensated positions (world
// coordinates in f32 resolve ~1e-6 m at 10 m).

import joint;
import common;

static const uint THREADS = 256;

static const float MAX_SET_VISCOSITY = 1.0;
static const float FACE_PAIR_POINTS = 10.0;
static const float FRICTION_REGULARIZATION = 1e-3;
static const uint SAMPLE_POINTS = 14;

// Batch control, in the sentinel island `islands[halt_index]`: `info.z` bit STOP_NOW
// (a chunk left its candidate budget: skip everything from this substep on, the host
// re-plans), `info.y` the substep at which a contact island split (that substep
// completes everywhere, then everything stops).
static const uint STOP_NOW = 1;

struct Params
{
    float4 gravity;          // world
    float dt;
    uint fracture;           // 0/1
    uint rigid_motion_loads; // 0/1
    uint step_start;         // absolute substep count when the host's step began
    float t_hi;              // time when the host's step began (compensated pair)
    float t_lo;
    uint max_steps;          // island_frame: substeps per island in this dispatch at most
    uint contact_mode;       // island_frame: 0 islands outside the pipeline, 1 contact islands
    uint halt_index;         // sentinel island
    uint chunk_count;
    uint pair_count;
    uint impactor_count;
    uint cand_count;         // impactor candidates (all impactors, in order)
    uint probe_base;         // scratch: probe outputs (float4 index)
    uint probe_stride;       // floats per probe item (multiple of 4)
    uint slot_base;          // scratch: contact output slots (2 float4 each)
    uint ledger_base;        // scratch: pair ledgers, then chunk ground ledgers
    uint record_base;        // scratch: impactor records (2 per impactor and substep)
    uint record_stride;
    uint cand_base;          // scratch: impactor candidate data (3 per candidate)
    uint pair_index;         // index: pair candidates (6 uints each)
    uint cand_index;         // index: impactor candidates (3 uints each)
    float zeta;              // damping ratio of the contact restitution
    float pair_friction;     // sim.contact_friction, or < 0 for min of the materials
    float ground_hi;         // ground height (compensated pair)
    float ground_lo;
    float ground_friction;   // resolved (contact_friction or the ground's)
    float ground_modulus;    // E' of the ground material (scaled)
    uint has_ground;
    uint wide_bond_groups;   // wide islands: bond groups (dispatched before the chunk groups)
    uint wide_bond_table;    // index: bond groups (island, begin, end, -)
    uint wide_chunk_table;   // index: chunk groups (island, begin, end, first group)
    uint wide_base;          // scratch: per chunk group partial sums (8 float4)
    uint seg_index;          // index: contact segments (chunk, begin, end)
    uint seg_count;
    uint seg_base;           // scratch: contact segment sums (force, torque)
    uint solve_mode;         // 0 explicit, 1 adaptive (settled islands can wake), 2 quasi-static
    uint cload_base;         // scratch: each chunk's external load of its last substep (2 float4)
    uint cframe_base;        // scratch: each chunk's external load summed over the frame (2 float4)
    uint statics_base;       // scratch: static solves (island_statics)
    uint statics_bonds;      // bonds in the layout
    uint statics_newton;     // Newton iterations at most
    uint statics_cg;         // conjugate-gradient iterations per Newton step at most
    float statics_tol;       // relative residual of an equilibrium
};

static const uint MODE_EXPLICIT = 0;
static const uint MODE_ADAPTIVE = 1;

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
    float4 geom;         // x: crush factor, y: crush depth the contacts use (this substep)
    float4 unused;
    float4 ledger;       // dissipated (compensated x + y), crush (z + w)
    uint4 cand;          // candidates [x, y) (candidate numbers); z: driven; w: substeps integrated
};

[[vk::binding(0, 0)]] ConstantBuffer<Params> params;
[[vk::binding(1, 0)]] ConstantBuffer<MaterialTable> materials;
[[vk::binding(2, 0)]] StructuredBuffer<BondStatic> bonds;
[[vk::binding(3, 0)]] StructuredBuffer<ChunkStatic> chunks;
// Integer data: CSR incidence ([chunk_count + 1 offsets], then 2 * bond + side), chunk
// contact contributions (slot, or 0x80000000 for the ground), pair candidates (a, b,
// slot, state, m_red bits, mu bits), impactor candidates (chunk, slot, impactor).
[[vk::binding(4, 0)]] StructuredBuffer<uint> index;
// Load terms, table data and probe items.
[[vk::binding(5, 0)]] StructuredBuffer<float4> loads;
// 4 per chunk: u (w: largest bond stress), theta, v, w (w lanes: support reaction).
[[vk::binding(6, 0)]] RWStructuredBuffer<float4> state;
[[vk::binding(7, 0)]] RWStructuredBuffer<BondDyn> bond_dyn;
// Bond loads (3 per bond: f on a (w: peak stress), moment on a, moment on b), probe
// outputs, contact slots, ledgers, impactor records, impactor candidate data.
[[vk::binding(8, 0)]] RWStructuredBuffer<float4> scratch;
[[vk::binding(9, 0)]] RWStructuredBuffer<Island> islands;
[[vk::binding(10, 0)]] RWStructuredBuffer<Impactor> impactors;
// Per pair: 28 sample-point offsets (offset, normal; NaN offset: not in contact).
[[vk::binding(11, 0)]] RWStructuredBuffer<float4> contact_state;

static const uint GROUND_ENTRY = 0x80000000u;

// Stop before this substep's contacts: re-plan pending, or a split in the last one.
bool stopped()
{
    Island sentinel = islands[params.halt_index];
    return (sentinel.info.z & STOP_NOW) != 0 || sentinel.info.y != 0;
}

// ------------------------------------------------------------------ group reductions

groupshared float4 g_red_a[THREADS];
groupshared float4 g_red_b[THREADS];

// Sums of two float4 over the group (fixed tree order: deterministic).
void group_sum2(uint tid, inout float4 a, inout float4 b)
{
    g_red_a[tid] = a;
    g_red_b[tid] = b;
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
    a = g_red_a[0];
    b = g_red_b[0];
    GroupMemoryBarrierWithGroupSync();
}

void group_sum3(uint tid, inout float3 a, inout float3 b)
{
    float4 x = float4(a, 0.0);
    float4 y = float4(b, 0.0);
    group_sum2(tid, x, y);
    a = x.xyz;
    b = y.xyz;
}

// ------------------------------------------------------------------ geometry

// A box in a local frame: centre relative to a reference point, axes (columns), half.
// A convex hull chunk keeps `half` as its bounds; its vertices, face planes and face
// centroids are in `loads` from `hull_at` (hull frame = the box axes).
struct Box
{
    float3 center;
    float3 axis0;
    float3 axis1;
    float3 axis2;
    float3 half;
    uint hull_at;
    uint hull_v; // 0: a box
    uint hull_f;
};

float3 box_to_world(Box b, float3 local)
{
    return b.axis0 * local.x + b.axis1 * local.y + b.axis2 * local.z;
}

float3 box_to_local(Box b, float3 r)
{
    return float3(dot(r, b.axis0), dot(r, b.axis1), dot(r, b.axis2));
}

float3 box_axis(Box b, uint k)
{
    return k == 0 ? b.axis0 : (k == 1 ? b.axis1 : b.axis2);
}

float comp3(float3 v, uint k)
{
    return k == 0 ? v.x : (k == 1 ? v.y : v.z);
}

// World position as (hi, lo, local offset): hi + lo + rel.
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
    Island isl = islands[ch.info.y];
    Quat q = quat_of(isl.rotation);
    float3 th = state[4 * c + 1].xyz;
    Quat hidden = from_axis_angle(th, length(th));
    Box b;
    b.center = center;
    b.axis0 = rotate(q, rotate(hidden, float3(ch.crot0.x, ch.crot1.x, ch.crot2.x)));
    b.axis1 = rotate(q, rotate(hidden, float3(ch.crot0.y, ch.crot1.y, ch.crot2.y)));
    b.axis2 = rotate(q, rotate(hidden, float3(ch.crot0.z, ch.crot1.z, ch.crot2.z)));
    b.half = ch.half.xyz;
    b.hull_at = asuint(ch.cmat.z);
    b.hull_v = asuint(ch.cmat.w) & 0xffu;
    b.hull_f = asuint(ch.cmat.w) >> 8;
    return b;
}

// World velocity and angular velocity of chunk c (solver.rs `chunk_velocity`).
void chunk_velocity(uint c, out float3 v, out float3 w)
{
    ChunkStatic ch = chunks[c];
    Island isl = islands[ch.info.y];
    Quat q = quat_of(isl.rotation);
    float3 r = rotate(q, ch.center.xyz + state[4 * c].xyz - isl.com.xyz);
    v = (isl.velocity.xyz + isl.velocity_err.xyz) + cross(isl.angular_velocity.xyz, r) + rotate(q, state[4 * c + 2].xyz);
    w = isl.angular_velocity.xyz + rotate(q, state[4 * c + 3].xyz);
}

// contact.rs `sample_count`: 14 for a box; a hull's vertices and faces.
uint sample_count(Box b)
{
    return b.hull_v == 0 ? SAMPLE_POINTS : b.hull_v + b.hull_f;
}

// contact.rs `for_each_sample`: box corners pulled 10% in, then face centres; a hull's
// vertices pulled 10% in, then its face centroids.
float3 sample_point(Box b, uint i)
{
    if (b.hull_v != 0)
    {
        float3 local = i < b.hull_v ? loads[b.hull_at + i].xyz * 0.9 : loads[b.hull_at + b.hull_v + b.hull_f + (i - b.hull_v)].xyz;
        return b.center + box_to_world(b, local);
    }
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

// hull.rs `signed_distance`: the largest face-plane distance (first face on ties).
float hull_signed_distance(Box b, float3 local, out uint face)
{
    float best = -1e30;
    face = 0;
    for (uint f = 0; f < b.hull_f; f++)
    {
        float4 plane = loads[b.hull_at + b.hull_v + f];
        float d = dot(plane.xyz, local) - plane.w;
        if (d > best)
        {
            best = d;
            face = f;
        }
    }
    return best;
}

// contact.rs `penetration`: depth to the nearest face and its outward normal.
bool penetration(Box b, float3 p, out float depth, out float3 normal)
{
    depth = 0.0;
    normal = float3(0.0);
    float3 r = p - b.center;
    if (dot(r, r) > dot(b.half, b.half) * (1.0 + 1e-5))
        return false;
    if (b.hull_v != 0)
    {
        uint face;
        float d = hull_signed_distance(b, box_to_local(b, r), face);
        if (!(d < 0.0))
            return false;
        depth = -d;
        normal = box_to_world(b, loads[b.hull_at + b.hull_v + face].xyz);
        return true;
    }
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

Box impactor_box(Impactor imp, float3 center, float3 half)
{
    Quat q = quat_of(imp.rotation);
    Box b;
    b.center = center;
    b.axis0 = rotate(q, float3(1, 0, 0));
    b.axis1 = rotate(q, float3(0, 1, 0));
    b.axis2 = rotate(q, float3(0, 0, 1));
    b.half = half;
    b.hull_at = 0;
    b.hull_v = 0;
    b.hull_f = 0;
    return b;
}

WorldPoint impactor_point(Impactor imp)
{
    WorldPoint wi;
    wi.hi = imp.position.xyz;
    wi.lo = imp.position_err.xyz;
    wi.rel = float3(0.0);
    return wi;
}

// contact.rs `sphere_contact` of a sphere (centre relative to the box frame) and a box.
bool sphere_contact(Box b, float3 center, float radius, out float3 point, out float3 normal, out float depth)
{
    point = float3(0.0);
    normal = float3(0.0);
    depth = 0.0;
    float3 r = center - b.center;
    float3 local = float3(dot(r, b.axis0), dot(r, b.axis1), dot(r, b.axis2));
    if (b.hull_v != 0)
    {
        // Nearest face plane (exact over a face, conservative near edges and corners).
        uint face;
        float d = hull_signed_distance(b, local, face);
        if (d >= radius)
            return false;
        normal = box_to_world(b, loads[b.hull_at + b.hull_v + face].xyz);
        point = center - normal * max(d, 0.0);
        depth = radius - d;
        return true;
    }
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
// impactor's frame (origin at its centre), enumerated by `j` in [0, impactor_slots):
// a sphere has one; a box has the chunk's samples inside it (shrunk by the crush depth),
// then its own samples inside the chunk. False where `j` is not in contact.
uint impactor_slots(Impactor imp, Box b)
{
    return imp.shape.x == 0.0 ? 1 : sample_count(b) + SAMPLE_POINTS;
}

Box impactor_shrunk(Impactor imp, float crush_depth, Box ib)
{
    Box shrunk = ib;
    shrunk.half = ib.half - min(float3(crush_depth), ib.half * 0.5);
    return shrunk;
}

bool impactor_contact(Impactor imp, float crush_depth, Box shrunk, Box b, uint j, out float3 p, out float3 n, out float d)
{
    p = float3(0.0);
    n = float3(0.0);
    d = 0.0;
    if (imp.shape.x == 0.0)
    {
        if (!sphere_contact(b, float3(0.0), imp.shape.y - crush_depth, p, n, d))
            return false;
        n = -n;
        return true;
    }
    uint cb = sample_count(b);
    if (j < cb)
    {
        p = sample_point(b, j);
        return penetration(shrunk, p, d, n);
    }
    p = sample_point(shrunk, j - cb);
    if (!penetration(b, p, d, n))
        return false;
    n = -n;
    return true;
}

// The number of contact points of an impactor with a chunk.
uint impactor_contact_count(Impactor imp, float crush_depth, Box shrunk, Box b)
{
    uint count = 0;
    for (uint j = 0; j < impactor_slots(imp, b); j++)
    {
        float3 p;
        float3 n;
        float d;
        if (impactor_contact(imp, crush_depth, shrunk, b, j, p, n, d))
            count++;
    }
    return count;
}

// ------------------------------------------------------------------ contacts

static const float NAN_OFFSET = asfloat(0x7fc00000u);

// NaN by its bits: holds under fast math, which may assume no NaN.
bool is_nan(float x)
{
    return (asuint(x) & 0x7fffffffu) > 0x7f800000u;
}

// A sample point of the pair (entry e: a's samples, then b's) inside the other chunk:
// its point, the normal pushing a out of b, and the depth.
bool pair_point(Box ba, Box bb, uint na, uint e, out float3 p, out float3 n, out float d)
{
    if (e < na)
    {
        p = sample_point(ba, e);
        return penetration(bb, p, d, n);
    }
    p = sample_point(bb, e - na);
    if (!penetration(ba, p, d, n))
        return false;
    n = -n;
    return true;
}

void pair_contact(uint i)
{
    uint at = params.pair_index + 6 * i;
    uint ca = index[at];
    uint cb = index[at + 1];
    uint slot = index[at + 2];
    uint st = index[at + 3];
    float m_red = asfloat(index[at + 4]);
    float mu = asfloat(index[at + 5]);
    float dt = params.dt;
    uint out = params.slot_base + 2 * slot;
    WorldPoint wa = chunk_world(ca);
    WorldPoint wb = chunk_world(cb);
    // Pair-local frame: the origin at chunk a's centre.
    float3 cb_rel = world_diff(wb, wa);
    bool touching = !(length(cb_rel) > chunks[ca].half.w + chunks[cb].half.w);
    float4 ledger = scratch[params.ledger_base + i];
    uint flags = asuint(ledger.w);
    Box ba = chunk_box(ca, float3(0.0));
    Box bb = chunk_box(cb, cb_rel);
    uint entries = sample_count(ba) + sample_count(bb);
    if (!touching)
    {
        // Far apart (most candidates): forget the pair's overlap, clear its outputs,
        // and write nothing when there is nothing to clear.
        if ((flags & 1) != 0)
            for (uint e = 0; e < entries; e++)
                contact_state[st + e] = float4(NAN_OFFSET, 0.0, 0.0, 0.0);
        if ((flags & 2) != 0)
            for (uint e = 0; e < 4; e++)
                scratch[out + e] = float4(0.0);
        if (flags != 0 || ledger.x != 0.0)
        {
            ledger.x = 0.0;
            ledger.w = asfloat(0u);
            scratch[params.ledger_base + i] = ledger;
        }
        return;
    }
    uint na = sample_count(ba);
    float3 fa = float3(0.0), ta = float3(0.0), fb = float3(0.0), tb = float3(0.0);
    float stored_sum = 0.0;
    bool has_state = false;
    if (may_overlap(ba, bb))
    {
        float3 va0, wa0, vb0, wb0;
        chunk_velocity(ca, va0, wa0);
        chunk_velocity(cb, vb0, wb0);
        // Pass 1: the overlap offsets of the points inside (new contacts born deeper
        // than one substep of approach keep their overlap as an offset that only
        // ratchets down); the points outside forget theirs.
        uint count = 0;
        uint engaged = 0;
        for (uint e = 0; e < entries; e++)
        {
            float3 p;
            float3 n;
            float d;
            if (!pair_point(ba, bb, na, e, p, n, d))
            {
                if (!is_nan(contact_state[st + e].x))
                    contact_state[st + e] = float4(NAN_OFFSET, 0.0, 0.0, 0.0);
                continue;
            }
            count++;
            float4 entry = contact_state[st + e];
            if (is_nan(entry.x) || dot(entry.yzw, n) < 0.99)
            {
                float3 va = va0 + cross(wa0, p);
                float3 vb = vb0 + cross(wb0, p - bb.center);
                float reach = 2.0 * abs(dot(va - vb, n)) * dt + 1e-9;
                entry = float4(d > reach ? d : 0.0, n);
            }
            entry.x = min(entry.x, d);
            contact_state[st + e] = entry;
            if (d - entry.x > 0.0)
                engaged++;
        }
        if (count > 0)
        {
            has_state = true;
            // Pass 2: penalty forces of the engaged points (geometry recomputed: the
            // same values, without per-point storage).
            float k_pair = contact_stiffness(chunks[ca].cmat.x, ba, chunks[cb].cmat.x, bb, bb.center - ba.center);
            float k = k_pair / max(float(engaged), FACE_PAIR_POINTS);
            for (uint e = 0; e < entries; e++)
            {
                float3 p;
                float3 n;
                float d;
                if (!pair_point(ba, bb, na, e, p, n, d))
                    continue;
                float eff = d - contact_state[st + e].x;
                if (eff <= 0.0)
                    continue;
                float3 va = va0 + cross(wa0, p);
                float3 vb = vb0 + cross(wb0, p - bb.center);
                float stored;
                float diss;
                float3 f = penalty_force(k, m_red, mu, eff, n, va - vb, dt, engaged, stored, diss);
                fa += f;
                ta += cross(p, f);
                fb += -f;
                tb += cross(p - bb.center, -f);
                stored_sum += stored;
                comp_add1(ledger.y, ledger.z, diss);
            }
        }
    }
    if (!has_state && (flags & 1) != 0)
        for (uint e = 0; e < entries; e++)
            contact_state[st + e] = float4(NAN_OFFSET, 0.0, 0.0, 0.0);
    bool loaded = any(fa != 0.0) || any(ta != 0.0) || any(fb != 0.0) || any(tb != 0.0);
    if (loaded || (flags & 2) != 0)
    {
        scratch[out] = float4(fa, 0.0);
        scratch[out + 1] = float4(ta, 0.0);
        scratch[out + 2] = float4(fb, 0.0);
        scratch[out + 3] = float4(tb, 0.0);
    }
    ledger.x = stored_sum;
    ledger.w = asfloat((has_state ? 1u : 0u) | (loaded ? 2u : 0u));
    scratch[params.ledger_base + i] = ledger;
}

// The forces of impactor candidate k on its chunk, and their reaction on the impactor.
void impactor_candidate_forces(uint k)
{
    uint at = params.cand_index + 3 * k;
    uint c = index[at];
    uint slot = index[at + 1];
    Impactor imp = impactors[index[at + 2]];
    float dt = params.dt;
    float3 f_sum = float3(0.0), t_sum = float3(0.0), imp_f = float3(0.0), imp_t = float3(0.0);
    float4 data = scratch[params.cand_base + 3 * k];
    if (imp.cand.z == 0)
    {
        float3 rel = world_diff(chunk_world(c), impactor_point(imp));
        if (!(length(rel) > imp.half.w + chunks[c].half.w))
        {
            Box ib = impactor_box(imp, float3(0.0), imp.half.xyz);
            Box b = chunk_box(c, rel);
            float kc = contact_stiffness(imp.mat.x, ib, chunks[c].cmat.x, b, b.center - ib.center);
            Box shrunk = impactor_shrunk(imp, imp.geom.y, ib);
            uint n = impactor_contact_count(imp, imp.geom.y, shrunk, b);
            float kp = imp.shape.x == 0.0 ? kc : kc / max(float(n), FACE_PAIR_POINTS);
            uint points = imp.shape.x == 0.0 ? 1 : n;
            float m = chunks[c].center.w;
            float m_red = m * imp.mat.z / (m + imp.mat.z);
            float mu = params.pair_friction >= 0.0 ? params.pair_friction : min(imp.mat.y, chunks[c].cmat.y);
            float3 v_imp = imp.velocity.xyz + imp.velocity_err.xyz;
            float3 vc;
            float3 wc;
            chunk_velocity(c, vc, wc);
            for (uint j = 0; n > 0 && j < impactor_slots(imp, b); j++)
            {
                float3 p;
                float3 nrm;
                float dep;
                if (!impactor_contact(imp, imp.geom.y, shrunk, b, j, p, nrm, dep))
                    continue;
                float3 v_chunk = vc + cross(wc, p - b.center);
                float3 v_i = v_imp + cross(imp.angular_velocity.xyz, p);
                float stored;
                float diss;
                float3 f = penalty_force(kp, m_red, mu, dep * imp.geom.x, nrm, v_chunk - v_i, dt, points, stored, diss);
                f_sum += f;
                t_sum += cross(p - b.center, f);
                imp_f -= f;
                imp_t -= cross(p, f);
                comp_add1(data.z, data.w, diss);
            }
        }
    }
    scratch[params.slot_base + 2 * slot] = float4(f_sum, 0.0);
    scratch[params.slot_base + 2 * slot + 1] = float4(t_sum, 0.0);
    scratch[params.cand_base + 3 * k] = data;
    scratch[params.cand_base + 3 * k + 1] = float4(imp_f, 0.0);
    scratch[params.cand_base + 3 * k + 2] = float4(imp_t, 0.0);
}

// A contact chunk outside its candidate budget stops the batch (the host re-plans).
void travel_check(uint c)
{
    ChunkStatic ch = chunks[c];
    if (ch.cinfo.z == 0)
        return;
    WorldPoint wp = chunk_world(c);
    float3 moved = ((wp.hi - ch.start_hi.xyz) + (wp.lo - ch.start_lo.xyz)) + wp.rel;
    if (length(moved) > ch.start_hi.w)
    {
        // Every writer stores the same bit: no atomics needed.
        islands[params.halt_index].info.z = islands[params.halt_index].info.z | STOP_NOW;
    }
}

[shader("compute")]
[numthreads(64, 1, 1)]
void contact_forces(uint3 id: SV_DispatchThreadID)
{
    uint i = id.x;
    if (stopped())
        return;
    if (i < params.pair_count)
        pair_contact(i);
    else if (i < params.pair_count + params.cand_count)
        impactor_candidate_forces(i - params.pair_count);
    else if (i < params.pair_count + params.cand_count + params.chunk_count)
        travel_check(i - params.pair_count - params.cand_count);
}

// Crush cap, first pass: each candidate's share of its impactor's elastic force.
[shader("compute")]
[numthreads(64, 1, 1)]
void impactor_shares(uint3 id: SV_DispatchThreadID)
{
    uint k = id.x;
    if (k >= params.cand_count || stopped())
        return;
    uint at = params.cand_index + 3 * k;
    uint c = index[at];
    Impactor imp = impactors[index[at + 2]];
    float total = 0.0;
    float ksum = 0.0;
    if (imp.cand.z == 0 && imp.crush.x > 0.0)
    {
        float3 rel = world_diff(chunk_world(c), impactor_point(imp));
        if (!(length(rel) > imp.half.w + chunks[c].half.w))
        {
            Box ib = impactor_box(imp, float3(0.0), imp.half.xyz);
            Box b = chunk_box(c, rel);
            float kc = contact_stiffness(imp.mat.x, ib, chunks[c].cmat.x, b, b.center - ib.center);
            Box shrunk = impactor_shrunk(imp, imp.crush.w, ib);
            uint n = impactor_contact_count(imp, imp.crush.w, shrunk, b);
            float kp = imp.shape.x == 0.0 ? kc : kc / max(float(n), FACE_PAIR_POINTS);
            for (uint j = 0; n > 0 && j < impactor_slots(imp, b); j++)
            {
                float3 p;
                float3 nrm;
                float dep;
                if (!impactor_contact(imp, imp.crush.w, shrunk, b, j, p, nrm, dep))
                    continue;
                total += kp * dep;
                ksum += kp;
            }
        }
    }
    float4 data = scratch[params.cand_base + 3 * k];
    scratch[params.cand_base + 3 * k] = float4(total, ksum, data.z, data.w);
}

// Crush cap, second pass (one group per impactor): the total, the cap, the factor the
// contacts use this substep.
[shader("compute")]
[numthreads(256, 1, 1)]
void impactor_crush(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint ii = group.x;
    uint tid = thread.x;
    if (ii >= params.impactor_count || stopped())
        return;
    Impactor imp = impactors[ii];
    float4 shares = float4(0.0);
    float4 unused = float4(0.0);
    for (uint k = imp.cand.x + tid; k < imp.cand.y; k += THREADS)
        shares += scratch[params.cand_base + 3 * k];
    group_sum2(tid, shares, unused);
    if (tid != 0 || imp.cand.z != 0)
        return;
    imp.geom = float4(1.0, imp.crush.w, 0.0, 0.0);
    float total = shares.x;
    if (imp.crush.x > 0.0 && imp.crush.z < imp.crush.y && total > imp.crush.x)
    {
        float extra = (total - imp.crush.x) / shares.y;
        imp.crush.w += extra;
        imp.crush.z += imp.crush.x * extra;
        comp_add1(imp.ledger.z, imp.ledger.w, imp.crush.x * extra);
        comp_add1(imp.ledger.x, imp.ledger.y, imp.crush.x * extra);
        imp.geom.x = imp.crush.x / total;
    }
    impactors[ii] = imp;
}

[shader("compute")]
[numthreads(256, 1, 1)]
void impactor_integrate(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint ii = group.x;
    uint tid = thread.x;
    if (ii >= params.impactor_count)
        return;
    Island sentinel = islands[params.halt_index];
    Impactor imp = impactors[ii];
    // cand.w: substeps integrated so far. Integrate through the substep of a split
    // (it completes), not past it; nothing after a re-plan stop.
    if (imp.cand.z != 0 || (sentinel.info.z & STOP_NOW) != 0 || (sentinel.info.y != 0 && imp.cand.w >= sentinel.info.y))
        return;
    // The contact reactions of the candidates (strided, then a tree).
    float4 rf = float4(0.0);
    float4 rt = float4(0.0);
    for (uint k = imp.cand.x + tid; k < imp.cand.y; k += THREADS)
    {
        rf += scratch[params.cand_base + 3 * k + 1];
        rt += scratch[params.cand_base + 3 * k + 2];
    }
    group_sum2(tid, rf, rt);
    if (tid != 0)
        return;
    float dt = params.dt;
    float3 load_f = float3(0.0);
    float3 load_t = float3(0.0);
    // The impactor on the ground (world.rs, after the chunk contacts).
    if (params.has_ground != 0)
    {
        Box ib = impactor_box(imp, float3(0.0), imp.half.xyz);
        float3 v_imp = imp.velocity.xyz + imp.velocity_err.xyz;
        float kc = contact_stiffness(params.ground_modulus, ib, imp.mat.x, ib, float3(0.0, 0.0, 1.0));
        float above = ((imp.position.z - params.ground_hi) + (imp.position_err.z - params.ground_lo));
        uint total_points = imp.shape.x == 0.0 ? 1 : SAMPLE_POINTS;
        float kp = kc / float(min(total_points, 5u));
        uint below = 0;
        for (uint s = 0; s < total_points; s++)
        {
            float3 p = imp.shape.x == 0.0 ? float3(0.0, 0.0, -imp.shape.y) : sample_point(ib, s);
            if (above + p.z < 0.0)
                below++;
        }
        for (uint s = 0; s < total_points; s++)
        {
            float3 p = imp.shape.x == 0.0 ? float3(0.0, 0.0, -imp.shape.y) : sample_point(ib, s);
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
    load_f = rf.xyz + load_f;
    load_t = rt.xyz + load_t;
    // Rigid motion (world.rs `substep`).
    float m = imp.mat.z;
    float3 vel = imp.velocity.xyz;
    float3 vel_err = imp.velocity_err.xyz;
    comp_add(vel, vel_err, (load_f / m + params.gravity.xyz) * dt);
    Quat q = quat_of(imp.rotation);
    float3 l = world_mul(q, imp.inertia0, imp.inertia1, imp.inertia2, imp.angular_velocity.xyz) + load_t * dt;
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
    imp.cand.w += 1;
    // The next substep's contacts see the crush depth reached, at full force unless
    // the crush pass says otherwise.
    imp.geom = float4(1.0, imp.crush.w, 0.0, 0.0);
    impactors[ii] = imp;
    // Per-substep record for the impactor probes: velocity, position.
    uint k = imp.cand.w - 1 - params.step_start;
    if (k < params.record_stride)
    {
        uint at = params.record_base + 2 * (ii * params.record_stride + k);
        scratch[at] = float4(vel + vel_err, 0.0);
        scratch[at + 1] = float4(pos + pos_err, 0.0);
    }
}

// ------------------------------------------------------------------ loads

static const uint LOAD_WORLD_FORCE = 0;   // world-fixed direction, lever arm in the body frame
static const uint LOAD_FACE = 1;          // body-fixed outward normal, -p(t) * area, lever arm
static const uint LOAD_REPLACEMENT = 2;   // body-frame force and moment ramping to zero

static const uint FN_CONSTANT = 0;
static const uint FN_RAMP = 1;
static const uint FN_HALF_SINE = 2;
static const uint FN_FRIEDLANDER = 3;
static const uint FN_TABLE = 4;
static const uint FN_BLAST = 5;
static const uint FN_REPLACEMENT = 6;

static const uint PROBE_DISPLACEMENT = 0;
static const uint PROBE_VELOCITY = 1;
static const uint PROBE_SECTION_BOND = 2;
static const uint PROBE_REACTION = 3;

// Time since a function's origin (compensated pair) at substep k of the host's step.
float time_since(float4 origin, uint k, float dt)
{
    return ((params.t_hi - origin.x) + (params.t_lo - origin.y)) + float(k) * dt;
}

float table_eval(uint offset, uint count, float tau)
{
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
        if (tau < 0.0)
            return 0.0;
        float sn = tau / p.x;
        float shape = (sn < 0.0 || sn > 1.0) ? 0.0 : (1.0 - sn) * exp(-p.y * sn);
        float clearing = origin.w;
        float relax = clearing > 0.0 ? max(1.0 - tau / clearing, 0.0) : 0.0;
        return (p.w + (p.z - p.w) * relax) * shape;
    }
    if (p.x <= 0.0)
        return 0.0;
    return clamp(1.0 - tau / p.x, 0.0, 1.0);
}

// Ground contact of chunk c (world.rs `apply_contacts`): its box's sample points below
// the ground, as force and torque about the chunk centre (world).
void ground_contact(uint c, bool account, inout float3 f, inout float3 t)
{
    ChunkStatic ch = chunks[c];
    WorldPoint wp = chunk_world(c);
    float above = ((wp.hi.z - params.ground_hi) + (wp.lo.z - params.ground_lo)) + wp.rel.z;
    if (above - ch.half.w > 0.0)
        return;
    Box b = chunk_box(c, float3(0.0));
    float kc = contact_stiffness(params.ground_modulus, b, ch.cmat.x, b, float3(0.0, 0.0, 1.0));
    uint samples = sample_count(b);
    uint n = 0;
    for (uint s = 0; s < samples; s++)
        if (above + sample_point(b, s).z < 0.0)
            n++;
    if (n == 0)
        return;
    float3 vc;
    float3 wc;
    chunk_velocity(c, vc, wc);
    float4 ledger = scratch[params.ledger_base + params.pair_count + c];
    for (uint s = 0; s < samples; s++)
    {
        float3 p = sample_point(b, s);
        if (!(above + p.z < 0.0))
            continue;
        float depth = -(above + p.z);
        float3 v = vc + cross(wc, p);
        float stored;
        float diss;
        float3 g = penalty_force(kc / float(max(n, 5u)), ch.center.w, params.ground_friction, depth, float3(0.0, 0.0, 1.0), v, params.dt, n, stored, diss);
        f += g;
        t += cross(p, g);
        comp_add1(ledger.y, ledger.z, diss);
    }
    if (account)
        scratch[params.ledger_base + params.pair_count + c] = ledger;
}

// The external (non-gravity) load on chunk c at substep k, world frame (force, torque
// about the chunk centre), in the order the reference adds it: scripted loads, then
// contacts (impactors, ground, chunk pairs). `account` books the ground dissipation
// (once per substep).
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
    if (contact && ch.cinfo.z != 0)
    {
        // The chunk's contact loads, summed by segments (`contact_sums`), in order.
        for (uint g = ch.cinfo.x; g < ch.cinfo.y; g++)
        {
            f += scratch[params.seg_base + 2 * g].xyz;
            t += scratch[params.seg_base + 2 * g + 1].xyz;
        }
    }
}

// The contact loads of a chunk in the reference's order (impactors, ground, chunk
// pairs), summed in segments of a few entries, one thread each: a chunk in a pile can
// have hundreds of candidates, too long a chain for one thread.
[shader("compute")]
[numthreads(64, 1, 1)]
void contact_sums(uint3 id: SV_DispatchThreadID)
{
    uint g = id.x;
    if (g >= params.seg_count || stopped())
        return;
    uint c = index[params.seg_index + 3 * g];
    uint begin = index[params.seg_index + 3 * g + 1];
    uint end = index[params.seg_index + 3 * g + 2];
    float3 f = float3(0.0);
    float3 t = float3(0.0);
    for (uint e = begin; e < end; e++)
    {
        uint entry = index[e];
        if (entry == GROUND_ENTRY)
        {
            ground_contact(c, true, f, t);
            continue;
        }
        f += scratch[params.slot_base + 2 * entry].xyz;
        t += scratch[params.slot_base + 2 * entry + 1].xyz;
    }
    scratch[params.seg_base + 2 * g] = float4(f, 0.0);
    scratch[params.seg_base + 2 * g + 1] = float4(t, 0.0);
}

// ------------------------------------------------------------------ islands

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

// Returns whether the bond disconnected.
bool bond_update(uint i, float dt, bool fracture, uint abs_step)
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
    float3 f = to_body(b, q_lin);
    float3 m = to_body(b, q_ang);
    Measures em = resp.measures;
    scratch[3 * i + 0] = float4(f, max(em.tension, em.compression));
    scratch[3 * i + 1] = float4(m + cross(ra, f), 0.0);
    scratch[3 * i + 2] = float4(-m + cross(rb, -f), 0.0);
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
        bd.events.z = abs_step;
    bd.js = resp.state;
    bond_dyn[i] = bd;
    return resp.disconnected;
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

// The external (non-gravity) load of chunk c this substep (world.rs `loads`), for the
// host's settle, wake and quasi-static solves: the last substep's, and the frame's sum.
void record_chunk_load(uint c, float3 f, float3 t)
{
    if (params.solve_mode == MODE_EXPLICIT)
        return;
    scratch[params.cload_base + 2 * c] = float4(f, 0.0);
    scratch[params.cload_base + 2 * c + 1] = float4(t, 0.0);
    scratch[params.cframe_base + 2 * c] = float4(scratch[params.cframe_base + 2 * c].xyz + f, 0.0);
    scratch[params.cframe_base + 2 * c + 1] = float4(scratch[params.cframe_base + 2 * c + 1].xyz + t, 0.0);
}

// A settled chunk this substep: its external load recorded, its norm returned
// (world.rs `cluster_load_norm` term).
float settled_chunk_load(uint c, Quat rot, uint k, float dt, bool contact)
{
    ChunkStatic ch = chunks[c];
    float3 f;
    float3 t;
    chunk_external(c, ch, rot, k, dt, contact, f, t);
    record_chunk_load(c, f, t);
    return length(f);
}

void chunk_update(uint c, Island isl, Rigid rg, float dt, bool rml, uint step, bool contact, inout float work, inout float work_err)
{
    ChunkStatic ch = chunks[c];
    float3 fi = float3(0.0);
    float3 mi = float3(0.0);
    float peak = 0.0;
    for (uint e = index[c]; e < index[c + 1]; e++)
    {
        uint entry = index[e];
        uint bond = entry >> 1;
        float4 fa = scratch[3 * bond];
        if ((entry & 1) == 0)
        {
            fi += fa.xyz;
            mi += scratch[3 * bond + 1].xyz;
        }
        else
        {
            fi += -fa.xyz;
            mi += scratch[3 * bond + 2].xyz;
        }
        peak = max(peak, fa.w);
    }
    float3 u = state[4 * c].xyz;
    float3 th = state[4 * c + 1].xyz;
    float3 v = state[4 * c + 2].xyz;
    float3 w = state[4 * c + 3].xyz;
    float mass = ch.center.w;
    // Frame loads (solver.rs `frame_loads`).
    float3 r_world = rotate(rg.rot, ch.center.xyz + u - isl.com.xyz);
    float3 f_load;
    float3 t_load;
    chunk_external(c, ch, rg.rot, step, dt, contact, f_load, t_load);
    record_chunk_load(c, f_load, t_load);
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
    // Replacement loads (body frame), evaluated at t + dt as `frame_loads` is.
    for (uint term = ch.load_range.x; term < ch.load_range.y; term++)
    {
        if (asuint(loads[5 * term]).y != LOAD_REPLACEMENT)
            continue;
        float kf = eval_function(term, step, dt, dt);
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
    uint at = params.probe_base * 4 + slot * params.probe_stride + k;
    float4 v = scratch[at / 4];
    v[at % 4] = value;
    scratch[at / 4] = v;
}

void record_probes(Island isl, Rigid rg, uint k)
{
    for (uint at = isl.probes.x; at < isl.probes.y; at += 4)
    {
        uint4 info = asuint(loads[at]);
        float4 a = loads[at + 1];
        float4 b = loads[at + 2];
        float4 c4 = loads[at + 3];
        uint kind = info.x;
        uint i = info.y;
        float value = 0.0;
        if (kind == PROBE_DISPLACEMENT)
        {
            ChunkStatic ch = chunks[i];
            float3 x = ((rg.pos - b.xyz) + (rg.pos_err - c4.xyz)) + rotate(rg.rot, ch.center.xyz + state[4 * i].xyz);
            value = dot(x, a.xyz);
        }
        else if (kind == PROBE_VELOCITY)
        {
            ChunkStatic ch = chunks[i];
            float3 r = rotate(rg.rot, ch.center.xyz + state[4 * i].xyz - isl.com.xyz);
            float3 v = (rg.vel + rg.vel_err) + cross(rg.w, r) + rotate(rg.rot, state[4 * i + 2].xyz);
            value = dot(v, a.xyz);
        }
        else if (kind == PROBE_SECTION_BOND)
        {
            float3 f = scratch[3 * i].xyz;
            float3 mc = info.z == 0 ? scratch[3 * i + 1].xyz : scratch[3 * i + 2].xyz;
            float3 fc = info.z == 0 ? f : -f;
            value = dot(fc, a.xyz) + dot(mc, b.xyz);
        }
        else
        {
            float3 reaction = float3(state[4 * i + 1].w, state[4 * i + 2].w, state[4 * i + 3].w);
            value = dot(rotate(rg.rot, reaction), a.xyz);
        }
        write_probe(info.w, k, value);
    }
}

// ------------------------------------------------------------------ island phases
//
// Shared by the narrow kernel (one threadgroup per island, whole segments) and the wide
// kernels (one island over many threadgroups, a round of dispatches per substep): the
// same per-chunk terms, summed in a fixed order by each.

Rigid rigid_of(Island isl)
{
    Rigid rg;
    rg.rot = quat_of(isl.rotation);
    rg.pos = isl.position.xyz;
    rg.pos_err = isl.position_err.xyz;
    rg.vel = isl.velocity.xyz;
    rg.vel_err = isl.velocity_err.xyz;
    rg.w = isl.angular_velocity.xyz;
    rg.a = float3(0.0);
    rg.alpha = float3(0.0);
    return rg;
}

// Chunk c's share of the net load on its free cluster (solver.rs `rigid_acceleration`,
// `net_load`): force and torque about the cluster's centre of mass, world frame.
void net_load(uint c, Island isl, Rigid rg, uint k, float dt, bool contact, inout float3 f, inout float3 t)
{
    ChunkStatic ch = chunks[c];
    float3 fl;
    float3 tl;
    chunk_external(c, ch, rg.rot, k, dt, contact, fl, tl);
    float3 fc = fl + params.gravity.xyz * ch.center.w;
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

// Rigid acceleration from the net load (solver.rs `rigid_acceleration`).
void rigid_acceleration(Island isl, inout Rigid rg, float3 f, float3 t)
{
    float3 iw_w = world_mul(rg.rot, isl.inertia0, isl.inertia1, isl.inertia2, rg.w);
    rg.a = f / isl.com.w;
    rg.alpha = world_mul(rg.rot, isl.inv0, isl.inv1, isl.inv2, t - cross(rg.w, iw_w));
}

// solver.rs `integrate_rigid`.
void integrate_rigid(Island isl, inout Rigid rg, float dt)
{
    float3 iw_w = world_mul(rg.rot, isl.inertia0, isl.inertia1, isl.inertia2, rg.w);
    float3 torque = world_mul(rg.rot, isl.inertia0, isl.inertia1, isl.inertia2, rg.alpha) + cross(rg.w, iw_w);
    float3 l = iw_w + torque * dt;
    comp_add(rg.vel, rg.vel_err, rg.a * dt);
    float3 vel = rg.vel + rg.vel_err;
    float3 w_mid = world_mul(rg.rot, isl.inv0, isl.inv1, isl.inv2, l);
    Quat rot1 = integrate_rotation(rg.rot, w_mid, dt);
    float3 delta = vel * dt + (rotate(rg.rot, isl.com.xyz) - rotate(rot1, isl.com.xyz));
    comp_add(rg.pos, rg.pos_err, delta);
    rg.rot = rot1;
    rg.w = world_mul(rg.rot, isl.inv0, isl.inv1, isl.inv2, l);
}

// Drift removal (solver.rs `remove_rigid_drift`, deformation weights), per chunk: the
// weighted translation and velocity sums, ...
void drift_moments(uint c, inout float3 tu, inout float3 pv)
{
    ChunkStatic ch = chunks[c];
    float m = ch.center.w * ch.scale.x;
    tu += state[4 * c].xyz * m;
    pv += state[4 * c + 2].xyz * m;
}

// ... the weighted angular sums about the weighted centre once those are removed, ...
void drift_angular(uint c, float3 wcom, float3 tr, float3 dv, inout float3 lu, inout float3 lv)
{
    ChunkStatic ch = chunks[c];
    float3 r = ch.center.xyz - wcom;
    float kw = ch.scale.x;
    lu += (cross(r, state[4 * c].xyz - tr) * ch.center.w + rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, state[4 * c + 1].xyz)) * kw;
    lv += (cross(r, state[4 * c + 2].xyz - dv) * ch.center.w + rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, state[4 * c + 3].xyz)) * kw;
}

// ... the correction of a chunk's hidden state, ...
void drift_apply(uint c, float3 wcom, float3 tr, float3 phi, float3 dv, float3 dw)
{
    float3 r = chunks[c].center.xyz - wcom;
    state[4 * c] = float4(state[4 * c].xyz - (tr + cross(phi, r)), state[4 * c].w);
    state[4 * c + 1] = float4(state[4 * c + 1].xyz - phi, state[4 * c + 1].w);
    state[4 * c + 2] = float4(state[4 * c + 2].xyz - (dv + cross(dw, r)), state[4 * c + 2].w);
    state[4 * c + 3] = float4(state[4 * c + 3].xyz - dw, state[4 * c + 3].w);
}

// ... and the drift moved into the cluster's rigid motion.
void drift_rigid(Island isl, inout Rigid rg, float3 tr, float3 phi, float3 dv, float3 dw)
{
    float3 wcom = isl.wcom.xyz;
    Quat rot = rg.rot;
    comp_add(rg.pos, rg.pos_err, rotate(rot, tr - cross(phi, wcom)));
    rg.rot = normalized(quat_mul(rot, from_axis_angle(phi, length(phi))));
    comp_add(rg.vel, rg.vel_err, rotate(rot, dv + cross(dw, isl.com.xyz - wcom)));
    rg.w += rotate(rot, dw);
}

// Batch control for a contact island: stopped for a re-plan, or past the substep at
// which some contact island split.
bool contact_stopped(Island isl)
{
    Island sentinel = islands[params.halt_index];
    return (sentinel.info.z & STOP_NOW) != 0 || (sentinel.info.y != 0 && sentinel.info.y <= isl.info.w);
}

// A contact island split after substep `at` (absolute): that substep completes in every
// contact island, then the batch stops.
void contact_split_at(uint at)
{
    uint previous = islands[params.halt_index].info.y;
    islands[params.halt_index].info.y = previous == 0 ? at : min(previous, at);
}

// ------------------------------------------------------------------ narrow islands

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
    bool settled = (isl.info.x & ISLAND_SETTLED) != 0;
    bool woke = false;
    // Batch control: read once, uniformly for the whole group. Wide islands run in
    // their own kernels.
    if (tid == 0)
    {
        uint run = 1;
        if (contact_island != (params.contact_mode == 1) || (isl.info.x & ISLAND_WIDE) != 0)
            run = 0;
        if (contact_island && contact_stopped(isl))
            run = 0;
        g_run = run;
        g_halt = 0;
    }
    GroupMemoryBarrierWithGroupSync();
    uint steps = ((isl.info.z & ISLAND_HALTED) != 0 || g_run == 0) ? 0 : min(isl.info.y, params.max_steps);
    float dt = params.dt;
    bool fracture = params.fracture != 0;
    bool rml = params.rigid_motion_loads != 0;
    Rigid rg = rigid_of(isl);

    uint done = 0;
    float work = 0.0;
    float work_err = 0.0;
    for (uint s = 0; s < steps; s++)
    {
        uint abs_step = isl.info.w + s + 1;
        uint k = abs_step - 1 - params.step_start; // substeps since the host's step began
        // 0. A settled island (world.rs `wake_loaded_clusters`): its loads recorded;
        // it wakes, and takes this substep explicitly, when they changed.
        if (settled)
        {
            float3 norm = float3(0.0);
            float3 unused0 = float3(0.0);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
                norm.x += settled_chunk_load(c, rg.rot, k, dt, contact_island);
            group_sum3(tid, norm, unused0);
            if (params.solve_mode == MODE_ADAPTIVE && abs(norm.x - isl.energy.z) > isl.energy.w)
            {
                settled = false;
                woke = true;
            }
        }
        // 1. Rigid acceleration of a free cluster.
        if (!anchored)
        {
            float3 f = float3(0.0);
            float3 t = float3(0.0);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
                net_load(c, isl, rg, k, dt, contact_island, f, t);
            group_sum3(tid, f, t);
            rigid_acceleration(isl, rg, f, t);
        }
        if (settled)
        {
            // Rigid motion only (solver.rs `advance_rigid_only`).
            if (free_motion)
                integrate_rigid(isl, rg, dt);
            if (tid == 0 && isl.probes.y > isl.probes.x)
                record_probes(isl, rg, k);
            done = s + 1;
            continue;
        }
        // 2. Bonds.
        for (uint i = isl.range.z + tid; i < isl.range.w; i += THREADS)
            if (bond_update(i, dt, fracture, abs_step))
                g_halt = 1;
        AllMemoryBarrierWithGroupSync();
        // 3. Chunks.
        for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
            chunk_update(c, isl, rg, dt, rml, k, contact_island, work, work_err);
        AllMemoryBarrierWithGroupSync();
        // 4. Rigid integration.
        if (free_motion)
            integrate_rigid(isl, rg, dt);
        if (!anchored)
        {
            // 5. Drift removal.
            float3 wcom = isl.wcom.xyz;
            float3 tu = float3(0.0);
            float3 pv = float3(0.0);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
                drift_moments(c, tu, pv);
            group_sum3(tid, tu, pv);
            float3 tr = tu / isl.wcom.w;
            float3 dv = pv / isl.wcom.w;
            float3 lu = float3(0.0);
            float3 lv = float3(0.0);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
                drift_angular(c, wcom, tr, dv, lu, lv);
            group_sum3(tid, lu, lv);
            float3 phi = rows_mul(isl.winv0, isl.winv1, isl.winv2, lu);
            float3 dw = rows_mul(isl.winv0, isl.winv1, isl.winv2, lv);
            for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
                drift_apply(c, wcom, tr, phi, dv, dw);
            if (!driven)
                drift_rigid(isl, rg, tr, phi, dv, dw);
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
    group_sum3(tid, wsum, unused);
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
            contact_split_at(isl.info.w + done);
        comp_add1(isl.energy.x, isl.energy.y, wsum.x);
        isl.energy.y += wsum.y;
        isl.info.w += done;
        if (g_halt != 0)
            isl.info.z |= ISLAND_HALTED;
        if (woke)
        {
            isl.info.x &= ~ISLAND_SETTLED;
            isl.info.z |= ISLAND_WOKE;
        }
        islands[group.x] = isl;
    }
}

// ------------------------------------------------------------------ wide islands
//
// An island above the host's size threshold spreads over many threadgroups, one round
// of five dispatches per substep (any order of rounds is a valid substep sequence):
//   wide_bonds   bond groups: the joint law; chunk groups: net-load partial sums;
//   wide_chunks  chunk groups: rigid acceleration (from the partials), chunk updates,
//                external-work and drift-moment partials;
//   wide_drift   chunk groups: the angular drift partials;
//   wide_rigid   chunk groups: the drift correction of their chunks; the island's
//                first group also moves the rigid frame;
//   wide_end     the island's first group: substep bookkeeping, work, probes.
// Partials: 8 float4 per chunk group at `wide_base` (net force, net torque, drift
// translation, momentum, angular drift (2), work, -). Each group sums its island's
// partials in group order, so every group and every run gets identical sums.

static const uint ISLAND_HALT_PENDING = 2;   // status: a bond disconnected this substep

struct WideGroup
{
    uint island;
    uint begin;
    uint end;
    uint first; // chunk groups: the island's first chunk group (partial slot)
};

WideGroup wide_group(uint table, uint g)
{
    WideGroup w;
    w.island = index[table + 4 * g];
    w.begin = index[table + 4 * g + 1];
    w.end = index[table + 4 * g + 2];
    w.first = index[table + 4 * g + 3];
    return w;
}

// Whether the island runs this substep (uniform over the round: only `wide_end` changes
// what this reads).
bool wide_runs(Island isl)
{
    if ((isl.info.z & ISLAND_HALTED) != 0 || isl.info.y == 0)
        return false;
    return (isl.info.x & ISLAND_CONTACT) == 0 || !contact_stopped(isl);
}

groupshared uint g_wide_run;

// The island's partial pair `p` summed over its chunk groups (fixed order).
void wide_partials(uint tid, uint first, uint count, uint p, out float3 a, out float3 b)
{
    float4 x = float4(0.0);
    float4 y = float4(0.0);
    for (uint s = tid; s < count; s += THREADS)
    {
        x += scratch[params.wide_base + 8 * (first + s) + p];
        y += scratch[params.wide_base + 8 * (first + s) + p + 1];
    }
    group_sum2(tid, x, y);
    a = x.xyz;
    b = y.xyz;
}

void wide_store(uint slot, uint p, float3 a, float3 b)
{
    scratch[params.wide_base + 8 * slot + p] = float4(a, 0.0);
    scratch[params.wide_base + 8 * slot + p + 1] = float4(b, 0.0);
}

// Every group reads the island's state once; the result is uniform over the group.
bool wide_enter(uint tid, Island isl)
{
    if (tid == 0)
        g_wide_run = wide_runs(isl) ? 1 : 0;
    GroupMemoryBarrierWithGroupSync();
    return g_wide_run != 0;
}

uint wide_step(Island isl)
{
    return isl.info.w - params.step_start;
}

// A settled wide island this substep (the island's first group, before the round): its
// loads recorded, and the wake check.
[shader("compute")]
[numthreads(256, 1, 1)]
void wide_wake(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    WideGroup wg = wide_group(params.wide_chunk_table, group.x);
    if (group.x != wg.first)
        return;
    Island isl = islands[wg.island];
    if ((isl.info.x & ISLAND_SETTLED) == 0 || !wide_enter(tid, isl))
        return;
    Quat rot = quat_of(isl.rotation);
    bool contact = (isl.info.x & ISLAND_CONTACT) != 0;
    float3 norm = float3(0.0);
    float3 unused = float3(0.0);
    for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
        norm.x += settled_chunk_load(c, rot, wide_step(isl), params.dt, contact);
    group_sum3(tid, norm, unused);
    if (tid == 0 && params.solve_mode == MODE_ADAPTIVE && abs(norm.x - isl.energy.z) > isl.energy.w)
    {
        islands[wg.island].info.x = isl.info.x & ~ISLAND_SETTLED;
        islands[wg.island].info.z = isl.info.z | ISLAND_WOKE;
    }
}

[shader("compute")]
[numthreads(256, 1, 1)]
void wide_bonds(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    bool bond_group = group.x < params.wide_bond_groups;
    WideGroup wg = bond_group ? wide_group(params.wide_bond_table, group.x) : wide_group(params.wide_chunk_table, group.x - params.wide_bond_groups);
    Island isl = islands[wg.island];
    if (!wide_enter(tid, isl))
        return;
    uint k = wide_step(isl);
    if (bond_group)
    {
        if ((isl.info.x & ISLAND_SETTLED) != 0)
            return;
        uint i = wg.begin + tid;
        if (i < wg.end && bond_update(i, params.dt, params.fracture != 0, isl.info.w + 1))
            islands[wg.island].info.z = isl.info.z | ISLAND_HALT_PENDING;
        return;
    }
    if ((isl.info.x & ISLAND_ANCHORED) != 0)
        return;
    float3 f = float3(0.0);
    float3 t = float3(0.0);
    uint c = wg.begin + tid;
    if (c < wg.end)
        net_load(c, isl, rigid_of(isl), k, params.dt, (isl.info.x & ISLAND_CONTACT) != 0, f, t);
    group_sum3(tid, f, t);
    if (tid == 0)
        wide_store(group.x - params.wide_bond_groups, 0, f, t);
}

// The island's rigid frame at the substep start with its acceleration.
Rigid wide_rigid_frame(uint tid, Island isl, WideGroup wg)
{
    Rigid rg = rigid_of(isl);
    if ((isl.info.x & ISLAND_ANCHORED) == 0)
    {
        float3 f;
        float3 t;
        wide_partials(tid, wg.first, isl.done.z, 0, f, t);
        rigid_acceleration(isl, rg, f, t);
    }
    return rg;
}

[shader("compute")]
[numthreads(256, 1, 1)]
void wide_chunks(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    WideGroup wg = wide_group(params.wide_chunk_table, group.x);
    Island isl = islands[wg.island];
    if (!wide_enter(tid, isl))
        return;
    bool anchored = (isl.info.x & ISLAND_ANCHORED) != 0;
    if ((isl.info.x & ISLAND_SETTLED) != 0)
    {
        // Rigid motion only; its loads were recorded by `wide_wake`.
        if (tid == 0)
            scratch[params.wide_base + 8 * group.x + 6] = float4(0.0);
        return;
    }
    Rigid rg = wide_rigid_frame(tid, isl, wg);
    float work = 0.0;
    float work_err = 0.0;
    float3 tu = float3(0.0);
    float3 pv = float3(0.0);
    uint c = wg.begin + tid;
    if (c < wg.end)
    {
        chunk_update(c, isl, rg, params.dt, params.rigid_motion_loads != 0, wide_step(isl), (isl.info.x & ISLAND_CONTACT) != 0, work, work_err);
        if (!anchored)
            drift_moments(c, tu, pv);
    }
    float3 wsum = float3(work, work_err, 0.0);
    float3 unused = float3(0.0);
    group_sum3(tid, wsum, unused);
    if (!anchored)
        group_sum3(tid, tu, pv);
    if (tid == 0)
    {
        scratch[params.wide_base + 8 * group.x + 6] = float4(wsum, 0.0);
        if (!anchored)
            wide_store(group.x, 2, tu, pv);
    }
}

[shader("compute")]
[numthreads(256, 1, 1)]
void wide_drift(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    WideGroup wg = wide_group(params.wide_chunk_table, group.x);
    Island isl = islands[wg.island];
    if ((isl.info.x & (ISLAND_ANCHORED | ISLAND_SETTLED)) != 0 || !wide_enter(tid, isl))
        return;
    float3 tu;
    float3 pv;
    wide_partials(tid, wg.first, isl.done.z, 2, tu, pv);
    float3 tr = tu / isl.wcom.w;
    float3 dv = pv / isl.wcom.w;
    float3 lu = float3(0.0);
    float3 lv = float3(0.0);
    uint c = wg.begin + tid;
    if (c < wg.end)
        drift_angular(c, isl.wcom.xyz, tr, dv, lu, lv);
    group_sum3(tid, lu, lv);
    if (tid == 0)
        wide_store(group.x, 4, lu, lv);
}

[shader("compute")]
[numthreads(256, 1, 1)]
void wide_rigid(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    WideGroup wg = wide_group(params.wide_chunk_table, group.x);
    Island isl = islands[wg.island];
    if ((isl.info.x & ISLAND_ANCHORED) != 0 || !wide_enter(tid, isl))
        return;
    if ((isl.info.x & ISLAND_SETTLED) != 0)
    {
        // Rigid motion only (solver.rs `advance_rigid_only`).
        if (group.x != wg.first)
            return;
        Rigid rs = wide_rigid_frame(tid, isl, wg);
        if (tid != 0 || (isl.info.x & ISLAND_DRIVEN) != 0)
            return;
        integrate_rigid(isl, rs, params.dt);
        islands[wg.island].rotation = quat_vec(rs.rot);
        islands[wg.island].position = float4(rs.pos, 0.0);
        islands[wg.island].position_err = float4(rs.pos_err, 0.0);
        islands[wg.island].velocity = float4(rs.vel, 0.0);
        islands[wg.island].velocity_err = float4(rs.vel_err, 0.0);
        islands[wg.island].angular_velocity = float4(rs.w, 0.0);
        return;
    }
    float3 tu;
    float3 pv;
    wide_partials(tid, wg.first, isl.done.z, 2, tu, pv);
    float3 lu;
    float3 lv;
    wide_partials(tid, wg.first, isl.done.z, 4, lu, lv);
    float3 tr = tu / isl.wcom.w;
    float3 dv = pv / isl.wcom.w;
    float3 phi = rows_mul(isl.winv0, isl.winv1, isl.winv2, lu);
    float3 dw = rows_mul(isl.winv0, isl.winv1, isl.winv2, lv);
    uint c = wg.begin + tid;
    if (c < wg.end)
        drift_apply(c, isl.wcom.xyz, tr, phi, dv, dw);
    // The island's first group moves the frame (others read only static island data
    // and the partials from here on).
    if (group.x != wg.first)
        return;
    Rigid rg = wide_rigid_frame(tid, isl, wg);
    if (tid != 0)
        return;
    bool driven = (isl.info.x & ISLAND_DRIVEN) != 0;
    if (!driven)
    {
        integrate_rigid(isl, rg, params.dt);
        drift_rigid(isl, rg, tr, phi, dv, dw);
    }
    islands[wg.island].rotation = quat_vec(rg.rot);
    islands[wg.island].position = float4(rg.pos, 0.0);
    islands[wg.island].position_err = float4(rg.pos_err, 0.0);
    islands[wg.island].velocity = float4(rg.vel, 0.0);
    islands[wg.island].velocity_err = float4(rg.vel_err, 0.0);
    islands[wg.island].angular_velocity = float4(rg.w, 0.0);
}

[shader("compute")]
[numthreads(256, 1, 1)]
void wide_end(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    WideGroup wg = wide_group(params.wide_chunk_table, group.x);
    if (group.x != wg.first)
        return;
    Island isl = islands[wg.island];
    if (!wide_enter(tid, isl))
        return;
    float3 work;
    float3 unused;
    wide_partials(tid, wg.first, isl.done.z, 6, work, unused);
    if (tid != 0)
        return;
    uint k = wide_step(isl);
    if (isl.probes.y > isl.probes.x)
        record_probes(isl, rigid_of(isl), k);
    bool halt = (isl.info.z & ISLAND_HALT_PENDING) != 0;
    if (halt && (isl.info.x & ISLAND_CONTACT) != 0)
        contact_split_at(isl.info.w + 1);
    comp_add1(isl.energy.x, isl.energy.y, work.x);
    isl.energy.y += work.y;
    isl.done.x += 1;
    isl.info.y -= 1;
    isl.info.w += 1;
    if (halt)
        isl.info.z = (isl.info.z & ~ISLAND_HALT_PENDING) | ISLAND_HALTED;
    islands[wg.island] = isl;
}

// ------------------------------------------------------------------ static equilibrium
//
// statics.rs `equilibrate` for the islands flagged ISLAND_SOLVE, one threadgroup each:
// a modified Newton iteration on the true residual (joint law at dt = 0, no history),
// each correction solving the secant system `K x = r` by conjugate gradients with the
// 6x6 block-Jacobi preconditioner; free islands use inertia relief (loads made
// self-equilibrated, rigid modes projected out mass-orthogonally). The host supplies
// the external loads (statics.rs `static_loads`, body frame) per chunk.
//
// Scratch from `statics_base`: per chunk 21 float4 (external load 2, x 2, r 2, z 2,
// p 2, ap 2, inverse block 9); then per bond its secant stiffness (2 float4); then per
// island its result (residual, Newton iterations, CG iterations, converged).

static const uint ISLAND_SOLVE = 8;      // status: solve this island to equilibrium
static const uint STATICS_PER_CHUNK = 23; // ... then the displacement's low parts (u, theta)
static const float STATICS_FLOOR = 1e-3;

uint sv(uint c, uint slot)
{
    return params.statics_base + STATICS_PER_CHUNK * c + slot;
}

uint statics_bond_slot(uint i)
{
    return params.statics_base + STATICS_PER_CHUNK * params.chunk_count + 2 * i;
}

uint statics_result_slot(uint island)
{
    return params.statics_base + STATICS_PER_CHUNK * params.chunk_count + 2 * params.statics_bonds + island;
}

// Which of a chunk's 6 DOFs its support holds: bit d.
uint fixed_mask(uint c)
{
    uint support = chunks[c].info.x;
    return support == SUPPORT_FIXED ? 0x3fu : (support == SUPPORT_PINNED ? 0x7u : 0u);
}

float comp6(float4 lin, float4 ang, uint d)
{
    return d < 3 ? lin[d] : ang[d - 3];
}

// Zero the held DOFs of a 6-vector (or set them to `keep`'s).
void hold(uint mask, inout float4 lin, inout float4 ang, float4 keep_lin, float4 keep_ang)
{
    for (uint d = 0; d < 3; d++)
    {
        if ((mask & (1u << d)) != 0)
            lin[d] = keep_lin[d];
        if ((mask & (1u << (d + 3))) != 0)
            ang[d] = keep_ang[d];
    }
}

// The bond's local deformation from the chunk 6-vectors at `slot` (x, or u/theta).
void bond_kinematics(BondStatic b, float3 ua, float3 ta, float3 ub, float3 tb, out float3 d_lin, out float3 d_ang)
{
    d_lin = to_local(b, (ub + cross(tb, b.rb.xyz)) - (ua + cross(ta, b.ra.xyz)));
    d_ang = to_local(b, tb - ta);
}

// Chunk loads of a local generalized force on the bond (bond.rs `chunk_loads`), in the
// explicit kernel's slots (force on a, moment on a, moment on b; force on b = -force).
void write_bond_loads(uint i, BondStatic b, float3 q_lin, float3 q_ang, float peak)
{
    float3 f = to_body(b, q_lin);
    float3 m = to_body(b, q_ang);
    scratch[3 * i + 0] = float4(f, peak);
    scratch[3 * i + 1] = float4(m + cross(b.ra.xyz, f), 0.0);
    scratch[3 * i + 2] = float4(-m + cross(b.rb.xyz, -f), 0.0);
}

// Gather a chunk's bond loads (fixed CSR order).
void gather_loads(uint c, out float3 fi, out float3 mi)
{
    fi = float3(0.0);
    mi = float3(0.0);
    for (uint e = index[c]; e < index[c + 1]; e++)
    {
        uint entry = index[e];
        uint bond = entry >> 1;
        if ((entry & 1) == 0)
        {
            fi += scratch[3 * bond].xyz;
            mi += scratch[3 * bond + 1].xyz;
        }
        else
        {
            fi -= scratch[3 * bond].xyz;
            mi += scratch[3 * bond + 2].xyz;
        }
    }
}

// The bond's deformation from the compensated displacements of a static solve:
// displacements build up along a structure to far more than the bond deformations
// they differ into, so the high parts are differenced first (nearly exact), then the
// low parts.
void static_kinematics(BondStatic b, out float3 d_lin, out float3 d_ang)
{
    uint ca = b.law.ids.y;
    uint cb = b.law.ids.z;
    float3 du = (state[4 * cb].xyz - state[4 * ca].xyz) + (scratch[sv(cb, 21)].xyz - scratch[sv(ca, 21)].xyz);
    float3 dth = (state[4 * cb + 1].xyz - state[4 * ca + 1].xyz) + (scratch[sv(cb, 22)].xyz - scratch[sv(ca, 22)].xyz);
    float3 ta = state[4 * ca + 1].xyz + scratch[sv(ca, 22)].xyz;
    float3 tb = state[4 * cb + 1].xyz + scratch[sv(cb, 22)].xyz;
    d_lin = to_local(b, du + (cross(tb, b.rb.xyz) - cross(ta, b.ra.xyz)));
    d_ang = to_local(b, dth);
}

// The joint's response at the current displacements, without history (dt = 0).
JointResponse static_response(uint i)
{
    BondStatic b = bonds[i];
    float3 d_lin;
    float3 d_ang;
    static_kinematics(b, d_lin, d_ang);
    return joint_evaluate(materials.m[b.law.ids.x], b.law, bond_dyn[i].js, d_lin, d_ang, 0.0, false);
}

// Group dot product of two chunk vector slots over the island.
float island_dot(uint tid, uint c0, uint c1, uint sa, uint sb)
{
    float4 acc = float4(0.0);
    float4 unused = float4(0.0);
    for (uint c = c0 + tid; c < c1; c += THREADS)
        acc.x += dot(scratch[sv(c, sa)].xyz, scratch[sv(c, sb)].xyz) + dot(scratch[sv(c, sa + 1)].xyz, scratch[sv(c, sb + 1)].xyz);
    group_sum2(tid, acc, unused);
    return acc.x;
}

// statics.rs `project_load` (inertia relief) on a chunk vector slot.
void project_load_slot(uint tid, Island isl, uint slot)
{
    float3 net_f = float3(0.0);
    float3 net_m = float3(0.0);
    for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
    {
        float3 fi = scratch[sv(c, slot)].xyz;
        net_f += fi;
        net_m += cross(chunks[c].center.xyz - isl.com.xyz, fi) + scratch[sv(c, slot + 1)].xyz;
    }
    group_sum3(tid, net_f, net_m);
    float3 a = net_f / isl.com.w;
    float3 alpha = rows_mul(isl.inv0, isl.inv1, isl.inv2, net_m);
    for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
    {
        ChunkStatic ch = chunks[c];
        float3 r = ch.center.xyz - isl.com.xyz;
        scratch[sv(c, slot)] = float4(scratch[sv(c, slot)].xyz - (a + cross(alpha, r)) * ch.center.w, 0.0);
        scratch[sv(c, slot + 1)] = float4(scratch[sv(c, slot + 1)].xyz - rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, alpha), 0.0);
    }
    AllMemoryBarrierWithGroupSync();
}

// statics.rs `project_displacement` (rigid modes off, mass-orthogonally) on a slot.
void project_displacement_slot(uint tid, Island isl, uint slot)
{
    float3 p = float3(0.0);
    float3 l = float3(0.0);
    for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
    {
        ChunkStatic ch = chunks[c];
        float3 u = scratch[sv(c, slot)].xyz;
        float3 th = scratch[sv(c, slot + 1)].xyz;
        float3 r = ch.center.xyz - isl.com.xyz;
        p += u * ch.center.w;
        l += cross(r, u) * ch.center.w + rows_mul(ch.inertia0, ch.inertia1, ch.inertia2, th);
    }
    group_sum3(tid, p, l);
    float3 t = p / isl.com.w;
    float3 th0 = rows_mul(isl.inv0, isl.inv1, isl.inv2, l);
    for (uint c = isl.range.x + tid; c < isl.range.y; c += THREADS)
    {
        float3 r = chunks[c].center.xyz - isl.com.xyz;
        scratch[sv(c, slot)] = float4(scratch[sv(c, slot)].xyz - t - cross(th0, r), 0.0);
        scratch[sv(c, slot + 1)] = float4(scratch[sv(c, slot + 1)].xyz - th0, 0.0);
    }
    AllMemoryBarrierWithGroupSync();
}

float block_get(uint c, uint i, uint j)
{
    uint k = i * 6 + j;
    return scratch[sv(c, 12 + k / 4)][k % 4];
}

// The 6x6 inverse (statics.rs `Block6::inverse`: Cholesky, diagonal fallback) of a
// symmetric block given by rows, stored in the chunk's inverse-block slots.
void store_inverse(uint c, float a[36])
{
    float l[36];
    for (uint k = 0; k < 36; k++)
        l[k] = 0.0;
    bool spd = true;
    for (uint i = 0; i < 6 && spd; i++)
    {
        for (uint j = 0; j <= i; j++)
        {
            float sum = a[i * 6 + j];
            for (uint k = 0; k < j; k++)
                sum -= l[i * 6 + k] * l[j * 6 + k];
            if (i == j)
            {
                if (sum <= 0.0)
                {
                    spd = false;
                    break;
                }
                l[i * 6 + i] = sqrt(sum);
            }
            else
                l[i * 6 + j] = sum / l[j * 6 + j];
        }
    }
    float inv[36];
    if (!spd)
    {
        for (uint k = 0; k < 36; k++)
            inv[k] = 0.0;
        for (uint k = 0; k < 6; k++)
            inv[k * 6 + k] = a[k * 6 + k] > 0.0 ? 1.0 / a[k * 6 + k] : 0.0;
    }
    else
    {
        for (uint col = 0; col < 6; col++)
        {
            float y[6] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
            for (uint i = 0; i < 6; i++)
            {
                float s = i == col ? 1.0 : 0.0;
                for (uint k = 0; k < i; k++)
                    s -= l[i * 6 + k] * y[k];
                y[i] = s / l[i * 6 + i];
            }
            float x[6] = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
            for (uint ii = 0; ii < 6; ii++)
            {
                uint i = 5 - ii;
                float s = y[i];
                for (uint k = i + 1; k < 6; k++)
                    s -= l[k * 6 + i] * x[k];
                x[i] = s / l[i * 6 + i];
            }
            for (uint i = 0; i < 6; i++)
                inv[i * 6 + col] = x[i];
        }
    }
    for (uint q = 0; q < 9; q++)
        scratch[sv(c, 12 + q)] = float4(inv[4 * q], inv[4 * q + 1], inv[4 * q + 2], inv[4 * q + 3]);
}

// statics.rs `block_jacobi` for chunk c from its bonds' secant stiffness.
void assemble_block(uint c)
{
    float a[36];
    for (uint k = 0; k < 36; k++)
        a[k] = 0.0;
    for (uint e = index[c]; e < index[c + 1]; e++)
    {
        uint entry = index[e];
        uint i = entry >> 1;
        bool side_b = (entry & 1) != 0;
        BondStatic b = bonds[i];
        float4 k_lin = scratch[statics_bond_slot(i)];
        float4 k_ang = scratch[statics_bond_slot(i) + 1];
        for (uint p = 0; p < 6; p++)
        {
            float3 t = (p % 3) == 0 ? b.t1.xyz : ((p % 3) == 1 ? b.t2.xyz : b.normal.xyz);
            float3 row_u;
            float3 row_t;
            if (p < 3)
            {
                row_u = side_b ? t : -t;
                row_t = side_b ? cross(b.rb.xyz, t) : -cross(b.ra.xyz, t);
            }
            else
            {
                row_u = float3(0.0);
                row_t = side_b ? t : -t;
            }
            float kp = p < 3 ? k_lin[p] : k_ang[p - 3];
            if (kp == 0.0)
                continue;
            float row[6] = { row_u.x, row_u.y, row_u.z, row_t.x, row_t.y, row_t.z };
            for (uint r = 0; r < 6; r++)
                for (uint q = 0; q < 6; q++)
                    a[r * 6 + q] += kp * row[r] * row[q];
        }
    }
    uint mask = fixed_mask(c);
    for (uint d = 0; d < 6; d++)
    {
        if ((mask & (1u << d)) != 0)
        {
            for (uint e2 = 0; e2 < 6; e2++)
            {
                a[d * 6 + e2] = 0.0;
                a[e2 * 6 + d] = 0.0;
            }
            a[d * 6 + d] = 1.0;
        }
    }
    for (uint d = 0; d < 6; d++)
        if (a[d * 6 + d] == 0.0)
            a[d * 6 + d] = 1.0;
    store_inverse(c, a);
}

// z = M^-1 r (block-Jacobi) at slots (r: 4, z: 6).
void precondition(uint c)
{
    float4 r_lin = scratch[sv(c, 4)];
    float4 r_ang = scratch[sv(c, 5)];
    float rv[6] = { r_lin.x, r_lin.y, r_lin.z, r_ang.x, r_ang.y, r_ang.z };
    float z[6];
    for (uint i = 0; i < 6; i++)
    {
        float s = 0.0;
        for (uint j = 0; j < 6; j++)
            s += block_get(c, i, j) * rv[j];
        z[i] = s;
    }
    scratch[sv(c, 6)] = float4(z[0], z[1], z[2], 0.0);
    scratch[sv(c, 7)] = float4(z[3], z[4], z[5], 0.0);
}

[shader("compute")]
[numthreads(256, 1, 1)]
void island_statics(uint3 group: SV_GroupID, uint3 thread: SV_GroupThreadID)
{
    uint tid = thread.x;
    Island isl = islands[group.x];
    if ((isl.info.z & ISLAND_SOLVE) == 0)
        return;
    bool free = (isl.info.x & ISLAND_ANCHORED) == 0;
    uint c0 = isl.range.x;
    uint c1 = isl.range.y;
    uint b0 = isl.range.z;
    uint b1 = isl.range.w;
    for (uint c = c0 + tid; c < c1; c += THREADS)
    {
        scratch[sv(c, 21)] = float4(0.0);
        scratch[sv(c, 22)] = float4(0.0);
    }
    AllMemoryBarrierWithGroupSync();
    if (free)
        project_load_slot(tid, isl, 0);
    float scale = max(sqrt(island_dot(tid, c0, c1, 0, 0)), 1e-30);
    float tol = params.statics_tol;
    float residual = 0.0;
    uint newton = 0;
    uint cg_total = 0;
    bool converged = false;
    float previous = 1e30;
    uint max_cg = min(params.statics_cg, 20 * (c1 - c0) * 6 + 200);
    for (uint it = 0; it < params.statics_newton; it++)
    {
        // Residual: external loads plus the bond forces at the current displacements.
        for (uint i = b0 + tid; i < b1; i += THREADS)
        {
            JointResponse resp = static_response(i);
            write_bond_loads(i, bonds[i], resp.force_lin, resp.force_ang, 0.0);
        }
        AllMemoryBarrierWithGroupSync();
        for (uint c = c0 + tid; c < c1; c += THREADS)
        {
            float3 fi;
            float3 mi;
            gather_loads(c, fi, mi);
            float4 r_lin = float4(scratch[sv(c, 0)].xyz + fi, 0.0);
            float4 r_ang = float4(scratch[sv(c, 1)].xyz + mi, 0.0);
            hold(fixed_mask(c), r_lin, r_ang, float4(0.0), float4(0.0));
            scratch[sv(c, 4)] = r_lin;
            scratch[sv(c, 5)] = r_ang;
        }
        AllMemoryBarrierWithGroupSync();
        if (free)
            project_load_slot(tid, isl, 4);
        residual = sqrt(island_dot(tid, c0, c1, 4, 4)) / scale;
        newton = it;
        // Converged at the tolerance, or at f32's floor: the residual of a structure
        // in equilibrium stops falling at a level set by rounding (displacements far
        // larger than the bond deformations they differ into); a mechanism's stays at
        // the size of its loads.
        if (residual <= tol || (residual <= STATICS_FLOOR && residual > 0.5 * previous))
        {
            converged = true;
            break;
        }
        previous = residual;
        // The secant system and its preconditioner.
        for (uint i = b0 + tid; i < b1; i += THREADS)
        {
            BondStatic b = bonds[i];
            float3 d_lin;
            float3 d_ang;
            static_kinematics(b, d_lin, d_ang);
            float3 f_lin;
            float3 f_ang;
            secant_factors(b.law, bond_dyn[i].js, d_lin, f_lin, f_ang);
            float4 st0 = b.law.stiff0;
            scratch[statics_bond_slot(i)] = float4(st0.y * f_lin.x, st0.y * f_lin.y, st0.x * f_lin.z, 0.0);
            scratch[statics_bond_slot(i) + 1] = float4(st0.z * f_ang.x, st0.w * f_ang.y, b.law.stiff1.x * f_ang.z, 0.0);
        }
        AllMemoryBarrierWithGroupSync();
        for (uint c = c0 + tid; c < c1; c += THREADS)
        {
            assemble_block(c);
            scratch[sv(c, 2)] = float4(0.0);
            scratch[sv(c, 3)] = float4(0.0);
        }
        AllMemoryBarrierWithGroupSync();
        // Conjugate gradients for K x = r (pcg_solve); r is consumed.
        for (uint c = c0 + tid; c < c1; c += THREADS)
            precondition(c);
        AllMemoryBarrierWithGroupSync();
        if (free)
            project_displacement_slot(tid, isl, 6);
        for (uint c = c0 + tid; c < c1; c += THREADS)
        {
            scratch[sv(c, 8)] = scratch[sv(c, 6)];
            scratch[sv(c, 9)] = scratch[sv(c, 7)];
        }
        AllMemoryBarrierWithGroupSync();
        float rz = island_dot(tid, c0, c1, 4, 6);
        float norm0 = sqrt(island_dot(tid, c0, c1, 4, 4));
        // Inexact Newton: each correction to 1e-4 of its residual.
        float cg_tol = 1e-4;
        for (uint k = 0; k < max_cg && norm0 > 0.0; k++)
        {
            // ap = K p.
            for (uint i = b0 + tid; i < b1; i += THREADS)
            {
                BondStatic b = bonds[i];
                uint ca = b.law.ids.y;
                uint cb = b.law.ids.z;
                float3 d_lin;
                float3 d_ang;
                bond_kinematics(b, scratch[sv(ca, 8)].xyz, scratch[sv(ca, 9)].xyz, scratch[sv(cb, 8)].xyz, scratch[sv(cb, 9)].xyz, d_lin, d_ang);
                write_bond_loads(i, b, d_lin * scratch[statics_bond_slot(i)].xyz, d_ang * scratch[statics_bond_slot(i) + 1].xyz, 0.0);
            }
            AllMemoryBarrierWithGroupSync();
            for (uint c = c0 + tid; c < c1; c += THREADS)
            {
                float3 fi;
                float3 mi;
                gather_loads(c, fi, mi);
                float4 ap_lin = float4(-fi, 0.0);
                float4 ap_ang = float4(-mi, 0.0);
                hold(fixed_mask(c), ap_lin, ap_ang, scratch[sv(c, 8)], scratch[sv(c, 9)]);
                scratch[sv(c, 10)] = ap_lin;
                scratch[sv(c, 11)] = ap_ang;
            }
            AllMemoryBarrierWithGroupSync();
            float pap = island_dot(tid, c0, c1, 8, 10);
            cg_total++;
            if (pap <= 0.0)
                break;
            float alpha = rz / pap;
            for (uint c = c0 + tid; c < c1; c += THREADS)
            {
                scratch[sv(c, 2)] = float4(scratch[sv(c, 2)].xyz + alpha * scratch[sv(c, 8)].xyz, 0.0);
                scratch[sv(c, 3)] = float4(scratch[sv(c, 3)].xyz + alpha * scratch[sv(c, 9)].xyz, 0.0);
                scratch[sv(c, 4)] = float4(scratch[sv(c, 4)].xyz - alpha * scratch[sv(c, 10)].xyz, 0.0);
                scratch[sv(c, 5)] = float4(scratch[sv(c, 5)].xyz - alpha * scratch[sv(c, 11)].xyz, 0.0);
            }
            AllMemoryBarrierWithGroupSync();
            if (sqrt(island_dot(tid, c0, c1, 4, 4)) <= cg_tol * norm0)
                break;
            for (uint c = c0 + tid; c < c1; c += THREADS)
                precondition(c);
            AllMemoryBarrierWithGroupSync();
            if (free)
                project_displacement_slot(tid, isl, 6);
            float rz_new = island_dot(tid, c0, c1, 4, 6);
            float beta = rz_new / rz;
            rz = rz_new;
            for (uint c = c0 + tid; c < c1; c += THREADS)
            {
                scratch[sv(c, 8)] = float4(scratch[sv(c, 6)].xyz + beta * scratch[sv(c, 8)].xyz, 0.0);
                scratch[sv(c, 9)] = float4(scratch[sv(c, 7)].xyz + beta * scratch[sv(c, 9)].xyz, 0.0);
            }
            AllMemoryBarrierWithGroupSync();
        }
        // The Newton correction, compensated.
        for (uint c = c0 + tid; c < c1; c += THREADS)
        {
            float3 u = state[4 * c].xyz;
            float3 u_lo = scratch[sv(c, 21)].xyz;
            float3 th = state[4 * c + 1].xyz;
            float3 th_lo = scratch[sv(c, 22)].xyz;
            comp_add(u, u_lo, scratch[sv(c, 2)].xyz);
            comp_add(th, th_lo, scratch[sv(c, 3)].xyz);
            state[4 * c] = float4(u, state[4 * c].w);
            state[4 * c + 1] = float4(th, state[4 * c + 1].w);
            scratch[sv(c, 21)] = float4(u_lo, 0.0);
            scratch[sv(c, 22)] = float4(th_lo, 0.0);
        }
        AllMemoryBarrierWithGroupSync();
        newton = it + 1;
    }
    // Equilibrium: no deformation velocity; reactions; the bond forces at it.
    for (uint i = b0 + tid; i < b1; i += THREADS)
    {
        JointResponse resp = static_response(i);
        BondDyn bd = bond_dyn[i];
        bd.force_lin = float4(resp.force_lin, resp.stored);
        bd.force_ang = float4(resp.force_ang, bd.force_ang.w);
        bond_dyn[i] = bd;
        write_bond_loads(i, bonds[i], resp.force_lin, resp.force_ang, max(resp.measures.tension, resp.measures.compression));
    }
    AllMemoryBarrierWithGroupSync();
    for (uint c = c0 + tid; c < c1; c += THREADS)
    {
        float3 fi;
        float3 mi;
        gather_loads(c, fi, mi);
        float3 reaction = fixed_mask(c) != 0 ? -(scratch[sv(c, 0)].xyz + fi) : float3(state[4 * c + 1].w, state[4 * c + 2].w, state[4 * c + 3].w);
        state[4 * c + 1] = float4(state[4 * c + 1].xyz, reaction.x);
        state[4 * c + 2] = float4(0.0, 0.0, 0.0, reaction.y);
        state[4 * c + 3] = float4(0.0, 0.0, 0.0, reaction.z);
    }
    if (tid == 0)
    {
        scratch[statics_result_slot(group.x)] = float4(residual, asfloat(newton), asfloat(cg_total), converged ? 1.0 : 0.0);
        islands[group.x].info.z = isl.info.z & ~ISLAND_SOLVE;
    }
}
