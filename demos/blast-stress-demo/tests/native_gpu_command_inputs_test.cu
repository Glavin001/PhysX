// Sparse native pre-addition capture, including irreversible float rounding.
#include "PxgDestructionRuntime.h"
#include "PxgBodySim.h"
#include "PxsRigidBody.h"
#include <cuda_runtime.h>
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vector>
#include <limits>
#include <fstream>
namespace physx { namespace {
#include "PxgDestructionCommandInputs.cuh"
}}
using namespace physx;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void require(bool v,const char* message){if(!v)throw std::runtime_error(message);}
float bits(PxU32 id){float v;std::memcpy(&v,&id,4);return v;}
template<class T>struct Buffer {
    T* p{};size_t n;
    Buffer(size_t count):n(count){check(cudaMalloc(&p,n*sizeof(T)));}
    ~Buffer(){cudaFree(p);}
    void set(const std::vector<T>& v){require(v.size()==n,"upload size");check(cudaMemcpy(p,v.data(),n*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(){std::vector<T> v(n);check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
int main(int argc,char**argv){try{
    const PxU32 n=argc>1?113664:257,capacity=2*n+1;
    Buffer<PxgBodySim> bodies(capacity);Buffer<PxgBodySimVelocityUpdate> updates(n);
    Buffer<PxU64> loaded(capacity);loaded.set(std::vector<PxU64>(capacity,0));
    Buffer<PxgDestructionCommandInput> records(n);Buffer<PxgDestructionCommandInputStatus> status(1);
    std::vector<PxgBodySim> bs(capacity);std::vector<PxgBodySimVelocityUpdate> us(n);
    for(PxU32 i=0;i<capacity;++i){bs[i].linearVelocityXYZ_inverseMassW={1.25f,2,3,.5f};bs[i].angularVelocityXYZ_maxPenBiasW={4,5,6,0};bs[i].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=bits(i);}
    for(PxU32 i=0;i<n;++i){us[i].linearVelocityXYZ_bodySimIndexW.w=bits(2*i+1);us[i].externalLinearAccelerationXYZ={1e8f,.25f,-.5f,bits(PxsRigidBody::eHOST_VELOCITY_DELTA_GPU)};us[i].externalAngularAccelerationXYZ={7,8,9,0};}
    bodies.set(bs);updates.set(us);
    auto run=[&](PxU32 count,PxU64 generation){beginCommandInputs<<<1,1>>>(status.p,generation,count);if(count)captureCommandInputsKernel<<<(count+127)/128,128>>>(bodies.p,capacity,updates.p,count,records.p,status.p,loaded.p);check(cudaGetLastError());check(cudaDeviceSynchronize());return status.get()[0];};
    auto s=run(n,7);require(!s.error && s.count==n && s.generation==7,"capture receipt");auto rs=records.get();
    for(PxU32 i=0;i<n;++i){const auto& r=rs[i];require(r.body==2*i+1 && r.kind==1 && r.linearBefore[0]==1.25f && r.linearDelta[0]==1e8f && r.angularBefore[2]==6 && r.angularDelta[2]==9,"capture values");}
    const auto epochs=loaded.get();for(PxU32 i=0;i<capacity;++i)require(epochs[i]==(i%2?7u:0u),"loaded generation touched wrong native slot");
    float summed=float(1.25f+us[0].externalLinearAccelerationXYZ.x);
    require(summed-us[0].externalLinearAccelerationXYZ.x!=rs[0].linearBefore[0],"fixture did not expose irreversible rounded addition");
    auto after=bodies.get();require(!std::memcmp(after.data(),bs.data(),bs.size()*sizeof(bs[0])),"capture mutated bodies");
    if(argc>2){std::ofstream out(argv[2],std::ios::binary);out.write(reinterpret_cast<const char*>(rs.data()),rs.size()*sizeof(rs[0]));require(bool(out),"capture output");}
    if(argc==1){
        us[0].externalLinearAccelerationXYZ={0,0,0,bits(PxsRigidBody::eHOST_VELOCITY_DELTA_GPU)};
        us[0].externalAngularAccelerationXYZ={0,0,0,0};updates.set(us);
        s=run(n,8);require(!s.error && loaded.get()[1]==7 && loaded.get()[3]==8,"zero command marked a new loaded generation");
        us[0].externalLinearAccelerationXYZ.w=bits(0);us[0].linearVelocityXYZ_bodySimIndexW.w=bits(PX_INVALID_U32);updates.set(us);
        s=run(n,8);require(!s.error && records.get()[0].kind==0,"non-command upload inspected invalid source");
        us[0].externalLinearAccelerationXYZ.w=bits(PxsRigidBody::eHOST_VELOCITY_DELTA_GPU);updates.set(us);s=run(n,9);require((s.error&1)&&records.get()[0].kind==2,"out of bounds accepted");
        us[0].linearVelocityXYZ_bodySimIndexW.w=bits(1);updates.set(us);bs[1].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=bits(2);bodies.set(bs);s=run(n,10);require(s.error&2,"native identity mismatch accepted");
        bs[1].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=bits(1);bs[1].angularVelocityXYZ_maxPenBiasW.x=std::numeric_limits<float>::quiet_NaN();bodies.set(bs);s=run(n,11);require(s.error&4,"nonfinite baseline accepted");
        s=run(0,12);require(!s.error&&!s.count&&s.generation==12,"empty next generation retained old commands");
        for(auto epoch:loaded.get())require(epoch!=12,"empty generation retained a current loaded source");
    }
    std::printf("command inputs: %u sparse uploads, %u body slots; exact pre-addition values and capture nonmutation passed\n",n,capacity);return 0;
}catch(const std::exception&e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
