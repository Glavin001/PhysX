#!/usr/bin/env python3
"""splitstats.py <run dir>...: split-tick and quiet-tick stats per run, pooled per variant.tag."""
import json,re,sys,collections,statistics as st,os
def pct(v,p):v=sorted(v);return v[min(len(v)-1,int(p*len(v)))]
pool=collections.defaultdict(lambda:collections.defaultdict(list))
for run in sys.argv[1:]:
    rows=[json.loads(l[5:]) for l in open(run+'/bench.log',errors='replace') if l.startswith('TICK ')]
    prev=None;C=collections.defaultdict(list)
    for r in rows:
        c=int(re.search(r'clusters (\d+)',r['native']).group(1));k='quiet'
        if prev is not None:
            if c>prev[0]:k='split'
            elif r['broken_bonds']>prev[1]:k='break'
        C[k].append(r['total']);prev=(c,r['broken_bonds'])
    name=os.path.basename(run.rstrip('/'));key=name.rsplit('.',1)[0]
    for k,v in C.items():pool[key][k]+=v
    s,q=C['split'],C['quiet']
    print(f'{name:28s} split n={len(s):3d} mean {st.mean(s):6.2f} p50 {pct(s,.5):6.2f} p90 {pct(s,.9):6.2f} max {max(s):6.2f} | quiet mean {st.mean(q):5.2f} p50 {pct(q,.5):5.2f} | excess {st.mean(s)-st.mean(q):6.2f}')
print('pooled:')
for key,C in pool.items():
    s,q=C['split'],C['quiet']
    print(f'{key:28s} split n={len(s):3d} mean {st.mean(s):6.2f} p50 {pct(s,.5):6.2f} p90 {pct(s,.9):6.2f} max {max(s):6.2f} | quiet mean {st.mean(q):5.2f} p50 {pct(q,.5):5.2f} | excess {st.mean(s)-st.mean(q):6.2f}')
