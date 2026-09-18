#!/usr/bin/env python3
"""Fetch the pinned, qualified profiler SDK locally; do not modify system CUDA."""
import argparse,hashlib,json,subprocess,sys,tempfile,zipfile
from pathlib import Path
VERSION='13.2.86'
WHEEL='nvidia_cuda_cupti-13.2.86-py3-none-manylinux_2_25_x86_64.whl'
SHA256='8fa29f15dd8336181f961764d9d95236fc6b931dd0c8fcf8cd70aab0c310b586'
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path);args=p.parse_args()
    args.output.mkdir(parents=True,exist_ok=False)
    with tempfile.TemporaryDirectory(prefix='physx-cupti-download-') as tmp:
        subprocess.run([sys.executable,'-m','pip','download','--no-deps','--no-cache-dir','--only-binary=:all:',
                        '--dest',tmp,'nvidia-cuda-cupti=='+VERSION],check=True)
        wheel=Path(tmp)/WHEEL
        if hashlib.sha256(wheel.read_bytes()).hexdigest()!=SHA256:raise RuntimeError('Unexpected CUPTI package hash/platform')
        with zipfile.ZipFile(wheel) as package:
            for name in package.namelist():
                if name.startswith('nvidia/cu13/include/') or name=='nvidia/cu13/lib/libcupti.so.13':
                    relative=Path(name).relative_to('nvidia/cu13');destination=args.output/relative
                    if name.endswith('/'):destination.mkdir(parents=True,exist_ok=True)
                    else:destination.parent.mkdir(parents=True,exist_ok=True);destination.write_bytes(package.read(name))
                elif name.endswith('/licenses/License.txt'):(args.output/'LICENSE.txt').write_bytes(package.read(name))
    (args.output/'manifest.json').write_text(json.dumps({'package':'nvidia-cuda-cupti','version':VERSION,'wheel_sha256':SHA256,
       'files':{str(f.relative_to(args.output)):hashlib.sha256(f.read_bytes()).hexdigest() for f in sorted(args.output.rglob('*')) if f.is_file()}},indent=2)+'\n')
    print(f'-DNATIVE_GPU_CUPTI_ROOT={args.output.resolve()}')
if __name__=='__main__':main()
