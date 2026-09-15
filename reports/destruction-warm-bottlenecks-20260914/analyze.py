#!/usr/bin/env python3
"""Offline attribution of the frozen warm52 cohort; no benchmark launches."""
import collections
import hashlib
import json
import sqlite3
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
DATA = HERE / 'data'
DATA.mkdir(exist_ok=True)
inputs = {}


def read(path):
    path = Path(path)
    raw = path.read_bytes()
    inputs[str(path.relative_to(ROOT))] = hashlib.sha256(raw).hexdigest()
    return json.loads(raw)


scenarios = read(ROOT / 'reports/destruction-warm-full52-20260914/data/scenarios.json')
coverage = read(ROOT / 'reports/destruction-warm-full52-20260914/data/coverage.json')
campaign = read(ROOT / 'out/warm-full52-20260914/counters/campaign.json')
cov = {r['scenario']: r for r in coverage['rows']}
cnt = {r['scenario']: r for r in campaign['scenarios']}
metric_names = coverage['core_metrics']
rows = []
profiles = {}
for scenario in scenarios:
    name = scenario['scenario']
    c = cov[name]
    a = read(Path(c['cpu_path']) / 'attribution-normalized.json')
    profiles[name] = a
    first = []
    all_ticks = []
    for process in scenario['processes']:
        replay = read(Path(process['path']) / 'replay.json')
        for trajectory in replay['trajectories']:
            measured = [t for t in trajectory['ticks'] if t['measured']]
            assert len(measured) == scenario['measure_ticks']
            first.append(measured[0]['complete_step_ms'])
            all_ticks.extend(measured)
    assert len(all_ticks) == scenario['n']
    assert abs(sum(t['complete_step_ms'] for t in all_ticks) / len(all_ticks) - scenario['mean_ms']) < 1e-9
    assert max(t['complete_step_ms'] for t in all_ticks) == scenario['peak_ms']
    assert sum(t['complete_step_ms'] > 1000 / 60 for t in all_ticks) == scenario['misses_60hz']
    stress = [k for k in a['kernels'] if 'componentStressSolve' in k['name']]
    copies = {k: {'count': 0, 'bytes': 0, 'summed_ms': 0.0} for k in ('HtoD', 'DtoH', 'DtoD', 'other')}
    callers = collections.defaultdict(lambda: {'count': 0, 'bytes': 0, 'summed_ms': 0.0})
    calls = collections.defaultdict(list)
    for call in a['cpu_attribution']['cuda_calls']:
        calls[call['correlation_id']].append(call)
    for transfer in a['transfers']:
        kind = {1: 'HtoD', 2: 'DtoH', 8: 'DtoD'}.get(transfer['kind'], 'other')
        call = max(calls.get(transfer['correlation_id'], []), key=lambda v: len(v.get('stack', [])), default={})
        caller = next((v['symbol'] for v in call.get('stack', [])
                       if v['symbol'].startswith('physx::') and not v['symbol'].startswith('physx::CudaCtx::')
                       and not v.get('unresolved')), 'unresolved engine caller')
        for entry in (copies[kind], callers[(kind, caller)]):
            entry['count'] += 1
            entry['bytes'] += transfer['bytes']
            entry['summed_ms'] += transfer['ms']
    assert sum(x['bytes'] for x in copies.values()) == c['copy_bytes']
    graph_path = c['counter_paths']['graph']
    graph_counters = read(Path(graph_path) / 'analysis.json') if graph_path else []
    inventory = cnt[name]['graph_inventory']
    assert len(graph_counters) == len(inventory)
    stress_graphs = []
    for i, (graph, counters) in enumerate(zip(inventory, graph_counters)):
        assert int(counters['launch']['ID']) == i
        node_ms = sum(n['ms'] for n in graph['nodes'])
        stress_ms = sum(n['ms'] for n in graph['nodes'] if 'componentStressSolve' in n['name'])
        if stress_ms:
            stress_graphs.append({'ordinal': i, 'stress_fraction_of_summed_node_ms': stress_ms / node_ms,
                                 'metrics': {m: counters['metrics'].get(m) for m in metric_names}})
    rows.append({'scenario': name,
                 'chunks': scenario['chunks'], 'bonds': scenario['bonds'],
                 'warmup_ticks': scenario['warmup_ticks'], 'measure_ticks': scenario['measure_ticks'],
                 'n': scenario['n'], 'mean_range_ms': scenario['mean_range_ms'],
                 'mean_ms': scenario['mean_ms'], 'peak_ms': scenario['peak_ms'],
                 'misses_60hz': scenario['misses_60hz'], 'stages_ms': scenario['stages_ms'],
                 'work': scenario['work'], 'preparation': scenario['preparation'],
                 'matched_first_tick_range_ms': [min(first), max(first)],
                 'profile_tick_ms': c['profiled_tick_ms'], 'gpu_activity_union_ms': c['gpu_activity_union_ms'],
                 'stress_kernel_sum_ms': sum(k['ms'] for k in stress),
                 'stress_launches': [{k: v[k] for k in ('ms', 'registers_per_thread', 'grid', 'block', 'shared_bytes')} for v in stress],
                 'copies': copies, 'copy_callers': [{'kind': k[0], 'caller': k[1], **v} for k, v in sorted(callers.items(), key=lambda kv: -kv[1]['bytes'])],
                 'cpu_scopes': c['cpu_scopes'], 'cpu_samples': c['cpu_samples'],
                 'unresolved_leaf_samples': c['unresolved_leaf_samples'],
                 'profile_work': a['physical_sample'], 'stress_graphs': stress_graphs,
                 'cpu_path': c['cpu_path'], 'counter_paths': c['counter_paths'],
                 'warnings': c['warnings']})

