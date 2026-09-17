// Native PhysX GPU destruction proof. The application authors assets and shots,
// calls simulate/fetchResults once per tick, and explicitly observes GPU motion
// for recording. It performs no stress solve, topology change or motion replay.
#include "physx_scene.h"
#include "state_writer.h"
#include "native_bombardment.h"
#include "native_scenario_geometry.h"
#include "native_phase_profiler.h"
#include "native_graph_diagnostics.h"
#include "native_graph_boundary_audit.h"
#include "native_gpu_consumer.h"
#include "native_stress_trace.h"
#include "PxgSimulationCore.h"
#include "PxgSimulationController.h"
#include <iomanip>
#include <PxDestructionScene.h>
#include <extensions/PxCollectionExt.h>
#include <extensions/PxSerialization.h>
#include <extensions/PxDefaultStreams.h>
#include <sstream>
#include <cuda.h>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <map>
#include <set>
#include <cstring>
#include <stdexcept>
#include <string>
#include <tuple>
#include <vector>
#ifdef NATIVE_FORCE_FRESHNESS_DIAGNOSTIC
#include "native_force_freshness_audit.h"
#endif
using namespace physx;
using namespace blast_demo;
namespace {
void require(bool x,const char* why){if(!x)throw std::runtime_error(why);}
void check(CUresult x){if(x!=CUDA_SUCCESS){const char* name=nullptr;cuGetErrorName(x,&name);throw std::runtime_error(name?name:"CUDA observation failed");}}
template<class T> void read(std::vector<T>& out,const T* ptr,size_t count){out.resize(count);if(count)check(cuMemcpyDtoH(out.data(),CUdeviceptr(ptr),sizeof(T)*count));}
struct Chunk {PxVec3 position;PxShape* shape;unsigned building;};
struct Shot {PxRigidDynamic* actor;unsigned visual;};
using Clock=std::chrono::steady_clock;
double ms(Clock::time_point start){return std::chrono::duration<double,std::milli>(Clock::now()-start).count();}
#include "../../tools/diagnostics/destruction-snapshot/native-capture.inl"
int run(int argc,char** argv){
    std::set<unsigned> snapshotSteps;
    if(const char* requested=std::getenv("PHYSX_SNAPSHOT_STEPS")){
        std::stringstream stream(requested);std::string item;while(std::getline(stream,item,','))snapshotSteps.insert(unsigned(std::stoul(item)));
    }
    std::string geometryName="building";
    const auto initializationBegin=Clock::now();
    bool standardScene=true,standardSleeping=true,traceStress=false,sceneQueryShapes=true;
    unsigned grid=3,waves=4,stressIterations=2048,recordFps=60,gpuTraceBufferMiB=512,stepLimit=0,reservePairs=~0u;bool profilePhases=false,recordState=false,preservePairs=false,auditMotion=false,gpuIslandRepair=false,auditIslands=false,preSolveIslands=false,preSolveContacts=false,preSolveSupport=false;float seconds=30;std::string output,statePath,motionPath,videoPath,gpuCamera="overview";bool gpuRender=false,profileGpu=false;std::string workload="bombardment";float launchSeconds=-1;unsigned freeBodies=0;bool deviceConnectivity=false,traceMotion=false,colorByCluster=false;float projectileMass=20000,materialStrength=1,frameStrength=1;std::string shotPath="aerial",layout="grid";
    for(int i=1;i<argc;++i){std::string flag=argv[i];require(i+1<argc,"missing option value");const char* value=argv[++i];
        if(flag=="--profile-gpu"){require(std::string(value)=="0" || std::string(value)=="1","--profile-gpu requires 0 or 1");profileGpu=std::string(value)=="1";}
        else if(flag=="--sleeping"){require(std::string(value)=="0" || std::string(value)=="1","--sleeping requires 0 or 1");standardSleeping=std::string(value)=="1";}
        else if(flag=="--standard-scene"){require(std::string(value)=="0" || std::string(value)=="1","--standard-scene requires 0 or 1");standardScene=std::string(value)=="1";}
        else if(flag=="--scene-query-shapes"){require(std::string(value)=="0" || std::string(value)=="1","--scene-query-shapes requires 0 or 1");sceneQueryShapes=std::string(value)=="1";}
        else if(flag=="--gpu-trace-buffer-mb"){gpuTraceBufferMiB=std::stoul(value);require(gpuTraceBufferMiB>=16 && gpuTraceBufferMiB<=4096,"GPU trace buffer must be 16..4096 MiB");}
        else if(flag=="--gpu-connectivity-owner"){require(std::string(value)=="0" || std::string(value)=="1","--gpu-connectivity-owner requires 0 or 1");deviceConnectivity=std::string(value)=="1";}
        else if(flag=="--color-by-cluster"){require(std::string(value)=="0" || std::string(value)=="1","--color-by-cluster requires 0 or 1");colorByCluster=std::string(value)=="1";}
        else if(flag=="--shot-path")shotPath=value;
        else if(flag=="--layout")layout=value;
        else if(flag=="--geometry")geometryName=value;
        else if(flag=="--frame-strength")frameStrength=std::stof(value);
        else if(flag=="--material-strength")materialStrength=std::stof(value);
        else if(flag=="--projectile-mass")projectileMass=std::stof(value);
        else if(flag=="--trace-stress"){require(std::string(value)=="0" || std::string(value)=="1","--trace-stress requires 0 or 1");traceStress=std::string(value)=="1";}
        else if(flag=="--trace-motion"){require(std::string(value)=="0" || std::string(value)=="1","--trace-motion requires 0 or 1");traceMotion=std::string(value)=="1";}
        else if(flag=="--free-bodies")freeBodies=std::stoul(value);
        else if(flag=="--workload")workload=value;
        else if(flag=="--launch-seconds")launchSeconds=std::stof(value);
        else if(flag=="--profile-phases"){require(std::string(value)=="0" || std::string(value)=="1","--profile-phases requires 0 or 1");profilePhases=std::string(value)=="1";}
        else if(flag=="--reserve-pairs"){reservePairs=unsigned(std::atol(value));}
        else if(flag=="--preserve-contact-pairs"){require(std::string(value)=="0" || std::string(value)=="1","--preserve-contact-pairs requires 0 or 1");preservePairs=std::string(value)=="1";}
        else if(flag=="--gpu-island-repair"){require(std::string(value)=="0" || std::string(value)=="1","--gpu-island-repair requires 0 or 1");gpuIslandRepair=std::string(value)=="1";}
        else if(flag=="--gpu-pre-solve-islands"){require(std::string(value)=="0" || std::string(value)=="1","--gpu-pre-solve-islands requires 0 or 1");preSolveIslands=std::string(value)=="1";}
        else if(flag=="--gpu-pre-solve-contacts"){require(std::string(value)=="0" || std::string(value)=="1","--gpu-pre-solve-contacts requires 0 or 1");preSolveContacts=std::string(value)=="1";}
        else if(flag=="--gpu-pre-solve-support"){require(std::string(value)=="0" || std::string(value)=="1","--gpu-pre-solve-support requires 0 or 1");preSolveSupport=std::string(value)=="1";}
        else if(flag=="--audit-islands"){require(std::string(value)=="0" || std::string(value)=="1","--audit-islands requires 0 or 1");auditIslands=std::string(value)=="1";}
        else if(flag=="--audit-motion"){require(std::string(value)=="0" || std::string(value)=="1","--audit-motion requires 0 or 1");auditMotion=std::string(value)=="1";}
        else if(flag=="--record-fps"){recordFps=std::stoul(value);require(recordFps==30 || recordFps==60,"--record-fps requires 30 or 60");}
        else if(flag=="--gpu-render"){require(std::string(value)=="0" || std::string(value)=="1","--gpu-render requires 0 or 1");gpuRender=std::string(value)=="1";}
        else if(flag=="--gpu-video")videoPath=value;
        else if(flag=="--gpu-camera"){gpuCamera=value;require(gpuCamera=="close" || gpuCamera=="overview" || gpuCamera=="diagnostic" || gpuCamera=="penetration","--gpu-camera requires close, overview, diagnostic or penetration");}
        else if(flag=="--state-path")statePath=value;
        else if(flag=="--motion-path")motionPath=value;
        else if(flag=="--record-state"){require(std::string(value)=="0" || std::string(value)=="1","--record-state requires 0 or 1");recordState=std::string(value)=="1";}
        else if(flag=="--grid")grid=std::stoul(value);else if(flag=="--waves")waves=std::stoul(value);
        else if(flag=="--steps"){stepLimit=std::stoul(value);require(stepLimit && stepLimit<=36000,"--steps requires 1..36000");}
        else if(flag=="--stress-iterations")stressIterations=std::stoul(value);else if(flag=="--seconds")seconds=std::stof(value);else if(flag=="--output")output=value;
        else throw std::runtime_error("unknown option: "+flag);
    }
    require(grid && grid<=32 && waves && waves<=16 && stressIterations && stressIterations<=32768 && seconds>2 && seconds<=600 && !output.empty(),"use --output NEW_DIRECTORY [--grid 3 --waves 4 --seconds 30]");
    require(layout=="grid" || layout=="impact-corridor","unknown scene layout");
    require(snapshotSteps.empty() || (standardScene && standardSleeping),"snapshot capture requires ordinary sleeping scene");
    const NativeScenarioGeometry geometry(geometryName);
    require(geometryName=="building" || (grid==1 && workload=="idle"),"synthetic geometry currently requires one gravity-only structure");
    require(shotPath=="aerial" || (shotPath=="through-wall" && (grid==1 || layout=="impact-corridor") && workload=="single-impact"),"through-wall launch requires a single impact and an unobstructed corridor");
    require(std::isfinite(frameStrength) && frameStrength>=1 && frameStrength<=1e6f,"invalid authored frame strength");
    require(std::isfinite(materialStrength) && materialStrength>0 && materialStrength<=1e6f,"invalid authored material strength");
    require(std::isfinite(projectileMass) && projectileMass>0 && projectileMass<=1e8f,"invalid projectile mass");
    require(workload=="idle" || workload=="single-impact" || workload=="bombardment","unknown workload");
    require(freeBodies<=100000 && (!freeBodies || workload=="idle"),"--free-bodies supports up to 100000 separated bodies in idle workload");
    require(launchSeconds==-1 || (std::isfinite(launchSeconds) && launchSeconds>=0),"invalid launch window");
    require(!standardScene || !standardSleeping || !deviceConnectivity,"ordinary sleeping requires the GPU-repaired native sleep membership; use --gpu-connectivity-owner 0");
    require(!std::filesystem::exists(output),"capture output already exists");std::filesystem::create_directories(output);
    const float scenarioSeconds=seconds;
    const unsigned buildings=grid*grid,scenarioFrames=unsigned(std::lround(seconds*60));
    const unsigned frames=stepLimit?std::min(stepLimit,scenarioFrames):scenarioFrames;
    seconds=float(frames)/60;const float dt=1.0f/60;
    const unsigned recordStride=60/recordFps,recordFrames=(frames+recordStride-1)/recordStride;
    if(statePath.empty())statePath=output+"/native.twstate";
    if(motionPath.empty())motionPath=output+"/native.motion.csv";
    require(!traceMotion || !std::filesystem::exists(motionPath) || std::filesystem::is_fifo(motionPath),"motion output already exists");
    require(!recordState || !std::filesystem::exists(statePath) || std::filesystem::is_fifo(statePath),"state output already exists");
    const PxVec3 half(.48f);const float massPerChunk=1000*8*half.x*half.y*half.z;
    const float inertia=massPerChunk*(half.x*half.x+half.y*half.y)/3;
    SceneCapacity capacity;capacity.maxBodies=buildings*std::max(512u,geometry.count())+buildings*waves+freeBodies;capacity.maxShapes=capacity.maxBodies;
    capacity.maxContactPairs=std::max(65536u,capacity.maxShapes*16);
    NativeGpuActivity gpuActivity(profileGpu?output:"",uint64_t(gpuTraceBufferMiB)*1024*1024);
    NativePhaseProfiler phaseProfiler(profilePhases?output+"/native.phases.csv":"");
    NativeGraphBoundaryAudit graphBoundaryAudit(auditIslands);
    PhysXScene context(PhysicsMode::Gpu,true,capacity,nullptr,!standardScene,!standardScene || !standardSleeping,false,false,PxSolverType::eTGS,false,false);
    auto& physics=context.physics();auto& scene=context.scene();auto& cuda=*context.cudaContextManager();
    require(context.gpuActive(),"native GPU physics is required");
    setNativeGraphAudit(scene,auditIslands);graphBoundaryAudit.bind(scene);
    require(!preSolveSupport || preSolveContacts,"GPU static support requires GPU pre-solve contacts");
    static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->enableCudaPreSolveSupport(preSolveSupport);
    require(!preSolveContacts || (preSolveIslands && gpuIslandRepair),"GPU pre-solve contacts require GPU pre-solve islands and island repair");
    static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->enableCudaPreSolveContacts(preSolveContacts);
    static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->enableCudaPreSolveIslands(preSolveIslands);
    require(!deviceConnectivity || (preSolveIslands && preSolveContacts && preSolveSupport && gpuIslandRepair),"GPU connectivity ownership requires GPU pre-solve islands/contacts/support and island repair");
    static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->enableDeviceConnectivityOwnership(deviceConnectivity);
    std::vector<PxRigidDynamic*> parents;std::vector<Chunk> chunks;
    std::vector<PxDestructionStressChunk> nodes;std::vector<PxDestructionChunkMassProperties> properties;
    std::vector<PxDestructionStressBond> bonds;std::vector<PxDestructionStressCluster> clusters;
    std::vector<PxVec3> origins;
    for(unsigned building=0;building<buildings;++building){
        const PxVec3 origin=nativeBuildingOrigin(building,grid,layout=="impact-corridor");origins.push_back(origin);
        auto* parent=physics.createRigidDynamic(PxTransform(origin));require(parent,"parent allocation failed");
        parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);parent->setLinearDamping(0);parent->setAngularDamping(0);
        std::map<std::tuple<int,int,int>,unsigned> ids;PxVec3 center(0);unsigned count=0;
        for(int y=0;y<geometry.ny;++y)for(int z=0;z<geometry.nz;++z)for(int x=0;x<geometry.nx;++x){
            if(!geometry.present(x,y,z))continue;
            const bool supported=geometry.supported(x,y,z);
            const PxVec3 p(float(x)-float(geometry.nx-1)*.5f,float(y),float(z)-float(geometry.nz-1)*.5f);auto* shape=physics.createShape(PxBoxGeometry(half),context.material(),true);
            require(shape,"chunk shape allocation failed");if(!sceneQueryShapes)shape->setFlag(PxShapeFlag::eSCENE_QUERY_SHAPE,false);shape->setLocalPose(PxTransform(p));require(parent->attachShape(*shape),"persistent chunk attachment failed");
            const unsigned id=unsigned(chunks.size());ids[{x,y,z}]=id;chunks.push_back({p,shape,building});
            const bool frameMember=geometry.frame(x,y,z);
            nodes.push_back({p,supported?0.0f:massPerChunk,supported?0.0f:inertia,building,PX_INVALID_U32,8*half.x*half.y*half.z,(frameStrength>1 && frameMember)?1u:0u});
            PxDestructionChunkMassProperties props{};props.mass=massPerChunk;props.supported=supported;
            for(unsigned k=0;k<3;++k){props.center[k]=p[k];props.inertia[k]=inertia;}properties.push_back(props);center+=p;++count;
            const int delta[3][3]={{-1,0,0},{0,-1,0},{0,0,-1}};
            for(const auto& d:delta){auto found=ids.find({x+d[0],y+d[1],z+d[2]});if(found==ids.end())continue;
                const auto other=found->second;const auto displacement=p-chunks[other].position;
                bonds.push_back({other,id,(p+chunks[other].position)*.5f,displacement.getNormalized(),4*half.x*half.y,1,1,(nodes[other].material==1 && nodes[id].material==1)?1u:0u});}
        }
        center/=float(count);parent->setMass(massPerChunk*count);parent->setCMassLocalPose(PxTransform(center));
        scene.addActor(*parent);parents.push_back(parent);clusters.push_back({PX_INVALID_U32,center});
    }
    // Profiling control: ordinary moving rigid bodies, separated in empty space.
    // This changes the authored workload explicitly, never the destruction rules.
    std::vector<PxRigidDynamic*> freeActors;
    for(unsigned i=0;i<freeBodies;++i){
        auto* actor=physics.createRigidDynamic(PxTransform(PxVec3(-100-float(i%320)*3,100,-100-float(i/320)*3)));
        auto* shape=physics.createShape(PxBoxGeometry(half),context.material(),true);
        require(actor && shape && actor->attachShape(*shape),"free body control allocation failed");shape->release();
        actor->setMass(massPerChunk);actor->setMassSpaceInertiaTensor(PxVec3(inertia));
        actor->setActorFlag(PxActorFlag::eDISABLE_GRAVITY,true);actor->setLinearDamping(0);actor->setAngularDamping(0);
        actor->setLinearVelocity(PxVec3(.1f,0,0));scene.addActor(*actor);freeActors.push_back(actor);
    }
    scene.simulate(dt);require(scene.fetchResults(true),"native setup step failed");
    auto* destruction=scene.getDestructionScene();require(destruction,"native destruction unavailable");
    for(unsigned i=0;i<chunks.size();++i)nodes[i].contactIndex=destruction->getShapeContactIndex(*chunks[i].shape);
    for(unsigned i=0;i<parents.size();++i)clusters[i].body=parents[i]->getGPUIndex();
    PxDestructionMaterial material;material.compressionElasticLimit=250000;material.compressionFatalLimit=500000;
    material.tensionElasticLimit=30000;material.tensionFatalLimit=60000;material.shearElasticLimit=80000;material.shearFatalLimit=160000;
    material.compressionElasticLimit*=materialStrength;material.compressionFatalLimit*=materialStrength;
    material.tensionElasticLimit*=materialStrength;material.tensionFatalLimit*=materialStrength;
    material.shearElasticLimit*=materialStrength;material.shearFatalLimit*=materialStrength;
    PxDestructionMaterial materials[2]={material,material};
    materials[1].compressionElasticLimit*=frameStrength;materials[1].compressionFatalLimit*=frameStrength;
    materials[1].tensionElasticLimit*=frameStrength;materials[1].tensionFatalLimit*=frameStrength;
    materials[1].shearElasticLimit*=frameStrength;materials[1].shearFatalLimit*=frameStrength;
    PxDestructionStressDesc desc;desc.chunks=nodes.data();desc.chunkCount=unsigned(nodes.size());desc.chunkMassProperties=properties.data();
    desc.clusters=clusters.data();desc.clusterCount=unsigned(clusters.size());desc.bonds=bonds.data();desc.bondCount=unsigned(bonds.size());
    desc.materials=materials;desc.materialCount=frameStrength>1?2:1;desc.maxIterations=stressIterations;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;desc.preserveUnchangedContactPairs=preservePairs;
    // Pair storage reserve: --reserve-pairs N (0 disables); default 1.5 pairs per chunk, capped at 1 M.
    desc.reservedContactPairs=reservePairs!=~0u?reservePairs:std::min<unsigned>(1u<<20,unsigned(nodes.size())*3u/2u);desc.gpuIslandRepair=gpuIslandRepair;
    require(destruction->configureStress(desc),"native destruction configuration failed");
    const PxVec3 center(float(grid-1)*8,4,float(grid-1)*8);std::array<Camera,4> cameras;
    for(unsigned i=0;i<4;++i){const float angle=float(i)*1.5707963f+.6f;cameras[i].eye=center+PxVec3(std::cos(angle)*float(grid)*24,float(grid)*13,std::sin(angle)*float(grid)*24);cameras[i].direction=(center-cameras[i].eye).getNormalized();}
    require(videoPath.empty() || gpuRender,"--gpu-video requires --gpu-render 1");
    require(videoPath.empty() || !std::filesystem::exists(videoPath),"GPU video already exists");
    std::vector<NativeGpuVisual> gpuVisuals;gpuVisuals.reserve(chunks.size());
    for(const auto& chunk:chunks)gpuVisuals.push_back({chunk.position,half,chunk.building%4});
    NativeGpuConsumer gpuConsumer(cuda,*destruction,gpuVisuals,buildings*waves);
    gpuConsumer.setClusterColors(colorByCluster);
    Camera gpuView=cameras[0];
    if(gpuCamera=="close"){
        const PxVec3 focus(grid==1?0:8,5,grid==1?0:8);
        gpuView.eye=focus+PxVec3(29,21,-39);gpuView.direction=(focus-gpuView.eye).getNormalized();
    }
    if(gpuCamera=="diagnostic") {
        const PxVec3 focus(0,6,0);gpuView.eye=PxVec3(26,15,-24);
        gpuView.direction=(focus-gpuView.eye).getNormalized();gpuView.fovDegrees=40;
    }
    if(gpuCamera=="penetration") {
        const PxVec3 focus(0,6,0);gpuView.eye=PxVec3(20,11,-18);
        gpuView.direction=(focus-gpuView.eye).getNormalized();gpuView.fovDegrees=40;
    }
    require(!traceMotion || (gpuRender && auditMotion && recordFps==60),"motion trace requires GPU rendering, motion audit and 60 fps observation");
    NativeStressTrace stressTrace(traceStress,output);
    std::ofstream motionTrace,bodyTrace;
    if(traceMotion){bodyTrace.open(output+"/native.body-words.csv");bodyTrace<<"step,body";for(unsigned i=0;i<sizeof(PxgBodySim)/4;++i)bodyTrace<<",word"<<i;bodyTrace<<"\n";}
    if(traceMotion) {
        motionTrace.open(motionPath);require(bool(motionTrace),"motion trace creation failed");motionTrace<<std::setprecision(9);
        motionTrace<<"step,chunk,root,slot,generation,body,cluster_chunks,supported,render_x,render_y,render_z,physics_x,physics_y,physics_z,com_x,com_y,com_z,vx,vy,vz,wx,wy,wz,origin_x,origin_y,origin_z,qx,qy,qz,qw,local_x,local_y,local_z,com_local_x,com_local_y,com_local_z,correction\n";
    }
    if(gpuRender)gpuConsumer.enableRenderer(960,540,gpuView,videoPath,recordFps);
    const bool observePoses=recordState || auditMotion;
    unsigned long long poseReadbackBytes=0,motionTraceReadbackBytes=0;float maxComError=0;
    StateWriter writer;if(recordState)require(writer.open(statePath,recordFps,recordFrames,960,540,buildings,seconds,0,cameras),"state output failed");
    if(recordState)for(unsigned i=0;i<chunks.size();++i){VisualActor visual;visual.parameters=half;visual.part=chunks[i].building%4;require(writer.defineActor(i,visual),"chunk visual definition failed");}
    std::ofstream telemetry(output+"/native.frames.csv");
    telemetry<<std::setprecision(17);
    telemetry<<"step,simulation_seconds,physics_step_ms,stress_solve_ms,frame_host_ms,bodies,awake_bodies,splits_total,contacts_total,resim_passes,correction_status,contacts_frame,projectiles_active,bonds_broken,stress_iterations,stress_converged,observation_ms,gpu_render_submit_and_export_ms,logical_clusters,native_dynamic_bodies,native_kinematic_bodies,active_dynamic_bodies,active_kinematic_bodies,contact_pairs,contact_pairs_with_contacts,solver_rows,stress_active_nodes,stress_active_bonds,stress_islands,graph_d2h_bytes,pre_solve_pairs,simulation_start_ns,simulation_end_ns,process_cpu_ms,complete_step_ms,command_ms,completion_ms,complete_start_ns,complete_end_ns,phase_output_start_ns,phase_output_end_ns,stress_passes,post_correction_bonds_broken,contact_reuse_fallbacks\n";
    std::vector<Shot> shots;std::vector<PxU32> shotIds;std::vector<PxTransform> shotPoses;std::vector<VisualPose> poses;
    CUdeviceptr deviceIds=0,devicePoses=0;CUevent observationIdsReady=nullptr;
    if(observePoses){PxScopedCudaLock lock(cuda);check(cuEventCreate(&observationIdsReady,CU_EVENT_DISABLE_TIMING));check(cuMemAlloc(&deviceIds,std::max(size_t(buildings*waves),chunks.size())*sizeof(PxU32)));check(cuMemAlloc(&devicePoses,std::max(size_t(buildings*waves),chunks.size())*sizeof(PxTransform)));}
    unsigned launched=0,totalCorrections=0,totalBroken=0,peakClusters=buildings;unsigned long long totalContacts=0;
    std::vector<double> times;double maxStep=0,sumStep=0,sumRender=0,maxRender=0;unsigned deadlines=0,completeDeadlines=0;double completeMaximum=0,completeSum=0;
    const float launchWindow=launchSeconds>=0?launchSeconds:std::max(1.0f,scenarioSeconds-5);
    const unsigned plannedShots=workload=="idle"?0:workload=="single-impact"?1:buildings*waves;
    uint64_t previousGraphBytes=0,previousPairs=0;
    float observedChunkTop=12.5f,maxMotionError=0;
    std::ofstream launches(output+"/native.launches.csv");
    launches<<"projectile,step,target_building,x,y,z,vx,vy,vz,chunk_ceiling\n";
    // Recording buffers are prepared outside the simulation advance. Required
    // spawn/clearance/registration work stays inside the complete-step bracket.
    struct LaunchRecord {unsigned id,step,building;PxVec3 position,velocity;float ceiling;};
    std::vector<LaunchRecord> launchRecords;launchRecords.reserve(plannedShots);
    shots.reserve(plannedShots);
    const double initializationMs=ms(initializationBegin);
    for(unsigned frame=0;frame<frames;++frame){
        if(snapshotSteps.count(frame)){
            require(frame>0 || workload=="idle","capture a post-launch accepted tick; frame zero bombardment has pending gameplay spawns");
            captureNativeSnapshot(scene,chunks,capacity,output+"/snapshot-"+std::to_string(frame),frame,buildings,unsigned(shots.size()),preSolveIslands,preSolveContacts,preSolveSupport,deviceConnectivity);
        }
#ifdef NATIVE_FORCE_FRESHNESS_DIAGNOSTIC
        poisonNormalForceWriteback(scene,cuda,frame);
#endif
        const auto tick=Clock::now();const auto completeStartNs=nativeProfileTimestamp();
        const unsigned firstLaunched=launched;const float time=frame*dt;
        while(launched<plannedShots && time>=launchWindow*float(launched)/float(plannedShots)){
            const unsigned building=launched%buildings,wave=launched/buildings;const auto origin=origins[building];
            auto launch=nativeBombardmentLaunch(origin,wave,12.5f);
            if(shotPath=="through-wall")launch=nativeWallPenetrationLaunch(origin);
            // Explicit gameplay observation: CUDA checks committed chunks and
            // projectiles and returns one clearance height. Pose arrays are
            // optional recording/audit output and never drive launch commands.
            const float clearHeight=gpuConsumer.launchHeight(launch.position,.75f);
            if(launch.position.y<clearHeight){
                launch.position.y+=2*std::ceil((clearHeight-launch.position.y)/2);
                launch.velocity=(launch.target-launch.position)/1.5f;launch.velocity.y+=.5f*9.81f*1.5f;
                require(launch.position.isFinite() && launch.velocity.isFinite(),"unrepresentable projectile command");
            }
            if(shotPath=="aerial")require(launch.position.y-.75f>12.5f,"projectile spawn overlaps authored skyline");
            else require(launch.position.z+.75f<origin.z-3.98f,"through-wall projectile overlaps building at spawn");
            const PxVec3 speed=launch.velocity;
            launchRecords.push_back({launched,frame,building,launch.position,speed,observedChunkTop});
            auto* shot=physics.createRigidDynamic(PxTransform(launch.position));auto* sphere=physics.createShape(PxSphereGeometry(.75f),context.material(),true);
            require(shot && sphere && shot->attachShape(*sphere),"projectile creation failed");sphere->release();
            shot->setMass(projectileMass);shot->setMassSpaceInertiaTensor(PxVec3(.4f*projectileMass*.75f*.75f));shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(speed);scene.addActor(*shot);
            const unsigned visualId=unsigned(chunks.size())+launched;VisualActor visual;visual.shape=VisualActor::Shape::Sphere;visual.parameters=PxVec3(.75f,0,0);visual.part=5;
            shots.push_back({shot,visualId});gpuConsumer.addProjectile(shot->getGPUIndex(),PxTransform(launch.position));++launched;
        }
        const double commandMs=ms(tick);
        phaseProfiler.begin(frame);
        const auto startNs=nativeProfileTimestamp(),startCpu=nativeProcessCpuNs();
        const auto begin=Clock::now();scene.simulate(dt);PxU32 error=0;const bool complete=scene.fetchResults(true,&error);const double simulationMs=ms(begin);
        const auto endNs=nativeProfileTimestamp(),endCpu=nativeProcessCpuNs();
        if(auditIslands){graphBoundaryAudit.check();requireNativeGraphAudit(scene,output+"/native.graph-diagnostics.json");}
        const auto status=destruction->getLastStatus();
        if(!complete || error || status.error){std::fprintf(stderr,"INCOMPLETE native step %u: fetch=%u stage=%u broken=%u crushed=%u\n",frame,error,status.error,status.brokenBonds,status.crushedChunks);throw std::runtime_error("native demo correction incomplete");}
        require(status.converged,"native demo accepted an unconverged stress solve");
        require(status.correctionPasses<=1,"native demo exceeded one internal correction");require(status.stressPasses==1+status.correctionPasses,"native demo missed/exceeded stress evaluations");require(status.frame==frame+1,"native demo duplicated timestep");
        require(status.brokenBonds==0 || totalContacts+status.normalContacts>0,"authored building fractured before any actual impact");
        totalCorrections+=status.correctionPasses;totalBroken+=status.brokenBonds;totalContacts+=status.normalContacts;
        const auto observation=Clock::now();const auto view=destruction->getDeviceView();PxDestructionTopologyStatus topology{};PxDestructionStressTopologyStatus stressTopology{};
        std::vector<PxU32> membership,slots;std::vector<PxDestructionClusterMotion> motions;
        {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));check(cuMemcpyDtoH(&topology,CUdeviceptr(view.acceptedTopology.status),sizeof(topology)));
        check(cuMemcpyDtoH(&stressTopology,CUdeviceptr(view.stressTopology),sizeof(stressTopology)));
        }
        require(!topology.slotError,"incomplete GPU cluster slot allocation");
        const auto completeEndNs=nativeProfileTimestamp();const double completeMs=ms(tick);
        const double completionMs=completeMs-commandMs-simulationMs;
        completeMaximum=std::max(completeMaximum,completeMs);completeSum+=completeMs;if(completeMs>8.0)++completeDeadlines;
        // Persisting diagnostic rows can cost milliseconds on a fracture frame.
        // It is report generation, not mandatory simulation completion.
        const auto phaseOutputStartNs=profilePhases?nativeProfileTimestamp():0;
        phaseProfiler.acceptedFrame();
        const auto phaseOutputEndNs=profilePhases?nativeProfileTimestamp():0;
        // Optional observations/graphics and log writes cannot feed physics.
        stressTrace.observe(frame,view,cuda);
        for(unsigned id=firstLaunched;id<launched;++id){
            const auto& r=launchRecords[id];
            launches<<r.id<<','<<r.step<<','<<r.building<<','<<r.position.x<<','<<r.position.y<<','<<r.position.z<<','<<r.velocity.x<<','<<r.velocity.y<<','<<r.velocity.z<<','<<r.ceiling<<'\n';
            VisualActor visual;visual.shape=VisualActor::Shape::Sphere;visual.parameters=PxVec3(.75f,0,0);visual.part=5;
            if(recordState)require(writer.defineActor(shots[id].visual,visual),"projectile visual definition failed");
        }
        gpuConsumer.update();
        const auto renderStart=Clock::now();
        std::vector<NativeGpuInstance> rendered;
        if(gpuRender && frame%recordStride==0)gpuConsumer.render(traceMotion?&rendered:nullptr);
        const double renderMs=gpuRender && frame%recordStride==0?ms(renderStart):0;
        sumRender+=renderMs;maxRender=std::max(maxRender,renderMs);
        if(observePoses){
          {PxScopedCudaLock lock(cuda);
            read(membership,view.acceptedTopology.chunkCluster,chunks.size());read(slots,view.acceptedTopology.clusterSlots,chunks.size());read(motions,view.acceptedTopology.motions,view.acceptedTopology.slotCapacity);
            shotIds.clear();for(const auto& shot:shots)shotIds.push_back(shot.actor->getGPUIndex());shotPoses.resize(shots.size());
            if(!shots.empty()){check(cuMemcpyHtoD(deviceIds,shotIds.data(),shotIds.size()*sizeof(PxU32)));check(cuEventRecord(observationIdsReady,nullptr));
                require(destruction->readRigidBodyData(reinterpret_cast<void*>(devicePoses),reinterpret_cast<const PxU32*>(deviceIds),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,unsigned(shots.size()),observationIdsReady),"projectile observation failed");
                check(cuCtxSynchronize());check(cuMemcpyDtoH(shotPoses.data(),devicePoses,shotPoses.size()*sizeof(PxTransform)));}}
        poses.clear();poses.reserve(chunks.size()+shots.size());observedChunkTop=0;
        for(unsigned i=0;i<chunks.size();++i){require(membership[i]<slots.size() && slots[membership[i]]<motions.size(),"invalid committed chunk membership");const auto& motion=motions[slots[membership[i]]];
            const PxTransform pose(PxVec3(float(motion.origin[0]),float(motion.origin[1]),float(motion.origin[2])),PxQuat(float(motion.orientation[0]),float(motion.orientation[1]),float(motion.orientation[2]),float(motion.orientation[3])));
            if(!pose.isValid())std::fprintf(stderr,"invalid motion step=%u chunk=%u root=%u slot=%u p=(%.9g,%.9g,%.9g) q=(%.9g,%.9g,%.9g,%.9g)\n",frame,i,membership[i],slots[membership[i]],pose.p.x,pose.p.y,pose.p.z,pose.q.x,pose.q.y,pose.q.z,pose.q.w);
            require(pose.isValid(),"invalid committed cluster motion");const auto chunkPose=pose*PxTransform(chunks[i].position);
            observedChunkTop=std::max(observedChunkTop,chunkPose.p.y+half.magnitude());poses.push_back({i,chunkPose,false});}
        for(unsigned i=0;i<shots.size();++i){require(shotPoses[i].isValid(),"nonfinite projectile motion");poses.push_back({shots[i].visual,shotPoses[i],false});}
          poseReadbackBytes+=chunks.size()*2*sizeof(PxU32)+view.acceptedTopology.slotCapacity*sizeof(PxDestructionClusterMotion)+shots.size()*sizeof(PxTransform);
        }
        if(auditMotion) {
            std::vector<PxU32> owners;std::vector<PxTransform> physical(chunks.size());owners.reserve(chunks.size());
            for(const auto& chunk:chunks){const auto* owner=chunk.shape->getActor()->is<PxRigidDynamic>();require(owner,"chunk has no rigid owner");owners.push_back(owner->getGPUIndex());}
            {PxScopedCudaLock lock(cuda);check(cuMemcpyHtoD(deviceIds,owners.data(),owners.size()*sizeof(PxU32)));check(cuEventRecord(observationIdsReady,nullptr));
                require(destruction->readRigidBodyData(reinterpret_cast<void*>(devicePoses),reinterpret_cast<const PxU32*>(deviceIds),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,unsigned(owners.size()),observationIdsReady),"physical chunk pose audit failed");
                check(cuCtxSynchronize());check(cuMemcpyDtoH(physical.data(),devicePoses,physical.size()*sizeof(PxTransform)));poseReadbackBytes+=physical.size()*sizeof(PxTransform);}
            std::vector<PxgBodySim> nativeBodies;std::vector<PxDestructionClusterMassProperties> clusterMass;
            std::vector<PxU64> generations;
            if(traceMotion) {
                auto* core=static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController())->getSimulationCore();
                const auto count=*std::max_element(owners.begin(),owners.end())+1;
                PxScopedCudaLock lock(cuda);read(nativeBodies,core->getBodySimBufferDevicePtr().getPointer(),count);
                for(auto id:std::set<PxU32>(owners.begin(),owners.end())) {
                    PxU32 words[sizeof(PxgBodySim)/4];std::memcpy(words,&nativeBodies[id],sizeof(words));
                    bodyTrace<<frame<<','<<id;for(auto word:words)bodyTrace<<','<<word;bodyTrace<<'\n';
                }
                read(clusterMass,view.acceptedTopology.clusters,chunks.size());read(generations,view.acceptedTopology.slotGenerations,view.acceptedTopology.slotCapacity);
                motionTraceReadbackBytes+=nativeBodies.size()*sizeof(PxgBodySim)+clusterMass.size()*sizeof(PxDestructionClusterMassProperties)+generations.size()*sizeof(PxU64)+rendered.size()*sizeof(NativeGpuInstance);
            }
            for(unsigned i=0;i<chunks.size();++i){const auto actual=physical[i]*chunks[i].shape->getLocalPose();
                if(traceMotion) {
                    const auto& body=nativeBodies[owners[i]];const auto& mass=clusterMass[membership[i]];const auto& instance=rendered[i];
                    require(instance.position[3]==1 && (PxVec3(instance.position[0],instance.position[1],instance.position[2])-actual.p).magnitude()<1e-3f,"actual render buffer differs from physics shape");
                    const PxQuat rq(instance.orientation[0],instance.orientation[1],instance.orientation[2],instance.orientation[3]);
                    require(std::abs(rq.getNormalized().dot(actual.q.getNormalized()))>1-1e-5f,"actual render orientation differs from physics shape");
                    const auto com=body.body2World.p,v=body.linearVelocityXYZ_inverseMassW,w=body.angularVelocityXYZ_maxPenBiasW;
                    const auto& origin=motions[slots[membership[i]]];const auto local=chunks[i].position;
                    const PxTransform actor(PxVec3(float(origin.origin[0]),float(origin.origin[1]),float(origin.origin[2])),
                        PxQuat(float(origin.orientation[0]),float(origin.orientation[1]),float(origin.orientation[2]),float(origin.orientation[3])));
                    const auto expectedCom=actor.transform(PxVec3(float(mass.center[0]),float(mass.center[1]),float(mass.center[2])));
                    const float comError=(expectedCom-PxVec3(com.x,com.y,com.z)).magnitude();maxComError=std::max(maxComError,comError);
                    require(comError<1e-3f,"physical GPU COM differs from accepted cluster mass frame");
                    motionTrace<<frame<<','<<i<<','<<membership[i]<<','<<slots[membership[i]]<<','<<generations[slots[membership[i]]]<<','<<owners[i]<<','<<mass.chunkCount<<','<<mass.supported
                        <<','<<instance.position[0]<<','<<instance.position[1]<<','<<instance.position[2]<<','<<actual.p.x<<','<<actual.p.y<<','<<actual.p.z
                        <<','<<com.x<<','<<com.y<<','<<com.z<<','<<v.x<<','<<v.y<<','<<v.z<<','<<w.x<<','<<w.y<<','<<w.z;
                    for(auto x:origin.origin)motionTrace<<','<<x;
                    for(auto x:origin.orientation)motionTrace<<','<<x;
                    motionTrace<<','<<local.x<<','<<local.y<<','<<local.z;
                    for(auto x:mass.center)motionTrace<<','<<x;
                    motionTrace<<','<<status.correctionPasses<<'\n';
                }
                const float error=(actual.p-poses[i].pose.p).magnitude();maxMotionError=std::max(maxMotionError,error);
                if(error>0 && std::getenv("PHYSX_MOTION_AUDIT_VERBOSE"))
                    std::fprintf(stderr,"motion audit nonzero step=%u chunk=%u cluster=%u body=%u error=%.9g actual=(%.9g,%.9g,%.9g) recorded=(%.9g,%.9g,%.9g)\n",
                        frame,i,membership[i],owners[i],error,actual.p.x,actual.p.y,actual.p.z,poses[i].pose.p.x,poses[i].pose.p.y,poses[i].pose.p.z);
                // Compare orientation independently of floating-point quaternion norm drift.
                const float orientationDot=std::abs(actual.q.getNormalized().dot(poses[i].pose.q.getNormalized()));
                if(!(error<1e-3f && orientationDot>1-1e-5f)) {
                    PxU32 expected=PX_INVALID_U32;PxDestructionClusterBodyState candidate{};
                    {PxScopedCudaLock lock(cuda);std::vector<PxU32> roots;read(roots,view.acceptedTopology.activeClusters,topology.clusterCount);
                        const auto found=std::lower_bound(roots.begin(),roots.end(),membership[i]);require(found!=roots.end() && *found==membership[i],"audit root missing");
                        const size_t packed=size_t(found-roots.begin());check(cuMemcpyDtoH(&expected,CUdeviceptr(view.trialBodyIndices+packed),sizeof(expected)));check(cuMemcpyDtoH(&candidate,CUdeviceptr(view.trialBodies+packed),sizeof(candidate)));}
                    std::fprintf(stderr,"motion audit expected_body=%u supported=%u source=%u correction=%u cpu_flags=%u\n",expected,candidate.supported,candidate.sourceBody,status.correctionPasses,unsigned(chunks[i].shape->getActor()->is<PxRigidDynamic>()->getRigidBodyFlags()));
                    std::fprintf(stderr,"motion audit step=%u chunk=%u cluster=%u body=%u position_error=%.9g orientation_dot=%.9g actual=(%.9g,%.9g,%.9g) recorded=(%.9g,%.9g,%.9g)\n",frame,i,membership[i],owners[i],error,orientationDot,actual.p.x,actual.p.y,actual.p.z,poses[i].pose.p.x,poses[i].pose.p.y,poses[i].pose.p.z);}
                require(error<1e-3f && orientationDot>1-1e-5f,"rendered chunk motion disagrees with physical GPU shape");}
        }
        if(recordState && frame%recordStride==0)require(writer.writeFrame(frame/recordStride,poses),"committed state capture failed");const double observationMs=ms(observation);
        peakClusters=std::max(peakClusters,topology.clusterCount);maxStep=std::max(maxStep,simulationMs);sumStep+=simulationMs;times.push_back(simulationMs);if(simulationMs>1000.0/60)++deadlines;
        PxSimulationStatistics counts;scene.getSimulationStatistics(counts);
        const auto graphStats=static_cast<PxgDestructionRuntime*>(destruction)->getContactGraphObservationStats();
        const auto pairs=static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->getCudaPreSolveContactPairs();
        // Stress time is included in physics_step_ms, not separately instrumented.
        // The recording uses the compact HUD, which only displays total times.
        telemetry<<frame<<','<<(frame+1)*dt<<','<<simulationMs<<",0,"<<ms(tick)<<','<<counts.nbDynamicBodies+counts.nbKinematicBodies<<','<<counts.nbActiveDynamicBodies+counts.nbActiveKinematicBodies<<','<<topology.clusterCount-buildings<<','<<totalContacts<<','<<status.correctionPasses<<",0,"<<status.normalContacts<<','<<shots.size()<<','<<status.brokenBonds<<','<<status.iterations<<','<<status.converged<<','<<observationMs<<','<<renderMs<<','<<topology.clusterCount<<','<<counts.nbDynamicBodies<<','<<counts.nbKinematicBodies<<','<<counts.nbActiveDynamicBodies<<','<<counts.nbActiveKinematicBodies<<','<<counts.nbDiscreteContactPairsTotal<<','<<counts.nbDiscreteContactPairsWithContacts<<','<<counts.nbAxisSolverConstraints<<','<<stressTopology.activeNodeCount<<','<<stressTopology.activeBondCount<<','<<stressTopology.islandCount<<','<<graphStats.deviceToHostBytes-previousGraphBytes<<','<<pairs-previousPairs<<','<<startNs<<','<<endNs<<','<<double(endCpu-startCpu)/1e6<<','<<completeMs<<','<<commandMs<<','<<completionMs<<','<<completeStartNs<<','<<completeEndNs<<','<<phaseOutputStartNs<<','<<phaseOutputEndNs<<','<<status.stressPasses<<','<<status.postCorrectionBrokenBonds<<','<<static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController())->getDestructionContactReuseFallbackCount()<<'\n';
        previousGraphBytes=graphStats.deviceToHostBytes;previousPairs=pairs;
        if(frame%60==0){std::printf("native t=%.1f chunks=%zu bonds=%zu clusters=%u shots=%zu broken=%u corrections=%u step=%.2fms\n",time,chunks.size(),bonds.size(),topology.clusterCount,shots.size(),totalBroken,totalCorrections,simulationMs);std::fflush(stdout);}
    }
    if(workload=="idle")require(!totalCorrections && !totalBroken && peakClusters==buildings,"idle scene unexpectedly fractured");
    else require(totalCorrections && totalBroken && peakClusters>buildings,"native bombardment did not demonstrate destruction");if(recordState)require(writer.finish(),"state stream finalization failed");
    gpuConsumer.finishVideo();
    gpuActivity.finish();
    stressTrace.finish();
    std::sort(times.begin(),times.end());auto percentile=[&](double p){return times[std::min(times.size()-1,size_t(p*times.size()))];};
    if(observePoses){PxScopedCudaLock lock(cuda);check(cuEventDestroy(observationIdsReady));check(cuMemFree(deviceIds));check(cuMemFree(devicePoses));}
    writeNativeGraphDiagnostics(scene,output+"/native.graph-diagnostics.json");
    require(destruction->clearStress(),"native fragment cleanup failed");for(auto* parent:parents)parent->release();for(auto& shot:shots)shot.actor->release();for(auto& chunk:chunks)chunk.shape->release();for(auto* actor:freeActors)actor->release();
    require(context.healthy(),"native demo GPU health failed");
    std::ofstream manifest(output+"/native.summary.json");
    manifest<<std::setprecision(17);
    // Separate authored provenance; recording is outside complete-step timing.
    std::ofstream geometryManifest(output+"/native.geometry.json");
    geometryManifest<<"{\"schema\":1,\"name\":\""<<geometryName<<"\",\"nx\":"<<geometry.nx<<",\"ny\":"<<geometry.ny<<",\"nz\":"<<geometry.nz<<",\"chunks_per_structure\":"<<geometry.count()<<"}\n";
    manifest<<"{\n  \"complete_timer_schema\": 1,\n  \"phase_output_outside_complete_timer\": true,\n  \"phase_output_timing_schema\": 1,\n  \"complete_step_ms_max\": "<<completeMaximum<<",\n  \"complete_step_ms_mean\": "<<completeSum/frames<<",\n  \"missed_8ms\": "<<completeDeadlines<<",\n  \"initialization_ms\": "<<initializationMs<<",\n  \"frame_strength_scale\": "<<frameStrength<<",\n  \"layout\": \""<<layout<<"\",\n  \"shot_path\": \""<<shotPath<<"\",\n  \"material_strength_scale\": "<<materialStrength<<",\n  \"color_by_cluster\": "<<(colorByCluster?"true":"false")<<",\n  \"projectile_mass_kg\": "<<projectileMass<<",\n  \"motion_trace_enabled\": "<<(traceMotion?"true":"false")<<",\n  \"motion_trace_readback_bytes\": "<<motionTraceReadbackBytes<<",\n  \"max_cluster_com_error\": "<<maxComError<<",\n  \"gpu_connectivity_owner\": "<<(deviceConnectivity?"true":"false")<<",\n  \"workload\": \""<<workload<<"\",\n  \"profile_gpu\": "<<(profileGpu?"true":"false")<<",\n  \"free_bodies\": "<<freeBodies<<",\n  \"launch_seconds\": "<<launchWindow<<",\n  \"physics_ms_min\": "<<times.front()<<",\n  \"physics_ms_mean\": "<<sumStep/frames<<",\n  \"simulation_realtime_fraction\": "<<seconds*1000/sumStep<<",\n  \"gpu_render_submit_and_export_ms_mean\": "<<(gpuConsumer.renderedFrames()?sumRender/gpuConsumer.renderedFrames():0)<<",\n  \"gpu_render_submit_and_export_ms_max\": "<<maxRender<<",\n  \"stress_stats_readback_bytes\": "<<frames*sizeof(PxDestructionStressTopologyStatus)<<",\n  \"topology_stats_readback_bytes\": "<<frames*sizeof(PxDestructionTopologyStatus)<<",\n  \"gpu_rendered_frames\": "<<gpuConsumer.renderedFrames()<<",\n  \"gpu_renderer\": \""<<gpuConsumer.rendererName()<<"\",\n  \"consumer_pose_readback_bytes\": "<<poseReadbackBytes<<",\n  \"consumer_query_readback_bytes\": "<<gpuConsumer.queryReadbackBytes()<<",\n  \"export_pixel_readback_bytes\": "<<gpuConsumer.pixelReadbackBytes()<<",\n  \"backend\": \"native PhysX GPU task graph + resident CUDA destruction\",\n  \"status\": \"completed\",\n  \"frames\": "<<frames<<",\n  \"seconds\": "<<seconds<<",\n  \"buildings\": "<<buildings<<",\n  \"chunks\": "<<chunks.size()<<",\n  \"bonds\": "<<bonds.size()<<",\n  \"peak_clusters\": "<<peakClusters<<",\n  \"projectiles\": "<<shots.size()<<",\n  \"broken_bonds\": "<<totalBroken<<",\n  \"corrections\": "<<totalCorrections<<",\n  \"spawn_protocol\": \""<<(shotPath=="aerial"?"gpu-clear-aerial-ballistic-v3":"gpu-clear-through-wall-ballistic-v1")<<"\",\n  \"contact_producer_audits\": "<<graphBoundaryAudit.passes()<<",\n  \"heavy_audit_inside_simulation_timer\": "<<(auditIslands?"true":"false")<<",\n  \"island_boundary_audit_enabled\": "<<(auditIslands?"true":"false")<<",\n  \"motion_audit_enabled\": "<<(auditMotion?"true":"false")<<",\n  \"max_motion_position_error\": "<<maxMotionError<<",\n  \"record_fps\": "<<recordFps<<",\n  \"gpu_island_repair\": "<<(gpuIslandRepair?"true":"false")<<",\n  \"gpu_pre_solve_islands\": "<<(preSolveIslands?"true":"false")<<",\n  \"gpu_pre_solve_support\": "<<(preSolveSupport?"true":"false")<<",\n  \"gpu_pre_solve_contacts\": "<<(preSolveContacts?"true":"false")<<",\n  \"preserve_contact_pairs\": "<<(preservePairs?"true":"false")<<",\n  \"recorded_state\": "<<(recordState?"true":"false")<<",\n  \"correction_limit\": 1,\n  \"physics_ms_p50\": "<<percentile(.5)<<",\n  \"physics_ms_p95\": "<<percentile(.95)<<",\n  \"physics_ms_p99\": "<<percentile(.99)<<",\n  \"physics_ms_max\": "<<maxStep<<",\n  \"missed_16_67ms\": "<<deadlines<<",\n  \"stress_included_in_physics_time\": true,\n  \"isolated_performance_qualification\": false,\n  \"sleeping\": "<<(standardScene && standardSleeping?"true":"false")<<",\n  \"direct_gpu_mode\": "<<(standardScene?"false":"true")<<",\n  \"crushing_material_enabled\": false\n}\n";
    return 0;
}
}
int main(int argc,char** argv){try{return run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
