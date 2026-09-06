// Native GPU fracture -> initialized cluster slots -> persistent shape bindings.
// Authored scene setup and diagnostic readbacks below do not orchestrate fracture.
#include "../physx_scene.h"
#include "NpScene.h"
#include "NpShapeManager.h"
#include "PxgSimulationController.h"
#include "PxgSimulationCore.h"
#include "native_contact_graph_check.h"
#include "PxgNphaseImplementationContext.h"
#include "PxgNarrowphaseCore.h"
#include "PxsContactManager.h"
#include <PxDestructionScene.h>
#include <cuda.h>
#include <cstdio>
#include <algorithm>
#include <cstring>
#include <stdexcept>
#include <string>
#include <vector>
#include <map>
#include <set>
using namespace physx;
namespace {
void require(bool value,const char* message){if(!value)throw std::runtime_error(message);}
void check(CUresult result){if(result!=CUDA_SUCCESS){const char* name=nullptr;cuGetErrorName(result,&name);std::fprintf(stderr,"CUDA observation failed: %d %s\n",int(result),name?name:"");throw std::runtime_error("CUDA observation failed");}}
void step(PxScene& scene){scene.simulate(1.0f/60);PxU32 error=0;require(scene.fetchResults(true,&error)&&!error,"ordinary step failed");}
struct Fixture {
    blast_demo::SceneCapacity capacity;
    blast_demo::PhysXScene context;
    PxScene& scene;
    PxCudaContextManager& cuda;
    PxgSimulationCore& core;
    PxRigidDynamic* parent;
    PxRigidDynamic* foreign;
    std::vector<PxRigidDynamic*> quiet;
    std::vector<PxShape*> shapes;
    PxShape* foreignShape;
    std::vector<PxDestructionStressChunk> chunks;
    std::vector<PxDestructionChunkMassProperties> mass;
    std::vector<PxDestructionStressBond> bonds;
    std::vector<PxDestructionStressCluster> clusters;
    std::vector<PxgShapeSim> originalShapes;
    PxDestructionMaterial material;
    PxDestructionStressDesc desc;
    PxDestructionScene* stage;
    unsigned mainCount;
    Fixture(unsigned count,unsigned untouched,bool sleeping):
        context(blast_demo::PhysicsMode::Gpu,true,capacity,nullptr,true,false,sleeping,sleeping),
        scene(context.scene()),cuda(*context.cudaContextManager()),
        core(*static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController())->getSimulationCore()),mainCount(count) {
        const PxTransform origin(PxVec3(10,20,-5),PxQuat(.43f,PxVec3(0,0,1)));
        parent=context.physics().createRigidDynamic(origin);parent->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        const auto addShape=[&](PxRigidDynamic& actor,PxVec3 point){
            auto* shape=context.physics().createShape(PxBoxGeometry(.25f,.25f,.25f),context.material(),true);
            require(shape,"shape creation failed");shape->setLocalPose(PxTransform(point));require(actor.attachShape(*shape),"chunk shape attachment failed");return shape;
        };
        for(unsigned i=0;i<count;++i)shapes.push_back(addShape(*parent,PxVec3(0,2*float(i),0)));
        scene.addActor(*parent);
        for(unsigned i=0;i<untouched;++i) {
            auto* actor=context.physics().createRigidDynamic(PxTransform(PxVec3(100+3*float(i),20,0)));
            actor->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);shapes.push_back(addShape(*actor,PxVec3(0)));
            scene.addActor(*actor);quiet.push_back(actor);
        }
        foreign=context.physics().createRigidDynamic(PxTransform(PxVec3(-100,20,0)));foreign->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);
        foreignShape=addShape(*foreign,PxVec3(0));scene.addActor(*foreign);step(scene);
        clusters.push_back({parent->getGPUIndex(),PxVec3(0)});
        for(auto* actor:quiet)clusters.push_back({actor->getGPUIndex(),PxVec3(0)});
        const unsigned total=count+untouched;chunks.resize(total);mass.resize(total);originalShapes.resize(total);
        for(unsigned i=0;i<total;++i) {
            const bool dynamic=i>0 && i<count;const auto position=i<count?PxVec3(0,2*float(i),0):PxVec3(0);
            chunks[i]={position,dynamic?1.0f:0.0f,dynamic?1.0f:0.0f,i<count?0:i-count+1,scene.getDirectGPUAPI().getShapeContactIndex(*shapes[i]),.125f,0};
            require(chunks[i].contactIndex!=PX_INVALID_U32,"persistent shape identity unavailable without host motion access");
            mass[i]={};mass[i].mass=dynamic?1:0;mass[i].supported=!dynamic;
            for(unsigned k=0;k<3;++k){mass[i].center[k]=position[k];mass[i].inertia[k]=dynamic?1:0;}
            if(dynamic)bonds.push_back({0,i,position*.5f,PxVec3(0,1,0),1,1,1});
        }
        desc.chunks=chunks.data();desc.chunkCount=unsigned(chunks.size());desc.chunkMassProperties=mass.data();
        desc.bonds=bonds.data();desc.bondCount=unsigned(bonds.size());desc.clusters=clusters.data();desc.clusterCount=unsigned(clusters.size());
        desc.materials=&material;desc.materialCount=1;desc.maxIterations=128;desc.tolerance=1e-5f;
        stage=scene.getDestructionScene();require(stage,"native destruction scene missing");
        snapshotShapes();
    }
    ~Fixture(){stage->clearStress();parent->release();foreign->release();foreignShape->release();for(auto* actor:quiet)actor->release();for(auto* shape:shapes)shape->release();}
    void configure(){require(stage->configureStress(desc),"native graph configuration failed");}
    void snapshotShapes(){PxScopedCudaLock lock(cuda);for(unsigned i=0;i<shapes.size();++i)check(cuMemcpyDtoH(&originalShapes[i],CUdeviceptr(core.mPxgShapeSimManager.getShapeSimsDeviceTypedPtr()+chunks[i].contactIndex),sizeof(PxgShapeSim)));}
    void assertUncommitted(){
        require(parent->getNbShapes()==mainCount,"binding preparation changed CPU membership");
        require(scene.getNbActors(PxActorTypeFlag::eRIGID_DYNAMIC)==quiet.size()+2,"binding preparation published private actors");
        PxScopedCudaLock lock(cuda);
        for(unsigned i=0;i<shapes.size();++i) {
            PxgShapeSim actual;check(cuMemcpyDtoH(&actual,CUdeviceptr(core.mPxgShapeSimManager.getShapeSimsDeviceTypedPtr()+chunks[i].contactIndex),sizeof(actual)));
            require(!std::memcmp(&actual,&originalShapes[i],sizeof(actual)),"binding preparation modified persistent GPU geometry/ownership");
            require(shapes[i]->getActor()==(i<mainCount?parent:quiet[i-mainCount]),"binding preparation changed query owner");
        }
        std::vector<float> health(bonds.size());if(!health.empty())check(cuMemcpyDtoH(health.data(),CUdeviceptr(stage->getDeviceView().bondHealth),health.size()*sizeof(float)));
        for(float value:health)require(value==1,"uncommitted collision plan changed accepted material damage");
    }
    PxDestructionCollisionPreparationStatus readStatus(){
        const auto view=stage->getDeviceView();require(view.collisionPreparation && view.trialCollisionBindings,"collision device view missing");
        PxDestructionCollisionPreparationStatus status;PxScopedCudaLock lock(cuda);check(cuEventSynchronize(view.readyEvent));check(cuMemcpyDtoH(&status,CUdeviceptr(view.collisionPreparation),sizeof(status)));return status;
    }
    void fracture(PxU32 expectedError=8){scene.simulate(1.0f/60);PxU32 error=0;require(!scene.fetchResults(true,&error)&&error&&stage->getLastStatus().error==expectedError,"native correction/preparation error mismatch");}
    std::vector<PxDestructionCollisionBinding> bindings(unsigned n){
        auto view=stage->getDeviceView();std::vector<PxDestructionCollisionBinding> result(n);PxScopedCudaLock lock(cuda);
        check(cuEventSynchronize(view.readyEvent));if(n)check(cuMemcpyDtoH(result.data(),CUdeviceptr(view.trialCollisionBindings),n*sizeof(result[0])));return result;
    }
};
void deviceContactInputs(bool enabled) {
    Fixture f(1,0,false);f.scene.setGravity(PxVec3(0));f.desc.internalCorrectionLimit=enabled?1:0;f.configure();
    auto& sc=static_cast<NpScene&>(f.scene).getScScene();
    auto& controller=*static_cast<PxgSimulationController*>(sc.getSimulationController());
    auto& np=*static_cast<PxgNphaseImplementationContext*>(sc.getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
    const PxVec3 vertices[]={{-.5f,-.5f,-.5f},{.5f,-.5f,-.5f},{-.5f,.5f,-.5f},{.5f,.5f,-.5f},
        {-.5f,-.5f,.5f},{.5f,-.5f,.5f},{-.5f,.5f,.5f},{.5f,.5f,.5f}};
    PxConvexMeshDesc hull;hull.points.count=8;hull.points.stride=sizeof(PxVec3);hull.points.data=vertices;hull.flags=PxConvexFlag::eCOMPUTE_CONVEX;
    auto params=f.context.cookingParams();params.buildGPUData=true;
    auto* mesh=PxCreateConvexMesh(params,hull,f.context.physics().getPhysicsInsertionCallback());
    require(mesh && mesh->isGpuCompatible(),"GPU convex fixture cooking failed");
    PxShape* shared[]={f.context.physics().createShape(PxBoxGeometry(.5f,.5f,.5f),f.context.material(),false),
        f.context.physics().createShape(PxSphereGeometry(.5f),f.context.material(),false),
        f.context.physics().createShape(PxCapsuleGeometry(.5f,.25f),f.context.material(),false),
        f.context.physics().createShape(PxConvexMeshGeometry(mesh),f.context.material(),false)};
    for(auto* shape:shared)require(shape,"shared collision geometry creation failed");mesh->release();
    auto* plane=PxCreatePlane(f.context.physics(),PxPlane(0,1,0,-39.6f),f.context.material());
    require(plane,"contact-input plane fixture failed");f.scene.addActor(*plane);
    std::vector<PxRigidDynamic*> actors;
    auto add=[&](unsigned slot){
        auto* body=f.context.physics().createRigidDynamic(PxTransform(PxVec3(200+float(slot/2)*3,40,float(slot%2)*.9f)));
        body->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,(slot%2)==0);
        require(body->attachShape(*shared[(slot/2)%4]),"shared collision instance attachment failed");f.scene.addActor(*body);return body;
    };
    // Hundreds of instances share four geometry registrations, while each has a
    // separate persistent transform ID. This also grows the GPU shape storage.
    for(unsigned i=0;i<514;++i)actors.push_back(add(i));
    PxU32 inspected=0,deviceOnly=0,stableIdentities=0,newIdentities=0;
    using PairKey=std::pair<PxU32,PxU32>;
    std::map<PairKey,PxU64> previous;
    std::set<PxU64> observedGenerations;

    auto inspect=[&](bool refreshed=false){
        if(static_cast<PxgDestructionRuntime*>(f.stage)->correctionEnabled())nativeGraphTest::verify(f.scene,f.cuda);
        else require(!static_cast<PxgDestructionRuntime*>(f.stage)->getContactGraphView().generation,"disabled destruction exposes a stale contact graph");
        PxScopedCudaLock lock(f.cuda);
        // Diagnostic observations wait for both producers; do not rely on
        // legacy-default-stream ordering with PhysX nonblocking streams.
        check(cuStreamSynchronize(np.mStream));
        check(cuStreamSynchronize(np.mSolverStream));
        std::map<PairKey,PxU64> current;
        std::set<PxU64> currentGenerations;
        PxU32 mergedOffset=0;
        auto& merged=np.getExistingGpuContactManagers(GPU_BUCKET_ID::eConvex);
        for(PxU32 b=GPU_BUCKET_ID::eConvex;b<=GPU_BUCKET_ID::eConvexCoreTrimesh;++b) {
            auto& host=np.getExistingContactManagers(GPU_BUCKET_ID::Enum(b));
            auto& gpu=np.getExistingGpuContactManagers(GPU_BUCKET_ID::Enum(b));
            const auto count=host.mCpuContactManagerMapping.size();if(!count)continue;
            std::vector<PxgContactManagerInput> inputs(count);
            check(cuMemcpyDtoH(inputs.data(),gpu.mContactManagerInputData.getDevicePtr(),count*sizeof(inputs[0])));
            std::vector<PxgContactGraphIdentity> identities(count),mergedIdentities(count);
            require(host.mContactGraphIdentities.size()==count,"CPU contact identity count mismatch");
            check(cuMemcpyDtoH(identities.data(),gpu.mContactGraphIdentities.getDevicePtr(),count*sizeof(identities[0])));
            check(cuMemcpyDtoH(mergedIdentities.data(),merged.mContactGraphIdentities.getDevicePtr()+mergedOffset*sizeof(identities[0]),count*sizeof(identities[0])));
            require(!std::memcmp(identities.data(),mergedIdentities.data(),count*sizeof(identities[0])),"flattened GPU contact identities misaligned with buckets");
            mergedOffset+=count;
            for(PxU32 i=0;i<count;++i) {
                const auto& work=host.mCpuContactManagerMapping[i]->getWorkUnit();const auto input=inputs[i];
                const auto& identity=identities[i];
                require(identity.generation && identity.edgeIndex!=PX_INVALID_U32 && identity.edgeIndex==work.mEdgeIndex,"GPU contact identity has stale or missing island edge");
                require(!std::memcmp(&identity,&host.mContactGraphIdentities[i],sizeof(identity)),"CPU/GPU pair identity compaction diverged");
                require(currentGenerations.insert(identity.generation).second,"live GPU contact generations are not unique");
                const PairKey key(work.mTransformCache0,work.mTransformCache1);
                require(current.emplace(key,identity.generation).second,"duplicate persistent contact pair");
                const auto old=previous.find(key);
                if(old!=previous.end() && !refreshed) {
                    require(old->second==identity.generation,"surviving contact identity changed during compaction/growth");
                    ++stableIdentities;
                } else {
                    if(old!=previous.end())require(old->second!=identity.generation,"refilter retained a retired contact lifetime");
                    require(observedGenerations.insert(identity.generation).second,"removed GPU contact generation was recycled");
                    ++newIdentities;
                }
                require(input.transformCacheRef0==work.mTransformCache0 && input.transformCacheRef1==work.mTransformCache1,"GPU narrowphase resolved the wrong persistent pair IDs");
                const auto* a=np.mShapesMap->find(size_t(work.getShapeCore0()));
                const auto* b=np.mShapesMap->find(size_t(work.getShapeCore1()));
                require(a && b && input.shapeRef0==a->second.idx && input.shapeRef1==b->second.idx,"GPU narrowphase geometry differs from reference registration");
                ++inspected;
                if(host.mGpuInputContactManagers[i].shapeRef0==PX_INVALID_U32 && host.mGpuInputContactManagers[i].shapeRef1==PX_INVALID_U32)++deviceOnly;
            }
        }
        previous=std::move(current);
    };
    step(f.scene);inspect();
    const auto generated=controller.getDestructionContactInputCount();
    require(inspected>=257,"shared-shape fixture did not create its required contact pairs");
    require(enabled?(generated>=257 && deviceOnly>=257):(!generated && !deviceOnly),"native descriptor construction did not select the intended CPU/GPU path");
    // Remove a sparse subset, then create replacements after deferred IDs have
    // become reusable. Surviving GPU descriptors are compacted without a CPU
    // geometry-ref mirror; replacements must resolve current registrations.
    for(unsigned i=1;i<actors.size();i+=4){actors[i]->release();actors[i]=nullptr;}
    step(f.scene);inspect();
    for(unsigned i=1;i<actors.size();i+=4)actors[i]=add(i);
    step(f.scene);inspect();
    if(enabled)require(controller.getDestructionContactInputCount()>generated,"reinserted pairs missed GPU descriptor construction");
    // Refiltering deliberately destroys/recreates these contact lifetimes,
    // even when shape and island-edge indices happen to remain unchanged.
    const auto beforeRefresh=newIdentities;
    for(auto* body:actors)f.scene.resetFiltering(*body);
    step(f.scene);inspect(true);
    require(newIdentities>beforeRefresh,"refilter did not exercise contact lifetime replacement");
    const auto beforeDisable=controller.getDestructionContactInputCount();
    require(f.stage->clearStress(),"device contact path teardown failed");
    // Switching back to ordinary PhysX preserves existing device descriptors
    // and constructs newly created ones through the original CPU path.
    actors[1]->release();actors[1]=nullptr;step(f.scene);inspect();actors[1]=add(1);step(f.scene);inspect();
    require(controller.getDestructionContactInputCount()==beforeDisable,"disabled destruction still dispatched native contact construction");
    require(stableIdentities>=257 && newIdentities>257,"contact lifetime fixture missed persistence or replacement coverage");
    std::printf("GPU pair identities: %u surviving observations, %u new lifetimes; bucket merge and CPU/GPU compaction agree\n",stableIdentities,newIdentities);
    for(auto* body:actors)body->release();plane->release();for(auto* shape:shared)shape->release();
    require(f.context.healthy(),"GPU contact-input fixture failed");
    std::printf("persistent GPU contact inputs enabled=%u inspected=%u generated=%llu: shared geometry, capacity growth, removal/reuse and disable transition passed\n",unsigned(enabled),inspected,(unsigned long long)beforeDisable);
}

