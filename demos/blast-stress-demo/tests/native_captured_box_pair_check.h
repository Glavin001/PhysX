// Focused geometry diagnostic, included inside the test's anonymous namespace.
// Provenance: cuda-metal/out/tests/native-wall-impact-1063.json, frame 30,
// gpu_state_audit.collision_shapes[id=11/16].gpu_shape_pose. These are shapes,
// not original compound owner frames. Original per-chunk mass/inertia retained;
// lower shape is authored kinematic to isolate rotated box-box response.
void capturedBoxPair(bool cpu=false) {
    blast_demo::SceneCapacity capacity;capacity.maxBodies=4;capacity.maxShapes=4;
    blast_demo::PhysXScene context(cpu?blast_demo::PhysicsMode::Cpu:blast_demo::PhysicsMode::Gpu,
        !cpu,capacity,nullptr,false,true,false,false,PxSolverType::eTGS,false,false);
    require(cpu?!context.gpuActive():(context.gpuActive()&&!context.directGpuApiActive()),
        "captured pair selected wrong physics backend");
    auto& scene=context.scene();auto& physics=context.physics();scene.setGravity(PxVec3(0));
    const PxBoxGeometry geometry(.48f,.48f,.48f);
    const PxTransform initial[2]={
        PxTransform(PxVec3(-.998621464f,2.43347096f,.175117612f),
            PxQuat(.0211046934f,.00435900036f,.000225879223f,.99976778f)),
        PxTransform(PxVec3(-.99999994f,3.12067151f,.13346459f),
            PxQuat(-.0900503471f,0,0,.995937228f))};
    const float mass=1000*8*.48f*.48f*.48f;
    const float inertia=mass*(.48f*.48f+.48f*.48f)/3;
    PxRigidDynamic* boxes[2]{};
    for(PxU32 i=0;i<2;++i) {
        require(initial[i].isValid(),"captured box pose invalid");
        boxes[i]=physics.createRigidDynamic(initial[i]);require(boxes[i],"captured box allocation failed");
        auto* shape=physics.createShape(geometry,context.material(),true);require(shape,"captured shape allocation failed");
        require(boxes[i]->attachShape(*shape),"captured shape attach failed");shape->release();
        boxes[i]->setMass(mass);boxes[i]->setMassSpaceInertiaTensor(PxVec3(inertia));
        boxes[i]->setLinearDamping(0);boxes[i]->setAngularDamping(0);
        boxes[i]->setLinearVelocity(PxVec3(0));boxes[i]->setAngularVelocity(PxVec3(0));
        if(i==0)boxes[i]->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        else boxes[i]->setWakeCounter(100); // authored once, never reset per step
        scene.addActor(*boxes[i]);
    }
    PxVec3 initialDirection;float initialDepth=0;
    require(PxGeometryQuery::computePenetration(initialDirection,initialDepth,geometry,initial[0],geometry,initial[1])
        && initialDepth>.03f,"captured pair lost its original deep overlap");
    std::fprintf(stderr,"captured-box-pair backend=%s source=1063 frame=30 ids=11,16 dt=1/60 steps=10 gravity=0 mass=%.9g inertia=%.9g initialDepth=%.9g initialDirection=(%.9g,%.9g,%.9g)\n",
        cpu?"CPU":"GPU",mass,inertia,initialDepth,initialDirection.x,initialDirection.y,initialDirection.z);
    PxgSimulationController* controller=nullptr;
    if(!cpu)controller=static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController());
    float finalDepth[2]={initialDepth,initialDepth};PxU32 publicationMismatches=0;
    for(PxU32 frame=0;frame<10;++frame) {
        scene.simulate(1.0f/60);PxU32 error=0;
        require(scene.fetchResults(true,&error)&&!error&&context.healthy(),"captured box pair step failed");
        PxTransform poses[2][2];PxVec3 velocity[2][2];
        for(PxU32 i=0;i<2;++i) {
            poses[0][i]=boxes[i]->getGlobalPose();velocity[0][i]=boxes[i]->getLinearVelocity();
            if(!cpu) {
                PxScopedCudaLock lock(*context.cudaContextManager());
                const PxU32 index=boxes[i]->getGPUIndex();require(index!=PX_INVALID_U32,"captured box GPU index missing");
                PxgBodySim observed{};
                require(cuMemcpyDtoH(&observed,reinterpret_cast<CUdeviceptr>(controller->getSimulationCore()
                    ->getBodySimBufferDevicePtr().getPointer()+index),sizeof(observed))==CUDA_SUCCESS,"captured GPU body copy failed");
                poses[1][i]=observed.body2World.getTransform()*observed.body2Actor_maxImpulseW.getTransform().getInverse();
                const auto v=observed.linearVelocityXYZ_inverseMassW;velocity[1][i]=PxVec3(v.x,v.y,v.z);
                const bool agrees=(poses[0][i].p-poses[1][i].p).magnitude()<1e-4f
                    && PxAbs(poses[0][i].q.dot(poses[1][i].q))>1-1e-5f
                    && (velocity[0][i]-velocity[1][i]).magnitude()<1e-4f;
                publicationMismatches+=!agrees;
                std::fprintf(stderr,"captured-box-pair gpu-state frame=%u id=%u index=%u agrees=%u flags=0x%x sleeping=%u\n",
                    frame,i,index,agrees,observed.internalFlags,boxes[i]->isSleeping());
            }
        }
        for(PxU32 representation=0;representation<(cpu?1u:2u);++representation) {
            for(PxU32 i=0;i<2;++i) {
                const auto& p=poses[representation][i];const auto& v=velocity[representation][i];
                require(p.isValid()&&v.isFinite(),"captured box pair nonfinite state");
                std::fprintf(stderr,"captured-box-pair state frame=%u source=%s id=%u p=(%.9g,%.9g,%.9g) q=(%.9g,%.9g,%.9g,%.9g) v=(%.9g,%.9g,%.9g)\n",
                    frame,representation?"GPU":"CPU",i,p.p.x,p.p.y,p.p.z,p.q.x,p.q.y,p.q.z,p.q.w,v.x,v.y,v.z);
            }
            PxVec3 direction;float depth=0;
            const bool overlap=PxGeometryQuery::computePenetration(direction,depth,geometry,poses[representation][0],geometry,poses[representation][1]);
            finalDepth[representation]=overlap?depth:0;
            std::fprintf(stderr,"captured-box-pair penetration frame=%u source=%s overlap=%u depth=%.9g\n",
                frame,representation?"GPU":"CPU",overlap,finalDepth[representation]);
            require((poses[representation][0].p-initial[0].p).magnitude()<1e-4f,
                "captured kinematic lower box moved without authored motion");
        }
    }
    for(auto* box:boxes)box->release();
    std::fprintf(stderr,"captured-box-pair complete backend=%s initialDepth=%.9g finalCpuDepth=%.9g finalGpuDepth=%.9g publicationMismatches=%u\n",
        cpu?"CPU":"GPU",initialDepth,finalDepth[0],cpu?-1.0f:finalDepth[1],publicationMismatches);
    require(finalDepth[0]<=.03f&&(cpu||finalDepth[1]<=.03f),"captured box pair failed to resolve deep overlap within ten steps");
    require(!publicationMismatches,"captured box pair CPU/GPU publication mismatch");
    require(context.healthy(),"captured box pair teardown error");
}
