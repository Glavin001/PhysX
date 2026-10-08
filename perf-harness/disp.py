#!/usr/bin/env python3
"""disp.py <run dir>: dispatches and named kernels per marked tick from CUMETAL_TRACE_COMMITS (batch kernels= lists)."""
import sys,re,collections,bisect
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
        try: cbs.append((float(d['commit_s'])*1e9,int(d['dispatches']),d.get('kernels','-'),d.get('kind')))
        except (KeyError,ValueError): pass
cbs.sort();ck=[c[0] for c in cbs];n=0;tot=0;names=collections.Counter();kinds=collections.Counter()
for b,e in ticks[5:]:
    sel=cbs[bisect.bisect_left(ck,b):bisect.bisect_right(ck,e)];n+=1
    for c in sel:
        tot+=c[1];kinds[c[3]]+=1
        for k in c[2].split(','):
            if k!='-':names[k]+=1
print(f'ticks {n}: dispatches/tick {tot/n:.1f} named kernels/tick {sum(names.values())/n:.1f} cbs/tick {sum(kinds.values())/n:.1f}',{k:round(v/n,1) for k,v in kinds.items()})
for k,v in names.most_common(40): print(f'  {v/n:6.1f} {k}')
