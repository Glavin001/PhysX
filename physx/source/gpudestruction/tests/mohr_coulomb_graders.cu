// Mohr-Coulomb joint shear (PX_DESTRUCTION_MOHR_COULOMB_SHEAR; vibe-land
// FIDELITY_AUDIT C11): every grader applies one law, f_v = f_v0 + mu sigma_c
// capped. It is checked on random joints and wrenches, on the device:
//   1. the impact models' verdict (impact::utilisation: shear against
//      shearCapacity(b, N)) and the static verdict's (the shear net of
//      extStressFrictionStrength against the authored limit, elastic = fatal)
//      agree, away from the boundary (|u - 1| > 1e-4), and equal the FP64
//      closed form;
//   2. the projection (impact::project) returns a point in the set at its own
//      N: |V| + gt |T| <= shearCapacity(b, N); its axial part is the
//      frictionless projection's (friction slides, it does not dilate), and
//      feasible() accepts it;
//   3. the ray capacity (impact::shearCapacityAlong) is where the shear along
//      the push reaches shearCapacity: s t = shearCapacity(b, -s a), to 1e-5;
//   4. mu 0 is the old law exactly (bit for bit, the three of them).
// Exit 0 when all hold; 1 otherwise.
#include "PxDestructionScene.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cfloat>
#include <cmath>
#include <cstdio>
#include <cstring>
#include <random>
#include <stdexcept>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"

struct Case {
    impact::Bond b;float A,fv0,capStress;      // the joint as the static verdict sees it (stress)
    float x[6],m[4],a,t;                       // a wrench, a metric, a push (a along n, t across)
    // results
    float uImpact,shearStatic,fric,cap,p[6],q[6],capAt,ray;PxU32 feasible;
    float uImpact0,ray0,uAxial,uOld;           // the same joint with mu 0; its axial utilisation; the pre-C11 expression
};
__global__ void gradeAll(Case* c,PxU32 n)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    Case& k=c[i];
    k.uImpact=impact::utilisation(k.b,k.x);
    const float N=k.x[0],V=sqrtf(k.x[1]*k.x[1]+k.x[2]*k.x[2]),T=fabsf(k.x[3]);
    const float tau=(V+k.b.gt*T)/k.A;
    k.fric=extStressFrictionStrength(N/k.A,k.b.mu,k.capStress,k.fv0);
    k.shearStatic=fmaxf(0.0f,tau-k.fric);
    k.cap=impact::shearCapacity(k.b,N);
    float x[6];for(int q=0;q<6;++q)x[q]=k.x[q];
    const float lin=sqrtf(x[0]*x[0]+x[1]*x[1]+x[2]*x[2]),ang=sqrtf(x[3]*x[3]+x[4]*x[4]+x[5]*x[5]);
    impact::project(k.b,x,k.m[0],k.m[1],k.m[2],k.m[3]);
    for(int q=0;q<6;++q)k.p[q]=x[q];
    k.feasible=impact::feasible(k.b,x,1e-4f,lin,ang)?1u:0u;
    k.capAt=impact::shearCapacity(k.b,x[0]);
    impact::Bond f=k.b;f.mu=0.0f;f.capSx=0.0f;
    float y[6];for(int q=0;q<6;++q)y[q]=k.x[q];
    impact::project(f,y,k.m[0],k.m[1],k.m[2],k.m[3]);
    for(int q=0;q<6;++q)k.q[q]=y[q];
    k.ray=impact::shearCapacityAlong(k.b,k.a,k.t);
    // mu 0 against the old expressions (copied from before C11).
    k.uImpact0=impact::utilisation(f,k.x);
    k.ray0=impact::shearCapacityAlong(f,k.a,k.t);
    impact::Bond ax=f;ax.capS=FLT_MAX;k.uAxial=impact::utilisation(ax,k.x);
    // utilisation's shear term as it was before C11: ratio(V + gt T, capS).
    const float shear=V+f.gt*T,rs=shear<=0.0f?0.0f:(f.capS>0.0f?shear/f.capS:FLT_MAX);
    k.uOld=fmaxf(k.uAxial,rs);
}

