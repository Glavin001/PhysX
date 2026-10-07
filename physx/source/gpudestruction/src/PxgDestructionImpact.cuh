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
// Solver: accelerated projected gradient (FISTA, gradient restart) on J, one
// block per island that has a joint past capacity; per-joint diagonal
// majoriser (Gershgorin over each chunk's live joints) and the exact projection
// in its metric (each capacity set is a solid of revolution whose meridian is a
// triangle). FP32; its iteration budget is its own (Settings::iterations).
//
// Included inside the runtime's namespace (or a test's), after PxDestructionScene.h.
namespace impact {

enum Verdict : PxU32 { eNONE=0, eHELD=1, eYIELDED=2, eBROKEN=3 };
enum BondFlag : PxU32 { eDYNAMIC0=1, eDYNAMIC1=2, eDUCTILE=4, eALIVE=8 };

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
    PxU32 iterations=4096;   // projected iterations per solve
    // Converged when every joint's projected gradient -- the relative
    // acceleration of its two chunks that the solve has not yet balanced or
    // let through -- moves them apart by at most this over the tick
    // (1/2 a dt^2, m; rotations at the solve's length scale): a tenth of a
    // millimetre, far under the 15 mm ultimate slip and a joint's elastic
    // deformation at capacity.
    float tolerance=1e-4f;
    float capacityBand=2e-3f;// at capacity: utilisation >= 1 - capacityBand (the oracle's)
    PxU32 maxRounds=256;     // solves per island per evaluation (levels plus brittle cascades)
    // The elastic solve's increment is the intact structure's. Once a joint
    // has reached capacity, false leaves the load increment to the solve
    // (through p(lambda)); true keeps adding it -- A/B.
    bool elasticIncrementAfterYield=false;
};

// Device-side counters for one evaluation.
struct Status {
    PxU32 triggered;   // islands with a joint past capacity
    PxU32 solves;      // solves run
    PxU32 iterations;  // projected iterations run (sum)
    PxU32 capped;      // solves that ended at the iteration budget
    PxU32 broken;      // joints E broke (brittle at capacity, or ductile past ultimate slip)
    PxU32 yielded;     // ductile joints at capacity that held
    PxU32 rounds;      // largest solve count of any island
    PxU32 error;       // 1: scratch overflow, 2: nonfinite, 4: round budget exhausted
};
// Optional per-solve record (diagnostics): the first kLogCapacity solves.
struct SolveRecord { PxU32 island,level,iterations,broken,clipped,capped; float lambda,change; };
constexpr PxU32 kLogCapacity=256;

