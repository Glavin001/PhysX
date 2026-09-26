// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cstdio>
#include <stdexcept>
namespace nativeConvergenceTest {
using namespace physx;
inline void require(bool value,const char* reason){if(!value)throw std::runtime_error(reason);}
inline void check(CUresult result){require(result==CUDA_SUCCESS,"convergence observation GPU copy failed");}
inline void run() {
    for(bool native:{false,true}) {
        blast_demo::SceneCapacity capacity;
        blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,true,false,false);
        auto& scene=context.scene();auto* parent=context.physics().createRigidDynamic(PxTransform(PxVec3(0,10,0)));
        parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        PxDestructionStressChunk nodes[4];PxDestructionChunkMassProperties mass[4]{};
        PxDestructionStressBond bonds[3];
        for(unsigned i=0;i<4;++i) {
            nodes[i]={PxVec3(float(i),0,0),i?float(i):0.0f,i?float(i):0.0f,0,PX_INVALID_U32};
            mass[i].center[0]=i;mass[i].mass=i;mass[i].supported=i==0;
            mass[i].inertia[0]=mass[i].inertia[1]=mass[i].inertia[2]=i;
            if(i) {
                bonds[i-1]={i-1,i,PxVec3(float(i)-.5f,0,0),PxVec3(1,0,0),1,1,1};
                auto* shape=context.physics().createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
                shape->setLocalPose(PxTransform(nodes[i].position));require(parent->attachShape(*shape),"cantilever shape setup failed");shape->release();
            }
        }
        scene.addActor(*parent);scene.simulate(1.0f/60);require(scene.fetchResults(true),"cantilever warmup failed");
        PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(2.3333333f,0,0)};
        PxDestructionMaterial material;material.compressionElasticLimit=native?1:1e12f;material.compressionFatalLimit=native?2:2e12f;
        material.tensionElasticLimit=native?1:1e12f;material.tensionFatalLimit=native?2:2e12f;
        material.shearElasticLimit=native?1:1e12f;material.shearFatalLimit=native?2:2e12f;
        PxDestructionStressDesc desc;desc.chunks=nodes;desc.chunkCount=4;desc.chunkMassProperties=mass;desc.bonds=bonds;desc.bondCount=3;
        desc.clusters=&cluster;desc.clusterCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=1;desc.tolerance=1e-5f;desc.internalCorrectionLimit=native?1:0;
        auto* stage=scene.getDestructionScene();require(stage->configureStress(desc),"cantilever stress configuration failed");
        scene.simulate(1.0f/60);PxU32 error=0;const bool accepted=scene.fetchResults(true,&error);const auto status=stage->getLastStatus();
        require(!status.converged && status.iterations==1,"fixture did not exhaust its stress budget");
        // Weak joints would break from the approximate iterate. Native mode
        // must reject the step and every material/topology change; diagnostic
        // reference mode retains its existing convergence reporting behavior.
        if(native)require(!accepted && (status.error&4096u) && !status.correctionPasses
            && !status.bondCommands && !status.brokenBonds && !status.crushedChunks,
            "native mode accepted unconverged material damage");
        else require(accepted && !error && !status.error,"diagnostic compatibility changed");
        if(native) {
            const auto view=stage->getDeviceView();
            float health[3];PxDestructionBondVerdict verdicts[3];PxDestructionCrushState crush[4];
            {PxScopedCudaLock lock(*context.cudaContextManager());
                check(cuMemcpyDtoH(health,CUdeviceptr(view.bondHealth),sizeof(health)));
                check(cuMemcpyDtoH(verdicts,CUdeviceptr(view.bondVerdicts),sizeof(verdicts)));
                check(cuMemcpyDtoH(crush,CUdeviceptr(view.chunkCrush),sizeof(crush)));}
            for(unsigned i=0;i<3;++i)require(health[i]==1 && verdicts[i].health==1
                && !verdicts[i].damage && !verdicts[i].broken && !verdicts[i].command,
                "unconverged solve changed accepted bond health or published damage");
            for(const auto& c:crush)require(!c.damage && !c.crushed,"unconverged solve changed accepted crush state");
        }
        require(stage->clearStress(),"cantilever cleanup failed");parent->release();require(context.healthy(),"cantilever GPU health failed");
    }
    std::puts("native convergence gate withholds verdicts on an exhausted stress budget; diagnostic reference remains selectable");
}
}
