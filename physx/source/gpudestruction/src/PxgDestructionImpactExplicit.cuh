// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#ifndef EX_THREADS
#define EX_THREADS 512
#endif
// Timing diagnostics only (never in a product build): a bit mask of the
// window's phases to skip -- 1 the joint gather, 2 the contact rows, 4 the row
// gather, 8 the joints, 16 the two-body implicit sweeps (32 their node gathers, 64 their joint passes).
#ifndef EX_GATHER
#define EX_GATHER 4
#endif
#ifndef EX_PROF_SKIP
#define EX_PROF_SKIP 0
#endif
// Timing diagnostics only: phases computed a second time into a dummy (2 the
// contact rows, 8 the joints), the physics unchanged; the time added is the
// phase's own.
#ifndef EX_PROF_DUP
#define EX_PROF_DUP 0
#endif
// The explicit impact step (Settings::method 2; vibe-land
// docs/destruction/IMPACT_STEP_PLAN.md, harness scripts/impact/explicit-step.py):
// the struck patch's bond graph integrated over the tick by symplectic Euler,
// one block per patch, every patch of the evaluation in one launch. No linear
// solve, no events, no ordering: a joint breaks in the substep its force
// reaches its capacity, so the failure order is the stress wave's.
//
// Rigid chunks (6 dof; anchors and chunks off the patch are held), joints in
// the stress solver's six link components with stiffness k (N/m, N m/rad), the
// impactor a node with its momentum, its contacts unilateral at velocity level
// (Moreau: an inelastic impulse per substep, Coulomb cone). Each substep h:
//
//   v += h M^-1 (B J + f0)            f0 = -B J0: the rest forces balance the dead load
//   v += M^-1 B_c P,  P in the Coulomb cone (exCone)  every contact row at once (Jacobi, mass split)
//   J  = J - h k (B^T v)              the trial
//   brittle joint, util >= 1 - band:  breaks (J = 0; its rest force J0 is released)
//   ductile joint, util > 1:          J /= util (radial return), slip += |dJ_pl| / k,
//                                      breaks past its ultimate slip
//
// No artificial damping: plasticity, fracture and the inelastic contact
// dissipate. h is 0.9 x 2 / omega, omega the per-node Gershgorin bound on the
// patch's largest frequency (symplectic Euler is stable for omega h < 2; the
// bound is never below the true one). The window is the tick. FP32.
// Included inside namespace impact, after PxgDestructionImpactStep.cuh.

constexpr PxU32 kExPatches=8;      // patches (struck islands) per evaluation
constexpr PxU32 kExNodes=1280;     // chunks and impactors per patch (a whole bungalow, 1,096 chunks: the dynamic sequence)
constexpr PxU32 kExLinks=4096;     // joints per patch
constexpr PxU32 kExRows=256;       // contact rows per patch (a meteor's debris: 216 seen)
constexpr PxU32 kExHandoffs=kExPatches*32;   // the window's hand-off records (impactors and cars) per evaluation
constexpr PxU32 kExThreads=EX_THREADS;  // the window's threads per patch (one block)
static_assert(kExRows<=kExThreads,"a row a thread (exRunT)");
// A patch of at most kExSmall nodes runs exRunSmall: its nodes' inverse masses
// and joint and row ranges in threadgroup memory beside their velocities. 672
// nodes x 48 bytes is 32,256 of Metal's 32 KB (patches of 561-581 nodes measured
// 7% faster than through exRun).
#ifndef EX_SMALL
#define EX_SMALL 672
#endif
constexpr PxU32 kExSmall=EX_SMALL;
// Power-iteration products of the substep's bound (exFinish): each one's bound
// is rigorous, so this sets only how tight it is (and the build's cost).
#ifndef EX_BOUND_PRODUCTS
#define EX_BOUND_PRODUCTS 8
#endif
constexpr PxU32 kExBoundProducts=EX_BOUND_PRODUCTS;
static_assert(8*kExLinks+6*kExNodes+2*kExLinks<=12*kExLinks,"the bound's blocks, y and ends fit t.wr");

struct ExPatch {
    PxU32 island,nodes,chunks,links,rows,impactors,substeps,done,broken,yielded,truncated,failed,seed,listed,bodies,pushing,near;
    float radius,h,t,omega;
    // Energy books (J): the impactors' kinetic energy at the window's start and
    // end (relative to the struck cluster), the elastic energy the joints held
    // when they broke (brittle release), and the plastic work of the ductile ones.
    float keIn,keOut,fracture,plastic;
    float u0;   // the elastic energy its joints held at the window's start (sum 1/2 J0^2/k)
    float dead; // the dead load's work over the window (sum h f0 . v: a sagging patch's)
    // The two-body impact (Settings::explicitTwoBody): the car's island (or ~0),
    // the row its pose came from, its chunk nodes [chunks - carChunks, chunks),
    // its cluster's rotation into the struck frame (x y z w), the joints made
    // implicit, and the compliant rows.
    PxU32 car=0xffffffffu,carRow=0xffffffffu,carChunks=0,implicitJoints=0,compliant=0,twoBody=0;
    float carQ[4]={0.0f,0.0f,0.0f,1.0f};
    // The dynamic sequence (Settings::dynamicSequence; "The dynamic sequence"
    // below): 1 an island in dynamic mode; its events this window (breaks,
    // fastenings failed to contact, seats lost, contacts crushed), its contacts,
    // the largest joint damping ratio (the substep's bound), and its books (J):
    // kinetic energy at the window's start and end, elastic energy at its end, the
    // loads' work, the contacts' slip work and the dashpots' work; the time of its
    // last event in the window (s; -1 none).
    PxU32 sequence=0,events=0,converted=0,seatLost=0,crushedContacts=0,contacts=0;
    float zeta=0.0f,keStart=0.0f,keEnd=0.0f,strainEnd=0.0f,extWork=0.0f,slipWork=0.0f,dashWork=0.0f,lastEvent=-1.0f;
    // The freeze (exSequencePeriod): the time of the window's last activity (an event, a
    // contact slipping, opening or closing; -1 none), its slowest motion's period at the
    // window's end (2 pi / omega_R, omega_R^2 = v^T K v / v^T M v), and 1 when it freezes.
    float lastActive=-1.0f,period=0.0f,quiet=0.0f;PxU32 freeze=0;
    float beta=0.0f;   // the damping's 2 / omega_K (s; times each joint's zeta): its last sample, kept across launches
    PxU32 anchored=0,fellFree=0;   // a joint to a support (or a held node); open contacts broken at the window's end (exSequenceSplit)
    PxU32 bearingJoints=0,looseNodes=0;   // (diagnostics) its bearing joints; its chunk nodes with no live joint
    // Settings::compliant: the crush work its rows did (J, the striker's) and the
    // chunks they crushed through.
    float crushWork=0.0f;PxU32 crushedThrough=0u;
    // The window's own geometry (exRefresh): rows re-found every refreshEvery substeps
    // (one face radius of the fastest impactor's travel: refreshTime), the swept rows added.
    PxU32 refreshEvery=0u,swept=0u;float refreshTime=0.0f;
    // The ghost check (exPublish, the window's own geometry): rows whose impactor's centre
    // ends inside its chunk's box while the chunk is neither crushed through nor freed (a
    // joint of it still live): the impactor passed an intact chunk. Must be 0.
    PxU32 passedIntact=0u;
    // The window covers its round impactors' reach (exBuild): 0 when a chunk of a struck
    // cluster that an impactor's sphere can reach over the tick is not a node of the patch
    // (another island, past the patch's radius, past its rows): the corrected pass then keeps
    // its pairs (bounded at what the window delivered) and the rigid simulation's momentum.
    PxU32 uncovered=0u;
    // A dynamic struck island (Settings::dynamicStruck; its rows' clusterIm > 0): the
    // whole island, free (the window's frame its cluster's, moving with it); its seed row.
    PxU32 dynamic=0,dynamicRow=0xffffffffu;
};
// A joint of the patch: local node ends (0xffffffff: held), state bits.
// eEX_ROWS: an end of the joint has contact rows (exRunT sets it; the window's
// other joints run beside the rows).
// eEX_CAR: a joint of the two-body car; eEX_IMPLICIT: integrated implicitly (exFinish).
// eEX_CONTACT: a bearing joint whose fastenings failed, a unilateral contact (the
// dynamic sequence); eEX_BEARING: a bearing joint (its fastenings may fail to contact).
// eEX_OPEN: a contact open (lifted) at the last substep (its transitions are activity).
// eEX_FRICTION: a Mohr-Coulomb joint (Bond::mu > 0): its mu and cap are packed in
// its record's last float4, read only for such joints (512: 32-256 are the
// two-body and dynamic-sequence branches' bits).
enum ExState : PxU32 { eEX_LIVE=1, eEX_DUCTILE=2, eEX_YIELDED=4, eEX_BROKEN=8, eEX_ROWS=16, eEX_CAR=32, eEX_IMPLICIT=64, eEX_CONTACT=128, eEX_BEARING=256, eEX_FRICTION=512, eEX_OPEN=1024 };
struct ExLink { PxU32 a,b,state,pad; float J0[6],J[6]; float slip,limit,brokeAt,pad2; };
// A contact row: the struck chunk (a, local), the impactor (b), the stage's row.
// A compliant row (compliant 1): its depth d (m), the materials' E* (Pa), the
// patch's radius sigma, the Hertz radius R and the face's radius (m): k(d) =
// 2 E* min(face, max(sigma, sqrt(R d))).
// gap: the separation the row still has to close before it pushes (m; the
// pair's contact points' least separation, when positive), closed at its
// closing rate over the window (a rigid row: it may close by gap / h in a
// substep; a compliant one pushes only once it is closed).
// Settings::compliant, the struck side's crush in the row (crushLaw; vibe-land
// scripts/impact/contact_law.py crush_of / compliant_impulse(crush=)): its onset and
// plateau pressures (Pa), the crushed depth dp and the chunk's depth along the row
// (m), the force applied this substep (N) and the contact radius it acted on (m);
// crush bits: 1 crushing, 2 crushed through (the plug pending), 4 done (the row is
// spent: its chunk is a free fragment).
struct ExRow { PxU32 a,b,row,pad; float P[3],total[3],Winv[9],W[9]; PxU32 compliant; float d,Estar,sigma,R,face,gap;
    float on=0.0f,pl=0.0f,dp=0.0f,depth=0.0f,Fa=0.0f,ac=0.0f; PxU32 crush=0u;
    // The window's own geometry (exRefresh; Settings::compliant with chunk boxes): 1 its
    // frame and arms are re-found as the bodies move; 2 a swept row, met only within the
    // window (no stage row of its own: row is its impactor's first, never published to).
    PxU32 geo=0u; };
// A node: inverse mass and inverse inertia (chunks: scalar ii in Iinv[0..2]),
// velocity, the rest forces' load; tensor 1 for an impactor. pad[0]: its
// material's modulus (float bits; compliant rows), pad[1]: 1 a two-body car's chunk.
// crushed: 1 once a row of the window crushed the chunk through (its joints break;
// Settings::compliant).
// x0: its position at the window's start (struck frame); dx, dth: its displacement and
// rotation (vector) since, for the window's own geometry (exRefresh); radius: a round
// impactor's (0: the stage's rows only).
struct ExNode { PxU32 chunk,tensor,jointBegin,jointEnd,rowBegin,rowEnd,pad[2]; float im,Iinv[6],v[6],f0[6],v0[6]; PxU32 crushed=0u;
    float x0[3]={0,0,0},dx[3]={0,0,0},dth[3]={0,0,0},radius=0.0f; };

// A joint packed for the window: kExJoint float4s, 16-byte aligned, so a
// substep reads it in vector loads (a simdgroup's scalar loads of a 164-byte
// Bond cost about three times as much: tests/tools/ex_floor_bench.cu). 0..8 the
// constants -- frame n, t1, t2, arms o0, o1, stiffnesses kl, kt, k0, k1,
// capacities and gains, J0, the local ends -- 9..10 the state: J, state bits,
// slip, 11 a Mohr-Coulomb joint's mu and shear cap (read only with
// eEX_FRICTION). exRunT packs them at each launch's start from bonds and links
// and writes the state back to links at its end.
constexpr PxU32 kExJoint=12;
// A contact row packed for the window: frame, arms, friction, W, W^-1 (kExRow float4s).
constexpr PxU32 kExRow=9;
struct ExScratch {
    PxU32* nodeOf{};      // [chunkCount] patch << 16 | local, or ~0
    PxU32* linkOf{};      // [bondCount] local joint index, or ~0 (each bond is in one patch at most)
    PxU32* patchCount{};  // [1]
    ExPatch* patches{};   // [kExPatches]
    ExNode* nodes{};      // [P][kExNodes]
    Bond* bonds{};        // [P][kExLinks]
    ExLink* links{};      // [P][kExLinks]
    Bond* rowBonds{};     // [P][kExRows]
    ExRow* rows{};        // [P][kExRows]
    PxU32* adj{};         // [P][2 kExLinks]: per node its joints, link << 1 | end (1: its chunk1)
    PxU32* rowAdj{};      // [P][2 kExRows]: per node its rows, row << 1 | end (1: the impactor)
    float* wr{};          // [P][kExLinks][2][6]: each joint's B (J - J0) on its two ends (adj indexes it)
    PxU32* rowList{};     // [P][kExRows]: each patch's stage rows (exList), in row order
    float* rwr{};         // [P][kExRows][2][6]: each row's impulse wrench on its two ends
    float4* jp{};         // [P][kExLinks][kExJoint]: each joint packed for the window (exRunT; exPack)
    float4* rp{};         // [P][kExRows][kExRow]: each contact row packed for the window (exRunT)
    PxU32* jl{};          // [P][kExLinks]: the live joints away from rows from the front, those at rows from the back (exRunT)
    // The two-body impact only (null otherwise): each implicit joint's relative
    // motion at the substep's start, its A = (I + h^2/2 K W~)^-1 h K
    // (9 float4s, row-major 6 x 6), and its increment's wrench on its two ends.
    float4* eStart{};     // [P][kExLinks][2]: each implicit joint's B^T v at the substep's start (its six rates, then two pad)
    // The window's hand-off to the corrected pass (exPublish; null: none): per
    // patch and impactor, its body and its end velocity; per stage row, 1 where
    // the window decided it (IMPACT_STEP_PLAN.md section 1, rule 3).
    // v, w at the window's end and v0, w0 at its start, in the struck cluster's frame,
    // relative to its rigid motion at the tick's start: the corrected pass applies the
    // change, v - v0 (rotated to the world), to the body's start (records of one body
    // from several windows sum their changes).
    struct Handoff { PxU32 island,body,patch,pad; float v[3],w[3],v0[3],w0[3]; };
    Handoff* handoff{};   // [kExPatches * kExHandoffs]: island ~0 a rigid impactor, else the two-body car's or the dynamic struck island
    PxU32* handoffCount{};// [1]
    PxU32* rowDecided{};  // [kContactCapacity]
    float4* ja{};         // [P][kExLinks][9]
    float* wd{};          // [P][kExLinks][12]
    // The dynamic sequence (Settings::dynamicSequence; null otherwise). Per island
    // id: 1 a dynamic island (seqIsland); seqCreate 1: exList adds a patch for
    // each such island without rows (the second submission), 0: it only marks the
    // row patches of those islands dynamic. Per chunk: 1 a seed (seqSeed: a chunk
    // of a joint whose verdict changed, or of the island's persisted state).
    const PxU32* seqIsland{};
    PxU32 seqCreate=0;PxU32 seqAtRest=0;   // (seqAtRest: Settings::sequenceDiag 4)
    const PxU32* seqSeed{};
    // The persisted state, start (committed at the tick's start) and next (this
    // pass's): per chunk bit 0 dynamic, its velocity (its cluster's frame); per bond
    // bit 0 its force persisted, bit 1 a contact, its force (bond frame) and its
    // contact slip along t1, t2 (m).
    const PxU32* pChunk{};PxU32* pChunkn{};
    const float* pV{};float* pVn{};
    const PxU32* pBond{};PxU32* pBondn{};
    const float* pJ{};float* pJn{};
    const float* pSlip{};float* pSlipn{};
    // Per chunk: the time its island has run without activity (s) and the longest period of
    // its slowest motion since (s), for the freeze. A frozen island (pChunk bit 1) is held at
    // its frozen forces plus the static solve's elastic increment since the freeze (per bond:
    // pBond bit 2; frozenForce and freezeElastic, solver frame), until an event thaws it.
    const float* pQuiet{};float* pQuietn{};
    const float* pPeriod{};float* pPeriodn{};
    PxDestructionVectorPair* frozenForce{};PxDestructionVectorPair* freezeElastic{};
    PxU32* seqCycles{};   // [chunkCount] freezes per chunk (its island's freeze/thaw cycles)
    // Per bond: the forces the structure carried before this tick's change -- the last
    // frame's trial (static) solve: a dynamic patch's start where nothing is persisted (null:
    // Inputs::base).
    const PxDestructionVectorPair* seqBase{};
    PxU32* seqCounters{}; // [4] this tick: islands frozen, thawed, held frozen; islands left to the static verdict (patch slots full)
    // The window's answer for the stage (exPublishDynamic): per bond its re-bearing
    // state (eBEAR_*; ~0 undecided) and 1 where it is a contact the window holds.
    PxU32* seqBear{};PxU32* seqHold{};
    // Per patch: each joint's damping (8: its split inverse mass per component, its zeta;
    // before exFinishDynamic its zeta in [6]), its contact slip in the window (2), each node's load
    // residual p + B J0 (6; before exFinishDynamic its load p).
    float* damp{};        // [P][kExLinks][8]: each joint's split inverse mass per component (6), its zeta, 0
    float* wk{};          // [P][kExLinks][12]: each joint's K d wrench on its two ends (the damping's frequency)
    float* cslip{};       // [P][kExLinks][2]
    float* dynLoad{};     // [P][kExNodes][6]
    float4* dynPos{};     // [P][kExNodes]: each chunk node's position (its cluster's frame)
    PxU32* dynMark{};     // [P][kExNodes]: exSequenceSplit's: 1 a node with a load path to a support
    const PxDestructionChunkBox* boxes{};   // Inputs::chunkBoxes for the window's own geometry (exRefreshRow), or null
};

// A joint's wrench on one end's six dof from a bond-frame force x (end 0: its
// chunk0 -- addWrench with first; end 1: its chunk1).
__device__ __forceinline__ void exWrench(const Bond& b,const float* x,PxU32 end,float* r){addWrench(b,x,end==0u,r);}
// B_end^T v_end: one end's share of the relative motion its joint feels (bond frame).
__device__ __forceinline__ void exRelative(const Bond& b,PxU32 end,const float* v,float* e)
{
    const float* o=end?b.o1:b.o0;const float s=end?-1.0f:1.0f;
    float m[3];cross3(v+3,o,m);
    const float lin[3]={s*(v[0]+m[0]),s*(v[1]+m[1]),s*(v[2]+m[2])},ang[3]={-s*v[3],-s*v[4],-s*v[5]};
    e[0]+=dot3(lin,b.n);e[1]+=dot3(lin,b.t1);e[2]+=dot3(lin,b.t2);
    e[3]+=dot3(ang,b.n);e[4]+=dot3(ang,b.t1);e[5]+=dot3(ang,b.t2);
}
__device__ __forceinline__ void exStiffness(const Bond& b,float* k)
{
    const float kk[6]={b.kl,b.kl,b.kl,b.kt,b.k0,b.k1};
    for(int q=0;q<6;++q)k[q]=(kk[q]>0.0f && kk[q]<1e30f)?kk[q]:0.0f;
}
// One end's rows of its joint's stiffness block against both ends, C_e = B_end
// K B_e^T: the block on its own node is added (signed) into D, its node's
// diagonal block, summed over the node's joints before its absolute values are
// taken (a node's joints' couplings between its own dofs cancel in part); the
// block against the other end (on the patch) by its absolute values, with w
// the other end's sqrt(m^-1): rows[r] += sum_c |C_rc| (Gershgorin of M^-1 K,
// times the row's m^-1), sym[r] += sum_c |C_rc| w[c] (of S = M^-1/2 K M^-1/2,
// less the row's sqrt(m^-1)), and lump[3 g + b] (g: r's group, translation 0
// or rotation 1) the same sum over c in group b, its largest row's.
// C_ef = B_e K B_f^T in closed form: B_e = s_e [[R, 0], [O_e R, -R]] (R the
// frame's columns n, t1, t2; O_e the cross product with end e's arm; s_e +1 for
// end 0, -1 for end 1; exWrench), K = diag(kl, kl, kl, kt, k0, k1). The force
// stiffness is isotropic, R kl R^T = kl I, so C_ef = s_e s_f [[kl I, -kl O_f],
// [kl O_e, -kl O_e O_f + R Km R^T]] (O^T = -O), Km = diag(kt, k0, k1): about 100
// operations where the product of the two 6 x 6 blocks took about 1,500.
__device__ __forceinline__ void exBlock(float kl,const float* M,float ex,float ey,float ez,float fx,float fy,float fz,float sign,float* C)
{
    const float eo=ex*fx+ey*fy+ez*fz;   // O_e O_f = of oe^T - (oe . of) I
    // (-O_f written out: CuMetal e1a12f7 emits `--1.0` for -sign * x with sign
    // the constant -1, which Metal rejects.)
    const float Oe[9]={0.0f,-ez,ey,ez,0.0f,-ex,-ey,ex,0.0f},Ofn[9]={0.0f,fz,-fy,-fz,0.0f,fx,fy,-fx,0.0f};
    const float e[3]={ex,ey,ez},f[3]={fx,fy,fz};
    #pragma unroll
    for(int i=0;i<3;++i) {
        #pragma unroll
        for(int j=0;j<3;++j) {
            const float oo=f[i]*e[j]-(i==j?eo:0.0f);
            C[6*i+j]=sign*(i==j?kl:0.0f);C[6*i+3+j]=sign*kl*Ofn[3*i+j];
            C[6*(3+i)+j]=sign*kl*Oe[3*i+j];C[6*(3+i)+3+j]=sign*(M[3*i+j]-kl*oo);
        }
    }
}
__device__ void exGershgorin(const Bond& b,PxU32 end,bool both,const float* w,float* D,float* rows,float* sym,float* lump)
{
    float k[6];exStiffness(b,k);
    float M[9];for(int i=0;i<3;++i)for(int j=0;j<3;++j)M[3*i+j]=k[3]*b.n[i]*b.n[j]+k[4]*b.t1[i]*b.t1[j]+k[5]*b.t2[i]*b.t2[j];
    const float ex=end?b.o1[0]:b.o0[0],ey=end?b.o1[1]:b.o0[1],ez=end?b.o1[2]:b.o0[2],fx=end?b.o0[0]:b.o1[0],fy=end?b.o0[1]:b.o1[1],fz=end?b.o0[2]:b.o1[2];
    float C[36];exBlock(k[0],M,ex,ey,ez,ex,ey,ez,1.0f,C);
    for(int i=0;i<36;++i)D[i]+=C[i];
    if(!both)return;
    exBlock(k[0],M,ex,ey,ez,fx,fy,fz,-1.0f,C);
    for(int r=0;r<6;++r) {
        float s=0.0f,t[2]={0.0f,0.0f};
        for(int c=0;c<6;++c){const float v=fabsf(C[6*r+c]);s+=v;t[c/3]+=v*w[c];}
        rows[r]+=s;sym[r]+=t[0]+t[1];
        for(int g=0;g<2;++g)lump[3*(r/3)+g]=fmaxf(lump[3*(r/3)+g],t[g]);
    }
}
// f += the six-float records rec[6 idx[j]], j in [b0, b1), in order. The
// gathers are latency-bound (each record waits on its index): four indices
// are loaded, then their records, before the sums (the same sums, in order).
__device__ __forceinline__ void exGather(const float* rec,const PxU32* idx,PxU32 b0,PxU32 b1,float* f)
{
    PxU32 j=b0;
    for(;j+EX_GATHER<=b1;j+=EX_GATHER) {
        const float* q[EX_GATHER];for(int u=0;u<EX_GATHER;++u)q[u]=rec+6*size_t(idx[j+u]);
        float r[EX_GATHER][6];for(int u=0;u<EX_GATHER;++u)for(int c=0;c<6;++c)r[u][c]=q[u][c];
        for(int u=0;u<EX_GATHER;++u)for(int c=0;c<6;++c)f[c]+=r[u][c];
    }
    for(;j<b1;++j){const float* q=rec+6*size_t(idx[j]);for(int c=0;c<6;++c)f[c]+=q[c];}
}
__device__ __forceinline__ void exApplyInverse(const ExNode& n,const float* f,float* dv)
{
    for(int q=0;q<3;++q)dv[q]=n.im*f[q];
    if(n.tensor){float w[3];symMul(n.Iinv,f+3,w);for(int q=0;q<3;++q)dv[3+q]=w[q];}
    else for(int q=0;q<3;++q)dv[3+q]=n.Iinv[q]*f[3+q];
}

