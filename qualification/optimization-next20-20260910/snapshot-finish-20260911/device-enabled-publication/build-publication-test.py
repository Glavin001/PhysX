from pathlib import Path
import json,shlex,subprocess
root=Path.cwd();out=root/'out/snapshot-finish-20260911/device-enabled-publication';build=root/'out/destruction-sdk/topology';recipe=build/'CMakeFiles/destruction_committed_changes_test.dir'
s=(root/'physx/source/gpudestruction/tests/committed_changes_test.cu').read_text().replace('#include "../src/PxgDestructionCommittedChanges.cuh"','#include "PxgDestructionCommittedChanges.cuh"')
(out/'committed_changes_test.cu').write_text(s)
flags={k.strip():shlex.split(v) for line in (recipe/'flags.make').read_text().splitlines() if ' = ' in line for k,v in [line.split(' = ',1)]}
cmd=['/usr/local/cuda-13.4/bin/nvcc',*flags['CUDA_DEFINES'],*flags['CUDA_INCLUDES'],*flags['CUDA_FLAGS'],'-c',str(out/'committed_changes_test.cu'),'-o',str(out/'publication-test.o')]
libs=shlex.split((recipe/'linkLibs.rsp').read_text());libs=[str(out/'topology.o') if x=='libPhysXDestructionTopologyGpu.a' else x for x in libs]
link=['/usr/bin/g++',str(out/'publication-test.o'),'-o',str(out/'publication-test'),*libs,'-L/usr/local/cuda-13.4/targets/x86_64-linux/lib/stubs','-L/usr/local/cuda-13.4/targets/x86_64-linux/lib']
(out/'publication-test-commands.json').write_text(json.dumps([cmd,link],indent=2)+'\n')
with (out/'publication-test-build.log').open('w') as log:
 subprocess.run(cmd,cwd=build,stdout=log,stderr=subprocess.STDOUT,check=True);subprocess.run(link,cwd=build,stdout=log,stderr=subprocess.STDOUT,check=True)
