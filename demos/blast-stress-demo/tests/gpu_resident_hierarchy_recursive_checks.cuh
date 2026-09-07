// Independent compaction/ancestry/CSR and recursive Galerkin qualification.
struct RecursiveChain {
    bool havePrevious=false;std::uint64_t previousGeneration=0;std::vector<Status> previousStates;
    std::vector<std::unique_ptr<PackedLevel>> packed;
    std::vector<std::unique_ptr<Graph>> graphs;
    std::vector<Input> inputs;
    cudaGraphNode_t append(cudaGraph_t graph,cudaGraphNode_t prior,Input source,Graph& parent,cudaStream_t stream,unsigned levels){
        Graph* current=&parent;
        for(unsigned i=0;i<levels;++i){
            packed.emplace_back(new PackedLevel(source,*current,stream));prior=packed.back()->append(graph,prior);
            source=packed.back()->view();inputs.push_back(source);
            graphs.emplace_back(new Graph(source.nodes,source.bonds,stream,true));current=graphs.back().get();
            prior=current->append(graph,prior,source);
        }
        return prior;
    }
};
template<class T>std::vector<T> download(const T* pointer,size_t count,cudaStream_t stream){
    std::vector<T> result(count);if(count)check(cudaMemcpyAsync(result.data(),pointer,count*sizeof(T),cudaMemcpyDeviceToHost,stream));
    check(cudaStreamSynchronize(stream));return result;
}
#include "gpu_resident_hierarchy_transfer_checks.cuh"
bool nonzeroColumn(const CoarseBond& e){
    return e.scale>0 && (e.a!=Invalid || e.b!=Invalid) && !(e.a==e.b && e.offset0.x==e.offset1.x && e.offset0.y==e.offset1.y && e.offset0.z==e.offset1.z);
}
void sameBond(const CoarseBond& actual,const CoarseBond& expected){
    require(actual.a==expected.a && actual.b==expected.b && actual.scale==expected.scale &&
        actual.offset0.x==expected.offset0.x && actual.offset0.y==expected.offset0.y && actual.offset0.z==expected.offset0.z &&
        actual.offset1.x==expected.offset1.x && actual.offset1.y==expected.offset1.y && actual.offset1.z==expected.offset1.z,"packing changed a coarse coefficient");
}
void verifyRecursive(const Fixture& f,RecursiveChain& chain,std::vector<unsigned> leaders,std::vector<CoarseBond> coarse,
                     std::uint64_t generation,cudaStream_t stream){
    const bool unchanged=chain.havePrevious && chain.previousGeneration==generation;
    std::vector<Status> observed;
    const unsigned original=unsigned(f.positions.size());std::vector<unsigned> identity(original),components=f.component,bondIdentity(f.a.size()),cumulative=leaders;
    std::iota(identity.begin(),identity.end(),0);std::iota(bondIdentity.begin(),bondIdentity.end(),0);
    for(unsigned level=0;level<chain.graphs.size();++level){
        auto& packed=*chain.packed[level];auto& graph=*chain.graphs[level];const auto input=chain.inputs[level];const auto b=packed.buffers();
        const auto counts=download(b.counts,2,stream);const unsigned n=counts[0],m=counts[1];
        const auto ps=download(packed.status(),1,stream)[0],gs=download(graph.status(),1,stream)[0];
        if(unchanged){require(ps.builds==chain.previousStates[2*level].builds && gs.builds==chain.previousStates[2*level+1].builds,"unchanged recursive generation rebuilt");}
        observed.push_back(ps);observed.push_back(gs);
        require(ps.initialized && gs.initialized && !ps.error && !gs.error && ps.generation==generation && gs.generation==generation,"recursive level did not commit");
        std::vector<unsigned> roots,map(leaders.size(),Invalid),active(leaders.size());
        for(const auto e:coarse)if(nonzeroColumn(e)){if(e.a!=Invalid)active[e.a]=1;if(e.b!=Invalid)active[e.b]=1;}
        for(unsigned i=0;i<leaders.size();++i)if(leaders[i]==i && active[i]){map[i]=unsigned(roots.size());roots.push_back(i);}
        require(n==roots.size(),"packed node count differs from canonical roots");
        const auto ids=download(b.identity,n,stream),parts=download(b.component,n,stream),origins=download(b.bondIdentity,m,stream);
        for(unsigned i=0;i<n;++i)require(ids[i]==identity[roots[i]] && parts[i]==components[roots[i]],"packed identity/component changed");
        const auto bonds=download(b.bonds,m,stream);unsigned next=0;
        for(unsigned i=0;i<coarse.size();++i)if(nonzeroColumn(coarse[i])){
            require(next<m,"packed bond capacity truncated");auto expected=coarse[i];
            if(expected.a!=Invalid)expected.a=map[expected.a];if(expected.b!=Invalid)expected.b=map[expected.b];
            sameBond(bonds[next],expected);require(origins[next]==bondIdentity[i],"bond creation ancestry lost");++next;
        }
        require(next==m,"packed bond count contains extra work");
        const auto begin=download(b.begin,n+1,stream);require(begin[0]==0 && begin.back()<=2*m,"invalid packed CSR extent");
        const auto refs=download(b.refs,begin.back(),stream);std::vector<std::vector<unsigned>> expected(n);
        for(unsigned i=0;i<m;++i){if(bonds[i].a!=Invalid)expected[bonds[i].a].push_back(i);if(bonds[i].b!=Invalid)expected[bonds[i].b].push_back(i|0x80000000u);}
        for(unsigned i=0;i<n;++i){require(begin[i]<=begin[i+1] && begin[i+1]-begin[i]==expected[i].size(),"packed CSR degree incorrect");
            for(unsigned j=0;j<expected[i].size();++j)require(refs[begin[i]+j]==expected[i][j],"packed CSR is not canonical");}
        verifyCompactTransfers(f,packed,stream);
        leaders=download(graph.leaders(),n,stream);coarse=download(graph.coarseBonds(),m,stream);
        std::vector<unsigned> oldOriginToNew(original,Invalid);
        for(unsigned i=0;i<n;++i)oldOriginToNew[ids[i]]=i;
        auto sourceCumulative=cumulative;
        for(unsigned node=0;node<original;++node)if(cumulative[node]!=Invalid){
            const unsigned compact=oldOriginToNew[cumulative[node]];
            if(compact==Invalid){sourceCumulative[node]=cumulative[node]=Invalid;continue;}
            require(leaders[compact]<=compact && leaders[compact]<n && leaders[leaders[compact]]==leaders[compact],"recursive owner is not a canonical root");
            cumulative[node]=ids[leaders[compact]];
        }
        // Expand only in this oracle, never in the GPU implementation. The
        // composed rigid basis must match the original fine B^T P directly.
        std::vector<CoarseBond> expanded(f.a.size());for(auto& e:expanded)e.a=e.b=Invalid;
        for(unsigned i=0;i<m;++i){auto e=coarse[i];if(e.a!=Invalid)e.a=ids[e.a];if(e.b!=Invalid)e.b=ids[e.b];expanded[origins[i]]=e;}
        if(original<=24)verifyFactor(f,cumulative,expanded);
        std::vector<Vector> x(original);for(unsigned i=0;i<original;++i){Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((i*7+k*3)%19)-9)/8.;x[i]=unpack(v);}
        const auto fine=hostProlong(f,cumulative,x);
        for(unsigned i=0;i<f.a.size();++i){
            const auto r=f.offset0[i],s=f.offset1[i];auto u=factor(fine[f.a[i]],f.inverse[f.a[i]],{r.x,r.y,r.z});
            auto v=factor(fine[f.b[i]],f.inverse[f.b[i]],{s.x,s.y,s.z});const auto e=expanded[i];Six a{},c{};
            if(e.a!=Invalid)a=pack(x[e.a]);if(e.b!=Invalid)c=pack(x[e.b]);
            a=factor(a,make_float2(1,1),{e.offset0.x,e.offset0.y,e.offset0.z});c=factor(c,make_float2(1,1),{e.offset1.x,e.offset1.y,e.offset1.z});
            for(unsigned k=0;k<6;++k){const double wanted=f.health[i]>0?f.scale[i]*(u[k]-v[k]):0,actual=e.scale*(a[k]-c[k]);
                require(std::isfinite(actual) && std::abs(actual-wanted)<2e-12*std::max(1.,std::abs(wanted)),"recursive factor differs from original fine basis");}
        }
        if(n){
            Device<Vector> values(n),result(n);std::vector<Vector> compactX(n);
            for(unsigned i=0;i<n;++i)compactX[i]=x[ids[i]];values.put(compactX,stream);
            applyCoarse<<<(n+7)/8,256,0,stream>>>(input,graph.buffers(),graph.status(),values.data,result.data);check(cudaGetLastError());
            const auto expectedResult=hostRestrict(f,cumulative,hostFineOperator(f,fine));std::vector<Six> compactExpected(n);
            for(unsigned i=0;i<n;++i)if(leaders[i]==i)compactExpected[i]=expectedResult[ids[i]];
            compare(result.get(stream),compactExpected,"recursive sparse application differs from original fine Galerkin operator");
            applyLevel<<<(n+7)/8,256,0,stream>>>(input,graph.status(),values.data,result.data);check(cudaGetLastError());
            const auto currentExpected=hostRestrict(f,sourceCumulative,hostFineOperator(f,hostProlong(f,sourceCumulative,x)));
            for(unsigned i=0;i<n;++i)compactExpected[i]=currentExpected[ids[i]];
            compare(result.get(stream),compactExpected,"compact current-level operator differs from original equations");
        }
        identity=ids;components=parts;bondIdentity=origins;
        std::printf("recursive GPU level=%u source nodes=%u bonds=%zu packed nodes=%u bonds=%u aggregates=%u passed\n",level+1,original,f.a.size(),n,m,gs.aggregates);
    }
    chain.previousStates=observed;chain.previousGeneration=generation;chain.havePrevious=true;
}

