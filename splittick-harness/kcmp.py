#!/usr/bin/env python3
"""kcmp.py <run>...: per-launch median/min GPU duration (us) and launches per split tick for key kernels (KERN=1 runs)."""
import sys,re,json,collections,statistics as st
KEYS=['prepareCandidateBodies','prepareCorrectionBodyInputs','prepareDeferredCorrectionBodyInputs','massProperties','transferClusterMotion',
 'captureClusterMotion','radix_digit_scatter','radix_digit_count','select_flagged_offsets','provisionalTopologyMotion','componentStressSolve',
 'solveBlockPartition','installCorrectionBodyInputs','gatherCorrectionOwnerMetadata','carryAcceptedPass','beginDeviceStressTopology']
kre=re.compile(r'kernel="([^"]*)".*?duration_ns=(-?\d+)')
for run in sys.argv[1:]:
    cur=None;cls={};prev=None;per=collections.defaultdict(list);cnt=collections.Counter();splits=0
    for line in open(run+'/bench.log',errors='replace'):
        if line.startswith('event=begin stage=physics_step'):cur=int(re.search(r'frame=(\d+)',line).group(1));continue
        if line.startswith('TICK '):
            r=json.loads(line[5:]);c=int(re.search(r'clusters (\d+)',r['native']).group(1))
            if prev is not None and c>prev:cls[r['tick']]='split'
            prev=c;continue
        if 'event=kernel_launch' in line and cur is not None:
            m=kre.search(line)
            if not m:continue
            name=m.group(1)
            for k in KEYS:
                if k in name:per[(k,cur)].append(int(m.group(2))/1e3);break
    split_ticks=[t for t,v in cls.items() if v=='split']
    print(run,'split ticks',len(split_ticks))
    for k in KEYS:
        d=[x for (kk,t),v in per.items() if kk==k and cls.get(t)=='split' for x in v]
        if d:print(f'  {k:38s} n/split {len(d)/max(1,len(split_ticks)):4.1f} median {st.median(d):7.1f} min {min(d):7.1f} sum/split {sum(d)/max(1,len(split_ticks)):8.1f}')
