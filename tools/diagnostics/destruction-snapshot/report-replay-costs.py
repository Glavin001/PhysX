#!/usr/bin/env python3
"""Report complete-tick and reusable snapshot workspace costs with physical gates."""
from pathlib import Path
import json,statistics,hashlib,importlib.util,argparse,math
r=Path(__file__).resolve().parents[3]
parser=argparse.ArgumentParser(description='Audit full-tick replay correctness and report setup/reset/validation/teardown costs separately.')
parser.add_argument('output',type=Path)
parser.add_argument('--suite',type=Path,required=True)
parser.add_argument('--reference',type=Path,required=True,help='Qualified matched report with per-scenario raw B observation directories')
args=parser.parse_args();suite=args.suite.resolve();out=args.output.resolve();out.mkdir(parents=True,exist_ok=False)
manifest=json.loads((suite/'manifest.json').read_text());expected=int(manifest['repetitions']);assert expected>=2
ref=json.loads(args.reference.read_text());refs={x['scenario']:x for x in ref['scenarios']}
spec=importlib.util.spec_from_file_location('physical',r/'tools/diagnostics/destruction-snapshot/compare-observations.py');physical=importlib.util.module_from_spec(spec);spec.loader.exec_module(physical)
campaign=json.loads((suite/'campaign.json').read_text());assert len(campaign)==len(manifest['scenarios']) and all(x['exit_code']==0 for x in campaign)
names=[x['scenario'] for x in campaign]
assert len(set(names))==len(names) and set(names)=={x['scenario'] for x in manifest['scenarios']}, 'Missing or duplicated scenario'
binary_hashes=set();module_hashes=set();rows=[];totals=dict(harness_s=0,ticks_s=0,restore_s=0,validation_s=0,teardown_s=0,context_setup_s=0)
for run in campaign:
 name=run['scenario'];p=suite/('complete-'+name);d=json.loads((p/'replay.json').read_text());receipt=json.loads((p/'receipt.json').read_text());assert d['passed'] and receipt['status']=='complete' and 'sanitizer' not in receipt
 assert d['steps_per_restore']==1 and d['repetitions']==expected and d['import_validation_every_sample']
 binary_hashes.add(receipt['binary_sha256']);module_hashes.add(tuple(sorted((Path(k).name,v) for k,v in receipt['modules'].items())))
 assert len(binary_hashes)==len(module_hashes)==1, 'Mixed artifacts in suite'
 samples=d['samples'];assert len(samples)==expected
 assert all(math.isfinite(v) and v>=0 for sample in samples for k,v in sample.items() if k.endswith('_ms'))
 assert all(s['repeatability_passed'] and abs(s['complete_step_ms']-sum(s[k] for k in ['command_ms','simulate_fetch_ms','completion_ms']))<1e-6 for s in samples)
 refdir=Path(refs[name]['raw']['B']);result=physical.compare(refdir,p);assert result['status']=='passed';(out/(name+'-physical.json')).write_text(json.dumps(result,indent=2)+'\n')
 stages={k:statistics.mean(s[k] for s in samples) for k in samples[0] if k.endswith('_ms')}
 row=dict(scenario=name,n=expected,tick_mean_ms=stages['complete_step_ms'],tick_max_ms=max(s['complete_step_ms'] for s in samples),misses_120hz=sum(s['complete_step_ms']>1000/120 for s in samples),misses_60hz=sum(s['complete_step_ms']>1000/60 for s in samples),restore_mean_ms=stages['restore_ms'],first_restore_ms=samples[0]['restore_ms'],repeat_restore_mean_ms=statistics.mean(s['restore_ms'] for s in samples[1:]),repeat_restore_max_ms=max(s['restore_ms'] for s in samples[1:]),stages_ms=stages,context_setup_ms=d['context_setup_ms'],harness_s=receipt['elapsed_monotonic_seconds'],pool=dict(allocations=samples[-1]['pinned_allocations'],reuses=samples[-1]['pinned_reuses'],retained_peak_bytes=samples[-1]['pinned_retained_peak_bytes']),physical_status='passed',reference=refs[name]['B'],raw=str(p))
 for label,values in [('tick',[s['complete_step_ms'] for s in samples]),
                      ('repeat_restore',[s['restore_ms'] for s in samples[1:]])]:
  row[label+'_spread_ms']=dict(min=min(values),median=statistics.median(values),
      sd=statistics.stdev(values) if len(values)>1 else None)
 row['samples']=samples
 rows.append(row);totals['harness_s']+=row['harness_s'];totals['context_setup_s']+=d['context_setup_ms']/1000
 for key,fields in [('ticks_s',['complete_step_ms']),('restore_s',['restore_ms']),('validation_s',['pre_tick_validation_ms','post_tick_validation_ms']),('teardown_s',['teardown_ms'])]:totals[key]+=sum(sum(s[f] for f in fields) for s in samples)/1000
 totals['other_process_s']=totals['harness_s']-sum(totals[k] for k in ['ticks_s','restore_s','validation_s','teardown_s','context_setup_s'])
 (out/'report.json').write_text(json.dumps(dict(status='running',scenarios=rows,totals=totals),indent=2)+'\n')
report=dict(status='complete',scenarios=rows,totals=totals,scope=f'{expected} fresh physical restores per case; bounded pinned storage reuse. Every import and repeated physical output checked. Full tick timer unchanged. First-load and reset costs separate. Historical timing reference is not an interleaved speedup claim.')
(out/'report.json').write_text(json.dumps(report,indent=2)+'\n')
lines=['# Snapshot workspace cost report','',f'{len(rows)} scenarios retain their original physical inputs and checks. {expected} full ticks each; restore/validation excluded from tick milliseconds. Reusable pinned storage does not preserve prior contact/solver data. First restore allocates capacity; subsequent restores reuse it.','','| Scenario | Tick mean / max ms | Repeat restore mean / max ms | First restore ms | 60 Hz misses | 120 Hz misses |','|---|---:|---:|---:|---:|---:|']
for x in rows:lines.append(f"| {x['scenario']} | {x['tick_mean_ms']:.3f} / {x['tick_max_ms']:.3f} | {x['repeat_restore_mean_ms']:.3f} / {x['repeat_restore_max_ms']:.3f} | {x['first_restore_ms']:.3f} | {x['misses_60hz']}/{expected} | {x['misses_120hz']}/{expected} |")
lines+=['','Totals (seconds):','',*['- '+k+': '+f'{v:.3f}' for k,v in totals.items()],'','`report.json` includes all disjoint stages, pool allocations/reuses/capacity and previous workflow measurements. Differences in full ticks are not claimed as application speedups. The combined physics/stress stage includes transfers and synchronization; no stock-PhysX-only timing is implied.','']
(out/'report.md').write_text('\n'.join(lines));print(json.dumps(totals,indent=2))
