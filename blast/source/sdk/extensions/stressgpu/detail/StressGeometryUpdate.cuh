// Private native geometry transaction. Validation precedes every write, on the
// solver stream. Immutable input storage until readyEvent is the caller contract.
#ifdef PHYSX_RESIDENT_DESTRUCTION
struct DeviceStressGeometryState {
    ExtStressGpuDeviceGeometryStatus status{};
    unsigned work=0;
};
struct DeviceStressGeometryBuffers {
    float4* positions;Inertia* inertia;Vec4 *offset0,*offset1,*normals;
    float* distances;const unsigned *node0,*node1;
    unsigned nodes,bonds;float lengthScale,massScale;
};
__device__ bool finiteGeometryVector(Vec4 v){return isfinite(v.x)&&isfinite(v.y)&&isfinite(v.z);}
__device__ Vec4 geometryPosition(const ExtStressGpuGeometryNode& node){
    return makeVec(node.position[0],node.position[1],node.position[2]);
}
__device__ float geometryAngularWeight(float inertia,DeviceStressGeometryBuffers b){
    return inertia>0?float(sqrt(double(b.massScale)*b.lengthScale*b.lengthScale/double(inertia))):0;
}
// Explicit trailing fields keep the aligned return value fully initialized
// for CuMetal; they are not physical coefficients.
struct DeviceStressBondGeometry {Vec4 offset0,offset1,normal;float distance,reserved0,reserved1,reserved2;};
__device__ DeviceStressBondGeometry deriveStressBondGeometry(const ExtStressGpuGeometryNode* nodes,
    const ExtStressGpuGeometryBond* bonds,DeviceStressGeometryBuffers b,unsigned edge){
    const unsigned a=b.node0[edge],c=b.node1[edge];
    const Vec4 first=geometryPosition(nodes[a]),second=geometryPosition(nodes[c]);
    const Vec4 displacement=sub(second,first);
    const float distance=sqrtf(displacement.x*displacement.x+displacement.y*displacement.y+displacement.z*displacement.z);
    const auto bond=bonds[edge];Vec4 normal=makeVec(bond.normal[0],bond.normal[1],bond.normal[2]);
    const float normalLength=sqrtf(normal.x*normal.x+normal.y*normal.y+normal.z*normal.z);
    if(!(normalLength>0))normal=distance>0?mul(displacement,1.f/distance):makeVec(1,0,0);
    else{normal=mul(normal,1.f/normalLength);if(normal.x*displacement.x+normal.y*displacement.y+normal.z*displacement.z<0)normal=mul(normal,-1);}
    const Vec4 center=makeVec(bond.centroid[0],bond.centroid[1],bond.centroid[2]);
    Vec4 offset0{},offset1{};
    if(b.inertia[a].linear<=0){offset1=sub(center,second);offset0=mul(offset1,-1);}
    else if(b.inertia[c].linear<=0){offset0=sub(center,first);offset1=mul(offset0,-1);}
    else{offset0=mul(displacement,.5f);offset1=mul(offset0,-1);}
    return {mul(offset0,1.f/b.lengthScale),mul(offset1,1.f/b.lengthScale),normal,distance>1e-6f?distance:1.f,0,0,0};
}
__global__ void beginStressGeometry(DeviceStressGeometryState* state,const std::uint64_t* generation,const unsigned* accept){
    state->status.applied=0;state->work=0;
    if(accept && !*accept)return; // Do not hide an earlier rejected geometry batch.
    state->status.error=0;
    if(state->status.initialized && *generation<state->status.generation){state->status.error=1;return;}
    state->work=!state->status.initialized || *generation!=state->status.generation;
}
__global__ void validateStressGeometryNodes(DeviceStressGeometryState* state,const ExtStressGpuGeometryNode* nodes,DeviceStressGeometryBuffers b){
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(!state->work || i>=b.nodes)return;
    const auto node=nodes[i];const Vec4 position=geometryPosition(node);
    unsigned error=0;
    if(!finiteGeometryVector(position) || !isfinite(node.inertia))error|=2;
    if(node.inertia<0 || ((node.inertia>0)!=(b.inertia[i].angular>0)))error|=4;
    const float weight=geometryAngularWeight(node.inertia,b);
    if(!finiteGeometryVector(mul(position,1.f/b.lengthScale)) || !isfinite(weight) || (node.inertia>0 && !(weight>0)))error|=8;
    if(error)atomicOr(&state->status.error,error);
}
__global__ void validateStressGeometryBonds(DeviceStressGeometryState* state,const ExtStressGpuGeometryNode* nodes,
    const ExtStressGpuGeometryBond* bonds,DeviceStressGeometryBuffers b){
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(!state->work || i>=b.bonds)return;
    const auto input=bonds[i];const Vec4 center=makeVec(input.centroid[0],input.centroid[1],input.centroid[2]);
    const Vec4 normal=makeVec(input.normal[0],input.normal[1],input.normal[2]);unsigned error=0;
    if(!finiteGeometryVector(center) || !finiteGeometryVector(normal))error|=2;
    const auto value=deriveStressBondGeometry(nodes,bonds,b,i);
    const float magnitude=value.normal.x*value.normal.x+value.normal.y*value.normal.y+value.normal.z*value.normal.z;
    if(!finiteGeometryVector(value.offset0)||!finiteGeometryVector(value.offset1)||!finiteGeometryVector(value.normal)
        || !isfinite(value.distance) || !(magnitude>0))error|=8;
    if(error)atomicOr(&state->status.error,error);
}
__global__ void chooseStressGeometry(DeviceStressGeometryState* state){state->status.applied=state->work && !state->status.error;}
__global__ void applyStressGeometryNodes(const DeviceStressGeometryState* state,const ExtStressGpuGeometryNode* nodes,DeviceStressGeometryBuffers b){
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(!state->status.applied || i>=b.nodes)return;
    const auto position=mul(geometryPosition(nodes[i]),1.f/b.lengthScale);
    b.positions[i]=make_float4(position.x,position.y,position.z,0);
    b.inertia[i].angular=geometryAngularWeight(nodes[i].inertia,b);
}
__global__ void applyStressGeometryBonds(const DeviceStressGeometryState* state,const ExtStressGpuGeometryNode* nodes,
    const ExtStressGpuGeometryBond* bonds,DeviceStressGeometryBuffers b){
    const unsigned i=blockIdx.x*blockDim.x+threadIdx.x;if(!state->status.applied || i>=b.bonds)return;
    const auto value=deriveStressBondGeometry(nodes,bonds,b,i);
    b.offset0[i]=value.offset0;b.offset1[i]=value.offset1;b.normals[i]=value.normal;b.distances[i]=value.distance;
}
__global__ void finishStressGeometry(DeviceStressGeometryState* state,const std::uint64_t* generation){
    if(state->status.applied){state->status.generation=*generation;state->status.initialized=1;}
}
__global__ void guardStressGeometry(const DeviceStressGeometryState* state,ExtStressGpuDeviceTopologyStatus* topology){
    if(state->status.error)topology->error|=1u<<6;
}
__global__ void rejectInvalidGeometrySolve(const DeviceStressGeometryState* state,SolveStatus* status){
    // With no live islands there is no component kernel to reject bad geometry.
    // Preserve the actual iteration count, but never publish successful solve.
    if(state->status.error){status->active=1;status->converged=0;}
}
#endif
