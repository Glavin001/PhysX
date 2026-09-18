// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Offline numerical replay of exactly the captured surface+gravity load case.
// This is not a claim that the native command ledger is fully represented.
#include "PxgDestructionElasticPartition.cuh"
#include <cuda_runtime.h>
#include <algorithm>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>
#include <vector>
namespace L=physx::destructionElasticLoads;
namespace E=Nv::Blast::Elastic;
namespace P=physx::destructionElasticPartition;
using namespace physx;
void check(cudaError_t e) {if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T> std::vector<T> read(const std::string& path) {
    std::ifstream f(path,std::ios::binary|std::ios::ate);
    if(!f || f.tellg()<0 || size_t(f.tellg())%sizeof(T))throw std::runtime_error("capture ABI/size: "+path);
    std::vector<T> v(size_t(f.tellg())/sizeof(T));f.seekg(0);f.read(reinterpret_cast<char*>(v.data()),v.size()*sizeof(T));
    if(!f)throw std::runtime_error("capture read: "+path);return v;
}
template<class T> void write(const std::string& path,const std::vector<T>& v) {
    std::ofstream f(path,std::ios::binary);f.write(reinterpret_cast<const char*>(v.data()),v.size()*sizeof(T));
    if(!f)throw std::runtime_error("replay write: "+path);
}
template<class T> struct Device {
    T* p=nullptr;size_t n;
    explicit Device(size_t count):n(count) {check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));check(cudaMemset(p,0,n*sizeof(T)));}
    explicit Device(const std::vector<T>& v):Device(v.size()) {check(cudaMemcpy(p,v.data(),n*sizeof(T),cudaMemcpyHostToDevice));}
    ~Device(){cudaFree(p);}
    Device(const Device&)=delete;
    std::vector<T> get()const {std::vector<T> v(n);check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
// Keep the host capture ABI explicit. Body flags are evidence, not an invented
// acceleration history. This replay has only the specified surface+gravity loads.
struct Body {
    float linear[3],angular[3],externalLinear[3],externalAngular[3],damping[2];
    uint32_t body,flags,locks,disableGravity,valid;
};
static_assert(sizeof(Body)==76,"native capture body ABI");
__global__ void canonical(uint32_t n,const PxDestructionStressChunk* chunks,double3* positions) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    const auto p=chunks[i].position;positions[i]=make_double3(p.x,p.y,p.z);
}
__global__ void restoreAuthored(const P::State* state,const uint32_t* authors,const E::Vector* compact,E::Vector* authored) {
    const auto j=blockIdx.x*blockDim.x+threadIdx.x;
    if(state->status==P::Status::Ready && j<state->groups.nodes)authored[authors[j]]=compact[j];
}
__global__ void motions(L::DeviceGroups source,const PxDestructionChunkMassProperties* mass,const PxTransform* poses,
    const Body* bodies,L::Motion* out,uint32_t* error) {
    const auto g=L::resolve(source);
    const auto group=blockIdx.x;if(group>=g.count || *error)return;
    __shared__ unsigned supported; if(!threadIdx.x)supported=0;__syncthreads();
    for(unsigned j=g.starts[group]+threadIdx.x;j<g.starts[group+1];j+=blockDim.x)
        if(mass[g.indices[j]].supported)atomicOr(&supported,1u);
    __syncthreads();if(threadIdx.x)return;
    const auto pose=poses[group];const auto body=bodies[group];L::Motion motion{};
    motion.state.origin[0]=pose.p.x;motion.state.origin[1]=pose.p.y;motion.state.origin[2]=pose.p.z;
    motion.state.orientation[0]=pose.q.x;motion.state.orientation[1]=pose.q.y;
    motion.state.orientation[2]=pose.q.z;motion.state.orientation[3]=pose.q.w;
    for(unsigned k=0;k<3;++k) {
        motion.state.linearVelocity[k]=body.linear[k];motion.state.angularVelocity[k]=body.angular[k];
        if(body.externalLinear[k]!=0 || body.externalAngular[k]!=0 ||
            (supported && (body.linear[k]!=0 || body.angular[k]!=0)))atomicOr(error,2u);
    }
    if(!body.valid || body.locks || body.disableGravity || body.damping[0]!=0 || body.damping[1]!=0)atomicOr(error,2u);
    motion.mode=supported?L::MotionMode::EngineAcceleration:L::MotionMode::CompleteFreeWrench;
    out[group]=motion;
}
#include "FineReplay.cuh"
int main(int argc,char** argv) {
    try {
        if(argc!=11 && !(argc==12 && (std::string(argv[11])=="--fine" || std::string(argv[11])=="--fine-setup" || std::string(argv[11])=="--fine-check")))
            throw std::runtime_error("Replay directory tick evaluation ownership input-generation seconds gx gy gz output-prefix [--fine|--fine-setup|--fine-check]");
        const std::string directory=argv[1],prefix=argv[10];
        const auto chunks=read<PxDestructionStressChunk>(directory+"/chunks.bin");
        const auto mass=read<PxDestructionChunkMassProperties>(directory+"/mass.bin");
        const auto surface=read<PxDestructionSurfaceLoad>(directory+"/surface.bin");
        const auto poses=read<PxTransform>(directory+"/poses.bin");
        const auto order=read<uint32_t>(directory+"/ordered_chunks.bin");
        const auto active=read<uint32_t>(directory+"/active_chunks.bin");
        const auto bodies=read<Body>(directory+"/bodies.bin");
        const uint32_t n=chunks.size(),count=poses.size();
        if(!n || !count || mass.size()!=n || surface.size()!=n || order.size()!=n || active.size()!=n || bodies.size()!=count)
            throw std::runtime_error("capture array mismatch");
        // Check capacities/permutation before any diagnostic indexed kernel.
        auto sorted=order;std::sort(sorted.begin(),sorted.end());
        for(uint32_t i=0;i<n;++i)if(sorted[i]!=i || active[i]!=1 || chunks[i].cluster>=count)
            throw std::runtime_error("replay requires complete active topology permutation");
        Device<PxDestructionStressChunk> dc(chunks);Device<PxDestructionChunkMassProperties> dm(mass);
        Device<PxDestructionSurfaceLoad> ds(surface);Device<PxTransform> dp(poses);Device<Body> db(bodies);
        Device<uint32_t> di(order),da(active),starts(n+1),local(n),error(1),indices(n),fineToAuthor(n),authorToFine(n);
        Device<uint32_t> roots(read<uint32_t>(directory+"/active_roots.bin")),
            chunkRoot(read<uint32_t>(directory+"/chunk_root.bin")),rootSlot(read<uint32_t>(directory+"/root_slot.bin")),
            slotRoot(read<uint32_t>(directory+"/slot_roots.bin"));
        Device<uint64_t> generations(read<uint64_t>(directory+"/slot_generations.bin"));
        Device<PxDestructionClusterMassProperties> clusterMass(read<PxDestructionClusterMassProperties>(directory+"/cluster_mass.bin"));
        if(roots.n!=count || chunkRoot.n!=n || rootSlot.n!=n || clusterMass.n!=n || slotRoot.n!=generations.n)
            throw std::runtime_error("native topology capture size mismatch");
        Device<PxDestructionStressChunk> compactChunks(n);Device<PxDestructionChunkMassProperties> compactMass(n);
        Device<double3> compactPositions(n);Device<PxDestructionSurfaceLoad> compactSurface(n);
        Device<E::Vector> compactExtra(n),authoredEffective(n);Device<P::State> partition(1);
        Device<PxDestructionTopologyStatus> topologyStatus(std::vector<PxDestructionTopologyStatus>{{std::stoull(argv[4]),count,0,0,0}});
        PxDestructionTopologyDeviceView topology{};
        topology.chunks=dm.p;topology.activeChunks=da.p;topology.chunkCluster=chunkRoot.p;topology.orderedChunks=di.p;
        topology.activeClusters=roots.p;topology.clusters=clusterMass.p;topology.status=topologyStatus.p;
        topology.clusterSlots=rootSlot.p;topology.slotRoots=slotRoot.p;topology.slotGenerations=generations.p;
        topology.slotCapacity=slotRoot.n;topology.chunkCount=n;
        std::unique_ptr<FineReplay> fine;
        if(argc==12){fine.reset(new FineReplay(directory,chunks,prefix,std::string(argv[11])=="--fine-setup",std::string(argv[11])=="--fine-check"));fine->bind(topology);}
        P::Storage storage{n,starts.p,indices.p,local.p,fineToAuthor.p,authorToFine.p,compactChunks.p,compactMass.p,compactPositions.p};
        Device<double3> positions(n);Device<L::Motion> motion(count);Device<L::Receipt> receipts(count);
        Device<E::Vector> effective(n);
        const L::Interval interval{{std::stoull(argv[2]),std::stoull(argv[5]),std::stoull(argv[4]),uint32_t(std::stoul(argv[3])),1},std::stod(argv[6])};
        Device<L::Interval> produced(std::vector<L::Interval>{interval});
        canonical<<<(n+127)/128,128>>>(n,dc.p,positions.p);
        P::Source partitionSource{topology,dc.p,positions.p};const P::Identity identity{1,1,1};
        P::begin<<<1,1>>>(partitionSource,storage,identity,partition.p);
        P::clear<<<(n+128)/128,128>>>(storage,partition.p);
        P::pack<<<(n+127)/128,128>>>(partitionSource,storage,partition.p);
        P::ranges<<<(n+128)/128,128>>>(partitionSource,storage,partition.p);
        P::validate<<<(n+127)/128,128>>>(partitionSource,storage,partition.p);
        P::finish<<<1,1>>>(partition.p);
        P::gate<<<1,1>>>(partition.p,identity,topology,error.p);
        P::scatter<<<(n+127)/128,128>>>(partition.p,storage,ds.p,nullptr,compactSurface.p,compactExtra.p,error.p);
        const L::DeviceGroups groups{&partition.p->groups};
        motions<<<count,128>>>(groups,compactMass.p,dp.p,db.p,motion.p,error.p);
        const L::Inputs inputs{compactPositions.p,compactChunks.p,compactMass.p,compactSurface.p,compactExtra.p,motion.p,produced.p,
            make_double3(std::stod(argv[7]),std::stod(argv[8]),std::stod(argv[9]))};
        const L::Profile profile{1e-6,1e-14,1e-11,1e-11,1e-11,1e-11};
        L::validate<<<(n+127)/128,128>>>(groups,inputs,profile,error.p);
        L::build<<<count,128>>>(groups,inputs,interval,profile,error.p,effective.p,receipts.p);
        L::gate<<<(count+127)/128,128>>>(groups,receipts.p,interval,error.p);
        restoreAuthored<<<(n+127)/128,128>>>(partition.p,fineToAuthor.p,effective.p,authoredEffective.p);
        if(fine)fine->run(topology,positions.p,partition.p,storage,inputs,receipts.p,effective.p,interval,error.p);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto result=receipts.get();unsigned failures=0;
        for(unsigned i=0;i<count;++i)if(result[i].status!=L::Status::Ready) {
            if(failures<8)std::cerr<<"aggregate "<<i<<" status "<<unsigned(result[i].status)<<" force "<<result[i].forceDefect<<" torque "<<result[i].torqueDefect<<"\n";
            ++failures;
        }
        write(prefix+".receipts.bin",result);write(prefix+".effective.bin",authoredEffective.get());
        if(fine)fine->report();
        if(error.get()[0] || failures)throw std::runtime_error("native load replay rejected");
        std::cout<<"PASS contacts+gravity numerical replay: "<<n<<" chunks, "<<count<<" aggregates; ownership generation "<<interval.stamp.ownershipGeneration<<"\n";
    }catch(const std::exception& e){std::cerr<<e.what()<<"\n";return 1;}
}
