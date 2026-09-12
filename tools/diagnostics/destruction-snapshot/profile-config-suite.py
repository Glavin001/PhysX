#!/usr/bin/env python3
"""Counter coverage for significant kernels outside graphs, by launch configuration.

Every kernel family costing >=0.1ms in the matched timeline is significant for
this diagnostic tier. Capture its first and slowest timed invocation at EACH grid/block/shared
configuration; all invocations and timings remain in Systems. Common invocation
filters may collect extra representatives; these are audited explicitly. This is explicitly
representative configuration coverage, not an all-invocation counter claim.
Graphs are covered by the separate full graph suite; selected stress node
captures retain individual instruction-level detail where the tool supports it.
"""
import argparse,collections,hashlib,importlib.util,json,math,os,re,sqlite3,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('profile',Path(__file__).with_name('analyze-profile.py'));profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)

def representatives(targets):
    ordinals={1}
    for t in targets:
        for c in t['configs']:ordinals.add(1+max(range(len(c['invocations'])),key=lambda i:c['invocations'][i]['ms']))
    for t in targets:
        for c in t['configs']:
            c['selected_ordinals']=[i+1 for i in range(len(c['invocations'])) if i+1 in ordinals]
    return sorted(ordinals)

def select(path,threshold):
    db=sqlite3.connect(f'file:{path/"trace.sqlite"}?mode=ro',uri=True);db.row_factory=sqlite3.Row
    lo,hi=db.execute("select start,end from NVTX_EVENTS where text='snapshot/full_tick'").fetchone();groups=collections.defaultdict(list)
    for k in db.execute('select k.*,s.value as name from CUPTI_ACTIVITY_KIND_KERNEL k join StringIds s on k.mangledName=s.id where start>=? and end<=? order by start',(lo,hi)):groups[k['name']].append(dict(k))
    targets=[]
    for name,ks in groups.items():
        ms=sum(k['end']-k['start'] for k in ks)/1e6
        if ms<threshold or all(k['graphId'] is not None for k in ks):continue
        assert all(k['graphId'] is None for k in ks),'Mixed graph/ordinary family needs explicit coverage handling'
        configurations=collections.defaultdict(list)
        for i,k in enumerate(ks):
            config=tuple(k[f'{dim}{axis}'] for dim in ['grid','block'] for axis in 'XYZ')+(k['staticSharedMemory']+k['dynamicSharedMemory'],)
            configurations[config].append(dict(invocation=i+1,ms=(k['end']-k['start'])/1e6))
        targets.append(dict(name=name,aggregate_ms=ms,launches=len(ks),configs=[dict(grid=list(c[:3]),block=list(c[3:6]),shared_bytes=c[6],invocations=v) for c,v in configurations.items()]))
    # Invocation filters count per name and configuration. Use one common
    # ordinal set, preserving first and observed worst invocation for every
    # configuration. Audit any extra representatives selected by the union.
    ordinals=representatives(targets)
    return dict(threshold_family_ms=threshold,targets=targets,invocation_ordinals=sorted(ordinals),expected_launches=sum(len(c['selected_ordinals']) for t in targets for c in t['configs']),expected_configs=sum(len(t['configs']) for t in targets),
        total_gpu_kernel_ms=sum(k['end']-k['start'] for ks in groups.values() for k in ks)/1e6,
        graph_gpu_kernel_ms=sum(k['end']-k['start'] for ks in groups.values() for k in ks if k['graphId'] is not None)/1e6,
        selected_ordinary_kernel_ms=sum(t['aggregate_ms'] for t in targets),
        omitted_ordinary=[dict(name=n,aggregate_ms=sum(k['end']-k['start'] for k in ks)/1e6,launches=len(ks)) for n,ks in groups.items() if all(k['graphId'] is None for k in ks) and n not in {t['name'] for t in targets}])

