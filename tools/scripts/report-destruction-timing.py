#!/usr/bin/env python3
"""Deterministic HTML/Markdown/JSON timing report from immutable native captures.

Re-running report generation does not run physics. Durations vary between physics
runs; the report preserves repeats, raw evidence and separate profiling modes.
"""
import argparse,bisect,collections,csv,gzip,hashlib,html,importlib.util,json,math,re,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('accounting',Path(__file__).with_name('analyze-native-gpu-profile.py'))
a=importlib.util.module_from_spec(spec);spec.loader.exec_module(a)

def require(ok,reason):
    if not ok:raise ValueError(reason)

def sha(path):
    h=hashlib.sha256()
    with path.open('rb') as f:
        for block in iter(lambda:f.read(1024*1024),b''):h.update(block)
    return h.hexdigest()

def stats(v):
    v=sorted(v)
    if not v:return None
    # Nearest-rank percentiles, explicitly shared by every table and JSON field.
    return dict(n=len(v),min=v[0],mean=statistics.mean(v),p50=v[max(0,math.ceil(.50*len(v))-1)],
                p95=v[max(0,math.ceil(.95*len(v))-1)],p99=v[max(0,math.ceil(.99*len(v))-1)],max=v[-1])

def subtract(base,removed):
    result=[];cut=a.union(removed)
    for lo,hi in a.union(base):
        cursor=lo
        for x,y in cut:
            if y<=cursor:continue
            if x>=hi:break
            if x>cursor:result.append((cursor,min(x,hi)))
            cursor=max(cursor,y)
        if cursor<hi:result.append((cursor,hi))
    return result

# Only siblings in this hierarchy are disjoint. Children replace their parent;
# parent remainders are retained, never silently renamed to GPU execution time.
TREE={
 'checkpoint':{},'submit':{},
 'finishAndReserve':{'finishDetail.waitForGpu':{},'finishDetail.reserveBodies':{
     'finishDetail.growMotionSlots':{},'finishDetail.requestReadback':{},'finishDetail.allocateNativeBodies':{},
     'finishDetail.uploadBindings':{},'finishDetail.publishReservation':{}}},
 'initializeReserved':{},'publishReservedMetadata':{},'collisionBindings':{},'correctionBodies':{},'preparationCompletion':{'compatibility.requestReadback':{},'compatibility.allocateNativeBodies':{},'compatibility.publishReservation':{}},'applyBindings':{
     'applyDetail.validateOwners':{},'applyDetail.scheduleOwners':{},'applyDetail.migrateShapes':{
         'migrateDetail.refilter':{},'migrateDetail.retireContacts':{},'migrateDetail.registerOwner':{},
         'migrateDetail.actorLinks':{},'migrateDetail.queryMirror':{}}},
 'restoreInstall':{},'resetContactCaches':{},'correctedCollisionSolve':{},'acceptCorrection':{}}
LABELS={
 'checkpoint':('Checkpoint moving-body state','CPU submission → GPU copy; save state for possible rewind'),
 'submit':('Submit contact loads and destruction','CPU queues GPU loads, stress, material and topology work'),
 'finishDetail.waitForGpu':('Wait for GPU destruction result','CPU blocked/spinning until required GPU work completes; not extra GPU work'),
 'finishDetail.growMotionSlots':('Grow native motion address capacity','CPU grants unused indices; GPU storage allocation/upload; no spare simulated bodies'),
 'finishDetail.requestReadback':('Assign GPU motion slots and observe compatibility requests','GPU compacts and assigns slots; GPU → CPU selected indices/metadata and completion dependency'),
 'finishDetail.allocateNativeBodies':('Create compatibility records for selected fragments','CPU PhysX body/lifecycle records at GPU-selected indices'),
 'finishDetail.uploadBindings':('Upload allocated body bindings','CPU → GPU indices for the reserved bodies'),
 'finishDetail.publishReservation':('Validate compatibility registration','CPU dispatch → GPU failure merge; preserves device allocation verdict'),
 'finishDetail.reserveBodies.other':('Other reservation bookkeeping','Uninstrumented remainder within CPU reservation scope'),
 'finishAndReserve.other':('Other destruction completion bookkeeping','Remaining host scope around destruction completion'),
 'publishReservedMetadata':('Update fragment compatibility metadata','CPU registered-body range and suppression of placeholder uploads; GPU motion already initialized'),
 'initializeReserved':('Submit fragment initialization','CPU dispatch/lifecycle; GPU initializes and validates without a stage-local readback'),
 'collisionBindings':('Prepare chunk collision ownership','CPU dispatch + GPU persistent-shape ownership preparation'),
 'correctionBodies':('Prepare corrected motion states','CPU dispatch + GPU cluster/body preparation'),
 'preparationCompletion':('Validate completed GPU preparation','CPU checks observed verdicts and constructs compatibility objects; legacy/manual preparation also waits for GPU completion'),
 'preparationCompletion.other':('Validate GPU preparation verdicts','CPU validation/bookkeeping; legacy/manual paths may also wait; compatibility construction children are separate'),
 'compatibility.requestReadback':('Observe GPU-selected fragment requests','GPU → CPU compact metadata after complete GPU collision and motion preparation'),
 'compatibility.allocateNativeBodies':('Construct fragment compatibility objects','CPU PhysX body/lifecycle records after GPU preparation; still required before corrected simulation'),
 'compatibility.publishReservation':('Validate compatibility construction','CPU result and exceptional GPU failure merge; physical GPU allocation remains authoritative'),
 'applyBindings':('Apply ownership/lifecycle changes','CPU PhysX ownership and lifecycle bridge'),
 'applyDetail.validateOwners':('Validate fragment owners and shape identities','CPU validates the migration batch against compatibility actors and persistent shapes'),
 'applyDetail.scheduleOwners':('Activate fragment scheduler metadata','CPU updates kinematic/dynamic type and wake/island bookkeeping; physical state is GPU-owned'),
 'migrateDetail.refilter':('Mark changed collision filtering','CPU broad-phase lifecycle bookkeeping for migrating persistent shapes'),
 'migrateDetail.retireContacts':('Retire old-owner contact managers','CPU releases shape interactions, contact managers and lost-touch bookkeeping'),
 'migrateDetail.registerOwner':('Update narrow-phase ownership mirror','CPU updates persistent narrow-phase owner references; no geometry upload'),
 'migrateDetail.actorLinks':('Update shape/actor links and query-bound membership','CPU transfers element ownership and registers query-bound tracking'),
 'migrateDetail.queryMirror':('Update persistent query-owner observation','CPU owner-lookup and compatibility shape-array updates; query geometry, handles and bounds persist'),
 'applyDetail.migrateShapes.other':('Other shape migration work','CPU validation, target storage and gaps around instrumented migration operations'),
 'applyBindings.other':('Other ownership bridge work','GPU-to-CPU metadata observation, completion waits and remaining host bookkeeping'),
 'restoreInstall':('Rewind and install fractured motion','CPU dispatch + GPU checkpoint restore and owner installation'),
 'resetContactCaches':('Invalidate incompatible contact caches','CPU dispatch + GPU contact/friction cache reset'),
 'correctedCollisionSolve':('Resimulate changed interaction','CPU task scheduling + GPU collision, constraints and motion solve'),
 'acceptCorrection':('Accept corrected step','GPU commit/status completion and CPU publication'),
 'trial.other':('Trial physics and remaining scene tasks','Original physics pass plus task/driver gaps outside destruction scopes')}
