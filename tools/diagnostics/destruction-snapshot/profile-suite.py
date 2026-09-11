#!/usr/bin/env python3
"""Capture a Systems timeline and targeted full NCU metrics for saved full ticks."""
import argparse,hashlib,json,os,re,subprocess,sys,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__);p.add_argument('output',type=Path)
p.add_argument('--manifest',type=Path,required=True);p.add_argument('--binary',type=Path,required=True);p.add_argument('--artifacts',type=Path,required=True)
p.add_argument('--preset',choices=['light','full'],default='light');p.add_argument('--reuse',type=Path,help='Prior matching campaign; matching passed captures are reused')
p.add_argument('--counter-mode',choices=['full','hardware','pm'],default='pm')
p.add_argument('--ncu-replay',choices=['kernel','application'],default='kernel')
p.add_argument('--allow-existing-graphics',action='store_true');p.add_argument('--allow-compute-pid',type=int,action='append',default=[])
a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False);started=time.monotonic()
manifest=json.loads(a.manifest.read_text());cases=manifest['scenarios']
if a.preset=='light':
 names={c['scenario'] for c in json.loads((ROOT/'tools/profiles/destruction-snapshot-light.json').read_text())['scenarios']};cases=[c for c in cases if c['scenario'] in names];assert len(cases)==len(names)
sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
identity=dict(binary_sha256=sha(a.binary),modules={p.name:sha(p) for p in sorted(a.artifacts.glob('*.so'))})
record=dict(preset=a.preset,identity=identity,scenarios=[],profiling_only=True,scope='First full restored tick profiled; second independent tick checks repeatability. Fixed physical inputs. NCU targets dominant kernel family and stress family if different; first two matching launches. Profiler timings are not application benchmarks.')
(out/'manifest.json').write_text(json.dumps(dict(input_manifest=str(a.manifest.resolve()),scenarios=cases,**identity),indent=2)+'\n')
previous=json.loads((a.reuse/'campaign.json').read_text()) if a.reuse else None
if previous:assert previous['identity']==identity,'Cannot reuse different profiling artifacts'
opts=[]
if a.allow_existing_graphics:opts+=['--allow-existing-graphics']
for pid in a.allow_compute_pid:opts+=['--allow-compute-pid',str(pid)]
nsys='/opt/nvidia/nsight-systems/2026.3.2/bin/nsys';ncu='/opt/nvidia/nsight-compute/2026.3.0/ncu'
commands=[]
def run(cmd,label):
 with (out/(label+'-driver.log')).open('x') as log:result=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT)
 commands.append(dict(command=cmd,exit_code=result.returncode));(out/'commands.json').write_text(json.dumps(commands,indent=2)+'\n')
 if result.returncode:raise RuntimeError(f'{label} failed; inspect preserved log')
for case in cases:
 name=case['scenario'];row=dict(scenario=name,input_sha256=case['input_sha256'],status='running');record['scenarios'].append(row)
 def save():
  record['elapsed_seconds']=time.monotonic()-started;(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
 save()
 try:
  for path,digest in case['input_sha256'].items():assert sha(Path(path))==digest,'Saved input changed'
  prior=next((r for r in previous['scenarios'] if r['scenario']==name),None) if previous else None
  if prior:assert prior['input_sha256']==case['input_sha256']
  prior_mode=prior.get('counter_mode','full' if prior.get('counters') else None) if prior else None
  reusable=prior_mode==a.counter_mode or (a.counter_mode=='hardware' and prior_mode=='full')
  if prior and prior.get('timeline'):
   old_receipt=json.loads((Path(prior['timeline'])/'receipt.json').read_text())
   reusable=reusable and old_receipt['profiler'].get('raw_timeline_scope')=='process'
  if prior and prior['status']=='complete' and reusable:
   row.update(prior);row['reused_from']=str(a.reuse.resolve());save();print(name,'reused',flush=True);continue
  print(name,'timeline',flush=True)
  timeline=out/(name+'-timeline')
  base=[sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/run-probe.py')]
  common=['--binary',str(a.binary.resolve()),'--artifacts',str(a.artifacts.resolve()),'--replay-prefix',case['prefix'],'--repetitions','2','--watchdog-seconds','240',*opts]
  if case.get('projectile_impulse'):common+=['--projectile-impulse']
  if prior and prior.get('timeline') and a.counter_mode!='pm':
   timeline=Path(prior['timeline']);assert json.loads((timeline/'analysis.json').read_text())['physical_status']=='passed'
  else:
   run([*base,str(timeline),*common,'--profiler','pm' if a.counter_mode=='pm' else 'nsys'],name+'-timeline')
   run([nsys,'export','--type','sqlite','--output',str(timeline/'trace.sqlite'),str(timeline/'trace.nsys-rep')],name+'-export')
   run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/analyze-profile.py'),str(timeline),'--kind','timeline'],name+'-analyze')
  row['timeline']=str(timeline);data=json.loads((timeline/'analysis.json').read_text());ranked=data['ranked_kernels'];assert ranked
  row['counter_mode']=a.counter_mode
  if a.counter_mode=='pm':
   assert data['pm']['tick']['samples']>0
   row['counters']=prior.get('counters',[]) if prior and prior['status']=='complete' else []
   row['status']='complete';save();continue
  targets=[ranked[0]['name']]
  stress=next((r['name'] for r in ranked if 'componentStressSolve(' in r['name']),None)
  if stress and stress not in targets:targets.append(stress)
  row['counters']=[]
  for i,target in enumerate(targets):
   # The function name includes anonymous namespaces; matching its escaped short
   # symbol avoids argument/type-name ambiguity in the profiler's function mode.
   symbol=target.split('(')[0].split('::')[-1].split('<')[0];capture=out/(name+'-counters-'+str(i))
   print(name,'counters',symbol,flush=True)
   run([*base,str(capture),*common,'--profiler','ncu','--ncu-kernel','regex:'+re.escape(symbol),'--ncu-count','2','--ncu-mode',a.counter_mode,'--ncu-replay',a.ncu_replay],name+'-counters-'+str(i))
   reports=list(capture.glob('counters.ncu-rep*'));assert len(reports)==1,'No unique NCU report'
   with (capture/'counters.csv').open('x') as csv:
    cmd=[ncu,'--import',str(reports[0]),'--page','raw','--csv'];result=subprocess.run(cmd,stdout=csv,stderr=subprocess.PIPE,text=True)
   commands.append(dict(command=cmd,exit_code=result.returncode));assert result.returncode==0,result.stderr
   run([sys.executable,str(ROOT/'tools/diagnostics/destruction-snapshot/analyze-profile.py'),str(capture),'--kind','counters'],name+'-counter-analyze-'+str(i))
   metrics=json.loads((capture/'analysis.json').read_text());assert metrics,'No counters extracted'
   replay=json.loads((capture/'replay.json').read_text());assert replay['passed']
   for k in ['broken_bonds','correction_passes','stress_passes','output_clusters']:
    assert replay['samples'][0][k]==data['physical_sample'][k],f'Profiler changed {k}'
   row['counters'].append(dict(target=target,path=str(capture),launches=len(metrics),report_sha256=sha(reports[0])))
  row['status']='complete'
 except Exception as error:row.update(status='failed',error=str(error));save();raise
 save()
record['status']='complete';save();print(f'Completed {len(cases)} scenarios in {record["elapsed_seconds"]:.1f}s',flush=True)
