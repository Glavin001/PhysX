// Cached direct factorization for anchored resident components (R1).
//
// Each initial anchored component (an asset instance at configuration) gets
// one host-computed symbolic block pattern: a minimum-degree ordering of its
// dynamic nodes, the block Cholesky fill structure, and an elimination-tree
// level schedule. Every later remnant of that component is a node subset, and
// bond removal never adds fill, so the parent's pattern stays a valid superset:
// absent nodes become identity blocks and removed bonds become zeros.
//
// Numeric factors live in a device slot pool keyed by the current component
// id (the minimum member node). A slot is invalidated by exactly the same
// changed-old-component flags and generation rule the settled certificates use,
// refactored by one CTA per component inside the solve graph, and applied in
// componentStressSolve as two block triangular solves whose result is added to
// the FP64 accumulated solution before the existing residual verification.
// The physical operator, load, tolerance and iteration cap are unchanged: the
// direct step only proposes a solution that the original gate still verifies.
#ifdef PHYSX_RESIDENT_DESTRUCTION
constexpr unsigned kDirectBlockEntries = 36u;
constexpr unsigned kDirectMinNodes = 8u;
constexpr unsigned kDirectStaleAttempts = 6u;

struct NativeDirectPatternView {
    const unsigned* nodeParent = nullptr;        // node -> pattern instance index or kNoIsland
    const unsigned* nodeLocal = nullptr;         // node -> local block index in its pattern
    const unsigned* patternNodeBegin = nullptr;  // instance -> offset into order (instances+1)
    const unsigned* order = nullptr;             // local -> node (per instance)
    const unsigned* patternStructure = nullptr;  // instance -> structure index (identical structures share one)
    const unsigned* structureNodeBegin = nullptr;// structure -> offset into levelCols (structures+1)
    const unsigned* patternColBegin = nullptr;   // pattern -> offset into colPtr/rowPtr (patterns+1), np+1 entries each
    const unsigned* colPtr = nullptr;            // column j -> [colPtr[j], colPtr[j+1]) pattern-local block positions, diagonal first
    const unsigned* patternPosBegin = nullptr;   // pattern -> offset into rowIdx (patterns+1)
    const unsigned* rowIdx = nullptr;            // position -> local block row
    const unsigned* rowPtr = nullptr;            // column j -> [rowPtr[j], rowPtr[j+1]) entries in rowCols/rowPos (k<j with L(j,k)!=0)
    const unsigned* patternRowEntryBegin = nullptr; // pattern -> offset into rowCols/rowPos (patterns+1)
    const unsigned* rowCols = nullptr;           // entry -> k
    const unsigned* rowPos = nullptr;            // entry -> pattern-local position of block (j,k) in column k
    const unsigned* patternLevelBegin = nullptr; // pattern -> offset into levelPtr (patterns+1)
    const unsigned* patternLevelCount = nullptr; // pattern -> number of levels
    const unsigned* levelPtr = nullptr;          // level l -> [levelPtr[l], levelPtr[l+1]) into levelCols (levels+1 entries per pattern)
    const unsigned* levelCols = nullptr;         // local columns ordered by level (np entries per pattern, offset patternNodeBegin)
    const unsigned* columnLevel = nullptr;       // local column -> level (np entries per structure, offset structureNodeBegin)
    const unsigned* structureTopLevel = nullptr; // structure -> first level of the narrow tail (levels with fewer columns than warps); == levels when none
};
struct NativeDirectSlotView {
    float* values = nullptr;               // slotCount * stride
    unsigned* slotComponent = nullptr;     // slot -> component id or kNoIsland
    unsigned* componentSlot = nullptr;     // component id -> slot or kNoIsland (node capacity entries)
    unsigned* slotValid = nullptr;         // factor values are current for the component's operator
    unsigned* slotFailed = nullptr;        // numeric factorization failed; PCG handles the component
    unsigned* slotStale = nullptr;         // factor predates a topology change: still applied as a preconditioner, refactored after the next solve
    unsigned* slotPinned = nullptr;        // pinned node the factor was built with (kNoIsland for anchored); a stale factor is only applied to the same pinning
    unsigned long long* slotGeneration = nullptr;
    unsigned* freeList = nullptr;          // scratch for deterministic assignment (slotCount entries)
    unsigned slotCount = 0, stride = 0;
};
struct NativeDirectView {
    NativeDirectPatternView pattern{};
    NativeDirectSlotView slots{};
    unsigned* counters = nullptr; // diagnostics: [0] eligible [1] applied [2] accepted before iterating [3] no slot [4] slot invalid/failed [5] pinned free applied [6] refactored [7] stale applied [8] applications undone (residual grew)
    unsigned enabled = 0, diagnostics = 0, minNodes = kDirectMinNodes;
    // Deferred mode: a changed component keeps its factor as a stale
    // preconditioner for this solve and is refactored after the solve, off the
    // tick's critical path. Otherwise changed factors are invalidated and
    // refactored before the solve (the original R1 schedule).
    unsigned deferred = 1;
    // Right-looking elimination of the narrow tail of the elimination tree
    // (the dense top): rank-6 updates spread over the CTA instead of one
    // gather per target block over every finished column.
    unsigned rightLooking = 1;
};
constexpr unsigned kDirectCounterCount = 9u;
struct NativeDirectOperator {
    const unsigned *node0, *node1, *nodeBondBegin, *nodeBondRef, *nodeIsland;
    const Vec4 *offset0, *offset1;
    const Inertia* inertia;
    const float *health, *colScale;
};

