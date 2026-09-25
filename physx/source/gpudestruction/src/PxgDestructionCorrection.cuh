// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included in the runtime implementation namespace.
__device__ bool correctionVelocityDouble(const float* center,const PxgBodySim& source,
    const float4& v,const float4& w,float* linear,float* angular) {
    const double r[3]={double(center[0])-source.body2World.p.x,double(center[1])-source.body2World.p.y,double(center[2])-source.body2World.p.z};
    const double velocity[3]={v.x+double(w.y)*r[2]-double(w.z)*r[1],v.y+double(w.z)*r[0]-double(w.x)*r[2],v.z+double(w.x)*r[1]-double(w.y)*r[0]};
    const double spin[3]={w.x,w.y,w.z};
    for(unsigned k=0;k<3;++k)if(!destructionBody::motionValue(velocity[k],linear[k]) || !destructionBody::motionValue(spin[k],angular[k]))return false;
    return true;
}
__device__ bool correctionMotionDouble(const PxDestructionClusterBodyState& candidate,
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
    return correctionVelocityDouble(output.bodyToWorldPosition,source,source.linearVelocityXYZ_inverseMassW,
        source.angularVelocityXYZ_maxPenBiasW,output.linearVelocity,output.angularVelocity);
}
// Shared by every variant of prepareCorrectionBodyInputs: the per-cluster
// preconditions, in their original order and with their original error bits.
// Returns false when the cluster needs no correction or failed a check.
__device__ __forceinline__ bool correctionPreconditions(PxU32 i,const PxDestructionClusterBodyState* candidates,const PxU32* targets,
    PxU32 chunkCount,const PxDestructionTopologyDeviceView& topology,const PxDestructionStressChunk* chunks,const PxU32* affected,
    const PxgBodySim* checkpoint,PxU32 checkpointCount,PxU32 bodyCapacity,const PxDestructionCollisionPreparationStatus* collision,
    PxDestructionCorrectionPreparationStatus* status,PxDestructionClusterBodyState& candidate,PxgBodySim& source) {
    if(!collision->valid || i>=topology.status->clusterCount)return false;
    candidate=candidates[i];
    if(candidate.cluster>=chunkCount || topology.activeClusters[i]!=candidate.cluster){atomicOr(&status->error,2u);return false;}
    if(!affected[chunks[candidate.cluster].cluster])return false;
    if(!checkpoint || candidate.sourceBody>=checkpointCount){atomicOr(&status->error,1u);return false;}
    source=checkpoint[candidate.sourceBody];
    if(__float_as_uint(source.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.w)!=candidate.sourceBody)
        {atomicOr(&status->error,1u);return false;}
    if(targets[i]>=bodyCapacity){atomicOr(&status->error,2u);return false;}
    return true;
}
// The corrected motion of one cluster in binary64, and the previous-velocity
// validation, exactly as before.
__device__ __forceinline__ void correctionBodyDouble(PxU32 i,const PxDestructionClusterBodyState& candidate,
    const PxDestructionClusterMassProperties& mass,const PxgBodySim& source,const PxgBodySimVelocities* previous,
    const PxU32* targets,PxDestructionCorrectionBody* output,PxDestructionCorrectionPreparationStatus* status) {
    if(!correctionMotionDouble(candidate,mass,source,output[i].body)){atomicOr(&status->error,4u);return;}
    if(previous) {
        const auto p=previous[candidate.sourceBody];float linear[3],angular[3];
        if(!correctionVelocityDouble(output[i].body.bodyToWorldPosition,source,p.linearVelocity,p.angularVelocity,linear,angular))
            {atomicOr(&status->error,4u);return;}
    }
    output[i].targetBody=targets[i];
}
#if defined(PX_CUMETAL) && PX_CUMETAL
// The motion and velocity above, operation for operation, in float pairs
// (PxgDestructionFloatPair.cuh), for Apple GPUs where binary64 is emulated.
// prepareCorrectionBodyInputs runs them once per corrected cluster on every
// split pass; as a chain of ~200 emulated double operations (two quaternion
// normalizations with square roots and divisions, two quaternion products, a
// rotation and the COM velocity) it measured ~290 us per launch in vibe-land's
// meteor bench, and ~50 us in pairs. Every input except the double cluster
// centre is a float, which a pair holds exactly; the centre takes one emulated
// split. Every validity test is kept, the unit-norm test with 1e-5 as the
// double constant, and each float output is the pair's leading float: the
// double result rounded to float up to the pairs' ~2^-44 relative accuracy
// (bit-identical to host double on 4096 random city-scale clusters). Inputs a
// pair cannot hold (nonzero magnitudes below 2^-60, which float arithmetic may
// flush, or a centre beyond 2^60) are deferred to the double path, which runs
// as a separate kernel: Apple's shader compiler fails ("internal error") on
// this kernel with both paths in it. CUDA keeps double throughout.
namespace destructionCorrectionPair {
using namespace destructionPair;
// Range tests on the bits, without branches or local arrays.
// A float is tiny when nonzero with |x| < 2^-60.
__device__ __forceinline__ unsigned tiny(float x){const unsigned b=__float_as_uint(x)&0x7fffffffu;return unsigned(b!=0u)&unsigned(b<0x21800000u);}
__device__ __forceinline__ unsigned tiny(float4 x){return tiny(x.x)|tiny(x.y)|tiny(x.z);}
__device__ __forceinline__ bool velocityInRange(const float* center,const PxgBodySim& source,const float4& v,const float4& w) {
    const auto p=source.body2World.p;
    return !(tiny(center[0])|tiny(center[1])|tiny(center[2])|tiny(p.x)|tiny(p.y)|tiny(p.z)|tiny(v)|tiny(w));
}
// r = centre - body COM (floats: the pair difference is exact), v + w x r.
__device__ __forceinline__ bool velocity(const float* center,const PxgBodySim& source,
    const float4& v,const float4& w,float* linear,float* angular) {
    const Pair r[3]={sub(pair(center[0]),pair(source.body2World.p.x)),sub(pair(center[1]),pair(source.body2World.p.y)),
        sub(pair(center[2]),pair(source.body2World.p.z))};
    const float vv[3]={v.x,v.y,v.z},ww[3]={w.x,w.y,w.z};
    // No return inside the loop: CuMetal lowers a loop with a second exit
    // through its per-lane CFG dispatcher, several times slower here.
    bool ok=true;
    for(unsigned k=0;k<3;++k) {
        const unsigned i=k==2?0:k+1,j=k==0?2:k-1;
        ok=ok && destructionBody::motionValue(sub(add(pair(vv[k]),mul(r[j],ww[i])),mul(r[i],ww[j])),linear[k])
            && destructionBody::motionValue(pair(ww[k]),angular[k]);
    }
    return ok;
}
__device__ __forceinline__ bool motionInRange(const PxDestructionClusterBodyState& candidate,
    const PxDestructionClusterMassProperties& mass,const PxgBodySim& source) {
    const auto w=source.body2World.getTransform(),l=source.body2Actor_maxImpulseW.getTransform();
    const float* o=candidate.bodyToActorOrientation;
    unsigned bad=tiny(w.p.x)|tiny(w.p.y)|tiny(w.p.z)|tiny(w.q.x)|tiny(w.q.y)|tiny(w.q.z)|tiny(w.q.w)
        |tiny(l.p.x)|tiny(l.p.y)|tiny(l.p.z)|tiny(l.q.x)|tiny(l.q.y)|tiny(l.q.z)|tiny(l.q.w)
        |tiny(o[0])|tiny(o[1])|tiny(o[2])|tiny(o[3])|tiny(source.linearVelocityXYZ_inverseMassW)|tiny(source.angularVelocityXYZ_maxPenBiasW);
    // The double centre: zero, or a finite magnitude in [2^-60, 2^60] (biased exponents 963..1083).
    const auto* bits=reinterpret_cast<const unsigned long long*>(mass.center);
    for(unsigned k=0;k<3;++k) {
        const unsigned exponent=unsigned(bits[k]>>52)&0x7ffu;
        bad|=unsigned((bits[k]<<1)!=0ull)&(unsigned(exponent<963u)|unsigned(exponent>1083u));
    }
    return !bad;
}
enum Result : unsigned {eOK,eFAILED,eDEFERRED};
// correctionMotionDouble in pairs: the actor frame conj(|world|) * |local|,
// the COM offset rotated into world space, the principal orientation and the
// COM velocity. A result outside the pair range is deferred, never approximated.
__device__ __forceinline__ unsigned motion(const PxDestructionClusterBodyState& candidate,
    const PxDestructionClusterMassProperties& mass,const PxgBodySim& source,PxDestructionClusterBodyState& output) {
    if(!motionInRange(candidate,mass,source))return eDEFERRED;
    const auto world=source.body2World.getTransform(),local=source.body2Actor_maxImpulseW.getTransform();
    if(!world.isValid() || !local.isValid())return eFAILED;
    Pair wq[4]={pair(world.q.x),pair(world.q.y),pair(world.q.z),pair(world.q.w)},
        lq[4]={pair(local.q.x),pair(local.q.y),pair(local.q.z),pair(local.q.w)};
    Pair wn=pair(0.0f),ln=pair(0.0f);for(unsigned k=0;k<4;++k){wn=add(wn,mul(wq[k],wq[k]));ln=add(ln,mul(lq[k],lq[k]));}
    const Pair wr=sqrt(wn),lr=sqrt(ln);
    for(unsigned k=0;k<4;++k){wq[k]=div(wq[k],wr);lq[k]=div(lq[k],lr);}
    const Pair actor[4]={add(sub(add(neg(mul(wq[3],lq[0])),mul(wq[0],lq[3])),mul(wq[1],lq[2])),mul(wq[2],lq[1])),
        sub(add(add(neg(mul(wq[3],lq[1])),mul(wq[0],lq[2])),mul(wq[1],lq[3])),mul(wq[2],lq[0])),
        add(add(sub(neg(mul(wq[3],lq[2])),mul(wq[0],lq[1])),mul(wq[1],lq[0])),mul(wq[2],lq[3])),
        add(add(add(mul(wq[3],lq[3]),mul(wq[0],lq[0])),mul(wq[1],lq[1])),mul(wq[2],lq[2]))};
    // Use a local COM difference instead of subtracting large world origins.
    const Pair offset[3]={sub(pairBits(mass.center[0]),pair(local.p.x)),sub(pairBits(mass.center[1]),pair(local.p.y)),
        sub(pairBits(mass.center[2]),pair(local.p.z))};
    Pair delta[3];destructionBody::rotate(actor,offset,delta);output=candidate;
    bool positioned=true;
    for(unsigned k=0;k<3;++k)positioned=positioned && destructionBody::motionValue(add(pair(world.p[k]),delta[k]),output.bodyToWorldPosition[k]);
    if(!positioned)return eFAILED;
    Pair principal[4],norm=pair(0.0f);
    for(unsigned k=0;k<4;++k){principal[k]=pair(candidate.bodyToActorOrientation[k]);norm=add(norm,mul(principal[k],principal[k]));}
    // !isfinite(norm) || fabs(norm-1)>1e-5, with 1e-5 as the double constant.
    constexpr float toleranceHi=1e-5f;constexpr float toleranceLo=float(1e-5-double(toleranceHi));
    if(!finite(norm) || less(Pair{toleranceHi,toleranceLo},abs(sub(norm,pair(1.0f)))))return eFAILED;
    const Pair root=sqrt(norm);for(unsigned k=0;k<4;++k)principal[k]=div(principal[k],root);
    const Pair* a=actor;const Pair* p=principal;
    const Pair q[4]={sub(add(add(mul(a[3],p[0]),mul(a[0],p[3])),mul(a[1],p[2])),mul(a[2],p[1])),
        add(add(sub(mul(a[3],p[1]),mul(a[0],p[2])),mul(a[1],p[3])),mul(a[2],p[0])),
        add(sub(add(mul(a[3],p[2]),mul(a[0],p[1])),mul(a[1],p[0])),mul(a[2],p[3])),
        sub(sub(sub(mul(a[3],p[3]),mul(a[0],p[0])),mul(a[1],p[1])),mul(a[2],p[2]))};
    for(unsigned k=0;k<4;++k)output.bodyToWorldOrientation[k]=q[k].hi;
    const float4 v=source.linearVelocityXYZ_inverseMassW,w=source.angularVelocityXYZ_maxPenBiasW;
    // The velocity centre is a result: a tiny one is deferred too.
    if(!velocityInRange(output.bodyToWorldPosition,source,v,w))return eDEFERRED;
    return velocity(output.bodyToWorldPosition,source,v,w,output.linearVelocity,output.angularVelocity)?eOK:eFAILED;
}
}
// installCorrectionBodyInputs' previous velocities (pairs; out of range keeps double).
__device__ __forceinline__ bool correctionVelocity(const float* center,const PxgBodySim& source,
    const float4& v,const float4& w,float* linear,float* angular) {
    return destructionCorrectionPair::velocityInRange(center,source,v,w)
        ? destructionCorrectionPair::velocity(center,source,v,w,linear,angular)
        : correctionVelocityDouble(center,source,v,w,linear,angular);
}
// A cluster the pair path defers keeps the compaction sentinel and this mark
// in its body record; prepareDeferredCorrectionBodyInputs completes it.
constexpr PxU32 gDeferredCorrectionBody=PX_INVALID_U32;
#else
__device__ bool correctionVelocity(const float* center,const PxgBodySim& source,
    const float4& v,const float4& w,float* linear,float* angular) {
    return correctionVelocityDouble(center,source,v,w,linear,angular);
}
#endif
__global__ void prepareCorrectionBodyInputs(const PxDestructionClusterBodyState* candidates,const PxU32* targets,
    PxU32 chunkCount,PxDestructionTopologyDeviceView topology,const PxDestructionStressChunk* chunks,
    const PxU32* affected,const PxgBodySim* checkpoint,const PxgBodySimVelocities* previous,PxU32 checkpointCount,PxU32 bodyCapacity,
    const PxDestructionCollisionPreparationStatus* collision,
    PxDestructionCorrectionBody* output,PxDestructionCorrectionPreparationStatus* status,
    const NativePreparationInputs* inputs=nullptr) {
    if(inputs){checkpoint=inputs->checkpoint;previous=inputs->previous;
        checkpointCount=inputs->checkpointCount;bodyCapacity=inputs->bodyCapacity;}
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=chunkCount)return;
    output[i]={};output[i].targetBody=PX_INVALID_U32;
    // Always overwrite the compaction sentinel, including a rejected prerequisite.
    PxDestructionClusterBodyState candidate;PxgBodySim source;
    if(!correctionPreconditions(i,candidates,targets,chunkCount,topology,chunks,affected,checkpoint,checkpointCount,
        bodyCapacity,collision,status,candidate,source))return;
    const auto& mass=topology.clusters[candidate.cluster];
