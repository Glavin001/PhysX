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

#include "PxsIslandSim.h"
#include "PxsRigidBody.h"
#include "foundation/PxSort.h"
#include "foundation/PxUtilities.h"
#include "common/PxProfileZone.h"
#include <cstdio>

using namespace physx;
using namespace IG;

#if IG_CACHE_CONTACT_MANAGER_DATA
static void cacheContactManagerData(IslandEdgesData_Island::EdgeData& indexedManager, const IslandSim& islandSim, EdgeIndex contactEdgeIndex, Edge::EdgeType edgeType)
{
	// PT: for contact managers we cache the data that we will need later in DynamicsContextBase::iterateIslandsContactEdges().
	// The goal is to avoid accessing the IG::IslandSim data structures while doing so. Instead we only read it once here and
	// cache a copy of the data alongside the edge index.
	if(edgeType == Edge::eCONTACT_MANAGER)
	{
		const PxNodeIndex nodeIndex1 = islandSim.mCpuData.getNodeIndex1(contactEdgeIndex);
		const PxNodeIndex nodeIndex2 = islandSim.mCpuData.getNodeIndex2(contactEdgeIndex);

		PX_ASSERT(!nodeIndex1.isStaticBody());

		PxU8 indexType0;
		if(nodeIndex1.isStaticBody())
		{
			indexType0 = PxsIndexedInteraction::eWORLD;
		}
		else
		{
			const IG::Node& node1 = islandSim.getNode(nodeIndex1);

			if(node1.getNodeType() == IG::Node::eARTICULATION_TYPE)
			{
				indexType0 = PxsIndexedInteraction::eARTICULATION;
			}
			else
			{
				if(node1.isKinematic())
					indexType0 = PxsIndexedInteraction::eKINEMATIC;
				else
					indexType0 = PxsIndexedInteraction::eBODY;
			}
		}
		indexedManager.setData0(nodeIndex1, indexType0);
		PX_ASSERT(indexedManager.getNodeIndex0() == nodeIndex1);
		PX_ASSERT(indexedManager.getType0() == indexType0);

		PxU8 indexType1;
		if(nodeIndex2.isStaticBody())
		{
			indexType1 = PxsIndexedInteraction::eWORLD;
		}
		else
		{
			const IG::Node& node2 = islandSim.getNode(nodeIndex2);

			if(node2.getNodeType() == IG::Node::eARTICULATION_TYPE)
			{
				indexType1 = PxsIndexedInteraction::eARTICULATION;
			}
			else
			{
				if(node2.isKinematic())
					indexType1 = PxsIndexedInteraction::eKINEMATIC;
				else
					indexType1 = PxsIndexedInteraction::eBODY;
			}
		}
		indexedManager.setData1(nodeIndex2, indexType1);
		PX_ASSERT(indexedManager.getNodeIndex1() == nodeIndex2);
		PX_ASSERT(indexedManager.getType1() == indexType1);
	}
}
#endif

static PX_FORCE_INLINE void addEdgeToIsland(const IslandSim& islandSim, Cm::BlockArray<Edge>& edges, IslandEdgesData_Island& islandEdges, EdgeIndex edgeIndex)
{
	Edge& edge = edges[edgeIndex];

#if IG_STORE_ISLAND_EDGES_IN_ARRAYS
	PxArray<IslandEdgesData_Island::EdgeData>& edgeArray = islandEdges.mEdges[edge.mEdgeType];
	#if PX_DEBUG
	for(PxU32 i=0; i<edgeArray.size(); i++)
	{
		PX_ASSERT(edgeArray[i].mIndex != edgeIndex);
	}
	#endif
	PX_ASSERT(edge.mLinks.mIndex == IG_INVALID_EDGE);
	edge.mLinks.mIndex = edgeArray.size();
	IslandEdgesData_Island::EdgeData data;
	data.mIndex = edgeIndex;
	#if IG_CACHE_CONTACT_MANAGER_DATA
	cacheContactManagerData(data, islandSim, edgeIndex, Edge::EdgeType(edge.mEdgeType));
	#endif
	edgeArray.pushBack(data);
#else
	PX_UNUSED(islandSim);
	PX_ASSERT(edge.mLinks.mNextIslandEdge == IG_INVALID_EDGE && edge.mLinks.mPrevIslandEdge == IG_INVALID_EDGE);

	if(islandEdges.mLastEdge[edge.mEdgeType] != IG_INVALID_EDGE)
	{
		PX_ASSERT(edges[islandEdges.mLastEdge[edge.mEdgeType]].mLinks.mNextIslandEdge == IG_INVALID_EDGE);
		edges[islandEdges.mLastEdge[edge.mEdgeType]].mLinks.mNextIslandEdge = edgeIndex;
	}
	else
	{
		PX_ASSERT(islandEdges.mFirstEdge[edge.mEdgeType] == IG_INVALID_EDGE);
		islandEdges.mFirstEdge[edge.mEdgeType] = edgeIndex;
	}

	edge.mLinks.mPrevIslandEdge = islandEdges.mLastEdge[edge.mEdgeType];
	islandEdges.mLastEdge[edge.mEdgeType] = edgeIndex;
	islandEdges.mEdgeCount[edge.mEdgeType]++;
#endif
}

static PX_FORCE_INLINE void removeEdgeFromIsland(Cm::BlockArray<Edge>& edges, IslandEdgesData_Island& islandEdges, EdgeIndex edgeIndex)
{
	Edge& edge = edges[edgeIndex];

#if IG_STORE_ISLAND_EDGES_IN_ARRAYS
	PxArray<IslandEdgesData_Island::EdgeData>& edgeArray = islandEdges.mEdges[edge.mEdgeType];

	const PxU32 index = edge.mLinks.mIndex;
	PX_ASSERT(index != IG_INVALID_EDGE);
	PX_ASSERT(edgeArray[index].mIndex == edgeIndex);
	edge.mLinks.mIndex = IG_INVALID_EDGE;

	const PxU32 lastPos = edgeArray.size() - 1;
	if(lastPos != index)
	{
		edgeArray.replaceWithLast(index);

		const EdgeIndex movedEdgeIndex = edgeArray[index].mIndex;
		Edge& movedEdge = edges[movedEdgeIndex];
		PX_ASSERT(movedEdge.mLinks.mIndex == lastPos);
		movedEdge.mLinks.mIndex = index;
	}
	else
		edgeArray.forceSize_Unsafe(lastPos);
#else
	if(edge.mLinks.mNextIslandEdge != IG_INVALID_EDGE)
	{
		PX_ASSERT(edges[edge.mLinks.mNextIslandEdge].mLinks.mPrevIslandEdge == edgeIndex);
		edges[edge.mLinks.mNextIslandEdge].mLinks.mPrevIslandEdge = edge.mLinks.mPrevIslandEdge;
	}
	else
	{
		PX_ASSERT(islandEdges.mLastEdge[edge.mEdgeType] == edgeIndex);
		islandEdges.mLastEdge[edge.mEdgeType] = edge.mLinks.mPrevIslandEdge;
	}

	if(edge.mLinks.mPrevIslandEdge != IG_INVALID_EDGE)
	{
		PX_ASSERT(edges[edge.mLinks.mPrevIslandEdge].mLinks.mNextIslandEdge == edgeIndex);
		edges[edge.mLinks.mPrevIslandEdge].mLinks.mNextIslandEdge = edge.mLinks.mNextIslandEdge;
	}
	else
	{
		PX_ASSERT(islandEdges.mFirstEdge[edge.mEdgeType] == edgeIndex);
		islandEdges.mFirstEdge[edge.mEdgeType] = edge.mLinks.mNextIslandEdge;
	}

	islandEdges.mEdgeCount[edge.mEdgeType]--;
	edge.mLinks.mNextIslandEdge = edge.mLinks.mPrevIslandEdge = IG_INVALID_EDGE;
#endif
}

static void mergeEdges(Cm::BlockArray<Edge>& edges, IslandEdgesData_Island& islandEdges0, IslandEdgesData_Island& islandEdges1, Edge::EdgeType a)
{
#if IG_STORE_ISLAND_EDGES_IN_ARRAYS
	PxArray<IslandEdgesData_Island::EdgeData>& edgeArray1 = islandEdges1.mEdges[a];

	const PxU32 nbEdges1 = edgeArray1.size();
	if(nbEdges1)
	{
		PxArray<IslandEdgesData_Island::EdgeData>& edgeArray0 = islandEdges0.mEdges[a];
		PxU32 offset = edgeArray0.size();
		for(PxU32 i=0;i<nbEdges1;i++)
		{
			const IslandEdgesData_Island::EdgeData edgeIndex = edgeArray1[i];

			edges[edgeIndex.mIndex].mLinks.mIndex = offset++;

			edgeArray0.pushBack(edgeIndex);
		}
	}
	edgeArray1.resetOrClear();
#else
	if(islandEdges0.mLastEdge[a] != IG_INVALID_EDGE)
	{
		PX_ASSERT(edges[islandEdges0.mLastEdge[a]].mLinks.mNextIslandEdge == IG_INVALID_EDGE);
		edges[islandEdges0.mLastEdge[a]].mLinks.mNextIslandEdge = islandEdges1.mFirstEdge[a];
	}
	else
	{
		PX_ASSERT(islandEdges0.mFirstEdge[a] == IG_INVALID_EDGE);
		islandEdges0.mFirstEdge[a] = islandEdges1.mFirstEdge[a];
	}
	if(islandEdges1.mFirstEdge[a] != IG_INVALID_EDGE)
	{
		PX_ASSERT(edges[islandEdges1.mFirstEdge[a]].mLinks.mPrevIslandEdge == IG_INVALID_EDGE);
		edges[islandEdges1.mFirstEdge[a]].mLinks.mPrevIslandEdge = islandEdges0.mLastEdge[a];
		islandEdges0.mLastEdge[a] = islandEdges1.mLastEdge[a];
	}

	islandEdges0.mEdgeCount[a] += islandEdges1.mEdgeCount[a];
	islandEdges1.mFirstEdge[a] = IG_INVALID_EDGE;
	islandEdges1.mLastEdge[a] = IG_INVALID_EDGE;
	islandEdges1.mEdgeCount[a] = 0;
#endif
}

static void splitEdges(const IslandSim& islandSim, Cm::BlockArray<Edge>& edges, PxArray<EdgeIndex>& splitEdges, IslandEdgesData_Island& islandEdges, Edge::EdgeType j)
{
	const PxU32 splitEdgeSize = splitEdges.size();
	if(splitEdgeSize)
	{
#if IG_STORE_ISLAND_EDGES_IN_ARRAYS
		PxArray<IslandEdgesData_Island::EdgeData>& edgeArray = islandEdges.mEdges[j];
		PX_ASSERT(edgeArray.size()==0);
		PxU32 offset = edgeArray.size();

		for (PxU32 a = 0; a < splitEdgeSize; ++a)
		{
			const EdgeIndex edgeIndex = splitEdges[a];

			edges[edgeIndex].mLinks.mIndex = offset++;

			IslandEdgesData_Island::EdgeData data;
	#if IG_CACHE_CONTACT_MANAGER_DATA
			cacheContactManagerData(data, islandSim, edgeIndex, j);
	#endif
			data.mIndex = edgeIndex;

			edgeArray.pushBack(data);
		}
#else
		PX_UNUSED(islandSim);

		splitEdges.pushBack(IG_INVALID_EDGE); //Push in a dummy invalid edge to complete the connectivity
		edges[splitEdges[0]].mLinks.mNextIslandEdge = splitEdges[1];
		for (PxU32 a = 1; a < splitEdgeSize; ++a)
		{
			const EdgeIndex edgeIndex = splitEdges[a];
			Edge& edge = edges[edgeIndex];
			edge.mLinks.mNextIslandEdge = splitEdges[a + 1];
			edge.mLinks.mPrevIslandEdge = splitEdges[a - 1];
		}

		islandEdges.mFirstEdge[j] = splitEdges[0];
		islandEdges.mLastEdge[j] = splitEdges[splitEdgeSize - 1];
		islandEdges.mEdgeCount[j] = splitEdgeSize;
#endif
	}
}

static PX_FORCE_INLINE void invalidateEdges(IslandEdgesData_Island& islandEdges, Edge::EdgeType a)
{
#if IG_STORE_ISLAND_EDGES_IN_ARRAYS
	islandEdges.mEdges[a].resetOrClear();
#else
	islandEdges.mFirstEdge[a] = islandEdges.mLastEdge[a] = IG_INVALID_EDGE;
	islandEdges.mEdgeCount[a] = 0;
#endif
}

///////////////////////////////////////////////////////////////////////////////

IslandSim::IslandSim(const CPUExternalData& cpuData, GPUExternalData* gpuData, PxU64 contextID) :
	mNodes					("IslandSim::mNodes"),
	mActiveNodeIndex		("IslandSim::mActiveNodeIndex"),
	mHopCounts				("IslandSim::mHopCounts"),
	mFastRoute				("IslandSim::mFastRoute"),
	mIslandIds				("IslandSim::mIslandIds"),
	mIslands				("IslandSim::mIslands"),
	mIslandStaticTouchCount	("IslandSim.activeStaticTouchCount"),
	mActiveKinematicNodes	("IslandSim::mActiveKinematicNodes"),
	mActiveIslands			("IslandSim::mActiveIslands"),
#if IG_LIMIT_DIRTY_NODES
	mLastMapIndex			(0),
#endif
	mActivatingNodes		("IslandSim::mActivatingNodes"),
	mDestroyedEdges			("IslandSim::mDestroyedEdges"),
	mVisitedNodes			("IslandSim::mVisitedNodes"),
	mCpuData				(cpuData),
	mGpuData				(gpuData),
	mContextId				(contextID)
{
    mRestoreHostConnectivity=[](IslandSim& sim){sim.restoreHostConnectivityImpl();};
    mBuildIndependentPreSolveAudit=[](const IslandSim& sim,PxArray<PxU32>& labels,PxArray<PxU32>& touches){
        return sim.buildIndependentPreSolveAuditImpl(labels,touches);
    };
	for (PxU32 i = 0; i < Edge::eEDGE_TYPE_COUNT; ++i)
	{
		mInitialActiveNodeCount[i] = 0;
		mActiveEdgeCount[i] = 0;
	}
}

#if PX_ENABLE_ASSERTS
template <typename Thing>
static bool contains(PxArray<Thing>& arr, const Thing& thing)
{
	for(PxU32 a = 0; a < arr.size(); ++a)
	{
		if(thing == arr[a])
			return true;
	}
	return false;
}
#endif

