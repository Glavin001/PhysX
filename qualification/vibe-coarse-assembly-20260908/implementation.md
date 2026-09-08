# GPU coarse hierarchy changes — short qualification

The added destruction solver is changed; NVIDIA rigid-body algorithms and physical settings are retained.

- ✅ Coarse terminal/smoother coefficients use warp-parallel FP64 reductions; deep rows use eight CTA tiles with the same local/cooperative reduction tree.
- ✅ Deep restriction enumerates unique aggregate ownership rather than duplicate bond references.
- ✅ Coarse self columns are contracted into persistent 3×3 angular matrices. Their nonzero rounded moment response is preserved, including the parent/child correction tensor. No self bond is discarded from physical equations. The cache covers resolved coarse levels up to 4,096 nodes.
- ✅ Coarsening scans compact non-self adjacency after validating every original reference. Original CSR degrees still determine seed priority, preserving the integer aggregation policy.
- ✅ Large cooperative stress launch size reflects its eight-lane row work; legal occupancy is queried. Two-block launch bounds reduce compiled registers from 191 to 128, with increased stack usage recorded.
- ✅ The fine inverse builder receives only its required pointers and scalar indices. An inlined generation test avoids calls on valid cache entries. Component stack storage falls from 528 to 48 bytes; no additional whole-step timing win is established.
- ❌ Smaller coarse row groups regressed sustained time and were reverted; their parallel Boolean support scan was retained.
- ❌ Grid-constant parameter annotations did not establish a gain and regressed the 256-building screen. They were reverted. Rejected patches and measurements remain separate from production.

## Results and limits

The generated [downtown report](report.md) includes every candidate, first step and later spike. The final narrow-call candidate uses 27 structures, 24,105 chunks, 74,543 bonds and three recorded shots over 600 steps / 10 simulated seconds. Complete destruction/aftermath peak changes from 719.880 to 130.319 ms. The candidate's all-step peak is 199.904 ms at startup. Intact idle has zero fracture throughout; median and startup remain separately visible. These are short single-run screens, not five-trial or endurance qualification.

The [256-building destruction control](256-shots/report.md) and [pristine idle control](256-idle/report.md) expose that the downtown changes do not establish a general scale win. The baseline has 113,664 chunks / 229,376 bonds, 768 rounds, complete peak 151.087 ms and loaded peak 135.994 ms; candidate runs remain above the real-time deadline. Neither historical external-backend superiority nor strict 60 Hz is established. Small chaotic-run differences must not be promoted to reliable gains.

The exact frozen 444-chunk / 896-bond wall passes: one projectile, 398 retained chunks, 46 detached, 199 broken bonds, unchanged topology signature and projectile clearance. Resident analytic, 3D and motion tests pass. The resident-grid runtime also passes all eight ordinary-scene sleep/wake/report/query tests. Receipts state which artifact each test exercised; the newest ordinary/browser deployment receipt is added separately.

The initial ordinary-scene wall audit was mistakenly invoked against the Direct-GPU golden. Its failure was retained. The original unmodified runtime also fails that differently configured golden; this is not a waived frozen assertion. Exact frozen configuration passes, and ordinary mode has its own lifecycle tests. Controlled tests pass; chaotic city trajectories are not bit-identical.

The frozen-wall runner now verifies actually mapped runtime libraries instead of assuming LD_LIBRARY_PATH selected the production path. Older receipts that predate this change must not use the runner's assumed production hash as proof of a candidate library; the separate candidate hashes and newer mapped-library audits are retained.

## Remaining measured work

Node-level CUDA tracing of the new runtime attributes 95.8% of aggregate kernel duration in the downtown replay to the large resident solver, and 81.4% in the 256-building replay to the small-component solver. These are separate intrusive profiles, not additive partitions of complete-step peaks or hardware-counter utilization. CUDA graph nodes must be traced explicitly; the first graph-level trace omitted their internal kernels and is not used for these percentages.

The external-library reference attempt is [not a valid matching-quality comparison](external-reference/README.md): it breaks the untouched city under this test configuration. Its timings cannot certify superiority. Full performance/architecture/endurance goals remain open, including component-local storage, validated structural reuse, GPU lifecycle ownership and correction scheduling.
