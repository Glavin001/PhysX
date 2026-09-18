#!/usr/bin/env python3
"""Independent sparse-direct audit of test-only 3D stress exports.

CPU/SciPy is an offline oracle, never a production destruction backend.
The exporter supplies prepared coefficients and published forces. This script
assembles B independently, solves B B^T mu = rhs (with exact free rigid modes),
and checks forces against B^T mu. It never uses native recursive residuals.
"""
import argparse
import json
from pathlib import Path
import numpy as np
import scipy.sparse as sparse
import scipy.sparse.linalg as linalg


def cross(v):
    x, y, z = v
    return np.array([[0., -z, y], [z, 0., -x], [-y, x, 0.]])


def audit(path):
    data = json.loads(path.read_text())
    nodes = np.asarray(data['nodes'], dtype=np.float64)
    bonds = np.asarray(data['bonds'], dtype=np.float64)
    if not np.all(np.isfinite(nodes)) or not np.all(np.isfinite(bonds)):
        raise ValueError('nonfinite exported coefficients or forces')
    n, m = len(nodes), len(bonds)
    inertia = np.repeat(nodes[:, :2], 3, axis=1).reshape(-1)
    rhs = nodes[:, 2:].reshape(-1)
    rows, cols, values = [], [], []
    adjacency = [[] for _ in range(n)]
    for e, bond in enumerate(bonds):
        a, b = map(int, bond[:2])
        delta = bond[2:5] - bond[5:8]
        adjacency[a].append((b, delta))
        adjacency[b].append((a, -delta))
        for node, offset, sign in [(a, bond[2:5], 1), (b, bond[5:8], -1)]:
            block = np.eye(6)
            block[:3, 3:] = -cross(offset)
            block *= (sign * bond[8] * inertia[6*node:6*node+6])[:, None]
            for i, j in zip(*np.nonzero(block)):
                rows.append(6*node+i)
                cols.append(6*e+j)
                values.append(block[i, j])
    B = sparse.coo_matrix((values, (rows, cols)), shape=(6*n, 6*m)).tocsc()
    active = inertia > 0
    A = B[active]
    L = (A @ A.T).tocsc()
    if np.all(active):
        # These fixtures are connected and have coherent three-dimensional
        # offsets. Check that premise rather than assume every graph has six modes.
        position = np.full((n, 3), np.nan)
        position[0] = 0
        queue = [0]
        for a in queue:
            for b, delta in adjacency[a]:
                candidate = position[a] + delta
                if np.isnan(position[b, 0]):
                    position[b] = candidate
                    queue.append(b)
                elif not np.array_equal(position[b], candidate):
                    raise ValueError('incoherent offsets require a different null-space audit')
        if len(queue) != n:
            raise ValueError('direct fixture audit requires a connected graph')
        position -= position.mean(axis=0)
        modes = np.zeros((6*n, 6))
        for i, p in enumerate(position):
            modes[6*i:6*i+3, :3] = np.eye(3)
            modes[6*i+3:6*i+6, :3] = cross(p)
            modes[6*i+3:6*i+6, 3:] = np.eye(3)
        modes /= inertia[:, None]
        modes = np.linalg.qr(modes)[0]
        if np.linalg.norm(B.T @ modes) > 1e-10:
            raise ValueError('constructed rigid modes are not null modes')
        R = sparse.csc_matrix(modes)
        system = sparse.bmat([[L, R], [R.T, None]], format='csc')
        mu = linalg.splu(system).solve(np.r_[rhs, np.zeros(6)])[:-6]
    else:
        mu = linalg.splu(L).solve(rhs[active])
    scaled = A.T @ mu
    length, mass = data['length_scale'], data['mass_scale']
    physical_scale = np.tile(np.r_[np.full(3, length*length*mass), np.full(3, length*mass)], m)
    physical_scale *= np.repeat(bonds[:, 8], 6)
    expected = scaled * physical_scale
    rhs2 = float(rhs @ rhs)
    def measure(force):
        if not np.all(np.isfinite(force)):
            raise ValueError('nonfinite force in independent audit')
        residual = rhs - B @ (force / physical_scale)
        gradient = B.T @ residual
        return {'gradient_squared': float(gradient @ gradient),
                'residual_squared': float(residual @ residual),
                'max_scaled_force_error': float(np.max(np.abs(force-expected)/np.maximum(1., np.abs(expected))))}
    result = {'file': str(path), 'nodes': n, 'bonds': m, 'native_converged': bool(data['native_converged']),
              'requested_threshold_squared': rhs2*1e-10, 'max_direct_force': float(np.max(np.abs(expected))),
              'direct': measure(expected), 'rounded_direct': measure(expected.astype(np.float32).astype(np.float64)),
              'cpu_iterative': measure(bonds[:, 9:15].reshape(-1)),
              'native': measure(bonds[:, 15:21].reshape(-1))}
    if 'precise' in data:
        result['precise_iterative'] = measure(np.asarray(data['precise'], dtype=np.float64).reshape(-1))
    if result['direct']['gradient_squared'] > max(1e-18, rhs2*1e-16):
        raise ValueError('direct reference residual is too large')
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('captures', nargs='+', type=Path)
    parser.add_argument('--max-native-error', type=float)
    parser.add_argument('--max-reference-error', type=float)
    args = parser.parse_args()
    for path in args.captures:
        result = audit(path)
        print(json.dumps(result, sort_keys=True), flush=True)
        if args.max_native_error is not None and (not result['native_converged'] or result['native']['max_scaled_force_error'] >= args.max_native_error):
            raise ValueError('native output failed the independent direct-reference gate')
        if args.max_reference_error is not None and result['precise_iterative']['max_scaled_force_error'] >= args.max_reference_error:
            raise ValueError('high-precision iterative reference disagrees with direct solve')


if __name__ == '__main__':
    main()
