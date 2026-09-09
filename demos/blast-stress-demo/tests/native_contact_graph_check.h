// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgDestructionRuntime.h"
#include "PxgShapeSim.h"
#include "PxgNphaseImplementationContext.h"
#include "PxgNarrowphaseCore.h"
#include "PxgSimulationController.h"
#include "NpScene.h"
#include "ScActorSim.h"
#include "ScInteraction.h"
#include "PxsSimpleIslandManager.h"
#include <cuda.h>
#include <map>
#include <string>
#include <vector>
#include <stdexcept>
namespace nativeGraphTest {
using namespace physx;
inline void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
inline void cudaCheck(CUresult result){require(result==CUDA_SUCCESS,"GPU graph observation failed");}
inline void verify(PxScene& scene,PxCudaContextManager& cuda) {
    auto* runtime=static_cast<PxgSimulationController*>(static_cast<NpScene&>(scene).getScScene().getSimulationController())->getNativeDestructionRuntime();
    const auto view=runtime->getContactGraphView();
    require(view.generation && view.readyEvent && view.status,"native contact component snapshot missing");
    PxScopedCudaLock lock(cuda);cudaCheck(cuEventSynchronize(view.readyEvent));
    PxgDestructionContactGraphStatus status;cudaCheck(cuMemcpyDtoH(&status,CUdeviceptr(view.status),sizeof(status)));
    require(!status.error && !status.omittedPairs,"native rigid fixture produced an incomplete contact graph");
    std::vector<PxgContactManagerInput> inputs(view.pairCount);
    std::vector<PxgContactGraphIdentity> identities(view.pairCount);
    std::vector<PxgShapeSim> shapes(view.shapeCapacity);
    std::vector<PxU32> retired((size_t(view.pairCount)+31)/32);
    std::vector<PxU32> accurate(view.nodeCapacity),speculative(view.nodeCapacity);
    if(view.pairCount) {
        cudaCheck(cuMemcpyDtoH(inputs.data(),CUdeviceptr(view.inputs),inputs.size()*sizeof(inputs[0])));
        cudaCheck(cuMemcpyDtoH(identities.data(),CUdeviceptr(view.identities),identities.size()*sizeof(identities[0])));
    }
    if(view.shapeCapacity)cudaCheck(cuMemcpyDtoH(shapes.data(),CUdeviceptr(view.shapes),shapes.size()*sizeof(shapes[0])));
    if(view.retiredMask && !retired.empty())cudaCheck(cuMemcpyDtoH(retired.data(),CUdeviceptr(view.retiredMask),retired.size()*sizeof(PxU32)));
    if(view.nodeCapacity) {
        cudaCheck(cuMemcpyDtoH(accurate.data(),CUdeviceptr(view.accurateLabels),accurate.size()*sizeof(PxU32)));
        cudaCheck(cuMemcpyDtoH(speculative.data(),CUdeviceptr(view.speculativeLabels),speculative.size()*sizeof(PxU32)));
    }
    auto& sc=static_cast<NpScene&>(scene).getScScene();
    auto& np=*static_cast<PxgNphaseImplementationContext*>(sc.getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
    std::vector<PxU32> expectedRetired(retired.size());PxU32 offset=0;
    for(PxU32 b=GPU_BUCKET_ID::eConvex;b<=GPU_BUCKET_ID::eConvexCoreTrimesh;++b) {
        for(PxU32 j=0;j<np.mRemovedIndices[b]->size();++j) {
            const PxU32 index=offset+(*np.mRemovedIndices[b])[j];require(index<view.pairCount,"CPU retirement exceeds graph domain");
            expectedRetired[index>>5]|=1u<<(index&31);
        }
        offset+=np.getExistingContactManagers(GPU_BUCKET_ID::Enum(b)).mCpuContactManagerMapping.size();
    }
    if(offset!=view.pairCount || retired!=expectedRetired)throw std::runtime_error(
        "GPU graph dropped or retained the wrong contact rows: gpu-count="+std::to_string(view.pairCount)
        +" current-cpu-count="+std::to_string(offset)+" mask-equal="+std::to_string(retired==expectedRetired)
        +" generation="+std::to_string(view.generation));
    auto& manager=*sc.getSimpleIslandManager();
    const auto& cpuAccurate=manager.getAccurateIslandSim();const auto& cpuSpeculative=manager.getSpeculativeIslandSim();
    // Independent CPU flood fill over the actual inserted island edges. This
    // does not trust island IDs or CUDA labels to decide connectivity, including
    // when CUDA is now the producer of the island partition under test.
    const auto floodCheck=[&](const IG::IslandSim& sim,const std::vector<PxU32>& gpu) {
        const PxU32 n=sim.getNbNodes();std::vector<std::vector<PxU32>> adjacency(n);
        const auto dynamic=[&](PxU32 i){return i<n && !sim.getNode(PxNodeIndex(i)).isDeleted()
            && !sim.getNode(PxNodeIndex(i)).isKinematic() && sim.getIslandIds()[i]!=IG_INVALID_ISLAND;};
        for(PxU32 e=0;e<sim.getNbEdges();++e) {
            const auto& edge=sim.getEdge(e);if(!edge.isInserted() || edge.isPendingDestroyed())continue;
            const PxU32 a=sim.mCpuData.mEdgeNodeIndices[2*e].index(),b=sim.mCpuData.mEdgeNodeIndices[2*e+1].index();
            if(dynamic(a) && dynamic(b)){adjacency[a].push_back(b);adjacency[b].push_back(a);}
        }
        std::vector<PxU32> labels(n,PX_INVALID_U32),queue;
        std::map<PxU32,PxU32> islandRoots;
        for(PxU32 i=0;i<n;++i)if(dynamic(i) && labels[i]==PX_INVALID_U32) {
            queue.clear();queue.push_back(i);labels[i]=i;
            for(size_t j=0;j<queue.size();++j)for(PxU32 next:adjacency[queue[j]])
                if(labels[next]==PX_INVALID_U32){labels[next]=i;queue.push_back(next);}
            const PxU32 island=sim.getIslandIds()[i];
            // Device ownership deliberately keeps a coarse CPU compatibility
            // partition. GPU components still must match the independent flood fill exactly.
            if(!sim.deviceConnectivityOwned())require(islandRoots.emplace(island,i).second,"CPU island contains disconnected components");
            for(PxU32 node:queue) {
                require(node<gpu.size() && gpu[node]==i,"CUDA components differ from independent CPU edge flood fill");
                require(sim.getIslandIds()[node]==island,"connected CPU edges span separate islands");
            }
        }
    };
    floodCheck(cpuAccurate,accurate);floodCheck(cpuSpeculative,speculative);
    std::map<PxU32,PxU32> accurateToGpu,accurateToCpu,speculativeToGpu,speculativeToCpu;
    const auto associate=[](std::map<PxU32,PxU32>& map,PxU32 from,PxU32 to){
        const auto result=map.emplace(from,to);return result.second || result.first->second==to;
    };
    std::map<PxU64,PxU32> shapePairs;
    for(PxU32 p=0;p<view.pairCount;++p) {
        if(retired[p>>5]&(1u<<(p&31)))continue;
        const auto* interaction=manager.getInteractionFromEdgeIndex(identities[p].edgeIndex);
        require(interaction,"GPU contact edge lacks a CPU interaction");
        const auto a=interaction->getActorSim0().getNodeIndex(),b=interaction->getActorSim1().getNodeIndex();
        const auto& input=inputs[p];
        const PxU32 lo=PxMin(input.transformCacheRef0,input.transformCacheRef1);
        const PxU32 hi=PxMax(input.transformCacheRef0,input.transformCacheRef1);
        const auto inserted=shapePairs.emplace((PxU64(lo)<<32)|hi,p);
        if(!inserted.second)throw std::runtime_error(
            "two live contact managers resolve to the same persistent shape pair: shapes="
            +std::to_string(lo)+","+std::to_string(hi)+" rows="+std::to_string(inserted.first->second)+","+std::to_string(p)
            +" edges="+std::to_string(identities[inserted.first->second].edgeIndex)+","+std::to_string(identities[p].edgeIndex)
            +" graph-generation="+std::to_string(view.generation));
        require(input.transformCacheRef0<view.shapeCapacity && input.transformCacheRef1<view.shapeCapacity,"GPU graph has invalid shape references");
        require(shapes[input.transformCacheRef0].mBodySimIndex==a && shapes[input.transformCacheRef1].mBodySimIndex==b,"GPU graph resolved stale cluster ownership");
        for(const auto node:{a,b}) {
            if(!node.isValid() || cpuAccurate.getNode(node).isKinematic())continue;
            const auto i=node.index();require(i<view.nodeCapacity,"GPU graph node capacity misses live body");
            const auto ca=cpuAccurate.getIslandIds()[i],cs=cpuSpeculative.getIslandIds()[i];
            require((cpuAccurate.deviceConnectivityOwned() || associate(accurateToGpu,ca,accurate[i])) && associate(accurateToCpu,accurate[i],ca),
                "GPU accurate components disagree with PhysX CPU islands");
            require((cpuSpeculative.deviceConnectivityOwned() || associate(speculativeToGpu,cs,speculative[i])) && associate(speculativeToCpu,speculative[i],cs),
                "GPU speculative components disagree with PhysX CPU islands");
        }
    }
}
}
