// Microbench of provisionalTopologyMotion's double chain (the runtime kernel's
// arithmetic, simplified types) at the city's scale: 164 active clusters.
#include <cuda_runtime.h>
#include <cstdio>
#include <vector>
struct Pose { float qx,qy,qz,qw,px,py,pz; };
struct Body { float4 v, w, p; };
struct Motion { double origin[3], orientation[4], linearVelocity[3], angularVelocity[3]; };
struct Center { double c[3]; };
__device__ inline void motionOf(const Pose& pose,const Body& body,const double* d,Motion& out){
    out.origin[0]=pose.px;out.origin[1]=pose.py;out.origin[2]=pose.pz;
    out.orientation[0]=pose.qx;out.orientation[1]=pose.qy;out.orientation[2]=pose.qz;out.orientation[3]=pose.qw;
    const double* q=out.orientation;
    const double t[3]={2*(q[1]*d[2]-q[2]*d[1]),2*(q[2]*d[0]-q[0]*d[2]),2*(q[0]*d[1]-q[1]*d[0])};
    const double r[3]={pose.px+d[0]+q[3]*t[0]+q[1]*t[2]-q[2]*t[1]-body.p.x,
        pose.py+d[1]+q[3]*t[1]+q[2]*t[0]-q[0]*t[2]-body.p.y,
        pose.pz+d[2]+q[3]*t[2]+q[0]*t[1]-q[1]*t[0]-body.p.z};
    const auto v=body.v,w=body.w;
    out.angularVelocity[0]=w.x;out.angularVelocity[1]=w.y;out.angularVelocity[2]=w.z;
    out.linearVelocity[0]=v.x+w.y*r[2]-w.z*r[1];
    out.linearVelocity[1]=v.y+w.z*r[0]-w.x*r[2];
    out.linearVelocity[2]=v.z+w.x*r[1]-w.y*r[0];
}
__global__ void original(const Pose* poses,const Body* bodies,const Center* centers,Motion* out,const unsigned* count){
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=*count)return;
    Motion m{};motionOf(poses[i],bodies[i],centers[i].c,m);out[i]=m;
}
int main(){
    const unsigned n=164;std::vector<Pose> p(n);std::vector<Body> b(n);std::vector<Center> c(n);
    for(unsigned i=0;i<n;++i){float a=0.01f*i;p[i]={0.1f*a,0.2f,0.3f*a,0.9f,10.f+i,2.f,-5.f*a};
        b[i]={make_float4(1,2,3,0),make_float4(0.1f,0.2f*a,0.3f,0),make_float4(10.f+i,2.1f,-5.f,0)};c[i]={{0.3+i*1e-3,1.7,-0.25*i}};}
    Pose* dp;Body* db;Center* dc;Motion* dm;unsigned* dn;
    cudaMalloc(&dp,n*sizeof(Pose));cudaMalloc(&db,n*sizeof(Body));cudaMalloc(&dc,n*sizeof(Center));cudaMalloc(&dm,n*sizeof(Motion));cudaMalloc(&dn,4);
    cudaMemcpy(dp,p.data(),n*sizeof(Pose),cudaMemcpyHostToDevice);cudaMemcpy(db,b.data(),n*sizeof(Body),cudaMemcpyHostToDevice);
    cudaMemcpy(dc,c.data(),n*sizeof(Center),cudaMemcpyHostToDevice);cudaMemcpy(dn,&n,4,cudaMemcpyHostToDevice);
    cudaEvent_t e0,e1;cudaEventCreate(&e0);cudaEventCreate(&e1);
    for(unsigned block:{128u,64u,32u}){
        const unsigned grid=(n+block-1)/block;
        for(int w=0;w<5;++w)original<<<grid,block>>>(dp,db,dc,dm,dn);
        cudaDeviceSynchronize();
        float best=1e9;
        for(int r=0;r<20;++r){cudaEventRecord(e0);original<<<grid,block>>>(dp,db,dc,dm,dn);cudaEventRecord(e1);cudaEventSynchronize(e1);
            float ms;cudaEventElapsedTime(&ms,e0,e1);if(ms<best)best=ms;}
        std::printf("block %u: best %.1f us\n",block,best*1000);
    }
    Motion m;cudaMemcpy(&m,dm,sizeof(m),cudaMemcpyDeviceToHost);std::printf("check %.17g\n",m.linearVelocity[0]);
}
