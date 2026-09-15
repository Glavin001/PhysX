#!/usr/bin/env python3
"""Verify every anchored output of the uniform current-operator batch."""
import argparse
import importlib.util
import json
from pathlib import Path
import hashlib
import numpy as np
from scipy.sparse.linalg import spsolve

spec = importlib.util.spec_from_file_location('batch', Path(__file__).with_name('prepare-batch.py'))
batch = importlib.util.module_from_spec(spec)
spec.loader.exec_module(batch)
p = batch.p


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputs', type=Path)
    parser.add_argument('run', type=Path)
    parser.add_argument('--strong-reference', type=Path, help='JSON list of solve/component/path for independently refined references')
    args = parser.parse_args()
    manifest = json.loads((args.inputs/'report.json').read_text())
    report = dict(scope='anchored captured equations; no native material/trajectory claim', cases=[],
                  source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    references = {}
    if args.strong_reference:
        for item in json.loads(args.strong_reference.read_text()):
            references[item['solve'],item['component']] = Path(item['path'])
        report['strong_references'] = {str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in references.values()}
    destination = args.run/('quality-strong.json' if references else 'quality.json')
    assert not destination.exists(), 'Preserve previous qualification receipts'
    for epoch in manifest['cases']:
        step = epoch['solve']
        nodes, bonds = batch.world(epoch['prefix'])
        paths = sorted(args.run.glob(f'solve-{step}.solution-*.f64'))
        assert len(paths) == 6
        solutions = [np.fromfile(path, '<f8').reshape(256, manifest['rows']) for path in paths]
        assert all(np.isfinite(solution).all() for solution in solutions)
        row = dict(solve=step, components=[], outputs={str(path):hashlib.sha256(path.read_bytes()).hexdigest() for path in paths})
        for asset in epoch['assets']:
            index = asset['asset']
            ns, bs = batch.asset(nodes, bonds, index)
            inactive = np.ones(manifest['rows'], dtype=bool)
            for component in asset['components']:
                identity, restriction = component['id'], np.array(component['rows'])
                inactive[restriction] = False
                A, B, rhs, threshold, _ = p.assemble(ns, bs, identity)
                current_ids = np.flatnonzero(ns['component'] == identity)
                selected = np.flatnonzero((bs['health'] > 0) & ((ns['component'][bs['first']] == identity) | (ns['component'][bs['second']] == identity)))
                warm = bs['warm'][selected].astype(float).ravel()
                original = ns['rhs'][current_ids].astype(float).ravel()
                reference = warm+B.T@spsolve(A, rhs)
                if (step,identity) in references:
                    reference = np.fromfile(references[step,identity], '<f8')
                    assert len(reference) == B.shape[1]
                entry = dict(asset=index, component=identity, nodes=len(current_ids), samples=[])
                for solution in solutions:
                    potential = solution[index, restriction]
                    force = warm+B.T@potential
                    rounded = force.astype(np.float32).astype(float)
                    gradient = B.T@(original-B@rounded)
                    energy = float(gradient@gradient)
                    error = float(np.max(np.abs(force-reference)/np.maximum(1, np.maximum(np.abs(force), np.abs(reference)))))
                    entry['samples'].append(dict(accepted=energy <= threshold, rounded_gradient_squared=energy,
                                                  threshold=threshold, strong_scaled_error=error))
                row['components'].append(entry)
            assert all(np.all(solution[index, inactive] == 0) for solution in solutions)
        report['cases'].append(row)
        destination.write_text(json.dumps(report, indent=2)+'\n')
    samples = [sample for case in report['cases'] for component in case['components'] for sample in component['samples']]
    report.update(checked_current_systems=len(samples), passed=all(s['accepted'] and s['strong_scaled_error'] < 1e-7 for s in samples))
    destination.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(passed=report['passed'], checked=len(samples),
                         worst_threshold_ratio=max(s['rounded_gradient_squared']/s['threshold'] if s['threshold'] else 0 for s in samples),
                         worst_reference_error=max(s['strong_scaled_error'] for s in samples))))
    if not report['passed']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
