#!/usr/bin/env python3
"""Offline mathematical/work screen on captured native peak stress problems.

This is an independent FP64 oracle, not a production solver or GPU timing test.
It never substitutes its iteration counts for native measured convergence.
"""
import argparse, hashlib, json
from pathlib import Path
import numpy as np
import scipy.linalg as la
import scipy.sparse as sp
from scipy.sparse.csgraph import reverse_cuthill_mckee
from scipy.sparse.linalg import spsolve_triangular

NODE = np.dtype([('inertia','<f4',(2,)),('rhs','<f4',(6,)),('residual','<f4',(6,)),
                 ('threshold','<f4'),('component','<u4')])
BOND = np.dtype([('first','<u4'),('second','<u4'),('offset0','<f4',(3,)),('offset1','<f4',(3,)),
                 ('health','<f4'),('scale','<f4'),('warm','<f4',(6,))])
INVALID=2**32-1

def require(ok, why):
    if not ok: raise ValueError(why)

def skew(v):
    x,y,z=v
    return np.array([[0,-z,y],[z,0,-x],[-y,x,0]],dtype=np.float64)

def assemble(nodes,bonds,identity):
    members=np.flatnonzero(nodes['component']==identity)
    require(len(members)>0,'empty selected component')
    labels=nodes['component']
    selected=np.flatnonzero((bonds['health']>0)&((labels[bonds['first']]==identity)|(labels[bonds['second']]==identity)))
    local=np.full(len(nodes),-1,dtype=np.int64);local[members]=np.arange(len(members))
    rows=[];cols=[];values=[];anchored=False
    for edge,source in enumerate(selected):
        bond=bonds[source]
        for side,key in enumerate(['first','second']):
            node=int(bond[key]);index=local[node]
            if index<0:
                require(np.all(nodes['inertia'][node]==0),'live bond crosses distinct dynamic components')
                anchored=True;continue
            block=np.eye(6);block[:3,3:]=-skew(bond['offset'+str(side)])
            block[:3]*=float(nodes['inertia'][node][0]);block[3:]*=float(nodes['inertia'][node][1])
            block*=float(bond['scale'])*(1 if side==0 else -1)
            r,c=np.nonzero(block)
            rows.extend((6*index+r).tolist());cols.extend((6*edge+c).tolist());values.extend(block[r,c].tolist())
    B=sp.coo_matrix((values,(rows,cols)),shape=(6*len(members),6*len(selected))).tocsr()
    original=nodes['rhs'][members].astype(np.float64).ravel()
    warm=bonds['warm'][selected].astype(np.float64).ravel()
    residual=original-B@warm
    captured=nodes['residual'][members].astype(np.float64).ravel()
    # Native snapshot stores the float result of an ordered FP64 warm gather.
    # Allow only FP32 rounding scaled by actual cancellation operands.
    cancellation=np.abs(original)+abs(B)@np.abs(warm)+1
    error=float(np.max(np.abs(captured-residual)/cancellation))
    require(error<=8*np.finfo(np.float32).eps,'captured warm residual disagrees with independent physical B assembly')
    thresholds=nodes['threshold'][members]
    require(np.all(thresholds==thresholds[0]) and thresholds[0]>=0,'inconsistent component acceptance threshold')
    A=(B@B.T).tocsr();A.eliminate_zeros()
    require(anchored,'this work screen currently requires an anchored/SPD component')
    return A,B,residual,float(thresholds[0]),dict(nodes=len(members),bonds=len(selected),capture_residual_scaled_error=error)

def block_graph(A):
    b=A.tobsr(blocksize=(6,6));n=A.shape[0]//6
    graph=sp.csr_matrix((np.ones(len(b.indices)),b.indices,b.indptr),shape=(n,n))
    graph.setdiag(0);graph.eliminate_zeros()
    return graph

def polynomial(A):
    n=A.shape[0]//6
    diagonal=np.array([A[6*i:6*i+6,6*i:6*i+6].toarray() for i in range(n)])
    inverse=np.linalg.inv(diagonal)
    D=sp.block_diag(diagonal,format='csr');E=A-D
    def apply(r):
        z=np.einsum('nij,nj->ni',inverse,r.reshape(n,6)).ravel()
        return (0.5779388123770052+2.6335678180143502-0.5779388123770052*2.6335678180143502)*z-0.5779388123770052*2.6335678180143502*np.einsum('nij,nj->ni',inverse,(E@z).reshape(n,6)).ravel()
    return apply,dict(dependency_levels=2,factor_block_products=0,apply_block_products=2*n+block_graph(A).nnz)

