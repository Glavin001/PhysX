#!/usr/bin/env python3
"""Serialize selected-control attribution; restore the temporarily stopped desktop."""
import argparse
import fcntl
import hashlib
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[1]
SCRIPTS = BASE / 'harness/tools/diagnostics/destruction-snapshot'
REPORT = ROOT / 'reports/destruction-baseline-20260913'

def write(path, data):
    temp = path.with_suffix(path.suffix + '.tmp')
    temp.write_text(json.dumps(data, indent=2) + '\n')
    temp.replace(path)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--through', choices=['cpu-light', 'graphs-light', 'cpu-full', 'warm', 'graphs-full', 'configs-light', 'configs-full'], default='configs-full')
    parser.add_argument('--resume', action='store_true')
    args = parser.parse_args()
    record_path = BASE / 'campaign.json'
    if record_path.exists() and not args.resume:
        raise RuntimeError('Existing campaign; inspect before explicitly resuming')
    previous = json.loads(record_path.read_text()) if record_path.exists() else {}
    if previous:
        write(BASE / ('campaign-before-resume-' + str(time.time_ns()) + '.json'), previous)
    record = dict(status='starting', pid=os.getpid(), source_commit='13b11af2e0aeabf4e0070931fbd8a060f383dfaf',
                  started_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                  completed_phases=previous.get('completed_phases', []), commands=previous.get('commands', []),
                  scope='Serialized analysis of frozen selected control; all new captures diagnostic, all old A0/A1 baseline samples preserved. No runtime optimization.')
    def save():
        write(record_path, record)
        write(REPORT / 'campaign-status.json', record)
    proc = None
    def terminate(signum, frame):
        raise RuntimeError('Coordinator interrupted by signal ' + str(signum))
    signal.signal(signal.SIGTERM, terminate)
    signal.signal(signal.SIGINT, terminate)
    lease = (ROOT / 'out/destruction-analysis.lock').open('a')
    fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
    # Wait for existing authorized work; never bypass or remove its lease.
    record['status'] = 'waiting_benchmark_lock'
    save()
    campaign_lock = (ROOT / 'out/destruction-ab.lock').open('a')
    fcntl.flock(campaign_lock, fcntl.LOCK_EX)
    active = subprocess.run(['systemctl', 'is-active', 'sddm'], capture_output=True, text=True)
    record['desktop_was_active'] = active.returncode == 0
    save()
    common = ['--manifest', str(BASE / 'manifest.json'), '--binary', str(BASE / 'profile/serialization-probe'), '--artifacts', str(BASE / 'artifacts')]
    light = [c['scenario'] for c in json.loads((BASE / 'harness/tools/profiles/destruction-snapshot-light.json').read_text())['scenarios']]
    py = sys.executable
    def cpu(preset):
        return [py, str(SCRIPTS / 'profile-cpu-suite.py'), str(BASE / 'cpu-full'), *common, '--preset', preset] + (['--resume'] if (BASE / 'cpu-full').exists() else [])
    def graph(light_only):
        return [py, str(SCRIPTS / 'profile-graph-suite.py'), str(BASE / 'graphs-full'), *common, '--timeline-campaign', str(BASE / 'timelines')] + (['--resume'] if (BASE / 'graphs-full').exists() else []) + (['--scenarios', *light] if light_only else [])
    def configs(light_only):
        return [py, str(SCRIPTS / 'profile-config-suite.py'), str(BASE / 'configs-full'), *common, '--timeline-campaign', str(BASE / 'timelines'), '--threshold-ms', '0.1', '--coverage', '0.99', '--ncu-replay', 'application', '--watchdog-seconds', '3600'] + (['--resume'] if (BASE / 'configs-full').exists() else []) + (['--scenarios', *light] if light_only else [])
    phases = [
        ('cpu-light', lambda: cpu('light')),
        ('graphs-light', lambda: graph(True)),
        ('cpu-full', lambda: cpu('full')),
        ('warm', lambda: [py, str(SCRIPTS / 'profile-warm-suite.py'), str(BASE / 'warm'), '--binary', str(BASE / 'native/native_destruction_demo'), '--artifacts', str(BASE / 'artifacts'), '--args-root', str(BASE / 'warm-args'), '--sampling-period', '10000000'] + (['--resume'] if (BASE / 'warm').exists() else [])),
        ('graphs-full', lambda: graph(False)),
        ('configs-light', lambda: configs(True)),
        ('configs-full', lambda: configs(False)),
    ]
    try:
        if record['desktop_was_active']:
            subprocess.run(['systemctl', 'stop', 'sddm'], check=True)
        # run-probe independently verifies ownership, health and loaded modules per run.
        with (BASE / ('environment-' + str(time.time_ns()) + '.txt')).open('x') as f:
            for cmd in [['nvidia-smi'], ['/opt/nvidia/nsight-systems/2026.3.2/bin/nsys', 'status', '--environment'], ['/opt/nvidia/nsight-compute/2025.3.1/ncu', '--version']]:
                f.write(json.dumps(cmd) + '\n'); f.flush()
                subprocess.run(cmd, stdout=f, stderr=subprocess.STDOUT, check=True)
        for name, recipe in phases:
            if name not in record['completed_phases']:
                command = recipe()
                log = BASE / (name + '-driver-' + str(time.time_ns()) + '.log')
                record.update(status='running', phase=name, log=str(log)); save()
                print('START', name, flush=True)
                started = time.monotonic()
                with log.open('x') as f:
                    proc = subprocess.Popen(command, cwd=ROOT, stdout=f, stderr=subprocess.STDOUT,
                                            env=dict(os.environ, PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1', PYTHONDONTWRITEBYTECODE='1', PHYSX_BASELINE_LOCK_OWNER=str(os.getpid())), start_new_session=True)
                    record['child_pid'] = proc.pid; save()
                    code = proc.wait()
                record['commands'].append(dict(phase=name, command=command, exit_code=code, elapsed_seconds=time.monotonic()-started, log=str(log)))
                record.pop('child_pid', None); save()
                if code:
                    raise RuntimeError(name + ' failed; original logs preserved')
                if name.startswith('cpu-'):
                    source = json.loads((BASE / 'cpu-full/campaign.json').read_text())
                    timeline = dict(status=source['status'], identity=source['identity'], scenarios=[dict(r, timeline=r['path']) for r in source['scenarios']])
                    (BASE / 'timelines').mkdir(exist_ok=True)
                    write(BASE / 'timelines/campaign.json', timeline)
                record['completed_phases'].append(name); save()
                print('DONE', name, flush=True)
            if name == args.through:
                break
        record['status'] = 'complete' if args.through == 'configs-full' else 'bounded_phases_complete'
    except BaseException as error:
        record.update(status='failed', error=repr(error))
        if proc is not None and proc.poll() is None:
            os.killpg(proc.pid, signal.SIGTERM)
            try: proc.wait(timeout=20)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL); proc.wait()
        raise
    finally:
        if record['desktop_was_active']:
            restored = subprocess.run(['systemctl', 'start', 'sddm'], capture_output=True, text=True)
            record['desktop_restore_exit_code'] = restored.returncode
        record['finished_utc'] = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
        save()
    if record.get('desktop_restore_exit_code', 0):
        raise RuntimeError('Desktop restoration failed; inspect service state')

if __name__ == '__main__':
    main()
