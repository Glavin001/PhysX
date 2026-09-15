#!/usr/bin/env python3
"""Exclusive compile, coefficient comparison and asynchronous memory checks."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time
ROOT=Path(__file__).resolve().parents[3]
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('timing',ROOT/'tools/scripts/run-destruction-timing.py')
timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)


def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('output',type=Path)
    args=parser.parse_args();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
    frozen=out/'source';frozen.mkdir()
    for name in ['producer.cu','PreparedPattern.h','PreparedCoefficientProducer.cuh','PreparedOperator.cuh','check-producer.py','run-producer.py']:
        (frozen/name).write_bytes((HERE/name).read_bytes())
    (frozen/'StressSharedFactorPlan.h').write_bytes((ROOT/'out/n28-native-factor-20260912/StressSharedFactorPlan.h').read_bytes())
    library=ROOT/'.toolchains/cudss-0.8.0.10-cuda13/libcudss-linux-x86_64-0.8.0.10_cuda13-archive'
    binary=out/'producer'
    build=['/usr/local/cuda-13.4/bin/nvcc','-std=c++17','-O3','-lineinfo','-arch=sm_120','-I'+str(library/'include'),str(frozen/'producer.cu'),'-o',str(binary)]
    capture=ROOT/'out/n28-duplicate-census-20260912'
    prefixes=[capture/'city256-initial-impact-problem.world-0.solve-0',*[capture/f'city256-late-debris-problem.world-0.solve-{i}' for i in [0,1]]]
    sha=lambda path:hashlib.sha256(path.read_bytes()).hexdigest()
    record=dict(status='waiting',sources={str(p):sha(p) for p in frozen.iterdir()},inputs={str(Path(str(p)+s)):sha(Path(str(p)+s)) for p in prefixes for s in ['.nodes.bin','.bonds.bin']},checks=[])
    def save():(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    def execute(name,command,timeout):
        row=dict(name=name,command=command);record['checks'].append(row);save();start=time.monotonic()
        with (out/(name+'.log')).open('x') as log:result=subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,timeout=timeout,env=dict(os.environ,OPENBLAS_NUM_THREADS='1'))
        row.update(exit_code=result.returncode,seconds=time.monotonic()-start);save()
        if result.returncode:raise RuntimeError(name+' failed')
    desktop=False
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            record['status']='building';save();execute('build',build,180);record['binary_sha256']=sha(binary)
            record['gpu_before']=timing.gpu()
            desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
            if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
            deadline=time.monotonic()+30
            while any(g['processes'] for g in timing.gpu()['devices']):
                if time.monotonic()>deadline:raise RuntimeError('GPU admission timeout')
                time.sleep(.5)
            record['status']='checking';save()
            for tool in ['plain','memcheck','initcheck','synccheck']:
                dest=out/tool;dest.mkdir()
                command=[str(binary),*map(str,prefixes),str(dest)]
                if tool!='plain':command=['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','97',*command]
                execute(tool,command,180)
                execute(tool+'-quality',[sys.executable,str(frozen/'check-producer.py'),str(ROOT/'out/prepared-remnant-20260913/batch-inputs'),str(dest)],90)
            record['status']='passed_coefficients_and_memory'
        except BaseException as error:record.update(status='failed',error=repr(error));raise
        finally:
            if desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            save()
    print(record['status'])


if __name__=='__main__':main()
