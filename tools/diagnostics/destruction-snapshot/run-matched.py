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
                peak_sample_index=ticks.index(max(ticks)),
                over_8ms=sum(t > 8 for t in ticks),
                over_120hz=sum(t > 1000 / 120 for t in ticks), over_60hz=sum(t > 1000 / 60 for t in ticks),
                budget_miss_percent={name:100*sum(t>bound for t in ticks)/len(ticks)
                                     for name,bound in [('8ms',8),('120hz',1000/120),('60hz',1000/60)]},
                stress_iterations=dict(min=min(s['stress_iterations'] for s in samples),
                                       max=max(s['stress_iterations'] for s in samples),
                                       mean=statistics.mean(s['stress_iterations'] for s in samples)),
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
              '| Scenario | A / B samples | A / B >8ms count (%) | A / B >60 Hz count (%) | A / B >120 Hz count (%) | A / B restore mean ms (excluded) |',
              '|---|---:|---:|---:|---:|---:|']
    for row in report['scenarios']:
        a, b = row['A'], row['B']
        counts=[' / '.join(f"{s['over_'+key]} ({s['budget_miss_percent'][key]:.1f}%)" for s in [a,b])
                for key in ['8ms','60hz','120hz']]
        lines.append(f"| {row['scenario']} | {a['n']} / {b['n']} | {' | '.join(counts)} | "
                     f"{a['restore_mean_ms']:.3f} / {b['restore_mean_ms']:.3f} |")
    lines += ['', '| Scenario | A / B command ms | A / B simulate/fetch ms | A / B completion ms |',
              '|---|---:|---:|---:|']
    for row in report['scenarios']:
        cells = [f"{row['A']['stages_ms'][k]:.6f} / {row['B']['stages_ms'][k]:.6f}"
                 for k in ['command_ms', 'simulate_fetch_ms', 'completion_ms']]
        lines.append(f"| {row['scenario']} | {' | '.join(cells)} |")
    lines += ['', '| Scenario | Context setup A before / B / A after ms (excluded) | A / B stress iterations min–max |',
              '|---|---:|---:|']
    for row in report['scenarios']:
        setup=' / '.join(f"{row['context_setup_ms'][arm]:.3f}" for arm in ['A0','B','A1'])
        iterations=' / '.join(f"{row[arm]['stress_iterations']['min']}–{row[arm]['stress_iterations']['max']}" for arm in ['A','B'])
        lines.append(f"| {row['scenario']} | {setup} | {iterations} |")
    (output / 'report.md').write_text('\n'.join(lines) + '\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('--manifest', type=Path, required=True, help='Input manifest produced by run-suite.py')
    parser.add_argument('--binary', type=Path, required=True)
    parser.add_argument('--candidate-binary', type=Path, help='Separate statically linked CPU candidate; defaults to --binary')
    parser.add_argument('--baseline-artifacts', type=Path, required=True)
    parser.add_argument('--candidate-artifacts', type=Path, required=True)
    parser.add_argument('--candidate-commit', required=True)
    parser.add_argument('--control-repetitions', type=int, default=20)
    parser.add_argument('--candidate-repetitions', type=int, default=20)
    parser.add_argument('--use-case-repetitions', action='store_true', help='Use each manifest case repetition count for every A-before/B/A-after process')
    parser.add_argument('--allow-existing-graphics', action='store_true')
    parser.add_argument('--allow-compute-pid', type=int, action='append', default=[])
    args = parser.parse_args()
    if min(args.control_repetitions, args.candidate_repetitions) < 2:
        parser.error('Each cohort requires at least two restores')
    cases = json.loads(args.manifest.read_text())['scenarios']
    if args.control_repetitions != args.candidate_repetitions:
        parser.error('Use equal per-process repetition counts so first-use ticks have equal weight in both arms')
    if args.use_case_repetitions:
        if args.control_repetitions!=20 or args.candidate_repetitions!=20:
            parser.error('--use-case-repetitions cannot override explicitly changed cohort counts')
        if any(type(c.get('repetitions')) is not int or c['repetitions']<2 for c in cases):
            parser.error('Manifest repetition counts must be at least two')
    binaries={arm:binary.resolve() for arm,binary in [('A',args.binary),('B',args.candidate_binary or args.binary)]}
    binary_hashes={arm:hashlib.sha256(binary.read_bytes()).hexdigest() for arm,binary in binaries.items()}
    module_hashes={arm:{str((directory/name).resolve()):hashlib.sha256((directory/name).read_bytes()).hexdigest()
                       for name in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']}
                   for arm,directory in [('A',args.baseline_artifacts),('B',args.candidate_artifacts)]}
    for case in cases:
        for name, digest in case['input_sha256'].items():
            if hashlib.sha256(Path(name).read_bytes()).hexdigest() != digest:
                raise RuntimeError(f'Changed input: {name}')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    report = dict(status='running', candidate_commit=args.candidate_commit, scenarios=[], runs=[],
                  runner_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
                  repetition_policy='Equal per-process counts in A-before/B/A-after; all first-use ticks included at equal weight. Pooled controls have twice the candidate sample count.',
                  binaries={arm:dict(path=str(binary),sha256=binary_hashes[arm]) for arm,binary in binaries.items()},
                  modules=module_hashes,
                  checker_sha256=hashlib.sha256((HERE / 'compare-observations.py').read_bytes()).hexdigest(),
                  force_scaled_bound=observations.FORCE_SCALED_BOUND,
                  scope='One full tick per independent physical restore. A-before / B / A-after per scenario. '
                        'All CPU/GPU work and correction included; restore, validation and post-tick observation excluded. '
                        'Unprofiled comparison with recorded GPU admission; no profiler timings or automatic acceptance.')
    (output / 'manifest.json').write_text(json.dumps(dict(cases=cases, arguments={
        k: str(v) if isinstance(v, Path) else v for k, v in vars(args).items()}), indent=2) + '\n')
    begin = time.monotonic()
    try:
        for case in cases:
            runs, samples, setup = {}, {}, {}
            candidate_count=case['repetitions'] if args.use_case_repetitions else args.candidate_repetitions
            control_count=candidate_count if args.use_case_repetitions else args.control_repetitions
            for arm, artifacts, count in [('A0', args.baseline_artifacts, control_count),
                                          ('B', args.candidate_artifacts, candidate_count),
                                          ('A1', args.baseline_artifacts, control_count)]:
                for name, digest in case['input_sha256'].items():
                    if hashlib.sha256(Path(name).read_bytes()).hexdigest() != digest:
                        raise RuntimeError(f'Input changed during campaign: {name}')
                run = output / f"{case['scenario']}-{arm}"
                binary_arm='B' if arm=='B' else 'A'
                if hashlib.sha256(binaries[binary_arm].read_bytes()).hexdigest()!=binary_hashes[binary_arm]:
                    raise RuntimeError('CPU binary changed during campaign')
                if any(hashlib.sha256(Path(path).read_bytes()).hexdigest()!=digest
                       for path,digest in module_hashes[binary_arm].items()):
                    raise RuntimeError('GPU module changed during campaign')
                command = [sys.executable, str(HERE / 'run-probe.py'), str(run), '--binary', str(binaries[binary_arm]),
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
                receipt=json.loads((run/'receipt.json').read_text())
                if receipt['binary_sha256']!=binary_hashes[binary_arm] or receipt['modules']!=module_hashes[binary_arm]:
                    raise RuntimeError('Run provenance differs from campaign identity')
                runs[arm] = run
                replay=json.loads((run / 'replay.json').read_text())
                samples[arm] = replay['samples']
                setup[arm] = replay['context_setup_ms']
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
                       context_setup_ms=setup,
                       first_tick_ms={arm:data[0]['complete_step_ms'] for arm,data in samples.items()},
                       later_tick_mean_ms={arm:statistics.mean(s['complete_step_ms'] for s in data[1:])
                                           for arm,data in samples.items()},
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
