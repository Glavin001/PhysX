#!/usr/bin/env python3
"""Bounded full-step A/B/A with selected Systems traces and focused NCU counters."""
import argparse
import fcntl
import hashlib
import json
import math
import os
from pathlib import Path
import signal
import subprocess
import sys
import time

ROOT=Path(__file__).resolve().parents[3]
sha=lambda p:hashlib.sha256(p.read_bytes()).hexdigest()


def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('output',type=Path)
    p.add_argument('--baseline',type=Path,required=True,help='Frozen screen baseline JSON')
    p.add_argument('--candidate-binary',type=Path,required=True)
    p.add_argument('--candidate-artifacts',type=Path,required=True)
    p.add_argument('--candidate-commit',required=True)
    p.add_argument('--hypothesis',required=True)
    p.add_argument('--budget-seconds',type=float,help='Default180;240 when focused NCU is requested')
    p.add_argument('--candidate-profile-binary',type=Path,help='Enables Systems CPU/GPU attribution after the timing screen')
    p.add_argument('--profile-scenario',action='append',default=[],help='One or two affected light scenarios; traces every kernel/copy in their full tick')
    p.add_argument('--ncu-kernel',help='Optional kernel-name filter for two representative launches in the first profiled scenario')
    p.add_argument('--ncu-metrics',help='Comma-separated hypothesis-specific metrics; defaults to five focused metrics')
    p.add_argument('--manage-desktop',action='store_true',help='Temporarily stop sddm; restore on every exit')
    a=p.parse_args()
    if bool(a.profile_scenario)!=bool(a.candidate_profile_binary) or len(a.profile_scenario)>2:p.error('Pair a profiling binary with one or two scenarios')
    if a.ncu_kernel and not a.profile_scenario:p.error('NCU requires a profiled scenario')
    if a.ncu_metrics and not a.ncu_kernel:p.error('NCU metrics require a selected kernel')
    if a.budget_seconds is None:a.budget_seconds=240 if a.ncu_kernel else 180
    if a.budget_seconds<=0:p.error('Positive time budget required')
    out=a.output.resolve();out.mkdir(parents=True,exist_ok=False)
    baseline=json.loads(a.baseline.read_text())
    for name,h in baseline['files_sha256'].items():
        if sha(Path(name))!=h:raise RuntimeError('Frozen baseline changed: '+name)
    record=dict(status='waiting_shared_gpu_lock',pid=os.getpid(),hypothesis=a.hypothesis,
                candidate_commit=a.candidate_commit,baseline=str(a.baseline.resolve()),
                budget_seconds=a.budget_seconds,scope='Prioritization screen, not promotion. Unprofiled full ticks; restore/check/export outside latency. Compilation excluded from screen wall time.')
    def save():
        t=out/'screen.tmp';t.write_text(json.dumps(record,indent=2)+'\n');t.replace(out/'screen.json')
    def interrupted(signum,frame):raise RuntimeError('Interrupted '+str(signum))
    signal.signal(signal.SIGINT,interrupted);signal.signal(signal.SIGTERM,interrupted)
    save();queued=time.monotonic();child=None;started=None;desktop=False
    def execute(command,log):
        nonlocal child
        remaining=a.budget_seconds-(time.monotonic()-started)
        if remaining<=0:raise subprocess.TimeoutExpired(command,a.budget_seconds)
        with log.open('x') as f:
            child=subprocess.Popen(command,stdout=f,stderr=subprocess.STDOUT,start_new_session=True,
                env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),PYTHONDONTWRITEBYTECODE='1',PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='first'))
            code=child.wait(timeout=remaining)
        if code:raise RuntimeError('Command failed; see '+str(log))
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        fcntl.flock(lock,fcntl.LOCK_EX)
        record['queue_seconds']=time.monotonic()-queued
        try:
            started=time.monotonic();record['status']='running';save()
            desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
            if desktop and not a.manage_desktop:raise RuntimeError('Active desktop; use authorized --manage-desktop for isolation')
            if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
            command=[sys.executable,baseline['matched_runner'],str(out/'matched'),'--manifest',baseline['manifest'],
                     '--use-case-repetitions','--binary',baseline['binary'],'--candidate-binary',str(a.candidate_binary.resolve()),
                     '--baseline-artifacts',baseline['artifacts'],'--candidate-artifacts',str(a.candidate_artifacts.resolve()),
                     '--candidate-commit',a.candidate_commit]
            record['command']=command;save()
            execute(command,out/'driver.log')
            result=json.loads((out/'matched/report.json').read_text());assert result['status']=='complete'
            modules=lambda arm:{Path(k).name:v for k,v in result['modules'][arm].items()}
            record['same_build_calibration']=(result['binaries']['A']['sha256']==result['binaries']['B']['sha256'] and modules('A')==modules('B'))
            record['timing_stage_seconds']=time.monotonic()-started;save()
            signals=[]
            for r in result['scenarios']:
                lo,hi=r['descriptive_saved_ms_95'];before=r['A0']['mean_ms'];after=r['A1']['mean_ms'];b=r['B']['mean_ms']
                drift=abs(after-before)
                signal_name='inconclusive'
                if lo>0 and b<min(before,after) and r['saved_ms']>drift:signal_name='promising_requires_confirmation'
                elif hi<0 and b>max(before,after) and -r['saved_ms']>drift:signal_name='slower_screen_signal'
                signals.append(dict(scenario=r['scenario'],signal='same_build_noise' if record['same_build_calibration'] else signal_name,descriptive_timing_signal=signal_name,saved_ms=r['saved_ms'],control_drift_ms=drift,
                                    means_ms={k:r[k]['mean_ms'] for k in ['A0','B','A1']},peaks_ms={k:r[k]['max_ms'] for k in ['A0','B','A1']},
                                    misses_60hz={k:r[k]['over_60hz'] for k in ['A0','B','A1']}))
            record.update(signals=signals,qualification='Screen only. Descriptive intervals do not measure between-process uncertainty; small effects require another independent comparison. No automatic promotion.')
            if a.profile_scenario:
                profile_start=time.monotonic();scripts=Path(baseline['matched_runner']).parent
                catalog=json.loads(Path(baseline['manifest']).read_text())['scenarios']
                selected=[next(c for c in catalog if c['scenario']==name) for name in a.profile_scenario]
                manifest=out/'profile-manifest.json';manifest.write_text(json.dumps(dict(scenarios=selected),indent=2)+'\n')
                command=[sys.executable,str(scripts/'profile-cpu-suite.py'),str(out/'systems'),'--manifest',str(manifest),'--binary',str(a.candidate_profile_binary.resolve()),'--artifacts',str(a.candidate_artifacts.resolve())]
                record['profile_commands']=[command];save();execute(command,out/'systems-driver.log')
                record['systems_seconds']=time.monotonic()-profile_start;save()
                if a.ncu_kernel:
                    ncu_start=time.monotonic();case=selected[0];dest=out/'ncu'
                    # Small mechanism-oriented set; never full metric/configuration expansion.
                    metrics=a.ncu_metrics or 'gpu__time_duration.sum,launch__registers_per_thread,sm__warps_active.avg.pct_of_peak_sustained_active,smsp__issue_active.avg.pct_of_peak_sustained_active,dram__bytes.sum'
                    command=[sys.executable,str(scripts/'run-probe.py'),str(dest),'--binary',str(a.candidate_profile_binary.resolve()),'--artifacts',str(a.candidate_artifacts.resolve()),'--replay-prefix',case['prefix'],'--repetitions','2','--profiler','ncu','--ncu-kernel',a.ncu_kernel,'--ncu-count','2','--ncu-metrics',metrics,'--ncu-apply-rules','no','--watchdog-seconds','90']
                    if case.get('projectile_impulse'):command+=['--projectile-impulse']
                    record['profile_commands'].append(command);save();execute(command,out/'ncu-driver.log')
                    ncu='/opt/nvidia/nsight-compute/2025.3.1/ncu'
                    execute([ncu,'--import',str(dest/'counters.ncu-rep'),'--page','raw','--csv'],dest/'counters.csv')
                    execute([sys.executable,str(scripts/'analyze-profile.py'),str(dest),'--kind','counters'],dest/'analysis.log')
                    counters=json.loads((dest/'analysis.json').read_text());assert len(counters)==2,'Selected kernel launches were not captured'
                    for counter in counters:
                        assert all(k in counter['metrics'] for k in metrics.split(',')), 'Missing requested counters'
                        for k in metrics.split(','):
                            value=counter['metrics'][k]['value']
                            assert isinstance(value,(int,float)) and math.isfinite(value), 'Invalid counter: '+k
                    execute([sys.executable,str(scripts/'compare-observations.py'),str(out/'matched'/(case['scenario']+'-B')),str(dest),str(dest/'physical-comparison.json')],dest/'compare.log')
                    record['ncu_seconds']=time.monotonic()-ncu_start;record['ncu_launches']=len(counters);save()
            record['status']='complete'
        except subprocess.TimeoutExpired:
            record.update(status='budget_exceeded',qualification='Incomplete screen; preserve partial cases. No complete-suite result or automatic speedup decision.')
        except BaseException as error:
            record.update(status='failed',error=repr(error));raise
        finally:
            if child is not None and child.poll() is None:
                os.killpg(child.pid,signal.SIGTERM)
                try:child.wait(timeout=15)
                except subprocess.TimeoutExpired:os.killpg(child.pid,signal.SIGKILL);child.wait()
            if desktop and a.manage_desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            if started is not None:record['wall_seconds_including_admission_restore_checks_reports']=time.monotonic()-started
            save()
    if record['status']!='complete':raise SystemExit(2)
    print(json.dumps(record,indent=2))


if __name__=='__main__':main()
