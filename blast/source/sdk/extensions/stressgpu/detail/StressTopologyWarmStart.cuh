// Topology changes invalidate the old connected component, including cuts that
// leave its minimum ID unchanged. Fixed supports are already excluded from
// bondIsland connectivity, so a shared prescribed boundary cannot dirty peers.
// This consumes the OLD labels/health before the topology producer overwrites
// them. rootFlags is temporary scratch until initializeDeviceStressTopology.
__global__ void markChangedStressComponents(const DeviceStressTopologyBatch* batch,
    const ExtStressGpuDeviceTopologyStatus* state,const float* health,
    const unsigned* oldIsland,unsigned* changed,unsigned bonds)
{
    const unsigned edge=blockIdx.x*blockDim.x+threadIdx.x;
    if(edge>=bonds || !state->initialized || !batch->mask)return;
    if(health[edge]>0 && !batch->mask[edge]){
        const unsigned id=oldIsland[edge];
        // A readmissible (contact) bond's removal keeps the warm start: the
        // remaining impulses stay B^T times the resident displacement. 2 marks
        // the component's caches stale without clearing its impulses.
        if(id!=kNoIsland){if(batch->readmit && batch->readmit[edge])atomicOr(changed+id,2u);else atomicExch(changed+id,1u);}
    }
}
__global__ void clearChangedStressWarmStart(const ExtStressGpuDeviceTopologyStatus* state,
    const unsigned* oldIsland,const unsigned* changed,AngLin* impulses,unsigned bonds)
{
    const unsigned edge=blockIdx.x*blockDim.x+threadIdx.x;
    if(edge>=bonds)return;
    // Initial labels need not be initialized; do not read them on first use.
    if(!state->initialized){impulses[edge]={};return;}
    const unsigned id=oldIsland[edge];
    if(id==kNoIsland || (changed[id]&1u))impulses[edge]={};
    // Unaffected lambda remains available. The independent exact-input
    // certificate may authorize reuse; otherwise the solve verifies it again.
}
// Incremental motion forest (BLAST_STRESS_INCREMENTAL_MOTION=1). A removal mask
// is the only way the resident topology changes, so an old component that lost
// no bond is, after relabeling, the same component: the same nodes, live bonds
// and minimum-node ID. Its spanning-tree bits and its motion modes are kept
// instead of rebuilt. stable[0,n) flags nodes, stable[n,n+m) live bonds, of
// such components. Like markChangedStressComponents, this reads the OLD labels
// and health; with no mask or no prior topology nothing is stable.
__global__ void markStableStressRows(const DeviceStressTopologyBatch* batch,
    const ExtStressGpuDeviceTopologyStatus* state,const float* health,
    const unsigned* nodeIsland,const unsigned* bondIsland,const unsigned* changed,
    unsigned* stable,unsigned n,unsigned m)
{
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    const bool prior=state->initialized && batch->mask;
    if(i<n){const unsigned id=prior?nodeIsland[i]:kNoIsland;stable[i]=id!=kNoIsland && !changed[id];}
    if(i<m){const unsigned id=prior && health[i]>0?bondIsland[i]:kNoIsland;stable[n+i]=id!=kNoIsland && !changed[id];}
}
