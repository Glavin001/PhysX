from pathlib import Path
import os,json,subprocess,time,shutil,hashlib
sdk=Path('/root/workspace/physx-2');game=Path('/root/workspace/vibe-land-2');root=sdk/'out/vibe-committed-changes-20260908'
live=sdk/'physx/bin/linux.x86_64/release';stage=root/'sdk/physx/bin/linux.x86_64/release';server=sdk/'out/vibe-native/release/web-fps-server'
hashes=json.loads((sdk/'qualification/vibe-committed-changes-20260908/build-hashes.json').read_text())
for file,digest in hashes.items():assert hashlib.sha256((sdk/file).read_bytes()).hexdigest()==digest,file
pid=int(Path('/tmp/vibe-embedded-city/server.pid').read_text());assert Path(f'/proc/{pid}/exe').resolve()==server
assert json.loads(subprocess.check_output(['curl','-fsS','http://127.0.0.1:4005/healthz']))['players']==0
backup=root/'predeploy-sdk';backup.mkdir(exist_ok=False);changed=[]
for source in stage.iterdir():
 if source.suffix not in ['.a','.so']:continue
 target=live/source.name
 if target.exists() and hashlib.sha256(target.read_bytes()).digest()==hashlib.sha256(source.read_bytes()).digest():continue
 assert target.exists(),target;shutil.copy2(target,backup/target.name);changed.append((source,target))
shutil.copy2(server,backup/'web-fps-server');changed.append((root/'web-fps-server',server))
def install(source,target):
 tmp=target.with_suffix(target.suffix+'.next');shutil.copy2(source,tmp);os.replace(tmp,target)
def launch():
 for attempt in range(12):
  with (root/'deployment.log').open('a') as log:r=subprocess.run(['bash','scripts/run-embedded-city.sh'],cwd=game,stdout=log,stderr=subprocess.STDOUT,timeout=45)
  if r.returncode==0:return
  time.sleep(5)
 raise RuntimeError('server launch failed')
os.kill(pid,15)
for _ in range(100):
 if not Path(f'/proc/{pid}/exe').exists():break
 time.sleep(.1)
assert not Path(f'/proc/{pid}/exe').exists()
try:
 for source,target in changed:install(source,target)
 launch()
except:
 for source,target in changed:install(backup/target.name,target)
 launch();raise
newpid=int(Path('/tmp/vibe-embedded-city/server.pid').read_text())
(root/'deployment.json').write_text(json.dumps({'pid':newpid,'engine_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=sdk,text=True).strip(),'game_commit':subprocess.check_output(['git','rev-parse','HEAD'],cwd=game,text=True).strip(),'files':{str(target):hashlib.sha256(target.read_bytes()).hexdigest() for source,target in changed}},indent=2))
print('deployed',newpid,flush=True)
