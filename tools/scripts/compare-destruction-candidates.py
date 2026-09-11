#!/usr/bin/env python3
"""Compare matched complete-step captures, retaining peaks and physical histories.

Reads reports produced by run-destruction-timing.py. Archives and hash-checks
the raw samples so this report can be regenerated after build outputs expire.
This is a short-screen comparison, never a substitute for endurance gates.
"""
import argparse
import csv
import gzip
import hashlib
import importlib.util
import json
import shutil
import statistics
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
spec = importlib.util.spec_from_file_location('peak', ROOT/'tools/scripts/destruction-peak-opportunities.py')
peak = importlib.util.module_from_spec(spec)
spec.loader.exec_module(peak)
FIELDS = ['bodies', 'awake_bodies', 'logical_clusters', 'contacts_frame',
          'stress_active_nodes', 'stress_active_bonds', 'stress_islands',
          'bonds_broken', 'resim_passes', 'stress_converged']
GRAPH = ['host_connectivity_restores', 'cuda_pre_solve_node_full_snapshots',
         'cuda_pre_solve_fallbacks', 'cuda_pre_solve_host_to_device_bytes',
         'solver_metadata_full_uploads', 'solver_metadata_host_to_device_bytes']


OWNERS = {'stress': 'CPU submission/wait; GPU stress, loads and topology',
          'ownership': 'CPU lifecycle/queries; GPU ownership updates',
          'correction': 'CPU scheduling; GPU restore, collision and solve',
          'commit': 'CPU completion; GPU publication', 'checkpoint': 'CPU submission; GPU copy',
          'trial': 'PhysX CPU tasks and GPU physics', 'commands': 'CPU submission and GPU execution',
          'completion': 'CPU final completion boundary'}