STAGES={'allocationAndPreparation':'GPU allocation, collision ownership preparation and corrected-motion preparation',
 'allocationAndPreparationRetry':'GPU allocation and preparation retry after exceptional storage growth',
 'motionAllocation':'GPU fragment motion allocation transaction',
 'motionAllocationRetry':'GPU allocation retry after exceptional storage growth',
 'contactLoads':'Convert solved contact impulses into chunk loads',
 'stress':'Iterative stress solve to convergence', 'materials':'Evaluate material damage and fracture',
 'topologyAndCandidates':'Connectivity, cluster mass and fragment candidates',
 'commitAndStressTopology':'Commit changes and rebuild stress topology',
 'rewindState':'GPU checkpoint restore (device-to-device copies)',
 'installFragments':'GPU fragment motion installation before replay',
 'installOwners':'GPU shape ownership installation before replay',
 'finalSplitState':'GPU end-state copy for final splits (no time rewind)',
 'finalSplitFragments':'GPU final-split motion installation after replay',
 'finalSplitOwners':'GPU final-split shape ownership after replay'}
DETAILS={
 'preallocateContactManagers':'Allocate contact-manager storage',
 'registerContactManagers':'Register contact managers','registerInteractions':'Register body/shape interactions',
 'registerSceneInteractions':'Register scene interactions','postBroadPhase':'Complete broad phase and callbacks',
 'broadPhaseWait':'Wait for GPU broad phase and pair publication',
 'postBroadPhaseStage2':'Broad-phase completion stage 2','postBroadPhaseStage3':'Broad-phase completion stage 3',
 'postNarrowPhase':'Complete narrow phase','islandInsertion':'Insert contact dependencies into islands',
 'islandGen':'Generate simulation islands','postIslandGen':'Finish island scheduling',
 'beforeSolver':'Prepare dynamics tasks','updateDynamics':'Submit dynamics/constraint solve',
 'updateDynamicsPostPartitioning':'Finish constraint partitioning','processLostContacts':'Dispatch lost contacts',
 'processLostContacts2':'Lost-contact completion stage 2','processLostContacts3':'Lost-contact completion stage 3',
 'postSolver':'Finish motion integration and solver tasks'}

def partition(boundary,by_name):
    out={}
    def visit(parent,tree,remainder):
        children=[]
        for name,sub in tree.items():
            span=a.union(by_name.get(name,[]))
            require(a.length(subtract(span,parent))==0,f'{name} escapes parent scope')
            children+=span
            if sub:visit(span,sub,name+'.other')
            else:out[name]=a.length(span)/1e6
        require(sum(b-a0 for a0,b in children)==a.length(children),'Overlapping sibling phase scopes; cannot add wall time')
        out[remainder]=a.length(subtract(parent,children))/1e6
    visit(boundary,TREE,'trial.other')
    require(abs(sum(out.values())-a.length(boundary)/1e6)<1e-8,'Wall partition does not close')
    return out

def windows(frames):
    breaks=[i for i,r in enumerate(frames) if int(r['bonds_broken'])]
    corrections=[i for i,r in enumerate(frames) if int(r['resim_passes'])]
    first=breaks[0] if breaks else len(frames)
    return {'all':list(range(len(frames))),'startup':[0], 'preimpact':list(range(1,first)),
            'corrected':corrections,'after_last_fracture':list(range(breaks[-1]+1,len(frames))) if breaks else [],
            'last_2s':list(range(max(1,len(frames)-120),len(frames))), 'post_startup':list(range(1,len(frames)))}

def load_run(directory,record):
    for name,digest in record['files'].items():require(sha(directory/name)==digest,f'Capture hash mismatch: {directory/name}')
    s=json.loads((directory/'native.summary.json').read_text());f=list(a.read_csv(directory/'native.frames.csv'))
    require(s['status']=='completed' and len(f)==s['frames'],'Incomplete capture')
    for i,r in enumerate(f):
        require(int(r['step'])==i and r['stress_converged']=='1' and 0<=int(r['resim_passes'])<=1,'Invalid accepted simulation frame')
        require(int(r['simulation_end_ns'])>int(r['simulation_start_ns']),'Invalid simulation timestamps')
        require(float(r['physics_step_ms'])>0,'Invalid simulation duration')
        if 'stress_passes' in r:
            require(int(r['stress_passes'])==1+int(r['resim_passes']),'Missing/excess stress evaluation')
            require(0<=int(r['post_correction_bonds_broken'])<=int(r['bonds_broken']),'Invalid post-correction fracture accounting')
    require(s['consumer_pose_readback_bytes']==0 and s['gpu_rendered_frames']==0,'Timing fixture accidentally enables pose observation/rendering')
    signature=[[int(r[k]) for k in ['step','bonds_broken','resim_passes','logical_clusters']] for r in f]
    w=windows(f)
    return {'summary':s,'frames':f,'windows':w,'signature':sha_json(signature),'signature_rows':signature,
            'metrics':{key:stats([float(f[i]['physics_step_ms']) for i in indices]) for key,indices in w.items()},
            'worst_step':max(range(len(f)),key=lambda i:float(f[i]['physics_step_ms']))}

def sha_json(value):return hashlib.sha256(json.dumps(value,separators=(',',':')).encode()).hexdigest()

def validate_activity_status(status):
    require(status.get('schema')==2 and status.get('cupti_header_version',0)==status.get('cupti_runtime_version',-1) and status.get('cupti_runtime_version',0)>=130202,'Unqualified CUPTI header/runtime configuration')
    require(16*1024**2<=status.get('device_graph_buffer_bytes',0)<=4096*1024**2,'Missing or invalid CUPTI device-graph capacity')
    require(status['complete'] and status['records']>0 and status['dropped']==0 and status['invalid_timestamps']==0,'Incomplete CUPTI trace')


def validate_duration(manifest,frames):
    require(manifest['gpu_seconds']==manifest['seconds'],'Partial-duration GPU capture cannot qualify this report')
    require(len(frames)==manifest['seconds']*60,'Capture duration differs from campaign')

def validate_activity_census(status,rows,kernel_counts):
    require(rows==status['records'],'CUPTI activity row count differs from collector status')
    require(all(count>0 for count in kernel_counts),'Missing GPU kernel coverage in accepted simulation step')

