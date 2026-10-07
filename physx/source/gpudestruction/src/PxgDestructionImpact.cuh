// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// Impact capacity ("E", docs/destruction/IMPACT_CAPACITY_DESIGN.md): one tick
// as an impact of chunks joined by joints of finite capacity.
//
// Each joint is elastic-perfectly-plastic. Its capacity C_b is the stage's own
// stress formula (fibre bending, section-modulus gains capped at bendGainMax)
// against its material's fatal limits, as three cones about the bond centroid:
//   compression  gb |M_t| - N <= cF a      (N: normal force, + tension)
//   tension      gb |M_t| + N <= tF a
//   shear        |V| + gt |T| <= sF a
// Its stiffness is the stress solve's own (the bond's compliance weight w:
// k = stiffness w^2 on its forces, k L^2 on its moments, L the solve's length
// scale), so redundant load paths share load as the elastic solve shares them.
//
// Over the tick the chunks move by x (backward Euler from rest):
//   M x / dt^2 = p + B J,    J_b = Pi_Cb(T_b - K_b B_b^T x)
// p is each chunk's load (the stress inputs: gravity, contact, constraint and
// command loads), B the stress solver's bond-to-chunk operator, T_b the joint's
// elastic trial force and Pi_Cb the return map (projection onto C_b in the
// metric K_b^-1). Its dual, solved here, is a strongly convex problem in the
// joint forces alone:
//   minimise 1/2 |p + B J|^2_{M^-1} + 1/2 sum_b |J_b - T_b|^2_{(K_b dt^2)^-1}   over J_b in C_b
// the post-tick kinetic energy (Moreau) plus the joints' complementary energy.
// A joint below capacity holds its chunks together; one at capacity carries
// exactly its capacity; what the joints cannot carry accelerates the chunks
// (a = M^-1 (p + B J): d'Alembert) instead of reaching the anchors, which have
// no M^-1. The joints' compliance is the elastic tie-break: where redundant
// joints could carry a load, it is shared in proportion to their stiffness, as
// in the elastic solve. With joints as stiff as these (k dt^2 / m >> 1) this is
// the design's rigid-chunk impact.
//
// The tick's load grows from the state the structure was in (the forces it
// carried at the end of the previous tick -- E's where E solved -- which
// balance their loads exactly on the current graph) to the full load, in
// factors of `rampFactor`, each level an increment from the last
// (incremental return mapping: T = the last level's forces plus the increment
// of the stage's elastic solve between the last tick's loads and this tick's,
// which is exact while nothing is clipped; what
// clipped and broken joints no longer carry is redistributed by the solve). A
// brittle joint (material ductileSlip 0) fractures at the level where its
// capacity is first reached in the solved field, and the level is solved again
// without it. A ductile joint yields and carries its capacity; at the full load
// it breaks if its slip at the centroid over the tick, 1/2 |v_rel| dt, exceeds
// its ultimate slip. When the elastic solve has no joint past capacity nothing
// here runs: the stage's verdict is today's, bit for bit.
//
// The coupled contact (ContactRow): a body that struck the island in the trial
// is a rigid node of the same problem, with its momentum and inverse mass and
// inertia, joined to the struck chunk by a unilateral contact (c >= 0, Coulomb
// friction); the trial's impulse of that pair is not a load. What the joints
// cannot pass on then slows the impactor only as much as the struck region's
// mass and capacity can (the impact solve's own answer for the impactor).
//
// Solver: ADMM on J, one block per island that has a joint past capacity: the
// linear step in chunk space by block-preconditioned conjugate gradients, the
// projection step exact in a diagonal metric (each capacity set is a solid of
// revolution whose meridian is a triangle, or the section model's polyhedron).
// FP32; its iteration budget is its own (Settings::iterations).
//
// Included inside the runtime's namespace (or a test's), after PxDestructionScene.h.
namespace impact {

enum Verdict : PxU32 { eNONE=0, eHELD=1, eYIELDED=2, eBROKEN=3 };
enum BondFlag : PxU32 { eDYNAMIC0=1, eDYNAMIC1=2, eDUCTILE=4, eALIVE=8, eCONTACT=16 };

// The coupled contact (design step 2): a body that struck an island in the
// trial -- a vehicle, a ball, a loose piece -- enters the island's solve as a
// rigid body with its own momentum and inverse mass and inertia, joined to the
// struck chunk by a unilateral contact (compression only, Coulomb friction,
// no moment). The trial's force on the chunk from that pair is taken out of
// the chunk's load; the contact force is solved with the joints. One row per
// (contact pair, struck chunk), in the struck chunk's cluster frame. The trial
// stopped the impactor against the anchored (kinematic) cluster: its velocity
// before the tick, and the change the trial gave it, are what the row carries.
struct ContactRow {
    PxU32 chunk;        // the struck chunk (0xffffffff: no row)
    PxU32 body;         // the impactor's identity (its rigid body index)
    PxU32 points;       // the pair's normal contact points
    float friction;     // Coulomb coefficient of the pair
    float point[3];     // the trial's contact point (force-weighted)
    float normal[3];    // unit: the direction of the contact force on the chunk
    float load[3];      // the trial's force on the chunk from this pair (normals and friction), N
    float torque[3];    // the trial's torque on the impactor from this pair, about its centre of mass, N m
    float com[3];       // the impactor's centre of mass before the tick
    float velocity[3];  // its velocity before the tick, relative to the struck cluster (at the com)
    float spin[3];      // its angular velocity before the tick, relative to the cluster
    float dv[3],dw[3];  // the change the trial gave its velocity and angular velocity over the tick
    float im;           // inverse mass
    float ii[6];        // inverse inertia (xx, yy, zz, xy, xz, yz)
    // A chain row (bodyA valid): a contact between two impactors, body A (one
    // with its own row on this island's anchored chunk `chunk`, which gives
    // the island and the frame) and `body` (B). load/normal: the trial's force
    // on A; torqueA: its torque on A about A's centre of mass (comA). The
    // impactor fields above are B's. The impactor pushing a freed piece into
    // the still-anchored structure is in the solve through it.
    PxU32 bodyA=0xffffffffu; // 0xffffffff: a row on a chunk
    float torqueA[3],comA[3];
};
__device__ __forceinline__ bool chainRow(const ContactRow& r){return r.bodyA!=0xffffffffu;}

struct Settings {
    float dt=1.0f/60.0f;
    float bendGainMax=3.0f;
    // Joint stiffness: k_b = stiffnessScale * stiffness * w_b^2 (N/m), stiffness
    // per material (Inputs::stiffness: the modulus that makes w^2 a stiffness)
    // or this default; L the stress solve's length scale (m).
    float stiffness=30e9f;
    float lengthScale=1.0f;
    // A multiplier on every joint's stiffness, for A/B only (1: the joints as
    // authored -- the stress solve's weights, or a material's own impact
    // stiffness where its weight is a concession for gravity load sharing,
    // e.g. a timber-frame wall tie, soft in the wall's plane and ~1 kN/mm
    // along its axis).
    float stiffnessScale=1.0f;
    bool momentAtCentroid=false;   // see prepareBond
    // The elastic solve reports every bond's wrench at its centroid (section
    // rotational stiffness, PX_DESTRUCTION_SECTION_ROTATIONAL_STIFFNESS)
    // instead of at the chunks' midpoint: its application point P is the
    // centroid for every bond.
    bool solverAtCentroid=false;
    // The stage's section model (PX_DESTRUCTION_SECTION_BENDING /
    // _ROTATIONAL_STIFFNESS, Inputs::sections): capacity from each bond's own
    // section -- bending |M0|/S0 + |M1|/S1 and twist |T|/Zt about the centroid,
    // the moduli shrinking with the remaining area, as the verdict reads them
    // (extStressCalcBondStressSection) -- and, with rotational stiffness, each
    // joint's rotational stiffness k r^2 per principal axis of its section and
    // k r_p^2 in twist, as the elastic solve has it.
    bool sectionBending=false,sectionRotation=false;
    // The ramp starts at the first event -- the load fraction at which the
    // first joint reaches capacity in the elastic solution -- and grows by
    // rampFactor to the full load (event to event: before the first event
    // the elastic solution is exact). rampLevels caps the levels (the first
    // event no earlier than rampFactor^-(rampLevels-1)): the float resolution
    // of the load, not a physical threshold.
    PxU32 rampLevels=32;
    float rampFactor=2.0f;
    PxU32 iterations=4096;   // ADMM iterations per solve
    // ADMM iterations per island per evaluation, all its solves together. A
    // solve that would exceed it is capped: the island returns to its last
    // converged state and the evaluation is unconverged (never a verdict
    // from an unconverged iterate). The veneer house's hardest first tick
    // (the meteor: 98 solves, 24.5k steps converged, ~20 s in 60 ms
    // dispatches) fits; the budget bounds a tick, it does not end converging
    // solves early.
    PxU32 evaluationIterations=32768;
    // The work of one dispatch, per block, in visits of the island's links
    // and nodes (an ADMM step: five passes, three more per conjugate
    // gradient iteration). Measured 5.4e7 visits a second for one block on
    // an M-series GPU (CuMetal), so 2^20 keeps a dispatch near 20-40 ms alone (under 100 ms shared),
    // whatever the convergence: Apple GPUs do not preempt compute well, and a
    // longer command buffer starves the display. The host waits for each
    // dispatch (Stage::submit). Not a physical quantity: only how an
    // evaluation is split into dispatches.
    PxU32 dispatchWork=1u<<20;   // measured: 2^22 reached 166 ms, 2^21 178 ms sharing the GPU with other jobs
    PxU32 innerIterations=64;// node-space conjugate gradient iterations per ADMM step, at most (warm-started; to the tolerance)
    // Converged when every joint's projected gradient -- the relative
    // acceleration of its two chunks that the solve has not yet balanced or
    // let through -- moves them apart by at most this over the tick
    // (1/2 a dt^2, m; rotations at the solve's length scale): a tenth of a
    // millimetre, far under the 15 mm ultimate slip and a joint's elastic
    // deformation at capacity.
    float tolerance=1e-4f;
    // How far past capacity a converged solve's forces may be (the split's
    // primal residual, as a fraction of the joint's capacity). A joint whose
    // carried plastic state is within it has not reached a new event.
    float capacityTolerance=1e-4f;
    float capacityBand=2e-3f;// at capacity: utilisation >= 1 - capacityBand (the oracle's)
    PxU32 maxRounds=256;     // solves per island per evaluation (levels plus brittle cascades)
    // The elastic solve's increment is the intact structure's. Once a joint
    // has reached capacity, false leaves the load increment to the solve
    // (through p(lambda)); true keeps adding it -- A/B.
    bool elasticIncrementAfterYield=false;
    // The coupled contact (Inputs::rows): false takes the trial's contact
    // impulses as given (step 1, the uncoupled oracle) -- A/B.
    bool coupledContact=true;
    // A struck chunk held elastically keeps the trial's stop (see stepIslands' publish); false: A/B only.
    bool heldStops=true;
    // Diagnostics only (tests): 1 corrupts the first link's projection
    // (scales it 10x out of its set), so the detectors can be shown to fire.
    PxU32 faultInjection=0;
};
// A solve is diverging when, past its first rho rebalance (25 steps), a
// joint's split |J - Z| exceeds kDivergence times the joint's capacity: the
// projection's broken solve on the house went to 4e3x within four steps; a
// relative test against the running minimum misfired on healthy coupled
// contacts, whose residual rightly rises from the feasible start.
constexpr float kDivergence=100.0f;

// Device-side counters for one evaluation.
struct Status {
    PxU32 triggered;   // islands with a joint past capacity
    PxU32 solves;      // solves run
    PxU32 iterations;  // projected iterations run (sum)
    PxU32 capped;      // solves that ended at the iteration budget
    PxU32 broken;      // joints E broke (brittle at capacity, or ductile past ultimate slip)
    PxU32 yielded;     // ductile joints at capacity that held
    PxU32 rounds;      // largest solve count of any island
    PxU32 error;       // 1: scratch overflow, 2: nonfinite, 4: round budget exhausted, 8: contact rows past capacity
    PxU32 contacts;    // contact rows coupled
    PxU32 impactors;   // impactor bodies coupled
    PxU32 diverged;    // solves stopped as diverging (a bug signal; no verdict from them)
    PxU32 infeasible;  // projections that left their capacity set (a bug signal)
    PxU32 worstBond;   // the bond with the worst split in the last diverged solve, plus 1 (0: none)
    PxU32 heldStops;   // impactors whose solved velocity was withheld (a struck chunk held elastically)
    PxU32 rolledBack;  // islands with impactors whose evaluation was capped or diverged (the trial's stop stands)
    PxU32 energyGain;  // impactors the solve would have sped up past their start (a bug signal; withheld)
};
// Optional per-solve record (diagnostics): the first kLogCapacity solves.
struct SolveRecord { PxU32 island,level,iterations,broken,clipped,capped,links,nodes; float lambda,change,rho,pad; };
constexpr PxU32 kLogCapacity=256;
constexpr PxU32 kTraceCapacity=8192;

struct Bond {
    PxU32 bond,c0,c1,flags;
    float n[3],t1[3],t2[3];  // bond frame (n from chunk0 to chunk1)
    float o0[3],o1[3];       // E's wrench's point from each chunk (the solver's, or the centroid)
    float pc[3];             // the stress solver's application point less E's
    float capC,capT,capS;    // cF a, tF a, sF a (N)
    float gb,gt;             // bending (round set) and torsion gains (1/m): fibre stress x area per unit moment
    float g0,g1;             // bending gains about t1 and t2 (section moduli: the L1 set); 0: the round set (gb |M_t|)
    float h0,h1;             // the tension line's gains (the L1 set): g0, g1, or a bearing joint's 1/d0, 1/d1
    float kl,kt,k0,k1;       // stiffness on forces (N/m), in twist, and in bending about t1, t2 (N m/rad)
    float dl,dt,d0,d1;       // majoriser of the dual's Hessian, by the same rows
    float slip;              // ultimate slip (m); 0 brittle
    float area;
};
// A node of the island: a chunk (scalar inertia, as the stress solve has it),
// or an impactor (tensor: its full inertia). begin/end index Scratch::adj.
struct Chunk { PxU32 chunk,begin,end,tensor,owner,pad[3]; float im,ii; float pb[6],pf[6],r[6]; float I[6],Iinv[6]; };

struct Scratch {
    PxU32* islandFlag{};   // [N] by island id (minimum dynamic node)
    PxU32* islands{};      // [N] triggered island ids
    PxU32* counters{};     // [4] island count, bond cursor, chunk cursor, spare
    PxU32* bondLocal{};    // [M] local slot of each bond of a triggered island
    PxU32* degree{};       // [N] live bonds per chunk
    Bond* bonds{};         // [M]
    Chunk* chunks{};       // [N]
    float *J{},*Y{},*Jn{},*T{}; // [6M] each, bond frame: force, extrapolation, next iterate, elastic trial
    float* u{};            // [6N] by chunk: M^-1 (p + B J), the tick's acceleration (linear, angular)
    float *a{};            // [6M] bond frame: the ADMM step's A^-1 c
    float *cy{},*cr{},*cz{},*cp{},*cq{}; // [6N] by chunk: the node-space conjugate gradient's vectors
    float* cinv{};         // [36N] by chunk: the inverse of its 6x6 diagonal block of N
    PxDestructionVectorPair* forces{}; // [M] E's bond forces, the stress solver's convention
    PxU32* verdict{};      // [M]
    Status* status{};
    SolveRecord* log{};    // [kLogCapacity] or null; status->solves counts them
    float* breaks{};       // [2M] or null: per bond, the round it broke in and its slip then (diagnostics)
    PxU32* adj{};          // [2 (M + R)] each island node's links (joints and contacts), local indices
    float* impactorMass{}; // [2 R] by impactor slot: inverse mass, largest inverse inertia (the majoriser)
    float* Js{};           // [6 (M + R)] the island's last converged forces
    float* slip{};         // [M] each solved bond's plastic slip this evaluation (m)
    float* linkResidual{}; // [6 (M + R)] or null: each link's last primal, dual, dual linear/angular and their float floors (diagnostics)
    PxU32 traceSolve=0;    // which solve the trace records (by Status::solves at its start)
    float* trace{};        // [4 kTraceCapacity] or null: the first solve's (primal, dual, motion, rho) per ADMM step (diagnostics)
    struct IslandState* state{}; // [N] by triggered-island slot
};
// Contact rows one evaluation may couple (all islands), beyond the bonds.
constexpr PxU32 kContactCapacity=4096;

struct Inputs {
    const PxDestructionStressChunk* chunks{}; PxU32 chunkCount{};
    const PxDestructionStressBond* bonds{}; PxU32 bondCount{};
    const PxDestructionMaterial* materials{};
    const float* ductileSlip{};       // per material, m (0 brittle); null: all brittle
    const float* stiffness{};         // per material, N/m per unit w^2; null: Settings::stiffness
    const float* health{};            // live area
    const PxU32* nodeBegin{}; const PxU32* nodeRefs{};
    const PxU32* nodeIslands{}; const PxU32* bondIslands{};
    const PxDestructionVectorPair* accelerations{}; // stress inputs: linear = load/m, angular = -torque/I
    const PxDestructionVectorPair* elastic{};       // this evaluation's elastic solve
    const PxDestructionVectorPair* base{};          // the forces the structure carried before this tick (the ramp's start: E's where it solved)
    // Per bond, nonzero where `base` is the impact solve's (its island was
    // solved or carried at the last evaluation): a plastic state -- yielded
    // joints at capacity, the self-equilibrated forces they left -- that the
    // elastic solve does not know. Null: none (every island elastic).
    const PxU32* carried{};
    const float* slipBefore{};                      // per bond: the plastic slip it has accumulated (m), or null (none)
    const PxDestructionVectorPair* elasticBase{};   // the elastic solve's forces before this tick (null: base)
    const PxDestructionStageStatus* stage{};        // skip when the stage already failed
    const PxDestructionCrushState* crushed{};       // chunks crushed before the solve (Ci), or null
    const PxDestructionBondSection* sections{};     // the section model's sections (Settings::sectionBending), or null
    const ContactRow* rows{}; PxU32 rowCount{};       // the coupled contact's rows, or none (Settings::coupledContact)
    const PxU32* rowCounter{};                       // on device: rows written (rowCount is then their capacity)
    float* rowForce{};                               // [3 rowCount] out: each coupled row's solved force on its chunk (N; 0 uncoupled)
    // [6 rowCount] out: per impactor and island, on one of its rows (the
    // others 0): the change the coupled solve makes to the trial's end
    // velocity and angular velocity (struck cluster's frame). Zeroed by the caller.
    float* rowDelta{};
};

// ---------------------------------------------------------------------------
// Small vector helpers
// ---------------------------------------------------------------------------
__device__ __forceinline__ float dot3(const float* a,const float* b){return a[0]*b[0]+a[1]*b[1]+a[2]*b[2];}
__device__ __forceinline__ void cross3(const float* a,const float* b,float* c)
{c[0]=a[1]*b[2]-a[2]*b[1];c[1]=a[2]*b[0]-a[0]*b[2];c[2]=a[0]*b[1]-a[1]*b[0];}
__device__ __forceinline__ void frame(const PxVec3& normal,float* n,float* t1,float* t2)
{
    n[0]=normal.x;n[1]=normal.y;n[2]=normal.z;
    const float e[3]={fabsf(n[0])<0.9f?1.0f:0.0f,fabsf(n[0])<0.9f?0.0f:1.0f,0.0f};
    cross3(n,e,t1);const float l=sqrtf(dot3(t1,t1));t1[0]/=l;t1[1]/=l;t1[2]/=l;
    cross3(n,t1,t2);
}
// The stress solver's wrench (cluster-local frame: force on chunk0 at its
// application point P, couple -ang on chunk0) <-> E's (bond frame: the same
// force at the centroid c, its couple there): M_c = ang + (c - P) x lin.
__device__ __forceinline__ void toLocal(const Bond& b,const PxDestructionVectorPair& w,float* x)
{
    const float l[3]={w.linear.x,w.linear.y,w.linear.z};
    float t[3];cross3(b.pc,l,t);
    const float a[3]={w.angular.x-t[0],w.angular.y-t[1],w.angular.z-t[2]};
    x[0]=dot3(l,b.n);x[1]=dot3(l,b.t1);x[2]=dot3(l,b.t2);
    x[3]=dot3(a,b.n);x[4]=dot3(a,b.t1);x[5]=dot3(a,b.t2);
}
// Bond frame -> cluster frame (couple about the centroid).
__device__ __forceinline__ void toWorld(const Bond& b,const float* x,float* lin,float* ang)
{
    for(int k=0;k<3;++k){lin[k]=x[0]*b.n[k]+x[1]*b.t1[k]+x[2]*b.t2[k];ang[k]=x[3]*b.n[k]+x[4]*b.t1[k]+x[5]*b.t2[k];}
}
// Bond frame -> the stress solver's convention (couple about P).
__device__ __forceinline__ void toSolver(const Bond& b,const float* x,float* lin,float* ang)
{
    toWorld(b,x,lin,ang);float t[3];cross3(b.pc,lin,t);for(int k=0;k<3;++k)ang[k]+=t[k];
}

// Fatal utilisation of a bond-frame wrench (the stage's formula with fibre
// bending and capped gains; see NvBlastExtStressFormula.h).
__device__ __forceinline__ float utilisation(const Bond& b,const float* x)
{
    const float N=x[0],V=sqrtf(x[1]*x[1]+x[2]*x[2]),T=fabsf(x[3]),M=sqrtf(x[4]*x[4]+x[5]*x[5]);
    const float bend=b.g0>0.0f?b.g0*fabsf(x[4])+b.g1*fabsf(x[5]):b.gb*M;
    // A bearing joint's fasteners: T = |M0|/d0 + |M1|/d1 + N (N signed: the
    // compression holds the contact shut), in place of the fibre's.
    const float pull=b.g0>0.0f?b.h0*fabsf(x[4])+b.h1*fabsf(x[5]):bend;
    const float tension=fmaxf(N+pull,0.0f),compression=fmaxf(bend-N,0.0f),shear=V+b.gt*T;
    auto ratio=[](float d,float c){return d<=0.0f?0.0f:(c>0.0f?d/c:FLT_MAX);};
    return fmaxf(fmaxf(ratio(compression,b.capC),ratio(tension,b.capT)),ratio(shear,b.capS));
}

// Nearest point of triangle (a,b,c) to p in 2D.
__device__ __forceinline__ void segment(float px,float py,float ax,float ay,float bx,float by,float& qx,float& qy,float& d2)
{
    const float ex=bx-ax,ey=by-ay,l=ex*ex+ey*ey;
    float t=l>0.0f?((px-ax)*ex+(py-ay)*ey)/l:0.0f;t=fminf(fmaxf(t,0.0f),1.0f);
    const float x=ax+t*ex,y=ay+t*ey,dx=px-x,dy=py-y,d=dx*dx+dy*dy;
    if(d<d2){d2=d;qx=x;qy=y;}
}
__device__ __forceinline__ bool triangle(float& px,float& py,float ax,float ay,float bx,float by,float cx,float cy)
{
    // Counter-clockwise a (left base), b (right base), c (apex above): inside
    // when on the left of every edge.
    const float e0=(bx-ax)*(py-ay)-(by-ay)*(px-ax),e1=(cx-bx)*(py-by)-(cy-by)*(px-bx),e2=(ax-cx)*(py-cy)-(ay-cy)*(px-cx);
    if(e0>=0.0f && e1>=0.0f && e2>=0.0f)return false;
    float qx=px,qy=py,d2=FLT_MAX;
    segment(px,py,ax,ay,bx,by,qx,qy,d2);segment(px,py,bx,by,cx,cy,qx,qy,d2);segment(px,py,cx,cy,ax,ay,qx,qy,d2);
    px=qx;py=qy;return true;
}
// The projection's KKT point for multipliers on the tension (lt) and
// compression (lc) lines: N moves by (lt - lc)/a, each moment by -(lt + lc)
// g / b, clipped at zero (the quadrant's own bound).
__device__ __forceinline__ void polytopePoint(const float* p,const float* w,float g0,float g1,float h0,float h1,float lt,float lc,float* q)
{
    q[0]=p[0]-(lt-lc)/w[0];q[1]=fmaxf(0.0f,p[1]-(lt*h0+lc*g0)/w[1]);q[2]=fmaxf(0.0f,p[2]-(lt*h1+lc*g1)/w[2]);
}
// The section's axial set with an L1 bending term, in its positive quadrant
// (M0, M1 >= 0; the set and a diagonal metric are symmetric under their sign
// flips, so the projection keeps their signs):
//   M0 >= 0, M1 >= 0, g0 M0 + g1 M1 + N <= capT, g0 M0 + g1 M1 - N <= capC.
// The projection in the metric diag(w) (w = sc^2) by its KKT conditions:
// the point is p moved by the active lines' multipliers (polytopePoint);
// each case -- tension line, compression line, both (the apex) -- is a
// monotone equation in one multiplier, solved by bisection. Exact to float
// resolution whatever the scaling (an enumeration of active sets through 3x3
// determinants lost every candidate on thin sections, g ~ 2e3 /m against
// metrics ~1: an infeasible "projection" that drove the solve apart).
__device__ __forceinline__ void polytope(float* p,const float* sc,float g0,float g1,float h0,float h1,float capT,float capC)
{
    // Tension line h . m + N <= capT (h = g, or a bearing joint's 1/d),
    // compression line g . m - N <= capC.
    const float w[3]={sc[0]*sc[0],sc[1]*sc[1],sc[2]*sc[2]};
    const float tol=1e-6f*(capT+capC);
    auto tension=[](const float* q,float a,float b){return a*q[1]+b*q[2]+q[0];};
    auto compression=[](const float* q,float a,float b){return a*q[1]+b*q[2]-q[0];};
    if(tension(p,h0,h1)<=capT+tol && compression(p,g0,g1)<=capC+tol)return;
    float q[3];
    const float gm=fmaxf(fminf(g0,g1),1e-30f),hm=fmaxf(fminf(h0,h1),1e-30f);
    const float big=(fabsf(p[0])+capT+capC+(g0+h0)*p[1]+(g1+h1)*p[2])*(w[0]+w[1]/(gm*hm)+w[2]/(gm*hm)+w[1]/(gm*gm)+w[2]/(hm*hm))+1.0f;
    // One line alone: its multiplier makes it hold with equality (monotone).
    for(int side=0;side<2;++side) {
        float lo=0.0f,hi=big;
        for(int it=0;it<64;++it) {
            const float mid=0.5f*(lo+hi);
            polytopePoint(p,w,g0,g1,h0,h1,side?0.0f:mid,side?mid:0.0f,q);
            const float f=side?compression(q,g0,g1)-capC:tension(q,h0,h1)-capT;
            if(f>0.0f)lo=mid;else hi=mid;
        }
        polytopePoint(p,w,g0,g1,h0,h1,side?0.0f:hi,side?hi:0.0f,q);
        const float other=side?tension(q,h0,h1)-capT:compression(q,g0,g1)-capC;
        if(other<=tol){p[0]=q[0];p[1]=q[1];p[2]=q[2];return;}
    }
    // Both lines (the apex): (g + h) . m = capT + capC and N = capT - h . m.
    // On that segment of the quadrant, m0 = s, m1 = (tau - c0 s)/c1: the
    // distance is a quadratic in s, minimised in closed form and clamped.
    const float tau=capT+capC,c0=g0+h0,c1=g1+h1;
    if(!(c1>0.0f) || !(c0>0.0f)){p[0]=capT;p[1]=p[2]=0.0f;return;}
    // m1 = A + B s, N = capT - h0 s - h1 m1 = C + D s.
    const float A=tau/c1,B=-c0/c1,C=capT-h1*A,D=-h0-h1*B;
    // d/ds [ w0 (C + D s - N^)^2 + w1 (s - m0^)^2 + w2 (A + B s - m1^)^2 ] = 0
    const float num=w[0]*D*(p[0]-C)+w[1]*p[1]+w[2]*B*(p[2]-A),den=w[0]*D*D+w[1]+w[2]*B*B;
    const float smax=tau/c0,sv=fminf(fmaxf(den>0.0f?num/den:0.0f,0.0f),smax);
    p[0]=C+D*sv;p[1]=sv;p[2]=fmaxf(0.0f,A+B*sv);
}
// Projection of a bond-frame wrench onto C_b in the metric
// diag(ml,ml,ml,mt,m0,m1). The axial set (N, M_t) and the shear set (T, V) are
// independent. The shear set, and the axial set with the round bending term,
// are rotationally symmetric about their scalar axis: the projection keeps
// the vector part's direction and projects (scalar, |vector|) onto the
// meridian triangle. The section's L1 bending term is a polyhedron (above).
// Returns whether anything moved.
// A contact row's set: compression only (N <= 0), Coulomb friction
// |V| <= mu (-N) (the row keeps mu in `area`), no couple. The metric is
// isotropic over the force (ml), so the projection onto the cone is the
// Euclidean one; a couple's projection is 0 in any diagonal metric.
__device__ __forceinline__ bool projectContact(const Bond& b,float* x)
{
    const float before[6]={x[0],x[1],x[2],x[3],x[4],x[5]};
    const float mu=b.area,s=-x[0],v=sqrtf(x[1]*x[1]+x[2]*x[2]);
    x[3]=x[4]=x[5]=0.0f;
    if(v<=mu*s) {}
    else if(mu*v<=-s){x[0]=x[1]=x[2]=0.0f;}
    else {
        const float t=(s+mu*v)/(1.0f+mu*mu);
        x[0]=-t;const float k=v>0.0f?mu*t/v:0.0f;x[1]*=k;x[2]*=k;
    }
    for(int q=0;q<6;++q)if(x[q]!=before[q])return true;
    return false;
}
__device__ __forceinline__ bool project(const Bond& b,float* x,float ml,float mt,float m0,float m1)
{
    if(b.flags&eCONTACT)return projectContact(b,x);
    const float sl=sqrtf(ml);
    bool moved=false;
    if(b.g0>0.0f) {   // (N, M0, M1), the section's L1 bending
        const float before[3]={x[0],x[4],x[5]};
        float p[3]={x[0],fabsf(x[4]),fabsf(x[5])};const float sc[3]={sl,sqrtf(m0),sqrtf(m1)};
        polytope(p,sc,b.g0,b.g1,b.h0,b.h1,b.capT,b.capC);
        x[0]=p[0];x[4]=copysignf(p[1],before[1]);x[5]=copysignf(p[2],before[2]);
        moved=x[0]!=before[0] || x[4]!=before[1] || x[5]!=before[2];
    } else {   // (N, M_t): base -cF a .. tF a, apex where both fibres reach capacity.
        const float sa=sqrtf(m0);   // the round set has m0 == m1
        const float m=sqrtf(x[4]*x[4]+x[5]*x[5]);
        float s=sl*x[0],r=sa*m;
        if(triangle(s,r,-sl*b.capC,0.0f,sl*b.capT,0.0f,0.5f*sl*(b.capT-b.capC),0.5f*sa*(b.capT+b.capC)/b.gb)) {
            moved=true;const float mn=r/sa;x[0]=s/sl;
            if(m>0.0f){x[4]*=mn/m;x[5]*=mn/m;}else{x[4]=x[5]=0.0f;}
        }
    }
    {   // (T, V): |V| + gt |T| <= sF a.
        const float sa=sqrtf(mt);
        const float v=sqrtf(x[1]*x[1]+x[2]*x[2]);
        float s=sa*x[3],r=sl*v;
        if(triangle(s,r,-sa*b.capS/b.gt,0.0f,sa*b.capS/b.gt,0.0f,0.0f,sl*b.capS)) {
            moved=true;const float vn=r/sl;x[3]=s/sa;
            if(v>0.0f){x[1]*=vn/v;x[2]*=vn/v;}else{x[1]=x[2]=0.0f;}
        }
    }
    return moved;
}
// Whether a bond-frame wrench lies in its link's set, to `tol` of its
// capacity (the projection's own check: a point outside is a bug).
__device__ __forceinline__ bool feasible(const Bond& b,const float* x,float tol)
{
    if(b.flags&eCONTACT) {
        const float scale=fmaxf(b.capC,1.0f),V=sqrtf(x[1]*x[1]+x[2]*x[2]);
        return x[0]<=tol*scale && V<=b.area*fmaxf(-x[0],0.0f)+tol*scale && fabsf(x[3])+fabsf(x[4])+fabsf(x[5])==0.0f;
    }
    return utilisation(b,x)<=1.0f+tol;
}
// The return map: the projection in the joint's compliance metric K^-1.
__device__ __forceinline__ bool returnMap(const Bond& b,float* x){return project(b,x,1.0f/b.kl,1.0f/b.kt,1.0f/b.k0,1.0f/b.k1);}

// Bond b's wrench (bond frame) on one of its chunks: chunk0 gets force +lin at
// the centroid and couple -M_c; chunk1 force -lin there and couple +M_c.
__device__ __forceinline__ void addWrench(const Bond& b,const float* x,bool first,float* r)
{
    float lin[3],ang[3];toWorld(b,x,lin,ang);
    const float* o=first?b.o0:b.o1;const float s=first?1.0f:-1.0f;
    float m[3];cross3(o,lin,m);
    for(int k=0;k<3;++k){r[k]+=s*lin[k];r[3+k]+=s*(m[k]-ang[k]);}
}
// B_b^T v (the adjoint of addWrench): the centroid's velocity (or
// acceleration, or displacement) on chunk0 less that on chunk1, and chunk1's
// rotation less chunk0's, bond frame. A joint force does work J . B_b^T v.
__device__ __forceinline__ void relative(const Bond& b,const float* v,float* e)
{
    float lin[3]={0,0,0},ang[3]={0,0,0};
    if(b.flags&eDYNAMIC0){const float* q=v+6*b.c0;float m[3];cross3(q+3,b.o0,m);
        for(int k=0;k<3;++k){lin[k]+=q[k]+m[k];ang[k]-=q[3+k];}}
    if(b.flags&eDYNAMIC1){const float* q=v+6*b.c1;float m[3];cross3(q+3,b.o1,m);
        for(int k=0;k<3;++k){lin[k]-=q[k]+m[k];ang[k]+=q[3+k];}}
    e[0]=dot3(lin,b.n);e[1]=dot3(lin,b.t1);e[2]=dot3(lin,b.t2);
    e[3]=dot3(ang,b.n);e[4]=dot3(ang,b.t1);e[5]=dot3(ang,b.t2);
}

__device__ __forceinline__ bool chunkGone(const Inputs& in,PxU32 c){return in.crushed && in.crushed[c].crushed;}
__device__ __forceinline__ bool bondMember(const Inputs& in,PxU32 i)
{
    if(!(in.health[i]>0.0f))return false;
    const auto& b=in.bonds[i];return !chunkGone(in,b.chunk0) && !chunkGone(in,b.chunk1);
}

// ---------------------------------------------------------------------------
// Ci: crush by the impact's own contact pressure. The 1-D elastic impact
// stress Z1 Z2 / (Z1 + Z2) v_n (Z = rho c, the acoustic impedance; an impactor
// whose own structure gives way -- a vehicle's front -- has the effective
// impedance of that crush) as a uniaxial compression through the material's
// crush law (extStressCrushStep): p = sigma/3, q = sigma.
// ---------------------------------------------------------------------------
__device__ __forceinline__ float impactStress(float impactor,float target,float closing)
{
    if(!(impactor>0.0f) || !(target>0.0f) || !(closing>0.0f))return 0.0f;
    return impactor*target/(impactor+target)*closing;
}
template<class Crush>
__device__ __forceinline__ ExtStressCrushState crushByImpact(float sigma,float volume,float mass,float rate,float dt,
    const Crush& material,ExtStressCrushState state)
{
    // A uniaxial compression sigma along any axis: virial / volume = -sigma e e^T.
    float virial[6]={-sigma*volume,0.0f,0.0f,0.0f,0.0f,0.0f};
    return extStressCrushStep(virial,volume,mass,rate,dt,material,state);
}

// ---------------------------------------------------------------------------
// Trigger: an island is solved when its elastic solution has a bond past capacity.
// ---------------------------------------------------------------------------
__device__ __forceinline__ bool prepareBond(const Inputs& in,const Settings& s,PxU32 i,Bond& b)
{
    const auto bond=in.bonds[i];const float area=in.health[i];
    if(!(area>0.0f && area<0.5f*FLT_MAX))return false;
    const auto c0=in.chunks[bond.chunk0],c1=in.chunks[bond.chunk1];
    const PxVec3 displacement=c1.position-c0.position;
    PxVec3 normal=bond.normal*copysignf(1.0f,bond.normal.dot(displacement));
    const float l=normal.magnitude();normal=l>0.0f?normal*(1.0f/l):PxVec3(1.0f,0.0f,0.0f);
    b.bond=i;b.c0=bond.chunk0;b.c1=bond.chunk1;
    b.flags=eALIVE|(c0.mass>0.0f?eDYNAMIC0:0u)|(c1.mass>0.0f?eDYNAMIC1:0u);
    if(in.ductileSlip && in.ductileSlip[bond.material]>0.0f){b.flags|=eDUCTILE;b.slip=in.ductileSlip[bond.material];}else b.slip=0.0f;
    const PxDestructionBondSection section=(s.sectionBending && in.sections)?in.sections[i]:PxDestructionBondSection{};
    if(s.sectionBending && section.bendModulus0>0.0f) {
        // The section's principal axes: t1 its axis, t2 = n x axis.
        PxVec3 axis=section.axis-normal*section.axis.dot(normal);axis.normalize();
        const PxVec3 axis1=normal.cross(axis);
        b.n[0]=normal.x;b.n[1]=normal.y;b.n[2]=normal.z;b.t1[0]=axis.x;b.t1[1]=axis.y;b.t1[2]=axis.z;
        b.t2[0]=axis1.x;b.t2[1]=axis1.y;b.t2[2]=axis1.z;
    } else frame(normal,b.n,b.t1,b.t2);
    // The stress solver's wrench acts at the chunks' midpoint P when both are
    // dynamic (at the centroid when one is a support), and the stage's
    // capped-gain formula reads its moment there: so do E's cones, so a joint's
    // capacity is the one today's verdict uses (and the trigger matches it at
    // rest). momentAtCentroid moves E's wrench to the centroid (the impact
    // study's convention, for comparison with it); pc converts between the two.
    const PxVec3 P=(!s.solverAtCentroid && c0.mass>0.0f && c1.mass>0.0f)?c0.position+displacement*0.5f:bond.centroid;
    // The section verdict reads the moment at the centroid.
    const PxVec3 point=(s.momentAtCentroid || s.sectionBending)?bond.centroid:P;
    const PxVec3 o0=point-c0.position,o1=point-c1.position,pc=P-point;
    b.o0[0]=o0.x;b.o0[1]=o0.y;b.o0[2]=o0.z;b.o1[0]=o1.x;b.o1[1]=o1.y;b.o1[2]=o1.z;
    b.pc[0]=pc.x;b.pc[1]=pc.y;b.pc[2]=pc.z;
    const auto m=in.materials[bond.material];
    b.area=area;b.capC=m.compressionFatalLimit*area;b.capT=m.tensionFatalLimit*area;b.capS=m.shearFatalLimit*area;
    const float root=sqrtf(area>1e-6f?area:1e-6f);
    // Stress = force / area with these gains on moments (extStressCalcBondStress).
    b.g0=b.g1=0.0f;
    if(!s.sectionBending){b.gb=fminf(6.0f/root,s.bendGainMax);b.gt=fminf(4.81f/root,s.bendGainMax);}
    else if(section.bendModulus0>0.0f && section.bendModulus1>0.0f && section.twistModulus>0.0f && bond.area>0.0f) {
        // extStressCalcBondStressSection: the moduli shrink with the live area.
        const float live=area/bond.area;
        b.g0=area/(section.bendModulus0*live);b.g1=area/(section.bendModulus1*live);b.gt=area/(section.twistModulus*live);b.gb=b.g0;
        b.h0=b.g0;b.h1=b.g1;
        // A bearing joint (PX_DESTRUCTION_BEARING_JOINTS): its fasteners' tension
        // T = |M0|/d0 + |M1|/d1 + N, as the verdict grades it.
        if(section.bearingDepth0>0.0f && section.bearingDepth1>0.0f){b.h0=1.0f/section.bearingDepth0;b.h1=1.0f/section.bearingDepth1;}
    } else {
        // No section data: the square patch of the remaining area, uncapped.
        b.gb=6.0f/root;b.gt=4.2426407f/root;
    }
    // The stress solve's weights: w^2 on forces, (w L)^2 on moments.
    const float w=bond.complianceScale,k=s.stiffnessScale*(in.stiffness?in.stiffness[bond.material]:s.stiffness)*w*w;
    b.kl=k;b.kt=b.k0=b.k1=k*s.lengthScale*s.lengthScale;b.dl=b.dt=b.d0=b.d1=1.0f;
    if(s.sectionRotation) {
        // ExtStressGpuSetBondRotationalStiffness: k r^2 about each principal
        // axis of the section (its radii of gyration, or the square patch of
        // the authored area), k r_p^2 in twist.
        float r0=section.gyration0,r1=section.gyration1,rp=section.polarGyration;
        if(!(r0>0.0f)){r0=r1=sqrtf(bond.area/12.0f);rp=r0*1.41421356f;}
        b.k0=k*r0*r0;b.k1=k*r1*r1;b.kt=k*rp*rp;
    }
    return true;
}

// The forces a bond carries this tick if no joint reaches a new event: its
// carried state plus the elastic solve's increment since the last
// evaluation (exact while every joint stays within capacity: the state
// balanced the last loads, the increment balances their change).
__device__ __forceinline__ PxDestructionVectorPair carriedForces(const Inputs& in,PxU32 i)
{
    const auto a=in.base[i],e=in.elastic[i],o=(in.elasticBase?in.elasticBase:in.base)[i];
    PxDestructionVectorPair f;f.linear=a.linear+(e.linear-o.linear);f.angular=a.angular+(e.angular-o.angular);return f;
}
__device__ __forceinline__ bool isCarried(const Inputs& in,PxU32 i){return in.carried && in.carried[i] && in.elasticBase;}
// islandFlag bits: 1 the island is solved (a joint reaches a new event, or
// its carried state lost a joint); 2 it carries a plastic state.
__global__ void trigger(Inputs in,Settings s,Scratch w)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=in.bondCount)return;
    if(in.stage && (in.stage->error & 4096u))return;
    const bool carried=isCarried(in,i);
    PxU32 island=in.bondIslands[i];
    if(!bondMember(in,i)) {
        // A carried joint gone since (broken, crushed): the forces it carried
        // no longer balance its neighbours' -- its island is solved again.
        if(!carried)return;
        const auto& bond=in.bonds[i];
        for(PxU32 c:{bond.chunk0,bond.chunk1})if(c<in.chunkCount && in.chunks[c].mass>0.0f && !chunkGone(in,c)){const PxU32 k=in.nodeIslands[c];if(k<in.chunkCount)atomicOr(w.islandFlag+k,1u);}
        return;
    }
    if(island>=in.chunkCount)return;
    Bond b;if(!prepareBond(in,s,i,b))return;
    float x[6];
    if(carried) {
        toLocal(b,carriedForces(in,i),x);
        if(!(w.islandFlag[island]&2u))atomicOr(w.islandFlag+island,2u);
        if(utilisation(b,x)>1.0f+s.capacityTolerance && !(w.islandFlag[island]&1u))atomicOr(w.islandFlag+island,1u);
    } else {
        toLocal(b,in.elastic[i],x);
        if(utilisation(b,x)>=1.0f && !(w.islandFlag[island]&1u))atomicOr(w.islandFlag+island,1u);
    }
}
// Islands that carry a plastic state and reach no new event: their bonds
// take the carried forces (held, or yielded at capacity), no solve.
__global__ void carryIslands(Inputs in,Settings s,Scratch w)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=in.bondCount)return;
    if(in.stage && (in.stage->error & 4096u))return;
    const PxU32 island=in.bondIslands[i];if(island>=in.chunkCount || w.islandFlag[island]!=2u)return;
    if(!bondMember(in,i))return;
    Bond b;if(!prepareBond(in,s,i,b))return;
    const auto f=isCarried(in,i)?carriedForces(in,i):in.elastic[i];
    float x[6];toLocal(b,f,x);
    w.forces[i]=f;w.verdict[i]=utilisation(b,x)>=1.0f-s.capacityBand?eYIELDED:eHELD;
}
__global__ void listIslands(Inputs in,Scratch w)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=in.chunkCount)return;
    if((w.islandFlag[i]&1u) && in.nodeIslands[i]==i){const PxU32 k=atomicAdd(w.counters,1u);w.islands[k]=i;}
}

