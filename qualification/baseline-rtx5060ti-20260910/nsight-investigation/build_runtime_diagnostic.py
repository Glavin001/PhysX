from pathlib import Path
import shlex,subprocess,json,hashlib
root=Path.cwd();base=root/'out/baseline-20260910-ordinary-sleeping';dst=base/'runtime-diagnostic-build';dst.mkdir(exist_ok=True)
source_dir=root/'physx/source/gpudestruction/src';header=source_dir/'PxgDestructionMotionSlots.cuh';s=header.read_text()
s=s.replace('if(v.stage->error!=8u)return;', 'if(v.stage->error!=8u)return;\n    printf("DIAG begin gen=%llu stage=%u requests=%u capacity=%u work=%llu continuation=%llu\\n",(unsigned long long)p.generation,v.stage->error,p.allocationRequests,addresses.capacity,(unsigned long long)work,(unsigned long long)v.continuation);')
s=s.replace('const auto grid=cooperative_groups::this_grid();\n    countNativeMotionRequests(v);','const auto grid=cooperative_groups::this_grid();\n    if(!grid.thread_rank())printf("DIAG allocation gen=%llu stage=%u error=%u capacity=%u\\n",(unsigned long long)v.preparation->generation,v.stage->error,v.allocation->error,v.pool->capacity);\n    countNativeMotionRequests(v);')
(dst/header.name).write_text(s)
original=source_dir/'PxgDestructionRuntime.cu';s=original.read_text();s=s.replace('#include "PxgDestructionMotionSlots.cuh"','#include "'+str(dst/header.name)+'"')
s=s.replace('if(!initializedBodyAllocation(allocation))collision->error|=64u;', 'if(!initializedBodyAllocation(allocation)){printf("DIAG collision stage=%u allocationError=%u\\n",stage->error,allocation->error);collision->error|=64u;}')
source=dst/original.name;source.write_text(s)
build=root/'out/sdk-release/sdk_gpu_source_bin/destruction-runtime';flags={}
for line in (build/'CMakeFiles/PhysXDestructionGpuRuntime.dir/flags.make').read_text().splitlines():
 if ' = ' in line:
  k,v=line.split(' = ',1);flags[k]=shlex.split(v)
obj=dst/'runtime.o';lib=dst/'libPhysXDestructionGpuRuntime_64.so'
compile=['/usr/local/cuda-13.4/bin/nvcc',*flags['CUDA_DEFINES'],*flags['CUDA_INCLUDES'],*flags['CUDA_FLAGS'],'-ccbin','/usr/bin/g++-12','-I'+str(source_dir),'-c',str(source),'-o',str(obj)]
link=shlex.split((build/'CMakeFiles/PhysXDestructionGpuRuntime.dir/link.txt').read_text());original_obj=next(x for x in link if x.endswith('/PxgDestructionRuntime.cu.o'));link[link.index(original_obj)]=str(obj);link[link.index('-o')+1]=str(lib)
for cmd in (compile,link):subprocess.run(cmd,cwd=build,check=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(dst/'build.json').write_text(json.dumps(dict(commands=[compile,link],cwd=str(build),source_sha256=sha(source),header_sha256=sha(dst/header.name),library_sha256=sha(lib)),indent=2)+'\n')
print(lib)
