// Exact storage checks complement the public solver's physical transition tests.
namespace MotionModeTest {
void topologyWarmInvalidation(){
    constexpr unsigned nodes=9,bonds=7;
    Device<unsigned> labels(bonds),mask(bonds),changed(nodes);
    Device<float> health(bonds);Device<AngLin> impulses(bonds);
    Device<DeviceStressTopologyBatch> batch(1);Device<ExtStressGpuDeviceTopologyStatus> state(1);
    // Two supported components (IDs 1 and 5); a removed and a boundary-only
    // edge have no component. IDs describe dynamic connectivity, not supports.
    const std::vector<unsigned> ids{1,1,1,5,5,kNoIsland,kNoIsland};
    labels.put(ids);health.put({1,1,1,1,1,0,1});
    AngLin value{};value.angular={1,2,3,0};value.linear={4,5,6,0};
    for(unsigned scenario=0;scenario<5;++scenario){
        ExtStressGpuDeviceTopologyStatus status{};status.initialized=scenario!=0;state.put({status});
        std::vector<unsigned> alive{1,1,1,1,1,0,1};
        if(scenario==2)alive[1]=0; // Inner cut: root 1 may survive unchanged.
        if(scenario==3)alive[0]=0; // Support edge: still invalidate all of ID 1.
        if(scenario==4)alive[3]=0; // The other component changes instead.
        mask.put(alive);batch.put({{mask.data,nullptr,nullptr}});
        changed.put(std::vector<unsigned>(nodes,0));impulses.put(std::vector<AngLin>(bonds,value));
        markChangedStressComponents<<<1,32>>>(batch.data,state.data,health.data,labels.data,changed.data,bonds);
        clearChangedStressWarmStart<<<1,32>>>(state.data,labels.data,changed.data,impulses.data,bonds);
        check(cudaGetLastError());check(cudaDeviceSynchronize());const auto actual=impulses.get();
        for(unsigned e=0;e<bonds;++e){
            const bool clear=!scenario || ids[e]==kNoIsland || ((scenario==2 || scenario==3)&&ids[e]==1) || (scenario==4&&ids[e]==5);
            const AngLin expected=clear?AngLin{}:value;
            require(!std::memcmp(&actual[e],&expected,sizeof(expected)),"topology warm invalidation lost an unaffected solution or retained affected stress");
        }
    }
    std::printf("GPU topology warm invalidation: 9 nodes, 7 bonds, two supported components; five cases passed\n");
}
}
