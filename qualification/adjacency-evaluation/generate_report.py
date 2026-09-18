#!/usr/bin/env python3
"""Reproduce the archived stable-adjacency experiment comparison from raw evidence."""
from pathlib import Path
import csv,gzip,hashlib,importlib.util,json,statistics
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[1]
spec=importlib.util.spec_from_file_location('peak',ROOT/'tools/scripts/destruction-peak-opportunities.py')
peak=importlib.util.module_from_spec(spec);spec.loader.exec_module(peak)
def load(p):
    raw=p.read_bytes();return json.loads(gzip.decompress(raw) if p.suffix=='.gz' else raw)
def sha(p):return hashlib.sha256(p.read_bytes()).hexdigest()
def require(value,message):
    if not value:raise ValueError(message)
paths={k:HERE.parent/('adjacency-'+k)/'report.json.gz' for k in ['before-impacts-256','after-impacts-256','candidate-repeat','baseline-repeat']}
reports={k:load(p) for k,p in paths.items()}
reference=reports['before-impacts-256']['manifest']
for d in reports.values():
    require(d['manifest']['status']=='complete','Incomplete timing capture')
    require(d['manifest']['config']==reference['config'] and d['manifest']['seconds']==3,'Changed scenario')
fields=['bodies','awake_bodies','logical_clusters','contacts_frame','stress_active_nodes','stress_active_bonds','stress_islands','stress_iterations','bonds_broken','resim_passes','stress_converged']
base=None;changes=[];runs=[]
for case,d in reports.items():
    for r in d['runs']:
        folder=HERE/'validation/samples'/case/('impacts-256-plain-'+str(r['repeat']-1))
        original=next(x for x in d['manifest']['runs'] if x['mode']=='plain' and x['trial']==r['repeat']-1)
        for name in ['native.frames.csv.gz','native.summary.json','native.launches.csv.gz']:
            require(sha(folder/name)==original['files'][name], 'Raw evidence hash mismatch: '+name)
        summary=load(folder/'native.summary.json')
        with gzip.open(folder/'native.frames.csv.gz','rt') as f:frames=list(csv.DictReader(f))
        require((summary['buildings'],summary['chunks'],summary['bonds'],summary['projectiles'],summary['correction_limit'],summary['sleeping'])==(256,113664,229376,256,1,False),'Changed physical workload')
        require(len(frames)==180 and all(int(f['stress_converged']) and int(f['resim_passes'])<=1 for f in frames),'Incomplete physical step')
        values=peak.complete(dict(summary=summary,frames=frames))
        require(abs(max(values)-r['metrics']['max'])<1e-8,'Peak does not match raw samples')
        require(abs(statistics.mean(values)-r['metrics']['mean'])<1e-8,'Mean does not match raw samples')
        run=dict(batch=case,repeat=r['repeat'],mean_ms=statistics.mean(values),peak_ms=max(values),peak_step=values.index(max(values)),missed_8ms=sum(v>8 for v in values),missed_60hz=sum(v>1000/60 for v in values))
        runs.append(run)
        if base is None:base=frames
        for i,(a,b) in enumerate(zip(base,frames)):
            for field in fields:
                if a[field]!=b[field]:changes.append(dict(batch=case,repeat=r['repeat'],step=i,field=field,before=a[field],after=b[field]))