// ---------------------------------------------------------------------------
// The island solve: one block per triggered island.
// ---------------------------------------------------------------------------
constexpr PxU32 kThreads=256;
struct Shared {
    float sum[kThreads];
    float big[kThreads];
    PxU32 scan[kThreads];
    PxU32 base,count,flag;
};
__device__ float blockSum(Shared& sh,float v)
{
    sh.sum[threadIdx.x]=v;__syncthreads();
    for(PxU32 o=kThreads/2;o;o>>=1){if(threadIdx.x<o)sh.sum[threadIdx.x]+=sh.sum[threadIdx.x+o];__syncthreads();}
    const float r=sh.sum[0];__syncthreads();return r;
}
__device__ float blockMax(Shared& sh,float v)
{
    sh.big[threadIdx.x]=v;__syncthreads();
    for(PxU32 o=kThreads/2;o;o>>=1){if(threadIdx.x<o)sh.big[threadIdx.x]=fmaxf(sh.big[threadIdx.x],sh.big[threadIdx.x+o]);__syncthreads();}
    const float r=sh.big[0];__syncthreads();return r;
}
__device__ float blockMin(Shared& sh,float v){return -blockMax(sh,-v);}
// The index carried with the block's largest value.
__device__ PxU32 blockArgMax(Shared& sh,float v,PxU32 index)
{
    sh.big[threadIdx.x]=v;sh.scan[threadIdx.x]=index;__syncthreads();
    for(PxU32 o=kThreads/2;o;o>>=1){if(threadIdx.x<o && sh.big[threadIdx.x+o]>sh.big[threadIdx.x]){sh.big[threadIdx.x]=sh.big[threadIdx.x+o];sh.scan[threadIdx.x]=sh.scan[threadIdx.x+o];}__syncthreads();}
    const PxU32 r=sh.scan[0];__syncthreads();return r;
}
__device__ PxU32 blockCount(Shared& sh,PxU32 v)
{
    sh.scan[threadIdx.x]=v;__syncthreads();
    for(PxU32 o=kThreads/2;o;o>>=1){if(threadIdx.x<o)sh.scan[threadIdx.x]+=sh.scan[threadIdx.x+o];__syncthreads();}
    const PxU32 r=sh.scan[0];__syncthreads();return r;
}
// Exclusive prefix of v over the block; returns the total.
__device__ PxU32 blockScan(Shared& sh,PxU32 v,PxU32& prefix)
{
    sh.scan[threadIdx.x]=v;__syncthreads();
    for(PxU32 o=1;o<kThreads;o<<=1){
        const PxU32 add=threadIdx.x>=o?sh.scan[threadIdx.x-o]:0u;__syncthreads();
        sh.scan[threadIdx.x]+=add;__syncthreads();
    }
    prefix=sh.scan[threadIdx.x]-v;const PxU32 total=sh.scan[kThreads-1];__syncthreads();return total;
}

