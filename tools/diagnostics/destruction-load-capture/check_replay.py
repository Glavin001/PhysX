#!/usr/bin/env python3
"""Independent Newton–Euler check of native surface+gravity numerical replay."""
import argparse
import json
from pathlib import Path
import numpy as np
from analyze import CHUNK, MASS, BODY, read, peak

RECEIPT=np.dtype([('tick','<u8'),('input_generation','<u8'),('ownership_generation','<u8'),
 ('evaluation','<u4'),('complete','<u4'),('seconds','<f8'),('status','<u4'),('supported','<u4'),
 ('mass','<f8'),('center','<f8',(3,)),('acceleration','<f8',(3,)),('alpha','<f8',(3,)),
 ('force_defect','<f8'),('torque_defect','<f8')])
assert RECEIPT.itemsize==144

def check(directory,prefix):
 m=json.loads((directory/'manifest.json').read_text())
 get=lambda name,dtype:read(directory,m,name,dtype)
 chunks,mass=get('chunks',CHUNK),get('mass',MASS)
 poses=get('poses',('<f4',(7,))).astype(float)
 surface=get('surface',('<f4',(12,))).astype(float)
 bodies=get('bodies',BODY)
 groups=chunks['cluster'];count=len(poses);n=len(chunks)
 def sum_groups(x):
  out=np.zeros((count,*x.shape[1:]),dtype=float);np.add.at(out,groups,x);return out
 # Explicit normalized rotation matrices, independent of the GPU cross helper.
 q=poses[:,:4];q=q/np.linalg.norm(q,axis=1)[:,None];x,y,z,w=q.T
 rotation=np.array([1-2*(y*y+z*z),2*(x*y-z*w),2*(x*z+y*w),
  2*(x*y+z*w),1-2*(x*x+z*z),2*(y*z-x*w),
  2*(x*z-y*w),2*(y*z+x*w),1-2*(x*x+y*y)]).T.reshape(-1,3,3)
 rotate_inv=lambda v:np.einsum('gji,gj->gi',rotation,v)
 omega=rotate_inv(bodies['angular'].astype(float))
 gravity=rotate_inv(np.broadcast_to(m['gravity'],(count,3)))
 M=sum_groups(mass['mass'])
 anchors=get('active_roots','<u4');origin=mass['center'][anchors]
 center=origin+sum_groups(mass['mass'][:,None]*(mass['center']-origin[groups]))/M[:,None]
 r=mass['center']-center[groups]
 offset=mass['center']-chunks['position']
 a=mass['inertia'];I=np.stack([a[:,0],a[:,3],a[:,4],a[:,3],a[:,1],a[:,5],a[:,4],a[:,5],a[:,2]],axis=1).reshape(-1,3,3)
 Ig=sum_groups(I+mass['mass'][:,None,None]*(np.eye(3)*np.sum(r*r,axis=1)[:,None,None]-r[:,:,None]*r[:,None,:]))
 force=surface[:,:3]+mass['mass'][:,None]*gravity[groups]
 torque=surface[:,3:6]+np.cross(offset,mass['mass'][:,None]*gravity[groups])
 net_force=sum_groups(force)
 net_torque=sum_groups(torque+np.cross(chunks['position']-center[groups],force))
 supported=sum_groups(mass['supported'])!=0
 accel=net_force/M[:,None];alpha=np.linalg.solve(Ig,(net_torque-np.cross(omega,np.einsum('gij,gj->gi',Ig,omega)))[...,None])[...,0]
 accel[supported]=0;alpha[supported]=0
 wnode,anode=omega[groups],alpha[groups]
 inertial_force=mass['mass'][:,None]*(accel[groups]+np.cross(anode,r)+np.cross(wnode,np.cross(wnode,r)))
 inertial_torque=np.einsum('nij,nj->ni',I,anode)+np.cross(wnode,np.einsum('nij,nj->ni',I,wnode))+np.cross(offset,inertial_force)
 expected=np.column_stack([force-inertial_force,torque-inertial_torque])
 # An unconstrained one-node aggregate spans only rigid DOFs. The exact
 # internal response is zero; do not manufacture an oracle subtraction error.
 singleton=(np.bincount(groups,minlength=count)==1)&~supported
 expected[singleton[groups]]=0
 actual=np.fromfile(str(prefix)+'.effective.bin',dtype='<f8').reshape(n,6)
 receipt=np.fromfile(str(prefix)+'.receipts.bin',dtype=RECEIPT)
 assert len(receipt)==count and np.all(receipt['status']==0)
 for name,expected_value in [('tick',m['tick']),('input_generation',m['response_epoch']),('ownership_generation',m['ownership_generation']),
                             ('evaluation',m['evaluation']),('seconds',m['seconds']),('complete',1)]:
  assert np.all(receipt[name]==expected_value),name
 assert np.array_equal(receipt['supported']!=0,supported)
 result={'tick':m['tick'],'evaluation':m['evaluation'],'clusters':count,'chunks':n,'checks':{}}
 values=[('effective',actual,expected),('mass',receipt['mass'],M),('center',receipt['center'],center),
         ('acceleration',receipt['acceleration'],accel),('alpha',receipt['alpha'],alpha)]
 passed=True
 for name,observed,reference in values:
  # Same comparison as the existing independent standalone load test.
  error=np.abs(observed-reference);limit=2e-11*(1+np.abs(reference))
  ok=np.isfinite(observed)&(error<=limit);passed &= bool(np.all(ok))
  result['checks'][name]={'max_absolute_error':peak(error),'max_fraction_of_limit':peak(error/limit),'failed_values':int(np.count_nonzero(~ok))}
 result['passed']=passed
 return result

def main():
 p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('replays',type=Path)
 a=p.parse_args();results=[check(a.capture/f'solve-{i}',a.replays/f'solve-{i}') for i in [0,82,83,130]]
 (a.replays/'reference-check.json').write_text(json.dumps(results,indent=2)+'\n');print(json.dumps(results,indent=2))
 assert all(r['passed'] for r in results),'Independent native-load numerical comparison failed'
if __name__=='__main__':main()
