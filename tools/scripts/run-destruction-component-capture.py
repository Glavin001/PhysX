#!/usr/bin/env python3
"""Replay recorded workload using an explicitly isolated, intrusive diagnostic runtime."""
import argparse
import csv
import gzip
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import time
ROOT=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('timing_runner',Path(__file__).with_name('run-destruction-timing.py'))
timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('reference_report',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--case',default='impacts-256')
    p.add_argument('--library',type=Path,default=ROOT/'out/sdk-release/diagnostics/component-work/libPhysXDestructionGpuRuntime_64.so')
    args=p.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    report=json.loads(gzip.decompress(args.reference_report.read_bytes()))
    reference=report['manifest'];config=reference['config'];case=next(c for c in config['cases'] if c['id']==args.case)
    library=args.library.resolve();binary=Path(reference['binary'])
    if not library.is_file():raise RuntimeError('Build PhysXDestructionGpuWorkDiagnostic first')
    if sha(binary)!=reference['artifacts'][str(binary)]:raise RuntimeError('Reference executable changed')
    env=dict(os.environ);env['LD_LIBRARY_PATH']=str(library.parent)+(':'+env['LD_LIBRARY_PATH'] if env.get('LD_LIBRARY_PATH') else '')
    env['PHYSX_COMPONENT_WORK_OUTPUT']=str(out/'components.jsonl')
    binding=subprocess.check_output(['ldd',str(ROOT/'physx/bin/linux.x86_64/release/libPhysXGpuActivity_64.so')],env=env,text=True)
    if str(library) not in binding:raise RuntimeError('Diagnostic runtime was not selected')
    cmd=[str(binary),*config['common'],*case['args'],'--seconds',str(reference['seconds']),
         '--output',str(out/'scene'),'--profile-phases','0','--profile-gpu','0']
    production=ROOT/'physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so'
    manifest=dict(schema=1,status='running',purpose='intrusive component work audit, not performance qualification',
        source_report_sha256=sha(args.reference_report),case=args.case,config=config,command=cmd,
        artifacts={str(x):sha(x) for x in [binary,library,production]},ldd=binding,samples=[])
    def save():(out/'capture.json').write_text(json.dumps(manifest,indent=2)+'\n')
    save();process=None
    try:
        sample=timing.gpu();manifest['samples'].append(sample)
        if any(g['processes'] for g in sample['devices']):raise RuntimeError('GPU occupied; no services were stopped')
        with (out/'scene.log').open('w') as log:
            process=subprocess.Popen(cmd,cwd=ROOT,env=env,stdout=log,stderr=subprocess.STDOUT)
            gpu_pid=None
            while process.poll() is None:
                sample=timing.gpu();manifest['samples'].append(sample)
                processes=[v for g in sample['devices'] for v in g['processes']]
                if len(processes)>1:raise RuntimeError('Multiple GPU processes; diagnostic invalid')
                if processes:
                    pid=processes[0]['pid']
                    if gpu_pid is not None and gpu_pid!=pid:raise RuntimeError('GPU process changed')
                    gpu_pid=pid
                if len(manifest['samples'])>1200:raise RuntimeError('Diagnostic watchdog exceeded')
                time.sleep(.25)
            manifest['exit_code']=process.returncode
            if process.returncode:raise RuntimeError('Diagnostic scene failed; inspect scene.log')
        manifest['samples'].append(timing.gpu())
        if any(g['processes'] for g in manifest['samples'][-1]['devices']):raise RuntimeError('GPU occupied after capture')
        for path,digest in manifest['artifacts'].items():
            if sha(Path(path))!=digest:raise RuntimeError('Executable/library changed during capture')
        records=[json.loads(line) for line in (out/'components.jsonl').open()]
        totals=[r for r in records if r['record']=='total']
        frames=list(csv.DictReader((out/'scene/native.frames.csv').open()))
        if [r['solve'] for r in totals]!=list(range(len(frames))):raise RuntimeError('Cannot map solves one-to-one to scene steps')
        base=report['runs'][args.case]['plain'][0]['frames']
        if len(base)!=len(frames):raise RuntimeError('Reference duration changed')
        fields=['bodies','awake_bodies','logical_clusters','contacts_frame','stress_active_nodes','stress_active_bonds',
                'stress_islands','stress_iterations','bonds_broken','resim_passes','stress_converged']
        changes=[dict(step=i,field=k,reference=a[k],diagnostic=b[k]) for i,(a,b) in enumerate(zip(base,frames)) for k in fields if a[k]!=b[k]]
        (out/'counter-differences.json').write_text(json.dumps(changes,indent=2)+'\n')
        manifest['counter_differences']=len(changes)
        manifest['unmeasured_component_records']=sum(t['unmeasured_components'] for t in totals)
        (out/'work-totals.json').write_text(json.dumps(totals,indent=2)+'\n')
        timing.compress_csv(out/'scene')
        raw=out/'components.jsonl'
        with raw.open('rb') as inp,(out/'components.jsonl.gz').open('wb') as dest:
            with gzip.GzipFile(filename='',mode='wb',fileobj=dest,mtime=0) as z:
                import shutil
                shutil.copyfileobj(inp,z)
        raw.unlink()
        manifest['files']={str(f.relative_to(out)):sha(f) for f in sorted(out.rglob('*')) if f.is_file() and f.name!='capture.json'}
        manifest['status']='complete';save();print(out/'capture.json')
    except BaseException as e:
        if process is not None and process.poll() is None:process.terminate();process.wait(timeout=30)
        manifest['status']='failed';manifest['error']=str(e);save();raise

if __name__=='__main__':main()
