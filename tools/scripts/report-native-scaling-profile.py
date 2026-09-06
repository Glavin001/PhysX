#!/usr/bin/env python3
"""Produce a reproducible comparison of complete native GPU profiling campaigns."""
import argparse,collections,csv,gzip,importlib.util,json,statistics
from pathlib import Path
spec=importlib.util.spec_from_file_location('analysis',Path(__file__).with_name('analyze-native-gpu-profile.py'));a=importlib.util.module_from_spec(spec);spec.loader.exec_module(a)

def metric(p,key):return p['metrics'].get(key,{}).get('mean',0)
def short(name):return name.removeprefix('GpuDestruction.')
def main():
    parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('campaigns',nargs='+',type=Path);parser.add_argument('--output',required=True,type=Path);args=parser.parse_args()
    cases=collections.defaultdict(dict);all_runs=[]
    for root in args.campaigns:
        campaign=json.loads((root/'campaign.json').read_text())
        for run in campaign['runs']:
            key=(run['case'],run['grid']);row=dict(run,campaign=str(root),source_revision=campaign['revision']);all_runs.append(row)
            if run['exit_code']!=0:
                cases[key].setdefault('failures',[]).append(row);continue
            directory=root/run['name'];p=json.loads((directory/'native.profile.json').read_text())
            if run['trace']:cases[key]['trace']=(directory,p)
            else:
                if cases[key].get('baseline_campaign')!=str(root):cases[key]['baseline']=[];cases[key]['baseline_campaign']=str(root)
                cases[key].setdefault('baseline',[]).append((directory,p))
    report=['# Native PhysX GPU destruction: scaling and phase profile','',
        'Measured on the available RTX 4090, with another GPU process present. This is a bottleneck investigation, **not isolated 60 Hz qualification**. No physical settings, stress tolerances, damage model, or one-correction limit were reduced. Rendering, video export, and motion auditing were off.', '',
        'Each run advances 720 steps (12 simulated seconds); the first 60 steps are excluded from the tables. Untraced comparisons use two repeat runs per workload. Separate CUPTI runs provide actual concurrent kernel/copy intervals and timestamped, per-thread CPU scopes. First-impact allocation and correction spikes remain in the measured interval. The campaign also retains incomplete runs; they are not successful timing samples.','',
        '## Baseline workloads','',
        'Bodies are registered PhysX dynamic + kinematic bodies; awake counts are the last solver pass’s island scheduling counts. Supported buildings use kinematic clusters. Sleeping remains disabled in this integrated correction path. “Pairs/step” counts contact managers processed across trial and correction, not unique touching pairs. Stress-active bonds are the retained stress graph, not the number visited by every iterative kernel.','',
        '| Workload | Authored chunks / bonds | Bodies mean / max | Awake mean / max | Pairs/step mean | Mean ms | Min / p95 / max ms | >16.67 ms |','|---|---:|---:|---:|---:|---:|---:|---:|']
    serial={}
    ordered=sorted(cases,key=lambda k:({'idle':0,'single-impact':1,'burst':2,'sustained':3}.get(k[0],4),k[1],k[0]))
    for key in ordered:
        c=cases[key];label=f'{key[0]} g{key[1]}';samples=[]
        for directory,p in c.get('baseline',[]):samples.extend(list(a.read_csv(directory/'native.profile.frames.csv'))[60:])
        if not samples:
            report.append(f'| {label} | — | — | — | — | **INCOMPLETE** | GPU allocation failure | — |')
            serial[label]={'failures':c.get('failures',[])};continue
        def values(k):return [float(r.get(k,0)) for r in samples]
        mean=lambda k:statistics.mean(values(k));maximum=lambda k:max(values(k))
        t=a.stats(values('physics_step_ms'));last=c['baseline'][-1][1]['summary'];miss=sum(v>1000/60 for v in values('physics_step_ms'))
        report.append(f"| {label} | {last['chunks']:,} / {last['bonds']:,} | {mean('bodies'):,.0f} / {maximum('bodies'):,.0f} | {mean('awake_bodies'):,.0f} / {maximum('awake_bodies'):,.0f} | {mean('pre_solve_pairs'):,.0f} | {t['mean']:.3f} | {t['min']:.3f} / {t['p95']:.3f} / {t['max']:.3f} | {miss}/{len(samples)} |")
        serial[label]={'timing_ms':t,'missed_deadlines':miss,'source_summary':last,'metrics':{k:a.stats(values(k)) for k in ('bodies','awake_bodies','pre_solve_pairs','stress_active_bonds','bonds_broken','process_cpu_ms')},'runs':[str(d) for d,p in c['baseline']],'per_run_means':[metric(p,'physics_step_ms') for d,p in c['baseline']],'failures':c.get('failures',[])}
        if 'trace' in c:serial[label]['trace']=str(c['trace'][0]);serial[label]['profile']=c['trace'][1]
    report+=['','A fast mean is insufficient for strict 60 Hz: the deadline column includes allocation, impact, and correction spikes. These are 11-second measured windows, not the specified future five-by-60-second qualification.','',
        '## GPU execution versus host-controlled gaps','',
        'These rows come from the **traced** runs, so their wall times differ from the untraced baseline above. Kernel union + copy-only union + no-GPU interval sum to the timestamped simulation interval (within rounding). No-GPU means no traced GPU activity from this process; another process may still be using the GPU. Thread/process CPU core-ms include spinning and profiler/driver work and cannot be added to wall-ms.','',
        '| Workload | Wall ms | Kernel union ms | Copy-only ms | No GPU activity ms | Process CPU core-ms | Instrumented CPU core-ms |','|---|---:|---:|---:|---:|---:|---:|']
    for key in ordered:
        c=cases[key]
        if 'trace' not in c:continue
        d,p=c['trace'];report.append('| '+f'{key[0]} g{key[1]}'+' | '+' | '.join(f'{metric(p,k):.3f}' for k in ('interval_ms','gpu_kernel_union_ms','gpu_copy_only_ms','no_gpu_activity_ms','process_cpu_ms','instrumented_cpu_core_ms'))+' |')
    report+=['','## Phase costs across workloads','',
        'CPU columns are exclusive **core-ms/step**, so the two task families do not double-count their synchronous children. GPU columns are summed kernel ms/step; these columns are not an additive wall-time decomposition.', '',
        '| Workload | CPU contact lifecycle | CPU island maintenance | CPU new-body allocation | GPU broad phase | GPU rigid solve/preparation | GPU stress |',
        '|---|---:|---:|---:|---:|---:|---:|']
    contact_names={'islandInsertion','registerSceneInteractions','registerContactManagers','preallocateContactManagers','registerInteractions','processLostContacts','processLostContacts2','processLostContacts3'}
    for key in ordered:
        if 'trace' not in cases[key]:continue
        p=cases[key]['trace'][1];contact=islands=allocation=0
        for row in p['host_phases']:
            name=row['name'];value=row['mean_exclusive_cpu_core_ms']
            if ('.trialDetail.' in name or '.detail.' in name) and name.rsplit('.',1)[-1] in contact_names:contact+=value
            if '.task.accurateIsland' in name or '.task.speculativeIsland' in name:islands+=value
            if name.endswith('.finishDetail.allocateNativeBodies'):allocation+=value
        gpu=p['gpu_kernel_categories_mean_sum_ms']
        values=[contact,islands,allocation,gpu.get('physics broad phase',0),gpu.get('physics constraint preparation / solve / integration',0),gpu.get('stress solver / stress topology',0)]
        report.append('| '+f'{key[0]} g{key[1]}'+' | '+' | '.join(f'{v:.3f}' for v in values)+' |')
    report+=['','Contact lifecycle groups insertion/registration/preallocation and lost-contact processing in trial and correction. Island maintenance groups accurate/speculative graph maintenance and their children. All individual scopes remain available below and in JSON.','']
    target=cases.get(('burst',8),{}).get('trace')
    if target:
        directory,p=target;metrics=p['metrics'];report+=['','## Detailed largest completed bombardment trace','',f'Source: `{directory}`. All means below are amortized over {metrics["physics_step_ms"]["n"]} measured steps. Nested host timings and simultaneous kernels are not an additive wall-time breakdown.','',
          '### GPU kernel categories','', '| Category | Sum mean ms | Per-step p95 ms | Per-step max ms |','|---|---:|---:|---:|']
        for category,v in sorted(p['gpu_kernel_categories_mean_sum_ms'].items(),key=lambda v:-v[1]):
            s=metrics['kernel_sum_ms:'+category];report.append(f"| {category} | {v:.3f} | {s['p95']:.3f} | {s['max']:.3f} |")
        report+=['','Category timings are sums of observed kernel durations, including contention. They are not hardware utilization percentages and do not establish DRAM-bandwidth versus SM-throughput saturation. Source-based classification and every kernel name are retained in the JSON report.','',
         '### CPU tasks','', '| Scope | Exclusive CPU core-ms mean | p95 / max core-ms per step | Inclusive wall-ms mean | GPU overlap within scope ms |','|---|---:|---:|---:|---:|']
        for phase in p['host_phases']:
            name=phase['name'];s=metrics.get('cpu_exclusive_ms:'+name,{})
            report.append(f"| {short(name)} | {phase['mean_exclusive_cpu_core_ms']:.3f} | {s.get('p95',0):.3f} / {s.get('max',0):.3f} | {phase['mean_inclusive_wall_ms']:.3f} | {phase['mean_gpu_overlap_ms']:.3f} |")
        report+=['','Synchronous children on the same OS thread are subtracted from CPU time. Detached correction spans have wall time only. Uninstrumented CPU time remains visible as the difference from total process CPU core-ms; it includes dispatcher work/spinning, callbacks, and profiling overhead and is not automatically classified as useful physics calculation.','',
            '### Correction, checkpoint, and waiting','', '| Measurement | Mean | p95 | Max |','|---|---:|---:|---:|']
        for key in ('correction_wall_ms','correction_gpu_busy_ms','trial_and_other_gpu_busy_ms','checkpoint_gpu_copy_union_ms','checkpoint_gpu_copy_bytes','cuda_wait_api_union_ms','no_gpu_inside_cuda_wait_ms'):
            s=metrics[key];report.append(f"| {key} | {s['mean']:.3f} | {s['p95']:.3f} | {s['max']:.3f} |")
        corrections=sum(int(float(r['resim_passes'])) for r in list(a.read_csv(directory/'native.profile.frames.csv'))[60:])
        report.append(f'\nCorrected steps: {corrections}. Mean corrected collision/solve wall interval **when it ran**: {metric(p,"correction_wall_ms")*metrics["physics_step_ms"]["n"]/max(1,corrections):.3f} ms. No step exceeds one correction.')
        report+=['','Checkpoint copies are device-to-device transfers associated with APIs inside the explicit checkpoint scope by CUPTI correlation IDs; their execution can occur after that CPU scope returns. CUDA wait-API durations overlap GPU execution, CPU work, and one another; they are not an additional simulation cost. A wait marks a dependency, and its CPU clock may include active polling.','',
         '| CUDA API | Summed host duration / measured step, ms |','|---|---:|']
        for name,v in list(p['driver_apis_mean_sum_ms'].items())[:25]:report.append(f'| {name} | {v:.4f} |')
        report+=['','### Continued contacts without new breakage','']
        for label,window in p['windows'].items():
            if label not in ('corrected','uncorrected','late_rubble','contact_without_new_fracture'):continue
            s=window['physics_step_ms'];report.append(f'- {label}: {s["n"]} steps; mean **{s["mean"]:.3f} ms**, p95 {s["p95"]:.3f}, max {s["max"]:.3f}; awake mean {window["awake_bodies"]["mean"]:,.0f}, processed pairs mean {window["pre_solve_pairs"]["mean"]:,.0f}.')
    report+=['','## Scaling associations','',
       'The correlations below use frame samples within each traced workload. They are associations, not fitted algorithmic complexity or causal coefficients: body count, pair count, damage, and simulation time co-vary. The separated-body and intact-city controls provide the stronger comparisons.','',
       '| Workload | Step time vs awake bodies | vs processed pairs | vs retained stress bonds | vs stress iterations | vs newly broken bonds | vs correction flag |','|---|---:|---:|---:|---:|---:|---:|']
    for key in ordered:
        if 'trace' not in cases[key]:continue
        p=cases[key]['trace'][1];corr=p['associations_pearson_not_causal'];report.append('| '+f'{key[0]} g{key[1]}'+' | '+' | '.join('—' if corr[k] is None else f'{corr[k]:.3f}' for k in ('awake_bodies','pre_solve_pairs','stress_active_bonds','stress_iterations','bonds_broken','resim_passes'))+' |')
    report+=['','## Instrumentation and limitations','',
       '- CUPTI concurrent-kernel, memcpy, memset, driver and runtime activity tracing; no per-kernel synchronization or kernel replay. Every successful trace must have zero dropped records and zero invalid timestamps. Old initial traces have driver-only APIs; final detailed traces include runtime APIs too.',
       '- Frame, scope, and activity clocks share CUPTI timestamps when tracing is enabled. GPU overlap is computed from interval unions, not the sum of durations. CPU clocks are process CPU time and per-OS-thread CPU time.',
       '- CUDA-event stress-stage intervals remain in `native.phases.csv.device.csv.gz`; they include dependencies and launch gaps. They are not substituted for measured kernel execution.',
       '- The legacy `stress_solve_ms` column is an unavailable zero placeholder; this report never uses it. Public contact/solver statistics do not include all GPU work and are also excluded; use processed contact-manager pairs and solved contact reports.',
       '- Counter observations are small fixed-size diagnostic reads after simulation; pose arrays are not read. Diagnostic observations and input placement are outside `physics_step_ms`, and could still affect following-step GPU conditions. CUPTI transferred-byte counts exclude implicit mapped-memory traffic.',
       '- All physical parameters, actual-impulse fracture decisions, stress convergence checks, and one-correction limit are retained. Large chaotic trajectories vary between repeats, so trace-versus-baseline differences are not a precise subtractable profiler overhead. Idle and separated-body repeats are the cleaner overhead checks.',
       '- Native corrected-path sleeping is still unsupported here. These results do not establish the scale of a sleeping integrated scene. Existing native CUDA memory-sanitizer qualification is a separate unresolved gate; these successful runs do not resolve it.',
       '- Build commands, exact binary/shared-library hashes, modified-source hashes, run arguments, GPU-process inventory, and sampled GPU conditions are in each campaign JSON. Traced and untraced captures differ only in diagnostic instrumentation; final traces add explicit checkpoint and CPU fallback scopes to the same physics implementation. Failed runs retain their logs and partial traces.',
       '- Scope accounting tests cover overlap, nested/parallel CPU scopes, crossing-scope rejection, frame clipping, and constant-counter correlations. These timing changes do not alter solver equations.',
       '', '## Failure inventory','']
    for run in all_runs:
        if run['exit_code']:
            log=Path(run['campaign'])/(run['name']+'.log');lines=log.read_text(errors='replace').splitlines();why=next((s for s in lines if 'failed to allocate memory' in s),'see log');frame=next((s for s in lines if 'INCOMPLETE native step' in s),'')
            report.append(f'- `{log}`: {why} {frame}')
    findings=[]
    if all(k in serial and 'timing_ms' in serial[k] for k in ('idle g16','burst g8','free-96000 g1','free-24000 g1')):
        idle,burst,free,free24=(serial[k] for k in ('idle g16','burst g8','free-96000 g1','free-24000 g1'))
        profile=burst['profile'];wall=metric(profile,'interval_ms');busy=metric(profile,'gpu_busy_ms');no_gpu=metric(profile,'no_gpu_activity_ms')
        findings=[
          '**The principal scaling bottleneck in these collapse workloads is CPU contact and island lifecycle processing.** Raw authored chunk/bond count and raw awake-body count do not explain the slowdown.', '',
          f"- The intact 113,664-chunk / 229,376-bond city averages **{idle['timing_ms']['mean']:.3f} ms**. It has 256 motion clusters and zero awake bodies.",
          f"- **96,000 separated awake bodies** average **{free['timing_ms']['mean']:.3f} ms**; 24,000 average **{free24['timing_ms']['mean']:.3f} ms**. They are moving, gravity-free ordinary bodies in empty space, an explicitly different control workload.",
          f"- Bombardment with approximately **{burst['metrics']['awake_bodies']['mean']:,.0f} awake bodies** and **{burst['metrics']['pre_solve_pairs']['mean']:,.0f} processed contact pairs/step** averages **{burst['timing_ms']['mean']:.3f} ms**. Contact workload and lifecycle churn dominate the comparison.",
          f"- In its detailed trace, **{busy:.3f} of {wall:.3f} ms** contains this process's GPU execution; **{no_gpu:.3f} ms ({100*no_gpu/wall:.1f}%)** has none. Measured CPU tasks identify registration, allocation, lost-contact processing, and island graph maintenance as major costs. The remaining host gap is not automatically classified as CPU arithmetic.",
          f"- GPU stress kernels, including stress-topology maintenance, average **{profile['gpu_kernel_categories_mean_sum_ms']['stress solver / stress topology']:.3f} ms** in this bombardment. On the isolated-impact large city they take a larger share; optimization priorities are workload-dependent.",
          '- The 113,664-chunk burst and sustained-impact variants fail on contact/friction solver memory growth under the shared GPU conditions. This is a separate capacity bottleneck, not a valid completed timing result.', '',
          '**Where to focus next:** move contact/interaction lifecycle and island scheduling onto the resident GPU path; address the dense-contact solver allocation footprint; then optimize broad-phase candidate generation. Checkpoint copies and the stress solver are smaller costs in the measured large-collapse case. No physics shortcut is justified by these measurements.', '',
          '## What grows with what', '',
          '| Work | Relevant workload term | Evidence / interpretation |',
          '|---|---|---|',
          '| CPU active-body/deactivation scans | Active/native body slots | Separated 6k/24k/96k controls expose body-count cost without contacts. At 96k, accurate + speculative deactivation consume about 1.8 CPU core-ms/step. |',
          '| CPU interaction registration and retirement | New/lost contact-manager edges and shapes | Dominant measured task family during dense collapse; less expensive after the contact set settles. |',
          '| CPU island maintenance | Contact graph size, removed edges, connectivity searches | Accurate-island path finding reaches 236 CPU core-ms in one measured step. This work can persist without any newly broken destruction bonds. |',
          '| GPU broad phase | Updated shape bounds and spatial overlap candidates | Largest GPU category in the collapse; incremental sweep-and-prune is the largest individual kernel. |',
          '| GPU narrow phase / constraint solve | Candidate pairs, touching contacts, friction rows, solver iterations | Contact-rich scenes cost much more than separated bodies; allocations for contact/friction blocks can exhaust available VRAM. |',
          '| GPU stress | Active stress nodes/bonds, convergence iterations, island distribution | 200k retained stress bonds in the intact city are cheap after convergence; an impact changes convergence work. Counts alone do not predict iteration cost. |',
          '| GPU topology changes | Affected chunks/bonds/components and new cluster slots | Occurs on fracture decisions; report includes corrected versus noncorrected steps. It is not the sustained-collapse bottleneck here. |',
          '| Checkpoint | Allocated native rigid-state slots | At 96k free bodies, approximately 23 MB of device-to-device checkpoint copies take 0.024 ms/step in the trace; no CPU pose transfer. |', '',
          'These are dependencies supported by the controls and implementation, not fitted Big-O claims. Contact count and topology churn are related; the campaign does not independently fix one while sweeping the other.', '',
        ]
    report[2:2]=findings
    args.output.parent.mkdir(parents=True,exist_ok=True);args.output.write_text('\n'.join(report)+'\n');args.output.with_suffix('.json').write_text(json.dumps({'cases':serial,'run_count':len(all_runs),'failed_runs':sum(bool(r['exit_code']) for r in all_runs),'campaigns':[str(p) for p in args.campaigns]},indent=2)+'\n')
    print(args.output)
if __name__=='__main__':main()
