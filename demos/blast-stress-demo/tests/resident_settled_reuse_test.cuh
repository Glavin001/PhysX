// Integration test through the native device API, including the actual reuse
// mask. Zero iteration counts alone cannot establish that work was skipped.
void nativeSettledReuse(){
    constexpr unsigned height=32,n=2*height,m=2*(height-1);
    std::vector<ExtStressGpuNode> nodes(n);std::vector<ExtStressGpuBond> bonds;
    std::vector<ExtStressGpuImpulse> loads(n),previous(m),actual(m);
    for(unsigned i=0;i<n;++i){const unsigned j=i%height,c=i/height;
        nodes[i]={{float(c)*4,float(j),0},j?1.f:0.f,j?.5f:0.f};loads[i].linear.y=j?-1.f:0.f;
        if(j){ExtStressGpuBond b{};b.node0=i-1;b.node1=i;b.centroid[0]=float(c)*4;b.centroid[1]=float(j)-.5f;b.normal[1]=1;bonds.push_back(b);}}
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),m));
    require(bool(solver) && solver->enableDeviceTopology(),"settled solver initialization failed");
    ExtStressGpuSolveParams params;params.maxIterations=512;params.tolerance=1e-5f;params.warmStart=true;
    auto solve=[&](){auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        check(cudaMemcpy(view.nodeInputs,loads.data(),n*sizeof(loads[0]),cudaMemcpyHostToDevice));
        require(solver->solveDeviceAsync(view.nodeInputs,n,params),"settled solve rejected");view=solver->deviceView();
        check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
        std::vector<unsigned> skip(n);require(view.reusedIslands!=nullptr,"native reuse observation missing");
        check(cudaMemcpy(skip.data(),view.reusedIslands,n*sizeof(unsigned),cudaMemcpyDeviceToHost));
        check(cudaMemcpy(actual.data(),view.bondImpulses,m*sizeof(actual[0]),cudaMemcpyDeviceToHost));
        return std::make_pair(status,skip);
    };
    auto settled=[&](){bool reused=false;for(unsigned i=0;i<8;++i){auto r=solve();require(r.first.converged,"settled convergence failed");
        if(r.second[1] && r.second[height+1]){reused=true;break;}}require(reused,"verified exact inputs never reused");};
    auto first=solve();require(first.first.converged && !first.second[1] && !first.second[height+1],"cold solve used uninitialized certificate");
    settled();previous=actual;
    for(unsigned i=0;i<4;++i){const auto r=solve();require(r.first.converged && r.second[1] && r.second[height+1],"settled reuse alternated with solving");
        require(std::memcmp(previous.data(),actual.data(),m*sizeof(actual[0]))==0,"cached stored forces changed bits");}
    // An input change smaller than tolerance must still invalidate reuse.
    loads[1].linear.y=std::nextafter(loads[1].linear.y,-2.f);
    auto changed=solve();require(changed.first.converged && !changed.second[1] && changed.second[height+1],"one-ULP input change not component-local");
    require(std::memcmp(previous.data()+height-1,actual.data()+height-1,(height-1)*sizeof(actual[0]))==0,"independent cached output changed");
    settled();params.tolerance=5e-6f;auto tighter=solve();require(tighter.first.converged && !tighter.second[1] && !tighter.second[height+1],"tolerance change reused stale certificate");
    settled();params.warmStart=false;auto cold=solve();require(cold.first.converged && !cold.second[1] && !cold.second[height+1],"cold command reused warm certificate");
    params.warmStart=true;settled();
    // Unchanged inputs with a changed graph may never reuse the previous graph.
    unsigned* mask=nullptr;std::uint64_t* generation=nullptr;
    check(cudaMalloc(&mask,m*sizeof(unsigned)));check(cudaMalloc(&generation,sizeof(std::uint64_t)));
    std::vector<unsigned> live(m,1u);live[height/2-1]=0u;std::uint64_t gen=1;
    check(cudaMemcpy(mask,live.data(),m*sizeof(unsigned),cudaMemcpyHostToDevice));check(cudaMemcpy(generation,&gen,sizeof(gen),cudaMemcpyHostToDevice));
    require(solver->updateDeviceTopologyAsync(mask,m,generation),"settled partial split rejected");
    auto partial=solve();require(partial.first.converged && !partial.second[1] && !partial.second[height/2]
        && partial.second[height+1],"split certificates did not distinguish changed and unchanged components");
    require(std::abs(std::abs(actual[0].linear.y)-float(height/2-1))<2e-4f,"split retained stale force at unchanged minimum root");
    std::fill(live.begin(),live.begin()+height-1,0u);gen=2;
    check(cudaMemcpy(mask,live.data(),m*sizeof(unsigned),cudaMemcpyHostToDevice));check(cudaMemcpy(generation,&gen,sizeof(gen),cudaMemcpyHostToDevice));
    require(solver->updateDeviceTopologyAsync(mask,m,generation),"settled topology update rejected");
    auto split=solve();require(split.first.converged && split.second[height+1],"unrelated cut discarded exact component certificate");
    for(unsigned e=0;e<m;++e){const float expected=e<height-1?0.f:float(height-1-e%(height-1));
        require(std::abs(std::abs(actual[e].linear.y)-expected)<2e-4f*std::max(1.f,expected),"settled split force incorrect");}
    // An unreachable tolerance keeps this fixture unconverged even when the
    // cached direct factorization would otherwise solve it before iterating.
    params.maxIterations=1;params.tolerance=1e-30f;
    for(unsigned i=height+1;i<n;++i)loads[i].linear.y=-3.f;
    auto incomplete=solve();require(!incomplete.first.converged && !incomplete.second[height+1],"incomplete fixture unexpectedly converged/reused");
    auto retry=solve();require(!retry.second[height+1],"unconverged output was cached");
    check(cudaFree(mask));check(cudaFree(generation));
    std::printf("resident exact settled reuse: 64 nodes / 62 bonds, zero-update certification, repeated byte-exact reuse, ULP/settings/cold/topology invalidation passed\n");
}
