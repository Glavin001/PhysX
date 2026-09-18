// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionTopology.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <numeric>
#include <random>
#include <vector>

using namespace physx;
#define CHECK(x) do { if (!(x)) { std::fprintf(stderr,"%s:%d: %s\n",__FILE__,__LINE__,#x); std::exit(1); } } while (0)
#define CUDA(x) CHECK((x) == cudaSuccess)

template<class T> std::vector<T> read(const T* device, size_t n) {
    std::vector<T> host(n);
    if (n) CUDA(cudaMemcpy(host.data(),device,n*sizeof(T),cudaMemcpyDeviceToHost));
    return host;
}

std::vector<PxgDestructionClusterMotion> activeMotions(const PxgDestructionTopologyView& view) {
    const auto count=read(view.status,1)[0].clusterCount;
    const auto roots=read(view.activeClusters,count),slots=read(view.clusterSlots,view.chunkCount);
    std::vector<PxgDestructionClusterMotion> out;
    for(auto root:roots) {
        CHECK(slots[root]<view.slotCapacity);
        out.push_back(read(view.motions+slots[root],1)[0]);
    }
    return out;
}

struct Fixture {
    std::vector<PxgDestructionChunk> chunks;
    std::vector<PxgDestructionBond> bonds;
    std::vector<unsigned> alive, edges;
    PxgDestructionTopology* gpu = nullptr;
    std::uint64_t generation = 0;
    explicit Fixture(unsigned n) : chunks(n), alive(n,1) {
        for (unsigned i=0;i<n;++i) {
            chunks[i] = {{double(i%101)*0.37, double(i%13)*0.61, double(i%7)*0.19},
                1.0 + double(i%5), {0.5,0.6,0.7,0.01,0.02,0.03}, i%37==0 ? 1u : 0u};
        }
    }
    ~Fixture() { if (gpu) gpu->release(); }
    void create() {
        edges.assign(bonds.size(),1);
        gpu = PxgDestructionTopology::create(chunks.data(),unsigned(chunks.size()),bonds.data(),unsigned(bonds.size()));
        CHECK(gpu); compare(false);
    }
    void apply(const std::vector<PxgDestructionEdit>& edits, bool valid = true, void* consumerDone = nullptr) {
        PxgDestructionEdit* d = nullptr;
        if (!edits.empty()) {
            CUDA(cudaMalloc(&d,edits.size()*sizeof(*d)));
            CUDA(cudaMemcpy(d,edits.data(),edits.size()*sizeof(*d),cudaMemcpyHostToDevice));
        }
        CHECK(gpu->apply(d,unsigned(edits.size()),nullptr,consumerDone));
        CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(gpu->view().readyEvent)));
        if (valid) {
            bool changed = false;
            for (const auto& e : edits) {
                unsigned& value = e.kind == PxgDestructionEditKind::BreakBond ? edges[e.index] : alive[e.index];
                changed |= value != 0; value = 0;
            }
            for (unsigned i=0;i<bonds.size();++i)
                if (!alive[bonds[i].chunk0] || !alive[bonds[i].chunk1]) edges[i]=0;
            if (changed) ++generation;
        }
        compare(!valid);
        if (d) CUDA(cudaFree(d));
    }
    void compare(bool invalid, const PxgDestructionTopologyView* other = nullptr) {
        const auto view = other ? *other : gpu->view();
        CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(view.readyEvent)));
        const auto status = read(view.status,1)[0];
        CHECK(status.generation == generation);
        CHECK(!status.slotError);
        CHECK(status.invalidEdit == unsigned(invalid));
        CHECK(read(view.activeChunks,chunks.size()) == alive);
        CHECK(read(view.activeBonds,bonds.size()) == edges);
        std::vector<unsigned> parent(chunks.size());
        std::iota(parent.begin(),parent.end(),0);
        auto root = [&](unsigned x) { while (parent[x]!=x) x=parent[x]; return x; };
        for (unsigned i=0;i<bonds.size();++i) if (edges[i]) {
            unsigned a=root(bonds[i].chunk0),b=root(bonds[i].chunk1);
            parent[std::max(a,b)] = std::min(a,b);
        }
        std::vector<unsigned> roots;
        const auto labels = read(view.chunkCluster,chunks.size());
        for (unsigned i=0;i<chunks.size();++i) {
            CHECK(labels[i] == (alive[i] ? root(i) : 0xffffffffu));
            if (alive[i] && root(i)==i) roots.push_back(i);
        }
        CHECK(status.clusterCount == roots.size());
        CHECK(read(view.activeClusters,roots.size()) == roots);
        CHECK(view.slotCapacity==chunks.size());
        const auto slots=read(view.clusterSlots,chunks.size());
        const auto slotRoots=read(view.slotRoots,view.slotCapacity);
        const auto generations=read(view.slotGenerations,view.slotCapacity);
        unsigned allocated=0;
        for(unsigned slot=0;slot<view.slotCapacity;++slot)if(slotRoots[slot]!=0xffffffffu) {
            ++allocated;CHECK(slotRoots[slot]<chunks.size() && slots[slotRoots[slot]]==slot);
            CHECK(generations[slot]>0);
        }
        CHECK(allocated==roots.size());
        for(unsigned i=0;i<chunks.size();++i) {
            if(alive[i] && root(i)==i)CHECK(slots[i]<view.slotCapacity && slotRoots[slots[i]]==i);
            else CHECK(slots[i]==0xffffffffu);
        }
        const auto clusters=read(view.clusters,chunks.size());
        for (unsigned r:roots) {
            double mass=0,center[3]={},inertia[6]={};
            unsigned count=0,supported=0;
            for(unsigned i=0;i<chunks.size();++i) if(alive[i]&&root(i)==r) {
                const auto& c=chunks[i]; mass+=c.mass; ++count; supported|=c.supported;
                for(unsigned k=0;k<3;++k)center[k]+=c.mass*c.center[k];
            }
            for(unsigned k=0;k<3;++k)center[k]=mass>0?center[k]/mass:chunks[r].center[k];
            for(unsigned i=0;i<chunks.size();++i)if(alive[i]&&root(i)==r) {
                const auto& c=chunks[i];
                const double x=c.center[0]-center[0], y=c.center[1]-center[1], z=c.center[2]-center[2],m=c.mass;
                inertia[0]+=c.inertia[0]+m*(y*y+z*z); inertia[1]+=c.inertia[1]+m*(x*x+z*z);
                inertia[2]+=c.inertia[2]+m*(x*x+y*y); inertia[3]+=c.inertia[3]-m*x*y;
                inertia[4]+=c.inertia[4]-m*x*z; inertia[5]+=c.inertia[5]-m*y*z;
            }
            const auto& c=clusters[r];
            CHECK(c.chunkCount==count && c.supported==supported);
            CHECK(std::abs(c.mass-mass)<1e-9*std::max(1.0,mass));
            for(unsigned k=0;k<3;++k)CHECK(std::abs(c.center[k]-center[k])<1e-9*std::max(1.0,std::abs(center[k])));
            for(unsigned k=0;k<6;++k)CHECK(std::abs(c.inertia[k]-inertia[k])<1e-8*std::max(1.0,std::abs(inertia[k])));
        }
    }
};

