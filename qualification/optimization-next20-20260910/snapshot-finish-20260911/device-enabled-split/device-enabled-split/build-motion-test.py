from pathlib import Path
import json,shlex,subprocess
root=Path.cwd();out=root/'out/snapshot-finish-20260911/device-enabled-split';build=root/'out/destruction-sdk/topology';recipe=build/'CMakeFiles/destruction_motion_slots_test.dir'
s=(root/'physx/source/gpudestruction/tests/motion_slots_test.cu').read_text().replace('#include "../src/PxgDestructionMotionSlots.cuh"','#include "PxgDestructionMotionSlots.cuh"')
s=s.replace('#include "../src/PxgDestructionMotionState.cuh"','#include "'+str(root/'physx/source/gpudestruction/src/PxgDestructionMotionState.cuh')+'"')
(out/'motion_slots_test.cu').write_text(s)
flags={k.strip():shlex.split(v) for line in (recipe/'flags.make').read_text().splitlines() if ' = ' in line for k,v in [line.split(' = ',1)]}
cmd=['/usr/local/cuda-13.4/bin/nvcc',*flags['CUDA_DEFINES'],*flags['CUDA_INCLUDES'],*flags['CUDA_FLAGS'],'-c',str(out/'motion_slots_test.cu'),'-o',str(out/'motion-test.o')]
libs=shlex.split((recipe/'linkLibs.rsp').read_text());libs=[str(out/'topology.o') if x=='libPhysXDestructionTopologyGpu.a' else x for x in libs]
link=['/usr/bin/g++',str(out/'motion-test.o'),'-o',str(out/'motion-test'),*libs,'-L/usr/local/cuda-13.4/targets/x86_64-linux/lib/stubs','-L/usr/local/cuda-13.4/targets/x86_64-linux/lib']
(out/'motion-test-commands.json').write_text(json.dumps([cmd,link],indent=2)+'\n')
with (out/'motion-test-build.log').open('w') as log:
 subprocess.run(cmd,cwd=build,stdout=log,stderr=subprocess.STDOUT,check=True);subprocess.run(link,cwd=build,stdout=log,stderr=subprocess.STDOUT,check=True)
