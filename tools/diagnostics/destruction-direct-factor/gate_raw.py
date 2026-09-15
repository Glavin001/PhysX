#!/usr/bin/env python3
"""R1 gates (a)(b)(c-real) on raw native captures: assemble every anchored
component of a captured world (nodes/bonds .bin, 64-byte records, same layout
as out/n28-native-factor-20260912/assess-native-stress-problems.py), measure
fill, FP32-factor + FP64-refinement accuracy at the 1e-5 relative-residual gate,
and (when a component's solve-1 bond set is a subset of its solve-0 set) the
Woodbury reuse of the solve-0 FP32 factor for the solve-1 system. Exports FP32
factors for the GPU triangular-solve benchmark. Offline only.
"""
import json, os, sys, time
import numpy as np, scipy.sparse as sp, scipy.sparse.linalg as spla, scipy.linalg as la
prefix = sys.argv[1]; outdir = sys.argv[2]; MINN = int(sys.argv[3]) if len(sys.argv) > 3 else 32
TOL = 1e-5; os.makedirs(outdir + '/factors', exist_ok=True)
NODE = np.dtype([('inertia','<f4',(2,)),('rhs','<f4',(6,)),('residual','<f4',(6,)),('threshold','<f4'),('component','<u4')])
BOND = np.dtype([('first','<u4'),('second','<u4'),('offset0','<f4',(3,)),('offset1','<f4',(3,)),('health','<f4'),('scale','<f4'),('warm','<f4',(6,))])
def skew(v):
    x,y,z = v; return np.array([[0,-z,y],[z,0,-x],[-y,x,0]])
def load(solve):
    return np.fromfile(f'{prefix}.solve-{solve}.nodes.bin', NODE), np.fromfile(f'{prefix}.solve-{solve}.bonds.bin', BOND)
def assemble(nodes, bonds, members, selected):
    local = np.full(len(nodes), -1, np.int64); local[members] = np.arange(len(members))
    rows=[]; cols=[]; vals=[]; anchored=False
    for edge, src in enumerate(selected):
        b = bonds[src]
        for side, key in enumerate(('first','second')):
            node = int(b[key]); idx = local[node]
            if idx < 0: anchored = True; continue
            blk = np.eye(6); blk[:3,3:] = -skew(b['offset'+str(side)])
            blk[:3] *= float(nodes['inertia'][node][0]); blk[3:] *= float(nodes['inertia'][node][1])
            blk *= float(b['scale']) * (1 if side == 0 else -1)
            r, c = np.nonzero(blk); rows.extend((6*idx+r).tolist()); cols.extend((6*edge+c).tolist()); vals.extend(blk[r,c].tolist())
    B = sp.coo_matrix((vals,(rows,cols)), shape=(6*len(members), 6*len(selected))).tocsr()
    return B, anchored
def components(nodes, bonds):
    labels = nodes['component']; live = bonds['health'] > 0
    out = {}
    for ident in np.unique(labels[nodes['inertia'][:,0] > 0]):
        members = np.flatnonzero(labels == ident)
        if len(members) < MINN: continue
        sel = np.flatnonzero(live & ((labels[bonds['first']] == ident) | (labels[bonds['second']] == ident)))
        out[int(ident)] = (members, sel)
    return out
def fp32_refine(Ad, b, c32):
    def s32(r): return la.cho_solve((c32, True), r.astype(np.float32)).astype(np.float64)
    x = s32(b); hist = []
    for it in range(5):
        r = b - Ad @ x; rel = float(np.linalg.norm(r)/np.linalg.norm(b)); hist.append(rel)
        if rel <= TOL: break
        x = x + s32(r)
    return x, hist
t0 = time.time(); worlds = {}
for solve in (0, 1):
    nodes, bonds = load(solve); comps = components(nodes, bonds); worlds[solve] = (nodes, bonds, comps)
    print(f'solve {solve}: nodes {len(nodes)} bonds {len(bonds)} live {(bonds["health"]>0).sum()} components>={MINN}: {len(comps)}', flush=True)