void IslandSim::addNode(bool isActive, bool isKinematic, Node::NodeType type, PxNodeIndex nodeIndex, void* object)
{
	// PT: the nodeIndex is assigned by the SimpleIslandManager one level higher.
	const PxU32 handle = nodeIndex.index();
	{
		if(handle == mNodes.capacity())
		{
			const PxU32 newCapacity = PxMax(2*mNodes.capacity(), 256u);
			mNodes.reserve(newCapacity);
			mIslandIds.reserve(newCapacity);
			mFastRoute.reserve(newCapacity);
			mHopCounts.reserve(newCapacity);
			mActiveNodeIndex.reserve(newCapacity);
		}

		const PxU32 newSize = PxMax(handle+1, mNodes.size());
		mNodes.resize(newSize);
		mIslandIds.resize(newSize);
		mFastRoute.resize(newSize);
		mHopCounts.resize(newSize);
		mActiveNodeIndex.resize(newSize);
	}

	mActiveNodeIndex[handle] = PX_INVALID_NODE;

	Node& node = mNodes[handle];
	node.mType = PxTo8(type);
	//Ensure that the node is not currently being used.
	PX_ASSERT(node.isDeleted());

	PxU8 flags = PxU8(isActive ? 0 : Node::eREADY_FOR_SLEEPING);
	if(isKinematic)
		flags |= Node::eKINEMATIC;
	node.mFlags = flags;
	noteReadiness(handle, !isActive);
    if(mGpuData){
        // Fragment registration can append thousands of nodes in one tick.
        // resize reserves exactly its argument; reuse the node storage capacity
        // so lifetime history is not reallocated/copied for every new fragment.
        // Active size, zero initialization and generation increments are unchanged.
        mPreSolveLifetimes.reserve(mNodes.capacity());
        mPreSolveLifetimes.resize(PxMax(handle+1,mPreSolveLifetimes.size()),0);
        ++mPreSolveLifetimes[handle];
    }
    markPreSolveNode(handle);
	writeIslandId(handle) = IG_INVALID_ISLAND;
	mFastRoute[handle].setIndices(PX_INVALID_NODE);
	mHopCounts[handle] = 0;

	if(!isKinematic)
	{
		const IslandId islandHandle = mIslandHandles.getHandle();
		
		if(islandHandle == mIslands.capacity())
		{
			const PxU32 newCapacity = PxMax(2*mIslands.capacity(), 256u);
			mIslands.reserve(newCapacity);
			mIslandAwake.resize(newCapacity);
			mIslandStaticTouchCount.reserve(newCapacity);
		}
		const PxU32 newSize = PxMax(islandHandle+1, mIslands.size());
		mIslands.resize(newSize);
		mIslandStaticTouchCount.resize(newSize);
		mIslandAwake.growAndReset(newSize);

		Island& island = mIslands[islandHandle];
		island.mLastNode = island.mRootNode = nodeIndex;
		island.mNodeCount[type] = 1;
		writeIslandId(handle) = islandHandle;
		writeIslandStaticTouchCount(islandHandle) = 0;
	}

	if(isActive)
		activateNode(nodeIndex);

	node.mObject = object;
}

// PT: preallocateConnections() and addConnectionPreallocated() are used to replicate IslandSim::addConnection() multi-threaded
void IslandSim::preallocateConnections(EdgeIndex handle)
{
	if(handle >= mEdges.capacity())
	{
		PX_PROFILE_ZONE("ReserveIslandEdges", mContextId);
		const PxU32 newSize = handle + 2048;
		mEdges.reserve(newSize);
		if(mGpuData)
			mGpuData->mActiveContactEdges.resize(mEdges.capacity());
	}
	mEdges.resize(PxMax(mEdges.size(), handle+1));
	if(mGpuData)
		mGpuData->mActiveContactEdges.reset(handle);
}

bool IslandSim::addConnectionPreallocated(PxNodeIndex nodeHandle1, PxNodeIndex nodeHandle2, Edge::EdgeType edgeType, EdgeIndex handle)
{
	// PT: the EdgeIndex is assigned by the SimpleIslandManager one level higher.

	PX_UNUSED(nodeHandle1);
	PX_UNUSED(nodeHandle2);
	Edge& edge = mEdges[handle];

	if(edge.isPendingDestroyed())
	{
		//If it's in this state, then the edge has been tagged for destruction but actually is now not needed to be destroyed
		edge.clearPendingDestroyed();
		return false;
	}

	if(edge.isInDirtyList())
	{
		PX_ASSERT(mCpuData.mEdgeNodeIndices[handle * 2].index() == nodeHandle1.index());
		PX_ASSERT(mCpuData.mEdgeNodeIndices[handle * 2 + 1].index() == nodeHandle2.index());
		PX_ASSERT(edge.mEdgeType == edgeType);
		return false;
	}

	PX_ASSERT(!edge.isInserted());

	PX_ASSERT(edge.isDestroyed());
	edge.clearDestroyed();

#if IG_STORE_ISLAND_EDGES_IN_ARRAYS
#else
	PX_ASSERT(edge.mLinks.mNextIslandEdge == IG_INVALID_EDGE);
	PX_ASSERT(edge.mLinks.mPrevIslandEdge == IG_INVALID_EDGE);
#endif
	PX_ASSERT(mEdgeInstances.size() <= 2*handle || mEdgeInstances[2*handle].mNextEdge == IG_INVALID_EDGE);
	PX_ASSERT(mEdgeInstances.size() <= 2*handle || mEdgeInstances[2*handle+1].mNextEdge == IG_INVALID_EDGE);
	PX_ASSERT(mEdgeInstances.size() <= 2*handle || mEdgeInstances[2*handle].mPrevEdge == IG_INVALID_EDGE);
	PX_ASSERT(mEdgeInstances.size() <= 2*handle || mEdgeInstances[2*handle+1].mPrevEdge == IG_INVALID_EDGE);

	edge.mEdgeType = PxTo16(edgeType);

	PX_ASSERT(handle*2 >= mEdgeInstances.size() || mEdgeInstances[handle*2].mNextEdge == IG_INVALID_EDGE);
	PX_ASSERT(handle*2+1 >= mEdgeInstances.size() || mEdgeInstances[handle*2+1].mNextEdge == IG_INVALID_EDGE);
	PX_ASSERT(handle*2 >= mEdgeInstances.size() || mEdgeInstances[handle*2].mPrevEdge == IG_INVALID_EDGE);
	PX_ASSERT(handle*2+1 >= mEdgeInstances.size() || mEdgeInstances[handle*2+1].mPrevEdge == IG_INVALID_EDGE);
	
	//Add the new handle
	PX_ASSERT(!edge.isInDirtyList());	// PT: otherwise it should have exited the function above
	PX_ASSERT(!contains(mDirtyEdges[edgeType], handle));
	// PT: TODO: we could push back to an array MT but that would break determinism
	//mDirtyEdges[edgeType].pushBack(handle);
	edge.markInDirtyList();

	edge.mEdgeState &= ~(Edge::eACTIVATING);
	return true;
}

void IslandSim::addConnection(PxNodeIndex nodeHandle1, PxNodeIndex nodeHandle2, Edge::EdgeType edgeType, EdgeIndex handle)
{
	// PT: the EdgeIndex is assigned by the SimpleIslandManager one level higher.

	preallocateConnections(handle);

	if(addConnectionPreallocated(nodeHandle1, nodeHandle2, edgeType, handle))
		mDirtyEdges[edgeType].pushBack(handle);
}

// PT: last part of IslandSim::addConnection, not MT in IslandSim::addConnectionPreallocated
void IslandSim::addDelayedDirtyEdges(PxU32 nbHandles, const EdgeIndex* handles)
{
	// PT: TODO: better version
	while(nbHandles--)
	{
		const EdgeIndex h = *handles++;
		const Edge& edge = mEdges[h];
		mDirtyEdges[edge.mEdgeType].pushBack(h);
	}
}

void IslandSim::addConnectionToGraph(EdgeIndex handle)
{
	const EdgeInstanceIndex instanceHandle = 2*handle;
	PX_ASSERT(instanceHandle < mEdgeInstances.capacity());
	/*if(instanceHandle == mEdgeInstances.capacity())
	{
		mEdgeInstances.reserve(2*mEdgeInstances.capacity() + 2);
	}*/
	mEdgeInstances.resize(PxMax(instanceHandle+2, mEdgeInstances.size()));

	Edge& edge = mEdges[handle];
	
	// PT: TODO: int bools
	PxIntBool activeEdge = false;
	bool kinematicKinematicEdge = true;

	const PxNodeIndex nodeIndex1 = mCpuData.mEdgeNodeIndices[instanceHandle];
	const PxNodeIndex nodeIndex2 = mCpuData.mEdgeNodeIndices[instanceHandle+1];

	struct Local
	{
		static PX_FORCE_INLINE void connectEdge(Cm::BlockArray<EdgeInstance>& edgeInstances, EdgeInstanceIndex edgeIndex, Node& source)
		{
			EdgeInstance& instance = edgeInstances[edgeIndex];

			PX_ASSERT(instance.mNextEdge == IG_INVALID_EDGE);
			PX_ASSERT(instance.mPrevEdge == IG_INVALID_EDGE);

			instance.mNextEdge = source.mFirstEdgeIndex;
			if(source.mFirstEdgeIndex != IG_INVALID_EDGE)
			{
				EdgeInstance& firstEdge = edgeInstances[source.mFirstEdgeIndex];
				firstEdge.mPrevEdge = edgeIndex;
			}

			source.mFirstEdgeIndex = edgeIndex;
			instance.mPrevEdge = IG_INVALID_EDGE;
		}
	};

	const PxU32 index1 = nodeIndex1.index();
	if(index1 != PX_INVALID_NODE)
	{
		Node& node = mNodes[index1];
		Local::connectEdge(mEdgeInstances, instanceHandle, node);
		activeEdge = node.isActiveOrActivating();
		kinematicKinematicEdge = node.isKinematic();
	}

	const PxU32 index2 = nodeIndex2.index();
	if(index1 != index2 && index2 != PX_INVALID_NODE)
	{
		Node& node = mNodes[index2];
		Local::connectEdge(mEdgeInstances, instanceHandle + 1, node);
		activeEdge |= node.isActiveOrActivating();
		kinematicKinematicEdge = kinematicKinematicEdge && node.isKinematic();
	}

	if(activeEdge && (!kinematicKinematicEdge || edge.getEdgeType() == IG::Edge::eCONTACT_MANAGER))
	{
		markEdgeActive(handle, nodeIndex1, nodeIndex2);
		edge.activateEdge();
	}
}

void IslandSim::removeConnectionFromGraph(EdgeIndex edgeIndex)
{
	const PxNodeIndex nodeIndex1 = mCpuData.mEdgeNodeIndices[2 * edgeIndex];
	const PxNodeIndex nodeIndex2 = mCpuData.mEdgeNodeIndices[2 * edgeIndex + 1];

	const PxU32 index1 = nodeIndex1.index();
	const PxU32 index2 = nodeIndex2.index();

	if (index1 != PX_INVALID_NODE)
	{
		Node& node = mNodes[index1];
		if (index2 == mFastRoute[index1].index())
			mFastRoute[index1].setIndices(PX_INVALID_NODE);
		if(!node.isDirty())
		{
			//mDirtyNodes.pushBack(nodeIndex1);
			mDirtyMap.growAndSet(index1);
			node.markDirty();
		}
	}

	if (index2 != PX_INVALID_NODE)
	{
		Node& node = mNodes[index2];
		if (index1 == mFastRoute[index2].index())
			mFastRoute[index2].setIndices(PX_INVALID_NODE);
		if(!node.isDirty())
		{
			mDirtyMap.growAndSet(index2);
			node.markDirty();
		}
	}
}

void IslandSim::removeConnection(EdgeIndex edgeIndex)
{
	Edge& edge = mEdges[edgeIndex];
	if(!edge.isPendingDestroyed())// && edge.isInserted())
	{
		mDestroyedEdges.pushBack(edgeIndex);
		/*if(!edge.isInserted())
			edge.setReportOnlyDestroy();*/
	}
	edge.setPendingDestroyed();
}

void IslandSim::removeConnectionInternal(EdgeIndex edgeIndex)
{
	PX_ASSERT(edgeIndex != IG_INVALID_EDGE);
	const EdgeInstanceIndex edgeInstanceBase = edgeIndex*2;
	const PxNodeIndex nodeIndex1 = mCpuData.mEdgeNodeIndices[edgeIndex * 2];
	const PxNodeIndex nodeIndex2 = mCpuData.mEdgeNodeIndices[edgeIndex * 2 + 1];

	struct Local
	{
		static void disconnectEdge(Cm::BlockArray<EdgeInstance>& edgeInstances, EdgeInstanceIndex edgeIndex, Node& node)
		{
			EdgeInstance& instance = edgeInstances[edgeIndex];

			PX_ASSERT(instance.mNextEdge == IG_INVALID_EDGE || edgeInstances[instance.mNextEdge].mPrevEdge == edgeIndex);
			PX_ASSERT(instance.mPrevEdge == IG_INVALID_EDGE || edgeInstances[instance.mPrevEdge].mNextEdge == edgeIndex);

			if(node.mFirstEdgeIndex == edgeIndex)
			{
				PX_ASSERT(instance.mPrevEdge == IG_INVALID_EDGE);
				node.mFirstEdgeIndex = instance.mNextEdge;
			}
			else
			{
				EdgeInstance& prev = edgeInstances[instance.mPrevEdge];
				PX_ASSERT(prev.mNextEdge == edgeIndex);
				prev.mNextEdge = instance.mNextEdge;
			}

			if(instance.mNextEdge != IG_INVALID_EDGE)
			{
				EdgeInstance& next = edgeInstances[instance.mNextEdge];
				PX_ASSERT(next.mPrevEdge == edgeIndex);
				next.mPrevEdge = instance.mPrevEdge;
			}

			PX_ASSERT(instance.mNextEdge == IG_INVALID_EDGE || edgeInstances[instance.mNextEdge].mPrevEdge == instance.mPrevEdge);
			PX_ASSERT(instance.mPrevEdge == IG_INVALID_EDGE || edgeInstances[instance.mPrevEdge].mNextEdge == instance.mNextEdge);

			instance.mNextEdge = IG_INVALID_EDGE;
			instance.mPrevEdge = IG_INVALID_EDGE;
		}
	};

	const PxU32 index1 = nodeIndex1.index();
	const PxU32 index2 = nodeIndex2.index();

	if (index1 != PX_INVALID_NODE)
		Local::disconnectEdge(mEdgeInstances, edgeInstanceBase, mNodes[index1]);

	if (index2 != PX_INVALID_NODE && index1 != index2)
		Local::disconnectEdge(mEdgeInstances, edgeInstanceBase + 1, mNodes[index2]);
}

void IslandSim::activateNode(PxNodeIndex nodeIndex)
{
	const PxU32 index = nodeIndex.index();
	if(index != PX_INVALID_NODE)
	{
		Node& node = mNodes[index];

		if(!node.isActiveOrActivating())
		{
			//If the node is kinematic and already in the active node list, then we need to remove it
			//from the active kinematic node list, then re-add it after the wake-up. It's a bit dumb
			//but it means that we don't need another index

			if(node.isKinematic() && mActiveNodeIndex[index] != PX_INVALID_NODE)
			{
				//node.setActive();
				//node.clearIsReadyForSleeping(); //Clear the "isReadyForSleeping" flag. Just in case it was set
				//return;

				const PxU32 activeRefCount = node.mActiveRefCount;
				node.mActiveRefCount = 0;
				node.clearActive();
				markKinematicInactive(nodeIndex);
				node.mActiveRefCount = activeRefCount;
			}
			
			node.setActivating(); //Tag it as activating
			PX_ASSERT(mActiveNodeIndex[index] == PX_INVALID_NODE);
			mActiveNodeIndex[index] = mActivatingNodes.size();	
			//Add to waking list
			mActivatingNodes.pushBack(nodeIndex);
		}
		node.clearIsReadyForSleeping(); //Clear the "isReadyForSleeping" flag. Just in case it was set
		noteReadiness(index, false);
		noteNodeWoken(index);
	}
}

