#!/usr/bin/env python3
"""Attribute setup-only replay rejections with independent extended precision.

This inspects the last rigid mode tested by GPU setup. It does not turn a failed
setup into an accepted solve or change any tolerance. Outputs from anchored rows
and unprepared modes are never interpreted as tested nullspace vectors.
"""
import argparse
import json
from pathlib import Path
import numpy as np
from analyze import CHUNK, MASS, read
from check_fine import BOND

SETUP = np.dtype([('key','<u8',(7,)), ('length','<f8'), ('rank','<f8'),
                  ('nullspace','<f8'), ('pivot','<f8'), ('status','<u4'),
                  ('free','<u4'), ('builds','<u4'), ('factors','<u4')])

def inspect(directory, prefix):
    meta=json.loads((directory/'manifest.json').read_text())
    profile=json.loads(Path(str(prefix)+'.profile.json').read_text())
    assert profile['setup_only'] and SETUP.itemsize==104
    chunks=read(directory,meta,'chunks',CHUNK)
    mass=read(directory,meta,'mass',MASS)
    active=read(directory,meta,'active_bonds','<u4')!=0
    bonds=np.fromfile(str(prefix)+'.bonds.bin',dtype=BOND)[active]
    states=np.fromfile(str(prefix)+'.setup.bin',dtype=SETUP)
    owner=np.fromfile(str(prefix)+'.owners.bin',dtype='<u4')
    unknown=owner!=np.iinfo(np.uint32).max
    assert np.array_equal(~unknown,mass['supported']!=0)
    count=len(states)
    q=np.fromfile(str(prefix)+'.mode.bin',dtype='<f8').reshape(-1,6).astype(np.longdouble)
    gpu=np.fromfile(str(prefix)+'.mode-action.bin',dtype='<f8').reshape(-1,6).astype(np.longdouble)
    assert len(q)==len(gpu)==len(owner)==len(chunks)
    q[~unknown]=0
    a,b=bonds['first'],bonds['second']
    free=np.ones(count,dtype=bool)
    for first,second in [(a,b),(b,a)]:
        mask=unknown[first]&~unknown[second]
        free[owner[first[mask]]]=False
    # The current diagnostic uses unit length; don't silently reinterpret a
    # future scaling recipe or nonzero prescribed-motion profile.
    assert np.all(states['length']==1) and profile['prescribed_motion']==0
    point=bonds['point'].astype(np.longdouble)
    positions=chunks['position'].astype(np.longdouble)
    ra,rb=point-positions[a],point-positions[b]
    frame=bonds['frame'].astype(np.longdouble)
    stiffness=bonds['stiffness'].astype(np.longdouble)
    def apply(vector):
        delta=np.column_stack([vector[b,:3]-vector[a,:3]+np.cross(vector[b,3:],rb)-np.cross(vector[a,3:],ra),vector[b,3:]-vector[a,3:]])
        local=np.column_stack([np.einsum('bji,bj->bi',frame,delta[:,:3]),np.einsum('bji,bj->bi',frame,delta[:,3:])])
        stress=np.einsum('bij,bj->bi',stiffness,local)
        force=np.einsum('bij,bj->bi',frame,stress[:,:3]);torque=np.einsum('bij,bj->bi',frame,stress[:,3:])
        action=np.zeros_like(vector)
        np.add.at(action,a,np.column_stack([-force,-torque-np.cross(ra,force)]))
        np.add.at(action,b,np.column_stack([force,torque+np.cross(rb,force)]))
        return action
    def norm(vector):
        result=np.zeros(count,dtype=np.longdouble)
        np.add.at(result,owner[unknown],np.sum(vector[unknown]**2,axis=1))
        return np.sqrt(result)
    sizes=np.bincount(owner[unknown],minlength=count)
    gpu_norm,true_norm,mode_norm=norm(gpu),norm(apply(q)),norm(q)
    # Check every mode of every accepted free basis, not merely its last mode.
    # Rejected components may have incomplete bases and are inspected above.
    basis=np.fromfile(str(prefix)+'.basis.bin',dtype='<f8').reshape(len(owner),6,6)
    ready=(states['status']==1)&free
    ready_nodes=np.zeros(len(owner),dtype=bool);ready_nodes[unknown]=ready[owner[unknown]]
    all_defects=np.zeros((count,6),dtype=np.longdouble)
    for mode in range(6):
        vector=basis[:,:,mode].astype(np.longdouble);vector[~ready_nodes]=0
        all_defects[:,mode]=norm(apply(vector))
    ready_max=np.max(all_defects,axis=1)
    ready_failed=ready & (~np.isfinite(ready_max) | (ready_max>states['nullspace']))
    rows=[]
    for i in np.flatnonzero(free):
        rows.append(dict(component=int(i),nodes=int(sizes[i]),status=int(states['status'][i]),
                         mode_norm=float(mode_norm[i]),gpu_defect=float(gpu_norm[i]),
                         independent_defect=float(true_norm[i]),limit=float(states['nullspace'][i])))
    rejected=[r for r in rows if r['status']==3]
    result=dict(scope='setup-only; no solve, material evaluation or physics advances',
                components=count,free_components=len(rows),extended_precision_bits=np.finfo(np.longdouble).nmant,
                status_counts={str(int(s)):int(np.count_nonzero(states['status']==s)) for s in np.unique(states['status'])},
                rejected_free=len(rejected),rejected_anchored=int(np.count_nonzero((states['status']==3)&~free)),
                rejected_last_mode_normalized=sum(abs(r['mode_norm']-1)<1e-12 for r in rejected),
                rejected_gpu_defect_above_limit=sum(r['gpu_defect']>r['limit'] for r in rejected),
                rejected_independent_defect_above_limit=sum(r['independent_defect']>r['limit'] for r in rejected),
                rejected_independent_defect_max=max((r['independent_defect'] for r in rejected),default=0),
                ready_free_components=int(np.count_nonzero(ready)),
                ready_modes_checked=6*int(np.count_nonzero(ready)),
                ready_independent_defect_max=float(np.max(ready_max[ready],initial=0)),
                ready_independent_failures=int(np.count_nonzero(ready_failed)),
                components_detail=rows)
    Path(str(prefix)+'.setup-check.json').write_text(json.dumps(result,indent=2)+'\n')
    return result

if __name__=='__main__':
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('capture',type=Path);parser.add_argument('prefix',type=Path)
    args=parser.parse_args();result=inspect(args.capture,args.prefix)
    print(json.dumps({k:v for k,v in result.items() if k!='components_detail'},indent=2))
    raise SystemExit(1 if result['ready_independent_failures'] else 0)
