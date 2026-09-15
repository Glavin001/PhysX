// GPU-resident null modes and orthogonal projection for the fine stress operator.
#pragma once
#include "StressMotionForest.cuh"
#include <algorithm>
#include <stdexcept>
#include <string>
namespace Nv { namespace Blast { namespace StressHierarchy {
struct MotionModeView {const double3* position=nullptr;const MotionComponent* components=nullptr;const Status* status=nullptr;const unsigned* forest=nullptr;};
__device__ __forceinline__ unsigned motionDimension(const MotionComponent& c){return c.anchored?0:c.rotations+3;}
__device__ __forceinline__ double3 motionAxis(const MotionComponent& c,unsigned coordinate){
    if(coordinate>=c.rotations)return {};if(c.rotations==1)return c.axis;
    return {double(coordinate==0),double(coordinate==1),double(coordinate==2)};
}
__device__ __forceinline__ double motionDot(double3 a,double3 b){return a.x*b.x+a.y*b.y+a.z*b.z;}
__device__ __forceinline__ double motionEntry(double3 a,unsigned i){return i==0?a.x:(i==1?a.y:a.z);}
template<unsigned Count>
__device__ void reduceMotionValues(double (&values)[Count],double (&partial)[Count][Threads/32]){
    for(unsigned k=0;k<Count;++k)values[k]=warpSum(values[k]);
    if(!(threadIdx.x&31u))for(unsigned k=0;k<Count;++k)partial[k][threadIdx.x/32]=values[k];
    __syncthreads();
    if(!threadIdx.x)for(unsigned k=0;k<Count;++k){values[k]=0;for(unsigned warp=0;warp<Threads/32;++warp)values[k]+=partial[k][warp];}
    __syncthreads();
}
__device__ void buildMotionFactor(Input a,MotionBuffers b,Status* status,unsigned id){
    auto& c=b.components[id];if(c.anchored || !motionChanged(b,id))return;
    __shared__ double centers[4][Threads/32],blocks[21][Threads/32];
    const unsigned begin=a.partition.begin[id],end=a.partition.end[id],dimension=motionDimension(c);
    double sums[4]{};
    for(unsigned i=begin+threadIdx.x;i<end;i+=blockDim.x){const auto node=orderedNode(a,i);const auto d=a.inertia[node];
        const double w=1/(double(d.y)*d.y);const auto p=b.position[node];sums[0]+=w;sums[1]+=p.x*w;sums[2]+=p.y*w;sums[3]+=p.z*w;}
    reduceMotionValues(sums,centers);
    if(!threadIdx.x){if(!(sums[0]>0) || !isfinite(sums[0]))atomicOr(&status->error,4u);c.center={sums[1]/sums[0],sums[2]/sums[0],sums[3]/sums[0]};}
    __syncthreads();double gram[21]{};
    for(unsigned i=begin+threadIdx.x;i<end;i+=blockDim.x){const auto node=orderedNode(a,i);const auto d=a.inertia[node];
        const auto q=sub(b.position[node],c.center);const double w=1/(double(d.y)*d.y),angular=1/(double(d.x)*d.x);
        for(unsigned row=0;row<dimension;++row)for(unsigned col=0;col<=row;++col){double value;
            if(row<c.rotations){const auto u=motionAxis(c,row),v=motionAxis(c,col);
                // Evaluate the actual basis vectors, rather than subtracting
                // nearly equal squared lengths for long, slender components.
                value=angular*motionDot(u,v)+w*motionDot(cross(q,u),cross(q,v));}
            else if(col<c.rotations)value=w*motionEntry(cross(q,motionAxis(c,col)),row-c.rotations);
            else value=row==col?w:0;
            gram[triangle(row,col)]+=value;
        }
    }
    reduceMotionValues(gram,blocks);
    if(!threadIdx.x){
        for(unsigned i=0;i<dimension;++i){const double diagonal=gram[triangle(i,i)];
            if(!(diagonal>0) || !isfinite(diagonal)){atomicOr(&status->error,4u);return;}c.scale[i]=1/sqrt(diagonal);}
        for(unsigned row=0;row<dimension;++row)for(unsigned col=0;col<=row;++col){
            double value=gram[triangle(row,col)]*c.scale[row]*c.scale[col];
            for(unsigned k=0;k<col;++k)value-=c.factor[triangle(row,k)]*c.factor[triangle(col,k)];
            if(row==col){if(!(value>0) || !isfinite(value)){atomicOr(&status->error,4u);return;}value=sqrt(value);}
            else value/=c.factor[triangle(col,col)];c.factor[triangle(row,col)]=value;
        }
    }
}
// One cooperative construction launch. It runs only for a changed, accepted
// topology generation. Euler-tour pointer jumping takes logarithmic rounds;
// large tree depth never becomes one host submission per graph edge.
__global__ void constructMotionModes(Input a,const unsigned* forest,MotionBuffers b,Status* status,Work* work){
    const auto grid=cooperative_groups::this_grid();const unsigned thread=blockIdx.x*blockDim.x+threadIdx.x,stride=gridDim.x*blockDim.x;
    if(!thread)beginBuild(a,status,work);grid.sync();if(!work->active)return;
    initializeMotionForest(a,forest,b,status,thread,stride);grid.sync();
    if(!thread)work->pending=!status->error;grid.sync();if(!work->pending)return;
    for(unsigned node=thread/32;node<a.nodes;node+=stride/32)if(motionChanged(b,node))buildMotionTour(a,forest,b,status,node);grid.sync();
    // Every tree component must have exactly one broken Euler-tour link.
    for(unsigned arc=thread;arc<2*a.bonds;arc+=stride)if(forest[arc/2] && motionEdgeChanged(a,b,arc/2)){
        auto& c=b.components[a.component[a.node0[arc/2]]];
        if(b.previous[0][arc]==Invalid)atomicAdd(&c.cuts,1u);if(!(arc&1u))atomicAdd(&c.edges,1u);
    }
    grid.sync();if(!thread)work->pending=!status->error;grid.sync();if(!work->pending)return;
    unsigned source=0;
    for(std::uint64_t covered=1;covered<2ull*a.bonds;covered*=2){jumpMotionTour(a,forest,b,status,source,thread,stride);grid.sync();source^=1u;}
    publishMotionPositions(a,forest,b,status,source,thread,stride);grid.sync();
    discoverMotionClosures(a,b,status,thread,stride);grid.sync();
    initializeMotionAxes(a,b,status,thread,stride);grid.sync();
    constrainMotionAxes(a,b,status,thread,stride);grid.sync();
    if(!thread)work->pending=!status->error;grid.sync();if(!work->pending)return;
    for(unsigned slot=blockIdx.x;slot<*a.partition.count;slot+=gridDim.x){buildMotionFactor(a,b,status,a.partition.ids[slot]);__syncthreads();}
    grid.sync();if(!thread)commitBuild(&a,status);
}
__device__ void projectMotionComponent(Input a,MotionModeView modes,unsigned id,const unsigned* nodes,unsigned count,Vector* values){
    const auto& c=modes.components[id];const unsigned dimension=motionDimension(c);if(!dimension)return;
    __shared__ double partial[6][Threads/32],coefficients[6];double sum[6]{};
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes?nodes[i]:a.partition.begin[id]+i;
        const auto d=a.inertia[node];const auto q=sub(modes.position[node],c.center);const auto value=values[node];
        const auto linear=mul(value.linear,1.0/d.y),rotation=sub(mul(value.angular,1.0/d.x),cross(q,linear));
        for(unsigned k=0;k<c.rotations;++k)sum[k]+=motionDot(motionAxis(c,k),rotation);
        sum[c.rotations]+=linear.x;sum[c.rotations+1]+=linear.y;sum[c.rotations+2]+=linear.z;
    }
    reduceMotionValues(sum,partial);
    if(!threadIdx.x){
        for(unsigned row=0;row<dimension;++row){double value=sum[row]*c.scale[row];for(unsigned j=0;j<row;++j)value-=c.factor[triangle(row,j)]*coefficients[j];coefficients[row]=value/c.factor[triangle(row,row)];}
        for(int row=int(dimension)-1;row>=0;--row){for(unsigned j=row+1;j<dimension;++j)coefficients[row]-=c.factor[triangle(j,row)]*coefficients[j];coefficients[row]/=c.factor[triangle(row,row)];}
        for(unsigned k=0;k<dimension;++k)coefficients[k]*=c.scale[k];
    }
    __syncthreads();double3 omega{};for(unsigned k=0;k<c.rotations;++k)omega=add(omega,mul(motionAxis(c,k),coefficients[k]));
    const double3 translation={coefficients[c.rotations],coefficients[c.rotations+1],coefficients[c.rotations+2]};
    for(unsigned i=threadIdx.x;i<count;i+=blockDim.x){const unsigned node=nodes?nodes[i]:a.partition.begin[id]+i;
        const auto d=a.inertia[node];const auto q=sub(modes.position[node],c.center);auto& v=values[node];
        v.angular=sub(v.angular,mul(omega,1.0/d.x));v.linear=sub(v.linear,mul(add(translation,cross(q,omega)),1.0/d.y));}
    __syncthreads();
}
class ResidentMotionModes {
    Input mInput;const unsigned* mForest;cudaStream_t mStream;unsigned mBlocks=0;
    MotionBuffers mBuffers{};Status* mStatus=nullptr;Work* mWork=nullptr;
    static void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(std::string("Resident motion modes: ")+cudaGetErrorString(e));}
    template<class T>static void allocate(T*& p,size_t count){check(cudaMalloc(&p,std::max(size_t(1),count)*sizeof(T)));}
    void release()noexcept{for(unsigned k=0;k<2;++k){cudaFree(mBuffers.previous[k]);cudaFree(mBuffers.sum[k]);}cudaFree(mBuffers.first);cudaFree(mBuffers.position);cudaFree(mBuffers.components);cudaFree(mStatus);cudaFree(mWork);}
public:
    ResidentMotionModes(Input input,const unsigned* forest,cudaStream_t stream):mInput(input),mForest(forest),mStream(stream){
        if(input.levelBonds || input.nodes>0x7fffffffu || input.bonds>0x7fffffffu || !input.generation || !input.partition.count
            || (input.nodes && (!input.begin||!input.component||!input.inertia||!input.partition.begin||!input.partition.end||!input.partition.ids))
            || (input.bonds && (!forest||!input.node0||!input.node1||!input.refs||!input.health||!input.scale||!input.offset0||!input.offset1)))
            throw std::runtime_error("Invalid native motion-mode view");
        try{
            int device=0,sms=0,blocks=0,cooperative=0;check(cudaGetDevice(&device));check(cudaDeviceGetAttribute(&sms,cudaDevAttrMultiProcessorCount,device));
            check(cudaDeviceGetAttribute(&cooperative,cudaDevAttrCooperativeLaunch,device));check(cudaOccupancyMaxActiveBlocksPerMultiprocessor(&blocks,constructMotionModes,Threads,0));
            if(!cooperative || sms<=0 || blocks<=0)throw std::runtime_error("Resident motion modes require legal cooperative CUDA residency");
            mBlocks=std::min(std::max(1u,(input.nodes+7)/8),unsigned(sms*blocks));
            for(unsigned k=0;k<2;++k){allocate(mBuffers.previous[k],size_t(input.bonds)*2);allocate(mBuffers.sum[k],size_t(input.bonds)*2);}
            allocate(mBuffers.first,input.nodes);allocate(mBuffers.position,input.nodes);allocate(mBuffers.components,input.nodes);allocate(mStatus,1);allocate(mWork,1);
            check(cudaMemsetAsync(mStatus,0,sizeof(Status),stream));
        }catch(...){release();throw;}
    }
    ~ResidentMotionModes(){cudaStreamSynchronize(mStream);release();}
    ResidentMotionModes(const ResidentMotionModes&)=delete;ResidentMotionModes& operator=(const ResidentMotionModes&)=delete;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior){
        void* args[]={&mInput,&mForest,&mBuffers,&mStatus,&mWork};cudaKernelNodeParams p{};p.func=(void*)constructMotionModes;p.gridDim=dim3(mBlocks);p.blockDim=dim3(Threads);p.kernelParams=args;
        cudaGraphNode_t node;check(cudaGraphAddKernelNode(&node,graph,prior?&prior:nullptr,prior?1:0,&p));cudaKernelNodeAttrValue attr{};attr.cooperative=1;
        check(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeCooperative,&attr));return node;
    }
    MotionModeView view()const{return {mBuffers.position,mBuffers.components,mStatus,mForest};}
    // Must be set before append(): the captured kernel parameters carry the pointer.
    void setChangedMask(const unsigned* mask){mBuffers.changed=mask;}
    const Status* status()const{return mStatus;}
};
}}}