void contactComponentPartitions(bool gpuRepair) {
    Fixture f(1,0,false);f.scene.setGravity(PxVec3(0));f.desc.internalCorrectionLimit=1;f.desc.gpuIslandRepair=gpuRepair;f.configure();
    std::vector<PxRigidDynamic*> bodies;
    auto* floor=PxCreatePlane(f.context.physics(),PxPlane(0,1,0,-59.6f),f.context.material());
    require(floor,"component floor creation failed");f.scene.addActor(*floor);
    auto* beam=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(235,61,0)),PxBoxGeometry(40,.5f,1),f.context.material(),1);
    require(beam,"component kinematic creation failed");beam->setRigidBodyFlag(PxRigidBodyFlag::eKINEMATIC,true);f.scene.addActor(*beam);
    for(unsigned group=0;group<8;++group)for(unsigned i=0;i<4;++i) {
        auto* body=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(200+10*float(group)+.8f*i,60,0)),PxBoxGeometry(.5f,.5f,.5f),f.context.material(),1);
        require(body,"component dynamic creation failed");
        // Infinite translational mass is not itself a kinematic flag.
        if(i==1)body->setMass(0);
        f.scene.addActor(*body);bodies.push_back(body);
    }
    PxU64 generation=0;
    for(unsigned frame=0;frame<12;++frame) {
        if(frame==4){bodies[2]->release();bodies[2]=nullptr;}
        step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);
        const auto view=static_cast<PxgDestructionRuntime*>(f.stage)->getContactGraphView();
        require(view.generation>generation,"native graph did not refresh its generation");generation=view.generation;
        PxScopedCudaLock lock(f.cuda);check(cuEventSynchronize(view.readyEvent));
        std::vector<PxU32> labels(view.nodeCapacity);check(cuMemcpyDtoH(labels.data(),CUdeviceptr(view.speculativeLabels),labels.size()*sizeof(PxU32)));
        std::set<PxU32> groups;
        for(unsigned group=0;group<8;++group)groups.insert(labels[bodies[4*group]->getGPUIndex()]);
        require(groups.size()==8,"shared ground or kinematic beam joined independent dynamic groups");
    }
    require(f.stage->clearStress(),"component stage teardown failed");
    for(auto* body:bodies)if(body)body->release();beam->release();floor->release();
    require(f.context.healthy(),"component fixture GPU health failed");
    std::puts("native GPU contact components match CPU islands: 8 dynamic groups, shared static/kinematic boundaries, infinite-mass dynamics and removal");
}

