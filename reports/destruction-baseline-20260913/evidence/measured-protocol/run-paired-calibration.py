#!/usr/bin/env python3
"""Fixed-count randomized A/A process pairs to measure full-step decision precision."""
import argparse
import csv
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import random
import signal
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('screen', HERE/'run-representative-screen.py')
screen = importlib.util.module_from_spec(spec)
spec.loader.exec_module(screen)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('output', type=Path)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--native-binary', type=Path, required=True)
    p.add_argument('--warm-args', type=Path, required=True)
    p.add_argument('--scenario', action='append', required=True)
    p.add_argument('--pairs', type=int, default=6)
    p.add_argument('--seed', type=int, default=20260913)
    p.add_argument('--watchdog-seconds', type=float, default=420)
    p.add_argument('--manage-desktop', action='store_true')
    a = p.parse_args()
    if a.pairs < 4 or a.pairs % 2:
        p.error('Use an even, fixed number of pairs >= 4')
    base = json.loads(a.baseline.read_text())
    root = a.baseline.resolve().parent
    scripts = Path(base['matched_runner']).parent
    spec = importlib.util.spec_from_file_location('frozen_checker', scripts/'compare-observations.py')
    checker = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checker)
    core = json.loads((screen.ROOT/'tools/profiles/destruction-experiment-core.json').read_text())
    catalog = {x['scenario']: x for x in json.loads((root/'manifest.json').read_text())['scenarios']}
    cases = {x['scenario']: x for x in core['snapshot_core']+core['continuous_core']}
    for path, digest in base['files_sha256'].items():
        if screen.sha(path) != digest:
            raise ValueError('Frozen baseline changed')
    for name in a.scenario:
        if name not in cases:
            p.error('Unknown core case: ' + name)
        if name in catalog:
            for path, digest in catalog[name]['input_sha256'].items():
                if screen.sha(path) != digest:
                    raise ValueError('Changed snapshot input')
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    rng = random.Random(a.seed)
    orders = {}
    for name in a.scenario:
        order = [['A', 'B'] for _ in range(a.pairs//2)] + [['B', 'A'] for _ in range(a.pairs//2)]
        rng.shuffle(order)
        orders[name] = order
    record = dict(status='waiting_shared_gpu_lock', pid=os.getpid(), pairs=a.pairs, seed=a.seed,
                  order=orders, scenarios=[], commands=[], same_build_calibration=True,
                  binary_sha256=screen.sha(base['binary']), native_sha256=screen.sha(a.native_binary),
                  runner_sha256=screen.sha(__file__), checker_sha256=screen.sha(scripts/'compare-observations.py'),
                  modules={str((Path(base['artifacts'])/n).resolve()): screen.sha(Path(base['artifacts'])/n) for n in screen.MODULES},
                  stopping_rule='Fixed count selected before data collection. No significance-based early stopping.',
                  scope='Identical builds. Paired fresh-process means, all first ticks retained. Existing matching profiles reused; calibration is not an optimization gain.')
    records = {}
    for name in a.scenario:
        row = dict(scenario=name, pairs=[], mode='restored' if name in catalog else 'continuous')
        record['scenarios'].append(row)
        records[name] = row
    started = None
    child = None
    desktop = False
    queued = time.monotonic()

    def save():
        if started is not None:
            record['elapsed_seconds'] = time.monotonic()-started
        screen.write(out/'calibration.json', record)

    def interrupt(signum, frame):
        raise RuntimeError('Interrupted ' + str(signum))

    signal.signal(signal.SIGTERM, interrupt)
    signal.signal(signal.SIGINT, interrupt)

    def execute(command, dest):
        nonlocal child
        left = a.watchdog_seconds-(time.monotonic()-started)
        if left <= 0:
            raise subprocess.TimeoutExpired(command, a.watchdog_seconds)
        entry = dict(command=[str(x) for x in command], start_seconds=time.monotonic()-started)
        record['commands'].append(entry)
        save()
        t = time.monotonic()
        with (out/(dest.name+'.log')).open('x') as f:
            child = subprocess.Popen(entry['command'], stdout=f, stderr=subprocess.STDOUT, start_new_session=True,
                                     env=dict(os.environ, PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),
                                     PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first', PYTHONDONTWRITEBYTECODE='1'))
            code = child.wait(timeout=left)
        entry.update(seconds=time.monotonic()-t, exit_code=code)
        save()
        if code:
            raise RuntimeError('Run failed: ' + str(dest))

    save()
    with (screen.ROOT/'out/destruction-ab.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        record['queue_seconds'] = time.monotonic()-queued
        try:
            started = time.monotonic()
            desktop = subprocess.run(['systemctl', 'is-active', 'sddm'], capture_output=True).returncode == 0
            if desktop and not a.manage_desktop:
                raise RuntimeError('Need authorized desktop isolation')
            if desktop:
                subprocess.run(['systemctl', 'stop', 'sddm'], check=True)
            admission = time.monotonic()
            while ET.fromstring(subprocess.check_output(['nvidia-smi', '-q', '-x'], text=True)).findall('.//process_info'):
                if time.monotonic()-admission > 15:
                    raise RuntimeError('GPU still has clients')
                time.sleep(.25)
            record['status'] = 'running'
            save()
            # Interleave scenarios between pairs to expose drift throughout the campaign.
            for pair_index in range(a.pairs):
                for name in a.scenario:
                    pair = dict(index=pair_index, order=orders[name][pair_index], runs={}, raw={})
                    records[name]['pairs'].append(pair)
                    case = cases[name]
                    continuous = name not in catalog
                    for slot in pair['order']:
                        dest = out/f'{name}-{pair_index:02d}-{slot}'
                        binary = a.native_binary if continuous else Path(base['binary'])
                        command = [sys.executable, scripts/'run-probe.py', dest, '--binary', binary,
                                   '--artifacts', base['artifacts'], '--watchdog-seconds', '90']
                        if continuous:
                            args = json.loads((a.warm_args/(name+'-warm-args.json')).read_text())
                            args[args.index('--profile-phases')+1] = '0'
                            argfile = out/(name+'-args.json')
                            screen.write(argfile, args)
                            command += ['--native-args-json', argfile]
                        else:
                            command += ['--replay-prefix', catalog[name]['prefix'], '--repetitions', str(case['repetitions_per_process'])]
                            if catalog[name].get('projectile_impulse'):
                                command += ['--projectile-impulse']
                        execute(command, dest)
                        receipt = json.loads((dest/'receipt.json').read_text())
                        if receipt['status'] != 'complete' or receipt['modules'] != record['modules'] or receipt['binary_sha256'] != screen.sha(binary):
                            raise ValueError('Receipt/provenance failed')
                        if continuous:
                            summary = json.loads((dest/'native/native.summary.json').read_text())
                            with (dest/'native/native.frames.csv').open() as f:
                                samples = [{k: float(v) for k, v in x.items()} for x in csv.DictReader(f)]
                            if not (summary['status'] == 'completed' and summary['sleeping'] and not summary['direct_gpu_mode'] and
                                    summary['correction_limit'] == 1 and summary['frames'] == len(samples) == case['steps_per_process']):
                                raise ValueError('Continuous contract failed')
                            if any(x['stress_converged'] != 1 or x['resim_passes'] > 1 or x['step'] != i for i,x in enumerate(samples)):
                                raise ValueError('Continuous convergence failed')
                            graph = json.loads((dest/'native/native.graph-diagnostics.json').read_text())
                            if graph['boundary_audit_failures'] or graph['registry_mismatch_fallbacks']:
                                raise ValueError('Graph contract failed')
                            history = [{k: x[k] for k in screen.WORK} for x in samples]
                            if 'reference_history' not in records[name]:
                                records[name]['reference_history'] = history
                            if history != records[name]['reference_history']:
                                raise ValueError('Physical-work history changed')
                            pair['physical_scope'] = 'Exact work history/convergence; not full trajectory proof'
                        else:
                            replay = json.loads((dest/'replay.json').read_text())
                            if not replay['passed'] or replay['steps_per_restore'] != 1 or len(replay['samples']) != case['repetitions_per_process']:
                                raise ValueError('Replay failed')
                            samples = replay['samples']
                        pair['runs'][slot] = screen.statistics(samples, continuous)
                        pair['runs'][slot]['initialization_ms'] = summary['initialization_ms'] if continuous else replay['context_setup_ms']
                        pair['raw'][slot] = str(dest)
                        save()
                    t = time.monotonic()
                    if not continuous:
                        physical = checker.compare(Path(pair['raw']['A']), Path(pair['raw']['B']))
                        screen.write(out/f'{name}-{pair_index:02d}-physical.json', physical)
                        if physical['status'] != 'passed':
                            raise ValueError('Physical comparison failed')
                    pair.update(physical='passed', physical_check_seconds=time.monotonic()-t,
                                saved_ms=pair['runs']['A']['mean_ms']-pair['runs']['B']['mean_ms'])
                    save()
            record['status'] = 'complete'
        except BaseException as error:
            record.update(status='failed', error=repr(error))
        finally:
            if child is not None and child.poll() is None:
                os.killpg(child.pid, signal.SIGTERM)
                try:
                    child.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    os.killpg(child.pid, signal.SIGKILL)
                    child.wait()
            if desktop and a.manage_desktop:
                record['desktop_restore_exit_code'] = subprocess.run(['systemctl', 'start', 'sddm'], capture_output=True).returncode
            record['wall_seconds'] = time.monotonic()-started
            save()
    print(json.dumps({k:record.get(k) for k in ['status', 'error', 'wall_seconds']}, indent=2))
    if record['status'] != 'complete':
        raise SystemExit(2)


if __name__ == '__main__':
    main()
