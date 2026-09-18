// Dense direct step for tiny components (at most kTinyComponentNodes nodes,
// below the cached-factor minimum). The 1,693 free debris components of a
// late city256 solve cost a third of the solve kernel's cycles in PCG
// machinery (preconditioner, monitors, barriers) for systems of at most 42
// unknowns. Here the component operator is assembled from its live bonds
// into shared memory, factored by a dense Cholesky and solved in place; the
// caller's acceptance flow (true residual, monotone gate, verification) is
// unchanged, so the result is exact under the same contract as the cached
// factors. Free components pin their id node exactly as the cached path does.
#ifdef PHYSX_RESIDENT_DESTRUCTION
constexpr unsigned kDenseTinyMaxNodes = 7u;
constexpr unsigned kDenseTinyMaxDim = 6u * kDenseTinyMaxNodes;

__device__ __forceinline__ unsigned denseTinyLocal(const unsigned* nodes, unsigned count, unsigned node) {
    for (unsigned i = 0; i < count; ++i) if (nodes[i] == node) return i;
    return kNoIsland;
}
// Returns false when the dense factorization fails (caller falls back to PCG).
// Warp 0 does the assembly, the factorization and the triangular solves with
// warp-level synchronisation only; the rest of the CTA waits at the end.
__device__ bool denseSolveTinyComponent(const PersistentStressArgs& a, const unsigned* nodes, unsigned count, unsigned id, float* x) {
    __shared__ float A[kDenseTinyMaxDim * kDenseTinyMaxDim];
    __shared__ unsigned denseFailed;
    const NativeDirectView& v = a.hierarchy.direct;
    const unsigned n = 6u * count;
    const unsigned pinned = StressHierarchy::motionDimension(a.hierarchy.modes.components[id]) ? id : kNoIsland;
    if (!threadIdx.x) denseFailed = 0;
    if (threadIdx.x < 32) {
        const unsigned lane = threadIdx.x;
        // Assemble: one lane per block (li, lj), from node li's live bonds.
        for (unsigned t = lane; t < count * count; t += 32) {
            const unsigned li = t / count, lj = t % count, inode = nodes[li], jnode = nodes[lj];
            float acc[kDirectBlockEntries];
            for (unsigned e = 0; e < kDirectBlockEntries; ++e) acc[e] = 0.f;
            const bool present = inode != pinned && jnode != pinned;
            if (present) {
                const Inertia di = a.m_inertia[inode];
                for (unsigned r = a.m_nodeBondBegin[inode]; r < a.m_nodeBondBegin[inode + 1]; ++r) {
                    const unsigned ref = a.m_nodeBondRef[r];
                    if (ref == kDeadBondRef) continue;
                    const unsigned edge = ref & 0x7fffffffu;
                    if (a.m_health[edge] <= 0.f) continue;
                    const bool second = (ref >> 31) != 0u;
                    const unsigned other = second ? a.m_node0[edge] : a.m_node1[edge];
                    float mi[kDirectBlockEntries];
                    directBondBlock(mi, second ? a.m_offset1[edge] : a.m_offset0[edge], di, a.m_colScales[edge], second ? -1.f : 1.f);
                    if (li == lj) directAccumulateMMt(acc, mi, mi);
                    else if (other == jnode) {
                        float mj[kDirectBlockEntries];
                        directBondBlock(mj, second ? a.m_offset0[edge] : a.m_offset1[edge], a.m_inertia[jnode], a.m_colScales[edge], second ? 1.f : -1.f);
                        directAccumulateMMt(acc, mi, mj);
                    }
                }
            } else if (li == lj) { acc[0] = acc[7] = acc[14] = acc[21] = acc[28] = acc[35] = 1.f; }
            for (unsigned r = 0; r < 6; ++r) for (unsigned c = 0; c < 6; ++c) A[(6u * li + r) * n + 6u * lj + c] = acc[r * 6 + c];
        }
        for (unsigned i = lane; i < count; i += 32) {
            const unsigned node = nodes[i];
            if (node != pinned) {
                const auto r = a.m_residual[node];
                x[6 * i + 0] = r.angular.x; x[6 * i + 1] = r.angular.y; x[6 * i + 2] = r.angular.z;
                x[6 * i + 3] = r.linear.x;  x[6 * i + 4] = r.linear.y;  x[6 * i + 5] = r.linear.z;
            } else for (unsigned r = 0; r < 6; ++r) x[6 * i + r] = 0.f;
        }
        __syncwarp();
        // Dense lower Cholesky in place, column by column (deterministic).
        bool failed = false;
        for (unsigned c = 0; c < n && !failed; ++c) {
            float diag = A[c * n + c];
            for (unsigned t = 0; t < c; ++t) diag = fmaf(-A[c * n + t], A[c * n + t], diag);
            if (!(diag > 0.f) || !isfinite(diag)) { failed = true; break; }
            const float l = sqrtf(diag), inv = 1.f / l;
            __syncwarp();
            if (!lane) A[c * n + c] = l;
            for (unsigned r = c + 1u + lane; r < n; r += 32) {
                float sum = A[r * n + c];
                for (unsigned t = 0; t < c; ++t) sum = fmaf(-A[r * n + t], A[c * n + t], sum);
                A[r * n + c] = sum * inv;
            }
            __syncwarp();
        }
        if (failed) { if (!lane) denseFailed = 1; }
        else {
            // Forward L y = r then backward L^T x = y: lanes over the inner sums.
            for (unsigned r = 0; r < n; ++r) {
                float sum = 0.f;
                for (unsigned t = lane; t < r; t += 32) sum = fmaf(A[r * n + t], x[t], sum);
                for (unsigned o = 16; o; o >>= 1) sum += __shfl_xor_sync(0xffffffffu, sum, o);
                if (!lane) x[r] = (x[r] - sum) / A[r * n + r];
                __syncwarp();
            }
            for (unsigned r = n; r-- > 0;) {
                float sum = 0.f;
                for (unsigned t = r + 1 + lane; t < n; t += 32) sum = fmaf(A[t * n + r], x[t], sum);
                for (unsigned o = 16; o; o >>= 1) sum += __shfl_xor_sync(0xffffffffu, sum, o);
                if (!lane) x[r] = (x[r] - sum) / A[r * n + r];
                __syncwarp();
            }
            for (unsigned i = lane; i < count; i += 32) {
                const unsigned node = nodes[i];
                if (node == pinned) continue;
                auto& u = a.hierarchy.solution[node];
                u.angular.x += double(x[6 * i + 0]); u.angular.y += double(x[6 * i + 1]); u.angular.z += double(x[6 * i + 2]);
                u.linear.x += double(x[6 * i + 3]);  u.linear.y += double(x[6 * i + 4]);  u.linear.z += double(x[6 * i + 5]);
            }
            if (v.counters && !lane) { atomicAdd(v.counters + 1, 1u); atomicAdd(v.counters + 11, 1u); if (pinned != kNoIsland) atomicAdd(v.counters + 5, 1u); }
        }
    }
    __syncthreads();
    return !denseFailed;
}
__device__ __forceinline__ void denseUndoTinyComponent(const PersistentStressArgs& a, const unsigned* nodes, unsigned count, unsigned id, const float* x) {
    const unsigned pinned = StressHierarchy::motionDimension(a.hierarchy.modes.components[id]) ? id : kNoIsland;
    for (unsigned i = threadIdx.x; i < count; i += blockDim.x) {
        const unsigned node = nodes[i];
        if (node == pinned) continue;
        auto& u = a.hierarchy.solution[node];
        u.angular.x -= double(x[6 * i + 0]); u.angular.y -= double(x[6 * i + 1]); u.angular.z -= double(x[6 * i + 2]);
        u.linear.x -= double(x[6 * i + 3]);  u.linear.y -= double(x[6 * i + 4]);  u.linear.z -= double(x[6 * i + 5]);
    }
    if (a.hierarchy.direct.counters && !threadIdx.x) atomicAdd(a.hierarchy.direct.counters + 8, 1u);
    __syncthreads();
}
#endif
