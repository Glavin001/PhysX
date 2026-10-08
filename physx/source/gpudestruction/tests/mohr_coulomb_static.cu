// Mohr-Coulomb joint shear in the static verdict (PX_DESTRUCTION_MOHR_COULOMB_SHEAR;
// vibe-land FIDELITY_AUDIT C11), through the stage's own grader
// (evaluateBondMaterials, PxgDestructionMaterial.cuh) on random joints:
//   1. the verdict and the damage equal the FP64 closed form: shear capacity
//      f_v0 + mu sigma_c, sigma_c = max(0, -sigma), the friction term capped
//      so f_v0 + term <= cap (EN 1996-1-1 3.6.2: f_vk = f_vk0 + 0.4 sigma_d <= f_vlt);
//   2. friction shifts both shear limits by the same term (it has no duration
//      of load): the joint with mu graded at (e, F) breaks exactly when the
//      same joint with mu 0 graded at (e + f, F + f) does, with the same damage;
//   3. tension adds no friction: a joint in tension grades bit for bit as
//      with mu 0;
//   4. a cap at or below f_v0 adds nothing: bit for bit as with mu 0;
//   5. three worked numbers: f_v0 0.15 MPa, mu 0.4, sigma_c 0.5 MPa gives
//      f_v 0.35 MPa (holds at 0.99 of it, breaks at 1.01); capped at 0.3 MPa it
//      breaks at 1.01 of 0.3 MPa; in tension at 1.01 of 0.15 MPa.
// Exit 0 when all hold; 1 otherwise.
#include "PxDestructionScene.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cfloat>
#include <cmath>
#include <cstdio>
#include <random>
#include <stdexcept>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionMaterial.cuh"

constexpr float kDt=1.0f/60.0f,kRate=2.0f;

struct Joint { double area,sigma,tau,fv0e,fv0,mu,cap; };   // stresses in Pa
struct Scene {
    std::vector<PxDestructionStressChunk> chunks;std::vector<PxDestructionStressBond> bonds;
    std::vector<PxDestructionMaterial> materials;std::vector<float> health;std::vector<PxDestructionVectorPair> forces;
};
// One bond per joint between its own two chunks, along a random normal, its
// force the joint's normal and shear stress over its area (no moment).
Scene build(const std::vector<Joint>& joints,bool friction)
{
    // The same normals for every scene built from the same joints (the bit-for-bit checks compare them).
    std::mt19937_64 rng(7);std::normal_distribution<double> G(0.0,1.0);Scene s;
    for(PxU32 i=0;i<joints.size();++i) {
        const Joint& j=joints[i];
        PxVec3 n(float(G(rng)),float(G(rng)),float(G(rng)));n.normalize();
        PxVec3 t=n.cross(std::fabs(n.x)<0.9f?PxVec3(1,0,0):PxVec3(0,1,0));t.normalize();
        PxDestructionStressChunk c0{},c1{};c0.position=PxVec3(0.0f);c1.position=n*0.5f;c0.mass=c1.mass=1.0f;c0.inertia=c1.inertia=1.0f;
        s.chunks.push_back(c0);s.chunks.push_back(c1);
        PxDestructionStressBond b{};b.chunk0=2*i;b.chunk1=2*i+1;b.centroid=n*0.25f;b.normal=n;
        b.area=float(j.area);b.health=b.area;b.complianceScale=1.0f;b.material=i;s.bonds.push_back(b);
        PxDestructionMaterial m{};
        m.compressionElasticLimit=m.tensionElasticLimit=1e30f;m.compressionFatalLimit=m.tensionFatalLimit=2e30f;
        m.shearElasticLimit=float(j.fv0e);m.shearFatalLimit=float(j.fv0);
        if(friction){m.shearFriction=float(j.mu);m.shearCapacityLimit=float(j.cap);}
        s.materials.push_back(m);s.health.push_back(b.area);
        PxDestructionVectorPair f;f.linear=n*float(j.sigma*j.area)+t*float(j.tau*j.area);s.forces.push_back(f);
    }
    return s;
}
std::vector<PxDestructionBondVerdict> grade(const Scene& s)
{
    const PxU32 n=PxU32(s.bonds.size());
    PxDestructionStressChunk* chunks;PxDestructionStressBond* bonds;PxDestructionMaterial* materials;float* health;
    PxDestructionVectorPair* forces;PxDestructionBondVerdict* verdict;PxVec3* centroids;PxDestructionStageStatus* status;
    allocate(chunks,s.chunks.size());allocate(bonds,n);allocate(materials,n);allocate(health,n);allocate(forces,n);
    allocate(verdict,n);allocate(centroids,n);allocate(status,1);
    check(cudaMemcpy(chunks,s.chunks.data(),sizeof(*chunks)*s.chunks.size(),cudaMemcpyHostToDevice));
    check(cudaMemcpy(bonds,s.bonds.data(),sizeof(*bonds)*n,cudaMemcpyHostToDevice));
    check(cudaMemcpy(materials,s.materials.data(),sizeof(*materials)*n,cudaMemcpyHostToDevice));
    check(cudaMemcpy(health,s.health.data(),sizeof(float)*n,cudaMemcpyHostToDevice));
    check(cudaMemcpy(forces,s.forces.data(),sizeof(*forces)*n,cudaMemcpyHostToDevice));
    check(cudaMemset(status,0,sizeof(*status)));
    evaluateBondMaterials<<<(n+127)/128,128>>>(chunks,bonds,materials,health,forces,n,kDt,kRate,3.0f,true,verdict,centroids,status,false,nullptr);
    check(cudaDeviceSynchronize());check(cudaGetLastError());
    std::vector<PxDestructionBondVerdict> out(n);check(cudaMemcpy(out.data(),verdict,sizeof(*verdict)*n,cudaMemcpyDeviceToHost));
    PxDestructionStageStatus st{};check(cudaMemcpy(&st,status,sizeof st,cudaMemcpyDeviceToHost));
    if(st.error)throw std::runtime_error("stage status error "+std::to_string(st.error));
    for(void* p:{(void*)chunks,(void*)bonds,(void*)materials,(void*)health,(void*)forces,(void*)verdict,(void*)centroids,(void*)status})cudaFree(p);
    return out;
}
// The FP64 closed form: the shear multiplier past the elastic limit, net of friction.
double frictionTerm(const Joint& j){
    if(!(j.mu>0.0) || !(j.sigma<0.0))return 0.0;
    double f=-j.mu*j.sigma;if(j.cap>0.0)f=std::min(f,std::max(0.0,j.cap-j.fv0));return f;
}
double multiplier(const Joint& j,double f){
    const double net=std::max(0.0,j.tau-f);return net>j.fv0e?(net-j.fv0e)/(j.fv0-j.fv0e):0.0;
}

