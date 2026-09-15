#!/usr/bin/env python3
"""Resume consumer compilation after the preserved missing-include preparation failure."""
import fcntl,hashlib,json,shlex,subprocess,time
from pathlib import Path
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'out/destruction-convergence-policy-20260913/build';tree=OUT/'source'
def sha(p):return hashlib.sha256(Path(p).read_bytes()).hexdigest()
r=json.loads((OUT/'build.json').read_text());r.setdefault('preparation_failures',[]).append(r.pop('error',r.get('preparation_failure','resumed')));r['status']='resuming_consumers'
(OUT/'source/tools/diagnostics').mkdir(parents=True,exist_ok=True)
if not (OUT/'source/tools/diagnostics/destruction-snapshot').exists():(OUT/'source/tools/diagnostics/destruction-snapshot').symlink_to(tree/'probe',target_is_directory=True)
def save():(OUT/'build.json').write_text(json.dumps(r,indent=2)+'\n')
def run(cmd,cwd):
 row=dict(argv=cmd,cwd=str(cwd));r['commands'].append(row);save();t=time.monotonic()
 with (OUT/'build.log').open('ab') as f:subprocess.run(cmd,cwd=cwd,stdout=f,stderr=subprocess.STDOUT,check=True)
 row['seconds']=time.monotonic()-t;save()
save()
with (ROOT/'out/destruction-ab.lock').open('a') as lease:
 fcntl.flock(lease,fcntl.LOCK_EX)
 try:
  cc=next(c['argv'] for c in r['commands'] if c['argv'][0]=='/usr/bin/clang++' and '-c' in c['argv']);prior=json.loads((ROOT/'out/n20-requalification-20260912/build/build.json').read_text())
  for source,name,objname in [(tree/'demos/blast-stress-demo/native_destruction_main.cpp','native_destruction_demo','native_destruction_main.cpp.o'),(tree/'probe/serialization-probe.cpp','serialization-probe','serialization-probe.o')]:
   cmd=cc.copy();obj=OUT/(name+'.o');cmd[cmd.index('-c')+1]=str(source);cmd[cmd.index('-o')+1]=str(obj);cmd[cmd.index('-MF')+1]=str(OUT/(name+'.d'));run(cmd,ROOT)
   c=next(c for c in prior['commands'] if '-o' in c['argv'] and c['argv'][c['argv'].index('-o')+1].endswith('/B/'+name))
   link=[str(obj) if a.endswith('/'+objname) else a for a in c['argv']];link[link.index('-o')+1]=str(OUT/name)
   for a in link:
    if Path(a).is_file() and Path(a)!=obj:r['inputs'][a]=sha(a)
   run(link,c['cwd'])
  r['outputs']={str(OUT/n):sha(OUT/n) for n in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so','native_destruction_demo','serialization-probe']}
  r['dependencies']={dep.name:{name:sha(name) for name in shlex.split(dep.read_text().replace('\\\n',' ').split(':',1)[1])} for dep in OUT.glob('*.d')};r['status']='built_not_run';save()
 except BaseException as e:r.update(status='failed',error=repr(e));save();raise
