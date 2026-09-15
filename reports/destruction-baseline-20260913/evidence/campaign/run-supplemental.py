#!/usr/bin/env python3
"""Wait for primary counters, then collect native phase costs without injection."""
import fcntl
import hashlib
import json
import os
import signal
import subprocess
import sys
import time
from pathlib import Path

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[1]
SCRIPTS = BASE/'harness/tools/diagnostics/destruction-snapshot'
OUT = BASE/'phase-only'


def main():
    OUT.mkdir(exist_ok=True)
    record = dict(status='waiting_primary_campaign', pid=os.getpid(), cases=[], scope='Two restored ticks per scenario; native phase clocks/events enabled, no Nsight injection. All timings diagnostic. Waits for the primary campaign to complete successfully; never overlaps it.')
    def save():
        p=OUT/'campaign.json'; t=p.with_suffix('.tmp'); t.write_text(json.dumps(record,indent=2)+'\n'); t.replace(p)
    def interrupted(signum, frame):
        raise RuntimeError('Interrupted: '+str(signum))
    signal.signal(signal.SIGINT,interrupted); signal.signal(signal.SIGTERM,interrupted)
    save()
    while True:
        parent=json.loads((BASE/'campaign.json').read_text())
        if parent['status']=='complete':break
        if parent['status']=='failed':
            record.update(status='primary_failed',error='Primary failure must be reviewed before supplemental work');save();return
        time.sleep(10)
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        record['status']='waiting_shared_lock';save();fcntl.flock(lock,fcntl.LOCK_EX)
        active=subprocess.run(['systemctl','is-active','sddm'],capture_output=True).returncode==0
        record['desktop_was_active']=active;save();proc=None
        def run(command, log):
            nonlocal proc
            with log.open('a') as f:
                proc=subprocess.Popen(command,stdout=f,stderr=subprocess.STDOUT,start_new_session=True,
                    env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1',PYTHONDONTWRITEBYTECODE='1'))
                code=proc.wait()
            if code:raise RuntimeError('Command failed: '+str(log))
        try:
            if active:subprocess.run(['systemctl','stop','sddm'],check=True)
            for case in json.loads((BASE/'manifest.json').read_text())['scenarios']:
                name=case['scenario'];dest=OUT/name;row=dict(scenario=name,status='running',path=str(dest));record['cases'].append(row);record['status']='running';save()
                for path,h in case['input_sha256'].items():assert hashlib.sha256(Path(path).read_bytes()).hexdigest()==h
                command=[sys.executable,str(SCRIPTS/'run-phase-probe.py'),str(dest),'--binary',str(BASE/'profile/serialization-probe'),'--artifacts',str(BASE/'artifacts'),'--replay-prefix',case['prefix'],'--repetitions','2','--watchdog-seconds','600']
                if case.get('projectile_impulse'):command+=['--projectile-impulse']
                row['command']=command;save();run(command,OUT/(name+'-driver.log'))
                comparison=dest/'physical-comparison.json'
                run([sys.executable,str(SCRIPTS/'compare-observations.py'),str(BASE/'references'/('complete-'+name)),str(dest),str(comparison)],dest/'compare.log')
                replay=json.loads((dest/'replay.json').read_text());assert len(replay['samples'])==2
                phases=dest/'native.phases.csv';assert phases.exists()
                row.update(status='complete',physical_comparison=str(comparison),diagnostic_tick_ms=[r['complete_step_ms'] for r in replay['samples']],phase_sha256=hashlib.sha256(phases.read_bytes()).hexdigest());save()
                print('DONE',name,flush=True)
            record['status']='complete'
        except BaseException as error:
            record.update(status='failed',error=repr(error))
            if proc is not None and proc.poll() is None:
                os.killpg(proc.pid,signal.SIGTERM)
                try:proc.wait(timeout=20)
                except subprocess.TimeoutExpired:os.killpg(proc.pid,signal.SIGKILL);proc.wait()
            raise
        finally:
            if active:record['desktop_restore_exit_code']=subprocess.run(['systemctl','start','sddm'],capture_output=True).returncode
            record['finished_unix']=time.time();save()


if __name__=='__main__':main()