void IslandSim::deactivateNode(PxNodeIndex nodeIndex)
{
	const PxU32 index = nodeIndex.index();
	if(index != PX_INVALID_NODE)
	{
		Node& node = mNodes[index];

		//If the node is activating, clear its activating state and remove it from the activating list. 
		//If it wasn't already activating, then it's probably already in the active list

		const PxIntBool wasActivating = node.isActivating();

		if(wasActivating)
		{
			//Already activating, so remove it from the activating list
			node.clearActivating();
			PX_ASSERT(mActivatingNodes[mActiveNodeIndex[index]].index() == index);
			const PxNodeIndex replaceIndex = mActivatingNodes[mActivatingNodes.size()-1];
			mActiveNodeIndex[replaceIndex.index()] = mActiveNodeIndex[index];
			mActivatingNodes[mActiveNodeIndex[index]] = replaceIndex;
			mActivatingNodes.forceSize_Unsafe(mActivatingNodes.size()-1);
			mActiveNodeIndex[index] = PX_INVALID_NODE;

			if(node.isKinematic())
			{
				//If we were temporarily removed from the active kinematic list to be put in the waking kinematic list
				//then add the node back in before deactivating the node. This is a bit counter-intuitive but the active
				//kinematic list contains all active kinematics and all kinematics that are referenced by an active constraint
				PX_ASSERT(mActiveNodeIndex[index] == PX_INVALID_NODE);
				mActiveNodeIndex[index] = mActiveKinematicNodes.size();
				mActiveKinematicNodes.pushBack(nodeIndex);
			}
		}

		//Raise the "ready for sleeping" flag so that island gen can put this node to sleep
		node.setIsReadyForSleeping();
		noteReadiness(index, true);
	}
}

void IslandSim::putNodeToSleep(PxNodeIndex nodeIndex)
{
	if(nodeIndex.index() != PX_INVALID_NODE)
		deactivateNode(nodeIndex);
}

PX_FORCE_INLINE void IslandSim::makeEdgeActive(EdgeInstanceIndex index, bool testEdgeType)
{
	const EdgeIndex idx = index / 2;
	Edge& edge = mEdges[idx];
	if (!edge.isActive() && (!testEdgeType || (edge.getEdgeType() != IG::Edge::eCONSTRAINT)))
	{
		//Make the edge active...
		const PxNodeIndex nodeIndex1 = mCpuData.mEdgeNodeIndices[idx * 2];
		const PxNodeIndex nodeIndex2 = mCpuData.mEdgeNodeIndices[idx * 2 + 1];

		PX_ASSERT(nodeIndex1.index() == PX_INVALID_NODE || !mNodes[nodeIndex1.index()].isActive() || mNodes[nodeIndex1.index()].isKinematic());
		PX_ASSERT(nodeIndex2.index() == PX_INVALID_NODE || !mNodes[nodeIndex2.index()].isActive() || mNodes[nodeIndex2.index()].isKinematic());

		markEdgeActive(idx, nodeIndex1, nodeIndex2);
		edge.activateEdge();
	}
}

void IslandSim::activateNodeInternal(PxNodeIndex nodeIndex)
{
	//This method should activate the node, then activate all the connections involving this node
	Node& node = mNodes[nodeIndex.index()];

	if(!node.isActive())
	{
		PX_ASSERT(mActiveNodeIndex[nodeIndex.index()] == PX_INVALID_NODE);

		//Activate all the edges + nodes...

		EdgeInstanceIndex index = node.mFirstEdgeIndex;

		while(index != IG_INVALID_EDGE)
		{
			makeEdgeActive(index, false);

			index = mEdgeInstances[index].mNextEdge;
		}

		if(node.isKinematic())
			markKinematicActive(nodeIndex);
		else
			markActive(nodeIndex);

		node.setActive();
	}
}

void IslandSim::deactivateNodeInternal(PxNodeIndex nodeIndex)
{
	//We deactivate a node, we need to loop through all the edges and deactivate them *if* both bodies are asleep

	Node& node = mNodes[nodeIndex.index()];

	if(node.isActive())
	{
		if(node.isKinematic())
			markKinematicInactive(nodeIndex);
		else
			markInactive(nodeIndex);

		//Clear the active status flag
		node.clearActive();
		node.clearActivating();

		EdgeInstanceIndex index = node.mFirstEdgeIndex;

		while(index != IG_INVALID_EDGE)
		{
			const EdgeInstance& instance = mEdgeInstances[index];

			const PxNodeIndex outboundNode = mCpuData.mEdgeNodeIndices[index ^ 1];
			if(outboundNode.index() == PX_INVALID_NODE || 
				!mNodes[outboundNode.index()].isActive())
			{
				const EdgeIndex idx = index/2;
				Edge& edge = mEdges[idx]; //InstanceIndex/2 = edgeIndex
				//PX_ASSERT(edge.isActive()); //The edge must currently be inactive because the node was active
				//Deactivate the edge if both nodes connected are inactive OR if one node is static/kinematic and the other is inactive...
				PX_ASSERT(mCpuData.mEdgeNodeIndices[index & (~1)].index() == PX_INVALID_NODE || !mNodes[mCpuData.mEdgeNodeIndices[index & (~1)].index()].isActive());
				PX_ASSERT(mCpuData.mEdgeNodeIndices[index | 1].index() == PX_INVALID_NODE || !mNodes[mCpuData.mEdgeNodeIndices[index | 1].index()].isActive());
				if(edge.isActive())
				{
					edge.deactivateEdge();
					mActiveEdgeCount[edge.mEdgeType]--;
					removeEdgeFromActivatingList(idx);
					mDeactivatingEdges[edge.mEdgeType].pushBack(idx);
				}
			}
			index = instance.mNextEdge;
		}
	}
}

#if IG_SANITY_CHECKS
bool IslandSim::canFindRoot(PxNodeIndex startNode, PxNodeIndex targetNode, PxArray<PxNodeIndex>* visitedNodes)
{
	if(visitedNodes)
		visitedNodes->pushBack(startNode);
	if(startNode.index() == targetNode.index())
		return true;
	PxBitMap visitedState;
	visitedState.resizeAndClear(mNodes.size());

	PxArray<PxNodeIndex> stack;

	stack.pushBack(startNode);

	visitedState.set(startNode.index());

	do
	{
		const PxNodeIndex currentIndex = stack.popBack();
		const Node& currentNode = mNodes[currentIndex.index()];

		EdgeInstanceIndex currentEdge = currentNode.mFirstEdgeIndex;

		while(currentEdge != IG_INVALID_EDGE)
		{
			const EdgeInstance& edge = mEdgeInstances[currentEdge];
			const PxNodeIndex outboundNode = mCpuData.mEdgeNodeIndices[currentEdge ^ 1];
			if(outboundNode.index() != PX_INVALID_NODE && !mNodes[outboundNode.index()].isKinematic() && !visitedState.test(outboundNode.index()))
			{
				if(outboundNode.index() == targetNode.index())
					return true;

				visitedState.set(outboundNode.index());
				stack.pushBack(outboundNode);
				if(visitedNodes)
					visitedNodes->pushBack(outboundNode);
			}

			currentEdge = edge.mNextEdge;
		}
	}
	while(stack.size());

	return false;
}
#endif

void IslandSim::unwindRoute(PxU32 traversalIndex, PxNodeIndex lastNode, PxU32 hopCount, IslandId id)
{
	//We have found either a witness *or* the root node with this traversal. In the event of finding the root node, hopCount will be 0. In the event of finding
	//a witness, hopCount will be the hopCount that witness reported as being the distance to the root.

	PxU32 currIndex = traversalIndex;
	PxU32 hc = hopCount+1; //Add on 1 for the hop to the witness/root node.
	const TraversalState*  PX_RESTRICT visitedNodes = mVisitedNodes.begin();
	PxU32* PX_RESTRICT hopCounts = mHopCounts.begin();
	PxNodeIndex* PX_RESTRICT fastRoute = mFastRoute.begin();

	do
	{
		const TraversalState& state = visitedNodes[currIndex];
		const PxU32 stateIndex = state.mNodeIndex.index();
		hopCounts[stateIndex] = hc++;
		writeIslandId(stateIndex) = id;
		fastRoute[stateIndex] = lastNode;
		currIndex = state.mPrevIndex;
		lastNode = state.mNodeIndex;
	}
	while(currIndex != PX_INVALID_NODE);
}

void IslandSim::activateIslandInternal(const Island& island)
{
	PxNodeIndex currentNode = island.mRootNode;
	while(currentNode.index() != PX_INVALID_NODE)
	{
		activateNodeInternal(currentNode);
		currentNode = mNodes[currentNode.index()].mNextNode;
	}
}

void IslandSim::activateIsland(IslandId islandId)
{
	Island& island = mIslands[islandId];
	PX_ASSERT(!mIslandAwake.test(islandId));
	PX_ASSERT(island.mActiveIndex == IG_INVALID_ISLAND);
	
	activateIslandInternal(island);

	markIslandActive(islandId);
}

static PxU32 gParkRejectReason[8] = {0,0,0,0,0,0,0,0};
PxU32 physx::IG::parkRejectReason(PxU32 i) { return i < 8 ? gParkRejectReason[i] : 0; }
bool IslandSim::parkIslandForPass(IslandId islandId)
{
	if(islandId >= mIslands.size()) { ++gParkRejectReason[0]; return false; }
	Island& island = mIslands[islandId];
	if(!mIslandAwake.test(islandId) || island.mActiveIndex == IG_INVALID_ISLAND) { ++gParkRejectReason[1]; return false; }
	if(island.mActiveIndex >= mActiveIslands.size() || mActiveIslands[island.mActiveIndex] != islandId) { ++gParkRejectReason[2]; return false; }
	if(island.mNodeCount[Node::eARTICULATION_TYPE]) { ++gParkRejectReason[3]; return false; }
	// Validate the whole island first: kinematic, deleted or inconsistent
	// nodes make the island unparkable (it is then re-simulated as before).
	PxNodeIndex currentNode = island.mRootNode;
	PxU32 visited = 0;
	while(currentNode.index() != PX_INVALID_NODE)
	{
		if(currentNode.index() >= mNodes.size() || ++visited > mNodes.size()) { ++gParkRejectReason[4]; return false; }
		const Node& node = mNodes[currentNode.index()];
		if(node.isKinematic() || node.isDeleted() || mIslandIds[currentNode.index()] != islandId) { ++gParkRejectReason[5]; return false; }
		const PxU32 activeIndex = mActiveNodeIndex[currentNode.index()];
		if(bool(node.isActive()) != (activeIndex != PX_INVALID_NODE)) { ++gParkRejectReason[6]; return false; }
		if(activeIndex != PX_INVALID_NODE && (activeIndex >= mActiveNodes[node.mType].size() || mActiveNodes[node.mType][activeIndex].index() != currentNode.index())) { ++gParkRejectReason[7]; return false; }
		currentNode = node.mNextNode;
	}
	// Nodes leave the active lists and drop their active flag (so that the
	// ordinary activation path re-adds them when a new touch wakes or merges
	// the island); edges keep their activity, so the partition and every
	// contact cache survive the pass.
	static const bool trace = ::getenv("PHYSX_DESTRUCTION_ISLAND_SCOPE_TRACE") != NULL;
	if(trace) fprintf(stderr, "park island %u nodes=%u root=%u activeIndex=%u activeIslands=%u\n", islandId, visited, island.mRootNode.index(), island.mActiveIndex, mActiveIslands.size());
	currentNode = island.mRootNode;
	while(currentNode.index() != PX_INVALID_NODE)
	{
		Node& node = mNodes[currentNode.index()];
		const PxNodeIndex next = node.mNextNode;
		if(trace) fprintf(stderr, "  node %u type=%u active=%d activeIndex=%u listSize=%u initial=%u\n", currentNode.index(), PxU32(node.mType), int(node.isActive()), mActiveNodeIndex[currentNode.index()], mActiveNodes[node.mType].size(), mInitialActiveNodeCount[node.mType]);
		if(mActiveNodeIndex[currentNode.index()] != PX_INVALID_NODE) markInactive(currentNode);
		if(node.isActive()) { node.clearActive(); }
		currentNode = next;
	}
	if(trace) fprintf(stderr, "  island inactive %u\n", islandId);
	markIslandInactive(islandId);
	return true;
}

PxU32 IslandSim::validateActiveLists(const char* tag) const
{
	PxU32 bad = 0;
	for(PxU32 type = 0; type < Node::eTYPE_COUNT; ++type)
	{
		const PxArray<PxNodeIndex>& list = mActiveNodes[type];
		for(PxU32 i = 0; i < list.size(); ++i)
		{
			const PxU32 node = list[i].index();
			const bool ok = node < mNodes.size() && mActiveNodeIndex[node] == i && mNodes[node].isActive();
			if(!ok)
			{
				if(bad < 4) fprintf(stderr, "active list %s: type=%u pos=%u (initial=%u size=%u) node=%u back=%u flags active=%d deleted=%d island=%u awake=%d\n", tag, type, i, mInitialActiveNodeCount[type], list.size(), node,
					node < mNodes.size() ? mActiveNodeIndex[node] : 0xffffffffu, node < mNodes.size() ? int(mNodes[node].isActive()) : -1, node < mNodes.size() ? int(mNodes[node].isDeleted()) : -1,
					node < mNodes.size() ? mIslandIds[node] : 0xffffffffu, (node < mNodes.size() && mIslandIds[node] != IG_INVALID_ISLAND && mIslandIds[node] < mIslands.size()) ? int(mIslandAwake.test(mIslandIds[node])) : -1);
				++bad;
			}
		}
	}
	if(bad) fprintf(stderr, "active list %s: %u inconsistent entries\n", tag, bad);
	return bad;
}

void IslandSim::unparkIslandForPass(IslandId islandId)
{
	if(islandId >= mIslands.size() || mIslandAwake.test(islandId)) return; // woken during the pass
	Island& island = mIslands[islandId];
	// Merged away or freed during the pass: its nodes now belong to another
	// (awake) island; the record must not be touched.
	if(island.mRootNode.index() == PX_INVALID_NODE || island.mRootNode.index() >= mNodes.size()
		|| mIslandIds[island.mRootNode.index()] != islandId) return;
	if(island.mActiveIndex != IG_INVALID_ISLAND) return;
	// Every node re-enters the active lists through the ordinary internal
	// activation (edges already active, so that part is idempotent). A node
	// that was queued for activation meanwhile (activateNode: activating
	// list, index into that list) is left to wakeIslands, which activates it
	// and the island; touching it here would strand a stale active entry.
	PxNodeIndex currentNode = island.mRootNode;
	while(currentNode.index() != PX_INVALID_NODE)
	{
		Node& node = mNodes[currentNode.index()];
		if(!node.isActiveOrActivating()) activateNodeInternal(currentNode);
		currentNode = node.mNextNode;
	}
	if(!mIslandAwake.test(islandId)) markIslandActive(islandId);
}

void IslandSim::deactivateIsland(IslandId islandId)
{
	PX_ASSERT(mIslandAwake.test(islandId));
	Island& island = mIslands[islandId];
	
	PxNodeIndex currentNode = island.mRootNode;
	while(currentNode.index() != PX_INVALID_NODE)
	{
		const Node& node = mNodes[currentNode.index()];
		
		//if(mActiveNodeIndex[currentNode.index()] < mInitialActiveNodeCount[node.mType])
		mNodesToPutToSleep[node.mType].pushBack(currentNode); //If this node was previously active, then push it to the list of nodes to deactivate
		if(!node.isReadyForSleeping()) mDeactivatedNotReady.pushBack(currentNode.index());
		deactivateNodeInternal(currentNode);
		currentNode = node.mNextNode;
	}
	markIslandInactive(islandId);
}

