// The explicit impact step's two-body window (PxgDestructionImpactExplicit.cuh,
// Settings::explicitTwoBody) on a problem exported by vibe-land
// scripts/impact/two-body.py --export, checked against that harness's result:
// a car's bond graph and a struck structure's in one patch, compliant rows
// between them (Johnson's flat punch, backward Euler), the car's stiff joints
// implicit (trapezoidal, two sweeps, split masses) where explicit integration at
// h would not be stable.
//
//   destruction_two_body_replay PREFIX     (PREFIX.bin, PREFIX.expected)
//
// PREFIX.bin: 'TWOB', nodes, joints, rows, dt, h, band, 0; per node: car,
// inverse mass, inverse scalar inertia, v[6]; per joint: a, b (~0 held), flags
// (1 ductile, 2 the car's), R[9] (n, t1, t2), o0[3], o1[3], k[6], F[9]
// (capacities and gains), ultimate slip, J0[6]; per row: a, b, compliant,
// R[9], o0[3], o1[3], friction, E*, sigma, R_hertz, face, gap.
// PREFIX.expected: the car's dv, its yielded joints, the broken joints.
// Gates (FP32 against the harness's FP64): the broken sets' Jaccard index >=
// TWO_BODY_MIN_JACCARD (0.9), the car's dv within 3% (the harness's own spread
// between h and h/2 on the brittle 10 m/s case is 9%: a brittle chain's order
// moves with rounding), its yielded joints within 5%, and the energy invariant
// (no patch dissipates more than it had).
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
    if(std::memcmp(d.data(),"TWOB",4))throw std::runtime_error("not a two-body problem");r.off=4;
    const PxU32 nn=r.get<PxU32>(),nl=r.get<PxU32>(),nr=r.get<PxU32>();const float dt=r.get<float>(),h=r.get<float>(),band=r.get<float>();r.get<float>();
    if(nn>impact::kExNodes || nl>impact::kExLinks || nr>impact::kExRows)throw std::runtime_error("problem larger than a patch");
    std::vector<impact::ExNode> nodes(impact::kExNodes);std::vector<float> mass(nn);std::vector<bool> car(nn);
    PxU32 carNodes=0;
    for(PxU32 k=0;k<nn;++k) {
        impact::ExNode n{};n.chunk=k;n.tensor=0;n.pad[1]=r.get<PxU32>();car[k]=n.pad[1]!=0;carNodes+=car[k]?1u:0u;
        n.im=r.get<float>();const float ii=r.get<float>();n.Iinv[0]=n.Iinv[1]=n.Iinv[2]=ii;r.floats(n.v,6);for(int q=0;q<6;++q)n.v0[q]=n.v[q];
        mass[k]=n.im>0.0f?1.0f/n.im:0.0f;nodes[k]=n;
    }
    std::vector<impact::Bond> bonds(impact::kExLinks);std::vector<impact::ExLink> links(impact::kExLinks);std::vector<bool> carJoint(nl);
    for(PxU32 l=0;l<nl;++l) {
        impact::Bond b{};impact::ExLink x{};x.a=r.get<PxU32>();x.b=r.get<PxU32>();const PxU32 flags=r.get<PxU32>();
        float R[9];r.floats(R,9);for(int q=0;q<3;++q){b.n[q]=R[q];b.t1[q]=R[3+q];b.t2[q]=R[6+q];}
        r.floats(b.o0,3);r.floats(b.o1,3);for(int q=0;q<3;++q)b.pc[q]=0.0f;
        float k[6],F[9];r.floats(k,6);r.floats(F,9);
        b.kl=k[0];b.kt=k[3];b.k0=k[4];b.k1=k[5];b.capC=F[0];b.capT=F[1];b.capS=F[2];b.gb=F[3];b.gt=F[4];b.g0=F[5];b.g1=F[6];b.h0=F[7];b.h1=F[8];
        b.slip=r.get<float>();b.bond=l;b.c0=x.a;b.c1=x.b;b.flags=impact::eALIVE|(x.a!=0xffffffffu?impact::eDYNAMIC0:0u)|(x.b!=0xffffffffu?impact::eDYNAMIC1:0u)|((flags&1u)?impact::eDUCTILE:0u);
        b.area=1.0f;b.dl=b.dt=b.d0=b.d1=1.0f;
        x.state=impact::eEX_LIVE|((flags&1u)?impact::eEX_DUCTILE:0u)|((flags&2u)?impact::eEX_CAR:0u);carJoint[l]=(flags&2u)!=0;
        r.floats(x.J0,6);for(int q=0;q<6;++q)x.J[q]=x.J0[q];x.limit=b.slip;x.slip=0.0f;x.brokeAt=-1.0f;
        bonds[l]=b;links[l]=x;
    }
    std::vector<impact::Bond> rowBonds(impact::kExRows);std::vector<impact::ExRow> rows(impact::kExRows);PxU32 compliant=0;
    for(PxU32 i=0;i<nr;++i) {
        impact::ExRow x{};x.a=r.get<PxU32>();x.b=r.get<PxU32>();x.compliant=r.get<PxU32>();x.row=i;compliant+=x.compliant;
        impact::Bond b{};float R[9];r.floats(R,9);for(int q=0;q<3;++q){b.n[q]=R[q];b.t1[q]=R[3+q];b.t2[q]=R[6+q];}
        r.floats(b.o0,3);r.floats(b.o1,3);b.area=r.get<float>();x.Estar=r.get<float>();x.sigma=r.get<float>();x.R=r.get<float>();x.face=r.get<float>();x.gap=r.get<float>();x.d=0.0f;
        b.flags=impact::eALIVE|impact::eDYNAMIC0|impact::eDYNAMIC1|impact::eCONTACT;b.kl=b.kt=b.k0=b.k1=FLT_MAX;
        rowBonds[i]=b;rows[i]=x;
    }
    if(r.off!=d.size())throw std::runtime_error("problem size mismatch");
    // Each node's joints and rows (CSR, link order).
    std::vector<PxU32> adj,rowAdj;
    for(PxU32 k=0;k<nn;++k) {
        nodes[k].jointBegin=PxU32(adj.size());
        for(PxU32 l=0;l<nl;++l){if(links[l].a==k)adj.push_back(l<<1);if(links[l].b==k)adj.push_back((l<<1)|1u);}
        nodes[k].jointEnd=PxU32(adj.size());
        nodes[k].rowBegin=PxU32(rowAdj.size());
        for(PxU32 i=0;i<nr;++i){if(rows[i].a==k)rowAdj.push_back(i<<1);if(rows[i].b==k)rowAdj.push_back((i<<1)|1u);}
        nodes[k].rowEnd=PxU32(rowAdj.size());
    }
    adj.resize(2*impact::kExLinks);rowAdj.resize(2*impact::kExRows);
    impact::ExPatch patch{};patch.nodes=nn;patch.chunks=nn;patch.links=nl;patch.rows=nr;patch.twoBody=1u;patch.carChunks=carNodes;patch.compliant=compliant;
    impact::ExScratch t{};
    t.patchCount=upload(std::vector<PxU32>{1u});t.patches=upload(std::vector<impact::ExPatch>{patch});
    t.nodes=upload(nodes);t.bonds=upload(bonds);t.links=upload(links);t.rowBonds=upload(rowBonds);t.rows=upload(rows);t.adj=upload(adj);t.rowAdj=upload(rowAdj);
    allocate(t.wr,12*size_t(impact::kExLinks));allocate(t.rwr,12*size_t(impact::kExRows));allocate(t.jp,impact::kExJoint*size_t(impact::kExLinks));
    allocate(t.jl,size_t(impact::kExLinks));allocate(t.rp,impact::kExRow*size_t(impact::kExRows));
    allocate(t.vStart,6*size_t(impact::kExNodes));allocate(t.ja,9*size_t(impact::kExLinks));allocate(t.wd,12*size_t(impact::kExLinks));
    impact::Settings s{};s.dt=dt;s.capacityBand=band;s.explicitDt=h;s.explicitTwoBody=true;
    impact::Scratch w{};
    impact::exFinishKernel<<<1,impact::kThreads>>>(s,t);check(cudaDeviceSynchronize());check(cudaGetLastError());
    const bool small=nn<=impact::kExSmall;
    const auto t0=std::chrono::steady_clock::now();
    if(small)impact::exRunSmall<<<1,impact::kExThreads>>>(s,w,t,PxU32(env("TWO_BODY_BUDGET",1e6f)));
    else impact::exRun<<<1,impact::kExThreads>>>(s,w,t,PxU32(env("TWO_BODY_BUDGET",1e6f)));
    check(cudaDeviceSynchronize());check(cudaGetLastError());
    const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
    impact::ExPatch p{};check(cudaMemcpy(&p,t.patches,sizeof p,cudaMemcpyDeviceToHost));
    std::vector<impact::ExLink> out(nl);check(cudaMemcpy(out.data(),t.links,sizeof(out[0])*nl,cudaMemcpyDeviceToHost));
    std::vector<impact::ExNode> nout(nn);check(cudaMemcpy(nout.data(),t.nodes,sizeof(nout[0])*nn,cudaMemcpyDeviceToHost));
    std::set<PxU32> broken;PxU32 yielded=0;
    for(PxU32 l=0;l<nl;++l){if(out[l].state&impact::eEX_BROKEN)broken.insert(l);if(carJoint[l] && (out[l].state&impact::eEX_YIELDED))++yielded;}
    double pm[3]={0,0,0},p0[3]={0,0,0},m=0.0,ke0=0.0,ke1=0.0;
    for(PxU32 k=0;k<nn;++k) {
        const double mk=mass[k],I=nout[k].Iinv[0]>0.0f?1.0/nout[k].Iinv[0]:0.0;
        for(int q=0;q<3;++q){ke0+=0.5*mk*double(nout[k].v0[q])*nout[k].v0[q]+0.5*I*double(nout[k].v0[3+q])*nout[k].v0[3+q];ke1+=0.5*mk*double(nout[k].v[q])*nout[k].v[q]+0.5*I*double(nout[k].v[3+q])*nout[k].v[3+q];}
        if(!car[k])continue;m+=mk;for(int q=0;q<3;++q){pm[q]+=mk*nout[k].v[q];p0[q]+=mk*nout[k].v0[q];}
    }
    const double dv[3]={(pm[0]-p0[0])/m,(pm[1]-p0[1])/m,(pm[2]-p0[2])/m};
    // The energy invariant: what the window dissipated by fracture and plastic work
    // is paid by the kinetic energy it lost, the elastic energy its joints held and
    // the dead load's work.
    const bool deficit=p.fracture+p.plastic>(ke0-ke1)+p.u0+std::max(p.dead,0.0f);
    std::printf("two-body: %u nodes (%u the car's), %u joints (%u implicit), %u rows (%u compliant); h %.2f us, %u substeps, %.2f ms; "
        "broke %zu, car yielded %u; car dv (%.3f %.3f %.3f) m/s; kinetic %.1f -> %.1f kJ, fracture %.2f, plastic %.2f kJ%s\n",
        p.nodes,carNodes,p.links,p.implicitJoints,p.rows,p.compliant,p.h*1e6f,p.substeps,ms,broken.size(),yielded,dv[0],dv[1],dv[2],ke0/1e3,ke1/1e3,p.fracture/1e3,p.plastic/1e3,
        deficit?"; ENERGY DEFICIT":"");
    std::ifstream e(prefix+".expected");double edv[3];PxU32 eyield=0;e>>edv[0]>>edv[1]>>edv[2]>>eyield;std::set<PxU32> want;PxU32 x;while(e>>x)want.insert(x);
    PxU32 both=0;for(PxU32 l:broken)both+=want.count(l)?1u:0u;
    const double jac=double(both)/double(std::max<size_t>(1,broken.size()+want.size()-both));
    const double edvn=std::sqrt(edv[0]*edv[0]+edv[1]*edv[1]+edv[2]*edv[2]),ddv=std::sqrt((dv[0]-edv[0])*(dv[0]-edv[0])+(dv[1]-edv[1])*(dv[1]-edv[1])+(dv[2]-edv[2])*(dv[2]-edv[2]));
    const double relv=edvn>0.0?ddv/edvn:ddv,rely=eyield?std::fabs(double(yielded)-eyield)/eyield:double(yielded);
    const double need=env("TWO_BODY_MIN_JACCARD",0.9f);
    std::printf("against the harness: %zu broken there, Jaccard %.3f (need %.2f); car dv %.3f vs %.3f m/s (%.2f%%, need 3%%); yielded %u vs %u (%.1f%%, need 5%%)\n",
        want.size(),jac,need,std::sqrt(dv[0]*dv[0]+dv[1]*dv[1]+dv[2]*dv[2]),edvn,100.0*relv,yielded,eyield,100.0*rely);
    return (jac<need || relv>0.03 || rely>0.05 || deficit)?1:0;
}
}} // physx
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 2;}}
