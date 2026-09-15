#!/usr/bin/env python3
"""Recompute selected-control tables from all saved unprofiled A0/A1 samples."""
import csv
import hashlib
import json
import statistics
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[1]


def main():
    source = json.loads((HERE / 'evidence/selected-control-full52-source.json').read_text())
    manifest = {r['scenario']: r for r in json.loads((HERE / 'evidence/scenario-manifest.json').read_text())['scenarios']}
    rows, samples, provenance = [], [], []
    for case in source['scenarios']:
        name = case['scenario']
        row = {'scenario': name, 'purpose': manifest[name].get('purpose'), 'group': manifest[name]['group']}
        for arm in ['A0', 'A1']:
            folder = Path(case['raw'][arm])
            path = folder / 'replay.json'
            replay = json.loads(path.read_text())
            receipt = json.loads((folder / 'receipt.json').read_text())
            observation = json.loads((folder / 'observation-0.json').read_text())
            assert receipt['status'] == 'complete' and not receipt.get('profiler')
            assert replay['steps_per_restore'] == 1
            raw = replay['samples']
            times = [r['complete_step_ms'] for r in raw]
            assert len(times) == 20 and all(r['repeatability_passed'] for r in raw)
            assert all(abs(r['complete_step_ms'] - sum(r[k] for k in ['command_ms', 'simulate_fetch_ms', 'completion_ms'])) < 0.00001 for r in raw)
            stats = dict(n=len(times), mean_ms=statistics.mean(times), max_ms=max(times), min_ms=min(times),
                         median_ms=statistics.median(times), sd_ms=statistics.stdev(times),
                         misses_60hz=sum(t > 1000/60 for t in times), first_tick_ms=times[0],
                         context_setup_ms=replay['context_setup_ms'], restore_mean_ms=statistics.mean(r['restore_ms'] for r in raw),
                         stages_ms={k: statistics.mean(r[k] for r in raw) for k in ['command_ms', 'simulate_fetch_ms', 'completion_ms']})
            for key in ['mean_ms', 'max_ms', 'sd_ms']:
                assert abs(stats[key] - case[arm][key]) < 1e-8
            assert stats['misses_60hz'] == case[arm]['over_60hz']
            row[arm] = stats
            row['representative_work'] = {k:raw[0][k] for k in ['stress_iterations', 'broken_bonds', 'correction_passes', 'stress_passes', 'output_clusters', 'stress_islands', 'stress_active_nodes', 'stress_active_bonds', 'normal_contacts', 'friction_anchors']}
            counts = {a['name']: a['count'] for a in observation.get('arrays', [])}
            row['chunks'] = counts.get('chunk-clusters', manifest[name].get('chunks')) if observation['destructive'] else 0
            row['bonds'] = counts.get('health') if observation['destructive'] else 0
            provenance.append(dict(scenario=name, arm=arm, path=str(path), sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                                   receipt_sha256=hashlib.sha256((folder/'receipt.json').read_bytes()).hexdigest(), binary_sha256=receipt['binary_sha256'], modules=receipt.get('modules')))
            samples.extend(dict(scenario=name, arm=arm, **r) for r in raw)
        rows.append(row)
    assert len(rows) == 52 and len(samples) == 2080
    (HERE / 'data').mkdir(exist_ok=True)
    with (HERE/'data/unprofiled-samples.csv').open('w') as f:
        writer = csv.DictWriter(f, fieldnames=list(samples[0])); writer.writeheader(); writer.writerows(samples)
    summary = dict(scope='Unprofiled selected controls from N29b A0/B/A1 campaign; rejected B excluded. A0/A1 kept separate. First-use samples included; restore and validation excluded.',
                   scenarios=rows, total_samples=len(samples), misses_60hz=sum(r['complete_step_ms']>1000/60 for r in samples),
                   means_over_60hz=sum((r['A0']['mean_ms']+r['A1']['mean_ms'])/2>1000/60 for r in rows),
                   sources=provenance)
    (HERE/'data/unprofiled-baseline.json').write_text(json.dumps(summary,indent=2)+'\n')
    table=['# All 52 selected-control scenarios', '', 'Unprofiled A0 and A1: 20 independent restored ticks each, all samples retained. Means and observed maxima are separate; maxima are not worst-case bounds. Each restore reconstructs disposable execution state; the source cold/warm label describes physical history. No confidence interval is inferred from these two run groups.', '',
           '| Scenario | Chunks / bonds | Mean A0 / A1 ms | Max A0 / A1 ms | SD A0 / A1 ms | 60 Hz misses A0 / A1 | Integrated A0 / A1 ms | Correction / stress passes |',
           '|---|---:|---:|---:|---:|---:|---:|---:|']
    for r in rows:
        a,b,w=r['A0'],r['A1'],r['representative_work']
        table.append(f"| {r['scenario']} | {r['chunks']} / {r['bonds']} | {a['mean_ms']:.3f} / {b['mean_ms']:.3f} | {a['max_ms']:.3f} / {b['max_ms']:.3f} | {a['sd_ms']:.3f} / {b['sd_ms']:.3f} | {a['misses_60hz']}/20, {b['misses_60hz']}/20 | {a['stages_ms']['simulate_fetch_ms']:.3f} / {b['stages_ms']['simulate_fetch_ms']:.3f} | {w['correction_passes']} / {w['stress_passes']} |")
    table += ['', 'Chunk/bond counts describe destruction assets; zero counts in the flying/resting/sliding controls do not mean the rigid-body scene is empty. Integrated means include PhysX, CPU work, stress, fracture and correction. Command/completion means, initialization, restore costs and all physical work counts are retained in the JSON and raw CSV. Restore, validation and teardown are excluded from full-step time.', '', f"{summary['means_over_60hz']}/52 pooled scenario means exceed 60 Hz; {summary['misses_60hz']}/{len(samples)} individual ticks miss. A0/A1 drift remains visible above. No optimization gain is claimed."]
    (HERE/'all-scenarios.md').write_text('\n'.join(table)+'\n')
    warm_source=ROOT/'qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n29b-warm.json'
    warm= json.loads(warm_source.read_text())
    controls=[r for r in warm['runs'] if r['arm']=='A']
    warm_samples=[];warm_rows=[]
    for r in controls:
        folder=Path(r['command'][2])
        path=folder/'native/native.frames.csv'
        assert hashlib.sha256(path.read_bytes()).hexdigest()==r['frames_sha256']
        frames=list(csv.DictReader(path.open()));assert len(frames)==600
        times=[float(f['complete_step_ms']) for f in frames]
        assert abs(statistics.mean(times)-r['mean_ms'])<1e-8
        assert sum(t>1000/60 for t in times)==r['misses']['60hz']
        warm_rows.append(dict(name=r['name'],n=600,mean_ms=statistics.mean(times),max_ms=max(times),sd_ms=statistics.stdev(times),misses_60hz=r['misses']['60hz'],initialization_ms=r['initialization_ms'],stages_ms=r['stages_ms'],source=str(path),sha256=r['frames_sha256']))
        warm_samples.extend(dict(run=r['name'],**f) for f in frames)
    assert len(warm_samples)==4800
    (HERE/'data/continuous-controls.json').write_text(json.dumps(dict(scope='Four independent runs per idle/heavy regime, 600 ticks each; no profiler. Consecutive frames are not independent runs. Work/iteration history qualification does not prove full trajectory equivalence.',runs=warm_rows),indent=2)+'\n')
    with (HERE/'data/continuous-control-frames.csv').open('w') as f:
        writer=csv.DictWriter(f,fieldnames=list(warm_samples[0]));writer.writeheader();writer.writerows(warm_samples)
    lines=['# Continuous selected-control baseline','', 'Unprofiled, ordinary API, sleeping enabled, 256 buildings / 113,664 chunks / 229,376 bonds; 256 projectiles in heavy. Four runs per regime, all ticks retained. Restore is not part of this workload. This is separate from the restored snapshot cohort.', '', '| Run | Mean / max ms | SD ms | 60 Hz misses | Initialization ms | Command / integrated / completion ms |', '|---|---:|---:|---:|---:|---:|']
    for r in warm_rows:
        st=r['stages_ms'];lines.append(f"| {r['name']} | {r['mean_ms']:.3f} / {r['max_ms']:.3f} | {r['sd_ms']:.3f} | {r['misses_60hz']}/600 | {r['initialization_ms']:.3f} | {st['command_ms']:.4f} / {st['physics_step_ms']:.3f} / {st['completion_ms']:.3f} |")
    lines+=['','Exact work/convergence histories pass the historical comparison. Full orientation/velocity/material trajectory qualification remains a separate requirement. No gain is claimed. [All frames](data/continuous-control-frames.csv).']
    (HERE/'continuous-controls.md').write_text('\n'.join(lines)+'\n')
    print(json.dumps({k:summary[k] for k in ['total_samples','misses_60hz','means_over_60hz']}))


if __name__ == '__main__':
    main()
