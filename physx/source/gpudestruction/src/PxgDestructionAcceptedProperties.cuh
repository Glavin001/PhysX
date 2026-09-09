// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Explicit accepted CPU observation. Retain authored mass/principal-frame data
// while replacing provisional corrected motion with the actual accepted result.
__global__ void gatherAcceptedProperties(const PxDestructionCorrectionBody* inputs,PxU32 count,
    const PxgBodySim* bodies,PxDestructionCorrectionBody* observations,const PxDestructionStageStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    auto out=inputs[i];
    if(!status->error) {
        const auto b=bodies[out.targetBody];
        const auto p=b.body2World.getTransform();
        for(PxU32 k=0;k<3;++k)out.body.bodyToWorldPosition[k]=p.p[k];
        out.body.bodyToWorldOrientation[0]=p.q.x;out.body.bodyToWorldOrientation[1]=p.q.y;
        out.body.bodyToWorldOrientation[2]=p.q.z;out.body.bodyToWorldOrientation[3]=p.q.w;
        out.body.linearVelocity[0]=b.linearVelocityXYZ_inverseMassW.x;
        out.body.linearVelocity[1]=b.linearVelocityXYZ_inverseMassW.y;
        out.body.linearVelocity[2]=b.linearVelocityXYZ_inverseMassW.z;
        out.body.angularVelocity[0]=b.angularVelocityXYZ_maxPenBiasW.x;
        out.body.angularVelocity[1]=b.angularVelocityXYZ_maxPenBiasW.y;
        out.body.angularVelocity[2]=b.angularVelocityXYZ_maxPenBiasW.z;
    }
    observations[i]=out;
}
