#!/usr/bin/env python3
"""Compare identical work in plain/IF/WHILE CUDA graphs, with and without memcheck."""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--nvcc', default='nvcc')
    parser.add_argument('--sanitizer', default='compute-sanitizer')
    parser.add_argument('--architecture', default='sm_89')
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    source = Path(__file__).with_name('repro.cu').resolve()
    nvcc, sanitizer = (shutil.which(p) for p in (args.nvcc, args.sanitizer))
    if not nvcc or not sanitizer:
        parser.error('nvcc and compute-sanitizer must both be available')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    binary = output / 'repro'
    manifest = {
        'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
        'nvcc_version': subprocess.check_output([nvcc, '--version'], text=True),
        'sanitizer_version': subprocess.check_output([sanitizer, '--version'], text=True),
        'gpu': subprocess.check_output(['nvidia-smi', '--query-gpu=name,driver_version',
                                        '--format=csv,noheader'], text=True),
        'commands': [],
    }
    shutil.copyfile(source, output / 'repro.cu')

    def run(command, log):
        with (output / log).open('w') as stream:
            result = subprocess.run(command, stdout=stream, stderr=subprocess.STDOUT)
        entry = {'command': command, 'exit_code': result.returncode, 'log': log}
        manifest['commands'].append(entry)
        (output / 'results.json').write_text(json.dumps(manifest, indent=2) + '\n')
        print(json.dumps(entry), flush=True)
        return result.returncode

    build = run([nvcc, '-std=c++17', '-arch=' + args.architecture, '-lineinfo',
                 str(source), '-o', str(binary)], 'build.log')
    if build:
        return 1
    failed = False
    for mode in ('plain', 'if', 'while'):
        failed |= run([str(binary), mode], mode + '-normal.log') != 0
        failed |= run([sanitizer, '--tool', 'memcheck', '--error-exitcode', '99',
                       '--print-limit', '3', str(binary), mode], mode + '-memcheck.log') != 0
    # An instrumented failure stays a failed diagnostic. Never turn it into a
    # passing solver test, disable production conditional graphs, or omit a mode.
    return 1 if failed else 0


if __name__ == '__main__':
    sys.exit(main())
