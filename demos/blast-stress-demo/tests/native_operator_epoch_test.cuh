// Cache identity must follow operator geometry, independently of fracture IDs.
// This directly exercises both production readiness and error publication.
namespace MotionModeTest {
__global__ void observeOperatorReady(NativeStressCycleView view,unsigned* result){
    *result=nativeHierarchyReady(view);
}
void operatorEpochReadiness(){
    Device<ExtStressGpuDeviceTopologyStatus> topology(1);
    Device<Status> hierarchy(1),modes(1);Device<unsigned> ready(1);
    NativeStressCycleView view{};view.topology=topology.data;
    view.cycle.status=hierarchy.data;view.modes.status=modes.data;
    for(unsigned scenario=0;scenario<6;++scenario){
        ExtStressGpuDeviceTopologyStatus state{};
        state.initialized=1;state.generation=77;state.solvedGeneration=76;state.rebuilds=4;
        Status h{},m{};h.initialized=m.initialized=1;h.generation=m.generation=4;
        if(scenario==1 || scenario==3)h.generation=77;
        if(scenario==2 || scenario==3)m.generation=77;
        if(scenario==4)h.initialized=0;
        if(scenario==5)m.error=2;
        topology.put({state});hierarchy.put({h});modes.put({m});
        observeOperatorReady<<<1,1>>>(view,ready.data);
        publishNativeHierarchyStatus<<<1,1>>>(hierarchy.data,modes.data,topology.data);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto result=topology.get()[0];
        require(ready.get()[0]==unsigned(scenario==0),"operator readiness used connectivity instead of cache revision");
        require((result.error==0)==(scenario==0),"operator publication accepted mismatched cache revision");
        if(scenario==1 || scenario==3)require(result.error&(1u<<26),"hierarchy revision mismatch not identified");
        if(scenario==2 || scenario==3)require(result.error&(1u<<27),"motion revision mismatch not identified");
        require(result.generation==77 && result.solvedGeneration==76 && result.rebuilds==4,
            "cache validation changed physical topology or solved generation");
    }
    std::printf("GPU operator epochs: six readiness/publication cases preserve independent connectivity and cache revisions\n");
}
}
