// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included inside the isolated runtime after its Context/check helpers.
namespace PartitionCapture = ::physx::destructionElasticPartition;
__global__ void captureCanonicalPositions(const PxDestructionStressChunk* chunks,PxU32 n,double3* positions) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    const auto p=chunks[i].position;positions[i]=make_double3(p.x,p.y,p.z);
}
class CapturePartition {
    PartitionCapture::State* state=nullptr;
    PartitionCapture::Storage storage{};
    double3* canonical=nullptr;
public:
    void clear() {
        void* pointers[]={state,canonical,storage.starts,storage.indices,storage.local,storage.fineToAuthor,
            storage.authorToFine,storage.chunks,storage.mass,storage.positions};
        for(auto pointer:pointers)if(pointer)cudaFree(pointer);
        state=nullptr;canonical=nullptr;storage={};
    }
    PartitionCapture::State inspect(PxDestructionTopologyDeviceView topology,
        const PxDestructionStressChunk* chunks,cudaStream_t stream) {
        const auto n=topology.chunkCount;
        if(!state) {
            storage.capacity=n;
            allocate(state,1);check(cudaMemsetAsync(state,0,sizeof(*state),stream));
            allocate(canonical,n);allocate(storage.starts,size_t(n)+1);allocate(storage.indices,n);
            allocate(storage.local,n);allocate(storage.fineToAuthor,n);allocate(storage.authorToFine,n);
            allocate(storage.chunks,n);allocate(storage.mass,n);allocate(storage.positions,n);
            captureCanonicalPositions<<<std::max(1u,(n+127)/128),128,0,stream>>>(chunks,n,canonical);
        }
        if(storage.capacity!=n)throw std::runtime_error("capture scene changed without clearing its partition");
        const PartitionCapture::Source source{topology,chunks,canonical};
        // This diagnostic scene has immutable authored geometry/mass. Runtime
        // clear/configure resets this owner. General live revisions remain a
        // separate producer obligation, not inferred from a copied position.
        const PartitionCapture::Identity identity{1,1,1};
        PartitionCapture::begin<<<1,1,0,stream>>>(source,storage,identity,state);
        PartitionCapture::clear<<<(n+128)/128,128,0,stream>>>(storage,state);
        PartitionCapture::pack<<<std::max(1u,(n+127)/128),128,0,stream>>>(source,storage,state);
        PartitionCapture::ranges<<<(n+128)/128,128,0,stream>>>(source,storage,state);
        PartitionCapture::validate<<<std::max(1u,(n+127)/128),128,0,stream>>>(source,storage,state);
        PartitionCapture::finish<<<1,1,0,stream>>>(state);
        check(cudaGetLastError());
        PartitionCapture::State observed{};
        check(cudaMemcpyAsync(&observed,state,sizeof(observed),cudaMemcpyDeviceToHost,stream));
        check(cudaStreamSynchronize(stream));
        if(observed.status!=PartitionCapture::Status::Ready || observed.error)
            throw std::runtime_error("live GPU elastic partition rejected");
        return observed;
    }
};
