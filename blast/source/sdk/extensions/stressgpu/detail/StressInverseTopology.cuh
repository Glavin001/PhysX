// A local diagonal depends only on incident live bonds and immutable asset
// offsets, coupling scales and inertia. Connectivity labels / loads / rigid
// modes do not enter its coefficients. A split elsewhere cannot change it.
// This runs inside the accepted topology transaction BEFORE health/generation
// are overwritten. Host topology/coefficients cannot mutate a resident solver;
// resurrection is rejected by the preceding mask validation.
__global__ void refreshNativeInverseValidity(const DeviceStressTopologyBatch* batch,
    const ExtStressGpuDeviceTopologyStatus* state,const unsigned* begin,
    const unsigned* refs,const float* health,unsigned* valid,
    std::uint64_t* generation,unsigned nodes)
{
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;
    if(node>=nodes)return;
    // Unknown and stale caches must never be certified by a topology update.
    // Short circuit before reading an uninitialized generation on first use.
    if(!state->initialized || !valid[node] || generation[node]!=state->generation){
        valid[node]=0;return;
    }
    if(batch->mask)for(unsigned slot=begin[node];slot<begin[node+1];++slot){
        const unsigned ref=refs[slot];if(ref==kNoIsland)continue;
        const unsigned bond=ref&0x7fffffffu;
        if(health[bond]>0 && !batch->mask[bond]){valid[node]=0;return;}
    }
    // Retain the existing packed inverse byte-for-byte. Only advance its
    // validity certificate; the normal solver still evaluates current loads.
    generation[node]=batch->generation?*batch->generation:0ull;
}
