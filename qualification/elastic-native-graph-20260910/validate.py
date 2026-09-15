from pathlib import Path
import subprocess,time,json,hashlib
root=Path.cwd();base=Path(__file__).resolve().parent;runs=[]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()
def run(name,command):
 record={'name':name,'command':command,'maps':{}}
 with (base/(name+'.log')).open('w') as log:
  proc=subprocess.Popen(command,cwd=root,stdout=log,stderr=subprocess.STDOUT);record['pid']=proc.pid
  while proc.poll() is None:
   for entry in Path('/proc').glob('[0-9]*'):
    try:
     executable=entry.joinpath('exe').resolve()
     if not executable.name.startswith('stress_elastic_'):continue
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
 if proc.returncode:raise RuntimeError(name)
run('ctest',['.toolchains/build-env/bin/ctest','--test-dir','out/destruction-sdk','-R','^blast_stress_six_channel_','--output-on-failure','-j1'])
binary=root/'out/destruction-sdk/reference/stress_elastic_native_graph_test'
for tool in ['memcheck','initcheck','synccheck','racecheck']:
 run('native-'+tool,['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','99',str(binary)])
source=root/'out/elastic-input-owners-20260910/native'
captures=[]
for ordinal in [0,82,83,130]:
 directory=source/f'solve-{ordinal}';metadata=json.loads((directory/'manifest.json').read_text())
 command=[str(binary),'--capture',str(directory),str(metadata['ownership_generation']),str(base/f'capture-{ordinal}.bin')]
 captures.append(dict(ordinal=ordinal,metadata=metadata,hashes={f.name:sha(f) for f in directory.glob('*.bin')}))
 run(f'capture-{ordinal}',command)
(base/'input-captures.json').write_text(json.dumps(captures,indent=2)+'\n')
directory=source/'solve-130';metadata=json.loads((directory/'manifest.json').read_text())
args=['--capture',str(directory),str(metadata['ownership_generation']),str(base/'sanitizer.bin')]
for tool in ['memcheck','initcheck','synccheck','racecheck']:
 run('capture-'+tool,['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','99',str(binary),*args])
run('ncu',['/usr/local/cuda-13.4/bin/ncu','--kernel-name-base','function','--kernel-name','regex:bindNodes|bindBonds|unite','--launch-count','3','--section','SpeedOfLight','--section','LaunchStats','--section','Occupancy','--section','MemoryWorkloadAnalysis','--section','SchedulerStats','--clock-control','none','--cache-control','all','--export',str(base/'native-graph-counters'),str(binary),*args[:-1],str(base/'profiled.bin')])
assert (base/'capture-130.bin').read_bytes()==(base/'profiled.bin').read_bytes()
print('profiled/plain native topology mapping byte-identical',flush=True)
