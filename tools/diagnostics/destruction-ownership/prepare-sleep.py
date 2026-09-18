#!/usr/bin/env python3
"""Isolate one native device sleep-commit experiment from the selected source."""
import difflib, hashlib, json, shutil, subprocess
from pathlib import Path

ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'out/ownership-scheduling-20260915'
tree=BASE/'sleep-source'
shutil.copytree(BASE/'build-v1/control-source',tree)
changed={};patch=[]
def edit(name,fn):
    p=tree/name;old=p.read_text();new=fn(old)
    assert old!=new,name
    p.write_text(new);changed[name]=hashlib.sha256(p.read_bytes()).hexdigest()
    patch.extend(difflib.unified_diff(old.splitlines(True),new.splitlines(True),fromfile='a/'+name,tofile='b/'+name))
def replace(s,old,new):
    assert s.count(old)==1,old
    return s.replace(old,new)

edit('physx/source/gpucommon/include/PxgKernelNames.h',lambda s:s+'\nKERNEL_DEF(NATIVE_SLEEP_COMMIT, "commitNativeSleep")\n')
edit('physx/source/gpusimulationcontroller/src/CUDA/updateBodiesAndShapes.cu',lambda s:s+'''
// Private native transition, after the current solver and optional pose rollback.
// The four generic setters wrote these same fields in separate kernels. Keep
// inverse mass, penetration limit, physical settings and previous-velocity W
// channels intact. CPU activity/wake decisions remain authoritative here.
extern "C" __global__ void commitNativeSleep(const PxU32* indices,
    const PxgUpdateActorDataDesc* desc, PxgBodySimVelocities* previous, PxU32 count)
{
    const PxU32 i=blockIdx.x*blockDim.x+threadIdx.x;
    if(i>=count)return;
    const PxU32 node=indices[i];
    auto& body=desc->mBodySimBufferDeviceData[node];
    const auto linear=make_float4(0.f,0.f,0.f,body.linearVelocityXYZ_inverseMassW.w);
    const auto angular=make_float4(0.f,0.f,0.f,body.angularVelocityXYZ_maxPenBiasW.w);
    body.linearVelocityXYZ_inverseMassW=linear;
    body.angularVelocityXYZ_maxPenBiasW=angular;
    if(previous){previous[node].linearVelocity=linear;previous[node].angularVelocity=angular;}
    body.externalLinearAcceleration=make_float4(0.f,0.f,0.f,0.f);
    body.externalAngularAcceleration=make_float4(0.f,0.f,0.f,0.f);
}
''')
def controller(s):
    # Preserve the old optional OmniPVD setter notifications. The measured
    # ordinary-API build has OmniPVD disabled and needs no zero upload buffer.
    s=replace(s,'                if(cuda->memAlloc(&newZeros, PxU64(count)*sizeof(PxVec3)) != 0)',
        '                #if PX_SUPPORT_OMNI_PVD\n                if(cuda->memAlloc(&newZeros, PxU64(count)*sizeof(PxVec3)) != 0)')
    s=replace(s,'                if(cuda->memAlloc(&newPoses, PxU64(count)*sizeof(PxTransform)) != 0)',
        '                #endif\n                if(cuda->memAlloc(&newPoses, PxU64(count)*sizeof(PxTransform)) != 0)')
    s=replace(s,'                    cuda->memFree(newZeros);','                    if(newZeros)cuda->memFree(newZeros);')
    s=replace(s,'                || cuda->memsetD32(mNativeSleepZeros, 0, PxU64(count)*3) != 0',
        '                #if PX_SUPPORT_OMNI_PVD\n                || cuda->memsetD32(mNativeSleepZeros, 0, PxU64(count)*3) != 0\n                #endif')
    # Recording the gather completion replaces its host wait. The next GPU
    # consumer explicitly waits for this event before refreshing pose/bounds.
    s=replace(s,'params, sizeof(params), 0, PX_FL) != 0 || cuda->streamSynchronize(solver->getStream()) != 0)',
        'params, sizeof(params), 0, PX_FL) != 0 || cuda->eventRecord(mNativeSleepReady,solver->getStream()) != 0)')
    s=replace(s,'PxRigidDynamicGPUAPIWriteType::eGLOBAL_POSE, count, mNativeSleepReady, NULL)) return false;',
        'PxRigidDynamicGPUAPIWriteType::eGLOBAL_POSE, count, mNativeSleepReady, mNativeSleepReady)) return false;')
    s=replace(s,'        // Sparse transition work completes before fetch returns or commands',
        '        #if PX_SUPPORT_OMNI_PVD\n        // Preserve optional per-property observation callbacks.\n        // Sparse transition work completes before fetch returns or commands')
    s=replace(s,'PxRigidDynamicGPUAPIWriteType::eTORQUE, count, mNativeSleepReady, NULL);',
        '''PxRigidDynamicGPUAPIWriteType::eTORQUE, count, mNativeSleepReady, NULL);
        #else
        // All current-state writes form one device operation. Join once before
        // public completion or a later command can reuse transition storage.
        PxScopedCudaLock lock(*mCudaContextManager);
        PxCudaContext* cuda=mCudaContextManager->getCudaContext();
        const CUstream stream=mSimulationCore->getStream();
        const CUdeviceptr desc=mSimulationCore->getUpdatedActorDescDesc();
        const CUdeviceptr previous=mSimulationCore->getBodySimPrevVelocitiesBufferDevicePtr();
        PxCudaKernelParam params[]={PX_CUDA_KERNEL_PARAM(mNativeSleepIndices),
            PX_CUDA_KERNEL_PARAM(desc),PX_CUDA_KERNEL_PARAM(previous),PX_CUDA_KERNEL_PARAM(count)};
        const CUfunction kernel=mGpuWranglerManager->getCuFunction(PxgKernelIds::NATIVE_SLEEP_COMMIT);
        return cuda->streamWaitEvent(stream,mNativeSleepReady,0)==0
            && cuda->launchKernel(kernel,(count+255)/256,1,1,256,1,1,0,stream,
                params,sizeof(params),0,PX_FL)==0
            && cuda->streamSynchronize(stream)==0;
        #endif''')
    return s
edit('physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp',controller)
(BASE/'sleep.patch').write_text(''.join(patch))
(BASE/'sleep-preparation.json').write_text(json.dumps(dict(status='prepared_not_built',source=str(tree),baseline='13b11af2',changes=changed,patch_sha256=hashlib.sha256((BASE/'sleep.patch').read_bytes()).hexdigest()),indent=2)+'\n')
print(tree)
