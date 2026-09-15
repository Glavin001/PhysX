#!/usr/bin/env python3
"""Record plain/attached conditional graph controls without changing the SDK."""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import signal
import subprocess
import time


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--nvcc', default='/usr/local/cuda-13.4/bin/nvcc')
    parser.add_argument('--ncu', default='/usr/local/cuda-13.4/bin/ncu')
    parser.add_argument('--sanitizer', default='/usr/local/cuda-13.4/bin/compute-sanitizer')
    parser.add_argument('--host-compiler', default='/usr/bin/g++-12')
    parser.add_argument('--architecture', default='sm_120')
    parser.add_argument('--repeats', type=int, default=2)
    parser.add_argument('--timeout', type=float, default=60)
    args = parser.parse_args()
    if args.repeats < 1 or args.timeout <= 0:
        parser.error('repeats and timeout must be positive')
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    source = Path(__file__).with_name('repro.cu')
    shutil.copy2(source, out / 'repro.cu')
    binary = out / 'repro'
    receipt = dict(source_sha256=sha(source), runs=[])

    def record(name, command):
        entry = dict(name=name, command=[str(x) for x in command], maps=[])
        started = time.monotonic()
        maps = {}
        with (out / (name + '.log')).open('w') as log:
            process = subprocess.Popen(entry['command'], stdout=log, stderr=subprocess.STDOUT,
                                       start_new_session=True)
            entry['pid'] = process.pid
            while process.poll() is None:
                for candidate in Path('/proc').glob('[0-9]*'):
                    try:
                        if candidate.joinpath('exe').resolve() != binary:
                            continue
                        data = candidate.joinpath('maps').read_text()
                        if 'libcuda.so' in data:
                            maps[candidate.name] = data
                    except (OSError, RuntimeError):
                        pass
                if time.monotonic() - started > args.timeout:
                    entry['timed_out'] = True
                    # Only this invocation and its profiler-launched child.
                    try:
                        os.killpg(process.pid, signal.SIGKILL)
                    except ProcessLookupError:
                        pass
                    process.wait()
                    break
                time.sleep(.05)
            entry['exit_code'] = process.wait()
        modules = set()
        for pid, data in maps.items():
            name_map = f'{name}-{pid}.maps'
            (out / name_map).write_text(data)
            entry['maps'].append(name_map)
            for line in data.splitlines():
                path = line.split()[-1]
                if path.startswith('/') and Path(path).is_file():
                    modules.add(path)
        entry['loaded_modules'] = {p: sha(p) for p in sorted(modules)}
        entry['wall_seconds'] = time.monotonic() - started
        receipt['runs'].append(entry)
        (out / 'results.json').write_text(json.dumps(receipt, indent=2) + '\n')
        print(name, entry['exit_code'], flush=True)
        return entry['exit_code']

    for name, command in [('nvcc-version', [args.nvcc, '--version']),
                          ('ncu-version', [args.ncu, '--version']),
                          ('gpu', ['nvidia-smi'])]:
        if record(name, command):
            return 2
    if record('build', [args.nvcc, '-std=c++17', '-arch=' + args.architecture,
                        '-O3', '-lineinfo', '-ccbin', args.host_compiler,
                        out / 'repro.cu', '-lcuda', '-o', binary]):
        return 2
    receipt['binary_sha256'] = sha(binary)
    failed = 0
    for repeat in range(args.repeats):
        for mode in ['same', 'cross', 'instantiate-worker', 'worker',
                     'upload-worker', 'reupload-worker']:
            for attached in [False, True]:
                prefix = [args.ncu, '--profile-from-start', 'off'] if attached else []
                label = 'attached' if attached else 'plain'
                failed += record(f'{mode}-{label}-{repeat}', [*prefix, binary, mode]) != 0
    failed += record('cross-memcheck', [args.sanitizer, '--tool', 'memcheck',
                                       '--error-exitcode', '99', binary, 'cross']) != 0
    receipt['failed_runs'] = failed
    receipt['note'] = 'Profiler collection is disabled. Nonzero numerical exits are retained as failures.'
    (out / 'results.json').write_text(json.dumps(receipt, indent=2) + '\n')
    return 1 if failed else 0


if __name__ == '__main__':
    raise SystemExit(main())
