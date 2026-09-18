// Batched small-component Cholesky preconditioning. Physical L is unchanged.
#pragma once
#include "StressHierarchyLevelOperator.cuh"
#include "StressHierarchyPacking.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
constexpr unsigned TerminalNodes=6,TerminalDofs=6*TerminalNodes;
constexpr unsigned TerminalTriangle=TerminalDofs*(TerminalDofs+1)/2;
constexpr unsigned TerminalFactorSlots=TerminalTriangle/TerminalNodes;
constexpr unsigned TerminalNodeSlots=TerminalFactorSlots+6;
struct TerminalBuffers {double* storage;double* lift;unsigned* kind;unsigned* owner;};
struct TerminalShared {
    double lower[TerminalTriangle],scaling[TerminalDofs],rhs[TerminalDofs],lift[6];
    unsigned nodes[TerminalNodes],coupled,anchored,failed;
};
__device__ __forceinline__ unsigned terminalNode(const Input& a,unsigned slot){return a.partition.nodes?a.partition.nodes[slot]:slot;}
__device__ __forceinline__ unsigned terminalOrigin(const Input& a,unsigned node){return a.identity?a.identity[node]:node;}
__device__ __forceinline__ double& terminalFactor(const Input& a,TerminalBuffers b,const unsigned* nodes,unsigned entry){
    return b.storage[size_t(terminalOrigin(a,nodes[entry/TerminalFactorSlots]))*TerminalNodeSlots+entry%TerminalFactorSlots];
}
__device__ __forceinline__ double& terminalScaling(const Input& a,TerminalBuffers b,unsigned node,unsigned dof){
    return b.storage[size_t(terminalOrigin(a,node))*TerminalNodeSlots+TerminalFactorSlots+dof];
}
__device__ __forceinline__ Vector basisVector(unsigned k){
    return {{double(k==0),double(k==1),double(k==2)},{double(k==3),double(k==4),double(k==5)}};
}
__device__ __forceinline__ double vectorCoordinate(Vector a,unsigned k){
    return k==0?a.angular.x:k==1?a.angular.y:k==2?a.angular.z:k==3?a.linear.x:k==4?a.linear.y:a.linear.z;
}
// Evaluate one matrix coefficient with the shared sparse coupling equations.
// Serial or strided immutable CSR order uses a fixed FP64 reduction tree;
// no floating-point atomics occur.
__device__ __forceinline__ double terminalCoefficient(const Input& a,unsigned node,unsigned row,unsigned columnNode,unsigned column,unsigned lane=0,unsigned width=1){
    const Vector x=scaledValue(basisVector(column),sourceInertia(a,columnNode));double value=0;
    const bool cached=cachedSelfRows(a);
    if(cached && !lane && node==columnNode && row<3 && column<3)value=a.selfMatrices[size_t(node)*SelfCacheEntries+row*3+column];
    const unsigned end=cached?a.nonSelfEnd[node]:a.begin[node+1];
    for(unsigned slot=a.begin[node]+lane;slot<end;slot+=width){
        const unsigned ref=cached?a.nonSelfRefs[slot]:a.refs[slot];if(ref==Invalid)continue;const unsigned e=ref&0x7fffffffu;
        if(sourceHealth(a,e)<=0)continue;
        Vector first{},second{};
        if(sourceFirst(a,e)==columnNode)first=couple(x,sourceOffset(a,e,false));
        if(sourceSecond(a,e)==columnNode)second=couple(x,sourceOffset(a,e,true));
        const bool back=ref>>31;const double scale=sourceScale(a,e);
        const auto flux=mul(sub(first,second),scale*scale*(back?-1.:1.));
        const auto response=scaledValue(transposeCouple(flux,sourceOffset(a,e,back)),sourceInertia(a,node));
        value+=vectorCoordinate(response,row);
    }
    return value;
}
__device__ __forceinline__ void constructTerminalComponent(const Input& a,TerminalBuffers b,Status* status,TerminalShared& s,unsigned component,unsigned level){
    const unsigned first=a.partition.begin[component],count=a.partition.end[component]-first;
    // Kind 3 is owned by the independent native fine solver, not an exact
    // zero terminal. Packing retires its unused coarse work; accidentally
    // dispatching it through the multilevel solve is an explicit error.
    if(componentUsesFineSolver(a,component)){if(!threadIdx.x){b.kind[component]=3;b.owner[component]=level;}return;}
    if(count>TerminalNodes){if(!threadIdx.x){b.kind[component]=0;b.owner[component]=Invalid;}return;}
    const unsigned size=6*count,entries=size*(size+1)/2;
    if(threadIdx.x<count)s.nodes[threadIdx.x]=terminalNode(a,first+threadIdx.x);
    if(!threadIdx.x)s.anchored=s.failed=s.coupled=0;__syncthreads();
    // Coarse rows retain many parallel bond columns. One warp cooperates on
    // each coefficient; use the immutable strided CSR order and a fixed FP64
    // reduction tree. Fine terminal rows retain their established schedule.
    if(a.levelBonds){
        const unsigned lane=threadIdx.x&31u;
        for(unsigned entry=threadIdx.x/32;entry<entries;entry+=blockDim.x/32){
            unsigned row=0;while(triangle(row+1,0)<=entry)++row;const unsigned col=entry-triangle(row,0);
            const double value=warpSum(terminalCoefficient(a,s.nodes[row/6],row%6,s.nodes[col/6],col%6,lane,32));
            if(!lane)s.lower[entry]=value;
        }
    }else {
    for(unsigned entry=threadIdx.x;entry<entries;entry+=blockDim.x){
        unsigned row=0;while(triangle(row+1,0)<=entry)++row;const unsigned col=entry-triangle(row,0);
        s.lower[entry]=terminalCoefficient(a,s.nodes[row/6],row%6,s.nodes[col/6],col%6);
    }
    }
    // Support is a Boolean property. Cooperate across the row rather than
    // serializing thousands of references through one thread. Cached self
    // columns cannot connect this node to a fixed boundary.
    for(unsigned i=threadIdx.x/32;i<count;i+=blockDim.x/32){const unsigned node=s.nodes[i];
        const bool cached=cachedSelfRows(a);const unsigned end=cached?a.nonSelfEnd[node]:a.begin[node+1];
        for(unsigned slot=a.begin[node]+(threadIdx.x&31u);slot<end;slot+=32){
            const unsigned ref=cached?a.nonSelfRefs[slot]:a.refs[slot];if(ref==Invalid)continue;const unsigned e=ref&0x7fffffffu;
            if(sourceHealth(a,e)<=0)continue;
            const unsigned other=(ref>>31)?sourceFirst(a,e):sourceSecond(a,e);
            if(other==Invalid || a.component[other]==Invalid)atomicExch(&s.anchored,1u);
        }
    }
    __syncthreads();
    if(!threadIdx.x){
        double maximum=0;
        for(unsigned i=0;i<size;++i){const double d=s.lower[triangle(i,i)];if(!isfinite(d) || d<0)s.failed=1;maximum=fmax(maximum,d);}
        s.coupled=maximum>0;
        // A full six-coordinate lift at one node removes every free null
        // direction of a connected full-coupling graph. It is NOT a physical
        // support, nor a projection that assumes six exact authored modes.
        for(unsigned k=0;k<6;++k){
            const double d=s.lower[triangle(k,k)];s.lift[k]=!s.anchored && s.coupled?(d>0?d:maximum):0;
            s.lower[triangle(k,k)]+=s.lift[k];b.lift[size_t(component)*6+k]=s.lift[k];
        }
        for(unsigned i=0;i<size;++i){const double d=s.lower[triangle(i,i)];
            if(s.coupled && (!(d>0) || !isfinite(d)))s.failed=1;
            s.scaling[i]=s.coupled && d>0?1./sqrt(d):0;
        }
    }
    __syncthreads();
    if(!s.failed && s.coupled){
        for(unsigned entry=threadIdx.x;entry<entries;entry+=blockDim.x){
            unsigned row=0;while(triangle(row+1,0)<=entry)++row;const unsigned col=entry-triangle(row,0);
            s.lower[entry]*=s.scaling[row]*s.scaling[col];
        }
        __syncthreads();
        for(unsigned k=0;k<size;++k){
            if(!threadIdx.x){const double d=s.lower[triangle(k,k)];if(!(d>0) || !isfinite(d))s.failed=1;else s.lower[triangle(k,k)]=sqrt(d);}
            __syncthreads();if(s.failed)break;
            for(unsigned row=k+1+threadIdx.x;row<size;row+=blockDim.x)s.lower[triangle(row,k)]/=s.lower[triangle(k,k)];
            __syncthreads();
            for(unsigned entry=threadIdx.x;entry<entries;entry+=blockDim.x){
                unsigned row=0;while(triangle(row+1,0)<=entry)++row;const unsigned col=entry-triangle(row,0);
                if(col>k)s.lower[entry]-=s.lower[triangle(row,k)]*s.lower[triangle(col,k)];
            }
            __syncthreads();
        }
    }
    if(s.failed){if(!threadIdx.x)atomicOr(&status->error,128u);return;}
    for(unsigned entry=threadIdx.x;entry<entries;entry+=blockDim.x)terminalFactor(a,b,s.nodes,entry)=s.coupled?s.lower[entry]:0;
    for(unsigned i=threadIdx.x;i<size;i+=blockDim.x)terminalScaling(a,b,s.nodes[i/6],i%6)=s.scaling[i];
    if(!threadIdx.x){b.kind[component]=s.coupled?2:1;b.owner[component]=level;}
}
__global__ void constructTerminals(Input input,const Status* source,Status* status,Work* work,TerminalBuffers b,unsigned level){
    __shared__ TerminalShared shared;const auto grid=cooperative_groups::this_grid();
    const unsigned lane=blockIdx.x*blockDim.x+threadIdx.x;
    if(!lane){
        work->active=0;
        if(!input.accept || *input.accept){
            if(!usable(source) || !sourceCountsValid(input) || source->generation!=*input.generation){status->error=32;
                printf("[hierarchy-terminal] rejected: usable=%d countsValid=%d srcInit=%u srcErr=%u srcGen=%llu gen=%llu\n",int(usable(source)),int(sourceCountsValid(input)),source->initialized,source->error,(unsigned long long)source->generation,(unsigned long long)*input.generation);}
            else if(status->initialized && source->generation<status->generation)status->error=4;
            else if(*input.partition.nodeCount>resolvedInput(input).nodes || *input.partition.count>resolvedInput(input).nodes)status->error=64;
            else if(!status->initialized || status->generation!=source->generation || status->error){status->error=0;work->active=1;}
        }
    }
    grid.sync();if(!work->active)return;input=resolvedInput(input);
    validatePackingPartition(input,status);
    grid.sync();if(!lane)work->active=!status->error;grid.sync();if(!work->active)return;
    for(unsigned i=blockIdx.x;i<*input.partition.count;i+=gridDim.x){
        constructTerminalComponent(input,b,status,shared,input.partition.ids[i],level);__syncthreads();
    }
    grid.sync();if(!lane && !status->error){status->generation=source->generation;status->initialized=1;++status->builds;}
}
__device__ __forceinline__ void solveTerminalComponent(const Input& a,TerminalBuffers b,TerminalShared& s,unsigned component,unsigned level,const Vector* rhs,Vector* result){
    if(b.owner[component]!=level)return;
    const unsigned kind=b.kind[component];if(!kind)return;
    if(kind==3){__trap();return;}
    const unsigned first=a.partition.begin[component],count=a.partition.end[component]-first,size=6*count;
    if(threadIdx.x<count)s.nodes[threadIdx.x]=terminalNode(a,first+threadIdx.x);__syncthreads();
    if(threadIdx.x<size){const unsigned i=threadIdx.x,node=s.nodes[i/6];
        s.rhs[i]=kind==2?vectorCoordinate(rhs[node],i%6)*terminalScaling(a,b,node,i%6):0;}
    __syncthreads();
    if(kind==2){
        for(unsigned k=0;k<size;++k){
            if(threadIdx.x==k)s.rhs[k]/=terminalFactor(a,b,s.nodes,triangle(k,k));__syncthreads();
            if(threadIdx.x<size && threadIdx.x>k)s.rhs[threadIdx.x]-=terminalFactor(a,b,s.nodes,triangle(threadIdx.x,k))*s.rhs[k];__syncthreads();
        }
        for(int k=int(size)-1;k>=0;--k){
            if(threadIdx.x==unsigned(k))s.rhs[k]/=terminalFactor(a,b,s.nodes,triangle(k,k));__syncthreads();
            if(threadIdx.x<unsigned(k))s.rhs[threadIdx.x]-=terminalFactor(a,b,s.nodes,triangle(k,threadIdx.x))*s.rhs[k];__syncthreads();
        }
    }
    if(threadIdx.x<count){const unsigned node=s.nodes[threadIdx.x],base=6*threadIdx.x;
        double x[6];for(unsigned k=0;k<6;++k)x[k]=s.rhs[base+k]*terminalScaling(a,b,node,k);
        result[node]={{x[0],x[1],x[2]},{x[3],x[4],x[5]}};
    }
}
__global__ void applyTerminals(Input input,const Status* status,TerminalBuffers b,unsigned level,const Vector* rhs,Vector* result){
    __shared__ TerminalShared shared;
    if(!usable(status) || status->generation!=*input.generation)return;input=resolvedInput(input);
    for(unsigned i=blockIdx.x;i<*input.partition.count;i+=gridDim.x){
        solveTerminalComponent(input,b,shared,input.partition.ids[i],level,rhs,result);__syncthreads();
    }
}
}}}
