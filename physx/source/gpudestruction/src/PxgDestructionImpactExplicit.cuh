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
//   v += M^-1 B_c P,  P = proj(-W^-1 B_c^T v)    every contact row at once (Jacobi)
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
constexpr PxU32 kExRows=128;       // contact rows per patch
constexpr PxU32 kExThreads=EX_THREADS;  // the window's threads per patch (one block)

struct ExPatch {
    PxU32 island,nodes,chunks,links,rows,impactors,substeps,done,broken,yielded,truncated,failed,seed,listed,bodies,pushing,near;
    float radius,h,t,omega;
};
// A joint of the patch: local node ends (0xffffffff: held), state bits.
enum ExState : PxU32 { eEX_LIVE=1, eEX_DUCTILE=2, eEX_YIELDED=4, eEX_BROKEN=8 };
struct ExLink { PxU32 a,b,state,pad; float J0[6],J[6]; float slip,limit,brokeAt,pad2; };
// A contact row: the struck chunk (a, local), the impactor (b), the stage's row.
struct ExRow { PxU32 a,b,row,pad; float P[3],total[3],Winv[9]; };
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
// The nodes' velocities live in threadgroup memory; each joint keeps the
// wrench of its force change on its two ends, B (J - J0) (t.wr), so a node
// gathers six floats a joint and never reads a joint's geometry.
__global__ __launch_bounds__(kExThreads) void exRun(Settings s,Scratch w,ExScratch t,PxU32 budget)
{
    __shared__ PxU32 shBroken,shYielded,shActive,shPushing,shNear;
    __shared__ float vS[6*kExNodes];
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    ExPatch& sp=t.patches[p];if(sp.done)return;
    ExNode* nodes=t.nodes+size_t(p)*kExNodes;const Bond* bonds=t.bonds+size_t(p)*kExLinks;ExLink* links=t.links+size_t(p)*kExLinks;
    const Bond* rowBonds=t.rowBonds+size_t(p)*kExRows;ExRow* rows=t.rows+size_t(p)*kExRows;
    const PxU32* adj=t.adj+size_t(p)*2*kExLinks;const PxU32* rowAdj=t.rowAdj+size_t(p)*2*kExRows;
    float* wr=t.wr+size_t(p)*kExLinks*12;
    const PxU32 nn=sp.nodes,nl=sp.links,nr=sp.rows;const float h=sp.h,T=s.dt;
    const PxU32 total=PxU32(ceilf(T/h-1e-4f));
    if(!threadIdx.x){shBroken=0;shYielded=0;}
    for(PxU32 i=threadIdx.x;i<6*nn;i+=kExThreads)vS[i]=nodes[i/6].v[i%6];
    // Each row's W^-1 (W = B_c^T M^-1 B_c over its three force components: fixed over the window).
    for(PxU32 r=threadIdx.x;r<nr;r+=kExThreads) {
        const Bond& b=rowBonds[r];ExRow& x=rows[r];float W[9]={0,0,0,0,0,0,0,0,0};
        for(PxU32 end=0;end<2;++end) {
            const ExNode& n=nodes[end?x.b:x.a];float col[3][6];
            for(int q=0;q<3;++q){float xq[6]={0,0,0,0,0,0};xq[q]=1.0f;float f[6]={0,0,0,0,0,0};exWrench(b,xq,end,f);exApplyInverse(n,f,col[q]);}
            for(int i=0;i<3;++i)for(int q=0;q<3;++q){float e6[6]={0,0,0,0,0,0};exRelative(b,end,col[q],e6);W[3*i+q]+=e6[i];}
        }
        const float det=W[0]*(W[4]*W[8]-W[5]*W[7])-W[1]*(W[3]*W[8]-W[5]*W[6])+W[2]*(W[3]*W[7]-W[4]*W[6]);
        const bool ok=det>0.0f && isfinite(det);const float id=ok?1.0f/det:0.0f;
        const float inv[9]={(W[4]*W[8]-W[5]*W[7])*id,(W[2]*W[7]-W[1]*W[8])*id,(W[1]*W[5]-W[2]*W[4])*id,
            (W[5]*W[6]-W[3]*W[8])*id,(W[0]*W[8]-W[2]*W[6])*id,(W[2]*W[3]-W[0]*W[5])*id,
            (W[3]*W[7]-W[4]*W[6])*id,(W[1]*W[6]-W[0]*W[7])*id,(W[0]*W[4]-W[1]*W[3])*id};
        for(int i=0;i<9;++i)x.Winv[i]=inv[i];
    }
    __syncthreads();
    PxU32 step=sp.substeps;
    for(PxU32 it=0;it<budget && step<total;++it,++step) {
        const float time=float(step+1)*h;
        // The window's end (Settings::explicitWindow 1): once no contact pushes, no
        // brittle joint is within the capacity band and no ductile one slips, no
        // event is under way; what remains (the dead load settling around the
        // damage) is the next tick's static verdict.
        if(!threadIdx.x){shActive=0u;shPushing=0u;shNear=0u;}
        // Joint forces on the nodes: each node gathers its joints' wrenches (no atomics).
        for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
            const ExNode& n=nodes[k];if(n.jointBegin==n.jointEnd)continue;
            float f[6]={0,0,0,0,0,0};
            for(PxU32 j=n.jointBegin;j<n.jointEnd;++j){const float* q=wr+6*size_t(adj[j]);for(int c=0;c<6;++c)f[c]+=q[c];}
            float dv[6];exApplyInverse(n,f,dv);for(int q=0;q<6;++q)vS[6*k+q]+=h*dv[q];
        }
        __syncthreads();
        // Contacts: each row's inelastic impulse from the same velocities (Jacobi).
        for(PxU32 r=threadIdx.x;r<nr;r+=kExThreads) {
            const Bond b=rowBonds[r];ExRow& x=rows[r];
            float g[6]={0,0,0,0,0,0};exRelative(b,0,vS+6*x.a,g);exRelative(b,1,vS+6*x.b,g);
            // P = -W^-1 g, then the cone: compression only (P_N <= 0), |P_T| <= mu |P_N|.
            float P[3];for(int i=0;i<3;++i)P[i]=-(x.Winv[3*i]*g[0]+x.Winv[3*i+1]*g[1]+x.Winv[3*i+2]*g[2]);
            if(P[0]>0.0f){P[0]=P[1]=P[2]=0.0f;}
            else{const float tn=sqrtf(P[1]*P[1]+P[2]*P[2]),lim=b.area*-P[0];if(tn>lim){const float f=lim/tn;P[1]*=f;P[2]*=f;}}
            for(int q=0;q<3;++q){x.P[q]=P[q];x.total[q]+=P[q];}
            // Pushing: an impulse the impactor's momentum resolves in float (below
            // its float resolution it exchanges nothing representable).
            {const ExNode& m=nodes[x.b];const float pm=sqrtf(vS[6*x.b]*vS[6*x.b]+vS[6*x.b+1]*vS[6*x.b+1]+vS[6*x.b+2]*vS[6*x.b+2])/fmaxf(m.im,FLT_MIN);
             if(-P[0]>FLT_EPSILON*pm){shActive=1u;atomicAdd(&shPushing,1u);}}
        }
        __syncthreads();
        if(nr)for(PxU32 k=threadIdx.x;k<nn;k+=kExThreads) {
            const ExNode& n=nodes[k];if(n.rowBegin==n.rowEnd)continue;
            float f[6]={0,0,0,0,0,0};
            for(PxU32 j=n.rowBegin;j<n.rowEnd;++j){const PxU32 r=rowAdj[j]>>1;const float x[6]={rows[r].P[0],rows[r].P[1],rows[r].P[2],0,0,0};exWrench(rowBonds[r],x,rowAdj[j]&1u,f);}
            float dv[6];exApplyInverse(n,f,dv);for(int q=0;q<6;++q)vS[6*k+q]+=dv[q];
        }
        __syncthreads();
        // Joints: the trial, then fracture or the radial return; the force change's wrench on both ends.
        for(PxU32 l=threadIdx.x;l<nl;l+=kExThreads) {
            ExLink& e=links[l];if(!(e.state&eEX_LIVE))continue;
            const Bond b=bonds[l];   // in registers: every field is read more than once
            float d[6]={0,0,0,0,0,0};if(e.a!=0xffffffffu)exRelative(b,0,vS+6*e.a,d);if(e.b!=0xffffffffu)exRelative(b,1,vS+6*e.b,d);
            float k[6];exStiffness(b,k);
            float J[6];for(int q=0;q<6;++q)J[q]=e.J[q]-h*k[q]*d[q];
            const float u=utilisation(b,J);
            // An event is near: a brittle joint within the band, a ductile one slipping.
            if((e.state&eEX_DUCTILE)?u>1.0f:u>=1.0f-s.capacityBand){shActive=1u;atomicAdd(&shNear,1u);}
            bool breaks=false;
            if(!(e.state&eEX_DUCTILE))breaks=u>=1.0f-s.capacityBand;
            else if(u>1.0f) {
                float slip=0.0f;
                for(int q=0;q<6;++q){const float y=J[q]/u;if(q<3 && k[q]>0.0f){const float dp=(J[q]-y)/k[q];slip+=dp*dp;}J[q]=y;}
                e.slip+=sqrtf(slip);
                if(!(e.state&eEX_YIELDED)){e.state|=eEX_YIELDED;atomicAdd(&shYielded,1u);}
                breaks=e.slip>e.limit;
            }
            if(breaks){e.state=(e.state&~eEX_LIVE)|eEX_BROKEN;for(int q=0;q<6;++q)J[q]=0.0f;e.brokeAt=time;atomicAdd(&shBroken,1u);}
            for(int q=0;q<6;++q)e.J[q]=J[q];
            float dJ[6];for(int q=0;q<6;++q)dJ[q]=J[q]-e.J0[q];
            float* o=wr+12*size_t(l);float f0[6]={0,0,0,0,0,0},f1[6]={0,0,0,0,0,0};
            exWrench(b,dJ,0,f0);exWrench(b,dJ,1,f1);for(int q=0;q<6;++q){o[q]=f0[q];o[6+q]=f1[q];}
        }
        __syncthreads();
        if(s.explicitWindow==1u && !shActive){++step;sp.done=1;break;}
    }
    for(PxU32 i=threadIdx.x;i<6*nn;i+=kExThreads)nodes[i/6].v[i%6]=vS[i];
    __syncthreads();
    if(!threadIdx.x){sp.substeps=step;sp.t=float(step)*h;sp.broken+=shBroken;sp.yielded+=shYielded;sp.pushing=shPushing;sp.near=shNear;if(step>=total)sp.done=1;}
}

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
