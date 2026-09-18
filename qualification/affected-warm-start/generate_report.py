#!/usr/bin/env python3
"""Verify archived matched-work samples and generate the warm-start comparison."""
import csv,gzip,hashlib,importlib.util,json,shutil,statistics
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('peak',ROOT/'tools/scripts/destruction-peak-opportunities.py')
peak=importlib.util.module_from_spec(spec);spec.loader.exec_module(peak)
BATCHES=[('baseline','polynomial2-impacts-256'),('baseline','polynomial2-repeat-impacts-256'),
         ('candidate','affected-warm-impacts-256'),('candidate','affected-warm-repeat-256'),
         ('baseline','affected-warm-baseline-control')]
FIELDS=['bodies','awake_bodies','logical_clusters','contacts_frame','stress_active_nodes','stress_active_bonds','stress_islands','bonds_broken','resim_passes','stress_converged']
def load(p):
    raw=p.read_bytes();return json.loads(gzip.decompress(raw) if p.suffix=='.gz' else raw)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(ok,message):
    if not ok:raise ValueError(message)
rows=[];reference=None;config=None;hashes={};phases={};changes=0
for arm,batch in BATCHES:
    path=HERE.parent/batch/'report.json.gz';report=load(path);hashes[str(path.relative_to(ROOT))]=sha(path)
    manifest=report['manifest'];require(manifest['status']=='complete','Incomplete campaign')
    if config is None:config=manifest['config']
    require(config==manifest['config'] and manifest['seconds']==3,'Changed workload')
    for run in manifest['runs']:
        if run['mode'] not in ('plain','phases'):continue
        original=Path(run['command'][run['command'].index('--output')+1]);archive=HERE/'validation/samples'/batch/run['name'];archive.mkdir(parents=True,exist_ok=True)
        for name in ['native.frames.csv.gz','native.summary.json','native.launches.csv.gz']:
            target=archive/name
            if not target.exists():shutil.copy2(original/name,target)
            require(sha(target)==run['files'][name],'Raw sample hash changed')
        summary=load(archive/'native.summary.json')
        require(tuple(summary[k] for k in ['buildings','chunks','bonds','projectiles','correction_limit','sleeping'])==(256,113664,229376,256,1,False),'Changed fixture')
        with gzip.open(archive/'native.frames.csv.gz','rt') as f:frames=list(csv.DictReader(f))
        require(len(frames)==180 and all(int(f['stress_converged']) and int(f['resim_passes'])<=1 for f in frames),'Incomplete physical solve')
        values=peak.complete(dict(summary=summary,frames=frames))
        if run['mode']=='phases':
            if batch in ['affected-warm-impacts-256','affected-warm-baseline-control']:
                phases[arm]=peak.rank(dict(summary=summary,frames=frames,profile=report['phase_captures'][0]['profile']))
            continue
        if reference is None:reference=frames
        require(all(a[k]==b[k] for a,b in zip(reference,frames) for k in FIELDS),'Physical counter histories differ')
        changes+=sum(a['stress_iterations']!=b['stress_iterations'] for a,b in zip(reference,frames))
        row=dict(arm=arm,batch=batch,repeat=run['trial']+1,mean_ms=statistics.mean(values),peak_ms=max(values),peak_step=values.index(max(values)),misses_8ms=sum(v>8 for v in values),misses_60hz=sum(v>1000/60 for v in values))
        recorded=next(x for x in report['runs'] if x['repeat']==row['repeat'])['metrics']
        require(abs(row['peak_ms']-recorded['max'])<1e-8 and abs(row['mean_ms']-recorded['mean'])<1e-8,'Report/sample disagreement');rows.append(row)
