"""Host feasibility oracle for exactly shared native operators, not a GPU benchmark."""
from pathlib import Path
import argparse,hashlib,importlib.util,json,os,statistics,time
assert os.environ.get('OPENBLAS_NUM_THREADS')=='1'
import numpy as np
from scipy.sparse.linalg import splu
root=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('native_problem',root/'tools/scripts/assess-native-stress-problems.py');p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('output',type=Path);parser.add_argument('--identities',type=Path,required=True);parser.add_argument('--capture-dir',type=Path,required=True);parser.add_argument('--reference-dir',type=Path,required=True);args=parser.parse_args();args.output.mkdir(exist_ok=False)
source=args.capture_dir.resolve();identities=json.loads(args.identities.read_text());record={'status':'running','scope':'CPU-only sparse LU feasibility on captured native anchored operators, one city25 snapshot/2stress passes. Host timings, not GPU/application estimates; no runtime implementation or promotion. Full force/material/snapshot gates remain unchanged.','groups':[],'commands':{'OPENBLAS_NUM_THREADS':os.environ['OPENBLAS_NUM_THREADS']},'source_identity_sha256':hashlib.sha256(args.identities.read_bytes()).hexdigest()}
def save():(args.output/'report.json').write_text(json.dumps(record,indent=2)+'\n')
def times(values):return dict(samples_ms=values,mean_ms=statistics.mean(values),min_ms=min(values),max_ms=max(values))
def canonical(nodes,bonds,identity):
 ns=np.flatnonzero(nodes['component']==identity);labels=nodes['component'];es=np.flatnonzero((bonds['health']>0)&(bonds['scale']!=0)&((labels[bonds['first']]==identity)|(labels[bonds['second']]==identity)));local={int(n):i for i,n in enumerate(ns)}
 ends=np.array([[local.get(int(bonds['first'][e]),-1),local.get(int(bonds['second'][e]),-1)] for e in es],dtype='<i4')
 # Exact byte comparison after hash grouping; no hash-only aliasing.
 # Compare individual fields; structured selection can retain unrelated padding.
 coeff=(nodes['inertia'][ns].tobytes(),ends.tobytes(),*(bonds[f][es].tobytes() for f in ['offset0','offset1','health','scale']))
 return ns,es,coeff
try:
 for case in identities['solves']:
  for name,digest in case['sources'].items():assert hashlib.sha256((source/Path(name).name).read_bytes()).hexdigest()==digest
  step=case['solve'];prefix=source/('A-problem.world-0.solve-'+str(step));nodes=np.fromfile(str(prefix)+'.nodes.bin',p.NODE);bonds=np.fromfile(str(prefix)+'.bonds.bin',p.BOND)
  selected=[r for r in case['components'] if r['anchored']];groups={}
  for r in selected:groups.setdefault(r['coefficients'],[]).append(r)
  for identity,members in groups.items():
   representative=members[0]['id'];ns,es,coeff=canonical(nodes,bonds,representative);A,B,_,_,info=p.assemble(nodes,bonds,representative);matrix=A.tocsc();matrix.sort_indices();rhs=[];warms=[];references=[];bounds=[]
   for m in members:
    ids,edges,c=canonical(nodes,bonds,m['id']);assert c==coeff,'Hash collision or inconsistent canonical mapping'
    warm=bonds['warm'][edges].astype(np.float64).ravel();rhs.append(nodes['rhs'][ids].astype(np.float64).ravel()-B@warm);warms.append(warm);bounds.append(float(nodes['threshold'][ids[0]]))
    ref=args.reference_dir.resolve()/('solve-'+str(step)+'-component-'+str(m['id']));receipt=json.loads((ref/'result.json').read_text());assert receipt['status']=='strong_reference_passed_not_runtime_qualification';assert np.array_equal(np.fromfile(ref/'bond-ids.u32','<u4'),edges)
    references.append(np.fromfile(ref/'normalized-reference.f64','<f8'))
   R=np.asfortranarray(np.stack(rhs,axis=1));W=np.stack(warms,axis=1);expected=np.stack(references,axis=1)
   group={'solve':step,'representative':representative,'matrix_rows':matrix.shape[0],'matrix_nnz':matrix.nnz,'rhs_count':R.shape[1],'members':[m['id'] for m in members],'orders':[]};record['groups'].append(group);save()
   for ordering in ['COLAMD','MMD_AT_PLUS_A']:
    factor_times=[]
    for _ in range(5):
     begin=time.perf_counter();factor=splu(matrix,permc_spec=ordering);factor_times.append(1000*(time.perf_counter()-begin))
    solve_times=[]
    for _ in range(20):
     begin=time.perf_counter();X=factor.solve(R);solve_times.append(1000*(time.perf_counter()-begin))
    residual=R-matrix@X;F=W+B.T@X;balance=R-B@(F-W)
    scaling=np.maximum(1,np.maximum(np.abs(F),np.abs(expected)));errors=np.max(np.abs(F-expected)/scaling,axis=0)
    rel=np.linalg.norm(F-expected,axis=0)/np.maximum(np.linalg.norm(expected,axis=0),1e-300)
    assert np.isfinite(X).all() and np.isfinite(errors).all()
    byte_count=sum(v.nbytes for f in [factor.L,factor.U] for v in [f.data,f.indices,f.indptr])+factor.perm_r.nbytes+factor.perm_c.nbytes
    entry={'ordering':ordering,'factor_host':times(factor_times),'batch_solve_host':times(solve_times),'factor_L_nnz':factor.L.nnz,'factor_U_nnz':factor.U.nnz,'factor_stored_bytes':byte_count,'fill_ratio_L_plus_U':(factor.L.nnz+factor.U.nnz)/matrix.nnz,'per_component_scaled_force_error_to_strong_reference':errors.tolist(),'per_component_relative_force_l2_to_strong_reference':rel.tolist(),'max_scaled_force_error_to_strong_reference':float(errors.max()),'max_relative_force_l2_to_strong_reference':float(rel.max()),'max_bond_form_residual_norm':float(np.linalg.norm(balance,axis=0).max()),'max_assembled_residual_norm':float(np.linalg.norm(residual,axis=0).max()),'captured_threshold_min':min(bounds),'captured_threshold_max':max(bounds),'normalized_coordinate_gate_2e_4_pass':bool(np.all(errors<=2e-4))}
    group['orders'].append(entry);save()
 record['status']='host_factor_feasibility_complete_not_runtime_qualification'
except BaseException as e:record.update(status='failed',error=repr(e));save();raise
save()
