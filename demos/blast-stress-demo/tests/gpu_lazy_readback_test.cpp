// Exercise the high-level city solver, not only the low-level CUDA operator.
#include "../physx_scene.h"
#include "ext_stress_bridge.h"
#include <algorithm>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <stdexcept>
#include <thread>
#include <vector>

namespace {
void require(bool value, const char* message) { if (!value) throw std::runtime_error(message); }
struct Graph {
    std::vector<ExtStressNodeDesc> nodes;
    std::vector<ExtStressBondDesc> bonds;
    explicit Graph(bool skew = false) {
        constexpr unsigned side = 11;
        const auto index = [](unsigned x, unsigned y, unsigned z) { return x + side*(y + side*z); };
        for (unsigned z=0; z<side; ++z) for (unsigned y=0; y<side; ++y) for (unsigned x=0; x<side; ++x) {
            ExtStressNodeDesc node{};
            node.centroid = skew
                ? StressVec3{float(x)+0.13f*y+0.07f*z, float(y)+0.09f*x+0.03f*z,
                             float(z)+0.11f*x-0.05f*y}
                : StressVec3{float(x),float(y),float(z)};
            node.mass = y ? 1.0f + float((x+z)%3) : 0.0f;
            node.volume = 1.0f;
            nodes.push_back(node);
        }
        for (unsigned z=0; z<side; ++z) for (unsigned y=0; y<side; ++y) for (unsigned x=0; x<side; ++x) {
            for (unsigned axis=0; axis<3; ++axis) {
                unsigned next[3] = {x,y,z};
                if (++next[axis] >= side) continue;
                ExtStressBondDesc bond{};
                bond.node0=index(x,y,z); bond.node1=index(next[0],next[1],next[2]);
                const auto& a=nodes[bond.node0].centroid; const auto& b=nodes[bond.node1].centroid;
                bond.centroid={(a.x+b.x)*0.5f,(a.y+b.y)*0.5f,(a.z+b.z)*0.5f};
                bond.normal={b.x-a.x,b.y-a.y,b.z-a.z};
                bond.area=1.0f+float((x+2*y+z)%4)*0.25f;
                bonds.push_back(bond);
            }
        }
    }
};
struct Solver {
    ExtStressSolverHandle* handle;
    std::vector<bool> removed;
    bool parallelWalk{false};
    explicit Solver(const Graph& graph, void* context, bool lazy) : removed(graph.bonds.size(), false) {
        setenv("BLAST_GPU_IMPULSE_READBACK",lazy ? "0" : "1",1);
        ExtStressMaterialDesc material{};
        material.compression_elastic_limit=material.tension_elastic_limit=material.shear_elastic_limit=1e15f;
        material.compression_fatal_limit=material.tension_fatal_limit=material.shear_fatal_limit=2e15f;
        ExtStressSolverSettingsDesc settings{2,0};
        handle=ext_stress_solver_create(graph.nodes.data(),graph.nodes.size(),graph.bonds.data(),graph.bonds.size(),&material,1,&settings);
        require(handle,"create high-level solver failed");
        ext_stress_solver_set_gpu_cuda_context(handle,context);
        ext_stress_solver_set_gpu_minimum_bond_count(handle,0);
        require(ext_stress_solver_set_gpu_accelerated(handle,1),"GPU request failed");
        ext_stress_solver_set_skip_settled(handle,1);
    }
    ~Solver() { ext_stress_solver_destroy(handle); }
    void update(StressVec3 gravity, bool gpu = true) {
        ext_stress_solver_set_defer_bond_stress(handle,parallelWalk);
        ext_stress_solver_add_gravity(handle,&gravity);
        ext_stress_solver_update(handle);
        if (parallelWalk) {
            std::vector<std::thread> workers;
            for (unsigned strip=0;strip<ext_stress_solver_bond_stress_strip_count(handle);++strip)
                workers.emplace_back([this,strip] { ext_stress_solver_bond_stress_strip(handle,strip); });
            for (auto& worker:workers) worker.join();
            ext_stress_solver_bond_stress_complete(handle);
            ext_stress_solver_set_defer_bond_stress(handle,0);
        }
        require(bool(ext_stress_solver_get_gpu_accelerated(handle)) == gpu,"unexpected solver backend");
    }
    std::vector<float> values(unsigned count) const {
        std::vector<float> result(4*count);
        require(ext_stress_solver_get_bond_stresses(handle,result.data(),result.data()+count,result.data()+2*count,count)==count,"stress read incomplete");
        require(ext_stress_solver_get_bond_healths(handle,result.data()+3*count,count)==count,"health read incomplete");
        for (float value:result) require(std::isfinite(value),"nonfinite stress/health");
        return result;
    }
    void remove(const Graph& graph, unsigned bondIndex) {
        require(!removed[bondIndex],"fixture repeated a fracture");
        std::vector<ExtStressActor> actors(graph.nodes.size());
        std::vector<uint32_t> actorNodes(graph.nodes.size());
        unsigned actorCount=0,nodeCount=0;
        require(ext_stress_solver_collect_actors(handle,actors.data(),actors.size(),actorNodes.data(),actorNodes.size(),&actorCount,&nodeCount)==1,"actor read failed");
        const auto& bond=graph.bonds[bondIndex];
        unsigned owner=~0u;
        for (unsigned i=0;i<actorCount;++i) {
            const auto& a=actors[i];
            if (!a.nodeCount) continue;
            require(a.nodes,"actor nodes were truncated");
            if (std::find(a.nodes,a.nodes+a.nodeCount,bond.node0)!=a.nodes+a.nodeCount
                && std::find(a.nodes,a.nodes+a.nodeCount,bond.node1)!=a.nodes+a.nodeCount) owner=a.actorIndex;
        }
        if (owner == ~0u) {
            const auto health = values(graph.bonds.size());
            std::fprintf(stderr,"missing owner bond=%u nodes=%u,%u actors=%u health=%.9g\n",bondIndex,bond.node0,bond.node1,actorCount,health[3*graph.bonds.size()+bondIndex]);
        }
        require(owner!=~0u,"bond owner missing");
        ExtStressBondFracture fracture{0,bond.node0,bond.node1,1000.0f};
        ExtStressFractureCommands commands{owner,&fracture,1,0};
        ExtStressSplitEvent events[16]{}; ExtStressActor children[16]{};
        std::vector<uint32_t> nodes(graph.nodes.size()*2);
        unsigned eventCount=0,childCount=0,written=0;
        require(ext_stress_solver_apply_fracture_commands(handle,&commands,1,events,16,children,16,&eventCount,&childCount,nodes.data(),nodes.size(),&written),"fracture apply failed");
        removed[bondIndex] = true;
    }
};
void compare(const Solver& eager,const Solver& lazy,unsigned count) {
    const auto a=eager.values(count), b=lazy.values(count);
    if (std::memcmp(a.data(),b.data(),a.size()*sizeof(float))) {
        for (unsigned i=0;i<a.size();++i) if(a[i]!=b[i]) {
            std::fprintf(stderr,"readback parity element=%u eager=%.9g lazy=%.9g\n",i,a[i],b[i]); break;
        }
        throw std::runtime_error("eager/lazy stress or health differs");
    }
    require(ext_stress_solver_converged(eager.handle)==ext_stress_solver_converged(lazy.handle),"convergence changed");
    require(ext_stress_solver_islands_skipped(eager.handle)==ext_stress_solver_islands_skipped(lazy.handle),"retirement policy changed");
}
}
int main(int argc,char** argv) {
    try {
        const bool cpuGpuWalk=argc>1 && std::strcmp(argv[1],"--cpu-gpu-walk")==0;
        const bool parallelWalk=cpuGpuWalk || (argc>1 && std::strcmp(argv[1],"--parallel-cpu-walk")==0);
        const bool cpuWalk=!cpuGpuWalk && (parallelWalk || (argc>1 && std::strcmp(argv[1],"--cpu-walk")==0));
        const bool eagerControl=argc>1 && std::strcmp(argv[1],"--eager-control")==0;
        setenv("BLAST_BOND_STRESS_GPU",cpuWalk ? "0" : "1",1);
        unsetenv("BLAST_GPU_NO_INCREMENTAL_REMOVAL");
        blast_demo::PhysXScene scene(blast_demo::PhysicsMode::Gpu,true,{},nullptr);
        // Oblique normals and non-unit distances exercise preparation of
        // the shared stress equation, not only its already-shared body.
        Graph graph(cpuGpuWalk);
        Solver eager(graph,scene.cudaContextManager()->getContext(),false);
        Solver lazy(graph,scene.cudaContextManager()->getContext(),!eagerControl);
        lazy.parallelWalk = parallelWalk;
        uint64_t saved=0; unsigned unconverged=0;
        for (unsigned tick=0;tick<40;++tick) {
            StressVec3 gravity{float(int(tick%7)-3)*0.3f,-9.81f,float(int(tick%5)-2)*0.2f};
            // Release/recreate the CUDA backend while its host mirror is
            // stale. The CPU observer must see the last device solution.
            if (tick == 19 || tick == 20) {
                require(ext_stress_solver_set_gpu_accelerated(eager.handle,tick == 20),"eager backend switch rejected");
                require(ext_stress_solver_set_gpu_accelerated(lazy.handle,tick == 20),"lazy backend switch rejected");
            }
            eager.update(gravity,tick != 19); lazy.update(gravity,tick != 19);
            const auto a=ext_stress_solver_gpu_device_to_host_bytes(eager.handle);
            const auto b=ext_stress_solver_gpu_device_to_host_bytes(lazy.handle);
            if (!ext_stress_solver_converged(lazy.handle)) {
                ++unconverged;
                if (!cpuWalk && !eagerControl && !cpuGpuWalk) { require(a>=b,"lazy path added impulse readback bytes"); saved+=a-b; }
            }
            compare(eager,lazy,graph.bonds.size());
            if (tick == 30) {
                // Split one >1,024-node island into three smaller islands.
                // This changes both tile ranges and captured graph parameters.
                for (unsigned index = 0; index < graph.bonds.size(); ++index) {
                    require(eager.removed[index] == lazy.removed[index],"fracture histories differ");
                    if (eager.removed[index]) continue;
                    const auto& bond = graph.bonds[index];
                    const unsigned x0 = bond.node0 % 11;
                    const unsigned x1 = bond.node1 % 11;
                    if ((x0 == 5 && x1 == 6) || (x0 == 8 && x1 == 9)) {
                        eager.remove(graph,index); lazy.remove(graph,index);
                    }
                }
                compare(eager,lazy,graph.bonds.size());
            }
            if (tick == 32) require(ext_stress_solver_islands_total(lazy.handle) >= 3,"partition split was not exercised");
            if (tick==8 || tick==15 || tick==23) {
                const unsigned index=unsigned(graph.bonds.size())-(tick==8 ? 1 : tick==15 ? 2 : 3);
                eager.remove(graph,index); lazy.remove(graph,index);
                // Observe after mutation and before the next solve, then let
                // incremental swap-with-last update both solver graphs.
                compare(eager,lazy,graph.bonds.size());
            }
        }
        require(unconverged>0,"fixture did not exercise capped GPU solves");
        if (!cpuWalk && !eagerControl && !cpuGpuWalk) require(saved>32*graph.bonds.size(),"no meaningful impulse transfer was removed");
        // Complete shattering is a valid GPU decline, not a CUDA failure.
        // It follows a capped solve whose host impulses are still stale.
        for (unsigned index = 0; index < graph.bonds.size(); ++index) {
            if (!eager.removed[index]) { eager.remove(graph,index); lazy.remove(graph,index); }
        }
        for (auto* solver : {&eager,&lazy}) {
            StressVec3 gravity{0,-9.81f,0};
            ext_stress_solver_add_gravity(solver->handle,&gravity);
            ext_stress_solver_update(solver->handle);
        }
        compare(eager,lazy,graph.bonds.size());
        const auto shattered = lazy.values(graph.bonds.size());
        for (unsigned i=0;i<graph.bonds.size();++i)
            require(shattered[3*graph.bonds.size()+i] == 0.0f,"complete shattering left a live bond");
        // A converged run still uses the original host steadiness check. Zero
        // load after reset makes convergence certain without relaxing a limit.
        ext_stress_solver_reset(eager.handle); ext_stress_solver_reset(lazy.handle);
        for(unsigned tick=0;tick<12;++tick) {
            eager.update({0,0,0}); lazy.update({0,0,0});
            compare(eager,lazy,graph.bonds.size());
            require(ext_stress_solver_converged(lazy.handle),"zero-load solve did not converge");
        }
        require(scene.healthy(),"PhysX error during GPU fixture");
        std::printf("lazy readback %s passed: 53 updates, 3 tail fractures, 2 island cuts, complete shattering, backend switching, %u unconverged, %llu bytes avoided\n",cpuGpuWalk?"CPU/GPU skewed-graph parity":cpuWalk?"CPU observer":"device walk",unconverged,(unsigned long long)saved);
        return 0;
    } catch(const std::exception& error) { std::fprintf(stderr,"%s\n",error.what()); return 1; }
}