void gpuIslandCycleAndFallback() {
    Fixture f(1,0,false);f.scene.setGravity(PxVec3(0));f.desc.internalCorrectionLimit=1;f.desc.gpuIslandRepair=true;f.configure();
    std::vector<PxRigidDynamic*> bodies(4);
    const PxVec3 points[]={PxVec3(300,80,0),PxVec3(301,80,0),PxVec3(301,80,1),PxVec3(300,80,1)};
    const auto add=[&](unsigned i){
        bodies[i]=PxCreateDynamic(f.context.physics(),PxTransform(points[i]),PxSphereGeometry(.6f),f.context.material(),1);
        require(bodies[i],"cycle body creation failed");bodies[i]->setMass(0);bodies[i]->setMassSpaceInertiaTensor(PxVec3(0));f.scene.addActor(*bodies[i]);
    };
    for(unsigned i=0;i<4;++i)add(i);
    auto& islands=*static_cast<NpScene&>(f.scene).getScScene().getSimpleIslandManager();
    const auto count=[&](){return islands.getAccurateIslandSim().getGpuRouteCount()+islands.getSpeculativeIslandSim().getGpuRouteCount()
        +islands.getAccurateIslandSim().getGpuSplitCount()+islands.getSpeculativeIslandSim().getGpuSplitCount();};
    const auto verify=[&](){step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);};
    verify();bodies[3]->release();bodies[3]=nullptr;verify();
    require(islands.getAccurateIslandSim().getGpuRouteCount()+islands.getSpeculativeIslandSim().getGpuRouteCount()>0,"cycle removal never used CUDA connectedness");
    bodies[1]->release();bodies[1]=nullptr;verify();
    require(islands.getAccurateIslandSim().getGpuSplitCount()+islands.getSpeculativeIslandSim().getGpuSplitCount()>0,"cycle disconnection never used CUDA membership");
    // Reinsert reclaimed handles and then switch to CPU repair. Routing hints
    // invalidated by the GPU split must still support ordinary CPU traversal.
    add(1);verify();f.desc.gpuIslandRepair=false;f.configure();const auto before=count();
    // An invalid borrowed membership snapshot must fall back before mutation,
    // and invalidate all subsequent GPU answers for this pass.
    const PxU32 domain=islands.getAccurateIslandSim().getNbNodes();
    std::vector<PxU32> invalidLabels(domain);std::vector<PxU32> invalidMembers(size_t(domain)*2,PX_INVALID_U32);
    for(PxU32 i=0;i<domain;++i)invalidLabels[i]=i;
    islands.getAccurateIslandSim().setGpuContactComponents(invalidLabels.data(),invalidMembers.data(),domain);
    islands.getSpeculativeIslandSim().setGpuContactComponents(invalidLabels.data(),invalidMembers.data(),domain);
    bodies[1]->release();bodies[1]=nullptr;verify();require(count()==before,"invalid GPU observation changed island connectivity");
    require(islands.getAccurateIslandSim().getGpuRepairFallbackCount()+islands.getSpeculativeIslandSim().getGpuRepairFallbackCount()>0,
        "invalid GPU membership failed to exercise CPU fallback");
    add(1);verify();const auto fallbacks=islands.getAccurateIslandSim().getGpuRepairFallbackCount()+islands.getSpeculativeIslandSim().getGpuRepairFallbackCount();
    for(PxU32 i=0;i<domain;++i){invalidMembers[i]=i;invalidMembers[size_t(domain)+i]=i;}
    islands.getAccurateIslandSim().setGpuContactComponents(invalidLabels.data(),invalidMembers.data(),domain);
    islands.getSpeculativeIslandSim().setGpuContactComponents(invalidLabels.data(),invalidMembers.data(),domain);
    bodies[1]->release();bodies[1]=nullptr;verify();
    require(count()==before && islands.getAccurateIslandSim().getGpuRepairFallbackCount()+islands.getSpeculativeIslandSim().getGpuRepairFallbackCount()>fallbacks,
        "cyclic GPU membership was not rejected before mutation");
    add(1);verify();f.desc.gpuIslandRepair=true;f.configure();bodies[1]->release();bodies[1]=nullptr;verify();
    require(count()>before,"GPU island repair failed after handle reuse and CPU fallback");
    require(f.stage->clearStress(),"cycle cleanup failed");for(auto* body:bodies)if(body)body->release();
    require(f.context.healthy(),"cycle GPU health failed");std::puts("GPU island repair: cycle edge removal, split, handle reuse, CPU fallback and resume passed");
}

