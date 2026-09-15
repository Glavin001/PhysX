#!/usr/bin/env python3
"""Build an isolated native profiler target; never replace the installed SDK."""
import argparse
import hashlib
import json
from pathlib import Path
import shlex
import subprocess


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--target', choices=['native_gpu_correction_body_test', 'native_destruction_demo'],
                        default='native_gpu_correction_body_test')
    args = parser.parse_args()
    root = Path(__file__).resolve().parents[3]
    build = root / 'out/destruction-sdk/reference'
    target = args.target
    cmake = build / f'CMakeFiles/{target}.dir'
    original = root / 'demos/blast-stress-demo/physx_scene.cpp'
    text = original.read_text()
    before, after = 'PxDefaultCpuDispatcherCreate(4)', 'PxDefaultCpuDispatcherCreate(0)'
    if text.count(before) != 1:
        raise RuntimeError('Native dispatcher setup changed; review the diagnostic against the current source.')
    flags = {}
    for line in (cmake / 'flags.make').read_text().splitlines():
        if ' = ' in line:
            key, value = line.split(' = ', 1)
            flags[key] = shlex.split(value)
    link = shlex.split((cmake / 'link.txt').read_text())
    # These generated files and objects must belong to the current SDK build.
    source_object = f'CMakeFiles/{target}.dir/physx_scene.cpp.o'
    if source_object not in link:
        raise RuntimeError('Native link recipe changed; no matching scene object.')
    out = args.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    source = out / 'physx_scene.cpp'
    source.write_text(text.replace(before, after))
    obj = out / 'physx_scene.o'
    binary = out / (target + '-ncu-inline')
    compile_command = ['/usr/bin/clang++', *flags['CXX_DEFINES'], *flags['CXX_INCLUDES'],
                       *flags['CXX_FLAGS'], '-I' + str(original.parent), '-c', str(source), '-o', str(obj)]
    link[link.index(source_object)] = str(obj)
    link[link.index('-o') + 1] = str(binary)
    with (out / 'build.log').open('w') as log:
        for command in [compile_command, link]:
            subprocess.run(command, cwd=build, stdout=log, stderr=subprocess.STDOUT, check=True)
    inputs = {}
    for item in link:
        path = Path(item)
        if not path.is_absolute():
            path = build / path
        if path.is_file() and path != binary:
            inputs[str(path)] = sha(path)
    receipt = dict(commands=[compile_command, link], cwd=str(build), cpu_dispatcher_workers=0,
                   production_cpu_dispatcher_workers=4, performance_qualification=False,
                   original_source=str(original), original_source_sha256=sha(original),
                   diagnostic_source_sha256=sha(source), binary=str(binary), binary_sha256=sha(binary),
                   link_inputs=inputs)
    (out / 'build.json').write_text(json.dumps(receipt, indent=2) + '\n')
    print(binary)


if __name__ == '__main__':
    main()
