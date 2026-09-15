#!/usr/bin/env python3
"""Fixed parent-factor experiment on saved current native equations.

Produces explicit CSR inputs and an independent FP64 work/quality oracle.
No native simulation, hidden cache priming, or application timing claim.
"""
import argparse
import hashlib
import importlib.util
import json
import os
from pathlib import Path

import numpy as np
import scipy.linalg as la

ROOT = Path(__file__).resolve().parents[3]
ORACLE = ROOT / 'out/n28-native-factor-20260912/assess-native-stress-problems.py'
spec = importlib.util.spec_from_file_location('captured', ORACLE)
p = importlib.util.module_from_spec(spec)
spec.loader.exec_module(p)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def solve(A, B, rhs, warm, original, threshold, apply, limit=8192):
    """Fixed SPD PCG, verifying actual recovered FP32 forces on acceptance."""
    x = np.zeros_like(rhs)
    r = rhs.copy()
    direction = None
    previous = 0.
    restarts = 0
    for iteration in range(limit + 1):
        # Native first update is steepest descent; use the same convention.
        force = (warm + B.T @ x).astype(np.float32).astype(np.float64)
        physical = original - B @ force
        gradient = B.T @ physical
        energy = float(gradient @ gradient)
        if energy <= threshold:
            return x, dict(converged=True, updates=iteration,
                           rounded_gradient_squared=energy, threshold=threshold,
                           residual_restarts=restarts)
        if iteration == limit:
            break
        z = r.copy() if iteration == 0 else apply(r)
        gamma = float(r @ z)
        if not gamma > 0 or not np.isfinite(gamma):
            raise ValueError('nonpositive preconditioned residual')
        direction = z if direction is None or iteration == 1 else z + gamma / previous * direction
        q = A @ direction
        den = float(direction @ q)
        if not den > 0 or not np.isfinite(den):
            raise ValueError('current operator is not positive on direction')
        alpha = gamma / den
        x += alpha * direction
        r -= alpha * q
        previous = gamma
        # Restart only when the recursive residual would falsely accept.
        # Periodic arbitrary restarts can hide useful conjugate directions.
        recursive_gradient = B.T @ r
        if float(recursive_gradient @ recursive_gradient) <= threshold:
            r = rhs - A @ x
            direction = None
            restarts += 1
    return x, dict(converged=False, updates=limit,
                   rounded_gradient_squared=energy, threshold=threshold,
                   residual_restarts=restarts)


