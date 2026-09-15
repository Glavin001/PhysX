#!/usr/bin/env python3
"""Measure the nine-case full-step protocol, including physical checks and profiles."""
import argparse
import csv
import fcntl
import hashlib
import importlib.util
import json
import math
import os
from pathlib import Path
import signal
import statistics as st
import subprocess
import sys
import time
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[3]
MODULES = ['libPhysXGpuActivity_64.so', 'libPhysXDestructionGpuRuntime_64.so']
WORK = ['bodies', 'awake_bodies', 'logical_clusters', 'contacts_frame',
        'stress_active_nodes', 'stress_active_bonds', 'stress_islands',
        'bonds_broken', 'resim_passes', 'stress_converged',
        'post_correction_bonds_broken', 'stress_passes']


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def write(path, data):
    path.with_suffix('.tmp').write_text(json.dumps(data, indent=2) + '\n')
    path.with_suffix('.tmp').replace(path)


def statistics(samples, continuous=False):
    values = [s['complete_step_ms'] for s in samples]
    stages = ['command_ms', 'physics_step_ms' if continuous else 'simulate_fetch_ms', 'completion_ms']
    if not all(math.isfinite(x) and x >= 0 for x in values):
        raise ValueError('Invalid tick time')
    for sample in samples:
        if abs(sample['complete_step_ms'] - sum(sample[k] for k in stages)) > 1e-5:
            raise ValueError('Complete-step partition mismatch')
    peak = values.index(max(values))
    return dict(n=len(values), mean_ms=st.mean(values), max_ms=max(values), min_ms=min(values),
                sd_ms=st.stdev(values), first_tick_ms=values[0],
                later_mean_ms=st.mean(values[1:]), peak_sample_index=peak,
                peak_sample=samples[peak], over_60hz=sum(x > 1000 / 60 for x in values),
                stages_ms={k: st.mean(s[k] for s in samples) for k in stages},
                restore_mean_ms=None if continuous else st.mean(s['restore_ms'] for s in samples))


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('output', type=Path)
    p.add_argument('--baseline', type=Path, required=True)
    p.add_argument('--core', type=Path, default=ROOT/'tools/profiles/destruction-experiment-core.json')
    p.add_argument('--native-binary', type=Path, required=True)
    p.add_argument('--profile-binary', type=Path, required=True)
    p.add_argument('--warm-args', type=Path, required=True)
    p.add_argument('--candidate-binary', type=Path)
    p.add_argument('--candidate-native-binary', type=Path)
    p.add_argument('--candidate-artifacts', type=Path)
    p.add_argument('--candidate-commit')
    p.add_argument('--target-seconds', type=float, default=300)
    p.add_argument('--watchdog-seconds', type=float, default=420)
    p.add_argument('--manage-desktop', action='store_true')
    a = p.parse_args()
    base = json.loads(a.baseline.read_text())
    core = json.loads(a.core.read_text())
    scripts = Path(base['matched_runner']).parent
    spec = importlib.util.spec_from_file_location('frozen_observations', scripts/'compare-observations.py')
    checker = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(checker)
    binaries = dict(A=Path(base['binary']), B=a.candidate_binary or Path(base['binary']))
    native = dict(A=a.native_binary, B=a.candidate_native_binary or a.native_binary)
    artifacts = dict(A=Path(base['artifacts']), B=a.candidate_artifacts or Path(base['artifacts']))
    for path, digest in base['files_sha256'].items():
        if sha(path) != digest:
            raise ValueError('Frozen baseline changed: ' + path)
    catalog = {c['scenario']: c for c in json.loads(Path(base['manifest']).with_name('manifest.json').read_text())['scenarios']}
    for c in core['snapshot_core']:
        for path, digest in catalog[c['scenario']]['input_sha256'].items():
            if sha(path) != digest:
                raise ValueError('Changed physical input: ' + path)
    out = a.output.resolve()
    out.mkdir(parents=True, exist_ok=False)
    identity = {arm: dict(binary_sha256=sha(binaries[arm]), native_sha256=sha(native[arm]),
                         modules={str((artifacts[arm]/n).resolve()): sha(artifacts[arm]/n) for n in MODULES})
                for arm in ['A', 'B']}
    same = (identity['A']['binary_sha256'] == identity['B']['binary_sha256'] and
            identity['A']['native_sha256'] == identity['B']['native_sha256'] and
            list(identity['A']['modules'].values()) == list(identity['B']['modules'].values()))
    record = dict(status='waiting_shared_gpu_lock', pid=os.getpid(), same_build_calibration=same,
                  target_seconds=a.target_seconds, watchdog_seconds=a.watchdog_seconds,
                  source_commit=base['source_commit'], candidate_commit=a.candidate_commit,
                  identity=identity, profile_binary_sha256=sha(a.profile_binary),
                  core_sha256=sha(a.core), runner_sha256=sha(__file__),
                  checker_sha256=sha(scripts/'compare-observations.py'),
                  commands=[], scenarios=[], phases_seconds={},
                  scope='Full-step latency; restore, initialization, checks, profiling and export excluded from ticks but included in total turnaround. Compilation and lock queue excluded. No runtime promotion.',
                  uncertainty='Process is the replicate. No tick-level significance interval; calibration differences are noise.')
    write(out/'core.json', core)
    queued = time.monotonic()
    started = None
    child = None
    desktop = False

    def save():
        if started is not None:
            record['elapsed_seconds'] = time.monotonic() - started
        write(out/'screen.json', record)

    def interrupted(signum, frame):
        raise RuntimeError('Interrupted ' + str(signum))

    signal.signal(signal.SIGTERM, interrupted)
    signal.signal(signal.SIGINT, interrupted)

    def execute(command, log):
        nonlocal child
        remaining = a.watchdog_seconds - (time.monotonic() - started)
        if remaining <= 0:
            raise subprocess.TimeoutExpired(command, a.watchdog_seconds)
        entry = dict(command=[str(x) for x in command], log=str(log), started_seconds=time.monotonic()-started)
        record['commands'].append(entry)
        save()
        t = time.monotonic()
        with log.open('x') as f:
            child = subprocess.Popen(entry['command'], stdout=f, stderr=subprocess.STDOUT,
                                     start_new_session=True, env=dict(os.environ,
                                     PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),
                                     PYTHONDONTWRITEBYTECODE='1', PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first'))
            code = child.wait(timeout=remaining)
        entry.update(seconds=time.monotonic()-t, exit_code=code)
        save()
        if code:
            raise RuntimeError('Command failed: ' + str(log))

    def verify_receipt(dest, arm, continuous=False):
        receipt = json.loads((dest/'receipt.json').read_text())
        expected = identity[arm]
        if (receipt['status'] != 'complete' or receipt['modules'] != expected['modules'] or
            receipt['binary_sha256'] != expected['native_sha256' if continuous else 'binary_sha256']):
            raise ValueError('Run provenance mismatch: ' + str(dest))

    def summarize(row):
        means = {k: v['mean_ms'] for k, v in row['runs'].items()}
        control = st.mean(v for k, v in means.items() if k.startswith('A'))
        candidate = st.mean(v for k, v in means.items() if k.startswith('B'))
        row.update(saved_ms=control-candidate, control_drift_ms=means['A1']-means['A0'],
                   decision='identical_build_noise' if same else 'screen_requires_independent_confirmation')
        if 'B1' in means:
            row['paired_saved_ms'] = [means['A0']-means['B0'], means['A1']-means['B1']]
        save()

    save()
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
        record['queue_seconds'] = time.monotonic()-queued
        try:
            started = time.monotonic()
            desktop = subprocess.run(['systemctl', 'is-active', 'sddm'], capture_output=True).returncode == 0
            if desktop and not a.manage_desktop:
                raise RuntimeError('Active desktop requires authorized --manage-desktop')
            if desktop:
                subprocess.run(['systemctl', 'stop', 'sddm'], check=True)
            # systemctl can return while the graphics session is still releasing CUDA handles.
            # Wait for actual device ownership; do not whitelist those transient clients.
            admission = time.monotonic()
            record['admission_samples'] = []
            while True:
                xml = ET.fromstring(subprocess.check_output(['nvidia-smi', '-q', '-x'], text=True))
                clients = [{k: node.findtext(k) for k in ['pid', 'type', 'process_name']}
                           for node in xml.findall('.//process_info')]
                record['admission_samples'].append(dict(seconds=time.monotonic()-admission, clients=clients))
                if not clients:
                    break
                if time.monotonic()-admission > 15:
                    raise RuntimeError('GPU clients did not release the device')
                time.sleep(0.25)
            record['status'] = 'running_snapshots'
            save()
            stage = time.monotonic()
            for c in core['snapshot_core']:
                case = catalog[c['scenario']]
                order = c['primary_order'] if c['scenario'] in core['default_primary'] else c['default_order']
                row = dict(scenario=c['scenario'], mode='restored', order=order, runs={}, raw={}, physical={})
                record['scenarios'].append(row)
                for slot in order:
                    arm = slot[0]
                    dest = out/(c['scenario']+'-'+slot)
                    command = [sys.executable, scripts/'run-probe.py', dest, '--binary', binaries[arm],
                               '--artifacts', artifacts[arm], '--replay-prefix', case['prefix'],
                               '--repetitions', str(c['repetitions_per_process']), '--watchdog-seconds', '90']
                    if case.get('projectile_impulse'):
                        command += ['--projectile-impulse']
                    execute(command, out/(dest.name+'.log'))
                    verify_receipt(dest, arm)
                    replay = json.loads((dest/'replay.json').read_text())
                    if not replay['passed'] or replay['repetitions'] != c['repetitions_per_process'] or replay['steps_per_restore'] != 1:
                        raise ValueError('Replay contract failed')
                    row['runs'][slot] = statistics(replay['samples'])
                    row['runs'][slot]['context_setup_ms'] = replay['context_setup_ms']
                    row['raw'][slot] = str(dest)
                    save()
                check_start = time.monotonic()
                for slot in order[1:]:
                    result = checker.compare(Path(row['raw']['A0']), Path(row['raw'][slot]))
                    if result['status'] != 'passed':
                        raise ValueError('Physical comparison failed')
                    write(out/(c['scenario']+'-physical-'+slot+'.json'), result)
                    row['physical'][slot] = 'passed'
                row['physical_check_seconds'] = time.monotonic()-check_start
                summarize(row)
            record['phases_seconds']['snapshots'] = time.monotonic()-stage
            record['status'] = 'running_continuous'
            save()
            stage = time.monotonic()
            for c in core['continuous_core']:
                name = c['scenario']
                args = json.loads((a.warm_args/(name+'-warm-args.json')).read_text())
                args[args.index('--profile-phases')+1] = '0'
                if float(args[args.index('--seconds')+1])*60 != c['steps_per_process']:
                    raise ValueError('Continuous tick count mismatch')
                argfile = out/(name+'-args.json')
                write(argfile, args)
                row = dict(scenario=name, mode='continuous', order=c['order'], runs={}, raw={}, physical={},
                           arguments_sha256=sha(argfile),
                           physical_scope='Exact per-frame work history and convergence; not full pose/force/energy trajectory proof')
                record['scenarios'].append(row)
                reference = None
                for slot in c['order']:
                    arm = slot[0]
                    dest = out/(name+'-'+slot)
                    execute([sys.executable, scripts/'run-probe.py', dest, '--binary', native[arm],
                             '--artifacts', artifacts[arm], '--native-args-json', argfile,
                             '--watchdog-seconds', '90'], out/(dest.name+'.log'))
                    verify_receipt(dest, arm, True)
                    summary = json.loads((dest/'native/native.summary.json').read_text())
                    graph = json.loads((dest/'native/native.graph-diagnostics.json').read_text())
                    with (dest/'native/native.frames.csv').open() as f:
                        frames = [{k: float(v) for k, v in s.items()} for s in csv.DictReader(f)]
                    if not (summary['status'] == 'completed' and summary['sleeping'] and
                            not summary['direct_gpu_mode'] and summary['correction_limit'] == 1 and
                            summary['frames'] == len(frames) == c['steps_per_process']):
                        raise ValueError('Native simulation contract failed')
                    if graph['boundary_audit_failures'] or graph['registry_mismatch_fallbacks']:
                        raise ValueError('Native graph failures')
                    if any(s['stress_converged'] != 1 or s['resim_passes'] > 1 or s['step'] != i for i, s in enumerate(frames)):
                        raise ValueError('Native convergence/correction failed')
                    history = [{k: s[k] for k in WORK} for s in frames]
                    if reference is None:
                        reference = history
                    if history != reference:
                        raise ValueError('Native physical-work history mismatch')
                    row['physical'][slot] = 'work_history_passed'
                    row['runs'][slot] = statistics(frames, True)
                    row['runs'][slot]['initialization_ms'] = summary['initialization_ms']
                    row['runs'][slot]['scale'] = {k: summary[k] for k in ['chunks', 'bonds', 'projectiles', 'buildings']}
                    row['raw'][slot] = str(dest)
                    save()
                summarize(row)
            record['phases_seconds']['continuous'] = time.monotonic()-stage
            record['status'] = 'running_systems'
            save()
            stage = time.monotonic()
            case = catalog['city256-late-debris']
            write(out/'profile-manifest.json', dict(scenarios=[case]))
            execute([sys.executable, scripts/'profile-cpu-suite.py', out/'systems', '--manifest',
                     out/'profile-manifest.json', '--binary', a.profile_binary, '--artifacts', artifacts['B']],
                    out/'systems-driver.log')
            campaign = json.loads((out/'systems/campaign.json').read_text())
            if campaign['status'] != 'complete':
                raise ValueError('Incomplete Systems attribution')
            record['systems'] = campaign
            record['phases_seconds']['systems'] = time.monotonic()-stage
            record['status'] = 'running_counters'
            save()
            stage = time.monotonic()
            dest = out/'ncu'
            metrics = 'gpu__time_duration.sum,launch__registers_per_thread,sm__warps_active.avg.pct_of_peak_sustained_active,smsp__issue_active.avg.pct_of_peak_sustained_active,dram__bytes.sum'
            execute([sys.executable, scripts/'run-probe.py', dest, '--binary', a.profile_binary,
                     '--artifacts', artifacts['B'], '--replay-prefix', case['prefix'], '--repetitions', '2',
                     '--profiler', 'ncu', '--ncu-kernel', 'regex:componentStressSolve', '--ncu-count', '2',
                     '--ncu-metrics', metrics, '--ncu-apply-rules', 'no', '--watchdog-seconds', '90'], out/'ncu-driver.log')
            execute(['/opt/nvidia/nsight-compute/2025.3.1/ncu', '--import', dest/'counters.ncu-rep',
                     '--page', 'raw', '--csv'], dest/'counters.csv')
            execute([sys.executable, scripts/'analyze-profile.py', dest, '--kind', 'counters'], dest/'analysis.log')
            counters = json.loads((dest/'analysis.json').read_text())
            if len(counters) != 2:
                raise ValueError('Expected two representative launches')
            for counter in counters:
                for metric in metrics.split(','):
                    value = counter['metrics'][metric]['value']
                    if not isinstance(value, (int, float)) or not math.isfinite(value):
                        raise ValueError('Invalid requested counter: ' + metric)
            physical = checker.compare(out/'city256-late-debris-B0', dest)
            write(dest/'physical-comparison.json', physical)
            if physical['status'] != 'passed':
                raise ValueError('Counter physical comparison failed')
            record['counters'] = dict(launches=len(counters), metrics=metrics.split(','), physical='passed',
                                    report_sha256=sha(dest/'counters.ncu-rep'))
            record['phases_seconds']['counters'] = time.monotonic()-stage
            record['status'] = 'complete'
        except subprocess.TimeoutExpired as error:
            record.update(status='watchdog_exceeded', error=str(error))
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
            record['wall_seconds_including_admission_restore_checks_reports'] = time.monotonic()-started
            record['target_met'] = record['status'] == 'complete' and record['wall_seconds_including_admission_restore_checks_reports'] <= a.target_seconds
            save()
    print(json.dumps({k: record.get(k) for k in ['status', 'error', 'target_met', 'phases_seconds', 'wall_seconds_including_admission_restore_checks_reports']}, indent=2))
    if record['status'] != 'complete':
        raise SystemExit(2)


if __name__ == '__main__':
    main()
