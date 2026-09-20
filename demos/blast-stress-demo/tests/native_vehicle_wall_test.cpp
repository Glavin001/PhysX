// A PhysX Vehicle SDK car on the native destruction stage.
//
// The question this answers: do vehicles still work on a GPU-dynamics scene
// with the native destruction stage configured? The vehicle SDK is CPU-side
// code that raycasts the scene for road geometry and applies forces to an
// ordinary PxRigidDynamic. Both stay valid here because the scene keeps
// ordinary CPU actor access (no Direct GPU API), which is also what the
// native stage requires. The chassis is then just another rigid body whose
// solved contact impulses load the stress solver -- ramming a wall breaks it.
//
// The fixture is a brick wall and the packaged NativeVehicle. The modes:
//
//   (default)          the car rams the wall at full throttle and must break
//                      through with its momentum handed to the bricks
//   --no-fracture      unbreakable wall: the car stops dead, nothing breaks,
//                      which proves the breakthrough is stress, not tunnelling
//   --drop-constraints the car without its PxConstraints, the configuration
//                      that worked before the correction gate was narrowed
//   --constrain-wall   a joint on the wall, which the stage owns, refuses the
//                      fracture step and the status names that blocker
//   --park             a car parked beside the wall while a round demolishes
//                      it must sleep with the rubble and wake on throttle
//   --rubble           the car crosses a field of loose bricks on sweep queries
//                      with dynamic bodies as road
//   --remote-fracture  a round fractures the wall while the car drives far
//                      away: its acceleration on the correction frame must
//                      equal its neighbours', so the vehicle's force command
//                      was replayed exactly once
//   --scale            a 600-brick wall: the vehicle's own step cost stays in
//                      microseconds
//   --resting-course   no car: pins a stage fault found while writing --park.
//                      A released fragment that was already resting on a
//                      static shape while part of the kinematic parent never
//                      forms a contact with it and free-falls out of the
//                      world; lifting the wall so the pair must be created
//                      after release avoids it. Expected to fail until the
//                      refilter of pre-existing kinematic-vs-static overlaps
//                      on ownership migration is fixed.
#include "../physx_scene.h"
#include "../state_writer.h"
#include <PxDestructionScene.h>
#include <PxNativeVehicle.h>
#include "extensions/PxD6Joint.h"
#include <algorithm>
#include <array>
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <string>
#include <vector>
using namespace physx;
using physx::native::NativeVehicle;
using physx::native::NativeVehicleDesc;
using physx::native::NativeVehicleState;
namespace {
void require(bool ok,const char* message){if(!ok)throw std::runtime_error(message);}

struct Options{
    enum Mode{eRAM,ePARK,eRUBBLE,eREMOTE_FRACTURE,eSCALE,eRESTING_COURSE} mode=eRAM;
    bool fracture=true,dropConstraints=false,constrainWall=false,sweep=false,verbose=false;
    unsigned frames=480;std::string statePath;
};

const float kDt=1.0f/60;
// Chassis box front in actor space: local pose z plus half extent.
const float kChassisFront=1.37003f+2.46971f;

// A brick wall: `width` bricks by `height` courses on a 0.4 m pitch, one brick
// deep, straddling z=0. The bottom course is the authored support (kinematic
// parent, mass 0 in the stress frame) and sits below grade, its top flush
// with the ground: a support course is unbreakable by construction, and a
// first version with it above ground stopped the car dead on that course while
// every brick above it was already loose -- the fragments all left the impact
// frame with exactly one tick of gravity and no momentum from the car. The
// courses above carry brick-density mass and bond to their -x and -y
// neighbours, the native_destruction_main pattern. Bricks rather than metre
// cubes because the car has to push what it breaks, and two tonnes cannot
// shove sixteen tonnes of concrete cubes across a 0.6-friction floor.
struct Wall {
    static constexpr float pitch=0.4f;
    PxVec3 half{pitch*.475f};
    int width=15,height=6;
    float chunkMass=0;
    PxRigidDynamic* actor=nullptr;
    std::vector<PxShape*> shapes;std::vector<PxVec3> positions;
    std::vector<PxDestructionStressChunk> chunks;std::vector<PxDestructionChunkMassProperties> properties;
    std::vector<PxDestructionStressBond> bonds;
    PxVec3 center{0};
    PxDestructionMaterial material;
    PxDestructionStressCluster cluster{};

