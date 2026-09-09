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
        if(id!=kNoIsland)atomicExch(changed+id,1u);
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
    if(id==kNoIsland || changed[id])impulses[edge]={};
    // Unaffected lambda remains available. The independent exact-input
    // certificate may authorize reuse; otherwise the solve verifies it again.
}
