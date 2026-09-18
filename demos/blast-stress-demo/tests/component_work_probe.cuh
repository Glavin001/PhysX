// Host observation only in the isolated diagnostic executable. Records are
// indexed by stable component IDs, never silently truncated to a top-N list.
struct WorkProbe {
    ComponentWorkRecord* device=nullptr;unsigned capacity;
    explicit WorkProbe(unsigned n):capacity(n){
        check(cudaMalloc(&device,sizeof(ComponentWorkRecord)*n));
        check(cudaMemcpyToSymbol(componentWorkRecords,&device,sizeof(device)));
        check(cudaMemcpyToSymbol(componentWorkCapacity,&capacity,sizeof(capacity)));
    }
    ~WorkProbe(){cudaFree(device);}
    void reset(){unsigned zero=0;check(cudaMemset(device,0,sizeof(ComponentWorkRecord)*capacity));
        check(cudaMemcpyToSymbol(componentWorkOverflow,&zero,sizeof(zero)));}
    void report(unsigned solve,unsigned expected){
        unsigned overflow=0;check(cudaMemcpyFromSymbol(&overflow,componentWorkOverflow,sizeof(overflow)));
        if(overflow)throw std::runtime_error("component work diagnostic overflow");
        std::vector<ComponentWorkRecord> records(capacity);check(cudaMemcpy(records.data(),device,records.size()*sizeof(records[0]),cudaMemcpyDeviceToHost));
        unsigned measured=0,unmeasured=0;unsigned long long nodeSweeps=0,csrVisits=0,liveVisits=0,updates=0;
        for(unsigned id=0;id<capacity;++id){const auto& r=records[id];if(!r.path)continue;
            if(r.path==2){++unmeasured;continue;}++measured;
            const auto sweeps=r.residualSweeps+r.verificationSweeps+r.directionSweeps;
            nodeSweeps+=r.dynamicNodes*sweeps;csrVisits+=r.csrReferences*sweeps;liveVisits+=r.liveReferences*sweeps;updates+=r.directionSweeps;
            std::printf("{\"record\":\"component_work\",\"solve\":%u,\"id\":%u,\"nodes\":%u,\"dynamic_nodes\":%u,\"csr_refs_per_sweep\":%llu,\"live_directed_refs_per_sweep\":%llu,\"residual_sweeps\":%llu,\"verification_sweeps\":%llu,\"direction_sweeps\":%llu,\"iterations\":%u,\"converged\":%u,\"cta\":%u,\"cta_cycles\":%llu}\n",solve,id,r.nodes,r.dynamicNodes,r.csrReferences,r.liveReferences,r.residualSweeps,r.verificationSweeps,r.directionSweeps,r.iterations,r.converged,r.block,r.cycles);
            // The fixture's dynamic nodes form one component per building.
            if(r.nodes!=380 || r.dynamicNodes!=380 || r.liveReferences!=1540 || r.csrReferences!=1540)
                throw std::runtime_error("building sparse work differs from independent graph count");
            if(r.directionSweeps!=r.iterations || r.residualSweeps<r.directionSweeps || !r.converged)
                throw std::runtime_error("component work iteration/convergence mismatch");
        }
        if(measured!=expected || unmeasured)throw std::runtime_error("missing/unmeasured fixture components");
        std::printf("{\"record\":\"component_work_total\",\"solve\":%u,\"components\":%u,\"operator_node_visits\":%llu,\"operator_csr_visits\":%llu,\"operator_live_directed_visits\":%llu,\"component_updates\":%llu}\n",solve,measured,nodeSweeps,csrVisits,liveVisits,updates);
    }
};
