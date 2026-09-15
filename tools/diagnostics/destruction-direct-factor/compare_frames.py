#!/usr/bin/env python3
"""Compare two native demo frame CSVs (A control, B candidate): physical
histories (bonds broken per tick, post-correction breaks, clusters, contacts,
corrections) must match exactly; timing and iteration columns are reported."""
import csv, sys, statistics
def load(p):
    return list(csv.DictReader(open(p)))
a, b = load(sys.argv[1]), load(sys.argv[2])
n = min(len(a), len(b)); print(f'ticks A={len(a)} B={len(b)} compared={n}')
phys = ['bonds_broken', 'post_correction_bonds_broken', 'logical_clusters', 'contacts_total', 'correction_status']
phys = [c for c in phys if c in a[0] and c in b[0]]
mism = {c: [] for c in phys}
for i in range(n):
    for c in phys:
        if a[i][c] != b[i][c]: mism[c].append(i)
for c in phys:
    print(f'{c:32} mismatching ticks: {len(mism[c])}' + (f' first at {mism[c][:5]}' if mism[c] else ''))
def col(rows, c): return [float(r[c]) for r in rows[:n]]
for c in ('complete_step_ms', 'physics_step_ms', 'stress_iterations'):
    if c in a[0]:
        xa, xb = col(a, c), col(b, c)
        print(f'{c:20} A mean {statistics.mean(xa):9.3f} max {max(xa):9.3f} | B mean {statistics.mean(xb):9.3f} max {max(xb):9.3f}')
        if c == 'complete_step_ms':
            ma, mb = sum(1 for v in xa if v > 16.667), sum(1 for v in xb if v > 16.667)
            print(f'{"":20} >16.67ms: A {ma}/{n}  B {mb}/{n}')
tot_a = sum(col(a, 'bonds_broken')); tot_b = sum(col(b, 'bonds_broken'))
print(f'total bonds broken A {tot_a:.0f} B {tot_b:.0f}')
