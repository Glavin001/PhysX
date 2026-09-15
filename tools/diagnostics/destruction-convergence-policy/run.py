#!/usr/bin/env python3
"""Short native stopping-policy diagnostic; quality differences are results, not waived gates."""
import csv, fcntl, hashlib, importlib.util, json, math, os, signal, statistics as st, subprocess, sys, time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'out/destruction-baseline-20260913'
BUILD=ROOT/'out/destruction-convergence-policy-20260913/build'
OUT=ROOT/'out/destruction-convergence-policy-20260913/screen'
ARMS=['strict','tolerance','cap32','vibe32']
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
def save_json(p,j):p.write_text(json.dumps(j,indent=2)+'\n')
def stats(samples):
 x=[r['complete_step_ms'] for r in samples]
 return dict(n=len(x),mean_ms=st.mean(x),max_ms=max(x),min_ms=min(x),sd_ms=st.stdev(x),first_tick_ms=x[0],over_60hz=sum(v>1000/60 for v in x))
def main():
 OUT.mkdir(parents=True,exist_ok=False)
 build=json.loads((BUILD/'build.json').read_text());assert build['status']=='built_not_run'
 for p,h in build['outputs'].items():assert sha(p)==h,p
 spec=importlib.util.spec_from_file_location('timing',ROOT/'tools/scripts/run-destruction-timing.py');timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)
 probe=BASE/'harness/tools/diagnostics/destruction-snapshot/run-probe.py'
 catalog={c['scenario']:c for c in json.loads((BASE/'manifest.json').read_text())['scenarios']}
 record=dict(status='waiting_shared_lock',pid=os.getpid(),build_sha256=sha(BUILD/'build.json'),runner_sha256=sha(__file__),arms=ARMS,commands=[],scenarios=[],scope='Diagnostic changed numerical policy; no equal-quality or production qualification claim')
 start=None;child=None;desktop=False
 def save():
  if start is not None:record['seconds']=time.monotonic()-start
  save_json(OUT/'screen.json',record)
 def stop(signum,frame):raise RuntimeError('Interrupted '+str(signum))
 signal.signal(signal.SIGTERM,stop);signal.signal(signal.SIGINT,stop)
 def execute(case,arm,slot,continuous=False,original=False):
  nonlocal child
  dest=OUT/(case+'-'+slot);cmd=[sys.executable,str(probe),str(dest),'--binary',str((BASE/('native/native_destruction_demo' if continuous else 'plain/serialization-probe')) if original else BUILD/('native_destruction_demo' if continuous else 'serialization-probe')),'--artifacts',str(BASE/'artifacts' if original else BUILD),'--watchdog-seconds','90']
  if continuous:cmd+=['--native-args-json',str(OUT/(case+'-args.json'))]
  else:cmd+=['--replay-prefix',catalog[case]['prefix'],'--repetitions','3']
  env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),PHYSX_CONVERGENCE_ARM=arm,PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first',PYTHONDONTWRITEBYTECODE='1')
  row=dict(case=case,arm=arm,slot=slot,command=cmd,environment={k:env[k] for k in ['PHYSX_CONVERGENCE_ARM','PHYSX_SNAPSHOT_DUMP_OBSERVATIONS']},started_seconds=time.monotonic()-start)
  record['commands'].append(row);save();t=time.monotonic()
  with (OUT/(dest.name+'.log')).open('x') as log:
   child=subprocess.Popen(cmd,env=env,stdout=log,stderr=subprocess.STDOUT,start_new_session=True)
   try:code=child.wait(timeout=min(100,max(1,360-(time.monotonic()-start))))
   except BaseException:
    os.killpg(child.pid,signal.SIGTERM);child.wait(timeout=30);raise
  row.update(exit_code=code,seconds=time.monotonic()-t);save()
  if code:raise RuntimeError('Capture failed: '+str(dest))
  receipt=json.loads((dest/'receipt.json').read_text());assert receipt['status']=='complete'
  expected={str((BASE/'artifacts' if original else BUILD)/n):sha((BASE/'artifacts' if original else BUILD)/n) for n in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']}
  assert receipt['modules']==expected
  if continuous:
   summary=json.loads((dest/'native/native.summary.json').read_text());graph=json.loads((dest/'native/native.graph-diagnostics.json').read_text())
   with (dest/'native/native.frames.csv').open() as f:samples=[{k:float(v) for k,v in r.items()} for r in csv.DictReader(f)]
   assert len(samples)==summary['frames']==180 and summary['sleeping'] and not summary['direct_gpu_mode']
   assert not graph['boundary_audit_failures'] and not graph['registry_mismatch_fallbacks']
   assert all(s['resim_passes']<=1 and s['stress_passes']==1+s['resim_passes'] and s['step']==i for i,s in enumerate(samples))
   info=dict(initialization_ms=summary['initialization_ms'],total_broken=summary['broken_bonds'],final_clusters=samples[-1]['logical_clusters'],final_awake=samples[-1]['awake_bodies'],contacts=sum(s['contacts_frame'] for s in samples))
  else:
   replay=json.loads((dest/'replay.json').read_text());assert replay['passed'];samples=replay['samples'];info=dict(context_setup_ms=replay['context_setup_ms'],restore_mean_ms=st.mean(s['restore_ms'] for s in samples),broken_bonds=[s['broken_bonds'] for s in samples],output_clusters=[s['output_clusters'] for s in samples])
  if arm in ['strict','tolerance'] and not original:assert all(s['stress_converged']==1 for s in samples)
  if arm in ['cap32','vibe32']:assert max(s['stress_iterations'] for s in samples)<=32
  return dict(**stats(samples),**info,unconverged_ticks=sum(s.get('stress_converged',1)==0 for s in samples),iterations_mean=st.mean(s['stress_iterations'] for s in samples),iterations_max=max(s['stress_iterations'] for s in samples),raw=str(dest))
 save()
 with (ROOT/'out/destruction-ab.lock').open('a') as lease:
  fcntl.flock(lease,fcntl.LOCK_EX)
  try:
   start=time.monotonic();record['gpu_before']=timing.gpu()
   desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
   if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
   end=time.monotonic()+20
   while any(g['processes'] for g in timing.gpu()['devices']):
    if time.monotonic()>end:raise RuntimeError('GPU admission timeout')
    time.sleep(.25)
   record['gpu_admitted']=timing.gpu();record['status']='running';save()
   record['original_control']=execute('city25-initial-impact','strict','original',original=True);save()
   for case in ['tower64-cold','city25-initial-impact','city256-late-debris']:
    for p,h in catalog[case]['input_sha256'].items():assert sha(p)==h
    row=dict(case=case,mode='restored',runs={});record['scenarios'].append(row)
    for arm in ARMS:row['runs'][arm]=execute(case,arm,arm);save()
   for case in ['idle-256','impacts-256']:
    args=json.loads((BASE/'warm-args'/(case+'-warm-args.json')).read_text());args[args.index('--profile-phases')+1]='0';save_json(OUT/(case+'-args.json'),args)
    row=dict(case=case,mode='continuous',runs={});record['scenarios'].append(row)
    for rep,order in enumerate([ARMS,list(reversed(ARMS))]):
     for arm in order:
      slot=arm+'-'+str(rep);row['runs'][slot]=execute(case,arm,slot,continuous=True);save()
   record['status']='complete';record['gpu_after']=timing.gpu()
  except BaseException as e:record.update(status='failed',error=repr(e));raise
  finally:
   if child and child.poll() is None:os.killpg(child.pid,signal.SIGTERM);child.wait(timeout=30)
   if desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
   save()
 print(record['status'])
if __name__=='__main__':main()
