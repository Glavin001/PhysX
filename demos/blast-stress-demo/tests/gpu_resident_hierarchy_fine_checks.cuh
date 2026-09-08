// Compare the selected fine-only partition against the original producer.
// Physical component labels and fine Cholesky factors must remain identical.
void verifyFineOnlyPreparation(bool initiallySmall=false){
    Fixture f(1034);for(unsigned i=1;i<1034;++i)if(i!=9)f.edge(i-1,i);
    f.csr();f.partition();const unsigned n=f.positions.size(),m=f.a.size();
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    {
        Device<unsigned> begin(n+1),refs(2*m),a(m),b(m),component(n),accept(1),nodes(n),ids(n),starts(n),ends(n),counts(2);
        Device<float2> inertia(n);Device<float> health(m),scale(m);Device<float4> position(n),offset0(m),offset1(m);Device<std::uint64_t> generation(1);
        begin.put(f.begin,stream);refs.put(f.refs,stream);a.put(f.a,stream);b.put(f.b,stream);inertia.put(f.inverse,stream);
        scale.put(f.scale,stream);position.put(f.positions,stream);offset0.put(f.offset0,stream);offset1.put(f.offset1,stream);
        Input input{n,m,begin.data,refs.data,a.data,b.data,component.data,health.data,scale.data,position.data,offset0.data,offset1.data,inertia.data,generation.data,accept.data};
        input.partition={nodes.data,ids.data,starts.data,ends.data,counts.data,counts.data+1};
        Graph reference(n,m,stream);input.componentSolverMaxNodes=1024;
        ResidentHierarchy hierarchy(input,16,stream);cudaGraph_t graph;cudaGraphExec_t executable;
        check(cudaGraphCreate(&graph,0));hierarchy.append(graph,nullptr);check(cudaGraphInstantiate(&executable,graph,0));
        const auto original=f.health;Status previous{};std::vector<Status> previousCoarse;
        for(unsigned step=0;step<4;++step){
            f.health=original;if((step==2)!=initiallySmall)f.health[520]=0;f.partition();
            std::vector<unsigned> order(n),parts(n,Invalid),first(n),last(n);std::iota(order.begin(),order.end(),0);
            std::sort(order.begin(),order.end(),[&](unsigned x,unsigned y){return std::make_pair(f.component[x],x)<std::make_pair(f.component[y],y);});
            unsigned partCount=0;for(unsigned i=0;i<n;++i){const unsigned id=f.component[order[i]];
                if(!i || f.component[order[i-1]]!=id){parts[partCount++]=id;first[id]=i;}last[id]=i+1;}
            nodes.put(order,stream);ids.put(parts,stream);starts.put(first,stream);ends.put(last,stream);counts.put({n,partCount},stream);
            component.put(f.component,stream);health.put(f.health,stream);generation.put({step==1?0u:step},stream);accept.put({1},stream);
            Input originalInput=input;originalInput.componentSolverMaxNodes=0;reference.enqueue(originalInput);
            check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));
            const auto status=download(hierarchy.status(),1,stream)[0];require(status.initialized && !status.error,"fine-only hierarchy construction failed");
            if(step==1)require(!std::memcmp(&status,&previous,sizeof(status)),"unchanged fine-only hierarchy rebuilt");previous=status;
            const auto expected=download(reference.buffers().diagonal,n*DiagonalEntries,stream);
            const auto actual=download(hierarchy.topology(0).buffers().diagonal,n*DiagonalEntries,stream);
            require(!std::memcmp(expected.data(),actual.data(),actual.size()*sizeof(double)),"fine-only selection changed physical fine factors");
            require(component.get(stream)==f.component,"fine-only selection changed physical connectivity");
            // Only live component IDs own terminal output. Unused capacity is
            // deliberately not initialized by producers and must not be read.
            std::vector<unsigned> owners(n,Invalid),kinds(n,Invalid);
            for(unsigned i=0;i<partCount;++i){const auto id=parts[i];
                owners[id]=download(hierarchy.terminalBuffers().owner+id,1,stream)[0];
                kinds[id]=download(hierarchy.terminalBuffers().kind+id,1,stream)[0];}
            const auto leaders=download(hierarchy.topology(0).leaders(),n,stream);
            const auto coarse=download(hierarchy.topology(0).coarseBonds(),m,stream);
            unsigned selected=0;for(unsigned i=0;i<partCount;++i){const auto id=parts[i];const bool small=last[id]-first[id]<=1024;
                if(small){++selected;require(owners[id]==0 && kinds[id]==3,"fine-only component acquired an unused coarse terminal");
                    for(unsigned j=first[id];j<last[id];++j)require(leaders[order[j]]==Invalid,"fine-only component built unused aggregates");}
                else require(kinds[id]!=3,"large component lost its required multilevel solve");}
            for(unsigned e=0;e<m;++e)if(f.health[e]>0 && last[f.component[f.a[e]]]-first[f.component[f.a[e]]]<=1024)
                require(coarse[e].a==Invalid && coarse[e].b==Invalid,"fine-only bond leaked into coarse packing");
            std::vector<Status> currentCoarse;
            for(unsigned level=1;level<hierarchy.levels();++level) {
                const auto state=download(hierarchy.topology(level).status(),1,stream)[0];
                if(selected==partCount && previousCoarse.empty())
                    require(!state.initialized && !state.builds,"initial all-small partition built unused recursive storage");
                if(selected==partCount && !previousCoarse.empty())
                    require(!std::memcmp(&state,&previousCoarse[level-1],sizeof(Status)),
                        "all-small partition executed an unused recursive hierarchy build");
                if(selected!=partCount)require(state.initialized && !state.error && state.generation==status.generation,
                    "large component failed to refresh its recursive hierarchy after fine-only mode");
                currentCoarse.push_back(state);
            }
            previousCoarse=currentCoarse;
            std::printf("fine-only preparation nodes=%u bonds=%u generation=%u fine_components=%u total_components=%u exact-factors/retirement passed\n",n,m,step==1?0u:step,selected,partCount);
        }
        for(unsigned failure=0;failure<3;++failure){
            auto badRefs=f.refs,badBegin=f.begin;
            if(failure==0)badRefs[0]=m; // Out-of-range bond, before fine-factor gather.
            if(failure==1)badRefs[0]^=0x80000000u; // Incorrect endpoint incidence.
            if(failure==2)badBegin[1]=2*m+1; // Invalid CSR bound.
            refs.put(badRefs,stream);begin.put(badBegin,stream);generation.put({4+failure},stream);
            check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));
            const auto fine=download(hierarchy.topology(0).status(),1,stream)[0];
            require((fine.error&1) && fine.generation==3,"fine-only omission bypassed CSR validation");
            require(download(hierarchy.status(),1,stream)[0].error!=0,"invalid fine-only topology published a usable hierarchy");
        }
        refs.put(f.refs,stream);begin.put(f.begin,stream);generation.put({7},stream);
        check(cudaGraphLaunch(executable,stream));check(cudaStreamSynchronize(stream));
        require(!download(hierarchy.status(),1,stream)[0].error,"fine-only preparation did not recover from rejected CSR");
        std::printf("fine-only malformed bond/endpoint/CSR rejection and recovery passed\n");
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
    }
    check(cudaStreamDestroy(stream));
}