def csr(prefix, matrix):
    matrix = matrix.tocsr(copy=True)
    matrix.sort_indices()
    matrix.indptr.astype('<i4').tofile(str(prefix) + '.rows.i32')
    matrix.indices.astype('<i4').tofile(str(prefix) + '.cols.i32')
    matrix.data.astype('<f8').tofile(str(prefix) + '.values.f64')
    return dict(rows=matrix.shape[0], columns=matrix.shape[1], nnz=matrix.nnz)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    assert os.environ.get('OPENBLAS_NUM_THREADS') == '1'
    args.output.mkdir(parents=True, exist_ok=False)
    source = ROOT / 'out/n24-native-equation-worlds-20260912'
    nodes = []; bonds = []
    provenance = {str(ORACLE): digest(ORACLE)}
    for step in range(2):
        prefix = source / f'A-problem.world-0.solve-{step}'
        nfile = Path(str(prefix) + '.nodes.bin'); bfile = Path(str(prefix) + '.bonds.bin')
        nodes.append(np.fromfile(nfile, p.NODE)); bonds.append(np.fromfile(bfile, p.BOND))
        provenance.update({str(nfile): digest(nfile), str(bfile): digest(bfile)})
    manifests = json.loads((ROOT / 'out/native-shared-factor-setup-20260912/inputs/manifest.json').read_text())['cases']
    parent_nodes = np.flatnonzero(nodes[0]['component'] == 64)
    parent_A, _, _, _, _ = p.assemble(nodes[0], bonds[0], 64)
    # Cholesky is also an independent SPD admission check, not an assumption
    # based merely on the component touching an anchor.
    L = la.cho_factor(parent_A.toarray(), lower=True)
    report = dict(status='running', scope='captured equations; no application timing',
                  baseline_source='13b11af2e0aeabf4e0070931fbd8a060f383dfaf',
                  inputs=provenance, parent_rows=parent_A.shape[0], iteration_limit=8192, cases=[])
    csr(args.output / 'parent', parent_A)
    for step in range(2):
        ns = nodes[step]; bs = bonds[step]
        ids = np.flatnonzero(ns['component'] == 64)
        positions = np.searchsorted(parent_nodes, ids)
        assert np.array_equal(parent_nodes[positions], ids)
        assert np.array_equal(ns['inertia'][ids], nodes[0]['inertia'][ids])
        restriction = (6 * positions[:, None] + np.arange(6)).ravel()
        def apply(v):
            padded = np.zeros(parent_A.shape[0]); padded[restriction] = v
            return la.cho_solve(L, padded)[restriction]
        A, B, _, _, info = p.assemble(ns, bs, 64)
        # Exact symmetry/positive quadratic forms of R A_parent^-1 R^T.
        rng = np.random.default_rng(78103 + step)
        for _ in range(8):
            u = rng.normal(size=len(restriction)); v = rng.normal(size=len(restriction))
            pu = apply(u); pv = apply(v)
            assert u @ pu > 0
            assert np.isclose(u @ pv, v @ pu, rtol=1e-9, atol=1e-7)
        diagonal = np.array([A[i:i+6, i:i+6].toarray() for i in range(0, A.shape[0], 6)])
        inverse = np.linalg.inv(diagonal)
        def jacobi(v):
            return np.einsum('nij,nj->ni', inverse, v.reshape(-1, 6)).ravel()
        case_dir = args.output / f'solve-{step}'; case_dir.mkdir()
        matrices = {name: csr(case_dir / name, mat) for name, mat in [('A', A), ('B', B), ('BT', B.T)]}
        restriction.astype('<i4').tofile(case_dir / 'restriction.i32')
        inverse.astype('<f8').tofile(case_dir / 'inverse.f64')
        original = []; warms = []; residuals = []; thresholds = []; entries = []
        for component in manifests[step]['components']:
            Ai, Bi, rhs, threshold, component_info = p.assemble(ns, bs, component)
            assert (Ai != A).nnz == 0 and (Bi != B).nnz == 0
            current_ids = np.flatnonzero(ns['component'] == component)
            # IDs differ by the instance offset; coordinate/coefficient mapping must agree.
            assert np.array_equal(current_ids-current_ids[0], ids-ids[0])
            es = np.flatnonzero((bs['health'] > 0) & ((ns['component'][bs['first']] == component) | (ns['component'][bs['second']] == component)))
            warm = bs['warm'][es].astype(np.float64).ravel()
            load = ns['rhs'][current_ids].astype(np.float64).ravel()
            expected = np.fromfile(source / 'strong-suite' / f'solve-{step}-component-{component}' / 'normalized-reference.f64', '<f8')
            row = dict(component=component, **component_info, methods={})
            for name, precondition in [('block_jacobi', jacobi), ('restricted_parent', apply)]:
                x, result = solve(A, B, rhs, warm, load, threshold, precondition)
                force = warm + B.T @ x
                result['force_error_to_strong_reference'] = float(np.max(np.abs(force-expected)/np.maximum(1, np.maximum(np.abs(force), np.abs(expected)))))
                row['methods'][name] = result
            entries.append(row)
            original.append(load); warms.append(warm); residuals.append(rhs); thresholds.append(threshold)
        for name, values in [('original', original), ('warm', warms), ('rhs', residuals)]:
            np.asarray(values, dtype='<f8').tofile(case_dir / (name + '.f64'))
        np.asarray(thresholds, dtype='<f8').tofile(case_dir / 'threshold.f64')
        case = dict(solve=step, matrices=matrices, nrhs=len(entries), parent_rows=parent_A.shape[0],
                    parent_nnz=parent_A.nnz, components=entries)
        (case_dir / 'manifest.json').write_text(json.dumps(case, indent=2) + '\n')
        report['cases'].append(case)
        (args.output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
        print(json.dumps(dict(solve=step, nodes=len(ids), rhs=len(entries), methods={name:[min(r['methods'][name]['updates'] for r in entries), max(r['methods'][name]['updates'] for r in entries)] for name in ['block_jacobi','restricted_parent']})), flush=True)
    report['status'] = 'independent_work_screen_complete_not_runtime_qualification'
    report['source_sha256'] = digest(Path(__file__))
    (args.output / 'report.json').write_text(json.dumps(report, indent=2) + '\n')


if __name__ == '__main__':
    main()
