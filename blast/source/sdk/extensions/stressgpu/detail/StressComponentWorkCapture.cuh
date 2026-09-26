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
#if defined(PX_CUMETAL) && PX_CUMETAL
    unsigned zeroOverflow=0;
    unsigned long long zeroClocks[9]{};
#else
    void *overflow=nullptr,*phases=nullptr,*precondition=nullptr;
#endif
    static inline bool bound=false;
#ifdef BLAST_GPU_NATIVE_PROBLEM_CAPTURE
    std::unique_ptr<NativeProblemCapture> problem;
#endif
    void cleanup(){if(device)cudaFree(device);device=nullptr;if(output)std::fclose(output);output=nullptr;}
public:
    explicit ComponentWorkCapture(unsigned count,unsigned bonds):host(count),capacity(count){
        if(bound)throw std::runtime_error("component diagnostic supports one live stress solver per process");
        const char* path=std::getenv("PHYSX_COMPONENT_WORK_OUTPUT");
        if(!path || !*path)throw std::runtime_error("diagnostic runtime requires PHYSX_COMPONENT_WORK_OUTPUT");
        output=std::fopen(path,"wx");
        if(!output)throw std::runtime_error("cannot create new component diagnostic output");
        try{
            checkCuda(cudaMalloc(&device,sizeof(ComponentWorkRecord)*count),"allocate diagnostic component records");
#if defined(PX_CUMETAL) && PX_CUMETAL
            // CuMetal's C symbol API takes the host registration address; its
            // reference overload deliberately excludes pointer-valued symbols.
            checkCuda(cudaMemcpyToSymbol(static_cast<const void*>(&componentWorkRecords),&device,sizeof(device),0,cudaMemcpyHostToDevice),"bind component records");
#else
            checkCuda(cudaMemcpyToSymbol(componentWorkRecords,&device,sizeof(device)),"bind component records");
#endif
            checkCuda(cudaMemcpyToSymbol(componentWorkCapacity,&capacity,sizeof(capacity)),"bind component capacity");
#if !defined(PX_CUMETAL) || !PX_CUMETAL
            checkCuda(cudaGetSymbolAddress(&overflow,componentWorkOverflow),"locate diagnostic overflow");
            checkCuda(cudaGetSymbolAddress(&phases,componentPhaseClocks),"locate diagnostic phase clocks");
            checkCuda(cudaGetSymbolAddress(&precondition,componentPreconditionClocks),"locate diagnostic precondition clocks");
#endif
#ifdef BLAST_GPU_NATIVE_PROBLEM_CAPTURE
            problem=std::make_unique<NativeProblemCapture>(count,bonds);
#else
            (void)bonds;
#endif
            bound=true;
        }catch(...){cleanup();throw;}
    }
    ~ComponentWorkCapture(){cleanup();bound=false;}
    void begin(cudaStream_t stream){
#ifdef BLAST_GPU_NATIVE_PROBLEM_CAPTURE
        problem->begin(solve,stream);
#endif
        checkCuda(cudaMemsetAsync(device,0,sizeof(ComponentWorkRecord)*capacity,stream),"clear component diagnostics");
#if defined(PX_CUMETAL) && PX_CUMETAL
        // CuMetal symbol handles are not ordinary cudaMalloc allocations.
        // Use symbol transfers for both clearing and observing their storage.
        checkCuda(cudaMemcpyToSymbolAsync(componentWorkOverflow,&zeroOverflow,sizeof(zeroOverflow),0,cudaMemcpyHostToDevice,stream),"clear diagnostic overflow");
        checkCuda(cudaMemcpyToSymbolAsync(componentPhaseClocks,zeroClocks,9*sizeof(unsigned long long),0,cudaMemcpyHostToDevice,stream),"clear phase diagnostic");
        checkCuda(cudaMemcpyToSymbolAsync(componentPreconditionClocks,zeroClocks,4*sizeof(unsigned long long),0,cudaMemcpyHostToDevice,stream),"clear precondition diagnostic");
#else
        checkCuda(cudaMemsetAsync(overflow,0,sizeof(unsigned),stream),"clear diagnostic overflow");
        checkCuda(cudaMemsetAsync(phases,0,9*sizeof(unsigned long long),stream),"clear phase diagnostic");
        checkCuda(cudaMemsetAsync(precondition,0,4*sizeof(unsigned long long),stream),"clear precondition diagnostic");
#endif
    }
    void finish(cudaStream_t stream) try {
#ifdef BLAST_GPU_NATIVE_PROBLEM_CAPTURE
        problem->finish(solve,stream);
#endif
        // Observation is synchronous and intrusive by design. Its timings are
        // excluded from production performance claims by the capture runner.
        unsigned exceeded=0;unsigned long long clocks[9]{},subclocks[4]{};
        checkCuda(cudaMemcpyAsync(host.data(),device,sizeof(ComponentWorkRecord)*capacity,cudaMemcpyDeviceToHost,stream),"observe component records");
#if defined(PX_CUMETAL) && PX_CUMETAL
        checkCuda(cudaMemcpyFromSymbolAsync(&exceeded,static_cast<const void*>(&componentWorkOverflow),sizeof(exceeded),0,cudaMemcpyDeviceToHost,stream),"observe diagnostic overflow");
        checkCuda(cudaMemcpyFromSymbolAsync(clocks,static_cast<const void*>(&componentPhaseClocks),sizeof(clocks),0,cudaMemcpyDeviceToHost,stream),"observe phase diagnostics");
        checkCuda(cudaMemcpyFromSymbolAsync(subclocks,static_cast<const void*>(&componentPreconditionClocks),sizeof(subclocks),0,cudaMemcpyDeviceToHost,stream),"observe precondition diagnostics");
#else
        checkCuda(cudaMemcpyAsync(&exceeded,overflow,sizeof(exceeded),cudaMemcpyDeviceToHost,stream),"observe diagnostic overflow");
        checkCuda(cudaMemcpyAsync(clocks,phases,sizeof(clocks),cudaMemcpyDeviceToHost,stream),"observe phase diagnostics");
        checkCuda(cudaMemcpyAsync(subclocks,precondition,sizeof(subclocks),cudaMemcpyDeviceToHost,stream),"observe precondition diagnostics");
#endif
        checkCuda(cudaStreamSynchronize(stream),"finish diagnostic observation");
        if(exceeded)throw std::runtime_error("component diagnostic overflow; capture incomplete (capacity="+std::to_string(capacity)+", flag="+std::to_string(exceeded)+")");
        unsigned components=0,unmeasured=0;unsigned long long nodeVisits=0,csrVisits=0,liveVisits=0,updates=0,polynomialVisits=0,inverseApplications=0;
        for(unsigned id=0;id<capacity;++id){const auto& r=host[id];if(!r.path)continue;
            if(r.path==2)++unmeasured;else ++components;
            const auto sweeps=r.residualSweeps+r.verificationSweeps+r.directionSweeps;
            nodeVisits+=r.dynamicNodes*sweeps;csrVisits+=r.csrReferences*sweeps;liveVisits+=r.liveReferences*sweeps;updates+=r.directionSweeps;
            polynomialVisits+=r.polynomialReferences*r.preconditionSweeps;inverseApplications+=2ull*r.nodes*r.preconditionSweeps;
            std::fprintf(output,"{\"record\":\"component\",\"cycle_timing_available\":%s,\"solve\":%u,\"id\":%u,\"path\":%u,\"nodes\":%u,\"dynamic_nodes\":%u,\"csr_refs_per_sweep\":%llu,\"live_refs_per_sweep\":%llu,\"residual_sweeps\":%llu,\"verification_sweeps\":%llu,\"direction_sweeps\":%llu,\"iterations\":%u,\"converged\":%u,\"cta\":%u,\"cta_cycles\":%llu,\"anchored\":%u,\"polynomial_refs_per_sweep\":%llu,\"precondition_sweeps\":%llu}\n",BLAST_COMPONENT_CYCLE_TIMING_AVAILABLE?"true":"false",solve,id,r.path,r.nodes,r.dynamicNodes,r.csrReferences,r.liveReferences,r.residualSweeps,r.verificationSweeps,r.directionSweeps,r.iterations,r.converged,r.block,r.cycles,r.anchored,r.polynomialReferences,r.preconditionSweeps);
        }
        unsigned long long sum=0;for(unsigned i=0;i<8;++i)sum+=clocks[i];
        if(sum!=clocks[8])throw std::runtime_error("component phase clocks do not close");
        std::fprintf(output,"{\"record\":\"total\",\"cycle_timing_available\":%s,\"solve\":%u,\"components\":%u,\"unmeasured_components\":%u,\"operator_node_visits\":%llu,\"operator_csr_visits\":%llu,\"operator_live_visits\":%llu,\"component_updates\":%llu,\"polynomial_live_visits\":%llu,\"fine_inverse_applications\":%llu,\"phase_cycles\":[",BLAST_COMPONENT_CYCLE_TIMING_AVAILABLE?"true":"false",solve++,components,unmeasured,nodeVisits,csrVisits,liveVisits,updates,polynomialVisits,inverseApplications);
        for(unsigned i=0;i<9;++i)std::fprintf(output,"%s%llu",i?",":"",clocks[i]);
        std::fprintf(output,"],\"precondition_cycles\":[");for(unsigned i=0;i<4;++i)std::fprintf(output,"%s%llu",i?",":"",subclocks[i]);
        std::fprintf(output,"]}\n");
        if(std::fflush(output) || std::ferror(output))throw std::runtime_error("component diagnostic output incomplete");
    } catch(const std::exception& error) {
        std::fprintf(stderr,"[component diagnostic] solve %u: %s\n",solve,error.what());
        throw;
    }
};
#endif
