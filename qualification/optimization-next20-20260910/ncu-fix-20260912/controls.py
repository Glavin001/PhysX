import json,subprocess
from pathlib import Path
root=Path.cwd();base=root/'out/ncu-fix-20260912';m=json.loads((root/'out/snapshot-light-20260911/full-manifest/manifest.json').read_text());results=[]
for name in ['city25-intact-idle','city256-intact-idle','building-fragmented']:
 c=next(c for c in m['scenarios'] if c['scenario']==name)
 cmd=['python3','tools/diagnostics/destruction-snapshot/run-probe.py',str(base/('control-'+name)),'--binary','out/snapshot-counters-20260911/probe/serialization-probe','--artifacts','out/snapshot-reset-20260911/local-artifacts','--replay-prefix',c['prefix'],'--repetitions','2','--profiler','ncu','--ncu-mode','hardware','--ncu-count','1','--allow-existing-graphics','--allow-compute-pid','435374']
 print(name,flush=True)
 with (base/('control-'+name+'-driver.log')).open('w') as f:r=subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT)
 results.append(dict(scenario=name,command=cmd,exit_code=r.returncode));(base/'controls.json').write_text(json.dumps(results,indent=2)+'\n');print('exit',r.returncode,flush=True)