void IslandSim::wakeIslandsInternal(bool flag)
{
	//(1) Iterate over activating nodes and activate them

	const PxU32 originalActiveIslands = mActiveIslands.size();

	if(flag)
	{
		for (PxU32 a = 0; a < Edge::eEDGE_TYPE_COUNT; ++a)
		{
			for (PxU32 i = 0, count = mActivatedEdges[a].size(); i < count; ++i)
			{
				IG::Edge& edge = mEdges[mActivatedEdges[a][i]];
				edge.mEdgeState &= (~Edge::eACTIVATING);
			}

			mActivatedEdges[a].forceSize_Unsafe(0);
		}

		for (PxU32 a = 0; a < Edge::eEDGE_TYPE_COUNT; ++a)
		{
			mInitialActiveNodeCount[a] = mActiveNodes[a].size();
		}
	}

	for(PxU32 a = 0; a < mActivatingNodes.size(); ++a)
	{
		const PxNodeIndex wakeNode = mActivatingNodes[a];

		const IslandId islandId = mIslandIds[wakeNode.index()];

		Node& node = mNodes[wakeNode.index()];
		node.clearActivating();
		if(islandId != IG_INVALID_ISLAND)
		{
			if(!mIslandAwake.test(islandId))
				markIslandActive(islandId);						

			mActiveNodeIndex[wakeNode.index()] = PX_INVALID_NODE; //Mark active node as invalid.
			activateNodeInternal(wakeNode);
		}
		else
		{
			PX_ASSERT(node.isKinematic());
			node.setActive();
			PX_ASSERT(mActiveNodeIndex[wakeNode.index()] == a);
			mActiveNodeIndex[wakeNode.index()] = mActiveKinematicNodes.size();
			mActiveKinematicNodes.pushBack(wakeNode);

			//Wake up the islands connected to this waking kinematic!
			EdgeInstanceIndex index = node.mFirstEdgeIndex;
			while(index != IG_INVALID_EDGE)
			{
				const EdgeInstance& edgeInstance = mEdgeInstances[index];

				const PxNodeIndex outboundNode = mCpuData.mEdgeNodeIndices[index ^ 1];
				//Edge& edge = mEdges[index/2];
				//if(edge.isConnected()) //Only wake up if the edge is not connected...
				const PxNodeIndex nodeIndex = outboundNode;

				if (nodeIndex.isStaticBody() || mIslandIds[nodeIndex.index()] == IG_INVALID_ISLAND)
				{
					//If the edge connects to a static body *or* it connects to a node which is not part of an island (i.e. a kinematic), then activate the edge
					makeEdgeActive(index, true);
				}
				else
				{
					const IslandId connectedIslandId = mIslandIds[nodeIndex.index()];
					if(!mIslandAwake.test(connectedIslandId))
					{
						//Wake up that island
						markIslandActive(connectedIslandId);
					}
				}

				index = edgeInstance.mNextEdge;
			}
		}
	}

	mActivatingNodes.forceSize_Unsafe(0);

	for(PxU32 a = originalActiveIslands; a < mActiveIslands.size(); ++a)
		activateIslandInternal(mIslands[mActiveIslands[a]]);
}

void IslandSim::wakeIslands()
{
	PX_PROFILE_ZONE("Basic.wakeIslands", mContextId);
	wakeIslandsInternal(true);
}

void IslandSim::wakeIslands2()
{
	PX_PROFILE_ZONE("Basic.wakeIslands2", mContextId);
	wakeIslandsInternal(false);
}

void IslandSim::insertNewEdges()
{
	PX_PROFILE_ZONE("Basic.insertNewEdges", mContextId);

	mEdgeInstances.reserve(mEdges.capacity()*2);
	
	for(PxU32 i = 0; i < Edge::eEDGE_TYPE_COUNT; ++i)
	{
		for(PxU32 a = 0; a < mDirtyEdges[i].size(); ++a)
		{
			const EdgeIndex edgeIndex = mDirtyEdges[i][a];

			Edge& edge = mEdges[edgeIndex];

			if(!edge.isPendingDestroyed())
			{
				//PX_ASSERT(!edge.isInserted());
				if(!edge.isInserted())
				{
					addConnectionToGraph(edgeIndex);
					edge.setInserted();
				}
			}
		}
	}
}

void IslandSim::removeDestroyedEdges()
{
	PX_PROFILE_ZONE("Basic.removeDestroyedEdges", mContextId);

	for(PxU32 a = 0; a < mDestroyedEdges.size(); ++a)
	{
		const EdgeIndex edgeIndex = mDestroyedEdges[a];

		const Edge& edge = mEdges[edgeIndex];
		
		if(edge.isPendingDestroyed())
		{
			if(!edge.isInDirtyList() && edge.isInserted())
			{
				removeConnectionInternal(edgeIndex);
				removeConnectionFromGraph(edgeIndex);
				//edge.clearInserted();
			}
			//edge.clearDestroyed();
		}
	}
}

IslandId IslandSim::addNodeToIsland(PxNodeIndex nodeIndex1, PxNodeIndex nodeIndex2, IslandId islandId2, bool active1, bool active2)
{
	PX_ASSERT(islandId2 != IG_INVALID_ISLAND);

	const PxU32 index1 = nodeIndex1.index();

	if (index1 != PX_INVALID_NODE)
	{
		if (!mNodes[index1].isKinematic())
		{
			//We need to add node 1 to island2
			Island& island = mIslands[islandId2];
			PX_ASSERT(mNodes[index1].mNextNode.index() == PX_INVALID_NODE); //Ensure that this node is not in any other island
			PX_ASSERT(mNodes[index1].mPrevNode.index() == PX_INVALID_NODE); //Ensure that this node is not in any other island
							
			Node& lastNode = mNodes[island.mLastNode.index()];

			PX_ASSERT(lastNode.mNextNode.index() == PX_INVALID_NODE);

			Node& node = mNodes[index1];
			lastNode.mNextNode = nodeIndex1;
			node.mPrevNode = island.mLastNode;
			island.mLastNode = nodeIndex1;
			island.mNodeCount[node.mType]++;
			writeIslandId(index1) = islandId2;
			mHopCounts[index1] = mHopCounts[nodeIndex2.index()] + 1;
			mFastRoute[index1] = nodeIndex2;

			if(active1 || active2)
			{
				if(!mIslandAwake.test(islandId2))
				{
					//This island wasn't already awake, so need to wake the whole island up
					activateIsland(islandId2);
				}
				if(!active1)
				{
					//Wake up this node...
					activateNodeInternal(nodeIndex1);
				}
			}
		}
		else if(active1 && !active2)
		{
			//Active kinematic object -> wake island!
			activateIsland(islandId2);
		}
	}
	else
	{
		//A new touch with a static body...
		Node& node = mNodes[nodeIndex2.index()];
		node.mStaticTouchCount++; //Increment static touch counter on the body
        markPreSolveSupport(nodeIndex2.index());
		//Island& island = mIslands[islandId2];
		//island.mStaticTouchCount++; //Increment static touch counter on the island
		writeIslandStaticTouchCount(islandId2)++;
	}
	return islandId2;
}

PX_FORCE_INLINE void IslandSim::removeNodeFromIsland(Island& island, PxNodeIndex nodeIndex)
{
	Node& node = mNodes[nodeIndex.index()];
	if(node.mNextNode.isValid())
	{
		PX_ASSERT(mNodes[node.mNextNode.index()].mPrevNode.index() == nodeIndex.index());
		mNodes[node.mNextNode.index()].mPrevNode = node.mPrevNode;
	}
	else
	{
		PX_ASSERT(island.mLastNode.index() == nodeIndex.index());
		island.mLastNode = node.mPrevNode;
	}

	if(node.mPrevNode.isValid())
	{
		PX_ASSERT(mNodes[node.mPrevNode.index()].mNextNode.index() == nodeIndex.index());
		mNodes[node.mPrevNode.index()].mNextNode = node.mNextNode;
	}
	else
	{
		PX_ASSERT(island.mRootNode.index() == nodeIndex.index());
		island.mRootNode = node.mNextNode;
	}

	island.mNodeCount[node.mType]--;

	node.mNextNode = node.mPrevNode = PxNodeIndex();
}

///////////////////////////////////////////////////////////////////////////////

void IslandSim::processNewEdges()
{
	PX_PROFILE_ZONE("Basic.processNewEdges", mContextId);
	//Stage 1: we process the list of new pairs. To do this, we need to first sort them based on a predicate...

	insertNewEdges();

	mHopCounts.resize(mNodes.size()); //Make sure we have enough space for hop counts for all nodes
	mFastRoute.resize(mNodes.size());

	for(PxU32 i = 0; i < Edge::eEDGE_TYPE_COUNT; ++i)
	{
		for(PxU32 a = 0; a < mDirtyEdges[i].size(); ++a)
		{
			const EdgeIndex edgeIndex = mDirtyEdges[i][a];
			const Edge& edge = mEdges[edgeIndex];
			
			/*PX_ASSERT(edge.mState != Edge::eDESTROYED || ((edge.mNode1.index() == PX_INVALID_NODE || mNodes[edge.mNode1.index()].isKinematic() || mNodes[edge.mNode1.index()].isActive() == false) &&
				(edge.mNode2.index() == PX_INVALID_NODE || mNodes[edge.mNode2.index()].isKinematic() || mNodes[edge.mNode2.index()].isActive() == false)));*/

			//edge.clearInDirtyList();
			
			//We do not process either destroyed or disconnected edges
			if(/*edge.isConnected() && */!edge.isPendingDestroyed())
			{
				//Conditions:
				//(1)	Neither body is in an island (static/kinematics are never in islands) so we need to create a new island containing these bodies 
				//		or just 1 body if the other is kinematic/static
				//(2)	Both bodies are already in the same island. Update root node hop count estimates for the bodies if a route through the new connection
				//		is shorter for either body
				//(3)	One body is already in an island and the other isn't, so we just add the new body to the existing island.
				//(4)	Both bodies are in different islands. In that case, we merge the islands

				const PxNodeIndex nodeIndex1 = mCpuData.mEdgeNodeIndices[2 * edgeIndex];
				const PxNodeIndex nodeIndex2 = mCpuData.mEdgeNodeIndices[2 * edgeIndex+1];
                if(mGpuData && mTrackPreSolveMerges && mRecordPreSolveMerges && nodeIndex1.isValid() && nodeIndex2.isValid()
                    && !mNodes[nodeIndex1.index()].isKinematic() && !mNodes[nodeIndex2.index()].isKinematic())
                    mPreSolveMerges.pushBack({nodeIndex1.index(),nodeIndex2.index()});

				const PxU32 index1 = nodeIndex1.index();
				const PxU32 index2 = nodeIndex2.index();

				const IslandId islandId1 = index1 == PX_INVALID_NODE ? IG_INVALID_ISLAND : mIslandIds[index1];
				const IslandId islandId2 = index2 == PX_INVALID_NODE ? IG_INVALID_ISLAND : mIslandIds[index2];

				//TODO - wake ups!!!!
				//If one of the nodes is awake and the other is asleep, we need to wake 'em up

				//When a node is activated, the island must also be activated...

				const bool active1 = index1 != PX_INVALID_NODE && mNodes[index1].isActive();
				const bool active2 = index2 != PX_INVALID_NODE && mNodes[index2].isActive();

				IslandId islandId = IG_INVALID_ISLAND;

				if(islandId1 == IG_INVALID_ISLAND && islandId2 == IG_INVALID_ISLAND)
				{
					//All nodes should be introduced in an island now unless they are static or kinematic. Therefore, if we get here, we have an edge
					//between 2 kinematic nodes or a kinematic and static node. These should not influence island management so we should just ignore
					//these edges.
				}
				else if(islandId1 == islandId2)
				{
					islandId = islandId1;
					if(active1 || active2)
					{
						PX_ASSERT(mIslandAwake.test(islandId1)); //If we got here, where the 2 were already in an island, if 1 node is awake, the whole island must be awake
					}
					//Both bodies in the same island. Nothing major to do already but we should see if this creates a shorter path to root for either node
					const PxU32 hopCount1 = mHopCounts[index1];
					const PxU32 hopCount2 = mHopCounts[index2];
					if((hopCount1+1) < hopCount2)
					{
						//It would be faster for node 2 to go through node 1
						mHopCounts[index2] = hopCount1 + 1;
						mFastRoute[index2] = nodeIndex1;
					}
					else if((hopCount2+1) < hopCount1)
					{
						//It would be faster for node 1 to go through node 2
						mHopCounts[index1] = hopCount2 + 1;
						mFastRoute[index1] = nodeIndex2;
					}

					//No need to activate/deactivate the island. Its state won't have changed
				}
				else if(islandId1 == IG_INVALID_ISLAND)
				{
					islandId = addNodeToIsland(nodeIndex1, nodeIndex2, islandId2, active1, active2);
				}
				else if (islandId2 == IG_INVALID_ISLAND)
				{
					islandId = addNodeToIsland(nodeIndex2, nodeIndex1, islandId1, active2, active1);
				}
				else
				{
					PX_ASSERT(islandId1 != islandId2);
					PX_ASSERT(islandId1 != IG_INVALID_ISLAND && islandId2 != IG_INVALID_ISLAND);

					if(active1 || active2)
					{
						//One of the 2 islands was awake, so need to wake the other one! We do this now, before we merge the islands, to ensure that all 
						//the bodies are activated
						if(!mIslandAwake.test(islandId1))
						{
							//This island wasn't already awake, so need to wake the whole island up
							activateIsland(islandId1);
						}
						if(!mIslandAwake.test(islandId2))
						{
							//This island wasn't already awake, so need to wake the whole island up
							activateIsland(islandId2);
						}
					}

					//OK. We need to merge these islands together...
					islandId = mergeIslands(islandId1, islandId2, nodeIndex1, nodeIndex2);
				}

				if(islandId != IG_INVALID_ISLAND)
				{
					//Add new edge to existing island
					Island& island = mIslands[islandId];
					addEdgeToIsland(*this, mEdges, island.mEdges, edgeIndex);
				}
			}
		}
	}
}

#if PX_DEBUG
bool IslandSim::isPathTo(PxNodeIndex startNode, PxNodeIndex targetNode) const
{
	const Node& node = mNodes[startNode.index()];

	EdgeInstanceIndex index = node.mFirstEdgeIndex;
	while(index != IG_INVALID_EDGE)
	{
		const EdgeInstance& instance = mEdgeInstances[index];
		if(/*mEdges[index/2].isConnected() &&*/ mCpuData.mEdgeNodeIndices[index^1].index() == targetNode.index())
			return true;
		index = instance.mNextEdge;
	}
	return false;
}
#endif

