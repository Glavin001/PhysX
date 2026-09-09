// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Final CPU observation consumes existing cluster mass frames and live GPU
// motion. Epochs track changed owners, not a second physical-state mirror.
struct HasChangedProperties {
    const PxU32* roots;const PxU64* epochs;const PxDestructionStageStatus* status;
    __device__ bool operator()(PxU32 slot)const{return epochs[roots[slot]]==status->frame;}
};
__global__ void gatherFinalProperties(const PxU32* slots,const PxU32* count,PxU32 capacity,
    const PxDestructionClusterBodyState* candidates,const PxDestructionStressCluster* clusters,
    const PxgBodySim* bodies,PxDestructionCorrectionBody* observations,PxDestructionStageStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=capacity)return;
    observations[i]={}; // Fully initialize the bounded host observation tail.
    if(*count>capacity){if(!i)atomicOr(&status->error,2048u);return;}
    if(i>=*count || status->error)return;
    const PxU32 slot=slots[i];PxDestructionCorrectionBody out{};
    out.body=candidates[slot];out.targetBody=clusters[slot].body;
    const auto b=bodies[out.targetBody];const auto p=b.body2World.getTransform();
    for(PxU32 k=0;k<3;++k)out.body.bodyToWorldPosition[k]=p.p[k];
    out.body.bodyToWorldOrientation[0]=p.q.x;out.body.bodyToWorldOrientation[1]=p.q.y;
    out.body.bodyToWorldOrientation[2]=p.q.z;out.body.bodyToWorldOrientation[3]=p.q.w;
    out.body.linearVelocity[0]=b.linearVelocityXYZ_inverseMassW.x;
    out.body.linearVelocity[1]=b.linearVelocityXYZ_inverseMassW.y;
    out.body.linearVelocity[2]=b.linearVelocityXYZ_inverseMassW.z;
    out.body.angularVelocity[0]=b.angularVelocityXYZ_maxPenBiasW.x;
    out.body.angularVelocity[1]=b.angularVelocityXYZ_maxPenBiasW.y;
    out.body.angularVelocity[2]=b.angularVelocityXYZ_maxPenBiasW.z;
    observations[i]=out;
}