// nb joints then nr contact rows from b0 (links b0 .. b0+nb+nr); nc chunks
// then ni impactors from c0.
struct Island { PxU32 b0,nb,nr,c0,nc,ni; };
__device__ __forceinline__ PxU32 links(const Island& is){return is.nb+is.nr;}
__device__ __forceinline__ PxU32 nodes(const Island& is){return is.nc+is.ni;}
// Symmetric 3x3 (xx, yy, zz, xy, xz, yz) times a vector.
__device__ __forceinline__ void symMul(const float* S,const float* v,float* o)
{
    o[0]=S[0]*v[0]+S[3]*v[1]+S[4]*v[2];o[1]=S[3]*v[0]+S[1]*v[1]+S[5]*v[2];o[2]=S[4]*v[0]+S[5]*v[1]+S[2]*v[2];
}
// u = M^-1 r and o = M v for one node (force, torque / acceleration, angular).
__device__ __forceinline__ void accelerate(const Chunk& c,const float* r,float* u)
{
    for(int q=0;q<3;++q)u[q]=r[q]*c.im;
    if(c.tensor)symMul(c.Iinv,r+3,u+3);else for(int q=0;q<3;++q)u[3+q]=r[3+q]*c.ii;
}
__device__ __forceinline__ void momentum(const Chunk& c,const float* v,float* o)
{
    for(int q=0;q<3;++q)o[q]=v[q]/c.im;
    if(c.tensor)symMul(c.I,v+3,o+3);else for(int q=0;q<3;++q)o[3+q]=c.ii>0.0f?v[3+q]/c.ii:0.0f;
}
// A node's inverse mass and a bound on its inverse inertia (the majoriser).
__device__ __forceinline__ void nodeInverse(const Inputs& in,const Scratch& w,PxU32 node,float& im,float& ii)
{
    if(node<in.chunkCount){const auto c=in.chunks[node];im=1.0f/c.mass;ii=c.inertia>0.0f?1.0f/c.inertia:0.0f;}
    else{im=w.impactorMass[2*(node-in.chunkCount)];ii=w.impactorMass[2*(node-in.chunkCount)+1];}
}

