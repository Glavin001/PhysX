// Motion-forest arithmetic without binary64, for Apple GPUs (PX_CUMETAL).
// Metal has no binary64 hardware and CuMetal emulates each double operation
// in integer code, 30-60 times the cost of the float work below. The forest
// needs two different things from double, and gets each without it:
// - Exact sums of float offsets. MotionExact holds eight non-overlapping
//   floats, including separated low terms beyond binary64's bit span. No
//   residual is discarded: sums outside the expansion capacity still fail.
//   Exact predicates operate on every term, never a rounded double conversion.
// - Accurate, not exact, frame arithmetic (centers, axes, the Gram factor).
//   A float pair (hi+lo, about 48 bits) replaces double's 53; its results are
//   consumed in the solver's float precision.
// Pair arithmetic needs round-to-nearest float operations that are not
// reassociated, which cumetalc's default (safe) math mode provides.
#pragma once
#include "StressHierarchyKernels.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
struct MotionPair {float hi,lo;};
struct MotionPair3 {MotionPair x,y,z;};
__device__ __forceinline__ void motionTwoSum(float a,float b,float& s,float& e){
    s=a+b;const float v=s-a;e=(a-(s-v))+(b-v);
}
__device__ __forceinline__ void motionFastTwoSum(float a,float b,float& s,float& e){s=a+b;e=b-(s-a);}
__device__ __forceinline__ void motionTwoProd(float a,float b,float& p,float& e){p=a*b;e=fmaf(a,b,-p);}
__device__ __forceinline__ MotionPair motionPair(float a){return {a,0.f};}
__device__ __forceinline__ MotionPair neg(MotionPair a){return {-a.hi,-a.lo};}
// Joldes, Muller and Popescu (2017): AccurateDWPlusDW, DWTimesDW3,
// DWTimesFP3 and DWDivDW2, relative errors of at most 3u^2, 4u^2, 2u^2 and
// 15u^2 (u = 2^-24).
__device__ __forceinline__ MotionPair add(MotionPair a,MotionPair b){
    float sh,sl,th,tl,vh,vl,zh,zl;motionTwoSum(a.hi,b.hi,sh,sl);motionTwoSum(a.lo,b.lo,th,tl);
    motionFastTwoSum(sh,sl+th,vh,vl);motionFastTwoSum(vh,tl+vl,zh,zl);return {zh,zl};
}
__device__ __forceinline__ MotionPair sub(MotionPair a,MotionPair b){return add(a,neg(b));}
__device__ __forceinline__ MotionPair mul(MotionPair a,MotionPair b){
    float ch,cl,zh,zl;motionTwoProd(a.hi,b.hi,ch,cl);
    const float t=fmaf(a.lo,b.hi,fmaf(a.hi,b.lo,a.lo*b.lo));motionFastTwoSum(ch,cl+t,zh,zl);return {zh,zl};
}
__device__ __forceinline__ MotionPair mul(MotionPair a,float b){
    float ch,cl,zh,zl;motionTwoProd(a.hi,b,ch,cl);motionFastTwoSum(ch,fmaf(a.lo,b,cl),zh,zl);return {zh,zl};
}
__device__ __forceinline__ MotionPair motionDiv(MotionPair a,MotionPair b){
    const float th=a.hi/b.hi;const MotionPair r=mul(b,th);
    const float tl=((a.hi-r.hi)+(a.lo-r.lo))/b.hi;float zh,zl;motionFastTwoSum(th,tl,zh,zl);return {zh,zl};
}
__device__ __forceinline__ MotionPair motionSqrt(MotionPair a){
    if(!(a.hi>0))return {sqrtf(a.hi),0.f};
    const float s=sqrtf(a.hi);float p,e,zh,zl;motionTwoProd(s,s,p,e);
    motionFastTwoSum(s,(((a.hi-p)-e)+a.lo)/(2*s),zh,zl);return {zh,zl};
}
__device__ __forceinline__ MotionPair motionAbs(MotionPair a){return a.hi<0?neg(a):a;}
__device__ __forceinline__ bool motionFinite(MotionPair a){return isfinite(a.hi) && isfinite(a.lo);}
__device__ __forceinline__ MotionPair3 sub(MotionPair3 a,MotionPair3 b){return {sub(a.x,b.x),sub(a.y,b.y),sub(a.z,b.z)};}
__device__ __forceinline__ MotionPair3 mul(MotionPair3 a,MotionPair b){return {mul(a.x,b),mul(a.y,b),mul(a.z,b)};}
__device__ __forceinline__ MotionPair3 cross(MotionPair3 a,MotionPair3 b){
    return {sub(mul(a.y,b.z),mul(a.z,b.y)),sub(mul(a.z,b.x),mul(a.x,b.z)),sub(mul(a.x,b.y),mul(a.y,b.x))};
}
__device__ __forceinline__ MotionPair dot(MotionPair3 a,MotionPair3 b){return add(add(mul(a.x,b.x),mul(a.y,b.y)),mul(a.z,b.z));}
// Solver-precision value of a pair: hi is already the rounded sum.
__device__ __forceinline__ StressReal motionStressReal(MotionPair a){
#if defined(BLAST_STRESS_GPU_FP64) && BLAST_STRESS_GPU_FP64
    return double(a.hi)+double(a.lo);
#else
    return a.hi;
#endif
}