results = []; factors = {}
for solve in (0, 1):
    nodes, bonds, comps = worlds[solve]
    for i, (ident, (members, sel)) in enumerate(sorted(comps.items())):
        B, anchored = assemble(nodes, bonds, members, sel)
        A = (B @ B.T).tocsc(); A.eliminate_zeros(); n = A.shape[0]
        b = (nodes['residual'][members].astype(np.float64)).ravel()
        rec = dict(solve=solve, component=ident, nodes=int(len(members)), bonds=int(len(sel)), rows=n, nnz=int(A.nnz), anchored=bool(anchored), rhs_norm=float(np.linalg.norm(b)))
        if not anchored or np.linalg.norm(b) == 0: rec['skipped'] = 'free or zero rhs'; results.append(rec); continue
        lu = spla.splu(A, permc_spec='MMD_AT_PLUS_A', diag_pivot_thresh=0.0, options=dict(SymmetricMode=True))
        rec['nnzL'] = int(lu.L.nnz - n); rec['perm_symmetric'] = bool(np.array_equal(lu.perm_r, lu.perm_c))
        Ad = A.toarray(); x64 = la.solve(Ad, b, assume_a='pos')
        c32 = la.cholesky(Ad.astype(np.float32), lower=True)
        x, hist = fp32_refine(Ad, b, c32)
        rec['refine_residuals'] = hist; rec['steps_to_gate'] = int(next((k for k,h in enumerate(hist) if h <= TOL), -1))
        rec['rel_err_x'] = float(np.linalg.norm(x-x64)/np.linalg.norm(x64))
        f64 = B.T @ x64; rec['rel_err_bond_force'] = float(np.linalg.norm(B.T @ x - f64)/np.linalg.norm(f64))
        if i % 16 == 0:
            w = la.eigvalsh(Ad); rec['cond'] = float(w[-1]/w[0])
        if solve == 0:
            factors[ident] = (c32, members, sel, Ad, B)
            # export permuted FP32 sparse factor from SuperLU for the GPU benchmark: A = P L (D L^T) P^T
            Lc = sp.tril(lu.L, -1).tocsr(); Ud = lu.U.diagonal(); LT = Lc.T.tocsr()
            base = f'{outdir}/factors/c{ident}'
            np.array([n, Lc.nnz], np.int32).tofile(base + '.meta.i32')
            Lc.indptr.astype(np.int32).tofile(base + '.L.rowptr.i32'); Lc.indices.astype(np.int32).tofile(base + '.L.cols.i32'); Lc.data.astype(np.float32).tofile(base + '.L.vals.f32')
            LT.indptr.astype(np.int32).tofile(base + '.LT.rowptr.i32'); LT.indices.astype(np.int32).tofile(base + '.LT.cols.i32'); LT.data.astype(np.float32).tofile(base + '.LT.vals.f32')
            Ud.astype(np.float32).tofile(base + '.udiag.f32'); lu.perm_r.astype(np.int32).tofile(base + '.perm.i32')
            (b[lu.perm_r]).astype(np.float32).tofile(base + '.rhs.f32')
        else:
            # real successive-pass reuse: same members, bonds(1) subset of bonds(0)?
            prev = factors.get(ident)
            if prev is not None:
                c32p, members0, sel0, A0d, B0 = prev
                if np.array_equal(members0, members):
                    removed = np.setdiff1d(sel0, sel); added = np.setdiff1d(sel, sel0)
                    rec['bonds_removed_since_solve0'] = int(len(removed)); rec['bonds_added'] = int(len(added))
                    if len(added) == 0 and len(removed) > 0:
                        pos = {int(s): j for j, s in enumerate(sel0)}
                        Ucols = np.concatenate([np.arange(6*pos[int(s)], 6*pos[int(s)]+6) for s in removed]); U = B0[:, Ucols].toarray()
                        Ak = A0d - U @ U.T
                        w = la.eigvalsh(Ak); rec['A1_from_A0_minus_UUT_max_diff'] = float(np.abs(Ak - Ad).max()); rec['A1_eig_min'] = float(w[0])
                        if w[0] > 1e-9:
                            def s32(r): return la.cho_solve((c32p, True), np.asarray(r, np.float32)).astype(np.float64)
                            W = s32(U); C = -np.eye(U.shape[1]) + U.T @ W; Cl = la.lu_factor(C)
                            def apply(r):
                                y = s32(r); return y - W @ la.lu_solve(Cl, U.T @ y)
                            xw = apply(b); hw = []
                            for it in range(5):
                                r = b - Ad @ xw; rel = float(np.linalg.norm(r)/np.linalg.norm(b)); hw.append(rel)
                                if rel <= TOL: break
                                xw = xw + apply(r)
                            rec['woodbury_residuals'] = hw; rec['woodbury_rel_err_x'] = float(np.linalg.norm(xw-x64)/np.linalg.norm(x64))
                    elif len(removed) == 0: rec['woodbury'] = 'unchanged operator (factor reusable as is)'
        results.append(rec)
        if i % 32 == 0: print(f'  solve {solve} #{i} comp {ident} nodes {len(members)} rows {n} nnzL {rec.get("nnzL")} steps {rec.get("steps_to_gate")} t={time.time()-t0:.0f}s', flush=True)
