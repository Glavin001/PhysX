#include "../physx_scene.h"
#include <NvBlastExtStressPhysXGpuActivity.h>
#include <NvBlastExtStressPhysXDirectGpu.h>
#include <NvBlastExtStressPhysXGpuHostMirror.h>
#include <extensions/PxCudaHelpersExt.h>
#include <extensions/PxD6Joint.h>
#include <cmath>
#include <cstdio>
#include <stdexcept>
#include <vector>

using namespace physx;
using namespace Nv::Blast;
using namespace blast_demo;
using physx::Ext::PxCudaHelpersExt;
namespace {
void require(bool value, const char* message) { if (!value) throw std::runtime_error(message); }
struct State { PxTransform pose; PxVec3 linear, angular; };
class Fixture
{
public:
    bool direct;
    PhysXScene context;
    std::vector<PxRigidDynamic*> bodies;
    ExtStressPhysXGpuActivity* activity;
    ExtStressPhysXGpuHostMirror* mirror = nullptr;
    PxRigidDynamicGPUIndex* index;
    PxTransform* pose;
    PxVec3* velocity;
    explicit Fixture(bool gpu, bool host = false, bool pgs = false)
        : direct(gpu), context(PhysicsMode::Gpu, true, SceneCapacity{}, nullptr, gpu, false, gpu, gpu && host, pgs ? PxSolverType::ePGS : PxSolverType::eTGS),
          activity(ExtStressPhysXGpuActivity::create(context.scene()))
    {
        require(activity && activity->available() == gpu, "activity capability mismatch");
        if(gpu && host)
        {
            mirror = ExtStressPhysXGpuHostMirror::create(context.scene());
            require(mirror && mirror->available(), "host mirror capability mismatch");
        }
        auto& cuda = *context.cudaContextManager();
        index = PxCudaHelpersExt::allocDeviceBuffer<PxRigidDynamicGPUIndex>(cuda, 1);
        pose = PxCudaHelpersExt::allocDeviceBuffer<PxTransform>(cuda, 1);
        velocity = PxCudaHelpersExt::allocDeviceBuffer<PxVec3>(cuda, 1);
        require(index && pose && velocity, "device allocation failed");
    }
    ~Fixture()
    {
        if(mirror) mirror->release();
        activity->release();
        auto& cuda = *context.cudaContextManager();
        PxCudaHelpersExt::freeDeviceBuffer(cuda, velocity);
        PxCudaHelpersExt::freeDeviceBuffer(cuda, pose);
        PxCudaHelpersExt::freeDeviceBuffer(cuda, index);
        for (auto* body : bodies) body->release();
    }
    PxRigidDynamic* box(PxVec3 position, float half = 0.5f, PxVec3 linear = PxVec3(0))
    {
        auto* body = context.physics().createRigidDynamic(PxTransform(position));
        const PxBoxGeometry geometry{PxVec3(half)};
        require(body && geometry.isValid(), "invalid box");
        auto* shape = context.physics().createShape(geometry, context.material(), true);
        require(shape && body->attachShape(*shape), "shape create failed");
        shape->release();
        body->setMass(1);
        body->setMassSpaceInertiaTensor(PxVec3(2.0f*half*half/3.0f));
        body->setLinearDamping(0); body->setAngularDamping(0);
        body->setLinearVelocity(linear);
        context.scene().addActor(*body);
        bodies.push_back(body);
        return body;
    }
    void step(unsigned n = 1)
    {
        while (n--)
        {
            context.scene().simulate(1.0f/60.0f);
            require(context.scene().fetchResults(true), "fetch failed");
            require(context.healthy(), "GPU error or capacity overflow");
            if(mirror) require(mirror->synchronize(bodies.data(),uint32_t(bodies.size())), "host mirror sync failed");
        }
    }
    State read(PxRigidDynamic* body)
    {
        if (!direct) return {body->getGlobalPose(),body->getLinearVelocity(),body->getAngularVelocity()};
        auto& cuda = *context.cudaContextManager();
        auto id = body->getGPUIndex();
        PxCudaHelpersExt::copyHToD(cuda,index,&id,1);
        // The reader runs on a nonblocking stream; establish completion of
        // the pageable host upload before it consumes this reused index slot.
        { PxScopedCudaLock lock(cuda); require(cuda.getCudaContext()->streamSynchronize(nullptr)==0,"index upload sync failed"); }
        auto& api = context.scene().getDirectGPUAPI();
        State state;
        require(api.getRigidDynamicData(pose,index,PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,1), "pose read failed");
        PxCudaHelpersExt::copyDToH(cuda,&state.pose,pose,1);
        require(api.getRigidDynamicData(velocity,index,PxRigidDynamicGPUAPIReadType::eLINEAR_VELOCITY,1), "linear read failed");
        PxCudaHelpersExt::copyDToH(cuda,&state.linear,velocity,1);
        require(api.getRigidDynamicData(velocity,index,PxRigidDynamicGPUAPIReadType::eANGULAR_VELOCITY,1), "angular read failed");
        PxCudaHelpersExt::copyDToH(cuda,&state.angular,velocity,1);
        if (!(state.pose.isFinite() && state.linear.isFinite() && state.angular.isFinite()))
            std::fprintf(stderr,"nonfinite GPU id=%u p=(%g,%g,%g) q=(%g,%g,%g,%g) v=(%g,%g,%g) w=(%g,%g,%g)\n",id,state.pose.p.x,state.pose.p.y,state.pose.p.z,state.pose.q.x,state.pose.q.y,state.pose.q.z,state.pose.q.w,state.linear.x,state.linear.y,state.linear.z,state.angular.x,state.angular.y,state.angular.z);
        require(state.pose.isFinite() && state.linear.isFinite() && state.angular.isFinite(), "nonfinite motion");
        return state;
    }
    void write(PxRigidDynamic* body, PxVec3 value, PxRigidDynamicGPUAPIWriteType::Enum type)
    {
        if (direct)
        {
            PxCudaHelpersExt::copyHToD(*context.cudaContextManager(),velocity,&value,1);
            require(activity->write(&body,1,velocity,type), "device activity command failed");
        }
        else
        {
            switch (type)
            {
            case PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY: body->setLinearVelocity(value); break;
            case PxRigidDynamicGPUAPIWriteType::eANGULAR_VELOCITY: body->setAngularVelocity(value); break;
            case PxRigidDynamicGPUAPIWriteType::eFORCE: body->addForce(value); break;
            case PxRigidDynamicGPUAPIWriteType::eTORQUE: body->addTorque(value); break;
            default: throw std::runtime_error("unsupported fixture write");
            }
        }
    }
    void asleep()
    {
        step(400);
        for(auto* body : bodies)
        {
            if (!body->isSleeping())
            {
                const auto state = read(body);
                std::fprintf(stderr,"sleep failure direct=%d flags=%u active=%u wc=%g y=%g speed=%g\n",
                    direct, unsigned(context.scene().getFlags()), context.statistics().nbActiveDynamicBodies,
                    body->getWakeCounter(), state.pose.p.y, state.linear.magnitude());
            }
            require(body->isSleeping(), "fixture did not reach native sleep");
            const auto motion = read(body);
            require(motion.linear.magnitudeSquared() == 0 && motion.angular.magnitudeSquared() == 0,
                "sleep retained device velocity");
        }
        require(context.statistics().nbActiveDynamicBodies == 0, "sleep did not retire island work");
    }
};
using Trace = std::vector<State>;
void record(Fixture& f, Trace& trace, unsigned ticks)
{
    while(ticks--)
    {
        f.step();
        for(auto* body : f.bodies) trace.push_back(f.read(body));
    }
}
Trace commands(bool direct)
{
    Fixture f(direct); Trace trace;
    auto* body = f.box(PxVec3(7,2,0));
    f.asleep();
    require(std::abs(f.read(body).pose.p.y-0.5f)<0.03f,"sleep lost device pose");
    body->setMass(2); // Metadata must not overwrite the current device pose.
    f.step(); trace.push_back(f.read(body));
    require(std::abs(trace.back().pose.p.y-0.5f)<0.03f,"metadata uploaded stale motion");
    f.write(body,PxVec3(0,240,0),PxRigidDynamicGPUAPIWriteType::eFORCE);
    record(f,trace,10);
    f.write(body,PxVec3(0,3,0),PxRigidDynamicGPUAPIWriteType::eTORQUE);
    record(f,trace,10);
    f.write(body,PxVec3(1,2,0),PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY);
    f.write(body,PxVec3(0,1,0),PxRigidDynamicGPUAPIWriteType::eANGULAR_VELOCITY);
    record(f,trace,10);
    return trace;
}
Trace metadataBatches(bool direct)
{
    Fixture f(direct); Trace trace;
    f.context.scene().setGravity(PxVec3(0));
    // More than a warp of updates, with distinct poses, and a non-multiple
    // batch tail. Current GPU motion must survive every CPU metadata upload.
    for(unsigned i=0;i<65;++i)
        f.box(PxVec3(3.0f*i,20.0f+(i%3),0),0.25f,PxVec3(0.1f*(i+1),0.2f,0));
    f.step();
    for(unsigned tick=0;tick<24;++tick)
    {
        for(unsigned i=0;i<f.bodies.size();++i)
        {
            f.bodies[i]->setMass(1.0f+float((i+tick)%7));
            f.bodies[i]->setLinearDamping(0.01f*float(tick%3));
        }
        // Mix first-time transfers with preservation in the same warp.
        if(tick==7)f.box(PxVec3(-20,23,0),0.25f,PxVec3(0.5f,0.2f,0));
        record(f,trace,1);
    }
    return trace;
}
Trace contactWake(bool direct)
{
    Fixture f(direct); Trace trace;
    auto* target=f.box(PxVec3(0,0.5f,0));
    f.asleep();
    f.box(PxVec3(-2,0.5f,0),0.25f,PxVec3(5,0,0));
    bool woke=false;
    for(unsigned i=0;i<50;++i)
    {
        record(f,trace,1);
        woke |= !target->isSleeping();
    }
    require(woke && f.read(target).pose.p.x>0.05f,"contact failed to wake finite-mass target");
    return trace;
}
Trace supportLoss(bool direct)
{
    Fixture f(direct); Trace trace;
    auto* support=f.context.physics().createRigidStatic(PxTransform(PxVec3(7,2,0)));
    auto* shape=f.context.physics().createShape(PxBoxGeometry(1,0.25f,1),f.context.material(),true);
    require(support && shape && support->attachShape(*shape),"support creation failed");
    shape->release(); f.context.scene().addActor(*support);
    auto* body=f.box(PxVec3(7,2.75f,0));
    f.asleep();
    require(f.read(body).pose.p.y>2.7f,"body missed its support");
    f.context.scene().removeActor(*support,true); support->release();
    record(f,trace,35);
    require(f.read(body).pose.p.y<2.0f,"lost support failed to wake body");
    return trace;
}
Trace jointWake(bool direct)
{
    Fixture f(direct); Trace trace;
    auto* a=f.box(PxVec3(0,0.5f,0));
    auto* b=f.box(PxVec3(2,0.5f,0));
    auto* joint=PxD6JointCreate(f.context.physics(),a,PxTransform(PxVec3(1,0,0)),b,PxTransform(PxVec3(-1,0,0)));
    require(joint,"joint create failed");
    f.asleep();
    f.write(a,PxVec3(0,360,0),PxRigidDynamicGPUAPIWriteType::eFORCE);
    record(f,trace,20);
    require(!b->isSleeping() && f.read(b).pose.p.y>0.55f,"wake failed to propagate through joint");
    joint->release();
    return trace;
}
void compare(const char* name, Trace (*run)(bool))
{
    const auto reference=run(false);
    const auto device=run(true);
    require(reference.size()==device.size(),"trace sizes differ");
    float worst=0;
    for(size_t i=0;i<reference.size();++i)
    {
        const auto& a=reference[i]; const auto& b=device[i];
        worst=std::max(worst,(a.pose.p-b.pose.p).magnitude());
        if ((a.pose.p-b.pose.p).magnitude()>0.0001f || (a.linear-b.linear).magnitude()>0.001f
            || (a.angular-b.angular).magnitude()>0.002f || std::abs(a.pose.q.dot(b.pose.q))<0.9999f)
        {
            std::fprintf(stderr,"%s mismatch sample=%zu dp=%g dv=%g dw=%g\n",name,i,
                (a.pose.p-b.pose.p).magnitude(),(a.linear-b.linear).magnitude(),(a.angular-b.angular).magnitude());
            std::fprintf(stderr,"reference p=(%g,%g,%g), device p=(%g,%g,%g)\n",
                a.pose.p.x,a.pose.p.y,a.pose.p.z,b.pose.p.x,b.pose.p.y,b.pose.p.z);
            if(i >= 2) std::fprintf(stderr,"previous reference p=(%g,%g,%g), device p=(%g,%g,%g)\n",
                reference[i-2].pose.p.x,reference[i-2].pose.p.y,reference[i-2].pose.p.z,
                device[i-2].pose.p.x,device[i-2].pose.p.y,device[i-2].pose.p.z);
            throw std::runtime_error("native/device physical outcome differs");
        }
    }
    std::printf("%s passed: %zu body samples, max position error %g m\n",name,reference.size(),worst);
}
Trace manualSleep(bool direct)
{
    Fixture f(direct); Trace trace;
    auto* body=f.box(PxVec3(0,5,0));
    f.step();
    for (unsigned cycle=0; cycle<3; ++cycle)
    {
        f.write(body,PxVec3(120,240,0),PxRigidDynamicGPUAPIWriteType::eFORCE);
        f.write(body,PxVec3(0,0,30),PxRigidDynamicGPUAPIWriteType::eTORQUE);
        body->putToSleep(); // Must cancel pending device forces too.
        require(body->isSleeping(),"manual sleep failed");
        f.write(body,PxVec3(0,2,0),PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY);
        record(f,trace,3);
        require(std::abs(trace.back().linear.x)<1e-6f && trace.back().angular.magnitude()<1e-6f,
            "manual sleep retained force or torque");
        require(std::abs(trace[trace.size()-3].linear.y-(2.0f-9.81f/60.0f))<0.001f,
            "sleep reset clobbered the later velocity command");
        const auto beforeSleep=f.read(body);
        body->putToSleep(); f.step();
        require(body->isSleeping(),"explicit sleep did not persist");
        require((f.read(body).pose.p-beforeSleep.pose.p).magnitude()<1e-6f,
            "explicit sleep integrated an extra frame");
        const auto stopped=f.read(body);
        if (stopped.linear.magnitudeSquared()!=0) std::fprintf(stderr,"manual sleep direct=%d cycle=%u v=(%g,%g,%g) wc=%g active=%u\n",direct,cycle,stopped.linear.x,stopped.linear.y,stopped.linear.z,body->getWakeCounter(),f.context.statistics().nbActiveDynamicBodies);
        require(stopped.linear.magnitudeSquared()==0,"manual sleep did not finalize velocity");
    }
    return trace;
}
void checkpointActivity()
{
    Fixture f(true);
    auto* body=f.box(PxVec3(0,2,0));
    f.step();
    auto* checkpoint=ExtStressPhysXDirectGpuMotionBuffer::create(f.context.scene());
    require(checkpoint && checkpoint->capture(&body,1),"awake checkpoint failed");
    const auto captured=f.read(body);
    const auto wakeCounter=body->getWakeCounter();
    f.asleep();
    require(checkpoint->restore(),"awake checkpoint restore failed");
    require(!body->isSleeping() && body->getWakeCounter()==wakeCounter,"checkpoint lost awake state");
    auto restored=f.read(body);
    require((restored.pose.p-captured.pose.p).magnitude()<1e-6f
        && (restored.linear-captured.linear).magnitude()<1e-6f,"checkpoint lost device motion");
    f.step();
    require(f.read(body).pose.p.y<captured.pose.p.y,"restored awake body remained dormant");
    f.asleep();
    require(checkpoint->capture(&body,1),"sleep checkpoint failed");
    const auto resting=f.read(body);
    f.write(body,PxVec3(0,10,0),PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY); f.step(5);
    require(checkpoint->restore() && body->isSleeping(),"checkpoint lost sleeping state");
    f.step(); restored=f.read(body);
    require(body->isSleeping() && (restored.pose.p-resting.pose.p).magnitude()<1e-6f
        && restored.linear.magnitudeSquared()==0,"sleeping checkpoint moved");
    f.write(body,PxVec3(0,3,0),PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY); f.step();
    require(f.read(body).pose.p.y>resting.pose.p.y+0.03f,"checkpoint sleep reset clobbered wake");
    require(checkpoint->capture(&body,1),"checkpoint recapture failed");
    f.context.scene().removeActor(*body);
    require(!checkpoint->restore(),"checkpoint accepted removed body");
    checkpoint->release();
    std::puts("checkpoint logical activity and device motion passed");
}
Trace replacement(bool direct)
{
    Fixture f(direct); Trace trace;
    auto* a=f.box(PxVec3(0,0.5f,0));
    auto* b=f.box(PxVec3(2,0.5f,0));
    f.asleep();
    f.write(a,PxVec3(0,3,0),PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY);
    f.write(b,PxVec3(0,4,0),PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY); f.step();
    a->putToSleep();
    f.context.scene().removeActor(*a); a->release(); f.bodies.erase(f.bodies.begin());
    auto* fragment=f.box(PxVec3(0,2,0),0.25f,PxVec3(0,2,0));
    record(f,trace,3);
    require(f.read(fragment).pose.isFinite() && f.read(fragment).pose.p.y>2.01f,"invalid replacement motion");
    return trace;
}
void producerBatchAndReplacement()
{
    Fixture f(true);
    auto* a=f.box(PxVec3(0,0.5f,0));
    auto* b=f.box(PxVec3(2,0.5f,0));
    f.asleep();
    auto& manager=*f.context.cudaContextManager();
    auto* values=PxCudaHelpersExt::allocDeviceBuffer<PxVec3>(manager,2);
    auto* host=PxCudaHelpersExt::allocPinnedHostBuffer<PxVec3>(manager,2);
    require(values && host,"batch buffer allocation failed");
    host[0]=PxVec3(0,3,0); host[1]=PxVec3(0,4,0);
    CUstream stream=nullptr; CUevent ready=nullptr;
    {
        PxScopedCudaLock lock(manager); auto* cuda=manager.getCudaContext();
        require(cuda->streamCreate(&stream,1)==0 && cuda->eventCreate(&ready,2)==0,"producer setup failed");
        require(cuda->memcpyHtoDAsync(reinterpret_cast<CUdeviceptr>(values),host,2*sizeof(PxVec3),stream)==0
            && cuda->eventRecord(ready,stream)==0,"producer enqueue failed");
    }
    PxRigidDynamic* bodies[]={a,b};
    require(f.activity->write(bodies,2,values,PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY,ready),
        "producer-event batch failed");
    f.step();
    require(std::abs(f.read(a).linear.y-(3.0f-9.81f/60))<0.001f
        && std::abs(f.read(b).linear.y-(4.0f-9.81f/60))<0.001f,"producer values or actor mapping lost");
    {
        PxScopedCudaLock lock(manager); auto* cuda=manager.getCudaContext();
        cuda->eventDestroy(ready); cuda->streamDestroy(stream);
    }
    PxCudaHelpersExt::freeDeviceBuffer(manager,values);
    PxCudaHelpersExt::freePinnedHostBuffer(manager,host);
    // Retire a body with a pending sleep reset, then allocate replacements.
    // A reused island/GPU index must not receive its predecessor's reset.
    a->putToSleep();
    f.context.scene().removeActor(*a); a->release(); f.bodies.erase(f.bodies.begin());
    auto* fragment=f.box(PxVec3(0,2,0),0.25f,PxVec3(0,2,0));
    f.step();
    require(f.read(fragment).pose.p.y>2.01f && f.read(fragment).linear.y>1.8f,
        "removed body's pending sleep corrupted its replacement");
    auto* articulation=f.context.physics().createArticulationReducedCoordinate();
    require(articulation && articulation->createLink(nullptr,PxTransform(PxVec3(4,2,0))),
        "articulation fixture creation failed");
    require(!f.context.scene().addArticulation(*articulation),"unsupported articulation accepted");
    require(articulation->getScene()==nullptr,"rejected articulation partially inserted");
    articulation->release();
    std::puts("producer event, replacement lifetime and articulation guard passed");
}
#if defined(PX_DIRECT_GPU_HOST_ACCESS_VERSION)
Trace thinBoxLanding(bool direct, bool pgs, bool movingKinematic = false)
{
    Fixture f(direct,true,pgs); Trace trace;
    PxActor* oldGround=nullptr;
    require(f.context.scene().getActors(PxActorTypeFlag::eRIGID_STATIC,&oldGround,1)==1,"missing fixture plane");
    f.context.scene().removeActor(*oldGround);
    auto* ground=f.context.physics().createRigidStatic(PxTransform(PxVec3(0,-0.5f,0)));
    auto* shape=f.context.physics().createShape(PxBoxGeometry(10,0.5f,10),f.context.material(),true);
    require(ground && shape && ground->attachShape(*shape),"ground creation failed");
    shape->release(); f.context.scene().addActor(*ground);
    auto* body=f.context.physics().createRigidDynamic(PxTransform(PxVec3(8,1,0)));
    shape=f.context.physics().createShape(PxBoxGeometry(2,0.25f,2),f.context.material(),true);
    require(body && shape && body->attachShape(*shape),"slab creation failed");
    shape->release();
    require(PxRigidBodyExt::setMassAndUpdateInertia(*body,100),"slab mass failed");
    body->setLinearDamping(0); body->setAngularDamping(0);
    f.context.scene().addActor(*body); f.bodies.push_back(body);
    body->addForce(PxVec3(100,0,0),PxForceMode::eIMPULSE);
    PxRigidDynamic* kinematic = nullptr;
    if(movingKinematic)
    {
        kinematic=f.box(PxVec3(-20,4,0));
        kinematic->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    }
    for(unsigned i=0; i<80; ++i)
    {
        if(kinematic) kinematic->setKinematicTarget(PxTransform(PxVec3(-20+0.01f*i,4,0)));
        record(f,trace,1);
    }
    std::fprintf(stderr,"thin landing direct=%d pgs=%d y=%g\n",direct,pgs,f.read(body).pose.p.y);
    require(f.read(body).pose.p.y>0.24f,"slab missed finite ground box");
    ground->release();
    return trace;
}
Trace thinBoxLandingTgs(bool direct) { return thinBoxLanding(direct,false); }
Trace thinBoxLandingPgs(bool direct) { return thinBoxLanding(direct,true); }
Trace landingWithKinematic(bool direct) { return thinBoxLanding(direct,true,true); }

Trace hostCommands(bool direct)
{
    Fixture f(direct,true); Trace trace;
    auto* body=f.box(PxVec3(0,8,0));
    // Initial state writes after insertion must arrive with the first upload.
    body->setLinearVelocity(PxVec3(1,2,0));
    body->setAngularVelocity(PxVec3(0,1,0));
    body->addForce(PxVec3(0,1,0),PxForceMode::eIMPULSE);
    record(f,trace,10);
    body->setGlobalPose(PxTransform(PxVec3(4,8,0)));
    if(f.mirror)
    {
        require(!f.mirror->synchronize(&body,1),"pending host command accepted a stale readback");
        require(body->getGlobalPose().p==PxVec3(4,8,0),"rejected mirror clobbered a pending teleport");
    }
    body->setLinearVelocity(PxVec3(0,0,0));
    record(f,trace,10);
    const auto before=f.read(body);
    require((before.pose.p-body->getGlobalPose().p).magnitude()<1e-6f,"host pose was not published");
    require((before.linear-body->getLinearVelocity()).magnitude()<1e-6f,"host velocity was not published");
    PxRaycastBuffer hit;
    require(f.context.scene().raycast(PxVec3(4,30,0),PxVec3(0,-1,0),30,hit),"raycast missed moved body");
    require(hit.hasBlock && hit.block.actor==body,"query acceleration structure retained the pre-teleport pose");
    if(f.mirror)
    {
        require(f.mirror->synchronize(&body,1),"repeated publication failed");
        const auto after=f.read(body);
        require(after.pose.p==before.pose.p && after.linear==before.linear && after.angular==before.angular,
            "host publication changed device motion");
    }
    // A single-field host command must preserve motion written on device even
    // when the CPU's other velocity component has not been refreshed yet.
    f.write(body,PxVec3(0,2,0),PxRigidDynamicGPUAPIWriteType::eANGULAR_VELOCITY);
    body->setLinearVelocity(PxVec3(1,1,0));
    record(f,trace,3);
    require(std::abs(f.read(body).angular.y-2)<1e-5f,"linear command overwrote device angular velocity");
    body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    const auto frozen=f.read(body).pose;
    record(f,trace,10);
    require((f.read(body).pose.p-frozen.p).magnitude()<1e-5f,"freezing moved the body");
    body->setKinematicTarget(PxTransform(PxVec3(6,8,0)));
    record(f,trace,1);
    require((f.read(body).pose.p-PxVec3(6,8,0)).magnitude()<1e-5f,"kinematic target was ignored");
    body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,false);
    body->setLinearVelocity(PxVec3(0,2,0));
    body->setAngularVelocity(PxVec3(0,0,0));
    record(f,trace,10);
    body->addForce(PxVec3(2,3,0),PxForceMode::eIMPULSE);
    body->addTorque(PxVec3(0,0.2f,0),PxForceMode::eIMPULSE);
    record(f,trace,3);
    body->addForce(PxVec3(60,120,0),PxForceMode::eFORCE);
    body->addTorque(PxVec3(0,3,0),PxForceMode::eFORCE);
    record(f,trace,10);
    body->addForce(PxVec3(1,2,0),PxForceMode::eVELOCITY_CHANGE);
    body->clearForce(PxForceMode::eVELOCITY_CHANGE);
    body->addForce(PxVec3(3,4,0),PxForceMode::eACCELERATION);
    record(f,trace,3);
    body->setRigidBodyFlag(PxRigidBodyFlag::eRETAIN_ACCELERATIONS,true);
    body->setForceAndTorque(PxVec3(0,20,0),PxVec3(0,0.1f,0),PxForceMode::eFORCE);
    record(f,trace,5);
    body->clearForce(); body->clearTorque();
    record(f,trace,3);
    // Device-side force assignment followed by native clearing must work even
    // when the body has never allocated CPU force-accumulator storage.
    auto* fresh=f.box(PxVec3(-8,8,0)); f.step();
    f.write(fresh,PxVec3(0,1000,0),PxRigidDynamicGPUAPIWriteType::eFORCE);
    fresh->clearForce();
    const auto prior=f.read(fresh);
    f.step();
    require(std::abs(f.read(fresh).linear.y-(prior.linear.y-9.81f/60))<1e-5f,
        "native clearForce did not clear a device-only force");
    record(f,trace,2);
    return trace;
}
#endif

