#include "common/PxPhysXCommonConfig.h"
#include "PxgBodySim.h"
#include "PxDestructionTopologyTypes.h"
#include "PxgDestructionBody.cuh"
#include <cstdio>
__device__ bool velDouble(const float* center,const physx::PxgBodySim& source,const float4& v,const float4& w,float* linear,float* angular) {
    const double r[3]={double(center[0])-source.body2World.p.x,double(center[1])-source.body2World.p.y,double(center[2])-source.body2World.p.z};
    const double velocity[3]={v.x+double(w.y)*r[2]-double(w.z)*r[1],v.y+double(w.z)*r[0]-double(w.x)*r[2],v.z+double(w.x)*r[1]-double(w.y)*r[0]};
    const double spin[3]={w.x,w.y,w.z};
    for(unsigned k=0;k<3;++k)if(!physx::destructionBody::motionValue(velocity[k],linear[k]) || !physx::destructionBody::motionValue(spin[k],angular[k]))return false;
    return true;}
__device__ bool velPair(const float* center,const physx::PxgBodySim& source,const float4& v,const float4& w,float* linear,float* angular) {
    using namespace physx::destructionPair;
    const Pair r[3]={sub(pair(center[0]),pair(source.body2World.p.x)),sub(pair(center[1]),pair(source.body2World.p.y)),sub(pair(center[2]),pair(source.body2World.p.z))};
    const float vv[3]={v.x,v.y,v.z},ww[3]={w.x,w.y,w.z};
    for(unsigned k=0;k<3;++k){const unsigned i=k==2?0:k+1,j=k==0?2:k-1;
        if(!physx::destructionBody::motionValue(sub(add(pair(vv[k]),mul(r[j],ww[i])),mul(r[i],ww[j])),linear[k]) || !physx::destructionBody::motionValue(pair(ww[k]),angular[k]))return false;}
    return true;}
