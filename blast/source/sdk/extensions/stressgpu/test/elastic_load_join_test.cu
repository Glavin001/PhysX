// SPDX-License-Identifier: BSD-3-Clause
#include "ElasticPcgTestFixture.h"
#include "PxgDestructionElasticLoadJoin.cuh"
namespace J=physx::destructionElasticLoadJoin;
namespace M=physx::destructionElasticPartition;
namespace L=physx::destructionElasticLoads;
namespace G=physx::destructionElasticGraph;
using namespace physx;
struct JoinFixture {
    Fixture f;
    Solver solver{f,{0,6},{1}};
    Device<uint32_t> authors{6},inverse{6},starts{3},indices{6},local{6},active{6},bonds{8},prior{1};
    Device<PxDestructionStressChunk> chunks{6};
    Device<PxDestructionChunkMassProperties> mass{6};
    Device<double3> positions{6};
    Device<E::Vector> effective{6},authored{6},prescribed{6};
    Device<L::Receipt> receipts{2};Device<L::Interval> produced{1};
    Device<M::State> partition{1};Device<G::State> graphState{1};Device<J::State> state{1};
    Device<PxDestructionTopologyStatus> topology{1};
    const std::vector<uint32_t> order{3,0,5,1,4,2};
    L::Interval interval{{9,10,13,0,1},1./60};
    E::SetupKey key{7,1,13,2,3,4,5};
    J::Source source{};M::State hostPartition{};
    JoinFixture() {
        source.storage={6,starts.p,indices.p,local.p,authors.p,inverse.p,chunks.p,mass.p,positions.p};
        source.partition=partition.p;source.graph=graphState.p;
        source.loads.referencePositions=positions.p;source.loads.chunks=chunks.p;source.loads.mass=mass.p;
        source.loads.produced=produced.p;source.receipts=receipts.p;source.effective=effective.p;
        source.topology.status=topology.p;source.topology.activeChunks=active.p;source.topology.activeBonds=bonds.p;
        source.topology.chunkCount=6;source.topology.bondCount=8;
        solver.graph.graph.activeBonds=bonds.p;
        hostPartition.identity={7,2,1};hostPartition.storage=source.storage;hostPartition.topology=13;
        hostPartition.groups={1,6,starts.p,indices.p,local.p};hostPartition.status=M::Status::Ready;hostPartition.sourceNodes=6;
        reset();
    }
    void reset() {
        std::vector<uint32_t> inv(6),seq{0,1,2,3,4,5};std::vector<double3> pos(6);
        std::vector<PxDestructionStressChunk> c(6);std::vector<PxDestructionChunkMassProperties> m(6);
        std::vector<E::Vector> loads(6);
        for(unsigned j=0;j<6;++j){const auto i=order[j];inv[i]=j;pos[j]=f.x[i];m[j].supported=f.fixed[i];loads[j]=f.external[i];}
        authors.put(order);inverse.put(inv);positions.put(pos);chunks.put(c);mass.put(m);effective.put(loads);
        indices.put(seq);local.put(seq);starts.put({0,6,6});active.put(std::vector<uint32_t>(6,1));bonds.put(std::vector<uint32_t>(8,1));
        prior.put({0});produced.put({interval});prescribed.put(f.prescribed);
        L::Receipt receipt{};receipt.interval=interval;receipt.status=L::Status::Ready;receipts.put({receipt,receipt});
        partition.put({hostPartition});graphState.put({{key,0,0,1,0}});topology.put({{13,1,0,0,0}});
        solver.keys.put({key});
    }
    E::SolveReceipt run() {
        auto& s=solver;check(J::build(s.graph.graph,source,interval,prior.p,authored.p,state.p));
        E::buildRhs<<<1,128>>>(s.graph.graph,authored.p,prescribed.p,s.rhs.p,&state.p->error);
        s.error.put({0});
        E::validateComponents<<<1,128>>>(s.graph.graph,s.components,&state.p->error,s.error.p);
        E::prepareComponents<<<1,128>>>(s.graph.graph,s.components,s.workspace,s.profile,s.keys.p,s.setup.p,&state.p->error,s.error.p);
        E::solveComponents<<<1,128>>>(s.graph.graph,s.components,s.rhs.p,s.initial.p,s.solution.p,s.workspace,s.profile,s.keys.p,s.setup.p,&state.p->error,s.error.p,s.receipts.p);
        check(cudaGetLastError());return s.receipts.get()[0];
    }
};
int main() {
    try {
        JoinFixture f;require(f.run().status==E::SolveStatus::LinearConverged,"joined solve failed");
        require(f.state.get()[0].ready,"join not ready");const auto mapped=f.authored.get();
        for(unsigned i=0;i<6;++i)for(unsigned k=0;k<6;++k)near(mapped[i].v[k],f.f.external[i].v[k],"permuted physical load map");
        residualCheck(f.f,referenceRhs(f.f),f.solver.solution.get());
        for(unsigned failure=0;failure<11;++failure) {
            f.reset();
            if(failure==0){auto r=f.receipts.get();++r[0].interval.stamp.inputGeneration;f.receipts.put(r);}
            if(failure==1){auto pos=f.positions.get();pos[2].x+=1e-8;f.positions.put(pos);}
            if(failure==2){auto inv=f.inverse.get();inv[3]=99;f.inverse.put(inv);}
            if(failure==3){auto m=f.mass.get();m[1].supported=0;f.mass.put(m);}
            if(failure==4){auto p=f.hostPartition;++p.topology;f.partition.put({p});}
            if(failure==5){auto interval=f.interval;interval.stamp.complete=0;f.produced.put({interval});}
            if(failure==6){auto p=f.hostPartition;p.groups.count=2;f.partition.put({p});auto c=f.chunks.get();c[2].cluster=1;f.chunks.put(c);}
            if(failure==7){auto load=f.effective.get();load[3].v[4]=NAN;f.effective.put(load);}
            if(failure==8)f.prior.put({1});
            if(failure==9){auto g=f.graphState.get();++g[0].key.geometry;f.graphState.put(g);}
            if(failure==10)f.active.put({1,1,0,1,1,1});
            require(f.run().status==E::SolveStatus::InvalidInput,"bad join reached numerical acceptance");
            require(f.state.get()[0].error && !f.state.get()[0].ready,"bad join was ready");
        }
        f.reset();require(f.run().status==E::SolveStatus::LinearConverged,"fresh interval did not recover after rejection");
        require(J::build(f.solver.graph.graph,f.source,f.interval,f.prior.p,f.effective.p,f.state.p)==cudaErrorInvalidValue,"in-place permutation accepted");
        std::cout<<"PASS compact-to-authored load/RHS/PCG chain; interval, geometry, support, ownership, closure and rejection checks\n";
        return 0;
    }catch(const std::exception& e){std::cerr<<e.what()<<'\n';return 1;}
}
