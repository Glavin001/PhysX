#!/usr/bin/env python3
"""Measured native trial/replay CPU boundaries; never equate waits with copy cost."""
import argparse
from collections import defaultdict
import csv
import gzip
import hashlib
import json
import math
from pathlib import Path

PREFIX = 'GpuDestruction.'
SCOPES = {
    'bodyDmaWait': 'Wait for GPU physics and readback completion',
    'bodyStatusWork': 'CPU wake/sleep body-status worker tasks',
    'queryMembership': 'CPU query-tree membership changes',
    'sleepCommit': 'Commit sleep transitions to GPU (CPU wall, includes waits)',
    'activityCheckpoint': 'CPU activity checkpoint',
    'activityRestore': 'CPU activity rollback before replay',
}


def union_ms(intervals):
    """Elapsed union, so overlapping workers are not counted twice."""
    total = 0
    end = None
    for a, b in sorted(intervals):
        assert b >= a
        total += max(0, b - max(a, end if end is not None else a))
        end = max(b, end if end is not None else b)
    return total / 1e6


def read_rows(path):
    with (path.open() if path.exists() else gzip.open(str(path) + '.gz', 'rt')) as stream:
        yield from csv.DictReader(stream)


def report(root):
    manifest = json.loads((root / 'capture.json').read_text())
    assert manifest['status'] == 'complete'
    d = root / 'simulation'
    for name, digest in manifest['files'].items():
        assert hashlib.sha256((d / name).read_bytes()).hexdigest() == digest
    summary = json.loads((d / 'native.summary.json').read_text())
    frames = list(read_rows(d / 'native.frames.csv'))
    assert summary['status'] == 'completed' and len(frames) == summary['frames']
    scopes = defaultdict(lambda: defaultdict(list))
    replay = {}
    for row in read_rows(d / 'native.phases.csv'):
        name = row['phase'].removeprefix(PREFIX)
        if name != 'correctedCollisionSolve' and name.removeprefix('task.') not in SCOPES:
            continue
        step = int(row['step'])
        assert 0 <= step < len(frames) and row['accepted_step'] == '1'
        a, b = int(row['start_ns']), int(row['end_ns'])
        assert b >= a
        cpu = float(row['thread_cpu_ms'])
        if name == 'correctedCollisionSolve':
            # Cross-thread wall scopes do not have a meaningful CPU clock.
            assert step not in replay
            replay[step] = (a, b)
        else:
            assert math.isfinite(cpu) and cpu >= 0, 'worker CPU clock unavailable'
            scopes[step][name.removeprefix('task.')].append((a, b, cpu))
    for i, f in enumerate(frames):
        assert int(f['stress_passes']) == 1 + int(f['resim_passes']) <= 2
        assert f['stress_converged'] == '1' and f['correction_status'] == '0'
        assert len(scopes[i]['bodyDmaWait']) == int(f['stress_passes']), 'missing per-physics-pass wait'
    peak = max(range(len(frames)), key=lambda i: float(frames[i]['complete_step_ms']))
    replay_peak = max(replay, key=lambda i: replay[i][1] - replay[i][0])
    wait_peak = max(scopes, key=lambda i: union_ms([(a,b) for a,b,_ in scopes[i]['bodyDmaWait']]))
    output = dict(workload=summary, selections={})
    lines = ['# CPU synchronization around native correction', '',
             f"256 buildings; {summary['chunks']:,} chunks, {summary['bonds']:,} bonds, {summary['projectiles']} projectiles; "
             f"one {summary['seconds']}-second diagnostic / {len(frames)} steps. Direct GPU OFF, sleeping ON, correction limit one, stress evaluation limit two.", '',
             'No physical behavior is changed by these profiling scopes. Times include instrumentation and are not an untraced performance qualification.', '',
             'A GPU-completion wait includes unfinished physics, transfer, and scheduling; it is not removable CPU work or a DMA-only measurement. CPU-clock time can include busy waiting. Worker wall intervals use their union, not their sum. Rows can overlap GPU work and each other; do not add them to replay time.', '']
    for label, i in [('Complete-step peak', peak), ('Largest replay', replay_peak), ('Largest combined body-readback wait', wait_peak)]:
        f = frames[i]
        replay_interval = replay.get(i)
        entries = []
        lines += [f'## {label}: step {i}', '',
                  f"{f['bodies']} bodies / {f['awake_bodies']} awake; complete step {float(f['complete_step_ms']):.3f} ms; "
                  f"replay {((replay_interval[1]-replay_interval[0])/1e6 if replay_interval else 0):.3f} ms.", '',
                  '| Responsibility | Trial/before replay wall ms | Inside replay wall ms | After replay wall ms | CPU time, whole tick (ms) | Calls |',
                  '|---|---:|---:|---:|---:|---:|']
        for name, description in SCOPES.items():
            before, during, after = [], [], []
            for a, b, cpu in scopes[i][name]:
                if replay_interval and a >= replay_interval[0] and b <= replay_interval[1]:
                    during.append((a,b))
                elif replay_interval and a >= replay_interval[1]:
                    after.append((a,b))
                else:
                    assert not replay_interval or b <= replay_interval[0], 'scope unexpectedly crossing replay boundary'
                    before.append((a,b))
            entry = dict(scope=name, before_ms=union_ms(before), replay_ms=union_ms(during),
                         after_ms=union_ms(after), cpu_ms=sum(cpu for _,_,cpu in scopes[i][name]), calls=len(scopes[i][name]))
            entries.append(entry)
            lines.append(f"| {description} | {entry['before_ms']:.6f} | {entry['replay_ms']:.6f} | {entry['after_ms']:.6f} | {entry['cpu_ms']:.6f} | {entry['calls']} |")
        output['selections'][label] = dict(step=i, frame=f, measurements=entries)
        lines += ['']
    lines += ['The current body-status workers apply simulation sleep/readiness, not just user-facing mirrors. Deferring them requires provisional activity semantics. Query membership is observation work, but freeze/unfreeze deltas must survive trial rejection. Public scene publication already occurs once after acceptance.', '']
    (root / 'cpu-sync.md').write_text('\n'.join(lines))
    (root / 'cpu-sync.json').write_text(json.dumps(output, indent=2) + '\n')
    print(root / 'cpu-sync.md')


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture', type=Path)
    report(p.parse_args().capture)
