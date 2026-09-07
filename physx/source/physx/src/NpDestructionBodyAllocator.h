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
    NpRigidDynamic* reserve(bool supported) {
        auto* body=static_cast<NpRigidDynamic*>(NpFactory::getInstance().createDestructionRigidDynamic());
        if(!body)return NULL;
        // Inactive allocation placeholders. No physical mass/motion is inferred
        // here; initialization will consume the matching GPU candidate record.
        body->getCore().setWakeCounter(0);
        if(supported)body->getCore().setFlags(PxRigidBodyFlag::eKINEMATIC);
        body->setNpScene(&mScene);
        mScene.getScScene().addBody(body->getCore(),NULL,0,NpShape::getCoreOffset(),NULL,false);
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
    bool prepare(const PxvDestructionBodyRequest* requests,PxU32 count,PxU32* indices) override {
        // Validate the entire request batch before changing reservations. Look
        // up scene nodes directly; do not scan world actors or traverse bonds.
        PxHashMap<PxU32,PxU32> roots;
        for(PxU32 i=0;i<count;++i)
            if(!isValidSource(requests[i].sourceBody) || requests[i].needsBody>1 || requests[i].supported>1
                || !roots.insert(requests[i].cluster,i))return false;
        PxHashMap<PxU32,PxU32> previous;
        for(PxU32 i=0;i<mBodies.size();++i)previous.insert(mBodies[i].cluster,i);
        PxArray<Entry> next;PxArray<PxU32> reused;PxArray<PxU8> kept;
        next.reserve(count);reused.reserve(count);kept.resize(mBodies.size(),0);
        if(next.capacity()<count || reused.capacity()<count || kept.size()!=mBodies.size())return false;
        bool ok=true;
        for(PxU32 i=0;i<count;++i) {
            const auto& request=requests[i];
            if(!request.needsBody){indices[i]=request.sourceBody;continue;}
            NpRigidDynamic* body=NULL;PxU32 old=PX_INVALID_U32;
            const auto* found=previous.find(request.cluster);
            if(found) {
                const auto& entry=mBodies[found->second];
                if(entry.source==request.sourceBody && bool(entry.body->getCore().getFlags()&PxRigidBodyFlag::eKINEMATIC)==bool(request.supported)) {
                    old=found->second;body=entry.body;kept[old]=1;
                }
            }
            if(!body)body=reserve(request.supported!=0);
            if(!body){ok=false;break;}
            next.pushBack({request.cluster,request.sourceBody,body});reused.pushBack(old);
            indices[i]=body->getCore().getInternalIslandNodeIndex().index();
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
        // Validate the complete metadata batch before changing ownership. Shape
        // identity lookup is built once per source, not once per migrating chunk.
        PxHashMap<PxU32,NpRigidDynamic*> owners;
        PxHashMap<PxU32,NpShape*> shapes;
        PxHashMap<PxU32,PxU32> seen;
        for(PxU32 i=0;i<bodies;++i) {
            auto* parent=source(requests[i].sourceBody);
            auto* target=source(targets[i],true);
            if(!parent || !target || requests[i].supported>1)return false;
            if(owners.insert(requests[i].sourceBody,parent)) {
                const auto& manager=parent->getShapeManager();
                if(parent->getAggregate() || manager.isSqCompound() || manager.getPruningStructure())return false;
                for(PxU32 j=0;j<manager.getNbShapes();++j) {
                    auto* shape=manager.getShapes()[j];auto* sim=shape->getCore().getExclusiveSim();
                    if(sim)shapes.insert(sim->getElementID(),shape);
                }
            }
        }
        for(PxU32 i=0;i<count;++i) {
            const auto b=bindings[i];const auto* found=shapes.find(b.shape);
            auto* from=source(b.sourceBody);auto* to=source(b.targetBody,true);
            if(!found || !from || !to || !seen.insert(b.shape,i))return false;
            auto* shape=found->second;auto* sim=shape->getCore().getExclusiveSim();
            if(shape->getActor()!=from || !shape->isExclusiveFast() || !sim || !sim->isInBroadPhase()
                || shape->getFlagsFast().isSet(PxShapeFlag::eTRIGGER_SHAPE)
                || to->getAggregate() || to->getShapeManager().isSqCompound()
                || to->getShapeManager().getPruningStructure())return false;
        }
        // These are scheduler/type metadata changes. Authoritative mass, COM,
        // velocities and applied forces are installed separately on the GPU.
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
        for(PxU32 i=0;i<count;++i) {
            const auto b=bindings[i];auto* shape=shapes.find(b.shape)->second;
            if(!NpShapeManager::rebindShapeInternal(*source(b.sourceBody),*source(b.targetBody,true),
                *shape,shape->getLocalPoseFast(),true))return false;
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
    }
    PxU32 size() const {return mBodies.size();}
    NpRigidDynamic* find(PxU32 cluster) const {
        for(const auto& entry:mBodies)if(entry.cluster==cluster)return entry.body;
        return NULL;
    }
};
}
