import hashlib,json,os,subprocess,time
from pathlib import Path
repo=Path('/root/workspace/vibe-land-2')
sdk=Path('/root/workspace/physx-2')
root=sdk/'out/vibe-rigid-inverse-20260908'
assert root.is_dir()
server=int(Path('/tmp/vibe-embedded-city/server.pid').read_text())
exe=Path(f'/proc/{server}/exe').resolve()
assert str(exe).removesuffix(' (deleted)')==str(sdk/'out/vibe-native/release/web-fps-server'),exe
health=json.loads(subprocess.check_output(['curl','-fsS','--max-time','5','http://127.0.0.1:4005/healthz']))
assert health['players']==0, 'players connected; do not interrupt'
env=os.environ.copy();common_libraries=str(sdk/'physx/bin/linux.x86_64/release')+':/usr/local/cuda/lib64';env['LD_LIBRARY_PATH']=str(root/'candidate-lib')+':'+common_libraries
bench=sdk/'out/vibe-native/release/examples/embedded_city_bench'
receipt={'game_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=repo,text=True).strip(),
 'engine_worktree_diff':subprocess.check_output(['git','diff'],cwd=sdk,text=True),
 'engine_revision':subprocess.check_output(['git','rev-parse','HEAD'],cwd=sdk,text=True).strip(),
 'game_worktree_diff':subprocess.check_output(['git','diff'],cwd=repo,text=True),
 'binary_sha256':hashlib.sha256(bench.read_bytes()).hexdigest(),
 'runtime_hashes':{kind:hashlib.sha256((root/(kind+'-lib')/'libPhysXDestructionGpuRuntime_64.so').read_bytes()).hexdigest() for kind in ['baseline','candidate']},
 'gpu_before':subprocess.check_output(['nvidia-smi','--query-gpu=name,driver_version,temperature.gpu,clocks.sm,memory.used','--format=csv'],text=True)}
(root/'receipt.json').write_text(json.dumps(receipt,indent=2))
os.kill(server,15)
try:
 for _ in range(50):
  gpu=subprocess.check_output(['nvidia-smi','--query-compute-apps=pid,process_name','--format=csv,noheader'],text=True).strip()
  if not gpu: break
  time.sleep(.2)
 assert not gpu, 'GPU remains occupied: '+gpu
 for name,command in [('memcheck',['compute-sanitizer','--tool','memcheck','--error-exitcode','99','out/destruction-sdk/reference/gpu_resident_motion_modes_test','small']),('resident-suite',['ctest','--test-dir','out/destruction-sdk','-R','^blast_stress_gpu_resident_(analytic|3d|motion_modes)$','--output-on-failure']),('standard-suite',['ctest','--test-dir','out/destruction-sdk','-R','^physx_native_standard_','--output-on-failure']),('penetration',['python3','tools/scripts/run-destruction-penetration-regression.py',str(root/'penetration')])]:
  with (root/(name+'-driver.log')).open('w') as log:
   result=subprocess.run(command,cwd=sdk,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=120)
  print(name,result.returncode,flush=True)
  assert result.returncode==0,name+' failed'
 for label,grid,steps,waves in [('baseline-a',8,600,3),('candidate-a',8,600,3),('candidate-b',8,600,3),('baseline-b',8,600,3)]:
  env['LD_LIBRARY_PATH']=str(root/(label.split('-')[0]+'-lib'))+':'+common_libraries
  with (root/(label+'.log')).open('w') as log:
   result=subprocess.run([str(bench),str(root/label),str(grid),str(steps),str(waves)],cwd=repo,env=env,stdout=log,stderr=subprocess.STDOUT,timeout=240)
  print(label,result.returncode,flush=True)
  (root/(label+'-exit.json')).write_text(json.dumps({'returncode':result.returncode}))
  if result.returncode: raise RuntimeError(label+' failed')
  report=json.loads((root/label/'report.json').read_text());assert not report.get('instrumented',False)
  print(label,'mean',report.get('mean_complete_step_ms'),'peak',report['peak_step']['complete_step_ms'],flush=True)
finally:
 with (root/'restore-server.log').open('w') as log:
  result=subprocess.run(['bash','scripts/run-embedded-city.sh'],cwd=repo,stdout=log,stderr=subprocess.STDOUT,timeout=45)
 print('server restore',result.returncode,flush=True)