focused = read(ROOT / 'out/warm-replay-20260914/final/city256-debris-ncu/analysis.json')
resource_metrics = ['launch__sm_count', 'launch__registers_per_thread_allocated',
                    'launch__occupancy_limit_registers', 'launch__occupancy_limit_warps',
                    'launch__occupancy_limit_shared_mem', 'launch__waves_per_multiprocessor']
focused = [{'name': x['name'], 'launch': x['launch'],
            'metrics': {m: x['metrics'].get(m) for m in metric_names + resource_metrics}} for x in focused]


def span(x):
    return f'{x[0]:.3f}–{x[1]:.3f}'


table = ['# All 52 warm windows: production latency and selected-tick attribution', '',
         'Derived from the saved cohort, not new measurements. Mean range spans two independent processes. '
         'First-tick range uses the first measured tick from all four restored trajectories. '
         'Profiler columns describe one matching first measured tick, not the mean window. '
         'GPU kernel sums, GPU activity union and transfer durations overlap and are not additive.', '',
         'Copies below count only host↔device traffic; device↔device traffic is separate in data/analysis.json. '
         'CPU clocks, graph counters and individual launch resources are also retained there. '
         '[Complete stages, preparation and work](../destruction-warm-full52-20260914/all-scenarios.md).', '',
         '| Scenario | W/M | Mean range ms | Peak ms | Misses / n | Matched first tick ms | Profile tick ms | GPU activity ms | Stress kernels ms | Host↔GPU MB / summed ms |',
         '|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
for r in rows:
    hostbytes = sum(r['copies'][k]['bytes'] for k in ('HtoD', 'DtoH'))
    hostms = sum(r['copies'][k]['summed_ms'] for k in ('HtoD', 'DtoH'))
    table.append(f"| {r['scenario']} | {r['warmup_ticks']}/{r['measure_ticks']} | {span(r['mean_range_ms'])} | {r['peak_ms']:.3f} | {r['misses_60hz']}/{r['n']} | {span(r['matched_first_tick_range_ms'])} | {r['profile_tick_ms']:.3f} | {r['gpu_activity_union_ms']:.3f} | {r['stress_kernel_sum_ms']:.3f} | {hostbytes/1e6:.3f} / {hostms:.3f} |")
(HERE / 'all-scenarios.md').write_text('\n'.join(table) + '\n')

# Standard static plots; use only clock-aligned SQLite NVTX and GPU intervals.
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.patches import Patch
plt.rcParams.update({'font.family': 'DejaVu Sans', 'font.size': 10, 'svg.fonttype': 'none'})
selected = ['bridge64-cold', 'chain256-cold', 'dense12-cold', 'tower64-cold',
            'city256-intact-idle', 'city256-airborne', 'city25-initial-impact', 'city64-initial-impact',
            'city256-initial-impact', 'city256-post-impact', 'city256-cascading-fracture',
            'city256-fragmented-loaded', 'city256-late-debris', 'city256-ten-second-debris']
index = {r['scenario']: r for r in rows}
fig, ax = plt.subplots(figsize=(13, 7.5))
for y, name in enumerate(selected):
    r = index[name]
    ax.barh(y, r['mean_ms'], color='#df8435' if r['mean_ms'] > 1000/60 else '#187f79', height=.65)
    ax.plot(r['mean_range_ms'], [y, y], color='#172f40', linewidth=2)
    ax.plot(r['peak_ms'], y, 'D', color='#713e86', markersize=4)
    ax.text(max(r['peak_ms'], r['mean_ms'])+2, y, f"{r['mean_ms']:.2f} / {r['peak_ms']:.2f}   ({r['misses_60hz']}/{r['n']})", va='center', fontsize=9)
ax.axvline(1000/60, color='#c35423', ls='--', linewidth=1)
ax.set_yticks(range(len(selected)), [n.replace('-cold', '').replace('city256-', 'City256 · ').replace('-', ' ') for n in selected])
ax.invert_yaxis()
ax.set_xlim(0, 250)
ax.set_xlabel('Complete step outside profiler, ms — bar: mean; diamond: observed peak; parentheses: deadline misses')
ax.set_title('Warm gameplay phases have different bottlenecks\nSelected baseline; two processes, two restores each; all measured ticks retained', loc='left')
ax.grid(axis='x', alpha=.15)
ax.spines[['top', 'right']].set_visible(False)
fig.text(.02, .02, 'Dashed line: 60 Hz (16.667 ms). Range mark: process means, not a confidence interval. Restore and fixed warmup excluded.\nFull52 cascade uses W47/M8. Physical history differs from cold restores and uninterrupted trajectories.', fontsize=9)
fig.tight_layout(rect=(0, .075, 1, 1))
for ext in ('png', 'svg'):
    fig.savefig(HERE / f'warm-costs.{ext}', dpi=160)
plt.close(fig)

fig, axes = plt.subplots(2, 1, figsize=(14, 8.4), sharex=True)
scope_lanes = {
    'GpuDestruction.task.prepareIslandRepair': 0,
    'GpuDestruction.submit': 1,
    'GpuDestruction.compatibility.allocateNativeBodies': 2,
    'GpuDestruction.applyDetail.migrateShapes': 2,
    'GpuDestruction.correctedCollisionSolve': 3,
    'GpuDestruction.acceptCorrection': 4,
    'GpuDestruction.finalPublication': 4,
}
timeline = {}
for ax, name in zip(axes, ['city256-initial-impact', 'city256-late-debris']):
    a = profiles[name]
    path = Path(cov[name]['cpu_path']) / 'trace.sqlite'
    db = sqlite3.connect(f'file:{path}?mode=ro', uri=True)
    # SQLite is read-only; its existing capture hashes are recorded by the baseline audit.
    ticks = db.execute("SELECT start,end FROM NVTX_EVENTS WHERE text='snapshot/full_tick'").fetchall()
    assert len(ticks) == 1, (name, ticks)
    start, end = ticks[0]
    scopes = db.execute('SELECT n.start,n.end,coalesce(n.text,s.value) FROM NVTX_EVENTS n LEFT JOIN StringIds s ON n.textId=s.id WHERE n.start>=? AND n.end<=?', (start, end)).fetchall()
    db.close()
    timeline[name] = {'tick_start_ns': start, 'tick_end_ns': end, 'scopes': []}
    for lo, hi, label in scopes:
        if label in scope_lanes:
            lane = scope_lanes[label]
            color = ['#8463a3', '#dd8638', '#be5250', '#6b8ba2', '#698774'][lane]
            ax.broken_barh([((lo-start)/1e6, (hi-lo)/1e6)], (lane-.27, .54), facecolors=color, alpha=.8)
            timeline[name]['scopes'].append({'name': label, 'start_ms': (lo-start)/1e6, 'duration_ms': (hi-lo)/1e6})
    for k in a['kernels']:
        stress = 'componentStressSolve' in k['name']
        lane = 5 if stress else 6
        ax.broken_barh([((k['start_ns']-start)/1e6, k['ms'])], (lane-.27, .54), facecolors='#d76d18' if stress else '#2476a0')
        if stress:
            ax.text((k['start_ns']-start)/1e6+k['ms']/2, lane, f"{k['ms']:.1f}", va='center', ha='center', color='white', fontsize=9)
    for transfer in a['transfers']:
        ax.broken_barh([((transfer['start_ns']-start)/1e6, transfer['ms'])], (7-.27, .54), facecolors='#885895')
    ax.axvline((end-start)/1e6, color='#172f40', linewidth=.8)
    r = index[name]
    ax.set_title(f"{name}: normal matching tick {span(r['matched_first_tick_range_ms'])} ms; instrumented timeline {r['profile_tick_ms']:.2f} ms", loc='left', fontsize=11)
    ax.set_yticks(range(8), ['Host: island repair', 'Host: stress submit / wait', 'Host: allocate / migrate', 'Host: corrected physics', 'Host: accept / publish', 'GPU: stress kernels', 'GPU: other kernels', 'GPU: copies (all directions)'])
    ax.set_ylim(7.65, -.65)
    ax.set_xlim(0, 270)
    ax.grid(axis='x', alpha=.15)
    ax.spines[['top', 'right']].set_visible(False)
axes[-1].set_xlabel('Elapsed time in one instrumented complete tick, ms')
fig.suptitle('First-impact ownership work and sustained stress work lie on different parts of the dependency path', x=.02, ha='left', fontsize=13)
fig.text(.02, .02, 'Host lanes are selected NVTX wall scopes: they include nested GPU work and waits, not exclusive CPU computation. GPU lanes overlap.\nUnpainted host time is not necessarily idle. Profiling perturbs execution; do not stack lanes or substitute these durations for production timing.', fontsize=9)
fig.tight_layout(rect=(0, .075, 1, .96))
for ext in ('png', 'svg'):
    fig.savefig(HERE / f'phase-timelines.{ext}', dpi=160)
plt.close(fig)

source_dir = ROOT / 'out/warm-bottleneck-analysis-20260914/source'
source_hashes = {str(p.relative_to(ROOT)): hashlib.sha256(p.read_bytes()).hexdigest() for p in source_dir.glob('*') if p.is_file()}
output = {'scope': 'Offline analysis of qualified full52 warm baseline; no new runtime measurements or candidate',
          'source_commit': '13b11af2e0aeabf4e0070931fbd8a060f383dfaf',
          'runtime_sha256': 'd5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354',
          'rows': rows, 'focused_warm_debris_stress_counters': focused, 'timeline': timeline,
          'input_sha256': inputs, 'frozen_source_sha256': source_hashes}
(DATA / 'analysis.json').write_text(json.dumps(output, indent=2) + '\n')
print(json.dumps({'status': 'passed', 'scenarios': len(rows), 'ticks_recomputed': sum(r['n'] for r in rows),
                  'inputs_hashed': len(inputs), 'output': str(DATA / 'analysis.json')}))