    // lift raises the whole wall so the first released course does not start
    // in contact with the ground; see --resting-course.
    void build(PxPhysics& physics,PxMaterial& material_,PxScene& scene,int w,int h,float lift=0) {
        width=w;height=h;
        const float density=1800,volume=8*half.x*half.y*half.z;chunkMass=density*volume;
        const float inertia=chunkMass*(half.y*half.y+half.z*half.z)*4/12; // cube: m(a^2+b^2)/12 with a=2h
        actor=physics.createRigidDynamic(PxTransform(PxVec3(0,0,0)));
        actor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        actor->setLinearDamping(0);actor->setAngularDamping(0);
        for(int y=0;y<height;++y)for(int x=0;x<width;++x) {
            const PxVec3 p((float(x)-float(width-1)*.5f)*pitch,(float(y)-.5f)*pitch+lift,0);
            auto* shape=physics.createShape(PxBoxGeometry(half),material_,true);
            require(shape,"chunk shape allocation failed");
            shape->setLocalPose(PxTransform(p));require(actor->attachShape(*shape),"chunk attachment failed");
            const unsigned id=unsigned(shapes.size());shapes.push_back(shape);positions.push_back(p);
            chunks.push_back({p,y?chunkMass:0.0f,y?inertia:0.0f,0,PX_INVALID_U32,volume,0});
            PxDestructionChunkMassProperties props{};props.mass=chunkMass;props.supported=y==0;
            for(unsigned k=0;k<3;++k){props.center[k]=p[k];props.inertia[k]=inertia;}properties.push_back(props);
            center+=p;
            if(x>0){const unsigned other=id-1;bonds.push_back({other,id,(p+positions[other])*.5f,(p-positions[other]).getNormalized(),4*half.y*half.z,1,1,0});}
            if(y>0){const unsigned other=id-unsigned(width);bonds.push_back({other,id,(p+positions[other])*.5f,(p-positions[other]).getNormalized(),4*half.x*half.z,1,1,0});}
        }
        center/=float(shapes.size());actor->setMass(chunkMass*float(shapes.size()));actor->setCMassLocalPose(PxTransform(center));
        scene.addActor(*actor);
        // Self-weight puts about 35 kPa of compression on the bottom bonds; a
        // car at 10 m/s or a heavy round delivers tens of times that.
        material.compressionElasticLimit=80000;material.compressionFatalLimit=160000;
        material.tensionElasticLimit=20000;material.tensionFatalLimit=40000;
        material.shearElasticLimit=30000;material.shearFatalLimit=60000;
    }
    void makeUnbreakable() {
        material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;
        material.tensionElasticLimit=1e12f;material.tensionFatalLimit=2e12f;
        material.shearElasticLimit=1e12f;material.shearFatalLimit=2e12f;
    }
    // Contact identities exist only after a step has seen the shapes.
    void configure(PxDestructionScene& destruction) {
        for(unsigned i=0;i<shapes.size();++i){chunks[i].contactIndex=destruction.getShapeContactIndex(*shapes[i]);require(chunks[i].contactIndex!=PX_INVALID_U32,"chunk identity unavailable");}
        cluster={actor->getGPUIndex(),center};
        PxDestructionStressDesc desc;
        desc.chunks=chunks.data();desc.chunkCount=PxU32(chunks.size());desc.chunkMassProperties=properties.data();
        desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=bonds.data();desc.bondCount=PxU32(bonds.size());
        desc.materials=&material;desc.materialCount=1;desc.maxIterations=256;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;desc.gpuIslandRepair=true;
        require(destruction.configureStress(desc),"native destruction configuration failed");
    }
    unsigned promoted(PxRigidDynamic*& first) const {
        unsigned count=0;
        for(auto* shape:shapes)if(shape->getActor()!=actor){++count;if(!first)first=shape->getActor()->is<PxRigidDynamic>();}
        return count;
    }
    // Every brick body released from the parent, each once.
    std::vector<PxRigidDynamic*> fragments() const {
        std::vector<PxRigidDynamic*> bodies;
        for(auto* shape:shapes){auto* body=shape->getActor()->is<PxRigidDynamic>();if(!body||body==actor)continue;
            if(std::find(bodies.begin(),bodies.end(),body)==bodies.end())bodies.push_back(body);}
        return bodies;
    }
    void release(){actor->release();for(auto* shape:shapes)shape->release();}
};

struct Fixture {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context;
    PxScene& scene;PxPhysics& physics;
    PxDestructionScene* destruction=nullptr;
    Fixture():context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,
        /*directGpu*/false,/*disableSleeping*/false,false,false,PxSolverType::eTGS,false,/*contactReports*/false),
        scene(context.scene()),physics(context.physics()) {
        require(!(scene.getFlags()&PxSceneFlag::eENABLE_DIRECT_GPU_API),"fixture enabled Direct GPU");
        require(!(scene.getFlags()&PxSceneFlag::eENABLE_CCD),"fixture enabled CCD");
        require(scene.getFlags()&PxSceneFlag::eENABLE_GPU_DYNAMICS,"fixture is not a GPU scene");
    }
    // One warm-up step, then the stage.
    void warmUp() {
        scene.simulate(kDt);require(scene.fetchResults(true),"warm-up step failed");
        destruction=scene.getDestructionScene();require(destruction,"native destruction stage unavailable");
    }
    // Step everything once; the vehicle first, as a game loop would.
    PxDestructionStageStatus step(NativeVehicle* vehicle,const char* what) {
        if(vehicle)vehicle->step(kDt);
        scene.simulate(kDt);PxU32 error=0;
        const bool complete=scene.fetchResults(true,&error);const auto status=destruction->getLastStatus();
        if(!complete||error||status.error)std::fprintf(stderr,"%s: complete=%u error=%u destruction=%u blockers=%u\n",what,complete,error,status.error,status.correctionBlockers);
        require(complete&&!error&&!status.error,"scene rejected a step with a vehicle present");
        return status;
    }
    NativeVehicle* car(const NativeVehicleDesc& desc,const PxVec3& position,const PxQuat& rotation=PxQuat(PxIdentity),const char* name="car") {
        NativeVehicle* vehicle=NativeVehicle::create(physics,scene,context.cookingParams(),context.material(),desc,PxTransform(position,rotation),name);
        require(vehicle,"vehicle creation failed");
        require(vehicle->actor() && vehicle->chassisShape(),"vehicle has no actor or chassis shape");
        return vehicle;
    }
    // A heavy round: enough momentum to open a brick wall on its own.
    PxRigidDynamic* round(const PxVec3& from,const PxVec3& velocity,float mass=500,float radius=0.5f) {
        auto* shot=PxCreateDynamic(physics,PxTransform(from),PxSphereGeometry(radius),context.material(),1);
        shot->setMass(mass);shot->setMassSpaceInertiaTensor(PxVec3(0.4f*mass*radius*radius));
        // Rolling resistance stands in for the ground it would deform: a sphere
        // with no angular damping rolls forever and keeps every brick it
        // touches awake, which is the fixture's fault, not the vehicle's.
        shot->setLinearDamping(0.1f);shot->setAngularDamping(0.5f);shot->setLinearVelocity(velocity);
        scene.addActor(*shot);return shot;
    }
};

