// The runtime's provisionalTopologyMotion with its real types, against variants.
#include "PxgDestructionRuntime.h"
#include "PxgBodySim.h"
#include <cuda_runtime.h>
#include <cstdio>
#include <vector>
#include <cstdlib>
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
__global__ void heavy0(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+0.5;b=b*a-a/(0.25+b);a=sqrt(a*a+b*b)+0;}x[i]=a+b;}
__global__ void heavy1(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+1.5;b=b*a-a/(1.25+b);a=sqrt(a*a+b*b)+1;}x[i]=a+b;}
__global__ void heavy2(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+2.5;b=b*a-a/(2.25+b);a=sqrt(a*a+b*b)+2;}x[i]=a+b;}
__global__ void heavy3(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+3.5;b=b*a-a/(3.25+b);a=sqrt(a*a+b*b)+3;}x[i]=a+b;}
__global__ void heavy4(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+4.5;b=b*a-a/(4.25+b);a=sqrt(a*a+b*b)+4;}x[i]=a+b;}
__global__ void heavy5(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+5.5;b=b*a-a/(5.25+b);a=sqrt(a*a+b*b)+5;}x[i]=a+b;}
__global__ void heavy6(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+6.5;b=b*a-a/(6.25+b);a=sqrt(a*a+b*b)+6;}x[i]=a+b;}
__global__ void heavy7(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+7.5;b=b*a-a/(7.25+b);a=sqrt(a*a+b*b)+7;}x[i]=a+b;}
__global__ void heavy8(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+8.5;b=b*a-a/(8.25+b);a=sqrt(a*a+b*b)+8;}x[i]=a+b;}
__global__ void heavy9(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+9.5;b=b*a-a/(9.25+b);a=sqrt(a*a+b*b)+9;}x[i]=a+b;}
__global__ void heavy10(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+10.5;b=b*a-a/(10.25+b);a=sqrt(a*a+b*b)+10;}x[i]=a+b;}
__global__ void heavy11(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+11.5;b=b*a-a/(11.25+b);a=sqrt(a*a+b*b)+11;}x[i]=a+b;}
__global__ void heavy12(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+12.5;b=b*a-a/(12.25+b);a=sqrt(a*a+b*b)+12;}x[i]=a+b;}
__global__ void heavy13(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+13.5;b=b*a-a/(13.25+b);a=sqrt(a*a+b*b)+13;}x[i]=a+b;}
__global__ void heavy14(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+14.5;b=b*a-a/(14.25+b);a=sqrt(a*a+b*b)+14;}x[i]=a+b;}
__global__ void heavy15(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+15.5;b=b*a-a/(15.25+b);a=sqrt(a*a+b*b)+15;}x[i]=a+b;}
__global__ void heavy16(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+16.5;b=b*a-a/(16.25+b);a=sqrt(a*a+b*b)+16;}x[i]=a+b;}
__global__ void heavy17(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+17.5;b=b*a-a/(17.25+b);a=sqrt(a*a+b*b)+17;}x[i]=a+b;}
__global__ void heavy18(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+18.5;b=b*a-a/(18.25+b);a=sqrt(a*a+b*b)+18;}x[i]=a+b;}
__global__ void heavy19(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+19.5;b=b*a-a/(19.25+b);a=sqrt(a*a+b*b)+19;}x[i]=a+b;}
__global__ void heavy20(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+20.5;b=b*a-a/(20.25+b);a=sqrt(a*a+b*b)+20;}x[i]=a+b;}
__global__ void heavy21(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+21.5;b=b*a-a/(21.25+b);a=sqrt(a*a+b*b)+21;}x[i]=a+b;}
__global__ void heavy22(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+22.5;b=b*a-a/(22.25+b);a=sqrt(a*a+b*b)+22;}x[i]=a+b;}
__global__ void heavy23(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+23.5;b=b*a-a/(23.25+b);a=sqrt(a*a+b*b)+23;}x[i]=a+b;}
__global__ void heavy24(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+24.5;b=b*a-a/(24.25+b);a=sqrt(a*a+b*b)+24;}x[i]=a+b;}
__global__ void heavy25(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+25.5;b=b*a-a/(25.25+b);a=sqrt(a*a+b*b)+25;}x[i]=a+b;}
__global__ void heavy26(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+26.5;b=b*a-a/(26.25+b);a=sqrt(a*a+b*b)+26;}x[i]=a+b;}
__global__ void heavy27(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+27.5;b=b*a-a/(27.25+b);a=sqrt(a*a+b*b)+27;}x[i]=a+b;}
__global__ void heavy28(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+28.5;b=b*a-a/(28.25+b);a=sqrt(a*a+b*b)+28;}x[i]=a+b;}
__global__ void heavy29(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+29.5;b=b*a-a/(29.25+b);a=sqrt(a*a+b*b)+29;}x[i]=a+b;}
__global__ void heavy30(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+30.5;b=b*a-a/(30.25+b);a=sqrt(a*a+b*b)+30;}x[i]=a+b;}
__global__ void heavy31(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+31.5;b=b*a-a/(31.25+b);a=sqrt(a*a+b*b)+31;}x[i]=a+b;}
__global__ void heavy32(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+32.5;b=b*a-a/(32.25+b);a=sqrt(a*a+b*b)+32;}x[i]=a+b;}
__global__ void heavy33(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+33.5;b=b*a-a/(33.25+b);a=sqrt(a*a+b*b)+33;}x[i]=a+b;}
__global__ void heavy34(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+34.5;b=b*a-a/(34.25+b);a=sqrt(a*a+b*b)+34;}x[i]=a+b;}
__global__ void heavy35(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+35.5;b=b*a-a/(35.25+b);a=sqrt(a*a+b*b)+35;}x[i]=a+b;}
__global__ void heavy36(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<3;++r){a=a*b+36.5;b=b*a-a/(36.25+b);a=sqrt(a*a+b*b)+36;}x[i]=a+b;}
__global__ void heavy37(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<4;++r){a=a*b+37.5;b=b*a-a/(37.25+b);a=sqrt(a*a+b*b)+37;}x[i]=a+b;}
__global__ void heavy38(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<5;++r){a=a*b+38.5;b=b*a-a/(38.25+b);a=sqrt(a*a+b*b)+38;}x[i]=a+b;}
__global__ void heavy39(double* x,int n){int i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;double a=x[i],b=x[i+1];
  for(int r=0;r<6;++r){a=a*b+39.5;b=b*a-a/(39.25+b);a=sqrt(a*a+b*b)+39;}x[i]=a+b;}
