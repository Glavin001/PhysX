#!/usr/bin/env python3
"""zones.py <bench.log>... : per-class (split/break/quiet) tick stats and mean zone ms on split ticks.
split = cluster count rose this tick."""
import json,re,sys,collections,statistics as st
def pct(v,p):
    v=sorted(v); return v[min(len(v)-1,int(p*len(v)))] if v else 0
for path in sys.argv[1:]:
    rows=[json.loads(l[5:]) for l in open(path,errors='replace') if l.startswith('TICK ')]
    cls=collections.defaultdict(list);prev=None
    for r in rows:
        m=re.search(r'clusters (\d+)',r.get('native',''));c=int(m.group(1)) if m else 0
        k='quiet'
        if prev is not None:
            if c>prev[0]: k='split'
            elif r['broken_bonds']>prev[1]: k='break'
        cls[k].append(r);prev=(c,r['broken_bonds'])
    print(path)
    for k in ('split','break','quiet'):
        v=[r['total'] for r in cls[k]]
        if v: print(f"  {k:5s} n={len(v):4d} p50 {pct(v,.5):6.2f} p90 {pct(v,.9):6.2f} p99 {pct(v,.99):6.2f} max {max(v):6.2f} mean {st.mean(v):6.2f}")
    def zones(rs):
        Z=collections.defaultdict(float);C=collections.defaultdict(float)
        for r in rs:
            for part in r.get('stage','').split(' | '):
                m=re.match(r'(\S+) ([0-9.]+) \((\d+)x\)',part.strip())
                if m: Z[m.group(1)]+=float(m.group(2));C[m.group(1)]+=int(m.group(3))
        n=max(1,len(rs));return {k:(Z[k]/n,C[k]/n) for k in Z}
    zs,zq=zones(cls['split']),zones(cls['quiet'])
    if cls['split']:
        print(f"  mean zones: split (ms, calls) | quiet (ms, calls)")
        for z,(t,c) in sorted(zs.items(),key=lambda x:-x[1][0])[:int(__import__('os').environ.get('TOP','32'))]:
            q=zq.get(z,(0,0));print(f"    {t:7.2f} {c:5.1f}x | {q[0]:6.2f} {q[1]:4.1f}x  {z}")