#if defined(PX_CUMETAL) && PX_CUMETAL
    using namespace destructionCorrectionPair;
    unsigned result=motion(candidate,mass,source,output[i].body);
    if(result==eOK && previous) {
        const auto p=previous[candidate.sourceBody];float linear[3],angular[3];
        result=!velocityInRange(output[i].body.bodyToWorldPosition,source,p.linearVelocity,p.angularVelocity)?unsigned(eDEFERRED)
            :velocity(output[i].body.bodyToWorldPosition,source,p.linearVelocity,p.angularVelocity,linear,angular)?unsigned(eOK):unsigned(eFAILED);
    }
    if(result==eDEFERRED){output[i].body={};output[i].body.cluster=gDeferredCorrectionBody;return;}
    if(result==eFAILED){atomicOr(&status->error,4u);return;}
    output[i].targetBody=targets[i];
#else
    correctionBodyDouble(i,candidate,mass,source,previous,targets,output,status);
#endif
}
#if defined(PX_CUMETAL) && PX_CUMETAL
// The double path for the clusters prepareCorrectionBodyInputs deferred (out
// of the pair range; normally none). Same arguments; launched right after it.
__global__ void prepareDeferredCorrectionBodyInputs(const PxDestructionClusterBodyState* candidates,const PxU32* targets,
    PxU32 chunkCount,PxDestructionTopologyDeviceView topology,const PxDestructionStressChunk* chunks,
    const PxU32* affected,const PxgBodySim* checkpoint,const PxgBodySimVelocities* previous,PxU32 checkpointCount,PxU32 bodyCapacity,
    const PxDestructionCollisionPreparationStatus* collision,
    PxDestructionCorrectionBody* output,PxDestructionCorrectionPreparationStatus* status,
    const NativePreparationInputs* inputs=nullptr) {
    if(inputs){checkpoint=inputs->checkpoint;previous=inputs->previous;
        checkpointCount=inputs->checkpointCount;bodyCapacity=inputs->bodyCapacity;}
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=chunkCount)return;
    if(output[i].targetBody!=PX_INVALID_U32 || output[i].body.cluster!=gDeferredCorrectionBody)return;
    // Deferral happens only after every precondition passed; they are
    // re-read here (without new errors) for the candidate and source.
    PxDestructionClusterBodyState candidate;PxgBodySim source;
    if(!correctionPreconditions(i,candidates,targets,chunkCount,topology,chunks,affected,checkpoint,checkpointCount,
        bodyCapacity,collision,status,candidate,source))return;
    correctionBodyDouble(i,candidate,topology.clusters[candidate.cluster],source,previous,targets,output,status);
}
#endif
__global__ void inspectCorrectionSourceLoads(const PxDestructionStressCluster* clusters,const PxU32* affected,PxU32 count,
    const PxgBodySim* checkpoint,PxU32 checkpointCount,const PxDestructionCollisionPreparationStatus* collision,
    PxDestructionCorrectionPreparationStatus* status,const NativePreparationInputs* inputs=nullptr) {
    if(inputs){checkpoint=inputs->checkpoint;checkpointCount=inputs->checkpointCount;count=inputs->clusterCount;}
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(!collision->valid || i>=count || !affected[i])return;
    const PxU32 id=clusters[i].body;if(!checkpoint || id>=checkpointCount){atomicOr(&status->error,1u);return;}
    const auto body=checkpoint[id];const auto a=body.externalLinearAcceleration,b=body.externalAngularAcceleration;
    if(!isfinite(a.x) || !isfinite(a.y) || !isfinite(a.z) || !isfinite(b.x) || !isfinite(b.y) || !isfinite(b.z))
        {atomicOr(&status->error,8u);return;}
    if(a.x!=0 || a.y!=0 || a.z!=0 || b.x!=0 || b.y!=0 || b.z!=0)atomicAdd(&status->loadedSources,1u);
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
