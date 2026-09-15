#!/usr/bin/env python3
"""Tabulate a warm nine-window screen: per window, A0/B/A1 mean and max complete_step_ms,
60 Hz misses, and (contract v3/v4) the candidate's force relative L2 and health drift."""
import json, statistics, sys
from pathlib import Path
root = Path(sys.argv[1]); arms = ['A0', 'B', 'A1']
windows = sorted({p.name.rsplit('-', 1)[0] for p in root.iterdir() if p.is_dir() and p.name.rsplit('-', 1)[-1] in arms})
print('| window | A0 mean | B mean | A1 mean | A0 max | B max | A1 max | misses A0/B/A1 | B force relL2 | B health drift | B check |')
print('|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---|')
for w in windows:
    row = {}
    for arm in arms:
        f = root / f'{w}-{arm}' / 'replay.json'
        if not f.exists(): row[arm] = None; continue
        s = [x['complete_step_ms'] for x in json.load(open(f))['samples'] if x.get('measured')]
        row[arm] = (statistics.mean(s), max(s), sum(v > 16.67 for v in s), len(s))
    fmt = lambda a, i: f'{row[a][i]:.2f}' if row[a] else '—'
    miss = '/'.join(f'{row[a][2]}' if row[a] else '—' for a in arms) + (f' of {row["B"][3]}' if row['B'] else '')
    rel = hd = chk = '—'
    pf = root / f'{w}-B-physical.json'
    if pf.exists():
        d = json.load(open(pf)); chk = d.get('status', '—'); na = d.get('numerical_arrays', {})
        if 'bond-forces' in na: rel = f"{na['bond-forces'].get('relative_l2', float('nan')):.2e}"
        if 'health' in na: hd = f"{na['health'].get('maximum_absolute', float('nan')):.1e}"
    print(f'| {w} | {fmt("A0",0)} | {fmt("B",0)} | {fmt("A1",0)} | {fmt("A0",1)} | {fmt("B",1)} | {fmt("A1",1)} | {miss} | {rel} | {hd} | {chk} |')
