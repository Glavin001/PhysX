#!/usr/bin/env python3
"""Build archival tables/plots only after every queued GPU collector is terminal."""
import fcntl
import hashlib
import json
import os
import subprocess
import sys
import time
from pathlib import Path

BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[1]
REPORT=ROOT/'reports/destruction-baseline-20260913'
record=dict(status='waiting_all_collectors',pid=os.getpid())


def save():
    p=BASE/'finalization.json';tmp=p.with_suffix('.tmp');tmp.write_text(json.dumps(record,indent=2)+'\n');tmp.replace(p)


def main():
    save()
    while True:
        paths=[BASE/'campaign.json',BASE/'phase-only/campaign.json',BASE/'allocation-pilots/campaign.json']
        statuses=[json.loads(p.read_text())['status'] for p in paths]
        if any(s in ['failed','primary_failed'] for s in statuses):
            record.update(status='collection_failed_review_required',collectors=statuses);save();return
        if all(s=='complete' for s in statuses):break
        time.sleep(10)
    with (ROOT/'out/destruction-ab.lock').open('a') as lock:
        record['status']='waiting_shared_lock';save();fcntl.flock(lock,fcntl.LOCK_EX)
        record['status']='building_report';save()
        try:
            for script in ['rebuild-baseline.py','collect-summaries.py']:
                subprocess.run([sys.executable,str(REPORT/script)],check=True)
            # Install binary wheels only in this campaign, after GPU collection.
            # Keep the host Python environment and runtime SDK unchanged.
            deps=BASE/'plot-deps'
            subprocess.run([sys.executable,'-m','pip','install','--only-binary=:all:','--target',str(deps),'matplotlib==3.10.8'],check=True)
            subprocess.run([sys.executable,str(REPORT/'render-figures.py')],check=True,env=dict(os.environ,PYTHONPATH=str(deps),MPLCONFIGDIR=str(BASE/'matplotlib-cache')))
            ledger=json.loads((REPORT/'data/attribution-ledger.json').read_text())
            assert all(ledger['coverage'][k]['complete']==52 for k in ['cpu-full','graphs-full','configs-full','phase-only'])
            assert ledger['coverage']['warm']['complete']==2
            public=REPORT/'evidence/campaign';public.mkdir(exist_ok=True)
            for name in ['run-analysis.py','run-supplemental.py','run-allocation-pilots.py','finalize-analysis.py','campaign.json','campaign-lock-fix.json','graph-inventory-fix.json']:
                (public/name).write_bytes((BASE/name).read_bytes())
            for tier in ['cpu-full','graphs-full','configs-full','warm','phase-only','allocation-pilots']:
                (public/(tier+'-campaign.json')).write_bytes((BASE/tier/'campaign.json').read_bytes())
            for name in ['run-probe.py','run-phase-probe.py','profile-graph-suite.py']:
                (public/name).write_bytes((BASE/'harness/tools/diagnostics/destruction-snapshot'/name).read_bytes())
            files=[]
            for path in sorted(REPORT.rglob('*')):
                if path.is_file() and path.name!='package-manifest.json' and '__pycache__' not in path.parts:
                    files.append(dict(path=str(path.relative_to(REPORT)),bytes=path.stat().st_size,sha256=hashlib.sha256(path.read_bytes()).hexdigest()))
            (REPORT/'package-manifest.json').write_text(json.dumps(files,indent=2)+'\n')
            record.update(status='data_collected_analysis_review_pending',coverage=ledger['coverage'],finished_unix=time.time(),report=str(REPORT))
        except BaseException as error:
            record.update(status='report_failed',error=repr(error));raise
        finally:save()


if __name__=='__main__':main()
