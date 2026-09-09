from pathlib import Path
import os,subprocess,time,json,hashlib
sdk=Path('/root/workspace/physx-2');game=Path('/root/workspace/vibe-land-2');root=sdk/'out/rigid-additive-20260909';out=root/'screen';out.mkdir(exist_ok=False)
live=sdk/'physx/bin/linux.x86_64/release';candidate=root/'candidate';binary=sdk/'out/vibe-native/release/examples/embedded_city_bench'
pid=int(Path('/tmp/vibe-embedded-city/server.pid').read_text());assert Path(f'/proc/{pid}/exe').resolve()==sdk/'out/vibe-native/release/web-fps-server'
assert json.loads(subprocess.check_output(['curl','-fsS','http://127.0.0.1:4005/healthz']))['players']==0
receipt={'commands':[]}
def run(name,cmd,cwd=sdk,env=None,expected=None):
 print('START',name,flush=True)
 mapped={}
 with (out/(name+'.log')).open('w') as log:
  r=subprocess.Popen([str(x) for x in cmd],cwd=cwd,env=env,stdout=log,stderr=subprocess.STDOUT)
  start=time.monotonic()
  while r.poll() is None:
   if time.monotonic()-start>600:r.kill();raise RuntimeError('timeout '+name)
   if expected:
    try:
     for line in Path(f'/proc/{r.pid}/maps').read_text().splitlines():
      for lib in expected:
       if line.endswith(lib) and lib not in mapped:
        p=Path(line.split()[-1]);mapped[lib]={'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()}
     if len(mapped)==len(expected):r.wait(timeout=600);break
    except FileNotFoundError:pass
   else:r.wait(timeout=600);break
   time.sleep(.005)
 if expected:assert all(mapped.get(k,{}).get('path')==str(v) for k,v in expected.items()),mapped
 receipt['commands'].append({'name':name,'command':[str(x) for x in cmd],'exit':r.returncode,'mapped':mapped});(out/'receipt.json').write_text(json.dumps(receipt,indent=2))
 print('END',name,r.returncode,flush=True);assert r.returncode==0,name
os.kill(pid,15)
try:
 for _ in range(100):
  gpu=subprocess.check_output(['nvidia-smi','--query-compute-apps=pid','--format=csv,noheader'],text=True).strip()
  if not gpu:break
  time.sleep(.2)
 assert not gpu,gpu
 run('numerical',['ctest','--test-dir','out/destruction-sdk','-R','^blast_stress_gpu_resident_(analytic|3d|motion_modes)$','--output-on-failure'])
 run('polynomial-memcheck',['/usr/local/cuda/bin/compute-sanitizer','--tool','memcheck','--error-exitcode','99',sdk/'out/destruction-sdk/reference/gpu_resident_motion_modes_test','small'])
 env=os.environ.copy();env['LD_LIBRARY_PATH']=str(candidate)+':'+str(live)+':/usr/local/cuda/lib64'
 run('ordinary',['ctest','--test-dir','out/destruction-sdk','-R','^physx_native_(post_correction|standard_(reported_reuse|reuse|awake|sleep|sleep_boundary|gpu_islands|wake_boundary|late_impact))$','--output-on-failure'],env=env)
 run('compound-memcheck',['/usr/local/cuda/bin/compute-sanitizer','--tool','memcheck','--error-exitcode','99',sdk/'out/destruction-sdk/reference/native_standard_scene_test','--compound-sleep'],env=env)
 run('wall-driver',['python3','tools/scripts/run-destruction-penetration-regression.py',out/'wall','--expected-runtime',candidate/'libPhysXDestructionGpuRuntime_64.so'],env=env)
 for arm,path in [('baseline',live),('candidate',candidate)]:
  env=os.environ.copy();env['LD_LIBRARY_PATH']=str(path)+':'+str(live)+':/usr/local/cuda/lib64';env.pop('VIBE_EMBEDDED_AUDIT_EVERY_TICK',None)
  for regime in ['idle','shots']:
   name=arm+'-'+regime
   run(name,[binary,out/name,'8','600','0' if regime=='idle' else '3'],game,env,{k:path/k for k in ['libPhysXDestructionGpuRuntime_64.so','libPhysXGpuActivity_64.so']})

finally:
 for attempt in range(12):
  with (out/'restore.log').open('a') as log:r=subprocess.run(['bash','scripts/run-embedded-city.sh'],cwd=game,stdout=log,stderr=subprocess.STDOUT,timeout=45)
  if r.returncode==0:break
  time.sleep(5)
 print('restored',r.returncode,flush=True)
