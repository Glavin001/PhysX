// Vehicle2 must follow changing physical mass without using principal inertia
// axes as the car's forward/up axes. CPU test of the shared Vehicle2 wrapper;
// the fracture transaction itself is qualified by the separate GPU fixtures.
#include <PxPhysicsAPI.h>
#include <PxNativeVehicle.h>
#include <cstdio>
#include <stdexcept>
#include <vector>
using namespace physx;
void require(bool value, const char* message) { if (!value) throw std::runtime_error(message); }
struct Sample { PxTransform pose; PxVec3 velocity, angular; native::NativeVehicleState state; };
struct Fixture {
    PxDefaultAllocator allocator; PxDefaultErrorCallback errors;
    PxFoundation* foundation; PxPhysics* physics; PxDefaultCpuDispatcher* dispatcher;
    PxScene* scene; PxMaterial* material; PxRigidStatic* ground;
    Fixture() {
        foundation=PxCreateFoundation(PX_PHYSICS_VERSION,allocator,errors);
        physics=PxCreatePhysics(PX_PHYSICS_VERSION,*foundation,PxTolerancesScale(),false);
        require(physics,"physics"); PxInitExtensions(*physics,nullptr);
        dispatcher=PxDefaultCpuDispatcherCreate(1);
        PxSceneDesc sd(physics->getTolerancesScale());
        sd.gravity=PxVec3(0,-9.81f,0);sd.cpuDispatcher=dispatcher;sd.filterShader=PxDefaultSimulationFilterShader;
        scene=physics->createScene(sd);material=physics->createMaterial(.8f,.8f,0);
        ground=PxCreatePlane(*physics,PxPlane(0,1,0,0),*material);scene->addActor(*ground);
    }
    ~Fixture() {
        ground->release();scene->release();dispatcher->release();material->release();
        PxCloseExtensions();physics->release();foundation->release();
    }
};
void setMass(PxRigidDynamic& actor, float mass, PxVec3 inertia, PxVec3 center, bool permuted) {
    actor.setMass(mass);
    actor.setMassSpaceInertiaTensor(permuted?PxVec3(inertia.z,inertia.y,inertia.x):inertia);
    actor.setCMassLocalPose(PxTransform(center,permuted?PxQuat(PxHalfPi,PxVec3(0,1,0)):PxQuat(PxIdentity)));
    actor.wakeUp();
}
std::vector<Sample> run(bool permuted, bool changeMass, float yaw) {
    Fixture f; native::NativeVehicleDesc desc;
    PxCookingParams cooking(f.physics->getTolerancesScale());
    auto* car=native::NativeVehicle::create(*f.physics,*f.scene,cooking,*f.material,desc,
        PxTransform(PxVec3(0,.2f,0),PxQuat(yaw,PxVec3(0,1,0))));require(car,"car");
    setMass(*car->actor(),desc.mass,desc.moi,desc.cMassLocalPose.p,permuted);
    std::vector<Sample> samples;unsigned observations=0;
    for(unsigned tick=0;tick<480;++tick) {
        if(tick==240 && changeMass)
            setMass(*car->actor(),desc.mass*.7f,desc.moi*.55f,
                desc.cMassLocalPose.p+PxVec3(.12f,.06f,-.2f),permuted);
        car->setCommands(tick>=90&&tick<390?.65f:0,tick>=390?1:0,0,tick>=170&&tick<350?.24f:0);
        const float dt=1.f/60;car->step(dt);
        const auto loads=car->stepLoads();
        if(loads.substeps) {
            ++observations;PxVec3 linear=loads.gravityImpulse+loads.externalImpulse,angular(0);
            for(const auto& wheel:loads.wheels) {
                linear+=wheel.suspensionImpulse+wheel.tireImpulse;angular+=wheel.angularVelocityChange;
            }
            const PxVec3 expected=loads.actorLinearAcceleration*(car->actor()->getMass()*dt);
            require((linear-expected).magnitude()<.05f+expected.magnitude()*1e-4f,"mass refresh does not conserve command impulse");
            require((angular-loads.actorAngularAcceleration*dt).magnitude()<1e-5f,"principal inertia frame does not conserve angular command");
        }
        f.scene->simulate(dt);require(f.scene->fetchResults(true),"step");
        const auto state=car->state();require(state.pose.isValid()&&state.linearVelocity.isFinite(),"finite state");
        samples.push_back({state.pose,state.linearVelocity,car->actor()->getAngularVelocity(),state});
    }
    require(observations>300,"must exercise suspension and driving");
    require(samples.back().pose.p.magnitude()>5,"car must actually drive");
    car->release();return samples;
}
void mountsStayFixed() {
    Fixture f;f.scene->setGravity(PxVec3(0));native::NativeVehicleDesc desc;
    PxCookingParams cooking(f.physics->getTolerancesScale());
    auto* car=native::NativeVehicle::create(*f.physics,*f.scene,cooking,*f.material,desc,PxTransform(PxVec3(0,20,0)));
    require(car,"mount test car");car->step(1.f/60);
    PxShape* shapes[8];const auto n=car->actor()->getShapes(shapes,8);PxTransform before[8];
    require(n==5,"expect chassis plus wheel query shapes");
    for(PxU32 i=0;i<n;++i)before[i]=shapes[i]->getLocalPose();
    setMass(*car->actor(),desc.mass*.5f,desc.moi*.4f,desc.cMassLocalPose.p+PxVec3(.4f,-.2f,.3f),true);
    car->step(1.f/60);
    for(PxU32 i=0;i<n;++i) {
        const auto after=shapes[i]->getLocalPose();
        require((after.p-before[i].p).magnitude()<1e-5f,"COM change moved a chassis/wheel mount");
        require(PxAbs(after.q.dot(before[i].q))>1-1e-6f,"inertia axes rotated wheel shape");
    }
    require(car->actor()->getLinearVelocity().magnitudeSquared()==0,"refresh injected momentum");
    car->release();
}
int main(){try {
    mountsStayFixed();
    for(float yaw:{0.f,.63f})for(bool changing:{false,true}) {
        const auto reference=run(false,changing,yaw),permuted=run(true,changing,yaw);
        float maxPosition=0,maxVelocity=0,maxAngular=0;
        for(size_t i=0;i<reference.size();++i) {
            const auto& a=reference[i];const auto& b=permuted[i];
            maxPosition=PxMax(maxPosition,(a.pose.p-b.pose.p).magnitude());
            maxVelocity=PxMax(maxVelocity,(a.velocity-b.velocity).magnitude());
            maxAngular=PxMax(maxAngular,(a.angular-b.angular).magnitude());
            if(i==0) {
                require((a.pose.p-b.pose.p).magnitude()<1e-5f,"equivalent tensor changed first step position");
                require((a.velocity-b.velocity).magnitude()<1e-4f,"equivalent tensor changed first step velocity");
                require((a.angular-b.angular).magnitude()<1e-4f,"equivalent tensor changed first step rotation");
            }
            require(PxAbs(a.pose.q.dot(b.pose.q))>1-1e-4f,"equivalent tensor changed chassis orientation");
            for(unsigned w=0;w<4;++w) {
                require(PxAbs(a.state.wheels[w].jounce-b.state.wheels[w].jounce)<.002f,"equivalent tensor changed suspension");
                require((a.state.wheels[w].localPose.p-b.state.wheels[w].localPose.p).magnitude()<.002f,"equivalent tensor moved wheel mount");
            }
        }
        std::printf("mass-frame yaw=%g changing=%d max position=%g velocity=%g angular=%g\n",yaw,changing,maxPosition,maxVelocity,maxAngular);
        // Eight seconds of iterative tyre/contact solving accumulates roundoff
        // from the equivalent principal quaternion. Mount and command checks
        // above are much tighter; this is the long trajectory envelope.
        require(maxPosition<.1f&&maxVelocity<.1f&&maxAngular<.1f,"equivalent physical inertia changed driving trajectory");
    }
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
