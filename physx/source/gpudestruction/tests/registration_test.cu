// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "../src/PxgDestructionRegistration.cuh"
#include <algorithm>
#include <cstdio>
#include <random>
#include <stdexcept>
#include <vector>
using namespace physx;
using Handle=PxgDestructionRegistrationHandle;
using Entry=PxgDestructionRegistrationEntry;
using State=PxgDestructionRegistrationState;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
bool same(Handle a,Handle b){return a.slot==b.slot && a.generation==b.generation;}
template<class T> struct Device {
    T* p=nullptr;
    explicit Device(size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
    ~Device(){cudaFree(p);}
    Device(const Device&)=delete;
    void put(const std::vector<T>& v){if(!v.empty())check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));}
    std::vector<T> get(size_t n)const{std::vector<T> v(n);if(n)check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
struct Access {
    const Handle* releases; Handle* assigned;
    __device__ Handle release(PxU32 i)const{return releases[i];}
    __device__ void assign(PxU32 i,Handle h)const{assigned[i]=h;}
};
// Independent sequential model: remove a tail slice, then grow one page at a
// time. Ordering is a batch contract, not a fixture-specific contact sort.
struct Reference {
    PxU32 page;
    std::vector<Entry> entries;
    std::vector<PxU32> free;
    std::vector<Handle> transact(const std::vector<Handle>& releases,PxU32 count){
        for(auto h:releases){
            require(h.slot<entries.size() && entries[h.slot].live && entries[h.slot].generation==h.generation,"invalid reference release");
            entries[h.slot].live=0;free.push_back(h.slot);
        }
        std::vector<PxU32> slots;
        const size_t take=std::min(size_t(count),free.size());
        slots.insert(slots.end(),free.end()-take,free.end());free.resize(free.size()-take);
        while(slots.size()<count){
            const PxU32 base=PxU32(entries.size());entries.resize(base+page);
            const PxU32 used=std::min(page,count-PxU32(slots.size()));
            for(PxU32 i=0;i<used;++i)slots.push_back(base+i);
            for(PxU32 i=page;i>used;--i)free.push_back(base+i-1);
        }
        std::vector<Handle> result;
        for(auto slot:slots){auto& e=entries[slot];e.live=1;++e.generation;result.push_back({slot,e.generation});}
        return result;
    }
};
struct Arena {
    PxU32 capacity,page;int residency=0;
    Device<Entry> entries;
    Device<PxU32> free;
    Device<State> state{1};
    Device<PxgDestructionRegistrationBatch> batch{1};
    Arena(PxU32 c,PxU32 p):capacity(c),page(p),entries(c),free(c){
        state.put({{}});check(destructionRegistration::residentBlocks<Access>(residency));
    }
    PxgDestructionRegistrationView view(){return {entries.p,free.p,state.p,batch.p,capacity,page};}
    std::vector<Handle> transact(const std::vector<Handle>& releases,PxU32 count,bool alias=false){
        Device<Handle> input(std::max(releases.size(),size_t(count))),output(count);
        std::vector<Handle> initial(std::max(releases.size(),size_t(count)),{0xdeadbeef,0xcafef00d});
        std::copy(releases.begin(),releases.end(),initial.begin());input.put(initial);
        output.put(std::vector<Handle>(count,{0xdeadbeef,0xcafef00d}));
        check(destructionRegistration::launch(view(),Access{input.p,alias?input.p:output.p},PxU32(releases.size()),count,residency,nullptr));
        check(cudaDeviceSynchronize());
        return alias?input.get(count):output.get(count);
    }
    void compare(const Reference& r){
        const auto s=state.get(1)[0];require(!s.error,"unexpected registration failure");
        require(s.allocated==r.entries.size() && s.freeCount==r.free.size() && s.liveCount==r.entries.size()-r.free.size(),"registration counts disagree");
        const auto actual=entries.get(s.allocated);
        for(size_t i=0;i<actual.size();++i)
            require(actual[i].generation==r.entries[i].generation && actual[i].live==r.entries[i].live,"live/generation state disagrees");
        require(free.get(s.freeCount)==r.free,"free slot order disagrees");
    }
};
void compareHandles(const std::vector<Handle>& a,const std::vector<Handle>& b){
    require(a.size()==b.size(),"wrong allocation count");
    for(size_t i=0;i<a.size();++i)require(same(a[i],b[i]),"allocation order or generation disagrees");
}
void lifecycle(){
    Arena gpu(32768,256);Reference ref{256};std::vector<Handle> active;
    auto step=[&](const std::vector<Handle>& releases,PxU32 count,bool alias=false){
        const auto expected=ref.transact(releases,count);
        compareHandles(gpu.transact(releases,count,alias),expected);gpu.compare(ref);return expected;
    };
    active=step({},3);
    require(active[0].slot==0 && active[2].slot==2,"first page ordering");
    auto more=step({},2);
    require(more[0].slot==4 && more[1].slot==3,"existing tail slice ordering");
    active.insert(active.end(),more.begin(),more.end());
    const auto reused=step({active[1],active[0]},2,true);
    require(reused[0].slot==1 && reused[1].slot==0 && reused[0].generation==2,"release/reuse ordering");
    active[1]=reused[0];active[0]=reused[1];
    more=step({},1025);active.insert(active.end(),more.begin(),more.end());
    std::mt19937 rng(0x57ad91);
    for(PxU32 pass=0;pass<300;++pass){
        std::shuffle(active.begin(),active.end(),rng);
        const size_t n=std::min(active.size(),size_t(rng()%1026));
        const std::vector<Handle> retired(active.end()-n,active.end());active.resize(active.size()-n);
        const PxU32 add=active.size()>12000?0:rng()%1026;
        more=step(retired,add,pass%2==0);active.insert(active.end(),more.begin(),more.end());
    }
    step(active,0);step({},0);
}
void atomicFailure(Arena& gpu,const std::vector<Handle>& releases,PxU32 count,PxU32 expected){
    const auto before=gpu.state.get(1)[0];
    const auto entries=gpu.entries.get(before.allocated);const auto free=gpu.free.get(before.freeCount);
    const auto result=gpu.transact(releases,count);const auto after=gpu.state.get(1)[0];
    require((after.error&expected)!=0,"missing expected failure");
    require(after.allocated==before.allocated && after.freeCount==before.freeCount && after.liveCount==before.liveCount,"failed batch committed counts");
    const auto actual=gpu.entries.get(before.allocated);
    for(size_t i=0;i<actual.size();++i)
        require(actual[i].live==entries[i].live && actual[i].generation==entries[i].generation,"failed batch mutated registration");
    require(gpu.free.get(before.freeCount)==free,"failed batch mutated free stack");
    for(auto h:result)require(same(h,{0xdeadbeef,0xcafef00d}),"failed batch published a handle");
}
void errorsAndGrowth(){
    Arena gpu(256,256);auto handles=gpu.transact({},4);
    auto stale=handles[1];++stale.generation;
    atomicFailure(gpu,{handles[0],stale},2,eREGISTRATION_STALE_HANDLE);
    atomicFailure(gpu,{},1,eREGISTRATION_STALE_HANDLE); // failure remains latched
    auto s=gpu.state.get(1)[0];s.error=0;gpu.state.put({s});
    atomicFailure(gpu,{handles[0],handles[0]},2,eREGISTRATION_DUPLICATE_RELEASE);
    s=gpu.state.get(1)[0];s.error=0;gpu.state.put({s});
    atomicFailure(gpu,{handles[0]},258,eREGISTRATION_CAPACITY);
    s=gpu.state.get(1)[0];require(s.requiredCapacity==512,"missing growth request");
    // Capacity growth preserves only initialized state; retry exactly the same
    // command without replaying any release or generation increment.
    Arena grown(512,256);
    check(cudaMemcpy(grown.entries.p,gpu.entries.p,s.allocated*sizeof(Entry),cudaMemcpyDeviceToDevice));
    check(cudaMemcpy(grown.free.p,gpu.free.p,s.freeCount*sizeof(PxU32),cudaMemcpyDeviceToDevice));
    s.error=0;grown.state.put({s});
    Reference ref{256};auto original=ref.transact({},4);
    compareHandles(grown.transact({handles[0]},258),ref.transact({original[0]},258));grown.compare(ref);
    // Fail closed on generation wrap without partially releasing a live handle.
    auto e= grown.entries.get(512);const auto f=grown.free.get(grown.state.get(1)[0].freeCount);
    e[f.back()].generation=~PxU32(0);grown.entries.put(e);
    atomicFailure(grown,{handles[2]},2,eREGISTRATION_GENERATION_EXHAUSTED);
    s=grown.state.get(1)[0];s.error=0;s.epoch=~PxU64(0);grown.state.put({s});
    atomicFailure(grown,{},1,eREGISTRATION_INVALID_STATE);
    Arena invalid(256,3);atomicFailure(invalid,{},1,eREGISTRATION_INVALID_STATE);
    invalid.page=256;s={};s.allocated=1;s.freeCount=1;invalid.state.put({s});
    invalid.entries.put({{}});invalid.free.put({0});
    atomicFailure(invalid,{},1,eREGISTRATION_INVALID_STATE);
}
// Native producers can refer to earlier GPU-assigned handles. No host observes
// or re-uploads those handles between command batches.
struct QueueAccess {
    const PxU32* source;
    Handle* assigned;
    __device__ Handle release(PxU32 i)const{return assigned[source[i]];}
    __device__ void assign(PxU32 i,Handle h)const{assigned[i]=h;}
};
__global__ void publishCount(PxU32* destination,PxU32 count){*destination=count;}
void queuedLifecycle(){
    Arena gpu(32768,256);Reference ref{256};
    std::vector<PxgDestructionRegistrationCommand> commands;
    std::vector<Handle> expected;
    std::vector<PxU32> active,sources;
    std::mt19937 rng(0x259971);
    for(PxU32 batch=0;batch<101;++batch){
        std::shuffle(active.begin(),active.end(),rng);
        const PxU32 retire=PxU32(std::min(active.size(),size_t(rng()%513)));
        const PxU32 add=batch==0?1025:batch==100?0:rng()%513;
        const PxU32 releaseOffset=PxU32(sources.size()),assignOffset=PxU32(expected.size());
        std::vector<Handle> releases;
        for(PxU32 i=0;i<retire;++i){
            const auto index=active.back();active.pop_back();sources.push_back(index);releases.push_back(expected[index]);
        }
        const auto assigned=ref.transact(releases,add);
        for(PxU32 i=0;i<add;++i)active.push_back(assignOffset+i);
        expected.insert(expected.end(),assigned.begin(),assigned.end());
        commands.push_back({releaseOffset,retire,assignOffset,add});
    }
    const PxU32 actualCount=PxU32(commands.size());
    // The device count, not backing capacity, determines valid commands.
    commands.push_back({~PxU32(0),~PxU32(0),~PxU32(0),~PxU32(0)});
    Device<PxgDestructionRegistrationCommand> tape(commands.size());tape.put(commands);
    Device<PxU32> count(1),input(sources.size());input.put(sources);
    Device<Handle> output(expected.size()+1);output.put(std::vector<Handle>(expected.size()+1,{0xdeadbeef,0xcafef00d}));
    PxgDestructionRegistrationQueue queue={tape.p,count.p,PxU32(commands.size()),PxU32(sources.size()),PxU32(expected.size())};
    int residency=0;check(destructionRegistration::queueResidentBlocks<QueueAccess>(residency));
    cudaStream_t producer,consumer;cudaEvent_t ready;
    check(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));
    check(cudaStreamCreateWithFlags(&consumer,cudaStreamNonBlocking));
    check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    publishCount<<<1,1,0,producer>>>(count.p,actualCount);
    check(cudaEventRecord(ready,producer));check(cudaStreamWaitEvent(consumer,ready,0));
    check(destructionRegistration::launchQueue(gpu.view(),QueueAccess{input.p,output.p},queue,residency,std::min(8,residency),consumer));
    check(cudaStreamSynchronize(consumer));
    compareHandles(output.get(expected.size()),expected);gpu.compare(ref);
    require(same(output.get(expected.size()+1).back(),{0xdeadbeef,0xcafef00d}),"queue overwrote unused output capacity");
    // An empty producer queue never reads the poisoned command capacity.
    publishCount<<<1,1,0,consumer>>>(count.p,0);
    check(destructionRegistration::launchQueue(gpu.view(),QueueAccess{input.p,output.p},queue,residency,1,consumer));
    check(cudaStreamSynchronize(consumer));gpu.compare(ref);
    // Overflow is latched before any command executes or touches payloads.
    const auto before=gpu.state.get(1)[0];
    publishCount<<<1,1,0,consumer>>>(count.p,PxU32(commands.size()+1));
    check(destructionRegistration::launchQueue(gpu.view(),QueueAccess{input.p,output.p},queue,residency,1,consumer));
    check(cudaStreamSynchronize(consumer));auto after=gpu.state.get(1)[0];
    require(after.error==eREGISTRATION_INVALID_STATE && after.epoch==before.epoch,"queue overflow executed a command");
    after.error=0;gpu.state.put({after});
    // Bad payload offsets are likewise rejected without reading them.
    tape.put({commands.back()});publishCount<<<1,1,0,consumer>>>(count.p,1);
    check(destructionRegistration::launchQueue(gpu.view(),QueueAccess{input.p,output.p},queue,residency,1,consumer));
    check(cudaStreamSynchronize(consumer));after=gpu.state.get(1)[0];
    require(after.error==eREGISTRATION_INVALID_STATE && after.epoch==before.epoch,"invalid queue offsets executed a command");
    after.error=0;gpu.state.put({after});gpu.compare(ref);
    require(destructionRegistration::launchQueue(gpu.view(),QueueAccess{input.p,output.p},queue,residency,residency+1,consumer)==cudaErrorInvalidValue,"illegal cooperative launch accepted");
    check(cudaEventDestroy(ready));check(cudaStreamDestroy(producer));check(cudaStreamDestroy(consumer));
}
int main(){try{
    lifecycle();errorsAndGrowth();queuedLifecycle();
    std::puts("GPU registration passed: 300 mixed lifecycle batches and 101 device-queued batches; paged order, GPU-produced handle dependencies, generations, aliasing, atomic failures, growth/retry and stream ordering");
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
