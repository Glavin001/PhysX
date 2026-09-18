import numpy as np
from scipy import sparse as sp
from scipy.linalg import cho_factor, cho_solve

def priority(i,r):
    x=(i+0x9e3779b9*(r+1))&0xffffffff
    x=((x^(x>>16))*0x7feb352d)&0xffffffff
    x=((x^(x>>15))*0x846ca68b)&0xffffffff
    return x^(x>>16)

def aggregate(a):
    n=a.shape[0]; adjacency=[a.indices[a.indptr[i]:a.indptr[i+1]][a.indices[a.indptr[i]:a.indptr[i+1]]!=i] for i in range(n)]
    degree=[len(x) for x in adjacency];owner=np.full(n,-1);r=0
    while np.any(owner<0):
        key=[(degree[i],priority(i,r),i) for i in range(n)]
        seeds=[i for i in range(n) if owner[i]<0 and all(owner[j]>=0 or key[i]>key[j] for j in adjacency[i])]
        seed=set(seeds)
        for i in np.where(owner<0)[0]:
            if i in seed:owner[i]=i
            else:
                options=[j for j in adjacency[i] if j in seed]
                if options:owner[i]=min(options)
        r+=1
    roots={i:min(np.where(owner==i)[0]) for i in set(owner)}
    ids=sorted(roots.values());index={root:i for i,root in enumerate(ids)}
    return sp.csr_matrix((np.ones(n),(np.arange(n),[index[roots[o]] for o in owner])),shape=(n,len(ids)))

def hierarchy(a,smoothed):
    if a.shape[0]<=6:
        dense=a.toarray();dense[0,0]+=dense[0,0]
        f=cho_factor(dense)
        return lambda b:cho_solve(f,b),[a.shape[0]]
    d=a.diagonal();s=sp.diags(.5/d)
    p=aggregate(a)
    if smoothed:p=p-sp.diags((2/3)/d)@a@p
    ac=(p.T@a@p).tocsr();ac.eliminate_zeros()
    coarse,sizes=hierarchy(ac,smoothed)
    def apply(b):
        x=s@b;x+=p@coarse(p.T@(b-a@x));x+=s@(b-a@x)
        return x
    return apply,[a.shape[0]]+sizes

def run(n,smoothed):
    b=np.array([1. if i%4 in (0,3) else -1. for i in range(n)])
    d=np.full(n,2.);d[[0,-1]]=1
    a=sp.diags([-np.ones(n-1),d,-np.ones(n-1)],[-1,0,1],format='csr')
    m,sizes=hierarchy(a,smoothed)
    rho=b.copy();mu=np.zeros(n);p=np.zeros(n);q=np.zeros(n);previous=0
    threshold=float(b@(a@b))*1e-10
    def project(x):return x-x.mean()
    for i in range(129):
        w=a@rho;res=float(rho@w)
        if res<=threshold or i==128:break
        g=project(m(project(m(project(w)))))
        gamma=float(w@g);beta=gamma/previous if i else 0
        p=g+beta*p;q=a@g+beta*q
        alpha=gamma/float(q@q);mu+=alpha*p;rho-=alpha*q;previous=gamma
    force=np.diff(mu)
    print(dict(nodes=n,bonds=n-1,smoothed=smoothed,levels=sizes,iterations=i,residual_squared=res,threshold_squared=threshold,converged=res<=threshold,max_force_error=float(np.max(np.abs(np.abs(force)-np.array([1. if i%2==0 else 0 for i in range(n-1)]))))),flush=True)
if __name__ == '__main__':
    for n in [24,128,1024,1028]:
        for smooth in [False,True]:run(n,smooth)