struct Bond {
    PxU32 bond,c0,c1,flags;
    float n[3],t1[3],t2[3];  // bond frame (n from chunk0 to chunk1)
    float o0[3],o1[3];       // E's wrench's point from each chunk (the solver's, or the centroid)
    float pc[3];             // the stress solver's application point less E's
    float capC,capT,capS;    // cF a, tF a, sF a (N)
    float gb,gt;             // bending (round set) and torsion gains (1/m): fibre stress x area per unit moment
    float g0,g1;             // bending gains about t1 and t2 (section moduli: the L1 set); 0: the round set (gb |M_t|)
    float kl,kt,k0,k1;       // stiffness on forces (N/m), in twist, and in bending about t1, t2 (N m/rad)
    float dl,dt,d0,d1;       // majoriser of the dual's Hessian, by the same rows
    float slip;              // ultimate slip (m); 0 brittle
    float area;
};
struct Chunk { PxU32 chunk,begin,end,pad; float im,ii; float pb[6],pf[6],r[6]; };

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
    PxDestructionVectorPair* forces{}; // [M] E's bond forces, the stress solver's convention
    PxU32* verdict{};      // [M]
    Status* status{};
    SolveRecord* log{};    // [kLogCapacity] or null; status->solves counts them
    float* breaks{};       // [2M] or null: per bond, the round it broke in and its slip then (diagnostics)
};

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
    const PxDestructionVectorPair* elasticBase{};   // the elastic solve's forces before this tick (null: base)
    const PxDestructionStageStatus* stage{};        // skip when the stage already failed
    const PxDestructionCrushState* crushed{};       // chunks crushed before the solve (Ci), or null
    const PxDestructionBondSection* sections{};     // the section model's sections (Settings::sectionBending), or null
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
    const float tension=fmaxf(N+bend,0.0f),compression=fmaxf(bend-N,0.0f),shear=V+b.gt*T;
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
// Projection of a bond-frame wrench onto C_b in the metric
// diag(ml,ml,ml,ma,ma,ma). The axial set (N, M_t) and the shear set (T, V) are
// independent; each is rotationally symmetric about its scalar axis, so its
// projection keeps the vector part's direction and projects (scalar, |vector|)
// onto the meridian triangle. Returns whether anything moved.
// The section's axial set with an L1 bending term, in its positive quadrant
// (M0, M1 >= 0; the set and a diagonal metric are symmetric under their sign
// flips, so the projection keeps their signs):
//   M0 >= 0, M1 >= 0, g0 M0 + g1 M1 <= capT - N, g0 M0 + g1 M1 <= capC + N.
// In coordinates scaled by the metric's square root it is a polyhedron of
// four half-spaces; the projection is the nearest feasible projection onto
// the affine hull of a subset of their planes (15 subsets).
__device__ __forceinline__ bool halfSpaces(const float (*A)[3],const float* B,const float* q)
{
    for(int k=0;k<4;++k) {
        const float v=A[k][0]*q[0]+A[k][1]*q[1]+A[k][2]*q[2]-B[k];
        const float scale=fabsf(B[k])+fabsf(A[k][0]*q[0])+fabsf(A[k][1]*q[1])+fabsf(A[k][2]*q[2])+1e-30f;
        if(v>1e-5f*scale)return false;
    }
    return true;
}
__device__ __forceinline__ void polytope(float* p,const float* sc,float g0,float g1,float capT,float capC)
{
    // Half-space k: a_k . y <= b_k in scaled coordinates y = sc * x.
    const float A[4][3]={{0.0f,-1.0f/sc[1],0.0f},{0.0f,0.0f,-1.0f/sc[2]},{1.0f/sc[0],g0/sc[1],g1/sc[2]},{-1.0f/sc[0],g0/sc[1],g1/sc[2]}};
    const float B[4]={0.0f,0.0f,capT,capC};
    const float y[3]={sc[0]*p[0],sc[1]*p[1],sc[2]*p[2]};
    if(halfSpaces(A,B,y))return;
    float best[3]={0,0,0},bestD=FLT_MAX;
    for(int mask=1;mask<16;++mask) {
        int idx[3],n=0;for(int k=0;k<4;++k)if(mask&(1<<k)){if(n==3){n=4;break;}idx[n++]=k;}
        if(n>3)continue;
        // q = y - A_S^T (A_S A_S^T)^-1 (A_S y - b_S)
        float G[3][3],r[3];
        for(int a=0;a<n;++a){r[a]=A[idx[a]][0]*y[0]+A[idx[a]][1]*y[1]+A[idx[a]][2]*y[2]-B[idx[a]];
            for(int c=0;c<n;++c)G[a][c]=A[idx[a]][0]*A[idx[c]][0]+A[idx[a]][1]*A[idx[c]][1]+A[idx[a]][2]*A[idx[c]][2];}
        float mu[3]={0,0,0};
        if(n==1){if(!(G[0][0]>0.0f))continue;mu[0]=r[0]/G[0][0];}
        else if(n==2){const float det=G[0][0]*G[1][1]-G[0][1]*G[1][0];if(!(fabsf(det)>1e-20f*(G[0][0]*G[1][1])))continue;
            mu[0]=(r[0]*G[1][1]-r[1]*G[0][1])/det;mu[1]=(G[0][0]*r[1]-G[1][0]*r[0])/det;}
        else {
            const float det=G[0][0]*(G[1][1]*G[2][2]-G[1][2]*G[2][1])-G[0][1]*(G[1][0]*G[2][2]-G[1][2]*G[2][0])+G[0][2]*(G[1][0]*G[2][1]-G[1][1]*G[2][0]);
            if(!(fabsf(det)>1e-20f*G[0][0]*G[1][1]*G[2][2]))continue;
            for(int c=0;c<3;++c){float M[3][3];for(int a=0;a<3;++a)for(int e=0;e<3;++e)M[a][e]=e==c?r[a]:G[a][e];
                mu[c]=(M[0][0]*(M[1][1]*M[2][2]-M[1][2]*M[2][1])-M[0][1]*(M[1][0]*M[2][2]-M[1][2]*M[2][0])+M[0][2]*(M[1][0]*M[2][1]-M[1][1]*M[2][0]))/det;}
        }
        float q[3]={y[0],y[1],y[2]};
        for(int a=0;a<n;++a)for(int e=0;e<3;++e)q[e]-=mu[a]*A[idx[a]][e];
        if(!halfSpaces(A,B,q))continue;
        const float d=(q[0]-y[0])*(q[0]-y[0])+(q[1]-y[1])*(q[1]-y[1])+(q[2]-y[2])*(q[2]-y[2]);
        if(d<bestD){bestD=d;best[0]=q[0];best[1]=q[1];best[2]=q[2];}
    }
    if(bestD<FLT_MAX){p[0]=best[0]/sc[0];p[1]=best[1]/sc[1];p[2]=best[2]/sc[2];}
}
// Projection of a bond-frame wrench onto C_b in the metric
// diag(ml,ml,ml,mt,m0,m1). The axial set (N, M_t) and the shear set (T, V) are
// independent. The shear set, and the axial set with the round bending term,
// are rotationally symmetric about their scalar axis: the projection keeps
// the vector part's direction and projects (scalar, |vector|) onto the
// meridian triangle. The section's L1 bending term is a polyhedron (above).
// Returns whether anything moved.
__device__ __forceinline__ bool project(const Bond& b,float* x,float ml,float mt,float m0,float m1)
{
    const float sl=sqrtf(ml);
    bool moved=false;
    if(b.g0>0.0f) {   // (N, M0, M1), the section's L1 bending
        const float before[3]={x[0],x[4],x[5]};
        float p[3]={x[0],fabsf(x[4]),fabsf(x[5])};const float sc[3]={sl,sqrtf(m0),sqrtf(m1)};
        polytope(p,sc,b.g0,b.g1,b.capT,b.capC);
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

__global__ void trigger(Inputs in,Settings s,Scratch w)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=in.bondCount)return;
    if(in.stage && (in.stage->error & 4096u))return;
    const PxU32 island=in.bondIslands[i];if(island>=in.chunkCount)return;
    if(!bondMember(in,i))return;
    Bond b;if(!prepareBond(in,s,i,b))return;
    float x[6];toLocal(b,in.elastic[i],x);
    if(utilisation(b,x)>=1.0f && !w.islandFlag[island])atomicOr(w.islandFlag+island,1u);
}
__global__ void listIslands(Inputs in,Scratch w)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=in.chunkCount)return;
    if(w.islandFlag[i] && in.nodeIslands[i]==i){const PxU32 k=atomicAdd(w.counters,1u);w.islands[k]=i;}
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

