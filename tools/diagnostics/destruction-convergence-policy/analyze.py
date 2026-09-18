#!/usr/bin/env python3
"""Summarize finite-budget effects without treating changed physics as equivalent."""
import csv,hashlib,importlib.util,json,math,statistics as st
from pathlib import Path
import numpy as np
ROOT=Path(__file__).resolve().parents[3];OUT=ROOT/'out/destruction-convergence-policy-20260913/screen';REPORT=ROOT/'reports/destruction-convergence-policy-20260913'
def compare(a,b):
 result={}
 for name in ['bond-forces','health','active-bonds','chunk-clusters','node-accelerations','surface-loads','crush']:
  dtype='<u4' if name in ['active-bonds','chunk-clusters'] else '<f4'
  x=np.fromfile(a/f'observation-0-{name}.bin',dtype=dtype);y=np.fromfile(b/f'observation-0-{name}.bin',dtype=dtype)
  assert x.shape==y.shape;d=(x.astype(float)-y.astype(float));row=dict(changed_scalars=int(np.count_nonzero(d)),total_scalars=int(x.size))
  if dtype=='<f4':
   assert np.isfinite(x).all() and np.isfinite(y).all();row.update(max_absolute=float(np.max(np.abs(d),initial=0)))
  if name=='bond-forces':
   row['relative_l2']=float(np.linalg.norm(d)/max(np.linalg.norm(x.astype(float)),1e-300))
   for label,part in [('torque',slice(0,3)),('force',slice(3,6))]:
    a0=x.astype(float).reshape(-1,6)[:,part];delta=d.reshape(-1,6)[:,part]
    row[label+'_relative_l2']=float(np.linalg.norm(delta)/max(np.linalg.norm(a0),1e-300))
   row['maximum_scaled']=float(np.max(np.abs(d)/np.maximum(1,np.maximum(np.abs(x),np.abs(y))),initial=0))
  if name=='health':row['broken_identity_differences']=int(np.count_nonzero((x<=0)!=(y<=0)))
  if name=='chunk-clusters':
   def canonical(v):
    _,index,inverse=np.unique(v,return_index=True,return_inverse=True);return index[inverse]
   row['physical_partition_equal']=bool(np.array_equal(canonical(x),canonical(y)))
  result[name]=row
 ax=json.loads((a/'observation-0-objects.json').read_text());by=json.loads((b/'observation-0-objects.json').read_text());fields=ax['fields'];assert fields==by['fields']
 x={v[0]:v for v in ax['objects']};y={v[0]:v for v in by['objects']};common=x.keys()&y.keys();m=dict(common_objects=len(common),unmatched_objects=len(x.keys()^y.keys()),changed_role_mass=0,maximum_position_m=0,maximum_linear_m_s=0,maximum_angular_rad_s=0)
 for k in common:
  a0,b0=x[k],y[k];m['changed_role_mass']+=a0[:6]!=b0[:6]
  for field,outkey in [('pose_xyz','maximum_position_m'),('linear_xyz','maximum_linear_m_s'),('angular_xyz','maximum_angular_rad_s')]:
   i=fields.index(field);m[outkey]=max(m[outkey],math.dist(a0[i],b0[i]))
 result['objects']=m
 return result
def main():
 screen=json.loads((OUT/'screen.json').read_text());assert screen['status']=='complete'
 result=dict(screen_sha256=hashlib.sha256((OUT/'screen.json').read_bytes()).hexdigest(),scenarios=[],scope=screen['scope'])
 checkerpath=ROOT/'reports/destruction-exact-solve-reuse/evidence/physical-checker.py';spec=importlib.util.spec_from_file_location('frozen',checkerpath);checker=importlib.util.module_from_spec(spec);spec.loader.exec_module(checker)
 for row in screen['scenarios']:
  x=dict(case=row['case'],mode=row['mode'],runs=row['runs']);result['scenarios'].append(x)
  if row['mode']=='restored':
   ref=Path(row['runs']['strict']['raw']);x['comparison']={}
   for arm in ['tolerance','cap32','vibe32']:
    target=Path(row['runs'][arm]['raw']);diff=compare(ref,target)
    try:diff['original_checker']=checker.compare(ref,target)
    except Exception as e:diff['original_checker']=dict(status='failed',first_failure=str(e))
    x['comparison'][arm]=diff
   if row['case']=='city25-initial-impact':
    result['rebuild_negative_control']=checker.compare(Path(screen['original_control']['raw']),ref)
  else:
   x['arms']={}
   refpaths=[Path(row['runs']['strict-'+str(i)]['raw'])/'native/native.frames.csv' for i in range(2)]
   reference=[list(csv.DictReader(p.open())) for p in refpaths]
   for arm in ['strict','tolerance','cap32','vibe32']:
    runs=[row['runs'][arm+'-'+str(i)] for i in range(2)]
    frames=[list(csv.DictReader((Path(r['raw'])/'native/native.frames.csv').open())) for r in runs]
    keys=['bodies','awake_bodies','logical_clusters','contacts_frame','stress_active_nodes','stress_active_bonds','stress_islands','bonds_broken','resim_passes','post_correction_bonds_broken','stress_passes']
    diff={k:[sum(a[k]!=b[k] for a,b in zip(reference[i],frames[i])) for i in range(2)] for k in keys}
    x['arms'][arm]=dict(mean_ms=st.mean(r['mean_ms'] for r in runs),range_ms=[min(r['mean_ms'] for r in runs),max(r['mean_ms'] for r in runs)],peak_ms=max(r['max_ms'] for r in runs),misses=sum(r['over_60hz'] for r in runs),unconverged=sum(r['unconverged_ticks'] for r in runs),broken=[r['total_broken'] for r in runs],different_ticks=diff)
 (REPORT/'results.json').write_text(json.dumps(result,indent=2)+'\n')
 print(json.dumps(result,indent=2))
if __name__=='__main__':main()
