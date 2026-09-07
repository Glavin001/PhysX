#pragma once
#ifdef BLAST_GPU_COMPONENT_WORK_CAPTURE
#ifndef BLAST_GPU_COMPONENT_PHASE_PROBE
#error Component capture requires diagnostic work probes
#endif
// Separate diagnostic runtime only: intentionally synchronizes and observes
// every component after a solve. Never link this implementation as production.
// The single-scene diagnostic process owns the probe's device symbols.
class ComponentWorkCapture {
    ComponentWorkRecord* device=nullptr;
    std::vector<ComponentWorkRecord> host;
    FILE* output=nullptr;
    unsigned solve=0,capacity;
    void *overflow=nullptr,*phases=nullptr,*precondition=nullptr;
    static inline bool bound=false;
    void cleanup(){if(device)cudaFree(device);device=nullptr;if(output)std::fclose(output);output=nullptr;}
public:
    explicit ComponentWorkCapture(unsigned count):host(count),capacity(count){
        if(bound)throw std::runtime_error("component diagnostic supports one live stress solver per process");
        const char* path=std::getenv("PHYSX_COMPONENT_WORK_OUTPUT");
        if(!path || !*path)throw std::runtime_error("diagnostic runtime requires PHYSX_COMPONENT_WORK_OUTPUT");
        output=std::fopen(path,"wx");
        if(!output)throw std::runtime_error("cannot create new component diagnostic output");
        try{
            checkCuda(cudaMalloc(&device,sizeof(ComponentWorkRecord)*count),"allocate diagnostic component records");
            checkCuda(cudaMemcpyToSymbol(componentWorkRecords,&device,sizeof(device)),"bind component records");
            checkCuda(cudaMemcpyToSymbol(componentWorkCapacity,&capacity,sizeof(capacity)),"bind component capacity");
            checkCuda(cudaGetSymbolAddress(&overflow,componentWorkOverflow),"locate diagnostic overflow");
            checkCuda(cudaGetSymbolAddress(&phases,componentPhaseClocks),"locate diagnostic phase clocks");
            checkCuda(cudaGetSymbolAddress(&precondition,componentPreconditionClocks),"locate diagnostic precondition clocks");
            bound=true;
        }catch(...){cleanup();throw;}
    }
    ~ComponentWorkCapture(){cleanup();bound=false;}
    void begin(cudaStream_t stream){
        checkCuda(cudaMemsetAsync(device,0,sizeof(ComponentWorkRecord)*capacity,stream),"clear component diagnostics");
        checkCuda(cudaMemsetAsync(overflow,0,sizeof(unsigned),stream),"clear diagnostic overflow");
        checkCuda(cudaMemsetAsync(phases,0,9*sizeof(unsigned long long),stream),"clear phase diagnostic");
        checkCuda(cudaMemsetAsync(precondition,0,4*sizeof(unsigned long long),stream),"clear precondition diagnostic");
    }
    void finish(cudaStream_t stream){
        // Observation is synchronous and intrusive by design. Its timings are
        // excluded from production performance claims by the capture runner.
        unsigned exceeded=0;unsigned long long clocks[9]{},subclocks[4]{};
        checkCuda(cudaMemcpyAsync(host.data(),device,sizeof(ComponentWorkRecord)*capacity,cudaMemcpyDeviceToHost,stream),"observe component records");
        checkCuda(cudaMemcpyAsync(&exceeded,overflow,sizeof(exceeded),cudaMemcpyDeviceToHost,stream),"observe diagnostic overflow");
        checkCuda(cudaMemcpyAsync(clocks,phases,sizeof(clocks),cudaMemcpyDeviceToHost,stream),"observe phase diagnostics");
        checkCuda(cudaMemcpyAsync(subclocks,precondition,sizeof(subclocks),cudaMemcpyDeviceToHost,stream),"observe precondition diagnostics");
        checkCuda(cudaStreamSynchronize(stream),"finish diagnostic observation");
        if(exceeded)throw std::runtime_error("component diagnostic overflow; capture incomplete");
        unsigned components=0,unmeasured=0;unsigned long long nodeVisits=0,csrVisits=0,liveVisits=0,updates=0;
        for(unsigned id=0;id<capacity;++id){const auto& r=host[id];if(!r.path)continue;
            if(r.path==2)++unmeasured;else ++components;
            const auto sweeps=r.residualSweeps+r.verificationSweeps+r.directionSweeps;
            nodeVisits+=r.dynamicNodes*sweeps;csrVisits+=r.csrReferences*sweeps;liveVisits+=r.liveReferences*sweeps;updates+=r.directionSweeps;
            std::fprintf(output,"{\"record\":\"component\",\"solve\":%u,\"id\":%u,\"path\":%u,\"nodes\":%u,\"dynamic_nodes\":%u,\"csr_refs_per_sweep\":%llu,\"live_refs_per_sweep\":%llu,\"residual_sweeps\":%llu,\"verification_sweeps\":%llu,\"direction_sweeps\":%llu,\"iterations\":%u,\"converged\":%u,\"cta\":%u,\"cta_cycles\":%llu}\n",solve,id,r.path,r.nodes,r.dynamicNodes,r.csrReferences,r.liveReferences,r.residualSweeps,r.verificationSweeps,r.directionSweeps,r.iterations,r.converged,r.block,r.cycles);
        }
        unsigned long long sum=0;for(unsigned i=0;i<8;++i)sum+=clocks[i];
        if(sum!=clocks[8])throw std::runtime_error("component phase clocks do not close");
        std::fprintf(output,"{\"record\":\"total\",\"solve\":%u,\"components\":%u,\"unmeasured_components\":%u,\"operator_node_visits\":%llu,\"operator_csr_visits\":%llu,\"operator_live_visits\":%llu,\"component_updates\":%llu,\"phase_cycles\":[",solve++,components,unmeasured,nodeVisits,csrVisits,liveVisits,updates);
        for(unsigned i=0;i<9;++i)std::fprintf(output,"%s%llu",i?",":"",clocks[i]);
        std::fprintf(output,"],\"precondition_cycles\":[");for(unsigned i=0;i<4;++i)std::fprintf(output,"%s%llu",i?",":"",subclocks[i]);
        std::fprintf(output,"]}\n");
        if(std::fflush(output) || std::ferror(output))throw std::runtime_error("component diagnostic output incomplete");
    }
};
#endif
