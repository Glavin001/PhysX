// Independent host-side P, P^T and P^T L P oracle for the private GPU operators.
#include "gpu_resident_diagonal_reference.cuh"
// Test only: all production transfers and matrix applications stay on device.
Six pack(Vector a){return {a.angular.x,a.angular.y,a.angular.z,a.linear.x,a.linear.y,a.linear.z};}
Vector unpack(Six a){return {{a[0],a[1],a[2]},{a[3],a[4],a[5]}};}
std::vector<Six> hostProlong(const Fixture& f,const std::vector<unsigned>& roots,const std::vector<Vector>& x){
    std::vector<Six> result(roots.size());
    for(unsigned i=0;i<roots.size();++i)if(roots[i]!=Invalid){
        const auto v=pack(x[roots[i]]);const auto p=f.positions[i],q=f.positions[roots[i]];
        const auto r=cross({double(p.x)-q.x,double(p.y)-q.y,double(p.z)-q.z},{v[0],v[1],v[2]});
        for(unsigned k=0;k<3;++k){result[i][k]=v[k]/f.inverse[i].x;result[i][k+3]=(v[k+3]+r[k])/f.inverse[i].y;}
    }
    return result;
}
std::vector<Six> hostRestrict(const Fixture& f,const std::vector<unsigned>& roots,const std::vector<Six>& x){
    std::vector<Six> result(roots.size());
    for(unsigned i=0;i<roots.size();++i)if(roots[i]!=Invalid){
        const auto p=f.positions[i],q=f.positions[roots[i]];
        Three linear{};for(unsigned k=0;k<3;++k)linear[k]=x[i][k+3]/f.inverse[i].y;
        const auto r=cross({double(p.x)-q.x,double(p.y)-q.y,double(p.z)-q.z},linear);
        for(unsigned k=0;k<3;++k){result[roots[i]][k]+=x[i][k]/f.inverse[i].x-r[k];result[roots[i]][k+3]+=linear[k];}
    }
    return result;
}
std::vector<Six> hostFineOperator(const Fixture& f,const std::vector<Six>& x){
    std::vector<Six> result(x.size());
    for(unsigned e=0;e<f.a.size();++e)if(f.health[e]>0){
        const unsigned nodes[2]={f.a[e],f.b[e]};const auto u=f.offset0[e],v=f.offset1[e];
        const Three offsets[2]={{u.x,u.y,u.z},{v.x,v.y,v.z}};
        const auto first=factor(x[nodes[0]],f.inverse[nodes[0]],offsets[0]);
        const auto second=factor(x[nodes[1]],f.inverse[nodes[1]],offsets[1]);
        Six flux{};for(unsigned k=0;k<6;++k)flux[k]=(first[k]-second[k])*double(f.scale[e])*f.scale[e];
        for(unsigned side=0;side<2;++side){
            const auto moment=cross(offsets[side],{flux[3],flux[4],flux[5]});
            const double sign=side?-1.:1.;const auto d=f.inverse[nodes[side]];
            for(unsigned k=0;k<3;++k){result[nodes[side]][k]+=sign*d.x*(flux[k]-moment[k]);result[nodes[side]][k+3]+=sign*d.y*flux[k+3];}
        }
    }
    return result;
}
#include "gpu_resident_hierarchy_diagonal_checks.cuh"
double compare(const std::vector<Vector>& actual,const std::vector<Six>& expected,const char* message){
    double worst=0;
    for(unsigned i=0;i<actual.size();++i){const auto a=pack(actual[i]);for(unsigned k=0;k<6;++k){
        const double error=std::abs(a[k]-expected[i][k])/std::max(1.,std::abs(expected[i][k]));
        require(std::isfinite(a[k]) && error<2e-12,message);worst=std::max(worst,error);
    }}
    return worst;
}
void verifyOperators(const Fixture& f,const std::vector<unsigned>& roots,Graph& graph,Input input,cudaStream_t stream){
    const unsigned n=unsigned(roots.size());if(!n)return;
    Device<Vector> coarse(n),fine(n),prolonged(n),restricted(n),applied(n),diagonal(n),current(n),referenceDiagonal(n),threadDiagonal(n);
    std::vector<Vector> x(n),y(n);
    for(unsigned i=0;i<n;++i){
        Six a{},b{};for(unsigned k=0;k<6;++k){a[k]=(int((i*11+k*7)%23)-11)/8.;b[k]=(int((i*5+k*13)%31)-15)/16.;}
        x[i]=unpack(a);y[i]=unpack(b);
    }
    coarse.put(x,stream);fine.put(y,stream);verifySmoothingBound(f,y);
    // Capture actual transfers/operator, not just construction; every call
    // uses borrowed resident buffers and requires no temporary allocation.
    cudaGraph_t captured=nullptr;cudaGraphExec_t executable=nullptr;
    check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));
    const auto buffers=graph.buffers();
    prolongate<<<(n+255)/256,256,0,stream>>>(input,buffers,graph.status(),coarse.data,prolonged.data);
    restrictResidual<<<(n+7)/8,256,0,stream>>>(input,buffers,graph.status(),fine.data,restricted.data);
    applyCoarse<<<(n+7)/8,256,0,stream>>>(input,buffers,graph.status(),coarse.data,applied.data);
    applyLevel<<<(n+7)/8,256,0,stream>>>(input,graph.status(),fine.data,current.data);
    applyFineDiagonal<<<(n+7)/8,256,0,stream>>>(input,buffers,graph.status(),fine.data,diagonal.data);
    applyReferenceDiagonal<<<(n+7)/8,256,0,stream>>>(input,buffers,graph.status(),fine.data,referenceDiagonal.data);
    applyThreadDiagonal<<<(n+255)/256,256,0,stream>>>(input,buffers,graph.status(),fine.data,threadDiagonal.data);
    check(cudaGetLastError());check(cudaStreamEndCapture(stream,&captured));check(cudaGraphInstantiate(&executable,captured,0));
    auto verify=[&](){
        check(cudaGraphLaunch(executable,stream));
        const auto px=prolonged.get(stream),ry=restricted.get(stream),lx=applied.get(stream);
        const auto actualDiagonal=diagonal.get(stream),oldDiagonal=referenceDiagonal.get(stream);
        require(!std::memcmp(actualDiagonal.data(),oldDiagonal.data(),n*sizeof(Vector)),"pivot-lane division changed diagonal solve bits");
        const auto perThread=threadDiagonal.get(stream);
        require(!std::memcmp(perThread.data(),oldDiagonal.data(),n*sizeof(Vector)),"per-thread solve changed diagonal solve bits");
        verifyDiagonalSolve(f,y,actualDiagonal);
        const auto expectedP=hostProlong(f,roots,x);
        std::vector<Six> fy(n);for(unsigned i=0;i<n;++i)fy[i]=pack(y[i]);
        compare(current.get(stream),hostFineOperator(f,fy),"current fine operator differs from original equations");
        const auto expectedR=hostRestrict(f,roots,fy);
        const auto expectedL=hostRestrict(f,roots,hostFineOperator(f,expectedP));
        double worst=compare(px,expectedP,"P application differs from independent rigid basis");
        worst=std::max(worst,compare(ry,expectedR,"P^T application differs from independent transpose"));
        worst=std::max(worst,compare(lx,expectedL,"coarse application differs from independent P^T L P"));
        // Adjointness and nonnegative energy protect transfer signs/null modes.
        double left=0,right=0,energy=0,scale=1;
        for(unsigned i=0;i<n;++i){const auto p=pack(px[i]),r=pack(ry[i]),l=pack(lx[i]),a=pack(x[i]),b=pack(y[i]);
            for(unsigned k=0;k<6;++k){left+=p[k]*b[k];right+=a[k]*r[k];energy+=a[k]*l[k];scale+=std::abs(p[k]*b[k])+std::abs(a[k]*r[k]);}}
        require(std::abs(left-right)<2e-12*scale,"transfers are not adjoints");
        require(energy>=-2e-12*scale,"coarse energy is negative");
        return worst;
    };
    double worst=verify();
    // Compare repeat output bytes to ensure scheduling cannot reorder sums.
    const auto previous=applied.get(stream);check(cudaGraphLaunch(executable,stream));const auto repeated=applied.get(stream);
    require(!std::memcmp(previous.data(),repeated.data(),n*sizeof(Vector)),"coarse application is not repeatable");
    // Full basis for small fixtures detects couplings hidden by a single RHS.
    if(n<=24)for(unsigned root=0;root<n;++root)if(roots[root]==root)for(unsigned k=0;k<6;++k){
        std::fill(x.begin(),x.end(),Vector{});Six basis{};basis[k]=1;x[root]=unpack(basis);coarse.put(x,stream);
        worst=std::max(worst,verify());
    }
    if(n<=24)for(unsigned node=0;node<n;++node)for(unsigned k=0;k<6;++k){
        std::fill(y.begin(),y.end(),Vector{});Six basis{};basis[k]=1;y[node]=unpack(basis);fine.put(y,stream);
        worst=std::max(worst,verify());
    }
    // A coherent free graph has six rigid null modes. Static boundaries and
    // intentionally inconsistent offsets do not satisfy this premise.
    bool free=true,coherent=true;
    for(const auto d:f.inverse)free=free && d.x>0 && d.y>0;
    for(unsigned e=0;e<f.a.size();++e)if(f.health[e]>0){
        const auto a=f.positions[f.a[e]],b=f.positions[f.b[e]],u=f.offset0[e],v=f.offset1[e];
        coherent=coherent && double(a.x)+u.x==double(b.x)+v.x && double(a.y)+u.y==double(b.y)+v.y && double(a.z)+u.z==double(b.z)+v.z;
    }
    if(free && coherent)for(unsigned k=0;k<6;++k){
        std::fill(x.begin(),x.end(),Vector{});Six mode{};mode[k]=1;
        for(unsigned root=0;root<n;++root)if(roots[root]==root){
            const auto p=f.positions[root];const auto r=cross({p.x,p.y,p.z},{mode[0],mode[1],mode[2]});Six v=mode;
            for(unsigned d=0;d<3;++d)v[d+3]+=r[d];x[root]=unpack(v);
        }
        coarse.put(x,stream);check(cudaGraphLaunch(executable,stream));
        const auto result=applied.get(stream);
        for(const auto value:result)for(const double a:pack(value))require(std::abs(a)<2e-12,"coarse operator destroyed a rigid null mode");
    }
    check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(captured));
    std::printf("resident P/PT/coarse operator: nodes=%u bonds=%zu max scaled error=%.3g passed\n",n,f.a.size(),worst);
}
