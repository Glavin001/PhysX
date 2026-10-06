// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the runtime implementation namespace.
// Keep the exact ordinary-host velocity delta beside the checkpoint, without
// changing native integration order or downloading rigid motion to the host.
__global__ void captureHostCommandDeltas(const PxgBodySimVelocityUpdate* updates,PxU32 count,
    PxgBodySimVelocities* commands,PxU32 capacity) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto update=updates[i];
    const PxU32 body=__float_as_uint(update.linearVelocityXYZ_bodySimIndexW.w);
    if(body>=capacity || !(__float_as_uint(update.externalLinearAccelerationXYZ.w)&PxsRigidBody::eHOST_VELOCITY_DELTA_GPU))return;
    commands[body]={update.externalLinearAccelerationXYZ,update.externalAngularAccelerationXYZ};
}
__device__ PxVec3 commandAngularAcceleration(const PxgBodySim& body,const PxVec3& torque) {
    const auto q=body.body2World.getTransform().q;
    const auto d=body.inverseInertiaXYZ_contactReportThresholdW;
    return q.rotate(q.rotateInv(torque).multiply(PxVec3(d.x,d.y,d.z)));
}
__device__ bool commandValuesMatch(const PxVec3& a,const PxVec3& b,float slack=0) {
    return a.isFinite() && b.isFinite() && (a-b).magnitude()<=1e-4f*(1+b.magnitude())+slack;
}
// scale: per cluster, the sum over its chunks of |force| and |impulse| times
// (|chunk world position| + |body COM| + 1 m), a bound on every lever arm.
// Torques from chunk commands are summed from arms taken as differences of
// world positions, and compared with what the host or the previous pass
// applied about the COM: they agree to a few float ulps of |arm| |J|. A light,
// thin body's inverse inertia turns that into more than the absolute 1e-4
// tolerance -- a 3.5 kg Vehicle2 carrier remnant (inverse inertia 471) was
// rejected on the trial at limit 1 (physx_native_chunk_loads_thin_remnant),
// a 7 kg part on a corrected pass at limit 8. The angular channels allow
// that rounding bound; a misplaced or duplicated command errs by a full lever
// arm times the command, orders of magnitude more, and the linear channels
// stay exact. Null keeps the plain tolerance.
__device__ bool chunkCommandSumsMatch(const PxVec3& force,const PxVec3& torque,const PxVec3& impulse,
    const PxVec3& angularImpulse,const PxgBodySim& body,const PxgBodySimVelocities& delta,const float* scale=nullptr) {
    const auto linear=body.externalLinearAcceleration,angular=body.externalAngularAcceleration;
    const auto dv=delta.linearVelocity,dw=delta.angularVelocity;
    float forceSlack=0,impulseSlack=0;
    if(scale) {
        const auto d=body.inverseInertiaXYZ_contactReportThresholdW;
        const float inverseInertia=fmaxf(fabsf(d.x),fmaxf(fabsf(d.y),fabsf(d.z)));
        forceSlack=16*1.1920929e-7f*inverseInertia*scale[0];impulseSlack=16*1.1920929e-7f*inverseInertia*scale[1];
    }
    return commandValuesMatch(force*body.linearVelocityXYZ_inverseMassW.w,PxVec3(linear.x,linear.y,linear.z))
        && commandValuesMatch(commandAngularAcceleration(body,torque),PxVec3(angular.x,angular.y,angular.z),forceSlack)
        && commandValuesMatch(impulse*body.linearVelocityXYZ_inverseMassW.w,PxVec3(dv.x,dv.y,dv.z))
        && commandValuesMatch(commandAngularAcceleration(body,angularImpulse),PxVec3(dw.x,dw.y,dw.z),impulseSlack);
}
// The host's chunk commands, summed per cluster: force, torque about the
// body COM, impulse and angular impulse (sums[4c..4c+3]). One thread per
// chunk, so the cost is the chunk count, not clusters x chunks: the per-cluster
// loop over every chunk it replaced cost 5.9 ms a tick on a city with five
// destructible cars (Metal, CUMETAL_TRACE_GPU, 2026-10-03). Zero loads add
// nothing; atomic order changes only the last bits, inside the 1e-4 tolerance.
__global__ void sumChunkCommandsByCluster(const PxDestructionStressChunk* chunks,PxU32 n,
    const PxDestructionStressCluster* clusters,PxU32 count,const PxDestructionChunkLoad* loads,
    const PxgBodySim* checkpoint,PxU32 checkpointCount,PxVec3* sums,float* scales=nullptr) {
    const PxU32 j=blockIdx.x*blockDim.x+threadIdx.x;if(j>=n || !checkpoint)return;
    const PxU32 c=chunks[j].cluster;if(c>=count)return;
    const auto load=loads[j];
    if(load.force.isZero() && load.torque.isZero() && load.impulse.isZero() && load.angularImpulse.isZero())return;
    const PxU32 id=clusters[c].body;if(id>=checkpointCount)return;
    const auto& source=checkpoint[id];
    const auto actor=source.body2World.getTransform()*source.body2Actor_maxImpulseW.getTransform().getInverse();
    const PxVec3 world=actor.transform(chunks[j].position);
    const PxVec3 arm=world-source.body2World.getTransform().p;
    const PxVec3 values[4]={load.force,load.torque+arm.cross(load.force),load.impulse,load.angularImpulse+arm.cross(load.impulse)};
    for(PxU32 k=0;k<4;++k){PxVec3& s=sums[4*c+k];atomicAdd(&s.x,values[k].x);atomicAdd(&s.y,values[k].y);atomicAdd(&s.z,values[k].z);}
    if(scales) {
        const float reach=world.magnitude()+source.body2World.getTransform().p.magnitude()+1;
        atomicAdd(scales+2*c,load.force.magnitude()*reach);atomicAdd(scales+2*c+1,load.impulse.magnitude()*reach);
    }
}
// The same commands summed per correction candidate: by the chunk's cluster
// in the trial topology (sums[4k..4k+3], k that cluster's root chunk), about
// the SOURCE body's COM; prepareCorrectionBodyInputs moves the torques to the
// candidate's COM. Original source membership is still live during
// preparation, and a candidate's chunks all come from its root's source
// cluster (clusters only split). This replaced a loop over every chunk per
// candidate, up to 4.9 ms on a meteor's correction tick (Metal, 2026-10-03).
__global__ void sumCorrectionCommands(const PxDestructionStressChunk* chunks,PxU32 n,const PxDestructionStressCluster* clusters,
    const PxU32* chunkCluster,const PxU32* affected,const PxgBodySim* checkpoint,PxU32 checkpointCount,
    const PxDestructionChunkLoad* loads,PxVec3* sums,const NativePreparationInputs* inputs=nullptr) {
    if(inputs){checkpoint=inputs->checkpoint;checkpointCount=inputs->checkpointCount;loads=inputs->chunkLoads;}
    const PxU32 j=blockIdx.x*blockDim.x+threadIdx.x;if(j>=n || !loads || !checkpoint)return;
    const PxU32 c=chunks[j].cluster,k=chunkCluster[j];if(k>=n || chunks[k].cluster!=c || !affected[c])return;
    const auto load=loads[j];
    if(load.force.isZero() && load.torque.isZero() && load.impulse.isZero() && load.angularImpulse.isZero())return;
    const PxU32 id=clusters[c].body;if(id>=checkpointCount)return;
    const auto& source=checkpoint[id];
    const auto actor=source.body2World.getTransform()*source.body2Actor_maxImpulseW.getTransform().getInverse();
    const PxVec3 arm=actor.transform(chunks[j].position)-source.body2World.getTransform().p;
    const PxVec3 values[4]={load.force,load.torque+arm.cross(load.force),load.impulse,load.angularImpulse+arm.cross(load.impulse)};
    for(PxU32 m=0;m<4;++m){PxVec3& s=sums[4*k+m];atomicAdd(&s.x,values[m].x);atomicAdd(&s.y,values[m].y);atomicAdd(&s.z,values[m].z);}
}
__global__ void validateChunkCommands(const PxDestructionStressCluster* clusters,PxU32 count,const PxVec3* sums,
    const PxgBodySim* checkpoint,PxU32 checkpointCount,const PxgBodySimVelocities* commands,PxDestructionStageStatus* status,
    const float* scales=nullptr) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 id=clusters[i].body;
    if(!checkpoint || id>=checkpointCount
        || !chunkCommandSumsMatch(sums[4*i],sums[4*i+1],sums[4*i+2],sums[4*i+3],checkpoint[id],commands[id],scales?scales+2*i:nullptr))
        atomicOr(&status->error,16384u);
}
__device__ bool correctionVelocity(const float* center,const PxgBodySim& source,
    const float4& v,const float4& w,float* linear,float* angular) {
    const double r[3]={double(center[0])-source.body2World.p.x,double(center[1])-source.body2World.p.y,double(center[2])-source.body2World.p.z};
    const double velocity[3]={v.x+double(w.y)*r[2]-double(w.z)*r[1],v.y+double(w.z)*r[0]-double(w.x)*r[2],v.z+double(w.x)*r[1]-double(w.y)*r[0]};
    const double spin[3]={w.x,w.y,w.z};
    for(unsigned k=0;k<3;++k)if(!destructionBody::motionValue(velocity[k],linear[k]) || !destructionBody::motionValue(spin[k],angular[k]))return false;
    return true;
}
__device__ bool correctionMotion(const PxDestructionClusterBodyState& candidate,
    const PxDestructionClusterMassProperties& mass,const PxgBodySim& source,PxDestructionClusterBodyState& output) {
    const auto world=source.body2World.getTransform(),local=source.body2Actor_maxImpulseW.getTransform();
    if(!world.isValid() || !local.isValid())return false;
    double wq[4]={world.q.x,world.q.y,world.q.z,world.q.w},lq[4]={local.q.x,local.q.y,local.q.z,local.q.w};
    double wn=0,ln=0;for(unsigned k=0;k<4;++k){wn+=wq[k]*wq[k];ln+=lq[k]*lq[k];}
    for(unsigned k=0;k<4;++k){wq[k]/=sqrt(wn);lq[k]/=sqrt(ln);}
    const double actor[4]={-wq[3]*lq[0]+wq[0]*lq[3]-wq[1]*lq[2]+wq[2]*lq[1],
        -wq[3]*lq[1]+wq[0]*lq[2]+wq[1]*lq[3]-wq[2]*lq[0],
        -wq[3]*lq[2]-wq[0]*lq[1]+wq[1]*lq[0]+wq[2]*lq[3],
        wq[3]*lq[3]+wq[0]*lq[0]+wq[1]*lq[1]+wq[2]*lq[2]};
    // Use a local COM difference instead of subtracting large world origins.
    const double offset[3]={mass.center[0]-local.p.x,mass.center[1]-local.p.y,mass.center[2]-local.p.z};
    double delta[3];destructionBody::rotate(actor,offset,delta);output=candidate;
    for(unsigned k=0;k<3;++k)if(!destructionBody::motionValue(double(world.p[k])+delta[k],output.bodyToWorldPosition[k]))return false;
    double principal[4],norm=0;for(unsigned k=0;k<4;++k){principal[k]=candidate.bodyToActorOrientation[k];norm+=principal[k]*principal[k];}
    if(!isfinite(norm) || fabs(norm-1)>1e-5)return false;
    for(unsigned k=0;k<4;++k)principal[k]/=sqrt(norm);
    const double q[4]={actor[3]*principal[0]+actor[0]*principal[3]+actor[1]*principal[2]-actor[2]*principal[1],
        actor[3]*principal[1]-actor[0]*principal[2]+actor[1]*principal[3]+actor[2]*principal[0],
        actor[3]*principal[2]+actor[0]*principal[1]-actor[1]*principal[0]+actor[2]*principal[3],
        actor[3]*principal[3]-actor[0]*principal[0]-actor[1]*principal[1]-actor[2]*principal[2]};
    for(unsigned k=0;k<4;++k)output.bodyToWorldOrientation[k]=float(q[k]);
    return correctionVelocity(output.bodyToWorldPosition,source,source.linearVelocityXYZ_inverseMassW,
        source.angularVelocityXYZ_maxPenBiasW,output.linearVelocity,output.angularVelocity);
}
__global__ void prepareCorrectionBodyInputs(const PxDestructionClusterBodyState* candidates,const PxU32* targets,
    PxU32 chunkCount,PxDestructionTopologyDeviceView topology,const PxDestructionStressChunk* chunks,
    const PxU32* affected,const PxgBodySim* checkpoint,const PxgBodySimVelocities* previous,PxU32 checkpointCount,PxU32 bodyCapacity,
    const PxDestructionCollisionPreparationStatus* collision,
    PxDestructionCorrectionBody* output,PxDestructionCorrectionPreparationStatus* status,
    const PxDestructionChunkLoad* loads,const PxgBodySimVelocities* commands,const PxVec3* sums,
    PxgBodySimVelocities* deltas,const NativePreparationInputs* inputs=nullptr) {
    if(inputs){checkpoint=inputs->checkpoint;previous=inputs->previous;loads=inputs->chunkLoads;commands=inputs->commands;
        checkpointCount=inputs->checkpointCount;bodyCapacity=inputs->bodyCapacity;}
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=chunkCount)return;
    output[i]={};output[i].targetBody=PX_INVALID_U32;
    // Always overwrite the compaction sentinel, including a rejected prerequisite.
    if(!collision->valid || i>=topology.status->clusterCount)return;
    const auto candidate=candidates[i];
    if(candidate.cluster>=chunkCount || topology.activeClusters[i]!=candidate.cluster){atomicOr(&status->error,2u);return;}
    if(!affected[chunks[candidate.cluster].cluster])return;
    if(!checkpoint || candidate.sourceBody>=checkpointCount){atomicOr(&status->error,1u);return;}
    auto source=checkpoint[candidate.sourceBody];
    if(__float_as_uint(source.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w)!=candidate.sourceBody)
        {atomicOr(&status->error,1u);return;}
    if(targets[i]>=bodyCapacity){atomicOr(&status->error,2u);return;}
    // The checkpoint is after ordinary host commands. Undo their velocity
    // increment on this source before distributing the original local impulses.
    if(loads) {
        const auto delta=commands[candidate.sourceBody];
        source.linearVelocityXYZ_inverseMassW.x-=delta.linearVelocity.x;
        source.linearVelocityXYZ_inverseMassW.y-=delta.linearVelocity.y;
        source.linearVelocityXYZ_inverseMassW.z-=delta.linearVelocity.z;
        source.angularVelocityXYZ_maxPenBiasW.x-=delta.angularVelocity.x;
        source.angularVelocityXYZ_maxPenBiasW.y-=delta.angularVelocity.y;
        source.angularVelocityXYZ_maxPenBiasW.z-=delta.angularVelocity.z;
    }
    if(!correctionMotion(candidate,topology.clusters[candidate.cluster],source,output[i].body))
        {atomicOr(&status->error,4u);return;}
    if(previous) {
        const auto p=previous[candidate.sourceBody];float linear[3],angular[3];
        if(!correctionVelocity(output[i].body.bodyToWorldPosition,source,p.linearVelocity,p.angularVelocity,linear,angular))
            {atomicOr(&status->error,4u);return;}
    }
    output[i].targetBody=targets[i];
    if(loads) {
        // sumCorrectionCommands' torques are about the source COM; move them
        // to the candidate's COM (parallel axis: (source - center) x force).
        const PxVec3 center(output[i].body.bodyToWorldPosition[0],output[i].body.bodyToWorldPosition[1],output[i].body.bodyToWorldPosition[2]);
        const PxVec3 shift=source.body2World.getTransform().p-center;
        const PxVec3* sum=sums+4*size_t(candidate.cluster);
        const auto recipient=nativeCandidateState(output[i].body,source,targets[i]);
        const auto linear=sum[0]*recipient.linearVelocityXYZ_inverseMassW.w,angular=commandAngularAcceleration(recipient,sum[1]+shift.cross(sum[0]));
        if(!linear.isFinite() || !angular.isFinite()){atomicOr(&status->error,8u);return;}
        for(PxU32 k=0;k<3;++k){output[i].linearAcceleration[k]=linear[k];output[i].angularAcceleration[k]=angular[k];}
        const auto dv=sum[2]*recipient.linearVelocityXYZ_inverseMassW.w,dw=commandAngularAcceleration(recipient,sum[3]+shift.cross(sum[2]));
        if(!dv.isFinite() || !dw.isFinite()){atomicOr(&status->error,8u);return;}
        for(PxU32 k=0;k<3;++k){output[i].body.linearVelocity[k]+=dv[k];output[i].body.angularVelocity[k]+=dw[k];}
        // The share just applied is this candidate's command delta. Another
        // corrected pass of the same tick splits from a checkpoint holding it
        // (carryCorrectionCommands), and must undo exactly this, not the
        // source's pre-split delta.
        if(deltas)deltas[candidate.cluster]={make_float4(dv.x,dv.y,dv.z,0),make_float4(dw.x,dw.y,dw.z,0)};
    }
}
// A corrected checkpoint of the same tick (start of tick plus the fragments
// just installed) keeps every other body's command delta and gives each
// installed owner the share prepareCorrectionBodyInputs applied to it. Its
// chunk commands then match its rigid inputs exactly as the trial's did.
__global__ void carryCorrectionCommands(const PxDestructionCorrectionBody* inputs,PxU32 count,
    const PxgBodySimVelocities* deltas,PxgBodySimVelocities* commands,PxU32 capacity) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto input=inputs[i];
    if(input.targetBody<capacity)commands[input.targetBody]=deltas[input.body.cluster];
}
__global__ void inspectCorrectionSourceLoads(const PxDestructionStressCluster* clusters,const PxU32* affected,PxU32 count,
    const PxgBodySim* checkpoint,PxU32 checkpointCount,const PxDestructionCollisionPreparationStatus* collision,
    PxDestructionCorrectionPreparationStatus* status,const PxVec3* sums,
    const PxDestructionChunkLoad* loads,const PxgBodySimVelocities* commands,const float* scales,const NativePreparationInputs* inputs=nullptr) {
    if(inputs){checkpoint=inputs->checkpoint;checkpointCount=inputs->checkpointCount;count=inputs->clusterCount;loads=inputs->chunkLoads;commands=inputs->commands;
        scales=inputs->commandScales;}
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(!collision->valid || i>=count || !affected[i])return;
    const PxU32 id=clusters[i].body;if(!checkpoint || id>=checkpointCount){atomicOr(&status->error,1u);return;}
    const auto body=checkpoint[id];const auto a=body.externalLinearAcceleration,b=body.externalAngularAcceleration;
    if(!isfinite(a.x) || !isfinite(a.y) || !isfinite(a.z) || !isfinite(b.x) || !isfinite(b.y) || !isfinite(b.z))
        {atomicOr(&status->error,8u);return;}
    if(loads) {
        // This pass's per-cluster sums (sumChunkCommandsByCluster, same
        // checkpoint, loads and original membership).
        if(!chunkCommandSumsMatch(sums[4*i],sums[4*i+1],sums[4*i+2],sums[4*i+3],body,commands[id],scales?scales+2*i:nullptr))
            atomicAdd(&status->loadedSources,1u);
    } else if(a.x!=0 || a.y!=0 || a.z!=0 || b.x!=0 || b.y!=0 || b.z!=0)atomicAdd(&status->loadedSources,1u);
}
struct HasCorrectionBody {
    __host__ __device__ bool operator()(const PxDestructionCorrectionBody& b) const {return b.targetBody!=PX_INVALID_U32;}
};
__global__ void finishCorrectionPreparation(PxDestructionCorrectionPreparationStatus* correction,
    const PxDestructionCollisionPreparationStatus* collision,PxU64 checkpointGeneration,PxDestructionStageStatus* stage,
    const NativePreparationInputs* inputs=nullptr) {
    if(inputs)checkpointGeneration=inputs->checkpointGeneration;
    correction->generation=collision->generation;correction->checkpointGeneration=checkpointGeneration;
    if(!collision->valid) {
        correction->error|=32u;correction->valid=0;
        return; // The collision stage already reported the originating error.
    }
    correction->valid=!correction->error;
    if(correction->error)stage->error|=2048u;
}
// Reuse the validated, stable GPU correction work set for the temporary CPU
// owner bridge. No physical fields cross this boundary, and no unchanged owner
// is read back merely because another structure fractured.
__global__ void gatherCorrectionOwnerMetadata(const PxDestructionCorrectionBody* corrections,PxU32 count,
    const PxU32* candidateSlots,const PxvDestructionBodyRequest* candidates,
    PxvDestructionBodyRequest* requests,PxU32* targets) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto correction=corrections[i];
    requests[i]=candidates[candidateSlots[correction.body.cluster]];
    targets[i]=correction.targetBody;
}
// deferred (fragmentGravity with chunk commands, on a pass that re-solves): a
// free fragment of a weightless source receives its share of the source's
// commands, which already carry its weight for this tick (Vehicle2 describes
// a weightless carrier's gravity per chunk). It stays weightless until the
// tick is complete (clearDeferredGravity); scene gravity on top of the share
// applied its weight twice on the split tick.
__global__ void installCorrectionBodyInputs(const PxDestructionCorrectionBody* inputs,PxU32 count,const PxgBodySim* checkpoint,
    const PxgBodySimVelocities* oldPrevious,PxgBodySim* bodies,PxgBodySimVelocities* previous,PxgRigidBodyAcceleration* accelerations,
    PxU32* deferred=nullptr,PxU32* deferredCount=nullptr,PxU32 deferredCapacity=0) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto input=inputs[i];const auto source=checkpoint[input.body.sourceBody];
    auto b=nativeCandidateState(input.body,source,input.targetBody);
    if(deferred && !b.disableGravity && source.disableGravity) {
        const PxU32 slot=atomicAdd(deferredCount,1u);
        if(slot<deferredCapacity){deferred[slot]=input.targetBody;b.disableGravity=source.disableGravity;}
    }
    b.externalLinearAcceleration=make_float4(input.linearAcceleration[0],input.linearAcceleration[1],input.linearAcceleration[2],0);
    b.externalAngularAcceleration=make_float4(input.angularAcceleration[0],input.angularAcceleration[1],input.angularAcceleration[2],0);
    bodies[input.targetBody]=b;
    if(previous) {
        const auto old=oldPrevious[input.body.sourceBody];float linear[3],angular[3];
        correctionVelocity(input.body.bodyToWorldPosition,source,old.linearVelocity,old.angularVelocity,linear,angular);
        previous[input.targetBody].linearVelocity=make_float4(linear[0],linear[1],linear[2],b.linearVelocityXYZ_inverseMassW.w);
        previous[input.targetBody].angularVelocity=make_float4(angular[0],angular[1],angular[2],b.angularVelocityXYZ_maxPenBiasW.w);
    }
    if(accelerations)accelerations[input.targetBody]={};
}
// End of the tick: fragments kept weightless by installCorrectionBodyInputs
// get the scene gravity fragmentGravity gives them.
__global__ void clearDeferredGravity(const PxU32* deferred,const PxU32* count,PxU32 capacity,PxgBodySim* bodies,PxU32 bodyCapacity) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=min(*count,capacity))return;
    const PxU32 id=deferred[i];if(id<bodyCapacity)bodies[id].disableGravity=0;
}
