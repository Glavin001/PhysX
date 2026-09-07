// Independent dense oracle for small-component GPU preconditioning only.
// Production never assembles these matrices or makes component decisions on CPU.
void verifyTerminals(const Fixture& f,Input input,const Status* source,cudaStream_t stream){
    const unsigned n=input.counts?download(input.counts,2,stream)[0]:input.nodes;
    const auto sourceState=download(source,1,stream)[0];
    Device<unsigned> accept(1);Device<std::uint64_t> generation(1);accept.put({1},stream);generation.put({sourceState.generation},stream);
    input.accept=accept.data;input.generation=generation.data;
    TerminalPool pool(input.authoredNodes?input.authoredNodes:input.nodes,stream);TerminalLevel terminal(input,source,pool,0,stream);cudaGraph_t graph=nullptr;cudaGraphExec_t executable=nullptr;
    check(cudaGraphCreate(&graph,0));terminal.append(graph,nullptr);check(cudaGraphInstantiate(&executable,graph,0));
    check(cudaGraphLaunch(executable,stream));const auto state=download(terminal.status(),1,stream)[0];
    require(state.initialized && !state.error && state.generation==download(source,1,stream)[0].generation,"terminal factors did not commit");
    check(cudaGraphLaunch(executable,stream));const auto unchanged=download(terminal.status(),1,stream)[0];
    require(!std::memcmp(&state,&unchanged,sizeof(state)),"unchanged terminal generation rebuilt");
    accept.put({0},stream);generation.put({sourceState.generation+1},stream);check(cudaGraphLaunch(executable,stream));
    const auto rejected=download(terminal.status(),1,stream)[0];require(!std::memcmp(&state,&rejected,sizeof(state)),"rejected terminal transaction changed committed status");
    accept.put({1},stream);check(cudaGraphLaunch(executable,stream));
    const auto stale=download(terminal.status(),1,stream)[0];require(stale.error==32 && stale.generation==state.generation,"terminal factors accepted stale source generation");
    generation.put({sourceState.generation},stream);check(cudaGraphLaunch(executable,stream));
    const auto recovered=download(terminal.status(),1,stream)[0];require(!recovered.error && recovered.generation==state.generation && recovered.builds==state.builds+1,"terminal generation failure did not recover");
    check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
    if(!n)return;
    if(n>257){
        // Exercise grid-stride application when many disconnected rows remain.
        // Detailed independent dense residual checks follow for smaller levels.
        Device<Vector> rhs(n),result(n);const Vector marker=unpack({123,123,123,123,123,123});
        rhs.put(std::vector<Vector>(n,unpack({1,2,3,4,5,6})),stream);result.put(std::vector<Vector>(n,marker),stream);
        check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));terminal.apply(rhs.data,result.data);
        check(cudaStreamEndCapture(stream,&graph));check(cudaGraphInstantiate(&executable,graph,0));
        check(cudaGraphLaunch(executable,stream));const auto applied=result.get(stream);
        check(cudaGraphLaunch(executable,stream));const auto repeated=result.get(stream);
        require(!std::memcmp(applied.data(),repeated.data(),n*sizeof(Vector)),"large terminal application is not byte-repeatable");
        const auto components=download(input.component,n,stream);
        const auto kinds=download(terminal.buffers().kind,input.authoredNodes?input.authoredNodes:input.nodes,stream);
        for(unsigned i=0;i<n;++i){const unsigned kind=components[i]==Invalid?0:kinds[components[i]];
            for(double x:pack(applied[i]))require(std::isfinite(x),"large terminal batch produced nonfinite output");
            if(!kind)require(!std::memcmp(&applied[i],&marker,sizeof(Vector)),"large terminal batch overwrote nonterminal output");
            else if(kind==1)for(double x:pack(applied[i]))require(x==0,"large uncoupled terminal batch is not zero");
        }
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));return;
    }
    const auto b=terminal.buffers();const unsigned capacity=input.authoredNodes?input.authoredNodes:input.nodes;
    const auto kind=download(b.kind,capacity,stream);const auto storage=download(b.storage,size_t(capacity)*TerminalNodeSlots,stream);
    const auto lift=download(b.lift,size_t(capacity)*6,stream);
    const unsigned partCount=download(input.partition.count,1,stream)[0];
    const auto ids=download(input.partition.ids,partCount,stream),begin=download(input.partition.begin,capacity,stream),end=download(input.partition.end,capacity,stream);
    const unsigned active=download(input.partition.nodeCount,1,stream)[0];std::vector<unsigned> order(active),origins(n);
    if(input.partition.nodes)order=download(input.partition.nodes,active,stream);else std::iota(order.begin(),order.end(),0);
    if(input.identity)origins=download(input.identity,n,stream);else std::iota(origins.begin(),origins.end(),0);
    std::vector<float2> inertia(n,make_float2(1,1));if(!input.levelBonds)inertia=f.inverse;
    const auto csr=download(input.begin,n+1,stream),refs=download(input.refs,csr.back(),stream);
    const unsigned bondCount=input.counts?download(input.counts,2,stream)[1]:input.bonds;
    std::vector<CoarseBond> bonds(bondCount);
    if(input.levelBonds)bonds=download(input.levelBonds,bondCount,stream);
    else for(unsigned i=0;i<bondCount;++i){const auto a=f.offset0[i],c=f.offset1[i];bonds[i]={f.a[i],f.b[i],{a.x,a.y,a.z},{c.x,c.y,c.z},f.health[i]>0?double(f.scale[i]):0};}
    std::vector<Vector> rhs(n),other(n);for(unsigned i=0;i<n;++i){Six x{},y{};for(unsigned k=0;k<6;++k){x[k]=(int((i*7+k*3)%19)-9)/8.;y[k]=(int((i*3+k*11)%29)-14)/16.;}rhs[i]=unpack(x);other[i]=unpack(y);}
    Device<Vector> deviceRhs(n),result(n);deviceRhs.put(rhs,stream);
    std::vector<Vector> sentinel(n,unpack({123,123,123,123,123,123}));result.put(sentinel,stream);
    check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));terminal.apply(deviceRhs.data,result.data);
    check(cudaStreamEndCapture(stream,&graph));check(cudaGraphInstantiate(&executable,graph,0));
    check(cudaGraphLaunch(executable,stream));const auto solution=result.get(stream);
    check(cudaGraphLaunch(executable,stream));const auto repeat=result.get(stream);
    require(!std::memcmp(solution.data(),repeat.data(),n*sizeof(Vector)),"terminal solve is not byte-repeatable");
    deviceRhs.put(other,stream);check(cudaGraphLaunch(executable,stream));const auto second=result.get(stream);
    std::vector<unsigned> handled(n);
    for(const auto id:ids){
        const unsigned count=end[id]-begin[id],dofs=count*6;
        if(count>TerminalNodes){require(kind[id]==0,"large component was silently truncated into a terminal solve");continue;}
        std::vector<unsigned> nodes(count),edges;
        for(unsigned i=0;i<count;++i){nodes[i]=order[begin[id]+i];handled[nodes[i]]=1;
            for(unsigned j=csr[nodes[i]];j<csr[nodes[i]+1];++j)if(refs[j]!=Invalid)edges.push_back(refs[j]&0x7fffffffu);}
        std::sort(edges.begin(),edges.end());edges.erase(std::unique(edges.begin(),edges.end()),edges.end());
        std::vector<long double> matrix(dofs*dofs);bool coherent=true;
        for(unsigned e:edges){const auto edge=bonds[e];if(edge.scale<=0)continue;
            if(edge.a!=Invalid && edge.b!=Invalid){const auto p=f.positions[origins[edge.a]],q=f.positions[origins[edge.b]];
                coherent=coherent && double(p.x)+edge.offset0.x==double(q.x)+edge.offset1.x && double(p.y)+edge.offset0.y==double(q.y)+edge.offset1.y && double(p.z)+edge.offset0.z==double(q.z)+edge.offset1.z;}
            std::vector<Six> columns(dofs);
            for(unsigned i=0;i<dofs;++i){Six unit{};unit[i%6]=1;const unsigned node=nodes[i/6];
                if(edge.a==node){const auto value=factor(unit,inertia[node],{edge.offset0.x,edge.offset0.y,edge.offset0.z});for(unsigned k=0;k<6;++k)columns[i][k]+=edge.scale*value[k];}
                if(edge.b==node){const auto value=factor(unit,inertia[node],{edge.offset1.x,edge.offset1.y,edge.offset1.z});for(unsigned k=0;k<6;++k)columns[i][k]-=edge.scale*value[k];}
            }
            for(unsigned i=0;i<dofs;++i)for(unsigned j=0;j<dofs;++j)for(unsigned k=0;k<6;++k)matrix[i*dofs+j]+=static_cast<long double>(columns[i][k])*columns[j][k];
        }
        bool zero=true;for(const auto x:matrix)zero=zero && x==0;
        require(kind[id]==(zero?1u:2u),"terminal zero/factor classification incorrect");
        auto factorAt=[&](unsigned row,unsigned col){const unsigned slot=row*(row+1)/2+col,node=nodes[slot/TerminalFactorSlots];return storage[size_t(origins[node])*TerminalNodeSlots+slot%TerminalFactorSlots];};
        auto scaleAt=[&](unsigned i){return storage[size_t(origins[nodes[i/6]])*TerminalNodeSlots+TerminalFactorSlots+i%6];};
        if(!zero)for(unsigned i=0;i<dofs;++i)for(unsigned j=0;j<=i;++j){
            long double reconstructed=0;for(unsigned k=0;k<=j;++k)reconstructed+=static_cast<long double>(factorAt(i,k))*factorAt(j,k);
            reconstructed/=static_cast<long double>(scaleAt(i))*scaleAt(j);
            const long double expected=matrix[i*dofs+j]+(i==j && i<6?lift[size_t(id)*6+i]:0);
            require(std::isfinite(double(reconstructed)) && std::abs(reconstructed-expected)<2e-12L*std::max(1.L,std::abs(expected)),"terminal factors differ from independent B B^T plus numerical lift");
        }
        double left=0,right=0,energy=0,adjointScale=1;
        for(unsigned i=0;i<dofs;++i){
            const double x=pack(solution[nodes[i/6]])[i%6],y=pack(second[nodes[i/6]])[i%6];
            const double r=pack(rhs[nodes[i/6]])[i%6],s=pack(other[nodes[i/6]])[i%6];
            require(std::isfinite(x) && std::isfinite(y),"terminal solve is nonfinite");
            if(zero){require(x==0 && y==0,"zero operator was replaced with an identity solve");continue;}
            long double applied=0,scale=std::max(1.,std::abs(r));
            for(unsigned j=0;j<dofs;++j){const long double coefficient=matrix[i*dofs+j]+(i==j && i<6?lift[size_t(id)*6+i]:0);
                const auto term=coefficient*pack(solution[nodes[j/6]])[j%6];applied+=term;scale+=std::abs(term);}
            require(std::abs(applied-r)<2e-12L*scale,"terminal solve residual exceeds authoritative tolerance");
            left+=r*y;right+=s*x;energy+=r*x;adjointScale+=std::abs(r*y)+std::abs(s*x);
        }
        require(std::abs(left-right)<2e-12*adjointScale && energy>=-2e-12*adjointScale,"terminal preconditioner is not symmetric positive");
        if(!zero && coherent){
            // Compatible RHS: check that the gauge choice preserves original
            // physical equations, including the supported case with no lift.
            std::vector<Vector> compatible(n);for(unsigned i=0;i<dofs;++i){Six v=pack(compatible[nodes[i/6]]);long double value=0;
                for(unsigned j=0;j<dofs;++j)value+=matrix[i*dofs+j]*pack(other[nodes[j/6]])[j%6];v[i%6]=double(value);compatible[nodes[i/6]]=unpack(v);}
            deviceRhs.put(compatible,stream);check(cudaGraphLaunch(executable,stream));const auto solved=result.get(stream);
            for(unsigned i=0;i<dofs;++i){long double applied=0,scale=1;const double wanted=pack(compatible[nodes[i/6]])[i%6];
                for(unsigned j=0;j<dofs;++j){const auto term=matrix[i*dofs+j]*pack(solved[nodes[j/6]])[j%6];applied+=term;scale+=std::abs(term);}
                require(std::abs(applied-wanted)<2e-12L*scale,"numerical anchor changed compatible physical equations");}
        }
    }
    for(unsigned node=0;node<n;++node)if(!handled[node])require(!std::memcmp(&solution[node],&sentinel[node],sizeof(Vector)),"terminal solver overwrote nonterminal/static output");
    check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
}

