#!/usr/bin/env python3
"""Work-only oracle for sparse rigid aggregate coarse correction.

Reconstruct geometry from native coefficients and verify internal bond null
modes before solving. Parent membership is fixed; the Galerkin matrix uses
the current surviving operator. No native timing or quality relaxation.
"""
import argparse
import fcntl
import hashlib
import importlib.util
import json
import os
from pathlib import Path
import time
import numpy as np
import scipy.linalg as la
import scipy.sparse as sp

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('prepared', Path(__file__).with_name('prepare.py'))
prepared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepared)
spec = importlib.util.spec_from_file_location('checks', Path(__file__).with_name('check.py'))
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputs', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    assert os.environ.get('OPENBLAS_NUM_THREADS') == '1'
    record = dict(status='running', source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), cases=[])
    def save():
        (args.output/'report.json').write_text(json.dumps(record, indent=2)+'\n')
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
        try:
            capture = ROOT/'out/n24-native-equation-worlds-20260912/A-problem.world-0.solve-0'
            nodes = np.fromfile(str(capture)+'.nodes.bin', prepared.p.NODE)
            bonds = np.fromfile(str(capture)+'.bonds.bin', prepared.p.BOND)
            members = np.flatnonzero(nodes['component'] == 64)
            local = {int(node): i for i, node in enumerate(members)}
            positions = np.full((len(members), 3), np.nan)
            positions[0] = 0
            graph = [[] for _ in members]
            for bond in bonds:
                a, b = int(bond['first']), int(bond['second'])
                if a in local and b in local and bond['health'] > 0:
                    delta = bond['offset0'].astype(float)-bond['offset1']
                    graph[local[a]].append((local[b], delta))
                    graph[local[b]].append((local[a], -delta))
            queue = [0]
            for a in queue:
                for b, delta in graph[a]:
                    if np.isnan(positions[b, 0]):
                        positions[b] = positions[a]+delta
                        queue.append(b)
                    else:
                        np.testing.assert_allclose(positions[b]-positions[a], delta, atol=1e-6)
            assert np.all(np.isfinite(positions)), 'Parent internal graph is disconnected'
            record['geometry_nodes'] = len(members)
            for groups in [8, 32]:
                start = time.monotonic()
                patches = [np.arange(len(members))]
                while len(patches) < groups:
                    split = []
                    for patch in patches:
                        axis = np.argmax(np.ptp(positions[patch], axis=0))
                        order = patch[np.argsort(positions[patch, axis], kind='stable')]
                        split.extend(np.array_split(order, 2))
                    patches = split
                basis = np.zeros((len(members)*6, groups*6))
                labels = np.zeros(len(members), dtype=int)
                for group, patch in enumerate(patches):
                    center = positions[patch].mean(axis=0)
                    for i in patch:
                        angular, linear = nodes['inertia'][members[i]]
                        basis[6*i:6*i+3, 6*group:6*group+3] = np.eye(3)/angular
                        basis[6*i+3:6*i+6, 6*group:6*group+3] = prepared.p.skew(positions[i]-center)/linear
                        basis[6*i+3:6*i+6, 6*group+3:6*group+6] = np.eye(3)/linear
                        labels[i] = group
                # A wrong rotation sign can appear SPD yet lose the physical
                # low-energy modes. Check every internal edge explicitly.
                maximum = 0.
                for bond in bonds:
                    a, b = int(bond['first']), int(bond['second'])
                    if a not in local or b not in local or labels[local[a]] != labels[local[b]]:
                        continue
                    image = np.zeros((6, groups*6))
                    for side, node in enumerate([a, b]):
                        block = np.eye(6)
                        block[:3, 3:] = -prepared.p.skew(bond['offset'+str(side)])
                        block[:3] *= nodes['inertia'][node][0]
                        block[3:] *= nodes['inertia'][node][1]
                        image += (1 if side == 0 else -1)*block.T@basis[6*local[node]:6*local[node]+6]
                    maximum = max(maximum, float(np.max(np.abs(image))))
                assert maximum < 1e-5, maximum
                asset_ms = 1000*(time.monotonic()-start)
                for step in [0, 1]:
                    path = args.inputs/f'solve-{step}'
                    manifest = json.loads((path/'manifest.json').read_text())
                    n, m, k = manifest['matrices']['A']['rows'], manifest['matrices']['B']['columns'], manifest['nrhs']
                    A = checks.matrix(path/'A', (n, n))
                    B = checks.matrix(path/'B', (n, m))
                    restriction = np.fromfile(path/'restriction.i32', '<i4')
                    V = sp.csr_matrix(basis[restriction])
                    inverse = np.fromfile(path/'inverse.f64', '<f8').reshape(-1, 6, 6)
                    start = time.monotonic()
                    coarse = (V.T@A@V).toarray()
                    factor = la.cho_factor(coarse, lower=True)
                    setup = 1000*(time.monotonic()-start)
                    rhs = np.fromfile(path/'rhs.f64', '<f8').reshape(k, n)
                    warm = np.fromfile(path/'warm.f64', '<f8').reshape(k, m)
                    original = np.fromfile(path/'original.f64', '<f8').reshape(k, n)
                    threshold = np.fromfile(path/'threshold.f64', '<f8')
                    def apply(r):
                        return np.einsum('nij,nj->ni', inverse, r.reshape(-1, 6)).ravel()+V@la.cho_solve(factor, V.T@r)
                    for column in [0, 4, 24]:
                        _, result = prepared.solve(A, B, rhs[column], warm[column], original[column], threshold[column], apply)
                        row = dict(solve=step, groups=groups, component=manifest['components'][column]['component'],
                                   sparse_basis_nnz=V.nnz, internal_mode_error=maximum,
                                   asset_host_ms=asset_ms, current_setup_host_ms=setup, **result)
                        record['cases'].append(row)
                        save()
                        print(json.dumps(row), flush=True)
            record['status'] = 'work_screen_complete_not_runtime_qualification'
        except BaseException as error:
            record.update(status='failed', error=repr(error))
            save()
            raise
        save()


if __name__ == '__main__':
    main()
