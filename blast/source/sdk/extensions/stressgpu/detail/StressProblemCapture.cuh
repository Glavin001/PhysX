#pragma once
// Diagnostic-only capture of the actual problem before resident iteration.
// No declarations, graph nodes, copies or host decisions enter production.
#ifdef BLAST_GPU_NATIVE_PROBLEM_CAPTURE
#ifndef BLAST_GPU_COMPONENT_WORK_CAPTURE
#error Native problem capture requires the separate component diagnostic runtime
#endif
struct CapturedStressNode {
    float inertia[2],rhs[6],residual[6],threshold;
    unsigned component;
};
struct CapturedStressBond {
    unsigned first,second;
    float offset0[3],offset1[3],health,scale,warm[6];
};
static_assert(sizeof(CapturedStressNode)==64 && sizeof(CapturedStressBond)==64,"problem capture wire layout");
__device__ CapturedStressNode* capturedStressNodes;
__device__ CapturedStressBond* capturedStressBonds;
__device__ unsigned captureStressProblemEnabled;
__device__ void captureSix(float* dst,const AngLin& v){
    dst[0]=v.angular.x;dst[1]=v.angular.y;dst[2]=v.angular.z;
    dst[3]=v.linear.x;dst[4]=v.linear.y;dst[5]=v.linear.z;
}
__global__ void captureStressProblem(PersistentStressArgs a,unsigned n,unsigned m){
    if(!captureStressProblemEnabled)return;
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i<n){
        auto& out=capturedStressNodes[i];const auto d=a.m_inertia[i];
        out.inertia[0]=d.angular;out.inertia[1]=d.linear;out.component=a.m_nodeIsland[i];
        out.threshold=out.component==kNoIsland?0:a.m_deltaSquared[out.component];
        if(out.component!=kNoIsland){captureSix(out.rhs,a.originalRhs[i]);captureSix(out.residual,a.m_residual[i]);}
        else for(unsigned k=0;k<6;++k){out.rhs[k]=0;out.residual[k]=0;}
    }
    if(i<m){
        auto& out=capturedStressBonds[i];out.first=a.m_node0[i];out.second=a.m_node1[i];
        const auto u=a.m_offset0[i],v=a.m_offset1[i];
        out.offset0[0]=u.x;out.offset0[1]=u.y;out.offset0[2]=u.z;
        out.offset1[0]=v.x;out.offset1[1]=v.y;out.offset1[2]=v.z;
        out.health=a.m_health[i];out.scale=a.m_colScales[i];
        if(out.health>0)captureSix(out.warm,a.impulses[i]);else for(unsigned k=0;k<6;++k)out.warm[k]=0;
    }
}
class NativeProblemCapture {
    CapturedStressNode* nodes=nullptr;CapturedStressBond* bonds=nullptr;
    std::vector<CapturedStressNode> hostNodes;std::vector<CapturedStressBond> hostBonds;
    std::string prefix;unsigned first=0,last=0,enabled=0;
    void cleanup(){if(nodes)cudaFree(nodes);if(bonds)cudaFree(bonds);nodes=nullptr;bonds=nullptr;}
    static void write(const std::string& path,const void* data,size_t size){
        FILE* f=std::fopen(path.c_str(),"wbx");if(!f)throw std::runtime_error("cannot create new native problem artifact");
        const bool ok=std::fwrite(data,1,size,f)==size;const bool closed=std::fclose(f)==0;
        if(!ok || !closed)throw std::runtime_error("native problem capture incomplete");
    }
public:
    NativeProblemCapture(unsigned n,unsigned m):hostNodes(n),hostBonds(m){
        const char* path=std::getenv("PHYSX_STRESS_PROBLEM_PREFIX");
        const char* range=std::getenv("PHYSX_STRESS_PROBLEM_SOLVES");char extra;
        if(!path || !*path || !range || std::sscanf(range,"%u:%u%c",&first,&last,&extra)!=2 || last<first)
            throw std::runtime_error("problem diagnostic requires prefix and inclusive first:last solve ordinals");
        prefix=path;
        try{
            checkCuda(cudaMalloc(&nodes,sizeof(*nodes)*n),"allocate problem node snapshot");
            checkCuda(cudaMalloc(&bonds,sizeof(*bonds)*m),"allocate problem bond snapshot");
            checkCuda(cudaMemcpyToSymbol(capturedStressNodes,&nodes,sizeof(nodes)),"bind problem nodes");
            checkCuda(cudaMemcpyToSymbol(capturedStressBonds,&bonds,sizeof(bonds)),"bind problem bonds");
        }catch(...){cleanup();throw;}
    }
    ~NativeProblemCapture(){cleanup();}
    void begin(unsigned solve,cudaStream_t stream){
        enabled=solve>=first && solve<=last;
        checkCuda(cudaMemcpyToSymbolAsync(captureStressProblemEnabled,&enabled,sizeof(enabled),0,cudaMemcpyHostToDevice,stream),"select problem snapshot");
    }
    void finish(unsigned solve,cudaStream_t stream){
        if(!enabled)return;
        checkCuda(cudaMemcpyAsync(hostNodes.data(),nodes,hostNodes.size()*sizeof(*nodes),cudaMemcpyDeviceToHost,stream),"observe original stress nodes");
        checkCuda(cudaMemcpyAsync(hostBonds.data(),bonds,hostBonds.size()*sizeof(*bonds),cudaMemcpyDeviceToHost,stream),"observe original stress bonds");
        checkCuda(cudaStreamSynchronize(stream),"complete original problem observation");
        const auto path=prefix+".solve-"+std::to_string(solve);
        write(path+".nodes.bin",hostNodes.data(),hostNodes.size()*sizeof(*nodes));
        write(path+".bonds.bin",hostBonds.data(),hostBonds.size()*sizeof(*bonds));
        const auto meta=std::string("{\"version\":1,\"solve\":")+std::to_string(solve)+",\"node_count\":"+std::to_string(hostNodes.size())
            +",\"bond_count\":"+std::to_string(hostBonds.size())+",\"record_bytes\":64,\"endian\":\"little\",\"stage\":\"after warm residual, before component solve\"}\n";
        write(path+".json",meta.data(),meta.size());
    }
};
#endif