done = [r for r in results if 'steps_to_gate' in r]; steps = np.array([r['steps_to_gate'] for r in done])
wb = [r for r in results if 'woodbury_residuals' in r]
summary = dict(prefix=prefix, min_nodes=MINN, anchored_systems=len(done), skipped=len(results)-len(done),
    rows_min=min(r['rows'] for r in done), rows_median=float(np.median([r['rows'] for r in done])), rows_max=max(r['rows'] for r in done),
    nnzA_mean=float(np.mean([r['nnz'] for r in done])), nnzL_mean=float(np.mean([r['nnzL'] for r in done])), nnzL_max=max(r['nnzL'] for r in done),
    nnzL_total_solve0=int(sum(r['nnzL'] for r in done if r['solve']==0)), factor_MB_fp32_total_solve0=float(sum(r['nnzL'] for r in done if r['solve']==0)*4/1e6),
    steps_hist={int(k): int((steps==k).sum()) for k in np.unique(steps)}, pass_le3=float(((steps>=0)&(steps<=3)).mean()),
    fp32_only_residual_median=float(np.median([r['refine_residuals'][0] for r in done])), fp32_only_residual_max=float(max(r['refine_residuals'][0] for r in done)),
    rel_err_x_max=float(max(r['rel_err_x'] for r in done)), rel_err_bond_force_max=float(max(r['rel_err_bond_force'] for r in done)),
    cond_min=float(min(r['cond'] for r in done if 'cond' in r)), cond_max=float(max(r['cond'] for r in done if 'cond' in r)),
    same_members_solve1=int(sum(1 for r in results if 'bonds_removed_since_solve0' in r)),
    unchanged_operator_solve1=int(sum(1 for r in results if r.get('woodbury','').startswith('unchanged'))),
    woodbury_cases=len(wb), woodbury_removed_bonds=[r['bonds_removed_since_solve0'] for r in wb],
    woodbury_steps=[int(next((k for k,h in enumerate(r['woodbury_residuals']) if h<=TOL),-1)) for r in wb],
    woodbury_rel_err_max=float(max([r['woodbury_rel_err_x'] for r in wb], default=0)), elapsed_s=time.time()-t0)
json.dump(dict(summary=summary, results=results), open(f'{outdir}/gate-raw.json','w'), indent=1)
print(json.dumps(summary, indent=1))
