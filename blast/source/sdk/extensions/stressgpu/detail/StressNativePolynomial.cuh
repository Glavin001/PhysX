// Fixed two-step Chebyshev-Jacobi preconditioner for a resident component.
// Let L=D+E, with the same cached node-block inverse M=D^-1. The two Richardson
// weights give P=(a+b)M-abMLM=(a+b-ab)M-abMEM. Only the off-diagonal E needs
// another sparse traversal: re-evaluating D would repeat algebra already cached.
// Each physical bond has at most two endpoints, hence L<=2D. Weights are the
// two Chebyshev roots for [0.1,2.01]; P stays positive on [0,2], including the
// zero eigenvalue. No low mode or load is dropped. Outer projection, equations
// and authoritative residual acceptance remain unchanged.
// The off-diagonal row of one node over CSR slots [begin, end), unscaled.
__device__ __forceinline__ StressHierarchy::Vector nativeOffDiagonalRange(
    const StressHierarchy::Input& input,unsigned node,const StressHierarchy::Vector* physical,unsigned begin,unsigned end)
{
    using namespace StressHierarchy;
    Vector value{};
    for(unsigned slot=begin;slot<end;++slot){
        const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
        const unsigned edge=ref&0x7fffffffu;if(input.health[edge]<=0)continue;
        const bool back=ref>>31;
        const unsigned other=back?input.node0[edge]:input.node1[edge];
        // Fixed boundaries contribute to D, but have no off-diagonal motion.
        if(other==node || input.component[other]==Invalid)continue;
        const auto remote=couple(physical[other],sourceOffset(input,edge,!back));
        const StressReal scale=input.scale[edge];
        value=add(value,transposeCouple(mul(remote,-scale*scale),sourceOffset(input,edge,back)));
    }
    return value;
}
__device__ __forceinline__ StressHierarchy::Vector nativeOffDiagonal(
    const StressHierarchy::Input& input,unsigned node,const StressHierarchy::Vector* physical)
{
    return StressHierarchy::scaledValue(nativeOffDiagonalRange(input,node,physical,input.begin[node],input.begin[node+1]),input.inertia[node]);
}
__device__ __forceinline__ StressHierarchy::Vector* preconditionNativePolynomial(
    const PersistentStressArgs& a,const unsigned* nodes,unsigned count)
{
    using namespace StressHierarchy;
    constexpr StressReal lowWeight=0.5779388123770052,highWeight=2.6335678180143502;
    constexpr StressReal coupling=lowWeight*highWeight;
    constexpr StressReal diagonal=lowWeight+highWeight-coupling;
    const auto input=a.hierarchy.cycle.levels[0].input;
    auto* local=a.hierarchy.result;
    auto* result=a.hierarchy.cycle.intermediate;
    // The small-component solve owns these fine-level rows; the cooperative
    // hierarchy only uses rows belonging to large components. Reuse its fine
    // residual workspace for scaled local values, without a new allocation.
    auto* physical=a.hierarchy.cycle.levels[0].residual;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        local[node]=applyNativeRigidInverse(a.hierarchy,node,a.hierarchy.rhs[node]);
        physical[node]=scaledValue(local[node],input.inertia[node]);}
    __syncthreads();
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        const auto off=nativeOffDiagonal(input,node,physical);
        result[node]=sub(mul(local[node],diagonal),mul(applyNativeRigidInverse(a.hierarchy,node,off),coupling));}
    // One disjoint destination per node. Readers consume this completed view;
    // there is no product buffer, copy back or second launch inside iteration.
    __syncthreads();return result;
}

// The same polynomial with its off-diagonal pass balanced by bonds: a node's
// CSR row is cut into chunks of ComponentChunks::kSlots slots, every thread of
// the block evaluates chunks, and each node then adds its chunks in order.
// Rows of at most kSlots slots are one chunk and evaluate exactly as above; a
// hub's row is summed chunk by chunk instead of slot by slot.
struct ComponentChunks {
    static constexpr unsigned kSlots=8;
    const unsigned* start;   // per component-local node, count+1 entries
    const unsigned* codes;   // per chunk: local node | chunk index << 20
    StressReal* partials;    // 8 per chunk
    unsigned count;          // chunks
};
__device__ __forceinline__ StressHierarchy::Vector* preconditionNativePolynomialBalanced(
    const PersistentStressArgs& a,const unsigned* nodes,unsigned count,const ComponentChunks chunks)
{
    using namespace StressHierarchy;
    constexpr StressReal lowWeight=0.5779388123770052,highWeight=2.6335678180143502;
    constexpr StressReal coupling=lowWeight*highWeight;
    constexpr StressReal diagonal=lowWeight+highWeight-coupling;
    const auto input=a.hierarchy.cycle.levels[0].input;
    auto* local=a.hierarchy.result;
    auto* result=a.hierarchy.cycle.intermediate;
    auto* physical=a.hierarchy.cycle.levels[0].residual;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        local[node]=applyNativeRigidInverse(a.hierarchy,node,a.hierarchy.rhs[node]);
        physical[node]=scaledValue(local[node],input.inertia[node]);}
    __syncthreads();
    for(unsigned k=threadIdx.x;k<chunks.count;k+=blockDim.x){const unsigned code=chunks.codes[k],node=nodes[code&0xFFFFFu];
        const unsigned first=input.begin[node]+(code>>20)*ComponentChunks::kSlots,last=min(first+ComponentChunks::kSlots,input.begin[node+1]);
        const Vector v=nativeOffDiagonalRange(input,node,physical,first,last);StressReal* out=chunks.partials+8*size_t(k);
        out[0]=v.angular.x;out[1]=v.angular.y;out[2]=v.angular.z;out[3]=v.linear.x;out[4]=v.linear.y;out[5]=v.linear.z;}
    __syncthreads();
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];Vector value{};
        for(unsigned k=chunks.start[i];k<chunks.start[i+1];++k){const StressReal* p=chunks.partials+8*size_t(k);
            value=add(value,Vector{makeStressReal3(p[0],p[1],p[2]),makeStressReal3(p[3],p[4],p[5])});}
        const auto off=StressHierarchy::scaledValue(value,input.inertia[node]);
        result[node]=sub(mul(local[node],diagonal),mul(applyNativeRigidInverse(a.hierarchy,node,off),coupling));}
    __syncthreads();return result;
}
