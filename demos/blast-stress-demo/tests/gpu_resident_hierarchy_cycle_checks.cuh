#include "gpu_resident_hierarchy_cycle_oracle.cuh"
class CycleQualification {
    ResidentCycle cycle;unsigned n;cudaStream_t stream;Device<Vector> rhs,once,squared,twice;
    cudaGraph_t graph=nullptr;cudaGraphExec_t executable=nullptr;
    std::pair<std::vector<Vector>,std::vector<Vector>> run(const std::vector<Vector>& value){
        rhs.put(value,stream);check(cudaGraphLaunch(executable,stream));const auto m=once.get(stream),s=squared.get(stream),t=twice.get(stream),input=rhs.get(stream);
        if(n){require(!std::memcmp(value.data(),input.data(),n*sizeof(Vector)),"cycle changed its source RHS");require(!std::memcmp(s.data(),t.data(),n*sizeof(Vector)),"resident squared cycle differs from two separate cycle applications");}
        for(auto v:m)for(auto x:pack(v))require(std::isfinite(x),"cycle produced nonfinite output");for(auto v:s)for(auto x:pack(v))require(std::isfinite(x),"squared cycle produced nonfinite output");return {m,s};
    }
public:
    CycleQualification(const ResidentHierarchy& h,cudaStream_t s):cycle(h),n(h.input(0).nodes),stream(s),rhs(n),once(n),squared(n),twice(n){
        check(cudaStreamBeginCapture(stream,cudaStreamCaptureModeThreadLocal));cycle.apply(rhs.data,once.data);cycle.applySquared(rhs.data,squared.data);cycle.apply(once.data,twice.data);
        check(cudaStreamEndCapture(stream,&graph));check(cudaGraphInstantiate(&executable,graph,0));
    }
    ~CycleQualification(){cudaGraphExecDestroy(executable);cudaGraphDestroy(graph);}
    void verifyRejected(){
        std::vector<Vector> marker(n,unpack({123,123,123,123,123,123}));rhs.put(std::vector<Vector>(n),stream);once.put(marker,stream);squared.put(marker,stream);twice.put(marker,stream);
        check(cudaGraphLaunch(executable,stream));const auto a=once.get(stream),b=squared.get(stream),c=twice.get(stream);
        if(n)require(!std::memcmp(a.data(),marker.data(),n*sizeof(Vector)) && !std::memcmp(b.data(),marker.data(),n*sizeof(Vector)) && !std::memcmp(c.data(),marker.data(),n*sizeof(Vector)),"invalid hierarchy published cycle output");
    }
    void verify(const Fixture& f,const ResidentHierarchy& h){
        std::vector<Vector> x(n),y(n),sum(n);for(unsigned i=0;i<n;++i){Six a{},b{},c{};for(unsigned k=0;k<6;++k){a[k]=(int((i*7+k*11)%29)-14)/16.;b[k]=(int((i*13+k*3)%23)-11)/8.;c[k]=a[k]+b[k];}x[i]=unpack(a);y[i]=unpack(b);sum[i]=unpack(c);}
        const auto mx=run(x),repeated=run(x),my=run(y),ms=run(sum);
        if(n){require(!std::memcmp(mx.first.data(),repeated.first.data(),n*sizeof(Vector)),"cycle output is not byte-repeatable");require(!std::memcmp(mx.second.data(),repeated.second.data(),n*sizeof(Vector)),"squared cycle output is not byte-repeatable");}
        for(unsigned square=0;square<2;++square){const auto& a=square?mx.second:mx.first;const auto& b=square?my.second:my.first;const auto& c=square?ms.second:ms.first;
            Wide left=0,right=0,energy=0,scale=1,worst=0,absolute=0,response=1;
            // Normwise linearity per physical stress component AND coordinate:
            // cancellation in a small entry must not demand relative accuracy
            // below FP64 for an operator whose other entries are much larger.
            // Components and angular/linear coordinates cannot hide each other.
            std::vector<Wide> componentScale(size_t(n)*6,1),componentError(size_t(n)*6);
            unsigned worstNode=0,worstCoordinate=0;
            for(unsigned i=0;i<n;++i)for(unsigned k=0;k<6;++k){const Wide av=pack(a[i])[k],bv=pack(b[i])[k],cv=pack(c[i])[k],xv=pack(x[i])[k],yv=pack(y[i])[k];
                const Wide difference=std::abs(cv-av-bv),magnitude=std::max(1.L,std::abs(cv)+std::abs(av)+std::abs(bv)),error=difference/magnitude;
                if(f.component[i]==Invalid)require(av==0 && bv==0 && cv==0,"cycle wrote a fixed/omitted row");
                else {const size_t entry=size_t(f.component[i])*6+k;componentScale[entry]=std::max(componentScale[entry],magnitude);componentError[entry]=std::max(componentError[entry],difference);}
                if(error>worst){worst=error;worstNode=i;worstCoordinate=k;}absolute=std::max(absolute,difference);response=std::max(response,magnitude);
                left+=xv*bv;right+=yv*av;energy+=xv*av;scale+=std::abs(xv*bv)+std::abs(yv*av)+std::abs(xv*av);}
            if(n>=1000 || worst>=2e-12L)std::fprintf(stderr,"cycle numeric nodes=%u bonds=%zu squared=%u local=%.17Lg absolute=%.17Lg response=%.17Lg normwise=%.17Lg symmetry=%.17Lg worst-node=%u coordinate=%u\n",n,f.a.size(),square,worst,absolute,response,absolute/response,std::abs(left-right)/scale,worstNode,worstCoordinate);
            Wide componentWorst=0;for(size_t i=0;i<componentScale.size();++i)componentWorst=std::max(componentWorst,componentError[i]/componentScale[i]);
            if(n>=1000)std::fprintf(stderr,"cycle component-coordinate normwise nodes=%u bonds=%zu squared=%u error=%.17Lg\n",n,f.a.size(),square,componentWorst);
            require(componentWorst<2e-12L,"cycle component-coordinate normwise linearity failed");
            require(std::abs(left-right)<2e-12L*scale,"cycle is not symmetric");require(energy>=-2e-12L*scale,"cycle has negative energy");
        }
        if(n<=24){DenseCycleOracle oracle(f,h,stream);compare(mx.first,oracle.apply(x),"resident cycle differs from independent dense V-cycle");
            for(unsigned node=0;node<n;++node)for(unsigned k=0;k<6;++k){std::vector<Vector> basis(n);Six v{};v[k]=1;basis[node]=unpack(v);const auto actual=run(basis);
                compare(actual.first,oracle.apply(basis),"resident cycle basis differs from independent dense V-cycle");}
        }
        std::printf("resident V-cycle nodes=%u bonds=%zu dense-oracle=%u squared-capture/symmetry/linearity passed\n",n,f.a.size(),n<=24);
    }
};
