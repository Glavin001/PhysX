#!/usr/bin/env python3
"""Prepare a REVIEW-ONLY patch. Never write or apply production source files."""
from pathlib import Path
import difflib
root=Path(__file__).resolve().parents[2]
before={};after={}
def put(path,text):
    before.setdefault(path,(root/path).read_text() if (root/path).exists() else '')
    after[path]=text
def edit(path,old,new):
    text=after.get(path,(root/path).read_text())
    assert old in text,(path,old[:100]);put(path,text.replace(old,new))
put('physx/source/gpudestruction/include/PxgDestructionStaticConstraints.h','''// Copyright (c) 2026. SPDX-License-Identifier: BSD-3-Clause
#pragma once
#include "foundation/PxSimpleTypes.h"
namespace physx {
struct PxgDestructionStaticCommand { PxU32 edge,node,kind,add; };
struct PxgDestructionStaticStats { PxU32 contacts,joints,maxContacts,maxJoints,error; };
}
''')
source=(root/'physx/source/gpudestruction/tests/static_registration_prototype.cuh').read_text()
source=source.replace('// Isolated prototype: not linked into production until ordering is qualified.','// GPU-owned rigid/static registration order. Host partitioning submits deltas.')
source=source.replace('struct StaticCommand { unsigned edge,node,kind,add; };','using StaticCommand=PxgDestructionStaticCommand;')
source=source.replace('struct StaticStats { unsigned contacts,joints,maxContacts,maxJoints,error; };','using StaticStats=PxgDestructionStaticStats;')
source=source.replace('const unsigned* active,unsigned offset','const PxNodeIndex* active,unsigned offset')
source=source.replace('unsigned node=active[size_t(offset)+i];\n    if(node>=nodes){if(!threadIdx.x)atomicOr(&stats->error,16u);return;}','''const auto handle=active[size_t(offset)+i];
    if(!handle.isValid() || handle.isArticulation() || handle.index()>=nodes){
        if(!threadIdx.x)atomicOr(&stats->error,16u);asm volatile("trap;");return;
    }
    unsigned node=handle.index();''')
source=source.replace('if(!threadIdx.x)atomicOr(&stats->error,32u);return;','if(!threadIdx.x)atomicOr(&stats->error,32u);asm volatile("trap;");return;')
source=source.replace('void gather(const unsigned* active','void gather(const PxNodeIndex* active')
put('physx/source/gpudestruction/src/PxgDestructionStaticConstraints.cuh',source)
source=(root/'physx/source/gpudestruction/tests/static_registration_prototype_test.cu').read_text()
source=source.replace('#include <cuda_runtime.h>','#include "PxgDestructionStaticConstraints.h"\n#include "PxNodeIndex.h"\nusing namespace physx;\n#include <cuda_runtime.h>')
source=source.replace('#include "static_registration_prototype.cuh"','#include "../src/PxgDestructionStaticConstraints.cuh"')
source=source.replace('Buffer<unsigned> ids(active.size());ids.upload(active);','std::vector<PxNodeIndex> handles;for(unsigned id:active)handles.push_back(id==~0u?PxNodeIndex():PxNodeIndex(id));\n    Buffer<PxNodeIndex> ids(active.size());ids.upload(handles);')
source=source.replace('StaticCommand{id,rng()%n,rng()%2,1}','StaticCommand{id,unsigned(rng()%n),unsigned(rng()%2),1}')
put('physx/source/gpudestruction/tests/static_registration_test.cu',source)
edit('physx/source/gpudestruction/CMakeLists.txt','    add_executable(destruction_registration_test tests/registration_test.cu)','''    add_executable(destruction_static_registration_test tests/static_registration_test.cu)
    target_link_libraries(destruction_static_registration_test PRIVATE PhysXDestructionTopologyGpu)
    target_compile_options(destruction_static_registration_test PRIVATE $<$<COMPILE_LANGUAGE:CUDA>:-lineinfo>)
    target_include_directories(destruction_static_registration_test PRIVATE ../gpucommon/include)
    set_target_properties(destruction_static_registration_test PROPERTIES CUDA_STANDARD 17 CUDA_ARCHITECTURES "89")
    add_test(NAME destruction_gpu_static_registration COMMAND destruction_static_registration_test)

    add_executable(destruction_registration_test tests/registration_test.cu)''')
