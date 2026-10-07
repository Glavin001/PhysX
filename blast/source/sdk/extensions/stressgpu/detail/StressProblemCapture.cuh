#pragma once
#include "StressProblemCaptureSymbols.cuh"
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
// After the solve (version 2): each component's motion modes and verdict, and
// each node's correction mu (solver precision, widened) and final residual.
struct CapturedStressComponent {
    unsigned id,nodes,anchored,rotations,closure,iterations,converged,active,failed;
    float tolerance2,residual2,gamma,direction,pad[3];
};
struct CapturedStressSolution {
    double mu[6];
    float residual[6];
    unsigned component,pad;
};
// Bond geometry and material index, for evaluating bond stress offline.
struct CapturedStressBondGeometry {
    float normal[3],area,nodeDistance;
    unsigned material,pad[2];
};
static_assert(sizeof(CapturedStressComponent)==64 && sizeof(CapturedStressSolution)==80 && sizeof(CapturedStressBondGeometry)==32,"problem capture v2 wire layout");
__device__ CapturedStressNode* capturedStressNodes;
__device__ CapturedStressBond* capturedStressBonds;
__device__ CapturedStressComponent* capturedStressComponents;
__device__ CapturedStressSolution* capturedStressSolution;
__device__ unsigned capturedStressComponentCount;
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
// Launched after finishComponentStress: the iterate the solve stopped at,
// before lambda = lambda0 + W mu is applied.
__global__ void captureStressSolution(PersistentStressArgs a,ResidentStressComponentView c,unsigned n){
    if(!captureStressProblemEnabled)return;
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i==0)capturedStressComponentCount=*c.count;
    if(i<*c.count){
        const unsigned id=c.ids[i];const auto m=a.hierarchy.modes.components[id];const auto r=c.results[id];
        auto& out=capturedStressComponents[i];
        out.id=id;out.nodes=c.end[id]-c.begin[id];out.anchored=m.anchored;out.rotations=m.rotations;out.closure=m.closure;
        out.iterations=r.iterations;out.converged=r.converged;out.active=r.active;out.failed=a.hierarchy.failed[id];
        out.tolerance2=a.m_deltaSquared[id];out.residual2=a.m_gradientSquared[id];out.gamma=a.hierarchy.gamma[id];
        out.direction=a.m_projectedDirectionSquared[id];out.pad[0]=out.pad[1]=out.pad[2]=0;
    }
    if(i<n){
        auto& out=capturedStressSolution[i];const auto u=a.hierarchy.solution[i];
        out.mu[0]=double(u.angular.x);out.mu[1]=double(u.angular.y);out.mu[2]=double(u.angular.z);
        out.mu[3]=double(u.linear.x);out.mu[4]=double(u.linear.y);out.mu[5]=double(u.linear.z);
        captureSix(out.residual,a.m_residual[i]);out.component=a.m_nodeIsland[i];out.pad=0;
    }
}
// What the host copies after the solve completes (final lambda, geometry).
struct NativeProblemSources {
    const AngLin* impulses;const Vec4* normals;const float* areas;const float* nodeDistances;
    const std::uint32_t* bondMaterials;const ExtStressGpuMaterial* materials;unsigned materialCount;
    float lengthScale,massScale;
    // Per-bond rotational scale A (StressBondRotation.cuh), packed symmetric,
    // or null: written as <solve>.rotation.bin (6 floats per bond).
    const float* angularScale=nullptr;
};
class NativeProblemCapture {
    CapturedStressNode* nodes=nullptr;CapturedStressBond* bonds=nullptr;
    CapturedStressComponent* components=nullptr;CapturedStressSolution* solution=nullptr;float* history=nullptr;
    std::vector<CapturedStressNode> hostNodes;std::vector<CapturedStressBond> hostBonds;
    std::vector<CapturedStressComponent> hostComponents;std::vector<CapturedStressSolution> hostSolution;std::vector<float> hostHistory;
    std::vector<AngLin> hostLambda;std::vector<Vec4> hostNormals;std::vector<float> hostAreas,hostDistances;std::vector<std::uint32_t> hostMaterials;
    std::vector<CapturedStressBondGeometry> hostGeometry;
    std::string prefix;unsigned first=0,last=0,enabled=0,historyLimit=256;
    NativeProblemSources sources{};
    void cleanup(){for(void* p:{(void*)nodes,(void*)bonds,(void*)components,(void*)solution,(void*)history})if(p)cudaFree(p);
        nodes=nullptr;bonds=nullptr;components=nullptr;solution=nullptr;history=nullptr;}
    static void write(const std::string& path,const void* data,size_t size){
        FILE* f=std::fopen(path.c_str(),"wbx");if(!f)throw std::runtime_error("cannot create new native problem artifact");
        const bool ok=std::fwrite(data,1,size,f)==size;const bool closed=std::fclose(f)==0;
        if(!ok || !closed)throw std::runtime_error("native problem capture incomplete");
    }
    template<class T> static void bind(T* const& symbol,T* value,const char* what){
#if defined(PX_CUMETAL) && PX_CUMETAL
        // CuMetal's C symbol API takes the host registration address; its
        // reference overload deliberately excludes pointer-valued symbols.
        checkCuda(cudaMemcpyToSymbol(static_cast<const void*>(&symbol),&value,sizeof(value),0,cudaMemcpyHostToDevice),what);
#else
        checkCuda(cudaMemcpyToSymbol(symbol,&value,sizeof(value)),what);
#endif
    }
public:
    NativeProblemCapture(unsigned n,unsigned m):hostNodes(n),hostBonds(m),hostComponents(n),hostSolution(n){
        const char* path=std::getenv("PHYSX_STRESS_PROBLEM_PREFIX");
        const char* range=std::getenv("PHYSX_STRESS_PROBLEM_SOLVES");char extra;
        if(!path || !*path || !range || std::sscanf(range,"%u:%u%c",&first,&last,&extra)!=2 || last<first)
            throw std::runtime_error("problem diagnostic requires prefix and inclusive first:last solve ordinals");
        // Iterations of history kept per component (PHYSX_STRESS_PROBLEM_HISTORY, default 256).
        if(const char* h=std::getenv("PHYSX_STRESS_PROBLEM_HISTORY"))historyLimit=unsigned(std::strtoul(h,nullptr,10));
        prefix=path;hostHistory.resize(std::size_t(n)*historyLimit*3u);
        try{
            checkCuda(cudaMalloc(&nodes,sizeof(*nodes)*n),"allocate problem node snapshot");
            checkCuda(cudaMalloc(&bonds,sizeof(*bonds)*m),"allocate problem bond snapshot");
            checkCuda(cudaMalloc(&components,sizeof(*components)*n),"allocate problem component snapshot");
            checkCuda(cudaMalloc(&solution,sizeof(*solution)*n),"allocate problem solution snapshot");
            checkCuda(cudaMalloc(&history,sizeof(float)*std::max<std::size_t>(1,hostHistory.size())),"allocate problem history");
            bind(capturedStressNodes,nodes,"bind problem nodes");
            bind(capturedStressBonds,bonds,"bind problem bonds");
            bind(capturedStressComponents,components,"bind problem components");
            bind(capturedStressSolution,solution,"bind problem solution");
            bind(capturedStressHistory,history,"bind problem history");
            checkCuda(cudaMemcpyToSymbol(capturedStressHistoryLimit,&historyLimit,sizeof(historyLimit)),"bind problem history limit");
        }catch(...){cleanup();throw;}
    }
    ~NativeProblemCapture(){cleanup();}
    void begin(unsigned solve,cudaStream_t stream){
        enabled=solve>=first && solve<=last;
        checkCuda(cudaMemcpyToSymbolAsync(captureStressProblemEnabled,&enabled,sizeof(enabled),0,cudaMemcpyHostToDevice,stream),"select problem snapshot");
        // NaN: an iteration a component never reached.
        if(enabled)checkCuda(cudaMemsetAsync(history,0xff,sizeof(float)*hostHistory.size(),stream),"clear problem history");
    }
    void setSources(const NativeProblemSources& s){sources=s;}
    void finish(unsigned solve,cudaStream_t stream){
        if(!enabled)return;
        const std::size_t n=hostNodes.size(),m=hostBonds.size();
        static_assert(sizeof(AngLin)==32 && sizeof(Vec4)==16,"problem capture source layout");
        if(!sources.impulses)throw std::runtime_error("problem capture v2 requires the solver's sources");
        hostLambda.resize(m);hostNormals.resize(m);hostAreas.resize(m);hostDistances.resize(m);hostMaterials.resize(m);hostGeometry.resize(m);
        std::vector<ExtStressGpuMaterial> materials(sources.materialCount);
        unsigned componentCount=0;
        checkCuda(cudaMemcpyAsync(hostNodes.data(),nodes,n*sizeof(*nodes),cudaMemcpyDeviceToHost,stream),"observe original stress nodes");
        checkCuda(cudaMemcpyAsync(hostBonds.data(),bonds,m*sizeof(*bonds),cudaMemcpyDeviceToHost,stream),"observe original stress bonds");
        checkCuda(cudaMemcpyAsync(hostComponents.data(),components,n*sizeof(*components),cudaMemcpyDeviceToHost,stream),"observe solved components");
        checkCuda(cudaMemcpyAsync(hostSolution.data(),solution,n*sizeof(*solution),cudaMemcpyDeviceToHost,stream),"observe solution");
        checkCuda(cudaMemcpyAsync(hostHistory.data(),history,hostHistory.size()*sizeof(float),cudaMemcpyDeviceToHost,stream),"observe history");
#if defined(PX_CUMETAL) && PX_CUMETAL
        checkCuda(cudaMemcpyFromSymbolAsync(&componentCount,static_cast<const void*>(&capturedStressComponentCount),sizeof(componentCount),0,cudaMemcpyDeviceToHost,stream),"observe component count");
#else
        checkCuda(cudaMemcpyFromSymbolAsync(&componentCount,capturedStressComponentCount,sizeof(componentCount),0,cudaMemcpyDeviceToHost,stream),"observe component count");
#endif
        checkCuda(cudaMemcpyAsync(hostLambda.data(),sources.impulses,m*sizeof(AngLin),cudaMemcpyDeviceToHost,stream),"observe final lambda");
        checkCuda(cudaMemcpyAsync(hostNormals.data(),sources.normals,m*sizeof(Vec4),cudaMemcpyDeviceToHost,stream),"observe bond normals");
        checkCuda(cudaMemcpyAsync(hostAreas.data(),sources.areas,m*sizeof(float),cudaMemcpyDeviceToHost,stream),"observe bond areas");
        checkCuda(cudaMemcpyAsync(hostDistances.data(),sources.nodeDistances,m*sizeof(float),cudaMemcpyDeviceToHost,stream),"observe bond distances");
        checkCuda(cudaMemcpyAsync(hostMaterials.data(),sources.bondMaterials,m*sizeof(std::uint32_t),cudaMemcpyDeviceToHost,stream),"observe bond materials");
        if(!materials.empty())checkCuda(cudaMemcpyAsync(materials.data(),sources.materials,materials.size()*sizeof(ExtStressGpuMaterial),cudaMemcpyDeviceToHost,stream),"observe materials");
        checkCuda(cudaStreamSynchronize(stream),"complete original problem observation");
        componentCount=std::min<unsigned>(componentCount,unsigned(n));
        for(std::size_t i=0;i<m;++i){auto& g=hostGeometry[i];const auto v=hostNormals[i];
            g.normal[0]=v.x;g.normal[1]=v.y;g.normal[2]=v.z;g.area=hostAreas[i];g.nodeDistance=hostDistances[i];g.material=hostMaterials[i];g.pad[0]=g.pad[1]=0;}
        const auto path=prefix+".solve-"+std::to_string(solve);
        write(path+".nodes.bin",hostNodes.data(),n*sizeof(*nodes));
        write(path+".bonds.bin",hostBonds.data(),m*sizeof(*bonds));
        write(path+".components.bin",hostComponents.data(),componentCount*sizeof(CapturedStressComponent));
        write(path+".solution.bin",hostSolution.data(),n*sizeof(CapturedStressSolution));
        write(path+".lambda.bin",hostLambda.data(),m*sizeof(AngLin));
        write(path+".geometry.bin",hostGeometry.data(),m*sizeof(CapturedStressBondGeometry));
        write(path+".history.bin",hostHistory.data(),hostHistory.size()*sizeof(float));
        if(sources.angularScale){std::vector<float> rotation(6*m);
            checkCuda(cudaMemcpy(rotation.data(),sources.angularScale,rotation.size()*sizeof(float),cudaMemcpyDeviceToHost),"observe bond rotational scales");
            write(path+".rotation.bin",rotation.data(),rotation.size()*sizeof(float));}
        char scales[160];std::snprintf(scales,sizeof(scales),"\"length_scale\":%.9g,\"mass_scale\":%.9g",double(sources.lengthScale),double(sources.massScale));
        std::string mats="[";
        for(std::size_t k=0;k<materials.size();++k){const auto& x=materials[k];char b[256];
            std::snprintf(b,sizeof(b),"%s[%.9g,%.9g,%.9g,%.9g,%.9g,%.9g]",k?",":"",double(x.compressionElasticLimit),double(x.compressionFatalLimit),
                double(x.tensionElasticLimit),double(x.tensionFatalLimit),double(x.shearElasticLimit),double(x.shearFatalLimit));mats+=b;}
        mats+="]";
        const auto meta=std::string("{\"version\":2,")+(sources.angularScale?"\"rotation\":\"A per bond: xx yy zz xy xz yz (float)\",":"")+"\"solve\":"+std::to_string(solve)+",\"node_count\":"+std::to_string(n)
            +",\"bond_count\":"+std::to_string(m)+",\"record_bytes\":64,\"endian\":\"little\",\"stage\":\"after warm residual, before component solve\""
            +",\"component_count\":"+std::to_string(componentCount)+",\"history_limit\":"+std::to_string(historyLimit)
            +",\"history_fields\":[\"residual2\",\"gamma\",\"direction\"],\"solution_record_bytes\":80,\"component_record_bytes\":64"
            +",\"lambda\":\"final solver-scaled lambda per bond: angular xyzw, linear xyzw (float)\",\"geometry_record_bytes\":32,"
            +scales+",\"materials\":"+mats+",\"material_fields\":[\"compressionElastic\",\"compressionFatal\",\"tensionElastic\",\"tensionFatal\",\"shearElastic\",\"shearFatal\"]}\n";
        write(path+".json",meta.data(),meta.size());
    }
};
#endif
