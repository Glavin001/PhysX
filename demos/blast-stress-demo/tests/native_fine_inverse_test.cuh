// Qualify the actual production cache/application against the independently
// qualified triangular solver, without changing that solver's bitwise tests.
namespace MotionModeTest {
__global__ void checkFineInverse(NativeStressCycleView h,const Vector* rhs,Vector* actual,Vector* reference,unsigned n){
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;if(node>=n)return;
    buildNativeFineInverse(h,node);
    actual[node]=applyNativeFineInverse(h,node,rhs[node]);
    reference[node]=solveFineDiagonalThread(h.cycle.levels[0].diagonal,node,rhs[node]);
}
void fineInverseCache(){
    constexpr unsigned n=257;
    Device<double> factors(n*DiagonalEntries),inverse(n*DiagonalEntries);
    Device<unsigned> valid(n);Device<std::uint64_t> generation(n);
    Device<CycleLevel> levels(1);Device<ExtStressGpuDeviceTopologyStatus> status(1);
    Device<Vector> rhs(n),actual(n),reference(n);
    CycleLevel level{};level.diagonal.diagonal=factors.data;levels.put({level});
    NativeStressCycleView h{};h.cycle.levels=levels.data;h.topology=status.data;h.inverseStride=n;
    h.fineInverse=inverse.data;h.inverseValid=valid.data;h.inverseGeneration=generation.data;
    std::vector<double> matrix(n*DiagonalEntries);std::vector<Vector> loads(n);
    for(unsigned node=0;node<n;++node){
        for(unsigned row=0;row<6;++row)for(unsigned col=0;col<=row;++col)
            matrix[node*DiagonalEntries+row*(row+1)/2+col]=row==col?(.5+double((node+row)%11)/8):(int((node*7+row*3+col)%9)-4)/32.;
        Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((node*3+k*7)%17)-8)/8.L;loads[node]=pack(v);
    }
    rhs.put(loads);std::vector<Vector> previous;double worst=0;
    for(unsigned test=0;test<4;++test){
        if(test==1)for(auto& entry:matrix)entry*=2; // A changed factor alone cannot silently refresh cached state.
        factors.put(matrix);ExtStressGpuDeviceTopologyStatus state{};state.initialized=1;state.generation=test<3?0:1;status.put({state});
        if(test==2){auto flags=valid.get();flags[0]=0;valid.put(flags);} // Unknown entry, even in a solved generation.
        checkFineInverse<<<(n+127)/128,128>>>(h,rhs.data,actual.data,reference.data,n);check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto result=actual.get(),direct=reference.get();
        for(unsigned node=0;node<n;++node){const auto expected=(test==1 || (test==2 && node))?previous[node]:direct[node];
            const auto a=unpack(result[node]),b=unpack(expected);for(unsigned k=0;k<6;++k){
                const double error=double(std::abs(a[k]-b[k])/std::max(1.L,std::abs(b[k])));worst=std::max(worst,error);
                require(std::isfinite(error) && error<2e-12,"cached local operator differs from triangular reference or reused wrong generation");}}
        previous=result;
    }
    // Check every matrix column, not only the mixed right-hand side used to
    // exercise cache lifetime above. The triangular oracle remains unchanged.
    for(unsigned column=0;column<6;++column){
        Six v{};v[column]=1;rhs.put(std::vector<Vector>(n,pack(v)));
        checkFineInverse<<<(n+127)/128,128>>>(h,rhs.data,actual.data,reference.data,n);check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto result=actual.get(),direct=reference.get();
        for(unsigned node=0;node<n;++node){const auto a=unpack(result[node]),b=unpack(direct[node]);
            for(unsigned k=0;k<6;++k){const double error=double(std::abs(a[k]-b[k])/std::max(1.L,std::abs(b[k])));worst=std::max(worst,error);
                require(std::isfinite(error) && error<2e-12,"cached local inverse basis differs from triangular reference");}}
    }
    std::printf("GPU local inverse: %u six-variable SPD blocks, cold/reuse/unknown/generation checks passed, scaled error %.9g\n",n,worst);
}
}
