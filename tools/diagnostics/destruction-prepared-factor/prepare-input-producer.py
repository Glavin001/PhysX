#!/usr/bin/env python3
"""Move exact load-change detection to final load producers, preserving equations.

This independent native hypothesis removes the consumer's second per-node input
comparison. It does not skip damage integration, use stale contacts, or infer
equilibrium from sleeping. Saved certificates retain all original validity gates.
"""
import argparse
import difflib
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile
ROOT=Path(__file__).resolve().parents[3]
BASE='13b11af2e0aeabf4e0070931fbd8a060f383dfaf'
STRESS='blast/source/sdk/extensions/stressgpu'
RUNTIME='physx/source/gpudestruction'

HEADER='''#pragma once
// Private bridge between the two objects created by the native runtime factory.
// Borrowed device views expire with the solver. No public PhysX or Blast ABI.
#include "NvBlastExtStressGpu.h"
namespace Nv { namespace Blast {
struct NativeStressInputProducer {
    const ExtStressGpuImpulse* accepted=nullptr;
    const unsigned char* certificates=nullptr;
    const unsigned* nodeComponents=nullptr;
    unsigned* changed=nullptr;
    unsigned certificateStride=0,validOffset=0;
};
NativeStressInputProducer attachNativeStressInputProducer(ExtStressGpuSolver*);
}}
'''

