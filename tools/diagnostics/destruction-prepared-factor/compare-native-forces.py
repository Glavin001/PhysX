#!/usr/bin/env python3
"""Compare replay forces with saved native outputs using the unchanged force gate.

This is a compatibility gate, not a claim that the native approximation is a
strong mathematical reference. It never replaces material/trajectory checks.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import numpy as np

ROOT=Path(__file__).resolve().parents[3]
spec=importlib.util.spec_from_file_location('checks',Path(__file__).with_name('check.py'))
checks=importlib.util.module_from_spec(spec);spec.loader.exec_module(checks)
CAPTURE=ROOT/'out/n24-native-equation-worlds-20260912'
BOND=np.dtype([('first','<u4'),('second','<u4'),('offset0','<f4',(3,)),
               ('offset1','<f4',(3,)),('health','<f4'),('scale','<f4'),('warm','<f4',(6,))])

def sha(path):return hashlib.sha256(path.read_bytes()).hexdigest()

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('inputs',type=Path);p.add_argument('run',type=Path)
    p.add_argument('output',type=Path)
    args=p.parse_args()
    if args.output.exists():raise FileExistsError(args.output)
    proof=json.loads((CAPTURE/'strong-suite/campaign.json').read_text())['physical_export_mapping']['proof'][0]
    units=np.array([proof['angular_scale']]*3+[proof['linear_scale']]*3,dtype='<f4')
    # Revalidate the exact normalized-to-physical export identity before applying
    # the physical checker bound to any alternative numerical output.
    final=CAPTURE/'A-problem.world-0.solve-1'
    bonds=np.fromfile(str(final)+'.bonds.bin',BOND)
    normalized=np.fromfile(str(final)+'.solution.bin','<f4').reshape(-1,6)
    published=CAPTURE/'A-capture/observation-0-bond-forces.bin'
    assert sha(published)==proof['published_sha256']
    assert np.array_equal(normalized*(bonds['scale'][:,None]*units),np.fromfile(published,'<f4').reshape(-1,6))
    record=dict(scope=__doc__,physical_scaled_bound=2e-4,cases=[],inputs={str(published):sha(published)})
    for step in [0,1]:
        src=args.inputs/f'solve-{step}'
        manifest=json.loads((src/'manifest.json').read_text())
        n,m,k=manifest['matrices']['A']['rows'],manifest['matrices']['B']['columns'],manifest['nrhs']
        B=checks.matrix(src/'B',(n,m));warm=np.fromfile(src/'warm.f64','<f8').reshape(k,m).T
        prefix=CAPTURE/f'A-problem.world-0.solve-{step}'
        bond_path=Path(str(prefix)+'.bonds.bin');solution=Path(str(prefix)+'.solution.bin')
        bonds=np.fromfile(bond_path,BOND);native=np.fromfile(solution,'<f4').reshape(-1,6)
        record['inputs'].update({str(path):sha(path) for path in [bond_path,solution,src/'manifest.json']})
        paths=sorted(args.run.glob(f'solve-{step}.solution-*.f64'))
        if len(paths)!=6:raise ValueError('Missing first/repeated replay outputs')
        for path in paths:
            X=np.fromfile(path,'<f8').reshape(k,-1).T
            if X.shape[0]!=n:
                restriction=np.fromfile(src/'restriction.i32','<i4')
                assert X.shape[0]==manifest['parent_rows'] and len(restriction)==n
                X=X[restriction]
            force=(warm+B.T@X).astype('<f4')
            for column,component in enumerate(manifest['components']):
                ids_path=CAPTURE/f'strong-suite/solve-{step}-component-{component["component"]}/bond-ids.u32'
                ids=np.fromfile(ids_path,'<u4')
                assert len(ids)*6==m
                coefficient=bonds['scale'][ids,None]*units
                expected=(native[ids]*coefficient).astype(float)
                actual=(force[:,column].reshape(-1,6)*coefficient).astype(float)
                error=np.abs(actual-expected)/np.maximum(1,np.maximum(np.abs(actual),np.abs(expected)))
                row=dict(solve=step,component=component['component'],output=str(path),
                         output_sha256=sha(path),maximum_scaled=float(error.max()),
                         fields_above_bound=int(np.count_nonzero(error>2e-4)),
                         passed=bool(np.isfinite(actual).all() and np.all(error<=2e-4)))
                record['cases'].append(row)
    record.update(checked_systems=len(record['cases']),passed_systems=sum(r['passed'] for r in record['cases']))
    record['passed']=record['checked_systems']==record['passed_systems']
    args.output.parent.mkdir(parents=True,exist_ok=True)
    args.output.write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({k:v for k,v in record.items() if k not in ['cases','inputs','scope']}))
    if not record['passed']:raise SystemExit(1)

if __name__=='__main__':main()
