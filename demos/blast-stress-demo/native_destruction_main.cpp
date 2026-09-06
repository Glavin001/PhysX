// Native PhysX GPU destruction proof. The application authors assets and shots,
// calls simulate/fetchResults once per tick, and explicitly observes GPU motion
// for recording. It performs no stress solve, topology change or motion replay.
#include "physx_scene.h"
#include "state_writer.h"
#include "native_bombardment.h"
#include "native_phase_profiler.h"
#include "native_graph_diagnostics.h"
#include "native_gpu_consumer.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <algorithm>
#include <chrono>
#include <cmath>
#include <cstdio>
#include <filesystem>
#include <fstream>
#include <map>
#include <stdexcept>
#include <string>
#include <tuple>
#include <vector>
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
int run(int argc,char** argv){
    unsigned grid=3,waves=4,stressIterations=2048,recordFps=60;bool profilePhases=false,recordState=false,preservePairs=false,auditMotion=false,gpuIslandRepair=false,auditIslands=false,preSolveIslands=false,preSolveContacts=false,preSolveSupport=false;float seconds=30;std::string output,statePath,videoPath,gpuCamera="overview";bool gpuRender=false;
    for(int i=1;i<argc;++i){std::string flag=argv[i];require(i+1<argc,"missing option value");const char* value=argv[++i];
        if(flag=="--profile-phases"){require(std::string(value)=="0" || std::string(value)=="1","--profile-phases requires 0 or 1");profilePhases=std::string(value)=="1";}
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
        else if(flag=="--gpu-camera"){gpuCamera=value;require(gpuCamera=="close" || gpuCamera=="overview","--gpu-camera requires close or overview");}
        else if(flag=="--state-path")statePath=value;
        else if(flag=="--record-state"){require(std::string(value)=="0" || std::string(value)=="1","--record-state requires 0 or 1");recordState=std::string(value)=="1";}
        else if(flag=="--grid")grid=std::stoul(value);else if(flag=="--waves")waves=std::stoul(value);
        else if(flag=="--stress-iterations")stressIterations=std::stoul(value);else if(flag=="--seconds")seconds=std::stof(value);else if(flag=="--output")output=value;
        else throw std::runtime_error("unknown option: "+flag);
    }
    require(grid && grid<=32 && waves && waves<=16 && stressIterations && stressIterations<=32768 && seconds>2 && seconds<=120 && !output.empty(),"use --output NEW_DIRECTORY [--grid 3 --waves 4 --seconds 30]");
    require(!std::filesystem::exists(output),"capture output already exists");std::filesystem::create_directories(output);
    const unsigned buildings=grid*grid,frames=unsigned(std::lround(seconds*60));const float dt=1.0f/60;
    const unsigned recordStride=60/recordFps,recordFrames=(frames+recordStride-1)/recordStride;
    if(statePath.empty())statePath=output+"/native.twstate";
    require(!recordState || !std::filesystem::exists(statePath) || std::filesystem::is_fifo(statePath),"state output already exists");
    const PxVec3 half(.48f);const float massPerChunk=1000*8*half.x*half.y*half.z;
    const float inertia=massPerChunk*(half.x*half.x+half.y*half.y)/3;
    SceneCapacity capacity;capacity.maxBodies=buildings*512+buildings*waves;capacity.maxShapes=capacity.maxBodies;
    capacity.maxContactPairs=std::max(65536u,capacity.maxShapes*16);
    NativePhaseProfiler phaseProfiler(profilePhases?output+"/native.phases.csv":"");
    PhysXScene context(PhysicsMode::Gpu,true,capacity,nullptr,true,true,false,false);
    auto& physics=context.physics();auto& scene=context.scene();auto& cuda=*context.cudaContextManager();
    require(context.gpuActive(),"native GPU physics is required");
    setNativeGraphAudit(scene,auditIslands);
    require(!preSolveSupport || preSolveContacts,"GPU static support requires GPU pre-solve contacts");
    static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->enableCudaPreSolveSupport(preSolveSupport);
    require(!preSolveContacts || (preSolveIslands && gpuIslandRepair),"GPU pre-solve contacts require GPU pre-solve islands and island repair");
    static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->enableCudaPreSolveContacts(preSolveContacts);
    static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->enableCudaPreSolveIslands(preSolveIslands);
    std::vector<PxRigidDynamic*> parents;std::vector<Chunk> chunks;
    std::vector<PxDestructionStressChunk> nodes;std::vector<PxDestructionChunkMassProperties> properties;
    std::vector<PxDestructionStressBond> bonds;std::vector<PxDestructionStressCluster> clusters;
    std::vector<PxVec3> origins;
    for(unsigned building=0;building<buildings;++building){
        const PxVec3 origin(float(building%grid)*16,.5f,float(building/grid)*16);origins.push_back(origin);
        auto* parent=physics.createRigidDynamic(PxTransform(origin));require(parent,"parent allocation failed");
        parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);parent->setLinearDamping(0);parent->setAngularDamping(0);
        std::map<std::tuple<int,int,int>,unsigned> ids;PxVec3 center(0);unsigned count=0;
        for(int y=0;y<12;++y)for(int z=0;z<8;++z)for(int x=0;x<8;++x){
            if(x && x!=7 && z && z!=7 && y%4!=0)continue;
            const PxVec3 p(float(x)-3.5f,float(y),float(z)-3.5f);auto* shape=physics.createShape(PxBoxGeometry(half),context.material(),true);
            require(shape,"chunk shape allocation failed");shape->setLocalPose(PxTransform(p));require(parent->attachShape(*shape),"persistent chunk attachment failed");
            const unsigned id=unsigned(chunks.size());ids[{x,y,z}]=id;chunks.push_back({p,shape,building});
            nodes.push_back({p,y?massPerChunk:0.0f,y?inertia:0.0f,building,PX_INVALID_U32,8*half.x*half.y*half.z,0});
            PxDestructionChunkMassProperties props{};props.mass=massPerChunk;props.supported=y==0;
            for(unsigned k=0;k<3;++k){props.center[k]=p[k];props.inertia[k]=inertia;}properties.push_back(props);center+=p;++count;
            const int delta[3][3]={{-1,0,0},{0,-1,0},{0,0,-1}};
            for(const auto& d:delta){auto found=ids.find({x+d[0],y+d[1],z+d[2]});if(found==ids.end())continue;
                const auto other=found->second;const auto displacement=p-chunks[other].position;
                bonds.push_back({other,id,(p+chunks[other].position)*.5f,displacement.getNormalized(),4*half.x*half.y,1,1,0});}
        }
        center/=float(count);parent->setMass(massPerChunk*count);parent->setCMassLocalPose(PxTransform(center));
        scene.addActor(*parent);parents.push_back(parent);clusters.push_back({PX_INVALID_U32,center});
    }
    scene.simulate(dt);require(scene.fetchResults(true),"native setup step failed");
    for(unsigned i=0;i<chunks.size();++i)nodes[i].contactIndex=scene.getDirectGPUAPI().getShapeContactIndex(*chunks[i].shape);
    for(unsigned i=0;i<parents.size();++i)clusters[i].body=parents[i]->getGPUIndex();
    PxDestructionMaterial material;material.compressionElasticLimit=250000;material.compressionFatalLimit=500000;
    material.tensionElasticLimit=30000;material.tensionFatalLimit=60000;material.shearElasticLimit=80000;material.shearFatalLimit=160000;
    PxDestructionStressDesc desc;desc.chunks=nodes.data();desc.chunkCount=unsigned(nodes.size());desc.chunkMassProperties=properties.data();
    desc.clusters=clusters.data();desc.clusterCount=unsigned(clusters.size());desc.bonds=bonds.data();desc.bondCount=unsigned(bonds.size());
    desc.materials=&material;desc.materialCount=1;desc.maxIterations=stressIterations;desc.tolerance=1e-5f;desc.internalCorrectionLimit=1;desc.preserveUnchangedContactPairs=preservePairs;desc.gpuIslandRepair=gpuIslandRepair;
    auto* destruction=scene.getDestructionScene();require(destruction && destruction->configureStress(desc),"native destruction configuration failed");
    const PxVec3 center(float(grid-1)*8,4,float(grid-1)*8);std::array<Camera,4> cameras;
    for(unsigned i=0;i<4;++i){const float angle=float(i)*1.5707963f+.6f;cameras[i].eye=center+PxVec3(std::cos(angle)*float(grid)*24,float(grid)*13,std::sin(angle)*float(grid)*24);cameras[i].direction=(center-cameras[i].eye).getNormalized();}
    require(videoPath.empty() || gpuRender,"--gpu-video requires --gpu-render 1");
    require(videoPath.empty() || !std::filesystem::exists(videoPath),"GPU video already exists");
    std::vector<NativeGpuVisual> gpuVisuals;gpuVisuals.reserve(chunks.size());
    for(const auto& chunk:chunks)gpuVisuals.push_back({chunk.position,half,chunk.building%4});
    NativeGpuConsumer gpuConsumer(cuda,*destruction,gpuVisuals,buildings*waves);
    Camera gpuView=cameras[0];
    if(gpuCamera=="close"){
        const PxVec3 focus(grid==1?0:8,5,grid==1?0:8);
        gpuView.eye=focus+PxVec3(29,21,-39);gpuView.direction=(focus-gpuView.eye).getNormalized();
    }
    if(gpuRender)gpuConsumer.enableRenderer(960,540,gpuView,videoPath,recordFps);
    const bool observePoses=recordState || auditMotion;
    unsigned long long poseReadbackBytes=0;
    StateWriter writer;if(recordState)require(writer.open(statePath,recordFps,recordFrames,960,540,buildings,seconds,0,cameras),"state output failed");
    if(recordState)for(unsigned i=0;i<chunks.size();++i){VisualActor visual;visual.parameters=half;visual.part=chunks[i].building%4;require(writer.defineActor(i,visual),"chunk visual definition failed");}
    std::ofstream telemetry(output+"/native.frames.csv");
    telemetry<<"step,simulation_seconds,physics_step_ms,stress_solve_ms,frame_host_ms,bodies,awake_bodies,splits_total,contacts_total,resim_passes,correction_status,contacts_frame,projectiles_active,bonds_broken,stress_iterations,stress_converged,observation_ms,gpu_render_submit_and_export_ms\n";
    std::vector<Shot> shots;std::vector<PxU32> shotIds;std::vector<PxTransform> shotPoses;std::vector<VisualPose> poses;
    CUdeviceptr deviceIds=0,devicePoses=0;CUevent observationIdsReady=nullptr;
    if(observePoses){PxScopedCudaLock lock(cuda);check(cuEventCreate(&observationIdsReady,CU_EVENT_DISABLE_TIMING));check(cuMemAlloc(&deviceIds,std::max(size_t(buildings*waves),chunks.size())*sizeof(PxU32)));check(cuMemAlloc(&devicePoses,std::max(size_t(buildings*waves),chunks.size())*sizeof(PxTransform)));}
    unsigned launched=0,totalCorrections=0,totalBroken=0,peakClusters=buildings;unsigned long long totalContacts=0;
    std::vector<double> times;double maxStep=0,sumStep=0,sumRender=0,maxRender=0;unsigned deadlines=0;
    const float launchWindow=std::max(1.0f,seconds-5);
    float observedChunkTop=12.5f,maxMotionError=0;
    std::ofstream launches(output+"/native.launches.csv");
    launches<<"projectile,step,target_building,x,y,z,vx,vy,vz,chunk_ceiling\n";
    for(unsigned frame=0;frame<frames;++frame){
        const auto tick=Clock::now();const float time=frame*dt;
        while(launched<buildings*waves && time>=launchWindow*float(launched)/float(buildings*waves)){
            const unsigned building=launched%buildings,wave=launched/buildings;const auto origin=origins[building];
            auto launch=nativeBombardmentLaunch(origin,wave,12.5f);
            // Explicit gameplay observation: CUDA checks committed chunks and
            // projectiles and returns one clearance height. Pose arrays are
            // optional recording/audit output and never drive launch commands.
            const float clearHeight=gpuConsumer.launchHeight(launch.position,.75f);
            if(launch.position.y<clearHeight){
                launch.position.y+=2*std::ceil((clearHeight-launch.position.y)/2);
                launch.velocity=(launch.target-launch.position)/1.5f;launch.velocity.y+=.5f*9.81f*1.5f;
                require(launch.position.isFinite() && launch.velocity.isFinite(),"unrepresentable projectile command");
            }
            require(launch.position.y-.75f>12.5f,"projectile spawn overlaps authored skyline");
            const PxVec3 speed=launch.velocity;
            launches<<launched<<','<<frame<<','<<building<<','<<launch.position.x<<','<<launch.position.y<<','<<launch.position.z<<','<<speed.x<<','<<speed.y<<','<<speed.z<<','<<observedChunkTop<<'\n';
            auto* shot=physics.createRigidDynamic(PxTransform(launch.position));auto* sphere=physics.createShape(PxSphereGeometry(.75f),context.material(),true);
            require(shot && sphere && shot->attachShape(*sphere),"projectile creation failed");sphere->release();
            shot->setMass(20000);shot->setMassSpaceInertiaTensor(PxVec3(.4f*20000*.75f*.75f));shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(speed);scene.addActor(*shot);
            const unsigned visualId=unsigned(chunks.size())+launched;VisualActor visual;visual.shape=VisualActor::Shape::Sphere;visual.parameters=PxVec3(.75f,0,0);visual.part=5;
            if(recordState)require(writer.defineActor(visualId,visual),"projectile visual definition failed");shots.push_back({shot,visualId});gpuConsumer.addProjectile(shot->getGPUIndex(),PxTransform(launch.position));++launched;
        }
        phaseProfiler.begin(frame);
        const auto begin=Clock::now();scene.simulate(dt);PxU32 error=0;const bool complete=scene.fetchResults(true,&error);const double simulationMs=ms(begin);
        if(auditIslands)requireNativeGraphAudit(scene,output+"/native.graph-diagnostics.json");
        const auto status=destruction->getLastStatus();
        if(!complete || error || status.error){std::fprintf(stderr,"INCOMPLETE native step %u: fetch=%u stage=%u broken=%u crushed=%u\n",frame,error,status.error,status.brokenBonds,status.crushedChunks);throw std::runtime_error("native demo correction incomplete");}
        require(status.converged,"native demo accepted an unconverged stress solve");
        require(status.correctionPasses<=1,"native demo exceeded one internal correction");require(status.frame==frame+1,"native demo duplicated timestep");
        require(status.brokenBonds==0 || totalContacts+status.normalContacts>0,"authored building fractured before any actual impact");
        phaseProfiler.acceptedFrame();
        totalCorrections+=status.correctionPasses;totalBroken+=status.brokenBonds;totalContacts+=status.normalContacts;
        const auto observation=Clock::now();const auto view=destruction->getDeviceView();PxDestructionTopologyStatus topology{};
        std::vector<PxU32> membership,slots;std::vector<PxDestructionClusterMotion> motions;
        {PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));check(cuMemcpyDtoH(&topology,CUdeviceptr(view.acceptedTopology.status),sizeof(topology)));
        }
        require(!topology.slotError,"incomplete GPU cluster slot allocation");
        gpuConsumer.update(scene.getDirectGPUAPI());
        const auto renderStart=Clock::now();
        if(gpuRender && frame%recordStride==0)gpuConsumer.render();
        const double renderMs=gpuRender && frame%recordStride==0?ms(renderStart):0;
        sumRender+=renderMs;maxRender=std::max(maxRender,renderMs);
        if(observePoses){
          {PxScopedCudaLock lock(cuda);
            read(membership,view.acceptedTopology.chunkCluster,chunks.size());read(slots,view.acceptedTopology.clusterSlots,chunks.size());read(motions,view.acceptedTopology.motions,view.acceptedTopology.slotCapacity);
            shotIds.clear();for(const auto& shot:shots)shotIds.push_back(shot.actor->getGPUIndex());shotPoses.resize(shots.size());
            if(!shots.empty()){check(cuMemcpyHtoD(deviceIds,shotIds.data(),shotIds.size()*sizeof(PxU32)));check(cuEventRecord(observationIdsReady,nullptr));
                require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(devicePoses),reinterpret_cast<const PxU32*>(deviceIds),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,unsigned(shots.size()),observationIdsReady),"projectile observation failed");
                check(cuCtxSynchronize());check(cuMemcpyDtoH(shotPoses.data(),devicePoses,shotPoses.size()*sizeof(PxTransform)));}}
        poses.clear();poses.reserve(chunks.size()+shots.size());observedChunkTop=0;
        for(unsigned i=0;i<chunks.size();++i){require(membership[i]<slots.size() && slots[membership[i]]<motions.size(),"invalid committed chunk membership");const auto& motion=motions[slots[membership[i]]];
            const PxTransform pose(PxVec3(float(motion.origin[0]),float(motion.origin[1]),float(motion.origin[2])),PxQuat(float(motion.orientation[0]),float(motion.orientation[1]),float(motion.orientation[2]),float(motion.orientation[3])));
            require(pose.isValid(),"nonfinite committed cluster motion");const auto chunkPose=pose*PxTransform(chunks[i].position);
            observedChunkTop=std::max(observedChunkTop,chunkPose.p.y+half.magnitude());poses.push_back({i,chunkPose,false});}
        for(unsigned i=0;i<shots.size();++i){require(shotPoses[i].isValid(),"nonfinite projectile motion");poses.push_back({shots[i].visual,shotPoses[i],false});}
          poseReadbackBytes+=chunks.size()*2*sizeof(PxU32)+view.acceptedTopology.slotCapacity*sizeof(PxDestructionClusterMotion)+shots.size()*sizeof(PxTransform);
        }
        if(auditMotion) {
            std::vector<PxU32> owners;std::vector<PxTransform> physical(chunks.size());owners.reserve(chunks.size());
            for(const auto& chunk:chunks){const auto* owner=chunk.shape->getActor()->is<PxRigidDynamic>();require(owner,"chunk has no rigid owner");owners.push_back(owner->getGPUIndex());}
            {PxScopedCudaLock lock(cuda);check(cuMemcpyHtoD(deviceIds,owners.data(),owners.size()*sizeof(PxU32)));check(cuEventRecord(observationIdsReady,nullptr));
                require(scene.getDirectGPUAPI().getRigidDynamicData(reinterpret_cast<void*>(devicePoses),reinterpret_cast<const PxU32*>(deviceIds),PxRigidDynamicGPUAPIReadType::eGLOBAL_POSE,unsigned(owners.size()),observationIdsReady),"physical chunk pose audit failed");
                check(cuCtxSynchronize());check(cuMemcpyDtoH(physical.data(),devicePoses,physical.size()*sizeof(PxTransform)));poseReadbackBytes+=physical.size()*sizeof(PxTransform);}
            for(unsigned i=0;i<chunks.size();++i){const auto actual=physical[i]*chunks[i].shape->getLocalPose();
                const float error=(actual.p-poses[i].pose.p).magnitude();maxMotionError=std::max(maxMotionError,error);
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
        // Stress time is included in physics_step_ms, not separately instrumented.
        // The recording uses the compact HUD, which only displays total times.
        telemetry<<frame<<','<<(frame+1)*dt<<','<<simulationMs<<",0,"<<ms(tick)<<','<<topology.clusterCount+shots.size()<<','<<topology.clusterCount+shots.size()<<','<<topology.clusterCount-buildings<<','<<totalContacts<<','<<status.correctionPasses<<",0,"<<status.normalContacts<<','<<shots.size()<<','<<status.brokenBonds<<','<<status.iterations<<','<<status.converged<<','<<observationMs<<','<<renderMs<<'\n';
        if(frame%60==0){std::printf("native t=%.1f chunks=%zu bonds=%zu clusters=%u shots=%zu broken=%u corrections=%u step=%.2fms\n",time,chunks.size(),bonds.size(),topology.clusterCount,shots.size(),totalBroken,totalCorrections,simulationMs);std::fflush(stdout);}
    }
    require(totalCorrections && totalBroken && peakClusters>buildings,"native bombardment did not demonstrate destruction");if(recordState)require(writer.finish(),"state stream finalization failed");
    gpuConsumer.finishVideo();
    std::sort(times.begin(),times.end());auto percentile=[&](double p){return times[std::min(times.size()-1,size_t(p*times.size()))];};
    if(observePoses){PxScopedCudaLock lock(cuda);check(cuEventDestroy(observationIdsReady));check(cuMemFree(deviceIds));check(cuMemFree(devicePoses));}
    writeNativeGraphDiagnostics(scene,output+"/native.graph-diagnostics.json");
    require(destruction->clearStress(),"native fragment cleanup failed");for(auto* parent:parents)parent->release();for(auto& shot:shots)shot.actor->release();for(auto& chunk:chunks)chunk.shape->release();
    require(context.healthy(),"native demo GPU health failed");
    std::ofstream manifest(output+"/native.summary.json");
    manifest<<"{\n  \"physics_ms_min\": "<<times.front()<<",\n  \"physics_ms_mean\": "<<sumStep/frames<<",\n  \"simulation_realtime_fraction\": "<<seconds*1000/sumStep<<",\n  \"gpu_render_submit_and_export_ms_mean\": "<<(gpuConsumer.renderedFrames()?sumRender/gpuConsumer.renderedFrames():0)<<",\n  \"gpu_render_submit_and_export_ms_max\": "<<maxRender<<",\n  \"topology_stats_readback_bytes\": "<<frames*sizeof(PxDestructionTopologyStatus)<<",\n  \"gpu_rendered_frames\": "<<gpuConsumer.renderedFrames()<<",\n  \"gpu_renderer\": \""<<gpuConsumer.rendererName()<<"\",\n  \"consumer_pose_readback_bytes\": "<<poseReadbackBytes<<",\n  \"consumer_query_readback_bytes\": "<<gpuConsumer.queryReadbackBytes()<<",\n  \"export_pixel_readback_bytes\": "<<gpuConsumer.pixelReadbackBytes()<<",\n  \"backend\": \"native PhysX GPU task graph + resident CUDA destruction\",\n  \"status\": \"completed\",\n  \"frames\": "<<frames<<",\n  \"seconds\": "<<seconds<<",\n  \"buildings\": "<<buildings<<",\n  \"chunks\": "<<chunks.size()<<",\n  \"bonds\": "<<bonds.size()<<",\n  \"peak_clusters\": "<<peakClusters<<",\n  \"projectiles\": "<<shots.size()<<",\n  \"broken_bonds\": "<<totalBroken<<",\n  \"corrections\": "<<totalCorrections<<",\n  \"spawn_protocol\": \"gpu-clear-aerial-ballistic-v3\",\n  \"island_boundary_audit_enabled\": "<<(auditIslands?"true":"false")<<",\n  \"motion_audit_enabled\": "<<(auditMotion?"true":"false")<<",\n  \"max_motion_position_error\": "<<maxMotionError<<",\n  \"record_fps\": "<<recordFps<<",\n  \"gpu_island_repair\": "<<(gpuIslandRepair?"true":"false")<<",\n  \"gpu_pre_solve_islands\": "<<(preSolveIslands?"true":"false")<<",\n  \"gpu_pre_solve_support\": "<<(preSolveSupport?"true":"false")<<",\n  \"gpu_pre_solve_contacts\": "<<(preSolveContacts?"true":"false")<<",\n  \"preserve_contact_pairs\": "<<(preservePairs?"true":"false")<<",\n  \"recorded_state\": "<<(recordState?"true":"false")<<",\n  \"correction_limit\": 1,\n  \"physics_ms_p50\": "<<percentile(.5)<<",\n  \"physics_ms_p95\": "<<percentile(.95)<<",\n  \"physics_ms_p99\": "<<percentile(.99)<<",\n  \"physics_ms_max\": "<<maxStep<<",\n  \"missed_16_67ms\": "<<deadlines<<",\n  \"stress_included_in_physics_time\": true,\n  \"isolated_performance_qualification\": false,\n  \"sleeping\": false,\n  \"crushing_material_enabled\": false\n}\n";
    return 0;
}
}
int main(int argc,char** argv){try{return run(argc,argv);}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
