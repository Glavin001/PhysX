#pragma once
// Diagnostic-only sparse work accounting. No storage or instructions exist in
// the production build. Topology is immutable during a solve, so graph visits
// per sweep are counted once and multiplied by the sweeps actually executed.
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
struct ComponentWorkRecord {
    unsigned path, nodes, dynamicNodes, iterations, converged, block;
    unsigned long long csrReferences, liveReferences, residualSweeps, verificationSweeps, directionSweeps, cycles;
};
__device__ ComponentWorkRecord* componentWorkRecords;
__device__ unsigned componentWorkCapacity, componentWorkOverflow;
#define COMPONENT_WORK_BEGIN(a,c,id,begin,count) \
    __shared__ ComponentWorkRecord workRecord; \
    __shared__ unsigned long long workStart; \
    if(!threadIdx.x){ \
        workRecord={};workRecord.path=1;workRecord.nodes=count;workRecord.block=blockIdx.x;workStart=clock64(); \
        for(unsigned wi=0;wi<count;++wi){const unsigned wn=c.nodes[begin+wi];const auto inv=a.m_inertia[wn]; \
            if(inv.angular==0 && inv.linear==0)continue; \
            ++workRecord.dynamicNodes; \
            workRecord.csrReferences+=a.m_nodeBondBegin[wn+1]-a.m_nodeBondBegin[wn]; \
            for(unsigned we=a.m_nodeBondBegin[wn];we<a.m_nodeBondBegin[wn+1];++we){ \
                const unsigned ref=a.m_nodeBondRef[we];if(ref!=kDeadBondRef && a.m_health[ref&0x7fffffffu]>0)++workRecord.liveReferences; \
            } \
        } \
    } \
    __syncthreads();
#define COMPONENT_WORK_SWEEP(a,id,field) \
    if(!threadIdx.x && a.m_islandActive[id])++workRecord.field;
#define COMPONENT_WORK_END(id,status) \
    if(!threadIdx.x){ \
        workRecord.iterations=status.iterations;workRecord.converged=status.converged;workRecord.cycles=clock64()-workStart; \
        if(componentWorkRecords && id<componentWorkCapacity)componentWorkRecords[id]=workRecord; \
        else atomicExch(&componentWorkOverflow,1u); \
    }
#define COMPONENT_WORK_UNMEASURED(id,count) \
    if(!threadIdx.x){ \
        if(componentWorkRecords && id<componentWorkCapacity){ComponentWorkRecord r{};r.path=2;r.nodes=count;componentWorkRecords[id]=r;} \
        else atomicExch(&componentWorkOverflow,1u); \
    }
#else
#define COMPONENT_WORK_BEGIN(a,c,id,begin,count)
#define COMPONENT_WORK_SWEEP(a,id,field)
#define COMPONENT_WORK_END(id,status)
#define COMPONENT_WORK_UNMEASURED(id,count)
#endif
