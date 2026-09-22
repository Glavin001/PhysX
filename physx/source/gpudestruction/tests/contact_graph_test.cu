// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include <cuda_runtime.h>
#include <cub/cub.cuh>
#include "../src/PxgDestructionContactGraph.cuh"
#include "../src/PxgSolverIslandMetadata.cuh"
#include "../src/PxgPreSolveIslands.cuh"
#include "PxgContactIdentity.cuh"
#include <set>
#include <algorithm>
#include <cstdio>
#include <cstring>
#include <map>
#include <numeric>
#include <random>
#include <stdexcept>
#include <vector>
using namespace physx;
#include "contact_identity_test.cuh"

void solverMetadataPages() {
    // Non-multiple domains, untouched pages, and guards catch short tail and
    // node/count address mixups. Reversed descriptors must have the same result.
    constexpr PxU32 nodes=1031,islands=777,guard=0xfedcba98;
    std::vector<PxU32> ids(nodes+2,guard),touches(islands+2,guard);
    for(PxU32 i=0;i<nodes;++i)ids[i+1]=i*17;
    for(PxU32 i=0;i<islands;++i)touches[i+1]=i%9;
    Device<PxU32> dIds(ids.size()),dTouches(touches.size());dIds.put(ids);dTouches.put(touches);
    for(PxU32 iteration=0;iteration<4;++iteration) {
        std::vector<PxvIslandMetadataPage> pages;
        for(PxU32 kind=0;kind<2;++kind)for(PxU32 page:{1u,kind==0?4u:3u}) {
            PxvIslandMetadataPage p={};p.kind=kind;p.offset=page*256;
            const PxU32 n=kind==0?nodes:islands;p.count=std::min(256u,n-p.offset);
            auto& expected=kind==0?ids:touches;
            for(PxU32 i=0;i<p.count;++i)expected[p.offset+i+1]=p.values[i]=100000*iteration+10000*kind+p.offset+i;
            pages.push_back(p);
        }
        if(iteration&1)std::reverse(pages.begin(),pages.end());
        Device<PxvIslandMetadataPage> dPages(pages.size());dPages.put(pages);
        destructionSolverMetadata::applyPages<<<pages.size(),128>>>(dPages.p,PxU32(pages.size()),dIds.p+1,nodes,dTouches.p+1,islands);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        require(dIds.get(ids.size())==ids,"solver metadata scatter changed untouched node entries or guards");
        require(dTouches.get(touches.size())==touches,"solver metadata scatter changed untouched static-touch entries or guards");
    }
    std::puts("GPU solver metadata pages: persistent updates, disjoint order, partial tails and guards passed");
}
struct Pair {PxU32 a,b;bool touch=true,kinematic=false,disabled=false;};
// Independent serial flood fill, rather than another union-find implementation.
std::vector<PxU32> reference(PxU32 n,const std::vector<Pair>& pairs,bool accurate) {
    std::vector<std::vector<PxU32>> adj(n);
    for(const auto& p:pairs)if(p.a<n && p.b<n && !p.kinematic && (!accurate || (p.touch && !p.disabled))) {
        adj[p.a].push_back(p.b);adj[p.b].push_back(p.a);
    }
    std::vector<PxU32> labels(n,PX_INVALID_NODE),queue;
    for(PxU32 root=0;root<n;++root)if(labels[root]==PX_INVALID_NODE) {
        queue.clear();queue.push_back(root);labels[root]=root;
        for(size_t i=0;i<queue.size();++i)for(PxU32 next:adj[queue[i]])if(labels[next]==PX_INVALID_NODE){labels[next]=root;queue.push_back(next);}
    }
    return labels;
}
void preSolveNodeTransactions() {
    const PxU32 n=1031;std::vector<PxvPreSolveNode> expected(n);
    for(PxU32 i=0;i<n;++i)expected[i]={100+i,i%5,1};
    Device<PxvPreSolveNode> nodes(n);nodes.put(expected);
    for(PxU32 pass=0;pass<4;++pass) {
        std::vector<PxvPreSolveNodeUpdate> updates;
        for(PxU32 i:{0u,31u,32u,255u,256u,1024u,1030u}) {
            const PxvPreSolveNode value={1000+pass*100+i,pass*17+i%11,(pass+i)%2};
            updates.push_back({i,0,value});expected[i]=value;
        }
        Device<PxvPreSolveNodeUpdate> input(updates.size());input.put(updates);
        destructionPreSolve::updateNodes<<<1,128>>>(input.p,PxU32(updates.size()),nodes.p,n);
        check(cudaGetLastError());check(cudaDeviceSynchronize());const auto actual=nodes.get(n);
        for(PxU32 i=0;i<n;++i)require(actual[i].lifetime==expected[i].lifetime && actual[i].live==expected[i].live
            && actual[i].staticTouches==expected[i].staticTouches,"CUDA node transaction changed untouched records or lost an update");
    }
    std::puts("CUDA node transactions: sparse persistence, lifetime/live/support changes and boundary indices passed");
}
void preSolveComponents() {
    for(PxU32 n:{12u,100001u}) {
        std::vector<PxvPreSolveNode> before(n),now(n);
        std::vector<PxU32> previous(n);std::vector<PxvPreSolveEdge> merges;
        for(PxU32 i=0;i<n;++i) {
            previous[i]=(i/4)*4;before[i]={1,i%7,1};now[i]=before[i];
            if(i%11==0)now[i].live=0;
            if(i%13==0)now[i].lifetime=2; // reused label representatives must not bridge old components
            if(i%17==0)before[i].live=0; // newly dynamic nodes have no inherited component
            if(i+1<n && i%3==0)merges.push_back({i,i+1});
        }
        std::vector<Pair> expectedEdges;std::map<PxU32,PxU32> hubs;
        for(PxU32 i=0;i<n;++i)if(now[i].live && before[i].live && now[i].lifetime==before[i].lifetime){
            const auto result=hubs.emplace(previous[i],i);
            if(!result.second)expectedEdges.push_back({result.first->second,i});
        }
        for(const auto& e:merges)if(now[e.a].live && now[e.b].live)expectedEdges.push_back({e.a,e.b});
        auto expected=reference(n,expectedEdges,true);std::vector<PxU32> expectedCounts(n);
        for(PxU32 i=0;i<n;++i)if(now[i].live)expectedCounts[expected[i]]+=now[i].staticTouches;else expected[i]=~PxU32(0);
        Device<PxvPreSolveNode> dBefore(n),dNow(n);Device<PxvPreSolveEdge> dMerges(merges.size());
        Device<PxU32> dPrevious(n),parents(2*n),labels(n),counts(n);
        dBefore.put(before);dNow.put(now);dPrevious.put(previous);
        for(unsigned trial=0;trial<3;++trial) {
            std::reverse(merges.begin(),merges.end());dMerges.put(merges);
            destructionPreSolve::initialize<<<(2*n+127)/128,128>>>(parents.p,2*n,counts.p,n);
            destructionPreSolve::seed<<<(n+127)/128,128>>>(dNow.p,n,dBefore.p,n,dPrevious.p,n,parents.p,nullptr);
            destructionPreSolve::connect<<<(merges.size()+127)/128,128>>>(dMerges.p,PxU32(merges.size()),dNow.p,n,parents.p);
            destructionPreSolve::finish<<<(n+127)/128,128>>>(dNow.p,n,parents.p,labels.p,counts.p);
            check(cudaGetLastError());check(cudaDeviceSynchronize());
            require(labels.get(n)==expected,"pre-solve CUDA components differ from independent phase-preserving flood fill");
            require(counts.get(n)==expectedCounts,"pre-solve CUDA static support reduction mismatch");
        }
    }
    std::puts("CUDA pre-solve graph: 100001 nodes, previous components, new merges, deleted/prescribed nodes, lifetime reuse, exact static counts passed");
}
void preSolveDeviceContacts() {
    constexpr PxU32 n=8;
    const std::vector<Pair> pairs={{0,1},{1,2,false},{2,3,false},{3,4,true,false,true},
        {4,5,true,true},{5,6},{6,7},{n,3},{n,4}};
    std::vector<PxgShapeSim> shapes(n+1);for(PxU32 i=0;i<n;++i)shapes[i].mBodySimIndex=PxNodeIndex(i);
    shapes[n].mBodySimIndex=PxNodeIndex();
    std::vector<PxvPreSolveNode> nodes(n,{1,0,1});nodes[0].staticTouches=1;nodes[2].staticTouches=2;nodes[7].live=0;
    std::vector<PxU32> previous={0,1,1,3,4,5,6,7};
    std::vector<PxgContactManagerInput> inputs(pairs.size());std::vector<PxgContactGraphIdentity> ids(pairs.size());
    std::vector<PxsContactManagerOutput> outputs(pairs.size());
    for(PxU32 i=0;i<pairs.size();++i) {
        const auto p=pairs[i];inputs[i]={0,0,p.a,p.b};ids[i]={i,0,1};
        outputs[i].statusFlag=p.touch?PxsContactManagerStatusFlag::eHAS_TOUCH:PxsContactManagerStatusFlag::eHAS_NO_TOUCH;
        outputs[i].flags=(p.kinematic?PxgDestructionContactFlags::eKINEMATIC_PAIR:0)|(p.disabled?PxgDestructionContactFlags::eDISABLE_RESPONSE:0);
    }
    inputs[5].transformCacheRef0=~0u; // retirement must prevent invalid geometry access
    Device<PxgShapeSim> dShapes(shapes.size());dShapes.put(shapes);
    Device<PxgContactManagerInput> dInputs(inputs.size());dInputs.put(inputs);
    Device<PxgContactGraphIdentity> dIds(ids.size());dIds.put(ids);
    Device<PxsContactManagerOutput> dOutputs(outputs.size());dOutputs.put(outputs);
    Device<PxvPreSolveNode> dNodes(n);dNodes.put(nodes);Device<PxU32> dPrevious(n);dPrevious.put(previous);
    Device<PxU32> parents(2*n),labels(n),counts(n),mask(1);mask.put({1u<<5});
    Device<PxvPreSolveEdge> retained(1);retained.put({{3,5}});
    Device<PxgDestructionContactGraphStatus> status(1);status.put({{0,0}});
    PxgDestructionPreSolveContacts view;view.inputs=dInputs.p;view.identities=dIds.p;view.outputs=dOutputs.p;
    view.shapes=dShapes.p;view.shapeCapacity=n+1;view.pairCount=PxU32(pairs.size());
    destructionPreSolve::initialize<<<1,128>>>(parents.p,2*n,counts.p,n);
    destructionPreSolve::seed<<<1,128>>>(dNodes.p,n,dNodes.p,n,dPrevious.p,n,parents.p,nullptr);
    destructionPreSolve::connect<<<1,128>>>(retained.p,1,dNodes.p,n,parents.p);
    destructionPreSolve::connectContacts<<<1,128>>>(view,mask.p,dNodes.p,n,parents.p,status.p);
    destructionPreSolve::requireValidContacts<<<1,1>>>(status.p);
    destructionPreSolve::finish<<<1,128>>>(dNodes.p,n,parents.p,labels.p,counts.p);
    check(cudaGetLastError());check(cudaDeviceSynchronize());
    require(status.get(1)[0].error==0,"direct pre-solve contact decoder rejected valid phase input");
    require(labels.get(n)==std::vector<PxU32>({0,0,0,3,4,3,6,~0u}),"GPU contacts lost prior connectivity or bridged an excluded contact");
    require(counts.get(n)==std::vector<PxU32>({3,0,0,0,0,0,0,0}),"GPU contact connectivity changed support reduction");
    // A lost static edge with three prior patches still counts as one edge.
    // Deliberately different native node counts cannot affect this GPU input.
    outputs[8].statusFlag=PxsContactManagerStatusFlag::eHAS_NO_TOUCH;outputs[8].prevPatches=3;dOutputs.put(outputs);
    Device<PxU32> support(n);support.put(std::vector<PxU32>(n,0));counts.put(std::vector<PxU32>(n,0));
    Device<PxvPreSolveEdge> staticBridges(2);staticBridges.put({{PX_INVALID_NODE,5},{6,PX_INVALID_NODE}});
    destructionPreSolve::connectContacts<<<1,128>>>(view,mask.p,dNodes.p,n,parents.p,status.p,support.p);
    destructionPreSolve::connectSupportBridges<<<1,128>>>(staticBridges.p,2,dNodes.p,n,parents.p,support.p);
    destructionPreSolve::finish<<<1,128>>>(dNodes.p,n,parents.p,labels.p,counts.p,support.p);
    check(cudaGetLastError());check(cudaDeviceSynchronize());
    require(support.get(n)==std::vector<PxU32>({0,0,0,1,1,1,1,0}),"GPU support must count current/prior static edges exactly once");
    require(counts.get(n)==std::vector<PxU32>({0,0,0,2,1,0,1,0}),"solver reduction used native support instead of GPU-derived counts");
    ids[0].generation=0;dIds.put(ids);
    destructionPreSolve::connectContacts<<<1,128>>>(view,mask.p,dNodes.p,n,parents.p,status.p);
    check(cudaDeviceSynchronize());require(status.get(1)[0].error==PxgDestructionContactGraphStatus::eINVALID_IDENTITY,"invalid current contact identity was not reported");
    std::puts("CUDA pre-solve contacts: prior lost connection, current touch, managerless edge, retired invalid geometry, static/kinematic/disabled/deleted exclusions passed");
}
void verifyMemberLinks(const PxU32* labels,const std::vector<PxU32>& expected) {
    const PxU32 n=PxU32(expected.size());if(!n)return;
    Device<PxU64> input(n),sorted(n);size_t bytes=0;
    check(cub::DeviceRadixSort::SortKeys(nullptr,bytes,input.p,sorted.p,n));Device<unsigned char> scratch(bytes);
    destructionContactGraph::componentKeys<<<(n+127)/128,128>>>(labels,input.p,n);
    check(cub::DeviceRadixSort::SortKeys(scratch.p,bytes,input.p,sorted.p,n));
    auto* members=reinterpret_cast<PxU32*>(input.p);check(cudaMemset(members,0xff,size_t(n)*sizeof(PxU32)));
    destructionContactGraph::componentMembers<<<(n+127)/128,128>>>(sorted.p,members,n);
    check(cudaGetLastError());std::vector<PxU32> actual(size_t(n)*2),wanted(size_t(n)*2,PX_INVALID_NODE),last(n,PX_INVALID_NODE);
    check(cudaMemcpy(actual.data(),members,actual.size()*sizeof(PxU32),cudaMemcpyDeviceToHost));
    for(PxU32 node=0;node<n;++node) {
        const PxU32 label=expected[node];if(last[label]==PX_INVALID_NODE)wanted[label]=node;
        else wanted[size_t(n)+last[label]]=node;last[label]=node;
    }
    require(actual==wanted,"GPU membership heads/successors differ from independent stable component grouping");
}
void run(PxU32 n,const std::vector<Pair>& pairs,unsigned invalid=0,PxU32 omitted=0,const std::vector<PxU32>& retired={},const std::vector<Pair>& retained={}) {
    const PxU32 count=PxU32(pairs.size());
    std::vector<PxgShapeSim> shapes(n+1);for(PxU32 i=0;i<n;++i)shapes[i].mBodySimIndex=PxNodeIndex(i);
    shapes[n].mBodySimIndex=PxNodeIndex();
    std::vector<PxgContactManagerInput> inputs(count);
    std::vector<PxgContactGraphIdentity> ids(count);
    std::vector<PxsContactManagerOutput> outputs(count);
    for(PxU32 i=0;i<count;++i){const auto& p=pairs[i];inputs[i]={0,0,p.a<n?p.a:n,p.b<n?p.b:n};ids[i]={i,0,PxU64(i)+1};
        outputs[i].statusFlag=p.touch?PxsContactManagerStatusFlag::eHAS_TOUCH:PxsContactManagerStatusFlag::eHAS_NO_TOUCH;
        outputs[i].flags=(p.kinematic?PxgDestructionContactFlags::eKINEMATIC_PAIR:0)|(p.disabled?PxgDestructionContactFlags::eDISABLE_RESPONSE:0);
    }
    if(invalid==1)ids[0].generation=0;
    if(invalid==2)inputs[0].transformCacheRef0=n+1;
    if(invalid==3)shapes[0].mBodySimIndex=PxNodeIndex(0u,0u);
    if(invalid==4)shapes[0].mBodySimIndex=PxNodeIndex(n+1);
    Device<PxgShapeSim> dShapes(shapes.size());dShapes.put(shapes);
    Device<PxgContactManagerInput> dInputs(count);dInputs.put(inputs);
    Device<PxgContactGraphIdentity> dIds(count);dIds.put(ids);
    Device<PxsContactManagerOutput> dOutputs(count);dOutputs.put(outputs);
    Device<PxgDestructionContactEdge> edges(count);Device<PxU32> accurate(n),speculative(n);
    Device<PxgDestructionContactGraphStatus> status(1);
    Device<PxU32> retiredIds(retired.size()),mask((size_t(count)+31)/32);retiredIds.put(retired);
    cudaStream_t stream;check(cudaStreamCreateWithFlags(&stream,cudaStreamNonBlocking));
    destructionContactGraph::initialize<<<(std::max(n,1u)+127)/128,128,0,stream>>>(accurate.p,speculative.p,n,status.p,omitted);
    if(!retired.empty()) {
        check(cudaMemsetAsync(mask.p,0,((size_t(count)+31)/32)*sizeof(PxU32),stream));
        destructionContactGraph::retire<<<(retired.size()+127)/128,128,0,stream>>>(retiredIds.p,PxU32(retired.size()),count,mask.p,status.p);
    }
    if(count){
        destructionContactGraph::decode<<<(count+127)/128,128,0,stream>>>(dInputs.p,dIds.p,dOutputs.p,count,dShapes.p,n+1,n,edges.p,status.p,retired.empty()?nullptr:mask.p);
        destructionContactGraph::connect<<<(count+127)/128,128,0,stream>>>(dInputs.p,dIds.p,dOutputs.p,count,dShapes.p,n+1,n,status.p,retired.empty()?nullptr:mask.p,accurate.p,speculative.p);
    }
    std::vector<PxgDestructionRetainedEdge> retainedEdges;
    for(PxU32 i=0;i<retained.size();++i) {
        const auto& p=retained[i];retainedEdges.push_back({i,p.a,p.b,
            (p.touch && !p.disabled?PxgDestructionRetainedEdge::eACCURATE:0u)|(p.kinematic?PxgDestructionRetainedEdge::eKINEMATIC:0u)});
    }
    Device<PxgDestructionRetainedEdge> dRetained(retainedEdges.size());dRetained.put(retainedEdges);
    if(!retainedEdges.empty())destructionContactGraph::connectRetained<<<(retainedEdges.size()+127)/128,128,0,stream>>>(
        dRetained.p,PxU32(retainedEdges.size()),n,accurate.p,speculative.p,status.p);
    if(n)destructionContactGraph::compress<<<(n+127)/128,128,0,stream>>>(accurate.p,speculative.p,n);
    check(cudaGetLastError());check(cudaStreamSynchronize(stream));check(cudaStreamDestroy(stream));
    const auto result=status.get(1)[0];
    const bool invalidRetirement=std::any_of(retired.begin(),retired.end(),[&](PxU32 i){return i>=count;});
    const PxU32 expected=(invalidRetirement?PxgDestructionContactGraphStatus::eINVALID_IDENTITY:0u)|(omitted?PxgDestructionContactGraphStatus::eMISSING_PAIRS:0u)|
        (invalid?(invalid==3?PxgDestructionContactGraphStatus::eUNSUPPORTED_ENDPOINT:PxgDestructionContactGraphStatus::eINVALID_IDENTITY):0u);
    if(result.error!=expected || result.omittedPairs!=omitted)
        std::fprintf(stderr,"graph availability: nodes=%u pairs=%u invalid=%u retired=%zu retained=%zu error=%u expected=%u omitted=%u expectedOmitted=%u\n",
            n,count,invalid,retired.size(),retained.size(),result.error,expected,result.omittedPairs,omitted);
    require(result.error==expected && result.omittedPairs==omitted,"graph availability status mismatch");
    if(invalid || invalidRetirement)return;
    std::vector<Pair> live;
    for(PxU32 i=0;i<count;++i)if(std::find(retired.begin(),retired.end(),i)==retired.end())live.push_back(pairs[i]);
    live.insert(live.end(),retained.begin(),retained.end());
    require(accurate.get(n)==reference(n,live,true),"accurate graph differs from flood fill");
    require(speculative.get(n)==reference(n,live,false),"speculative graph differs from flood fill");
    verifyMemberLinks(accurate.p,reference(n,live,true));verifyMemberLinks(speculative.p,reference(n,live,false));
    const auto decoded=edges.get(count);for(PxU32 i=0;i<count;++i){
        require(decoded[i].identity.generation==ids[i].generation && decoded[i].identity.edgeIndex==i,"GPU graph lost pair lifetime identity");
        if(std::find(retired.begin(),retired.end(),i)!=retired.end()) {
            require((decoded[i].flags&PxgDestructionContactFlags::eRETIRED) && decoded[i].node0==PX_INVALID_NODE && decoded[i].node1==PX_INVALID_NODE,"retired edge still connects nodes");continue;
        }
        require(decoded[i].node0==pairs[i].a && decoded[i].node1==pairs[i].b,"GPU graph resolved wrong node ownership");
    }
}
void retainedTransactions() {
    constexpr PxU32 n=8,capacity=97;
    Device<PxgDestructionRetainedEdge> slots(capacity),updates(128);
    Device<PxU32> active((capacity+31)/32),counts(3),accurate(n),speculative(n);
    Device<PxgDestructionContactGraphStatus> status(1);
    check(cudaMemset(slots.p,0,capacity*sizeof(PxgDestructionRetainedEdge)));
    check(cudaMemset(active.p,0,((capacity+31)/32)*sizeof(PxU32)));check(cudaMemset(counts.p,0,3*sizeof(PxU32)));
    std::map<PxU32,PxgDestructionRetainedEdge> expected;PxU32 peak=0;
    const auto transaction=[&](std::vector<PxgDestructionRetainedEdge> batch,bool valid=true) {
        updates.put(batch);
        const auto oldSlots=slots.get(capacity);const auto oldActive=active.get((capacity+31)/32);
        destructionContactGraph::initialize<<<1,128>>>(accurate.p,speculative.p,n,status.p,0);
        check(cudaMemset(counts.p+2,0,sizeof(PxU32)));
        if(!batch.empty()) {
            destructionContactGraph::validateRetainedUpdates<<<1,128>>>(updates.p,PxU32(batch.size()),capacity,counts.p,status.p);
            destructionContactGraph::applyRetainedUpdates<<<1,128>>>(updates.p,PxU32(batch.size()),slots.p,capacity,active.p,counts.p,status.p);
            destructionContactGraph::finishRetainedUpdates<<<1,1>>>(counts.p);
        }
        destructionContactGraph::connectRetainedSlots<<<1,128>>>(slots.p,active.p,capacity,n,accurate.p,speculative.p,status.p);
        destructionContactGraph::compress<<<1,128>>>(accurate.p,speculative.p,n);
        check(cudaGetLastError());check(cudaDeviceSynchronize());
        const auto result=status.get(1)[0];
        require(result.error==(valid?0u:PxgDestructionContactGraphStatus::eINVALID_IDENTITY),"retained transaction error status mismatch");
        if(valid) {
            for(const auto& e:batch) {
                if(e.flags&PxgDestructionRetainedEdge::eREMOVED)expected.erase(e.edgeIndex);
                else expected[e.edgeIndex]=e;
            }
            peak=std::max(peak,PxU32(expected.size()));
        } else {
            const auto current=slots.get(capacity);
            require(!std::memcmp(oldSlots.data(),current.data(),capacity*sizeof(current[0]))
                && oldActive==active.get((capacity+31)/32),"invalid retained transaction partially changed resident state");
        }
        const auto c=counts.get(3);require(c[0]==expected.size() && c[1]==peak,"resident retained counts differ from complete transaction");
        std::vector<Pair> pairs;
        for(const auto& item:expected) {
            const auto& e=item.second;pairs.push_back({e.node0,e.node1,bool(e.flags&PxgDestructionRetainedEdge::eACCURATE),bool(e.flags&PxgDestructionRetainedEdge::eKINEMATIC)});
        }
        require(accurate.get(n)==reference(n,pairs,true) && speculative.get(n)==reference(n,pairs,false),"retained delta connectivity differs from independent snapshot flood fill");
    };
    transaction({{0,0,1,1},{31,1,2,0},{32,2,3,1},{64,4,5,1},{96,6,7,1}});
    transaction({}); // No upload/rebuild of the persistent edge data.
    transaction({{31,1,2,1},{32,2,3,3}}); // Accurate change and kinematic boundary.
    transaction({{0,0,0,8},{31,0,0,8},{96,0,0,8}});
    transaction({{0,0,7,1},{31,3,4,0},{96,7,PX_INVALID_NODE,1}}); // Reused native slots, new endpoints.
    transaction({{0,0,0,8},{31,0,0,8},{32,0,0,8},{64,0,0,8},{96,0,0,8}});
    transaction({{31,0,0,8}}); // Idempotent removal, no count underflow.
    transaction({{0,0,1,1},{96,6,7,1}});
    transaction({{0,0,0,8},{97,0,1,1}},false); // Entire batch rejected before a valid-prefix deletion.
    transaction({{0,0,0,8},{32,1,2,1},{0,0,4,1},{96,1,7,1}},false); // Nonadjacent duplicate/out-of-order key.
    transaction({{0,0,0,8},{96,0,0,8}}); // Valid transaction after rejection.
    std::puts("CUDA retained registry: persistence, bit boundaries, contact changes, removal/reuse, exact counts and atomic rejection passed");
}

