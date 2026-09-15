#!/usr/bin/env python3
"""Apply the batch-search experiment only to the isolated selected source."""
from pathlib import Path
import subprocess
ROOT = Path(__file__).resolve().parents[3]
TREE = ROOT/'out/ownership-scheduling-20260915/source'
edits={}

def edit(path, old, new):
    text=edits.get(path)
    if text is None:text=subprocess.check_output(['git','show','13b11af2:'+path],cwd=ROOT,text=True)
    if text.count(old)!=1: raise ValueError((str(path),old[:100],text.count(old)))
    edits[path]=text.replace(old,new)

SC='physx/source/simulationcontroller/src/'
NP='physx/source/physx/src/'
edit(SC+'ScNPhaseCore.h', 'class NPhaseCore :', 'class NativeShapeOwnerBatch;\n\n\tclass NPhaseCore :')
edit(SC+'ScNPhaseCore.h', '\t\tvoid onVolumeRemoved(ElementSim* volume, PxU32 flags, PxsContactManagerOutputIterator& outputs);',
     '\t\tvoid onVolumeRemoved(ElementSim* volume, PxU32 flags, PxsContactManagerOutputIterator& outputs);\n'
     '        bool onNativeOwnerRemoved(ElementSim* volume, PxU32 flags, PxsContactManagerOutputIterator& outputs, NativeShapeOwnerBatch& batch);')
