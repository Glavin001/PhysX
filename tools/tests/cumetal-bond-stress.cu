// Direct production packed-argument bond walk qualification. No solver clone.
#include <cuda_runtime.h>
#include "NvBlastExtStressGpu.h"
#include "NvBlastExtStressFormula.h"
#include "NvBlastExtStressMaterialFormula.h"
#include <algorithm>
#include <array>
#include <cmath>
#include <cstddef>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <limits>
#include <stdexcept>
#include <string>
#include <type_traits>
#include <vector>
#if !defined(PX_CUMETAL_PACK_BOND_STRESS_SCALARS) || !PX_CUMETAL_PACK_BOND_STRESS_SCALARS
#error "This component qualification requires the packed bond-stress argument ABI"
#endif
#define NVBLAST_STRESS_NORMALIZATION_EPSILON float(1e-20f)
namespace Nv { namespace Blast { namespace {
// Private POD adapters match the owning .cu's existing payload ABI. The actual
// bond walk, member ordering, material decisions and compaction are included.
struct alignas(16) Vec4 { float x,y,z,w; };
struct alignas(16) AngLin { Vec4 angular,linear; };
static_assert(sizeof(Vec4)==16 && alignof(Vec4)==16, "production Vec4 ABI");
static_assert(sizeof(AngLin)==32 && alignof(AngLin)==16 && offsetof(AngLin,linear)==16,
              "production AngLin ABI");
__host__ __device__ Vec4 mul(const Vec4& v,float scale) {
    return {v.x*scale,v.y*scale,v.z*scale,0.0f};
}
#include "StressMaterialKernels.cuh"
} } }
using namespace Nv::Blast;
namespace {
constexpr unsigned Groups=129, Capacity=131, Slots=3*Capacity, Nodes=2*Slots;
constexpr unsigned Guard=2, Snapshots=4;
constexpr float FloatGuard=-12345.25f;
constexpr std::uint32_t WordGuard=0xdeadbeefu;
void check(cudaError_t e) { if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e)); }
void require(bool b,const std::string& message) { if(!b)throw std::runtime_error(message); }
template<class T> struct Buffer {
    std::vector<T> initial;
    T* raw=nullptr;
    std::array<T*,Snapshots> snapshot{};
    Buffer(unsigned count,T guard,bool readback=false):initial(count+2*Guard,guard) {
        check(cudaMalloc(&raw,initial.size()*sizeof(T)));
        if(readback)for(auto& p:snapshot)check(cudaHostAlloc(&p,initial.size()*sizeof(T),cudaHostAllocDefault));
    }
    ~Buffer(){for(auto p:snapshot)if(p)cudaFreeHost(p);if(raw)cudaFree(raw);}
    Buffer(const Buffer&)=delete;Buffer& operator=(const Buffer&)=delete;
    T* data(){return raw+Guard;}
    T& host(unsigned i){return initial[Guard+i];}
    void upload(cudaStream_t stream){check(cudaMemcpyAsync(raw,initial.data(),initial.size()*sizeof(T),cudaMemcpyHostToDevice,stream));}
    void read(unsigned run,cudaStream_t stream){check(cudaMemcpyAsync(snapshot[run],raw,initial.size()*sizeof(T),cudaMemcpyDeviceToHost,stream));}
    void match(unsigned run,const std::vector<T>& expected,const char* name)const {
        require(expected.size()==initial.size(),"oracle size mismatch");
        for(unsigned i=0;i<expected.size();++i)
            require(!std::memcmp(snapshot[run]+i,expected.data()+i,sizeof(T)),
                    std::string(name)+" differs at slot "+std::to_string(i)+" replay "+std::to_string(run));
    }
};
struct Expected {
    std::vector<float> sn,ss,sb,normal,centroid;
    std::vector<std::uint32_t> removeCount,removeFlag,counters,removals;
    std::vector<std::uint8_t> mask;
    std::vector<std::uint32_t> offsets,overIds;
    std::vector<std::array<float,9>> records;
};
std::uint32_t bits(float v){std::uint32_t u;std::memcpy(&u,&v,4);return u;}
int run(){
    Buffer<std::uint32_t> begin(Capacity,WordGuard),size(Capacity,WordGuard),member(Slots,WordGuard),
        node0(Slots,WordGuard),node1(Slots,WordGuard),material(Slots,WordGuard),offset(Capacity,WordGuard);
    Buffer<float> normal(3*Slots,FloatGuard),centroid(3*Slots,FloatGuard),disp(3*Slots,FloatGuard),
        health(Slots,FloatGuard),scale(Capacity,FloatGuard),limits(12,FloatGuard);
    const AngLin impulseGuard{{FloatGuard,FloatGuard,FloatGuard,FloatGuard},{FloatGuard,FloatGuard,FloatGuard,FloatGuard}};
    Buffer<AngLin> impulses(Capacity,impulseGuard);
    Buffer<float> sn(Capacity,FloatGuard,true),ss(Capacity,FloatGuard,true),sb(Capacity,FloatGuard,true),
        outNormal(3*Capacity,FloatGuard,true),outCentroid(3*Capacity,FloatGuard,true),records(9*Capacity,FloatGuard,true);
    Buffer<std::uint32_t> removeCount(Capacity,WordGuard,true),removeFlag(Slots,WordGuard,true),
        counters(4,WordGuard,true),overIds(Capacity,WordGuard,true),removals(Slots,WordGuard,true);
    Buffer<std::uint8_t> mask(Nodes,0xa5u,true);
    for(unsigned i=0;i<Nodes;++i)mask.host(i)=0;
    for(unsigned i=0;i<4;++i)counters.host(i)=0;
    // Every flag is stale before each walk, including the unvisited tail after
    // an unbreakable member. Guards outside the slot payload remain distinct.
    for(unsigned i=0;i<Slots;++i)removeFlag.host(i)=9;
    const float table[12]={8,4,8, 8,std::nextafter(4.0f,0.0f),8,
        8,std::nextafter(4.0f,std::numeric_limits<float>::infinity()),8, 8,.5f,8};
    for(unsigned i=0;i<12;++i)limits.host(i)=table[i];
    for(unsigned g=0;g<Capacity;++g){
        const unsigned kind=g%11;begin.host(g)=3*g;size.host(g)=kind==10?0:3;scale.host(g)=1;
        impulses.host(g)={{0,0,0,0},{2,0,0,0}};
        if(kind==3)impulses.host(g).linear.x=-2;
        if(kind==4)impulses.host(g).linear={0,2,0,0};
        if(kind==5)impulses.host(g)={{0,1,0,0},{-1,0,0,0}};
        if(kind==6)impulses.host(g).linear={-0.0f,-0.0f,-0.0f,0};
        const unsigned permutation[3]={2,0,1};
        for(unsigned k=0;k<3;++k){
            const unsigned bb=3*g+permutation[k];member.host(3*g+k)=bb;
            node0.host(bb)=2*bb;node1.host(bb)=2*bb+1;
            material.host(bb)=kind==1?1:kind==2?2:kind==5?3:99;
            health.host(bb)=k==0?1.0f:k==1?0.0f:-0.0f;
            for(unsigned j=0;j<3;++j){normal.host(3*bb+j)=j==0?1.0f:0.0f;
                centroid.host(3*bb+j)=j==0?2.0f:j==1?4.0f:8.0f;
                disp.host(3*bb+j)=j==0?1.0f:0.0f;}
            if(kind==6 && k==0)node0.host(bb)=0xffffffffu;
            if(kind==7){health.host(bb)=k<2?.5f:0.0f;if(k==1){centroid.host(3*bb)=6;material.host(bb)=3;}}
            if(kind==8){health.host(bb)=k==1?16.0f:k==0?0.0f:-1.0f;
                if(k==1){normal.host(3*bb)=0;normal.host(3*bb+1)=1;centroid.host(3*bb)=6;}}
            if(kind==9)health.host(bb)=k==0?0.0f:k==1?-0.0f:-1.0f;
        }
    }
    std::array<BondStressWalkConfig,Snapshots> configs{{
        {8,1,2,.5f,4,16,0,0xfedcba98u},
        {8,1,2,.5f,4,16,Groups,0xfedcba98u},
        {8,0,1,1,4,16,Groups,0xfedcba98u},
        {0,0,2,.5f,2,16,Groups,0xfedcba98u}}};
    std::array<Expected,Snapshots> expected;
    for(unsigned r=0;r<Snapshots;++r){
        auto& e=expected[r];const auto& config=configs[r];
        e.sn=sn.initial;e.ss=ss.initial;e.sb=sb.initial;e.normal=outNormal.initial;e.centroid=outCentroid.initial;
        e.removeCount=removeCount.initial;e.removeFlag=removeFlag.initial;e.mask=mask.initial;
        e.counters=counters.initial;e.removals=removals.initial;e.offsets=offset.initial;
        unsigned removalIndex=0;float maxUtil=0;
        for(unsigned g=0;g<config.groupCount;++g){
            const unsigned kind=g%11;unsigned removed=0;e.offsets[Guard+g]=removalIndex;
            for(unsigned k=0;k<size.host(g);++k){
                const bool remove=kind==8?k==0:kind==9?true:kind==7?k==2:k!=0;
                e.removeFlag[Guard+3*g+k]=remove?1u:0u;
                if(remove){++removed;e.removals[Guard+removalIndex++]=member.host(3*g+k);}
            }
            e.removeCount[Guard+g]=removed;
            if(kind==9 || kind==10)continue;
            const ExtStressVec3 n=kind==8?ExtStressVec3{0,1,0}:ExtStressVec3{1,0,0};
            const float cx=kind==8?6.0f:kind==7?4.0f:2.0f;
            float normalStress=0,shearStress=0,bendStress=0;
            if(kind!=8){
                const auto im=impulses.host(g);
                const auto l=mul(im.linear,config.bsLinearScale*scale.host(g));
                const auto a=mul(im.angular,config.bsAngularScale*scale.host(g));
                // Known authored aggregate area1, displacement length1 and
                // unit axis normal: no duplicate production stress equation.
                extStressCalcBondStress({l.x,l.y,l.z},{a.x,a.y,a.z},n,1,1,config.bendGainMax,
                                       normalStress,shearStress,bendStress);
            }
            e.sn[Guard+g]=normalStress;e.ss[Guard+g]=shearStress;e.sb[Guard+g]=bendStress;
            const std::array<float,9> row{{normalStress,shearStress,bendStress,n.x,n.y,n.z,cx,4,8}};
            for(unsigned j=0;j<3;++j){e.normal[Guard+3*g+j]=row[3+j];e.centroid[Guard+3*g+j]=row[6+j];}
            float compression,tension;extStressFibre(config.fibreBending!=0,normalStress,bendStress,compression,tension);
            unsigned over=0;
            for(unsigned k=0;k<size.host(g);++k){
                const unsigned bb=member.host(3*g+k);
                if(!(health.host(bb)>0) || node0.host(bb)==0xffffffffu)continue;
                const unsigned raw=material.host(bb),m=raw<config.materialCount?raw:0;
                const float ce=table[3*m],te=table[3*m+1],se=table[3*m+2];
                if(compression>ce || tension>te || shearStress>se){++over;e.mask[Guard+node0.host(bb)]=1;e.mask[Guard+node1.host(bb)]=1;}
                float utilization=0;
                for(float ratio:{compression/ce,tension/te,shearStress/se})if(utilization<ratio)utilization=ratio;
                if(maxUtil<utilization)maxUtil=utilization;
                if(utilization>=.5f)++e.counters[Guard+3];
            }
            e.counters[Guard]+=over;
            if(over){e.overIds.push_back(g);e.records.push_back(row);}
        }
        e.counters[Guard+1]=static_cast<unsigned>(e.overIds.size());e.counters[Guard+2]=bits(maxUtil);
        // Independent analytic anchors for the first nonzero config, including
        // the strict threshold and exact half-utilization boundaries.
        if(r==1){require(e.sn[Guard]==4 && e.ss[Guard]==0 && e.sb[Guard]==0,"analytic axial oracle");
            require(e.sn[Guard+3]==-4 && e.ss[Guard+4]==4,"analytic compression/shear oracle");
            require(e.sn[Guard+5]==-2 && e.sb[Guard+5]==3,"analytic capped bending oracle");}
    }
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    std::array<cudaGraph_t,Snapshots> graphs{};std::array<cudaGraphExec_t,Snapshots> executable{};
    for(unsigned r=0;r<Snapshots;++r){
        auto config=configs[r];const unsigned grid=std::max(1u,(config.groupCount+127)/128);
        check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
        bondStressWalk<<<grid,128,0,stream>>>(config,begin.data(),size.data(),member.data(),node0.data(),node1.data(),material.data(),
            normal.data(),centroid.data(),disp.data(),health.data(),impulses.data(),scale.data(),limits.data(),
            sn.data(),ss.data(),sb.data(),outNormal.data(),outCentroid.data(),mask.data(),removeCount.data(),removeFlag.data(),
            counters.data(),overIds.data(),records.data(),counters.data()+1,counters.data()+2,counters.data()+3);
        bondStressCompactRemovals<<<grid,128,0,stream>>>(begin.data(),size.data(),member.data(),removeFlag.data(),offset.data(),config.groupCount,removals.data());
        check(cudaStreamEndCapture(stream,&graphs[r]));check(cudaGraphInstantiate(&executable[r],graphs[r],0));
        // Captured by-value parameters must survive mutation of their source.
        std::memset(&config,0xa7,sizeof(config));
    }
    begin.upload(stream);size.upload(stream);member.upload(stream);node0.upload(stream);node1.upload(stream);material.upload(stream);
    normal.upload(stream);centroid.upload(stream);disp.upload(stream);health.upload(stream);impulses.upload(stream);scale.upload(stream);limits.upload(stream);
    for(unsigned r=0;r<Snapshots;++r){
        check(cudaMemcpyAsync(offset.raw,expected[r].offsets.data(),offset.initial.size()*sizeof(std::uint32_t),cudaMemcpyHostToDevice,stream));
        sn.upload(stream);ss.upload(stream);sb.upload(stream);outNormal.upload(stream);outCentroid.upload(stream);records.upload(stream);
        removeCount.upload(stream);removeFlag.upload(stream);counters.upload(stream);overIds.upload(stream);removals.upload(stream);mask.upload(stream);
        check(cudaGraphLaunch(executable[r],stream));
        sn.read(r,stream);ss.read(r,stream);sb.read(r,stream);outNormal.read(r,stream);outCentroid.read(r,stream);records.read(r,stream);
        removeCount.read(r,stream);removeFlag.read(r,stream);counters.read(r,stream);overIds.read(r,stream);removals.read(r,stream);mask.read(r,stream);
    }
    check(cudaStreamSynchronize(stream));
    for(unsigned r=0;r<Snapshots;++r){
        const auto& e=expected[r];sn.match(r,e.sn,"normal stress");ss.match(r,e.ss,"shear stress");sb.match(r,e.sb,"bend stress");
        outNormal.match(r,e.normal,"normal vector");outCentroid.match(r,e.centroid,"centroid");mask.match(r,e.mask,"node mask");
        removeCount.match(r,e.removeCount,"removal counts");removeFlag.match(r,e.removeFlag,"removal flags");
        removals.match(r,e.removals,"ordered removals");counters.match(r,e.counters,"summary counters");
        auto expectedIds=overIds.initial;auto expectedRecords=records.initial;std::vector<bool> seen(Capacity,false);
        for(unsigned slot=0;slot<e.overIds.size();++slot){
            const unsigned g=overIds.snapshot[r][Guard+slot];
            require(g<configs[r].groupCount && !seen[g],"invalid/duplicate compact group");seen[g]=true;
            const auto it=std::find(e.overIds.begin(),e.overIds.end(),g);require(it!=e.overIds.end(),"unexpected compact group");
            expectedIds[Guard+slot]=g;const auto index=static_cast<unsigned>(it-e.overIds.begin());
            for(unsigned j=0;j<9;++j)expectedRecords[Guard+9*slot+j]=e.records[index][j];
        }
        overIds.match(r,expectedIds,"compact IDs/guards");records.match(r,expectedRecords,"compact records/guards");
        check(cudaGraphExecDestroy(executable[r]));check(cudaGraphDestroy(graphs[r]));
    }
    check(cudaStreamDestroy(stream));
    std::puts("PASS packed production bondStressWalk: zero + 3 queued snapshots, exact values/flags/removals/guards");
    return 0;
}
}
int main(){try{return run();}catch(const std::exception& e){std::fprintf(stderr,"bond stress qualification failed: %s\n",e.what());return 1;}}
