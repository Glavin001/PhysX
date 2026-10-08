#!/usr/bin/env python3
"""waitsites.py <run dir>: host waits per tick class, keyed by reason + last kernel committed before the wait
(TRACE=1 run). Mean count and mean wait us per tick; plus mean GPU-idle gap after each wait's end."""
import re,json,bisect,collections,sys
run=sys.argv[1]
ticks=[];cbs=[];syncs=[];cls={};prev=None
for line in open(run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        ticks.append([int(re.search(r'frame=(\d+)',line).group(1)),int(re.search(r'monotonic_ns=(\d+)',line).group(1)),None])
    elif line.startswith('event=end stage=physics_step'):
        ticks[-1][2]=int(re.search(r'monotonic_ns=(\d+)',line).group(1))
    elif line.startswith('CUMETAL_COMMIT'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv)
        ks=[k for k in d.get('kernels','').split(',') if k and k!='-' and not k.startswith('cm_graph')]
        cbs.append((float(d['commit_s'])*1e9,ks[-1] if ks else '-',float(d['gpu_start_s'])*1e9))
    elif line.startswith('CUMETAL_SYNC'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv);syncs.append((float(d['start_s'])*1e9,float(d['wait_us']),d['reason']))
    elif line.startswith('TICK '):
        r=json.loads(line[5:]);c=int(re.search(r'clusters (\d+)',r['native']).group(1))
        k='quiet'
        if prev is not None:
            if c>prev[0]:k='split'
            elif r['broken_bonds']>prev[1]:k='break'
        cls[r['tick']]=k;prev=(c,r['broken_bonds'])
cbs.sort();ck=[c[0] for c in cbs];gs=sorted(c[2] for c in cbs)
agg={g:collections.defaultdict(lambda:[0,0.0,0.0]) for g in ('split','quiet','break')};n=collections.Counter()
for f,b,e in ticks[5:]:
    if e is None or f not in cls:continue
    g=cls[f];n[g]+=1;last='-'
    for s in syncs[bisect.bisect_left(syncs,(b,)):bisect.bisect_right(syncs,(e,))]:
        j=bisect.bisect_right(ck,s[0])-1
        # last named kernel committed before the wait
        while j>=0 and cbs[j][1]=='-' and ck[j]>b:j-=1
        key=(s[2],cbs[j][1][:60] if j>=0 else '-')
        end=s[0]+s[1]*1e3;nx=gs[bisect.bisect_right(gs,end)] if bisect.bisect_right(gs,end)<len(gs) else end
        a=agg[g][key];a[0]+=1;a[1]+=s[1];a[2]+=min(nx-end,5e6)/1e3
for g in ('split','quiet'):
    print(f'== {g} ({n[g]} ticks): count/tick  wait_us/tick  gpu_idle_after_us/tick  reason  last-kernel')
    for k,(c,w,idle) in sorted(agg[g].items(),key=lambda kv:-kv[1][1]):
        if c/n[g]>=0.05:print(f'  {c/n[g]:5.2f} {w/n[g]:8.0f} {idle/n[g]:8.0f}  {k[0]:12s} {k[1]}')
