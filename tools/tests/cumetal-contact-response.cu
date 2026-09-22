// Test the production publication helper and actual PGS/TGS header layouts.
#include <cuda_runtime.h>
#include "PxgConstraintBlock.h"
#include "../../physx/source/gpusolver/src/CUDA/PxgContactResponse.cuh"
#include <cstdio>
#include <cstring>
#include <stdexcept>
#include <vector>
using namespace physx;
constexpr unsigned batches=32, managers=34;
static const PxU64 epochs[]={0xffffffffull,0x100000000ull,0xfedcba9876543210ull,~PxU64(0)};
void check(cudaError_t e) { if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e)); }
template<class T> struct Device {
    T* p;
    explicit Device(size_t n) {check(cudaMalloc(&p,n*sizeof(T)));}
    ~Device() {cudaFree(p);}
};
__global__ void prepare(PxgSolverCoreDesc* desc,PxgBlockSolverContactHeader* pgs,
    PxgTGSBlockSolverContactHeader* tgs,const PxU64* epoch,const unsigned* phase) {
    const unsigned n=blockIdx.x*blockDim.x+threadIdx.x,lane=n%32,batch=n/32;
    const unsigned manager=(lane*7)%32;
    const unsigned mode=(manager+*phase)%4;
    if(n==0)desc->nativeResponseEpoch=epoch[*phase];
    pgs[batch].numNormalConstr[lane]=tgs[batch].numNormalConstr[lane]=mode==0?0:3;
    pgs[batch].forceWritebackOffset[lane]=tgs[batch].forceWritebackOffset[lane]=mode==1?0xffffffffu:lane;
}
template<class Header>
__global__ void publish(const PxgSolverCoreDesc* desc,const PxgBlockConstraintBatch* batchesData,const Header* headers) {
    const unsigned n=blockIdx.x*blockDim.x+threadIdx.x;
    publishContactResponse(*desc,batchesData[n/32],headers[n/32],n%32);
}
__global__ void observe(const PxsContactManagerOutput* output,unsigned char* snapshots,unsigned* phase) {
    const auto* bytes=reinterpret_cast<const unsigned char*>(output);
    const unsigned count=managers*sizeof(PxsContactManagerOutput);
    for(unsigned i=0;i<count;++i)snapshots[*phase*count+i]=bytes[i];
    ++*phase; // one observer thread, after all publication writers have joined
}
int main() {
 try {
    Device<PxsContactManagerOutput> outputs(managers);
    Device<PxgBlockWorkUnit> units(batches);
    Device<PxgBlockConstraintBatch> batchData(batches);
    Device<PxgBlockSolverContactHeader> pgs(batches);
    Device<PxgTGSBlockSolverContactHeader> tgs(batches);
    Device<PxgSolverCoreDesc> descriptor(1);
    Device<PxU64> epoch(4);
    Device<unsigned> phase(1);
    Device<unsigned char> snapshots(4*managers*sizeof(PxsContactManagerOutput));
    std::vector<PxsContactManagerOutput> expected(managers);
    std::memset(expected.data(),0xa5,expected.size()*sizeof(expected[0]));
    for(unsigned i=0;i<managers;++i)expected[i].nativeResponseEpoch=0x123456789abcdef0ull+i;
    std::vector<PxgBlockWorkUnit> work(batches);
    std::vector<PxgBlockConstraintBatch> batchesHost(batches);
    for(unsigned b=0;b<batches;++b) {
        batchesHost[b].mConstraintBatchIndex=b;
        for(unsigned lane=0;lane<32;++lane)work[b].mContactManagerOutputIndex[lane]=1+(lane*7)%32;
    }
    PxgSolverCoreDesc desc{};desc.nativeContactWorkUnits=units.p;desc.contactManagerOutputBase=outputs.p;
    unsigned zero=0;
    check(cudaMemcpy(outputs.p,expected.data(),expected.size()*sizeof(expected[0]),cudaMemcpyHostToDevice));
    check(cudaMemcpy(units.p,work.data(),work.size()*sizeof(work[0]),cudaMemcpyHostToDevice));
    check(cudaMemcpy(batchData.p,batchesHost.data(),batchesHost.size()*sizeof(batchesHost[0]),cudaMemcpyHostToDevice));
    check(cudaMemcpy(descriptor.p,&desc,sizeof(desc),cudaMemcpyHostToDevice));
    check(cudaMemcpy(epoch.p,epochs,sizeof(epochs),cudaMemcpyHostToDevice));
    check(cudaMemcpy(phase.p,&zero,sizeof(zero),cudaMemcpyHostToDevice));
    cudaStream_t left,right,reader;
    check(cudaStreamCreateWithFlags(&left,cudaStreamNonBlocking));
    check(cudaStreamCreateWithFlags(&right,cudaStreamNonBlocking));
    check(cudaStreamCreateWithFlags(&reader,cudaStreamNonBlocking));
    cudaEvent_t ready,pgsDone,tgsDone;
    check(cudaEventCreateWithFlags(&ready,cudaEventDisableTiming));
    check(cudaEventCreateWithFlags(&pgsDone,cudaEventDisableTiming));
    check(cudaEventCreateWithFlags(&tgsDone,cudaEventDisableTiming));
    check(cudaEventRecord(ready));check(cudaStreamWaitEvent(left,ready));
    cudaGraph_t graph;cudaGraphExec_t exec;
    check(cudaStreamBeginCapture(left,cudaStreamCaptureModeGlobal));
    prepare<<<8,128,0,left>>>(descriptor.p,pgs.p,tgs.p,epoch.p,phase.p);
    publish<<<8,128,0,left>>>(descriptor.p,batchData.p,pgs.p);
    publish<<<8,128,0,left>>>(descriptor.p,batchData.p,tgs.p);
    observe<<<1,1,0,left>>>(outputs.p,snapshots.p,phase.p);
    check(cudaStreamEndCapture(left,&graph));check(cudaGraphInstantiate(&exec,graph,nullptr,nullptr,0));
    for(unsigned i=0;i<3;++i)check(cudaGraphLaunch(exec,left));
    // The fourth pass has PGS/TGS writers on separate streams. Readers join
    // both; preparation joins all previous readers before changing the epoch.
    prepare<<<8,128,0,left>>>(descriptor.p,pgs.p,tgs.p,epoch.p,phase.p);
    check(cudaEventRecord(ready,left));check(cudaStreamWaitEvent(right,ready));
    publish<<<8,128,0,left>>>(descriptor.p,batchData.p,pgs.p);
    publish<<<8,128,0,right>>>(descriptor.p,batchData.p,tgs.p);
    check(cudaEventRecord(pgsDone,left));check(cudaEventRecord(tgsDone,right));
    check(cudaStreamWaitEvent(reader,pgsDone));check(cudaStreamWaitEvent(reader,tgsDone));
    observe<<<1,1,0,reader>>>(outputs.p,snapshots.p,phase.p);
    check(cudaGetLastError());
    std::vector<unsigned char> actual(4*managers*sizeof(PxsContactManagerOutput));
    unsigned observedPhases=0;
    check(cudaMemcpyAsync(actual.data(),snapshots.p,actual.size(),cudaMemcpyDeviceToHost,reader));
    check(cudaMemcpyAsync(&observedPhases,phase.p,sizeof(observedPhases),cudaMemcpyDeviceToHost,reader));
    check(cudaStreamSynchronize(reader));
    if(observedPhases!=4)throw std::runtime_error("response capture lost or duplicated a pass");
    for(unsigned pass=0;pass<4;++pass) {
        for(unsigned manager=0;manager<32;++manager)
            if((manager+pass)%4>=2)expected[manager+1].nativeResponseEpoch=epochs[pass];
        const size_t count=expected.size()*sizeof(expected[0]);
        if(std::memcmp(actual.data()+pass*count,expected.data(),count))
            throw std::runtime_error("response stamp changed guarded bytes, skipped contacts or the exact 64-bit epoch");
    }
    check(cudaGraphExecDestroy(exec));check(cudaGraphDestroy(graph));
    check(cudaStreamDestroy(left));check(cudaStreamDestroy(right));check(cudaStreamDestroy(reader));
    check(cudaEventDestroy(ready));check(cudaEventDestroy(pgsDone));check(cudaEventDestroy(tgsDone));
    std::puts("PASS: production PGS/TGS response stamps, contending patch writers, unchanged skipped contacts/guard bytes, full 64-bit epochs, three queued replays and event-joined readers");
    return 0;
 } catch(const std::exception& e) {std::fprintf(stderr,"%s\n",e.what());return 1;}
}