// Optional TWSTATE1 recording for the offline recorder: every brick is a box
// actor, the chassis a box, each wheel a sphere of the wheel radius, a round
// a sphere in the projectile colour.
struct Recording {
    blast_demo::StateWriter writer;bool active=false;
    const Wall* wall=nullptr;std::vector<NativeVehicle*> vehicles;std::vector<PxRigidDynamic*> rounds;
    void open(const std::string& path,unsigned frames,const Wall& w,const std::vector<NativeVehicle*>& cars,const std::vector<PxRigidDynamic*>& shots,const NativeVehicleDesc& desc,const PxVec3& focus) {
        if(path.empty())return;
        active=true;wall=&w;vehicles=cars;rounds=shots;
        std::array<blast_demo::Camera,4> cameras;
        const PxVec3 offsets[4]={PxVec3(-14,7,-16),PxVec3(-13,3.5f,-7),PxVec3(16,5,-14),PxVec3(0,4,-24)};
        for(unsigned i=0;i<4;++i){cameras[i].eye=focus+offsets[i];cameras[i].direction=(focus-cameras[i].eye).getNormalized();cameras[i].fovDegrees=50;}
        require(writer.open(path,60,frames,1280,720,1,float(frames)/60,0,cameras),"state output failed");
        unsigned id=0;
        for(unsigned i=0;i<wall->shapes.size();++i){blast_demo::VisualActor visual;visual.parameters=wall->half;visual.part=PxU8((i/unsigned(wall->width))%2?2:0);require(writer.defineActor(id++,visual),"brick visual failed");}
        for(size_t c=0;c<vehicles.size();++c) {
            {blast_demo::VisualActor visual;visual.parameters=desc.chassisHalfExtents;visual.part=1;require(writer.defineActor(id++,visual),"chassis visual failed");}
            for(unsigned w=0;w<4;++w){blast_demo::VisualActor visual;visual.shape=blast_demo::VisualActor::Shape::Sphere;visual.parameters=PxVec3(desc.wheelRadius);visual.part=4;require(writer.defineActor(id++,visual),"wheel visual failed");}
        }
        for(auto* shot:rounds) {
            PxShape* shape=nullptr;shot->getShapes(&shape,1);require(shape && shape->getGeometry().getType()==PxGeometryType::eSPHERE,"round is not a sphere");
            const float radius=static_cast<const PxSphereGeometry&>(shape->getGeometry()).radius;
            blast_demo::VisualActor visual;visual.shape=blast_demo::VisualActor::Shape::Sphere;visual.parameters=PxVec3(radius);visual.part=5;require(writer.defineActor(id++,visual),"round visual failed");
        }
    }
    void frame(unsigned index) {
        if(!active)return;
        std::vector<blast_demo::VisualPose> poses;unsigned id=0;
        for(auto* shape:wall->shapes){auto* actor=shape->getActor();auto* body=actor->is<PxRigidDynamic>();
            poses.push_back({id++,actor->getGlobalPose()*shape->getLocalPose(),body&&body->isSleeping()});}
        for(auto* vehicle:vehicles) {
            const NativeVehicleState vs=vehicle->state();
            poses.push_back({id++,vs.pose*vehicle->chassisShape()->getLocalPose(),vs.sleeping});
            for(unsigned w=0;w<4;++w)poses.push_back({id++,vs.pose*vs.wheels[w].localPose,vs.sleeping});
        }
        for(auto* shot:rounds)poses.push_back({id++,shot->getGlobalPose(),shot->isSleeping()});
        require(writer.writeFrame(index,poses),"state capture failed");
    }
    void finish(){if(active)require(writer.finish(),"state output did not finish");}
};