// M = sign * s * D * C with C = [[I, -skew(o)], [0, I]] and D = diag(d_a I, d_l I),
// row-major 6x6: rows 0-2 angular, rows 3-5 linear. This is one node-side
// factor of the bond term of the resident operator D C S^2 C^T D.
__device__ __forceinline__ void directBondBlock(float m[kDirectBlockEntries], const Vec4& o, const Inertia& d, float s, float sign) {
    const float da = sign * s * d.angular, dl = sign * s * d.linear;
    for (unsigned e = 0; e < kDirectBlockEntries; ++e) m[e] = 0.f;
    m[0] = da; m[7] = da; m[14] = da; m[21] = dl; m[28] = dl; m[35] = dl;
    m[0 * 6 + 4] = da * o.z;  m[0 * 6 + 5] = -da * o.y;
    m[1 * 6 + 3] = -da * o.z; m[1 * 6 + 5] = da * o.x;
    m[2 * 6 + 3] = da * o.y;  m[2 * 6 + 4] = -da * o.x;
}
__device__ __forceinline__ void directAccumulateMMt(float acc[kDirectBlockEntries], const float a[kDirectBlockEntries], const float b[kDirectBlockEntries]) {
    for (unsigned r = 0; r < 6; ++r)
        for (unsigned c = 0; c < 6; ++c) {
            float sum = acc[r * 6 + c];
            for (unsigned t = 0; t < 6; ++t) sum = fmaf(a[r * 6 + t], b[c * 6 + t], sum);
            acc[r * 6 + c] = sum;
        }
}
// In-place lower Cholesky of a 6x6 SPD block. Returns false on a non-positive pivot.
__device__ __forceinline__ bool directCholesky6(float* d) {
    for (unsigned c = 0; c < 6; ++c) {
        for (unsigned r = c; r < 6; ++r) {
            float sum = d[r * 6 + c];
            for (unsigned t = 0; t < c; ++t) sum = fmaf(-d[r * 6 + t], d[c * 6 + t], sum);
            if (r == c) {
                if (!(sum > 0.f) || !isfinite(sum)) return false;
                d[c * 6 + c] = sqrtf(sum);
            } else d[r * 6 + c] = sum / d[c * 6 + c];
        }
        for (unsigned t = c + 1; t < 6; ++t) d[c * 6 + t] = 0.f;
    }
    return true;
}
struct NativeDirectPatternRefs {
    const unsigned *order, *colPtr, *rowIdx, *rowPtr, *rowCols, *rowPos, *levelPtr, *levelCols, *columnLevel;
    unsigned nodes, levels, blocks, topLevel;
};
__device__ __forceinline__ NativeDirectPatternRefs directPatternRefs(const NativeDirectPatternView& P, unsigned p) {
    NativeDirectPatternRefs r;
    const unsigned nodeBase = P.patternNodeBegin[p], s = P.patternStructure[p];
    r.nodes = P.patternNodeBegin[p + 1] - nodeBase;
    r.order = P.order + nodeBase; r.levelCols = P.levelCols + P.structureNodeBegin[s];
    r.colPtr = P.colPtr + P.patternColBegin[s]; r.rowPtr = P.rowPtr + P.patternColBegin[s];
    r.rowIdx = P.rowIdx + P.patternPosBegin[s];
    r.rowCols = P.rowCols + P.patternRowEntryBegin[s]; r.rowPos = P.rowPos + P.patternRowEntryBegin[s];
    r.levelPtr = P.levelPtr + P.patternLevelBegin[s]; r.levels = P.patternLevelCount[s];
    r.blocks = P.patternPosBegin[s + 1] - P.patternPosBegin[s];
    r.columnLevel = P.columnLevel + P.structureNodeBegin[s]; r.topLevel = P.structureTopLevel[s];
    return r;
}

