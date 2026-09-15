#!/usr/bin/env python3
"""Serial regression entrypoint. CPU, native, sanitizer and final are distinct gates.

Final adds matched full52, normal asynchronous memory checks for all52 and an
ordinary sleeping 600-tick wall. It never promotes a performance candidate.
"""
import argparse
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[2]
CPU_TESTS=[
 'tools/scripts/test-destruction-ab.py','tools/scripts/test-native-prefix.py',
 'tools/scripts/test-destruction-regression.py','tools/scripts/test-destruction-timing.py',
 'tools/scripts/test-destruction-semantic-suite.py','tools/scripts/test_report_native_publication.py',
 'tools/scripts/test-native-stress-solution-audit.py',
 'tools/diagnostics/destruction-snapshot/test-compare-observations.py',
 'tools/diagnostics/destruction-snapshot/test-matched.py','tools/diagnostics/destruction-snapshot/test-attribution.py']
NATIVE_CASES=[
 ('physical-outcomes','native_physics_contract_test',[]),
 ('independent-equilibrium','gpu_resident_stress_3d_test',[]),
 ('material-transactions','native_gpu_material_test',[]),
 ('same-tick-correction','native_gpu_resimulation_test',[]),
 ('sleep','native_standard_scene_test',[]),
 ('compound-sleep','native_standard_scene_test',['--compound-sleep']),
 ('wake-boundary','native_standard_scene_test',['--wake-boundary']),
 ('late-impact','native_standard_scene_test',['--late-impact']),
 ('post-correction','native_standard_scene_test',['--post-correction']),
 ('hierarchy-equations','gpu_resident_hierarchy_test',[]),
 ('hierarchy-cycle','gpu_resident_hierarchy_test',['--cycle'])]

def sha(path):return hashlib.sha256(Path(path).read_bytes()).hexdigest()

def validate_build(artifacts):
    receipt=json.loads((artifacts/'build.json').read_text())
    if receipt['status']!='built_not_gpu_qualified':raise ValueError('Incomplete consumer build')
    for path,digest in receipt['outputs'].items():
        if sha(path)!=digest:raise ValueError('Build artifact changed: '+path)
    required={exe for _,exe,_ in NATIVE_CASES}|{'libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so'}
    for name in required:
        path=artifacts/name
        if str(path.resolve()) not in receipt['outputs']:raise ValueError('Missing attested consumer: '+name)
    return receipt

def validate_full_manifest(path):
    data=json.loads(path.read_text());cases=data['scenarios']
    structural=json.loads((ROOT/'tools/profiles/destruction-snapshot-suite.json').read_text())['structural']
    city=json.loads((ROOT/'tools/profiles/destruction-snapshot-large.json').read_text())
    expected={c['scenario'] for c in structural}|{f"city{g*g}-{s['id']}" for g in city['grids'] for s in city['states']}
    if len(cases)!=52 or {c['scenario'] for c in cases}!=expected:raise ValueError('Final qualification requires all 52 unique scenarios')
    for case in cases:
        if not case.get('input_sha256'):raise ValueError('Missing snapshot input attestation')
        validate_snapshot_inputs(case)
        for name,digest in case['input_sha256'].items():
            if sha(name)!=digest:raise ValueError('Snapshot input changed: '+name)
    return cases

def validate_snapshot_inputs(case):
    prefix=str(Path(case['prefix']).resolve())
    actual={prefix+suffix for suffix in ('.pxbin','.destruction','.scene','.metadata.json')
            if Path(prefix+suffix).is_file()}
    attested={str(Path(name).resolve()) for name in case['input_sha256']}
    if not {prefix+'.pxbin',prefix+'.destruction'} <= actual or actual != attested:
        raise ValueError('Snapshot attestation must cover the actual replay prefix and sidecars')

