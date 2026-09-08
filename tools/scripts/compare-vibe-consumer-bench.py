#!/usr/bin/env python3
"""Compare complete untraced consumer runs, preserving physical work and every peak."""
import argparse,gzip,hashlib,json,math
from pathlib import Path


def load(path):
    report=json.loads((path/'report.json').read_text()); rows=json.loads((path/'steps.json').read_text())
    assert report['status']=='complete' and not report.get('instrumented',False)
    assert len(rows)==report['steps'] and [r['tick'] for r in rows]==list(range(len(rows)))
    for r in rows:
        assert all(math.isfinite(r[k]) and r[k]>=0 for k in ['commands_and_pre_step_ms','native_physics_and_destruction_ms',
            'game_observation_events_ms','accepted_status_and_snapshots_ms','complete_step_ms'])
        parts=sum(r[k] for k in ['commands_and_pre_step_ms','native_physics_and_destruction_ms',
                                'game_observation_events_ms','accepted_status_and_snapshots_ms'])
        assert math.isclose(parts,r['complete_step_ms'],abs_tol=1e-8)
        assert r['native_corrections']<=1
        assert r['native_counts']['native_stress_passes']==1+r['native_corrections']
    fractured=[r for i,r in enumerate(rows) if r['broken_bonds']>(rows[i-1]['broken_bonds'] if i else 0)]
    peak=max(rows,key=lambda r:r['complete_step_ms']); assert peak==report['peak_step']
    commands=json.loads((path/'commands.json').read_text())
    intact_idle=not commands and report['projectiles']==0 and report['waves']==0 and all(
        r['broken_bonds']==0 and r['fragment_bodies']==0 for r in rows)
    first_command=min((c['tick'] for c in commands),default=None)
    loaded=[] if first_command is None else [r for r in rows if r['tick']>=first_command]
    return dict(report=report,steps=rows,peak=peak,
        fracture_peak=max(fractured,key=lambda r:r['complete_step_ms'],default=None),
        loaded_peak=max(loaded,key=lambda r:r['complete_step_ms'],default=None),
        intact_idle=intact_idle,
        command_sha256=hashlib.sha256((path/'commands.json').read_bytes()).hexdigest())


def peak_text(row):
    return 'not measured' if row is None else f"{row['complete_step_ms']:.3f} ({row['tick']})"


def distribution(rows):
    values=sorted(r['complete_step_ms'] for r in rows)
    quantile=lambda q:values[max(0,math.ceil(q*len(values))-1)]
    return [values[0],sum(values)/len(values),quantile(.5),quantile(.95),quantile(.99),values[-1]]


