// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
// Included inside the runtime namespace, after PxgDestructionMaterial.cuh.
//
// Re-bearing (PX_DESTRUCTION_REBEARING=1): a bearing joint (PX_DESTRUCTION_BEARING_JOINTS,
// a fastened joint whose members bear on each other) whose fasteners fail is
// not removed. Its members still touch: it becomes a unilateral contact.
//   - it carries compression up to the bearing capacity of its material (its
//     compression limits: crushing perpendicular to the grain for timber,
//     EN 1995-1-1 6.1.5 / NDS 3.10 F_c-perp);
//   - shear only by friction, |V| <= mu C (Coulomb; mu below);
//   - no tension: in tension the contact lifts off and carries nothing;
//   - it is never broken while it bears. It breaks when it crushes, when it
//     slides (|V| > mu C: the stage's rigid clusters cannot slide, the rigid
//     solver can), or when the region it holds falls free: lifted off with no
//     other path to a support, which splits it as any fracture does.
// The stress solve is linear, so the contact is an active set: bearing
// (compression) bonds are in the solve, lifted (tension) bonds are out. The set
// is re-evaluated once per evaluation from the solve's own answer: a bearing
// contact in tension lifts; a lifted contact closes when the solve's resident
// displacement presses its two chunks together (the force it would carry if
// readmitted, Blast ExtStressGpuProbeBondForcesAsync). The solver keeps its
// warm start through both changes (ExtStressGpuEnableBondReadmission), so the
// set settles over ticks at the existing iteration cap; nothing iterates to
// convergence within a tick.
//
// Friction: timber on timber, sawn, parallel to the grain, mu = 0.23, the lower
// of EN 1995-2:2004 Table 6.2's static values for sawn softwood at <= 12% moisture
// (0.30 perpendicular to the grain); PX_DESTRUCTION_REBEARING_FRICTION overrides.
// A bearing joint's rocking (its compression resultant past the patch edge, the
// fasteners' T = M0/d0 + M1/d1 + N > 0 with N < 0) is not a failure: nothing
// breaks, the contact turns about its edge. The linear solve still gives the
// bond its full rotational stiffness there (one stiffness per bond: see
// vibe-land docs/calibration/house-headers.md "What the engine cannot do").
enum : PxU32 { eBEAR_FASTENED=0u, eBEAR_CONTACT=1u, eBEAR_LIFTED=2u };
static constexpr float kRebearingTimberFriction=0.23f; // EN 1995-2:2004 Table 6.2, sawn, parallel to grain