template<class T> T* dev(const std::vector<T>& h){T* p;cudaMalloc(&p,h.size()*sizeof(T));cudaMemcpy(p,h.data(),h.size()*sizeof(T),cudaMemcpyHostToDevice);return p;}
int main(int argc,char** argv){
    const unsigned n=164;const int mode=argc>1?atoi(argv[1]):0;
    std::vector<PxDestructionStressChunk> chunks(n);std::vector<PxDestructionStressCluster> clusters(n);
    std::vector<PxTransform> poses(n);std::vector<PxgBodySim> bodies(n);std::vector<PxDestructionClusterMassProperties> mass(n);
    std::vector<PxU32> active(n);
    for(unsigned i=0;i<n;++i){chunks[i]={};chunks[i].cluster=i;clusters[i]={};clusters[i].body=i;
        float a=0.01f*i;poses[i]=PxTransform(PxVec3(10.f+i,2.f,-5.f*a),PxQuat(0.1f*a,0.2f,0.3f*a,0.9f));
        std::memset(&bodies[i],0,sizeof(PxgBodySim));bodies[i].body2World.p=make_float4(10.f+i,2.1f,-5.f,0);
        bodies[i].linearVelocityXYZ_inverseMassW=make_float4(1,2,3,0);bodies[i].angularVelocityXYZ_maxPenBiasW=make_float4(0.1f,0.2f*a,0.3f,0);
        if(mode==1){bodies[i].linearVelocityXYZ_inverseMassW=make_float4(0,0,0,0);bodies[i].angularVelocityXYZ_maxPenBiasW=make_float4(0,0,0,0);poses[i].q=PxQuat(PxIdentity);}
        if(mode==2){bodies[i].angularVelocityXYZ_maxPenBiasW=make_float4(1e-40f,-2e-39f,1e-41f,0);poses[i].q=PxQuat(1e-39f,0,0,1);}
        mass[i]={};mass[i].center[0]=0.3+i*1e-3;mass[i].center[1]=1.7;mass[i].center[2]=-0.25*i;active[i]=i;}
    PxDestructionTopologyStatus st{};st.clusterCount=n;
    PxDestructionTopologyDeviceView t{};t.activeClusters=dev(active);t.clusters=dev(mass);t.status=dev(std::vector<PxDestructionTopologyStatus>{st});
    auto* dc=dev(chunks);auto* dcl=dev(clusters);auto* dp=dev(poses);auto* db=dev(bodies);
    PxDestructionClusterMotion *m1,*m2;cudaMalloc(&m1,n*sizeof(*m1));cudaMalloc(&m2,n*sizeof(*m2));
    cudaEvent_t e0,e1;cudaEventCreate(&e0);cudaEventCreate(&e1);
    auto time=[&](auto kernel,PxDestructionClusterMotion* out,const char* name){
        for(int w=0;w<5;++w)kernel<<<2,128>>>(t,dc,dcl,dp,db,out);cudaDeviceSynchronize();float best=1e9;
        for(int r=0;r<20;++r){cudaEventRecord(e0);kernel<<<2,128>>>(t,dc,dcl,dp,db,out);cudaEventRecord(e1);cudaEventSynchronize(e1);float ms;cudaEventElapsedTime(&ms,e0,e1);best=std::min(best,ms);}
        std::printf("%s: best %.1f us (err %d)\n",name,best*1000,int(cudaGetLastError()));};
    time(original,m1,"original");time(fields,m2,"fields");
    std::vector<PxDestructionClusterMotion> a(n),b(n);cudaMemcpy(a.data(),m1,n*sizeof(a[0]),cudaMemcpyDeviceToHost);cudaMemcpy(b.data(),m2,n*sizeof(b[0]),cudaMemcpyDeviceToHost);
    std::printf("bitwise equal: %d\n",std::memcmp(a.data(),b.data(),n*sizeof(a[0]))==0);
}
