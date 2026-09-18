// Native trial failures must not publish gameplay callbacks or break joints.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <extensions/PxD6Joint.h>
#include <cstdio>
#include <stdexcept>
using namespace physx;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
struct Events final:PxSimulationEventCallback {
    unsigned advances=0,contacts=0,triggers=0,wakes=0,sleeps=0,breaks=0;
    void onConstraintBreak(PxConstraintInfo*,PxU32 n)override{breaks+=n;}
    void onWake(PxActor**,PxU32 n)override{wakes+=n;}
    void onSleep(PxActor**,PxU32 n)override{sleeps+=n;}
    void onContact(const PxContactPairHeader&,const PxContactPair*,PxU32 n)override{contacts+=n;}
    void onTrigger(PxTriggerPair*,PxU32 n)override{triggers+=n;}
    void onAdvance(const PxRigidBody*const*,const PxTransform*,const PxU32 n)override{advances+=n;}
    unsigned total()const{return advances+contacts+triggers+wakes+sleeps+breaks;}
};
void run(bool fracture,bool splitFetch,bool cpuControl=false) {
    Events events;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(cpuControl?blast_demo::PhysicsMode::Cpu:blast_demo::PhysicsMode::Gpu,!cpuControl,capacity,&events,!cpuControl,false,!cpuControl,!cpuControl);
    auto& scene=context.scene();auto& physics=context.physics();
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(20,20,0)));
    parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    PxShape* chunks[2];
    for(unsigned i=0;i<2;++i){chunks[i]=physics.createShape(PxBoxGeometry(.25f,.25f,.25f),context.material(),true);chunks[i]->setLocalPose(PxTransform(PxVec3(0,2*float(i),0)));require(parent->attachShape(*chunks[i]),"chunk attachment failed");}
    scene.addActor(*parent);
    auto* ordinary=PxCreateDynamic(physics,PxTransform(PxVec3(0,.45f,0)),PxBoxGeometry(.5f,.5f,.5f),context.material(),1);
    ordinary->setRigidBodyFlag(PxRigidBodyFlag::eENABLE_POSE_INTEGRATION_PREVIEW,true);
    ordinary->setActorFlag(PxActorFlag::eSEND_SLEEP_NOTIFIES,true);scene.addActor(*ordinary);
    PxU32 error=0;for(unsigned i=0;i<4;++i){scene.simulate(1.0f/60);require(scene.fetchResults(true,&error)&&!error,"warmup failed");}
    std::printf("warmup advance=%u contact=%u wake=%u\n",events.advances,events.contacts,events.wakes);
    require(events.advances && events.wakes,"fixture did not exercise ordinary pose/wake publication");events={};
    // These new trial interactions must be observable in the accepted control.
    auto* trigger=physics.createRigidStatic(PxTransform(PxVec3(0,.5f,0)));
    auto* triggerShape=physics.createShape(PxBoxGeometry(2,2,2),context.material(),true,PxShapeFlag::eTRIGGER_SHAPE);
    require(trigger->attachShape(*triggerShape),"trigger attachment failed");scene.addActor(*trigger);
    auto* jointed=PxCreateDynamic(physics,PxTransform(PxVec3(10,10,0)),PxSphereGeometry(.25f),context.material(),1);
    jointed->setActorFlag(PxActorFlag::eSEND_SLEEP_NOTIFIES,true);scene.addActor(*jointed);
    auto* joint=PxD6JointCreate(physics,nullptr,PxTransform(PxVec3(10,10,0)),jointed,PxTransform(PxIdentity));
    require(joint,"joint creation failed");joint->setBreakForce(.001f,.001f);
    PxDestructionScene* stage=nullptr;
    if(!cpuControl) {
    PxDestructionStressChunk nodes[2]={{PxVec3(0),0,0,0,scene.getDirectGPUAPI().getShapeContactIndex(*chunks[0]),.125f,0},{PxVec3(0,2,0),1,1,0,scene.getDirectGPUAPI().getShapeContactIndex(*chunks[1]),.125f,0}};
    PxDestructionChunkMassProperties masses[2]{};masses[0].supported=1;masses[1].mass=1;masses[1].center[1]=2;for(unsigned i=0;i<3;++i)masses[1].inertia[i]=1;
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bond{0,1,PxVec3(0,1,0),PxVec3(0,1,0),1,1,1};PxDestructionMaterial material;
    if(!fracture){material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;}
    PxDestructionStressDesc desc;desc.chunks=nodes;desc.chunkCount=2;desc.chunkMassProperties=masses;desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=&bond;desc.bondCount=1;desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
    stage=scene.getDestructionScene();require(stage && stage->configureStress(desc),"native graph configuration failed");
    }
    scene.simulate(1.0f/60);
    if(splitFetch){const PxContactPairHeader* pairs=nullptr;PxU32 count=0;require(scene.fetchResultsStart(pairs,count,true),"split fetch was not ready");if(fracture)require(!count,"incomplete trial exposed contact headers");for(PxU32 i=0;i<count;++i)events.onContact(pairs[i],pairs[i].pairs,pairs[i].nbPairs);scene.fetchResultsFinish(&error);}
    else require(scene.fetchResults(true,&error)==!fracture,"fetch completion did not match fracture verdict");
    std::printf("publication fracture=%u split=%u error=%u advance=%u contact=%u trigger=%u wake=%u sleep=%u break=%u\n",unsigned(fracture),unsigned(splitFetch),error,events.advances,events.contacts,events.triggers,events.wakes,events.sleeps,events.breaks);
    if(fracture){require(error && stage->getLastStatus().error==8,"fixture did not reach native correction boundary");require(!events.total(),"incomplete native trial published simulation callbacks");require(!(joint->getConstraintFlags()&PxConstraintFlag::eBROKEN),"incomplete trial committed joint breakage");}
    else{require(!error,"accepted control failed");require(events.advances && events.wakes && events.breaks,"accepted control lost pose/wake/joint callbacks");require(joint->getConstraintFlags()&PxConstraintFlag::eBROKEN,"accepted control lost joint breakage");if(cpuControl)require(events.contacts && events.triggers,"CPU control lost contact/trigger callbacks");}
    if(stage)require(stage->clearStress(),"native cleanup failed");joint->release();jointed->release();trigger->release();triggerShape->release();ordinary->release();parent->release();for(auto* s:chunks)s->release();require(context.healthy(),"publication fixture GPU failure");
}
#include "native_query_controls.h"
}
int main(){try{queryControls(false,false);queryControls(false,true);queryControls(true,false);queryControls(true,true);run(false,false,true);run(false,true,true);run(false,false);run(true,false);run(false,true);run(true,true);return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
