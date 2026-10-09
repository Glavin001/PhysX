// A solve must never report convergence for an answer it did not compute.
//
// The native solve's unknowns are the bond forces lambda of
//     A lambda = b,  A = D C S,  D = (massScale M^-1)^1/2,  b = (M / massScale)^1/2 a / L,
// i.e. every chunk's force balance, each row weighted by 1/sqrt(m) (vibe-land
// simply-supported-point/n37: the stage reported "converged" at iteration 0,
// every tick, with zero bond forces against 49 kN reactions).
//
// Its residual test (Blast cgnr.h, Golub & Van Loan 11.3.9) accepts when
// ||A^T r|| <= tol ||b||. A^T r is a bond-space quantity (relative chunk
// accelerations), b a node-space one (sqrt(m) a): the test is relative only
// while ||A|| ~ 1, which held with Blast's equalized masses and does not with
// the native M^-1/2 weighting. On a cold start r = b and, under gravity alone,
// A^T b is nonzero only at the anchor bonds (s g / L each), whatever the
// masses, while ||b||^2 = g^2 sum(m) / (massScale L^2). So iteration 0 passes
// whenever s_anchor^2 massScale / sum(m) < tol^2: one heavy chunk on light
// ones (massScale is the geometric mean mass) passes it with lambda = 0.
//
// The fixture: a column on one anchor, four 0.1 g blocks under a 10 t mass
// (masses spanning 1e8, as n37's 10 t load on 0.08 g support blocks). Each
// bond carries the weight above it (statics, [Hibbeler] 5.3); the anchor
// bond carries the whole weight W. The gate is the solve's own claim: the
// relative residual ||r|| <= tol ||b|| of this compatible system (Barrett et
// al., Templates (1994) 4.2.1; Paige & Saunders, LSQR (1982) rule S1) bounds
// the net force imbalance of the whole column, sum_i sqrt(m_i) r_i, by
// sqrt(sum m) ||r|| <= tol sqrt(sum m) ||b|| = tol W (Cauchy-Schwarz). So a
// solve reported converged must carry W at its anchor to within tol W (plus
// FP32 rounding of the sums, ~1e-7 W, far inside it). An unconverged report
// is honest whatever its forces. Run as the stage runs: 64 iterations a
// tick, tolerance 1e-3, warm start, for several ticks; with and without the
// force tolerance (the high-fidelity profile's 1e-3).
void zeroIterationConvergence(){
    constexpr unsigned light=4,n=light+2;   // the anchor, four blocks, the load
    constexpr float tol=1e-3f,g=9.81f,lightMass=1e-4f,loadMass=1e4f;
    std::vector<ExtStressGpuNode> nodes(n);std::vector<ExtStressGpuBond> bonds;
    for(unsigned i=0;i<n;++i){
        const float m=i==0?0.f:(i<=light?lightMass:loadMass);
        nodes[i]={{0,float(i),0},m,m/6};   // unit cubes: I = m/6
        if(i){ExtStressGpuBond b{};b.node0=i-1;b.node1=i;b.centroid[1]=float(i)-.5f;b.normal[1]=1;bonds.push_back(b);}
    }
    const unsigned m=unsigned(bonds.size());
    // The fixture must fool the residual test at iteration 0 (else it tests
    // nothing): massScale / sum(m) < tol^2, the anchor bond's s = 1.
    double logMass=0,total=0;for(unsigned i=1;i<n;++i){logMass+=std::log(double(nodes[i].mass));total+=nodes[i].mass;}
    const double massScale=std::exp(logMass/(n-1)),W=total*g;
    require(massScale/total<double(tol)*tol,"zero iteration: the fixture does not pass the residual test at iteration 0");
    std::vector<ExtStressGpuImpulse> gravity(n);for(unsigned i=1;i<n;++i)gravity[i].linear.y=-g;
    unsigned dishonest=0;
    for(float forceTolerance:{0.f,1e-3f}){
        std::unique_ptr<ExtStressGpuSolver,Release> solver(ExtStressGpuSolver::create(nodes.data(),n,bonds.data(),m));
        require(bool(solver) && solver->prepareDeviceSolve() && solver->enableDeviceTopology(),"zero iteration: solver initialization failed");
        cudaStream_t stream;cudaEvent_t ready;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
        for(unsigned tick=1;tick<=8;++tick){
            auto view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
            ExtStressGpuSolveParams params;params.maxIterations=64;params.tolerance=tol;params.forceTolerance=forceTolerance;params.warmStart=true;
            check(cudaMemcpyAsync(view.nodeInputs,gravity.data(),n*sizeof(gravity[0]),cudaMemcpyHostToDevice,stream));check(cudaEventRecord(ready,stream));
            require(solver->solveDeviceAsync(view.nodeInputs,n,params,ready),"zero iteration: solve rejected");
            view=solver->deviceView();check(cudaEventSynchronize(reinterpret_cast<cudaEvent_t>(view.readyEvent)));
            ExtStressGpuDeviceStatus status{};check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));
            std::vector<ExtStressGpuImpulse> out(m);check(cudaMemcpy(out.data(),view.bondImpulses,m*sizeof(out[0]),cudaMemcpyDeviceToHost));
            // Bond orientation may use either action/reaction convention.
            const double reaction=std::fabs(double(out[0].linear.y)),error=std::fabs(reaction-W);
            std::printf("zero iteration: force tolerance %g, tick %u: %u iterations, converged %u; anchor bond %.6g N of the weight %.6g N (error %.3g of W)\n",
                forceTolerance,tick,status.iterations,status.converged,reaction,W,error/W);
            if(status.converged && !(error<=double(tol)*W))++dishonest;
        }
        check(cudaEventDestroy(ready));check(cudaStreamDestroy(stream));
    }
    require(dishonest==0,"zero iteration: a solve reported converged with the anchor reaction off the weight by more than its tolerance");
}
