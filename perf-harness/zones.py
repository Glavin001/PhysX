#!/usr/bin/env python3
"""zones.py <run dir> <scenario>: mean engine zones (VIBE_PHYSX_PROFILE=1) over fracture ticks vs others."""
import sys,re,csv,collections
run,scen=sys.argv[1],sys.argv[2]
rows={int(r['tick']):r for r in csv.DictReader(open(f'{run}/{scen}.csv'))}
prev=None;fr=set()
for t in sorted(rows):
    b=int(rows[t]['broken_bonds'])
    if prev is not None and b>prev: fr.add(t)
    prev=b
groups={'fracture':collections.defaultdict(float),'other':collections.defaultdict(float)};n=collections.Counter();tot=collections.defaultdict(float)
for line in open(f'{run}/{scen}.stages.txt'):
    parts=line.split(' | ');t=int(line.split()[0]);g='fracture' if t in fr else 'other'
    n[g]+=1;tot[g]+=float(line.split()[1])
    for p in parts[1:]:
        m=re.match(r'(.+) ([\d.]+) \(([\d.]+)x\)',p.strip())
        if m: groups[g][m.group(1)]+=float(m.group(2))
for g in groups:
    if not n[g]:continue
    print(f'== {g}: {n[g]} ticks, mean tick {tot[g]/n[g]:.2f} ms')
    for k,v in sorted(groups[g].items(),key=lambda kv:-kv[1])[:22]: print(f'  {v/n[g]:7.2f} {k}')
