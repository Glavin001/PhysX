#!/usr/bin/env python3
"""Audit frozen native contact inputs; these diagnostics do not qualify a solver."""
import argparse
import csv
import json
from pathlib import Path
import numpy as np

CHUNK = np.dtype([('position','<f4',(3,)),('mass','<f4'),('inertia','<f4'),('cluster','<u4'),
                  ('contact','<u4'),('volume','<f4'),('material','<u4')])
MASS = np.dtype([('center','<f8',(3,)),('mass','<f8'),('inertia','<f8',(6,)),('supported','<u4'),('padding','<u4')])
CONTACT = np.dtype([('chunk','<u4'),('point','<f4',(3,)),('impulse','<f4',(3,)),('inverse_seconds','<f4')])
BODY = np.dtype([('linear','<f4',(3,)),('angular','<f4',(3,)),('external_linear','<f4',(3,)),
                 ('external_angular','<f4',(3,)),('damping','<f4',(2,)),('body','<u4'),
                 ('flags','<u4'),('locks','<u4'),('disable_gravity','<u4'),('valid','<u4')])

def read(directory, manifest, name, dtype):
    layout = manifest[name]
    dtype = np.dtype(dtype)
    assert dtype.itemsize == layout['stride'], (name, dtype.itemsize, layout)
    values = np.fromfile(directory/(name+'.bin'), dtype=dtype)
    assert len(values)==layout['count'], name
    return values

def rotate_inverse(q, v):
    # Match the native (possibly slightly nonunit) quaternion polynomial in
    # double precision. This is independent of the adapter's normalized frame.
    xyz, w = q[:,:3], q[:,3:4]
    return 2*(w*w-.5)*v + 2*xyz*np.sum(xyz*v,axis=1)[:,None] - 2*w*np.cross(xyz,v)

def peak(a):
    return float(np.max(np.abs(a),initial=0))

