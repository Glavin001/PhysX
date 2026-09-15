#!/usr/bin/env python3
"""Exclusive bounded topology-kernel qualification, with desktop restoration."""
import argparse
import fcntl
import hashlib
import importlib.util
import json
from pathlib import Path
import subprocess
import time

ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('timing',ROOT/'tools/scripts/run-destruction-timing.py')
timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('build',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    binary=a.build.resolve()/'topology-test'
    record=dict(status='running',binary_sha256=hashlib.sha256(binary.read_bytes()).hexdigest(),checks=[])
    def save():(out/'checks.json').write_text(json.dumps(record,indent=2)+'\n')
    desktop=False
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            record['gpu_before']=timing.gpu()
            desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
            if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
            deadline=time.monotonic()+30
            while any(g['processes'] for g in timing.gpu()['devices']):
                if time.monotonic()>=deadline:raise RuntimeError('GPU admission timed out')
                time.sleep(.5)
            for tool in ['plain','memcheck','initcheck','synccheck']:
                cmd=[str(binary)] if tool=='plain' else ['/usr/local/cuda-13.4/bin/compute-sanitizer','--tool',tool,'--error-exitcode','97',str(binary)]
                row=dict(name=tool,command=cmd,status='running');record['checks'].append(row);save();start=time.monotonic()
                with (out/(tool+'.log')).open('x') as log:
                    result=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,timeout=180)
                row.update(exit_code=result.returncode,seconds=time.monotonic()-start,status='passed' if result.returncode==0 else 'failed');save()
                if result.returncode:raise RuntimeError('Topology '+tool+' failed')
            record['gpu_after']=timing.gpu();record['status']='passed_topology_kernels_only'
        except BaseException as error:record.update(status='failed',error=repr(error));save();raise
        finally:
            if desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            save()
    print(record['status'])


if __name__=='__main__':main()