def observed_key(row):
    dims=lambda key:tuple(map(int,re.findall(r'\d+',row['launch'][key])))
    def shared(key):
        m=row['metrics'][key];return round(m['value']*(1000 if m['unit'].startswith('Kbyte') else 1))
    return row['name'],dims('Grid Size'),dims('Block Size'),shared('launch__shared_mem_per_block_static')+shared('launch__shared_mem_per_block_dynamic')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--timeline-campaign',type=Path,required=True);p.add_argument('--manifest',type=Path,required=True)
    p.add_argument('--binary',type=Path,required=True);p.add_argument('--artifacts',type=Path,required=True)
    p.add_argument('--threshold-ms',type=float,default=.1);p.add_argument('--scenarios',nargs='+');p.add_argument('--resume',action='store_true')
    p.add_argument('--allow-existing-graphics',action='store_true');a=p.parse_args();assert a.threshold_ms>=0
    ncu='/opt/nvidia/nsight-compute/2025.3.1/ncu';out=a.output.resolve();out.mkdir(parents=True,exist_ok=a.resume);sha=lambda f:hashlib.sha256(Path(f).read_bytes()).hexdigest()
    prior=json.loads((a.timeline_campaign/'campaign.json').read_text());cases=json.loads(a.manifest.read_text())['scenarios']
    if a.scenarios:cases=[c for c in cases if c['scenario'] in a.scenarios];assert len(cases)==len(a.scenarios)
    identity=dict(binary_sha256=sha(a.binary),modules={p.name:sha(p) for p in sorted(a.artifacts.glob('*.so'))});assert identity==prior['identity']
    previous=json.loads((out/'campaign.json').read_text()) if a.resume and (out/'campaign.json').exists() else None
    if previous:assert previous['identity']==identity and previous['threshold_ms']==a.threshold_ms
    if previous:(out/('campaign-before-resume-'+str(time.time_ns())+'.json')).write_bytes((out/'campaign.json').read_bytes())
    start=time.monotonic();record=dict(status='running',identity=identity,threshold_ms=a.threshold_ms,scenarios=[],scope=__doc__)
    def save():record['elapsed_this_invocation_seconds']=time.monotonic()-start;(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(cmd,log):
        with log.open('a') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=dict(os.environ,PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1'),check=True)
    for c in cases:
        name=c['scenario'];old=next((r for r in previous['scenarios'] if r['scenario']==name and r['status']=='complete'),None) if previous else None
        if old:assert old['input_sha256']==c['input_sha256'];record['scenarios'].append(old);save();continue
        for f,h in c['input_sha256'].items():assert sha(f)==h
        timeline=next(r for r in prior['scenarios'] if r['scenario']==name);assert timeline['input_sha256']==c['input_sha256'];plan=select(Path(timeline['timeline']),a.threshold_ms)
        row=dict(scenario=name,status='running',input_sha256=c['input_sha256'],selection=plan);record['scenarios'].append(row);save()
        try:
            if not plan['targets']:row.update(status='complete',captured_configs=0,note='No significant ordinary kernel family; graph and timeline tiers apply.');save();continue
            capture=out/name;attempt=0
            while capture.exists():attempt+=1;capture=out/(name+'-attempt'+str(attempt))
            expression='::regex:^('+'|'.join(re.escape(t['name']) for t in plan['targets'])+')$:^('+'|'.join(map(str,plan['invocation_ordinals']))+')$'
            cmd=[sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(capture),'--binary',str(a.binary.resolve()),'--artifacts',str(a.artifacts.resolve()),'--replay-prefix',c['prefix'],'--repetitions','2','--watchdog-seconds','1800','--profiler','ncu','--ncu-binary',ncu,'--ncu-kernel-id',expression,'--ncu-name-base','mangled','--ncu-filter-mode','per-launch-config','--ncu-count','100000','--ncu-mode','full','--ncu-apply-rules','no']
            if a.allow_existing_graphics:cmd+=['--allow-existing-graphics']
            if c.get('projectile_impulse'):cmd+=['--projectile-impulse']
            print(name,plan['expected_configs'],'configurations',plan['expected_launches'],'representatives',flush=True);row['path']=str(capture);save();run(cmd,out/(name+'-driver.log'))
            with (capture/'counters.csv').open('w') as f:subprocess.run([ncu,'--import',str(capture/'counters.ncu-rep'),'--page','raw','--csv','--print-kernel-base','mangled'],stdout=f,check=True)
            data=profile.counters(capture/'counters.csv');(capture/'analysis.json').write_text(json.dumps(data)+'\n')
            expected=collections.Counter((t['name'],tuple(c['grid']),tuple(c['block']),c['shared_bytes']) for t in plan['targets'] for c in t['configs'] for _ in c['selected_ordinals']);actual=collections.Counter(observed_key(d) for d in data)
            row['missing_configs']=[list(k) for k in (expected-actual).elements()];row['extra_configs']=[list(k) for k in (actual-expected).elements()]
            assert actual==expected,'Launch configuration inventory mismatch'
            for d in data:
                for k in ['gpu__time_duration.sum','smsp__warps_eligible.avg.per_cycle_active','smsp__issue_active.avg.pct_of_peak_sustained_active','dram__bytes.sum.per_second','launch__registers_per_thread']:
                    assert math.isfinite(d['metrics'][k]['value']),(name,k)
            run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/compare-observations.py'),str(ROOT/'out/snapshot-reset-20260911/prepared-full20'/('complete-'+name)),str(capture),str(capture/'physical-comparison.json')],capture/'compare.log')
            row.update(status='complete',captured_configs=len(actual),captured_launches=len(data),report_sha256=sha(capture/'counters.ncu-rep'),physical_comparison=str(capture/'physical-comparison.json'));save()
        except BaseException as e:row.update(status='failed',error=str(e));record['status']='failed';save();raise
    record['status']='complete';save();print('complete',out)

if __name__=='__main__':main()
