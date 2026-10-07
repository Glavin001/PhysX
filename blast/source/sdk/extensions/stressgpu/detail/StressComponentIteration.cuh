#include "StressComponentPhaseProbe.cuh"
#include "StressComponentWorkProbe.cuh"
#include "StressProblemCaptureSymbols.cuh"
// Private native specialization, included after the shared resident arguments.
#ifdef PHYSX_RESIDENT_DESTRUCTION
// Every warp produces one fully overwritten partial. No floating atomics
// or scratch-clearing pass is needed; all lanes participate, including zero
// contributions from out-of-range or already converged rows.
__device__ __forceinline__ float componentSquaredNorm(float value)
{
    __shared__ float warpSums[kBlockSize/32];
    for(unsigned offset=16;offset;offset>>=1)
        value+=__shfl_down_sync(0xffffffffu,value,offset);
    if((threadIdx.x&31u)==0)warpSums[threadIdx.x/32]=value;
    __syncthreads();
    float sum=0;
    if(threadIdx.x==0)for(unsigned warp=0;warp<kBlockSize/32;++warp)sum+=warpSums[warp];
    return sum;
}

// Each CTA owns all iterations of one component at a time. Stable sorted node
// ranges make every vector/scalar write exclusive to that component; static
// boundary rows are read-only. No grid rendezvous or global loop counter is
// involved. The operator, recurrence, norm and convergence functions are the
// same ones used by the cooperative large-component implementation.
// Iterations without a 1% improvement of the best convergence norm after
// which a component is reported unconverged.
constexpr unsigned kStressStagnationWindow=512;

// Solve report (diagnostics, PersistentStressArgs::report): thread 0 only.
__device__ __forceinline__ void reportBegin(ExtStressGpuComponentReport* r,unsigned id,unsigned count,unsigned anchored)
{
    r->component=id;r->nodeCount=count;r->anchored=anchored;r->reason=ExtStressGpuStopUnreported;
    r->iterations=0;r->bestIteration=0;r->tolerance2=0;r->best2=INFINITY;r->final2=NAN;
    for(unsigned k=0;k<16;++k)r->history[k]=NAN;
}
// Residual^2 at iteration 0 and every power of two, and the best and last.
__device__ __forceinline__ void reportResidual(ExtStressGpuComponentReport* r,unsigned iteration,float value)
{
    if(value<r->best2){r->best2=value;r->bestIteration=iteration;}
    r->final2=value;
    if(iteration==0)r->history[0]=value;
    else if((iteration&(iteration-1u))==0u){unsigned k=0;while((1u<<k)<iteration)++k;if(k+1u<16u)r->history[k+1u]=value;}
}

// ||lambda0 + B^T mu||^2 over a component's live bonds, each counted once
// (the operator's ownership rule), in solver units: the bond forces this solve
// would publish if it stopped now (withSolution), or started with. Per thread;
// reduce with componentSquaredNorm.
__device__ __forceinline__ float componentForceNorm2(const PersistentStressArgs& a,const unsigned* nodes,unsigned count,bool withSolution)
{
    float sum=0;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){
        const unsigned node=nodes[i];
        for(unsigned k=a.m_nodeBondBegin[node];k<a.m_nodeBondBegin[node+1];++k){
            const unsigned ref=a.m_nodeBondRef[k];if(ref==kDeadBondRef)continue;
            const unsigned bond=ref&0x7FFFFFFFu;const bool second=(ref&0x80000000u)!=0u;
            if(a.m_health[bond]<=0.0f)continue;
            const Inertia other=a.m_inertia[second?a.m_node0[bond]:a.m_node1[bond]];
            if(second && !(other.angular==0.0f && other.linear==0.0f))continue;
            AngLin f=a.impulses[bond];
            if(withSolution){
                const unsigned n0=a.m_node0[bond],n1=a.m_node1[bond];
                const auto x=StressHierarchy::scaledValue(a.hierarchy.solution[n0],make_float2(a.m_inertia[n0].angular,a.m_inertia[n0].linear));
                const auto y=StressHierarchy::scaledValue(a.hierarchy.solution[n1],make_float2(a.m_inertia[n1].angular,a.m_inertia[n1].linear));
                const auto r0=a.m_offset0[bond],r1=a.m_offset1[bond];
                const auto d=bondScaled(a.m_angularScale,bond,StressHierarchy::sub(StressHierarchy::couple(x,makeStressReal3(r0.x,r0.y,r0.z)),
                    StressHierarchy::couple(y,makeStressReal3(r1.x,r1.y,r1.z))),StressReal(a.m_colScales[bond]));
                f.angular.x+=float(d.angular.x);f.angular.y+=float(d.angular.y);f.angular.z+=float(d.angular.z);
                f.linear.x+=float(d.linear.x);f.linear.y+=float(d.linear.y);f.linear.z+=float(d.linear.z);
            }
            sum+=f.angular.x*f.angular.x+f.angular.y*f.angular.y+f.angular.z*f.angular.z
                +f.linear.x*f.linear.x+f.linear.y*f.linear.y+f.linear.z*f.linear.z;
        }
    }
    return sum;
}

