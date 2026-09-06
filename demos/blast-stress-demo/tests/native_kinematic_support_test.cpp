// Native support bookkeeping regression; no destruction stress or CUDA producer.
#include "../physx_scene.h"
#include "NpScene.h"
#include "PxsSimpleIslandManager.h"
#include <cstdio>
#include <map>
#include <stdexcept>
using namespace physx;
static void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
static void step(PxScene& scene){scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"native support step failed");}
static void run(blast_demo::PhysicsMode mode,PxSolverType::Enum solver) {
    const bool gpu=mode==blast_demo::PhysicsMode::Gpu;
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(mode,gpu,capacity,nullptr,gpu,true,false,false,solver);
    auto& scene=context.scene();scene.setGravity(PxVec3(0));
    auto* floor=PxCreateStatic(context.physics(),PxTransform(PxVec3(0,79,0)),PxBoxGeometry(3,.5f,3),context.material());
    require(floor,"floor allocation failed");scene.addActor(*floor);
    PxRigidDynamic* bodies[2];
    for(unsigned i=0;i<2;++i){bodies[i]=PxCreateDynamic(context.physics(),PxTransform(PxVec3(float(i),80,0)),PxSphereGeometry(.6f),context.material(),1);
        require(bodies[i],"body allocation failed");bodies[i]->setMass(0);bodies[i]->setMassSpaceInertiaTensor(PxVec3(0));scene.addActor(*bodies[i]);}
    step(scene);step(scene);
    const auto verify=[&](PxU32 expected){
        const auto& islands=static_cast<NpScene&>(scene).getScScene().getSimpleIslandManager()->getAccurateIslandSim();
        std::map<PxU32,PxU32> sums;PxU32 total=0;
        for(PxU32 i=0;i<islands.getNbNodes();++i){const auto& node=islands.getNode(PxNodeIndex(i));const PxU32 island=islands.getIslandIds()[i];
            if(node.isDeleted() || node.isKinematic() || island==IG_INVALID_ISLAND)continue;
            sums[island]+=node.mStaticTouchCount;total+=node.mStaticTouchCount;}
        require(total==expected,"native live-node support count differs from analytic edge count");
        for(const auto& pair:sums)require(islands.getIslandStaticTouchCount()[pair.first]==pair.second,"native island retained a removed body's static support");
    };
    verify(2);
    for(unsigned cycle=0;cycle<3;++cycle){
        bodies[0]->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);verify(1);step(scene);verify(1);
        bodies[0]->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,false);step(scene);verify(2);
    }
    floor->release();step(scene);step(scene);verify(0);
    for(auto* body:bodies)body->release();
    std::printf("%s %s native static support: analytic 2 -> 1 -> 2 across three prescribed-motion cycles, removal -> 0 passed\n",gpu?"GPU":"CPU",solver==PxSolverType::ePGS?"PGS":"TGS");
}
int main(){try{for(auto mode:{blast_demo::PhysicsMode::Cpu,blast_demo::PhysicsMode::Gpu})for(auto solver:{PxSolverType::ePGS,PxSolverType::eTGS})run(mode,solver);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
