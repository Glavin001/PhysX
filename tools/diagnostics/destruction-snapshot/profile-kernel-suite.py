#!/usr/bin/env python3
"""Capture every invocation of significant GPU families; audit against Systems inventory.

Selection includes at least 99% of aggregate kernel duration and every family
costing >=0.1ms in its scenario, plus every stress solve. These are coverage
budgets, not bottleneck diagnoses. All omitted launches remain in the timeline.
"""
import argparse,collections,hashlib,importlib.util,json,math,os,re,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('profile',Path(__file__).with_name('analyze-profile.py'));profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)

def select(trace,coverage,absolute_ms):
    total=sum(k['ms'] for k in trace['kernels']);groups=collections.defaultdict(list)
    for k in trace['kernels']:groups[k['mangled']].append(k)
    selected=[];covered=0
    for symbol,ks in sorted(groups.items(),key=lambda x:-sum(k['ms'] for k in x[1])):
        ms=sum(k['ms'] for k in ks)
        if covered<coverage*total or ms>=absolute_ms or 'componentStressSolve' in symbol:
            selected.append(dict(mangled=symbol,name=ks[0]['name'],launches=len(ks),aggregate_ms=ms,max_ms=max(k['ms'] for k in ks),
                configurations=[dict(grid=list(g),block=list(b),shared_bytes=s) for g,b,s in sorted({(tuple(k['grid']),tuple(k['block']),k['shared_bytes']) for k in ks})]));covered+=ms
    return dict(targets=selected,total_kernel_ms=total,selected_kernel_ms=covered,coverage_fraction=covered/total,omitted_kernel_ms=total-covered,
        expected_launches=sum(s['launches'] for s in selected),policy=dict(aggregate_fraction=coverage,absolute_family_ms=absolute_ms,all_invocations=True))

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--timeline-campaign',type=Path,required=True);p.add_argument('--manifest',type=Path,required=True)
    p.add_argument('--binary',type=Path,required=True);p.add_argument('--artifacts',type=Path,required=True);p.add_argument('--ncu-binary',type=Path,required=True)
    p.add_argument('--coverage',type=float,default=.99);p.add_argument('--absolute-ms',type=float,default=.1);p.add_argument('--scenarios',nargs='+')
    p.add_argument('--resume',action='store_true');p.add_argument('--allow-existing-graphics',action='store_true');p.add_argument('--allow-compute-pid',type=int,action='append',default=[])
    a=p.parse_args();assert 0<a.coverage<=1 and a.absolute_ms>=0
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=a.resume);start=time.monotonic();sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
    prior=json.loads((a.timeline_campaign/'campaign.json').read_text());cases=json.loads(a.manifest.read_text())['scenarios']
    if a.scenarios:cases=[c for c in cases if c['scenario'] in a.scenarios];assert len(cases)==len(a.scenarios)
    identity=dict(binary_sha256=sha(a.binary),modules={p.name:sha(p) for p in sorted(a.artifacts.glob('*.so'))})
    assert identity==prior['identity'],'Use the matching frozen profiling probe for reused kernel inventory'
    ncu=str(a.ncu_binary.resolve());record=dict(status='running',identity=identity,ncu=dict(path=ncu,version=subprocess.check_output([ncu,'--version'],text=True).strip(),sha256=sha(ncu)),scenarios=[],profiling_only=True)
    previous=json.loads((out/'campaign.json').read_text()) if a.resume and (out/'campaign.json').exists() else None
    if previous:assert previous['identity']==identity and previous['ncu']==record['ncu']
    opts=['--allow-existing-graphics'] if a.allow_existing_graphics else []
    for pid in a.allow_compute_pid:opts+=['--allow-compute-pid',str(pid)]
    def save():record['elapsed_this_invocation_seconds']=time.monotonic()-start;(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(cmd,log):
        with log.open('a') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=dict(os.environ,PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1'))
        if r.returncode:raise RuntimeError(f'Command failed; inspect {log}')
    for c in cases:
        name=c['scenario'];capture=out/name;attempt=0
        while capture.exists():attempt+=1;capture=out/(name+'-attempt'+str(attempt))
        row=dict(scenario=name,path=str(capture),input_sha256=c['input_sha256'],status='running');record['scenarios'].append(row);save()
        for f,h in c['input_sha256'].items():assert sha(f)==h
        old=next((r for r in previous['scenarios'] if r['scenario']==name and r['status']=='complete'),None) if previous else None
        if old:assert old['input_sha256']==c['input_sha256'];row.update(old);save();continue
        try:
            t=next(r for r in prior['scenarios'] if r['scenario']==name);assert t['input_sha256']==c['input_sha256']
            trace=json.loads((Path(t['timeline'])/'analysis.json').read_text());plan=select(trace,a.coverage,a.absolute_ms);row['selection']=plan
            (out/(name+'-selection.json')).write_text(json.dumps(plan,indent=2)+'\n')
            print(name,len(plan['targets']),'families',plan['expected_launches'],'launches',flush=True)
            expression='::regex:^('+'|'.join(re.escape(k['mangled']) for k in plan['targets'])+')$:'
            cmd=[sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(capture),'--binary',str(a.binary.resolve()),'--artifacts',str(a.artifacts.resolve()),'--replay-prefix',c['prefix'],'--repetitions','2','--watchdog-seconds','1800','--profiler','ncu','--ncu-binary',ncu,'--ncu-kernel-id',expression,'--ncu-name-base','mangled','--ncu-count','100000','--ncu-mode','full',*opts]
            if c.get('projectile_impulse'):cmd+=['--projectile-impulse']
            run(cmd,out/(name+'-driver.log'))
            with (capture/'counters.csv').open('w') as f:subprocess.run([ncu,'--import',str(capture/'counters.ncu-rep'),'--page','raw','--csv','--print-kernel-base','mangled'],stdout=f,check=True)
            launches=profile.counters(capture/'counters.csv');(capture/'analysis.json').write_text(json.dumps(launches)+'\n')
            actual=collections.Counter(x['name'] for x in launches);expected=collections.Counter({x['mangled']:x['launches'] for x in plan['targets']})
            row['missing_launches']=dict(expected-actual);row['extra_launches']=dict(actual-expected)
            run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/compare-observations.py'),str(ROOT/'out/snapshot-reset-20260911/prepared-full20'/('complete-'+name)),str(capture),str(capture/'physical-comparison.json')],capture/'compare.log')
            # A successful profiler exit is not proof all selected launches were recorded.
            if actual!=expected:raise RuntimeError('Counter inventory differs from Systems; preserve missing/extra launch audit')
            for launch in launches:
                m=launch['metrics']
                for k in ['gpu__time_duration.sum','launch__registers_per_thread','sm__warps_active.avg.pct_of_peak_sustained_active','smsp__warps_eligible.avg.per_cycle_active','smsp__issue_active.avg.pct_of_peak_sustained_active','dram__bytes.sum.per_second']:
                    assert k in m and isinstance(m[k]['value'],(int,float)) and math.isfinite(m[k]['value']),(name,k)
            row.update(status='complete',launches=len(launches),report_sha256=sha(capture/'counters.ncu-rep'),physical_comparison=str(capture/'physical-comparison.json'))
        except BaseException as e:row.update(status='failed',error=str(e));record['status']='failed';save();raise
        save()
    record['status']='complete';save()
if __name__=='__main__':main()
