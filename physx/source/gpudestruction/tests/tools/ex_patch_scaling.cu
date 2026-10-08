// The explicit step's window on P copies of one dumped patch in one launch (a
// block each): does the wall time of N impacts stay that of one?
//
//   ex_patch_scaling DUMP.bin [P...]   (default 1 2 4 8)
//
// Built from impact_explicit_replay.cu's dump reader; prints the window's time
// per P (min of 5 launches) and the per-patch substeps.
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
#include <type_traits>
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
    const PxU32 kP=impact::kExPatches;
    auto rep=[](const auto& v,PxU32 n){std::remove_const_t<std::remove_reference_t<decltype(v)>> r;for(PxU32 i=0;i<n;++i)r.insert(r.end(),v.begin(),v.end());return r;};
    impact::ExScratch t{};
    t.patchCount=upload(std::vector<PxU32>{1u});t.patches=upload(std::vector<impact::ExPatch>(kP,patch));
    t.nodes=upload(rep(nodes,kP));t.bonds=upload(rep(bonds,kP));t.links=upload(rep(links,kP));t.rowBonds=upload(rep(rowBonds,kP));t.rows=upload(rep(rows,kP));
    t.adj=upload(rep(adj,kP));t.rowAdj=upload(rep(rowAdj,kP));allocate(t.wr,12*size_t(impact::kExLinks)*kP);allocate(t.rwr,12*size_t(impact::kExRows)*kP);
    allocate(t.jp,impact::kExJoint*size_t(impact::kExLinks)*kP);allocate(t.jl,size_t(impact::kExLinks)*kP);
    impact::Settings s{};s.dt=dt;s.capacityBand=band;
    impact::Scratch w{};
    std::vector<PxU32> counts;for(int i=2;i<argc;++i)counts.push_back(PxU32(std::atoi(argv[i])));if(counts.empty())counts={1,2,4,8};
    const auto nodes0=rep(nodes,kP);const auto links0=rep(links,kP);const auto rows0=rep(rows,kP);
    for(PxU32 P:counts) {
        if(P>kP)continue;
        double best=1e30;impact::ExPatch out{};
        for(int r=0;r<6;++r) {
            check(cudaMemcpy(t.nodes,nodes0.data(),sizeof(nodes0[0])*nodes0.size(),cudaMemcpyHostToDevice));
            check(cudaMemcpy(t.links,links0.data(),sizeof(links0[0])*links0.size(),cudaMemcpyHostToDevice));
            check(cudaMemcpy(t.rows,rows0.data(),sizeof(rows0[0])*rows0.size(),cudaMemcpyHostToDevice));
            std::vector<impact::ExPatch> ps(kP,patch);check(cudaMemcpy(t.patches,ps.data(),sizeof(ps[0])*kP,cudaMemcpyHostToDevice));
            check(cudaMemcpy(t.patchCount,&P,sizeof P,cudaMemcpyHostToDevice));
            impact::exFinishKernel<<<P,impact::kThreads>>>(s,t);check(cudaDeviceSynchronize());
            const auto t0=std::chrono::steady_clock::now();
            impact::exRun<<<P,impact::kExThreads>>>(s,w,t,PxU32(1e6));check(cudaDeviceSynchronize());check(cudaGetLastError());
            const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
            if(r)best=std::min(best,ms);   // the first builds the pipeline
            check(cudaMemcpy(&out,t.patches+(P-1),sizeof out,cudaMemcpyDeviceToHost));
        }
        std::printf("%u patches of %u nodes, %u joints: window %.2f ms (%u substeps each)\n",P,patch.nodes,patch.links,best,out.substeps);
    }
    return 0;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
