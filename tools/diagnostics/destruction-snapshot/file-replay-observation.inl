// CPU reference outputs let large replays use one live GPU world at a time.
// These are observations for validation, never inputs or serialized caches.
struct ObjectObservation {
    PxSerialObjectId id;PxType type;bool moving=false,shapeDynamic=false;
    PxTransform pose{PxIdentity},com{PxIdentity};PxVec3 linear{0},angular{0},inertia{0};PxReal mass=0;PxU32 flags=0;
};
std::vector<ObjectObservation> observeObjects(const PxCollection& objects){
    std::vector<ObjectObservation> result;result.reserve(objects.getNbObjects());
    for(PxU32 i=0;i<objects.getNbObjects();++i){const auto& object=objects.getObject(i);
        ObjectObservation x;x.id=objects.getId(object);x.type=object.getConcreteType();
        if(const auto* body=object.is<PxRigidDynamic>()){
            x.moving=true;x.pose=body->getGlobalPose();x.com=body->getCMassLocalPose();x.inertia=body->getMassSpaceInertiaTensor();
            x.linear=body->getLinearVelocity();x.angular=body->getAngularVelocity();x.mass=body->getMass();x.flags=PxU32(body->getRigidBodyFlags());
        }else if(const auto* shape=object.is<PxShape>()){
            require(shape->getActor(),"observed shape owner missing");x.moving=true;x.pose=shape->getActor()->getGlobalPose()*shape->getLocalPose();
            if(const auto* body=shape->getActor()->is<PxRigidDynamic>()){
                x.shapeDynamic=true;x.com=body->getCMassLocalPose();x.inertia=body->getMassSpaceInertiaTensor();x.linear=body->getLinearVelocity();x.angular=body->getAngularVelocity();x.mass=body->getMass();x.flags=PxU32(body->getRigidBodyFlags());}
        }
        require(!x.moving || (x.pose.isValid() && x.linear.isFinite() && x.angular.isFinite()),"nonfinite observed motion");result.push_back(x);
    }
    std::sort(result.begin(),result.end(),[](const ObjectObservation& a,const ObjectObservation& b){return a.id<b.id;});return result;
}
MotionError compareObservedObjects(const std::vector<ObjectObservation>& a,const std::vector<ObjectObservation>& b){
    require(a.size()==b.size(),"observed object count changed");MotionError error;
    for(size_t i=0;i<a.size();++i){const auto& x=a[i];const auto& y=b[i];
        require(x.id==y.id && x.type==y.type && x.shapeDynamic==y.shapeDynamic,"observed object identity/type changed");
        if(!x.moving)continue;
        error.position=PxMax(error.position,(x.pose.p-y.pose.p).magnitude());error.orientation=PxMax(error.orientation,PxAbs(1-PxAbs(x.pose.q.dot(y.pose.q))));
        error.linear=PxMax(error.linear,(x.linear-y.linear).magnitude());error.angular=PxMax(error.angular,(x.angular-y.angular).magnitude());
        require(x.mass==y.mass && x.inertia==y.inertia && x.com==y.com && x.flags==y.flags,"observed body mass/inertia/COM/role changed");
    }
    if(!(error.position<1e-4f && error.linear<1e-4f && error.angular<1e-4f && error.orientation<1e-5f))
        std::cerr<<"motion error position "<<error.position<<" linear "<<error.linear<<" angular "<<error.angular<<" orientation "<<error.orientation<<std::endl;
    require(error.position<1e-4f && error.linear<1e-4f && error.angular<1e-4f && error.orientation<1e-5f,"physical state differs beyond existing motion bounds");return error;
}
struct DestructionObservation {
    std::vector<float> health;
    std::vector<PxU32> active,clusters;
    std::vector<PxDestructionCrushState> crush;
};
DestructionObservation observeDestruction(PxScene& scene){
    const auto view=scene.getDestructionScene()->getDeviceView();DestructionObservation result;
    result.health=health(scene);result.active.resize(view.bondCount);result.clusters.resize(view.chunkCount);result.crush.resize(view.chunkCount);
    require(cuCtxPushCurrent(scene.getCudaContextManager()->getContext())==CUDA_SUCCESS,"observation context");
    require(cuEventSynchronize(view.readyEvent)==CUDA_SUCCESS,"observation ready");
    auto read=[](void* dst,const void* src,size_t bytes){if(bytes)require(cuMemcpyDtoH(dst,CUdeviceptr(src),bytes)==CUDA_SUCCESS,"observation readback");};
    read(result.active.data(),view.acceptedTopology.activeBonds,result.active.size()*sizeof(PxU32));
    read(result.clusters.data(),view.acceptedTopology.chunkCluster,result.clusters.size()*sizeof(PxU32));
    read(result.crush.data(),view.chunkCrush,result.crush.size()*sizeof(result.crush[0]));
    CUcontext previous;require(cuCtxPopCurrent(&previous)==CUDA_SUCCESS,"observation context pop");return result;
}
void compareObservedDestruction(const DestructionObservation& a,const DestructionObservation& b){
    require(a.active==b.active && a.clusters==b.clusters,"accepted topology changed between equivalent states");
    require(a.crush.size()==b.crush.size() && a.health.size()==b.health.size(),"observed material size changed");
    for(size_t i=0;i<a.crush.size();++i)require(a.crush[i].damage==b.crush[i].damage && a.crush[i].crushed==b.crush[i].crushed,"material damage changed");
    if(a.health!=b.health){unsigned count=0,index=0;float delta=0;for(unsigned i=0;i<a.health.size();++i)if(a.health[i]!=b.health[i]){
        ++count;if(PxAbs(a.health[i]-b.health[i])>delta){delta=PxAbs(a.health[i]-b.health[i]);index=i;}}
        std::cerr<<std::setprecision(10)<<"health differences="<<count<<" max="<<delta<<" bond="<<index<<" values="<<a.health[index]<<'/'<<b.health[index]<<std::endl;}
    require(a.health==b.health,"bond health changed between equivalent states");
}
