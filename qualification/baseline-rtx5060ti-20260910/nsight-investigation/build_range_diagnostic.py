from pathlib import Path
import shlex, subprocess, json, hashlib
root=Path.cwd(); base=root/'out/baseline-20260910-ordinary-sleeping'; dst=base/'range-diagnostic-build';dst.mkdir(exist_ok=True)
original=root/'demos/blast-stress-demo/native_destruction_main.cpp'
s=original.read_text().replace('#include <cuda.h>', '#include <cuda.h>\n#include <cudaProfiler.h>'); s=s.replace('const auto begin=Clock::now();scene.simulate(dt);','if(frame==108){PxScopedCudaLock lock(cuda);check(cuProfilerStart());}\n        const auto begin=Clock::now();scene.simulate(dt);'); s=s.replace('const auto endNs=nativeProfileTimestamp(),endCpu=nativeProcessCpuNs();','if(frame==108){PxScopedCudaLock lock(cuda);check(cuProfilerStop());}\n        const auto endNs=nativeProfileTimestamp(),endCpu=nativeProcessCpuNs();'); needle='throw std::runtime_error("native demo correction incomplete");'
instrument='''
            {PxScopedCudaLock lock(cuda);const auto v=destruction->getDeviceView();
             PxDestructionBodyAllocationStatus a{};PxDestructionBodyPreparationStatus p{};PxDestructionMotionSlotStatus m{};
             const auto ra=cuMemcpyDtoH(&a,CUdeviceptr(v.bodyAllocation),sizeof(a));
             const auto rp=cuMemcpyDtoH(&p,CUdeviceptr(v.bodyPreparation),sizeof(p));
             const auto rm=cuMemcpyDtoH(&m,CUdeviceptr(v.motionSlots),sizeof(m));
             std::fprintf(stderr,"DIAGNOSTIC copies=%u/%u/%u allocation gen=%llu count=%u reserved=%u valid=%u error=%u initialized=%u initerror=%u preparation count=%u valid=%u error=%u requests=%u pool capacity=%u committed=%u pending=%u error=%u\\n",unsigned(ra),unsigned(rp),unsigned(rm),(unsigned long long)a.generation,a.count,a.reserved,a.valid,a.error,a.initialized,a.initializationError,p.count,p.valid,p.error,p.allocationRequests,m.capacity,m.committed,m.pending,m.error);
            }
            '''
assert s.count(needle)==1
source=dst/original.name;source.write_text(s.replace(needle,instrument+needle))
build=root/'out/destruction-sdk/reference'; flags={}
for line in (build/'CMakeFiles/native_destruction_demo.dir/flags.make').read_text().splitlines():
    if ' = ' in line:
        k,v=line.split(' = ',1);flags[k]=shlex.split(v)
obj=dst/'main.o';binary=dst/'native_destruction_demo'
compile=['/usr/bin/clang++',*flags['CXX_DEFINES'],*flags['CXX_INCLUDES'],*flags['CXX_FLAGS'],'-I'+str(original.parent),'-c',str(source),'-o',str(obj)]
link=shlex.split((build/'CMakeFiles/native_destruction_demo.dir/link.txt').read_text())
link[link.index('CMakeFiles/native_destruction_demo.dir/native_destruction_main.cpp.o')]=str(obj);link[link.index('-o')+1]=str(binary)
for cmd in (compile,link):subprocess.run(cmd,cwd=build,check=True)
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
(dst/'build.json').write_text(json.dumps(dict(commands=[compile,link],cwd=str(build),original_sha256=sha(original),diagnostic_sha256=sha(source),binary_sha256=sha(binary)),indent=2)+'\n')
print(binary)
