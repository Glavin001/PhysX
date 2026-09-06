#!/usr/bin/env python3
"""Build this checkout's PhysX GPU engine and destruction reference targets."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[2]
TARGETS = ['PhysX', 'PhysXCommon', 'PhysXFoundation', 'PhysXExtensions',
           'PhysXPvdSDK', 'PhysXCooking', 'PhysXCharacterKinematic', 'PhysXVehicle',
           'PhysXCudaContextManager', 'PhysXGpu', 'PVDRuntime']


def run(*args):
    subprocess.run(list(map(str, args)), cwd=ROOT, check=True)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--jobs', type=int, default=8)
    parser.add_argument('--cuda', default='/usr/local/cuda/bin/nvcc')
    parser.add_argument('--cuda-architectures', default='89', help='CMake CUDA architecture list; RTX 4090 is 89')
    parser.add_argument('--cc', default='clang')
    parser.add_argument('--cxx', default='clang++')
    parser.add_argument('--test', action='store_true')
    args = parser.parse_args()
    if args.jobs < 1:
        parser.error('--jobs must be positive')
    for compiler in (args.cuda, args.cc, args.cxx):
        if not shutil.which(compiler):
            parser.error(f'Required compiler unavailable: {compiler}')
    sdk, out = ROOT / 'physx', ROOT / 'out'
    run('cmake', '-S', sdk / 'compiler/public', '-B', out / 'sdk-release',
        '-DCMAKE_BUILD_TYPE=release', f'-DCMAKE_C_COMPILER={args.cc}',
        f'-DCMAKE_CXX_COMPILER={args.cxx}', f'-DCMAKE_CUDA_COMPILER={args.cuda}',
        f'-DPHYSX_ROOT_DIR={sdk}', f'-DPX_OUTPUT_LIB_DIR={sdk}', f'-DPX_OUTPUT_BIN_DIR={sdk}',
        f'-DCMAKE_INSTALL_PREFIX={out / "install"}', '-DTARGET_BUILD_PLATFORM=linux',
        '-DNV_FORCE_64BIT_SUFFIX=TRUE', '-DPX_OUTPUT_ARCH=x86', '-DPX_GENERATE_STATIC_LIBRARIES=TRUE',
        '-DPX_GENERATE_GPU_PROJECTS=TRUE', f'-DPX_DESTRUCTION_CUDA_ARCHITECTURES={args.cuda_architectures}', '-DPX_BUILDPVDRUNTIME=TRUE', '-DPX_BUILDSNIPPETS=FALSE')
    run('cmake', '--build', out / 'sdk-release', '--target', *TARGETS, f'-j{args.jobs}')
    run('cmake', '-S', ROOT / 'destruction', '-B', out / 'destruction-sdk',
        '-DCMAKE_BUILD_TYPE=Release', f'-DCMAKE_CXX_COMPILER={args.cxx}',
        f'-DCMAKE_CUDA_COMPILER={args.cuda}', f'-DPHYSX_ROOT={sdk}',
        '-DBLAST_ENABLE_CUDA_STRESS=ON', f'-DCMAKE_CUDA_ARCHITECTURES={args.cuda_architectures}',
        f'-DCMAKE_INSTALL_PREFIX={out / "install"}')
    run('cmake', '--build', out / 'destruction-sdk', f'-j{args.jobs}')
    run('cmake', '--install', out / 'destruction-sdk')
    lib = sdk / 'bin/linux.x86_64/release'
    names = ['libPhysXDestructionGpuRuntime_64.so', 'libPhysXGpuActivity_64.so', 'libPVDRuntime_64.so'] + [
        f'lib{target}_static_64.a' for target in TARGETS if target not in ('PhysXGpu', 'PVDRuntime')]
    manifest = {'source_revision': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip(),
                'libraries': {name: hashlib.sha256((lib / name).read_bytes()).hexdigest() for name in names}}
    # HEAD alone does not identify this uncommitted SDK. Record the exact
    # source content and compiler versions that produced the artifacts.
    files = subprocess.check_output(['git','ls-files','--cached','--others','--exclude-standard','-z'],
        cwd=ROOT).decode().split('\0')
    source_hashes = {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                     for name in sorted(set(files)-{''}) if (ROOT / name).is_file()}
    manifest['source_content_sha256'] = hashlib.sha256(
        json.dumps(source_hashes,sort_keys=True).encode()).hexdigest()
    manifest['source_files'] = source_hashes
    manifest['cuda_architectures'] = args.cuda_architectures
    manifest['compilers'] = {compiler: subprocess.check_output([compiler,'--version'],text=True)
                             for compiler in (args.cuda,args.cc,args.cxx)}
    (out / 'sdk-artifacts.json').write_text(json.dumps(manifest, indent=2) + '\n')
    if args.test:
        run('ctest', '--test-dir', out / 'destruction-sdk', '--output-on-failure')


if __name__ == '__main__':
    main()
