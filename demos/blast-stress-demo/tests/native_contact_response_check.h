// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
// Included after Fixture. Diagnostic reads/poisoning never enter production.
void contactResponseFreshness(PxSolverType::Enum solver) {
    Fixture f(2,0,true,solver,false,true);
    require(!(f.scene.getFlags()&(PxSceneFlag::eENABLE_DIRECT_GPU_API|PxSceneFlag::eDISABLE_SLEEPING)),
        "response fixture requires ordinary actor mode and sleeping");
    f.parent->setGlobalPose(PxTransform(PxVec3(0,.25f,0)));
    f.foreign->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,false);
    f.foreign->setGlobalPose(PxTransform(PxVec3(0,2.8f,0)));
    f.foreign->setMass(10);f.foreign->setMassSpaceInertiaTensor(PxVec3(1));
    f.bonds[0].health=f.bonds[0].area=10000;
    f.configure();
    auto& sc=static_cast<NpScene&>(f.scene).getScScene();
    auto& np=*static_cast<PxgNphaseImplementationContext*>(sc.getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
    const PxU32 foreignId=f.stage->getShapeContactIndex(*f.foreignShape);
    CUevent observed;{PxScopedCudaLock lock(f.cuda);check(cuEventCreate(&observed,CU_EVENT_DISABLE_TIMING));check(cuEventRecord(observed,0));}
    unsigned awakeWrites=0,sleepingStale=0,sleepTransitionWrites=0,wakeWrites=0,sleepingQuiet=0;
    PxU64 previous=0;bool sawSleep=false;
    try {
        for(unsigned frame=0;frame<180;++frame) {
            if(frame==120) {
                require(sawSleep,"ordinary contact never slept before wake command");
                f.foreign->addForce(PxVec3(0,5,0),PxForceMode::eIMPULSE);
            }
            const bool wasSleeping=f.foreign->isSleeping();
            blast_demo::poisonNormalForceWriteback(f.scene,f.cuda,frame);
            step(f.scene);
            const auto status=f.stage->getLastStatus();
            require(!status.error && !status.brokenBonds,"freshness fixture failed or fractured");
            const bool sleeping=f.foreign->isSleeping();sawSleep|=sleeping;
            PxgDestructionSolvedContacts view;
            // fetchResults has completed every writer; inspect the producer's
            // actual merged buffers without exporting an internal engine API.
            const auto& managers=np.getExistingGpuContactManagers(GPU_BUCKET_ID::eConvex);
            view.inputs=managers.mContactManagerInputData.getTypedPtr();
            view.outputs=managers.mContactManagerOutputData.getTypedPtr();view.pairCount=np.mTotalNumPairs;
            view.responseEpoch=static_cast<PxgGpuContext*>(sc.getDynamicsContext())->mGpuSolverCore->mNativeResponseEpoch;
            require(view.responseEpoch>previous,"idle/current response epoch did not advance");previous=view.responseEpoch;
            std::vector<PxsContactManagerOutput> outputs(view.pairCount);
            std::vector<PxgContactManagerInput> inputs(view.pairCount);
            {PxScopedCudaLock lock(f.cuda);check(cuEventSynchronize(observed));
                if(view.pairCount) {
                    check(cuMemcpyDtoH(outputs.data(),CUdeviceptr(view.outputs),outputs.size()*sizeof(outputs[0])));
                    check(cuMemcpyDtoH(inputs.data(),CUdeviceptr(view.inputs),inputs.size()*sizeof(inputs[0])));
                }
            }
            bool currentForPair=false;
            for(unsigned i=0;i<view.pairCount;++i) {
                const auto& in=inputs[i];const auto& out=outputs[i];
                if(!out.nbContacts || !((in.transformCacheRef0==foreignId && in.transformCacheRef1==f.chunks[1].contactIndex)
                    || (in.transformCacheRef1==foreignId && in.transformCacheRef0==f.chunks[1].contactIndex)))continue;
                if(out.nativeResponseEpoch==view.responseEpoch) {
                    currentForPair=true;++awakeWrites;
                    if(!wasSleeping && sleeping)++sleepTransitionWrites;
                    if(frame>=120)++wakeWrites;
                }else if(sleeping)++sleepingStale;
            }
            if(wasSleeping && sleeping) {
                require(!currentForPair,"sleeping pair retained a falsely current solved response");
                ++sleepingQuiet;
            }
        }
        std::fprintf(stderr,"response coverage: active=%u sleep-retained=%u transition=%u wake=%u\n",
            awakeWrites,sleepingStale,sleepTransitionWrites,wakeWrites);
        require(awakeWrites && sleepingQuiet && wakeWrites,"missing active, quiet sleeping, or reawakened contact coverage");
        require(sleepTransitionWrites,"newly sleeping body's current solved response was discarded");
        require(f.context.healthy(),"GPU response fixture was unhealthy");
    }catch(...) {PxScopedCudaLock lock(f.cuda);cuEventDestroy(observed);throw;}
    {PxScopedCudaLock lock(f.cuda);check(cuEventDestroy(observed));}
    std::printf("%s response freshness: 2 chunks / 1 bond / 1 ordinary load body / 180 steps; active=%u sleep-retained=%u transition=%u wake=%u quiet-sleep-steps=%u passed\n",
        solver==PxSolverType::ePGS?"PGS":"TGS",awakeWrites,sleepingStale,sleepTransitionWrites,wakeWrites,sleepingQuiet);
}
