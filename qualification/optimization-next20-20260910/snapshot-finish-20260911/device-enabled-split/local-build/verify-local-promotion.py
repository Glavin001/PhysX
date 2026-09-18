from pathlib import Path
import json,subprocess,hashlib,shutil,os
r=Path.cwd();base=r/'out/snapshot-finish-20260911';out=base/'local-promoted-verification';out.mkdir(exist_ok=True);art=out/'artifacts';art.mkdir(exist_ok=True)
for name in ['libPhysXDestructionGpuRuntime_64.so','libPhysXGpuActivity_64.so']:
 source=(r/'physx/bin/linux.x86_64/release'/name) if name.startswith('libPhysXDestruction') else (base/'device-enabled-split'/name)
 shutil.copy2(source,art/name)
rows=json.loads((out/'results.json').read_text()) if (out/'results.json').exists() else []
def run(cmd):
 if cmd[:2]==['python3',str(r/'tools/diagnostics/destruction-snapshot/run-probe.py')] and (Path(cmd[2])/'receipt.json').exists():
  assert json.loads((Path(cmd[2])/'receipt.json').read_text())['status']=='complete';return
 p=subprocess.run(cmd,env=dict(os.environ,PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first'));rows.append(dict(command=cmd,exit_code=p.returncode));(out/'results.json').write_text(json.dumps(rows,indent=2)+'\n');assert p.returncode==0
common=['python3',str(r/'tools/diagnostics/destruction-snapshot/run-probe.py')]
flags=['--artifacts',str(art),'--allow-existing-graphics','--allow-compute-pid','435374','--watchdog-seconds','600']
run(common+[str(out/'correction-mem'),'--binary',str(r/'out/snapshot-large-20260911/final-artifacts/native_gpu_correction_body_test'),'--sanitizer','memcheck']+flags)
manifest=json.loads((base/'device-enabled-split-mem-suite/manifest.json').read_text());scenarios={s['scenario']:s for s in manifest['scenarios']}
for name in ['dense12-cold','ladder128-cold','city25-initial-impact','city256-late-debris']:
 s=scenarios[name];target=out/(name+'-observed')
 run(common+[str(target),'--binary',str(base/'physical-ab-probe-v3/serialization-probe'),'--replay-prefix',s['prefix'],'--repetitions','2']+flags)
 reference=base/('split-matched-full' if name=='dense12-cold' else 'split-matched-remaining')/(name+'-B')
 run(['python3',str(r/'tools/diagnostics/destruction-snapshot/compare-observations.py'),str(reference),str(target),str(out/(name+'-physical-final.json'))])
(out/'artifacts.json').write_text(json.dumps({str(f.relative_to(r)):hashlib.sha256(f.read_bytes()).hexdigest() for f in art.iterdir()},indent=2)+'\n')
print('LOCAL REBUILT RUNTIME: correction memcheck and four physical restored scenarios pass')