def profile(directory,run,catalog):
    frames=run['frames'];n=len(frames);begins=[int(f['simulation_start_ns']) for f in frames];ends=[int(f['simulation_end_ns']) for f in frames]
    host=[[] for _ in frames];by=[collections.defaultdict(list) for _ in frames];outside=0
    for row in a.read_csv(directory/'native.phases.csv'):
        if row['accepted_step']!='1':outside+=1;continue
        i=int(row['step']);require(0<=i<n,'Bad phase step')
        lo,hi=int(row['start_ns']),int(row['end_ns'])
        require(hi>=lo,'Negative host scope')
        require(begins[i]<=lo<=hi<=ends[i],'Accepted host scope escaped simulation bracket')
        host[i].append(row);by[i][row['phase'].removeprefix('GpuDestruction.')].append((lo,hi))
    require(all('submit' in b and 'finishAndReserve' in b for b in by),'Required destruction phases missing')
    partitions=[partition([(begins[i],ends[i])],by[i]) for i in range(n)]
    stages=[collections.defaultdict(float) for _ in frames]
    for r in a.read_csv(directory/'native.phases.csv.device.csv'):
        if r['accepted_step']=='1':
            elapsed=float(r['cuda_elapsed_ms']);require(math.isfinite(elapsed) and elapsed>=0,'Invalid CUDA-event duration')
            require(0<=int(r['step'])<n,'CUDA-event step outside capture')
            stages[int(r['step'])][r['phase'].removeprefix('GpuDestruction.cuda.')]+=elapsed
    require(all('stress' in s for s in stages),'CUDA stress intervals missing')
    result={'wall_partition':partitions,'cuda_stages':list(map(dict,stages)),
            'host_cpu_core_ms':[a.exclusive_cpu(r) for r in host], 'outside_accepted_host_rows':outside,
            'timestamp_bookend_ms':stats([(ends[i]-begins[i])/1e6-float(frames[i]['physics_step_ms']) for i in range(n)])}
    detail={}
    for prefix in ['trialDetail.','detail.']:
        for key,label in DETAILS.items():
            name=prefix+key
            detail[name]={'label':label,'observed_wall_ms':[a.length(b.get(name,[]))/1e6 for b in by]}
    result['detail']=detail
    if not run['summary']['profile_gpu']:return result
    status=json.loads((directory/'native.activity.status.json').read_text())
    validate_activity_status(status)
    names={int(i):v.rstrip('\n') for i,v in (line.split('\t',1) for line in (directory/'native.activity.names.tsv').open())}
    categories={i:catalog.get(name,('unclassified',None))[0] for i,name in names.items()}
    busy=[[] for _ in frames];kernels=[[] for _ in frames];apis=[[] for _ in frames];waits=[[] for _ in frames]
    kernel_sum=[collections.defaultdict(float) for _ in frames];kernel_count=[collections.Counter() for _ in frames]
    transfers=[collections.Counter() for _ in frames];outside_device=collections.Counter();zero=0;activity_rows=0
    for row in a.read_csv(directory/'native.activity.csv'):
        activity_rows+=1
        start,end=int(row['start_ns']),int(row['end_ns']);kind=row['kind'];name=names[int(row['name_id'])]
        require(kind in ('A','K','C','M') and int(row['bytes'])>=0,'Unsupported activity record')
        require(end>=start and start>0,'Bad activity timestamps')
        if start==end:zero+=1;continue
        i=bisect.bisect_right(ends,start);matched=False
        while i<n and begins[i]<end:
            lo,hi=max(start,begins[i]),min(end,ends[i])
            if hi>lo:
                matched=True;span=(lo,hi)
                if kind=='A':
                    apis[i].append(span)
                    if 'Synchronize' in name or ('Memcpy' in name and 'Async' not in name):waits[i].append(span)
                else:
                    busy[i].append(span)
                    if kind=='K':
                        kernels[i].append(span);kernel_sum[i][name]+=(hi-lo)/1e6
                        if lo==start:kernel_count[i][name]+=1
                    elif lo==start:transfers[i][name]+=int(row['bytes'])
            i+=1
        if not matched:outside_device[kind]+=1
    validate_activity_census(status,activity_rows,[sum(counts.values()) for counts in kernel_count])
    metrics=[];regions={name:[] for name in ['trial.other',*TREE]};cats=collections.defaultdict(lambda:[0.0]*n)
    for i in range(n):
        total=(ends[i]-begins[i])/1e6;gpu=a.length(busy[i])/1e6;kernel=a.length(kernels[i])/1e6
        require(-1e-8<=kernel<=gpu+1e-8 and gpu<=total+1e-8,'GPU union escaped wall interval')
        api=a.length(apis[i])/1e6;no_gpu_wait=a.length(subtract(waits[i],busy[i]))/1e6
        metrics.append({'wall_ms':total,'kernel_union_ms':kernel,'copy_memset_only_ms':gpu-kernel,
                        'gpu_busy_ms':gpu,'no_gpu_activity_ms':total-gpu,'api_union_ms':api,'no_gpu_in_wait_api_ms':no_gpu_wait,
                        'kernel_calls':sum(kernel_count[i].values())})
        for name,ms in kernel_sum[i].items():cats[catalog.get(name,('unclassified',None))[0]][i]+=ms
        other=subtract([(begins[i],ends[i])],[span for key in TREE for span in by[i].get(key,[])])
        for key in regions:
            span=other if key=='trial.other' else by[i].get(key,[])
            wall=a.length(span)/1e6;active=a.length(a.intersect(span,busy[i]))/1e6
            regions[key].append({'wall_ms':wall,'gpu_busy_ms':active,'no_gpu_activity_ms':wall-active})
        for key in detail:
            detail[key].setdefault('gpu_overlap_ms',[]).append(a.length(a.intersect(by[i].get(key,[]),busy[i]))/1e6)
    totals=collections.defaultdict(float);counts=collections.Counter()
    for values in kernel_sum:
        for key,ms in values.items():totals[key]+=ms
    for values in kernel_count:counts.update(values)
    result.update(activity_status=status,gpu=metrics,gpu_regions=regions,kernel_categories=dict(cats),
                  kernels=[{'name':name,'category':catalog.get(name,('unclassified',None))[0],'source':catalog.get(name,('unclassified',None))[1],
                            'sum_ms':ms,'calls':counts[name]} for name,ms in sorted(totals.items(),key=lambda p:(-p[1],p[0]))],
                  transfer_bytes=list(map(dict,transfers)),outside_simulation_records=dict(outside_device),zero_duration_records=zero)
    return result

class Document:
    def __init__(self):self.md=[];self.htm=[]
    def title(self,text,level=2):self.md.append('#'*level+' '+text+'\n');self.htm.append(f'<h{level}>{html.escape(text)}</h{level}>')
    def text(self,text):self.md.append(text+'\n');self.htm.append('<p>'+html.escape(text)+'</p>')
    def table(self,head,rows):
        self.md += ['| '+' | '.join(head)+' |','|'+'|'.join('---' for _ in head)+'|',*['| '+' | '.join(map(str,r))+' |' for r in rows],'']
        self.htm.append('<div class="table"><table><thead><tr>'+''.join('<th>'+html.escape(h)+'</th>' for h in head)+'</tr></thead><tbody>'+''.join('<tr>'+''.join('<td>'+html.escape(str(c))+'</td>' for c in r)+'</tr>' for r in rows)+'</tbody></table></div>')
    def save(self,out):
        out.mkdir(parents=True,exist_ok=True);(out/'report.md').write_text('\n'.join(self.md))
        css='body{font:16px system-ui;max-width:1400px;margin:32px auto;padding:0 24px;color:#172b40;background:#f8fafc}h1{font-size:32px}h2{margin-top:40px;border-bottom:2px solid #b9d6e7;padding-bottom:8px}p{line-height:1.6;max-width:1100px}.table{overflow:auto;margin:18px 0}table{border-collapse:collapse;width:100%;background:white;font-size:14px}th{background:#123851;color:white;text-align:left;position:sticky;top:0}td,th{padding:9px 12px;border-bottom:1px solid #dce5ec}tr:nth-child(even){background:#eff5f8}td{font-variant-numeric:tabular-nums}td:first-child{min-width:180px}a{color:#086cac}@media print{body{font-size:11px}table{font-size:10px}th{position:static}h2{break-after:avoid}}'
        (out/'report.html').write_text('<!doctype html><html lang="en"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>PhysX GPU destruction timing</title><style>'+css+'</style><body><nav><a href="report.md">Markdown</a> · <a href="report.json.gz">Machine-readable data</a></nav>'+''.join(self.htm)+'</body></html>')

