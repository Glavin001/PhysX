#!/usr/bin/env python3
"""Serial fresh-prefix semantic measurements. No snapshot-restore or speedup claim.

Discovery freezes event indices from reference A before any candidate runs.
Confirmation requires --selection from discovery, an independently fixed repeat
count, and alternates balanced randomized AB/BA pairs within each fixture.
"""
import argparse
import csv
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import random
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('capture', ROOT/'tools/scripts/run-destruction-timing.py')
capture = importlib.util.module_from_spec(spec)
spec.loader.exec_module(capture)


def matches(row, predicates):
    for key, checks in predicates.items():
        value = int(row[key])
        for op, target in checks.items():
            if op not in ('eq', 'gt'):
                raise ValueError('Unknown predicate '+op)
            if not (value == target if op == 'eq' else value > target):
                return False
    return True


def select(rows, scenarios):
    selected = {}
    for case in scenarios:
        rule = case['selection']
        after = rule.get('after', -1)
        if 'after_scenario' in rule:
            if rule['after_scenario'] not in selected:
                selected[case['id']] = {'status': 'missing_dependency'}
                continue
            dependency = selected[rule['after_scenario']]
            if dependency['status'] != 'selected':
                selected[case['id']] = {'status': 'missing_dependency'}
                continue
            after = dependency['step']
        eligible = [r for r in rows if int(r['step']) > after and
                    ('step' not in rule or int(r['step']) == rule['step']) and matches(r, rule['where'])]
        selected[case['id']] = ({'status': 'selected', 'step': int(eligible[0]['step'])}
                               if eligible else {'status': 'predicate_not_observed'})
    return selected


