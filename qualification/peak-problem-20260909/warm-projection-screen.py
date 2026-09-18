import importlib.util,json
from pathlib import Path
import numpy as np
from scipy.sparse.linalg import spsolve
s=importlib.util.spec_from_file_location('assess','tools/scripts/assess-native-stress-problems.py');a=importlib.util.module_from_spec(s);s.loader.exec_module(a)
root=Path('out/peak-problem-20260909/capture')
old=np.fromfile(root/'problem.solve-50.nodes.bin',dtype=a.NODE);oldb=np.fromfile(root/'problem.solve-50.bonds.bin',dtype=a.BOND)
new=np.fromfile(root/'problem.solve-51.nodes.bin',dtype=a.NODE);newb=np.fromfile(root/'problem.solve-51.bonds.bin',dtype=a.BOND)
report=json.loads(Path('qualification/peak-problem-20260909/assessment.json').read_text());results=[]
for row in report['problems']:
 if row['solve']!=51:continue
 identity=row['component'];ids=np.flatnonzero(new['component']==identity);parents=np.unique(old['component'][ids]);guess=np.zeros((len(ids),6));parents_info=[]
 for parent in parents:
  if parent==a.INVALID:continue
  A,B,r,t,info=a.assemble(old,oldb,int(parent));pids=np.flatnonzero(old['component']==parent)
  mu=spsolve(A,old['rhs'][pids].astype(np.float64).ravel()).reshape(-1,6)
  take=old['component'][ids]==parent;guess[take]=mu[np.searchsorted(pids,ids[take])]
  parents_info.append(dict(component=int(parent),**info))
 A,B,r,t,info=a.assemble(new,newb,identity);apply,work=a.polynomial(A)
 cold=a.cg(A,B,r,t,apply);projected=new['rhs'][ids].astype(np.float64).ravel()-A@guess.ravel()
 projected_result=a.cg(A,B,projected,t,apply)
 item=dict(component=identity,parents=parents_info,nodes=len(ids),native_cold_updates=row['native_record']['iterations'],oracle_cold=cold,oracle_reprojected=projected_result)
 results.append(item);print(json.dumps(item),flush=True)
Path('out/peak-problem-20260909/warm-projection.json').write_text(json.dumps(results,indent=2))
