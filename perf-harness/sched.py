#!/usr/bin/env python3
"""sched.py <run dir>: split GPU scheduling delay per marked tick into idle-start latency (buffer
committed while the GPU was idle: start - commit) and queue gaps (committed while the previous
buffer ran: start - previous end)."""
import sys,re,bisect,statistics as st
run=sys.argv[1];ticks=[];cur=None;cbs=[]
for line in open(run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        m=re.search(r'monotonic_ns=(\d+)',line);cur=int(m.group(1)) if m else None
    elif line.startswith('event=end stage=physics_step') and cur:
        m=re.search(r'monotonic_ns=(\d+)\s*$',line)
        if m: ticks.append((cur,int(m.group(1))))
        cur=None
    elif line.startswith('CUMETAL_COMMIT'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv)
        try: cbs.append((float(d['gpu_start_s'])*1e9,float(d['gpu_end_s'])*1e9,float(d['commit_s'])*1e9))
        except (KeyError,ValueError): pass
cbs.sort();cs=[c[0] for c in cbs];idle=[];queued=[];nidle=[];nq=[]
for b,e in ticks[5:]:
    sel=cbs[bisect.bisect_left(cs,b):bisect.bisect_right(cs,e)];prev_end=None;i_sum=q_sum=0;ni=nqq=0
    for s0,s1,c in sel:
        if prev_end is not None and c<prev_end: q_sum+=max(0,s0-prev_end);nqq+=1
        else: i_sum+=max(0,s0-c);ni+=1
        prev_end=max(prev_end or 0,s1)
    idle.append(i_sum/1e6);queued.append(q_sum/1e6);nidle.append(ni);nq.append(nqq)
print(f'{run.split("/")[-1]}: idle-start {st.mean(idle):.2f} ms/tick over {st.mean(nidle):.1f} buffers ({1e3*st.mean(idle)/max(1e-9,st.mean(nidle)):.0f} us each), queue gaps {st.mean(queued):.2f} ms/tick over {st.mean(nq):.1f} buffers ({1e3*st.mean(queued)/max(1e-9,st.mean(nq)):.0f} us each)')
