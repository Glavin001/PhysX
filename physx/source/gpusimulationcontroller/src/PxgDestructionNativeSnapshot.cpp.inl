// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Physical observations only. Restore writes fresh host bodies; ordinary PhysX
// insertion/upload recreates GPU state, contacts, sleep filters and solver storage.
namespace physx {
bool PxgSimulationController::exportNativeSnapshot(const PxU32* indices,PxU32 count,void* data,PxU32 stride) const
{
    if(!indices || !data || stride!=sizeof(PxgDestructionNativeSnapshot) || mDestructionError)return false;
    PxScopedCudaLock lock(*mCudaContextManager);auto* cuda=mCudaContextManager->getCudaContext();
    if(cuda->isInAbortMode() || cuda->streamSynchronize(mSimulationCore->getStream())!=CUDA_SUCCESS)return false;
    auto* out=static_cast<PxgDestructionNativeSnapshot*>(data);
    const auto* bodies=mSimulationCore->getBodySimBufferDevicePtr().getPointer();
    for(PxU32 i=0;i<count;++i){const PxU32 id=indices[i];
        if(id>=mBodySimManager.mBodies.size() || !mBodySimManager.mBodies[id])return false;
        const auto& r=*static_cast<PxsRigidBody*>(mBodySimManager.mBodies[id]);const auto& c=r.getCore();
        auto& v=out[i];PxMemZero(&v,sizeof(v));
        v.bodyToWorld=c.body2World;v.bodyToActor=c.getBody2Actor();
        v.linearVelocity=c.linearVelocity;v.angularVelocity=c.angularVelocity;
        v.inverseMass=c.inverseMass;v.inverseInertia=c.inverseInertia;v.wakeCounter=c.wakeCounter;
        v.limitsDamping=PxVec4(c.maxLinearVelocitySq,c.maxAngularVelocitySq,c.linearDamping,c.angularDamping);
        v.dynamicLimitsDamping=r.mGpuDynamicLimitsDamping;
        v.maxPenBias=c.maxPenBias;v.maxImpulse=c.maxContactImpulse;v.contactThreshold=c.contactReportThreshold;
        v.offsetSlop=c.offsetSlop;v.sleepThreshold=c.sleepThreshold;v.freezeThreshold=c.freezeThreshold;
        v.solverIterations=c.solverIterationCounts;v.lockFlags=c.lockFlags;v.disableGravity=c.disableGravity;
        if(!(r.mInternalFlags & PxsRigidBody::eFIRST_BODY_COPY_GPU)){
            if(id>=mSimulationCore->getBodySimStorageCapacity() || !bodies)return false;
            PxgBodySim b;
            if(cuda->memcpyDtoH(&b,CUdeviceptr(bodies+id),sizeof(b))!=CUDA_SUCCESS)return false;
            const auto xyz=[](const float4& x){return PxVec3(x.x,x.y,x.z);};
            const auto transform=[](const PxAlignedTransform& x){return PxTransform(PxVec3(x.p.x,x.p.y,x.p.z),PxQuat(x.q.q.x,x.q.q.y,x.q.q.z,x.q.q.w));};
            v.bodyToWorld=transform(b.body2World);v.bodyToActor=transform(b.body2Actor_maxImpulseW);
            v.linearVelocity=xyz(b.linearVelocityXYZ_inverseMassW);v.angularVelocity=xyz(b.angularVelocityXYZ_maxPenBiasW);
            v.inverseMass=b.linearVelocityXYZ_inverseMassW.w;v.inverseInertia=xyz(b.inverseInertiaXYZ_contactReportThresholdW);
            v.wakeCounter=b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.y;
            const auto d=b.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW;
            v.limitsDamping=PxVec4(d.x,d.y,d.z,d.w);
            const auto dynamic=b.dynamicLimitsDamping;v.dynamicLimitsDamping=PxVec4(dynamic.x,dynamic.y,dynamic.z,dynamic.w);
            v.maxPenBias=b.angularVelocityXYZ_maxPenBiasW.w;v.maxImpulse=b.body2Actor_maxImpulseW.p.w;
            v.contactThreshold=b.inverseInertiaXYZ_contactReportThresholdW.w;v.offsetSlop=b.offsetSlop;
            v.sleepThreshold=b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.z;
            v.freezeThreshold=b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.x;
            v.solverIterations=b.solverConfig.x;v.lockFlags=b.lockFlags;v.disableGravity=b.disableGravity;
        }
    }
    return true;
}
bool PxgSimulationController::importNativeSnapshot(const PxU32* indices,PxU32 count,const void* data,PxU32 stride)
{
    if(!indices || !data || stride!=sizeof(PxgDestructionNativeSnapshot) || mDestructionError)return false;
    const auto* in=static_cast<const PxgDestructionNativeSnapshot*>(data);
    for(PxU32 i=0;i<count;++i){const auto id=indices[i];const auto& v=in[i];
        if(id>=mBodySimManager.mBodies.size() || !mBodySimManager.mBodies[id]
            || !(static_cast<PxsRigidBody*>(mBodySimManager.mBodies[id])->mInternalFlags & PxsRigidBody::eFIRST_BODY_COPY_GPU)
            || !v.bodyToWorld.isValid() || !v.bodyToActor.isValid() || !v.linearVelocity.isFinite() || !v.angularVelocity.isFinite()
            || !v.inverseInertia.isFinite() || v.inverseInertia.minElement()<0 || !PxIsFinite(v.inverseMass) || v.inverseMass<0
            || !v.limitsDamping.isFinite() || !v.dynamicLimitsDamping.isFinite() || !PxIsFinite(v.wakeCounter) || v.wakeCounter<0
            || !PxIsFinite(v.maxPenBias) || !PxIsFinite(v.maxImpulse) || !PxIsFinite(v.contactThreshold)
            || !PxIsFinite(v.offsetSlop) || !PxIsFinite(v.sleepThreshold) || !PxIsFinite(v.freezeThreshold)
            || v.active>1 || v.disableGravity>1 || v.lockFlags>63 || v.solverIterations>65535)return false;
    }
    for(PxU32 i=0;i<count;++i){auto& r=*static_cast<PxsRigidBody*>(mBodySimManager.mBodies[indices[i]]);
        auto& c=r.getCore();const auto& v=in[i];
        c.body2World=v.bodyToWorld;c.setBody2Actor(v.bodyToActor);
        c.linearVelocity=v.linearVelocity;c.angularVelocity=v.angularVelocity;c.inverseMass=v.inverseMass;c.inverseInertia=v.inverseInertia;
        c.wakeCounter=v.wakeCounter;c.maxLinearVelocitySq=v.limitsDamping.x;c.maxAngularVelocitySq=v.limitsDamping.y;
        c.linearDamping=v.limitsDamping.z;c.angularDamping=v.limitsDamping.w;
        c.maxPenBias=v.maxPenBias;c.maxContactImpulse=v.maxImpulse;c.contactReportThreshold=v.contactThreshold;
        c.offsetSlop=v.offsetSlop;c.sleepThreshold=v.sleepThreshold;c.freezeThreshold=v.freezeThreshold;
        c.solverIterationCounts=PxU16(v.solverIterations);c.lockFlags=PxRigidDynamicLockFlags(PxU8(v.lockFlags));c.disableGravity=PxU8(v.disableGravity);
        r.mLastTransform=v.bodyToWorld;r.mGpuDynamicLimitsDamping=v.dynamicLimitsDamping;
        // Keep normal first-insertion flags and initialized sleep filters. No
        // previous impulses, contact state or CPU/GPU scheduling flags restored.
    }
    return true;
}
} // namespace physx
