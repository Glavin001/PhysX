#!/usr/bin/env python3
"""Report matched connectivity ownership runs with overlap-aware CPU/GPU timings."""
import argparse
import collections
import importlib.util
import json
import statistics
from pathlib import Path

spec = importlib.util.spec_from_file_location('analysis', Path(__file__).with_name('analyze-native-gpu-profile.py'))
analysis = importlib.util.module_from_spec(spec)
spec.loader.exec_module(analysis)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('campaign', type=Path)
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--reuse-analysis', action='store_true', help='Reuse existing per-run analysis when only report presentation changed')
    args = parser.parse_args()
    campaign = json.loads((args.campaign/'campaign.json').read_text())
    groups = collections.defaultdict(list)
    traces = {}
    runs = []
    catalog = analysis.source_catalog()
    for run in campaign['runs']:
        if run['exit_code']:
            raise ValueError('incomplete run: '+run['name'])
        directory = args.campaign/run['name']
        cached = directory/'native.profile.json'
        profile = json.loads(cached.read_text()) if args.reuse_analysis and cached.exists() else analysis.analyze(directory, catalog=catalog)
        graph = json.loads((directory/'native.graph-diagnostics.json').read_text())
        runs.append(dict(run=run, summary=profile['summary'], metrics=profile['metrics'], graph=graph,
                         deadline_misses=profile['deadline_misses']))
        key = run['case'], run['grid'], run['owner']
        if run['trace']:
            traces[key] = profile
        else:
            groups[key].extend(list(analysis.read_csv(directory/'native.profile.frames.csv'))[60:])
    cases = list(dict.fromkeys((r['case'], r['grid']) for r in campaign['runs']))
    text = ['# GPU connectivity ownership: matched comparison', '',
        'The opt-in path uses the existing GPU component graph as solver connectivity and skips CPU path searches and island splitting. CPU actor/contact registration and constraint partitioning remain. Sleeping and unsupported scenes retain the existing path. One correction per step and physical settings are unchanged.', '',
        f'Campaign: `{args.campaign}`. Timing tables exclude the first 60 steps of each run. Trial 0 uses CUPTI concurrent activity tracing; the remaining trials are untraced. Each run advances {runs[0]["summary"]["seconds"]} simulated seconds. This is a bounded comparison, not the full 60-second/five-trial scale qualification.', '',
        'Both modes include the fragment-readiness fix `6a3ac3f9`; earlier captures without it are not matched performance baselines. Validation evidence is recorded separately in `qualification/connectivity-validation-20260906.json`.', '',
        '## Untraced step times', '',
        '| Workload | Chunks / bonds | CPU-owned mean ms | GPU-owned mean ms | Speed ratio | GPU-owned min / p95 / max ms | GPU-owned missed deadlines |',
        '|---|---:|---:|---:|---:|---:|---:|']
    comparisons = []
    work_warnings = []
    for case, grid in cases:
        before = groups[(case, grid, 0)]
        after = groups[(case, grid, 1)]
        if not before or not after:
            raise ValueError('missing untraced comparison')
        a = analysis.stats([float(r['physics_step_ms']) for r in before])
        b = analysis.stats([float(r['physics_step_ms']) for r in after])
        misses = sum(float(r['physics_step_ms']) > 1000/60 for r in after)
        summary = next(r['summary'] for r in runs if r['run']['case'] == case and r['run']['grid'] == grid)
        cohort = [[r['summary']['broken_bonds'] for r in runs if r['run']['case'] == case
                   and r['run']['grid'] == grid and r['run']['owner'] == owner and not r['run']['trace']]
                  for owner in (0, 1)]
        mismatch = len(set(cohort[0]+cohort[1])) != 1
        marker = '†' if mismatch else ''
        if mismatch:
            work_warnings.append(f'† {case} g{grid}: CPU-owned runs broke {cohort[0]} bonds; GPU-owned runs broke {cohort[1]}. The displayed ratio includes different realized destruction work and is **not an attributable optimization speedup**. No run was discarded.')
        text.append(f'| {case} g{grid}{marker} | {summary["chunks"]:,} / {summary["bonds"]:,} | {a["mean"]:.3f} | {b["mean"]:.3f} | {a["mean"]/b["mean"]:.2f}×{marker} | {b["min"]:.3f} / {b["p95"]:.3f} / {b["max"]:.3f} | {misses}/{len(after)} |')
        comparisons.append(dict(case=case, grid=grid, before=a, after=b, speed_ratio=a['mean']/b['mean'], missed=misses))
    text += ['']+work_warnings
    text += ['', '## Traced phase costs', '',
        'Each cell is CPU-owned → GPU-owned. CPU values are exclusive core-ms; concurrent GPU times use interval unions. These columns cannot be added together as elapsed step time.', '',
        '| Workload | Step wall ms | CPU island maintenance core-ms | CPU contact lifecycle core-ms | GPU busy ms | No GPU activity ms | Graph readback bytes/step |',
        '|---|---:|---:|---:|---:|---:|---:|']
    for case, grid in cases:
        values = []
        for owner in (0, 1):
            p = traces[(case, grid, owner)]
            phase = p['host_phases']
            island = sum(x['mean_exclusive_cpu_core_ms'] for x in phase if 'accurateIsland' in x['name'] or 'speculativeIsland' in x['name'] or 'restoreHostConnectivity' in x['name'])
            contact_names = {'islandInsertion', 'registerSceneInteractions', 'registerContactManagers',
                             'preallocateContactManagers', 'registerInteractions', 'processLostContacts',
                             'processLostContacts2', 'processLostContacts3'}
            contact = sum(x['mean_exclusive_cpu_core_ms'] for x in phase
                          if ('.trialDetail.' in x['name'] or '.detail.' in x['name'])
                          and x['name'].rsplit('.', 1)[-1] in contact_names)
            m = p['metrics']
            values.append([m['physics_step_ms']['mean'], island, contact, m['gpu_busy_ms']['mean'], m['no_gpu_activity_ms']['mean'], m['graph_d2h_bytes']['mean']])
        text.append('| '+f'{case} g{grid}'+' | '+' | '.join(f'{a:.3f} → {b:.3f}' for a, b in zip(*values))+' |')
    text += ['', '## Work and fallback counters', '',
        '| Workload | Mode | Awake bodies mean | Processed pairs/step mean | Stress bonds mean | Broken bonds across runs | Device-owned passes across runs | Host restores across runs |',
        '|---|---|---:|---:|---:|---|---|---|']
    for case, grid in cases:
        for owner in (0, 1):
            rows = groups[(case, grid, owner)]
            matching = [r for r in runs if (r['run']['case'], r['run']['grid'], r['run']['owner']) == (case, grid, owner)]
            avg = lambda key: statistics.mean(float(r[key]) for r in rows)
            text.append(f'| {case} g{grid} | {"GPU-owned" if owner else "CPU-owned"} | {avg("awake_bodies"):.1f} | {avg("pre_solve_pairs"):.1f} | {avg("stress_active_bonds"):.1f} | '+', '.join(str(r['summary']['broken_bonds']) for r in matching)+' | '+', '.join(str(r['graph']['device_connectivity_passes']) for r in matching)+' | '+', '.join(str(r['graph']['host_connectivity_restores']) for r in matching)+' |')
    if ('burst', 8, 0) in traces and ('burst', 8, 1) in traces:
        pair = [traces[('burst', 8, owner)] for owner in (0, 1)]
        text += ['', '## Largest bombardment: detailed traced breakdown', '',
            'Means are amortized across measured steps, including steps without correction. CPU core times and overlapping GPU kernel sums are not additive wall times.', '',
            '| Measurement | CPU-owned | GPU-owned |', '|---|---:|---:|']
        for key in ('physics_step_ms', 'process_cpu_ms', 'gpu_busy_ms', 'no_gpu_activity_ms',
                    'correction_wall_ms', 'correction_gpu_busy_ms', 'trial_and_other_gpu_busy_ms',
                    'checkpoint_gpu_copy_union_ms', 'checkpoint_gpu_copy_bytes', 'cuda_wait_api_union_ms',
                    'no_gpu_inside_cuda_wait_ms'):
            text.append('| '+key+' | '+' | '.join(f'{p["metrics"][key]["mean"]:.3f}' for p in pair)+' |')
        phases = [{x['name']: x['mean_exclusive_cpu_core_ms'] for x in p['host_phases']} for p in pair]
        names = sorted(set(phases[0]) | set(phases[1]), key=lambda n: -max(d.get(n, 0) for d in phases))[:18]
        text += ['', '| CPU scope | CPU-owned core-ms | GPU-owned core-ms |', '|---|---:|---:|']
        for name in names:
            text.append('| '+name.removeprefix('GpuDestruction.')+' | '+' | '.join(f'{d.get(name, 0):.3f}' for d in phases)+' |')
        categories = [p['gpu_kernel_categories_mean_sum_ms'] for p in pair]
        text += ['', '| GPU category | CPU-owned summed kernel ms | GPU-owned summed kernel ms |', '|---|---:|---:|']
        for name in sorted(set(categories[0]) | set(categories[1]), key=lambda n: -max(d.get(n, 0) for d in categories)):
            text.append('| '+name+' | '+' | '.join(f'{d.get(name, 0):.3f}' for d in categories)+' |')
    text += ['', '## Interpretation limits', '',
        '- Chaotic bombardment trajectories differ between repeated GPU runs; inspect actual processed work alongside timing. Controlled repeated-impact tests separately require identical fracture steps, momentum checks, and trajectory differences below the existing 2e-4 tolerance.',
        '- No sleeping benefit is measured here. Sleeping scenes fall back; GPU-owned activation and sleep propagation are still future work.',
        '- The new mode removes CPU connectivity searches and component observation. It does not remove CPU contact creation, registration, active-body staging, or constraint partitioning.',
        '- Restoring CPU connectivity is explicit and counted. Buffer growth or a missing eligible previous GPU graph can still trigger it; unsupported features also restore the host path.',
        '- No physical work is capped or omitted. Every completed frame requires converged stress and at most one correction. Captures require zero dropped activity records and valid timestamps.',
        '- CPU core-ms include spinning and profiler/driver work. No-GPU-activity time refers to this process, not global device idleness. See the campaign for GPU samples, process inventory, exact commands, source hashes, and binary hashes.',
        '- Rendering is disabled. These are simulation times, not whole-game tick or rendering rates.', '']
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text('\n'.join(text))
    args.output.with_suffix('.json').write_text(json.dumps(dict(campaign=campaign, comparisons=comparisons, runs=runs, traces={str(k):v for k,v in traces.items()}), indent=2)+'\n')
    print(args.output)


if __name__ == '__main__':
    main()