// Topology rebuild, before relabeling: consume the OLD component ids and the
// exact changed-old-component flags. Unchanged components keep their factor
// and advance to the batch generation; changed ones need a refactorization.
__global__ void refreshNativeDirectSlots(NativeDirectView v, ResidentStressComponentView c,
    const ExtStressGpuDeviceTopologyStatus* state, const DeviceStressTopologyBatch* batch, const unsigned* changed) {
    if (!v.enabled) return;
    for (unsigned t = blockIdx.x * blockDim.x + threadIdx.x; t < *c.count; t += blockDim.x * gridDim.x) {
        const unsigned id = c.ids[t], s = v.slots.componentSlot[id];
        if (s == kNoIsland) continue;
        if (!state->initialized || changed[id] || v.slots.slotGeneration[s] != state->generation) {
            if (v.deferred && state->initialized && v.slots.slotValid[s] && !v.slots.slotFailed[s]) {
                // Bond removal never adds fill: the old factor is an exact factor of a
                // nearby operator on a superset pattern, i.e. a preconditioner.
                v.slots.slotStale[s] = 1; v.slots.slotGeneration[s] = batch->generation ? *batch->generation : 0ull;
            } else { v.slots.slotValid[s] = 0; v.slots.slotFailed[s] = 0; v.slots.slotStale[s] = 0; }
        } else v.slots.slotGeneration[s] = batch->generation ? *batch->generation : 0ull;
    }
}
// Topology rebuild, after relabeling: a slot whose component id is no longer a
// root is released. A root that survived keeps its slot (valid or dirty).
__global__ void releaseNativeDirectSlots(NativeDirectView v, const unsigned* nodeIsland, unsigned n) {
    if (!v.enabled) return;
    for (unsigned s = blockIdx.x * blockDim.x + threadIdx.x; s < v.slots.slotCount; s += blockDim.x * gridDim.x) {
        const unsigned id = v.slots.slotComponent[s];
        if (id == kNoIsland) continue;
        if (id >= n || nodeIsland[id] != id) {
            v.slots.componentSlot[id] = kNoIsland; v.slots.slotComponent[s] = kNoIsland;
            v.slots.slotValid[s] = 0; v.slots.slotFailed[s] = 0; v.slots.slotStale[s] = 0;
        }
    }
}
// Solve entry: every eligible live component without a slot claims one, in
// component-list order from the free slots in ascending order. One CTA runs
// this deterministically: identical inputs always produce identical slot
// assignments, so pool exhaustion never makes the fallback set run-dependent.
__device__ __forceinline__ unsigned directBlockScanInclusive(unsigned* scan, unsigned value) {
    scan[threadIdx.x] = value; __syncthreads();
    for (unsigned o = 1; o < kBlockSize; o <<= 1) { const unsigned x = threadIdx.x >= o ? scan[threadIdx.x - o] : 0u; __syncthreads(); scan[threadIdx.x] += x; __syncthreads(); }
    return scan[threadIdx.x];
}
__global__ void assignNativeDirectSlots(NativeDirectView v, ResidentStressComponentView c,
    const StressHierarchy::MotionComponent* modes, const ExtStressGpuDeviceTopologyStatus* state) {
    __shared__ unsigned scan[kBlockSize];
    __shared__ unsigned freeTotal, needTotal;
    if (!v.enabled || blockIdx.x) return;
    if (!threadIdx.x) { freeTotal = 0; needTotal = 0; if (v.counters) for (unsigned k = 0; k < kDirectCounterCount; ++k) v.counters[k] = 0; }
    __syncthreads();
    // Pass 1: ascending list of free slots (snapshot, no writes to slot state).
    for (unsigned base = 0; base < v.slots.slotCount; base += kBlockSize) {
        const unsigned k = base + threadIdx.x;
        const unsigned isFree = (k < v.slots.slotCount && v.slots.slotComponent[k] == kNoIsland) ? 1u : 0u;
        const unsigned inclusive = directBlockScanInclusive(scan, isFree);
        if (isFree) v.slots.freeList[freeTotal + inclusive - 1u] = k;
        __syncthreads();
        if (threadIdx.x == kBlockSize - 1) freeTotal += inclusive;
        __syncthreads();
    }
    // Pass 2: k-th needing component (component-list order) takes freeList[k].
    const unsigned total = *c.count;
    for (unsigned base = 0; base < total; base += kBlockSize) {
        const unsigned t = base + threadIdx.x;
        unsigned need = 0u, id = kNoIsland;
        if (t < total) {
            id = c.ids[t];
            const unsigned count = c.end[id] - c.begin[id];
            need = (count <= kResidentComponentMaxNodes && count >= v.minNodes
                && v.pattern.nodeParent[c.nodes[c.begin[id]]] != kNoIsland
                && v.slots.componentSlot[id] == kNoIsland) ? 1u : 0u;
        }
        const unsigned inclusive = directBlockScanInclusive(scan, need);
        const unsigned rank = needTotal + inclusive - need;
        if (need && rank < freeTotal) {
            const unsigned s = v.slots.freeList[rank];
            v.slots.slotValid[s] = 0; v.slots.slotFailed[s] = 0; v.slots.slotStale[s] = 0; v.slots.slotGeneration[s] = state->generation;
            v.slots.componentSlot[id] = s; v.slots.slotComponent[s] = id;
        }
        __syncthreads();
        if (threadIdx.x == kBlockSize - 1) needTotal += inclusive;
        __syncthreads();
    }
}
// Numeric block Cholesky of every assigned-but-invalid slot: one CTA per
// component, warp per column, columns of one elimination-tree level in
// parallel, left-looking updates gathered in a fixed order (deterministic).
__global__ void __launch_bounds__(kBlockSize, 2) factorNativeDirect(NativeDirectView v, NativeDirectOperator op,
    ResidentStressComponentView c, const StressHierarchy::MotionComponent* modes, const ExtStressGpuDeviceTopologyStatus* state) {
    __shared__ unsigned failed;
    if (!v.enabled) return;
    const unsigned warp = threadIdx.x >> 5, lane = threadIdx.x & 31, warps = blockDim.x >> 5;
    for (unsigned t = blockIdx.x; t < *c.count; t += gridDim.x) {
        const unsigned id = c.ids[t], s = v.slots.componentSlot[id];
        if (s == kNoIsland || (v.slots.slotValid[s] && !v.slots.slotStale[s]) || v.slots.slotFailed[s]) continue;
        const unsigned p = v.pattern.nodeParent[c.nodes[c.begin[id]]];
        if (p == kNoIsland) continue;
        const auto P = directPatternRefs(v.pattern, p);
        float* val = v.slots.values + size_t(s) * v.slots.stride;
        // A free component has a rigid null space. Pinning its minimum node (the
        // component id) makes the reduced operator SPD; any particular solution
        // of the compatible projected residual yields the same bond forces.
        const unsigned pinned = modes[id].anchored ? kNoIsland : id;
        // Levels below T use the level-parallel left-looking scheme; levels
        // from T on (the narrow tail) are eliminated one column at a time with
        // right-looking updates. Both give each target block one writer per
        // source column in a fixed order, so the factor is deterministic.
        const unsigned T = v.rightLooking ? P.topLevel : P.levels, topBegin = P.levelPtr[T];
        if (!threadIdx.x) { failed = 0; if (v.counters) atomicAdd(v.counters + 6, 1u); }
        __syncthreads();
        for (unsigned l = 0; l < T; ++l) {
            const unsigned levelBegin = P.levelPtr[l], levelEnd = P.levelPtr[l + 1];
            // Sparse levels (the dense top of the elimination tree) use the
            // whole CTA per column; wide levels use one warp per column. Both
            // give every target block exactly one writer per source column k,
            // applied in a fixed order, so results are deterministic.
            const bool wide = (levelEnd - levelBegin) >= warps;
            const unsigned groups = wide ? warps : 1u, group = wide ? warp : 0u;
            const unsigned lanes = wide ? 32u : blockDim.x, laneId = wide ? lane : threadIdx.x;
            for (unsigned e = levelBegin + group; e < levelEnd; e += groups) {
                const unsigned j = P.levelCols[e], jnode = P.order[j], p0 = P.colPtr[j], p1 = P.colPtr[j + 1];
                const bool present = op.nodeIsland[jnode] == id && jnode != pinned;
                const Inertia dj = op.inertia[jnode];
                // Assemble column j of the current operator inside the parent pattern.
                for (unsigned q = p0 + laneId; q < p1; q += lanes) {
                    const unsigned i = P.rowIdx[q], inode = P.order[i];
                    float acc[kDirectBlockEntries];
                    for (unsigned x = 0; x < kDirectBlockEntries; ++x) acc[x] = 0.f;
                    if (present && op.nodeIsland[inode] == id && inode != pinned) {
                        for (unsigned r = op.nodeBondBegin[jnode]; r < op.nodeBondBegin[jnode + 1]; ++r) {
                            const unsigned ref = op.nodeBondRef[r];
                            if (ref == kDeadBondRef) continue;
                            const unsigned edge = ref & 0x7fffffffu;
                            if (op.health[edge] <= 0.f) continue;
                            const bool second = (ref >> 31) != 0u;
                            const unsigned other = second ? op.node0[edge] : op.node1[edge];
                            float mj[kDirectBlockEntries];
                            directBondBlock(mj, second ? op.offset1[edge] : op.offset0[edge], dj, op.colScale[edge], second ? -1.f : 1.f);
                            if (i == j) directAccumulateMMt(acc, mj, mj);
                            else if (other == inode) {
                                float mi[kDirectBlockEntries];
                                directBondBlock(mi, second ? op.offset0[edge] : op.offset1[edge], op.inertia[inode], op.colScale[edge], second ? 1.f : -1.f);
                                directAccumulateMMt(acc, mi, mj);
                            }
                        }
                    } else if (i == j) { acc[0] = acc[7] = acc[14] = acc[21] = acc[28] = acc[35] = 1.f; }
                    float* dst = val + size_t(q) * kDirectBlockEntries;
                    for (unsigned x = 0; x < kDirectBlockEntries; ++x) dst[x] = acc[x];
                }
                if (wide) __syncwarp(); else __syncthreads();
                // Left-looking gather: each thread owns one row of one target
                // block (i,j) and accumulates -L(i,k) L(j,k)^T over every finished
                // column k of row j, locating (i,k) by binary search in column k's
                // sorted rows. No barrier is needed and the k order is fixed.
                for (unsigned t = laneId; t < (p1 - p0) * 6u; t += lanes) {
                    const unsigned q = p0 + t / 6u, rr = t % 6u, i = P.rowIdx[q];
                    float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
                    for (unsigned r = P.rowPtr[j]; r < P.rowPtr[j + 1]; ++r) {
                        const unsigned k = P.rowCols[r], q0 = P.rowPos[r];
                        unsigned lo = q0, hi = P.colPtr[k + 1];
                        while (lo < hi) { const unsigned mid = (lo + hi) >> 1; if (P.rowIdx[mid] < i) lo = mid + 1; else hi = mid; }
                        if (lo >= P.colPtr[k + 1] || P.rowIdx[lo] != i) continue;
                        const float* ljk = val + size_t(q0) * kDirectBlockEntries;
                        const float* lik = val + size_t(lo) * kDirectBlockEntries + rr * 6u;
                        for (unsigned cc = 0; cc < 6; ++cc) {
                            float sum = acc[cc];
                            for (unsigned tt = 0; tt < 6; ++tt) sum = fmaf(lik[tt], ljk[cc * 6 + tt], sum);
                            acc[cc] = sum;
                        }
                    }
                    float* dst = val + size_t(q) * kDirectBlockEntries + rr * 6u;
                    for (unsigned cc = 0; cc < 6; ++cc) dst[cc] -= acc[cc];
                }
                if (wide) __syncwarp(); else __syncthreads();
                if (laneId == 0) { if (!directCholesky6(val + size_t(p0) * kDirectBlockEntries)) atomicExch(&failed, 1u); }
                if (wide) __syncwarp(); else __syncthreads();
                {
                    const float* ljj = val + size_t(p0) * kDirectBlockEntries;
                    for (unsigned t = laneId; t < (p1 - p0 - 1u) * 6u; t += lanes) {
                        const unsigned q = p0 + 1u + t / 6u, rr = t % 6u;
                        float* row = val + size_t(q) * kDirectBlockEntries + rr * 6u;
                        for (unsigned cc = 0; cc < 6; ++cc) {
                            float sum = row[cc];
                            for (unsigned tt = 0; tt < cc; ++tt) sum = fmaf(-row[tt], ljj[cc * 6 + tt], sum);
                            row[cc] = sum / ljj[cc * 6 + cc];
                        }
                    }
                }
                if (!wide) __syncthreads();
            }
            __syncthreads();
        }
        // Dense top, step 1: assemble every column of the tail up front, because
        // right-looking updates land in columns that are eliminated later.
        for (unsigned e = topBegin + warp; e < P.nodes; e += warps) {
            const unsigned j = P.levelCols[e], jnode = P.order[j], p0 = P.colPtr[j], p1 = P.colPtr[j + 1];
            const bool present = op.nodeIsland[jnode] == id && jnode != pinned;
            const Inertia dj = op.inertia[jnode];
            for (unsigned q = p0 + lane; q < p1; q += 32) {
                const unsigned i = P.rowIdx[q], inode = P.order[i];
                float acc[kDirectBlockEntries];
                for (unsigned x = 0; x < kDirectBlockEntries; ++x) acc[x] = 0.f;
                if (present && op.nodeIsland[inode] == id && inode != pinned) {
                    for (unsigned r = op.nodeBondBegin[jnode]; r < op.nodeBondBegin[jnode + 1]; ++r) {
                        const unsigned ref = op.nodeBondRef[r];
                        if (ref == kDeadBondRef) continue;
                        const unsigned edge = ref & 0x7fffffffu;
                        if (op.health[edge] <= 0.f) continue;
                        const bool second = (ref >> 31) != 0u;
                        const unsigned other = second ? op.node0[edge] : op.node1[edge];
                        float mj[kDirectBlockEntries];
                        directBondBlock(mj, second ? op.offset1[edge] : op.offset0[edge], dj, op.colScale[edge], second ? -1.f : 1.f);
                        if (i == j) directAccumulateMMt(acc, mj, mj);
                        else if (other == inode) {
                            float mi[kDirectBlockEntries];
                            directBondBlock(mi, second ? op.offset0[edge] : op.offset1[edge], op.inertia[inode], op.colScale[edge], second ? 1.f : -1.f);
                            directAccumulateMMt(acc, mi, mj);
                        }
                    }
                } else if (i == j) { acc[0] = acc[7] = acc[14] = acc[21] = acc[28] = acc[35] = 1.f; }
                float* dst = val + size_t(q) * kDirectBlockEntries;
                for (unsigned x = 0; x < kDirectBlockEntries; ++x) dst[x] = acc[x];
            }
        }
        __syncthreads();
        // Dense top, step 2: eliminate tail columns in level order. Contributions
        // from bottom columns are gathered (left-looking, few per column);
        // contributions from earlier tail columns already arrived right-looking.
        for (unsigned e = topBegin; e < P.nodes; ++e) {
            const unsigned j = P.levelCols[e], p0 = P.colPtr[j], p1 = P.colPtr[j + 1];
            for (unsigned t = threadIdx.x; t < (p1 - p0) * 6u; t += blockDim.x) {
                const unsigned q = p0 + t / 6u, rr = t % 6u, i = P.rowIdx[q];
                float acc[6] = {0.f, 0.f, 0.f, 0.f, 0.f, 0.f};
                for (unsigned r = P.rowPtr[j]; r < P.rowPtr[j + 1]; ++r) {
                    const unsigned k = P.rowCols[r], q0 = P.rowPos[r];
                    if (P.columnLevel[k] >= T) continue;
                    unsigned lo = q0, hi = P.colPtr[k + 1];
                    while (lo < hi) { const unsigned mid = (lo + hi) >> 1; if (P.rowIdx[mid] < i) lo = mid + 1; else hi = mid; }
                    if (lo >= P.colPtr[k + 1] || P.rowIdx[lo] != i) continue;
                    const float* ljk = val + size_t(q0) * kDirectBlockEntries;
                    const float* lik = val + size_t(lo) * kDirectBlockEntries + rr * 6u;
                    for (unsigned cc = 0; cc < 6; ++cc) {
                        float sum = acc[cc];
                        for (unsigned tt = 0; tt < 6; ++tt) sum = fmaf(lik[tt], ljk[cc * 6 + tt], sum);
                        acc[cc] = sum;
                    }
                }
                float* dst = val + size_t(q) * kDirectBlockEntries + rr * 6u;
                for (unsigned cc = 0; cc < 6; ++cc) dst[cc] -= acc[cc];
            }
            __syncthreads();
            if (threadIdx.x == 0) { if (!directCholesky6(val + size_t(p0) * kDirectBlockEntries)) atomicExch(&failed, 1u); }
            __syncthreads();
            {
                const float* ljj = val + size_t(p0) * kDirectBlockEntries;
                for (unsigned t = threadIdx.x; t < (p1 - p0 - 1u) * 6u; t += blockDim.x) {
                    const unsigned q = p0 + 1u + t / 6u, rr = t % 6u;
                    float* row = val + size_t(q) * kDirectBlockEntries + rr * 6u;
                    for (unsigned cc = 0; cc < 6; ++cc) {
                        float sum = row[cc];
                        for (unsigned tt = 0; tt < cc; ++tt) sum = fmaf(-row[tt], ljj[cc * 6 + tt], sum);
                        row[cc] = sum / ljj[cc * 6 + cc];
                    }
                }
            }
            __syncthreads();
            // Right-looking rank-6 update of every pair of rows (i >= k) below the
            // diagonal: block (i,k) -= L(i,j) L(k,j)^T. Rows are sorted ascending,
            // and (i,k) is in the pattern by the fill rule. One writer per (i,k,row).
            const unsigned n = p1 - p0 - 1u, pairs = n * (n + 1u) / 2u;
            for (unsigned t = threadIdx.x; t < pairs * 6u; t += blockDim.x) {
                const unsigned pair = t / 6u, rr = t % 6u;
                unsigned a = unsigned((sqrtf(8.f * float(pair) + 1.f) - 1.f) * 0.5f);
                while (a * (a + 1u) / 2u > pair) --a;
                while ((a + 1u) * (a + 2u) / 2u <= pair) ++a;
                const unsigned b = pair - a * (a + 1u) / 2u;
                const unsigned qi = p0 + 1u + a, qk = p0 + 1u + b, i = P.rowIdx[qi], k = P.rowIdx[qk];
                unsigned lo = P.colPtr[k], hi = P.colPtr[k + 1];
                if (i != k) { lo = P.colPtr[k] + 1u; while (lo < hi) { const unsigned mid = (lo + hi) >> 1; if (P.rowIdx[mid] < i) lo = mid + 1; else hi = mid; } }
                if (lo >= P.colPtr[k + 1] || P.rowIdx[lo] != i) { atomicExch(&failed, 1u); continue; }
                const float* lij = val + size_t(qi) * kDirectBlockEntries + rr * 6u;
                const float* lkj = val + size_t(qk) * kDirectBlockEntries;
                float* dst = val + size_t(lo) * kDirectBlockEntries + rr * 6u;
                for (unsigned cc = 0; cc < 6; ++cc) {
                    float sum = 0.f;
                    for (unsigned tt = 0; tt < 6; ++tt) sum = fmaf(lij[tt], lkj[cc * 6 + tt], sum);
                    dst[cc] -= sum;
                }
            }
            __syncthreads();
        }
        if (!threadIdx.x) {
            if (failed) { v.slots.slotFailed[s] = 1; v.slots.slotValid[s] = 0; }
            else v.slots.slotValid[s] = 1;
            v.slots.slotStale[s] = 0; v.slots.slotPinned[s] = pinned;
            v.slots.slotGeneration[s] = state->generation;
        }
        __syncthreads();
    }
}
#endif
