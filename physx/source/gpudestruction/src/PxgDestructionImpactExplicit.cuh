// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#ifndef EX_THREADS
#define EX_THREADS 256
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
// and joint and row ranges in threadgroup memory beside their velocities.
constexpr PxU32 kExSmall=512;

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
enum ExState : PxU32 { eEX_LIVE=1, eEX_DUCTILE=2, eEX_YIELDED=4, eEX_BROKEN=8 };
struct ExLink { PxU32 a,b,state,pad; float J0[6],J[6]; float slip,limit,brokeAt,pad2; };
// A contact row: the struck chunk (a, local), the impactor (b), the stage's row.
struct ExRow { PxU32 a,b,row,pad; float P[3],total[3],Winv[9],W[9]; };
// A node: inverse mass and inverse inertia (chunks: scalar ii in Iinv[0..2]),
// velocity, the rest forces' load; tensor 1 for an impactor.
struct ExNode { PxU32 chunk,tensor,jointBegin,jointEnd,rowBegin,rowEnd,pad[2]; float im,Iinv[6],v[6],f0[6],v0[6]; };

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
// The Gershgorin row sums of one end's stiffness block rows against both ends:
// rows[r] += sum_c |(B_end K B_e^T)_rc|, and the same of M^-1/2 K M^-1/2 less
// the row's own scale, sym[r] += sum_c |..._rc| sqrt(m^-1 of e's dof c) (both
// ends on the patch; minv: each end's six inverse masses).
__device__ void exGershgorin(const Bond& b,const ExLink& l,PxU32 end,const float (*minv)[6],float* rows,float* sym)
{
    float k[6];exStiffness(b,k);
    float Be[2][36];
    for(PxU32 e=0;e<2;++e)for(int q=0;q<6;++q){float x[6]={0,0,0,0,0,0};x[q]=1.0f;float r[6]={0,0,0,0,0,0};exWrench(b,x,e,r);for(int i=0;i<6;++i)Be[e][6*i+q]=r[i];}
    const PxU32 ends[2]={l.a,l.b};
    for(int r=0;r<6;++r) {
        float s=0.0f,t=0.0f;
        for(PxU32 e=0;e<2;++e) {
            if(ends[e]==0xffffffffu)continue;
            for(int c=0;c<6;++c){float v=0.0f;for(int q=0;q<6;++q)v+=Be[end][6*r+q]*k[q]*Be[e][6*c+q];s+=fabsf(v);t+=fabsf(v)*sqrtf(minv[e][c]);}
        }
        rows[r]+=s;sym[r]+=t;
    }
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
__device__ __forceinline__ void exConeMetric(const float* W,const float* Ps,float mu,float* P)
{
    float WP[3];for(int i=0;i<3;++i)WP[i]=W[3*i]*Ps[0]+W[3*i+1]*Ps[1]+W[3*i+2]*Ps[2];
    auto value=[&](float t,float& l){const float d[3]={-1.0f,mu*cosf(t),mu*sinf(t)};
        float Wd[3];for(int i=0;i<3;++i)Wd[i]=W[3*i]*d[0]+W[3*i+1]*d[1]+W[3*i+2]*d[2];
        const float dWd=d[0]*Wd[0]+d[1]*Wd[1]+d[2]*Wd[2],dWP=d[0]*WP[0]+d[1]*WP[1]+d[2]*WP[2];
        l=dWd>0.0f?fmaxf(0.0f,dWP/dWd):0.0f;return 0.5f*l*l*dWd-l*dWP;};   // (P-Ps)^T W (P-Ps)/2 less a constant
    P[0]=P[1]=P[2]=0.0f;if(!(mu>0.0f)){const float l=W[0]>0.0f?fmaxf(0.0f,-WP[0]/W[0]):0.0f;P[0]=-l;return;}
    constexpr int kScan=16;float best=0.0f,tb=0.0f;   // P = 0: value 0
    const float t0=atan2f(Ps[2],Ps[1]);
    for(int k=0;k<kScan;++k){const float t=t0+6.2831853f*float(k)/float(kScan);float l;const float v=value(t,l);if(v<best){best=v;tb=t;}}
    if(best<0.0f) {
        float a=tb-6.2831853f/float(kScan),b=tb+6.2831853f/float(kScan);
        for(int it=0;it<24;++it){const float c=b-0.618034f*(b-a),e=a+0.618034f*(b-a);float l;if(value(c,l)<value(e,l))b=e;else a=c;}
        const float t=0.5f*(a+b);float l;if(value(t,l)<best){tb=t;}
        value(tb,l);P[0]=-l;P[1]=l*mu*cosf(tb);P[2]=l*mu*sinf(tb);
    }
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
    // Impactors and rows (one thread: at most kExRows rows).
    if(!threadIdx.x) {
        PxU32 n=chunkNodes,k=0,impactors=0;
        for(PxU32 j=0;j<nrows;++j) {
            const PxU32 r=list[j];
            const ContactRow& q=in.rows[r];const PxU32 sc=t.nodeOf[q.chunk];
            if(sc==0xffffffffu || (sc>>16)!=p)continue;
            PxU32 node=0xffffffffu;
            for(PxU32 e=0;e<k;++e)if(in.rows[exRows[e].row].body==q.body){node=exRows[e].b;break;}
            if(node==0xffffffffu) {
                if(n>=kExNodes){sp.failed=1;continue;}
                node=n++;++impactors;
                ExNode m{};m.chunk=in.chunkCount+p*kExNodes+node;m.tensor=1;m.im=q.im;for(int a=0;a<6;++a)m.Iinv[a]=q.ii[a];
                for(int a=0;a<3;++a){m.v[a]=q.velocity[a];m.v[3+a]=q.spin[a];}
                for(int a=0;a<6;++a)m.v0[a]=m.v[a];
                nodes[node]=m;
            }
            Bond b;prepareRow(in,s,r,b);b.c1=in.chunkCount+p*kExNodes+node;
            rowBonds[k]=b;ExRow e{};e.a=sc&0xffffu;e.b=node;e.row=r;exRows[k]=e;++k;
        }
        sp.nodes=n;sp.chunks=chunkNodes;sp.rows=k;sp.impactors=impactors;
    }
    __syncthreads();
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
            e.state=(b.flags&eALIVE)?(eEX_LIVE|((b.flags&eDUCTILE)?eEX_DUCTILE:0u)):0u;
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
                if(pass)for(PxU32 r=0;r<nr;++r)deg+=(exRows[r].a==k?1u:0u)+(exRows[r].b==k?1u:0u);
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
                    for(PxU32 r=0;r<nr;++r){if(exRows[r].a==k)rowAdj[at++]=r<<1;if(exRows[r].b==k)rowAdj[at++]=(r<<1)|1u;}
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
    for(PxU32 i=threadIdx.x;i<12*sp.links;i+=kThreads)wr[i]=0.0f;
    float u0=0.0f;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads){const ExLink& e=links[l];if(!(e.state&eEX_LIVE))continue;
        float k[6];exStiffness(bonds[l],k);for(int q=0;q<6;++q)if(k[q]>0.0f)u0+=0.5f*e.J0[q]*e.J0[q]/k[q];}
    u0=blockSum(sh,u0);
    if(!threadIdx.x){sp.u0=u0;sp.keIn=sp.keOut=sp.fracture=sp.plastic=sp.dead=0.0f;}
    // The largest frequency's square, bounded by Gershgorin's theorem on M^-1 K
    // and on its similar M^-1/2 K M^-1/2 (both upper bounds: the smaller holds).
    // Joints act on chunk nodes only (scalar inertia): M^-1 is diagonal there.
    float lambda=0.0f,lambdaSym=0.0f;
    for(PxU32 k=threadIdx.x;k<nn;k+=kThreads) {
        ExNode& n=nodes[k];float f[6]={0,0,0,0,0,0},g[6]={0,0,0,0,0,0},y[6]={0,0,0,0,0,0};
        for(PxU32 j=n.jointBegin;j<n.jointEnd;++j) {
            const PxU32 l=adj[j]>>1,end=adj[j]&1u;const ExLink& e=links[l];
            if(!(e.state&eEX_LIVE))continue;
            float minv[2][6]={};
            const PxU32 ends[2]={e.a,e.b};
            for(PxU32 m=0;m<2;++m)if(ends[m]!=0xffffffffu){const ExNode& o=nodes[ends[m]];for(int q=0;q<3;++q){minv[m][q]=o.im;minv[m][3+q]=o.Iinv[q];}}
            exWrench(bonds[l],e.J0,end,f);exGershgorin(bonds[l],e,end,minv,g,y);
        }
        for(int q=0;q<6;++q)n.f0[q]=-f[q];
        if(n.tensor)continue;
        for(int q=0;q<3;++q){
            lambda=fmaxf(lambda,fmaxf(n.im*g[q],n.Iinv[q]*g[3+q]));
            lambdaSym=fmaxf(lambdaSym,fmaxf(sqrtf(n.im)*y[q],sqrtf(n.Iinv[q])*y[3+q]));
        }
    }
    lambda=fminf(blockMax(sh,lambda),blockMax(sh,lambdaSym));
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
// - Each row lives in its thread's registers (geometry, W, W^-1, its impulse).
// - The dead load's work is the joints' (f0 . v = -sum J0 . B^T v), counted
//   where the joint phase already has B^T v.
template<bool Small> __device__ __forceinline__
void exRunT(Settings s,Scratch w,ExScratch t,PxU32 budget)
{
    constexpr PxU32 kV=Small?kExSmall:kExNodes,kN=Small?kExSmall:1u;
    __shared__ PxU32 shBroken,shYielded,shActive,shPushing,shNear;
    __shared__ float shFracture,shPlastic,shDead;
    __shared__ float vS[6*kV],imS[kN],iiS[3*kN];
    __shared__ PxU32 jS[kN],rS[kN];
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    ExPatch& sp=t.patches[p];if(sp.done)return;
    ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;ExLink* links=t.links+size_t(p)*kExLinks;
    const Bond* rowBonds=t.rowBonds+size_t(p)*kExRows;ExRow* rows=t.rows+size_t(p)*kExRows;
    const PxU32* adj=t.adj+size_t(p)*2*kExLinks;const PxU32* rowAdj=t.rowAdj+size_t(p)*2*kExRows;
    float* wr=t.wr+size_t(p)*kExLinks*12;float* rwr=t.rwr+size_t(p)*kExRows*12;
    const PxU32 nn=sp.nodes,nl=sp.links,nr=sp.rows;const float h=sp.h,T=s.dt;
    const PxU32 total=PxU32(ceilf(T/h-1e-4f));
    if(!threadIdx.x){shBroken=0;shYielded=0;shFracture=0.0f;shPlastic=0.0f;shDead=0.0f;}
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
    float W[9]={0,0,0,0,0,0,0,0,0},Winv[9]={0,0,0,0,0,0,0,0,0},tot[3]={0,0,0};PxU32 ra=0,rn=0;
    if(hasRow) {
        const Bond rb=rowBonds[threadIdx.x];const ExRow x=rows[threadIdx.x];ra=x.a;rn=x.b;for(int q=0;q<3;++q)tot[q]=x.total[q];
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
        for(int i=0;i<9;++i){Winv[i]=inv[i];rows[threadIdx.x].Winv[i]=inv[i];rows[threadIdx.x].W[i]=W[i];}
    }
    __syncthreads();
    PxU32 step=sp.substeps;float dead=0.0f;
    for(PxU32 it=0;it<budget && step<total;++it,++step) {
        const float time=float(step+1)*h;const bool last=step+1==total;
        // The window's end (Settings::explicitWindow 1): once no contact pushes, no
        // brittle joint is within the capacity band and no ductile one slips, no
        // event is under way; what remains (the dead load settling around the
        // damage) is the next tick's static verdict.
        if(!threadIdx.x){shActive=0u;shPushing=0u;shNear=0u;}
        // Joint forces on the nodes: each node gathers its joints' wrenches (no atomics).
        for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
            PxU32 b0,b1;jointRange(k,b0,b1);if(b0==b1)continue;
            float f[6]={0,0,0,0,0,0};
            for(PxU32 j=b0;j<b1;++j){const float* q=wr+6*size_t(adj[j]);for(int c=0;c<6;++c)f[c]+=q[c];}
            apply(k,f,h);
        }
        __syncthreads();
        // Contacts: each row's impulse from the same velocities (Jacobi), in the
        // Coulomb cone (exCone: sliding, never adding energy).
        if(hasRow) {
            const Bond rb=rowBonds[threadIdx.x];
            float g[6]={0,0,0,0,0,0};exRelative(rb,0,vS+6*ra,g);exRelative(rb,1,vS+6*rn,g);
            float Ps[3];for(int i=0;i<3;++i)Ps[i]=-(Winv[3*i]*g[0]+Winv[3*i+1]*g[1]+Winv[3*i+2]*g[2]);
            float P[3];exCone(rows[threadIdx.x].W,g,Ps,rb.area,P);
            for(int q=0;q<3;++q)tot[q]+=P[q];
            // Pushing: an impulse the impactor's momentum resolves in float (below
            // its float resolution it exchanges nothing representable).
            const float im=Small?imS[rn]:nodes[rn].im;
            const float pm=sqrtf(vS[6*rn]*vS[6*rn]+vS[6*rn+1]*vS[6*rn+1]+vS[6*rn+2]*vS[6*rn+2])/fmaxf(im,FLT_MIN);
            if(-P[0]>FLT_EPSILON*pm){shActive=1u;if(last)atomicAdd(&shPushing,1u);}
            const float x[6]={P[0],P[1],P[2],0,0,0};float f0[6]={0,0,0,0,0,0},f1[6]={0,0,0,0,0,0};
            exWrench(rb,x,0,f0);exWrench(rb,x,1,f1);float* o=rwr+12*size_t(threadIdx.x);for(int q=0;q<6;++q){o[q]=f0[q];o[6+q]=f1[q];}
        }
        __syncthreads();
        if(nr)for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
            PxU32 b0,b1;rowRange(k,b0,b1);if(b0==b1)continue;
            float f[6]={0,0,0,0,0,0};
            for(PxU32 j=b0;j<b1;++j){const float* q=rwr+6*size_t(rowAdj[j]);for(int c=0;c<6;++c)f[c]+=q[c];}
            apply(k,f,1.0f);
        }
        __syncthreads();
        // Joints: the trial, then fracture or the radial return; the force change's wrench on both ends.
        for(PxU32 l=threadIdx.x;l<nl;l+=kExThreads) {
            ExLink& e=links[l];if(!(e.state&eEX_LIVE))continue;
            const Bond b=bonds[l];   // in registers: every field is read more than once
            float d[6]={0,0,0,0,0,0};if(e.a!=0xffffffffu)exRelative(b,0,vS+6*e.a,d);if(e.b!=0xffffffffu)exRelative(b,1,vS+6*e.b,d);
            float J0[6];for(int q=0;q<6;++q)J0[q]=e.J0[q];
            for(int q=0;q<6;++q)dead-=h*J0[q]*d[q];
            float k[6];exStiffness(b,k);
            float J[6];for(int q=0;q<6;++q)J[q]=e.J[q]-h*k[q]*d[q];
            const float u=utilisation(b,J);
            // An event is near: a brittle joint within the band, a ductile one slipping.
            if((e.state&eEX_DUCTILE)?u>1.0f:u>=1.0f-s.capacityBand){shActive=1u;if(last)atomicAdd(&shNear,1u);}
            bool breaks=false;
            if(!(e.state&eEX_DUCTILE))breaks=u>=1.0f-s.capacityBand;
            else if(u>1.0f) {
                float slip=0.0f,work=0.0f;
                for(int q=0;q<6;++q){const float y=J[q]/u;if(k[q]>0.0f){const float dp=(J[q]-y)/k[q];if(q<3)slip+=dp*dp;work+=fabsf(y*dp);}J[q]=y;}
                e.slip+=sqrtf(slip);atomicAdd(&shPlastic,work);
                if(!(e.state&eEX_YIELDED)){e.state|=eEX_YIELDED;atomicAdd(&shYielded,1u);}
                breaks=e.slip>e.limit;
            }
            if(breaks){float u2=0.0f;for(int q=0;q<6;++q)if(k[q]>0.0f)u2+=0.5f*J[q]*J[q]/k[q];atomicAdd(&shFracture,u2);
                e.state=(e.state&~eEX_LIVE)|eEX_BROKEN;for(int q=0;q<6;++q)J[q]=0.0f;e.brokeAt=time;atomicAdd(&shBroken,1u);}
            for(int q=0;q<6;++q)e.J[q]=J[q];
            float dJ[6];for(int q=0;q<6;++q)dJ[q]=J[q]-J0[q];
            float* o=wr+12*size_t(l);float f0[6]={0,0,0,0,0,0},f1[6]={0,0,0,0,0,0};
            exWrench(b,dJ,0,f0);exWrench(b,dJ,1,f1);for(int q=0;q<6;++q){o[q]=f0[q];o[6+q]=f1[q];}
        }
        __syncthreads();
        if(s.explicitWindow==1u && !shActive){++step;sp.done=1;break;}
    }
    for(PxU32 i=threadIdx.x;i<6*nn;i+=kExThreads)nodes[i/6].v[i%6]=vS[i];
    if(hasRow){ExRow& x=rows[threadIdx.x];for(int q=0;q<3;++q)x.total[q]=tot[q];}
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