require(all(x['field']=='stress_iterations' and abs(int(x['before'])-int(x['after']))==1 for x in changes),'Unexpected physical counter difference')
work_before=load(HERE.parent/'component-work-bombardment-256/work-totals.json')[103]
work_after=load(HERE.parent/'adjacency-component-work-256/work-totals.json')[103]
require(work_after['operator_csr_visits']==work_after['operator_live_visits'],'Dead visits remain')
quality=load(HERE/'validation/wall-quality.json')
require(quality['frozen_identity_gate_passed'] and quality['largest_connected_cluster']==398 and quality['detached_chunks']==46 and quality['broken_bonds']==199,'Frozen quality failed')
data=dict(status='reverted: peak benefit unsubstantiated',workload=dict(buildings=256,chunks=113664,bonds=229376,projectiles=256,seconds_per_run=3,steps_per_run=180,correction_limit=1,sleeping=False),runs=runs,counter_differences=changes,work_before=work_before,work_after=work_after,quality=quality,source_report_hashes={str(p.relative_to(ROOT)):sha(p) for p in paths.values()},candidate_patch_sha256=sha(HERE/'candidate.patch'))
text=['# Stable GPU adjacency experiment — reverted','',
'Correctness checks passed and dead-reference traversal was removed. A complete-step peak improvement was not established. The candidate is archived as a patch; production source and runtime were returned to the baseline implementation. No compatibility switch or alternate production path remains.','',
'## Workload and timing boundary','',
'256 buildings; 113,664 chunks; 229,376 bonds; 256 simultaneous aerial projectiles; fixed 1/60 s timestep; maximum one correction per step; sleeping disabled. Each short run measures all 180 complete advances across 3 simulated seconds, including first steps and allocation spikes. Commands through mandatory completion are included; initialization, rendering, encoding and report generation are excluded.','',
'Initial order: baseline two repeats, candidate two repeats, with a separate phase capture for each. Follow-up order: candidate five repeats, rebuilt baseline five repeats. Runs were GPU-isolated, with warm-up per campaign. This reversal checks gross batch-order drift but is not individual-run randomized interleaving. These short experiments are not five 60-second acceptance runs or endurance qualification.','',
'## Every untraced run','',
'| Batch | Repeat | Mean complete ms | Peak complete ms | Peak step | Steps >8 ms | Steps >16.67 ms |','|---|---|---|---|---|---|---|']
for r in runs:text.append(f"| {r['batch']} | {r['repeat']} | {r['mean_ms']:.3f} | {r['peak_ms']:.3f} | {r['peak_step']} | {r['missed_8ms']} | {r['missed_60hz']} |")
text+=['','## Separate instrumented phase capture','',
'The following CUDA-event times describe their own phase captures. They overlap host scopes and are not a decomposition of the untraced maximum.','',
'| Phase | Before mean ms | Candidate mean ms | Before at step 103 ms | Candidate at step 103 ms |','|---|---|---|---|---|']
a=reports['before-impacts-256']['phase_captures'][0]['profile']['cuda_stages'];b=reports['after-impacts-256']['phase_captures'][0]['profile']['cuda_stages']
labels={'stress':'GPU: prepare and solve structural stress','commitAndStressTopology':'GPU: commit health and update stress topology','contactLoads':'GPU: convert solved contacts into chunk loads','materials':'GPU: evaluate damage and material verdicts','topologyAndCandidates':'GPU: evaluate connectivity and fracture candidates'}
for key in labels:
 text.append(f"| {labels[key]} | {statistics.mean(x[key] for x in a):.3f} | {statistics.mean(x[key] for x in b):.3f} | {a[103][key]:.3f} | {b[103][key]:.3f} |")
text+=['','## Work removed, and what that tells us','',
f"At step 103, the earlier isolated work probe recorded {work_before['operator_csr_visits']:,} CSR visits, including {work_before['operator_csr_visits']-work_before['operator_live_visits']:,} dead visits. The candidate recorded {work_after['operator_csr_visits']:,} CSR visits and zero dead visits. Both describe 1,606 stress components before fracture. These are stress components, not independently moving rigid bodies.", '',
f"The probes recorded {work_before['component_updates']:,} versus {work_after['component_updates']:,} component updates. Iteration counts can vary by one across diagnostic replays; eliminating dead adjacency does not eliminate the live arithmetic. These intrusive work captures are not performance measurements.", '',
'The candidate reduces average observed stress time slightly, but does not establish a complete-step peak improvement. The repeated peak ranges overlap; the candidate also retains the larger observed worst step. This does not prove a statistically significant regression or a hardware compute/bandwidth limit. It does show that the fraction of dead adjacency visits was not a defensible estimate of available time savings.', '',
'Next priority: reduce repeated live work in the retained building components through stronger preconditioning, with setup cost and unchanged physical acceptance included. Ownership and correction remain separate peak opportunities. Do not spend further iterations polishing the rejected compaction in isolation.','',
'## Correctness and preservation','',
'- Native analytical and 3D oracle suites passed; the stable-filter test covered empty/high-degree rows, tombstones, all-bond removal, restoration and repeated captured-graph execution.',
'- New compaction kernel passed CUDA memcheck, initcheck, synccheck and racecheck. These checks cover the tested kernels, not a claim that the whole engine is race-free.',
'- Frozen penetration: one building, 444 chunks, 896 bonds, one projectile, 10 simulated seconds. Passed both-wall clearance, exact topology signature, 398 retained supported chunks, 46 detached chunks, 199 broken bonds, and correction maximum one.',
f'- Across the {len(runs)} untraced runs, the archived comparison records {len(changes)} differences in the listed physical/convergence/iteration counters against the first baseline. All observed differences were single-update stress iteration counts, occurring in both versions; body/contact/fracture/convergence counters matched. Counter agreement alone is not trajectory equivalence; the independent frozen audit remains necessary.',
'- Production mathematics, tolerances and physical settings were unchanged by the candidate. Compaction preserved the original order of live references, keeping immutable authored CSR for reconstruction.',
'- Rebuild work ran inside a generation-guarded device topology transaction, without host counts. It used additional persistent offsets/counts/reference storage; no runtime allocation was required for this fixed asset.', '',
'## Reproduce','',
'Run python3 qualification/adjacency-evaluation/generate_report.py. The generator checks raw complete-step samples against each timing report, checks workload identity and physical counters, and regenerates Markdown, HTML and JSON. candidate.patch preserves the tested change against source revision 2690b048; it is not applied to production. validation/ retains numerical, sanitizer, penetration and raw timing evidence.','']
body='\n'.join(text)
(HERE/'report.md').write_text(body)
(HERE/'report.html').write_text(peak.render_html(body).replace('<title>Destruction peak opportunities</title>','<title>GPU adjacency experiment</title>'))
(HERE/'report.json').write_text(json.dumps(data,indent=2,sort_keys=True)+'\n')
print(HERE/'report.html')
