// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the runtime implementation namespace.
// Ordered begin -> capture -> finish before the input checkpoint ready event.
// Source arrays and output capacity are owned by the configured runtime.
__global__ void beginInputOwnership(PxgDestructionInputOwnership* status,
    PxDestructionTopologyDeviceView topology,PxU32 clusters,PxU32 bodyCount,PxU64 generation) {
    *status={};
    status->inputGeneration=generation;status->topologyGeneration=topology.status->generation;
    status->chunkCount=topology.chunkCount;status->bodyCount=bodyCount;
    if(!generation || !bodyCount || clusters!=topology.status->clusterCount || clusters>topology.chunkCount ||
        topology.status->invalidEdit || topology.status->slotError)status->error=1;
}
__global__ void captureInputOwners(PxDestructionTopologyDeviceView topology,
    const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,PxU32 clusterCount,
    const PxgBodySim* bodies,PxgDestructionInputOwner* owners,PxgDestructionInputOwnership* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=topology.chunkCount)return;
    PxgDestructionInputOwner owner{0,PX_INVALID_U32,PX_INVALID_U32,PX_INVALID_U32,0};
    owners[i]=owner;
    if(!topology.activeChunks[i])return;
    const PxU32 root=topology.chunkCluster[i],cluster=chunks[i].cluster;
    if(topology.activeChunks[i]!=1 || root>=topology.chunkCount || cluster>=clusterCount ||
        cluster>=topology.status->clusterCount || topology.activeClusters[cluster]!=root) {
        atomicOr(&status->error,2u);return;
    }
    const PxU32 slot=topology.clusterSlots[root],body=clusters[cluster].body;
    if(slot>=topology.slotCapacity || topology.slotRoots[slot]!=root || body>=status->bodyCount) {
        atomicOr(&status->error,4u);return;
    }
    if(__float_as_uint(bodies[body].freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w)!=body) {
        atomicOr(&status->error,8u);return;
    }
    owner={topology.slotGenerations[slot],body,root,slot,1};owners[i]=owner;
}
__global__ void finishInputOwnership(PxgDestructionInputOwnership* status) {
    status->valid=status->error==0;
}
