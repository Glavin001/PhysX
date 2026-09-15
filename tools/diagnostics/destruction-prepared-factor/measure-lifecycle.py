#!/usr/bin/env python3
"""Bounded phase-only attribution, distinguishing it from Nsight injection cost.

Same frozen instrumented executable, no collector injection. Phase durations
still contain callback overhead and are not additive or production timings.
"""
import csv
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import statistics
import subprocess
import sys
import time
ROOT=Path(__file__).resolve().parents[3]
BASE=ROOT/'out/destruction-baseline-20260913'
spec=importlib.util.spec_from_file_location('timing',ROOT/'tools/scripts/run-destruction-timing.py')
timing=importlib.util.module_from_spec(spec);spec.loader.exec_module(timing)


def main():
    if len(sys.argv)!=2:raise SystemExit('output-directory')
    out=Path(sys.argv[1]).resolve();out.mkdir(parents=True,exist_ok=False)
    frozen=BASE/'harness/tools/diagnostics/destruction-snapshot'
    # The one explicit exception is diagnostic phase recording without an
    # injected collector. Do not make these outputs eligible as plain timings.
    source=(frozen/'run-probe.py').read_text()
    source=source.replace("root=Path(__file__).resolve().parents[3]",'root=Path('+repr(str(BASE/'harness'))+')')
    old="if build.get('profiling_only') and build.get('binary_sha256')==c.sha(args.binary) and not args.profiler:"
    assert source.count(old)==1
    source=source.replace(old,"if False: # Dedicated phase-only diagnostic; not performance qualification")
    runner=out/'phase-probe.py';runner.write_text(source)
    spec2=importlib.util.spec_from_file_location('observations',frozen/'compare-observations.py')
    observations=importlib.util.module_from_spec(spec2);spec2.loader.exec_module(observations)
    catalog={x['scenario']:x for x in json.loads((BASE/'manifest.json').read_text())['scenarios']}
    record=dict(status='waiting',scope=__doc__,pid=os.getpid(),runner_sha256=hashlib.sha256(source.encode()).hexdigest(),cases=[])
    def save():(out/'campaign.json').write_text(json.dumps(record,indent=2)+'\n')
    desktop=False
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            record['gpu_before']=timing.gpu()
            desktop=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
            if desktop:subprocess.run(['systemctl','stop','sddm'],check=True)
            deadline=time.monotonic()+30
            while any(g['processes'] for g in timing.gpu()['devices']):
                if time.monotonic()>deadline:raise RuntimeError('GPU admission timeout')
                time.sleep(.5)
            record['status']='running';save()
            for name in ['city25-initial-impact','city256-late-debris']:
                case=dict(scenario=name,runs={},physical={},phases={});record['cases'].append(case)
                for arm in ['plain-before','phase-only','plain-after']:
                    dest=out/(name+'-'+arm)
                    binary=BASE/('profile/serialization-probe' if arm=='phase-only' else 'plain/serialization-probe')
                    command=[sys.executable,str(runner if arm=='phase-only' else frozen/'run-probe.py'),str(dest),'--binary',str(binary),'--artifacts',str(BASE/'artifacts'),'--replay-prefix',catalog[name]['prefix'],'--repetitions','2','--watchdog-seconds','90']
                    case['runs'][arm]=dict(command=command);save()
                    with (out/(dest.name+'.log')).open('x') as log:
                        subprocess.run(command,env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1'),stdout=log,stderr=subprocess.STDOUT,check=True,timeout=120)
                    replay=json.loads((dest/'replay.json').read_text());assert replay['passed']
                    samples=replay['samples'];ticks=[r['complete_step_ms'] for r in samples]
                    case['runs'][arm].update(mean_ms=statistics.mean(ticks),max_ms=max(ticks),over_60hz=sum(x>1000/60 for x in ticks),n=len(ticks),first_tick_ms=ticks[0],restore_ms=statistics.mean(x['restore_ms'] for x in samples),stages_ms={k:statistics.mean(x[k] for x in samples) for k in ['command_ms','simulate_fetch_ms','completion_ms']})
                    save()
                for arm in ['phase-only','plain-after']:
                    case['physical'][arm]=observations.compare(out/(name+'-plain-before'),out/(name+'-'+arm))
                with (out/(name+'-phase-only')/'native.phases.csv').open() as stream:
                    for row in csv.DictReader(stream):
                        item=case['phases'].setdefault(row['phase'],dict(count=0,wall_ms=0,thread_cpu_ms=0))
                        item['count']+=1;item['wall_ms']+=float(row['host_wall_ms'])
                        item['thread_cpu_ms']+=max(0,float(row['thread_cpu_ms']))
                save()
            record['status']='complete'
        except BaseException as error:record.update(status='failed',error=repr(error));raise
        finally:
            if desktop:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            save()
    print(record['status'])


if __name__=='__main__':main()
