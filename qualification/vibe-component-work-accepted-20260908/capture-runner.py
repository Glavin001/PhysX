import hashlib,json,os,subprocess,time
from pathlib import Path
repo=Path('/root/workspace/vibe-land-2')
sdk=Path('/root/workspace/physx-2')
root=sdk/'out/vibe-component-work-accepted-20260908'
root.mkdir(exist_ok=False)
server=int(Path('/tmp/vibe-embedded-city/server.pid').read_text())
exe=Path(f'/proc/{server}/exe').resolve()
assert str(exe).removesuffix(' (deleted)')==str(sdk/'out/vibe-native/release/web-fps-server'),exe
health=json.loads(subprocess.check_output(['curl','-fsS','--max-time','5','http://127.0.0.1:4005/healthz']))
assert health['players']==0, 'players connected; do not interrupt'
env=os.environ.copy();common_libraries=str(sdk/'physx/bin/linux.x86_64/release')+':/usr/local/cuda/lib64'
bench=sdk/'out/vibe-native/diagnostics/embedded_city_bench-local-report-profile'
receipt={'game_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),
 'engine_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=sdk,text=True).strip(),
 'game_worktree_diff':subprocess.check_output(['git','diff'],cwd=repo,text=True),
 'binary_sha256':hashlib.sha256(bench.read_bytes()).hexdigest(),
 'diagnostic_runtime_sha256':hashlib.sha256((sdk/'out/sdk-release/diagnostics/component-work/libPhysXDestructionGpuRuntime_64.so').read_bytes()).hexdigest(),
 'production_runtime_sha256':hashlib.sha256((sdk/'physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so').read_bytes()).hexdigest(),
 'engine_worktree_diff':subprocess.check_output(['git','diff'],cwd=sdk,text=True),
 'gpu_before':subprocess.check_output(['nvidia-smi','--query-gpu=name,driver_version,temperature.gpu,clocks.sm,memory.used','--format=csv'],text=True)}
(root/'receipt.json').write_text(json.dumps(receipt,indent=2))
os.kill(server,15)
try:
 for _ in range(50):
  gpu=subprocess.check_output(['nvidia-smi','--query-compute-apps=pid,process_name','--format=csv,noheader'],text=True).strip()
  if not gpu: break
  time.sleep(.2)
 assert not gpu, 'GPU remains occupied: '+gpu
 for label,grid,steps,waves in [('smoke',1,60,1),('256-buildings',8,600,3)]:
  env['LD_LIBRARY_PATH']=str(sdk/'out/sdk-release/diagnostics/component-work')+':'+common_libraries
  env['PHYSX_COMPONENT_WORK_OUTPUT']=str(root/(label+'-components.jsonl'))
  binding=subprocess.check_output(['ldd',str(sdk/'physx/bin/linux.x86_64/release/libPhysXGpuActivity_64.so')],env=env,text=True)
  assert str(sdk/'out/sdk-release/diagnostics/component-work/libPhysXDestructionGpuRuntime_64.so') in binding
  (root/(label+'-ldd.txt')).write_text(binding)
  with (root/(label+'.log')).open('w') as log:
   result=subprocess.run([str(bench),str(root/label),str(grid),str(steps),str(waves)],cwd=repo,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=480)
  print(label,result.returncode,flush=True)
  (root/(label+'-exit.json')).write_text(json.dumps({'returncode':result.returncode}))
  if result.returncode: raise RuntimeError(label+' failed')
  report=json.loads((root/label/'report.json').read_text());assert report['instrumented']
  if label=='smoke':
   import importlib.util
   spec=importlib.util.spec_from_file_location('work_report',sdk/'tools/scripts/report-vibe-component-work.py')
   work=importlib.util.module_from_spec(spec);spec.loader.exec_module(work)
   frames=json.loads((root/label/'steps.json').read_text())
   audited=work.read_solves(root/(label+'-components.jsonl'),work.solve_mapping(frames))
   print('smoke mapped and phase-validated solves',len(audited),flush=True)
finally:
 with (root/'restore-server.log').open('w') as log:
  result=subprocess.run(['bash','scripts/run-embedded-city.sh'],cwd=repo,stdout=log,stderr=subprocess.STDOUT,timeout=45)
 print('server restore',result.returncode,flush=True)
