// Native PhysX GPU wall impact. This program authors a bonded asset and one
// projectile; PhysX owns stress, fracture, correction and motion. JSON observes
// committed state only. It is not a renderer or a real-time performance test.
#include "physx_scene.h"
#include <PxDestructionScene.h>
#include "NpScene.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "PxgBodySim.h"
#include "PxsRigidBody.h"
#include "state_writer.h"
#include "tests/native_wall_shape_audit.h"
#include "tests/native_wall_pair_audit.h"
#include <cuda.h>
#include <algorithm>
#include <cmath>
#include <chrono>
#include <cstdint>
#include <cstring>
#include <unistd.h>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <limits>
#include <sstream>
#include <stdexcept>
#include <string>
#include <vector>

using namespace physx;
namespace {
void require(bool ok, const char* text) { if (!ok) throw std::runtime_error(text); }
void check(CUresult result) { require(result == CUDA_SUCCESS, "committed GPU observation failed"); }
// Host wall-clock phases, separate from Metal compilation spans and GPU timers.
// The timing analyzer clips/merges compiler spans against these same-clock bounds.
class WallTimingScope {
    const char* stage; int frame; bool open=true; bool compileTrace;
    void emit(const char* event) const {
        const auto ns=std::chrono::duration_cast<std::chrono::nanoseconds>(
            std::chrono::steady_clock::now().time_since_epoch()).count();
        std::fprintf(stderr,"NATIVE_WALL_TIMING event=%s pid=%d stage=%s frame=%d clock=steady_clock monotonic_ns=%llu compile_trace=%u\n",
            event,int(getpid()),stage,frame,static_cast<unsigned long long>(ns),unsigned(compileTrace));
        std::fflush(stderr);
    }
public:
    explicit WallTimingScope(const char* name,int index=-1):stage(name),frame(index) {
        const char* setting=std::getenv("CUMETAL_TRACE_COMPILE");
        compileTrace=setting && std::strcmp(setting,"1")==0; emit("begin");
    }
    void finish() {if(open){emit("end");open=false;}}
    ~WallTimingScope(){finish();}
    WallTimingScope(const WallTimingScope&)=delete;
    WallTimingScope& operator=(const WallTimingScope&)=delete;
};
std::string quoted(const std::string& value) {
    std::ostringstream out; out << '"';
    for (unsigned char c : value) {
        if (c == '"' || c == '\\') out << '\\' << char(c);
        else if (c < 32) out << "\\u" << std::hex << std::setw(4) << std::setfill('0') << unsigned(c) << std::dec;
        else out << char(c);
    }
    return out.str() + '"';
}
void vec(std::ostream& out, const PxVec3& p) { out << '[' << p.x << ',' << p.y << ',' << p.z << ']'; }
void pose(std::ostream& out, PxU32 id, const PxTransform& p, bool visible, PxU32 root = PX_INVALID_U32) {
    require(p.isValid(), "nonfinite or invalid committed pose");
    out << "{\"id\":" << id << ",\"position\":"; vec(out,p.p);
    out << ",\"rotation\":[" << p.q.x << ',' << p.q.y << ',' << p.q.z << ',' << p.q.w
        << "],\"visible\":" << (visible ? "true" : "false");
    if (root != PX_INVALID_U32) out << ",\"cluster_id\":" << root;
    out << '}';
}
template<class T> void observe(std::vector<T>& values, const T* source, size_t count) {
    require(source || !count, "missing accepted device array"); values.resize(count);
    if (count) check(cuMemcpyDtoH(values.data(), reinterpret_cast<CUdeviceptr>(source), count*sizeof(T)));
}
// Optional diagnostic readback at the existing committed-frame boundary. This
// never writes simulation state and never synchronizes between kernels. A CPU/GPU
// disagreement is recorded, not used to stop the requested observation window.
void diagnosticReal(std::ostream& out, float value) {
    if(std::isfinite(value)) out<<value; else out<<"null";
}
void diagnosticVec(std::ostream& out,const PxVec3& value) {
    out<<'[';diagnosticReal(out,value.x);out<<',';diagnosticReal(out,value.y);out<<',';diagnosticReal(out,value.z);out<<']';
}
void diagnosticPose(std::ostream& out,const PxTransform& value) {
    out<<"{\"position\":";diagnosticVec(out,value.p);out<<",\"rotation\":[";
    diagnosticReal(out,value.q.x);out<<',';diagnosticReal(out,value.q.y);out<<',';
    diagnosticReal(out,value.q.z);out<<',';diagnosticReal(out,value.q.w);out<<"]}";
}
void auditGpuState(std::ostream& out,PxScene& scene,PxCudaContextManager& cuda,
    const std::vector<PxShape*>& shapes,PxRigidDynamic& ball,unsigned frame,
    const std::vector<PxDestructionStressBond>& bonds) {
    struct Record {PxRigidDynamic* actor;PxU32 index;PxgBodySim body;PxTransform gpuPose;bool poseValid;};
    std::vector<Record> records;
    std::vector<unsigned> shapeOwners;
    auto addOwner=[&](PxRigidDynamic* actor) {
        require(actor,"GPU audit expected a dynamic rigid owner");
        for(unsigned i=0;i<records.size();++i) if(records[i].actor==actor)return i;
        const PxU32 index=actor->getGPUIndex();require(index!=PX_INVALID_U32,"GPU audit owner index missing");
        Record record{};record.actor=actor;record.index=index;record.gpuPose=PxTransform(PxIdentity);
        records.push_back(record);return unsigned(records.size()-1);
    };
    for(auto* shape:shapes) {
        auto* actor=shape->getActor();require(actor,"GPU audit shape owner missing");
        shapeOwners.push_back(addOwner(actor->is<PxRigidDynamic>()));
    }
    const unsigned ballOwner=addOwner(&ball);
    auto* controller=static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController());
    require(controller,"GPU audit simulation controller missing");
    {
        // readyEvent has already completed before this call. One copy per unique
        // actor (not per shape), with no writes or extra event/stream waits.
        PxScopedCudaLock lock(cuda);
        const auto* deviceBodies=controller->getSimulationCore()->getBodySimBufferDevicePtr().getPointer();
        require(deviceBodies,"GPU audit body buffer missing");
        for(auto& r:records) {
            check(cuMemcpyDtoH(&r.body,reinterpret_cast<CUdeviceptr>(deviceBodies+r.index),sizeof(r.body)));
            const auto world=r.body.body2World.getTransform();
            const auto local=r.body.body2Actor_maxImpulseW.getTransform();
            r.poseValid=world.isValid() && local.isValid();
            if(r.poseValid) {r.gpuPose=world*local.getInverse();r.poseValid=r.gpuPose.isValid();}
        }
    }
    out<<",\"gpu_state_audit\":{\"observational_only\":true,\"gpu_body_records\":[";
    for(unsigned i=0;i<records.size();++i) {
        const auto& r=records[i];const auto& b=r.body;
        const auto cpuPose=r.actor->getGlobalPose();const auto cpuV=r.actor->getLinearVelocity();
        const auto cpuW=r.actor->getAngularVelocity();
        const PxVec3 gpuV(b.linearVelocityXYZ_inverseMassW.x,b.linearVelocityXYZ_inverseMassW.y,b.linearVelocityXYZ_inverseMassW.z);
        const PxVec3 gpuW(b.angularVelocityXYZ_maxPenBiasW.x,b.angularVelocityXYZ_maxPenBiasW.y,b.angularVelocityXYZ_maxPenBiasW.z);
        const float cpuWake=r.actor->getWakeCounter(),gpuWake=b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.y;
        const bool finite=r.poseValid && cpuPose.isValid() && gpuV.isFinite() && gpuW.isFinite()
            && cpuV.isFinite() && cpuW.isFinite() && std::isfinite(cpuWake) && std::isfinite(gpuWake);
        const float positionError=r.poseValid?(cpuPose.p-r.gpuPose.p).magnitude():std::numeric_limits<float>::quiet_NaN();
        const bool poseMismatch=!r.poseValid || !(positionError<1e-4f && PxAbs(cpuPose.q.dot(r.gpuPose.q))>1-1e-5f);
        const bool velocityMismatch=!((cpuV-gpuV).magnitude()<1e-4f && (cpuW-gpuW).magnitude()<1e-4f);
        if(i)out<<',';
        out<<"{\"owner_record\":"<<i<<",\"gpu_index\":"<<r.index<<",\"cpu_actor_pose\":";diagnosticPose(out,cpuPose);
        out<<",\"gpu_actor_pose\":";if(r.poseValid)diagnosticPose(out,r.gpuPose);else out<<"null";
        out<<",\"gpu_body2world\":";diagnosticPose(out,b.body2World.getTransform());
        out<<",\"gpu_body2actor\":";diagnosticPose(out,b.body2Actor_maxImpulseW.getTransform());
        out<<",\"cpu_linear_velocity\":";diagnosticVec(out,cpuV);out<<",\"gpu_linear_velocity\":";diagnosticVec(out,gpuV);
        out<<",\"cpu_angular_velocity\":";diagnosticVec(out,cpuW);out<<",\"gpu_angular_velocity\":";diagnosticVec(out,gpuW);
        out<<",\"cpu_wake\":";diagnosticReal(out,cpuWake);out<<",\"gpu_wake\":";diagnosticReal(out,gpuWake);
        out<<",\"cpu_sleeping\":"<<(r.actor->isSleeping()?"true":"false")
           <<",\"cpu_kinematic\":"<<(r.actor->getRigidBodyFlags()&PxRigidBodyFlag::eKINEMATIC?"true":"false")
           <<",\"gpu_internal_flags\":"<<b.internalFlags<<",\"gpu_disable_gravity\":"<<b.disableGravity;
        out<<",\"gpu_freeze_count\":";diagnosticReal(out,b.sleepLinVelAccXYZ_freezeCountW.w);
        out<<",\"gpu_freeze_threshold\":";diagnosticReal(out,b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.x);
        out<<",\"gpu_sleep_threshold\":";diagnosticReal(out,b.freezeThresholdX_wakeCounterY_sleepThresholdZ_bodySimIndex.z);
        out<<",\"finite\":"<<(finite?"true":"false")<<",\"pose_mismatch\":"<<(poseMismatch?"true":"false")
           <<",\"velocity_mismatch\":"<<(velocityMismatch?"true":"false")<<",\"position_error\":";
        diagnosticReal(out,positionError);out<<'}';
        if(!finite || poseMismatch || velocityMismatch)
            std::fprintf(stderr,"wall GPU audit frame=%u owner=%u gpuIndex=%u finite=%u poseMismatch=%u velocityMismatch=%u positionError=%.9g cpuWake=%.9g gpuWake=%.9g flags=0x%x; observation continues\n",
                frame,i,r.index,unsigned(finite),unsigned(poseMismatch),unsigned(velocityMismatch),double(positionError),double(cpuWake),double(gpuWake),b.internalFlags);
    }
    out<<"],\"gpu_shape_poses\":[";
    auto emitShape=[&](unsigned id,unsigned owner,const PxTransform& local) {
        const auto& r=records[owner];if(id)out<<',';
        out<<"{\"id\":"<<id<<",\"owner_record\":"<<owner<<",\"gpu_index\":"<<r.index<<",\"shape_local_pose\":";
        diagnosticPose(out,local);out<<",\"pose\":";
        if(r.poseValid && local.isValid())diagnosticPose(out,r.gpuPose*local);else out<<"null";
        out<<'}';
    };
    for(unsigned i=0;i<shapes.size();++i)emitShape(i,shapeOwners[i],shapes[i]->getLocalPose());
    PxShape* ballShape=nullptr;require(ball.getNbShapes()==1 && ball.getShapes(&ballShape,1)==1,"GPU audit projectile shape missing");
    emitShape(unsigned(shapes.size()),ballOwner,ballShape->getLocalPose());
    out<<"],\"collision_shapes\":[";
    auto* destruction=scene.getDestructionScene();require(destruction,"shape audit destruction view missing");
    for(unsigned i=0;i<shapes.size();++i) {
        const auto r=wall_shape_audit::read(scene,cuda,*destruction,*shapes[i]);
        if(i)out<<',';
        out<<"{\"id\":"<<i<<",\"shape_id\":"<<r.shapeId<<",\"cpu_gpu_index\":"<<r.cpuBodyIndex
           <<",\"shape_owner_node\":"<<r.shapeSim.mBodySimIndex.getInd()<<",\"np_owner_node\":"<<r.npOwner.getInd()
           <<",\"shape_owner_index\":"<<r.shapeSim.mBodySimIndex.index()<<",\"gpu_local_pose\":";
        diagnosticPose(out,r.shapeSim.mTransform);
        out<<",\"gpu_shape_pose\":";diagnosticPose(out,r.gpuShapePose);
        out<<",\"cached_pose\":";diagnosticPose(out,r.cached.transform);
        out<<",\"cache_flags\":"<<r.cached.flags<<",\"bounds_min\":";diagnosticVec(out,r.bounds.minimum);
        out<<",\"bounds_max\":";diagnosticVec(out,r.bounds.maximum);
        out<<",\"local_bounds_min\":";diagnosticVec(out,r.shapeSim.mLocalBounds.minimum);
        out<<",\"local_bounds_max\":";diagnosticVec(out,r.shapeSim.mLocalBounds.maximum);
        out<<'}';
    }
    out<<"],\"contact_pairs\":[";
    auto* np=static_cast<PxgGpuContext*>(static_cast<NpScene&>(scene).getScScene().getDynamicsContext())->getNarrowphaseCore();
    for(unsigned b=0;b<bonds.size();++b) {
        const auto a=bonds[b].chunk0,c=bonds[b].chunk1;
        const auto p=wall_pair_audit::read(*shapes[a],*shapes[c],cuda,*np);
        if(b)out<<',';
        out<<"{\"chunks\":["<<a<<','<<c<<"],\"shape_ids\":["<<p.shape0<<','<<p.shape1
           <<"],\"same_cpu_owner\":"<<(p.sameCpuOwner?"true":"false")<<",\"interactions\":[";
        for(unsigned j=0;j<p.interactions.size();++j) {
            const auto& v=p.interactions[j];if(j)out<<',';
            out<<"{\"type\":"<<v.type<<",\"has_manager\":"<<(v.hasManager?"true":"false")
               <<",\"has_touch\":"<<(v.hasTouch?"true":"false")<<",\"pair_flags\":"<<v.pairFlags<<",\"np_index\":"<<v.npIndex<<",\"work_flags\":"<<v.workFlags<<",\"work_status_flags\":"<<v.workStatusFlags<<'}';
        }
        out<<"],\"managers\":[";
        for(unsigned j=0;j<p.managers.size();++j) {
            const auto& v=p.managers[j];if(j)out<<',';
            out<<"{\"new_bucket\":"<<(v.newBucket?"true":"false")<<",\"index\":"<<v.index<<",\"np_index\":"<<v.npIndex
               <<",\"storage_ready\":"<<(v.storageReady?"true":"false");
            if(v.storageReady) {
                out<<",\"shape_refs\":["<<v.input.shapeRef0<<','<<v.input.shapeRef1<<"],\"cache_refs\":["<<v.input.transformCacheRef0<<','<<v.input.transformCacheRef1
                   <<"],\"contacts\":"<<v.output.nbContacts<<",\"patches\":"<<unsigned(v.output.nbPatches)<<",\"previous_patches\":"<<unsigned(v.output.prevPatches)
                   <<",\"status_flags\":"<<unsigned(v.output.statusFlag)<<",\"flags\":"<<v.output.flags<<",\"response_epoch\":"<<v.output.nativeResponseEpoch
                   <<",\"cpu_tokens\":{\"patches\":"<<reinterpret_cast<uintptr_t>(v.output.contactPatches)<<",\"points\":"<<reinterpret_cast<uintptr_t>(v.output.contactPoints)
                   <<",\"forces\":"<<reinterpret_cast<uintptr_t>(v.output.contactForces)<<",\"friction\":"<<reinterpret_cast<uintptr_t>(v.output.frictionPatches)<<'}';
            }
            out<<",\"merged_index\":"<<v.mergedIndex<<",\"merged_observed\":"<<(v.mergedObserved?"true":"false")
               <<",\"expected_response_epoch\":"<<v.expectedEpoch;
            if(v.mergedObserved) {
                out<<",\"merged_contacts\":"<<v.mergedOutput.nbContacts<<",\"merged_patches\":"<<unsigned(v.mergedOutput.nbPatches)
                   <<",\"merged_status_flags\":"<<unsigned(v.mergedOutput.statusFlag)<<",\"merged_flags\":"<<v.mergedOutput.flags
                   <<",\"merged_response_epoch\":"<<v.mergedOutput.nativeResponseEpoch
                   <<",\"response_epoch_matched\":"<<(v.expectedEpoch && v.mergedOutput.nativeResponseEpoch==v.expectedEpoch?"true":"false");
            }
            out<<",\"forces_observed\":"<<(v.forcesObserved?"true":"false")<<",\"normal_forces\":[";
            for(unsigned k=0;k<v.forces.size();++k){if(k)out<<',';diagnosticReal(out,v.forces[k]);}
            out<<"]}";
        }
        out<<"]}";
    }
    out<<"]}";
}
struct Options {
    unsigned width=9, height=7, frames=360, iterations=8192;
    float mass=600, speed=12, strength=1, foundationStrength=1;
    bool recordBondStress=false, auditGpuState=false;
    std::string output, state;
};
unsigned number(const char* text) {
    size_t used=0; const auto n=std::stoul(text,&used);
    require(used==std::string(text).size() && n<=std::numeric_limits<unsigned>::max(), "invalid integer option");
    return unsigned(n);
}
float real(const char* text) {
    size_t used=0; const float n=std::stof(text,&used);
    require(used==std::string(text).size() && std::isfinite(n), "invalid real option"); return n;
}
Options options(int argc,char** argv) {
    Options o;
    for(int i=1;i<argc;++i) {
        const std::string flag=argv[i];
        if(flag=="--help") {
            std::puts("native_wall_capture --output NEW_FILE.json [--state NEW_FILE.twstate] [--width 9 --height 7 --frames 360 --stress-iterations 8192 --projectile-mass 600 --projectile-speed 12 --material-strength 1 --foundation-strength 1 --record-bond-stress 0 --audit-gpu-state 0]");
            std::exit(0);
        }
        require(i+1<argc,"missing option value"); const char* value=argv[++i];
        if(flag=="--output") o.output=value;
        else if(flag=="--state") o.state=value;
        else if(flag=="--width") o.width=number(value);
        else if(flag=="--height") o.height=number(value);
        else if(flag=="--frames") o.frames=number(value);
        else if(flag=="--stress-iterations") o.iterations=number(value);
        else if(flag=="--projectile-mass") o.mass=real(value);
        else if(flag=="--projectile-speed") o.speed=real(value);
        else if(flag=="--material-strength") o.strength=real(value);
        else if(flag=="--foundation-strength") o.foundationStrength=real(value);
        else if(flag=="--record-bond-stress") {
            const unsigned enabled=number(value); require(enabled<=1,"record-bond-stress must be 0 or 1");
            o.recordBondStress=enabled!=0;
        }
        else if(flag=="--audit-gpu-state") {
            const unsigned enabled=number(value); require(enabled<=1,"audit-gpu-state must be 0 or 1");
            o.auditGpuState=enabled!=0;
        }
        else throw std::runtime_error("unknown option: "+flag);
    }
    require(!o.output.empty() && o.width>=3 && o.width<=32 && o.height>=3 && o.height<=32,
        "supply --output and wall dimensions in 3..32");
    require(o.frames>=1 && o.frames<=3600 && o.iterations>=128 && o.iterations<=32768,
        "frames must be 1..3600; stress iterations 128..32768");
    require(o.mass>0 && o.mass<=100000 && o.speed>0 && o.speed<=30 && o.strength>0 && o.strength<=1000000,
        "invalid authored projectile/material values");
    require(o.foundationStrength>0, "foundation strength must be finite and positive");
    // Reject overflow/underflow before creating output or starting the scene.
    const double foundationScale=double(o.strength)*o.foundationStrength;
    require(500000.0*foundationScale<=std::numeric_limits<float>::max()
        && std::isfinite((500000.0f*o.strength)*o.foundationStrength)
        && (30000.0f*o.strength)*o.foundationStrength>0,
        "foundation material limits must remain finite and positive");
    return o;
}
// Keep this capture executable inside the user's repository write boundary.
std::filesystem::path outputPath(const std::string& requested) {
    namespace fs=std::filesystem;
    const auto source=fs::weakly_canonical(fs::absolute(fs::path(__FILE__)));
    const auto physx=source.parent_path().parent_path().parent_path();
    const auto cumetal=fs::weakly_canonical(physx.parent_path()/"cuda-metal");
    const auto output=fs::weakly_canonical(fs::absolute(requested));
    auto inside=[](const fs::path& path,const fs::path& root) {
        auto p=path.begin(); for(auto r=root.begin();r!=root.end();++r,++p) if(p==path.end() || *p!=*r) return false;
        return p!=path.end();
    };
    require(inside(output,physx) || inside(output,cumetal),"output must remain inside PhysX or sibling cuda-metal");
    require(!fs::exists(output) && !fs::is_symlink(fs::symlink_status(output)),"output already exists");
    fs::create_directories(output.parent_path()); return output;
}