// u = M^-1 (p(lambda) - r_prev + B J) per chunk (J the bond-frame forces given);
// with total, r_prev is left out and the chunk's whole acceleration results.
__device__ void chunkPass(const Inputs& in,const Scratch& w,const Island& is,float lambda,const float* J,bool total)
{
    (void)in;
    for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];
        float r[6];for(int q=0;q<6;++q)r[q]=(1.0f-lambda)*c.pb[q]+lambda*c.pf[q]-(total?0.0f:c.r[q]);
        for(PxU32 slot=c.begin;slot<c.end;++slot) {
            const PxU32 l=w.adj[slot];const Bond& b=w.bonds[l];if(!(b.flags&eALIVE))continue;
            addWrench(b,J+6*l,b.c0==c.chunk,r);
        }
        accelerate(c,r,w.u+6*c.chunk);
    }
}

// The majoriser of the dual's Hessian B^T M^-1 B + (K dt^2)^-1 per joint:
// Gershgorin over each dynamic endpoint's live joints, bounded by its diagonal
// (|o x f - m|^2 <= 2|o|^2|f|^2 + 2|m|^2).
__device__ void precondition(const Inputs& in,const Settings& s,const Scratch& w,const Island& is)
{
    for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];PxU32 degree=0;
        for(PxU32 slot=c.begin;slot<c.end;++slot)degree+=(w.bonds[w.adj[slot]].flags&eALIVE)?1u:0u;
        w.degree[c.chunk]=degree;
    }
    __syncthreads();
    (void)s;
    for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads) {
        Bond& b=w.bonds[is.b0+k];
        float dl=0.0f,da=0.0f;
        for(int e=0;e<2;++e) {
            if(!(b.flags&(e?eDYNAMIC1:eDYNAMIC0)))continue;
            const PxU32 node=e?b.c1:b.c0;float im,ii;nodeInverse(in,w,node,im,ii);const float d=float(w.degree[node]);
            const float* o=e?b.o1:b.o0;
            dl+=d*(im+2.0f*dot3(o,o)*ii);da+=d*2.0f*ii;
        }
        // The kinetic part alone: the ADMM penalty's scale (rho D).
        b.dl=dl>0.0f?dl:1.0f;b.dt=b.d0=b.d1=da>0.0f?da:1.0f;
    }
    __syncthreads();
}