// Bond-balanced component operator (BLAST_STRESS_BALANCED_OPERATOR=1).
// One thread per node made every operator pass as slow as the node with the
// most bonds: car hubs carry 36-48 bonds against a median of 5-7, and the
// other 255 threads waited at the barrier for it. Rows are cut into chunks of
// ComponentChunks::kSlots CSR slots (StressNativePolynomial.cuh), built once a
// solve; a pass evaluates chunks on every thread and each node adds its chunks
// in order. A row of at most kSlots slots is one chunk and evaluates exactly
// as before. Returns false (use the node-per-thread passes) when the
// component has more chunks than the threadgroup's scratch holds.
// Fills start/codes (this threadgroup's scratch) and returns the chunk count,
// or ~0u when the component does not fit.
__device__ __forceinline__ unsigned buildComponentChunks(const PersistentStressArgs& a,const unsigned* nodes,unsigned count,
    unsigned* start,unsigned* codes){
    __shared__ unsigned segmentTotals[kBlockSize];__shared__ unsigned total;
    if(!a.componentChunkIndex || count>a.componentChunkCapacity)return ~0u;
    const unsigned segment=(count+blockDim.x-1)/blockDim.x,first=min(count,threadIdx.x*segment),last=min(count,first+segment);
    unsigned sum=0;
    for(unsigned i=first;i<last;++i){const unsigned node=nodes[i],slots=a.m_nodeBondBegin[node+1]-a.m_nodeBondBegin[node];
        const unsigned n=slots?(slots+ComponentChunks::kSlots-1)/ComponentChunks::kSlots:1u;start[i]=n;sum+=n;}
    segmentTotals[threadIdx.x]=sum;__syncthreads();
    if(!threadIdx.x){unsigned running=0;for(unsigned t=0;t<blockDim.x;++t){const unsigned v=segmentTotals[t];segmentTotals[t]=running;running+=v;}total=running;}
    __syncthreads();
    const unsigned chunkCount=total;
    if(chunkCount>a.componentChunkCapacity){__syncthreads();return ~0u;}
    unsigned running=segmentTotals[threadIdx.x];
    for(unsigned i=first;i<last;++i){const unsigned n=start[i];start[i]=running;
        for(unsigned j=0;j<n;++j)codes[running+j]=i|(j<<20);running+=n;}
    if(!threadIdx.x)start[count]=chunkCount;
    __syncthreads();
    return chunkCount;
}
// One balanced operator pass: w = L rho over the component (w null: the
// convergence norm only). Returns this thread's share of the squared norm;
// residual2 non-null records each node's share (the solve report).
__device__ __forceinline__ float componentOperatorBalanced(const PersistentStressArgs& a,const unsigned* nodes,unsigned count,
    const ComponentChunks chunks,AngLin* w,const AngLin* rho,float* residual2){
    for(unsigned k=threadIdx.x;k<chunks.count;k+=blockDim.x){const unsigned code=chunks.codes[k],node=nodes[code&0xFFFFFu];
        StressReal* out=chunks.partials+8*size_t(k);
        const unsigned island=a.m_nodeIsland[node];const Inertia inv=a.m_inertia[node];
        Vec4 accAng{0.0f,0.0f,0.0f,0.0f},accLin{0.0f,0.0f,0.0f,0.0f};float zSq=0.0f;
        if(!(island!=kNoIsland && !a.m_islandActive[island]) && !(inv.angular==0.0f && inv.linear==0.0f)){
            const AngLin selfRho=rho[node];
            const unsigned firstSlot=a.m_nodeBondBegin[node]+(code>>20)*ComponentChunks::kSlots;
            const unsigned lastSlot=min(firstSlot+ComponentChunks::kSlots,a.m_nodeBondBegin[node+1]);
            nodeSpaceBondRange(rho,a.m_inertia,a.m_nodeBondRef,a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,
                a.m_bondIsland,nullptr,w!=nullptr,mul(selfRho.angular,inv.angular),mul(selfRho.linear,inv.linear),firstSlot,lastSlot,accAng,accLin,zSq,a.m_angularWeight);
        }
        out[0]=accAng.x;out[1]=accAng.y;out[2]=accAng.z;out[3]=accLin.x;out[4]=accLin.y;out[5]=accLin.z;out[6]=zSq;
    }
    __syncthreads();
    float squared=0;
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes[i],island=a.m_nodeIsland[node];
        // As nodeSpaceMatvecBody: a retired island writes nothing; a static
        // row is zero.
        if(island!=kNoIsland && !a.m_islandActive[island])continue;
        const Inertia inv=a.m_inertia[node];
        if(inv.angular==0.0f && inv.linear==0.0f){if(w){w[node].angular=Vec4{0.0f,0.0f,0.0f,0.0f};w[node].linear=Vec4{0.0f,0.0f,0.0f,0.0f};}continue;}
        Vec4 accAng{0.0f,0.0f,0.0f,0.0f},accLin{0.0f,0.0f,0.0f,0.0f};float zSq=0.0f;
        for(unsigned k=chunks.start[i];k<chunks.start[i+1];++k){const StressReal* p=chunks.partials+8*size_t(k);
            accAng=add(accAng,Vec4{float(p[0]),float(p[1]),float(p[2]),0.0f});accLin=add(accLin,Vec4{float(p[3]),float(p[4]),float(p[5]),0.0f});zSq+=float(p[6]);}
        if(w){w[node].angular=mul(accAng,inv.angular);w[node].linear=mul(accLin,inv.linear);}
        if(island!=kNoIsland){const float contribution=stressSquaredContribution(zSq);squared+=contribution;if(residual2)residual2[node]=contribution;}
    }
    return squared;
}
// Bench-only phase ablation (gpu_component_solve_bench, BLAST_COMPONENT_ABLATION):
// a bit set skips one phase of every iteration so its latency shows as a time
// difference at a fixed iteration count. Results are meaningless when set.
// Production builds compile every check to false.
#ifdef BLAST_COMPONENT_ABLATION
__device__ unsigned componentAblation;
// Bench-only: components solved balanced, unbalanced, chunks, without scratch.
__device__ unsigned componentBalanceTrace[4];
#define COMPONENT_ABLATE(bit) ((componentAblation>>(bit))&1u)
#else
#define COMPONENT_ABLATE(bit) false
#endif
template<bool Rotation=false>
__global__ void componentStressSolve(
#if defined(PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT) && PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT
    PersistentStressArgs original,ResidentStressComponentView c,
    const StressHierarchy::CycleLevel* __restrict__ cycleLevels
#else
    PersistentStressArgs a,ResidentStressComponentView c
#endif
) {
#if defined(PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT) && PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT
    // Same separately allocated, immutable descriptor storage contract as the
    // cooperative entry point; no restrict promise applies to nested pointees.
    PersistentStressArgs a=original;
    a.hierarchy.cycle.levels=cycleLevels;
#endif
    if constexpr(!Rotation){a.m_angularScale=nullptr;a.m_angularWeight=nullptr;}
    __shared__ unsigned counts[2], iteration, activeCount, slot;
    __shared__ StressHierarchy::TerminalShared cycleShared;   // matched hierarchy's block-local cycle
    __shared__ SolveStatus status;
    __shared__ float reduceValue;
    // Stagnation: the best convergence norm so far and when it was reached.
    __shared__ float bestResidual;
    __shared__ unsigned bestIteration;
    // Force convergence: the last step's change of the bond forces, the sum of
    // those changes, and the force norm at the start (forceTolerance > 0).
    __shared__ float forceStep,forceTravel,forceStart;
    __shared__ bool forcePass;
    COMPONENT_PROBE_BEGIN
    // Components have very different convergence costs after fracture. A CTA
    // claims its next independent component only when its previous one finishes;
    // fixed grid-stride ownership can strand expensive components on one SM.
    // Only integer dispatch order changes, never a component's numerical order.
    for(;;) {
        if(threadIdx.x==0)slot=atomicAdd(c.workCursor,1u);
        __syncthreads();
        if(slot>=*c.count)break;
        const unsigned id=c.ids[slot], begin=c.begin[id], count=c.end[id]-begin;
        // Every live component publishes a defined verification flag before
        // the subsequent cooperative kernel visits the shared active-node list.
        if(!threadIdx.x)a.hierarchy.verification[id]=0;
        if(count>kResidentComponentMaxNodes) {
            if(a.report && !threadIdx.x){reportBegin(a.report+id,id,count,0u);a.report[id].reason=ExtStressGpuStopCooperative;}
            COMPONENT_WORK_UNMEASURED(id,count)
            // All readers must finish using the shared ticket before reuse.
            __syncthreads();continue;
        }
        if(!nativeHierarchyReady(a.hierarchy)){
            if(!threadIdx.x){c.results[id]={1u,a.maxIterations,0u};a.m_islandActive[id]=0;
                if(a.report){reportBegin(a.report+id,id,count,0u);a.report[id].reason=ExtStressGpuStopNotReady;}}
            __syncthreads();continue;
        }
        if(threadIdx.x==0) {
            a.hierarchy.previous[id]=0;a.hierarchy.failed[id]=0;
            counts[0]=0;counts[1]=count;iteration=0;activeCount=0;
            status={1u,a.maxIterations,0u};
            bestResidual=INFINITY;bestIteration=0;
            if(a.report)reportBegin(a.report+id,id,count,a.hierarchy.modes.components[id].anchored);
        }
        __syncthreads();
        COMPONENT_WORK_BEGIN(a,c,id,begin,count)
        if(a.settledIslands && a.settledIslands[id]){
            if(!threadIdx.x){status={0u,0u,1u};COMPONENT_WORK_END(id,status) c.results[id]=status;
                if(a.report)a.report[id].reason=ExtStressGpuStopSettled;}
            __syncthreads();continue;
        }
        // Cache validity belongs to each built operator, independently of a
        // solve's success. Each node has one writer in this owning component.
        for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)buildNativeRigidInverse(a.hierarchy,c.nodes[begin+i]);
        __syncthreads();
#if defined(PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT) && PX_CUMETAL_EXPLICIT_HIERARCHY_ROOT
        // Retirement never reads cycle descriptors. All fields it consumes
        // still match original; keep the rebound root out of this retained call.
        retireHomogeneousTreeComponent(original,c.nodes+begin,count,id);
#else
        retireHomogeneousTreeComponent(a,c.nodes+begin,count,id);
#endif
        const unsigned nodeBlocks=(count+blockDim.x-1)/blockDim.x;
        unsigned* chunkStart=a.componentChunkIndex+size_t(blockIdx.x)*(2*size_t(a.componentChunkCapacity)+1);
        const unsigned chunkCount=buildComponentChunks(a,c.nodes+begin,count,chunkStart,chunkStart+a.componentChunkCapacity+1);
        const bool balanced=chunkCount!=~0u;
        const ComponentChunks chunks{chunkStart,chunkStart+a.componentChunkCapacity+1,
            a.componentChunkPartials+size_t(blockIdx.x)*8*size_t(a.componentChunkCapacity),balanced?chunkCount:0u};
#ifdef BLAST_COMPONENT_ABLATION
        if(!threadIdx.x){atomicAdd(componentBalanceTrace+(balanced?0:1),1u);atomicAdd(componentBalanceTrace+2,chunks.count);
            if(!a.componentChunkIndex)atomicAdd(componentBalanceTrace+3,1u);}
#endif
        if(a.forceTolerance>0){
            const float start=componentSquaredNorm(componentForceNorm2(a,c.nodes+begin,count,false));
            if(!threadIdx.x){forceStart=sqrtf(start);forceTravel=0;forceStep=INFINITY;}
            __syncthreads();
        }
        do {
            if(a.m_islandActive[id] && !COMPONENT_ABLATE(1))prepareNativeResidualComponent(a,c.nodes+begin,count,id);
            COMPONENT_PROBE_END(0)
            COMPONENT_WORK_SWEEP(a,id,residualSweeps)
            float squared=COMPONENT_ABLATE(0)?1.f:0.f;
            if(balanced && !COMPONENT_ABLATE(0))squared=componentOperatorBalanced(a,c.nodes+begin,count,chunks,nullptr,a.m_residual,a.nodeResidual2);
            for(unsigned block=0;block<nodeBlocks && !COMPONENT_ABLATE(0) && !balanced;++block) {
                float contribution=0;
                nodeSpaceMatvecBody(nullptr,a.m_residual,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,
                    a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,
                    nullptr,a.m_nodeIsland,a.m_islandActive,true,nullptr,1u,c.nodes+begin,
                    counts,&iteration,0u,block,&contribution,a.m_angularWeight);
                if(a.nodeResidual2){const unsigned local=block*blockDim.x+threadIdx.x;if(local<count)a.nodeResidual2[c.nodes[begin+local]]=contribution;}
                squared+=contribution;
            }
            const float numerator=componentSquaredNorm(squared);
            if(threadIdx.x==0)reduceValue=numerator;
            __syncthreads();
            if((iteration || a.warmStart) && a.m_islandActive[id] && a.m_deltaSquared[id]>0 && reduceValue<=a.m_deltaSquared[id]){
                for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)rebuildNativeResidualNode(a,c.nodes[begin+i]);
                if(!threadIdx.x)a.hierarchy.previous[id]=0;__syncthreads();
                prepareNativeResidualComponent(a,c.nodes+begin,count,id);
                COMPONENT_WORK_SWEEP(a,id,verificationSweeps)
                float verified=balanced?componentOperatorBalanced(a,c.nodes+begin,count,chunks,nullptr,a.m_residual,a.nodeResidual2):0.f;
                for(unsigned block=0;block<nodeBlocks && !balanced;++block){float contribution=0;
                    nodeSpaceMatvecBody(nullptr,a.m_residual,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,
                        nullptr,a.m_nodeIsland,a.m_islandActive,true,nullptr,1u,c.nodes+begin,counts,&iteration,0u,block,&contribution,a.m_angularWeight);
                    if(a.nodeResidual2){const unsigned local=block*blockDim.x+threadIdx.x;if(local<count)a.nodeResidual2[c.nodes[begin+local]]=contribution;}
                    verified+=contribution;
                }
                const float norm=componentSquaredNorm(verified);if(!threadIdx.x)reduceValue=norm;__syncthreads();
            }
            COMPONENT_PROBE_END(1)
            // A component that has stopped converging is reported unconverged
            // now rather than at the iteration cap. Anchored components that
            // settle a few times above tolerance otherwise spend the whole
            // cap on a plateau: 8192 iterations for the verdict the state
            // already gives. The best norm must improve by 1% in the window.
            if(!threadIdx.x && a.m_islandActive[id]){
                if(a.report)reportResidual(a.report+id,iteration,reduceValue);
                STRESS_CAPTURE_HISTORY(id,iteration,0u,reduceValue)
                if(reduceValue<bestResidual*0.99f){bestResidual=reduceValue;bestIteration=iteration;}
                else if(iteration-bestIteration>=kStressStagnationWindow){status.active=0;status.iterations=iteration;
                    if(a.report)a.report[id].reason=ExtStressGpuStopStagnated;}
            }
            __syncthreads();
            if(!status.active)break;
            finalizeAndCheckConvergenceBody(&reduceValue,a.m_gradientSquared,1u,
                a.m_islandActive,a.m_islandConverged,a.m_deltaSquared,&activeCount,1u,nullptr,0u,c.ids+slot,id);
            __syncthreads();
            if(a.forceTolerance>0 && iteration>0 && a.m_islandActive[id]){
                // The bond forces stopped moving: the last step changed them by
                // at most forceTolerance of their size. The running bound
                // ||lambda|| <= ||lambda0|| + sum of steps screens; the exact
                // norm decides.
                if(!threadIdx.x)forcePass=forceStep<=a.forceTolerance*(forceStart+forceTravel);
                __syncthreads();
                if(forcePass){
                    const float exact=componentSquaredNorm(componentForceNorm2(a,c.nodes+begin,count,true));
                    if(!threadIdx.x && forceStep<=a.forceTolerance*sqrtf(exact)){a.m_islandActive[id]=0;a.m_islandConverged[id]=1;}
                    __syncthreads();
                }
            }
            COMPONENT_PROBE_END(2)
            // The complete convergence verdict is already known for this
            // component. Retire directly instead of executing inactive gamma,
            // direction, matrix-product and update stages plus their barriers.
            // Preserve the final scratch/status writes of finalizeAndRetireBody.
            if(!a.m_islandActive[id]){
                if(!threadIdx.x){
                    a.hierarchy.gamma[id]=0;a.m_projectedDirectionSquared[id]=0;
                    status.active=0;status.converged=1;status.iterations=iteration;++iteration;
                }
                __syncthreads();break;
            }
            COMPONENT_WORK_PRECONDITION(a,id,iteration)
            float localGamma=0;
            if(a.m_islandActive[id] && !COMPONENT_ABLATE(2))localGamma=preconditionNativeComponent<Rotation>(a,c.nodes+begin,count,id,iteration COMPONENT_SUBPROBE_ARGUMENT,balanced,chunks,&cycleShared);
            if(COMPONENT_ABLATE(2))localGamma=threadIdx.x?0.f:1.f;
            const float gamma=componentSquaredNorm(localGamma);
            if(!threadIdx.x){a.hierarchy.gamma[id]=gamma;STRESS_CAPTURE_HISTORY(id,iteration,1u,gamma)if(a.m_islandActive[id] && (!(gamma>0) || !isfinite(gamma)))a.hierarchy.failed[id]=1;}
            __syncthreads();
            COMPONENT_PROBE_END(3)
            if(!COMPONENT_ABLATE(3))for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)updateNativeDirection(a,c.nodes[begin+i],id,iteration);
            __syncthreads();
            COMPONENT_PROBE_END(4)
            COMPONENT_WORK_SWEEP(a,id,directionSweeps)
            squared=COMPONENT_ABLATE(4)?1.f:0.f;
            if(balanced && !COMPONENT_ABLATE(4))squared=componentOperatorBalanced(a,c.nodes+begin,count,chunks,a.m_nsQ,a.m_nsPi,nullptr);
            for(unsigned block=0;block<nodeBlocks && !COMPONENT_ABLATE(4) && !balanced;++block) {
                float contribution=0;
                nodeSpaceMatvecBody(a.m_nsQ,a.m_nsPi,a.m_inertia,a.m_nodeBondBegin,a.m_nodeBondRef,a.m_node0,a.m_node1,
                    a.m_offset0,a.m_offset1,a.m_health,a.m_colScales,a.m_bondIsland,nullptr,a.m_nodeIsland,a.m_islandActive,true,
                    nullptr,1u,c.nodes+begin,counts,&iteration,0u,block,&contribution,a.m_angularWeight);
                squared+=contribution;
            }
            const float denominator=componentSquaredNorm(squared);
            if(threadIdx.x==0){reduceValue=denominator;STRESS_CAPTURE_HISTORY(id,iteration,2u,denominator)
                // ||dlambda|| = alpha ||B^T p|| = gamma / sqrt(p'Lp); invariant
                // under the per-component normalization of g. Only a
                // preconditioned step is judged: the projected steepest-descent
                // step of iteration 0 is small exactly when the error sits in
                // soft modes (oracle, 881 captured car solves: judged from
                // iteration 0, stops after one step carried up to 42% force
                // error; from iteration 1, at most 0.4% at tolerance 1e-3).
                if(a.forceTolerance>0){const float g=a.hierarchy.gamma[id];
                    const float step=denominator>0 && g>0?g/sqrtf(denominator):INFINITY;
                    if(isfinite(step))forceTravel+=step;
                    forceStep=(iteration>0 || a.firstPolynomial)?step:INFINITY;}}
            __syncthreads();
            COMPONENT_PROBE_END(5)
            finalizeAndRetireBody(&reduceValue,a.m_projectedDirectionSquared,1u,
                a.m_islandActive,a.hierarchy.previous,a.hierarchy.gamma,&status,&activeCount,1u,
                &iteration,1u,0,a.maxIterations,nullptr,0u,c.ids+slot,id);
            __syncthreads();
            if(!COMPONENT_ABLATE(5))for(unsigned i=threadIdx.x;i<count;i+=blockDim.x)updateNativeStressSolution(a,c.nodes[begin+i],id,iteration);
            __syncthreads();
            COMPONENT_PROBE_END(6)
