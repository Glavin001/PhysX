// The impact solve's projections (impact::project, the ADMM's Z step and the
// return map) against an exact FP64 reference, for every capacity-set type:
//   the section's L1 axial set (N, M0, M1), its bearing-joint variant (the
//   tension line's own gains 1/d), the round axial set (N, |M|), the shear set
//   (|V| + gt |T|), and a contact row's Coulomb cone (no couple).
// The reference is independent of the product's algorithms (bisection on KKT
// multipliers, triangle nearest points): each set is a union of polyhedra
// (its sign orthants; for a set of revolution the meridian polygon, exact by
// the metric's symmetry), and the projection onto each polyhedron is found by
// enumerating active sets of its inequalities in double, keeping the KKT point
// (feasible, multipliers >= 0). Cases span the house's ranges and past them:
// thin sections (g ~ 2e3 /m), compression 1e3x the tension (and "none"),
// metrics over six decades, points inside, near vertices and 1e4 x capacity out.
// Exit 0 when every projection is feasible and within 2e-4 of the reference
// (distance in the metric, relative to the move; or 8 ulps of the point); 1 otherwise.
#include "PxDestructionScene.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cfloat>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <random>
#include <stdexcept>
#include <vector>
#include "impact_projection_reference.h"
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionImpact.cuh"

struct Case { impact::Bond b; float x[6],m[4],p[6]; PxU32 feasible,kind; };
enum Kind : PxU32 { eL1=0, eBEARING=1, eROUND=2, eCONTACT_ROW=3, eKINDS=4 };
const char* kName[eKINDS]={"section L1","bearing joint","round","contact cone"};

__global__ void projectAll(Case* c,PxU32 n)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    Case& k=c[i];float x[6];for(int q=0;q<6;++q)x[q]=k.x[q];
    const float lin=sqrtf(x[0]*x[0]+x[1]*x[1]+x[2]*x[2]),ang=sqrtf(x[3]*x[3]+x[4]*x[4]+x[5]*x[5]);
    impact::project(k.b,x,k.m[0],k.m[1],k.m[2],k.m[3]);
    for(int q=0;q<6;++q)k.p[q]=x[q];
    // As the solve calls it: with the projected point's size (its rounding).
    k.feasible=impact::feasible(k.b,x,1e-4f,lin,ang)?1u:0u;
}

// The reference (impact_projection_reference.cpp, plain host C++).
ProjectionCase plain(const Case& c)
{
    const impact::Bond& b=c.b;ProjectionCase p{};
    p.contact=(b.flags&impact::eCONTACT)!=0;p.capC=b.capC;p.capT=b.capT;p.capS=b.capS;p.gb=b.gb;p.gt=b.gt;
    p.g0=b.g0;p.g1=b.g1;p.h0=b.h0;p.h1=b.h1;p.mu=b.area;
    for(int q=0;q<6;++q)p.x[q]=c.x[q];for(int q=0;q<4;++q)p.m[q]=c.m[q];return p;
}
void reference(const Case& c,double* ref){projectionReference(plain(c),ref);}

