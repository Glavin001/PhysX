// Null modes and projection for Apple GPUs (PX_CUMETAL); the double version is
// StressMotionModes.cuh. The construction runs as a chain of ordinary launches
// (a cooperative grid is one threadgroup under CuMetal, where the fused kernel
// took 28-59 ms), and the frame is built in float pairs from the exact forest.
// The projection runs every solver iteration. Its frame -- each node's offset
// from the component center, the axis, the scaled Gram factor -- is stored in
// solver precision once per construction, which is exactly what the double
// version converted on every call.
#pragma once
namespace Nv { namespace Blast { namespace StressHierarchy {
struct MotionModeView {const StressReal3* relative=nullptr;const MotionComponent* components=nullptr;const Status* status=nullptr;const unsigned* forest=nullptr;};
__device__ __forceinline__ unsigned motionDimension(const MotionComponent& c){return c.anchored?0:c.rotations+3;}
template<class T,unsigned Count>
__device__ void reduceMotionValues(T (&values)[Count],T (&partial)[Count][Threads/32]){
    for(unsigned k=0;k<Count;++k)values[k]=warpSum(values[k]);
    if(!(threadIdx.x&31u))for(unsigned k=0;k<Count;++k)partial[k][threadIdx.x/32]=values[k];
    __syncthreads();
    if(!threadIdx.x)for(unsigned k=0;k<Count;++k){values[k]=0;for(unsigned warp=0;warp<Threads/32;++warp)values[k]+=partial[k][warp];}
    __syncthreads();
}
template<unsigned Count>
__device__ void reduceMotionPairs(MotionPair (&values)[Count],MotionPair (&partial)[Count][Threads/32]){
    for(unsigned k=0;k<Count;++k)for(unsigned offset=16;offset;offset>>=1)
        values[k]=add(values[k],MotionPair{__shfl_down_sync(0xffffffffu,values[k].hi,offset),__shfl_down_sync(0xffffffffu,values[k].lo,offset)});
    if(!(threadIdx.x&31u))for(unsigned k=0;k<Count;++k)partial[k][threadIdx.x/32]=values[k];
    __syncthreads();
    if(!threadIdx.x)for(unsigned k=0;k<Count;++k){values[k]={};for(unsigned warp=0;warp<Threads/32;++warp)values[k]=add(values[k],partial[k][warp]);}
    __syncthreads();
}
__device__ __forceinline__ MotionPair motionInverseSquare(float x){float p,e;motionTwoProd(x,x,p,e);return motionDiv(motionPair(1.f),{p,e});}
__device__ __forceinline__ MotionPair motionEntry(MotionPair3 a,unsigned i){return i==0?a.x:(i==1?a.y:a.z);}
// cross(q, axis k): the unit axes need no arithmetic.
__device__ __forceinline__ MotionPair3 motionMoment(const MotionComponent& c,MotionPair3 q,unsigned k){
    if(c.rotations==1)return cross(q,c.axis);
    const MotionPair zero{};
    return k==0?MotionPair3{zero,q.z,neg(q.y)}:(k==1?MotionPair3{neg(q.z),zero,q.x}:MotionPair3{q.y,neg(q.x),zero});
}
__device__ void buildMotionFactor(Input a,MotionBuffers b,Status* status,unsigned id){
    auto& c=b.components[id];if(c.anchored)return;
    __shared__ MotionPair centers[4][Threads/32],blocks[21][Threads/32];__shared__ MotionPair3 center;
    const unsigned begin=a.partition.begin[id],end=a.partition.end[id],dimension=motionDimension(c);
    MotionPair sums[4]{};
    for(unsigned i=begin+threadIdx.x;i<end;i+=blockDim.x){const auto node=orderedNode(a,i);
        const MotionPair w=motionInverseSquare(a.inertia[node].y);const auto p=motionPair(b.position[node]);
        sums[0]=add(sums[0],w);sums[1]=add(sums[1],mul(p.x,w));sums[2]=add(sums[2],mul(p.y,w));sums[3]=add(sums[3],mul(p.z,w));}
    reduceMotionPairs(sums,centers);
    if(!threadIdx.x){if(!(sums[0].hi>0) || !motionFinite(sums[0]))atomicOr(&status->error,4u);
        center={motionDiv(sums[1],sums[0]),motionDiv(sums[2],sums[0]),motionDiv(sums[3],sums[0])};}
    __syncthreads();MotionPair gram[21]{};
    const MotionPair axial=c.rotations==1?dot(c.axis,c.axis):motionPair(1.f);
    for(unsigned i=begin+threadIdx.x;i<end;i+=blockDim.x){const auto node=orderedNode(a,i);const auto d=a.inertia[node];
        const auto q=sub(motionPair(b.position[node]),center);const MotionPair w=motionInverseSquare(d.y),angular=motionInverseSquare(d.x);
        b.relative[node]=makeStressReal3(motionStressReal(q.x),motionStressReal(q.y),motionStressReal(q.z));
        MotionPair3 moment[3];for(unsigned k=0;k<c.rotations;++k)moment[k]=motionMoment(c,q,k);
        for(unsigned row=0;row<dimension;++row)for(unsigned col=0;col<=row;++col){MotionPair value{};
            if(row<c.rotations){
                // Evaluate the actual basis vectors, rather than subtracting
                // nearly equal squared lengths for long, slender components.
                value=add(row==col?mul(angular,axial):MotionPair{},mul(w,dot(moment[row],moment[col])));}
            else if(col<c.rotations)value=mul(w,motionEntry(moment[col],row-c.rotations));
            else if(row==col)value=w;
            gram[triangle(row,col)]=add(gram[triangle(row,col)],value);
        }
    }
    reduceMotionPairs(gram,blocks);
    if(!threadIdx.x){MotionPair scale[6],factor[21];
        for(unsigned i=0;i<dimension;++i){const MotionPair diagonal=gram[triangle(i,i)];
            if(!(diagonal.hi>0) || !motionFinite(diagonal)){atomicOr(&status->error,4u);return;}
            scale[i]=motionDiv(motionPair(1.f),motionSqrt(diagonal));c.scale[i]=motionStressReal(scale[i]);}
        for(unsigned row=0;row<dimension;++row)for(unsigned col=0;col<=row;++col){
            MotionPair value=mul(mul(gram[triangle(row,col)],scale[row]),scale[col]);
            for(unsigned k=0;k<col;++k)value=sub(value,mul(factor[triangle(row,k)],factor[triangle(col,k)]));
            if(row==col){if(!(value.hi>0) || !motionFinite(value)){atomicOr(&status->error,4u);return;}value=motionSqrt(value);}
            else value=motionDiv(value,factor[triangle(col,col)]);
            factor[triangle(row,col)]=value;c.factor[triangle(row,col)]=motionStressReal(value);
        }
    }
}
// Each phase runs only while the construction is live, exactly where the
// cooperative kernel would still have been running; every phase is a
// grid-stride loop with order-independent atomics.
__device__ __forceinline__ unsigned motionThread(){return blockIdx.x*blockDim.x+threadIdx.x;}
__device__ __forceinline__ unsigned motionStride(){return gridDim.x*blockDim.x;}
__device__ __forceinline__ bool motionLive(const Work* work){return work->active && work->pending;}
__global__ void beginMotionModes(Input a,Status* status,Work* work){beginBuild(a,status,work);}
__global__ void checkpointMotionModes(Status* status,Work* work){if(work->active)work->pending=!status->error;}
__global__ void initializeMotionModes(Input a,const unsigned* forest,MotionBuffers b,Status* status,Work* work){
    if(work->active)initializeMotionForest(a,forest,b,status,motionThread(),motionStride());
}
__global__ void tourMotionModes(Input a,const unsigned* forest,MotionBuffers b,Status* status,Work* work){
    if(!motionLive(work))return;
    for(unsigned node=motionThread()/32;node<a.nodes;node+=motionStride()/32)buildMotionTour(a,forest,b,status,node);
}
__global__ void cutMotionModes(Input a,const unsigned* forest,MotionBuffers b,Work* work){
    if(!motionLive(work))return;
    // Every tree component must have exactly one broken Euler-tour link.
    for(unsigned arc=motionThread();arc<2*a.bonds;arc+=motionStride())if(forest[arc/2]){
        auto& c=b.components[a.component[a.node0[arc/2]]];
        if(b.previous[0][arc]==Invalid)atomicAdd(&c.cuts,1u);if(!(arc&1u))atomicAdd(&c.edges,1u);
    }
}
__global__ void jumpMotionModes(Input a,const unsigned* forest,MotionBuffers b,Status* status,Work* work,unsigned source){
    if(motionLive(work))jumpMotionTour(a,forest,b,status,source,motionThread(),motionStride());
}
__global__ void publishMotionModes(Input a,const unsigned* forest,MotionBuffers b,Status* status,Work* work,unsigned source){
    if(motionLive(work))publishMotionPositions(a,forest,b,status,source,motionThread(),motionStride());
}
__global__ void closeMotionModes(Input a,MotionBuffers b,Status* status,Work* work){
    if(motionLive(work))discoverMotionClosures(a,b,status,motionThread(),motionStride());
}
__global__ void axisMotionModes(Input a,MotionBuffers b,Status* status,Work* work){
    if(motionLive(work))initializeMotionAxes(a,b,status,motionThread(),motionStride());
}
__global__ void constrainMotionModes(Input a,MotionBuffers b,Status* status,Work* work){
    if(motionLive(work))constrainMotionAxes(a,b,status,motionThread(),motionStride());
}
__global__ void buildMotionFactors(Input a,MotionBuffers b,Status* status,Work* work){
    if(!motionLive(work))return;
    for(unsigned slot=blockIdx.x;slot<*a.partition.count;slot+=gridDim.x){buildMotionFactor(a,b,status,a.partition.ids[slot]);__syncthreads();}
}
__global__ void commitMotionModes(Input a,Status* status,Work* work){
    if(motionLive(work))commitBuild(&a,status);
}
// The double version's projection, operation for operation, reading the
// stored solver-precision frame instead of converting it.
__device__ __forceinline__ StressReal3 motionAxisReal(const MotionComponent& c,unsigned coordinate){
    if(coordinate>=c.rotations)return {};if(c.rotations==1)return c.frameAxis;
    return makeStressReal3(StressReal(coordinate==0),StressReal(coordinate==1),StressReal(coordinate==2));
}
__device__ __forceinline__ StressReal motionDotReal(StressReal3 a,StressReal3 b){return a.x*b.x+a.y*b.y+a.z*b.z;}
__device__ void projectMotionComponent(Input a,MotionModeView modes,unsigned id,const unsigned* nodes,unsigned count,Vector* values){
    const auto& c=modes.components[id];const unsigned dimension=motionDimension(c);if(!dimension)return;
    __shared__ StressReal partial[6][Threads/32],coefficients[6];StressReal sum[6]{};
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes?nodes[i]:a.partition.begin[id]+i;
        const auto d=a.inertia[node];const auto q=modes.relative[node];const auto value=values[node];
        const auto linear=mul(value.linear,StressReal(1)/d.y),rotation=sub(mul(value.angular,StressReal(1)/d.x),cross(q,linear));
        for(unsigned k=0;k<c.rotations;++k)sum[k]+=motionDotReal(motionAxisReal(c,k),rotation);
        sum[c.rotations]+=linear.x;sum[c.rotations+1]+=linear.y;sum[c.rotations+2]+=linear.z;
    }
    reduceMotionValues(sum,partial);
    if(!threadIdx.x){
        for(unsigned row=0;row<dimension;++row){StressReal value=sum[row]*c.scale[row];for(unsigned j=0;j<row;++j)value-=c.factor[triangle(row,j)]*coefficients[j];coefficients[row]=value/c.factor[triangle(row,row)];}
        for(int row=int(dimension)-1;row>=0;--row){for(unsigned j=row+1;j<dimension;++j)coefficients[row]-=c.factor[triangle(j,row)]*coefficients[j];coefficients[row]/=c.factor[triangle(row,row)];}
        for(unsigned k=0;k<dimension;++k)coefficients[k]*=c.scale[k];
    }
    __syncthreads();StressReal3 omega{};for(unsigned k=0;k<c.rotations;++k)omega=add(omega,mul(motionAxisReal(c,k),coefficients[k]));
    const StressReal3 translation={coefficients[c.rotations],coefficients[c.rotations+1],coefficients[c.rotations+2]};
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes?nodes[i]:a.partition.begin[id]+i;
        const auto d=a.inertia[node];const auto q=modes.relative[node];auto& v=values[node];
        v.angular=sub(v.angular,mul(omega,StressReal(1)/d.x));v.linear=sub(v.linear,mul(add(translation,cross(q,omega)),StressReal(1)/d.y));}
    __syncthreads();
}
class ResidentMotionModes {
    Input mInput;const unsigned* mForest;cudaStream_t mStream;
    MotionBuffers mBuffers{};Status* mStatus=nullptr;Work* mWork=nullptr;
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident motion modes: ")+cudaGetErrorString(e));}
    template<class T>static void allocate(T*& p,size_t count){check(cudaMalloc(&p,std::max(size_t(1),count)*sizeof(T)));}
    void release()noexcept{for(unsigned k=0;k<2;++k){cudaFree(mBuffers.previous[k]);cudaFree(mBuffers.sum[k]);}cudaFree(mBuffers.first);cudaFree(mBuffers.position);cudaFree(mBuffers.components);cudaFree(mBuffers.relative);cudaFree(mStatus);cudaFree(mWork);}
public:
    ResidentMotionModes(Input input,const unsigned* forest,cudaStream_t stream):mInput(input),mForest(forest),mStream(stream){
        if(input.levelBonds || input.nodes>0x7fffffffu || input.bonds>0x7fffffffu || !input.generation || !input.partition.count
            || (input.nodes && (!input.begin||!input.component||!input.inertia||!input.partition.begin||!input.partition.end||!input.partition.ids))
            || (input.bonds && (!forest||!input.node0||!input.node1||!input.refs||!input.health||!input.scale||!input.offset0||!input.offset1)))
            throw std::runtime_error("Invalid native motion-mode view");
        try{
            for(unsigned k=0;k<2;++k){allocate(mBuffers.previous[k],size_t(input.bonds)*2);allocate(mBuffers.sum[k],size_t(input.bonds)*2);}
            allocate(mBuffers.first,input.nodes);allocate(mBuffers.position,input.nodes);allocate(mBuffers.components,input.nodes);allocate(mBuffers.relative,input.nodes);
            allocate(mStatus,1);allocate(mWork,1);check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));
        }catch(...){release();throw;}
    }
    ~ResidentMotionModes(){cudaStreamSynchronize(mStream);release();}
    ResidentMotionModes(const ResidentMotionModes&)=delete;ResidentMotionModes& operator=(const ResidentMotionModes&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        // Arguments are copied into each node, so one args array per shape serves every node.
        Input input=mInput;const unsigned* forest=mForest;MotionBuffers buffers=mBuffers;Status* status=mStatus;Work* work=mWork;unsigned source=0;
        const unsigned blocks=std::max(1u,std::min(4096u,unsigned((std::max<std::uint64_t>(input.nodes,2ull*input.bonds)+Threads-1)/Threads)));
        auto add=[&](void* func,unsigned grid,unsigned threads,void** args){
            cudaKernelNodeParams p{};p.func=func;p.gridDim=dim3(grid);p.blockDim=dim3(threads);p.kernelParams=args;
            cudaGraphNode_t node;check(cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&p));prior=node;
        };
        void* beginArgs[]={&input,&status,&work};
        void* checkpointArgs[]={&status,&work};
        void* forestArgs[]={&input,&forest,&buffers,&status,&work};
        void* cutArgs[]={&input,&forest,&buffers,&work};
        void* bufferArgs[]={&input,&buffers,&status,&work};
        void* commitArgs[]={&input,&status,&work};
        add((void*)beginMotionModes,1,1,beginArgs);
        add((void*)initializeMotionModes,blocks,Threads,forestArgs);
        add((void*)checkpointMotionModes,1,1,checkpointArgs);
        add((void*)tourMotionModes,blocks,Threads,forestArgs);
        add((void*)cutMotionModes,blocks,Threads,cutArgs);
        add((void*)checkpointMotionModes,1,1,checkpointArgs);
        for(std::uint64_t covered=1;covered<2ull*input.bonds;covered*=2){
            void* jumpArgs[]={&input,&forest,&buffers,&status,&work,&source};
            add((void*)jumpMotionModes,blocks,Threads,jumpArgs);source^=1u;
        }
        void* publishArgs[]={&input,&forest,&buffers,&status,&work,&source};
        add((void*)publishMotionModes,blocks,Threads,publishArgs);
        add((void*)closeMotionModes,blocks,Threads,bufferArgs);
        add((void*)axisMotionModes,blocks,Threads,bufferArgs);
        add((void*)constrainMotionModes,blocks,Threads,bufferArgs);
        add((void*)checkpointMotionModes,1,1,checkpointArgs);
        // Components never outnumber nodes; blocks past the live count return.
        add((void*)buildMotionFactors,std::min(std::max(1u,input.nodes),4096u),Threads,bufferArgs);
        add((void*)commitMotionModes,1,1,commitArgs);
        return prior;
    }
    MotionModeView view()const{return {mBuffers.relative,mBuffers.components,mStatus,mForest};}
    const Status* status()const{return mStatus;}
    // Exact node positions, for validation against the double implementation.
    const MotionExact3* positions()const{return mBuffers.position;}
};
}}}
