// Exercise production publication independently of physical trajectory chaos.
#include "PxDestructionScene.h"
#include "NvBlastExtStressGpu.h"
#include <cuda_runtime.h>
#include <cub/cub.cuh>
#include <algorithm>
#include <climits>
#include <cstdio>
#include <stdexcept>
#include <vector>
namespace physx { namespace {
using namespace Nv::Blast;
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T>void allocate(T*& p,size_t n){check(cudaMalloc(&p,std::max(size_t(1),n)*sizeof(T)));}
#include "../src/PxgDestructionCommittedChanges.cuh"
void require(bool ok,const char* text){if(!ok)throw std::runtime_error(text);}
template<class T>struct Device {
    T* p=nullptr;explicit Device(size_t n){allocate(p,n);check(cudaMemset(p,0,n*sizeof(T)));}
    ~Device(){cudaFree(p);}
    void put(const std::vector<T>& v){check(cudaMemcpy(p,v.data(),v.size()*sizeof(T),cudaMemcpyHostToDevice));check(cudaStreamSynchronize(nullptr));}
    std::vector<T> get(size_t n){std::vector<T> v(n);check(cudaMemcpy(v.data(),p,n*sizeof(T),cudaMemcpyDeviceToHost));return v;}
};
struct Topology {
    Device<PxU32> active{8},bonds{6},roots{8},slots{8};Device<PxU64> generations{8};Device<PxDestructionTopologyStatus> status{1};
    PxDestructionTopologyDeviceView view{};
    Topology(){view.activeChunks=active.p;view.activeBonds=bonds.p;view.chunkCluster=roots.p;view.clusterSlots=slots.p;view.slotGenerations=generations.p;
        view.status=status.p;view.chunkCount=8;view.bondCount=6;view.slotCapacity=8;}
    void set(const std::vector<PxU32>& labels,const std::vector<PxU32>& live,PxU64 generation,PxU32 clusters){
        active.put(std::vector<PxU32>(8,1));bonds.put(live);roots.put(labels);slots.put({0,1,2,3,4,5,6,7});generations.put({1,2,3,4,5,6,7,8});
        status.put({{generation,clusters,0,0,0}});
    }
};
void test(){
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    Topology before,after;const std::vector<PxU32> original={0,0,0,0,4,4,4,4};std::vector<PxU32> live(6,1);
    before.set(original,live,1,2);after.set(original,live,1,2);
    Device<PxDestructionStageStatus> stage(1);Device<PxDestructionTopologyTransactionStatus> transaction(1);Device<PxU32> accept(1),affected(3);
    Device<PxDestructionStressChunk> chunks(8);std::vector<PxDestructionStressChunk> inputs(8);
    for(unsigned i=0;i<8;++i)inputs[i].cluster=i/4;chunks.put(inputs);affected.put({0,0,0});accept.put({1});transaction.put({{0,0,1,0,1,1}});
    PxDestructionStageStatus frame{};frame.frame=1;stage.put({frame});
    committedChanges::Publication publication;publication.initialize(before.view,stage.p,nullptr,stream);
    publication.start(before.view,stage.p,stream);publication.publish(stream);check(cudaStreamSynchronize(stream));
    auto view=publication.view();PxDestructionCommittedChangesStatus status{};
    auto read=[&]{check(cudaStreamSynchronize(stream));check(cudaMemcpy(&status,view.status,sizeof(status),cudaMemcpyDeviceToHost));};read();
    require(status.fullSnapshot && status.frame==1 && status.chunkCount==8 && !status.bondCount,"initial snapshot incorrect");
    std::vector<PxDestructionChangedChunk> rows(8);check(cudaMemcpy(rows.data(),view.chunks,rows.size()*sizeof(rows[0]),cudaMemcpyDeviceToHost));
    for(unsigned i=0;i<8;++i)require(rows[i].chunk==i && rows[i].root==original[i] && rows[i].generation==original[i]+1,"initial identity incorrect");
    frame.frame=2;stage.put({frame});publication.start(before.view,stage.p,stream);
    accept.put({0});live[0]=0;after.set(original,live,2,2);
    publication.commit(before.view,after.view,transaction.p,accept.p,chunks.p,affected.p,stream);publication.publish(stream);read();
    require(status.frame==2 && !status.chunkCount && !status.bondCount,"rejected trial published events");
    // A cycle cut publishes a bond event without fake membership changes.
    accept.put({1});frame.brokenBonds=1;stage.put({frame});
    publication.commit(before.view,after.view,transaction.p,accept.p,chunks.p,affected.p,stream);check(cudaStreamSynchronize(stream));
    before.set(original,live,2,2);publication.publish(stream);read();
    require(!status.chunkCount && status.bondCount==1,"cycle cut changed membership or lost bond");
    PxU32 bond=99;check(cudaMemcpy(&bond,view.brokenBonds,sizeof(bond),cudaMemcpyDeviceToHost));require(!bond,"wrong cycle-cut bond");
    // Two commits in the SAME frame: the retained source changes COM twice.
    frame.frame=3;frame.brokenBonds=0;stage.put({frame});publication.start(before.view,stage.p,stream);check(cudaStreamSynchronize(stream));
    std::vector<PxU32> first={0,0,2,2,4,4,4,4};live[1]=0;after.set(first,live,3,3);affected.put({1,0,0});
    publication.commit(before.view,after.view,transaction.p,accept.p,chunks.p,affected.p,stream);check(cudaStreamSynchronize(stream));before.set(first,live,3,3);
    for(unsigned i=0;i<8;++i)inputs[i].cluster=i<2?0:(i<4?1:2);chunks.put(inputs);
    std::vector<PxU32> second={0,1,2,2,4,4,4,4};live[2]=0;after.set(second,live,4,4);
    publication.commit(before.view,after.view,transaction.p,accept.p,chunks.p,affected.p,stream);check(cudaStreamSynchronize(stream));before.set(second,live,4,4);
    frame.brokenBonds=2;frame.stressPasses=2;frame.correctionPasses=1;stage.put({frame});publication.publish(stream);read();
    require(status.frame==3 && !status.fullSnapshot && status.chunkCount==4 && status.bondCount==2 && status.topologyGeneration==4,"two-pass delta incorrect");
    rows.resize(4);check(cudaMemcpy(rows.data(),view.chunks,rows.size()*sizeof(rows[0]),cudaMemcpyDeviceToHost));
    for(unsigned i=0;i<4;++i)require(rows[i].chunk==i && rows[i].root==second[i] && rows[i].generation==second[i]+1,"retained/migrating final identity incorrect");
    PxU32 broken[2];check(cudaMemcpy(broken,view.brokenBonds,sizeof(broken),cudaMemcpyDeviceToHost));require(broken[0]==1 && broken[1]==2,"duplicate or missing two-pass bond");
    frame.frame=4;frame.brokenBonds=0;stage.put({frame});publication.start(before.view,stage.p,stream);publication.publish(stream);read();
    require(status.frame==4 && !status.chunkCount && !status.bondCount,"quiet frame repeated prior events");
    frame.error=32;frame.brokenBonds=1;stage.put({frame});publication.publish(stream);read();
    require(status.error==32 && !status.chunkCount && !status.bondCount,"failed frame published accepted data");
    publication.clear();
    before.set(original,std::vector<PxU32>(6,1),1,2);frame={};frame.frame=1;stage.put({frame});
    publication.initialize(before.view,stage.p,nullptr,stream);publication.start(before.view,stage.p,stream);publication.publish(stream);
    view=publication.view();read();require(status.fullSnapshot && status.chunkCount==8 && !status.bondCount,"reinitialization retained stale events");
    publication.clear();
    auto excessive=before.view;excessive.chunkCount=unsigned(INT_MAX)+1u;bool rejected=false;
    try{publication.initialize(excessive,stage.p,nullptr,stream);}catch(const std::runtime_error&){rejected=true;}
    require(rejected,"unsupported publication capacity accepted");publication.clear();check(cudaStreamDestroy(stream));
    std::puts("committed changes: 8 chunks / 6 bonds; initial, quiet, rejected, cycle-cut, two-pass union, stable identities, failed-step passed");
}
}}
int main(){try{physx::test();return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