void verifyTerminalFactorFailure(const Fixture& f,Input input,const Status* source,cudaStream_t stream){
    if(input.levelBonds || input.nodes!=2 || input.bonds!=1 || f.health[0]<=0)return;
    Device<float4> offset(1),secondOffset(1);auto bad=f.offset0;bad[0]=make_float4(1e20f,0,0,0);offset.put(bad,stream);secondOffset.put(bad,stream);input.offset0=offset.data;input.offset1=secondOffset.data;
    TerminalPool pool(input.authoredNodes?input.authoredNodes:input.nodes,stream);TerminalLevel terminal(input,source,pool,0,stream);cudaGraph_t graph=nullptr;cudaGraphExec_t executable=nullptr;
    check(cudaGraphCreate(&graph,0));terminal.append(graph,nullptr);check(cudaGraphInstantiate(&executable,graph,0));
    check(cudaGraphLaunch(executable,stream));auto state=download(terminal.status(),1,stream)[0];
    require(state.error==128 && !state.initialized,"unfactorable terminal system was accepted");
    offset.put(f.offset0,stream);secondOffset.put(f.offset1,stream);check(cudaGraphLaunch(executable,stream));state=download(terminal.status(),1,stream)[0];
    require(!state.error && state.initialized,"terminal factorization failure did not recover");
    check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
}
