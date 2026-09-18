from pathlib import Path
import json,shlex,subprocess,shutil,hashlib
root=Path.cwd();out=root/'out/snapshot-finish-20260911/device-enabled-split';src=root/'physx/source/gpudestruction/src'
build=root/'out/sdk-release/sdk_gpu_source_bin/destruction-runtime';recipe=build/'CMakeFiles/PhysXDestructionGpuRuntime.dir'
flags={k.strip():shlex.split(v) for line in (recipe/'flags.make').read_text().splitlines() if ' = ' in line for k,v in [line.split(' = ',1)]}
cmd=['/usr/local/cuda-13.4/bin/nvcc',*flags['CUDA_DEFINES'],*flags['CUDA_INCLUDES'],'-I'+str(src),*flags['CUDA_FLAGS'],'-c',str(out/'PxgDestructionRuntime.cu'),'-o',str(out/'runtime.o')]
link=shlex.split((recipe/'link.txt').read_text());link[link.index('-o')+1]=str(out/'libPhysXDestructionGpuRuntime_64.so')
for i,arg in enumerate(link):
 if arg.endswith('PxgDestructionRuntime.cu.o'):link[i]=str(out/'runtime.o')
 if arg.endswith('PxgDestructionTopology.cu.o'):link[i]=str(out/'topology.o')
(out/'commands.json').write_text(json.dumps({'compile':cmd,'link':link,'cwd':str(build)},indent=2)+'\n')
with (out/'build.log').open('w') as log:
 subprocess.run(cmd,check=True,stdout=log,stderr=subprocess.STDOUT);subprocess.run(link,cwd=build,check=True,stdout=log,stderr=subprocess.STDOUT)
shutil.copy2(root/'out/snapshot-large-20260911/final-artifacts/libPhysXGpuActivity_64.so',out)
(out/'hashes.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [out/'libPhysXDestructionGpuRuntime_64.so',out/'libPhysXGpuActivity_64.so',out/'PxgDestructionRuntime.cu',out/'PxgDestructionCommittedChanges.cuh',out/'PxgDestructionDeviceGraph.cuh',out/'PxgDestructionMotionSlots.cuh']},indent=2)+'\n');print(out)
