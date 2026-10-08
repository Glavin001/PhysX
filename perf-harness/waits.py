#!/usr/bin/env python3
"""waits.py <run dir> [--show N]: per-tick host waits (CUMETAL_TRACE_SYNC) and GPU busy (CUMETAL_TRACE_COMMITS)
inside VIBE_PERF_MARKERS ticks. Prints mean waits/tick by reason and position, and N example ticks' timelines."""
import sys, re, collections, statistics as st, argparse
ap=argparse.ArgumentParser();ap.add_argument('run');ap.add_argument('--show',type=int,default=2);ap.add_argument('--skip',type=int,default=5)
a=ap.parse_args()
ticks=[];cur=None;syncs=[];cbs=[];drains=[]
for line in open(a.run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        cur=[int(re.search(r'monotonic_ns=(\d+)',line).group(1)),None,int(re.search(r'frame=(\d+)',line).group(1))];continue
    if line.startswith('event=end stage=physics_step') and cur:
        cur[1]=int(re.search(r'monotonic_ns=(\d+)',line).group(1));ticks.append(cur);cur=None;continue
    if line.startswith('CUMETAL_SYNC'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv)
        syncs.append((float(d['start_s'])*1e9,float(d['wait_us']),d.get('reason'),d.get('stream'),line.strip()))
    elif line.startswith('CUMETAL_COMMIT'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv)
        cbs.append((float(d['commit_s'])*1e9,float(d['gpu_start_s'])*1e9,float(d['gpu_end_s'])*1e9,d.get('kernels','')))
    elif line.startswith('CUMETAL_DRAIN'):
        drains.append(line.strip())
ticks=ticks[a.skip:]
per=[];byreason=collections.Counter();byreasonus=collections.Counter()
for k,(b,e,f) in enumerate(ticks):
    ws=[s for s in syncs if b<=s[0]<=e]
    iv=sorted((max(c[1],b),min(c[2],e)) for c in cbs if c[2]>b and c[1]<e)
    busy=0;last=None
    for s0,s1 in iv:
        if last is None or s0>last: busy+=s1-s0;last=s1
        elif s1>last: busy+=s1-last;last=s1
    ncb=sum(1 for c in cbs if b<=c[0]<=e)
    per.append(dict(wall=(e-b)/1e6,busy=busy/1e6,waits=len(ws),waitms=sum(w[1] for w in ws)/1e3,cbs=ncb))
    for w in ws: byreason[w[2]]+=1;byreasonus[w[2]]+=w[1]
    if k<a.show:
        print(f'--- tick {f}: wall {(e-b)/1e6:.2f} ms busy {busy/1e6:.2f} cbs {ncb}')
        ev=[(s[0],'WAIT',f'{s[2]} {s[1]:.0f}us stream={s[3]}') for s in ws]+[(c[0],'CB',f'gpu {max(0,(c[1]-c[0]))/1e3:.0f}us-late run {(c[2]-c[1])/1e3:.0f}us {c[3][:150]}') for c in cbs if b<=c[0]<=e]
        for t,kind,txt in sorted(ev): print(f'  {(t-b)/1e6:7.3f} {kind:4s} {txt}')
n=len(per)
print(f'ticks {n}: wall {st.mean(p["wall"] for p in per):.2f} busy {st.mean(p["busy"] for p in per):.2f} idle {st.mean(p["wall"]-p["busy"] for p in per):.2f} waits {st.mean(p["waits"] for p in per):.1f} waitms {st.mean(p["waitms"] for p in per):.2f} cbs {st.mean(p["cbs"] for p in per):.1f}')
for r in byreason: print(f'  {r}: {byreason[r]/n:.2f}/tick {byreasonus[r]/n/1e3:.2f} ms/tick')