OBSERVER='''// The last writer of each node's complete input owns this comparison.
// Untouched nodes include contacts removed this pass: they receive fresh base
// loads and are compared just like creation/change. Invalid certificates never
// expose uninitialized accepted-input storage.
__device__ void observeProducedInput(PxU32 node,const PxDestructionVectorPair& value,
    NativeStressInputProducer observer) {
    if(!observer.changed)return;
    const unsigned id=observer.nodeComponents[node];if(id==~0u)return;
    const unsigned valid=*reinterpret_cast<const unsigned*>(observer.certificates+
        size_t(id)*observer.certificateStride+observer.validOffset);
    if(!valid)return;
    const auto old=observer.accepted[node];
    const bool same=__float_as_uint(value.angular.x)==__float_as_uint(old.angular.x)
        && __float_as_uint(value.angular.y)==__float_as_uint(old.angular.y)
        && __float_as_uint(value.angular.z)==__float_as_uint(old.angular.z)
        && __float_as_uint(value.linear.x)==__float_as_uint(old.linear.x)
        && __float_as_uint(value.linear.y)==__float_as_uint(old.linear.y)
        && __float_as_uint(value.linear.z)==__float_as_uint(old.linear.z);
    if(!same)atomicExch(observer.changed+id,1u);
}
'''


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('output',type=Path);args=parser.parse_args()
    out=args.output.resolve();out.mkdir(parents=True,exist_ok=False);tree=out/'source';tree.mkdir()
    archive=subprocess.check_output(['git','archive',BASE,STRESS,RUNTIME],cwd=ROOT)
    before={}
    with tarfile.open(fileobj=io.BytesIO(archive)) as tar:
        for member in tar.getmembers():
            if not member.isfile():continue
            path=tree/member.name;path.parent.mkdir(parents=True,exist_ok=True)
            data=tar.extractfile(member).read();path.write_bytes(data);before[member.name]=data.decode()
    def edit(name,old,new):
        path=tree/name;text=path.read_text()
        if text.count(old)!=1:raise RuntimeError('Source match failed: '+name+' '+old[:80])
        path.write_text(text.replace(old,new))
    (tree/STRESS/'detail/NativeStressInputProducer.h').write_text(HEADER)
    cu=STRESS+'/NvBlastExtStressGpu.cu'
    edit(cu,'#include "NvBlastExtStressGpu.h"','#include "NvBlastExtStressGpu.h"\n#include "detail/NativeStressInputProducer.h"\n#include <cstddef>')
    edit(cu,'public:\n#include "detail/StressSolverLifetime.inl"','''public:
    NativeStressInputProducer attachInputProducer() {
#ifdef PHYSX_RESIDENT_DESTRUCTION
        if(!m_deviceTopology)return {};
        ContextGuard context(m_cudaContext);
        if(!m_producerLoadChanged){
            checkCuda(cudaMalloc(&m_producerLoadChanged,sizeof(unsigned)*m_nodeCount),"allocate producer load changes");
            m_graphParamsDirty=true;
        }
        const auto cache=m_deviceTopology->cycleView().settled;
        return {cache.inputs,reinterpret_cast<const unsigned char*>(cache.certificates),m_nodeIsland,
            m_producerLoadChanged,sizeof(NativeSettledCertificate),offsetof(NativeSettledCertificate,valid)};
#else
        return {};
#endif
    }
#include "detail/StressSolverLifetime.inl"''')
    edit(cu,'    float* m_bsHostGroupCentroid{nullptr};','    unsigned* m_producerLoadChanged{nullptr};\n    float* m_bsHostGroupCentroid{nullptr};')
    edit(cu,'ExtStressGpuSolver* ExtStressGpuSolver::create(','''// Only the native runtime's own factory-created solver reaches this bridge.
NativeStressInputProducer attachNativeStressInputProducer(ExtStressGpuSolver* solver) {
    return solver?static_cast<ExtStressGpuSolverImpl*>(solver)->attachInputProducer():NativeStressInputProducer{};
}

ExtStressGpuSolver* ExtStressGpuSolver::create(''')
    edit(STRESS+'/detail/StressSolverLifetime.inl','        delete m_deviceTopology;','        cudaFree(m_producerLoadChanged);\n        delete m_deviceTopology;')
    edit(STRESS+'/detail/StressNativeSettled.cuh','    unsigned* converged,unsigned* skip,bool warm,float tolerance,unsigned maxIterations){',
         '    unsigned* converged,unsigned* skip,bool warm,float tolerance,unsigned maxIterations,\n    const unsigned* producerChanged=nullptr){')
    edit(STRESS+'/detail/StressNativeSettled.cuh','        if(!dirty)for(unsigned i=components.begin[id]+threadIdx.x;i<components.end[id];i+=blockDim.x){',
         '        if(!dirty && producerChanged)dirty=producerChanged[id]!=0;\n        if(!dirty && !producerChanged)for(unsigned i=components.begin[id]+threadIdx.x;i<components.end[id];i+=blockDim.x){')
    edit(STRESS+'/detail/StressSolveSubmission.inl','                m_input,m_islandConverged,m_islandSkip,warmStart,params.tolerance,params.maxIterations);',
         '                m_input,m_islandConverged,m_islandSkip,warmStart,params.tolerance,params.maxIterations,m_producerLoadChanged);')
    cu=RUNTIME+'/src/PxgDestructionRuntime.cu'
    edit(cu,'#include "NvBlastExtStressMaterialFormula.h"','#include "NvBlastExtStressMaterialFormula.h"\n#include "detail/NativeStressInputProducer.h"')
    path=tree/cu;text=path.read_text();start=text.index('__global__ void prepareLoads(');end=text.index('__device__ void contactLoad(',start)
    original=text[start:end];initialize=original.replace('__global__ void prepareLoads(','__device__ void initializeLoad(PxU32 i, ')
    initialize=initialize.replace('    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;\n    if(i>=n)return;\n','')
    # Contact-rate accumulation can update BOTH endpoint chunks. Keep its
    # clearing in the preceding full-node launch, never in per-chunk routing.
    initialize=initialize.replace('surfaces[i]={}; inputs[i]={};if(rates)rates[i]=0;','surfaces[i]={}; inputs[i]={};')
    wrapper='''__global__ void prepareLoads(const PxDestructionStressChunk* chunks,PxU32 n,
    const PxDestructionStressCluster* clusters,const PxTransform* poses,const PxVec3* angular,
    PxVec3 gravity,PxDestructionVectorPair* inputs,PxDestructionSurfaceLoad* surfaces,float* rates,
    const unsigned* touched,NativeStressInputProducer observer) {
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=n)return;
    if(rates)rates[i]=0;
    if(touched[i])return;
    initializeLoad(i,chunks,n,clusters,poses,angular,gravity,inputs,surfaces,rates);
    observeProducedInput(i,inputs[i],observer);
}
'''
    path.write_text(text[:start]+OBSERVER+initialize+wrapper+text[end:])
    edit(cu,'    PxU32 maps,PxU64* keys) {','    PxU32 maps,PxU64* keys,unsigned* touched) {')
    edit(cu,'    if(a!=PX_INVALID_U32)keys[2*i]=(PxU64(a)<<32)|(2*i);\n    if(b!=PX_INVALID_U32)keys[2*i+1]=(PxU64(b)<<32)|(2*i+1);',
         '    if(a!=PX_INVALID_U32){keys[2*i]=(PxU64(a)<<32)|(2*i);atomicExch(touched+a,1u);}\n    if(b!=PX_INVALID_U32){keys[2*i+1]=(PxU64(b)<<32)|(2*i+1);atomicExch(touched+b,1u);}')
    edit(cu,'    const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates) {\n    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;',
         '    const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates,\n    PxU32 nodes,const PxDestructionStressCluster* clusters,const PxVec3* angular,PxVec3 gravity,NativeStressInputProducer observer) {\n    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;if(i>=count)return;')
    edit(cu,'    if(i && PxU32(keys[i-1]>>32)==chunk)return;','    if(i && PxU32(keys[i-1]>>32)==chunk)return;\n    initializeLoad(chunk,chunks,nodes,clusters,poses,angular,gravity,inputs,surface,rates);')
    edit(cu,'    }\n}\nstruct StableContactRouting {','    }\n    observeProducedInput(chunk,inputs[chunk],observer);\n}\nstruct StableContactRouting {')
    edit(cu,'        const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates,cudaStream_t stream) {\n        if(!contacts.pairCount)return;',
         '''        const PxgBodySim* bodies,const PxDestructionMaterial* materials,float* rates,cudaStream_t stream,
        PxU32 nodes,const PxDestructionStressCluster* clusters,const PxVec3* angular,PxVec3 gravity,
        unsigned* touched,NativeStressInputProducer observer) {
        check(cudaMemsetAsync(touched,0,sizeof(unsigned)*nodes,stream));
        if(observer.changed)check(cudaMemsetAsync(observer.changed,0,sizeof(unsigned)*nodes,stream));
        if(!contacts.pairCount){
            prepareLoads<<<(nodes+127)/128,128,0,stream>>>(chunks,nodes,clusters,poses,angular,gravity,inputs,surface,rates,touched,observer);
            check(cudaGetLastError());return;
        }''')
    edit(cu,'>(contacts,map,maps,keys);','>(contacts,map,maps,keys,touched);')
    edit(cu,'        routeSortedContacts<<<(n+127)/128,128,0,stream>>>(sorted,n,contacts,map,maps,chunks,poses,invDt,inputs,surface,status,bodies,materials,rates);',
         '        prepareLoads<<<(nodes+127)/128,128,0,stream>>>(chunks,nodes,clusters,poses,angular,gravity,inputs,surface,rates,touched,observer);\n        routeSortedContacts<<<(n+127)/128,128,0,stream>>>(sorted,n,contacts,map,maps,chunks,poses,invDt,inputs,surface,status,bodies,materials,rates,nodes,clusters,angular,gravity,observer);')
    edit(cu,'    PxDestructionVectorPair* mInputs{}; PxDestructionSurfaceLoad* mSurface{};',
         '    NativeStressInputProducer mInputProducer{};unsigned* mInputTouched{};\n    PxDestructionVectorPair* mInputs{}; PxDestructionSurfaceLoad* mSurface{};')
    edit(cu,'        cudaFree(mMap);mMap=nullptr;', '        mInputProducer={};cudaFree(mInputTouched);mInputTouched=nullptr;\n        cudaFree(mMap);mMap=nullptr;')
    edit(cu,'            allocate(mSurface,d.chunkCount);','            allocate(mSurface,d.chunkCount);allocate(mInputTouched,d.chunkCount);')
    edit(cu,'                if(!mTopology || (mSolver && !mSolver->enableDeviceTopology())){clear();return false;}',
         '                if(!mTopology || (mSolver && !mSolver->enableDeviceTopology())){clear();return false;}\n                if(mSolver)mInputProducer=attachNativeStressInputProducer(mSolver);')
    edit(cu,'            prepareLoads<<<(mN+127)/128,128,0,mStream>>>(mChunks,mN,mClusters,mPoses,mAngular,gravity,mInputs,mSurface,mRates);\n            mContactRouting.route(contacts,mMap,mMapCount,mChunks,mPoses,1.0f/dt,mInputs,mSurface,mStatus,bodyStates,mMaterials,mRates,mStream);',
         '            mContactRouting.route(contacts,mMap,mMapCount,mChunks,mPoses,1.0f/dt,mInputs,mSurface,mStatus,bodyStates,mMaterials,mRates,mStream,\n                mN,mClusters,mAngular,gravity,mInputTouched,mInputProducer);')
    patch=''
    for p in sorted(tree.rglob('*')):
        if not p.is_file():continue
        name=str(p.relative_to(tree));old=before.get(name,'');new=p.read_text()
        if old!=new:patch+=''.join(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+name,tofile='b/'+name))
    (out/'candidate.patch').write_text(patch)
    record=dict(status='prepared_not_built',baseline_commit=BASE,scope=__doc__,candidate_patch_sha256=hashlib.sha256(patch.encode()).hexdigest(),source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),files={str(p.relative_to(tree)):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.rglob('*') if p.is_file()})
    (out/'preparation.json').write_text(json.dumps(record,indent=2)+'\n');print(record['status'])

if __name__=='__main__':main()
