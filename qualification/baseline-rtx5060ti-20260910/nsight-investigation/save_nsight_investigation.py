from pathlib import Path
import json,shutil,hashlib,csv,subprocess
root=Path.cwd();raw=root/'out/baseline-20260910-ordinary-sleeping';dst=root/'qualification/baseline-rtx5060ti-20260910/nsight-investigation';dst.mkdir(exist_ok=True)
summary={}
for name in ['diagnose-later','control-disabled','control-graph','diagnose-device','plain-device','application-range-probe','application-range-probe2','application-range-graph']:
 p=raw/name;r=json.loads((p/'receipt.json').read_text());o=dst/name;o.mkdir(exist_ok=True)
 shutil.copy2(p/'capture.log',o/'capture.log')
 summary[name]={k:r.get(k) for k in ['command','status','exit_code','binary_sha256','config_sha256','maps_sha256','loaded_modules','error'] if k in r}
 summary[name]['graphics_processes']=r['allowed_graphics']
 if (p/'nsight-internal.log').exists():shutil.copy2(p/'nsight-internal.log',o/'nsight-internal.log')
for name in ['profile_capture.py','replay_target.py','build_diagnostic.py','build_runtime_diagnostic.py','build_range_diagnostic.py','save_nsight_investigation.py']:
 shutil.copy2(raw/name,dst/name)
for name in ['diagnostic-build','runtime-diagnostic-build','range-diagnostic-build']:
 p=raw/name;o=dst/name;o.mkdir(exist_ok=True)
 for f in p.iterdir():
  if f.suffix in ('.cpp','.cu','.cuh','.json'):shutil.copy2(f,o/f.name)
p=raw/'conditional-probe';o=dst/'conditional-probe';o.mkdir(exist_ok=True)
for f in p.iterdir():
 if f.suffix in ('.cpp','.cu','.log','.json'):shutil.copy2(f,o/f.name)
a=list(csv.DictReader((raw/'plain-device/scene/native.frames.csv').open()));b=list(csv.DictReader((raw/'timeline/scene/native.frames.csv').open()))
fields=['bonds_broken','logical_clusters','contacts_frame','stress_iterations','resim_passes','stress_passes','stress_active_nodes','stress_active_bonds']
summary['plain_vs_systems']={'steps':len(a),'fields':fields,'differences':[{'step':x['step'],'values':{f:[x[f],y[f]] for f in fields if x[f]!=y[f]}} for x,y in zip(a,b) if any(x[f]!=y[f] for f in fields)]}
summary['source_revision']=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
summary['production_runtime_sha256']=hashlib.sha256((root/'physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so').read_bytes()).hexdigest()
summary['production_runtime_matches_attestation']=summary['production_runtime_sha256']==json.loads((root/'out/sdk-artifacts.json').read_text())['libraries']['libPhysXDestructionGpuRuntime_64.so']
(dst/'evidence.json').write_text(json.dumps(summary,indent=2)+'\n')
print(dst)
