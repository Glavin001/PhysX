// Validation + timing: prepareCorrectionBodyInputs' motion, double vs float pairs vs host double.
#include "common/PxPhysXCommonConfig.h"
#include "PxgBodySim.h"
#include "PxDestructionTopologyTypes.h"
#include "PxDestructionScene.h"
#include "PxvDestructionBodyAllocator.h"
#include "PxgDestructionBody.cuh"
#include <cuda_runtime.h>
#include <cstdio>
#include <cmath>
#include <random>
#include <vector>
#include <chrono>
#include <algorithm>
namespace physx { namespace {
struct NativePreparationInputs { const PxgBodySim* checkpoint; const PxgBodySimVelocities* previous; PxU32 checkpointCount,bodyCapacity,clusterCount; PxU64 checkpointGeneration; };
__device__ PxgBodySim nativeCandidateState(const PxDestructionClusterBodyState&,const PxgBodySim& s,PxU32){return s;}
#include "PxgDestructionCorrection.cuh"
}}
using namespace physx;
struct In { PxDestructionClusterBodyState cand; PxDestructionClusterMassProperties mass; PxgBodySim src; };
struct Out { PxDestructionClusterBodyState o; int ok; };
__global__ void kDouble(const In* in,Out* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  Out r{};r.ok=correctionMotionDouble(in[i].cand,in[i].mass,in[i].src,r.o);out[i]=r;}
__device__ __noinline__ bool dblNoInline(const PxDestructionClusterBodyState& c,const PxDestructionClusterMassProperties& m,const PxgBodySim& s,PxDestructionClusterBodyState& o){return correctionMotionDouble(c,m,s,o);}
__global__ void kV1(const In* in,Out* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  Out r{};r.ok=destructionCorrectionPair::motionInRange(in[i].cand,in[i].mass,in[i].src)?destructionCorrectionPair::motion(in[i].cand,in[i].mass,in[i].src,r.o):dblNoInline(in[i].cand,in[i].mass,in[i].src,r.o);out[i]=r;}
__global__ void kV4(const In* in,Out* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  Out r{};r.ok=destructionCorrectionPair::motionInRange(in[i].cand,in[i].mass,in[i].src)?destructionCorrectionPair::motion(in[i].cand,in[i].mass,in[i].src,r.o):correctionMotionFallback(in[i].cand,in[i].mass,in[i].src,r.o);out[i]=r;}
__global__ void kOnly(const In* in,Out* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  Out r{};r.ok=destructionCorrectionPair::motion(in[i].cand,in[i].mass,in[i].src,r.o);out[i]=r;}
__global__ void kVelOnly(const In* in,Out* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  Out r{};r.ok=destructionCorrectionPair::velocity(in[i].cand.bodyToActorPosition,in[i].src,in[i].src.linearVelocityXYZ_inverseMassW,in[i].src.angularVelocityXYZ_maxPenBiasW,r.o.linearVelocity,r.o.angularVelocity);out[i]=r;}
__global__ void kEmpty(const In* in,Out* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  Out r{};r.ok=1;out[i]=r;}
__global__ void kPair(const In* in,Out* out,unsigned n){unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  Out r{};r.ok=correctionMotion(in[i].cand,in[i].mass,in[i].src,r.o);out[i]=r;}
// Host double reference, the double formulas verbatim.
static bool hostMotion(const In& in,float* pos,float* q,float* lin,float* ang){
  const auto& s=in.src;const PxTransform W=s.body2World.getTransform(),L=s.body2Actor_maxImpulseW.getTransform();double wq[4]={W.q.x,W.q.y,W.q.z,W.q.w};
  double lq[4]={L.q.x,L.q.y,L.q.z,L.q.w};
  double wn=0,ln=0;for(int k=0;k<4;++k){wn+=wq[k]*wq[k];ln+=lq[k]*lq[k];}for(int k=0;k<4;++k){wq[k]/=std::sqrt(wn);lq[k]/=std::sqrt(ln);}
  const double a[4]={-wq[3]*lq[0]+wq[0]*lq[3]-wq[1]*lq[2]+wq[2]*lq[1],-wq[3]*lq[1]+wq[0]*lq[2]+wq[1]*lq[3]-wq[2]*lq[0],
    -wq[3]*lq[2]-wq[0]*lq[1]+wq[1]*lq[0]+wq[2]*lq[3],wq[3]*lq[3]+wq[0]*lq[0]+wq[1]*lq[1]+wq[2]*lq[2]};
  const double lp[3]={L.p.x,L.p.y,L.p.z};
  const double off[3]={in.mass.center[0]-lp[0],in.mass.center[1]-lp[1],in.mass.center[2]-lp[2]};
  const double t[3]={2*(a[1]*off[2]-a[2]*off[1]),2*(a[2]*off[0]-a[0]*off[2]),2*(a[0]*off[1]-a[1]*off[0])};
  const double d[3]={off[0]+a[3]*t[0]+a[1]*t[2]-a[2]*t[1],off[1]+a[3]*t[1]+a[2]*t[0]-a[0]*t[2],off[2]+a[3]*t[2]+a[0]*t[1]-a[1]*t[0]};
  const double wp[3]={W.p.x,W.p.y,W.p.z};
  for(int k=0;k<3;++k)pos[k]=float(wp[k]+d[k]);
  double p[4],n=0;for(int k=0;k<4;++k){p[k]=in.cand.bodyToActorOrientation[k];n+=p[k]*p[k];}for(int k=0;k<4;++k)p[k]/=std::sqrt(n);
  const double qq[4]={a[3]*p[0]+a[0]*p[3]+a[1]*p[2]-a[2]*p[1],a[3]*p[1]-a[0]*p[2]+a[1]*p[3]+a[2]*p[0],a[3]*p[2]+a[0]*p[1]-a[1]*p[0]+a[2]*p[3],a[3]*p[3]-a[0]*p[0]-a[1]*p[1]-a[2]*p[2]};
  for(int k=0;k<4;++k)q[k]=float(qq[k]);
  const double r[3]={double(pos[0])-wp[0],double(pos[1])-wp[1],double(pos[2])-wp[2]};
  const auto v=s.linearVelocityXYZ_inverseMassW,w=s.angularVelocityXYZ_maxPenBiasW;
  lin[0]=float(v.x+double(w.y)*r[2]-double(w.z)*r[1]);lin[1]=float(v.y+double(w.z)*r[0]-double(w.x)*r[2]);lin[2]=float(v.z+double(w.x)*r[1]-double(w.y)*r[0]);
  ang[0]=w.x;ang[1]=w.y;ang[2]=w.z;return true;}
