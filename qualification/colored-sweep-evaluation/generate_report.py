#!/usr/bin/env python3
"""Reconstruct the matched bombardment comparison from hashed raw samples."""
import csv,gzip,hashlib,importlib.util,json,shutil,statistics
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('peak',ROOT/'tools/scripts/destruction-peak-opportunities.py')
peak=importlib.util.module_from_spec(spec);spec.loader.exec_module(peak)
def require(ok,message):
    if not ok:raise ValueError(message)
def load(p):
    raw=p.read_bytes();return json.loads(gzip.decompress(raw) if p.suffix=='.gz' else raw)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
rows=[];phases={};histories={};hashes={};config=None
fields=['bodies','awake_bodies','logical_clusters','contacts_frame','stress_active_nodes','stress_active_bonds','stress_islands','bonds_broken','resim_passes','stress_converged']
for arm,batch in [('candidate','colored-sweep-impacts-256'),('baseline','colored-sweep-baseline-control')]:
    report_path=HERE.parent/batch/'report.json.gz';report=load(report_path);manifest=report['manifest']
    require(manifest['status']=='complete','Incomplete capture');hashes[str(report_path.relative_to(ROOT))]=sha(report_path)
    if config is None:config=manifest['config']
    require(config==manifest['config'] and manifest['seconds']==3 and manifest['trials']==2,'Changed workload')
    for run in manifest['runs']:
        if run['mode'] not in ('plain','phases'):continue
        source=Path(run['command'][run['command'].index('--output')+1]);archive=HERE/'samples'/batch/run['name'];archive.mkdir(parents=True,exist_ok=True)
        for name in ['native.frames.csv.gz','native.summary.json','native.launches.csv.gz']:
            target=archive/name
            if not target.exists():shutil.copy2(source/name,target)
            require(sha(target)==run['files'][name],'Sample hash changed')
        summary=load(archive/'native.summary.json')
        require(tuple(summary[k] for k in ['buildings','chunks','bonds','projectiles','correction_limit','sleeping'])==(256,113664,229376,256,1,False),'Changed physical fixture')
        with gzip.open(archive/'native.frames.csv.gz','rt') as stream:frames=list(csv.DictReader(stream))
        require(len(frames)==180 and all(int(f['stress_converged']) and int(f['resim_passes'])<=1 for f in frames),'Incomplete physical solve')
        values=peak.complete(dict(summary=summary,frames=frames))
        if run['mode']=='phases':
            phases[arm]=peak.rank(dict(summary=summary,frames=frames,profile=report['phase_captures'][0]['profile']));continue
        index=max(range(len(values)),key=values.__getitem__);f=frames[index]
        row=dict(arm=arm,repeat=run['trial']+1,mean_ms=statistics.mean(values),peak_ms=max(values),peak_step=index,misses_8ms=sum(v>8 for v in values),misses_60hz=sum(v>1000/60 for v in values),peak_work={k:int(f[k]) for k in fields+['stress_iterations']})
        recorded=next(r for r in report['runs'] if r['repeat']==row['repeat'])['metrics']
        require(abs(recorded['max']-row['peak_ms'])<1e-8 and abs(recorded['mean']-row['mean_ms'])<1e-8,'Sample/report disagreement')
        rows.append(row);histories[(arm,row['repeat'])]=frames
reference=histories[('baseline',1)]
differences={f'{arm}-{repeat}':{k:sum(a[k]!=b[k] for a,b in zip(reference,frames)) for k in fields} for (arm,repeat),frames in histories.items()}
quality=load(HERE/'wall-quality.json')
require(quality['frozen_identity_gate_passed'] and (quality['supported_chunks'],quality['detached_chunks'],quality['broken_bonds'],quality['corrections_per_step_max'])==(398,46,199,1),'Frozen physical audit failed')
aggregates={arm:dict(mean_ms=statistics.mean(r['mean_ms'] for r in rows if r['arm']==arm),worst_ms=max(r['peak_ms'] for r in rows if r['arm']==arm)) for arm in ['baseline','candidate']}
probe=next(json.loads(line) for line in (HERE/'colored-sweep-probe-fixed.jsonl').read_text().splitlines() if '"stress_submission_and_completion_ms"' in line)
require((probe['buildings'],probe['chunks'],probe['bonds'],probe['solve'],probe['converged'])==(256,113664,229376,0,1),'Changed stress probe fixture')
text=['# Colored symmetric stress sweep — rejected from production','',
'Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 aerial projectiles; 180 steps / 3 simulated seconds per run, fixed 1/60 second timestep, correction limit one, sleeping disabled. Two complete untraced runs per version, plus separate phase captures. Candidate ran first, then the restored baseline; these are short ordered screens, not randomized long qualification or endurance.','',
'Timer: recorded command application through accepted simulation/destruction/event completion. Includes physics, stress, topology/lifecycle, correction and synchronization. Rendering, encoding and initialization excluded; all measured steps and spikes retained.','',
'| Version | Repeat | Mean complete ms | Peak complete ms | Peak step | Steps >8 ms | Steps >16.67 ms |','|---|---|---|---|---|---|---|']
for r in rows:text.append(f"| {r['arm']} | {r['repeat']} | {r['mean_ms']:.3f} | {r['peak_ms']:.3f} | {r['peak_step']} | {r['misses_8ms']} | {r['misses_60hz']} |")
text+=['','The candidate does not establish a performance win. Its implementation and added tests were archived as a patch and reverted; the previously qualified polynomial + unaffected warm-start runtime is restored. Neither implementation meets the peak deadline.','',
'## Work at each complete-step peak','', '| Version / repeat | Bodies | Awake bodies | Clusters | Contacts this step | Stress updates (maximum) | Corrections |','|---|---|---|---|---|---|---|']
for r in rows:
    w=r['peak_work'];text.append(f"| {r['arm']} / {r['repeat']} | {w['bodies']} | {w['awake_bodies']} | {w['logical_clusters']} | {w['contacts_frame']} | {w['stress_iterations']} | {w['resim_passes']} |")
