// Private CUDA construction primitives for the resident multilevel hierarchy.
#pragma once
#include <cuda_runtime.h>
#include <cooperative_groups.h>
#include <cstdint>
#include <cmath>
namespace Nv { namespace Blast { namespace StressHierarchy {
constexpr unsigned Invalid=0xffffffffu, Threads=256;
struct Input {
    unsigned nodes,bonds;
    const unsigned *begin,*refs,*node0,*node1,*component;
    const float *health,*scale;
    const float4 *position,*offset0,*offset1;
    const float2* inertia;
    const std::uint64_t* generation;
    const unsigned* accept;
};
struct Status {
    std::uint64_t generation;
    unsigned initialized,builds,rounds,aggregates,error;
};
struct Work {unsigned active,pending;};
struct CoarseBond {
    unsigned a,b;
    double3 offset0,offset1;
    double scale;
};
struct Buffers {
    unsigned *owner,*seed,*minimum,*leader,*pending,*memberBond;
    CoarseBond* coarse;
    double* diagonal;
};
__device__ __forceinline__ unsigned priority(unsigned node,unsigned round)
{
    unsigned x=node+0x9e3779b9u*(round+1u);
    x=(x^(x>>16))*0x7feb352du;x=(x^(x>>15))*0x846ca68bu;
    return x^(x>>16);
}
// Immutable CSR bounds/endpoint identities are validated before any gather.
// The component labels are the caller's current exact GPU partition. Static
// boundary nodes carry Invalid and never connect two dynamic components.
__device__ __forceinline__ unsigned neighbour(const Input& a,unsigned node,unsigned slot,Status* status)
{
    const unsigned ref=a.refs[slot];if(ref==Invalid)return Invalid;
    const unsigned bond=ref&0x7fffffffu;
    if(bond>=a.bonds){atomicOr(&status->error,1u);return Invalid;}
    const unsigned first=a.node0[bond],second=a.node1[bond];
    if(first>=a.nodes || second>=a.nodes || first==second
        || ((ref>>31)?second:first)!=node){atomicOr(&status->error,1u);return Invalid;}
    if(!isfinite(a.health[bond])){atomicOr(&status->error,2u);return Invalid;}
    if(a.health[bond]<=0)return Invalid;
    const unsigned other=(ref>>31)?first:second;
    if(a.component[other]==Invalid)return Invalid;
    if(a.component[node]!=a.component[other]){atomicOr(&status->error,1u);return Invalid;}
    return other;
}
__device__ __forceinline__ void beginBuild(const Input& a,Status* status,Work* work)
{
    bool run=!a.accept || *a.accept;
    if(run && status->initialized && *a.generation<status->generation){status->error=4;run=false;}
    if(run)run=!status->initialized || *a.generation!=status->generation || status->error;
    if(run){status->error=0;status->rounds=0;status->aggregates=0;}
    work->active=work->pending=unsigned(run);
}
__device__ __forceinline__ void initialize(const Input* input,Buffers b,Status* status,unsigned logicalBlock)
{
    const unsigned i=logicalBlock*blockDim.x+threadIdx.x;if(i>=input->nodes)return;
    b.owner[i]=b.minimum[i]=b.leader[i]=b.memberBond[i]=Invalid;b.seed[i]=0;
    const auto d=input->inertia[i];const auto p=input->position[i];
    const bool active=input->component[i]!=Invalid;
    const bool dynamic=d.x>0 && d.y>0,fixed=d.x==0 && d.y==0;
    if(!isfinite(d.x)||!isfinite(d.y)||(!dynamic&&!fixed)||(active&&!dynamic))atomicOr(&status->error,8u);
    // Native PhysX stress labels omit uncoupled dynamic rows as well as fixed
    // rows. Accept those zero rows, but never omit a loaded live constraint.
    if(!active && dynamic){
        const unsigned begin=input->begin[i],end=input->begin[i+1];
        if(begin>end || end>2ull*input->bonds)atomicOr(&status->error,1u);
        else for(unsigned slot=begin;slot<end;++slot){
            const unsigned ref=input->refs[slot];if(ref==Invalid)continue;
            const unsigned bond=ref&0x7fffffffu;
            if(bond>=input->bonds || input->health[bond]>0)atomicOr(&status->error,1u);
        }
    }
    if(!isfinite(p.x)||!isfinite(p.y)||!isfinite(p.z))atomicOr(&status->error,2u);
}
__device__ __forceinline__ void chooseSeeds(const Input* input,Buffers b,Status* status,unsigned logicalBlock)
{
    const auto a=*input;const unsigned node=logicalBlock*blockDim.x+threadIdx.x;
    if(node>=a.nodes)return;b.seed[node]=0;
    if(a.component[node]==Invalid || b.owner[node]!=Invalid)return;
    const unsigned begin=a.begin[node],end=a.begin[node+1];
    if(begin>end || end>2ull*a.bonds || a.component[node]>=a.nodes){atomicOr(&status->error,1u);return;}
    // Prefer hubs so a star coarsens to one aggregate instead of losing only
    // one leaf per level. Hash ties by round for parallel progress on paths;
    // this is an integer layout choice, never a physical approximation.
    const unsigned degree=end-begin,mine=priority(node,status->rounds);bool seed=true;
    for(unsigned i=begin;i<end;++i){
        const unsigned other=neighbour(a,node,i,status);
        if(other==Invalid || b.owner[other]!=Invalid)continue;
        const unsigned theirs=priority(other,status->rounds);
        const unsigned otherDegree=a.begin[other+1]-a.begin[other];
        if(otherDegree>degree || (otherDegree==degree && (theirs>mine || (theirs==mine && other>node))))seed=false;
    }
    b.seed[node]=unsigned(seed);
}
__device__ __forceinline__ void assignSeeds(const Input* input,Buffers b,Status* status,unsigned logicalBlock)
{
    const auto a=*input;const unsigned node=logicalBlock*blockDim.x+threadIdx.x;unsigned pending=0;
    if(node<a.nodes && a.component[node]!=Invalid && b.owner[node]==Invalid){
        unsigned owner=b.seed[node]?node:Invalid,memberBond=Invalid;
        const unsigned begin=a.begin[node],end=a.begin[node+1];
        if(begin<=end && end<=2ull*a.bonds && !b.seed[node])for(unsigned i=begin;i<end;++i){
            const unsigned other=neighbour(a,node,i,status);
            if(other!=Invalid && b.seed[other]){
                const unsigned bond=a.refs[i]&0x7fffffffu;
                if(other<owner){owner=other;memberBond=bond;}
                else if(other==owner)memberBond=min(memberBond,bond);
            }
        }
        b.owner[node]=owner;b.memberBond[node]=memberBond;pending=owner==Invalid;
    }
    // Convergence needs only whether any node remains, not a global sum.
    const unsigned remaining=__syncthreads_or(pending!=0);
    if(!threadIdx.x)b.pending[logicalBlock]=remaining;
}
__device__ __forceinline__ void finishRound(const Input* input,Buffers b,Status* status,Work* work)
{
    bool pending=false;const unsigned blocks=(input->nodes+Threads-1)/Threads;
    for(unsigned i=threadIdx.x;i<blocks;i+=blockDim.x)pending|=b.pending[i]!=0;
    const unsigned remaining=__syncthreads_or(pending);
    if(!threadIdx.x){++status->rounds;work->pending=unsigned(remaining && !status->error);}
}
__device__ __forceinline__ void minimumMembers(const Input* input,Buffers b,unsigned logicalBlock)
{
    const unsigned i=logicalBlock*blockDim.x+threadIdx.x;
    if(i<input->nodes && b.owner[i]!=Invalid)atomicMin(b.minimum+b.owner[i],i);
}
__device__ __forceinline__ void publishLeaders(const Input* input,Buffers b,Status* status,unsigned logicalBlock)
{
    const unsigned i=logicalBlock*blockDim.x+threadIdx.x;unsigned root=Invalid;
    if(i<input->nodes && b.owner[i]!=Invalid){root=b.minimum[b.owner[i]];b.leader[i]=root;}
    const unsigned count=__syncthreads_count(i<input->nodes && root==i);
    if(!threadIdx.x)atomicAdd(&status->aggregates,count);
}
__device__ __forceinline__ double3 relativeOffset(float4 position,float4 offset,float4 origin)
{
    return make_double3((double(position.x)-origin.x)+offset.x,
                        (double(position.y)-origin.y)+offset.y,
                        (double(position.z)-origin.z)+offset.z);
}
__device__ __forceinline__ bool finite(double3 v){return isfinite(v.x)&&isfinite(v.y)&&isfinite(v.z);}
// Store a sparse factor, not a dense inverse or a CPU-assembled matrix.
// Prolongation is the mass-scaled rigid basis at each aggregate's minimum-ID
// origin. Thus B^T P has the original coupling form with shifted offsets and
// unit coarse inertia. Retain self-edges: independently rounded fine offsets
// can leave a small nonzero internal term, which must not be silently dropped.
__device__ __forceinline__ void buildCoarseBonds(const Input* input,Buffers b,Status* status,unsigned logicalBlock)
{
    const auto a=*input;const unsigned i=logicalBlock*blockDim.x+threadIdx.x;if(i>=a.bonds)return;
    CoarseBond out{};out.a=out.b=Invalid;
    if(!isfinite(a.health[i]))atomicOr(&status->error,2u);
    else if(a.health[i]>0){
        const unsigned first=a.node0[i],second=a.node1[i];
        if(first>=a.nodes || second>=a.nodes || first==second){atomicOr(&status->error,1u);b.coarse[i]=out;return;}
        out.a=b.leader[first];out.b=b.leader[second];out.scale=a.scale[i];
        if(out.a!=Invalid)out.offset0=relativeOffset(a.position[first],a.offset0[i],a.position[out.a]);
        if(out.b!=Invalid)out.offset1=relativeOffset(a.position[second],a.offset1[i],a.position[out.b]);
        if(!finite(out.offset0)||!finite(out.offset1)||!isfinite(out.scale)||!(out.scale>0))atomicOr(&status->error,2u);
    }
    b.coarse[i]=out;
}
__device__ __forceinline__ void commitBuild(const Input* input,Status* status)
{
    if(!status->error){status->generation=*input->generation;status->initialized=1;++status->builds;}
}
#include "StressHierarchyDiagonal.cuh"
// All mutable construction state stays on the device. Residency limits the
// physical grid, never the amount of topology processed by its virtual blocks.
__global__ void construct(Input input,Buffers buffers,Status* status,Work* work)
{
    const auto grid=cooperative_groups::this_grid();
    const unsigned nodes=max(1u,(input.nodes+Threads-1)/Threads);
    const unsigned bonds=(input.bonds+Threads-1)/Threads;
    if(!blockIdx.x && !threadIdx.x)beginBuild(input,status,work);
    grid.sync();if(!work->active)return;
    for(unsigned block=blockIdx.x;block<nodes;block+=gridDim.x)initialize(&input,buffers,status,block);
    grid.sync();
    while(work->pending){
        for(unsigned block=blockIdx.x;block<nodes;block+=gridDim.x)chooseSeeds(&input,buffers,status,block);
        grid.sync();
        for(unsigned block=blockIdx.x;block<nodes;block+=gridDim.x)assignSeeds(&input,buffers,status,block);
        grid.sync();
        if(!blockIdx.x)finishRound(&input,buffers,status,work);
        grid.sync();
    }
    for(unsigned block=blockIdx.x;block<nodes;block+=gridDim.x)minimumMembers(&input,buffers,block);
    grid.sync();
    for(unsigned block=blockIdx.x;block<nodes;block+=gridDim.x)publishLeaders(&input,buffers,status,block);
    grid.sync();
    for(unsigned block=blockIdx.x;block<bonds;block+=gridDim.x)buildCoarseBonds(&input,buffers,status,block);
    grid.sync();
    // Validate all shared geometry/topology first. This decision is uniform
    // across the cooperative grid and never travels through the host.
    if(!blockIdx.x && !threadIdx.x)work->pending=unsigned(!status->error);
    grid.sync();
    if(work->pending){
        const unsigned diagonalBlocks=(input.nodes+Threads/32-1)/(Threads/32);
        for(unsigned block=blockIdx.x;block<diagonalBlocks;block+=gridDim.x)buildFineDiagonal(input,buffers,status,block);
    }
    grid.sync();
    if(!blockIdx.x && !threadIdx.x)commitBuild(&input,status);
}

}}}
