"""Existing independent oracles, asynchronous native checks, then matched light ticks."""
import fcntl,hashlib,importlib.util,json,os,signal,subprocess,sys,time
from pathlib import Path
base=Path(__file__).resolve().parent;root=base.parents[1];out=base/'screen';out.mkdir(exist_ok=False)
spec=importlib.util.spec_from_file_location('timing',root/'tools/scripts/run-destruction-timing.py');timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)
record=dict(status='running',commit=json.loads((base/'preparation.json').read_text())['commit'],stages=[],
    scope='Qualification and light prioritization only; no all-suite or speedup acceptance. Existing tests/gates unchanged; both arms use selected N13 policy and retained N20 CPU allocation; N24 changes component-local preconditioning only.')
sha=lambda p:hashlib.sha256(Path(p).read_bytes()).hexdigest()
record['runner_sha256']=sha(__file__)
def save():(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
def run(name,cmd,standalone=False):
    row=dict(name=name,command=cmd,status='running');record['stages'].append(row);save();start=time.monotonic()
    if standalone:
        lock=(root/'out/destruction-ab.lock').open('a');fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
        before=timing.gpu();assert not any(g['processes'] for g in before['devices']);row['gpu_before']=before
    with (out/(name+'.log')).open('w') as log:
        proc=subprocess.Popen(cmd,cwd=root,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
        try:result=proc.wait(timeout=900)
        except BaseException:
            os.killpg(proc.pid,signal.SIGKILL);proc.wait();raise
        finally:
            if standalone:
                row['gpu_after']=timing.gpu();fcntl.flock(lock,fcntl.LOCK_UN);lock.close()
    row.update(exit_code=result,seconds=time.monotonic()-start,status='passed' if result==0 else 'failed')
    if standalone:
        audit=subprocess.run(['journalctl','-k','--since','@'+str(int(before['unix_seconds'])),'--no-pager','-g','NVRM: Xid'],capture_output=True,text=True)
        row['fault_audit']=dict(exit_code=audit.returncode,stdout=audit.stdout,stderr=audit.stderr)
        assert audit.returncode in [0,1] and not audit.stderr.strip() and 'NVRM: Xid' not in audit.stdout
    save();assert result==0,name
try:
    assert os.environ.get('CUDA_LAUNCH_BLOCKING','0')=='0'
    builds={n:json.loads((base/n/'build.json').read_text()) for n in ['build','oracles']}
    for b in builds.values():
        assert b['status']=='built_not_gpu_qualified'
        for p,h in b['outputs'].items():assert sha(p)==h
    for arm in ['A','B']:
        for test in ['gpu_resident_stress_test','gpu_resident_stress_3d_test','gpu_resident_motion_modes_test']:
            run(arm+'-'+test,[str(base/'oracles'/arm/test)],True)
        for sanitizer in ['memcheck','initcheck','synccheck']:
            run(arm+'-'+sanitizer,['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',sanitizer,'--error-exitcode','97',str(base/'oracles'/arm/'gpu_resident_stress_3d_test')],True)
    source=json.loads((root/'out/snapshot-light-20260911/full-manifest/manifest.json').read_text())
    for arm in ['A','B']:
        for name in ['flying','city25-initial-impact','city256-late-debris']:
            case=next(c for c in source['scenarios'] if c['scenario']==name);dest=out/(arm+'-'+name+'-memcheck')
            cmd=[sys.executable,str(root/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(dest),
                '--binary',str(root/'out/n20-requalification-20260912/build/B/serialization-probe'),
                '--artifacts',str(base/'build'/arm),'--replay-prefix',case['prefix'],'--repetitions','2','--sanitizer','memcheck','--watchdog-seconds','900']
            if case.get('projectile_impulse'):cmd+=['--projectile-impulse']
            # Existing snapshot runner exports observations and checks repeatability.
            os.environ['PHYSX_SNAPSHOT_DUMP_OBSERVATIONS']='first'
            run(arm+'-'+name+'-memcheck',cmd)
            run(arm+'-'+name+'-physical',[sys.executable,str(root/'tools/diagnostics/destruction-snapshot/compare-observations.py'),
                str(root/'out/snapshot-reset-20260911/prepared-full20'/('complete-'+name)),str(dest),str(out/(arm+'-'+name+'-physical.json'))])
    run('matched-light',[sys.executable,str(root/'tools/diagnostics/destruction-snapshot/run-matched.py'),str(out/'matched-light'),
        '--manifest',str(root/'out/snapshot-light-20260911/confirmation/manifest.json'),'--use-case-repetitions',
        '--binary',str(root/'out/n20-requalification-20260912/build/B/serialization-probe'),
        '--baseline-artifacts',str(base/'build/A'),'--candidate-artifacts',str(base/'build/B'),'--candidate-commit',record['commit']])
    record['status']='screen_complete_pending_review'
except BaseException as exc:record.update(status='failed',error=repr(exc));save();raise
save()
