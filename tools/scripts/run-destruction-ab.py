#!/usr/bin/env python3
"""Sequential A/B/A screens using the existing capture and comparison tools.

Exit 0: complete screen (not acceptance); 2: complete but deadlines/physical
comparison fail; 3: unavailable GPU; 1: invalid or incomplete evidence.
Every destination is new. No builds, installs, process eviction or auto-promotion.
"""
import argparse
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('timing_runner', ROOT/'tools/scripts/run-destruction-timing.py')
runner = importlib.util.module_from_spec(spec)
spec.loader.exec_module(runner)
MODULES = ('libPhysXDestructionGpuRuntime_64.so', 'libPhysXGpuActivity_64.so')


def artifacts(directory):
    required = [directory/'native_destruction_demo', *(directory/n for n in MODULES)]
    for path in required:
        if not path.is_file():
            raise ValueError(f'Missing isolated arm artifact: {path}')
    return {str(p): runner.sha(p) for p in sorted(set(required + list(directory.glob('*.so'))))}


def verify_campaign(campaign, directory, expected):
    if campaign['status'] != 'complete':
        raise ValueError('Incomplete campaign; no comparison allowed')
    for run in campaign['runs']:
        if run.get('exit_code') != 0:
            raise ValueError('Incomplete simulation: '+run['name'])
        loaded = run.get('loaded_modules', {})
        for name in MODULES:
            path = str(directory/name)
            if loaded.get(path) != expected[path]:
                raise ValueError(f'Wrong or missing mapped module in {run["name"]}: {path}')
    if artifacts(directory) != expected:
        raise ValueError('Arm artifacts changed during capture')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--baseline', type=Path, required=True, help='Isolated directory containing demo and modules')
    parser.add_argument('--candidate', type=Path, help='Omit for baseline verification only')
    parser.add_argument('--config', type=Path, default=ROOT/'tools/profiles/destruction-ordinary-ab.json')
    parser.add_argument('--correctness', type=Path, help='Candidate correctness receipt, retained without waiving failures')
    parser.add_argument('--hypothesis', help='One coherent mechanism; required with candidate')
    parser.add_argument('--trials', type=int, default=2)
    parser.add_argument('--seconds', type=int, default=3)
    parser.add_argument('--allow-existing-graphics', action='store_true')
    parser.add_argument('--allow-compute-pid', type=int, action='append', default=[], help='Explicitly authorized existing compute PID for shared-GPU diagnostics')
    args = parser.parse_args()
    if args.trials < 2 or args.seconds < 3:
        parser.error('At least two trials and three simulated seconds required')
    if args.candidate and not (args.correctness and args.hypothesis):
        parser.error('Candidate requires --correctness and --hypothesis')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    receipt = {'schema': 1, 'status': 'preparing', 'experiments_completed': 0,
               'hypothesis': args.hypothesis, 'runs': [], 'comparisons': [],
               'qualification': 'Diagnostic screen; independent fidelity gates remain required'}

    def save():
        temporary = output/'experiment.json.tmp'
        temporary.write_text(json.dumps(receipt, indent=2)+'\n')
        temporary.replace(output/'experiment.json')

    save()
    # Cooperating wrappers share this lock; the existing runner additionally
    # detects foreign compute before, during and after every simulation.
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            receipt['commit'] = subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=ROOT, text=True).strip()
            patch = output/'worktree.patch'
            patch.write_bytes(subprocess.check_output(['git', 'diff', 'HEAD', '--binary'], cwd=ROOT))
            receipt['worktree_patch_sha256'] = runner.sha(patch)
            names = subprocess.check_output(['git', 'ls-files', '--others', '--exclude-standard', '-z'], cwd=ROOT).decode().split('\0')
            receipt['untracked_files'] = {n: runner.sha(ROOT/n) for n in names if n and (ROOT/n).is_file() and not (ROOT/n).is_relative_to(output)}
            config = json.loads(args.config.read_text())
            if [c['id'] for c in config['cases']] != ['idle-256', 'impacts-256']:
                raise ValueError('Expected ordered pristine idle and impacts scenario suite')
            (output/'config.json').write_text(json.dumps(config, indent=2)+'\n')
            receipt['config_sha256'] = runner.sha(output/'config.json')
            if args.correctness:
                receipt['correctness'] = json.loads(args.correctness.read_text())
                receipt['correctness_sha256'] = runner.sha(args.correctness)
            arms = {'A': args.baseline.resolve()}
            if args.candidate:
                arms['B'] = args.candidate.resolve()
            receipt['artifacts'] = {arm: artifacts(path) for arm, path in arms.items()}
            receipt['initial_gpu'] = runner.gpu()
            allowed = [p for g in receipt['initial_gpu']['devices'] for p in g['processes']
                       if args.allow_existing_graphics and p['type'] == 'G']
            receipt['allowed_compute'] = [p for g in receipt['initial_gpu']['devices'] for p in g['processes'] if p['pid'] in args.allow_compute_pid and p['type'] != 'G']
            receipt['allow_compute_pids'] = args.allow_compute_pid
            receipt['isolated_performance_qualification'] = False if args.allow_compute_pid or args.allow_existing_graphics else None
            receipt['competing_processes'] = runner.competing_processes(receipt['initial_gpu'], allowed, receipt['allowed_compute'])
            if receipt['competing_processes']:
                receipt['status'] = 'blocked_gpu'; save()
                print('GPU unavailable; no simulation launched. See', output/'experiment.json')
                return 3
            deadline_failure = False
            stages = [('A-before', 'A')]
            if args.candidate:
                stages += [('B', 'B'), ('A-after', 'A')]
            for stage, arm in stages:
                for case in config['cases']:
                    directory = output/stage/case['id']
                    command = [sys.executable, str(ROOT/'tools/scripts/run-destruction-timing.py'), str(directory),
                               '--binary', str(arms[arm]/'native_destruction_demo'), '--config', str(output/'config.json'),
                               '--case', case['id'], '--trials', str(args.trials), '--seconds', str(args.seconds), '--gate-only']
                    if args.allow_existing_graphics:
                        command.append('--allow-existing-graphics')
                    for pid in args.allow_compute_pid:
                        command += ['--allow-compute-pid', str(pid)]
                    if artifacts(arms[arm]) != receipt['artifacts'][arm]:
                        raise ValueError('Arm changed before launch')
                    record = {'stage': stage, 'case': case['id'], 'command': command,
                              'LD_LIBRARY_PATH': str(arms[arm])}
                    receipt['runs'].append(record); receipt['status'] = 'running'; save()
                    env = dict(os.environ, LD_LIBRARY_PATH=str(arms[arm]))
                    with (output/f'{stage}-{case["id"]}.log').open('w') as log:
                        result = subprocess.run(command, cwd=ROOT, env=env, stdout=log, stderr=subprocess.STDOUT)
                    record['exit_code'] = result.returncode; save()
                    campaign = json.loads((directory/'campaign.json').read_text())
                    verify_campaign(campaign, arms[arm], receipt['artifacts'][arm])
                    if result.returncode not in (0, 2):
                        raise ValueError('Capture/report failed: '+str(directory))
                    record['report'] = str(directory/'report/report.json.gz')
                    record['report_sha256'] = runner.sha(Path(record['report']))
                    deadline_failure |= result.returncode == 2
                    save()
            if args.candidate:
                for stage in ('A-before', 'A-after'):
                    for case in config['cases']:
                        command = [sys.executable, str(ROOT/'tools/scripts/compare-destruction-candidates.py'),
                                   '--baseline', str(output/stage/case['id']/'report/report.json.gz'),
                                   '--candidate', str(output/'B'/case['id']/'report/report.json.gz'),
                                   '--output', str(output/'comparisons'/stage/case['id'])]
                        result = subprocess.run(command, cwd=ROOT)
                        receipt['comparisons'].append({'command': command, 'exit_code': result.returncode})
                        if result.returncode:
                            comparison = output/'comparisons'/stage/case['id']/'comparison.json'
                            if not comparison.is_file() or not json.loads(comparison.read_text()).get('physical_counter_differences'):
                                raise ValueError('Comparison failed before producing valid physical evidence')
                            receipt['physical_comparison_failed'] = True
                        save()
                receipt['experiments_completed'] = 1
            receipt['deadline_gate_failed'] = deadline_failure
            receipt['status'] = 'complete'; save()
            return 2 if deadline_failure or receipt.get('physical_comparison_failed') else 0
        except BaseException as error:
            receipt['status'] = 'failed'; receipt['error'] = str(error); save()
            raise


if __name__ == '__main__':
    sys.exit(main())