int run(int argc,char** argv) {
    const auto o=options(argc,argv); const auto output=outputPath(o.output);
    // Optional compact binary trajectory for the native renderer. The JSON stays
    // the audit artifact; this carries the same committed poses at ~32 bytes per
    // body-frame instead of ~1.5 kB, delta-encoded, so long runs stay tractable.
    const auto statePath=o.state.empty()?std::filesystem::path():outputPath(o.state);
    WallTimingScope setupTiming("setup");
    constexpr float dt=1.0f/60.0f;
    const PxVec3 half(.48f); const float volume=8*half.x*half.y*half.z;
    const float blockMass=1000*volume, inertia=blockMass*(half.x*half.x+half.y*half.y)/3;
    const unsigned count=o.width*o.height, dynamicCount=count-o.width;
    blast_demo::SceneCapacity capacity; capacity.maxBodies=count+16; capacity.maxShapes=count+16;
    // Ordinary actor API mode, awake rigid scene, GPU TGS, no CPU contact reports.
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,
        false,true,false,false,PxSolverType::eTGS,false,false);
    require(context.gpuActive() && !context.directGpuApiActive(),"native ordinary GPU scene required");
    auto& physics=context.physics(); auto& scene=context.scene(); auto& cuda=*context.cudaContextManager();
    auto* wall=physics.createRigidDynamic(PxTransform(PxIdentity)); require(wall,"wall allocation failed");
    wall->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    wall->setLinearDamping(0); wall->setAngularDamping(0);
    std::vector<PxShape*> shapes; std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionChunkMassProperties> properties; std::vector<PxDestructionStressBond> bonds;
    std::vector<PxU32> foundationBondIds;
    const PxVec3 center(0,float(o.height)*.5f,0); PxVec3 totalInertia(0);
    for(unsigned y=0;y<o.height;++y) for(unsigned x=0;x<o.width;++x) {
        const unsigned id=y*o.width+x; const PxVec3 p(float(x)-float(o.width-1)*.5f,float(y)+.5f,0);
        auto* shape=physics.createShape(PxBoxGeometry(half),context.material(),true); require(shape,"wall shape allocation failed");
        shape->setLocalPose(PxTransform(p)); require(wall->attachShape(*shape),"wall shape attachment failed"); shapes.push_back(shape);
        chunks.push_back({p,y?blockMass:0.0f,y?inertia:0.0f,0,PX_INVALID_U32,volume,0});
        PxDestructionChunkMassProperties prop{}; prop.mass=blockMass; prop.supported=y==0;
        for(unsigned k=0;k<3;++k) {prop.center[k]=p[k];prop.inertia[k]=inertia;} properties.push_back(prop);
        const auto delta=p-center; totalInertia+=PxVec3(inertia+blockMass*(delta.y*delta.y+delta.z*delta.z),
            inertia+blockMass*(delta.x*delta.x+delta.z*delta.z),inertia+blockMass*(delta.x*delta.x+delta.y*delta.y));
        auto bond=[&](unsigned other) {
            const auto d=p-chunks[other].position;
            // A separate authored foundation mortar, only on vertical row-0/1 ties.
            const bool foundation=y==1 && other==id-o.width;
            if(foundation) foundationBondIds.push_back(PxU32(bonds.size()));
            bonds.push_back({other,id,(p+chunks[other].position)*.5f,d.getNormalized(),4*half.x*half.y,1,1,foundation?1u:0u});
        };
        if(x) bond(id-1); if(y) bond(id-o.width);
    }
    wall->setMass(blockMass*float(count)); wall->setCMassLocalPose(PxTransform(center));
    wall->setMassSpaceInertiaTensor(totalInertia); scene.addActor(*wall);
    // Configure the asset before launching the single real dynamic projectile.
    scene.simulate(dt); PxU32 setupError=0;
    require(scene.fetchResults(true,&setupError) && !setupError && context.healthy(),"native setup failed");
    auto* destruction=scene.getDestructionScene(); require(destruction,"integrated destruction is unavailable");
    for(unsigned i=0;i<count;++i) {
        chunks[i].contactIndex=destruction->getShapeContactIndex(*shapes[i]);
        require(chunks[i].contactIndex!=PX_INVALID_U32,"wall collision identity missing");
    }
    PxDestructionStressCluster cluster{wall->getGPUIndex(),center};
    PxDestructionMaterial materials[2];
    auto& material=materials[0];
    material.compressionElasticLimit=250000*o.strength;material.compressionFatalLimit=500000*o.strength;
    material.tensionElasticLimit=30000*o.strength;material.tensionFatalLimit=60000*o.strength;
    material.shearElasticLimit=80000*o.strength;material.shearFatalLimit=160000*o.strength;
    auto& foundationMaterial=materials[1]; foundationMaterial=material;
    foundationMaterial.compressionElasticLimit*=o.foundationStrength;
    foundationMaterial.compressionFatalLimit*=o.foundationStrength;
    foundationMaterial.tensionElasticLimit*=o.foundationStrength;
    foundationMaterial.tensionFatalLimit*=o.foundationStrength;
    foundationMaterial.shearElasticLimit*=o.foundationStrength;
    foundationMaterial.shearFatalLimit*=o.foundationStrength;
    PxDestructionStressDesc desc; desc.chunks=chunks.data();desc.chunkCount=count;desc.chunkMassProperties=properties.data();
    desc.clusters=&cluster;desc.clusterCount=1;desc.bonds=bonds.data();desc.bondCount=PxU32(bonds.size());
    desc.materials=materials;desc.materialCount=2;desc.maxIterations=o.iterations;desc.tolerance=1e-5f;
    desc.internalCorrectionLimit=1;desc.gpuIslandRepair=false;desc.preserveUnchangedContactPairs=false;
    require(destruction->configureStress(desc),"native wall stress configuration failed");
    constexpr float radius=.6f;
    auto* ball=PxCreateDynamic(physics,PxTransform(PxVec3(0,float(o.height)*.55f,-4)),PxSphereGeometry(radius),context.material(),1);
    require(ball,"projectile allocation failed");ball->setMass(o.mass);ball->setMassSpaceInertiaTensor(PxVec3(.4f*o.mass*radius*radius));
    ball->setLinearDamping(0);ball->setAngularDamping(0);ball->setLinearVelocity(PxVec3(0,0,o.speed));scene.addActor(*ball);

    // The trajectory declares geometry once and then records only changed poses.
    // Cameras are fixed at four by the format; author useful angles on the wall.
    blast_demo::StateWriter state;
    if(!o.state.empty()) {
        const float span=float(o.width), tall=float(o.height);
        const PxVec3 focus(0,tall*.5f,0);
        std::array<blast_demo::Camera,4> cameras{};
        const PxVec3 eyes[4]={PxVec3(0,tall*.65f,-(span*1.15f+4)),PxVec3(span*1.1f+3,tall*.7f,-(span*.6f+3)),
            PxVec3(0,tall*1.9f+3,-(span*.5f+3)),PxVec3(span*.35f+2,tall*.35f,-(span*.35f+2))};
        for(unsigned c=0;c<4;++c) {
            cameras[c].eye=eyes[c];cameras[c].direction=(focus-eyes[c]).getNormalized();cameras[c].fovDegrees=55;
        }
        require(state.open(statePath.string(),60,o.frames,1920,1080,1,float(o.frames)/60.0f,0.0f,cameras),
            ("trajectory open failed: "+state.error()).c_str());
        for(unsigned i=0;i<count;++i) {
            blast_demo::VisualActor actor; actor.shape=blast_demo::VisualActor::Shape::Box;
            actor.part=0; actor.parameters=half; actor.localPose=PxTransform(PxIdentity);
            require(state.defineActor(i,actor),("trajectory actor failed: "+state.error()).c_str());
        }
        blast_demo::VisualActor projectile; projectile.shape=blast_demo::VisualActor::Shape::Sphere;
        projectile.part=1; projectile.parameters=PxVec3(radius,radius,radius);
        require(state.defineActor(count,projectile),("trajectory actor failed: "+state.error()).c_str());
    }

    std::ofstream out(output); require(bool(out),"capture output could not be opened"); out<<std::setprecision(9);