constexpr unsigned MotionExactTerms=8;
struct MotionExact {float x[MotionExactTerms];};          // x[0] leads; non-overlapping
struct MotionExact3 {MotionExact x,y,z;};
// Terms stay normal and far from overflow, where TwoSum and TwoProd are exact
// whether or not the GPU flushes subnormals. Offsets outside this range (no
// physical scene has them) are rejected like an inexact sum.
constexpr float MotionExactLargest=0x1p60f,MotionExactSmallest=0x1p-100f;
// Non-overlapping terms need not fit one contiguous 53-bit significand.
// Reject only unsupported magnitudes here; distillation independently rejects
// an unrepresentable residual. This preserves tiny authored COM offsets exactly.
__device__ __forceinline__ bool motionRepresentable(const MotionExact& out){
    for(unsigned i=0;i<MotionExactTerms;++i)if(out.x[i]!=0){const float m=fabsf(out.x[i]);
        if(!(m<=MotionExactLargest) || m<MotionExactSmallest)return false;}
    return true;
}
// Canonical error-free distillation: VecSum passes (Ogita, Rump and Oishi)
// move the sum into the leading slot without changing the exact total;
// repeating it on the remainders peels off the next terms.
template<unsigned Count>
__device__ __forceinline__ bool motionDistill(float (&v)[Count],MotionExact& out){
    out={};bool exact=true;
    for(unsigned term=0;term<Count;++term){
        for(unsigned pass=term;pass+1<Count;++pass)
            for(unsigned i=Count-1;i>term;--i){float s,e;motionTwoSum(v[i-1],v[i],s,e);v[i-1]=s;v[i]=e;}
        if(term<MotionExactTerms)out.x[term]=v[term];else if(v[term]!=0)exact=false;
    }
    for(unsigned pass=0;pass+1<MotionExactTerms;++pass)for(unsigned i=0;i+1<MotionExactTerms;++i)if(out.x[i]==0){out.x[i]=out.x[i+1];out.x[i+1]=0;}
    return exact && motionRepresentable(out);
}
__device__ __forceinline__ MotionExact motionExactDifference(float a,float b,bool& exact){
    if(!isfinite(a) || !isfinite(b)){exact=false;return {};}
    float s,e;motionTwoSum(a,-b,s,e);const MotionExact out{{s,e,0.f}};exact=motionRepresentable(out)&&exact;return out;
}
// Exact addition. Kept out of line: inlined at every use, the distillation
// makes kernels large enough that Metal's compiler spills them (measured 8x
// slower for the closure kernel).
__device__ __noinline__ MotionExact motionExactAddWide(MotionExact a,MotionExact b,bool& exact){
    MotionExact out;float v[2*MotionExactTerms];
    for(unsigned i=0;i<MotionExactTerms;++i){v[2*i]=a.x[i];v[2*i+1]=b.x[i];}
    exact=motionDistill(v,out)&&exact;return out;
}
__device__ __noinline__ MotionExact motionExactAdd(MotionExact a,MotionExact b,bool& exact){
    for(unsigned i=3;i<MotionExactTerms;++i)if(a.x[i]!=0 || b.x[i]!=0)return motionExactAddWide(a,b,exact);
    MotionExact out;
    if(a.x[2]!=0 || b.x[2]!=0){float v[6]={a.x[0],b.x[0],a.x[1],b.x[1],a.x[2],b.x[2]};exact=motionDistill(v,out)&&exact;}
    else {float v[4]={a.x[0],b.x[0],a.x[1],b.x[1]};exact=motionDistill(v,out)&&exact;}
    return out;
}
__device__ __forceinline__ MotionExact neg(MotionExact a){for(unsigned i=0;i<MotionExactTerms;++i)a.x[i]=-a.x[i];return a;}
__device__ __forceinline__ MotionExact3 neg(MotionExact3 v){return {neg(v.x),neg(v.y),neg(v.z)};}
__device__ __forceinline__ MotionExact3 motionExactAdd(MotionExact3 a,MotionExact3 b,bool& exact){
    return {motionExactAdd(a.x,b.x,exact),motionExactAdd(a.y,b.y,exact),motionExactAdd(a.z,b.z,exact)};
}
__device__ __forceinline__ bool motionNonzero(MotionExact a){return a.x[0]!=0;}
__device__ __forceinline__ bool motionNonzero(MotionExact3 v){return motionNonzero(v.x) || motionNonzero(v.y) || motionNonzero(v.z);}
__device__ __forceinline__ MotionExact motionMagnitude(MotionExact a){return a.x[0]<0?neg(a):a;}
// Exact magnitude comparison |a| > |b| (both given as magnitudes).
__device__ __forceinline__ bool motionGreater(MotionExact a,MotionExact b){
    float v[2*MotionExactTerms];for(unsigned i=0;i<MotionExactTerms;++i){v[2*i]=a.x[i];v[2*i+1]=-b.x[i];}
    for(unsigned pass=0;pass+1<2*MotionExactTerms;++pass)for(unsigned i=2*MotionExactTerms-1;i>0;--i){float s,e;motionTwoSum(v[i-1],v[i],s,e);v[i-1]=s;v[i]=e;}
    for(unsigned i=0;i<2*MotionExactTerms;++i)if(v[i]!=0)return v[i]>0;
    return false;
}
__device__ __forceinline__ MotionExact motionMax(MotionExact a,MotionExact b){return motionGreater(b,a)?b:a;}
__device__ __forceinline__ MotionExact motionExact(float f){return {{f,0.f,0.f}};}
__device__ __forceinline__ MotionExact motionScaled(MotionExact a,float power){for(unsigned i=0;i<MotionExactTerms;++i)a.x[i]*=power;return a;}
__device__ __forceinline__ MotionPair motionPair(MotionExact a){float tail=0,s,e;for(unsigned i=MotionExactTerms-1;i>0;--i)tail+=a.x[i];motionTwoSum(a.x[0],tail,s,e);return {s,e};}
__device__ __forceinline__ MotionPair3 motionPair(MotionExact3 v){return {motionPair(v.x),motionPair(v.y),motionPair(v.z)};}
// Rounded binary64 conversion for frame arithmetic only, never predicates.
__device__ __forceinline__ double motionDouble(MotionExact a){double sum=0;for(unsigned i=MotionExactTerms;i>0;--i)sum=__dadd_rn(sum,double(a.x[i-1]));return sum;}
__device__ __forceinline__ double3 motionDouble(MotionExact3 v){return {motionDouble(v.x),motionDouble(v.y),motionDouble(v.z)};}
// Compare a*b and c*d without collapsing the input expansions. Each binary32
// product is exact in binary64 (at most 48 significant bits), and guarded term
// magnitudes keep every product normal. Grow-expansion with zero elimination
// retains every TwoSum residual; capacity is two complete expansion products.
// See Shewchuk, Adaptive Precision Floating-Point Arithmetic (1997), section 2.
__device__ __noinline__ bool motionProductEqual(MotionExact a,MotionExact b,MotionExact c,MotionExact d){
    double expansion[2*MotionExactTerms*MotionExactTerms];unsigned count=0;
    for(unsigned side=0;side<2;++side)for(unsigned i=0;i<MotionExactTerms;++i)for(unsigned j=0;j<MotionExactTerms;++j){
        double carry=side?-__dmul_rn(double(c.x[i]),double(d.x[j])):__dmul_rn(double(a.x[i]),double(b.x[j]));
        if(carry==0)continue;
        unsigned next=0;
        for(unsigned k=0;k<count;++k){
            const double term=expansion[k],sum=__dadd_rn(carry,term),virtualTerm=__dsub_rn(sum,carry);
            const double error=__dadd_rn(__dsub_rn(carry,__dsub_rn(sum,virtualTerm)),__dsub_rn(term,virtualTerm));
            if(error!=0)expansion[next++]=error;carry=sum;
        }
        if(carry!=0)expansion[next++]=carry;count=next;
    }
    return count==0;
}
__device__ __forceinline__ bool motionCollinear(MotionExact3 a,MotionExact3 b){
    return motionProductEqual(a.y,b.z,a.z,b.y) && motionProductEqual(a.z,b.x,a.x,b.z) && motionProductEqual(a.x,b.y,a.y,b.x);
}
}}}
