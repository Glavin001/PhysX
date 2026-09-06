// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "PxgDestructionRuntime.h"
#include "PxgShapeSim.h"
#include "PxgNphaseImplementationContext.h"
#include "PxgNarrowphaseCore.h"
#include "NpScene.h"
#include "ScActorSim.h"
#include "ScInteraction.h"
#include "PxsSimpleIslandManager.h"
#include <cuda.h>
#include <map>
#include <vector>
#include <stdexcept>
namespace nativeGraphTest {
using namespace physx;
inline void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
inline void cudaCheck(CUresult result){require(result==CUDA_SUCCESS,"GPU graph observation failed");}
inline void verify(PxScene& scene,PxCudaContextManager& cuda) {
    auto* runtime=static_cast<PxgDestructionRuntime*>(scene.getDestructionScene());
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
    require(offset==view.pairCount && retired==expectedRetired,"GPU graph dropped or retained the wrong contact rows");
    auto& manager=*sc.getSimpleIslandManager();
    const auto& cpuAccurate=manager.getAccurateIslandSim();const auto& cpuSpeculative=manager.getSpeculativeIslandSim();
    std::map<PxU32,PxU32> accurateToGpu,accurateToCpu,speculativeToGpu,speculativeToCpu;
    const auto associate=[](std::map<PxU32,PxU32>& map,PxU32 from,PxU32 to){
        const auto result=map.emplace(from,to);return result.second || result.first->second==to;
    };
    for(PxU32 p=0;p<view.pairCount;++p) {
        if(retired[p>>5]&(1u<<(p&31)))continue;
        const auto* interaction=manager.getInteractionFromEdgeIndex(identities[p].edgeIndex);
        require(interaction,"GPU contact edge lacks a CPU interaction");
        const auto a=interaction->getActorSim0().getNodeIndex(),b=interaction->getActorSim1().getNodeIndex();
        const auto& input=inputs[p];
        require(input.transformCacheRef0<view.shapeCapacity && input.transformCacheRef1<view.shapeCapacity,"GPU graph has invalid shape references");
        require(shapes[input.transformCacheRef0].mBodySimIndex==a && shapes[input.transformCacheRef1].mBodySimIndex==b,"GPU graph resolved stale cluster ownership");
        for(const auto node:{a,b}) {
            if(!node.isValid() || cpuAccurate.getNode(node).isKinematic())continue;
            const auto i=node.index();require(i<view.nodeCapacity,"GPU graph node capacity misses live body");
            const auto ca=cpuAccurate.getIslandIds()[i],cs=cpuSpeculative.getIslandIds()[i];
            require(associate(accurateToGpu,ca,accurate[i]) && associate(accurateToCpu,accurate[i],ca),
                "GPU accurate components disagree with PhysX CPU islands");
            require(associate(speculativeToGpu,cs,speculative[i]) && associate(speculativeToCpu,speculative[i],cs),
                "GPU speculative components disagree with PhysX CPU islands");
        }
    }
}
}
