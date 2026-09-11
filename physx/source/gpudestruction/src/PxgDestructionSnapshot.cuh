// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Native-build snapshot codec. No pointer or native allocation identity is stored.
// Included once before Runtime. Limits and checksum are checked before allocation
// of GPU state. This is not an untrusted-input PhysX binary parser.
namespace snapshot {
constexpr PxU32 Magic=0x44535452, Version=7, MaxBytes=1024u*1024u*1024u;
struct Settings {
    PxU32 n=0,m=0,c=0,materials=0,iterations=0,warm=0,correction=0,pairs=0,islands=0,fibres=0;
    float tolerance=0,damageRate=0,bendGain=0;
    PxU32 nativeCount=0;
};
struct Data {
    Settings settings;
    std::vector<PxU64> nativeIds;
    std::vector<PxgDestructionNativeSnapshot> nativeBodies;
    PxDestructionStageStatus stage{};
    PxDestructionTopologyStatus topology{};
    std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionStressBond> bonds;
    std::vector<PxDestructionStressCluster> clusters;
    std::vector<PxDestructionChunkMassProperties> mass;
    std::vector<PxDestructionMaterial> materials;
    std::vector<float> health;
    std::vector<PxDestructionCrushState> crush;
    std::vector<PxU32> active,roots,labels,slots,slotRoots;
    std::vector<PxU64> generations,shapeIds,bodyIds;
    std::vector<PxDestructionClusterMotion> motions;
    PxDestructionStressDesc desc() const {
        PxDestructionStressDesc d;
        d.chunks=chunks.data();d.chunkCount=settings.n;d.bonds=bonds.data();d.bondCount=settings.m;
        d.clusters=clusters.data();d.clusterCount=settings.c;d.chunkMassProperties=mass.data();
        d.materials=materials.data();d.materialCount=settings.materials;
        d.maxIterations=settings.iterations;d.tolerance=settings.tolerance;d.warmStart=settings.warm;
        d.internalCorrectionLimit=settings.correction;d.preserveUnchangedContactPairs=settings.pairs;
        d.gpuIslandRepair=settings.islands;d.fibreBending=settings.fibres;
        d.damageRate=settings.damageRate;d.bendGainMax=settings.bendGain;
        return d;
    }
    void authored(const PxDestructionStressDesc& d) {
        settings={d.chunkCount,d.bondCount,d.clusterCount,d.materialCount,d.maxIterations,
            PxU32(d.warmStart),d.internalCorrectionLimit,PxU32(d.preserveUnchangedContactPairs),
            PxU32(d.gpuIslandRepair),PxU32(d.fibreBending),d.tolerance,d.damageRate,d.bendGainMax};
        chunks.assign(d.chunks,d.chunks+d.chunkCount);
        if(d.bondCount)bonds.assign(d.bonds,d.bonds+d.bondCount);
        clusters.assign(d.clusters,d.clusters+d.clusterCount);
        if(d.chunkMassProperties)mass.assign(d.chunkMassProperties,d.chunkMassProperties+d.chunkCount);
        if(d.materialCount)materials.assign(d.materials,d.materials+d.materialCount);
    }
};
template<class T> void download(std::vector<T>& out,const T* src,size_t n) {
    out.resize(n);if(n)check(cudaMemcpy(out.data(),src,n*sizeof(T),cudaMemcpyDeviceToHost));
}
template<class T> void upload(const T* dst,const std::vector<T>& data) {
    if(!data.empty())check(cudaMemcpy(const_cast<T*>(dst),data.data(),data.size()*sizeof(T),cudaMemcpyHostToDevice));
}
// Pack only active motion slots; never read uninitialized capacity entries.
__global__ void gatherMotions(PxDestructionClusterMotion* packed,const PxDestructionClusterMotion* slots,
    const PxU32* roots,const PxU32* rootSlots,PxU32 count){
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<count)packed[i]=slots[rootSlots[roots[i]]];
}
__global__ void scatterMotions(PxDestructionClusterMotion* slots,const PxDestructionClusterMotion* packed,
    const PxU32* roots,const PxU32* rootSlots,PxU32 count){
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i<count)slots[rootSlots[roots[i]]]=packed[i];
}
struct Bytes {
    std::vector<PxU8> data;size_t cursor=0;bool reading=false;
    template<class T> void pod(T& x) {
        if(reading){if(sizeof(T)>data.size()-cursor)throw std::runtime_error("truncated snapshot");
            std::memcpy(&x,data.data()+cursor,sizeof(T));cursor+=sizeof(T);}
        else {if(data.size()+sizeof(T)>MaxBytes)throw std::runtime_error("snapshot too large");
            const auto* p=reinterpret_cast<const PxU8*>(&x);data.insert(data.end(),p,p+sizeof(T));}
    }
    template<class T> void array(std::vector<T>& x,PxU32 n) {
        const size_t bytes=size_t(n)*sizeof(T);
        if(reading){if(bytes>data.size()-cursor)throw std::runtime_error("truncated snapshot array");
            x.resize(n);if(bytes)std::memcpy(x.data(),data.data()+cursor,bytes);cursor+=bytes;}
        else {if(x.size()!=n || bytes>MaxBytes-data.size())throw std::runtime_error("snapshot array size");
            if(bytes){const auto* p=reinterpret_cast<const PxU8*>(x.data());data.insert(data.end(),p,p+bytes);}}
    }
    void fields(Data& d) {
        pod(d.settings);const auto s=d.settings;
        if(!s.n || !s.c || s.c>s.n || s.n>MaxBytes/sizeof(PxDestructionStressChunk)
            || s.m>MaxBytes/sizeof(PxDestructionStressBond) || s.materials>MaxBytes/sizeof(PxDestructionMaterial)
            || s.warm>1 || s.correction>1 || s.pairs>1 || s.islands>1 || s.fibres>1)
            throw std::runtime_error("invalid snapshot counts/flags");
        pod(d.stage);pod(d.topology);
        array(d.chunks,s.n);array(d.bonds,s.m);array(d.clusters,s.c);array(d.mass,s.n);
        array(d.materials,s.materials);array(d.health,s.materials?s.m:0);array(d.crush,s.materials?s.n:0);
        array(d.active,s.m);array(d.roots,s.c);array(d.labels,s.n);array(d.slots,s.n);
        array(d.slotRoots,s.n);array(d.generations,s.n);array(d.shapeIds,s.n);array(d.bodyIds,s.c);
        array(d.motions,s.c);array(d.nativeIds,s.nativeCount);array(d.nativeBodies,s.nativeCount);
    }
};
PxU64 checksum(const std::vector<PxU8>& bytes){PxU64 h=14695981039346656037ull;for(auto b:bytes){h^=b;h*=1099511628211ull;}return h;}
struct Envelope {PxU32 magic=Magic,version=Version,api=PX_DESTRUCTION_SCENE_VERSION,endian=0x01020304,bytes=0,reserved=0;PxU64 hash=0;};
bool write(PxOutputStream& output,Data& data) {
    Bytes b;b.fields(data);Envelope h;h.bytes=PxU32(b.data.size());h.hash=checksum(b.data);
    return output.write(&h,sizeof(h))==sizeof(h) && output.write(b.data.data(),h.bytes)==h.bytes;
}
bool read(PxInputData& input,Data& data) {
    Envelope h;if(input.read(&h,sizeof(h))!=sizeof(h) || h.magic!=Magic || h.version!=Version
        || h.api!=PX_DESTRUCTION_SCENE_VERSION || h.endian!=0x01020304 || h.reserved
        || h.bytes>MaxBytes || input.tell()>input.getLength() || h.bytes!=input.getLength()-input.tell())return false;
    Bytes b;b.reading=true;b.data.resize(h.bytes);
    if(input.read(b.data.data(),h.bytes)!=h.bytes || checksum(b.data)!=h.hash)return false;
    b.fields(data);return b.cursor==b.data.size();
}
} // namespace snapshot
