// Private packing stages. Reuse the producer's component order; never sort it.
__device__ __forceinline__ unsigned orderedNode(const Input& input,unsigned index){
    return input.partition.nodes?input.partition.nodes[index]:index;
}
__device__ __forceinline__ void validatePackingPartition(const Input& input,Status* status){
    const auto p=input.partition;const unsigned nodes=*p.nodeCount,components=*p.count;
    const unsigned lane=blockIdx.x*Threads+threadIdx.x,stride=gridDim.x*Threads,capacity=sourceComponentCapacity(input);
    if(!lane && ((!components && nodes) || (components && !nodes)))atomicOr(&status->error,64u);
    for(unsigned i=lane;i<nodes;i+=stride){
        const unsigned node=orderedNode(input,i);if(node>=input.nodes){atomicOr(&status->error,64u);continue;}
        const unsigned part=input.component[node];
        if(part==Invalid || part>=capacity){atomicOr(&status->error,64u);continue;}
        if(p.begin[part]>i || p.end[part]<=i)atomicOr(&status->error,64u);
        if(i){const unsigned previous=orderedNode(input,i-1);
            if(previous>=input.nodes || input.component[previous]>part || (input.component[previous]==part && previous>=node))atomicOr(&status->error,64u);}
    }
    for(unsigned i=lane;i<components;i+=stride){
        const unsigned id=p.ids[i];if(id>=capacity){atomicOr(&status->error,64u);continue;}
        const unsigned begin=p.begin[id],end=p.end[id];
        if(begin>=end || end>nodes){atomicOr(&status->error,64u);continue;}
        const unsigned first=orderedNode(input,begin),last=orderedNode(input,end-1);
        if(first>=input.nodes || last>=input.nodes || input.component[first]!=id || input.component[last]!=id)atomicOr(&status->error,64u);
        if(!i){if(begin)atomicOr(&status->error,64u);}
        else {const unsigned previous=p.ids[i-1];if(previous>=id || previous>=capacity || p.end[previous]!=begin)atomicOr(&status->error,64u);}
        if(i+1==components && end!=nodes)atomicOr(&status->error,64u);
    }
}
__device__ __forceinline__ void scanPackedComponents(const Input& input,PackingBuffers b,PackingShared& shared,unsigned block){
    const unsigned i=block*Threads+threadIdx.x;unsigned flag=0;
    if(i<*input.partition.count){
        const unsigned id=input.partition.ids[i];
        const unsigned first=b.orderedPrefix[input.partition.begin[id]],last=b.orderedPrefix[input.partition.end[id]];
        b.componentBegin[id]=first;b.componentEnd[id]=last;flag=last!=first;
    }
    unsigned prefix,total;PackingScan(shared.temp.scan).ExclusiveSum(flag,prefix,total);
    // Bond compaction has not started; its scratch is available for this scan.
    if(i<*input.partition.count)b.bondMap[i]=prefix;
    if(!threadIdx.x)b.partial[block]=total;__syncthreads();
}
