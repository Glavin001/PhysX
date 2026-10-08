#!/usr/bin/env python3
"""tl.py <run dir> <frame>: one marked tick's command buffers, waits and drains, in time order."""
import sys,re
run,frame=sys.argv[1],sys.argv[2]
rows=[];on=False
for l in open(run+'/bench.log',errors='replace'):
    if l.startswith(f'event=begin stage=physics_step frame={frame} '):on=True;t0=int(re.search(r'monotonic_ns=(\d+)',l).group(1))/1e9;continue
    if l.startswith(f'event=end stage=physics_step frame={frame} '):
        t1=int(re.search(r'monotonic_ns=(\d+)',l).group(1))/1e9;break
    if not on:continue
    d=dict(kv.split('=',1) for kv in l.split()[1:] if '=' in kv)
    try:
        if l.startswith('CUMETAL_COMMIT'): rows.append((float(d['commit_s']),'CB %-6s st=%s n=%-3s w=%s late=%5.0f run=%5.0f %s'%(d['kind'],d['stream'][-4:],d['dispatches'],d.get('waits','?'),(float(d['gpu_start_s'])-float(d['commit_s']))*1e6,(float(d['gpu_end_s'])-float(d['gpu_start_s']))*1e6,d.get('kernels','')[:100])))
        elif l.startswith('CUMETAL_SYNC'): rows.append((float(d['start_s']),'   WAIT %s %sus st=%s'%(d['reason'],d['wait_us'],d['stream'][-4:])))
        elif l.startswith('CUMETAL_DRAIN'): rows.append((rows[-1][0] if rows else t0,'   '+l.strip()))
    except (KeyError,ValueError): pass
for t,s in sorted(rows,key=lambda r:r[0]): print('%7.3f %s'%((t-t0)*1e3,s))
print('wall %.3f ms'%((t1-t0)*1e3))