edit(SC+'ScNPhaseCore.cpp', '#include "ScNPhaseCore.h"', '#include "ScNPhaseCore.h"\n#include "ScNativeShapeOwnerBatch.h"\n#include "foundation/PxSort.h"\n#ifdef PHYSX_DESTRUCTION_OWNER_BATCH_AUDIT\n#include <cstdio>\n#endif')
impl='''
bool NativeShapeOwnerBatch::prepare(ShapeSimBase* const* shapes, PxU32 count)
{
    mPrepared=false;mNextShape=0;mActorVisits=0;mLegacySearchVisits=0;mRetiredPairs=0;
    mShapes.clear();mActors.clear();mShapeOrdinals.clear();mActorOrdinals.clear();mRows.clear();mBegin.clear();
    if(count && !shapes)return false;
    if(count==PX_MAX_U32)return false;
    mShapes.reserve(count);mActors.reserve(count);mBegin.resize(count+1,0);
    if(mShapes.capacity()<count || mActors.capacity()<count || mBegin.size()!=count+1
        || !mShapeOrdinals.reserve(count) || !mActorOrdinals.reserve(count))return false;
    for(PxU32 i=0;i<count;++i) {
        auto* shape=shapes[i];
        if(!shape || (i && &shape->getScene()!=&shapes[0]->getScene())
            || !mShapeOrdinals.insert(shape->getElementID(),i))return false;
        mShapes.pushBack(shape);
        auto* actor=&shape->getActor();
        if(!mActorOrdinals.find(actor)) {
            if(!mActorOrdinals.insert(actor,mActors.size()))return false;
            mActors.pushBack(actor);
        }
    }
    PxU64 capacity=0;
    for(const auto* actor:mActors)capacity+=actor->getActorInteractionCount();
    if(capacity>PX_MAX_U32)return false;
    mRows.reserve(PxU32(capacity));
    if(mRows.capacity()<capacity)return false;
    for(auto* actor:mActors) {
        const PxU32 n=actor->getActorInteractionCount();
        Interaction*const* interactions=actor->getActorInteractions();
        for(PxU32 j=0;j<n;++j) {
            ++mActorVisits;
            auto* interaction=interactions[j];
            if(!interaction->isElementInteraction())continue;
            auto* pair=static_cast<ElementSimInteraction*>(interaction);
            const auto* a=mShapeOrdinals.find(pair->getElement0().getElementID());
            const auto* b=mShapeOrdinals.find(pair->getElement1().getElementID());
            const PxU32 ordinal=PxMin(a?a->second:PX_MAX_U32,b?b->second:PX_MAX_U32);
            // A pair can appear in two source-actor lists. Its selected endpoint
            // owns the sole row; later migrating endpoints never dereference it.
            if(ordinal!=PX_MAX_U32 && &mShapes[ordinal]->getActor()==actor) {
                mRows.pushBack({pair,ordinal});++mBegin[ordinal+1];
            }
        }
    }
    struct ShapeOrder {
        bool operator()(const Row& a,const Row& b)const { return a.shape<b.shape; }
    };
    if(mRows.size()>1)PxSort(mRows.begin(),mRows.size(),ShapeOrder());
    for(PxU32 i=0;i<count;++i)mBegin[i+1]+=mBegin[i];
    mPrepared=true;return true;
}

bool NPhaseCore::onNativeOwnerRemoved(ElementSim* volume,PxU32 flags,
    PxsContactManagerOutputIterator& outputs,NativeShapeOwnerBatch& batch)
{
    if(!batch.mPrepared || batch.mNextShape>=batch.mShapes.size()
        || batch.mShapes[batch.mNextShape]!=volume)return false;
    const PxU32 begin=batch.mBegin[batch.mNextShape],end=batch.mBegin[batch.mNextShape+1];
    ActorSim* actor=&volume->getActor();
    batch.mLegacySearchVisits+=actor->getActorInteractionCount();
    // Previous removals replace actor-list entries with the last entry. Sort by
    // CURRENT indices, not the preparation snapshot, to preserve release order.
    // Descending removal cannot move an unprocessed matching entry: its index
    // is below the removed entry. This is the original reverse iterator order.
    struct CurrentActorOrder {
        ActorSim* owner;
        bool operator()(const NativeShapeOwnerBatch::Row& a,const NativeShapeOwnerBatch::Row& b)const {
            return a.interaction->getActorId(owner)>b.interaction->getActorId(owner);
        }
    };
    if(end-begin>1)PxSort(batch.mRows.begin()+begin,end-begin,CurrentActorOrder{actor});
#ifdef PHYSX_DESTRUCTION_OWNER_BATCH_AUDIT
    auto reference=volume->getElemInteractionsReverse();
    for(PxU32 i=begin;i<end;++i)if(reference.getNext()!=batch.mRows[i].interaction)return false;
    if(reference.getNext())return false;
#endif
    flags|=PairReleaseFlag::eRUN_LOST_TOUCH_LOGIC;
    for(PxU32 i=begin;i<end;++i) {
        auto* pair=batch.mRows[i].interaction;
        releaseElementPair(pair,flags,volume,0,true,outputs);
        ++batch.mRetiredPairs;
    }
    ++batch.mNextShape;
#ifdef PHYSX_DESTRUCTION_OWNER_BATCH_AUDIT
    if(batch.complete())std::fprintf(stderr,
        "OWNER_BATCH shapes=%u actors=%u actor_visits=%llu legacy_search_visits=%llu retired_pairs=%llu order_checked=1\\n",
        batch.mShapes.size(),batch.mActors.size(),static_cast<unsigned long long>(batch.mActorVisits),
        static_cast<unsigned long long>(batch.mLegacySearchVisits),static_cast<unsigned long long>(batch.mRetiredPairs));
#endif
    return true;
}

'''
edit(SC+'ScNPhaseCore.cpp','void NPhaseCore::onVolumeRemoved(ElementSim* volume, PxU32 flags, PxsContactManagerOutputIterator& outputs)\n',impl+'void NPhaseCore::onVolumeRemoved(ElementSim* volume, PxU32 flags, PxsContactManagerOutputIterator& outputs)\n')
edit(SC+'ScShapeSimBase.h', 'namespace Sc\n\t{', 'namespace Sc\n\t{\n    class NativeShapeOwnerBatch;')
edit(SC+'ScShapeSimBase.h', 'bool rebindRigidOwner(RigidSim& owner, const PxTransform& shapeToActor, bool deviceOwnerTransaction = false);',
     'bool rebindRigidOwner(RigidSim& owner, const PxTransform& shapeToActor, bool deviceOwnerTransaction = false, NativeShapeOwnerBatch* batch = NULL);')
edit(SC+'ScShapeSimBase.cpp', 'bool ShapeSimBase::rebindRigidOwner(RigidSim& owner, const PxTransform& shapeToActor, bool deviceOwnerTransaction)',
     'bool ShapeSimBase::rebindRigidOwner(RigidSim& owner, const PxTransform& shapeToActor, bool deviceOwnerTransaction, NativeShapeOwnerBatch* batch)')
