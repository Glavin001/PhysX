// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "native_gpu_visuals.h"
#include <cuda_runtime.h>
#include <math_constants.h>
#include <stdexcept>
namespace blast_demo {
namespace {
using namespace physx;
__device__ bool chunkPose(PxDestructionDeviceView view, const NativeGpuVisual* visuals,
    PxU32 i, PxTransform& pose, bool& invalid) {
    const auto t=view.acceptedTopology;
    if(!t.activeChunks[i])return false;
    const PxU32 root=t.chunkCluster[i];
    if(root>=t.chunkCount){invalid=true;return false;}
    const PxU32 slot=t.clusterSlots[root];
    if(slot>=t.slotCapacity || t.slotRoots[slot]!=root || !t.slotGenerations[slot]){invalid=true;return false;}
    const auto m=t.motions[slot];
    const PxTransform cluster(PxVec3(float(m.origin[0]),float(m.origin[1]),float(m.origin[2])),
        PxQuat(float(m.orientation[0]),float(m.orientation[1]),float(m.orientation[2]),float(m.orientation[3])));
    if(!cluster.isValid()){invalid=true;return false;}
    pose=cluster*PxTransform(visuals[i].position);return true;
}
__device__ NativeGpuInstance instance(PxTransform pose,PxVec3 scale,PxU32 palette) {
    const float colors[6][3]={{.78f,.70f,.55f},{.44f,.58f,.68f},{.66f,.57f,.47f},{.57f,.64f,.58f},{.5f,.5f,.5f},{.95f,.20f,.05f}};
    NativeGpuInstance out{};
    out.position[0]=pose.p.x;out.position[1]=pose.p.y;out.position[2]=pose.p.z;out.position[3]=1;
    out.orientation[0]=pose.q.x;out.orientation[1]=pose.q.y;out.orientation[2]=pose.q.z;out.orientation[3]=pose.q.w;
    out.scale[0]=scale.x;out.scale[1]=scale.y;out.scale[2]=scale.z;
    for(unsigned j=0;j<3;++j)out.color[j]=colors[palette%6][j];out.color[3]=1;return out;
}
// Color is an observation of accepted connectivity, never a grouping rule.
// Root + generation survive motion and packed-slot reordering. Recycled handles
// receive a new color. The hash is a visual aid, not a unique identity encoding.
__device__ void clusterColor(PxDestructionDeviceView view,PxU32 chunk,float* color) {
    const auto t=view.acceptedTopology;const PxU32 root=t.chunkCluster[chunk];
    const PxU64 generation=t.slotGenerations[t.clusterSlots[root]];
    PxU32 key=root ^ PxU32(generation)*0x9e3779b9u ^ PxU32(generation>>32);
    key^=key>>16;key*=0x7feb352du;key^=key>>15;key*=0x846ca68bu;key^=key>>16;
    const float hue=float(key&0xffffffu)*(6.0f/16777216.0f);
    const float low=.24f,high=.95f,f=hue-floorf(hue);
    const float rising=low+(high-low)*f,falling=high-(high-low)*f;
    switch(unsigned(hue)) {
        case 0:color[0]=high;color[1]=rising;color[2]=low;break;
        case 1:color[0]=falling;color[1]=high;color[2]=low;break;
        case 2:color[0]=low;color[1]=high;color[2]=rising;break;
        case 3:color[0]=low;color[1]=falling;color[2]=high;break;
        case 4:color[0]=rising;color[1]=low;color[2]=high;break;
        default:color[0]=high;color[1]=low;color[2]=falling;break;
    }
}
__global__ void instances(PxDestructionDeviceView view,const NativeGpuVisual* visuals,
    const PxTransform* shots,PxU32 count,NativeGpuInstance* out,NativeGpuVisualStatus* status,bool colorByCluster) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=view.chunkCount+count)return;
    NativeGpuInstance value{};bool invalid=false;
    if(view.status->error || !view.status->frame || view.acceptedTopology.status->slotError)invalid=true;
    else if(i<view.chunkCount) {
        PxTransform pose;
        if(chunkPose(view,visuals,i,pose,invalid)) {
            value=instance(pose,visuals[i].half,visuals[i].palette);
            if(colorByCluster)clusterColor(view,i,value.color);
        }
    } else {
        const auto pose=shots[i-view.chunkCount];
        if(!pose.isValid())invalid=true;
        else {
            value=instance(pose,PxVec3(.75f),5);
            if(colorByCluster)for(unsigned j=0;j<3;++j)value.color[j]=.95f;
        }
    }
    out[i]=value;
    if(invalid)atomicOr(&status->errors,1u);
    if(value.position[3])atomicAdd(&status->visible,1u);
}
__global__ void initializeHeight(float* height,float y){*height=y;}
__device__ void raiseHeight(float* height,float value) {
    // Launch heights are positive in this demo; handle all finite signed floats
    // anyway so tests and future consumers don't depend on float bit ordering.
    auto* address=reinterpret_cast<unsigned*>(height);unsigned old=atomicAdd(address,0u),assumed;
    while(__uint_as_float(old)<value){assumed=old;old=atomicCAS(address,assumed,__float_as_uint(value));if(old==assumed)break;}
}
__global__ void launchHeight(PxDestructionDeviceView view,const NativeGpuVisual* visuals,
    const PxTransform* shots,PxU32 count,PxVec3 launch,float radius,float* height) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=view.chunkCount+count)return;
    PxTransform pose;float objectRadius=.75f;
    if(i<view.chunkCount){bool invalid=false;if(!chunkPose(view,visuals,i,pose,invalid)) {
        if(invalid)raiseHeight(height,CUDART_INF_F);return;
    } objectRadius=visuals[i].half.magnitude();}
    else {pose=shots[i-view.chunkCount];if(!pose.isValid()){raiseHeight(height,CUDART_INF_F);return;}}
    const float dx=pose.p.x-launch.x,dz=pose.p.z-launch.z,r=radius+objectRadius;
    const float horizontal=dx*dx+dz*dz;
    if(horizontal<r*r && pose.p.y+r>=launch.y)
        raiseHeight(height,pose.p.y+sqrtf(r*r-horizontal)+.01f);
}
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
}
void writeNativeGpuInstances(physx::PxDestructionDeviceView view,const NativeGpuVisual* visuals,
    const physx::PxTransform* shots,physx::PxU32 count,NativeGpuInstance* out,NativeGpuVisualStatus* status,CUstream stream,bool colorByCluster) {
    check(cudaMemsetAsync(&status->visible,0,sizeof(status->visible),stream));
    if(view.chunkCount+count)instances<<<(view.chunkCount+count+255)/256,256,0,stream>>>(view,visuals,shots,count,out,status,colorByCluster);
    check(cudaGetLastError());
}
void queryNativeGpuLaunch(physx::PxDestructionDeviceView view,const NativeGpuVisual* visuals,
    const physx::PxTransform* shots,physx::PxU32 count,physx::PxVec3 launch,float radius,float* height,CUstream stream) {
    initializeHeight<<<1,1,0,stream>>>(height,launch.y);
    if(view.chunkCount+count)launchHeight<<<(view.chunkCount+count+255)/256,256,0,stream>>>(view,visuals,shots,count,launch,radius,height);
    check(cudaGetLastError());
}
}
