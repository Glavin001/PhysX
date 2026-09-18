#!/usr/bin/env python3
"""Collect complete CPU/GPU attribution for each saved full-tick scenario, serially."""
import argparse,hashlib,json,os,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
    p.add_argument('--manifest',type=Path,required=True);p.add_argument('--binary',type=Path,required=True);p.add_argument('--artifacts',type=Path,required=True)
    p.add_argument('--preset',choices=['light','full'],default='full');p.add_argument('--resume',action='store_true')
    p.add_argument('--allow-existing-graphics',action='store_true');p.add_argument('--allow-compute-pid',type=int,action='append',default=[])
    a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=a.resume);start=time.monotonic()
    sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
    cases=json.loads(a.manifest.read_text())['scenarios']
    if a.preset=='light':
        names={c['scenario'] for c in json.loads((ROOT/'tools/profiles/destruction-snapshot-light.json').read_text())['scenarios']};cases=[c for c in cases if c['scenario'] in names]
    identity=dict(binary_sha256=sha(a.binary),modules={x.name:sha(x) for x in sorted(a.artifacts.glob('*.so'))})
    record=dict(status='running',identity=identity,manifest=str(a.manifest.resolve()),scenarios=[],profiling_only=True)
    previous=json.loads((out/'campaign.json').read_text()) if a.resume and (out/'campaign.json').exists() else None
    if previous:assert previous['identity']==identity
    options=['--allow-existing-graphics'] if a.allow_existing_graphics else []
    for pid in a.allow_compute_pid:options+=['--allow-compute-pid',str(pid)]
    def save():record['elapsed_this_invocation_seconds']=time.monotonic()-start;(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    def run(cmd,log):
        with log.open('a') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,env=dict(os.environ,PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1'))
        if r.returncode:raise RuntimeError(f'Failed command; see {log}')
    for c in cases:
        name=c['scenario'];capture=out/name;attempt=0
        while capture.exists():attempt+=1;capture=out/(name+'-attempt'+str(attempt))
        row=dict(scenario=name,path=str(capture),input_sha256=c['input_sha256'],status='running');record['scenarios'].append(row);save()
        for f,h in c['input_sha256'].items():assert sha(f)==h
        old=next((r for r in previous['scenarios'] if r['scenario']==name and r['status']=='complete'),None) if previous else None
        if old:
            assert old['input_sha256']==c['input_sha256'];row.update(old);save();continue
        try:
            print(name,'CPU/GPU attribution',flush=True)
            cmd=[sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(capture),'--binary',str(a.binary.resolve()),'--artifacts',str(a.artifacts.resolve()),'--replay-prefix',c['prefix'],'--repetitions','2','--watchdog-seconds','600','--profiler','nsys','--nsys-cpu',*options]
            if c.get('projectile_impulse'):cmd+=['--projectile-impulse']
            run(cmd,out/(name+'-driver.log'))
            run(['/opt/nvidia/nsight-systems/2026.3.2/bin/nsys','export','--type','sqlite','--output',str(capture/'trace.sqlite'),str(capture/'trace.nsys-rep')],capture/'export.log')
            run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/compare-observations.py'),str(ROOT/'out/snapshot-reset-20260911/prepared-full20'/('complete-'+name)),str(capture),str(capture/'physical-comparison.json')],capture/'compare.log')
            run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/analyze-attribution.py'),str(capture)],capture/'analysis.log')
            d=json.loads((capture/'attribution.json').read_text());assert d['cpu_attribution']['samples']>0
            row.update(status='complete',cpu_samples=d['cpu_attribution']['samples'],engine_scopes=d['cpu_attribution']['nvtx_scope_count'],kernel_launches=d['kernel_count'],trace_sha256=sha(capture/'trace.nsys-rep'),physical_comparison=str(capture/'physical-comparison.json'))
        except BaseException as e:row.update(status='failed',error=str(e));record['status']='failed';save();raise
        save()
    record['status']='complete';save()
if __name__=='__main__':main()
