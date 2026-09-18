// SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "StressElasticPcgBlock.cuh"
#include <cub/device/device_radix_sort.cuh>

namespace Nv { namespace Blast { namespace Elastic { namespace Partition {
// Rebuild at an explicit topology/support edit boundary. No host convergence
// loop or device count readback. All buffers and scratch are caller-owned and
// exclusive until completion on stream. A rebuild requires fresh layout keys.
struct State { uint32_t count, nodes, error, ready; };
struct Storage {
    uint32_t capacity;
    uint32_t *parents, *roots, *ids, *sortedRoots, *sortedNodes, *flags, *prefix;
    uint32_t *starts, *owner, *local; // starts: capacity+1; others: capacity
    double* length;
    SetupKey* keys;
};
__global__ void begin(Graph g, State* state, const uint32_t* graphError, double length) {
    *state = {0, g.nodes, *graphError, 0};
    if (!isfinite(length) || length <= 0) state->error |= InvalidValue;
}
__global__ void initialize(Graph g, Storage s, const State* state) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if (i>=g.nodes) return;
    // Sorting always receives initialized input, including a rejected graph.
    s.parents[i]=!state->error && !g.prescribed[i] ? i : Unowned;
    s.ids[i]=i;s.owner[i]=s.local[i]=Unowned;
}
__device__ uint32_t root(uint32_t* parent,uint32_t i) {
    for (;;) {
        const auto next=atomicAdd(parent+i,0u);
        if(next==i) return i;
        // All links decrease toward the minimum ID. Atomically skip a stable
        // ancestor; concurrent root linking can only shorten it further.
        const auto ancestor=atomicAdd(parent+next,0u);
        if(ancestor==next)return next;
        atomicCAS(parent+i,next,ancestor);
        i=ancestor;
    }
}
__global__ void unite(Graph g,Storage s,const State* state) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=g.bonds || state->error) return;
    const auto& e=g.interfaces[i];
    if(!live(g,i) || g.prescribed[e.first] || g.prescribed[e.second]) return;
    auto a=e.first,b=e.second;
    for (;;) {
        a=root(s.parents,a);b=root(s.parents,b);
        if(a==b) return;
        const auto low=min(a,b),high=max(a,b);
        if(atomicCAS(s.parents+high,high,low)==high) return;
    }
}
__global__ void labels(Graph g,Storage s) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=g.nodes) return;
    auto r=s.parents[i];
    if(r!=Unowned) while(s.parents[r]!=r) r=s.parents[r];
    s.roots[i]=r;
}
__global__ void mark(Graph g,Storage s,State* state) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=g.nodes) return;
    const auto r=s.sortedRoots[i];
    s.flags[i]=r!=Unowned && (!i || s.sortedRoots[i-1]!=r);
    if(r==Unowned && (!i || s.sortedRoots[i-1]!=Unowned)) state->nodes=i;
}
__global__ void ranges(Graph g,Storage s,State* state,double length,SetupKey key,const SetupKey* deviceKey) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!i) {
        const auto count=g.nodes?s.prefix[g.nodes-1]:0;
        state->count=count;s.starts[count]=state->nodes;
    }
    if(i<g.nodes && s.flags[i]) {
        const auto group=s.prefix[i]-1;
        s.starts[group]=i;s.length[group]=length;s.keys[group]=deviceKey?*deviceKey:key;
    }
}
__global__ void inverse(Graph g,Storage s,const State* state) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=state->nodes || state->error) return;
    const auto node=s.sortedNodes[i],group=s.prefix[i]-1;
    s.owner[node]=group;s.local[node]=i-s.starts[group];
}
__global__ void finish(State* state) {
    state->ready=!state->error;
    if(state->error) state->count=state->nodes=0;
}
inline Components view(Storage s,const State* state) {
    return {s.capacity,s.starts,s.sortedNodes,s.owner,s.local,s.length,&state->count};
}
// Fixed-size inclusive block scan. Every lane participates; out-of-range lanes
// contribute zero. Block totals are scanned recursively at geometry-known sizes,
// so neither a CPU count readback nor a data-dependent host loop is needed.
__global__ void scanBlock(const uint32_t* input,uint32_t* output,uint32_t n,uint32_t* totals) {
    __shared__ uint32_t warps[4];
    const auto i=blockIdx.x*128+threadIdx.x,lane=threadIdx.x%32,warp=threadIdx.x/32;
    uint32_t value=i<n?input[i]:0;
    for(unsigned offset=1;offset<32;offset*=2) {
        const auto previous=__shfl_up_sync(0xffffffffu,value,offset);
        if(lane>=offset)value+=previous;
    }
    if(lane==31)warps[warp]=value;
    __syncthreads();
    if(!warp) {
        uint32_t sum=lane<4?warps[lane]:0;
        for(unsigned offset=1;offset<4;offset*=2) {
            const auto previous=__shfl_up_sync(0xffffffffu,sum,offset);
            if(lane>=offset)sum+=previous;
        }
        __syncwarp(); // all shared loads finish before any lane overwrites them
        if(lane<4)warps[lane]=sum;
    }
    __syncthreads();
    if(i<n)output[i]=value+(warp?warps[warp-1]:0);
    if(totals && !threadIdx.x)totals[blockIdx.x]=warps[3];
}
__global__ void addScanOffsets(uint32_t* output,uint32_t n,const uint32_t* totals) {
    const auto i=blockIdx.x*128+threadIdx.x;
    if(i<n && blockIdx.x)output[i]+=totals[blockIdx.x-1];
}
inline size_t scanBytes(uint32_t n) {
    size_t bytes=0;
    for(uint64_t blocks=(uint64_t(n)+127)/128;blocks>1;blocks=(blocks+127)/128)
        bytes+=2*blocks*sizeof(uint32_t);
    return bytes;
}
inline cudaError_t scan(const uint32_t* input,uint32_t* output,uint32_t n,uint32_t* scratch,cudaStream_t stream) {
    if(!n)return cudaSuccess;
    const auto blocks=uint32_t((uint64_t(n)+127)/128);
    scanBlock<<<blocks,128,0,stream>>>(input,output,n,blocks>1?scratch:nullptr);
    auto result=cudaGetLastError();if(result!=cudaSuccess || blocks==1)return result;
    auto* sums=scratch+blocks;
    result=scan(scratch,sums,blocks,scratch+2*blocks,stream);if(result!=cudaSuccess)return result;
    addScanOffsets<<<blocks,128,0,stream>>>(output,n,sums);
    return cudaGetLastError();
}
// Scratch query does not execute GPU work. Sort is stable: initial ascending
// node IDs therefore give deterministic order within each minimum-root label.
inline cudaError_t scratchBytes(Graph g,Storage s,size_t& bytes,cudaStream_t stream=nullptr) {
    bytes=0;
    if(!g.nodes) return cudaSuccess;
    size_t sort=0;
    const auto result=cub::DeviceRadixSort::SortPairs(nullptr,sort,s.roots,s.sortedRoots,s.ids,s.sortedNodes,g.nodes,0,32,stream);
    const size_t prefix=scanBytes(g.nodes);
    if(result==cudaSuccess)bytes=sort>prefix?sort:prefix;
    return result;
}
inline cudaError_t build(Graph g,Storage s,State* state,const uint32_t* graphError,double length,
                         SetupKey key,void* scratch,size_t bytes,cudaStream_t stream=nullptr,const SetupKey* deviceKey=nullptr) {
    if(g.nodes>s.capacity || !state || !graphError || !s.starts ||
       (g.nodes && (!s.parents || !s.roots || !s.ids || !s.sortedRoots || !s.sortedNodes ||
                    !s.flags || !s.prefix || !s.owner || !s.local || !s.length || !s.keys)))
        return cudaErrorInvalidValue;
    size_t required=0;
    auto result=scratchBytes(g,s,required,stream);
    if(result!=cudaSuccess) return result;
    if(required && (!scratch || bytes<required)) return cudaErrorInvalidValue;
    begin<<<1,1,0,stream>>>(g,state,graphError,length);
    const auto blocks=uint32_t((uint64_t(g.nodes)+127)/128);
    if(g.nodes) {
        initialize<<<blocks,128,0,stream>>>(g,s,state);
        if(g.bonds) unite<<<uint32_t((uint64_t(g.bonds)+127)/128),128,0,stream>>>(g,s,state);
        labels<<<blocks,128,0,stream>>>(g,s);
        result=cudaGetLastError();if(result!=cudaSuccess) return result;
        size_t available=bytes;
        result=cub::DeviceRadixSort::SortPairs(scratch,available,s.roots,s.sortedRoots,s.ids,s.sortedNodes,g.nodes,0,32,stream);
        if(result!=cudaSuccess) return result;
        mark<<<blocks,128,0,stream>>>(g,s,state);
        result=scan(s.flags,s.prefix,g.nodes,reinterpret_cast<uint32_t*>(scratch),stream);
        if(result!=cudaSuccess) return result;
    }
    ranges<<<blocks?blocks:1,128,0,stream>>>(g,s,state,length,key,deviceKey);
    if(g.nodes) inverse<<<blocks,128,0,stream>>>(g,s,state);
    finish<<<1,1,0,stream>>>(state);
    return cudaGetLastError();
}
}}}}