void motionContinuity() {
    Fixture f(4);
    for(unsigned i=0;i<4;++i)f.chunks[i]={{(i&1)?1.0:-1.0,(i&2)?1.0:-1.0,0},
        1,{1.0/6,1.0/6,1.0/6,0,0,0},0};
    f.bonds={{0,1},{0,2},{1,3},{2,3}};
    f.create();
    const PxgDestructionClusterMotion initial={{10,20,30},{0,0,std::sqrt(0.5),std::sqrt(0.5)},
        {3,4,5},{0,0,2}};
    cudaStream_t producer;
    cudaEvent_t done;
    CUDA(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));
    CUDA(cudaEventCreateWithFlags(&done,cudaEventDisableTiming));
    CUDA(cudaStreamWaitEvent(producer,static_cast<cudaEvent_t>(f.gpu->view().readyEvent),0));
    CUDA(cudaMemcpyAsync(f.gpu->view().motions,&initial,sizeof(initial),cudaMemcpyHostToDevice,producer));
    CUDA(cudaEventRecord(done,producer));
    f.apply({{PxgDestructionEditKind::BreakBond,0},{PxgDestructionEditKind::BreakBond,3}},true,done);
    auto motion=activeMotions(f.gpu->view());
    CHECK(std::abs(motion[0].linearVelocity[0]-5)<1e-12);
    CHECK(std::abs(motion[1].linearVelocity[0]-1)<1e-12);
    // Two equal-mass clusters: total linear and angular momentum match the
    // original four-body mass distribution about the original COM. Rotation
    // about z leaves Izz invariant and puts the two COMs at world y=+/-1.
    double momentum[3]={},lz=0;
    const auto props=read(f.gpu->view().clusters,4);
    for(unsigned i=0;i<2;++i) {
        for(unsigned k=0;k<3;++k) {
            momentum[k]+=2*motion[i].linearVelocity[k];
            CHECK(motion[i].origin[k]==initial.origin[k]);
            CHECK(motion[i].angularVelocity[k]==initial.angularVelocity[k]);
        }
        for(unsigned k=0;k<4;++k)CHECK(motion[i].orientation[k]==initial.orientation[k]);
        const double y=i?1:-1;
        lz+=props[i].inertia[2]*motion[i].angularVelocity[2]
            -y*2*(motion[i].linearVelocity[0]-initial.linearVelocity[0]);
    }
    for(unsigned k=0;k<3;++k)CHECK(std::abs(momentum[k]-4*initial.linearVelocity[k])<1e-12);
    CHECK(std::abs(lz-(8+4.0/6)*2)<1e-12);
    f.apply({{PxgDestructionEditKind::BreakBond,1},{PxgDestructionEditKind::BreakBond,2}});
    motion=activeMotions(f.gpu->view());
    // The velocity of each chunk center is continuous through both splits.
    for(unsigned i=0;i<4;++i) {
        CHECK(std::abs(motion[i].linearVelocity[0]-((i&1)?1:5))<1e-12);
        CHECK(std::abs(motion[i].linearVelocity[1]-((i&2)?2:6))<1e-12);
        CHECK(motion[i].linearVelocity[2]==5);
    }
    f.apply({{PxgDestructionEditKind::DestroyChunk,0}});
    const auto remaining=activeMotions(f.gpu->view());
    for(unsigned i=0;i<3;++i)for(unsigned k=0;k<3;++k)
        CHECK(remaining[i].linearVelocity[k]==motion[i+1].linearVelocity[k]);
    CUDA(cudaEventDestroy(done)); CUDA(cudaStreamDestroy(producer));
}