def fmt(x):return '—' if x is None else f'{x:.3f}'
def mean(v):return statistics.mean(v) if v else 0.0

def focused_case(manifest,runs):
    cases=manifest['config']['cases']
    require(bool(cases),'No configured scene for detailed profiling')
    case=cases[0]
    require(case['id'] in runs,'Configured focus scene has no captures')
    return case,runs[case['id']]

def render(manifest,runs,out):
    d=Document();d.title('PhysX GPU destruction — measured timing breakdown',1)
    cases=manifest['config']['cases'];focus,p=focused_case(manifest,runs);plain=p['plain'];phase=p['phases'][0];trace=p['gpu'][0]
    d.text(f"Detailed focus: {focus['label']} — {plain[0]['summary']['chunks']:,} chunks, {plain[0]['summary']['bonds']:,} bonds. All configured scenes appear in the comparison table; detailed sections use this first configured scene.")
    pooled=[float(f['physics_step_ms']) for r in plain for f in r['frames']];s=stats(pooled)
    stress=mean([v['stress'] for v in phase['profile']['cuda_stages']]);interval=mean([sum(v.values()) for v in phase['profile']['wall_partition']])
    d.text(f"The selected scene’s simulate/fetch subinterval averages {s['mean']:.3f} ms per step across {len(plain)} untraced repeats; the worst measured step is {s['max']:.3f} ms. {sum(x<1 for x in pooled)}/{len(pooled)} steps are below 1 ms. GPU stress occupies a mean {stress:.3f} ms of destruction-stream elapsed time in the separate host-scope capture ({100*stress/interval:.1f}% of its simulation bracket; this overlaps submission/wait).")
    if 'idle-1' in runs and 'idle-16' in runs:
        base=mean([r['metrics']['post_startup']['mean'] for r in runs['idle-1']['plain']]);big=mean([r['metrics']['post_startup']['mean'] for r in runs['idle-16']['plain']])
        d.text(f"The intact one-building control costs {base:.3f} ms after its first step; 16 intact buildings cost {big:.3f} ms ({big/base:.2f}× for 16× geometry). This measures an idle baseline of the current implementation, not a fundamental GPU latency floor. Idle controls do not establish active-destruction scalability.")
    if all(r['summary'].get('complete_timer_schema')==1 for r in plain):
        d.title('🎯 Authoritative complete advance — commands through committed completion')
        misses=sum(float(f['complete_step_ms'])>8 for r in plain for f in r['frames'])
        d.text(('❌ Deadline failed' if misses else '✅ Measured deadlines passed')+f': {misses} complete steps exceeded 8.0 ms. Every measured step is retained. Full plan and endurance qualification remain incomplete.')
        complete_rows=[]
        for i,r in enumerate(plain):
            metric=complete_step_metrics(r);frames=r['frames'];peak=max(frames,key=lambda f:float(f['complete_step_ms']))
            complete_rows.append([i+1,len(frames),fmt(metric['mean']),fmt(metric['max']),sum(float(f['complete_step_ms'])>8 for f in frames),peak['step'],fmt(float(peak['command_ms'])),fmt(float(peak['physics_step_ms'])),fmt(float(peak['completion_ms']))])
        d.table(['Untraced repeat','Steps','Mean ms','Peak ms','>8 ms','Peak step','CPU commands at peak ms','PhysX/destruction at peak ms','Completion at peak ms'],complete_rows)
        d.text('This is the deadline timer. It includes commands, insertion and mandatory completion in addition to simulate/fetch. The detailed CPU/GPU tables below subdivide simulate/fetch in separate profiling captures. These short runs do not establish the five × 60-second gate.')
    d.title('Measurement contract and validity')
    matches=all(all(r['signature_rows']==runs[c['id']]['plain'][0]['signature_rows'][:len(r['frames'])] for mode in ['plain','phases','gpu'] for r in runs[c['id']][mode]) for c in cases)
    d.table(['Check','Result'],[
        ['Capture completeness / recorded file hashes','PASS — every input capture hashed and validated'],
        ['Stress convergence / correction limit','PASS — every accepted step converged; at most one correction per step'],
        ['Fracture/cluster counter histories across repetitions and trace modes','MATCH across full-duration untraced, host-scope and GPU captures' if matches else 'DIFFER — comparisons below are workload-level; inspect report.json.gz signatures'],
        ['CPU observations / rendering / video encoding','Disabled in measured runs; compact SDK status observation remains outside simulate/fetch'],
        ['Wall-time partition / GPU overlap accounting','PASS — disjoint scope tree closes; GPU interval unions remain inside the measured bracket'],
        ['CUPTI loss / malformed timestamps','PASS — every full-duration GPU repetition has zero dropped records and zero invalid timestamps'],
        ['CUPTI configuration',f"Header/runtime API version {trace['profile']['activity_status'].get('cupti_runtime_version','unknown')}; device-graph trace buffer {trace['profile']['activity_status'].get('device_graph_buffer_bytes',0)//(1024*1024)} MiB per context. No solver or physical-input changes."],
        ['GPU process isolation evidence',manifest['monitor']],
        ['Determinism','Same input configuration and stable report generation. GPU timings are not deterministic; repeated measurements retain variation.']])
    d.text(f"Hardware: {manifest['runs'][0]['samples'][0]['devices'][0]['name']}; driver {manifest['runs'][0]['samples'][0]['driver']}. Revision {manifest['revision']}. {manifest['warmup']} All modes advance {manifest['seconds']} simulated seconds; {manifest.get('gpu_trials',1)} complete CUPTI repetitions per scene, at 60 Hz. This short diagnostic campaign is not the planned five × 60-second scale qualification.")
    d.text('The detailed profiling bracket starts immediately before scene.simulate and ends after blocking scene.fetchResults, including embedded destruction and correction. Scene construction, projectile creation before the step, compact post-step status observation, CSV output and GPU activity flush are outside this bracket. This is simulation cost, not the complete application tick. CPU profiling callbacks and concurrent CUPTI collection can still perturb the measured interval.')
    failures=manifest.get('prior_failure_evidence',{}).get('attempts',[])+manifest.get('failed_attempts',[])
    if failures:
        d.title('Earlier failed captures — excluded from measurements')
        d.text(f'{len(failures)} earlier capture attempts failed. Their recorded errors and activity status are retained below and in the machine-readable data. No failed capture contributes timings. Every GPU capture used below passed full-duration validation. Historical failure records alone do not establish their cause; consult the separate capture qualification record.')
        d.table(['Failed attempt','Exit','Step','Recorded error','Invalid activity timestamps'],[[r['name'],r.get('exit_code','interrupted'),r.get('failure_step','unknown'),r.get('error_line',r.get('campaign_error','See captured log')),r.get('activity_status',{}).get('invalid_timestamps','unknown')] for r in failures])
    d.title('Untraced simulate/fetch cost — subinterval of the complete advance')
    rows=[]
    for case in cases:
        rr=runs[case['id']]['plain'];values=[float(f['physics_step_ms']) for r in rr for f in r['frames']];v=stats(values)
        rows.append([case['label'],rr[0]['summary']['chunks'],rr[0]['summary']['bonds'],len(values),*[fmt(v[k]) for k in ['min','mean','p50','p95','p99','max']],sum(x>=1 for x in values),sum(x>1000/60 for x in values)])
    d.table(['Scene','Chunks','Bonds','Steps','Min ms','Mean ms','p50 ms','p95 ms','p99 ms','Max ms','≥1 ms','>16.67 ms'],rows)
    rows=[]
    for j,r in enumerate(plain):
        q=r['metrics']['all'];i=r['worst_step'];f=r['frames'][i]
        rows.append([j+1,fmt(q['mean']),fmt(q['max']),i,fmt(float(f['simulation_seconds'])),f['resim_passes'],f['stress_iterations'],f['logical_clusters'],f['awake_bodies'],f['contacts_frame']])
    d.table(['Selected scene repeat','Mean ms','Worst ms','Worst step','Sim time s','Resim','Stress iterations','Clusters','Scheduled active bodies','Solved contact reports'],rows)
    d.title('Event-based windows — no fixed impact frame or hidden warm-up cutoff')
    rows=[]
    for key,label in [('startup','First accepted step'),('preimpact','After startup, before first broken bond'),('corrected','Steps that execute correction'),('after_last_fracture','After the last newly broken bond'),('last_2s','Last two simulated seconds')]:
        v=stats([float(r['frames'][i]['physics_step_ms']) for r in plain for i in r['windows'][key]])
        if v:rows.append([label,v['n'],*[fmt(v[k]) for k in ['mean','p50','p95','max']]])
    d.table(['Window (overlapping; do not add)','Steps','Mean ms','p50 ms','p95 ms','Max ms'],rows)
    d.title('Instrumentation overhead — never mix these captures')
    rows=[]
    for mode,label in [('plain','No detailed profiling'),('phases','CPU scopes + CUDA stream events'),('gpu','CPU scopes + CUDA events + CUPTI')]:
        rr=p[mode];v=stats([float(f['physics_step_ms']) for r in rr for f in r['frames']]);rows.append([label,len(rr),fmt(v['mean']),fmt(v['max']),f"{v['mean']/mean([float(f['physics_step_ms']) for r in plain for f in r['frames'][:len(rr[0]['frames'])]]):.2f}×"])
    d.table(['Mode','Runs','Mean ms','Max ms','Mean / untraced mean'],rows)
    d.text('Profiling changes scheduling and adds overhead. Detailed tables describe their own measured capture; they are not a retrospective decomposition of the video or of an untraced maximum. Overhead is observed, not subtracted as a guessed correction.')
    pf=phase['frames'];pp=phase['profile'];first=next((i for i,f in enumerate(pf) if int(f['bonds_broken'])),0);worst=phase['worst_step'];late=phase['windows']['last_2s']
    d.title('Additive wall-time breakdown — host-scope capture')
    d.text(f"Columns show all-step mean, first fracture (step {first}), this capture's worst step ({worst}), and the last-two-seconds mean. CPU/GPU designations describe what happens inside the scope, not exclusive processor execution. Rows are disjoint and add to the timestamp bracket. The bracket includes clock-read bookends around simulate/fetch; mean difference from the simulation timer is {pp['timestamp_bookend_ms']['mean']*1000:.2f} µs.")
    rows=[]
    for key in partition([],{}):
        values=[x[key] for x in pp['wall_partition']];label,meaning=LABELS[key]
        rows.append([label,meaning,fmt(mean(values)),fmt(values[first]),fmt(values[worst]),fmt(mean([values[i] for i in late]))])
    rows.append(['TOTAL','Measured simulate/fetch bracket',fmt(mean([sum(x.values()) for x in pp['wall_partition']])),fmt(sum(pp['wall_partition'][first].values())),fmt(sum(pp['wall_partition'][worst].values())),fmt(mean([sum(pp['wall_partition'][i].values()) for i in late]))])
    d.table(['Operation','CPU / GPU responsibility','Mean ms','First fracture ms','Worst step ms','Last 2 s ms'],rows)
    d.title('Inside the destruction wait — GPU-stream elapsed time')
    d.text('These consecutive CUDA-event intervals include GPU execution plus stream scheduling/dependency gaps. They overlap the CPU submission/wait above and must NOT be added to wall time. The wait is the host observing completion of required work, not a second computation. Exact kernel execution is shown separately below.')
    d.table(['GPU stream operation','Mean ms','First fracture ms','Worst step ms','Last 2 s ms'],[[label,fmt(mean([r.get(key,0) for r in pp['cuda_stages']])),fmt(pp['cuda_stages'][first].get(key,0)),fmt(pp['cuda_stages'][worst].get(key,0)),fmt(mean([pp['cuda_stages'][i].get(key,0) for i in late]))] for key,label in STAGES.items() if any(key in v for v in pp['cuda_stages'])])
    t=trace['profile'];tf=trace['frames'];tfirst=next((i for i,f in enumerate(tf) if int(f['bonds_broken'])),0);tworst=trace['worst_step'];tl=trace['windows']['last_2s']
    d.title('Actual GPU execution versus elapsed gaps — CUPTI capture')
    d.text(f"Detailed GPU tables use repetition 1; all {len(p['gpu'])} repetitions pass full validation and contribute to the overhead table. GPU capture duration: {trace['summary']['seconds']} s. Its final-two-seconds column covers simulation seconds {max(0,trace['summary']['seconds']-2)}–{trace['summary']['seconds']}. This capture's first fracture is step {tfirst}; its worst step is {tworst}. Concurrent GPU intervals are merged before summing. No GPU activity means no recorded kernel/copy/memset from this process, not proof of global GPU idleness or useful CPU computation. CPU core-time can exceed elapsed time and is never added to it.")
    rows=[]
    for key,label in [('kernel_union_ms','GPU kernel execution (union)'),('copy_memset_only_ms','GPU copy/memset time not overlapping kernels'),('no_gpu_activity_ms','No recorded GPU execution'),('wall_ms','TOTAL measured bracket')]:
        v=[r[key] for r in t['gpu']];rows.append([label,fmt(mean(v)),fmt(v[tfirst]),fmt(v[tworst]),fmt(mean([v[i] for i in tl]))])
    d.table(['Disjoint wall-time category','Mean ms','First fracture ms','Worst step ms','Trace final 2 s ms'],rows)
    rows=[]
    for key in ['trial.other','finishAndReserve','correctedCollisionSolve']:
        r=t['gpu_regions'][key];rows.append([LABELS.get(key,('Finish GPU work and reserve bodies',''))[0],fmt(mean([x['wall_ms'] for x in r])),fmt(mean([x['gpu_busy_ms'] for x in r])),fmt(mean([x['no_gpu_activity_ms'] for x in r]))])
    d.table(['Important region','Wall mean ms','GPU activity mean ms','No GPU activity mean ms'],rows)
    d.title('Ordinary physics and resimulation — observed host substeps')
    d.text('Inclusive observed host scopes below can nest or overlap across worker threads. These rows explain the broad trial/correction regions; do not add them together. GPU work is dispatched asynchronously and need not execute inside its submitting host scope. Missing coverage remains in the parent region, rather than being presented as a measured operation.')
    d.table(['Host task / callback','Trial mean wall ms','Correction mean wall ms','Trial first-fracture ms','Correction first-fracture ms'],[[label,fmt(mean(pp['detail']['trialDetail.'+key]['observed_wall_ms'])),fmt(mean(pp['detail']['detail.'+key]['observed_wall_ms'])),fmt(pp['detail']['trialDetail.'+key]['observed_wall_ms'][first]),fmt(pp['detail']['detail.'+key]['observed_wall_ms'][first])] for key,label in DETAILS.items()])
    d.title('Which GPU work consumes execution time?')
    d.text('Kernel durations below are execution sums. They can overlap across streams and are NOT additive elapsed wall time. Classification uses kernel symbols and CUDA source files; unknown symbols stay explicitly unclassified.')
    d.table(['GPU kernel family','Mean execution sum ms','First-fracture sum ms','Worst-step sum ms','Trace final 2 s sum ms'],[[key,fmt(mean(v)),fmt(v[tfirst]),fmt(v[tworst]),fmt(mean([v[i] for i in tl]))] for key,v in sorted(t['kernel_categories'].items(),key=lambda p:(-mean(p[1]),p[0]))])
    d.text(f"Mean kernel dispatches per step: {mean([r['kernel_calls'] for r in t['gpu']]):.1f}; first-fracture dispatches: {t['gpu'][tfirst]['kernel_calls']}. CUDA API wall union averages {mean([r['api_union_ms'] for r in t['gpu']]):.3f} ms, overlapping GPU work. Time inside synchronization APIs with no recorded GPU activity averages {mean([r['no_gpu_in_wait_api_ms'] for r in t['gpu']]):.3f} ms; this includes driver/scheduler/dependency overhead, not proven useful CPU computation.")
    kernel_meaning={'nodeSpaceMatvec':'Stress matrix × search direction', 'nodeSpaceUpdateDirection':'Update stress search direction',
      'nodeSpaceUpdateSolution':'Update stress solution and residual', 'finalizeAndCheckConvergence':'Reduce residuals and check convergence',
      'finalizeAndRetire':'Retire converged stress islands', 'memset32':'Clear GPU scratch values',
      'solveStaticBlockTGS':'Solve contacts against static boundaries', 'solveWholeIslandTGS':'Solve a rigid-body constraint island'}
    def short_name(name):
        match=re.search(r'_cu_[0-9a-f]{8}(\d+)(\w+)',name)
        return match.group(2)[:int(match.group(1))] if match else name
    d.table(['Largest individual GPU kernels','Operation','Calls / step','Mean µs / call','Execution sum ms / step'],
      [[short_name(k['name']),kernel_meaning.get(short_name(k['name']),k['category']),fmt(k['calls']/len(tf)),
        fmt(1000*k['sum_ms']/k['calls']) if k['calls'] else '—',fmt(k['sum_ms']/len(tf))] for k in t['kernels'][:12]])
    d.text('Stress iterations are numerical convergence iterations, not additional resimulations. CUDA-graph guarded tail kernels can execute beyond the reported iteration count; kernel dispatch counts are shown separately. Small per-call times combined with repeated dependent launches identify a scheduling/fusion investigation, not proof of a particular hardware throughput limit.')
    d.title('CPU execution — core time, separate from elapsed wall time')
    cpu=pp['host_cpu_core_ms'];cpu_keys=sorted(set().union(*(r.keys() for r in cpu)),key=lambda k:(-mean([r.get(k,0) for r in cpu]),k))[:10]
    d.table(['Host scope','Mean exclusive CPU core-ms / step'],[[k.removeprefix('GpuDestruction.'),fmt(mean([r.get(k,0) for r in cpu]))] for k in cpu_keys])
    d.text(f"Process CPU time averages {mean([float(f['process_cpu_ms']) for f in pf]):.3f} core-ms per step in the host-scope capture. CPU thread clocks include busy waiting, driver and profiling work, but exclude descheduling. Same-thread children are subtracted from their parent; detached/cross-thread spans are excluded. Parallel CPU core-ms must not be added to wall-ms or GPU time. A large wait scope's CPU time does not mean the stress math runs on the CPU.")
    d.title('Work quantities — physical workload, not just allocated capacity')
    keys=[('logical_clusters','Connected rigid clusters'),('bodies','Registered PhysX bodies'),('awake_bodies','CPU-scheduled active bodies'),('contacts_frame','Solved contact reports'),('pre_solve_pairs','GPU pre-solve pair visits'),('stress_active_nodes','Retained stress nodes'),('stress_active_bonds','Retained stress bonds'),('stress_islands','Retained stress islands'),('stress_iterations','Reported stress iterations'),('bonds_broken','New broken bonds'),('resim_passes','Correction passes')]
    d.table(['Counter (untraced repeat 1)','Mean','Minimum','Maximum','Last 2 s mean'],[[label,*[fmt(stats([float(f[key]) for f in plain[0]['frames']])[k]) for k in ['mean','min','max']],fmt(mean([float(plain[0]['frames'][i][key]) for i in plain[0]['windows']['last_2s']]))] for key,label in keys])
    d.text('Active-body counters come from CPU scheduling, not a qualified GPU sleep mask; sleeping is disabled here. Contact reports/pair visits are work counts, not unique collisions. Retained stress bonds are topology membership, not the number processed in every iteration. Legacy public contact-pair/solver-row counters are incomplete on this GPU path and are excluded. Allocation capacity and memory-bandwidth/occupancy counters are not collected in this report.')
    d.table(['Counter association (host-scope capture)','Pearson r with total step time','Pearson r with stress-stream time'],
      [[label,fmt(a.pearson([float(f[key]) for f in pf],[float(f['physics_step_ms']) for f in pf])),
        fmt(a.pearson([float(f[key]) for f in pf],[r['stress'] for r in pp['cuda_stages']]))]
       for key,label in [('stress_iterations','Stress iterations'),('awake_bodies','Scheduled active bodies'),('stress_active_bonds','Retained stress bonds'),('contacts_frame','Solved contact reports'),('resim_passes','Correction passes')]])
    d.text('Associations describe this one evolving scene; they are not causal scaling laws. A dash means a constant/insufficient sample. In particular, retained-body and bond counts co-vary with impact time; controlled workload variations are needed to establish their independent costs.')
    d.title('Automatic bottleneck summary and next decision')
    ranked=sorted(((mean([row[key] for row in pp['wall_partition']]),LABELS[key][0]) for key in pp['wall_partition'][0]),reverse=True)
    d.text('Largest elapsed regions: '+ '; '.join(f'{label}: {ms:.3f} ms/step' for ms,label in ranked[:3])+'.')
    stage_rank=sorted(((mean([v.get(k,0) for v in pp['cuda_stages']]),label) for k,label in STAGES.items()),reverse=True)
    d.text('Largest GPU-stream stage: '+stage_rank[0][1]+f" ({stage_rank[0][0]:.3f} ms/step). A sub-1-ms target needs this measured cost reduced if it already exceeds 1 ms; increasing scene size would not remove it.")
    late_iterations=mean([float(plain[0]['frames'][i]['stress_iterations']) for i in plain[0]['windows']['last_2s']])
    d.text(f"Late-scene stress remains active: {late_iterations:.1f} reported iterations/step in the last two seconds. No new fracture does not imply no stress work. Compare convergence, applied loads and contact changes before considering any result reuse; this report does not authorize skipped physics or relaxed convergence.")
    d.text('Evidence supports targeting the largest measured stages and investigating small-kernel/iteration scheduling. It does not distinguish memory-bandwidth limitation from arithmetic throughput: SM occupancy, bandwidth and instruction counters require a separate hardware-counter experiment. Scale an active workload only after comparing these per-step costs; the intact controls show geometry scaling alone.')
    d.title('Reproduce, audit and extend')
    d.text('Capture and generate in one command: python3 tools/scripts/run-destruction-timing.py NEW_CAPTURE_DIRECTORY --trials 5 --gpu-trials 3 --seconds 10. Reports appear in NEW_CAPTURE_DIRECTORY/report. Regenerate from captures only: python3 tools/scripts/report-destruction-timing.py CAPTURE_DIRECTORY --output REPORT_DIRECTORY. Change the versioned tools/profiles/wall-penetration-timing.json configuration for additional physical workloads; every resolved command is retained.')
    d.text('report.json.gz contains every per-step partition, GPU region, CPU exclusive core-time scope, kernel symbol/source, transfer byte count, run signature and summary. campaign.json beside the captures records binary/library SHA-256 hashes, exact inputs, driver, GPU process/clock samples, and hashes of all raw files. Reports are generated from those recorded files, without querying the current GPU or inserting a generation timestamp.')
    d.text('Percentiles use nearest rank ceil(p × N), with 1-based ranks. Means pool equally long untraced runs; maxima retain all measured spikes. Event windows overlap and must not be added. Zero-size windows are omitted. Rounded display values can differ from the exact total by rounding; raw JSON preserves full precision.')
    d.save(out)