edit('physx/source/gpudestruction/include/PxgDestructionRuntime.h','#include "PxvIslandMetadata.h"','#include "PxvIslandMetadata.h"\n#include "PxgDestructionStaticConstraints.h"')
edit('physx/source/gpudestruction/include/PxgDestructionRuntime.h','    virtual bool configured() const = 0;','''    virtual bool configured() const = 0;
    virtual bool updateStaticConstraints(const PxgDestructionStaticCommand*,PxU32,PxU32,PxU32,PxgDestructionStaticStats&,CUstream) = 0;
    virtual bool gatherStaticConstraints(const PxNodeIndex*,PxU32,PxU32,PxU32*,PxU32,PxU32*,PxU32,PxU32*,PxU32*,CUstream) = 0;''')
edit('physx/source/gpudestruction/src/PxgDestructionRuntime.cu','#include "PxgRigidIterationLimits.cuh"','#include "PxgRigidIterationLimits.cuh"\n#include "PxgDestructionStaticConstraints.cuh"')
edit('physx/source/gpudestruction/src/PxgDestructionRuntime.cu','    NativeRigidIterationLimits mRigidIterationLimits;','    NativeRigidIterationLimits mRigidIterationLimits;\n    StaticRegistry* mStaticConstraints=nullptr;')
edit('physx/source/gpudestruction/src/PxgDestructionRuntime.cu','        mRigidIterationLimits.initialize();','        mRigidIterationLimits.initialize();mStaticConstraints=new StaticRegistry;')
edit('physx/source/gpudestruction/src/PxgDestructionRuntime.cu','        mRigidIterationLimits.clear();','        mRigidIterationLimits.clear();delete mStaticConstraints;mStaticConstraints=nullptr;')
edit('physx/source/gpudestruction/src/PxgDestructionRuntime.cu','    bool prepareRigidIterationLimits(','''    bool updateStaticConstraints(const PxgDestructionStaticCommand* commands,PxU32 count,PxU32 capacity,PxU32 nodes,PxgDestructionStaticStats& stats,CUstream stream) override {
        if(mFailed)return false;
        try {Context current(mContext);stats=mStaticConstraints->update(commands,count,capacity,nodes,reinterpret_cast<cudaStream_t>(stream));return true;}
        catch(...){mFailed=true;return false;}
    }
    bool gatherStaticConstraints(const PxNodeIndex* active,PxU32 offset,PxU32 count,PxU32* contacts,PxU32 contactCapacity,PxU32* joints,PxU32 jointCapacity,PxU32* contactCounts,PxU32* jointCounts,CUstream stream) override {
        if(mFailed)return false;
        try {Context current(mContext);mStaticConstraints->gather(active,offset,count,contacts,contactCapacity,joints,jointCapacity,contactCounts,jointCounts,reinterpret_cast<cudaStream_t>(stream));return true;}
        catch(...){mFailed=true;return false;}
    }
    bool prepareRigidIterationLimits(''')
for path in ['physx/source/gpudestruction/include/PxgDestructionRuntime.h','physx/source/gpudestruction/src/PxgDestructionRuntime.cu','physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp']:
    edit(path,'PxCreateDestructionRuntimeV10','PxCreateDestructionRuntimeV11')
