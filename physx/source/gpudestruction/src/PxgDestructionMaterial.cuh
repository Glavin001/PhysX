// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "NvBlastExtStressMaterialFormula.h"
#include <cfloat>

// Included inside the runtime namespace. One immutable solver edge per chunk
// pair in this API revision; CSR iteration keeps the reference virial order.
__global__ void evaluateBondMaterials(const PxDestructionStressChunk* chunks,
    const PxDestructionStressBond* bonds,const PxDestructionMaterial* materials,
    const float* health,const PxDestructionVectorPair* forces,PxU32 count,
    float dt,float rate,float bendGain,bool fibres,PxDestructionBondVerdict* verdict,
    PxVec3* centroids,PxDestructionStageStatus* status)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto b=bonds[i];const float area=health[i];auto& v=verdict[i];v={};v.health=area;
    centroids[i]=b.centroid;
    if(!(area>0 && area<0.5f*FLT_MAX))return;
    const PxVec3 displacement=chunks[b.chunk1].position-chunks[b.chunk0].position;
    const PxVec3 aligned=b.normal*copysignf(1.0f,b.normal.dot(displacement));
    // Same area-weighted preparation as the reference group walk, including
    // its multiply/reciprocal sequence for a group with one member.
    PxVec3 normal(fmaf(aligned.x,area,0),fmaf(aligned.y,area,0),fmaf(aligned.z,area,0));
    PxVec3 delta(fmaf(displacement.x,area,0),fmaf(displacement.y,area,0),fmaf(displacement.z,area,0));
    PxVec3 centroid(fmaf(b.centroid.x,area,0),fmaf(b.centroid.y,area,0),fmaf(b.centroid.z,area,0));
    const float norm=sqrtf(extStressDot({normal.x,normal.y,normal.z},{normal.x,normal.y,normal.z}));
    if(!(norm<1e-20f))normal*=1.0f/norm;
    const float inv=1.0f/area;delta*=inv;centroid*=inv;centroids[i]=centroid;
    const float distance=sqrtf(extStressDot({delta.x,delta.y,delta.z},{delta.x,delta.y,delta.z}));
    const auto force=forces[i];
    extStressCalcBondStress({force.linear.x,force.linear.y,force.linear.z},
        {force.angular.x,force.angular.y,force.angular.z},{normal.x,normal.y,normal.z},
        area,distance,bendGain,v.stressNormal,v.stressShear,v.stressBend);
    if(!extStressFinite(v.stressNormal) || !extStressFinite(v.stressShear) || !extStressFinite(v.stressBend)) {
        atomicOr(&status->error,2u);return;
    }
    float compression,tension;extStressFibre(fibres,v.stressNormal,v.stressBend,compression,tension);
    const auto damage=extStressBondDamage(compression,tension,v.stressShear,area,b.area,materials[b.material],dt,rate);
    v.damage=damage.damage;v.command=damage.command;v.health=area-damage.damage;
    if(!extStressFinite(v.health) || !extStressFinite(v.damage))atomicOr(&status->error,2u);
    if(v.command)atomicAdd(&status->bondCommands,1u);
}
__device__ void addVirial(float* v,const PxVec3& r,const PxVec3& f)
{
    v[0]+=r.x*f.x;v[1]+=r.y*f.y;v[2]+=r.z*f.z;
    v[3]+=0.5f*(r.x*f.y+r.y*f.x);v[4]+=0.5f*(r.x*f.z+r.z*f.x);v[5]+=0.5f*(r.y*f.z+r.z*f.y);
}
__global__ void evaluateChunkMaterials(const PxDestructionStressChunk* chunks,
    const PxDestructionStressBond* bonds,const PxDestructionMaterial* materials,
    const PxU32* begin,const PxU32* refs,const float* health,
    const PxDestructionVectorPair* forces,const PxVec3* centroids,
    const PxDestructionSurfaceLoad* surface,const float* rates,
    const PxDestructionCrushState* accepted,PxDestructionCrushState* trial,
    PxU32 count,float dt,PxDestructionStageStatus* status)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    const auto c=chunks[i];const auto material=materials[c.material].crush;
    float virial[6];for(PxU32 k=0;k<6;++k)virial[k]=surface[i].virial[k];
    if(material.capPressure>0 && c.mass>0 && !accepted[i].crushed) {
        for(PxU32 slot=begin[i];slot<begin[i+1];++slot) {
            const PxU32 bond=refs[slot];const float area=health[bond];
            if(!(area>0 && area<0.5f*FLT_MAX))continue;
            const float share=area*(1.0f/area); // reference member/group area share
            const PxVec3 force=forces[bond].linear*share*(bonds[bond].chunk0==i?1.0f:-1.0f);
            addVirial(virial,centroids[bond]-c.position,force);
        }
    }
    for(PxU32 k=0;k<6;++k)if(!extStressFinite(virial[k]))atomicOr(&status->error,2u);
    const auto a=accepted[i];const ExtStressCrushState before{a.damage,a.pressure,a.deviator,a.utilisation,a.crushed!=0};
    const auto next=extStressCrushStep(virial,c.volume,c.mass,rates[i],dt,material,before);
    trial[i]={next.damage,next.pressure,next.deviator,next.utilisation,next.crushed?1u:0u};
    if(!a.crushed && next.crushed)atomicAdd(&status->crushedChunks,1u);
}
__global__ void finalizeMaterialVerdict(const PxDestructionStressBond* bonds,
    PxDestructionBondVerdict* verdict,const PxDestructionCrushState* chunks,PxU32 count,
    PxDestructionStageStatus* status)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    auto& v=verdict[i];const auto b=bonds[i];
    if(chunks[b.chunk0].crushed || chunks[b.chunk1].crushed)v.health=0;
    v.broken=v.health<=0?1u:0u;
    if(v.broken)atomicAdd(&status->brokenBonds,1u);
}
__global__ void requireFractureCorrection(PxDestructionStageStatus* status)
{
    if(status->brokenBonds || status->crushedChunks)status->error|=8u;
}
__global__ void commitMaterialState(const PxDestructionBondVerdict* bonds,float* health,PxU32 nb,
    const PxDestructionCrushState* trial,PxDestructionCrushState* accepted,PxU32 nc,
    const PxDestructionStageStatus* status)
{
    if(status->error)return; // whole material transaction remains uncommitted
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<nb)health[i]=bonds[i].health;
    if(i<nc)accepted[i]=trial[i];
}
