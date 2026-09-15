// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included only by the isolated diagnostic Runtime translation unit.
#include "CapturePartition.cuh"
struct LoadContactRecord {
    PxU32 chunk;
    PxVec3 point, impulse;
    float inverseSeconds;
};
static_assert(sizeof(LoadContactRecord)==32,"capture contact ABI");
__device__ LoadContactRecord* loadCaptureRecords=nullptr;
__device__ PxU32* loadCaptureCount=nullptr;
constexpr PxU32 loadCaptureCapacity=2*1024*1024;
__global__ void setLoadCapture(LoadContactRecord* records,PxU32* count) {
    loadCaptureRecords=records;loadCaptureCount=count;
    if(count)*count=0;
}
__device__ void recordLoadContact(PxU32 chunk,PxVec3 point,PxVec3 impulse,float invDt) {
    if(!loadCaptureRecords || chunk==PX_INVALID_U32)return;
    const auto index=atomicAdd(loadCaptureCount,1u);
    if(index<loadCaptureCapacity)loadCaptureRecords[index]={chunk,point,impulse,invDt};
}
struct LoadBodyRecord {
    float linear[3],angular[3],externalLinear[3],externalAngular[3];
    float damping[2];
    PxU32 body,flags,locks,disableGravity,valid;
};
static_assert(sizeof(LoadBodyRecord)==76,"capture body ABI");
__global__ void gatherLoadBodies(const PxDestructionStressCluster* clusters,PxU32 count,
    const PxgBodySim* bodies,PxU32 capacity,LoadBodyRecord* records) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;
    LoadBodyRecord out{};out.body=clusters[i].body;
    if(bodies && out.body<capacity) {
        const auto b=bodies[out.body];out.valid=1;
        const auto v=b.linearVelocityXYZ_inverseMassW,w=b.angularVelocityXYZ_maxPenBiasW;
        const auto a=b.externalLinearAcceleration,t=b.externalAngularAcceleration;
        out.linear[0]=v.x;out.linear[1]=v.y;out.linear[2]=v.z;
        out.angular[0]=w.x;out.angular[1]=w.y;out.angular[2]=w.z;
        out.externalLinear[0]=a.x;out.externalLinear[1]=a.y;out.externalLinear[2]=a.z;
        out.externalAngular[0]=t.x;out.externalAngular[1]=t.y;out.externalAngular[2]=t.z;
        out.damping[0]=b.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW.z;
        out.damping[1]=b.maxLinearVelocitySqX_maxAngularVelocitySqY_linearDampingZ_angularDampingW.w;
        out.flags=b.internalFlags;out.locks=b.lockFlags;out.disableGravity=b.disableGravity;
    }
    records[i]=out;
}
class LoadCapture {
    CapturePartition partition;
    unsigned ordinal=0;
    bool selected=false;
    LoadContactRecord* contacts=nullptr;
    PxU32* count=nullptr;
    std::string directory;
    std::ofstream metadata;
    template<class T> std::vector<T> read(const T* pointer,size_t n,cudaStream_t stream) {
        std::vector<T> values(n);
        if(n)check(cudaMemcpyAsync(values.data(),pointer,n*sizeof(T),cudaMemcpyDeviceToHost,stream));
        check(cudaStreamSynchronize(stream));return values;
    }
    template<class T> void blob(const char* name,const T* pointer,size_t n,cudaStream_t stream) {
        const auto values=read(pointer,n,stream);
        std::ofstream file(directory+"/"+name+".bin",std::ios::binary);
        file.write(reinterpret_cast<const char*>(values.data()),values.size()*sizeof(T));
        if(!file)throw std::runtime_error("load capture write failed");
        metadata<<",\n  \""<<name<<"\": {\"count\":"<<n<<",\"stride\":"<<sizeof(T)<<"}";
    }
public:
    void clear() { partition.clear(); }
    void begin(cudaStream_t stream) {
        const char* root=std::getenv("PHYSX_LOAD_CAPTURE_DIR");
        // Solve ordinals are only selectors. Device frame/evaluation/generation
        // are recorded below; never infer those identities from an ordinal.
        selected=root && (ordinal==0 || ordinal==82 || ordinal==83 || ordinal==130);
        if(selected) {
            directory=std::string(root)+"/solve-"+std::to_string(ordinal);
            if(!std::filesystem::create_directory(directory))throw std::runtime_error("load capture directory exists");
            allocate(contacts,loadCaptureCapacity);allocate(count,1);
            setLoadCapture<<<1,1,0,stream>>>(contacts,count);
        }
        ++ordinal;
    }
    void finish(cudaStream_t stream,float dt,PxVec3 gravity,bool correction,
        const PxDestructionStageStatus* stage,PxDestructionTopologyDeviceView topology,
        const PxDestructionStressChunk* chunks,const PxDestructionStressCluster* clusters,
        const PxTransform* poses,const PxVec3* angular,const PxDestructionSurfaceLoad* surface,
        const PxDestructionVectorPair* legacy,PxU32 clusterCount,
        const PxgBodySim* bodies,PxU32 bodyCapacity,const PxgBodySim* checkpoint,PxU32 checkpointCount,
        PxU64 checkpointGeneration,PxU64 responseEpoch,
        PxgDestructionRigidCheckpointView inputCheckpoint,PxgDestructionCheckpointPurpose checkpointPurpose) {
        if(!selected)return;
        if(!inputCheckpoint.bodies || !inputCheckpoint.ready || !inputCheckpoint.generation ||
            inputCheckpoint.purpose!=PxgDestructionCheckpointPurpose::BeforeSolve ||
            (correction?(inputCheckpoint.generation>=checkpointGeneration || checkpointPurpose!=PxgDestructionCheckpointPurpose::CorrectedMotion):
                        (inputCheckpoint.generation!=checkpointGeneration || checkpointPurpose!=PxgDestructionCheckpointPurpose::BeforeSolve)))
            throw std::runtime_error("load capture input-history purpose/generation mismatch");
        check(cudaStreamWaitEvent(stream,reinterpret_cast<cudaEvent_t>(inputCheckpoint.ready),0));
        const auto status=read(stage,1,stream)[0];
        const auto topo=read(topology.status,1,stream)[0];
        const auto packed=partition.inspect(topology,chunks,stream);
        const auto records=read(count,1,stream)[0];
        if(records>loadCaptureCapacity)throw std::runtime_error("load contact capture overflow");
        metadata.open(directory+"/manifest.json");metadata<<std::setprecision(17);
        metadata<<"{\n  \"schema\":1,\"diagnostic_only\":true,\"complete_command_ledger\":false"
            <<",\"ordinal\":"<<ordinal-1<<",\"tick\":"<<status.frame<<",\"evaluation\":"<<unsigned(correction)
            <<",\"ownership_generation\":"<<topo.generation<<",\"stage_error\":"<<status.error
            <<",\"cluster_count\":"<<clusterCount<<",\"topology_clusters\":"<<topo.clusterCount
            <<",\"checkpoint_generation\":"<<checkpointGeneration<<",\"response_epoch\":"<<responseEpoch
            <<",\"seconds\":"<<double(dt)<<",\"inverse_seconds\":"<<double(1.0f/dt)
            <<",\"gravity\":["<<gravity.x<<","<<gravity.y<<","<<gravity.z<<"]";
        metadata<<",\n  \"elastic_partition\": {\"nodes\":"<<packed.groups.nodes<<",\"groups\":"<<packed.groups.count
            <<",\"builds\":"<<packed.builds<<",\"rebuilt\":"<<packed.rebuild<<",\"error\":"<<packed.error<<"}";
        metadata<<",\n  \"input_history_generation\":"<<inputCheckpoint.generation
            <<",\"input_history_count\":"<<inputCheckpoint.count<<",\"input_history_purpose\":"<<unsigned(inputCheckpoint.purpose)
            <<",\"checkpoint_purpose\":"<<unsigned(checkpointPurpose);
        blob("original_bodies",inputCheckpoint.bodies,inputCheckpoint.count,stream);
        if(!inputCheckpoint.owners || !inputCheckpoint.ownership)throw std::runtime_error("missing original ownership");
        const auto originalOwnership=read(inputCheckpoint.ownership,1,stream)[0];
        if(!originalOwnership.valid || originalOwnership.error || originalOwnership.inputGeneration!=inputCheckpoint.generation ||
            originalOwnership.bodyCount!=inputCheckpoint.count || originalOwnership.chunkCount!=topology.chunkCount)
            throw std::runtime_error("invalid original ownership receipt");
        blob("original_ownership",inputCheckpoint.ownership,1,stream);
        blob("original_owners",inputCheckpoint.owners,originalOwnership.chunkCount,stream);
        if(inputCheckpoint.previous)blob("original_previous",inputCheckpoint.previous,inputCheckpoint.count,stream);
        if(inputCheckpoint.accelerations)blob("original_accelerations",inputCheckpoint.accelerations,inputCheckpoint.count,stream);
        const auto n=topology.chunkCount,m=topology.bondCount;
        blob("chunks",chunks,n,stream);blob("mass",topology.chunks,n,stream);
        blob("surface",surface,n,stream);blob("legacy",legacy,n,stream);
        blob("active_chunks",topology.activeChunks,n,stream);blob("chunk_root",topology.chunkCluster,n,stream);
        blob("ordered_chunks",topology.orderedChunks,n,stream);
        blob("bond_endpoints",topology.bonds,m,stream);blob("active_bonds",topology.activeBonds,m,stream);
        blob("active_roots",topology.activeClusters,topo.clusterCount,stream);
        blob("cluster_mass",topology.clusters,n,stream);blob("root_slot",topology.clusterSlots,n,stream);
        blob("slot_roots",topology.slotRoots,topology.slotCapacity,stream);
        blob("slot_generations",topology.slotGenerations,topology.slotCapacity,stream);
        blob("poses",poses,clusterCount,stream);blob("angular",angular,clusterCount,stream);
        blob("clusters",clusters,clusterCount,stream);blob("contacts",contacts,records,stream);
        LoadBodyRecord* deviceBodies=nullptr;allocate(deviceBodies,clusterCount);
        gatherLoadBodies<<<(clusterCount+127)/128,128,0,stream>>>(clusters,clusterCount,bodies,bodyCapacity,deviceBodies);
        blob("bodies",deviceBodies,clusterCount,stream);
        gatherLoadBodies<<<(clusterCount+127)/128,128,0,stream>>>(clusters,clusterCount,checkpoint,checkpointCount,deviceBodies);
        blob("checkpoint_bodies",deviceBodies,clusterCount,stream);
        check(cudaFree(deviceBodies));
        metadata<<"\n}\n";metadata.close();if(!metadata)throw std::runtime_error("load manifest write failed");
        setLoadCapture<<<1,1,0,stream>>>(nullptr,nullptr);check(cudaStreamSynchronize(stream));
        check(cudaFree(contacts));check(cudaFree(count));contacts=nullptr;count=nullptr;
    }
};
