from pathlib import Path
import os,subprocess,time,json,shutil,hashlib
sdk=Path('/root/workspace/physx-2');game=Path('/root/workspace/vibe-land-2');root=sdk/'out/vibe-committed-changes-20260908';binary=sdk/'out/vibe-native/release/web-fps-server'
pid=int(Path('/tmp/vibe-embedded-city/server.pid').read_text());assert Path(f'/proc/{pid}/exe').resolve()==binary
assert json.loads(subprocess.check_output(['curl','-fsS','http://127.0.0.1:4005/healthz']))['players']==0
backup=root/'baseline/web-fps-server';assert not backup.exists();shutil.copy2(binary,backup)
os.kill(pid,15)
try:
 env=os.environ.copy();env['CARGO_TARGET_DIR']=str(sdk/'out/vibe-native');env['PHYSX_ROOT']=str(root/'sdk/physx')
 with (root/'server-build.log').open('w') as log:
  subprocess.run(['cargo','build','--release','--offline','-p','web-fps-server','--features','embedded-destruction','-j2'],cwd=game,env=env,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
 shutil.copy2(binary,root/'web-fps-server')
finally:
 replacement=binary.with_suffix('.restore');shutil.copy2(backup,replacement);os.replace(replacement,binary)
 for attempt in range(12):
  with (root/'restore-after-build.log').open('a') as log:r=subprocess.run(['bash','scripts/run-embedded-city.sh'],cwd=game,stdout=log,stderr=subprocess.STDOUT,timeout=45)
  if r.returncode==0:break
  time.sleep(5)
 print('restored',r.returncode,flush=True)
print('candidate server ready',flush=True)
