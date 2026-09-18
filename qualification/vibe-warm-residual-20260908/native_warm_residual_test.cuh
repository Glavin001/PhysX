// Independent force/couple sum checks the native initialization before any
// iteration. Include cancellation, non-unit inertia/scales and removed bonds.
namespace MotionModeTest {
__global__ void verifyZeroCorrection(PersistentStressArgs a,unsigned n){
    if(threadIdx.x<n)rebuildNativeResidualNode(a,threadIdx.x);
}
void accurateWarmResidual(){
    constexpr unsigned n=19;
    Fixture f(n);for(unsigned i=1;i<n;++i){f.edge(0,i);if(i>1)f.edge(i-1,i);}
    for(unsigned e=0;e<f.a.size();++e){f.scale[e]=.25f+float(e%5)/8; if(e%11==3)f.health[e]=0;}
    f.csr();
    std::vector<AngLin> warm(f.a.size());
    for(unsigned e=0;e<warm.size();++e){const float sign=e%2?-1.f:1.f;
        warm[e].angular={sign*(16777216.f+float(e)*2),float(e)*.125f,-sign*8192.f};
        warm[e].linear={float(e)*.0625f,sign*1048576.f,-sign*float(e+1)};}
    std::vector<AngLin> rhs(n),sentinel(n),expected(n);
    for(unsigned node=0;node<n;++node){
        Three angular{},linear{};
        for(unsigned slot=f.begin[node];slot<f.begin[node+1];++slot){const unsigned ref=f.refs[slot],e=ref&0x7fffffffu;if(f.health[e]<=0)continue;
            const bool back=ref>>31;const auto impulse=warm[e];const auto offset=coord(back?f.offset1[e]:f.offset0[e]);
            const long double scale=f.scale[e]*(back?-1.L:1.L);
            const Three force=times({impulse.linear.x,impulse.linear.y,impulse.linear.z},scale);
            const Three moment=times({impulse.angular.x,impulse.angular.y,impulse.angular.z},scale);
            angular=plus(angular,minus(moment,product(offset,force)));linear=plus(linear,force);
        }
        angular=times(angular,f.inertia[node].angular);linear=times(linear,f.inertia[node].linear);
        // The rounded RHS nearly cancels the large equilibrium response.
        rhs[node]={{float(angular[0]),float(angular[1]),float(angular[2]),0},{float(linear[0]),float(linear[1]),float(linear[2]),0}};
        expected[node]={{float((long double)rhs[node].angular.x-angular[0]),float((long double)rhs[node].angular.y-angular[1]),float((long double)rhs[node].angular.z-angular[2]),0},
                        {float((long double)rhs[node].linear.x-linear[0]),float((long double)rhs[node].linear.y-linear[1]),float((long double)rhs[node].linear.z-linear[2]),0}};
        sentinel[node]={{17,23,31,0},{37,41,43,0}};
    }
    Device<unsigned> begin(f.begin.size()),refs(f.refs.size()),active(n),counts(2);
    Device<float> health(f.health.size()),scales(f.scale.size());Device<Vec4> offset0(f.offset0.size()),offset1(f.offset1.size());
    Device<Inertia> inertia(n);Device<AngLin> impulses(warm.size());Device<AngLin> original(n),residual(n);
    std::vector<unsigned> order(n);std::iota(order.begin(),order.end(),0u);std::reverse(order.begin(),order.end());
    begin.put(f.begin);refs.put(f.refs);active.put(order);counts.put({unsigned(warm.size()),n});health.put(f.health);scales.put(f.scale);
    std::vector<Vec4> offsets0,offsets1;for(auto v:f.offset0)offsets0.push_back({v.x,v.y,v.z,0});for(auto v:f.offset1)offsets1.push_back({v.x,v.y,v.z,0});
    offset0.put(offsets0);offset1.put(offsets1);inertia.put(f.inertia);impulses.put(warm);original.put(rhs);residual.put(sentinel);
    PersistentStressArgs a{};a.m_nodeBondBegin=begin.data;a.m_nodeBondRef=refs.data;a.m_activeNodes=active.data;a.m_activeCounts=counts.data;
    a.m_health=health.data;a.m_colScales=scales.data;a.m_offset0=offset0.data;a.m_offset1=offset1.data;a.m_inertia=inertia.data;
    a.impulses=impulses.data;a.originalRhs=original.data;a.m_residual=residual.data;
    // Cold initialization must leave the already written RHS unchanged.
    initializeNativeWarmResidual<<<1,kBlockSize>>>(a);check(cudaGetLastError());check(cudaDeviceSynchronize());
    auto observed=residual.get();require(!std::memcmp(observed.data(),sentinel.data(),n*sizeof(AngLin)),"cold warm-residual launch changed RHS");
    a.warmStart=true;initializeNativeWarmResidual<<<1,kBlockSize>>>(a);check(cudaGetLastError());check(cudaDeviceSynchronize());observed=residual.get();
    require(!std::memcmp(observed.data(),expected.data(),n*sizeof(AngLin)),"warm residual differs from independent cancellation oracle");
    // The true-residual checker must give exactly the same result at zero
    // correction. It may read solution/endpoint arrays, unlike initialization.
    Device<unsigned> first(f.a.size()),second(f.b.size());Device<Vector> zero(n);first.put(f.a);second.put(f.b);
    a.m_node0=first.data;a.m_node1=second.data;a.hierarchy.solution=zero.data;
    verifyZeroCorrection<<<1,kBlockSize>>>(a,n);check(cudaGetLastError());check(cudaDeviceSynchronize());observed=residual.get();
    require(!std::memcmp(observed.data(),expected.data(),n*sizeof(AngLin)),"warm and verified zero-correction residuals disagree");
    std::printf("accurate warm residual: nodes=%u bonds=%zu cancellation/removed-bonds/cold/verification passed\n",n,warm.size());
}
}
