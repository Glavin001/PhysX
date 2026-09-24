#!/usr/bin/env python3
"""Make an installed CuMetal destruction SDK self-contained and relocatable.

`cmake --install` copies the GPU module and destruction runtime with the build
tree's absolute rpaths, and without the libcumetal they load. This step:

* copies libcumetal.dylib into <prefix>/lib and CuMetal's clean-room CUDA
  headers into <prefix>/include/cumetal, so a consumer needs nothing else;
* replaces every absolute LC_RPATH in <prefix>/lib/*.dylib with @loader_path,
  so the libraries find each other wherever the prefix is moved;
* writes the consumer manifest (source revision and a sha256 per library),
  the same shape the Linux SDK build records;
* with --warm, builds a Metal pipeline for every kernel embedded in the
  installed GPU libraries and fails if any cannot be built. Metal enforces
  limits CUDA does not (32 KB of threadgroup memory, for one); a kernel over
  one fails at every launch, silently to the scene, and only this catches it
  before a consumer runs. The archive that step builds ships in
  <prefix>/lib/cumetal-pipeline-archive, where libcumetal looks beside itself,
  so a consumer's first run after an engine rebuild loads compiled pipelines
  instead of compiling them (17 s on the first city tick, measured) into
  whatever cache directory it happens to use. cumetal-warm also archives each
  kernel's indirect-command-buffer variant, which CuMetal builds for kernels
  in conditional graph bodies (10.7 s at destruction graph instantiation on a
  cache without them, measured), so those ship too.

Usage: relocate-macos-sdk.py PREFIX LIBCUMETAL CUMETAL_API_DIR MANIFEST
                             [--warm CUMETAL_WARM --gate-dir DIRECTORY]
"""
import argparse
import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import sys


def rpaths(library):
    output = subprocess.check_output(['otool', '-l', str(library)], text=True)
    found, lines = [], output.splitlines()
    for index, line in enumerate(lines):
        if line.strip() == 'cmd LC_RPATH':
            for following in lines[index + 1:index + 4]:
                parts = following.split()
                if parts and parts[0] == 'path':
                    found.append(parts[1])
    return found


def relocate(library):
    current = rpaths(library)
    arguments = []
    for path in current:
        if not path.startswith('@'):
            arguments += ['-delete_rpath', path]
    if '@loader_path' not in current:
        arguments += ['-add_rpath', '@loader_path']
    if arguments:
        subprocess.run(['install_name_tool', *arguments, str(library)], check=True)
        # Editing load commands invalidates the ad-hoc signature arm64 requires.
        subprocess.run(['codesign', '--force', '--sign', '-', str(library)], check=True)


def embedded_metallibs(library):
    """Every metallib CuMetal embedded in a library, named as the runtime names
    them when it materializes its native AOT cache (abi4-<fnv1a>.metallib)."""
    data = library.read_bytes()
    found, start = {}, 0
    while (start := data.find(b'MTLB', start)) >= 0:
        size = int.from_bytes(data[start + 16:start + 24], 'little') if start + 24 <= len(data) else 0
        if 24 < size <= len(data) - start:
            blob = data[start:start + size]
            digest = 1469598103934665603
            for byte in blob:
                digest = ((digest ^ byte) * 1099511628211) & 0xFFFFFFFFFFFFFFFF
            found[f'abi4-{digest:016x}.metallib'] = blob
            start += size
        else:
            start += 4
    return found


