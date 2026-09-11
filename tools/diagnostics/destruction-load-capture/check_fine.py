#!/usr/bin/env python3
"""Independent extended-precision fine-equation check of recorded-load solves."""
import argparse
import json
from pathlib import Path
import numpy as np
from analyze import CHUNK, MASS, read
from check_replay import check as check_loads

BOND = np.dtype([('first','<u4'),('second','<u4'),('live','<u4'),('padding','<u4'),
                 ('point','<f8',(3,)),('frame','<f8',(3,3)),('stiffness','<f8',(6,6)),('inelastic','<f8',(6,))])
RECEIPT = np.dtype([('status','<u4'),('iterations','<u4'),('restarts','<u4'),('checks','<u4'),
                    ('norm','<f8'),('force','<f8'),('torque','<f8'),('compatibility','<f8')])

def check(directory, prefix):
    metadata=json.loads((directory/'manifest.json').read_text())
    profile=json.loads(Path(str(prefix)+'.profile.json').read_text())
    assert BOND.itemsize==profile['bond_stride']==448
    chunks=read(directory,metadata,'chunks',CHUNK)
    mass=read(directory,metadata,'mass',MASS)
    active=read(directory,metadata,'active_bonds','<u4')!=0
    bonds=np.fromfile(str(prefix)+'.bonds.bin',dtype=BOND)
    receipts=np.fromfile(str(prefix)+'.fine-receipts.bin',dtype=RECEIPT)
    converged=bool(np.all(receipts['status']==0))
    get=lambda name: np.fromfile(str(prefix)+'.'+name+'.bin',dtype='<f8').reshape(-1,6)
    suffix='solution' if converged else 'iterate'
    q=get(suffix).astype(np.longdouble)
    rhs=get('rhs').astype(np.longdouble)
    owner=np.fromfile(str(prefix)+'.owners.bin',dtype='<u4')
    unknown=owner!=np.iinfo(np.uint32).max
    assert np.array_equal(~unknown,mass['supported']!=0), 'this replay requires all authored chunks active'
    assert len(bonds)==len(active) and len(q)==len(chunks)==len(owner)
    assert np.array_equal(get('fine-loads'),get('effective')), 'load join changed applied wrenches'
    q[~unknown]=0
    e=bonds[active];a,b=e['first'],e['second']
    positions=chunks['position'].astype(np.longdouble)
    point=e['point'].astype(np.longdouble);ra=point-positions[a];rb=point-positions[b]
    rotation=e['frame'].astype(np.longdouble)
    delta=np.column_stack([q[b,:3]-q[a,:3]+np.cross(q[b,3:],rb)-np.cross(q[a,3:],ra),q[b,3:]-q[a,3:]])
    local=np.column_stack([np.einsum('bji,bj->bi',rotation,delta[:,:3]),np.einsum('bji,bj->bi',rotation,delta[:,3:])])
    stress=np.einsum('bij,bj->bi',e['stiffness'].astype(np.longdouble),local)
    force=np.einsum('bij,bj->bi',rotation,stress[:,:3]);moment=np.einsum('bij,bj->bi',rotation,stress[:,3:])
    applied=np.zeros_like(q)
    np.add.at(applied,a,np.column_stack([-force,-moment-np.cross(ra,force)]))
    np.add.at(applied,b,np.column_stack([force,moment+np.cross(rb,force)]))
    residual=applied-rhs;residual[~unknown]=0
    force_error=np.sqrt(np.sum(residual[:,:3]**2,axis=1))/profile['force_scale']
    torque_error=np.sqrt(np.sum(residual[:,3:]**2,axis=1))/profile['torque_scale']
    norms=np.zeros(len(receipts),dtype=np.longdouble);rhs_norms=np.zeros_like(norms)
    np.add.at(norms,owner[unknown],np.sum(residual[unknown]**2,axis=1))
    np.add.at(rhs_norms,owner[unknown],np.sum(rhs[unknown]**2,axis=1))
    limits=profile['absolute_tolerance']+profile['relative_tolerance']*np.sqrt(rhs_norms)
    equations=bool(np.all(np.sqrt(norms)<=limits) and np.all(force_error<=profile['force_tolerance']) and
                   np.all(torque_error<=profile['torque_tolerance']))
    load_check=check_loads(directory,prefix)
    result=dict(converged=converged,iterate=suffix,components=len(receipts),unknowns=int(np.count_nonzero(unknown)),
                rejected=int(np.count_nonzero(receipts['status'])),iterations_total=int(receipts['iterations'].sum()),
                iterations_max=int(receipts['iterations'].max(initial=0)),restarts_total=int(receipts['restarts'].sum()),
                residual_checks=int(receipts['checks'].sum()),force_error=float(np.max(force_error,initial=0)),
                torque_error=float(np.max(torque_error,initial=0)),norm_error=float(np.max(np.sqrt(norms),initial=0)),
                fine_equations_passed=equations,load_check=load_check,extended_precision_bits=np.finfo(np.longdouble).nmant)
    result['status_counts']={str(int(status)):int(np.count_nonzero(receipts['status']==status)) for status in np.unique(receipts['status'])}
    result['balance_by_status']={}
    for status in [0,1]:
        mask=np.zeros(len(owner),dtype=bool);mask[unknown]=receipts['status'][owner[unknown]]==status
        if np.any(mask):result['balance_by_status'][str(status)]=dict(force=float(np.max(force_error[mask])),torque=float(np.max(torque_error[mask])),
            max_iterate=float(np.max(np.abs(q[mask]))),max_spacing=float(np.max(np.abs(np.spacing(np.asarray(q[mask],dtype=np.float64))))))
    if converged:
        # Recover independently with the serialized zero prescribed/inelastic profile.
        assert not np.any(e['inelastic']) and profile['inelastic']==0 and profile['prescribed_motion']==0
        recovered=get('response').astype(np.longdouble)
        energy=np.fromfile(str(prefix)+'.energy.bin',dtype='<f8').astype(np.longdouble)
        ref=np.zeros_like(recovered);ref[active]=stress
        expected_energy=np.zeros_like(energy);expected_energy[active]=np.sum(local*stress,axis=1)/2
        response_ok=bool(np.all(np.abs(recovered-ref)<=2e-11*(1+np.abs(ref))))
        energy_ok=bool(np.all(np.abs(energy-expected_energy)<=2e-11*(1+np.abs(expected_energy))))
        result.update(response_passed=response_ok,energy_passed=energy_ok)
    result['passed']=converged and equations and load_check['passed'] and result.get('response_passed',False) and result.get('energy_passed',False)
    Path(str(prefix)+'.check.json').write_text(json.dumps(result,indent=2)+'\n')
    return result

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('prefix',type=Path)
    a=p.parse_args();r=check(a.capture,a.prefix);print(json.dumps(r,indent=2));raise SystemExit(0 if r['passed'] else 1)
