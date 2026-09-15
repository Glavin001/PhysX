"""Recompute the archived scenario table; never run benchmarks or update experiment status."""
from pathlib import Path
import csv,json,statistics
root=Path(__file__).resolve().parent
report=json.loads((root/'evidence/full52.json').read_text());samples=list(csv.DictReader((root/'samples.csv').open()));assert len(samples)==3120
rows=[]
for case in report['scenarios']:
 for arm in ['A0','B','A1']:
  values=[x for x in samples if x['scenario']==case['scenario'] and x['arm']==arm];assert len(values)==20
  times=[float(x['complete_step_ms']) for x in values];s=case[arm]
  for name,actual in [('mean_ms',statistics.mean(times)),('max_ms',max(times)),('sd_ms',statistics.stdev(times))]:assert abs(actual-s[name])<1e-9
  assert sum(t>1000/60 for t in times)==s['over_60hz']
  stages={k:statistics.mean(float(v[k]) for v in values) for k in ['command_ms','simulate_fetch_ms','completion_ms']}
  assert abs(sum(stages.values())-s['mean_ms'])<1e-6
  rows.append(dict(scenario=case['scenario'],arm=arm,mean_ms=s['mean_ms'],max_ms=s['max_ms'],sd_ms=s['sd_ms'],n=20,misses60hz=s['over_60hz'],restore_mean_ms=statistics.mean(float(x['restore_ms']) for x in values),context_setup_ms=case['context_setup_ms'][arm],**stages))
with (root/'scenarios.csv').open('w') as f:
 w=csv.DictWriter(f,fieldnames=list(rows[0]),lineterminator="\n");w.writeheader();w.writerows(rows)
print('52 scenarios,3120 samples and all stage sums/deadline counts verified.')