def complete_step_metrics(run):
    require(run['summary'].get('complete_timer_schema')==1,'Complete-step timer required; old simulate/fetch timing cannot qualify')
    values=[]
    for f in run['frames']:
        total=float(f['complete_step_ms']);command=float(f['command_ms']);completion=float(f['completion_ms']);physics=float(f['physics_step_ms'])
        require(all(math.isfinite(v) and v>=0 for v in [total,command,completion,physics]) and total>0,'Invalid complete-step duration')
        require(abs(total-command-completion-physics)<0.0002,'Complete-step phases do not add up')
        require(int(f['complete_start_ns'])<=int(f['simulation_start_ns'])<int(f['simulation_end_ns'])<=int(f['complete_end_ns']),'Simulation escaped complete-step bracket')
        if run['summary'].get('phase_output_timing_schema')==1:
            require('phase_output_start_ns' in f and 'phase_output_end_ns' in f,'Missing profiler output timestamps')
            start,end=int(f['phase_output_start_ns']),int(f['phase_output_end_ns'])
            require((start==end==0) or int(f['complete_end_ns'])<=start<=end,'Profiler output overlaps complete-step timer')
            if len(values)+1<len(run['frames']) and end:
                require(end<=int(run['frames'][len(values)+1]['complete_start_ns']),'Profiler output overlaps next complete step')
        values.append(total)
    require(sum(v>8.0 for v in values)==run['summary']['missed_8ms'],'Deadline counter mismatch')
    require(abs(max(values)-run['summary']['complete_step_ms_max'])<0.0002,'Peak counter mismatch')
    return stats(values)

