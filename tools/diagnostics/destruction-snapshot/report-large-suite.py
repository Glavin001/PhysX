#!/usr/bin/env python3
"""Report every large-scene case, retaining failed qualification explicitly."""
import argparse,csv,json,subprocess,sys
from pathlib import Path
p=argparse.ArgumentParser(description=__doc__);p.add_argument('campaign',type=Path);p.add_argument('output',type=Path);p.add_argument('--run-prefix',default='file');a=p.parse_args()
root=Path(__file__).resolve().parents[3];profile=json.loads((root/'tools/profiles/destruction-snapshot-large.json').read_text())
a.output.mkdir(parents=True,exist_ok=True);rows=[];successful=[];measured=[]
for grid in profile['grids']:
    for state in profile['states']:
        name=f"city{grid*grid}-{state['id']}";run=a.campaign/f'{a.run_prefix}-{name}'
        prefix=a.campaign/f"capture-{grid}-{state['regime']}"/'native'/f"snapshot-{state['step']}"
        meta=json.loads(prefix.with_suffix('.metadata.json').read_text())
        row=dict(scenario=name,purpose=state['purpose'],metadata=meta,raw=str(run),status='not_run')
        with (prefix.parent/'native.frames.csv').open() as stream:
            source=next(r for r in csv.DictReader(stream) if int(r['step'])==state['step'])
        row['uninterrupted_source_tick']={k:source[k] for k in ['step','bonds_broken','logical_clusters','stress_iterations','resim_passes','complete_step_ms']}
        row['source_comparison_scope']='Diagnostic context only: not the independent-restore gate and not matched warm/cold performance.'
        if (run/'receipt.json').exists():
            receipt=json.loads((run/'receipt.json').read_text());row['status']=receipt['status'];row['input_sha256']=receipt.get('snapshot_inputs',{})
            row['wall_seconds']=receipt.get('elapsed_monotonic_seconds',receipt['after']['unix_seconds']-receipt['before']['unix_seconds'])
            if row['status']=='complete':successful.append(run)
            else:row['failure_log']=(run/'stdout.log').read_text()[-4000:]
            try:
                data=json.loads((run/'replay.json').read_text())
                if len(data['samples'])==data['repetitions']:measured.append(run)
            except (OSError,ValueError,KeyError):pass
        rows.append(row)
if measured:
    subprocess.run([sys.executable,str(Path(__file__).with_name('report-file-replay.py')),str(a.output/'timings'),'--include-failed',*[str(x) for x in measured]],check=True)
    timings={x['scenario']:x for x in json.loads((a.output/'timings.json').read_text())['scenarios']}
else:timings={}
for row in rows:
    if row['scenario'] in timings:row['timings']=timings[row['scenario']]
result=dict(scenarios=rows,passed=len(successful),measured=len(measured),total=len(rows),summed_replay_harness_seconds=sum(r.get('wall_seconds',0) for r in rows))
result['summed_measured_tick_seconds']=sum(t['mean_ms']*t['samples'] for t in timings.values())/1000
result['summed_restore_seconds']=sum(t['restore_mean_ms']*t['samples'] for t in timings.values())/1000
result['other_harness_seconds']=result['summed_replay_harness_seconds']-result['summed_measured_tick_seconds']-result['summed_restore_seconds']
(a.output/'catalog.json').write_text(json.dumps(result,indent=2)+'\n')
lines=['# Large native scene snapshot campaign','','Each sample restores the same physical file and runs one complete tick, including current physics, stress, at most one correction, second stress and accepted publication. Source histories use the original native benchmark and unchanged ordinary A/B settings. Restore/setup and output validation are separate from tick time. No solver/contact caches are serialized. Shared GPU; these are descriptive fresh-restored timings, not gameplay speedups or matched candidate comparisons.','',f"**{len(measured)}/{len(rows)} scenarios produced all requested samples; {len(successful)}/{len(rows)} pass the strict repeatability gate.** Failed cases retain diagnostic timings. Source capture, correctness screens and sanitizers are excluded from the replay wall total ({result['summed_replay_harness_seconds']:.2f} s).",'', 'Repeatability is distinct from memory and physical-equivalence qualification. See [investigation and validation limits](investigation.md), including the large-case sanitizer failure on both the updated and saved pre-fix runtimes.','', '| Scenario | Chunks / bonds | Input clusters | Ticks measured | Output comparison | Mean / peak full tick ms |','|---|---:|---:|---:|---|---:|']
lines[4:4]=[f"Measured ticks total **{result['summed_measured_tick_seconds']:.2f} s**. Restoration totals {result['summed_restore_seconds']:.2f} s and is **excluded** from every full-step sample. Context/process setup, validation, teardown and harness overhead account for the remaining {result['other_harness_seconds']:.2f} s of summed replay harness time.", '']
lines[2:2]=['This is the **24-case city expansion**. The original structural cases remain in the [complete 52-scenario catalog](../snapshot-scenarios.md), with their different measurement protocol clearly labeled.', '']
for row in rows:
    m=row['metadata'];t=row.get('timings');value=f"{t['mean_ms']:.3f} / {t['max_ms']:.3f}" if t else '—'
    status='PASS' if row['status']=='complete' else ('FAIL: bond-health equality' if t and t['comparison_failure_reasons']==['bond health changed between equivalent states'] else row['status'])
    count=t['samples'] if t else '—'
    lines.append(f"| {row['scenario']} | {m['chunks']} / {m['bonds']} | {m['input_clusters']} | {count} | {status} | {value} |")
lines+=['','[Timing spread, restore costs, budget misses and active work](timings.md). Every source hash, raw path, failure log and sample statistics are in [catalog.json](catalog.json).','', 'The ten-second debris state is not assumed asleep or converged to rest. Fixed source-step names describe historical events; actual restored bond/correction counters describe the measured work. Continuous warm city trajectories remain necessary to evaluate normal gameplay cache reuse.','']
lines+=['## Restored versus uninterrupted source context','','These are separate execution histories. Restored and uninterrupted paths produce different fracture verdicts; the cause and physical significance are not yet qualified. Independent-restore success does not establish equivalence to uninterrupted gameplay. No exact-continuation requirement is reinstated here, and these differences are not hidden as speedups.','', '| Scenario | Source → restored new broken bonds | Source → restored output clusters |','|---|---|---|']
for row in rows:
    if 'timings' not in row:continue
    t=row['timings'];source=row['uninterrupted_source_tick']
    lines.append(f"| {row['scenario']} | {source['bonds_broken']} → {t['broken_bonds']} | {source['logical_clusters']} → {t['active_work']['output_clusters']} |")
lines+=['']
(a.output/'README.md').write_text('\n'.join(lines))
print(f"{len(successful)}/{len(rows)} pass the repeatability gate; other qualifications are separate")