struct Island { PxU32 b0,nb,c0,nc; };

// u = M^-1 (p(lambda) - r_prev + B J) per chunk (J the bond-frame forces given);
// with total, r_prev is left out and the chunk's whole acceleration results.
__device__ void chunkPass(const Inputs& in,const Scratch& w,const Island& is,float lambda,const float* J,bool total)
{
    for(PxU32 k=threadIdx.x;k<is.nc;k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];
        float r[6];for(int q=0;q<6;++q)r[q]=(1.0f-lambda)*c.pb[q]+lambda*c.pf[q]-(total?0.0f:c.r[q]);
        for(PxU32 slot=c.begin;slot<c.end;++slot) {
            const PxU32 bond=in.nodeRefs[slot];
            if(!bondMember(in,bond))continue;
            const PxU32 l=w.bondLocal[bond];const Bond& b=w.bonds[l];if(!(b.flags&eALIVE))continue;
            addWrench(b,J+6*l,b.c0==c.chunk,r);
        }
        float* u=w.u+6*c.chunk;
        for(int q=0;q<3;++q){u[q]=r[q]*c.im;u[3+q]=r[3+q]*c.ii;}
    }
}

// The majoriser of the dual's Hessian B^T M^-1 B + (K dt^2)^-1 per joint:
// Gershgorin over each dynamic endpoint's live joints, bounded by its diagonal
// (|o x f - m|^2 <= 2|o|^2|f|^2 + 2|m|^2).
__device__ void precondition(const Inputs& in,const Settings& s,const Scratch& w,const Island& is)
{
    for(PxU32 k=threadIdx.x;k<is.nc;k+=kThreads) {
        const Chunk& c=w.chunks[is.c0+k];PxU32 degree=0;
        for(PxU32 slot=c.begin;slot<c.end;++slot) {
            const PxU32 bond=in.nodeRefs[slot];if(!bondMember(in,bond))continue;
            degree+=(w.bonds[w.bondLocal[bond]].flags&eALIVE)?1u:0u;
        }
        w.degree[c.chunk]=degree;
    }
    __syncthreads();
    const float inverseDt2=1.0f/(s.dt*s.dt);
    for(PxU32 k=threadIdx.x;k<is.nb;k+=kThreads) {
        Bond& b=w.bonds[is.b0+k];
        float dl=inverseDt2/b.kl,dt=inverseDt2/b.kt,d0=inverseDt2/b.k0,d1=inverseDt2/b.k1,da=0.0f;
        for(int e=0;e<2;++e) {
            if(!(b.flags&(e?eDYNAMIC1:eDYNAMIC0)))continue;
            const auto c=in.chunks[e?b.c1:b.c0];const float d=float(w.degree[e?b.c1:b.c0]);
            const float* o=e?b.o1:b.o0;const float ii=c.inertia>0.0f?1.0f/c.inertia:0.0f;
            dl+=d*(1.0f/c.mass+2.0f*dot3(o,o)*ii);da+=d*2.0f*ii;
        }
        b.dl=dl;b.dt=dt+da;b.d0=d0+da;b.d1=d1+da;
    }
    __syncthreads();
}

