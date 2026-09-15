#!/usr/bin/env python3
"""Independent whole-world coefficient and dirty-product validation."""
import argparse
import json
from pathlib import Path
import numpy as np


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('reference',type=Path)
    parser.add_argument('output',type=Path)
    args=parser.parse_args()
    manifest=json.loads((args.reference/'report.json').read_text())
    entries,batch=manifest['nnz'],manifest['uniform_batch']
    for name in ['pattern.rows.i32','pattern.cols.i32']:
        np.testing.assert_array_equal(np.fromfile(args.reference/name,'<i4'),np.fromfile(args.output/name,'<i4'))
    expected=[np.fromfile(args.reference/f'solve-{i}.values.f64','<f8').reshape(batch,entries) for i in [0,1]]
    mixed=expected[0].copy();mixed[::2]=expected[1][::2]
    record=dict(scope='Full coefficient matrices and dirty-product behavior; no application qualification',epochs=[])
    for epoch,want in enumerate([expected[0],expected[0],mixed,expected[1],expected[0]]):
        got=np.fromfile(args.output/f'epoch-{epoch}.values.f64','<f8').reshape(batch,entries)
        # Independent assembly may sum contributions in a different order.
        scaled=np.max(np.abs(got-want)/(1+np.abs(want)))
        record['epochs'].append(dict(epoch=epoch,coefficient_count=got.size,max_scaled_error=float(scaled),passed=bool(np.isfinite(got).all() and scaled<=1e-12)))
    record['passed']=all(row['passed'] for row in record['epochs'])
    with (args.output/'quality.json').open('x') as stream:json.dump(record,stream,indent=2)
    print(json.dumps(record,indent=2))
    if not record['passed']:raise SystemExit(1)


if __name__=='__main__':main()
