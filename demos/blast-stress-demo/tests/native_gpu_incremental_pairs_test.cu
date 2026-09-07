// Production broad-phase kernels versus brute-force geometric transitions.
#include <cuda_runtime.h>
#include "PxgBroadPhaseDesc.h"
#include "PxgIntegerAABB.h"
#include "PxgBroadPhasePairReport.h"
#include <algorithm>
#include <cstdio>
#include <numeric>
#include <random>
#include <set>
#include <stdexcept>
#include <vector>
using namespace physx;
extern "C" __global__ void computeIncrementalComparisonHistograms_Stage1(const PxgBroadPhaseDesc*);
extern "C" __global__ void computeIncrementalComparisonHistograms_Stage2(PxgBroadPhaseDesc*);
extern "C" __global__ void performIncrementalSAP(PxgBroadPhaseDesc*);
namespace {
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
struct Device {
    std::vector<void*> allocations;
    ~Device(){for(auto p:allocations)cudaFree(p);}
    template<class T>T* upload(const std::vector<T>& v){
        T* p=nullptr;check(cudaMalloc(&p,v.size()*sizeof(T)));allocations.push_back(p);
        check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));return p;
    }
    template<class T>T* zeros(size_t n){return upload(std::vector<T>(n));}
};
using Pair=std::pair<unsigned,unsigned>;
bool overlaps(const PxgIntegerAABB& a,const PxgIntegerAABB& b){
    for(unsigned axis=0;axis<3;++axis)
        if(a.mMinMax[axis]>b.mMinMax[axis+3]||b.mMinMax[axis]>a.mMinMax[axis+3])return false;
    return true;
}
struct Result {unsigned long long before=0,after=0;};
Result run(unsigned n,unsigned seed,unsigned mode,bool refilter){
    std::mt19937 rng(seed);Device memory;PxgBroadPhaseDesc h{};
    std::vector<PxgIntegerAABB> bounds[2];bounds[0].resize(n);bounds[1].resize(n);
    std::vector<PxU32> groups(n);std::vector<PxNodeIndex> owners(n);std::vector<PxU64> generations(n);
    for(unsigned i=0;i<n;++i){
        groups[i]=((i+1)<<3)|2;owners[i]=PxNodeIndex(PxU32(i));
        generations[i]=refilter&&(mode==4||i%3==0)?7:0;
        for(unsigned axis=0;axis<3;++axis){
            const unsigned start=200+(rng()%32)*2;
            bounds[0][i].mMinMax[axis]=start;
            bounds[0][i].mMinMax[axis+3]=start+9;
        }
        bounds[1][i]=bounds[0][i];
        // One moving object, sparse movement, all moving, one moving endpoint,
        // and tied aligned geometry exercise both crossing directions.
        if(mode!=0||i==0)for(unsigned axis=0;axis<3;++axis){
            if(mode==1&&i%7)continue;
            const int delta=(int(rng()%31)-15)*2;
            if(mode==3){
                if(i&1)bounds[1][i].mMinMax[axis+3]+=unsigned(rng()%24)*2;
                else bounds[1][i].mMinMax[axis]-=unsigned(rng()%24)*2;
            }else{
                bounds[1][i].mMinMax[axis]+=delta;
                bounds[1][i].mMinMax[axis+3]+=delta;
            }
        }
    }
    h.oldIntegerBounds=memory.upload(bounds[0]);h.newIntegerBounds=memory.upload(bounds[1]);
    h.numPreviousHandles=n;h.updateData_groups=memory.upload(groups);
    h.rigidOwners=memory.upload(owners);h.rigidOwnerCapacity=n;
    h.nativeOwnership={memory.upload(generations),refilter?PxU64(7):PxU64(0),n};
    h.max_found_lost_pairs=n*n*6;
    h.foundPairReport=memory.zeros<PxgBroadPhasePair>(h.max_found_lost_pairs);
    h.lostPairReport=memory.zeros<PxgBroadPhasePair>(h.max_found_lost_pairs);
    Result result;
    for(unsigned axis=0;axis<3;++axis){
        std::vector<unsigned> order[2];order[0].resize(2*n);std::iota(order[0].begin(),order[0].end(),0);
        auto coordinate=[&](unsigned when,unsigned endpoint){return bounds[when][endpoint/2].mMinMax[axis+(endpoint%2)*3];};
        std::stable_sort(order[0].begin(),order[0].end(),[&](unsigned a,unsigned b){return coordinate(0,a)<coordinate(0,b);});
        order[1]=order[0];std::stable_sort(order[1].begin(),order[1].end(),[&](unsigned a,unsigned b){return coordinate(1,a)<coordinate(1,b);});
        std::vector<unsigned> oldRank(2*n),ranks(2*n),handles(2*n);
        std::vector<unsigned> starts[2],ends[2];
        for(unsigned i=0;i<2*n;++i)oldRank[order[0][i]]=i;
        for(unsigned when=0;when<2;++when){
            const unsigned slot=1-when;std::vector<unsigned> startIDs,endIDs;
            starts[slot].resize(2*n);ends[slot].resize(2*n);
            for(unsigned i=0;i<2*n;++i){
                const unsigned endpoint=order[when][i];
                starts[slot][i]=unsigned(startIDs.size());ends[slot][i]=unsigned(endIDs.size());
                ((endpoint&1)?endIDs:startIDs).push_back(endpoint/2);
            }
            h.startPtHistogram[slot][axis]=memory.upload(starts[slot]);h.endPtHistogram[slot][axis]=memory.upload(ends[slot]);
            h.startPointHandles[slot][axis]=memory.upload(startIDs);h.endPointHandles[slot][axis]=memory.upload(endIDs);
        }
        for(unsigned i=0;i<2*n;++i){
            const unsigned endpoint=order[1][i];ranks[i]=oldRank[endpoint];
            handles[i]=createHandle(endpoint/2,!(endpoint&1),false);
            const bool down=i<=ranks[i];const unsigned begin=down?i:ranks[i]+1,end=down?ranks[i]:i;
            const auto& prefix=(endpoint&1)?starts[down]:ends[down];
            result.before+=prefix[end]-prefix[begin];
        }
        h.boxHandles[0][axis]=memory.upload(handles);h.boxProjectionRanks[axis]=memory.upload(ranks);
        h.incrementalComparisons[axis]=memory.zeros<PxU32>(2*n);
        h.incrementalBlockComparisons[axis]=memory.zeros<PxU32>(32);
    }
    auto d=memory.upload(std::vector<PxgBroadPhaseDesc>{h});
    computeIncrementalComparisonHistograms_Stage1<<<32,256>>>(d);
    computeIncrementalComparisonHistograms_Stage2<<<32,256>>>(d);
    performIncrementalSAP<<<dim3(256,3),256>>>(d);
    check(cudaGetLastError());PxgBroadPhaseDesc out;
    check(cudaMemcpy(&out,d,sizeof(out),cudaMemcpyDeviceToHost));
    for(unsigned axis=0;axis<3;++axis)result.after+=out.totalIncrementalComparisons[axis];
    for(unsigned lost=0;lost<2;++lost){
        const unsigned count=lost?out.sharedLostPairIndex:out.sharedFoundPairIndex;
        require(count<=h.max_found_lost_pairs,"pair overflow");
        std::vector<PxgBroadPhasePair> reports(count);
        if(count)check(cudaMemcpy(reports.data(),lost?h.lostPairReport:h.foundPairReport,count*sizeof(reports[0]),cudaMemcpyDeviceToHost));
        std::set<Pair> actual,expected;
        for(auto p:reports)actual.emplace(p.mVolA,p.mVolB);
        for(unsigned a=0;a<n;++a)for(unsigned b=a+1;b<n;++b){
            if(generations[a]||generations[b])continue; // owned by insertion/refilter pass
            const bool old=overlaps(bounds[0][a],bounds[0][b]),now=overlaps(bounds[1][a],bounds[1][b]);
            if(lost?(old&&!now):(!old&&now))expected.emplace(a,b);
        }
        if(actual!=expected){
            std::fprintf(stderr,"seed=%u n=%u mode=%u refilter=%d lost=%u actual=%zu expected=%zu\n",seed,n,mode,refilter,lost,actual.size(),expected.size());
            throw std::runtime_error("GPU transitions differ from brute-force geometry");
        }
    }
    require(result.after<=result.before,"comparison work grew");
    if(refilter&&mode==4)require(result.after==0,"refilter-only batch still schedules incremental comparisons");
    return result;
}
}
int main(){
    try{
        unsigned cases=0;Result totals;
        for(unsigned n:{2u,17u,129u,257u})for(unsigned mode=0;mode<5;++mode)for(bool refilter:{false,true})for(unsigned seed:{51u,97u,123u}){
            const auto r=run(n,seed,mode,refilter);totals.before+=r.before;totals.after+=r.after;++cases;
        }
        std::printf("PASS %u production GPU transition cases; comparisons %llu -> %llu; exact brute-force found/lost sets\n",cases,totals.before,totals.after);return 0;
    }catch(const std::exception& e){std::fprintf(stderr,"FAIL %s\n",e.what());return 1;}
}
