#!/usr/bin/env python3
"""Collect every nonempty graph launch with full counters, auditing timeline coverage.

Graph counters supplement individual-kernel timelines/selected node counters.
They do not supply individual conditional-node or instruction-source metrics.
"""
import argparse,hashlib,importlib.util,json,math,os,sqlite3,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('profile',Path(__file__).with_name('analyze-profile.py'));profile=importlib.util.module_from_spec(spec);spec.loader.exec_module(profile)

def inventory(path):
    db=sqlite3.connect(f'file:{path/"trace.sqlite"}?mode=ro',uri=True);db.row_factory=sqlite3.Row
    lo,hi=db.execute("select start,end from NVTX_EVENTS where text='snapshot/full_tick'").fetchone()
    tables={r[0] for r in db.execute("select name from sqlite_master where type='table'")};launches=[]
    for table in ['CUPTI_ACTIVITY_KIND_RUNTIME','CUPTI_ACTIVITY_KIND_DRIVER']:
        if table not in tables:continue
        for r in db.execute(f'select a.*,s.value as name from {table} a join StringIds s on s.id=a.nameId where a.start>=? and a.end<=? and s.value like "%GraphLaunch%" order by a.start',(lo,hi)):
            nodes=[dict(k) for k in db.execute('select k.*,s.value as name from CUPTI_ACTIVITY_KIND_KERNEL k join StringIds s on k.mangledName=s.id where correlationId=? and start>=? and end<=? order by start',(r['correlationId'],lo,hi))]
            if nodes:launches.append(dict(api=r['name'],correlation_id=r['correlationId'],start_ns=r['start'],nodes=[dict(name=k['name'],graph_id=k['graphId'],node_id=k['graphNodeId'],ms=(k['end']-k['start'])/1e6) for k in nodes]))
    # Runtime and driver tables can both describe a launch. Distinct correlation
    # IDs with nodes avoid treating an empty outer wrapper as a second graph.
    assert len({r['correlation_id'] for r in launches})==len(launches)
    return sorted(launches,key=lambda r:r['start_ns'])

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--timeline-campaign',type=Path,required=True);p.add_argument('--manifest',type=Path,required=True)
    p.add_argument('--binary',type=Path,required=True);p.add_argument('--artifacts',type=Path,required=True)
    p.add_argument('--ncu-binary',type=Path,default=Path('/opt/nvidia/nsight-compute/2025.3.1/ncu'))
    p.add_argument('--resume',action='store_true');p.add_argument('--scenarios',nargs='+');p.add_argument('--reuse-pilot',type=Path)
    p.add_argument('--allow-existing-graphics',action='store_true');a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=a.resume)
    sha=lambda f:hashlib.sha256(Path(f).read_bytes()).hexdigest();start=time.monotonic()
    prior=json.loads((a.timeline_campaign/'campaign.json').read_text());cases=json.loads(a.manifest.read_text())['scenarios']
    identity=dict(binary_sha256=sha(a.binary),modules={p.name:sha(p) for p in sorted(a.artifacts.glob('*.so'))});assert identity==prior['identity']
    if a.scenarios:cases=[c for c in cases if c['scenario'] in a.scenarios];assert len(cases)==len(a.scenarios)
    previous=json.loads((out/'campaign.json').read_text()) if a.resume and (out/'campaign.json').exists() else None
    if previous:assert previous['identity']==identity
    if previous:(out/('campaign-before-resume-'+str(time.time_ns())+'.json')).write_bytes((out/'campaign.json').read_bytes())
    record=dict(status='running',identity=identity,scenarios=[],scope='Full counters for each nonempty graph invocation, with optional host analysis rules disabled. Individual conditional-node and source counters remain unavailable.')
    def save():record['elapsed_this_invocation_seconds']=time.monotonic()-start;(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(cmd,log):
        with log.open('a') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=dict(os.environ,PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1'),check=True)
    for c in cases:
        name=c['scenario'];old=next((r for r in previous['scenarios'] if r['scenario']==name and r['status']=='complete'),None) if previous else None
        if old:assert old['input_sha256']==c['input_sha256'];record['scenarios'].append(old);save();continue
        for f,h in c['input_sha256'].items():assert sha(f)==h
        timeline=next(r for r in prior['scenarios'] if r['scenario']==name);assert timeline['input_sha256']==c['input_sha256']
        expected=inventory(Path(timeline['timeline']));row=dict(scenario=name,status='running',input_sha256=c['input_sha256'],expected_graph_launches=len(expected),timeline=timeline['timeline'],graph_inventory=expected);record['scenarios'].append(row);save()
        try:
            if not expected:row.update(status='complete',captured_graph_launches=0,note='No nonempty graph workload in this tick; kernel timelines and individual counters apply.');save();continue
            capture=out/name;attempt=0
            while capture.exists():attempt+=1;capture=out/(name+'-attempt'+str(attempt))
            if a.reuse_pilot and name=='city25-initial-impact':capture=a.reuse_pilot.resolve()
            else:
                cmd=[sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(capture),'--binary',str(a.binary.resolve()),'--artifacts',str(a.artifacts.resolve()),'--replay-prefix',c['prefix'],'--repetitions','2','--watchdog-seconds','900','--profiler','ncu','--ncu-binary',str(a.ncu_binary.resolve()),'--ncu-kernel','regex:^graph$','--ncu-name-base','mangled','--ncu-graph','graph','--ncu-apply-rules','no','--ncu-count','100000','--ncu-mode','full']
                if a.allow_existing_graphics:cmd+=['--allow-existing-graphics']
                if c.get('projectile_impulse'):cmd+=['--projectile-impulse']
                print(name,len(expected),'graph launches',flush=True);run(cmd,out/(name+'-driver.log'))
            row['path']=str(capture);receipt=json.loads((capture/'receipt.json').read_text());assert receipt['status']=='complete' and receipt['binary_sha256']==identity['binary_sha256'] and receipt['snapshot_inputs']==c['input_sha256']
            assert {Path(k).name:v for k,v in receipt['modules'].items()}==identity['modules']
            assert receipt['profiler']['binary']['sha256']==sha(a.ncu_binary)
            with (capture/'counters.csv').open('w') as f:subprocess.run([str(a.ncu_binary.resolve()),'--import',str(capture/'counters.ncu-rep'),'--page','raw','--csv','--print-kernel-base','mangled'],stdout=f,check=True)
            data=profile.counters(capture/'counters.csv');(capture/'analysis.json').write_text(json.dumps(data)+'\n');row['captured_graph_launches']=len(data)
            assert len(data)==len(expected) and all(d['name']=='graph' for d in data),'Nonempty graph invocation inventory mismatch'
            for d in data:
                for k in ['gpu__time_duration.sum','sm__warps_active.avg.pct_of_peak_sustained_active','smsp__issue_active.avg.pct_of_peak_sustained_active','dram__bytes.sum.per_second']:
                    assert math.isfinite(d['metrics'][k]['value']),(name,k)
            comparison=capture/'physical-comparison.json'
            if comparison.exists():comparison=capture/('physical-comparison-graph-audit-'+str(time.time_ns())+'.json')
            run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/compare-observations.py'),str(ROOT/'out/snapshot-reset-20260911/prepared-full20'/('complete-'+name)),str(capture),str(comparison)],capture/'compare.log')
            row.update(status='complete',report_sha256=sha(capture/'counters.ncu-rep'),physical_comparison=str(comparison));save()
        except BaseException as e:row.update(status='failed',error=str(e));record['status']='failed';save();raise
    record['status']='complete';save();print('complete',out)

if __name__=='__main__':main()
