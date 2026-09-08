// Private accessors shared by original fine data and packed recursive levels.
// These are two mathematical levels of one solver, not alternate backends.
__device__ __forceinline__ unsigned sourceFirst(const Input& a,unsigned bond){return a.levelBonds?a.levelBonds[bond].a:a.node0[bond];}
__device__ __forceinline__ unsigned sourceSecond(const Input& a,unsigned bond){return a.levelBonds?a.levelBonds[bond].b:a.node1[bond];}
__device__ __forceinline__ double sourceHealth(const Input& a,unsigned bond){
    if(!a.levelBonds)return a.health[bond];
    const auto e=a.levelBonds[bond];if(!isfinite(e.scale))return e.scale;
    return e.scale!=0 && (e.a!=Invalid || e.b!=Invalid)?1.:0.;
}
__device__ __forceinline__ double sourceScale(const Input& a,unsigned bond){return a.levelBonds?a.levelBonds[bond].scale:a.scale[bond];}
__device__ __forceinline__ double3 sourceOffset(const Input& a,unsigned bond,bool second){
    if(a.levelBonds)return second?a.levelBonds[bond].offset1:a.levelBonds[bond].offset0;
    const auto r=second?a.offset1[bond]:a.offset0[bond];return make_double3(r.x,r.y,r.z);
}
__device__ __forceinline__ float4 sourcePosition(const Input& a,unsigned node){return a.position[a.identity?a.identity[node]:node];}
__device__ __forceinline__ float2 sourceInertia(const Input& a,unsigned node){return a.levelBonds?make_float2(1,1):a.inertia[node];}
__device__ __forceinline__ unsigned sourceComponentCapacity(const Input& a){return a.authoredNodes?a.authoredNodes:a.nodes;}
__device__ __forceinline__ bool validEndpoint(const Input& a,unsigned node){return node<a.nodes || (a.levelBonds && node==Invalid);}
__device__ __forceinline__ bool sourceCountsValid(const Input& a){return !a.counts || (a.counts[0]<=a.nodes && a.counts[1]<=a.bonds);}
__device__ __forceinline__ Input resolvedInput(Input a){
    if(a.counts && sourceCountsValid(a)){a.nodes=a.counts[0];a.bonds=a.counts[1];}
    return a;
}

__device__ __forceinline__ bool cachedSelfRows(const Input& a){
    return a.levelBonds && a.nodes<=SelfCacheNodes && a.nonSelfRefs;
}
