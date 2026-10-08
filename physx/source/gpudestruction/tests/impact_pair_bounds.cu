// The corrected pass's contact bounds act on contact pairs, not bodies.
//
// The impact step evaluates the pairs of its rows (an impactor against the
// anchored chunks it struck) and bounds what the corrected pass may deliver
// there: the impulse per point the step delivered. A rigid body's max contact
// impulse holds for every contact it has (contactConstraintBlockPrep.cuh took
// the smaller of the two bodies'), so the impactor's bound also capped its
// contacts with debris, the ground and anchored chunks new in the corrected
// pass, none of which the step evaluated. The framed-house truck then pushed
// through debris it could not carry and ended +10..+17 m past the front wall
// (h2, h3; 8e9006545), against 0.7 m when its bound was large (h1).
//
// Each case below is a pair of bodies as boundImpactContacts leaves them
// (applyImpactBounds' encoding) and the max impulse per point the solver must
// use. IMPACT_PAIR_RULE_MIN=1 evaluates the per-body rule this replaced (the
// impactor's bound b on the body, PxMin of the pair): it fails the
// unevaluated pairs, the reproducer.
#include "PxgContactPairMaxImpulse.h"
#include "PxgAnchoredContactBound.h"
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>
#include <cmath>

using namespace physx;

namespace {
constexpr float kDefault=1e32f;   // PxsBodyCore's max contact impulse: none of its own
constexpr float kBound=1250.0f;   // an impactor's bound, N s per point
struct Case { const char* name; float m0,m1; float old0,old1; float want; };

__global__ void evaluate(const Case* c,float* out,PxU32 n,bool old)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    out[i]=old?PxMin(c[i].old0,c[i].old1):contactPairMaxImpulse(c[i].m0,c[i].m1);
}
}

int main()
{
    const bool old=std::getenv("IMPACT_PAIR_RULE_MIN") && std::strcmp(std::getenv("IMPACT_PAIR_RULE_MIN"),"0")!=0;
    // pairwise encoding (m0, m1) / the per-body rule's (old0, old1) / wanted
    const std::vector<Case> cases={
        {"impactor against a cluster it struck",   -kBound,-PX_MAX_F32, kBound,kDefault, kBound},
        {"struck cluster against its impactor",    -PX_MAX_F32,-kBound, kDefault,kBound, kBound},
        {"impactor against debris (dynamic)",      -kBound,kDefault,    kBound,kDefault, kDefault},
        {"impactor against the ground (static)",   -kBound,PX_MAX_F32,  kBound,PX_MAX_F32, PX_MAX_F32},
        {"impactor against an unstruck cluster",   -kBound,kDefault,    kBound,kDefault, kDefault},
        {"two bounded impactors",                  -kBound,-2.0f*kBound, kBound,2.0f*kBound, PX_MAX_F32},
        {"struck cluster against debris",          -PX_MAX_F32,kDefault, kDefault,kDefault, kDefault},
        {"impactor against debris with its own bound", -kBound,300.0f,  kBound,300.0f, 300.0f},
        {"ordinary bodies (PhysX's own rule)",     500.0f,700.0f,       500.0f,700.0f, 500.0f},
    };
    const PxU32 n=PxU32(cases.size());
    Case* dc=nullptr;float* dout=nullptr;
    if(cudaMalloc(&dc,sizeof(Case)*n)!=cudaSuccess || cudaMalloc(&dout,sizeof(float)*n)!=cudaSuccess){std::printf("cuda allocation failed\n");return 2;}
    cudaMemcpy(dc,cases.data(),sizeof(Case)*n,cudaMemcpyHostToDevice);
    evaluate<<<1,64>>>(dc,dout,n,old);
    if(cudaDeviceSynchronize()!=cudaSuccess){std::printf("kernel failed\n");return 2;}
    std::vector<float> out(n);cudaMemcpy(out.data(),dout,sizeof(float)*n,cudaMemcpyDeviceToHost);
    int failed=0;
    for(PxU32 i=0;i<n;++i) {
        const float host=old?PxMin(cases[i].old0,cases[i].old1):contactPairMaxImpulse(cases[i].m0,cases[i].m1);
        const bool ok=out[i]==cases[i].want && host==cases[i].want;
        failed+=!ok;
        std::printf("%s %-46s %.4g (want %.4g)\n",ok?"ok  ":"FAIL",cases[i].name,out[i],cases[i].want);
    }
    std::printf("contact pair bounds (%s rule): %d of %u cases wrong\n",old?"per-body":"pairwise",failed,n);
    cudaFree(dc);cudaFree(dout);
    // The anchored-chunk bound (PxgAnchoredContactBound.h): a 0.073 m^3, 139 kg
    // brick chunk with 0.12 MN of bonds, dt 1/60 s, struck at 60 m/s along the
    // normal on 2 points: (0.12e6 / 60 + 139 * 60) / 2 per point.
    if(!old) {
        const float dt=1.0f/60.0f,C=0.12e6f,m=139.0f;
        const PxU32 inputs[12]={0,0,7,9, 0,0,9,7, 0,0,5,9};   // shape 7: the chunk; 9, 5: no chunk
        const PxU32 map[2]={7,0};const float chunks[4]={C*dt,m,0,0};
        PxgAnchoredContactBoundView hv{};hv.inputs=inputs;hv.map=map;hv.mapCount=1;hv.chunkCount=1;hv.chunks=chunks;
        const PxVec3 n(0,0,1),still(0),fast(0,0,-60);
        const float want=(C*dt+m*60.0f)/2.0f;
        struct A { const char* name; PxU32 cm; bool k0,k1; PxVec3 v0,v1; float want; };
        const A a[]={
            {"ball against the anchored chunk (chunk side 0)",0,true,false,still,fast,want},
            {"the same pair, chunk side 1",1,false,true,fast,still,want},
            {"ball against a dynamic chunk (no kinematic side)",0,false,false,still,fast,PX_MAX_F32},
            {"kinematic body that is no chunk",2,true,false,still,fast,PX_MAX_F32},
            {"separating at 60 m/s (the closing speed either sense)",0,true,false,still,PxVec3(0,0,60),want},
            {"at rest: the bonds' capacity alone",0,true,false,still,still,C*dt/2.0f},
        };
        int bad=0;
        for(const A& c:a) {
            const float got=anchoredContactPointBound(hv,c.cm,c.k0,c.k1,c.v0,c.v1,n,2);
            const bool ok=std::fabs(got-c.want)<=1e-6f*c.want;bad+=!ok;
            std::printf("%s %-54s %.6g (want %.6g)\n",ok?"ok  ":"FAIL",c.name,got,c.want);
        }
        std::printf("anchored contact bound: %d of %zu cases wrong\n",bad,sizeof a/sizeof a[0]);
        failed+=bad;
    }
    return failed?1:0;
}
