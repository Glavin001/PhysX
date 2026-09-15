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
        std::vector<unsigned> patternNodeBegin{0u}, order, patternColBegin{0u}, colPtr, patternPosBegin{0u}, rowIdx,
            rowPtr, patternRowEntryBegin{0u}, rowCols, rowPos, patternLevelBegin{0u}, patternLevelCount, levelPtr, levelCols;
        unsigned patterns = 0, maxBlocks = 0;
        std::vector<unsigned> local(n, kNoIsland);
        for (unsigned root = 0; root < n; ++root) {
            const auto& group = members[root];
            const unsigned np = unsigned(group.size());
            // Free groups get patterns too: their solves pin the minimum node.
            if (np < kDirectMinNodes || np > kResidentComponentMaxNodes) continue;
            for (unsigned i = 0; i < np; ++i) local[group[i]] = i;
            std::vector<unsigned char> adj(size_t(np) * np, 0);
            std::vector<unsigned> degree(np, 0);
            for (unsigned i = 0; i < np; ++i) {
                const unsigned node = group[i];
                for (unsigned r = m_hostNodeBondBegin[node]; r < m_hostNodeBondBegin[node + 1]; ++r) {
                    const unsigned ref = m_hostNodeBondRef[r];
                    if (ref == kDeadBondRef) continue;
                    const unsigned edge = ref & 0x7fffffffu;
                    if (m_hostHealth[edge] <= 0.f) continue;
                    const unsigned other = (ref >> 31) ? m_hostNode0[edge] : m_hostNode1[edge];
                    const unsigned j = local[other];
                    if (j == kNoIsland || j == i) continue;
                    if (!adj[size_t(i) * np + j]) { adj[size_t(i) * np + j] = adj[size_t(j) * np + i] = 1; ++degree[i]; ++degree[j]; }
                }
            }
            // Minimum-degree elimination; column structures are the neighbors at elimination time.
            std::vector<unsigned char> eliminated(np, 0);
            std::vector<unsigned> position(np, 0), eliminationOrder(np, 0);
            std::vector<std::vector<unsigned>> structure(np);
            std::vector<unsigned> neighbors;
            for (unsigned step = 0; step < np; ++step) {
                unsigned pick = kNoIsland, best = ~0u;
                for (unsigned i = 0; i < np; ++i) if (!eliminated[i] && degree[i] < best) { best = degree[i]; pick = i; }
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
            std::vector<unsigned> levelCount(levels + 1, 0);
            for (unsigned j = 0; j < np; ++j) ++levelCount[level[j] + 1];
            for (unsigned l = 0; l < levels; ++l) levelCount[l + 1] += levelCount[l];
            std::vector<unsigned> levelOrder(np), cursor(levelCount.begin(), levelCount.end() - 1);
            for (unsigned j = 0; j < np; ++j) levelOrder[cursor[level[j]]++] = j;
            // Append this pattern.
            const unsigned p = patterns++;
            for (unsigned j = 0; j < np; ++j) {
                const unsigned node = group[eliminationOrder[j]];
                order.push_back(node); nodeParent[node] = p; nodeLocal[node] = j;
            }
            patternNodeBegin.push_back(unsigned(order.size()));
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
        view.pattern.patternColBegin = directUpload(patternColBegin); view.pattern.colPtr = directUpload(colPtr);
        view.pattern.patternPosBegin = directUpload(patternPosBegin); view.pattern.rowIdx = directUpload(rowIdx);
        view.pattern.rowPtr = directUpload(rowPtr); view.pattern.patternRowEntryBegin = directUpload(patternRowEntryBegin);
        view.pattern.rowCols = directUpload(rowCols); view.pattern.rowPos = directUpload(rowPos);
        view.pattern.patternLevelBegin = directUpload(patternLevelBegin); view.pattern.patternLevelCount = directUpload(patternLevelCount);
        view.pattern.levelPtr = directUpload(levelPtr); view.pattern.levelCols = directUpload(levelCols);
        std::vector<float> values(size_t(slotCount) * stride, 0.f);
        std::vector<unsigned> slotComponent(slotCount, kNoIsland), componentSlot(n, kNoIsland), zeros(slotCount, 0u);
        std::vector<unsigned long long> generations(slotCount, 0ull);
        view.slots.values = directUpload(values); view.slots.slotComponent = directUpload(slotComponent);
        view.slots.componentSlot = directUpload(componentSlot); view.slots.slotValid = directUpload(zeros);
        view.slots.slotFailed = directUpload(zeros); view.slots.slotGeneration = directUpload(generations);
        view.slots.slotCount = slotCount; view.slots.stride = stride; view.enabled = 1;
        view.counters = directUpload(std::vector<unsigned>(kDirectCounterCount, 0u));
        view.diagnostics = std::getenv("BLAST_GPU_NATIVE_DIRECT_DIAG") ? 1u : 0u;
        m_direct = view;
        m_directPatternCount = patterns; m_directMaxBlocks = maxBlocks;
    }
    unsigned m_directPatternCount = 0, m_directMaxBlocks = 0;
