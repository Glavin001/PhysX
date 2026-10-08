// The static verdict after an impact, from two captured passes of the same
// tick (PX_DESTRUCTION_IMPACT_CAPTURE_STATIC): the trial pass, where the
// impactor's rigid stop is a contact load on the struck chunks, and the
// corrected pass after it.
//
//   destruction_impact_static_handoff TRIAL.impc CORRECTED.impc
//
// The stage's elastic solve is warm-started from the pass before and capped
// at 64 iterations a pass (unconverged solves continue next tick). This
// reproduces that with a block-Jacobi PCG on the struck island (K = B k B^T,
// the stress solve's own stiffness; anchors held):
//   x0  the corrected pass's loads, converged (the state before the tick);
//   xt  the trial pass's loads, IMPACT_STATIC_ITERATIONS (64) from x0;
//   xc  the corrected pass's loads, 64 iterations from xt;
// and counts the joints the static verdict breaks (utilisation >= 1) under
// xc against those of x0 -- the verdict of the corrected pass's own loads.
// With IMPACT_ROUTE=1 the trial's contact rows go through the routing
// (Settings::route: impact::routeRows) first. Passes when the corrected
// pass's verdict breaks no more than its converged loads do.
#include "PxDestructionScene.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cfloat>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <string>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"
#include "../src/PxgDestructionImpactCapture.cuh"
struct File {
    FILE* f;explicit File(const char* path):f(std::fopen(path,"rb")){if(!f)throw std::runtime_error(std::string("cannot open ")+path);}
    ~File(){std::fclose(f);}
    template<class T>std::vector<T> read(size_t n){std::vector<T> v(n);if(n && std::fread(v.data(),sizeof(T),n,f)!=n)throw std::runtime_error("short capture");return v;}
    template<class T>T one(){return read<T>(1)[0];}
};
template<class T>T* upload(const std::vector<T>& v){T* p;allocate(p,v.size());if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
float env(const char* name,float fallback){const char* v=std::getenv(name);return v && *v?float(std::atof(v)):fallback;}
struct Capture { impact::Inputs in{};impact::Settings s{};std::vector<impact::ContactRow> rows; };
Capture load(const char* path)
{
    File f(path);Capture c;
    const auto h=f.one<impact::CaptureHeader>();
    if(std::memcmp(h.magic,"IMPC",4) || h.version!=1 || h.settingsBytes>sizeof(impact::Settings))throw std::runtime_error("not a capture of this build");
    {const auto raw=f.read<unsigned char>(h.settingsBytes);std::memcpy(&c.s,raw.data(),h.settingsBytes);}
    const PxU32 n=h.n,m=h.m;impact::Inputs& in=c.in;in.chunkCount=n;in.bondCount=m;
    in.chunks=upload(f.read<PxDestructionStressChunk>(n));in.bonds=upload(f.read<PxDestructionStressBond>(m));
    in.materials=upload(f.read<PxDestructionMaterial>(h.materials));
    if(h.flags&impact::eCAPTURE_SLIP)in.ductileSlip=upload(f.read<float>(h.materials));
    if(h.flags&impact::eCAPTURE_STIFFNESS)in.stiffness=upload(f.read<float>(h.materials));
    in.health=upload(f.read<float>(m));
    in.nodeBegin=upload(f.read<PxU32>(size_t(n)+1));
    const PxU32 refs=f.one<PxU32>();in.nodeRefs=upload(f.read<PxU32>(refs));
    in.nodeIslands=upload(f.read<PxU32>(n));in.bondIslands=upload(f.read<PxU32>(m));
    in.accelerations=upload(f.read<PxDestructionVectorPair>(n));in.elastic=upload(f.read<PxDestructionVectorPair>(m));
    in.base=upload(f.read<PxDestructionVectorPair>(m));
    if(h.flags&impact::eCAPTURE_ELASTIC_BASE)in.elasticBase=upload(f.read<PxDestructionVectorPair>(m));
    if(h.flags&impact::eCAPTURE_CRUSHED)in.crushed=upload(f.read<PxDestructionCrushState>(n));
    if(h.flags&impact::eCAPTURE_SECTIONS)in.sections=upload(f.read<PxDestructionBondSection>(m));
    if(h.flags&impact::eCAPTURE_ROWS){c.rows=f.read<impact::ContactRow>(h.rows);in.rows=upload(c.rows);in.rowCount=h.rows;}
    if(h.flags&impact::eCAPTURE_CARRIED)in.carried=upload(f.read<PxU32>(m));
    if(h.flags&impact::eCAPTURE_SLIP_BEFORE)in.slipBefore=upload(f.read<float>(m));
    if(h.flags&impact::eCAPTURE_ROUTED)f.read<PxU32>(h.rows);   // the capture's own routing: recomputed here
    in.stage=upload(std::vector<PxDestructionStageStatus>(1));
    return c;
}
// The PCG's state on one patch (the whole struck island).
struct Pcg { float *x,*r,*z,*p,*q,*e,*Dinv,*f; float* scalars; };
// y = K v (K = B k B^T over the live joints; held ends contribute nothing).
__device__ void kApply(const impact::ExScratch& t,float* E,const float* v,float* y,const float* scale)
{
    const impact::ExPatch& sp=t.patches[0];const impact::Bond* bonds=t.bonds;const impact::ExLink* links=t.links;const impact::ExNode* nodes=t.nodes;
    for(PxU32 l=threadIdx.x;l<sp.links;l+=impact::kThreads) {
        const impact::ExLink& e=links[l];float d[6]={0,0,0,0,0,0};
        if(e.state&impact::eEX_LIVE){if(e.a!=0xffffffffu)impact::exRelative(bonds[l],0,v+6*e.a,d);if(e.b!=0xffffffffu)impact::exRelative(bonds[l],1,v+6*e.b,d);}
        float k[6];impact::exStiffness(bonds[l],k);for(int q=0;q<6;++q)E[6*l+q]=scale[l]*k[q]*d[q];
    }
    __syncthreads();
    for(PxU32 n=threadIdx.x;n<sp.chunks;n+=impact::kThreads) {
        float f[6]={0,0,0,0,0,0};
        for(PxU32 j=nodes[n].jointBegin;j<nodes[n].jointEnd;++j){const PxU32 l=t.adj[j]>>1;impact::exWrench(bonds[l],E+6*l,t.adj[j]&1u,f);}
        for(int q=0;q<6;++q)y[6*n+q]=f[q];
    }
    __syncthreads();
}
__device__ float dotAll(impact::Shared& sh,const float* a,const float* b,PxU32 count)
{
    float s=0.0f;for(PxU32 i=threadIdx.x;i<count;i+=impact::kThreads)s+=a[i]*b[i];return impact::blockSum(sh,s);
}
// The diagonal 6x6 blocks of K, inverted (the preconditioner), and each chunk's load.
__global__ __launch_bounds__(impact::kThreads) void pcgSetup(impact::Inputs in,impact::ExScratch t,float* Dinv,float* F,const float* scale,const PxU32* freeNode)
{
    const impact::ExPatch& sp=t.patches[0];
    for(PxU32 n=threadIdx.x;n<sp.chunks;n+=impact::kThreads) {
        const impact::ExNode& nd=t.nodes[n];float D[36]={};
        for(PxU32 j=nd.jointBegin;j<nd.jointEnd;++j) {
            const PxU32 l=t.adj[j]>>1,end=t.adj[j]&1u;const impact::Bond& b=t.bonds[l];if(!(t.links[l].state&impact::eEX_LIVE))continue;
            float k[6];impact::exStiffness(b,k);for(int q=0;q<6;++q)k[q]*=scale[l];float B[36];
            for(int q=0;q<6;++q){float x[6]={0,0,0,0,0,0};x[q]=1.0f;float r[6]={0,0,0,0,0,0};impact::exWrench(b,x,end,r);for(int i=0;i<6;++i)B[6*i+q]=r[i];}
            for(int i=0;i<6;++i)for(int c=0;c<6;++c){float v=0.0f;for(int q=0;q<6;++q)v+=B[6*i+q]*k[q]*B[6*c+q];D[6*i+c]+=v;}
        }
        float R[36];for(int i=0;i<36;++i)R[i]=(i%7==0)?1.0f:0.0f;
        for(int i=0;i<6;++i)if(!(D[7*i]>0.0f))D[7*i]=1.0f;
        for(int kk=0;kk<6;++kk){const float iv=1.0f/D[7*kk];for(int j=0;j<6;++j){D[6*kk+j]*=iv;R[6*kk+j]*=iv;}
            for(int i=0;i<6;++i)if(i!=kk){const float f=D[6*i+kk];for(int j=0;j<6;++j){D[6*i+j]-=f*D[6*kk+j];R[6*i+j]-=f*R[6*kk+j];}}}
        for(int i=0;i<36;++i)Dinv[36*n+i]=R[i];
        const auto c=in.chunks[nd.chunk];const auto a=in.accelerations[nd.chunk];
        const float held=freeNode[n]?0.0f:1.0f;   // debris (no live path to an anchor) carries no load
        F[6*n]=held*a.linear.x*c.mass;F[6*n+1]=held*a.linear.y*c.mass;F[6*n+2]=held*a.linear.z*c.mass;F[6*n+3]=F[6*n+4]=F[6*n+5]=0.0f;
    }
}
// PCG on K x = f from the x in place, `iterations` steps or to a relative residual of 1e-6.
__global__ __launch_bounds__(impact::kThreads) void pcg(impact::ExScratch t,float* X,float* R,float* Z,float* P,float* Q,float* E,const float* Dinv,const float* F,float* scalars,const float* scale,PxU32 iterations)
{
    __shared__ impact::Shared sh;
    const PxU32 nd=6*t.patches[0].chunks;
    kApply(t,E,X,Q,scale);
    for(PxU32 i=threadIdx.x;i<nd;i+=impact::kThreads)R[i]=F[i]-Q[i];
    __syncthreads();
    auto precondition=[&]{for(PxU32 n=threadIdx.x;n<nd/6;n+=impact::kThreads){for(int a=0;a<6;++a){float s=0.0f;for(int b=0;b<6;++b)s+=Dinv[36*n+6*a+b]*R[6*n+b];Z[6*n+a]=s;}}__syncthreads();};
    precondition();
    for(PxU32 i=threadIdx.x;i<nd;i+=impact::kThreads)P[i]=Z[i];
    __syncthreads();
    float rz=dotAll(sh,R,Z,nd);const float f2=dotAll(sh,F,F,nd);
    PxU32 it=0;
    for(;it<iterations;++it) {
        if(dotAll(sh,R,R,nd)<=1e-12f*f2)break;
        kApply(t,E,P,Q,scale);
        const float pq=dotAll(sh,P,Q,nd);if(!(pq>0.0f))break;
        const float alpha=rz/pq;
        for(PxU32 i=threadIdx.x;i<nd;i+=impact::kThreads){X[i]+=alpha*P[i];R[i]-=alpha*Q[i];}
        __syncthreads();
        precondition();
        const float rz2=dotAll(sh,R,Z,nd),beta=rz2/rz;rz=rz2;
        for(PxU32 i=threadIdx.x;i<nd;i+=impact::kThreads)P[i]=Z[i]+beta*P[i];
        __syncthreads();
    }
    const float rr=dotAll(sh,R,R,nd);
    if(!threadIdx.x){scalars[0]=float(it);scalars[1]=sqrtf(rr/fmaxf(f2,1e-30f));}
}
// The static verdict of J = -k B^T x: joints at or past capacity.
__global__ void verdict(impact::ExScratch t,const float* X,impact::Settings s,PxU32* broken,const float* scale,float* util)
{
    const PxU32 l=blockIdx.x*blockDim.x+threadIdx.x;if(l>=t.patches[0].links)return;
    const impact::ExLink& e=t.links[l];if(!(e.state&impact::eEX_LIVE))return;
    const impact::Bond& b=t.bonds[l];float d[6]={0,0,0,0,0,0};
    if(e.a!=0xffffffffu)impact::exRelative(b,0,X+6*e.a,d);if(e.b!=0xffffffffu)impact::exRelative(b,1,X+6*e.b,d);
    float k[6];impact::exStiffness(b,k);float J[6];for(int q=0;q<6;++q)J[q]=-scale[l]*k[q]*d[q];
    const float u=impact::utilisation(b,J);util[l]=u;
    if(u>=1.0f)atomicAdd(broken,1u);
}

int run(int argc,char** argv)
{
    if(argc<3){std::fprintf(stderr,"usage: %s TRIAL.impc CORRECTED.impc\n",argv[0]);return 2;}
    Capture trial=load(argv[1]),corrected=load(argv[2]);
    const bool route=env("IMPACT_ROUTE",0.0f)!=0.0f;const PxU32 cap=PxU32(env("IMPACT_STATIC_ITERATIONS",64.0f));
    impact::Settings s=trial.s;s.stepRadius=1e6f;s.route=route;
    // The struck island: the patch of the trial's rows with an unbounded radius.
    const PxU32 n=trial.in.chunkCount,m=trial.in.bondCount;
    impact::Stage stage;stage.allocate(n,m);stage.allocateExplicit();impact::ExScratch& t=stage.x;
    impact::Inputs in=trial.in;in.rowCounter=nullptr;
    // The routing on the trial's loads (a copy: the corrected capture is untouched).
    PxDestructionVectorPair* trialLoads;allocate(trialLoads,n);check(cudaMemcpy(trialLoads,in.accelerations,sizeof(*trialLoads)*n,cudaMemcpyDeviceToDevice));
    PxU32* routed=nullptr;
    if(route && in.rows) {
        allocate(routed,in.rowCount);
        impact::routeRows<<<(in.rowCount+127)/128,128>>>(in,s,routed,trialLoads);check(cudaDeviceSynchronize());
        std::vector<PxU32> r(in.rowCount);check(cudaMemcpy(r.data(),routed,sizeof(PxU32)*r.size(),cudaMemcpyDeviceToHost));
        PxU32 c=0;for(PxU32 x:r)c+=x;std::printf("routing: %u of %u contact rows routed to the impact model\n",c,in.rowCount);
        in.rowRouted=nullptr;   // the patch: every row's island
    }
    // IMPACT_STATIC_ISLAND=I: that island instead (a pass with no impactor on
    // it -- a cascade under dead load): one stand-in row on its first chunk.
    if(const char* v=std::getenv("IMPACT_STATIC_ISLAND")) {
        const PxU32 island=PxU32(std::atoi(v));
        std::vector<PxU32> islands(n);check(cudaMemcpy(islands.data(),in.nodeIslands,sizeof(PxU32)*n,cudaMemcpyDeviceToHost));
        impact::ContactRow row{};row.chunk=0xffffffffu;for(PxU32 c=0;c<n && row.chunk==0xffffffffu;++c)if(islands[c]==island)row.chunk=c;
        if(row.chunk==0xffffffffu)throw std::runtime_error("no such island");
        row.points=1;row.im=1e-6f;row.normal[1]=1.0f;row.friction=0.5f;for(int q=0;q<6;++q)row.ii[q]=q<3?1e-6f:0.0f;
        in.rows=upload(std::vector<impact::ContactRow>{row});in.rowCount=1;
    }
    impact::exClear<<<64,impact::kThreads>>>(in,t);impact::exList<<<1,1>>>(in,s,stage.w,t);
    PxU32 count=0;check(cudaDeviceSynchronize());check(cudaMemcpy(&count,t.patchCount,4,cudaMemcpyDeviceToHost));
    if(!count)throw std::runtime_error("no struck island in the trial capture");
    PxU32 one=1;check(cudaMemcpy(t.patchCount,&one,4,cudaMemcpyHostToDevice));
    impact::exBuild<<<1,impact::kThreads>>>(in,s,stage.w,t);check(cudaDeviceSynchronize());
    impact::ExPatch sp{};check(cudaMemcpy(&sp,t.patches,sizeof sp,cudaMemcpyDeviceToHost));
    std::printf("island %u: %u chunks, %u joints%s\n",sp.island,sp.chunks,sp.links,sp.failed?" (TRUNCATED)":"");
    Pcg g{};for(float** a:{&g.x,&g.r,&g.z,&g.p,&g.q,&g.f})allocate(*a,6*size_t(impact::kExNodes));
    allocate(g.e,6*size_t(impact::kExLinks));allocate(g.Dinv,36*size_t(impact::kExNodes));allocate(g.scalars,2);
    PxU32* broken;allocate(broken,1);
    PxU32* freeNode;allocate(freeNode,impact::kExNodes);check(cudaMemset(freeNode,0,sizeof(PxU32)*impact::kExNodes));
    float* scale;allocate(scale,impact::kExLinks);float* util;allocate(util,impact::kExLinks);
    std::vector<float> hostScale(impact::kExLinks,1.0f);check(cudaMemcpy(scale,hostScale.data(),sizeof(float)*hostScale.size(),cudaMemcpyHostToDevice));
    check(cudaMemset(util,0,sizeof(float)*impact::kExLinks));
    auto solve=[&](const impact::Inputs& loads,PxU32 iterations,const char* what) {
        pcgSetup<<<1,impact::kThreads>>>(loads,t,g.Dinv,g.f,scale,freeNode);pcg<<<1,impact::kThreads>>>(t,g.x,g.r,g.z,g.p,g.q,g.e,g.Dinv,g.f,g.scalars,scale,iterations);
        check(cudaMemset(broken,0,4));verdict<<<(sp.links+127)/128,128>>>(t,g.x,s,broken,scale,util);check(cudaDeviceSynchronize());check(cudaGetLastError());
        float sc[2];PxU32 b=0;check(cudaMemcpy(sc,g.scalars,8,cudaMemcpyDeviceToHost));check(cudaMemcpy(&b,broken,4,cudaMemcpyDeviceToHost));
        std::printf("  %-44s %6.0f iterations, residual %.2e: the static verdict breaks %u\n",what,sc[0],sc[1],b);return b;
    };
    // The corrected pass's loads, routed too (the routing runs every pass).
    PxDestructionVectorPair* corrLoads;allocate(corrLoads,n);check(cudaMemcpy(corrLoads,corrected.in.accelerations,sizeof(*corrLoads)*n,cudaMemcpyDeviceToDevice));
    if(route && corrected.in.rows) {
        PxU32* r2;allocate(r2,corrected.in.rowCount);
        impact::routeRows<<<(corrected.in.rowCount+127)/128,128>>>(corrected.in,s,r2,corrLoads);check(cudaDeviceSynchronize());
        std::vector<PxU32> r(corrected.in.rowCount);check(cudaMemcpy(r.data(),r2,sizeof(PxU32)*r.size(),cudaMemcpyDeviceToHost));
        PxU32 c=0;for(PxU32 x:r)c+=x;std::printf("routing (corrected pass): %u of %u contact rows\n",c,corrected.in.rowCount);
    }
    impact::Inputs correctedLoads=in;correctedLoads.accelerations=corrLoads;
    impact::Inputs trialInputs=in;trialInputs.accelerations=trialLoads;
    check(cudaMemset(g.x,0,sizeof(float)*6*impact::kExNodes));
    const PxU32 reference=solve(correctedLoads,100000,"corrected loads, converged (x0)");
    solve(trialInputs,cap,route?"trial loads, routed, from x0":"trial loads, from x0");
    const PxU32 after=solve(correctedLoads,cap,"corrected loads, from the trial's state");
    std::printf("corrected pass: %u breaks against %u under its own loads%s\n",after,reference,after<=reference?"":" -- the trial's contact loads carried into it");
    // IMPACT_STATIC_CASCADE=1: the corrected loads' cascade, each round
    // converged: brittle-only (today's static verdict: every joint at capacity
    // breaks), and with ductile joints yielding (their secant stiffness scaled
    // to carry their capacity, brittle ones breaking), to a fixed point.
    if(std::getenv("IMPACT_STATIC_CASCADE")) {
        std::vector<impact::ExLink> links(sp.links);check(cudaMemcpy(links.data(),t.links,sizeof(links[0])*links.size(),cudaMemcpyDeviceToHost));
        const std::vector<impact::ExLink> intact=links;
        for(int ductileYield=0;ductileYield<2;++ductileYield) {
            links=intact;std::fill(hostScale.begin(),hostScale.end(),1.0f);PxU32 brokenTotal=0,yielded=0;
            for(int round=0;round<64;++round) {
                check(cudaMemcpy(t.links,links.data(),sizeof(links[0])*links.size(),cudaMemcpyHostToDevice));
                check(cudaMemcpy(scale,hostScale.data(),sizeof(float)*hostScale.size(),cudaMemcpyHostToDevice));
                {   // debris: components of the live joints with no joint to an anchor (a held end)
                    std::vector<PxU32> parent(sp.chunks),held(sp.chunks,0u),freeHost(impact::kExNodes,0u);
                    for(PxU32 k=0;k<sp.chunks;++k)parent[k]=k;
                    auto root=[&](PxU32 k){while(parent[k]!=k){parent[k]=parent[parent[k]];k=parent[k];}return k;};
                    for(const auto& e:links){if(!(e.state&impact::eEX_LIVE))continue;
                        if(e.a!=0xffffffffu && e.b!=0xffffffffu && e.a<sp.chunks && e.b<sp.chunks)parent[root(e.a)]=root(e.b);}
                    for(const auto& e:links){if(!(e.state&impact::eEX_LIVE))continue;
                        if(e.a==0xffffffffu && e.b<sp.chunks)held[root(e.b)]=1u;if(e.b==0xffffffffu && e.a<sp.chunks)held[root(e.a)]=1u;}
                    for(PxU32 k=0;k<sp.chunks;++k)freeHost[k]=held[root(k)]?0u:1u;
                    check(cudaMemcpy(freeNode,freeHost.data(),sizeof(PxU32)*freeHost.size(),cudaMemcpyHostToDevice));
                }
                check(cudaMemset(g.x,0,sizeof(float)*6*impact::kExNodes));check(cudaMemset(util,0,sizeof(float)*impact::kExLinks));
                char what[64];std::snprintf(what,sizeof what,"%s round %d",ductileYield?"ductile yield":"brittle",round);
                solve(correctedLoads,100000,what);
                std::vector<float> u(sp.links);check(cudaMemcpy(u.data(),util,sizeof(float)*u.size(),cudaMemcpyDeviceToHost));
                PxU32 changed=0;
                for(PxU32 l=0;l<sp.links;++l) {
                    if(!(links[l].state&impact::eEX_LIVE) || !(u[l]>=1.0f-s.capacityBand))continue;
                    if(ductileYield && (links[l].state&impact::eEX_DUCTILE)){if(u[l]>1.0f+s.capacityBand){if(hostScale[l]==1.0f)++yielded;hostScale[l]/=u[l]*(1.0f+s.capacityBand);++changed;}continue;}
                    if(u[l]>=1.0f){links[l].state&=~impact::eEX_LIVE;++brokenTotal;++changed;}
                }
                if(!changed)break;
            }
            std::printf("cascade under the corrected loads, %s: %u broken%s\n",ductileYield?"ductile joints yield":"brittle (today)",brokenTotal,ductileYield?(", "+std::to_string(yielded)+" yielded").c_str():"");
        }
    }
    return after<=reference?0:1;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
