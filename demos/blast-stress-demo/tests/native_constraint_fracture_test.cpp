// Real Vehicle2 suspension rows across a native GPU topology transaction.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <vehicle/physxConstraints/PxVehiclePhysXConstraintStates.h>
#include <cstdio>
#include <stdexcept>
using namespace physx;
static void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
static void near(const PxVec3& a,const PxVec3& b,const char* message){
    if((a-b).magnitude()>.003f){std::fprintf(stderr,"%s: got(%g,%g,%g) expected(%g,%g,%g)\n",message,a.x,a.y,a.z,b.x,b.y,b.z);throw std::runtime_error(message);}
}
static PxU32 prepare(Px1DConstraint* rows,PxVec3p& offset,PxU32 capacity,PxConstraintInvMassScale& scale,
    const void* block,const PxTransform& a,const PxTransform& b,bool ext,PxVec3p& ca,PxVec3p& cb) {
    auto n=vehicleConstraintSolverPrep(rows,offset,capacity,scale,block,a,b,ext,ca,cb);
    for(PxU32 i=0;i<n;++i)rows[i].flags|=Px1DConstraintFlag::eOUTPUT_FORCE;return n;
}
// Limit 2 must give the same result: the corrected evaluation changes nothing,
// but it audits the corrected checkpoint's apportioned commands itself.
static void run(PxSolverType::Enum solver,PxU32 carrier,bool disconnect,bool rotated,bool registered=true,PxU32 limit=1) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true,false,false,solver);
    auto& scene=context.scene();auto& physics=context.physics();
    const PxQuat rotation=rotated?PxQuat(.7f,PxVec3(0,1,0)):PxQuat(PxIdentity);
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(0,5,0),rotation));
    parent->setMass(2);parent->setMassSpaceInertiaTensor(PxVec3(1.0f/3,5.0f/6,5.0f/6));
    parent->setLinearDamping(0);parent->setAngularDamping(0);parent->setStabilizationThreshold(0);
    PxShape* shapes[2];
    for(PxU32 i=0;i<2;++i) {
        shapes[i]=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        shapes[i]->setLocalPose(PxTransform(PxVec3(i?.5f:-.5f,0,0)));require(parent->attachShape(*shapes[i]),"shape attachment");
    }
    scene.addActor(*parent);scene.simulate(1.0f/60);require(scene.fetchResults(true),"identity initialization");
    parent->setLinearVelocity(PxVec3(0));parent->setAngularVelocity(PxVec3(0));
    PxVehiclePhysXConstraintState rows[PxVehiclePhysXConstraintLimits::eNB_WHEELS_PER_PXCONSTRAINT];
    for(auto& row:rows)row.setToDefault();
    const PxU32 attached=disconnect?1-carrier:carrier;
    rows[0].suspActiveStatus=true;rows[0].suspLinear=PxVec3(0,1,0);
    rows[0].suspAngular=rotation.rotate(PxVec3(attached?.5f:-.5f,0,0)).cross(rows[0].suspLinear);
    PxVehicleConstraintConnector connector(rows);
    const PxConstraintShaderTable shader{prepare,visualiseVehicleConstraint,PxConstraintFlag::Enum(0)};
    auto* constraint=physics.createConstraint(parent,nullptr,connector,shader,sizeof(rows));require(constraint,"constraint creation");
    auto* stage=scene.getDestructionScene();require(stage,"native stage missing");
    PxDestructionStressChunk chunks[2];PxDestructionChunkMassProperties mass[2]{};
    for(PxU32 i=0;i<2;++i) {
        chunks[i]={PxVec3(i?.5f:-.5f,0,0),1,1.0f/6,0,stage->getShapeContactIndex(*shapes[i]),1,0};
        mass[i].center[0]=chunks[i].position.x;mass[i].mass=1;for(PxU32 k=0;k<3;++k)mass[i].inertia[k]=1.0/6;
    }
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bond{0,1,PxVec3(0),PxVec3(1,0,0),1,1,1};
    PxDestructionMaterial material;material.compressionElasticLimit=1;material.compressionFatalLimit=2;
    PxDestructionStressConstraint binding{constraint,attached,true,PxVec3(0),true,carrier};
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.chunkMassProperties=mass;
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=&bond;desc.bondCount=1;
    desc.materials=&material;desc.materialCount=1;desc.internalCorrectionLimit=limit;desc.enableChunkLoads=true;
    desc.maxIterations=128;desc.tolerance=1e-6f;
    if(registered){desc.constraints=&binding;desc.constraintCount=1;}
    if(registered) {
        binding.carrierChunk=2;require(!stage->configureStress(desc),"invalid carrier accepted");binding.carrierChunk=carrier;
        binding.replayWorldRows=false;require(!stage->configureStress(desc),"unmanaged fracture constraint accepted");binding.replayWorldRows=true;
    }
    require(stage->configureStress(desc),"managed world constraint configuration rejected");
    const float dt=1.0f/60;PxDestructionChunkLoad loads[2];loads[1].impulse=rotation.rotate(PxVec3(100*dt,0,0));
    require(stage->setChunkLoads(loads,2),"load submission");parent->addForce(loads[1].impulse,PxForceMode::eIMPULSE);
    scene.simulate(dt);PxU32 error=0;const bool fetched=scene.fetchResults(true,&error);const auto status=stage->getLastStatus();
    std::printf("%s limit=%u carrier=%u disconnect=%u rotated=%u registered=%u fetched=%u error=%u stage=%u blockers=%u broken=%u passes=%u\n",
        solver==PxSolverType::eTGS?"TGS":"PGS",limit,carrier,disconnect,rotated,registered,fetched,error,status.error,status.correctionBlockers,status.brokenBonds,status.correctionPasses);
    if(!registered) {
        require(status.correctionBlockers & PxDestructionCorrectionBlocker::eCONSTRAINT_ON_DESTRUCTION_BODY,"unregistered constraint bypassed guard");
        require(shapes[0]->getActor()==parent && shapes[1]->getActor()==parent,"blocked transaction mutated physical owners");
    } else {
        require(fetched && !error && !status.error,"managed constraint correction failed");
        require(status.brokenBonds==1 && status.correctionPasses==1,"expected one native corrected fracture");
        auto* bodies0=shapes[0]->getActor()->is<PxRigidDynamic>();auto* bodies1=shapes[1]->getActor()->is<PxRigidDynamic>();
        require(bodies0 && bodies1 && bodies0!=bodies1,"physical chunks did not split");PxRigidDynamic* bodies[2]={bodies0,bodies1};
        PxRigidActor *a,*b;constraint->getActors(a,b);require(a==bodies[carrier] && !b,"constraint did not follow its carrier");
        for(PxU32 i=0;i<2;++i) {
            const PxVec3 expected=(i?loads[1].impulse:PxVec3(0))+PxVec3(0,(!disconnect && i==carrier)?0:-9.81f*dt,0);
            near(bodies[i]->getLinearVelocity(),expected,"corrected fragment momentum");
            near(bodies[i]->getAngularVelocity(),PxVec3(0),"constraint was not recentered on GPU fragment COM");
        }
        PxVec3 force,torque;constraint->getForce(force,torque);
        near(force,disconnect?PxVec3(0):PxVec3(0,9.81f,0),"same-step constraint survived disconnection or lost support");
        near(torque,PxVec3(0),"same-step constraint retained old COM torque");
        // Keep the shader active deliberately. The native disconnection must
        // remain authoritative even if gameplay has not yet cleared wheel state.
        rows[0].suspAngular=PxVec3(0);constraint->markDirty();
        for(PxU32 tick=0;tick<8;++tick) {
            scene.simulate(dt);require(scene.fetchResults(true)&&!stage->getLastStatus().error,"post-fracture step failed");
            constraint->getForce(force,torque);
            near(force,disconnect?PxVec3(0):PxVec3(0,9.81f,0),"constraint state did not persist after fracture");
        }
    }
    require(stage->clearStress(),"managed constraint cleanup failed");
    PxRigidActor *a,*b;constraint->getActors(a,b);require(a==parent,"cleanup left a dangling fragment constraint");
    constraint->release();parent->release();for(auto* shape:shapes)shape->release();
    if(registered)require(context.healthy(),"native physics diagnostics");
}
// A physical sphere shoots one corner off a three-chunk assembly. The other
// corner has a stronger material and must stay attached throughout the run.
static void cannon(PxSolverType::Enum solver,PxU32 limit=1) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true,false,false,solver);
    auto& scene=context.scene();auto& physics=context.physics();
    auto* parent=physics.createRigidDynamic(PxTransform(PxVec3(0,5,0)));
    parent->setMass(3);parent->setMassSpaceInertiaTensor(PxVec3(.5f,2.5f,2.5f));
    parent->setLinearDamping(0);parent->setAngularDamping(0);parent->setStabilizationThreshold(0);
    PxShape* shapes[3];const PxVec3 positions[3]={PxVec3(0),PxVec3(1,0,0),PxVec3(-1,0,0)};
    for(PxU32 i=0;i<3;++i){shapes[i]=physics.createShape(PxBoxGeometry(.5f,.5f,.5f),context.material(),true);
        shapes[i]->setLocalPose(PxTransform(positions[i]));require(parent->attachShape(*shapes[i]),"cannon fixture shape");}
    scene.addActor(*parent);scene.simulate(1.0f/60);require(scene.fetchResults(true),"cannon initialization");
    parent->setLinearVelocity(PxVec3(0));
    PxVehiclePhysXConstraintState rows[2][PxVehiclePhysXConstraintLimits::eNB_WHEELS_PER_PXCONSTRAINT];
    for(auto& corner:rows)for(auto& row:corner)row.setToDefault();
    PxVehicleConstraintConnector connectors[2]={PxVehicleConstraintConnector(rows[0]),PxVehicleConstraintConnector(rows[1])};
    const PxConstraintShaderTable shader{prepare,visualiseVehicleConstraint,PxConstraintFlag::Enum(0)};PxConstraint* constraints[2];
    for(PxU32 w=0;w<2;++w)constraints[w]=physics.createConstraint(parent,nullptr,connectors[w],shader,sizeof(rows[w]));
    auto* stage=scene.getDestructionScene();require(stage,"cannon native stage");
    PxDestructionStressChunk chunks[3];PxDestructionChunkMassProperties mass[3]{};
    for(PxU32 i=0;i<3;++i){chunks[i]={positions[i],1,1.0f/6,0,stage->getShapeContactIndex(*shapes[i]),1,0};
        mass[i].mass=1;mass[i].center[0]=positions[i].x;for(PxU32 k=0;k<3;++k)mass[i].inertia[k]=1.0/6;}
    PxDestructionStressBond bonds[2]={{0,1,PxVec3(.5f,0,0),PxVec3(1,0,0),1,1,1,0},
        {0,2,PxVec3(-.5f,0,0),PxVec3(-1,0,0),1,1,1,1}};
    PxDestructionMaterial materials[2];materials[0].compressionElasticLimit=100;materials[0].compressionFatalLimit=200;
    materials[1].compressionElasticLimit=1e7f;materials[1].compressionFatalLimit=2e7f;
    PxDestructionStressConstraint bindings[2]={{constraints[0],1,true,PxVec3(0),true,0},{constraints[1],2,true,PxVec3(0),true,0}};
    PxDestructionStressCluster cluster{parent->getGPUIndex(),PxVec3(0)};
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=3;desc.chunkMassProperties=mass;desc.bonds=bonds;desc.bondCount=2;
    desc.materials=materials;desc.materialCount=2;desc.clusters=&cluster;desc.clusterCount=1;desc.internalCorrectionLimit=limit;
    desc.constraints=bindings;desc.constraintCount=2;desc.maxIterations=128;desc.tolerance=1e-6f;
    require(stage->configureStress(desc),"cannon configuration");
    PxRigidDynamic* shot=nullptr;bool detached=false;unsigned broken=0,corrections=0;float supportPeak=0;
    for(PxU32 tick=0;tick<150;++tick){
        if(tick==60){const auto center=(parent->getGlobalPose()*shapes[1]->getLocalPose()).p;
            shot=PxCreateDynamic(physics,PxTransform(center+PxVec3(0,0,-2)),PxSphereGeometry(.15f),context.material(),1);
            shot->setMass(2);shot->setMassSpaceInertiaTensor(PxVec3(.018f));shot->setLinearDamping(0);shot->setAngularDamping(0);
            shot->setLinearVelocity(PxVec3(0,0,20));scene.addActor(*shot);}
        for(PxU32 w=0;w<2;++w){rows[w][0].suspActiveStatus=true;rows[w][0].suspLinear=PxVec3(0,1,0);
            const auto world=(parent->getGlobalPose()*shapes[w+1]->getLocalPose()).p;
            const auto com=(parent->getGlobalPose()*parent->getCMassLocalPose()).p;
            rows[w][0].suspAngular=(world-com).cross(rows[w][0].suspLinear);constraints[w]->markDirty();}
        scene.simulate(1.0f/60);require(scene.fetchResults(true)&&!stage->getLastStatus().error,"cannon native step");
        const auto status=stage->getLastStatus();broken+=status.brokenBonds;corrections+=status.correctionPasses;
        require(shapes[0]->getActor()==shapes[2]->getActor(),"cannon destroyed the strong neighboring attachment");
        if(tick<60)require(!broken && shapes[1]->getActor()==parent,"assembly failed under its own weight before shot");
        if(shapes[1]->getActor()!=parent){detached=true;PxVec3 force,torque;constraints[0]->getForce(force,torque);
            near(force,PxVec3(0),"shot-off wheel retained suspension force");near(torque,PxVec3(0),"shot-off wheel retained constraint torque");
            require(constraints[0]->getFlags()&PxConstraintFlag::eDISABLE_CONSTRAINT,"disconnected wheel was not disabled");
            require(!(constraints[1]->getFlags()&PxConstraintFlag::eDISABLE_CONSTRAINT),"unhit connected wheel was disabled");
            constraints[1]->getForce(force,torque);supportPeak=PxMax(supportPeak,force.magnitude());}
    }
    require(detached && broken==1 && corrections==1,"physical cannonball did not cause one localized corrected fracture");
    require(supportPeak>1,"remaining connected suspension provided no support");
    require(stage->clearStress(),"cannon cleanup");for(auto* c:constraints)c->release();parent->release();shot->release();for(auto* shape:shapes)shape->release();
    require(context.healthy(),"cannon physics diagnostic");
    std::printf("PASS physical cannon %s limit=%u: 60 intact idle + 90 impact ticks, 3 chunks, 2 bonds, 1 projectile, one corner detached, neighbor retained; support peak %g N\n",
        solver==PxSolverType::eTGS?"TGS":"PGS",limit,supportPeak);
}
int main(){try{
    for(auto solver:{PxSolverType::ePGS,PxSolverType::eTGS})for(PxU32 carrier=0;carrier<2;++carrier)
        for(bool disconnect:{false,true})for(bool rotated:{false,true})run(solver,carrier,disconnect,rotated);
    run(PxSolverType::eTGS,0,false,false,false);cannon(PxSolverType::ePGS);cannon(PxSolverType::eTGS);
    for(PxU32 carrier=0;carrier<2;++carrier)for(bool disconnect:{false,true})for(bool rotated:{false,true})
        run(PxSolverType::eTGS,carrier,disconnect,rotated,true,2);
    cannon(PxSolverType::eTGS,2);return 0;
}catch(const std::exception& e){std::fprintf(stderr,"FAIL: %s\n",e.what());return 1;}}
