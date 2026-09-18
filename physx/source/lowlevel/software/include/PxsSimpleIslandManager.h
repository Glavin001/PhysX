// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
//  * Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
//  * Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
//  * Neither the name of NVIDIA CORPORATION nor the names of its
//    contributors may be used to endorse or promote products derived
//    from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ''AS IS'' AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
// PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
// CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
// OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//
// Copyright (c) 2008-2026 NVIDIA Corporation. All rights reserved.
// Copyright (c) 2004-2008 AGEIA Technologies, Inc. All rights reserved.
// Copyright (c) 2001-2004 NovodeX AG. All rights reserved.  

#ifndef PXS_SIMPLE_ISLAND_GEN_H
#define PXS_SIMPLE_ISLAND_GEN_H

#include "foundation/PxUserAllocated.h"
#include "PxsIslandSim.h"
#include <atomic>
#include "CmTask.h"

/*
PT: runs first part of the island gen's second pass in parallel with the Pxg-level constraint partitioning.

mIslandGen task spawns Pxg constraint partitioning task(s).
mIslandGen runs processNarrowPhaseTouchEvents() in parallel with Pxg.

///////////////////////////////////////////////////////////////////////////////

Previous design:

mPostIslandGen runs as a continuation task after mIslandGen and Pxg.

mPostIslandGen mainly runs mSetEdgesConnectedTask, which:
- calls mSimpleIslandManager->setEdgeConnected()
- calls mSimpleIslandManager-secondPassIslandGen()
- calls wakeObjectsUp()

///////////////////////////////////////////////////////////////////////////////

New design:

postIslandGen is not a task anymore (mPostIslandGen does not exist).
postIslandGen is directly called at the end of mIslandGen.
So it now runs in parallel with Pxg.
mIslandGen and Pxg continue to mSolver task.

postIslandGen mainly runs mSetEdgesConnectedTask, which:
- calls mSimpleIslandManager->setEdgeConnected()
- calls mSimpleIslandManager->secondPassIslandGenPart1()

mSolver now first runs the parts that don't overlap with Pxg:
- calls mSimpleIslandManager-secondPassIslandGenPart2()
- calls wakeObjectsUp()

///////////////////////////////////////////////////////////////////////////////

Before:
mIslandGen->processNarrowPhaseTouchEvents	|mPostIslandGen											|mSolver
=>PxgConstraintPartition					|=>setEdgesConnected->secondPassIslandGen->wakeObjectsUp|

After:
mIslandGen->processNarrowPhaseTouchEvents->postIslandGen									|secondPassIslandGenPart2->wakeObjectsUp->mSolver
=>PxgConstraintPartition					=>setEdgesConnected->secondPassIslandGenPart1	|
*/
#define USE_SPLIT_SECOND_PASS_ISLAND_GEN	1

namespace physx
{
	class PxsContactManager;

// PT: TODO: fw declaring an Sc class here is not good
namespace Sc
{
	class Interaction;
}

namespace Dy
{
	struct Constraint;
}

namespace IG
{
	class SimpleIslandManager;

class ThirdPassTask : public Cm::Task
{
	SimpleIslandManager& mIslandManager;
	IslandSim& mIslandSim;

public:

	ThirdPassTask(PxU64 contextID, SimpleIslandManager& islandManager, IslandSim& islandSim);

	virtual void runInternal() PX_OVERRIDE;

	virtual const char* getName() const PX_OVERRIDE
	{
		return "ThirdPassIslandGenTask";
	}

private:
	PX_NOCOPY(ThirdPassTask)
};

class PostThirdPassTask : public Cm::Task
{
	SimpleIslandManager& mIslandManager;

public:

	PostThirdPassTask(PxU64 contextID, SimpleIslandManager& islandManager);

	virtual void runInternal() PX_OVERRIDE;

	virtual const char* getName() const PX_OVERRIDE
	{
		return "PostThirdPassTask";
	}
private:
	PX_NOCOPY(PostThirdPassTask)
};

class AuxCpuData
{
	public:
	PX_FORCE_INLINE PxsContactManager*	getContactManager(IG::EdgeIndex edgeId)	const { return reinterpret_cast<PxsContactManager*>(mConstraintOrCm[edgeId]);	}
	PX_FORCE_INLINE Dy::Constraint*		getConstraint(IG::EdgeIndex edgeId)		const { return reinterpret_cast<Dy::Constraint*>(mConstraintOrCm[edgeId]);		}

	Cm::BlockArray<void*>	mConstraintOrCm;	//! Pointers to either the constraint or Cm for this pair
};

class SimpleIslandManager : public PxUserAllocated
{
	HandleManager<PxU32> mNodeHandles;		//! Handle manager for nodes
    // Capacity leased to the native GPU motion allocator. No Node/BodySim exists
    // until a GPU-selected handle is bound. Live includes deferred retirement.
    PxBitMap mReservedNativeNodes, mBoundNativeNodes;
    void reclaimNodeHandle(PxU32 handle);
	HandleManager<EdgeIndex> mEdgeHandles;	//! Handle manager for edges

