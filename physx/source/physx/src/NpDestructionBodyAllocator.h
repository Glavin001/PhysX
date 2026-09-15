// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include <cstdlib>
#include <cstring>
#include "PxvDestructionBodyAllocator.h"
#include "NpFactory.h"
#include "NpRigidDynamic.h"
#include "NpScene.h"
#include "ScBodySim.h"
#include "ScShapeSim.h"
#include "ScSimStateData.h"
#include "PxsSimpleIslandManager.h"
#include "PxsSimulationController.h"
#include "foundation/PxHashMap.h"
#include "foundation/PxProfiler.h"
namespace physx {
// Scene finalization, between-step commands and teardown call this allocator. It
// never relaxes the application's API access guards or publishes candidates in
// the scene actor/query lists. These are real BodySim/node reservations, not
// one independent body allocated in advance for every intact chunk.
class NpDestructionBodyAllocator final : public PxvDestructionBodyAllocator, public PxUserAllocated {
    struct Entry {PxU32 cluster,source;NpRigidDynamic* body;};
    NpScene& mScene;
    PxArray<Entry> mBodies;
    PxArray<Entry> mAcceptedBodies;
    PxArray<PxU32> mGrantedNodes;
    PxBitMap mGrantedNodeMask;
    // Private-body membership must not scan every accepted fragment for every
    // chunk binding. False denotes an uncommitted reservation; true denotes an
    // accepted owner. The arrays retain deterministic allocation/teardown order.
    PxHashMap<NpRigidDynamic*,bool> mPrivateBodies;
    // Placeholder bodies pre-bound to granted node handles. The GPU allocator
    // consumes granted handles sequentially, so a fracture takes the placeholder
    // already registered on its handle instead of creating and adding a body
    // inside the tick. Opt-in: PHYSX_DESTRUCTION_BODY_POOL=N (bodies reserved at
    // the first advance) enables it; placeholders are island nodes, and the
    // native lifecycle tests and CPU/GPU island audits still expect none before
    // allocation, so the default stays off until those consumers are migrated.
    PxHashMap<PxU32,NpRigidDynamic*> mPlaceholders;
    static bool poolEnabled() {
        static const bool enabled=[](){const char* raw=getenv("PHYSX_DESTRUCTION_BODY_POOL");return raw && strcmp(raw,"0")!=0;}();
        return enabled;
    }
    NpRigidDynamic* source(PxU32 id, bool allowReservation=false) const {
        const auto& islands=mScene.getScScene().getSimpleIslandManager()->getAccurateIslandSim();
        if(id>=islands.getNbNodes())return NULL;
        const auto& node=islands.getNode(PxNodeIndex(id));
        if(node.isDeleted() || node.getNodeType()!=IG::Node::eRIGID_BODY_TYPE || !node.mObject)return NULL;
        // Island deletion is deferred; its object pointer can already be
        // released. The controller unregisters the body before storage is freed.
        if(!mScene.getScScene().getSimulationController()->isRigidBodyRegistered(id,static_cast<PxsRigidBody*>(node.mObject)))return NULL;
        auto* sim=reinterpret_cast<Sc::BodySim*>(reinterpret_cast<PxU8*>(node.mObject)-Sc::BodySim::getRigidBodyOffset());
        PxActor* actor=sim->getPxActor();
        if(!actor || actor->getConcreteType()!=PxConcreteType::eRIGID_DYNAMIC)return NULL;
        auto* body=static_cast<NpRigidDynamic*>(actor);
        if(body->getNpScene()!=&mScene)return NULL;
        if(body->getRigidActorSceneIndex()!=NP_UNUSED_BASE_INDEX)return body;
        const auto* entry=mPrivateBodies.find(body);
        return entry && (entry->second || allowReservation) ? body : NULL;
    }
    void discard(NpRigidDynamic& body) {
        // Remove membership before the pool can reuse this object's address.
        mPrivateBodies.erase(&body);
        PxInlineArray<const Sc::ShapeCore*,64> shapes;
        mScene.getScScene().removeBody(body.getCore(),shapes,false);
        body.getShapeManager().detachAll(&mScene.getSQAPI(), body);
        body.setNpScene(NULL);NpFactory::getInstance().releaseRigidDynamicToPool(body);
    }
    static void observeSettings(Sc::BodyCore& core,const PxvDestructionBodyProperties& observation) {
        auto& state=core.getCore();
        // Publish GPU-inherited settings once. Source CPU ancestors need not
        // exist or have current properties during the fracture transaction.
        const auto& values=observation.dynamicLimitsDamping;
        const PxReal maxLinear=values[0],maxAngular=values[1];
        const PxReal linearDamping=values[2],angularDamping=values[3];
        state.linearDamping=linearDamping;state.angularDamping=angularDamping;
        state.maxLinearVelocitySq=maxLinear;state.maxAngularVelocitySq=maxAngular;
        state.maxPenBias=observation.maxPenBias;state.maxContactImpulse=observation.maxContactImpulse;
        state.contactReportThreshold=observation.contactReportThreshold;state.offsetSlop=observation.offsetSlop;
        state.sleepThreshold=observation.sleepThreshold;state.freezeThreshold=observation.freezeThreshold;
        state.disableGravity=observation.disableGravity;state.lockFlags=PxRigidDynamicLockFlags(observation.lockFlags);
        state.solverIterationCounts=PxU16(observation.solverIterationCounts);
        core.getSim()->getLowLevelBody().mGpuDynamicLimitsDamping=PxVec4(maxLinear,maxAngular,linearDamping,angularDamping);
        if(auto* simState=core.getSim()->getSimStateData(true)) {
            auto* kine=simState->getKinematicData();
            kine->backupLinearDamping=linearDamping;kine->backupAngularDamping=angularDamping;
            kine->backupMaxLinVelSq=maxLinear;kine->backupMaxAngVelSq=maxAngular;
            state.linearDamping=state.angularDamping=0;
            state.maxLinearVelocitySq=state.maxAngularVelocitySq=PX_MAX_REAL;
        }
        core.getSim()->getLowLevelBody().mInternalFlags|=PxsRigidBody::eDESTRUCTION_MASS_GPU;
    }
    NpRigidDynamic* reserve(bool supported,PxU32 node) {
        auto* body=static_cast<NpRigidDynamic*>(NpFactory::getInstance().createDestructionRigidDynamic());
        if(!body)return NULL;
        // Inactive allocation placeholders. No physical mass/motion is inferred
        // here; initialization will consume the matching GPU candidate record.
        body->getCore().setWakeCounter(0);
        if(supported)body->getCore().setFlags(PxRigidBodyFlag::eKINEMATIC);
        body->setNpScene(&mScene);
        mScene.getScScene().addBody(body->getCore(),NULL,0,NpShape::getCoreOffset(),NULL,false,PxNodeIndex(node));
        if(!body->getCore().getSim()){body->setNpScene(NULL);NpFactory::getInstance().releaseRigidDynamicToPool(*body);return NULL;}
        // Initial inactivity has no resident GPU motion and queues no GPU sleep
        // transaction. Candidate initialization supplies the fragment motion.
        if(!mPrivateBodies.insert(body,false)){discard(*body);return NULL;}
        return body;
    }
public:
    PxU32 getShapeContactIndex(const PxShape& shape) const override {
        if(mScene.isAPIWriteForbidden())return PX_INVALID_U32;
        const auto& native=static_cast<const NpShape&>(shape);
        if(!native.isExclusiveFast() || native.getNpScene()!=&mScene)return PX_INVALID_U32;
        const auto* sim=native.getCore().getExclusiveSim();
        return sim?sim->getTransformCacheID():PX_INVALID_U32;
    }
    bool readRigidBodyData(void* data,const PxRigidDynamicGPUIndex* indices,PxRigidDynamicGPUAPIReadType::Enum type,
        PxU32 count,CUevent start,CUevent finish) const override {
        if(mScene.isAPIWriteForbidden() || !mScene.getScScene().isSimulationResultAccepted() || !data || !indices)return false;
        return mScene.getScScene().getSimulationController()->getRigidDynamicData(data,indices,type,count,start,finish);
    }
    bool needsHostProperties() const override {
        return !(mScene.getFlags() & PxSceneFlag::eENABLE_DIRECT_GPU_API);
    }
    bool wakeCommandOwners(const PxU32* indices,PxU32 count) override {
        if(mScene.isAPIWriteForbidden() || !mScene.getScScene().isSimulationResultAccepted() || (count && !indices))return false;
        for(PxU32 i=0;i<count;++i) {
            const auto* body=source(indices[i]);
            if(!body || body->getCore().getActorFlags().isSet(PxActorFlag::eDISABLE_SIMULATION))return false;
        }
        // A queued sleep finalization clears native velocities/forces. Complete
        // it before command producers can write, just as ordinary wakeUp does.
        for(PxU32 i=0;i<count;++i) {
            auto* body=source(indices[i]);
            if(!(body->getCore().getFlags() & PxRigidBodyFlag::eKINEMATIC) &&
                !mScene.getScScene().finalizeGpuSleep(&body->getCore()))return false;
        }
        for(PxU32 i=0;i<count;++i) {
            auto* body=source(indices[i]);
            if(!(body->getCore().getFlags() & PxRigidBodyFlag::eKINEMATIC))
                body->wakeUpInternalNoKinematicTest(true,true);
        }
        return true;
    }
    bool publishCorrectionProperties(const PxvDestructionBodyProperties* inputs,PxU32 count) override {
        for(PxU32 i=0;i<count;++i)if(!source(inputs[i].motion.targetBody,true))return false;
        for(PxU32 i=0;i<count;++i) {
            const auto& v=inputs[i].motion.body;
            auto& core=source(inputs[i].motion.targetBody,true)->getCore();
            observeSettings(core,inputs[i]);
            auto& state=core.getCore();
            // Kinematic solver inverses are zero. Ordinary actor getters expose
            // the physical mass/inertia stored in their kinematic backup.
            if(auto* simState=core.getSim()->getSimStateData(true)) {
                auto* kine=simState->getKinematicData();
                kine->backupInvMass=v.mass>0 ? 1.0f/v.mass : 0;
                kine->backupInverseInertia=PxVec3(v.principalInertia[0]>0 ? 1.0f/v.principalInertia[0] : 0,
                    v.principalInertia[1]>0 ? 1.0f/v.principalInertia[1] : 0,
                    v.principalInertia[2]>0 ? 1.0f/v.principalInertia[2] : 0);
            }
            state.inverseMass=v.inverseMass;
            state.inverseInertia=PxVec3(v.inverseInertia[0],v.inverseInertia[1],v.inverseInertia[2]);
            state.setBody2Actor(PxTransform(PxVec3(v.bodyToActorPosition[0],v.bodyToActorPosition[1],v.bodyToActorPosition[2]),
                PxQuat(v.bodyToActorOrientation[0],v.bodyToActorOrientation[1],v.bodyToActorOrientation[2],v.bodyToActorOrientation[3])));
            auto& body=core.getSim()->getLowLevelBody();
            state.body2World=PxTransform(PxVec3(v.bodyToWorldPosition[0],v.bodyToWorldPosition[1],v.bodyToWorldPosition[2]),
                PxQuat(v.bodyToWorldOrientation[0],v.bodyToWorldOrientation[1],v.bodyToWorldOrientation[2],v.bodyToWorldOrientation[3]));
            state.linearVelocity=PxVec3(v.linearVelocity[0],v.linearVelocity[1],v.linearVelocity[2]);
            state.angularVelocity=PxVec3(v.angularVelocity[0],v.angularVelocity[1],v.angularVelocity[2]);
            body.mLastTransform=state.body2World;
            body.mInternalFlags|=PxsRigidBody::eDESTRUCTION_MASS_GPU;
        }
        return true;
    }
    bool supportsGpuIslandRepair() const override { return mScene.getScScene().canUseGpuDestructionIslandRepair(); }

