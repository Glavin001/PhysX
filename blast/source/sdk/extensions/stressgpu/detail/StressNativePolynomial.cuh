// Fixed two-step Chebyshev-Jacobi preconditioner for a resident component.
// Let L=D+E, with the same cached node-block inverse M=D^-1. The two Richardson
// weights give P=(a+b)M-abMLM=(a+b-ab)M-abMEM. Only the off-diagonal E needs
// another sparse traversal: re-evaluating D would repeat algebra already cached.
// Each physical bond has at most two endpoints, hence L<=2D. Weights are the
// two Chebyshev roots for [0.1,2.01]; P stays positive on [0,2], including the
// zero eigenvalue. No low mode or load is dropped. Outer projection, equations
// and authoritative residual acceptance remain unchanged.
__device__ __forceinline__ StressHierarchy::Vector nativeOffDiagonal(
    const StressHierarchy::Input& input,unsigned node,const StressHierarchy::Vector* x)
{
    using namespace StressHierarchy;
    Vector value{};
    for(unsigned slot=input.begin[node];slot<input.begin[node+1];++slot){
        const unsigned ref=input.refs[slot];if(ref==Invalid)continue;
        const unsigned edge=ref&0x7fffffffu;if(input.health[edge]<=0)continue;
        const bool back=ref>>31;
        const unsigned other=back?input.node0[edge]:input.node1[edge];
        // Fixed boundaries contribute to D, but have no off-diagonal motion.
        if(other==node || input.component[other]==Invalid)continue;
        const auto remote=couple(scaledValue(x[other],input.inertia[other]),sourceOffset(input,edge,!back));
        const double scale=input.scale[edge];
        value=add(value,scaledValue(transposeCouple(mul(remote,-scale*scale),sourceOffset(input,edge,back)),input.inertia[node]));
    }
    return value;
}
__device__ __forceinline__ StressHierarchy::Vector* preconditionNativePolynomial(
    const PersistentStressArgs& a,const unsigned* nodes,unsigned count)
{
    using namespace StressHierarchy;
    constexpr double lowWeight=0.5779388123770052,highWeight=2.6335678180143502;
    constexpr double coupling=lowWeight*highWeight;
    constexpr double diagonal=lowWeight+highWeight-coupling;
    const auto input=a.hierarchy.cycle.levels[0].input;
    auto* local=a.hierarchy.result;
    auto* result=a.hierarchy.cycle.intermediate;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        local[node]=applyNativeFineInverse(a.hierarchy,node,a.hierarchy.rhs[node]);}
    __syncthreads();
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i];
        const auto off=nativeOffDiagonal(input,node,local);
        result[node]=sub(mul(local[node],diagonal),mul(applyNativeFineInverse(a.hierarchy,node,off),coupling));}
    // One disjoint destination per node. Readers consume this completed view;
    // there is no product buffer, copy back or second launch inside iteration.
    __syncthreads();return result;
}
