// Scheduling parity: broadcast one rounded reciprocal without changing the
// original per-node direction or scalar contribution, including invalid loads.
namespace MotionModeTest {
__global__ void normalizationParity(PersistentStressArgs a,const Vector* values,
    unsigned n,AngLin* reference,float* gamma,float* expected,double* maxima){
    double magnitude=0;
    for(unsigned i=threadIdx.x;i<n;i+=blockDim.x)
        magnitude=fmax(magnitude,nativeCycleMagnitude(values[i]));
    double inverse;magnitude=nativeComponentMaximum(magnitude,inverse);
    if(!threadIdx.x){maxima[0]=magnitude;maxima[1]=inverse;}
    for(unsigned i=threadIdx.x;i<n;i+=blockDim.x){
        gamma[i]=nativeCycleResult<true>(a,i,0,magnitude,values,inverse);
        auto old=a;old.hierarchy.g=reference;old.hierarchy.failed=a.hierarchy.failed+1;
        expected[i]=nativeCycleResult(old,i,0,magnitude,values);
    }
}
void normalizationBroadcast(){
    constexpr unsigned n=517;
    Device<Vector> values(n),rhs(n);Device<AngLin> observed(n),reference(n);
    Device<float> gamma(n),expected(n);Device<unsigned> failed(2);Device<double> maxima(2);
    PersistentStressArgs a{};a.hierarchy.rhs=rhs.data;a.hierarchy.g=observed.data;a.hierarchy.failed=failed.data;
    for(double scale:{0.,1e-150,1.,1e150}){
        std::vector<Vector> v(n),r(n);
        double maximum=0;
        for(unsigned i=0;i<n;++i){
            const double x=scale*double(int(i%31)-15);
            v[i]={{x,-x*.5,x*.25},{-x*.125,x*.0625,-x*.03125}};
            r[i]={{.5,-.25,.125},{-.0625,.03125,-.015625}};
            maximum=std::max(maximum,std::abs(x));
        }
        values.put(v);rhs.put(r);failed.put({0,0});
        observed.put(std::vector<AngLin>(n));reference.put(std::vector<AngLin>(n));
        normalizationParity<<<1,kBlockSize>>>(a,values.data,n,reference.data,gamma.data,expected.data,maxima.data);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto x=observed.get(),y=reference.get();const auto g=gamma.get(),h=expected.get();
        const auto flags=failed.get();const auto m=maxima.get();
        require(!std::memcmp(x.data(),y.data(),n*sizeof(AngLin)),"broadcast normalization changed direction bits");
        require(!std::memcmp(g.data(),h.data(),n*sizeof(float)),"broadcast normalization changed gamma bits");
        require(flags[0]==flags[1] && flags[0]==unsigned(scale==0),"broadcast normalization changed failure status");
        require(m[0]==maximum && (scale==0?std::isinf(m[1]):m[1]==1/maximum),"broadcast normalization maximum/reciprocal mismatch");
    }
    std::printf("GPU normalization 517 nodes, zero/tiny/unit/large RHS: bit-identical directions and gamma passed\n");
}
}
