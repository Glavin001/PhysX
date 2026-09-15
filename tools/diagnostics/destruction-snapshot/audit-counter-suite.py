#!/usr/bin/env python3
"""Verify complete targeted NCU coverage and physical evidence for a scenario manifest."""
import argparse
import hashlib
import json
import math
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('campaign',type=Path)
p.add_argument('output',type=Path)
a=p.parse_args()
d=json.loads((a.campaign/'campaign.json').read_text())
m=json.loads((a.campaign/'manifest.json').read_text())
assert d['status']=='complete'
expected={r['scenario'] for r in m['scenarios']}
assert len(expected)==len(m['scenarios'])==len(d['scenarios'])
assert expected=={r['scenario'] for r in d['scenarios']}
required={'launch__registers_per_thread','sm__warps_active.avg.pct_of_peak_sustained_active',
 'smsp__warps_eligible.avg.per_cycle_active','smsp__issue_active.avg.pct_of_peak_sustained_active',
 'sm__pipe_fp64_cycles_active.avg.pct_of_peak_sustained_elapsed','dram__bytes.sum.per_second',
 'lts__t_sector_hit_rate.pct','l1tex__t_sector_hit_rate.pct'}
rows=[]
for r in d['scenarios']:
 assert r['status']=='complete' and r['counter_mode']=='full' and r['counters'],r['scenario']
 row=dict(scenario=r['scenario'],captures=[],physical_ticks=0,launches=0)
 for c in r['counters']:
  directory=Path(c['path']);receipt=json.loads((directory/'receipt.json').read_text())
  replay=json.loads((directory/'replay.json').read_text());physical=json.loads(Path(c['physical_comparison']).read_text())
  assert receipt['status']=='complete' and receipt['exit_code']==0 and replay['passed']
  assert receipt['profiler']['version']==d['ncu']['version'] and receipt['profiler']['metric_mode']=='full'
  assert not receipt['profiler'].get('explicit_metrics') and not receipt['profiler'].get('preload')
  assert receipt['binary_sha256']==d['identity']['binary_sha256']
  assert {Path(k).name:v for k,v in receipt['modules'].items()}==d['identity']['modules']
  assert receipt['snapshot_inputs']==r['input_sha256']
  assert replay['steps_per_restore']==1 and replay['repetitions']==2 and len(replay['samples'])==2
  assert all(s['repeatability_passed'] for s in replay['samples'])
  if json.loads((directory/'observation-0.json').read_text())['destructive']:
   assert all(s['correction_passes']<=1 and s['stress_passes']==1+s['correction_passes'] for s in replay['samples'])
  assert physical['status']=='passed' and Path(physical['candidate']).resolve()==directory.resolve()
  reports=list(directory.glob('counters.ncu-rep*'));assert len(reports)==1
  assert hashlib.sha256(reports[0].read_bytes()).hexdigest()==c['report_sha256']
  launches=json.loads((directory/'analysis.json').read_text());assert len(launches)==c['launches']>0
  for launch in launches:
   metrics=launch['metrics'];assert required<=metrics.keys(),(r['scenario'],required-metrics.keys())
   assert all(isinstance(metrics[k]['value'],(int,float)) and math.isfinite(metrics[k]['value']) for k in required)
   assert any('issue_stalled' in k for k in metrics)
  row['physical_ticks']+=len(replay['samples']);row['launches']+=len(launches)
  row['captures'].append(dict(path=str(directory),launches=len(launches),metric_counts=[len(l['metrics']) for l in launches],physical_comparison=c['physical_comparison'],report_sha256=c['report_sha256']))
 rows.append(row)
result=dict(status='passed',scenarios=len(rows),captures=sum(len(r['captures']) for r in rows),launches=sum(r['launches'] for r in rows),physical_ticks=sum(r['physical_ticks'] for r in rows),collector=d['ncu'],rows=rows,scope='Full NCU metric set on selected dominant/stress launches for every manifest scenario, with complete physical continuation and comparison to unprofiled reference. Not every helper launch.')
a.output.parent.mkdir(parents=True,exist_ok=True)
assert not a.output.exists()
a.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:v for k,v in result.items() if k not in ['rows','collector']},indent=2))
