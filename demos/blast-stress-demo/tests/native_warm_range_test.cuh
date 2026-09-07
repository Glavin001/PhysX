// Focused device lifecycle checks, included by gpu_resident_motion_modes_test.
// Exercise production reset/retirement kernels, with a supported three-bond
// cycle that cannot use the independent free-tree zero-load certificate.
namespace MotionModeTest {
__global__ void observeWarmRange(PersistentStressArgs a,unsigned* result){*result=nativeWarmRangeKnown(a);}
__global__ void retireWarmComponent(PersistentStressArgs a){retireHomogeneousTreeComponent(a,a.m_activeNodes,2,1);}
__global__ void retireWarmGrid(PersistentStressArgs a){retireHomogeneousTreesGrid(a);}
void warmRangeLifecycle(){
    Device<unsigned> known(1),observed(1);Device<std::uint64_t> generation(1);
    Device<ExtStressGpuDeviceTopologyStatus> topology(1);
    Device<Vector> solution(3);Device<AngLin> pi(3),q(3);
    PersistentStressArgs a{};a.hierarchy.warmRangeKnown=known.data;a.hierarchy.warmRangeGeneration=generation.data;
    a.hierarchy.topology=topology.data;a.hierarchy.solution=solution.data;
    ExtStressGpuDeviceTopologyStatus status{};
    auto reset=[&](bool warm,unsigned ready,unsigned error,std::uint64_t gen,unsigned expected){
        status.initialized=ready;status.error=error;status.generation=gen;topology.put({status});
        resetNativeStressSolution<<<1,32>>>(a.hierarchy,pi.data,q.data,3,warm);
        observeWarmRange<<<1,1>>>(a,observed.data);check(cudaGetLastError());check(cudaDeviceSynchronize());
        require(known.get()[0]==expected && observed.get()[0]==expected,"invalid native warm-range lifecycle proof");
    };
    reset(false,0,0,0,0); // Cold initialization is not proof before valid topology.
    reset(false,1,8,1,0); // Nor after a rejected topology transaction.
    reset(true,1,0,1,0); // Unknown imported warm state is never inferred valid.
    reset(false,1,0,1,1);reset(true,1,0,1,1); // Valid cold origin persists.
    reset(true,1,0,2,0);reset(true,1,0,1,0); // Change and rewind invalidate.
    reset(false,1,0,2,1);reset(true,0,0,2,0);
    reset(false,1,0,2,1);reset(true,1,8,2,0);

    Device<unsigned> begin(4),refs(6),node0(3),island(3),active(3),members(2),counts(2),ids(1),live(1),forest(3),failed(3);
    Device<float> health(3),delta(3);Device<ExtStressGpuImpulse> loads(3);Device<AngLin> impulses(3),residual(3);
    // Fixed node 0; edges 0->1, 1->2, 0->2. Back-references at 1 and 2
    // must clear fixed-first edges exactly once, even across grid blocks.
    begin.put({0,2,4,6});refs.put({0,2,0x80000000u,1,0x80000001u,0x80000002u});node0.put({0,1,0});
    island.put({kNoIsland,1,1});active.put({0,1,0});members.put({1,2});counts.put({3,2});ids.put({1});live.put({1});
    health.put({1,1,1});
    a.m_nodeBondBegin=begin.data;a.m_nodeBondRef=refs.data;a.m_node0=node0.data;a.m_nodeIsland=island.data;
    a.m_islandActive=active.data;a.m_activeNodes=members.data;a.m_activeCounts=counts.data;
    a.islandIds=ids.data;a.liveIslandCount=live.data;a.m_deltaSquared=delta.data;a.m_health=health.data;
    a.hierarchy.failed=failed.data;a.hierarchy.modes.forest=forest.data;a.input=loads.data;
    a.impulses=impulses.data;a.m_residual=residual.data;
    AngLin sentinel{};sentinel.angular={1,2,3,0};sentinel.linear={4,5,6,0};
    unsigned cases=0;
    for(bool cooperative:{false,true})for(unsigned scenario=0;scenario<9;++scenario){
        status.initialized=scenario!=3;status.error=scenario==4?8:0;status.generation=7;topology.put({status});
        known.put({scenario==1?0u:1u});generation.put({scenario==2?6u:7u});failed.put({0,0,0});
        std::vector<ExtStressGpuImpulse> input(3);
        if(scenario>=5){const float value=scenario==5?.5f:(scenario==6?1e-30f:(scenario==7?1e-40f:0));
            input[1].angular.x=value;input[2].angular.x=-value;}
        loads.put(input);impulses.put({sentinel,sentinel,sentinel});residual.put({sentinel,sentinel,sentinel});
        // Positive threshold must not select the exactly-homogeneous path.
        delta.put({0,scenario==8?1.f:0.f,0});
        if(cooperative){void* args[]={&a};check(cudaLaunchCooperativeKernel(reinterpret_cast<const void*>(retireWarmGrid),2,1,args));}
        else retireWarmComponent<<<1,32>>>(a);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto bonds=impulses.get(),nodes=residual.get();const bool cleared=scenario==0;
        const AngLin zero{};const auto& expected=cleared?zero:sentinel;
        for(const auto& force:bonds)require(!std::memcmp(&force,&expected,sizeof(force)),"homogeneous warm retirement changed an uncertified bond or missed a fixed-first bond");
        for(unsigned node:{1u,2u})require(!std::memcmp(&nodes[node],&expected,sizeof(expected)),"homogeneous warm retirement residual mismatch");
        require(!std::memcmp(&nodes[0],&sentinel,sizeof(sentinel)),"homogeneous retirement wrote inactive boundary state");++cases;
    }
    std::printf("GPU warm-range lifecycle: 3 nodes, 3 bonds, supported cycle; %u block/cooperative retirement cases passed\n",cases);
}
}
