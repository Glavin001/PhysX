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
// Ordering of normalized pairs (|lo| <= ulp(hi)/2): by hi, then lo.
__device__ __forceinline__ bool less(Pair a,Pair b){return a.hi<b.hi || (a.hi==b.hi && a.lo<b.lo);}
__device__ __forceinline__ bool finite(Pair a){return isfinite(a.hi) && isfinite(a.lo);}
}}
