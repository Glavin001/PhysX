// Native-demo diagnostics only. Simulation still uses the public scene lifecycle.
#pragma once
#include "NpScene.h"
#include "PxgNphaseImplementationContext.h"
#include "PxgNarrowphaseCore.h"
#include "PxgDestructionRuntime.h"
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
    std::ofstream out(path);
    out<<"{\n  \"scope\": \"contact graph only; excludes other physics and recording transfers\",\n"
        <<"  \"graph_builds\": "<<np.getDestructionGraphBuildCount()<<",\n"
        <<"  \"same_pass_reuses\": "<<np.getDestructionGraphReuseCount()<<",\n"
        <<"  \"host_observations\": "<<stats.observations<<",\n"
        <<"  \"sorted_graphs\": "<<stats.sortedGraphs<<",\n"
        <<"  \"device_to_host_bytes\": "<<stats.deviceToHostBytes<<",\n"
        <<"  \"gpu_connected_answers\": "<<a.getGpuRouteCount()+s.getGpuRouteCount()<<",\n"
        <<"  \"gpu_splits\": "<<a.getGpuSplitCount()+s.getGpuSplitCount()<<",\n"
        <<"  \"retained_edges_uploaded\": "<<stats.retainedEdgesUploaded<<",\n"
        <<"  \"retained_host_to_device_bytes\": "<<stats.retainedHostToDeviceBytes<<",\n"
        <<"  \"peak_retained_edges\": "<<stats.peakRetainedEdges<<",\n"
        <<"  \"boundary_audits\": "<<a.getGpuComponentAudits()+s.getGpuComponentAudits()<<",\n"
        <<"  \"boundary_audit_failures\": "<<a.getGpuComponentAuditFailures()+s.getGpuComponentAuditFailures()<<",\n"
        <<"  \"registry_mismatch_fallbacks\": "<<a.getGpuRepairFallbackCount()+s.getGpuRepairFallbackCount()<<"\n}\n";
    out.close();if(!out)throw std::runtime_error("failed to write native graph diagnostics");
}

inline void setNativeGraphAudit(physx::PxScene& scene,bool enabled) {
    auto& islands=*static_cast<physx::NpScene&>(scene).getScScene().getSimpleIslandManager();
    islands.getAccurateIslandSim().setGpuComponentAudit(enabled);
    islands.getSpeculativeIslandSim().setGpuComponentAudit(enabled);
}
inline void requireNativeGraphAudit(physx::PxScene& scene,const std::string& path) {
    auto& islands=*static_cast<physx::NpScene&>(scene).getScScene().getSimpleIslandManager();
    if(islands.getAccurateIslandSim().getGpuComponentAuditFailures()
        || islands.getSpeculativeIslandSim().getGpuComponentAuditFailures()) {
        writeNativeGraphDiagnostics(scene,path);
        throw std::runtime_error("native GPU island boundary audit failed; capture incomplete");
    }
}