void gpuComponentBoundaryAudit() {
    Fixture f(1,0,false);f.scene.setGravity(PxVec3(0));f.desc.internalCorrectionLimit=1;f.desc.gpuIslandRepair=true;f.configure();
    std::vector<PxRigidDynamic*> bodies;
    for(unsigned i=0;i<4;++i) {
        auto* body=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(400+float(i/2)*10+float(i%2),80,0)),PxSphereGeometry(.6f),f.context.material(),1);
        require(body,"audit body creation failed");body->setMass(0);body->setMassSpaceInertiaTensor(PxVec3(0));f.scene.addActor(*body);bodies.push_back(body);
    }
    step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);
    auto& islands=*static_cast<NpScene&>(f.scene).getScScene().getSimpleIslandManager();
    auto& sim=islands.getAccurateIslandSim();sim.setGpuComponentAudit(true);
    islands.getSpeculativeIslandSim().setGpuComponentAudit(true);
    const PxU32 *a=nullptr,*s=nullptr,*am=nullptr,*sm=nullptr;PxU32 n=0;
    require(static_cast<PxgDestructionRuntime*>(f.stage)->observeContactComponents(a,s,am,sm,n,true,true),"audit observation failed");
    sim.setGpuContactComponents(a,am,n);require(sim.auditGpuContactComponents(),"independent audit rejected valid graph");
    // Wrong equal labels would bypass the ordinary split-only membership check.
    std::vector<PxU32> labels(a,a+n),members(am,am+size_t(n)*2);
    const PxU32 node=bodies[2]->getGPUIndex();labels[node]=labels[bodies[0]->getGPUIndex()];
    const std::vector<IG::IslandId> oldIslands(sim.getIslandIds(),sim.getIslandIds()+sim.getNbNodes());
    sim.setGpuContactComponents(labels.data(),members.data(),n);
    require(!sim.auditGpuContactComponents(),"audit accepted falsely connected labels");
    labels.assign(a,a+n);members[size_t(n)+node]=node;
    sim.setGpuContactComponents(labels.data(),members.data(),n);
    require(!sim.auditGpuContactComponents(),"audit accepted cyclic membership");
    require(sim.getGpuComponentAuditFailures()==2 && std::equal(oldIslands.begin(),oldIslands.end(),sim.getIslandIds()),
        "audit modified registry or lost diagnostic failures");
    // The actual third-pass hook must audit fresh snapshots after removals.
    const auto audits=sim.getGpuComponentAudits();bodies[0]->release();bodies[0]=nullptr;
    step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);
    require(sim.getGpuComponentAudits()>audits && sim.getGpuComponentAuditFailures()==2
        && !islands.getSpeculativeIslandSim().getGpuComponentAuditFailures(),"third-pass boundary audit failed after edge removal");
    require(f.stage->clearStress(),"audit cleanup failed");for(auto* body:bodies)if(body)body->release();
    require(f.context.healthy(),"audit fixture GPU health failed");
    std::puts("native boundary audit: independent edge flood fill, false equal labels, cyclic membership, pre-mutation rejection and removal passed");
}

