#!/usr/bin/env python3
"""Reproduce the polynomial candidate report from hashed, archived scene samples."""
from pathlib import Path
import csv,gzip,hashlib,importlib.util,json,shutil,statistics
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('peak',ROOT/'tools/scripts/destruction-peak-opportunities.py')
peak=importlib.util.module_from_spec(spec);spec.loader.exec_module(peak)
BATCHES=[('baseline','adjacency-before-impacts-256'),('baseline','adjacency-baseline-repeat'),('candidate','polynomial2-impacts-256'),('candidate','polynomial2-repeat-impacts-256'),('baseline','polynomial2-baseline-control')]
FIELDS=['bodies','awake_bodies','logical_clusters','contacts_frame','stress_active_nodes','stress_active_bonds','stress_islands','bonds_broken','resim_passes','stress_converged']
def require(ok,message):
    if not ok:raise ValueError(message)
def load(p):
    raw=p.read_bytes();return json.loads(gzip.decompress(raw) if p.suffix=='.gz' else raw)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
reports={};rows=[];baseline=None;differences=[];iteration_changes=0;hashes={};phase_runs={}
for arm,batch in BATCHES:
    path=HERE.parent/batch/'report.json.gz';report=load(path);reports[batch]=report;hashes[str(path.relative_to(ROOT))]=sha(path)
    manifest=report['manifest'];require(manifest['status']=='complete','Incomplete campaign')
    if baseline is None:config=manifest['config']
    require(manifest['config']==config and manifest['seconds']==3,'Changed workload inputs')
    for entry in manifest['runs']:
        if entry['mode'] not in ('plain','phases'):continue
        original=Path(entry['command'][entry['command'].index('--output')+1]);archive=HERE/'validation/samples'/batch/entry['name'];archive.mkdir(parents=True,exist_ok=True)
        for name in ['native.frames.csv.gz','native.summary.json','native.launches.csv.gz']:
            target=archive/name
            if not target.exists():shutil.copy2(original/name,target)
            require(sha(target)==entry['files'][name],'Sample hash mismatch: '+str(target))
        summary=load(archive/'native.summary.json')
        require((summary['buildings'],summary['chunks'],summary['bonds'],summary['projectiles'],summary['correction_limit'],summary['sleeping'])==(256,113664,229376,256,1,False),'Workload changed')
        with gzip.open(archive/'native.frames.csv.gz','rt') as f:frames=list(csv.DictReader(f))
        require(len(frames)==180 and all(int(f['stress_converged']) and int(f['resim_passes'])<=1 for f in frames),'Invalid/incomplete step')
        values=peak.complete(dict(summary=summary,frames=frames));require(len(values)==180,'Wrong duration')
        if entry['mode']=='phases':
            if batch in ['polynomial2-impacts-256','polynomial2-baseline-control']:
                profile=report['phase_captures'][0]['profile'];phase_runs[arm]=dict(summary=summary,frames=frames,profile=profile)
            continue
        metric=next(r for r in report['runs'] if r['repeat']==entry['trial']+1)
        require(abs(max(values)-metric['metrics']['max'])<1e-8,'Peak does not match samples')
        require(abs(statistics.mean(values)-metric['metrics']['mean'])<1e-8,'Mean does not match samples')
        item=dict(arm=arm,batch=batch,repeat=entry['trial']+1,mean_ms=statistics.mean(values),peak_ms=max(values),peak_step=values.index(max(values)),missed_8ms=sum(v>8 for v in values),missed_60hz=sum(v>1000/60 for v in values))
        rows.append(item)
        if baseline is None:baseline=frames
        for step,(a,b) in enumerate(zip(baseline,frames)):
            for field in FIELDS:
                if a[field]!=b[field]:differences.append(dict(batch=batch,repeat=item['repeat'],step=step,field=field,before=a[field],after=b[field]))
            iteration_changes+=a['stress_iterations']!=b['stress_iterations']
