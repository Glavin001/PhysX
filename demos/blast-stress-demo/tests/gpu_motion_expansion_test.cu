// Exercise the production expansion on the device, including the low terms a
// single binary64 conversion cannot preserve. The separate Python rational
// oracle covers a wider deterministic corpus without duplicating this code.
#include "detail/StressMotionPair.cuh"
#include <cstdio>
using namespace Nv::Blast::StressHierarchy;
__global__ void checkExpansion(unsigned* result){
    bool exact=true;
    const auto one=motionExact(1.f),two=motionExact(2.f),zero=motionExact(0.f);
    const auto tiny=motionExact(1e-18f),shifted=motionExactDifference(1.f,1e-18f,exact);
    result[0]=exact;
    const auto recovered=motionExactAdd(shifted,neg(one),exact);
    result[1]=exact && recovered.x[0]==-1e-18f && recovered.x[1]==0 && recovered.x[2]==0;
    result[2]=!motionProductEqual(shifted,one,one,one);
    result[3]=motionProductEqual(shifted,two,two,shifted);
    result[4]=motionProductEqual(motionScaled(shifted,2.f),one,shifted,two);
    result[5]=motionGreater(one,shifted) && !motionGreater(shifted,one);
    const MotionExact3 a{shifted,one,zero},b{one,one,zero};
    result[6]=!motionCollinear(a,b);
    result[7]=motionCollinear(a,{motionScaled(shifted,2.f),two,zero});
    result[8]=motionCollinear({zero,zero,zero},{one,tiny,two});
    const MotionExact wide{{1.f,0x1p-28f,0x1p-56f}};
    exact=true;const auto fourth=motionExactAdd(wide,motionExact(0x1p-84f),exact);
    result[9]=exact && fourth.x[0]==1.f && fourth.x[1]==0x1p-28f && fourth.x[2]==0x1p-56f && fourth.x[3]==0x1p-84f;
    const MotionExact signedLow{{1.f,-0x1p-50f,0x1p-95f}};
    result[10]=!motionProductEqual(signedLow,one,MotionExact{{1.f,-0x1p-50f,0.f}},one);
    result[11]=motionProductEqual(signedLow,shifted,shifted,signedLow);
}
int main(){
    unsigned* device=nullptr,results[12]{};
    cudaError_t error=cudaMalloc(&device,sizeof(results));
    if(error==cudaSuccess){checkExpansion<<<1,1>>>(device);error=cudaGetLastError();}
    if(error==cudaSuccess)error=cudaMemcpy(results,device,sizeof(results),cudaMemcpyDeviceToHost);
    cudaFree(device);
    if(error!=cudaSuccess){std::fprintf(stderr,"CUDA arithmetic test: %s\n",cudaGetErrorString(error));return 1;}
    for(unsigned i=0;i<12;++i)if(results[i]!=1){std::fprintf(stderr,"Expansion predicate %u failed\n",i);return 1;}
    std::puts("PASS: 12 exact motion expansion device predicates");return 0;
}
