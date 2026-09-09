// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included after the runtime CUDA allocation/error helpers. The native body
// record owns settings; the existing PhysX host launch loop consumes only maxima.
struct NativeIterationLimits { PxU32 position,velocity,error; };
struct MergeIterationLimits {
    __device__ NativeIterationLimits operator()(NativeIterationLimits a,NativeIterationLimits b)const {
        return {max(a.position,b.position),max(a.velocity,b.velocity),a.error|b.error};
    }
};
__global__ void reduceNativeIterationLimits(const PxgBodySim* bodies,PxU32 capacity,
    const PxNodeIndex* active,PxU32 offset,PxU32 count,NativeIterationLimits* partials) {
    NativeIterationLimits value{};
    for(PxU64 i=PxU64(blockIdx.x)*blockDim.x+threadIdx.x;i<count;i+=PxU64(gridDim.x)*blockDim.x) {
        const auto node=active[PxU64(offset)+i];
        if(!node.isValid() || node.isArticulation() || node.index()>=capacity) {value.error|=1u;continue;}
        const PxU32 packed=bodies[node.index()].solverConfig.x;
        if(!(packed&255u) || packed>65535u){value.error|=2u;continue;}
        value.position=max(value.position,packed&255u);value.velocity=max(value.velocity,packed>>8);
    }
    using Reduce=cub::BlockReduce<NativeIterationLimits,256>;
    __shared__ typename Reduce::TempStorage scratch;
    value=Reduce(scratch).Reduce(value,MergeIterationLimits{});
    if(!threadIdx.x)partials[blockIdx.x]=value;
}
__global__ void finishNativeIterationLimits(const NativeIterationLimits* partials,PxU32 count,NativeIterationLimits* result) {
    NativeIterationLimits value{};if(threadIdx.x<count)value=partials[threadIdx.x];
    using Reduce=cub::BlockReduce<NativeIterationLimits,256>;
    __shared__ typename Reduce::TempStorage scratch;
    value=Reduce(scratch).Reduce(value,MergeIterationLimits{});
    if(!threadIdx.x)*result=value;
}
class NativeRigidIterationLimits {
    NativeIterationLimits *mPartials{},*mResult{},*mHost{};
    cudaEvent_t mReady{};bool mPending=false;
public:
    void initialize() {
        allocate(mPartials,128);allocate(mResult,1);
        check(cudaMallocHost(&mHost,sizeof(*mHost)));
        check(cudaEventCreateWithFlags(&mReady,cudaEventDisableTiming));
    }
    void clear() {
        if(mPending)cudaEventSynchronize(mReady);
        cudaFree(mPartials);cudaFree(mResult);cudaFreeHost(mHost);cudaEventDestroy(mReady);
        mPartials=mResult=mHost=nullptr;mReady=nullptr;mPending=false;
    }
    void prepare(const PxgBodySim* bodies,PxU32 capacity,const PxNodeIndex* active,
        PxU32 offset,PxU32 count,cudaStream_t stream) {
        if(mPending || !bodies || !active || PxU64(offset)+count>~PxU32(0))
            throw std::runtime_error("invalid native iteration limit transaction");
        const PxU32 blocks=PxU32(std::max<PxU64>(1,std::min<PxU64>(128,(PxU64(count)+255)/256)));
        reduceNativeIterationLimits<<<blocks,256,0,stream>>>(bodies,capacity,active,offset,count,mPartials);
        const auto* source=mPartials;
        if(blocks>1){finishNativeIterationLimits<<<1,256,0,stream>>>(mPartials,blocks,mResult);source=mResult;}
        check(cudaGetLastError());
        check(cudaMemcpyAsync(mHost,source,sizeof(*mHost),cudaMemcpyDeviceToHost,stream));
        check(cudaEventRecord(mReady,stream));mPending=true;
    }
    void read(PxU32& position,PxU32& velocity) {
        if(!mPending)throw std::runtime_error("native iteration limits not submitted");
        check(cudaEventSynchronize(mReady));mPending=false;
        if(mHost->error)throw std::runtime_error("invalid active rigid iteration settings");
        position=mHost->position;velocity=mHost->velocity;
    }
};