// A contact's impulse in the Coulomb cone K = {P_N <= 0, |P_T| <= mu |P_N|},
// from the impulse Ps = -W^-1 g that stops its relative motion (sticking):
// - Ps in K: it sticks.
// - Otherwise it slides (Coulomb): the normal approach is stopped, the
//   tangential impulse is mu |P_N| against the slip, t its direction: P_T =
//   -mu P_N t, and P_N from the normal row, g_N + W_NN P_N + W_NT . P_T = 0,
//   so P_N = -g_N / (W_NN - mu W_NT . t). t follows the slip after the
//   impulse (g + W P)_T, from Ps's tangential direction, to a fixed point.
// - The sliding solution must not add kinetic energy (g . P + P^T W P / 2 <=
//   0) nor pull (P_N <= 0); where it would (W coupling normal and tangential
//   strongly: a spinning fragment's off-centre contact) or does not exist, the
//   impulse is the projection of Ps onto K in the metric W, which never adds
//   energy (0 is in K) but lets the contact separate along the cone (dilation).
// Scaling the tangential part alone, the normal kept, could add energy: a
// 7.8 kg fragment spinning at 180 rad/s went to 280 rad/s.
// The same search, cheaply: P = 0 at once where Ps lies in the cone's polar in
// the metric W (d^T W Ps <= 0 for every generator d: mu |(W Ps)_T| <= (W Ps)_N,
// where the scan finds nothing below 0); the scan's directions by rotating
// Ps's tangential direction through a table (no trigonometry); the golden
// section about the scan's best direction tb by the offset u (cos(tb + u) =
// cos tb cos u - sin tb sin u), each step reusing one of the last step's two
// points (24 evaluations, not 48).
// The value of the cone's boundary direction d = (-1, mu c, mu s): its length l
// = max(0, d^T W Ps / d^T W d) and (P-Ps)^T W (P-Ps)/2 less a constant there.
// (Scalars and the device W, no lambdas: CuMetal cannot prove the pointees of
// a lambda's captured locals.)
struct ExValue { float v,l; };
__device__ __forceinline__ ExValue exValue(const float* W,float wp0,float wp1,float wp2,float mu,float c,float s)
{
    const float d1=mu*c,d2=mu*s;
    const float Wd0=-W[0]+W[1]*d1+W[2]*d2,Wd1=-W[3]+W[4]*d1+W[5]*d2,Wd2=-W[6]+W[7]*d1+W[8]*d2;
    const float dWd=-Wd0+d1*Wd1+d2*Wd2,dWP=-wp0+d1*wp1+d2*wp2;
    const float l=dWd>0.0f?fmaxf(0.0f,dWP/dWd):0.0f;
    return ExValue{0.5f*l*l*dWd-l*dWP,l};
}
// sin u and cos u for |u| <= pi/8 (the golden section's offsets): Taylor to
// u^11 and u^12, the remainder below 2e-12, far under float's resolution.
__device__ __forceinline__ void exSinCosSmall(float u,float& su,float& cu)
{
    const float x=u*u;
    su=u*(1.0f+x*(-1.0f/6.0f+x*(1.0f/120.0f+x*(-1.0f/5040.0f+x*(1.0f/362880.0f+x*(-1.0f/39916800.0f))))));
    cu=1.0f+x*(-0.5f+x*(1.0f/24.0f+x*(-1.0f/720.0f+x*(1.0f/40320.0f+x*(-1.0f/3628800.0f+x*(1.0f/479001600.0f))))));
}
// The projection's search: P = 0 at once where Ps lies in the cone's polar in
// the metric W (d^T W Ps <= 0 for every generator d: mu |(W Ps)_T| <= (W
// Ps)_N); else a 16-direction scan (Ps's tangential direction rotated through
// a table), then the best direction refined by safeguarded Newton on the
// offset u from it. On the boundary P = l d, l = N / D with N = d^T W Ps and D
// = d^T W d, the value is -N^2 / (2 D): the best direction maximises R = N^2
// / D where N > 0, a root of F = 2 N' D - N D' (R' = N F / D^2), F' = 2 N'' D +
// N' D' - N D'' (d' = (0, -mu s, mu c), d'' = (0, -mu c, -mu s)). The root is
// bracketed in the scan's interval about the best (as the golden section it
// replaces assumed), Newton steps that leave the bracket or meet F' >= 0
// bisect it, and it stops when the step is below float's resolution of u:
// the same minimiser, to float precision (the golden section's 24 steps left
// it within 1e-5 rad), in about 4 evaluations instead of 26.
__device__ __forceinline__ void exConeMetric(const float* W,const float* Ps,float mu,float* P)
{
    const float wp0=W[0]*Ps[0]+W[1]*Ps[1]+W[2]*Ps[2],wp1=W[3]*Ps[0]+W[4]*Ps[1]+W[5]*Ps[2],wp2=W[6]*Ps[0]+W[7]*Ps[1]+W[8]*Ps[2];
    P[0]=P[1]=P[2]=0.0f;if(!(mu>0.0f)){const float l=W[0]>0.0f?fmaxf(0.0f,-wp0/W[0]):0.0f;P[0]=-l;return;}
    if(mu*sqrtf(wp1*wp1+wp2*wp2)<=wp0)return;   // in the polar: the projection is 0
    constexpr int kScan=16;
    constexpr float kC[kScan]={1.0f,0.92387953f,0.70710678f,0.38268343f,0.0f,-0.38268343f,-0.70710678f,-0.92387953f,-1.0f,-0.92387953f,-0.70710678f,-0.38268343f,0.0f,0.38268343f,0.70710678f,0.92387953f};
    constexpr float kS[kScan]={0.0f,0.38268343f,0.70710678f,0.92387953f,1.0f,0.92387953f,0.70710678f,0.38268343f,0.0f,-0.38268343f,-0.70710678f,-0.92387953f,-1.0f,-0.92387953f,-0.70710678f,-0.38268343f};
    const float tn=sqrtf(Ps[1]*Ps[1]+Ps[2]*Ps[2]);
    const float c0=tn>0.0f?Ps[1]/tn:1.0f,s0=tn>0.0f?Ps[2]/tn:0.0f;   // t0 = atan2(Ps_2, Ps_1)
    // The scan without divisions: where N > 0 and D > 0 the value is -N^2/(2 D),
    // so the best direction has the largest N^2 / D (compared crosswise).
    float bN=0.0f,bD=1.0f,cb=0.0f,sb=0.0f;   // P = 0: value 0
    #pragma unroll
    for(int k=0;k<kScan;++k) {
        const float c=c0*kC[k]-s0*kS[k],s=s0*kC[k]+c0*kS[k],d1=mu*c,d2=mu*s;
        const float Wd0=-W[0]+W[1]*d1+W[2]*d2,Wd1=-W[3]+W[4]*d1+W[5]*d2,Wd2=-W[6]+W[7]*d1+W[8]*d2;
        const float D=-Wd0+d1*Wd1+d2*Wd2,N=-wp0+d1*wp1+d2*wp2;
        if(N>0.0f && D>0.0f && N*N*bD>bN*bN*D){bN=N;bD=D;cb=c;sb=s;}
    }
    if(!(bN>0.0f))return;
    const float best=-0.5f*bN*bN/bD;
    constexpr float kStep=6.2831853f/float(kScan);
    float a=-kStep,b=kStep,u=0.0f,cx=cb,sx=sb;
    for(int it=0;it<24;++it) {
        float su,cu;exSinCosSmall(u,su,cu);cx=cb*cu-sb*su;sx=sb*cu+cb*su;
        const float d1=mu*cx,d2=mu*sx,e1=-d2,e2=d1;   // d = (-1, d1, d2), d' = (0, e1, e2), d'' = (0, -d1, -d2)
        const float Wd0=-W[0]+W[1]*d1+W[2]*d2,Wd1=-W[3]+W[4]*d1+W[5]*d2,Wd2=-W[6]+W[7]*d1+W[8]*d2;
        const float We0=W[1]*e1+W[2]*e2,We1=W[4]*e1+W[5]*e2,We2=W[7]*e1+W[8]*e2;
        const float N=-wp0+d1*wp1+d2*wp2,N1=e1*wp1+e2*wp2,N2=-d1*wp1-d2*wp2;
        const float D=-Wd0+d1*Wd1+d2*Wd2,D1=e1*Wd1+e2*Wd2+(-We0+d1*We1+d2*We2);
        const float Wf0=W[1]*d1+W[2]*d2,Wf1=W[4]*d1+W[5]*d2,Wf2=W[7]*d1+W[8]*d2;   // W d'' = -W (0, d1, d2)
        const float D2=-d1*Wd1-d2*Wd2+2.0f*(e1*We1+e2*We2)-(-Wf0+d1*Wf1+d2*Wf2);
        float un;
        if(!(N>0.0f) || !(D>0.0f)){if(u>0.0f)b=u;else a=u;un=0.5f*(a+b);}
        else {
            const float F=2.0f*N1*D-N*D1,F1=2.0f*N2*D+N1*D1-N*D2;
            if(F>0.0f)a=u;else b=u;
            un=F1<0.0f?u-F/F1:0.5f*(a+b);
            if(!(un>a && un<b))un=0.5f*(a+b);
        }
        const bool done=fabsf(un-u)<=4.0f*FLT_EPSILON*kStep;
        u=un;if(done)break;
    }
    {float su,cu;exSinCosSmall(u,su,cu);cx=cb*cu-sb*su;sx=sb*cu+cb*su;}
    if(exValue(W,wp0,wp1,wp2,mu,cx,sx).v<best){cb=cx;sb=sx;}
    const float l=exValue(W,wp0,wp1,wp2,mu,cb,sb).l;P[0]=-l;P[1]=l*mu*cb;P[2]=l*mu*sb;
}
__device__ __forceinline__ void exCone(const float* W,const float* g,const float* Ps,float mu,float* P)
{
    const float tn=sqrtf(Ps[1]*Ps[1]+Ps[2]*Ps[2]);
    if(Ps[0]<=0.0f && tn<=mu*-Ps[0]){P[0]=Ps[0];P[1]=Ps[1];P[2]=Ps[2];return;}
    if(Ps[0]<=0.0f && mu>0.0f && tn>0.0f) {
        float t[2]={Ps[1]/tn,Ps[2]/tn},PN=0.0f;bool ok=false;
        for(int it=0;it<8;++it) {
            const float den=W[0]-mu*(W[1]*t[0]+W[2]*t[1]);
            if(!(den>0.0f)){ok=false;break;}
            PN=-g[0]/den;if(!(PN<=0.0f)){ok=false;break;}
            const float PT[2]={-mu*PN*t[0],-mu*PN*t[1]};
            // the slip after the impulse; the friction opposes it (P_T along -slip)
            const float s1=g[1]+W[3]*PN+W[4]*PT[0]+W[5]*PT[1],s2=g[2]+W[6]*PN+W[7]*PT[0]+W[8]*PT[1],sn=sqrtf(s1*s1+s2*s2);
            ok=true;if(!(sn>0.0f))break;
            const float u[2]={-s1/sn,-s2/sn};const float change=fabsf(u[0]-t[0])+fabsf(u[1]-t[1]);t[0]=u[0];t[1]=u[1];
            if(change<1e-4f)break;
        }
        if(ok) {
            P[0]=PN;P[1]=-mu*PN*t[0];P[2]=-mu*PN*t[1];
            float WPv[3];for(int i=0;i<3;++i)WPv[i]=W[3*i]*P[0]+W[3*i+1]*P[1]+W[3*i+2]*P[2];
            const float dE=g[0]*P[0]+g[1]*P[1]+g[2]*P[2]+0.5f*(P[0]*WPv[0]+P[1]*WPv[1]+P[2]*WPv[2]);
            if(dE<=0.0f)return;
        }
    }
    exConeMetric(W,Ps,mu,P);
}
// A round impactor (radius R, centre c) against a chunk's box (centre bc, half extents
// he, rotation q), all in the struck frame: its penetration (negative: the gap still
// open), the unit normal from the box to the sphere and the box's closest point. The
// centre inside the box: the nearest face's.
__device__ float exSphereBox(const PxVec3& c,float R,const PxVec3& bc,const PxVec3& he,const PxQuat& q,PxVec3& n,PxVec3& p)
{
    const PxVec3 l=q.rotateInv(c-bc);
    const PxVec3 cl(fminf(fmaxf(l.x,-he.x),he.x),fminf(fmaxf(l.y,-he.y),he.y),fminf(fmaxf(l.z,-he.z),he.z));
    const PxVec3 d=l-cl;const float dist=d.magnitude();
    if(dist>0.0f){n=q.rotate(d*(1.0f/dist));p=bc+q.rotate(cl);return R-dist;}
    // inside: the face of least depth
    const float ex=he.x-fabsf(l.x),ey=he.y-fabsf(l.y),ez=he.z-fabsf(l.z);
    PxVec3 nl(0.0f),pl=l;float depth;
    if(ex<=ey && ex<=ez){nl.x=l.x>=0.0f?1.0f:-1.0f;pl.x=nl.x*he.x;depth=ex;}
    else if(ey<=ez){nl.y=l.y>=0.0f?1.0f:-1.0f;pl.y=nl.y*he.y;depth=ey;}
    else{nl.z=l.z>=0.0f?1.0f:-1.0f;pl.z=nl.z*he.z;depth=ez;}
    n=q.rotate(nl);p=bc+q.rotate(pl);return R+depth;
}
// A small rotation vector as a quaternion (exp).
__device__ __forceinline__ PxQuat exRotation(const float* th)
{
    const float a=sqrtf(th[0]*th[0]+th[1]*th[1]+th[2]*th[2]);if(!(a>0.0f))return PxQuat(PxIdentity);
    const float s=sinf(0.5f*a)/a;return PxQuat(th[0]*s,th[1]*s,th[2]*s,cosf(0.5f*a));
}
// The window's own geometry for one row (Settings::compliant with chunk boxes): its
// impactor's sphere against its chunk's box where both are now (their window
// displacements), as the row's frame (n from the chunk to the impactor), arms and
// gap (or, closed, its depth: the whole intrusion). The vibe-land harness's
// --geometry fixed rebuilt each face radius of travel (scripts/impact/compliant-step.py).
// initial (the window's start): a penetration the stage's contact already has is the
// narrowphase finding it a tick late (FIDELITY_AUDIT H7), not a stored elastic state:
// it is taken as crushed depth (no force from it), the row starts velocity-level.
__device__ void exRefreshRow(const PxDestructionChunkBox* boxes,const ExNode* nodes,ExRow& x,Bond& b,bool initial=false)
{
    const ExNode& a=nodes[x.a];const ExNode& m=nodes[x.b];
    const PxDestructionChunkBox box=boxes[a.chunk];
    const PxQuat qa=exRotation(a.dth);
    const PxVec3 xa(a.x0[0]+a.dx[0],a.x0[1]+a.dx[1],a.x0[2]+a.dx[2]),pa(a.x0[0],a.x0[1],a.x0[2]);
    const PxVec3 bc=xa+qa.rotate(box.center-pa);
    const PxVec3 cm(m.x0[0]+m.dx[0],m.x0[1]+m.dx[1],m.x0[2]+m.dx[2]);
    PxVec3 n,p;const float pen=exSphereBox(cm,m.radius,bc,box.halfExtents,qa*box.rotation,n,p);
    frame(n,b.n,b.t1,b.t2);
    for(int q=0;q<3;++q){b.o0[q]=p[q]-xa[q];b.o1[q]=p[q]-cm[q];b.pc[q]=0.0f;}
    // The chunk's depth along the row (its box's extent along n), until its crush starts.
    if(!(x.crush&1u)){const PxQuat qb=qa*box.rotation;const PxVec3 he=box.halfExtents;
        x.depth=2.0f*(fabsf(n.dot(qb.getBasisVector0()))*he.x+fabsf(n.dot(qb.getBasisVector1()))*he.y+fabsf(n.dot(qb.getBasisVector2()))*he.z);}
    if(initial && pen>x.dp)x.dp=pen;
    if(pen>=0.0f){x.gap=0.0f;if(x.compliant)x.d=fmaxf(pen,x.dp);}else{x.gap=-pen;if(x.compliant)x.d=x.dp;}
}
// 1. The patches: one per island with a routed row, in row order; each
// patch's rows (at most kExRows) and its impactor bodies.
// A two-body row (Settings::explicitTwoBody) is the window's when either side of
// it is an impact: the struck side's (the routing: routeRows, v_n M sqrt(k / (M +
// m)) against its struck chunk's weakest joint), or the car's -- the same
// criterion mirrored, the car's chunk stopped against its own joints by a
// struck chunk the trial holds still: peak v_n sqrt(k_c m_c) against its weakest
// joint along the push (EN 1991-1-7 Annex C's hard-impact force). A contact
// below both is quasi-static: the trial's rigid support is what the car meets.
__device__ __forceinline__ bool exTwoBodyRow(const Inputs& in,const Settings& s,PxU32 r,PxU32 island)
{
    if(!s.explicitTwoBody)return false;
    const ContactRow& row=in.rows[r];const PxU32 o=row.other;
    if(o>=in.chunkCount || !(in.chunks[o].mass>0.0f) || chunkGone(in,o) || in.nodeIslands[o]==island)return false;
    if(row.chunk>=in.chunkCount || in.nodeIslands[row.chunk]!=island || !(in.chunks[row.chunk].mass>0.0f) || chunkGone(in,row.chunk))return false;
    if(row.resting || !(row.im>0.0f) || !isfinite(row.im) || !row.points)return false;
    if(!in.rowRouted || in.rowRouted[r])return true;   // the struck side's impact (or no routing: every row)
    // The car's side, in its cluster's frame: the push on its chunk is -normal.
    const PxQuat back=PxQuat(row.otherPose[0],row.otherPose[1],row.otherPose[2],row.otherPose[3]).getConjugate();
    PxVec3 n(row.normal[0],row.normal[1],row.normal[2]);if(!(n.magnitudeSquared()>0.0f))return false;n=n.getNormalized();
    const float arm[3]={row.point[0]-row.com[0],row.point[1]-row.com[1],row.point[2]-row.com[2]};float spin[3];cross3(row.spin,arm,spin);
    const float vn=fmaxf(0.0f,(row.velocity[0]+spin[0])*n.x+(row.velocity[1]+spin[1])*n.y+(row.velocity[2]+spin[2])*n.z);
    const PxVec3 push=back.rotate(-n);const float pc[3]={push.x,push.y,push.z};
    float k=0.0f,cap=FLT_MAX;
    for(PxU32 slot=in.nodeBegin[o];slot<in.nodeBegin[o+1];++slot) {
        const PxU32 i=in.nodeRefs[slot];if(!bondMember(in,i))continue;
        Bond b;if(!prepareBond(in,s,i,b))continue;
        k+=b.kl;
        const float a=(b.c0==o?1.0f:-1.0f)*dot3(b.n,pc),t=sqrtf(fmaxf(0.0f,1.0f-a*a));
        float f=FLT_MAX;if(fabsf(a)>0.0f)f=(a>0.0f?b.capC:b.capT)/fabsf(a);if(t>0.0f)f=fminf(f,b.capS/t);
        cap=fminf(cap,f);
    }
    return k>0.0f && vn*sqrtf(k*in.chunks[o].mass)>cap;
}
__global__ void exList(Inputs in,Settings s,Scratch w,ExScratch t)
{
    if(blockIdx.x || threadIdx.x)return;
    const PxU32 rows=in.rows?(in.rowCounter?min(*in.rowCounter,in.rowCount):in.rowCount):0u;
    PxU32 count=0;
    for(PxU32 r=0;r<rows;++r) {
        const PxU32 c=in.rows[r].chunk;if(c>=in.chunkCount)continue;
        const PxU32 island=in.nodeIslands[c];if(island>=in.chunkCount)continue;
        const bool stepped=stepRow(in,r,island);if(!stepped && !exTwoBodyRow(in,s,r,island))continue;
        PxU32 p=0;while(p<count && t.patches[p].island!=island)++p;
        // One window a car: a car's chunks are nodes of one patch only (the patches
        // share the chunk and bond maps, nodeOf and linkOf: a car in two patches got
        // the other's joints and nodes, and its windows gained 1e3-1e4 times their
        // kinetic energy). A car another patch holds: its rows here stay what they
        // were without two-body impacts (a rigid impactor where the struck side's
        // impact routed them; else the rigid solve's).
        const PxU32 o=in.rows[r].other;
        const PxU32 rowCar=(s.explicitTwoBody && o<in.chunkCount)?in.nodeIslands[o]:0xffffffffu;
        bool heldElsewhere=false;
        if(rowCar<in.chunkCount)for(PxU32 k=0;k<count;++k)heldElsewhere=heldElsewhere || (k!=p && (t.patches[k].car==rowCar || t.patches[k].island==rowCar));
        if(heldElsewhere && !stepped)continue;
        // (likewise a struck island another patch holds as its car: its chunks are that
        // patch's nodes; this row stays the rigid solve's)
        {bool carElsewhere=false;for(PxU32 k=0;k<count;++k)carElsewhere=carElsewhere || (k!=p && t.patches[k].car==island);if(carElsewhere)continue;}
        if(p==count) {
            if(count>=kExPatches){atomicOr(&w.status->error,1u);continue;}
            ExPatch e{};e.island=island;e.radius=s.stepRadius;e.seed=r;
            if(s.dynamicStruck && in.rows[r].clusterIm>0.0f){e.dynamic=1u;e.dynamicRow=r;e.radius=FLT_MAX;}
            t.patches[count++]=e;
        }
        ExPatch& e=t.patches[p];PxU32* list=t.rowList+size_t(p)*kExRows;
        if(e.listed>=kExRows){e.failed=1;continue;}
        bool body=true;for(PxU32 k=0;k<e.listed;++k)body=body && in.rows[list[k]].body!=in.rows[r].body;
        e.bodies+=body?1u:0u;list[e.listed++]=r;
        // The two-body impact: the first destructible other body of the patch's rows
        // (a live chunk of a dynamic island; one car a patch: another's rows stay rigid).
        if(s.explicitTwoBody && !heldElsewhere && e.car==0xffffffffu && o<in.chunkCount && in.chunks[o].mass>0.0f && !chunkGone(in,o)) {
            const PxU32 car=in.nodeIslands[o];
            if(car<in.chunkCount && car!=island){e.car=car;e.carRow=r;}
        }
    }
    // The dynamic sequence: a row patch of a dynamic island is dynamic (one patch per
    // island); the second submission adds a patch for every other dynamic island.
    if(t.seqIsland) {
        for(PxU32 p=0;p<count;++p)if(t.seqIsland[t.patches[p].island]) {
            t.patches[p].sequence=1u;
            if(s.sequenceDiag&8u){t.patches[p].listed=0u;t.patches[p].bodies=0u;t.patches[p].car=0xffffffffu;}   // (diagnostics: the rows left to the stage)
        }
        if(t.seqCreate)for(PxU32 i=0;i<in.chunkCount;++i) {
            if(!t.seqIsland[i])continue;
            PxU32 p=0;while(p<count && t.patches[p].island!=i)++p;
            if(p<count)continue;
            if(count>=kExPatches){atomicOr(&w.status->error,1u);if(t.seqCounters)atomicAdd(t.seqCounters+3,1u);continue;}   // (counted: the static verdict stands there)
            ExPatch e{};e.island=i;e.radius=s.stepRadius;e.seed=0xffffffffu;e.sequence=1u;t.patches[count++]=e;
        }
    }
    *t.patchCount=count;
}

