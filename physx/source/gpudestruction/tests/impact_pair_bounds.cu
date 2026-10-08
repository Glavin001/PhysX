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
#include <cuda_runtime.h>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <vector>

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
    return failed?1:0;
}
