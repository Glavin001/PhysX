// Woodbury updates for cached direct factors (R1 follow-up).
//
// A slot whose component lost k <= kWoodburyMaxBonds bonds since its factor
// was built keeps the factor of A_old and solves the current operator
//   A_new = A_old - U U^T
// through
//   A_new^+ r = y + W C^+ U^T y,  y = A_old^-1 r,  W = A_old^-1 U,  C = I - U^T W.
// U stacks the six columns of every removed bond's endpoint blocks (the bond
// term of the operator is u u^T with u = [M_node0; M_node1], see
// directBondBlock). C is symmetric positive semidefinite with the same rank
// deficiency as A_new: after a split the departed part is a free fragment
// whose rigid modes are null vectors of A_new supported on departed rows, so
// for a residual supported on the kept rows U^T y lies in range(C), any
// particular solution of C t = U^T y gives an exact kept-part solution, and
// the departed rows (never scattered) may hold anything. The build finds the
// numerical rank of C by pivoted Cholesky, inverts the leading pivot block
// explicitly, and caches W and that pseudo-inverse per slot in a pool; the
// base solve is followed by two dense mat-vecs.
#ifdef PHYSX_RESIDENT_DESTRUCTION
constexpr unsigned kWoodburyMaxBonds = 16u;   // removed bonds per factor before a refactor (32 measured slower: the per-solve W mat-vec doubles, see warm-screen.md)
constexpr unsigned kWoodburyMaxColumns = 6u * kWoodburyMaxBonds;
constexpr unsigned kWoodburyCapStride = 2u * kWoodburyMaxColumns; // row stride of the capacitance work areas
constexpr unsigned kWoodburyCapFloats = 3u * kWoodburyMaxColumns * kWoodburyCapStride; // working copy, permuted [C11 | I], pseudo-inverse
constexpr float kWoodburyRankTolerance = 1e-4f; // pivot / largest initial diagonal below this is null
constexpr unsigned kWoodburyPresentWords = kResidentComponentMaxNodes / 32u;

