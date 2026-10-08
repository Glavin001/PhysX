// The runtime's provisionalTopologyMotion with its real types, against variants.
#include "PxgDestructionRuntime.h"
#include "PxgBodySim.h"
#include <cuda_runtime.h>
#include <cstdio>
#include <vector>
#include <cstdlib>
#include <thread>
#include <chrono>
#include <cstring>
using namespace physx;
__global__ void original(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    const PxTransform* poses,const PxgBodySim* bodies,PxDestructionClusterMotion* motion) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.status->clusterCount)return;
    const PxU32 root=topology.activeClusters[i],cluster=chunks[root].cluster;
    const auto pose=poses[cluster];const auto body=bodies[clusters[cluster].body];
    PxDestructionClusterMotion out{};
    for(PxU32 k=0;k<3;++k)out.origin[k]=pose.p[k];
    out.orientation[0]=pose.q.x;out.orientation[1]=pose.q.y;out.orientation[2]=pose.q.z;out.orientation[3]=pose.q.w;
    const auto* d=topology.clusters[root].center;const auto* q=out.orientation;
    const double t[3]={2*(q[1]*d[2]-q[2]*d[1]),2*(q[2]*d[0]-q[0]*d[2]),2*(q[0]*d[1]-q[1]*d[0])};
    const double r[3]={pose.p.x+d[0]+q[3]*t[0]+q[1]*t[2]-q[2]*t[1]-body.body2World.p.x,
        pose.p.y+d[1]+q[3]*t[1]+q[2]*t[0]-q[0]*t[2]-body.body2World.p.y,
        pose.p.z+d[2]+q[3]*t[2]+q[0]*t[1]-q[1]*t[0]-body.body2World.p.z};
    const auto v=body.linearVelocityXYZ_inverseMassW,w=body.angularVelocityXYZ_maxPenBiasW;
    out.angularVelocity[0]=w.x;out.angularVelocity[1]=w.y;out.angularVelocity[2]=w.z;
    out.linearVelocity[0]=v.x+w.y*r[2]-w.z*r[1];
    out.linearVelocity[1]=v.y+w.z*r[0]-w.x*r[2];
    out.linearVelocity[2]=v.z+w.x*r[1]-w.y*r[0];
    motion[i]=out;
}
// Same arithmetic; loads only the used body fields and builds the output in registers.
__global__ void fields(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    const PxTransform* poses,const PxgBodySim* bodies,PxDestructionClusterMotion* motion) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.status->clusterCount)return;
    const PxU32 root=topology.activeClusters[i],cluster=chunks[root].cluster;
    const PxTransform pose=poses[cluster];const PxgBodySim& body=bodies[clusters[cluster].body];
    const float4 bp=body.body2World.p,v=body.linearVelocityXYZ_inverseMassW,w=body.angularVelocityXYZ_maxPenBiasW;
    const double d[3]={topology.clusters[root].center[0],topology.clusters[root].center[1],topology.clusters[root].center[2]};
    const double q[4]={pose.q.x,pose.q.y,pose.q.z,pose.q.w};
    const double t[3]={2*(q[1]*d[2]-q[2]*d[1]),2*(q[2]*d[0]-q[0]*d[2]),2*(q[0]*d[1]-q[1]*d[0])};
    const double r[3]={pose.p.x+d[0]+q[3]*t[0]+q[1]*t[2]-q[2]*t[1]-bp.x,
        pose.p.y+d[1]+q[3]*t[1]+q[2]*t[0]-q[0]*t[2]-bp.y,
        pose.p.z+d[2]+q[3]*t[2]+q[0]*t[1]-q[1]*t[0]-bp.z};
    PxDestructionClusterMotion out;
    out.origin[0]=pose.p.x;out.origin[1]=pose.p.y;out.origin[2]=pose.p.z;
    for(PxU32 k=0;k<4;++k)out.orientation[k]=q[k];
    out.angularVelocity[0]=w.x;out.angularVelocity[1]=w.y;out.angularVelocity[2]=w.z;
    out.linearVelocity[0]=v.x+w.y*r[2]-w.z*r[1];
    out.linearVelocity[1]=v.y+w.z*r[0]-w.x*r[2];
    out.linearVelocity[2]=v.z+w.x*r[1]-w.y*r[0];
    motion[i]=out;
}
// Loop form: each emulated double operation appears once per loop body.
__global__ void looped(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
    const PxTransform* poses,const PxgBodySim* bodies,PxDestructionClusterMotion* motion) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.status->clusterCount)return;
    const PxU32 root=topology.activeClusters[i],cluster=chunks[root].cluster;
    const PxTransform pose=poses[cluster];const PxgBodySim& body=bodies[clusters[cluster].body];
    const float4 b4=body.body2World.p,v4=body.linearVelocityXYZ_inverseMassW,w4=body.angularVelocityXYZ_maxPenBiasW;
    const float p[3]={pose.p.x,pose.p.y,pose.p.z},bp[3]={b4.x,b4.y,b4.z},v[3]={v4.x,v4.y,v4.z},w[3]={w4.x,w4.y,w4.z};
    PxDestructionClusterMotion out;
    for(PxU32 k=0;k<3;++k){out.origin[k]=p[k];out.angularVelocity[k]=w[k];}
    out.orientation[0]=pose.q.x;out.orientation[1]=pose.q.y;out.orientation[2]=pose.q.z;out.orientation[3]=pose.q.w;
    const double* d=topology.clusters[root].center;const double* q=out.orientation;
    double t[3],r[3];
