#!/usr/bin/env python3
"""Compare optional accepted stress observations; never a performance/quality gate."""
import argparse
import csv
import gzip
import hashlib
import json
import math
from pathlib import Path


def read(path, kind, frames, count):
    file = path / f'native.{kind}.csv.gz'
    with gzip.open(file, 'rt') as stream:
        rows = list(csv.DictReader(stream))
    if len(rows) != frames * count:
        raise ValueError(f'Incomplete {kind} trace: {path}')
    identity = 'bond' if kind == 'bonds' else 'chunk'
    for index, row in enumerate(rows):
        if int(row['step']) != index // count or int(row[identity]) != index % count:
            raise ValueError(f'Missing/duplicate {kind} identity: {path}')
        if not all(math.isfinite(float(value)) for value in row.values()):
            raise ValueError(f'Nonfinite {kind} observation: {path}')
    return rows, hashlib.sha256(file.read_bytes()).hexdigest()


def compare(reference, candidate, identity):
    first, maximum, changed = {}, {}, {}
    for a, b in zip(reference, candidate):
        for key in a.keys() - {'step', identity}:
            x, y = float(a[key]), float(b[key])
            if x != y:
                first.setdefault(key, dict(step=int(a['step']), id=int(a[identity]), reference=x, actual=y))
                maximum[key] = max(maximum.get(key, 0), abs(x-y))
                changed[key] = changed.get(key, 0) + 1
    return dict(first_differences=first, maximum_absolute_differences=maximum, changed_values=changed)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('captures', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    names = ['1-baseline', '2-candidate', '3-candidate', '4-baseline']
    data, receipts = {}, {}
    for name in names:
        path = args.captures / name
        summary = json.loads((path / 'native.summary.json').read_text())
        if (summary['frames'], summary['chunks'], summary['bonds'], summary['projectiles'], summary['direct_gpu_mode'], summary['sleeping']) != (128, 444, 896, 1, False, True):
            raise ValueError(f'Wrong diagnostic fixture: {path}')
        data[name], receipts[name] = {}, {}
        for kind, count in [('bonds', 896), ('loads', 444)]:
            data[name][kind], receipts[name][kind] = read(path, kind, 128, count)
        receipts[name]['capture'] = json.loads((path / 'capture.json').read_text())
        receipts[name]['quality'] = json.loads((path / 'quality.json').read_text())
    comparisons = []
    for name in names[1:]:
        for kind in ['loads', 'bonds']:
            result = compare(data[names[0]][kind], data[name][kind], 'bond' if kind == 'bonds' else 'chunk')
            comparisons.append(dict(reference=names[0], candidate=name, kind=kind, **result))
    result = dict(schema=1, performance_qualification=False, frames=128, chunks=444, bonds=896,
                  projectiles=1, correction_limit=1, comparisons=comparisons, receipts=receipts)
    args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
    for item in comparisons:
        print(item['candidate'], item['kind'], 'accepted health first difference:',
              item['first_differences'].get('accepted_health'), 'changed fields:', sorted(item['changed_values']))


if __name__ == '__main__':
    main()
