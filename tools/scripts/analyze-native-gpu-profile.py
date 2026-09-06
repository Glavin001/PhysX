#!/usr/bin/env python3
"""Account concurrent GPU intervals and nested host scopes without adding overlapping time."""
import argparse,bisect,collections,csv,gzip,json,math,re,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[2]

def read_csv(path):
    if path.exists():return csv.DictReader(path.open())
    return csv.DictReader(gzip.open(str(path)+'.gz','rt'))

def union(intervals):
    result=[]
    for a,b in sorted(intervals):
        if b<a:raise ValueError('negative interval')
        if b==a:continue
        if result and a<=result[-1][1]:result[-1]=(result[-1][0],max(b,result[-1][1]))
        else:result.append((a,b))
    return result

def length(intervals):return sum(b-a for a,b in union(intervals))

def intersect(left,right):
    a,b=union(left),union(right);i=j=0;out=[]
    while i<len(a) and j<len(b):
        lo,hi=max(a[i][0],b[j][0]),min(a[i][1],b[j][1])
        if hi>lo:out.append((lo,hi))
        if a[i][1]<b[j][1]:i+=1
        else:j+=1
    return out

def stats(values):
    values=sorted(values)
    if not values:return None
    return {'n':len(values),'min':values[0],'mean':statistics.mean(values),'p50':statistics.median(values),'p95':values[min(len(values)-1,int(.95*len(values)))],'p99':values[min(len(values)-1,int(.99*len(values)))],'max':values[-1]}

def pearson(x,y):
    if len(x)<3:return None
    ax,ay=statistics.mean(x),statistics.mean(y)
    dx=[a-ax for a in x];dy=[b-ay for b in y]
    denom=math.sqrt(sum(a*a for a in dx)*sum(b*b for b in dy))
    return sum(a*b for a,b in zip(dx,dy))/denom if denom else None

def source_catalog():
    catalog=collections.defaultdict(set)
    for path in (ROOT/'physx/source').glob('gpu*/**/*.cu'):
        category=path.relative_to(ROOT/'physx/source').parts[0]
        for symbol in set(re.findall(r'\b(\w+)\s*\(',path.read_text(errors='replace'))):
            catalog[symbol].add((category,str(path.relative_to(ROOT))))
    return catalog

def classify(name,catalog):
    # Mangled anonymous-namespace names embed the CUDA translation unit.
    if 'NvBlastExtStressGpu' in name:return 'stress solver / stress topology','blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpu.cu'
    if 'PxgDestructionTopology' in name:return 'destruction connectivity / mass / slots','physx/source/gpudestruction/src/PxgDestructionTopology.cu'
    if 'destructionPreSolve' in name:return 'destruction pre-solve contacts / islands','physx/source/gpudestruction/src/PxgPreSolveIslands.cuh'
    if 'destructionContactGraph' in name:return 'destruction contact graph','physx/source/gpudestruction/src/PxgDestructionContactGraph.cuh'
    if 'PxgDestructionRuntime' in name:
        group='destruction orchestration / motion'
        # Classify the kernel function, not names in its mangled parameter types.
        match=re.search(r'PxgDestructionRuntime_cu_[0-9a-f]{8}(\d+)(\w+)',name)
        function=match.group(2)[:int(match.group(1))] if match else ''
        if any(n in function for n in ('prepareLoads','routeContacts','contactLoads','frictionLoads','gatherContact','applyContact')):group='destruction load gathering'
        if any(n in function for n in ('Material','Crush','Verdict')):group='destruction material / damage'
        return group,'physx/source/gpudestruction/src/PxgDestructionRuntime.cu'
    if 'cub' in name:return 'shared CUDA scan / sort primitives',None
    found=catalog.get(name,set())
    categories={x[0] for x in found}
    labels={'gpubroadphase':'physics broad phase','gpunarrowphase':'physics narrow phase / contact lifecycle','gpusolver':'physics constraint preparation / solve / integration','gpusimulationcontroller':'physics body / shape updates','gpucommon':'shared physics utilities','gpudestruction':'destruction utilities'}
    if len(categories)==1:return labels.get(next(iter(categories)),next(iter(categories))),sorted(x[1] for x in found)[0]
    if name in ('memset32','memcpy32_post'):return 'CUDA memory utility kernels',None
    return 'unclassified',None

