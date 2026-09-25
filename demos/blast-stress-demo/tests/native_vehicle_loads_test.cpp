// Vehicle2 load observation must conserve the original model's velocity command.
// CPU reference scene: this qualifies the CPU-side Vehicle2 observer, not GPU
// fracture/constraint remapping. Output trajectories permit an unchanged-model
// comparison with the installed wrapper's matching headers and libraries.
#include <PxPhysicsAPI.h>
#include <PxNativeVehicle.h>
#include <cstdio>
#include <stdexcept>
#include <cmath>
using namespace physx;
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
int main(){try{
 PxDefaultAllocator allocator;PxDefaultErrorCallback errors;
 auto* foundation=PxCreateFoundation(PX_PHYSICS_VERSION,allocator,errors);require(foundation,"foundation");
 auto* physics=PxCreatePhysics(PX_PHYSICS_VERSION,*foundation,PxTolerancesScale(),false);require(physics,"physics");
 PxInitExtensions(*physics,nullptr);auto* dispatcher=PxDefaultCpuDispatcherCreate(1);
 PxSceneDesc sd(physics->getTolerancesScale());sd.gravity=PxVec3(0,-9.81f,0);sd.cpuDispatcher=dispatcher;sd.filterShader=PxDefaultSimulationFilterShader;
 auto* scene=physics->createScene(sd);auto* material=physics->createMaterial(.8f,.8f,0);
 auto* ground=PxCreatePlane(*physics,PxPlane(0,1,0,0),*material);scene->addActor(*ground);
 PxCookingParams cooking(physics->getTolerancesScale());native::NativeVehicleDesc desc;
 auto* car=native::NativeVehicle::create(*physics,*scene,cooking,*material,desc,PxTransform(PxVec3(0,.2f,0)));require(car,"vehicle creation");
 require(car->constraintCount()>0,"vehicle constraints were dropped");
 const float dt=1.0f/60;unsigned observations=0;float maxLinearError=0,maxAngularError=0;
 for(unsigned tick=0;tick<540;++tick){
   const float throttle=tick>=120&&tick<420?1.0f:0.0f;
   const float brake=tick>=420?1.0f:0.0f;
   const float steer=tick>=240&&tick<330?.6f:tick>=330&&tick<420?-.6f:0.0f;
   car->setCommands(throttle,brake,0,steer);car->step(dt);
#ifndef VEHICLE_LOADS_BASELINE
   const auto loads=car->stepLoads();
   if(loads.substeps){
     require(loads.available,"SDK did not install the load observer");
     ++observations;require(PxAbs(loads.duration-dt)<1e-7f,"observer missed a substep");
     PxVec3 linear=loads.gravityImpulse+loads.externalImpulse,angular(0);
     for(const auto& wheel:loads.wheels){linear+=wheel.suspensionImpulse+wheel.tireImpulse;angular+=wheel.angularVelocityChange;}
     const PxVec3 expected=loads.actorLinearAcceleration*(desc.mass*dt);
     const float linearError=(linear-expected).magnitude(),angularError=(angular-loads.actorAngularAcceleration*dt).magnitude();
     maxLinearError=PxMax(maxLinearError,linearError);maxAngularError=PxMax(maxAngularError,angularError);
     require(linearError<.05f+expected.magnitude()*1e-4f,"recorded wheel loads do not conserve linear impulse");
     require(angularError<1e-5f,"recorded wheel loads do not conserve angular velocity change");
   }
#endif
   scene->simulate(dt);require(scene->fetchResults(true),"vehicle step failed");
   const auto state=car->state();require(state.pose.isValid()&&state.linearVelocity.isFinite(),"invalid vehicle state");
   std::printf("%u %.9g %.9g %.9g %.9g %.9g %.9g\n",tick,state.pose.p.x,state.pose.p.y,state.pose.p.z,state.linearVelocity.x,state.linearVelocity.y,state.linearVelocity.z);
 }
#ifndef VEHICLE_LOADS_BASELINE
 require(observations>300,"load check never exercised driving");
 std::fprintf(stderr,"Vehicle2 observer: %u moving substep groups; max linear error=%g N s, angular error=%g rad/s\n",observations,maxLinearError,maxAngularError);
#endif
 car->release();ground->release();scene->release();dispatcher->release();material->release();PxCloseExtensions();physics->release();foundation->release();return 0;
}catch(const std::exception& error){std::fprintf(stderr,"%s\n",error.what());return 1;}}
