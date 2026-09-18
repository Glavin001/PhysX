// Included after Fixture. Explicitly restore native connectivity before actual
// fracture, rather than hoping a supported shot trajectory triggers fallback.
void fractureConnectivityFallback() {
    Fixture f(4,16,false,PxSolverType::eTGS,true);f.scene.setGravity(PxVec3(0));
    // Actual dynamic contact work keeps the solver active; a converted Direct
    // GPU kinematic actor alone does not establish an uploaded awake body.
    const auto add=[&](float x){
        auto* body=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(x,80,0)),PxSphereGeometry(.6f),f.context.material(),1);
        require(body,"fallback dynamic creation failed");body->setMass(0);body->setMassSpaceInertiaTensor(PxVec3(0));
        f.scene.addActor(*body);return body;
    };
    auto* a=add(4500);auto* b=add(4501);
    f.desc.internalCorrectionLimit=1;f.desc.gpuIslandRepair=true;f.configure();
    auto& gpu=*static_cast<PxgGpuContext*>(static_cast<NpScene&>(f.scene).getScScene().getDynamicsContext());
    auto& islands=gpu.getIslandManager();
    gpu.captureSolverIslandMetadata(true);gpu.enableCudaPreSolveIslands(true);
    gpu.enableCudaPreSolveContacts(true);gpu.enableCudaPreSolveSupport(true);gpu.enableDeviceConnectivityOwnership(true);
    islands.getAccurateIslandSim().setGpuComponentAudit(true);
    islands.getSpeculativeIslandSim().setGpuComponentAudit(true);
    for(unsigned i=0;i<4;++i){step(f.scene);nativePreSolveTest::verify(gpu,f.cuda);}
    require(islands.deviceConnectivityOwned() && islands.mDeviceConnectivityPasses>0,"fracture fallback fixture never entered GPU ownership");
    const auto restores=islands.mHostConnectivityRestores;
    // Exercise the existing connectivity handoff explicitly. Speculative CCD
    // would force fallback too, but correction with CCD is unsupported and must
    // reject; it cannot be used to test successful fracture/correction.
    gpu.enableCudaPreSolveIslands(false);
    f.scene.setGravity(PxVec3(0,-100000,0));step(f.scene);
    const auto status=f.stage->getLastStatus();
    require(status.brokenBonds>0 && status.correctionPasses==1 && status.stressPasses==2,
        "explicit connectivity fallback did not coincide with actual fracture and one correction");
    require(islands.mHostConnectivityRestores>restores && !islands.deviceConnectivityOwned(),
        "explicit handoff did not restore ordinary connectivity during fracture");
    nativePreSolveTest::verify(gpu,f.cuda);
    gpu.enableCudaPreSolveIslands(true);
    f.scene.setGravity(PxVec3(0));
    for(unsigned i=0;i<4;++i){step(f.scene);nativePreSolveTest::verify(gpu,f.cuda);}
    require(islands.deviceConnectivityOwned(),"GPU connectivity did not resume after fractured-scene fallback");
    require(!islands.getAccurateIslandSim().getGpuComponentAuditFailures()
        && !islands.getSpeculativeIslandSim().getGpuComponentAuditFailures(),"fracture/fallback component audit failed");
    require(f.context.healthy(),"fracture/fallback scene became unhealthy");
    a->release();b->release();
    std::puts("20 chunks / 3 bonds plus three ordinary bodies: GPU ownership, actual fracture, one correction, explicit host restoration and GPU resume passed");
}
