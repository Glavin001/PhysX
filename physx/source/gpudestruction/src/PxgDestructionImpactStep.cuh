// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// The impact step (Settings::method eSTEP; docs/destruction/IMPACT_CHEAP_FORMULATION.md):
// one implicit dynamic step over the contact duration h on a local patch of
// the struck island, the impactor coupled as a node carrying its momentum,
// with an exact event-to-event failure order. Included inside namespace
// impact, after the impact solve's helpers (Bond, prepareBond, prepareRow,
// impactorNode, utilisation, addWrench) and before Stage.
//
// The step: (M + h^2 B K B^T) du = lam f, f = p / h on each impactor node (p
// its momentum before the tick), the impactor tied to its struck chunks by
// rigid contact rows (unilateral; sticking inside the Coulomb cone, then
// sliding frictionless): A du + C l = lam f, C^T du = 0. Joint forces J = J0 +
// dJ, dJ = -k h^2 B^T du (J0 the forces before the tick); a contact's force
// is -l. Velocities over the step: du h.
// Failure order: between events the system is linear, so every joint's
// critical load factor along the current increment is the root of
// util(J + d dJ) = 1 (util convex); advance to the smallest; a brittle joint
// breaks and its force is released as a load at the same lam (re-solved,
// cascading while anything is past capacity), a ductile one yields (leaves
// the operator, keeps its force), a contact separates or starts to slide.
// To lam = 1; then a yielded joint past its ultimate slip, 1/2 |B^T u| h^2,
// breaks.
// The patch: the island's chunks within Settings::stepRadius of a struck
// chunk; the rest of the island is held as boundary. A is inverted
// explicitly (Gauss-Jordan, one launch per pivot over all patches), and each
// event changes it by a joint's rank-6 term (Sherman-Morrison-Woodbury), so
// a solve is a matrix-vector product.

constexpr PxU32 kStepPatches=4;      // patches (struck islands) per evaluation
// Chunks and impactors per patch (a 3 m patch of the veneer house: ~300; larger
// ones shrink their radius). The dispatch bound: a launch does at most one
// ramp action, up to 8 passes over the dense A^-1 by one block; at 384 nodes
// (n = 2304) that reached 140-207 ms on a shared GPU (the meteor and truck
// trials), over the 100 ms rule; 256 (n = 1536) is 2.25x less per pass.
constexpr PxU32 kStepNodes=256;
constexpr PxU32 kStepDof=6*kStepNodes;
constexpr PxU32 kStepLinks=3072;     // joints and contact rows per patch
constexpr PxU32 kStepCols=192;       // contact constraint columns per patch (3 a sticking row, 1 a sliding one)

enum StepPhase : PxU32 { eSTEP_RAMP=0, eSTEP_DONE=1 };
struct StepPatch {
    PxU32 island,nodes,links,joints,contacts,cols,phase,events,solves,broken,yielded,truncated,failed,impactors,restOver,cascade;
    float lam,h,radius;
};
struct StepLink { PxU32 a,b,state,pad; };   // local node ends (0xffffffff: held), state bits below
enum StepLinkState : PxU32 { eSL_LIVE=1, eSL_YIELDED=2, eSL_CONTACT=4, eSL_SLIDE=8, eSL_OFF=16, eSL_BROKEN=32 };

struct StepScratch {
    PxU32* nodeOf{};      // [chunkCount + kStepPatches*kStepNodes] patch << 16 | local, or ~0
    PxU32* patchCount{};  // [1]
    StepPatch* patches{}; // [kStepPatches]
    PxU32* nodeChunk{};   // [P][kStepNodes] chunk id (impactors: chunkCount + p*kStepNodes + k)
    float* nodeMass{};    // [P][kStepNodes][7]: 1/m, I (xx yy zz xy xz yz) (scalar chunks: I in xx yy zz)
    Bond* links{};        // [P][kStepLinks]
    StepLink* linkEnds{}; // [P][kStepLinks]
    float* B{};           // [P][kStepLinks][72]: the wrench blocks on end a, end b (column q: unit force q)
    float* Ainv{};        // [P][kStepDof^2], and Atmp the same (Gauss-Jordan ping-pong)
    float* Atmp{};
    float* G{};           // [P][kStepDof][kStepCols]: A^-1 C
    float* S{};           // [P][kStepCols^2]: (C^T A^-1 C)^-1
    PxU32* colLink{};     // [P][kStepCols]: link << 2 | component
    float* J{};float* dJ{};float* J2{};    // [P][kStepLinks][6]
    float* f{};float* w{};float* du{};float* u{};float* d2{};float* rhs{};   // [P][kStepDof]
    float* lam{};         // [P][kStepCols] contact multipliers
    PxU32* rowNode{};     // [kContactCapacity] each row's impactor node (local)
    float* panelP{};      // [P][32*32]   blocked Gauss-Jordan: the panel's pivot block inverse
    float* panelV{};      // [P][kStepDof*32] the panel's columns
    float* panelW{};      // [P][32*kStepDof] the panel's rows times P
    float* scale{};       // [P][kStepDof] Jacobi scaling, 1 / sqrt(A_ii)
};
constexpr PxU32 kPanel=32;

__device__ __forceinline__ float* stepA(const StepScratch& w,PxU32 p){return w.Ainv+size_t(p)*kStepDof*kStepDof;}

