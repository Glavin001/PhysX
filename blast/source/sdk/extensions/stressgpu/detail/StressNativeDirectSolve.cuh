// In-kernel direct solve for one small anchored component (R1). Called by the
// owning CTA of componentStressSolve with the component's current residual in
// a.m_residual. Solves L L^T x = r in FP32 with the cached block factor and
// adds x to the FP64 accumulated node solution. Returns false when no valid
// factor exists; the caller then proceeds exactly as before.
#ifdef PHYSX_RESIDENT_DESTRUCTION
__device__ __forceinline__ void directWarpReduce6(float (&acc)[6]) {
    for (unsigned o = 16; o; o >>= 1)
        for (unsigned r = 0; r < 6; ++r) acc[r] += __shfl_xor_sync(0xffffffffu, acc[r], o);
}
__device__ __forceinline__ bool directSlotStale(const NativeDirectView& v, unsigned id) {
    if (!v.enabled) return false;
    const unsigned s = v.slots.componentSlot[id];
    return s != kNoIsland && v.slots.slotValid[s] && !v.slots.slotFailed[s] && v.slots.slotStale[s];
}
// One entry of a block row: acc += L(i,k) x_k (forward, block stored row-major) or
// acc += L(k,i)^T x_k (backward), then the 6x6 triangular finish of row i.
__device__ __forceinline__ void directFwdEntry(float (&acc)[6], const float* val, const float* x, const NativeDirectPatternRefs& P, unsigned q) {
    const float* blk = val + size_t(P.rowPos[q]) * kDirectBlockEntries;
    const float* xk = x + 6 * P.rowCols[q];
    for (unsigned r = 0; r < 6; ++r) { float sum = acc[r]; for (unsigned cc = 0; cc < 6; ++cc) sum = fmaf(blk[r * 6 + cc], xk[cc], sum); acc[r] = sum; }
}
__device__ __forceinline__ void directBwdEntry(float (&acc)[6], const float* val, const float* x, const NativeDirectPatternRefs& P, unsigned q) {
    const float* blk = val + size_t(q) * kDirectBlockEntries; // L(k,i)
    const float* xk = x + 6 * P.rowIdx[q];
    for (unsigned r = 0; r < 6; ++r) { float sum = acc[r]; for (unsigned cc = 0; cc < 6; ++cc) sum = fmaf(blk[cc * 6 + r], xk[cc], sum); acc[r] = sum; }
}
__device__ __forceinline__ void directFwdFinish(const float* val, float* x, const NativeDirectPatternRefs& P, unsigned i, const float (&acc)[6]) {
    const float* d = val + size_t(P.colPtr[i]) * kDirectBlockEntries;
    float y[6];
    for (unsigned r = 0; r < 6; ++r) {
        float sum = x[6 * i + r] - acc[r];
        for (unsigned tt = 0; tt < r; ++tt) sum = fmaf(-d[r * 6 + tt], y[tt], sum);
        y[r] = sum / d[r * 6 + r];
    }
    for (unsigned r = 0; r < 6; ++r) x[6 * i + r] = y[r];
}
__device__ __forceinline__ void directBwdFinish(const float* val, float* x, const NativeDirectPatternRefs& P, unsigned i, const float (&acc)[6]) {
    const float* d = val + size_t(P.colPtr[i]) * kDirectBlockEntries;
    float y[6];
    for (unsigned r = 6; r-- > 0;) {
        float sum = x[6 * i + r] - acc[r];
        for (unsigned tt = r + 1; tt < 6; ++tt) sum = fmaf(-d[tt * 6 + r], y[tt], sum);
        y[r] = sum / d[r * 6 + r];
    }
    for (unsigned r = 0; r < 6; ++r) x[6 * i + r] = y[r];
}
// Row finish with the stored diagonal inverse: lanes 0-5 each produce one
// component, y_r = sum_t Linv[r][t] (rhs_t - acc_t) (forward) or with Linv^T
// (backward). `inv` is this lane's row (forward) or column (backward) of the
// inverse, loaded before the entry loop so the latency overlaps it. Every
// lane holds the reduced acc; the caller passes the per-row partial sums.
__device__ __forceinline__ void directFinishInv(float* x, unsigned i, const float (&acc)[6], const float (&inv)[6], unsigned lane, bool forward) {
    // Whole warp executes both barriers (a __syncwarp inside a divergent branch hangs).
    const unsigned r = lane < 6 ? lane : 0u;
    float sum = 0.f;
    if (forward) for (unsigned t = 0; t <= r; ++t) sum = fmaf(inv[t], x[6 * i + t] - acc[t], sum);
    else for (unsigned t = r; t < 6; ++t) sum = fmaf(inv[t], x[6 * i + t] - acc[t], sum);
    __syncwarp();
    if (lane < 6) x[6 * i + lane] = sum;
    __syncwarp();
}
__device__ __forceinline__ void directLoadInv(const NativeDirectView& v, unsigned s, unsigned i, unsigned lane, bool forward, float (&inv)[6]) {
    const float* m = v.slots.diagInv + size_t(s) * v.slots.diagStride + size_t(i) * kDirectBlockEntries;
    const unsigned r = lane < 6 ? lane : 0u;
    for (unsigned t = 0; t < 6; ++t) inv[t] = forward ? m[r * 6 + t] : m[t * 6 + r];
}
__device__ __forceinline__ bool directSolveNativeComponent(const PersistentStressArgs& a, const unsigned* nodes, unsigned count, unsigned id, float* x) {
    const NativeDirectView& v = a.hierarchy.direct;
    if (!v.enabled || count > kResidentComponentMaxNodes) return false;
    const unsigned s = v.slots.componentSlot[id];
    if (s == kNoIsland) { if (v.counters && !threadIdx.x) atomicAdd(v.counters + 3, 1u); return false; }
    if (!v.slots.slotValid[s] || v.slots.slotFailed[s]) { if (v.counters && !threadIdx.x) atomicAdd(v.counters + 4, 1u); return false; }
    const unsigned p = v.pattern.nodeParent[nodes[0]];
    if (p == kNoIsland) return false;
    const unsigned pinned = StressHierarchy::motionDimension(a.hierarchy.modes.components[id]) ? id : kNoIsland;
    // A stale factor built under a different pinning is not a preconditioner
    // for this operator (the null space changed); leave the component to PCG.
    if ((v.slots.slotStale[s] || v.slots.slotWoodbury[s] == 2u) && v.slots.slotPinned[s] != pinned) { if (v.counters && !threadIdx.x) atomicAdd(v.counters + 4, 1u); return false; }
    const auto P = directPatternRefs(v.pattern, p);
    const float* val = v.slots.values + size_t(s) * v.slots.stride;
    const unsigned warp = threadIdx.x >> 5, lane = threadIdx.x & 31, warps = blockDim.x >> 5;
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
    unsigned long long probeAcc[8] = {0, 0, 0, 0, 0, 0, 0, 0}, probeLast = 0;
    if (!threadIdx.x) probeLast = clock64();
#define DIRECT_PROBE(i) if (!threadIdx.x) { const auto probeNow = clock64(); probeAcc[i] += probeNow - probeLast; probeLast = probeNow; }
#define DIRECT_PROBE_PUBLISH if (!threadIdx.x) for (unsigned pi = 0; pi < 8; ++pi) atomicAdd(directSolveClocks + pi, probeAcc[pi]);
#else
#define DIRECT_PROBE(i)
#define DIRECT_PROBE_PUBLISH
#endif
    for (unsigned i = threadIdx.x; i < P.nodes; i += blockDim.x) {
        const unsigned node = P.order[i];
        if (a.m_nodeIsland[node] == id && node != pinned) {
            const auto r = a.m_residual[node];
            x[6 * i + 0] = r.angular.x; x[6 * i + 1] = r.angular.y; x[6 * i + 2] = r.angular.z;
            x[6 * i + 3] = r.linear.x;  x[6 * i + 4] = r.linear.y;  x[6 * i + 5] = r.linear.z;
        } else for (unsigned r = 0; r < 6; ++r) x[6 * i + r] = 0.f;
    }
    __syncthreads();
    DIRECT_PROBE(0)
    // Level loops. Wide levels: one warp per row, lanes over entries. Narrow
    // levels (fewer rows than warps, the elimination tree's top) are pipelined:
    // while the rows of level l finish with their "late" entries (columns one
    // level away, an explicit list) and the 6x6 solve, the idle warps gather
    // the "early" entries of the next level's rows (all already final) into
    // per-warp partials that the next step sums in a fixed order. This takes
    // the entry-bound gathers of the dense top off the serial chain.
    __shared__ float scratch[2][kBlockSize / 32u][6];
    unsigned T = (v.pipeline && warps >= 2u && P.lateFwdPtr) ? P.topLevel : P.levels;
    // The pattern's top level assumes kBlockSize/32 warps; a launch with fewer
    // warps treats only the suffix of levels narrower than its warp count as
    // pipelined (the scratch partials are indexed by warp).
    if (T < P.levels && warps < kBlockSize / 32u) { unsigned t = P.levels; while (t > T && P.levelPtr[t] - P.levelPtr[t - 1u] < warps) --t; T = t; }
    const bool useInv = v.slots.diagInv != nullptr;
    const unsigned Tf = (v.pipeline == 3u) ? P.levels : T, Tb = (v.pipeline == 2u) ? P.levels : T; // debug split: 2 forward only, 3 backward only
    for (unsigned l = 0; l < Tf; ++l) {
        for (unsigned e = P.levelPtr[l] + warp; e < P.levelPtr[l + 1]; e += warps) {
            const unsigned i = P.levelCols[e];
            float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f}, inv[6];
            if (useInv) directLoadInv(v, s, i, lane, true, inv);
            for (unsigned q = P.rowPtr[i] + lane; q < P.rowPtr[i + 1]; q += 32) directFwdEntry(acc, val, x, P, q);
            directWarpReduce6(acc);
            if (useInv) directFinishInv(x, i, acc, inv, lane, true); else if (lane == 0) directFwdFinish(val, x, P, i, acc);
        }
        __syncthreads();
        DIRECT_PROBE(1)
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
        if (!threadIdx.x) probeAcc[7] += 1;
#endif
    }
    if (Tf < P.levels) {
        unsigned buf = 0;
        // Prep: early entries of the first narrow level's rows (columns at
        // levels <= T-2) on every warp; the late ones (level T-1) follow below.
        {
            // Work items (row, part) of the next level: parts per row = max(1,
            // early warps / rows); item idx -> row idx % R, part idx / R; early
            // warp `we` takes items we, we + We, ... and slot idx holds its partial.
            const unsigned R = P.levelPtr[T + 1] - P.levelPtr[T], We = warps, parts = We / R > 0u ? We / R : 1u;
            for (unsigned idx = warp; idx < R * parts; idx += We) {
                const unsigned row = idx % R, part = idx / R, i = P.levelCols[P.levelPtr[T] + row];
                float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
                for (unsigned q = P.rowPtr[i] + part * 32u + lane; q < P.rowPtr[i + 1]; q += 32u * parts)
                    if (P.columnLevel[P.rowCols[q]] + 1u != T) directFwdEntry(acc, val, x, P, q);
                directWarpReduce6(acc);
                if (lane == 0) for (unsigned r = 0; r < 6; ++r) scratch[buf][idx][r] = acc[r];
            }
        }
        __syncthreads();
        for (unsigned l = T; l < P.levels; ++l) {
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
            unsigned long long nt[6] = {0, 0, 0, 0, 0, 0}; if (!threadIdx.x) nt[0] = clock64();
#define NARROW_MARK(k) if (!threadIdx.x) nt[k] = clock64();
#else
#define NARROW_MARK(k)
#endif
            const unsigned nl = P.levelPtr[l + 1] - P.levelPtr[l];
            const unsigned WePrev = (l == T) ? warps : warps - (P.levelPtr[l] - P.levelPtr[l - 1]);
            if (warp < nl) {
                const unsigned i = P.levelCols[P.levelPtr[l] + warp];
                const unsigned lb = P.lateFwdPtr[i], le = P.lateFwdPtr[i + 1];
                NARROW_MARK(1)
                float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f}, inv[6];
                if (useInv) directLoadInv(v, s, i, lane, true, inv);
                if (v.pipeline == 4u) { for (unsigned q = P.rowPtr[i] + lane; q < P.rowPtr[i + 1]; q += 32) directFwdEntry(acc, val, x, P, q); }
                else if (v.pipeline == 5u) { for (unsigned q = P.rowPtr[i] + lane; q < P.rowPtr[i + 1]; q += 32) if (P.columnLevel[P.rowCols[q]] + 1u != l) directFwdEntry(acc, val, x, P, q); for (unsigned t = lb + lane; t < le; t += 32) directFwdEntry(acc, val, x, P, P.lateFwdIdx[t]); }
                else for (unsigned t = lb + lane; t < le; t += 32) directFwdEntry(acc, val, x, P, P.lateFwdIdx[t]);
                NARROW_MARK(2)
                directWarpReduce6(acc);
                NARROW_MARK(3)
                if (v.pipeline < 4u) { const unsigned parts = WePrev / nl > 0u ? WePrev / nl : 1u; for (unsigned part = 0; part < parts; ++part) for (unsigned r = 0; r < 6; ++r) acc[r] += scratch[buf][warp + part * nl][r]; }
                if (useInv) directFinishInv(x, i, acc, inv, lane, true); else if (lane == 0) directFwdFinish(val, x, P, i, acc);
                NARROW_MARK(4)
            } else if (l + 1 < P.levels) {
                const unsigned R = P.levelPtr[l + 2] - P.levelPtr[l + 1], We = warps - nl, we = warp - nl, parts = We / R > 0u ? We / R : 1u;
                for (unsigned idx = we; idx < R * parts; idx += We) {
                    const unsigned row = idx % R, part = idx / R, i = P.levelCols[P.levelPtr[l + 1] + row];
                    float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
                    for (unsigned q = P.rowPtr[i] + part * 32u + lane; q < P.rowPtr[i + 1]; q += 32u * parts)
                        if (P.columnLevel[P.rowCols[q]] != l) directFwdEntry(acc, val, x, P, q);
                    directWarpReduce6(acc);
                    if (lane == 0) for (unsigned r = 0; r < 6; ++r) scratch[buf ^ 1u][idx][r] = acc[r];
                }
            }
            __syncthreads();
            NARROW_MARK(5)
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
            if (!threadIdx.x && nt[1]) { atomicAdd(directNarrowClocks + 0, nt[1] - nt[0]); atomicAdd(directNarrowClocks + 1, nt[2] - nt[1]); atomicAdd(directNarrowClocks + 2, nt[3] - nt[2]); atomicAdd(directNarrowClocks + 3, nt[4] - nt[3]); atomicAdd(directNarrowClocks + 4, nt[5] - nt[4]); atomicAdd(directNarrowClocks + 5, 1ull); }
#endif
#undef NARROW_MARK
            buf ^= 1u;
            DIRECT_PROBE(2)
#ifdef BLAST_GPU_COMPONENT_PHASE_PROBE
            if (!threadIdx.x) probeAcc[7] += 1;
#endif
        }
    }
    if (v.diagnostics >= 2u) {
        // Self-check of the forward sweep: L y = r on every row, against the
        // untouched residual source. One warp per row, lanes over entries.
        __shared__ float checkErr, checkRef;
        if (!threadIdx.x) { checkErr = 0.f; checkRef = 0.f; }
        __syncthreads();
        for (unsigned i = warp; i < P.nodes; i += warps) {
            const unsigned node = P.order[i];
            float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
            for (unsigned q = P.rowPtr[i] + lane; q < P.rowPtr[i + 1]; q += 32) directFwdEntry(acc, val, x, P, q);
            directWarpReduce6(acc);
            if (lane == 0) {
                const float* d = val + size_t(P.colPtr[i]) * kDirectBlockEntries;
                float rhs[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
                if (a.m_nodeIsland[node] == id && node != pinned) { const auto r = a.m_residual[node]; rhs[0] = r.angular.x; rhs[1] = r.angular.y; rhs[2] = r.angular.z; rhs[3] = r.linear.x; rhs[4] = r.linear.y; rhs[5] = r.linear.z; }
                float e = 0.f, f = 0.f;
                for (unsigned r = 0; r < 6; ++r) {
                    float sum = acc[r];
                    for (unsigned tt = 0; tt <= r; ++tt) sum = fmaf(d[r * 6 + tt], x[6 * i + tt], sum);
                    e += (sum - rhs[r]) * (sum - rhs[r]); f += rhs[r] * rhs[r];
                }
                atomicAdd(&checkErr, e); atomicAdd(&checkRef, f);
            }
        }
        __syncthreads();
        if (!threadIdx.x && checkErr > 1e-8f * fmaxf(checkRef, 1e-30f)) printf("direct forward check: component=%u nodes=%u levels=%u top=%u rel=%.3e\n", id, P.nodes, P.levels, P.topLevel, sqrtf(checkErr / fmaxf(checkRef, 1e-30f)));
        __syncthreads();
    }
    // Backward: L^T x = y, rows in descending level order (ancestors first).
    if (Tb < P.levels) {
        unsigned buf = 0;
        // The top level has no entries above it; its rows finish directly while
        // the other warps gather the early entries of the level below.
        for (unsigned l = P.levels; l-- > T;) {
            const unsigned nl = P.levelPtr[l + 1] - P.levelPtr[l];
            const unsigned WePrev = (l + 1 == P.levels) ? 0u : warps - (P.levelPtr[l + 2] - P.levelPtr[l + 1]);
            if (warp < nl) {
                const unsigned i = P.levelCols[P.levelPtr[l] + warp];
                float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f}, inv[6];
                if (useInv) directLoadInv(v, s, i, lane, false, inv);
                for (unsigned t = P.lateBwdPtr[i] + lane; t < P.lateBwdPtr[i + 1]; t += 32) directBwdEntry(acc, val, x, P, P.lateBwdIdx[t]);
                directWarpReduce6(acc);
                if (WePrev) { const unsigned parts = WePrev / nl > 0u ? WePrev / nl : 1u; for (unsigned part = 0; part < parts; ++part) for (unsigned r = 0; r < 6; ++r) acc[r] += scratch[buf][warp + part * nl][r]; }
                if (useInv) directFinishInv(x, i, acc, inv, lane, false); else if (lane == 0) directBwdFinish(val, x, P, i, acc);
            } else if (l > Tb) {
                const unsigned R = P.levelPtr[l] - P.levelPtr[l - 1], We = warps - nl, we = warp - nl, parts = We / R > 0u ? We / R : 1u;
                for (unsigned idx = we; idx < R * parts; idx += We) {
                    const unsigned row = idx % R, part = idx / R, i = P.levelCols[P.levelPtr[l - 1] + row], p0 = P.colPtr[i], p1 = P.colPtr[i + 1];
                    float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
                    for (unsigned q = p0 + 1u + part * 32u + lane; q < p1; q += 32u * parts)
                        if (P.columnLevel[P.rowIdx[q]] != l) directBwdEntry(acc, val, x, P, q);
                    directWarpReduce6(acc);
                    if (lane == 0) for (unsigned r = 0; r < 6; ++r) scratch[buf ^ 1u][idx][r] = acc[r];
                }
            }
            __syncthreads();
            buf ^= 1u;
            DIRECT_PROBE(4)
        }
    }
    for (unsigned l = Tb; l-- > 0;) {
        for (unsigned e = P.levelPtr[l] + warp; e < P.levelPtr[l + 1]; e += warps) {
            const unsigned i = P.levelCols[e], p0 = P.colPtr[i], p1 = P.colPtr[i + 1];
            float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f}, inv[6];
            if (useInv) directLoadInv(v, s, i, lane, false, inv);
            for (unsigned q = p0 + 1 + lane; q < p1; q += 32) directBwdEntry(acc, val, x, P, q);
            directWarpReduce6(acc);
            if (useInv) directFinishInv(x, i, acc, inv, lane, false); else if (lane == 0) directBwdFinish(val, x, P, i, acc);
        }
        __syncthreads();
        DIRECT_PROBE(3)
    }
    if (v.woodbury && v.slots.slotWoodbury[s] == 2u) {
        const NativeDirectOperator op{a.m_node0, a.m_node1, a.m_nodeBondBegin, a.m_nodeBondRef, a.m_nodeIsland, a.m_offset0, a.m_offset1, a.m_inertia, a.m_health, a.m_colScales};
        woodburyApply(v, op, P, p, pinned, s, x);
        if (v.counters && !threadIdx.x) atomicAdd(v.counters + 10, 1u);
    }
    DIRECT_PROBE(5)
    for (unsigned i = threadIdx.x; i < P.nodes; i += blockDim.x) {
        const unsigned node = P.order[i];
        if (a.m_nodeIsland[node] != id || node == pinned) continue;
        auto& u = a.hierarchy.solution[node];
        u.angular.x += double(x[6 * i + 0]); u.angular.y += double(x[6 * i + 1]); u.angular.z += double(x[6 * i + 2]);
        u.linear.x += double(x[6 * i + 3]);  u.linear.y += double(x[6 * i + 4]);  u.linear.z += double(x[6 * i + 5]);
    }
    if (v.counters && !threadIdx.x) { atomicAdd(v.counters + 1, 1u); if (pinned != kNoIsland) atomicAdd(v.counters + 5, 1u); if (v.slots.slotStale[s]) atomicAdd(v.counters + 7, 1u); }
    __syncthreads();
    DIRECT_PROBE(6)
    DIRECT_PROBE_PUBLISH
