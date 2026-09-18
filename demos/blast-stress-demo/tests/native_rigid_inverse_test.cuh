// Qualify the structured production inverse on independently assembled physical
// blocks. Preserve the general dense reference test and its tolerances.
namespace MotionModeTest {
__global__ void checkRigidInverse(NativeStressCycleView h,const Vector* rhs,Vector* actual,Vector* reference,unsigned n){
    const unsigned node=blockIdx.x*blockDim.x+threadIdx.x;if(node>=n)return;
    buildNativeRigidInverse(h,node);
    actual[node]=applyNativeRigidInverse(h,node,rhs[node]);
    reference[node]=solveFineDiagonalThread(h.cycle.levels[0].diagonal,node,rhs[node]);
}
void rigidInverseCache(){
    constexpr unsigned originalCount=257,n=3*originalCount;
    Device<double> factors(n*DiagonalEntries),inverse(n*10);
    Device<unsigned> valid(n);Device<std::uint64_t> generation(n);
    Device<CycleLevel> levels(1);Device<ExtStressGpuDeviceTopologyStatus> status(1);
    Device<Vector> rhs(n),actual(n),reference(n);
    CycleLevel level{};level.diagonal.diagonal=factors.data;levels.put({level});
    NativeStressCycleView h{};h.cycle.levels=levels.data;h.topology=status.data;h.inverseStride=n;
    h.fineInverse=inverse.data;h.inverseValid=valid.data;h.inverseGeneration=generation.data;
    std::vector<double> matrix(n*DiagonalEntries);std::vector<Vector> loads(n);
    for(unsigned node=0;node<n;++node){
        const unsigned sample=node%originalCount,family=node/originalCount;
        // Independent physical B*B^T assembly from offset force/moment columns.
        // Unequal angular/linear scales, arbitrary offsets and varied degrees.
        long double d[6][6]{},l[6][6]{};
        const long double angular=.25L+(sample%11)/8.L,linear=.5L+(sample%7)/4.L;
        for(unsigned edge=0;edge<1+sample%9;++edge){
            Three offset={(int((sample+edge*3)%13)-6)/4.L,
                (int((sample*3+edge)%11)-5)/3.L,(int((sample+edge*7)%17)-8)/5.L};
            if(family==1)offset={0,0,0}; // exactly diagonal physical blocks
            if(family==2)for(auto& v:offset)v*=1e-10L; // tiny nonzero is not diagonal
            const long double weight=.25L+(edge%5)/3.L;
            for(unsigned column=0;column<6;++column){
                Three force{},moment{};if(column<3)moment[column]=1;else force[column-3]=1;
                moment=minus(moment,product(offset,force));Six v{};
                for(unsigned k=0;k<3;++k){v[k]=angular*moment[k];v[k+3]=linear*force[k];}
                for(unsigned r=0;r<6;++r)for(unsigned c=0;c<6;++c)d[r][c]+=weight*v[r]*v[c];
            }
        }
        for(unsigned r=0;r<6;++r)for(unsigned c=0;c<=r;++c){
            long double v=d[r][c];for(unsigned j=0;j<c;++j)v-=l[r][j]*l[c][j];
            require(c!=r || v>0,"rigid inverse oracle matrix is not SPD");
            l[r][c]=r==c?sqrtl(v):v/l[c][c];
            matrix[node*DiagonalEntries+r*(r+1)/2+c]=double(l[r][c]);
        }
        Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((node*3+k*7)%17)-8)/8.L;loads[node]=pack(v);
    }
    rhs.put(loads);std::vector<Vector> previous;double worst=0;
    for(unsigned test=0;test<4;++test){
        if(test==1)for(auto& entry:matrix)entry*=2; // A changed factor alone cannot silently refresh cached state.
        factors.put(matrix);ExtStressGpuDeviceTopologyStatus state{};state.initialized=1;state.generation=test<3?0:1;status.put({state});
        if(test==2){auto flags=valid.get();flags[0]=0;valid.put(flags);} // Unknown entry, even in a solved generation.
        checkRigidInverse<<<(n+127)/128,128>>>(h,rhs.data,actual.data,reference.data,n);check(cudaGetLastError());check(cudaDeviceSynchronize());
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
        checkRigidInverse<<<(n+127)/128,128>>>(h,rhs.data,actual.data,reference.data,n);check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto result=actual.get(),direct=reference.get();
        for(unsigned node=0;node<n;++node){const auto a=unpack(result[node]),b=unpack(direct[node]);
            for(unsigned k=0;k<6;++k){const double error=double(std::abs(a[k]-b[k])/std::max(1.L,std::abs(b[k])));worst=std::max(worst,error);
                require(std::isfinite(error) && error<2e-12,"cached local inverse basis differs from triangular reference");}}
    }
    std::printf("GPU rigid inverse: %u six-variable SPD blocks, cold/reuse/unknown/generation checks passed, scaled error %.9g\n",n,worst);
}
}
