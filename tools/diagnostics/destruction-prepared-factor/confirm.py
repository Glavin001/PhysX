#!/usr/bin/env python3
"""Bounded independent A/B/A confirmation using the frozen physical contract."""
import argparse
import fcntl
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('timing', ROOT/'tools/scripts/run-destruction-timing.py')
timing = importlib.util.module_from_spec(spec)
spec.loader.exec_module(timing)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('candidate', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('--scenario')
    parser.add_argument('--full', action='store_true', help='Finalist full52 qualification, still 20/20/20 samples')
    parser.add_argument('--mechanism-check', action='store_true', help='Three 2/2/2 native cases plus two asynchronous memory cases')
    args = parser.parse_args()
    if sum(map(bool,[args.scenario,args.full,args.mechanism_check]))!=1:
        parser.error('Select exactly one of --scenario, --full or --mechanism-check')
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=False)
    baseline = json.loads((ROOT/'out/destruction-baseline-20260913/fast-baseline.json').read_text())
    source_manifest = ROOT/'out/destruction-baseline-20260913/manifest.json' if args.full or args.mechanism_check else Path(baseline['manifest'])
    cases = json.loads(source_manifest.read_text())['scenarios']
    selected = cases if args.full else [case for case in cases if case['scenario'] in (['bridge64-cold','city25-initial-impact','city256-late-debris'] if args.mechanism_check else [args.scenario])]
    assert len(selected) == (52 if args.full else 3 if args.mechanism_check else 1), 'Unexpected frozen scenario count'
    manifest = output/'manifest.json'
    manifest.write_text(json.dumps(dict(scenarios=selected), indent=2)+'\n')
    command = [sys.executable, baseline['matched_runner'], str(output/'matched'),
               '--manifest', str(manifest), '--binary', baseline['binary'],
               '--baseline-artifacts', baseline['artifacts'],
               '--candidate-artifacts', str(args.candidate.resolve()),
               '--candidate-commit', 'uncommitted; identity in candidate build.json',
               '--control-repetitions', '2' if args.mechanism_check else '20', '--candidate-repetitions', '2' if args.mechanism_check else '20']
    record = dict(status='waiting', command=command, scenario=args.scenario, full52=args.full,mechanism_check=args.mechanism_check)
    def save():
        (output/'campaign.json').write_text(json.dumps(record, indent=2)+'\n')
    save()
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
        desktop = False
        start = time.monotonic()
        try:
            record['gpu_before'] = timing.gpu()
            desktop = subprocess.run(['systemctl', 'is-active', 'sddm'], capture_output=True).returncode == 0
            if desktop:
                subprocess.run(['systemctl', 'stop', 'sddm'], check=True)
            deadline = time.monotonic()+30
            while any(device['processes'] for device in timing.gpu()['devices']):
                if time.monotonic() > deadline:
                    raise RuntimeError('GPU admission timed out')
                time.sleep(.5)
            record['status'] = 'running'
            save()
            with (output/'run.log').open('x') as log:
                result = subprocess.run(command, stdout=log, stderr=subprocess.STDOUT,
                                        env=dict(os.environ, PHYSX_BASELINE_LOCK_OWNER=str(os.getpid())), timeout=1800 if args.full else 300)
            record['exit_code'] = result.returncode
            if result.returncode:
                raise RuntimeError('Matched confirmation failed')
            if args.mechanism_check:
                frozen=Path(baseline['matched_runner']).parent
                spec=importlib.util.spec_from_file_location('observations',frozen/'compare-observations.py')
                observations=importlib.util.module_from_spec(spec);spec.loader.exec_module(observations)
                record['memory']=[]
                for case in selected:
                    if case['scenario']=='bridge64-cold':continue
                    dest=output/(case['scenario']+'-memcheck')
                    cmd=[sys.executable,str(frozen/'run-probe.py'),str(dest),'--binary',baseline['binary'],
                         '--artifacts',str(args.candidate.resolve()),'--replay-prefix',case['prefix'],'--repetitions','2',
                         '--sanitizer','memcheck','--watchdog-seconds','150']
                    row=dict(scenario=case['scenario'],command=cmd);record['memory'].append(row);save()
                    with (output/(dest.name+'.log')).open('x') as log:
                        result=subprocess.run(cmd,stdout=log,stderr=subprocess.STDOUT,env=dict(os.environ,PHYSX_BASELINE_LOCK_OWNER=str(os.getpid()),PHYSX_SNAPSHOT_DUMP_OBSERVATIONS='1'),timeout=180)
                    row['exit_code']=result.returncode;save()
                    if result.returncode:raise RuntimeError('Native asynchronous memory check failed')
                    row['physical']=observations.compare(output/'matched'/(case['scenario']+'-A0'),dest);save()
                    if row['physical']['status']!='passed':
                        raise RuntimeError('Memory-run physical comparison failed')
            record['status'] = 'complete'
        except BaseException as error:
            record.update(status='failed', error=repr(error))
            raise
        finally:
            if desktop:
                record['desktop_restore_exit_code'] = subprocess.run(['systemctl', 'start', 'sddm'], capture_output=True).returncode
            record['seconds'] = time.monotonic()-start
            save()
    print(record['status'])


if __name__ == '__main__':
    main()
