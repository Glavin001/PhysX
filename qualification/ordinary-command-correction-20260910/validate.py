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
 runs.append(record);(base/'final-runs.json').write_text(json.dumps(runs,indent=2)+'\n')
 print(name,proc.returncode,flush=True)
 if proc.returncode:raise SystemExit(proc.returncode)
run('gpu-before',['nvidia-smi'])
run('ctest-final',['.toolchains/build-env/bin/ctest','--test-dir','out/destruction-sdk','-R','^physx_native_(gpu_command_inputs|command_wake|gpu_rigid_checkpoint|gpu_correction_bodies|gpu_resimulation|post_correction|standard_sleep|compound_sleep|standard_sleep_boundary)$','--output-on-failure','-j1'])
run('native-memcheck',['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool','memcheck','--error-exitcode','99',str(root/'out/destruction-sdk/reference/native_gpu_correction_body_test')])
for tool in ['memcheck','initcheck','synccheck','racecheck']:
 run('producer-'+tool,['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','99',str(root/'out/destruction-sdk/reference/native_gpu_command_inputs_test')])
run('large',[str(root/'out/destruction-sdk/reference/native_gpu_command_inputs_test'),'--large',str(base/'plain.bin')])
common=['/usr/local/cuda-13.4/bin/ncu','--kernel-name-base','function','--kernel-name','regex:captureCommandInputsKernel','--launch-count','1','--section','SpeedOfLight','--section','LaunchStats','--section','Occupancy','--section','MemoryWorkloadAnalysis','--clock-control','none','--cache-control','all']
run('ncu-producer',common+['--export',str(base/'producer-counters'),str(root/'out/destruction-sdk/reference/native_gpu_command_inputs_test'),'--large',str(base/'profiled.bin')])
assert (base/'plain.bin').read_bytes()==(base/'profiled.bin').read_bytes()
run('gpu-after',['nvidia-smi'])
