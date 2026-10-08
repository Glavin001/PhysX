#!/usr/bin/env python3
"""tstat.py <run dir|tag>...: per-scenario tick stats from TICK lines (VIBE_PERF_ALL_TICKS=1):
quiet / break (bonds broke) / split (cluster count rose) classes; p50/p95, % over 8.3 and 16.7 ms,
stress iterations and awake bodies. A tag expands to every runs/<tag>.N (pooled)."""
import sys,json,re,glob,os,collections,statistics as st
R='/Users/glavin/Development/vibe-land/target/perf-tools/steady-tick/runs'
def q(v,p): v=sorted(v); return v[min(len(v)-1,int(round(p*(len(v)-1))))] if v else float('nan')
for arg in sys.argv[1:]:
    dirs=[arg] if os.path.isdir(arg) else sorted(glob.glob(f'{R}/{arg}.*'))
    pools=collections.defaultdict(lambda:collections.defaultdict(list))
    for d in dirs:
        prev={}
        for l in open(d+'/bench.log',errors='replace'):
            if not l.startswith('TICK '):continue
            x=json.loads(l[5:]);s=x['scenario'];n=x['native']
            c=int(re.search(r'clusters (\d+)',n).group(1));it=int(re.search(r'it (\d+)',n).group(1))
            p=prev.get(s)
            k='split' if p and c>p[0] else 'break' if p and x['broken_bonds']>p[1] else 'quiet'
            prev[s]=(c,x['broken_bonds'])
            for kk in (k,'all'):
                pools[s][kk].append((x['total'],it,x['awake_rigid']))
    for s,cl in pools.items():
        for k in ('all','quiet','break','split'):
            v=cl.get(k)
            if not v:continue
            t=[a for a,_,_ in v];its=[b for _,b,_ in v];aw=[c for _,_,c in v]
            print(f"{os.path.basename(arg):14s} {s:14s} {k:5s} n={len(v):5d} p50 {q(t,.5):6.2f} p95 {q(t,.95):6.2f} mean {st.mean(t):6.2f} >8.3 {100*sum(a>8.33 for a in t)/len(t):5.1f}% >16.7 {100*sum(a>16.67 for a in t)/len(t):5.1f}% | iters mean {st.mean(its):4.1f} ==16 {100*sum(i>=16 for i in its)/len(its):4.0f}% | awake p50 {q(aw,.5)}")