#ifdef BLAST_GPU_NATIVE_CYCLE_DIAGNOSTIC
            if(!threadIdx.x && (iteration&(iteration-1))==0)printf("native history id=%g nodes=%g iteration=%g residual2=%g tolerance2=%g gamma=%g direction_energy=%g failed=%g\n",double(id),double(count),double(iteration),double(a.m_gradientSquared[id]),double(a.m_deltaSquared[id]),double(a.hierarchy.gamma[id]),double(a.m_projectedDirectionSquared[id]),double(a.hierarchy.failed[id]));
#endif
        } while(status.active && iteration<a.maxIterations);
        if(threadIdx.x==0) {
            if(a.hierarchy.failed[id] || !a.m_islandConverged[id])status.converged=0;
#ifdef BLAST_GPU_NATIVE_CYCLE_DIAGNOSTIC
            // Every argument as a double: a packed argument list, which typed
            // printf on the Metal backend requires.
            if(!status.converged)printf("native component id=%g nodes=%g iterations=%g active=%g failed=%g residual2=%g tolerance2=%g gamma=%g direction_energy=%g anchored=%g rotations=%g\n",double(id),double(count),double(status.iterations),double(status.active),double(a.hierarchy.failed[id]),double(a.m_gradientSquared[id]),double(a.m_deltaSquared[id]),double(a.hierarchy.gamma[id]),double(a.m_projectedDirectionSquared[id]),double(a.hierarchy.modes.components[id].anchored),double(a.hierarchy.modes.components[id].rotations));
#endif
            COMPONENT_WORK_END(id,status)
            if(a.report){
                ExtStressGpuComponentReport* r=a.report+id;
                if(a.hierarchy.failed[id])r->reason=ExtStressGpuStopFailed;
                else if(r->reason==ExtStressGpuStopUnreported)
                    r->reason=status.converged?ExtStressGpuStopConverged:
                        (status.active && status.iterations>=a.maxIterations)?ExtStressGpuStopIterationCap:ExtStressGpuStopDegenerate;
                r->iterations=status.iterations;r->tolerance2=a.m_deltaSquared[id];
            }
            c.results[id]=status;
            a.hierarchy.settled.verifiedStoredOutput[id]=a.warmStart && status.converged && status.iterations==0;
            // The cooperative stage must never update a small component,
            // including one that exhausted its iteration budget. Its failed
            // status survives separately and rejects the complete solve.
            a.m_islandActive[id]=0;
        }
        __syncthreads();
    }
    COMPONENT_PROBE_PUBLISH
}