void validation()
{
    Fixture f(true);
    auto* a=f.box(PxVec3(0,0.5f,0));
    auto* b=f.box(PxVec3(2,0.5f,0));
    f.asleep();
    auto type=PxRigidDynamicGPUAPIWriteType::eFORCE;
    require(!f.activity->write(nullptr,1,f.velocity,type),"null actor batch accepted");
    require(!f.activity->write(&a,1,nullptr,type),"null values accepted");
    PxRigidDynamic* duplicate[]={a,a};
    require(!f.activity->write(duplicate,2,f.velocity,type),"duplicate actor batch accepted");
    f.context.scene().removeActor(*b);
    PxRigidDynamic* mixed[]={a,b};
    require(!f.activity->write(mixed,2,f.velocity,type),"removed actor batch accepted");
    require(a->isSleeping(),"invalid batch partially woke actors");
    f.context.scene().addActor(*b); f.step();
    f.write(b,PxVec3(0,2,0),PxRigidDynamicGPUAPIWriteType::eLINEAR_VELOCITY);
    f.step(); require(f.read(b).pose.p.y>0.5f,"reinserted body index was stale");
    std::puts("batch rejection and actor reinsertion passed");
}
}
int main()
{
    try
    {
        compare("commands and metadata",commands);
        compare("batched metadata pose preservation",metadataBatches);
        compare("contact wake",contactWake);
        compare("support removal",supportLoss);
        compare("joint wake",jointWake);
        compare("manual sleep/wake cycles",manualSleep);
        checkpointActivity();
        compare("replacement",replacement);
        producerBatchAndReplacement();
        validation();
#if defined(PX_DIRECT_GPU_HOST_ACCESS_VERSION)
        compare("host commands, forces, query publication and kinematics",hostCommands);
        compare("thin box landing TGS",thinBoxLandingTgs);
        compare("thin box landing PGS",thinBoxLandingPgs);
        compare("landing beside a moving kinematic",landingWithKinematic);
#endif
        return 0;
    }
    catch(const std::exception& e) { std::fprintf(stderr,"gpu_activity_test FAILED: %s\n",e.what()); return 1; }
}