std::vector<Status> recursiveState(const RecursiveChain& chain,cudaStream_t stream){
    std::vector<Status> result;
    for(unsigned i=0;i<chain.graphs.size();++i){result.push_back(download(chain.packed[i]->status(),1,stream)[0]);result.push_back(download(chain.graphs[i]->status(),1,stream)[0]);}
    return result;
}
void verifyRecursiveFailures(RecursiveChain& chain,cudaStream_t stream){
    if(chain.graphs.empty())return;
    const auto input=chain.inputs[0];const auto buffers=chain.packed[0]->buffers();
    const auto originalCounts=download(buffers.counts,2,stream);
    const auto parent=download(input.sourceStatus,1,stream)[0];require(!parent.error && parent.initialized,"failure test requires accepted source");
    Graph probe(input.nodes,input.bonds,stream,true);probe.enqueue(input);
    auto state=download(probe.status(),1,stream)[0];require(!state.error && state.generation==parent.generation,"probe did not initialize");
    unsigned badCounts[2]={input.nodes+1,originalCounts[1]};
    check(cudaMemcpyAsync(buffers.counts,badCounts,sizeof(badCounts),cudaMemcpyHostToDevice,stream));probe.enqueue(input);
    state=download(probe.status(),1,stream)[0];require(state.error==32 && state.generation==parent.generation,"recursive capacity overflow was not rejected");
    check(cudaMemcpyAsync(buffers.counts,originalCounts.data(),sizeof(badCounts),cudaMemcpyHostToDevice,stream));probe.enqueue(input);
    state=download(probe.status(),1,stream)[0];require(!state.error,"recursive capacity recovery failed");
    Device<std::uint64_t> newer(1);newer.put({parent.generation+1},stream);Input stale=input;stale.generation=newer.data;probe.enqueue(stale);
    state=download(probe.status(),1,stream)[0];require(state.error==32 && state.generation==parent.generation,"stale source generation was accepted");
    probe.enqueue(input);state=download(probe.status(),1,stream)[0];require(!state.error,"recursive generation recovery failed");
    if(originalCounts[0]){
        const unsigned identity=download(buffers.identity,1,stream)[0],bad=input.authoredNodes;
        check(cudaMemcpyAsync(buffers.identity,&bad,sizeof(bad),cudaMemcpyHostToDevice,stream));
        Graph invalidIdentity(input.nodes,input.bonds,stream,true);invalidIdentity.enqueue(input);
        state=download(invalidIdentity.status(),1,stream)[0];require(state.error==1 && !state.initialized,"invalid recursive origin accepted");
        check(cudaMemcpyAsync(buffers.identity,&identity,sizeof(identity),cudaMemcpyHostToDevice,stream));invalidIdentity.enqueue(input);
        state=download(invalidIdentity.status(),1,stream)[0];require(!state.error && state.generation==parent.generation,"recursive origin recovery failed");
    }
}
