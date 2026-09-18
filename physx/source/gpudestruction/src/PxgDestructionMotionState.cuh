// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the native CUDA implementation namespace.
// Validate the complete reservation mapping before writing any native slot.
__global__ void validateReservedBodies(const PxvDestructionBodyRequest* requests,const PxU32* indices,
    PxU32 count,const PxDestructionClusterBodyState* candidates,PxU32 candidateCount,PxU32 capacity,
    PxDestructionBodyAllocationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto r=requests[i];
    if(r.candidateSlot>=candidateCount || indices[i]>=capacity || r.sourceBody>=capacity
        || !r.needsBody || indices[i]==r.sourceBody) {atomicOr(&status->initializationError,1u);return;}
    const auto b=candidates[r.candidateSlot];
    if(b.cluster!=r.cluster || b.sourceBody!=r.sourceBody || b.supported!=r.supported)
        atomicOr(&status->initializationError,1u);
}
__device__ PxgBodySim nativeCandidateState(const PxDestructionClusterBodyState& candidate,const PxgBodySim& source,PxU32 id) {
    auto b=source;
    // Inherit physical settings from the authoritative GPU source, not the CPU
    // allocation placeholder. No velocity/mass/inertia clamps or extra locks.
    if(!candidate.supported)b.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW=b.dynamicLimitsDamping;
    b.linearVelocityXYZ_inverseMassW=make_float4(candidate.linearVelocity[0],candidate.linearVelocity[1],candidate.linearVelocity[2],candidate.inverseMass);
    b.angularVelocityXYZ_maxPenBiasW.x=candidate.angularVelocity[0];
    b.angularVelocityXYZ_maxPenBiasW.y=candidate.angularVelocity[1];
    b.angularVelocityXYZ_maxPenBiasW.z=candidate.angularVelocity[2];
    b.inverseInertiaXYZ_contactReportThresholdW.x=candidate.inverseInertia[0];
    b.inverseInertiaXYZ_contactReportThresholdW.y=candidate.inverseInertia[1];
    b.inverseInertiaXYZ_contactReportThresholdW.z=candidate.inverseInertia[2];
    b.body2World=PxAlignedTransform(candidate.bodyToWorldPosition[0],candidate.bodyToWorldPosition[1],candidate.bodyToWorldPosition[2],
        PxAlignedQuat(candidate.bodyToWorldOrientation[0],candidate.bodyToWorldOrientation[1],candidate.bodyToWorldOrientation[2],candidate.bodyToWorldOrientation[3]));
    const float maxImpulse=b.body2Actor_maxImpulseW.p.w;
    b.body2Actor_maxImpulseW=PxAlignedTransform(candidate.bodyToActorPosition[0],candidate.bodyToActorPosition[1],candidate.bodyToActorPosition[2],
        PxAlignedQuat(candidate.bodyToActorOrientation[0],candidate.bodyToActorOrientation[1],candidate.bodyToActorOrientation[2],candidate.bodyToActorOrientation[3]));
    b.body2Actor_maxImpulseW.p.w=maxImpulse;
    b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w=__uint_as_float(id);
    b.sleepLinVelAccXYZ_freezeCountW=make_float4(0,0,0,0);
    b.sleepAngVelAccXYZ_accelScaleW=make_float4(0,0,0,1);
    b.internalFlags &= PxsRigidBody::eSPECULATIVE_CCD_GPU | PxsRigidBody::eENABLE_GYROSCOPIC_GPU | PxsRigidBody::eRETAIN_ACCELERATION_GPU;
    b.internalFlags |= PxsRigidBody::eDESTRUCTION_MASS_GPU;
    // Trial commands already contributed to provisional motion. The later
    // rewind transaction must restore/distribute commands exactly once; cloning
    // the parent's acceleration accumulator here would duplicate them.
    b.externalLinearAcceleration=make_float4(0,0,0,0);
    b.externalAngularAcceleration=make_float4(0,0,0,0);
    return b;
}
__global__ void initializeReservedBodiesKernel(const PxvDestructionBodyRequest* requests,const PxU32* indices,
    PxU32 count,const PxDestructionClusterBodyState* candidates,PxgBodySim* bodies,
    PxgBodySimVelocities* previous,PxgRigidBodyAcceleration* accelerations,PxDestructionBodyAllocationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || status->initializationError)return;
    const auto candidate=candidates[requests[i].candidateSlot];const PxU32 id=indices[i];
    const auto b=nativeCandidateState(candidate,bodies[candidate.sourceBody],id);
    bodies[id]=b;
    if(previous) {previous[id].linearVelocity=b.linearVelocityXYZ_inverseMassW;previous[id].angularVelocity=b.angularVelocityXYZ_maxPenBiasW;}
    if(accelerations)accelerations[id]={};
}
__global__ void finishBodyInitialization(PxDestructionBodyAllocationStatus* allocation,PxDestructionStageStatus* status) {
    allocation->initialized=allocation->initializationError?0:allocation->reserved;
    if(allocation->initializationError)status->error|=512u;
}
