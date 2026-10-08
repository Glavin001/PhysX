#!/usr/bin/env python3
"""kern.py <run dir> [--top N] [--ticks a-b] [--scenario S]
Per-kernel GPU time per tick from a CUMETAL_TRACE_GPU=1 VIBE_PERF_MARKERS=1 perf_bench log.
Kernel completion lines are attributed to the tick whose begin marker precedes them.
Reports mean ms/tick and launches/tick over quiet ticks (no bond broken) and fracture ticks."""
import sys, re, collections, csv, os, argparse
ap = argparse.ArgumentParser(); ap.add_argument('run'); ap.add_argument('--top', type=int, default=40)
ap.add_argument('--scenario', default=None); ap.add_argument('--skip', type=int, default=5)
a = ap.parse_args()
log = os.path.join(a.run, 'bench.log')
ticks = collections.OrderedDict(); cur = None
kre = re.compile(r'CUMETAL_PROVENANCE event=kernel_launch kernel="([^"]*)".*?duration_ns=(-?\d+)')
for line in open(log, errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        cur = int(re.search(r'frame=(\d+)', line).group(1)); ticks[cur] = collections.defaultdict(lambda: [0, 0])
        continue
    if line.startswith('event=end stage=physics_step'):
        continue
    m = kre.search(line)
    if m and cur is not None:
        d = ticks[cur][m.group(1)]; d[0] += 1; d[1] += max(0, int(m.group(2)))
scen = a.scenario
if not scen:
    scen = [f[:-4] for f in os.listdir(a.run) if f.endswith('.csv')][0]
rows = {int(r['tick']): r for r in csv.DictReader(open(os.path.join(a.run, scen + '.csv')))}
prev = None; fr = set()
for t in sorted(rows):
    b = int(rows[t]['broken_bonds'])
    if prev is not None and b > prev: fr.add(t)
    prev = b
keys = list(ticks)[a.skip:]
groups = {'quiet': [t for t in keys if t not in fr], 'fracture': [t for t in keys if t in fr]}
for g, ts in groups.items():
    if not ts: continue
    tot = collections.defaultdict(lambda: [0, 0])
    for t in ts:
        for k, (n, ns) in ticks[t].items(): tot[k][0] += n; tot[k][1] += ns
    alln = sum(v[0] for v in tot.values()); allns = sum(v[1] for v in tot.values())
    wall = [float(rows[t]['total_ms']) for t in ts if t in rows]
    print(f'== {g}: {len(ts)} ticks, {alln/len(ts):.0f} launches/tick, GPU {allns/len(ts)/1e6:.2f} ms/tick (sum of kernel durations), wall mean {sum(wall)/max(1,len(wall)):.2f} ms (traced)')
    for k, (n, ns) in sorted(tot.items(), key=lambda kv: -kv[1][1])[:a.top]:
        print(f'  {ns/len(ts)/1e3:9.1f} us/tick {n/len(ts):7.1f} x/tick  {ns/max(n,1)/1e3:8.1f} us/launch  {k[:110]}')
