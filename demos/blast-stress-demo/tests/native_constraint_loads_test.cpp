// GPU-to-stress routing of real solved constraint wrenches, not fracture yet.
#include "../physx_scene.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cstdio>
#include <stdexcept>
#include <cmath>
using namespace physx;
static void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}
static void near(const PxVec3& a,const PxVec3& b,const char* message){
    if((a-b).magnitude()>0.002f+0.0001f*b.magnitude()) {
        std::fprintf(stderr,"%s: got (%g,%g,%g), expected (%g,%g,%g)\n",message,a.x,a.y,a.z,b.x,b.y,b.z);
        throw std::runtime_error(message);
    }
}
static void run(PxSolverType::Enum solver,PxU32 attached,const PxQuat& orientation) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,false,true,false,false,solver);
    auto& scene=context.scene();auto& physics=context.physics();
    auto* body=physics.createRigidDynamic(PxTransform(PxVec3(0,4,0),orientation));
    body->setMass(2);body->setMassSpaceInertiaTensor(PxVec3(2,4,4));
    body->setLinearDamping(0);body->setAngularDamping(0);body->setStabilizationThreshold(0);
    PxShape* shapes[2];
    for(PxU32 i=0;i<2;++i) {
        shapes[i]=physics.createShape(PxBoxGeometry(.25f,.25f,.25f),context.material(),true);
        shapes[i]->setLocalPose(PxTransform(PxVec3(i?1.0f:-1.0f,0,0)));
        require(body->attachShape(*shapes[i]),"attach shape");
    }
    scene.addActor(*body);
    const PxTransform attachment(PxVec3(attached?1.0f:-1.0f,0,0));
    auto* joint=PxD6JointCreate(physics,body,attachment,nullptr,body->getGlobalPose()*attachment);
    require(joint,"joint creation");
    for(PxU32 axis=0;axis<6;++axis)joint->setMotion(PxD6Axis::Enum(axis),PxD6Motion::eLOCKED);
    const float dt=1.0f/60;
    scene.simulate(dt);require(scene.fetchResults(true),"identity initialization");
    auto* stage=scene.getDestructionScene();require(stage,"GPU native stage");
    PxDestructionStressChunk chunks[2];
    for(PxU32 i=0;i<2;++i)chunks[i]={PxVec3(i?1.0f:-1.0f,0,0),1,1,0,stage->getShapeContactIndex(*shapes[i])};
    PxDestructionStressCluster cluster{body->getGPUIndex(),PxVec3(0)};
    PxDestructionStressBond bond{0,1,PxVec3(0),PxVec3(1,0,0),1,1,1};
    PxDestructionStressConstraint binding{joint->getConstraint(),attached,false,attachment.p};
    PxDestructionStressDesc desc;desc.chunks=chunks;desc.chunkCount=2;desc.clusters=&cluster;desc.clusterCount=1;
    desc.bonds=&bond;desc.bondCount=1;desc.maxIterations=256;desc.tolerance=1e-5f;
    desc.constraints=&binding;desc.constraintCount=1;
    binding.chunk=2;require(!stage->configureStress(desc),"accepted invalid constraint chunk");binding.chunk=attached;
    PxDestructionStressConstraint duplicate[2]={binding,binding};desc.constraints=duplicate;desc.constraintCount=2;
    require(!stage->configureStress(desc),"double counted constraint identity");desc.constraints=&binding;desc.constraintCount=1;
    joint->setBreakForce(1,1);require(!stage->configureStress(desc),"accepted independently breakable constraint");joint->setBreakForce(PX_MAX_F32,PX_MAX_F32);
    desc.constraints=nullptr;require(!stage->configureStress(desc),"accepted null constraint list");desc.constraints=&binding;
    auto* other=physics.createRigidDynamic(PxTransform(PxVec3(10,5,0)));scene.addActor(*other);
    joint->setActors(other,nullptr);require(!stage->configureStress(desc),"accepted wrong owner");joint->setActors(body,nullptr);
    require(stage->configureStress(desc),"valid constraint registration rejected");
    float peak=0;
    for(PxU32 tick=0;tick<12;++tick) {
        if(tick==4)body->addTorque(PxVec3(.1f,.2f,.3f),PxForceMode::eIMPULSE);
        if(tick==8)for(PxU32 axis=0;axis<6;++axis)joint->setMotion(PxD6Axis::Enum(axis),PxD6Motion::eFREE);
        scene.simulate(dt);require(scene.fetchResults(true),"native constraint load step");
        require(stage->getLastStatus().error==0,"native constraint load stage error");
        const auto view=stage->getDeviceView();PxDestructionSurfaceLoad surface[2];PxDestructionVectorPair accelerations[2],bondForce;
        {PxScopedCudaLock lock(*context.cudaContextManager());
            require(cuEventSynchronize(view.readyEvent)==CUDA_SUCCESS,"load observation ordering");
            require(cuMemcpyDtoH(surface,CUdeviceptr(view.surfaceLoads),sizeof(surface))==CUDA_SUCCESS
                && cuMemcpyDtoH(accelerations,CUdeviceptr(view.nodeAccelerations),sizeof(accelerations))==CUDA_SUCCESS
                && cuMemcpyDtoH(&bondForce,CUdeviceptr(view.bondForces),sizeof(bondForce))==CUDA_SUCCESS,"load observation readback");}
        PxVec3 force,torque;joint->getConstraint()->getForce(force,torque);
        const auto pose=body->getGlobalPose();
        const auto localForce=pose.q.rotateInv(force);
        const auto localTorque=pose.q.rotateInv(torque+(pose.transform(attachment.p)-pose.transform(chunks[attached].position)).cross(force));
        near(surface[attached].force,localForce,"routed solved force");
        near(surface[attached].torque,localTorque,"routed solved torque about chunk COM");
        near(accelerations[attached].angular,-localTorque,"angular stress input omitted the solved torque");
        near(surface[1-attached].force,PxVec3(0),"unloaded neighbor received force");
        near(surface[1-attached].torque,PxVec3(0),"unloaded neighbor received torque");
        near(accelerations[attached].linear,pose.q.rotateInv(scene.getGravity())+localForce,"chunk acceleration omitted/doubled load");
        near(accelerations[1-attached].linear,pose.q.rotateInv(scene.getGravity()),"neighbor acceleration changed");
        require(bondForce.linear.isFinite() && bondForce.angular.isFinite(),"invalid bond solve");
        if(tick<4) {
            // Each one-kilogram half needs the interface to carry its weight.
            // Independent force balance, not a comparison with the route itself.
            const PxVec3 expectedForce=pose.q.rotateInv(scene.getGravity())*(attached? -1.0f:1.0f);
            near(bondForce.linear,expectedForce,"bond failed to transmit the neighbor's weight");
            near(bondForce.angular,chunks[attached].position.cross(expectedForce),"bond bending moment is unbalanced");
        }
        if(tick>=8) {near(surface[attached].force,PxVec3(0),"stale force after removing joint rows");near(surface[attached].torque,PxVec3(0),"stale torque after removing joint rows");}
        if(tick<4) {
            const PxVec3 netMoment=surface[attached].torque+chunks[attached].position.cross(surface[attached].force);
            near(netMoment,PxVec3(0),"static assembly has an unbalanced constraint moment");
        }
        peak=PxMax(peak,force.magnitude());
    }
    require(peak>10,"test produced no meaningful solved constraint force");
    require(stage->clearStress(),"clear constraint registration");
    joint->release();other->release();body->release();for(auto* shape:shapes)shape->release();
    require(context.healthy(),"physics diagnostic failure");
    std::printf("PASS %s chunk %u orientation (%g,%g,%g,%g), peak constraint force %g N\n",
        solver==PxSolverType::eTGS?"TGS":"PGS",attached,orientation.x,orientation.y,orientation.z,orientation.w,peak);
}
int main(){try{for(auto solver:{PxSolverType::ePGS,PxSolverType::eTGS})for(PxU32 attached=0;attached<2;++attached)
    for(const auto q:{PxQuat(PxIdentity),PxQuat(.7f,PxVec3(0,0,1))})run(solver,attached,q);
    return 0;}catch(const std::exception& e){std::fprintf(stderr,"FAIL: %s\n",e.what());return 1;}}
