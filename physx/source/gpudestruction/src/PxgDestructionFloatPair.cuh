// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Float-pair arithmetic for the CuMetal build (PX_CUMETAL), where binary64 is
// emulated: each double operation is a library call costing on the order of a
// microsecond of latency inside a physics step, so a dependent chain of a few
// hundred of them dominates its kernel. A pair (hi+lo) holds about 48
// significand bits (double: 53). Operations follow Joldes, Muller and Popescu
// (2017): AccurateDWPlusDW (relative error <= 3u^2), DWTimesFP3 (2u^2),
// DWTimesDW3 (4u^2), DWDivDW2 (15u^2), u = 2^-24; square root is one Newton
// correction of the float root. They need round-to-nearest float operations
// that are not reassociated, which cumetalc's default (safe) math mode gives.
// Only conversions from and to double use emulated binary64 (one operation
// each way). Float subnormals may be flushed; callers keep tiny values on
// their double paths. Blast's stress motion forest uses the same formulas
// (StressMotionPair.cuh).
#pragma once
#include <cmath>

namespace physx { namespace destructionPair {
struct Pair {float hi,lo;};
__device__ __forceinline__ void twoSum(float a,float b,float& s,float& e){s=a+b;const float v=s-a;e=(a-(s-v))+(b-v);}
__device__ __forceinline__ void fastTwoSum(float a,float b,float& s,float& e){s=a+b;e=b-(s-a);}
__device__ __forceinline__ Pair pair(float f){return {f,0.0f};}
// hi is double's value rounded to float; lo the rounded remainder, taken with
// one emulated subtraction. (An exact integer split of the double's bits works
// in isolation but made Apple's shader compiler fail on prepareCandidateBodies.)
__device__ __forceinline__ Pair pair(double d){const float hi=float(d);return {hi,float(d-double(hi))};}
__device__ __forceinline__ double value(Pair a){return double(a.hi)+double(a.lo);}
__device__ __forceinline__ Pair neg(Pair a){return {-a.hi,-a.lo};}
__device__ __forceinline__ Pair abs(Pair a){return a.hi<0 || (a.hi==0 && a.lo<0)?neg(a):a;}
// Exact scaling by a power of two (no overflow/underflow in the ranges used).
__device__ __forceinline__ Pair scale(Pair a,float power){return {a.hi*power,a.lo*power};}
__device__ __forceinline__ Pair add(Pair a,Pair b){
    float sh,sl,th,tl,vh,vl,zh,zl;twoSum(a.hi,b.hi,sh,sl);twoSum(a.lo,b.lo,th,tl);
    fastTwoSum(sh,sl+th,vh,vl);fastTwoSum(vh,tl+vl,zh,zl);return {zh,zl};
}
__device__ __forceinline__ Pair sub(Pair a,Pair b){return add(a,neg(b));}
__device__ __forceinline__ Pair mul(Pair a,float b){
    const float ch=a.hi*b,cl=fmaf(a.hi,b,-ch);float zh,zl;fastTwoSum(ch,fmaf(a.lo,b,cl),zh,zl);return {zh,zl};
}
__device__ __forceinline__ Pair mul(Pair a,Pair b){
    const float ch=a.hi*b.hi,cl=fmaf(a.hi,b.hi,-ch);
    const float t=fmaf(a.lo,b.hi,fmaf(a.hi,b.lo,a.lo*b.lo));float zh,zl;fastTwoSum(ch,cl+t,zh,zl);return {zh,zl};
}
__device__ __forceinline__ Pair div(Pair a,Pair b){
    const float th=a.hi/b.hi;const Pair r=mul(b,th);
    const float tl=((a.hi-r.hi)+(a.lo-r.lo))/b.hi;float zh,zl;fastTwoSum(th,tl,zh,zl);return {zh,zl};
}
__device__ __forceinline__ Pair sqrt(Pair a){
    if(!(a.hi>0))return {sqrtf(a.hi),0.0f};
    const float s=sqrtf(a.hi),p=s*s,e=fmaf(s,s,-p);float zh,zl;
    fastTwoSum(s,(((a.hi-p)-e)+a.lo)/(2*s),zh,zl);return {zh,zl};
}
// Conversions between binary64 and pairs with integer operations only.
// CuMetal emulates every double conversion as a library call (about a
// microsecond each inside a kernel); these give bit-identical results:
// pairBits(d) == pair(d), doubleBits(f) == double(f), valueBits(p) ==
// value(p) (the double nearest hi+lo, ties to even). Values outside the
// normal float range take the emulated conversion, which handles them.
__device__ __forceinline__ double doubleBits(float f) {
    const unsigned b=__float_as_uint(f),e=(b>>23)&0xffu;
    if(e==0u || e==0xffu)return double(f); // zero, subnormal, inf, nan
    return __longlong_as_double((long long)((static_cast<unsigned long long>(b>>31)<<63)
        |(static_cast<unsigned long long>(e+896u)<<52)|(static_cast<unsigned long long>(b&0x7fffffu)<<29)));
}
__device__ __forceinline__ Pair pairBits(double d) {
    const unsigned long long b=static_cast<unsigned long long>(__double_as_longlong(d));
    const int e=int((b>>52)&0x7ffu)-1023;
    // Both parts normal floats: the remainder's scale 2^(e-52) >= 2^-126, and
    // hi <= 2^(e+1) < 2^128. Beyond that (and for zero, subnormal, inf and
    // nan, whose biased exponents fall outside) take the emulated split.
    if(e<-70 || e>120)return pair(d);
    const unsigned long long m=(b&0xfffffffffffffull)|(1ull<<52); // 53-bit significand
    unsigned long long top=m>>29;const unsigned long long rest=m&((1ull<<29)-1);
    if(rest>(1ull<<28) || (rest==(1ull<<28) && (top&1ull)))++top; // nearest, ties to even
    const long long remainder=static_cast<long long>(m)-static_cast<long long>(top<<29); // exact, |r| <= 2^28
    const float sign=(b>>63)?-1.0f:1.0f;
    // hi = top * 2^(e-52+29), lo = remainder * 2^(e-52); top may be 2^24 after rounding.
    const float hi=sign*float(top)*__uint_as_float(static_cast<unsigned>(e-23+127)<<23);
    // The remainder carries the sign itself, so an exact split gives +0 as pair(d) does.
    const int r=static_cast<int>(remainder);
    const float lo=float((b>>63)?-r:r)*__uint_as_float(static_cast<unsigned>(e-52+127)<<23);
    return {hi,lo};
}
__device__ __forceinline__ double valueBits(Pair a) {
    const unsigned hb=__float_as_uint(a.hi),lb=__float_as_uint(a.lo);
    const unsigned he=(hb>>23)&0xffu,le=(lb>>23)&0xffu;
    // hi normal and lo zero or normal; anything else takes the emulated sum.
    if(he==0u || he==0xffu || le==0xffu || (le==0u && (lb&0x7fffffffu)))return value(a);
    const unsigned long long mh=(hb&0x7fffffu)|0x800000u;
    const int eh=int(he)-150;                      // hi = mh * 2^eh
    unsigned long long t=mh<<39;int et=eh-39;       // t * 2^et, t < 2^63
    if(le) {
        const unsigned long long ml=(lb&0x7fffffu)|0x800000u;
        const int el=int(le)-150;const int shift=et-el; // lo = ml * 2^el = (ml >> shift) * 2^et
        if(shift<-15)return value(a);                 // not a normalized pair (|lo| > ulp(hi)/2)
        unsigned long long term;bool sticky=false;
        if(shift<=0)term=ml<<(-shift);              // below 2^39
        else if(shift<64){term=ml>>shift;sticky=(ml&((1ull<<shift)-1))!=0;}
        else {term=0;sticky=true;}
        if((hb>>31)==(lb>>31)){t+=term;if(sticky)t|=1ull;}
        else {t-=term;if(sticky){t-=1ull;t|=1ull;}}   // borrow for the discarded tail, then sticky
    }
    // Normalize t to 64 bits and round to 53 (nearest, ties to even).
    const int lead=63-__clzll(static_cast<long long>(t));
    int exponent=et+lead;                           // value = 1.xxx * 2^exponent
    unsigned long long mant;
    if(lead>52) {
        const int drop=lead-52;const unsigned long long half=1ull<<(drop-1),dropped=t&((1ull<<drop)-1);
        mant=t>>drop;
        if(dropped>half || (dropped==half && (mant&1ull)))++mant;
        if(mant>>53){mant>>=1;++exponent;}
    } else mant=t<<(52-lead);
    if(exponent<-1022 || exponent>1023)return value(a);
    return __longlong_as_double(static_cast<long long>((static_cast<unsigned long long>(hb>>31)<<63)
        |(static_cast<unsigned long long>(exponent+1023)<<52)|(mant&0xfffffffffffffull)));
}
// Ordering of normalized pairs (|lo| <= ulp(hi)/2): by hi, then lo.
__device__ __forceinline__ bool less(Pair a,Pair b){return a.hi<b.hi || (a.hi==b.hi && a.lo<b.lo);}
__device__ __forceinline__ bool finite(Pair a){return isfinite(a.hi) && isfinite(a.lo);}
}}
