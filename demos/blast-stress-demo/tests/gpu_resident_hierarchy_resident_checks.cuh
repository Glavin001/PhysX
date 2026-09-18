// End-to-end hierarchy ownership/retirement checks; reference kernels are
// independently equation-qualified by the existing nonretiring test target.
std::vector<Status> residentStates(const ResidentHierarchy& hierarchy,cudaStream_t stream){
    std::vector<Status> result{download(hierarchy.status(),1,stream)[0]};
    for(unsigned i=0;i<hierarchy.levels();++i){
        result.push_back(download(hierarchy.topology(i).status(),1,stream)[0]);result.push_back(download(hierarchy.terminal(i).status(),1,stream)[0]);result.push_back(download(hierarchy.smoother(i).status(),1,stream)[0]);
        if(i+1<hierarchy.levels())result.push_back(download(hierarchy.packed(i).status(),1,stream)[0]);
    }
    return result;
}
void verifyResidentHierarchy(const Fixture& f,const ResidentHierarchy& hierarchy,cudaStream_t stream){
    const unsigned original=f.positions.size();const auto owners=download(hierarchy.terminalBuffers().owner,original,stream);
    std::vector<unsigned> expectedOwner(original,Invalid),usedOrigin(original);
    for(unsigned level=0;level<hierarchy.levels();++level){
        const auto input=hierarchy.input(level);const auto counts=input.counts?download(input.counts,2,stream):std::vector<unsigned>{input.nodes,input.bonds};
        const unsigned n=counts[0],m=counts[1];
        if(original>=100000)std::printf("resident packed level=%u nodes=%u bonds=%u\n",level,n,m);
        const auto labels=download(input.component,n,stream);
        const auto partCount=download(input.partition.count,1,stream)[0];const auto ids=download(input.partition.ids,partCount,stream);
        const auto begin=download(input.partition.begin,original,stream),end=download(input.partition.end,original,stream);
        std::vector<unsigned> order(download(input.partition.nodeCount,1,stream)[0]),identity(n);
        if(input.partition.nodes)order=download(input.partition.nodes,order.size(),stream);else std::iota(order.begin(),order.end(),0);
        if(input.identity)identity=download(input.identity,n,stream);else std::iota(identity.begin(),identity.end(),0);
        for(const auto id:ids){
            require(expectedOwner[id]==Invalid,"terminal component survived into a deeper level");
            if(end[id]-begin[id]<=TerminalNodes){
                expectedOwner[id]=level;
                for(unsigned j=begin[id];j<end[id];++j){const unsigned origin=identity[order[j]];require(origin<original && !usedOrigin[origin]++,"shared terminal storage overlaps across levels/components");}
            }
        }
        require(hierarchy.terminal(level).buffers().storage==hierarchy.terminalBuffers().storage,"terminal level allocated a duplicate factor pool");
        if(n){
            // Compare shared factors AFTER every deeper level has constructed
            // against an independently owned terminal workspace at this level.
            Device<Vector> rhs(n),actual(n),expected(n);std::vector<Vector> values(n),marker(n,unpack({123,123,123,123,123,123}));
            for(unsigned i=0;i<n;++i){Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((i*7+k*11)%29)-14)/16.;values[i]=unpack(v);}
            rhs.put(values,stream);actual.put(marker,stream);expected.put(marker,stream);
            hierarchy.terminal(level).apply(rhs.data,actual.data);
            TerminalPool pool(original,stream);TerminalLevel reference(input,hierarchy.topology(level).status(),pool,level,stream);
            cudaGraph_t graph=nullptr;cudaGraphExec_t executable=nullptr;check(cudaGraphCreate(&graph,0));reference.append(graph,nullptr);check(cudaGraphInstantiate(&executable,graph,0));
            check(cudaGraphLaunch(executable,stream));reference.apply(rhs.data,expected.data);
            const auto shared=actual.get(stream),independent=expected.get(stream);
            require(!std::memcmp(shared.data(),independent.data(),n*sizeof(Vector)),"deeper levels corrupted shared terminal factors or ownership");
            check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
        }
        if(level+1<hierarchy.levels()){
            const auto parent=hierarchy.topology(level).buffers();const auto b=hierarchy.packed(level).buffers();
            const auto leaders=download(parent.leader,n,stream),active=download(parent.coarseActive,n,stream);const auto edges=download(parent.coarse,m,stream);
            const auto nextCounts=download(b.counts,2,stream);std::vector<unsigned> roots,map(n,Invalid);
            for(unsigned i=0;i<n;++i)if(leaders[i]==i && active[i] && end[labels[i]]-begin[labels[i]]>TerminalNodes)roots.push_back(i);
            std::sort(roots.begin(),roots.end(),[&](unsigned a,unsigned c){return std::make_pair(labels[a],a)<std::make_pair(labels[c],c);});
            for(unsigned i=0;i<roots.size();++i)map[roots[i]]=i;
            require(roots.size()==nextCounts[0],"retiring packing removed or retained incorrect roots");
            const auto sources=download(b.nodeSource,nextCounts[0],stream);require(sources==roots,"retiring packing changed stable root ordering");
            const auto packed=download(b.bonds,nextCounts[1],stream);unsigned next=0;
            for(auto e:edges)if(nonzeroColumn(e)){
                const unsigned root=e.a!=Invalid?e.a:e.b;if(end[labels[root]]-begin[labels[root]]<=TerminalNodes)continue;
                if(e.a!=Invalid)e.a=map[e.a];if(e.b!=Invalid)e.b=map[e.b];require(next<packed.size(),"retiring packing lost a required column");sameBond(packed[next++],e);
            }
            require(next==packed.size(),"retiring packing retained terminal columns");
            if(n){
                Device<Vector> coarse(nextCounts[0]),result(n);coarse.put(std::vector<Vector>(nextCounts[0],unpack({1,2,3,4,5,6})),stream);
                prolongPacked<<<(n+255)/256,256,0,stream>>>(input,parent,b,hierarchy.packed(level).status(),coarse.data,result.data);check(cudaGetLastError());
                const auto prolonged=result.get(stream);
                for(unsigned i=0;i<n;++i)if(labels[i]==Invalid || end[labels[i]]-begin[labels[i]]<=TerminalNodes || leaders[i]==Invalid || map[leaders[i]]==Invalid)
                    for(double x:pack(prolonged[i]))require(x==0,"retired coarse coordinates leaked into prolongation");
            }
        }
    }
    for(unsigned i=0;i<original;++i)if(f.component[i]==i)require(owners[i]==expectedOwner[i],"component terminal owner differs from earliest eligible level");
}
void runResidentHierarchy(Fixture f,bool transitions,bool cycleChecks=false,unsigned selectedStep=Invalid){
    require(selectedStep==Invalid || (cycleChecks && selectedStep<(transitions?6u:2u)),"invalid cycle transition selection");
    f.csr();f.partition();const unsigned n=f.positions.size(),m=f.a.size();cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    {
        Device<unsigned> begin(n+1),refs(2*m),a(m),b(m),component(n),accept(1),nodes(n),ids(n),starts(n),ends(n),counts(2);
        Device<float2> inertia(n);Device<float> health(m),scale(m);Device<float4> position(n),offset0(m),offset1(m);Device<std::uint64_t> generation(1);
        begin.put(f.begin,stream);refs.put(f.refs,stream);a.put(f.a,stream);b.put(f.b,stream);inertia.put(f.inverse,stream);
        scale.put(f.scale,stream);position.put(f.positions,stream);offset0.put(f.offset0,stream);offset1.put(f.offset1,stream);
        Input input{n,m,begin.data,refs.data,a.data,b.data,component.data,health.data,scale.data,position.data,offset0.data,offset1.data,inertia.data,generation.data,accept.data};
        input.partition={nodes.data,ids.data,starts.data,ends.data,counts.data,counts.data+1};
        const unsigned depth=n>257?16:7;ResidentHierarchy hierarchy(input,depth,stream);cudaGraph_t graph=nullptr;cudaGraphExec_t executable=nullptr;
        check(cudaGraphCreate(&graph,0));hierarchy.append(graph,nullptr);check(cudaGraphInstantiate(&executable,graph,0));
        std::unique_ptr<CycleQualification> cycle;if(cycleChecks)cycle.reset(new CycleQualification(hierarchy,stream));
        const auto originalHealth=f.health;std::vector<Status> previous;
        for(unsigned step=0;step<(transitions?6u:2u);++step){
            f.health=originalHealth;if(step==2 || step==3)for(unsigned e=0;e<m;++e)if(e%3==0)f.health[e]=0;
            if(step==4)std::fill(f.health.begin(),f.health.end(),0);f.partition();
            std::vector<unsigned> order(n,Invalid),parts(n,Invalid),first(n),last(n);unsigned used=0,partCount=0;
            for(unsigned i=0;i<n;++i)if(f.component[i]!=Invalid)order[used++]=i;
            std::sort(order.begin(),order.begin()+used,[&](unsigned a,unsigned b){return std::make_pair(f.component[a],a)<std::make_pair(f.component[b],b);});
            for(unsigned i=0;i<used;++i){const unsigned id=f.component[order[i]];if(!i || f.component[order[i-1]]!=id){parts[partCount++]=id;first[id]=i;}last[id]=i+1;}
            nodes.put(order,stream);ids.put(parts,stream);starts.put(first,stream);ends.put(last,stream);counts.put({used,partCount},stream);
            component.put(f.component,stream);health.put(f.health,stream);generation.put({step==1?0u:step},stream);accept.put({1},stream);
            check(cudaGraphLaunch(executable,stream));const auto state=residentStates(hierarchy,stream);
            if(state[0].error){std::fprintf(stderr,"resident pipeline error nodes=%u bonds=%u step=%u error=%u\n",n,m,step,state[0].error);for(unsigned i=0;i<depth;++i)std::fprintf(stderr,"level=%u graph=%u terminal=%u\n",i,download(hierarchy.topology(i).status(),1,stream)[0].error,download(hierarchy.terminal(i).status(),1,stream)[0].error);}
            require(state[0].initialized && !state[0].error,"assembled hierarchy did not complete");
            if(step==1)require(!std::memcmp(previous.data(),state.data(),state.size()*sizeof(Status)),"unchanged assembled hierarchy rebuilt");
            if(cycle){if(selectedStep==Invalid || step==selectedStep)cycle->verify(f,hierarchy);}
            else verifyResidentHierarchy(f,hierarchy,stream);previous=state;
        }
        accept.put({0},stream);generation.put({999},stream);check(cudaGraphLaunch(executable,stream));const auto rejected=residentStates(hierarchy,stream);
        require(!std::memcmp(previous.data(),rejected.data(),previous.size()*sizeof(Status)),"rejected command modified shared hierarchy status");
        if(cycle)cycle->verifyRejected();
        accept.put({1},stream);generation.put({transitions?5u:0u},stream);
        // An allocated hierarchy that stops before required components become
        // terminal reports incomplete work, rather than silently accepting it.
        bool needsMore=false;std::vector<unsigned> sizes(n);for(auto part:f.component)if(part!=Invalid)++sizes[part];for(auto count:sizes)needsMore=needsMore || count>TerminalNodes;
        if(needsMore){ResidentHierarchy shallow(input,1,stream);cudaGraph_t g=nullptr;cudaGraphExec_t e=nullptr;check(cudaGraphCreate(&g,0));shallow.append(g,nullptr);check(cudaGraphInstantiate(&e,g,0));check(cudaGraphLaunch(e,stream));
            const auto state=download(shallow.status(),1,stream)[0];require(state.error==256 && !state.initialized,"incomplete depth silently accepted");if(cycleChecks){CycleQualification rejected(shallow,stream);rejected.verifyRejected();}check(cudaGraphExecDestroy(e));check(cudaGraphDestroy(g));}
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
        std::printf("assembled resident hierarchy nodes=%u bonds=%u levels=%u transitions=%u passed\n",n,m,depth,transitions?6:2);
    }
    check(cudaStreamDestroy(stream));
}
