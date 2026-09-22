// Diagnostic controls: ordinary GPU TGS contacts, optionally stress configured without intended fracture.
// Included inside native_standard_scene_test.cpp's anonymous namespace.
void rigidBoxStack(bool compound=false,bool withStress=false) {
    require(!withStress || compound,"stress stack requires compound rows");
    blast_demo::SceneCapacity capacity; capacity.maxBodies=16; capacity.maxShapes=16;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,
        false,true,false,false,PxSolverType::eTGS,false,false);
    require(context.gpuActive() && !context.directGpuApiActive(),"rigid stack requires ordinary GPU TGS");
    auto& scene=context.scene(); auto& physics=context.physics(); auto& cuda=*context.cudaContextManager();
    const PxBoxGeometry geometry(.48f,.48f,.48f);
    const PxU32 rows=compound?5:3, columns=compound?2:1;
    PxRigidDynamic* boxes[5]{}; PxShape* shapes[5][2]{};
    PxDestructionScene* stress=nullptr;
    const char* mode=withStress?"compound-stress":compound?"compound":"single";
    std::fprintf(stderr,"rigid-stack mode=%s sceneFlags=0x%x disableSleeping=%u stabilization=%u rows=%u columns=%u initialDynamicWake=%g\n",
        mode,PxU32(scene.getFlags()),bool(scene.getFlags()&PxSceneFlag::eDISABLE_SLEEPING),
        bool(scene.getFlags()&PxSceneFlag::eENABLE_STABILIZATION),rows,columns,compound?100.0:0.4);
    for(PxU32 i=0;i<rows;++i) {
        boxes[i]=physics.createRigidDynamic(PxTransform(PxVec3(0,.5f+float(i),0)));
        require(boxes[i],"rigid stack box allocation failed");
        for(PxU32 column=0;column<columns;++column) {
            auto* shape=physics.createShape(geometry,context.material(),true);
            require(shape,"rigid stack shape allocation failed");
            shape->setLocalPose(PxTransform(PxVec3(compound?float(column)-.5f:0,0,0)));
            require(boxes[i]->attachShape(*shape),"rigid stack shape attachment failed");
            shapes[i][column]=shape; // actor retains ownership after release
            shape->release();
        }
        require(PxRigidBodyExt::updateMassAndInertia(*boxes[i],1000),"rigid stack mass setup failed");
        boxes[i]->setLinearDamping(0); boxes[i]->setAngularDamping(0);
        // Authored once, not reset per step: isolate compound contacts from the
        // separate ordinary-GPU disable-sleeping publication boundary.
        if(compound && i>0)boxes[i]->setWakeCounter(100);
        if(i==0)boxes[i]->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        scene.addActor(*boxes[i]);
    }
    auto* controller=static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController());
    float deepest[2]={0,0},largestPoseError=0;
    PxU32 poseMismatches=0,velocityMismatches=0,firstMismatch=PX_INVALID_U32;
    for(PxU32 frame=0;frame<90;++frame) {
        scene.simulate(1.0f/60); PxU32 error=0;
        require(scene.fetchResults(true,&error) && !error && context.healthy(),"rigid stack step failed");
        if(withStress && frame==0) {
            // Configure only after initial shape registration. The ordinary
            // control takes this same first step; native BP starts at frame 1.
            stress=scene.getDestructionScene();require(stress,"stress stack native stage unavailable");
            PxDestructionStressChunk chunks[10]{};
            PxDestructionChunkMassProperties properties[10]{};
            PxDestructionStressCluster clusters[5]{};
            PxDestructionStressBond bonds[5]{};
            const float volume=8*.48f*.48f*.48f,mass=1000*volume,inertia=mass*(.48f*.48f+.48f*.48f)/3;
            for(PxU32 row=0;row<rows;++row) {
                clusters[row]={boxes[row]->getGPUIndex(),PxVec3(0)};
                for(PxU32 column=0;column<2;++column) {
                    const PxU32 id=2*row+column;const PxVec3 position(float(column)-.5f,0,0);
                    const PxU32 contact=stress->getShapeContactIndex(*shapes[row][column]);
                    require(contact!=PX_INVALID_U32,"stress stack missing registered shape");
                    chunks[id]={position,row?mass:0,row?inertia:0,row,contact,volume,0};
                    auto& property=properties[id];property.mass=mass;property.supported=row==0;
                    for(PxU32 k=0;k<3;++k) {property.center[k]=position[k];property.inertia[k]=inertia;}
                }
                bonds[row]={2*row,2*row+1,PxVec3(0),PxVec3(1,0,0),4*.48f*.48f,1,1,0};
            }
            PxDestructionMaterial material;
            material.compressionElasticLimit=material.tensionElasticLimit=material.shearElasticLimit=1e12f;
            material.compressionFatalLimit=material.tensionFatalLimit=material.shearFatalLimit=2e12f;
            PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=10;desc.chunkMassProperties=properties;
            desc.clusters=clusters;desc.clusterCount=5;desc.bonds=bonds;desc.bondCount=5;
            desc.materials=&material;desc.materialCount=1;desc.maxIterations=8192;desc.tolerance=1e-5f;
            desc.internalCorrectionLimit=1;desc.gpuIslandRepair=false;desc.preserveUnchangedContactPairs=false;
            require(stress->configureStress(desc),"stress stack configuration failed");
            std::fprintf(stderr,"rigid-stack stress configured after frame0: chunks=10 bonds=5 clusters=5 elastic=1e12 fatal=2e12 tolerance=1e-5 iterations=8192 correctionLimit=1\n");
        } else if(withStress) {
            const auto status=stress->getLastStatus();
            std::fprintf(stderr,"rigid-stack stress frame=%u converged=%u iterations=%u broken=%u corrections=%u error=%u\n",
                frame,status.converged,status.iterations,status.brokenBonds,status.correctionPasses,status.error);
            require(!status.error && status.converged && !status.brokenBonds && !status.correctionPasses,
                "stress stack is not a converged nonfracturing control");
        }
        PxTransform cpuPose[5],gpuPose[5]; PxVec3 cpuVelocity[5],gpuVelocity[5];
        // fetchResults is the normal frame boundary. Readback is diagnostic;
        // there is no forced synchronization between simulation kernels.
        {
            PxScopedCudaLock lock(cuda);
            for(PxU32 i=0;i<rows;++i) {
                const PxU32 index=boxes[i]->getGPUIndex(); require(index!=PX_INVALID_U32,"rigid stack GPU index missing");
                PxgBodySim observed{};
                require(cuMemcpyDtoH(&observed,reinterpret_cast<CUdeviceptr>(controller->getSimulationCore()
                    ->getBodySimBufferDevicePtr().getPointer()+index),sizeof(observed))==CUDA_SUCCESS,"rigid stack GPU audit copy failed");
                cpuPose[i]=boxes[i]->getGlobalPose();
                gpuPose[i]=observed.body2World.getTransform()*observed.body2Actor_maxImpulseW.getTransform().getInverse();
                cpuVelocity[i]=boxes[i]->getLinearVelocity();
                const auto gv=observed.linearVelocityXYZ_inverseMassW;
                gpuVelocity[i]=PxVec3(gv.x,gv.y,gv.z);
                const auto ca=boxes[i]->getAngularVelocity();const auto ga=observed.angularVelocityXYZ_maxPenBiasW;
                std::fprintf(stderr,"rigid-stack state frame=%u id=%u sleeping=%u cpuWake=%.9g gpuWake=%.9g flags=0x%x frozen=%u freezeThisFrame=%u unfreezeThisFrame=%u deactivate=%u freezeCount=%.9g freezeThreshold=%.9g sleepThreshold=%.9g\n",
                    frame,i,boxes[i]->isSleeping(),boxes[i]->getWakeCounter(),observed.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.y,
                    observed.internalFlags,bool(observed.internalFlags&PxsRigidBody::eFROZEN),bool(observed.internalFlags&PxsRigidBody::eFREEZE_THIS_FRAME),
                    bool(observed.internalFlags&PxsRigidBody::eUNFREEZE_THIS_FRAME),bool(observed.internalFlags&PxsRigidBody::eDEACTIVATE_THIS_FRAME),
                    observed.sleepLinVelAccXYZ_freezeCountW.w,observed.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.x,
                    observed.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.z);
                std::fprintf(stderr,"rigid-stack frame=%u id=%u gpuIndex=%u cpuP=(%.9g,%.9g,%.9g) gpuP=(%.9g,%.9g,%.9g) cpuQ=(%.9g,%.9g,%.9g,%.9g) gpuQ=(%.9g,%.9g,%.9g,%.9g) cpuV=(%.9g,%.9g,%.9g) gpuV=(%.9g,%.9g,%.9g) cpuW=(%.9g,%.9g,%.9g) gpuW=(%.9g,%.9g,%.9g)\n",
                    frame,i,index,cpuPose[i].p.x,cpuPose[i].p.y,cpuPose[i].p.z,gpuPose[i].p.x,gpuPose[i].p.y,gpuPose[i].p.z,
                    cpuPose[i].q.x,cpuPose[i].q.y,cpuPose[i].q.z,cpuPose[i].q.w,gpuPose[i].q.x,gpuPose[i].q.y,gpuPose[i].q.z,gpuPose[i].q.w,
                    cpuVelocity[i].x,cpuVelocity[i].y,cpuVelocity[i].z,gv.x,gv.y,gv.z,ca.x,ca.y,ca.z,ga.x,ga.y,ga.z);
            }
        }
        for(PxU32 i=0;i<rows;++i) {
            require(cpuPose[i].isValid() && gpuPose[i].isValid(),"rigid stack invalid pose");
            const float poseError=(cpuPose[i].p-gpuPose[i].p).magnitude();largestPoseError=PxMax(largestPoseError,poseError);
            require(cpuVelocity[i].isFinite() && gpuVelocity[i].isFinite(),"rigid stack invalid velocity");
            const bool poseMismatch=!(poseError<1e-4f && PxAbs(cpuPose[i].q.dot(gpuPose[i].q))>1-1e-5f);
            const float velocityError=(cpuVelocity[i]-gpuVelocity[i]).magnitude();
            const bool velocityMismatch=!(velocityError<1e-4f);
            poseMismatches+=poseMismatch;velocityMismatches+=velocityMismatch;
            if(poseMismatch || velocityMismatch) {
                if(firstMismatch==PX_INVALID_U32)firstMismatch=frame;
                std::fprintf(stderr,"rigid-stack MISMATCH frame=%u id=%u pose=%u velocity=%u poseError=%.9g velocityError=%.9g; continuing diagnostic, final gate remains failure\n",
                    frame,i,poseMismatch,velocityMismatch,poseError,velocityError);
            }
            // This symmetric, stationary stack must retain its vertical order;
            // also catches complete pass-through after intersection disappears.
            for(PxU32 representation=0;representation<2;++representation) {
                const PxTransform* poses=representation?gpuPose:cpuPose;
                require(poses[i].p.y>=.5f+.96f*float(i)-.03f,"rigid stack lost vertical support");
                for(PxU32 column=0;column<columns;++column) {
                    const auto shapePose=poses[i]*PxTransform(PxVec3(compound?float(column)-.5f:0,0,0));
                    const auto q=shapePose.q;
                    const float bottom=shapePose.p.y-.48f*(PxAbs(q.rotate(PxVec3(1,0,0)).y)
                        +PxAbs(q.rotate(PxVec3(0,1,0)).y)+PxAbs(q.rotate(PxVec3(0,0,1)).y));
                    require(bottom>=-.03f,"rigid stack penetrated ground");
                    for(PxU32 j=0;j<i;++j)for(PxU32 other=0;other<columns;++other) {
                        const auto otherPose=poses[j]*PxTransform(PxVec3(compound?float(other)-.5f:0,0,0));
                        PxVec3 direction;float depth=0;
                        if(PxGeometryQuery::computePenetration(direction,depth,geometry,shapePose,geometry,otherPose)) {
                            deepest[representation]=PxMax(deepest[representation],depth);
                            std::fprintf(stderr,"rigid-stack overlap source=%s frame=%u pair=%u:%u,%u:%u depth=%.9g\n",representation?"GPU":"CPU",frame,j,other,i,column,depth);
                            require(depth<=.03f,"rigid stack deep box-box penetration");
                        }
                    }
                }
            }
        }
    }
    if(stress)require(stress->clearStress(),"stress stack teardown failed");
    for(PxU32 i=0;i<rows;++i)boxes[i]->release();
    require(context.healthy(),"rigid stack teardown GPU error");
    std::fprintf(stderr,"rigid-stack audit complete mode=%s frames=90 maxCpuPenetration=%.9g maxGpuPenetration=%.9g maxPoseError=%.9g poseMismatches=%u velocityMismatches=%u firstMismatch=%u\n",
        mode,deepest[0],deepest[1],largestPoseError,poseMismatches,velocityMismatches,firstMismatch);
    require(!poseMismatches && !velocityMismatches,"rigid stack CPU/GPU publication mismatches (see full 90-frame audit)");
    std::printf("rigid box stack passed: mode=%s rows=%u columns=%u, 90 frames, stressConfigured=%u\n",mode,rows,columns,withStress);
}
