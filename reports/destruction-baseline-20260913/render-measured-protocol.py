#!/usr/bin/env python3
"""Regenerate compact tables/plots from the saved calibration records; no GPU use."""
import csv
import hashlib
import html
import json
from pathlib import Path
import shutil

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]
BASE = ROOT/'out/destruction-baseline-20260913'
screen_path = BASE/'representative-calibration-v2/screen.json'
screen = json.loads(screen_path.read_text())
assert screen['status'] == 'complete'
data = HERE/'data'
evidence = HERE/'evidence/measured-protocol'
data.mkdir(exist_ok=True)
evidence.mkdir(exist_ok=True)
shutil.copy2(screen_path, evidence/'screen.json')
shutil.copy2(BASE/'representative-calibration-v2/core.json', evidence/'core.json')
for name in ['run-representative-screen.py', 'run-paired-calibration.py', 'analyze-paired-calibration.py']:
    # Keep the exact version archived when the measurement completed, even if the
    # reusable runner later gains additional options.
    if not (evidence/name).exists():
        shutil.copy2(ROOT/'tools/diagnostics/destruction-snapshot'/name, evidence/name)
lines = ['## All nine scenarios: identical-build timing', '',
         'Authored scales (chunks / bonds): bridge768 /1524; chain256 /255; dense1728 /4752; tower2368 /4900; city25 impact11100 /22400. Both city256 snapshots and both continuous scenarios use113664 chunks /229376 bonds. Continuous heavy uses256 projectiles; continuous idle has none. Peak active-node/bond/island/contact counts are retained in each process record; authored chunks are not independent rigid bodies.', '',
         'Milliseconds per complete tick. Each cell is one fresh process, in A0/B0/B1/A1 order; “—” is a slot absent from the predeclared schedule. All differences here are measurement variation. The independent unit is the process, not each tick. All first-use samples are included.', '',
         '| Scenario | Ticks/process | Mean ms: A0 / B0 / B1 / A1 | Peak ms: A0 / B0 / B1 / A1 | 60Hz misses: A0 / B0 / B1 / A1 |',
         '|---|---:|---|---|---|']
rows = []
for row in screen['scenarios']:
    def cells(key, fmt):
        return ' / '.join(format(row['runs'][arm][key], fmt) if arm in row['runs'] else '—' for arm in ['A0','B0','B1','A1'])
    n = row['runs']['A0']['n']
    lines.append(f"|{row['scenario']}|{n}|{cells('mean_ms','.3f')}|{cells('max_ms','.3f')}|{cells('over_60hz','d')}|")
    for arm, run in row['runs'].items():
        flat = dict(scenario=row['scenario'], mode=row['mode'], arm=arm,
                    **{k:run[k] for k in ['n','mean_ms','max_ms','min_ms','sd_ms','first_tick_ms','later_mean_ms','over_60hz','restore_mean_ms']},
                    initialization_ms=run.get('context_setup_ms',run.get('initialization_ms')),
                    command_ms=run['stages_ms']['command_ms'],
                    simulate_fetch_ms=run['stages_ms'].get('simulate_fetch_ms',run['stages_ms'].get('physics_step_ms')),
                    completion_ms=run['stages_ms']['completion_ms'],raw=row['raw'][arm])
        rows.append(flat)
with (data/'representative-processes.csv').open('w') as f:
    writer=csv.DictWriter(f,fieldnames=list(rows[0]));writer.writeheader();writer.writerows(rows)
lines += ['', '[Every process: stages, first/later ticks, restore, initialization and spread](data/representative-processes.csv). [Complete source record with peak physical-work counts](evidence/measured-protocol/screen.json).', '',
          '| Scenario / process | Command ms | PhysX + integrated destruction ms | Completion ms | First tick / later mean ms | Restore mean / initialization ms, excluded |',
          '|---|---:|---:|---:|---|---|']
for r in rows:
    restore='n/a' if r['restore_mean_ms'] is None else f"{r['restore_mean_ms']:.3f}"
    lines.append(f"|{r['scenario']} {r['arm']}|{r['command_ms']:.4f}|{r['simulate_fetch_ms']:.4f}|{r['completion_ms']:.4f}|{r['first_tick_ms']:.3f} / {r['later_mean_ms']:.3f}|{restore} / {r['initialization_ms']:.3f}|")