// One solve at load level lambda, from the current J: ADMM on the dual
//   minimise 1/2 |p - r_prev + B J|^2_M^-1 + 1/2 |J - T|^2_C   over J in C_b
// (C = (K dt^2)^-1), split J = Z with Z in the capacity sets: the J step is a
// linear solve, done in chunk space (Woodbury: (A + B^T M^-1 B)^-1 through
// N = M + B A^-1 B^T, A = C + R) by conjugate gradients preconditioned with
// each chunk's exact 6x6 block -- so a long member's lever, which couples its
// joints' forces and moments, costs nothing -- and the Z step is the exact
// projection in the penalty's diagonal metric R = rho D (D the kinetic
// majoriser). Converged when the split closes (|J - Z| within 1e-4 of the
// joint's capacity) and the motion is settled (the dual residual moves the
// joint's chunks by at most `tolerance` over the tick). Returns ADMM steps.
__device__ __forceinline__ void penalty(const Bond& b,float rho,float inverseDt2,float* Ainv,float* R)
{
    const float k[6]={b.kl,b.kl,b.kl,b.kt,b.k0,b.k1},d[6]={b.dl,b.dl,b.dl,b.dt,b.d0,b.d1};
    for(int q=0;q<6;++q){R[q]=rho*d[q];Ainv[q]=1.0f/(inverseDt2/k[q]+R[q]);}
}
// N v = M v + B A^-1 B^T v into out, for every island chunk.
__device__ void nodeApply(const Inputs& in,const Scratch& w,const Island& is,float rho,float inverseDt2,const float* v,float* out)
{
    (void)in;
    for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads) {
        const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];float* f=w.a+6*l;
        if(!(b.flags&eALIVE)){for(int q=0;q<6;++q)f[q]=0.0f;continue;}
        float e[6],Ainv[6],R[6];relative(b,v,e);penalty(b,rho,inverseDt2,Ainv,R);
        for(int q=0;q<6;++q)f[q]=Ainv[q]*e[q];
    }
    __syncthreads();
    for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];float r[6]={0,0,0,0,0,0};
        for(PxU32 slot=c.begin;slot<c.end;++slot) {
            const PxU32 l=w.adj[slot];const Bond& b=w.bonds[l];if(!(b.flags&eALIVE))continue;
            // addWrench gives B f; N's sign: M v + B A^-1 B^T v (B^T = relative, its adjoint).
            addWrench(b,w.a+6*l,b.c0==c.chunk,r);
        }
        const float* vc=v+6*c.chunk;float* o=out+6*c.chunk;
        momentum(c,vc,o);for(int q=0;q<6;++q)o[q]+=r[q];
    }
    __syncthreads();
}
// Each chunk's 6x6 block of N, inverted (Gauss-Jordan; symmetric positive definite).
__device__ void blockJacobi(const Inputs& in,const Scratch& w,const Island& is,float rho,float inverseDt2)
{
    (void)in;
    for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];float N[6][12];
        for(int a=0;a<6;++a)for(int e=0;e<12;++e)N[a][e]=0.0f;
        for(int q=0;q<3;++q){N[q][q]=1.0f/c.im;N[3+q][3+q]=c.ii>0.0f?1.0f/c.ii:0.0f;}
        if(c.tensor){const int map[3][3]={{0,3,4},{3,1,5},{4,5,2}};for(int a=0;a<3;++a)for(int e=0;e<3;++e)N[3+a][3+e]=c.I[map[a][e]];}
        for(PxU32 slot=c.begin;slot<c.end;++slot) {
            const Bond& b=w.bonds[w.adj[slot]];if(!(b.flags&eALIVE))continue;
            float Ainv[6],R[6];penalty(b,rho,inverseDt2,Ainv,R);
            const bool first=b.c0==c.chunk;
            for(int q=0;q<6;++q) {
                // Column q: B_ib A^-1 B_ib^T e_q.
                float unit[6]={0,0,0,0,0,0};unit[q]=1.0f;
                float lin[3]={0,0,0},ang[3]={0,0,0};
                const float* o=first?b.o0:b.o1;const float sg=first?1.0f:-1.0f;
                if(q<3)lin[q]=sg;else{float m[3];cross3(unit+3,o,m);for(int t=0;t<3;++t){lin[t]=sg*m[t];ang[t]=-sg*unit[3+t];}}
                float e[6]={dot3(lin,b.n),dot3(lin,b.t1),dot3(lin,b.t2),dot3(ang,b.n),dot3(ang,b.t1),dot3(ang,b.t2)};
                for(int t=0;t<6;++t)e[t]*=Ainv[t];
                float r[6]={0,0,0,0,0,0};addWrench(b,e,first,r);
                for(int t=0;t<6;++t)N[t][q]+=r[t];
            }
        }
        for(int a=0;a<6;++a)N[a][6+a]=1.0f;
        bool ok=true;
        for(int col=0;col<6;++col) {
            const float piv=N[col][col];if(!(piv>0.0f)){ok=false;break;}
            const float inv=1.0f/piv;for(int e=0;e<12;++e)N[col][e]*=inv;
            for(int a=0;a<6;++a)if(a!=col){const float f=N[a][col];if(f!=0.0f)for(int e=0;e<12;++e)N[a][e]-=f*N[col][e];}
        }
        float* out=w.cinv+36*size_t(c.chunk);
        for(int a=0;a<6;++a)for(int e=0;e<6;++e)out[6*a+e]=ok?N[a][6+e]:(a==e?1.0f:0.0f);
    }
    __syncthreads();
}
// The largest motion over the tick, 1/2 dt^2 |M^-1 r| (rotations at the length
// scale), of the node-space conjugate gradient's residual r (w.cr).
__device__ float residualMotion(Shared& sh,const Settings& s,const Scratch& w,const Island& is)
{
    float m=0.0f;
    for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];float a[6];accelerate(c,w.cr+6*c.chunk,a);
        m=fmaxf(m,fmaxf(sqrtf(a[0]*a[0]+a[1]*a[1]+a[2]*a[2]),sqrtf(a[3]*a[3]+a[4]*a[4]+a[5]*a[5])*s.lengthScale));
    }
    return 0.5f*s.dt*s.dt*blockMax(sh,m);
}
__device__ __forceinline__ void blockApply(const float* M,const float* v,float* o)
{
    for(int a=0;a<6;++a){float t=0.0f;for(int e=0;e<6;++e)t+=M[6*a+e]*v[e];o[a]=t;}
}
// The ADMM state that persists between dispatches (and, rho and U, between
// the solves of one island's evaluation: a warm start).
struct SolveState { PxU32 it,started,diverged,pad; float rho,last,least,pad2; };
// Runs at most `steps` ADMM steps of the solve at load level lambda, resuming
// where the last call stopped; done when converged or at the solve's budget
// (capped). Returns the steps run.
__device__ PxU32 solve(Shared& sh,const Inputs& in,const Settings& s,const Scratch& w,const Island& is,float lambda,
    SolveState& ss,float& budget,float units,bool& done,bool& capped)
{
    const float inverseDt2=1.0f/(s.dt*s.dt);
    precondition(in,s,w,is);
    float rho=ss.rho;
    blockJacobi(in,w,is,rho,inverseDt2);
    // A fresh solve: Z = J (feasible); U, the scaled dual, kept from the
    // island's last solve (zero at its first). The load's own acceleration
    // M^-1 (p - r_prev), every call (it is fixed for the solve).
    if(!ss.started)for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads)for(int q=0;q<6;++q)w.Y[6*(is.b0+k)+q]=w.J[6*(is.b0+k)+q];
    for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];
        float p[6];for(int q=0;q<6;++q){p[q]=(1.0f-lambda)*c.pb[q]+lambda*c.pf[q]-c.r[q];if(!ss.started)w.cy[6*c.chunk+q]=0.0f;}
        accelerate(c,p,w.u+6*c.chunk);
    }
    ss.started=1;
    __syncthreads();
    PxU32 it=ss.it,run=0;done=false;capped=false;float last=ss.last;
    if(!ss.it)ss.least=FLT_MAX;
    float* Z=w.Y;float* U=w.Jn;
    for(;(!run || budget>0.0f) && it<s.iterations;++it,++run) {
        // J step: c = -B^T M^-1 p + C T + R (Z - U); J = A^-1 c - A^-1 B^T y, N y = B A^-1 c.
        for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];float* a=w.a+6*l;
            if(!(b.flags&eALIVE)){for(int q=0;q<6;++q)a[q]=0.0f;continue;}
            float g[6],Ainv[6],R[6];relative(b,w.u,g);penalty(b,rho,inverseDt2,Ainv,R);
            const float k6[6]={b.kl,b.kl,b.kl,b.kt,b.k0,b.k1};
            const float* T=w.T+6*l;const float* z=Z+6*l;const float* uu=U+6*l;
            for(int q=0;q<6;++q)a[q]=Ainv[q]*(-g[q]+inverseDt2/k6[q]*T[q]+R[q]*(z[q]-uu[q]));
        }
        __syncthreads();
        // r = B a - N y (y warm), z = P r, p = z.
        nodeApply(in,w,is,rho,inverseDt2,w.cy,w.cq);   // uses w.a as scratch: recompute B a after
        // nodeApply overwrote w.a; rebuild a (cheap) and form the residual.
        for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];float* a=w.a+6*l;
            if(!(b.flags&eALIVE)){for(int q=0;q<6;++q)a[q]=0.0f;continue;}
            float g[6],Ainv[6],R[6];relative(b,w.u,g);penalty(b,rho,inverseDt2,Ainv,R);
            const float k6[6]={b.kl,b.kl,b.kl,b.kt,b.k0,b.k1};
            const float* T=w.T+6*l;const float* z=Z+6*l;const float* uu=U+6*l;
            for(int q=0;q<6;++q)a[q]=Ainv[q]*(-g[q]+inverseDt2/k6[q]*T[q]+R[q]*(z[q]-uu[q]));
        }
        __syncthreads();
        float rz=0.0f;
        for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
            const Chunk& c=w.chunks[is.c0+k];float ba[6]={0,0,0,0,0,0};
            for(PxU32 slot=c.begin;slot<c.end;++slot) {
                const PxU32 l=w.adj[slot];const Bond& b=w.bonds[l];if(!(b.flags&eALIVE))continue;
                addWrench(b,w.a+6*l,b.c0==c.chunk,ba);
            }
            float* r=w.cr+6*c.chunk;float* zz=w.cz+6*c.chunk;const float* q=w.cq+6*c.chunk;
            for(int t=0;t<6;++t)r[t]=ba[t]-q[t];
            blockApply(w.cinv+36*size_t(c.chunk),r,zz);
            for(int t=0;t<6;++t){w.cp[6*c.chunk+t]=zz[t];rz+=r[t]*zz[t];}
        }
        rz=blockSum(sh,rz);
        // The J step is solved to the solve's tolerance: its residual, as the
        // chunks' motion over the tick it leaves unexplained (1/2 dt^2 M^-1 r),
        // within `tolerance` -- else ADMM's residuals would certify an inexact
        // fixed point. innerIterations bounds the conjugate gradients per step.
        float motion=residualMotion(sh,s,w,is);
        // The step's work in link-and-node visits: five passes, three more per
        // conjugate gradient iteration (Settings::dispatchWork).
        budget-=5.0f*units;
        for(PxU32 inner=0;inner<s.innerIterations && rz>0.0f && motion>s.tolerance;++inner) {
            budget-=3.0f*units;
            nodeApply(in,w,is,rho,inverseDt2,w.cp,w.cq);
            float pq=0.0f;
            for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads){const PxU32 c=w.chunks[is.c0+k].chunk;for(int t=0;t<6;++t)pq+=w.cp[6*c+t]*w.cq[6*c+t];}
            pq=blockSum(sh,pq);if(!(pq>0.0f))break;
            const float alpha=rz/pq;float rz2=0.0f;
            for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
                const PxU32 c=w.chunks[is.c0+k].chunk;float* r=w.cr+6*c;float* zz=w.cz+6*c;
                for(int t=0;t<6;++t){w.cy[6*c+t]+=alpha*w.cp[6*c+t];r[t]-=alpha*w.cq[6*c+t];}
                blockApply(w.cinv+36*size_t(c),r,zz);
                for(int t=0;t<6;++t)rz2+=r[t]*zz[t];
            }
            rz2=blockSum(sh,rz2);
            const float beta=rz2/rz;rz=rz2;
            for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads){const PxU32 c=w.chunks[is.c0+k].chunk;for(int t=0;t<6;++t)w.cp[6*c+t]=w.cz[6*c+t]+beta*w.cp[6*c+t];}
            __syncthreads();
            motion=residualMotion(sh,s,w,is);
        }
        // J = A^-1 (c - B^T y); Z = Pi_R(J + U); U += J - Z.
        float primal=0.0f,dual=0.0f,pn=0.0f,dn=0.0f,worst=-1.0f;PxU32 worstBond=0xffffffffu,bad=0u;
        for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];float* j=w.J+6*l;float* z=Z+6*l;float* uu=U+6*l;
            if(!(b.flags&eALIVE)){for(int q=0;q<6;++q)j[q]=z[q]=uu[q]=0.0f;continue;}
            float g[6],Ainv[6],R[6],ey[6];relative(b,w.u,g);relative(b,w.cy,ey);penalty(b,rho,inverseDt2,Ainv,R);
            const float k6[6]={b.kl,b.kl,b.kl,b.kt,b.k0,b.k1};const float* T=w.T+6*l;
            float x[6],zold[6];
            for(int q=0;q<6;++q){j[q]=Ainv[q]*(-g[q]+inverseDt2/k6[q]*T[q]+R[q]*(z[q]-uu[q])-ey[q]);x[q]=j[q]+uu[q];zold[q]=z[q];}
            // The projected point's size: the projection's rounding is eps of
            // it (a point far outside its set comes back as a difference of
            // large numbers).
            float xl=0.0f,xa=0.0f;for(int q=0;q<6;++q){if(q<3)xl+=x[q]*x[q];else xa+=x[q]*x[q];}
            project(b,x,R[0],R[3],R[4],R[5]);
            if(s.faultInjection==1 && k==0)for(int q=0;q<6;++q)x[q]*=10.0f;
            if(!feasible(b,x,s.capacityTolerance)){atomicAdd(&w.status->infeasible,1u);bad=1u;}
            const float cap=fmaxf(fmaxf(b.capC,b.capT),b.capS);
            float lp=0.0f,ap=0.0f,ld=0.0f,ad=0.0f;
            for(int q=0;q<6;++q) {
                z[q]=x[q];uu[q]+=j[q]-z[q];
                const float rp=j[q]-z[q],rd=R[q]*(z[q]-zold[q]);
                if(q<3){lp+=rp*rp;ld+=rd*rd;}else{ap+=rp*rp;ad+=rd*rd;}
            }
            if(b.flags&eCONTACT) {
                // A contact has no capacity to measure its split against: the
                // motion it would leave unexplained over the tick, to the
                // solve's tolerance (as a fraction of 1e-4, the joints' scale).
                float im0,ii0,im1,ii1;nodeInverse(in,w,b.c0,im0,ii0);nodeInverse(in,w,b.c1,im1,ii1);
                const float motion=0.5f*s.dt*s.dt*(sqrtf(lp)*(im0+im1)+sqrtf(ap)*(ii0+ii1)*s.lengthScale);
                primal=fmaxf(primal,motion/s.tolerance*s.capacityTolerance);
            } else {
                const float gain=fmaxf(fmaxf(b.gb,b.gt),fmaxf(b.g0,b.g1));
                const float mine=(sqrtf(lp)+gain*sqrtf(ap))/cap;
                primal=fmaxf(primal,mine);
                if(mine>worst){worst=mine;worstBond=b.bond;}
            }
            if(w.linkResidual){w.linkResidual[6*l]=(b.flags&eCONTACT)?0.0f:(sqrtf(lp)+fmaxf(fmaxf(b.gb,b.gt),fmaxf(b.g0,b.g1))*sqrtf(ap))/cap;
                w.linkResidual[6*l+1]=0.5f*s.dt*s.dt*fmaxf(sqrtf(ld),sqrtf(ad)*s.lengthScale);}
            // The dual residual R |dZ| as motion over the tick, against the
            // tolerance -- or, where float cannot resolve that, against the
            // motion a few ulps of the joint's own force stand for
            // (1/2 dt^2 R 8 eps |Z|): a soft hinge (k r^2 ~ 2e4 N m/rad on a
            // 2 cm strip) carries 57 N m with R ~ 2e5, and its iterates
            // dither at 1.5e-4 m for ever (65k steps).
            {
                float zl=0.0f,za=0.0f;for(int q=0;q<6;++q){if(q<3)zl+=z[q]*z[q];else za+=z[q]*z[q];}
                const float half=0.5f*s.dt*s.dt,eps8=8.0f*FLT_EPSILON;
                // The J step forms the joint's relative motion from its chunks'
                // accelerations: its rounding is eps of theirs, not of the
                // difference (two chunks falling together under gravity).
                float ua=0.0f,uw=0.0f;
                for(int e=0;e<2;++e){if(!(b.flags&(e?eDYNAMIC1:eDYNAMIC0)))continue;const float* q6=w.u+6*(e?b.c1:b.c0);const float* y6=w.cy+6*(e?b.c1:b.c0);
                    ua+=sqrtf(q6[0]*q6[0]+q6[1]*q6[1]+q6[2]*q6[2])+sqrtf(y6[0]*y6[0]+y6[1]*y6[1]+y6[2]*y6[2]);
                    uw+=sqrtf(q6[3]*q6[3]+q6[4]*q6[4]+q6[5]*q6[5])+sqrtf(y6[3]*y6[3]+y6[4]*y6[4]+y6[5]*y6[5]);}
                const float fl=half*eps8*fmaxf(R[0]*sqrtf(fmaxf(zl,xl)),ua),fa=half*eps8*fmaxf(fmaxf(fmaxf(R[3],R[4]),R[5])*sqrtf(fmaxf(za,xa)),uw)*s.lengthScale;
                const float rl=half*sqrtf(ld),ra=half*sqrtf(ad)*s.lengthScale;
                dual=fmaxf(dual,fmaxf(rl/fmaxf(1.0f,fl/s.tolerance),ra/fmaxf(1.0f,fa/s.tolerance)));
                if(w.linkResidual){float* d=w.linkResidual+6*l;d[2]=rl;d[3]=ra;d[4]=fl;d[5]=fa;}
            }
            pn+=lp+ap;dn+=ld+ad;
        }
        primal=blockMax(sh,primal);dual=blockMax(sh,dual);last=fmaxf(primal,dual/s.tolerance*s.capacityTolerance);
        if(w.trace && !threadIdx.x && blockIdx.x==0 && w.status->solves==w.traceSolve && it<kTraceCapacity){float* t=w.trace+4*it;t[0]=primal;t[1]=dual;t[2]=motion;t[3]=rho;}
        // A projection that left its set is a bug: no verdict from this solve.
        const bool infeasible=blockCount(sh,bad)>0;
        if(!infeasible && !(primal>s.capacityTolerance) && !(dual>s.tolerance) && !(motion>s.tolerance)){done=true;++it;++run;break;}
        // Diverging: a joint's split past kDivergence times its capacity (an
        // iterate no converging solve passes through), or a residual that is
        // not finite, or a projection outside its set.
        const float split=blockMax(sh,worst);
        if(infeasible || !isfinite(last) || (it>=25 && split>kDivergence)) {
            // Diverging: stop; the caller rolls the island back, as for a capped solve.
            const PxU32 bond=blockArgMax(sh,worst,worstBond);
            if(!threadIdx.x){atomicAdd(&w.status->diverged,1u);atomicExch(&w.status->worstBond,bond+1u);}
            ss.diverged=1;done=true;capped=true;++it;++run;break;
        }
        // Balance the residuals (OSQP): rescale rho by sqrt(primal/dual) every
        // 25 steps, each residual against its own tolerance (the split against
        // capacityTolerance, the motion against tolerance) -- the raw sums are
        // in different units (forces, accelerations), and their ratio drove
        // rho down 16x on a house at rest, where the J step's self-stressed
        // part then diverged (the split 4e3 x capacity, never recovering).
        (void)pn;(void)dn;
        const float rp=primal/s.capacityTolerance,rd=dual/s.tolerance;
        // A split closed exactly (rp = 0) with the motion unsettled is the
        // most unbalanced case, not one to skip: rho was never rescaled there
        // (OSQP rebalances on it too).
        if(it%25==24 && (rp>0.0f || rd>0.0f)) {
            const float ratio=rd>0.0f?sqrtf(rp/rd):10.0f;
            if((ratio>5.0f && rho<1e3f) || (ratio<0.2f && rho>1e-3f)) {
                // At most 10x a rebalance, and rho within 1e-3..1e3 of the
                // kinetic majoriser's scale: beyond, the projection's metric
                // spans more than float resolves (rho 1e-6 gave infeasible
                // projections).
                const float next=fminf(fmaxf(rho*fminf(fmaxf(ratio,0.1f),10.0f),1e-3f),1e3f);
                for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads)for(int q=0;q<6;++q)U[6*(is.b0+k)+q]*=rho/next;
                rho=next;__syncthreads();blockJacobi(in,w,is,rho,inverseDt2);
            }
        }
    }
    if(!done && it>=s.iterations){done=true;capped=true;}
    ss.it=it;ss.rho=rho;ss.last=last;
    // The feasible iterate is the answer.
    if(done && !capped)for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads)for(int q=0;q<6;++q)w.J[6*(is.b0+k)+q]=Z[6*(is.b0+k)+q];
    __syncthreads();
    return run;
}

