#!/usr/bin/env python3
"""Independent equation audit of diagnostic native captures; no timing or gate replacement."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

import numpy as np
from scipy.linalg import lstsq
from scipy.sparse.linalg import splu

spec = importlib.util.spec_from_file_location('native_problem', Path(__file__).with_name('assess-native-stress-problems.py'))
problem = importlib.util.module_from_spec(spec)
spec.loader.exec_module(problem)


def norm(x):
    return float(np.linalg.norm(x))


def audit_component(nodes, bonds, solution, identity):
    A, B, residual, threshold, metadata = problem.assemble(nodes, bonds, identity, require_anchored=False)
    members = np.flatnonzero(nodes['component'] == identity)
    labels = nodes['component']
    selected = np.flatnonzero((bonds['health'] > 0) &
        ((labels[bonds['first']] == identity) | (labels[bonds['second']] == identity)))
    rhs = nodes['rhs'][members].astype(np.float64).ravel()
    warm = bonds['warm'][selected].astype(np.float64).ravel()
    actual = solution[selected].astype(np.float64).ravel()
    problem.require(np.isfinite(actual).all(), 'nonfinite captured solution')
    if not metadata['anchored']:
        problem.require(len(members) <= 256, 'free component exceeds bounded independent dense reference')
        dense = B.toarray()
        delta, _, rank, singular = lstsq(dense, residual, cond=None, lapack_driver='gelsd')
        minimum_norm, _, _, _ = lstsq(dense, rhs, cond=None, lapack_driver='gelsd')
        expected = warm + delta
        projected, _, _, _ = lstsq(dense, B @ (actual - warm), cond=None, lapack_driver='gelsd')
        force_error = actual - expected
        live_residual = rhs - B @ actual
        gradient = B.T @ live_residual
        scale = np.maximum(1.0, np.maximum(np.abs(expected), np.abs(actual)))
        return dict(component=int(identity), **metadata, threshold=threshold,
            reference_method='independent FP64 dense SVD least squares; no prescribed anchor',
            reference_rank=int(rank), reference_singular_values=singular.tolist(),
            reference_gradient_squared=norm(B.T @ (rhs - B @ expected)) ** 2,
            actual_gradient_squared=norm(gradient) ** 2,
            actual_gradient_to_threshold=norm(gradient) ** 2 / threshold if threshold else None,
            force_relative_l2_error=norm(force_error) / max(norm(expected), 1e-300),
            force_max_scaled_error=float(np.max(np.abs(force_error) / scale)),
            force_max_absolute_error=float(np.max(np.abs(force_error))),
            rhs_norm=norm(rhs), actual_residual_norm=norm(live_residual),
            actual_force_norm=norm(actual), reference_force_norm=norm(expected),
            warm_norm=norm(warm), warm_self_stress_norm=norm(expected - minimum_norm),
            actual_update_outside_range_norm=norm(actual - warm - projected),
            units='native normalized solver units; physical exported force gate is separate')
    factor = splu(A.tocsc())
    extended = A.astype(np.longdouble)

    def solve(value):
        x = factor.solve(value)
        for _ in range(3):
            r = value.astype(np.longdouble) - extended @ x.astype(np.longdouble)
            x += factor.solve(np.asarray(r, dtype=np.float64))
        r = value.astype(np.longdouble) - extended @ x.astype(np.longdouble)
        scale = np.abs(value) + abs(A) @ np.abs(x)
        backward = float(np.max(np.abs(r) / np.maximum(scale, 1e-300)))
        problem.require(backward < 1e-12, 'independent direct solve backward-error check failed')
        return x, backward

    correction, backward = solve(residual)
    expected = warm + B.T @ correction
    canonical, canonical_backward = solve(rhs)
    minimum_norm = B.T @ canonical
    live_residual = rhs - B @ actual
    gradient = B.T @ live_residual
    force_error = actual - expected
    # This separates force equilibrium from self-stress invisible to B.
    projected, _ = solve(B @ (actual - warm))
    outside_range = actual - warm - B.T @ projected
    scale = np.maximum(1.0, np.maximum(np.abs(expected), np.abs(actual)))
    return dict(component=int(identity), **metadata, threshold=threshold,
        reference_backward_error=backward, canonical_backward_error=canonical_backward,
        reference_gradient_squared=norm(B.T @ (rhs - B @ expected)) ** 2,
        actual_gradient_squared=norm(gradient) ** 2,
        actual_gradient_to_threshold=norm(gradient) ** 2 / threshold if threshold else None,
        force_relative_l2_error=norm(force_error) / max(norm(expected), 1e-300),
        force_max_scaled_error=float(np.max(np.abs(force_error) / scale)),
        force_max_absolute_error=float(np.max(np.abs(force_error))),
        rhs_norm=norm(rhs), actual_residual_norm=norm(live_residual),
        actual_force_norm=norm(actual), reference_force_norm=norm(expected),
        warm_norm=norm(warm), warm_self_stress_norm=norm(expected - minimum_norm),
        actual_update_outside_range_norm=norm(outside_range),
        units='native normalized solver units; physical exported force gate is separate')


def audit(prefix):
    paths = [Path(str(prefix) + suffix) for suffix in ['.json', '.nodes.bin', '.bonds.bin', '.solution.bin']]
    meta = json.loads(paths[0].read_text())
    nodes = np.fromfile(paths[1], dtype=problem.NODE)
    bonds = np.fromfile(paths[2], dtype=problem.BOND)
    solution = np.fromfile(paths[3], dtype='<f4').reshape(-1, 6)
    problem.require(len(nodes) == meta['node_count'] and len(bonds) == len(solution) == meta['bond_count'], 'capture lengths disagree')
    rows, free, skipped = [], [], []
    for identity in np.unique(nodes['component']):
        if identity == problem.INVALID:
            continue
        try:
            result = audit_component(nodes, bonds, solution, identity)
            (rows if result['anchored'] else free).append(result)
        except ValueError as error:
            if str(error) != 'free component exceeds bounded independent dense reference':
                raise
            skipped.append(dict(component=int(identity), reason=str(error)))
    return dict(capture=str(prefix), sha256={str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},
        anchored_components=rows, free_components=free, unsupported_free_components=skipped,
        scope='Independent FP64 sparse direct solve with extended-precision residual refinement on captured coefficients. '
              'Not an arbitrary-precision forward-error proof; no replacement of physical/material gates or application timing claim.')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    parser.add_argument('prefix', type=Path, nargs='+')
    args = parser.parse_args()
    result = dict(status='running', captures=[])
    try:
        for prefix in args.prefix:
            result['captures'].append(audit(prefix))
        result['status'] = 'audit_complete_not_quality_qualification'
    except Exception as error:
        result.update(status='failed', error=repr(error))
        raise
    finally:
        with args.output.open('x') as output:
            json.dump(result, output, indent=2, allow_nan=False)
            output.write('\n')