// One solve at load level lambda, from the current J: FISTA on the dual,
// minimise 1/2 |p - r_prev + B J|^2_M^-1 + 1/2 sum |J - T|^2_(K dt^2)^-1 over C.
// Converged when no joint's force moves by more than `tolerance` of its
// capacity in an iteration. Returns iterations.
__device__ PxU32 solve(Shared& sh,const Inputs& in,const Settings& s,const Scratch& w,const Island& is,float lambda,bool& capped,float& last)
{
    const float inverseDt2=1.0f/(s.dt*s.dt);
    precondition(in,s,w,is);
    float t=1.0f;
    for(PxU32 k=threadIdx.x;k<is.nb;k+=kThreads)for(int q=0;q<6;++q)w.Y[6*(is.b0+k)+q]=w.J[6*(is.b0+k)+q];
    __syncthreads();
    PxU32 it=0;capped=true;last=0.0f;
    for(;it<s.iterations;++it) {
        chunkPass(in,w,is,lambda,w.Y,false);
        __syncthreads();
        float change=0.0f,restart=0.0f;
        for(PxU32 k=threadIdx.x;k<is.nb;k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];
            float* jn=w.Jn+6*l;const float* y=w.Y+6*l;const float* j=w.J+6*l;const float* T=w.T+6*l;
            if(!(b.flags&eALIVE)){for(int q=0;q<6;++q)jn[q]=0.0f;continue;}
            float g[6];relative(b,w.u,g);
            float x[6];
            for(int q=0;q<3;++q) {
                x[q]=y[q]-(g[q]+(y[q]-T[q])*inverseDt2/b.kl)/b.dl;
            }
            {const float ka[3]={b.kt,b.k0,b.k1},dd[3]={b.dt,b.d0,b.d1};
                for(int q=0;q<3;++q)x[3+q]=y[3+q]-(g[3+q]+(y[3+q]-T[3+q])*inverseDt2/ka[q])/dd[q];}
            project(b,x,b.dl,b.dt,b.d0,b.d1);
            // The projected gradient D (Y - Jn): a relative acceleration.
            const float dq[6]={b.dl,b.dl,b.dl,b.dt,b.d0,b.d1};
            float gl=0.0f,ga=0.0f;
            for(int q=0;q<3;++q){const float a=dq[q]*(y[q]-x[q]),r=dq[3+q]*(y[3+q]-x[3+q]);gl+=a*a;ga+=r*r;}
            change=fmaxf(change,0.5f*s.dt*s.dt*fmaxf(sqrtf(gl),sqrtf(ga)*s.lengthScale));
            for(int q=0;q<6;++q){jn[q]=x[q];restart+=dq[q]*(y[q]-x[q])*(x[q]-j[q]);}
        }
        change=blockMax(sh,change);
        restart=blockSum(sh,restart);
        const bool done=!(change>s.tolerance);last=change;
        float beta=0.0f;
        // Gradient restart (O'Donoghue & Candes): momentum against descent.
        if(restart>0.0f)t=1.0f;
        else{const float tn=0.5f*(1.0f+sqrtf(1.0f+4.0f*t*t));beta=(t-1.0f)/tn;t=tn;}
        for(PxU32 k=threadIdx.x;k<is.nb;k+=kThreads) {
            const PxU32 l=is.b0+k;float* j=w.J+6*l;float* y=w.Y+6*l;const float* jn=w.Jn+6*l;
            for(int q=0;q<6;++q){const float v=jn[q];y[q]=done?v:v+beta*(v-j[q]);j[q]=v;}
        }
        __syncthreads();
        if(done){capped=false;++it;break;}
    }
    return it;
}