int run()
{
    std::mt19937_64 rng(20261008);std::uniform_real_distribution<double> U(0.0,1.0);
    auto decade=[&](double lo,double hi){return std::pow(10.0,lo+(hi-lo)*U(rng));};
    const PxU32 n=100000;std::vector<Joint> joints(n);
    for(Joint& j:joints) {
        j.area=decade(-3,0);j.fv0=decade(4.5,6.5);j.fv0e=j.fv0*(0.3+0.6*U(rng));
        j.mu=U(rng)<0.1?0.0:0.2+0.8*U(rng);
        j.cap=U(rng)<0.3?0.0:(U(rng)<0.15?j.fv0*(0.5+0.5*U(rng)):j.fv0*(1.0+decade(-2,1)));
        j.sigma=(U(rng)<0.8?-1.0:0.3)*j.fv0*decade(-1,1.5);               // compression mostly
        j.tau=j.fv0*decade(-0.7,1.3);
    }
    const auto withMu=grade(build(joints,true));
    // 2: the same joints at mu 0 with both limits shifted by the closed-form term.
    std::vector<Joint> shifted=joints;for(Joint& j:shifted){const double f=frictionTerm(j);j.fv0e+=f;j.fv0+=f;j.mu=0.0;j.cap=0.0;}
    const auto shiftedVerdict=grade(build(shifted,false));
    const auto noFriction=grade(build(joints,false));
    PxU32 closedCommand=0,closedBroken=0,closedDamage=0,shiftDiff=0,tensionDiff=0,capDiff=0,checked=0;
    for(PxU32 i=0;i<n;++i) {
        const Joint& j=joints[i];const auto& v=withMu[i];
        const double f=frictionTerm(j),u=multiplier(j,f);
        const double net=std::max(0.0,j.tau-f);
        // FP32 rounding: the shear is the force's tangential part after the
        // normal part is removed, so it carries a few ulps of |F| / A (tau and
        // |sigma|), and tau - f - e cancels: eps (tau + |sigma| + f + F) in
        // stress; over (F - e) in the multiplier.
        const double eps=std::ldexp(1.0,-23),scale=8.0*eps*(j.tau+std::fabs(j.sigma)+f+j.fv0),uScale=scale/(j.fv0-j.fv0e);
        const bool nearElastic=std::fabs(net-j.fv0e)<=scale,nearFatal=std::fabs(u-1.0)<=uScale;
        const double damageTol=(uScale+4.0*eps)*j.area*kDt*kRate;   // plus the multiplier's own rounding
        if(!nearElastic && !nearFatal) {
            ++checked;
            if(bool(v.command)!=(u>0.0)){if(!closedCommand)std::printf("  command off the closed form, joint %u: u %.9g\n",i,u);++closedCommand;}
            const bool broken=v.command && v.damage>=v.health+v.damage;   // the whole section gone
            if(broken!=(u>=1.0)){if(!closedBroken)std::printf("  fracture off the closed form, joint %u: u %.9g, damage %.9g of %.9g\n",i,u,double(v.damage),double(v.damage+v.health));++closedBroken;}
            if(u>0.0 && u<1.0) {
                const double expect=j.area*std::min(1.0,u*kDt*kRate);
                if(std::fabs(v.damage-expect)>damageTol){if(!closedDamage)std::printf("  sub-fatal damage off, joint %u: %.9g vs %.9g\n",i,double(v.damage),expect);++closedDamage;}
            }
            const auto& w=shiftedVerdict[i];
            if(v.command!=w.command || (u>=1.0)!=(w.damage>=w.health+w.damage) ||
               (u<1.0 && std::fabs(double(v.damage)-double(w.damage))>2.0*damageTol)){
                if(!shiftDiff)std::printf("  shifted limits differ, joint %u: damage %.9g vs %.9g\n",i,double(v.damage),double(w.damage));++shiftDiff;}
        }
        const auto& z=noFriction[i];
        const bool same=v.command==z.command && v.damage==z.damage && v.health==z.health && v.stressShear==z.stressShear;
        if(j.sigma>=0.0 && !same){if(!tensionDiff)std::printf("  tension took friction, joint %u\n",i);++tensionDiff;}
        if(j.cap>0.0 && j.cap<=j.fv0 && !same){if(!capDiff)std::printf("  a cap below f_v0 added strength, joint %u\n",i);++capDiff;}
    }
    // 5: worked numbers (EN 1996-1-1 3.6.2 form, f_v0 0.15 MPa, mu 0.4).
    std::vector<Joint> worked;const double A=0.01,fv0=0.15e6;
    for(double k:{0.99,1.01})worked.push_back({A,-0.5e6,k*0.35e6,0.5*fv0,fv0,0.4,0.0});   // f_v = 0.15 + 0.4 x 0.5 = 0.35 MPa
    for(double k:{0.99,1.01})worked.push_back({A,-0.5e6,k*0.30e6,0.5*fv0,fv0,0.4,0.30e6});// capped at f_vlt 0.3 MPa
    for(double k:{0.99,1.01})worked.push_back({A,+0.5e6,k*fv0,0.5*fv0,fv0,0.4,0.0});      // tension: f_v0 alone
    const auto wv=grade(build(worked,true));PxU32 workedOff=0;
    for(PxU32 i=0;i<wv.size();++i) {
        const bool broken=wv[i].command && wv[i].damage>=wv[i].health+wv[i].damage,expect=(i%2)==1;
        if(broken!=expect){std::printf("  worked case %u: broken %d, expected %d\n",i,int(broken),int(expect));++workedOff;}
    }
    std::printf("Mohr-Coulomb static verdict, %u joints (%u away from a limit): command off %u, fracture off %u, damage off %u; "
        "shifted limits differ %u; tension took friction %u; cap below f_v0 added strength %u; worked numbers off %u of 6\n",
        n,checked,closedCommand,closedBroken,closedDamage,shiftDiff,tensionDiff,capDiff,workedOff);
    return closedCommand||closedBroken||closedDamage||shiftDiff||tensionDiff||capDiff||workedOff?1:0;
}
}}
int main(){try{return physx::run();}catch(const std::exception& e){std::fprintf(stderr,"error: %s\n",e.what());return 3;}}
