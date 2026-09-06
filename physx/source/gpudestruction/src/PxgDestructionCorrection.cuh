// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the runtime implementation namespace.
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
    PxDestructionCorrectionBody* output,PxDestructionCorrectionPreparationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=chunkCount)return;
    output[i]={};output[i].targetBody=PX_INVALID_U32;
    if(i>=topology.status->clusterCount)return;
    const auto candidate=candidates[i];
    if(candidate.cluster>=chunkCount || topology.activeClusters[i]!=candidate.cluster){atomicOr(&status->error,2u);return;}
    if(!affected[chunks[candidate.cluster].cluster])return;
    if(candidate.sourceBody>=checkpointCount){atomicOr(&status->error,1u);return;}
    const auto source=checkpoint[candidate.sourceBody];
    if(__float_as_uint(source.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w)!=candidate.sourceBody)
        {atomicOr(&status->error,1u);return;}
    if(targets[i]>=bodyCapacity){atomicOr(&status->error,2u);return;}
    if(!correctionMotion(candidate,topology.clusters[candidate.cluster],source,output[i].body))
        {atomicOr(&status->error,4u);return;}
    if(previous) {
        const auto p=previous[candidate.sourceBody];float linear[3],angular[3];
        if(!correctionVelocity(output[i].body.bodyToWorldPosition,source,p.linearVelocity,p.angularVelocity,linear,angular))
            {atomicOr(&status->error,4u);return;}
    }
    output[i].targetBody=targets[i];
}
__global__ void inspectCorrectionSourceLoads(const PxDestructionStressCluster* clusters,const PxU32* affected,PxU32 count,
    const PxgBodySim* checkpoint,PxU32 checkpointCount,PxDestructionCorrectionPreparationStatus* status) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || !affected[i])return;
    const PxU32 id=clusters[i].body;if(id>=checkpointCount){atomicOr(&status->error,1u);return;}
    const auto body=checkpoint[id];const auto a=body.externalLinearAcceleration,b=body.externalAngularAcceleration;
    if(!isfinite(a.x) || !isfinite(a.y) || !isfinite(a.z) || !isfinite(b.x) || !isfinite(b.y) || !isfinite(b.z))
        {atomicOr(&status->error,8u);return;}
    if(a.x!=0 || a.y!=0 || a.z!=0 || b.x!=0 || b.y!=0 || b.z!=0)atomicAdd(&status->loadedSources,1u);
}
struct HasCorrectionBody {
    __host__ __device__ bool operator()(const PxDestructionCorrectionBody& b) const {return b.targetBody!=PX_INVALID_U32;}
};
__global__ void finishCorrectionPreparation(PxDestructionCorrectionPreparationStatus* correction,
    const PxDestructionCollisionPreparationStatus* collision,PxU64 checkpointGeneration,PxDestructionStageStatus* stage) {
    correction->generation=collision->generation;correction->checkpointGeneration=checkpointGeneration;
    correction->valid=!correction->error;
    if(correction->error)stage->error|=2048u;
}
__global__ void installCorrectionBodyInputs(const PxDestructionCorrectionBody* inputs,PxU32 count,const PxgBodySim* checkpoint,
    const PxgBodySimVelocities* oldPrevious,PxgBodySim* bodies,PxgBodySimVelocities* previous,PxgRigidBodyAcceleration* accelerations) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto input=inputs[i];const auto source=checkpoint[input.body.sourceBody];
    const auto b=nativeCandidateState(input.body,source,input.targetBody);bodies[input.targetBody]=b;
    if(previous) {
        const auto old=oldPrevious[input.body.sourceBody];float linear[3],angular[3];
        correctionVelocity(input.body.bodyToWorldPosition,source,old.linearVelocity,old.angularVelocity,linear,angular);
        previous[input.targetBody].linearVelocity=make_float4(linear[0],linear[1],linear[2],b.linearVelocityXYZ_inverseMassW.w);
        previous[input.targetBody].angularVelocity=make_float4(angular[0],angular[1],angular[2],b.angularVelocityXYZ_maxPenBiasW.w);
    }
    if(accelerations)accelerations[input.targetBody]={};
}
