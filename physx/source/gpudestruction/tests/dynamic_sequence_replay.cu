// The dynamic sequence's window (PxgDestructionImpactExplicit.cuh, "The dynamic
// sequence"; Settings::dynamicSequence) on a removal exported by vibe-land
// structures/town-kit/scripts/sequence-lab.py --law stage --export, checked
// against that reference's own run: the bungalow at equilibrium, a case's
// members gone at t = 0, its joints dashpot-damped (zeta), its bearing joints
// failing to re-bearing contacts (friction, rocking, crushing, seat loss).
//
//   destruction_dynamic_sequence_replay PREFIX     (PREFIX.bin, PREFIX.expected)
//
// PREFIX.bin: 'DSEQ', nodes, joints, T (s), h (s), band, mu; per node: inverse
// mass, inverse inertia (3, per world axis), its load p (6: force, torque); per
// joint: a, b (~0 held), flags (4 a bearing joint), R[9] (n, t1, t2), o0[3],
// o1[3], k[6] (kl kl kl kt k0 k1), F[9] (capC capT capS gb gt g0 g1 h0 h1), zeta,
// J0[6] (bond frame). PREFIX.expected: the count of joints the reference broke,
// then per joint its index, time (ms) and kind.
// Gates (FP32 against the reference's FP64): the broken sets' Jaccard index >=
// DYNAMIC_MIN_JACCARD (0.9); the first break within DYNAMIC_FIRST_MS (2 ms, about
// 60 substeps); the energy invariant (Status::sequenceEnergy 0).
// The window runs in launches of DYNAMIC_BUDGET substeps (512, as the stage's
// explicitBudget: a dispatch stays short on a shared GPU).
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
#include <map>
#include <set>
#include <stdexcept>
#include <string>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));check(cudaMemset(p,0,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"
std::vector<unsigned char> slurp(const std::string& path)
{
    std::ifstream f(path,std::ios::binary);if(!f)throw std::runtime_error("cannot open "+path);
    return std::vector<unsigned char>((std::istreambuf_iterator<char>(f)),std::istreambuf_iterator<char>());
}
struct Reader { const std::vector<unsigned char>& b; size_t off=0;
    template<class T>T get(){if(off+sizeof(T)>b.size())throw std::runtime_error("short problem");T v;std::memcpy(&v,b.data()+off,sizeof v);off+=sizeof v;return v;}
    void floats(float* out,int n){for(int i=0;i<n;++i)out[i]=get<float>();} };
