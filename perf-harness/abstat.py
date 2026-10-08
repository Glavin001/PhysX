#!/usr/bin/env python3
"""abstat.py <tag>...: per-run and pooled tick stats from TICK lines (VIBE_PERF_ALL_TICKS=1).
Ticks are split (cluster count rose), break (bonds broke, no split) or quiet."""
import json,re,sys,glob,os,statistics as st
R='/Users/glavin/Development/vibe-land/target/perf-tools/steady/runs'
def q(v,p): v=sorted(v); return v[min(len(v)-1,int(round(p*(len(v)-1))))] if v else float('nan')
for tag in sys.argv[1:]:
    pools={'all':[],'split':[],'break':[],'quiet':[]};bonds=[]
    for d in sorted(glob.glob(f'{R}/{tag}.*'),key=lambda x:int(x.rsplit('.',1)[1])):
        f=d+'/bench.log'
        if not os.path.exists(f):continue
        rows=[json.loads(l[5:]) for l in open(f,errors='replace') if l.startswith('TICK ')]
        if not rows:continue
        prev=None;runs={'all':[],'split':[],'break':[],'quiet':[]}
        for x in rows:
            m=re.search(r'clusters (\d+)',x.get('native',''));c=int(m.group(1)) if m else 0;x['c']=c
            runs['all'].append(x['total'])
            if prev:
                k='split' if c>prev['c'] else 'break' if x['broken_bonds']>prev['broken_bonds'] else 'quiet'
                runs[k].append(x['total'])
            prev=x
        bonds.append(rows[-1]['broken_bonds']-rows[0]['broken_bonds'])
        a=runs['all'];print(f"  {os.path.basename(d):22s} p50 {q(a,.5):6.2f} p95 {q(a,.95):6.2f} p99 {q(a,.99):6.2f} max {max(a):6.1f} | split n={len(runs['split'])} p50 {q(runs['split'],.5):5.1f} p90 {q(runs['split'],.9):5.1f} | quiet p50 {q(runs['quiet'],.5):5.2f} | bonds {bonds[-1]}")
        for k in pools:pools[k]+=runs[k]
    a=pools['all']
    if a:print(f"{tag:24s} POOLED p50 {q(a,.5):6.2f} p95 {q(a,.95):6.2f} p99 {q(a,.99):6.2f} max {max(a):6.1f} | split n={len(pools['split'])} p50 {q(pools['split'],.5):5.1f} p90 {q(pools['split'],.9):5.1f} max {max(pools['split'] or [0]):5.1f} | break p50 {q(pools['break'],.5):5.1f} | quiet p50 {q(pools['quiet'],.5):5.2f} p90 {q(pools['quiet'],.9):5.2f} | bonds {bonds}")