__device__ void finishFailed(const Scratch& w,PxU32 bit){atomicOr(&w.status->error,bit);}

// The coupled contact's rows of an island: a live struck chunk of it, and a
// movable impactor.
__device__ __forceinline__ bool rowMember(const Inputs& in,PxU32 r,PxU32 island)
{
    const ContactRow& row=in.rows[r];
    if(row.chunk>=in.chunkCount || in.nodeIslands[row.chunk]!=island || !(in.chunks[row.chunk].mass>0.0f) || chunkGone(in,row.chunk))return false;
    return row.im>0.0f && isfinite(row.im) && row.points>0;
}
// A contact row as a link: chunk0 the struck chunk, chunk1 the impactor's
// node (set by the caller); n from the chunk to the impactor, so a contact
// force is a compression (N <= 0). Rigid: no compliance.
__device__ __forceinline__ void prepareRow(const Inputs& in,const Settings& s,PxU32 r,Bond& b)
{
    const ContactRow& row=in.rows[r];const auto c=in.chunks[row.chunk];
    PxVec3 n(-row.normal[0],-row.normal[1],-row.normal[2]);
    const float l=n.magnitude();n=l>0.0f?n*(1.0f/l):PxVec3(0.0f,1.0f,0.0f);
    b=Bond{};b.bond=r;b.c0=chainRow(row)?0u:row.chunk;b.c1=0;b.flags=eALIVE|eDYNAMIC0|eDYNAMIC1|eCONTACT;
    frame(n,b.n,b.t1,b.t2);
    const float* origin0=chainRow(row)?row.comA:nullptr;
    for(int q=0;q<3;++q){b.o0[q]=row.point[q]-(origin0?origin0[q]:c.position[q]);b.o1[q]=row.point[q]-row.com[q];b.pc[q]=0.0f;}
    // The residual's scale: the force that stops the impactor in the tick.
    const float v=sqrtf(dot3(row.velocity,row.velocity))+sqrtf(dot3(row.dv,row.dv));
    b.capC=fmaxf(sqrtf(dot3(row.load,row.load))+v/(row.im*s.dt),1.0f);b.capT=b.capS=0.0f;
    b.gb=b.gt=b.g0=b.g1=0.0f;b.kl=b.kt=b.k0=b.k1=FLT_MAX;b.dl=b.dt=b.d0=b.d1=1.0f;b.slip=0.0f;
    b.area=fmaxf(row.friction,0.0f);
}
// An impactor's node from its first row: its momentum at the start of the
// tick (relative to the struck cluster) and the change the trial gave it as
// loads over the tick, d'Alembert: p = m (v + dv) / dt, L = I (w + dw) / dt.
__device__ __forceinline__ Chunk impactorNode(const Inputs& in,const Settings& s,PxU32 r,PxU32 id)
{
    (void)in;const ContactRow& row=in.rows[r];Chunk c{};
    c.chunk=id;c.tensor=1;c.im=row.im;c.ii=0.0f;
    const float* S=row.ii;
    const float A=S[1]*S[2]-S[5]*S[5],B=S[0]*S[2]-S[4]*S[4],C=S[0]*S[1]-S[3]*S[3];
    const float D=S[4]*S[5]-S[3]*S[2],E=S[3]*S[5]-S[1]*S[4],F=S[3]*S[4]-S[0]*S[5];
    const float det=S[0]*A+S[3]*D+S[4]*E;
    if(det>0.0f && isfinite(det)){const float k=1.0f/det;const float I[6]={A*k,B*k,C*k,D*k,E*k,F*k};
        for(int q=0;q<6;++q){c.Iinv[q]=S[q];c.I[q]=I[q];}}
    float w[3];for(int q=0;q<3;++q){c.pf[q]=(row.velocity[q]+row.dv[q])/(row.im*s.dt);w[q]=(row.spin[q]+row.dw[q])/s.dt;}
    symMul(c.I,w,c.pf+3);
    return c;
}

// One island's evaluation, as a state machine that can stop between any two
// ADMM steps and resume in the next dispatch (a dispatch is bounded by
// Settings::dispatchWork, whatever the convergence).
enum Phase : PxU32 { eTRIAL=0, eSOLVE=1, ePOST=2, ePUBLISH=3, eDONE=4 };
struct IslandState {
    Island is;PxU32 island,phase,level,rounds,broken,plastic,failed,capped,clipped,total;
    float first,previous,lambda,snapLambda;SolveState solve;
};

