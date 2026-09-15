"""80-digit native B B^T reference, with independent bond-form residual checks."""
import argparse,collections,hashlib,importlib.util,json,time
from decimal import Decimal as D,localcontext
from pathlib import Path
import numpy as np
from scipy.sparse import csc_matrix
from scipy.sparse.linalg import splu
root=Path(__file__).resolve().parents[2]
spec=importlib.util.spec_from_file_location('p',root/'tools/scripts/assess-native-stress-problems.py');p=importlib.util.module_from_spec(spec);spec.loader.exec_module(p)
decimal=lambda x:D.from_float(float(x))
parser=argparse.ArgumentParser(description=__doc__);parser.add_argument('prefix',type=Path);parser.add_argument('other',type=Path);parser.add_argument('component',type=int);parser.add_argument('output',type=Path);a=parser.parse_args()
a.output.mkdir(exist_ok=False);begin=time.monotonic()
nodes=np.fromfile(str(a.prefix)+'.nodes.bin',p.NODE);bonds=np.fromfile(str(a.prefix)+'.bonds.bin',p.BOND)
nodes2=np.fromfile(str(a.other)+'.nodes.bin',p.NODE);bonds2=np.fromfile(str(a.other)+'.bonds.bin',p.BOND)
for field in nodes.dtype.names:
 if field!='threshold':assert np.array_equal(nodes[field],nodes2[field]),field
assert np.array_equal(bonds,bonds2),'operator/warm inputs differ'
A,B,_,_,info=p.assemble(nodes,bonds,a.component);ids=np.flatnonzero(nodes['component']==a.component);index={int(v):i for i,v in enumerate(ids)};labels=nodes['component']
selected=np.flatnonzero((bonds['health']>0)&((labels[bonds['first']]==a.component)|(labels[bonds['second']]==a.component)))
size=6*len(ids);columns=[]
with localcontext() as context:
 context.prec=80
 for edge in selected:
  e=bonds[edge];cols=[{} for _ in range(6)]
  for side,key in enumerate(['first','second']):
   native=int(e[key])
   if native not in index:assert np.all(nodes['inertia'][native]==0);continue
   node=index[native];x,y,z=map(decimal,e['offset'+str(side)]);negative_skew=[[D(0),z,-y],[-z,D(0),x],[y,-x,D(0)]]
   d=list(map(decimal,nodes['inertia'][native]));scale=decimal(e['scale'])*D(1 if side==0 else -1)
   for i in range(3):
    cols[i][6*node+i]=scale*d[0];cols[3+i][6*node+3+i]=scale*d[1]
    for j in range(3):
     v=scale*d[0]*negative_skew[i][j]
     if v:cols[3+j][6*node+i]=v
  columns+=cols
 warm=list(map(decimal,bonds['warm'][selected].ravel()));rhs=list(map(decimal,nodes['rhs'][ids].ravel()))
 def apply_b(force):
  result=[D(0)]*size
  for col,f in zip(columns,force):
   for i,v in col.items():result[i]+=v*f
  return result
 def apply_bt(value):return [sum((v*value[i] for i,v in col.items()),D(0)) for col in columns]
 bw=apply_b(warm);residual_rhs=[r-w for r,w in zip(rhs,bw)]
 entries=collections.defaultdict(D)
 for col in columns:
  for i,x in col.items():
   for j,y in col.items():entries[i,j]+=x*y
 entries={k:v for k,v in entries.items() if v};assert all(v==entries[j,i] for (i,j),v in entries.items())
 rows=[[] for _ in range(size)]
 for (i,j),v in sorted(entries.items()):rows[i].append((j,v))
 matrix=csc_matrix(([float(v) for v in entries.values()],tuple(zip(*entries))),shape=(size,size));factor=splu(matrix)
 def residual(x):return [residual_rhs[i]-sum((v*x[j] for j,v in row),D(0)) for i,row in enumerate(rows)]
 solution=[D(0)]*size;history=[]
 for k in range(9):
  r=residual(solution);rn=sum((v*v for v in r),D(0)).sqrt();history.append(dict(correction=k,residual_norm=str(rn)))
  if rn<D('1e-35'):break
  delta=factor.solve(np.array(list(map(float,r))));assert np.isfinite(delta).all();solution=[x+decimal(v) for x,v in zip(solution,delta)]
 assert rn<D('1e-35'),'reference refinement did not converge'
 expected=[w+d for w,d in zip(warm,apply_bt(solution))];balance=[r-v for r,v in zip(rhs,apply_b(expected))];discrepancy=max(abs(x-y) for x,y in zip(r,balance));assert discrepancy<D('1e-50')
 expected64=np.array(list(map(float,expected)));expected64.tofile(a.output/'normalized-reference.f64');selected.astype('<u4').tofile(a.output/'bond-ids.u32')
 reports=[]
 for prefix in [a.prefix,a.other]:
  actual=np.fromfile(str(prefix)+'.solution.bin','<f4').reshape(-1,6)[selected].ravel();diff=[decimal(x)-y for x,y in zip(actual,expected)]
  reports.append(dict(prefix=str(prefix),normalized_max_scaled_error=float(max(abs(e)/max(D(1),abs(decimal(x)),abs(y)) for e,x,y in zip(diff,actual,expected))),normalized_relative_l2_error=float((sum(e*e for e in diff)/sum(v*v for v in expected)).sqrt())))
 result=dict(status='strong_reference_passed_not_runtime_qualification',component=a.component,**info,decimal_digits=80,matrix_nonzeros=len(entries),refinement=history,bond_form_residual_norm=str(sum(v*v for v in balance).sqrt()),assembled_vs_bond_form_max=str(discrepancy),arms=reports,elapsed_seconds=time.monotonic()-begin,script_sha256=hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),scope='Exact captured coefficient arithmetic at80 decimal digits; same anchored native problem in both arms. No physical output scaling, free components, material acceptance or timing claim.')
 (a.output/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