path='physx/source/gpusimulationcontroller/include/PxgBodySimManager.h'
edit(path,'#include "PxgBodySim.h"','#include "PxgBodySim.h"\n#include "PxgDestructionStaticConstraints.h"')
edit(path,'\t\t~PxgBodySimManager();','''        void enableNativeStaticConstraints();
        bool nativeStaticConstraints=false;
        PxArray<PxgDestructionStaticCommand> nativeStaticCommands;
        PxU32 nativeStaticCapacity=0;
        void nativeStaticCommand(PxU32 edge,PxU32 node,PxU32 kind,PxU32 add) {
            // Existing special-case partition insertion/removal is serialized.
            // No CPU per-body registration arrays or ordering cache are kept.
            nativeStaticCommands.pushBack({edge,node,kind,add});
            nativeStaticCapacity=PxMax(nativeStaticCapacity,edge==0xffffffffu?edge:edge+1);
        }
\t\t~PxgBodySimManager();''')
path='physx/source/gpusimulationcontroller/src/PxgBodySimManager.cpp'
edit(path,'bool PxgBodySimManager::addStaticRBContactManager(','''void PxgBodySimManager::enableNativeStaticConstraints()
{
    if(nativeStaticConstraints)return;
    // One-time adoption if the destruction API is attached to an existing scene.
    // Articulation lists retain their upstream owner and link ordering.
    for(PxU32 node=0;node<mTotalNumBodies;++node) {
        if(mNodeToRemapMap.find(node))continue;
        auto& lists=mStaticConstraints[node];
        for(PxU32 i=0;i<lists.mStaticContacts.size();++i)
            nativeStaticCommand(lists.mStaticContacts[i].uniqueId,node,0,1);
        for(PxU32 i=0;i<lists.mStaticJoints.size();++i)
            nativeStaticCommand(lists.mStaticJoints[i].uniqueId,node,1,1);
        lists.mStaticContacts.reset();lists.mStaticJoints.reset();
    }
    nativeStaticConstraints=true;
}

bool PxgBodySimManager::addStaticRBContactManager(''')
edit(path,'bool PxgBodySimManager::addStaticRBContactManager(PxU32 uniqueIndex, const PxNodeIndex nodeIndex)\n{','bool PxgBodySimManager::addStaticRBContactManager(PxU32 uniqueIndex, const PxNodeIndex nodeIndex)\n{\n    if(nativeStaticConstraints){nativeStaticCommand(uniqueIndex,nodeIndex.index(),0,1);return true;}')
edit(path,'return remove(uniqueIndex, mStaticConstraints[nodeIndex.index()].mStaticContacts, mTotalStaticRBContacts);','if(nativeStaticConstraints){nativeStaticCommand(uniqueIndex,nodeIndex.index(),0,0);return true;}\n\treturn remove(uniqueIndex, mStaticConstraints[nodeIndex.index()].mStaticContacts, mTotalStaticRBContacts);')
edit(path,'bool PxgBodySimManager::addStaticRBJoint(PxU32 uniqueIndex, const PxNodeIndex nodeIndex)\n{','bool PxgBodySimManager::addStaticRBJoint(PxU32 uniqueIndex, const PxNodeIndex nodeIndex)\n{\n    if(nativeStaticConstraints){nativeStaticCommand(uniqueIndex,nodeIndex.index(),1,1);return true;}')
edit(path,'return remove(uniqueIndex, mStaticConstraints[nodeIndex.index()].mStaticJoints, mTotalStaticRBJoints);','if(nativeStaticConstraints){nativeStaticCommand(uniqueIndex,nodeIndex.index(),1,0);return true;}\n\treturn remove(uniqueIndex, mStaticConstraints[nodeIndex.index()].mStaticJoints, mTotalStaticRBJoints);')
edit('physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp','if(mDestruction)mDynamicContext->activateDestructionNodeTracking();','if(mDestruction){mDynamicContext->activateDestructionNodeTracking();mBodySimManager.enableNativeStaticConstraints();}')
path='physx/source/gpusolver/include/PxgContext.h'
edit(path,'        bool usesNativeKinematicInputs();','''        bool usesNativeKinematicInputs();
        bool usesNativeStaticConstraints();
        bool updateNativeStaticConstraints(CUstream stream);
        void gatherNativeStaticConstraints(CUdeviceptr active,CUdeviceptr contacts,PxU32 contactCapacity,CUdeviceptr joints,PxU32 jointCapacity,CUdeviceptr contactCounts,CUdeviceptr jointCounts,CUstream stream);''')