bool IslandSim::tryFastPath(PxNodeIndex startNode, PxNodeIndex targetNode, IslandId islandId)
{
	PX_UNUSED(startNode);
	PX_UNUSED(targetNode);

	PxNodeIndex currentNode = startNode;

	const PxU32 currentVisitedNodes = mVisitedNodes.size();

	PxU32 depth = 0;
	
	bool found = false;
	do
	{
		//Get the fast path from this node...
		
		const PxU32 nodeIndex = currentNode.index();
		if(mVisitedState.test(nodeIndex))
		{
			found = mIslandIds[nodeIndex] != IG_INVALID_ISLAND; //Already visited and not tagged with invalid island == a witness!
			break;
		}
		if(nodeIndex == targetNode.index())
		{
			found = true;
			break;
		}

		mVisitedNodes.pushBack(TraversalState(currentNode, mVisitedNodes.size(), mVisitedNodes.size()-1, depth++));

		PX_ASSERT(mFastRoute[nodeIndex].index() == PX_INVALID_NODE || isPathTo(currentNode, mFastRoute[nodeIndex]));

		writeIslandId(nodeIndex) = IG_INVALID_ISLAND;
		mVisitedState.set(nodeIndex);

		currentNode = mFastRoute[nodeIndex];
	}
	while(currentNode.index() != PX_INVALID_NODE);

	for(PxU32 a = currentVisitedNodes; a < mVisitedNodes.size(); ++a)
	{
		const TraversalState& state = mVisitedNodes[a];
		writeIslandId(state.mNodeIndex.index()) = islandId;
	}

	if(!found)
	{
		for(PxU32 a = currentVisitedNodes; a < mVisitedNodes.size(); ++a)
		{
			const TraversalState& state = mVisitedNodes[a];
			mVisitedState.reset(state.mNodeIndex.index());
		}

		mVisitedNodes.forceSize_Unsafe(currentVisitedNodes);
	}
	return found;
}

bool IslandSim::auditGpuContactComponents()
{
    if(!mGpuComponentAudit || !mGpuComponentLabels)return true;
    ++mGpuComponentAudits;
    const auto fail=[&](const char* why,PxU32 node) {
        std::fprintf(stderr,"GPU island boundary audit: %s graph=%s node=%u\n",
            why,mGpuData?"accurate":"speculative",node);
        ++mGpuComponentAuditFailures;
        // Preserve a usable registry for diagnostics; never consume a known
        // incorrect graph. The capture checks this sticky failure after fetch.
        setGpuContactComponents(NULL,NULL,0);return false;
    };
    if(!mGpuComponentMembers)return fail("missing member storage",PX_INVALID_NODE);
    const PxU32 n=mNodes.size();
    const auto dynamic=[&](PxU32 i) { return i<n && !mNodes[i].isDeleted()
        && !mNodes[i].isKinematic() && mIslandIds[i]!=IG_INVALID_ISLAND; };
    // Build an independent adjacency from native inserted edges, not GPU pair
    // inputs, GPU labels or existing island partitions. Pending deletions no
    // longer contribute to the connectivity consumed by this third pass.
    PxArray<PxArray<PxU32> > adjacency;adjacency.resize(n);
    for(PxU32 e=0;e<mEdges.size();++e) {
        const Edge& edge=mEdges[e];if(!edge.isInserted() || edge.isPendingDestroyed())continue;
        if(size_t(e)*2+1>=mCpuData.mEdgeNodeIndices.size())return fail("missing edge endpoints",e);
        const PxU32 a=mCpuData.mEdgeNodeIndices[2*e].index(),b=mCpuData.mEdgeNodeIndices[2*e+1].index();
        if(dynamic(a) && dynamic(b)){adjacency[a].pushBack(b);adjacency[b].pushBack(a);}
    }
    PxArray<PxU32> expected;expected.resize(n,PX_INVALID_NODE);
    PxArray<PxU32> queue;
    for(PxU32 root=0;root<n;++root)if(dynamic(root) && expected[root]==PX_INVALID_NODE) {
        queue.clear();queue.pushBack(root);expected[root]=root;
        for(PxU32 j=0;j<queue.size();++j) {
            const PxArray<PxU32>& neighbors=adjacency[queue[j]];
            for(PxU32 k=0;k<neighbors.size();++k)if(expected[neighbors[k]]==PX_INVALID_NODE) {
                expected[neighbors[k]]=root;queue.pushBack(neighbors[k]);
            }
        }
    }
    // Validate labels and the complete sorted member chain, including the
    // case of equal but wrong labels (which bypasses findRoute's split checks).
    PxArray<PxU32> last;last.resize(n,PX_INVALID_NODE);
    for(PxU32 node=0;node<n;++node)if(dynamic(node)) {
        const PxU32 root=expected[node];
        if(node>=mGpuComponentCount || mGpuComponentLabels[node]!=root) {
            const PxU32 gpu=node<mGpuComponentCount?mGpuComponentLabels[node]:PX_INVALID_NODE;
            std::fprintf(stderr,"GPU island audit partition: node=%u expected=%u gpu=%u native_island=%u domain=%u nodes=%u\n",
                node,root,gpu,mIslandIds[node],mGpuComponentCount,n);
            PxU32 printed=0;
            for(PxU32 e=0;e<mEdges.size() && printed<32;++e) {
                const Edge& edge=mEdges[e];if(!edge.isInserted() || edge.isPendingDestroyed())continue;
                const PxU32 a=mCpuData.mEdgeNodeIndices[2*e].index(),b=mCpuData.mEdgeNodeIndices[2*e+1].index();
                if(dynamic(a) && dynamic(b) && (expected[a]==root || expected[b]==root)) {
                    std::fprintf(stderr,"GPU island audit edge: edge=%u nodes=%u,%u labels=%u,%u expected=%u,%u\n",
                        e,a,b,a<mGpuComponentCount?mGpuComponentLabels[a]:PX_INVALID_NODE,
                        b<mGpuComponentCount?mGpuComponentLabels[b]:PX_INVALID_NODE,expected[a],expected[b]);++printed;
                }
            }
            return fail("component differs from native edge flood fill",node);
        }
        if(last[root]==PX_INVALID_NODE) {
            if(mGpuComponentMembers[root]!=node)return fail("incorrect component head",node);
        } else if(mGpuComponentMembers[size_t(mGpuComponentCount)+last[root]]!=node)
            return fail("incorrect member successor",node);
        last[root]=node;
    }
    for(PxU32 root=0;root<n;++root)if(last[root]!=PX_INVALID_NODE
        && mGpuComponentMembers[size_t(mGpuComponentCount)+last[root]]!=PX_INVALID_NODE)
        return fail("unterminated member chain",last[root]);
    // Preserve an independently constructed previous-phase partition for the
    // next pre-solver audit. GPU labels are not copied into the oracle.
    if(mGpuData) {
        mAuditPreviousLabels=expected;mAuditPreviousLifetimes.resize(n);
        for(PxU32 i=0;i<n;++i)mAuditPreviousLifetimes[i]=getPreSolveLifetime(i);
    }
    return true;
}

void IslandSim::restoreHostConnectivityImpl()
{
    if(!mDeviceConnectivityOwned)return;
    PxProfileScoped profile(PxGetProfilerCallback(),"GpuDestruction.task.restoreHostConnectivity",false,mContextId);
    mDeviceConnectivityOwned=false;setGpuContactComponents(NULL,NULL,0);
    // CPU edge and node lifetimes have continued to be maintained. Complete
    // every deferred split before a native metadata consumer can see this cache.
    // Deferred removals and handle reuse invalidate the old routing witnesses.
    for(PxU32 i=0;i<mNodes.size();++i) {
        mFastRoute[i]=PxNodeIndex(PX_INVALID_NODE);mHopCounts[i]=0;
        if(!mNodes[i].isDeleted() && !mNodes[i].isKinematic() && mIslandIds[i]!=IG_INVALID_ISLAND) {
            mNodes[i].markDirty();mDirtyMap.growAndSet(i);
        }
    }
    // Restore only the partition cache. This can run after solver partitioning;
    // replaying retirement/deactivation/resetDirtyEdges here would consume the
    // pending lifecycle queues a second time and invalidate solver-body maps.
    rebuildHostConnectivity(0xffffffffu,PxGetProfilerCallback());
}

bool IslandSim::buildIndependentPreSolveAuditImpl(PxArray<PxU32>& labels,PxArray<PxU32>& touches) const
{
    if(!mDeviceConnectivityOwned)return false;
    const PxU32 n=mNodes.size(),previous=mAuditPreviousLabels.size();
    if(!mGpuComponentAudit || !previous)return false;
    // Virtual hubs retain previous connections for surviving node lifetimes;
    // current inserted edges then add the new pre-solve connections. This is
    // the native deferred-removal phase, not a flood fill of final contacts.
    PxArray<PxU32> parents;parents.resize(n+previous);
    for(PxU32 i=0;i<parents.size();++i)parents[i]=i;
    const auto live=[&](PxU32 i){return i<n && !mNodes[i].isDeleted() && !mNodes[i].isKinematic() && mIslandIds[i]!=IG_INVALID_ISLAND;};
    const auto root=[&](PxU32 i){while(parents[i]!=i){parents[i]=parents[parents[i]];i=parents[i];}return i;};
    const auto join=[&](PxU32 a,PxU32 b){a=root(a);b=root(b);if(a!=b)parents[PxMax(a,b)]=PxMin(a,b);};
    for(PxU32 i=0;i<n && i<previous;++i)if(live(i) && mAuditPreviousLabels[i]<previous
        && mAuditPreviousLifetimes[i]==getPreSolveLifetime(i))join(i,n+mAuditPreviousLabels[i]);
    for(PxU32 e=0;e<mEdges.size();++e)if(mEdges[e].isInserted() && !mEdges[e].isPendingDestroyed()) {
        const PxU32 a=mCpuData.mEdgeNodeIndices[2*e].index(),b=mCpuData.mEdgeNodeIndices[2*e+1].index();
        if(live(a) && live(b))join(a,b);
    }
    labels.resize(n);touches.resize(n);PxMemZero(touches.begin(),n*sizeof(PxU32));
    for(PxU32 i=0;i<n;++i){labels[i]=live(i)?root(i):IG_INVALID_ISLAND;if(live(i))touches[labels[i]]+=mNodes[i].mStaticTouchCount;}
    return true;
}

bool IslandSim::findRoute(PxNodeIndex startNode, PxNodeIndex targetNode, IslandId islandId)
{
    mGpuSplit=false;
    if(mGpuComponentLabels && startNode.index()<mGpuComponentCount && targetNode.index()<mGpuComponentCount) {
        const PxU32 component=mGpuComponentLabels[startNode.index()];
        if(component==mGpuComponentLabels[targetNode.index()]) {
            ++mGpuRouteCount;return true; // exact connectedness, no CPU path search
        }
        // CUDA supplies a direct component head and sorted successors. No
        // CPU binary search or component grouping is needed. Validate before
        // mutating the compatibility registry, including strict order/cycles.
        bool valid=component<mGpuComponentCount,foundStart=false;
        const PxU32 first=valid?mGpuComponentMembers[component]:PX_INVALID_NODE;
        PxU32 previous=PX_INVALID_NODE;
        for(PxU32 node=first;node!=PX_INVALID_NODE;) {
            if(node>=mGpuComponentCount || node>=mNodes.size()
                || (previous!=PX_INVALID_NODE && node<=previous)
                || mGpuComponentLabels[node]!=component || mNodes[node].isDeleted() || mNodes[node].isKinematic()
                || mIslandIds[node]!=islandId || mVisitedState.test(node)){valid=false;break;}
            foundStart|=node==startNode.index();previous=node;
            node=mGpuComponentMembers[size_t(mGpuComponentCount)+node];
        }
        if(valid && foundStart) {
            mVisitedNodes.pushBack(TraversalState(startNode,0,PX_INVALID_NODE,0));
            for(PxU32 node=first;node!=PX_INVALID_NODE;node=mGpuComponentMembers[size_t(mGpuComponentCount)+node]) {
                if(node!=startNode.index())mVisitedNodes.pushBack(TraversalState(PxNodeIndex(node),mVisitedNodes.size(),0,0));
                mVisitedState.set(node);writeIslandId(node)=IG_INVALID_ISLAND;
            }
            mGpuSplit=true;++mGpuSplitCount;return false;
        }
        ++mGpuRepairFallbackCount;
        // A registry mismatch invalidates this observation for the remainder
        // of the pass; do not mix later GPU answers with repaired CPU state.
        setGpuContactComponents(NULL,NULL,0);
    }

	//Firstly, traverse the fast path and tag up witnesses. TryFastPath can fail. In that case, no witnesses are left but this node is permitted to report
	//that it is still part of the island. Whichever node lost its fast path will be tagged as dirty and will be responsible for recovering the fast path
	//and tagging up the visited nodes
	if(mFastRoute[startNode.index()].index() != PX_INVALID_NODE)
	{
		if(tryFastPath(startNode, targetNode, islandId))
			return true;

		//Try fast path can either be successful or not. If it was successful, then we had a valid fast path cached and all nodes on that fast path were tagged
		//as witness nodes (visited and with a valid island ID). If the fast path was not successful, then no nodes were tagged as witnesses. 
		//Technically, we need to find a route to the root node but, as an optimization, we can simply return true from here with no witnesses added. 
		//Whichever node actually broke the "fast path" will also be on the list of dirty nodes and will be processed later. 
		//If that broken edge triggered an island separation, this node will be re-visited and added to that island, otherwise
		//the path to the root node will be re-established. The end result is the same - the island state is computed - this just saves us some work.
		//return true;
	}

	{
		//If we got here, there was no fast path. Therefore, we need to fall back on searching for the root node. This is optimized by using "hop counts".
		//These are per-node counts that indicate the expected number of hops from this node to the root node. These are lazily evaluated and updated
		//as new edges are formed or when traversals occur to re-establish islands. As a result, they may be inaccurate but they still serve the purpose
		//of guiding our search to minimize the chances of us doing an exhaustive search to find the root node.
		writeIslandId(startNode.index()) = IG_INVALID_ISLAND;
		TraversalState* startTraversal = mVisitedNodes.pushBack(TraversalState(startNode, mVisitedNodes.size(), PX_INVALID_NODE, 0));
		mVisitedState.set(startNode.index());
		QueueElement element(startTraversal, mHopCounts[startNode.index()]);
		mPriorityQueue.push(element);

		do
		{
			const QueueElement currentQE = mPriorityQueue.pop();

			const TraversalState& currentState = *currentQE.mState;

			const Node& currentNode = mNodes[currentState.mNodeIndex.index()];

			EdgeInstanceIndex edge = currentNode.mFirstEdgeIndex;

			while(edge != IG_INVALID_EDGE)
			{
				const EdgeInstance& instance = mEdgeInstances[edge];
				{
					const PxNodeIndex nextIndex = mCpuData.mEdgeNodeIndices[edge ^ 1];
					const PxU32 nextIndexIndex = nextIndex.index();

					//Static or kinematic nodes don't connect islands.
					if(nextIndexIndex != PX_INVALID_NODE && !mNodes[nextIndexIndex].isKinematic())
					{
						if(nextIndexIndex == targetNode.index())
						{
							unwindRoute(currentState.mCurrentIndex, nextIndex, 0, islandId);
							return true;
						}

						if(mVisitedState.test(nextIndexIndex))
						{
							//We already visited this node. This means that it's either in the priority queue already or we 
							//visited in on a previous pass. If it was visited on a previous pass, then it already knows what island it's in. 
							//We now need to test the island id to find out if this node knows the root.
							//If it has a valid root id, that id *is* our new root. We can guesstimate our hop count based on the node's properties
							
							const IslandId visitedIslandId = mIslandIds[nextIndexIndex];
							if(visitedIslandId != IG_INVALID_ISLAND)
							{
								//If we get here, we must have found a node that knows a route to our root node. It must not be a different island
								//because that would caused me to have been visited already because totally separate islands trigger a full traversal on 
								//the orphaned side.
								PX_ASSERT(visitedIslandId == islandId);
								unwindRoute(currentState.mCurrentIndex, nextIndex, mHopCounts[nextIndexIndex], islandId);
								return true;
							}
						}
						else
						{
							//This node has not been visited yet, so we need to push it into the stack and continue traversing
							TraversalState* state = mVisitedNodes.pushBack(TraversalState(nextIndex, mVisitedNodes.size(), currentState.mCurrentIndex, currentState.mDepth+1));
							QueueElement qe(state, mHopCounts[nextIndexIndex]);
							mPriorityQueue.push(qe);
							mVisitedState.set(nextIndexIndex);
							PX_ASSERT(mIslandIds[nextIndexIndex] == islandId);
							writeIslandId(nextIndexIndex) = IG_INVALID_ISLAND; //Flag as invalid island until we know whether we can find root or an island id.
						}
					}
				}

				edge = instance.mNextEdge;
			}
		}
		while(mPriorityQueue.size());

		return false;
	}
}