__device__ void finishFailed(const Scratch& w,PxU32 bit){atomicOr(&w.status->error,bit);}

__global__ __launch_bounds__(kThreads) void solveIslands(Inputs in,Settings s,Scratch w)
{
    __shared__ Shared sh;
    const PxU32 islands=w.counters[0];
    for(PxU32 k=blockIdx.x;k<islands;k+=gridDim.x) {
        const PxU32 island=w.islands[k];
        Island is{};
        // Members, in index order (deterministic): count, allocate, compact.
        PxU32 nb=0,nc=0;
        for(PxU32 i=threadIdx.x;i<in.bondCount;i+=kThreads) {
            if(in.bondIslands[i]!=island)continue;
            if(bondMember(in,i))++nb;
            // A joint of a chunk crushed before the solve goes with it.
            else if(in.health[i]>0.0f){w.forces[i]=PxDestructionVectorPair();w.verdict[i]=eBROKEN;}
        }
        for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads)nc+=(in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i))?1u:0u;
        nb=blockCount(sh,nb);nc=blockCount(sh,nc);
        if(!threadIdx.x){sh.base=atomicAdd(w.counters+1,nb);sh.count=atomicAdd(w.counters+2,nc);}
        __syncthreads();
        is.b0=sh.base;is.nb=nb;is.c0=sh.count;is.nc=nc;
        __syncthreads();
        if(is.b0+nb>in.bondCount || is.c0+nc>in.chunkCount){if(!threadIdx.x)finishFailed(w,1u);continue;}
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
                const auto c=in.chunks[i];Chunk ch{};ch.chunk=i;ch.begin=in.nodeBegin[i];ch.end=in.nodeBegin[i+1];
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
        __syncthreads();
        // The ramp's start: the previous forces, projected; they balance
        // p_base = -B J_base exactly, at rest (r_prev = 0).
        for(PxU32 k=threadIdx.x;k<nb;k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];
            float j[6];toLocal(b,in.base[b.bond],j);returnMap(b,j);
            for(int q=0;q<6;++q)w.J[6*l+q]=j[q];
        }
        __syncthreads();
        for(PxU32 k=threadIdx.x;k<nc;k+=kThreads) {
            Chunk& c=w.chunks[is.c0+k];
            float r[6]={0,0,0,0,0,0};
            for(PxU32 slot=c.begin;slot<c.end;++slot) {
                const PxU32 bond=in.nodeRefs[slot];
                if(!bondMember(in,bond))continue;
                const PxU32 l=w.bondLocal[bond];const Bond& b=w.bonds[l];
                addWrench(b,w.J+6*l,b.c0==c.chunk,r);
            }
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
        PxU32 rounds=0,level=0,broken=0;bool plastic=false,failed=false;
        float previous=0.0f;
        for(;;) {
            const float lambda=fminf(1.0f,first*powf(s.rampFactor,float(level)));
            const bool final=lambda>=1.0f;
            // The trial: the last forces plus this level's increment of the
            // elastic solution, returned onto capacity.
            PxU32 clipped=0;
            for(PxU32 k=threadIdx.x;k<nb;k+=kThreads) {
                const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];
                if(!(b.flags&eALIVE))continue;
                float* T=w.T+6*l;float* J=w.J+6*l;
                float inc[6]={0,0,0,0,0,0};
                if(lambda!=previous && (!plastic || s.elasticIncrementAfterYield)){float a[6],o[6];toLocal(b,in.elastic[b.bond],a);toLocal(b,(in.elasticBase?in.elasticBase:in.base)[b.bond],o);
                    for(int q=0;q<6;++q)inc[q]=(lambda-previous)*(a[q]-o[q]);}
                for(int q=0;q<6;++q){T[q]=J[q]+inc[q];J[q]=T[q];}
                clipped+=returnMap(b,J)?1u:0u;
            }
            clipped=blockCount(sh,clipped);
            previous=lambda;
            if(clipped)plastic=true;
            if(plastic) {
                bool capped;float last;const PxU32 it=solve(sh,in,s,w,is,lambda,capped,last);
                ++rounds;
                if(!threadIdx.x){const PxU32 slot=atomicAdd(&w.status->solves,1u);atomicAdd(&w.status->iterations,it);
                    if(capped)atomicAdd(&w.status->capped,1u);
                    if(w.log && slot<kLogCapacity)w.log[slot]={island,level,it,broken,clipped,capped?1u:0u,lambda,last};}
            }
            // The chunks' acceleration so far; it carries into the next solve.
            chunkPass(in,w,is,lambda,w.J,true);
            __syncthreads();
            for(PxU32 k=threadIdx.x;k<nc;k+=kThreads) {
                Chunk& c=w.chunks[is.c0+k];const float* u=w.u+6*c.chunk;
                if(plastic)for(int q=0;q<3;++q){c.r[q]=u[q]/c.im;c.r[3+q]=c.ii>0.0f?u[3+q]/c.ii:0.0f;}
            }
            __syncthreads();
            // Which joints reached capacity, and which of them fail.
            PxU32 newly=0;
            for(PxU32 k=threadIdx.x;k<nb;k+=kThreads) {
                const PxU32 l=is.b0+k;Bond& b=w.bonds[l];float* j=w.J+6*l;
                if(!(b.flags&eALIVE))continue;
                if(!(utilisation(b,j)>=1.0f-s.capacityBand))continue;
                bool fails=!(b.flags&eDUCTILE);
                if(!fails && final) {
                    // Slip at the centroid over the tick: 1/2 |v_rel| dt = 1/2 |a_rel| dt^2.
                    float e[6];relative(b,w.u,e);
                    fails=0.5f*sqrtf(e[0]*e[0]+e[1]*e[1]+e[2]*e[2])*s.dt*s.dt>b.slip;
                }
                if(fails){b.flags&=~eALIVE;for(int q=0;q<6;++q)j[q]=0.0f;++newly;
                    if(w.breaks){float e[6];relative(b,w.u,e);w.breaks[2*b.bond]=float(rounds)+0.01f*float(level);
                        w.breaks[2*b.bond+1]=0.5f*sqrtf(e[0]*e[0]+e[1]*e[1]+e[2]*e[2])*s.dt*s.dt;}}
            }
            newly=blockCount(sh,newly);
            broken+=newly;
            if(newly)plastic=true;
            if(!newly){if(final)break;++level;}
            if(rounds>=s.maxRounds){failed=true;break;}
        }
        if(failed && !threadIdx.x)finishFailed(w,4u);
        // Publish: forces in the solver's convention, verdicts, accelerations.
        chunkPass(in,w,is,1.0f,w.J,true);
        PxU32 yielded=0;bool finite=true;
        for(PxU32 k=threadIdx.x;k<nb;k+=kThreads) {
            const PxU32 l=is.b0+k;const Bond& b=w.bonds[l];const float* j=w.J+6*l;
            float lin[3],ang[3];toSolver(b,j,lin,ang);
            PxDestructionVectorPair f;f.linear=PxVec3(lin[0],lin[1],lin[2]);f.angular=PxVec3(ang[0],ang[1],ang[2]);
            finite=finite && f.linear.isFinite() && f.angular.isFinite();
            w.forces[b.bond]=f;
            PxU32 v=eHELD;
            if(!(b.flags&eALIVE))v=eBROKEN;
            else if(utilisation(b,j)>=1.0f-s.capacityBand){v=eYIELDED;++yielded;}
            w.verdict[b.bond]=v;
        }
        yielded=blockCount(sh,yielded);
        const PxU32 bad=blockCount(sh,finite?0u:1u);
        if(!threadIdx.x) {
            atomicAdd(&w.status->triggered,1u);atomicAdd(&w.status->broken,broken);atomicAdd(&w.status->yielded,yielded);
            atomicMax(&w.status->rounds,rounds);if(bad)atomicOr(&w.status->error,2u);
        }
        __syncthreads();
    }
}

