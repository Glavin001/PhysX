// Reject malformed borrowed partition views and recover without CPU regrouping.
void verifyPackingPartitionFailures(Input input,Graph& parent,cudaStream_t stream){
    bool rejected=false;Input missing=input;missing.partition={};
    try{PackedLevel invalid(missing,parent,stream);}catch(const std::runtime_error& e){rejected=std::string(e.what()).find("native GPU component partition")!=std::string::npos;}
    require(rejected,"missing native component view was accepted");
    const unsigned used=input.counts?download(input.counts,2,stream)[0]:input.nodes;
    if(used>257)return;
    const unsigned nodes=download(input.partition.nodeCount,1,stream)[0],parts=download(input.partition.count,1,stream)[0];
    std::vector<unsigned> originalNodes(input.nodes);
    if(input.partition.nodes)originalNodes=download(input.partition.nodes,input.nodes,stream);
    else std::iota(originalNodes.begin(),originalNodes.end(),0);
    const auto originalBegin=download(input.partition.begin,input.authoredNodes?input.authoredNodes:input.nodes,stream);
    Device<unsigned> order(input.nodes),counts(2),begin(originalBegin.size());
    auto restore=[&](){order.put(originalNodes,stream);counts.put({nodes,parts},stream);begin.put(originalBegin,stream);};
    restore();input.partition.nodes=order.data;input.partition.nodeCount=counts.data;input.partition.count=counts.data+1;input.partition.begin=begin.data;
    auto verify=[&](){
        PackedLevel probe(input,parent,stream);cudaGraph_t graph=nullptr;cudaGraphExec_t executable=nullptr;
        check(cudaGraphCreate(&graph,0));probe.append(graph,nullptr);check(cudaGraphInstantiate(&executable,graph,0));
        check(cudaGraphLaunch(executable,stream));auto state=download(probe.status(),1,stream)[0];
        require(state.error==64 && !state.initialized,"invalid partition was accepted or reported incorrectly");
        restore();check(cudaGraphLaunch(executable,stream));state=download(probe.status(),1,stream)[0];
        const auto source=download(parent.status(),1,stream)[0];
        require(!state.error && state.initialized && state.generation==source.generation,"valid partition did not recover");
        check(cudaGraphExecDestroy(executable));check(cudaGraphDestroy(graph));
    };
    counts.put({used+1,parts},stream);verify();
    if(nodes){auto bad=originalNodes;bad[0]=used;order.put(bad,stream);verify();}
    if(nodes>1){auto bad=originalNodes;bad[1]=bad[0];order.put(bad,stream);verify();}
    if(parts){const unsigned first=download(input.partition.ids,1,stream)[0];auto bad=originalBegin;bad[first]=nodes+1;begin.put(bad,stream);verify();}
    const auto retained=download(parent.buffers().coarseActive,used,stream);
    if(std::any_of(retained.begin(),retained.end(),[](unsigned flag){return flag!=0;})){
        counts.put({0,0},stream);verify(); // A plausible empty partition must not hide live roots.
    }
}