__device__ __forceinline__ bool woodburyPresent(const unsigned* present, unsigned local) {
    return (present[local >> 5] >> (local & 31u)) & 1u;
}
// Endpoint blocks of removed bond `edge` (row-major 6x6, rows = node DOFs,
// columns = the bond's six columns of U). Rows exist only for endpoints that
// were present when the factor was built (kNoIsland otherwise).
struct WoodburyBond { unsigned local0, local1; float m0[36], m1[36]; };
__device__ __forceinline__ WoodburyBond woodburyBond(const NativeDirectView& v, const NativeDirectOperator& op, const unsigned* present,
    unsigned pattern, unsigned pinned, unsigned edge) {
    WoodburyBond b;
    const unsigned n0 = op.node0[edge], n1 = op.node1[edge];
    b.local0 = (v.pattern.nodeParent[n0] == pattern && n0 != pinned) ? v.pattern.nodeLocal[n0] : kNoIsland;
    b.local1 = (v.pattern.nodeParent[n1] == pattern && n1 != pinned) ? v.pattern.nodeLocal[n1] : kNoIsland;
    if (b.local0 != kNoIsland && !woodburyPresent(present, b.local0)) b.local0 = kNoIsland;
    if (b.local1 != kNoIsland && !woodburyPresent(present, b.local1)) b.local1 = kNoIsland;
    if (b.local0 != kNoIsland) directBondBlock(b.m0, op.offset0[edge], op.inertia[n0], op.colScale[edge], 1.f);
    if (b.local1 != kNoIsland) directBondBlock(b.m1, op.offset1[edge], op.inertia[n1], op.colScale[edge], -1.f);
    return b;
}
struct WoodburySlot {
    const unsigned* removed; unsigned k;      // removed bond edges
    const unsigned* present;
    float* W; float* C;                       // pool buffers (C: kWoodburyCapFloats work area; last third holds C^+)
    unsigned m;                               // 6 k
};
__device__ __forceinline__ WoodburySlot woodburySlot(const NativeDirectView& v, unsigned s) {
    WoodburySlot w;
    const unsigned buffer = v.slots.slotWoodburyBuffer[s];
    w.removed = v.slots.slotRemoved + size_t(s) * kWoodburyMaxBonds; w.k = v.slots.slotRemovedCount[s];
    w.present = v.slots.slotPresent + size_t(s) * kWoodburyPresentWords;
    w.W = buffer == kNoIsland ? nullptr : v.slots.woodburyPool + size_t(buffer) * v.slots.woodburyStride;
    w.C = buffer == kNoIsland ? nullptr : v.slots.woodburyCap + size_t(buffer) * kWoodburyCapFloats;
    w.m = 6u * w.k;
    return w;
}
// U^T x for column a.
__device__ __forceinline__ float woodburyDot(const NativeDirectView& v, const NativeDirectOperator& op, const WoodburySlot& w,
    unsigned pattern, unsigned pinned, unsigned a, const float* x, size_t xStride) {
    const unsigned q = a / 6u, ca = a % 6u;
    const WoodburyBond bond = woodburyBond(v, op, w.present, pattern, pinned, w.removed[q]);
    float sum = 0.f;
    if (bond.local0 != kNoIsland) for (unsigned r = 0; r < 6; ++r) sum = fmaf(bond.m0[r * 6 + ca], x[size_t(6u * bond.local0 + r) * xStride], sum);
    if (bond.local1 != kNoIsland) for (unsigned r = 0; r < 6; ++r) sum = fmaf(bond.m1[r * 6 + ca], x[size_t(6u * bond.local1 + r) * xStride], sum);
    return sum;
}
// One row of a multi-RHS triangular sweep on W (m columns) with a thread
// group of T threads (32: warp per row, wide levels; kBlockSize: whole CTA per
// row, narrow levels). Threads split into column lanes (CW) and entry groups;
// entry partials reduce over lanes and, for the CTA, over warps in shared
// memory. Fixed lane assignment: the result is deterministic.
template<unsigned T>
__device__ __forceinline__ void woodburyRow(const NativeDirectPatternRefs& P, const float* val, float* W, unsigned m, unsigned i, bool forward, float* red) {
    const unsigned tid = (T == 32u) ? (threadIdx.x & 31u) : threadIdx.x;
    const unsigned CW = m > 16u ? 32u : (m > 8u ? 16u : 8u), EG = T / CW;
    const unsigned eg = tid / CW, cl = tid % CW, lane = threadIdx.x & 31u, warp = threadIdx.x >> 5;
    const unsigned begin = forward ? P.rowPtr[i] : P.colPtr[i] + 1u, end = forward ? P.rowPtr[i + 1] : P.colPtr[i + 1];
    const float* d = val + size_t(P.colPtr[i]) * kDirectBlockEntries;
    for (unsigned c0 = 0; c0 < m; c0 += CW) {
        const unsigned c = c0 + cl; const bool valid = c < m;
        float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
        if (valid) for (unsigned q = begin + eg; q < end; q += EG) {
            const float* blk = forward ? val + size_t(P.rowPos[q]) * kDirectBlockEntries : val + size_t(q) * kDirectBlockEntries;
            const float* xk = W + size_t(6u * (forward ? P.rowCols[q] : P.rowIdx[q])) * m + c;
            float xv[6];
            for (unsigned cc = 0; cc < 6; ++cc) xv[cc] = xk[size_t(cc) * m];
            if (forward) { for (unsigned r = 0; r < 6; ++r) { float sum = acc[r]; for (unsigned cc = 0; cc < 6; ++cc) sum = fmaf(blk[r * 6 + cc], xv[cc], sum); acc[r] = sum; } }
            else         { for (unsigned r = 0; r < 6; ++r) { float sum = acc[r]; for (unsigned cc = 0; cc < 6; ++cc) sum = fmaf(blk[cc * 6 + r], xv[cc], sum); acc[r] = sum; } }
        }
        for (unsigned off = CW; off < 32u; off <<= 1) for (unsigned r = 0; r < 6; ++r) acc[r] += __shfl_xor_sync(0xffffffffu, acc[r], off);
        if (T != 32u) {
            // Cross-warp reduction: warp partials for column lane cl live in lanes < CW.
            if (lane < CW) for (unsigned r = 0; r < 6; ++r) red[(warp * 6u + r) * 32u + lane] = acc[r];
            __syncthreads();
            if (tid < CW) for (unsigned r = 0; r < 6; ++r) { float sum = 0.f; for (unsigned w = 0; w < T / 32u; ++w) sum += red[(w * 6u + r) * 32u + tid]; acc[r] = sum; }
        }
        if (eg == 0 && valid) {
            float y[6];
            if (forward) for (unsigned r = 0; r < 6; ++r) {
                float sum = W[size_t(6u * i + r) * m + c] - acc[r];
                for (unsigned tt = 0; tt < r; ++tt) sum = fmaf(-d[r * 6 + tt], y[tt], sum);
                y[r] = sum / d[r * 6 + r];
            } else for (unsigned r = 6; r-- > 0;) {
                float sum = W[size_t(6u * i + r) * m + c] - acc[r];
                for (unsigned tt = r + 1; tt < 6; ++tt) sum = fmaf(-d[tt * 6 + r], y[tt], sum);
                y[r] = sum / d[r * 6 + r];
            }
            for (unsigned r = 0; r < 6; ++r) W[size_t(6u * i + r) * m + c] = y[r];
        }
        if (T != 32u) __syncthreads(); else __syncwarp();
    }
}
// Builds W = A_old^-1 U and the pseudo-inverse of C = I - U^T W for slot s
// (whole CTA). False only on non-finite values.
__device__ bool woodburyBuild(const NativeDirectView& v, const NativeDirectOperator& op, const NativeDirectPatternRefs& P,
    unsigned pattern, unsigned pinned, unsigned s, const float* val, unsigned* failedFlag) {
    __shared__ float red[(kBlockSize / 32u) * 6u * 32u];
    __shared__ float mult[kWoodburyMaxColumns];
    __shared__ unsigned perm[kWoodburyMaxColumns];
    __shared__ unsigned pivotRow, rank; __shared__ float pivotValue, largest;
    const WoodburySlot w = woodburySlot(v, s);
    const unsigned m = w.m;
    if (!w.W || !m || m > kWoodburyMaxColumns) return false;
    float* W = w.W;
    float* A = w.C;                                            // working copy (pivoted Cholesky)
    float* G = w.C + size_t(kWoodburyMaxColumns) * kWoodburyCapStride;      // permuted C, then [C11 | C11^-1]
    float* Cp = w.C + 2u * size_t(kWoodburyMaxColumns) * kWoodburyCapStride; // pseudo-inverse (m x m, stride kWoodburyCapStride)
    const unsigned rows = 6u * P.nodes;
    const unsigned warp = threadIdx.x >> 5, warps = blockDim.x >> 5;
    if (!threadIdx.x) { *failedFlag = 0; rank = 0; }
    for (unsigned t = threadIdx.x; t < rows * m; t += blockDim.x) W[t] = 0.f;
    __syncthreads();
    for (unsigned q = warp; q < w.k; q += warps) {
        const WoodburyBond b = woodburyBond(v, op, w.present, pattern, pinned, w.removed[q]);
        for (unsigned e = threadIdx.x & 31u; e < 72; e += 32) {
            const unsigned which = e / 36, x = e % 36, r = x / 6, c = x % 6;
            const unsigned local = which ? b.local1 : b.local0;
            if (local == kNoIsland) continue;
            W[size_t(6u * local + r) * m + 6u * q + c] = which ? b.m1[x] : b.m0[x];
        }
    }
    __syncthreads();
    // Forward L Y = U, then backward L^T W = Y, level by level.
    for (unsigned sweep = 0; sweep < 2; ++sweep) {
        const bool forward = sweep == 0;
        for (unsigned ll = 0; ll < P.levels; ++ll) {
            const unsigned l = forward ? ll : P.levels - 1u - ll;
            const unsigned levelBegin = P.levelPtr[l], levelEnd = P.levelPtr[l + 1];
            if (levelEnd - levelBegin >= warps) {
                for (unsigned e = levelBegin + warp; e < levelEnd; e += warps) woodburyRow<32u>(P, val, W, m, P.levelCols[e], forward, red);
            } else {
                for (unsigned e = levelBegin; e < levelEnd; ++e) woodburyRow<kBlockSize>(P, val, W, m, P.levelCols[e], forward, red);
            }
            __syncthreads();
        }
    }
    // C = I - U^T W, symmetrized, into the working copy and the permuted copy.
    for (unsigned t = threadIdx.x; t < m * m; t += blockDim.x) {
        const unsigned a = t / m, b = t % m;
        const float value = ((a == b) ? 1.f : 0.f) - woodburyDot(v, op, w, pattern, pinned, a, W + b, m);
        A[a * kWoodburyCapStride + b] = value;
    }
    for (unsigned t = threadIdx.x; t < m; t += blockDim.x) perm[t] = t;
    __syncthreads();
    for (unsigned t = threadIdx.x; t < m * m; t += blockDim.x) {
        const unsigned a = t / m, b = t % m;
        const float value = 0.5f * (A[a * kWoodburyCapStride + b] + A[b * kWoodburyCapStride + a]);
        G[a * kWoodburyCapStride + b] = value;
    }
    __syncthreads();
    for (unsigned t = threadIdx.x; t < m * m; t += blockDim.x) A[t / m * kWoodburyCapStride + t % m] = G[t / m * kWoodburyCapStride + t % m];
    __syncthreads();
    // Pivoted (largest remaining diagonal) right-looking Cholesky on A to find
    // the numerical rank and the pivot order; rows/columns of G follow.
    for (unsigned j = 0; j < m; ++j) {
        if (threadIdx.x < 32) {
            const unsigned lane = threadIdx.x;
            float best = -1.f; unsigned bestRow = j;
            for (unsigned r = j + lane; r < m; r += 32) { const float a = A[r * kWoodburyCapStride + r]; if (a > best) { best = a; bestRow = r; } }
            for (unsigned off = 16; off; off >>= 1) {
                const float ob = __shfl_xor_sync(0xffffffffu, best, off); const unsigned orow = __shfl_xor_sync(0xffffffffu, bestRow, off);
                if (ob > best || (ob == best && orow < bestRow)) { best = ob; bestRow = orow; }
            }
            if (!lane) {
                if (j == 0) largest = best;
                pivotRow = bestRow; pivotValue = best;
                if (!isfinite(best)) *failedFlag = 1;
                if (best > kWoodburyRankTolerance * largest && best > 0.f) rank = j + 1u;
            }
        }
        __syncthreads();
        if (*failedFlag || rank != j + 1u) break;
        const unsigned p = pivotRow;
        if (p != j) {
            for (unsigned t = threadIdx.x; t < m; t += blockDim.x) {
                float x = A[j * kWoodburyCapStride + t]; A[j * kWoodburyCapStride + t] = A[p * kWoodburyCapStride + t]; A[p * kWoodburyCapStride + t] = x;
                x = G[j * kWoodburyCapStride + t]; G[j * kWoodburyCapStride + t] = G[p * kWoodburyCapStride + t]; G[p * kWoodburyCapStride + t] = x;
            }
            __syncthreads();
            for (unsigned t = threadIdx.x; t < m; t += blockDim.x) {
                float x = A[t * kWoodburyCapStride + j]; A[t * kWoodburyCapStride + j] = A[t * kWoodburyCapStride + p]; A[t * kWoodburyCapStride + p] = x;
                x = G[t * kWoodburyCapStride + j]; G[t * kWoodburyCapStride + j] = G[t * kWoodburyCapStride + p]; G[t * kWoodburyCapStride + p] = x;
            }
            if (!threadIdx.x) { const unsigned x = perm[j]; perm[j] = perm[p]; perm[p] = x; }
            __syncthreads();
        }
        const float inv = rsqrtf(pivotValue);
        for (unsigned r = j + 1u + threadIdx.x; r < m; r += blockDim.x) mult[r] = A[r * kWoodburyCapStride + j] * inv;
        __syncthreads();
        const unsigned rest = m - j - 1u;
        // Full trailing block (both triangles): later row/column swaps read both.
        for (unsigned t = threadIdx.x; t < rest * rest; t += blockDim.x) {
            const unsigned r = j + 1u + t / rest, c = j + 1u + t % rest;
            A[r * kWoodburyCapStride + c] = fmaf(-mult[r], mult[c], A[r * kWoodburyCapStride + c]);
        }
        __syncthreads();
    }
    const unsigned n = rank;
    // Gauss-Jordan on [C11 | I] (n x n leading block of the permuted C).
    for (unsigned t = threadIdx.x; t < n * n; t += blockDim.x) G[(t / n) * kWoodburyCapStride + n + t % n] = (t / n == t % n) ? 1.f : 0.f;
    __syncthreads();
    for (unsigned c = 0; c < n; ++c) {
        if (threadIdx.x < 32) {
            const unsigned lane = threadIdx.x;
            float best = -1.f; unsigned bestRow = c;
            for (unsigned r = c + lane; r < n; r += 32) { const float a = fabsf(G[r * kWoodburyCapStride + c]); if (a > best) { best = a; bestRow = r; } }
            for (unsigned off = 16; off; off >>= 1) {
                const float ob = __shfl_xor_sync(0xffffffffu, best, off); const unsigned orow = __shfl_xor_sync(0xffffffffu, bestRow, off);
                if (ob > best || (ob == best && orow < bestRow)) { best = ob; bestRow = orow; }
            }
            if (!lane) { pivotRow = bestRow; pivotValue = G[bestRow * kWoodburyCapStride + c]; if (!(best > 0.f) || !isfinite(best)) *failedFlag = 1; }
        }
        __syncthreads();
        if (*failedFlag) break;
        const unsigned p = pivotRow; const float inv = 1.f / pivotValue;
        if (p != c) for (unsigned j = threadIdx.x; j < 2u * n; j += blockDim.x) { const float t = G[c * kWoodburyCapStride + j]; G[c * kWoodburyCapStride + j] = G[p * kWoodburyCapStride + j]; G[p * kWoodburyCapStride + j] = t; }
        __syncthreads();
        for (unsigned j = threadIdx.x; j < 2u * n; j += blockDim.x) G[c * kWoodburyCapStride + j] *= inv;
        for (unsigned r = threadIdx.x; r < n; r += blockDim.x) mult[r] = (r == c) ? 0.f : G[r * kWoodburyCapStride + c];
        __syncthreads();
        for (unsigned t = threadIdx.x; t < n * 2u * n; t += blockDim.x) {
            const unsigned r = t / (2u * n), j = t % (2u * n);
            if (r == c) continue;
            G[r * kWoodburyCapStride + j] = fmaf(-mult[r], G[c * kWoodburyCapStride + j], G[r * kWoodburyCapStride + j]);
        }
        __syncthreads();
    }
    // Scatter C11^-1 into the pseudo-inverse in original column order.
    for (unsigned t = threadIdx.x; t < m * m; t += blockDim.x) Cp[(t / m) * kWoodburyCapStride + t % m] = 0.f;
    __syncthreads();
    for (unsigned t = threadIdx.x; t < n * n; t += blockDim.x) {
        const unsigned a = t / n, b = t % n;
        Cp[perm[a] * kWoodburyCapStride + perm[b]] = G[a * kWoodburyCapStride + n + b];
    }
    __syncthreads();
    return !*failedFlag;
}
// x <- x + W C^+ U^T x (x shared, 6 * np, base solve already applied).
__device__ __forceinline__ void woodburyApply(const NativeDirectView& v, const NativeDirectOperator& op, const NativeDirectPatternRefs& P,
    unsigned pattern, unsigned pinned, unsigned s, float* x) {
    __shared__ float sv[kWoodburyMaxColumns], tv[kWoodburyMaxColumns];
    const WoodburySlot w = woodburySlot(v, s);
    const unsigned m = w.m;
    for (unsigned a = threadIdx.x; a < m; a += blockDim.x) sv[a] = woodburyDot(v, op, w, pattern, pinned, a, x, 1);
    __syncthreads();
    const float* Cp = w.C + 2u * size_t(kWoodburyMaxColumns) * kWoodburyCapStride;
    for (unsigned a = threadIdx.x; a < m; a += blockDim.x) {
        float sum = 0.f;
        for (unsigned b = 0; b < m; ++b) sum = fmaf(Cp[a * kWoodburyCapStride + b], sv[b], sum);
        tv[a] = sum;
    }
    __syncthreads();
    const unsigned rows = 6u * P.nodes;
    for (unsigned row = threadIdx.x; row < rows; row += blockDim.x) {
        float sum = x[row];
        for (unsigned b = 0; b < m; ++b) sum = fmaf(w.W[size_t(row) * m + b], tv[b], sum);
        x[row] = sum;
    }
    __syncthreads();
}
// Diagnostic (BLAST_GPU_NATIVE_DIRECT_DIAG=2): after a build, check on the kept
// rows that A_new W == U C (with A_new applied from bonds through the current
// island labels) and that C C^+ C == C. Prints the relative errors.
__device__ void woodburyCheck(const NativeDirectView& v, const NativeDirectOperator& op, const NativeDirectPatternRefs& P,
    unsigned pattern, unsigned pinned, unsigned id, unsigned s) {
    __shared__ double err[2], ref[2];
    const WoodburySlot w = woodburySlot(v, s);
    const unsigned m = w.m;
    const float* C = w.C + size_t(kWoodburyMaxColumns) * kWoodburyCapStride; // permuted copy is not C; recompute C = I - U^T W below
    const float* Cp = w.C + 2u * size_t(kWoodburyMaxColumns) * kWoodburyCapStride;
    if (!threadIdx.x) { err[0] = err[1] = ref[0] = ref[1] = 0.0; }
    __syncthreads();
    // (A_new W)(row i, col b) for kept local rows i: sum over bonds at node i.
    for (unsigned t = threadIdx.x; t < P.nodes * m; t += blockDim.x) {
        const unsigned i = t / m, b = t % m, inode = P.order[i];
        if (op.nodeIsland[inode] != id || inode == pinned || !woodburyPresent(w.present, i)) continue;
        double aw[6] = {0, 0, 0, 0, 0, 0};
        const Inertia di = op.inertia[inode];
        for (unsigned r = op.nodeBondBegin[inode]; r < op.nodeBondBegin[inode + 1]; ++r) {
            const unsigned ref_ = op.nodeBondRef[r];
            if (ref_ == kDeadBondRef) continue;
            const unsigned edge = ref_ & 0x7fffffffu;
            if (op.health[edge] <= 0.f) continue;
            const bool second = (ref_ >> 31) != 0u;
            const unsigned other = second ? op.node0[edge] : op.node1[edge];
            float mi[36], mo[36];
            directBondBlock(mi, second ? op.offset1[edge] : op.offset0[edge], di, op.colScale[edge], second ? -1.f : 1.f);
            // m_i^T W_i
            float z[6] = {0, 0, 0, 0, 0, 0};
            for (unsigned c = 0; c < 6; ++c) for (unsigned rr = 0; rr < 6; ++rr) z[c] += mi[rr * 6 + c] * w.W[size_t(6u * i + rr) * m + b];
            if (v.pattern.nodeParent[other] == pattern && op.nodeIsland[other] == id && other != pinned) {
                const unsigned j = v.pattern.nodeLocal[other];
                directBondBlock(mo, second ? op.offset0[edge] : op.offset1[edge], op.inertia[other], op.colScale[edge], second ? 1.f : -1.f);
                for (unsigned c = 0; c < 6; ++c) for (unsigned rr = 0; rr < 6; ++rr) z[c] += mo[rr * 6 + c] * w.W[size_t(6u * j + rr) * m + b];
            }
            for (unsigned rr = 0; rr < 6; ++rr) for (unsigned c = 0; c < 6; ++c) aw[rr] += double(mi[rr * 6 + c]) * z[c];
        }
        // (U C)(row i, col b) = sum_a U[i,a] C[a,b], C = I - U^T W.
        double uc[6] = {0, 0, 0, 0, 0, 0};
        for (unsigned a = 0; a < m; ++a) {
            const unsigned q = a / 6u, ca = a % 6u;
            const WoodburyBond bond = woodburyBond(v, op, w.present, pattern, pinned, w.removed[q]);
            float ua[6] = {0, 0, 0, 0, 0, 0};
            if (bond.local0 == i) for (unsigned rr = 0; rr < 6; ++rr) ua[rr] += bond.m0[rr * 6 + ca];
            if (bond.local1 == i) for (unsigned rr = 0; rr < 6; ++rr) ua[rr] += bond.m1[rr * 6 + ca];
            const float cab = ((a == b) ? 1.f : 0.f) - woodburyDot(v, op, w, pattern, pinned, a, w.W + b, m);
            for (unsigned rr = 0; rr < 6; ++rr) uc[rr] += double(ua[rr]) * cab;
        }
        double e = 0, f = 0;
        for (unsigned rr = 0; rr < 6; ++rr) { e += (aw[rr] - uc[rr]) * (aw[rr] - uc[rr]); f += uc[rr] * uc[rr]; }
        atomicAdd(err + 0, e); atomicAdd(ref + 0, f);
    }
    // C C^+ C vs C.
    for (unsigned t = threadIdx.x; t < m * m; t += blockDim.x) {
        const unsigned a = t / m, b = t % m;
        double acc = 0;
        for (unsigned x = 0; x < m; ++x) {
            const float cax = ((a == x) ? 1.f : 0.f) - woodburyDot(v, op, w, pattern, pinned, a, w.W + x, m);
            double inner = 0;
            for (unsigned y = 0; y < m; ++y) {
                const float cyb = ((y == b) ? 1.f : 0.f) - woodburyDot(v, op, w, pattern, pinned, y, w.W + b, m);
                inner += double(Cp[x * kWoodburyCapStride + y]) * cyb;
            }
            acc += double(cax) * inner;
        }
        const float cab = ((a == b) ? 1.f : 0.f) - woodburyDot(v, op, w, pattern, pinned, a, w.W + b, m);
        atomicAdd(err + 1, (acc - cab) * (acc - cab)); atomicAdd(ref + 1, double(cab) * cab);
    }
    __syncthreads();
    if (!threadIdx.x) printf("woodbury check: component=%u slot=%u k=%u m=%u |A W - U C|/|U C|=%.3e |C C+ C - C|/|C|=%.3e\n",
        id, s, w.k, m, sqrt(err[0] / fmax(ref[0], 1e-300)), sqrt(err[1] / fmax(ref[1], 1e-300)));
    __syncthreads();
    (void)C;
}
// Topology refresh (old labels): append this transaction's removed bonds to
// their old component's slot. Beyond the limit the slot refactors.
__global__ void trackNativeDirectRemovedBonds(NativeDirectView v, const DeviceStressTopologyBatch* batch,
    const ExtStressGpuDeviceTopologyStatus* state, const float* health, const unsigned* oldIsland, unsigned bonds) {
    const unsigned edge = blockIdx.x * blockDim.x + threadIdx.x;
    if (edge >= bonds || !v.enabled || !v.woodbury || !state->initialized || !batch->mask) return;
    if (!(health[edge] > 0.f) || batch->mask[edge]) return;
    const unsigned id = oldIsland[edge]; if (id == kNoIsland) return;
    const unsigned s = v.slots.componentSlot[id]; if (s == kNoIsland || !v.slots.slotValid[s] || v.slots.slotFailed[s]) return;
    const unsigned q = atomicAdd(v.slots.slotRemovedCount + s, 1u);
    if (q < kWoodburyMaxBonds) v.slots.slotRemoved[size_t(s) * kWoodburyMaxBonds + q] = edge;
    else v.slots.slotValid[s] = 0;
}
// Removed-bond lists must not depend on thread order: sort each slot's list
// (at most kWoodburyMaxBonds entries) so identical inputs give identical W.
__global__ void sortNativeDirectRemovedBonds(NativeDirectView v) {
    const unsigned s = blockIdx.x * blockDim.x + threadIdx.x;
    if (s >= v.slots.slotCount || !v.enabled || !v.woodbury) return;
    const unsigned k = v.slots.slotRemovedCount[s];
    if (k < 2u || k > kWoodburyMaxBonds) return;
    unsigned* list = v.slots.slotRemoved + size_t(s) * kWoodburyMaxBonds;
    for (unsigned i = 1; i < k; ++i) { const unsigned key = list[i]; unsigned j = i; while (j > 0 && list[j - 1] > key) { list[j] = list[j - 1]; --j; } list[j] = key; }
}
#endif