def render_physics_task_details(doc,data,peak):
    # These task spans can nest and overlap. They explain their parent physics
    # pass but are deliberately not added to the disjoint complete-step table.
    for prefix,title in [('trialDetail.','Trial physics tasks'),('detail.','Correction physics tasks')]:
        rows=[]
        for key,label in DETAILS.items():
            entry=data.get('detail',{}).get(prefix+key)
            if not entry:continue
            values=entry['observed_wall_ms']
            if not any(values):continue
            owner='CPU task; elapsed includes any GPU submission/dependency waits'
            if key=='broadPhaseWait':
                owner='CPU spin/block awaiting GPU completion; overlaps GPU execution, not additional GPU work'
            elif key in ('preallocateContactManagers','registerContactManagers','registerInteractions','registerSceneInteractions','islandInsertion'):
                owner='CPU contact/interaction lifecycle bookkeeping'
            rows.append([label,owner,fmt(mean(values)),fmt(values[peak])])
        if rows:
            doc.title(title+' — overlapping diagnostic spans')
            doc.text('These are existing CPU task wall scopes, not GPU kernel durations. They may nest or execute concurrently; do not sum them or add them to the complete advance. Means include all measured steps, including steps with no correction. The peak column uses the same scoped complete-step peak as the parent table.')
            doc.table(['Task','Owner / responsibility','All-step mean ms','At scoped peak ms'],rows)