def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output',type=Path)
    parser.add_argument('--tier',choices=['cpu','native','sanitizer','final','model-accuracy'],required=True)
    parser.add_argument('--artifacts',type=Path)
    parser.add_argument('--snapshot-manifest',type=Path)
    parser.add_argument('--snapshot-binary',type=Path)
    parser.add_argument('--control-artifacts',type=Path)
    parser.add_argument('--control-snapshot-binary',type=Path)
    parser.add_argument('--demo',type=Path)
    parser.add_argument('--wall-reference',type=Path)
    parser.add_argument('--candidate-commit')
    a=parser.parse_args()
    if a.tier!='cpu' and not a.artifacts:parser.error('--artifacts is required')
    if a.tier=='final' and not all((a.snapshot_manifest,a.snapshot_binary,a.control_artifacts,a.control_snapshot_binary,a.demo,a.wall_reference,a.candidate_commit)):
        parser.error('Final requires snapshot manifest/binaries, control artifacts, demo, wall reference and candidate commit')
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    artifacts=a.artifacts.resolve() if a.artifacts else None
    record=dict(schema=1,tier=a.tier,status='running',performance_qualification=False,runs=[],sources={})
    # Include imported comparators, not only executable command-line tokens.
    for path in [Path(__file__),ROOT/'tools/scripts/destruction_physics_contract.py',
                 ROOT/'tools/scripts/verify-native-prefix.py',
                 ROOT/'tools/diagnostics/destruction-snapshot/compare-observations.py']:
        record['sources'][str(path.resolve())]=sha(path)
    env=dict(os.environ,OPENBLAS_NUM_THREADS='1',PYTHONDONTWRITEBYTECODE='1')
    env.pop('PYTHONOPTIMIZE',None)
    env.pop('CUDA_LAUNCH_BLOCKING',None)
    record['environment']=dict(OPENBLAS_NUM_THREADS='1',PYTHONOPTIMIZE='unset',CUDA_LAUNCH_BLOCKING='unset',
                               strict_diagnostics=env.get('PHYSX_DESTRUCTION_STRICT_DIAGNOSTICS','unset'))
    env['PYTHONPATH']=str(ROOT/'out/elastic-precision-reference-20260910/python')
    if artifacts:env['LD_LIBRARY_PATH']=str(artifacts)+':'+env.get('LD_LIBRARY_PATH','')
    def save():(out/'results.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(name,command,gpu=False,own_lock=True,timeout=600):
        row=dict(name=name,command=[str(x) for x in command],status='running');record['runs'].append(row);save()
        for token in command:
            path=Path(token)
            if path.is_file():record['sources'][str(path.resolve())]=sha(path)
        start=time.monotonic()
        try:
            with (ROOT/'out/destruction-ab.lock').open('a') as lock:
                if gpu and own_lock and not suite_owns_lock:fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
                if artifacts:validate_build(artifacts)
                # Graphics clients may remain for correctness; foreign compute
                # must not overlap. GPU availability failure cannot pass a gate.
                if gpu:
                    clients=subprocess.check_output(['nvidia-smi','--query-compute-apps=pid','--format=csv,noheader'],text=True).strip()
                    if clients:raise RuntimeError('GPU has an existing compute client: '+clients)
                with (out/(name+'.log')).open('x') as log:
                    result=subprocess.run(row['command'],cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=timeout)
                row['exit_code']=result.returncode;result.check_returncode()
                if artifacts:validate_build(artifacts)
            row['status']='passed'
        except BaseException as error:row.update(status='failed',error=repr(error));raise
        finally:row['wall_seconds']=time.monotonic()-start;save()
    suite_lease=contextlib.ExitStack()
    suite_owns_lock=False
    try:
        if artifacts:record['build']=validate_build(artifacts)
        if a.tier=='final':
            # Refuse an incomplete final request before any expensive test.
            cases=validate_full_manifest(a.snapshot_manifest)
            for path in (a.snapshot_manifest,a.snapshot_binary,a.control_snapshot_binary,a.demo):
                record['sources'][str(path.resolve())]=sha(path)
        if a.tier in ('native','sanitizer','model-accuracy'):
            lock=suite_lease.enter_context((ROOT/'out/destruction-ab.lock').open('a'))
            fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
            suite_owns_lock=True
        if a.tier in ('cpu','final'):
            for test in CPU_TESTS:run(Path(test).stem,[sys.executable,ROOT/test])
        if a.tier!='cpu':
            if a.tier=='model-accuracy':
                run('unequal-chunk-mass',[artifacts/'native_physics_contract_test','--unequal-mass'],gpu=True)
            if a.tier in ('native','final'):
                for name,exe,options in NATIVE_CASES:run(name,[artifacts/exe,*options],gpu=True)
            if a.tier in ('sanitizer','final'):
                for tool in ('memcheck','initcheck','synccheck'):
                    run('physical-'+tool,['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','97',artifacts/'native_physics_contract_test'],gpu=True,timeout=1200)
            if a.tier=='final':
                snapshot=ROOT/'tools/diagnostics/destruction-snapshot'
                run('full52',[sys.executable,snapshot/'run-matched.py',out/'full52','--manifest',a.snapshot_manifest,
                    '--binary',a.control_snapshot_binary,'--candidate-binary',a.snapshot_binary,'--baseline-artifacts',a.control_artifacts,
                    '--candidate-artifacts',artifacts,'--candidate-commit',a.candidate_commit,'--allow-existing-graphics'],gpu=True,own_lock=False,timeout=14400)
                for case in cases:
                    command=[sys.executable,snapshot/'run-probe.py',out/('memory-'+case['scenario']),'--binary',a.snapshot_binary,
                        '--artifacts',artifacts,'--replay-prefix',case['prefix'],'--repetitions','2','--sanitizer','memcheck','--allow-existing-graphics']
                    if case.get('projectile_impulse'):command.append('--projectile-impulse')
                    run('memory-'+case['scenario'],command,gpu=True,own_lock=False,timeout=1200)
                run('wall',[sys.executable,ROOT/'tools/scripts/run-destruction-penetration-regression.py',out/'wall','--binary',a.demo,
                    '--expected-runtime',artifacts/'libPhysXDestructionGpuRuntime_64.so','--reference',a.wall_reference,
                    '--standard-scene','--sleeping','1','--tier','full'],gpu=True)
        for path,digest in record['sources'].items():
            if sha(path)!=digest:raise RuntimeError('Test source changed during execution: '+path)
        record['status']='passed'
    except BaseException as error:record.update(status='failed',error=repr(error));raise
    finally:
        suite_lease.close()
        save()
    print(out/'results.json')

if __name__=='__main__':main()
