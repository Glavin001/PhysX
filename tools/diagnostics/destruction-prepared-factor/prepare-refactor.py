#!/usr/bin/env python3
"""Construct a deletion-stable symbolic envelope, with current coefficients.

Dropped coordinates have identity rows and zero loads. Structural sparsity is
the union of per-bond products, including entries which cancel numerically in
the intact operator. No new synchronous symbolic analysis is needed for cuts.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import numpy as np
import scipy.linalg as la
import scipy.sparse as sp

spec = importlib.util.spec_from_file_location('checks', Path(__file__).with_name('check.py'))
checks = importlib.util.module_from_spec(spec)
spec.loader.exec_module(checks)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('inputs', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    parent = json.loads((args.inputs/'solve-0/manifest.json').read_text())
    n = parent['parent_rows']
    B = checks.matrix(args.inputs/'solve-0/B', (n, parent['matrices']['B']['columns']))
    incidence = B.copy()
    incidence.data[:] = 1
    envelope = (incidence@incidence.T+sp.eye(n)).tocsr()
    envelope.sort_indices()
    row_ids = np.repeat(np.arange(n), np.diff(envelope.indptr))
    envelope.indptr.astype('<i4').tofile(args.output/'pattern.rows.i32')
    envelope.indices.astype('<i4').tofile(args.output/'pattern.cols.i32')
    report = dict(scope=__doc__, rows=n, nnz=envelope.nnz, nrhs=parent['nrhs'], cases=[],
                  source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    for step in [0, 1]:
        path = args.inputs/f'solve-{step}'
        manifest = json.loads((path/'manifest.json').read_text())
        count, loads = manifest['matrices']['A']['rows'], manifest['nrhs']
        A = checks.matrix(path/'A', (count, count))
        restriction = np.fromfile(path/'restriction.i32', '<i4')
        active = np.zeros(n, dtype=bool)
        active[restriction] = True
        coordinates = A.tocoo()
        padded = sp.coo_matrix((coordinates.data, (restriction[coordinates.row], restriction[coordinates.col])), shape=(n, n)).tocsr()
        padded += sp.diags((~active).astype(float))
        values = np.asarray(padded[row_ids, envelope.indices]).ravel()
        rebuilt = sp.csr_matrix((values, envelope.indices, envelope.indptr), shape=(n, n))
        assert (rebuilt != padded).nnz == 0, 'Current operator exceeds prepared symbolic envelope'
        # Test SPD on the active block. The padded matrix is its direct sum
        # with an identity and has no active/inactive coupling.
        la.cholesky(A.toarray(), lower=True)
        assert (padded[restriction][:, restriction] != A).nnz == 0
        rhs = np.fromfile(path/'rhs.f64', '<f8').reshape(loads, count)
        padded_rhs = np.zeros((loads, n))
        padded_rhs[:, restriction] = rhs
        values.astype('<f8').tofile(args.output/f'solve-{step}.values.f64')
        padded_rhs.astype('<f8').tofile(args.output/f'solve-{step}.rhs.f64')
        report['cases'].append(dict(solve=step, active_rows=count, identity_rows=n-count,
                                    numeric_nnz=padded.nnz, pattern_nnz=envelope.nnz))
    report['status'] = 'prepared_current_operator_envelope'
    report['inputs'] = {str(path): hashlib.sha256(path.read_bytes()).hexdigest()
                        for path in args.inputs.rglob('*') if path.is_file()}
    (args.output/'report.json').write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps({k:v for k,v in report.items() if k != 'inputs'}))


if __name__ == '__main__':
    main()
