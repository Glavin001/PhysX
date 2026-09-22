// Derive component coordinates from the actual live bond equations. Authored
// positions are deliberately not used: rounded offsets can retain real moments.
#pragma once
#include "StressHierarchyOperator.cuh"
namespace Nv { namespace Blast { namespace StressHierarchy {
struct MotionComponent {
    unsigned anchored,rotations,closure,cuts,edges;
    double3 center,axis;
    double factor[21],scale[6];
};
struct MotionBuffers {
    unsigned *previous[2],*first;
    double3 *sum[2],*position;
    MotionComponent* components;
};
// The topology predicates require exact sums of their finite float inputs.
// Detect loss of representable information; never erase a small cycle moment.
// A failed numerical construction remains an explicit incomplete transaction.
__device__ __forceinline__ double exactMotionAdd(double a,double b,Status* status){
    const double sum=__dadd_rn(a,b),virtualB=__dsub_rn(sum,a);
    const double error=__dadd_rn(__dsub_rn(a,__dsub_rn(sum,virtualB)),__dsub_rn(b,virtualB));
    if(error!=0 || !isfinite(sum))atomicOr(&status->error,16u);return sum;
}
__device__ __forceinline__ double3 exactMotionAdd(double3 a,double3 b,Status* status){
    return {exactMotionAdd(a.x,b.x,status),exactMotionAdd(a.y,b.y,status),exactMotionAdd(a.z,b.z,status)};
}
__device__ __forceinline__ double3 motionOffset(const Input& a,unsigned edge,Status* status){
    const auto x=a.offset0[edge],y=a.offset1[edge];
    return {exactMotionAdd(double(x.x),-double(y.x),status),exactMotionAdd(double(x.y),-double(y.y),status),exactMotionAdd(double(x.z),-double(y.z),status)};
}
__device__ __forceinline__ double3 motionClosure(const Input& a,MotionBuffers b,unsigned edge,Status* status){
    return exactMotionAdd(exactMotionAdd(b.position[a.node0[edge]],motionOffset(a,edge,status),status),mul(b.position[a.node1[edge]],-1),status);
}
__device__ __forceinline__ bool motionNonzero(double3 v){return v.x!=0 || v.y!=0 || v.z!=0;}
// Compare exact double products, including their FMA residuals. Comparing only
// rounded cross products could classify a small, real closure as collinear.
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
        const auto delta=motionOffset(a,edge,status);b.sum[0][2*edge]=delta;b.sum[0][2*edge+1]=mul(delta,-1);
    }
}
// One warp per vertex constructs its cyclic outgoing tree-edge order. Ballots
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
        double3 value=b.sum[source][arc];unsigned next=Invalid;
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
// Whether a cycle's closure is a real moment or the rounding of its offsets.
// Bond offsets arrive as float differences of authored positions, so a cycle
// that closes exactly in real arithmetic leaves a residue of a few float ulps
// of the positions involved. Counting that residue as a moment constrains a
// free fragment's rotation to a near-zero eigenvalue the projection never
// removes, and CG runs away along it. A closure within 64 float epsilons of
// the cycle's own coordinate scale is treated as closed; anything that large
// relative to single-precision input cannot come from the authored geometry.
__device__ __forceinline__ bool motionClosureSignificant(const Input& a,MotionBuffers b,unsigned edge,double3 closure){
    const auto x=a.offset0[edge],y=a.offset1[edge];
    const auto p=b.position[a.node0[edge]],q=b.position[a.node1[edge]];
    const double scale=fmax(fmax(fmax(fabs(p.x),fabs(p.y)),fmax(fabs(p.z),fabs(q.x))),fmax(fmax(fabs(q.y),fabs(q.z)),
        fmax(fmax(fabs(double(x.x)),fabs(double(x.y))),fmax(fabs(double(x.z)),fmax(fabs(double(y.x)),fmax(fabs(double(y.y)),fabs(double(y.z))))))));
    const double magnitude=fmax(fabs(closure.x),fmax(fabs(closure.y),fabs(closure.z)));
    return magnitude>64.0*1.1920928955078125e-7*fmax(scale,1e-30);
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
        if(c.closure!=Invalid){auto axis=motionClosure(a,b,c.closure,status);const double maximum=fmax(fabs(axis.x),fmax(fabs(axis.y),fabs(axis.z)));
            if(!(maximum>0) || !isfinite(maximum)){atomicOr(&status->error,4u);continue;}
            axis=mul(axis,1/maximum);const double norm=sqrt(axis.x*axis.x+axis.y*axis.y+axis.z*axis.z);c.axis=mul(axis,1/norm);}
    }
}
__device__ void constrainMotionAxes(Input a,MotionBuffers b,Status* status,unsigned thread,unsigned stride){
    for(unsigned e=thread;e<a.bonds;e+=stride){if(a.health[e]<=0)continue;
        const unsigned id=a.component[a.node0[e]];if(id==Invalid || a.component[a.node1[e]]!=id)continue;
        const auto& c=b.components[id];if(c.anchored || c.closure==Invalid)continue;
        const auto seed=motionClosure(a,b,c.closure,status),value=motionClosure(a,b,e,status);
        // A rounding-sized closure is no constraint, collinear or not.
        if(!motionNonzero(value) || !motionClosureSignificant(a,b,e,value))continue;
        if(!motionCollinear(seed,value))atomicExch(&b.components[id].rotations,0u);
    }
}
}}}