// The car rams the wall.
void ram(const Options& options) {
    Fixture f;Wall wall;wall.build(f.physics,f.context.material(),f.scene,15,6);
    if(!options.fracture)wall.makeUnbreakable();
    // The vehicle SDK measures suspension from the centre of mass, 0.55 m above
    // the actor origin, so the origin rests a few centimetres above the road.
    const PxVec3 start(0,0.1f,-18);
    NativeVehicleDesc carDesc;carDesc.keepConstraints=!options.dropConstraints;carDesc.sweepRoadQueries=options.sweep;
    NativeVehicle* vehicle=f.car(carDesc,start,PxQuat(PxIdentity),"wallRammer");
    require(vehicle->constraintCount()==(options.dropConstraints?0u:1u),"unexpected vehicle constraint count");
    PxRigidDynamic* car=vehicle->actor();
    PxD6Joint* wallJoint=nullptr;
    if(options.constrainWall) {
        // A joint on a stage-owned body is the constraint state the checkpoint
        // does not cover. World-attached, so it changes no island.
        wallJoint=PxD6JointCreate(f.physics,wall.actor,PxTransform(PxIdentity),NULL,wall.actor->getGlobalPose());
        require(wallJoint,"wall joint creation failed");
    }
    require(f.scene.getNbConstraints()==(options.dropConstraints?0u:1u)+(options.constrainWall?1u:0u),"unexpected constraint count");
    f.warmUp();wall.configure(*f.destruction);
    Recording recording;recording.open(options.statePath,options.frames,wall,{vehicle},{},carDesc,PxVec3(0,1,-4));

    const float wallFront=-wall.half.z,wallBack=wall.half.z;
    unsigned brokenBonds=0,corrections=0,fragmentFrames=0,contactFrame=0;float peakSpeed=0,maxZ=-1e9f,momentumBefore=0,zBefore=start.z;
    PxRigidDynamic* fragment=nullptr;
    for(unsigned i=0;i<options.frames;++i) {
        vehicle->setCommands(/*throttle*/1,/*brake*/0,/*handbrake*/0,/*steer*/0);
        vehicle->step(kDt);
        f.scene.simulate(kDt);PxU32 error=0;
        const bool complete=f.scene.fetchResults(true,&error);const auto status=f.destruction->getLastStatus();
        if(!complete||error||status.error)std::fprintf(stderr,"vehicle wall fracture=%u frame=%u complete=%u error=%u destruction=%u\n",options.fracture,i,complete,error,status.error);
        if(options.constrainWall) {
            // The status names the blocker on every step, so a consumer can
            // check its scene before anything has fractured.
            require(status.correctionBlockers==PxDestructionCorrectionBlocker::eCONSTRAINT_ON_DESTRUCTION_BODY,"a joint on the wall was not reported as the correction blocker");
            if(!complete||status.error) {
                require(contactFrame && !complete && (status.error&8),"fracture with a joint on the wall was not refused as correction-required");
                std::fprintf(stderr,"constraint gate: frame %u refused correction, status error %u blockers %u; the vehicle drove %.1f m at up to %.2f m/s first\n",i,status.error,status.correctionBlockers,zBefore-start.z,peakSpeed);
                std::printf("vehicle wall constraint gate passed: fracture refused while a joint is attached to the wall\n");
                return;
            }
        } else {
            require(status.correctionBlockers==0,"vehicle constraints on the chassis were reported as correction blockers");
        }
        require(complete&&!error&&!status.error,"scene rejected a step with a vehicle present");
        brokenBonds+=status.brokenBonds;corrections+=status.correctionPasses;
        recording.frame(i);
        const NativeVehicleState vs=vehicle->state();const auto pose=vs.pose;const auto velocity=vs.linearVelocity;
        require(pose.isFinite()&&velocity.isFinite(),"vehicle state is not finite");
        const float speed=vs.forwardSpeed;
        peakSpeed=PxMax(peakSpeed,speed);maxZ=PxMax(maxZ,pose.p.z);
        if(!contactFrame && pose.p.z+kChassisFront>=wallFront)contactFrame=i;
        const unsigned promoted=wall.promoted(fragment);
        if(promoted)++fragmentFrames;
        if(status.correctionPasses) {
            // The corrected solve must hand the car's momentum to the bricks it
            // released, not to the kinematic parent it hit in the trial solve.
            float fragmentMomentumZ=0;unsigned moving=0;
            for(auto* body:wall.fragments()){const auto v=body->getLinearVelocity();fragmentMomentumZ+=body->getMass()*v.z;moving+=v.magnitude()>0.5f;}
            const float carMomentumZ=car->getMass()*velocity.z;
            std::fprintf(stderr,"impact frame=%u: momentum in=%.0f kg m/s, car after=%.0f, fragments after=%.0f, moving fragments=%u\n",
                i,momentumBefore,carMomentumZ,fragmentMomentumZ,moving);
            require(carMomentumZ+fragmentMomentumZ>0.8f*momentumBefore,"corrected solve lost the car's momentum to the kinematic parent");
        }
        momentumBefore=car->getMass()*velocity.z;zBefore=pose.p.z;
        if(options.verbose)std::fprintf(stderr,"frame=%3u z=%7.3f y=%6.3f speed=%6.3f broken=%u (+%u) corrections=%u fragments=%u sleeping=%u hit=%u jounce=%.3f\n",
            i,pose.p.z,pose.p.y,speed,brokenBonds,status.brokenBonds,status.correctionPasses,promoted,vs.sleeping,vs.wheels[0].onRoad,vs.wheels[0].jounce);
        // The vehicle SDK is doing its job on this scene: the wheels found the
        // static ground and the drivetrain moves the car before it hits anything.
        if(i==60) {
            bool allWheelsOnRoad=true;
            for(PxU32 w=0;w<4;++w)allWheelsOnRoad&=vs.wheels[w].onRoad;
            require(allWheelsOnRoad,"wheel raycasts found no road on the GPU scene");
            require(speed>3 && pose.p.y>-0.2f && pose.p.y<0.3f,"vehicle did not accelerate on the GPU scene");
        }
        if(!contactFrame)require(status.brokenBonds==0,"wall broke before the car reached it");
        if(options.fracture && contactFrame && brokenBonds==0)require(i<contactFrame+120,"car reached the wall but nothing broke");
    }
    std::fprintf(stderr,"vehicle wall fracture=%u: contact frame=%u peak speed=%.2f m/s max z=%.2f broken bonds=%u corrections=%u fragment frames=%u\n",
        options.fracture,contactFrame,peakSpeed,maxZ,brokenBonds,corrections,fragmentFrames);
    require(contactFrame>0,"car never reached the wall");
    if(options.fracture) {
        require(brokenBonds>0,"car hit the wall and broke no bonds");
        require(fragment&&fragmentFrames>0,"broken bonds released no fragment body");
        require(corrections>0,"fracture happened without a correction pass");
        require(maxZ+kChassisFront>wallBack,"car did not get through the broken wall");
    } else {
        require(brokenBonds==0,"unbreakable wall lost bonds");
        require(!fragment,"unbreakable wall released a fragment");
        require(maxZ+kChassisFront<wallBack,"car tunnelled through an unbreakable kinematic wall");
    }
    require(!options.constrainWall,"constraint-gated run never reached the wall");
    recording.finish();
    require(f.destruction->clearStress(),"destruction teardown failed");
    vehicle->release();if(wallJoint)wallJoint->release();wall.release();
    require(f.context.healthy(),"GPU errors");
    std::printf("vehicle wall fracture=%u passed: %u chunks, %u bonds, broken=%u, corrections=%u\n",
        options.fracture,unsigned(wall.chunks.size()),unsigned(wall.bonds.size()),brokenBonds,corrections);
}