text+=['','## Separate instrumented peak phases','',
f"CPU elapsed scopes below include GPU work/waits and partition each scoped peak: baseline step {phases['baseline']['peak_step']} ({phases['baseline']['peak_complete_ms']:.3f} ms), candidate step {phases['candidate']['peak_step']} ({phases['candidate']['peak_complete_ms']:.3f} ms). The CUDA durations below overlap these scopes and must not be added again.",'',
'| Responsibility | Owner | Baseline ms | Candidate ms |','|---|---|---|---|']
owners={'stress':'CPU submit/wait; GPU stress','ownership':'CPU lifecycle + GPU ownership','correction':'CPU scheduling + GPU restore/collision/solve','commit':'CPU completion + GPU publication','checkpoint':'CPU submission + GPU copy','trial':'PhysX CPU tasks + GPU physics','commands':'CPU submission + GPU execution','completion':'CPU final boundary'}
for key,owner in owners.items():
    a=next(x for x in phases['baseline']['rows'] if x['key']==key);b=next(x for x in phases['candidate']['rows'] if x['key']==key)
    text.append(f"| {a['label']} | {owner} | {a['peak_ms']:.3f} | {b['peak_ms']:.3f} |")
text+=['','| Overlapping GPU stage | Baseline ms | Candidate ms |','|---|---|---|']
for key,value in phases['baseline']['peak_cuda_stages'].items():text.append(f"| {key} | {value:.3f} | {phases['candidate']['peak_cuda_stages'][key]:.3f} |")
text+=['','## Quality and interpretation','',
'- Independent 12-node / 30-bond anchored and free fixtures assemble the physical matrix in long double and check all basis responses, symmetry and positive definiteness. Coloring is checked against independent sequential first-fit, including odd cycles and reuse after edge removal. Existing tolerances were not relaxed.',
'- Native analytic, 3D and motion suites pass. The focused motion/sweep memcheck and 256-building gravity-only synccheck report zero errors.',
'- Frozen penetration: 444 chunks / 896 bonds, one projectile, 10 simulated seconds. Both-wall clearance, 398 retained chunks, 46 detached, 199 broken bonds, exact controlled topology signature and at most one correction pass.',
'- Initial coloring probe stalled due to a cooperative round-counter race. It was terminated, the missing read-before-reset barrier was added, and the corrected scale probe completed under synccheck.',
f"- Isolated instrumented gravity-only probe: 256 intact buildings / 113,664 chunks / 229,376 bonds; {probe['iterations']} iterations and {probe['stress_submission_and_completion_ms']:.6f} ms for its cold stress submit/completion. No projectiles, rigid-body physics, damage or correction. This is not an end-to-end simulation timing.",
'- Fewer maximum stress updates at the bombardment peak do not compensate for more expensive updates. This is measured end-to-end evidence, not proof of a hardware bandwidth or compute limit.',
'- Physical counter-history differences against the first baseline run are recorded below. Matching counters do not prove identical chaotic trajectories.','', '```json',json.dumps(differences,indent=2,sort_keys=True),'```','',
'## Reproduce','',
'Run `python3 qualification/colored-sweep-evaluation/generate_report.py`. The generator validates archived sample hashes, configuration, physical workload, complete-step metrics and controlled quality. Capture reports preserve exact commands and binary hashes. `candidate.patch` records all rejected source/test changes; `artifacts.json` records its base revision and runtime hashes.']
md='\n'.join(text)+'\n';(HERE/'report.md').write_text(md);(HERE/'report.html').write_text(peak.render_html(md));(HERE/'report.json').write_text(json.dumps(dict(schema=1,rows=rows,aggregates=aggregates,phase_peaks=phases,physical_counter_differences=differences,input_report_hashes=hashes,quality=quality),indent=2,sort_keys=True)+'\n')
print(HERE/'report.html')
