#!/usr/bin/env python3
"""Exclusive changed-coefficient cuDSS probe; all commands and inputs saved."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('timing', ROOT/'tools/scripts/run-destruction-timing.py')
timing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(timing)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputs', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--refinement', action='store_true', help='FP32 factors with ten FP64 residual corrections')
    parser.add_argument('--selective', action='store_true', help='Refactor only changed coefficient matrices')
    parser.add_argument('--diagnostic-log', action='store_true', help='Library API diagnosis only; timings do not qualify')
    parser.add_argument('--wait-for-lease', type=float, default=0, help='Maximum seconds to wait for another authorized GPU job')
    args = parser.parse_args()
    if args.refinement and args.selective:
        parser.error('One coherent mechanism per experiment')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    inputs = args.inputs.resolve()
    manifest = json.loads((inputs/'report.json').read_text())
    library = ROOT/'.toolchains/cudss-0.8.0.10-cuda13/libcudss-linux-x86_64-0.8.0.10_cuda13-archive'
    frozen = output/'source'
    frozen.mkdir()
    for name in ['refactor.cu', 'refine.cu', 'selective.cu', 'PreparedOperator.cuh', 'run-refactor.py', 'prepare-refactor.py']:
        (frozen/name).write_bytes((HERE/name).read_bytes())
    binary = output/'probe'
    build = ['/usr/local/cuda-13.4/bin/nvcc','-std=c++17','-O3','-lineinfo','-arch=sm_120',
             '-I'+str(library/'include'),str(frozen/('refine.cu' if args.refinement else 'selective.cu' if args.selective else 'refactor.cu')),'-L'+str(library/'lib'),
             '-Xlinker=-rpath','-Xlinker='+str(library/'lib'),'-lcudss','-o',str(binary)]
    if args.diagnostic_log:
        build.insert(1,'-DPREPARED_LIBRARY_DIAGNOSTIC=1')
    command = [str(binary), str(inputs), str(manifest['rows']), str(manifest['nnz']), str(manifest['nrhs']), str(output)]
    if manifest.get('uniform_batch'):
        command.append(str(manifest['uniform_batch']))
    sha = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
    record = dict(status='building', build_command=build, command=command, diagnostic_only=args.diagnostic_log,
                  sources={str(path): sha(path) for path in frozen.iterdir()},
                  inputs={str(path): sha(path) for path in inputs.iterdir() if path.is_file()})
    def save():
        (output/'campaign.json').write_text(json.dumps(record, indent=2)+'\n')
    desktop = False
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        record['status'] = 'waiting_shared_lock'
        save()
        deadline = time.monotonic()+args.wait_for_lease
        while True:
            try:
                fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                if time.monotonic() >= deadline:
                    record.update(status='admission_failed', error='Shared GPU lease is owned by another job')
                    save()
                    raise
                time.sleep(.5)
        try:
            record['status'] = 'building'
            save()
            with (output/'build.log').open('x') as log:
                subprocess.run(build, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=180)
            record['binary_sha256'] = sha(binary)
            record['gpu_before'] = timing.gpu()
            desktop = subprocess.run(['systemctl', 'is-active', 'sddm'], capture_output=True).returncode == 0
            if desktop:
                subprocess.run(['systemctl', 'stop', 'sddm'], check=True)
            deadline = time.monotonic()+30
            while any(device['processes'] for device in timing.gpu()['devices']):
                if time.monotonic() > deadline:
                    raise RuntimeError('GPU admission timed out')
                time.sleep(.5)
            record['status'] = 'running'
            save()
            start = time.monotonic()
            with (output/'run.log').open('x') as log:
                subprocess.run(command, stdout=log, stderr=subprocess.STDOUT, check=True, timeout=90)
            record.update(status='complete_quality_pending', process_seconds=time.monotonic()-start)
        except BaseException as error:
            record.update(status='failed', error=repr(error))
            raise
        finally:
            if desktop:
                record['desktop_restore_exit_code'] = subprocess.run(['systemctl', 'start', 'sddm'], capture_output=True).returncode
            save()
    print(record['status'])


if __name__ == '__main__':
    main()
