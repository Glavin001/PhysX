// prepareCorrectionBodyInputs (pairs) + prepareDeferredCorrectionBodyInputs vs the double path, on random
// city-scale clusters, some with tiny (deferred) inputs. Also times each variant (50 launches per sync).
#include "common/PxPhysXCommonConfig.h"
#include "PxgBodySim.h"
#include "PxDestructionTopologyTypes.h"
#include "PxDestructionScene.h"
#include "PxvDestructionBodyAllocator.h"
#include "PxgDestructionBody.cuh"
#include <cuda_runtime.h>
#include <cstdio>
#include <cstring>
#include <cmath>
#include <random>
#include <vector>
#include <chrono>
#include <algorithm>
namespace physx { namespace {
struct NativePreparationInputs { const PxgBodySim* checkpoint; const PxgBodySimVelocities* previous; PxU32 checkpointCount,bodyCapacity,clusterCount; PxU64 checkpointGeneration; };
__device__ PxgBodySim nativeCandidateState(const PxDestructionClusterBodyState&,const PxgBodySim& s,PxU32){return s;}
#include "PxgDestructionCorrection.cuh"
__global__ void doubleReference(const PxDestructionClusterBodyState* candidates,const PxU32* targets,
    PxU32 chunkCount,PxDestructionTopologyDeviceView topology,const PxDestructionStressChunk* chunks,
    const PxU32* affected,const PxgBodySim* checkpoint,const PxgBodySimVelocities* previous,PxU32 checkpointCount,PxU32 bodyCapacity,
    const PxDestructionCollisionPreparationStatus* collision,PxDestructionCorrectionBody* output,PxDestructionCorrectionPreparationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=chunkCount)return;
    output[i]={};output[i].targetBody=PX_INVALID_U32;
    PxDestructionClusterBodyState candidate;PxgBodySim source;
    if(!correctionPreconditions(i,candidates,targets,chunkCount,topology,chunks,affected,checkpoint,checkpointCount,bodyCapacity,collision,status,candidate,source))return;
    correctionBodyDouble(i,candidate,topology.clusters[candidate.cluster],source,previous,targets,output,status);
}
}}
using namespace physx;
static int ulp(float a,float b){if(a==b)return 0;int ia,ib;memcpy(&ia,&a,4);memcpy(&ib,&b,4);if((ia<0)!=(ib<0))return 1<<30;return std::abs(ia-ib);}
template<class T> T* up(const std::vector<T>& v){T* d;cudaMalloc(&d,std::max<size_t>(1,v.size())*sizeof(T));cudaMemcpy(d,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice);return d;}
int main(int argc,char**argv){
  const unsigned n=argc>1?atoi(argv[1]):4096,tinyEvery=argc>2?atoi(argv[2]):97;
  std::mt19937 rng(11);std::uniform_real_distribution<float> u(-1,1);
  auto quat=[&](float*q){float s=0;for(int k=0;k<4;++k){q[k]=u(rng);s+=q[k]*q[k];}s=std::sqrt(s);for(int k=0;k<4;++k)q[k]/=s;};
  std::vector<PxDestructionClusterBodyState> cand(n);std::vector<PxU32> targets(n),active(n),affected(n,1);
  std::vector<PxDestructionClusterMassProperties> clusters(n);std::vector<PxDestructionStressChunk> chunks(n);
  std::vector<PxgBodySim> bodies(n);std::vector<PxgBodySimVelocities> prev(n);
  for(unsigned i=0;i<n;++i){memset((void*)&cand[i],0,sizeof(cand[i]));memset((void*)&bodies[i],0,sizeof(bodies[i]));memset((void*)&chunks[i],0,sizeof(chunks[i]));memset((void*)&clusters[i],0,sizeof(clusters[i]));
    cand[i].cluster=i;cand[i].sourceBody=i;quat(cand[i].bodyToActorOrientation);active[i]=i;chunks[i].cluster=i;targets[i]=n+i;
    float q[4];quat(q);bodies[i].body2World=PxAlignedTransform(500*u(rng),50+50*u(rng),500*u(rng),PxAlignedQuat(q[0],q[1],q[2],q[3]));
    quat(q);float lp[3]={5*u(rng),5*u(rng),5*u(rng)};bodies[i].body2Actor_maxImpulseW=PxAlignedTransform(lp[0],lp[1],lp[2],PxAlignedQuat(q[0],q[1],q[2],q[3]));
    for(int k=0;k<3;++k)clusters[i].center[k]=double(lp[k])+2.0*u(rng)+1e-7*u(rng);
    bodies[i].linearVelocityXYZ_inverseMassW=make_float4(10*u(rng),10*u(rng),10*u(rng),1);
    bodies[i].angularVelocityXYZ_maxPenBiasW=make_float4(5*u(rng),5*u(rng),5*u(rng),0);
    PxU32 id=i;float f;memcpy(&f,&id,4);bodies[i].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex=make_float4(0,0,0,f);
    prev[i].linearVelocity=make_float4(10*u(rng),10*u(rng),10*u(rng),1);prev[i].angularVelocity=make_float4(5*u(rng),5*u(rng),5*u(rng),0);
    if(tinyEvery && i%tinyEvery==3){bodies[i].linearVelocityXYZ_inverseMassW.y=1e-30f;} // deferred: tiny velocity
    if(tinyEvery && i%tinyEvery==5){clusters[i].center[1]=1e-25;}                     // deferred: tiny centre
    if(tinyEvery && i%tinyEvery==7){prev[i].angularVelocity.z=-2e-38f;}                // deferred at the previous-velocity check
    if(tinyEvery && i%tinyEvery==11){cand[i].bodyToActorOrientation[0]*=1.001f;}      // fails the unit-norm test (error 4)
  }
  PxDestructionTopologyStatus ts{};ts.clusterCount=n;
  auto* dts=up(std::vector<PxDestructionTopologyStatus>{ts});
  PxDestructionTopologyDeviceView view{};view.status=dts;view.activeClusters=up(active);view.clusters=up(clusters);
  PxDestructionCollisionPreparationStatus col{};col.valid=1;auto* dcol=up(std::vector<PxDestructionCollisionPreparationStatus>{col});
  auto *dc=up(cand);auto* dt=up(targets);auto* dch=up(chunks);auto* da=up(affected);auto* db=up(bodies);auto* dp=up(prev);
  PxDestructionCorrectionBody *outP,*outD;cudaMalloc(&outP,n*sizeof(*outP));cudaMalloc(&outD,n*sizeof(*outD));
  PxDestructionCorrectionPreparationStatus *stP,*stD;cudaMalloc(&stP,sizeof(*stP));cudaMalloc(&stD,sizeof(*stD));
  cudaMemset(stP,0,sizeof(*stP));cudaMemset(stD,0,sizeof(*stD));
  const unsigned grid=(n+127)/128,cap=2*n;
  auto runPair=[&]{prepareCorrectionBodyInputs<<<grid,128>>>(dc,dt,n,view,dch,da,db,dp,n,cap,dcol,outP,stP);
                   prepareDeferredCorrectionBodyInputs<<<grid,128>>>(dc,dt,n,view,dch,da,db,dp,n,cap,dcol,outP,stP);};
  auto runDouble=[&]{doubleReference<<<grid,128>>>(dc,dt,n,view,dch,da,db,dp,n,cap,dcol,outD,stD);};
  auto time=[&](auto f){double best=1e9;for(int r=0;r<5;++r){cudaDeviceSynchronize();auto t0=std::chrono::steady_clock::now();for(int k=0;k<50;++k)f();
    auto e=cudaDeviceSynchronize();if(e)printf("error %s\n",cudaGetErrorString(e));best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/50);}return best;};
  const double tp=time(runPair),td=time(runDouble);
  const double ta=time([&]{prepareCorrectionBodyInputs<<<grid,128>>>(dc,dt,n,view,dch,da,db,dp,n,cap,dcol,outP,stP);});
  const double tb=time([&]{prepareDeferredCorrectionBodyInputs<<<grid,128>>>(dc,dt,n,view,dch,da,db,dp,n,cap,dcol,outP,stP);});
  printf("pair kernel alone %.1f deferred kernel alone %.1f\n",ta,tb);runPair();
  std::vector<PxDestructionCorrectionBody> hp(n),hd(n);cudaMemcpy(hp.data(),outP,n*sizeof(hp[0]),cudaMemcpyDeviceToHost);cudaMemcpy(hd.data(),outD,n*sizeof(hd[0]),cudaMemcpyDeviceToHost);
  PxDestructionCorrectionPreparationStatus sp,sd;cudaMemcpy(&sp,stP,sizeof(sp),cudaMemcpyDeviceToHost);cudaMemcpy(&sd,stD,sizeof(sd),cudaMemcpyDeviceToHost);
  int maxu=0,diff=0,targetMismatch=0,selected=0;
  for(unsigned i=0;i<n;++i){if(hp[i].targetBody!=hd[i].targetBody)++targetMismatch;if(hd[i].targetBody==PX_INVALID_U32)continue;++selected;
    const float* P[]={hp[i].body.bodyToWorldPosition,hp[i].body.bodyToWorldOrientation,hp[i].body.linearVelocity,hp[i].body.angularVelocity};
    const float* D[]={hd[i].body.bodyToWorldPosition,hd[i].body.bodyToWorldOrientation,hd[i].body.linearVelocity,hd[i].body.angularVelocity};
    const int c[]={3,4,3,3};for(int g=0;g<4;++g)for(int k=0;k<c[g];++k){int x=ulp(P[g][k],D[g][k]);maxu=std::max(maxu,x);diff+=x!=0;}
    if(memcmp(&hp[i].body,&hd[i].body,sizeof(hp[i].body)))++diff;}
  printf("n=%u selected %d | us/launch-pair pair+deferred %.1f double %.1f | target mismatches %d | differing records %d max ulp %d | status error pair %u double %u\n",
    n,selected,tp,td,targetMismatch,diff,maxu,sp.error,sd.error);
}
