// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxvDestructionBodyAllocator.h"
#include "NpFactory.h"
#include "NpRigidDynamic.h"
#include "NpScene.h"
#include "ScBodySim.h"
#include "ScShapeSim.h"
#include "PxsSimpleIslandManager.h"
#include "PxsSimulationController.h"
#include "foundation/PxHashMap.h"
#include "foundation/PxProfiler.h"
namespace physx {
// Only scene finalization and between-step teardown call this allocator. It
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
        // Allocation's initial inactive notification is not a physical sleep
        // transition. Consume it while FIRST_BODY_COPY_GPU still marks this as
        // uninitialized, so fetchResults cannot zero later GPU candidate motion.
        if(!mScene.getScScene().finalizeGpuSleep(&body->getCore())){discard(*body);return NULL;}
        if(!mPrivateBodies.insert(body,false)){discard(*body);return NULL;}
        return body;
    }
public:
    bool supportsGpuIslandRepair() const override { return mScene.getScScene().canUseGpuDestructionIslandRepair(); }

    explicit NpDestructionBodyAllocator(NpScene& scene):mScene(scene) {}
    ~NpDestructionBodyAllocator() override {clear();}
    bool isValidSource(PxU32 body) const override {return source(body)!=NULL;}
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
            if(!islands.isUnusedNativeNodeHandle(indices[i]))return false;
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
            if(!shape || sim->getElementID()!=b.shape || shape->getActor()!=from || !shape->isExclusiveFast()
                || shape->getCore().getExclusiveSim()!=sim || !sim->isInBroadPhase()
                || shape->getFlagsFast().isSet(PxShapeFlag::eTRIGGER_SHAPE)
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
                *shape,shape->getLocalPoseFast(),true))return false;
        }
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
