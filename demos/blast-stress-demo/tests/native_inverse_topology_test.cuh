// Exact cache ownership test: an internal cut invalidates its two endpoint
// operators, not every node in that old stress component. Shared support does
// not spread local invalidation to the other structure.
namespace MotionModeTest {

// Compare retained production factors with a fresh construction after the
// producer certifies a local cut. Stale/future/unknown proofs must rebuild.
__global__ void factorReusePair(Input input,Buffers retained,Buffers fresh,Status* status){
    buildFineDiagonal(input,retained,status,0);
    input.fineDiagonalValid=nullptr;input.fineDiagonalGeneration=nullptr;
    buildFineDiagonal(input,fresh,status,0);
}
void factorReuseLifetime(){
    Fixture f(6);f.edge(0,1);f.edge(1,2);f.edge(2,3);f.edge(0,4);f.edge(4,5);f.csr();
    Device<unsigned> begin(f.begin.size()),refs(f.refs.size()),mask(f.a.size()),valid(f.n),labels(f.n);
    Device<float> health(f.health.size()),scale(f.scale.size());
    Device<float4> offset0(f.offset0.size()),offset1(f.offset1.size());Device<float2> inertia(f.n);
    Device<std::uint64_t> cached(f.n),generation(1);Device<DeviceStressTopologyBatch> batch(1);
    Device<ExtStressGpuDeviceTopologyStatus> state(1);Device<Status> status(1);
    Device<double> retained(f.n*DiagonalEntries),fresh(f.n*DiagonalEntries);
    begin.put(f.begin);refs.put(f.refs);health.put(f.health);scale.put(f.scale);
    offset0.put(f.offset0);offset1.put(f.offset1);inertia.put(std::vector<float2>(f.n,make_float2(1,1)));labels.put(std::vector<unsigned>(f.n,0));
    generation.put({7});cached.put(std::vector<std::uint64_t>(f.n,7));valid.put(std::vector<unsigned>(f.n,0));status.put({{}});
    Input input{};input.nodes=f.n;input.bonds=f.a.size();input.begin=begin.data;input.refs=refs.data;input.component=labels.data;
    input.health=health.data;input.scale=scale.data;input.offset0=offset0.data;input.offset1=offset1.data;input.inertia=inertia.data;
    input.generation=generation.data;input.fineDiagonalValid=valid.data;input.fineDiagonalGeneration=cached.data;
    Buffers keep{},reference{};keep.diagonal=retained.data;reference.diagonal=fresh.data;
    factorReusePair<<<1,256>>>(input,keep,reference,status.data);check(cudaGetLastError());check(cudaDeviceSynchronize());
    require(retained.get()==fresh.get(),"cold factors differ from fresh construction");
    ExtStressGpuDeviceTopologyStatus old{};old.initialized=1;old.generation=7;state.put({old});
    valid.put(std::vector<unsigned>(f.n,1));generation.put({8});std::vector<unsigned> desired(f.a.size(),1);desired[2]=0;mask.put(desired);
    batch.put({{mask.data,generation.data,nullptr}});
    refreshNativeInverseValidity<<<1,32>>>(batch.data,state.data,begin.data,refs.data,health.data,valid.data,cached.data,f.n);
    check(cudaGetLastError());check(cudaDeviceSynchronize());auto alive=f.health;alive[2]=0;health.put(alive);
    factorReusePair<<<1,256>>>(input,keep,reference,status.data);check(cudaGetLastError());check(cudaDeviceSynchronize());
    require(retained.get()==fresh.get(),"retained factors differ after incident cut");
    for(unsigned mode=0;mode<3;++mode){
        retained.put(std::vector<double>(f.n*DiagonalEntries,-12345));valid.put(std::vector<unsigned>(f.n,mode!=2));
        cached.put(std::vector<std::uint64_t>(f.n,mode==0?7:mode==1?9:8));
        factorReusePair<<<1,256>>>(input,keep,reference,status.data);check(cudaGetLastError());check(cudaDeviceSynchronize());
        require(retained.get()==fresh.get(),"stale/future/unknown factor proof skipped construction");
    }
    require(!status.get()[0].error,"factor reuse fixture failed assembly");
    std::printf("GPU factor reuse: cold/local cut/stale/future/unknown proofs match fresh factors exactly\n");
}

void inverseTopologyLifetime(){
    factorReuseLifetime();
    Fixture f(6);f.edge(0,1);f.edge(1,2);f.edge(2,3);f.edge(0,4);f.edge(4,5);f.csr();
    Device<unsigned> begin(f.begin.size()),refs(f.refs.size()),mask(f.a.size()),valid(f.n);
    Device<float> health(f.health.size());Device<std::uint64_t> cached(f.n),next(1);
    Device<DeviceStressTopologyBatch> batch(1);Device<ExtStressGpuDeviceTopologyStatus> state(1);
    begin.put(f.begin);refs.put(f.refs);next.put({8});batch.put({{mask.data,next.data,nullptr}});
    for(unsigned scenario=0;scenario<6;++scenario){
        ExtStressGpuDeviceTopologyStatus status{};status.initialized=scenario!=0;status.generation=7;state.put({status});
        auto alive=f.health;std::vector<unsigned> desired(f.a.size(),1),flags(f.n,1);std::vector<std::uint64_t> generations(f.n,7);
        if(scenario==1){flags[1]=0;generations[4]=6;} // Unknown and stale cannot gain validity.
        if(scenario==2)desired[2]=0; // Only 2 and 3, despite 1 sharing their old component.
        if(scenario==3)desired[0]=0; // Only 0 and 1, not the other supported structure.
        if(scenario==4){alive[2]=0;desired[2]=0;} // An already removed edge is not a new change.
        if(scenario==5){generations[2]=8;flags[3]=0;} // Future/stale and unknown remain invalid.
        health.put(alive);mask.put(desired);valid.put(flags);cached.put(generations);
        refreshNativeInverseValidity<<<1,32>>>(batch.data,state.data,begin.data,refs.data,health.data,valid.data,cached.data,f.n);
        check(cudaGetLastError());check(cudaDeviceSynchronize());const auto got=valid.get();const auto epochs=cached.get();
        for(unsigned node=0;node<f.n;++node){bool expected=scenario && flags[node] && generations[node]==7;
            for(unsigned e=0;e<f.a.size();++e)if((f.a[e]==node || f.b[e]==node) && alive[e]>0 && !desired[e])expected=false;
            require(got[node]==unsigned(expected),"local inverse invalidation exceeded or missed incident changes");
            require(epochs[node]==(expected?8:generations[node]),"invalid inverse acquired a new generation certificate");}
    }
    std::printf("GPU inverse topology lifetime: 6 nodes, 5 bonds, shared support; six cold/unknown/stale/cut/repeated-cut cases passed\n");
}
}
