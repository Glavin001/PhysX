// Exact corner identities and solved wrench accounting; no fracture claim.
#include "../physx_scene.h"
#include "PxNativeVehicle.h"
#include <cstdio>
#include <stdexcept>
#include <set>
#include <memory>
using namespace physx;
static void require(bool value, const char* message) { if (!value) throw std::runtime_error(message); }
static void run(blast_demo::PhysicsMode mode, PxSolverType::Enum solver) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(mode, mode==blast_demo::PhysicsMode::Gpu, capacity, nullptr, false, true, false, false, solver);
    auto& scene=context.scene();
    native::NativeVehicleDesc desc;
    auto releaseCar=[](native::NativeVehicle* car){if(car)car->release();};
    std::unique_ptr<native::NativeVehicle,decltype(releaseCar)> owner(native::NativeVehicle::create(context.physics(), scene, context.cookingParams(), context.material(), desc,
        PxTransform(PxVec3(0,.15f,0))),releaseCar);
    auto* car=owner.get();
    require(car && car->constraintCount()==4, "expected one constraint per corner");
    require(!car->wheelConstraint(4), "out-of-range corner returned a constraint");
    std::set<PxConstraint*> identities;
    for (PxU32 w=0;w<4;++w) require(identities.insert(car->wheelConstraint(w)).second,"corners share a constraint");
    // Exclude ordinary chassis contacts from the force-conservation oracle.
    car->chassisShape()->setFlag(PxShapeFlag::eSIMULATION_SHAPE,false);
    // Momentum accounting excludes solver stabilization's independent velocity
    // projection. The separate production-settings feature test keeps it on.
    car->actor()->setStabilizationThreshold(0);
    car->actor()->setLinearDamping(0);car->actor()->setAngularDamping(0);
    car->actor()->setLinearVelocity(PxVec3(0,-5,0));
    const float dt=1.0f/60;
    unsigned observed=0;float peak=0,maxError=0;
    for(unsigned tick=0;tick<120;++tick) {
        if(tick==40) require(car->setFunctionalState(14,true),"disable one corner");
        if(tick==80) require(car->setFunctionalState(0,false),"disable all corners");
        const auto before=car->actor()->getLinearVelocity();
        car->setCommands(0,1,0,0);car->step(dt);
        const auto command=car->stepLoads();
        require(command.available,"missing command load observer");
        scene.simulate(dt);require(scene.fetchResults(true),"scene step");
        PxVec3 total(0);
        for(PxU32 w=0;w<4;++w) {
            PxVec3 force,torque;car->wheelConstraint(w)->getForce(force,torque);
            require(force.isFinite() && torque.isFinite(),"invalid solved wrench");
            total+=force;
            peak=PxMax(peak,force.magnitude());
            if(force.magnitude()>1) ++observed;
            if((tick>=80 || (tick>=40 && w==0)) && (force.magnitude()>1e-5f || torque.magnitude()>1e-5f)) std::fprintf(stderr,"disabled mode=%u tick=%u wheel=%u force=%g,%g,%g torque=%g,%g,%g\n",unsigned(mode),tick,w,force.x,force.y,force.z,torque.x,torque.y,torque.z);
            if(tick>=80 || (tick>=40 && w==0)) require(force.magnitude()<1e-5f && torque.magnitude()<1e-5f,"disabled wheel retains solved constraint load");
        }
        const auto expected=before+command.actorLinearAcceleration*dt+total*(dt/desc.mass);
        const float error=(expected-car->actor()->getLinearVelocity()).magnitude();
        maxError=PxMax(maxError,error);
        if(error>.02f) std::fprintf(stderr,"mode=%u tick=%u error=%g force=%g,%g,%g\n",unsigned(mode),tick,error,total.x,total.y,total.z);
        require(error<.02f,"per-wheel solved forces do not conserve scene velocity");
    }
    require(observed>0 && peak>100,"fixture never loaded wheel constraints");
    require(context.healthy(),"physics error");
    std::printf("%s %s corner constraints: %u nonzero samples, peak %g N, velocity residual %g m/s\n",
        mode==blast_demo::PhysicsMode::Gpu?"GPU":"CPU",solver==PxSolverType::eTGS?"TGS":"PGS",observed,peak,maxError);

}
int main() {try {for(auto solver:{PxSolverType::ePGS,PxSolverType::eTGS}) {run(blast_demo::PhysicsMode::Cpu,solver);run(blast_demo::PhysicsMode::Gpu,solver);}return 0;}
 catch(const std::exception& e) {std::fprintf(stderr,"FAIL: %s\n",e.what());return 1;}}