path='physx/source/gpusolver/src/PxgContext.cpp'
edit(path,'    bool PxgGpuContext::usesNativeKinematicInputs()','''    bool PxgGpuContext::usesNativeStaticConstraints() {
        return getSimulationController()->getBodySimManager().nativeStaticConstraints;
    }
    bool PxgGpuContext::updateNativeStaticConstraints(CUstream stream) {
        if(!usesNativeStaticConstraints())return true;
        PX_PROFILE_ZONE("GpuDynamics.NativeStaticRegistration",0);
        auto& manager=getSimulationController()->getBodySimManager();
        auto* runtime=getSimulationController()->getNativeDestructionRuntime();
        PxgDestructionStaticStats stats{};
        if(!runtime || !runtime->updateStaticConstraints(manager.nativeStaticCommands.begin(),manager.nativeStaticCommands.size(),
            manager.nativeStaticCapacity,manager.mTotalNumBodies,stats,stream))return false;
        manager.nativeStaticCommands.clear();
        manager.mTotalStaticRBContacts=stats.contacts;manager.mTotalStaticRBJoints=stats.joints;
        // Preserve upstream historical capacity maxima; these do not suppress work.
        manager.mMaxStaticRBContacts=PxMax(manager.mMaxStaticRBContacts,stats.maxContacts);
        manager.mMaxStaticRBJoints=PxMax(manager.mMaxStaticRBJoints,stats.maxJoints);
        // The existing solver interface accepts 32-bit element counts. Validate
        // BEFORE any multiplication in allocation/batching, not after wrapping.
        const PxU64 contactElements=PxU64(manager.mMaxStaticRBContacts)*mBodyCount;
        const PxU64 jointElements=PxU64(manager.mMaxStaticRBJoints)*mBodyCount;
        if(contactElements>0xffffffffull || jointElements>0xffffffffull) {
            PxGetFoundation().error(PxErrorCode::eOUT_OF_MEMORY,PX_FL,
                "Native static constraint layout exceeds the solver address range.");
            return false;
        }
        return true;
    }
    void PxgGpuContext::gatherNativeStaticConstraints(CUdeviceptr active,CUdeviceptr contacts,PxU32 contactCapacity,
        CUdeviceptr joints,PxU32 jointCapacity,CUdeviceptr contactCounts,CUdeviceptr jointCounts,CUstream stream) {
        auto* runtime=getSimulationController()->getNativeDestructionRuntime();
        if(!runtime || !runtime->gatherStaticConstraints(reinterpret_cast<const PxNodeIndex*>(active),1+mKinematicCount,mBodyCount,
            reinterpret_cast<PxU32*>(contacts),contactCapacity,reinterpret_cast<PxU32*>(joints),jointCapacity,
            reinterpret_cast<PxU32*>(contactCounts),reinterpret_cast<PxU32*>(jointCounts),stream))
            getNarrowphaseCore()->mCudaContext->setAbortMode(true);
    }

    bool PxgGpuContext::usesNativeKinematicInputs()''')
edit(path,'\tvoid PxgGpuContext::doStaticRigidConstraintPrePrep(physx::PxBaseTask* continuation)\n\t{','\tvoid PxgGpuContext::doStaticRigidConstraintPrePrep(physx::PxBaseTask* continuation)\n\t{\n        if(usesNativeStaticConstraints())return;')
edit(path,'\t// At this point we are ready to allocate the pinned memory for the solver.','''    if(!updateNativeStaticConstraints(mGpuSolverCore->getStream())) {
        getNarrowphaseCore()->mCudaContext->setAbortMode(true);
        mGpuSolverCore->releaseContext();
        if(needsSolve(islandSim,mBodyCount,mArticulationCount))mGpuTask.getContinuation()->removeReference();
        return;
    }

\t// At this point we are ready to allocate the pinned memory for the solver.''')
edit(path,'mRigidStaticContactIndices.begin(), mRigidStaticContactIndices.size(), mRigidStaticJointIndices.begin(), mRigidStaticJointIndices.size(),','mRigidStaticContactIndices.begin(), usesNativeStaticConstraints()?bodySimManager.mMaxStaticRBContacts*mBodyCount:mRigidStaticContactIndices.size(), mRigidStaticJointIndices.begin(), usesNativeStaticConstraints()?bodySimManager.mMaxStaticRBJoints*mBodyCount:mRigidStaticJointIndices.size(),')
for path in ['physx/source/gpusolver/src/PxgCudaSolverCore.cpp','physx/source/gpusolver/src/PxgTGSCudaSolverCore.cpp']:
    text=(root/path).read_text()
    start=text.index('\tmCudaContext->memcpyHtoDAsync(mRigidStaticContactIndices.getDevicePtr(), rigidStaticContactIndices,')
    end=text.index('\n',text.index('mCudaContext->memcpyHtoDAsync(mRigidStaticJointCounts.getDevicePtr(), rigidStaticJointCounts,',start))
    old=text[start:end]
    edit(path,old,'''    if(mGpuContext->usesNativeStaticConstraints()) {
        mGpuContext->gatherNativeStaticConstraints(mIslandNodeIndices2.getDevicePtr(),mRigidStaticContactIndices.getDevicePtr(),rigidStaticContactIndSize,
            mRigidStaticJointIndices.getDevicePtr(),rigidStaticJointSize,mRigidStaticContactCounts.getDevicePtr(),mRigidStaticJointCounts.getDevicePtr(),mStream);
    } else {
'''+old+'\n    }')
output=[]
for path,text in sorted(after.items()):
    output.extend(difflib.unified_diff(before[path].splitlines(True),text.splitlines(True),
        fromfile='a/'+path if before[path] else '/dev/null',tofile='b/'+path))
patch=Path(__file__).with_name('integration-review.patch')
patch.write_text(''.join(output))
print(f'Review-only patch: {len(after)} files, {len(output)} diff lines. Production files were not written.')
