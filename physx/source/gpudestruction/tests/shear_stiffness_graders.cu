// Shear stiffness (PX_DESTRUCTION_SHEAR_STIFFNESS; vibe-land FIDELITY_AUDIT D11):
// a joint is kl stiff along its normal and ks across it in every impact model.
// Checked on random joints, on the device:
//   1. exStiffness gives the bond frame's diagonal (kl, ks, ks, kt, k0, k1);
//   2. the explicit step's stiffness blocks (exGershgorin's C_ef = B_e K B_f^T,
//      exBlockShear) equal the FP64 product of the joint's own matrices, B_e =
//      s_e [[R, 0], [O_e R, -R]], K = diag(kl, ks, ks, kt, k0, k1); and with
//      ks = kl the isotropic block (exBlock) gives the same;
//   3. the return map projects in the joint's compliance metric diag(1/kt, 1/ks)
//      on (T, V): a shear excess with a twist returns along M^-1 times the
//      normal of |V| + gt |T| = cap, |dT| / |dV| = gt kt / ks (each force drops
//      by its own stiffness: a softer shear row gives up less of V);
//   4. ks = kl is the isotropic law (the projection with ms < 0), to float rounding.
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
    impact::Bond b;float x[6];
    float k[6],C[36],Ciso[36],p[6],q[6];
};
__global__ void gradeAll(Case* c,PxU32 n)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    Case& k=c[i];
    impact::exStiffness(k.b,k.k);
    // Both ends' coupling block, end 0 against end 1 (exGershgorin's second block).
    float M[9];for(int a=0;a<3;++a)for(int b=0;b<3;++b)M[3*a+b]=k.k[3]*k.b.n[a]*k.b.n[b]+k.k[4]*k.b.t1[a]*k.b.t1[b]+k.k[5]*k.b.t2[a]*k.b.t2[b];
    float L[9];for(int a=0;a<3;++a)for(int b=0;b<3;++b)L[3*a+b]=k.k[0]*k.b.n[a]*k.b.n[b]+k.k[1]*(k.b.t1[a]*k.b.t1[b]+k.b.t2[a]*k.b.t2[b]);
    impact::exBlockShear(L,M,k.b.o0[0],k.b.o0[1],k.b.o0[2],k.b.o1[0],k.b.o1[1],k.b.o1[2],-1.0f,k.C);
    impact::exBlock(k.k[0],M,k.b.o0[0],k.b.o0[1],k.b.o0[2],k.b.o1[0],k.b.o1[1],k.b.o1[2],-1.0f,k.Ciso);
    float x[6];for(int q=0;q<6;++q)x[q]=k.x[q];
    impact::returnMap(k.b,x);for(int q=0;q<6;++q)k.p[q]=x[q];
    // The isotropic metric, for the ks = kl check.
    for(int q=0;q<6;++q)x[q]=k.x[q];
    impact::project(k.b,x,1.0f/k.b.kl,1.0f/k.b.kt,1.0f/k.b.k0,1.0f/k.b.k1);for(int q=0;q<6;++q)k.q[q]=x[q];
}

