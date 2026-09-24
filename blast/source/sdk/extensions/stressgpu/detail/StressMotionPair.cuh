// Motion-forest arithmetic without binary64, for Apple GPUs (PX_CUMETAL).
// Metal has no binary64 hardware and CuMetal emulates each double operation
// in integer code, 30-60 times the cost of the float work below. The forest
// needs two different things from double, and gets each without it:
// - Exact sums of float offsets, with the same rejection rule. MotionExact
//   holds a value as up to three non-overlapping floats (72 significand bits,
//   more than double's 53). Error-free TwoSum transformations add exactly, and
//   whether binary64 would have held the sum is decided from its bit span.
//   Positions, closures and their tests are the same real numbers and
//   decisions as in double. Only float operations are used: exponent and
//   trailing-zero reads aside, no integer arithmetic carries values.
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


struct MotionExact {float x[3];};          // x[0] leads; non-overlapping
struct MotionExact3 {MotionExact x,y,z;};
// Terms stay normal and far from overflow, where TwoSum and TwoProd are exact
// whether or not the GPU flushes subnormals. Offsets outside this range (no
// physical scene has them) are rejected like an inexact sum.
constexpr float MotionExactLargest=0x1p60f,MotionExactSmallest=0x1p-100f;
__device__ __forceinline__ int motionExponent(float f){return int((__float_as_uint(f)>>23)&255u)-127;}
// Lowest set bit of a normal float's value, as a power of two.
__device__ __forceinline__ int motionLowestBit(float f){return motionExponent(f)-24+__ffs(int((__float_as_uint(f)&0x7fffffu)|0x800000u));}
// binary64 holds a non-overlapping expansion's value iff its significant bits
// span at most 53. Terms outside the guarded range reject the value.
__device__ __forceinline__ bool motionRepresentable(const MotionExact& out){
    if(out.x[0]==0)return true;
    int high=motionExponent(out.x[0]),low=high;bool exact=true;
    for(unsigned i=0;i<3;++i)if(out.x[i]!=0){const float m=fabsf(out.x[i]);
        if(!(m<=MotionExactLargest) || m<MotionExactSmallest)exact=false;else low=min(low,motionLowestBit(out.x[i]));}
    // A power-of-two lead reduced by an opposite remainder loses its top bit.
    const bool power=(__float_as_uint(out.x[0])&0x7fffffu)==0;
    const float next=out.x[1]!=0?out.x[1]:out.x[2];
    if(power && next!=0 && (next<0)!=(out.x[0]<0))--high;
    return exact && high-low+1<=53;
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
        if(term<3)out.x[term]=v[term];else if(v[term]!=0)exact=false;
    }
    for(unsigned pass=0;pass<2;++pass)for(unsigned i=0;i<2;++i)if(out.x[i]==0){out.x[i]=out.x[i+1];out.x[i+1]=0;}
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
    MotionExact out;float v[6]={a.x[0],b.x[0],a.x[1],b.x[1],a.x[2],b.x[2]};exact=motionDistill(v,out)&&exact;return out;
}
__device__ __noinline__ MotionExact motionExactAdd(MotionExact a,MotionExact b,bool& exact){
    if(a.x[2]!=0 || b.x[2]!=0)return motionExactAddWide(a,b,exact);
    MotionExact out;float v[4]={a.x[0],b.x[0],a.x[1],b.x[1]};exact=motionDistill(v,out)&&exact;return out;
}
__device__ __forceinline__ MotionExact neg(MotionExact a){return {{-a.x[0],-a.x[1],-a.x[2]}};}
__device__ __forceinline__ MotionExact3 neg(MotionExact3 v){return {neg(v.x),neg(v.y),neg(v.z)};}
__device__ __forceinline__ MotionExact3 motionExactAdd(MotionExact3 a,MotionExact3 b,bool& exact){
    return {motionExactAdd(a.x,b.x,exact),motionExactAdd(a.y,b.y,exact),motionExactAdd(a.z,b.z,exact)};
}
__device__ __forceinline__ bool motionNonzero(MotionExact a){return a.x[0]!=0;}
__device__ __forceinline__ bool motionNonzero(MotionExact3 v){return motionNonzero(v.x) || motionNonzero(v.y) || motionNonzero(v.z);}
__device__ __forceinline__ MotionExact motionMagnitude(MotionExact a){return a.x[0]<0?neg(a):a;}
// Exact magnitude comparison |a| > |b| (both given as magnitudes).
__device__ __forceinline__ bool motionGreater(MotionExact a,MotionExact b){
    float v[6]={a.x[0],-b.x[0],a.x[1],-b.x[1],a.x[2],-b.x[2]};
    for(unsigned pass=0;pass<5;++pass)for(unsigned i=5;i>0;--i){float s,e;motionTwoSum(v[i-1],v[i],s,e);v[i-1]=s;v[i]=e;}
    for(unsigned i=0;i<6;++i)if(v[i]!=0)return v[i]>0;
    return false;
}
__device__ __forceinline__ MotionExact motionMax(MotionExact a,MotionExact b){return motionGreater(b,a)?b:a;}
__device__ __forceinline__ MotionExact motionExact(float f){return {{f,0.f,0.f}};}
__device__ __forceinline__ MotionExact motionScaled(MotionExact a,float power){return {{a.x[0]*power,a.x[1]*power,a.x[2]*power}};}
__device__ __forceinline__ MotionPair motionPair(MotionExact a){float s,e;motionTwoSum(a.x[0],a.x[1]+a.x[2],s,e);return {s,e};}
__device__ __forceinline__ MotionPair3 motionPair(MotionExact3 v){return {motionPair(v.x),motionPair(v.y),motionPair(v.z)};}
// The exact binary64 value, for a sum the rejection rule accepted.
__device__ __forceinline__ double motionDouble(MotionExact a){return double(a.x[0])+(double(a.x[1])+double(a.x[2]));}
__device__ __forceinline__ double3 motionDouble(MotionExact3 v){return {motionDouble(v.x),motionDouble(v.y),motionDouble(v.z)};}
}}}
