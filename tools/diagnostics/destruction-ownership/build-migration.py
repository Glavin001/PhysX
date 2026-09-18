#!/usr/bin/env python3
"""Build an isolated ownership transaction without changing the selected SDK."""
import argparse
import fcntl
import hashlib
import json
import shlex
import shutil
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
BASE = ROOT / 'out/ownership-migration-20260915'
parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('name')
args = parser.parse_args()
out = BASE / args.name
out.mkdir(exist_ok=False)
tree = BASE / 'source'
prep = json.loads((BASE / 'transaction-preparation.json').read_text())
selected = ROOT / 'out/destruction-baseline-20260913/artifacts'
recipes = json.loads((ROOT / 'out/sdk-release/compile_commands.json').read_text())
sha = lambda p: hashlib.sha256(Path(p).read_bytes()).hexdigest()
record = dict(status='starting', preparation=prep, commands=[], inputs={}, dependencies={}, outputs={})

def save():
    (out / 'build.json').write_text(json.dumps(record, indent=2) + '\n')

def run(cmd, cwd, label):
    row = dict(argv=list(map(str, cmd)), cwd=str(cwd), label=label)
    record['commands'].append(row)
    save()
    start = time.monotonic()
    with (out / (label + '.log')).open('x') as log:
        result = subprocess.run(cmd, cwd=cwd, stdout=log, stderr=subprocess.STDOUT, timeout=300)
    row.update(seconds=time.monotonic()-start, exit_code=result.returncode)
    save()
    print(label, result.returncode, round(row['seconds'], 2), flush=True)
    result.check_returncode()

def compile_one(name):
    recipe = next(c for c in recipes if c['file'].endswith('/' + name))
    original = shlex.split(recipe['command'])
    original_obj = (Path(recipe['directory']) / original[original.index('-o') + 1]).resolve()
    cmd = [s.replace(str(ROOT/'physx'), str(tree/'physx')).replace(str(ROOT/'blast'), str(tree/'blast')) for s in original]
    obj = out / (name + '.o')
    dep = out / (name + '.d')
    cmd[cmd.index('-o') + 1] = str(obj)
    cmd += ['-MD', '-MF', str(dep)]
    run(cmd, recipe['directory'], name)
    for token in shlex.split(dep.read_text().replace('\\\n', ' ').split(':', 1)[1]):
        path = Path(token)
        if not path.is_absolute():
            path = Path(recipe['directory']) / path
        record['dependencies'][str(path)] = sha(path)
    return original_obj, obj

def capture_inputs(command, cwd):
    for token in command:
        p = Path(token)
        if not p.is_absolute():
            p = Path(cwd) / p
        if p.is_file():
            record['inputs'][str(p)] = sha(p)

