#!/usr/bin/env python3
"""stages.py <run dir>...: per-tick kernel GPU time and launch counts grouped by pipeline stage, from a
CUMETAL_TRACE_GPU=1 CUMETAL_PROVENANCE=1 VIBE_PERF_MARKERS=1 run (each kernel its own command buffer)."""
import sys,re,collections
S=[('stress',r'Nv5Blast|StressSolve|persistentStress|componentStress|NativeSettled|accumulateSquared|finalizeIsland|setTolerance|initializeSolve|initializeStatus|NativeWarm|NativeStress|exportPhysical|applyStressDamage|beginDeviceStress|publishNativeHierarchy'),
   ('destruction',r'physx12_GLOBAL|destructionContactGraph|destructionPreSolve|committedChanges|NativeIterationLimits|buildNativeContactInputs|registerNativeMotion|clearNewNativeNodeRange|updateNodes|chooseCommit|beginTransaction|record|Topology|MotionAllocation'),
   ('broadphase',r'radixSort|SAP|Sap|AABB|Pairs|nativePair|Histogram|translateAABBs|markCreated|markUpdated|clearNewFlag|accumulateReports|updateHandles|copyReports|outputEndPts|computeEndPts|initializeSapBox|Region|FoundPairs|LostPairs|MergeLost'),
   ('narrowphase',r'Nphase|Manifold|prepareLostFound|removeContactManagers|FrictionPatch|contactReduction|finishContacts|compaction|convex|Convex|sphere|capsule|box|mesh|heightfield'),
   ('solver',r'solve|Solver|Slab|Partition|constraint|Constraint|Batch|artic|writeback|writeBack|ZeroBodies|bodyInputAndRanks|preIntegration|initStaticKinematics|propagate|computeAverage|Threshold|dmaBack|Contact'),
   ('integration',r'integrate|updateTransformCache|updateBodies|updateShapes|mergeTransform|mergeChanged|updateChanged|Frozen|MemCopy|Balanced'),
   ('cumetal_graph',r'^cm_graph|cm_')]
for run in sys.argv[1:]:
    tick=None;per=collections.defaultdict(lambda:collections.defaultdict(lambda:[0,0]));order=[]
    kre=re.compile(r'kernel="([^"]*)".*?duration_ns=(-?\d+)')
    for line in open(run+'/bench.log',errors='replace'):
        if line.startswith('event=begin stage=physics_step'):
            m=re.search(r'frame=(\d+)',line)
            if m: tick=int(m.group(1));order.append(tick)
            continue
        if 'CUMETAL_PROVENANCE event=kernel_launch' in line and tick is not None:
            m=kre.search(line)
            if not m:continue
            k=m.group(1);st='other'
            for name,pat in S:
                if re.search(pat,k):st=name;break
            d=per[tick][st];d[0]+=1;d[1]+=max(0,int(m.group(2)))
    ticks=order[5:];n=len(ticks);tot=collections.defaultdict(lambda:[0,0])
    for t in ticks:
        for st,(c,ns) in per[t].items():tot[st][0]+=c;tot[st][1]+=ns
    print(f'{run.split("/")[-1]}: {n} ticks, {sum(v[0] for v in tot.values())/n:.0f} launches/tick, {sum(v[1] for v in tot.values())/n/1e6:.2f} ms GPU/tick')
    for st,(c,ns) in sorted(tot.items(),key=lambda kv:-kv[1][1]): print(f'  {st:14s} {ns/n/1e3:7.0f} us/tick {c/n:6.1f} launches/tick')
