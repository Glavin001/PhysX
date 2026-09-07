// Exercise the production producer kernels against an independent CPU oracle.
#include <cuda_runtime.h>
#include "PxgNativePairCanonicalization.cuh"
#include <algorithm>
#include <cstdio>
#include <random>
#include <stdexcept>
#include <vector>
using namespace physx;
namespace {
void check(cudaError_t e) { if(e!=cudaSuccess) throw std::runtime_error(cudaGetErrorString(e)); }
void require(bool ok,const char* why) { if(!ok) throw std::runtime_error(why); }
struct Fixture {
    static constexpr PxU32 capacity=1048577;
    PxgBroadPhaseDesc h{},*d=nullptr;
    PxgBroadPhasePair* buffers[4]{};
    Fixture() {
        for(auto& p:buffers)check(cudaMalloc(&p,capacity*sizeof(*p)));
        check(cudaMalloc(&d,sizeof(*d)));
        check(cudaMalloc(&h.nativePairTileOffsets,2*((capacity+1023)/1024)*sizeof(PxU32)));
        h.max_found_lost_pairs=capacity;
        h.foundActorPairReport=buffers[0];h.lostActorPairReport=buffers[1];
        h.foundPairReport=buffers[2];h.lostPairReport=buffers[3];
    }
    ~Fixture() {for(auto p:buffers)cudaFree(p);cudaFree(d);cudaFree(h.nativePairTileOffsets);}
    void run(std::vector<PxgBroadPhasePair> found,std::vector<PxgBroadPhasePair> lost,
             bool overflow=false,bool invalid=false) {
        h.sharedFoundPairIndex=overflow?capacity+1:PxU32(found.size());
        h.sharedLostPairIndex=PxU32(lost.size());
        h.sharedFoundAggPairIndex=h.sharedLostAggPairIndex=0;
        h.nativePairError=0;h.nativePairCounts[0]=h.nativePairCounts[1]=0xdeadbeef;
        h.nativePairReports[0]=h.nativePairReports[1]=nullptr;
        if(found.size())check(cudaMemcpy(buffers[0],found.data(),found.size()*sizeof(found[0]),cudaMemcpyHostToDevice));
        if(lost.size())check(cudaMemcpy(buffers[1],lost.data(),lost.size()*sizeof(lost[0]),cudaMemcpyHostToDevice));
        check(cudaMemcpy(d,&h,sizeof(h),cudaMemcpyHostToDevice));
        const dim3 grid(128,2);
        nativePairSortTiles<<<grid,128>>>(d);
        for(PxU32 width=1024;width<capacity;width*=2)nativePairMerge<<<grid,128>>>(d,width);
        nativePairUniqueCounts<<<grid,128>>>(d);
        nativePairUniquePrefix<<<dim3(1,2),128>>>(d);
        nativePairUniqueScatter<<<grid,128>>>(d);
        check(cudaGetLastError());PxgBroadPhaseDesc result;
        check(cudaMemcpy(&result,d,sizeof(result),cudaMemcpyDeviceToHost));
        if(overflow||invalid) {
            require(result.nativePairError!=0,"invalid input accepted");
            require(!result.nativePairCounts[0]&&!result.nativePairCounts[1],"failed batch published pairs");
            return;
        }
        require(result.nativePairError==0,"valid input rejected");
        for(PxU32 axis=0;axis<2;++axis) {
            auto expected=axis?lost:found;
            std::sort(expected.begin(),expected.end(),[](const PxgBroadPhasePair& a,const PxgBroadPhasePair& b){
                return a.mVolA>b.mVolA||(a.mVolA==b.mVolA&&a.mVolB>b.mVolB);});
            expected.erase(std::unique(expected.begin(),expected.end(),[](const PxgBroadPhasePair& a,const PxgBroadPhasePair& b){
                return a.mVolA==b.mVolA&&a.mVolB==b.mVolB;}),expected.end());
            require(expected.size()==result.nativePairCounts[axis],"wrong unique count");
            std::vector<PxgBroadPhasePair> actual(expected.size());
            if(actual.size())check(cudaMemcpy(actual.data(),result.nativePairReports[axis],actual.size()*sizeof(actual[0]),cudaMemcpyDeviceToHost));
            for(size_t i=0;i<actual.size();++i)require(actual[i].mVolA==expected[i].mVolA&&actual[i].mVolB==expected[i].mVolB,"pair order/content mismatch");
        }
    }
};
std::vector<PxgBroadPhasePair> make(PxU32 n,PxU32 seed,PxU32 mode) {
    std::mt19937 rng(seed);std::vector<PxgBroadPhasePair> v;v.reserve(n);
    for(PxU32 i=0;i<n;++i) {
        PxU32 a=rng()%20000,b=20001+rng()%20000;
        if(mode==1){a=0;b=1;} // Every tile and merge boundary has duplicate keys.
        if(mode==2){a=i;b=0xfffffffeu-i;}
        if(mode==3){a=rng()%5;b=6+rng()%5;}
        v.emplace_back(a,b);
    }
    std::shuffle(v.begin(),v.end(),rng);return v;
}
}
int main() {
    try {
        cudaDeviceProp p;check(cudaGetDeviceProperties(&p,0));
        require(p.major==8&&p.minor==9,"requires sm_89");
        Fixture f;unsigned cases=0;
        for(PxU32 n:{0u,1u,2u,1023u,1024u,1025u,2049u,4096u,16385u,131073u,1048577u,3u,0u})
            for(PxU32 mode=0;mode<4;++mode){f.run(make(n,71+n,mode),make(n/3,91+n,(mode+1)%4));++cases;}
        f.run({},make(1025,8,0),true);++cases;
        auto invalid=make(3,9,0);invalid[1].mVolA=invalid[1].mVolB;
        f.run(invalid,make(10,8,0),false,true);++cases;
        f.run(make(2049,7,0),{});++cases;
        std::printf("PASS %u production GPU pair batches: exact descending sort/unique, capacity boundaries, reuse and rejection\n",cases);
        return 0;
    }catch(const std::exception& e){std::fprintf(stderr,"FAIL %s\n",e.what());return 1;}
}