	//An array of destroyed nodes
	PxArray<PxNodeIndex> mDestroyedNodes;
	Cm::BlockArray<Sc::Interaction*> mInteractions;

	//Edges destroyed this frame
	PxArray<EdgeIndex> mDestroyedEdges;
	GPUExternalData	mGpuData;

	CPUExternalData	mCpuData;
	AuxCpuData		mAuxCpuData;

	PxBitMap mConnectedMap;
    // Contact edges may outlive their active narrowphase manager. Track those
    // lifecycle entries without scanning every active contact for GPU export.
    PxBitMap mRetainedContactMap;
    PxBitMap mRetainedContactChanges;
    // Submission receipt only: suppress removals for edges never published to
    // the device. This is not another contact/connectivity simulation.
    PxBitMap mRetainedContactPublished;
    std::atomic<bool> mRetainedEndpointChanges{false};
    bool isRetainedContact(EdgeIndex edge) {
        const PxU32 word=PxU32(PxAtomicOr(reinterpret_cast<PxI32*>(mRetainedContactMap.getWords()+(edge>>5)),0));
        return bool(word & (1u<<(edge&31)));
    }
    void markRetainedContactChanged(EdgeIndex edge) {
        PxAtomicOr(reinterpret_cast<PxI32*>(mRetainedContactChanges.getWords()+(edge>>5)),PxI32(1u<<(edge&31)));
    }
    std::atomic<PxU64> mRetainedContactRevision{0};
    void setRetainedContact(EdgeIndex edge,bool retained) {
        if(!mGPU)return;
        PxI32* word=reinterpret_cast<PxI32*>(mRetainedContactMap.getWords()+(edge>>5));
        const PxU32 mask=1u<<(edge&31);
        const PxU32 previous=PxU32(retained?PxAtomicOr(word,PxI32(mask)):PxAtomicAnd(word,PxI32(~mask)));
        if(bool(previous&mask)!=retained) {
            markRetainedContactChanged(edge);
            mRetainedContactRevision.fetch_add(1,std::memory_order_relaxed);
        }
    }

	// PT: TODO: figure out why we still need both
	IslandSim mAccurateIslandManager;
	IslandSim mSpeculativeIslandManager;

	ThirdPassTask mSpeculativeThirdPassTask;
	ThirdPassTask mAccurateThirdPassTask;

	PostThirdPassTask mPostThirdPassTask;
	PxU32 mMaxDirtyNodesPerFrame;

	const PxU64	mContextID;
	const bool mGPU;
public:

    bool mDeviceConnectivityRequested = false;
    PxU64 mDeviceConnectivityPasses = 0, mHostConnectivityRestores = 0;
    void requestDeviceConnectivity(bool value) { if(!value)restoreHostConnectivity();mDeviceConnectivityRequested=value; }
    bool deviceConnectivityRequested() const { return mDeviceConnectivityRequested; }
    bool deviceConnectivityOwned() const { return mAccurateIslandManager.deviceConnectivityOwned(); }
    void setDeviceConnectivityOwned(bool value) {
        if(value)++mDeviceConnectivityPasses;
        mAccurateIslandManager.setDeviceConnectivityOwned(value);
        mSpeculativeIslandManager.setDeviceConnectivityOwned(value);
    }
    void restoreHostConnectivity() {
        if(!deviceConnectivityOwned())return;
        ++mHostConnectivityRestores;
        mAccurateIslandManager.restoreHostConnectivity();mSpeculativeIslandManager.restoreHostConnectivity();
    }
    const PxBitMap& getRetainedContactMap() const { return mRetainedContactMap; }
    // Called only at the completed native lifecycle boundary, after parallel
    // contact registration. Coalesce endpoint changes once per transaction.
    const PxBitMap& getRetainedContactChanges() {
        if(mRetainedEndpointChanges.load(std::memory_order_relaxed))mRetainedContactChanges.combineInPlace<PxBitMap::OR>(mRetainedContactMap);
        // Coalesce transient manager release/recreation before enumerating
        // commands; otherwise churn emits removals for never-resident edges.
        for(PxU32 i=0;i<mRetainedContactChanges.getWordCount();++i)
            mRetainedContactChanges.getWords()[i]&=mRetainedContactMap.getWords()[i]|mRetainedContactPublished.getWords()[i];
        return mRetainedContactChanges;
    }
    bool wasRetainedContactPublished(PxU32 edge) const { return mRetainedContactPublished.test(edge); }
    void resetRetainedContactReceipt() { mRetainedContactPublished.clear(); }
    void acknowledgeRetainedContact(PxU32 edge,bool active) {
        if(active)mRetainedContactPublished.set(edge);else mRetainedContactPublished.reset(edge);
    }
    void acknowledgeRetainedContactChanges(const PxArray<PxU32>& deferred) {
        mRetainedContactChanges.clear();mRetainedEndpointChanges.store(false,std::memory_order_relaxed);
        for(PxU32 i=0;i<deferred.size();++i)mRetainedContactChanges.set(deferred[i]);
    }
    PxU64 getRetainedContactRevision() const { return mRetainedContactRevision.load(std::memory_order_relaxed); }
	SimpleIslandManager(bool useEnhancedDeterminism, bool gpu, PxU64 contextID);
	~SimpleIslandManager();

