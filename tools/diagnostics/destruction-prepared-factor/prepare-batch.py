#!/usr/bin/env python3
"""Prepare all anchored remnants from the existing city256 debris captures.

One independent numeric matrix per original asset, with a common structural
envelope. Free components are excluded and have identity rows/zero loads.
These are diagnostic inputs; no snapshot or native solver state is changed.
"""
import argparse
import fcntl
import hashlib
import importlib.util
import json
from pathlib import Path
import time
import numpy as np
import scipy.sparse as sp

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location('prepared', Path(__file__).with_name('prepare.py'))
prepared = importlib.util.module_from_spec(spec)
spec.loader.exec_module(prepared)
p = prepared.p


def world(prefix):
    return np.fromfile(str(prefix)+'.nodes.bin', p.NODE), np.fromfile(str(prefix)+'.bonds.bin', p.BOND)


def asset(nodes, bonds, index):
    # Fixture dimensions are verified against endpoints and full capture sizes.
    ns, bs = nodes[index*444:(index+1)*444].copy(), bonds[index*896:(index+1)*896].copy()
    assert np.all(bs['first']//444 == index) and np.all(bs['second']//444 == index)
    bs['first'] -= index*444
    bs['second'] -= index*444
    return ns, bs


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=False)
    record = dict(scope=__doc__, source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(), cases=[])
    def save():
        (args.output/'report.json').write_text(json.dumps(record, indent=2)+'\n')
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease, fcntl.LOCK_EX | fcntl.LOCK_NB)
        start = time.monotonic()
        source = ROOT/'out/n28-duplicate-census-20260912'
        pn, pb = world(source/'city256-initial-impact-problem.world-0.solve-0')
        assert len(pn) == 256*444 and len(pb) == 256*896
        parent_nodes, parent_bonds = asset(pn, pb, 0)
        parent_ids = np.flatnonzero(parent_nodes['component'] == 64)
        A, B, *_ = p.assemble(parent_nodes, parent_bonds, 64)
        n = A.shape[0]
        incidence = B.copy()
        incidence.data[:] = 1
        pattern = (incidence@incidence.T+sp.eye(n)).tocsr()
        pattern.sort_indices()
        row_ids = np.repeat(np.arange(n), np.diff(pattern.indptr))
        pattern.indptr.astype('<i4').tofile(args.output/'pattern.rows.i32')
        pattern.indices.astype('<i4').tofile(args.output/'pattern.cols.i32')
        record.update(rows=n, nnz=pattern.nnz, nrhs=1, uniform_batch=256)
        record['inputs'] = {}
        for step in [0, 1]:
            prefix = source/f'city256-late-debris-problem.world-0.solve-{step}'
            nodes, bonds = world(prefix)
            for suffix in ['.nodes.bin', '.bonds.bin']:
                path = Path(str(prefix)+suffix)
                record['inputs'][str(path)] = hashlib.sha256(path.read_bytes()).hexdigest()
            batch_values, batch_rhs, cases = [], [], []
            for index in range(256):
                ns, bs = asset(nodes, bonds, index)
                np.testing.assert_array_equal(ns['inertia'], parent_nodes['inertia'])
                labels = set()
                for bond in bs:
                    if bond['health'] <= 0 or bond['scale'] == 0:
                        continue
                    left, right = int(bond['first']), int(bond['second'])
                    if np.all(ns['inertia'][left] == 0) and ns['component'][right] != p.INVALID:
                        labels.add(int(ns['component'][right]))
                    if np.all(ns['inertia'][right] == 0) and ns['component'][left] != p.INVALID:
                        labels.add(int(ns['component'][left]))
                active = np.zeros(n, dtype=bool)
                rows, cols, values = [], [], []
                load = np.zeros(n)
                case = dict(asset=index, components=[])
                for identity in sorted(labels):
                    current_ids = np.flatnonzero(ns['component'] == identity)
                    positions = np.searchsorted(parent_ids, current_ids)
                    np.testing.assert_array_equal(parent_ids[positions], current_ids)
                    restriction = (6*positions[:,None]+np.arange(6)).ravel()
                    current, _, rhs, threshold, _ = p.assemble(ns, bs, identity)
                    coo = current.tocoo()
                    rows.extend(restriction[coo.row]); cols.extend(restriction[coo.col]); values.extend(coo.data)
                    assert not np.any(active[restriction])
                    active[restriction] = True
                    load[restriction] = rhs
                    case['components'].append(dict(id=identity, rows=restriction.tolist(), threshold=threshold))
                inactive = np.flatnonzero(~active)
                rows.extend(inactive); cols.extend(inactive); values.extend(np.ones(len(inactive)))
                matrix = sp.coo_matrix((values, (rows, cols)), shape=(n, n)).tocsr()
                packed = np.asarray(matrix[row_ids, pattern.indices]).ravel()
                restored = sp.csr_matrix((packed, pattern.indices, pattern.indptr), shape=(n, n))
                assert (restored != matrix).nnz == 0, 'Current operator outside symbolic envelope'
                batch_values.append(packed); batch_rhs.append(load); cases.append(case)
            np.asarray(batch_values, dtype='<f8').tofile(args.output/f'solve-{step}.values.f64')
            np.asarray(batch_rhs, dtype='<f8').tofile(args.output/f'solve-{step}.rhs.f64')
            record['cases'].append(dict(solve=step, prefix=str(prefix), assets=cases))
            save()
            print(json.dumps(dict(solve=step, assets=len(cases), anchored_components=sum(len(c['components']) for c in cases))), flush=True)
        record.update(status='prepared_all_current_anchored_operators', preparation_host_seconds=time.monotonic()-start)
        save()


if __name__ == '__main__':
    main()