__device__ inline PxVec3 rebearingNormal(const PxDestructionStressChunk* chunks,const PxDestructionStressBond& b)
{
    const PxVec3 displacement=chunks[b.chunk1].position-chunks[b.chunk0].position;
    PxVec3 n=b.normal*copysignf(1.0f,b.normal.dot(displacement));
    const float l=n.magnitude();return l>1e-20f?n*(1.0f/l):n;
}
// The islands this solve held up: an island with a live bond to a support.
__global__ void markSupportedIslands(const PxDestructionStressChunk* chunks,const PxDestructionStressBond* bonds,
    const PxU32* solverMask,const PxU32* nodeIslands,PxU32* supported,PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || !solverMask[i])return;
    const auto b=bonds[i];const bool f0=!(chunks[b.chunk0].mass>0),f1=!(chunks[b.chunk1].mass>0);
    if(f0==f1)return;
    const PxU32 island=nodeIslands[f0?b.chunk1:b.chunk0];
    if(island!=0xffffffffu)supported[island]=1u;
}
// Diagnostics (PX_DESTRUCTION_REBEARING_LOG=2): (bond, kind, N, V) per transition;
// kind 0 fastening failed, 1 lifted, 2 closed, 3 slid, 4 fell free, 5 crushed.
__device__ inline void rebearingNote(float4* events,PxU32* counters,PxU32 capacity,PxU32 bond,float kind,float n,float shear)
{
    if(!events)return;const PxU32 k=atomicAdd(counters+5,1u);
    if(k<capacity)events[k]=make_float4(__uint_as_float(bond),kind,n,shear);
}
// After evaluateBondMaterials: the verdict of every bearing joint the static
// solve decided, and its next contact state (trial; committed with the material).
__global__ void rebearVerdicts(const PxDestructionStressChunk* chunks,const PxDestructionStressBond* bonds,
    const PxDestructionMaterial* materials,const PxDestructionBondSection* sections,const float* health,
    const PxU32* state,PxU32* trial,const PxDestructionVectorPair* probe,const PxU32* nodeIslands,const PxU32* supported,
    PxDestructionBondVerdict* verdict,PxU32 count,float dt,float rate,bool fibres,float friction,
    PxDestructionStageStatus* status,PxU32* counters,float4* events=nullptr,PxU32 eventCapacity=0)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 st=state[i];trial[i]=st;
    if(status->error & 4096u)return;
    const float area=health[i];if(!(area>0 && area<0.5f*FLT_MAX))return;
    const auto s=sections[i];if(!(s.bearingDepth0>0 && s.bearingDepth1>0))return;
    const auto b=bonds[i];const auto& m=materials[b.material];auto& v=verdict[i];
    // A material with its own friction coefficient (PX_DESTRUCTION_MOHR_COULOMB_SHEAR:
    // masonry's 0.4, EN 1996-1-1 3.6.2) slides at it once its bond has failed,
    // the same mu its intact joint was graded with; else the stage's (timber).
    if(m.shearFriction>0.0f)friction=m.shearFriction;
    const auto hold=[&](PxU32 next){v.health=area;v.damage=0.0f;trial[i]=next;};

    if(st==eBEAR_FASTENED) {
        if(v.health>0.0f)return;   // its fasteners held
        float compression,tension;extStressFibre(fibres,v.stressNormal,v.stressBend,compression,tension);
        if(compression>=m.compressionFatalLimit){rebearingNote(events,counters,eventCapacity,i,5.0f,v.stressNormal*area,v.stressShear*area);return;}   // crushed at the contact: broken
        // The fasteners failed (withdrawal or lateral); the members still touch.
        if(v.stressNormal<0.0f) {
            if(v.stressShear>friction*-v.stressNormal){atomicAdd(counters+2,1u);rebearingNote(events,counters,eventCapacity,i,3.0f,v.stressNormal*area,v.stressShear*area);return;}   // and slides: broken
            hold(eBEAR_CONTACT);
        } else hold(eBEAR_LIFTED);
        atomicAdd(counters,1u);rebearingNote(events,counters,eventCapacity,i,0.0f,v.stressNormal*area,v.stressShear*area);
        return;
    }
    if(st==eBEAR_CONTACT) {
        if(v.stressNormal>0.0f){rebearingNote(events,counters,eventCapacity,i,1.0f,v.stressNormal*area,v.stressShear*area);hold(eBEAR_LIFTED);atomicAdd(counters+4,1u);return;}   // pulled: it lifts, carrying nothing
        float compression,tension;extStressFibre(fibres,v.stressNormal,v.stressBend,compression,tension);
        const auto crush=extStressBondDamage(compression,0.0f,0.0f,area,b.area,m,dt,rate);
        const bool slides=v.stressShear>friction*-v.stressNormal;
        if(slides){atomicAdd(counters+2,1u);rebearingNote(events,counters,eventCapacity,i,3.0f,v.stressNormal*area,v.stressShear*area);}
        v.damage=slides?area:crush.damage;v.health=area-v.damage;v.command=slides || crush.command;
        return;
    }
    // Lifted: out of the solve. Does what it held fall free?
    v.health=area;v.damage=0.0f;v.command=0u;v.stressNormal=v.stressShear=v.stressBend=0.0f;
    const auto loose=[&](PxU32 c,PxU32 island){return chunks[c].mass>0 && (island==0xffffffffu || !supported[island]);};
    const PxU32 i0=nodeIslands[b.chunk0],i1=nodeIslands[b.chunk1];
    if(!(i0==i1 && i0!=0xffffffffu) && (loose(b.chunk0,i0) || loose(b.chunk1,i1))) {
        v.health=0.0f;v.damage=area;v.command=1u;atomicAdd(counters+3,1u);rebearingNote(events,counters,eventCapacity,i,4.0f,0.0f,0.0f);return;   // no compression path: it splits
    }
    // Would it press if readmitted (B^T y at its row; signed as stressNormal)?
    const float n=probe[i].linear.dot(rebearingNormal(chunks,b))/area;
    if(n<0.0f){trial[i]=eBEAR_CONTACT;atomicAdd(counters+1,1u);rebearingNote(events,counters,eventCapacity,i,2.0f,n*area,0.0f);}
}
__global__ void commitBearingState(const PxU32* trial,PxU32* state,PxU32 count,const PxDestructionStageStatus* status)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<count && !status->error)state[i]=trial[i];
}
// The solver's mask: the accepted topology less the lifted contacts. changed:
// any bit differs from the mask submitted last.
__global__ void composeBearingMask(const PxU32* accepted,const PxU32* state,PxU32* mask,PxU32* changed,PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const PxU32 live=accepted[i] && state[i]!=eBEAR_LIFTED?1u:0u;
    if(live!=mask[i]){mask[i]=live;*changed=1u;}
}
// A generation per (accepted generation, active set): strictly increasing, and
// equal to the accepted one shifted while no contact changes (the solver then
// rebuilds exactly when it would without re-bearing).
__global__ void bumpBearingGeneration(const PxU64* accepted,PxU64* generation,PxU64* lastAccepted,PxU32* changed)
{
    const PxU64 g=*accepted;
    if(g!=*lastAccepted){*lastAccepted=g;*generation=g<<32;}
    else if(*changed)++*generation;
    *changed=0u;
}
// PX_DESTRUCTION_REBEARING_CHECK=1 (diagnostic): the probe on every live bond
// must give its solved force (lambda = B^T y). out[0]: max |probe - force| over
// bonds, out[1]: max |force| (as float bits; both nonnegative).
__global__ void checkReadmissionProbe(const PxU32* mask,const PxDestructionVectorPair* probe,const PxDestructionVectorPair* forces,PxU32* out,PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count || !mask[i])return;
    const float d=(probe[i].linear-forces[i].linear).magnitude(),f=forces[i].linear.magnitude();
    if(d==d)atomicMax(out,__float_as_uint(d));atomicMax(out+1,__float_as_uint(f));
}