def ordering(A,name):
    graph=block_graph(A);n=graph.shape[0]
    if name=='natural':return np.arange(n)
    if name=='rcm':return reverse_cuthill_mckee(graph,symmetric_mode=True)
    colors=np.full(n,-1,dtype=np.int64)
    for i in sorted(range(n),key=lambda i:-(graph.indptr[i+1]-graph.indptr[i])):
        used=set(colors[graph.indices[graph.indptr[i]:graph.indptr[i+1]]]);color=0
        while color in used:color+=1
        colors[i]=color
    return np.argsort(colors,kind='stable')

def incomplete_cholesky(A,name):
    order=ordering(A,name);permutation=(6*order[:,None]+np.arange(6)).ravel()
    matrix=A[permutation,:][:,permutation].tobsr(blocksize=(6,6));n=len(order)
    factors=[];depth=[];products=0
    for i in range(n):
        row={int(matrix.indices[k]):matrix.data[k] for k in range(matrix.indptr[i],matrix.indptr[i+1])}
        out={};prior=sorted(j for j in row if j<i)
        for j in prior:
            value=row[j].copy()
            for k in sorted(set(out)&set(factors[j])):
                value-=out[k]@factors[j][k].T;products+=1
            out[j]=la.solve_triangular(factors[j][j],value.T,lower=True,check_finite=False).T
        value=row[i].copy()
        for block in out.values():value-=block@block.T;products+=1
        out[i]=la.cholesky(value,lower=True,check_finite=True)
        depth.append(1+max((depth[j] for j in prior),default=0));factors.append(out)
    data=[];indices=[];indptr=[0]
    for row in factors:
        for j in sorted(row):indices.append(j);data.append(row[j])
        indptr.append(len(indices))
    L=sp.bsr_matrix((np.array(data),np.array(indices),np.array(indptr)),shape=A.shape).tocsr();L.eliminate_zeros()
    U=L.T.tocsr()
    def apply(r):
        low=spsolve_triangular(L,r[permutation],lower=True)
        high=spsolve_triangular(U,low,lower=False)
        result=np.empty_like(high);result[permutation]=high;return result
    return apply,dict(dependency_levels=2*max(depth),max_level_width=int(np.max(np.bincount(depth))),
                     factor_block_products=products,apply_block_products=2*(len(indices)-n)+2*n)

def cg(A,B,rhs,threshold,apply,limit=8192):
    x=np.zeros_like(rhs);r=rhs.copy();p=None;previous=0;verifications=0
    for iteration in range(limit+1):
        g=B.T@r;energy=float(g@g)
        if energy<=threshold:
            r=rhs-A@x;g=B.T@r;energy=float(g@g);verifications+=1
            if energy<=threshold:return dict(converged=True,updates=iteration,gradient_squared=energy,threshold=threshold,verifications=verifications)
            p=None
        if iteration==limit:break
        z=r.copy() if iteration==0 else apply(r)
        gamma=float(r@z);require(gamma>0 and np.isfinite(gamma),'preconditioner is not positive on residual')
        p=z if p is None or iteration==1 else z+(gamma/previous)*p
        q=A@p;bp=B.T@p;denominator=float(bp@bp)
        require(denominator>0 and np.isfinite(denominator),'invalid direction energy')
        alpha=gamma/denominator;x+=alpha*p;r-=alpha*q;previous=gamma
    return dict(converged=False,updates=limit,gradient_squared=energy,threshold=threshold,verifications=verifications)

def assess(A,B,rhs,threshold):
    results=[]
    for name in ['polynomial','ic0-natural','ic0-rcm','ic0-color']:
        try:
            apply,work=polynomial(A) if name=='polynomial' else incomplete_cholesky(A,name.removeprefix('ic0-'))
            result=cg(A,B,rhs,threshold,apply)
            result.update(work)
            result['precondition_block_products']=max(0,result['updates']-1)*work['apply_block_products']
            result['sequential_level_visits']=max(0,result['updates']-1)*work['dependency_levels']
            results.append(dict(method=name,**result))
        except (ValueError,np.linalg.LinAlgError) as error:results.append(dict(method=name,error=str(error),converged=False))
    return results

def self_test():
    nodes=np.zeros(4,dtype=NODE);nodes['inertia'][1:]=[1,2];nodes['component'][0]=INVALID;nodes['component'][1:]=1
    nodes['rhs'][3]=[1,2,3,4,5,6];nodes['residual']=nodes['rhs'];nodes['threshold']=1e-12
    bonds=np.zeros(3,dtype=BOND);bonds['first']=[0,1,2];bonds['second']=[1,2,3];bonds['offset0']=[0,.5,0];bonds['offset1']=[0,-.5,0];bonds['scale']=1;bonds['health']=1
    A,B,rhs,threshold,info=assemble(nodes,bonds,1)
    inverse,work=incomplete_cholesky(A,'natural');solution=inverse(rhs)
    require(np.allclose(solution,np.linalg.solve(A.toarray(),rhs),rtol=1e-11,atol=1e-11),'tree IC0 differs from independent dense solve')
    require(cg(A,B,rhs,threshold,inverse)['converged'],'controlled tree failed convergence')
    broken=nodes.copy();broken['residual'][1,0]=100
    try:assemble(broken,bonds,1)
    except ValueError:pass
    else:raise ValueError('corrupted snapshot passed physical residual validation')
    print('offline oracle self-test: 3 dynamic nodes + 1 support / 3 bonds; exact tree factor, true residual and corruption rejection passed')

