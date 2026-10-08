#!/usr/bin/env python3
"""gaps.py <run dir> [--csv scenario] [--skip N]: decompose each marked tick's wall time
(CUMETAL_TRACE_COMMITS + CUMETAL_TRACE_SYNC + VIBE_PERF_MARKERS) into
 busy  : GPU executing some command buffer
 sched : a command buffer was committed and the previous one had finished, but it had not started
 host  : no committed-unstarted work (the GPU waits for the host to encode/commit)
Also: command buffers/tick, empty (no kernel) buffers/tick, blocking waits and wake latency
(wait end minus the GPU end of the last buffer that finished before it)."""
import re,sys,json,argparse,collections,statistics as st,bisect
ap=argparse.ArgumentParser();ap.add_argument('run');ap.add_argument('--skip',type=int,default=5);ap.add_argument('--cls',default=None)
a=ap.parse_args()
ticks=[];cur=None;cbs=[];syncs=[];rows={}
for line in open(a.run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        m1=re.search(r'monotonic_ns=(\d+)',line);m2=re.search(r'frame=(\d+)',line)
        cur=[int(m1.group(1)),None,int(m2.group(1))] if m1 and m2 else None
    elif line.startswith('event=end stage=physics_step') and cur:
        m1=re.search(r'monotonic_ns=(\d+)\s*$',line)
        if m1: cur[1]=int(m1.group(1));ticks.append(cur)
        cur=None
    elif line.startswith('CUMETAL_COMMIT'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv)
        if not all(k in d for k in ('commit_s','gpu_start_s','gpu_end_s')):continue
        try: float(d['commit_s']);float(d['gpu_start_s']);float(d['gpu_end_s'])
        except ValueError: continue
        cbs.append((float(d['commit_s'])*1e9,float(d['gpu_start_s'])*1e9,float(d['gpu_end_s'])*1e9,d.get('kernels','')))
    elif line.startswith('CUMETAL_SYNC'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv)
        try: float(d['start_s']);float(d['wait_us'])
        except (KeyError,ValueError): continue
        s=float(d['start_s'])*1e9;syncs.append((s,s+float(d['wait_us'])*1e3,d.get('reason')))
    elif line.startswith('TICK '):
        try: x=json.loads(line[5:])
        except ValueError: continue
        m=re.search(r'clusters (\d+)',x.get('native',''));it=re.search(r'it (\d+)',x.get('native',''))
        rows[x['tick']]=(int(m.group(1)) if m else 0,x['broken_bonds'],x['total'],int(it.group(1)) if it else 0,x.get('awake_rigid',0))
cbs.sort();syncs.sort();ck=[c[0] for c in cbs];sk=[s[0] for s in syncs]
def klass(t):
    if t not in rows or t-1 not in rows:return 'quiet'
    c,b,_,_,_=rows[t];pc,pb,_,_,_=rows[t-1]
    return 'split' if c>pc else 'break' if b>pb else 'quiet'
out=collections.defaultdict(lambda:collections.defaultdict(list))
for b,e,f in ticks[a.skip:]:
    if not e:continue
    k=klass(f)
    sel=[c for c in cbs[bisect.bisect_left(ck,b-100e6):bisect.bisect_right(ck,e)] if c[2]>b]
    # timeline sweep over [b,e] in 1us bins is slow; do interval logic
    busy=0;sched=0
    events=sorted(sel,key=lambda c:c[1])
    prev_end=b
    for c in events:
        s0=max(c[1],b);s1=min(c[2],e)
        if s1<=s0:
            prev_end=max(prev_end,c[2]);continue
        ready=max(c[0],prev_end,b)   # committed and GPU free
        if s0>ready: sched+=s0-ready
        busy+=max(0,s1-max(s0,prev_end)) if s1>prev_end else 0
        prev_end=max(prev_end,s1)
    wall=e-b
    ws=syncs[bisect.bisect_left(sk,b):bisect.bisect_right(sk,e)]
    wake=[]
    for s0,s1,r in ws:
        ends=[c[2] for c in sel if c[2]<=s1]
        if ends: wake.append((s1-max(ends))/1e3)
    ncb=sum(1 for c in sel if b<=c[0]<=e);nem=sum(1 for c in sel if b<=c[0]<=e and c[3] in ('','-'))
    o=out[k];o['wall'].append(wall/1e6);o['busy'].append(busy/1e6);o['sched'].append(sched/1e6);o['host'].append((wall-busy-sched)/1e6)
    o['cbs'].append(ncb);o['empty'].append(nem);o['waits'].append(len(ws));o['wake'].extend(wake)
    o['iters'].append(rows.get(f,(0,0,0,0,0))[3]);o['awake'].append(rows.get(f,(0,0,0,0,0))[4])
for k,o in out.items():
    n=len(o['wall']);m=lambda x:st.mean(x) if x else float('nan')
    print(f"{k:6s} n={n:5d} wall {m(o['wall']):.2f} (p50 {st.median(o['wall']):.2f}) busy {m(o['busy']):.2f} sched {m(o['sched']):.2f} host {m(o['host']):.2f} | cbs {m(o['cbs']):.1f} empty {m(o['empty']):.1f} waits {m(o['waits']):.1f} wake p50 {st.median(o['wake']) if o['wake'] else 0:.0f}us | iters {m(o['iters']):.1f} awake {m(o['awake']):.0f}")
