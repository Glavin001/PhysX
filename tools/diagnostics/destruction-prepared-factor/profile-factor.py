#!/usr/bin/env python3
"""Bounded Systems capture of the prepared-factor replay's host/device cost."""
import argparse
import fcntl
import importlib.util
import json
from pathlib import Path
import subprocess
import time

ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('timing',ROOT/'tools/scripts/run-destruction-timing.py')
timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('gpu_run',type=Path);p.add_argument('output',type=Path)
    p.add_argument('--ncu',action='store_true',help='Four selected dense-product launches, pinned counter collector')
    a=p.parse_args();out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    source=json.loads((a.gpu_run/'campaign.json').read_text())
    assert json.loads((a.gpu_run/'quality.json').read_text())['passed'], 'Require current-equation qualification'
    cmd=source['cases'][1]['command'].copy();cmd[10]=str(out/'solve-1')
    assert timing.sha(Path(cmd[0]))==source['binary_sha256']
    for path,digest in source['cases'][1]['inputs'].items():assert timing.sha(Path(path))==digest
    if 'dense_input_sha256' in source:assert timing.sha(Path(cmd[-1]))==source['dense_input_sha256']
    tool='/opt/nvidia/nsight-compute/2025.3.1/ncu' if a.ncu else '/opt/nvidia/nsight-systems/2026.3.2/bin/nsys'
    command=([tool,'--kernel-name-base','demangled','--kernel-name','regex:cutlass::Kernel2',
              '--launch-skip','32','--launch-count','4','--replay-mode','kernel','--clock-control','none','--cache-control','none',
              '--metrics','gpu__time_duration.sum,dram__bytes.sum,lts__t_bytes.sum,smsp__sass_thread_inst_executed_op_ffma_pred_on.sum,sm__warps_active.avg.pct_of_peak_sustained_active,smsp__issue_active.avg.pct_of_peak_sustained_active',
              '--export',str(out/'counters'),*cmd] if a.ncu else
             [tool,'profile','--trace=cuda,nvtx','--sample=none','--cpuctxsw=none','-o',str(out/'trace'),*cmd])
    record=dict(status='running',command=command,binary_sha256=source['binary_sha256'],scope='six mathematical replays; no simulation speed claim')
    def save():(out/'profile.json').write_text(json.dumps(record,indent=2)+'\n')
    desktop=False
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            record['gpu_before']=timing.gpu();save()
            desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
            if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
            deadline=time.monotonic()+30
            while any(g['processes'] for g in timing.gpu()['devices']):
                if time.monotonic()>=deadline:raise RuntimeError('GPU admission timeout')
                time.sleep(.5)
            with (out/'capture.log').open('x') as log:subprocess.run(command,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
            with (out/'export.log').open('x') as log:
                if a.ncu:
                    with (out/'counters.csv').open('x') as csv:
                        subprocess.run([tool,'--import',str(out/'counters.ncu-rep'),'--csv','--page','raw'],stdout=csv,stderr=log,check=True,timeout=60)
                else:subprocess.run([tool,'export','--type','sqlite','--output',str(out/'trace.sqlite'),str(out/'trace.nsys-rep')],stdout=log,stderr=subprocess.STDOUT,check=True,timeout=60)
            record['status']='captured_analysis_pending'
        except BaseException as error:record.update(status='failed',error=repr(error));save();raise
        finally:
            if desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            save()


if __name__=='__main__':main()
