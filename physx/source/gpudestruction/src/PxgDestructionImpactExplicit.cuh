// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#ifndef EX_THREADS
#define EX_THREADS 512
#endif
// Timing diagnostics only (never in a product build): a bit mask of the
// window's phases to skip -- 1 the joint gather, 2 the contact rows, 4 the row
// gather, 8 the joints.
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
constexpr PxU32 kExNodes=1024;     // chunks and impactors per patch
constexpr PxU32 kExLinks=4096;     // joints per patch
constexpr PxU32 kExRows=256;       // contact rows per patch (a meteor's debris: 216 seen)
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
};
// A joint of the patch: local node ends (0xffffffff: held), state bits.
// eEX_ROWS: an end of the joint has contact rows (exRunT sets it; the window's
// other joints run beside the rows).
// eEX_FRICTION: a Mohr-Coulomb joint (Bond::mu > 0): its mu and cap are packed in
// its record's last float4, read only for such joints (512: 32-256 are the
// two-body and dynamic-sequence branches' bits).
enum ExState : PxU32 { eEX_LIVE=1, eEX_DUCTILE=2, eEX_YIELDED=4, eEX_BROKEN=8, eEX_ROWS=16, eEX_FRICTION=512 };
struct ExLink { PxU32 a,b,state,pad; float J0[6],J[6]; float slip,limit,brokeAt,pad2; };
// A contact row: the struck chunk (a, local), the impactor (b), the stage's row.
struct ExRow { PxU32 a,b,row,pad; float P[3],total[3],Winv[9],W[9]; };
// A node: inverse mass and inverse inertia (chunks: scalar ii in Iinv[0..2]),
// velocity, the rest forces' load; tensor 1 for an impactor.
struct ExNode { PxU32 chunk,tensor,jointBegin,jointEnd,rowBegin,rowEnd,pad[2]; float im,Iinv[6],v[6],f0[6],v0[6]; };

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
// 1. The patches: one per island with a routed row, in row order; each
// patch's rows (at most kExRows) and its impactor bodies.
__global__ void exList(Inputs in,Settings s,Scratch w,ExScratch t)
{
    if(blockIdx.x || threadIdx.x)return;
    const PxU32 rows=in.rows?(in.rowCounter?min(*in.rowCounter,in.rowCount):in.rowCount):0u;
    PxU32 count=0;
    for(PxU32 r=0;r<rows;++r) {
        const PxU32 c=in.rows[r].chunk;if(c>=in.chunkCount)continue;
        const PxU32 island=in.nodeIslands[c];if(island>=in.chunkCount || !stepRow(in,r,island))continue;
        PxU32 p=0;while(p<count && t.patches[p].island!=island)++p;
        if(p==count) {
            if(count>=kExPatches){atomicOr(&w.status->error,1u);continue;}
            ExPatch e{};e.island=island;e.radius=s.stepRadius;e.seed=r;t.patches[count++]=e;
        }
        ExPatch& e=t.patches[p];PxU32* list=t.rowList+size_t(p)*kExRows;
        if(e.listed>=kExRows){e.failed=1;continue;}
        bool body=true;for(PxU32 k=0;k<e.listed;++k)body=body && in.rows[list[k]].body!=in.rows[r].body;
        e.bodies+=body?1u:0u;list[e.listed++]=r;
    }
    *t.patchCount=count;
}