// A parked car beside a demolition. The reason /city lost its vehicle: an
// always-awake actor resting among rubble held every chunk in its contact
// island awake. The vehicle SDK applies its forces with autowake off and only
// wakes on a throttle or steer intent, so a parked car must go to sleep with
// the rubble around it, and throttle must wake it again.
void park(const Options& options) {
    // Lifted 5 cm: see --resting-course for why a course resting on the ground
    // at release cannot be part of a vehicle test yet.
    Fixture f;Wall wall;wall.build(f.physics,f.context.material(),f.scene,15,6,0.05f);
    // Parked right behind the wall where the round comes through, facing along
    // it, so the bricks it pushes out land against and on the car.
    NativeVehicleDesc carDesc;carDesc.keepConstraints=!options.dropConstraints;
    const PxQuat alongX(PxHalfPi,PxVec3(0,1,0));
    NativeVehicle* vehicle=f.car(carDesc,PxVec3(1.4f,0.1f,1.4f),alongX,"parked");
    PxRigidDynamic* car=vehicle->actor();
    // 500 kg at 25 m/s: 12.5 kN s into the middle of the wall from the front.
    PxRigidDynamic* shot=f.round(PxVec3(0,1.2f,-8),PxVec3(0,0,25));
    f.warmUp();wall.configure(*f.destruction);
    Recording recording;recording.open(options.statePath,options.frames+180,wall,{vehicle},{shot},carDesc,PxVec3(0,1,0));
    unsigned brokenBonds=0,sleptFrame=0,carSleptFrame=0;unsigned settled=0;bool shotInScene=true;
    for(unsigned i=0;i<options.frames;++i,++settled) {
        // The round has done its job two seconds in; a heavy sphere rolling
        // on a flat plane is not the rubble under test. Take it out.
        if(shotInScene && i==120){f.scene.removeActor(*shot);shotInScene=false;}
        // No commands at all: a driver sat still, or nobody in the car.
        const auto status=f.step(vehicle,"parked car");
        require(status.correctionBlockers==0,"parked car reported correction blockers");
        brokenBonds+=status.brokenBonds;recording.frame(i);
        const auto fragments=wall.fragments();
        unsigned awake=0;for(auto* body:fragments)awake+=!body->isSleeping();
        const NativeVehicleState vs=vehicle->state();
        if(!carSleptFrame && vs.sleeping)carSleptFrame=i;
        if(!sleptFrame && brokenBonds && !awake && vs.sleeping && !shotInScene)sleptFrame=i;
        if(options.verbose)std::fprintf(stderr,"frame=%3u broken=%u fragments=%zu awake=%u car sleeping=%u car y=%.3f\n",
            i,brokenBonds,fragments.size(),awake,vs.sleeping,vs.pose.p.y);
        if(sleptFrame && i>sleptFrame+60){++settled;break;}
    }
    const auto fragments=wall.fragments();
    unsigned awake=0;for(auto* body:fragments)awake+=!body->isSleeping();
    std::fprintf(stderr,"parked car: broken bonds=%u fragments=%zu awake=%u car asleep at frame %u everything asleep at frame %u\n",
        brokenBonds,fragments.size(),awake,carSleptFrame,sleptFrame);
    if(options.verbose) {
        for(auto* body:fragments)if(!body->isSleeping()){const auto p=body->getGlobalPose().p,v=body->getLinearVelocity(),w=body->getAngularVelocity();
            unsigned owned=0;for(auto* shape:wall.shapes)owned+=shape->getActor()==body;
            const auto b=body->getWorldBounds();
            std::fprintf(stderr,"  awake body %p at (%.2f,%.2f,%.2f) v=%.4f w=%.4f wake=%.3f shapes=%u (wall shapes %u) mass=%.1f bounds x[%.2f,%.2f] y[%.2f,%.2f] z[%.2f,%.2f] gpu=%u kinematic=%u flags=%u\n",(void*)body,p.x,p.y,p.z,v.magnitude(),w.magnitude(),body->getWakeCounter(),body->getNbShapes(),owned,body->getMass(),b.minimum.x,b.maximum.x,b.minimum.y,b.maximum.y,b.minimum.z,b.maximum.z,body->getGPUIndex(),unsigned(body->getRigidBodyFlags()&PxRigidBodyFlag::eKINEMATIC),unsigned(PxU32(body->getActorFlags())));
            for(unsigned k=0;k<wall.shapes.size();++k)if(wall.shapes[k]->getActor()==body){const auto lp=wall.shapes[k]->getLocalPose().p;
                std::fprintf(stderr,"     brick %u (col %u course %u) local (%.2f,%.2f,%.2f) simFlag=%u sq=%u\n",k,k%unsigned(wall.width),k/unsigned(wall.width),lp.x,lp.y,lp.z,unsigned(wall.shapes[k]->getFlags()&PxShapeFlag::eSIMULATION_SHAPE),unsigned(wall.shapes[k]->getFlags()&PxShapeFlag::eSCENE_QUERY_SHAPE));}}
    }
    require(brokenBonds>0 && !fragments.empty(),"the round did not open the wall");
    require(sleptFrame>0,"the parked car and the rubble did not all go to sleep");
    require(vehicle->state().sleeping && awake==0,"something woke again after settling");
    // Touching the rubble is the point: at least one brick came to rest against
    // or on the car, and that pile still slept.
    bool touching=false;
    const PxBounds3 carBounds=car->getWorldBounds(1.05f);
    for(auto* body:fragments)touching|=carBounds.intersects(body->getWorldBounds());
    require(touching,"no brick came to rest against the parked car; the fixture proves nothing");
    // Throttle wakes the car through the vehicle SDK's intent path, and it moves.
    const float xStart=car->getGlobalPose().p.x;
    unsigned wokeFrame=0;float travelled=0;
    for(unsigned i=0;i<180;++i) {
        vehicle->setCommands(1,0,0,0);
        f.step(vehicle,"parked car throttle");
        recording.frame(settled+i);
        const NativeVehicleState vs=vehicle->state();
        if(!wokeFrame && !vs.sleeping)wokeFrame=i+1;
        travelled=PxMax(travelled,PxAbs(vs.pose.p.x-xStart));
        if(options.verbose && i%20==0)std::fprintf(stderr,"throttle frame=%3u sleeping=%u speed=%.2f travelled=%.2f\n",i,vs.sleeping,vs.forwardSpeed,travelled);
    }
    std::fprintf(stderr,"parked car: woke on throttle at frame %u, travelled %.2f m in 3 s\n",wokeFrame,travelled);
    require(wokeFrame==1,"throttle did not wake the parked car on its first frame");
    require(travelled>1.0f,"the woken car did not drive away from the rubble");
    recording.finish();
    require(f.destruction->clearStress(),"destruction teardown failed");
    vehicle->release();shot->release();wall.release();
    require(f.context.healthy(),"GPU errors");
    std::printf("parked car passed: %u bonds broken, %zu fragments, all asleep by frame %u, woke on throttle\n",brokenBonds,fragments.size(),sleptFrame);
}