// The forces each bond carries after an evaluation: E's where it solved, the
// elastic solve's elsewhere (the next tick's ramp starts here).
__global__ void recordState(const PxU32* islandFlag,const PxU32* bondIslands,const PxDestructionVectorPair* impact,
    const PxDestructionVectorPair* elastic,PxDestructionVectorPair* state,PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 island=bondIslands[i];
    state[i]=(island!=0xffffffffu && islandFlag[island])?impact[i]:elastic[i];
}

// Host side: persistent scratch and the launches of one evaluation.
struct Stage {
    Scratch w{};PxU32 n=0,m=0;
    void release() {
        cudaFree(w.islandFlag);cudaFree(w.islands);cudaFree(w.counters);cudaFree(w.bondLocal);cudaFree(w.degree);
        cudaFree(w.bonds);cudaFree(w.chunks);cudaFree(w.J);cudaFree(w.Y);cudaFree(w.Jn);cudaFree(w.T);cudaFree(w.u);
        cudaFree(w.forces);cudaFree(w.verdict);cudaFree(w.status);w={};n=m=0;
    }
    void allocate(PxU32 chunks,PxU32 bonds) {
        release();n=chunks;m=bonds;
        ::physx::allocate(w.islandFlag,n);::physx::allocate(w.islands,n);::physx::allocate(w.counters,4);
        ::physx::allocate(w.bondLocal,m);::physx::allocate(w.degree,n);
        ::physx::allocate(w.bonds,m);::physx::allocate(w.chunks,n);
        for(float** a:{&w.J,&w.Y,&w.Jn,&w.T})::physx::allocate(*a,6*size_t(m));
        ::physx::allocate(w.u,6*size_t(n));::physx::allocate(w.forces,m);::physx::allocate(w.verdict,m);::physx::allocate(w.status,1);
        check(cudaMemset(w.islandFlag,0,sizeof(PxU32)*n));check(cudaMemset(w.u,0,sizeof(float)*6*size_t(n)));
        check(cudaMemset(w.status,0,sizeof(Status)));check(cudaMemset(w.verdict,0,sizeof(PxU32)*m));
    }
    // One evaluation: trigger, list, solve. Leaves islandFlag set for the
    // material kernels, which take E's forces and verdicts on flagged islands.
    void submit(const Inputs& in,const Settings& s,cudaStream_t stream,PxU32 grid=32) {
        check(cudaMemsetAsync(w.islandFlag,0,sizeof(PxU32)*n,stream));
        check(cudaMemsetAsync(w.counters,0,sizeof(PxU32)*4,stream));
        check(cudaMemsetAsync(w.status,0,sizeof(Status),stream));
        if(m)trigger<<<(m+127)/128,128,0,stream>>>(in,s,w);
        if(n)listIslands<<<(n+127)/128,128,0,stream>>>(in,w);
        if(m)solveIslands<<<grid,kThreads,0,stream>>>(in,s,w);
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