// Setup: members, links, nodes, the ramp's start and first event.
__global__ __launch_bounds__(kThreads) void setupIslands(Inputs in,Settings s,Scratch w)
{
    __shared__ Shared sh;
    const PxU32 islands=w.counters[0];
    for(PxU32 k=blockIdx.x;k<islands;k+=gridDim.x) {
        const PxU32 island=w.islands[k];
        if(!threadIdx.x){w.state[k]=IslandState{};w.state[k].island=island;w.state[k].phase=eDONE;}
        __syncthreads();
        Island is{};
        // Members, in index order (deterministic): count, allocate, compact.
        PxU32 nb=0,nc=0,nr=0;
        for(PxU32 i=threadIdx.x;i<in.bondCount;i+=kThreads) {
            if(in.bondIslands[i]!=island)continue;
            if(bondMember(in,i))++nb;
            // A joint of a chunk crushed before the solve goes with it.
            else if(in.health[i]>0.0f){w.forces[i]=PxDestructionVectorPair();w.verdict[i]=eBROKEN;}
        }
        for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads)nc+=(in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i))?1u:0u;
        PxU32 rowCount=s.coupledContact && in.rows?in.rowCount:0u;
        if(rowCount && in.rowCounter){
            // Rows past the capacity were dropped (their pairs stay uncoupled): error 8.
            if(*in.rowCounter>rowCount && !threadIdx.x && !k)finishFailed(w,8u);
            rowCount=min(*in.rowCounter,rowCount);
        }
        for(PxU32 i=threadIdx.x;i<rowCount;i+=kThreads)nr+=rowMember(in,i,island)?1u:0u;
        nb=blockCount(sh,nb);nc=blockCount(sh,nc);nr=blockCount(sh,nr);
        if(!threadIdx.x){sh.base=atomicAdd(w.counters+1,nb+nr);sh.count=atomicAdd(w.counters+2,nc+nr);}
        __syncthreads();
        is.b0=sh.base;is.nb=nb;is.nr=nr;is.c0=sh.count;is.nc=nc;is.ni=0;
        __syncthreads();
        if(is.b0+nb+nr>in.bondCount+kContactCapacity || is.c0+nc+nr>in.chunkCount+kContactCapacity){if(!threadIdx.x)finishFailed(w,1u);__syncthreads();continue;}
        if(!threadIdx.x)sh.flag=0;
        __syncthreads();
        for(PxU32 tile=0;tile<in.bondCount;tile+=kThreads) {
            const PxU32 i=tile+threadIdx.x;
            const PxU32 member=(i<in.bondCount && in.bondIslands[i]==island && bondMember(in,i))?1u:0u;
            PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
            if(member){const PxU32 l=is.b0+sh.flag+prefix;Bond b;prepareBond(in,s,i,b);w.bonds[l]=b;w.bondLocal[i]=l;}
            __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
        }
        if(!threadIdx.x)sh.flag=0;
        __syncthreads();
        for(PxU32 tile=0;tile<in.chunkCount;tile+=kThreads) {
            const PxU32 i=tile+threadIdx.x;
            const PxU32 member=(i<in.chunkCount && in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i))?1u:0u;
            PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
            if(member) {
                const auto c=in.chunks[i];Chunk ch{};ch.chunk=i;
                ch.im=1.0f/c.mass;ch.ii=c.inertia>0.0f?1.0f/c.inertia:0.0f;
                // Full load over the tick (force, torque about the chunk).
                const auto a=in.accelerations[i];
                ch.pf[0]=a.linear.x*c.mass;ch.pf[1]=a.linear.y*c.mass;ch.pf[2]=a.linear.z*c.mass;
                ch.pf[3]=-a.angular.x*c.inertia;ch.pf[4]=-a.angular.y*c.inertia;ch.pf[5]=-a.angular.z*c.inertia;
                w.chunks[is.c0+sh.flag+prefix]=ch;
                for(int q=0;q<6;++q)w.u[6*i+q]=0.0f;
            }
            __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
        }
        // The coupled contact: the rows (in row order), then one node per
        // impactor body (in the order of its first row).
        if(nr) {
            if(!threadIdx.x)sh.flag=0;
            __syncthreads();
            for(PxU32 tile=0;tile<rowCount;tile+=kThreads) {
                const PxU32 i=tile+threadIdx.x;
                const PxU32 member=(i<rowCount && rowMember(in,i,island))?1u:0u;
                PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
                if(member){Bond b;prepareRow(in,s,i,b);w.bonds[is.b0+nb+sh.flag+prefix]=b;}
                __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
            }
            if(!threadIdx.x)sh.flag=0;
            __syncthreads();
            for(PxU32 tile=0;tile<nr;tile+=kThreads) {
                const PxU32 k=tile+threadIdx.x;PxU32 first=0;
                if(k<nr) {
                    const PxU32 body=in.rows[w.bonds[is.b0+nb+k].bond].body;first=1;
                    for(PxU32 e=0;e<k;++e)if(in.rows[w.bonds[is.b0+nb+e].bond].body==body){first=0;break;}
                }
                PxU32 prefix;const PxU32 total=blockScan(sh,first,prefix);
                if(first) {
                    const PxU32 slot=is.c0+nc+sh.flag+prefix,id=in.chunkCount+slot;
                    w.bonds[is.b0+nb+k].c1=id;
                    w.chunks[slot]=impactorNode(in,s,w.bonds[is.b0+nb+k].bond,id);w.chunks[slot].owner=w.bonds[is.b0+nb+k].bond;
                    const Chunk& c=w.chunks[slot];
                    float largest=0.0f;for(int a=0;a<3;++a){const int m3[3][3]={{0,3,4},{3,1,5},{4,5,2}};
                        largest=fmaxf(largest,fabsf(c.Iinv[m3[a][0]])+fabsf(c.Iinv[m3[a][1]])+fabsf(c.Iinv[m3[a][2]]));}
                    w.impactorMass[2*slot]=c.im;w.impactorMass[2*slot+1]=largest;
                    for(int q=0;q<6;++q)w.u[6*id+q]=0.0f;
                }
                __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
            }
            is.ni=sh.flag;
            __syncthreads();
            // Every other row of an impactor joins its node.
            for(PxU32 k=threadIdx.x;k<nr;k+=kThreads) {
                Bond& b=w.bonds[is.b0+nb+k];if(b.c1)continue;
                const PxU32 body=in.rows[b.bond].body;
                for(PxU32 e=0;e<k;++e){const Bond& f=w.bonds[is.b0+nb+e];if(in.rows[f.bond].body==body && f.c1){b.c1=f.c1;break;}}
            }
            __syncthreads();
            // A chain row's A side: A's node (from its own row). Without one
            // (A's rows lie on another island) the chain row is dropped.
            for(PxU32 k=threadIdx.x;k<nr;k+=kThreads) {
                Bond& b=w.bonds[is.b0+nb+k];const ContactRow& row=in.rows[b.bond];if(!chainRow(row))continue;
                PxU32 node=0;
                for(PxU32 e=0;e<nr && !node;++e){const Bond& f=w.bonds[is.b0+nb+e];if(in.rows[f.bond].body==row.bodyA)node=f.c1;}
                if(node)b.c0=node;else{b.c0=b.c1;b.flags&=~eALIVE;}
            }
            __syncthreads();
            // The trial's force of each coupled pair leaves its chunk's load
            // and its impactor's (the impactor's other loads stay: what the
            // trial gave it, less these pairs).
            for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
                Chunk& c=w.chunks[is.c0+k];
                for(PxU32 e=0;e<nr;++e) {
                    const Bond& b=w.bonds[is.b0+nb+e];const ContactRow& row=in.rows[b.bond];
                    if(!(b.flags&eALIVE))continue;
                    if(b.c0==c.chunk) {
                        for(int q=0;q<3;++q)c.pf[q]-=row.load[q];
                        if(chainRow(row))for(int q=0;q<3;++q)c.pf[3+q]-=row.torqueA[q];
                    }
                    if(k>=nc && b.c1==c.chunk)for(int q=0;q<3;++q){c.pf[q]+=row.load[q];c.pf[3+q]-=row.torque[q];}
                }
            }
            if(!threadIdx.x){atomicAdd(&w.status->contacts,nr);atomicAdd(&w.status->impactors,is.ni);}
            __syncthreads();
        }
        // Each node's links: its joints (the bond graph's), then its contacts.
        for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
            const Chunk& c=w.chunks[is.c0+k];PxU32 degree=0;
            if(k<nc)for(PxU32 slot=in.nodeBegin[c.chunk];slot<in.nodeBegin[c.chunk+1];++slot)degree+=bondMember(in,in.nodeRefs[slot])?1u:0u;
            for(PxU32 e=0;e<nr;++e){const Bond& b=w.bonds[is.b0+nb+e];degree+=(b.c0==c.chunk || b.c1==c.chunk)?1u:0u;}
            w.degree[c.chunk]=degree;
        }
        __syncthreads();
        {
            PxU32 total=0;for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads)total+=w.degree[w.chunks[is.c0+k].chunk];
            total=blockCount(sh,total);
            if(!threadIdx.x){sh.base=atomicAdd(w.counters+3,total);sh.flag=0;}
            __syncthreads();
            if(sh.base+total>2*(in.bondCount+kContactCapacity)){if(!threadIdx.x)finishFailed(w,1u);__syncthreads();continue;}
        }
        for(PxU32 tile=0;tile<nodes(is);tile+=kThreads) {
            const PxU32 k=tile+threadIdx.x;
            const PxU32 degree=k<nodes(is)?w.degree[w.chunks[is.c0+k].chunk]:0u;
            PxU32 prefix;const PxU32 total=blockScan(sh,degree,prefix);
            if(k<nodes(is)) {
                Chunk& c=w.chunks[is.c0+k];c.begin=sh.base+sh.flag+prefix;PxU32 at=c.begin;
                if(k<nc)for(PxU32 slot=in.nodeBegin[c.chunk];slot<in.nodeBegin[c.chunk+1];++slot) {
                    const PxU32 bond=in.nodeRefs[slot];if(bondMember(in,bond))w.adj[at++]=w.bondLocal[bond];
                }
                for(PxU32 e=0;e<nr;++e){const Bond& b=w.bonds[is.b0+nb+e];if(b.c0==c.chunk || b.c1==c.chunk)w.adj[at++]=is.b0+nb+e;}
                c.end=at;
            }
            __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
        }
        __syncthreads();
        // The ramp's start: the previous forces, projected; they balance
        // p_base = -B J_base exactly, at rest (r_prev = 0). No contact force
        // carries over (the impactor arrives this tick).
        for(PxU32 k=threadIdx.x;k<links(is);k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];
            float j[6]={0,0,0,0,0,0};
            if(k<nb){toLocal(b,in.base[b.bond],j);returnMap(b,j);}
            for(int q=0;q<6;++q){w.J[6*l+q]=j[q];w.T[6*l+q]=j[q];}
        }
        __syncthreads();
        for(PxU32 k=threadIdx.x;k<nodes(is);k+=kThreads) {
            Chunk& c=w.chunks[is.c0+k];
            float r[6]={0,0,0,0,0,0};
            for(PxU32 slot=c.begin;slot<c.end;++slot){const PxU32 l=w.adj[slot];const Bond& b=w.bonds[l];addWrench(b,w.J+6*l,b.c0==c.chunk,r);}
            for(int q=0;q<6;++q){c.pb[q]=-r[q];c.r[q]=0.0f;}
        }
        __syncthreads();
        // The ramp.
        // The first event: the smallest load fraction at which a joint below
        // capacity at the start reaches it along the elastic increment
        // (utilisation is convex along the line, so bisection finds it).
        float first=1.0f;
        for(PxU32 k=threadIdx.x;k<nb;k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];const float* J=w.J+6*l;
            if(utilisation(b,J)>=1.0f-s.capacityBand)continue;
            float a[6],o[6];toLocal(b,in.elastic[b.bond],a);toLocal(b,(in.elasticBase?in.elasticBase:in.base)[b.bond],o);
            float x[6];for(int q=0;q<6;++q)x[q]=J[q]+(a[q]-o[q]);
            if(utilisation(b,x)<1.0f)continue;
            float lo=0.0f,hi=1.0f;
            for(int it=0;it<24;++it){const float mid=0.5f*(lo+hi);for(int q=0;q<6;++q)x[q]=J[q]+mid*(a[q]-o[q]);if(utilisation(b,x)<1.0f)lo=mid;else hi=mid;}
            first=fminf(first,hi);
        }
        first=fmaxf(blockMin(sh,first),powf(s.rampFactor,-float(s.rampLevels-1)));
        // The last converged state (the ramp's start until a solve converges):
        // what a capped solve returns to.
        for(PxU32 k2=threadIdx.x;k2<links(is);k2+=kThreads)for(int q=0;q<6;++q){w.Js[6*(is.b0+k2)+q]=w.J[6*(is.b0+k2)+q];w.Jn[6*(is.b0+k2)+q]=0.0f;}
        __syncthreads();
        if(!threadIdx.x) {
            IslandState st{};st.is=is;st.island=island;st.phase=eTRIAL;
            // An impactor's contact is solved from the first level (no elastic
            // solution knows it).
            st.plastic=is.nr>0;st.first=first;st.solve.rho=1.0f;
            w.state[k]=st;
        }
        __syncthreads();
    }
}

// One dispatch of every island's evaluation: at most Settings::dispatchWork
// link-and-node visits of ADMM steps per block, then it stops where it is.
__global__ __launch_bounds__(kThreads) void stepIslands(Inputs in,Settings s,Scratch w)
{
    __shared__ Shared sh;
    const PxU32 islands=w.counters[0];
    float budget=float(s.dispatchWork);
    for(PxU32 k=blockIdx.x;k<islands;k+=gridDim.x) {
        IslandState st=w.state[k];
        if(st.phase==eDONE)continue;
        // This block's dispatch budget is spent: the island waits for the next.
        if(budget<=0.0f){if(!threadIdx.x)atomicAdd(w.counters+4,1u);continue;}
        const Island is=st.is;const PxU32 nb=is.nb,island=st.island;
        // A step costs at least a block's pass however small the island (its
        // synchronisations): a 15-link island ran 4096 steps in one 112 ms dispatch.
        const float units=float(max(links(is)+nodes(is),kThreads));
        while(st.phase!=eDONE && budget>0.0f) {
            if(st.phase==eTRIAL) {
                const float lambda=fminf(1.0f,st.first*powf(s.rampFactor,float(st.level)));
                // The trial: the last forces plus this level's increment of the
                // elastic solution, returned onto capacity.
                PxU32 clipped=0;
                for(PxU32 k2=threadIdx.x;k2<nb;k2+=kThreads) {
                    const PxU32 l=is.b0+k2;const Bond& b=w.bonds[l];
                    if(!(b.flags&eALIVE))continue;
                    float* T=w.T+6*l;float* J=w.J+6*l;
                    float inc[6]={0,0,0,0,0,0};
                    if(lambda!=st.previous && (!st.plastic || s.elasticIncrementAfterYield)){float a[6],o[6];toLocal(b,in.elastic[b.bond],a);toLocal(b,(in.elasticBase?in.elasticBase:in.base)[b.bond],o);
                        for(int q=0;q<6;++q)inc[q]=(lambda-st.previous)*(a[q]-o[q]);}
                    for(int q=0;q<6;++q){T[q]=J[q]+inc[q];J[q]=T[q];}
                    clipped+=returnMap(b,J)?1u:0u;
                }
                clipped=blockCount(sh,clipped);
                st.previous=st.lambda=lambda;st.clipped=clipped;
                if(clipped)st.plastic=1;
                budget-=units;
                if(st.plastic){st.phase=eSOLVE;st.solve.it=0;st.solve.started=0;st.solve.diverged=0;}else st.phase=ePOST;
            }
            if(st.phase==eSOLVE && budget>0.0f) {
                // The evaluation's own budget (Settings::evaluationIterations)
                // caps the solve as its per-solve budget does.
                Settings local=s;local.iterations=min(s.iterations,st.solve.it+(s.evaluationIterations>st.total?s.evaluationIterations-st.total:0u));
                bool done,capped;const PxU32 run=solve(sh,in,local,w,is,st.lambda,st.solve,budget,units,done,capped);
                st.total+=run;
                if(!done)break;   // the dispatch's budget: resume here next dispatch
                ++st.rounds;
                if(!threadIdx.x){const PxU32 slot=atomicAdd(&w.status->solves,1u);atomicAdd(&w.status->iterations,st.solve.it);
                    if(capped && !st.solve.diverged)atomicAdd(&w.status->capped,1u);
                    if(w.log && slot<kLogCapacity)w.log[slot]={island,st.level,st.solve.it,st.broken,st.clipped,capped?1u:0u,links(is),nodes(is),st.lambda,st.solve.last,st.solve.rho,0.0f};}
                if(capped) {
                    // Not converged: no verdict from it. The island goes back to
                    // its last converged state (forces, breaks), and the
                    // evaluation reports itself unconverged (Status::capped).
                    for(PxU32 k2=threadIdx.x;k2<links(is);k2+=kThreads)for(int q=0;q<6;++q)w.J[6*(is.b0+k2)+q]=w.Js[6*(is.b0+k2)+q];
                    __syncthreads();
                    st.capped=1;st.lambda=st.snapLambda;st.phase=ePUBLISH;
                } else st.phase=ePOST;
            }
            if(st.phase==ePOST) {
                const float lambda=st.lambda;const bool final=lambda>=1.0f;
                // The chunks' acceleration so far; it carries into the next solve.
                chunkPass(in,w,is,lambda,w.J,true);
                __syncthreads();
                for(PxU32 k2=threadIdx.x;k2<nodes(is);k2+=kThreads) {
                    Chunk& c=w.chunks[is.c0+k2];const float* u=w.u+6*c.chunk;
                    if(st.plastic)momentum(c,u,c.r);
                }
                __syncthreads();
                // Which joints reached capacity, and which of them fail.
                PxU32 newly=0;
                for(PxU32 k2=threadIdx.x;k2<nb;k2+=kThreads) {
                    const PxU32 l=is.b0+k2;Bond& b=w.bonds[l];float* j=w.J+6*l;
                    if(!(b.flags&eALIVE))continue;
                    if(!(utilisation(b,j)>=1.0f-s.capacityBand))continue;
                    bool fails=!(b.flags&eDUCTILE);
                    if(!fails && final) {
                        // Slip at the centroid over the tick, 1/2 |v_rel| dt = 1/2 |a_rel| dt^2,
                        // on top of what the joint has slipped before.
                        float e[6];relative(b,w.u,e);
                        const float before=in.slipBefore?in.slipBefore[b.bond]:0.0f;
                        fails=before+0.5f*sqrtf(e[0]*e[0]+e[1]*e[1]+e[2]*e[2])*s.dt*s.dt>b.slip;
                    }
                    if(fails){b.flags&=~eALIVE;for(int q=0;q<6;++q)j[q]=0.0f;++newly;
                        if(w.breaks){float e[6];relative(b,w.u,e);w.breaks[2*b.bond]=float(st.rounds)+0.01f*float(st.level);
                            w.breaks[2*b.bond+1]=0.5f*sqrtf(e[0]*e[0]+e[1]*e[1]+e[2]*e[2])*s.dt*s.dt;}}
                }
                newly=blockCount(sh,newly);
                // The converged state (a brittle joint at capacity in a converged
                // field has broken).
                for(PxU32 k2=threadIdx.x;k2<links(is);k2+=kThreads)for(int q=0;q<6;++q)w.Js[6*(is.b0+k2)+q]=w.J[6*(is.b0+k2)+q];
                st.snapLambda=lambda;
                st.broken+=newly;
                if(newly)st.plastic=1;
                budget-=units;
                st.phase=eTRIAL;
                if(!newly){if(final)st.phase=ePUBLISH;else ++st.level;}
                if(st.phase!=ePUBLISH && st.rounds>=s.maxRounds){st.failed=1;st.phase=ePUBLISH;}
                __syncthreads();
            }
            if(st.phase==ePUBLISH) {
                if(st.failed && !threadIdx.x)finishFailed(w,4u);
                // Publish: forces in the solver's convention, verdicts, accelerations.
                chunkPass(in,w,is,st.capped?st.lambda:1.0f,w.J,true);
                __syncthreads();
                PxU32 yielded=0;bool finite=true;
                for(PxU32 k2=threadIdx.x;k2<nb;k2+=kThreads) {
                    const PxU32 l=is.b0+k2;const Bond& b=w.bonds[l];const float* j=w.J+6*l;
                    float lin[3],ang[3];toSolver(b,j,lin,ang);
                    PxDestructionVectorPair f;f.linear=PxVec3(lin[0],lin[1],lin[2]);f.angular=PxVec3(ang[0],ang[1],ang[2]);
                    finite=finite && f.linear.isFinite() && f.angular.isFinite();
                    w.forces[b.bond]=f;
                    PxU32 v=eHELD;float slip=0.0f;
                    if(!(b.flags&eALIVE))v=eBROKEN;
                    else if(utilisation(b,j)>=1.0f-s.capacityBand) {
                        v=eYIELDED;++yielded;
                        // A yielded joint slips with its chunks' relative motion (a held one does not).
                        if(!st.capped){float e[6];relative(b,w.u,e);slip=0.5f*sqrtf(e[0]*e[0]+e[1]*e[1]+e[2]*e[2])*s.dt*s.dt;}
                    }
                    w.verdict[b.bond]=v;if(w.slip)w.slip[b.bond]=slip;
                }
                // Each impactor's end velocity against the trial's (none from an
                // unconverged evaluation: the trial's stands). A struck chunk
                // still joined to the structure stays where it is in the rigid
                // simulation (its cluster is kinematic); its motion in the solve
                // is its joints' deformation, which the rigid simulation does
                // not have. So the solve's velocity stands only if it does not
                // carry the impactor into such a chunk held elastically:
                // otherwise the trial's (the chunk holds it, with the contact's
                // own restitution).
                for(PxU32 k2=is.nc+threadIdx.x;k2<nodes(is) && !st.capped;k2+=kThreads) {
                    const Chunk& c=w.chunks[is.c0+k2];const ContactRow& row=in.rows[c.owner];const float* u=w.u+6*c.chunk;
                    bool into=false;
                    for(PxU32 slot=c.begin;slot<c.end && !into;++slot) {
                        const Bond& r=w.bonds[w.adj[slot]];if(!(r.flags&eCONTACT) || r.c1!=c.chunk || r.c0>=in.chunkCount)continue;
                        // Is the struck chunk still held elastically (a live joint
                        // below capacity)? One whose joints have all broken or
                        // yielded moves with the impactor (plastic slip, until it
                        // breaks); one held below capacity does not.
                        const Chunk* struck=nullptr;
                        for(PxU32 m2=0;m2<is.nc;++m2)if(w.chunks[is.c0+m2].chunk==r.c0){struck=&w.chunks[is.c0+m2];break;}
                        bool held=false;
                        if(struck)for(PxU32 s2=struck->begin;s2<struck->end && !held;++s2){const PxU32 l=w.adj[s2];const Bond& j=w.bonds[l];
                            held=!(j.flags&eCONTACT) && (j.flags&eALIVE) && utilisation(j,w.J+6*l)<1.0f-s.capacityBand;}
                        if(!held || !s.heldStops)continue;
                        // The impactor's velocity at the contact point along the push (n points from the chunk to the impactor).
                        float wv[3];cross3(u+3,r.o1,wv);
                        const float approach=-((u[0]+wv[0])*r.n[0]+(u[1]+wv[1])*r.n[1]+(u[2]+wv[2])*r.n[2])*s.dt;
                        into=approach>s.tolerance/s.dt;
                    }
                    float d[6];
                    for(int q=0;q<3;++q){d[q]=u[q]*s.dt-(row.velocity[q]+row.dv[q]);d[3+q]=u[3+q]*s.dt-(row.spin[q]+row.dw[q]);}
                    if(into){for(int q=0;q<6;++q)d[q]=0.0f;atomicAdd(&w.status->heldStops,1u);}
                    // Passivity: joints and unilateral contacts only take
                    // momentum from an impactor; its end speed cannot exceed
                    // what it started with plus its other loads' change (the
                    // trial's, less the coupled pairs'). Beyond it: a bug.
                    else {
                        // pf: its momentum and every other load over the tick, the coupled pairs' trial forces taken out.
                        float e2=0.0f,b2=0.0f;
                        for(int q=0;q<3;++q){const float o=c.pf[q]*c.im*s.dt;e2+=u[q]*s.dt*u[q]*s.dt;b2+=o*o;}
                        const float start=sqrtf(row.velocity[0]*row.velocity[0]+row.velocity[1]*row.velocity[1]+row.velocity[2]*row.velocity[2]);
                        if(sqrtf(e2)>fmaxf(start,sqrtf(b2))*1.01f+s.tolerance/s.dt){for(int q=0;q<6;++q)d[q]=0.0f;atomicAdd(&w.status->energyGain,1u);}
                    }
                    for(int q=0;q<6;++q)finite=finite && isfinite(d[q]);
                    if(in.rowDelta)for(int q=0;q<6;++q)in.rowDelta[6*c.owner+q]=d[q];
                }
                if(st.capped && is.ni && !threadIdx.x)atomicAdd(&w.status->rolledBack,1u);
                // Each coupled row's force on its chunk (cluster frame).
                for(PxU32 k2=threadIdx.x;k2<is.nr;k2+=kThreads) {
                    const PxU32 l=is.b0+nb+k2;const Bond& b=w.bonds[l];float lin[3],ang[3];toWorld(b,w.J+6*l,lin,ang);
                    finite=finite && isfinite(lin[0]) && isfinite(lin[1]) && isfinite(lin[2]);
                    if(in.rowForce)for(int q=0;q<3;++q)in.rowForce[3*b.bond+q]=lin[q];
                }
                yielded=blockCount(sh,yielded);
                const PxU32 bad=blockCount(sh,finite?0u:1u);
                if(!threadIdx.x) {
                    atomicAdd(&w.status->triggered,1u);atomicAdd(&w.status->broken,st.broken);atomicAdd(&w.status->yielded,yielded);
                    atomicMax(&w.status->rounds,st.rounds);if(bad)atomicOr(&w.status->error,2u);
                }
                st.phase=eDONE;budget-=units;
            }
        }
        if(!threadIdx.x){w.state[k]=st;if(st.phase!=eDONE)atomicAdd(w.counters+4,1u);}
        __syncthreads();
    }
}