__global__ void produceTransaction(PxgDestructionEdit* edits,unsigned* count,unsigned* abort,unsigned* accept,
    unsigned mode,unsigned allow) {
    *count=mode==0?0:mode==3?3:2;*abort=mode==4?1:0;*accept=allow;
    edits[0]={PxgDestructionEditKind::BreakBond,0};
    edits[1]={PxgDestructionEditKind::BreakBond,mode==2?999u:3u};
    if(mode==5)edits[0]={PxgDestructionEditKind::DestroyChunk,0};
}
void deviceTransactions() {
    Fixture f(4);f.bonds={{0,1},{1,2},{2,0},{2,3}};f.create();
    auto* tx=PxgDestructionTopologyTransaction::create(f.chunks.data(),4,f.bonds.data(),4);CHECK(tx);
    CHECK(tx->accepted().chunks==tx->trial().chunks && tx->accepted().bonds==tx->trial().bonds);
    PxgDestructionEdit* edits;unsigned *count,*abort,*accept;
    CUDA(cudaMalloc(&edits,2*sizeof(*edits)));CUDA(cudaMalloc(&count,sizeof(unsigned)));
    CUDA(cudaMalloc(&abort,sizeof(unsigned)));CUDA(cudaMalloc(&accept,sizeof(unsigned)));
    cudaStream_t producer;cudaEvent_t ready;
    CUDA(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));CUDA(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    auto submit=[&](unsigned mode,unsigned allow) {
        CUDA(cudaStreamWaitEvent(producer,static_cast<cudaEvent_t>(tx->accepted().readyEvent),0));
        produceTransaction<<<1,1,0,producer>>>(edits,count,abort,accept,mode,allow);
        CUDA(cudaEventRecord(ready,producer));
        CHECK(tx->prepare(edits,count,2,abort,0xffffffffu,ready));
        CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->trial().readyEvent)));
        return read(tx->status(),1)[0];
    };
    auto unchanged=[&] {auto v=tx->accepted();f.compare(false,&v);};
    auto status=submit(0,1);CHECK(!status.prepared && !status.error && !status.rebuilds);unchanged();
    CHECK(tx->commit(accept));CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));
    CHECK(!read(tx->status(),1)[0].commits);unchanged();
    status=submit(2,1);CHECK(status.error==1 && !status.prepared && !status.rebuilds);unchanged();
    CHECK(tx->commit(accept));CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));unchanged();
    status=submit(3,1);CHECK(status.error==2 && !status.prepared && !status.rebuilds);unchanged();
    status=submit(4,1);CHECK(status.error==4 && !status.prepared && !status.rebuilds);unchanged();
    status=submit(1,0);CHECK(!status.error && status.prepared && status.rebuilds==1);unchanged();
    CHECK(read(tx->trial().status,1)[0].clusterCount==2);
    CHECK(tx->commit(accept));CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));
    CHECK(!read(tx->status(),1)[0].commits);unchanged();
    CHECK(tx->discard());CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));
    CHECK(!read(tx->status(),1)[0].prepared);unchanged();
    status=submit(1,1);CHECK(!status.error && status.prepared && status.rebuilds==2);unchanged();
    CHECK(tx->commit(accept));CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));
    f.apply({{PxgDestructionEditKind::BreakBond,0},{PxgDestructionEditKind::BreakBond,3}});unchanged();
    CHECK(read(tx->status(),1)[0].commits==1);
    CHECK(tx->commit(accept));CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));
    CHECK(read(tx->status(),1)[0].commits==1);unchanged(); // commit once
    status=submit(1,1);CHECK(!status.prepared && !status.error && status.rebuilds==2);unchanged(); // duplicate batch
    status=submit(0,1);CHECK(!status.prepared && !status.error && status.rebuilds==2);unchanged();
    status=submit(5,1);CHECK(status.prepared && !status.error && status.rebuilds==3);unchanged();
    CHECK(tx->commit(accept));CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));
    f.apply({{PxgDestructionEditKind::DestroyChunk,0},{PxgDestructionEditKind::BreakBond,3}});unchanged();
    CHECK(read(tx->status(),1)[0].commits==2);
    tx->release();CUDA(cudaFree(edits));CUDA(cudaFree(count));CUDA(cudaFree(abort));CUDA(cudaFree(accept));
    CUDA(cudaEventDestroy(ready));CUDA(cudaStreamDestroy(producer));
    std::puts("GPU topology transaction: device counts, rejected/overflow/empty trials, discard and commit-once passed");
}

