// Physical-state save/load regression: two independent reconstructions of each
// frozen input. Source execution caches are deliberately not part of the input.
#include "physx_scene.h"
#include "pinned-memory-pool.h"
#include "native_scenario_geometry.h"
#include "native_graph_diagnostics.h"
#include "PxgDestructionRuntime.h"
#include "PxgSimulationCore.h"
#include "PxgSimulationController.h"
#include <extensions/PxCollectionExt.h>
#include <extensions/PxSerialization.h>
#include <extensions/PxDefaultStreams.h>
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cudamanager/PxCudaContextManager.h>
#include <chrono>
#include <algorithm>
#include <map>
#include <tuple>
#include <cmath>
#include <cstdlib>
#include <cstring>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <stdexcept>
#include <vector>
#include "profile-markers.h"
using namespace physx;
namespace {
bool requireCompleteShapes=true;
unsigned completedCases=0;
bool selectedCase(const std::string& name){const char* filter=std::getenv("PHYSX_SNAPSHOT_CASE");
    return !filter || (std::string(",")+filter+",").find(","+name+",")!=std::string::npos;
}
void require(bool condition,const char* message){if(!condition)throw std::runtime_error(message);}
void step(PxScene& scene){auto* stage=scene.getDestructionScene();scene.simulate(1.0f/60);
    if(std::getenv("PHYSX_SNAPSHOT_FETCH_DIAGNOSTIC")){scene.checkResults(true);const auto s=stage->getLastStatus();std::cerr<<"pre-fetch stage error="<<s.error<<" converged="<<s.converged<<" iterations="<<s.iterations<<" breaks="<<s.brokenBonds<<" corrections="<<s.correctionPasses<<std::endl;
        if(s.error){const auto v=stage->getDeviceView();PxDestructionCorrectionPreparationStatus c{};
            cuCtxPushCurrent(scene.getCudaContextManager()->getContext());cuEventSynchronize(v.readyEvent);
            cuMemcpyDtoH(&c,CUdeviceptr(v.correctionPreparation),sizeof(c));const auto h=static_cast<PxgDestructionRuntime*>(stage)->commandInputHistory();PxgDestructionCommandInputStatus hs{};
            if(h.status)cuMemcpyDtoH(&hs,CUdeviceptr(h.status),sizeof(hs));
            std::cerr<<"command history generation="<<h.generation<<" device="<<hs.generation<<" error="<<hs.error<<" count="<<hs.count<<std::endl;
            if(h.count){std::vector<PxgDestructionCommandInput> records(h.count);cuMemcpyDtoH(records.data(),CUdeviceptr(h.records),records.size()*sizeof(records[0]));unsigned bad=0;for(auto& r:records)if(r.kind==2){if(bad++<8)std::cerr<<"invalid command body="<<r.body<<" flags="<<r.flags<<std::endl;}std::cerr<<"bad command records="<<bad<<std::endl;}
            CUcontext previous;cuCtxPopCurrent(&previous);
            std::cerr<<"correction preparation error="<<c.error<<" loaded="<<c.loadedSources<<" count="<<c.count<<std::endl;}}
    PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"GPU step failed");}