// Loose bricks strewn across the road, sleeping. Sweep road queries with
// dynamic bodies as road let the wheels ride over them; the chassis shoves
// what the wheels do not clear. No stage configuration: this is the vehicle
// over loose bodies.
void rubble(const Options& options) {
    Fixture f;
    // A 6 m deep strip of 160 half-bricks, jittered, dropped and settled:
    // debris smaller than the wheel radius, which a car can climb. A whole
    // 0.38 m brick is taller than the 0.34 m wheel -- a kerb, not rubble --
    // and a first version with 120 of them in two layers was a twelve-tonne
    // barricade the car bulldozed into a pile and stalled against.
    const PxVec3 half(0.1f);const float mass=1800*8*half.x*half.y*half.z;
    std::vector<PxRigidDynamic*> bricks;
    unsigned seed=12345;auto noise=[&](){seed=seed*1664525u+1013904223u;return float(seed>>8)/float(1u<<24);};
    for(unsigned i=0;i<160;++i) {
        const PxVec3 p(-3+6*noise(),0.15f+0.3f*noise(),-3+6*noise());
        const PxQuat q(noise()*PxTwoPi,PxVec3(0,1,0));
        auto* brick=PxCreateDynamic(f.physics,PxTransform(p,q),PxBoxGeometry(half),f.context.material(),1);
        brick->setMass(mass);brick->setMassSpaceInertiaTensor(PxVec3(mass*(half.y*half.y+half.z*half.z)*4/12));
        f.scene.addActor(*brick);bricks.push_back(brick);
    }
    for(unsigned i=0;i<180;++i){f.scene.simulate(kDt);require(f.scene.fetchResults(true),"rubble settling failed");}
    unsigned awake=0;for(auto* b:bricks)awake+=!b->isSleeping();
    require(awake<12,"rubble did not settle");
    // Sweeps, bricks as road, and ground clearance: the snippet car's bumper
    // sits 0.13 m off the road and reaches a 0.38 m brick a metre before its
    // front wheels do, so it bulldozes a growing pile instead of climbing it.
    // Raised to 0.40 m, the wheels meet the debris first.
    NativeVehicleDesc carDesc;carDesc.sweepRoadQueries=true;
    carDesc.roadQueryFlags=PxQueryFlags(PxQueryFlag::eSTATIC|PxQueryFlag::eDYNAMIC);
    carDesc.chassisLocalPose.p.y+=0.27f;
    NativeVehicle* vehicle=f.car(carDesc,PxVec3(0,0.1f,-16),PxQuat(PxIdentity),"crossing");
    f.warmUp();
    unsigned brickRoadFrames=0,onRoadFrames=0;float maxY=-1e9f,maxZ=-1e9f,minY=1e9f;
    for(unsigned i=0;i<options.frames;++i) {
        vehicle->setCommands(1,0,0,0);
        vehicle->step(kDt);
        f.scene.simulate(kDt);PxU32 error=0;
        require(f.scene.fetchResults(true,&error)&&!error,"rubble crossing step failed");
        const NativeVehicleState vs=vehicle->state();
        require(vs.pose.isFinite(),"vehicle state is not finite");
        maxY=PxMax(maxY,vs.pose.p.y);minY=PxMin(minY,vs.pose.p.y);maxZ=PxMax(maxZ,vs.pose.p.z);
        bool onBrick=false,onRoad=true;
        for(unsigned w=0;w<4;++w){onRoad&=vs.wheels[w].onRoad;onBrick|=vs.wheels[w].onRoad && vs.wheels[w].roadActor && vs.wheels[w].roadActor->is<PxRigidDynamic>();}
        brickRoadFrames+=onBrick;onRoadFrames+=onRoad;
        if(options.verbose && i%20==0)std::fprintf(stderr,"frame=%3u z=%7.3f y=%6.3f speed=%6.3f onBrick=%u\n",i,vs.pose.p.z,vs.pose.p.y,vs.forwardSpeed,onBrick);
        if(vs.pose.p.z>8)break;
    }
    std::fprintf(stderr,"rubble crossing: max z=%.2f y in [%.2f,%.2f] frames with a brick under a wheel=%u all wheels on road=%u\n",maxZ,minY,maxY,brickRoadFrames,onRoadFrames);
    require(maxZ>8,"the car did not cross the rubble field");
    require(brickRoadFrames>0,"no wheel ever stood on a brick; dynamic road queries did nothing");
    require(minY>-0.3f && maxY<1.2f,"the car went through the floor or over the sky");
    vehicle->release();for(auto* b:bricks)b->release();
    require(f.context.healthy(),"GPU errors");
    std::printf("rubble crossing passed: %u frames on bricks, max height %.2f m\n",brickRoadFrames,maxY);
}