// A device consumer resolves chunk -> root -> stable slot. This deliberately
// does not receive a host-created packed component index or transform array.
__global__ void consumeStableSlots(PxgDestructionTopologyView view,unsigned* output) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=view.chunkCount)return;
    if(!view.activeChunks[i]){output[i]=0xffffffffu;return;}
    const unsigned root=view.chunkCluster[i],slot=view.clusterSlots[root];
    if(slot>=view.slotCapacity || view.slotRoots[slot]!=root || !view.slotGenerations[slot]){__trap();return;}
    output[i]=slot;
}
void stableSlotLifecycle() {
    Fixture f(6);f.bonds={{0,1},{2,3},{4,5}};f.create();
    auto* tx=PxgDestructionTopologyTransaction::create(f.chunks.data(),6,f.bonds.data(),3);CHECK(tx);
    PxgDestructionEdit* edits;unsigned *count,*accept,*output;
    CUDA(cudaMalloc(&edits,2*sizeof(*edits)));CUDA(cudaMalloc(&count,sizeof(unsigned)));
    CUDA(cudaMalloc(&accept,sizeof(unsigned)));CUDA(cudaMalloc(&output,6*sizeof(unsigned)));
    auto wait=[&]{CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->accepted().readyEvent)));};
    auto submit=[&](std::initializer_list<PxgDestructionEdit> list) {
        const unsigned n=unsigned(list.size());
        CUDA(cudaMemcpy(edits,list.begin(),n*sizeof(*edits),cudaMemcpyHostToDevice));
        CUDA(cudaMemcpy(count,&n,sizeof(n),cudaMemcpyHostToDevice));
        CHECK(tx->prepare(edits,count,2));wait();return read(tx->status(),1)[0];
    };
    auto commit=[&](unsigned yes) {
        const auto status=read(tx->status(),1)[0];
        const auto expected=activeMotions(yes && status.prepared && !status.error ? tx->trial() : tx->accepted());
        CUDA(cudaMemcpy(accept,&yes,sizeof(yes),cudaMemcpyHostToDevice));CHECK(tx->commit(accept));wait();
        const auto actual=activeMotions(tx->accepted());CHECK(actual.size()==expected.size());
        for(unsigned i=0;i<actual.size();++i)
            CHECK(!std::memcmp(&actual[i],&expected[i],sizeof(actual[i])));
    };
    auto slots=[&]{return read(tx->accepted().clusterSlots,6);};
    auto generations=[&]{return read(tx->accepted().slotGenerations,6);};
    wait();const auto initial=slots();const auto initialGeneration=generations();
    CHECK(initial[0]==0 && initial[2]==1 && initial[4]==2);
    // Distinct nonzero motion makes an omitted/stale commit observable even
    // when a freed slot is reused by a different root later in this fixture.
    for(unsigned root:{0u,2u,4u}) {
        PxgDestructionClusterMotion motion{};
        motion.origin[0]=10+root;motion.origin[1]=-3;motion.origin[2]=.5;
        motion.orientation[2]=.6;motion.orientation[3]=.8;
        motion.linearVelocity[0]=1+initial[root];motion.linearVelocity[1]=-2;motion.linearVelocity[2]=3;
        motion.angularVelocity[0]=.5;motion.angularVelocity[1]=-.25;motion.angularVelocity[2]=.75;
        CUDA(cudaMemcpy(tx->accepted().motions+initial[root],&motion,sizeof(motion),cudaMemcpyHostToDevice));
    }
    CHECK(submit({{PxgDestructionEditKind::DestroyChunk,0},{PxgDestructionEditKind::DestroyChunk,1}}).prepared);
    commit(1);CHECK(slots()[2]==1 && slots()[4]==2 && slots()[0]==0xffffffffu);
    CHECK(read(tx->accepted().slotRoots,6)[0]==0xffffffffu && generations()==initialGeneration);
    auto status=submit({{PxgDestructionEditKind::BreakBond,1}});CHECK(status.prepared && !status.error);
    CHECK(read(tx->trial().clusterSlots,6)[3]==0 && read(tx->trial().slotGenerations,6)[0]==initialGeneration[0]+1);
    commit(0);CHECK(slots()[3]==0xffffffffu && generations()==initialGeneration);
    CHECK(tx->discard());wait();
    CHECK(submit({{PxgDestructionEditKind::BreakBond,1}}).prepared);commit(1);
    CHECK(slots()[3]==0 && generations()[0]==initialGeneration[0]+1);
    CHECK(slots()[2]==1 && slots()[4]==2 && generations()[1]==initialGeneration[1]);
    consumeStableSlots<<<1,32>>>(tx->accepted(),output);CUDA(cudaDeviceSynchronize());
    CHECK(read(output,6)==std::vector<unsigned>({0xffffffffu,0xffffffffu,1,0,2,2}));
    CHECK(submit({{PxgDestructionEditKind::DestroyChunk,3}}).prepared);commit(1);
    // Fault injection: a freed slot must not wrap and resurrect an old handle.
    const std::uint64_t exhausted=~std::uint64_t(0);
    CUDA(cudaMemcpy(const_cast<std::uint64_t*>(tx->accepted().slotGenerations),&exhausted,sizeof(exhausted),cudaMemcpyHostToDevice));
    const auto beforeSlots=slots();const auto beforeGeneration=generations();
    const auto beforeStatus=read(tx->accepted().status,1)[0];
    status=submit({{PxgDestructionEditKind::BreakBond,2}});
    CHECK(!status.prepared && status.error==8 && read(tx->trial().status,1)[0].slotError==2);
    commit(1);CHECK(slots()==beforeSlots && generations()==beforeGeneration);
    CHECK(read(tx->accepted().status,1)[0].generation==beforeStatus.generation);
    CHECK(read(tx->accepted().activeBonds,3)[2]==1);
    tx->release();CUDA(cudaFree(edits));CUDA(cudaFree(count));CUDA(cudaFree(accept));CUDA(cudaFree(output));
    std::puts("GPU stable motion slots: retained identity, free-slot reuse, device consumer, rejected candidates and generation exhaustion passed");
}

