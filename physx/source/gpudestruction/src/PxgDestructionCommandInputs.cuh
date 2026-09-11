// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the runtime CUDA implementation namespace.
__global__ void beginCommandInputs(PxgDestructionCommandInputStatus* status,PxU64 generation,PxU32 count) {
    *status={generation,count,0};
}
__global__ void captureCommandInputsKernel(const PxgBodySim* bodies,PxU32 bodyCount,
    const PxgBodySimVelocityUpdate* updates,PxU32 count,PxgDestructionCommandInput* records,
    PxgDestructionCommandInputStatus* status,PxU64* loadedGenerations=nullptr) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto update=updates[i];PxgDestructionCommandInput record{};
    record.body=__float_as_uint(update.linearVelocityXYZ_bodySimIndexW.w);
    record.flags=__float_as_uint(update.externalLinearAccelerationXYZ.w);
    // Other uploads are not an invertible command history. Never label an
    // already modified host velocity as a command-free native input.
    if(!(record.flags&PxsRigidBody::eHOST_VELOCITY_DELTA_GPU)){records[i]=record;return;}
    if(record.body>=bodyCount){record.kind=2;records[i]=record;atomicOr(&status->error,1u);return;}
    const auto& body=bodies[record.body];
    if(__float_as_uint(body.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w)!=record.body) {
        record.kind=2;records[i]=record;atomicOr(&status->error,2u);return;
    }
    const auto linear=body.linearVelocityXYZ_inverseMassW,angular=body.angularVelocityXYZ_maxPenBiasW;
    const auto dl=update.externalLinearAccelerationXYZ,da=update.externalAngularAccelerationXYZ;
    const float values[12]={linear.x,linear.y,linear.z,angular.x,angular.y,angular.z,dl.x,dl.y,dl.z,da.x,da.y,da.z};
    for(PxU32 k=0;k<12;++k)if(!isfinite(values[k])) {
        record.kind=2;records[i]=record;atomicOr(&status->error,4u);return;
    }
    for(PxU32 k=0;k<3;++k) {
        record.linearBefore[k]=values[k];record.angularBefore[k]=values[k+3];
        record.linearDelta[k]=values[k+6];record.angularDelta[k]=values[k+9];
    }
    record.kind=1;records[i]=record;
    // Sparse epoch marking: no body-capacity clear on ordinary steps. The
    // consumer combines this with accumulator loads and counts each source once.
    if(loadedGenerations && (dl.x!=0 || dl.y!=0 || dl.z!=0 || da.x!=0 || da.y!=0 || da.z!=0))
        atomicExch(reinterpret_cast<unsigned long long*>(loadedGenerations+record.body),
            static_cast<unsigned long long>(status->generation));
}
