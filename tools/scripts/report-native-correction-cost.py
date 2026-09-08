#!/usr/bin/env python3
"""GPU rewind/install intervals versus the internal physics replay wall interval."""
import argparse
from collections import defaultdict
import csv
import gzip
import hashlib
import json
import math
from pathlib import Path

NAMES = {'rewindState': 'Restore GPU checkpoint', 'installFragments': 'Install fragment motion on GPU',
         'installOwners': 'Install shape ownership on GPU', 'finalSplitState': 'Copy current state for final splits (no rewind)',
         'finalSplitFragments': 'Install final-split motion on GPU', 'finalSplitOwners': 'Install final-split ownership on GPU'}

def rows(path):
    with (path.open() if path.exists() else gzip.open(str(path) + '.gz', 'rt')) as stream:
        return list(csv.DictReader(stream))

def report(root):
    manifest = json.loads((root / 'capture.json').read_text()); assert manifest['status'] == 'complete'
    d = root / 'simulation'
    for name, digest in manifest['files'].items():
        assert hashlib.sha256((d / name).read_bytes()).hexdigest() == digest
    summary = json.loads((d / 'native.summary.json').read_text()); frames = rows(d / 'native.frames.csv')
    assert summary['status'] == 'completed' and len(frames) == summary['frames']
    gpu = defaultdict(dict); host = defaultdict(lambda: defaultdict(float))
    for r in rows(d / 'native.phases.csv.device.csv'):
        name = r['phase'].removeprefix('GpuDestruction.cuda.')
        if name not in NAMES: continue
        i = int(r['step']); value = float(r['cuda_elapsed_ms'])
        assert r['accepted_step'] == '1' and 0 <= i < len(frames) and math.isfinite(value) and value >= 0
        assert name not in gpu[i]; gpu[i][name] = value
    for r in rows(d / 'native.phases.csv'):
        i = int(r['step']); assert r['accepted_step'] == '1' and 0 <= i < len(frames)
        host[i][r['phase'].removeprefix('GpuDestruction.')] += float(r['host_wall_ms'])
    first = {'rewindState', 'installFragments', 'installOwners'}
    last = set(NAMES) - first
    corrected = []
    for i, f in enumerate(frames):
        assert f['stress_converged'] == '1' and f['correction_status'] == '0'
        assert int(f['stress_passes']) == 1 + int(f['resim_passes']) <= 2
        if int(f['resim_passes']):
            assert first <= gpu[i].keys()
            assert not (last & gpu[i].keys()) or last <= gpu[i].keys()
            corrected.append(i)
        else: assert not gpu[i]
    assert corrected
    peak = max(range(len(frames)), key=lambda i: float(frames[i]['complete_step_ms']))
    replay_peak = max(corrected, key=lambda i: host[i]['correctedCollisionSolve'])
    result = dict(workload=summary, complete_peak_step=peak, replay_peak_step=replay_peak, selections={})
    text = ['# GPU rewind cost versus physics replay', '',
            f"256 buildings; {summary['chunks']:,} chunks, {summary['bonds']:,} bonds, {summary['projectiles']} projectiles; "
            f"one {summary['seconds']}-second instrumented run / {len(frames)} steps. Direct GPU OFF, sleeping ON, max two physics and two stress evaluations. Every step retained.", '',
            'CUDA event intervals are read at existing acceptance waits. They include stream scheduling gaps, not just kernel instructions. '
            'The CPU replay interval includes scheduling, collision/constraint work, GPU physics and dependencies. GPU restore/install can overlap its start; do not add or blindly subtract these columns.', '']
    for label, i in [('Complete-step peak', peak), ('Largest physics replay', replay_peak)]:
        f = frames[i]; result['selections'][label] = dict(frame=f, gpu=gpu[i], host=dict(host[i]))
        text += [f"## {label}: step {i}", '',
                 f"{f['bodies']} bodies, {f['awake_bodies']} awake; complete step {float(f['complete_step_ms']):.3f} ms.", '',
                 '| Operation | Measured ms |', '|---|---:|',
                 f"| Physics replay — CPU/GPU wall interval | {host[i]['correctedCollisionSolve']:.6f} |",
                 f"| Restore/install — CPU submission (both evaluations) | {host[i]['restoreInstall']:.6f} |"]
        text += [f'| {description} — CUDA interval | {gpu[i].get(name, 0):.6f} |' for name, description in NAMES.items()]
        text += [f"| First-pass GPU restore/install interval sum | {sum(gpu[i].get(k, 0) for k in first):.6f} |", '']
    text += ['This is diagnostic timing, not an untraced peak qualification. The replay interval is not a pure GPU rigid-solver kernel measurement.', '']
    (root / 'report.md').write_text('\n'.join(text))
    (root / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    print(root / 'report.md')

if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__); p.add_argument('capture', type=Path)
    report(p.parse_args().capture)
