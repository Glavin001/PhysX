#!/usr/bin/env python3
"""Export saved warmed profiles and extract the selected tick; no simulation rerun."""
import argparse,json,subprocess,sys,time
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('campaign',type=Path);a=p.parse_args();out=a.campaign.resolve();start=time.monotonic();record=dict(status='running',commands=[])
try:
    campaign=json.loads((out/'campaign.json').read_text())
    for job in campaign['jobs']:
        dest=out/job['name'];receipt=dest/'receipt.json'
        if job['status']!='complete' or not receipt.exists():continue
        receipt=json.loads(receipt.read_text());profile=receipt.get('profiler',{});kind=profile.get('tool')
        if kind not in ('nsys','ncu'):continue
        if kind=='nsys':
            if (dest/'trace.sqlite').exists():raise RuntimeError('Refusing to overwrite existing SQLite export')
            cmd=[profile['binary']['path'],'export','--type=sqlite','--output',str(dest/'trace.sqlite'),str(dest/'trace.nsys-rep')]
            logfile=dest/'export.log';analysis='timeline'
        else:
            if (dest/'counters.csv').exists():raise RuntimeError('Refusing to overwrite existing counter export')
            cmd=[profile['binary']['path'],'--import',str(dest/'counters.ncu-rep'),'--csv','--page','raw']
            logfile=dest/'counters.csv';analysis='counters'
        record['commands'].append(cmd)
        with logfile.open('w') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,check=True)
        cmd=[sys.executable,str(Path(__file__).with_name('analyze-profile.py')),str(dest),'--kind',analysis];record['commands'].append(cmd)
        with (dest/'analysis.log').open('w') as f:subprocess.run(cmd,stdout=f,stderr=subprocess.STDOUT,check=True)
    record['status']='complete'
except Exception as e:record.update(status='failed',error=str(e));raise
finally:
    record['elapsed_seconds']=time.monotonic()-start
    (out/'exports.json').write_text(json.dumps(record,indent=2)+'\n')
print(record['status'],record['elapsed_seconds'])
