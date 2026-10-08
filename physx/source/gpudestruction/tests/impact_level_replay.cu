// One level of the impact solve (an IMPACT_DUMP island: the level's QP, its
// links' capacity sets and wrench blocks) through the stage's own ADMM
// (impact::solve), on its own: no ramp, no trial, no verdict. The smallest unit
// that reproduces a convergence fault, and the test that it converges.
//
//   destruction_impact_level_replay DUMP.bin [ORACLE.f64]
//
// The dump's start: J (the island's last converged state), U = 0, rho
// IMPACT_RHO (1). Every dispatch stays within Settings::dispatchWork.
// Prints the residuals per dispatch (IMPACT_TRACE_EVERY steps with
// IMPACT_TRACE=1), the objective, and with ORACLE (the FP64 optimum's J, nl x 6
// doubles, scripts/impact/admm-fp64.py --oracle-out) the largest difference of
// the objective gap and the contact forces' difference from it.
// Settings: IMPACT_LENGTH_SCALE (required: the capture's), IMPACT_ITERATIONS,
// IMPACT_INNER, IMPACT_INNER_TOLERANCE, IMPACT_TOLERANCE.
// Exit status (a test): 0 when the solve converges within IMPACT_ITERATIONS
// with its J step exact enough on every step (and agrees with ORACLE:
// IMPACT_AGREE_OBJECTIVE, IMPACT_AGREE_CONTACT), 1 not.
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
#include <map>
#include <stdexcept>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));check(cudaMemset(p,0,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"
template<class T>T* upload(const std::vector<T>& v){T* p;allocate(p,v.size());if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));return p;}
template<class T>std::vector<T> download(const T* p,size_t n){std::vector<T> v(n);if(n)check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
float env(const char* name,float fallback){const char* v=std::getenv(name);return v && *v?float(std::atof(v)):fallback;}

__global__ __launch_bounds__(impact::kThreads) void levelSolve(impact::Inputs in,impact::Settings s,impact::Scratch w,impact::Island is,impact::SolveState* state,PxU32* out)
{
    __shared__ impact::Shared sh;
    float budget=float(s.dispatchWork);
    const float units=float(max(impact::links(is)+impact::nodes(is),impact::kThreads));
    impact::SolveState ss=*state;bool done,capped;
    const PxU32 run=impact::solve(sh,in,s,w,is,1.0f,ss,budget,units,done,capped);
    __syncthreads();
    if(!threadIdx.x){*state=ss;out[0]=done?1u:0u;out[1]=capped?1u:0u;out[2]=run;}
}

struct Dump {
    PxU32 nn,nl,nb,nr;float dt,lambda,band,capTol;
    std::vector<PxU32> nodeChunk,nodeTensor;std::vector<float> nodeF;     // 14 per node
    std::vector<PxU32> linkU;std::vector<float> linkF,J,T,B;              // 4, 14, 6, 6, 72 per link
};
Dump load(const char* path)
{
    FILE* f=std::fopen(path,"rb");if(!f)throw std::runtime_error("cannot open the dump");
    auto rd=[&](void* p,size_t n){if(std::fread(p,1,n,f)!=n)throw std::runtime_error("short dump");};
    Dump d;PxU32 h[4];float fh[4];rd(h,16);rd(fh,16);
    d.nn=h[0];d.nl=h[1];d.nb=h[2];d.nr=h[3];d.dt=fh[0];d.lambda=fh[1];d.band=fh[2];d.capTol=fh[3];
    d.nodeChunk.resize(d.nn);d.nodeTensor.resize(d.nn);d.nodeF.resize(14*size_t(d.nn));
    for(PxU32 i=0;i<d.nn;++i){PxU32 u[2];rd(u,8);d.nodeChunk[i]=u[0];d.nodeTensor[i]=u[1];rd(&d.nodeF[14*i],56);}
    d.linkU.resize(4*size_t(d.nl));d.linkF.resize(14*size_t(d.nl));d.J.resize(6*size_t(d.nl));d.T.resize(6*size_t(d.nl));d.B.resize(72*size_t(d.nl));
    for(PxU32 l=0;l<d.nl;++l){rd(&d.linkU[4*l],16);rd(&d.linkF[14*l],56);rd(&d.J[6*l],24);rd(&d.T[6*l],24);rd(&d.B[72*l],288);}
    std::fclose(f);return d;
}
void hcross(const float* a,const float* b,float* c){c[0]=a[1]*b[2]-a[2]*b[1];c[1]=a[2]*b[0]-a[0]*b[2];c[2]=a[0]*b[1]-a[1]*b[0];}
// impact::addWrench on the host (the reconstruction's check).
void hostWrench(const impact::Bond& b,const float* x,bool first,float* r)
{
    float lin[3],ang[3];for(int k=0;k<3;++k){lin[k]=x[0]*b.n[k]+x[1]*b.t1[k]+x[2]*b.t2[k];ang[k]=x[3]*b.n[k]+x[4]*b.t1[k]+x[5]*b.t2[k];}
    const float* o=first?b.o0:b.o1;const float s=first?1.0f:-1.0f;float m[3];hcross(o,lin,m);
    for(int k=0;k<3;++k){r[k]+=s*lin[k];r[3+k]+=s*(m[k]-ang[k]);}
}
void invert3(const float* S,float* I)
{
    const double A=double(S[1])*S[2]-double(S[5])*S[5],B=double(S[0])*S[2]-double(S[4])*S[4],C=double(S[0])*S[1]-double(S[3])*S[3];
    const double D=double(S[4])*S[5]-double(S[3])*S[2],E=double(S[3])*S[5]-double(S[1])*S[4],F=double(S[3])*S[4]-double(S[0])*S[5];
    const double det=S[0]*A+S[3]*D+S[4]*E;const double k=1.0/det;
    I[0]=float(A*k);I[1]=float(B*k);I[2]=float(C*k);I[3]=float(D*k);I[4]=float(E*k);I[5]=float(F*k);
}

int run(int argc,char** argv)
{
    if(argc<2){std::fprintf(stderr,"usage: %s DUMP.bin [ORACLE.f64]\n",argv[0]);return 2;}
    const Dump d=load(argv[1]);
    const PxU32 nn=d.nn,nl=d.nl,nc=[&]{PxU32 c=0;while(c<nn && !d.nodeTensor[c])++c;return c;}(),ni=nn-nc;
    // Node ids: 0..nc-1 the chunks, nc.. the impactors (chunkCount = nc); an
    // anchored end gets an id no node has.
    const PxU32 kAnchor=0xfffffff0u;
    std::map<PxU32,PxU32> id;for(PxU32 i=0;i<nn;++i)id[d.nodeChunk[i]]=i;
    impact::Settings s{};
    s.dt=d.dt;s.capacityTolerance=d.capTol;s.capacityBand=d.band;
    s.lengthScale=env("IMPACT_LENGTH_SCALE",0.0f);if(!(s.lengthScale>0.0f))throw std::runtime_error("IMPACT_LENGTH_SCALE (the capture's) is required");
    s.iterations=PxU32(env("IMPACT_ITERATIONS",32768.0f));s.innerIterations=PxU32(env("IMPACT_INNER",float(s.innerIterations)));
    s.innerTolerance=env("IMPACT_INNER_TOLERANCE",s.innerTolerance);s.tolerance=env("IMPACT_TOLERANCE",s.tolerance);
    s.dispatchWork=PxU32(env("IMPACT_DISPATCH_WORK",float(s.dispatchWork)));
    // The bonds, from the dump's wrench blocks: n, t1, t2 are a unit force's
    // linear rows on chunk0; o0 = 1/2 sum_q e_q x (o0 x e_q).
    std::vector<impact::Bond> bonds(nl);std::vector<std::vector<PxU32>> adj(nn);
    for(PxU32 l=0;l<nl;++l) {
        impact::Bond b{};const PxU32* u=&d.linkU[4*l];const float* f=&d.linkF[14*l];const float* B0=&d.B[72*l];const float* B1=B0+36;
        b.bond=u[0];b.flags=u[3];
        auto node=[&](PxU32 c,PxU32 flag)->PxU32{if(!(b.flags&flag))return kAnchor;auto it=id.find(c);if(it==id.end())throw std::runtime_error("a dynamic end outside the island");return it->second;};
        b.c0=node(u[1],impact::eDYNAMIC0);b.c1=node(u[2],impact::eDYNAMIC1);
        for(int k=0;k<3;++k){b.n[k]=B0[6*k+0];b.t1[k]=B0[6*k+1];b.t2[k]=B0[6*k+2];}
        float o0[3]={0,0,0},o1[3]={0,0,0};
        for(int q=0;q<3;++q) {
            const float e[3]={B0[0*6+q],B0[1*6+q],B0[2*6+q]};          // the frame vector q (chunk0's lin, +)
            const float m0[3]={B0[3*6+q],B0[4*6+q],B0[5*6+q]};        // o0 x e
            const float m1[3]={-B1[3*6+q],-B1[4*6+q],-B1[5*6+q]};     // o1 x e (chunk1's is -(o1 x e))
            float c[3];hcross(e,m0,c);for(int k=0;k<3;++k)o0[k]+=0.5f*c[k];
            hcross(e,m1,c);for(int k=0;k<3;++k)o1[k]+=0.5f*c[k];
        }
        for(int k=0;k<3;++k){b.o0[k]=o0[k];b.o1[k]=o1[k];b.pc[k]=0.0f;}
        b.capC=f[0];b.capT=f[1];b.capS=f[2];b.gb=f[3];b.gt=f[4];b.g0=f[5];b.g1=f[6];b.h0=f[7];b.h1=f[8];
        b.kl=f[9];b.kt=f[10];b.k0=f[11];b.k1=f[12];b.ks=b.kl;b.dl=b.dt=b.d0=b.d1=1.0f;b.slip=0.0f;   // isotropic (dumps predate shear stiffness)
        b.area=(b.flags&impact::eCONTACT)?f[13]:1.0f;
        bonds[l]=b;
        if(b.c0!=kAnchor)adj[b.c0].push_back(l);
        if(b.c1!=kAnchor)adj[b.c1].push_back(l);
    }
    // Check the reconstruction: addWrench of each unit force against the dump's blocks.
    double worstB=0.0;
    for(PxU32 l=0;l<nl;++l)for(int q=0;q<6;++q){float x[6]={0,0,0,0,0,0};x[q]=1.0f;float r0[6]={0,0,0,0,0,0},r1[6]={0,0,0,0,0,0};
        hostWrench(bonds[l],x,true,r0);hostWrench(bonds[l],x,false,r1);
        for(int k=0;k<6;++k)worstB=std::max(worstB,std::max(std::fabs(double(r0[k])-d.B[72*l+6*k+q]),std::fabs(double(r1[k])-d.B[72*l+36+6*k+q])));}
    std::vector<PxU32> adjFlat;std::vector<impact::Chunk> chunks(nn);std::vector<PxDestructionStressChunk> stress(nc);std::vector<float> impactorMass(2*size_t(std::max(ni,1u)));
    for(PxU32 i=0;i<nn;++i) {
        impact::Chunk c{};const float* f=&d.nodeF[14*i];
        c.chunk=i;c.begin=PxU32(adjFlat.size());for(PxU32 l:adj[i])adjFlat.push_back(l);c.end=PxU32(adjFlat.size());
        c.tensor=d.nodeTensor[i];c.im=f[0];c.ii=f[1];
        for(int q=0;q<6;++q){c.pb[q]=c.pf[q]=f[8+q];c.r[q]=0.0f;}
        if(c.tensor){for(int q=0;q<6;++q)c.Iinv[q]=f[2+q];invert3(c.Iinv,c.I);
            float largest=0.0f;const int m3[3][3]={{0,3,4},{3,1,5},{4,5,2}};
            for(int a=0;a<3;++a)largest=std::max(largest,std::fabs(c.Iinv[m3[a][0]])+std::fabs(c.Iinv[m3[a][1]])+std::fabs(c.Iinv[m3[a][2]]));
            impactorMass[2*(i-nc)]=c.im;impactorMass[2*(i-nc)+1]=largest;}
        else {stress[i].mass=1.0f/c.im;stress[i].inertia=c.ii>0.0f?1.0f/c.ii:0.0f;}
        chunks[i]=c;
    }
    impact::Inputs in{};in.chunkCount=nc;in.chunks=upload(stress);
    impact::Scratch w{};
    w.bonds=upload(bonds);w.chunks=upload(chunks);w.adj=upload(adjFlat);w.impactorMass=upload(impactorMass);
    allocate(w.degree,nn);
    std::vector<float> J(d.J);for(PxU32 l=0;l<nl;++l)if(!(bonds[l].flags&impact::eALIVE))for(int q=0;q<6;++q)J[6*l+q]=0.0f;
    w.J=upload(J);w.T=upload(d.T);allocate(w.Y,6*size_t(nl));allocate(w.Jn,6*size_t(nl));allocate(w.a,6*size_t(nl));
    allocate(w.u,6*size_t(nn));allocate(w.cy,6*size_t(nn));allocate(w.cr,6*size_t(nn));allocate(w.cz,6*size_t(nn));allocate(w.cp,6*size_t(nn));allocate(w.cq,6*size_t(nn));
    allocate(w.cinv,36*size_t(nn));allocate(w.status,1);
    float* trace=nullptr;const bool tracing=std::getenv("IMPACT_TRACE")!=nullptr;
    if(tracing){allocate(trace,4*size_t(impact::kTraceCapacity));w.trace=trace;w.traceSolve=0;w.traceStride=PxU32(std::max(1.0f,env("IMPACT_TRACE_STRIDE",std::max(1.0f,float(s.iterations)/impact::kTraceCapacity))));}
    impact::Island is{0,d.nb,d.nr,0,nc,ni};
    impact::SolveState ss{};ss.rho=env("IMPACT_RHO",1.0f);
    // IMPACT_START: resume from a capped solve's state (the dump's .state.bin): Z, U, y and rho.
    if(const char* path=std::getenv("IMPACT_START")) {
        FILE* f=std::fopen(path,"rb");if(!f)throw std::runtime_error("cannot open the start state");
        float head[2];std::vector<float> Z(6*size_t(nl)),U(6*size_t(nl)),y(6*size_t(nn));
        if(std::fread(head,4,2,f)!=2 || std::fread(Z.data(),4,Z.size(),f)!=Z.size() || std::fread(U.data(),4,U.size(),f)!=U.size() || std::fread(y.data(),4,y.size(),f)!=y.size())throw std::runtime_error("short start state");
        std::fclose(f);
        check(cudaMemcpy(w.Y,Z.data(),sizeof(float)*Z.size(),cudaMemcpyHostToDevice));check(cudaMemcpy(w.Jn,U.data(),sizeof(float)*U.size(),cudaMemcpyHostToDevice));
        check(cudaMemcpy(w.cy,y.data(),sizeof(float)*y.size(),cudaMemcpyHostToDevice));
        ss.rho=env("IMPACT_RHO",head[0]);ss.started=1;
        std::printf("  resuming from %s: rho %.4g after %.0f steps\n",path,head[0],head[1]);
    }
    impact::SolveState* dss=upload(std::vector<impact::SolveState>{ss});PxU32* out;allocate(out,4);
    std::printf("%s: %u nodes (%u chunks, %u impactors), %u links (%u joints, %u contacts), lambda %.4g; wrench blocks rebuilt to %.2e\n",
        argv[1],nn,nc,ni,nl,d.nb,d.nr,d.lambda,worstB);
    std::printf("  settings: tolerance %.2e, capacity tolerance %.2e, inner %u to %.3g x tolerance, length scale %.4g, rho0 %.4g, %u steps\n",
        s.tolerance,s.capacityTolerance,s.innerIterations,s.innerTolerance,s.lengthScale,ss.rho,s.iterations);
    PxU32 o[4]={0,0,0,0};double longest=0.0;size_t dispatches=0;const auto t0=std::chrono::steady_clock::now();
    while(!o[0]) {
        const auto a=std::chrono::steady_clock::now();
        levelSolve<<<1,impact::kThreads>>>(in,s,w,is,dss,out);check(cudaDeviceSynchronize());check(cudaGetLastError());
        longest=std::max(longest,std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-a).count());++dispatches;
        check(cudaMemcpy(o,out,16,cudaMemcpyDeviceToHost));check(cudaMemcpy(&ss,dss,sizeof ss,cudaMemcpyDeviceToHost));
        if(!tracing && dispatches%50==1)std::printf("  dispatch %zu: step %u, residual %.3e, rho %.4g\n",dispatches,ss.it,ss.last,ss.rho);
    }
    const double ms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t0).count();
    const auto st=download(w.status,1)[0];
    const bool converged=!o[1];
    std::printf("  %s after %u steps (residual %.3e, rho %.4g); %zu dispatches, %.0f ms, longest %.1f ms; %u infeasible, %u diverged, %u non-finite, %u energy gains\n",
        converged?"converged":"CAPPED",ss.it,ss.last,ss.rho,dispatches,ms,longest,st.infeasible,st.diverged,st.nonfinite,st.energyGain);
    if(tracing) {
        const auto t=download(trace,4*size_t(impact::kTraceCapacity));const PxU32 every=PxU32(std::max(1.0f,env("IMPACT_TRACE_EVERY",256.0f)/w.traceStride));
        for(PxU32 i=0;i<impact::kTraceCapacity && i*w.traceStride<ss.it;i+=every)
            std::printf("  step %8u: primal %.3e dual %.3e motion %.3e rho %.4g\n",i*w.traceStride,t[4*i],t[4*i+1],t[4*i+2],t[4*i+3]);
    }
    // The answer: Z (the feasible iterate) when capped, J (= Z) when converged.
    const auto Z=download(converged?w.J:w.Y,6*size_t(nl));
    // The objective in double: 1/2 |q + B J|^2_{M^-1} + 1/2 sum (J - T)^2 / (k dt^2).
    auto objective=[&](const std::vector<double>& x){
        std::vector<double> r(6*size_t(nn));for(PxU32 i=0;i<nn;++i)for(int q=0;q<6;++q)r[6*i+q]=d.nodeF[14*i+8+q];
        double c=0.0;
        for(PxU32 l=0;l<nl;++l){const auto& b=bonds[l];if(!(b.flags&impact::eALIVE))continue;
            for(int e=0;e<2;++e){const PxU32 n=e?b.c1:b.c0;if(n==kAnchor)continue;
                for(int k=0;k<6;++k){double v=0.0;for(int q=0;q<6;++q)v+=double(d.B[72*l+36*e+6*k+q])*x[6*l+q];r[6*n+k]+=v;}}
            if(!(b.flags&impact::eCONTACT)){const float k6[6]={b.kl,b.kl,b.kl,b.kt,b.k0,b.k1};
                for(int q=0;q<6;++q){const double dd=x[6*l+q]-d.T[6*l+q];c+=0.5*dd*dd/(double(k6[q])*d.dt*d.dt);}}}
        for(PxU32 i=0;i<nn;++i){const float* f=&d.nodeF[14*i];
            for(int q=0;q<3;++q)c+=0.5*r[6*i+q]*r[6*i+q]*f[0];
            if(d.nodeTensor[i]){const float* S=f+2;const double v[3]={r[6*i+3],r[6*i+4],r[6*i+5]};
                const double Sv[3]={S[0]*v[0]+S[3]*v[1]+S[4]*v[2],S[3]*v[0]+S[1]*v[1]+S[5]*v[2],S[4]*v[0]+S[5]*v[1]+S[2]*v[2]};
                c+=0.5*(v[0]*Sv[0]+v[1]*Sv[1]+v[2]*Sv[2]);}
            else for(int q=3;q<6;++q)c+=0.5*r[6*i+q]*r[6*i+q]*f[1];}
        return c;};
    const std::vector<double> z(Z.begin(),Z.end());
    std::printf("  objective %.9g\n",objective(z));
    // The J step's exactness on every step: its CG reached its limit (none
    // ran out of iterations), and the worst residual left is within the bound
    // its error allows, 1 / (4 (1 + |o|/L)) for the island's longest lever.
    float lever=0.0f;for(const auto& b:bonds){if(!(b.flags&impact::eALIVE))continue;
        if(b.flags&impact::eDYNAMIC0)lever=std::max(lever,std::sqrt(b.o0[0]*b.o0[0]+b.o0[1]*b.o0[1]+b.o0[2]*b.o0[2]));
        if(b.flags&impact::eDYNAMIC1)lever=std::max(lever,std::sqrt(b.o1[0]*b.o1[0]+b.o1[1]*b.o1[1]+b.o1[2]*b.o1[2]));}
    float innerWorst;std::memcpy(&innerWorst,&st.innerWorst,4);
    const float bound=1.0f/(4.0f*(1.0f+lever/s.lengthScale));
    const bool exact=st.innerShort==0 && innerWorst<=bound*1.0001f;
    std::printf("  J step: worst residual %.3g x tolerance (%u steps short of their limit); the error bound allows %.3g (longest lever %.3g m, L %.3g m): %s\n",
        innerWorst,st.innerShort,bound,lever,s.lengthScale,exact?"exact enough":"NOT");
    int status=converged && exact?0:1;
    if(argc>2) {
        FILE* f=std::fopen(argv[2],"rb");if(!f)throw std::runtime_error("cannot open the oracle");
        std::vector<double> x(6*size_t(nl));if(std::fread(x.data(),8,x.size(),f)!=x.size())throw std::runtime_error("short oracle");std::fclose(f);
        // What the level decides, against the optimum: its objective (the
        // tick's kinetic and the joints' complementary energy) as a fraction of
        // the problem's scale (that of J = 0), and the impactor's contact
        // impulses as a fraction of the largest. Single joint forces are
        // reported, not judged: along a near-mechanism the objective is nearly
        // flat in them (joints k dt^2 / m >> 1 share a load almost freely), so
        // a solution within tolerance may carry a load on a neighbouring joint.
        const double scale=objective(std::vector<double>(6*size_t(nl),0.0));
        const double gap=(objective(z)-objective(x))/scale;
        double worstF=0.0,largest=0.0;PxU32 atF=0;
        for(PxU32 l=0;l<nl;++l){const auto& b=bonds[l];if(!(b.flags&impact::eCONTACT) || !(b.flags&impact::eALIVE))continue;
            double fz[3]={0,0,0},fx[3]={0,0,0};
            for(int k=0;k<3;++k)for(int q=0;q<6;++q){fz[k]+=double(d.B[72*l+6*k+q])*z[6*l+q];fx[k]+=double(d.B[72*l+6*k+q])*x[6*l+q];}
            largest=std::max(largest,std::sqrt(fx[0]*fx[0]+fx[1]*fx[1]+fx[2]*fx[2]));
            const double e=std::sqrt((fz[0]-fx[0])*(fz[0]-fx[0])+(fz[1]-fx[1])*(fz[1]-fx[1])+(fz[2]-fx[2])*(fz[2]-fx[2]));if(e>worstF){worstF=e;atF=l;}}
        const double relF=largest>0.0?worstF/largest:0.0;
        double worst=0.0;PxU32 at=0;
        for(PxU32 l=0;l<nl;++l){const auto& b=bonds[l];if(!(b.flags&impact::eALIVE) || (b.flags&impact::eCONTACT))continue;
            double lf=0.0,af=0.0;for(int q=0;q<6;++q){const double dd=z[6*l+q]-x[6*l+q];(q<3?lf:af)+=dd*dd;}
            const double gain=std::max(std::max(b.gb,b.gt),std::max(b.g0,b.g1)),cap=std::max(std::max(b.capC,b.capT),b.capS);
            const double e=(std::sqrt(lf)+gain*std::sqrt(af))/cap;if(e>worst){worst=e;at=l;}}
        // The joints at capacity (utilisation >= 1 - capacityBand: the
        // brittle ones break at this level), here and at the optimum.
        auto util=[&](const impact::Bond& b,const double* v){
            const double N=v[0],V=std::hypot(v[1],v[2]),T=std::fabs(v[3]),M=std::hypot(v[4],v[5]);
            const double bend=b.g0>0.0f?b.g0*std::fabs(v[4])+b.g1*std::fabs(v[5]):b.gb*M,pull=b.g0>0.0f?b.h0*std::fabs(v[4])+b.h1*std::fabs(v[5]):bend;
            auto r=[](double dd,double c){return dd<=0.0?0.0:(c>0.0?dd/c:1e30);};
            return std::max(std::max(r(std::max(bend-N,0.0),b.capC),r(std::max(N+pull,0.0),b.capT)),r(V+b.gt*T,b.capS));};
        PxU32 atBoth=0,onlyHere=0,onlyOptimum=0,brittleDiffer=0;
        for(PxU32 l=0;l<nl;++l){const auto& b=bonds[l];if(!(b.flags&impact::eALIVE) || (b.flags&impact::eCONTACT))continue;
            const bool h=util(b,&z[6*l])>=1.0-d.band,o=util(b,&x[6*l])>=1.0-d.band;
            atBoth+=h&&o;onlyHere+=h&&!o;onlyOptimum+=o&&!h;if(h!=o && !(b.flags&impact::eDUCTILE))++brittleDiffer;}
        double impulse[2][3]={{0,0,0},{0,0,0}};
        for(PxU32 l=0;l<nl;++l){const auto& b=bonds[l];if(!(b.flags&impact::eCONTACT) || !(b.flags&impact::eALIVE))continue;
            for(int k=0;k<3;++k)for(int q=0;q<6;++q){impulse[0][k]+=double(d.B[72*l+6*k+q])*z[6*l+q]*d.dt;impulse[1][k]+=double(d.B[72*l+6*k+q])*x[6*l+q]*d.dt;}}
        std::printf("  joints at capacity: %u both, %u here only, %u the optimum's only (%u brittle differ); total contact impulse (%.4g %.4g %.4g) N s, the optimum's (%.4g %.4g %.4g)\n",
            atBoth,onlyHere,onlyOptimum,brittleDiffer,impulse[0][0],impulse[0][1],impulse[0][2],impulse[1][0],impulse[1][1],impulse[1][2]);
        const double agreeObjective=env("IMPACT_AGREE_OBJECTIVE",1e-3f),agreeContact=env("IMPACT_AGREE_CONTACT",1e-2f);
        const bool agrees=gap<=agreeObjective && relF<=agreeContact;
        std::printf("  against the FP64 optimum (objective %.9g): objective gap %.3e of the problem's scale (within %.0e), contact forces within %.3e of the largest (link %u; within %.0e): %s; worst joint force %.3e of its capacity (link %u, bond %u: reported)\n",
            objective(x),gap,agreeObjective,relF,atF,agreeContact,agrees?"agrees":"DISAGREES",worst,at,bonds[at].bond);
        if(!agrees)status=1;
    }
    return status;
}
}}
int main(int argc,char** argv){try{return physx::run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 3;}}