require(not differences,'Physical counters changed; inspect before using this as a matched-work comparison')
quality=load(HERE/'validation/final-wall-quality.json')
require(quality['frozen_identity_gate_passed'] and quality['largest_connected_cluster']==398 and quality['detached_chunks']==46 and quality['broken_bonds']==199,'Frozen wall quality failed')
ranked={arm:peak.rank(run) for arm,run in phase_runs.items()}
summary={arm:dict(runs=len(selected),mean_complete_ms=statistics.mean(r['mean_ms'] for r in selected),worst_complete_ms=max(r['peak_ms'] for r in selected),median_run_peak_ms=statistics.median(r['peak_ms'] for r in selected)) for arm in ['baseline','candidate'] if (selected:=[r for r in rows if r['arm']==arm])}
text=['# Resident polynomial preconditioner — short-run qualification','',
'The two-stage candidate is retained for lower repeated stress cost, with unchanged physical acceptance and matched scene counters. The absolute worst complete-step result is nearly unchanged, and the full 8 ms / 60 Hz objective is not met. Every measured candidate peak, including the earlier 64.135 ms result, remains below.','',
'## Workload and protocol','',
'256 buildings, 113,664 chunks, 229,376 bonds and 256 simultaneous aerial projectiles. Each run advances 180 steps / 3 simulated seconds, dt=1/60 s, maximum one correction, sleeping disabled. Chunks share cluster motion; they are not 113,664 independently simulated rigid bodies. At step 103 the recorded body/awake counts are 12,072 / 12,072, including 256 projectiles; the logical cluster count is 11,816. These body counters come from the scene scheduler, not a separately qualified GPU sleep mask.','',
'Timing includes commands, insertion, simulation, destruction, correction, capacity growth and mandatory completion. Initialization, rendering, encoding and report generation are excluded. Each campaign has warm-up; every measured step is retained. Separate phase captures are instrumented and are not substituted for untraced deadline timing.', '',
'The baseline consists of two earlier runs, five recent baseline repeats and five reverse-order control repeats. The candidate has its initial two runs and five follow-up repeats. The reverse control checks batch drift; runs are not randomized individual-run interleaving. The unequal sample counts and short duration do not establish a statistical worst-case bound. These are not the planned five 60-second acceptance runs or the 10-minute endurance test.', '',
'## All complete-step results','',
'| Arm / batch | Repeat | Mean ms | Peak ms | Peak step | Steps >8 ms | Steps >16.67 ms |','|---|---|---|---|---|---|---|']
for r in rows:text.append(f"| {r['arm']} / {r['batch']} | {r['repeat']} | {r['mean_ms']:.3f} | {r['peak_ms']:.3f} | {r['peak_step']} | {r['missed_8ms']} | {r['missed_60hz']} |")
text+=['','| All retained samples | Runs | Mean complete ms | Median run peak ms | Absolute worst complete ms |','|---|---|---|---|---|']
for arm,s in summary.items():text.append(f"| {arm} | {s['runs']} | {s['mean_complete_ms']:.3f} | {s['median_run_peak_ms']:.3f} | {s['worst_complete_ms']:.3f} |")
text+=['','Median run peak describes repeatability; it never replaces the absolute maximum for deadline acceptance. Neither arm passes 8 ms or 16.67 ms on every step.','',
'## Separate phase breakdown','',
'These rows compare each version’s instrumented peak. CPU elapsed scopes below partition the step; GPU stages in the next table overlap those scopes and must not be added to them. The baseline phase capture is the reverse control; the candidate capture accompanies its initial two timing runs.','',
'| Responsibility | Owner | Baseline scoped peak ms | Candidate scoped peak ms |','|---|---|---|---|']
byarm={arm:{r['key']:r for r in ranked[arm]['rows']} for arm in ranked}
owners={'stress':'CPU submit/wait enclosing GPU destruction','ownership':'CPU lifecycle/registration plus GPU slot and binding work','correction':'CPU scheduling plus GPU restore, collision and solve','commit':'CPU completion plus GPU accepted-state publication','trial':'PhysX CPU task scheduling plus GPU trial physics','checkpoint':'CPU submission, GPU motion copy','commands':'CPU submission plus GPU command application','completion':'CPU completion boundary and GPU status observation'}
for key in ['stress','ownership','correction','commit','trial','checkpoint','commands','completion']:
    label,_=peak.GROUPS[key];owner=owners[key];text.append(f"| {label} | {owner} | {byarm['baseline'][key]['peak_ms']:.3f} | {byarm['candidate'][key]['peak_ms']:.3f} |")
