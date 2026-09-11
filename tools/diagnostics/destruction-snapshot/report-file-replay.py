#!/usr/bin/env python3
"""Summarize independent, single-tick physical file replays without speedup claims."""
import argparse
import json
import statistics
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('output',type=Path)
p.add_argument('runs',type=Path,nargs='+')
a=p.parse_args();rows=[]
for run in a.runs:
    receipt=json.loads((run/'receipt.json').read_text());d=json.loads((run/'replay.json').read_text())
    if receipt['status']!='complete' or not d['passed'] or d['steps_per_restore']!=1:
        raise SystemExit(f'Unqualified replay: {run}')
    s=d['samples'];t=[x['complete_step_ms'] for x in s];r=[x['restore_ms'] for x in s]
    rows.append(dict(scenario=run.name.removeprefix('file-'),samples=len(s),mean_ms=statistics.mean(t),median_ms=statistics.median(t),min_ms=min(t),max_ms=max(t),
        restore_mean_ms=statistics.mean(r),restore_max_ms=max(r),
        over_8_ms=sum(x>8 for x in t),over_120hz=sum(x>1000/120 for x in t),over_60hz=sum(x>1000/60 for x in t),
        corrections=sorted({x['correction_passes'] for x in s}),stress_evaluations=sorted({x['stress_passes'] for x in s}),
        stress_iterations=sorted({x['stress_iterations'] for x in s}),broken_bonds=sorted({x['broken_bonds'] for x in s}),
        max_position_error_m=max(x['position_error_m'] for x in s),max_linear_error_m_s=max(x['linear_error_m_s'] for x in s),max_angular_error_rad_s=max(x['angular_error_rad_s'] for x in s),
        input_sha256=receipt['snapshot_inputs'],raw=str(run/'replay.json')))
result={'scope':'One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.', 'scenarios':rows}
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.with_suffix('.json').write_text(json.dumps(result,indent=2)+'\n')
lines=['# Independent one-tick file replay','',result['scope'],'',
       '| Saved scenario | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |',
       '|---|---:|---:|---:|---:|---|---|']
for r in rows:
    misses=' / '.join(f"{r[k]} ({100*r[k]/r['samples']:.0f}%)" for k in ['over_8_ms','over_120hz','over_60hz'])
    lines.append(f"| {r['scenario']} | {r['samples']} | {r['mean_ms']:.3f} / {r['max_ms']:.3f} | {r['median_ms']:.3f} | {r['restore_mean_ms']:.3f} | {misses} | {r['corrections']} / {r['stress_evaluations']} |")
lines+=['','Every repeat passed the physical/material/motion checks. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. These small/scaled fixtures are not the 256-building city benchmark.','',
        'The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.','']
a.output.with_suffix('.md').write_text('\n'.join(lines));print(f'{len(rows)} file scenarios reported')