	PxNodeIndex	addNode(bool isActive, bool isKinematic, Node::NodeType type, void* object);
    bool reserveNativeNodeHandles(PxU32 count, PxU32* handles);
    void releaseNativeNodeHandles(PxU32 count, const PxU32* handles);
    bool isUnusedNativeNodeHandle(PxU32 handle) const;
    PxNodeIndex bindNativeNodeHandle(PxU32 handle, bool active, bool kinematic, void* object);
	void		removeNode(const PxNodeIndex index);

	// PT: these two functions added for multithreaded implementation of Sc::Scene::islandInsertion
	void preallocateContactManagers(PxU32 nb, EdgeIndex* handles);
	bool addPreallocatedContactManager(EdgeIndex handle, PxsContactManager* manager, PxNodeIndex nodeHandle1, PxNodeIndex nodeHandle2, Sc::Interaction* interaction, Edge::EdgeType edgeType);

	EdgeIndex addContactManager(PxsContactManager* manager, PxNodeIndex nodeHandle1, PxNodeIndex nodeHandle2, Sc::Interaction* interaction, Edge::EdgeType edgeType);
	EdgeIndex addConstraint(Dy::Constraint* constraint, PxNodeIndex nodeHandle1, PxNodeIndex nodeHandle2, Sc::Interaction* interaction);

	PX_FORCE_INLINE	PxIntBool isEdgeConnected(EdgeIndex edgeIndex) const { return mConnectedMap.test(edgeIndex); }

	void activateNode(PxNodeIndex index);
	void deactivateNode(PxNodeIndex index);
	void putNodeToSleep(PxNodeIndex index);

	void removeConnection(EdgeIndex edgeIndex);
	
	void firstPassIslandGen();
	void additionalSpeculativeActivation();
	void secondPassIslandGen();
	void secondPassIslandGenPart1();
	void secondPassIslandGenPart2();
	void thirdPassIslandGen(PxBaseTask* continuation);

	PX_INLINE void clearDestroyedPartitionEdges()
	{
		mGpuData.mDestroyedPartitionEdges.forceSize_Unsafe(0);
	}

	void setEdgeConnected(EdgeIndex edgeIndex, Edge::EdgeType edgeType);
	void setEdgeDisconnected(EdgeIndex edgeIndex);

	void setEdgeRigidCM(const EdgeIndex edgeIndex, PxsContactManager* cm);

	void clearEdgeRigidCM(const EdgeIndex edgeIndex);

	void setKinematic(PxNodeIndex nodeIndex);

	void setDynamic(PxNodeIndex nodeIndex);

	PX_FORCE_INLINE	IslandSim&			getSpeculativeIslandSim()			{ return mSpeculativeIslandManager;	}
	PX_FORCE_INLINE	const IslandSim&	getSpeculativeIslandSim()	const	{ return mSpeculativeIslandManager;	}

	PX_FORCE_INLINE	IslandSim&			getAccurateIslandSim()				{ return mAccurateIslandManager;	}
	PX_FORCE_INLINE	const IslandSim&	getAccurateIslandSim()		const	{ return mAccurateIslandManager;	}

	PX_FORCE_INLINE	const AuxCpuData&	getAuxCpuData()				const	{ return mAuxCpuData;				}

	PX_FORCE_INLINE PxU32				getNbEdgeHandles()			const	{ return mEdgeHandles.getTotalHandles(); }

	PX_FORCE_INLINE PxU32				getNbNodeHandles()			const	{ return mNodeHandles.getTotalHandles(); }

	void deactivateEdge(const EdgeIndex edge);

	PX_FORCE_INLINE PxsContactManager*	getContactManager(IG::EdgeIndex edgeId)	const { return reinterpret_cast<PxsContactManager*>(mAuxCpuData.mConstraintOrCm[edgeId]);	}
	PX_FORCE_INLINE Dy::Constraint*		getConstraint(IG::EdgeIndex edgeId)		const { return reinterpret_cast<Dy::Constraint*>(mAuxCpuData.mConstraintOrCm[edgeId]);		}

	PX_FORCE_INLINE Sc::Interaction*	getInteractionFromEdgeIndex(IG::EdgeIndex edgeId) const { return mInteractions[edgeId]; }

	PX_FORCE_INLINE	PxU64				getContextId() const { return mContextID; }

	bool checkInternalConsistency();

private:

	friend class ThirdPassTask;
	friend class PostThirdPassTask;

	bool		validateDeactivations() const;
	EdgeIndex	addEdge(void* edge, PxNodeIndex nodeHandle1, PxNodeIndex nodeHandle2, Sc::Interaction* interaction);
	EdgeIndex	resizeEdgeArrays(EdgeIndex handle, bool flag);

	PX_NOCOPY(SimpleIslandManager)
};

}
}

#endif
