// Incremental motion forest (BLAST_STRESS_INCREMENTAL_MOTION): a rebuild keeps
// the spanning tree and motion modes of every component that lost no bond.
// Runs the production producers in production order -- markChanged,
// markStable, mask, union-find with kept trees, labels, finish -- then the
// motion modes twice on the same forest: incrementally, and as a full build.
// The two must agree field for field on every live component (kept and
// rebuilt), the kept trees must not move, and the projection must still match
// the independent long-double oracle.
namespace MotionModeTest {
// An anchored component's modes are dimension 0 and nothing else of it is
// read; the incremental build does no forest work for it (skipAnchored).
bool sameComponent(const MotionComponent& x,const MotionComponent& y){
    if(x.anchored || y.anchored)return x.anchored==y.anchored;
    return x.rotations==y.rotations && x.closure==y.closure && x.cuts==y.cuts && x.edges==y.edges
        && !std::memcmp(&x.axis,&y.axis,sizeof(x.axis)) && !std::memcmp(&x.frameAxis,&y.frameAxis,sizeof(x.frameAxis))
        && !std::memcmp(x.factor,y.factor,sizeof(x.factor)) && !std::memcmp(x.scale,y.scale,sizeof(x.scale));
}
void incrementalMotion(){
    // Five separate 24-node components, each a different mode case: an open
    // chain (6 modes), a bent chain, a cycle with one closure (4), two
    // closures (3), and a chain on a fixed support (0).
    constexpr unsigned span=24,groups=5;Fixture f(span*groups);
    for(unsigned g=0;g<groups;++g){const unsigned o=g*span;for(unsigned i=1;i<span;++i)f.edge(o+i-1,o+i);
        if(g==1)f.offset1[f.a.size()-span/2].x+=.03125f;
        if(g==2 || g==3){f.edge(o+span-1,o);f.offset1.back().x+=.03125f;}
        if(g==3){f.edge(o+span/2,o);f.offset1.back().y+=.0625f;}
        if(g==4)f.inertia[o]={0,0};}
    f.csr();const unsigned n=f.n,m=f.a.size();
    // Each step removes bonds in one component only. Bond indices are in
    // edge() order: component g's chain bonds start at its first edge.
    std::vector<unsigned> firstEdge(groups);{unsigned e=0;for(unsigned g=0;g<groups;++g){firstEdge[g]=e;e+=span-1+(g==2||g==3)+(g==3);}}
    const std::vector<std::vector<unsigned>> removals{{},{firstEdge[2]+5},{firstEdge[0]+11},{firstEdge[4]+3},{firstEdge[3]+20},{firstEdge[0]+4,firstEdge[0]+17}};
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    {
        Device<unsigned> a(m),b(m),begin(n+1),refs(2*m),parent(n),identity(std::max(n,m)),flags(n),nodeIsland(n),bondIsland(m),forest(m),stable(n+m),mask(m);
        Device<unsigned> order(n),ids(n),first(n),last(n),counts(2),activeCounts(2);
        Device<float4> position(n),offset0(m),offset1(m);Device<Inertia> inertia(n);Device<float> health(m),scale(m);
        Device<DeviceStressTopologyBatch> batch(1);Device<ExtStressGpuDeviceTopologyStatus> state(1);
        a.put(f.a);b.put(f.b);begin.put(f.begin);refs.put(f.refs);position.put(f.position);offset0.put(f.offset0);offset1.put(f.offset1);inertia.put(f.inertia);scale.put(f.scale);health.put(f.health);
        Input input{n,m,begin.data,refs.data,a.data,b.data,nodeIsland.data,health.data,scale.data,position.data,offset0.data,offset1.data,
            reinterpret_cast<const float2*>(inertia.data),&state.data->rebuilds,nullptr};
        input.partition={order.data,ids.data,first.data,last.data,counts.data,counts.data+1};
        ResidentMotionModes incremental(input,forest.data,stable.data,stream),full(input,forest.data,nullptr,stream);
        cudaGraph_t graphs[2];cudaGraphExec_t runs[2];
        for(unsigned k=0;k<2;++k){check(cudaGraphCreate(&graphs[k],0));(k?full:incremental).append(graphs[k],nullptr);check(cudaGraphInstantiate(&runs[k],graphs[k],0));}
        std::vector<unsigned> alive(m,1),previousForest;std::vector<unsigned> previousLabels;
        const unsigned nb=std::max(1u,(n+Threads-1)/Threads),eb=std::max(1u,(m+Threads-1)/Threads);
        unsigned keptSteps=0;
        for(unsigned step=0;step<removals.size();++step){
            for(auto e:removals[step])alive[e]=0;mask.put(alive);
            // The first build has no prior topology and configures from health.
            batch.put({{step?mask.data:nullptr,nullptr,nullptr}});
            check(cudaMemsetAsync(flags.data,0,sizeof(unsigned)*n,stream));
            markChangedStressComponents<<<eb,Threads,0,stream>>>(batch.data,state.data,health.data,bondIsland.data,flags.data,m);
            markStableStressRows<<<std::max(nb,eb),Threads,0,stream>>>(batch.data,state.data,health.data,nodeIsland.data,bondIsland.data,flags.data,stable.data,n,m);
            beginDeviceStressRebuild<<<1,1,0,stream>>>(state.data);
            initializeDeviceStressTopology<<<std::max(nb,eb),Threads,0,stream>>>(batch.data,inertia.data,parent.data,identity.data,flags.data,health.data,n,m,forest.data,stable.data+n);
            connectDeviceStressTopology<<<eb,Threads,0,stream>>>(a.data,b.data,health.data,inertia.data,m,parent.data,forest.data,stable.data+n);
            flattenDeviceStressTopology<<<nb,Threads,0,stream>>>(parent.data,n);
            labelDeviceStressBonds<<<eb,Threads,0,stream>>>(a.data,b.data,health.data,inertia.data,parent.data,flags.data,bondIsland.data,m);
            labelDeviceStressNodes<<<nb,Threads,0,stream>>>(parent.data,flags.data,nodeIsland.data,n,state.data);
            finishDeviceStressRebuild<<<1,1,0,stream>>>(batch.data,state.data,activeCounts.data);
            check(cudaGetLastError());check(cudaStreamSynchronize(stream));
            for(unsigned e=0;e<m;++e)if(!alive[e])f.health[e]=0;
            Oracle oracle(f);require(nodeIsland.get()==oracle.labels,"incremental topology labels differ from the oracle");
            order.put(oracle.order);first.put(oracle.begin);last.put(oracle.end);auto live=oracle.ids;live.resize(n,Invalid);ids.put(live);
            unsigned active=0;for(auto id:oracle.ids)active+=oracle.components[id].nodes.size();counts.put({active,unsigned(oracle.ids.size())});
            // Which components the removal touched, independently: those whose
            // nodes held a removed bond. Every other one must be kept.
            std::vector<unsigned> touched(n,0);
            for(auto e:removals[step])if(!previousLabels.empty()){const unsigned id=previousLabels[f.a[e]]!=Invalid?previousLabels[f.a[e]]:previousLabels[f.b[e]];if(id!=Invalid)touched[id]=1;}
            const auto stableFlags=stable.get();const auto currentForest=forest.get();
            for(auto id:oracle.ids){const bool kept=step && !(previousLabels.empty() || previousLabels[id]!=id || touched[id]);
                for(auto node:oracle.components[id].nodes)require(stableFlags[node]==unsigned(kept),"stable node flag disagrees with the removed bonds");
                if(kept)for(unsigned e=0;e<m;++e)if(f.health[e]>0 && oracle.labels[f.a[e]]==id)
                    require(currentForest[e]==previousForest[e],"a kept component's spanning tree changed");}
            for(unsigned k=0;k<2;++k){check(cudaGraphLaunch(runs[k],stream));check(cudaStreamSynchronize(stream));
                Status status{};check(cudaMemcpy(&status,(k?full:incremental).status(),sizeof(status),cudaMemcpyDeviceToHost));
                require(status.initialized && !status.error && status.generation==step+1,"incremental motion construction failed");}
            const unsigned* reused=incremental.reused();
            if(reused){unsigned flag=0;check(cudaMemcpy(&flag,reused,sizeof(flag),cudaMemcpyDeviceToHost));
                require(flag==unsigned(step>0),"incremental motion build did not take the reuse path");keptSteps+=flag;}
            std::vector<MotionComponent> mine(n),theirs(n);std::vector<StressReal3> mineRelative(n),theirsRelative(n);
            check(cudaMemcpy(mine.data(),incremental.view().components,n*sizeof(MotionComponent),cudaMemcpyDeviceToHost));
            check(cudaMemcpy(theirs.data(),full.view().components,n*sizeof(MotionComponent),cudaMemcpyDeviceToHost));
            check(cudaMemcpy(mineRelative.data(),incremental.view().relative,n*sizeof(StressReal3),cudaMemcpyDeviceToHost));
            check(cudaMemcpy(theirsRelative.data(),full.view().relative,n*sizeof(StressReal3),cudaMemcpyDeviceToHost));
            for(auto id:oracle.ids){require(sameComponent(mine[id],theirs[id]),"incremental motion component differs from a full build on the same forest");
                const auto& c=oracle.components[id];require((mine[id].anchored?0:mine[id].rotations+3)==(c.anchored?0:c.rotations+3),"incremental motion dimension differs from the oracle");
                if(!mine[id].anchored)for(auto node:c.nodes)require(!std::memcmp(&mineRelative[node],&theirsRelative[node],sizeof(StressReal3)),"incremental motion frame differs from a full build");}
            // Independent oracle: the projection, as in run().
            Device<Vector> values(n),result(n);std::vector<Vector> loads(n);for(unsigned i=0;i<n;++i){Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((i*17+k*7)%23)-11)/16.L;loads[i]=pack(v);}values.put(loads);
            projectObserved<<<std::max(1u,std::min(128u,unsigned(oracle.ids.size()))),Threads,0,stream>>>(input,incremental.view(),values.data,result.data);check(cudaGetLastError());check(cudaStreamSynchronize(stream));
            const auto actual=result.get(),expected=oracle.project(f,loads);double worst=0;
            for(unsigned i=0;i<n;++i){const auto x=unpack(actual[i]),y=unpack(expected[i]);for(unsigned k=0;k<6;++k){const double error=double(std::abs(x[k]-y[k])/std::max(1.L,std::abs(y[k])));worst=std::max(worst,error);
                require(std::isfinite(error)&&error<2e-12,"incremental projection differs from the independent long-double oracle");}}
            std::printf("GPU incremental motion step=%u removed=%zu components=%zu oracle_error=%.3g\n",step,removals[step].size(),oracle.ids.size(),worst);std::fflush(stdout);
            previousForest=currentForest;previousLabels=oracle.labels;
        }
        for(unsigned k=0;k<2;++k){check(cudaGraphExecDestroy(runs[k]));check(cudaGraphDestroy(graphs[k]));}
        std::printf("GPU incremental motion: %u nodes, %u bonds, %zu removal steps, %u reused builds; every kept and rebuilt component matches a full build\n",n,m,removals.size()-1,keptSteps);
    }
    check(cudaStreamDestroy(stream));
}
}