__device__ void exFinish(Shared& sh,const Settings& s,const ExScratch& t,PxU32 p);
__device__ void exFinishDynamic(Shared& sh,const Settings& s,const ExScratch& t,PxU32 p);
// v <- q v (a car's bond frame and arms into the struck frame; no lambda: CuMetal captures).
__device__ __forceinline__ void exRotate(const PxQuat& q,float* v){const PxVec3 r=q.rotate(PxVec3(v[0],v[1],v[2]));v[0]=r.x;v[1]=r.y;v[2]=r.z;}
// A chunk's modulus for its contacts, from its own joints: each joint's stiffness
// is E A / L (the bridge's true stiffness, VIBE_BOND_TRUE_STIFFNESS: L the
// separation of its chunks along its normal, at least sqrt A), so E = k L / A,
// averaged over the chunk's joints. 0 where it has none (a rigid row).
__device__ float exModulus(const Inputs& in,const Settings& s,PxU32 c){return chunkModulus(in,s,c);}
// ---------------------------------------------------------------------------
// The dynamic sequence (Settings::dynamicSequence, PX_DESTRUCTION_DYNAMIC_SEQUENCE;
// vibe-land FIDELITY_AUDIT C10, docs/calibration/house-headers.md "Sequencing
// (C10)"; its CPU reference structures/town-kit/scripts/sequence-lab.py --law stage).
// An island whose static verdict would change its topology (a joint broken, a
// re-bearing contact's fastenings failed, lifted or closed) is decided by this
// window instead of by that one elastic snapshot: a failure then sheds its load
// in the order the structure's inertia gives (the plate over a removed bay breaks
// before it can pry up the uprights beyond it), where the snapshot broke every
// joint the redistribution would have relieved. The patch (its whole island when
// it fits, else the nodes within the radius of its seed chunks) differs from an
// impact patch in five ways:
//   - its start: the persisted state of the last window (per bond its force and
//     contact slip, per chunk its velocity), else the last accepted forces
//     (Inputs::base) at rest;
//   - its loads: the tick's (Inputs::accelerations: m a, -I alpha), not the rest
//     forces' -B J0, so a node moves by p + B J (the residual p + B J0 in
//     ExScratch::dynLoad, added to the joints' B (J - J0) in the gather);
//   - its bearing joints (re-bearing, PxgDestructionRebearing.cuh): one whose
//     fastenings reach capacity becomes a unilateral contact (exContactJoint), as
//     one in a contact state already is;
//   - its joints' damping: Rayleigh's stiffness-proportional damping, c = beta k on
//     each live joint (Chopra, Dynamics of Structures, 11.4), beta = 2 zeta /
//     omega_K: zeta the material's modal ratio (EN 1995-2:2004 6.4(2): 0.015 for
//     timber with mechanical joints) on the frequency of the deformation the island
//     has, omega_K^2 = (K v)^T M^-1 (K v) / v^T K v (mechanisms, K v = 0, drop out;
//     every kExDampSample substeps and after an event), more above it. Integrated
//     implicitly per joint, F = -c d / (1 + h c W), W its split inverse mass (each
//     end's times its live joints: Jacobi), so h is unchanged. A joint is graded on
//     its spring's force J: the damping stands for its energy loss, not a stress it
//     carries (the implicit dashpot is near rigid on the stiffest joints' kHz rates);
//   - it runs the whole tick, and persists its state for the next.
// The damping's frequency is sampled every kExDampSample substeps (and after an event):
// over that many substeps (about 1 ms at h = 33 us) the deformation's frequency content
// moves little; a sample costs a joint pass and a gather.
constexpr PxU32 kExDampSample=32;
constexpr float kExWhole=1e18f;   // a dynamic patch's radius before any shrink: the whole island (its square stays finite)
// A dynamic patch's seeds, after its rows' struck chunks (and their swept ends) in hit: its
// island's seed chunks in chunk order, as many as fit (hit holds 2 kExRows). Returns the count.
__device__ PxU32 exBuildDynamicSeeds(const Inputs& in,const ExScratch& t,Shared& sh,PxU32 island,float* hit,PxU32 nrows)
{
    if(!t.seqSeed)return nrows;
    PxU32 base=nrows;
    for(PxU32 tile=0;tile<in.chunkCount;tile+=kThreads) {
        const PxU32 i=tile+threadIdx.x;
        const PxU32 member=(i<in.chunkCount && t.seqSeed[i] && in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i))?1u:0u;
        PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
        if(member && base+prefix<2u*kExRows){const PxVec3 x=in.chunks[i].position;hit[3*(base+prefix)]=x.x;hit[3*(base+prefix)+1]=x.y;hit[3*(base+prefix)+2]=x.z;}
        base+=total;
    }
    __syncthreads();
    return min(base,2u*kExRows);
}
// A dynamic patch's chunk node: its persisted velocity, its load p (exFinishDynamic
// turns it into the residual p + B J0).
__device__ void exDynamicNode(const Inputs& in,const ExScratch& t,PxU32 p,PxU32 k,PxU32 i,ExNode& n)
{
    if(t.pChunk && (t.pChunk[i]&1u) && !t.seqAtRest)for(int q=0;q<6;++q)n.v[q]=t.pV[6*size_t(i)+q];
    const auto c=in.chunks[i];const auto a=in.accelerations[i];float* f=t.dynLoad+(size_t(p)*kExNodes+k)*6;
    f[0]=a.linear.x*c.mass;f[1]=a.linear.y*c.mass;f[2]=a.linear.z*c.mass;
    f[3]=-a.angular.x*c.inertia;f[4]=-a.angular.y*c.inertia;f[5]=-a.angular.z*c.inertia;
    t.dynPos[size_t(p)*kExNodes+k]=make_float4(c.position.x,c.position.y,c.position.z,0.0f);
}
// A dynamic patch's joint: its persisted force and contact state (else the last frame's
// trial forces: the equilibrium before this tick's change, the study's start), whether it is a
// bearing joint, its damping ratio (in damp[0] until exFinishDynamic). A joint of a
// frozen island that thaws starts from its carried force: the frozen one plus the
// static solve's elastic increment since the freeze (exact by superposition while the
// topology was the frozen one's).
__device__ void exDynamicLink(const Inputs& in,const Settings& s,const ExScratch& t,PxU32 p,PxU32 l,PxU32 i,const Bond& b,ExLink& e)
{
    float* c=t.damp+(size_t(p)*kExLinks+l)*8;float* cs=t.cslip+(size_t(p)*kExLinks+l)*2;
    cs[0]=cs[1]=0.0f;
    const PxU32 persisted=t.pBond?t.pBond[i]:0u;
    if(persisted&1u){for(int q=0;q<6;++q){e.J0[q]=t.pJ[6*size_t(i)+q];e.J[q]=e.J0[q];}cs[0]=t.pSlip[2*size_t(i)];cs[1]=t.pSlip[2*size_t(i)+1];}
    else if(t.seqBase){float x[6];toLocal(b,t.seqBase[i],x);for(int q=0;q<6;++q){e.J0[q]=x[q];e.J[q]=x[q];}}
    if((persisted&4u) && t.frozenForce && in.elastic) {
        const PxDestructionVectorPair f=t.frozenForce[i],a=in.elastic[i],z=t.freezeElastic[i];
        PxDestructionVectorPair c0;c0.linear=f.linear+(a.linear-z.linear);c0.angular=f.angular+(a.angular-z.angular);
        float x[6];toLocal(b,c0,x);for(int q=0;q<6;++q){e.J0[q]=x[q];e.J[q]=x[q];}
    }
    const PxDestructionBondSection section=in.sections?in.sections[i]:PxDestructionBondSection{};
    if(section.bearingDepth0>0.0f && section.bearingDepth1>0.0f && s.sectionBending) {
        e.state|=eEX_BEARING;
        const PxU32 bear=in.bearState?in.bearState[i]:0u;   // eBEAR_CONTACT 1, eBEAR_LIFTED 2
        if(bear==1u || bear==2u || (persisted&2u))e.state|=eEX_CONTACT;
        if((e.state&eEX_CONTACT) && !(e.J0[0]<0.0f))e.state|=eEX_OPEN;
    }
    for(int q=0;q<8;++q)c[q]=0.0f;c[6]=in.damping?in.damping[in.bonds[i].material]:s.dynamicDamping;
}
// 2. Each patch (a block): its nodes within the radius of a struck chunk
// (shrunk until they fit), impactors, rows, joints (each from its lower local
// end, in node order: deterministic), each node's joints and rows, the rest
// forces' load, and the substep.
__global__ __launch_bounds__(kThreads) void exBuild(Inputs in,Settings s,Scratch w,ExScratch t)
{
    __shared__ Shared sh;
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    ExPatch& sp=t.patches[p];const PxU32 island=sp.island;
    ExNode* nodes=t.nodes+size_t(p)*kExNodes;Bond* bonds=t.bonds+size_t(p)*kExLinks;ExLink* links=t.links+size_t(p)*kExLinks;
    Bond* rowBonds=t.rowBonds+size_t(p)*kExRows;ExRow* exRows=t.rows+size_t(p)*kExRows;
    PxU32* adj=t.adj+size_t(p)*2*kExLinks;PxU32* rowAdj=t.rowAdj+size_t(p)*2*kExRows;
    // The patch's rows (exList) and their struck chunks' positions.
    const PxU32 nrows=sp.listed,bodies=sp.bodies;const PxU32* list=t.rowList+size_t(p)*kExRows;
    __shared__ float hit[6*kExRows];
    for(PxU32 k=threadIdx.x;k<nrows;k+=kThreads){const PxVec3 x=in.chunks[in.rows[list[k]].chunk].position;hit[3*k]=x.x;hit[3*k+1]=x.y;hit[3*k+2]=x.z;}
    // The window's own geometry (Settings::compliant with chunk boxes): the patch reaches
    // along each impactor's path over the tick too (its centre at the tick's end), where its
    // swept rows are.
    const bool sweep=s.compliant && in.chunkBoxes;
    const PxU32 nhits=sweep?2u*nrows:nrows;
    if(sweep)for(PxU32 k=threadIdx.x;k<nrows;k+=kThreads){const ContactRow& q=in.rows[list[k]];
        for(int a=0;a<3;++a)hit[3*(nrows+k)+a]=q.com[a]+q.velocity[a]*s.dt;}
    __syncthreads();
    // A dynamic patch: its seed chunks after the rows' (none found: the whole island).
    const PxU32 nhit=sp.sequence?exBuildDynamicSeeds(in,t,sh,island,hit,nhits):nhits;
    const PxDestructionStressChunk* const chunks=in.chunks;   // a local copy: the build writes through other pointers
    auto near=[chunks,nhit](PxU32 i,float radius,const float* hit){const PxVec3 x=chunks[i].position;const float r2=radius*radius;
        if(!nhit)return true;
        for(PxU32 k=0;k<nhit;++k){const float dx=x.x-hit[3*k],dy=x.y-hit[3*k+1],dz=x.z-hit[3*k+2];if(dx*dx+dy*dy+dz*dz<=r2)return true;}return false;};
    // Radius: shrink until the island's chunks within it fit beside the impactors.
    // The two-body car: all of its island's live chunks (a car is small; its
    // remainder cannot be held as a support: it is free), or none if they would
    // not fit beside a patch of the struck island (its rows then stay rigid).
    PxU32 carCount=0;
    if(sp.car!=0xffffffffu) {
        PxU32 c=0;for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads)c+=(in.nodeIslands[i]==sp.car && in.chunks[i].mass>0.0f && !chunkGone(in,i))?1u:0u;
        carCount=blockCount(sh,c);
        if(carCount+bodies>=kExNodes/2){__syncthreads();if(!threadIdx.x)sp.car=0xffffffffu;__syncthreads();carCount=0;}
    }
    const PxU32 car=sp.car;
    // (a dynamic struck island: all of it, free; one too large for the patch falls
    // back to the anchored patch around its rows, its remainder held: truncated;
    // a dynamic-sequence patch: its whole island, else around its seeds)
    const bool dynamic=sp.dynamic!=0u;
    const float radius0=sp.sequence?kExWhole:(dynamic?FLT_MAX:s.stepRadius);
    float radius=radius0;PxU32 count=0;
    for(int attempt=0;attempt<33;++attempt) {
        PxU32 c=0;
        for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads)
            c+=(in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i) && near(i,radius,hit))?1u:0u;
        count=blockCount(sh,c);
        if(count+bodies+carCount<=kExNodes)break;
        if(sp.sequence) {
            // A dynamic island too large for a patch: from the farthest chunk's distance to its nearest seed.
            if(radius>=kExWhole && nhit) {
                float far2=0.0f;
                for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads)if(in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i)) {
                    const PxVec3 x=in.chunks[i].position;float d2=FLT_MAX;
                    for(PxU32 k=0;k<nhit;++k){const float dx=x.x-hit[3*k],dy=x.y-hit[3*k+1],dz=x.z-hit[3*k+2];d2=fminf(d2,dx*dx+dy*dy+dz*dz);}
                    far2=fmaxf(far2,d2);}
                radius=sqrtf(blockMax(sh,far2));
            }
            radius*=0.85f;
        } else radius=radius==FLT_MAX?s.stepRadius:radius*0.85f;
    }
    if(!threadIdx.x){sp.radius=radius;if(radius<radius0)sp.truncated=1;sh.flag=0;}
    __syncthreads();
    // Chunk nodes (chunk order).
    for(PxU32 tile=0;tile<in.chunkCount;tile+=kThreads) {
        const PxU32 i=tile+threadIdx.x;PxU32 member=0;
        if(i<in.chunkCount && in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i))member=near(i,radius,hit)?1u:0u;
        PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
        if(member) {
            const PxU32 k=sh.flag+prefix;
            if(k<kExNodes){t.nodeOf[i]=(p<<16)|k;ExNode n{};n.chunk=i;n.tensor=0;const auto c=in.chunks[i];
                n.im=1.0f/c.mass;n.Iinv[0]=n.Iinv[1]=n.Iinv[2]=c.inertia>0.0f?1.0f/c.inertia:0.0f;
                // (a dynamic struck island's chunks too start at rest: the window's frame
                // is its cluster's, moving with it -- the rows' velocities are relative
                // to its rigid motion at the tick's start; the frame's rotation over the
                // window, a few ms, is left out)
                n.x0[0]=c.position.x;n.x0[1]=c.position.y;n.x0[2]=c.position.z;
                if(sp.sequence)exDynamicNode(in,t,p,k,i,n);
                nodes[k]=n;}
        }
        __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
    }
    // The car's chunks (chunk order), in the struck frame: its cluster's pose there
    // (the row's otherPose), each chunk's velocity its body's rigid motion at the
    // tick's start (the row's, relative to the struck cluster) at its position.
    const PxU32 structNodes=min(sh.flag,kExNodes);
    __syncthreads();
    if(car!=0xffffffffu) {
        const ContactRow& q=in.rows[sp.carRow];
        const PxQuat rq(q.otherPose[0],q.otherPose[1],q.otherPose[2],q.otherPose[3]);const PxVec3 rp(q.otherPose[4],q.otherPose[5],q.otherPose[6]);
        const PxVec3 vel(q.velocity[0],q.velocity[1],q.velocity[2]),spin(q.spin[0],q.spin[1],q.spin[2]),com(q.com[0],q.com[1],q.com[2]);
        for(PxU32 tile=0;tile<in.chunkCount;tile+=kThreads) {
            const PxU32 i=tile+threadIdx.x;
            const PxU32 member=(i<in.chunkCount && in.nodeIslands[i]==car && in.chunks[i].mass>0.0f && !chunkGone(in,i))?1u:0u;
            PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
            if(member) {
                const PxU32 k=sh.flag+prefix;
                if(k<kExNodes){t.nodeOf[i]=(p<<16)|k;ExNode n{};n.chunk=i;n.tensor=0;n.pad[1]=1u;const auto c=in.chunks[i];
                    n.im=1.0f/c.mass;n.Iinv[0]=n.Iinv[1]=n.Iinv[2]=c.inertia>0.0f?1.0f/c.inertia:0.0f;
                    const PxVec3 x=rq.rotate(c.position)+rp,v=vel+spin.cross(x-com);
                    n.v[0]=v.x;n.v[1]=v.y;n.v[2]=v.z;n.v[3]=spin.x;n.v[4]=spin.y;n.v[5]=spin.z;for(int a=0;a<6;++a)n.v0[a]=n.v[a];
                    n.x0[0]=x.x;n.x0[1]=x.y;n.x0[2]=x.z;   // (its start position, struck frame: the hand-off's world velocity)
                    nodes[k]=n;}
            }
            __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
        }
        if(!threadIdx.x){sp.carChunks=min(sh.flag,kExNodes)-structNodes;sp.twoBody=1u;for(int a=0;a<4;++a)sp.carQ[a]=q.otherPose[a];}
    }
    const PxU32 chunkNodes=min(sh.flag,kExNodes);
    __syncthreads();
    // Impactors and rows (one thread, in row order: at most kExRows rows; the
    // bodies seen so far in threadgroup memory), then the rows' geometry
    // (prepareRow) on every thread.
    __shared__ PxU32 rowBody[kExRows],rowEnd[2*kExRows];
    if(!threadIdx.x) {
        PxU32 n=chunkNodes,k=0,impactors=0;
        for(PxU32 j=0;j<nrows;++j) {
            const PxU32 r=list[j];
            const ContactRow& q=in.rows[r];const PxU32 sc=t.nodeOf[q.chunk];
            if(sc==0xffffffffu || (sc>>16)!=p)continue;
            PxU32 node=0xffffffffu;const PxU32 body=q.body;
            if(car!=0xffffffffu && q.other<in.chunkCount && in.nodeIslands[q.other]==car){const PxU32 lo=t.nodeOf[q.other];if(lo!=0xffffffffu && (lo>>16)==p)node=lo&0xffffu;}
            if(node==0xffffffffu)for(PxU32 e=0;e<k;++e)if(rowBody[e]==body && rowEnd[2*e+1]>=chunkNodes){node=rowEnd[2*e+1];break;}
            if(node==0xffffffffu) {
                if(n>=kExNodes){sp.failed=1;continue;}
                node=n++;++impactors;
                ExNode m{};m.chunk=in.chunkCount+p*kExNodes+node;m.tensor=1;m.im=q.im;for(int a=0;a<6;++a)m.Iinv[a]=q.ii[a];
                for(int a=0;a<3;++a){m.v[a]=q.velocity[a];m.v[3+a]=q.spin[a];}
                for(int a=0;a<6;++a)m.v0[a]=m.v[a];
                for(int a=0;a<3;++a)m.x0[a]=q.com[a];
                // A round impactor (its inertia isotropic, products nil): a sphere of I = 2/5 m R^2,
                // the window's own geometry's (Settings::compliant with chunk boxes).
                if(sweep && q.im>0.0f) {
                    const float* S=q.ii;const float i0=S[0],tol=1e-3f*i0;
                    if(i0>0.0f && fabsf(S[1]-i0)<=tol && fabsf(S[2]-i0)<=tol && fabsf(S[3])<=tol && fabsf(S[4])<=tol && fabsf(S[5])<=tol)m.radius=sqrtf(2.5f*q.im/i0);
                }
                nodes[node]=m;
            }
            ExRow e{};e.a=sc&0xffffu;e.b=node;e.row=r;e.geo=(sweep && nodes[node].tensor && nodes[node].radius>0.0f && in.chunkBoxes[q.chunk].halfExtents.magnitudeSquared()>0.0f)?1u:0u;exRows[k]=e;rowBody[k]=body;rowEnd[2*k]=e.a;rowEnd[2*k+1]=node;++k;
        }
        // The swept rows: each round impactor against every chunk of the patch its sphere can
        // reach over the tick (its box within its radius of the path the impactor's centre
        // takes at its start velocity), one row a pair.
        if(sweep)for(PxU32 b=chunkNodes;b<n;++b) {
            const ExNode& m=nodes[b];if(!m.tensor || !(m.radius>0.0f))continue;
            PxU32 first=0xffffffffu;for(PxU32 e=0;e<k;++e)if(rowEnd[2*e+1]==b){first=exRows[e].row;break;}
            if(first==0xffffffffu)continue;
            const PxVec3 c0(m.x0[0],m.x0[1],m.x0[2]),vel(m.v[0],m.v[1],m.v[2]),c1=c0+vel*s.dt,seg=c1-c0;const float L2=seg.magnitudeSquared();
            for(PxU32 a=0;a<structNodes;++a) {
                if(k>=kExRows){sp.uncovered=1u;break;}
                bool have=false;for(PxU32 e=0;e<k && !have;++e)have=rowEnd[2*e]==a && rowEnd[2*e+1]==b;
                if(have)continue;
                const PxDestructionChunkBox box=in.chunkBoxes[nodes[a].chunk];
                if(!(box.halfExtents.magnitudeSquared()>0.0f))continue;   // a chunk with no box (a vehicle part's)
                const float tt=L2>0.0f?fminf(fmaxf((box.center-c0).dot(seg)/L2,0.0f),1.0f):0.0f;
                if((box.center-(c0+seg*tt)).magnitude()>m.radius+box.halfExtents.magnitude())continue;
                ExRow e{};e.a=a;e.b=b;e.row=first;e.geo=3u;exRows[k]=e;rowBody[k]=in.rows[first].body;rowEnd[2*k]=a;rowEnd[2*k+1]=b;++k;++sp.swept;
            }
        }
        sp.nodes=n;sp.chunks=chunkNodes;sp.rows=k;sp.impactors=impactors;
    }
    __syncthreads();
    // Coverage (the window's own geometry): every chunk of a struck cluster within a round
    // impactor's reach over the tick must be a node of this patch (with a row) for the
    // corrected pass to drop its pairs with that cluster.
    if(sweep) {
        for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads) {
            // (a support of the struck cluster in reach too: the window has no row on a support,
            // the ground the corrected pass must still meet)
            if(chunkGone(in,i))continue;
            const PxU32 lo=t.nodeOf[i];if(lo!=0xffffffffu && (lo>>16)==p)continue;
            const PxDestructionChunkBox box=in.chunkBoxes[i];if(!(box.halfExtents.magnitudeSquared()>0.0f))continue;
            bool struck=false;for(PxU32 e=0;e<sp.rows && !struck;++e)struck=in.chunks[nodes[exRows[e].a].chunk].cluster==in.chunks[i].cluster;
            if(!struck)continue;
            for(PxU32 b=chunkNodes;b<sp.nodes;++b) {
                const ExNode& m=nodes[b];if(!m.tensor || !(m.radius>0.0f))continue;
                const PxVec3 c0(m.x0[0],m.x0[1],m.x0[2]),seg=PxVec3(m.v[0],m.v[1],m.v[2])*s.dt;const float L2=seg.magnitudeSquared();
                const float tt=L2>0.0f?fminf(fmaxf((box.center-c0).dot(seg)/L2,0.0f),1.0f):0.0f;
                if((box.center-(c0+seg*tt)).magnitude()<=m.radius+box.halfExtents.magnitude()){atomicOr(&sp.uncovered,1u);break;}
            }
        }
        __syncthreads();
    }
    for(PxU32 k=threadIdx.x;k<sp.rows;k+=kThreads){Bond b;prepareRow(in,s,exRows[k].row,b);b.c1=in.chunkCount+p*kExNodes+rowEnd[2*k+1];
        // A two-body row's other end is the car's chunk, not its body's centre of mass.
        const PxU32 bn=rowEnd[2*k+1];
        if(bn<chunkNodes){const ContactRow& q=in.rows[exRows[k].row];const PxQuat rq(q.otherPose[0],q.otherPose[1],q.otherPose[2],q.otherPose[3]);
            const PxVec3 x=rq.rotate(in.chunks[nodes[bn].chunk].position)+PxVec3(q.otherPose[4],q.otherPose[5],q.otherPose[6]);
            b.o1[0]=q.point[0]-x.x;b.o1[1]=q.point[1]-x.y;b.o1[2]=q.point[2]-x.z;b.c1=nodes[bn].chunk;}
        rowBonds[k]=b;}
    const PxU32 nn=sp.nodes,nr=sp.rows;
    // Joints, each from its lower local end (or its only patch end): count, scan, write.
    if(!threadIdx.x)sh.flag=0;
    __syncthreads();
    for(PxU32 tile=0;tile<chunkNodes;tile+=kThreads) {
        const PxU32 k=tile+threadIdx.x;PxU32 own=0;
        const PxU32 c=k<chunkNodes?nodes[k].chunk:0u;
        if(k<chunkNodes)for(PxU32 slot=in.nodeBegin[c];slot<in.nodeBegin[c+1];++slot) {
            const PxU32 i=in.nodeRefs[slot];if(!bondMember(in,i))continue;
            const auto bd=in.bonds[i];const PxU32 other=bd.chunk0==c?bd.chunk1:bd.chunk0;
            const PxU32 lo=t.nodeOf[other];if(lo!=0xffffffffu && (lo>>16)==p && (lo&0xffffu)<k)continue;
            ++own;
        }
        PxU32 prefix;const PxU32 total=blockScan(sh,own,prefix);
        PxU32 l=sh.flag+prefix;
        if(k<chunkNodes)for(PxU32 slot=in.nodeBegin[c];slot<in.nodeBegin[c+1];++slot) {
            const PxU32 i=in.nodeRefs[slot];if(!bondMember(in,i))continue;
            const auto bd=in.bonds[i];const PxU32 other=bd.chunk0==c?bd.chunk1:bd.chunk0;
            const PxU32 lo=t.nodeOf[other];if(lo!=0xffffffffu && (lo>>16)==p && (lo&0xffffu)<k)continue;
            if(l>=kExLinks){atomicOr(&sp.failed,1u);continue;}
            Bond b;
            if(!prepareBond(in,s,i,b)){b=Bond{};b.bond=i;b.c0=bd.chunk0;b.c1=bd.chunk1;b.flags=0;}
            const PxU32 a0=t.nodeOf[b.c0],a1=t.nodeOf[b.c1];
            ExLink e{};e.a=(a0!=0xffffffffu && (a0>>16)==p)?(a0&0xffffu):0xffffffffu;e.b=(a1!=0xffffffffu && (a1>>16)==p)?(a1&0xffffu):0xffffffffu;
            e.state=(b.flags&eALIVE)?(eEX_LIVE|((b.flags&eDUCTILE)?eEX_DUCTILE:0u)|(b.mu>0.0f?eEX_FRICTION:0u)):0u;
            float x[6]={0,0,0,0,0,0};toLocal(b,in.base[i],x);
            for(int q=0;q<6;++q){e.J0[q]=x[q];e.J[q]=x[q];}
            // A car's joint: its frame and arms (its cluster's) rotated into the struck
            // frame (the bond-frame forces x are the same in both).
            if(car!=0xffffffffu && in.nodeIslands[c]==car) {
                const PxQuat rq(sp.carQ[0],sp.carQ[1],sp.carQ[2],sp.carQ[3]);
                exRotate(rq,b.n);exRotate(rq,b.t1);exRotate(rq,b.t2);exRotate(rq,b.o0);exRotate(rq,b.o1);exRotate(rq,b.pc);
                e.state|=eEX_CAR;
            }
            e.slip=in.slipBefore?in.slipBefore[i]:0.0f;e.limit=b.slip;e.brokeAt=-1.0f;
            // A dead-load dynamic patch (no rows): the static model's stiffness, whose
            // equilibrium it starts from (an impact window keeps the impact solve's).
            if(sp.sequence && !nrows && in.staticStiffness && in.stiffness && !(e.state&eEX_CAR)) {
                const PxU32 mat=in.bonds[i].material;const float ki=in.stiffness[mat],ks=in.staticStiffness[mat];
                if(ki>0.0f && ks>0.0f){const float f=ks/ki;b.kl*=f;b.kt*=f;b.k0*=f;b.k1*=f;}
            }
            if(sp.sequence && !(e.state&eEX_CAR))exDynamicLink(in,s,t,p,l,i,b,e);
            bonds[l]=b;links[l]=e;t.linkOf[i]=l;++l;
        }
        __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
    }
    if(!threadIdx.x)sp.links=min(sh.flag,kExLinks);
    __syncthreads();
    const PxU32 nl=sp.links;
    // Each node's joints (CSR, in the chunk's bond-slot order) and rows.
    for(PxU32 pass=0;pass<2;++pass) {
        if(!threadIdx.x)sh.flag=0;
        __syncthreads();
        for(PxU32 tile=0;tile<nn;tile+=kThreads) {
            const PxU32 k=tile+threadIdx.x;PxU32 deg=0;
            if(k<nn) {
                if(!pass && k<chunkNodes){const PxU32 c=nodes[k].chunk;
                    for(PxU32 slot=in.nodeBegin[c];slot<in.nodeBegin[c+1];++slot){const PxU32 l=t.linkOf[in.nodeRefs[slot]];if(l!=0xffffffffu && l<nl)++deg;}}
                if(pass)for(PxU32 r=0;r<nr;++r)deg+=(rowEnd[2*r]==k?1u:0u)+(rowEnd[2*r+1]==k?1u:0u);
            }
            PxU32 prefix;const PxU32 total=blockScan(sh,deg,prefix);
            if(k<nn) {
                PxU32 at=sh.flag+prefix;
                if(!pass) {
                    nodes[k].jointBegin=at;
                    if(k<chunkNodes){const PxU32 c=nodes[k].chunk;
                        for(PxU32 slot=in.nodeBegin[c];slot<in.nodeBegin[c+1];++slot){const PxU32 l=t.linkOf[in.nodeRefs[slot]];
                            if(l!=0xffffffffu && l<nl)adj[at++]=(l<<1)|(links[l].a==k?0u:1u);}}
                    nodes[k].jointEnd=at;
                } else {
                    nodes[k].rowBegin=at;
                    for(PxU32 r=0;r<nr;++r){if(rowEnd[2*r]==k)rowAdj[at++]=r<<1;if(rowEnd[2*r+1]==k)rowAdj[at++]=(r<<1)|1u;}
                    nodes[k].rowEnd=at;
                }
            }
            __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
        }
    }
    // Compliant rows (Settings::compliantRows, and every two-body row): Johnson's
    // flat punch, k = 2 a E*, 1/E* = 1/E_a + 1/E_b (Poisson's ratio left out:
    // (1 - nu^2) >= 0.91 for nu <= 0.3, so k is at most 10% stiff; a rigid
    // impactor's side is rigid, 1/E_b = 0). The contact radius a from the stage's
    // patch: its points' spread sigma (PhysX places a patch's points on its
    // outline: sigma is the radius of a round patch, its RMS radius 1/sqrt 2 of
    // a square's half-diagonal), at least the Hertz radius sqrt(R d) of the
    // depth d reached in the window (R the smaller chunk's equivalent sphere),
    // at most the smaller chunk's face, sqrt(V^(2/3) / pi). A chunk's modulus
    // from its joints (exModulus); a row whose struck chunk has none stays rigid.
    if(s.compliantRows || sp.twoBody) {
        for(PxU32 k=threadIdx.x;k<nr;k+=kThreads) {
            ExRow& e=exRows[k];const ContactRow& q=in.rows[e.row];
            const bool carRow=e.b<chunkNodes;
            e.gap=fmaxf(-q.patch[1],0.0f);
            if(!s.compliantRows && !carRow)continue;
            const PxU32 ca=nodes[e.a].chunk,cb=carRow?nodes[e.b].chunk:0xffffffffu;
            const float Ea=exModulus(in,s,ca),Eb=carRow?exModulus(in,s,cb):0.0f;
            if(!(Ea>0.0f))continue;
            float Va=in.chunks[ca].volume,V=carRow?fminf(Va,in.chunks[cb].volume):Va;if(!(V>0.0f))V=Va;
            e.compliant=1u;e.d=0.0f;e.Estar=1.0f/(1.0f/Ea+(Eb>0.0f?1.0f/Eb:0.0f));e.sigma=q.patch[0];
            // Hertz's relative curvature, 1/R = 1/R_a + 1/R_b: each chunk's equivalent sphere,
            // a rigid impactor's from its own mass and inertia (a solid sphere: I = 2/5 m R^2).
            const float Ra=cbrtf(0.75f*Va/3.14159265f);
            float Rb=carRow?cbrtf(0.75f*in.chunks[cb].volume/3.14159265f):0.0f;
            if(!carRow){const float Ii=fmaxf(q.ii[0],fmaxf(q.ii[1],q.ii[2]));if(Ii>0.0f && q.im>0.0f)Rb=sqrtf(2.5f/(Ii/q.im));}
            e.R=Rb>0.0f?Ra*Rb/(Ra+Rb):Ra;e.face=sqrtf(powf(V,2.0f/3.0f)/3.14159265f);
            // The struck side's crush (Settings::compliant): its material's onset and plateau,
            // its depth along the row (the cube of its volume, V^(1/3)), and the depth a
            // crush of earlier ticks left (its accepted damage, the crushed share of it).
            if(s.compliant) {
                crushLaw(in.materials[in.chunks[ca].material],e.on,e.pl);
                if(!(e.on<FLT_MAX)){e.on=e.pl=0.0f;}   // no crush law: the row is the two-body law's alone (exCompliantRow)
                e.depth=cbrtf(fmaxf(in.chunks[ca].volume,0.0f));
                e.dp=(in.crushed && in.crushed[ca].damage>0.0f)?fminf(in.crushed[ca].damage,1.0f)*e.depth:0.0f;
                // The row starts at its carried crushed depth, velocity-level (elastic depth 0): a
                // fresh contact's penetration is the narrowphase finding it a tick late (FIDELITY_AUDIT
                // H7), not a stored elastic state; a crater carried from earlier ticks keeps its depth
                // for its radius. A partly crushed chunk is crushing.
                e.d=e.dp;e.crush=e.dp>0.0f?1u:0u;e.Fa=0.0f;e.ac=0.0f;
            }
            atomicAdd(&sp.compliant,1u);
        }
    }
    __syncthreads();
    // The window's own geometry (Settings::compliant with chunk boxes): each round
    // impactor's rows from its sphere and their chunks' boxes at the window's start (a
    // swept row: no patch of its own), and the refresh interval: the time the fastest
    // impactor takes to move one face radius of the chunks its rows meet (a row's frame is
    // the tangent plane of its pair's distance; it holds while its point stays on the face).
    if(s.compliant && in.chunkBoxes) {
        for(PxU32 k=threadIdx.x;k<nr;k+=kThreads){ExRow& e=exRows[k];if(!e.geo)continue;if(e.geo&2u)e.sigma=0.0f;exRefreshRow(in.chunkBoxes,nodes,e,rowBonds[k],true);}
        __syncthreads();
        if(!threadIdx.x) {
            float tmin=FLT_MAX;
            for(PxU32 k=0;k<nr;++k){const ExRow& e=exRows[k];if(!e.geo || !(e.face>0.0f))continue;const ExNode& m=nodes[e.b];
                const float v=sqrtf(m.v[0]*m.v[0]+m.v[1]*m.v[1]+m.v[2]*m.v[2]);if(v>0.0f)tmin=fminf(tmin,e.face/v);}
            sp.refreshTime=tmin<FLT_MAX?tmin:0.0f;
        }
        __syncthreads();
    }
    exFinish(sh,s,t,p);
    if(sp.sequence)exFinishDynamic(sh,s,t,p);
}
// A built patch's rest load f0 = -B J0 per node, its Gershgorin bound and the
// substep (also for a patch filled by a test).
// The two-body car's joints at h: each one's own frequency from its split
// masses (its ends' inverse masses times their car joint counts, Tonge et al.
// 2012), the Gershgorin bound on S = K^1/2 W~ K^1/2; a joint with omega h above
// explicitSafety x 2 is implicit (trapezoidal: A = (I + h^2/2 K W~)^-1 h K), the
// rest stay explicit (their split frequency is within the symplectic bound).
__device__ void exImplicit(Shared& sh,const Settings& s,const ExScratch& t,PxU32 p)
{
    ExPatch& sp=t.patches[p];const float h=sp.h;
    const ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;ExLink* links=t.links+size_t(p)*kExLinks;
    float4* ja=t.ja+size_t(p)*kExLinks*9;
    PxU32 count=0;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
        ExLink& e=links[l];if(!(e.state&eEX_CAR) || !(e.state&eEX_LIVE) || !ja)continue;
        const Bond& b=bonds[l];float W[36];for(int i=0;i<36;++i)W[i]=0.0f;
        for(PxU32 end=0;end<2;++end) {
            const PxU32 k=end?e.b:e.a;if(k==0xffffffffu)continue;const ExNode& n=nodes[k];
            PxU32 deg=0;for(PxU32 j=n.jointBegin;j<n.jointEnd;++j){const ExLink& o=links[t.adj[size_t(p)*2*kExLinks+j]>>1];deg+=((o.state&eEX_CAR) && (o.state&eEX_LIVE))?1u:0u;}
            const float split=float(max(deg,1u));
            for(int q=0;q<6;++q){float xq[6]={0,0,0,0,0,0};xq[q]=1.0f;float f[6]={0,0,0,0,0,0},dv[6],e6[6]={0,0,0,0,0,0};
                exWrench(b,xq,end,f);exApplyInverse(n,f,dv);for(int c=0;c<6;++c)dv[c]*=split;exRelative(b,end,dv,e6);for(int i=0;i<6;++i)W[6*i+q]+=e6[i];}
        }
        float kk[6];exStiffness(b,kk);
        float gersh=0.0f;
        for(int i=0;i<6;++i){float r=0.0f;for(int q=0;q<6;++q)r+=fabsf(sqrtf(kk[i])*W[6*i+q]*sqrtf(kk[q]));gersh=fmaxf(gersh,r);}
        if(!(sqrtf(gersh)*h>s.explicitSafety*2.0f))continue;
        // M = I + h^2/2 K W~; A = M^-1 h K (Gauss-Jordan, partial pivoting)
        float M[36],A[36];
        for(int i=0;i<6;++i)for(int q=0;q<6;++q){M[6*i+q]=(i==q?1.0f:0.0f)+0.5f*h*h*kk[i]*W[6*i+q];A[6*i+q]=i==q?h*kk[i]:0.0f;}
        bool ok=true;
        for(int c=0;c<6 && ok;++c) {
            int piv=c;for(int r=c+1;r<6;++r)if(fabsf(M[6*r+c])>fabsf(M[6*piv+c]))piv=r;
            if(!(fabsf(M[6*piv+c])>0.0f)){ok=false;break;}
            if(piv!=c)for(int q=0;q<6;++q){float x=M[6*c+q];M[6*c+q]=M[6*piv+q];M[6*piv+q]=x;x=A[6*c+q];A[6*c+q]=A[6*piv+q];A[6*piv+q]=x;}
            const float d=1.0f/M[6*c+c];for(int q=0;q<6;++q){M[6*c+q]*=d;A[6*c+q]*=d;}
            for(int r=0;r<6;++r){if(r==c)continue;const float m=M[6*r+c];if(m==0.0f)continue;for(int q=0;q<6;++q){M[6*r+q]-=m*M[6*c+q];A[6*r+q]-=m*A[6*c+q];}}
        }
        if(!ok)continue;   // (singular: stays explicit -- it cannot be, M = I + a positive semidefinite product)
        float4* o=ja+size_t(9)*l;for(int i=0;i<9;++i)o[i]=make_float4(A[4*i],A[4*i+1],A[4*i+2],A[4*i+3]);
        e.state|=eEX_IMPLICIT;++count;
    }
    count=blockCount(sh,count);
    if(!threadIdx.x)sp.implicitJoints=count;
    __syncthreads();
}
// A re-bearing contact's friction coefficient: its material's (Bond::mu, Mohr-Coulomb
// shear, FIDELITY_AUDIT C11; for an exUnpack'ed joint after exUnpackFriction), as the
// stage's re-bearing law takes it (rebearVerdicts), else the contact law's
// (Settings::dynamicFriction: the re-bearing friction).
__device__ __forceinline__ float exContactMu(const Bond& b,float fallback){return b.mu>0.0f?b.mu:fallback;}
// A contact's transmitted force from its state J (exContactJoint's projection
// without its slip: J's shear is already within the cone).
__device__ __forceinline__ void exContactForce(const Bond& b,const float* J,float mu,float* F)
{
    for(int q=0;q<6;++q)F[q]=0.0f;if(!(J[0]<0.0f))return;
    const float C=-J[0],V=sqrtf(J[1]*J[1]+J[2]*J[2]),T=fabsf(J[3]),shear=V+b.gt*T,sc=shear>mu*C?mu*C/shear:1.0f;
    const float rock=b.h0*fabsf(J[4])+b.h1*fabsf(J[5]),bsc=rock>C?C/rock:1.0f;
    F[0]=J[0];F[1]=sc*J[1];F[2]=sc*J[2];F[3]=sc*J[3];F[4]=bsc*J[4];F[5]=bsc*J[5];
}
// A joint's stored energy at state J (k its stiffness): 1/2 J K^-1 J; a dynamic
// sequence's contact (the CPU study's book, sequence-lab.py contactv): its transmitted
// force F's, but a rocking contact's moments capped at F while it turns on to J,
// F K^-1 (J - F / 2) (the path to J without permanent set); open, nothing.
__device__ __forceinline__ float exJointEnergy(const Bond& b,const float* k,const float* J,PxU32 state,float mu)
{
    float u=0.0f;
    if(!(state&eEX_CONTACT)){for(int q=0;q<6;++q)if(k[q]>0.0f)u+=0.5f*J[q]*J[q]/k[q];return u;}
    float F[6];exContactForce(b,J,mu,F);
    for(int q=0;q<6;++q)if(k[q]>0.0f)u+=q<4?0.5f*F[q]*F[q]/k[q]:F[q]*(J[q]-0.5f*F[q])/k[q];
    return u;
}
__device__ void exFinish(Shared& sh,const Settings& s,const ExScratch& t,PxU32 p)
{
    ExPatch& sp=t.patches[p];const PxU32 nn=sp.nodes;
    ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;const ExLink* links=t.links+size_t(p)*kExLinks;
    const PxU32* adj=t.adj+size_t(p)*2*kExLinks;
    float* wr=t.wr+size_t(p)*kExLinks*12;
    float u0=0.0f;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads){const ExLink& e=links[l];if(!(e.state&eEX_LIVE))continue;
        float k[6];exStiffness(bonds[l],k);u0+=exJointEnergy(bonds[l],k,e.J0,e.state,exContactMu(bonds[l],s.dynamicFriction));}
    u0=blockSum(sh,u0);
    if(!threadIdx.x){sp.u0=u0;sp.keIn=sp.keOut=sp.fracture=sp.plastic=sp.dead=0.0f;}
    // The largest frequency's square: lambda_max(M^-1 K) = lambda_max(S), S =
    // M^-1/2 K M^-1/2 symmetric. Gershgorin on M^-1 K and on S bounds it; so,
    // tighter, does Collatz-Wielandt: lambda_max(S) <= rho(S) <= rho(|S|) <=
    // max_i (A x)_i / x_i for every positive x and every nonnegative A >= |S|
    // entrywise (Wielandt). A here: each node's diagonal block assembled before
    // its absolute values, the joints' blocks between nodes by theirs, and
    // each node's six dofs lumped into two groups, translation and rotation
    // (L, 2 x 2 per block: a group's largest row sum over each group; for x
    // constant on groups (|S| x)_r <= (L x)_g(r), so rho(|S|) <= the bound on
    // L). x = 1 is Gershgorin; power iteration on L from there tightens it
    // towards rho(L) (the cannonball's full island: Gershgorin on S 3.45e4
    // rad/s, after 8 products 2.92e4, rho(|S|) 2.89e4, the true 2.80e4). Every
    // iterate's bound holds; the least is kept. Joints act on chunk nodes
    // only (diagonal M^-1). L's blocks and the iterate live in t.wr, zeroed
    // after: per joint end (adj slot) its block against the other end, per
    // node its own block, x and y (2 per node; dofs with no stiffness x = 1).
    float* Lo=wr;float* Ld=wr+8*kExLinks;float* Y=Ld+4*kExNodes;PxU32* O=reinterpret_cast<PxU32*>(Y+2*kExNodes);   // O: each adj slot's other end
    __shared__ float X[2*kExNodes];   // the iterate (threadgroup memory: each product reads it per joint)
    float lambda=0.0f;
    {
        float gersh=0.0f,cw=0.0f;
        for(PxU32 k=threadIdx.x;k<nn;k+=kThreads) {
            ExNode& n=nodes[k];float f[6]={0,0,0,0,0,0},g[6]={0,0,0,0,0,0},y[6]={0,0,0,0,0,0};
            float D[36];for(int i=0;i<36;++i)D[i]=0.0f;
            for(PxU32 j=n.jointBegin;j<n.jointEnd;++j) {
                const PxU32 l=adj[j]>>1,end=adj[j]&1u;const ExLink& e=links[l];
                float lump[6]={0,0,0,0,0,0};
                // (a two-body car's joints are left out of the bound: exFinish makes the
                // ones it would not hold implicit)
                const bool bounded=(e.state&eEX_LIVE) && !(e.state&eEX_CAR);
                if(e.state&eEX_LIVE)exWrench(bonds[l],e.J0,end,f);
                if(bounded) {
                    const PxU32 other=end?e.a:e.b;float w[6]={0,0,0,0,0,0};
                    if(other!=0xffffffffu){const ExNode& o=nodes[other];for(int q=0;q<3;++q){w[q]=sqrtf(o.im);w[3+q]=sqrtf(o.Iinv[q]);}}
                    exGershgorin(bonds[l],end,other!=0xffffffffu,w,D,g,y,lump);
                }
                for(int a=0;a<2;++a)for(int c=0;c<2;++c)Lo[4*j+2*a+c]=lump[3*a+c]*sqrtf(a?n.Iinv[0]>0.0f?fmaxf(n.Iinv[0],fmaxf(n.Iinv[1],n.Iinv[2])):0.0f:n.im);
                O[j]=bounded?(end?e.a:e.b):0xffffffffu;
            }
            for(int q=0;q<6;++q)n.f0[q]=-f[q];
            float ld[4]={0,0,0,0};
            if(!n.tensor) {
                for(int r=0;r<6;++r){float t[2]={0.0f,0.0f};
                    for(int c=0;c<6;++c){const float a=fabsf(D[6*r+c]);g[r]+=a;t[c/3]+=a*sqrtf(c<3?n.im:n.Iinv[c-3]);}
                    y[r]+=t[0]+t[1];const float sr=sqrtf(r<3?n.im:n.Iinv[r-3]);
                    for(int c=0;c<2;++c)ld[2*(r/3)+c]=fmaxf(ld[2*(r/3)+c],sr*t[c]);}
                for(int q=0;q<6;++q){const float m=q<3?n.im:n.Iinv[q-3];gersh=fmaxf(gersh,m*g[q]);cw=fmaxf(cw,sqrtf(m)*y[q]);}
            }
            for(int q=0;q<4;++q)Ld[4*k+q]=ld[q];
            X[2*k]=X[2*k+1]=1.0f;
        }
        lambda=fminf(blockMax(sh,gersh),blockMax(sh,cw));
    }
    for(PxU32 pass=0;pass<kExBoundProducts;++pass) {
        float cw=0.0f,ymax=0.0f;
        for(PxU32 k=threadIdx.x;k<nn;k+=kThreads) {
            const ExNode& n=nodes[k];if(n.tensor)continue;
            float y[2];for(int a=0;a<2;++a)y[a]=Ld[4*k+2*a]*X[2*k]+Ld[4*k+2*a+1]*X[2*k+1];
            const PxU32 b0=n.jointBegin,b1=n.jointEnd;PxU32 j=b0;
            for(;j+4<=b1;j+=4) {   // four slots' loads issued before their sums (the same sums, in order)
                PxU32 o[4];float4 L[4];for(int u=0;u<4;++u){o[u]=O[j+u];L[u]=reinterpret_cast<const float4*>(Lo)[j+u];}
                for(int u=0;u<4;++u)if(o[u]!=0xffffffffu){y[0]+=L[u].x*X[2*o[u]]+L[u].y*X[2*o[u]+1];y[1]+=L[u].z*X[2*o[u]]+L[u].w*X[2*o[u]+1];}
            }
            for(;j<b1;++j){const PxU32 other=O[j];if(other==0xffffffffu)continue;
                for(int a=0;a<2;++a)y[a]+=Lo[4*j+2*a]*X[2*other]+Lo[4*j+2*a+1]*X[2*other+1];}
            for(int a=0;a<2;++a){cw=fmaxf(cw,y[a]/X[2*k+a]);Y[2*k+a]=y[a];ymax=fmaxf(ymax,y[a]);}
        }
        lambda=fminf(lambda,blockMax(sh,cw));
        ymax=blockMax(sh,ymax);
        if(!(ymax>0.0f))break;
        for(PxU32 i=threadIdx.x;i<2*nn;i+=kThreads)if(!nodes[i/2].tensor)X[i]=Y[i]>0.0f?Y[i]/ymax:1.0f;
        __syncthreads();
    }
    for(PxU32 i=threadIdx.x;i<12*kExLinks;i+=kThreads)wr[i]=0.0f;
    // Compliant rows: h resolves the shortest contact too. A row is an oscillator of
    // stiffness k and effective mass m = 1 / W_NN (its ends' inverse masses at its
    // point along its normal); backward Euler's period error is (w h)^2 / 3, so a
    // period error of at most eps needs h <= sqrt(3 eps m / k). k at the depth the
    // row could reach in the tick at its closing speed (the stiffest it gets).
    float hRow=FLT_MAX;
    if(sp.compliant) {
        const ExRow* rows=t.rows+size_t(p)*kExRows;const Bond* rowBonds=t.rowBonds+size_t(p)*kExRows;
        for(PxU32 r=threadIdx.x;r<sp.rows;r+=kThreads) {
            const ExRow& e=rows[r];if(!e.compliant)continue;
            const Bond rb=rowBonds[r];float WNN=0.0f,gN=0.0f;
            for(PxU32 end=0;end<2;++end) {
                const ExNode& n=nodes[end?e.b:e.a];float xq[6]={1,0,0,0,0,0},f[6]={0,0,0,0,0,0},dv[6],e6[6]={0,0,0,0,0,0},g6[6]={0,0,0,0,0,0};
                exWrench(rb,xq,end,f);exApplyInverse(n,f,dv);exRelative(rb,end,dv,e6);WNN+=e6[0];exRelative(rb,end,n.v,g6);gN+=g6[0];
            }
            const float a=fminf(e.face,fmaxf(e.sigma,sqrtf(e.R*fmaxf(gN,0.0f)*s.dt))),k=2.0f*a*e.Estar;
            if(WNN>0.0f && k>0.0f)hRow=fminf(hRow,sqrtf(3.0f*s.explicitAccuracy/(WNN*k)));
        }
        hRow=-blockMax(sh,-hRow);
    }
    __syncthreads();
    if(!threadIdx.x) {
        sp.omega=sqrtf(lambda);
        sp.h=s.explicitDt>0.0f?s.explicitDt:(sp.omega>0.0f?s.explicitSafety*2.0f/sp.omega:s.dt);
        if(sp.compliant && !(s.explicitDt>0.0f))sp.h=fminf(fminf(sp.h,hRow),s.explicitMaxStep);
        sp.h=fminf(sp.h,s.dt);sp.t=0.0f;sp.substeps=0;sp.done=0;
        sp.refreshEvery=sp.refreshTime>0.0f?max(1u,PxU32(sp.refreshTime/sp.h)):0u;
    }
    __syncthreads();
    if(sp.twoBody)exImplicit(sh,s,t,p);
}
// A free patch's rigid mode out of its loads (in dynLoad: p) and velocities: the
// rigid fit (V, Omega) of the velocities and (a, alpha) of the loads by its mass and
// inertia about its centre of mass (chunks: scalar inertia).
__device__ void exFreeRigidMode(Shared& sh,const ExScratch& t,PxU32 p)
{
    ExPatch& sp=t.patches[p];ExNode* nodes=t.nodes+size_t(p)*kExNodes;const float4* pos=t.dynPos+size_t(p)*kExNodes;
    float acc[13]={0,0,0,0,0,0,0,0,0,0,0,0,0};   // M, M x, P, F
    for(PxU32 k=threadIdx.x;k<sp.chunks;k+=kThreads) {
        const ExNode& n=nodes[k];if(n.tensor || n.pad[1] || !(n.im>0.0f))continue;
        const float m=1.0f/n.im;const float4 x=pos[k];const float* f=t.dynLoad+(size_t(p)*kExNodes+k)*6;
        acc[0]+=m;acc[1]+=m*x.x;acc[2]+=m*x.y;acc[3]+=m*x.z;for(int q=0;q<3;++q){acc[4+q]+=m*n.v[q];acc[7+q]+=f[q];}
    }
    for(int q=0;q<10;++q)acc[q]=blockSum(sh,acc[q]);
    if(!(acc[0]>0.0f))return;
    const float M=acc[0],X[3]={acc[1]/M,acc[2]/M,acc[3]/M},V[3]={acc[4]/M,acc[5]/M,acc[6]/M},A[3]={acc[7]/M,acc[8]/M,acc[9]/M};
    float red[15]={0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};   // I (6: xx yy zz xy xz yz), L, torque
    for(PxU32 k=threadIdx.x;k<sp.chunks;k+=kThreads) {
        const ExNode& n=nodes[k];if(n.tensor || n.pad[1] || !(n.im>0.0f))continue;
        const float m=1.0f/n.im,Ii=n.Iinv[0]>0.0f?1.0f/n.Iinv[0]:0.0f;const float4 x=pos[k];const float r[3]={x.x-X[0],x.y-X[1],x.z-X[2]};
        const float* f=t.dynLoad+(size_t(p)*kExNodes+k)*6;const float rr=r[0]*r[0]+r[1]*r[1]+r[2]*r[2];
        red[0]+=Ii+m*(rr-r[0]*r[0]);red[1]+=Ii+m*(rr-r[1]*r[1]);red[2]+=Ii+m*(rr-r[2]*r[2]);red[3]-=m*r[0]*r[1];red[4]-=m*r[0]*r[2];red[5]-=m*r[1]*r[2];
        float mv[3];for(int q=0;q<3;++q)mv[q]=m*n.v[q];float c[3];cross3(r,mv,c);for(int q=0;q<3;++q)red[6+q]+=c[q]+Ii*n.v[3+q];
        cross3(r,f,c);for(int q=0;q<3;++q)red[9+q]+=c[q]+f[3+q];
    }
    for(int q=0;q<12;++q)red[q]=blockSum(sh,red[q]);
    // I^-1 (symmetric 3 x 3, by its adjugate)
    const float a=red[0],b=red[1],c=red[2],d=red[3],e=red[4],f=red[5];
    const float A0=b*c-f*f,B0=a*c-e*e,C0=a*b-d*d,D0=e*f-d*c,E0=d*f-b*e,F0=d*e-a*f,det=a*A0+d*D0+e*E0;
    float Ii[9]={0,0,0,0,0,0,0,0,0};
    if(det>0.0f && isfinite(det)){const float id=1.0f/det;Ii[0]=A0*id;Ii[4]=B0*id;Ii[8]=C0*id;Ii[1]=Ii[3]=D0*id;Ii[2]=Ii[6]=E0*id;Ii[5]=Ii[7]=F0*id;}
    float W[3],Al[3];for(int i=0;i<3;++i){W[i]=Ii[3*i]*red[6]+Ii[3*i+1]*red[7]+Ii[3*i+2]*red[8];Al[i]=Ii[3*i]*red[9]+Ii[3*i+1]*red[10]+Ii[3*i+2]*red[11];}
    for(PxU32 k=threadIdx.x;k<sp.chunks;k+=kThreads) {
        ExNode& n=nodes[k];if(n.tensor || n.pad[1] || !(n.im>0.0f))continue;
        const float m=1.0f/n.im,Ik=n.Iinv[0]>0.0f?1.0f/n.Iinv[0]:0.0f;const float4 x=pos[k];const float r[3]={x.x-X[0],x.y-X[1],x.z-X[2]};
        float* fl=t.dynLoad+(size_t(p)*kExNodes+k)*6;float wr_[3],ar[3];cross3(W,r,wr_);cross3(Al,r,ar);
        for(int q=0;q<3;++q){n.v[q]-=V[q]+wr_[q];n.v[3+q]-=W[q];fl[q]-=m*(A[q]+ar[q]);fl[3+q]-=Ik*Al[q];}
    }
    __syncthreads();
}
// 3b. A dynamic patch's load paths at the window's end: a node is supported when live
// joints and closed contacts join it to a support or a held node. An open contact with an
// end that is not has nothing it bears on (a piece hanging on lifted contacts, falling):
// it breaks, so the piece splits off as a rigid body (the re-bearing law's "fell free",
// PxgDestructionRebearing.cuh), and its window momentum goes with it.
__global__ __launch_bounds__(kThreads) void exSequenceSplit(Settings s,ExScratch t)
{
    __shared__ PxU32 changed;
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    ExPatch& sp=t.patches[p];if(!sp.sequence || !sp.anchored || !t.dynMark)return;
    ExLink* links=t.links+size_t(p)*kExLinks;PxU32* mark=t.dynMark+size_t(p)*kExNodes;float4* jp=t.jp+size_t(p)*kExLinks*kExJoint;
    for(PxU32 k=threadIdx.x;k<sp.nodes;k+=kThreads)mark[k]=0u;
    __syncthreads();
    auto bears=[](PxU32 st){return (st&eEX_LIVE) && !((st&eEX_CONTACT) && (st&eEX_OPEN));};
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads){const ExLink& e=links[l];if(!bears(e.state))continue;
        if(e.a==0xffffffffu && e.b!=0xffffffffu)mark[e.b]=1u;if(e.b==0xffffffffu && e.a!=0xffffffffu)mark[e.a]=1u;}
    for(PxU32 it=0;it<4096;++it) {
        __syncthreads();if(!threadIdx.x)changed=0u;__syncthreads();
        for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
            const ExLink& e=links[l];if(!bears(e.state) || e.a==0xffffffffu || e.b==0xffffffffu)continue;
            const PxU32 ma=mark[e.a],mb=mark[e.b];if(ma!=mb){mark[e.a]=1u;mark[e.b]=1u;changed=1u;}
        }
        __syncthreads();if(!changed)break;
    }
    PxU32 fell=0;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
        ExLink& e=links[l];if(!(e.state&eEX_LIVE) || !(e.state&eEX_CONTACT) || !(e.state&eEX_OPEN))continue;
        const bool a=e.a==0xffffffffu || mark[e.a],b=e.b==0xffffffffu || mark[e.b];if(a && b)continue;
        e.state=(e.state&~eEX_LIVE)|eEX_BROKEN;e.brokeAt=s.dt;for(int q=0;q<6;++q)e.J[q]=0.0f;
        float4* q4=jp+size_t(kExJoint)*l;q4[9]=make_float4(0,0,0,0);q4[10]=make_float4(0,0,__uint_as_float(e.state),e.slip);
        ++fell;
    }
    if(fell){atomicAdd(&sp.fellFree,fell);atomicAdd(&sp.broken,fell);atomicAdd(&sp.events,fell);sp.lastActive=s.dt;}
}
// A dynamic patch after exFinish: each node's residual p + B J0 (exFinish left f0 =
// -B J0; f0 becomes the load p, the books' external force), its kinetic energy, and
// each joint's split inverse mass per component, W_q = sum over its ends of (B_q^T
// M^-1 B_q) times that end's live joints (Jacobi: the joints sharing a node cannot
// together overshoot it; Tonge et al. 2012), for its implicit dashpot. A test fills
// dynLoad with p and damp[6] with each joint's zeta before exFinishKernel, as exBuild does.
__device__ void exFinishDynamic(Shared& sh,const Settings& s,const ExScratch& t,PxU32 p)
{
    ExPatch& sp=t.patches[p];
    ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;const ExLink* links=t.links+size_t(p)*kExLinks;
    float ke=0.0f,zmax=0.0f;
    // Anchored: a live joint holds it to a support or to a node off the patch (held). A free
    // patch (debris, a piece that split off) is a rigid body PhysX moves: the window takes only
    // its internal motion -- its loads less the rigid acceleration they give it, its velocities
    // less its rigid motion (linear and angular momentum about its centre of mass) -- so it
    // conserves the body's momentum exactly and never integrates its fall a second time.
    PxU32 held=0;
    PxU32 bearing=0,loose=0;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads){const ExLink& e=links[l];if((e.state&eEX_LIVE) && !(e.state&eEX_CAR) && (e.a==0xffffffffu || e.b==0xffffffffu))held=1u;
        if((e.state&eEX_LIVE) && (e.state&eEX_BEARING))++bearing;}
    {const PxU32* adj=t.adj+size_t(p)*2*kExLinks;
     for(PxU32 k=threadIdx.x;k<sp.chunks;k+=kThreads){const ExNode& n=nodes[k];if(n.tensor || n.pad[1])continue;PxU32 live=0;
        for(PxU32 j=n.jointBegin;j<n.jointEnd;++j)live+=(links[adj[j]>>1].state&eEX_LIVE)?1u:0u;if(!live)++loose;}}
    held=blockCount(sh,held);bearing=blockCount(sh,bearing);loose=blockCount(sh,loose);
    if(!threadIdx.x){sp.bearingJoints=bearing;sp.looseNodes=loose;}
    if(!held && t.dynPos)exFreeRigidMode(sh,t,p);
    for(PxU32 k=threadIdx.x;k<sp.nodes;k+=kThreads) {
        ExNode& n=nodes[k];float* f=t.dynLoad+(size_t(p)*kExNodes+k)*6;
        if(n.tensor || n.pad[1]){for(int q=0;q<6;++q)f[q]=0.0f;continue;}   // impactors and a car's chunks: no residual
        for(int q=0;q<6;++q){const float load=f[q];f[q]=load-n.f0[q];n.f0[q]=load;}
        const float m=n.im>0.0f?1.0f/n.im:0.0f,I=n.Iinv[0]>0.0f?1.0f/n.Iinv[0]:0.0f;
        ke+=0.5f*(m*(n.v[0]*n.v[0]+n.v[1]*n.v[1]+n.v[2]*n.v[2])+I*(n.v[3]*n.v[3]+n.v[4]*n.v[4]+n.v[5]*n.v[5]));
    }
    const PxU32* adj=t.adj+size_t(p)*2*kExLinks;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
        const ExLink& e=links[l];float* c=t.damp+(size_t(p)*kExLinks+l)*8;
        if(!(e.state&eEX_LIVE) || (e.state&eEX_CAR)){for(int q=0;q<8;++q)c[q]=0.0f;continue;}
        const float zeta=fmaxf(c[6],0.0f);const Bond& b=bonds[l];float W[6]={0,0,0,0,0,0};
        for(PxU32 end=0;end<2;++end) {
            const PxU32 node=end?e.b:e.a;if(node==0xffffffffu)continue;const ExNode& n=nodes[node];
            PxU32 deg=0;for(PxU32 j=n.jointBegin;j<n.jointEnd;++j)deg+=(links[adj[j]>>1].state&eEX_LIVE)?1u:0u;
            for(int q=0;q<6;++q){float xq[6]={0,0,0,0,0,0};xq[q]=1.0f;float f[6]={0,0,0,0,0,0},dv[6],e6[6]={0,0,0,0,0,0};
                exWrench(b,xq,end,f);exApplyInverse(n,f,dv);exRelative(b,end,dv,e6);W[q]+=e6[q]*float(max(deg,1u));}
        }
        for(int q=0;q<6;++q)c[q]=fmaxf(W[q],0.0f);
        zmax=fmaxf(zmax,zeta);
    }
    for(PxU32 i=threadIdx.x;i<12*sp.links;i+=kThreads)t.wk[size_t(p)*kExLinks*12+i]=0.0f;
    ke=blockSum(sh,ke);zmax=blockMax(sh,zmax);
    if(!threadIdx.x) {
        sp.zeta=zmax;sp.keStart=sp.keEnd=ke;sp.anchored=held?1u:0u;sp.fellFree=0u;sp.strainEnd=sp.u0;sp.extWork=sp.slipWork=sp.dashWork=0.0f;sp.lastEvent=-1.0f;
        sp.events=sp.converted=sp.seatLost=sp.crushedContacts=sp.contacts=0;sp.lastActive=-1.0f;sp.period=0.0f;sp.freeze=0u;sp.beta=0.0f;
    }
    __syncthreads();
}
__global__ __launch_bounds__(kThreads) void exFinishKernel(Settings s,ExScratch t)
{
    __shared__ Shared sh;if(blockIdx.x<*t.patchCount){exFinish(sh,s,t,blockIdx.x);if(t.patches[blockIdx.x].sequence)exFinishDynamic(sh,s,t,blockIdx.x);}
}

