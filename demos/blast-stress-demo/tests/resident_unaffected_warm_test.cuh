// Public native API regression: fracture one of two independent columns.
// The surviving column keeps its initial guess, still checks equilibrium,
// and must respond to a later changed load rather than accepting stale stress.
void unaffectedWarmColumn(){
    constexpr unsigned height=32,n=2*height,m=2*(height-1);
    std::vector<ExtStressGpuNode> nodes(n);std::vector<ExtStressGpuBond> bonds;
    std::vector<ExtStressGpuImpulse> loads(n);
    for(unsigned i=0;i<n;++i){const unsigned j=i%height,c=i/height;
        nodes[i]={{float(c)*4,float(j),0},j?1.f:0.f,j?.5f:0.f};loads[i].linear.y=j?-1.f:0.f;
        if(j){ExtStressGpuBond b{};b.node0=i-1;b.node1=i;b.centroid[0]=float(c)*4;b.centroid[1]=float(j)-.5f;b.normal[1]=1;bonds.push_back(b);}}
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),m));
    require(bool(solver) && solver->enableDeviceTopology(),"unaffected warm column initialization failed");
    cudaStream_t stream;cudaEvent_t ready;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    unsigned* mask=nullptr;std::uint64_t* generation=nullptr;check(cudaMalloc(&mask,m*sizeof(unsigned)));check(cudaMalloc(&generation,sizeof(std::uint64_t)));
    ExtStressGpuSolveParams params;params.maxIterations=512;params.tolerance=1e-5f;params.warmStart=true;
    unsigned cold=0,preserved=0;
    for(unsigned step=0;step<4;++step){
        auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        if(step==1){std::vector<unsigned> alive(m,1);std::fill(alive.begin(),alive.begin()+height-1,0);const std::uint64_t gen=1;
            check(cudaMemcpyAsync(mask,alive.data(),m*sizeof(unsigned),cudaMemcpyHostToDevice,stream));check(cudaMemcpyAsync(generation,&gen,sizeof(gen),cudaMemcpyHostToDevice,stream));check(cudaEventRecord(ready,stream));
            require(solver->updateDeviceTopologyAsync(mask,m,generation,nullptr,ready),"unaffected warm column split rejected");
            check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(solver->deviceView().readyEvent)));}
        const float multiplier=step==3?0.f:(step==2?2.f:1.f);
        for(unsigned i=0;i<n;++i)loads[i].linear.y=(i%height && (!step || i>=height))?-multiplier:0;
        check(cudaMemcpyAsync(view.nodeInputs,loads.data(),n*sizeof(loads[0]),cudaMemcpyHostToDevice,stream));check(cudaEventRecord(ready,stream));
        require(solver->solveDeviceAsync(view.nodeInputs,n,params,ready),"unaffected warm column solve rejected");view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));require(status.converged,"unaffected warm column did not converge");
        if(!step)cold=status.iterations;if(step==1)preserved=status.iterations;
        std::vector<ExtStressGpuImpulse> actual(m);check(cudaMemcpy(actual.data(),view.bondImpulses,m*sizeof(actual[0]),cudaMemcpyDeviceToHost));
        for(unsigned e=0;e<m;++e){const float target=step && e<height-1?0.f:float(height-1-e%(height-1))*multiplier;const auto f=actual[e];
            const float error=std::max({std::abs(std::abs(f.linear.y)-target),std::abs(f.linear.x),std::abs(f.linear.z),std::abs(f.angular.x),std::abs(f.angular.y),std::abs(f.angular.z)})/std::max(1.f,target);
            require(std::isfinite(error) && error<2e-4f,"unaffected warm column physical response changed");}
    }
    // The cached direct factorization solves an anchored column exactly at cold
    // start, so both counts can be zero; a preserved warm start must never cost
    // more iterations than the cold solve did.
    require(preserved<cold || (preserved==0 && cold==0),"unrelated fracture discarded the surviving column warm start");
    check(cudaFree(mask));check(cudaFree(generation));check(cudaEventDestroy(ready));check(cudaStreamDestroy(stream));
    std::printf("resident unaffected warm column: 64 nodes, 62 bonds, two supported columns; cold=%u preserved=%u; fracture/doubled/zero loads passed\n",cold,preserved);
}
