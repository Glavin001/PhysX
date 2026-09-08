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
    return dict(report=report,steps=rows,peak=peak,fracture_peak=max(fractured,key=lambda r:r['complete_step_ms']),
        command_sha256=hashlib.sha256((path/'commands.json').read_bytes()).hexdigest())


def generate(baseline,candidates,output,title='Embedded consumer comparison',notes=None):
    baselines=[baseline] if isinstance(baseline,Path) else baseline
    baseline_runs=[load(p) for p in baselines]
    base=baseline_runs[0];runs=baseline_runs+[load(p) for p in candidates]
    labels=[f'baseline-{i+1}' for i in range(len(baselines))]+[f'candidate-{i+1}' for i in range(len(candidates))]
    fixed=['buildings','chunks','bonds','steps','seconds','waves','projectiles','direct_gpu_api',
           'sleeping','max_correction','max_stress_passes','timestep_seconds','iterations_max','tolerance','timing_scope']
    for other in runs[1:]:
        assert base['command_sha256']==other['command_sha256'],'recorded commands changed'
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
            f"{f['complete_step_ms']:.3f} ({f['tick']}) | {r['unique_broken_bonds']:,} | {run['steps'][-1]['fragment_bodies']:,} | "
            f"{sum(row['native_corrections'] for row in run['steps'])} |")
        (output/(label+'.json.gz')).write_bytes(gzip.compress(json.dumps(run,separators=(',',':')).encode(),mtime=0))
    worst_base=max(r['peak']['complete_step_ms'] for r in baseline_runs)
    fracture_base=max(r['fracture_peak']['complete_step_ms'] for r in baseline_runs)
    candidate_runs=runs[len(baselines):]
    worst=max(r['peak']['complete_step_ms'] for r in candidate_runs)
    worst_fracture=max(r['fracture_peak']['complete_step_ms'] for r in candidate_runs)
    text+=['',f"Comparing the **worst run in each arm**, observed complete-peak reduction is **{100*(1-worst/worst_base):.1f}%**; "
        f"fracture-step peak reduction is **{100*(1-worst_fracture/fracture_base):.1f}%**. "
        'Negative reduction means slower. These short screens do not establish a guaranteed saving or a 60 Hz pass.', '',
        '## Physical-work checks and limits', '',
        '- Reported physical settings and exact command tapes match. Complete phase sums and correction/stress-pass counts validate.',
        '- Final fracture/body counts are shown, not hidden. Counts alone do not prove equal physical quality; '
        'these short runs are not a complete parity/endurance oracle.',
        '- This report does not infer numerical-test, penetration or browser-test success from timing captures.', '']
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
