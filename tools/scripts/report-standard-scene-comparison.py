#!/usr/bin/env python3
"""Compare ordinary-scene load analogues with explicitly selected resim=1 reports.

Only compares measured work bands. It never calls unequal workloads a speedup.
All measured frames are retained; video timing is reported separately.
"""
import argparse
import csv
import gzip
import hashlib
import json
import math
from pathlib import Path
import statistics


def read_frames(directory):
    p = directory / 'native.frames.csv'
    if p.exists():
        with p.open() as f:
            return list(csv.DictReader(f))
    with gzip.open(p.with_suffix('.csv.gz'), 'rt') as f:
        return list(csv.DictReader(f))


def timing(rows):
    values = sorted(float(r['complete_step_ms']) for r in rows)
    assert values and all(math.isfinite(v) and v > 0 for v in values)
    return dict(samples=len(values), minimum=min(values), mean=statistics.mean(values),
                p95=values[int((len(values)-1)*.95)], maximum=max(values),
                missed_60hz=sum(v > 1000/60 for v in values),
                missed_8ms=sum(v > 8 for v in values))


def inspect(directory):
    s = json.loads((directory / 'native.summary.json').read_text())
    rows = read_frames(directory)
    assert s['status'] == 'completed' and len(rows) == s['frames']
    assert not s['direct_gpu_mode'] and s['sleeping'] and s['correction_limit'] == 1
    assert all(int(r['step']) == i and int(r['stress_converged']) == 1
               and int(r['resim_passes']) <= 1 and int(r['correction_status']) == 0
               for i, r in enumerate(rows))
    assert sum(int(r['bonds_broken']) for r in rows) == s['broken_bonds']
    assert sum(int(r['resim_passes']) for r in rows) == s['corrections']
    for r in rows:
        assert abs(float(r['complete_step_ms']) - sum(float(r[k]) for k in
                   ['command_ms', 'physics_step_ms', 'completion_ms'])) < .0002
    cumulative = 0
    bands = []
    for start in range(0, len(rows), 180):
        band = rows[start:start+180]
        cumulative += sum(int(r['bonds_broken']) for r in band)
        if len(band) != 180:
            continue
        bands.append(dict(start_step=start, end_step=start+179,
                          bodies=statistics.median(int(r['bodies']) for r in band),
                          awake=statistics.median(int(r['awake_bodies']) for r in band),
                          broken_bonds=cumulative, timing=timing(band)))
    peak = max(rows, key=lambda r: float(r['complete_step_ms']))
    return dict(path=str(directory), summary=s, timing=timing(rows),
                peak_sample=peak, peak_bodies=max(int(r['bodies']) for r in rows),
                peak_awake=max(int(r['awake_bodies']) for r in rows),
                windows={label: timing(part) for label, part in {
                    'impact_0_to_15s': rows[:900], 'rubble_20_to_30s': rows[1200:1800],
                    'corrected_steps': [r for r in rows if int(r['resim_passes']) == 1]
                }.items() if part}, bands=bands)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture', type=Path)
    p.add_argument('--reference', required=True, type=Path)
    p.add_argument('--videos', type=Path)
    p.add_argument('--output', required=True, type=Path)
    args = p.parse_args()
    manifest = json.loads((args.capture / 'campaign.json').read_text())
    assert manifest['status'] == 'complete'
    reference = json.loads(args.reference.read_text())
    assert reference['rows'] and all(r['resim_limit'] == '1' for r in reference['rows'])
    measured = []
    for rec in manifest['runs']:
        if rec['mode'] != 'plain':
            continue
        assert rec['exit_code'] == 0
        directory = args.capture / rec['name']
        for filename, digest in rec['files'].items():
            assert hashlib.sha256((directory/filename).read_bytes()).hexdigest() == digest
        run = inspect(directory)
        run.update(case=rec['case'], trial=rec['trial'])
        measured.append(run)
    videos = []
    if args.videos and args.videos.exists():
        for d in sorted(args.videos.iterdir()):
            if d.is_dir() and (d/'native.summary.json').exists():
                videos.append(inspect(d))
    targets = [reference['rows'][0], reference['rows'][5], reference['rows'][-1]]
    comparisons = []
    for target in targets:
        choices = []
        for run in measured:
            for band in run['bands']:
                score = sum(abs(math.log((band[k]+1)/(target[src]+1))) for k, src in
                            [('bodies','bodies'), ('awake','awake'), ('broken_bonds','broken_bonds')])
                choices.append((score, run['path'], band))
        score, path, band = min(choices, key=lambda x: (x[0], x[1], x[2]['start_step']))
        comparisons.append(dict(reference=target, nearest_run=path, band=band, distance=score))
    result = dict(campaign=str(args.capture), configuration=manifest['config'],
                  reference_sha256=hashlib.sha256(args.reference.read_bytes()).hexdigest(),
                  measured=measured, videos=videos, workload_comparisons=comparisons,
                  claim='Load analogues only; no equal-geometry/input/fidelity speedup claim.')
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output/'comparison.json').write_text(json.dumps(result, indent=2)+'\n')
    lines = ['# Ordinary PhysX GPU + embedded destruction: load comparison', '',
             '**Direct GPU OFF · Sleeping ON · CUDA physics/destruction · resim limit 1 · dt 1/60 s.**', '',
             'Procedural native buildings and ballistic projectiles approximate the recorded work range; '
             'they do not reproduce Vibe-land geometry, hitscan inputs, materials or convergence/freezing policy. '
             'All scenes use the same physical parameters: 18,000 kg projectiles, wall strength scale 24, '
             'frame strength scale 40, stress tolerance 1e-5 and maximum 8,192 iterations with convergence required.', '',
             'Each measured run covers 30 simulated seconds / 1,800 steps. A separate warm-up precedes '
             'two unrendered trials; no first-step or allocation outlier is removed. Phase captures and '
             'videos run separately. Complete-step timing includes commands, physics, destruction, correction '
             'and mandatory completion, excluding setup, optional observation, graphics and encoding.', '',
             '## Unrendered measurements', '',
             '| Buildings / trial | Chunks / bonds / projectiles | Peak bodies / awake | Broken bonds | Min / mean / p95 / max ms | >16.667 ms | >8 ms |',
             '|---|---|---|---:|---|---:|---:|']
    for run in measured:
        s, t = run['summary'], run['timing']
        lines.append(f"| {s['buildings']} / {run['trial']+1} | {s['chunks']:,} / {s['bonds']:,} / {s['projectiles']} | "
                     f"{run['peak_bodies']:,} / {run['peak_awake']:,} | {s['broken_bonds']:,} | "
                     f"{t['minimum']:.2f} / {t['mean']:.2f} / {t['p95']:.2f} / {t['maximum']:.2f} | "
                     f"{t['missed_60hz']}/{t['samples']} | {t['missed_8ms']}/{t['samples']} |")
    lines += ['', '## Impacts, correction and late rubble', '',
              '| Buildings / trial | Subset | Steps | Mean / max ms |', '|---|---|---:|---|']
    for run in measured:
        for label, t in run['windows'].items():
            lines.append(f"| {run['summary']['buildings']} / {run['trial']+1} | {label} | {t['samples']} | {t['mean']:.2f} / {t['maximum']:.2f} |")
    lines += ['', '## Closest recorded workload bands', '',
              'Only the newest verified Vibe-land executable/session with resim=1 is used. '
              'Its player reports show 96,420 chunks; total authored bonds are absent. Newer headless '
              'observations lack their own geometry count. Vibe timings are broader server-tick rolling windows. '
              'We select a non-overlapping 180-step native band using body, awake and broken-bond counts '
              '(sum of absolute log ratios), never its timing. Native bodies/awake are band medians; '
              'broken bonds are cumulative at band end. Vibe counters are snapshots. These bands are '
              'descriptive comparisons, not matched trials or a scale model. Native body counts include spawned projectiles; Vibe city body counts exclude other gameplay actors. The native stress graph is partitioned into many small buildings, unlike the city asset, so matching chunk totals does not match connected solve complexity.', '',
              '| Reference / native band | Bodies / awake / broken bonds | Mean / p95 / max ms |', '|---|---|---|']
    for match in comparisons:
        r, b = match['reference'], match['band']; t = b['timing']
        lines.append(f"| Vibe {r['captured_at']} ({'headless' if r['headless'] else 'player'}) | {r['bodies']:,} / {r['awake']:,} / {r['broken_bonds']:,} | {r['mean_ms']:.2f} / {r['p95_ms']:.2f} / {r['max_ms']:.2f} |")
        lines.append(f"| Native {Path(match['nearest_run']).name}, steps {b['start_step']}–{b['end_step']} | {b['bodies']:,.0f} / {b['awake']:,.0f} / {b['broken_bonds']:,} | {t['mean']:.2f} / {t['p95']:.2f} / {t['maximum']:.2f} |")
    phase_path = args.output / 'timing/report.json.gz'
    if phase_path.exists():
        phase_data = json.loads(gzip.decompress(phase_path.read_bytes()))
        lines += ['', '## Separately measured phase peaks', '',
                  'These are the instrumented runs, not a decomposition of an unrendered peak. '
                  'Correction includes CPU scheduling/lifecycle and GPU physics. The GPU stress stage '
                  'overlaps the CPU wait for destruction; never add both to the total.', '',
                  '| Buildings | Scoped complete peak ms | Correction ms | Trial/remaining ms | Wait for destruction ms | GPU stress ms (overlapping) |',
                  '|---|---:|---:|---:|---:|---:|']
        for case in phase_data['phase_captures']:
            i = case['peak_step']; profile = case['profile']; wall = profile['wall_partition'][i]
            directory = args.capture / (case['case'] + '-phases-0')
            total = float(read_frames(directory)[i]['complete_step_ms'])
            lines.append(f"| {case['case']} | {total:.2f} | {wall.get('correctedCollisionSolve',0):.2f} | {wall.get('trial.other',0):.2f} | {wall.get('finishDetail.waitForGpu',0):.2f} | {profile['cuda_stages'][i].get('stress',0):.2f} |")
        lines += ['', 'The full phase report expands fragment allocation, ownership migration, contact-manager registration, '
                  'island updates, checkpoint/restore, stress/material/topology stages and accepted publication, with CPU/GPU owners. '
                  'Task scopes can overlap and are not isolated GPU kernel timings.']
    lines += ['', '## Videos', '', 'Video recordings are separate physical runs and can fracture differently. On-screen timing comes from that exact video capture, not the unrendered trials.']
    for v in videos:
        d=Path(v['path']); t=v['timing']; s=v['summary']
        lines += ['', f"- [{s['buildings']}-building video]({d.resolve()}/native-captioned.mp4): {s['chunks']:,} chunks, {s['bonds']:,} bonds, {s['projectiles']} projectiles; {s['broken_bonds']:,} broken bonds; exact capture complete-step mean/max {t['mean']:.2f}/{t['maximum']:.2f} ms."]
    lines += ['', '## Qualification limits and reproduction', '',
              'Every completed run is checked for accepted steps, convergence, correction <=1, total broken-bond/correction consistency and complete-timer closure. '
              'These counters do not prove matching physical trajectories, collision/render parity, or absence of all geometry bugs. '
              'The ordinary-mode frozen penetration topology discrepancy remains open. This is not five 60-second trials or full lifecycle endurance. '
              'Absent solver-row/pair counters are not evidence that PhysX performed no work.', '',
              '[Detailed timing and separate phase breakdown](timing/report.md) · [Machine-readable comparison](comparison.json)', '',
              '`python3 tools/scripts/run-destruction-timing.py out/NEW --config tools/profiles/standard-scene-bombardment-comparison.json --trials 2 --seconds 30 --gate-only --phase-scopes`', '',
              'Exit 2 from the timing report means a deadline/duration gate failed; it is not a failed simulation. Keep that result visible.']
    (args.output/'comparison.md').write_text('\n'.join(lines)+'\n')
    print(args.output/'comparison.md')


if __name__ == '__main__':
    main()
