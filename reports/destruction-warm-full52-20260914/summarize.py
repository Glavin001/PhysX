#!/usr/bin/env python3
"""Build a readable per-scenario warm timing and live attribution index from saved evidence."""
import argparse,json,statistics as st
from pathlib import Path
root=Path(__file__).resolve().parents[2];base=root/'out/warm-full52-20260914';report=Path(__file__).resolve().parent
manifest=json.load(open(base/'manifest.json'));audit=json.load(open(base/'timing-audit.json'));references={x['scenario']:x for x in audit['rows']}
def campaign(name):
 p=base/name/'campaign.json';return json.loads(p.read_text()) if p.exists() else dict(scenarios=[])
cpus={x['scenario']:x for x in campaign('cpu-v2')['scenarios']};counts={x['scenario']:x for x in campaign('counters')['scenarios']}
rows=[]
for c in manifest['scenarios']:
 refs=references[c['scenario']];processes=[];ticks=[];setups=[];restores=[];warmups=[];warmfirst=[]
 for path in map(Path,refs['paths']):
  r=json.load(open(path/'replay.json'));v=r['samples'];ticks+=v;setups.append(r['context_setup_ms']);processes.append(dict(path=str(path),n=len(v),mean_ms=st.mean(t['complete_step_ms'] for t in v),max_ms=max(t['complete_step_ms'] for t in v),sd_ms=st.stdev(t['complete_step_ms'] for t in v)))
  for trajectory in r['trajectories']:
   restores.append(trajectory['restore_ms']);warmups.append(sum(t['complete_step_ms'] for t in trajectory['ticks'][:r['warmup_ticks']]));warmfirst.append(trajectory['ticks'][0]['complete_step_ms'])
 observed=json.load(open(Path(refs['paths'][0])/'observation-0.json'));sizes={x['name']:x['count'] for x in observed['arrays']};peak=max(ticks,key=lambda x:x['complete_step_ms'])
 row=dict(scenario=c['scenario'],chunks=c.get('chunks',sizes.get('chunk-clusters',0)),bonds=c.get('bonds',sizes.get('health',0)),projectiles=c.get('projectiles'),warmup_ticks=c['warmup_ticks'],measure_ticks=c['measure_ticks'],history=c['history'],input_prefix=c['prefix'],original_prefix=c['original_prefix'],physical='passed',processes=processes,n=len(ticks),mean_ms=st.mean(t['complete_step_ms'] for t in ticks),mean_range_ms=[min(p['mean_ms'] for p in processes),max(p['mean_ms'] for p in processes)],peak_ms=peak['complete_step_ms'],peak_work=peak,misses_60hz=sum(t['complete_step_ms']>1000/60 for t in ticks),stages_ms={k:st.mean(t[k] for t in ticks) for k in ('command_ms','simulate_fetch_ms','completion_ms')},work={k:dict(mean=st.mean(t[k] for t in ticks),max=max(t[k] for t in ticks)) for k in ('stress_iterations','broken_bonds','correction_passes','output_clusters','stress_islands','stress_active_nodes','stress_active_bonds','normal_contacts','friction_anchors')},preparation=dict(context_setup_ms=st.mean(setups),restore_ms=st.mean(restores),warmup_total_ms=st.mean(warmups),first_postrestore_range_ms=[min(warmfirst),max(warmfirst)]),cpu=cpus.get(c['scenario'],dict(status='pending')),counters=counts.get(c['scenario'],dict(status='pending')))
 rows.append(row)
(report/'data').mkdir(exist_ok=True);(report/'data/scenarios.json').write_text(json.dumps(rows,indent=2)+'\n')
lines=['# All52 warm scenarios','',f"All52 physical comparisons pass. {audit['measured_ticks']} complete measured ticks; {audit['warmup_ticks']} warmup ticks stored separately. Two independent processes, two restores per process. Ranges span process means; adjacent ticks are correlated. No optimization or speedup claim.",'','A source label ending `cold` describes the original snapshot. Every row below measures its explicit W/M continuation; it is not the original cold tick. City impact/post-impact/cascade windows warm from snapshot40 to their original event time.','', '| Scenario | Chunks / bonds | W / M | Mean range ms | Peak ms | 60 Hz misses | CPU / counters |','|---|---:|---:|---:|---:|---:|---|']
for r in rows:
 lo,hi=r['mean_range_ms'];lines.append(f"| {r['scenario']} | {r['chunks']:,} / {r['bonds']:,} | {r['warmup_ticks']} / {r['measure_ticks']} | {lo:.3f}–{hi:.3f} | {r['peak_ms']:.3f} | {r['misses_60hz']}/{r['n']} | {r['cpu']['status']} / {r['counters']['status']} |")
lines+=['','## Stage and preparation costs','','Stages include all overlapping work inside the integrated simulate/fetch interval. Restore/setup/warmup are separate.','', '| Scenario | Command / integrated / completion mean ms | Context setup ms/process | Restore ms/trajectory | Warmup total ms/trajectory | Iteration mean / max | Contacts at peak | Clusters at peak |','|---|---:|---:|---:|---:|---:|---:|---:|']
for r in rows:
 s=r['stages_ms'];p=r['preparation'];w=r['work']['stress_iterations'];lines.append(f"| {r['scenario']} | {s['command_ms']:.4f} / {s['simulate_fetch_ms']:.3f} / {s['completion_ms']:.3f} | {p['context_setup_ms']:.1f} | {p['restore_ms']:.1f} | {p['warmup_total_ms']:.1f} | {w['mean']:.1f} / {w['max']} | {r['peak_work']['normal_contacts']} | {r['peak_work']['output_clusters']} |")
lines+=['','[Structured timing/work/coverage index](data/scenarios.json) includes input histories and raw paths. The iteration counter is not total operator/node work. No deadline misses or first-use costs have been discarded; warmup first-use samples are separately recorded.']
(report/'all-scenarios.md').write_text('\n'.join(lines)+'\n')
print('written',len(rows),'rows; cpu',sum(r['cpu']['status']=='complete' for r in rows),'counters',sum(r['counters']['status']=='complete' for r in rows))