int run()
{
    std::mt19937_64 rng(20261008);
    std::uniform_real_distribution<double> U(0.0,1.0);std::normal_distribution<double> G(0.0,1.0);
    auto decade=[&](double lo,double hi){return std::pow(10.0,lo+(hi-lo)*U(rng));};
    const PxU32 n=100000;std::vector<Case> cases(n);
    for(PxU32 i=0;i<n;++i) {
        Case& c=cases[i];c={};impact::Bond& b=c.b;b=impact::Bond{};b.flags=impact::eALIVE;
        // A random frame n, t1, t2.
        double dir[3]={G(rng),G(rng),G(rng)};const double l=std::sqrt(dir[0]*dir[0]+dir[1]*dir[1]+dir[2]*dir[2]);
        // impact::frame, on the host: t1 = n x e (e a unit axis away from n), t2 = n x t1.
        b.n[0]=float(dir[0]/l);b.n[1]=float(dir[1]/l);b.n[2]=float(dir[2]/l);
        {const float e[3]={std::fabs(b.n[0])<0.9f?1.0f:0.0f,std::fabs(b.n[0])<0.9f?0.0f:1.0f,0.0f};
         float t[3]={b.n[1]*e[2]-b.n[2]*e[1],b.n[2]*e[0]-b.n[0]*e[2],b.n[0]*e[1]-b.n[1]*e[0]};
         const float tl=std::sqrt(t[0]*t[0]+t[1]*t[1]+t[2]*t[2]);for(int q=0;q<3;++q)b.t1[q]=t[q]/tl;
         b.t2[0]=b.n[1]*b.t1[2]-b.n[2]*b.t1[1];b.t2[1]=b.n[2]*b.t1[0]-b.n[0]*b.t1[2];b.t2[2]=b.n[0]*b.t1[1]-b.n[1]*b.t1[0];}
        for(int q=0;q<3;++q){b.o0[q]=float(0.3*G(rng));b.o1[q]=float(0.3*G(rng));}
        b.kl=float(decade(5,9));b.ks=i%4==0?b.kl:float(b.kl*decade(-1.5,0));
        b.kt=float(decade(3,7));b.k0=float(decade(3,7));b.k1=float(decade(3,7));
        b.capC=float(decade(4,6));b.capT=float(decade(3,5));b.capS=float(decade(3,5));b.gt=float(decade(0,2));
        b.g0=float(decade(0,3));b.g1=float(decade(0,3));b.gb=b.g0;b.h0=b.g0;b.h1=b.g1;b.area=0.01f;
        // A shear-and-twist excess, its axial part well inside (compression 10% of capacity).
        const double reach=decade(0.2,1.5);
        c.x[0]=float(-0.1*b.capC);c.x[1]=float(b.capS*reach*G(rng));c.x[2]=float(b.capS*reach*G(rng));
        c.x[3]=float(b.capS*reach*G(rng)/b.gt);c.x[4]=0.0f;c.x[5]=0.0f;
    }
    Case* d;allocate(d,n);check(cudaMemcpy(d,cases.data(),sizeof(Case)*n,cudaMemcpyHostToDevice));
    gradeAll<<<(n+127)/128,128>>>(d,n);check(cudaDeviceSynchronize());check(cudaGetLastError());
    check(cudaMemcpy(cases.data(),d,sizeof(Case)*n,cudaMemcpyDeviceToHost));
    PxU32 stiff=0,block=0,iso=0,metric=0,isotropic=0,checked=0;double worst=0;
    for(PxU32 i=0;i<n;++i) {
        const Case& c=cases[i];const impact::Bond& b=c.b;
        // 1.
        const float want[6]={b.kl,b.ks,b.ks,b.kt,b.k0,b.k1};
        for(int q=0;q<6;++q)if(c.k[q]!=want[q]){++stiff;break;}
        // 2. FP64 B_0 K B_1^T, s_0 s_1 = -1.
        double R[3][3];for(int a=0;a<3;++a){R[a][0]=b.n[a];R[a][1]=b.t1[a];R[a][2]=b.t2[a];}
        auto skew=[](const float* o,double S[3][3]){S[0][0]=0;S[0][1]=-o[2];S[0][2]=o[1];S[1][0]=o[2];S[1][1]=0;S[1][2]=-o[0];S[2][0]=-o[1];S[2][1]=o[0];S[2][2]=0;};
        double O0[3][3],O1[3][3];skew(b.o0,O0);skew(b.o1,O1);
        auto Bm=[&](double O[3][3],double B[6][6]){for(int r=0;r<6;++r)for(int q=0;q<6;++q)B[r][q]=0;
            for(int a=0;a<3;++a)for(int q=0;q<3;++q){B[a][q]=R[a][q];double s=0;for(int k=0;k<3;++k)s+=O[a][k]*R[k][q];B[3+a][q]=s;B[3+a][3+q]=-R[a][q];}};
        double B0[6][6],B1[6][6];Bm(O0,B0);Bm(O1,B1);
        const double K[6]={b.kl,b.ks,b.ks,b.kt,b.k0,b.k1};
        double scale=0;
        for(int r=0;r<6;++r)for(int q=0;q<6;++q){double s=0;for(int k=0;k<6;++k)s+=B0[r][k]*K[k]*B1[q][k];s=-s;
            scale=std::max(scale,std::fabs(s));
            const double e=std::fabs(s-c.C[6*r+q]);if(e>worst*1.0)worst=std::max(worst,e);}
        bool bad=false;
        for(int r=0;r<6;++r)for(int q=0;q<6;++q){double s=0;for(int k=0;k<6;++k)s+=B0[r][k]*K[k]*B1[q][k];s=-s;
            if(std::fabs(s-c.C[6*r+q])>2e-5*scale)bad=true;}
        if(bad){if(!block)std::printf("  block off, case %u\n",i);++block;}
        if(b.ks==b.kl){for(int q=0;q<36;++q)if(std::fabs(c.C[q]-c.Ciso[q])>2e-5*scale){if(!iso)std::printf("  isotropic block differs, case %u\n",i);++iso;break;}}
        // 3. The return's direction in (T, V): |dT| / |dV| = gt kt^-1 / ks^-1 (when both moved).
        const double V0=std::hypot(double(c.x[1]),double(c.x[2])),V1=std::hypot(double(c.p[1]),double(c.p[2]));
        const double dT=std::fabs(double(c.p[3])-c.x[3]),dV=V0-V1;
        // (A return of at least 1e-3 of the point in each, so float rounding of the
        // difference is well under the 5e-3 allowed.)
        if(dT>1e-3*std::fabs(c.x[3]) && dV>1e-3*V0 && c.p[3]*c.x[3]>0 && V1>1e-3*V0) {
            ++checked;
            const double ratio=(dT/dV)/(double(b.gt)*double(b.kt)/double(b.ks));
            if(std::fabs(ratio-1.0)>5e-3){if(!metric)std::printf("  return off the metric's normal, case %u: ratio %.6g\n",i,ratio);++metric;}
        }
        // 4.
        // (To float rounding: the two call sites are contracted (fma) independently.)
        if(b.ks==b.kl){double size=0;for(int q=0;q<6;++q)size=std::max(size,std::fabs(double(c.q[q])));
            for(int q=0;q<6;++q)if(std::fabs(double(c.p[q])-c.q[q])>1e-5*size+1e-30){if(!isotropic)std::printf("  ks = kl differs from the isotropic return, case %u\n",i);++isotropic;break;}}
    }
    std::printf("Shear stiffness graders, %u joints: stiffness rows off %u; blocks off the FP64 product %u, isotropic block differs %u; "
        "returns off the metric normal %u of %u checked; ks = kl not the isotropic return %u\n",n,stiff,block,iso,metric,checked,isotropic);
    return stiff||block||iso||metric||isotropic?1:0;
}
}}
int main(){try{return physx::run();}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 3;}}