// The forces each bond carries after an evaluation: E's where it solved, the
// elastic solve's elsewhere (the next tick's ramp starts here).
__global__ void recordState(const PxU32* islandFlag,const PxU32* bondIslands,const PxDestructionVectorPair* impact,
    const PxDestructionVectorPair* elastic,PxDestructionVectorPair* state,PxU32 count,PxU32* carried=nullptr,
    const float* slip=nullptr,const float* slipBefore=nullptr,float* slipState=nullptr)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 island=bondIslands[i];
    const bool mine=island!=0xffffffffu && islandFlag[island];
    state[i]=mine?impact[i]:elastic[i];
    if(carried)carried[i]=mine?1u:0u;
    // The plastic slip accumulates where the island was solved (from the
    // start of the tick: a corrected pass replaces the trial's).
    if(slipState)slipState[i]=(slipBefore?slipBefore[i]:0.0f)+((slip && mine && (islandFlag[island]&1u))?slip[i]:0.0f);
}

// A solve that ended at its budget did not converge: the stage reports the
// evaluation unconverged (and, where it requires convergence, rejects it, as
// it does an unconverged elastic solve: error 4096).
__global__ void reportConvergence(const Status* impactStatus,PxDestructionStageStatus* stage,bool require,float longestDispatchMs)
{
    const Status& e=*impactStatus;
    stage->impactIslands+=e.triggered;stage->impactSolves+=e.solves;stage->impactSteps+=e.iterations;stage->impactCapped+=e.capped;
    stage->impactDiverged+=e.diverged;stage->impactInfeasible+=e.infeasible;if(e.worstBond)stage->impactWorstBond=e.worstBond;
    stage->impactLongestDispatchMs=fmaxf(stage->impactLongestDispatchMs,longestDispatchMs);
    if(impactStatus->capped || impactStatus->diverged || (impactStatus->error & 4u)) {
        stage->converged=0;
        if(require)atomicOr(&stage->error,4096u);
    }
}

__global__ void markError(Status* status,PxU32 bit){atomicOr(&status->error,bit);}
// Host side: persistent scratch and the launches of one evaluation.
struct Stage {
    Scratch w{};PxU32 n=0,m=0;
    PxU32* pending{};        // pinned: islands not done after the last dispatch
    // The last evaluation's dispatches and the longest of them (host clock,
    // from submission to completion), ms.
    PxU32 dispatches=0;double longestDispatch=0.0,lastSubmit=0.0;
    bool errorUnfinished=false;
    void release() {
        if(pending)cudaFreeHost(pending);pending=nullptr;
        cudaFree(w.islandFlag);cudaFree(w.islands);cudaFree(w.counters);cudaFree(w.bondLocal);cudaFree(w.degree);
        cudaFree(w.bonds);cudaFree(w.chunks);cudaFree(w.J);cudaFree(w.Y);cudaFree(w.Jn);cudaFree(w.T);cudaFree(w.u);
        cudaFree(w.forces);cudaFree(w.verdict);cudaFree(w.status);cudaFree(w.adj);cudaFree(w.impactorMass);cudaFree(w.Js);cudaFree(w.state);cudaFree(w.slip);
        for(float* a:{w.a,w.cy,w.cr,w.cz,w.cp,w.cq,w.cinv})cudaFree(a);w={};n=m=0;
    }
    void allocate(PxU32 chunks,PxU32 bonds) {
        release();n=chunks;m=bonds;
        // Links: the bonds, then contact rows; nodes: the chunks, then the
        // impactors (ids from n, slots after the chunk slots: up to 2n + K).
        const size_t links=size_t(m)+kContactCapacity,slots=size_t(n)+kContactCapacity,ids=size_t(n)+slots;
        ::physx::allocate(w.islandFlag,n);::physx::allocate(w.islands,n);::physx::allocate(w.counters,8);check(cudaMallocHost(&pending,sizeof(PxU32)));
        ::physx::allocate(w.bondLocal,m);::physx::allocate(w.degree,ids);
        ::physx::allocate(w.bonds,links);::physx::allocate(w.chunks,slots);
        ::physx::allocate(w.adj,2*links);::physx::allocate(w.impactorMass,2*slots);
        for(float** a:{&w.J,&w.Y,&w.Jn,&w.T,&w.Js})::physx::allocate(*a,6*links);
        ::physx::allocate(w.state,n);::physx::allocate(w.slip,m);check(cudaMemset(w.slip,0,sizeof(float)*m));
        ::physx::allocate(w.u,6*ids);::physx::allocate(w.a,6*links);::physx::allocate(w.cinv,36*ids);
        for(float** a:{&w.cy,&w.cr,&w.cz,&w.cp,&w.cq}){::physx::allocate(*a,6*ids);check(cudaMemset(*a,0,sizeof(float)*6*ids));}::physx::allocate(w.forces,m);::physx::allocate(w.verdict,m);::physx::allocate(w.status,1);
        check(cudaMemset(w.islandFlag,0,sizeof(PxU32)*n));check(cudaMemset(w.u,0,sizeof(float)*6*ids));
        check(cudaMemset(w.status,0,sizeof(Status)));check(cudaMemset(w.verdict,0,sizeof(PxU32)*m));
    }
    // One evaluation: trigger, list, solve. Leaves islandFlag set for the
    // material kernels, which take E's forces and verdicts on flagged islands.
    void submit(const Inputs& in,const Settings& s,cudaStream_t stream,PxU32 grid=32) {
        check(cudaMemsetAsync(w.islandFlag,0,sizeof(PxU32)*n,stream));
        check(cudaMemsetAsync(w.counters,0,sizeof(PxU32)*8,stream));
        check(cudaMemsetAsync(w.status,0,sizeof(Status),stream));
        check(cudaMemsetAsync(w.slip,0,sizeof(float)*m,stream));
        if(m)trigger<<<(m+127)/128,128,0,stream>>>(in,s,w);
        if(m && in.carried)carryIslands<<<(m+127)/128,128,0,stream>>>(in,s,w);
        if(n)listIslands<<<(n+127)/128,128,0,stream>>>(in,w);
        dispatches=0;longestDispatch=0.0;
        if(!m)return;
        setupIslands<<<grid,kThreads,0,stream>>>(in,s,w);
        // Bounded dispatches (Settings::dispatchWork each), one at a time: the
        // host waits for each and stops when no island has work left. Enough
        // of them for the largest island the scene can have to spend its
        // evaluation budget (ADMM steps, and the ramp's other passes).
        const double units=std::max(double(m)+double(n)+double(in.rows?in.rowCount:0u)*2.0,double(kThreads));
        const double work=(double(s.evaluationIterations)*(5.0+3.0*double(s.innerIterations))+3.0*double(s.maxRounds)+2.0)*units;
        const PxU32 limit=PxU32(std::min(1e6,std::ceil(work/double(s.dispatchWork))+1.0));
        check(cudaStreamSynchronize(stream));
        for(PxU32 d=0;d<limit;++d) {
            const auto t0=std::chrono::steady_clock::now();
            check(cudaMemsetAsync(w.counters+4,0,sizeof(PxU32),stream));
            stepIslands<<<grid,kThreads,0,stream>>>(in,s,w);
            check(cudaMemcpyAsync(pending,w.counters+4,sizeof(PxU32),cudaMemcpyDeviceToHost,stream));
            check(cudaStreamSynchronize(stream));
            longestDispatch=std::max(longestDispatch,std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count());
            ++dispatches;
            if(!*pending)break;
        }
        // Work left after the last dispatch the budget allows: an island
        // never published (its forces are the elastic solve's). A bug.
        if(*pending){std::fprintf(stderr,"[impact] error: %u islands unfinished after %u dispatches\n",*pending,dispatches);
            markError<<<1,1,0,stream>>>(w.status,1u);errorUnfinished=true;}
    }
};

// What the material kernels read: E's forces and verdicts where it solved.
struct View {
    const PxU32* islandFlag{};const PxU32* bondIslands{};
    const PxDestructionVectorPair* forces{};const PxU32* verdict{};
    __device__ bool active(PxU32 bond) const {
        if(!islandFlag)return false;const PxU32 island=bondIslands[bond];
        return island!=0xffffffffu && islandFlag[island];
    }
};

} // namespace impact
