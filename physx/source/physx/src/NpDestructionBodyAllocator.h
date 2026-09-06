// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxvDestructionBodyAllocator.h"
#include "NpFactory.h"
#include "NpRigidDynamic.h"
#include "NpScene.h"
#include "ScBodySim.h"
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
    NpRigidDynamic* source(PxU32 id) const {
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
        return body->getNpScene()==&mScene && body->getRigidActorSceneIndex()!=NP_UNUSED_BASE_INDEX?body:NULL;
    }
    void discard(NpRigidDynamic& body) {
        PX_ASSERT(body.getShapeManager().getNbShapes()==0);
        PxInlineArray<const Sc::ShapeCore*,64> shapes;
        mScene.getScScene().removeBody(body.getCore(),shapes,false);
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
        return body;
    }
public:
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
    void clear() override {for(auto& entry:mBodies)discard(*entry.body);mBodies.clear();}
    PxU32 size() const {return mBodies.size();}
    NpRigidDynamic* find(PxU32 cluster) const {
        for(const auto& entry:mBodies)if(entry.cluster==cluster)return entry.body;
        return NULL;
    }
};
}
