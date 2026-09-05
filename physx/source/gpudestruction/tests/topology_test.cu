// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgDestructionTopology.h"
#include <cuda_runtime.h>
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
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
    void compare(bool invalid) {
        const auto view = gpu->view();
        CUDA(cudaEventSynchronize(static_cast<cudaEvent_t>(view.readyEvent)));
        const auto status = read(view.status,1)[0];
        CHECK(status.generation == generation);
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
    auto motion=read(f.gpu->view().motions,2);
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
    motion=read(f.gpu->view().motions,4);
    // The velocity of each chunk center is continuous through both splits.
    for(unsigned i=0;i<4;++i) {
        CHECK(std::abs(motion[i].linearVelocity[0]-((i&1)?1:5))<1e-12);
        CHECK(std::abs(motion[i].linearVelocity[1]-((i&2)?2:6))<1e-12);
        CHECK(motion[i].linearVelocity[2]==5);
    }
    f.apply({{PxgDestructionEditKind::DestroyChunk,0}});
    const auto remaining=read(f.gpu->view().motions,3);
    for(unsigned i=0;i<3;++i)for(unsigned k=0;k<3;++k)
        CHECK(remaining[i].linearVelocity[k]==motion[i+1].linearVelocity[k]);
    CUDA(cudaEventDestroy(done)); CUDA(cudaStreamDestroy(producer));
}

int main() {
    motionContinuity();
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
