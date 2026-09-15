#!/usr/bin/env python3
"""Join continuous complete-step boundaries to Systems CPU/GPU evidence.

Native phase/frame clocks are CLOCK_MONOTONIC. Systems systemClockNs anchors its
relative timestamps to that clock. All samples/stacks remain in the SQLite file.
"""
import argparse,bisect,collections,csv,importlib.util,json,sqlite3
from pathlib import Path
spec=importlib.util.spec_from_file_location('profile',Path(__file__).with_name('analyze-profile.py'))
profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)
accounting=profile.accounting

def analyze(path):
    receipt=json.loads((path/'receipt.json').read_text());assert receipt['status']=='complete'
    native=path/'native'
    summary=json.loads((native/'native.summary.json').read_text());assert summary['status']=='completed'
    frames=list(csv.DictReader((native/'native.frames.csv').open()));assert len(frames)==summary['frames']
    db=sqlite3.connect(f'file:{path/"trace.sqlite"}?mode=ro',uri=True);db.row_factory=sqlite3.Row
    tables={r[0] for r in db.execute("select name from sqlite_master where type='table'")}
    assert {'COMPOSITE_EVENTS','SAMPLING_CALLCHAINS','SCHED_EVENTS','CUDA_CALLCHAINS','OSRT_API'}<=tables
    strings=dict(db.execute('select id,value from StringIds'))
    anchor=db.execute('select * from TARGET_INFO_SESSION_START_TIME').fetchone()['systemClockNs']
    diagnostics=[dict(r) for r in db.execute('select severity,text from DIAGNOSTIC_EVENT where severity>=2')]
    assert not any('CUDA events' in r['text'] for r in diagnostics),'Incomplete drained GPU trace'
    windows=[(int(f['complete_start_ns'])-anchor,int(f['complete_end_ns'])-anchor) for f in frames]
    assert all(a<b and (i==0 or a>=windows[i-1][1]) for i,(a,b) in enumerate(windows))
    begins=[a for a,b in windows];ends=[b for a,b in windows]
    buckets=[collections.defaultdict(list) for _ in frames]
    def assign(kind,row):
        a,b=row['start'],row['end'];i=bisect.bisect_right(ends,a)
        while i<len(frames) and begins[i]<b:
            lo,hi=max(a,begins[i]),min(b,ends[i])
            if hi>lo:buckets[i][kind].append(dict(row,start=lo,end=hi))
            i+=1
    for table,kind in [('CUPTI_ACTIVITY_KIND_KERNEL','kernel'),('CUPTI_ACTIVITY_KIND_MEMCPY','copy'),('CUPTI_ACTIVITY_KIND_MEMSET','memset'),('CUPTI_ACTIVITY_KIND_RUNTIME','cuda'),('CUPTI_ACTIVITY_KIND_DRIVER','cuda'),('OSRT_API','os')]:
        if table not in tables:continue
        for r in db.execute(f'select * from {table} where end>? and start<?',(begins[0],ends[-1])):assign(kind,dict(r))
    for r in db.execute('select * from COMPOSITE_EVENTS where start>=? and start<?',(begins[0],ends[-1])):
        i=bisect.bisect_right(begins,r['start'])-1
        if i>=0 and r['start']<ends[i]:buckets[i]['samples'].append(dict(r))
    # Include scheduling events at either boundary to reconstruct each state.
    sched=collections.defaultdict(list)
    for r in db.execute('select * from SCHED_EVENTS order by globalTid,start'):sched[r['globalTid']].append(dict(r))
    for tid,events in sched.items():
        for i,e in enumerate(events):
            end=events[i+1]['start'] if i+1<len(events) else ends[-1]
            if e['isSchedIn'] and end>begins[0] and e['start']<ends[-1]:assign('running',dict(e,end=end))
    phases=list(csv.DictReader((native/'native.phases.csv').open()))
    for r in phases:
        if r['accepted_step']!='1':continue
        i=int(r['step'])
        if 0<=i<len(frames) and begins[i]<=int(r['start_ns'])-anchor<=int(r['end_ns'])-anchor<=ends[i]:buckets[i]['phases'].append(r)
    stacks={}
    for r in db.execute('select * from SAMPLING_CALLCHAINS order by id,stackDepth'):
        stacks.setdefault(r['id'],[]).append(dict(symbol=strings.get(r['symbol'],'?'),module=strings.get(r['module'],'?'),unresolved=bool(r['unresolved'])))
    results=[];catalog=accounting.source_catalog()
    for i,(f,bucket) in enumerate(zip(frames,buckets)):
        assert int(f['step'])==i and f['stress_converged']=='1' and int(f['resim_passes'])<=1
        lo,hi=windows[i];wall=(hi-lo)/1e6
        # The native monotonic anchors are nested inside its authoritative timer.
        # Preemption between clock reads is real but cannot be placed on the
        # trace from these anchors; preserve it as unlocated boundary time.
        boundary=float(f['complete_step_ms'])-wall
        assert boundary>=-1e-5,'Anchored window extends outside the native complete timer'
        spans=lambda kind:[(r['start'],r['end']) for r in bucket[kind]]
        gpu=accounting.union(spans('kernel')+spans('copy')+spans('memset'));cpu=accounting.union(spans('running'))
        both=accounting.length(accounting.intersect(gpu,cpu));g=accounting.length(gpu);c=accounting.length(cpu)
        partition=dict(gpu_and_scheduled_cpu_ms=both/1e6,gpu_without_scheduled_cpu_ms=(g-both)/1e6,scheduled_cpu_without_gpu_ms=(c-both)/1e6,neither_traced_gpu_nor_scheduled_cpu_ms=((hi-lo)-g-c+both)/1e6)
        assert min(partition.values())>=-1e-6 and abs(sum(partition.values())-wall)<1e-6
        leaves=collections.Counter();unresolved=0
        for sample in bucket['samples']:
            stack=stacks.get(sample['id'],[])
            if stack:leaves[(stack[0]['symbol'],stack[0]['module'])]+=1;unresolved+=stack[0]['unresolved']
        kernels=collections.defaultdict(list)
        for k in bucket['kernel']:kernels[strings[k['mangledName']]].append(k)
        kernel_rows=[]
        for name,rows in kernels.items():
            kind,source=accounting.classify(name,catalog)
            if kind=='unclassified':kind,source=accounting.classify(strings[rows[0]['demangledName']].split('(')[0],catalog)
            kernel_rows.append(dict(name=strings[rows[0]['demangledName']],mangled=name,launches=len(rows),aggregate_ms=sum(r['end']-r['start'] for r in rows)/1e6,category=kind,source=source))
        waits=[r for r in bucket['cuda'] if 'Synchronize' in strings[r['nameId']] or ('Memcpy' in strings[r['nameId']] and 'Async' not in strings[r['nameId']])]+bucket['os']
        phase_wall=collections.Counter()
        for phase in bucket['phases']:phase_wall[phase['phase']]+=float(phase['host_wall_ms'])
        results.append(dict(step=i,frame=f,profiled_complete_ms=float(f['complete_step_ms']),profiled_anchor_window_ms=wall,unlocated_timer_boundary_ms=max(0,boundary),disjoint_wall=partition,cpu_samples=len(bucket['samples']),unresolved_leaf_samples=unresolved,
            cpu_leaf=[dict(symbol=k[0],module=k[1],samples=v) for k,v in leaves.most_common()],kernel_launches=len(bucket['kernel']),ranked_kernels=sorted(kernel_rows,key=lambda k:-k['aggregate_ms']),
            copy_count=len(bucket['copy']),copy_bytes=sum(r['bytes'] for r in bucket['copy']),cuda_calls=len(bucket['cuda']),
            wait_union_ms=accounting.length((r['start'],r['end']) for r in waits)/1e6,
            wait_gpu_overlap_ms=accounting.length(accounting.intersect([(r['start'],r['end']) for r in waits],gpu))/1e6,
            phase_calls=len(bucket['phases']),phase_aggregate_wall_ms=dict(phase_wall),phase_exclusive_cpu_ms=accounting.exclusive_cpu(bucket['phases'])))
    assert sum(r['cpu_samples'] for r in results)>0 and sum(r['kernel_launches'] for r in results)>0
    return dict(status='complete',scope='Instrumented continuous full steps; diagnostic durations, not benchmark results. GPU/CPU same-clock union partition. Samples are counts; unresolved frames explicit. All stacks, CUDA callers, streams and scheduling events remain in SQLite.',
        clock_anchor_steady_ns=anchor,receipt=receipt,summary=summary,frames=results,diagnostics=diagnostics,
        physical_status='Convergence and correction cap checked; requires separate unprofiled trajectory comparison.',
        initialization_seconds=summary.get('initialization_seconds'),cpu_samples=sum(r['cpu_samples'] for r in results),kernel_launches=sum(r['kernel_launches'] for r in results))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);a=p.parse_args();d=analyze(a.capture)
    (a.capture/'warm-attribution.json').write_text(json.dumps(d)+'\n')
    print(json.dumps({k:d[k] for k in ['status','cpu_samples','kernel_launches','physical_status']}))
