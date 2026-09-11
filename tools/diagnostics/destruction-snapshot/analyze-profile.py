#!/usr/bin/env python3
"""Extract first-complete-tick timeline costs and persistent targeted NCU metrics."""
import argparse,bisect,collections,csv,importlib.util,json,sqlite3,statistics
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('accounting',ROOT/'tools/scripts/analyze-native-gpu-profile.py')
accounting=importlib.util.module_from_spec(spec);spec.loader.exec_module(accounting)

def timeline(directory):
    receipt=json.loads((directory/'receipt.json').read_text());replay=json.loads((directory/'replay.json').read_text())
    if receipt['status']!='complete' or not replay['passed']:raise ValueError('Unqualified timeline execution')
    db=sqlite3.connect(f'file:{directory / "trace.sqlite"}?mode=ro',uri=True);db.row_factory=sqlite3.Row
    tables={r[0] for r in db.execute("select name from sqlite_master where type='table'")}
    ranges=[dict(r) for r in db.execute("select start,end,text from NVTX_EVENTS where text like 'snapshot/%' and end is not null")]
    ticks=[r for r in ranges if r['text']=='snapshot/full_tick'];assert len(ticks)==1
    lo,hi=ticks[0]['start'],ticks[0]['end'];clip=lambda a,b:(max(lo,a),min(hi,b))
    assert {r['text'] for r in ranges}=={'snapshot/full_tick','snapshot/commands','snapshot/simulate_fetch','snapshot/completion'} and len(ranges)==4
    assert all(lo<=r['start']<=r['end']<=hi for r in ranges)
    diagnostics=[dict(r) for r in db.execute('select severity,text from DIAGNOSTIC_EVENT where severity>=2')] if 'DIAGNOSTIC_EVENT' in tables else []
    if receipt['profiler'].get('raw_timeline_scope')=='process' and any('CUDA events' in r['text'] for r in diagnostics):
        raise ValueError('Full-process CUDA trace completeness warning')
    kernels=[];groups=collections.defaultdict(list)
    # Reuse the existing source-based classifier. Its catalog is shared on disk
    # across this campaign; it is attribution evidence, not a physical workload.
    cache=directory.parent/'source-catalog.json'
    if cache.exists():catalog={k:set(map(tuple,v)) for k,v in json.loads(cache.read_text()).items()}
    else:
        catalog=accounting.source_catalog();cache.write_text(json.dumps({k:sorted(v) for k,v in catalog.items()})+'\n')
    query='select k.*,s.value as name,m.value as mangled from CUPTI_ACTIVITY_KIND_KERNEL k join StringIds s on s.id=k.demangledName join StringIds m on m.id=k.mangledName where k.end>? and k.start<? order by k.start'
    for r in db.execute(query,(lo,hi)):
        a,b=clip(r['start'],r['end']);kind,source=accounting.classify(r['mangled'],catalog)
        if kind=='unclassified':kind,source=accounting.classify(r['name'].split('(')[0],catalog)
        item=dict(name=r['name'],mangled=r['mangled'],start_ns=a,end_ns=b,ms=(b-a)/1e6,
            category=kind,source=source,registers_per_thread=r['registersPerThread'],
            grid=[r['gridX'],r['gridY'],r['gridZ']],block=[r['blockX'],r['blockY'],r['blockZ']],
            shared_bytes=r['staticSharedMemory']+r['dynamicSharedMemory'])
        kernels.append(item);groups[item['name']].append(item)
    copies=[];memsets=[]
    for table,dest in [('CUPTI_ACTIVITY_KIND_MEMCPY',copies),('CUPTI_ACTIVITY_KIND_MEMSET',memsets)]:
        if table not in tables:continue
        for r in db.execute(f'select * from {table} where end>? and start<?',(lo,hi)):
            a,b=clip(r['start'],r['end']);dest.append(dict(start_ns=a,end_ns=b,ms=(b-a)/1e6,bytes=r['bytes'],kind=r['copyKind'] if 'copyKind' in r.keys() else 'memset'))
    apis=collections.defaultdict(list)
    for table in ['CUPTI_ACTIVITY_KIND_RUNTIME','CUPTI_ACTIVITY_KIND_DRIVER']:
        if table not in tables:continue
        for r in db.execute(f'select a.start,a.end,s.value from {table} a join StringIds s on s.id=a.nameId where a.end>? and a.start<?',(lo,hi)):
            a,b=clip(r['start'],r['end']);apis[r['value']].append((a,b))
    api_rows=sorted([dict(name=n,calls=len(v),aggregate_ms=sum(b-a for a,b in v)/1e6,union_ms=accounting.length(v)/1e6) for n,v in apis.items()],key=lambda x:-x['aggregate_ms'])
    activity=[(x['start_ns'],x['end_ns']) for x in kernels+copies+memsets]
    union=accounting.length(activity)/1e6;tick=(hi-lo)/1e6
    ranked=sorted([dict(name=n,launches=len(v),aggregate_ms=sum(x['ms'] for x in v),max_ms=max(x['ms'] for x in v),category=v[0]['category']) for n,v in groups.items()],key=lambda x:-x['aggregate_ms'])
    result=dict(scope='Nsight-instrumented first full tick; GPU activity is interval union; API and kernel aggregates may overlap and are not additive CPU/GPU stage costs.',
        tick_ms=tick,stage_ms={r['text'].split('/')[-1]:(r['end']-r['start'])/1e6 for r in ranges if r['text']!='snapshot/full_tick'},
        gpu_activity_union_ms=union,no_traced_gpu_activity_ms=max(0,tick-union),
        kernel_count=len(kernels),copy_count=len(copies),copy_bytes=sum(x['bytes'] for x in copies),
        kernels=kernels,ranked_kernels=ranked,transfers=copies,memsets=memsets,cuda_apis=api_rows,
        physical_status='passed',physical_sample=replay['samples'][0],receipt=receipt,diagnostics=diagnostics,declared_tick_ranges_complete=True)
    return result

