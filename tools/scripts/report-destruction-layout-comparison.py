#!/usr/bin/env python3
"""Compare named implementations on identical recorded simulation commands.

The first capture is the baseline. Reuses validated complete-step measurements;
no simulation is executed and no measured peak is discarded.
"""
import argparse
import gzip
import importlib.util
import json
from pathlib import Path

spec = importlib.util.spec_from_file_location('scaling', Path(__file__).with_name('report-destruction-scaling.py'))
s = importlib.util.module_from_spec(spec)
spec.loader.exec_module(s)
t = s.t


def commands(manifest):
    result = []
    for run in manifest['runs']:
        if run['mode'] != 'plain':
            continue
        command = list(run['command'][1:])
        index = command.index('--output')
        del command[index:index + 2]
        result.append(command)
    return result


def render(named, output, decision):
    manifests = [json.loads((path / 'campaign.json').read_text()) for _, path in named]
    reference = commands(manifests[0])
    for manifest in manifests:
        t.require(manifest['status'] == 'complete', 'Incomplete capture')
        t.require(commands(manifest) == reference,
                  'Cannot compare different recorded commands, durations, or repetition counts')
    captures = [s.collect(path) for _, path in named]
    t.require(all(len(capture['cases']) == 1 for capture in captures), 'Select one workload per capture')
    cases = [capture['cases'][0] for capture in captures]
    base = cases[0]
    doc = t.Document()
    doc.title('🧪 Destruction implementation comparison', 1)
    doc.text(f"Identical workload: {base['buildings']} buildings, {base['chunks']} chunks, "
             f"{base['bonds']} bonds, {base['projectiles']} projectile(s), "
             f"{base['trials']} × {base['seconds']} simulated seconds per implementation. "
             f"Timestep 1/60 second; correction limit one; sleeping {'enabled' if base['sleeping'] else 'disabled'}.")
    doc.text('Complete-advance timing includes commands, physics, stress/destruction, correction and mandatory completion. '
             'Initialization, rendering and reporting are excluded. Every measured step is retained. '
             'Run counts and durations are shown above. This comparison does not establish full physical or lifecycle qualification.')
    rows = []
    for (label, _), case in zip(named, cases):
        metric = case['metrics']
        rows.append([label, t.fmt(metric['min']), t.fmt(metric['mean']), t.fmt(metric['p95']),
                     t.fmt(metric['p99']), t.fmt(metric['max']), case['missed_8ms'],
                     f"{100 * (metric['mean'] / base['metrics']['mean'] - 1):+.2f}%",
                     case['population_peaks']['logical_clusters'],
                     'Match' if case['frozen_wall_counters_match'] else 'Not established'])
    doc.table(['Implementation', 'Min ms', 'Mean ms', 'p95 ms', 'p99 ms', 'Worst ms',
               '>8 ms steps', 'Mean change', 'Peak clusters', 'Frozen wall counters'], rows)
    doc.text('Matching counters are narrower evidence than matching trajectories, exact bond identities or physical invariants. '
             'See the separate physical and motion audits before treating an implementation as qualified. '
             'Timing differences do not by themselves identify an SM, cache or memory-bandwidth bottleneck.')
    if decision:
        doc.text(decision)
    doc.title('Reproduce and inspect')
    doc.table(['Implementation', 'Capture', 'Manifest SHA-256'],
              [[label, str(path.resolve()), capture['manifest_sha256']]
               for (label, path), capture in zip(named, captures)])
    doc.save(output)
    with (output / 'report.json.gz').open('wb') as raw:
        with gzip.GzipFile(filename='', fileobj=raw, mode='wb', mtime=0) as out:
            out.write((json.dumps({'schema': 1, 'reporter_sha256': t.sha(Path(__file__)),
                                  'labels': [label for label, _ in named], 'captures': captures,
                                  'decision': decision}, indent=2, sort_keys=True) + '\n').encode())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('captures', nargs='+', help='LABEL=CAPTURE; baseline first')
    parser.add_argument('--output', required=True, type=Path)
    parser.add_argument('--decision', default='')
    args = parser.parse_args()
    named = []
    for value in args.captures:
        label, separator, path = value.partition('=')
        t.require(bool(label and separator and path), 'Use LABEL=CAPTURE')
        named.append((label, Path(path)))
    t.require(len(named) >= 2, 'Provide a baseline and at least one candidate')
    render(named, args.output, args.decision)
    print(args.output / 'report.html')


if __name__ == '__main__':
    main()