// 3. The window, resumable: at most `budget` substeps per patch per launch.
// The window is latency-bound (a phase costs about the same at 256, 512 and
// 1024 threads; on the cannonball's patch each of the node, contact and joint
// phases took about 4 us a substep with its node and row data in device
// memory): so what a phase reads from device memory is what it costs.
// - The nodes' velocities live in threadgroup memory; for a patch of at most
//   kExSmall nodes (Small) so do their inverse masses and their joint and row
//   ranges.
// - Each joint keeps the wrench of its force change on its two ends, B (J -
//   J0) (t.wr), so a node gathers six floats a joint and never reads a joint's
//   geometry; each row likewise (t.rwr).
// - Each row is its thread's: its ends in registers, W, W^-1 and its running
//   impulse read from device memory (in registers they cost more: fewer live
//   registers across the loop measured 8% faster on the whole window).
// - The dead load's work is the joints' (f0 . v = -sum J0 . B^T v), counted
//   where the joint phase already has B^T v.
__device__ __forceinline__ void exPack(const Bond& b,const ExLink& e,float4* q)
{
    q[0]=make_float4(b.n[0],b.n[1],b.n[2],b.t1[0]);q[1]=make_float4(b.t1[1],b.t1[2],b.t2[0],b.t2[1]);
    q[2]=make_float4(b.t2[2],b.o0[0],b.o0[1],b.o0[2]);q[3]=make_float4(b.o1[0],b.o1[1],b.o1[2],b.kl);
    q[4]=make_float4(b.kt,b.k0,b.k1,b.capC);q[5]=make_float4(b.capT,b.capS,b.gb,b.gt);q[6]=make_float4(b.g0,b.g1,b.h0,b.h1);
    q[7]=make_float4(e.J0[0],e.J0[1],e.J0[2],e.J0[3]);q[8]=make_float4(e.J0[4],e.J0[5],__uint_as_float(e.a),__uint_as_float(e.b));
    q[9]=make_float4(e.J[0],e.J[1],e.J[2],e.J[3]);q[10]=make_float4(e.J[4],e.J[5],__uint_as_float(e.state),e.slip);
    q[11]=make_float4(b.mu,b.capSx,0.0f,0.0f);
}
// A Mohr-Coulomb joint's friction (eEX_FRICTION) into its unpacked Bond:
// every grader of a packed joint calls this after reading its state.
__device__ __forceinline__ void exUnpackFriction(const float4* q,PxU32 state,Bond& b)
{
    if(state&eEX_FRICTION){const float4 f=q[11];b.mu=f.x;b.capSx=f.y;}
}
// The packed constants back into a Bond's fields the window reads (the rest unset).
__device__ __forceinline__ void exUnpack(const float4* q,Bond& b,float* J0,PxU32& a,PxU32& e1)
{
    const float4 q0=q[0],q1=q[1],q2=q[2],q3=q[3],q4=q[4],q5=q[5],q6=q[6],q7=q[7],q8=q[8];
    b.n[0]=q0.x;b.n[1]=q0.y;b.n[2]=q0.z;b.t1[0]=q0.w;b.t1[1]=q1.x;b.t1[2]=q1.y;b.t2[0]=q1.z;b.t2[1]=q1.w;
    b.t2[2]=q2.x;b.o0[0]=q2.y;b.o0[1]=q2.z;b.o0[2]=q2.w;b.o1[0]=q3.x;b.o1[1]=q3.y;b.o1[2]=q3.z;b.kl=q3.w;
    b.kt=q4.x;b.k0=q4.y;b.k1=q4.z;b.capC=q4.w;b.capT=q5.x;b.capS=q5.y;b.gb=q5.z;b.gt=q5.w;b.g0=q6.x;b.g1=q6.y;b.h0=q6.z;b.h1=q6.w;
    J0[0]=q7.x;J0[1]=q7.y;J0[2]=q7.z;J0[3]=q7.w;J0[4]=q8.x;J0[5]=q8.y;a=__float_as_uint(q8.z);e1=__float_as_uint(q8.w);
    b.mu=0.0f;b.capSx=0.0f;   // exUnpackFriction, with the joint's state
}
// A compliant row's impulse over h (exBuild's law): its normal force at the
// substep's end (backward Euler, g+ = g_N + W_NN P_N the closing rate after it):
// P_N = min(0, -h (F(d) + k h g_N) / (1 + k h^2 W_NN)); the
// tangential impulse that stops the slip, at most mu |P_N|. g the row's relative
// motion (g_N > 0 closing), W its (split) 3 x 3 inverse mass, d its depth.
// The force is the integral of the tangent stiffness k(s) = 2 E* a(s), a(s) = min(face,
// max(sigma, sqrt(R s))): a flat patch of radius sigma (F = 2 sigma E* d, Johnson 3.8), past
// d1 = sigma^2 / R Hertz's contact of the curvature R (F = 4/3 E* sqrt(R) d^(3/2), Johnson 4.2),
// past d2 = face^2 / R the face's punch; at the substep's end F(d) + k(d) h g+ (linearised at d).
// (vibe-land scripts/impact/contact_law.py row_force, compliant_impulse; hertz_check.)
__device__ __forceinline__ float exRowForce(float d,float Estar,float sigma,float R,float face)
{
    d=fmaxf(d,0.0f);const float sg=fminf(sigma,face);
    const float d1=R>0.0f?sg*sg/R:FLT_MAX,d2=R>0.0f?face*face/R:FLT_MAX;
    if(d<=d1)return 2.0f*Estar*sg*d;
    const float F1=2.0f*Estar*sg*d1,c=4.0f/3.0f*Estar*sqrtf(R);
    if(d<=d2)return F1+c*(d*sqrtf(d)-d1*sqrtf(d1));
    return F1+c*(d2*sqrtf(d2)-d1*sqrtf(d1))+2.0f*Estar*face*(d-d2);
}
__device__ __forceinline__ void exCompliantRow(const float* W,const float* g,float d,float Estar,float sigma,float R,float face,float mu,float h,float* P)
{
    const float a=fminf(face,fmaxf(sigma,sqrtf(R*fmaxf(d,0.0f)))),k=2.0f*a*Estar;
    const float PN=fminf(0.0f,-h*(exRowForce(d,Estar,sigma,R,face)+k*h*g[0])/(1.0f+k*h*h*W[0]));
    const float r1=g[1]+W[3]*PN,r2=g[2]+W[6]*PN,det=W[4]*W[8]-W[5]*W[7];
    float T1=0.0f,T2=0.0f;
    if(det>0.0f){T1=-(W[8]*r1-W[5]*r2)/det;T2=-(-W[7]*r1+W[4]*r2)/det;}
    const float n=sqrtf(T1*T1+T2*T2),lim=mu*-PN;
    if(n>lim){const float sc=n>0.0f?lim/n:0.0f;T1*=sc;T2*=sc;}
    P[0]=PN;P[1]=T1;P[2]=T2;
}
// A compliant row with its struck side's crush (Settings::compliant; vibe-land
// scripts/impact/contact_law.py compliant_impulse(crush=)). Crushing, the row is a flat
// punch of the crater's radius, a^2 = 2 R d at the whole intrusion d (a plastic
// indentation's truncated cap, Johnson 1985 sec. 6.3), at most the face; d - dp is its
// elastic depth. Its normal force reaching the onset over pi a^2 starts the crush
// (sticky); crushing, it is at most the plateau over pi a^2, the tangential impulse
// then the one that stops the slip under it, within mu of it. Returns the force
// applied (N) and the radius it acted on (m) for the crushed depth's update.
__device__ __forceinline__ void exCrushRow(const float* W,const float* g,ExRow& x,float mu,float h,float* P)
{
    const bool crushing=(x.crush&1u)!=0u;
    const float de=x.d-x.dp;
    const float sg=crushing?fmaxf(x.sigma,fminf(x.face,sqrtf(2.0f*x.R*fmaxf(x.d,0.0f)))):x.sigma;
    exCompliantRow(W,g,de,x.Estar,sg,x.R,x.face,mu,h,P);
    const float a=fminf(x.face,fmaxf(sg,sqrtf(x.R*fmaxf(de,0.0f)))),A=3.14159265f*a*a,F=-P[0]/h;
    if(!crushing && A>0.0f && F>=x.on*A)x.crush|=1u;
    if((x.crush&1u) && F>x.pl*A) {
        P[0]=-x.pl*A*h;
        const float r1=g[1]+W[3]*P[0],r2=g[2]+W[6]*P[0],det=W[4]*W[8]-W[5]*W[7];
        float T1=0.0f,T2=0.0f;if(det>0.0f){T1=-(W[8]*r1-W[5]*r2)/det;T2=-(-W[7]*r1+W[4]*r2)/det;}
        const float n=sqrtf(T1*T1+T2*T2),lim=mu*-P[0];if(n>lim){const float sc=n>0.0f?lim/n:0.0f;T1*=sc;T2*=sc;}
        P[1]=T1;P[2]=T2;
    }
    x.Fa=-P[0]/h;x.ac=a;
}
// An implicit joint's sweep (exImplicit made it so): from its ends' velocities v
// now and at the substep's start (eStart), dJ = -A (B^T v / 2 + B^T v0 / 2) (the
// trapezoidal rule on the joint's own split nodes), then the law (fracture, or the
// radial return of a ductile joint); its force change's wrench into wr (the next
// substep's gather) and its increment's into wd (this sweep's, exImplicitNodeB).
// A broken one writes a zero increment.
// An implicit joint's relative motion B^T v (its six rates) into eStart: at the
// window's start, and after each substep's sweeps (v is then the next substep's start).
__device__ __forceinline__ void exImplicitStart(PxU32 l,const float4* jp,const float* v,float4* eStart)
{
    const float4* q=jp+size_t(kExJoint)*l;const PxU32 state=__float_as_uint(q[10].z);
    if(!(state&eEX_IMPLICIT) || !(state&eEX_LIVE))return;
    Bond b;float J0[6];PxU32 ea,eb;exUnpack(q,b,J0,ea,eb);
    float d[6]={0,0,0,0,0,0};if(ea!=0xffffffffu)exRelative(b,0,v+6*ea,d);if(eb!=0xffffffffu)exRelative(b,1,v+6*eb,d);
    eStart[2*size_t(l)]=make_float4(d[0],d[1],d[2],d[3]);eStart[2*size_t(l)+1]=make_float4(d[4],d[5],0.0f,0.0f);
}
__device__ void exImplicitJointA(PxU32 l,const float4* ja,float4* jp,ExLink* links,float* wr,float* wd,const float* v,const float4* eStart,
    float h,float time,float band,PxU32* cBroken,PxU32* cYielded,float* cFracture,float* cPlastic,float& dead)
{
    float4* q=jp+size_t(kExJoint)*l;
    const float4 s1=q[10];PxU32 state=__float_as_uint(s1.z);
    if(!(state&eEX_IMPLICIT))return;
    float* od=wd+12*size_t(l);
    if(!(state&eEX_LIVE)){float4* o4=reinterpret_cast<float4*>(od);o4[0]=o4[1]=o4[2]=make_float4(0.0f,0.0f,0.0f,0.0f);return;}
    Bond b;float J0[6];PxU32 ea,eb;exUnpack(q,b,J0,ea,eb);
    const float4 s0=q[9];float slip=s1.w;
    float d[6]={0,0,0,0,0,0};
    if(ea!=0xffffffffu)exRelative(b,0,v+6*ea,d);
    if(eb!=0xffffffffu)exRelative(b,1,v+6*eb,d);
    const float4 e0=eStart[2*size_t(l)],e1=eStart[2*size_t(l)+1];const float d0[6]={e0.x,e0.y,e0.z,e0.w,e1.x,e1.y};
    for(int i=0;i<6;++i)dead-=0.5f*h*J0[i]*d[i];   // (half of the dead load's work: two sweeps)
    float e[6];for(int i=0;i<6;++i)e[i]=0.5f*d[i]+0.5f*d0[i];
    // (A in vector loads: nine float4s, row-major)
    float A[36];{const float4* q4=ja+size_t(9)*l;for(int i=0;i<9;++i){const float4 a=q4[i];A[4*i]=a.x;A[4*i+1]=a.y;A[4*i+2]=a.z;A[4*i+3]=a.w;}}
    const float Jold[6]={s0.x,s0.y,s0.z,s0.w,s1.x,s1.y};
    float J[6];for(int i=0;i<6;++i){float a=0.0f;for(int j=0;j<6;++j)a+=A[6*i+j]*e[j];J[i]=Jold[i]-a;}
    float k[6];exStiffness(b,k);
    const float u=utilisation(b,J);
    bool breaks=false;
    if(!(state&eEX_DUCTILE))breaks=u>=1.0f-band;
    else if(u>1.0f) {
        float sl=0.0f,work=0.0f;
        for(int i=0;i<6;++i){const float y=J[i]/u;if(k[i]>0.0f){const float dp=(J[i]-y)/k[i];if(i<3)sl+=dp*dp;work+=fabsf(y*dp);}J[i]=y;}
        slip+=sqrtf(sl);atomicAdd(cPlastic,work);
        if(!(state&eEX_YIELDED)){state|=eEX_YIELDED;atomicAdd(cYielded,1u);}
        breaks=slip>links[l].limit;
    }
    if(breaks){float u2=0.0f;for(int i=0;i<6;++i)if(k[i]>0.0f)u2+=0.5f*J[i]*J[i]/k[i];atomicAdd(cFracture,u2);
        state=(state&~eEX_LIVE)|eEX_BROKEN;for(int i=0;i<6;++i)J[i]=0.0f;links[l].brokeAt=time;atomicAdd(cBroken,1u);}
    q[9]=make_float4(J[0],J[1],J[2],J[3]);q[10]=make_float4(J[4],J[5],__uint_as_float(state),slip);
    float dJ[6],inc[6];for(int i=0;i<6;++i){dJ[i]=J[i]-J0[i];inc[i]=J[i]-Jold[i];}
    float f0[6]={0,0,0,0,0,0},f1[6]={0,0,0,0,0,0};exWrench(b,dJ,0,f0);exWrench(b,dJ,1,f1);
    float4* o=reinterpret_cast<float4*>(wr+12*size_t(l));
    o[0]=make_float4(f0[0],f0[1],f0[2],f0[3]);o[1]=make_float4(f0[4],f0[5],f1[0],f1[1]);o[2]=make_float4(f1[2],f1[3],f1[4],f1[5]);
    float g0[6]={0,0,0,0,0,0},g1[6]={0,0,0,0,0,0};exWrench(b,inc,0,g0);exWrench(b,inc,1,g1);
    float4* o4=reinterpret_cast<float4*>(od);
    o4[0]=make_float4(g0[0],g0[1],g0[2],g0[3]);o4[1]=make_float4(g0[4],g0[5],g1[0],g1[1]);o4[2]=make_float4(g1[2],g1[3],g1[4],g1[5]);
}
// This row's packed record for the window (exRunT): W = B_c^T M^-1 B_c over its three
// force components, each node's inverse mass times its row count (Jacobi: mass
// splitting, Tonge et al. 2012; rows sharing a node then cannot together overshoot
// it), W^-1, its frame and arms. At each launch's start, and after the window's own
// geometry re-finds the row (exRefreshRow).
__device__ void exPackRow(const Bond& rb,ExRow& x,const ExNode* nodes,float4* q)
{
    float W[9]={0,0,0,0,0,0,0,0,0};
    for(PxU32 end=0;end<2;++end) {
        const ExNode& n=nodes[end?x.b:x.a];float col[3][6];
        const float split=float(max(n.rowEnd-n.rowBegin,1u));
        for(int c=0;c<3;++c){float xq[6]={0,0,0,0,0,0};xq[c]=1.0f;float f[6]={0,0,0,0,0,0};exWrench(rb,xq,end,f);exApplyInverse(n,f,col[c]);for(int k=0;k<6;++k)col[c][k]*=split;}
        for(int i=0;i<3;++i)for(int c=0;c<3;++c){float e6[6]={0,0,0,0,0,0};exRelative(rb,end,col[c],e6);W[3*i+c]+=e6[i];}
    }
    const float det=W[0]*(W[4]*W[8]-W[5]*W[7])-W[1]*(W[3]*W[8]-W[5]*W[6])+W[2]*(W[3]*W[7]-W[4]*W[6]);
    const float id=(det>0.0f && isfinite(det))?1.0f/det:0.0f;
    const float inv[9]={(W[4]*W[8]-W[5]*W[7])*id,(W[2]*W[7]-W[1]*W[8])*id,(W[1]*W[5]-W[2]*W[4])*id,
        (W[5]*W[6]-W[3]*W[8])*id,(W[0]*W[8]-W[2]*W[6])*id,(W[2]*W[3]-W[0]*W[5])*id,
        (W[3]*W[7]-W[4]*W[6])*id,(W[1]*W[6]-W[0]*W[7])*id,(W[0]*W[4]-W[1]*W[3])*id};
    for(int i=0;i<9;++i){x.Winv[i]=inv[i];x.W[i]=W[i];}
    q[0]=make_float4(rb.n[0],rb.n[1],rb.n[2],rb.t1[0]);q[1]=make_float4(rb.t1[1],rb.t1[2],rb.t2[0],rb.t2[1]);
    q[2]=make_float4(rb.t2[2],rb.o0[0],rb.o0[1],rb.o0[2]);q[3]=make_float4(rb.o1[0],rb.o1[1],rb.o1[2],rb.area);
    q[4]=make_float4(W[0],W[1],W[2],W[3]);q[5]=make_float4(W[4],W[5],W[6],W[7]);q[6]=make_float4(W[8],inv[0],inv[1],inv[2]);
    q[7]=make_float4(inv[3],inv[4],inv[5],inv[6]);q[8]=make_float4(inv[7],inv[8],0.0f,0.0f);
}
// The dynamic sequence's joint laws (exRunT's joint pass on a dynamic patch).
// A re-bearing contact (PxgDestructionRebearing.cuh's law, graded as the stage
// grades it): from its trial force J (bond frame, x[0] the normal force, + in
// tension) the force F it transmits --
//   - open (N >= 0): nothing, it has lifted;
//   - shear V + gt |T| (the stage's shear measure) by friction, at most mu C:
//     past it the contact slips, permanently (J's shear follows the cap; the
//     radial return's plastic part is the slip, along t1 and t2 in cs, and its
//     work at the capped force in slipWork);
//   - rocking: where its fastenings' tension line h0 |M0| + h1 |M1| - C passes
//     zero the compression resultant has reached the patch's edge and the contact
//     turns about it: the moments are capped there (F only; J keeps the rotation,
//     which is geometry, not slip).
// It breaks (returns 1) when its compression on F, bend + C, reaches the bearing
// capacity (crushing), and (2) when it has slid off its seat: the bearing patch is
// the faces' overlap, of half-widths d1 = 1/h1 along t1 and d0 = 1/h0 along t2
// (the reaches the rocking line uses: d0 is the reach for a moment about t1), and
// two such rectangles translated by the slip s overlap iff |s.t1| < 2 d1 and |s.t2|
// < 2 d0: the overlap the authored interface guarantees is gone at a slip of the
// patch's full width (a face wider than the interface would hold longer).
// Bit 16 of the result: activity (it slipped, or opened or closed: eEX_OPEN follows it).
__device__ __forceinline__ PxU32 exContactJoint(const Bond& b,const float* k,float* J,float* F,float* cs,float mu,float band,float& slipWork,PxU32& state)
{
    const bool open=!(J[0]<0.0f);PxU32 act=(open!=((state&eEX_OPEN)!=0u))?16u:0u;
    state=open?(state|eEX_OPEN):(state&~eEX_OPEN);
    if(open) {
        // A lost contact keeps no tangential or rocking state: on closing again it starts
        // anew (Cundall & Strack 1979, the shear spring reset when contact is lost); its
        // normal state is the gap.
        for(int q=0;q<6;++q)F[q]=0.0f;for(int q=1;q<6;++q)J[q]=0.0f;
    }
    else {
        const float C=-J[0],V=sqrtf(J[1]*J[1]+J[2]*J[2]),T=fabsf(J[3]),shear=V+b.gt*T;
        if(shear>mu*C) {act=16u;
            const float sc=mu*C/shear;
            const float s1=k[0]>0.0f?(1.0f-sc)*J[1]/k[0]:0.0f,s2=k[0]>0.0f?(1.0f-sc)*J[2]/k[0]:0.0f;
            cs[0]+=s1;cs[1]+=s2;
            slipWork+=sc*V*sqrtf(s1*s1+s2*s2)+(k[3]>0.0f?sc*T*(1.0f-sc)*T/k[3]:0.0f);
            J[1]*=sc;J[2]*=sc;J[3]*=sc;
        }
        // Rocking past the cap: the moment follows the cap and the rotation past it is
        // plastic, as the slip is (the elastic-plastic rolling resistance, Ai, Chen,
        // Rotter & Ooi 2011, Powder Technol. 206: |M| <= M_max on the incremental spring):
        // its work at the capped moment is dissipated. (A state kept past the cap is not
        // energy-consistent: the cap moves with C, and a rotation stored under a small C
        // would be released under a larger one.)
        const float rock=b.h0*fabsf(J[4])+b.h1*fabsf(J[5]);
        if(rock>C) {act=16u;
            const float bsc=C/rock;
            for(int q=4;q<6;++q){const float y=bsc*J[q];if(k[q]>0.0f)slipWork+=fabsf(y*(J[q]-y))/k[q];J[q]=y;}
        }
        F[0]=J[0];F[1]=J[1];F[2]=J[2];F[3]=J[3];F[4]=J[4];F[5]=J[5];
        const float bend=b.g0>0.0f?b.g0*fabsf(F[4])+b.g1*fabsf(F[5]):b.gb*sqrtf(F[4]*F[4]+F[5]*F[5]);
        if(bend+C>=(1.0f-band)*b.capC)return 1u|act;
    }
    if((b.h1>0.0f && fabsf(cs[0])*b.h1>=2.0f) || (b.h0>0.0f && fabsf(cs[1])*b.h0>=2.0f))return 2u|act;
    return act;
}
// A dynamic patch's joint after its trial J: a bond carries J and its damping, F = J
// - c d / (1 + h c W) (d its relative velocity), graded on J at capacity within the band; a
// bearing joint that reaches it with its compression below the bearing capacity has
// lost its fastenings, not its seat: it becomes a contact (bit 2 of the result) and
// takes the contact law at once. A contact that crushes or slides off breaks.
// Returns its events: 1 broke, 2 fastenings failed to contact, 4 the break crushed
// a contact, 8 a contact slid off its seat; 16 activity (a contact slipped, opened or
// closed). F is what it transmits (0 when broken).
__device__ __forceinline__ PxU32 exDynamicJoint(const Bond& b,const float* k,const float* dw,float beta,const float* d,float* J,float* F,
    PxU32& state,float& slip,float limit,float* cs,float h,float mu,float band,float& fracture,float& plastic,float& slipWork,float& dash)
{
    PxU32 ev=0u;
    if(!(state&eEX_CONTACT)) {
        // Its damping (c = beta zeta k, implicit: F_d = -c d / (1 + h c W)); graded on the spring.
        float work=0.0f;for(int q=0;q<6;++q){const float c=beta*dw[6]*k[q],fd=c*d[q]/(1.0f+h*c*dw[q]);F[q]=J[q]-fd;work+=fd*d[q];}
        dash+=h*work;
        const float u=utilisation(b,J);
        // A ductile joint (not a bearing one: its fastenings' failure is the contact's, below)
        // yields by the radial return (the impact window's) on its spring. Its plastic rotation
        // counts towards its ultimate slip at the patch's half-width (the fastener at the edge
        // moves by theta x that): over ticks a joint yielding in bending alone would otherwise
        // turn without limit, a mechanism that never ruptures.
        if((state&eEX_DUCTILE) && !(state&eEX_BEARING)) {
            if(u>1.0f) {
                float sl=0.0f,w=0.0f;const float lever=0.5f*sqrtf(fmaxf(b.area,0.0f));
                for(int q=0;q<6;++q){const float y=J[q]/u,fd=J[q]-F[q];if(k[q]>0.0f){const float dp=(J[q]-y)/k[q];sl+=q<3?dp*dp:dp*dp*lever*lever;w+=fabsf(y*dp);}J[q]=y;F[q]=y-fd;}
                slip+=sqrtf(sl);plastic+=w;state|=eEX_YIELDED;
                if(slip>limit){float u2=0.0f;for(int q=0;q<6;++q)if(k[q]>0.0f)u2+=0.5f*J[q]*J[q]/k[q];fracture+=u2;
                    state=(state&~eEX_LIVE)|eEX_BROKEN;for(int q=0;q<6;++q)J[q]=F[q]=0.0f;return 1u;}
                return 16u;   // (yielding: activity, not an event)
            }
            return 0u;
        }
        if(!(u>=1.0f-band))return 0u;
        const float bend=b.g0>0.0f?b.g0*fabsf(J[4])+b.g1*fabsf(J[5]):b.gb*sqrtf(J[4]*J[4]+J[5]*J[5]);
        if((state&eEX_BEARING) && bend-J[0]<(1.0f-band)*b.capC){state|=eEX_CONTACT;ev=2u;}
        else {
            float u2=0.0f;for(int q=0;q<6;++q)if(k[q]>0.0f)u2+=0.5f*J[q]*J[q]/k[q];fracture+=u2;
            const PxU32 bearingBroke=(state&eEX_BEARING)?32u:0u;   // (diagnostics: a bearing joint crushed at its fatal)
            state=(state&~eEX_LIVE)|eEX_BROKEN;for(int q=0;q<6;++q)J[q]=F[q]=0.0f;return 1u|bearingBroke;
        }
    }
    const PxU32 r=exContactJoint(b,k,J,F,cs,mu,band,slipWork,state);
    if(r&3u) {
        float u2=0.0f;for(int q=0;q<6;++q)if(k[q]>0.0f)u2+=0.5f*F[q]*F[q]/k[q];fracture+=u2;
        state=(state&~eEX_LIVE)|eEX_BROKEN;for(int q=0;q<6;++q)J[q]=F[q]=0.0f;
        return ev|1u|((r&1u)?4u:8u)|(r&16u);
    }
    return ev|(r&16u);
}
template<bool Small> __device__ __forceinline__
void exRunT(Settings s,Scratch w,ExScratch t,PxU32 budget)
{
    constexpr PxU32 kV=Small?kExSmall:kExNodes,kN=Small?kExSmall:1u;
    __shared__ PxU32 shBroken,shYielded,shActive,shPushing,shNear,shFree,shAtRows,shImplicit;
    __shared__ float shFracture,shPlastic,shDead;
    // The dynamic sequence's books and events (a dynamic-sequence patch only).
    __shared__ float shSlipWork,shDash,shExt;__shared__ PxU32 shEvents,shConverted,shSeat,shCrushed,shLast,shActive2;
    __shared__ float shNum,shDen,shBeta;__shared__ PxU32 shResample;   // the damping's frequency (dynamic-sequence patches)
    __shared__ float shCrush;
    __shared__ PxU32 shThrough;
    __shared__ float vS[6*kV],imS[kN],iiS[3*kN];
    __shared__ PxU32 jS[kN],rS[kN];
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    ExPatch& sp=t.patches[p];if(sp.done)return;
    if(Small!=(sp.nodes<=kExSmall))return;   // each patch runs in the kernel of its size (the host launches both)
    ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;ExLink* links=t.links+size_t(p)*kExLinks;
    const Bond* rowBonds=t.rowBonds+size_t(p)*kExRows;ExRow* rows=t.rows+size_t(p)*kExRows;
    const PxU32* adj=t.adj+size_t(p)*2*kExLinks;const PxU32* rowAdj=t.rowAdj+size_t(p)*2*kExRows;
    float* wr=t.wr+size_t(p)*kExLinks*12;float* rwr=t.rwr+size_t(p)*kExRows*12;float4* jp=t.jp+size_t(p)*kExLinks*kExJoint;PxU32* jl=t.jl+size_t(p)*kExLinks;float4* rp=t.rp+size_t(p)*kExRows*kExRow;
    const PxU32 nn=sp.nodes,nl=sp.links,nr=sp.rows;const float h=sp.h,T=s.dt;
    const PxU32 total=PxU32(ceilf(T/h-1e-4f));
    if(!threadIdx.x){shBroken=0;shYielded=0;shFracture=0.0f;shPlastic=0.0f;shDead=0.0f;shFree=0;shAtRows=0;shImplicit=0;
        shSlipWork=0.0f;shDash=0.0f;shExt=0.0f;shEvents=0;shConverted=0;shSeat=0;shCrushed=0;shLast=0;shActive2=0;
        shNum=0.0f;shDen=0.0f;shBeta=sp.beta;shResample=0;}
    const bool seqp=sp.sequence!=0u;   // (a dynamic-sequence patch)
    const float* dynLoad=seqp?t.dynLoad+size_t(p)*kExNodes*6:nullptr;
    const float* damp=seqp?t.damp+size_t(p)*kExLinks*8:nullptr;float* cslip=seqp?t.cslip+size_t(p)*kExLinks*2:nullptr;
    float* wk=seqp?t.wk+size_t(p)*kExLinks*12:nullptr;
    const float mu=s.dynamicFriction;
    if(!threadIdx.x){shCrush=0.0f;shThrough=0;}
    for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
        const ExNode& n=nodes[k];for(int q=0;q<6;++q)vS[6*k+q]=n.v[q];
        if(Small){imS[k]=n.im;for(int q=0;q<3;++q)iiS[3*k+q]=n.tensor?-1.0f:n.Iinv[q];jS[k]=n.jointBegin|(n.jointEnd<<16);rS[k]=n.rowBegin|(n.rowEnd<<16);}
    }
    auto jointRange=[&](PxU32 k,PxU32& b0,PxU32& b1){if(Small){b0=jS[k]&0xffffu;b1=jS[k]>>16;}else{b0=nodes[k].jointBegin;b1=nodes[k].jointEnd;}};
    auto rowRange=[&](PxU32 k,PxU32& b0,PxU32& b1){if(Small){b0=rS[k]&0xffffu;b1=rS[k]>>16;}else{b0=nodes[k].rowBegin;b1=nodes[k].rowEnd;}};
    // A node's velocity change from a wrench f, times scale.
    auto apply=[&](PxU32 k,const float* f,float scale){
        // A chunk's inverse inertia is diagonal in the joint frame (Iinv[0..2]); an impactor's a tensor.
        float im,ii[3];if(Small){im=imS[k];for(int q=0;q<3;++q)ii[q]=iiS[3*k+q];}else{const ExNode& n=nodes[k];im=n.im;for(int q=0;q<3;++q)ii[q]=n.tensor?-1.0f:n.Iinv[q];}
        for(int q=0;q<3;++q)vS[6*k+q]+=scale*im*f[q];
        if(ii[0]>=0.0f){for(int q=0;q<3;++q)vS[6*k+3+q]+=scale*ii[q]*f[3+q];}
        else{float a3[3];symMul(nodes[k].Iinv,f+3,a3);for(int q=0;q<3;++q)vS[6*k+3+q]+=scale*a3[q];}
    };
    // This thread's row: W = B_c^T M^-1 B_c over its three force components
    // (fixed over the window), each node's inverse mass times its row count
    // (Jacobi: mass splitting, Tonge et al. 2012; rows sharing a node then
    // cannot together overshoot it), W^-1, its ends, its impulse.
    const bool hasRow=threadIdx.x<nr;
    PxU32 ra=0,rn=0;
    if(hasRow){const ExRow& x=rows[threadIdx.x];ra=x.a;rn=x.b;exPackRow(rowBonds[threadIdx.x],rows[threadIdx.x],nodes,rp+size_t(kExRow)*threadIdx.x);}
    __syncthreads();
    PxU32 step=sp.substeps;float dead=0.0f,crush=0.0f;
    float dashLocal=0.0f,slipLocal=0.0f,plasticLocal=0.0f,extLocal=0.0f;   // (the dynamic sequence's books: per thread, summed once)
    float denLocal=0.0f;bool sample=false;   // (the damping's frequency sample: this substep's)
    // A joint's substep: the trial, then fracture or the radial return; the force change's wrench on both ends.
    auto joint=[&](PxU32 l,float time,bool last) {
        float4* q=jp+size_t(kExJoint)*l;
        Bond b;float J0[6];PxU32 ea,eb;exUnpack(q,b,J0,ea,eb);
        const float4 s0=q[9],s1=q[10];PxU32 state=__float_as_uint(s1.z);float slip=s1.w;
        if(!(state&eEX_LIVE) || (state&eEX_IMPLICIT))return;   // broke earlier in this launch; or implicit (exImplicitJointA)
        exUnpackFriction(q,state,b);
        // An end a row crushed through (Settings::compliant): the joint goes with it.
        const bool crushedEnd=(state&eEX_ROWS) && ((ea!=0xffffffffu && nodes[ea].crushed) || (eb!=0xffffffffu && nodes[eb].crushed));
        float d[6]={0,0,0,0,0,0};if(ea!=0xffffffffu)exRelative(b,0,vS+6*ea,d);if(eb!=0xffffffffu)exRelative(b,1,vS+6*eb,d);
        for(int q6=0;q6<6;++q6)dead-=h*J0[q6]*d[q6];
        float k[6];exStiffness(b,k);
        const float Jp[6]={s0.x,s0.y,s0.z,s0.w,s1.x,s1.y};
        float J[6];for(int q6=0;q6<6;++q6)J[q6]=Jp[q6]-h*k[q6]*d[q6];
        if(seqp && !(state&eEX_CAR)) {
            // The dynamic sequence: the joint's own law (exDynamicJoint); its wrench B (F - J0).
            float F[6],fracture=0.0f,plastic=0.0f,slipWork=0.0f,dash=0.0f;
            const PxU32 ev=exDynamicJoint(b,k,damp+8*size_t(l),shBeta,d,J,F,state,slip,links[l].limit,cslip+2*size_t(l),h,exContactMu(b,mu),s.capacityBand,fracture,plastic,slipWork,dash);
            if(sample) {
                // The damping's frequency: this joint's K d on its ends, and d . K d (open contacts and broken joints: none).
                float kd[6];const bool stiff=(state&eEX_LIVE) && !((state&eEX_CONTACT) && (state&eEX_OPEN));
                for(int q6=0;q6<6;++q6){kd[q6]=stiff?k[q6]*d[q6]:0.0f;denLocal+=kd[q6]*d[q6];}
                float g0[6]={0,0,0,0,0,0},g1[6]={0,0,0,0,0,0};exWrench(b,kd,0,g0);exWrench(b,kd,1,g1);
                float* o=wk+12*size_t(l);for(int q6=0;q6<6;++q6){o[q6]=g0[q6];o[6+q6]=g1[q6];}
            }
            if(ev&15u)shResample=1u;
            if((ev&1u) && !sample){float* o=wk+12*size_t(l);for(int q6=0;q6<12;++q6)o[q6]=0.0f;}   // (broken: no stiffness in later samples)
            dashLocal+=dash;slipLocal+=slipWork;plasticLocal+=plastic;
            if(ev)atomicMax(&shActive2,__float_as_uint(time));   // activity: an event, a slip, an opening or closing
            if(ev&15u) {
                atomicAdd(&shEvents,1u);atomicMax(&shLast,__float_as_uint(time));
                if(ev&2u)atomicAdd(&shConverted,1u);
                if(ev&1u){atomicAdd(&shBroken,1u);atomicAdd(&shFracture,fracture);links[l].brokeAt=time;}
                if(ev&4u)atomicAdd(&shCrushed,1u);if(ev&8u)atomicAdd(&shSeat,1u);if(ev&32u)atomicAdd(&shCrushed,1u);
            }
            q[9]=make_float4(J[0],J[1],J[2],J[3]);q[10]=make_float4(J[4],J[5],__uint_as_float(state),slip);
            float dJ[6];for(int q6=0;q6<6;++q6)dJ[q6]=F[q6]-J0[q6];
            float* o=wr+12*size_t(l);float f0[6]={0,0,0,0,0,0},f1[6]={0,0,0,0,0,0};
            exWrench(b,dJ,0,f0);exWrench(b,dJ,1,f1);
            reinterpret_cast<float4*>(o)[0]=make_float4(f0[0],f0[1],f0[2],f0[3]);reinterpret_cast<float4*>(o)[1]=make_float4(f0[4],f0[5],f1[0],f1[1]);reinterpret_cast<float4*>(o)[2]=make_float4(f1[2],f1[3],f1[4],f1[5]);
            return;
        }
        const float u=utilisation(b,J);
        // An event is near: a brittle joint within the band, a ductile one slipping.
        if((state&eEX_DUCTILE)?u>1.0f:u>=1.0f-s.capacityBand){shActive=1u;if(last)atomicAdd(&shNear,1u);}
        bool breaks=crushedEnd;
        if(crushedEnd){}
        else if(!(state&eEX_DUCTILE))breaks=u>=1.0f-s.capacityBand;
        else if(u>1.0f) {
            float sl=0.0f,work=0.0f;
            for(int q6=0;q6<6;++q6){const float y=J[q6]/u;if(k[q6]>0.0f){const float dp=(J[q6]-y)/k[q6];if(q6<3)sl+=dp*dp;work+=fabsf(y*dp);}J[q6]=y;}
            slip+=sqrtf(sl);atomicAdd(&shPlastic,work);
            if(!(state&eEX_YIELDED)){state|=eEX_YIELDED;atomicAdd(&shYielded,1u);}
            breaks=slip>links[l].limit;
        }
        if(breaks){float u2=0.0f;for(int q6=0;q6<6;++q6)if(k[q6]>0.0f)u2+=0.5f*J[q6]*J[q6]/k[q6];atomicAdd(&shFracture,u2);
            state=(state&~eEX_LIVE)|eEX_BROKEN;for(int q6=0;q6<6;++q6)J[q6]=0.0f;links[l].brokeAt=time;atomicAdd(&shBroken,1u);}
        q[9]=make_float4(J[0],J[1],J[2],J[3]);q[10]=make_float4(J[4],J[5],__uint_as_float(state),slip);
        float dJ[6];for(int q6=0;q6<6;++q6)dJ[q6]=J[q6]-J0[q6];
        float* o=wr+12*size_t(l);float f0[6]={0,0,0,0,0,0},f1[6]={0,0,0,0,0,0};
        exWrench(b,dJ,0,f0);exWrench(b,dJ,1,f1);
        reinterpret_cast<float4*>(o)[0]=make_float4(f0[0],f0[1],f0[2],f0[3]);reinterpret_cast<float4*>(o)[1]=make_float4(f0[4],f0[5],f1[0],f1[1]);reinterpret_cast<float4*>(o)[2]=make_float4(f1[2],f1[3],f1[4],f1[5]);
    };
    // Rows run on the first ceil(nr / 32) simdgroups; the joints away from them on the rest at the same time.
    // (a two-body patch: none beside the rows -- the implicit sweeps after them move row nodes)
    const PxU32 rowThreads=min((nr+31u)&~31u,kExThreads),freeStride=sp.twoBody?0u:kExThreads-rowThreads;
    float4* eStart=sp.twoBody?t.eStart+size_t(p)*kExLinks*2:nullptr;const float4* ja=sp.twoBody?t.ja+size_t(p)*kExLinks*9:nullptr;
    float* wd=sp.twoBody?t.wd+size_t(p)*kExLinks*12:nullptr;
    __syncthreads();
    for(PxU32 l=threadIdx.x;l<nl;l+=kExThreads) {
        ExLink& e=links[l];PxU32 b0,b1,c0=0,c1=0;
        if(e.a!=0xffffffffu){rowRange(e.a,b0,b1);c0=b1-b0;}
        if(e.b!=0xffffffffu){rowRange(e.b,b0,b1);c1=b1-b0;}
        e.state=(c0||c1)?(e.state|eEX_ROWS):(e.state&~eEX_ROWS);
        exPack(bonds[l],e,jp+size_t(kExJoint)*l);
        if(wd)for(int q=0;q<12;++q)wd[12*size_t(l)+q]=0.0f;   // (the explicit joints' increments: none)
        // The lists the substeps walk (any order: each joint's substep is its own).
        // (a two-body patch: its implicit joints from the front -- the sweeps walk them --, the rest from the back)
        if(e.state&eEX_LIVE){if(e.state&eEX_IMPLICIT)jl[atomicAdd(&shImplicit,1u)]=l;
            else if((c0||c1) || !freeStride)jl[nl-1u-atomicAdd(&shAtRows,1u)]=l;else jl[atomicAdd(&shFree,1u)]=l;}
    }
    __syncthreads();
    const PxU32 nFree=shFree,nAtRows=shAtRows,nImplicit=shImplicit;
    if(eStart)for(PxU32 i=threadIdx.x;i<nImplicit;i+=kExThreads)exImplicitStart(jl[i],jp,vS,eStart);
    for(PxU32 it=0;it<budget && step<total;++it,++step) {
        const float time=float(step+1)*h;const bool last=step+1==total;
        // The window's end (Settings::explicitWindow 1): once no contact pushes, no
        // brittle joint is within the capacity band and no ductile one slips, no
        // event is under way; what remains (the dead load settling around the
        // damage) is the next tick's static verdict.
        if(!threadIdx.x){shActive=0u;shPushing=0u;shNear=0u;}
        sample=seqp && (step%kExDampSample==0u || shResample);
        // The window's own geometry (Settings::compliant with chunk boxes): every refreshEvery
        // substeps each round impactor's rows are re-found where the bodies now are, and
        // repacked (their frame, arms, W).
        if(sp.refreshEvery && step>0 && step%sp.refreshEvery==0u) {
            if(hasRow && rows[threadIdx.x].geo){Bond* rbw=t.rowBonds+size_t(p)*kExRows;
                exRefreshRow(t.boxes,nodes,rows[threadIdx.x],rbw[threadIdx.x]);exPackRow(rbw[threadIdx.x],rows[threadIdx.x],nodes,rp+size_t(kExRow)*threadIdx.x);}
            __syncthreads();
        }
        // Joint forces on the nodes: each node gathers its joints' wrenches (no atomics).
        if(!(EX_PROF_SKIP&1))for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
            PxU32 b0,b1;jointRange(k,b0,b1);if(b0==b1 && !seqp)continue;
            float f[6]={0,0,0,0,0,0};
            exGather(wr,adj,b0,b1,f);
            // A dynamic-sequence patch: the tick's loads, as the residual p + B J0 (exFinishDynamic), and their work.
            if(seqp){for(int q=0;q<6;++q)f[q]+=dynLoad[6*k+q];}
            apply(k,f,h);
            if(seqp){const ExNode& n=nodes[k];float wk=0.0f;for(int q=0;q<6;++q)wk+=n.f0[q]*vS[6*k+q];extLocal+=h*wk;}
        }
        __syncthreads();
        // The joints with no row at either end (their ends' velocities are final),
        // beside the rows: on the threads past the rows' simdgroups.
        if(!(EX_PROF_SKIP&8) && threadIdx.x>=rowThreads)for(PxU32 i=threadIdx.x-rowThreads;i<nFree;i+=freeStride)joint(jl[i],time,last);
        // Contacts: each row's impulse from the same velocities (Jacobi), in the
        // Coulomb cone (exCone: sliding, never adding energy).
        if(hasRow && !(EX_PROF_SKIP&2)) {
            // The row from its packed record (vector loads; no lambda holds W: CUMETAL_COMPATIBILITY.md).
            const float4* q=rp+size_t(kExRow)*threadIdx.x;
            const float4 q0=q[0],q1=q[1],q2=q[2],q3=q[3],q4=q[4],q5=q[5],q6=q[6],q7=q[7],q8=q[8];
            Bond rb;rb.n[0]=q0.x;rb.n[1]=q0.y;rb.n[2]=q0.z;rb.t1[0]=q0.w;rb.t1[1]=q1.x;rb.t1[2]=q1.y;rb.t2[0]=q1.z;rb.t2[1]=q1.w;
            rb.t2[2]=q2.x;rb.o0[0]=q2.y;rb.o0[1]=q2.z;rb.o0[2]=q2.w;rb.o1[0]=q3.x;rb.o1[1]=q3.y;rb.o1[2]=q3.z;rb.area=q3.w;
            const float Wr[9]={q4.x,q4.y,q4.z,q4.w,q5.x,q5.y,q5.z,q5.w,q6.x},Wi[9]={q6.y,q6.z,q6.w,q7.x,q7.y,q7.z,q7.w,q8.x,q8.y};
            float g[6]={0,0,0,0,0,0};exRelative(rb,0,vS+6*ra,g);exRelative(rb,1,vS+6*rn,g);
            float P[3];const float gap=rows[threadIdx.x].gap;
            if(rows[threadIdx.x].compliant){ExRow& x=rows[threadIdx.x];
                if(gap>0.0f || (x.crush&4u)){P[0]=P[1]=P[2]=0.0f;}
                // Crushed through (Settings::compliant): the crushed material cannot pass through the
                // striker; it leaves with the striker's normal speed (the plug, perfectly inelastic,
                // in this row's split metric); then the row is spent.
                else if(x.crush&2u){P[0]=g[0]>0.0f?-g[0]/fmaxf(Wr[0],FLT_MIN):0.0f;P[1]=P[2]=0.0f;x.crush|=4u;}
                else if(x.on>0.0f)exCrushRow(Wr,g,x,rb.area,h,P);
                else exCompliantRow(Wr,g,x.d-x.dp,x.Estar,x.sigma,x.R,x.face,rb.area,h,P);}   // (its elastic depth: dp holds a late contact's penetration, no force)
            else if(!(gap>0.0f)){
            // (a rigid row in contact: its arithmetic exactly as before two-body rows. The
            // gap's subtraction merged into this path, even behind gap > 0, changed the
            // rigid rows' float rounding (cannon-first's IMPACT_HASH, 1e-5 relative))
            float Ps[3];for(int i=0;i<3;++i)Ps[i]=-(Wi[3*i]*g[0]+Wi[3*i+1]*g[1]+Wi[3*i+2]*g[2]);
            exCone(Wr,g,Ps,rb.area,P);
            if(EX_PROF_DUP&2){float g2[6],P2[3],Ps2[3];for(int q=0;q<6;++q)g2[q]=g[q]*(1.0f+FLT_EPSILON*float(step&1));for(int q=0;q<3;++q)Ps2[q]=Ps[q]*(1.0f+FLT_EPSILON*float(step&1));
                exCone(Wr,g2,Ps2,rb.area,P2);dead+=1e-30f*(P2[0]+P2[1]+P2[2]);}}
            else{g[0]-=gap/h;   // (a gap still open: the row may close it this substep before it pushes)
            float Ps[3];for(int i=0;i<3;++i)Ps[i]=-(Wi[3*i]*g[0]+Wi[3*i+1]*g[1]+Wi[3*i+2]*g[2]);
            if(!(g[0]>0.0f) && !(rows[threadIdx.x].total[0]!=0.0f)){Ps[0]=Ps[1]=Ps[2]=0.0f;}
            exCone(Wr,g,Ps,rb.area,P);}
            for(int q=0;q<3;++q)rows[threadIdx.x].total[q]+=P[q];
            // Pushing: an impulse the impactor's momentum resolves in float (below
            // its float resolution it exchanges nothing representable).
            const float im=Small?imS[rn]:nodes[rn].im;
            const float pm=sqrtf(vS[6*rn]*vS[6*rn]+vS[6*rn+1]*vS[6*rn+1]+vS[6*rn+2]*vS[6*rn+2])/fmaxf(im,FLT_MIN);
            if(-P[0]>FLT_EPSILON*pm){shActive=1u;if(last)atomicAdd(&shPushing,1u);}
            const float x[6]={P[0],P[1],P[2],0,0,0};float f0[6]={0,0,0,0,0,0},f1[6]={0,0,0,0,0,0};
            exWrench(rb,x,0,f0);exWrench(rb,x,1,f1);float* o=rwr+12*size_t(threadIdx.x);for(int q=0;q<6;++q){o[q]=f0[q];o[6+q]=f1[q];}
        }
        __syncthreads();
        if(nr && !(EX_PROF_SKIP&4))for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
            PxU32 b0,b1;rowRange(k,b0,b1);if(b0==b1)continue;
            float f[6]={0,0,0,0,0,0};
            exGather(rwr,rowAdj,b0,b1,f);
            apply(k,f,1.0f);
            // The window's own geometry: where the row nodes have moved (exRefreshRow).
            if(sp.refreshEvery){ExNode& nk=nodes[k];for(int q=0;q<3;++q){nk.dx[q]+=h*vS[6*k+q];nk.dth[q]+=h*vS[6*k+3+q];}}
        }
        __syncthreads();
        // Compliant rows: their depth over the substep, at the closing rate after the impulses.
        if((sp.compliant || sp.twoBody) && hasRow && (rows[threadIdx.x].compliant || rows[threadIdx.x].gap>0.0f)) {
            const float4* q=rp+size_t(kExRow)*threadIdx.x;const float4 q0=q[0],q1=q[1],q2=q[2],q3=q[3];
            Bond rb;rb.n[0]=q0.x;rb.n[1]=q0.y;rb.n[2]=q0.z;rb.t1[0]=q0.w;rb.t1[1]=q1.x;rb.t1[2]=q1.y;rb.t2[0]=q1.z;rb.t2[1]=q1.w;
            rb.t2[2]=q2.x;rb.o0[0]=q2.y;rb.o0[1]=q2.z;rb.o0[2]=q2.w;rb.o1[0]=q3.x;rb.o1[1]=q3.y;rb.o1[2]=q3.z;
            float g[6]={0,0,0,0,0,0};exRelative(rb,0,vS+6*ra,g);exRelative(rb,1,vS+6*rn,g);
            ExRow& x=rows[threadIdx.x];
            if(x.gap>0.0f)x.gap=fmaxf(x.gap-g[0]*h,0.0f);else if(x.compliant)x.d=fmaxf(x.d+g[0]*h,0.0f);
            // The crushed depth: the intrusion past the elastic depth F / (2 a E*), at the force
            // applied (its work the striker's); through the chunk's depth, its joints break and
            // the plug follows.
            if((x.crush&1u) && !(x.crush&6u) && x.ac>0.0f) {
                const float dy=x.Fa/(2.0f*x.ac*x.Estar),dn=x.d-x.dp;
                if(dn>dy){x.dp+=dn-dy;crush+=x.Fa*(dn-dy);}
                if(x.depth>0.0f && x.dp>=x.depth){x.crush|=2u;nodes[ra].crushed=1u;atomicAdd(&shThrough,1u);}
            }
        }
        // The two-body car's implicit joints: two sweeps, each a joint pass and a node gather.
        if(sp.twoBody && sp.implicitJoints && !(EX_PROF_SKIP&16))for(int sweep=0;sweep<2;++sweep) {
            if(!(EX_PROF_SKIP&64))for(PxU32 i=threadIdx.x;i<nImplicit;i+=kExThreads)exImplicitJointA(jl[i],ja,jp,links,wr,wd,vS,eStart,h,time,s.capacityBand,&shBroken,&shYielded,&shFracture,&shPlastic,dead);
            __syncthreads();
            // (only the car's nodes: implicit joints are the car's)
            if(!(EX_PROF_SKIP&32))for(PxU32 k=sp.chunks-sp.carChunks+threadIdx.x;k<sp.chunks;k+=kExThreads) {
                PxU32 b0,b1;jointRange(k,b0,b1);if(b0==b1)continue;
                float f[6]={0,0,0,0,0,0};exGather(wd,adj,b0,b1,f);apply(k,f,h);
            }
            __syncthreads();
        }
        // The joints at the rows' nodes (and all of them when no thread is free beside the rows).
        if(!(EX_PROF_SKIP&8))for(PxU32 i=threadIdx.x;i<nAtRows;i+=kExThreads)joint(jl[nl-1u-i],time,last);
        // (v is final: the next substep's start for the implicit joints)
        if(eStart)for(PxU32 i=threadIdx.x;i<nImplicit;i+=kExThreads)exImplicitStart(jl[i],jp,vS,eStart);
        __syncthreads();
        if(sample) {
            // The damping's frequency from this substep's rates: omega_K^2 = (K v)^T M^-1 (K v) / v^T K v.
            float numLocal=0.0f;
            for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
                PxU32 b0,b1;jointRange(k,b0,b1);if(b0==b1)continue;
                float f[6]={0,0,0,0,0,0};exGather(wk,adj,b0,b1,f);
                float im,ii[3];if(Small){im=imS[k];for(int q=0;q<3;++q)ii[q]=iiS[3*k+q];}else{const ExNode& n=nodes[k];im=n.im;for(int q=0;q<3;++q)ii[q]=n.tensor?0.0f:n.Iinv[q];}
                if(ii[0]<0.0f)continue;   // (an impactor: none in a dynamic-sequence patch's joints)
                for(int q=0;q<3;++q)numLocal+=im*f[q]*f[q]+ii[q]*f[3+q]*f[3+q];
            }
            atomicAdd(&shNum,numLocal);atomicAdd(&shDen,denLocal);denLocal=0.0f;
            __syncthreads();
            if(!threadIdx.x){if(shNum>0.0f && shDen>0.0f)shBeta=2.0f/sqrtf(shNum/shDen);shNum=0.0f;shDen=0.0f;shResample=0u;}
            __syncthreads();
        }
        if(s.explicitWindow==1u && !seqp && !shActive){++step;sp.done=1;break;}
    }
    for(PxU32 i=threadIdx.x;i<6*nn;i+=kExThreads)nodes[i/6].v[i%6]=vS[i];
    for(PxU32 l=threadIdx.x;l<nl;l+=kExThreads){ExLink& e=links[l];const float4 s0=jp[size_t(kExJoint)*l+9],s1=jp[size_t(kExJoint)*l+10];
        e.J[0]=s0.x;e.J[1]=s0.y;e.J[2]=s0.z;e.J[3]=s0.w;e.J[4]=s1.x;e.J[5]=s1.y;e.state=__float_as_uint(s1.z);e.slip=s1.w;}
    atomicAdd(&shDead,dead);if(crush>0.0f)atomicAdd(&shCrush,crush);
    if(seqp){atomicAdd(&shDash,dashLocal);atomicAdd(&shSlipWork,slipLocal);atomicAdd(&shPlastic,plasticLocal);atomicAdd(&shExt,extLocal);}
    __syncthreads();
    if(!threadIdx.x && seqp){sp.beta=shBeta;sp.slipWork+=shSlipWork;sp.dashWork+=shDash;sp.extWork+=shExt;sp.events+=shEvents;sp.converted+=shConverted;sp.seatLost+=shSeat;sp.crushedContacts+=shCrushed;
        if(shEvents)sp.lastEvent=__uint_as_float(shLast);if(shActive2)sp.lastActive=__uint_as_float(shActive2);}
    if(!threadIdx.x){sp.dead+=shDead;sp.crushWork+=shCrush;sp.crushedThrough+=shThrough;sp.fracture+=shFracture;sp.plastic+=shPlastic;sp.substeps=step;sp.t=float(step)*h;sp.broken+=shBroken;sp.yielded+=shYielded;sp.pushing=shPushing;sp.near=shNear;if(step>=total)sp.done=1;}
}
__global__ __launch_bounds__(kExThreads) void exRun(Settings s,Scratch w,ExScratch t,PxU32 budget){exRunT<false>(s,w,t,budget);}
__global__ __launch_bounds__(kExThreads) void exRunSmall(Settings s,Scratch w,ExScratch t,PxU32 budget){exRunT<true>(s,w,t,budget);}

