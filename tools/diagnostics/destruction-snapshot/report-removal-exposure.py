#!/usr/bin/env python3
"""Rank measured exposure separately from hypotheses about removable work."""
import argparse
import collections
import hashlib
import json
from pathlib import Path


def summarize(kernels, scopes):
    groups = collections.Counter()
    for row in kernels:
        name = row['name']
        group = ('iteration' if 'componentStressSolve' in name or 'persistentStressSolve' in name
                 else 'motion_modes' if 'constructMotionModes(' in name
                 else 'material' if any(v in name for v in ['evaluateBondMaterials(', 'evaluateChunkMaterials(', 'finalizeMaterialVerdict('])
                 else 'input_preparation' if any(v in name for v in ['prepareLoads(', 'observeNativeClusters(', 'beginNativeSettledReuse('])
                 else 'other')
        groups[group] += row['aggregate_ms']
    names = ['allocateNativeBodies', 'validateOwners', 'scheduleOwners', 'migrateShapes']
    cpu = {name: sum(value for key, value in scopes.items() if key.endswith('.'+name)) for name in names}
    return dict(kernel_aggregate_ms=dict(groups), exclusive_thread_cpu_ms=cpu)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('captures', type=Path)
    parser.add_argument('qualification', type=Path)
    args = parser.parse_args()
    inputs = {}

    def read(path):
        raw = path.read_bytes()
        inputs[str(path)] = hashlib.sha256(raw).hexdigest()
        return json.loads(raw)

    baselines = {row['scenario']: row['baseline'] for row in read(args.qualification/'report.json')['scenarios_data']}
    snapshots = []
    for case in read(args.captures/'cpu-full/campaign.json')['scenarios']:
        assert case['status'] == 'complete'
        data = read(Path(case['path'])/'attribution.json')
        scopes = {row['name']: row['exclusive_thread_cpu_ms'] for row in data['cpu_attribution']['scopes']
                  if row['exclusive_thread_cpu_ms'] is not None}
        baseline = baselines[case['scenario']]
        row = dict(scenario=case['scenario'], source=case['path'],
                   unprofiled={key: baseline[key] for key in ['n', 'tick_mean_ms', 'tick_max_ms', 'misses_60hz', 'misses_120hz']},
                   **summarize(data['ranked_kernels'], scopes))
        snapshots.append(row)
    warm = []
    for case in ['idle-256', 'impacts-256']:
        path = args.captures/'warm-reduced-sampling'/(case+'-profile')/'warm-attribution.json'
        frames = read(path)['frames']
        for frame in frames:
            warm.append(dict(case=case, step=frame['step'],
                             **summarize(frame['ranked_kernels'], frame['phase_exclusive_cpu_ms'])))
    result = dict(scope='Diagnostic exposure only. Kernel aggregates overlap CPU and may overlap each other. '
                        'Exclusive thread CPU excludes nested recorded CPU scopes, not concurrent GPU work. '
                        'These quantities are not predicted or subtractable full-step savings. Cold snapshot baseline '
                        'has20 full ticks per case; current N20 comparisons remain a separate cohort.',
                  snapshots=snapshots, warm=warm, inputs=inputs,
                  decisions=['Do not prioritize a pointer-cache-only change from the whole allocation/migration budget: '
                             'validation is only1.593ms at warm first fracture and0.127ms at late step179.',
                             'Measure per-component active/settled work before choosing numerical removal versus CPU lifecycle restructuring.',
                             'Material/input skip may improve idle but has much smaller measured kernel exposure than heavy iteration.',
                             'Topology motion-mode work is already generation-gated; a new proposal must exploit locality within actual changes.'])
    (args.qualification/'removal-exposure.json').write_text(json.dumps(result, indent=2)+'\n')
    lines = ['# Measured exposure for removal priorities', '', result['scope'], '',
             'A large parent scope does not justify attributing its cost to repeated pointer validation. '
             'That candidate is held before implementation; the next diagnostic reuses the existing per-component work recorder.', '',
             '| Restored scenario | Unprofiled mean / peak ms | Iteration / modes / materials / input GPU aggregate ms | Allocation / validation / migration exclusive thread CPU ms |',
             '|---|---:|---:|---:|']
    for row in snapshots:
        k, c, b = row['kernel_aggregate_ms'], row['exclusive_thread_cpu_ms'], row['unprofiled']
        lines.append(f"| {row['scenario']} | {b['tick_mean_ms']:.3f} / {b['tick_max_ms']:.3f} | " +
                     ' / '.join(f'{k.get(n,0):.3f}' for n in ['iteration','motion_modes','material','input_preparation']) + ' | ' +
                     ' / '.join(f'{c[n]:.3f}' for n in ['allocateNativeBodies','validateOwners','migrateShapes']) + ' |')
    lines += ['', '## Continuous semantic checkpoints', '',
              '| Case / tick | Iteration / modes / materials / input GPU aggregate ms | Allocation / validation / migration exclusive thread CPU ms |',
              '|---|---:|---:|']
    for row in warm:
        if row['step'] not in [0,81,82,103,179]:
            continue
        k, c = row['kernel_aggregate_ms'], row['exclusive_thread_cpu_ms']
        lines.append(f"| {row['case']} / {row['step']} | " +
                     ' / '.join(f'{k.get(n,0):.3f}' for n in ['iteration','motion_modes','material','input_preparation']) + ' | ' +
                     ' / '.join(f'{c[n]:.3f}' for n in ['allocateNativeBodies','validateOwners','migrateShapes']) + ' |')
    lines += ['', 'All360 continuous frames and source hashes are retained in `removal-exposure.json`. '
              'Full-step idle/heavy means, maxima, deadline misses, initialization and stage evidence remain in '
              '[the attribution report](coverage-tiers.md); retained N20 application comparisons are in [N20 qualification](n20-final.md). '
              'No runtime change or new application gain is claimed.']
    (args.qualification/'removal-exposure.md').write_text('\n'.join(lines)+'\n')
    print(f'{len(snapshots)} restored scenarios; {len(warm)} continuous frames analyzed.')


if __name__ == '__main__':
    main()