template<class T>T* upload(const std::vector<T>& v){T* p;allocate(p,v.size());if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
float env(const char* name,float fallback){const char* v=std::getenv(name);return v && *v?float(std::atof(v)):fallback;}

int run(int argc,char** argv)
{
    if(argc<2){std::fprintf(stderr,"usage: %s PREFIX\n",argv[0]);return 2;}
    const std::string prefix=argv[1];
    const auto d=slurp(prefix+".bin");Reader r{d};
    if(std::memcmp(d.data(),"DSEQ",4))throw std::runtime_error("not a dynamic-sequence problem");r.off=4;
    const PxU32 nn=r.get<PxU32>(),nl=r.get<PxU32>();const float T=r.get<float>(),h=r.get<float>(),band=r.get<float>(),mu=r.get<float>();
    if(nn>impact::kExNodes || nl>impact::kExLinks)throw std::runtime_error("problem larger than a patch");
    std::vector<impact::ExNode> nodes(impact::kExNodes);std::vector<float> load(6*size_t(impact::kExNodes),0.0f);
    for(PxU32 k=0;k<nn;++k) {
        impact::ExNode n{};n.chunk=k;n.tensor=0;n.im=r.get<float>();r.floats(n.Iinv,3);r.floats(&load[6*size_t(k)],6);nodes[k]=n;
    }
    std::vector<impact::Bond> bonds(impact::kExLinks);std::vector<impact::ExLink> links(impact::kExLinks);std::vector<float> damp(6*size_t(impact::kExLinks),0.0f);
    PxU32 bearing=0;
    for(PxU32 l=0;l<nl;++l) {
        impact::Bond b{};impact::ExLink x{};x.a=r.get<PxU32>();x.b=r.get<PxU32>();const PxU32 flags=r.get<PxU32>();
        float R[9];r.floats(R,9);for(int q=0;q<3;++q){b.n[q]=R[q];b.t1[q]=R[3+q];b.t2[q]=R[6+q];}
        r.floats(b.o0,3);r.floats(b.o1,3);for(int q=0;q<3;++q)b.pc[q]=0.0f;
        float k[6],F[9];r.floats(k,6);r.floats(F,9);
        b.kl=k[0];b.kt=k[3];b.k0=k[4];b.k1=k[5];b.capC=F[0];b.capT=F[1];b.capS=F[2];b.gb=F[3];b.gt=F[4];b.g0=F[5];b.g1=F[6];b.h0=F[7];b.h1=F[8];
        b.slip=0.0f;b.bond=l;b.c0=x.a;b.c1=x.b;b.flags=impact::eALIVE|(x.a!=0xffffffffu?impact::eDYNAMIC0:0u)|(x.b!=0xffffffffu?impact::eDYNAMIC1:0u);
        b.area=1.0f;b.dl=b.dt=b.d0=b.d1=1.0f;
        x.state=impact::eEX_LIVE|((flags&4u)?impact::eEX_BEARING:0u);bearing+=(flags&4u)?1u:0u;
        damp[6*size_t(l)]=r.get<float>();
        r.floats(x.J0,6);for(int q=0;q<6;++q)x.J[q]=x.J0[q];x.limit=0.0f;x.slip=0.0f;x.brokeAt=-1.0f;
        bonds[l]=b;links[l]=x;
    }
    if(r.off!=d.size())throw std::runtime_error("problem size mismatch");
    std::vector<PxU32> adj;
    {
        std::vector<std::vector<PxU32>> per(nn);
        for(PxU32 l=0;l<nl;++l){if(links[l].a!=0xffffffffu)per[links[l].a].push_back(l<<1);if(links[l].b!=0xffffffffu)per[links[l].b].push_back((l<<1)|1u);}
        for(PxU32 k=0;k<nn;++k){nodes[k].jointBegin=PxU32(adj.size());adj.insert(adj.end(),per[k].begin(),per[k].end());nodes[k].jointEnd=PxU32(adj.size());nodes[k].rowBegin=nodes[k].rowEnd=0;}
    }
    adj.resize(2*impact::kExLinks);std::vector<PxU32> rowAdj(2*impact::kExRows,0u);
    impact::ExPatch patch{};patch.nodes=nn;patch.chunks=nn;patch.links=nl;patch.rows=0;patch.dynamic=1u;
    impact::ExScratch t{};
    t.patchCount=upload(std::vector<PxU32>{1u});t.patches=upload(std::vector<impact::ExPatch>{patch});
    t.nodes=upload(nodes);t.bonds=upload(bonds);t.links=upload(links);t.adj=upload(adj);t.rowAdj=upload(rowAdj);
    allocate(t.rowBonds,size_t(impact::kExRows));allocate(t.rows,size_t(impact::kExRows));
    allocate(t.wr,12*size_t(impact::kExLinks));allocate(t.rwr,12*size_t(impact::kExRows));allocate(t.jp,impact::kExJoint*size_t(impact::kExLinks));
    allocate(t.jl,size_t(impact::kExLinks));allocate(t.rp,impact::kExRow*size_t(impact::kExRows));
    t.damp=upload(damp);t.dynLoad=upload(load);allocate(t.cslip,2*size_t(impact::kExLinks));
    impact::Settings s{};s.dt=T;s.capacityBand=band;s.explicitDt=h;s.dynamicSequence=1u;s.dynamicFriction=mu;
    impact::Scratch w{};allocate(w.status,1);
    impact::exFinishKernel<<<1,impact::kThreads>>>(s,t);check(cudaDeviceSynchronize());check(cudaGetLastError());
    const bool small=nn<=impact::kExSmall;const PxU32 budget=PxU32(env("DYNAMIC_BUDGET",512.0f));
    const auto t0=std::chrono::steady_clock::now();double longest=0.0;PxU32 launches=0;
    impact::ExPatch p{};
    for(;;) {
        const auto l0=std::chrono::steady_clock::now();
        if(small)impact::exRunSmall<<<1,impact::kExThreads>>>(s,w,t,budget);else impact::exRun<<<1,impact::kExThreads>>>(s,w,t,budget);
        check(cudaMemcpy(&p,t.patches,sizeof p,cudaMemcpyDeviceToHost));check(cudaGetLastError());++launches;
        longest=std::max(longest,std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-l0).count());
        if(p.done)break;
    }
    const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
    // The books (exPublishDynamic's, without the stage's arrays) and the invariant.
    std::vector<impact::ExLink> out(nl);check(cudaMemcpy(out.data(),t.links,sizeof(out[0])*nl,cudaMemcpyDeviceToHost));
    std::vector<impact::ExNode> nout(nn);check(cudaMemcpy(nout.data(),t.nodes,sizeof(nout[0])*nn,cudaMemcpyDeviceToHost));
    double ke=0.0;for(PxU32 k=0;k<nn;++k){const impact::ExNode& n=nout[k];const double m=n.im>0.0f?1.0/n.im:0.0;
        for(int q=0;q<3;++q)ke+=0.5*m*double(n.v[q])*n.v[q]+(n.Iinv[q]>0.0f?0.5/n.Iinv[q]*double(n.v[3+q])*n.v[3+q]:0.0);}
    const double dissipated=double(p.fracture)+p.plastic+p.slipWork+p.dashWork,had=double(p.keStart)+p.u0+std::max(p.extWork,0.0f);
    const bool deficit=dissipated>had;
    std::map<PxU32,float> broken;PxU32 contacts=0;
    for(PxU32 l=0;l<nl;++l){if(out[l].state&impact::eEX_BROKEN)broken[l]=out[l].brokeAt*1e3f;if((out[l].state&impact::eEX_CONTACT) && (out[l].state&impact::eEX_LIVE))++contacts;}
    float first=FLT_MAX;for(const auto& e:broken)first=std::min(first,e.second);
    std::printf("dynamic sequence: %u nodes, %u joints (%u bearing); h %.2f us, %u substeps over %.3f s, %.1f ms in %u launches (longest %.1f ms), %.2f us a substep; "
        "%u events: broke %zu (%u contacts crushed, %u slid off their seats), %u fastenings to contact (%u contacts at the end); "
        "KE %.4g -> %.4g J; dissipated %.4g J (fracture %.4g, slip %.4g, dashpots %.4g) of %.4g J it had (KE %.4g, elastic %.4g, the loads' work %.4g)%s\n",
        nn,nl,bearing,p.h*1e6f,p.substeps,T,ms,launches,longest,1e3*ms/std::max(1u,p.substeps),p.events,broken.size(),p.crushedContacts,p.seatLost,p.converted,contacts,
        p.keStart,ke,dissipated,p.fracture,p.slipWork,p.dashWork,had,p.keStart,p.u0,p.extWork,deficit?"; SEQUENCE ENERGY (dissipated more than it had)":"");
    std::ifstream e(prefix+".expected");PxU32 count=0;e>>count;std::map<PxU32,float> want;
    for(PxU32 i=0;i<count;++i){PxU32 l;float tm;std::string kind;e>>l>>tm>>kind;want[l]=tm;}
    float wfirst=FLT_MAX;for(const auto& x:want)wfirst=std::min(wfirst,x.second);
    PxU32 both=0;for(const auto& x:broken)both+=want.count(x.first)?1u:0u;
    const double jac=broken.empty() && want.empty()?1.0:double(both)/double(std::max<size_t>(1,broken.size()+want.size()-both));
    const double need=env("DYNAMIC_MIN_JACCARD",0.9f),firstTol=env("DYNAMIC_FIRST_MS",2.0f);
    const bool firstOk=(broken.empty() && want.empty()) || std::fabs(double(first)-wfirst)<=firstTol;
    std::printf("against the reference: %zu broken there, Jaccard %.3f (need %.2f); first break %.2f ms vs %.2f ms (need within %.1f ms)\n",
        want.size(),jac,need,broken.empty()?-1.0f:first,want.empty()?-1.0f:wfirst,firstTol);
    if(std::getenv("DYNAMIC_LIST")){for(const auto& x:broken)std::printf("  gpu %u %.2f ms%s\n",x.first,x.second,want.count(x.first)?"":" (not in the reference)");
        for(const auto& x:want)if(!broken.count(x.first))std::printf("  reference only %u %.2f ms\n",x.first,x.second);}
    return (jac<need || !firstOk || deficit)?1:0;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
