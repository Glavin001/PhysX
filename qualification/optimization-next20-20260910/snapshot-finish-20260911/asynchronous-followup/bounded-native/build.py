from pathlib import Path
import json,shlex,subprocess,shutil,hashlib,difflib
root=Path.cwd();out=root/'out/snapshot-finish-20260911/bounded-native';src=root/'physx/source/gpudestruction/src'
original=(src/'PxgDestructionTopology.cu').read_text();s=original
s=s.replace('#include <cuda_runtime.h>','#include <cuda_runtime.h>\n#include <cstdio>',1)
s=s.replace('__device__ unsigned root(unsigned* labels, unsigned i) {','__device__ unsigned root(unsigned* labels, unsigned i, unsigned n) {\n    if (i >= n) { printf("BAD_INITIAL_INDEX %u limit %u\\n",i,n); asm("trap;"); }')
s=s.replace('while (p != i) { i = p; p = atomicAdd(labels + i, 0u); }','while (p != i) { if (p >= n) { printf("BAD_PARENT_INDEX %u limit %u\\n",p,n); asm("trap;"); } i = p; p = atomicAdd(labels + i, 0u); }')
s=s.replace('const unsigned* alive, unsigned* labels) {','const unsigned* alive, unsigned* labels, unsigned n) {',1)
s=s.replace('const auto b = bonds[i];','const auto b = bonds[i];\n    if (b.chunk0 >= n || b.chunk1 >= n) { printf("BAD_EDGE_INDEX %u %u limit %u\\n",b.chunk0,b.chunk1,n); asm("trap;"); }',1)
s=s.replace('root(labels, a)','root(labels, a, n)').replace('root(labels, c)','root(labels, c, n)').replace('root(labels, i)','root(labels, i, n)')
s=s.replace('(mBonds, mM, mActiveBonds, mActiveChunks, mLabels);','(mBonds, mM, mActiveBonds, mActiveChunks, mLabels, mN);')
(out/'PxgDestructionTopology.cu').write_text(s)
shutil.copy2(src/'PxgDestructionTransaction.cuh',out)
(out/'diagnostic.patch').write_text(''.join(difflib.unified_diff(original.splitlines(True),s.splitlines(True),fromfile='production/PxgDestructionTopology.cu',tofile='candidate/PxgDestructionTopology.cu')))
build=root/'out/sdk-release/sdk_gpu_source_bin/destruction-runtime';recipe=build/'CMakeFiles/PhysXDestructionGpuRuntime.dir'
flags={k.strip():shlex.split(v) for line in (recipe/'flags.make').read_text().splitlines() if ' = ' in line for k,v in [line.split(' = ',1)]}
cmd=['/usr/local/cuda-13.4/bin/nvcc',*flags['CUDA_DEFINES'],*flags['CUDA_INCLUDES'],'-I'+str(src),*flags['CUDA_FLAGS'],'-c',str(out/'PxgDestructionTopology.cu'),'-o',str(out/'topology.o')]
link=shlex.split((recipe/'link.txt').read_text());link[link.index('-o')+1]=str(out/'libPhysXDestructionGpuRuntime_64.so')
for i,arg in enumerate(link):
 if arg.endswith('PxgDestructionTopology.cu.o'):link[i]=str(out/'topology.o')
(out/'commands.json').write_text(json.dumps({'compile':cmd,'link':link,'cwd':str(build)},indent=2)+'\n')
with (out/'build.log').open('w') as log:
 subprocess.run(cmd,check=True,stdout=log,stderr=subprocess.STDOUT);subprocess.run(link,cwd=build,check=True,stdout=log,stderr=subprocess.STDOUT)
shutil.copy2(root/'out/snapshot-large-20260911/final-artifacts/libPhysXGpuActivity_64.so',out)
(out/'hashes.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in [out/'libPhysXDestructionGpuRuntime_64.so',out/'libPhysXGpuActivity_64.so',out/'PxgDestructionTopology.cu',out/'PxgDestructionTransaction.cuh']},indent=2)+'\n');print(out)
