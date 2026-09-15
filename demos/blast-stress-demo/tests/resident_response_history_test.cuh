// Independent supported-chain force balance under correlated, nonidentical
// current loads. Sign reversal, zero loads and cold ownership are intentional.
void nativeResponseHistoryLoads(){
    constexpr unsigned n=32;
    std::vector<ExtStressGpuNode> nodes(n);
    std::vector<ExtStressGpuBond> bonds;
    std::vector<ExtStressGpuImpulse> loads(n),observed(n-1);
    for(unsigned i=0;i<n;++i){nodes[i]={{0,float(i),0},i?1.f:0.f,i?.5f:0.f};
        if(i){ExtStressGpuBond b{};b.node0=i-1;b.node1=i;b.centroid[1]=float(i)-.5f;b.normal[1]=1;bonds.push_back(b);}}
    std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),bonds.size()));
    require(bool(solver)&&solver->enableDeviceTopology(),"response history fixture initialization failed");
    ExtStressGpuSolveParams params;params.maxIterations=128;params.tolerance=1e-5f;
    const float amplitudes[]={1,1.25f,1.5f,-.5f,-.75f,-1,0,0,2};
    for(unsigned revision=0;revision<9;++revision){
        for(unsigned i=1;i<n;++i)loads[i].linear.y=amplitudes[revision]*(1.f+.05f*(i%3)+.125f*(revision%3)*(i%2?1.f:-1.f));
        params.warmStart=revision!=0;
        auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        check(cudaMemcpy(view.nodeInputs,loads.data(),sizeof(loads[0])*n,cudaMemcpyHostToDevice));
        require(solver->solveDeviceAsync(view.nodeInputs,n,params),"response history current solve rejected");
        view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
        ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
        require(status.converged && status.iterations<=params.maxIterations,"response history current load did not converge");
        check(cudaMemcpy(observed.data(),view.bondImpulses,sizeof(observed[0])*observed.size(),cudaMemcpyDeviceToHost));
        double total=0;for(unsigned i=1;i<n;++i)total+=loads[i].linear.y;
        const double orientation=total && observed[0].linear.y*total<0?-1.:1.;
        double worst=0;
        for(unsigned e=0;e<n-1;++e){double expected=0;for(unsigned i=e+1;i<n;++i)expected+=loads[i].linear.y;
            const auto f=observed[e];for(float x:{f.angular.x,f.angular.y,f.angular.z,f.linear.x,f.linear.y,f.linear.z})require(std::isfinite(x),"response history nonfinite force");
            const double error=std::max({std::abs(double(f.linear.y)-orientation*expected),std::abs(double(f.linear.x)),std::abs(double(f.linear.z)),std::abs(double(f.angular.x)),std::abs(double(f.angular.y)),std::abs(double(f.angular.z))})/std::max(1.,std::abs(expected));
            worst=std::max(worst,error);
        }
        require(worst<2e-4,"response history violated current-load force balance");
        std::printf("response history revision=%u amplitude=%g iterations=%u worst_force_error=%g\n",revision,amplitudes[revision],status.iterations,worst);
    }
}
