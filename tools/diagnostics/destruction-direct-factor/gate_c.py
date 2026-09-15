#!/usr/bin/env python3
"""R1 feasibility gate (c): Woodbury/capacitance reuse of a cached FP32 factor
under bond removal and node detachment, on the captured intact parent building
(out/prepared-remnant-20260913/inputs-v3) and its real fractured successor.

A_k = A0 - U U^T + E E^T, U = bond columns of B removed, E = identity columns on
detached coordinates (regularizes the singular detached block; b_det = 0 gives
x_det = 0 and x_rem = A_rem^{-1} b_rem exactly). Solve with cached chol(A0) in
FP32, capacitance C = Sigma + V^T A0^{-1} V in FP64, FP64 refinement on A_k.
"""
import json, sys, time
import numpy as np, scipy.sparse as sp, scipy.linalg as la
from scipy.sparse.csgraph import connected_components
base = 'out/prepared-remnant-20260913/inputs-v3'; TOL = 1e-5
def csr(prefix, shape=None):
    r = np.fromfile(prefix + '.rows.i32', np.int32); c = np.fromfile(prefix + '.cols.i32', np.int32); v = np.fromfile(prefix + '.values.f64')
    return sp.csr_matrix((v, c, r), shape=shape or (len(r) - 1, c.max() + 1))
B0 = csr(f'{base}/solve-0/B'); A0 = (B0 @ B0.T).tocsr(); n = A0.shape[0]; nb = B0.shape[1] // 6
b0 = np.fromfile(f'{base}/solve-0/rhs.f64').reshape(-1, n)[0]; print('parent', A0.shape, A0.nnz, 'bonds', nb)
A0d = A0.toarray(); c32 = la.cholesky(A0d.astype(np.float32), lower=True)
def s32(R): return la.cho_solve((c32, True), np.asarray(R, np.float32)).astype(np.float64)
# node graph from bonds: bond j couples nodes present in column block j
nodes = n // 6
def bond_nodes(j):
    rows = np.unique(B0[:, 6*j:6*j+6].tocoo().row // 6); return rows
bn = [bond_nodes(j) for j in range(nb)]
anchored_bonds = [j for j in range(nb) if len(bn[j]) == 1]
print('anchor bonds', len(anchored_bonds))
def detached_after(removed):
    keep = [j for j in range(nb) if j not in removed]
    rows = []; cols = []
    for j in keep:
        if len(bn[j]) == 2: rows.append(bn[j][0]); cols.append(bn[j][1])
    G = sp.coo_matrix((np.ones(len(rows)), (rows, cols)), shape=(nodes, nodes))
    ncomp, lab = connected_components(G, directed=False)
    anchored_labels = set(lab[bn[j][0]] for j in keep if len(bn[j]) == 1)
    return np.where(~np.isin(lab, list(anchored_labels)))[0]
def woodbury_solve(removed, det, b, refine=3):
    Ucols = np.concatenate([np.arange(6*j, 6*j+6) for j in removed]) if len(removed) else np.zeros(0, int)
    U = B0[:, Ucols].toarray(); Ecoords = np.concatenate([np.arange(6*d, 6*d+6) for d in det]) if len(det) else np.zeros(0, int)
    E = np.zeros((n, len(Ecoords))); E[Ecoords, np.arange(len(Ecoords))] = 1.0
    V = np.hstack([U, E]); m = V.shape[1]
    Sig = np.diag(np.concatenate([-np.ones(U.shape[1]), np.ones(E.shape[1])]))
    Ak = A0d - U @ U.T + E @ E.T
    bk = b.copy(); bk[Ecoords] = 0.0
    W = s32(V)                                   # A0^{-1} V  (FP32 factor)
    C = Sig + V.T @ W                            # capacitance, FP64, symmetric indefinite
    Cl, piv = la.lu_factor(C) if m else (None, None)
    def apply(rhs):
        y = s32(rhs)
        if m == 0: return y
        return y - W @ la.lu_solve((Cl, piv), V.T @ y)
    x = apply(bk); hist = []
    for it in range(refine + 1):
        r = bk - Ak @ x; rel = float(np.linalg.norm(r) / np.linalg.norm(bk)); hist.append(rel)
        if rel <= TOL or it == refine: break
        x = x + apply(r)
    xd = la.solve(Ak, bk, assume_a='pos'); err = float(np.linalg.norm(x - xd) / np.linalg.norm(xd))
    ev = np.abs(la.eigvalsh((C + C.T) / 2)) if m else np.array([1.0])
    return dict(k=len(removed), detached_nodes=int(len(det)), m=int(m), residuals=hist, rel_err=err, cap_abs_eig_min=float(ev.min()), cap_abs_eig_max=float(ev.max()))
rng = np.random.default_rng(7); out = []
for k in (1, 2, 4, 8, 16, 32, 64, 128, 200):
    for trial in range(3):
        removed = set(rng.choice(nb, size=k, replace=False).tolist()); det = detached_after(removed)
        rec = woodbury_solve(removed, det, b0); rec['trial'] = trial; out.append(rec)
        print(f"k={k:3} det={len(det):3} m={rec['m']:5} residuals={['%.1e'%h for h in rec['residuals']]} err={rec['rel_err']:.2e} capEig[{rec['cap_abs_eig_min']:.1e},{rec['cap_abs_eig_max']:.1e}]", flush=True)
# real fractured successor: solve-1
B1 = csr(f'{base}/solve-1/B', shape=None); A1 = csr(f'{base}/solve-1/A'); b1 = np.fromfile(f'{base}/solve-1/rhs.f64').reshape(-1, n)[0]
present1 = np.array([B1[:, 6*j:6*j+6].nnz > 0 for j in range(B1.shape[1] // 6)])
print('solve-1 B', B1.shape, 'bonds present', present1.sum(), 'A1 rows', A1.shape, 'identity rows', int(((A1.getnnz(axis=1) == 1) & (A1.diagonal() == 1)).sum()))
# map solve-1 bonds to solve-0 bonds by column pattern (same ordering assumed if same width)
real = None
if B1.shape[1] == B0.shape[1]:
    removed = set(np.where(~present1)[0].tolist()); det = detached_after(removed)
    Ucols = np.concatenate([np.arange(6*j, 6*j+6) for j in removed]); U = B0[:, Ucols].toarray()
    Ecoords = np.concatenate([np.arange(6*d, 6*d+6) for d in det]); Ak = A0d - U @ U.T; Ak[Ecoords, Ecoords] += 1.0
    diff = float(np.abs(Ak - A1.toarray()).max())
    real = woodbury_solve(removed, det, b1); real['reconstruction_max_abs_diff_vs_captured_A1'] = diff
    print('REAL fractured solve-1: removed', len(removed), 'detached nodes', len(det), 'A reconstruction diff', diff, real)
json.dump(dict(random=out, real_fracture=real), open('out/direct-factor-feasibility-20260915/gate-c.json', 'w'), indent=1)