struct Events:PxSimulationEventCallback {
    unsigned points=0;
    void onConstraintBreak(PxConstraintInfo*,PxU32)override{}
    void onWake(PxActor**,PxU32)override{}
    void onSleep(PxActor**,PxU32)override{}
    void onTrigger(PxTriggerPair*,PxU32)override{}
    void onAdvance(const PxRigidBody*const*,const PxTransform*,PxU32)override{}
    void onContact(const PxContactPairHeader&,const PxContactPair* pairs,PxU32 n)override{
        for(PxU32 i=0;i<n;++i)points+=pairs[i].contactCount;
    }
};
std::vector<float> health(PxScene& scene){
    const auto view=scene.getDestructionScene()->getDeviceView();std::vector<float> result(view.bondCount);
    require(cuCtxPushCurrent(scene.getCudaContextManager()->getContext())==CUDA_SUCCESS,"health context");
    require(cuEventSynchronize(view.readyEvent)==CUDA_SUCCESS,"health ready");
    if(!result.empty())require(cuMemcpyDtoH(result.data(),reinterpret_cast<CUdeviceptr>(view.bondHealth),result.size()*sizeof(float))==CUDA_SUCCESS,"health readback");
    CUcontext prior;require(cuCtxPopCurrent(&prior)==CUDA_SUCCESS,"health context pop");return result;
}
void compareDestruction(PxScene& a,PxScene& b){
    const auto x=a.getDestructionScene()->getDeviceView(),y=b.getDestructionScene()->getDeviceView();
    require(x.chunkCount==y.chunkCount && x.bondCount==y.bondCount,"destruction size mismatch");
    const auto ha=health(a),hb=health(b);
    if(ha!=hb){unsigned count=0,index=0;float delta=0;for(unsigned i=0;i<ha.size();++i)if(ha[i]!=hb[i]){++count;if(PxAbs(ha[i]-hb[i])>delta){delta=PxAbs(ha[i]-hb[i]);index=i;}}
        std::cerr<<std::setprecision(10)<<"health differences="<<count<<" max="<<delta<<" bond="<<index<<" values="<<ha[index]<<'/'<<hb[index]<<std::endl;}
    require(ha==hb,"bond health changed between equivalent states");
    require(cuCtxPushCurrent(a.getCudaContextManager()->getContext())==CUDA_SUCCESS,"CUDA context");
    auto read=[](void* dst,const void* src,size_t bytes){if(bytes)require(cuMemcpyDtoH(dst,reinterpret_cast<CUdeviceptr>(src),bytes)==CUDA_SUCCESS,"state readback");};
    std::vector<PxU32> bx(x.bondCount),by(y.bondCount),cx(x.chunkCount),cy(y.chunkCount);
    read(bx.data(),x.acceptedTopology.activeBonds,bx.size()*4);read(by.data(),y.acceptedTopology.activeBonds,by.size()*4);
    read(cx.data(),x.acceptedTopology.chunkCluster,cx.size()*4);read(cy.data(),y.acceptedTopology.chunkCluster,cy.size()*4);
    require(bx==by && cx==cy,"accepted topology changed between equivalent states");
    std::vector<PxDestructionCrushState> dx(x.chunkCount),dy(y.chunkCount);
    read(dx.data(),x.chunkCrush,dx.size()*sizeof(dx[0]));read(dy.data(),y.chunkCrush,dy.size()*sizeof(dy[0]));
    for(unsigned i=0;i<dx.size();++i)require(dx[i].damage==dy[i].damage && dx[i].crushed==dy[i].crushed,"material damage changed");
    CUcontext prior;require(cuCtxPopCurrent(&prior)==CUDA_SUCCESS,"CUDA context pop");
}
bool replayPreIslands=false,replayPreContacts=false,replayPreSupport=false,replayConnectivity=false;
struct World {
    void* memory=nullptr;bool ownsMemory=true;PxCollection* objects=nullptr;PxScene* scene=nullptr;
    double deserializeMs=0,sceneCreateMs=0,insertMs=0;
    void release(){if(scene){scene->release();scene=nullptr;}if(objects){PxCollectionExt::releaseObjects(*objects);objects->release();objects=nullptr;}if(ownsMemory)free(memory);memory=nullptr;}
    ~World(){release();}
    void load(PxPhysics& physics,PxSerializationRegistry& registry,PxScene& source,Events& events,const PxDefaultMemoryOutputStream& bytes,void* reusableMemory=nullptr){
        const auto a=std::chrono::steady_clock::now();
        if(reusableMemory){memory=reusableMemory;ownsMemory=false;}
        else require(posix_memalign(&memory,PX_SERIAL_FILE_ALIGN,bytes.getSize())==0,"aligned storage failed");
        std::memcpy(memory,bytes.getData(),bytes.getSize());objects=PxSerialization::createCollectionFromBinary(memory,registry);
        require(objects,"binary import failed");
        const auto b=std::chrono::steady_clock::now();deserializeMs=std::chrono::duration<double,std::milli>(b-a).count();
        PxSceneDesc d(physics.getTolerancesScale());d.gravity=source.getGravity();d.cpuDispatcher=source.getCpuDispatcher();
        d.cudaContextManager=source.getCudaContextManager();d.filterShader=source.getFilterShader();d.flags=source.getFlags();
        d.broadPhaseType=PxBroadPhaseType::eGPU;d.simulationEventCallback=&events;d.solverType=source.getSolverType();
        d.gpuMaxNumPartitions=8;d.gpuDynamicsConfig=source.getGpuDynamicsConfig();scene=physics.createScene(d);
        const auto c=std::chrono::steady_clock::now();sceneCreateMs=std::chrono::duration<double,std::milli>(c-b).count();
        require(scene && scene->addCollection(*objects),"fresh GPU collection insertion failed");
        insertMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-c).count();
        auto* gpu=static_cast<PxgGpuContext*>(static_cast<NpScene&>(*scene).getScScene().getDynamicsContext());
        gpu->enableCudaPreSolveIslands(replayPreIslands);gpu->enableCudaPreSolveContacts(replayPreContacts);
        gpu->enableCudaPreSolveSupport(replayPreSupport);gpu->enableDeviceConnectivityOwnership(replayConnectivity);
    }
};
struct MotionError {float position=0,linear=0,angular=0,orientation=0;};
MotionError compareObjects(const PxCollection& a,const PxCollection& b,float poseBound){
    MotionError error;
    for(PxU32 i=0;i<a.getNbObjects();++i){const auto& object=a.getObject(i);
        const auto id=a.getId(object);const auto* other=b.find(id);require(other,"restored object identity missing");
        if(const auto* x=object.is<PxRigidDynamic>()){
            const auto* y=other->is<PxRigidDynamic>();require(y,"restored body type changed");
            const auto xp=x->getGlobalPose(),yp=y->getGlobalPose();
            require(xp.isValid() && yp.isValid() && x->getLinearVelocity().isFinite() && y->getLinearVelocity().isFinite()
                && x->getAngularVelocity().isFinite() && y->getAngularVelocity().isFinite(),"nonfinite body state");
            error.position=PxMax(error.position,(xp.p-yp.p).magnitude());
            error.linear=PxMax(error.linear,(x->getLinearVelocity()-y->getLinearVelocity()).magnitude());
            error.angular=PxMax(error.angular,(x->getAngularVelocity()-y->getAngularVelocity()).magnitude());
            error.orientation=PxMax(error.orientation,PxAbs(1-PxAbs(xp.q.dot(yp.q))));
            require(x->getMass()==y->getMass() && x->getMassSpaceInertiaTensor()==y->getMassSpaceInertiaTensor()
                && x->getCMassLocalPose()==y->getCMassLocalPose() && x->getRigidBodyFlags()==y->getRigidBodyFlags(),"body mass/inertia/COM/role changed");
        }
        if(const auto* x=object.is<PxShape>()){
            const auto* y=other->is<PxShape>();require(y && x->getActor() && y->getActor(),"shape owner missing");
            const auto xp=x->getActor()->getGlobalPose()*x->getLocalPose(),yp=y->getActor()->getGlobalPose()*y->getLocalPose();
            error.position=PxMax(error.position,(xp.p-yp.p).magnitude());
            error.orientation=PxMax(error.orientation,PxAbs(1-PxAbs(xp.q.dot(yp.q))));
            const auto* xb=x->getActor()->is<PxRigidDynamic>();const auto* yb=y->getActor()->is<PxRigidDynamic>();
            if(xb && yb){error.linear=PxMax(error.linear,(xb->getLinearVelocity()-yb->getLinearVelocity()).magnitude());
                error.angular=PxMax(error.angular,(xb->getAngularVelocity()-yb->getAngularVelocity()).magnitude());
                require(xb->getMass()==yb->getMass() && xb->getRigidBodyFlags()==yb->getRigidBodyFlags(),"fragment mass/role changed");}
        }
    }
    if(!(error.position<poseBound && error.linear<1e-4f && error.angular<1e-4f && error.orientation<1e-5f))
        std::cerr<<"motion error position "<<error.position<<" linear "<<error.linear<<" angular "<<error.angular<<" orientation "<<error.orientation<<std::endl;
    require(error.position<poseBound && error.linear<1e-4f && error.angular<1e-4f && error.orientation<1e-5f,"physical state differs beyond existing motion bounds");
    return error;
}
void roundTrip(const char* name,unsigned prefix,const char* directory,blast_demo::PhysXScene& context,
    Events& sourceEvents,Events& restoredEvents,PxRigidDynamic* body,PxRigidDynamic* shot,
    const std::vector<PxShape*>& authoredShapes,unsigned breaks,bool destructive,bool onset){
    auto& physics=context.physics();auto& original=context.scene();
    if(std::strcmp(name,"destruction-damaged")==0){const auto h=health(original);require(h[0]>0 && h[0]<1,"damage fixture has no partial damage");}
    auto* registry=PxSerialization::createSerializationRegistry(physics);require(registry,"serialization registry unavailable");
    auto* collection=PxCollectionExt::createCollection(original);require(collection,"collection unavailable");
    collection->addId(*body,101);if(shot)collection->addId(*shot,102);PxSerialization::complete(*collection,*registry);
    unsigned serializedShapes=0;
    for(unsigned i=0;i<authoredShapes.size();++i)if(collection->contains(*authoredShapes[i])){++serializedShapes;collection->addId(*authoredShapes[i],200+i);}
    require(serializedShapes==authoredShapes.size(),"scene export omitted a destructible shape");
    for(PxU32 i=0;i<collection->getNbObjects();++i){auto& o=collection->getObject(i);if(!collection->getId(o))collection->addId(o,(PxU64(1)<<32)+i);}
    require(PxSerialization::isSerializable(*collection,*registry),"collection not serializable");
    PxDefaultMemoryOutputStream destruction,bytes;
    if(destructive && shot){shot->addForce(PxVec3(1,0,0),PxForceMode::eFORCE);PxDefaultMemoryOutputStream pending;
        require(!original.getDestructionScene()->exportState(pending,*collection),"snapshot dropped pending force");shot->clearForce(PxForceMode::eFORCE);}
    const auto exportBegin=std::chrono::steady_clock::now();
    if(destructive)require(original.getDestructionScene()->exportState(destruction,*collection),"destruction export failed");
    require(PxSerialization::serializeCollectionToBinary(bytes,*collection,*registry),"binary export failed");
    const double exportMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-exportBegin).count();
    for(const auto item:{std::make_pair(".pxbin",&bytes),std::make_pair(".destruction",&destruction)}){
        std::ofstream file(std::string(directory)+"/"+name+item.first,std::ios::binary);
        file.write(reinterpret_cast<const char*>(item.second->getData()),item.second->getSize());}
    {
        World a,b;Events eventsA;const auto restoreBegin=std::chrono::steady_clock::now();
        a.load(physics,*registry,original,eventsA,bytes);b.load(physics,*registry,original,restoredEvents,bytes);
        for(World* w:{&a,&b})if(destructive){
            auto* stage=w->scene->getDestructionScene();require(stage,"restored destruction unavailable");
            std::vector<PxU8> corrupt(destruction.getData(),destruction.getData()+destruction.getSize());corrupt.back()^=1;
            PxDefaultMemoryInputData bad(corrupt.data(),PxU32(corrupt.size()));
            require(!stage->importState(bad,*w->objects) && !stage->getDeviceView().chunkCount,"corrupt snapshot accepted or mutated target");
            PxDefaultMemoryInputData shortData(destruction.getData(),destruction.getSize()-1);
            require(!stage->importState(shortData,*w->objects),"truncated snapshot accepted");
            auto* absent=w->objects->find(200);w->objects->removeId(200);
            PxDefaultMemoryInputData missing(destruction.getData(),destruction.getSize());require(!stage->importState(missing,*w->objects),"missing shape binding accepted");w->objects->addId(*absent,200);
            PxDefaultMemoryInputData data(destruction.getData(),destruction.getSize());require(stage->importState(data,*w->objects),"destruction import failed");
            compareDestruction(original,*w->scene);
            PxDefaultMemoryOutputStream again;require(stage->exportState(again,*w->objects),"restored state cannot be exported");
            require(again.getSize()==destruction.getSize() && std::memcmp(again.getData(),destruction.getData(),again.getSize())==0,"physical destruction round trip not byte-exact");
            require(stage->getLastStatus().frame==original.getDestructionScene()->getLastStatus().frame,"restore advanced/lost tick");
            PxDefaultMemoryInputData duplicate(destruction.getData(),destruction.getSize());require(!stage->importState(duplicate,*w->objects),"import overwrote live state");
        }
        const double restoreValidationMs=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-restoreBegin).count();
        compareObjects(*collection,*a.objects,1e-4f);compareObjects(*collection,*b.objects,1e-4f);
        for(World* w:{&a,&b})for(PxU32 j=0;j<collection->getNbObjects();++j)if(const auto* x=collection->getObject(j).is<PxRigidDynamic>()){
            const auto* y=w->objects->find(collection->getId(*x))->is<PxRigidDynamic>();
            if(x->isSleeping()!=y->isSleeping() || PxAbs(x->getWakeCounter()-y->getWakeCounter())>=1e-6f)
                std::cerr<<name<<" body "<<collection->getId(*x)<<" sleeping "<<x->isSleeping()<<'/'<<y->isSleeping()<<" wake "<<x->getWakeCounter()<<'/'<<y->getWakeCounter()<<std::endl;
            require(x->isSleeping()==y->isSleeping() && PxAbs(x->getWakeCounter()-y->getWakeCounter())<1e-6f,"initial sleep/wake state changed");}
        const auto initialLinear=a.objects->find(101)->is<PxRigidDynamic>()->getLinearVelocity();

        // Two reconstructions now receive the same next input. No comparison
        // against the source scene's warm execution/allocator history is required.
        auto previous=destructive?health(*a.scene):std::vector<float>();unsigned continuationBreaks=0;
        std::ofstream report(std::string(directory)+"/"+name+".json");report<<std::setprecision(17);
        report<<"{\"scenario\":\""<<name<<"\",\"contract\":\"physical-state-v20\",\"comparison\":\"independent-restores\",\"prefix_steps\":"<<prefix
            <<",\"physx_bytes\":"<<bytes.getSize()<<",\"destruction_bytes\":"<<destruction.getSize()<<",\"export_ms\":"<<exportMs
            <<",\"two_restores_and_validation_ms\":"<<restoreValidationMs<<",\"authored_shapes\":"<<authoredShapes.size()
            <<",\"authored_shapes_in_collection\":"<<serializedShapes<<",\"broken_before_export\":"<<breaks<<",\"continuation\":[";
        for(unsigned i=0;i<10;++i){
            PxDefaultMemoryOutputStream beforePhysics,beforeDestruction;
            if(onset && !continuationBreaks){
                require(a.scene->getDestructionScene()->exportState(beforeDestruction,*a.objects),"pre-fracture export failed");
                require(PxSerialization::serializeCollectionToBinary(beforePhysics,*a.objects,*registry),"pre-fracture collection export failed");}
            eventsA.points=restoredEvents.points=0;
            if(std::strcmp(name,"destruction-stimulus")==0 && i==0)for(World* w:{&a,&b}){
                auto* target=w->objects->find(102)->is<PxRigidDynamic>();require(target,"stimulus projectile missing");
                target->setAngularVelocity(PxVec3(0,.25f,0));target->addForce(PxVec3(.1f,0,0),PxForceMode::eIMPULSE);}
            auto t=std::chrono::steady_clock::now();step(*a.scene);const double ams=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t).count();
            t=std::chrono::steady_clock::now();step(*b.scene);const double bms=std::chrono::duration<double,std::milli>(std::chrono::steady_clock::now()-t).count();
            auto error=compareObjects(*a.objects,*b.objects,1e-4f);
            if(std::strcmp(name,"flying")==0)for(World* w:{&a,&b}){
                const auto expected=initialLinear+original.getGravity()*(float(i+1)/60);
                require((w->objects->find(101)->is<PxRigidDynamic>()->getLinearVelocity()-expected).magnitude()<1e-4f,"restored free-fall acceleration incorrect");}

            PxDestructionStageStatus sa{},sb{};
            if(destructive){sa=a.scene->getDestructionScene()->getLastStatus();sb=b.scene->getDestructionScene()->getLastStatus();
                require(!sa.error && !sb.error && sa.converged && sb.converged,"restored stress failed convergence");
                require(sa.correctionPasses<=1 && sb.correctionPasses<=1 && sa.stressPasses==1+sa.correctionPasses
                    && sb.stressPasses==1+sb.correctionPasses,"restored correction/evaluation cap violated");
                require(sa.frame==sb.frame && sa.frame==original.getDestructionScene()->getLastStatus().frame+i+1
                    && sa.brokenBonds==sb.brokenBonds && sa.correctionPasses==sb.correctionPasses,"restored material/tick verdict differs");
                compareDestruction(*a.scene,*b.scene);
                if(onset && !continuationBreaks && sa.brokenBonds){
                    for(const auto item:{std::make_pair(".pxbin",&beforePhysics),std::make_pair(".destruction",&beforeDestruction)}){
                        std::ofstream saved(std::string(directory)+"/"+name+"-first-fracture"+item.first,std::ios::binary);
                        saved.write(reinterpret_cast<const char*>(item.second->getData()),item.second->getSize());}
                }
                continuationBreaks+=sa.brokenBonds;
                auto next=health(*a.scene);for(unsigned j=0;j<next.size();++j)require(std::isfinite(next[j]) && next[j]>=0 && next[j]<=previous[j],"bond damage was lost or healed");previous=next;
            }
            if(std::strcmp(name,"destruction-stimulus")==0 && i==0)for(World* w:{&a,&b}){
                auto* target=w->objects->find(102)->is<PxRigidDynamic>();
                require(PxAbs(target->getLinearVelocity().x-12.05f)<1e-5f && PxAbs(target->getAngularVelocity().y-.25f)<1e-5f,"post-restore command lost or doubled");}
            if(i)report<<',';
            report<<"{\"step\":"<<i<<",\"restore_a_complete_step_ms\":"<<ams<<",\"restore_b_complete_step_ms\":"<<bms
                <<",\"position_error_m\":"<<error.position<<",\"linear_velocity_error_m_s\":"<<error.linear<<",\"angular_velocity_error_rad_s\":"<<error.angular
                <<",\"orientation_dot_error\":"<<error.orientation<<",\"stress_iterations_a\":"<<sa.iterations
                <<",\"broken_bonds\":"<<sa.brokenBonds<<",\"correction_passes\":"<<sa.correctionPasses<<",\"stress_passes\":"<<sa.stressPasses
                <<",\"reported_contact_points_a\":"<<eventsA.points<<",\"reported_contact_points_b\":"<<restoredEvents.points<<'}';report.flush();
        }
        require(!onset || continuationBreaks>0,"onset continuation did not fracture");
        report<<"],\"continuation_broken_bonds\":"<<continuationBreaks<<",\"passed\":true}\n";
    }
    collection->release();registry->release();require(original.getDestructionScene()->clearStress(),"destruction cleanup failed");
    body->release();if(shot)shot->release();require(context.healthy(),"PhysX error during round-trip");
    ++completedCases;std::cout<<"completed "<<name<<std::endl;
}
#include "file-replay-observation.inl"
#include "file-replay.inl"
#include "warm-replay.inl"
void run(const char* name,unsigned prefix,const char* directory) {
    if(!selectedCase(name))return;
    blast_demo::SceneCapacity capacity;
    Events sourceEvents,restoredEvents;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&sourceEvents,false,false,false,false,PxSolverType::eTGS,false,true);
    auto& physics=context.physics();auto& original=context.scene();
    const bool flying=std::strcmp(name,"flying")==0;
    const bool sliding=std::strcmp(name,"sliding")==0;
    const bool fractured=std::strcmp(name,"destruction-fractured")==0;
    const bool onset=std::strcmp(name,"destruction-onset")==0;
    const bool cold=std::strcmp(name,"destruction-cold")==0;
    const bool stimulus=std::strcmp(name,"destruction-stimulus")==0;
    const bool damage=std::strcmp(name,"destruction-damaged")==0;
    const bool destructive=fractured || onset || cold || damage || stimulus || std::strcmp(name,"destruction-intact")==0;
    PxRigidDynamic* shot=nullptr;
    std::vector<PxShape*> authoredShapes;
    auto* body=PxCreateDynamic(physics,PxTransform(PxVec3(0,flying?10.0f:.5f,0)),PxBoxGeometry(PxVec3(.5f)),context.material(),1);
    require(body,"body allocation failed");
    body->setLinearDamping(0);body->setAngularDamping(0);
    if(sliding)body->setLinearVelocity(PxVec3(3,0,.7f));
    original.addActor(*body);
    if(destructive){
        body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        auto* upper=physics.createShape(PxBoxGeometry(PxVec3(.5f)),context.material(),true);
        require(upper,"upper shape failed");upper->setLocalPose(PxTransform(PxVec3(0,1,0)));
        require(body->attachShape(*upper),"upper attachment failed");upper->release();
        body->setMass(2);body->setCMassLocalPose(PxTransform(PxVec3(0,.5f,0)));
        body->setMassSpaceInertiaTensor(PxVec3(5.0f/6,1.0f/3,5.0f/6));
        step(original);
        PxShape* shapes[2];require(body->getShapes(shapes,2)==2,"compound shape count");
        authoredShapes.assign(shapes,shapes+2);
        auto* stage=original.getDestructionScene();require(stage,"destruction unavailable");
        PxDestructionStressChunk chunks[2]={{PxVec3(0),0,0,0,stage->getShapeContactIndex(*shapes[0]),1,0},
                                          {PxVec3(0,1,0),1,1.0f/6,0,stage->getShapeContactIndex(*shapes[1]),1,0}};
        PxDestructionChunkMassProperties mass[2]{};
        for(unsigned i=0;i<2;++i){mass[i].mass=1;mass[i].center[1]=i;mass[i].supported=i==0;
            for(unsigned k=0;k<3;++k)mass[i].inertia[k]=1.0/6;}
        PxDestructionStressBond bond{0,1,PxVec3(0,.5f,0),PxVec3(0,1,0),1,1,1};
        PxDestructionStressCluster cluster{body->getGPUIndex(),PxVec3(0,.5f,0)};
        PxDestructionMaterial material;material.compressionElasticLimit=1e9f;material.compressionFatalLimit=2e9f;
        if(fractured || onset || stimulus){material.compressionElasticLimit=100;material.compressionFatalLimit=200;}
        if(damage){material.compressionElasticLimit=5;material.compressionFatalLimit=1000;}
        PxDestructionStressDesc stress;stress.chunks=chunks;stress.chunkCount=2;stress.chunkMassProperties=mass;
        stress.bonds=&bond;stress.bondCount=1;stress.clusters=&cluster;stress.clusterCount=1;
        stress.materials=&material;stress.materialCount=1;stress.maxIterations=128;stress.tolerance=1e-5f;stress.internalCorrectionLimit=1;
        require(stage->configureStress(stress),"destruction configure failed");
        if(fractured || onset || stimulus){
            shot=PxCreateDynamic(physics,PxTransform(PxVec3(-2,1.5f,0)),PxSphereGeometry(.2f),context.material(),1);
            require(shot,"shot allocation failed");shot->setMass(2);shot->setMassSpaceInertiaTensor(PxVec3(.032f));
            shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(PxVec3(12,0,0));original.addActor(*shot);
        }
    }
    unsigned breaks=0;
    for(unsigned i=0;i<prefix;++i){sourceEvents.points=0;step(original);breaks+=original.getDestructionScene()->getLastStatus().brokenBonds;}
    require(!fractured || breaks,"fracture probe did not fracture");
    roundTrip(name,prefix,directory,context,sourceEvents,restoredEvents,body,shot,authoredShapes,breaks,destructive,onset);
}
void runGeometry(const char* kind,unsigned prefix,const char* directory,bool impact=false){
    if(!selectedCase(std::string(kind)+(impact?"-fragmented":prefix?"-warm":"-cold")))return;
    const blast_demo::NativeScenarioGeometry geometry(kind);
    Events sourceEvents,restoredEvents;blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context(blast_demo::PhysicsMode::Gpu,true,capacity,&sourceEvents,false,false,false,false,PxSolverType::eTGS,false,true);
    auto& physics=context.physics();auto& scene=context.scene();
    if(std::getenv("PHYSX_SNAPSHOT_ZERO_FRICTION")){context.material().setStaticFriction(0);context.material().setDynamicFriction(0);}
    auto* body=physics.createRigidDynamic(PxTransform(PxVec3(0,.5f,0)));require(body,"geometry body allocation");
    body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
    std::vector<PxShape*> shapes;std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionChunkMassProperties> mass;
    std::map<std::tuple<int,int,int>,unsigned> lookup;
    for(int y=0;y<geometry.ny;++y)for(int z=0;z<geometry.nz;++z)for(int x=0;x<geometry.nx;++x)if(geometry.present(x,y,z)){
        const PxVec3 position{float(x),float(y),float(z)};
        auto* shape=physics.createShape(PxBoxGeometry(PxVec3(.5f)),context.material(),true);require(shape,"geometry shape allocation");
        shape->setLocalPose(PxTransform(position));require(body->attachShape(*shape),"geometry shape attachment");shape->release();
        const bool supported=geometry.supported(x,y,z);lookup[{x,y,z}]=unsigned(chunks.size());
        shapes.push_back(shape);chunks.push_back({position,supported?0.0f:1.0f,supported?0.0f:1.0f/6,0,PX_INVALID_U32,1,0});
        PxDestructionChunkMassProperties m{};m.mass=1;m.supported=supported;
        for(unsigned k=0;k<3;++k){m.center[k]=position[k];m.inertia[k]=1.0/6;}mass.push_back(m);
    }
    require(PxRigidBodyExt::updateMassAndInertia(*body,1),"geometry mass properties");scene.addActor(*body);step(scene);
    auto* stage=scene.getDestructionScene();require(stage,"geometry destruction stage");
    for(unsigned i=0;i<shapes.size();++i)chunks[i].contactIndex=stage->getShapeContactIndex(*shapes[i]);
    std::vector<PxDestructionStressBond> bonds;
    for(const auto& item:lookup){int x,y,z;std::tie(x,y,z)=item.first;
        const std::tuple<int,int,int> neighbors[]={{x+1,y,z},{x,y+1,z},{x,y,z+1}};
        for(const auto& neighbor:neighbors){const auto found=lookup.find(neighbor);if(found==lookup.end())continue;
            const unsigned a=item.second,b=found->second;const auto delta=chunks[b].position-chunks[a].position;
            bonds.push_back({a,b,(chunks[a].position+chunks[b].position)*.5f,delta.getNormalized(),1,1,1,0});}}
    PxDestructionStressCluster cluster{body->getGPUIndex(),body->getCMassLocalPose().p};
    PxDestructionMaterial material;material.compressionElasticLimit=impact?100:1e9f;material.compressionFatalLimit=impact?200:2e9f;
    PxDestructionStressDesc d;d.chunks=chunks.data();d.chunkCount=unsigned(chunks.size());d.chunkMassProperties=mass.data();
    d.bonds=bonds.data();d.bondCount=unsigned(bonds.size());d.clusters=&cluster;d.clusterCount=1;
    d.materials=&material;d.materialCount=1;d.maxIterations=8192;d.tolerance=1e-5f;d.internalCorrectionLimit=1;
    require(stage->configureStress(d),"geometry stress configure");
    PxRigidDynamic* shot=nullptr;
    if(impact){shot=PxCreateDynamic(physics,PxTransform(PxVec3(-3,4.5f,3)),PxSphereGeometry(.3f),context.material(),1);
        require(shot,"building projectile");shot->setMass(100);shot->setMassSpaceInertiaTensor(PxVec3(3.6f));
        shot->setLinearDamping(0);shot->setAngularDamping(0);shot->setLinearVelocity(PxVec3(50,0,0));scene.addActor(*shot);}
    unsigned breaks=0;for(unsigned i=0;i<prefix;++i){step(scene);breaks+=stage->getLastStatus().brokenBonds;}
    require(!impact || breaks>0,"building impact did not fracture");
    const std::string name=std::string(kind)+(impact?"-fragmented":prefix?"-warm":"-cold");
    roundTrip(name.c_str(),prefix,directory,context,sourceEvents,restoredEvents,body,shot,shapes,breaks,true,false);
}

}
int main(int argc,char** argv){try{
    require(argc>=2,"usage: serialization-probe OUTPUT_DIRECTORY [--replay PREFIX --repetitions N] [--projectile-impulse]");
    SnapshotProfileSession profileSession(argv[1]);
    std::string replayPrefix;unsigned repetitions=10,warmupTicks=0,measureTicks=1;bool impulse=false,warmReplay=false;
    for(int i=2;i<argc;++i){const std::string option=argv[i];
        if(option=="--require-complete-shapes")requireCompleteShapes=true;
        else if(option=="--replay"){require(++i<argc,"missing replay prefix");replayPrefix=argv[i];}
        else if(option=="--repetitions"){require(++i<argc,"missing repetitions");repetitions=unsigned(std::stoul(argv[i]));}
        else if(option=="--warmup-ticks"){require(++i<argc,"missing warmup ticks");warmupTicks=unsigned(std::stoul(argv[i]));warmReplay=true;}
        else if(option=="--measure-ticks"){require(++i<argc,"missing measured ticks");measureTicks=unsigned(std::stoul(argv[i]));warmReplay=true;}
        else if(option=="--projectile-impulse")impulse=true;
        else require(false,"unknown snapshot argument");}
    require(!warmReplay || !replayPrefix.empty(),"warm replay requires --replay");
    if(!replayPrefix.empty()){
        if(warmReplay)replayWarmFiles(replayPrefix,argv[1],repetitions,impulse,warmupTicks,measureTicks);
        else replayFiles(replayPrefix,argv[1],repetitions,impulse);
        return 0;}

    run("flying",5,argv[1]);run("sliding",5,argv[1]);run("resting",180,argv[1]);run("destruction-intact",5,argv[1]);run("destruction-fractured",20,argv[1]);run("destruction-onset",1,argv[1]);run("destruction-cold",0,argv[1]);run("destruction-damaged",5,argv[1]);run("destruction-stimulus",1,argv[1]);
    for(const char* geometry:{"building","chain32","chain256","cantilever64","dense12","tower64","panel32","bridge64","ladder128"}){
        runGeometry(geometry,0,argv[1]);runGeometry(geometry,5,argv[1]);}
    runGeometry("building",16,argv[1],true);
    require(completedCases>0,"unknown snapshot case filter");
    return 0;
}catch(const std::exception& e){std::cerr<<e.what()<<std::endl;return 1;}}
