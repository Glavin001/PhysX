// Exercise the actual grid-uniform retirement boundary with sparse island IDs.
// A still-active component must prevent the shortcut; an inactive grid must
// publish precisely the normal finalization status without reading solution data.
namespace MotionModeTest {
__global__ void checkCooperativeRetirement(PersistentStressArgs a,unsigned blocks,unsigned islands,unsigned* retired){
    const bool result=retireConvergedStressGrid(a,blocks,islands);
    if(!threadIdx.x)retired[blockIdx.x]=result;
}
void cooperativeRetirement(){
    constexpr unsigned n=513,slots=4,blocks=3;
    Device<unsigned> ids(3),tallies(blocks),iteration(1),retired(2);
    Device<float> gamma(n),energy(n),partials(n*slots);Device<double> magnitude(n);Device<SolveStatus> status(1);
    ids.put({2,256,512});
    PersistentStressArgs a{};a.islandIds=ids.data;a.slots=slots;a.m_blockActiveCounts=tallies.data;
    a.m_iteration=iteration.data;a.m_status=status.data;a.hierarchy.gamma=gamma.data;
    a.hierarchy.normalizer=magnitude.data;a.m_projectedDirectionSquared=energy.data;a.m_reduceSlots=partials.data;
    for(unsigned test=0;test<4;++test){
        tallies.put(test==0?std::vector<unsigned>{0,1,0}:std::vector<unsigned>{0,0,0});
        iteration.put({7});status.put({SolveStatus{1,99,test==3?1u:0u}});
        gamma.put(std::vector<float>(n,19));energy.put(std::vector<float>(n,23));
        magnitude.put(std::vector<double>(n,29));partials.put(std::vector<float>(n*slots,31));
        unsigned blockCount=blocks,islands=test==2?0:3;unsigned* flags=retired.data;
        void* args[]={&a,&blockCount,&islands,&flags};
        check(cudaLaunchCooperativeKernel((void*)checkCooperativeRetirement,dim3(2),dim3(kBlockSize),args,0,nullptr));
        check(cudaDeviceSynchronize());const auto st=status.get()[0];
        const auto g=gamma.get(),e=energy.get(),p=partials.get();const auto m=magnitude.get();
        for(auto flag:retired.get())require(flag==unsigned(test!=0),"cooperative retirement branch diverged or skipped active work");
        require(iteration.get()[0]==(test?8u:7u),"cooperative retirement iteration mismatch");
        require(st.active==(test?0u:1u) && st.converged==unsigned(test!=0) && st.iterations==((test==1 || test==2)?7u:99u),"cooperative retirement status mismatch");
        for(unsigned id=0;id<n;++id){const bool clear=test && islands && (id==2 || id==256 || id==512);
            require(g[id]==(clear?0:19) && e[id]==(clear?0:23) && m[id]==(clear?0:29),"cooperative retirement changed unselected island or omitted finalization");
            for(unsigned slot=0;slot<slots;++slot)require(p[id*slots+slot]==(clear?0:31),"cooperative retirement scratch mismatch");}
    }
    std::puts("GPU cooperative retirement: two CTAs, sparse IDs, active/retired/empty/prior-status cases passed");
}
}