#pragma unroll 1
    for(PxU32 k=0;k<3;++k){const PxU32 a=k==2?0:k+1,b=k==0?2:k-1;t[k]=2*(q[a]*d[b]-q[b]*d[a]);}
#pragma unroll 1
    for(PxU32 k=0;k<3;++k){const PxU32 a=k==2?0:k+1,b=k==0?2:k-1;r[k]=p[k]+d[k]+q[3]*t[k]+q[a]*t[b]-q[b]*t[a]-bp[k];}
#pragma unroll 1
    for(PxU32 k=0;k<3;++k){const PxU32 a=k==2?0:k+1,b=k==0?2:k-1;out.linearVelocity[k]=v[k]+w[a]*r[b]-w[b]*r[a];}
    motion[i]=out;
}
template<class T> T* dev(const std::vector<T>& h){T* p;cudaMalloc(&p,h.size()*sizeof(T));cudaMemcpy(p,h.data(),h.size()*sizeof(T),cudaMemcpyHostToDevice);return p;}
int main(int argc,char** argv){
    const unsigned n=164;const int mode=argc>1?atoi(argv[1]):0;const int dataMode=mode%10;
    std::vector<PxDestructionStressChunk> chunks(n);std::vector<PxDestructionStressCluster> clusters(n);
    std::vector<PxTransform> poses(n);std::vector<PxgBodySim> bodies(n);std::vector<PxDestructionClusterMassProperties> mass(n);
    std::vector<PxU32> active(n);
    for(unsigned i=0;i<n;++i){chunks[i]={};chunks[i].cluster=i;clusters[i]={};clusters[i].body=i;
        float a=0.01f*i;poses[i]=PxTransform(PxVec3(10.f+i,2.f,-5.f*a),PxQuat(0.1f*a,0.2f,0.3f*a,0.9f));
        std::memset(&bodies[i],0,sizeof(PxgBodySim));bodies[i].body2World.p=make_float4(10.f+i,2.1f,-5.f,0);
        bodies[i].linearVelocityXYZ_inverseMassW=make_float4(1,2,3,0);bodies[i].angularVelocityXYZ_maxPenBiasW=make_float4(0.1f,0.2f*a,0.3f,0);
        if(dataMode==1){bodies[i].linearVelocityXYZ_inverseMassW=make_float4(0,0,0,0);bodies[i].angularVelocityXYZ_maxPenBiasW=make_float4(0,0,0,0);poses[i].q=PxQuat(PxIdentity);}
        if(dataMode==2){bodies[i].angularVelocityXYZ_maxPenBiasW=make_float4(1e-40f,-2e-39f,1e-41f,0);poses[i].q=PxQuat(1e-39f,0,0,1);}
        mass[i]={};mass[i].center[0]=0.3+i*1e-3;mass[i].center[1]=1.7;mass[i].center[2]=-0.25*i;active[i]=i;}
    PxDestructionTopologyStatus st{};st.clusterCount=n;
    PxDestructionTopologyDeviceView t{};t.activeClusters=dev(active);t.clusters=dev(mass);t.status=dev(std::vector<PxDestructionTopologyStatus>{st});
    auto* dc=dev(chunks);auto* dcl=dev(clusters);auto* dp=dev(poses);auto* db=dev(bodies);
    PxDestructionClusterMotion *m1,*m2;cudaMalloc(&m1,n*sizeof(*m1));cudaMalloc(&m2,n*sizeof(*m2));
    cudaEvent_t e0,e1;cudaEventCreate(&e0);cudaEventCreate(&e1);
    auto time=[&](auto kernel,PxDestructionClusterMotion* out,const char* name){
        for(int w=0;w<5;++w)kernel<<<2,128>>>(t,dc,dcl,dp,db,out);cudaDeviceSynchronize();float best=1e9;
        for(int r=0;r<20;++r){if(mode>=10)std::this_thread::sleep_for(std::chrono::milliseconds(16));cudaEventRecord(e0);kernel<<<2,128>>>(t,dc,dcl,dp,db,out);cudaEventRecord(e1);cudaEventSynchronize(e1);float ms;cudaEventElapsedTime(&ms,e0,e1);best=std::min(best,ms);}
        std::printf("%s: best %.1f us (err %d)\n",name,best*1000,int(cudaGetLastError()));};
    time(original,m1,"original");time(looped,m2,"looped");
    std::vector<PxDestructionClusterMotion> a(n),b(n);cudaMemcpy(a.data(),m1,n*sizeof(a[0]),cudaMemcpyDeviceToHost);cudaMemcpy(b.data(),m2,n*sizeof(b[0]),cudaMemcpyDeviceToHost);
    std::printf("bitwise equal: %d\n",std::memcmp(a.data(),b.data(),n*sizeof(a[0]))==0);
}
