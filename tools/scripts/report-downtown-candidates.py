#!/usr/bin/env python3
"""Compare untraced complete-step screens; retain startup and physical differences."""
import argparse
import gzip
import json
import statistics
from pathlib import Path


def generate(baseline, candidates, output):
    output.mkdir(parents=True, exist_ok=True)
    captures = [('deployed', baseline, 'baseline')]
    captures += [(p.parent.name + '/' + p.name, p, 'candidate') for p in candidates]
    decisions = json.loads((output / 'decisions.json').read_text()) if (output / 'decisions.json').exists() else {}
    reference = {}
    evidence = {}
    lines = [
        '# Downtown destruction candidate screens', '',
        'RTX 4090; 27 buildings, 24,105 chunks, 74,543 bonds. '
        'Direct GPU API off, native sleeping on, dt 1/60, at most one correction '
        'and two stress/fracture evaluations per tick. Each row is one 600-step '
        '(10 simulated seconds) run: zero projectiles for pristine idle, three '
        'recorded projectiles for destruction.', '',
        'Complete-step timer includes physical commands, physics, stress, '
        'fracture/correction, mandatory completion and game observation staging. '
        'Asset preparation, rendering, network encoding and report generation '
        'are excluded. First-step and all later spikes are retained.', '',
        '| Implementation / regime | Decision | Mean ms | Median ms | First step ms | All-step peak ms | Destruction/aftermath peak ms | New-fracture peak ms | Missed 60 Hz / 600 |',
        '|---|---|---:|---:|---:|---:|---:|---:|---:|',
    ]
    for label, root, prefix in captures:
        for regime in ['idle', 'shots']:
            path = root / (prefix + '-' + regime)
            report, frames, commands = [json.loads((path / (name + '.json')).read_text())
                                        for name in ['report', 'steps', 'commands']]
            assert report['status'] == 'complete' and not report['instrumented']
            assert report['chunks'] == 24105 and report['bonds'] == 74543
            assert len(frames) == report['steps'] == 600
            assert [r['tick'] for r in frames] == list(range(600))
            assert all(r['native_corrections'] <= 1 and
                       r['native_counts']['native_stress_passes'] <= 2 for r in frames)
            if regime == 'idle':
                assert not commands and all(r['broken_bonds'] == r['fragment_bodies'] == 0 for r in frames)
            else:
                assert report['projectiles'] == 3 and frames[-1]['broken_bonds'] > 0
            if label == 'deployed':
                reference[regime] = (report, frames, commands)
            old_report, old_frames, old_commands = reference[regime]
            assert commands == old_commands
            for key in ['source_asset', 'manifest_hash', 'chunks', 'bonds', 'steps', 'projectiles', 'direct_gpu_api', 'sleeping', 'max_correction', 'max_stress_passes', 'timestep_seconds', 'iterations_max', 'tolerance', 'timing_scope']:
                assert report.get(key) == old_report.get(key), key
            values = [r['complete_step_ms'] for r in frames]
            loaded = [r for r in frames if commands and r['tick'] >= commands[0]['tick']]
            fractured = [r for i, r in enumerate(frames) if r['broken_bonds'] > (frames[i-1]['broken_bonds'] if i else 0)]
            def peak(rows):
                return max(rows, key=lambda r: r['complete_step_ms']) if rows else None
            stats = dict(mean=statistics.mean(values), median=statistics.median(values), first=values[0],
                         peak=peak(frames), loaded_peak=peak(loaded), fracture_peak=peak(fractured),
                         missed_60hz=sum(v > 1000/60 for v in values), missed_8ms=sum(v > 8 for v in values))
            differences = {k: [i for i, (a, b) in enumerate(zip(old_frames, frames)) if a[k] != b[k]]
                           for k in ['broken_bonds', 'fragment_bodies', 'awake_fragment_bodies', 'native_corrections']}
            key = label + '-' + regime
            evidence[key] = dict(stats=stats, report=report, final=frames[-1], counter_differences=differences)
            tag = key.replace('/', '-')
            for name in ['steps', 'commands', 'report']:
                data = (path / (name + '.json')).read_bytes()
                archive = output / (tag + '-' + name + '.json.gz')
                if archive.exists():
                    assert gzip.decompress(archive.read_bytes()) == data
                else:
                    archive.write_bytes(gzip.compress(data, mtime=0))
            def ms(row):
                return f"{row['complete_step_ms']:.3f}" if row else '—'
            lines.append(f"| {label} / {regime} | {decisions.get(root.name, 'reference')} | {stats['mean']:.3f} | {stats['median']:.3f} | "
                         f"{stats['first']:.3f} | {ms(stats['peak'])} | {ms(stats['loaded_peak'])} | "
                         f"{ms(stats['fracture_peak'])} | {stats['missed_60hz']} |")
    lines += ['', 'Destruction/aftermath starts at the first recorded command and includes settling. '
              'New-fracture peaks require an increase in broken bonds. Neither replaces the all-step peak.', '',
              'These are short screens, not five-trial or endurance qualification. '
              'Physical counter differences and peak workload details are retained in '
              '[analysis.json](analysis.json); equal final counts do not prove identical trajectories. '
              'The independent wall and hierarchy quality checks are recorded separately.', '',
              'The deployed comparison arm is the prior embedded runtime. '
              'This report does not establish superiority over the external Vibe-land/Blast baseline.', '']
    (output / 'analysis.json').write_text(json.dumps(evidence, indent=2))
    (output / 'report.md').write_text('\n'.join(lines))
    print(output / 'report.md')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('baseline', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('candidates', nargs='+', type=Path)
    args = parser.parse_args()
    generate(args.baseline, args.candidates, args.output)
