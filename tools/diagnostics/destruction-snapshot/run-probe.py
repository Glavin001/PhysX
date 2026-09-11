#!/usr/bin/env python3
"""Run the serialization diagnostic with exact GPU/module provenance."""
import argparse
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import time

root=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('capture',root/'tools/scripts/run-destruction-timing.py')
c=importlib.util.module_from_spec(spec);spec.loader.exec_module(c)
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('output',type=Path)
parser.add_argument('--binary',type=Path,required=True)
parser.add_argument('--artifacts',type=Path,required=True)
parser.add_argument('--allow-existing-graphics',action='store_true')
parser.add_argument('--allow-compute-pid',type=int,action='append',default=[])
parser.add_argument('--require-complete-shapes',action='store_true')
parser.add_argument('--sanitizer',choices=['memcheck','initcheck','synccheck'])
parser.add_argument('--watchdog-seconds',type=float,default=120)
parser.add_argument('--replay-prefix',type=Path)
parser.add_argument('--repetitions',type=int,default=10)
parser.add_argument('--projectile-impulse',action='store_true')
args=parser.parse_args()
out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
arm=args.artifacts.resolve();binary=args.binary.resolve()
record={'command':[str(binary),str(out)],'binary_sha256':c.sha(binary),'samples':[],'status':'running',
        'diagnostic_environment':{k:v for k,v in os.environ.items() if k.startswith('PHYSX_SNAPSHOT_')}}
if args.require_complete_shapes:record['command'].append('--require-complete-shapes')
if args.replay_prefix:
    prefix=args.replay_prefix.resolve()
    record['snapshot_inputs']={str(prefix)+suffix:c.sha(Path(str(prefix)+suffix)) for suffix in ('.pxbin','.destruction')}
    record['command'] += ['--replay',str(prefix),'--repetitions',str(args.repetitions)]
    if args.projectile_impulse:record['command'].append('--projectile-impulse')
if args.sanitizer:record['command']=['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',args.sanitizer,'--error-exitcode','97',*record['command']]
def owned(pid,parent):
    seen=set()
    while pid and pid not in seen:
        if pid==parent:return True
        seen.add(pid)
        try:
            fields=Path(f'/proc/{pid}/status').read_text().splitlines()
            pid=int(next(line for line in fields if line.startswith('PPid:')).split()[1])
        except (OSError,StopIteration):return False
    return False
def save():(out/'receipt.json').write_text(json.dumps(record,indent=2)+'\n')
with (root/'out/destruction-ab.lock').open('a') as lock:
    fcntl.flock(lock,fcntl.LOCK_EX|fcntl.LOCK_NB)
    initial=c.gpu();record['before']=initial
    allowed=[p for g in initial['devices'] for p in g['processes'] if
             (args.allow_existing_graphics and p['type']=='G') or p['pid'] in args.allow_compute_pid]
    record['allowed']=allowed
    if any(p not in allowed for g in initial['devices'] for p in g['processes']):raise RuntimeError('Unlisted GPU process')
    start=time.monotonic()
    try:
        with (out/'stdout.log').open('w') as log:
            process=subprocess.Popen(record['command'],env=dict(os.environ,LD_LIBRARY_PATH=str(arm)),stdout=log,stderr=subprocess.STDOUT)
            try:
                while process.poll() is None:
                    sample=c.gpu();record['samples'].append(sample)
                    extra=[p for g in sample['devices'] for p in g['processes'] if p not in allowed]
                    if len(extra)>1:raise RuntimeError('Unlisted GPU process')
                    if extra:
                        if not owned(extra[0]['pid'],process.pid):raise RuntimeError('GPU process is not an owned target')
                        if record.get('gpu_pid',extra[0]['pid'])!=extra[0]['pid']:raise RuntimeError('GPU identity changed')
                        record['gpu_pid']=extra[0]['pid']
                    maps=Path(f'/proc/{extra[0]["pid"] if extra else process.pid}/maps')
                    if maps.exists():
                        raw=maps.read_text()
                        if all(n in raw for n in ['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']):
                            paths={line.split()[-1] for line in raw.splitlines() if '/' in line}
                            names=['libPhysXGpuActivity_64.so','libPhysXDestructionGpuRuntime_64.so']
                            if not all(str(arm/n) in paths for n in names):raise RuntimeError('Wrong mapped modules')
                            (out/'process.maps').write_text(raw)
                            record['modules']={str(arm/n):c.sha(arm/n) for n in names}
                    if time.monotonic()-start>args.watchdog_seconds:raise RuntimeError('Probe watchdog')
                    time.sleep(.2)
                record['exit_code']=process.returncode
            finally:
                if process.poll() is None:process.terminate();process.wait(timeout=30)
        if record['exit_code'] or 'modules' not in record:raise RuntimeError('Probe failed or missing maps')
        record['status']='complete'
    except BaseException as error:
        record.update(status='failed',error=str(error));raise
    finally:
        record['after']=c.gpu();save()
print(record['status'],out)
