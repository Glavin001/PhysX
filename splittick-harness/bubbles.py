#!/usr/bin/env python3
"""bubbles.py <run dir>: per tick class, time the host spends blocked in waits while the GPU is idle
(completion latency + GPU-side scheduling bubbles), vs GPU busy during waits, vs host-not-waiting time."""
import re,json,bisect,collections,sys,statistics as st
run=sys.argv[1]
ticks=[];cbs=[];syncs=[];cls={};prev=None
for line in open(run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        ticks.append([int(re.search(r'frame=(\d+)',line).group(1)),int(re.search(r'monotonic_ns=(\d+)',line).group(1)),None])
    elif line.startswith('event=end stage=physics_step'):
        ticks[-1][2]=int(re.search(r'monotonic_ns=(\d+)',line).group(1))
    elif line.startswith('CUMETAL_COMMIT'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv);cbs.append((float(d['gpu_start_s'])*1e9,float(d['gpu_end_s'])*1e9))
    elif line.startswith('CUMETAL_SYNC'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv);syncs.append((float(d['start_s'])*1e9,float(d['wait_us'])*1e3))
    elif line.startswith('TICK '):
        r=json.loads(line[5:]);c=int(re.search(r'clusters (\d+)',r['native']).group(1))
        k='quiet'
        if prev is not None:
            if c>prev[0]:k='split'
            elif r['broken_bonds']>prev[1]:k='break'
        cls[r['tick']]=k;prev=(c,r['broken_bonds'])
# merged GPU busy intervals
cbs.sort();busy=[]
for s,e in cbs:
    if e<=s:continue
    if busy and s<=busy[-1][1]:busy[-1][1]=max(busy[-1][1],e)
    else:busy.append([s,e])
bs=[b[0] for b in busy]
def busy_in(a,b):
    t=0;i=max(0,bisect.bisect_right(bs,a)-1)
    while i<len(busy) and busy[i][0]<b:
        t+=max(0,min(b,busy[i][1])-max(a,busy[i][0]));i+=1
    return t
syncs.sort();R=collections.defaultdict(lambda:collections.defaultdict(list))
for f,b,e in ticks[5:]:
    if e is None or f not in cls:continue
    g=cls[f];wait=0;wbusy=0
    for s,w in syncs[bisect.bisect_left(syncs,(b,)):bisect.bisect_right(syncs,(e,))]:
        wait+=w;wbusy+=busy_in(s,s+w)
    tb=busy_in(b,e)
    R[g]['wall'].append((e-b)/1e6);R[g]['busy'].append(tb/1e6);R[g]['wait'].append(wait/1e6)
    R[g]['wait_gpu_busy'].append(wbusy/1e6);R[g]['wait_gpu_idle'].append((wait-wbusy)/1e6)
    R[g]['host_run_gpu_idle'].append(((e-b)-wait-(tb-wbusy))/1e6)
for g in ('split','break','quiet'):
    if g in R:print(g,len(R[g]['wall']),' '.join(f'{k} {st.mean(v):.2f}' for k,v in R[g].items()))
