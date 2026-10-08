// The corrected pass's warm start (ExtStressGpuSnapshotWarmStart /
// ExtStressGpuRestoreWarmStart, PhysX PX_DESTRUCTION_CORRECTED_WARM_START).
// A stage that re-simulates a tick solves the trial pass under the tick's
// contact loads, then the corrected pass under the loads the re-simulation
// produces. With the product's capped iteration count (64), the corrected
// solve's answer depends on where it starts: from the trial's iterate it
// carries the trial's loads into its verdict. Restored, it starts where the
// tick began.
//
// A wall (supported along its base) converged under its own weight is the
// tick's start. Then, at 64 iterations:
//   R2: restore, solve gravity                      (the corrected pass with no trial)
//   R1: restore, solve gravity + a lateral impact load (the trial), restore, solve gravity
//   R3: as R1 without the second restore           (the corrected pass from the trial's iterate)
// R1 must equal R2 bit for bit: the corrected pass does not remember the trial.
// R3 must differ from R2 by more than the solve tolerance (1e-3, the product's), or the fixture does
// not exercise the warm start (the test would pass with it broken).
void correctedWarmStart(){
    constexpr unsigned W=48,H=24,n=W*H;
    std::vector<ExtStressGpuNode> nodes(n);std::vector<ExtStressGpuBond> bonds;
    for(unsigned y=0;y<H;++y)for(unsigned x=0;x<W;++x){
        const unsigned i=y*W+x;const bool support=y==0;
        nodes[i]={{float(x),float(y),0},support?0.f:1.f,support?0.f:.5f};
        if(x){ExtStressGpuBond b{};b.node0=i-1;b.node1=i;b.centroid[0]=float(x)-.5f;b.centroid[1]=float(y);b.normal[0]=1;bonds.push_back(b);}
        if(y){ExtStressGpuBond b{};b.node0=i-W;b.node1=i;b.centroid[0]=float(x);b.centroid[1]=float(y)-.5f;b.normal[1]=1;bonds.push_back(b);}
    }
    const unsigned m=unsigned(bonds.size());
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),m));
    require(bool(solver) && solver->prepareDeviceSolve() && solver->enableDeviceTopology(),"corrected warm start: solver initialization failed");
    cudaStream_t stream;cudaEvent_t ready;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    // Gravity: each free node's weight (unit mass, g = 9.81); the trial adds a
    // lateral load at the top middle, 1000 times a node's weight (a rigid stop's
    // contact impulse over a tick is of that order: m v / dt).
    std::vector<ExtStressGpuImpulse> gravity(n),trial(n);
    for(unsigned i=0;i<n;++i){gravity[i].linear.y=i>=W?-9.81f:0.f;trial[i]=gravity[i];}
    trial[(H-1)*W+W/2].linear.x=9810.f;
    auto solve=[&](const std::vector<ExtStressGpuImpulse>& loads,unsigned iterations){
        auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        ExtStressGpuSolveParams params;params.maxIterations=iterations;params.tolerance=1e-3f;   // the product's (vibe-land native destruction)params.warmStart=true;
        check(cudaMemcpyAsync(view.nodeInputs,loads.data(),n*sizeof(loads[0]),cudaMemcpyHostToDevice,stream));check(cudaEventRecord(ready,stream));
        require(solver->solveDeviceAsync(view.nodeInputs,n,params,ready),"corrected warm start: solve rejected");
        view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
        std::vector<ExtStressGpuImpulse> out(m);check(cudaMemcpy(out.data(),view.bondImpulses,m*sizeof(out[0]),cudaMemcpyDeviceToHost));
        return std::make_pair(out,status);
    };
    auto sync=[&]{check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(solver->deviceView().readyEvent)));};
    const auto start=solve(gravity,4096);if(!start.second.converged){std::printf("start: %u iterations, not converged\n",start.second.iterations);require(false,"corrected warm start: the tick's start did not converge");}
    require(ExtStressGpuSnapshotWarmStart(solver.get()),"corrected warm start: snapshot rejected");sync();
    require(ExtStressGpuRestoreWarmStart(solver.get()),"corrected warm start: restore rejected");
    const auto r2=solve(gravity,64);
    require(ExtStressGpuRestoreWarmStart(solver.get()),"corrected warm start: restore rejected");
    const auto trialPass=solve(trial,64);
    require(ExtStressGpuRestoreWarmStart(solver.get()),"corrected warm start: restore rejected");
    const auto r1=solve(gravity,64);
    require(ExtStressGpuRestoreWarmStart(solver.get()),"corrected warm start: restore rejected");
    solve(trial,64);
    const auto r3=solve(gravity,64);
    double same=0,stale=0,scale=0;
    for(unsigned e=0;e<m;++e){
        const float* a=&r1.first[e].angular.x;const float* b=&r2.first[e].angular.x;const float* c=&r3.first[e].angular.x;
        for(int k=0;k<6;++k){same=std::max(same,double(std::fabs(a[k]-b[k])));stale=std::max(stale,double(std::fabs(c[k]-b[k])));scale=std::max(scale,double(std::fabs(b[k])));}
    }
    require(std::memcmp(r1.first.data(),r2.first.data(),m*sizeof(r1.first[0]))==0,"corrected warm start: the corrected pass remembers the trial");
    require(stale>1e-3*scale,"corrected warm start: the fixture does not depend on the warm start (the trial's iterate changes nothing)");
    check(cudaEventDestroy(ready));check(cudaStreamDestroy(stream));
    std::printf("resident corrected warm start: %u nodes, %u bonds; start converged in %u; at 64 iterations the restored corrected pass equals the "
        "trial-free one bit for bit (max diff %.3g); from the trial's iterate it is off by %.3g of %.3g (%u iterations, converged %u)\n",
        n,m,start.second.iterations,same,stale,scale,r3.second.iterations,r3.second.converged);
    (void)trialPass;
}