void gpuGraphReuseAndQuietObservation() {
    Fixture f(1,0,false);f.scene.setGravity(PxVec3(0));f.desc.internalCorrectionLimit=1;f.desc.gpuIslandRepair=true;f.configure();
    auto* runtime=static_cast<PxgDestructionRuntime*>(f.stage);
    auto& sc=static_cast<NpScene&>(f.scene).getScScene();
    auto& np=*static_cast<PxgNphaseImplementationContext*>(sc.getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
    const auto before=runtime->getContactGraphObservationStats();
    const auto builds=np.getDestructionGraphBuildCount(),reuses=np.getDestructionGraphReuseCount();
    PxU64 generation=0;
    for(unsigned i=0;i<12;++i) {
        step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);
        const auto view=runtime->getContactGraphView();require(view.generation==generation+1,"quiet graph crossed pass boundaries or rebuilt twice");generation=view.generation;
    }
    const auto after=runtime->getContactGraphObservationStats();
    require(after.observations==before.observations && after.sortedGraphs==before.sortedGraphs && after.deviceToHostBytes==before.deviceToHostBytes,
        "quiet island registry still sorts or reads back GPU components");
    require(np.getDestructionGraphBuildCount()==builds+12 && np.getDestructionGraphReuseCount()==reuses+12,"quiet graph did not reuse its single NP-pass build");
    const PxU32 *accurate=nullptr,*speculative=nullptr;const PxU32 *am=nullptr,*sm=nullptr;PxU32 count=0;
    const auto observeOne=[&](bool aNeeded,bool sNeeded){
        PxScopedCudaLock lock(f.cuda);require(runtime->observeContactComponents(accurate,speculative,am,sm,count,aNeeded,sNeeded),"selective graph observation failed");
        require(bool(accurate)==aNeeded && bool(am)==aNeeded && bool(speculative)==sNeeded && bool(sm)==sNeeded,"observation returned an unrequested graph");
    };
    observeOne(true,false);const auto one=runtime->getContactGraphObservationStats();const PxU32 domain=count;
    require(one.sortedGraphs==after.sortedGraphs+1 && one.deviceToHostBytes==after.deviceToHostBytes+8+12ull*domain,"accurate-only observation sorted or transferred extra data");
    observeOne(false,true);const auto two=runtime->getContactGraphObservationStats();
    require(count==domain && two.sortedGraphs==one.sortedGraphs+1 && two.deviceToHostBytes==one.deviceToHostBytes+8+12ull*domain,"speculative-only observation sorted or transferred extra data");
    observeOne(false,false);const auto none=runtime->getContactGraphObservationStats();
    require(count==0 && none.observations==two.observations && none.deviceToHostBytes==two.deviceToHostBytes,"empty observation performed device work");
    auto* a=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(350,80,0)),PxSphereGeometry(.6f),f.context.material(),1);
    auto* b=PxCreateDynamic(f.context.physics(),PxTransform(PxVec3(351,80,0)),PxSphereGeometry(.6f),f.context.material(),1);
    require(a && b,"reuse fixture body creation failed");for(auto* body:{a,b}){body->setMass(0);body->setMassSpaceInertiaTensor(PxVec3(0));f.scene.addActor(*body);}
    step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);generation=runtime->getContactGraphView().generation;
    require(np.canReuseDestructionContactGraph(generation,static_cast<NpScene&>(f.scene).getScScene().getSimpleIslandManager()->getRetainedContactRevision()),"unchanged graph receipt failed");
    a->release();require(!np.canReuseDestructionContactGraph(generation,static_cast<NpScene&>(f.scene).getScScene().getSimpleIslandManager()->getRetainedContactRevision()),"late retirement accepted a stale graph receipt");
    step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);
    require(runtime->getContactGraphView().generation==generation+1,"retired graph was not rebuilt on the next pass");
    // Reconfiguration clears the view without cycling lifetime generations.
    generation=runtime->getContactGraphView().generation;f.configure();require(!runtime->getContactGraphView().generation,"clear retained a graph view");
    require(!np.canReuseDestructionContactGraph(runtime->getContactGraphView().generation,static_cast<NpScene&>(f.scene).getScScene().getSimpleIslandManager()->getRetainedContactRevision()),"reconfiguration accepted a stale graph receipt");
    step(f.scene);nativeGraphTest::verify(f.scene,f.cuda);require(runtime->getContactGraphView().generation>generation,"reconfiguration did not regenerate graph");b->release();
    require(f.stage->clearStress() && f.context.healthy(),"graph reuse fixture cleanup failed");
    std::puts("GPU graph reuse: one build per pass; quiet registry has zero sort/readback; late retirement and reconfiguration invalidate receipt");
}

