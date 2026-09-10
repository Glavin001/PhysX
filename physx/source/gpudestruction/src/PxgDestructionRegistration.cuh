// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgDestructionRegistration.h"
#include <cuda_runtime.h>
#include <cooperative_groups.h>
namespace physx { namespace destructionRegistration {
// Access is a device adapter: release(i) reads a handle and assign(i,h) writes
// one. Native geometry/owner packets can supply adapters without repacking them.
// Release and destination storage may alias: all releases finish before writes.
template<class Access>
__device__ void transactBatch(PxgDestructionRegistrationView view,Access access,
    PxU32 releaseCount,PxU32 allocateCount) {
    const auto grid=cooperative_groups::this_grid();
    const PxU64 lane=grid.thread_rank(),stride=grid.size();
    auto* state=view.state;auto* batch=view.batch;
    if(lane==0 && !state->error) {
        const PxU64 freeBefore=PxU64(state->freeCount)+releaseCount;
        const PxU64 take=freeBefore<allocateCount?freeBefore:allocateCount;
        const PxU64 needed=PxU64(allocateCount)-take;
        const bool validPage=view.pageSize && !(view.pageSize&(view.pageSize-1));
        if(!validPage || (validPage && state->allocated%view.pageSize)
            || state->allocated>view.capacity || state->freeCount>state->allocated
            || PxU64(state->freeCount)+state->liveCount!=state->allocated
            || releaseCount>state->liveCount || state->epoch==~PxU64(0))
            state->error=eREGISTRATION_INVALID_STATE;
        else {
            const PxU64 grown=PxU64(state->allocated)+((needed+view.pageSize-1)/view.pageSize)*view.pageSize;
            state->requiredCapacity=grown;
            if(grown>view.capacity)state->error=eREGISTRATION_CAPACITY;
            else {
                *batch={state->allocated,state->freeCount,PxU32(take),PxU32(grown),
                    PxU32(freeBefore+grown-state->allocated-allocateCount),
                    state->liveCount-releaseCount+allocateCount};
                ++state->epoch;
            }
        }
    }
    grid.sync();
    if(state->error)return;
    // Validate the complete batch before changing any registration or free slot.
    for(PxU64 i=lane;i<releaseCount;i+=stride) {
        const auto h=access.release(PxU32(i));
        if(h.slot>=batch->oldAllocated || !h.generation) {
            atomicOr(&state->error,PxU32(eREGISTRATION_STALE_HANDLE));continue;
        }
        auto& entry=view.entries[h.slot];
        if(!entry.live || entry.generation!=h.generation) {
            atomicOr(&state->error,PxU32(eREGISTRATION_STALE_HANDLE));continue;
        }
        if(atomicExch(reinterpret_cast<unsigned long long*>(&entry.claimEpoch),
            static_cast<unsigned long long>(state->epoch))==state->epoch)
            atomicOr(&state->error,PxU32(eREGISTRATION_DUPLICATE_RELEASE));
    }
    // Only reused slots need validation. New page entries are initialized below.
    for(PxU64 i=lane;i<batch->takeFree;i+=stride) {
        const PxU64 position=PxU64(batch->oldFree)+releaseCount-batch->takeFree+i;
        const bool existing=position<batch->oldFree;
        const PxU32 slot=existing?view.freeSlots[position]:access.release(PxU32(position-batch->oldFree)).slot;
        if(slot>=batch->oldAllocated || (existing && view.entries[slot].live))
            atomicOr(&state->error,PxU32(eREGISTRATION_INVALID_STATE));
        else if(view.entries[slot].generation==~PxU32(0))
            atomicOr(&state->error,PxU32(eREGISTRATION_GENERATION_EXHAUSTED));
    }
    grid.sync();
    if(state->error)return;
    for(PxU64 i=lane;i<releaseCount;i+=stride) {
        const auto h=access.release(PxU32(i));
        view.entries[h.slot].live=0;
        view.freeSlots[batch->oldFree+i]=h.slot;
    }
    for(PxU64 i=PxU64(batch->oldAllocated)+lane;i<batch->newAllocated;i+=stride)
        view.entries[i]={0,0,0};
    grid.sync();
    for(PxU64 i=lane;i<allocateCount;i+=stride) {
        const PxU32 slot=i<batch->takeFree
            ?view.freeSlots[PxU64(batch->oldFree)+releaseCount-batch->takeFree+i]
            :PxU32(batch->oldAllocated+i-batch->takeFree);
        auto& entry=view.entries[slot];++entry.generation;entry.live=1;
        access.assign(PxU32(i),PxgDestructionRegistrationHandle{slot,entry.generation});
    }
    grid.sync();
    // Do not overwrite the free-stack tail until every allocation has read it.
    if(batch->newAllocated>batch->oldAllocated)
        for(PxU64 i=lane;i<batch->newFree;i+=stride)
            view.freeSlots[i]=PxU32(batch->newAllocated-1-i);
    grid.sync();
    if(lane==0) {
        state->allocated=batch->newAllocated;state->freeCount=batch->newFree;
        state->liveCount=batch->newLive;
    }
}

template<class Access>
__global__ void transact(PxgDestructionRegistrationView view,Access access,
    PxU32 releaseCount,PxU32 allocateCount) {
    transactBatch(view,access,releaseCount,allocateCount);
}

// Queue adapters offset native access without copying release/output payloads.
template<class Access> struct BatchAccess {
    Access source;
    PxU32 releaseOffset,assignOffset;
    __device__ PxgDestructionRegistrationHandle release(PxU32 i)const {
        return source.release(releaseOffset+i);
    }
    __device__ void assign(PxU32 i,PxgDestructionRegistrationHandle h)const {
        source.assign(assignOffset+i,h);
    }
};
template<class Access>
__global__ void transactQueue(PxgDestructionRegistrationView view,Access access,
    PxgDestructionRegistrationQueue queue) {
    const auto grid=cooperative_groups::this_grid();
    const PxU32 count=*queue.count;
    if(grid.thread_rank()==0 && count>queue.commandCapacity)
        atomicOr(&view.state->error,PxU32(eREGISTRATION_INVALID_STATE));
    grid.sync();
    if(view.state->error)return;
    for(PxU32 i=0;i<count;++i) {
        const auto command=queue.commands[i];
        if(grid.thread_rank()==0 && (PxU64(command.releaseOffset)+command.releaseCount>queue.releaseCapacity
            || PxU64(command.assignOffset)+command.assignCount>queue.assignCapacity))
            atomicOr(&view.state->error,PxU32(eREGISTRATION_INVALID_STATE));
        grid.sync();
        if(view.state->error)return;
        if(command.releaseCount || command.assignCount)
            transactBatch(view,BatchAccess<Access>{access,command.releaseOffset,command.assignOffset},
                command.releaseCount,command.assignCount);
        // transactBatch commits counters on thread zero after its final barrier.
        // Publish that commit before the next batch's validation reads it.
        grid.sync();
        if(view.state->error)return;
    }
}

// Qualify residency once per kernel specialization when its owner is created.
// There is no ordinary-launch/CPU fallback for an unsupported CUDA environment.
template<class Kernel>
cudaError_t residentBlocksFor(Kernel kernel,int& blocks) {
    int device=0,cooperative=0,major=0,minor=0,sms=0,perSm=0;
    auto result=cudaGetDevice(&device);if(result!=cudaSuccess)return result;
    result=cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device);if(result!=cudaSuccess)return result;
    result=cudaDeviceGetAttribute(&major,cudaDevAttrComputeCapabilityMajor,device);if(result!=cudaSuccess)return result;
    result=cudaDeviceGetAttribute(&minor,cudaDevAttrComputeCapabilityMinor,device);if(result!=cudaSuccess)return result;
    if(!cooperative || !((major==8 && minor==9) || (major==12 && minor==0)))return cudaErrorNotSupported;
    result=cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device);if(result!=cudaSuccess)return result;
    result=cudaOccupancyMaxActiveBlocksPerMultiprocessor(&perSm,kernel,128,0);if(result!=cudaSuccess)return result;
    blocks=perSm*sms;return blocks?cudaSuccess:cudaErrorNotSupported;
}
template<class Access>
cudaError_t residentBlocks(int& blocks) {return residentBlocksFor(transact<Access>,blocks);}
template<class Access>
cudaError_t queueResidentBlocks(int& blocks) {return residentBlocksFor(transactQueue<Access>,blocks);}
template<class Access>
cudaError_t launch(PxgDestructionRegistrationView view,Access access,PxU32 releases,
    PxU32 allocations,int residency,cudaStream_t stream) {
    if(!view.state || !view.batch || !view.entries || !view.freeSlots || residency<=0)return cudaErrorInvalidValue;
    if(!releases && !allocations)return cudaSuccess;
    const PxU64 work=(PxU64(releases)>allocations?releases:allocations)+view.pageSize;
    const PxU64 wanted=(work+127)/128;
    const PxU32 blocks=PxU32(wanted<PxU64(residency)?wanted:residency);
    void* arguments[]={&view,&access,&releases,&allocations};
    return cudaLaunchCooperativeKernel(reinterpret_cast<void*>(transact<Access>),
        dim3(blocks?blocks:1),dim3(128),arguments,0,stream);
}
// Grid size is chosen at initialization for the workload, within measured legal
// residency. Device count controls work; no queue-count readback is required.
template<class Access>
cudaError_t launchQueue(PxgDestructionRegistrationView view,Access access,
    PxgDestructionRegistrationQueue queue,int residency,int blocks,cudaStream_t stream) {
    if(!view.state || !view.batch || !view.entries || !view.freeSlots || !queue.commands
        || !queue.count || blocks<=0 || blocks>residency)return cudaErrorInvalidValue;
    void* arguments[]={&view,&access,&queue};
    return cudaLaunchCooperativeKernel(reinterpret_cast<void*>(transactQueue<Access>),
        dim3(blocks),dim3(128),arguments,0,stream);
}
}}
