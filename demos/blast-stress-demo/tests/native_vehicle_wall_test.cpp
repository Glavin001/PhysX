// A PhysX Vehicle SDK car driving through a native-destruction wall.
//
// The question this answers: do vehicles still work on a GPU-dynamics scene
// with the native destruction stage configured? The vehicle SDK is CPU-side
// code that raycasts the scene for road geometry and applies forces to an
// ordinary PxRigidDynamic. Both stay valid here because the scene keeps
// ordinary CPU actor access (no Direct GPU API), which is also what the
// native stage requires. The chassis is then just another rigid body whose
// solved contact impulses load the stress solver -- ramming a wall breaks it.
//
// Two runs share the fixture. The fracture run must break bonds, promote a
// fragment and drive the car past the wall's footprint. The control run gives
// the wall unbreakable material and must stop the car with zero bonds broken,
// which is what proves the fracture run's breakthrough is stress and not
// tunnelling through a kinematic parent.
//
// The vehicle SDK's suspension-limit and sticky-tyre constraints are
// PxConstraints attached to the chassis and the world. The native correction
// pass used to refuse any scene holding a PxConstraint; it now admits
// constraints on bodies the stage does not own, because such a constraint is
// prepared on the CPU from the restored start pose and its unchanged constant
// block, so the corrected solve rebuilds it exactly. The default run keeps
// them. --drop-constraints destroys them after creation (every component
// tolerates a NULL table) and is the configuration that worked before the
// gate was narrowed. --constrain-wall attaches a joint to the wall itself,
// which the stage owns, and asserts that PxDestructionStageStatus names that
// as the reason the fracture step is refused.
#include "../physx_scene.h"
#include "../state_writer.h"
#include <PxDestructionScene.h>
#include <PxNativeVehicle.h>
#include "extensions/PxD6Joint.h"
#include <array>
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

struct Options{bool fracture=true;bool dropConstraints=false;bool constrainWall=false;bool sweep=false;unsigned frames=480;bool verbose=false;std::string statePath;};