__device__ void exFinish(Shared& sh,const Settings& s,const ExScratch& t,PxU32 p);
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
    __shared__ float hit[3*kExRows];
    for(PxU32 k=threadIdx.x;k<nrows;k+=kThreads){const PxVec3 x=in.chunks[in.rows[list[k]].chunk].position;hit[3*k]=x.x;hit[3*k+1]=x.y;hit[3*k+2]=x.z;}
    __syncthreads();
    const PxDestructionStressChunk* const chunks=in.chunks;   // a local copy: the build writes through other pointers
    auto near=[chunks,nrows](PxU32 i,float radius,const float* hit){const PxVec3 x=chunks[i].position;const float r2=radius*radius;
        for(PxU32 k=0;k<nrows;++k){const float dx=x.x-hit[3*k],dy=x.y-hit[3*k+1],dz=x.z-hit[3*k+2];if(dx*dx+dy*dy+dz*dz<=r2)return true;}return false;};
    // Radius: shrink until the island's chunks within it fit beside the impactors.
    float radius=s.stepRadius;PxU32 count=0;
    for(int attempt=0;attempt<32;++attempt) {
        PxU32 c=0;
        for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads)
            c+=(in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i) && near(i,radius,hit))?1u:0u;
        count=blockCount(sh,c);
        if(count+bodies<=kExNodes)break;
        radius*=0.85f;
    }
    if(!threadIdx.x){sp.radius=radius;if(radius<s.stepRadius)sp.truncated=1;sh.flag=0;}
    __syncthreads();
    // Chunk nodes (chunk order).
    for(PxU32 tile=0;tile<in.chunkCount;tile+=kThreads) {
        const PxU32 i=tile+threadIdx.x;PxU32 member=0;
        if(i<in.chunkCount && in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i))member=near(i,radius,hit)?1u:0u;
        PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
        if(member) {
            const PxU32 k=sh.flag+prefix;
            if(k<kExNodes){t.nodeOf[i]=(p<<16)|k;ExNode n{};n.chunk=i;n.tensor=0;const auto c=in.chunks[i];
                n.im=1.0f/c.mass;n.Iinv[0]=n.Iinv[1]=n.Iinv[2]=c.inertia>0.0f?1.0f/c.inertia:0.0f;nodes[k]=n;}
        }
        __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
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
            for(PxU32 e=0;e<k;++e)if(rowBody[e]==body){node=rowEnd[2*e+1];break;}
            if(node==0xffffffffu) {
                if(n>=kExNodes){sp.failed=1;continue;}
                node=n++;++impactors;
                ExNode m{};m.chunk=in.chunkCount+p*kExNodes+node;m.tensor=1;m.im=q.im;for(int a=0;a<6;++a)m.Iinv[a]=q.ii[a];
                for(int a=0;a<3;++a){m.v[a]=q.velocity[a];m.v[3+a]=q.spin[a];}
                for(int a=0;a<6;++a)m.v0[a]=m.v[a];
                nodes[node]=m;
            }
            ExRow e{};e.a=sc&0xffffu;e.b=node;e.row=r;exRows[k]=e;rowBody[k]=body;rowEnd[2*k]=e.a;rowEnd[2*k+1]=node;++k;
        }
        sp.nodes=n;sp.chunks=chunkNodes;sp.rows=k;sp.impactors=impactors;
    }
    __syncthreads();
    for(PxU32 k=threadIdx.x;k<sp.rows;k+=kThreads){Bond b;prepareRow(in,s,exRows[k].row,b);b.c1=in.chunkCount+p*kExNodes+rowEnd[2*k+1];rowBonds[k]=b;}
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
            e.slip=in.slipBefore?in.slipBefore[i]:0.0f;e.limit=b.slip;e.brokeAt=-1.0f;
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
    exFinish(sh,s,t,p);
}
// A built patch's rest load f0 = -B J0 per node, its Gershgorin bound and the
// substep (also for a patch filled by a test).
__device__ void exFinish(Shared& sh,const Settings& s,const ExScratch& t,PxU32 p)
{
    ExPatch& sp=t.patches[p];const PxU32 nn=sp.nodes;
    ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;const ExLink* links=t.links+size_t(p)*kExLinks;
    const PxU32* adj=t.adj+size_t(p)*2*kExLinks;
    float* wr=t.wr+size_t(p)*kExLinks*12;
    float u0=0.0f;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads){const ExLink& e=links[l];if(!(e.state&eEX_LIVE))continue;
        float k[6];exStiffness(bonds[l],k);for(int q=0;q<6;++q)if(k[q]>0.0f)u0+=0.5f*e.J0[q]*e.J0[q]/k[q];}
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
                if(e.state&eEX_LIVE) {
                    const PxU32 other=end?e.a:e.b;float w[6]={0,0,0,0,0,0};
                    if(other!=0xffffffffu){const ExNode& o=nodes[other];for(int q=0;q<3;++q){w[q]=sqrtf(o.im);w[3+q]=sqrtf(o.Iinv[q]);}}
                    exWrench(bonds[l],e.J0,end,f);
                    exGershgorin(bonds[l],end,other!=0xffffffffu,w,D,g,y,lump);
                }
                for(int a=0;a<2;++a)for(int c=0;c<2;++c)Lo[4*j+2*a+c]=lump[3*a+c]*sqrtf(a?n.Iinv[0]>0.0f?fmaxf(n.Iinv[0],fmaxf(n.Iinv[1],n.Iinv[2])):0.0f:n.im);
                O[j]=(e.state&eEX_LIVE)?(end?e.a:e.b):0xffffffffu;
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
    __syncthreads();
    if(!threadIdx.x) {
        sp.omega=sqrtf(lambda);
        sp.h=s.explicitDt>0.0f?s.explicitDt:(sp.omega>0.0f?s.explicitSafety*2.0f/sp.omega:s.dt);
        sp.h=fminf(sp.h,s.dt);sp.t=0.0f;sp.substeps=0;sp.done=0;
    }
    __syncthreads();
}
__global__ __launch_bounds__(kThreads) void exFinishKernel(Settings s,ExScratch t)
{
    __shared__ Shared sh;if(blockIdx.x<*t.patchCount)exFinish(sh,s,t,blockIdx.x);
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
template<bool Small> __device__ __forceinline__
void exRunT(Settings s,Scratch w,ExScratch t,PxU32 budget)
{
    constexpr PxU32 kV=Small?kExSmall:kExNodes,kN=Small?kExSmall:1u;
    __shared__ PxU32 shBroken,shYielded,shActive,shPushing,shNear,shFree,shAtRows;
    __shared__ float shFracture,shPlastic,shDead;
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
    if(!threadIdx.x){shBroken=0;shYielded=0;shFracture=0.0f;shPlastic=0.0f;shDead=0.0f;shFree=0;shAtRows=0;}
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
    float W[9]={0,0,0,0,0,0,0,0,0};PxU32 ra=0,rn=0;
    if(hasRow) {
        const Bond rb=rowBonds[threadIdx.x];const ExRow x=rows[threadIdx.x];ra=x.a;rn=x.b;
        for(PxU32 end=0;end<2;++end) {
            const ExNode& n=nodes[end?x.b:x.a];float col[3][6];
            const float split=float(max(n.rowEnd-n.rowBegin,1u));
            for(int q=0;q<3;++q){float xq[6]={0,0,0,0,0,0};xq[q]=1.0f;float f[6]={0,0,0,0,0,0};exWrench(rb,xq,end,f);exApplyInverse(n,f,col[q]);for(int c=0;c<6;++c)col[q][c]*=split;}
            for(int i=0;i<3;++i)for(int q=0;q<3;++q){float e6[6]={0,0,0,0,0,0};exRelative(rb,end,col[q],e6);W[3*i+q]+=e6[i];}
        }
        const float det=W[0]*(W[4]*W[8]-W[5]*W[7])-W[1]*(W[3]*W[8]-W[5]*W[6])+W[2]*(W[3]*W[7]-W[4]*W[6]);
        const float id=(det>0.0f && isfinite(det))?1.0f/det:0.0f;
        const float inv[9]={(W[4]*W[8]-W[5]*W[7])*id,(W[2]*W[7]-W[1]*W[8])*id,(W[1]*W[5]-W[2]*W[4])*id,
            (W[5]*W[6]-W[3]*W[8])*id,(W[0]*W[8]-W[2]*W[6])*id,(W[2]*W[3]-W[0]*W[5])*id,
            (W[3]*W[7]-W[4]*W[6])*id,(W[1]*W[6]-W[0]*W[7])*id,(W[0]*W[4]-W[1]*W[3])*id};
        for(int i=0;i<9;++i){rows[threadIdx.x].Winv[i]=inv[i];rows[threadIdx.x].W[i]=W[i];}
        float4* q=rp+size_t(kExRow)*threadIdx.x;
        q[0]=make_float4(rb.n[0],rb.n[1],rb.n[2],rb.t1[0]);q[1]=make_float4(rb.t1[1],rb.t1[2],rb.t2[0],rb.t2[1]);
        q[2]=make_float4(rb.t2[2],rb.o0[0],rb.o0[1],rb.o0[2]);q[3]=make_float4(rb.o1[0],rb.o1[1],rb.o1[2],rb.area);
        q[4]=make_float4(W[0],W[1],W[2],W[3]);q[5]=make_float4(W[4],W[5],W[6],W[7]);q[6]=make_float4(W[8],inv[0],inv[1],inv[2]);
        q[7]=make_float4(inv[3],inv[4],inv[5],inv[6]);q[8]=make_float4(inv[7],inv[8],0.0f,0.0f);
    }
    __syncthreads();
    PxU32 step=sp.substeps;float dead=0.0f;
    // A joint's substep: the trial, then fracture or the radial return; the force change's wrench on both ends.
    auto joint=[&](PxU32 l,float time,bool last) {
        float4* q=jp+size_t(kExJoint)*l;
        Bond b;float J0[6];PxU32 ea,eb;exUnpack(q,b,J0,ea,eb);
        const float4 s0=q[9],s1=q[10];PxU32 state=__float_as_uint(s1.z);float slip=s1.w;
        if(!(state&eEX_LIVE))return;   // broke earlier in this launch
        exUnpackFriction(q,state,b);
        float d[6]={0,0,0,0,0,0};if(ea!=0xffffffffu)exRelative(b,0,vS+6*ea,d);if(eb!=0xffffffffu)exRelative(b,1,vS+6*eb,d);
        for(int q6=0;q6<6;++q6)dead-=h*J0[q6]*d[q6];
        float k[6];exStiffness(b,k);
        const float Jp[6]={s0.x,s0.y,s0.z,s0.w,s1.x,s1.y};
        float J[6];for(int q6=0;q6<6;++q6)J[q6]=Jp[q6]-h*k[q6]*d[q6];
        const float u=utilisation(b,J);
        // An event is near: a brittle joint within the band, a ductile one slipping.
        if((state&eEX_DUCTILE)?u>1.0f:u>=1.0f-s.capacityBand){shActive=1u;if(last)atomicAdd(&shNear,1u);}
        bool breaks=false;
        if(!(state&eEX_DUCTILE))breaks=u>=1.0f-s.capacityBand;
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
    const PxU32 rowThreads=min((nr+31u)&~31u,kExThreads),freeStride=kExThreads-rowThreads;
    __syncthreads();
    for(PxU32 l=threadIdx.x;l<nl;l+=kExThreads) {
        ExLink& e=links[l];PxU32 b0,b1,c0=0,c1=0;
        if(e.a!=0xffffffffu){rowRange(e.a,b0,b1);c0=b1-b0;}
        if(e.b!=0xffffffffu){rowRange(e.b,b0,b1);c1=b1-b0;}
        e.state=(c0||c1)?(e.state|eEX_ROWS):(e.state&~eEX_ROWS);
        exPack(bonds[l],e,jp+size_t(kExJoint)*l);
        // The lists the substeps walk (any order: each joint's substep is its own).
        if(e.state&eEX_LIVE){if((c0||c1) || !freeStride)jl[nl-1u-atomicAdd(&shAtRows,1u)]=l;else jl[atomicAdd(&shFree,1u)]=l;}
    }
    __syncthreads();
    const PxU32 nFree=shFree,nAtRows=shAtRows;
    for(PxU32 it=0;it<budget && step<total;++it,++step) {
        const float time=float(step+1)*h;const bool last=step+1==total;
        // The window's end (Settings::explicitWindow 1): once no contact pushes, no
        // brittle joint is within the capacity band and no ductile one slips, no
        // event is under way; what remains (the dead load settling around the
        // damage) is the next tick's static verdict.
        if(!threadIdx.x){shActive=0u;shPushing=0u;shNear=0u;}
        // Joint forces on the nodes: each node gathers its joints' wrenches (no atomics).
        if(!(EX_PROF_SKIP&1))for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
            PxU32 b0,b1;jointRange(k,b0,b1);if(b0==b1)continue;
            float f[6]={0,0,0,0,0,0};
            exGather(wr,adj,b0,b1,f);
            apply(k,f,h);
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
            float Ps[3];for(int i=0;i<3;++i)Ps[i]=-(Wi[3*i]*g[0]+Wi[3*i+1]*g[1]+Wi[3*i+2]*g[2]);
            float P[3];exCone(Wr,g,Ps,rb.area,P);
            if(EX_PROF_DUP&2){float g2[6],P2[3],Ps2[3];for(int q=0;q<6;++q)g2[q]=g[q]*(1.0f+FLT_EPSILON*float(step&1));for(int q=0;q<3;++q)Ps2[q]=Ps[q]*(1.0f+FLT_EPSILON*float(step&1));
                exCone(Wr,g2,Ps2,rb.area,P2);dead+=1e-30f*(P2[0]+P2[1]+P2[2]);}
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
        }
        __syncthreads();
        // The joints at the rows' nodes (and all of them when no thread is free beside the rows).
        if(!(EX_PROF_SKIP&8))for(PxU32 i=threadIdx.x;i<nAtRows;i+=kExThreads)joint(jl[nl-1u-i],time,last);
        __syncthreads();
        if(s.explicitWindow==1u && !shActive){++step;sp.done=1;break;}
    }
    for(PxU32 i=threadIdx.x;i<6*nn;i+=kExThreads)nodes[i/6].v[i%6]=vS[i];
    for(PxU32 l=threadIdx.x;l<nl;l+=kExThreads){ExLink& e=links[l];const float4 s0=jp[size_t(kExJoint)*l+9],s1=jp[size_t(kExJoint)*l+10];
        e.J[0]=s0.x;e.J[1]=s0.y;e.J[2]=s0.z;e.J[3]=s0.w;e.J[4]=s1.x;e.J[5]=s1.y;e.state=__float_as_uint(s1.z);e.slip=s1.w;}
    atomicAdd(&shDead,dead);
    __syncthreads();
    if(!threadIdx.x){sp.dead+=shDead;sp.fracture+=shFracture;sp.plastic+=shPlastic;sp.substeps=step;sp.t=float(step)*h;sp.broken+=shBroken;sp.yielded+=shYielded;sp.pushing=shPushing;sp.near=shNear;if(step>=total)sp.done=1;}
}
__global__ __launch_bounds__(kExThreads) void exRun(Settings s,Scratch w,ExScratch t,PxU32 budget){exRunT<false>(s,w,t,budget);}
__global__ __launch_bounds__(kExThreads) void exRunSmall(Settings s,Scratch w,ExScratch t,PxU32 budget){exRunT<true>(s,w,t,budget);}

// 4. Publish: the patch's joints (forces, verdicts, slip), the rows' force
// and bound (the impulse delivered over the window, per point), the
// impactors' change; the rest of the island is held at its rest forces
// (stepPublish, launched first).
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
        if(in.rowForce)for(int q=0;q<3;++q)in.rowForce[3*x.row+q]=lin[q]/s.dt;
        bool live=false;
        for(PxU32 j=nodes[x.a].jointBegin;j<nodes[x.a].jointEnd && !live;++j)live=(links[t.adj[size_t(p)*2*kExLinks+j]>>1].state&eEX_LIVE)!=0u;
        const float bound=sqrtf(lin[0]*lin[0]+lin[1]*lin[1]+lin[2]*lin[2])/float(max(row.points,1u));
        if(in.rowBound)in.rowBound[x.row]=(live || s.boundImpactor)?fmaxf(bound,FLT_MIN):0.0f;
        if(in.rowDelta){const ExNode& n=nodes[x.b];for(int q=0;q<3;++q){in.rowDelta[6*x.row+q]=n.v[q]-(row.velocity[q]+row.dv[q]);in.rowDelta[6*x.row+3+q]=n.v[3+q]-(row.spin[q]+row.dw[q]);}}
    }
    if(!blockIdx.x && !threadIdx.x) {
        float in0=0.0f,out0=0.0f;
        // (translational and rotational: w . I w / 2, I the inverse of the node's inverse inertia)
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
        if(sp.fracture+sp.plastic>(in0-out0)+sp.u0+fmaxf(sp.dead,0.0f))atomicAdd(&w.status->energyDeficit,1u);
        w.islandFlag[sp.island]=1u;
        atomicAdd(&w.status->triggered,1u);atomicAdd(&w.status->solves,1u);atomicAdd(&w.status->iterations,sp.substeps);
        atomicAdd(&w.status->broken,sp.broken);atomicAdd(&w.status->yielded,sp.yielded);
        atomicAdd(&w.status->contacts,sp.rows);atomicAdd(&w.status->impactors,sp.impactors);
        atomicAdd(&w.status->stepPatches,1u);if(sp.truncated)atomicAdd(&w.status->stepTruncated,1u);
        if(sp.failed)atomicOr(&w.status->error,4u);
    }
}
// The rest of each patch's island: held at its rest forces.
__global__ void exPublishIsland(Inputs in,Scratch w,ExScratch t)
{
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    const PxU32 patches=*t.patchCount;
    for(PxU32 i=tid;i<in.bondCount;i+=stride) {
        const PxU32 island=in.bondIslands[i];if(island>=in.chunkCount)continue;
        for(PxU32 p=0;p<patches;++p)if(t.patches[p].island==island){w.forces[i]=in.base[i];w.verdict[i]=eHELD;if(w.slip)w.slip[i]=0.0f;}
    }
}
__global__ void exClear(Inputs in,ExScratch t)
{
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    for(PxU32 i=tid;i<in.chunkCount;i+=stride)t.nodeOf[i]=0xffffffffu;
    for(PxU32 i=tid;i<in.bondCount;i+=stride)t.linkOf[i]=0xffffffffu;
    if(!tid)*t.patchCount=0;
}