edit(SC+'ScShapeSimBase.cpp', '        PxProfileScoped profile(profiler,"GpuDestruction.migrateDetail.retireContacts",false,profileContext);\n        scene.getNPhaseCore()->onVolumeRemoved(this, PairReleaseFlag::eWAKE_ON_LOST_TOUCH, outputs);',
     '        PxProfileScoped profile(profiler,"GpuDestruction.migrateDetail.retireContacts",false,profileContext);\n        if(batch) {\n            if(!deviceOwnerTransaction || !scene.getNPhaseCore()->onNativeOwnerRemoved(this,PairReleaseFlag::eWAKE_ON_LOST_TOUCH,outputs,*batch))return false;\n        } else scene.getNPhaseCore()->onVolumeRemoved(this, PairReleaseFlag::eWAKE_ON_LOST_TOUCH, outputs);')
edit(NP+'NpShapeManager.h','namespace physx\n{','namespace physx\n{\nnamespace Sc { class NativeShapeOwnerBatch; }')
edit(NP+'NpShapeManager.h','const PxTransform& shapeToActor, bool nativeTransaction, bool deferObservation = false);',
     'const PxTransform& shapeToActor, bool nativeTransaction, bool deferObservation = false, Sc::NativeShapeOwnerBatch* batch = NULL);')
edit(NP+'NpShapeManager.cpp','const PxTransform& shapeToActor, bool nativeTransaction, bool deferObservation)\n',
     'const PxTransform& shapeToActor, bool nativeTransaction, bool deferObservation, Sc::NativeShapeOwnerBatch* batch)\n')
edit(NP+'NpShapeManager.cpp','return sim->rebindRigidOwner(*destination,shapeToActor,true);','return sim->rebindRigidOwner(*destination,shapeToActor,true,batch);')
edit(NP+'NpShapeManager.cpp','sim->rebindRigidOwner(*destination, shapeToActor, nativeTransaction)', 'sim->rebindRigidOwner(*destination, shapeToActor, nativeTransaction, batch)')
edit(NP+'NpDestructionBodyAllocator.h','#include "ScShapeSim.h"','#include "ScShapeSim.h"\n#include "ScNativeShapeOwnerBatch.h"')
edit(NP+'NpDestructionBodyAllocator.h','    NpScene& mScene;','    NpScene& mScene;\n    Sc::NativeShapeOwnerBatch mOwnerBatch;\n    PxArray<Sc::ShapeSimBase*> mOwnerBatchShapes;')
edit(NP+'NpDestructionBodyAllocator.h',
     '        PxProfileScoped profile(profiler,"GpuDestruction.applyDetail.migrateShapes",false,profileContext);\n        for(PxU32 i=0;i<count;++i) {',
     '''        PxProfileScoped profile(profiler,"GpuDestruction.applyDetail.migrateShapes",false,profileContext);
        mOwnerBatchShapes.resize(count);
        if(mOwnerBatchShapes.size()!=count)return false;
        for(PxU32 i=0;i<count;++i)mOwnerBatchShapes[i]=shapes[bindings[i].shape];
        {
            PxProfileScoped prepare(profiler,"GpuDestruction.applyDetail.prepareOwnerBatch",false,profileContext);
            if(!mOwnerBatch.prepare(mOwnerBatchShapes.begin(),count))return false;
        }
        for(PxU32 i=0;i<count;++i) {''')
edit(NP+'NpDestructionBodyAllocator.h','*shape,shape->getLocalPoseFast(),true,needsHostProperties()))return false;',
     '*shape,shape->getLocalPoseFast(),true,needsHostProperties(),&mOwnerBatch))return false;')
edit(NP+'NpDestructionBodyAllocator.h','    bool publishShapeOwners(const PxDestructionCollisionBinding* bindings,PxU32 count) override {',
     '    bool publishShapeOwners(const PxDestructionCollisionBinding* bindings,PxU32 count) override {')
for path,text in edits.items():(TREE/path).write_text(text)
print('Prepared batch candidate in',TREE)
