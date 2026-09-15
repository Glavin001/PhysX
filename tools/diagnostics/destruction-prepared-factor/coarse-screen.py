#!/usr/bin/env python3
"""Independent work screen: reuse asset modes with a current Galerkin operator.

Alternative after full parent-factor application proved expensive. This is not
runtime code, a relaxed quality budget, or an application speed measurement.
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

ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('prepared',Path(__file__).with_name('prepare.py'))
prepared=importlib.util.module_from_spec(spec);spec.loader.exec_module(prepared)
spec=importlib.util.spec_from_file_location('checks',Path(__file__).with_name('check.py'))
checks=importlib.util.module_from_spec(spec);spec.loader.exec_module(checks)


def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('inputs',type=Path);p.add_argument('output',type=Path)
    a=p.parse_args();a.output.mkdir(parents=True,exist_ok=False)
    assert os.environ.get('OPENBLAS_NUM_THREADS')=='1'
    record=dict(status='running',scope=__doc__,ranks=[32,128],cases=[],preparation_ms={},source_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest())
    def save():(a.output/'report.json').write_text(json.dumps(record,indent=2)+'\n')
    with (ROOT/'out/destruction-ab.lock').open('a') as lease:
        fcntl.flock(lease,fcntl.LOCK_EX|fcntl.LOCK_NB)
        try:
            manifest=json.loads((a.inputs/'solve-0/manifest.json').read_text());pn=manifest['parent_rows']
            parent=checks.matrix(a.inputs/'parent',(pn,pn))
            start=time.monotonic()
            diagonal=np.array([parent[i:i+6,i:i+6].toarray() for i in range(0,pn,6)])
            W=sp.block_diag(np.array([la.solve_triangular(la.cholesky(d,lower=True),np.eye(6),lower=True) for d in diagonal]),format='csr')
            symmetric=(W@parent@W.T).toarray()
            values,vectors=la.eigh(symmetric,subset_by_index=[0,127])
            assert np.min(values)>0
            basis=W.T@vectors
            record['preparation_ms']['asset_modes_host']=1000*(time.monotonic()-start)
            record['smallest_parent_eigenvalues']=values.tolist();save()
            for step in [0,1]:
                path=a.inputs/f'solve-{step}';manifest=json.loads((path/'manifest.json').read_text())
                n=manifest['matrices']['A']['rows'];m=manifest['matrices']['B']['columns'];k=manifest['nrhs']
                A=checks.matrix(path/'A',(n,n));B=checks.matrix(path/'B',(n,m))
                restriction=np.fromfile(path/'restriction.i32','<i4')
                inverse=np.fromfile(path/'inverse.f64','<f8').reshape(-1,6,6)
                rhs=np.fromfile(path/'rhs.f64','<f8').reshape(k,n)
                warm=np.fromfile(path/'warm.f64','<f8').reshape(k,m)
                original=np.fromfile(path/'original.f64','<f8').reshape(k,n)
                threshold=np.fromfile(path/'threshold.f64','<f8')
                for rank in record['ranks']:
                    V=basis[restriction,:rank];start=time.monotonic()
                    # This is the current operator, even though the basis is old.
                    coarse=V.T@(A@V);factor=la.cho_factor(coarse,lower=True)
                    setup=1000*(time.monotonic()-start)
                    destination=a.output/f'solve-{step}-rank-{rank}'
                    destination.mkdir()
                    np.asarray(V.T,dtype='<f8').tofile(destination/'basis.f64')
                    np.asarray(la.cho_solve(factor,np.eye(rank)),dtype='<f8').tofile(destination/'inverse.f64')
                    def apply(r):
                        return np.einsum('nij,nj->ni',inverse,r.reshape(-1,6)).ravel()+V@la.cho_solve(factor,V.T@r)
                    for column in [0,4,24]:
                        _,result=prepared.solve(A,B,rhs[column],warm[column],original[column],threshold[column],apply)
                        row=dict(solve=step,rank=rank,component=manifest['components'][column]['component'],
                                 current_coarse_setup_host_ms=setup,**result)
                        record['cases'].append(row);save();print(json.dumps(row),flush=True)
            record['status']='work_screen_complete_not_runtime_qualification'
        except BaseException as error:record.update(status='failed',error=repr(error));save();raise
        save()


if __name__=='__main__':main()
