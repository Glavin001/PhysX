#!/usr/bin/env python3
"""Write readable, scope-aware timing tables from a validated native capture."""
import argparse
from collections import defaultdict
import csv
from pathlib import Path
import runpy
import statistics

analysis = runpy.run_path(str(Path(__file__).with_name('analyze-native-destruction-phases.py')))


def report(capture):
    result = analysis['analyze'](capture)
    count = result['frames']
    values = defaultdict(lambda: defaultdict(float))
    with (capture / 'native.phases.csv').open() as stream:
        for row in csv.DictReader(stream):
            values[row['phase'].removeprefix(analysis['PREFIX'])][int(row['step'])] += float(row['host_wall_ms'])
    timing = result['physics_timing']
    lines = [
        '# Native destruction timing report', '',
        f'Capture: `{capture}`. {count:,} accepted steps; {result["corrected_steps"]:,} steps used one resimulation.', '',
        'These are host-wall timings including GPU waits, measured with profiling on a shared GPU. Audit settings are recorded in `native.summary.json`. '
        'They are not isolated CUDA kernel timings or a whole-game performance qualification. The simulation/destruction row is `physics_step_ms`, including integrated destruction; it is not stock PhysX alone or the authoritative unprofiled `complete_step_ms`.', '',
        '| Measured scope | Minimum ms | Average ms | Maximum ms | p95 ms |',
        '| --- | ---: | ---: | ---: | ---: |',
    ]
    for title, key in [('Simulation/destruction', 'physics_timing'), ('Capture tick including observation and I/O', 'capture_tick_timing')]:
        row = result[key]
        lines.append(f'| {title} | {row["min_ms"]:.3f} | {row["mean_ms"]:.3f} | {row["max_ms"]:.3f} | {row["p95_ms"]:.3f} |')
    lines += ['', f'Simulation speed: **{timing["real_time_factor"]:.3f}x real time** '
              f'({timing["effective_steps_per_second"]:.2f} steps/s). '
              f'{timing["missed_deadlines"]:,}/{count:,} steps exceeded {timing["fixed_step_ms"]:.3f} ms.', '',
              '## Outer simulation intervals', '',
              'This table averages over **all** accepted steps, counting absent correction phases as zero. '
              'These selected outer intervals plus the residual reconcile to the complete simulation step. '
              'The residual contains ordinary physics, checkpointing, nested tasks and other work; '
              'it is not a measurement of one GPU kernel.', '',
              '| Interval | Average ms per accepted step |', '| --- | ---: |']
    names = {
        'submit': 'Submit contact loads, motion inputs and destruction work',
        'finishAndReserve': 'Wait for destruction completion and reserve bodies',
        'collisionBindings': 'Prepare collision ownership bindings',
        'correctionBodies': 'Prepare bodies for correction',
        'preparationCompletion': 'Observe prepared correction verdicts',
        'initializeReserved': 'Initialize reserved body state',
        'applyBindings': 'Apply changed collision ownership',
        'restoreInstall': 'Restore/install provisional motion',
        'resetContactCaches': 'Reset affected contact caches',
        'correctedCollisionSolve': 'Correction collision/solve (including refilter)',
        'acceptCorrection': 'Accept corrected state',
    }
    outer_total = 0.0
    for name in names:
        assert name in analysis['INDEPENDENT']
        mean = sum(values[name].values()) / count
        outer_total += mean
        lines.append(f'| {names[name]} (`{name}`) | {mean:.3f} |')
    residual = result['unmeasured_interval_mean_ms']
    assert abs(outer_total + residual - timing['mean_ms']) < .05
    lines += [f'| Ordinary physics/checkpoint/other residual | {residual:.3f} |',
              f'| **Complete simulation step** | **{timing["mean_ms"]:.3f}** |', '',
              '## Every recorded phase/task', '',
              '**Do not add this table:** parent/child scopes and parallel tasks overlap. '
              'The active-step columns summarize only steps where that scope appeared. '
              'The all-step average counts absent scopes as zero. `task.*` values sum invocations '
              'within each accepted step across trial and correction. `trialDetail.*` is the ordinary '
              'pass; `detail.*` is inside correction. `refilter` is included in `correctedCollisionSolve`.', '',
              '| Scope | Active steps | Active-step min ms | Active-step avg ms | Active-step max ms | All-step avg ms |',
              '| --- | ---: | ---: | ---: | ---: | ---: |']
    for name in sorted(values):
        measured = list(values[name].values())
        expected = result['phases'][name]
        assert len(measured) == expected['samples']
        assert abs(statistics.mean(measured) - expected['mean_ms']) < 1e-9
        lines.append(f'| `{name}` | {len(measured):,} | {min(measured):.3f} | {statistics.mean(measured):.3f} | '
                     f'{max(measured):.3f} | {sum(measured)/count:.3f} |')
    if result.get('cuda_stages'):
        gpu = result['cuda_stages']
        lines += ['', '## CUDA destruction stages', '', gpu['scope'], '',
                  'These stages are separate from the host-wall scopes above. Do not add them to the simulation total.', '',
                  '| Device stage | Min ms | Average ms | Max ms | p95 ms |',
                  '| --- | ---: | ---: | ---: | ---: |']
        for name, row in [*gpu['phases'].items(), ('Total destruction stage sequence', gpu['total'])]:
            lines.append(f'| {name} | {row["min_ms"]:.3f} | {row["mean_ms"]:.3f} | {row["max_ms"]:.3f} | {row["p95_ms"]:.3f} |')
    lines += ['', 'Individual CUDA kernel durations for stress, topology, broadphase, narrowphase and rigid solving '

              'are not separately isolated in this capture. In particular, the short `task.contactGraph` '
              'host scope is not the GPU graph-computation duration, and `finishAndReserve` is not pure stress time.', '']
    return '\n'.join(lines)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture', type=Path)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    try:
        text = report(args.capture)
    except (ValueError, KeyError, OSError, AssertionError) as error:
        parser.exit(1, f'Cannot report invalid phase capture: {error}\n')
    if args.output:
        args.output.write_text(text)
    else:
        print(text)