void run(const Options& options) {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,
        /*directGpu*/false,/*disableSleeping*/false,false,false,PxSolverType::eTGS,false,/*contactReports*/false);
    auto& scene=context.scene();auto& physics=context.physics();
    require(!(scene.getFlags()&PxSceneFlag::eENABLE_DIRECT_GPU_API),"fixture enabled Direct GPU");
    require(!(scene.getFlags()&PxSceneFlag::eENABLE_CCD),"fixture enabled CCD");
    require(scene.getFlags()&PxSceneFlag::eENABLE_GPU_DYNAMICS,"fixture is not a GPU scene");

    // The wall: a brick wall, 15 bricks wide and 6 courses high on a 0.4 m
    // pitch, one brick deep, straddling z=0. The bottom course is the authored
    // support (kinematic parent, mass 0 in the stress frame) and sits below
    // grade, its top flush with the ground: a support course is unbreakable by
    // construction, and a first version with it above ground stopped the car
    // dead on that course while every brick above it was already loose -- the
    // fragments all left the impact frame with exactly one tick of gravity and
    // no momentum from the car. The five courses above carry brick-density
    // mass and bond to their -x and -y neighbours, the native_destruction_main
    // pattern. Bricks rather than metre cubes because the car has to push what
    // it breaks, and two tonnes cannot shove sixteen tonnes of concrete cubes
    // across a 0.6-friction floor.
    const float pitch=0.4f;const PxVec3 half(pitch*.475f);const int width=15,height=6;
    const float density=1800,volume=8*half.x*half.y*half.z,chunkMass=density*volume;
    const float inertia=chunkMass*(half.y*half.y+half.z*half.z)*4/12; // cube: m(a^2+b^2)/12 with a=2h
    auto* wall=physics.createRigidDynamic(PxTransform(PxVec3(0,0,0)));
    wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    wall->setLinearDamping(0);wall->setAngularDamping(0);
    std::vector<PxShape*> shapes;std::vector<PxVec3> positions;
    std::vector<PxDestructionStressChunk> chunks;std::vector<PxDestructionChunkMassProperties> properties;
    std::vector<PxDestructionStressBond> bonds;
    PxVec3 center(0);
    for(int y=0;y<height;++y)for(int x=0;x<width;++x) {
        const PxVec3 p((float(x)-float(width-1)*.5f)*pitch,(float(y)-.5f)*pitch,0);
        auto* shape=physics.createShape(PxBoxGeometry(half),context.material(),true);
        require(shape,"chunk shape allocation failed");
        shape->setLocalPose(PxTransform(p));require(wall->attachShape(*shape),"chunk attachment failed");
        const unsigned id=unsigned(shapes.size());shapes.push_back(shape);positions.push_back(p);
        chunks.push_back({p,y?chunkMass:0.0f,y?inertia:0.0f,0,PX_INVALID_U32,volume,0});
        PxDestructionChunkMassProperties props{};props.mass=chunkMass;props.supported=y==0;
        for(unsigned k=0;k<3;++k){props.center[k]=p[k];props.inertia[k]=inertia;}properties.push_back(props);
        center+=p;
        if(x>0){const unsigned other=id-1;bonds.push_back({other,id,(p+positions[other])*.5f,(p-positions[other]).getNormalized(),4*half.y*half.z,1,1,0});}
        if(y>0){const unsigned other=id-unsigned(width);bonds.push_back({other,id,(p+positions[other])*.5f,(p-positions[other]).getNormalized(),4*half.x*half.z,1,1,0});}
    }
    center/=float(shapes.size());wall->setMass(chunkMass*float(shapes.size()));wall->setCMassLocalPose(PxTransform(center));
    scene.addActor(*wall);

    // The car, through the packaged helper: the snippet two-tonne car with
    // the chassis box colliding and kept out of scene queries.
    // The vehicle SDK measures suspension from the centre of mass, 0.55 m above
    // the actor origin, so the origin rests a few centimetres above the road.
    const PxVec3 start(0,0.1f,-18);
    NativeVehicleDesc carDesc;
    carDesc.keepConstraints=!options.dropConstraints;
    carDesc.sweepRoadQueries=options.sweep;
    NativeVehicle* vehicle=NativeVehicle::create(physics,scene,context.cookingParams(),context.material(),carDesc,PxTransform(start,PxQuat(PxIdentity)),"wallRammer");
    require(vehicle,"vehicle creation failed");
    require(vehicle->constraintCount()==(options.dropConstraints?0u:1u),"unexpected vehicle constraint count");
    PxRigidDynamic* car=vehicle->actor();PxShape* chassis=vehicle->chassisShape();
    require(car && chassis,"vehicle has no actor or chassis shape");
    const PxU32 wheelCount=4;
    PxD6Joint* wallJoint=nullptr;
    if(options.constrainWall) {
        // A joint on a stage-owned body is the constraint state the checkpoint
        // does not cover. World-attached, so it changes no island.
        wallJoint=PxD6JointCreate(physics,wall,PxTransform(PxIdentity),NULL,wall->getGlobalPose());
        require(wallJoint,"wall joint creation failed");
    }
    require(scene.getNbConstraints()==(options.dropConstraints?0u:1u)+(options.constrainWall?1u:0u),"unexpected constraint count");

    // Contact identities exist only after a step has seen the shapes.
    const float dt=1.0f/60;
    scene.simulate(dt);require(scene.fetchResults(true),"warm-up step failed");
    auto* destruction=scene.getDestructionScene();require(destruction,"native destruction stage unavailable");
    for(unsigned i=0;i<shapes.size();++i){chunks[i].contactIndex=destruction->getShapeContactIndex(*shapes[i]);require(chunks[i].contactIndex!=PX_INVALID_U32,"chunk identity unavailable");}
    PxDestructionStressCluster cluster{wall->getGPUIndex(),center};
    // Self-weight puts about 35 kPa of compression on the bottom bonds; the
    // car arrives at roughly 10 m/s and its stopping impulse is tens of times
    // that. The control run scales the same limits out of reach.
    PxDestructionMaterial material;
    material.compressionElasticLimit=80000;material.compressionFatalLimit=160000;
    material.tensionElasticLimit=20000;material.tensionFatalLimit=40000;
    material.shearElasticLimit=30000;material.shearFatalLimit=60000;
    if(!options.fracture) {
        material.compressionElasticLimit=1e12f;material.compressionFatalLimit=2e12f;
        material.tensionElasticLimit=1e12f;material.tensionFatalLimit=2e12f;
        material.shearElasticLimit=1e12f;material.shearFatalLimit=2e12f;
    }
    PxDestructionStressDesc desc;
    desc.chunks=chunks.data();desc.chunkCount=PxU32(chunks.size());desc.chunkMassProperties=properties.data();
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=bonds.data();desc.bondCount=PxU32(bonds.size());
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=256;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;desc.gpuIslandRepair=true;
    require(destruction->configureStress(desc),"native destruction configuration failed");

    // Optional TWSTATE1 recording for the offline recorder: every brick is a
    // box actor, the chassis a box, each wheel a sphere of the wheel radius.
    blast_demo::StateWriter writer;const bool recording=!options.statePath.empty();
    if(recording) {
        std::array<blast_demo::Camera,4> cameras;
        const PxVec3 focus(0,1,-4);
        const PxVec3 offsets[4]={PxVec3(-14,7,-16),PxVec3(-13,3.5f,-7),PxVec3(16,5,-14),PxVec3(0,4,-24)};
        for(unsigned i=0;i<4;++i){cameras[i].eye=focus+offsets[i];cameras[i].direction=(focus-cameras[i].eye).getNormalized();cameras[i].fovDegrees=50;}
        require(writer.open(options.statePath,60,options.frames,1280,720,1,float(options.frames)/60,0,cameras),"state output failed");
        unsigned id=0;
        for(unsigned i=0;i<shapes.size();++i){blast_demo::VisualActor visual;visual.parameters=half;visual.part=PxU8((i/unsigned(width))%2?2:0);require(writer.defineActor(id++,visual),"brick visual failed");}
        {blast_demo::VisualActor visual;visual.parameters=PxVec3(0.84097f,0.65458f,2.46971f);visual.part=1;require(writer.defineActor(id++,visual),"chassis visual failed");}
        for(unsigned w=0;w<wheelCount;++w){blast_demo::VisualActor visual;visual.shape=blast_demo::VisualActor::Shape::Sphere;visual.parameters=PxVec3(carDesc.wheelRadius);visual.part=4;require(writer.defineActor(id++,visual),"wheel visual failed");}
    }
    auto recordFrame=[&](unsigned frame) {
        if(!recording)return;
        std::vector<blast_demo::VisualPose> poses;poses.reserve(shapes.size()+1+wheelCount);
        for(unsigned i=0;i<shapes.size();++i){auto* actor=shapes[i]->getActor();auto* body=actor->is<PxRigidDynamic>();
            poses.push_back({i,actor->getGlobalPose()*shapes[i]->getLocalPose(),body&&body->isSleeping()});}
        const NativeVehicleState vs=vehicle->state();
        poses.push_back({unsigned(shapes.size()),vs.pose*chassis->getLocalPose(),false});
        for(unsigned w=0;w<wheelCount;++w)poses.push_back({unsigned(shapes.size())+1+w,vs.pose*vs.wheels[w].localPose,false});
        require(writer.writeFrame(frame,poses),"state capture failed");
    };
    // Drive. Full throttle, no steer, no brake, straight at the wall.
    const float wallFront=-half.z,wallBack=half.z;
    const float chassisFront=1.37003f+2.46971f; // chassis box front, in actor space
    unsigned brokenBonds=0,corrections=0,fragmentFrames=0,contactFrame=0;float peakSpeed=0,maxZ=-1e9f,momentumBefore=0,pose_z_before=start.z;
    PxRigidDynamic* fragment=nullptr;
    for(unsigned i=0;i<options.frames;++i) {
        vehicle->setCommands(/*throttle*/1,/*brake*/0,/*handbrake*/0,/*steer*/0);
        vehicle->step(dt);
        scene.simulate(dt);PxU32 error=0;
        const bool complete=scene.fetchResults(true,&error);const auto status=destruction->getLastStatus();
        if(!complete||error||status.error)std::fprintf(stderr,"vehicle wall fracture=%u frame=%u complete=%u error=%u destruction=%u\n",options.fracture,i,complete,error,status.error);
        if(options.constrainWall) {
            // The status names the blocker on every step, so a consumer can
            // check its scene before anything has fractured.
            require(status.correctionBlockers==PxDestructionCorrectionBlocker::eCONSTRAINT_ON_DESTRUCTION_BODY,"a joint on the wall was not reported as the correction blocker");
            if(!complete||status.error) {
                require(contactFrame && !complete && (status.error&8),"fracture with a joint on the wall was not refused as correction-required");
                std::fprintf(stderr,"constraint gate: frame %u refused correction, status error %u blockers %u; the vehicle drove %.1f m at up to %.2f m/s first\n",i,status.error,status.correctionBlockers,pose_z_before-start.z,peakSpeed);
                std::printf("vehicle wall constraint gate passed: fracture refused while a joint is attached to the wall\n");
                return;
            }
        } else {
            require(status.correctionBlockers==0,"vehicle constraints on the chassis were reported as correction blockers");
        }
        require(complete&&!error&&!status.error,"scene rejected a step with a vehicle present");
        brokenBonds+=status.brokenBonds;corrections+=status.correctionPasses;
        recordFrame(i);
        const NativeVehicleState vs=vehicle->state();const auto pose=vs.pose;const auto velocity=vs.linearVelocity;
        require(pose.isFinite()&&velocity.isFinite(),"vehicle state is not finite");
        const float speed=vs.forwardSpeed;
        peakSpeed=PxMax(peakSpeed,speed);maxZ=PxMax(maxZ,pose.p.z);
        if(!contactFrame && pose.p.z+chassisFront>=wallFront)contactFrame=i;
        unsigned promoted=0;
        for(auto* shape:shapes)if(shape->getActor()!=wall){++promoted;if(!fragment)fragment=shape->getActor()->is<PxRigidDynamic>();}
        if(promoted)++fragmentFrames;
        if(status.correctionPasses) {
            // The corrected solve must hand the car's momentum to the bricks it
            // released, not to the kinematic parent it hit in the trial solve.
            float fragmentMomentumZ=0;unsigned moving=0;
            for(auto* shape:shapes){auto* body=shape->getActor()->is<PxRigidDynamic>();if(!body||body==wall)continue;
                const auto v=body->getLinearVelocity();fragmentMomentumZ+=body->getMass()*v.z/float(body->getNbShapes());moving+=v.magnitude()>0.5f;}
            const float carMomentumZ=car->getMass()*velocity.z;
            std::fprintf(stderr,"impact frame=%u: momentum in=%.0f kg m/s, car after=%.0f, fragments after=%.0f, moving fragment shapes=%u\n",
                i,momentumBefore,carMomentumZ,fragmentMomentumZ,moving);
            require(carMomentumZ+fragmentMomentumZ>0.8f*momentumBefore,"corrected solve lost the car's momentum to the kinematic parent");
        }
        momentumBefore=car->getMass()*velocity.z;pose_z_before=pose.p.z;
        if(options.verbose)std::fprintf(stderr,"frame=%3u z=%7.3f y=%6.3f speed=%6.3f broken=%u (+%u) corrections=%u fragments=%u sleeping=%u hit=%u jounce=%.3f road=%.3f\n",
            i,pose.p.z,pose.p.y,speed,brokenBonds,status.brokenBonds,status.correctionPasses,promoted,car->isSleeping(),
            vs.wheels[0].onRoad,vs.wheels[0].jounce,vs.wheels[0].localPose.p.y);
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
        require(maxZ+chassisFront>wallBack,"car did not get through the broken wall");
    } else {
        require(brokenBonds==0,"unbreakable wall lost bonds");
        require(!fragment,"unbreakable wall released a fragment");
        require(maxZ+chassisFront<wallBack,"car tunnelled through an unbreakable kinematic wall");
    }
    require(!options.constrainWall,"constraint-gated run never reached the wall");
    if(recording)require(writer.finish(),"state output did not finish");
    require(destruction->clearStress(),"destruction teardown failed");
    vehicle->release();
    if(wallJoint)wallJoint->release();
    wall->release();for(auto* shape:shapes)shape->release();
    require(context.healthy(),"GPU errors");
    std::printf("vehicle wall fracture=%u passed: %u chunks, %u bonds, broken=%u, corrections=%u\n",
        options.fracture,unsigned(chunks.size()),unsigned(bonds.size()),brokenBonds,corrections);
}
}
int main(int argc,char** argv) {
    Options options;
    for(int i=1;i<argc;++i) {
        if(!std::strcmp(argv[i],"--no-fracture"))options.fracture=false;
        else if(!std::strcmp(argv[i],"--drop-constraints"))options.dropConstraints=true;
        else if(!std::strcmp(argv[i],"--constrain-wall"))options.constrainWall=true;
        else if(!std::strcmp(argv[i],"--sweep"))options.sweep=true;
        else if(!std::strcmp(argv[i],"--verbose"))options.verbose=true;
        else if(!std::strcmp(argv[i],"--frames")&&i+1<argc)options.frames=unsigned(std::atoi(argv[++i]));
        else if(!std::strcmp(argv[i],"--state")&&i+1<argc)options.statePath=argv[++i];
        else{std::fprintf(stderr,"usage: native_vehicle_wall_test [--no-fracture] [--drop-constraints] [--constrain-wall] [--sweep] [--frames N] [--state RECORDING.twstate] [--verbose]\n");return 2;}
    }
    try{run(options);return 0;}
    catch(const std::exception& e){std::fprintf(stderr,"native_vehicle_wall_test: %s\n",e.what());return 1;}
}