def render_complete_gate(manifest,runs,out):
    doc=Document();doc.title('🎯 Complete PhysX destruction advance — 8 ms gate',1)
    doc.text('60 Hz physical timestep. Timer includes commands, projectile insertion, simulate/fetch, destruction/correction and mandatory completion. All measured steps, including startup, remain. Rendering and report output are outside the bracket.')
    rows=[];workloads=[];failures=0;gates=[];quality_failures=[];history_changes=[]
    for case in manifest['config']['cases']:
        case_runs=runs[case['id']]['plain']
        summary=case_runs[0]['summary']
        peak_clusters=max(run['summary']['peak_clusters'] for run in case_runs)
        workloads.append([case['label'],summary['chunks'],summary['bonds'],summary['projectiles'],
                          peak_clusters,summary['seconds'],summary['correction_limit'],
                          'Enabled' if summary['sleeping'] else 'Disabled'])
        previous=None
        for i,run in enumerate(runs[case['id']]['plain']):
            metric=complete_step_metrics(run);frames=run['frames'];worst=max(range(len(frames)),key=lambda n:float(frames[n]['complete_step_ms']));f=frames[worst]
            misses=sum(float(f['complete_step_ms'])>8 for f in frames);failures+=misses
            summary=run['summary']
            if summary['shot_path']=='through-wall' and not (summary['broken_bonds']==199 and summary['corrections']==3 and summary['peak_clusters']==summary['buildings']+42):
                quality_failures.append(f"{case['label']}, repeat {i+1}: frozen wall counters changed")
            if previous is not None and run['signature_rows']!=previous:
                change=f"{case['label']}, repeat {i+1}: per-step counter history differs"
                # Multi-impact rubble is a chaotic workload. Keep the changed
                # histories visible; never waive the controlled wall fixture.
                if summary['workload']=='bombardment':history_changes.append(change)
                else:quality_failures.append(change)
            previous=run['signature_rows']
            rows.append([case['label'],i+1,len(frames),fmt(metric['min']),fmt(metric['mean']),fmt(metric['p95']),fmt(metric['p99']),fmt(metric['max']),misses,worst,fmt(float(f['command_ms'])),fmt(float(f['physics_step_ms'])),fmt(float(f['completion_ms']))])
            gates.append(dict(case=case['id'],repeat=i+1,metrics=metric,misses=misses,worst_step=worst))
    enough=manifest['seconds']>=60 and manifest['trials']>=5
    doc.text(('❌ Deadline failed' if failures else '✅ Measured deadlines passed')+f': {failures} steps exceeded 8.0 ms. '+('Five × 60-second duration requirement met.' if enough else 'Diagnostic only: five × 60-second qualification duration not met.'))
    doc.text('This timing gate checks convergence, correction limit, frozen wall counters and repeated counter histories. It does not substitute for the independent trajectory/hole/momentum audit or the 10-minute endurance gate; overall plan qualification remains incomplete until those pass.')
    for message in quality_failures:doc.text('❌ Controlled quality gate failed: '+message)
    for message in history_changes:doc.text('⚠️ Chaotic workload variation: '+message+'. Convergence and correction-limit checks passed, but exact trajectories and full physical quality are not qualified.')
    doc.table(['Scene','Chunks','Bonds','Projectiles','Peak destruction clusters','Seconds per run','Correction limit','Sleeping'],workloads)
    doc.text('Stress chunks are geometry/connectivity units, not independently solved rigid bodies while bonded. Peak destruction clusters is the maximum across all measured repeats and excludes ordinary actors such as the projectile and ground. Idle controls measure retained geometry, not concurrent destruction.')
    doc.table(['Scene','Repeat','Steps','Min ms','Mean ms','p95 ms','p99 ms','Peak ms','Misses','Peak step','Commands at peak ms','Physics/destruction at peak ms','Completion at peak ms'],rows)
    doc.text('Commands and completion timings are disjoint from simulate/fetch. Detailed CPU/GPU subdivisions require a separate profiling capture; they must not be inferred from another run’s maximum. No percentile or outlier removal changes the deadline verdict.')
    scoped=[]
    for case in manifest['config']['cases']:
        for run in runs[case['id']]['phases']:
            data=run['profile'];frames=run['frames']
            complete_step_metrics(run)
            peak=max(range(len(frames)),key=lambda i:float(frames[i]['complete_step_ms']))
            doc.title('Separate phase capture: '+case['label'])
            doc.text('This is a separate instrumented run. CPU elapsed regions form a partition; CUDA stream stages overlap that partition and must not be added to it. The peak column below refers only to this scoped run, not the untraced peak above.')
            phase_rows=[['Apply recorded commands','CPU submission and GPU command execution',fmt(mean([float(f['command_ms']) for f in frames])),fmt(float(frames[peak]['command_ms']))]]
            phase_rows += [[LABELS[key][0],LABELS[key][1],fmt(mean([v[key] for v in data['wall_partition']])),fmt(data['wall_partition'][peak][key])]
                for key in data['wall_partition'][0]]
            phase_rows += [['Mandatory completion and status','CPU completion boundary and compact GPU status observation',fmt(mean([float(f['completion_ms']) for f in frames])),fmt(float(frames[peak]['completion_ms']))],
                ['TOTAL complete advance','Commands through accepted state and mandatory status',fmt(mean([float(f['complete_step_ms']) for f in frames])),fmt(float(frames[peak]['complete_step_ms']))]]
            doc.table(['Operation','Owner / responsibility','Mean elapsed ms','At scoped peak ms'],phase_rows)
            if not run['summary'].get('phase_output_outside_complete_timer',False):
                doc.text('⚠️ Legacy diagnostic capture: profiler CSV serialization was included in completion time. This scoped complete-step measurement includes report-output overhead; use untraced runs for performance. No estimated cost is subtracted.')
            doc.table(['GPU stream stage','Mean ms','At scoped peak ms'],[
                [label,fmt(mean([v.get(key,0) for v in data['cuda_stages']])),fmt(data['cuda_stages'][peak].get(key,0))]
                for key,label in STAGES.items() if any(key in v for v in data['cuda_stages'])])
            render_physics_task_details(doc,data,peak)
            doc.text(f"Scoped peak: repeat 1, step {peak}, complete advance {float(frames[peak]['complete_step_ms']):.3f} ms. CUDA-event timings measure stream intervals, including gaps; they do not establish SM utilization or hardware bandwidth limits.")
            reference=runs[case['id']]['plain'][0]
            plain_means=[mean([float(f['complete_step_ms']) for f in r['frames']]) for r in runs[case['id']]['plain']]
            plain_peaks=[max(float(f['complete_step_ms']) for f in r['frames']) for r in runs[case['id']]['plain']]
            doc.text(f"Observer comparison: scoped mean {mean([float(f['complete_step_ms']) for f in frames]):.3f} ms versus untraced repeat means {min(plain_means):.3f}–{max(plain_means):.3f} ms; scoped peak {float(frames[peak]['complete_step_ms']):.3f} ms versus untraced peaks {min(plain_peaks):.3f}–{max(plain_peaks):.3f} ms. This includes run variation and observer effects, not a correction factor. Thread CPU time for detailed migration leaves is intentionally unmeasured; the enclosing scope retains it.")
            full_match=run['signature_rows']==reference['signature_rows']
            prefix_match=run['signature_rows'][:peak+1]==reference['signature_rows'][:peak+1]
            doc.text(f"Scoped versus first untraced counter history: complete run {'matches' if full_match else 'differs'}; through the scoped peak {'matches' if prefix_match else 'differs'}. Broken bonds: scoped {run['summary']['broken_bonds']}, first untraced {reference['summary']['broken_bonds']}. These are separate trajectories, not a decomposition of the same measured peak.")
            scoped.append({'case':case['id'],'peak_step':peak,'profile':data})
    doc.save(out)
    payload=dict(schema=1,deadline_ms=8.0,deadline_pass=failures==0,duration_pass=enough,quality_endurance_qualified=False,runs=gates,phase_captures=scoped,controlled_quality_failures=quality_failures,chaotic_history_changes=history_changes,manifest=manifest)
    with (out/'report.json.gz').open('wb') as raw:
        with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as z:z.write((json.dumps(payload,indent=2,sort_keys=True)+'\n').encode())
    return failures==0 and enough and not quality_failures