#undef COMPONENT_PROBE_BEGIN
#undef COMPONENT_PROBE_END
#undef COMPONENT_PROBE_PUBLISH

// Merge per-component convergence only after both workload specializations
// finish. A small component reaching the cap cannot be hidden by a successful
// large component (or an empty large-component list).
__global__ void finishComponentStress(PersistentStressArgs a, ResidentStressComponentView c)
{
    __shared__ unsigned iterations[kBlockSize], active[kBlockSize], failed[kBlockSize];
    unsigned maxIterations=0,activeComponents=0,notConverged=0;
    for(unsigned slot=threadIdx.x;slot<*c.count;slot+=blockDim.x) {
        const unsigned id=c.ids[slot];
        if(c.end[id]-c.begin[id]>kResidentComponentMaxNodes)continue;
        const auto status=c.results[id];
        maxIterations=max(maxIterations,status.iterations);
        activeComponents+=status.active;notConverged+=!status.converged;
    }
    iterations[threadIdx.x]=maxIterations;active[threadIdx.x]=activeComponents;failed[threadIdx.x]=notConverged;
    __syncthreads();
    for(unsigned stride=blockDim.x/2;stride;stride>>=1) {
        if(threadIdx.x<stride) {
            iterations[threadIdx.x]=max(iterations[threadIdx.x],iterations[threadIdx.x+stride]);
            active[threadIdx.x]+=active[threadIdx.x+stride];failed[threadIdx.x]+=failed[threadIdx.x+stride];
        }
        __syncthreads();
    }
    if(threadIdx.x==0) {
        a.m_status->active+=active[0];
        a.m_status->iterations=max(a.m_status->iterations,iterations[0]);
        a.m_status->converged=a.m_status->converged && failed[0]==0;
        *a.m_iteration=min(a.maxIterations,a.m_status->iterations+1u);
    }
}
#endif
