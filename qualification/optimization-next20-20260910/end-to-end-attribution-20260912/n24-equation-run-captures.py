"""Capture two independent restored ticks per original N24 arm; never time as production."""
from pathlib import Path
import hashlib,json,os,subprocess,sys,time
base=Path(__file__).resolve().parent;root=base.parents[1]
record=dict(status='running',diagnostic_commit=json.loads((base/'commit.json').read_text())['commit'],stages=[],scope='Intrusive native-equation capture, not application timing. Same original N24 failing city25 impact fixture, two independent restores per arm.')
def save():(base/'capture-campaign.json').write_text(json.dumps(record,indent=2)+'\n')
def run(name,cmd,env=None):
 row=dict(name=name,command=list(map(str,cmd)),status='running');record['stages'].append(row);save();begin=time.monotonic()
 with (base/(name+'.log')).open('x') as log:result=subprocess.run(cmd,cwd=root,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=900)
 row.update(status='passed' if result.returncode==0 else 'failed',exit_code=result.returncode,seconds=time.monotonic()-begin);save();assert result.returncode==0,name
try:
 build=json.loads((base/'build/build.json').read_text());assert build['status']=='built_not_gpu_qualified'
 for path,h in build['outputs'].items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==h
 manifest=json.loads((root/'out/snapshot-light-20260911/full-manifest/manifest.json').read_text())
 case=next(c for c in manifest['scenarios'] if c['scenario']=='city25-initial-impact')
 for arm in ['A','B']:
  env=dict(os.environ,PHYSX_COMPONENT_WORK_OUTPUT=str(base/(arm+'-work.jsonl')),PHYSX_STRESS_PROBLEM_PREFIX=str(base/(arm+'-problem')),PHYSX_STRESS_PROBLEM_SOLVES='0:1',PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first')
  record.setdefault('diagnostic_environment',{})[arm]={k:v for k,v in env.items() if k.startswith('PHYSX_')};save()
  dest=base/(arm+'-capture')
  cmd=[sys.executable,str(root/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(dest),'--binary',str(root/'out/n20-requalification-20260912/build/B/serialization-probe'),'--artifacts',str(base/'build'/arm),'--replay-prefix',case['prefix'],'--repetitions','2','--watchdog-seconds','900']
  if case.get('projectile_impulse'):cmd+=['--projectile-impulse']
  run(arm+'-capture',cmd,env)
  reference=root/'out/n24-component-multilevel-20260912/screen'/(arm+'-city25-initial-impact-memcheck')
  run(arm+'-diagnostic-physical',[sys.executable,str(root/'tools/diagnostics/destruction-snapshot/compare-observations.py'),str(reference),str(dest),str(base/(arm+'-diagnostic-physical.json'))])
 prefixes=sorted(base.glob('*-problem.world-*.solve-*.json'))
 assert len(prefixes)==8,'Expected two stress passes in each of two restored worlds per arm'
 audit_env=dict(os.environ,PYTHONPATH=str(root/'out/elastic-precision-reference-20260910/python'),OPENBLAS_NUM_THREADS='1')
 run('independent-equations',[sys.executable,str(root/'tools/scripts/audit-native-stress-solution.py'),str(base/'equation-audit.json'),*[str(p.with_suffix('')) for p in prefixes]],audit_env)
 run('hierarchy-oracle-observation-check',[sys.executable,str(root/'out/hierarchy-oracle-live-ranges-20260912/run-diagnostic.py')])
 record['status']='captures_and_equation_audit_complete_pending_review'
except BaseException as error:record.update(status='failed',error=repr(error));save();raise
save()
