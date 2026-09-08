#!/usr/bin/env python3
"""Validate and report measured native committed-publication work, preserving peaks."""
import argparse
import importlib.util
import json
import statistics
from pathlib import Path


def check_rows(report, rows):
    chunks, bonds = report['chunks'], report['bonds']
    total_chunks = total_bonds = total_bytes = 0
    previous = 0
    for i, row in enumerate(rows):
        c = row['native_counts']
        changed, broken, transferred = [c[k] for k in [
            'native_topology_observed_chunks', 'native_topology_observed_bonds',
            'native_topology_observation_bytes']]
        assert all(v == int(v) and v >= 0 for v in [changed, broken, transferred])
        assert changed <= chunks and broken <= bonds, 'publication exceeds capacity'
        assert broken == row['broken_bonds'] - previous, 'missing/duplicate bond publication'
        assert i or changed == chunks, 'missing initial full snapshot'
        # ABI v15: 40-byte status, 24-byte chunk records and 4-byte bond indices.
        expected = 40 + 24 * changed + 4 * broken if i == 0 or broken else 0
        assert transferred == expected, 'publication byte accounting mismatch'
        total_chunks += int(changed)
        total_bonds += int(broken)
        total_bytes += int(transferred)
        previous = row['broken_bonds']
    return dict(observed_chunks=total_chunks, observed_bonds=total_bonds,
                device_to_host_bytes=total_bytes)


def generate(paths, output):
    spec = importlib.util.spec_from_file_location('consumer_compare',
        Path(__file__).with_name('compare-vibe-consumer-bench.py'))
    compare = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(compare)
    evidence = []
    text = ['# Native committed publication', '',
        'RTX 4090; Direct GPU API off, sleeping on, dt 1/60, correction ≤1 and stress evaluations ≤2. '
        'Each row retains every measured complete simulation step. The timer includes commands, physics, '
        'stress, correction, accepted events and game snapshot staging; excludes initialization, rendering, '
        'network encoding and report/audit work. First-step initialization performed inside advance remains measured.', '',
        '| Capture | Buildings / chunks / bonds | Projectiles / steps | Complete mean / peak ms | Impact + aftermath peak ms | CPU event/snapshot mean / peak ms | GPU-selected chunks read by CPU, total | Readback MiB, total |',
        '|---|---|---|---:|---:|---:|---:|---:|']
    for path in paths:
        run = compare.load(path)
        r, rows = run['report'], run['steps']
        counts = check_rows(r, rows)
        phases = r['phases_ms']
        scope = phases['game_observation_events_ms']
        total = phases['complete_step_ms']
        loaded = run['loaded_peak']
        text.append(f"| {path.name} | {r['buildings']} / {r['chunks']:,} / {r['bonds']:,} | "
                    f"{r['projectiles']} / {r['steps']} | {total['mean']:.3f} / {total['max']:.3f} | "
                    f"{loaded['complete_step_ms'] if loaded else 0:.3f} | {scope['mean']:.3f} / {scope['max']:.3f} | "
                    f"{counts['observed_chunks']:,} | {counts['device_to_host_bytes']/1048576:.3f} |")
        evidence.append(dict(path=str(path),counts=counts,peak=run['peak'],loaded_peak=loaded,
                             report=r,raw_path=str(path/'steps.json')))
    text += ['', 'A zero impact peak means no projectile commands. CPU event/snapshot time includes the '
        'explicit GPU readback and other game observation processing; it is not GPU kernel time. '
        'The byte counter covers topology publication only, not all simulation transfers. '
        'Readback totals include the initial full snapshot. Quiet ticks read no topology delta.', '',
        'Publication is GPU-generated and compacted. CPU consumes changed group definitions; the renderer '
        'or another device consumer can instead use the ordered device view. The CPU compatibility actor '
        'creation and ordinary query mirror remain separate unfinished architecture work.', '',
        'These short screens establish neither endurance nor every-step 60 Hz nor superiority over the '
        'historical user-land backend. Peak workload details and source paths are in [publication.json](publication.json).', '']
    output.mkdir(parents=True, exist_ok=True)
    (output/'publication.json').write_text(json.dumps(evidence,indent=2))
    (output/'publication.md').write_text('\n'.join(text))


if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--captures',type=Path,nargs='+',required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args();generate(a.captures,a.output)