__global__ void largeTransactionEdits(const PxgDestructionBond* bonds,unsigned n,PxgDestructionEdit* edits,
    unsigned* count,bool all) {
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<n && (all || bonds[i].chunk0/1000!=bonds[i].chunk1/1000))
        edits[atomicAdd(count,1u)]={PxgDestructionEditKind::BreakBond,i};
}
void largeTransactions() {
    Fixture f(100000);
    for(unsigned i=1;i<100000;++i)f.bonds.push_back({i-1,i});
    for(unsigned i=2;i<100000;++i)f.bonds.push_back({i-2,i});
    f.bonds.push_back({0,99999});f.bonds.push_back({1,99999});f.bonds.push_back({2,99999});
    CHECK(f.bonds.size()==200000);f.create();
    auto* tx=PxgDestructionTopologyTransaction::create(f.chunks.data(),100000,f.bonds.data(),200000);CHECK(tx);
    PxgDestructionEdit* edits;unsigned* count;
    CUDA(cudaMalloc(&edits,200000*sizeof(*edits)));CUDA(cudaMalloc(&count,sizeof(unsigned)));
    cudaStream_t producer;cudaEvent_t ready;
    CUDA(cudaStreamCreateWithFlags(&producer,cudaStreamNonBlocking));CUDA(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    auto prepare=[&](bool all) {
        CUDA(cudaStreamWaitEvent(producer,static_cast<cudaEvent_t>(tx->accepted().readyEvent),0));
        CUDA(cudaMemsetAsync(count,0,sizeof(unsigned),producer));
        largeTransactionEdits<<<(200000+255)/256,256,0,producer>>>(tx->accepted().bonds,200000,edits,count,all);
        CUDA(cudaEventRecord(ready,producer));
        CHECK(tx->prepare(edits,count,200000,nullptr,0xffffffffu,ready));
        CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(tx->trial().readyEvent)));
        CHECK(read(tx->status(),1)[0].prepared && !read(tx->status(),1)[0].error);
    };
    prepare(false);
    auto candidate=tx->trial();CHECK(read(candidate.status,1)[0].clusterCount==100);
    std::vector<PxgDestructionEdit> expected;
    for(unsigned i=0;i<f.bonds.size();++i)if(f.bonds[i].chunk0/1000!=f.bonds[i].chunk1/1000)
        expected.push_back({PxgDestructionEditKind::BreakBond,i});
    f.apply(expected);f.compare(false,&candidate);
    // A second candidate replaces the first without consuming it. All 200k
    // break decisions are retained and yield 100k independent components.
    prepare(true);candidate=tx->trial();CHECK(read(candidate.status,1)[0].clusterCount==100000);
    const auto roots=read(candidate.activeClusters,100000),labels=read(candidate.chunkCluster,100000);
    const auto properties=read(candidate.clusters,100000);
    for(unsigned i=0;i<100000;++i) {
        CHECK(roots[i]==i && labels[i]==i && properties[i].chunkCount==1);
        CHECK(properties[i].mass==f.chunks[i].mass && properties[i].supported==f.chunks[i].supported);
        for(unsigned k=0;k<3;++k)CHECK(properties[i].center[k]==f.chunks[i].center[k]);
        for(unsigned k=0;k<6;++k)CHECK(properties[i].inertia[k]==f.chunks[i].inertia[k]);
    }
    CHECK(read(tx->accepted().status,1)[0].clusterCount==1 && !read(tx->accepted().status,1)[0].generation);
    CHECK(read(tx->status(),1)[0].editCount==200000 && read(tx->status(),1)[0].rebuilds==2 && !read(tx->status(),1)[0].commits);
    CHECK(tx->discard());tx->release();CUDA(cudaFree(edits));CUDA(cudaFree(count));
    CUDA(cudaEventDestroy(ready));CUDA(cudaStreamDestroy(producer));
    std::puts("GPU topology transaction: 100k chunks / 200k bonds, all fracture decisions retained, candidate replacement without commit passed");
}

