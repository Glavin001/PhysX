#!/usr/bin/env python3
"""Prepare fixed inverse Cholesky coordinates, not an inverse physical answer."""
import argparse
import fcntl
import hashlib
import json
from pathlib import Path
import time
import numpy as np
import scipy.linalg as la
import scipy.sparse as sp
ROOT=Path(__file__).resolve().parents[3]

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('inputs',type=Path);p.add_argument('output',type=Path);a=p.parse_args()
    a.output.mkdir(parents=True,exist_ok=False)
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        manifest=json.loads((a.inputs/'solve-0/manifest.json').read_text());n=manifest['parent_rows']
        paths=[a.inputs/('parent'+s) for s in ['.values.f64','.cols.i32','.rows.i32']]
        A=sp.csr_matrix((np.fromfile(paths[0],'<f8'),np.fromfile(paths[1],'<i4'),np.fromfile(paths[2],'<i4')),shape=(n,n)).toarray()
        start=time.monotonic();L=la.cholesky(A,lower=True);R=la.solve_triangular(L,np.eye(n),lower=True).astype('<f4');seconds=time.monotonic()-start
        assert np.isfinite(R).all() and np.all(np.diag(R)>0) and np.count_nonzero(np.triu(R,1))==0
        # A triangular matrix with positive diagonal is nonsingular; R.T R
        # and its injective coordinate restrictions are therefore SPD.
        rng=np.random.default_rng(271828);vectors=rng.normal(size=(n,32));energy=np.sum((R.astype('f8')@vectors)**2,axis=0)
        assert np.all(energy>0)
        R.T.copy().tofile(a.output/'inverse-lower.f32') # cuBLAS column-major
        r=dict(scope=__doc__,rows=n,factor_bytes=R.nbytes,host_factor_prepare_ms=seconds*1000,
            max_inverse_identity_error=float(np.max(np.abs(L@R.astype('f8')-np.eye(n)))),minimum_test_energy=float(energy.min()),
            inputs={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),status='prepared_fixed_spd_form')
        (a.output/'report.json').write_text(json.dumps(r,indent=2)+'\n');print(json.dumps(r))
if __name__=='__main__':main()