int main(){try{
    const auto exhaustedSequence=contactLifetimeAllocation();
    {
        Device<PxgContactGraphSequence> sequence(1);sequence.put({exhaustedSequence});
    Device<PxU32> emptyAccurate(0),emptySpeculative(0);Device<PxgDestructionContactGraphStatus> graphStatus(1);
    destructionContactGraph::initialize<<<1,128>>>(emptyAccurate.p,emptySpeculative.p,0,graphStatus.p,0,sequence.p);
    check(cudaDeviceSynchronize());
    require(graphStatus.get(1)[0].error==PxgDestructionContactGraphStatus::eLIFETIME_EXHAUSTED,
        "empty/retired contact set hid allocator exhaustion at completion");
    }

    preSolveNodeTransactions();
    preSolveDeviceContacts();
    preSolveComponents();
    solverMetadataPages();
    retainedTransactions();
    run(0,{});run(100,{});
    // A native speculative edge can have no active narrowphase manager.
    // Retained touch, no-touch, disabled response and prescribed boundaries
    // must preserve their different accurate/speculative connectivity.
    const std::vector<Pair> retained={{1,2,false},{3,4,true},{4,5,true,false,true},{0,6,true,true},{5,6,true,true},{0,PX_INVALID_NODE}};
    run(8,{{0,1},{2,3},{5,7}},0,0,{},retained);
    run(8,{},0,0,{},retained);
    run(8,{{0,1},{2,3},{5,7}}); // removed snapshot cannot retain old links

    // Untouched broadphase bridge, disabled-response bridge, cycles, common
    // static/kinematic boundaries and isolated bodies have distinct semantics.
    const std::vector<Pair> small={{0,1},{1,2},{2,0},{2,3,false},{3,4,true,false,true},{4,5},
        {0,6,true,true},{4,6,true,true},{0,PX_INVALID_NODE},{4,PX_INVALID_NODE},{5,5}};
    run(8,small);run(8,small,0,7);run(8,small,0,0,{0,1,2,2});run(8,small,0,0,{999});
    for(unsigned i=1;i<=4;++i)run(8,small,i);
    std::vector<Pair> boundaryBits;for(PxU32 i=0;i<65;++i)boundaryBits.push_back({i,i+1});
    run(66,boundaryBits,0,0,{0,31,32,63,64,32});
    std::mt19937 rng(413);
    std::vector<Pair> pairs;
    for(PxU32 i=1;i<100000;++i)if(i!=50000)pairs.push_back({i-1,i,(i%5)!=0});
    for(PxU32 i=0;i<100000;++i){const PxU32 base=(i&1)?50000:0;pairs.push_back({base+PxU32(rng()%50000),base+PxU32(rng()%50000),(i%3)!=0,false,(i%11)==0});}
    for(PxU32 i=0;i<1000;++i){pairs.push_back({i,100000,true,true});pairs.push_back({50000+i,PX_INVALID_NODE});}
    for(unsigned trial=0;trial<3;++trial){std::shuffle(pairs.begin(),pairs.end(),rng);run(100001,pairs);}
    // Rebuild after deletions/splitting: stale roots cannot carry connectivity.
    pairs.erase(std::remove_if(pairs.begin(),pairs.end(),[](const Pair& p){return p.a<50000 && p.b>=25000 && p.b<50000;}),pairs.end());
    run(100001,pairs);
    std::puts("GPU contact graph: 100001 nodes, 201998 pairs, shuffled order, split rebuild, static/kinematic boundaries, touch/response, explicit invalid inputs: passed");
    return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