int run()
{
    std::mt19937_64 rng(20261008);
    std::uniform_real_distribution<double> U(0.0,1.0);std::normal_distribution<double> G(0.0,1.0);
    auto decade=[&](double lo,double hi){return std::pow(10.0,lo+(hi-lo)*U(rng));};
    const PxU32 perKind=50000,n=perKind*eKINDS;std::vector<Case> cases(n);
    for(PxU32 i=0;i<n;++i) {
        Case& c=cases[i];c.kind=i/perKind;impact::Bond& b=c.b;b=impact::Bond{};b.flags=impact::eALIVE;
        b.capT=float(decade(2,6));
        const double cr=U(rng);b.capC=float(cr<0.15?4e10:b.capT*decade(-1,1.5));   // "no compression limit" too
        b.capS=float(b.capT*decade(-1,0.5));b.gt=float(decade(0,3));b.area=1.0f;
        if(c.kind==eL1 || c.kind==eBEARING) {
            b.g0=float(decade(0,3.5));b.g1=float(U(rng)<0.2?b.g0:decade(0,3.5));b.gb=b.g0;
            if(c.kind==eBEARING){b.h0=float(decade(0,2));b.h1=float(decade(0,2));}else{b.h0=b.g0;b.h1=b.g1;}
        } else if(c.kind==eROUND){b.gb=float(decade(0,3));}
        else {b.flags|=impact::eCONTACT;b.area=float(U(rng)<0.1?0.0:1.5*U(rng));b.capC=float(decade(2,7));b.capT=b.capS=0.0f;}
        // Metrics over six decades; the round set's bending metric is one (its symmetry).
        c.m[0]=float(decade(-3,3));c.m[1]=float(decade(-3,3));c.m[2]=float(decade(-3,3));c.m[3]=(c.kind==eROUND)?c.m[2]:float(decade(-3,3));
        // Points: inside, near the boundary, far out; moments at the set's own scale.
        const double cap=std::max(std::max(double(b.capT),double(b.capS)),c.kind==eCONTACT_ROW?double(b.capC):0.0);
        const double reach=U(rng)<0.3?decade(-3,0):decade(0,4);
        const double gm=std::max(std::max(double(b.gb),double(b.g0)),1.0),gtm=std::max(double(b.gt),1e-3);
        const double f[6]={G(rng),G(rng),G(rng),G(rng)/gtm,G(rng)/gm,G(rng)/gm};
        for(int q=0;q<6;++q)c.x[q]=float(cap*reach*f[q]);
        if(U(rng)<0.1){c.x[4]=0.0f;}if(U(rng)<0.1){c.x[1]=c.x[2]=0.0f;}
    }
    Case* d;allocate(d,n);check(cudaMemcpy(d,cases.data(),sizeof(Case)*n,cudaMemcpyHostToDevice));
    projectAll<<<(n+127)/128,128>>>(d,n);check(cudaDeviceSynchronize());check(cudaGetLastError());
    check(cudaMemcpy(cases.data(),d,sizeof(Case)*n,cudaMemcpyDeviceToHost));
    auto show=[&](const char* what,PxU32 at){const Case& c=cases[at];double ref[6];reference(c,ref);
        std::printf("  %s case %u: caps C %.9g T %.9g S %.9g gains gb %.6g gt %.6g g %.6g %.6g h %.6g %.6g mu %.3g metric %.3g %.3g %.3g %.3g\n",what,at,
            c.b.capC,c.b.capT,c.b.capS,c.b.gb,c.b.gt,c.b.g0,c.b.g1,c.b.h0,c.b.h1,c.b.area,c.m[0],c.m[1],c.m[2],c.m[3]);
        std::printf("    x   %.9g %.9g %.9g | %.9g %.9g %.9g\n    gpu %.9g %.9g %.9g | %.9g %.9g %.9g\n    ref %.9g %.9g %.9g | %.9g %.9g %.9g\n",
            c.x[0],c.x[1],c.x[2],c.x[3],c.x[4],c.x[5],c.p[0],c.p[1],c.p[2],c.p[3],c.p[4],c.p[5],ref[0],ref[1],ref[2],ref[3],ref[4],ref[5]);};
    // Feasibility in FP64, to float's resolution of the terms each line sums
    // (8 ulps): N + h.m beside a tension capacity 1e3 x smaller resolves it
    // only to 1e3 eps. The product's own feasible() must agree: a projection
    // the reference finds in its set that feasible() rejects is a misfire
    // (a spurious "infeasible", which stops a solve as diverged).
    auto inSet=[&](const Case& c)->bool{
        const impact::Bond& b=c.b;double p[6];for(int q=0;q<6;++q)p[q]=c.p[q];
        const double e8=8.0*FLT_EPSILON;
        if(b.flags&impact::eCONTACT){const double V=std::hypot(p[1],p[2]);
            return p[0]<=e8*std::fabs(p[0]) && V<=b.area*std::max(-p[0],0.0)+e8*(V+b.area*std::fabs(p[0]))+1e-30 && p[3]==0.0 && p[4]==0.0 && p[5]==0.0;}
        const double capC=std::min(double(b.capC),1e3*std::max(double(b.capT),double(b.capS)));
        const double V=std::hypot(p[1],p[2]),T=std::fabs(p[3]),M=std::hypot(p[4],p[5]);
        const double bend=b.g0>0.0f?b.g0*std::fabs(p[4])+b.g1*std::fabs(p[5]):b.gb*M,pull=b.g0>0.0f?b.h0*std::fabs(p[4])+b.h1*std::fabs(p[5]):bend;
        // (and of the apex, where both lines meet: their capacities' sum)
        const double tolT=1e-6*b.capT+e8*(std::fabs(p[0])+pull+capC),tolC=1e-6*capC+e8*(std::fabs(p[0])+bend+b.capT),tolS=1e-6*b.capS+e8*(V+b.gt*T);
        return p[0]+pull<=b.capT+tolT && bend-p[0]<=capC+tolC && V+b.gt*T<=b.capS+tolS;};
    int status=0;
    for(PxU32 kind=0;kind<eKINDS;++kind) {
        double worst=0.0;PxU32 bad=0,infeasible=0,misfires=0,at=kind*perKind,firstInfeasible=~0u;
        for(PxU32 i=kind*perKind;i<(kind+1)*perKind;++i) {
            const Case& c=cases[i];double ref[6];reference(c,ref);
            const double w[6]={c.m[0],c.m[0],c.m[0],c.m[1],c.m[2],c.m[3]};
            double e=0,move=0,size=0;
            for(int q=0;q<6;++q){e+=w[q]*(c.p[q]-ref[q])*(c.p[q]-ref[q]);move+=w[q]*(c.x[q]-ref[q])*(c.x[q]-ref[q]);size+=w[q]*(double(c.x[q])*c.x[q]+ref[q]*ref[q]);}
            // Within 2e-4 of the move, or of float's resolution of the point (8 ulps of its size).
            // ... and of the set's own scale (its vertices: the capacities).
            const double setScale=std::sqrt(double(c.m[0]))*std::max(std::max(double(c.b.capT),double(c.b.capS)),
                std::min(double(c.b.capC),1e3*std::max(double(c.b.capT),double(c.b.capS))));
            const double rel=std::sqrt(e)/(2e-4*std::sqrt(move)+1e-6*(std::sqrt(size)+setScale)+1e-300);
            if(!inSet(c)){++infeasible;if(firstInfeasible==~0u)firstInfeasible=i;}
            if(!c.feasible && inSet(c)){if(!misfires)show("misfire",i);++misfires;}
            if(rel>1.0)++bad;
            if(rel>worst){worst=rel;at=i;}
        }
        std::printf("%-14s %u cases: %u infeasible, %u off the FP64 projection (worst %.3g of the allowance); feasible() misfires %u\n",kName[kind],perKind,infeasible,bad,worst,misfires);
        if(bad){status=1;show("worst",at);}
        if(misfires)status=1;
        if(infeasible){status=1;show("infeasible",firstInfeasible);}
    }
    return status;
}
}}
int main(){try{return physx::run();}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 3;}}
