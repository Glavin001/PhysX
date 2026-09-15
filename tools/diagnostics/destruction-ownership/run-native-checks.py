#!/usr/bin/env python3
"""Run a bounded native correctness plan under the existing GPU lease/provenance wrapper."""
import argparse, csv, fcntl, importlib.util, json, os, signal, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('plan',type=Path);p.add_argument('output',type=Path);p.add_argument('--budget-seconds',type=float,default=180);a=p.parse_args()
plan=json.loads(a.plan.read_text());out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
spec=importlib.util.spec_from_file_location('timing',ROOT/'tools/scripts/run-destruction-timing.py');timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)
record=dict(status='starting',plan=plan,pid=os.getpid(),jobs=[]);start=time.monotonic();child=None;desktop=False
def save():(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
def interrupted(sig,frame):raise RuntimeError('Interrupted '+str(sig))
def terminate_group(pgid):
    # A profiler/sanitizer can exit before its reparented target. The group was
    # created by this wrapper and belongs solely to this job, even after the
    # immediate child exits. Do not release the GPU lease with that target live.
    try:os.killpg(pgid,signal.SIGTERM)
    except ProcessLookupError:return
    for i in range(30):
        try:os.killpg(pgid,0)
        except ProcessLookupError:return
        time.sleep(.1)
    try:os.killpg(pgid,signal.SIGKILL)
    except ProcessLookupError:pass
for sig in (signal.SIGINT,signal.SIGTERM):signal.signal(sig,interrupted)
with (ROOT/'out/destruction-ab.lock').open('a') as lease:
    fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
    try:
        desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
        if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
        for i in range(50):
            gpu=timing.gpu()
            if gpu.get('devices') and not any(g['processes'] for g in gpu['devices']):break
            time.sleep(.2)
        else:raise RuntimeError('GPU admission failed')
        record.update(status='running',initial_gpu=gpu);save()
        for job in plan['jobs']:
            args=out/(job['name']+'-args.json');args.write_text(json.dumps(job.get('args',[]))+'\n')
            cmd=[sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(out/job['name']),'--binary',job['binary'],'--artifacts',job['artifacts'],'--native-args-json' if job.get('continuous') else '--test-args-json',str(args),'--watchdog-seconds',str(job.get('watchdog_seconds',90))]
            if job.get('sanitizer'):cmd+=['--sanitizer',job['sanitizer']]
            if job.get('sanitizer_check_api_memory_access'):cmd+=['--sanitizer-check-api-memory-access',job['sanitizer_check_api_memory_access']]
            row=dict(name=job['name'],command=cmd,status='running');record['jobs'].append(row);save();before=time.monotonic()
            with (out/(job['name']+'.log')).open('x') as log:
                child=subprocess.Popen(cmd,stdout=log,stderr=subprocess.STDOUT,start_new_session=True,env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid())))
                row['process_group']=child.pid;save()
                code=child.wait(timeout=max(1,a.budget_seconds-(time.monotonic()-start)))
                terminate_group(child.pid);child=None
            if code==0 and job.get('continuous'):
                try:
                    # Reuse the established uninterrupted work/convergence and
                    # complete-step partition contract; do not label this a
                    # complete physical-array trajectory comparison.
                    spec=importlib.util.spec_from_file_location('representative',ROOT/'tools/diagnostics/destruction-snapshot/run-representative-screen.py')
                    representative=importlib.util.module_from_spec(spec);spec.loader.exec_module(representative)
                    dest=out/job['name']/'native'
                    summary=json.loads((dest/'native.summary.json').read_text())
                    graph=json.loads((dest/'native.graph-diagnostics.json').read_text())
                    with (dest/'native.frames.csv').open() as f:frames=[{k:float(v) for k,v in row.items()} for row in csv.DictReader(f)]
                    arguments=job['args'];expected=int(float(arguments[arguments.index('--seconds')+1])*60)
                    assert summary['status']=='completed' and summary['sleeping'] and not summary['direct_gpu_mode']
                    assert summary['correction_limit']==1 and summary['frames']==len(frames)==expected
                    assert not graph['boundary_audit_failures'] and not graph['registry_mismatch_fallbacks']
                    assert all(v['stress_converged']==1 and v['resim_passes']<=1 and v['step']==i for i,v in enumerate(frames))
                    work_keys=representative.WORK+['stress_iterations']
                    history=[{k:v[k] for k in work_keys} for v in frames]
                    if job.get('compare_to'):
                        reference=json.loads((out/(job['compare_to']+'-work-history.json')).read_text())
                        assert history==reference,'Uninterrupted work/iteration history changed'
                    (out/(job['name']+'-work-history.json')).write_text(json.dumps(history)+'\n')
                    row['physical_scope']='exact work/iteration/convergence history; no full pose/force arrays'
                    row['statistics']=representative.statistics(frames,True)
                    row['statistics']['initialization_ms']=summary['initialization_ms']
                    row['statistics']['scale']={k:summary[k] for k in ['chunks','bonds','projectiles','buildings']}
                except Exception as error:code=2;row['validation_error']=repr(error)
            row.update(exit_code=code,status='complete' if code==0 else 'failed',seconds=time.monotonic()-before);save();print(row['name'],row['status'],round(row['seconds'],2),flush=True)
            if code and not job.get('continue_on_failure'):raise RuntimeError('Native correctness failed: '+job['name'])
        record['status']='complete' if all(j['status']=='complete' for j in record['jobs']) else 'failed'
    except BaseException as e:record.update(status='failed',error=repr(e));raise
    finally:
        if child:
            # Also clean descendants when an exception arrives after their
            # immediate launcher has already exited.
            terminate_group(child.pid)
            try:child.wait(timeout=10)
            except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.wait()
        if desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
        record['elapsed_seconds']=time.monotonic()-start;save()
print(record['status'])
sys.exit(record['status']!='complete')