    explicit NpDestructionBodyAllocator(NpScene& scene):mScene(scene) {}
    ~NpDestructionBodyAllocator() override {clear();}
    bool isValidSource(PxU32 body) const override {return source(body)!=NULL;}
    bool exportNativeSnapshot(const PxU32* indices,PxU32 count,void* data,PxU32 stride) const override {
        for(PxU32 i=0;i<count;++i)if(!source(indices[i]))return false;
        if(!mScene.getScScene().getSimulationController()->exportNativeSnapshot(indices,count,data,stride))return false;
        auto* values=static_cast<PxvDestructionSnapshotBody*>(data);
        for(PxU32 i=0;i<count;++i){const auto& core=source(indices[i])->getCore();
            values[i].active=core.getSim()->isActive();
            // Ordinary wakeUp/addForce may update the logical wake counter
            // between steps even when its force is subsequently cleared. This
            // is public physical state, not the GPU's previous sleep filter.
            values[i].wakeCounter=core.getWakeCounter();
        }
        return true;
    }
    bool importNativeSnapshot(const PxU32* indices,PxU32 count,const void* data,PxU32 stride) override {
        for(PxU32 i=0;i<count;++i)if(!source(indices[i]))return false;
        if(!mScene.getScScene().getSimulationController()->importNativeSnapshot(indices,count,data,stride))return false;
        const auto* values=static_cast<const PxvDestructionSnapshotBody*>(data);
        for(PxU32 i=0;i<count;++i){auto& actor=*source(indices[i]);auto& core=actor.getCore();auto& sim=*core.getSim();
            const auto& v=values[i];
            // Ordinary pose notification rebuilds collision/query transforms.
            actor.setGlobalPose(v.bodyToWorld*v.bodyToActor.getInverse(),false);
            core.setBody2World(v.bodyToWorld);
            if(sim.isActive()!=bool(v.active))sim.setActive(v.active!=0);
            auto& ll=sim.getLowLevelBody();ll.mLastTransform=v.bodyToWorld;
            // Import is the initial physical state, not an unconsumed command.
            ll.mGpuHostDirty=0;
        }
        return true;
    }
    bool stateExportAllowed() const override {
        if(mScene.isAPIWriteForbidden() || !mScene.getScScene().isSimulationResultAccepted())return false;
        // The collection captures accepted rigid state, not unconsumed force
        // accumulators or kinematic commands. Submit the next stimulus after
        // restore; reject pending commands instead of silently dropping them.
        auto clean=[](const NpRigidDynamic& body){
            const auto* sim=body.getCore().getSim();if(!sim)return false;
            const PxU32 host=PxU32(sim->getLowLevelBody().mGpuHostDirty)<<16;
            if(host & (PxsRigidBody::eHOST_POSE_COPY_GPU|PxsRigidBody::eHOST_LINEAR_COPY_GPU
                |PxsRigidBody::eHOST_ANGULAR_COPY_GPU|PxsRigidBody::eHOST_MASS_COPY_GPU
                |PxsRigidBody::eHOST_INERTIA_COPY_GPU|PxsRigidBody::eHOST_COM_COPY_GPU))return false;
            if(const auto* data=sim->getSimStateData(true))if(data->getKinematicData()->targetValid)return false;
            if(const auto* data=sim->getSimStateData(false)){
                const auto* v=data->getVelocityModData();
                if(!v->linearPerSec.isZero() || !v->angularPerSec.isZero()
                    || !v->linearPerStep.isZero() || !v->angularPerStep.isZero())return false;
            }
            return true;
        };
        PxActor* actors[128];PxU32 offset=0,count;
        while((count=mScene.getActors(PxActorTypeFlag::eRIGID_DYNAMIC,actors,128,offset))!=0){
            for(PxU32 i=0;i<count;++i)if(!clean(*static_cast<NpRigidDynamic*>(actors[i])))return false;
            offset+=count;
        }
        for(const auto& entry:mAcceptedBodies)if(!clean(*entry.body))return false;
        return true;
    }
    bool reserveNodeCapacity(PxU32 capacity,const PxU32*& indices) override {
        const PxU32 old=mGrantedNodes.size();
        if(capacity>old) {
            auto& islands=*mScene.getScScene().getSimpleIslandManager();
            const PxU32 extra=capacity-old;
            if(PxU64(islands.getNbNodeHandles())+extra+31>PX_INVALID_NODE
                || !mGrantedNodeMask.resize(islands.getNbNodeHandles()+extra))return false;
            mGrantedNodes.resize(capacity);
            if(mGrantedNodes.size()!=capacity)return false;
            if(!islands.reserveNativeNodeHandles(extra,mGrantedNodes.begin()+old)) {
                mGrantedNodes.forceSize_Unsafe(old);return false;
            }
            for(PxU32 i=old;i<capacity;++i)mGrantedNodeMask.set(mGrantedNodes[i]);
            if(poolEnabled()) {
                PxProfileScoped profile(PxGetProfilerCallback(),"GpuDestruction.allocator.createPlaceholders",false,PxU64(reinterpret_cast<size_t>(this)));
                for(PxU32 i=old;i<capacity;++i) {
                    // Kinematic placeholders stay outside dynamic island audits
                    // and contact components until a fracture claims them.
                    auto* body=reserve(true,mGrantedNodes[i]);
                    if(!body)break; // later fractures fall back to in-tick creation
                    mPlaceholders.insert(mGrantedNodes[i],body);
                }
            }
        }
        indices=mGrantedNodes.begin();return true;
    }
    bool prepare(const PxvDestructionBodyRequest* requests,PxU32 count,const PxU32* indices) override {
        if(count && (!requests || !indices))return false;
        // Validate all GPU-selected addresses before creating a compatibility
        // record. In particular, ordinary and foreign allocator slots are invalid.
        auto& islands=*mScene.getScScene().getSimpleIslandManager();
        PxHashMap<PxU32,PxU32> roots,targets,previous;
        for(PxU32 i=0;i<mBodies.size();++i)previous.insert(mBodies[i].cluster,i);
        for(PxU32 i=0;i<count;++i) {
            const auto& request=requests[i];
            if(!isValidSource(request.sourceBody) || request.needsBody>1 || request.supported>1
                || !roots.insert(request.cluster,i))return false;
            if(!request.needsBody) {if(indices[i]!=request.sourceBody)return false;continue;}
            if(!mGrantedNodeMask.boundedTest(indices[i]) || !targets.insert(indices[i],i))return false;
            const auto* found=previous.find(request.cluster);
            if(found) {
                const auto& entry=mBodies[found->second];
                if(entry.body->getCore().getInternalIslandNodeIndex().index()==indices[i]
                    && entry.source==request.sourceBody
                    && bool(entry.body->getCore().getFlags()&PxRigidBodyFlag::eKINEMATIC)==bool(request.supported))continue;
            }
            if(!mPlaceholders.find(indices[i]) && !islands.isUnusedNativeNodeHandle(indices[i]))return false;
        }
        PxArray<Entry> next;PxArray<PxU32> reused;PxArray<PxU8> kept;
        next.reserve(count);reused.reserve(count);kept.resize(mBodies.size(),0);
        if(next.capacity()<count || reused.capacity()<count || kept.size()!=mBodies.size())return false;
        bool ok=true;
        for(PxU32 i=0;i<count;++i) {
            const auto& request=requests[i];if(!request.needsBody)continue;
            NpRigidDynamic* body=NULL;PxU32 old=PX_INVALID_U32;
            const auto* found=previous.find(request.cluster);
            if(found && mBodies[found->second].body->getCore().getInternalIslandNodeIndex().index()==indices[i]) {
                old=found->second;body=mBodies[old].body;kept[old]=1;
            }
            if(!body) {
                if(auto* placeholder=mPlaceholders.find(indices[i])) {
                    body=placeholder->second;mPlaceholders.erase(indices[i]);
                    // Placeholders are kinematic and inactive; an unsupported
                    // fragment becomes dynamic exactly as a fresh reservation would be.
                    if(!request.supported)body->getCore().setFlags(PxRigidBodyFlags());
                }
            }
            if(!body)body=reserve(request.supported!=0,indices[i]);
            if(!body){ok=false;break;}
            next.pushBack({request.cluster,request.sourceBody,body});reused.pushBack(old);
        }
        if(!ok) {for(PxU32 i=0;i<next.size();++i)if(reused[i]==PX_INVALID_U32)discard(*next[i].body);return false;}
        for(PxU32 i=0;i<mBodies.size();++i)if(!kept[i])discard(*mBodies[i].body);
        mBodies.swap(next);return true;
    }
    bool applyBindings(const PxDestructionCollisionBinding* bindings,PxU32 count,
        const PxvDestructionBodyRequest* requests,const PxU32* targets,PxU32 bodies) override {
        if(mBodies.size()>PX_MAX_U32-mAcceptedBodies.size())return false;
        const PxU32 required=mAcceptedBodies.size()+mBodies.size();
        mAcceptedBodies.reserve(required);
        if(mAcceptedBodies.capacity()<required)return false;
        // Only actual migrations cross this observation boundary. Retained owners
        // are updated by the GPU collision transaction and cache invalidation.
        // PhysX already owns a persistent element-ID index. Reconstructing a
        // second shape map by walking source actors is unnecessary, including
        // for chunks that do not migrate. Keep batch validation before mutation.
        auto* controller=mScene.getScScene().getSimulationController();
        auto** shapes=controller->getShapeSims();
        const PxU32 shapeCapacity=controller->getNbShapes();
        if(count && !shapes)return false;
        PxHashMap<PxU32,NpRigidDynamic*> owners;
        PxHashMap<PxU32,PxU32> seen;
        PxProfilerCallback* profiler=PxGetProfilerCallback();
        const PxU64 profileContext=PxU64(reinterpret_cast<size_t>(this));
        {
        PxProfileScoped profile(profiler,"GpuDestruction.applyDetail.validateOwners",false,profileContext);
        for(PxU32 i=0;i<bodies;++i) {
            auto* parent=source(requests[i].sourceBody);
            auto* target=source(targets[i],true);
            if(!parent || !target || requests[i].supported>1)return false;
            if(owners.insert(requests[i].sourceBody,parent)) {
                const auto& manager=parent->getShapeManager();
                if(parent->getAggregate() || manager.isSqCompound() || manager.getPruningStructure())return false;
            }
        }
        for(PxU32 i=0;i<count;++i) {
            const auto b=bindings[i];
            auto* from=source(b.sourceBody);auto* to=source(b.targetBody,true);
            if(!from || !to || from==to || !owners.find(b.sourceBody) || b.shape>=shapeCapacity
                || !shapes[b.shape] || !seen.insert(b.shape,i))return false;
            auto* sim=shapes[b.shape];auto* shape=static_cast<NpShape*>(sim->getPxShape());
            if(!shape || sim->getElementID()!=b.shape || (needsHostProperties()? &sim->getActor()!=from->getCore().getSim():shape->getActor()!=from) || !shape->isExclusiveFast()
                || shape->getCore().getExclusiveSim()!=sim || !sim->isInBroadPhase()
                || shape->getFlagsFast().isSet(PxShapeFlag::eTRIGGER_SHAPE)
                || (shape->getFlagsFast().isSet(PxShapeFlag::eSCENE_QUERY_SHAPE)
                    && !mScene.getNpSQ().supportsNativeGpuQueryRebind())
                || to->getAggregate() || to->getShapeManager().isSqCompound()
                || to->getShapeManager().getPruningStructure())return false;
        }
        }
        // These are scheduler/type metadata changes. Authoritative mass, COM,
        // velocities and applied forces are installed separately on the GPU.
        {
        PxProfileScoped profile(profiler,"GpuDestruction.applyDetail.scheduleOwners",false,profileContext);
        for(PxU32 i=0;i<bodies;++i) {
            auto* target=source(targets[i],true);auto& core=target->getCore();auto flags=core.getFlags();
            if(requests[i].supported)flags|=PxRigidBodyFlag::eKINEMATIC;
            else flags.clear(PxRigidBodyFlag::eKINEMATIC);
            core.setFlags(flags,true);
            core.getSim()->getLowLevelBody().mInternalFlags|=PxsRigidBody::eDESTRUCTION_MASS_GPU;
            // Physical settings, including solver iterations, are inherited on
            // GPU and reach CPU records only through final accepted publication.
            if(!requests[i].supported) {
                core.getSim()->setActive(true);
                // Reservations begin with ready-for-sleep island flags. Installing
                // moving GPU state must clear those flags as well as activate BodySim;
                // otherwise contact separation can freeze a falling fragment even
                // in an eDISABLE_SLEEPING scene. This changes scheduler metadata only.
                core.getSim()->notifyNotReadyForSleeping();
            }
        }
        }
        {
        PxProfileScoped profile(profiler,"GpuDestruction.applyDetail.migrateShapes",false,profileContext);
        for(PxU32 i=0;i<count;++i) {
            const auto b=bindings[i];auto* shape=static_cast<NpShape*>(shapes[b.shape]->getPxShape());
            if(!NpShapeManager::rebindShapeInternal(*source(b.sourceBody),*source(b.targetBody,true),
                *shape,shape->getLocalPoseFast(),true,needsHostProperties()))return false;
        }
        }
        return true;
    }
    bool publishShapeOwners(const PxDestructionCollisionBinding* bindings,PxU32 count) override {
        if(count && !bindings)return false;
        auto* controller=mScene.getScScene().getSimulationController();
        auto** shapes=controller->getShapeSims();const PxU32 capacity=controller->getNbShapes();
        // Validate the entire GPU-selected final batch before publication.
        for(PxU32 i=0;i<count;++i) {
            const auto& b=bindings[i];auto* target=source(b.targetBody,true);
            if(!target || b.shape>=capacity || !shapes[b.shape]
                || &shapes[b.shape]->getActor()!=target->getCore().getSim())return false;
        }
        PxProfileScoped profile(PxGetProfilerCallback(),"GpuDestruction.finalShapePublication",false,
            PxU64(reinterpret_cast<size_t>(this)));
        for(PxU32 i=0;i<count;++i) {
            const auto& b=bindings[i];auto* shape=shapes[b.shape]->getPxShape();
            if(!NpShapeManager::publishNativeShapeOwner(*source(b.targetBody,true),*shape))return false;
        }
        return true;
    }
    void acceptReservations() override {
        for(const auto& entry:mBodies) {
            PX_ASSERT(mPrivateBodies.find(entry.body));
            // Already inserted at reservation time; acceptance does not grow
            // the lookup or allocate storage after physical state is committed.
            mPrivateBodies[entry.body]=true;
            mAcceptedBodies.pushBack(entry);
        }
        mBodies.clear();
    }
    void discardReservations() override {for(auto& entry:mBodies)discard(*entry.body);mBodies.clear();}
    void clear() override {
        discardReservations();
        for(auto it=mPlaceholders.getIterator();!it.done();++it)discard(*it->second);
        mPlaceholders.clear();
        for(auto& entry:mAcceptedBodies)discard(*entry.body);
        mAcceptedBodies.clear();
        PX_ASSERT(mPrivateBodies.size()==0);
        if(mGrantedNodes.size()) {
            mScene.getScScene().getSimpleIslandManager()->releaseNativeNodeHandles(mGrantedNodes.size(),mGrantedNodes.begin());
            mGrantedNodes.clear();mGrantedNodeMask.clear();
        }
    }
    PxU32 size() const {return mBodies.size();}
    NpRigidDynamic* find(PxU32 cluster) const {
        for(const auto& entry:mBodies)if(entry.cluster==cluster)return entry.body;
        return NULL;
    }
};
}
