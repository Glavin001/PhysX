from pathlib import Path
import subprocess,json,fcntl
root=Path.cwd();base=root/'out/snapshot-finish-20260911';arm=base/'device-enabled-publication';rows=[]
def record(name,cmd,r):
 rows.append(dict(name=name,command=cmd,exit_code=r.returncode));(arm/'screen-results.json').write_text(json.dumps(rows,indent=2)+'\n');print(name,r.returncode,flush=True)
 if r.returncode:raise SystemExit(r.returncode)
for mode in ['plain','mem']:
 cmd=[str(arm/'publication-test')]
 if mode=='mem':cmd=['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool','memcheck','--error-exitcode','97',*cmd]
 with (root/'out/destruction-ab.lock').open('a') as lock:
  fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
  with (arm/('publication-'+mode+'.log')).open('w') as log:r=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,timeout=180)
 record('publication-'+mode,cmd,r)
cases=[('ladder128-cold',root/'out/snapshot-large-20260911/roundtrip-regressions/ladder128-cold'),('city256-initial-impact',root/'out/snapshot-large-20260911/capture-16-bombardment/native/snapshot-82'),('city256-late-debris',root/'out/snapshot-large-20260911/capture-16-bombardment/native/snapshot-179')]
for case,prefix in cases:
 for mode in ['plain','mem']:
  name='publication-'+case+'-'+mode
  cmd=['python3',str(root/'tools/diagnostics/destruction-snapshot/run-probe.py'),str(base/name),'--binary',str(root/'out/snapshot-large-20260911/final-artifacts/native_destruction_snapshot_test'),'--artifacts',str(arm),'--replay-prefix',str(prefix),'--repetitions','2','--watchdog-seconds','600','--allow-existing-graphics','--allow-compute-pid','435374']
  if mode=='mem':cmd+=['--sanitizer','memcheck']
  r=subprocess.run(cmd);record(name,cmd,r)