int run()
{
    std::mt19937_64 rng(20261008);
    std::uniform_real_distribution<double> U(0.0,1.0);std::normal_distribution<double> G(0.0,1.0);
    auto decade=[&](double lo,double hi){return std::pow(10.0,lo+(hi-lo)*U(rng));};
    const PxU32 n=200000;std::vector<Case> cases(n);
    for(PxU32 i=0;i<n;++i) {
        Case& c=cases[i];c={};impact::Bond& b=c.b;b=impact::Bond{};b.flags=impact::eALIVE;
        c.A=float(decade(-3,0));c.fv0=float(decade(4.5,6.5));                  // 30 kPa - 3 MPa
        b.capS=c.fv0*c.A;b.capT=float(c.fv0*c.A*decade(-1,0.5));b.capC=float(c.fv0*c.A*decade(1,3));
        b.mu=float(U(rng)<0.1?0.0:0.2+0.8*U(rng));
        c.capStress=float(U(rng)<0.3?0.0:c.fv0*(1.0+decade(-2,1)));
        b.capSx=b.mu>0.0f && c.capStress>0.0f?c.capStress*c.A:0.0f;
        b.gt=float(decade(0,2.5));b.area=c.A;
        b.g0=float(decade(0,3));b.g1=float(decade(0,3));b.gb=b.g0;b.h0=b.g0;b.h1=b.g1;
        c.m[0]=float(decade(-3,3));c.m[1]=float(decade(-3,3));c.m[2]=float(decade(-3,3));c.m[3]=float(decade(-3,3));
        const double cap=b.capS,reach=U(rng)<0.5?decade(-1,0.5):decade(0.5,3);
        // Compression mostly (the friction's branch), tension sometimes.
        const double N=-std::fabs(G(rng))*cap*decade(-1,1.5)*(U(rng)<0.8?1.0:-0.3);
        c.x[0]=float(N);for(int q=1;q<3;++q)c.x[q]=float(cap*reach*G(rng));
        c.x[3]=float(cap*reach*G(rng)/b.gt);c.x[4]=float(0.1*cap*G(rng)/b.g0);c.x[5]=float(0.1*cap*G(rng)/b.g1);
        const double th=std::acos(2.0*U(rng)-1.0);c.a=float(std::cos(th));c.t=float(std::sin(th));
    }
    Case* d;allocate(d,n);check(cudaMemcpy(d,cases.data(),sizeof(Case)*n,cudaMemcpyHostToDevice));
    gradeAll<<<(n+127)/128,128>>>(d,n);check(cudaDeviceSynchronize());check(cudaGetLastError());
    check(cudaMemcpy(cases.data(),d,sizeof(Case)*n,cudaMemcpyDeviceToHost));
    PxU32 verdict=0,closed=0,outside=0,axial=0,misfire=0,ray=0,old=0,checked=0;
    for(PxU32 i=0;i<n;++i) {
        const Case& c=cases[i];const impact::Bond& b=c.b;
        // 1. The two verdicts, and the FP64 closed form.
        const double N=c.x[0],V=std::hypot(double(c.x[1]),double(c.x[2])),T=std::fabs(double(c.x[3]));
        double f=b.mu>0.0f && N<0.0?-b.mu*N:0.0;
        if(c.capStress>0.0f && b.mu>0.0f)f=std::min(f,std::max(0.0,double(c.capStress)*c.A-b.capS));
        const double uShear=(V+b.gt*T)/(b.capS+f);
        const float uStatic=c.shearStatic/c.fv0;
        const float axialU=c.uAxial;
        if(std::fabs(uShear-1.0)>1e-4 && std::fabs(axialU-1.0f)>1e-4f) {
            ++checked;
            const bool impactBreaks=c.uImpact>=1.0f,staticBreaks=uStatic>1.0f || axialU>=1.0f,closedBreaks=uShear>1.0 || axialU>=1.0f;
            if(impactBreaks!=staticBreaks){if(!verdict)std::printf("  verdicts differ, case %u: impact u %.7g, static shear u %.7g, closed %.7g\n",i,c.uImpact,uStatic,uShear);++verdict;}
            if(impactBreaks!=closedBreaks)++closed;
        }
        // 2. The projection at its own N.
        const double Vp=std::hypot(double(c.p[1]),double(c.p[2])),Tp=std::fabs(double(c.p[3]));
        if(Vp+b.gt*Tp>c.capAt*(1.0+1e-5)+1e-30){if(!outside)std::printf("  projection outside, case %u: %.9g > %.9g\n",i,Vp+b.gt*Tp,double(c.capAt));++outside;}
        if(c.p[0]!=c.q[0] || c.p[4]!=c.q[4] || c.p[5]!=c.q[5]){if(!axial)std::printf("  axial part moved by friction, case %u\n",i);++axial;}
        if(!c.feasible){if(!misfire)std::printf("  feasible() rejects the projection, case %u\n",i);++misfire;}
        // 3. The ray capacity: s t = shearCapacity(-s a), or none.
        if(c.ray<FLT_MAX) {
            const double s=c.ray;double capS=b.capS;const double comp=s*c.a;
            if(b.mu>0.0f && comp>0.0){double fr=b.mu*comp;if(b.capSx>0.0f)fr=std::min(fr,std::max(0.0,double(b.capSx)-b.capS));capS+=fr;}
            if(std::fabs(s*c.t-capS)>1e-5*capS){if(!ray)std::printf("  ray capacity off, case %u: s t %.9g vs %.9g\n",i,s*c.t,capS);++ray;}
        } else if(!(b.mu>0.0f && c.a>0.0f && c.t<=b.mu*c.a && !(b.capSx>0.0f)) && c.t>0.0f){if(!ray)std::printf("  ray capacity unbounded, case %u\n",i);++ray;}
        // 4. mu 0: the old law bit for bit.
        {const float oldRay=c.t>0.0f?b.capS/c.t:FLT_MAX;
         if(c.uImpact0!=c.uOld || c.ray0!=oldRay){if(!old)std::printf("  mu 0 differs from the old law, case %u: u %.9g vs %.9g, ray %.9g vs %.9g\n",i,c.uImpact0,c.uOld,c.ray0,oldRay);++old;}}
    }
    std::printf("Mohr-Coulomb graders, %u joints (%u away from the boundary): verdicts differ %u, off the closed form %u; "
        "projections outside their set %u, axial part moved %u, feasible() rejects %u; ray capacities off %u; mu 0 not the old law %u\n",
        n,checked,verdict,closed,outside,axial,misfire,ray,old);
    return verdict||closed||outside||axial||misfire||ray||old?1:0;
}
}}
int main(){try{return physx::run();}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 3;}}
