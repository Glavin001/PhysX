#!/usr/bin/env python3
"""Build an isolated native load-capture runtime; never replace SDK artifacts."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess

root = Path(__file__).resolve().parents[3]
p = argparse.ArgumentParser(description=__doc__)
p.add_argument('destination', type=Path)
a = p.parse_args()
dst = a.destination.resolve()
dst.mkdir(parents=True, exist_ok=True)
source_dir = root / 'physx/source/gpudestruction/src'
original = source_dir / 'PxgDestructionRuntime.cu'
s = original.read_text()
s = '#include \"PxgDestructionElasticPartition.cuh\"\n' + s
header = Path(__file__).with_name('Capture.cuh').resolve()
s = s.replace('#include <vector>', '#include <vector>\n#include <fstream>\n#include <iomanip>\n#include <filesystem>\n#include <cstdlib>')
needle = '#include "PxgRigidIterationLimits.cuh"'
assert s.count(needle) == 1
s = s.replace(needle, '#include "' + str(header) + '"\n' + needle)
needle = '    if(i==PX_INVALID_U32)return;\n    const auto c=chunks[i];'
assert s.count(needle) == 1
s = s.replace(needle, '    recordLoadContact(i,point,impulse,invDt);\n' + needle)
needle = 'class Runtime final : public PxgDestructionRuntime {'
assert s.count(needle) == 1
s = s.replace(needle, needle + '\n    LoadCapture mLoadCapture;')
needle = '        Context current(mContext); cudaStreamSynchronize(mStream);clear();'
assert s.count(needle) == 1
s = s.replace(needle, '        Context current(mContext); cudaStreamSynchronize(mStream);mLoadCapture.clear();clear();')
needle = '    void clear() {\n        cudaEventSynchronize(mPreReady);cudaEventSynchronize(mReady);'
assert s.count(needle) == 1
s = s.replace(needle, needle + '\n        mLoadCapture.clear();')
needle = '            prepareLoads<<<(mN+127)/128,128,0,mStream>>>'
assert s.count(needle) == 1
s = s.replace(needle, '            mLoadCapture.begin(mStream);\n' + needle)
needle = '            check(cudaEventRecord(mReady,mStream));\n            stageMarker(1);'
assert s.count(needle) == 1
s = s.replace(needle, '''            if(mTopology)mLoadCapture.finish(mStream,dt,gravity,mPostCorrection,mStatus,mTopology->accepted(),
                mChunks,mClusters,mPoses,mAngular,mSurface,mInputs,mC,bodyStates,storage.capacity,
                mCheckpointValid?mCheckpointBodies:nullptr,mCheckpointValid?mCheckpointCount:0,
                mCheckpointGeneration,contacts.responseEpoch,inputRigidCheckpoint(),mCheckpointPurpose);
''' + needle)
source = dst / original.name
source.write_text(s)
build = root / 'out/sdk-release/sdk_gpu_source_bin/destruction-runtime'
flags = {}
for line in (build / 'CMakeFiles/PhysXDestructionGpuRuntime.dir/flags.make').read_text().splitlines():
    if ' = ' in line:
        k, v = line.split(' = ', 1)
        flags[k] = shlex.split(v)
obj = dst / 'runtime.o'
lib = dst / 'libPhysXDestructionGpuRuntime_64.so'
compile_command = ['/usr/local/cuda-13.4/bin/nvcc', *flags['CUDA_DEFINES'], *flags['CUDA_INCLUDES'],
                   *flags['CUDA_FLAGS'], '-ccbin', '/usr/bin/g++-12', '-I' + str(source_dir),
                   '-I' + str(root/'blast/source/sdk/extensions/stressgpu/detail'), '-c', str(source), '-o', str(obj)]
link = shlex.split((build / 'CMakeFiles/PhysXDestructionGpuRuntime.dir/link.txt').read_text())
original_obj = next(x for x in link if x.endswith('/PxgDestructionRuntime.cu.o'))
link[link.index(original_obj)] = str(obj)
link[link.index('-o') + 1] = str(lib)
for cmd in (compile_command, link):
    subprocess.run(cmd, cwd=build, check=True)
sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
inputs = {str(original): sha(original), str(source): sha(source), str(header): sha(header)}
for included in [header.with_name('CapturePartition.cuh'), source_dir/'PxgDestructionInputOwners.cuh', source_dir/'PxgDestructionElasticPartition.cuh', source_dir/'PxgDestructionElasticLoads.cuh', root/'physx/source/gpudestruction/include/PxgDestructionRuntime.h', root/'blast/source/sdk/extensions/stressgpu/detail/StressElasticOperator.cuh']:
    inputs[str(included)] = sha(included)
for arg in link:
    if arg.endswith(('.o', '.a')) and (build / arg).is_file():
        inputs[str((build / arg).resolve())] = sha(build / arg)
(dst / 'build.json').write_text(json.dumps(dict(commands=[compile_command, link], cwd=str(build),
    inputs_sha256=inputs, library_sha256=sha(lib)), indent=2) + '\n')
print(lib)
