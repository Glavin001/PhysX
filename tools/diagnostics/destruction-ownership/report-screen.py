#!/usr/bin/env python3
"""Write complete warm-screen timing, preparation and work tables from receipts."""
import argparse, json, statistics
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('campaign',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
root=a.campaign;campaign=json.loads((root/'campaign.json').read_text());rows=[]
for job in campaign['jobs']:
    if job['status']!='complete' or '-nsys' in job['name'] or '-ncu' in job['name']:continue
    d=json.loads((root/job['name']/'replay.json').read_text());ticks=d['samples']
    mean=lambda k:statistics.mean(t[k] for t in ticks)
    traj=d['trajectories'];warm=[t for v in traj for t in v['ticks'] if not t['measured']]
    rows.append(dict(name=job['name'],n=len(ticks),mean=mean('complete_step_ms'),peak=max(t['complete_step_ms'] for t in ticks),misses=sum(t['complete_step_ms']>1000/60 for t in ticks),
        command=mean('command_ms'),physics=mean('simulate_fetch_ms'),completion=mean('completion_ms'),
        restore=statistics.mean(v['restore_ms'] for v in traj),setup=d['context_setup_ms'],warm=statistics.mean(t['complete_step_ms'] for t in warm),
        iterations=mean('stress_iterations'),broken=mean('broken_bonds'),corrections=mean('correction_passes'),
        islands=mean('stress_islands'),active_nodes=mean('stress_active_nodes'),active_bonds=mean('stress_active_bonds'),contacts=mean('normal_contacts'),anchors=mean('friction_anchors')))
text=['# Warm screen: every measured scenario','',f'Receipt: `{root}/campaign.json`. Campaign status: {campaign["status"]}; capture/check time {campaign.get("elapsed_seconds",0):.3f}s. All durations below are milliseconds. Each arm/slot is a separate process; its schedule is recorded in the plan. Two restores per process, fixed real warmup; first measured tick retained. Restore and warmup are excluded from complete-step timing. Samples within a trajectory are correlated; these are descriptive results, not independent statistical trials.','',
'## Complete-step and stages','','`simulate/fetch` includes PhysX, stress/material, transfers, waits and optional corrected physics. Completion includes the remaining publication/observation work. Fine-grained native scopes are only available in the separately instrumented selected profile.','',
'| Scenario/arm | N | Mean | Peak | >16.667ms | Command | Simulate/fetch | Completion |','|---|---:|---:|---:|---:|---:|---:|---:|']
for r in rows:text.append(f'| {r["name"]} | {r["n"]} | {r["mean"]:.3f} | {r["peak"]:.3f} | {r["misses"]}/{r["n"]} | {r["command"]:.6f} | {r["physics"]:.3f} | {r["completion"]:.3f} |')
text+=['','## Preparation excluded from tick timing','','Context setup is once per process; restore is the mean per trajectory; warm tick is the mean over the fixed physical warmup. Costs remain recorded rather than silently primed away.','','| Scenario/arm | Context setup | Restore | Warm tick |','|---|---:|---:|---:|']
for r in rows:text.append(f'| {r["name"]} | {r["setup"]:.3f} | {r["restore"]:.3f} | {r["warm"]:.3f} |')
text+=['','## Actual work, mean per measured tick','','The physical checker compares complete work histories, including warmup. Counts below are window means, not reconstructed compute scores. Fractures, contacts and component sizes can vary through a window.','','| Scenario/arm | Stress iterations | New broken bonds | Corrections | Stress islands | Active nodes | Active bonds | Contacts | Friction anchors |','|---|---:|---:|---:|---:|---:|---:|---:|---:|']
for r in rows:text.append('| '+r['name']+' | '+' | '.join(f'{r[k]:.3f}' for k in ['iterations','broken','corrections','islands','active_nodes','active_bonds','contacts','anchors'])+' |')
text+=['','Raw observations and profiler artifacts are local ignored evidence and are not included in a fresh clone.']
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.write_text('\n'.join(text)+'\n')
print(a.output)
