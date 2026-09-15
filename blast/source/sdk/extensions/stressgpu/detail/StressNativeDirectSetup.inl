// Private member definitions; included once inside ExtStressGpuSolverImpl.
// Host-side symbolic analysis for the cached direct factorization (R1).
// Runs once when device topology is enabled, from the host topology copies,
// before the resident topology object is constructed. Setup cost is reported
// separately from per-tick solve time.
    NativeDirectView m_direct{};
    std::vector<void*> m_directAllocations;
    template<class T> T* directUpload(const std::vector<T>& host) {
        T* device = nullptr;
        checkCuda(cudaMalloc(&device, std::max(size_t(1), host.size()) * sizeof(T)), "allocate native direct pattern");
        m_directAllocations.push_back(device);
        if (!host.empty()) checkCuda(cudaMemcpy(device, host.data(), host.size() * sizeof(T), cudaMemcpyHostToDevice), "upload native direct pattern");
        return device;
    }
    void releaseNativeDirect() noexcept {
        for (void* p : m_directAllocations) cudaFree(p);
        m_directAllocations.clear();
        m_direct = NativeDirectView{};
    }
    void prepareNativeDirect() {
        if (!nativeDirectEnabled() || m_direct.enabled) return;
        const unsigned n = m_nodeCount, m = m_bondCount;
        if (!n || !m) return;
        const unsigned minNodes = [] { const char* raw = std::getenv("BLAST_GPU_NATIVE_DIRECT_MIN_NODES"); const long v = raw ? std::atol(raw) : long(kDirectMinNodes); return unsigned(std::max(2L, v)); }();
        auto isStatic = [&](unsigned v) { return m_hostInertia[v].angular == 0.f && m_hostInertia[v].linear == 0.f; };
        std::vector<unsigned> parent(n);
        for (unsigned i = 0; i < n; ++i) parent[i] = i;
        auto find = [&](unsigned v) { while (parent[v] != v) { parent[v] = parent[parent[v]]; v = parent[v]; } return v; };
        std::vector<unsigned char> anchoredNode(n, 0);
        for (unsigned b = 0; b < m; ++b) {
            if (m_hostHealth[b] <= 0.f) continue;
            const unsigned u = m_hostNode0[b], v = m_hostNode1[b];
            const bool su = isStatic(u), sv = isStatic(v);
            if (su && sv) continue;
            if (su) { anchoredNode[v] = 1; continue; }
            if (sv) { anchoredNode[u] = 1; continue; }
            const unsigned ru = find(u), rv = find(v);
            if (ru != rv) parent[std::max(ru, rv)] = std::min(ru, rv);
        }
        std::vector<std::vector<unsigned>> members(n);
        std::vector<unsigned char> anchoredRoot(n, 0);
        for (unsigned i = 0; i < n; ++i) {
            if (isStatic(i)) continue;
            const unsigned r = find(i);
            members[r].push_back(i);
            if (anchoredNode[i]) anchoredRoot[r] = 1;
        }
        std::vector<unsigned> nodeParent(n, kNoIsland), nodeLocal(n, 0);
        std::vector<unsigned> patternNodeBegin{0u}, order, patternStructure, structureNodeBegin{0u}, patternColBegin{0u}, colPtr, patternPosBegin{0u}, rowIdx,
            rowPtr, patternRowEntryBegin{0u}, rowCols, rowPos, patternLevelBegin{0u}, patternLevelCount, levelPtr, levelCols, columnLevel, structureTopLevel;
        unsigned patterns = 0, structures = 0, maxBlocks = 0;
        std::vector<unsigned> local(n, kNoIsland);
        // Structurally identical groups (same size, same local edge set under the
        // member-order numbering) share one symbolic structure and one ordering.
        std::map<std::vector<unsigned>, unsigned> structureIndex;
        std::vector<std::vector<unsigned>> structureOrder;
        for (unsigned root = 0; root < n; ++root) {
            const auto& group = members[root];
            const unsigned np = unsigned(group.size());
            // Free groups get patterns too: their solves pin the minimum node.
            if (np < minNodes || np > kResidentComponentMaxNodes) continue;
            for (unsigned i = 0; i < np; ++i) local[group[i]] = i;
            std::vector<std::pair<unsigned, unsigned>> pairs;
            for (unsigned i = 0; i < np; ++i) {
                const unsigned node = group[i];
                for (unsigned r = m_hostNodeBondBegin[node]; r < m_hostNodeBondBegin[node + 1]; ++r) {
                    const unsigned ref = m_hostNodeBondRef[r];
                    if (ref == kDeadBondRef) continue;
                    const unsigned edge = ref & 0x7fffffffu;
                    if (m_hostHealth[edge] <= 0.f) continue;
                    const unsigned other = (ref >> 31) ? m_hostNode0[edge] : m_hostNode1[edge];
                    const unsigned j = local[other];
                    if (j == kNoIsland || j <= i) continue;
                    pairs.push_back({i, j});
                }
            }
            std::sort(pairs.begin(), pairs.end());
            pairs.erase(std::unique(pairs.begin(), pairs.end()), pairs.end());
            std::vector<unsigned> key{np};
            for (const auto& e : pairs) { key.push_back(e.first); key.push_back(e.second); }
            const auto known = structureIndex.find(key);
            if (known != structureIndex.end()) {
                // Reuse the structure; only this instance's node order is new.
                const unsigned sIndex = known->second, p = patterns++;
                const auto& eliminationOrder = structureOrder[sIndex];
                for (unsigned j = 0; j < np; ++j) { const unsigned node = group[eliminationOrder[j]]; order.push_back(node); nodeParent[node] = p; nodeLocal[node] = j; }
                patternNodeBegin.push_back(unsigned(order.size())); patternStructure.push_back(sIndex);
                for (unsigned i = 0; i < np; ++i) local[group[i]] = kNoIsland;
                continue;
            }
            std::vector<unsigned char> adj(size_t(np) * np, 0);
            std::vector<unsigned> degree(np, 0);
            for (unsigned e = 1; e + 1 < key.size(); e += 2) { const unsigned i = key[e], j = key[e + 1]; adj[size_t(i) * np + j] = adj[size_t(j) * np + i] = 1; ++degree[i]; ++degree[j]; }
            // Elimination priority. Minimum degree by default. The optional
            // nested dissection (BLAST_GPU_NATIVE_DIRECT_ORDER=nd) is a recursive
            // level-structure bisection ordering each part before its separator;
            // the numeric refactor is throughput-bound on its single CTA with cost
            // cubic in the dense-top size, so a smaller top separator is the lever.
            // The simple bisection measured worse than minimum degree on the
            // city256 building (see nativeDirectNestedDissection); a real graph
            // partitioner (with refinement) is the next step for this path.
            std::vector<unsigned> priority(np, 0);
            if (nativeDirectNestedDissection()) {
                std::vector<std::vector<unsigned>> graph(np);
                for (unsigned e = 1; e + 1 < key.size(); e += 2) { graph[key[e]].push_back(key[e + 1]); graph[key[e + 1]].push_back(key[e]); }
                unsigned nextRank = 0;
                std::vector<unsigned> mark(np, kNoIsland), dist(np, 0), queue;
                auto bfs = [&](unsigned source, unsigned stamp) {
                    // Returns the farthest node; dist holds levels for nodes with mark == stamp.
                    queue.clear(); queue.push_back(source); mark[source] = stamp; dist[source] = 0; unsigned far = source;
                    for (size_t h = 0; h < queue.size(); ++h) { const unsigned u = queue[h]; if (dist[u] > dist[far]) far = u;
                        for (unsigned w : graph[u]) if (mark[w] == stamp - 1u) { mark[w] = stamp; dist[w] = dist[u] + 1; queue.push_back(w); } }
                    return far;
                };
                unsigned stamp = 0;
                auto dissect = [&](auto& self, const std::vector<unsigned>& part) -> void {
                    if (part.size() <= 12u) { for (unsigned v : part) priority[v] = nextRank++; return; }
                    // Pseudo-peripheral start: two BFS passes inside the part. Every
                    // marking round uses a fresh stamp so no node outside the round
                    // can carry the membership value by coincidence.
                    ++stamp; for (unsigned v : part) mark[v] = stamp; ++stamp;
                    unsigned far = bfs(part[0], stamp);
                    ++stamp; for (unsigned v : part) mark[v] = stamp; ++stamp;
                    far = bfs(far, stamp);
                    const unsigned depth = dist[far];
                    bool reached = true;
                    for (unsigned v : part) reached = reached && mark[v] == stamp && dist[v] <= depth;
                    if (depth < 2u || !reached) { for (unsigned v : part) priority[v] = nextRank++; return; }
                    // Separator: the level whose cumulative count first reaches half.
                    std::vector<unsigned> levelCountLocal(depth + 1, 0);
                    for (unsigned v : part) ++levelCountLocal[dist[v]];
                    unsigned sepLevel = 0, cumulative = 0;
                    for (unsigned l = 0; l <= depth; ++l) { cumulative += levelCountLocal[l]; if (cumulative * 2u >= part.size()) { sepLevel = l; break; } }
                    if (sepLevel == 0u) sepLevel = 1u; if (sepLevel == depth) sepLevel = depth - 1u;
                    std::vector<unsigned> separator, rest;
                    for (unsigned v : part) (dist[v] == sepLevel ? separator : rest).push_back(v);
                    if (rest.empty() || separator.empty()) { for (unsigned v : part) priority[v] = nextRank++; return; }
                    // Connected components of the rest, each dissected recursively.
                    ++stamp; for (unsigned v : rest) mark[v] = stamp; ++stamp;
                    const unsigned restStamp = stamp;
                    std::vector<std::vector<unsigned>> components;
                    for (unsigned v : rest) {
                        if (mark[v] != restStamp - 1u) continue;
                        queue.clear(); queue.push_back(v); mark[v] = restStamp;
                        for (size_t h = 0; h < queue.size(); ++h) for (unsigned w : graph[queue[h]]) if (mark[w] == restStamp - 1u) { mark[w] = restStamp; queue.push_back(w); }
                        components.emplace_back(queue.begin(), queue.end());
                        std::sort(components.back().begin(), components.back().end());
                    }
                    // Progress guard: every child must be strictly smaller than the part.
                    for (const auto& component : components) if (component.size() >= part.size()) { for (unsigned v : part) priority[v] = nextRank++; return; }
                    for (const auto& component : components) self(self, component);
                    for (unsigned v : separator) priority[v] = nextRank++;
                };
                std::vector<unsigned> all(np); for (unsigned i = 0; i < np; ++i) all[i] = i;
                stamp = 1u; dissect(dissect, all);
            } else for (unsigned i = 0; i < np; ++i) priority[i] = degree[i];
            std::vector<unsigned char> eliminated(np, 0);
            std::vector<unsigned> position(np, 0), eliminationOrder(np, 0);
            std::vector<std::vector<unsigned>> structure(np);
            std::vector<unsigned> neighbors;
            const bool dynamicDegree = !nativeDirectNestedDissection();
            for (unsigned step = 0; step < np; ++step) {
                unsigned pick = kNoIsland, best = ~0u;
                for (unsigned i = 0; i < np; ++i) if (!eliminated[i]) { const unsigned key2 = dynamicDegree ? degree[i] : priority[i]; if (key2 < best) { best = key2; pick = i; } }
                neighbors.clear();
                const unsigned char* row = adj.data() + size_t(pick) * np;
                for (unsigned v = 0; v < np; ++v) if (row[v] && !eliminated[v]) neighbors.push_back(v);
                eliminated[pick] = 1; position[pick] = step; eliminationOrder[step] = pick;
                structure[step] = neighbors;
                for (unsigned a = 0; a < neighbors.size(); ++a) {
                    --degree[neighbors[a]];
                    for (unsigned b = a + 1; b < neighbors.size(); ++b) {
                        const unsigned u = neighbors[a], w = neighbors[b];
                        if (!adj[size_t(u) * np + w]) { adj[size_t(u) * np + w] = adj[size_t(w) * np + u] = 1; ++degree[u]; ++degree[w]; }
                    }
                }
            }
            // Column structures in the new order (rows > j), diagonal first.
            std::vector<std::vector<unsigned>> columns(np);
            unsigned blocks = 0;
            for (unsigned j = 0; j < np; ++j) {
                auto& col = columns[j];
                col.push_back(j);
                for (unsigned v : structure[j]) col.push_back(position[v]);
                std::sort(col.begin() + 1, col.end());
                blocks += unsigned(col.size());
            }
            if (blocks > kDirectMaxBlocks) { for (unsigned i = 0; i < np; ++i) local[group[i]] = kNoIsland; continue; }
            // Row structures with positions in the owning column.
            std::vector<std::vector<std::pair<unsigned, unsigned>>> rows(np);
            std::vector<unsigned> columnBase(np + 1, 0);
            for (unsigned j = 0; j < np; ++j) {
                columnBase[j + 1] = columnBase[j] + unsigned(columns[j].size());
                for (unsigned q = 1; q < columns[j].size(); ++q) rows[columns[j][q]].push_back({j, columnBase[j] + q});
            }
            std::vector<unsigned> level(np, 0);
            unsigned levels = 0;
            for (unsigned j = 0; j < np; ++j) {
                unsigned lv = 0;
                for (const auto& e : rows[j]) lv = std::max(lv, level[e.first] + 1);
                level[j] = lv; levels = std::max(levels, lv + 1);
            }
            // A chain-like elimination tree (depth close to the node count) makes
            // the level-synchronous solve slower than the iteration; leave it to PCG.
            if (levels * 2u > np) { for (unsigned i = 0; i < np; ++i) local[group[i]] = kNoIsland; continue; }
            std::vector<unsigned> levelCount(levels + 1, 0);
            for (unsigned j = 0; j < np; ++j) ++levelCount[level[j] + 1];
            for (unsigned l = 0; l < levels; ++l) levelCount[l + 1] += levelCount[l];
            std::vector<unsigned> levelOrder(np), cursor(levelCount.begin(), levelCount.end() - 1);
            for (unsigned j = 0; j < np; ++j) levelOrder[cursor[level[j]]++] = j;
            // Append this instance and its new structure.
            const unsigned p = patterns++, sIndex = structures++;
            structureIndex.emplace(key, sIndex); structureOrder.push_back(eliminationOrder);
            for (unsigned j = 0; j < np; ++j) {
                const unsigned node = group[eliminationOrder[j]];
                order.push_back(node); nodeParent[node] = p; nodeLocal[node] = j;
            }
            patternNodeBegin.push_back(unsigned(order.size())); patternStructure.push_back(sIndex);
            for (unsigned j = 0; j <= np; ++j) colPtr.push_back(columnBase[j]);
            for (unsigned j = 0; j < np; ++j) for (unsigned r : columns[j]) rowIdx.push_back(r);
            patternColBegin.push_back(unsigned(colPtr.size()));
            patternPosBegin.push_back(unsigned(rowIdx.size()));
            unsigned entries = 0;
            for (unsigned j = 0; j < np; ++j) {
                rowPtr.push_back(entries);
                for (const auto& e : rows[j]) { rowCols.push_back(e.first); rowPos.push_back(e.second); ++entries; }
            }
            rowPtr.push_back(entries);
            patternRowEntryBegin.push_back(unsigned(rowCols.size()));
            for (unsigned l = 0; l <= levels; ++l) levelPtr.push_back(levelCount[l]);
            patternLevelBegin.push_back(unsigned(levelPtr.size()));
            patternLevelCount.push_back(levels);
            for (unsigned j : levelOrder) levelCols.push_back(j);
            for (unsigned j = 0; j < np; ++j) columnLevel.push_back(level[j]);
            // First level of the narrow tail: every level from here on has fewer
            // columns than the CTA has warps, so the level-parallel scheme runs
            // them one column at a time anyway.
            unsigned top = levels;
            while (top > 0 && levelCount[top] - levelCount[top - 1] < kBlockSize / 32u) --top;
            structureTopLevel.push_back(top);
            structureNodeBegin.push_back(unsigned(levelCols.size()));
            maxBlocks = std::max(maxBlocks, blocks);
            for (unsigned i = 0; i < np; ++i) local[group[i]] = kNoIsland;
        }
        if (!patterns) return;
        const unsigned stride = ((maxBlocks * kDirectBlockEntries + 31u) / 32u) * 32u;
        unsigned slotCount = std::min(std::max(2u * patterns, 64u), 4096u);
        const size_t budget = nativeDirectSlotBudgetBytes();
        slotCount = unsigned(std::min<size_t>(slotCount, std::max<size_t>(1, budget / (size_t(stride) * sizeof(float)))));
        NativeDirectView view{};
        view.pattern.nodeParent = directUpload(nodeParent); view.pattern.nodeLocal = directUpload(nodeLocal);
        view.pattern.patternNodeBegin = directUpload(patternNodeBegin); view.pattern.order = directUpload(order);
        view.pattern.patternStructure = directUpload(patternStructure); view.pattern.structureNodeBegin = directUpload(structureNodeBegin);
        view.pattern.patternColBegin = directUpload(patternColBegin); view.pattern.colPtr = directUpload(colPtr);
        view.pattern.patternPosBegin = directUpload(patternPosBegin); view.pattern.rowIdx = directUpload(rowIdx);
        view.pattern.rowPtr = directUpload(rowPtr); view.pattern.patternRowEntryBegin = directUpload(patternRowEntryBegin);
        view.pattern.rowCols = directUpload(rowCols); view.pattern.rowPos = directUpload(rowPos);
        view.pattern.patternLevelBegin = directUpload(patternLevelBegin); view.pattern.patternLevelCount = directUpload(patternLevelCount);
        view.pattern.levelPtr = directUpload(levelPtr); view.pattern.levelCols = directUpload(levelCols);
        view.pattern.columnLevel = directUpload(columnLevel); view.pattern.structureTopLevel = directUpload(structureTopLevel);
        std::vector<float> values(size_t(slotCount) * stride, 0.f);
        std::vector<unsigned> slotComponent(slotCount, kNoIsland), componentSlot(n, kNoIsland), zeros(slotCount, 0u);
        std::vector<unsigned long long> generations(slotCount, 0ull);
        view.slots.values = directUpload(values); view.slots.slotComponent = directUpload(slotComponent);
        view.slots.componentSlot = directUpload(componentSlot); view.slots.slotValid = directUpload(zeros);
        view.slots.slotFailed = directUpload(zeros); view.slots.slotGeneration = directUpload(generations);
        view.slots.freeList = directUpload(zeros); view.slots.slotStale = directUpload(zeros); view.slots.slotPinned = directUpload(std::vector<unsigned>(slotCount, kNoIsland));
        view.slots.slotCount = slotCount; view.slots.stride = stride; view.enabled = 1;
        // Woodbury pool (StressNativeWoodbury.cuh): W is 6 np x m floats per
        // buffer; buffers come from BLAST_GPU_NATIVE_WOODBURY_BUDGET_MB.
        view.woodbury = (nativeDirectWoodbury() && !nativeDirectDeferred() && nativeDirectClusterSize() <= 1u) ? 1u : 0u;
        if (view.woodbury) {
            unsigned maxNodes = 0;
            for (unsigned p = 0; p < patterns; ++p) maxNodes = std::max(maxNodes, patternNodeBegin[p + 1] - patternNodeBegin[p]);
            const unsigned wStride = ((6u * maxNodes * kWoodburyMaxColumns + 31u) / 32u) * 32u;
            const size_t perBuffer = size_t(wStride) * sizeof(float) + size_t(kWoodburyCapFloats) * sizeof(float);
            const unsigned buffers = unsigned(std::min<size_t>(slotCount, std::max<size_t>(1, nativeWoodburyBudgetBytes() / perBuffer)));
            view.slots.slotRemovedCount = directUpload(zeros); view.slots.slotRemoved = directUpload(std::vector<unsigned>(size_t(slotCount) * kWoodburyMaxBonds, 0u));
            view.slots.slotPresent = directUpload(std::vector<unsigned>(size_t(slotCount) * kWoodburyPresentWords, 0u));
            view.slots.slotWoodbury = directUpload(zeros); view.slots.slotWoodburyBuffer = directUpload(std::vector<unsigned>(slotCount, kNoIsland));
            view.slots.woodburyPool = directUpload(std::vector<float>(size_t(buffers) * wStride, 0.f));
            view.slots.woodburyCap = directUpload(std::vector<float>(size_t(buffers) * kWoodburyCapFloats, 0.f));
            view.slots.woodburyOwner = directUpload(std::vector<unsigned>(buffers, kNoIsland)); view.slots.woodburyFree = directUpload(std::vector<unsigned>(buffers, 0u));
            view.slots.woodburyBuffers = buffers; view.slots.woodburyStride = wStride;
            if (std::getenv("BLAST_GPU_NATIVE_DIRECT_DIAG"))
                std::fprintf(stderr, "native direct woodbury: buffers=%u stride=%u floats maxNodes=%u maxBonds=%u\n", buffers, wStride, maxNodes, kWoodburyMaxBonds);
        }
        view.counters = directUpload(std::vector<unsigned>(kDirectCounterCount, 0u));
        view.diagnostics = std::getenv("BLAST_GPU_NATIVE_DIRECT_DIAG") ? std::max(1u, unsigned(std::atoi(std::getenv("BLAST_GPU_NATIVE_DIRECT_DIAG")))) : 0u;
        view.minNodes = minNodes;
        view.deferred = nativeDirectDeferred() ? 1u : 0u;
        view.rightLooking = nativeDirectRightLooking() ? 1u : 0u;
        if (view.diagnostics) {
            // Level structure of the largest pattern: the refactor and solve
            // critical path is the level count, and the dense top of the
            // elimination tree (levels with fewer columns than warps) runs one
            // column per CTA step.
            // Level data is stored per shared structure (patternStructure maps instances to it).
            unsigned worst = 0;
            for (unsigned s = 0; s < structures; ++s) if (patternLevelCount[s] > patternLevelCount[worst]) worst = s;
            const unsigned lv = patternLevelCount[worst], lb = patternLevelBegin[worst], cb = patternColBegin[worst], ce = patternColBegin[worst + 1];
            const unsigned np = ce > cb ? ce - cb - 1u : 0u, blocksTotal = ce > cb ? colPtr[ce - 1u] : 0u;
            unsigned narrow = 0, narrowColumns = 0;
            for (unsigned l = 0; l < lv; ++l) { const unsigned w = levelPtr[lb + l + 1] - levelPtr[lb + l]; if (w < kBlockSize / 32u) { ++narrow; narrowColumns += w; } }
            std::fprintf(stderr, "native direct patterns: instances=%u structures=%u maxBlocks=%u deepest structure: nodes=%u levels=%u blocks=%u narrowLevels=%u narrowColumns=%u topLevel=%u rightLooking=%u\n",
                patterns, structures, maxBlocks, np, lv, blocksTotal, narrow, narrowColumns, structureTopLevel[worst], view.rightLooking);
        }
        m_direct = view;
        m_directPatternCount = patterns; m_directStructureCount = structures; m_directMaxBlocks = maxBlocks;
    }
    unsigned m_directPatternCount = 0, m_directStructureCount = 0, m_directMaxBlocks = 0;
    // Claim slots for eligible components and refactor every invalid or stale
    // slot. Launched before the solve in the original schedule, after the
    // solve's completion event in deferred mode, and once at setup.
    void launchNativeDirectFactor() {
        if (!m_direct.enabled || !m_deviceTopology) return;
        const auto components = m_deviceTopology->components();
        const auto view = m_deviceTopology->cycleView();
        if (!m_directGrid) {
            int device = 0, sms = 0;
            checkCuda(cudaGetDevice(&device), "prefactor device");
            checkCuda(cudaDeviceGetAttribute(&sms, cudaDevAttrMultiProcessorCount, device), "prefactor multiprocessors");
            m_directGrid = std::min(m_nodeCount, unsigned(std::max(1, sms)) * nativeFactorBlocksPerSm());
        }
        const NativeDirectOperator op{m_node0, m_node1, m_nodeBondBegin, m_nodeBondRef, m_nodeIsland, m_offset0, m_offset1, m_inertia, m_health, m_colScales};
        assignNativeDirectSlots<<<1, kBlockSize, 0, m_stream>>>(m_direct, components, view.modes.components, m_deviceTopology->status());
        if (m_directClusterSize == ~0u) {
            // Probe once: a cluster of BLAST_GPU_NATIVE_DIRECT_CLUSTER CTAs per
            // component (default 8, 0 disables) if the device and kernel allow it.
            m_directClusterSize = 0;
            const unsigned wanted = nativeDirectClusterSize();
            if (wanted > 1) {
                cudaLaunchConfig_t cfg = {};
                cfg.gridDim = dim3(wanted); cfg.blockDim = dim3(kBlockSize); cfg.dynamicSmemBytes = 0; cfg.stream = m_stream;
                cudaLaunchAttribute attr = {};
                attr.id = cudaLaunchAttributeClusterDimension; attr.val.clusterDim.x = wanted; attr.val.clusterDim.y = 1; attr.val.clusterDim.z = 1;
                cfg.attrs = &attr; cfg.numAttrs = 1;
                int maxClusters = 0;
                if (cudaOccupancyMaxActiveClusters(&maxClusters, (void*)factorNativeDirectCluster, &cfg) == cudaSuccess && maxClusters > 0)
                    m_directClusterSize = wanted;
                cudaGetLastError();
            }
        }
        if (m_directClusterSize > 1) {
            const unsigned clusters = std::max(1u, std::min(m_nodeCount, m_directGrid / m_directClusterSize));
            cudaLaunchConfig_t cfg = {};
            cfg.gridDim = dim3(clusters * m_directClusterSize); cfg.blockDim = dim3(kBlockSize); cfg.dynamicSmemBytes = 0; cfg.stream = m_stream;
            cudaLaunchAttribute attr = {};
            attr.id = cudaLaunchAttributeClusterDimension; attr.val.clusterDim.x = m_directClusterSize; attr.val.clusterDim.y = 1; attr.val.clusterDim.z = 1;
            cfg.attrs = &attr; cfg.numAttrs = 1;
            checkCuda(cudaLaunchKernelEx(&cfg, factorNativeDirectCluster, m_direct, op, components, view.modes.components, m_deviceTopology->status()), "native direct cluster factor launch");
        } else
            factorNativeDirect<<<m_directGrid, kBlockSize, 0, m_stream>>>(m_direct, op, components, view.modes.components, m_deviceTopology->status());
        checkCuda(cudaGetLastError(), "native direct factor launch");
    }
    unsigned m_directGrid = 0, m_directClusterSize = ~0u;
    void prefactorNativeDirect() {
        if (!m_direct.enabled || !m_deviceTopology) return;
        launchNativeDirectFactor();
        checkCuda(cudaStreamSynchronize(m_stream), "prefactor native direct");
    }
