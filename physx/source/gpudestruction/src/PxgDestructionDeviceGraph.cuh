#pragma once
// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
__global__ void transactionFill(unsigned char* destination,size_t width,size_t height,size_t pitch,unsigned value,unsigned elementSize) {
    const size_t rowBytes=width*elementSize;
    for(size_t i=size_t(blockIdx.x)*blockDim.x+threadIdx.x;i<rowBytes*height;i+=size_t(blockDim.x)*gridDim.x)
        destination[(i/rowBytes)*pitch+i%rowBytes]=static_cast<unsigned char>(value>>(8*(i%elementSize)));
}

struct DeviceGraphBodyView {const cudaGraphDeviceNode_t* nodes;unsigned count;};
__device__ void setDeviceGraphBodyEnabled(DeviceGraphBodyView body,bool enabled) {
    for(unsigned i=0;i<body.count;++i)if(cudaGraphKernelNodeSetEnabled(body.nodes[i],enabled)!=cudaSuccess)asm("trap;");
}
class DeviceGraphBody {
    cudaGraphDeviceNode_t* mNodes=nullptr;unsigned mCount=0;
public:
    void clear(){cudaFree(mNodes);mNodes=nullptr;mCount=0;}
    DeviceGraphBodyView view()const{return {mNodes,mCount};}
    bool initialize(cudaGraph_t graph,
        std::vector<cudaGraphNode_t>& roots) {
        size_t n=0;if(cudaGraphGetNodes(graph,nullptr,&n)!=cudaSuccess)return false;
        std::vector<cudaGraphNode_t> nodes(n);
        if(cudaGraphGetNodes(graph,nodes.data(),&n)!=cudaSuccess)return false;
        std::vector<cudaGraphDeviceNode_t> handles;handles.reserve(n);
        for(auto node:nodes) {
            cudaGraphNodeType type;if(cudaGraphNodeGetType(node,&type)!=cudaSuccess)return false;
            if(type==cudaGraphNodeTypeMemset) {
                cudaMemsetParams fill{};
                if(cudaGraphMemsetNodeGetParams(node,&fill)!=cudaSuccess)return false;
                if(fill.elementSize!=1 && fill.elementSize!=2 && fill.elementSize!=4)return false;
                size_t dependenciesCount=0,dependentsCount=0;
                if(cudaGraphNodeGetDependencies(node,nullptr,nullptr,&dependenciesCount)!=cudaSuccess
                    || cudaGraphNodeGetDependentNodes(node,nullptr,nullptr,&dependentsCount)!=cudaSuccess)return false;
                std::vector<cudaGraphNode_t> dependencies(dependenciesCount),dependents(dependentsCount);
                if(cudaGraphNodeGetDependencies(node,dependencies.data(),nullptr,&dependenciesCount)!=cudaSuccess
                    || cudaGraphNodeGetDependentNodes(node,dependents.data(),nullptr,&dependentsCount)!=cudaSuccess)return false;
                cudaKernelNodeParams params{};params.func=(void*)transactionFill;params.blockDim=dim3(256);
                params.gridDim=dim3(unsigned(std::min<size_t>(2560,(fill.width*fill.height*fill.elementSize+256-1)/256)));
                size_t pitch=fill.height==1?fill.width*fill.elementSize:fill.pitch;
                void* args[]={&fill.dst,&fill.width,&fill.height,&pitch,&fill.value,&fill.elementSize};params.kernelParams=args;
                cudaGraphNode_t replacement=nullptr;
                if(cudaGraphAddKernelNode(&replacement,graph,dependencies.data(),dependencies.size(),&params)!=cudaSuccess)return false;
                for(auto dependent:dependents)
                    if(cudaGraphAddDependencies(graph,&replacement,&dependent,nullptr,1)!=cudaSuccess)return false;
                if(cudaGraphDestroyNode(node)!=cudaSuccess)return false;
                node=replacement;type=cudaGraphNodeTypeKernel;
            }
            if(type!=cudaGraphNodeTypeKernel){fprintf(stderr,"Unsupported transaction graph node %d\n",int(type));return false;}
            cudaKernelNodeAttrValue attr{};attr.deviceUpdatableKernelNode.deviceUpdatable=1;
            if(cudaGraphKernelNodeSetAttribute(node,cudaKernelNodeAttributeDeviceUpdatableKernelNode,&attr)!=cudaSuccess
                || cudaGraphKernelNodeGetAttribute(node,cudaKernelNodeAttributeDeviceUpdatableKernelNode,&attr)!=cudaSuccess)return false;
            handles.push_back(attr.deviceUpdatableKernelNode.devNode);
        }
        mCount=unsigned(n);
        if(cudaMalloc(&mNodes,n*sizeof(cudaGraphDeviceNode_t))!=cudaSuccess
            || cudaMemcpy(mNodes,handles.data(),n*sizeof(cudaGraphDeviceNode_t),cudaMemcpyHostToDevice)!=cudaSuccess)return false;
        size_t r=0;if(cudaGraphGetRootNodes(graph,nullptr,&r)!=cudaSuccess)return false;
        roots.resize(r);return cudaGraphGetRootNodes(graph,roots.data(),&r)==cudaSuccess;
    }
    bool connectBody(cudaGraph_t graph,cudaGraphNode_t selector,const std::vector<cudaGraphNode_t>& roots) {
        for(auto root:roots)if(cudaGraphAddDependencies(graph,&selector,&root,nullptr,1)!=cudaSuccess)return false;
        return true;
    }
};