labels={'stress':'GPU: stress preparation and solve','contactLoads':'GPU: solved contacts to chunk loads','materials':'GPU: material and damage verdicts','topologyAndCandidates':'GPU: connectivity and fracture candidates','commitAndStressTopology':'GPU: commit health and update stress topology'}
text+=['','| GPU stream stage | Baseline mean ms | Candidate mean ms | Baseline scoped peak ms | Candidate scoped peak ms |','|---|---|---|---|---|']
for key,label in labels.items():
    a=phase_runs['baseline']['profile']['cuda_stages'];b=phase_runs['candidate']['profile']['cuda_stages'];ia=ranked['baseline']['peak_step'];ib=ranked['candidate']['peak_step']
    text.append(f"| {label} | {statistics.mean(x[key] for x in a):.3f} | {statistics.mean(x[key] for x in b):.3f} | {a[ia][key]:.3f} | {b[ib][key]:.3f} |")
text+=['','## Numerical work and fidelity','',
'At the same bombardment step 103, the reported maximum stress iteration count decreases from 537 to 280. A separate intact gravity-only fixture (256 buildings, the same chunk/bond counts; no projectile, physics response or correction) decreases from 86 to 45 iterations per building. These counts alone are not performance: each preconditioned update adds one cross-endpoint sparse traversal and a second cached local-inverse application. Existing outer-operator visit counters exclude those preconditioner operations. Complete timing includes them.', '',
'- Independent long-double polynomial oracle: 12 nodes / 20 bonds, both supported and free; all basis vectors, symmetry and positive definiteness pass. Existing full native analytical and 3D force/residual tests pass their unchanged thresholds.',
'- Candidate CUDA memory and synchronization checks pass. The expanded initialization audit exposed a separate reference first-iteration history read; commit 8c9a7146 fixes that read. The full initialization audit then passes with zero errors. Baseline reverse control and candidate both include that fix; it does not execute in the native projected component path.',
'- Final frozen penetration audit: 444 chunks, 896 bonds, one projectile, 10 simulated seconds. Same topology identity, both-wall clearance, 398 supported chunks, 46 detached chunks, 199 broken bonds, convergence and maximum one correction pass.',
f'- All {len(rows)} untraced runs match the listed body/contact/fracture/convergence counters. Iteration counts differ in {iteration_changes} step comparisons as expected. Counts are not proof of identical chaotic trajectories; the independent controlled audit is separate evidence.',
'- Four-stage polynomial and unfused two-stage probes are retained as intermediate diagnostics. Only the fused two-stage expression is active; no tuning switch or extra production backend is introduced.', '',
'## What remains','',
'The reduction is useful but insufficient for massive real-time destruction. Stress still exceeds the desired total deadline during impacts, while correction orchestration and the ownership bridge remain major independent peak costs. The next changes must reduce those costs without dropping physical work, relaxing acceptance or hiding measured spikes. See ALGORITHM.md for the exact resident data flow and numerical identity.', '',
'## Reproduce','',
'Run python3 qualification/polynomial-preconditioner/generate_report.py. It verifies archived raw samples against campaign hashes, checks complete-timer accounting and physical counters, and regenerates Markdown, HTML and JSON. The input timing reports contain commands, hardware sampling and binary hashes. All durations, peaks and exclusions remain explicit.','']
body='\n'.join(text)
(HERE/'report.md').write_text(body);(HERE/'report.html').write_text(peak.render_html(body).replace('<title>Destruction peak opportunities</title>','<title>Resident polynomial preconditioner</title>'))
(HERE/'report.json').write_text(json.dumps(dict(status='selected short-run candidate; full deadline/endurance qualification incomplete',runs=rows,summary=summary,phase_peaks=ranked,physical_counter_differences=differences,iteration_comparisons_differing=iteration_changes,quality=quality,report_hashes=hashes),indent=2,sort_keys=True)+'\n')
print(HERE/'report.html')
