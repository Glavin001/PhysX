#!/usr/bin/env python3
"""cbcat.py <run dir>: GPU time per command-buffer category per tick class (TRACE=1 run), split minus quiet."""
import re,json,bisect,collections,sys
run=sys.argv[1]
CATS=[('stressTopology','beginDeviceStressTopology'),('transaction','beginTransaction'),('allocation','beginNativeMotionAllocation'),
 ('candidates','prepareCandidateBodies'),('stressSolve','initializeSolve|persistentStressSolve|finishComponentStress|resetNativeStress'),
 ('islandRepair','componentKeys|componentMembers'),('contactGraph','connectRetainedSlots|validateRetainedUpdates|retire,|compress'),
 ('accept','acceptClusterBindings|prepareNativeCorrectionAcceptance|chooseCommit'),('publish','mergePostCorrectionStatus|gatherFinal'),
 ('destrEval','observeNativeClusters|prepareLoads|routeContacts|finishStatus|evaluateBondMaterials|emitTopologyEdits|provisionalTopologyMotion|inspectStress|commitMaterialState|checkUnchangedMotionCommit'),
 ('install','installCorrectionBodyInputs|installNativeCollisionOwners|gatherCorrectionOwnerMetadata|clearNewNativeNodeRange'),
 ('sleepApi','setRigidDynamic|gatherNativeSleepPoses'),
 ('broadphase','SAP|AABB|Aabb|Histogram|radixSort|nativePair|Regions|FoundPairs|accumulateReports|copyReports|translateAABBs'),
 ('narrowphase','Nphase|Manifold|LostFound|FrictionPatches|ContactManagers|buildNativeContactInputs|compressContact|Midphase|Contact'),
 ('solver','solve|Solve|integrate|Integration|constraint|Constraint|Partition|Slab|propagate|Velocity|rigidSum|preIntegration|updateBodies|Transform|Frozen|Island|island')]
def cat(ks):
    for n,p in CATS:
        if re.search(p,ks):return n
    return 'other' if ks.strip('-,') else 'empty'
ticks=[];cbs=[];cls={};prev=None
for line in open(run+'/bench.log',errors='replace'):
    if line.startswith('event=begin stage=physics_step'):
        ticks.append([int(re.search(r'frame=(\d+)',line).group(1)),int(re.search(r'monotonic_ns=(\d+)',line).group(1)),None])
    elif line.startswith('event=end stage=physics_step'):
        ticks[-1][2]=int(re.search(r'monotonic_ns=(\d+)',line).group(1))
    elif line.startswith('CUMETAL_COMMIT'):
        d=dict(kv.split('=',1) for kv in line.split()[1:] if '=' in kv)
        cbs.append((float(d['commit_s'])*1e9,(float(d['gpu_end_s'])-float(d['gpu_start_s']))*1e6,int(d.get('dispatches',0)),d.get('kernels','')))
    elif line.startswith('TICK '):
        r=json.loads(line[5:]);c=int(re.search(r'clusters (\d+)',r['native']).group(1))
        k='quiet'
        if prev is not None:
            if c>prev[0]:k='split'
            elif r['broken_bonds']>prev[1]:k='break'
        cls[r['tick']]=k;prev=(c,r['broken_bonds'])
cbs.sort();ck=[c[0] for c in cbs]
A={g:collections.defaultdict(lambda:[0.0,0,0]) for g in ('split','quiet','break')};N=collections.Counter()
for f,b,e in ticks[5:]:
    if e is None or f not in cls:continue
    g=cls[f];N[g]+=1
    for c in cbs[bisect.bisect_left(ck,b):bisect.bisect_right(ck,e)]:
        a=A[g][cat(c[3])];a[0]+=c[1];a[1]+=c[2];a[2]+=1
print('category        split_us  quiet_us  delta_us | split disp  quiet disp | split cbs')
keys=sorted(set(A['split'])|set(A['quiet']),key=lambda k:-(A['split'][k][0]/N['split']-A['quiet'][k][0]/N['quiet']))
T=[0,0]
for k in keys:
    s=A['split'][k];q=A['quiet'][k];ds=s[0]/N['split'];dq=q[0]/N['quiet'];T[0]+=ds;T[1]+=dq
    print(f'{k:14s} {ds:9.0f} {dq:9.0f} {ds-dq:9.0f} | {s[1]/N["split"]:9.1f} {q[1]/N["quiet"]:10.1f} | {s[2]/N["split"]:6.1f}')
print(f'{"total":14s} {T[0]:9.0f} {T[1]:9.0f} {T[0]-T[1]:9.0f}')
