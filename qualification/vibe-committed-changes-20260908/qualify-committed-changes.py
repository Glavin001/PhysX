from pathlib import Path
import os,subprocess,time,json,hashlib
sdk=Path('/root/workspace/physx-2');game=Path('/root/workspace/vibe-land-2');root=sdk/'out/vibe-committed-changes-20260908';out=root/'screen-a';out.mkdir(exist_ok=False)
live=sdk/'physx/bin/linux.x86_64/release';candidate=root/'sdk/physx/bin/linux.x86_64/release';bin=sdk/'out/vibe-native/release/examples/embedded_city_bench'
pid=int(Path('/tmp/vibe-embedded-city/server.pid').read_text());assert Path(f'/proc/{pid}/exe').resolve()==sdk/'out/vibe-native/release/web-fps-server'
assert json.loads(subprocess.check_output(['curl','-fsS','http://127.0.0.1:4005/healthz']))['players']==0
receipt={'runtime_sha256':{k:hashlib.sha256((v/'libPhysXDestructionGpuRuntime_64.so').read_bytes()).hexdigest() for k,v in [('baseline',live),('candidate',candidate)]},'commands':[]}
(out/'receipt.json').write_text(json.dumps(receipt,indent=2))
def run(name,cmd,cwd=sdk,env=None):
 print('START',name,flush=True)
 with (out/(name+'.log')).open('w') as log:
  r=subprocess.Popen([str(x) for x in cmd],cwd=cwd,env=env,stdout=log,stderr=subprocess.STDOUT)
  mapped={};start=time.monotonic()
  while r.poll() is None:
   if time.monotonic()-start>600:r.kill();raise RuntimeError('timeout '+name)
   try:
    for line in Path(f'/proc/{r.pid}/maps').read_text().splitlines():
     for lib in ['libPhysXDestructionGpuRuntime_64.so','libPhysXGpuActivity_64.so']:
      if line.endswith(lib):
       p=Path(line.split()[-1]);mapped[lib]={'path':str(p),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()} if lib not in mapped else mapped[lib]
   except FileNotFoundError:pass
   time.sleep(.02)
  if cmd[0]==bin:
   assert len(mapped)==2,(name,mapped)
   assert all(Path(x['path']).parent==candidate for x in mapped.values()),mapped
   (out/(name+'-mapped.json')).write_text(json.dumps(mapped,indent=2))
 receipt['commands'].append({'name':name,'command':[str(x) for x in cmd],'exit':r.returncode});(out/'receipt.json').write_text(json.dumps(receipt,indent=2))
 print('END',name,r.returncode,flush=True);assert r.returncode==0,name
os.kill(pid,15)
try:
 for _ in range(100):
  gpu=subprocess.check_output(['nvidia-smi','--query-compute-apps=pid','--format=csv,noheader'],text=True).strip()
  if not gpu:break
  time.sleep(.2)
 assert not gpu,gpu
 run('publication',['ctest','--test-dir','out/destruction-sdk','-R','^destruction_gpu_committed_changes$','--output-on-failure'])

 env=os.environ.copy();env['LD_LIBRARY_PATH']=str(candidate)+':'+str(live)+':/usr/local/cuda/lib64'
 run('ordinary',['ctest','--test-dir','out/destruction-sdk','-R','^physx_native_standard_(reported_reuse|reuse|awake|sleep|sleep_boundary|gpu_islands|wake_boundary|late_impact)$','--output-on-failure'],env=env)
 run('wall-driver',['python3','tools/scripts/run-destruction-penetration-regression.py',out/'wall','--expected-runtime',candidate/'libPhysXDestructionGpuRuntime_64.so'],env=env)
 for arm,path in [('candidate',candidate)]:
  env=os.environ.copy();env['LD_LIBRARY_PATH']=str(path)+':'+str(live)+':/usr/local/cuda/lib64'
  for regime in ['idle','shots']:
   cmd=[bin,out/(arm+'-'+regime),'1','600','0','fractured-downtown.json']
   if regime=='shots':cmd.append(sdk/'out/vibe-idle-fix-20260908/downtown-commands.json')
   run(arm+'-'+regime,cmd,game,env)
 for regime in ['idle','shots']:
  run('scale-'+regime,[bin,out/('scale-'+regime),'8','600','0' if regime=='idle' else '3'],game,env)

finally:
 for attempt in range(12):
  with (out/'restore.log').open('a') as log:r=subprocess.run(['bash','scripts/run-embedded-city.sh'],cwd=game,stdout=log,stderr=subprocess.STDOUT,timeout=45)
  if r.returncode==0:break
  time.sleep(5)
 print('restored',r.returncode,flush=True)
