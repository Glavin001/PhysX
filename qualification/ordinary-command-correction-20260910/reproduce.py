from pathlib import Path
import subprocess,time,json,hashlib
root=Path.cwd();base=root/'out/ordinary-command-correction-20260910';runs=[]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def run(name,command):
 record={'name':name,'command':command,'maps':{}}
 with (base/(name+'.log')).open('w') as log:
  proc=subprocess.Popen(command,cwd=root,stdout=log,stderr=subprocess.STDOUT);record['pid']=proc.pid
  while proc.poll() is None:
   for entry in Path('/proc').glob('[0-9]*'):
    try:
     executable=entry.joinpath('exe').resolve()
     if not executable.name.startswith('native_'):continue
     parent=int(entry.name)
     while parent>1 and parent!=proc.pid:
      status=Path(f'/proc/{parent}/status').read_text();parent=int(next(x.split()[1] for x in status.splitlines() if x.startswith('PPid:')))
     if parent!=proc.pid:continue
     maps=entry.joinpath('maps').read_text()
     if 'libcuda.so' in maps:
      path=base/(name+'-'+entry.name+'.maps');path.write_text(maps);record['maps'][entry.name]=str(path)
    except (OSError,RuntimeError,StopIteration):pass
   time.sleep(.025)
 record['exit_code']=proc.returncode;paths=set()
 for path in record['maps'].values():
  for line in Path(path).read_text().splitlines():
   p=line.split()[-1]
   if p.startswith('/') and Path(p).is_file():paths.add(p)
 record['loaded_modules']={p:sha(Path(p)) for p in sorted(paths)}
 runs.append(record);(base/'validation-runs.json').write_text(json.dumps(runs,indent=2)+'\n')
 print(name,proc.returncode,flush=True)
 if proc.returncode:raise SystemExit(proc.returncode)
run('before-fix',[str(root/'out/destruction-sdk/reference/native_gpu_correction_body_test')])
