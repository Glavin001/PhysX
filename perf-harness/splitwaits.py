#!/usr/bin/env python3
"""splitwaits.py <run dir>...: host waits (CUMETAL_TRACE_SYNC), GPU busy and command buffers per tick,
for split ticks (cluster count rose), break ticks and quiet ticks (VIBE_PERF_MARKERS + ALL_TICKS)."""
import re,sys,json,bisect,collections,statistics as st
for run in sys.argv[1:]:
    rows={};ticks={};cur=None;syncs=[];cbs=[]
    for line in open(run+'/bench.log',errors='replace'):
        if line.startswith('TICK '):
            x=json.loads(line[5:]);m=re.search(r'clusters (\d+)',x.get('native',''));rows[x['tick']]=(int(m.group(1)) if m else 0,x['broken_bonds'],x['total'])
        elif line.startswith('event=begin stage=physics_step'):
            cur=int(re.search(r'frame=(\d+)',line).group(1));ticks[cur]=[int(re.search(r'monotonic_ns=(\d+)',line).group(1)),None]
        elif line.startswith('event=end stage=physics_step') and cur in ticks:
            ticks[cur][1]=int(re.search(r'monotonic_ns=(\d+)',line).group(1))
        elif line.startswith('CUMETAL_SYNC'):
            d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv);syncs.append((float(d['start_s'])*1e9,float(d['wait_us']),d['reason']))
        elif line.startswith('CUMETAL_COMMIT'):
            d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv);cbs.append((float(d['commit_s'])*1e9,float(d['gpu_start_s'])*1e9,float(d['gpu_end_s'])*1e9))
    syncs.sort();sk=[s[0] for s in syncs];cbs.sort();ck=[c[0] for c in cbs]
    cls=collections.defaultdict(list);prev=None
    for t in sorted(rows):
        if prev is not None and t in ticks and ticks[t][1]:
            c,b,_=rows[t];pc,pb,_=rows[prev]
            cls['split' if c>pc else 'break' if b>pb else 'quiet'].append(t)
        prev=t
    print(run.split('/')[-1])
    for k in ('split','break','quiet'):
        ts=cls[k]
        if not ts:continue
        W=[];R=collections.Counter();B=[];N=[];wall=[]
        for t in ts:
            b,e=ticks[t];ws=syncs[bisect.bisect_left(sk,b):bisect.bisect_right(sk,e)];W.append(len(ws));R.update(w[2] for w in ws)
            sel=cbs[bisect.bisect_left(ck,b-50e6):bisect.bisect_right(ck,e)]
            iv=sorted((max(c[1],b),min(c[2],e)) for c in sel if c[2]>b and c[1]<e);busy=0;last=None
            for s0,s1 in iv:
                if last is None or s0>last: busy+=s1-s0;last=s1
                elif s1>last: busy+=s1-last;last=s1
            B.append(busy/1e6);N.append(bisect.bisect_right(ck,e)-bisect.bisect_left(ck,b));wall.append((e-b)/1e6)
        n=len(ts);print(f'  {k:6s} n={n:4d} wall p50 {st.median(wall):6.2f} busy {st.mean(B):6.2f} waits {st.mean(W):5.1f} cbs {st.mean(N):5.0f} | '+' '.join(f'{r} {R[r]/n:.1f}' for r in sorted(R)))