#if defined(PX_CUMETAL) && PX_CUMETAL
    const char* backend="cumetal";
#else
    const char* backend="cuda";
#endif
    out<<"{\"schema\":\"physx.native-wall-capture\",\"version\":1,\"backend\":"<<quoted(backend)
       <<",\"timestep\":"<<dt<<",\"metadata\":{\"device\":"<<quoted(cuda.getDeviceName()?cuda.getDeviceName():"unknown")
       <<",\"width\":"<<o.width<<",\"height\":"<<o.height<<",\"ground_y\":0,\"fps\":60,\"requested_frames\":"<<o.frames
       <<",\"solver\":\"TGS\",\"stress_tolerance\":1e-5,\"stress_iterations\":"<<o.iterations
       <<",\"correction_limit\":1,\"warm_start\":true,\"gpu_island_repair\":false,\"cpu_pose_observation\":true"
       <<",\"realtime_claim\":false,\"projectile_mass\":"<<o.mass<<",\"projectile_speed\":"<<o.speed
       <<",\"material_strength\":"<<o.strength<<",\"material\":{\"compression_elastic\":"<<material.compressionElasticLimit
       <<",\"compression_fatal\":"<<material.compressionFatalLimit<<",\"tension_elastic\":"<<material.tensionElasticLimit
       <<",\"tension_fatal\":"<<material.tensionFatalLimit<<",\"shear_elastic\":"<<material.shearElasticLimit
       <<",\"shear_fatal\":"<<material.shearFatalLimit<<"},\"foundation_strength_multiplier\":"<<o.foundationStrength
       <<",\"foundation_material\":{\"compression_elastic\":"<<foundationMaterial.compressionElasticLimit
       <<",\"compression_fatal\":"<<foundationMaterial.compressionFatalLimit
       <<",\"tension_elastic\":"<<foundationMaterial.tensionElasticLimit
       <<",\"tension_fatal\":"<<foundationMaterial.tensionFatalLimit
       <<",\"shear_elastic\":"<<foundationMaterial.shearElasticLimit
       <<",\"shear_fatal\":"<<foundationMaterial.shearFatalLimit<<"},\"foundation_bond_ids\":[";
    for(unsigned i=0;i<foundationBondIds.size();++i) {if(i) out<<',';out<<foundationBondIds[i];}
    out<<"],\"record_bond_stress\":"<<(o.recordBondStress?"true":"false");
    out<<",\"audit_gpu_state\":"<<(o.auditGpuState?"true":"false")
       <<",\"gpu_state_audit_semantics\":\"Observational only; committed-frame readback, unique actor owners; mismatch does not stop capture.\"";
    if(o.recordBondStress) out<<",\"bond_stress_semantics\":\"Last trial verdicts, not per-frame peaks; correction may overwrite the original impact evaluation. Accepted health is separate.\"";
    out<<"},\"bodies\":[";
    for(unsigned i=0;i<count;++i) {
        if(i) out<<',';
        out<<"{\"id\":"<<i<<",\"chunk_id\":"<<i<<",\"shape\":\"box\",\"half_extents\":";vec(out,half);
        out<<",\"supported\":"<<(i<o.width?"true":"false")<<",\"color\":[0.64,0.39,0.22]}";
    }
    out<<",{\"id\":"<<count<<",\"shape\":\"sphere\",\"radius\":"<<radius<<",\"color\":[0.12,0.24,0.55]}],\"frames\":[\n";
    unsigned completed=0,broken=0,corrections=0,detached=0,peakDetached=0;
    std::vector<PxU32> active,roots,live,previous(bonds.size(),1);
    std::vector<blast_demo::VisualPose> trajectory;
    std::vector<PxDestructionBondVerdict> lastTrialVerdicts;
    std::vector<PxReal> acceptedBondHealth;
    std::string failure;
    setupTiming.finish();
    try {
        for(unsigned frame=0;frame<o.frames;++frame) {
            WallTimingScope stepTiming("physics_step",int(frame));
            scene.simulate(dt);PxU32 error=0;const bool accepted=scene.fetchResults(true,&error);
            const auto status=destruction->getLastStatus();
            require(accepted && !error && !status.error && context.healthy(),"native simulation did not publish an accepted step");
            require(status.correctionPasses<=1 && status.frame==frame+1 && status.stressPasses==1+status.correctionPasses,
                "native correction/time publication invariant failed");
            stepTiming.finish();
            WallTimingScope observationTiming("observation",int(frame));
            const auto view=destruction->getDeviceView();
            { PxScopedCudaLock lock(cuda);
                require(view.readyEvent,"missing committed observation event");check(cuEventSynchronize(view.readyEvent));
                observe(active,view.acceptedTopology.activeBonds,bonds.size());
                observe(roots,view.acceptedTopology.chunkCluster,count);observe(live,view.acceptedTopology.activeChunks,count);
                if(o.recordBondStress) {
                    observe(lastTrialVerdicts,view.bondVerdicts,bonds.size());
                    observe(acceptedBondHealth,view.bondHealth,bonds.size());
                }
            }
            std::vector<bool> supported(count,false);
            for(unsigned i=0;i<o.width;++i) {require(live[i] && roots[i]<count,"support chunk removed or invalid");supported[roots[i]]=true;}
            detached=0;
            std::ostringstream row;row<<std::setprecision(9)<<"{\"frame\":"<<frame<<",\"time\":"<<double(frame+1)/60.0<<",\"bodies\":[";
            trajectory.clear();
            for(unsigned i=0;i<count;++i) {
                if(i) row<<',';
                require(live[i] && roots[i]<count,"unexpected chunk removal in non-crushing wall");
                auto* owner=shapes[i]->getActor();require(owner,"committed wall chunk has no actor");
                const auto world=owner->getGlobalPose()*shapes[i]->getLocalPose();
                pose(row,i,world,true,roots[i]);
                // Identical committed pose; the trajectory must never diverge from
                // the audit JSON, so both are written from this one value.
                if(!o.state.empty()) trajectory.push_back({i,world,false,roots[i]});
                if(i>=o.width && !supported[roots[i]]) ++detached;
            }
            row<<',';pose(row,count,ball->getGlobalPose(),true);
            if(!o.state.empty()) {
                trajectory.push_back({count,ball->getGlobalPose(),false,blast_demo::VisualPose::kNoGroup});
                require(state.writeFrame(frame,trajectory),("trajectory frame failed: "+state.error()).c_str());
            }
            row<<"],\"fractures\":[";
            bool first=true;
            for(unsigned i=0;i<bonds.size();++i) {
                require(active[i]<=1 && !(active[i] && !previous[i]),"accepted bond state reactivated or invalid");
                if(previous[i] && !active[i]) {
                    if(!first) row<<',';first=false;++broken;
                    row<<"{\"bond_id\":"<<i<<",\"chunk0\":"<<bonds[i].chunk0<<",\"chunk1\":"<<bonds[i].chunk1<<'}';
                }
            }
            row<<"],\"status\":{\"converged\":"<<status.converged<<",\"iterations\":"<<status.iterations
               <<",\"correction_passes\":"<<status.correctionPasses<<",\"broken_bonds\":"<<status.brokenBonds
               <<",\"post_correction_broken_bonds\":"<<status.postCorrectionBrokenBonds
               <<",\"detached_chunks\":"<<detached<<"}";
            if(o.recordBondStress) {
                row<<",\"diagnostics\":{\"last_trial_bond_verdicts\":[";
                for(unsigned i=0;i<lastTrialVerdicts.size();++i) {
                    const auto& v=lastTrialVerdicts[i];
                    require(std::isfinite(v.health) && std::isfinite(v.damage) && std::isfinite(v.stressNormal)
                        && std::isfinite(v.stressShear) && std::isfinite(v.stressBend)
                        && std::isfinite(acceptedBondHealth[i]),"nonfinite bond diagnostic");
                    if(i) row<<',';
                    row<<"{\"bond_id\":"<<i<<",\"health\":"<<v.health<<",\"damage\":"<<v.damage
                       <<",\"normal\":"<<v.stressNormal<<",\"shear\":"<<v.stressShear
                       <<",\"bend\":"<<v.stressBend<<",\"command\":"<<v.command<<",\"broken\":"<<v.broken<<'}';
                }
                row<<"],\"accepted_bond_health\":[";
                for(unsigned i=0;i<acceptedBondHealth.size();++i) {if(i) row<<',';row<<acceptedBondHealth[i];}
                row<<"]}";
            }
            if(o.auditGpuState)auditGpuState(row,scene,cuda,shapes,*ball,frame,bonds);
            row<<'}';
            if(completed) out<<",\n";out<<row.str();out.flush();require(bool(out),"capture frame write failed");
            previous=active;++completed;corrections+=status.correctionPasses;peakDetached=std::max(peakDetached,detached);
            if(frame%30==0 || status.brokenBonds) std::fprintf(stderr,"wall frame %u: broken=%u detached=%u/%u converged=%u corrections=%u\n",
                frame,status.brokenBonds,detached,dynamicCount,status.converged,status.correctionPasses);
        }
        WallTimingScope teardownTiming("teardown");
        require(destruction->clearStress(),"native destruction teardown failed");
        ball->release();wall->release();for(auto* shape:shapes) shape->release();
        require(context.healthy(),"native scene reported a GPU failure");
    } catch(const std::exception& e) {failure=e.what();}
    const bool localized=broken>0 && detached>0 && peakDetached<=dynamicCount/2;
    out<<"\n],\"status\":"<<quoted(failure.empty()?"completed":"failed")<<",\"summary\":{\"frames\":"<<completed
       <<",\"chunks\":"<<count<<",\"bonds\":"<<bonds.size()<<",\"broken_bonds\":"<<broken
       <<",\"correction_passes\":"<<corrections<<",\"detached_chunks\":"<<detached
       <<",\"retained_non_support_chunks\":"<<dynamicCount-detached<<",\"peak_detached_chunks\":"<<peakDetached
       <<",\"localized_damage\":"<<(localized?"true":"false")<<",\"localized_damage_rule\":\"some detached; at most half of non-support chunks detached at any captured step\"},\"failure\":"<<quoted(failure)<<"}\n";
    out.close();require(bool(out),"capture finalization failed");
    // Close the trajectory before reporting success. A partial run still leaves a
    // readable prefix, but an unfinished file must not be presented as complete.
    if(!o.state.empty() && failure.empty())
        require(state.finish(),("trajectory finalization failed: "+state.error()).c_str());
    if(!failure.empty()) throw std::runtime_error(failure);
    std::printf("capture completed: %u committed frames; %u broken bonds; %u/%u non-support chunks detached; localized=%s\n",
        completed,broken,detached,dynamicCount,localized?"true":"false");
    // A valid simulation capture is retained for diagnosis, but no satisfying
    // localized-damage video should be advertised if this authored scene missed.
    return localized?0:2;
}
} // namespace
int main(int argc,char** argv) {
    try {return run(argc,argv);} catch(const std::exception& e) {
        std::fprintf(stderr,"native_wall_capture: %s\n",e.what());return 1;
    }
}