def load(path):
    raw = path.read_bytes()
    return json.loads(gzip.decompress(raw) if path.suffix == '.gz' else raw)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def collect(path, arm, output):
    report = load(path)
    manifest = report['manifest']
    peak.require(manifest['status'] == 'complete', 'Incomplete capture')
    peak.require(len({r['case'] for r in manifest['runs']}) == 1, 'Compare one workload at a time')
    result = []
    for run in manifest['runs']:
        if run['mode'] not in ('plain', 'phases'):
            continue
        source = Path(run['command'][run['command'].index('--output')+1])
        archive = output/'samples'/arm/run['name']
        archive.mkdir(parents=True, exist_ok=True)
        for name in ['native.frames.csv.gz', 'native.summary.json', 'native.graph-diagnostics.json']:
            target = archive/name
            if not target.exists():
                shutil.copy2(source/name, target)
            peak.require(sha(target) == run['files'][name], 'Sample hash mismatch: '+str(target))
        with gzip.open(archive/'native.frames.csv.gz', 'rt') as stream:
            frames = list(csv.DictReader(stream))
        summary = load(archive/'native.summary.json')
        graph = load(archive/'native.graph-diagnostics.json')
        value = dict(summary=summary, frames=frames, graph=graph, mode=run['mode'], name=run['name'])
        value['times'] = peak.complete(value)
        peak.require(all(int(f['stress_converged']) and int(f['resim_passes']) <= 1 for f in frames),
                     'Incomplete solve or changed correction limit')
        peak.require(not graph['boundary_audit_failures'] and not graph['registry_mismatch_fallbacks'],
                     'Graph audit or registry failure')
        if run['mode'] == 'phases':
            captures = [c for c in report['phase_captures'] if c['case'] == run['case']]
            peak.require(len(captures) == 1, 'Ambiguous phase capture')
            value['profile'] = captures[0]['profile']
            value['rank'] = peak.rank(value)
        result.append(value)
    peak.require(len([r for r in result if r['mode'] == 'plain']) >= 2, 'Need repeated untraced runs')
    return manifest, result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', type=Path, required=True)
    parser.add_argument('--candidate', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    manifests = {}
    runs = {}
    for arm in ['baseline', 'candidate']:
        path = getattr(args, arm).resolve()
        manifests[arm], runs[arm] = collect(path, arm, args.output)
    a, b = manifests.values()
    peak.require(a['config'] == b['config'] and a['seconds'] == b['seconds'], 'Different workloads')
    first = runs['baseline'][0]
    fixture = {k: first['summary'][k] for k in ['buildings', 'chunks', 'bonds', 'projectiles', 'correction_limit', 'sleeping']}
    rows = []
    counter_diffs = []
    iteration_diffs = []
    for arm, values in runs.items():
        for run in values:
            peak.require(all(run['summary'][k] == v for k, v in fixture.items()), 'Fixture changed')
            peak.require(len(run['frames']) == len(first['frames']), 'Step count changed')
            for old, new in zip(first['frames'], run['frames']):
                peak.require(old['step'] == new['step'], 'Step identity changed')
                for key in FIELDS:
                    if old[key] != new[key]:
                        counter_diffs.append(dict(arm=arm, run=run['name'], step=new['step'], field=key,
                                                  baseline=old[key], observed=new[key]))
                if old['stress_iterations'] != new['stress_iterations']:
                    iteration_diffs.append(dict(arm=arm, run=run['name'], step=new['step'],
                                                baseline=old['stress_iterations'], observed=new['stress_iterations']))
            if run['mode'] != 'plain':
                continue
            i = max(range(len(run['times'])), key=run['times'].__getitem__)
            rows.append(dict(arm=arm, run=run['name'], mean_ms=statistics.mean(run['times']),
                             peak_ms=run['times'][i], peak_step=int(run['frames'][i]['step']),
                             misses_8ms=sum(t > 8 for t in run['times']),
                             misses_120hz=sum(t > 1000/120 for t in run['times']),
                             misses_60hz=sum(t > 1000/60 for t in run['times']),
                             steps=len(run['times']),
                             peak_work={k: run['frames'][i][k] for k in FIELDS+['stress_iterations']}))
            for budget in ('8ms', '120hz', '60hz'):
                rows[-1]['misses_'+budget+'_percent'] = 100*rows[-1]['misses_'+budget]/rows[-1]['steps']
    aggregates = {arm: dict(runs=sum(r['arm'] == arm for r in rows),
                           mean_ms=statistics.mean(r['mean_ms'] for r in rows if r['arm'] == arm),
                           median_peak_ms=statistics.median(r['peak_ms'] for r in rows if r['arm'] == arm),
                           worst_ms=max(r['peak_ms'] for r in rows if r['arm'] == arm))
                  for arm in runs}
    # Union of both arms' worst steps: a moving peak must not hide regressions.
    steps = sorted({r['peak_step'] for r in rows})
    same_steps = {}
    for step in steps:
        same_steps[step] = {}
        for arm, values in runs.items():
            ts = [float(f['complete_step_ms']) for r in values if r['mode'] == 'plain'
                  for f in r['frames'] if int(f['step']) == step]
            same_steps[step][arm] = dict(min=min(ts), median=statistics.median(ts), max=max(ts))
    md = ['# GPU destruction candidate comparison', '',
          f"Fixture: {fixture['buildings']} buildings, {fixture['chunks']:,} chunks, {fixture['bonds']:,} bonds, "
          f"{fixture['projectiles']} projectiles; {len(first['frames'])} steps / {a['seconds']} simulated seconds per run. "
          f"Correction limit {fixture['correction_limit']}; sleeping {fixture['sleeping']}.", '',
          'Complete wall-clock advance includes commands, physics, destruction, correction, synchronization and runtime growth. '
          'Initialization, rendering and report generation are excluded. Every measured step is retained. '
          'These short, ordered screens do not establish the five 60-second peak gate or endurance.', '',
          '| Version | Runs | Mean ms | Median run peak ms | Worst ms |', '|---|---:|---:|---:|---:|']
    for arm, values in aggregates.items():
        md.append(f"| {arm} | {values['runs']} | {values['mean_ms']:.3f} | {values['median_peak_ms']:.3f} | {values['worst_ms']:.3f} |")
    md += ['', 'Deadline exceedances use strict >8 ms, >1000/120 ms and >1000/60 ms thresholds.', '',
           '| Version/run | Peak step | Peak ms | Awake bodies | Contacts | Stress iterations | >8 ms | >120 Hz budget | >60 Hz budget |',
           '|---|---:|---:|---:|---:|---:|---:|---:|---:|']
    for r in rows:
        w = r['peak_work']
        budgets = ' | '.join(f"{r['misses_'+b]}/{r['steps']} ({r['misses_'+b+'_percent']:.2f}%)" for b in ('8ms', '120hz', '60hz'))
        md.append(f"| {r['arm']}/{r['run']} | {r['peak_step']} | {r['peak_ms']:.3f} | {w['awake_bodies']} | {w['contacts_frame']} | {w['stress_iterations']} | {budgets} |")
    md += ['', '## Same-step comparisons', '', '| Step | Baseline min / median / max ms | Candidate min / median / max ms |', '|---|---:|---:|']
    for step, values in same_steps.items():
        cells = [' / '.join(f'{values[arm][k]:.3f}' for k in ['min', 'median', 'max']) for arm in runs]
        md.append(f"| {step} | {' | '.join(cells)} |")
    md += ['', '## Separate instrumented phase captures', '',
           'Host elapsed scopes include GPU waits. CUDA stages overlap these scopes and must not be added again. '
           'Each table compares the same step in both captures; instrumented timing is not the authoritative peak.', '']
    scoped = {arm: next((r for r in values if r['mode'] == 'phases'), None) for arm, values in runs.items()}
    if all(scoped.values()):
        for step in steps:
            md += [f'### Step {step}', '', '| Responsibility / owner | Baseline ms | Candidate ms |', '|---|---:|---:|']
            totals = {}
            for arm, run in scoped.items():
                i = next(i for i, f in enumerate(run['frames']) if int(f['step']) == step)
                grouped = {k: 0. for k in peak.GROUPS}
                for key, value in run['profile']['wall_partition'][i].items():
                    grouped[peak.group(key)] += value
                for key, field in [('commands', 'command_ms'), ('completion', 'completion_ms')]:
                    grouped[key] = float(run['frames'][i][field])
                totals[arm] = grouped
            for key, (label, _) in peak.GROUPS.items():
                md.append(f"| {label} — {OWNERS[key]} | {totals['baseline'][key]:.3f} | {totals['candidate'][key]:.3f} |")
            md += ['', '| Nested GPU stage (overlaps above) | Baseline ms | Candidate ms |', '|---|---:|---:|']
            cuda = {}
            for arm, run in scoped.items():
                i = next(i for i, f in enumerate(run['frames']) if int(f['step']) == step)
                cuda[arm] = run['profile']['cuda_stages'][i]
            for key in cuda['baseline']:
                md.append(f"| {key} | {cuda['baseline'][key]:.3f} | {cuda['candidate'][key]:.3f} |")
            md.append('')
    md += ['## Connectivity bookkeeping (whole run)', '',
           '| Counter | Baseline range | Candidate range |', '|---|---:|---:|']
    for key in GRAPH:
        cells = []
        for arm, values in runs.items():
            counts = [r['graph'][key] for r in values if r['mode'] == 'plain']
            cells.append(f'{min(counts):,}–{max(counts):,}')
        md.append(f"| {key} | {' | '.join(cells)} |")
    md += ['', '## Quality and provenance', '',
           f'- Physical counter differences: **{len(counter_diffs)}**. Full differences are retained in JSON.',
           f'- Iteration-count differences: **{len(iteration_diffs)}** across all comparisons, including separate phase captures. '
           'Iteration counts alone do not prove or disprove equal physical output.',
           '- All captured solves report convergence and at most one correction. Counter agreement is not proof of identical trajectories.',
           '- Independent physical, memory and lifecycle test evidence must accompany acceptance of a candidate.',
           '- Raw samples are archived and checked against capture hashes. Both manifests retain commands and runtime hashes.', '']
    result = dict(schema=1, fixture=fixture, rows=rows, aggregates=aggregates, same_steps=same_steps,
                  physical_counter_differences=counter_diffs, iteration_differences=iteration_diffs,
                  source_reports={arm: dict(path=str(getattr(args, arm).resolve()), sha256=sha(getattr(args, arm))) for arm in runs})
    text = '\n'.join(md)
    (args.output/'comparison.md').write_text(text)
    (args.output/'comparison.html').write_text(peak.render_html(text))
    (args.output/'comparison.json').write_text(json.dumps(result, indent=2)+'\n')
    print(args.output/'comparison.html')
    if counter_diffs:
        raise SystemExit('Physical counter histories differ; investigate before acceptance')


if __name__ == '__main__':
    main()
