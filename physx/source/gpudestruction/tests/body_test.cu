// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Independent analytic tensors/motion check the GPU code used by the scene task.
#include "../src/PxgDestructionBody.cuh"
#include <cuda_runtime.h>
#include <algorithm>
#include <array>
#include <cstdio>
#include <cstdlib>
#include <limits>
#include <random>
#include <vector>
using namespace physx;
#define CHECK(x) do {if(!(x)){std::fprintf(stderr,"%s:%d: %s\n",__FILE__,__LINE__,#x);std::exit(1);}}while(0)
#define CUDA(x) CHECK((x)==cudaSuccess)
struct Input {PxDestructionClusterMassProperties mass;PxDestructionClusterMotion motion;};
struct Output {PxDestructionClusterBodyState body;unsigned error;};
__global__ void evaluate(const Input* in,Output* out,unsigned n) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n)out[i].error=destructionBody::prepare(in[i].mass,in[i].motion,out[i].body);
}
std::vector<Output> run(const std::vector<Input>& in) {
    Input* d;Output* result;CUDA(cudaMalloc(&d,in.size()*sizeof(Input)));CUDA(cudaMalloc(&result,in.size()*sizeof(Output)));
    CUDA(cudaMemcpy(d,in.data(),in.size()*sizeof(Input),cudaMemcpyHostToDevice));
    evaluate<<<(in.size()+127)/128,128>>>(d,result,unsigned(in.size()));CUDA(cudaGetLastError());
    std::vector<Output> out(in.size());CUDA(cudaMemcpy(out.data(),result,out.size()*sizeof(Output),cudaMemcpyDeviceToHost));
    CUDA(cudaFree(d));CUDA(cudaFree(result));return out;
}
using V=std::array<double,3>;using Q=std::array<double,4>;using M=std::array<V,3>;
M matrix(Q q) {
    const auto [x,y,z,w]=q;
    return {{{1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w)},
        {2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w)},
        {2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)}}};
}
V mv(M a,V x) {V out{};for(unsigned i=0;i<3;++i)for(unsigned j=0;j<3;++j)out[i]+=a[i][j]*x[j];return out;}
V cross(V a,V b) {return {a[1]*b[2]-a[2]*b[1],a[2]*b[0]-a[0]*b[2],a[0]*b[1]-a[1]*b[0]};}
Q quaternion(std::mt19937& rng) {
    std::normal_distribution<double> normal(0,1);Q q;double len=0;for(double& x:q){x=normal(rng);len+=x*x;}
    for(double& x:q)x/=sqrt(len);return q;
}
void analytic() {
    std::mt19937 rng(587);std::uniform_real_distribution<double> positive(.1,3),location(-10,10);
    std::vector<Input> in(4096);std::vector<V> expected(in.size());
    for(unsigned i=0;i<in.size();++i) {
        auto& input=in[i];auto& mass=input.mass;auto& motion=input.motion;
        const Q q=quaternion(rng),pose=quaternion(rng);const M a=matrix(q);
        const V size={positive(rng),positive(rng),positive(rng)};
        const double scale=pow(10.0,int(i%51)-25);mass.mass=positive(rng)*scale;mass.chunkCount=1;mass.supported=i%11==0;
        V diag={scale*(size[1]*size[1]+size[2]*size[2]),scale*(size[0]*size[0]+size[2]*size[2]),scale*(size[0]*size[0]+size[1]*size[1])};
        if(i%7==0)diag={scale,scale,scale}; // repeated eigenvalues
        expected[i]=diag;std::sort(expected[i].begin(),expected[i].end());
        M tensor{};for(unsigned j=0;j<3;++j)for(unsigned k=0;k<3;++k)for(unsigned p=0;p<3;++p)tensor[j][k]+=a[j][p]*diag[p]*a[k][p];
        const double packed[]={tensor[0][0],tensor[1][1],tensor[2][2],tensor[0][1],tensor[0][2],tensor[1][2]};
        std::copy(packed,packed+6,mass.inertia);
        for(unsigned k=0;k<3;++k){mass.center[k]=location(rng)+(i%19==0?1e6:0);motion.origin[k]=location(rng);motion.linearVelocity[k]=location(rng);motion.angularVelocity[k]=location(rng);}
        std::copy(pose.begin(),pose.end(),motion.orientation);
    }
    const auto out=run(in);double worstTensor=0,worstVelocity=0;
    for(unsigned i=0;i<in.size();++i) {
        const auto& o=out[i];const auto& mass=in[i].mass;const auto& motion=in[i].motion;
        if(o.error)std::fprintf(stderr,"input %u returned error %u\n",i,o.error);CHECK(!o.error);
        const auto& body=o.body;const auto* q=body.bodyToActorOrientation;const M a=matrix({q[0],q[1],q[2],q[3]});
        double norm=0;for(unsigned k=0;k<4;++k)norm+=q[k]*double(q[k]);CHECK(fabs(norm-1)<2e-7);
        M tensor{};for(unsigned j=0;j<3;++j)for(unsigned k=0;k<3;++k)for(unsigned p=0;p<3;++p)tensor[j][k]+=a[j][p]*body.principalInertia[p]*a[k][p];
        const double packed[]={tensor[0][0],tensor[1][1],tensor[2][2],tensor[0][1],tensor[0][2],tensor[1][2]};
        const double scale=expected[i][2];
        for(unsigned k=0;k<6;++k){const double error=fabs(packed[k]-mass.inertia[k])/scale;worstTensor=std::max(worstTensor,error);CHECK(error<2e-6);}
        for(unsigned k=0;k<3;++k) {
            CHECK(fabs(body.principalInertia[k]/expected[i][k]-1)<2e-6);
            CHECK(mass.supported?body.inverseInertia[k]==0:fabs(body.inverseInertia[k]*expected[i][k]-1)<2e-6);
        }
        CHECK(body.supported==mass.supported && fabs(body.mass/mass.mass-1)<1e-7);
        CHECK(mass.supported?body.inverseMass==0:fabs(body.inverseMass*mass.mass-1)<1e-7);
        const M pose=matrix({motion.orientation[0],motion.orientation[1],motion.orientation[2],motion.orientation[3]});
        const V rotated=mv(pose,{mass.center[0],mass.center[1],mass.center[2]});
        V world,point;for(unsigned k=0;k<3;++k){world[k]=motion.origin[k]+rotated[k];point[k]=world[k]+k+1;}
        const V exact=cross({motion.angularVelocity[0],motion.angularVelocity[1],motion.angularVelocity[2]},
            {point[0]-world[0],point[1]-world[1],point[2]-world[2]});
        const V stored=cross({body.angularVelocity[0],body.angularVelocity[1],body.angularVelocity[2]},
            {point[0]-body.bodyToWorldPosition[0],point[1]-body.bodyToWorldPosition[1],point[2]-body.bodyToWorldPosition[2]});
        for(unsigned k=0;k<3;++k) {
            CHECK(body.bodyToWorldPosition[k]==float(world[k]));
            const double error=fabs((body.linearVelocity[k]+stored[k])-(motion.linearVelocity[k]+exact[k]));
            worstVelocity=std::max(worstVelocity,error);CHECK(error<1e-5);
        }
        const auto* bq=body.bodyToWorldOrientation;const M worldFrame=matrix({bq[0],bq[1],bq[2],bq[3]});
        for(unsigned j=0;j<3;++j)for(unsigned k=0;k<3;++k) {
            double element=0;for(unsigned p=0;p<3;++p)element+=pose[j][p]*a[p][k];
            CHECK(fabs(element-worldFrame[j][k])<6e-7);
        }
    }
    // Deterministic principal frames for the exact same input batch.
    const auto repeat=run(in);for(unsigned i=0;i<in.size();++i)for(unsigned k=0;k<4;++k)
        CHECK(out[i].body.bodyToActorOrientation[k]==repeat[i].body.bodyToActorOrientation[k]);
    std::printf("4096 GPU body candidates: rotated/full tensors, repeated moments, 1e-25..1e25 scales, supported mass, COM velocity; tensor %.3g, point velocity %.3g\n",worstTensor,worstVelocity);
}
void roundedRotation() {
    Input in{};in.mass.mass=1;in.mass.inertia[0]=in.mass.inertia[1]=in.mass.inertia[2]=1;
    in.mass.center[0]=1e6;in.mass.center[1]=-.3e6;in.mass.center[2]=.4e6;
    in.motion.orientation[2]=.6*(1+1e-7);in.motion.orientation[3]=.8*(1+1e-7);
    in.motion.linearVelocity[0]=3;in.motion.linearVelocity[1]=4;in.motion.linearVelocity[2]=5;
    in.motion.angularVelocity[0]=1;in.motion.angularVelocity[1]=2;in.motion.angularVelocity[2]=3;
    const auto result=run({in})[0];CHECK(!result.error);
    // Float PhysX quaternion observations are only approximately unit length.
    // The velocity is referenced to the old COM, before frame normalization.
    const auto source=mv(matrix({0,0,in.motion.orientation[2],in.motion.orientation[3]}),{1e6,-.3e6,.4e6});
    const auto& b=result.body;const V r={b.bodyToWorldPosition[0]-source[0],b.bodyToWorldPosition[1]-source[1],b.bodyToWorldPosition[2]-source[2]};
    const auto delta=cross({1,2,3},r);
    for(unsigned k=0;k<3;++k)CHECK(fabs(b.linearVelocity[k]-in.motion.linearVelocity[k]-delta[k])<2e-6);
    std::puts("rounded GPU quaternion retains COM point velocity after body-frame normalization");
}
void failures() {
    Input base{};base.mass.mass=1;base.mass.inertia[0]=base.mass.inertia[1]=base.mass.inertia[2]=1;base.motion.orientation[3]=1;
    std::vector<Input> in(12,base);in[0].mass.mass=0;in[1].mass.mass=-1;
    in[2].mass.inertia[0]=-1;in[3].mass.inertia[0]=0;in[4].mass.inertia[3]=2;
    in[5].motion.orientation[3]=2;in[6].motion.origin[0]=std::numeric_limits<double>::infinity();
    in[7].mass.mass=1e-40;in[8].mass.inertia[0]=1e40;in[9].mass.inertia[0]=1e-40;
    in[10].mass.inertia[3]=std::numeric_limits<double>::quiet_NaN();in[11].mass.center[1]=std::numeric_limits<double>::quiet_NaN();
    const unsigned errors[]={1,1,2,2,2,4,4,8,8,8,2,4};const auto out=run(in);
    for(unsigned i=0;i<in.size();++i){if(out[i].error!=errors[i])std::fprintf(stderr,"invalid input %u: got %u expected %u\n",i,out[i].error,errors[i]);CHECK(out[i].error==errors[i]);}
    base.mass={};base.mass.supported=1;const auto anchor=run({base})[0];CHECK(!anchor.error && anchor.body.supported && !anchor.body.mass && !anchor.body.inverseMass);
    for(unsigned k=0;k<3;++k)CHECK(!anchor.body.principalInertia[k] && !anchor.body.inverseInertia[k]);
    std::puts("invalid/singular/nonfinite/unrepresentable body candidates explicitly rejected; massless authored support preserved");
}
int main(){analytic();roundedRotation();failures();}
