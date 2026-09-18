#!/usr/bin/env python3
"""Strong supported-component reference; never part of the native runtime.

Assemble G^T D G in Decimal arithmetic, use sparse FP64 LU for corrections,
retain an 80-digit iterate, and independently check the bond-form equations.
Compare the reference with both FP64 rounding and a two-word representation.
This diagnoses precision; it does not certify a production material profile.
"""
import argparse
from collections import defaultdict
from decimal import Decimal as D, localcontext
import hashlib
import json
from pathlib import Path
import time
import numpy as np
import scipy
from scipy.sparse import csc_matrix, save_npz
from scipy.sparse.linalg import splu
from analyze import CHUNK, MASS, read
from check_fine import BOND

def decimal(x):
    return D.from_float(float(x))

def run(capture, prefix, component, output, stalled=None, candidate=None):
    output.mkdir(parents=True,exist_ok=False)
    started=time.monotonic()
    meta=json.loads((capture/'manifest.json').read_text())
    profile=json.loads(Path(str(prefix)+'.profile.json').read_text())
    assert profile['prescribed_motion']==0 and profile['inelastic']==0
    chunks=read(capture,meta,'chunks',CHUNK)
    mass=read(capture,meta,'mass',MASS)
    active=read(capture,meta,'active_bonds','<u4')!=0
    all_bonds=np.fromfile(str(prefix)+'.bonds.bin',dtype=BOND)
    starts=np.fromfile(str(prefix)+'.starts.bin',dtype='<u4')
    nodes=np.fromfile(str(prefix)+'.nodes.bin',dtype='<u4')
    owners=np.fromfile(str(prefix)+'.owners.bin',dtype='<u4')
    if component<0:component=int(np.argmax(np.diff(starts)))
    assert 0<=component<len(starts)-1
    ids=nodes[starts[component]:starts[component+1]]
    assert len(ids) and np.all(owners[ids]==component) and not np.any(mass['supported'][ids])
    index={int(i):j for j,i in enumerate(ids)}
    mask=active & (np.isin(all_bonds['first'],ids)|np.isin(all_bonds['second'],ids))
    bond_ids=np.flatnonzero(mask);bonds=all_bonds[mask]
    endpoints=np.unique(np.r_[bonds['first'],bonds['second']])
    fixed=[int(i) for i in endpoints if int(i) not in index]
    assert fixed and np.all(mass['supported'][fixed]),'reference requires a closed, anchored component'
    rhs_all=np.fromfile(str(prefix)+'.rhs.bin',dtype='<f8').reshape(-1,6)
    rhs=[decimal(v) for v in rhs_all[ids].ravel()]
    size=len(rhs);entries=defaultdict(D);operators=[]
    with localcontext() as context:
        context.prec=80
        for e in bonds:
            assert not np.any(e['inelastic'])
            rows=[{} for _ in range(6)]
            for native,sign in [(int(e['first']),-1),(int(e['second']),1)]:
                if native not in index:continue # explicit zero prescribed coordinates
                node=index[native]
                r=[decimal(e['point'][k])-decimal(chunks['position'][native,k]) for k in range(3)]
                minus_skew=[[D(0),r[2],-r[1]],[-r[2],D(0),r[0]],[r[1],-r[0],D(0)]]
                for local in range(3):
                    for world in range(3):
                        value=D(sign)*decimal(e['frame'][world,local])
                        if value:
                            rows[local][6*node+world]=value
                            rows[3+local][6*node+3+world]=value
                    for axis in range(3):
                        value=D(sign)*sum((decimal(e['frame'][world,local])*minus_skew[world][axis] for world in range(3)),D(0))
                        if value:rows[local][6*node+3+axis]=value
            stiffness=[[decimal(e['stiffness'][r,c]) for c in range(6)] for r in range(6)]
            operators.append((rows,stiffness))
            for r in range(6):
                for c in range(6):
                    if stiffness[r][c]:
                        for i,gi in rows[r].items():
                            for j,gj in rows[c].items():entries[i,j]+=gi*stiffness[r][c]*gj
        entries={key:value for key,value in entries.items() if value}
        assert all(value==entries.get((j,i),D(0)) for (i,j),value in entries.items()),'matrix symmetry'
        row_lists=[[] for _ in range(size)]
        for (i,j),value in sorted(entries.items()):row_lists[i].append((j,value))
        matrix=csc_matrix(([float(v) for v in entries.values()],tuple(zip(*entries))),shape=(size,size))
        exact_coefficients=all(decimal(float(v))==v for v in entries.values())
        factor=splu(matrix,permc_spec='COLAMD')
        def matrix_residual(x):
            return [rhs[i]-sum((value*x[j] for j,value in row),D(0)) for i,row in enumerate(row_lists)]
        def bond_action(x):
            result=[D(0)]*size
            responses=[];energies=[]
            for rows,stiffness in operators:
                delta=[sum((v*x[j] for j,v in row.items()),D(0)) for row in rows]
                stress=[sum((stiffness[r][c]*delta[c] for c in range(6)),D(0)) for r in range(6)]
                for r,row in enumerate(rows):
                    for i,v in row.items():result[i]+=v*stress[r]
                responses.append(stress);energies.append(sum((a*b for a,b in zip(delta,stress)),D(0))/2)
            return result,responses,energies
        def assess(x):
            action,responses,energy=bond_action(x);residual=[b-a for a,b in zip(action,rhs)]
            norm=sum((v*v for v in residual),D(0)).sqrt()
            force=max(sum((residual[6*i+k]**2 for k in range(3)),D(0)).sqrt() for i in range(len(ids)))
            torque=max(sum((residual[6*i+k]**2 for k in range(3,6)),D(0)).sqrt() for i in range(len(ids)))
            rhs_norm=sum((v*v for v in rhs),D(0)).sqrt()
            limits=(decimal(profile['absolute_tolerance'])+decimal(profile['relative_tolerance'])*rhs_norm,
                    decimal(profile['force_scale'])*decimal(profile['force_tolerance']),
                    decimal(profile['torque_scale'])*decimal(profile['torque_tolerance']))
            comparison=matrix_residual(x)
            discrepancy=max(abs(a-b) for a,b in zip(comparison,residual))
            assert discrepancy<D('1e-50'),'assembled and bond-form actions disagree'
            return dict(norm=str(norm),force=str(force),torque=str(torque),passed=all(v<=limit for v,limit in zip((norm,force,torque),limits)),
                        assembly_discrepancy=str(discrepancy)),responses,energy
        x=[D(0)]*size;history=[]
        for iteration in range(9):
            residual=matrix_residual(x);norm=sum((v*v for v in residual),D(0)).sqrt()
            history.append(dict(correction=iteration,residual_norm=str(norm)))
            if norm<D('1e-30'):break
            correction=factor.solve(np.asarray([float(v) for v in residual]))
            assert np.all(np.isfinite(correction))
            x=[v+decimal(c) for v,c in zip(x,correction)]
        assert norm<D('1e-30'),'strong-reference refinement did not converge'
        reference,responses,energy=assess(x)
        high=np.asarray([float(v) for v in x]);low=np.asarray([float(v-decimal(h)) for v,h in zip(x,high)])
        rounded,_,_=assess([decimal(v) for v in high])
        pair,_,_=assess([decimal(h)+decimal(l) for h,l in zip(high,low)])
        result=dict(scope='one supported numerical component; CPU reference only',ordinal=meta['ordinal'],component=component,
                    unknown_nodes=len(ids),prescribed_neighbors=len(fixed),live_bonds=len(bonds),scalar_dofs=size,
                    matrix_nonzeros=len(entries),factor_nonzeros=int(factor.L.nnz+factor.U.nnz),
                    matrix_coefficients_exact_in_fp64=exact_coefficients,decimal_digits=context.prec,
                    profile=profile,reference=reference,rounded_fp64=rounded,two_word_fp64=pair,refinement=history,
                    max_solution=float(np.max(np.abs(high))),max_fp64_spacing=float(np.max(np.abs(np.spacing(high)))),
                    numpy=np.__version__,scipy=scipy.__version__)
        if stalled:
            old_owners=np.fromfile(str(stalled)+'.owners.bin',dtype='<u4')
            old_rhs=np.fromfile(str(stalled)+'.rhs.bin',dtype='<f8').reshape(-1,6)
            assert np.array_equal(owners,old_owners) and np.array_equal(rhs_all[ids],old_rhs[ids]),'stalled input changed'
            old_bonds=np.fromfile(str(stalled)+'.bonds.bin',dtype=BOND)
            assert np.array_equal(all_bonds,old_bonds),'stalled operator changed'
            # Captured probe uses unit length, so its scaled iterate is physical q.
            q=np.fromfile(str(stalled)+'.iterate.bin',dtype='<f8').reshape(-1,6)[ids].ravel()
            result['stalled_gpu_iterate']=assess([decimal(v) for v in q])[0]
        if candidate:
            hi=np.fromfile(str(candidate)+'.hi.bin',dtype='<f8')
            lo=np.fromfile(str(candidate)+'.lo.bin',dtype='<f8')
            assert len(hi)==len(lo)==size and np.all(np.isfinite(hi)) and np.all(np.isfinite(lo))
            checked,expected_response,expected_energy=assess([decimal(h)+decimal(l) for h,l in zip(hi,lo)])
            result['gpu_candidate']=checked
            if Path(str(candidate)+'.response.bin').exists():
                response=np.fromfile(str(candidate)+'.response.bin',dtype='<f8').reshape(-1,6)
                energy=np.fromfile(str(candidate)+'.energy.bin',dtype='<f8')
                assert response.shape==(len(bonds),6) and len(energy)==len(bonds)
                tolerance=D('2e-11')
                result['gpu_response_passed']=all(abs(decimal(a)-b)<=tolerance*(1+abs(b)) for a,b in zip(response.ravel(),sum(expected_response,[])))
                result['gpu_energy_passed']=all(abs(decimal(a)-b)<=tolerance*(1+abs(b)) for a,b in zip(energy,expected_energy))
            result['gpu_candidate_receipt']=json.loads(Path(str(candidate)+'.json').read_text())
            result['gpu_candidate_sha256']={str(candidate)+suffix:hashlib.sha256(Path(str(candidate)+suffix).read_bytes()).hexdigest()
                                            for suffix in ['.hi.bin','.lo.bin','.json','.response.bin','.energy.bin'] if Path(str(candidate)+suffix).exists()}
        high.tofile(output/'solution-hi.bin');low.tofile(output/'solution-lo.bin')
        (output/'solution-decimal.json').write_text(json.dumps([str(v) for v in x])+'\n')
        (output/'response-decimal.json').write_text(json.dumps([[str(v) for v in row] for row in responses])+'\n')
        (output/'energy-decimal.json').write_text(json.dumps([str(v) for v in energy])+'\n')
        ids.tofile(output/'unknown-authored-ids.bin');bond_ids.astype('<u4').tofile(output/'live-authored-bond-ids.bin')
        bonds.tofile(output/'bonds.bin');chunks['position'][endpoints].astype('<f8').tofile(output/'positions.bin')
        endpoints.astype('<u4').tofile(output/'position-authored-ids.bin');rhs_all[ids].tofile(output/'rhs.bin')
        np.asarray(fixed,dtype='<u4').tofile(output/'prescribed-authored-ids.bin');save_npz(output/'matrix.npz',matrix)
        result['cpu_diagnostic_seconds']=time.monotonic()-started
        inputs=[capture/'manifest.json',capture/'chunks.bin',capture/'mass.bin',capture/'active_bonds.bin',
                *[Path(str(prefix)+'.'+s) for s in ['profile.json','bonds.bin','rhs.bin','starts.bin','nodes.bin','owners.bin']]]
        result['input_sha256']={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in inputs}
        (output/'report.json').write_text(json.dumps(result,indent=2)+'\n')
        return result

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('capture',type=Path);p.add_argument('prefix',type=Path)
    p.add_argument('output',type=Path);p.add_argument('--component',type=int,default=-1,help='default: largest component')
    p.add_argument('--stalled-prefix',type=Path)
    p.add_argument('--candidate-prefix',type=Path)
    a=p.parse_args();print(json.dumps(run(a.capture,a.prefix,a.component,a.output,a.stalled_prefix,a.candidate_prefix),indent=2))
