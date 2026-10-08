// provisionalMotion (PX_CUMETAL pair version) timing: where do ~55 us go?
#include "common/PxPhysXCommonConfig.h"
#include "foundation/PxTransform.h"
#include "PxDestructionTopologyTypes.h"
#include "PxgDestructionFloatPair.cuh"
#define OLD_VALUE 1
#include <cuda_runtime.h>
#include <cstdio>
#include <cstring>
#include <random>
#include <vector>
#include <chrono>
#include <algorithm>
using namespace physx;
namespace physx{namespace{
#include "PxgDestructionMotionPair.cuh"
}}
using namespace physx::destructionPair;
__device__ __forceinline__ double exactDouble(float f){
  // float -> double by bits (normal and zero only; subnormal/inf/nan via the conversion)
  const unsigned b=__float_as_uint(f);const unsigned e=(b>>23)&0xff;
  if(e==0||e==0xff)return double(f);
  const unsigned long long d=((unsigned long long)(b>>31)<<63)|((unsigned long long)(e+896)<<52)|((unsigned long long)(b&0x7fffff)<<29);
  return __longlong_as_double((long long)d);}
template<int V> __global__ void k(const PxTransform* poses,const float4* pos,const float4* lin,const float4* ang,const double* centers,PxDestructionClusterMotion* out,unsigned n){
  unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
  if(V==0){PxDestructionClusterMotion o;destructionMotionPair::provisionalMotion(poses[i],pos[i],lin[i],ang[i],centers+3*i,o);out[i]=o;return;}
  if(V==1){ // only the double stores of float values (no pair math)
    PxDestructionClusterMotion o;const auto p=poses[i];o.origin[0]=p.p.x;o.origin[1]=p.p.y;o.origin[2]=p.p.z;o.orientation[0]=p.q.x;o.orientation[1]=p.q.y;o.orientation[2]=p.q.z;o.orientation[3]=p.q.w;
    o.angularVelocity[0]=ang[i].x;o.angularVelocity[1]=ang[i].y;o.angularVelocity[2]=ang[i].z;o.linearVelocity[0]=lin[i].x;o.linearVelocity[1]=lin[i].y;o.linearVelocity[2]=lin[i].z;out[i]=o;return;}
  if(V==2){ // same stores by bits
    PxDestructionClusterMotion o;const auto p=poses[i];o.origin[0]=exactDouble(p.p.x);o.origin[1]=exactDouble(p.p.y);o.origin[2]=exactDouble(p.p.z);o.orientation[0]=exactDouble(p.q.x);o.orientation[1]=exactDouble(p.q.y);o.orientation[2]=exactDouble(p.q.z);o.orientation[3]=exactDouble(p.q.w);
    o.angularVelocity[0]=exactDouble(ang[i].x);o.angularVelocity[1]=exactDouble(ang[i].y);o.angularVelocity[2]=exactDouble(ang[i].z);o.linearVelocity[0]=exactDouble(lin[i].x);o.linearVelocity[1]=exactDouble(lin[i].y);o.linearVelocity[2]=exactDouble(lin[i].z);out[i]=o;return;}
  if(V==3){ // pair splits + value only
    PxDestructionClusterMotion o{};const double* c=centers+3*i;for(int k=0;k<3;++k)o.linearVelocity[k]=value(add(pair(c[k]),pair(lin[i].x)));out[i]=o;return;}
}
int main(int argc,char**argv){const unsigned n=argc>1?atoi(argv[1]):600;std::mt19937 rng(2);std::uniform_real_distribution<float> u(-1,1);
  std::vector<PxTransform> poses(n);std::vector<float4> pos(n),lin(n),ang(n);std::vector<double> c(3*n);
  for(unsigned i=0;i<n;++i){PxQuat q(u(rng),u(rng),u(rng),u(rng));q.normalize();poses[i]=PxTransform(PxVec3(300*u(rng),30*u(rng),300*u(rng)),q);pos[i]=make_float4(300*u(rng),30*u(rng),300*u(rng),0);lin[i]=make_float4(u(rng),u(rng),u(rng),0);ang[i]=make_float4(u(rng),u(rng),u(rng),0);for(int k=0;k<3;++k)c[3*i+k]=5.0*u(rng);}
  auto up=[](const auto& v){using T=typename std::decay_t<decltype(v)>::value_type;T* d;cudaMalloc(&d,v.size()*sizeof(T));cudaMemcpy(d,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice);return d;};
  auto *dp=up(poses);auto* dpos=up(pos);auto* dl=up(lin);auto* da=up(ang);auto* dc=up(c);PxDestructionClusterMotion* dout;cudaMalloc(&dout,n*sizeof(PxDestructionClusterMotion));
  auto time=[&](auto f){double best=1e9;for(int r=0;r<5;++r){cudaDeviceSynchronize();auto t0=std::chrono::steady_clock::now();for(int j=0;j<30;++j)f();
    auto e=cudaDeviceSynchronize();if(e)printf("err %s\n",cudaGetErrorString(e));best=std::min(best,std::chrono::duration<double,std::micro>(std::chrono::steady_clock::now()-t0).count()/30);}return best;};
  const unsigned g=(n+127)/128;
  printf("n=%u full %.1f | float->double stores %.1f | bit stores %.1f | pair splits+value %.1f us/launch\n",n,
   time([&]{k<0><<<g,128>>>(dp,dpos,dl,da,dc,dout,n);}),time([&]{k<1><<<g,128>>>(dp,dpos,dl,da,dc,dout,n);}),time([&]{k<2><<<g,128>>>(dp,dpos,dl,da,dc,dout,n);}),time([&]{k<3><<<g,128>>>(dp,dpos,dl,da,dc,dout,n);}));}