#undef DIRECT_PROBE
#undef DIRECT_PROBE_PUBLISH
    return true;
}
#include "StressNativeDenseTiny.cuh"
// Undo the last application: subtract the same x from the accumulated solution.
__device__ __forceinline__ void directUndoNativeComponent(const PersistentStressArgs& a, const unsigned* nodes, unsigned id, const float* x) {
    const NativeDirectView& v = a.hierarchy.direct;
    const unsigned p = v.pattern.nodeParent[nodes[0]];
    const unsigned pinned = StressHierarchy::motionDimension(a.hierarchy.modes.components[id]) ? id : kNoIsland;
    const auto P = directPatternRefs(v.pattern, p);
    for (unsigned i = threadIdx.x; i < P.nodes; i += blockDim.x) {
        const unsigned node = P.order[i];
        if (a.m_nodeIsland[node] != id || node == pinned) continue;
        auto& u = a.hierarchy.solution[node];
        u.angular.x -= double(x[6 * i + 0]); u.angular.y -= double(x[6 * i + 1]); u.angular.z -= double(x[6 * i + 2]);
        u.linear.x -= double(x[6 * i + 3]);  u.linear.y -= double(x[6 * i + 4]);  u.linear.z -= double(x[6 * i + 5]);
    }
    if (v.counters && !threadIdx.x) atomicAdd(v.counters + 8, 1u);
    __syncthreads();
}
#endif
