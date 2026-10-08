// The explicit impact step (PxgDestructionImpactExplicit.cuh) on a dumped
// impact level (IMPACT_DUMP: the capture replay's capped island -- its nodes,
// joints with their wrench blocks and capacity sets, the contact rows), checked
// against vibe-land scripts/impact/explicit-step.py on the same dump.
//
//   destruction_impact_explicit_replay DUMP.bin [EXPECTED]
//
// DUMP.bin with DUMP.rows.bin (the impactor's velocity) and DUMP.ramp.bin (each
// joint's ultimate slip and the slip it carries) beside it. The window is the
// tick, the substep IMPACT_EXPLICIT_DT_US (the harness's --dt-us) or the
// patch's Gershgorin bound. EXPECTED: the harness's broken links (link
// indices, one per line; first line the impactor's momentum change, N s): the
// broken sets' Jaccard index must be at least IMPACT_EXPLICIT_MIN_JACCARD
// (default 0.9) and the momentum change within 1%.
// Prints the broken links, the impactor's momentum change and the time.
#include "PxDestructionScene.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cfloat>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"
std::vector<unsigned char> slurp(const std::string& path)
{
    std::ifstream f(path,std::ios::binary);if(!f)throw std::runtime_error("cannot open "+path);
    return std::vector<unsigned char>((std::istreambuf_iterator<char>(f)),std::istreambuf_iterator<char>());
}
template<class T>T at(const std::vector<unsigned char>& b,size_t off){T v;std::memcpy(&v,b.data()+off,sizeof v);return v;}
template<class T>T* upload(const std::vector<T>& v){T* p;allocate(p,v.size());if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
float env(const char* name,float fallback){const char* v=std::getenv(name);return v && *v?float(std::atof(v)):fallback;}

int run(int argc,char** argv)
{
    if(argc<2){std::fprintf(stderr,"usage: %s DUMP.bin [EXPECTED]\n",argv[0]);return 2;}
    const std::string path=argv[1],stem=path.substr(0,path.size()-4);
    const auto d=slurp(path),rb=slurp(stem+".ramp.bin"),rr=slurp(stem+".rows.bin");
    const PxU32 nn=at<PxU32>(d,0),nl=at<PxU32>(d,4);const float dt=at<float>(d,16),band=at<float>(d,24);
    struct DumpNode { PxU32 chunk,tensor; float f[14]; };
    struct DumpLink { PxU32 u[4]; float f[14],J[6],T[6],B[72]; };
    std::vector<DumpNode> dn(nn);std::vector<DumpLink> dl(nl);
    size_t off=32;
    for(auto& n:dn){std::memcpy(&n,d.data()+off,sizeof n);off+=sizeof n;}
    for(auto& l:dl){std::memcpy(&l,d.data()+off,sizeof l);off+=sizeof l;}
    if(off!=d.size())throw std::runtime_error("dump size mismatch");
    const size_t slipOff=32+72*size_t(nn);
    float v0[3];std::memcpy(v0,rr.data()+4+36,12);
    std::vector<PxU32> local(nn);
    // One patch: every node of the dump (the full island; anchors are not nodes).
    std::vector<impact::ExNode> nodes(nn);
    PxU32 imp=0xffffffffu;
    for(PxU32 k=0;k<nn;++k) {
        impact::ExNode n{};n.chunk=dn[k].chunk;n.tensor=dn[k].tensor;n.im=dn[k].f[0];
        if(n.tensor){for(int q=0;q<6;++q)n.Iinv[q]=dn[k].f[2+q];for(int q=0;q<3;++q)n.v[q]=n.v0[q]=v0[q];imp=k;}
        else n.Iinv[0]=n.Iinv[1]=n.Iinv[2]=dn[k].f[1];
        nodes[k]=n;
    }
    auto nodeIndex=[&](PxU32 c){for(PxU32 k=0;k<nn;++k)if(dn[k].chunk==c)return k;return 0xffffffffu;};
    // Links: the bond frame, arms and sets back from the wrench blocks.
    auto frameOf=[](const DumpLink& l,impact::Bond& b) {
        const float* A=l.B;const float* Bb=l.B+36;
        for(int k=0;k<3;++k){b.n[k]=A[6*k+0];b.t1[k]=A[6*k+1];b.t2[k]=A[6*k+2];}
        // [o]x = M F^T, M the angular rows of the force columns (end b: minus).
        float Ma[9],Mb[9];for(int r=0;r<3;++r)for(int q=0;q<3;++q){Ma[3*r+q]=A[6*(3+r)+q];Mb[3*r+q]=-Bb[6*(3+r)+q];}
        const float* F[3]={b.n,b.t1,b.t2};
        auto skew=[&](const float* M,float* o){float X[9];for(int r=0;r<3;++r)for(int c=0;c<3;++c){float s=0;for(int q=0;q<3;++q)s+=M[3*r+q]*F[q][c];X[3*r+c]=s;}
            o[0]=0.5f*(X[7]-X[5]);o[1]=0.5f*(X[2]-X[6]);o[2]=0.5f*(X[3]-X[1]);};
        skew(Ma,b.o0);skew(Mb,b.o1);for(int k=0;k<3;++k)b.pc[k]=0.0f;
    };
    std::vector<impact::Bond> bonds,rowBonds;std::vector<impact::ExLink> links;std::vector<impact::ExRow> rows;std::vector<PxU32> linkOfDump;
    for(PxU32 l=0;l<nl;++l) {
        const DumpLink& L=dl[l];impact::Bond b{};frameOf(L,b);
        b.bond=L.u[0];b.c0=L.u[1];b.c1=L.u[2];b.flags=L.u[3];
        b.capC=L.f[0];b.capT=L.f[1];b.capS=L.f[2];b.gb=L.f[3];b.gt=L.f[4];b.g0=L.f[5];b.g1=L.f[6];b.h0=L.f[7];b.h1=L.f[8];
        b.kl=L.f[9];b.kt=L.f[10];b.k0=L.f[11];b.k1=L.f[12];b.area=L.f[13];b.slip=at<float>(rb,slipOff+8*size_t(l));
        const PxU32 a=nodeIndex(b.c0),e=nodeIndex(b.c1);
        if(b.flags&impact::eCONTACT) {
            if(!(b.flags&impact::eALIVE))continue;
            impact::ExRow x{};x.a=a;x.b=e;x.row=l;rows.push_back(x);rowBonds.push_back(b);continue;
        }
        impact::ExLink x{};x.a=a;x.b=e;
        x.state=(b.flags&impact::eALIVE)?(impact::eEX_LIVE|((b.flags&impact::eDUCTILE)?impact::eEX_DUCTILE:0u)):0u;
        for(int q=0;q<6;++q){x.J0[q]=(b.flags&impact::eALIVE)?L.J[q]:0.0f;x.J[q]=x.J0[q];}
        x.slip=at<float>(rb,slipOff+8*size_t(l)+4);x.limit=b.slip;x.brokeAt=-1.0f;
        bonds.push_back(b);links.push_back(x);linkOfDump.push_back(l);
    }
    if(nn>impact::kExNodes || links.size()>impact::kExLinks || rows.size()>impact::kExRows)throw std::runtime_error("dump larger than a patch");
    // Each node's joints and rows (CSR, link order).
    std::vector<PxU32> adj,rowAdj;
    for(PxU32 k=0;k<nn;++k) {
        nodes[k].jointBegin=PxU32(adj.size());
        for(PxU32 l=0;l<links.size();++l){if(links[l].a==k)adj.push_back(l<<1);if(links[l].b==k)adj.push_back((l<<1)|1u);}
        nodes[k].jointEnd=PxU32(adj.size());
        nodes[k].rowBegin=PxU32(rowAdj.size());
        for(PxU32 r=0;r<rows.size();++r){if(rows[r].a==k)rowAdj.push_back(r<<1);if(rows[r].b==k)rowAdj.push_back((r<<1)|1u);}
        nodes[k].rowEnd=PxU32(rowAdj.size());
    }
    nodes.resize(impact::kExNodes);bonds.resize(impact::kExLinks);links.resize(impact::kExLinks);rows.resize(impact::kExRows);rowBonds.resize(impact::kExRows);
    adj.resize(2*impact::kExLinks);rowAdj.resize(2*impact::kExRows);
    impact::ExPatch patch{};patch.nodes=nn;patch.chunks=nn-(imp!=0xffffffffu?1:0);patch.links=PxU32(linkOfDump.size());
    patch.rows=0;for(PxU32 l=0;l<nl;++l)if((dl[l].u[3]&impact::eCONTACT) && (dl[l].u[3]&impact::eALIVE))++patch.rows;
    patch.impactors=imp!=0xffffffffu?1:0;
    impact::ExScratch t{};
    t.patchCount=upload(std::vector<PxU32>{1u});t.patches=upload(std::vector<impact::ExPatch>{patch});
    t.nodes=upload(nodes);t.bonds=upload(bonds);t.links=upload(links);t.rowBonds=upload(rowBonds);t.rows=upload(rows);t.adj=upload(adj);t.rowAdj=upload(rowAdj);allocate(t.wr,12*size_t(impact::kExLinks));allocate(t.rwr,12*size_t(impact::kExRows));
    impact::Settings s{};s.dt=dt;s.capacityBand=band;
    s.explicitDt=env("IMPACT_EXPLICIT_DT_US",0.0f)*1e-6f;s.explicitSafety=env("IMPACT_EXPLICIT_SAFETY",s.explicitSafety);
    impact::Scratch w{};
    impact::exFinishKernel<<<1,impact::kThreads>>>(s,t);check(cudaDeviceSynchronize());
    // Warm the window's pipeline (its first launch builds it), then run.
    {impact::ExPatch p0{};check(cudaMemcpy(&p0,t.patches,sizeof p0,cudaMemcpyDeviceToHost));
     impact::ExPatch warm=p0;warm.done=1;check(cudaMemcpy(t.patches,&warm,sizeof warm,cudaMemcpyHostToDevice));
     impact::exRun<<<1,impact::kExThreads>>>(s,w,t,1);check(cudaDeviceSynchronize());check(cudaMemcpy(t.patches,&p0,sizeof p0,cudaMemcpyHostToDevice));}
    const auto t0=std::chrono::steady_clock::now();
    impact::exRun<<<1,impact::kExThreads>>>(s,w,t,PxU32(env("IMPACT_EXPLICIT_BUDGET",1e6f)));check(cudaDeviceSynchronize());check(cudaGetLastError());
    const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
    impact::ExPatch p{};check(cudaMemcpy(&p,t.patches,sizeof p,cudaMemcpyDeviceToHost));
    std::vector<impact::ExLink> out(links.size());check(cudaMemcpy(out.data(),t.links,sizeof(out[0])*out.size(),cudaMemcpyDeviceToHost));
    std::vector<impact::ExNode> nout(nn);check(cudaMemcpy(nout.data(),t.nodes,sizeof(nout[0])*nn,cudaMemcpyDeviceToHost));
    if(std::getenv("IMPACT_DEBUG")){std::vector<impact::ExRow> R(patch.rows);check(cudaMemcpy(R.data(),t.rows,sizeof(R[0])*R.size(),cudaMemcpyDeviceToHost));
        for(const auto& x:R)std::printf("row a %u b %u total %.3g %.3g %.3g\n",x.a,x.b,x.total[0],x.total[1],x.total[2]);
        std::printf("patch: substeps %u done %u h %g\n",p.substeps,p.done,p.h);}
    std::set<PxU32> broken;
    for(PxU32 l=0;l<patch.links;++l)if(out[l].state&impact::eEX_BROKEN)broken.insert(linkOfDump[l]);
    float dp=0.0f;if(imp!=0xffffffffu){float s2=0;for(int q=0;q<3;++q){const float d=nout[imp].v[q]-v0[q];s2+=d*d;}dp=std::sqrt(s2)/dn[imp].f[0];}
    std::printf("explicit: %u nodes, %u joints, %u rows; omega %.3g rad/s, h %.2f us, %u substeps, %.2f ms; broke %zu, yielded %u; impactor dp %.1f N s\n",
        p.nodes,p.links,p.rows,p.omega,p.h*1e6f,p.substeps,ms,broken.size(),p.yielded,dp);
    std::printf("broken:");for(PxU32 l:broken)std::printf(" %u",l);std::printf("\n");
    if(argc>2) {
        std::ifstream e(argv[2]);float edp=0.0f;e>>edp;std::set<PxU32> want;PxU32 x;while(e>>x)want.insert(x);
        PxU32 both=0;for(PxU32 l:broken)both+=want.count(l)?1u:0u;
        const double jac=double(both)/double(std::max<size_t>(1,broken.size()+want.size()-both));
        const double rel=edp>0.0f?std::fabs(dp-edp)/edp:0.0;
        const double need=env("IMPACT_EXPLICIT_MIN_JACCARD",0.9f);
        std::printf("against the harness: %zu broken there, Jaccard %.3f (need %.2f); impactor dp %.1f vs %.1f N s (%.2f%%, need 1%%)\n",want.size(),jac,need,dp,edp,100.0*rel);
        if(jac<need || rel>0.01)return 1;
    }
    return 0;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