using namespace physx;using namespace physx::destructionPair;
struct In { PxDestructionClusterBodyState cand; PxDestructionClusterMassProperties mass; PxgBodySim src; };
template<int S> __device__ bool m(const In& in,PxDestructionClusterBodyState& output){
    const auto& source=in.src;const auto& mass=in.mass;const auto& candidate=in.cand;
    const auto world=source.body2World.getTransform(),local=source.body2Actor_maxImpulseW.getTransform();
    if(S&128){if(!world.isValid() || !local.isValid())return false;}
    Pair wq[4]={pair(world.q.x),pair(world.q.y),pair(world.q.z),pair(world.q.w)},
        lq[4]={pair(local.q.x),pair(local.q.y),pair(local.q.z),pair(local.q.w)};
    Pair wn=pair(0.0f),ln=pair(0.0f);for(unsigned k=0;k<4;++k){wn=add(wn,mul(wq[k],wq[k]));ln=add(ln,mul(lq[k],lq[k]));}
    if(S&1){const Pair wr=sqrt(wn),lr=sqrt(ln);for(unsigned k=0;k<4;++k){wq[k]=div(wq[k],wr);lq[k]=div(lq[k],lr);}}
    const Pair actor[4]={add(sub(add(neg(mul(wq[3],lq[0])),mul(wq[0],lq[3])),mul(wq[1],lq[2])),mul(wq[2],lq[1])),
        sub(add(add(neg(mul(wq[3],lq[1])),mul(wq[0],lq[2])),mul(wq[1],lq[3])),mul(wq[2],lq[0])),
        add(add(sub(neg(mul(wq[3],lq[2])),mul(wq[0],lq[1])),mul(wq[1],lq[0])),mul(wq[2],lq[3])),
        add(add(add(mul(wq[3],lq[3]),mul(wq[0],lq[0])),mul(wq[1],lq[1])),mul(wq[2],lq[2]))};
    Pair offset[3];
    if(S&2){offset[0]=sub(pair(mass.center[0]),pair(local.p.x));offset[1]=sub(pair(mass.center[1]),pair(local.p.y));offset[2]=sub(pair(mass.center[2]),pair(local.p.z));}
    else {offset[0]=pair(local.p.x);offset[1]=pair(local.p.y);offset[2]=pair(local.p.z);}
    Pair delta[3];destructionBody::rotate(actor,offset,delta);output=candidate;
    for(unsigned k=0;k<3;++k)if(!destructionBody::motionValue(add(pair(world.p[k]),delta[k]),output.bodyToWorldPosition[k]))return false;
    Pair principal[4],norm=pair(0.0f);
    for(unsigned k=0;k<4;++k){principal[k]=pair(candidate.bodyToActorOrientation[k]);norm=add(norm,mul(principal[k],principal[k]));}
    if(S&4){constexpr float toleranceHi=1e-5f;constexpr float toleranceLo=float(1e-5-double(toleranceHi));
    if(!finite(norm) || less(Pair{toleranceHi,toleranceLo},abs(sub(norm,pair(1.0f)))))return false;}
    if(S&8){const Pair root=sqrt(norm);for(unsigned k=0;k<4;++k)principal[k]=div(principal[k],root);}
    const Pair* a=actor;const Pair* p=principal;
    const Pair q[4]={sub(add(add(mul(a[3],p[0]),mul(a[0],p[3])),mul(a[1],p[2])),mul(a[2],p[1])),
        add(add(sub(mul(a[3],p[1]),mul(a[0],p[2])),mul(a[1],p[3])),mul(a[2],p[0])),
        add(sub(add(mul(a[3],p[2]),mul(a[0],p[1])),mul(a[1],p[0])),mul(a[2],p[3])),
        sub(sub(sub(mul(a[3],p[3]),mul(a[0],p[0])),mul(a[1],p[1])),mul(a[2],p[2]))};
    for(unsigned k=0;k<4;++k)output.bodyToWorldOrientation[k]=q[k].hi;
    const float4 v=source.linearVelocityXYZ_inverseMassW,w=source.angularVelocityXYZ_maxPenBiasW;
    if(S&16)return velPair(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);
    if(S&32)return velDouble(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);
    if(S&256){const float* center=output.bodyToWorldPosition;const float c[]={center[0],center[1],center[2],source.body2World.p.x,source.body2World.p.y,source.body2World.p.z,
        v.x,v.y,v.z,w.x,w.y,w.z};bool okr=true;
      for(const float x:c)if(x!=0 && !(fabsf(x)>=0x1p-60f))okr=false;
      if(!okr)return velDouble(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);
      return velPair(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);}
    if(S&512){const float* center=output.bodyToWorldPosition;
      auto t=[](float x){return x!=0 && !(fabsf(x)>=0x1p-60f);};
      const bool bad=t(center[0])||t(center[1])||t(center[2])||t(source.body2World.p.x)||t(source.body2World.p.y)||t(source.body2World.p.z)
        ||t(v.x)||t(v.y)||t(v.z)||t(w.x)||t(w.y)||t(w.z);
      if(bad)return velDouble(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);
      return velPair(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);}
    if(S&1024){const float* center=output.bodyToWorldPosition;
      // smallest nonzero magnitude via integer bits: |x| bits in (0, bits(2^-60)) is tiny
      auto t=[](float x){const unsigned b=__float_as_uint(x)&0x7fffffffu;return b!=0 && b<0x21800000u;};
      const bool bad=t(center[0])|t(center[1])|t(center[2])|t(source.body2World.p.x)|t(source.body2World.p.y)|t(source.body2World.p.z)
        |t(v.x)|t(v.y)|t(v.z)|t(w.x)|t(w.y)|t(w.z);
      if(bad)return velDouble(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);
      return velPair(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);}
    if(S&64){if(output.bodyToWorldPosition[0]==0)return velDouble(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);
       return velPair(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity);}
    return true;
}
template<int S> __global__ void k(const In* in,PxDestructionClusterBodyState* out,int* ok){unsigned i=threadIdx.x;ok[i]=m<S>(in[i],out[i]);}
template<int S> void run(In* in,PxDestructionClusterBodyState* o,int* ok){k<S><<<1,32>>>(in,o,ok);auto e=cudaDeviceSynchronize();printf("S=%d %s\n",S,cudaGetErrorString(e));cudaGetLastError();}
int main(){In* in;PxDestructionClusterBodyState* o;int* ok;cudaMalloc(&in,32*sizeof(In));cudaMalloc(&o,32*sizeof(*o));cudaMalloc(&ok,128);cudaMemset(in,0,32*sizeof(In));
 run<15+128+512>(in,o,ok);run<15+128+1024>(in,o,ok);}
