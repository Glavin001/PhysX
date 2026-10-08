#!/usr/bin/env python3
"""kern.py <run dir> [--top N] [--cls split]: per-kernel GPU time (CUMETAL_TRACE_GPU+PROVENANCE) per tick class.
Classes from TICK lines: split (clusters rose), break (bonds broke), quiet. Also prints split-minus-quiet deltas."""
import sys,re,json,collections,argparse
ap=argparse.ArgumentParser();ap.add_argument('run');ap.add_argument('--top',type=int,default=45);ap.add_argument('--skip',type=int,default=5)
a=ap.parse_args()
ticks=collections.OrderedDict();cur=None;cls={};prev=None
kre=re.compile(r'kernel="([^"]*)".*?duration_ns=(-?\d+)')
for line in open(a.run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        cur=int(re.search(r'frame=(\d+)',line).group(1));ticks[cur]=collections.defaultdict(lambda:[0,0]);continue
    if line.startswith('TICK '):
        r=json.loads(line[5:]);m=re.search(r'clusters (\d+)',r.get('native',''));c=int(m.group(1)) if m else 0
        k='quiet'
        if prev is not None:
            if c>prev[0]:k='split'
            elif r['broken_bonds']>prev[1]:k='break'
        cls[r['tick']]=k;prev=(c,r['broken_bonds']);continue
    if cur is not None and 'event=kernel_launch' in line:
        m=kre.search(line)
        if m: d=ticks[cur][m.group(1)];d[0]+=1;d[1]+=max(0,int(m.group(2)))
keys=list(ticks)[a.skip:]
agg={}
for g in ('split','break','quiet'):
    ts=[t for t in keys if cls.get(t)==g]
    if not ts:continue
    tot=collections.defaultdict(lambda:[0,0])
    for t in ts:
        for k,(n,ns) in ticks[t].items():tot[k][0]+=n;tot[k][1]+=ns
    agg[g]=(len(ts),tot)
    print(f'== {g}: {len(ts)} ticks, {sum(v[0] for v in tot.values())/len(ts):.0f} launches/tick, GPU {sum(v[1] for v in tot.values())/len(ts)/1e6:.2f} ms/tick')
if 'split' in agg and 'quiet' in agg:
    ns_,ts_=agg['split'];nq,tq=agg['quiet']
    rows=[]
    for k in set(ts_)|set(tq):
        s=ts_.get(k,[0,0]);q=tq.get(k,[0,0])
        rows.append((s[1]/ns_-q[1]/nq,s[0]/ns_-q[0]/nq,s[1]/ns_,s[0]/ns_,k))
    rows.sort(reverse=True)
    print(f'== split minus quiet (per tick): top {a.top}')
    print('  delta_us  delta_n   split_us  split_n  kernel')
    for d,dn,s,sn,k in rows[:a.top]:print(f'  {d/1e3:8.1f} {dn:8.1f} {s/1e3:9.1f} {sn:7.1f}  {k[:120]}')
    print('  total delta us %.1f, launches %.1f'%(sum(r[0] for r in rows)/1e3,sum(r[1] for r in rows)))
