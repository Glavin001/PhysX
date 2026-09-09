#!/usr/bin/env python3
import argparse,importlib.util,json,hashlib
from pathlib import Path
import numpy as np
from scipy.linalg import cho_factor,cho_solve
s=importlib.util.spec_from_file_location('assess',Path(__file__).with_name('assess-native-stress-problems.py'));a=importlib.util.module_from_spec(s);s.loader.exec_module(a)
p=argparse.ArgumentParser(description='Independent FP64 coarse-space work screen, NOT GPU timings.');p.add_argument('capture',type=Path);p.add_argument('assessment',type=Path);p.add_argument('output',type=Path);args=p.parse_args();a.require(not args.output.exists(),'output already exists');root=args.capture;report=json.loads(args.assessment.read_text());results=[]
for row in report['problems']:
 ordinal=row['solve'];identity=row['component'];nodes=np.fromfile(root/f'problem.solve-{ordinal}.nodes.bin',dtype=a.NODE);bonds=np.fromfile(root/f'problem.solve-{ordinal}.bonds.bin',dtype=a.BOND)
 ids=np.flatnonzero(nodes['component']==identity);lookup={int(n):i for i,n in enumerate(ids)};neighbors=[[] for _ in ids]
 for bond in bonds[bonds['health']>0]:
  u=lookup.get(int(bond['first']));v=lookup.get(int(bond['second']))
  if u is not None and v is not None:
   shift=bond['offset0'].astype(np.float64)-bond['offset1'];neighbors[u].append((v,shift));neighbors[v].append((u,-shift))
 positions=np.zeros((len(ids),3));seen={0};queue=[0]
 for u in queue:
  for v,shift in neighbors[u]:
   if v not in seen:positions[v]=positions[u]+shift;seen.add(v);queue.append(v)
 a.require(len(seen)==len(ids),'disconnected captured component')
 positions-=positions.mean(axis=0);span=np.ptp(positions,axis=0);axis=int(np.argmax(span));t=positions[:,axis]/max(span[axis],1e-30)
 Z=np.zeros((len(ids),6,6));inertia=nodes['inertia'][ids].astype(np.float64)
 for i,pos in enumerate(positions):
  Z[i,:3,:3]=np.eye(3)/inertia[i,0];Z[i,3:,:3]=a.skew(pos)/inertia[i,1];Z[i,3:,3:]=np.eye(3)/inertia[i,1]
 A,B,r,threshold,info=a.assemble(nodes,bonds,identity);fine,work=a.polynomial(A);methods=[]
 for degree in range(4):
  basis=np.concatenate([(Z*t[:,None,None]**power).reshape(len(ids)*6,6) for power in range(degree+1)],axis=1)
  basis/=np.linalg.norm(basis,axis=0)
  AZ=A@basis;E=basis.T@AZ;factor=cho_factor(E,lower=True)
  def balanced(x):
   c=cho_solve(factor,basis.T@x);coarse=basis@c
   y=fine(x-AZ@c)
   return coarse+y-basis@cho_solve(factor,AZ.T@y)
  for name,apply in [('balanced',balanced),('additive',lambda x:fine(x)+basis@cho_solve(factor,basis.T@x))]:
   result=a.cg(A,B,r,threshold,apply);result.update(method=name,coarse_dofs=basis.shape[1],coarse_dense_products_per_apply=(4 if name=='balanced' else 2)*basis.size,coarse_solves_per_apply=2 if name=='balanced' else 1);methods.append(result)
 output=dict(solve=ordinal,component=identity,nodes=len(ids),bonds=info['bonds'],native_updates=row['native_record']['iterations'],plain_fp64_updates=row['methods'][0]['updates'],methods=methods)
 results.append(output);print(json.dumps(output),flush=True)
args.output.write_text(json.dumps(dict(kind='offline_fp64_work_screen_not_gpu_timing',assessment_sha256=hashlib.sha256(args.assessment.read_bytes()).hexdigest(),script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),problems=results),indent=2))