def pipeline_gate(lib, warm, gate):
    """Extract the shipped kernels and require a Metal pipeline for each."""
    metallibs = gate / 'native-aot'
    if metallibs.exists():
        shutil.rmtree(metallibs)
    metallibs.mkdir(parents=True)
    for name in ('libPhysXGpuActivity_64.dylib', 'libPhysXDestructionGpuRuntime_64.dylib'):
        for file, blob in embedded_metallibs(lib / name).items():
            (metallibs / file).write_bytes(blob)
    count = len(list(metallibs.iterdir()))
    if not count:
        raise SystemExit(f'No embedded metallibs found in {lib}; cannot check Metal pipelines')
    environment = dict(__import__('os').environ, CUMETAL_CACHE_DIR=str(gate))
    result = subprocess.run([str(warm), '--strict', str(metallibs)], env=environment,
                            capture_output=True, text=True)
    sys.stderr.write(result.stderr)
    summary = (result.stdout.strip().splitlines() or [''])[-1]
    if result.returncode:
        raise SystemExit(f'Metal pipeline gate failed for {count} metallibs; see skipped kernels above')
    print(f'Metal pipeline gate: {summary}')
    shipped = ship_pipeline_archive(lib, gate, metallibs)
    return {'metallibs': count, 'result': summary, 'shipped_archive': shipped}


def ship_pipeline_archive(lib, gate, metallibs):
    """Copy the gate's compiled pipelines for the shipped metallibs next to
    libcumetal. The gate's archive directory also holds earlier builds'
    kernels; only files named for a current metallib are copied. An archive
    is valid for the GPU and macOS build that compiled it (its name says
    which); elsewhere libcumetal ignores it and compiles as usual."""
    target = lib / 'cumetal-pipeline-archive'
    if target.exists():
        shutil.rmtree(target)
    target.mkdir()
    stems = {path.stem for path in metallibs.iterdir()}
    files = size = 0
    for path in sorted((gate / 'pipeline-archive').iterdir()):
        stem = path.name.split('-', 2)
        if '.pending.' in path.name or len(stem) < 3 or f'{stem[0]}-{stem[1]}' not in stems:
            continue
        shutil.copy2(path, target / path.name)
        files += 1
        size += path.stat().st_size
    print(f'Shipped {files} pipeline archive files ({size / 1e6:.1f} MB) in {target}')
    return {'files': files, 'bytes': size}


def main(argv):
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument('prefix', type=Path)
    parser.add_argument('cumetal', type=Path)
    parser.add_argument('api', type=Path)
    parser.add_argument('manifest', type=Path)
    parser.add_argument('--warm', type=Path, help='cumetal-warm executable; enables the pipeline gate')
    parser.add_argument('--gate-dir', type=Path, help='scratch directory for the gate\'s metallibs and archive')
    args = parser.parse_args(argv[1:])
    if bool(args.warm) != bool(args.gate_dir):
        parser.error('--warm and --gate-dir go together')
    prefix, cumetal, api, manifest = args.prefix, args.cumetal, args.api, args.manifest
    lib = prefix / 'lib'
    if not (lib / 'libPhysXGpuActivity_64.dylib').is_file():
        raise SystemExit(f'Not an installed CuMetal SDK: {lib}')
    shutil.copy2(cumetal, lib / cumetal.name)
    headers = prefix / 'include/cumetal'
    if headers.exists():
        shutil.rmtree(headers)
    shutil.copytree(api, headers)
    for library in sorted(lib.glob('*.dylib')):
        relocate(library)
    gate = pipeline_gate(lib, args.warm, args.gate_dir) if args.warm else None
    root = Path(__file__).resolve().parents[2]
    revision = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=root, text=True).strip()
    dirty = bool(subprocess.check_output(['git', 'status', '--porcelain', '--untracked-files=no'],
                                         cwd=root, text=True).strip())
    names = sorted(p.name for p in lib.iterdir() if p.suffix in ('.a', '.dylib') and p.is_file())
    record = {'source_revision': revision, 'source_dirty': dirty, 'backend': 'cumetal',
              'feature_profile': 'rigid-demo-experimental', 'install_prefix': str(prefix),
              'libraries': {name: hashlib.sha256((lib / name).read_bytes()).hexdigest() for name in names}}
    if gate:
        record['metal_pipeline_gate'] = gate
    manifest.write_text(json.dumps(record, indent=2) + '\n')
    print(f'Relocated {prefix}; manifest {manifest}')


if __name__ == '__main__':
    main(sys.argv)
