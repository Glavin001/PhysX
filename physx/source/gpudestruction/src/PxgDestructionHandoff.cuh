// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// The windows' hand-off to the corrected pass (impact::Settings::compliant;
// vibe-land docs/destruction/IMPACT_STEP_PLAN.md section 1, rule 3, and
// "compliant impact contacts"). A window (the explicit impact step's, and the
// dynamic islands' of PX_DESTRUCTION_DYNAMIC_SEQUENCE) integrates its patch over
// the whole tick; its end velocities are the momentum handed to PhysX. The
// corrected pass re-simulates the tick from the rigid checkpoint with the split
// applied, so
//   - each impactor (and a two-body car) starts it with its window end velocity
//     (applyWindowImpactors, into the checkpoint it restores);
//   - each free fragment of window chunks starts it with their momentum
//     (handoffWindowMomentum, into its correction body);
//   - the pairs the window decided are dropped from its rigid solve (their
//     bound, impact::exPublish, pairwise), and the window's verdict stands
//     for its bonds (impact::View::decided).
// Included inside the runtime's namespace, after PxgDestructionImpact.cuh.

// The chunks of the rows routed to the window this pass: the trial's impact
// pressure (Ci) leaves them to the window, which crushes them in the row.
__global__ void markRoutedChunks(const impact::ContactRow* rows,const PxU32* count,PxU32 capacity,const PxU32* routed,PxU32 n,PxU32* flags)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=min(*count,capacity) || !routed[i])return;
    const PxU32 c=rows[i].chunk;if(c<n)flags[c]=1u;
}
// Per trial cluster root: the window chunks' mass, momentum (world) and angular
// momentum about the world origin (each chunk's own spin, scalar inertia, plus
// x x m v), at the tick's start pose. sums[2 root] = (M, P), sums[2 root + 1] = (L, 0).
__global__ void handoffAccumulate(const PxDestructionStressChunk* chunks,PxU32 n,const PxU32* chunkCluster,
    const float4* windowV,const PxU32* windowMask,const PxTransform* poses,float4* sums)
{
    const PxU32 c=blockIdx.x*blockDim.x+threadIdx.x;if(c>=n || !windowMask[c])return;
    const PxU32 root=chunkCluster[c];if(root>=n)return;
    const auto ch=chunks[c];if(!(ch.mass>0.0f))return;
    const PxVec3 x=poses[ch.cluster].transform(ch.position);
    const float4 a=windowV[2*size_t(c)],b=windowV[2*size_t(c)+1];
    const PxVec3 v(a.x,a.y,a.z),w(b.x,b.y,b.z),L=w*ch.inertia+x.cross(v*ch.mass);
    float4* s=sums+2*size_t(root);
    atomicAdd(&s[0].x,ch.mass);atomicAdd(&s[0].y,ch.mass*v.x);atomicAdd(&s[0].z,ch.mass*v.y);atomicAdd(&s[0].w,ch.mass*v.z);
    atomicAdd(&s[1].x,L.x);atomicAdd(&s[1].y,L.y);atomicAdd(&s[1].z,L.z);
}
// Each new free fragment's start motion in the corrected pass: its window chunks'
// momentum, its other chunks' share at the rigid (checkpoint) motion it was given:
// V = (P_w + (M - M_w) v_rigid) / M, w = I^-1 (L_w - X x P_w) (about its centre
// of mass X; its principal inertia in its body frame). The supported remnant keeps
// its own (rigid) motion.
__global__ void handoffWindowMomentum(PxDestructionCorrectionBody* output,PxU32 count,const float4* sums,PxU32 n)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    PxDestructionCorrectionBody& o=output[i];
    if(o.targetBody==PX_INVALID_U32 || o.body.supported)return;
    const PxU32 root=o.body.cluster;if(root>=n)return;
    const float4 s0=sums[2*size_t(root)],s1=sums[2*size_t(root)+1];
    const float Mw=s0.x,M=o.body.mass;if(!(Mw>0.0f) || !(M>0.0f))return;
    const PxVec3 P(s0.y,s0.z,s0.w),Lo(s1.x,s1.y,s1.z);
    const PxVec3 vr(o.body.linearVelocity[0],o.body.linearVelocity[1],o.body.linearVelocity[2]);
    const PxVec3 V=(P+vr*fmaxf(M-Mw,0.0f))*(1.0f/M);
    const PxVec3 X(o.body.bodyToWorldPosition[0],o.body.bodyToWorldPosition[1],o.body.bodyToWorldPosition[2]);
    const PxVec3 L=Lo-X.cross(P);
    const PxQuat q(o.body.bodyToWorldOrientation[0],o.body.bodyToWorldOrientation[1],o.body.bodyToWorldOrientation[2],o.body.bodyToWorldOrientation[3]);
    const PxVec3 Lb=q.rotateInv(L);
    const PxVec3 wb(Lb.x*o.body.inverseInertia[0],Lb.y*o.body.inverseInertia[1],Lb.z*o.body.inverseInertia[2]);
    const PxVec3 w=q.rotate(wb);
    if(!V.isFinite() || !w.isFinite())return;
    for(int k=0;k<3;++k){o.body.linearVelocity[k]=V[k];o.body.angularVelocity[k]=w[k];}
}
// Each impactor's (and a two-body car's) window end velocity into the rigid
// checkpoint the corrected pass restores: the records are in the struck
// cluster's frame (anchored), rotated into world by its pose. Several windows that
// met one body each integrated it from the same start, so they superpose: v = v0 +
// sum_p (v_p - v0) (first order; the two-body agent's agreement). The first record of
// a body (in record order) writes it.
// A hand-off record's vector, from its struck cluster's frame into world.
__device__ __forceinline__ PxVec3 handoffWorld(const impact::ExPatch* patches,const PxDestructionStressChunk* chunks,PxU32 n,const PxTransform* poses,PxU32 patch,const float* x)
{
    const PxU32 island=patches[patch].island;const PxVec3 a(x[0],x[1],x[2]);
    return island<n?poses[chunks[island].cluster].q.rotate(a):a;
}
__global__ void applyWindowImpactors(const impact::ExScratch::Handoff* records,const PxU32* count,const impact::ExPatch* patches,
    const PxDestructionStressChunk* chunks,PxU32 n,const PxTransform* poses,PxgBodySim* checkpoint,PxgBodySimVelocities* previous,PxU32 checkpointCount)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x,total=min(*count,impact::kExHandoffs);if(i>=total)return;
    const auto r=records[i];if(r.body>=checkpointCount || !r.pad)return;   // (pad: its pairs dropped, exPublish)
    for(PxU32 j=0;j<i;++j)if(records[j].body==r.body && records[j].pad)return;   // (an earlier record writes this body)
    PxVec3 v=handoffWorld(patches,chunks,n,poses,r.patch,r.v0),w=handoffWorld(patches,chunks,n,poses,r.patch,r.w0);
    for(PxU32 j=i;j<total;++j){const auto& h=records[j];if(h.body!=r.body || !h.pad)continue;
        v+=handoffWorld(patches,chunks,n,poses,h.patch,h.v)-handoffWorld(patches,chunks,n,poses,h.patch,h.v0);
        w+=handoffWorld(patches,chunks,n,poses,h.patch,h.w)-handoffWorld(patches,chunks,n,poses,h.patch,h.w0);}
    if(!v.isFinite() || !w.isFinite())return;
    PxgBodySim& b=checkpoint[r.body];
    b.linearVelocityXYZ_inverseMassW.x=v.x;b.linearVelocityXYZ_inverseMassW.y=v.y;b.linearVelocityXYZ_inverseMassW.z=v.z;
    b.angularVelocityXYZ_maxPenBiasW.x=w.x;b.angularVelocityXYZ_maxPenBiasW.y=w.y;b.angularVelocityXYZ_maxPenBiasW.z=w.z;
    if(previous){previous[r.body].linearVelocity.x=v.x;previous[r.body].linearVelocity.y=v.y;previous[r.body].linearVelocity.z=v.z;
        previous[r.body].angularVelocity.x=w.x;previous[r.body].angularVelocity.y=w.y;previous[r.body].angularVelocity.z=w.z;}
}
