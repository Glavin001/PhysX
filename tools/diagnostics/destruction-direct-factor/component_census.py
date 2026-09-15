#!/usr/bin/env python3
"""Per-component work census from a PHYSX_COMPONENT_WORK_OUTPUT capture (components.jsonl).
Buckets components by node count and reports their share of solve cycles, sweeps and
iterations, for the solves in the given step range (late window by default)."""
import json, sys, collections
path = sys.argv[1]; lo = int(sys.argv[2]) if len(sys.argv) > 2 else 0; hi = int(sys.argv[3]) if len(sys.argv) > 3 else 10**9
buckets = [(1, 1), (2, 7), (8, 31), (32, 127), (128, 511), (512, 1023), (1024, 10**9)]
def bucket(n):
    for a, b in buckets:
        if a <= n <= b: return f'{a}-{b}' if b < 10**9 else f'{a}+'
agg = collections.defaultdict(lambda: collections.Counter()); solves = set(); totals = collections.Counter()
for line in open(path):
    r = json.loads(line)
    if r['record'] == 'total':
        if lo <= r['solve'] < hi: solves.add(r['solve']); totals['components'] += r['components']
        continue
    if not (lo <= r['solve'] < hi): continue
    b = bucket(r['nodes']); c = agg[b]
    c['count'] += 1; c['cycles'] += r.get('cta_cycles', 0); c['iterations'] += r.get('iterations', 0)
    c['sweeps'] += r.get('residual_sweeps', 0) + r.get('verification_sweeps', 0) + r.get('direction_sweeps', 0)
    c['anchored'] += r.get('anchored', 0); c['unconverged'] += 0 if r.get('converged', 1) else 1
    c['maxcycles'] = max(c['maxcycles'], r.get('cta_cycles', 0)); c['unmeasured'] += 1 if r['path'] == 2 else 0
allc = sum(c['cycles'] for c in agg.values()) or 1
print(f'solves {len(solves)}  components/solve {totals["components"]/max(1,len(solves)):.0f}')
print('%-10s %9s %8s %8s %8s %9s %8s %10s'%('nodes','count/solve','cycles%','maxMcyc','iters','sweeps','anchored','unmeasured'))
for a, b in buckets:
    k = f'{a}-{b}' if b < 10**9 else f'{a}+'; c = agg.get(k)
    if not c: continue
    n = max(1, len(solves))
    print('%-10s %9.0f %8.1f %8.2f %8.1f %9.1f %8.0f %10.0f'%(k, c['count']/n, 100*c['cycles']/allc, c['maxcycles']/1e6, c['iterations']/max(1,c['count']), c['sweeps']/max(1,c['count']), c['anchored']/n, c['unmeasured']/n))
