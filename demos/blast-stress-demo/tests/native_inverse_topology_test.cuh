// Exact cache ownership test: an internal cut invalidates its two endpoint
// operators, not every node in that old stress component. Shared support does
// not spread local invalidation to the other structure.
namespace MotionModeTest {
void inverseTopologyLifetime(){
    Fixture f(6);f.edge(0,1);f.edge(1,2);f.edge(2,3);f.edge(0,4);f.edge(4,5);f.csr();
    Device<unsigned> begin(f.begin.size()),refs(f.refs.size()),mask(f.a.size()),valid(f.n);
    Device<float> health(f.health.size());Device<std::uint64_t> cached(f.n),next(1);
    Device<DeviceStressTopologyBatch> batch(1);Device<ExtStressGpuDeviceTopologyStatus> state(1);
    begin.put(f.begin);refs.put(f.refs);next.put({8});batch.put({{mask.data,next.data,nullptr}});
    for(unsigned scenario=0;scenario<6;++scenario){
        ExtStressGpuDeviceTopologyStatus status{};status.initialized=scenario!=0;status.generation=7;state.put({status});
        auto alive=f.health;std::vector<unsigned> desired(f.a.size(),1),flags(f.n,1);std::vector<std::uint64_t> generations(f.n,7);
        if(scenario==1){flags[1]=0;generations[4]=6;} // Unknown and stale cannot gain validity.
        if(scenario==2)desired[2]=0; // Only 2 and 3, despite 1 sharing their old component.
        if(scenario==3)desired[0]=0; // Only 0 and 1, not the other supported structure.
        if(scenario==4){alive[2]=0;desired[2]=0;} // An already removed edge is not a new change.
        if(scenario==5){generations[2]=8;flags[3]=0;} // Future/stale and unknown remain invalid.
        health.put(alive);mask.put(desired);valid.put(flags);cached.put(generations);
        refreshNativeInverseValidity<<<1,32>>>(batch.data,state.data,begin.data,refs.data,health.data,valid.data,cached.data,f.n);
        check(cudaGetLastError());check(cudaDeviceSynchronize());const auto got=valid.get();const auto epochs=cached.get();
        for(unsigned node=0;node<f.n;++node){bool expected=scenario && flags[node] && generations[node]==7;
            for(unsigned e=0;e<f.a.size();++e)if((f.a[e]==node || f.b[e]==node) && alive[e]>0 && !desired[e])expected=false;
            require(got[node]==unsigned(expected),"local inverse invalidation exceeded or missed incident changes");
            require(epochs[node]==(expected?8:generations[node]),"invalid inverse acquired a new generation certificate");}
    }
    std::printf("GPU inverse topology lifetime: 6 nodes, 5 bonds, shared support; six cold/unknown/stale/cut/repeated-cut cases passed\n");
}
}