// The vehicle's force command on a correction frame. A round fractures the
// wall while the car accelerates 40 m away on open road, untouched by the
// event. The checkpoint restores the car and replays its acceleration once:
// the speed gained on the correction frame must match its neighbours.
void remoteFracture(const Options& options) {
    Fixture f;Wall wall;wall.build(f.physics,f.context.material(),f.scene,15,6);
    NativeVehicleDesc carDesc;
    NativeVehicle* vehicle=f.car(carDesc,PxVec3(40,0.1f,-10),PxQuat(PxIdentity),"remote");
    PxRigidDynamic* shot=f.round(PxVec3(0,1.2f,-3),PxVec3(0,0,25));
    f.warmUp();wall.configure(*f.destruction);
    std::vector<float> gains;std::vector<bool> corrected;float previous=0;unsigned corrections=0;
    for(unsigned i=0;i<120;++i) {
        vehicle->setCommands(1,0,0,0);
        const auto status=f.step(vehicle,"remote fracture");
        require(status.correctionBlockers==0,"remote car reported correction blockers");
        const NativeVehicleState vs=vehicle->state();
        gains.push_back(vs.forwardSpeed-previous);previous=vs.forwardSpeed;
        corrected.push_back(status.correctionPasses>0);corrections+=status.correctionPasses;
        if(options.verbose)std::fprintf(stderr,"frame=%3u speed=%.4f gain=%.5f correction=%u broken=%u\n",i,vs.forwardSpeed,gains.back(),status.correctionPasses,status.brokenBonds);
    }
    require(corrections>0,"the round did not fracture the wall");
    // On every correction frame, compare the speed gain with the nearest
    // uncorrected frames on either side. Acceleration changes slowly at these
    // speeds, so a replayed-twice or dropped force command stands out.
    unsigned checked=0;float worst=0;
    for(unsigned i=10;i+3<gains.size();++i) {
        if(!corrected[i])continue;
        float sum=0;unsigned n=0;
        for(int d=-3;d<=3;++d){if(!d)continue;const unsigned j=unsigned(int(i)+d);if(!corrected[j]){sum+=gains[j];++n;}}
        require(n>=2,"correction frames too dense to compare");
        const float around=sum/float(n),on=gains[i];
        require(around>0.02f,"the car was not accelerating");
        worst=PxMax(worst,PxAbs(on-around)/around);++checked;
        std::fprintf(stderr,"remote fracture: correction at frame %u, speed gain on it %.5f m/s vs %.5f around it\n",i,on,around);
        require(PxAbs(on-around)<0.25f*around,"vehicle acceleration on a correction frame differs from its neighbours: force replayed wrongly");
    }
    require(checked>0,"no correction frame could be compared");
    require(f.destruction->clearStress(),"destruction teardown failed");
    vehicle->release();shot->release();wall.release();
    require(f.context.healthy(),"GPU errors");
    std::printf("remote fracture passed: %u correction frames, worst acceleration deviation %.1f%%\n",checked,worst*100);
}

