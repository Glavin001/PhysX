#!/usr/bin/env python3
"""Validate and summarize exact local-inverse cache retention experiments."""
import csv,gzip,hashlib,importlib.util,json,shutil,statistics
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('peak',ROOT/'tools/scripts/destruction-peak-opportunities.py')
peak=importlib.util.module_from_spec(spec);spec.loader.exec_module(peak)
def load(p):
    raw=p.read_bytes();return json.loads(gzip.decompress(raw) if p.suffix=='.gz' else raw)
def require(ok,message):
    if not ok:raise ValueError(message)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
BATCHES=[('baseline','colored-sweep-baseline-control'),('candidate','local-inverse-validity-impacts-256'),('baseline','local-inverse-validity-baseline-control')]
fields=['bodies','awake_bodies','logical_clusters','contacts_frame','stress_active_nodes','stress_active_bonds','stress_islands','bonds_broken','resim_passes','stress_converged']
rows=[];phases={};hashes={};reference=None;config=None;iteration_changes=0
for arm,batch in BATCHES:
    rp=HERE.parent/batch/'report.json.gz';report=load(rp);manifest=report['manifest'];hashes[str(rp.relative_to(ROOT))]=sha(rp)
    require(manifest['status']=='complete' and manifest['seconds']==3,'Incomplete or different capture')
    if config is None:config=manifest['config']
    require(config==manifest['config'],'Changed workload configuration')
    for run in manifest['runs']:
        if run['mode'] not in ('plain','phases'):continue
        source=Path(run['command'][run['command'].index('--output')+1]);archive=HERE/'samples'/batch/run['name'];archive.mkdir(parents=True,exist_ok=True)
        for name in ['native.frames.csv.gz','native.summary.json','native.launches.csv.gz']:
            target=archive/name
            if not target.exists():shutil.copy2(source/name,target)
            require(sha(target)==run['files'][name],'Sample hash mismatch')
        summary=load(archive/'native.summary.json')
        require(tuple(summary[k] for k in ['buildings','chunks','bonds','projectiles','correction_limit','sleeping'])==(256,113664,229376,256,1,False),'Changed physical fixture')
        with gzip.open(archive/'native.frames.csv.gz','rt') as stream:frames=list(csv.DictReader(stream))
        require(len(frames)==180 and all(int(f['stress_converged']) and int(f['resim_passes'])<=1 for f in frames),'Incomplete physical solve')
        values=peak.complete(dict(summary=summary,frames=frames))
        if run['mode']=='phases':phases[arm]=peak.rank(dict(summary=summary,frames=frames,profile=report['phase_captures'][0]['profile']));continue
        if reference is None:reference=frames
        require(all(a[k]==b[k] for a,b in zip(reference,frames) for k in fields),'Physical counter history changed')
        iteration_changes+=sum(a['stress_iterations']!=b['stress_iterations'] for a,b in zip(reference,frames))
        index=max(range(len(values)),key=values.__getitem__)
        row=dict(arm=arm,batch=batch,repeat=run['trial']+1,mean_ms=statistics.mean(values),peak_ms=max(values),peak_step=index,misses_8ms=sum(v>8 for v in values),misses_60hz=sum(v>1000/60 for v in values),peak_work={k:int(frames[index][k]) for k in fields+['stress_iterations']})
        recorded=next(r for r in report['runs'] if r['repeat']==row['repeat'])['metrics'];require(abs(recorded['mean']-row['mean_ms'])<1e-8 and abs(recorded['max']-row['peak_ms'])<1e-8,'Sample/report disagreement');rows.append(row)
quality=load(HERE/'wall-quality.json');require(quality['frozen_identity_gate_passed'] and (quality['supported_chunks'],quality['detached_chunks'],quality['broken_bonds'],quality['corrections_per_step_max'])==(398,46,199,1),'Frozen quality failed')
aggregates={arm:dict(runs=sum(r['arm']==arm for r in rows),mean_ms=statistics.mean(r['mean_ms'] for r in rows if r['arm']==arm),median_peak_ms=statistics.median(r['peak_ms'] for r in rows if r['arm']==arm),worst_ms=max(r['peak_ms'] for r in rows if r['arm']==arm)) for arm in ['baseline','candidate']}
text=['# Preserve unchanged GPU local stress inverses','',
'Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 aerial projectiles. Each run measures every complete advance for 180 steps / 3 simulated seconds; timestep 1/60 second, correction limit one, sleeping disabled. Two earlier baseline runs, five candidate runs, then two baseline control runs. Ordered short screens are not randomized five-minute qualification or endurance.','',
'Timer includes commands, physics, destruction, correction, synchronization and runtime growth through committed completion. Initialization, rendering and report generation are excluded. Every measured step remains in the raw samples.','',
'| Version | Runs | Mean complete ms | Median run peak ms | Worst complete ms |','|---|---|---|---|---|']
for arm,a in aggregates.items():text.append(f"| {arm} | {a['runs']} | {a['mean_ms']:.3f} | {a['median_peak_ms']:.3f} | {a['worst_ms']:.3f} |")
text+=['','This change deletes unnecessary local inverse reconstruction after fractures. It does not implement affected-only connectivity/hierarchy rebuilding or settled-island skipping. Peak ranges overlap; this short comparison is not evidence of a large peak improvement or a passing deadline.','',
'| Version / batch | Repeat | Mean ms | Peak ms | Peak step | Misses >8 ms | Misses >16.67 ms |','|---|---|---|---|---|---|---|']
for r in rows:text.append(f"| {r['arm']} / {r['batch']} | {r['repeat']} | {r['mean_ms']:.3f} | {r['peak_ms']:.3f} | {r['peak_step']} | {r['misses_8ms']} | {r['misses_60hz']} |")
text+=['','## Peak workload','', '| Version / repeat | Bodies | Awake | Clusters | Contacts | Max stress iterations | Correction passes |','|---|---|---|---|---|---|---|']
for r in rows:
    w=r['peak_work'];text.append(f"| {r['arm']} / {r['batch']} / {r['repeat']} | {w['bodies']} | {w['awake_bodies']} | {w['logical_clusters']} | {w['contacts_frame']} | {w['stress_iterations']} | {w['resim_passes']} |")