// A link's wrench on its ends' 6-dof from a bond-frame force x: out[a] += Ba x, out[b] += Bb x.
__device__ __forceinline__ void stepScatter(const float* Bl,const StepLink& e,const float* x,float* out,float scale=1.0f)
{
    for(int r=0;r<6;++r) {
        float sa=0.0f,sb=0.0f;for(int q=0;q<6;++q){sa+=Bl[6*r+q]*x[q];sb+=Bl[36+6*r+q]*x[q];}
        if(e.a!=0xffffffffu)atomicAdd(out+6*e.a+r,scale*sa);
        if(e.b!=0xffffffffu)atomicAdd(out+6*e.b+r,scale*sb);
    }
}
// B^T v for one link: the relative motion its joint feels (bond frame).
__device__ __forceinline__ void stepGather(const float* Bl,const StepLink& e,const float* v,float* x)
{
    for(int q=0;q<6;++q) {
        float s=0.0f;
        if(e.a!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[6*r+q]*v[6*e.a+r];
        if(e.b!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[36+6*r+q]*v[6*e.b+r];
        x[q]=s;
    }
}
__device__ __forceinline__ void stepStiffness(const Bond& b,float h,float* c)
{
    const float k[6]={b.kl,b.kl,b.kl,b.kt,b.k0,b.k1};
    for(int q=0;q<6;++q)c[q]=(k[q]>0.0f && k[q]<1e30f)?k[q]*h*h:0.0f;
}

// A row the step takes: any pair of an impactor with a live chunk of the
// island, closing or not (a released pair -- the impactor receding, deep in
// a thin chunk -- is a unilateral contact that separates): every impactor
// contact on the island is the step's, none is the static solve's load.
__device__ __forceinline__ bool stepRow(const Inputs& in,PxU32 r,PxU32 island)
{
    const ContactRow& row=in.rows[r];
    if(row.chunk>=in.chunkCount || in.nodeIslands[row.chunk]!=island || !(in.chunks[row.chunk].mass>0.0f) || chunkGone(in,row.chunk))return false;
    if(in.rowRouted && !in.rowRouted[r])return false;   // a static load (Settings::route)
    if(row.resting&1u)return false;
    return row.im>0.0f && isfinite(row.im);
}
// 1. The patches: one per island with a coupled row, seeded by its struck
// chunks; nodes within the radius (shrunk until they fit), the impactors,
// the links (joints with an end on the patch; the contact rows).
__global__ __launch_bounds__(kThreads) void stepBuild(Inputs in,Settings s,Scratch w,StepScratch t)
{
    __shared__ Shared sh;
    if(blockIdx.x)return;
    const PxU32 rows=in.rows?(in.rowCounter?min(*in.rowCounter,in.rowCount):in.rowCount):0u;
    // The islands to solve, in row order (deterministic): each row's struck island once.
    for(PxU32 r=0;r<rows;++r) {
        if(!stepRow(in,r,in.nodeIslands[in.rows[r].chunk<in.chunkCount?in.rows[r].chunk:0]))continue;
        const PxU32 island=in.nodeIslands[in.rows[r].chunk];
        PxU32 seen=0;for(PxU32 p=0;p<*t.patchCount;++p)seen|=t.patches[p].island==island?1u:0u;
        if(seen)continue;
        if(*t.patchCount>=kStepPatches){if(!threadIdx.x)atomicOr(&w.status->error,1u);continue;}
        __syncthreads();
        const PxU32 p=*t.patchCount;
        __syncthreads();
        if(!threadIdx.x){StepPatch sp{};sp.island=island;sp.h=s.stepDuration;sp.radius=s.stepRadius;t.patches[p]=sp;*t.patchCount=p+1;}
        __syncthreads();
        // Radius: shrink until the island's chunks within it fit.
        float radius=s.stepRadius;PxU32 count=0;
        for(int attempt=0;attempt<32;++attempt) {
            PxU32 c=0;
            for(PxU32 i=threadIdx.x;i<in.chunkCount;i+=kThreads) {
                if(in.nodeIslands[i]!=island || !(in.chunks[i].mass>0.0f) || chunkGone(in,i))continue;
                const PxVec3 x=in.chunks[i].position;bool near=false;
                for(PxU32 r2=0;r2<rows && !near;++r2){const ContactRow& q=in.rows[r2];if(!stepRow(in,r2,island))continue;
                    near=(x-in.chunks[q.chunk].position).magnitude()<=radius;}
                c+=near?1u:0u;
            }
            count=blockCount(sh,c);
            // room for the impactors (one per row at most)
            if(count+min(rows,32u)<=kStepNodes)break;
            radius*=0.85f;
        }
        if(!threadIdx.x){t.patches[p].radius=radius;if(radius<s.stepRadius)t.patches[p].truncated=1;}
        // Nodes (chunk order).
        if(!threadIdx.x)sh.flag=0;
        __syncthreads();
        for(PxU32 tile=0;tile<in.chunkCount;tile+=kThreads) {
            const PxU32 i=tile+threadIdx.x;PxU32 member=0;
            if(i<in.chunkCount && in.nodeIslands[i]==island && in.chunks[i].mass>0.0f && !chunkGone(in,i)) {
                const PxVec3 x=in.chunks[i].position;
                for(PxU32 r2=0;r2<rows && !member;++r2){const ContactRow& q=in.rows[r2];if(!stepRow(in,r2,island))continue;
                    member=(x-in.chunks[q.chunk].position).magnitude()<=radius?1u:0u;}
            }
            PxU32 prefix;const PxU32 total=blockScan(sh,member,prefix);
            if(member){const PxU32 k=sh.flag+prefix;t.nodeChunk[p*kStepNodes+k]=i;t.nodeOf[i]=(p<<16)|k;
                const auto c=in.chunks[i];float* m=t.nodeMass+size_t(p*kStepNodes+k)*7;
                m[0]=1.0f/c.mass;m[1]=m[2]=m[3]=c.inertia;m[4]=m[5]=m[6]=0.0f;}
            __syncthreads();if(!threadIdx.x)sh.flag+=total;__syncthreads();
        }
        PxU32 nodes=sh.flag;
        // Impactors: one node per body, in the order of its first row.
        if(!threadIdx.x) {
            PxU32 links=0,impactors=0;
            for(PxU32 r2=0;r2<rows;++r2) {
                if(!stepRow(in,r2,island))continue;
                const ContactRow& q=in.rows[r2];
                PxU32 node=0xffffffffu;
                for(PxU32 e=0;e<r2;++e)if(stepRow(in,e,island) && in.rows[e].body==q.body){node=t.rowNode[e];break;}
                if(node==0xffffffffu && nodes<kStepNodes) {
                    node=nodes++;++impactors;const PxU32 id=in.chunkCount+p*kStepNodes+node;
                    t.nodeChunk[p*kStepNodes+node]=id;
                    const Chunk c=impactorNode(in,s,r2,id);float* m=t.nodeMass+size_t(p*kStepNodes+node)*7;
                    m[0]=c.im;for(int a=0;a<6;++a)m[1+a]=c.I[a];
                    // Its load over the step: its momentum before the tick over h (linear).
                    float* f=t.f+size_t(p)*kStepDof+6*node;for(int a=0;a<3;++a)f[a]=c.pf[a]*s.dt/s.stepDuration;
                }
                t.rowNode[r2]=node;
                // The contact row as a link (its node ends: the struck chunk, the impactor).
                const PxU32 sc=t.nodeOf[q.chunk];
                if(links<kStepLinks && node!=0xffffffffu && sc!=0xffffffffu && (sc>>16)==p) {
                    Bond b;prepareRow(in,s,r2,b);b.c1=in.chunkCount+p*kStepNodes+node;
                    t.links[p*kStepLinks+links]=b;t.linkEnds[p*kStepLinks+links]={sc&0xffffu,node,eSL_LIVE|eSL_CONTACT,r2};
                    ++links;
                }
            }
            t.patches[p].contacts=links;t.patches[p].impactors=impactors;
            sh.count=links;
        }
        __syncthreads();
        nodes=0;if(!threadIdx.x)sh.base=0;
        __syncthreads();
        // Joints with an end on the patch (each once: from its first patch end).
        for(PxU32 k=0;k<kStepNodes;++k) {
            const PxU32 c=t.nodeChunk[p*kStepNodes+k];
            if(k>=kStepNodes || c>=in.chunkCount)break;
            for(PxU32 slot=in.nodeBegin[c]+threadIdx.x;slot<in.nodeBegin[c+1];slot+=kThreads) {
                const PxU32 i=in.nodeRefs[slot];if(!bondMember(in,i))continue;
                const auto bd=in.bonds[i];const PxU32 other=bd.chunk0==c?bd.chunk1:bd.chunk0;
                const PxU32 lo=t.nodeOf[other];const bool otherOn=lo!=0xffffffffu && (lo>>16)==p;
                if(otherOn && (lo&0xffffu)<k)continue;   // counted from its other end
                Bond b;if(!prepareBond(in,s,i,b))continue;
                const PxU32 l=atomicAdd(&sh.count,1u);if(l>=kStepLinks){atomicOr(&t.patches[p].failed,1u);continue;}
                const PxU32 a0=t.nodeOf[b.c0],a1=t.nodeOf[b.c1];
                StepLink e{(a0!=0xffffffffu && (a0>>16)==p)?(a0&0xffffu):0xffffffffu,(a1!=0xffffffffu && (a1>>16)==p)?(a1&0xffffu):0xffffffffu,eSL_LIVE,i};
                t.links[p*kStepLinks+l]=b;t.linkEnds[p*kStepLinks+l]=e;
            }
            __syncthreads();
        }
        if(!threadIdx.x){t.patches[p].links=min(sh.count,kStepLinks);t.patches[p].joints=t.patches[p].links-t.patches[p].contacts;
            PxU32 n=0;for(PxU32 k=0;k<kStepNodes;++k)if(t.nodeChunk[p*kStepNodes+k]!=0xffffffffu)n=k+1;t.patches[p].nodes=n;}
        __syncthreads();
    }
}

// 2. Each link's wrench blocks, and A = M + h^2 sum B K B^T assembled.
__global__ void stepAssemble(Inputs in,Settings s,Scratch w,StepScratch t)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const StepPatch& sp=t.patches[p];const PxU32 n=6*sp.nodes;float* A=stepA(t,p);
    for(PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;i<n*n;i+=gridDim.x*blockDim.x)A[i]=0.0f;
    // (the diagonal mass after a grid-wide pass: a second kernel would be
    // cleaner; one block per patch writes M below once the zeroing is done)
}
__global__ void stepAssemble2(Inputs in,Settings s,Scratch w,StepScratch t)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const StepPatch& sp=t.patches[p];const PxU32 n=6*sp.nodes;float* A=stepA(t,p);
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    for(PxU32 k=tid;k<sp.nodes;k+=stride) {
        const float* m=t.nodeMass+size_t(p*kStepNodes+k)*7;const PxU32 o=6*k;
        // atomically: the links below add to the same diagonal blocks concurrently
        for(int a=0;a<3;++a)atomicAdd(A+size_t(o+a)*n+o+a,1.0f/m[0]);
        const bool tensor=t.nodeChunk[p*kStepNodes+k]>=in.chunkCount;
        if(tensor){const int idx[3][3]={{1,4,5},{4,2,6},{5,6,3}};for(int a=0;a<3;++a)for(int b=0;b<3;++b)atomicAdd(A+size_t(o+3+a)*n+o+3+b,m[idx[a][b]]);}
        else for(int a=0;a<3;++a)atomicAdd(A+size_t(o+3+a)*n+o+3+a,m[1+a]);
    }
    for(PxU32 l=tid;l<sp.links;l+=stride) {
        const Bond& b=t.links[p*kStepLinks+l];const StepLink& e=t.linkEnds[p*kStepLinks+l];float* Bl=t.B+(size_t(p)*kStepLinks+l)*72;
        for(int q=0;q<6;++q){float x[6]={0,0,0,0,0,0};x[q]=1.0f;float r0[6]={0,0,0,0,0,0},r1[6]={0,0,0,0,0,0};
            addWrench(b,x,true,r0);addWrench(b,x,false,r1);for(int r=0;r<6;++r){Bl[6*r+q]=r0[r];Bl[36+6*r+q]=r1[r];}}
        if(e.state&eSL_CONTACT)continue;
        float c[6];stepStiffness(b,sp.h,c);
        const PxU32 ends[2]={e.a,e.b};
        for(int ea=0;ea<2;++ea)for(int eb=0;eb<2;++eb) {
            if(ends[ea]==0xffffffffu || ends[eb]==0xffffffffu)continue;
            const float* Ba=Bl+36*ea;const float* Bb=Bl+36*eb;
            for(int r=0;r<6;++r)for(int cc=0;cc<6;++cc){float v=0.0f;for(int q=0;q<6;++q)v+=Ba[6*r+q]*c[q]*Bb[6*cc+q];
                if(v!=0.0f)atomicAdd(A+size_t(6*ends[ea]+r)*n+6*ends[eb]+cc,v);}
        }
    }
}
// 3. Gauss-Jordan in place, one pivot per launch (all patches): out = f(in).
__global__ void stepPivot(StepScratch t,PxU32 k)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const PxU32 n=6*t.patches[p].nodes;if(k>=n)return;
    const float* A=(k&1u)?t.Atmp+size_t(p)*kStepDof*kStepDof:stepA(t,p);
    float* O=(k&1u)?stepA(t,p):t.Atmp+size_t(p)*kStepDof*kStepDof;
    const float pivot=A[size_t(k)*n+k],inv=1.0f/pivot;
    for(PxU32 idx=blockIdx.x*blockDim.x+threadIdx.x;idx<n*n;idx+=gridDim.x*blockDim.x) {
        const PxU32 i=idx/n,j=idx%n;float v;
        if(i==k && j==k)v=inv;
        else if(i==k)v=A[size_t(k)*n+j]*inv;
        else if(j==k)v=-A[size_t(i)*n+k]*inv;
        else v=A[idx]-A[size_t(i)*n+k]*A[size_t(k)*n+j]*inv;
        O[idx]=v;
    }
}
// Blocked Gauss-Jordan (in place, SPD, no pivoting), a panel of kPanel
// pivots K per two launches: P = A_KK^-1, W = P A_K*, V = A_*K; then
// A_RR -= V W, A_RK = -V P, A_KR = W, A_KK = P.
__global__ __launch_bounds__(kThreads) void stepPanelA(StepScratch t,PxU32 k0)
{
    const PxU32 p=blockIdx.x;if(p>=*t.patchCount)return;
    const PxU32 n=6*t.patches[p].nodes;if(k0>=n)return;
    const PxU32 b=min(kPanel,n-k0);const float* A=stepA(t,p);
    __shared__ float M[kPanel*kPanel],R[kPanel*kPanel];
    for(PxU32 idx=threadIdx.x;idx<kPanel*kPanel;idx+=kThreads){const PxU32 i=idx/kPanel,j=idx%kPanel;
        M[idx]=(i<b && j<b)?A[size_t(k0+i)*n+k0+j]:(i==j?1.0f:0.0f);R[idx]=i==j?1.0f:0.0f;}
    __syncthreads();
    for(PxU32 k=0;k<b;++k) {
        const float inv=1.0f/M[k*kPanel+k];
        __syncthreads();
        if(threadIdx.x<kPanel){M[k*kPanel+threadIdx.x]*=inv;R[k*kPanel+threadIdx.x]*=inv;}
        __syncthreads();
        // eliminate column k from the other rows (two arrays: read the factors first)
        float fi=0.0f;const PxU32 row=threadIdx.x;
        if(row<kPanel && row!=k)fi=M[row*kPanel+k];
        __syncthreads();
        if(row<kPanel && row!=k)for(PxU32 j=0;j<kPanel;++j){M[row*kPanel+j]-=fi*M[k*kPanel+j];R[row*kPanel+j]-=fi*R[k*kPanel+j];}
        __syncthreads();
    }
    float* P=t.panelP+size_t(p)*kPanel*kPanel;
    for(PxU32 idx=threadIdx.x;idx<kPanel*kPanel;idx+=kThreads)P[idx]=R[idx];
    float* V=t.panelV+size_t(p)*kStepDof*kPanel;float* W=t.panelW+size_t(p)*kPanel*kStepDof;
    for(PxU32 idx=threadIdx.x;idx<n*kPanel;idx+=kThreads){const PxU32 i=idx/kPanel,s2=idx%kPanel;V[idx]=s2<b?A[size_t(i)*n+k0+s2]:0.0f;}
    for(PxU32 idx=threadIdx.x;idx<kPanel*n;idx+=kThreads){const PxU32 r=idx/n,j=idx%n;float v=0.0f;
        if(r<b)for(PxU32 s2=0;s2<b;++s2)v+=R[r*kPanel+s2]*A[size_t(k0+s2)*n+j];W[idx]=v;}
}
// Jacobi scaling around the inversion: A's diagonal spans the rotational
// inertia of a light chunk (0.03 kg m^2) to a stiff joint's k h^2 |o|^2
// (1e5): unscaled, float Gauss-Jordan loses the inverse's sign.
__global__ void stepScale(StepScratch t,PxU32 back)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const PxU32 n=6*t.patches[p].nodes;float* A=stepA(t,p);float* d=t.scale+size_t(p)*kStepDof;
    if(!back){for(PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;i<n;i+=gridDim.x*blockDim.x)d[i]=rsqrtf(A[size_t(i)*n+i]);return;}
    for(PxU32 idx=blockIdx.x*blockDim.x+threadIdx.x;idx<n*n;idx+=gridDim.x*blockDim.x){const PxU32 i=idx/n,j=idx%n;A[idx]*=d[i]*d[j];}
}
// One 32 x 32 tile of A per block (its panel rows of V and columns of W in
// shared memory: two reads an element, not 64).
__global__ __launch_bounds__(kThreads) void stepPanelB(StepScratch t,PxU32 k0)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const PxU32 n=6*t.patches[p].nodes;if(k0>=n)return;
    const PxU32 tiles=(n+kPanel-1)/kPanel;
    const PxU32 b=min(kPanel,n-k0);float* A=stepA(t,p);
    const float* P=t.panelP+size_t(p)*kPanel*kPanel;const float* V=t.panelV+size_t(p)*kStepDof*kPanel;const float* W=t.panelW+size_t(p)*kPanel*kStepDof;
    __shared__ float sV[kPanel*kPanel],sW[kPanel*kPanel],sP[kPanel*kPanel];
    for(PxU32 i=threadIdx.x;i<kPanel*kPanel;i+=kThreads)sP[i]=P[i];
    for(PxU32 tile=blockIdx.x;tile<tiles*tiles;tile+=gridDim.x) {
        const PxU32 ti=tile/tiles,tj=tile%tiles,i0=ti*kPanel,j0=tj*kPanel;
        __syncthreads();
        for(PxU32 e=threadIdx.x;e<kPanel*kPanel;e+=kThreads){const PxU32 r=e/kPanel,c=e%kPanel;
            sV[e]=(i0+r<n)?V[size_t(i0+r)*kPanel+c]:0.0f;sW[e]=(j0+c<n)?W[size_t(r)*n+j0+c]:0.0f;}
        __syncthreads();
        for(PxU32 e=threadIdx.x;e<kPanel*kPanel;e+=kThreads) {
            const PxU32 r=e/kPanel,c=e%kPanel,i=i0+r,j=j0+c;if(i>=n || j>=n)continue;
            const bool ik=i>=k0 && i<k0+b,jk=j>=k0 && j<k0+b;
            float v;
            if(ik && jk)v=sP[(i-k0)*kPanel+(j-k0)];
            else if(ik)v=sW[(i-k0)*kPanel+c];
            else if(jk){v=0.0f;for(PxU32 s2=0;s2<b;++s2)v-=sV[r*kPanel+s2]*sP[s2*kPanel+(j-k0)];}
            else{v=A[size_t(i)*n+j];for(PxU32 s2=0;s2<b;++s2)v-=sV[r*kPanel+s2]*sW[s2*kPanel+c];}
            A[size_t(i)*n+j]=v;
        }
    }
}
// After an odd number of pivots the result is in Atmp: copy back.
__global__ void stepSettle(StepScratch t)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const PxU32 n=6*t.patches[p].nodes;if(!(n&1u))return;
    const float* A=t.Atmp+size_t(p)*kStepDof*kStepDof;float* O=stepA(t,p);
    for(PxU32 idx=blockIdx.x*blockDim.x+threadIdx.x;idx<n*n;idx+=gridDim.x*blockDim.x)O[idx]=A[idx];
}