static int ulp(float a,float b){if(a==b)return 0;int ia,ib;memcpy(&ia,&a,4);memcpy(&ib,&b,4);if((ia<0)!=(ib<0))return 1<<30;return std::abs(ia-ib);}
int main(int argc,char**argv){
  const unsigned n=argc>1?atoi(argv[1]):4096;std::mt19937 rng(7);std::uniform_real_distribution<float> u(-1,1);
  auto quat=[&](float*q){float s=0;for(int k=0;k<4;++k){q[k]=u(rng);s+=q[k]*q[k];}s=std::sqrt(s);for(int k=0;k<4;++k)q[k]/=s;};
  std::vector<In> in(n);
  for(auto& x:in){memset((void*)&x,0,sizeof(x));float q[4];
    quat(q);x.src.body2World=PxAlignedTransform(500*u(rng),50+50*u(rng),500*u(rng),PxAlignedQuat(q[0],q[1],q[2],q[3]));
    quat(q);float lp[3]={5*u(rng),5*u(rng),5*u(rng)};x.src.body2Actor_maxImpulseW=PxAlignedTransform(lp[0],lp[1],lp[2],PxAlignedQuat(q[0],q[1],q[2],q[3]));
    for(int k=0;k<3;++k)x.mass.center[k]=double(lp[k])+2.0*u(rng)+1e-7*u(rng);
    quat(x.cand.bodyToActorOrientation);
    x.src.linearVelocityXYZ_inverseMassW=make_float4(10*u(rng),10*u(rng),10*u(rng),1);
    x.src.angularVelocityXYZ_maxPenBiasW=make_float4(5*u(rng),5*u(rng),5*u(rng),0);}
  In* din;Out *dd,*dp;cudaMalloc(&din,n*sizeof(In));cudaMalloc(&dd,n*sizeof(Out));cudaMalloc(&dp,n*sizeof(Out));
  cudaMemcpy(din,in.data(),n*sizeof(In),cudaMemcpyHostToDevice);
  auto time=[&](auto k,Out* o){double best=1e9;for(int r=0;r<7;++r){cudaDeviceSynchronize();auto t0=std::chrono::steady_clock::now();
    for(int rep=0;rep<50;++rep)k<<<(n+127)/128,128>>>(din,o,n);{auto e=cudaGetLastError();auto e2=cudaDeviceSynchronize();if(e||e2)printf("launch error %s / %s\n",cudaGetErrorString(e),cudaGetErrorString(e2));}best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/50);}return best;};
  const double td=time(kDouble,dd);printf("empty %.1f\n",time(kEmpty,dp));printf("velonly %.1f\n",time(kVelOnly,dp));printf("only %.1f\n",time(kOnly,dp));printf("v1 %.1f\n",time(kV1,dp));printf("v4 %.1f\n",time(kV4,dp));const double tp=time(kPair,dp);
  std::vector<Out> od(n),op(n);cudaMemcpy(od.data(),dd,n*sizeof(Out),cudaMemcpyDeviceToHost);cudaMemcpy(op.data(),dp,n*sizeof(Out),cudaMemcpyDeviceToHost);
  int maxD=0,maxP=0,diffDP=0,okMismatch=0;long sumP=0;
  for(unsigned i=0;i<n;++i){float pos[3],q[4],lin[3],ang[3];hostMotion(in[i],pos,q,lin,ang);
    if(od[i].ok!=op[i].ok)++okMismatch;
    const float* H[]={pos,q,lin,ang};const float* D[]={od[i].o.bodyToWorldPosition,od[i].o.bodyToWorldOrientation,od[i].o.linearVelocity,od[i].o.angularVelocity};
    const float* P[]={op[i].o.bodyToWorldPosition,op[i].o.bodyToWorldOrientation,op[i].o.linearVelocity,op[i].o.angularVelocity};
    const int cnt[]={3,4,3,3};
    for(int g=0;g<4;++g)for(int k=0;k<cnt[g];++k){int ud=ulp(D[g][k],H[g][k]),up=ulp(P[g][k],H[g][k]);maxD=std::max(maxD,ud);maxP=std::max(maxP,up);sumP+=up;if(D[g][k]!=P[g][k])++diffDP;}}
  printf("d0 pos %g %g %g q %g %g %g %g lin %g %g %g\n",od[0].o.bodyToWorldPosition[0],od[0].o.bodyToWorldPosition[1],od[0].o.bodyToWorldPosition[2],od[0].o.bodyToWorldOrientation[0],od[0].o.bodyToWorldOrientation[1],od[0].o.bodyToWorldOrientation[2],od[0].o.bodyToWorldOrientation[3],od[0].o.linearVelocity[0],od[0].o.linearVelocity[1],od[0].o.linearVelocity[2]);
  printf("p0 pos %g %g %g q %g %g %g %g lin %g %g %g\n",op[0].o.bodyToWorldPosition[0],op[0].o.bodyToWorldPosition[1],op[0].o.bodyToWorldPosition[2],op[0].o.bodyToWorldOrientation[0],op[0].o.bodyToWorldOrientation[1],op[0].o.bodyToWorldOrientation[2],op[0].o.bodyToWorldOrientation[3],op[0].o.linearVelocity[0],op[0].o.linearVelocity[1],op[0].o.linearVelocity[2]);
  printf("n=%u time_us double %.1f pair %.1f | vs host double: max ulp gpu-double %d pair %d (sum %ld) | double!=pair outputs %d | ok mismatches %d | ok %d/%d\n",
    n,td,tp,maxD,maxP,sumP,diffDP,okMismatch,op[0].ok,od[0].ok);
}
