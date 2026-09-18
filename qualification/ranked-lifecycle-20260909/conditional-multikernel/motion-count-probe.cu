#define main fixture_main
#include "/root/workspace/physx-2/physx/source/gpudestruction/tests/motion_slots_test.cu"
#undef main
int main(int argc,char**){
 Fixture f(1);f.requests[0]={0,7,0,1,0};f.reset(1,1);put(f.allocation,PxDestructionBodyAllocationStatus{});
 auto offsets=make<PxU32>();auto addresses=make<NativeMotionAddresses>();put(addresses,NativeMotionAddresses{f.granted,33});
 NativeMotionAllocationView v{f.pool,addresses,f.prep,f.input,f.compact,f.selected,f.owners,offsets,f.allocation,f.stage,1,1};
 if(argc>1){for(unsigned i=0;i<10;++i){f.reset(i%2,i%2,11);f.run(33);}}else{countNativeMotionRequests<<<1,128>>>(v);CUDA(cudaDeviceSynchronize());CHECK(get(offsets)==1);}
 CUDA(cudaFree(offsets));CUDA(cudaFree(addresses));
}