def counters(path):
    lines=path.read_text().splitlines();start=next(i for i,l in enumerate(lines) if l.startswith('"ID","Process ID"'))
    reader=csv.DictReader(lines[start:])
    if 'Metric Value' not in reader.fieldnames:
        units=next(reader);result=[]
        metadata={'ID','Process ID','Process Name','Host Name','Kernel Name','Context','Stream','Block Size','Grid Size','Device','CC'}
        for r in reader:
            metrics={}
            for name,value in r.items():
                if name in metadata:continue
                try:value=float(value.replace(',',''))
                except ValueError:pass
                metrics[name]=dict(value=value,unit=units[name])
            result.append(dict(name=r['Kernel Name'],metrics=metrics))
        return result
    groups={}
    for r in reader:
        key=r['ID'];g=groups.setdefault(key,dict(name=r['Kernel Name'],metrics={}))
        value=r['Metric Value']
        try:value=float(value.replace(',',''))
        except ValueError:pass
        g['metrics'][r['Metric Name']]=dict(value=value,unit=r['Metric Unit'])
    return list(groups.values())

def pm_counters(directory,trace):
    pm=directory/'pm';result=json.loads((pm/'result.json').read_text())
    if result['child_exit_code'] or result['overflow'] or not result['final_drain_complete']:
        raise ValueError('Incomplete hardware sampling capture')
    db=sqlite3.connect(f'file:{directory / "trace.sqlite"}?mode=ro',uri=True)
    epoch,_,_,steady=db.execute('select * from TARGET_INFO_SESSION_START_TIME').fetchone()
    lo,hi=db.execute("select start,end from NVTX_EVENTS where text='snapshot/full_tick'").fetchone()
    clock=list(csv.DictReader((pm/'clock.csv').open()))
    offsets=[int(c['cupti_ns'])-(int(c['steady_before_ns'])+int(c['steady_after_ns']))//2 for c in clock]
    discrepancy=max(abs(epoch-steady-o) for o in offsets);margin=100000+discrepancy
    samples=[];excluded=0
    with (pm/'samples.csv').open() as f:
        for s in csv.DictReader(f):
            if s['timestamp_valid']!='1':excluded+=1;continue
            samples.append((int(s['start_ns']),int(s['end_ns']),float(s['sm__warps_active_realtime.avg.pct_of_peak_sustained_elapsed']),float(s['sm__inst_executed_realtime.avg.per_cycle_elapsed']),float(s['dram__bytes.sum'])))
    starts=[s[0] for s in samples]
    def window(begin,end):
        begin+=epoch+margin;end+=epoch-margin
        chosen=[s for s in samples[bisect.bisect_left(starts,begin):bisect.bisect_right(starts,end)] if s[1]<=end]
        duration=sum(s[1]-s[0] for s in chosen)
        return dict(samples=len(chosen),sampled_ms=duration/1e6,interior_coverage=duration/(end-begin) if end>begin else None,
            resident_warps_elapsed_pct=sum((s[1]-s[0])*s[2] for s in chosen)/duration if duration else None,
            instructions_per_sm_cycle=sum((s[1]-s[0])*s[3] for s in chosen)/duration if duration else None,
            dram_gb_s=sum(s[4] for s in chosen)/duration if duration else None)
    tick=window(lo,hi)
    if not tick['samples']:raise ValueError('No valid hardware samples within full tick')
    kernels=[dict(name=k['name'],ms=k['ms'],**window(k['start_ns'],k['end_ns'])) for k in trace['kernels']]
    return dict(scope='Device-wide non-replaying PM samples; includes graphics/server contexts. Elapsed-time resident warps are not NCU achieved active occupancy. Short kernels may have no interior samples.',
        tick=tick,kernels=kernels,boundary_margin_ns=margin,clock_anchor_discrepancy_ns=discrepancy,
        excluded_samples=excluded,sampling=result)

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('--kind',choices=['timeline','counters'],required=True);a=p.parse_args()
    result=timeline(a.capture) if a.kind=='timeline' else counters(a.capture/'counters.csv')
    if a.kind=='timeline' and (a.capture/'pm/result.json').exists():result['pm']=pm_counters(a.capture,result)
    (a.capture/'analysis.json').write_text(json.dumps(result,indent=2)+'\n')
    if a.kind=='timeline':print(json.dumps({k:result[k] for k in ['tick_ms','gpu_activity_union_ms','kernel_count','copy_count','copy_bytes']}))
    else:print(f'{len(result)} targeted kernel launches with hardware metrics')
if __name__=='__main__':main()
