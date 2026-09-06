// Native-demo diagnostics only. Simulation still uses the public scene lifecycle.
#pragma once
#include "NpScene.h"
#include "PxgNphaseImplementationContext.h"
#include "PxgNarrowphaseCore.h"
#include "PxgDestructionRuntime.h"
#include "PxgContext.h"
#include "PxgSolverCore.h"
#include "cudamanager/PxCudaContextManager.h"
#include <algorithm>
#include <vector>
#include "PxsSimpleIslandManager.h"
#include <fstream>
#include <stdexcept>
#include <string>
inline void writeNativeGraphDiagnostics(physx::PxScene& scene,const std::string& path) {
    using namespace physx;
    auto& sc=static_cast<NpScene&>(scene).getScScene();
    auto& np=*static_cast<PxgNphaseImplementationContext*>(sc.getLowLevelContext()->getNphaseImplementationContext())->getGpuNarrowphaseCore();
    auto& islands=*sc.getSimpleIslandManager();
    const auto& a=islands.getAccurateIslandSim();const auto& s=islands.getSpeculativeIslandSim();
    auto* runtime=static_cast<PxgDestructionRuntime*>(scene.getDestructionScene());
    const auto stats=runtime->getContactGraphObservationStats();
    const auto metadata=static_cast<PxgGpuContext*>(sc.getDynamicsContext())->getSolverIslandMetadataStats();
    std::ofstream out(path);
    out<<"{\n  \"scope\": \"contact graph and pre-solver island metadata submissions (including correction); excludes diagnostic reads, other physics and recording transfers\",\n"
        <<"  \"graph_builds\": "<<np.getDestructionGraphBuildCount()<<",\n"
        <<"  \"same_pass_reuses\": "<<np.getDestructionGraphReuseCount()<<",\n"
        <<"  \"host_observations\": "<<stats.observations<<",\n"
        <<"  \"sorted_graphs\": "<<stats.sortedGraphs<<",\n"
        <<"  \"device_to_host_bytes\": "<<stats.deviceToHostBytes<<",\n"
        <<"  \"gpu_connected_answers\": "<<a.getGpuRouteCount()+s.getGpuRouteCount()<<",\n"
        <<"  \"gpu_splits\": "<<a.getGpuSplitCount()+s.getGpuSplitCount()<<",\n"
        <<"  \"retained_edges_uploaded\": "<<stats.retainedEdgesUploaded<<",\n"
        <<"  \"retained_host_to_device_bytes\": "<<stats.retainedHostToDeviceBytes<<",\n"
        <<"  \"retained_delta_updates\": "<<stats.retainedDeltaUpdates<<",\n"
        <<"  \"retained_slot_capacity\": "<<stats.retainedSlotCapacity<<",\n"
        <<"  \"peak_retained_edges\": "<<stats.peakRetainedEdges<<",\n"
        <<"  \"boundary_audits\": "<<a.getGpuComponentAudits()+s.getGpuComponentAudits()<<",\n"
        <<"  \"boundary_audit_failures\": "<<a.getGpuComponentAuditFailures()+s.getGpuComponentAuditFailures()<<",\n"
        <<"  \"solver_metadata_passes\": "<<metadata.passes<<",\n"
        <<"  \"solver_metadata_full_uploads\": "<<metadata.fullUploads<<",\n"
        <<"  \"solver_metadata_page_uploads\": "<<metadata.pageUploads<<",\n"
        <<"  \"solver_metadata_quiet_passes\": "<<metadata.quietPasses<<",\n"
        <<"  \"solver_metadata_host_to_device_bytes\": "<<metadata.hostToDeviceBytes<<",\n"
        <<"  \"solver_metadata_full_equivalent_bytes\": "<<metadata.fullEquivalentBytes<<",\n"
        <<"  \"solver_metadata_pages\": "<<metadata.pages<<",\n"
        <<"  \"registry_mismatch_fallbacks\": "<<a.getGpuRepairFallbackCount()+s.getGpuRepairFallbackCount()<<"\n}\n";
    out.close();if(!out)throw std::runtime_error("failed to write native graph diagnostics");
}

inline void setNativeGraphAudit(physx::PxScene& scene,bool enabled) {
    auto& islands=*static_cast<physx::NpScene&>(scene).getScScene().getSimpleIslandManager();
    auto& sc=static_cast<physx::NpScene&>(scene).getScScene();
    static_cast<physx::PxgGpuContext*>(sc.getDynamicsContext())->captureSolverIslandMetadata(enabled);
    islands.getAccurateIslandSim().setGpuComponentAudit(enabled);
    islands.getSpeculativeIslandSim().setGpuComponentAudit(enabled);
}
inline void requireNativeGraphAudit(physx::PxScene& scene,const std::string& path) {
    using namespace physx;
    auto& sc=static_cast<NpScene&>(scene).getScScene();
    auto& gpu=*static_cast<PxgGpuContext*>(sc.getDynamicsContext());
    const auto& ids=gpu.getExpectedSolverIslandIds();const auto& touches=gpu.getExpectedSolverStaticTouches();
    std::vector<PxU32> actualIds(ids.size()),actualTouches(touches.size());
    CUdeviceptr dIds=0,dTouches=0;gpu.getGpuSolverCore()->getSolverIslandMetadataPointers(dIds,dTouches);
    {
        PxScopedCudaLock lock(*scene.getCudaContextManager());
        if(cuStreamSynchronize(gpu.getGpuSolverCore()->getStream())!=CUDA_SUCCESS
            || (!ids.empty() && cuMemcpyDtoH(actualIds.data(),dIds,ids.size()*sizeof(PxU32))!=CUDA_SUCCESS)
            || (!touches.empty() && cuMemcpyDtoH(actualTouches.data(),dTouches,touches.size()*sizeof(PxU32))!=CUDA_SUCCESS))
            throw std::runtime_error("native solver metadata audit readback failed");
    }
    if(!std::equal(actualIds.begin(),actualIds.end(),ids.begin())
        || !std::equal(actualTouches.begin(),actualTouches.end(),touches.begin()))
        throw std::runtime_error("native solver metadata differs from independent pre-solve snapshot");
    auto& islands=*static_cast<physx::NpScene&>(scene).getScScene().getSimpleIslandManager();
    if(islands.getAccurateIslandSim().getGpuComponentAuditFailures()
        || islands.getSpeculativeIslandSim().getGpuComponentAuditFailures()) {
        writeNativeGraphDiagnostics(scene,path);
        throw std::runtime_error("native GPU island boundary audit failed; capture incomplete");
    }
}