int main() {
    deviceTransactions();
    largeTransactions();
    motionContinuity();
    stableSlotLifecycle();
    {
        Fixture f(4); f.bonds={{0,1},{1,2},{2,0},{2,3}}; f.create();
        const auto* immutableChunks=f.gpu->view().chunks;
        f.apply({{PxgDestructionEditKind::BreakBond,0}}); // alternate path remains
        f.apply({{PxgDestructionEditKind::BreakBond,3}}); // detached chunk
        f.apply({{PxgDestructionEditKind::BreakBond,1},{PxgDestructionEditKind::BreakBond,900}},false);
        f.apply({{PxgDestructionEditKind::BreakBond,3},{PxgDestructionEditKind::BreakBond,3}});
        f.apply({{PxgDestructionEditKind::DestroyChunk,0}}); // smallest root disappears
        f.apply({});
        CHECK(f.gpu->view().chunks==immutableChunks);
        f.apply({{PxgDestructionEditKind::DestroyChunk,1},{PxgDestructionEditKind::DestroyChunk,2},
                 {PxgDestructionEditKind::DestroyChunk,3}});
    }
    {
        Fixture f(10000);
        for(unsigned i=1;i<f.chunks.size();++i)f.bonds.push_back({i-1,i});
        f.create(); CHECK(read(f.gpu->view().status,1)[0].clusterCount==1);
        f.apply({{PxgDestructionEditKind::BreakBond,2499},{PxgDestructionEditKind::BreakBond,7499}});
        CHECK(read(f.gpu->view().status,1)[0].clusterCount==3);
    }
    {
        // A translated asset must retain its full inertia, including products
        // of inertia. This catches world-origin parallel-axis cancellation.
        Fixture f(73);
        for(auto& c : f.chunks) for(unsigned k=0;k<3;++k)c.center[k] += (k+1)*1e8;
        for(unsigned i=1;i<f.chunks.size();++i)f.bonds.push_back({i-1,i});
        f.create();
        f.apply({{PxgDestructionEditKind::BreakBond,19},{PxgDestructionEditKind::BreakBond,53}});
    }
    std::mt19937 rng(1234);
    for(unsigned trial=0;trial<12;++trial) {
        Fixture f(193);
        for(unsigned i=0;i<450;++i)f.bonds.push_back({unsigned(rng()%193),unsigned(rng()%193)});
        f.create();
        for(unsigned pass=0;pass<8;++pass) {
            std::vector<PxgDestructionEdit> edits;
            for(unsigned i=0;i<50;++i)edits.push_back({PxgDestructionEditKind::BreakBond,unsigned(rng()%450)});
            if(pass%2==0)edits.push_back({PxgDestructionEditKind::DestroyChunk,unsigned(rng()%193)});
            f.apply(edits);
        }
    }
    std::puts("GPU topology: cyclic graphs, split roots, atomic rejection, immutable chunk records, 10k chunk clustering and randomized CPU equivalence passed");
}