quality=load(HERE/'validation/wall-quality.json')
require(quality['frozen_identity_gate_passed'] and (quality['largest_connected_cluster'],quality['detached_chunks'],quality['broken_bonds'],quality['corrections_per_step_max'])==(398,46,199,1),'Frozen wall failed')
aggregates={arm:dict(runs=len(v),mean_ms=statistics.mean(x['mean_ms'] for x in v),worst_ms=max(x['peak_ms'] for x in v),median_run_peak_ms=statistics.median(x['peak_ms'] for x in v)) for arm in ['baseline','candidate'] if (v:=[x for x in rows if x['arm']==arm])}
text=['# GPU affected-component warm starts','',
'🟡 Implemented and short-run tested. Full peak and endurance gates remain incomplete. Preserve the initial guess only for unchanged components; every solve still evaluates its current loads and true residual. Changed old components cold-start before relabeling, including internal cuts and removed support bonds.','',
'## Workload and timing','',
'256 buildings, 113,664 chunks, 229,376 bonds, 256 simultaneous aerial projectiles; 180 steps / 3 simulated seconds per run; timestep 1/60 second, correction limit one, sleeping disabled. At peak step 103: 12,072 recorded bodies/awake bodies, 11,816 destruction clusters and 109,383 contacts. Body/awake counters are scene scheduler observations, not an independently qualified device sleep mask.','',
'Complete timing includes commands, insertion, physics, stress/destruction, correction, capacity growth and mandatory completion. Initialization, rendering and report generation are excluded. Separate warm-up processes are excluded; every measured step remains. Earlier polynomial runs plus a reverse-order baseline control are compared with all candidate runs. These unequal-sized, short batches are not randomized trials, five 60-second acceptance runs, or 10-minute endurance.','',
'| Version | Runs | Mean complete ms | Median run peak ms | Worst complete ms |','|---|---|---|---|---|']
for arm,s in aggregates.items():text.append(f"| {arm} | {s['runs']} | {s['mean_ms']:.3f} | {s['median_run_peak_ms']:.3f} | {s['worst_ms']:.3f} |")
text+=['','The candidate lowers repeated mean cost, but does not establish a peak improvement: median run peaks are slightly worse, and observed absolute maxima are not a worst-case bound. Retain it for correct unaffected-component reuse, not as a demonstrated real-time peak fix. Neither version passes 8 ms or every-step 60 Hz.','',
'| Version / batch | Repeat | Mean ms | Peak ms | Peak step | Misses >8 ms | Misses >16.67 ms |','|---|---|---|---|---|---|---|']
for r in rows:text.append(f"| {r['arm']} / {r['batch']} | {r['repeat']} | {r['mean_ms']:.3f} | {r['peak_ms']:.3f} | {r['peak_step']} | {r['misses_8ms']} | {r['misses_60hz']} |")
text+=['','## Separate instrumented peak phases','',
'These CPU elapsed groups partition each instrumented step and include GPU waits. GPU stress timing below overlaps them; do not add it again. Controls include the same NVIDIA physics.','',
'| Responsibility | Owner | Baseline ms | Candidate ms |','|---|---|---|---|']
owners={'stress':'CPU submit/wait; GPU destruction','ownership':'CPU lifecycle plus GPU slots/ownership','correction':'CPU scheduling; GPU restore/collision/solve','commit':'CPU completion; GPU publication','checkpoint':'CPU submission; GPU copy','trial':'PhysX CPU tasks and GPU physics','commands':'CPU submission; GPU execution','completion':'CPU completion boundary'}
for key in owners:
    a=next(x for x in phases['baseline']['rows'] if x['key']==key);b=next(x for x in phases['candidate']['rows'] if x['key']==key)
    text.append(f"| {a['label']} | {owners[key]} | {a['peak_ms']:.3f} | {b['peak_ms']:.3f} |")
text+=['','GPU stages at those same scoped peaks:','', '| Stage | Baseline ms | Candidate ms |','|---|---|---|']
for key,value in phases['baseline']['peak_cuda_stages'].items():text.append(f"| GPU {key} | {value:.3f} | {phases['candidate']['peak_cuda_stages'][key]:.3f} |")
text+=['','## Correctness and limits','',
'- All compared untraced runs match body, contact, fracture and convergence histories. Iterations may differ; matching counters alone do not prove identical chaotic trajectories.',
'- Independent native analytic and 3D force tests pass unchanged tolerances. Two supported columns (64 nodes, 62 bonds) verify removal, doubled and zero loads: the untouched column needs zero iterations after fracture versus 30 initially, with a fresh residual check.',
'- Device storage checks cover 9 nodes / 7 bonds: cold initialization, unchanged topology, internal cut, support cut and a different affected component. No allocation or CPU transfer is added; existing root-flag scratch is reused before relabeling.',
'- Full native analytic initcheck and small motion/topology memcheck report zero errors; memcheck reports no leaks.',
'- Frozen wall: 444 chunks, 896 bonds, one projectile, 10 simulated seconds; same identity signature, both-wall clearance, 398 retained chunks, 46 detached, 199 broken bonds, correction limit one.',
'- Remaining global partition/hierarchy rebuild and inverse-cache invalidation are NOT solved by retaining bond initial guesses. General settled-component skipping is still absent. The peak is still dominated by real stress work and correction/ownership costs.',
'- Changes are limited to native topology transactions. The reference implementation retains global cold restarts. No physical tolerances, equations, materials, damage accounting or correction limits changed.','',
'## Reproduce','',
'Run `python3 qualification/affected-warm-start/generate_report.py`. Archived raw samples are verified against capture manifests; generated Markdown, HTML and JSON retain every measured peak. Campaign reports record commands, GPU observations and binary hashes.']
md='\n'.join(text)+'\n';(HERE/'report.md').write_text(md);(HERE/'report.html').write_text(peak.render_html(md))
(HERE/'report.json').write_text(json.dumps(dict(schema=1,rows=rows,aggregates=aggregates,phase_peaks=phases,input_report_hashes=hashes,physical_counter_differences=0,iteration_step_comparisons_changed=changes,frozen_quality=quality),indent=2,sort_keys=True)+'\n')
print(HERE/'report.html')
