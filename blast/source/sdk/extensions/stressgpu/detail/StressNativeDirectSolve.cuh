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
    for (unsigned i = threadIdx.x; i < P.nodes; i += blockDim.x) {
        const unsigned node = P.order[i];
        if (a.m_nodeIsland[node] == id && node != pinned) {
            const auto r = a.m_residual[node];
            x[6 * i + 0] = r.angular.x; x[6 * i + 1] = r.angular.y; x[6 * i + 2] = r.angular.z;
            x[6 * i + 3] = r.linear.x;  x[6 * i + 4] = r.linear.y;  x[6 * i + 5] = r.linear.z;
        } else for (unsigned r = 0; r < 6; ++r) x[6 * i + r] = 0.f;
    }
    __syncthreads();
    // Forward: L y = r, rows in ascending level order (descendants first).
    for (unsigned l = 0; l < P.levels; ++l) {
        for (unsigned e = P.levelPtr[l] + warp; e < P.levelPtr[l + 1]; e += warps) {
            const unsigned i = P.levelCols[e];
            float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
            for (unsigned q = P.rowPtr[i] + lane; q < P.rowPtr[i + 1]; q += 32) {
                const float* blk = val + size_t(P.rowPos[q]) * kDirectBlockEntries;
                const float* xk = x + 6 * P.rowCols[q];
                for (unsigned r = 0; r < 6; ++r) {
                    float sum = acc[r];
                    for (unsigned cc = 0; cc < 6; ++cc) sum = fmaf(blk[r * 6 + cc], xk[cc], sum);
                    acc[r] = sum;
                }
            }
            directWarpReduce6(acc);
            if (lane == 0) {
                const float* d = val + size_t(P.colPtr[i]) * kDirectBlockEntries;
                float y[6];
                for (unsigned r = 0; r < 6; ++r) {
                    float sum = x[6 * i + r] - acc[r];
                    for (unsigned tt = 0; tt < r; ++tt) sum = fmaf(-d[r * 6 + tt], y[tt], sum);
                    y[r] = sum / d[r * 6 + r];
                }
                for (unsigned r = 0; r < 6; ++r) x[6 * i + r] = y[r];
            }
        }
        __syncthreads();
    }
    // Backward: L^T x = y, rows in descending level order (ancestors first).
    for (unsigned l = P.levels; l-- > 0;) {
        for (unsigned e = P.levelPtr[l] + warp; e < P.levelPtr[l + 1]; e += warps) {
            const unsigned i = P.levelCols[e], p0 = P.colPtr[i], p1 = P.colPtr[i + 1];
            float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
            for (unsigned q = p0 + 1 + lane; q < p1; q += 32) {
                const float* blk = val + size_t(q) * kDirectBlockEntries; // L(k,i)
                const float* xk = x + 6 * P.rowIdx[q];
                for (unsigned r = 0; r < 6; ++r) {
                    float sum = acc[r];
                    for (unsigned cc = 0; cc < 6; ++cc) sum = fmaf(blk[cc * 6 + r], xk[cc], sum);
                    acc[r] = sum;
                }
            }
            directWarpReduce6(acc);
            if (lane == 0) {
                const float* d = val + size_t(p0) * kDirectBlockEntries;
                float y[6];
                for (unsigned r = 6; r-- > 0;) {
                    float sum = x[6 * i + r] - acc[r];
                    for (unsigned tt = r + 1; tt < 6; ++tt) sum = fmaf(-d[tt * 6 + r], y[tt], sum);
                    y[r] = sum / d[r * 6 + r];
                }
                for (unsigned r = 0; r < 6; ++r) x[6 * i + r] = y[r];
            }
        }
        __syncthreads();
    }
    if (v.woodbury && v.slots.slotWoodbury[s] == 2u) {
        const NativeDirectOperator op{a.m_node0, a.m_node1, a.m_nodeBondBegin, a.m_nodeBondRef, a.m_nodeIsland, a.m_offset0, a.m_offset1, a.m_inertia, a.m_health, a.m_colScales};
        woodburyApply(v, op, P, p, pinned, s, x);
        if (v.counters && !threadIdx.x) atomicAdd(v.counters + 10, 1u);
    }
    for (unsigned i = threadIdx.x; i < P.nodes; i += blockDim.x) {
        const unsigned node = P.order[i];
        if (a.m_nodeIsland[node] != id || node == pinned) continue;
        auto& u = a.hierarchy.solution[node];
        u.angular.x += double(x[6 * i + 0]); u.angular.y += double(x[6 * i + 1]); u.angular.z += double(x[6 * i + 2]);
        u.linear.x += double(x[6 * i + 3]);  u.linear.y += double(x[6 * i + 4]);  u.linear.z += double(x[6 * i + 5]);
    }
    if (v.counters && !threadIdx.x) { atomicAdd(v.counters + 1, 1u); if (pinned != kNoIsland) atomicAdd(v.counters + 5, 1u); if (v.slots.slotStale[s]) atomicAdd(v.counters + 7, 1u); }
    __syncthreads();
    return true;
}
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