def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('capture',type=Path);parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    manifest=json.loads((args.capture/'campaign.json').read_text());require(manifest['status']=='complete','Campaign incomplete')
    runs={c['id']:{mode:[] for mode in ['plain','phases','gpu']} for c in manifest['config']['cases']};catalog_record=manifest['kernel_classification']
    require(sha(args.capture/catalog_record['file'])==catalog_record['sha256'],'Kernel classification snapshot changed')
    catalog=json.loads((args.capture/catalog_record['file']).read_text())
    for rec in manifest['runs']:
        if rec['mode']=='warmup':continue
        directory=args.capture/rec['name'];r=load_run(directory,rec);r['capture']=str(directory.resolve())
        validate_duration(manifest,r['frames'])
        if rec['mode'] in ['phases','gpu']:r['profile']=profile(directory,r,catalog)
        runs[rec['case']][rec['mode']].append(r)
    if manifest.get('gate_only'):
        for case in runs.values():require(len(case['plain'])==manifest['trials'],'Missing untraced repetition')
        if manifest.get('phase_scopes'):
            for case in runs.values():require(len(case['phases'])==1,'Missing scoped capture')
        passed=render_complete_gate(manifest,runs,args.output)
        print(args.output/'report.html')
        raise SystemExit(0 if passed else 2)
    require(manifest['gpu_seconds']==manifest['seconds'],'Partial-duration GPU capture cannot qualify this report')
    for case in runs.values():require(len(case['plain'])==manifest['trials'] and len(case['phases'])==1 and len(case['gpu'])==manifest.get('gpu_trials',1),'Missing repeat or profile capture')
    render(manifest,runs,args.output)
    with (args.output/'report.json.gz').open('wb') as raw:
        with gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as zipped:
            zipped.write((json.dumps({'schema':1,'manifest':manifest,'reporter_sha256':sha(Path(__file__)),'accounting_sha256':sha(Path(a.__file__)),'runs':runs},indent=2,sort_keys=True)+'\n').encode())
    print(args.output/'report.html')

if __name__=='__main__':main()
