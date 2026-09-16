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
    // Weaker than a certificate: `inputs` holds the load of the last fresh
    // CONVERGED solve of this component and the stored forces are that solve's
    // export (within the solve tolerance, not verified against the strict
    // residual gate). Used by the continuing-load (R4) and elastic-margin (R6)
    // policies, whose margins dwarf the tolerance. Same lifetime rules as the
    // certificate: changed old components lose it; survivors advance.
    NativeSettledCertificate* references=nullptr;
    unsigned* counters=nullptr; // [0] elastic-margin skips (diagnostic)
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
        const unsigned id=components.ids[slot];
        if(!topology->initialized)continue;
        NativeSettledCertificate* proofs[2]={cache.certificates+id,cache.references+id};
        for(auto* proof:proofs){
            if(!proof->valid)continue;
            if(changed[id] || proof->generation!=topology->generation)proof->valid=0;
            else proof->generation=batch->generation?*batch->generation:0ull;
        }
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
        const auto proof=cache.references[id];
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
// R6: elastic-margin reuse. A component whose last material pass reported every
// bond below `margin` of its elastic limit, and whose load changed by less than
// `changeFraction` of the load last solved, reuses its stored forces this tick:
// no damage can accrue below the elastic limit, so the fracture verdict is
// unchanged; only the reported forces of such components are stale. Requires a
// converged reference solve for the current topology. Off unless
// BLAST_GPU_NATIVE_ELASTIC_MARGIN is set.
__global__ void beginNativeElasticReuse(NativeSettledCache cache,ResidentStressComponentView components,
    const ExtStressGpuDeviceTopologyStatus* topology,const DeviceStressTopologyBatch* batch,const ExtStressGpuImpulse* inputs,
    const unsigned* nodeBondBegin,const unsigned* nodeBondRef,const float* health,
    unsigned* converged,unsigned* skip,bool warm,float margin,float changeFraction,unsigned* counters,bool exactReuse){
    __shared__ float partial[3][kBlockSize/32];
    const float* utilization=batch->utilization;
    if(!utilization)return;
    for(unsigned slot=blockIdx.x;slot<*components.count;slot+=gridDim.x){
        const unsigned id=components.ids[slot];
        if(!warm || !topology->initialized || topology->error || skip[id])continue;
        const auto proof=cache.references[id];
        if(!proof.valid || proof.generation!=topology->generation)continue;
        float diff=0.f,prev=0.f,umax=0.f;
        for(unsigned i=components.begin[id]+threadIdx.x;i<components.end[id];i+=blockDim.x){
            const unsigned node=components.nodes[i];const auto a=inputs[node],b=cache.inputs[node];
            const float dx[6]={a.angular.x-b.angular.x,a.angular.y-b.angular.y,a.angular.z-b.angular.z,a.linear.x-b.linear.x,a.linear.y-b.linear.y,a.linear.z-b.linear.z};
            const float px[6]={b.angular.x,b.angular.y,b.angular.z,b.linear.x,b.linear.y,b.linear.z};
            for(unsigned k=0;k<6;++k){diff=fmaf(dx[k],dx[k],diff);prev=fmaf(px[k],px[k],prev);}
            for(unsigned r=nodeBondBegin[node];r<nodeBondBegin[node+1];++r){
                const unsigned ref=nodeBondRef[r];if(ref==kDeadBondRef)continue;const unsigned edge=ref&0x7fffffffu;
                if(health[edge]>0.f)umax=fmaxf(umax,utilization[edge]);
            }
        }
        for(unsigned o=16;o;o>>=1){diff+=__shfl_down_sync(0xffffffffu,diff,o);prev+=__shfl_down_sync(0xffffffffu,prev,o);umax=fmaxf(umax,__shfl_down_sync(0xffffffffu,umax,o));}
        if(!(threadIdx.x&31u)){partial[0][threadIdx.x/32]=diff;partial[1][threadIdx.x/32]=prev;partial[2][threadIdx.x/32]=umax;}
        __syncthreads();
        if(!threadIdx.x){
            float d2=0.f,p2=0.f,u=0.f;for(unsigned w=0;w<kBlockSize/32;++w){d2+=partial[0][w];p2+=partial[1][w];u=fmaxf(u,partial[2][w]);}
            if(p2>0.f && d2<=changeFraction*changeFraction*p2 && u<margin){skip[id]=1;converged[id]=1;if(counters)atomicAdd(counters,1u);}
            // Exact-input reuse (BLAST_GPU_NATIVE_EXACT_REUSE): the load is
            // bit-identical to the last converged solve of this unchanged
            // component, so its stored forces are that solve's answer; no
            // margin condition. Typical in the corrected pass for components
            // the correction did not touch.
            else if(exactReuse && p2>0.f && d2==0.f){skip[id]=1;converged[id]=1;if(counters)atomicAdd(counters+1,1u);}
        }
        __syncthreads();
    }
}
// Island-scoped correction: components whose root node is flagged keep their
// previous output (the same skip the settled certificate takes).
// The component's stored forces, reference load and certificate stay exactly
// what they were: a parked component is neither solved nor observed this pass
// (its inputs are the neutralised contacts of the corrected rigid solve).
__global__ void markParkedNativeComponents(unsigned* islandSkip, const unsigned* parkedNodeFlags, ResidentStressComponentView c,
    NativeSettledCache cache, unsigned* converged) {
    const unsigned t = blockIdx.x * blockDim.x + threadIdx.x;
    if (t >= *c.count) return;
    const unsigned id = c.ids[t];
    if (!parkedNodeFlags[id]) return;
    islandSkip[id] = 1u;
    converged[id] = 1u;
    cache.verifiedStoredOutput[id] = cache.certificates[id].valid ? 1u : 0u;
}
__global__ void commitNativeSettledReuse(NativeSettledCache cache,ResidentStressComponentView components,
    const ExtStressGpuDeviceTopologyStatus* topology,const ExtStressGpuImpulse* inputs,
    const unsigned* converged,const unsigned* skip,float tolerance,unsigned maxIterations){
    for(unsigned slot=blockIdx.x;slot<*components.count;slot+=gridDim.x){
        const unsigned id=components.ids[slot];
        const bool ok=topology->initialized && !topology->error && converged[id];
        const bool valid=ok && cache.verifiedStoredOutput[id];
        // A fresh converged solve becomes the reference load for the stored
        // forces. Skipped components keep the reference their stored forces
        // still belong to; a non-converged fresh solve invalidates it.
        if(ok && !skip[id])for(unsigned i=components.begin[id]+threadIdx.x;i<components.end[id];i+=blockDim.x){
            const unsigned node=components.nodes[i];cache.inputs[node]=inputs[node];}
        __syncthreads();
        if(!threadIdx.x){
            cache.certificates[id]={topology->generation,__float_as_uint(tolerance),maxIterations,unsigned(valid)};
            if(!skip[id])cache.references[id]={topology->generation,__float_as_uint(tolerance),maxIterations,unsigned(ok)};
            else if(!ok)cache.references[id].valid=0;
        }
        __syncthreads();
    }
}