text+=['','## Separate instrumented phase capture','',f"Baseline scoped peak: step {phases['baseline']['peak_step']}, {phases['baseline']['peak_complete_ms']:.3f} ms. Candidate: step {phases['candidate']['peak_step']}, {phases['candidate']['peak_complete_ms']:.3f} ms. CPU elapsed scopes include GPU waits; CUDA stages overlap and must not be added again.",'', '| Responsibility | CPU / GPU | Baseline ms | Candidate ms |','|---|---|---|---|']
owners={'stress':'CPU submit/wait; GPU stress','ownership':'CPU lifecycle + GPU ownership','correction':'CPU scheduling + GPU restore/collision/solve','commit':'CPU completion + GPU publication','checkpoint':'CPU submission + GPU copy','trial':'PhysX CPU tasks + GPU physics','commands':'CPU submission + GPU execution','completion':'CPU final boundary'}
for key,owner in owners.items():
    a=next(x for x in phases['baseline']['rows'] if x['key']==key);b=next(x for x in phases['candidate']['rows'] if x['key']==key);text.append(f"| {a['label']} | {owner} | {a['peak_ms']:.3f} | {b['peak_ms']:.3f} |")
text+=['','| Overlapping GPU stage | Baseline ms | Candidate ms |','|---|---|---|']
for k,v in phases['baseline']['peak_cuda_stages'].items():text.append(f"| {k} | {v:.3f} | {phases['candidate']['peak_cuda_stages'][k]:.3f} |")
text+=['','## What changed and why it is valid','',
'- Local inverse coefficients depend only on live incident bonds and immutable coupling/inertia/offset data. Loads, connectivity labels and rigid-mode projection do not enter those local coefficients.',
'- Inside the validated GPU topology transaction, each cached node checks its incident removal mask. Changed, unknown and stale entries lose validity. Unchanged entries carry their generation certificate forward without touching the packed inverse.',
'- One additional GPU validation pass on topology changes; no extra allocation, CPU observation or host decision. Unchanged topology remains guarded out. The reference solver is unchanged.',
'- Bond insertion/resurrection is rejected by the existing resident topology API. Future mutable coefficients must invalidate this cache explicitly; this implementation does not claim support for silent coefficient mutation.',
'- The CPU actor/contact/query lifecycle bridge remains. This optimization removes GPU rebuild work; it does not represent completion of the CPU-to-GPU ownership migration.','',
'## Validation and remaining gates','',
'- Native analytic, 3D and motion suites pass existing tolerances. Focused cache lifetime fixture: 6 nodes / 5 bonds, shared support; six cold/unknown/stale/internal-cut/support-cut/repeated-removal cases.',
'- Motion/cache and full native analytic initcheck report zero errors. Existing inverse basis and public removal/doubled-load/zero-load tests still pass.',
'- Frozen penetration: 444 chunks / 896 bonds, one projectile, ten simulated seconds; exact controlled topology signature, both-wall clearance, 398 retained chunks, 46 detached, 199 broken bonds, correction maximum one.',
f'- All {len(rows)} untraced runs match the recorded body/contact/fracture/convergence histories. Stress iteration histories have {iteration_changes} differing step comparisons. Counter agreement alone is not bit-identical chaotic trajectory proof.',
'- No scene passes the required 8 ms peak campaign here; these screens are not five 60-second runs or the 10-minute lifecycle endurance gate.','',
'## Reproduce','',
'Run `python3 qualification/local-inverse-validity/generate_report.py`. Archived raw samples are checked against capture manifests, physical configuration, complete-step accounting and frozen quality. The script regenerates Markdown, HTML and JSON without manual timing tables.']
md='\n'.join(text)+'\n';(HERE/'report.md').write_text(md);(HERE/'report.html').write_text(peak.render_html(md));(HERE/'report.json').write_text(json.dumps(dict(schema=1,rows=rows,aggregates=aggregates,phase_peaks=phases,input_report_hashes=hashes,quality=quality,physical_counter_differences=0,iteration_step_comparisons_changed=iteration_changes),indent=2,sort_keys=True)+'\n');print(HERE/'report.html')
