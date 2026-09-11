// Included by the native benchmark: capture accepted physical inputs outside its
// timer. Opt-in only; no simulation tick, mutations, or warmup during export.
void captureNativeSnapshot(PxScene& scene,const std::vector<Chunk>& chunks,
    const SceneCapacity& capacity,const std::string& prefix,unsigned frame,unsigned buildings,unsigned shots,
    bool preIslands,bool preContacts,bool preSupport,bool connectivity){
    auto* registry=PxSerialization::createSerializationRegistry(scene.getPhysics());
    auto* objects=PxCollectionExt::createCollection(scene);
    require(registry && objects,"native snapshot collection");PxSerialization::complete(*objects,*registry);
    for(const auto& chunk:chunks)require(objects->contains(*chunk.shape),"native snapshot omitted authored shape");
    for(PxU32 i=0;i<objects->getNbObjects();++i)objects->addId(objects->getObject(i),PxU64(i)+1);
    PxDefaultMemoryOutputStream physical,destruction;
    require(scene.getDestructionScene()->exportState(destruction,*objects),"native destruction snapshot export");
    require(PxSerialization::serializeCollectionToBinary(physical,*objects,*registry),"native PhysX snapshot export");
    for(const auto entry:{std::make_pair(".pxbin",&physical),std::make_pair(".destruction",&destruction)}){
        std::ofstream file(prefix+entry.first,std::ios::binary);file.write(reinterpret_cast<const char*>(entry.second->getData()),entry.second->getSize());
        require(bool(file),"native snapshot file write");}
    // This fixture sidecar reconstructs application-owned scene policy; the
    // destruction stream itself owns stress/material settings.
    std::ofstream settings(prefix+".scene");
    settings<<1<<' '<<capacity.maxBodies<<' '<<capacity.maxShapes<<' '<<capacity.maxContactPairs<<' '
        <<0<<' '<<preIslands<<' '<<preContacts<<' '<<preSupport<<' '<<connectivity<<'\n';
    require(bool(settings),"native snapshot scene settings write");
    const auto view=scene.getDestructionScene()->getDeviceView();PxDestructionTopologyStatus topology{};
    {PxScopedCudaLock lock(*scene.getCudaContextManager());check(cuEventSynchronize(view.readyEvent));
        check(cuMemcpyDtoH(&topology,CUdeviceptr(view.acceptedTopology.status),sizeof(topology)));}
    std::ofstream metadata(prefix+".metadata.json");
    metadata<<"{\"schema\":1,\"source\":\"native_destruction_demo\",\"next_step\":"<<frame
        <<",\"buildings\":"<<buildings<<",\"chunks\":"<<view.chunkCount<<",\"bonds\":"<<view.bondCount
        <<",\"projectiles\":"<<shots<<",\"input_clusters\":"<<topology.clusterCount
        <<",\"physical_bytes\":"<<physical.getSize()<<",\"destruction_bytes\":"<<destruction.getSize()
        <<",\"dt\":0.016666666666666666,\"pending_gameplay_commands\":false}\n";
    require(bool(metadata),"native snapshot metadata write");objects->release();registry->release();
}
