// A chunk crushed under internalCorrectionLimit 1 must not stop the scene.
// The struck chunk of an anchored structure crushes (its material's cap is far
// below the impact pressure; its bond is far above any load); the step that
// crushes it completes through one corrected solve, the crushed chunk leaves
// the anchored body as a free body of its own, the projectile goes on, and no
// later step fails. Before PX_DESTRUCTION_CRUSH_CORRECTION the stage removed
// the chunk's shape inside the correction, refused that owner transaction, and
// every step from the crush on was incomplete.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cstdio>
#include <stdexcept>
using namespace physx;
namespace {
void require(bool ok,const char* message) { if(!ok)throw std::runtime_error(message); }
void check(CUresult r) { require(r==CUDA_SUCCESS,"CUDA driver operation failed"); }

void crushInCorrection(PxSolverType::Enum solver) {
    blast_demo::SceneCapacity capacity;capacity.maxBodies=64;capacity.maxShapes=64;capacity.maxContactPairs=4096;
    // Ordinary CPU actor access (no Direct GPU API), as an application runs it.
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,false,false,false,solver);
    auto& scene=context.scene();auto& cuda=*context.cudaContextManager();
    scene.setGravity(PxVec3(0));
    auto* stage=scene.getDestructionScene();require(stage,"native destruction stage unavailable");
    // An anchored wall: a support (no shape) and one 1 m crushable block bonded to it.
    auto* wall=context.physics().createRigidDynamic(PxTransform(PxVec3(0,5,0)));
    auto* block=context.physics().createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
    require(wall && block && wall->attachShape(*block),"wall setup failed");
    wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);scene.addActor(*wall);
    // A 1 t ball at 20 m/s along +x, 2 m short of the block.
    auto* ball=PxCreateDynamic(context.physics(),PxTransform(PxVec3(-2.0f,5,0)),PxSphereGeometry(.3f),context.material(),1.0f);
    require(ball,"projectile setup failed");ball->setMass(1000);ball->setMassSpaceInertiaTensor(PxVec3(36));
    ball->setLinearDamping(0);ball->setAngularDamping(0);ball->setLinearVelocity(PxVec3(20,0,0));scene.addActor(*ball);
    scene.simulate(1.0f/60);require(scene.fetchResults(true),"warmup failed");
    const PxU32 identity=stage->getShapeContactIndex(*block);
    require(identity!=PX_INVALID_U32,"persistent shape identity unavailable");
    PxDestructionStressChunk chunks[2]={{PxVec3(0,-1,0),0,0,0,PX_INVALID_U32,1,0},{PxVec3(0),50,50.0f/6,0,identity,1,0}};
    PxDestructionChunkMassProperties mass[2]={};mass[0].supported=1;mass[0].center[1]=-1;
    mass[1].mass=50;mass[1].inertia[0]=mass[1].inertia[1]=mass[1].inertia[2]=50.0/6;
    PxDestructionStressCluster cluster{wall->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bond{0,1,PxVec3(0,-.5f,0),PxVec3(0,1,0),1,1,1};
    PxDestructionMaterial material;
    material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f; // the bond never breaks on its own
    // Crushes at 10 kPa: the ball's contact on the block is ~0.5-1 MPa.
    material.crush.capPressure=1e4f;material.crush.cohesion=1e4f;material.crush.frictionSlope=0;
    material.crush.crushEnergy=1;material.crush.crushViscosity=1;
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;
    desc.bonds=&bond;desc.bondCount=1;desc.clusters=&cluster;desc.clusterCount=1;
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;
    require(stage->configureStress(desc),"native configuration failed");
    unsigned crushTick=0,crushed=0;float speedBefore=0;
    for(unsigned tick=1;tick<=60;++tick) {
        const float before=ball->getLinearVelocity().x;
        scene.simulate(1.0f/60);PxU32 error=0;const bool complete=scene.fetchResults(true,&error);
        const auto status=stage->getLastStatus();
        std::printf("tick %u complete %u error %u stage %u contacts %u broken %u crushed %u corrections %u ball vx %.2f\n",
            tick,unsigned(complete),error,status.error,status.normalContacts,status.brokenBonds,status.crushedChunks,
            status.correctionPasses,ball->getLinearVelocity().x);
        require(complete && !error && !status.error,"a step that crushes a chunk, or one after it, did not complete");
        if(status.crushedChunks && !crushTick) {
            crushTick=tick;crushed=status.crushedChunks;speedBefore=before;
            require(status.correctionPasses==1,"the crush was not corrected by one re-solve");
        }
    }
    require(crushTick,"the ball crushed nothing");
    require(crushed==1,"more than the struck chunk crushed");
    PxDestructionCrushState state[2];
    {PxScopedCudaLock lock(cuda);const auto view=stage->getDeviceView();check(cuEventSynchronize(view.readyEvent));
        check(cuMemcpyDtoH(state,CUdeviceptr(view.chunkCrush),sizeof(state)));}
    require(state[1].crushed && !state[0].crushed,"the accepted crush state does not mark the struck chunk");
    // The crushed chunk left the anchored wall as a free body of its own.
    auto* owner=block->getActor()?block->getActor()->is<PxRigidDynamic>():nullptr;
    require(owner && owner!=wall && !(owner->getRigidBodyFlags()&PxRigidBodyFlag::eKINEMATIC),"the crushed chunk is still on the anchored wall");
    // The ball pushed one 50 kg block, not an anchored wall: it goes on at well over half its speed.
    const float after=ball->getLinearVelocity().x;
    std::printf("ball %.2f m/s before the crush, %.2f m/s at the end; crushed at tick %u\n",speedBefore,after,crushTick);
    require(after>0.5f*speedBefore && ball->getGlobalPose().p.x>2,"the projectile was stopped by the crushed chunk");
    require(stage->clearStress(),"clear failed");
    ball->release();wall->release();block->release();
    require(context.healthy() && !context.errors().warningCount(),"PhysX warning or GPU failure");
}
}
int main() {
    try {crushInCorrection(PxSolverType::eTGS);crushInCorrection(PxSolverType::ePGS);
        std::puts("a crushed chunk splits off and the step completes under one correction: passed");return 0;}
    catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}
}
