from squared_cycle import hierarchy
import numpy as np
from scipy import sparse as sp
from scipy.sparse.linalg import gmres, LinearOperator
for n in [24,128,1024,1028]:
 for smoothed in [False,True]:
    b=np.array([1. if i%4 in (0,3) else -1. for i in range(n)]);d=np.full(n,2.);d[[0,-1]]=1
    a=sp.diags([-np.ones(n-1),d,-np.ones(n-1)],[-1,0,1],format='csr');m,sizes=hierarchy(a,smoothed)
    # Right preconditioning; the residual is in the original coordinates.
    def right(v):return a@m(v)
    history=[]
    y,info=gmres(LinearOperator((n,n),matvec=right),b,restart=32,maxiter=128,rtol=1e-6,atol=0,callback=history.append,callback_type='legacy')
    mu=m(y);rho=b-a@mu;threshold=float(b@(a@b))*1e-10
    print(dict(nodes=n,bonds=n-1,smoothed=smoothed,iterations=len(history),info=info,residual_squared=float(rho@(a@rho)),threshold_squared=threshold,max_force_error=float(np.max(np.abs(np.abs(np.diff(mu))-np.array([1. if i%2==0 else 0 for i in range(n-1)]))))),flush=True)