def exclusive_cpu(rows):
    # Thread-clock deltas can be subtracted only on the same OS thread and
    # for nested synchronous intervals. Detached task spans are wall-only.
    by_thread=collections.defaultdict(list)
    for row in rows:
        if not int(row['detached']) and row['thread']==row['end_thread'] and float(row['thread_cpu_ms'])>=0:
            by_thread[row['thread']].append(row)
    totals=collections.defaultdict(float)
    for thread,items in by_thread.items():
        stack=[]
        for row in sorted(items,key=lambda r:(int(r['start_ns']),-int(r['end_ns']))):
            a,b=int(row['start_ns']),int(row['end_ns']);cpu=float(row['thread_cpu_ms'])
            while stack and a>=int(stack[-1]['end_ns']):stack.pop()
            if stack:
                if b>int(stack[-1]['end_ns']):raise ValueError('crossing synchronous scopes on one thread')
                totals[stack[-1]['phase']]-=cpu
            totals[row['phase']]+=cpu;stack.append(row)
    if any(v<-.01 for v in totals.values()):raise ValueError('negative exclusive CPU time')
    return {k:max(0,v) for k,v in totals.items()}

def analyze(directory,catalog=None,warmup=60):
    summary=json.loads((directory/'native.summary.json').read_text());assert summary['status']=='completed'
    rows=list(read_csv(directory/'native.frames.csv'));assert len(rows)==summary['frames']
    frames=[];begins=[];ends=[]
    numeric=('physics_step_ms','process_cpu_ms','bodies','awake_bodies','logical_clusters','native_dynamic_bodies','native_kinematic_bodies','active_dynamic_bodies','active_kinematic_bodies','contacts_frame','pre_solve_pairs','stress_active_nodes','stress_active_bonds','stress_islands','stress_iterations','bonds_broken','resim_passes','graph_d2h_bytes')
    for i,row in enumerate(rows):
        assert int(row['step'])==i and row['stress_converged']=='1' and int(row['resim_passes'])<=1
        frame={k:float(row[k]) for k in numeric};a,b=int(row['simulation_start_ns']),int(row['simulation_end_ns']);assert b>a
        begins.append(a);ends.append(b);frame.update(step=i,simulation_seconds=float(row['simulation_seconds']),interval_ms=(b-a)/1e6)
        frames.append(frame)
    result={'summary':summary,'warmup_excluded_steps':warmup,'metrics':{},'windows':{}}
    traced=summary.get('profile_gpu',False)
    if traced:
        capture=json.loads((directory/'native.activity.status.json').read_text());assert capture['complete'] and not capture['dropped'] and not capture['invalid_timestamps']
        result['capture']=capture
        names={int(a):b.rstrip('\n') for a,b in (line.split('\t',1) for line in (directory/'native.activity.names.tsv').open())}
        catalog=catalog if catalog is not None else source_catalog()
        classification={i:classify(n,catalog) for i,n in names.items()}
        gpu=[[] for _ in frames];kernels=[[] for _ in frames];waits=[[] for _ in frames];apis=[[] for _ in frames]
        gpu_sum=[collections.defaultdict(float) for _ in frames];kernel_sum=collections.defaultdict(float);kernel_calls=collections.Counter();api_sum=collections.defaultdict(float);byte_sum=collections.Counter()
        host=[[] for _ in frames];correction=[[] for _ in frames];copies=[[] for _ in frames];checkpoint_ids=set();checkpoint_calls=0
        for row in read_csv(directory/'native.phases.csv'):
            if row['accepted_step']!='1':continue # teardown after final accepted frame is outside measurement
            i=int(row['step']);assert 0<=i<len(frames)
            if int(row['start_ns'])<begins[i] or int(row['end_ns'])>ends[i]:continue # observation/setup/async boundary scopes are not simulation CPU work
            host[i].append(row)
            if row['phase']=='GpuDestruction.correctedCollisionSolve':correction[i].append((int(row['start_ns']),int(row['end_ns'])))
        outside=collections.Counter()
        for row in read_csv(directory/'native.activity.csv'):
            a,b=int(row['start_ns']),int(row['end_ns']);kind=row['kind'];name=names[int(row['name_id'])]
            i=max(0,bisect.bisect_right(ends,a));overlapped=False
            while i<len(frames) and begins[i]<b:
                start,end=max(a,begins[i]),min(b,ends[i])
                if end>start:
                    overlapped=True;span=(start,end);elapsed=(end-start)/1e6;frame=frames[i]
                    if kind=='A':
                        apis[i].append(span)
                        if 'Synchronize' in name or ('Memcpy' in name and 'Async' not in name):waits[i].append(span)
                        if i>=warmup:api_sum[name]+=elapsed
                        if 'Memcpy' in name:
                            for scope in host[i]:
                                if scope['phase']=='GpuDestruction.checkpoint' and scope['thread']==row['thread'] and int(scope['start_ns'])<=a and b<=int(scope['end_ns']):
                                    checkpoint_ids.add(int(row['correlation']));checkpoint_calls+=1
                    else:
                        gpu[i].append(span)
                        if kind=='K':
                            kernels[i].append(span);category=classification[int(row['name_id'])][0];gpu_sum[i][category]+=elapsed
                            if i>=warmup:kernel_sum[name]+=elapsed;kernel_calls[name]+=1
                        else:
                            # Bytes attach once to the frame containing the operation start;
                            # interval time is split across boundaries if necessary.
                            if kind=='C':copies[i].append((start,end,int(row['bytes']),int(row['correlation'])))
                            key='gpu_'+name+'_bytes'
                            if start==a:frame[key]=frame.get(key,0)+int(row['bytes'])
                            if i>=warmup and start==a:byte_sum[name]+=int(row['bytes'])
                i+=1
            if not overlapped:outside[kind]+=1
        phase_cpu=collections.defaultdict(float);phase_wall=collections.defaultdict(float);phase_calls=collections.Counter();phase_gpu=collections.defaultdict(float);phase_off_gpu=collections.defaultdict(float)
        for i,frame in enumerate(frames):
            busy=length(gpu[i])/1e6;kernel=length(kernels[i])/1e6;corr=length(intersect(correction[i],[(begins[i],ends[i])]))/1e6
            frame.update(gpu_busy_ms=busy,gpu_kernel_union_ms=kernel,gpu_copy_only_ms=busy-kernel,no_gpu_activity_ms=frame['interval_ms']-busy,cuda_api_union_ms=length(apis[i])/1e6,cuda_wait_api_union_ms=length(waits[i])/1e6,correction_wall_ms=corr,correction_gpu_busy_ms=length(intersect(gpu[i],correction[i]))/1e6)
            checkpoint=[(a,b) for a,b,_,c in copies[i] if c in checkpoint_ids]
            frame['checkpoint_gpu_copy_union_ms']=length(checkpoint)/1e6
            frame['checkpoint_gpu_copy_bytes']=sum(size for _,_,size,c in copies[i] if c in checkpoint_ids)
            frame['trial_and_other_gpu_busy_ms']=busy-frame['correction_gpu_busy_ms']
            frame['no_gpu_inside_cuda_wait_ms']=(length(waits[i])-length(intersect(waits[i],gpu[i])))/1e6
            cpu=exclusive_cpu(host[i]);frame['instrumented_cpu_core_ms']=sum(cpu.values())
            for category,value in gpu_sum[i].items():frame['kernel_sum_ms:'+category]=value
            for name,value in cpu.items():frame['cpu_exclusive_ms:'+name]=value
            if i>=warmup:
                for name,value in cpu.items():phase_cpu[name]+=value
                for row in host[i]:
                    name=row['phase'];span=[(int(row['start_ns']),int(row['end_ns']))];wall=length(span)/1e6
                    phase_wall[name]+=wall;phase_calls[name]+=1
                    overlap=length(intersect(span,gpu[i]))/1e6;phase_gpu[name]+=overlap;phase_off_gpu[name]+=wall-overlap
        n=len(frames)-warmup
        result['gpu_kernel_categories_mean_sum_ms']={key:sum(f.get('kernel_sum_ms:'+key,0) for f in frames[warmup:])/n for key in sorted(set().union(*(g.keys() for g in gpu_sum)))}
        result['kernels']=sorted([{'name':name,'category':classify(name,catalog)[0],'source':classify(name,catalog)[1],'mean_sum_ms':total/n,'calls':kernel_calls[name]} for name,total in kernel_sum.items()],key=lambda r:-r['mean_sum_ms'])
        result['driver_apis_mean_sum_ms']=dict(sorted(((k,v/n) for k,v in api_sum.items()),key=lambda p:-p[1]))
        result['transfer_bytes_total']=dict(byte_sum)
        result['host_phases']=sorted([{'name':name,'calls':phase_calls[name],'mean_inclusive_wall_ms':phase_wall[name]/n,'mean_exclusive_cpu_core_ms':phase_cpu[name]/n,'mean_gpu_overlap_ms':phase_gpu[name]/n,'mean_no_gpu_overlap_ms':phase_off_gpu[name]/n} for name in phase_wall],key=lambda r:-r['mean_exclusive_cpu_core_ms'])
        result['outside_frame_activity_records']=dict(outside)
        result['checkpoint_copy_correlations']=len(checkpoint_ids)
        result['checkpoint_api_calls']=checkpoint_calls
    values=frames[warmup:];assert values
    keys=set().union(*(v.keys() for v in values))
    result['metrics']={k:stats([f.get(k,0) for f in values]) for k in sorted(keys) if k!='step'}
    result['deadline_misses']=sum(f['physics_step_ms']>1000/60 for f in values)
    for name,predicate in [('preimpact',lambda f:f['simulation_seconds']<=1),('corrected',lambda f:f['resim_passes']>0),('uncorrected',lambda f:f['resim_passes']==0),('late_rubble',lambda f:f['simulation_seconds']>=8),('contact_without_new_fracture',lambda f:f['contacts_frame']>0 and f['bonds_broken']==0)]:
        subset=[f for f in values if predicate(f)]
        if subset:result['windows'][name]={k:stats([f.get(k,0) for f in subset]) for k in ('physics_step_ms','awake_bodies','pre_solve_pairs','bonds_broken','stress_active_bonds','gpu_busy_ms','process_cpu_ms') if k in keys}
    result['associations_pearson_not_causal']={k:pearson([f[k] for f in values],[f['physics_step_ms'] for f in values]) for k in ('awake_bodies','pre_solve_pairs','stress_active_bonds','stress_iterations','bonds_broken','resim_passes')}
    result['definitions']={'GPU times':'CUPTI concurrent activity; union clips to simulate/fetch boundaries. Kernel category sums overlap across streams and must not be added to wall time.','no_gpu_activity_ms':'No kernel/copy/memset from this process in the simulation interval. Not a measure of global GPU idleness or proof all time is CPU computation.','CPU':'Process and thread CPU clocks measure core-ms, excluding sleeping/descheduling, but including spinning and driver/profiler CPU. Exclusive scopes subtract same-thread synchronous children only. Parallel core-ms are not additive wall-ms.','bodies':'PhysX registered dynamic plus kinematic actors, including retained parent/body lifecycle objects; distinct from logical rigid clusters.','awake_bodies':'PhysX CPU island scheduling counters from last solver pass: active dynamic + active kinematic. This integrated path disables sleeping; these are not a demonstrated GPU sleep mask.','pre_solve_pairs':'GPU pre-solve contact-manager pairs processed across trial and correction, not unique touching pairs; normalContacts counts solved reports separately.','stress_active_bonds':'Retained stress topology membership after accepted topology update; not count of nonconverged bonds processed in each solver iteration.','public_contact_stats':'Legacy contact_pairs, contact_pairs_with_contacts and solver_rows are not complete GPU work counters; excluded from scaling analysis.','warmup':'First 60 accepted steps excluded; initial destruction allocation spikes remain part of measurement.','profiling':'Tracing itself has overhead; use untraced replicates for elapsed time. No isolated-device or 60-second 60Hz qualification.'}
    (directory/'native.profile.json').write_text(json.dumps(result,indent=2)+'\n')
    with gzip.open(directory/'native.profile.frames.csv.gz','wt') as f:
        writer=csv.DictWriter(f,fieldnames=['step']+sorted(set().union(*(f.keys() for f in frames))-{'step'}));writer.writeheader();writer.writerows(frames)
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('--warmup',type=int,default=60);a=p.parse_args();result=analyze(a.capture,warmup=a.warmup)
    print(json.dumps({'physics_ms':result['metrics']['physics_step_ms'],'gpu_busy_ms':result['metrics'].get('gpu_busy_ms'),'top_cpu':result.get('host_phases',[])[:8]},indent=2))
if __name__=='__main__':main()