def main():
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path,nargs='?');p.add_argument('output',type=Path,nargs='?');p.add_argument('--per-solve',type=int,default=2);p.add_argument('--self-test',action='store_true');args=p.parse_args()
    self_test()
    if args.self_test:return
    require(args.capture and args.output,'capture and fresh output are required');require(not args.output.exists(),'output already exists')
    snapshots=sorted(args.capture.glob('problem.solve-*.json'))
    wanted={json.loads(path.read_text())['solve'] for path in snapshots};require(wanted,'no problem snapshots')
    records=[]
    with (args.capture/'components.jsonl').open() as f:
        for line in f:
            row=json.loads(line)
            if row['solve']>max(wanted):break
            if row['solve'] in wanted:records.append(row)
    output=[];hashes={}
    for path in snapshots:
        meta=json.loads(path.read_text());require(meta['version']==1 and meta['record_bytes']==64 and meta['endian']=='little','unsupported problem schema')
        base=str(path)[:-5];npth=Path(base+'.nodes.bin');bpth=Path(base+'.bonds.bin')
        require(npth.stat().st_size==meta['node_count']*NODE.itemsize and bpth.stat().st_size==meta['bond_count']*BOND.itemsize,'incorrect snapshot byte length')
        nodes=np.fromfile(npth,dtype=NODE);bonds=np.fromfile(bpth,dtype=BOND)
        require(len(nodes)==meta['node_count'] and len(bonds)==meta['bond_count'],'truncated problem capture')
        require(np.all(bonds['first']<len(nodes)) and np.all(bonds['second']<len(nodes)),'invalid endpoint')
        for source in [path,npth,bpth]:hashes[str(source)]=hashlib.file_digest(source.open('rb'),'sha256').hexdigest()
        choices=sorted((r for r in records if r['record']=='component' and r['solve']==meta['solve'] and r['path']==1 and r['anchored'] and r['nodes']>=32),key=lambda r:-r['precondition_sweeps']*r['nodes'])[:args.per_solve]
        require(choices,'no anchored peak components')
        for r in choices:
            print('ASSESS',meta['solve'],r['id'],r['nodes'],flush=True)
            A,B,rhs,threshold,info=assemble(nodes,bonds,r['id'])
            result=dict(solve=meta['solve'],component=r['id'],native_record=r,**info,methods=assess(A,B,rhs,threshold));output.append(result)
            print(json.dumps(result),flush=True)
    require(output,'no problem snapshots');args.output.mkdir(parents=True)
    data=dict(status='complete',kind='offline_fp64_mathematical_work_screen',source_hashes=hashes,problems=output)
    (args.output/'assessment.json').write_text(json.dumps(data,indent=2))
    lines=['# Offline screen of captured peak stress problems','','Actual native equations, warm bond state and loads are captured before iteration. This independent FP64 model uses the captured acceptance threshold. Its iteration counts differ from the native mixed-precision recurrence. **These are not GPU timings, end-to-end speedups or a physics qualification.**','','Each IC0 factorization is rebuilt for this assessment. Factorization products and triangular dependency depth remain costs that a CUDA implementation must pay; fewer iterations alone do not imply faster simulation. No production solver or physical setting was changed.','']
    for r in output:
        lines += [f"## Solve {r['solve']}, component {r['component']}: {r['nodes']} dynamic nodes, {r['bonds']} incident live bonds",'',f"Native captured updates: {r['native_record']['iterations']}; independent warm-residual scaled discrepancy: {r['capture_residual_scaled_error']:.3g}.",'','| Method | FP64 updates | True gradient² / threshold | Precondition block products | Sequential level visits | Factor block products |','|---|---:|---:|---:|---:|---:|']
        for m in r['methods']:
            if 'error' in m:lines.append(f"| {m['method']} | rejected: {m['error']} | — | — | — | — |")
            else:lines.append(f"| {m['method']} | {m['updates']}{'' if m['converged'] else ' (failed)'} | {m['gradient_squared']/m['threshold']:.3g} | {m['precondition_block_products']:,} | {m['sequential_level_visits']:,} | {m['factor_block_products']:,} |")
        lines.append('')
    (args.output/'report.md').write_text('\n'.join(lines));print(args.output/'report.md')

if __name__=='__main__':main()