// 4. Publish: the patch's joints (forces, verdicts, slip), the rows' force
// and bound (the impulse delivered over the window, per point), the
// impactors' change; the rest of the island is held at its rest forces
// (stepPublish, launched first).
// A free group of chunk nodes [b0, b1) as one rigid body: its centre-of-mass velocity
// and its angular momentum about its centre of mass over the sum of its chunks'
// inertia and m r^2 2/3 (exact for a rigid group of round chunks), at the window's
// end (n.v) or start (n.v0); chunk positions x = rq c + rp in the struck frame.
__device__ void exGroupMotion(const Inputs& in,const ExNode* nodes,PxU32 b0,PxU32 b1,const PxQuat& rq,const PxVec3& rp,bool start,float* v,float* w)
{
    double m=0.0,c[3]={0,0,0},pm[3]={0,0,0};
    for(PxU32 k=b0;k<b1;++k){const ExNode& n=nodes[k];const float* u=start?n.v0:n.v;const double mk=n.im>0.0f?1.0/n.im:0.0;const PxVec3 x=rq.rotate(in.chunks[n.chunk].position)+rp;
        m+=mk;c[0]+=mk*x.x;c[1]+=mk*x.y;c[2]+=mk*x.z;for(int a=0;a<3;++a)pm[a]+=mk*u[a];}
    if(m>0.0){for(int a=0;a<3;++a){c[a]/=m;pm[a]/=m;}}
    double L[3]={0,0,0},I=0.0;
    for(PxU32 k=b0;k<b1;++k){const ExNode& n=nodes[k];const float* u0=start?n.v0:n.v;const double mk=n.im>0.0f?1.0/n.im:0.0,ik=n.Iinv[0]>0.0f?1.0/n.Iinv[0]:0.0;
        const PxVec3 x=rq.rotate(in.chunks[n.chunk].position)+rp;const double r[3]={x.x-c[0],x.y-c[1],x.z-c[2]},u[3]={u0[0]-pm[0],u0[1]-pm[1],u0[2]-pm[2]};
        L[0]+=ik*u0[3]+mk*(r[1]*u[2]-r[2]*u[1]);L[1]+=ik*u0[4]+mk*(r[2]*u[0]-r[0]*u[2]);L[2]+=ik*u0[5]+mk*(r[0]*u[1]-r[1]*u[0]);
        I+=ik+mk*(r[0]*r[0]+r[1]*r[1]+r[2]*r[2])*2.0/3.0;}
    for(int a=0;a<3;++a){v[a]=float(pm[a]);w[a]=I>0.0?float(L[a]/I):0.0f;}
}
__global__ void exPublish(Inputs in,Settings s,Scratch w,ExScratch t)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const ExPatch& sp=t.patches[p];
    const ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;const ExLink* links=t.links+size_t(p)*kExLinks;
    const Bond* rowBonds=t.rowBonds+size_t(p)*kExRows;const ExRow* rows=t.rows+size_t(p)*kExRows;
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    for(PxU32 l=tid;l<sp.links;l+=stride) {
        const Bond& b=bonds[l];const ExLink& e=links[l];
        float lin[3],ang[3];toSolver(b,e.J,lin,ang);
        // A car's joint: back into its own cluster's frame.
        if(e.state&eEX_CAR){const PxQuat rq=PxQuat(sp.carQ[0],sp.carQ[1],sp.carQ[2],sp.carQ[3]).getConjugate();exRotate(rq,lin);exRotate(rq,ang);}
        PxDestructionVectorPair fo;fo.linear=PxVec3(lin[0],lin[1],lin[2]);fo.angular=PxVec3(ang[0],ang[1],ang[2]);
        w.forces[b.bond]=fo;
        const float before=in.slipBefore?in.slipBefore[b.bond]:0.0f;
        const PxU32 v=(e.state&eEX_BROKEN)?eBROKEN:((e.state&eEX_YIELDED)?eYIELDED:eHELD);
        w.verdict[b.bond]=v;if(w.slip)w.slip[b.bond]=v==eYIELDED?fmaxf(0.0f,e.slip-before):0.0f;
        if(w.breaks && v==eBROKEN){w.breaks[2*b.bond]=e.brokeAt;w.breaks[2*b.bond+1]=e.slip;}
    }
    for(PxU32 r=tid;r<sp.rows;r+=stride) {
        const ExRow& x=rows[r];const ContactRow& row=in.rows[x.row];
        float lin[3],ang[3];toWorld(rowBonds[r],x.total,lin,ang);
        // The ghost check (the window's own geometry): the impactor's centre inside an intact chunk.
        if(x.geo && t.boxes && !(x.crush&2u)) {
            const ExNode& a=nodes[x.a];const ExNode& m=nodes[x.b];const PxDestructionChunkBox box=t.boxes[a.chunk];
            const PxQuat qa=exRotation(a.dth);const PxVec3 xa(a.x0[0]+a.dx[0],a.x0[1]+a.dx[1],a.x0[2]+a.dx[2]),pa(a.x0[0],a.x0[1],a.x0[2]);
            const PxVec3 l=(qa*box.rotation).rotateInv(PxVec3(m.x0[0]+m.dx[0],m.x0[1]+m.dx[1],m.x0[2]+m.dx[2])-(xa+qa.rotate(box.center-pa)));
            const bool inside=fabsf(l.x)<box.halfExtents.x && fabsf(l.y)<box.halfExtents.y && fabsf(l.z)<box.halfExtents.z;
            bool tied=false;for(PxU32 j=a.jointBegin;j<a.jointEnd && !tied;++j)tied=(links[t.adj[size_t(p)*2*kExLinks+j]>>1].state&eEX_LIVE)!=0u;
            if(inside && tied){atomicAdd(&t.patches[p].passedIntact,1u);atomicAdd(&w.status->passedIntact,1u);}
        }
        // A swept row (the window's own, met only within it): its chunk's crush and the
        // window's verdict are published; it has no stage row of its own.
        if(x.geo&2u) {
            if(in.crushOut && x.compliant && x.on>0.0f && x.depth>0.0f && (x.dp>0.0f || (x.crush&2u))) {
                const PxU32 c=nodes[x.a].chunk;PxDestructionCrushState& cs=in.crushOut[c];
                atomicMax(reinterpret_cast<unsigned*>(&cs.damage),__float_as_uint(fminf(x.dp/x.depth,1.0f)));
                if((x.crush&2u) && !atomicExch(&cs.crushed,1u) && in.crushedChunks)atomicAdd(in.crushedChunks,1u);
            }
            continue;
        }
        if(in.rowForce)for(int q=0;q<3;++q)in.rowForce[3*x.row+q]=lin[q]/s.dt;
        bool live=false;
        for(PxU32 j=nodes[x.a].jointBegin;j<nodes[x.a].jointEnd && !live;++j)live=(links[t.adj[size_t(p)*2*kExLinks+j]>>1].state&eEX_LIVE)!=0u;
        const float bound=sqrtf(lin[0]*lin[0]+lin[1]*lin[1]+lin[2]*lin[2])/float(max(row.points,1u));
        // Settings::compliant: where the window met every chunk the impactor reaches in the tick
        // (a round impactor's swept rows; a two-body car, whose joints it graded on them), it
        // decided the pair: the corrected pass drops it (the least positive bound, pairwise: no
        // impulse between them) and starts the impactor at its window end velocity
        // (applyWindowImpactors). Otherwise its contacts stay bounded at what the window delivered.
        const bool dropped=s.compliant && ((x.geo && !sp.uncovered) || x.b<sp.chunks);
        if(in.rowBound)in.rowBound[x.row]=dropped?FLT_MIN:((live || s.boundImpactor)?fmaxf(bound,FLT_MIN):0.0f);
        // The struck chunk's crush (Settings::compliant): the depth share its rows crushed,
        // or through (crushed: the stage makes it a free fragment).
        if(in.crushOut && x.compliant && x.on>0.0f && x.depth>0.0f && (x.dp>0.0f || (x.crush&2u))) {
            const PxU32 c=nodes[x.a].chunk;PxDestructionCrushState& cs=in.crushOut[c];
            const float share=fminf(x.dp/x.depth,1.0f);
            atomicMax(reinterpret_cast<unsigned*>(&cs.damage),__float_as_uint(share));
            if((x.crush&2u) && !atomicExch(&cs.crushed,1u) && in.crushedChunks)atomicAdd(in.crushedChunks,1u);
        }
        if(in.rowDelta && x.b>=sp.chunks){const ExNode& n=nodes[x.b];for(int q=0;q<3;++q){in.rowDelta[6*x.row+q]=n.v[q]-(row.velocity[q]+row.dv[q]);in.rowDelta[6*x.row+3+q]=n.v[3+q]-(row.spin[q]+row.dw[q]);}}
        // A two-body row: the car's centre-of-mass velocity change (its chunks' momentum).
        else if(in.rowDelta) {
            float pm[3]={0,0,0},m=0.0f;
            for(PxU32 k=sp.chunks-sp.carChunks;k<sp.chunks;++k){const ExNode& n=nodes[k];const float mk=n.im>0.0f?1.0f/n.im:0.0f;m+=mk;for(int q=0;q<3;++q)pm[q]+=mk*n.v[q];}
            for(int q=0;q<3;++q){in.rowDelta[6*x.row+q]=(m>0.0f?pm[q]/m:0.0f)-(row.velocity[q]+row.dv[q]);in.rowDelta[6*x.row+3+q]=0.0f;}
        }
    }
    // The window's chunk end velocities for the corrected pass's free fragments
    // (Settings::compliant: handoffWindowMomentum), in world: the nodes' velocities
    // are relative to the struck cluster, in its frame; a moving (dynamic struck)
    // cluster's rigid motion at the tick's start is added back at each chunk.
    // The dynamic sequence (without compliant: its own patches only) hands its anchored patches'
    // velocities over -- a free patch's rigid motion is PhysX's, its window only its internal one.
    if(in.windowV && in.windowMask && in.clusterPoses && sp.chunks && (s.compliant || sp.sequence) && !(sp.sequence && !sp.anchored)) {
        const PxU32 frame=in.chunks[nodes[0].chunk].cluster;const PxTransform pose=in.clusterPoses[frame];const PxQuat q=pose.q;
        PxVec3 vc(0.0f),wc(0.0f),pc(0.0f);
        if(sp.dynamic && in.clusterStart){const float4 a=in.clusterStart[3*size_t(frame)],b=in.clusterStart[3*size_t(frame)+1],c=in.clusterStart[3*size_t(frame)+2];
            vc=PxVec3(a.x,a.y,a.z);wc=PxVec3(b.x,b.y,b.z);pc=PxVec3(c.x,c.y,c.z);}
        for(PxU32 k=tid;k<sp.chunks;k+=stride){const ExNode& n=nodes[k];const PxU32 c=n.chunk;if(c>=in.chunkCount)continue;
            const PxVec3 x=pose.transform(PxVec3(n.x0[0],n.x0[1],n.x0[2]));
            const PxVec3 v=q.rotate(PxVec3(n.v[0],n.v[1],n.v[2]))+vc+wc.cross(x-pc),wv=q.rotate(PxVec3(n.v[3],n.v[4],n.v[5]))+wc;
            in.windowV[2*size_t(c)]=make_float4(v.x,v.y,v.z,0.0f);in.windowV[2*size_t(c)+1]=make_float4(wv.x,wv.y,wv.z,0.0f);in.windowMask[c]=1u;}
    }
    // The hand-off (ExScratch::handoff): each row decided; each rigid impactor's end
    // velocity; the two-body car's centre-of-mass velocity and an angular velocity
    // (its angular momentum about its centre of mass over the sum of its chunks'
    // inertia and m r^2 2/3: exact for a rigid car of round chunks).
    // (a dynamic struck island too large for one patch was held beyond it: its rows'
    // momentum stays the rigid solve's, so they are not marked decided)
    if(t.rowDecided && !(sp.dynamic && sp.truncated))for(PxU32 r=tid;r<sp.rows;r+=stride)t.rowDecided[rows[r].row]=1u;
    if(t.handoff && !blockIdx.x && !threadIdx.x) {
        for(PxU32 k=sp.chunks;k<sp.nodes;++k){const ExNode& n=nodes[k];if(!n.tensor)continue;
            PxU32 body=0xffffffffu;for(PxU32 r=0;r<sp.rows;++r)if(rows[r].b==k){body=in.rows[rows[r].row].body;break;}
            const PxU32 slot=atomicAdd(t.handoffCount,1u);if(slot>=kExHandoffs)break;
            ExScratch::Handoff hnd{};hnd.island=0xffffffffu;hnd.body=body;hnd.patch=p;for(int q=0;q<3;++q){hnd.v[q]=n.v[q];hnd.w[q]=n.v[3+q];hnd.v0[q]=n.v0[q];hnd.w0[q]=n.v0[3+q];}
            hnd.pad=(s.compliant && n.radius>0.0f && !sp.uncovered)?1u:0u;   // its pairs dropped: it starts the corrected pass at this velocity
            t.handoff[slot]=hnd;}
        if(sp.twoBody) {
            const ContactRow& q=in.rows[sp.carRow];const PxQuat rq(q.otherPose[0],q.otherPose[1],q.otherPose[2],q.otherPose[3]);const PxVec3 rp(q.otherPose[4],q.otherPose[5],q.otherPose[6]);
            const PxU32 slot=atomicAdd(t.handoffCount,1u);
            if(slot<kExHandoffs){ExScratch::Handoff hnd{};hnd.island=sp.car;hnd.body=q.body;hnd.patch=p;hnd.pad=s.compliant?1u:0u;   // (its rows always dropped)
                exGroupMotion(in,nodes,sp.chunks-sp.carChunks,sp.chunks,rq,rp,false,hnd.v,hnd.w);exGroupMotion(in,nodes,sp.chunks-sp.carChunks,sp.chunks,rq,rp,true,hnd.v0,hnd.w0);
                t.handoff[slot]=hnd;}
        }
        // A dynamic struck island (Settings::dynamicStruck): its own motion's change.
        if(sp.dynamic && !sp.truncated) {
            const ContactRow& q=in.rows[sp.dynamicRow];const PxQuat rq(PxIdentity);const PxVec3 rp(0.0f);
            const PxU32 slot=atomicAdd(t.handoffCount,1u);
            if(slot<kExHandoffs){ExScratch::Handoff hnd{};hnd.island=sp.island;hnd.body=q.clusterBody;hnd.patch=p;hnd.pad=(s.compliant && !sp.uncovered)?1u:0u;   // (as its round impactors' rows)
                exGroupMotion(in,nodes,0,sp.chunks-sp.carChunks,rq,rp,false,hnd.v,hnd.w);exGroupMotion(in,nodes,0,sp.chunks-sp.carChunks,rq,rp,true,hnd.v0,hnd.w0);
                t.handoff[slot]=hnd;}
        }
    }
    if(!blockIdx.x && !threadIdx.x) {
        float in0=0.0f,out0=0.0f;
        // (translational and rotational: w . I w / 2, I the inverse of the node's inverse inertia)
        // (and a two-body car's chunks: scalar inertia)
        // (and a dynamic struck island's chunks: they move, relative to the frame, too)
        for(PxU32 k=sp.dynamic?0u:sp.chunks-sp.carChunks;k<sp.chunks;++k){const ExNode& n=nodes[k];const float m=n.im>0.0f?1.0f/n.im:0.0f,I=n.Iinv[0]>0.0f?1.0f/n.Iinv[0]:0.0f;
            in0+=0.5f*m*(n.v0[0]*n.v0[0]+n.v0[1]*n.v0[1]+n.v0[2]*n.v0[2])+0.5f*I*(n.v0[3]*n.v0[3]+n.v0[4]*n.v0[4]+n.v0[5]*n.v0[5]);
            out0+=0.5f*m*(n.v[0]*n.v[0]+n.v[1]*n.v[1]+n.v[2]*n.v[2])+0.5f*I*(n.v[3]*n.v[3]+n.v[4]*n.v[4]+n.v[5]*n.v[5]);}
        for(PxU32 k=sp.chunks;k<sp.nodes;++k){const ExNode& n=nodes[k];if(!n.tensor)continue;const float m=n.im>0.0f?1.0f/n.im:0.0f;
            const float* S=n.Iinv;const float A=S[1]*S[2]-S[5]*S[5],B=S[0]*S[2]-S[4]*S[4],C=S[0]*S[1]-S[3]*S[3];
            const float D=S[4]*S[5]-S[3]*S[2],E=S[3]*S[5]-S[1]*S[4],F=S[3]*S[4]-S[0]*S[5],det=S[0]*A+S[3]*D+S[4]*E;
            float I[6]={0,0,0,0,0,0};if(det>0.0f && isfinite(det)){const float id=1.0f/det;const float t6[6]={A*id,B*id,C*id,D*id,E*id,F*id};for(int q=0;q<6;++q)I[q]=t6[q];}
            float a[3],b[3];symMul(I,n.v0+3,a);symMul(I,n.v+3,b);
            in0+=0.5f*m*(n.v0[0]*n.v0[0]+n.v0[1]*n.v0[1]+n.v0[2]*n.v0[2])+0.5f*(a[0]*n.v0[3]+a[1]*n.v0[4]+a[2]*n.v0[5]);
            out0+=0.5f*m*(n.v[0]*n.v[0]+n.v[1]*n.v[1]+n.v[2]*n.v[2])+0.5f*(b[0]*n.v[3]+b[1]*n.v[4]+b[2]*n.v[5]);}
        t.patches[p].keIn=in0;t.patches[p].keOut=out0;
        // The energy invariant: what the window dissipated by fracture and plastic
        // work is paid by the impactors' kinetic energy loss, the elastic energy
        // the patch held and the dead load's work (a sagging patch's).
        if(!sp.sequence && sp.fracture+sp.plastic+sp.crushWork>(in0-out0)+sp.u0+fmaxf(sp.dead,0.0f))atomicAdd(&w.status->energyDeficit,1u);
        // And the other way: the impactors leave with no more kinetic energy than the
        // window had (theirs, the joints' held elastic energy, the dead load's work),
        // up to symplectic Euler's energy error: its conserved H~ differs from H by
        // at most (omega h / 2) H (harmonic oscillator, H~ = H - (h/2) omega^2 x v), so
        // H <= H~ / (1 - omega h / 2) for omega h < 2. Past that, energy from
        // nowhere (Status::energyGain): a car whose window gained 1e3-1e4 times its
        // kinetic energy counted none.
        {const float wh=sp.omega*sp.h,avail=in0+sp.u0+fmaxf(sp.dead,0.0f);
         if(wh<2.0f && out0*(1.0f-0.5f*wh)>avail)atomicAdd(&w.status->energyGain,1u);}
        w.islandFlag[sp.island]=1u;if(sp.twoBody)w.islandFlag[sp.car]=1u;
        atomicAdd(&w.status->triggered,1u);atomicAdd(&w.status->solves,1u);atomicAdd(&w.status->iterations,sp.substeps);
        atomicAdd(&w.status->broken,sp.broken);atomicAdd(&w.status->yielded,sp.yielded);
        atomicAdd(&w.status->contacts,sp.rows);atomicAdd(&w.status->impactors,sp.impactors);
        atomicAdd(&w.status->stepPatches,1u);if(sp.truncated)atomicAdd(&w.status->stepTruncated,1u);
        if(sp.failed)atomicOr(&w.status->error,4u);
    }
}
// 4a. A dynamic patch's freeze (after exPublish, before exPublishDynamic): the period of
// its slowest motion at the window's end, 2 pi / omega_R with omega_R^2 = v^T K v / v^T
// M v (Rayleigh's quotient of the velocity field the island has: K over its live joints
// and closed contacts), the longest since its last activity (the persisted pPeriod while
// it had none); its quiet time; and it freezes once that has lasted a full such period
// (at least a tick). With no activity no joint reached capacity and no contact slid,
// opened or closed, so every force is within its set. (Its frozen joints' carried forces
// are watched by the stage: PxgDestructionSequence.cuh, seqThaw.)
__global__ __launch_bounds__(kThreads) void exSequencePeriod(Settings s,ExScratch t)
{
    __shared__ Shared sh;
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    ExPatch& sp=t.patches[p];if(!sp.sequence)return;
    const ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;const ExLink* links=t.links+size_t(p)*kExLinks;
    float num=0.0f,den=0.0f,qPrev=-1.0f,pPrev=-1.0f;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
        const ExLink& e=links[l];if(!(e.state&eEX_LIVE) || (e.state&eEX_CAR) || ((e.state&eEX_CONTACT) && (e.state&eEX_OPEN)))continue;
        const Bond& b=bonds[l];float d[6]={0,0,0,0,0,0};
        if(e.a!=0xffffffffu)exRelative(b,0,nodes[e.a].v,d);if(e.b!=0xffffffffu)exRelative(b,1,nodes[e.b].v,d);
        float k[6];exStiffness(b,k);for(int q=0;q<6;++q)num+=k[q]*d[q]*d[q];
    }
    for(PxU32 k=threadIdx.x;k<sp.chunks;k+=kThreads) {
        const ExNode& n=nodes[k];if(n.tensor || n.pad[1])continue;
        const float m=n.im>0.0f?1.0f/n.im:0.0f;
        den+=m*(n.v[0]*n.v[0]+n.v[1]*n.v[1]+n.v[2]*n.v[2]);for(int q=0;q<3;++q)den+=n.Iinv[q]>0.0f?n.v[3+q]*n.v[3+q]/n.Iinv[q]:0.0f;
        if(t.pChunk && (t.pChunk[n.chunk]&1u)){qPrev=fmaxf(qPrev,t.pQuiet[n.chunk]);pPrev=fmaxf(pPrev,t.pPeriod[n.chunk]);}
    }
    num=blockSum(sh,num);den=blockSum(sh,den);qPrev=blockMax(sh,qPrev);pPrev=blockMax(sh,pPrev);
    if(!threadIdx.x) {
        const float period=(num>0.0f && den>0.0f)?6.2831853f*sqrtf(den/num):0.0f;
        const bool active=sp.lastActive>=0.0f;
        sp.quiet=active?fmaxf(s.dt-sp.lastActive,0.0f):(qPrev>=0.0f?qPrev+s.dt:s.dt);
        sp.period=active || pPrev<0.0f?period:fmaxf(pPrev,period);
        sp.freeze=(sp.done && sp.quiet>=fmaxf(sp.period,s.dt))?1u:0u;
    }
}
// 4b. A dynamic patch's publication (after exPublish): its contacts' transmitted
// forces in place of their states, the window's re-bearing states and holds for the
// stage's verdict, the persisted state for the next window (each joint's force and
// contact slip, each chunk's velocity, the island's quiet time: since its last
// event, for the hand-back), and its books. The energy invariant: what the window
// dissipated (fracture, plastic work, contact slip, the dashpots) cannot exceed the
// energy it had -- its kinetic and elastic energy at the start and the loads' work
// on it (positive part); else Status::sequenceEnergy (energy from nowhere).
__global__ void exPublishDynamic(Inputs in,Settings s,Scratch w,ExScratch t)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    ExPatch& sp=t.patches[p];if(!sp.sequence)return;
    const ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;const ExLink* links=t.links+size_t(p)*kExLinks;
    const float* cslip=t.cslip+size_t(p)*kExLinks*2;
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    __shared__ float shStrain,shKe;__shared__ PxU32 shContacts;
    if(!threadIdx.x){shStrain=0.0f;shKe=0.0f;shContacts=0u;}
    __syncthreads();
    float strain=0.0f,ke=0.0f;PxU32 contacts=0u;
    for(PxU32 l=tid;l<sp.links;l+=stride) {
        const Bond& b=bonds[l];const ExLink& e=links[l];const PxU32 i=b.bond;
        if(e.state&eEX_CAR)continue;
        const bool live=(e.state&eEX_LIVE)!=0u,contact=(e.state&eEX_CONTACT)!=0u;
        float F[6];for(int q=0;q<6;++q)F[q]=e.J[q];
        if(live && contact) {
            exContactForce(b,e.J,exContactMu(b,s.dynamicFriction),F);++contacts;
            float lin[3],ang[3];toSolver(b,F,lin,ang);
            PxDestructionVectorPair fo;fo.linear=PxVec3(lin[0],lin[1],lin[2]);fo.angular=PxVec3(ang[0],ang[1],ang[2]);w.forces[i]=fo;
        }
        if(live){float k[6];exStiffness(b,k);strain+=exJointEnergy(b,k,e.J,e.state,exContactMu(b,s.dynamicFriction));}
        if(t.pJn){for(int q=0;q<6;++q)t.pJn[6*size_t(i)+q]=live?e.J[q]:0.0f;
            t.pSlipn[2*size_t(i)]=cslip[2*l];t.pSlipn[2*size_t(i)+1]=cslip[2*l+1];
            t.pBondn[i]=live?(1u|(contact?2u:0u)|(sp.freeze?4u:0u)):0u;}
        // A freeze: the state it holds (a contact's J: its gap when open, the force it transmits
        // when closed is exContactForce's of it), and the static solve's at the freeze (the
        // carried state's origin).
        if(sp.freeze && live && t.frozenForce) {
            float lin[3],ang[3];toSolver(b,e.J,lin,ang);
            PxDestructionVectorPair fo;fo.linear=PxVec3(lin[0],lin[1],lin[2]);fo.angular=PxVec3(ang[0],ang[1],ang[2]);
            t.frozenForce[i]=fo;t.freezeElastic[i]=in.elastic?in.elastic[i]:fo;
        }
        // eBEAR_FASTENED 0, eBEAR_CONTACT 1 (bearing); ~0 broken (the verdict's). An open contact
        // stays eBEAR_CONTACT: its gap is the window's state (persisted J), and eBEAR_LIFTED would
        // take it out of the solver's topology -- splitting the island, so that the next window
        // could not close it (a contact that has nothing to bear on was broken by exSequenceSplit).
        if(t.seqBear && (e.state&eEX_BEARING))t.seqBear[i]=!live?0xffffffffu:(!contact?0u:1u);
        if(t.seqHold)t.seqHold[i]=(live && contact)?1u:0u;
    }
    for(PxU32 k=tid;k<sp.chunks;k+=stride) {
        const ExNode& n=nodes[k];if(n.tensor || n.pad[1])continue;
        const float m=n.im>0.0f?1.0f/n.im:0.0f,I=n.Iinv[0]>0.0f?1.0f/n.Iinv[0]:0.0f;
        ke+=0.5f*(m*(n.v[0]*n.v[0]+n.v[1]*n.v[1]+n.v[2]*n.v[2])+I*(n.v[3]*n.v[3]+n.v[4]*n.v[4]+n.v[5]*n.v[5]));
        if(t.pVn) {
            const PxU32 c=n.chunk;t.pChunkn[c]=1u|(sp.freeze?2u:0u);for(int q=0;q<6;++q)t.pVn[6*size_t(c)+q]=n.v[q];
            t.pQuietn[c]=sp.quiet;t.pPeriodn[c]=sp.period;
            if(sp.freeze && t.seqCycles)++t.seqCycles[c];
        }
    }
    atomicAdd(&shStrain,strain);atomicAdd(&shKe,ke);atomicAdd(&shContacts,contacts);
    if(sp.freeze && t.seqCounters && !blockIdx.x && !threadIdx.x)atomicAdd(t.seqCounters,1u);
    __syncthreads();
    if(!threadIdx.x) {
        atomicAdd(&sp.strainEnd,shStrain-(blockIdx.x?0.0f:sp.u0));atomicAdd(&sp.keEnd,shKe-(blockIdx.x?0.0f:sp.keStart));atomicAdd(&sp.contacts,shContacts);
        // (sp.strainEnd and sp.keEnd start at u0 and keStart: the first block's subtraction resets them)
    }
}
// The dynamic patches' books, once their publication is summed: the invariant and the counters.
__global__ void exSequenceBooks(Scratch w,ExScratch t)
{
    const PxU32 p=threadIdx.x;if(p>=*t.patchCount)return;
    const ExPatch& sp=t.patches[p];if(!sp.sequence)return;
    const float dissipated=sp.fracture+sp.plastic+sp.slipWork+sp.dashWork,had=sp.keStart+sp.u0+fmaxf(sp.extWork,0.0f);
    if(dissipated>had)atomicAdd(&w.status->sequenceEnergy,1u);
    atomicAdd(&w.status->sequencePatches,1u);atomicAdd(&w.status->sequenceSubsteps,sp.substeps);
    atomicAdd(&w.status->sequenceBroken,sp.broken);atomicAdd(&w.status->sequenceConverted,sp.converted);
}
// The rest of each patch's island: held at its rest forces.
__global__ void exPublishIsland(Inputs in,Scratch w,ExScratch t)
{
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    const PxU32 patches=*t.patchCount;
    for(PxU32 i=tid;i<in.bondCount;i+=stride) {
        const PxU32 island=in.bondIslands[i];if(island>=in.chunkCount)continue;
        for(PxU32 p=0;p<patches;++p)if(t.patches[p].island==island || (t.patches[p].twoBody && t.patches[p].car==island)){
            if(in.decidedBonds)in.decidedBonds[i]=1u;   // (Settings::compliant: its verdict stands through the corrected pass)
            if(t.linkOf[i]!=0xffffffffu)continue;       // a joint of the patch: exPublish's
            w.forces[i]=in.base[i];w.verdict[i]=eHELD;if(w.slip)w.slip[i]=0.0f;}
    }
}
// The stress solve report's contact input (getStressSolveReport, its third
// segment: each chunk's acceleration after contact loads) for a two-body car's
// chunks: its joints were graded on the window's forces, so the report carries
// each of its rows' window impulse over the tick in place of the trial's contact
// load there (both the reaction on the car's chunk, in its cluster's frame; linear
// only). report: [3 n] (prepared, constraint, contact), n chunks.
__global__ void exReportLoads(Inputs in,Settings s,ExScratch t,PxDestructionVectorPair* report,PxU32 n)
{
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    const ExPatch& sp=t.patches[p];if(!sp.twoBody)return;
    const ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* rowBonds=t.rowBonds+size_t(p)*kExRows;const ExRow* rows=t.rows+size_t(p)*kExRows;
    const PxQuat back=PxQuat(sp.carQ[0],sp.carQ[1],sp.carQ[2],sp.carQ[3]).getConjugate();
    for(PxU32 r=threadIdx.x;r<sp.rows;r+=blockDim.x) {
        const ExRow& x=rows[r];if(x.b>=sp.chunks || x.b<sp.chunks-sp.carChunks)continue;
        const PxU32 c=nodes[x.b].chunk;if(c>=n)continue;
        float lin[3],ang[3];toWorld(rowBonds[r],x.total,lin,ang);
        const ContactRow& row=in.rows[x.row];
        const PxVec3 window=back.rotate(PxVec3(-lin[0],-lin[1],-lin[2])*(1.0f/s.dt)),trial=back.rotate(PxVec3(-row.load[0],-row.load[1],-row.load[2]));
        const PxVec3 a=(window-trial)*nodes[x.b].im;
        PxDestructionVectorPair& e=report[2*size_t(n)+c];
        atomicAdd(&e.linear.x,a.x);atomicAdd(&e.linear.y,a.y);atomicAdd(&e.linear.z,a.z);
    }
}
__global__ void exClear(Inputs in,ExScratch t)
{
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    for(PxU32 i=tid;i<in.chunkCount;i+=stride)t.nodeOf[i]=0xffffffffu;
    for(PxU32 i=tid;i<in.bondCount;i+=stride)t.linkOf[i]=0xffffffffu;
    if(t.rowDecided)for(PxU32 i=tid;i<in.rowCount;i+=stride)t.rowDecided[i]=0u;
    // (the dynamic sequence's second submission keeps the first's hand-off records)
    if(!tid){*t.patchCount=0;if(t.handoffCount && !t.seqCreate)*t.handoffCount=0;}
}
