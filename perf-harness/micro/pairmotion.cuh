// Float-pair motion arithmetic for provisionalTopologyMotion under PX_CUMETAL.
struct DestructionPair {float hi,lo;};
__device__ __forceinline__ void destructionTwoSum(float a,float b,float& s,float& e){s=a+b;const float v=s-a;e=(a-(s-v))+(b-v);}
__device__ __forceinline__ void destructionFastTwoSum(float a,float b,float& s,float& e){s=a+b;e=b-(s-a);}
// Joldes, Muller and Popescu (2017): AccurateDWPlusDW (3u^2) and DWTimesFP3 (2u^2).
__device__ __forceinline__ DestructionPair pairAdd(DestructionPair a,DestructionPair b){
    float sh,sl,th,tl,vh,vl,zh,zl;destructionTwoSum(a.hi,b.hi,sh,sl);destructionTwoSum(a.lo,b.lo,th,tl);
    destructionFastTwoSum(sh,sl+th,vh,vl);destructionFastTwoSum(vh,tl+vl,zh,zl);return {zh,zl};
}
__device__ __forceinline__ DestructionPair pairSub(DestructionPair a,DestructionPair b){return pairAdd(a,{-b.hi,-b.lo});}
__device__ __forceinline__ DestructionPair pairMul(DestructionPair a,float b){
    const float ch=a.hi*b,cl=fmaf(a.hi,b,-ch);float zh,zl;destructionFastTwoSum(ch,fmaf(a.lo,b,cl),zh,zl);return {zh,zl};
}
__device__ __forceinline__ DestructionPair pairOf(float f){return {f,0.0f};}
// Two emulated double operations per value in and out; everything between is float.
__device__ __forceinline__ DestructionPair pairOf(double d){const float hi=float(d);return {hi,float(d-double(hi))};}
__device__ __forceinline__ double pairDouble(DestructionPair a){return double(a.hi)+double(a.lo);}