lines += ['', 'PhysX and the tightly integrated stress solver share the simulate/fetch phase. The legacy stress_solve_ms zero field is not a measurement. Detailed disjoint CPU/GPU attribution is in the selected Systems capture. Nested scopes and concurrent kernel durations must not be summed into application wall time.', '']
precision_path = BASE/'precision-calibration/analysis.json'
if precision_path.exists():
    precision=json.loads(precision_path.read_text())
    shutil.copy2(precision_path,data/'paired-precision.json')
    shutil.copy2(BASE/'precision-calibration/calibration.json',evidence/'paired-calibration.json')
    lines += ['## Measured independent-pair precision', '',
              f"The additional fixed six-pair calibration completed in **{precision['wall_seconds']:.3f} seconds**. It reused the just-completed matching profiles. This is a separate calibration cohort, not an extended candidate result or a new speedup.", '',
              '| Scenario | Pair mean difference ms | Simultaneous95% interval ms | Smallest supported equivalence margin ms | Proposed routine margin ms | Decision at routine margin | Seconds/pair |',
              '|---|---:|---|---:|---:|---|---:|']
    for r in precision['scenarios']:
        lo,hi=r['family95_ci_ms']
        lines.append(f"|{r['scenario']}|{r['mean_saved_ms']:.4f}|[{lo:.4f}, {hi:.4f}]|±{r['equivalent_margin_supported_ms']:.4f}|±{r['proposed_equivalence_margin_ms']:.4f}|{r['decision'].replace('_',' ')}|{r['measured_seconds_per_pair']:.2f}|")
    lines += ['', 'Intervals adjust for all three measured means. They describe uncertainty under the stated stable/normal paired-effect model; they do not establish a worst-case bound or full52 equivalence. A margin strictly larger than the interval’s largest absolute endpoint would pass this conservative equivalence criterion. Maxima/miss histories remain separate.', '',
              '| Scenario | Target resolution | Estimated fresh pairs | Estimated focused seconds |',
              '|---|---|---:|---:|']
    for r in precision['scenarios']:
        for plan in r['projected_fixed_confirmation']:
            lines.append(f"|{r['scenario']}|{plan['resolution']} = {plan['margin_ms']:.4f}ms|{plan['pairs']}|{plan['seconds']:.1f}|")
    lines += ['', 'These counts are **pilot-based projections**, not measured turnaround guarantees. They target80% probability of an equivalence conclusion at true zero with stable variance. New candidate confirmations must use fresh data and a frozen count; do not pool these same-build pilot labels into a candidate comparison. Profiles cost roughly56 seconds in this measured protocol and can be reused when identities/mechanism match.', '',
              '| Scenario / pair order | A mean / peak ms | B mean / peak ms | A / B 60Hz misses | A − B ms |',
              '|---|---|---|---|---:|']
    raw=json.loads((BASE/'precision-calibration/calibration.json').read_text())
    for r in raw['scenarios']:
        for pair in r['pairs']:
            aa,bb=pair['runs']['A'],pair['runs']['B']
            lines.append(f"|{r['scenario']} {pair['index']} {''.join(pair['order'])}|{aa['mean_ms']:.3f} / {aa['max_ms']:.3f}|{bb['mean_ms']:.3f} / {bb['max_ms']:.3f}|{aa['over_60hz']} / {bb['over_60hz']}|{pair['saved_ms']:.4f}|")
    lines += ['', '[Complete precision analysis, order effects and planning assumptions](data/paired-precision.json). [Raw paired records with stages, peak work and receipt locations](evidence/measured-protocol/paired-calibration.json).', '']
    # Separate linear axes preserve readable millisecond resolution across different scales.
    svg=['<svg xmlns="http://www.w3.org/2000/svg" width="1000" height="480" viewBox="0 0 1000 480">',
         '<rect width="1000" height="480" fill="white"/>',
         '<g font-family="sans-serif" fill="#17263c"><text x="28" y="30" font-size="21">Identical code: uncertainty of paired full-step differences</text>',
         '<text x="28" y="55" font-size="14">Six independent pairs per case; simultaneous 95% t intervals; each panel has its own millisecond scale.</text>']
    for i,r in enumerate(precision['scenarios']):
        y=110+i*115
        lo,hi=r['family95_ci_ms'];margin=r['proposed_equivalence_margin_ms'];span=max(abs(lo),abs(hi),margin)*1.2
        x=lambda value:620+value/span*320
        svg += [f'<text x="28" y="{y-10}" font-size="17">{html.escape(r["scenario"])}</text>',
                f'<text x="28" y="{y+12}" font-size="13">mean difference {r["mean_saved_ms"]:.3f} ms</text>',
                f'<rect x="{x(-margin):.2f}" y="{y-24}" width="{x(margin)-x(-margin):.2f}" height="48" fill="#e2efeb"/>',
                f'<line x1="{x(-span)}" x2="{x(span)}" y1="{y}" y2="{y}" stroke="#c5cbd3"/>',
                f'<line x1="620" x2="620" y1="{y-27}" y2="{y+27}" stroke="#555"/>',
                f'<line x1="{x(lo):.2f}" x2="{x(hi):.2f}" y1="{y}" y2="{y}" stroke="#285a9b" stroke-width="5"/>',
                f'<circle cx="{x(r["mean_saved_ms"]):.2f}" cy="{y}" r="6" fill="#285a9b"/>',
                f'<text x="{x(lo):.2f}" y="{y+44}" font-size="13" text-anchor="middle">{lo:.3f} ms</text>',
                f'<text x="620" y="{y-34}" font-size="13" text-anchor="middle">0</text>',
                f'<text x="{x(hi):.2f}" y="{y+44}" font-size="13" text-anchor="middle">{hi:.3f} ms</text>']
    svg+=['<text x="28" y="464" font-size="13">Green: provisional equivalence margin max(0.1 ms, 1%). Positive means A slower than B; no code changed.</text></g></svg>']
    (HERE/'paired-precision.svg').write_text('\n'.join(svg))
    lines += ['![Paired timing uncertainty](paired-precision.svg)', '']
path=HERE/'measured-experiment-protocol.md'
prefix=path.read_text().split('<!-- GENERATED MEASUREMENTS -->')[0]
path.write_text(prefix+'<!-- GENERATED MEASUREMENTS -->\n\n'+'\n'.join(lines)+'\n')
locators=[screen_path, BASE/'representative-calibration-v2/ncu/counters.ncu-rep',
          BASE/'representative-calibration-v2/systems/city256-late-debris/trace.nsys-rep']
# Captures were already hashed by their collectors. Reuse those identities; no large re-read during a GPU campaign.
manifest={'screen':{'path':str(screen_path),'sha256':hashlib.sha256(screen_path.read_bytes()).hexdigest()},
          'ncu':{'path':str(locators[1]),'sha256':screen['counters']['report_sha256']},
          'systems':{'path':str(locators[2]),'sha256':screen['systems']['scenarios'][0]['trace_sha256']},
          'availability':'Large original captures remain in out/; this report archives compact JSON/CSV and exact source locators.'}
(evidence/'capture-locators.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(path)
