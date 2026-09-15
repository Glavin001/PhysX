// SPDX-License-Identifier: BSD-3-Clause
// Included after Replay.cu's I/O/allocation helpers. This diagnostic profile is
// deliberately explicit and uncalibrated; it never publishes material fracture.
#include "PxgDestructionElasticLoadJoin.cuh"
#include "StressElasticComponents.cuh"
#include "StressElasticPcg.cuh"
#include <memory>
namespace C=E::Partition;
namespace G=physx::destructionElasticGraph;
namespace J=physx::destructionElasticLoadJoin;
__global__ void fineConvergence(E::Components components,const E::SolveReceipt* receipts,const uint32_t* inputError,uint32_t* error) {
    const auto i=blockIdx.x*blockDim.x+threadIdx.x;
    if(!i && *inputError)atomicOr(error,1u);
    if(i<E::componentCount(components) && receipts[i].status!=E::SolveStatus::LinearConverged)atomicOr(error,1u);
}
template<class T> std::vector<T> activeRead(const Device<T>& device,size_t count) {
    if(count>device.n)throw std::runtime_error("active export exceeds allocation");
    std::vector<T> result(count);if(count)check(cudaMemcpy(result.data(),device.p,count*sizeof(T),cudaMemcpyDeviceToHost));return result;
}
struct FineReplay {
    uint32_t n,m,blocks=144;
    std::string prefix;
    bool setupOnly;
    Device<PxDestructionBondEndpoints> endpoints;
    Device<uint32_t> active,rows,references,prescribed,parents,roots,ids,sortedRoots,nodes,flags,scan,starts,owner,local,error;
    Device<E::Bond> bonds;
    Device<double> length,energy;
    Device<E::SetupKey> keys;
    Device<G::State> graphState;Device<J::State> joined;Device<C::State> components;
    Device<E::SetupState> setup;Device<E::SolveReceipt> receipts;
    Device<E::Vector> loads,rhs,initial,solution,x,r,p,z,v,truth,response;
    Device<E::Matrix> basis,factors;Device<uint32_t> reached,nextReached;
    std::unique_ptr<Device<char>> scratch;
    C::Storage storage{};E::SolveWorkspace workspace{};E::Graph graph{};E::Components partition{};
    E::SetupKey revisions{1,1,0,1,1,1,1};
    // The same strict FP64 numerical limits as standalone fixtures; allow the
    // native iteration cap, without changing any convergence condition.
    E::SolveProfile profile{1e-12,1e-10,1,1,1e-9,1e-9,1e-12,1e-11,1e-12,1e-10,1e-14,.1,7,8192};
    FineReplay(const std::string& directory,const std::vector<PxDestructionStressChunk>& chunks,const std::string& output,bool setupDiagnostic=false,bool checkOnly=false)
        :n(chunks.size()),m(read<PxDestructionBondEndpoints>(directory+"/bond_endpoints.bin").size()),prefix(output),setupOnly(setupDiagnostic),
         endpoints(read<PxDestructionBondEndpoints>(directory+"/bond_endpoints.bin")),active(read<uint32_t>(directory+"/active_bonds.bin")),
         rows(n+1),references(2*size_t(m)),prescribed(n),parents(n),roots(n),ids(n),sortedRoots(n),nodes(n),flags(n),scan(n),starts(n+1),owner(n),local(n),error(1),
         bonds(m),length(n),energy(m),keys(n),graphState(1),joined(1),components(1),setup(n),receipts(n),
         loads(n),rhs(n),initial(n),solution(n),x(n),r(n),p(n),z(n),v(n),truth(n),response(m),basis(n),factors(n),reached(n),nextReached(n) {
        if(checkOnly)profile.maxIterations=0; // retain compatibility and original-row checks; no iteration work
        const auto ends=endpoints.get();std::vector<E::Bond> authored(m);std::vector<uint32_t> offsets(n+1),refs(2*size_t(m));
        if(active.n!=m)throw std::runtime_error("fine native mask size");
        for(unsigned i=0;i<m;++i) {
            const auto e=ends[i];if(e.chunk0>=n || e.chunk1>=n)throw std::runtime_error("fine native endpoint");
            auto& b=authored[i];b.first=e.chunk0;b.second=e.chunk1;b.live=1;
            const auto a=chunks[e.chunk0].position,c=chunks[e.chunk1].position;
            b.point[0]=.5*(double(a.x)+c.x);b.point[1]=.5*(double(a.y)+c.y);b.point[2]=.5*(double(a.z)+c.z);
            b.frame[0]=b.frame[4]=b.frame[8]=1;
            for(unsigned k=0;k<6;++k)b.stiffness.v[7*k]=k<3?1e6:1e4;
            ++offsets[e.chunk0+1];++offsets[e.chunk1+1];
        }
        for(unsigned i=0;i<n;++i)offsets[i+1]+=offsets[i];auto cursor=offsets;
        for(unsigned i=0;i<m;++i){refs[cursor[ends[i].chunk0]++]=i;refs[cursor[ends[i].chunk1]++]=i;}
        check(cudaMemcpy(bonds.p,authored.data(),m*sizeof(E::Bond),cudaMemcpyHostToDevice));
        check(cudaMemcpy(rows.p,offsets.data(),offsets.size()*sizeof(uint32_t),cudaMemcpyHostToDevice));
        check(cudaMemcpy(references.p,refs.data(),refs.size()*sizeof(uint32_t),cudaMemcpyHostToDevice));
        storage={n,parents.p,roots.p,ids.p,sortedRoots.p,nodes.p,flags.p,scan.p,starts.p,owner.p,local.p,length.p,keys.p};
        workspace={x.p,r.p,p.p,z.p,v.p,truth.p,basis.p,factors.p,reached.p,nextReached.p};
        partition=C::view(storage,components.p);
        write(prefix+".bonds.bin",authored);
        std::ofstream metadata(prefix+".profile.json");
        metadata<<"{\"name\":\"uncalibrated-elastic-interface-v1\",\"bond_stride\":"<<sizeof(E::Bond)
            <<",\"translation_stiffness_N_per_m\":1000000,\"rotation_stiffness_Nm_per_rad\":10000,"
              "\"inelastic\":0,\"prescribed_motion\":0,\"blocks\":144,\"absolute_tolerance\":1e-12,"
              "\"relative_tolerance\":1e-10,\"force_scale\":1,\"torque_scale\":1,\"force_tolerance\":1e-9,"
              "\"torque_tolerance\":1e-9,\"nullspace_tolerance\":1e-10,\"rank_tolerance\":1e-12,"
              "\"max_iterations\":"<<profile.maxIterations<<",\"material_qualified\":false,\"setup_only\":"<<(setupOnly?"true":"false")
                <<",\"initial_check_only\":"<<(checkOnly?"true":"false")<<"}\n";
        if(!metadata)throw std::runtime_error("fine profile export");
    }
    void bind(PxDestructionTopologyDeviceView& topology) {topology.bonds=endpoints.p;topology.activeBonds=active.p;topology.bondCount=m;}
    void run(PxDestructionTopologyDeviceView topology,const double3* positions,const P::State* motionPartition,P::Storage motionStorage,
             L::Inputs inputs,const L::Receipt* loadReceipts,const E::Vector* effective,L::Interval interval,const uint32_t* loadError) {
        graph={n,m,positions,bonds.p,rows.p,references.p,prescribed.p,active.p};
        check(G::build(graph,topology,prescribed.p,revisions,{1e-12,1e-12,1e-14},graphState.p));
        J::Source source{motionPartition,motionStorage,inputs,loadReceipts,effective,graphState.p,topology};
        check(J::build(graph,source,interval,loadError,loads.p,joined.p));
        size_t bytes=0;check(C::scratchBytes(graph,storage,bytes));scratch.reset(new Device<char>(bytes));
        check(C::build(graph,storage,components.p,&graphState.p->error,1,{},scratch->p,bytes,nullptr,&graphState.p->key));
        E::validateComponents<<<(n+127)/128,128>>>(graph,partition,&joined.p->error,error.p);
        E::buildRhs<<<(n+127)/128,128>>>(graph,loads.p,initial.p,rhs.p,&joined.p->error);
        E::prepareComponents<<<blocks,128>>>(graph,partition,workspace,profile,keys.p,setup.p,&joined.p->error,error.p);
        if(setupOnly){check(cudaGetLastError());return;}
        E::solveComponents<<<blocks,128>>>(graph,partition,rhs.p,initial.p,solution.p,workspace,profile,keys.p,setup.p,&joined.p->error,error.p,receipts.p);
        fineConvergence<<<(n+127)/128,128>>>(partition,receipts.p,&joined.p->error,error.p);
        E::Accurate::recover<<<(m+127)/128,128>>>(graph,solution.p,initial.p,response.p,energy.p,error.p);
        check(cudaGetLastError());
    }
    void report() {
        const auto c=components.get()[0];const auto j=joined.get()[0];
        if(setupOnly) {
            write(prefix+".setup.bin",activeRead(setup,c.count));write(prefix+".basis.bin",basis.get());
            write(prefix+".mode.bin",p.get());write(prefix+".mode-action.bin",v.get());
            write(prefix+".owners.bin",owner.get());write(prefix+".starts.bin",activeRead(starts,c.count+1));
            write(prefix+".nodes.bin",activeRead(nodes,c.nodes));
            unsigned failures=0;for(const auto& state:activeRead(setup,c.count))failures+=state.status!=E::SetupStatus::Ready;
            std::cout<<"fine setup diagnostic: "<<c.count<<" components, "<<failures<<" rejected; graph error "
                     <<graphState.get()[0].error<<" join error "<<j.error<<"; no solve or recovery performed\n";
            if(failures || !j.ready || j.error || c.error || error.get()[0])throw std::runtime_error("fine setup replay rejected");
            return;
        }
        const auto result=activeRead(receipts,c.count);
        write(prefix+".iterate.bin",x.get());write(prefix+".fine-receipts.bin",result);write(prefix+".solution.bin",solution.get());write(prefix+".rhs.bin",rhs.get());
        write(prefix+".fine-loads.bin",loads.get());write(prefix+".owners.bin",owner.get());write(prefix+".starts.bin",activeRead(starts,c.count+1));
        write(prefix+".nodes.bin",activeRead(nodes,c.nodes));write(prefix+".response.bin",response.get());write(prefix+".energy.bin",energy.get());
        unsigned failures=0,maximum=0;uint64_t iterations=0;
        for(unsigned i=0;i<c.count;++i) {maximum=std::max(maximum,result[i].iterations);iterations+=result[i].iterations;
            if(result[i].status!=E::SolveStatus::LinearConverged) {
                if(failures<12)std::cerr<<"fine component "<<i<<" status "<<unsigned(result[i].status)<<" iterations "<<result[i].iterations
                    <<" norm "<<result[i].residualNorm<<" force "<<result[i].maxForce<<" torque "<<result[i].maxTorque<<" compatibility "<<result[i].compatibilityNorm<<"\n";
                ++failures;
            }
        }
        std::cout<<"fine native load solve: "<<n<<" chunks, "<<m<<" bonds, "<<c.count<<" components, "<<c.nodes<<" unknowns; "
            <<failures<<" rejected, iterations total "<<iterations<<" maximum "<<maximum<<"; graph error "<<graphState.get()[0].error<<" join error "<<j.error<<"\n";
        if(failures || !j.ready || j.error || c.error || error.get()[0])throw std::runtime_error("fine numerical replay rejected");
    }
};
