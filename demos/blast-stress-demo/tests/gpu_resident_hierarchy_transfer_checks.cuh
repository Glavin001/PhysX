// Independent compact P/P^T oracle. The CPU arithmetic is test-only.
void verifyCompactTransfers(const Fixture& original,PackedLevel& level,cudaStream_t stream){
    const auto input=level.parentInput();const auto b=level.buffers();const auto parent=level.parentBuffers();
    const unsigned n=input.counts?download(input.counts,2,stream)[0]:input.nodes;
    const unsigned m=download(b.counts,2,stream)[0];
    if(!n)return;
    const auto roots=download(parent.leader,n,stream),source=download(b.nodeSource,m,stream);
    std::vector<unsigned> identity(n),map(n,Invalid);
    if(input.identity)identity=download(input.identity,n,stream);else std::iota(identity.begin(),identity.end(),0);
    for(unsigned i=0;i<m;++i){require(source[i]<n && roots[source[i]]==source[i],"packed source is not its parent root");map[source[i]]=i;}
    const auto published=download(b.nodeMap,n,stream);
    for(unsigned i=0;i<m;++i)require(published[source[i]]==i,"packed forward/reverse maps disagree");
    Device<Vector> fine(n),coarse(m),restricted(m),prolonged(n);
    std::vector<Vector> x(m),y(n);
    for(unsigned i=0;i<m;++i){Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((i*11+k*7)%23)-11)/8.;x[i]=unpack(v);}
    for(unsigned i=0;i<n;++i){Six v{};for(unsigned k=0;k<6;++k)v[k]=(int((i*5+k*13)%31)-15)/16.;y[i]=unpack(v);}
    fine.put(y,stream);coarse.put(x,stream);
    cudaGraph_t captured=nullptr;cudaGraphExec_t executable=nullptr;
    check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
    // Launch dimensions use capacity even when no coarse rows remain. Device
    // counts choose the work, as they must inside the production graph.
    restrictPacked<<<(input.nodes+7)/8,256,0,stream>>>(input,parent,b,level.status(),fine.data,restricted.data);
    prolongPacked<<<(input.nodes+255)/256,256,0,stream>>>(input,parent,b,level.status(),coarse.data,prolonged.data);
    check(cudaGetLastError());check(cudaStreamEndCapture(stream,&captured));check(cudaGraphInstantiate(&executable,captured,0));
    auto verify=[&](){
        std::vector<Six> expectedP(n),expectedR(m);
        for(unsigned i=0;i<n;++i){
            if(roots[i]==Invalid || map[roots[i]]==Invalid)continue;
            const unsigned c=map[roots[i]];const auto a=pack(x[c]),v=pack(y[i]);
            const auto p=original.positions[identity[i]],q=original.positions[identity[roots[i]]];
            const Three offset={double(p.x)-q.x,double(p.y)-q.y,double(p.z)-q.z};
            const auto d=input.levelBonds?make_float2(1,1):original.inverse[i];
            const auto spin=cross(offset,{a[0],a[1],a[2]});
            const auto moment=cross(offset,{v[3]/d.y,v[4]/d.y,v[5]/d.y});
            for(unsigned k=0;k<3;++k){
                expectedP[i][k]=a[k]/d.x;expectedP[i][k+3]=(a[k+3]+spin[k])/d.y;
                expectedR[c][k]+=v[k]/d.x-moment[k];expectedR[c][k+3]+=v[k+3]/d.y;
            }
        }
        check(cudaGraphLaunch(executable,stream));const auto p=prolonged.get(stream),r=restricted.get(stream);
        compare(p,expectedP,"compact prolongation differs from independent rigid basis");
        compare(r,expectedR,"compact restriction differs from independent transpose");
        double left=0,right=0,scale=1;
        for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k){const double v=pack(p[i])[k]*pack(y[i])[k];left+=v;scale+=std::abs(v);}
        for(unsigned i=0;i<m;++i)for(unsigned k=0;k<6;++k){const double v=pack(r[i])[k]*pack(x[i])[k];right+=v;scale+=std::abs(v);}
        require(std::abs(left-right)<2e-12*scale,"compact transfers are not adjoints");
        return std::make_pair(p,r);
    };
    const auto first=verify(),second=verify();
    require(!std::memcmp(first.first.data(),second.first.data(),n*sizeof(Vector)),"compact prolongation is not byte-repeatable");
    if(m)require(!std::memcmp(first.second.data(),second.second.data(),m*sizeof(Vector)),"compact restriction is not byte-repeatable");
    if(n<=24){
        for(unsigned i=0;i<m;++i)for(unsigned k=0;k<6;++k){std::fill(x.begin(),x.end(),Vector{});Six v{};v[k]=1;x[i]=unpack(v);coarse.put(x,stream);verify();}
        for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k){std::fill(y.begin(),y.end(),Vector{});Six v{};v[k]=1;y[i]=unpack(v);fine.put(y,stream);verify();}
    }
    check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(captured));
}
