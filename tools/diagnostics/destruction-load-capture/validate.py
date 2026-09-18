#!/usr/bin/env python3
"""Validate/counter-profile an offline replay; retain every command and loaded module."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import time

root=Path(__file__).resolve().parents[3]
p=argparse.ArgumentParser(description=__doc__)
p.add_argument('--capture',type=Path,required=True)
p.add_argument('--replay',type=Path,required=True)
p.add_argument('--output',type=Path,required=True)
a=p.parse_args()
capture=a.capture.resolve();binary=a.replay.resolve();base=a.output.resolve();base.mkdir()
results=base/'replays';results.mkdir()
sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
runs=[]

def run(name,cmd):
    record={'name':name,'command':list(map(str,cmd)),'maps':{}}
    with (base/(name+'.log')).open('w') as log:
        process=subprocess.Popen(record['command'],stdout=log,stderr=subprocess.STDOUT,cwd=root)
        record['pid']=process.pid
        while process.poll() is None:
            for proc in Path('/proc').glob('[0-9]*'):
                try:
                    if proc.joinpath('exe').resolve() not in {binary,root/'out/destruction-sdk/reference/stress_elastic_loads_test',
                                                            root/'out/destruction-sdk/reference/stress_elastic_partition_test'}:
                        continue
                    parent=int(proc.name)
                    while parent>1 and parent!=process.pid:
                        status=Path(f'/proc/{parent}/status').read_text()
                        parent=int(next(line.split()[1] for line in status.splitlines() if line.startswith('PPid:')))
                    if parent!=process.pid:
                        continue
                    content=proc.joinpath('maps').read_text()
                    if 'libcuda.so' in content:
                        path=base/(name+'-'+proc.name+'.maps');path.write_text(content)
                        record['maps'][proc.name]=str(path)
                except (OSError,RuntimeError,StopIteration):
                    pass
            time.sleep(.025)
    record['exit_code']=process.returncode
    paths=set()
    for file in record['maps'].values():
        for line in Path(file).read_text().splitlines():
            last=line.split()[-1]
            if last.startswith('/') and Path(last).is_file():
                paths.add(last)
    record['loaded_modules']={path:sha(Path(path)) for path in sorted(paths)}
    runs.append(record)
    (base/'validation-runs.json').write_text(json.dumps(runs,indent=2)+'\n')
    print(name,process.returncode,flush=True)
    if process.returncode:
        raise RuntimeError(f'{name} failed; preserve its log')

def command(i,prefix):
    directory=capture/('solve-'+str(i));m=json.loads((directory/'manifest.json').read_text())
    return [binary,directory,m['tick'],m['evaluation'],m['ownership_generation'],m['response_epoch'],m['seconds'],*m['gravity'],results/prefix]

for i in [0,82,83,130]:
    run('replay-'+str(i),command(i,'solve-'+str(i)))
run('ctest',['.toolchains/build-env/bin/ctest','--test-dir','out/destruction-sdk','-R','^blast_stress_six_channel_','--output-on-failure'])
run('reference-check',[root/'.toolchains/build-env/bin/python',Path(__file__).with_name('check_replay.py'),capture,results])
for tool in ['memcheck','initcheck','synccheck','racecheck']:
    run(tool,['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','99',*command(130,tool)])
    run('partition-'+tool,['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','99',
                          root/'out/destruction-sdk/reference/stress_elastic_partition_test'])
run('ncu',['/usr/local/cuda-13.4/bin/ncu','--kernel-name-base','function','--kernel-name','regex:pack|build','--launch-count','2',
    '--section','SpeedOfLight','--section','LaunchStats','--section','Occupancy','--section','MemoryWorkloadAnalysis',
    '--clock-control','none','--cache-control','all','--export',base/'native-load-counters',*command(130,'ncu')])
for suffix in ['receipts.bin','effective.bin']:
    if sha(results/('solve-130.'+suffix))!=sha(results/('ncu.'+suffix)):
        raise RuntimeError('Counter replay changed numerical output')
