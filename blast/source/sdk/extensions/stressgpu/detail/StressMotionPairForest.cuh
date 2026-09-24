// The motion forest for Apple GPUs (PX_CUMETAL), phase for phase the double
// implementation in StressMotionForest.cuh. Positions, closures and every
// exactness, significance and collinearity decision are computed exactly from
// float expansions (StressMotionPair.cuh), so they are the same numbers and
// verdicts; only the closure axis is rounded, in a float pair. A sum binary64
// would not have held exactly is still reported as error 16.
#pragma once
#include "StressMotionPair.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
struct MotionComponent {
    unsigned anchored,rotations,closure,cuts,edges;
    MotionPair3 axis;
    // The projection's frame, in the solver's precision.
    StressReal3 frameAxis;
    StressReal factor[21],scale[6];
};
struct MotionBuffers {
    unsigned *previous[2],*first;
    MotionExact3 *sum[2],*position;
    MotionComponent* components;
    // Each node's position relative to its component center, solver precision.
    StressReal3* relative;
};
__device__ __forceinline__ MotionExact3 exactMotionAdd(MotionExact3 a,MotionExact3 b,Status* status){
    bool representable=true;const auto sum=motionExactAdd(a,b,representable);
    if(!representable)atomicOr(&status->error,16u);return sum;
}
__device__ __forceinline__ MotionExact motionDifference(float x,float y,Status* status){
    bool representable=true;const auto d=motionExactDifference(x,y,representable);
    if(!representable)atomicOr(&status->error,16u);return d;
}
__device__ __forceinline__ MotionExact3 motionOffset(const Input& a,unsigned edge,Status* status){
    const auto x=a.offset0[edge],y=a.offset1[edge];
    return {motionDifference(x.x,y.x,status),motionDifference(x.y,y.y,status),motionDifference(x.z,y.z,status)};
}
__device__ __forceinline__ MotionExact3 motionClosure(const Input& a,MotionBuffers b,unsigned edge,Status* status){
    return exactMotionAdd(exactMotionAdd(b.position[a.node0[edge]],motionOffset(a,edge,status),status),neg(b.position[a.node1[edge]]),status);
}
// Exact product comparison. Accepted closures are binary64 values, so the
// double implementation's own predicate decides it; closures are rare, and
// only bonds that carry one reach this emulated arithmetic.
__device__ __forceinline__ bool motionProductEqual(double a,double b,double c,double d){
    const double x=__dmul_rn(a,b),y=__dmul_rn(c,d);
    return x==y && __fma_rn(a,b,-x)==__fma_rn(c,d,-y);
}
__device__ __forceinline__ bool motionCollinear(double3 a,double3 b){
    return motionProductEqual(a.y,b.z,a.z,b.y) && motionProductEqual(a.z,b.x,a.x,b.z) && motionProductEqual(a.x,b.y,a.y,b.x);
}
__device__ void initializeMotionForest(Input a,const unsigned* forest,MotionBuffers b,Status* status,unsigned thread,unsigned stride){
    for(unsigned node=thread;node<a.nodes;node+=stride){
        b.first[node]=Invalid;b.position[node]={};b.components[node]={};b.components[node].closure=Invalid;
        const auto d=a.inertia[node];const unsigned id=a.component[node];
        const bool dynamic=d.x>0 && d.y>0,fixed=d.x==0 && d.y==0;
        if((!dynamic && !fixed) || !isfinite(d.x) || !isfinite(d.y))atomicOr(&status->error,1u);
        if(id!=Invalid && (id>=a.nodes || id>node || !dynamic || a.component[id]!=id))atomicOr(&status->error,1u);
        if(a.begin[node]>a.begin[node+1] || a.begin[node+1]>2ull*a.bonds)atomicOr(&status->error,1u);
    }
    for(unsigned edge=thread;edge<a.bonds;edge+=stride){
        b.previous[0][2*edge]=b.previous[0][2*edge+1]=Invalid;
        b.sum[0][2*edge]=b.sum[0][2*edge+1]={};
        const unsigned u=a.node0[edge],v=a.node1[edge];
        if(u>=a.nodes || v>=a.nodes || u==v || forest[edge]>1 || !isfinite(a.health[edge])){atomicOr(&status->error,1u);continue;}
        if(a.health[edge]>0){
            if(!(a.scale[edge]>0) || !isfinite(a.scale[edge]))atomicOr(&status->error,1u);
            const auto x=a.offset0[edge],y=a.offset1[edge];
            if(!isfinite(x.x)||!isfinite(x.y)||!isfinite(x.z)||!isfinite(y.x)||!isfinite(y.y)||!isfinite(y.z))atomicOr(&status->error,1u);
            if((a.inertia[u].y>0 && a.component[u]==Invalid) || (a.inertia[v].y>0 && a.component[v]==Invalid))atomicOr(&status->error,1u);
        }
        if(!forest[edge])continue;
        if(a.health[edge]<=0 || a.component[u]==Invalid || a.component[u]!=a.component[v]){atomicOr(&status->error,1u);continue;}
        const auto delta=motionOffset(a,edge,status);b.sum[0][2*edge]=delta;b.sum[0][2*edge+1]=neg(delta);
    }
}
// As in StressMotionForest.cuh (integer work only). One warp per vertex constructs its cyclic outgoing tree-edge order. Ballots
// find predecessors within a tile; a carry joins tiles. Even a hub scans its
// adjacency once, avoiding a quadratic search for every incident tree edge.
__device__ void buildMotionTour(Input a,const unsigned* forest,MotionBuffers b,Status* status,unsigned node){
    const unsigned lane=threadIdx.x&31u,begin=a.begin[node],end=a.begin[node+1];unsigned first=Invalid,last=Invalid;
    for(unsigned base=begin;base<end;base+=32){
        const unsigned slot=base+lane,ref=slot<end?a.refs[slot]:Invalid;unsigned arc=Invalid;
        if(ref!=Invalid){const unsigned edge=ref&0x7fffffffu;
            if(edge>=a.bonds)atomicOr(&status->error,1u);
            else if(((ref>>31)?a.node1[edge]:a.node0[edge])!=node)atomicOr(&status->error,1u);
            else if(forest[edge])arc=2*edge+(ref>>31);
        }
        const unsigned mask=__ballot_sync(0xffffffffu,arc!=Invalid),lower=mask&((1u<<lane)-1u);
        const unsigned priorLane=lower?31u-__clz(lower):lane,prior=__shfl_sync(0xffffffffu,arc,priorLane);
        if(arc!=Invalid)b.previous[0][arc]=(lower?prior:last)==Invalid?Invalid:((lower?prior:last)^1u);
        if(mask){const unsigned firstTile=__shfl_sync(0xffffffffu,arc,__ffs(mask)-1),lastTile=__shfl_sync(0xffffffffu,arc,31u-__clz(mask));
            if(first==Invalid)first=firstTile;last=lastTile;}
    }
    if(!lane){b.first[node]=first;
        if(first!=Invalid)b.previous[0][first]=a.component[node]==node?Invalid:(last^1u);
    }
}
__device__ void jumpMotionTour(Input a,const unsigned* forest,MotionBuffers b,Status* status,unsigned source,unsigned thread,unsigned stride){
    const unsigned target=source^1u;
    for(unsigned arc=thread;arc<2*a.bonds;arc+=stride){
        if(!forest[arc/2])continue;const unsigned previous=b.previous[source][arc];
        MotionExact3 value=b.sum[source][arc];unsigned next=Invalid;
        if(previous!=Invalid){if(previous>=2*a.bonds || !forest[previous/2])atomicOr(&status->error,2u);
            else {value=exactMotionAdd(value,b.sum[source][previous],status);next=b.previous[source][previous];}}
        b.previous[target][arc]=next;b.sum[target][arc]=value;
    }
}
__device__ void publishMotionPositions(Input a,const unsigned* forest,MotionBuffers b,Status* status,unsigned source,unsigned thread,unsigned stride){
    for(unsigned arc=thread;arc<2*a.bonds;arc+=stride)if(forest[arc/2]){
        if(b.previous[source][arc]!=Invalid)atomicOr(&status->error,2u);
    }
    for(unsigned node=thread;node<a.nodes;node+=stride){
        const unsigned id=a.component[node];if(id==Invalid)continue;
        if(id!=node && b.first[node]==Invalid)atomicOr(&status->error,2u);
        if(b.first[node]!=Invalid && id!=node)b.position[node]=b.sum[source][b.first[node]^1u];
    }
}
// See StressMotionForest.cuh: a closure within 64 float epsilons (2^-17) of
// the cycle's own coordinate scale is rounding of the authored offsets. The
// double test scales by a power of two and compares exact values; so does
// this one. Leading terms carry each value to well within 2^-20, which decides
// every case outside that band; inside it the exact values are compared.
__device__ __forceinline__ bool motionClosureSignificant(const Input& a,MotionBuffers b,unsigned edge,MotionExact3 closure){
    const auto x=a.offset0[edge],y=a.offset1[edge];
    const auto p=b.position[a.node0[edge]],q=b.position[a.node1[edge]];
    const float offsets=fmaxf(fmaxf(fmaxf(fabsf(x.x),fabsf(x.y)),fmaxf(fabsf(x.z),fabsf(y.x))),fmaxf(fabsf(y.y),fabsf(y.z)));
    const float leadScale=fmaxf(offsets,fmaxf(fmaxf(fmaxf(fabsf(p.x.x[0]),fabsf(p.y.x[0])),fmaxf(fabsf(p.z.x[0]),fabsf(q.x.x[0]))),fmaxf(fabsf(q.y.x[0]),fabsf(q.z.x[0]))));
    const float leadMagnitude=fmaxf(fmaxf(fabsf(closure.x.x[0]),fabsf(closure.y.x[0])),fabsf(closure.z.x[0]));
    const float threshold=leadScale*0x1p-17f;
    if(leadMagnitude>threshold*(1+0x1p-20f))return true;
    if(leadMagnitude<threshold*(1-0x1p-20f))return false;
    MotionExact scale=motionMax(motionMax(motionMagnitude(p.x),motionMagnitude(p.y)),motionMagnitude(p.z));
    scale=motionMax(scale,motionMax(motionMax(motionMagnitude(q.x),motionMagnitude(q.y)),motionMagnitude(q.z)));
    scale=motionMax(scale,motionExact(offsets));
    const MotionExact magnitude=motionMax(motionMax(motionMagnitude(closure.x),motionMagnitude(closure.y)),motionMagnitude(closure.z));
    // Double's floor of 1e-30 is below every accepted nonzero value.
    return motionGreater(magnitude,motionScaled(scale,0x1p-17f));
}
__device__ void discoverMotionClosures(Input a,MotionBuffers b,Status* status,unsigned thread,unsigned stride){
    for(unsigned e=thread;e<a.bonds;e+=stride){if(a.health[e]<=0)continue;
        const unsigned u=a.component[a.node0[e]],v=a.component[a.node1[e]];
        if(u==Invalid && v==Invalid)continue;
        if(u==Invalid || v==Invalid){atomicExch(&b.components[u==Invalid?v:u].anchored,1u);continue;}
        if(u!=v){atomicOr(&status->error,1u);continue;}
        const auto closure=motionClosure(a,b,e,status);
        if(motionNonzero(closure) && motionClosureSignificant(a,b,e,closure))atomicMin(&b.components[u].closure,e);
    }
}
__device__ void initializeMotionAxes(Input a,MotionBuffers b,Status* status,unsigned thread,unsigned stride){
    for(unsigned node=thread;node<a.nodes;node+=stride)if(a.component[node]==node){auto& c=b.components[node];
        const unsigned count=a.partition.end[node]-a.partition.begin[node];
        if(c.edges+1!=count || (b.first[node]!=Invalid && c.cuts!=1) || (b.first[node]==Invalid && c.cuts))atomicOr(&status->error,2u);
        c.rotations=c.closure==Invalid?3u:1u;
        if(c.closure!=Invalid){auto axis=motionPair(motionClosure(a,b,c.closure,status));
            MotionPair maximum=motionAbs(axis.x);
            if(fabsf(axis.y.hi)>maximum.hi)maximum=motionAbs(axis.y);if(fabsf(axis.z.hi)>maximum.hi)maximum=motionAbs(axis.z);
            if(!(maximum.hi>0) || !motionFinite(maximum)){atomicOr(&status->error,4u);continue;}
            axis=mul(axis,motionDiv(motionPair(1.f),maximum));const MotionPair norm=motionSqrt(dot(axis,axis));
            c.axis=mul(axis,motionDiv(motionPair(1.f),norm));
            c.frameAxis=makeStressReal3(motionStressReal(c.axis.x),motionStressReal(c.axis.y),motionStressReal(c.axis.z));}
    }
}
__device__ void constrainMotionAxes(Input a,MotionBuffers b,Status* status,unsigned thread,unsigned stride){
    for(unsigned e=thread;e<a.bonds;e+=stride){if(a.health[e]<=0)continue;
        const unsigned id=a.component[a.node0[e]];if(id==Invalid || a.component[a.node1[e]]!=id)continue;
        const auto& c=b.components[id];if(c.anchored || c.closure==Invalid)continue;
        const auto seed=motionClosure(a,b,c.closure,status),value=motionClosure(a,b,e,status);
        // A rounding-sized closure is no constraint, collinear or not.
        if(!motionNonzero(value) || !motionClosureSignificant(a,b,e,value))continue;
        if(!motionCollinear(motionDouble(seed),motionDouble(value)))atomicExch(&b.components[id].rotations,0u);
    }
}
}}}
