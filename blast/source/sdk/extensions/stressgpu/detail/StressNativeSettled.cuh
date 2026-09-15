// GPU-owned exact-input reuse. This is independent of rigid-body sleeping.
// A certificate is issued only after a ZERO-UPDATE warm solve has verified
// the stored bond forces, not merely the higher-precision pre-export solution.
// The normal material consumer still executes and advances damage each tick.
struct NativeSettledCertificate {
    std::uint64_t generation;
    unsigned toleranceBits, maxIterations, valid;
};
struct NativeSettledCache {
    ExtStressGpuImpulse* inputs=nullptr;
    NativeSettledCertificate* certificates=nullptr;
    unsigned* verifiedStoredOutput=nullptr;
};
__device__ __forceinline__ bool identicalNativeInput(const ExtStressGpuImpulse& a,const ExtStressGpuImpulse& b){
    return __float_as_uint(a.angular.x)==__float_as_uint(b.angular.x)
        && __float_as_uint(a.angular.y)==__float_as_uint(b.angular.y)
        && __float_as_uint(a.angular.z)==__float_as_uint(b.angular.z)
        && __float_as_uint(a.linear.x)==__float_as_uint(b.linear.x)
        && __float_as_uint(a.linear.y)==__float_as_uint(b.linear.y)
        && __float_as_uint(a.linear.z)==__float_as_uint(b.linear.z);
}
// Bond removals are the only mutable operator input in the resident API.
// Consume the existing exact changed-OLD-component flags before relabeling.
// Surviving certificates can advance generations without touching their forces.
// New split roots have never owned a certificate: removals cannot merge or
// resurrect a former component. Changed old roots lose their certificate.
__global__ void refreshNativeSettledCertificates(NativeSettledCache cache,
    ResidentStressComponentView components,const ExtStressGpuDeviceTopologyStatus* topology,
    const DeviceStressTopologyBatch* batch,const unsigned* changed){
    for(unsigned slot=blockIdx.x*blockDim.x+threadIdx.x;slot<*components.count;slot+=blockDim.x*gridDim.x){
        const unsigned id=components.ids[slot];auto& proof=cache.certificates[id];
        if(!topology->initialized || !proof.valid)continue;
        if(changed[id] || proof.generation!=topology->generation)proof.valid=0;
        else proof.generation=batch->generation?*batch->generation:0ull;
    }
}
__global__ void beginNativeSettledReuse(NativeSettledCache cache,ResidentStressComponentView components,
    const ExtStressGpuDeviceTopologyStatus* topology,const ExtStressGpuImpulse* inputs,
    unsigned* converged,unsigned* skip,bool warm,float tolerance,unsigned maxIterations){
    for(unsigned slot=blockIdx.x;slot<*components.count;slot+=gridDim.x){
        const unsigned id=components.ids[slot];
        // valid is initialized separately, so invalid certificate fields and
        // input storage are never read before their first successful write.
        bool dirty=!warm || !topology->initialized || topology->error || !cache.certificates[id].valid;
        if(!dirty){const auto proof=cache.certificates[id];
            dirty=proof.generation!=topology->generation || proof.toleranceBits!=__float_as_uint(tolerance)
                || proof.maxIterations!=maxIterations;}
        if(!dirty)for(unsigned i=components.begin[id]+threadIdx.x;i<components.end[id];i+=blockDim.x){
            const unsigned node=components.nodes[i];dirty|=!identicalNativeInput(inputs[node],cache.inputs[node]);}
        const bool changed=__syncthreads_or(dirty);
        if(!threadIdx.x){
            skip[id]=!changed;cache.verifiedStoredOutput[id]=!changed;
            // Topology rebuild clears recurrence scratch, including this flag.
            // Restore it from the independently preserved exact certificate.
            if(!changed)converged[id]=1;
        }
        __syncthreads();
    }
}
// R4: continuing-load relaxation. A component whose verified stored input
// exists and whose new load differs from it by less than changeFraction of its
// norm keeps a looser relative tolerance; a new event (no certificate, changed
// topology, or a larger load change) keeps the strict one. Fracture verdicts
// for impacts therefore still come from the strict solve in the same tick.
// BLAST_GPU_NATIVE_CONTINUING_TOLERANCE=0 (default) disables the relaxation.
__global__ void relaxNativeContinuingTolerance(NativeSettledCache cache,ResidentStressComponentView components,
    const ExtStressGpuDeviceTopologyStatus* topology,const ExtStressGpuImpulse* inputs,
    float* deltaSquared,const float* rhsSquared,const unsigned* skip,float loose,float changeFraction,bool warm){
    __shared__ float partial[2][kBlockSize/32];
    for(unsigned slot=blockIdx.x;slot<*components.count;slot+=gridDim.x){
        const unsigned id=components.ids[slot];
        if(!warm || !topology->initialized || topology->error || (skip && skip[id]))continue;
        const auto proof=cache.certificates[id];
        if(!proof.valid || proof.generation!=topology->generation)continue;
        float diff=0.f,prev=0.f;
        for(unsigned i=components.begin[id]+threadIdx.x;i<components.end[id];i+=blockDim.x){
            const unsigned node=components.nodes[i];const auto a=inputs[node],b=cache.inputs[node];
            const float dx[6]={a.angular.x-b.angular.x,a.angular.y-b.angular.y,a.angular.z-b.angular.z,a.linear.x-b.linear.x,a.linear.y-b.linear.y,a.linear.z-b.linear.z};
            const float px[6]={b.angular.x,b.angular.y,b.angular.z,b.linear.x,b.linear.y,b.linear.z};
            for(unsigned k=0;k<6;++k){diff=fmaf(dx[k],dx[k],diff);prev=fmaf(px[k],px[k],prev);}
        }
        for(unsigned o=16;o;o>>=1){diff+=__shfl_down_sync(0xffffffffu,diff,o);prev+=__shfl_down_sync(0xffffffffu,prev,o);}
        if(!(threadIdx.x&31u)){partial[0][threadIdx.x/32]=diff;partial[1][threadIdx.x/32]=prev;}
        __syncthreads();
        if(!threadIdx.x){
            float d2=0.f,p2=0.f;for(unsigned w=0;w<kBlockSize/32;++w){d2+=partial[0][w];p2+=partial[1][w];}
            if(p2>0.f && d2<=changeFraction*changeFraction*p2)deltaSquared[id]=rhsSquared[id]*loose*loose;
        }
        __syncthreads();
    }
}
__global__ void commitNativeSettledReuse(NativeSettledCache cache,ResidentStressComponentView components,
    const ExtStressGpuDeviceTopologyStatus* topology,const ExtStressGpuImpulse* inputs,
    const unsigned* converged,const unsigned* skip,float tolerance,unsigned maxIterations){
    for(unsigned slot=blockIdx.x;slot<*components.count;slot+=gridDim.x){
        const unsigned id=components.ids[slot];
        const bool valid=topology->initialized && !topology->error && converged[id] && cache.verifiedStoredOutput[id];
        if(valid && !skip[id])for(unsigned i=components.begin[id]+threadIdx.x;i<components.end[id];i+=blockDim.x){
            const unsigned node=components.nodes[i];cache.inputs[node]=inputs[node];}
        __syncthreads();
        if(!threadIdx.x)cache.certificates[id]={topology->generation,__float_as_uint(tolerance),maxIterations,unsigned(valid)};
        __syncthreads();
    }
}
