#!/usr/bin/env python3
"""Report all physical snapshot cases; these are correctness-run wall timings, not A/B wins."""
import argparse
import json
import statistics
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('output', type=Path)
p.add_argument('runs', type=Path, nargs='+')
a = p.parse_args()
cases = {}
for run in a.runs:
    receipt = json.loads((run/'receipt.json').read_text())
    if receipt['status'] != 'complete':
        raise SystemExit(f'Incomplete run: {run}')
    for path in sorted(run.glob('*.json')):
        d = json.loads(path.read_text())
        if d.get('contract') != 'physical-state-v20':
            continue
        if d.get('passed') is not True:
            raise SystemExit(f'Failed case: {path}')
        cases.setdefault(d['scenario'], []).append(d)
rows = []
for name, runs in sorted(cases.items()):
    steps = [s for r in runs for s in r['continuation']]
    times = [s[k] for s in steps for k in ('restore_a_complete_step_ms','restore_b_complete_step_ms')]
    first = [r['continuation'][0][k] for r in runs for k in ('restore_a_complete_step_ms','restore_b_complete_step_ms')]
    rows.append(dict(scenario=name, runs=len(runs), chunks=runs[0]['authored_shapes'],
        broken_before_export=runs[0]['broken_before_export'], samples=len(times),
        first_tick_ms=first, first_tick_median_ms=statistics.median(first),
        complete_step_mean_ms=statistics.mean(times), complete_step_max_ms=max(times),
        over_8_ms=sum(t>8 for t in times), over_120hz=sum(t>1000/120 for t in times), over_60hz=sum(t>1000/60 for t in times),
        position_error_m=max(s['position_error_m'] for s in steps),
        linear_error_m_s=max(s['linear_velocity_error_m_s'] for s in steps),
        angular_error_rad_s=max(s['angular_velocity_error_rad_s'] for s in steps),
        destruction_bytes=runs[0]['destruction_bytes'], physx_bytes=runs[0]['physx_bytes'],
        export_ms=[r['export_ms'] for r in runs],
        two_restores_and_validation_ms=[r['two_restores_and_validation_ms'] for r in runs], passed=True))
result = dict(contract='physical-state-v20', scope='Shared-GPU correctness diagnostics: two independent restores per case, ten consecutive full ticks each. Export and paired restoration/validation measured separately. Continuation samples are correlated; no speedup or continuous-city performance claim.', runs=[str(r) for r in a.runs], scenarios=rows)
a.output.parent.mkdir(parents=True,exist_ok=True)
a.output.with_suffix('.json').write_text(json.dumps(result,indent=2)+'\n')
lines = ['# Physical-state save/load results', '', result['scope'], '',
    '| Scenario | Chunks | Broken at export | First tick median ms | Full-tick mean / max ms | >8 / >120Hz / >60Hz | Samples | Pass |',
    '|---|---:|---:|---:|---:|---:|---:|---|']
for r in rows:
    misses = ' / '.join(f"{r[k]} ({100*r[k]/r['samples']:.1f}%)" for k in ('over_8_ms','over_120hz','over_60hz'))
    lines.append(f"| {r['scenario']} | {r['chunks']} | {r['broken_before_export']} | {r['first_tick_median_ms']:.3f} | {r['complete_step_mean_ms']:.3f} / {r['complete_step_max_ms']:.3f} | {misses} | {r['samples']} | Yes |")
lines += ['', 'Exact samples, separate export/setup observations, byte sizes and motion errors are in the adjacent JSON. Budget counts use the complete denominator shown in each row. These fixture geometries are not the 256-building city benchmark.', '']
a.output.with_suffix('.md').write_text('\n'.join(lines))
print(f'{len(rows)} scenarios reported')