def launch(arm, fixture, config, destination, graphics, compute, phases=False):
    destination.mkdir()
    cmd = [str(arm/'native_destruction_demo'), *config['common'], *fixture['args'],
           '--seconds', str(fixture['seconds']), '--steps', str(fixture['steps']),
           '--profile-phases', str(int(phases)), '--profile-gpu', '0', '--output', str(destination/'scene')]
    record = {'command': cmd, 'arm_directory': str(arm), 'samples': [], 'status': 'running'}
    def save():
        (destination/'run.json').write_text(json.dumps(record, indent=2)+'\n')
    before = capture.gpu()
    record['samples'].append(before)
    if capture.competing_processes(before, graphics, compute):
        raise RuntimeError('Foreign GPU process; no service was stopped')
    save()
    start = time.monotonic()
    with (destination/'stdout.log').open('w') as log:
        process = subprocess.Popen(cmd, cwd=ROOT, env=dict(os.environ, LD_LIBRARY_PATH=str(arm)),
                                   stdout=log, stderr=subprocess.STDOUT)
        try:
            while process.poll() is None:
                sample = capture.gpu()
                record['samples'].append(sample)
                observed = capture.competing_processes(sample, graphics, compute)
                if len(observed) > 1:
                    raise RuntimeError('Multiple unlisted GPU processes')
                if observed:
                    if record.get('gpu_pid', observed[0]['pid']) != observed[0]['pid']:
                        raise RuntimeError('GPU identity changed')
                    record['gpu_pid'] = observed[0]['pid']
                maps = Path(f'/proc/{process.pid}/maps')
                if 'modules' not in record and maps.exists():
                    content = maps.read_text()
                    names = ('libPhysXDestructionGpuRuntime_64.so', 'libPhysXGpuActivity_64.so')
                    if all(n in content for n in names):
                        (destination/'process.maps').write_text(content)
                        paths = {line.split()[-1] for line in content.splitlines() if '/' in line}
                        record['modules'] = {n: str(arm/n) for n in names if str(arm/n) in paths}
                        if len(record['modules']) != len(names):
                            raise RuntimeError('Unexpected loaded runtime')
                if time.monotonic()-start > 600:
                    raise RuntimeError('Owned process exceeded watchdog')
                time.sleep(.2)
            record['exit_code'] = process.returncode
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=30)
            record['process_wall_ms'] = 1000*(time.monotonic()-start)
            record['samples'].append(capture.gpu())
            record['status'] = 'complete' if process.returncode == 0 else 'failed'
            save()
    if record['exit_code'] or 'modules' not in record:
        raise RuntimeError('Simulation failed or missing module attestation: '+str(destination))
    if capture.competing_processes(record['samples'][-1], graphics, compute):
        raise RuntimeError('Unlisted GPU process after run')
    record['module_sha256'] = {n: capture.sha(Path(p)) for n,p in record['modules'].items()}
    frames = destination/'scene/native.frames.csv'
    rows = list(csv.DictReader(frames.open()))
    if [int(r['step']) for r in rows] != list(range(fixture['steps'])):
        raise RuntimeError('Missing/duplicate frames')
    for row in rows:
        if int(row['stress_converged']) != 1 or int(row['resim_passes']) > 1 or int(row['stress_passes']) != 1+int(row['resim_passes']):
            raise RuntimeError('Convergence/correction/evaluation violation')
    record['frames_sha256'] = capture.sha(frames)
    record['summary'] = json.loads((destination/'scene/native.summary.json').read_text())
    if not record['summary']['sleeping'] or record['summary']['direct_gpu_mode']:
        raise RuntimeError('Wrong API/sleeping settings')
    capture.compress_csv(destination/'scene')
    save()
    return rows, record


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--baseline', required=True, type=Path)
    parser.add_argument('--candidate', type=Path)
    parser.add_argument('--config', type=Path, default=ROOT/'tools/profiles/destruction-semantic-suite.json')
    parser.add_argument('--selection', type=Path)
    parser.add_argument('--repeats', type=int, default=10)
    parser.add_argument('--fixture', action='append')
    parser.add_argument('--seed', type=int, default=11092026)
    parser.add_argument('--phase-scopes', action='store_true', help='Separate diagnostic campaign; not acceptance times')
    parser.add_argument('--allow-existing-graphics', action='store_true')
    parser.add_argument('--allow-compute-pid', type=int, action='append', default=[])
    args = parser.parse_args()
    if args.repeats < 1 or args.repeats > 100:
        parser.error('Require 1..100 independent repetitions')
    if args.candidate and (not args.selection or args.repeats < 10 or args.repeats % 2):
        parser.error('Comparison requires frozen selection and an even fixed count >=10 pairs')
    config = json.loads(args.config.read_text())
    fixtures = [f for f in config['fixtures'] if not args.fixture or f['id'] in args.fixture]
    if not fixtures or (args.fixture and set(args.fixture)-{f['id'] for f in fixtures}):
        parser.error('Unknown/empty fixture selection')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    arms = {'A': args.baseline.resolve()}
    if args.candidate:
        arms['B'] = args.candidate.resolve()
    artifacts = {a: {str(p): capture.sha(p) for p in [d/'native_destruction_demo', *sorted(d.glob('*.so'))]} for a,d in arms.items()}
    selection = json.loads(args.selection.read_text()) if args.selection else {'config_sha256': capture.sha(args.config), 'scenarios': {}}
    if selection['config_sha256'] != capture.sha(args.config):
        raise ValueError('Selection/config mismatch')
    receipt = {'schema': 1, 'scope': config['scope'], 'status': 'running', 'config': config,
               'config_sha256': capture.sha(args.config), 'artifacts': artifacts,
               'repeats': args.repeats, 'seed': args.seed, 'runs': [], 'phase_scopes': args.phase_scopes,
               'input_restore_qualified': False, 'selection_supplied': bool(args.selection),
               'inference': 'Fixed-prefix repeatability only; independent physical quality gates still required'}
    def save():
        (output/'campaign.json').write_text(json.dumps(receipt, indent=2)+'\n')
        (output/'selection.json').write_text(json.dumps(selection, indent=2)+'\n')
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        initial = capture.gpu()
        graphics = [p for g in initial['devices'] for p in g['processes'] if args.allow_existing_graphics and p['type']=='G']
        compute = [p for g in initial['devices'] for p in g['processes'] if p['pid'] in args.allow_compute_pid and p['type']!='G']
        receipt.update(initial_gpu=initial, allowed_graphics=graphics, allowed_compute=compute,
                       shared_gpu=bool(graphics or compute), runner_sha256=capture.sha(Path(__file__)))
        rng = random.Random(args.seed)
        orders = {f['id']: [['A','B'],['B','A']]*(args.repeats//2) for f in fixtures}
        for value in orders.values():
            rng.shuffle(value)
        try:
            # Warmup is a separate discarded process, never an excluded tick.
            for fixture in fixtures:
                for arm in arms:
                    print('WARMUP', fixture['id'], arm, flush=True)
                    launch(arms[arm], fixture, config, output/f'warmup-{fixture["id"]}-{arm}', graphics, compute, args.phase_scopes)
            for repeat in range(args.repeats):
                sequence = fixtures[:]
                rng.shuffle(sequence)
                for fixture in sequence:
                    for arm in orders[fixture['id']][repeat] if args.candidate else ['A']:
                        name = f'{repeat:03}-{fixture["id"]}-{arm}'
                        print('RUN', name, flush=True)
                        for path, digest in artifacts[arm].items():
                            if capture.sha(Path(path)) != digest:
                                raise RuntimeError('Artifact changed')
                        rows, record = launch(arms[arm], fixture, config, output/name, graphics, compute, args.phase_scopes)
                        cases = [s for s in config['scenarios'] if s['fixture']==fixture['id']]
                        if not args.selection and repeat == 0:
                            selection['scenarios'].update(select(rows, cases))
                            selection.setdefault('reference_frames', {})[fixture['id']] = {'file': str(output/name/'scene/native.frames.csv.gz'), 'sha256':record['frames_sha256']}
                        selected_rows = {}
                        for case in cases:
                            chosen = selection['scenarios'].get(case['id'], {'status':'not_selected'})
                            if chosen['status'] == 'selected':
                                row = rows[chosen['step']]
                                selected_rows[case['id']] = {'predicate_pass': matches(row, case['selection']['where']), 'row': row}
                            else:
                                selected_rows[case['id']] = dict(chosen)
                        receipt['runs'].append({'name':name, 'fixture':fixture['id'], 'arm':arm, 'repeat':repeat,
                                                'selected':selected_rows, 'summary':record['summary'],
                                                'frames_sha256':record['frames_sha256']})
                        save()
            receipt['status']='complete'
        except BaseException as error:
            receipt.update(status='failed', error=str(error))
            raise
        finally:
            save()
    return 0


if __name__ == '__main__':
    sys.exit(main())
