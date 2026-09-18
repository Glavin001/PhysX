// Included in the runtime private namespace. GPU-owned final ownership union.
struct HasPendingShapeOwner {
    const PxU64* epochs;const PxDestructionStageStatus* stage;
    __device__ bool operator()(PxU32 chunk)const{return epochs[chunk]==stage->frame;}
};
__global__ void gatherFinalShapeOwners(const PxU32* indices,const PxU32* count,PxU32 capacity,
    const PxDestructionStressChunk* chunks,const PxU32* targets,
    PxDestructionCollisionBinding* out,PxDestructionStageStatus* stage) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=capacity)return;
    out[i]={}; // The bounded host observation includes this initialized tail.
    if(*count>capacity){if(i==0)atomicOr(&stage->error,1024u);return;}
    if(i>=*count || stage->error)return;
    const PxU32 chunk=indices[i];
    out[i]={chunk,chunks[chunk].contactIndex,PX_INVALID_U32,targets[chunk]};
}
