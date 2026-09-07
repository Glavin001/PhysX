#pragma once
// Test-only resident stage probe. Normal SDK builds compile out all storage,
// clock reads and publication. SM-cycle deltas are local to one CTA; summed
// cycles describe resident work, not additive multi-SM elapsed milliseconds.
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
__device__ unsigned long long componentPhaseClocks[9];
__device__ unsigned long long componentPreconditionClocks[4];
#define COMPONENT_PROBE_BEGIN \
    __shared__ unsigned long long probeCycles[8],probeLast,probeStart; \
    if(!threadIdx.x){for(unsigned probeI=0;probeI<8;++probeI)probeCycles[probeI]=0;probeStart=probeLast=clock64();}
#define COMPONENT_PROBE_END(phase) \
    if(!threadIdx.x){const auto probeNow=clock64();probeCycles[phase]+=probeNow-probeLast;probeLast=probeNow;}
#define COMPONENT_PROBE_PUBLISH \
    COMPONENT_PROBE_END(7) \
    if(!threadIdx.x){for(unsigned probeI=0;probeI<8;++probeI)atomicAdd(componentPhaseClocks+probeI,probeCycles[probeI]);atomicAdd(componentPhaseClocks+8,probeLast-probeStart);}
#else
#define COMPONENT_PROBE_BEGIN
#define COMPONENT_PROBE_END(phase)
#define COMPONENT_PROBE_PUBLISH
#endif
