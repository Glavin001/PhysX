#!/usr/bin/env python3
"""Summarize active destruction capacity from complete, archived timing captures."""
import argparse
import csv
import gzip
import hashlib
import importlib.util
import json
import statistics
from pathlib import Path


def rows(path):
    with gzip.open(path, 'rt') as stream:
        return list(csv.DictReader(stream))


def analyze(campaign, run):
    folder = campaign.parent / run['name']
    for name, digest in run['files'].items():
        assert hashlib.sha256((folder / name).read_bytes()).hexdigest() == digest, name
    summary = json.loads((folder / 'native.summary.json').read_text())
    frames = rows(folder / 'native.frames.csv.gz')
    launches = rows(folder / 'native.launches.csv.gz')
    count = summary['frames']
    assert count == len(frames) and count == round(summary['seconds'] * 60)
    assert (summary['buildings'], summary['chunks'], summary['bonds'], summary['projectiles']) == (256, 113664, 229376, 256)
    assert len(launches) == 256 and len({int(r['projectile']) for r in launches}) == 256
    assert len({int(r['target_building']) for r in launches}) == 256
    assert summary['correction_limit'] == 1 and not summary['sleeping']
    assert summary['status'] == 'completed'
    assert [int(r['step']) for r in frames] == list(range(count))
    assert all(int(r['stress_converged']) == 1 and int(r['resim_passes']) <= 1 and int(r['correction_status']) == 0 for r in frames)
    times = [float(r['complete_step_ms']) for r in frames]
    assert all(abs(t - sum(float(r[k]) for k in ('command_ms', 'physics_step_ms', 'completion_ms'))) < 1e-5 for t, r in zip(times, frames))
    broken = [int(r['bonds_broken']) for r in frames]
    assert sum(broken) == summary['broken_bonds']
    assert sum(int(r['resim_passes']) for r in frames) == summary['corrections']
    # Launch deadlines are quantized to the simulation step, not the wall clock.
    window = summary['launch_seconds']
    for r in launches:
        target = window * int(r['projectile']) / 256
        assert -1e-5 <= int(r['step']) / 60 - target < 1 / 60 + 1e-5
    peak = max(range(count), key=times.__getitem__)
    destruction = [i for i, n in enumerate(broken) if n]
    rolling = [sum(broken[i:i+60]) for i in range(count-59)]
    busiest = max(range(len(rolling)), key=rolling.__getitem__)
    peak_work = {k: int(frames[peak][k]) for k in ('bodies', 'awake_bodies', 'projectiles_active', 'logical_clusters', 'contacts_frame', 'stress_active_nodes', 'stress_active_bonds', 'stress_islands', 'stress_iterations', 'bonds_broken', 'resim_passes')}
    first_miss = next((i for i, t in enumerate(times) if t > 1000 / 60), None)
    per_second = []
    for begin in range(0, count, 60):
        end = min(begin+60, count)
        per_second.append(dict(start_seconds=begin/60, worst_ms=max(times[begin:end]),
            bonds_broken=sum(broken[begin:end]), awake_bodies_max=max(int(r['awake_bodies']) for r in frames[begin:end]),
            new_clusters_net=int(frames[end-1]['logical_clusters']) - (int(frames[begin-1]['logical_clusters']) if begin else 256),
            corrections=sum(int(r['resim_passes']) for r in frames[begin:end])))
    return dict(case=run['case'], run=run['name'], seconds=summary['seconds'], launch_window_seconds=window,
        first_launch_step=min(int(r['step']) for r in launches), last_launch_step=max(int(r['step']) for r in launches),
        mean_ms=statistics.mean(times), minimum_ms=min(times), worst_ms=times[peak], peak_step=peak,
        missed_60hz=sum(t>1000/60 for t in times), missed_8ms=sum(t>8 for t in times), frames=count,
        first_60hz_miss_step=first_miss, peak_work=peak_work, broken_bonds=sum(broken),
        new_clusters_net=int(frames[-1]['logical_clusters'])-256,
        destruction_steps=len(destruction), destruction_step_mean_ms=statistics.mean(times[i] for i in destruction) if destruction else None,
        busiest_1s_start=busiest/60, busiest_1s_bonds_broken=rolling[busiest],
        busiest_1s_worst_ms=max(times[busiest:busiest+60]),
        complete_simulation_realtime_fraction=summary['seconds']*1000/sum(times),
        initialization_ms=summary['initialization_ms'], per_second=per_second,
        launch_sha256=run['files']['native.launches.csv.gz'], frames_sha256=run['files']['native.frames.csv.gz'])


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('campaign', type=Path)
    parser.add_argument('--output', required=True, type=Path)
    args = parser.parse_args()
    manifest = json.loads(args.campaign.read_text())
    assert manifest['status'] == 'complete', 'Incomplete campaign cannot establish capacity'
    results = [analyze(args.campaign, r) for r in manifest['runs'] if r['mode'] == 'plain']
    assert results and all(r['exit_code'] == 0 for r in manifest['runs'])
    args.output.mkdir(parents=True, exist_ok=True)
    data = dict(schema=1, source_manifest_sha256=hashlib.sha256(args.campaign.read_bytes()).hexdigest(),
                source_manifest=str(args.campaign.resolve()), results=results)
    timing_path=args.output/'timing/report.json.gz'
    timing=json.loads(gzip.decompress(timing_path.read_bytes()))
    spec=importlib.util.spec_from_file_location('peak_accounting',Path(__file__).with_name('destruction-peak-opportunities.py'))
    accounting=importlib.util.module_from_spec(spec);spec.loader.exec_module(accounting)
    phase_rows=[]
    for capture in timing['phase_captures']:
        case=capture['case'];profile=capture['profile']
        observed=max((r for r in results if r['case']==case),key=lambda r:r['worst_ms'])
        phase_run=next(r for r in manifest['runs'] if r['case']==case and r['mode']=='phases')
        folder=args.campaign.parent/phase_run['name']
        phase_frames=rows(folder/'native.frames.csv.gz')
        accounting.rank(dict(profile=profile,frames=phase_frames,summary=json.loads((folder/'native.summary.json').read_text())))
        for step in sorted({82,observed['peak_step'],840}):
            groups={k:0.0 for k in accounting.GROUPS}
            for k,v in profile['wall_partition'][step].items():groups[accounting.group(k)]+=v
            phase_rows.append(dict(case=case,step=step,scope_ms=groups,cuda_stress_ms=profile['cuda_stages'][step]['stress'],
                bonds_broken=int(phase_frames[step]['bonds_broken']),awake_bodies=int(phase_frames[step]['awake_bodies']),
                active_stress_nodes=int(phase_frames[step]['stress_active_nodes']),active_stress_bonds=int(phase_frames[step]['stress_active_bonds'])))
    data['phase_samples']=phase_rows
    data['timing_report_sha256']=hashlib.sha256(timing_path.read_bytes()).hexdigest()
    (args.output/'capacity.json').write_text(json.dumps(data, indent=2)+'\n')
    text = ['# 💥 Active destruction capacity: 256-building launch scheduling', '',
        'Fixed scene: **256 buildings, 113,664 chunks, 229,376 bonds and 256 projectiles**. Each projectile targets a different building. Same masses, material laws, aerial launch generator, 1/60-second timestep and correction limit one. Sleeping remains disabled. Launch timing changes the interaction history, so this is a workload-capacity comparison, not an equal-work implementation speedup.', '',
        f'Each measured run covers **{results[0]["seconds"]:g} simulated seconds**. Separate warm-ups and phase captures are excluded from the table; every step of each untraced run is included, including insertion, first fracture and allocation peaks. Complete time covers commands, physics, destruction, correction and mandatory completion. Initialization, rendering and report generation are excluded. GPU process monitoring is retained in the campaign; clocks were observed, not locked.', '',
        '| Workload/run | Launch window s | Complete mean / min / max ms | Misses >16.67 ms / >8 ms | Bonds broken | Net new clusters | Peak bonds broken in 1 simulated second | Worst ms in that 1 s |',
        '|---|---:|---:|---:|---:|---:|---:|---:|']
    for r in results:
        text.append(f'| {r["run"]} | {r["launch_window_seconds"]:g} | {r["mean_ms"]:.2f} / {r["minimum_ms"]:.2f} / {r["worst_ms"]:.2f} | {r["missed_60hz"]} / {r["missed_8ms"]} of {r["frames"]} | {r["broken_bonds"]:,} | {r["new_clusters_net"]:,} | {r["busiest_1s_bonds_broken"]:,} | {r["busiest_1s_worst_ms"]:.2f} |')
    text += ['', '**Interpretation:** launches per second are input pressure, not destruction throughput. Broken bonds measure actual fracture events; net new clusters measure fragmentation, not detached chunk count. Neither alone captures stress iterations, collision density or rubble cost. A short passing interval is not a sustainable-capacity result.', '',
             '## Peak-step work', '',
             '| Run | Step / simulation s | Complete ms | Awake bodies | Contact loads | Active stress nodes / bonds | Stress islands / max iterations | Broken bonds / correction passes |',
             '|---|---:|---:|---:|---:|---:|---:|---:|']
    for r in results:
        w=r['peak_work']
        text.append(f'| {r["run"]} | {r["peak_step"]} / {r["peak_step"]/60:.3f} | {r["worst_ms"]:.2f} | {w["awake_bodies"]:,} | {w["contacts_frame"]:,} | {w["stress_active_nodes"]:,} / {w["stress_active_bonds"]:,} | {w["stress_islands"]:,} / {w["stress_iterations"]} | {w["bonds_broken"]} / {w["resim_passes"]} |')
    text += ['', 'Contact loads are the recorded contacts_frame counter, not unique collision pairs or solver rows. Stress topology counts do not represent per-iteration work; iteration count is the maximum component count, not a sum.', '', '## Capacity verdict', '']
    text[-3:]=[]  # Place phase evidence before the capacity verdict heading.
    text += ['', '## Separate instrumented phase samples', '',
        'These are separate replays at selected steps, not a decomposition of the exact untraced peak. Host elapsed groups include device waits; **GPU stress is nested inside stress/dependencies and must not be added again**. Step 82 is the first impact; later rows expose peak or post-impact costs.', '',
        '| Workload / step | Awake bodies | Active stress nodes / bonds | Bonds broken | CPU lifecycle + GPU ownership ms | Correction ms | Stress/dependencies ms | Nested GPU stress ms | Commit ms | Trial/other ms |',
        '|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|']
    for row in phase_rows:
        g=row['scope_ms']
        text.append(f'| {row["case"]} / {row["step"]} | {row["awake_bodies"]:,} | {row["active_stress_nodes"]:,} / {row["active_stress_bonds"]:,} | {row["bonds_broken"]} | {g["ownership"]:.2f} | {g["correction"]:.2f} | {g["stress"]:.2f} | {row["cuda_stress_ms"]:.2f} | {g["commit"]:.2f} | {g["trial"]:.2f} |')
    text += ['', 'The staggered peak shifts toward GPU stress and accumulated contacts. Even post-impact steps with no new fracture can still perform substantial stress work. Zero broken bonds does not prove that those solves can safely be skipped: changed contact loads, residual/convergence, supports and damage inputs need a validity test.', '', '## Capacity verdict', '']
    passing = [r['run'] for r in results if not r['missed_60hz']]
    text.append('No tested run passes every complete step at 60 Hz. A maximum sustainable real-time destruction rate has **not been established**.' if not passing else f'Short-screen runs passing every step at 60 Hz: {", ".join(passing)}. These require five 60-second runs and endurance before qualification.')
    text += ['', 'All captured runs must report convergence, no incomplete correction, at most one correction per step, complete launch schedules and consistent fracture totals. These telemetry checks do not replace trajectory, hole-retention, momentum or sanitizer qualification.', '', '## Evolution through each run', '']
    for r in results:
        text += [f'### {r["run"]}', '', '| Simulation second | Worst complete ms | Bonds broken | Net new clusters | Maximum awake bodies | Correction steps |', '|---|---:|---:|---:|---:|---:|']
        for b in r['per_second']:
            text.append(f'| {b["start_seconds"]:g}–{b["start_seconds"]+1:g} | {b["worst_ms"]:.2f} | {b["bonds_broken"]:,} | {b["new_clusters_net"]:,} | {b["awake_bodies_max"]:,} | {b["corrections"]} |')
        text.append('')
    text += ['Raw provenance and all per-second values: [capacity.json](capacity.json). Detailed separately instrumented phases: [timing report](timing/report.md).', '']
    (args.output/'capacity.md').write_text('\n'.join(text))
    print(args.output/'capacity.md')


if __name__ == '__main__':
    main()
