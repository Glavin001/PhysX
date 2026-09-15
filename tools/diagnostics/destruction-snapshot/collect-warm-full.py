#!/usr/bin/env python3
"""Warm full52 attribution: matched timing audit, CPU/GPU timelines, graph/config counters."""
import argparse,collections,fcntl,hashlib,importlib.util,json,math,os,re,signal,sqlite3,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];HERE=Path(__file__).resolve().parent
p=argparse.ArgumentParser(description=__doc__);p.add_argument('manifest',type=Path);p.add_argument('output',type=Path);p.add_argument('--timings',type=Path,required=True);p.add_argument('--reuse',type=Path,required=True);p.add_argument('--tier',choices=['cpu','counters'],required=True);p.add_argument('--cpu',type=Path);p.add_argument('--scenarios',nargs='+');p.add_argument('--budget-seconds',type=float,default=1800);p.add_argument('--nsys-range',choices=['process','first-tick'],default='first-tick');p.add_argument('--metric-tier',choices=['core','detailed'],default='core');a=p.parse_args()
def load(name,file):
 s=importlib.util.spec_from_file_location(name,file);m=importlib.util.module_from_spec(s);s.loader.exec_module(m);return m
capture=load('capture',ROOT/'tools/scripts/run-destruction-timing.py');checker=load('checker',HERE/'compare-warm-observations-v2.py');profile=load('profile',HERE/'analyze-profile.py');config=load('config',HERE/'profile-config-suite.py');graph=load('graph',HERE/'warm-profile-graphs.py')
manifest=json.loads(a.manifest.read_text());reuse=json.loads(a.reuse.read_text());out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);cases=manifest['scenarios']
if a.scenarios:cases=[c for c in cases if c['scenario'] in a.scenarios]
# Largest and a static case qualify recording options before broad expansion.
cases=sorted(cases,key=lambda c:(0 if c['scenario']=='city256-late-debris' else 1 if c['scenario']=='bridge64-cold' else 2,c['scenario']))
sha=lambda path:hashlib.sha256(Path(path).read_bytes()).hexdigest()
record=dict(status='waiting_shared_gpu_lock',pid=os.getpid(),tier=a.tier,manifest=str(a.manifest.resolve()),manifest_sha256=sha(a.manifest),scenarios=[],tools_sha256={str(q):sha(q) for q in [Path(__file__),HERE/'run-probe.py',HERE/'compare-warm-observations-v2.py',HERE/'warm-window-contract-v2.py']})
record['metrics']=['gpu__time_duration.sum','sm__warps_active.avg.pct_of_peak_sustained_active','smsp__warps_eligible.avg.per_cycle_active','smsp__issue_active.avg.pct_of_peak_sustained_active','sm__pipe_fp64_cycles_active.avg.pct_of_peak_sustained_elapsed','dram__bytes.sum.per_second','launch__registers_per_thread','launch__shared_mem_per_block_static','launch__shared_mem_per_block_dynamic','l1tex__t_sector_hit_rate.pct','lts__t_sector_hit_rate.pct','l1tex__t_sectors_pipe_lsu_mem_local_op_ld.sum','l1tex__t_sectors_pipe_lsu_mem_local_op_st.sum','smsp__average_warps_issue_stalled_long_scoreboard_per_issue_active.ratio','smsp__average_warps_issue_stalled_barrier_per_issue_active.ratio']
record['metric_tier']=a.metric_tier
if a.metric_tier=='core':record['metrics']=['gpu__time_duration.sum','sm__warps_active.avg.pct_of_peak_sustained_active','smsp__issue_active.avg.pct_of_peak_sustained_active','dram__bytes.sum.per_second','launch__registers_per_thread','launch__shared_mem_per_block_static','launch__shared_mem_per_block_dynamic']
child=None;desktop=False;start=None
def save():
 record['elapsed_seconds']=time.monotonic()-start if start else 0;(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
def stopped(sig,frame):raise RuntimeError('Interrupted by signal '+str(sig))
for sig in (signal.SIGINT,signal.SIGTERM):signal.signal(sig,stopped)
env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first')
def run(cmd,log,timeout=180):
 global child
 remaining=a.budget_seconds-(time.monotonic()-start)
 if remaining<=0:raise TimeoutError('Campaign budget exhausted')
 with log.open('w') as f:
  child=subprocess.Popen(list(map(str,cmd)),env=env,stdout=f,stderr=subprocess.STDOUT,start_new_session=True)
  try:
   code=child.wait(timeout=min(timeout,remaining))
   if code:raise RuntimeError(f'Command exit{code}; inspect {log}')
  finally:
   if child.poll() is None:
    os.killpg(child.pid,signal.SIGTERM)
    try:child.wait(timeout=10)
    except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.wait()
   child=None

def reference(c):
 paths=[Path(x) for x in reuse.get(c['scenario'],[])] or [a.timings/(c['scenario']+'-'+arm) for arm in ('A0','A1')]
 for q in paths:
  r=json.loads((q/'receipt.json').read_text());assert r['status']=='complete';assert r['binary_sha256']==sha(manifest['binary']);assert r['snapshot_inputs']==c['input_sha256']
  v=json.loads((q/'replay.json').read_text());assert checker.contract.schedule(v)==(c['warmup_ticks'],c['measure_ticks'],bool(c.get('projectile_impulse')))
 result=checker.compare(*paths,collect_failures=True)
 (out/(c['scenario']+'-timing-physical.json')).write_text(json.dumps(result,indent=2)+'\n')
 assert result['status']=='passed','Plain cross-process physical comparison failed'
 return paths[0],paths

def base(c,dest):
 cmd=[sys.executable,HERE/'run-probe.py',dest,'--binary',manifest['profile_binary'],'--artifacts',manifest['artifacts'],'--replay-prefix',c['prefix'],'--repetitions','2','--warmup-ticks',str(c['warmup_ticks']),'--measure-ticks',str(c['measure_ticks']),'--watchdog-seconds','170']
 if c.get('projectile_impulse'):cmd+=['--projectile-impulse']
 return cmd

def check(ref,dest):
 result=checker.compare(ref,dest,collect_failures=True);(dest/'physical-comparison.json').write_text(json.dumps(result,indent=2)+'\n');assert result['status']=='passed','Profile changes physical/work outputs'

def ncu(c,ref,row,kind,selection,expected):
 metrics=[m for m in record['metrics'] if kind!='graph' or m not in ('launch__shared_mem_per_block_static','launch__shared_mem_per_block_dynamic')]
 dest=out/(c['scenario']+'-'+kind);cmd=base(c,dest)+['--profiler','ncu','--ncu-mode','hardware','--ncu-metrics',','.join(metrics),'--ncu-apply-rules','no','--ncu-name-base','mangled','--ncu-count','100000',*selection];row[kind]=dict(status='running',path=str(dest),command=list(map(str,cmd)));save();before=time.monotonic()
 try:
  run(cmd,out/(dest.name+'.log'));check(ref,dest)
  run(['/opt/nvidia/nsight-compute/2025.3.1/ncu','--import',dest/'counters.ncu-rep','--page','raw','--csv','--print-kernel-base','mangled'],dest/'counters.csv')
  data=profile.counters(dest/'counters.csv');(dest/'analysis.json').write_text(json.dumps(data)+'\n')
  if kind=='graph':assert len(data)==len(expected) and all(x['name']=='graph' for x in data),'Graph inventory mismatch'
  else:
   actual=collections.Counter(config.observed_key(d) for d in data);want=collections.Counter((t['name'],tuple(k['grid']),tuple(k['block']),k['shared_bytes']) for t in expected['targets'] for k in t['configs'] for _ in k['selected_ordinals'])
   row[kind]['missing_configurations']=[str(k) for k in (want-actual).elements()];row[kind]['extra_configurations']=[str(k) for k in (actual-want).elements()];assert actual==want,'Ordinary configuration inventory mismatch'
  for d in data:
   for key in metrics:
    assert key in d['metrics'] and isinstance(d['metrics'][key]['value'],(int,float)) and math.isfinite(d['metrics'][key]['value']),(kind,key,'missing/nonfinite')
  row[kind].update(status='complete',launches=len(data),report_sha256=sha(dest/'counters.ncu-rep'))
 except Exception as e:row[kind].update(status='failed',error=str(e));raise
 finally:row[kind]['elapsed_seconds']=time.monotonic()-before;save()

save()
with (ROOT/'out/destruction-ab.lock').open('a') as lease:
 fcntl.flock(lease,fcntl.LOCK_EX);start=time.monotonic()
 try:
  desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
  if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
  for _ in range(50):
   gpu=capture.gpu()
   if gpu.get('devices') and not any(g['processes'] for g in gpu['devices']) and not any(bad in json.dumps(gpu).lower() for bad in ['err!','requires reset']):break
   time.sleep(.2)
  else:raise RuntimeError('GPU unavailable')
  record.update(status='running',gpu=gpu);save()
  prior=json.loads((a.cpu/'campaign.json').read_text()) if a.cpu else None
  for c in cases:
   row=dict(scenario=c['scenario'],status='running',input_sha256=c['input_sha256'],warmup_ticks=c['warmup_ticks'],measure_ticks=c['measure_ticks']);record['scenarios'].append(row);save();before=time.monotonic()
   try:
    ref,paths=reference(c);row['plain']=list(map(str,paths))
    if a.tier=='cpu':
     old=next((x for x in prior['scenarios'] if x['scenario']==c['scenario'] and x['status']=='complete'),None) if prior else None
     if old:
      assert old['input_sha256']==c['input_sha256'] and old['warmup_ticks']==c['warmup_ticks'] and old['measure_ticks']==c['measure_ticks']
      receipt=json.loads((Path(old['path'])/'receipt.json').read_text());assert receipt['binary_sha256']==sha(manifest['profile_binary']);assert sha(Path(old['path'])/'trace.nsys-rep')==old['trace_sha256']
      assert checker.compare(ref,Path(old['path']))['status']=='passed';row.update(old,reused_from=str(a.cpu));save();print('cpu',c['scenario'],'reused',flush=True);continue
     dest=out/c['scenario'];row['path']=str(dest);cmd=base(c,dest)+['--profiler','nsys','--nsys-cpu','--nsys-range',a.nsys_range,'--nsys-sampling-period','2000000'];row['command']=list(map(str,cmd));save()
     run(cmd,out/(c['scenario']+'.log'));check(ref,dest)
     run(['/opt/nvidia/nsight-systems/2026.3.2/bin/nsys','export','--type','sqlite','--output',dest/'trace.sqlite',dest/'trace.nsys-rep'],dest/'export.log')
     run([sys.executable,HERE/'analyze-attribution.py',dest],dest/'analysis.log')
     d=json.loads((dest/'attribution.json').read_text());row.update(cpu_samples=d['cpu_attribution']['samples'],kernels=d['kernel_count'],engine_scopes=d['cpu_attribution']['nvtx_scope_count'],warnings=d['diagnostics']);assert row['cpu_samples']>0,'No CPU samples'
     row['trace_sha256']=sha(dest/'trace.nsys-rep')
    else:
     cpu=next(x for x in prior['scenarios'] if x['scenario']==c['scenario']);assert cpu['status']=='complete','No qualified current CPU/GPU inventory';path=Path(cpu['path']);row['timeline']=str(path)
     graphs=graph.inventory(path);selected=config.select(path,.1,.99);row['graph_inventory']=graphs;row['ordinary_selection']=selected;save()
     if graphs:ncu(c,ref,row,'graph',['--ncu-kernel','regex:^graph$','--ncu-graph','graph'],graphs)
     else:row['graph']=dict(status='complete',launches=0,note='No nonempty graph launch in measured tick')
     if selected['targets']:
      symbols='|'.join(re.escape(x['name']) for x in selected['targets']);ordinals='|'.join(str(x) for x in selected['invocation_ordinals']);expression='::regex:^('+symbols+')$:^('+ordinals+')$'
      ncu(c,ref,row,'ordinary',['--ncu-kernel-id',expression,'--ncu-filter-mode','per-launch-config','--ncu-graph','node'],selected)
     else:row['ordinary']=dict(status='complete',launches=0,note='No selected ordinary kernel work')
    row['status']='complete'
   except Exception as e:
    row.update(status='failed',error=repr(e))
    # Fail safely on firmware faults; a bad capture must not poison later cases.
    audit=subprocess.run(['journalctl','-k','--since','@'+str(int(record['gpu']['unix_seconds'])),'--no-pager','-g','NVRM: Xid'],capture_output=True,text=True)
    if 'NVRM: Xid' in audit.stdout:raise RuntimeError('GPU Xid: collection stopped; inspect current capture')
   row['elapsed_seconds']=time.monotonic()-before;save();print(a.tier,c['scenario'],row['status'],round(row['elapsed_seconds'],2),flush=True)
  record['status']='complete' if all(x['status']=='complete' for x in record['scenarios']) else 'incomplete'
 except BaseException as e:
  record.update(status='interrupted',error=str(e))
  for row in record['scenarios']:
   if row['status']=='running':row.update(status='interrupted',error=str(e))
  raise
 finally:
  if desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
  save()
print(record['status'],round(record['elapsed_seconds'],2));sys.exit(record['status']!='complete')
