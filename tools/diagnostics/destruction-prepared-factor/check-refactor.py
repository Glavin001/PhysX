#!/usr/bin/env python3
"""Check every changed-factor output against current forces and strong reference."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import numpy as np

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('checks', Path(__file__).with_name('check.py'))
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('inputs', type=Path)
    p.add_argument('run', type=Path)
    args = p.parse_args()
    report = dict(scope='captured current equations, not native materials or trajectories', cases=[])
    for step in [0, 1]:
        path = args.inputs/f'solve-{step}'
        manifest = json.loads((path/'manifest.json').read_text())
        n, m, k = manifest['matrices']['A']['rows'], manifest['matrices']['B']['columns'], manifest['nrhs']
        rows = manifest['parent_rows']
        restriction = np.fromfile(path/'restriction.i32', '<i4')
        inactive = np.ones(rows, dtype=bool)
        inactive[restriction] = False
        B = checks.matrix(path/'B', (n, m))
        original = np.fromfile(path/'original.f64', '<f8').reshape(k, n).T
        warm = np.fromfile(path/'warm.f64', '<f8').reshape(k, m).T
        threshold = np.fromfile(path/'threshold.f64', '<f8')
        strong = np.stack([np.fromfile(ROOT/f'out/n24-native-equation-worlds-20260912/strong-suite/solve-{step}-component-{c["component"]}/normalized-reference.f64', '<f8') for c in manifest['components']], axis=1)
        outputs = sorted(args.run.glob(f'solve-{step}.solution-*.f64'))
        assert len(outputs) == 6, 'Missing first or repeated output'
        for output in outputs:
            full = np.fromfile(output, '<f8').reshape(k, rows).T
            assert np.isfinite(full).all() and np.all(full[inactive] == 0)
            force = warm+B.T@full[restriction]
            rounded = force.astype(np.float32).astype(np.float64)
            gradient = B.T@(original-B@rounded)
            ratios = np.sum(gradient*gradient, axis=0)/threshold
            error = np.max(np.abs(force-strong)/np.maximum(1, np.maximum(np.abs(force), np.abs(strong))), axis=0)
            report['cases'].append(dict(solve=step, path=str(output), sha256=hashlib.sha256(output.read_bytes()).hexdigest(),
                                        threshold_ratios=ratios.tolist(), strong_scaled_errors=error.tolist(),
                                        passed=bool(np.all(ratios <= 1) and np.all(error < 1e-7))))
    report['checked_current_systems'] = 25*len(report['cases'])
    report['passed'] = all(case['passed'] for case in report['cases'])
    (args.run/'quality.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(dict(passed=report['passed'], checked=report['checked_current_systems'],
                         worst_threshold_ratio=max(max(c['threshold_ratios']) for c in report['cases']),
                         worst_strong_error=max(max(c['strong_scaled_errors']) for c in report['cases']))))
    if not report['passed']:
        raise SystemExit(1)


if __name__ == '__main__':
    main()