// Cost. A 600-brick wall and the car's own step: the vehicle model and its
// four scene queries against a scene full of GPU-resident bodies.
void scale(const Options& options) {
    Fixture f;Wall wall;wall.build(f.physics,f.context.material(),f.scene,60,10);
    NativeVehicleDesc carDesc;carDesc.sweepRoadQueries=options.sweep;
    NativeVehicle* vehicle=f.car(carDesc,PxVec3(0,0.1f,-18),PxQuat(PxIdentity),"scale");
    f.warmUp();wall.configure(*f.destruction);
    double vehicleUs=0,sceneUs=0;unsigned brokenBonds=0,frames=0;
    for(unsigned i=0;i<options.frames;++i) {
        vehicle->setCommands(1,0,0,0);
        const auto t0=std::chrono::steady_clock::now();
        vehicle->step(kDt);
        const auto t1=std::chrono::steady_clock::now();
        f.scene.simulate(kDt);PxU32 error=0;
        const bool complete=f.scene.fetchResults(true,&error);
        const auto t2=std::chrono::steady_clock::now();
        const auto status=f.destruction->getLastStatus();
        require(complete&&!error&&!status.error,"scale step failed");
        brokenBonds+=status.brokenBonds;++frames;
        vehicleUs+=std::chrono::duration<double,std::micro>(t1-t0).count();
        sceneUs+=std::chrono::duration<double,std::micro>(t2-t1).count();
        if(vehicle->state().pose.p.z>12)break;
    }
    std::fprintf(stderr,"scale: %u bricks, %u frames, vehicle step %.1f us/frame, scene step %.0f us/frame, broken bonds %u\n",
        unsigned(wall.shapes.size()),frames,vehicleUs/frames,sceneUs/frames,brokenBonds);
    require(brokenBonds>0,"the car did not break the big wall");
    require(vehicleUs/frames<500,"vehicle step cost exceeded 500 microseconds per frame");
    require(f.destruction->clearStress(),"destruction teardown failed");
    vehicle->release();wall.release();
    require(f.context.healthy(),"GPU errors");
    std::printf("scale passed: vehicle step %.1f us/frame beside %u bricks\n",vehicleUs/frames,unsigned(wall.shapes.size()));
}
// No car. The wall sits with its first released course resting on the ground
// plane, a round opens it, and the two halves of that course must come to rest
// on the ground like every other brick. Today they never touch it.
void restingCourse(const Options& options) {
    Fixture f;Wall wall;wall.build(f.physics,f.context.material(),f.scene,15,6,0);
    PxRigidDynamic* shot=f.round(PxVec3(0,1.2f,-8),PxVec3(0,0,25));
    f.warmUp();wall.configure(*f.destruction);
    unsigned brokenBonds=0;
    for(unsigned i=0;i<options.frames;++i){brokenBonds+=f.step(nullptr,"resting course").brokenBonds;}
    require(brokenBonds>0,"the round did not open the wall");
    unsigned lost=0;
    for(auto* body:wall.fragments()) {
        const auto p=body->getGlobalPose().p;
        if(p.y<-1) {
            ++lost;
            std::fprintf(stderr,"fragment of %u bricks at y=%.1f m, speed %.1f m/s, sleeping=%u, below the ground:",body->getNbShapes(),p.y,body->getLinearVelocity().magnitude(),body->isSleeping());
            for(unsigned k=0;k<wall.shapes.size();++k)if(wall.shapes[k]->getActor()==body)std::fprintf(stderr," (col %u course %u)",k%unsigned(wall.width),k/unsigned(wall.width));
            std::fprintf(stderr,"\n");
        }
    }
    std::fprintf(stderr,"resting course: %u bonds broken, %zu fragments, %u below the world\n",brokenBonds,wall.fragments().size(),lost);
    require(f.destruction->clearStress(),"destruction teardown failed");
    shot->release();wall.release();
    require(f.context.healthy(),"GPU errors");
    require(lost==0,"a fragment released while resting on the ground fell through it");
    std::printf("resting course passed: every released brick rests on the ground\n");
}
}
int main(int argc,char** argv) {
    Options options;
    for(int i=1;i<argc;++i) {
        if(!std::strcmp(argv[i],"--no-fracture"))options.fracture=false;
        else if(!std::strcmp(argv[i],"--drop-constraints"))options.dropConstraints=true;
        else if(!std::strcmp(argv[i],"--constrain-wall"))options.constrainWall=true;
        else if(!std::strcmp(argv[i],"--sweep"))options.sweep=true;
        else if(!std::strcmp(argv[i],"--park"))options.mode=Options::ePARK;
        else if(!std::strcmp(argv[i],"--rubble"))options.mode=Options::eRUBBLE;
        else if(!std::strcmp(argv[i],"--remote-fracture"))options.mode=Options::eREMOTE_FRACTURE;
        else if(!std::strcmp(argv[i],"--scale"))options.mode=Options::eSCALE;
        else if(!std::strcmp(argv[i],"--resting-course"))options.mode=Options::eRESTING_COURSE;
        else if(!std::strcmp(argv[i],"--verbose"))options.verbose=true;
        else if(!std::strcmp(argv[i],"--frames")&&i+1<argc)options.frames=unsigned(std::atoi(argv[++i]));
        else if(!std::strcmp(argv[i],"--state")&&i+1<argc)options.statePath=argv[++i];
        else{std::fprintf(stderr,"usage: native_vehicle_wall_test [--no-fracture] [--drop-constraints] [--constrain-wall] [--sweep] [--park|--rubble|--remote-fracture|--scale|--resting-course] [--frames N] [--state RECORDING.twstate] [--verbose]\n");return 2;}
    }
    try {
        switch(options.mode) {
            case Options::ePARK:park(options);break;
            case Options::eRUBBLE:rubble(options);break;
            case Options::eREMOTE_FRACTURE:remoteFracture(options);break;
            case Options::eSCALE:scale(options);break;
            case Options::eRESTING_COURSE:restingCourse(options);break;
            default:ram(options);break;
        }
        return 0;
    }
    catch(const std::exception& e){std::fprintf(stderr,"native_vehicle_wall_test: %s\n",e.what());return 1;}
}
