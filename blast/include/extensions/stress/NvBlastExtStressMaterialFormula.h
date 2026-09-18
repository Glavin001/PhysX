// Copyright (c) 2026 NVIDIA Corporation. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "NvBlastExtStressFormula.h"
#include <cfloat>
namespace Nv { namespace Blast {

// Shared material laws extracted from ExtStressSolverImpl. Material templates
// deliberately accept both the existing Blast material and native PhysX PODs.
NVBLAST_STRESS_FORMULA_FN void extStressFibre(bool fibres,float normal,float bend,float& compression,float& tension)
{
    if(!fibres) {
        const float combined=normal+copysignf(bend,normal);
        compression=combined<=0.0f?-combined:0.0f;tension=combined>0.0f?combined:0.0f;return;
    }
    const float t=normal+bend,c=bend-normal;
    tension=t>0.0f?t:0.0f;compression=c>0.0f?c:0.0f;
}
struct ExtStressDamageVerdict { float damage; float multiplier; bool command; };
template<class Material>
NVBLAST_STRESS_FORMULA_FN ExtStressDamageVerdict extStressBondDamage(
    float compression,float tension,float shear,float health,float originalArea,
    const Material& material,float dt,float damageRate)
{
    ExtStressDamageVerdict out{};
    if(!(health>0.0f))return out;
    float axial=0.0f;
    if(compression>material.compressionElasticLimit) {
        const float denominator=material.compressionFatalLimit-material.compressionElasticLimit;
        axial=(compression-material.compressionElasticLimit)/(denominator>0.0f?denominator:1.0f);
    }
    if(tension>material.tensionElasticLimit) {
        const float denominator=material.tensionFatalLimit-material.tensionElasticLimit;
        const float value=(tension-material.tensionElasticLimit)/(denominator>0.0f?denominator:1.0f);
        axial=axial<value?value:axial;
    }
    float multiplier=0.0f;multiplier+=axial;
    if(shear>material.shearElasticLimit) {
        const float denominator=material.shearFatalLimit-material.shearElasticLimit;
        multiplier+=(shear-material.shearElasticLimit)/(denominator>0.0f?denominator:1.0f);
    }
    out.multiplier=multiplier;out.command=multiplier>0.0f;
    if(!out.command)return out;
    // Fatal failure is immediate; subfatal section loss is a rate. A zero dt
    // retains the legacy offline per-tick convention.
    float damage;
    if(multiplier>=1.0f)damage=health;
    else if(dt>0.0f) {
        const float fraction=multiplier*dt*damageRate;
        damage=health*(fraction<1.0f?fraction:1.0f);
    }else damage=health*multiplier;
    // Reinforcement arrests gradual damage, never fatal failure. A command
    // remains a command even when the residual floor makes its damage zero.
    if(multiplier<1.0f && material.residualAreaFraction>0.0f) {
        const float floor=originalArea*material.residualAreaFraction;
        if(health-damage<floor)damage=health>floor?health-floor:0.0f;
    }
    out.damage=damage;return out;
}
struct ExtStressCrushState {
    float damage,pressure,deviator,utilisation;
    bool crushed;
};
NVBLAST_STRESS_FORMULA_FN bool extStressFinite(float x) {return x<=FLT_MAX && x>=-FLT_MAX;}
template<class Crush>
NVBLAST_STRESS_FORMULA_FN ExtStressCrushState extStressCrushStep(
    const float* virial,float volume,float mass,float strainRate,float dt,
    const Crush& material,ExtStressCrushState state)
{
    state.pressure=state.deviator=state.utilisation=0.0f;
    if(material.capPressure<=0.0f || state.crushed || volume<=0.0f || mass<=0.0f)return state;
    const float inv=1.0f/volume;
    const float xx=virial[0]*inv,yy=virial[1]*inv,zz=virial[2]*inv;
    const float xy=virial[3]*inv,xz=virial[4]*inv,yz=virial[5]*inv;
    const float pressure=-(xx+yy+zz)/3.0f;
    const float dx=xx+pressure,dy=yy+pressure,dz=zz+pressure;
    const float squared=dx*dx+dy*dy+dz*dz+2.0f*(xy*xy+xz*xz+yz*yz);
    const float deviator=sqrtf(1.5f*(squared>0.0f?squared:0.0f));
    // Preserve reference treatment of an unreadable stress state. Native
    // transaction validation also rejects nonfinite surface/bond inputs.
    if(!extStressFinite(pressure) || !extStressFinite(deviator))return state;
    state.pressure=pressure;state.deviator=deviator;
    if(pressure<=0.0f)return state; // no comminution in net tension
    const float cone=material.cohesion+material.frictionSlope*pressure;
    const float coneUse=cone>0.0f?deviator/cone:0.0f;
    const float capUse=material.capPressure>0.0f?pressure/material.capPressure:0.0f;
    state.utilisation=coneUse>capUse?coneUse:capUse;
    if(dt<=0.0f)return state;
    float strength=1.0f;
    if(material.strainRateExponent>0.0f && material.referenceStrainRate>0.0f) {
        strength=powf(strainRate/material.referenceStrainRate,material.strainRateExponent);
        if(strength<1.0f)strength=1.0f;
    }
    const float shearExcess=deviator-strength*(material.cohesion+material.frictionSlope*pressure);
    const float capExcess=pressure-strength*material.capPressure;
    const float excess=shearExcess>capExcess?shearExcess:capExcess;
    if(excess<=0.0f)return state;
    const float energy=material.crushEnergy>0.0f?material.crushEnergy:1.0f;
    const float viscosity=material.crushViscosity>0.0f?material.crushViscosity:1.0f;
    state.damage+=excess*excess*dt/(viscosity*energy);
    if(state.damage>=1.0f){state.damage=1.0f;state.crushed=true;}
    return state;
}
}} // Nv::Blast
