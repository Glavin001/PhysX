// Device-owned demand for recursive hierarchy work. Fine factors and level-zero
// retirement have already been validated. Block-solved components consume no
// packed levels or terminal factors, so an all-small partition needs no tail.
#pragma once
namespace Nv { namespace Blast { namespace StressHierarchy {
__global__ void chooseHierarchyTail(Input input,const Status* fine,TerminalBuffers pool,
    Status* output,cudaGraphConditionalHandle tail) {
    __shared__ unsigned needed,error,accepted;
    if(!threadIdx.x){needed=error=0;accepted=!input.accept || *input.accept;}
    __syncthreads();
    if(accepted) {
        if(!usable(fine) || !sourceCountsValid(input) || fine->generation!=*input.generation)
            atomicOr(&error,32u);
        else if(output->initialized && output->generation>fine->generation)atomicOr(&error,4u);
        else {
            const unsigned count=*input.partition.count;
            if(count>sourceComponentCapacity(input))atomicOr(&error,256u);
            else for(unsigned slot=threadIdx.x;slot<count;slot+=blockDim.x) {
                const unsigned id=input.partition.ids[slot];
                if(id>=sourceComponentCapacity(input)){atomicOr(&error,256u);continue;}
                if(componentUsesFineSolver(input,id)) {
                    if(pool.owner[id]!=0 || pool.kind[id]!=3)atomicOr(&error,256u);
                } else atomicOr(&needed,1u);
            }
        }
    }
    __syncthreads();
    if(!threadIdx.x) {
        cudaGraphSetConditional(tail,accepted && !error && needed);
        if(!accepted)return;
        if(error){output->error=error;return;}
        if(!needed && (!output->initialized || output->generation!=fine->generation || output->error)) {
            output->error=0;output->generation=fine->generation;output->initialized=1;++output->builds;
        }
    }
}
}}}
