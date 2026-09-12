#!/usr/bin/env python3
"""Join CPU scheduling/stacks, engine scopes, CUDA callers and complete-tick GPU work.

All wall accounting uses the same Systems clock. CPU samples are counts, not
invented milliseconds. Thread CPU and nested scope totals are never added to wall.
"""
import argparse,collections,csv,functools,importlib.util,json,sqlite3
from pathlib import Path

def load(name,path):
    s=importlib.util.spec_from_file_location(name,path);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
profile=load('profile',Path(__file__).with_name('analyze-profile.py'))
accounting=profile.accounting

def analyze(path):
    base=profile.timeline(path)
    db=sqlite3.connect(f'file:{path/"trace.sqlite"}?mode=ro',uri=True);db.row_factory=sqlite3.Row
    tables={r[0] for r in db.execute("select name from sqlite_master where type='table'")}
    required={'COMPOSITE_EVENTS','SAMPLING_CALLCHAINS','SCHED_EVENTS','CUDA_CALLCHAINS','OSRT_API'}
    if not required<=tables:raise ValueError('Missing CPU attribution tables: '+str(required-tables))
    strings=dict(db.execute('select id,value from StringIds'))
    tick=db.execute("select start,end,globalTid from NVTX_EVENTS where text='snapshot/full_tick'").fetchone();lo,hi,main=tick
    scopes=[dict(r) for r in db.execute("select start,end,text,globalTid,endGlobalTid,rangeId from NVTX_EVENTS where text like 'GpuDestruction.%' and start>=? and end<=?",(lo,hi))]
    scopes_by_thread=collections.defaultdict(list)
    for s in scopes:scopes_by_thread[s['globalTid']].append(s)
    def clip(a,b):return max(lo,a),min(hi,b)
    def scope_at(t,tid):
        hits=[s for s in scopes_by_thread[tid] if s['start']<=t<=s['end']]
        return min(hits,key=lambda s:s['end']-s['start'])['text'] if hits else None
    @functools.lru_cache(maxsize=None)
    def chain(table,key):
        return [dict(symbol=strings.get(r['symbol'],'?'),module=strings.get(r['module'],'?'),unresolved=bool(r['unresolved']),depth=r['stackDepth'])
                for r in db.execute(f'select * from {table} where id=? order by stackDepth',(key,))]
    apis=[]
    for table,kind in [('CUPTI_ACTIVITY_KIND_RUNTIME','cuda'),('CUPTI_ACTIVITY_KIND_DRIVER','cuda'),('OSRT_API','os')]:
        if table not in tables:continue
        for r in db.execute(f'select * from {table} where end>? and start<?',(lo,hi)):
            a,b=clip(r['start'],r['end']);item=dict(start_ns=a,end_ns=b,ms=(b-a)/1e6,kind=kind,name=strings[r['nameId']],thread=r['globalTid'],
                correlation_id=r['correlationId'] if 'correlationId' in r.keys() else None,callchain_id=r['callchainId'],scope=scope_at(a,r['globalTid']))
            item['stack']=chain('CUDA_CALLCHAINS' if kind=='cuda' else 'OSRT_CALLCHAINS',r['callchainId']) if r['callchainId'] is not None else []
            apis.append(item)
    correlations={a['correlation_id']:a for a in apis if a['kind']=='cuda'}
    gpu_rows=list(db.execute('select * from CUPTI_ACTIVITY_KIND_KERNEL where end>? and start<? order by start',(lo,hi)))
    for item,r in zip(base['kernels'],gpu_rows):
        api=correlations.get(r['correlationId']);item.update(stream=r['streamId'],context=r['contextId'],correlation_id=r['correlationId'],graph_id=r['graphId'],graph_node_id=r['graphNodeId'],grid_id=r['gridId'],
            launch_api=api['name'] if api else None,launch_scope=api['scope'] if api else None,launch_thread=api['thread'] if api else None)
        # Queue delay includes preceding work/dependencies; it is not all launch overhead.
        item['api_end_to_gpu_start_ms']=(r['start']-api['end_ns'])/1e6 if api else None
    for item,r in zip(base['transfers'],db.execute('select * from CUPTI_ACTIVITY_KIND_MEMCPY where end>? and start<?',(lo,hi))):
        api=correlations.get(r['correlationId']);item.update(stream=r['streamId'],correlation_id=r['correlationId'],src_kind=r['srcKind'],dst_kind=r['dstKind'],
            launch_scope=api['scope'] if api else None,launch_thread=api['thread'] if api else None)
    samples=[dict(r) for r in db.execute('select * from COMPOSITE_EVENTS where start>=? and start<?',(lo,hi))]
    leaves=collections.Counter();inclusive=collections.Counter();modules=collections.Counter();unresolved=0;sample_threads=collections.Counter()
    for s in samples:
        stack=chain('SAMPLING_CALLCHAINS',s['id']);sample_threads[s['globalTid']]+=1
        if stack:
            leaf=stack[0];leaves[(leaf['symbol'],leaf['module'])]+=1;modules[leaf['module']]+=1;unresolved+=leaf['unresolved']
            for key in {(f['symbol'],f['module']) for f in stack}:inclusive[key]+=1
    def counts(c):return [dict(symbol=k[0],module=k[1],samples=v) for k,v in c.most_common()]
    # Include boundary events outside the tick to determine the state at tick start.
    tids={main}|set(sample_threads)|{a['thread'] for a in apis}|{s['globalTid'] for s in scopes}
    states=dict(db.execute('select id,label from ENUM_SAMPLING_THREAD_STATE'));thread_rows=[];running=[];main_states=[]
    for tid in sorted(t for t in tids if t is not None):
        events=[dict(r) for r in db.execute('select * from SCHED_EVENTS where globalTid=? order by start',(tid,))]
        intervals=[]
        for i,e in enumerate(events):
            end=events[i+1]['start'] if i+1<len(events) else hi
            a,b=clip(e['start'],end)
            if b<=a:continue
            state='running' if e['isSchedIn'] else ('runnable' if e['threadState'] in (1,6) else 'blocked' if e['threadState'] in (2,3,4,7,8) else 'unknown')
            intervals.append(dict(start_ns=a,end_ns=b,state=state,raw_state=states.get(e['threadState']),cpu=e['cpu']))
            if state=='running':running.append((a,b))
        covered=accounting.length((x['start_ns'],x['end_ns']) for x in intervals)
        totals={state:sum(x['end_ns']-x['start_ns'] for x in intervals if x['state']==state)/1e6 for state in ['running','runnable','blocked','unknown']}
        totals['unknown']+=(hi-lo-covered)/1e6
        thread_rows.append(dict(thread=tid,is_main=tid==main,samples=sample_threads[tid],state_ms=totals,intervals=intervals))
        if tid==main:main_states=intervals
    activity=[(k['start_ns'],k['end_ns']) for k in base['kernels']+base['transfers']+base['memsets']]
    gpu=accounting.union(activity);cpu=accounting.union(running);both=accounting.length(accounting.intersect(gpu,cpu));g=accounting.length(gpu);c=accounting.length(cpu)
    disjoint=dict(gpu_and_scheduled_cpu_ms=both/1e6,gpu_without_scheduled_cpu_ms=(g-both)/1e6,scheduled_cpu_without_gpu_ms=(c-both)/1e6,neither_traced_gpu_nor_scheduled_cpu_ms=((hi-lo)-g-c+both)/1e6)
    assert min(disjoint.values())>=-1e-6 and abs(sum(disjoint.values())-base['tick_ms'])<1e-6
    # These intervals expose waits without pretending API time and GPU execution add.
    waits=sorted([a for a in apis if a['kind']=='os' or 'Synchronize' in a['name'] or ('Memcpy' in a['name'] and 'Async' not in a['name'])],key=lambda a:-a['ms'])
    for a in waits:
        a['gpu_overlap_ms']=accounting.length(accounting.intersect([(a['start_ns'],a['end_ns'])],gpu))/1e6
    phase_rows=list(csv.DictReader((path/'native.phases.csv').open()))
    assert all(r['accepted_step']=='1' for r in phase_rows)
    assert len(phase_rows)==len(scopes),'Native/NVTX phase inventory mismatch'
    grouped=collections.defaultdict(list)
    for r in phase_rows:grouped[r['phase']].append(r)
    exclusive=accounting.exclusive_cpu(phase_rows)
    phases=[dict(name=n,calls=len(v),aggregate_wall_ms=sum(float(r['host_wall_ms']) for r in v),thread_cpu_ms=sum(max(0,float(r['thread_cpu_ms'])) for r in v),exclusive_thread_cpu_ms=exclusive.get(n),cpu_unmeasured_calls=sum(float(r['thread_cpu_ms'])<0 for r in v)) for n,v in grouped.items()]
    physical=json.loads((path/'physical-comparison.json').read_text());assert physical['status']=='passed'
    base.update(cpu_attribution=dict(samples=len(samples),unresolved_leaf_samples=unresolved,leaf=counts(leaves),inclusive=counts(inclusive),threads=thread_rows,
        module_leaf_samples=dict(modules),disjoint_wall=disjoint,scopes=phases,nvtx_scope_count=len(scopes),waits=waits,cuda_calls=[a for a in apis if a['kind']=='cuda'],
        gpu_launches_with_correlated_api=sum(k['launch_api'] is not None for k in base['kernels']),gpu_launches_with_engine_scope=sum(k['launch_scope'] is not None for k in base['kernels']),
        sampling_caveat='Statistical stack counts, not exact CPU milliseconds. Inclusive stacks overlap. Unresolved driver/kernel frames remain explicit. Short scenarios may require additional samples for a selected function.',
        accounting_caveat='Disjoint wall partitions use scheduling and GPU intervals from this trace. Scheduled CPU includes observed profiler/driver threads. Neither is not automatically idle or removable. A CPU wait overlapping GPU work is not independent overhead.'),
        device_phase_events=list(csv.DictReader((path/'native.phases.csv.device.csv').open())),physical_comparison=physical)
    return base

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);a=p.parse_args();r=analyze(a.capture)
    (a.capture/'attribution.json').write_text(json.dumps(r,indent=2)+'\n')
    print(json.dumps(dict(samples=r['cpu_attribution']['samples'],scopes=r['cpu_attribution']['nvtx_scope_count'],wall=r['cpu_attribution']['disjoint_wall'])))
