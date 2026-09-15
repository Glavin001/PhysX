#!/usr/bin/env python3
"""Summarize independent, single-tick physical file replays without speedup claims."""
import argparse
import json
import statistics
import random
import re
from pathlib import Path

p=argparse.ArgumentParser(description=__doc__)
p.add_argument('output',type=Path)
p.add_argument('runs',type=Path,nargs='+')
p.add_argument('--include-failed',action='store_true',help='Report complete sampled runs that failed repeatability, marked unqualified')
a=p.parse_args();rows=[]
for run in a.runs:
    receipt=json.loads((run/'receipt.json').read_text());d=json.loads((run/'replay.json').read_text())
    if receipt.get('sanitizer') or receipt.get('profiler') or 'compute-sanitizer' in receipt['command'][0]:
        raise SystemExit(f'Instrumented timings cannot enter the unprofiled performance report: {run}')
    if d['steps_per_restore']!=1 or (not a.include_failed and (receipt['status']!='complete' or not d['passed'])):
        raise SystemExit(f'Unqualified replay: {run}')
    s=d['samples'];t=[x['complete_step_ms'] for x in s];r=[x['restore_ms'] for x in s]
    meta_files=[Path(x) for x in receipt['snapshot_inputs'] if x.endswith('.metadata.json')]
    metadata=json.loads(meta_files[0].read_text()) if meta_files else {}
    log=(run/'stdout.log').read_text()
    health_differences=[float(x) for x in re.findall(r'health differences=\d+ max=([\d.eE+-]+)',log)]
    comparison_failures=re.findall(r'repeat \d+ comparison failed: ([^\n]+)',log)
    rng=random.Random(20260911);bootstrap=sorted(statistics.mean(rng.choices(t,k=len(t))) for _ in range(5000))
    rows.append(dict(qualified=d['passed'] and receipt['status']=='complete',repeatability_passed=d['passed'],receipt_status=receipt['status'],replay_contract=d['contract'],metadata=metadata,sd_ms=statistics.stdev(t),cv_percent=100*statistics.stdev(t)/statistics.mean(t),
        comparison_failure_reasons=sorted(set(comparison_failures)),failed_comparisons=len(comparison_failures),maximum_observed_bond_health_difference=max(health_differences,default=0),
        descriptive_bootstrap_mean_95_ms=[bootstrap[125],bootstrap[4874]],
        first_half_mean_ms=statistics.mean(t[:len(t)//2]),last_half_mean_ms=statistics.mean(t[len(t)//2:]),
        harness_wall_seconds=receipt.get('elapsed_monotonic_seconds',receipt['after']['unix_seconds']-receipt['before']['unix_seconds']),harness_clock='monotonic' if 'elapsed_monotonic_seconds' in receipt else 'UTC provenance span',
        mean_stages_ms={key:statistics.mean(x[key] for x in s) for key in ['command_ms','simulate_fetch_ms','completion_ms'] if all(key in x for x in s)},
        active_work={key:sorted({x[key] for x in s if key in x}) for key in ['output_clusters','stress_islands','stress_active_nodes','stress_active_bonds','normal_contacts','friction_anchors']},
        scenario=run.name.removeprefix('file-').removeprefix('single-').removeprefix('complete-'),samples=len(s),mean_ms=statistics.mean(t),median_ms=statistics.median(t),min_ms=min(t),max_ms=max(t),
        restore_mean_ms=statistics.mean(r),restore_max_ms=max(r),
        over_8_ms=sum(x>8 for x in t),over_120hz=sum(x>1000/120 for x in t),over_60hz=sum(x>1000/60 for x in t),
        corrections=sorted({x['correction_passes'] for x in s}),stress_evaluations=sorted({x['stress_passes'] for x in s}),
        stress_iterations=sorted({x['stress_iterations'] for x in s}),broken_bonds=sorted({x['broken_bonds'] for x in s}),
        motion_comparisons_unavailable=sum(not x.get('motion_comparison_measured',True) for x in s),max_position_error_m=max(x['position_error_m'] for x in s),max_linear_error_m_s=max(x['linear_error_m_s'] for x in s),max_angular_error_rad_s=max(x['angular_error_rad_s'] for x in s),
        input_sha256=receipt['snapshot_inputs'],raw=str(run/'replay.json')))
result={'quality_contract':{'position_m':1e-4,'linear_velocity_m_s':1e-4,'angular_velocity_rad_s':1e-4,'orientation_dot_error':1e-5,'bond_health':'exact','accepted_topology':'exact','crush_damage':'exact','stress_converged':True,'maximum_corrections':1},'scope':'One full tick per fresh restore, fixed file inputs, ordinary GPU/TGS, dt=1/60, at most one correction. Independent physical reconstructions; shared-GPU descriptive timings, not matched A/B performance qualification. Restore includes scene creation and stress configuration; context initialization and validation are outside both reported intervals. No capture-prefix simulation.', 'scenarios':rows}
a.output.parent.mkdir(parents=True,exist_ok=True);a.output.with_suffix('.json').write_text(json.dumps(result,indent=2)+'\n')
lines=['# Independent one-tick file replay','',result['scope'],'',
       '| Saved scenario | Repeatability gate | n | Full tick mean / max ms | Median ms | Restore mean ms | >8 / >120Hz / >60Hz | Correction / stress evaluations |',
       '|---|---|---:|---:|---:|---:|---|---|']
for r in rows:
    misses=' / '.join(f"{r[k]} ({100*r[k]/r['samples']:.0f}%)" for k in ['over_8_ms','over_120hz','over_60hz'])
    status='PASS' if r['qualified'] else ('FAIL: bond-health equality' if r['comparison_failure_reasons']==['bond health changed between equivalent states'] else 'FAIL: validation')
    lines.append(f"| {r['scenario']} | {status} | {r['samples']} | {r['mean_ms']:.3f} / {r['max_ms']:.3f} | {r['median_ms']:.3f} | {r['restore_mean_ms']:.3f} | {misses} | {r['corrections']} / {r['stress_evaluations']} |")
lines+=['','Repeatability qualification is explicit in each row. Failed comparisons remain failures; their timings are diagnostic only. The adjacent JSON reports measured motion differences and fracture/correction counts for every scenario. Scene scale and source-step metadata, when available, are listed below. Fresh restore rebuilds caches, so these timings do not replace warm continuous city trajectories.','',
        'The input hashes, iteration counts, ranges and raw sample locations are in the adjacent JSON. Repeat counts describe observed variability; they do not establish a candidate speedup or guarantee statistical significance. Retain continuous warm trajectories and matched A/B controls for optimization decisions.','']
lines+=['## Complete-step phases','','The integrated simulate/fetch interval includes rigid physics, stress, transfers, correction and accepted publication. The completion interval includes the native benchmark’s two compact GPU status transfers and readiness synchronization. Large output validation is outside all three intervals.','', '| Scenario | Command mean ms | Integrated simulate/fetch mean ms | Completion mean ms |','|---|---:|---:|---:|']
for r in rows:
    m=r['mean_stages_ms']
    if m:lines.append(f"| {r['scenario']} | {m['command_ms']:.6f} | {m['simulate_fetch_ms']:.3f} | {m['completion_ms']:.3f} |")
lines+=['','## Scale and timing spread','','| Scenario | Chunks / bonds | Input → output clusters | New broken bonds | Standard deviation ms | Mean 95% resampling interval ms | Harness seconds |','|---|---:|---|---|---:|---|---:|']
for r in rows:
    m=r['metadata'];ci=r['descriptive_bootstrap_mean_95_ms']
    lines.append(f"| {r['scenario']} | {m.get('chunks','?')} / {m.get('bonds','?')} | {m.get('input_clusters','?')} → {r['active_work']['output_clusters']} | {r['broken_bonds']} | {r['sd_ms']:.3f} | {ci[0]:.3f}–{ci[1]:.3f} | {r['harness_wall_seconds']:.2f} |")
lines+=['','Intervals describe variation in these samples, assuming exchangeable observations; they do not bound systematic shared-GPU interference. JSON includes first-half versus last-half means to expose drift. All samples, including first restored ticks, are retained.','']
a.output.with_suffix('.md').write_text('\n'.join(lines));print(f'{len(rows)} file scenarios reported')