// --- The ramp, one block per patch --------------------------------------
// y = A^-1 x (dense, in place of a solve).
__device__ void stepApply(const StepScratch& t,PxU32 p,PxU32 n,const float* x,float* y)
{
    const float* A=stepA(t,p);
    for(PxU32 i=threadIdx.x;i<n;i+=kThreads){float s=0.0f;const float* row=A+size_t(i)*n;for(PxU32 j=0;j<n;++j)s+=row[j]*x[j];y[i]=s;}
    __syncthreads();
}
// The contact columns of the current contact set; G = A^-1 C; S = (C^T G)^-1.
__device__ void stepContacts(Shared& sh,const StepScratch& t,PxU32 p)
{
    StepPatch& sp=t.patches[p];const PxU32 n=6*sp.nodes;
    if(!threadIdx.x) {
        PxU32 cols=0;
        for(PxU32 l=0;l<sp.links;++l){const StepLink& e=t.linkEnds[p*kStepLinks+l];
            if(!(e.state&eSL_CONTACT) || (e.state&eSL_OFF))continue;
            const PxU32 m=(e.state&eSL_SLIDE)?1u:3u;
            for(PxU32 q=0;q<m && cols<kStepCols;++q)t.colLink[p*kStepCols+cols++]=(l<<2)|q;}
        sp.cols=cols;
    }
    __syncthreads();
    const PxU32 nc=sp.cols;float* G=t.G+size_t(p)*kStepDof*kStepCols;const float* A=stepA(t,p);
    // G[:,c] = A^-1 C[:,c]; C[:,c] is the link's wrench of a unit force (component q), nonzero on its two nodes.
    for(PxU32 idx=threadIdx.x;idx<n*nc;idx+=kThreads) {
        const PxU32 i=idx/nc,c=idx%nc,cl=t.colLink[p*kStepCols+c],l=cl>>2,q=cl&3u;
        const StepLink& e=t.linkEnds[p*kStepLinks+l];const float* Bl=t.B+(size_t(p)*kStepLinks+l)*72;
        float s=0.0f;
        if(e.a!=0xffffffffu)for(int r=0;r<6;++r)s+=A[size_t(i)*n+6*e.a+r]*Bl[6*r+q];
        if(e.b!=0xffffffffu)for(int r=0;r<6;++r)s+=A[size_t(i)*n+6*e.b+r]*Bl[36+6*r+q];
        G[size_t(i)*kStepCols+c]=s;
    }
    __syncthreads();
    // S = C^T G, then inverted in place (Gauss-Jordan; SPD).
    float* S=t.S+size_t(p)*kStepCols*kStepCols;
    for(PxU32 idx=threadIdx.x;idx<nc*nc;idx+=kThreads) {
        const PxU32 a=idx/nc,c=idx%nc,cl=t.colLink[p*kStepCols+a],l=cl>>2,q=cl&3u;
        const StepLink& e=t.linkEnds[p*kStepLinks+l];const float* Bl=t.B+(size_t(p)*kStepLinks+l)*72;
        float s=0.0f;
        if(e.a!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[6*r+q]*G[size_t(6*e.a+r)*kStepCols+c];
        if(e.b!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[36+6*r+q]*G[size_t(6*e.b+r)*kStepCols+c];
        S[size_t(a)*kStepCols+c]=s;
    }
    __syncthreads();
    // Rigid contacts can be redundant (two rows of one pair, or a pair's
    // rows over-constraining it): S is then singular. The inverse is taken
    // of S + e I, e the float resolution of its largest diagonal entry (no
    // physical compliance: the smallest that keeps it finite).
    if(!threadIdx.x){float big=0.0f;for(PxU32 k=0;k<nc;++k)big=fmaxf(big,fabsf(S[size_t(k)*kStepCols+k]));
        for(PxU32 k=0;k<nc;++k)S[size_t(k)*kStepCols+k]+=16.0f*FLT_EPSILON*big;}
    __syncthreads();
    for(PxU32 k=0;k<nc;++k) {
        const float inv=1.0f/S[size_t(k)*kStepCols+k];
        __syncthreads();
        for(PxU32 idx=threadIdx.x;idx<nc*nc;idx+=kThreads){const PxU32 i=idx/nc,j=idx%nc;
            if(i!=k && j!=k)S[size_t(i)*kStepCols+j]-=S[size_t(i)*kStepCols+k]*S[size_t(k)*kStepCols+j]*inv;}
        __syncthreads();
        for(PxU32 idx=threadIdx.x;idx<nc;idx+=kThreads){if(idx!=k){S[size_t(idx)*kStepCols+k]*=-inv;S[size_t(k)*kStepCols+idx]*=inv;}}
        __syncthreads();
        if(!threadIdx.x)S[size_t(k)*kStepCols+k]=inv;
        __syncthreads();
    }
    (void)sh;
}
// One solve: du = A^-1 (x - C l), C^T du = 0; dJ for every link (joints: -k h^2 B^T du; contacts: -l).
__device__ void stepSolve(Shared& sh,const StepScratch& t,PxU32 p,const float* x,float* du,float* dJ)
{
    StepPatch& sp=t.patches[p];const PxU32 n=6*sp.nodes,nc=sp.cols;
    float* w=t.w+size_t(p)*kStepDof;float* lam=t.lam+size_t(p)*kStepCols;
    const float* G=t.G+size_t(p)*kStepDof*kStepCols;const float* S=t.S+size_t(p)*kStepCols*kStepCols;
    stepApply(t,p,n,x,w);
    // y = C^T w; l = S y
    float* y=t.rhs+size_t(p)*kStepDof;   // scratch (nc <= kStepCols)
    for(PxU32 c=threadIdx.x;c<nc;c+=kThreads) {
        const PxU32 cl=t.colLink[p*kStepCols+c],l=cl>>2,q=cl&3u;const StepLink& e=t.linkEnds[p*kStepLinks+l];const float* Bl=t.B+(size_t(p)*kStepLinks+l)*72;
        float s=0.0f;if(e.a!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[6*r+q]*w[6*e.a+r];if(e.b!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[36+6*r+q]*w[6*e.b+r];
        y[c]=s;
    }
    __syncthreads();
    for(PxU32 c=threadIdx.x;c<nc;c+=kThreads){float s=0.0f;for(PxU32 d=0;d<nc;++d)s+=S[size_t(c)*kStepCols+d]*y[d];lam[c]=s;}
    __syncthreads();
    for(PxU32 i=threadIdx.x;i<n;i+=kThreads){float s=w[i];for(PxU32 c=0;c<nc;++c)s-=G[size_t(i)*kStepCols+c]*lam[c];du[i]=s;}
    __syncthreads();
    for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
        const StepLink& e=t.linkEnds[p*kStepLinks+l];float* d=dJ+6*l;
        for(int q=0;q<6;++q)d[q]=0.0f;
        if(e.state&eSL_CONTACT)continue;
        if(!(e.state&eSL_LIVE) || (e.state&eSL_YIELDED))continue;
        float c[6];stepStiffness(t.links[p*kStepLinks+l],sp.h,c);
        float x6[6];stepGather(t.B+(size_t(p)*kStepLinks+l)*72,e,du,x6);
        for(int q=0;q<6;++q)d[q]=-c[q]*x6[q];
    }
    __syncthreads();
    if(!threadIdx.x)for(PxU32 c=0;c<nc;++c){const PxU32 cl=t.colLink[p*kStepCols+c];dJ[6*(cl>>2)+(cl&3u)]=-lam[c];}
    if(!threadIdx.x)++sp.solves;
    __syncthreads();
    (void)sh;
}
// A joint leaves the operator (broken or yielded): A^-1 += Z (D^-1 - B^T Z)^-1 Z^T, Z = A^-1 B_l (Sherman-Morrison-Woodbury, rank 6).
__device__ void stepRemove(Shared& sh,const StepScratch& t,PxU32 p,PxU32 l)
{
    StepPatch& sp=t.patches[p];const PxU32 n=6*sp.nodes;const StepLink e=t.linkEnds[p*kStepLinks+l];
    float c[6];stepStiffness(t.links[p*kStepLinks+l],sp.h,c);
    const float* Bl=t.B+(size_t(p)*kStepLinks+l)*72;float* A=stepA(t,p);
    float* Z=t.w+size_t(p)*kStepDof;  // [n][6] in w and d2 (n*6 <= 2*kStepDof? use G's tail is not safe): use Atmp as scratch
    Z=t.Atmp+size_t(p)*kStepDof*kStepDof;
    __shared__ float M6[36],R6[36];
    for(PxU32 idx=threadIdx.x;idx<n*6;idx+=kThreads) {
        const PxU32 i=idx/6,q=idx%6;float s=0.0f;
        if(e.a!=0xffffffffu)for(int r=0;r<6;++r)s+=A[size_t(i)*n+6*e.a+r]*Bl[6*r+q];
        if(e.b!=0xffffffffu)for(int r=0;r<6;++r)s+=A[size_t(i)*n+6*e.b+r]*Bl[36+6*r+q];
        Z[idx]=s;
    }
    __syncthreads();
    if(threadIdx.x<36) {
        const PxU32 a=threadIdx.x/6,b=threadIdx.x%6;float s=0.0f;
        if(e.a!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[6*r+a]*Z[(6*e.a+r)*6+b];
        if(e.b!=0xffffffffu)for(int r=0;r<6;++r)s+=Bl[36+6*r+a]*Z[(6*e.b+r)*6+b];
        // components with no stiffness are not in A: they leave nothing (D^-1 -> inf: drop the row/column)
        M6[threadIdx.x]=(a==b?(c[a]>0.0f?1.0f/c[a]:1.0f):0.0f)-((c[a]>0.0f && c[b]>0.0f)?s:0.0f);
    }
    __syncthreads();
    if(!threadIdx.x) {
        // invert the 6x6 (Gauss-Jordan, SPD)
        for(int i=0;i<36;++i)R6[i]=(i%7==0)?1.0f:0.0f;
        for(int k=0;k<6;++k){const float iv=1.0f/M6[7*k];for(int j=0;j<6;++j){M6[6*k+j]*=iv;R6[6*k+j]*=iv;}
            for(int i=0;i<6;++i)if(i!=k){const float f=M6[6*i+k];for(int j=0;j<6;++j){M6[6*i+j]-=f*M6[6*k+j];R6[6*i+j]-=f*R6[6*k+j];}}}
        for(int a=0;a<6;++a)for(int b=0;b<6;++b)if(!(c[a]>0.0f) || !(c[b]>0.0f))R6[6*a+b]=0.0f;
    }
    __syncthreads();
    float* Y=Z+size_t(n)*6;
    for(PxU32 idx=threadIdx.x;idx<n*6;idx+=kThreads){const PxU32 j=idx/6,a=idx%6;float z=0.0f;for(int b=0;b<6;++b)z+=R6[6*a+b]*Z[j*6+b];Y[idx]=z;}
    __syncthreads();
    for(PxU32 idx=threadIdx.x;idx<n*n;idx+=kThreads) {
        const PxU32 i=idx/n,j=idx%n;float s=0.0f;
        for(int a=0;a<6;++a)s+=Z[i*6+a]*Y[j*6+a];
        A[idx]+=s;
    }
    __syncthreads();
    (void)sh;
}
// The smallest load-factor step to a joint's capacity along dJ (within cap), by bisection of the convex utilisation.
__device__ float stepCritical(const Bond& b,const float* J,const float* dJ,float cap,float band)
{
    float x[6];for(int q=0;q<6;++q)x[q]=J[q];
    if(utilisation(b,x)>=1.0f-band)return 0.0f;
    for(int q=0;q<6;++q)x[q]=J[q]+cap*dJ[q];
    if(utilisation(b,x)<1.0f-band)return FLT_MAX;
    float lo=0.0f,hi=cap;
    for(int it=0;it<40;++it){const float mid=0.5f*(lo+hi);for(int q=0;q<6;++q)x[q]=J[q]+mid*dJ[q];if(utilisation(b,x)>=1.0f-band)hi=mid;else lo=mid;}
    return hi;
}
__device__ float stepContactCritical(const Bond& b,const StepLink& e,const float* J,const float* dJ,float cap)
{
    const float mu=b.area;
    // J, dJ captured by value: a pointer parameter captured by reference reads
    // zeros under CuMetal when it points at a local array (the W miscompile's shape).
    const PxU32 state=e.state;
    auto g=[J,dJ,state,mu](float s){const float N=J[0]+s*dJ[0];if(state&eSL_SLIDE)return N;
        return fmaxf(N,sqrtf((J[1]+s*dJ[1])*(J[1]+s*dJ[1])+(J[2]+s*dJ[2])*(J[2]+s*dJ[2]))-mu*-N);};
    // a separating contact: N >= 0 (the row's force is a compression, N <= 0)
    if(g(cap)<=0.0f)return FLT_MAX;
    if(g(0.0f)>0.0f)return 0.0f;
    float lo=0.0f,hi=cap;for(int it=0;it<40;++it){const float mid=0.5f*(lo+hi);if(g(mid)>0.0f)hi=mid;else lo=mid;}
    return hi;
}

// 4. The ramp: one block per patch, resumable. A launch spends at most
// `budget` units of work (a unit: one pass over A, n^2 multiply-adds), so a
// dispatch stays bounded however long a cascade runs: a solve costs 1, a
// joint leaving the operator 7 (its rank-6 update and the contact columns).
// The cascade at one load factor goes a joint at a time: the first joint at
// capacity yields (ductile) or breaks and its force is released as a load
// and solved; then the next, until none is at capacity.
__global__ __launch_bounds__(kThreads) void stepRamp(Inputs in,Settings s,Scratch w,StepScratch t,PxU32 budget)
{
    __shared__ Shared sh;
    __shared__ PxU32 shHit;
    for(PxU32 p=blockIdx.x;p<*t.patchCount;p+=gridDim.x) {
        StepPatch& sp=t.patches[p];
        if(sp.phase==eSTEP_DONE)continue;
        const PxU32 n=6*sp.nodes;
        float* J=t.J+size_t(p)*kStepLinks*6;float* dJ=t.dJ+size_t(p)*kStepLinks*6;float* J2=t.J2+size_t(p)*kStepLinks*6;
        float* du=t.du+size_t(p)*kStepDof;float* u=t.u+size_t(p)*kStepDof;float* d2=t.d2+size_t(p)*kStepDof;
        const float* f=t.f+size_t(p)*kStepDof;
        PxU32 work=0;
        if(!sp.events && sp.lam==0.0f && !sp.solves && !sp.cascade) {
            // J0: the rest forces (bond frame); contacts 0.
            for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads){const Bond& b=t.links[p*kStepLinks+l];const StepLink& e=t.linkEnds[p*kStepLinks+l];
                float x[6]={0,0,0,0,0,0};if(!(e.state&eSL_CONTACT))toLocal(b,in.base[b.bond],x);for(int q=0;q<6;++q)J[6*l+q]=x[q];
                if(!(e.state&eSL_CONTACT) && utilisation(b,x)>=1.0f-s.capacityBand)atomicAdd(&sp.restOver,1u);}
            for(PxU32 i=threadIdx.x;i<n;i+=kThreads)u[i]=0.0f;
            __syncthreads();
            stepContacts(sh,t,p);++work;
            // Joints at capacity at rest: the cascade first.
            if(!threadIdx.x)sp.cascade=1;
            __syncthreads();
        }
        while(work<budget && sp.phase!=eSTEP_DONE) {
            if(sp.cascade) {
                // The first joint at capacity, if any.
                if(!threadIdx.x)shHit=0xffffffffu;
                __syncthreads();
                for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
                    const StepLink& e=t.linkEnds[p*kStepLinks+l];
                    if((e.state&eSL_CONTACT) || !(e.state&eSL_LIVE) || (e.state&eSL_YIELDED))continue;
                    if(utilisation(t.links[p*kStepLinks+l],J+6*l)>=1.0f-s.capacityBand)atomicMin(&shHit,l);
                }
                __syncthreads();
                const PxU32 l=shHit;
                if(l==0xffffffffu){if(!threadIdx.x)sp.cascade=0;__syncthreads();continue;}
                StepLink& e=t.linkEnds[p*kStepLinks+l];const Bond& b=t.links[p*kStepLinks+l];
                if(b.flags&eDUCTILE) {
                    stepRemove(sh,t,p,l);
                    if(!threadIdx.x){e.state|=eSL_YIELDED;++sp.yielded;}
                    __syncthreads();
                    stepContacts(sh,t,p);work+=7;
                    continue;
                }
                // brittle: its force leaves as a load on its ends
                for(PxU32 i=threadIdx.x;i<n;i+=kThreads)d2[i]=0.0f;
                __syncthreads();
                if(!threadIdx.x)stepScatter(t.B+(size_t(p)*kStepLinks+l)*72,e,J+6*l,d2,-1.0f);
                __syncthreads();
                stepRemove(sh,t,p,l);
                if(!threadIdx.x){e.state&=~eSL_LIVE;e.state|=eSL_BROKEN;for(int q=0;q<6;++q)J[6*l+q]=0.0f;++sp.broken;
                    if(w.breaks){w.breaks[2*b.bond]=sp.lam;w.breaks[2*b.bond+1]=0.0f;}}
                __syncthreads();
                stepContacts(sh,t,p);
                stepSolve(sh,t,p,d2,du,J2);
                for(PxU32 m=threadIdx.x;m<sp.links;m+=kThreads)for(int q=0;q<6;++q)J[6*m+q]+=J2[6*m+q];
                for(PxU32 i=threadIdx.x;i<n;i+=kThreads)u[i]+=du[i];
                __syncthreads();
                work+=8;
                continue;
            }
            if(sp.events>=s.stepMaxEvents){if(!threadIdx.x){sp.failed=1;sp.phase=eSTEP_DONE;}__syncthreads();break;}
            // The next increment of the impactors' load and its first event.
            stepSolve(sh,t,p,f,du,dJ);++work;
            const float cap=1.0f-sp.lam;float best=FLT_MAX;
            for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads) {
                const StepLink& e=t.linkEnds[p*kStepLinks+l];const Bond& b=t.links[p*kStepLinks+l];
                float c=FLT_MAX;
                if(e.state&eSL_CONTACT){if(!(e.state&eSL_OFF))c=stepContactCritical(b,e,J+6*l,dJ+6*l,cap);}
                else if((e.state&eSL_LIVE) && !(e.state&eSL_YIELDED))c=stepCritical(b,J+6*l,dJ+6*l,cap,s.capacityBand);
                best=fminf(best,c);
            }
            best=blockMin(sh,best);
            const bool last=!(best<cap);
            const float step=last?cap:best;
            for(PxU32 l=threadIdx.x;l<sp.links;l+=kThreads)for(int q=0;q<6;++q)J[6*l+q]+=step*dJ[6*l+q];
            for(PxU32 i=threadIdx.x;i<n;i+=kThreads)u[i]+=step*du[i];
            __syncthreads();
            if(!threadIdx.x){sp.lam=last?1.0f:sp.lam+step;if(!last)++sp.events;}
            __syncthreads();
            if(last){if(!threadIdx.x)sp.phase=eSTEP_DONE;__syncthreads();break;}
            // Contacts at their event: separate (its force 0) or slide (its friction released as a load).
            bool changed=false;
            for(PxU32 l=0;l<sp.links;++l) {
                StepLink& e=t.linkEnds[p*kStepLinks+l];if(!(e.state&eSL_CONTACT) || (e.state&eSL_OFF))continue;
                const Bond& b=t.links[p*kStepLinks+l];
                if(stepContactCritical(b,e,J+6*l,dJ+6*l,1e-6f)>0.0f)continue;
                __syncthreads();
                const bool separates=(e.state&eSL_SLIDE) || J[6*l]>=-1e-6f*fmaxf(1.0f,fabsf(J[6*l]));
                if(separates){if(!threadIdx.x){e.state|=eSL_OFF;for(int q=0;q<6;++q)J[6*l+q]=0.0f;}changed=true;__syncthreads();continue;}
                for(PxU32 i=threadIdx.x;i<n;i+=kThreads)d2[i]=0.0f;
                __syncthreads();
                if(!threadIdx.x){float x[6]={0,J[6*l+1],J[6*l+2],0,0,0};stepScatter(t.B+(size_t(p)*kStepLinks+l)*72,e,x,d2,-1.0f);
                    J[6*l+1]=J[6*l+2]=0.0f;e.state|=eSL_SLIDE;}
                __syncthreads();
                stepContacts(sh,t,p);
                stepSolve(sh,t,p,d2,du,J2);
                for(PxU32 m=threadIdx.x;m<sp.links;m+=kThreads)for(int q=0;q<6;++q)J[6*m+q]+=J2[6*m+q];
                for(PxU32 i=threadIdx.x;i<n;i+=kThreads)u[i]+=du[i];
                __syncthreads();
                work+=2;changed=false;
            }
            if(changed){stepContacts(sh,t,p);++work;}
            if(!threadIdx.x)sp.cascade=1;
            __syncthreads();
        }
        __syncthreads();
    }
}

// 5. Publish: the island's forces and verdicts (the patch's joints from the
// step; the rest of the island: its forces before the tick, held), each row's
// bound (the impulse its pair delivered over h, per point), the flags.
__global__ void stepPublish(Inputs in,Settings s,Scratch w,StepScratch t)
{
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    const PxU32 patches=*t.patchCount;
    // the island's other bonds
    for(PxU32 i=tid;i<in.bondCount;i+=stride) {
        const PxU32 island=in.bondIslands[i];if(island>=in.chunkCount)continue;
        for(PxU32 p=0;p<patches;++p)if(t.patches[p].island==island){w.forces[i]=in.base[i];w.verdict[i]=eHELD;if(w.slip)w.slip[i]=0.0f;}
    }
}
__global__ void stepPublishPatch(Inputs in,Settings s,Scratch w,StepScratch t)
{
    const PxU32 p=blockIdx.y;if(p>=*t.patchCount)return;
    const StepPatch& sp=t.patches[p];
    const float* J=t.J+size_t(p)*kStepLinks*6;const float* u=t.u+size_t(p)*kStepDof;
    for(PxU32 l=blockIdx.x*blockDim.x+threadIdx.x;l<sp.links;l+=gridDim.x*blockDim.x) {
        const Bond& b=t.links[p*kStepLinks+l];const StepLink& e=t.linkEnds[p*kStepLinks+l];const float* Bl=t.B+(size_t(p)*kStepLinks+l)*72;
        if(e.state&eSL_CONTACT) {
            const PxU32 r=e.pad;const ContactRow& row=in.rows[r];
            float lin[3],ang[3];toWorld(b,J+6*l,lin,ang);
            if(in.rowForce)for(int q=0;q<3;++q)in.rowForce[3*r+q]=lin[q]*sp.h/s.dt;   // its impulse over the tick, as a force
            // The bound: the impulse the pair delivered (over h), per point; a struck chunk freed takes none.
            bool live=false;
            for(PxU32 m=0;m<sp.links && !live;++m){const StepLink& e2=t.linkEnds[p*kStepLinks+m];
                live=!(e2.state&eSL_CONTACT) && (e2.state&eSL_LIVE) && (e2.a==e.a || e2.b==e.a);}
            if(in.rowBound)in.rowBound[r]=(live || s.boundImpactor)?fmaxf(sqrtf(lin[0]*lin[0]+lin[1]*lin[1]+lin[2]*lin[2])*sp.h/float(max(row.points,1u)),FLT_MIN):0.0f;
            if(in.rowDelta){const float* ui=u+6*e.b;for(int q=0;q<3;++q)in.rowDelta[6*r+q]=ui[q]*sp.h-(row.velocity[q]+row.dv[q]);}
            continue;
        }
        float lin[3],ang[3];toSolver(b,J+6*l,lin,ang);
        PxDestructionVectorPair fo;fo.linear=PxVec3(lin[0],lin[1],lin[2]);fo.angular=PxVec3(ang[0],ang[1],ang[2]);
        w.forces[b.bond]=fo;
        PxU32 v=eHELD;float slip=0.0f;
        if(e.state&eSL_BROKEN)v=eBROKEN;
        else if(e.state&eSL_YIELDED) {
            float x6[6];stepGather(Bl,e,u,x6);slip=0.5f*sqrtf(x6[0]*x6[0]+x6[1]*x6[1]+x6[2]*x6[2])*sp.h*sp.h;
            const float before=in.slipBefore?in.slipBefore[b.bond]:0.0f;
            v=(before+slip>b.slip)?eBROKEN:eYIELDED;
        }
        w.verdict[b.bond]=v;if(w.slip)w.slip[b.bond]=v==eYIELDED?slip:0.0f;
    }
    if(!blockIdx.x && !threadIdx.x) {
        w.islandFlag[sp.island]=1u;
        atomicAdd(&w.status->triggered,1u);atomicAdd(&w.status->solves,sp.solves);atomicAdd(&w.status->iterations,sp.events);
        atomicAdd(&w.status->broken,sp.broken);atomicAdd(&w.status->yielded,sp.yielded);
        atomicAdd(&w.status->contacts,sp.contacts);atomicAdd(&w.status->impactors,sp.impactors);
        atomicAdd(&w.status->stepPatches,1u);if(sp.truncated)atomicAdd(&w.status->stepTruncated,1u);
        if(sp.failed)atomicOr(&w.status->error,4u);
    }
}
__global__ void stepClear(Inputs in,StepScratch t)
{
    const PxU32 tid=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    for(PxU32 i=tid;i<in.chunkCount+kStepPatches*kStepNodes;i+=stride)t.nodeOf[i]=0xffffffffu;
    for(PxU32 i=tid;i<kStepPatches*kStepNodes;i+=stride)t.nodeChunk[i]=0xffffffffu;
    for(PxU32 i=tid;i<kStepPatches*kStepDof;i+=stride)t.f[i]=0.0f;
    if(!tid)*t.patchCount=0;
}
