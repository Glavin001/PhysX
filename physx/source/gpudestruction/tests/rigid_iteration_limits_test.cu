// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#include "PxgBodySim.h"
#include "PxNodeIndex.h"
#include <cuda_runtime.h>
#include <cub/cub.cuh>
#include <algorithm>
#include <stdexcept>
#include <vector>
#include <cstdio>
namespace physx { namespace {
void check(cudaError_t e){if(e!=cudaSuccess)throw std::runtime_error(cudaGetErrorString(e));}
template<class T> void allocate(T*& p,size_t n){check(cudaMalloc(&p,sizeof(T)*std::max<size_t>(n,1)));}
#include "../src/PxgRigidIterationLimits.cuh"
}}
using namespace physx;
void require(bool ok,const char* why){if(!ok)throw std::runtime_error(why);}
int main(){try {
    NativeRigidIterationLimits limits;limits.initialize();
    for(PxU32 n:{0u,1u,257u,4099u,113664u}) {
        const PxU32 capacity=2*n+4;
        std::vector<PxgBodySim> host(capacity);std::vector<PxNodeIndex> ids(n+3,PxNodeIndex());
        for(auto& body:host)body.solverConfig=make_uint4(65535,0,0,0); // inactive, excluded
        PxU32 position=0,velocity=0;
        for(PxU32 i=0;i<n;++i) {
            const PxU32 p=1+i%31,v=i%9,index=2*i+2;
            host[index].solverConfig.x=p|(v<<8);ids[3+i]=PxNodeIndex(index);
            position=std::max(position,p);velocity=std::max(velocity,v);
        }
        PxgBodySim* bodies=nullptr;PxNodeIndex* active=nullptr;allocate(bodies,capacity);allocate(active,n+3);
        check(cudaMemcpy(bodies,host.data(),host.size()*sizeof(*bodies),cudaMemcpyHostToDevice));
        check(cudaMemcpy(active,ids.data(),ids.size()*sizeof(*active),cudaMemcpyHostToDevice));
        for(unsigned repeat=0;repeat<2;++repeat) {
            limits.prepare(bodies,capacity,active,3,n,0);PxU32 p=99,v=99;limits.read(p,v);
            require(p==position && v==velocity,"GPU limits disagree with independent active-only reduction");
        }
        if(n) {
            const PxNodeIndex invalid(capacity);check(cudaMemcpy(active+3,&invalid,sizeof(invalid),cudaMemcpyHostToDevice));
            limits.prepare(bodies,capacity,active,3,n,0);bool rejected=false;PxU32 p=0,v=0;
            try{limits.read(p,v);}catch(const std::runtime_error&){rejected=true;}
            require(rejected,"invalid active body accepted");
            check(cudaMemcpy(active+3,ids.data()+3,sizeof(*active),cudaMemcpyHostToDevice));
            host[2].solverConfig.x=0;check(cudaMemcpy(bodies+2,host.data()+2,sizeof(*bodies),cudaMemcpyHostToDevice));
            limits.prepare(bodies,capacity,active,3,n,0);rejected=false;
            try{limits.read(p,v);}catch(const std::runtime_error&){rejected=true;}
            require(rejected,"zero position iterations accepted");
        }
        check(cudaFree(bodies));check(cudaFree(active));std::printf("active rigid iteration limits: %u bodies, no bonds, PASS\n",n);
    }
    limits.clear();return 0;
}catch(const std::exception& e){std::fprintf(stderr,"%s\n",e.what());return 1;}}