void gpuIslandSleepFallback() {
    Fixture f(1,0,true);f.scene.setGravity(PxVec3(0));f.desc.internalCorrectionLimit=1;f.desc.gpuIslandRepair=true;f.configure();
    PxU64 previous=0;
    for(unsigned i=0;i<8;++i) {
        step(f.scene);const auto graph=static_cast<PxgDestructionRuntime*>(f.stage)->getContactGraphView();
        require(graph.generation==previous+1,"sleeping scene entered early GPU island repair instead of fallback");previous=graph.generation;
    }
    auto& islands=*static_cast<NpScene&>(f.scene).getScScene().getSimpleIslandManager();
    require(!islands.getAccurateIslandSim().getGpuRouteCount() && !islands.getAccurateIslandSim().getGpuSplitCount()
        && !islands.getSpeculativeIslandSim().getGpuRouteCount() && !islands.getSpeculativeIslandSim().getGpuSplitCount(),"sleeping graph was treated as complete GPU input");
    require(f.stage->clearStress() && f.context.healthy(),"sleep fallback cleanup failed");
    std::puts("GPU island repair: sleeping registry retains CPU fallback passed");
}

void sparseAndGrowth(bool sleeping,unsigned count,unsigned quiet) {
    std::fprintf(stderr,"begin collision fixture: chunks=%u quiet=%u sleeping=%u\n",count,quiet,unsigned(sleeping));
    Fixture f(count,quiet,sleeping);f.configure();f.fracture();auto status=f.readStatus();
    require(status.valid && !status.error && status.generation==1 && status.count==count && status.migrating==count-1
        && status.affectedClusters==1 && !status.removed,"sparse native collision binding batch mismatch");
    const auto first=f.bindings(count);std::vector<PxU32> bodies(count+quiet);
    {PxScopedCudaLock lock(f.cuda);check(cuMemcpyDtoH(bodies.data(),CUdeviceptr(f.stage->getDeviceView().trialBodyIndices),bodies.size()*sizeof(PxU32)));}
    for(unsigned i=0;i<count;++i)require(first[i].chunk==i && first[i].shape==f.chunks[i].contactIndex && first[i].sourceBody==f.parent->getGPUIndex() && first[i].targetBody==bodies[i],"binding identity or target does not match GPU topology");
    require(first[0].sourceBody==first[0].targetBody,"retained shape missing from changed-COM work set");f.assertUncommitted();
    for(unsigned retry=0;retry<2;++retry) {f.fracture();const auto current=f.bindings(count);require(!std::memcmp(first.data(),current.data(),first.size()*sizeof(first[0])),"identical fracture retry changed stable binding order/identity");f.assertUncommitted();}
    f.material.compressionElasticLimit=1e12f;f.material.compressionFatalLimit=2e12f;f.configure();step(f.scene);status=f.readStatus();
    require(!status.valid && !status.count && !status.generation && !status.affectedClusters && !status.error,"quiet step exposed stale collision preparation");f.assertUncommitted();
    require(f.context.healthy(),"native collision preparation GPU health failure");
    std::printf("native collision binding preparation: %u affected chunks, %u unchanged structures, sleeping=%u passed\n",count,quiet,unsigned(sleeping));
}
void rejection() {
    Fixture f(4,2,true);const PxU32 old=f.chunks[2].contactIndex;
    f.chunks[2].contactIndex=0xfffffffeu;f.configure();f.fracture(8u|1024u);auto status=f.readStatus();
    require(!status.valid && (status.error&1) && status.generation==1,"out-of-range shape did not reject whole batch");
    f.chunks[2].contactIndex=old;f.assertUncommitted();
    f.chunks[2].contactIndex=f.scene.getDirectGPUAPI().getShapeContactIndex(*f.foreignShape);f.configure();f.fracture(8u|1024u);status=f.readStatus();
    require(!status.valid && (status.error&2),"foreign native owner accepted in collision plan");
    f.chunks[2].contactIndex=old;f.assertUncommitted();
    f.configure();f.fracture();require(f.readStatus().valid,"valid graph could not recover after rejected collision batch");f.assertUncommitted();
    require(f.context.healthy(),"rejected binding corrupted GPU scene");std::puts("native collision binding invalid shape and wrong source reject the whole batch; valid retry passed");
}
void crushRemoval() {
    Fixture f(2,0,true);f.material.compressionElasticLimit=1e12f;f.material.compressionFatalLimit=2e12f;
    f.material.crush.capPressure=2;f.material.crush.cohesion=1000;f.configure();
    bool crushed=false;
    for(unsigned frame=0;frame<150 && !crushed;++frame) {
        f.scene.simulate(1.0f/60);PxU32 error=0;const bool complete=f.scene.fetchResults(true,&error);
        if(complete){require(!error,"ordinary crush accumulation failed");continue;}
        require(error && f.stage->getLastStatus().error==8 && f.stage->getLastStatus().crushedChunks,"crush verdict failed for an unexpected reason");
        const auto status=f.readStatus();require(status.valid && !status.error && status.removed>0,"destroyed chunk collision removal missing");
        const auto bindings=f.bindings(status.count);PxU32 active[2];{PxScopedCudaLock lock(f.cuda);check(cuMemcpyDtoH(active,CUdeviceptr(f.stage->getDeviceView().trialTopology.activeChunks),sizeof(active)));}
        unsigned removed=0;for(const auto& binding:bindings)if(!active[binding.chunk]){require(binding.targetBody==PX_INVALID_U32,"destroyed geometry retained a motion owner");++removed;}
        require(removed==status.removed,"partial collision removal verdict");crushed=true;
    }
    require(crushed,"crush fixture did not exercise collision removal");require(f.context.healthy(),"crush collision preparation GPU failure");std::puts("native crush verdict includes every destroyed collision shape passed");
}
}
int main(int argc,char** argv){try{
    if(argc==2) {
        const std::string mode=argv[1];
        if(mode=="--sparse"){sparseAndGrowth(true,4,64);return 0;}
        if(mode=="--island-repair"){contactComponentPartitions(true);gpuIslandCycleAndFallback();gpuComponentBoundaryAudit();gpuGraphReuseAndQuietObservation();gpuIslandSleepFallback();return 0;}
        if(mode=="--reference"){deviceContactInputs(false);deviceContactInputs(true);contactComponentPartitions(false);sparseAndGrowth(true,4,64);sparseAndGrowth(false,4,64);sparseAndGrowth(true,257,0);rejection();crushRemoval();return 0;}
        throw std::runtime_error("unknown collision test mode");
    }
    require(argc==1,"collision test accepts at most one mode");deviceContactInputs(false);deviceContactInputs(true);contactComponentPartitions(false);contactComponentPartitions(true);gpuIslandCycleAndFallback();gpuComponentBoundaryAudit();gpuGraphReuseAndQuietObservation();gpuIslandSleepFallback();sparseAndGrowth(true,4,64);sparseAndGrowth(false,4,64);sparseAndGrowth(true,257,0);rejection();crushRemoval();return 0;}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