def audit(directory):
    m = json.loads((directory/'manifest.json').read_text())
    get = lambda name, dtype: read(directory,m,name,dtype)
    chunks, mass = get('chunks',CHUNK), get('mass',MASS)
    poses = get('poses',('<f4',(7,))).astype(np.float64)
    surface = get('surface',('<f4',(12,))).astype(np.float64)
    contacts = get('contacts',CONTACT)
    active, roots = get('active_chunks','<u4'), get('chunk_root','<u4')
    active_roots, slots = get('active_roots','<u4'), get('root_slot','<u4')
    slot_roots = get('slot_roots','<u4')
    bodies, checkpoint = get('bodies',BODY), get('checkpoint_bodies',BODY)
    assert m['stage_error']==0 and m['cluster_count']==m['topology_clusters']
    ids = np.flatnonzero(active)
    assert np.all(chunks['cluster'][ids]<len(active_roots))
    assert np.array_equal(active_roots[chunks['cluster'][ids]],roots[ids])
    assert np.array_equal(slot_roots[slots[active_roots]],active_roots)
    assert np.array_equal(np.sort(get('ordered_chunks','<u4')[:len(ids)]), ids)
    assert np.all(mass['mass']>0) and np.all(mass['supported']<=1)
    assert np.array_equal(mass['supported']!=0,chunks['mass']==0)
    a = mass['inertia']
    tensor = np.stack([a[:,0],a[:,3],a[:,4],a[:,3],a[:,1],a[:,5],a[:,4],a[:,5],a[:,2]],axis=1).reshape(-1,3,3)
    assert np.all(np.linalg.eigvalsh(tensor)>0)
    assert np.all(bodies['valid'])
    node = contacts['chunk']
    assert np.all(node<len(chunks)) and np.all(active[node])
    q, origin = poses[chunks['cluster'][node],:4], poses[chunks['cluster'][node],4:]
    assert np.all(contacts['inverse_seconds']==m['inverse_seconds'])
    force = rotate_inverse(q,contacts['impulse'].astype(float))*m['inverse_seconds']
    arm = rotate_inverse(q,contacts['point'].astype(float)-origin)-chunks['position'][node]
    torque = np.cross(arm,force)
    virial = np.column_stack([arm[:,0]*force[:,0],arm[:,1]*force[:,1],arm[:,2]*force[:,2],
                             .5*(arm[:,0]*force[:,1]+arm[:,1]*force[:,0]),
                             .5*(arm[:,0]*force[:,2]+arm[:,2]*force[:,0]),
                             .5*(arm[:,1]*force[:,2]+arm[:,2]*force[:,1])])
    reconstructed = np.zeros_like(surface)
    absolute = np.zeros_like(surface)
    contributions = np.column_stack([force,torque,virial])
    np.add.at(reconstructed,node,contributions)
    np.add.at(absolute,node,np.abs(contributions))
    counts = np.bincount(node,minlength=len(chunks))
    result = {k:m[k] for k in ['ordinal','tick','evaluation','ownership_generation','checkpoint_generation','response_epoch','seconds','inverse_seconds','complete_command_ledger']}
    result.update(chunks=len(chunks),active_chunks=len(ids),bonds=m['bond_endpoints']['count'],
                  live_bonds=int(np.count_nonzero(get('active_bonds','<u4'))),clusters=len(poses),
                  contact_sides=len(contacts),loaded_chunks=int(np.count_nonzero(counts)),
                  max_contact_sides_per_chunk=int(counts.max(initial=0)),
                  topology_mapping_passed=True,full_mass_spd_passed=True,
                  quaternion_norm_error=peak(np.linalg.norm(poses[:,:4],axis=1)-1),
                  checkpoint_missing=int(np.count_nonzero(checkpoint['valid']==0)))
    result['surface_reconstruction']={}
    for key, columns in [('force',slice(0,3)),('torque',slice(3,6)),('virial',slice(6,12))]:
        error = reconstructed[:,columns]-surface[:,columns]
        scale = absolute[:,columns]
        result['surface_reconstruction'][key] = dict(max_absolute_error=peak(error),
            max_absolute_contribution_sum=peak(scale),
            max_error_over_max_1_abs_contribution_sum=peak(error/np.maximum(1,scale)))
    for label,b in [('current',bodies),('checkpoint',checkpoint[checkpoint['valid']!=0])]:
        result[label] = dict(external_linear_max=peak(b['external_linear']),external_angular_max=peak(b['external_angular']),
            linear_velocity_max=peak(b['linear']),angular_velocity_max=peak(b['angular']),
            damping_values=np.unique(b['damping'],axis=0).tolist(),locks=int(np.count_nonzero(b['locks'])),
            gravity_disabled=int(np.count_nonzero(b['disable_gravity'])))
    # Supported aggregates require supplied accelerations; stationary snapshots
    # alone do not prove their full prescribed acceleration history.
    supported = np.zeros(len(poses),dtype=bool)
    np.logical_or.at(supported,chunks['cluster'][ids],mass['supported'][ids]!=0)
    result['supported_aggregates']=int(np.count_nonzero(supported))
    result['supported_velocity_max']=max(peak(bodies['linear'][supported]),peak(bodies['angular'][supported]))
    return result

def main():
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('capture',type=Path)
    p.add_argument('--reference-frames',type=Path)
    args=p.parse_args()
    result={'evaluations':[audit(d) for d in sorted(args.capture.glob('solve-*'),key=lambda d:int(d.name.split('-')[1]))]}
    if args.reference_frames:
        with (args.capture/'scene/native.frames.csv').open() as f: current=list(csv.DictReader(f))
        with args.reference_frames.open() as f: old=list(csv.DictReader(f))
        assert len(current)==len(old)==180
        assert all(row['stress_converged']=='1' and row['correction_status']=='0' and int(row['resim_passes'])<=1 for row in current)
        keys=['bonds_broken','logical_clusters','contacts_frame','resim_passes','stress_passes','stress_active_nodes','stress_active_bonds','stress_iterations']
        result['trajectory_comparison']={key:dict(differing_steps=sum(a[key]!=b[key] for a,b in zip(current,old)),
            first_differing_step=next((int(a['step']) for a,b in zip(current,old) if a[key]!=b[key]),None)) for key in keys}
    (args.capture/'analysis.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))

if __name__=='__main__': main()
