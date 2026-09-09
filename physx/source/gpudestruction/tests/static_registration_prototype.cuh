// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Isolated prototype: not linked into production until ordering is qualified.
struct StaticCommand { unsigned edge,node,kind,add; };
struct StaticEntry { unsigned node,kind; unsigned long long sequence; };
struct StaticStats { unsigned contacts,joints,maxContacts,maxJoints,error; };
__global__ void commandKeys(const StaticCommand* cmd,unsigned n,unsigned* keys,unsigned* ids) {
    unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i<n){keys[i]=cmd[i].edge;ids[i]=i;}
}
__global__ void applyCommands(const StaticCommand* cmd,const unsigned* keys,const unsigned* ids,
    unsigned n,StaticEntry* entries,unsigned capacity,unsigned nodes,unsigned long long sequence,StaticStats* status) {
    unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=n || (i && keys[i-1]==keys[i]))return;
    unsigned edge=keys[i];if(edge>=capacity){atomicOr(&status->error,1u);return;}
    auto value=entries[edge];
    // Only same-registration updates serialize. Stable grouping preserves the
    // producer order; independent registrations execute concurrently.
    for(unsigned j=i;j<n && keys[j]==edge;++j){
        unsigned ordinal=ids[j];auto c=cmd[ordinal];
        if(c.node>=nodes || c.kind>1 || c.add>1){atomicOr(&status->error,2u);return;}
        if(c.add){
            if(value.node!=~0u){atomicOr(&status->error,4u);return;}
            value={c.node,c.kind,sequence+ordinal};
        }else{
            if(value.node!=c.node || value.kind!=c.kind){atomicOr(&status->error,8u);return;}
            value.node=~0u;
        }
    }
    entries[edge]=value;
}
__global__ void sequenceKeys(const StaticEntry* entries,unsigned n,unsigned long long* keys,unsigned* ids){
    unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<n){keys[i]=entries[i].node==~0u?~0ull:entries[i].sequence;ids[i]=i;}
}
__global__ void ownerKeys(const StaticEntry* entries,const unsigned* ids,unsigned n,unsigned long long* keys){
    unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<n){auto e=entries[ids[i]];keys[i]=e.node==~0u?~0ull:static_cast<unsigned long long>(e.node)*2+e.kind;}
}
__global__ void ownerRanges(const unsigned long long* keys,unsigned n,uint2* ranges){
    unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n || keys[i]==~0ull)return;
    auto key=keys[i];if(!i || keys[i-1]!=key)ranges[key].x=i;
    if(i+1==n || keys[i+1]!=key)ranges[key].y=i+1;
}
__global__ void rangeStats(const uint2* ranges,unsigned nodes,StaticStats* stats){
    unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=nodes)return;
    auto c=ranges[size_t(i)*2],j=ranges[size_t(i)*2+1];unsigned nc=c.y-c.x,nj=j.y-j.x;
    if(nc){atomicAdd(&stats->contacts,nc);atomicMax(&stats->maxContacts,nc);}
    if(nj){atomicAdd(&stats->joints,nj);atomicMax(&stats->maxJoints,nj);}
}
__global__ void gatherRegistrations(const unsigned* ordered,const uint2* ranges,unsigned nodes,
    const unsigned* active,unsigned offset,unsigned count,unsigned* contacts,unsigned contactCapacity,
    unsigned* joints,unsigned jointCapacity,unsigned* contactCounts,unsigned* jointCounts,StaticStats* stats){
    unsigned i=blockIdx.x;if(i>=count)return;
    unsigned node=active[size_t(offset)+i];
    if(node>=nodes){if(!threadIdx.x)atomicOr(&stats->error,16u);return;}
    auto c=ranges[size_t(node)*2],j=ranges[size_t(node)*2+1];unsigned nc=c.y-c.x,nj=j.y-j.x;
    if(size_t(nc)*count>contactCapacity || size_t(nj)*count>jointCapacity){if(!threadIdx.x)atomicOr(&stats->error,32u);return;}
    if(!threadIdx.x){contactCounts[i]=nc;jointCounts[i]=nj;}
    for(unsigned k=threadIdx.x;k<nc;k+=blockDim.x)contacts[size_t(k)*count+i]=ordered[c.x+k];
    for(unsigned k=threadIdx.x;k<nj;k+=blockDim.x)joints[size_t(k)*count+i]=ordered[j.x+k];
}
class StaticRegistry {
    StaticEntry* entries{};unsigned capacity=0,nodes=0,commandCapacity=0;
    StaticCommand* commands{};unsigned *commandKey[2]{},*commandId[2]{},*ids[2]{};
    unsigned long long* keys[2]{};uint2* ranges{};void* scratch{};size_t scratchBytes=0;
    unsigned long long sequence=0;bool failed=false;StaticStats cached{};
    void reserveScratch(size_t bytes){if(bytes>scratchBytes){check(cudaFree(scratch));check(cudaMalloc(&scratch,bytes));scratchBytes=bytes;}}
public:
    StaticStats* status{};
    StaticRegistry(){allocate(status,1);check(cudaMemset(status,0,sizeof(*status)));}
    ~StaticRegistry(){
        cudaDeviceSynchronize();cudaFree(entries);cudaFree(commands);cudaFree(ranges);cudaFree(scratch);cudaFree(status);
        for(auto p:commandKey)cudaFree(p);for(auto p:commandId)cudaFree(p);for(auto p:ids)cudaFree(p);for(auto p:keys)cudaFree(p);
    }
    StaticRegistry(const StaticRegistry&)=delete;StaticRegistry& operator=(const StaticRegistry&)=delete;
    StaticStats update(const StaticCommand* host,unsigned count,unsigned requestedCapacity,unsigned requestedNodes,cudaStream_t stream){
        if(failed)throw std::runtime_error("latched static registration failure");
        if((count && !host) || count>0x7fffffffu || requestedCapacity>0x7fffffffu || requestedNodes>0x7fffffffu || count>~0ull-sequence)
            throw std::runtime_error("invalid static registration dimensions");
        bool changed=count || requestedCapacity>capacity || requestedNodes>nodes;
        if(!changed)return cached;
        unsigned wanted=std::max(1u,requestedCapacity),wantedNodes=std::max(1u,requestedNodes);
        if(wanted>capacity){
            StaticEntry* next{};allocate(next,wanted);check(cudaMemsetAsync(next,255,size_t(wanted)*sizeof(*next),stream));
            if(capacity)check(cudaMemcpyAsync(next,entries,size_t(capacity)*sizeof(*next),cudaMemcpyDeviceToDevice,stream));
            check(cudaStreamSynchronize(stream));check(cudaFree(entries));entries=next;
            for(auto& p:keys){check(cudaFree(p));allocate(p,wanted);}for(auto& p:ids){check(cudaFree(p));allocate(p,wanted);}capacity=wanted;
        }
        if(wantedNodes>nodes){check(cudaFree(ranges));allocate(ranges,size_t(wantedNodes)*2);nodes=wantedNodes;}
        if(count>commandCapacity){
            check(cudaFree(commands));allocate(commands,count);
            for(auto& p:commandKey){check(cudaFree(p));allocate(p,count);}for(auto& p:commandId){check(cudaFree(p));allocate(p,count);}commandCapacity=count;
        }
        check(cudaMemsetAsync(status,0,sizeof(*status),stream));
        if(count){
            check(cudaMemcpyAsync(commands,host,size_t(count)*sizeof(*host),cudaMemcpyHostToDevice,stream));
            commandKeys<<<(count+255)/256,256,0,stream>>>(commands,count,commandKey[0],commandId[0]);
            size_t bytes=0;check(cub::DeviceRadixSort::SortPairs(nullptr,bytes,commandKey[0],commandKey[1],commandId[0],commandId[1],count,0,32,stream));reserveScratch(bytes);
            check(cub::DeviceRadixSort::SortPairs(scratch,scratchBytes,commandKey[0],commandKey[1],commandId[0],commandId[1],count,0,32,stream));
            applyCommands<<<(count+255)/256,256,0,stream>>>(commands,commandKey[1],commandId[1],count,entries,capacity,nodes,sequence,status);sequence+=count;
        }
        sequenceKeys<<<(capacity+255)/256,256,0,stream>>>(entries,capacity,keys[0],ids[0]);
        size_t bytes=0;check(cub::DeviceRadixSort::SortPairs(nullptr,bytes,keys[0],keys[1],ids[0],ids[1],capacity,0,64,stream));reserveScratch(bytes);
        check(cub::DeviceRadixSort::SortPairs(scratch,scratchBytes,keys[0],keys[1],ids[0],ids[1],capacity,0,64,stream));
        ownerKeys<<<(capacity+255)/256,256,0,stream>>>(entries,ids[1],capacity,keys[0]);
        check(cub::DeviceRadixSort::SortPairs(scratch,scratchBytes,keys[0],keys[1],ids[1],ids[0],capacity,0,64,stream));
        check(cudaMemsetAsync(ranges,0,size_t(nodes)*2*sizeof(*ranges),stream));
        ownerRanges<<<(capacity+255)/256,256,0,stream>>>(keys[1],capacity,ranges);
        rangeStats<<<(nodes+255)/256,256,0,stream>>>(ranges,nodes,status);check(cudaGetLastError());
        check(cudaMemcpyAsync(&cached,status,sizeof(cached),cudaMemcpyDeviceToHost,stream));check(cudaStreamSynchronize(stream));
        if(cached.error){failed=true;throw std::runtime_error("invalid static registration transaction");}
        return cached;
    }
    void gather(const unsigned* active,unsigned offset,unsigned count,unsigned* contacts,unsigned contactCapacity,
        unsigned* joints,unsigned jointCapacity,unsigned* contactCounts,unsigned* jointCounts,cudaStream_t stream){
        if(failed)throw std::runtime_error("latched static registration failure");
        if(count)gatherRegistrations<<<count,128,0,stream>>>(ids[0],ranges,nodes,active,offset,count,contacts,contactCapacity,joints,jointCapacity,contactCounts,jointCounts,status);
        check(cudaGetLastError());
    }
};
