#!/usr/bin/env python3
"""Execute an explicit warm-window plan serially, saving every command/result."""
import argparse, fcntl, hashlib, importlib.util, json, os, signal, subprocess, sys, time
from pathlib import Path
root=Path(__file__).resolve().parents[3];here=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('plan',type=Path);p.add_argument('output',type=Path);p.add_argument('--manage-desktop',action='store_true');p.add_argument('--budget-seconds',type=float,default=300);p.add_argument('--contract-version',choices=['1','2','3','4'],default='1',help='Version 2 admits ordinary scenes with no destruction stage; version 3 additionally bounds bond forces per bond relative to their norm and health drift, for numerical-policy candidates');a=p.parse_args()
plan=json.loads(a.plan.read_text());out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
record=dict(status='starting',plan=plan,plan_sha256=hashlib.sha256(a.plan.read_bytes()).hexdigest(),jobs=[],pid=os.getpid())
spec=importlib.util.spec_from_file_location('capture',root/'tools/scripts/run-destruction-timing.py');c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
suffix={'1':'','2':'-v2','3':'-v3','4':'-v4'}[a.contract_version]
contract_path=here/('warm-window-contract'+suffix+'.py');checker_path=here/('compare-warm-observations'+suffix+'.py')
cspec=importlib.util.spec_from_file_location('contract',contract_path);contract=importlib.util.module_from_spec(cspec);cspec.loader.exec_module(contract)
record.update(contract_version=a.contract_version,checker_sha256={str(q):hashlib.sha256(q.read_bytes()).hexdigest() for q in [contract_path,checker_path]})
def save():(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
def stop(sig,frame):raise RuntimeError(f'Interrupted by signal {sig}')
for sig in (signal.SIGTERM,signal.SIGINT):signal.signal(sig,stop)
child=None;desktop=False;start=time.monotonic();env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first')
def run(cmd,log):
    global child
    remaining=a.budget_seconds-(time.monotonic()-start)
    if remaining<=0:raise RuntimeError('Campaign budget exhausted')
    with log.open('w') as f:
        child=subprocess.Popen(list(map(str,cmd)),env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
        try:return child.wait(timeout=remaining)
        finally:
            if child.poll() is None:
                os.killpg(child.pid,signal.SIGTERM)
                try:child.wait(timeout=10)
                except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.wait()
            child=None
with (root/'out/destruction-ab.lock').open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    try:
        desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
        if desktop and not a.manage_desktop:raise RuntimeError('Desktop active: authorized --manage-desktop required')
        if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
        for attempt in range(50):
            gpu=c.gpu()
            if gpu.get('devices') and not any(g['processes'] for g in gpu['devices']):break
            time.sleep(.2)
        else:raise RuntimeError('GPU not exclusively available')
        record.update(status='running',initial_gpu=gpu);save()
        for job in plan['jobs']:
            if job.get('profiler') and any(j['status']=='failed' for j in record['jobs']):
                record['jobs'].append(dict(name=job['name'],status='skipped',reason='Plain trajectory qualification failed; resolve before profiling'))
                save();continue
            dest=out/job['name'];profile=job.get('profiler');binary=job.get('binary',plan['profile_binary'] if profile else plan['binary'])
            cmd=[sys.executable,here/'run-probe.py',dest,'--binary',binary,'--artifacts',job.get('artifacts',plan['artifacts']),'--replay-prefix',job['prefix'],'--repetitions',str(job.get('repetitions',2)),'--watchdog-seconds',str(min(180,a.budget_seconds))]
            if 'warmup_ticks' in job:cmd+=['--warmup-ticks',str(job['warmup_ticks']),'--measure-ticks',str(job.get('measure_ticks',1))]
            if job.get('projectile_impulse'):cmd+=['--projectile-impulse']
            if profile=='nsys':cmd+=['--profiler','nsys','--nsys-cpu','--nsys-range','first-tick']
            if profile=='ncu':
                cmd+=['--profiler','ncu','--ncu-mode','hardware','--ncu-count',str(job.get('ncu_count',2)),
                    '--ncu-metrics',job.get('ncu_metrics','gpu__time_duration.sum,sm__warps_active.avg.pct_of_peak_sustained_active,smsp__issue_active.avg.pct_of_peak_sustained_active,dram__bytes.sum.per_second,launch__registers_per_thread')]
                if job.get('ncu_kernel'):cmd+=['--ncu-kernel',job['ncu_kernel']]
            entry=dict(name=job['name'],command=list(map(str,cmd)),status='running');record['jobs'].append(entry);save();before=time.monotonic()
            code=run(cmd,out/(job['name']+'.log'));entry.update(exit_code=code,elapsed_seconds=time.monotonic()-before,status='complete' if code==0 else 'failed')
            if code==0:
                try:
                    r=json.loads((dest/'replay.json').read_text());contract.schedule(r)
                    if job.get('compare_to'):
                        code=run([sys.executable,checker_path,out/job['compare_to'],dest,out/(job['name']+'-physical.json'),'--all-errors'],out/(job['name']+'-check.log'))
                        entry['physical_comparison_exit_code']=code
                        if code:entry['status']='failed'
                except Exception as e:entry.update(status='failed',error=str(e))
            save()
            print(entry['name'],entry['status'],round(entry['elapsed_seconds'],2),flush=True)
        record['status']='complete' if all(j['status']=='complete' for j in record['jobs']) else 'failed'
    except BaseException as e:
        record.update(status='failed',error=str(e))
        for j in record['jobs']:
            if j['status']=='running':j.update(status='interrupted',error=str(e))
        raise
    finally:
        if desktop and a.manage_desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
        record['elapsed_seconds']=time.monotonic()-start;save()
print(record['status'],round(record['elapsed_seconds'],2),out)
sys.exit(record['status']!='complete')
