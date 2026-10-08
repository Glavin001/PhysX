#!/usr/bin/env python3
"""timeline.py <run dir> <tick>: waits and command buffers of one tick (TRACE=1 run)."""
import sys,re
run,tick=sys.argv[1],int(sys.argv[2])
b=e=None;syncs=[];cbs=[]
for line in open(run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step') and f'frame={tick} ' in line: b=int(re.search(r'monotonic_ns=(\d+)',line).group(1))
    elif line.startswith('event=end stage=physics_step') and f'frame={tick} ' in line: e=int(re.search(r'monotonic_ns=(\d+)',line).group(1))
    elif line.startswith('CUMETAL_SYNC'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv);syncs.append((float(d['start_s'])*1e9,float(d['wait_us']),d.get('reason'),d.get('stream')))
    elif line.startswith('CUMETAL_COMMIT'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv);cbs.append((float(d['commit_s'])*1e9,float(d['gpu_start_s'])*1e9,float(d['gpu_end_s'])*1e9,d.get('dispatches'),d.get('kernels','')))
ev=[(s[0],f'WAIT {s[2]:13s} {s[1]:7.0f}us  ends {(s[0]+s[1]*1e3-b)/1e6:7.3f}') for s in syncs if b<=s[0]<=e]
ev+=[(c[0],f'CB   n={c[3]:>3s} gpu {(c[1]-b)/1e6:7.3f}-{(c[2]-b)/1e6:7.3f} ({(c[2]-c[1])/1e3:6.0f}us) {c[4][:160]}') for c in cbs if b<=c[0]<=e]
print(f'tick {tick} wall {(e-b)/1e6:.2f} ms')
for t,txt in sorted(ev):print(f'{(t-b)/1e6:8.3f} {txt}')
