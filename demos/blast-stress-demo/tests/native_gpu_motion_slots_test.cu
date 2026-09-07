// Exercise the production CUDA allocation kernels, including rejected transactions.
#include "PxDestructionScene.h"
#include "PxvDestructionBodyAllocator.h"
#include <cuda_runtime.h>
#include <cstdio>
#include <stdexcept>
namespace physx {
constexpr PxU32 PX_INVALID_U32=0xffffffffu;
#include "PxgDestructionMotionSlots.cuh"
}
using namespace physx;
namespace {
void require(bool ok,const char* message) {if(!ok)throw std::runtime_error(message);}
void check(cudaError_t error) {if(error!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(error));}
struct State {
    PxDestructionMotionSlotStatus pool{};
    PxDestructionBodyPreparationStatus preparation{};
    PxDestructionBodyAllocationStatus allocation{};
    PxDestructionStageStatus stage{};
    PxvDestructionBodyRequest requests[3]{};
    PxU32 granted[4]{19,31,7,42},selected[3]{},candidates[5]{};
};
State run(State initial,PxU32 capacity,PxU32 count,bool registered,bool accept) {
    State* device=nullptr;check(cudaMalloc(&device,sizeof(State)));
    try {
        check(cudaMemcpy(device,&initial,sizeof(initial),cudaMemcpyHostToDevice));
        beginNativeMotionSlots<<<1,1>>>(&device->pool,capacity,&device->preparation,count,&device->allocation);
        if(count)assignNativeMotionSlots<<<1,32>>>(&device->pool,device->granted,device->requests,count,
            device->selected,device->candidates,&device->allocation);
        finishNativeMotionSlots<<<1,1>>>(&device->allocation,&device->stage);
        finishNativeBodyShadowRegistration<<<1,1>>>(registered,&device->allocation,&device->stage);
        if(accept)commitNativeMotionSlots<<<1,1>>>(&device->pool,&device->stage);
        check(cudaGetLastError());State result;
        check(cudaMemcpy(&result,device,sizeof(result),cudaMemcpyDeviceToHost));check(cudaFree(device));return result;
    }catch(...){cudaFree(device);throw;}
}
State fixture() {
    State s;s.pool.committed=1;s.preparation.valid=1;s.preparation.generation=17;
    s.preparation.count=5;s.preparation.allocationRequests=2;
    s.requests[0]={9,3,0,1,4};s.requests[1]={10,3,1,1,1};
    for(auto& id:s.candidates)id=3;
    return s;
}
}
int main() {
    try {
        cudaDeviceProp properties{};check(cudaGetDeviceProperties(&properties,0));
        require(properties.major==8 && properties.minor==9,"incompatible device: sm_89 required");
        const auto initial=fixture();const auto trial=run(initial,4,2,true,false);
        require(trial.allocation.valid && !trial.allocation.error && trial.allocation.generation==17
            && trial.pool.committed==1 && trial.pool.pending==2,"trial allocation committed early");
        require(trial.selected[0]==31 && trial.selected[1]==7 && trial.candidates[4]==31
            && trial.candidates[1]==7 && trial.candidates[0]==3 && trial.candidates[2]==3,
            "allocation lost stable request order or changed retained motion");
        const auto retry=run(trial,4,2,true,false);
        require(retry.selected[0]==31 && retry.selected[1]==7 && retry.pool.committed==1,"retry consumed motion slots twice");
        const auto accepted=run(trial,4,2,true,true);
        require(accepted.pool.committed==3 && !accepted.pool.pending,"acceptance failed to consume precisely the selected slots");
        const auto exhausted=run(initial,2,2,true,true);
        require(!exhausted.allocation.valid && (exhausted.allocation.error&1) && exhausted.stage.error
            && exhausted.pool.committed==1 && exhausted.selected[0]==PX_INVALID_U32
            && exhausted.candidates[4]==3,"exhausted capacity truncated or committed an allocation");
        auto invalid=initial;invalid.preparation.allocationRequests=1;
        const auto mismatch=run(invalid,4,2,true,true);
        require((mismatch.allocation.error&2) && mismatch.pool.committed==1,"count mismatch accepted");
        invalid=initial;invalid.requests[1].candidateSlot=5;
        const auto badMapping=run(invalid,4,2,true,true);
        require((badMapping.allocation.error&4) && !badMapping.allocation.valid && badMapping.pool.committed==1,
            "invalid candidate mapping accepted");
        const auto failedRecords=run(initial,4,2,false,true);
        require((failedRecords.allocation.error&8) && failedRecords.pool.committed==1,"failed compatibility registration committed slots");
        invalid=initial;invalid.pool.committed=5;
        require(run(invalid,4,2,true,true).allocation.error&1,"invalid committed cursor wrapped capacity arithmetic");
        invalid=initial;invalid.preparation.allocationRequests=0;
        const auto empty=run(invalid,4,0,true,true);
        require(empty.allocation.valid && empty.pool.committed==1 && !empty.pool.pending,"empty transaction consumed capacity");
        std::puts("GPU native slots: stable assignment, retained owners, retry, commit, exhaustion, invalid mapping and registration rejection passed");
        return 0;
    }catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}
}
