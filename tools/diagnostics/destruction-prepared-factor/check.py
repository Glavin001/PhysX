#!/usr/bin/env python3
"""Independent current-force checks on every saved GPU replay output."""
import argparse
import hashlib
import json
from pathlib import Path
import numpy as np
from scipy.sparse import csr_matrix


def matrix(prefix, shape):
    return csr_matrix((np.fromfile(str(prefix)+'.values.f64','<f8'),
                       np.fromfile(str(prefix)+'.cols.i32','<i4'),
                       np.fromfile(str(prefix)+'.rows.i32','<i4')),shape=shape)


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('inputs',type=Path);p.add_argument('run',type=Path)
    p.add_argument('--solve',type=int,choices=[0,1],help='Check a deliberately single-pass profile')
    a = p.parse_args()
    report = dict(scope='GPU replay; current captured force acceptance only, not material/trajectory qualification',cases=[])
    for step in ([a.solve] if a.solve is not None else [0,1]):
        source=a.inputs/f'solve-{step}'
        manifest=json.loads((source/'manifest.json').read_text())
        n=manifest['matrices']['A']['rows'];m=manifest['matrices']['B']['columns'];k=manifest['nrhs']
        B=matrix(source/'B',(n,m))
        original=np.fromfile(source/'original.f64','<f8').reshape(k,n).T
        warm=np.fromfile(source/'warm.f64','<f8').reshape(k,m).T
        thresholds=np.fromfile(source/'threshold.f64','<f8')
        case=dict(solve=step,outputs=[])
        for path in sorted(a.run.glob(f'solve-{step}.solution-*.f64')):
            X=np.fromfile(path,'<f8').reshape(k,n).T
            if not np.isfinite(X).all():raise ValueError('nonfinite output')
            F=(warm+B.T@X).astype(np.float32).astype(np.float64)
            gradient=B.T@(original-B@F)
            energy=np.sum(gradient*gradient,axis=0)
            case['outputs'].append(dict(path=str(path),sha256=hashlib.sha256(path.read_bytes()).hexdigest(),
                                        accepted=(energy<=thresholds).tolist(),threshold_ratios=(energy/thresholds).tolist()))
        if len(case['outputs'])!=6:raise ValueError('missing first/repeated outputs')
        report['cases'].append(case)
    report['checked_current_systems']=sum(len(o['accepted']) for c in report['cases'] for o in c['outputs'])
    report['passed']=all(all(o['accepted']) for c in report['cases'] for o in c['outputs'])
    (a.run/'quality.json').write_text(json.dumps(report,indent=2)+'\n')
    print(json.dumps(dict(passed=report['passed'],checked_current_systems=report['checked_current_systems'],
                         worst_threshold_ratio=max(max(o['threshold_ratios']) for c in report['cases'] for o in c['outputs']))))
    if not report['passed']:raise SystemExit(1)


if __name__=='__main__':main()
