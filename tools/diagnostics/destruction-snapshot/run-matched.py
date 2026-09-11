#!/usr/bin/env python3
"""Matched A/B/A complete-tick replay with post-tick physical comparisons."""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import random
import statistics
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location('observations', HERE / 'compare-observations.py')
observations = importlib.util.module_from_spec(spec)
spec.loader.exec_module(observations)


def stats(samples):
    ticks = [s['complete_step_ms'] for s in samples]
    return dict(n=len(ticks), mean_ms=statistics.mean(ticks), median_ms=statistics.median(ticks),
                max_ms=max(ticks), sd_ms=statistics.stdev(ticks),
                over_120hz=sum(t > 1000 / 120 for t in ticks), over_60hz=sum(t > 1000 / 60 for t in ticks),
                restore_mean_ms=statistics.mean(s['restore_ms'] for s in samples),
                stages_ms={k: statistics.mean(s[k] for s in samples)
                           for k in ['command_ms', 'simulate_fetch_ms', 'completion_ms']})


def publish(output, report):
    (output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    lines = ['# Matched restored full ticks', '', report['scope'], '',
             '| Scenario | A before mean / max ms | B mean / max ms | A after mean / max ms | A combined − B mean ms | Descriptive 95% interval ms |',
             '|---|---:|---:|---:|---:|---|']
    for row in report['scenarios']:
        cells = [f"{row[arm]['mean_ms']:.3f} / {row[arm]['max_ms']:.3f}" for arm in ['A0', 'B', 'A1']]
        lo, hi = row['descriptive_saved_ms_95']
        lines.append(f"| {row['scenario']} | {' | '.join(cells)} | {row['saved_ms']:.3f} | {lo:.3f}–{hi:.3f} |")
    lines += ['', 'Positive saved milliseconds indicate a lower candidate mean. Intervals describe sample variation, '
              'not systematic shared-GPU interference. Physical equality is checked separately; no automatic speedup acceptance.', '',
              '| Scenario | A / B samples | A / B >60 Hz | A / B >120 Hz | A / B restore mean ms (excluded) |',
              '|---|---:|---:|---:|---:|']
    for row in report['scenarios']:
        a, b = row['A'], row['B']
        lines.append(f"| {row['scenario']} | {a['n']} / {b['n']} | {a['over_60hz']} / {b['over_60hz']} | "
                     f"{a['over_120hz']} / {b['over_120hz']} | {a['restore_mean_ms']:.3f} / {b['restore_mean_ms']:.3f} |")
    lines += ['', '| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |',
              '|---|---:|---:|---:|']
    for row in report['scenarios']:
        cells = [f"{row['A']['stages_ms'][k]:.6f} / {row['B']['stages_ms'][k]:.6f}"
                 for k in ['command_ms', 'simulate_fetch_ms', 'completion_ms']]
        lines.append(f"| {row['scenario']} | {' | '.join(cells)} |")
    (output / 'report.md').write_text('\n'.join(lines) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--manifest', type=Path, required=True, help='Input manifest produced by run-suite.py')
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--baseline-artifacts', type=Path, required=True)
    parser.add_argument('--candidate-artifacts', type=Path, required=True)
    parser.add_argument('--candidate-commit', required=True)
    parser.add_argument('--control-repetitions', type=int, default=10)
    parser.add_argument('--candidate-repetitions', type=int, default=20)
    parser.add_argument('--allow-existing-graphics', action='store_true')
    parser.add_argument('--allow-compute-pid', type=int, action='append', default=[])
    args = parser.parse_args()
    if min(args.control_repetitions, args.candidate_repetitions) < 2:
        parser.error('Each cohort requires at least two restores')
    cases = json.loads(args.manifest.read_text())['scenarios']
    for case in cases:
        for name, digest in case['input_sha256'].items():
            if hashlib.sha256(Path(name).read_bytes()).hexdigest() != digest:
                raise RuntimeError(f'Changed input: {name}')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    report = dict(status='running', candidate_commit=args.candidate_commit, scenarios=[], runs=[],
                  checker_sha256=hashlib.sha256((HERE / 'compare-observations.py').read_bytes()).hexdigest(),
                  force_scaled_bound=observations.FORCE_SCALED_BOUND,
                  scope='One full tick per independent physical restore. A-before / B / A-after per scenario. '
                        'All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. '
                        'Shared-GPU unprofiled comparison; no profiler timings or automatic acceptance.')
    (output / 'manifest.json').write_text(json.dumps(dict(cases=cases, arguments={
        k: str(v) if isinstance(v, Path) else v for k, v in vars(args).items()}), indent=2) + '\n')
    begin = time.monotonic()
    try:
        for case in cases:
            runs, samples = {}, {}
            for arm, artifacts, count in [('A0', args.baseline_artifacts, args.control_repetitions),
                                          ('B', args.candidate_artifacts, args.candidate_repetitions),
                                          ('A1', args.baseline_artifacts, args.control_repetitions)]:
                for name, digest in case['input_sha256'].items():
                    if hashlib.sha256(Path(name).read_bytes()).hexdigest() != digest:
                        raise RuntimeError(f'Input changed during campaign: {name}')
                run = output / f"{case['scenario']}-{arm}"
                command = [sys.executable, str(HERE / 'run-probe.py'), str(run), '--binary', str(args.binary.resolve()),
                           '--artifacts', str(artifacts.resolve()), '--replay-prefix', case['prefix'],
                           '--repetitions', str(count), '--watchdog-seconds', '1200']
                if args.allow_existing_graphics:
                    command += ['--allow-existing-graphics']
                for pid in args.allow_compute_pid:
                    command += ['--allow-compute-pid', str(pid)]
                if case.get('projectile_impulse'):
                    command += ['--projectile-impulse']
                result = subprocess.run(command, env=dict(os.environ, PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first'))
                report['runs'].append(dict(scenario=case['scenario'], arm=arm, command=command, exit_code=result.returncode))
                publish(output, report)
                if result.returncode:
                    raise RuntimeError(f"Replay failed: {case['scenario']} {arm}")
                runs[arm] = run
                samples[arm] = json.loads((run / 'replay.json').read_text())['samples']
            physical = {}
            for arm in ['B', 'A1']:
                physical[arm] = observations.compare(runs['A0'], runs[arm])
                (output / f"{case['scenario']}-physical-{arm}.json").write_text(json.dumps(physical[arm], indent=2) + '\n')
            a = [s['complete_step_ms'] for s in samples['A0'] + samples['A1']]
            b = [s['complete_step_ms'] for s in samples['B']]
            rng = random.Random(case['scenario'])
            differences = sorted(statistics.mean(rng.choices(a, k=len(a))) - statistics.mean(rng.choices(b, k=len(b)))
                                 for _ in range(2000))
            row = dict(scenario=case['scenario'], A=stats(samples['A0'] + samples['A1']),
                       saved_ms=statistics.mean(a) - statistics.mean(b), descriptive_saved_ms_95=[differences[50], differences[1949]],
                       physical_status='passed', raw={arm: str(run) for arm, run in runs.items()})
            row.update({arm: stats(data) for arm, data in samples.items()})
            report['scenarios'].append(row)
            publish(output, report)
        report['status'] = 'complete'
    except Exception as error:
        report.update(status='failed', error=str(error))
        raise
    finally:
        report['harness_seconds'] = time.monotonic() - begin
        publish(output, report)


if __name__ == '__main__':
    main()