void IslandSim::rebuildHostConnectivity(PxU32 dirtyNodeLimit,PxProfilerCallback* profiler)
{
    PX_UNUSED(dirtyNodeLimit);
    mVisitedState.resizeAndClear(mNodes.size());
    mPriorityQueue.reserve(1024);mVisitedNodes.reserve(mNodes.size());
    for(PxU32 i=0;i<Edge::eEDGE_TYPE_COUNT;++i)mIslandSplitEdges[i].reserve(1024);

		PX_PROFILE_ZONE("Basic.findPathsAndBreakIslands", mContextId);
        PxProfileScoped detail(profiler,mGpuData?"GpuDestruction.task.accurateIsland.findPathsAndBreakIslands":"GpuDestruction.task.speculativeIsland.findPathsAndBreakIslands",false,mContextId);

		//KS - process only this many dirty nodes, deferring future dirty nodes to subsequent frames. 
		//This means that it may take several frames for broken edges to trigger islands to completely break but this is better
		//than triggering large performance spikes.
#if IG_LIMIT_DIRTY_NODES
		PxBitMap::PxCircularIterator iter(mDirtyMap, mLastMapIndex);
		const PxU32 MaxCount = dirtyNodeLimit;// +10000000;
		PxU32 lastMapIndex = mLastMapIndex;
		PxU32 count = 0;
#else
		PxBitMap::Iterator iter(mDirtyMap);
#endif

		PxU32 dirtyIdx;

#if IG_LIMIT_DIRTY_NODES
		while ((dirtyIdx = iter.getNext()) != PxBitMap::PxCircularIterator::DONE
			&& (count++ < MaxCount)
#else
		while ((dirtyIdx = iter.getNext()) != PxBitMap::Iterator::DONE
#endif
			)
		{
#if IG_LIMIT_DIRTY_NODES
			lastMapIndex = dirtyIdx + 1;
#endif
			//Process dirty nodes. Figure out if we can make our way from the dirty node to the root.

			mPriorityQueue.clear(); //Clear the queue used for traversal
			mVisitedNodes.forceSize_Unsafe(0); //Clear the list of nodes in this island
			const PxNodeIndex dirtyNodeIndex(dirtyIdx);
			const PxU32 dirtyIndex = dirtyNodeIndex.index();
			Node& dirtyNode = mNodes[dirtyIndex];

			//Check whether this node has already been touched. If it has been touched this frame, then its island state is reliable 
			//and we can just unclear the dirty flag on the body. If we were already visited, then the state should have already been confirmed in a 
			//previous pass.
			if (!dirtyNode.isKinematic() && !dirtyNode.isDeleted() && !mVisitedState.test(dirtyIndex))
			{
				//We haven't visited this node in our island repair passes yet, so we still need to process until we've hit a visited node or found
				//our root node. Note that, as soon as we hit a visited node that has already been processed in a previous pass, we know that we can rely
				//on its island information although the hop counts may not be optimal. It also indicates that this island was not broken immediately because
				//otherwise, the entire new sub-island would already have been visited and this node would have already had its new island state assigned.

				//Indicate that I've been visited

				const IslandId islandId = mIslandIds[dirtyIndex];
				const Island& findIsland = mIslands[islandId];

				const PxNodeIndex searchNode = findIsland.mRootNode;//The node that we're searching for!

				if (searchNode.index() != dirtyIndex) //If we are the root node, we don't need to do anything!
				{
					if (findRoute(dirtyNodeIndex, searchNode, islandId))
					{
						//We found the root node so let's let every visited node know that we found its root
						//and we can also update our hop counts because we recorded how many hops it took to reach this
						//node

						//We already filled in the path to the root/witness with accurate hop counts. Now we just need to fill in the estimates
						//for the remaining nodes and re-define their islandIds. We approximate their path to the root by just routing them through
						//the route we already found.

						//This loop works because mVisitedNodes are recorded in the order they were visited and we already filled in the critical path
						//so the remainder of the paths will just fork from that path.

						//Verify state (that we can see the root from this node)...

#if IG_SANITY_CHECKS
						PX_ASSERT(canFindRoot(dirtyNodeIndex, searchNode, NULL)); //Verify that we found the connection
#endif

						for (PxU32 b = 0; b < mVisitedNodes.size(); ++b)
						{
							const TraversalState& state = mVisitedNodes[b];
							const PxU32 stateIndex = state.mNodeIndex.index();
							if (mIslandIds[stateIndex] == IG_INVALID_ISLAND)
							{
								mHopCounts[stateIndex] = mHopCounts[mVisitedNodes[state.mPrevIndex].mNodeIndex.index()] + 1;
								mFastRoute[stateIndex] = mVisitedNodes[state.mPrevIndex].mNodeIndex;
								writeIslandId(stateIndex) = islandId;
							}
						}
					}
					else
					{
						//If I traversed and could not find the root node, then I have established a new island. In this island, I am the root node
						//and I will point all my nodes towards me. Furthermore, I have established how many steps it took to reach all nodes in my island

						//OK. We need to separate the islands. We have a list of nodes that are part of the new island (mVisitedNodes) and we know that the 
						//first node in that list is the root node.


						//OK, we need to remove all these actors from their current island, then add them to the new island...

						Island& oldIsland = mIslands[islandId];
						//We can just unpick these nodes from the island because they do not contain the root node (if they did, then we wouldn't be
						//removing this node from the island at all). The only challenge is if we need to remove the last node. In that case
						//we need to re-establish the new last node in the island but perhaps the simplest way to do that would be to traverse
						//the island to establish the last node again

#if IG_SANITY_CHECKS
						PX_ASSERT(!canFindRoot(dirtyNodeIndex, searchNode, NULL));
#endif

						PxU32 totalStaticTouchCount = 0;
						PxU32 nodeCount[Node::eTYPE_COUNT];
						for (PxU32 t = 0; t < Node::eTYPE_COUNT; ++t)
						{
							nodeCount[t] = 0;
						}

						for (PxU32 t = 0; t < Edge::eEDGE_TYPE_COUNT; ++t)
						{
							mIslandSplitEdges[t].forceSize_Unsafe(0);
						}

						//NodeIndex lastIndex = oldIsland.mLastNode;

						//nodeCount[node.mType] = 1;

						for (PxU32 a = 0; a < mVisitedNodes.size(); ++a)
						{
							const PxNodeIndex index = mVisitedNodes[a].mNodeIndex;
							Node& node = mNodes[index.index()];

							if (node.mNextNode.index() != PX_INVALID_NODE)
								mNodes[node.mNextNode.index()].mPrevNode = node.mPrevNode;
							else
								oldIsland.mLastNode = node.mPrevNode;
							if (node.mPrevNode.index() != PX_INVALID_NODE)
								mNodes[node.mPrevNode.index()].mNextNode = node.mNextNode;

							nodeCount[node.mType]++;

							node.mNextNode.setIndices(PX_INVALID_NODE);
							node.mPrevNode.setIndices(PX_INVALID_NODE);

							PX_ASSERT(mNodes[oldIsland.mLastNode.index()].mNextNode.index() == PX_INVALID_NODE);

							totalStaticTouchCount += node.mStaticTouchCount;

							EdgeInstanceIndex idx = node.mFirstEdgeIndex;

							while (idx != IG_INVALID_EDGE)
							{
								const EdgeInstance& instance = mEdgeInstances[idx];
								const EdgeIndex edgeIndex = idx / 2;
								const Edge& edge = mEdges[edgeIndex];

								//Only split the island if we're processing the first node or if the first node is infinite-mass
								if (!(idx & 1) || (mCpuData.mEdgeNodeIndices[idx & (~1)].index() == PX_INVALID_NODE || mNodes[mCpuData.mEdgeNodeIndices[idx & (~1)].index()].isKinematic()))
								{
									//We will remove this edge from the island...
									mIslandSplitEdges[edge.mEdgeType].pushBack(edgeIndex);

									removeEdgeFromIsland(mEdges, oldIsland.mEdges, edgeIndex);
								}
								idx = instance.mNextEdge;
							}
						}

						//oldIsland.mStaticTouchCount -= totalStaticTouchCount;
						writeIslandStaticTouchCount(islandId) -= totalStaticTouchCount;

						for (PxU32 i = 0; i < Node::eTYPE_COUNT; ++i)
						{
							PX_ASSERT(nodeCount[i] <= oldIsland.mNodeCount[i]);
							oldIsland.mNodeCount[i] -= nodeCount[i];
						}

						//Now add all these nodes to the new island

						//(1) Create the new island...
						const IslandId newIslandHandle = mIslandHandles.getHandle();
						/*if(newIslandHandle == mIslands.capacity())
						{
						mIslands.reserve(2*mIslands.capacity() + 1);
						}*/
						mIslands.resize(PxMax(newIslandHandle + 1, mIslands.size()));
						mIslandStaticTouchCount.resize(PxMax(newIslandHandle + 1, mIslandStaticTouchCount.size()));
						Island& newIsland = mIslands[newIslandHandle];

						if (mIslandAwake.test(islandId))
						{
							newIsland.mActiveIndex = mActiveIslands.size();
							mActiveIslands.pushBack(newIslandHandle);
							mIslandAwake.growAndSet(newIslandHandle); //Separated island, so it should be awake
						}
						else
						{
							mIslandAwake.growAndReset(newIslandHandle);
						}

						newIsland.mRootNode = dirtyNodeIndex;
						mHopCounts[dirtyIndex] = 0;
						writeIslandId(dirtyIndex) = newIslandHandle;
						//newIsland.mTotalSize = mVisitedNodes.size();

						mNodes[dirtyIndex].mPrevNode.setIndices(PX_INVALID_NODE); //First node so doesn't have a preceding node
						mFastRoute[dirtyIndex].setIndices(PX_INVALID_NODE);

						for (PxU32 i = 0; i < Node::eTYPE_COUNT; ++i)
							nodeCount[i] = 0;

						nodeCount[dirtyNode.mType] = 1;

						for (PxU32 a = 1; a < mVisitedNodes.size(); ++a)
						{
							const PxNodeIndex index = mVisitedNodes[a].mNodeIndex;
							const PxU32 indexIndex = index.index();
							Node& thisNode = mNodes[indexIndex];
							const PxNodeIndex prevNodeIndex = mVisitedNodes[a - 1].mNodeIndex;
							thisNode.mPrevNode = prevNodeIndex;
							mNodes[prevNodeIndex.index()].mNextNode = index;
							nodeCount[thisNode.mType]++;
							writeIslandId(indexIndex) = newIslandHandle;
							mHopCounts[indexIndex] = mVisitedNodes[a].mDepth; //How many hops to root
                            // Component membership is not an adjacency tree.
                            // Invalidate routing hints so a later CPU fallback
                            // searches real edges instead of inventing a path.
                            mFastRoute[indexIndex] = mGpuSplit ? PxNodeIndex(PX_INVALID_NODE)
                                : mVisitedNodes[mVisitedNodes[a].mPrevIndex].mNodeIndex;
						}

						for (PxU32 i = 0; i < Node::eTYPE_COUNT; ++i)
							newIsland.mNodeCount[i] = nodeCount[i];

						//Last node in the island
						const PxNodeIndex lastIndex = mVisitedNodes[mVisitedNodes.size() - 1].mNodeIndex;
						mNodes[lastIndex.index()].mNextNode.setIndices(PX_INVALID_NODE);
						newIsland.mLastNode = lastIndex;
						//newIsland.mStaticTouchCount = totalStaticTouchCount;
						writeIslandStaticTouchCount(newIslandHandle) = totalStaticTouchCount;

						PX_ASSERT(mNodes[newIsland.mLastNode.index()].mNextNode.index() == PX_INVALID_NODE);

						for (PxU32 j = 0; j < IG::Edge::eEDGE_TYPE_COUNT; ++j)
							splitEdges(*this, mEdges, mIslandSplitEdges[j], newIsland.mEdges, Edge::EdgeType(j));
					}
				}
			}
			dirtyNode.clearDirty();
#if IG_LIMIT_DIRTY_NODES
			mDirtyMap.reset(dirtyIdx);
#endif
		}

#if IG_LIMIT_DIRTY_NODES
		mLastMapIndex = lastMapIndex;
		if (count < MaxCount)
			mLastMapIndex = 0;
#else
		mDirtyMap.clear();
#endif

		//mDirtyNodes.forceSize_Unsafe(0);
}

void IslandSim::processLostEdges(const PxArray<PxNodeIndex>& destroyedNodes, bool allowDeactivation, bool permitKinematicDeactivation, PxU32 dirtyNodeLimit, PxProfilerCallback* profiler)
{
	PX_UNUSED(dirtyNodeLimit);
	PX_PROFILE_ZONE("Basic.processLostEdges", mContextId);
	//At this point, all nodes and edges are activated.

	const PxU32 nbDestroyedEdges = mDestroyedEdges.size();
	PX_UNUSED(nbDestroyedEdges);
	{
		PX_PROFILE_ZONE("Basic.removeEdgesFromIslands", mContextId);
        PxProfileScoped detail(profiler,mGpuData?"GpuDestruction.task.accurateIsland.removeEdgesFromIslands":"GpuDestruction.task.speculativeIsland.removeEdgesFromIslands",false,mContextId);
		for (PxU32 a = 0; a < mDestroyedEdges.size(); ++a)
		{
			const EdgeIndex lostIndex = mDestroyedEdges[a];
			Edge& lostEdge = mEdges[lostIndex];

			if (lostEdge.isPendingDestroyed() && !lostEdge.isInDirtyList())
			{
				//Process this edge...
				if (!lostEdge.isReportOnlyDestroy() && lostEdge.isInserted())
				{
					const PxU32 index1 = mCpuData.mEdgeNodeIndices[mDestroyedEdges[a] * 2].index();
					const PxU32 index2 = mCpuData.mEdgeNodeIndices[mDestroyedEdges[a] * 2 + 1].index();

					IslandId islandId = IG_INVALID_ISLAND;
					if (index1 != PX_INVALID_NODE && index2 != PX_INVALID_NODE)
					{
						PX_ASSERT(mIslandIds[index1] == IG_INVALID_ISLAND || mIslandIds[index2] == IG_INVALID_ISLAND ||
							mIslandIds[index1] == mIslandIds[index2]);
						islandId = mIslandIds[index1] != IG_INVALID_ISLAND ? mIslandIds[index1] : mIslandIds[index2];
					}
					else if (index1 != PX_INVALID_NODE)
					{
						PX_ASSERT(index2 == PX_INVALID_NODE);
						Node& node = mNodes[index1];
						if (!node.isKinematic())
						{
							islandId = mIslandIds[index1];
							node.mStaticTouchCount--;
                            markPreSolveSupport(index1);
							//Island& island = mIslands[islandId];
							writeIslandStaticTouchCount(islandId)--;
							//island.mStaticTouchCount--;
						}
					}
					else if (index2 != PX_INVALID_NODE)
					{
						PX_ASSERT(index1 == PX_INVALID_NODE);
						Node& node = mNodes[index2];
						if (!node.isKinematic())
						{
							islandId = mIslandIds[index2];
							node.mStaticTouchCount--;
                            markPreSolveSupport(index2);
							//Island& island = mIslands[islandId];
							writeIslandStaticTouchCount(islandId)--;
							//island.mStaticTouchCount--;
						}
					}

					if (islandId != IG_INVALID_ISLAND)
					{
						//We need to remove this edge from the island
						Island& island = mIslands[islandId];
						removeEdgeFromIsland(mEdges, island.mEdges, lostIndex);
					}
				}

				lostEdge.clearInserted();
			}
		}
	}

    if(allowDeactivation && !mDeviceConnectivityOwned)
    {
        rebuildHostConnectivity(dirtyNodeLimit,profiler);
    }

	{
		PX_PROFILE_ZONE("Basic.clearDestroyedEdges", mContextId);
        PxProfileScoped detail(profiler,mGpuData?"GpuDestruction.task.accurateIsland.clearDestroyedEdges":"GpuDestruction.task.speculativeIsland.clearDestroyedEdges",false,mContextId);
		//Now process the lost edges...
		for (PxU32 a = 0; a < mDestroyedEdges.size(); ++a)
		{
			//Process these destroyed edges. Recompute island information. Update the islands and hop counters accordingly
			const EdgeIndex index = mDestroyedEdges[a];

			Edge& edge = mEdges[index];
			if (edge.isPendingDestroyed())
			{
				PartitionEdge* pEdge = mGpuData ? mGpuData->mFirstPartitionEdges[index] : NULL;
				if (pEdge)
				{
					mGpuData->mDestroyedPartitionEdges.pushBack(pEdge);
					mGpuData->mFirstPartitionEdges[index] = NULL; //Force first partition edge to NULL to ensure we don't have a clash
				}
				if (edge.isActive())
				{
					removeEdgeFromActivatingList(index); //TODO - can we remove this call? Can we handle this elsewhere, e.g. when destroying the nodes...
					mActiveEdgeCount[edge.mEdgeType]--;
				}

				edge = Edge(); //Reset edge
				if(mGpuData)
					mGpuData->mActiveContactEdges.growAndReset(index);
			}
		}

		mDestroyedEdges.forceSize_Unsafe(0);
	}

	{
		PX_PROFILE_ZONE("Basic.clearDestroyedNodes", mContextId);
        PxProfileScoped detail(profiler,mGpuData?"GpuDestruction.task.accurateIsland.clearDestroyedNodes":"GpuDestruction.task.speculativeIsland.clearDestroyedNodes",false,mContextId);

		for (PxU32 a = 0; a < destroyedNodes.size(); ++a)
		{
			const PxNodeIndex nodeIndex = destroyedNodes[a];
			const IslandId islandId = mIslandIds[nodeIndex.index()];
			Node& node = mNodes[nodeIndex.index()];
			if (islandId != IG_INVALID_ISLAND)
			{
				Island& island = mIslands[islandId];

				removeNodeFromIsland(island, nodeIndex);

				writeIslandId(nodeIndex.index()) = IG_INVALID_ISLAND;

				PxU32 nodeCountTotal = 0;
				for (PxU32 t = 0; t < Node::eTYPE_COUNT; ++t)
				{
					nodeCountTotal += island.mNodeCount[t];
				}

				if (nodeCountTotal == 0)
				{
					mIslandHandles.freeHandle(islandId);
					if (island.mActiveIndex != IG_INVALID_ISLAND)
					{
						const IslandId replaceId = mActiveIslands[mActiveIslands.size() - 1];
						Island& replaceIsland = mIslands[replaceId];
						replaceIsland.mActiveIndex = island.mActiveIndex;
						mActiveIslands[island.mActiveIndex] = replaceId;
						mActiveIslands.forceSize_Unsafe(mActiveIslands.size() - 1);
						island.mActiveIndex = IG_INVALID_ISLAND;
						//island.mStaticTouchCount -= node.mStaticTouchCount; //Remove the static touch count from the island
						writeIslandStaticTouchCount(islandId) -= node.mStaticTouchCount;
					}
					mIslandAwake.reset(islandId);
					island.mLastNode.setIndices(PX_INVALID_NODE);
					island.mRootNode.setIndices(PX_INVALID_NODE);
					island.mActiveIndex = IG_INVALID_ISLAND;
				}
			}

			if (node.isKinematic())
			{
				if (mActiveNodeIndex[nodeIndex.index()] != PX_INVALID_NODE)
				{
					//Remove from the active kinematics list...
					markKinematicInactive(nodeIndex);
				}
			}
			else
			{
				if (mActiveNodeIndex[nodeIndex.index()] != PX_INVALID_NODE)
				{
					markInactive(nodeIndex);
				}
			}

			//node.reset();
			node.mFlags |= Node::eDELETED;
            markPreSolveNode(nodeIndex.index());
		}
	}
	//Now we need to produce the list of active edges and nodes!!!

	//If we get here, we have a list of active islands. From this, we need to iterate over all active islands and establish if that island
	//can, in fact, go to sleep. In order to become deactivated, all nodes in the island must be ready for sleeping...

	if (allowDeactivation)
	{
		PX_PROFILE_ZONE("Basic.deactivation", mContextId);
        PxProfileScoped detail(profiler,mGpuData?"GpuDestruction.task.accurateIsland.deactivation":"GpuDestruction.task.speculativeIsland.deactivation",false,mContextId);
		for (PxU32 a = 0; a < mActiveIslands.size(); a++)
		{
			const IslandId islandId = mActiveIslands[a];

			mIslandAwake.reset(islandId);
		}

		//Loop over the active kinematic nodes and tag all islands touched by active kinematics as awake
		for (PxU32 a = mActiveKinematicNodes.size(); a > 0; --a)
		{
			const PxNodeIndex kinematicIndex = mActiveKinematicNodes[a - 1];

			Node& kinematicNode = mNodes[kinematicIndex.index()];

			if (kinematicNode.isReadyForSleeping())
			{
				if (permitKinematicDeactivation)
				{
					kinematicNode.clearActive();
					markKinematicInactive(kinematicIndex);
				}
			}
			else //if(!kinematicNode.isReadyForSleeping())
			{
				//KS - if kinematic is active, then wake up all islands the kinematic is touching
				EdgeInstanceIndex edgeId = kinematicNode.mFirstEdgeIndex;
				while (edgeId != IG_INVALID_EDGE)
				{
					const EdgeInstance& instance = mEdgeInstances[edgeId];
					//Edge& edge = mEdges[edgeId/2];
					//Only wake up islands if a connection was present
					//if(edge.isConnected())
					{
						PxNodeIndex outNode = mCpuData.mEdgeNodeIndices[edgeId ^ 1];
						if (outNode.index() != PX_INVALID_NODE)
						{
							IslandId islandId = mIslandIds[outNode.index()];
							if (islandId != IG_INVALID_ISLAND)
							{
								mIslandAwake.set(islandId);
								PX_ASSERT(mIslands[islandId].mActiveIndex != IG_INVALID_ISLAND);
							}
						}
					}
					edgeId = instance.mNextEdge;
				}
			}
		}

		// Mode 3 (exact): one flat pass over the active node lists marks every
		// island holding a node that is not ready, replacing the per-island
		// node-chain walk below with a bitmap test.
		const bool flatReadiness = mGpuSleepMode == 3;
		if (flatReadiness)
		{
			mIslandNotReadyFlat.resizeAndClear(mIslands.size());
			for (PxU32 type = 0; type < Node::eTYPE_COUNT; ++type)
			{
				const PxArray<PxNodeIndex>& active = mActiveNodes[type];
				for (PxU32 i = 0; i < active.size(); ++i)
				{
					const PxU32 node = active[i].index();
					if (!mNodes[node].isReadyForSleeping())
					{
						const IslandId island = mIslandIds[node];
						if (island != IG_INVALID_ISLAND && island < mIslands.size()) mIslandNotReadyFlat.set(island);
					}
				}
			}
		}
		for (PxU32 a = mActiveIslands.size(); a > 0; --a)
		{
			const IslandId islandId = mActiveIslands[a - 1];

			const Island& island = mIslands[islandId];

			bool canDeactivate = !mIslandAwake.test(islandId);
			mIslandAwake.set(islandId);

			//If it was touched by an active kinematic in the above loop, we can't deactivate it.
			//Therefore, no point in testing the nodes in the island. They must remain awake
			if (canDeactivate)
			{
				// R2 core: the device verdict for this island is the flag of its root
				// node (device components and islands coincide under owned connectivity).
				const PxU32 root = island.mRootNode.index();
				const bool haveVerdict = mGpuSleepNotReady && root < mGpuSleepCapacity;
				const bool wokenCpu = islandId < mIslandWokenThisFrame.size() && mIslandWokenThisFrame.test(islandId);
				// Modes 4/5 reduce the CPU's own readiness flags per device component;
				// CPU-side wakes are already in those flags, so the woken guard only
				// applies to the solver-derived verdicts (modes 1/2).
				const bool cpuReadiness = mGpuSleepMode >= 4;
				const bool deviceCan = haveVerdict && !mGpuSleepNotReady[root] && (cpuReadiness || !wokenCpu);
				if (haveVerdict && (mGpuSleepMode == 1 || mGpuSleepMode == 4))
				{
					canDeactivate = deviceCan;
				}
				else if (flatReadiness)
				{
					canDeactivate = !mIslandNotReadyFlat.test(islandId);
				}
				else
				{
					PxNodeIndex nodeId = island.mRootNode;
					while (nodeId.index() != PX_INVALID_NODE)
					{
						Node& node = mNodes[nodeId.index()];
						if (!node.isReadyForSleeping())
						{
							canDeactivate = false;
							break;
						}
						nodeId = node.mNextNode;
					}
					if (haveVerdict && (mGpuSleepMode == 2 || mGpuSleepMode == 5))
					{
						static PxU64 counters[2][8] = {};
						PxU64* c = counters[mGpuData ? 0 : 1];
						PxU64 &audits = c[0], &agree = c[1], &cpuOnly = c[2], &deviceOnly = c[3], &deviceOnlyMemberFlagged = c[4], &deviceOnlyMemberClear = c[5], &cpuOnlyRootFlagged = c[6], &shown = c[7];
						++audits; if (canDeactivate == deviceCan) ++agree; else if (canDeactivate) ++cpuOnly; else ++deviceOnly;
						if (canDeactivate != deviceCan)
						{
							// Classify: for deviceOnly (device says sleep, CPU found a not-ready
							// member) does that member's own device flag say not ready (then the
							// root and the member sit in different device components or the
							// member is unlabeled) or ready (readiness itself differs)?
							PxU32 members = 0, notReadyCpu = 0, notReadyCpuFlagged = 0;
							PxNodeIndex walkId = island.mRootNode;
							while (walkId.index() != PX_INVALID_NODE)
							{
								const Node& walkNode = mNodes[walkId.index()]; ++members;
								if (!walkNode.isReadyForSleeping()) { ++notReadyCpu; if (walkId.index() < mGpuSleepCapacity && mGpuSleepNotReady[walkId.index()]) ++notReadyCpuFlagged; }
								walkId = walkNode.mNextNode;
							}
							if (!canDeactivate) { if (notReadyCpuFlagged) ++deviceOnlyMemberFlagged; else ++deviceOnlyMemberClear; }
							else if (mGpuSleepNotReady[root]) ++cpuOnlyRootFlagged;
							if (shown < 24 && mGpuData) { ++shown;
								const Node& rootNode = mNodes[root];
								float wake = -1.f, solverWake = -1.f; unsigned internalFlags = 0, activeIndex = mActiveNodeIndex[root];
								if (rootNode.mType == Node::eRIGID_BODY_TYPE && rootNode.mObject) {
									const PxsRigidBody& body = *reinterpret_cast<const PxsRigidBody*>(rootNode.mObject);
									wake = body.getCore().wakeCounter; solverWake = body.getCore().solverWakeCounter; internalFlags = body.mInternalFlags; }
								fprintf(stderr, "  mismatch accurate #%llu pass=%u(%s): cpu=%d device=%d members=%u notReadyCpu=%u ofWhichDeviceFlagged=%u rootFlag=%u woken=%d root=%u/%u lifetime=%u rootReady=%d activating=%d kinematic=%d activeIndex=%u wake=%g solverWake=%g bodyFlags=0x%x\n",
									(unsigned long long)audits, mGpuSleepPassTag >> 1, (mGpuSleepPassTag & 1) ? "corrected" : "trial", int(canDeactivate), int(deviceCan), members, notReadyCpu, notReadyCpuFlagged, unsigned(mGpuSleepNotReady[root]), int(wokenCpu), root, mNodes.size(), unsigned(getPreSolveLifetime(root)),
									int(rootNode.isReadyForSleeping()), int(rootNode.isActivating()), int(rootNode.isKinematic()), activeIndex, double(wake), double(solverWake), internalFlags); }
						}
						if ((audits & 4095) == 0) fprintf(stderr, "device sleep audit (%s): islands=%llu agree=%llu cpuOnly=%llu (rootFlagged=%llu) deviceOnly=%llu (memberFlagged=%llu memberClear=%llu)\n", mGpuData ? "accurate" : "speculative",
							(unsigned long long)audits, (unsigned long long)agree, (unsigned long long)cpuOnly, (unsigned long long)cpuOnlyRootFlagged, (unsigned long long)deviceOnly, (unsigned long long)deviceOnlyMemberFlagged, (unsigned long long)deviceOnlyMemberClear);
					}
				}
				if (canDeactivate)
				{
					//If all nodes in this island are ready for sleeping and there were no active 
					//kinematics interacting with the any bodies in the island, we can deactivate the island.
					deactivateIsland(islandId);
				}
			}
		}
		mIslandWokenThisFrame.clear();
	}

	{
		PX_PROFILE_ZONE("Basic.resetDirtyEdges", mContextId);
        PxProfileScoped detail(profiler,mGpuData?"GpuDestruction.task.accurateIsland.resetDirtyEdges":"GpuDestruction.task.speculativeIsland.resetDirtyEdges",false,mContextId);
		for (PxU32 i = 0; i < Edge::eEDGE_TYPE_COUNT; ++i)
		{
			for (PxU32 a = 0; a < mDirtyEdges[i].size(); ++a)
			{
				Edge& edge = mEdges[mDirtyEdges[i][a]];
				edge.clearInDirtyList();
			}
			mDirtyEdges[i].clear(); //All new edges processed
		}
	}
}

IslandId IslandSim::mergeIslands(IslandId island0, IslandId island1, PxNodeIndex node0, PxNodeIndex node1)
{
	Island& is0 = mIslands[island0];
	Island& is1 = mIslands[island1];

	//We defer this process and do it later instead. That way, if we have some pathological 
	//case where multiple islands get merged repeatedly, we don't end up repeatedly remapping all the nodes in those islands 
	//to their new island. Instead, we just choose the largest island and remap the smaller island to that.

	PxU32 totalSize0 = 0;
	PxU32 totalSize1 = 0;

	for (PxU32 i = 0; i < Node::eTYPE_COUNT; ++i)
	{
		totalSize0 += is0.mNodeCount[i];
		totalSize1 += is1.mNodeCount[i];
	}
	if(totalSize0 > totalSize1)
	{
		mergeIslandsInternal(is0, is1, island0, island1, node0, node1);
		mIslandAwake.reset(island1);
		mIslandHandles.freeHandle(island1);
		mFastRoute[node1.index()] = node0;
		return island0;
	}
	else
	{
		mergeIslandsInternal(is1, is0, island1, island0, node1, node0);
		mIslandAwake.reset(island0);
		mIslandHandles.freeHandle(island0);
		mFastRoute[node0.index()] = node1;
		return island1;
	}
}

bool IslandSim::checkInternalConsistency() const
{
	//Loop over islands, confirming that the island data is consistent...
	//Really expensive. Turn off unless investigating some random issue...
#if 0
	for (PxU32 a = 0; a < mIslands.size(); ++a)
	{
		const Island& island = mIslands[a];

		PxU32 expectedNodeCount = 0;
		for (PxU32 t = 0; t < Node::eTYPE_COUNT; ++t)
		{
			expectedNodeCount += island.mNodeCount[t];
		}
		bool metLastNode = expectedNodeCount == 0;

		PxNodeIndex nodeId = island.mRootNode;

		while (nodeId.index() != PX_INVALID_NODE)
		{
			PX_ASSERT(mIslandIds[nodeId.index()] == a);

			if (nodeId.index() == island.mLastNode.index())
			{
				metLastNode = true;
				PX_ASSERT(mNodes[nodeId.index()].mNextNode.index() == PX_INVALID_NODE);
			}

			--expectedNodeCount;

			nodeId = mNodes[nodeId.index()].mNextNode;
		}

		PX_ASSERT(expectedNodeCount == 0);
		PX_ASSERT(metLastNode);
	}
#endif

	return true;
}

void IslandSim::mergeIslandsInternal(Island& island0, Island& island1, IslandId islandId0, IslandId islandId1, PxNodeIndex nodeIndex0, PxNodeIndex nodeIndex1)
{
#if PX_ENABLE_ASSERTS
	PxU32 island0Size = 0;
	PxU32 island1Size = 0;
	for(PxU32 nodeType = 0; nodeType < Node::eTYPE_COUNT; ++nodeType)
	{
		island0Size += island0.mNodeCount[nodeType];
		island1Size += island1.mNodeCount[nodeType];
	}
#endif
	PX_ASSERT(island0Size >= island1Size); //We only ever merge the smaller island to the larger island
	//Stage 1 - we need to move all the nodes across to the new island ID (i.e. write all their new island indices, move them to the 
	//island and then also update their estimated hop counts to the root. As we don't want to do a full traversal at this point,
	//instead, we estimate based on the route from the node to their previous root and then from that root to the new connection
	//between the 2 islands. This is probably a very indirect route but it will be refined later.

	//In this case, island1 is subsumed by island0

	//It takes mHopCounts[nodeIndex1] to get from node1 to its old root. It takes mHopCounts[nodeIndex0] to get from nodeIndex0 to the new root
	//and it takes 1 extra hop to go from node1 to node0. Therefore, a sub-optimal route can be planned going via the old root node that should take
	//mHopCounts[nodeIndex0] + mHopCounts[nodeIndex1] + 1 + mHopCounts[nodeIndex] to travel from any arbitrary node (nodeIndex) in island1 to the root
	//of island2.

	const PxU32 extraPath = mHopCounts[nodeIndex0.index()] + mHopCounts[nodeIndex1.index()] + 1;

	PxNodeIndex islandNode = island1.mRootNode;
	while(islandNode.index() != PX_INVALID_NODE)
	{
		mHopCounts[islandNode.index()] += extraPath;
		writeIslandId(islandNode.index()) = islandId0;

		//mFastRoute[islandNode] = PX_INVALID_NODE;
		
		Node& node = mNodes[islandNode.index()];
		islandNode = node.mNextNode;
	}

	//Now fill in the hop count for node1, which is directly connected to node0.
	mHopCounts[nodeIndex1.index()] = mHopCounts[nodeIndex0.index()] + 1;
	Node& lastNode = mNodes[island0.mLastNode.index()];
	Node& firstNode = mNodes[island1.mRootNode.index()];
	PX_ASSERT(lastNode.mNextNode.index() == PX_INVALID_NODE);
	PX_ASSERT(firstNode.mPrevNode.index() == PX_INVALID_NODE);
	PX_ASSERT(island1.mRootNode.index() != island0.mLastNode.index());

	PX_ASSERT(mNodes[island0.mLastNode.index()].mNextNode.index() == PX_INVALID_NODE);
	PX_ASSERT(mNodes[island1.mLastNode.index()].mNextNode.index() == PX_INVALID_NODE);

	PX_ASSERT(mIslandIds[island0.mLastNode.index()] == islandId0);

	lastNode.mNextNode = island1.mRootNode;
	firstNode.mPrevNode = island0.mLastNode;

	island0.mLastNode = island1.mLastNode;
	//island0.mStaticTouchCount += island1.mStaticTouchCount;
	writeIslandStaticTouchCount(islandId0) += mIslandStaticTouchCount[islandId1];

	//Merge the edge list for the islands...
	for(PxU32 a = 0; a < IG::Edge::eEDGE_TYPE_COUNT; ++a)
		mergeEdges(mEdges, island0.mEdges, island1.mEdges, Edge::EdgeType(a));

	for (PxU32 a = 0; a < IG::Node::eTYPE_COUNT; ++a)
	{
		island0.mNodeCount[a] += island1.mNodeCount[a];
		island1.mNodeCount[a] = 0;
	}

	island1.mLastNode.setIndices(PX_INVALID_NODE);
	island1.mRootNode.setIndices(PX_INVALID_NODE);
	
	writeIslandStaticTouchCount(islandId1) = 0;
	//island1.mStaticTouchCount = 0;
	
	//Remove from active island list
	if(island1.mActiveIndex != IG_INVALID_ISLAND)
		markIslandInactive(islandId1);
}

void IslandSim::removeEdgeFromActivatingList(EdgeIndex index)
{
	Edge& edge = mEdges[index];

	if (edge.mEdgeState & Edge::eACTIVATING)
	{
		for (PxU32 a = 0, count = mActivatedEdges[edge.mEdgeType].size(); a < count; a++)
		{
			if (mActivatedEdges[edge.mEdgeType][a] == index)
			{
				mActivatedEdges[edge.mEdgeType].replaceWithLast(a);
				break;
			}
		}

		edge.mEdgeState &= (~Edge::eACTIVATING);
	}

	const PxNodeIndex nodeIndex1 = mCpuData.mEdgeNodeIndices[index * 2];
	const PxNodeIndex nodeIndex2 = mCpuData.mEdgeNodeIndices[index * 2 + 1];

	if (nodeIndex1.isValid() && nodeIndex2.isValid())
	{
		mNodes[nodeIndex1.index()].mActiveRefCount--;
		mNodes[nodeIndex2.index()].mActiveRefCount--;
	}

	if(mGpuData && edge.mEdgeType == Edge::eCONTACT_MANAGER)
		mGpuData->mActiveContactEdges.reset(index);
}

void IslandSim::setKinematic(PxNodeIndex nodeIndex)
{
	Node& node = mNodes[nodeIndex.index()];

	if(!node.isKinematic())
	{
        markPreSolveNode(nodeIndex.index());
		//Transition from dynamic to kinematic:
		//(1) Remove this node from the island
		//(2) Remove this node from the active node list
		//(3) If active or referenced, add it to the active kinematic list
		//(4) Tag the node as kinematic
		//External code will re-filter interactions and lost touches will be reported

		const IslandId islandId = mIslandIds[nodeIndex.index()];
		PX_ASSERT(islandId != IG_INVALID_ISLAND);

		Island& island = mIslands[islandId];

        // Prescribed motion no longer contributes static edges to the dynamic
        // island. Clear its local count as well: switching back to dynamic
        // reinserts those edges and must not count the previous lifetime twice.
        writeIslandStaticTouchCount(islandId) -= node.mStaticTouchCount;
        node.mStaticTouchCount = 0;

		writeIslandId(nodeIndex.index()) = IG_INVALID_ISLAND;

		removeNodeFromIsland(island, nodeIndex);

		const bool isActive = node.isActive()!=0;

		if (isActive)
		{
			//Remove from active list...
			markInactive(nodeIndex);
		}
		else if (node.isActivating())
		{
			//Remove from activating list...
			node.clearActivating();
			PX_ASSERT(mActivatingNodes[mActiveNodeIndex[nodeIndex.index()]].index() == nodeIndex.index());

			const PxNodeIndex replaceIndex = mActivatingNodes[mActivatingNodes.size() - 1];
			mActiveNodeIndex[replaceIndex.index()] = mActiveNodeIndex[nodeIndex.index()];
			mActivatingNodes[mActiveNodeIndex[nodeIndex.index()]] = replaceIndex;
			mActivatingNodes.forceSize_Unsafe(mActivatingNodes.size() - 1);
			mActiveNodeIndex[nodeIndex.index()] = PX_INVALID_NODE;
		}

		node.setKinematicFlag();

		node.clearActive();

		if (/*isActive || */node.mActiveRefCount != 0)
		{
			//Add to active kinematic list...
			PX_ASSERT(mActiveNodeIndex[nodeIndex.index()] == PX_INVALID_NODE);

			mActiveNodeIndex[nodeIndex.index()] = mActivatingNodes.size();
			mActivatingNodes.pushBack(nodeIndex);
			node.setActivating();
		}

		{
			//This node was potentially in an island with other bodies. We need to force an island recomputation in case the
			//islands became broken due to losing this connection. Same rules as losing a contact, we just 
			//tag the nodes directly connected to the lost edge as "dirty" and force an island recomputation if 
			//it resulted in lost connections
			EdgeInstanceIndex edgeId = node.mFirstEdgeIndex;
			while(edgeId != IG_INVALID_EDGE)
			{
				const EdgeInstance& instance = mEdgeInstances[edgeId];
				const EdgeInstanceIndex nextId = instance.mNextEdge;

				const PxU32 idx = edgeId/2;
				IG::Edge& edge = mEdges[edgeId/2];

				removeEdgeFromIsland(mEdges, island.mEdges, idx);

				removeConnectionInternal(idx);
				removeConnectionFromGraph(idx);

				edge.clearInserted();

				if (edge.isActive())
				{
					removeEdgeFromActivatingList(idx);
					edge.deactivateEdge();
					mActiveEdgeCount[edge.mEdgeType]--;
					mDeactivatingEdges[edge.mEdgeType].pushBack(idx);
				}

				if(!edge.isPendingDestroyed())
				{
					if(!edge.isInDirtyList())
					{
						PX_ASSERT(!contains(mDirtyEdges[edge.mEdgeType], idx));
						mDirtyEdges[edge.mEdgeType].pushBack(idx);
						edge.markInDirtyList();
					}
				}
				else
				{
					edge.setReportOnlyDestroy();
				}

				edgeId = nextId;
			}
		}

		PxU32 newNodeCount = 0;
		for(PxU32 i = 0; i < Node::eTYPE_COUNT; ++i)
			newNodeCount += island.mNodeCount[i];

		if(newNodeCount == 0)
		{
			// If this island is empty after having removed the edges of the node we've just set to kinematic
			// we invalidate all edges and set the island to inactive
			for(PxU32 a = 0; a < Edge::eEDGE_TYPE_COUNT; ++a)
			{
				invalidateEdges(island.mEdges, Edge::EdgeType(a));

				writeIslandStaticTouchCount(islandId) = 0;
				//island.mStaticTouchCount = 0;
			}

			if(island.mActiveIndex != IG_INVALID_ISLAND)
			{
				markIslandInactive(islandId);
			}

			mIslandAwake.reset(islandId);
			mIslandHandles.freeHandle(islandId);
		}
	}
}

void IslandSim::setDynamic(PxNodeIndex nodeIndex)
{

	//(1) Remove all edges involving this node from all islands they may be in
	//(2) Mark all edges as "new" edges - let island gen re-process them!
	//(3) Remove this node from the active kinematic list
	//(4) Add this node to the active dynamic list (if it is active)
	//(5) Mark node as dynamic
	
	Node& node = mNodes[nodeIndex.index()];

	if(node.isKinematic())
	{
    if(mGpuData){mPreSolveLifetimes.resize(PxMax(nodeIndex.index()+1,mPreSolveLifetimes.size()),0);++mPreSolveLifetimes[nodeIndex.index()];}
        markPreSolveNode(nodeIndex.index());

		//EdgeInstanceIndex edgeIndex = node.mFirstEdgeIndex;

		EdgeInstanceIndex edgeId = node.mFirstEdgeIndex;
		while(edgeId != IG_INVALID_EDGE)
		{
			const EdgeInstance& instance = mEdgeInstances[edgeId];
			const EdgeInstanceIndex nextId = instance.mNextEdge;

			const PxNodeIndex otherNode = mCpuData.mEdgeNodeIndices[edgeId^1];

			const PxU32 idx = edgeId/2;
			IG::Edge& edge = mEdges[edgeId/2];

			if(!otherNode.isStaticBody())
			{
				const IslandId islandId = mIslandIds[otherNode.index()];
				if(islandId != IG_INVALID_ISLAND)
					removeEdgeFromIsland(mEdges, mIslands[islandId].mEdges, idx);
			}

			removeConnectionInternal(idx);
			removeConnectionFromGraph(idx);

			edge.clearInserted();
			if (edge.isActive())
			{
				edge.deactivateEdge();
				removeEdgeFromActivatingList(idx);
				mActiveEdgeCount[edge.mEdgeType]--;
			}
			
			if(!edge.isPendingDestroyed())
			{
				if(!edge.isInDirtyList())
				{
					PX_ASSERT(!contains(mDirtyEdges[edge.mEdgeType], idx));
					mDirtyEdges[edge.mEdgeType].pushBack(idx);
					edge.markInDirtyList();
				}
			}
			else
			{
				edge.setReportOnlyDestroy();
			}

			edgeId = nextId;
		}

		if(!node.isActivating() && mActiveNodeIndex[nodeIndex.index()] != PX_INVALID_NODE)
		{
			//Remove from active kinematic list, add to active dynamic list
			const PxU32 oldRefCount = node.mActiveRefCount;
			node.mActiveRefCount = 0;
			markKinematicInactive(nodeIndex);
			node.mActiveRefCount = oldRefCount;
		}

		node.clearKinematicFlag();

		//Create an island for this node. If there are any edges affecting this node, they will have been marked as 
		//"new" and will be processed next island update.
		{
			const IslandId islandHandle = mIslandHandles.getHandle();
			
			if(islandHandle == mIslands.capacity())
			{
				const PxU32 newCapacity = 2*mIslands.capacity()+1;
				mIslands.reserve(newCapacity);
				mIslandAwake.resize(newCapacity);
				mIslandStaticTouchCount.resize(newCapacity);
			}
			mIslandAwake.reset(islandHandle);
			mIslands.resize(PxMax(islandHandle+1, mIslands.size()));
			mIslandStaticTouchCount.resize(PxMax(islandHandle + 1, mIslands.size()));
			Island& island = mIslands[islandHandle];
			island.mLastNode = island.mRootNode = nodeIndex;
			PX_ASSERT(mNodes[nodeIndex.index()].mNextNode.index() == PX_INVALID_NODE);
			island.mNodeCount[node.mType] = 1;
			writeIslandId(nodeIndex.index()) = islandHandle;
			writeIslandStaticTouchCount(islandHandle) = 0;

			if(node.isActive())
			{
				node.clearActive();

				activateNode(nodeIndex);
			}
		}
	}
}
