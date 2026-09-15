import importlib.util
import json
import subprocess
import sys
import time
from pathlib import Path

base = Path(__file__).resolve().parent
root = base.parents[1]
spec = importlib.util.spec_from_file_location('runner', root/'tools/scripts/run-destruction-timing.py')
r = importlib.util.module_from_spec(spec)
spec.loader.exec_module(r)
mode = sys.argv[1]
destination = base/mode
destination.mkdir()
config = json.loads((base/'config.json').read_text())
case = next(c for c in config['cases'] if c['id']=='impacts-256')
binary = root/'out/destruction-sdk/reference/native_destruction_demo'
simulation = [str(binary), *config['common'], *case['args'], '--seconds', '3',
              '--output', str(destination/'scene'), '--profile-phases','1','--profile-gpu','0']
if mode == 'timeline':
    command = ['/usr/local/cuda-13.4/bin/nsys','profile','--trace=cuda,nvtx,osrt',
               '--sample=none','--cpuctxsw=none','--cuda-graph-trace=node',
               '--output',str(destination/'trace'), *simulation]
else:
    skip = int(sys.argv[2])
    command = ['/usr/local/cuda-13.4/bin/ncu','--kernel-name-base','function',
               '--kernel-name','regex:componentStressSolve','--launch-skip',str(skip),
               '--launch-count','2','--replay-mode','kernel','--graph-profiling','node',
               '--clock-control','none','--cache-control','all',
               '--section','SpeedOfLight','--section','MemoryWorkloadAnalysis',
               '--section','SchedulerStats','--section','Occupancy','--section','WarpStateStats',
               '--section','LaunchStats','--section','ComputeWorkloadAnalysis',
               '--section','InstructionStats','--export',str(destination/'stress'), *simulation]
    if mode.startswith('application-'):
        command = ['/usr/local/cuda-13.4/bin/ncu','--kernel-name-base','function',
                   '--kernel-name','regex:componentStressSolve','--launch-skip',str(skip),
                   '--launch-count','2','--replay-mode','application','--app-replay-mode','strict',
                   '--target-processes','all','--kill','yes','--graph-profiling','node',
                   '--clock-control','none','--cache-control','all',
                   '--section','SpeedOfLight','--section','ComputeWorkloadAnalysis',
                   '--section','SchedulerStats','--section','Occupancy','--section','LaunchStats',
                   '--export',str(destination/'stress'),
                   str(root/'.toolchains/build-env/bin/python'),str(base/'replay_target.py'),str(destination)]
    if mode.startswith('single-'):
        command[command.index('--launch-count')+1]='1'
        command[command.index('--export'):command.index('--export')]=['--kill','yes']
initial = r.gpu()
allowed = [p for g in initial['devices'] for p in g['processes'] if p['type']=='G']
assert not r.competing_processes(initial, allowed), 'Competing GPU process; no service stopped'
receipt = {'command':command,'initial_gpu':initial,'allowed_graphics':allowed,
           'diagnostic_only':True,'samples':[],'status':'running',
           'binary_sha256':r.sha(binary),'config_sha256':r.sha(base/'config.json')}
receipt_path = destination/'receipt.json'
def save():
    receipt_path.write_text(json.dumps(receipt,indent=2)+'\n')
with (destination/'capture.log').open('w') as log:
    p = subprocess.Popen(command,cwd=root,stdout=log,stderr=subprocess.STDOUT)
    receipt['profiler_pid']=p.pid
    save()
    start = time.monotonic()
    try:
        while p.poll() is None:
            sample = r.gpu();receipt['samples'].append(sample)
            observed = r.competing_processes(sample,allowed)
            assert len(observed)<=1, 'Competing GPU process appeared'
            if observed:
                pid=observed[0]['pid']
                if not mode.startswith('application-'):
                    assert receipt.get('gpu_pid',pid)==pid, 'GPU process changed'
                receipt['gpu_pid']=pid
                if mode.startswith('application-'):
                    receipt.setdefault('application_replay_pids',[])
                    if pid not in receipt['application_replay_pids']:
                        receipt['application_replay_pids'].append(pid)
                maps=Path(f'/proc/{pid}/maps')
                if 'maps_sha256' not in receipt and maps.exists():
                    content=maps.read_text()
                    if 'libPhysXDestructionGpuRuntime_64.so' in content and 'libPhysXGpuActivity_64.so' in content:
                        (destination/'loaded.maps').write_text(content)
                        receipt['maps_sha256']=r.sha(destination/'loaded.maps')
            assert time.monotonic()-start<600, 'Diagnostic exceeded 10 minute watchdog'
            time.sleep(.5)
        receipt['exit_code']=p.returncode
        receipt['status']='complete' if p.returncode==0 else 'failed'
    except BaseException as exc:
        if p.poll() is None:
            p.terminate();p.wait(timeout=30)
        receipt['status']='failed';receipt['error']=str(exc)
        raise
    finally:
        if (destination/'loaded.maps').exists():
            paths={line.split()[-1] for line in (destination/'loaded.maps').read_text().splitlines() if '/' in line and '.so' in line}
            receipt['loaded_modules']={path:r.sha(Path(path)) for path in sorted(paths) if Path(path).is_file()}
        receipt['final_gpu']=r.gpu()
        save()
print(mode,receipt['status'],receipt['exit_code'],flush=True)
sys.exit(receipt['exit_code'])