def generate(baseline,candidates,output,title='Embedded consumer comparison',notes=None):
    baselines=[baseline] if isinstance(baseline,Path) else baseline
    baseline_runs=[load(p) for p in baselines]
    base=baseline_runs[0];runs=baseline_runs+[load(p) for p in candidates]
    labels=[f'baseline-{i+1}' for i in range(len(baselines))]+[f'candidate-{i+1}' for i in range(len(candidates))]
    fixed=['buildings','chunks','bonds','steps','seconds','waves','projectiles','direct_gpu_api',
           'sleeping','max_correction','max_stress_passes','timestep_seconds','iterations_max','tolerance','timing_scope']
    for other in runs[1:]:
        assert base['command_sha256']==other['command_sha256'],'recorded commands changed'
        assert all(base['report'].get(k)==other['report'].get(k) for k in ['source_asset','manifest_hash']),'scene identity changed'
        assert all(base['report'][k]==other['report'][k] for k in fixed),'physical/measurement configuration changed'
    output.mkdir(parents=True,exist_ok=False)
    source=base['report']
    text=['# '+title, '',
        f"**{source['buildings']} buildings, {source['chunks']:,} chunks, {source['bonds']:,} bonds, "
        f"{source['projectiles']} physical projectiles over {source['steps']} steps / {source['seconds']:g} simulated seconds per run.** "
        'Direct GPU API off, sleep on, correction ≤1, at most two stress evaluations. '
        f'Identical recorded commands and reported physical settings. {len(baselines)} baseline and {len(candidates)} candidate runs; '
        'short isolated screens, not endurance or a historical external-backend comparison.', '',
        'The complete timer includes projectile insertion, native physics/stress/topology/correction and '
        'accepted game events/snapshots. Every first-step and allocation spike remains. Rendering and networking are excluded.', '',
        '| Run | Mean ms | All-step peak ms (tick) | Fracture-step peak ms (tick) | Final broken bonds | Final fragment bodies | Corrected steps |',
        '|---|---:|---:|---:|---:|---:|---:|']
    for i,run in enumerate(runs):
        label=labels[i]
        r,p,f=run['report'],run['peak'],run['fracture_peak']
        text.append(f"| {label} | {r['phases_ms']['complete_step_ms']['mean']:.3f} | {p['complete_step_ms']:.3f} ({p['tick']}) | "
            f"{peak_text(f)} | {r['unique_broken_bonds']:,} | {run['steps'][-1]['fragment_bodies']:,} | "
            f"{sum(row['native_corrections'] for row in run['steps'])} |")
        (output/(label+'.json.gz')).write_bytes(gzip.compress(json.dumps(run,separators=(',',':')).encode(),mtime=0))
    worst_base=max(r['peak']['complete_step_ms'] for r in baseline_runs)
    fracture_base=max((r['fracture_peak']['complete_step_ms'] for r in baseline_runs if r['fracture_peak']),default=None)
    candidate_runs=runs[len(baselines):]
    worst=max(r['peak']['complete_step_ms'] for r in candidate_runs)
    worst_fracture=max((r['fracture_peak']['complete_step_ms'] for r in candidate_runs if r['fracture_peak']),default=None)
    fracture_change=('fracture-step peak reduction is not measured. ' if fracture_base is None or worst_fracture is None else
        f"fracture-step peak reduction is **{100*(1-worst_fracture/fracture_base):.1f}%**. ")
    text+=['',f"Comparing the **worst run in each arm**, observed complete-peak reduction is **{100*(1-worst/worst_base):.1f}%**; "+
        fracture_change+
        'Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.', '',
        '## Physical-work checks and limits', '',
        '- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.',
        '- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; '
        'these short runs are not a complete parity/endurance oracle.',
        '- This report does not infer numerical-test, penetration or browser-test success from timing captures.', '']
    text+=['## Required idle and destruction measurements', '',
        '| Run | Fresh intact idle | Idle min / mean / p50 / p95 / p99 / max ms | Impact + aftermath peak ms (tick) |',
        '|---|---|---|---:|']
    for label,run in zip(labels,runs):
        idle=' / '.join(f'{v:.3f}' for v in distribution(run['steps'])) if run['intact_idle'] else 'not measured'
        text.append(f"| {label} | {'yes' if run['intact_idle'] else 'no'} | {idle} | {peak_text(run['loaded_peak'])} |")
    text+=['', 'This table retains step zero. Fresh intact idle requires an empty command tape, zero projectiles, '
        'zero broken bonds and zero fragment bodies throughout. A short pre-impact window or sleeping debris after damage '
        'does not replace the fresh idle run. The impact/aftermath interval starts with the first recorded command and includes '
        'late rubble costs, even on steps without new fractures.', '',
        '**Paired performance qualification is incomplete in this single-regime comparison:** '
        'attach the matching intact-idle or destruction comparison for the same scene and settings. Both regimes are required.', '']
    if notes:
        text+=['## Experiment notes', '',notes.read_text().strip(), '']
    text+=[
        '## First counted-state divergence', '',
        'The following is a diagnostic of divergence, not a demand for bit-identical chaotic trajectories. '
        'It compares contact count, broken bonds, fragment count and awake fragment count at each tick.', '']
    keys=['normal_contacts','broken_bonds','fragment_bodies','awake_fragment_bodies']
    for i,run in enumerate(runs[1:],1):
        first=next((n for n,(a,b) in enumerate(zip(base['steps'],run['steps'])) if any(a[k]!=b[k] for k in keys)),None)
        text.append(f'- {labels[i]} versus baseline-1: first difference at tick {first}; command SHA-256 `{run["command_sha256"]}`.')
    text+=['','Raw accepted samples and summaries for every run are archived alongside this report. '
        'CUDA stage durations '
        'must not be added to overlapping CPU wait intervals.','']
    (output/'report.md').write_text('\n'.join(text));print(output/'report.md')

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--baseline',type=Path,nargs='+',required=True)
    p.add_argument('--candidates',type=Path,nargs='+',required=True);p.add_argument('--output',type=Path,required=True)
    p.add_argument('--title',default='Embedded consumer comparison');p.add_argument('--notes',type=Path)
    args=p.parse_args();generate(args.baseline,args.candidates,args.output,args.title,args.notes)