with (ROOT / 'out/destruction-ab.lock').open('a') as lease:
    fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
    try:
        record['status'] = 'building'
        save()
        for name, digest in prep['changes'].items():
            assert sha(tree/name) == digest, name
        prior = json.loads((ROOT/'out/n24-component-multilevel-20260912/build/build.json').read_text())
        for item in prior['inputs'].values():
            assert sha(item['copy']) == item['sha256'], item['copy']
        _, runtime_obj = compile_one('PxgDestructionRuntime.cu')
        runtime_link = prior['commands'][1]['argv'].copy()
        runtime_cwd = prior['commands'][1]['cwd']
        runtime_link = [str(runtime_obj) if Path(s).name == 'PxgDestructionRuntime.cu.o' else s for s in runtime_link]
        runtime = out / 'libPhysXDestructionGpuRuntime_64.so'
        runtime_link[runtime_link.index('-o') + 1] = str(runtime)
        capture_inputs(runtime_link, runtime_cwd)
        run(runtime_link, runtime_cwd, 'runtime-link')
        old_obj, controller_obj = compile_one('PxgSimulationController.cpp')
        gpu_cwd = ROOT/'out/sdk-release/sdk_gpu_source_bin'
        gpu_link = shlex.split((gpu_cwd/'CMakeFiles/PhysXGpu.dir/link.txt').read_text())
        gpu_link = [s.replace('\\$ORIGIN', '$ORIGIN') for s in gpu_link]
        replaced = 0
        for i, token in enumerate(gpu_link):
            p = Path(token)
            if not p.is_absolute():
                p = gpu_cwd/p
            if p.resolve() == old_obj:
                gpu_link[i] = str(controller_obj)
                replaced += 1
            elif p.name == runtime.name:
                gpu_link[i] = str(runtime)
        assert replaced == 1, replaced
        gpu = out / 'libPhysXGpuActivity_64.so'
        gpu_link[gpu_link.index('-o') + 1] = str(gpu)
        capture_inputs(gpu_link, gpu_cwd)
        # These shared objects were independently relinked and compared with
        # the selected GPU module in E2. Recheck every reused input here.
        attested = json.loads((ROOT/'out/ownership-scheduling-20260915/sleep-build-v2/build.json').read_text())
        reused_gpu_inputs = 0
        for token in gpu_link:
            path = Path(token)
            if not path.is_absolute(): path = gpu_cwd/path
            if path.is_file() and path.suffix in ('.o', '.a', '.so') and path.parent != out:
                name = str(path)
                assert name in attested['inputs'], 'Unattested shared GPU input: '+name
                assert record['inputs'][name] == attested['inputs'][name], name
                reused_gpu_inputs += 1
        record['attested_reused_gpu_inputs'] = reused_gpu_inputs
        record['gpu_input_attestation'] = str(ROOT/'out/ownership-scheduling-20260915/sleep-build-v2/build.json')
        run(gpu_link, gpu_cwd, 'gpu-link')
        flags = ROOT/'out/destruction-sdk/reference/CMakeFiles/native_gpu_collision_test.dir/flags.make'
        values = dict(line.split(' = ', 1) for line in flags.read_text().splitlines() if ' = ' in line)
        test_source = tree/'demos/blast-stress-demo/tests/native_gpu_collision_test.cpp'
        test_obj = out/'native_gpu_collision_test.cpp.o'
        test_cmd = ['/usr/bin/clang++']
        for key in ['CXX_DEFINES', 'CXX_INCLUDES', 'CXX_FLAGS']:
            test_cmd += shlex.split(values[key].replace('\\"', '"'))
        test_cmd = [s.replace(str(ROOT/'physx'), str(tree/'physx')) for s in test_cmd]
        # Keep the fixture filename quoted as a C string after shell parsing.
        test_cmd = [s.split('=', 1)[0]+'="'+s.split('=', 1)[1].strip('"')+'"'
                    if s.startswith('-DNATIVE_KINEMATIC_REFERENCE_FILE=') else s for s in test_cmd]
        test_dep = out/'native_gpu_collision_test.cpp.d'
        test_cmd += ['-c', str(test_source), '-o', str(test_obj), '-MD', '-MF', str(test_dep)]
        run(test_cmd, ROOT, 'transaction-test-compile')
        scene_source = tree/'demos/blast-stress-demo/physx_scene.cpp'
        scene_obj = out/'physx_scene.cpp.o'
        scene_dep = out/'physx_scene.cpp.d'
        scene_cmd = [str(scene_source) if s == str(test_source) else str(scene_obj) if s == str(test_obj)
                     else str(scene_dep) if s == str(test_dep) else s for s in test_cmd]
        run(scene_cmd, ROOT, 'transaction-scene-compile')
        for token in shlex.split(scene_dep.read_text().replace('\\\n', ' ').split(':', 1)[1]):
            path = Path(token)
            if not path.is_absolute(): path = ROOT/path
            record['dependencies'][str(path)] = sha(path)
        for token in shlex.split(test_dep.read_text().replace('\\\n', ' ').split(':', 1)[1]):
            path = Path(token)
            if not path.is_absolute(): path = ROOT/path
            record['dependencies'][str(path)] = sha(path)
        old_tests = json.loads((ROOT/'out/n20-requalification-20260912/build/build.json').read_text())
        test_recipe = next(c for c in old_tests['commands'] if '-o' in c['argv']
            and c['argv'][c['argv'].index('-o')+1].endswith('/B/native_gpu_collision_test'))
        test_link = [str(test_obj) if Path(s).name == test_obj.name else str(scene_obj)
                     if Path(s).name == scene_obj.name else s for s in test_recipe['argv']]
        test_bin = out/'native_gpu_collision_test'
        test_link[test_link.index('-o')+1] = str(test_bin)
        capture_inputs(test_link, test_recipe['cwd'])
        run(test_link, test_recipe['cwd'], 'transaction-test-link')
        record['outputs'][str(test_bin)] = sha(test_bin)
        for path in (runtime, gpu):
            record['outputs'][str(path)] = sha(path)
        for name, digest in {**record['inputs'], **record['dependencies']}.items():
            assert sha(name) == digest, name
        for name, digest in prep['changes'].items():
            assert sha(tree/name) == digest, name
        for p in selected.glob('*.so'):
            record.setdefault('selected_unchanged', {})[str(p)] = sha(p)
        record['status'] = 'built_not_gpu_qualified'
    except BaseException as error:
        record.update(status='failed', error=repr(error))
        raise
    finally:
        save()
print(record['status'])
