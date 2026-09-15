# Destruction test coverage: strong regression protection, incomplete physical acceptance

Published **2026-09-13**. This is a source/registration audit with bounded CPU checker tests, not a new GPU qualification or a line/branch coverage measurement.

**We have meaningful automated tests, but I would not yet call the suite sufficient to approve arbitrary solver or architecture changes.** It is strong at catching broken ownership, correction ordering, cache invalidation, material transactions and repeatability. It is less complete at independently proving physical quality over long trajectories. Some cross-build gates also require the old internal representation or arithmetic results, which can reject a physically valid improvement.

The remedy is to separate **physical acceptance**, **strict regression comparisons**, and **implementation-specific tests**. Keep the latter two useful and visible; do not let them substitute for independent physical acceptance or silently waive their failures.

No runtime or existing test assertions were changed in this audit. The current optimization candidates are not newly qualified by this report.

## What was audited

The [source inventory](source-inventory.csv) catalogs **318 source/helper files** across the custom destruction test trees, with source hashes, assertion/declaration locations and Rust feature guards. The [assertion index](assertion-index.json) makes the cross-cutting review reproducible. Counts include helpers, prototypes and diagnostics, not just executable tests. Native acceptance/checker paths received detailed contract review; legacy families received assertion and registration review with representative behavioral tests inspected in detail. This is not a claim of formal verification of every line.

The configured `out/destruction-sdk` build exposes **174 CTest entries**: **65 labeled and 65 marked RUN_SERIAL**. Variants, sanitizer invocations and legacy adapters contribute to that total. Only some entries use the ordinary API/sleeping mode required for the current application. The [CTest inventory](ctest-inventory.json) records exact commands and properties; it does not prove that the built executables match today's modified worktree.

The source cohort is a modified worktree at HEAD `1155b7ffb60d4d65853f448b00485c21cfd06b99`; use the per-file hashes, not HEAD alone, to identify reviewed code. Isolated experiment sources under `out/` are not silently counted as main-tree coverage. N24 and N29b qualification records are referenced separately below. Generic upstream PhysX/Blast/Omniverse tests are outside this custom-destruction audit. No Momentic integration or hosted workflow was found in the inspected configuration; existing browser coverage uses Playwright/Vitest on the JS bridge. Those browser tests do not exercise the native embedded GPU destruction path.

## Findings, in priority order

### 1. Long-run acceptance does not observe the complete rigid-body motion state

**Confirmed source finding and synthetic checker challenge.** The [continuous wall verifier](../../tools/scripts/verify-native-prefix.py) compares chunk physics/COM positions, projectile positions and exact fracture/identity history over 32/128/600 steps. Its motion CSV comparison does not compare orientations, linear velocities or angular velocities. The [TWSTATE reader](../../tools/scripts/analyze-native-motion.py) reads seven pose floats but retains only projectile XYZ.

Changing a synthetic projectile quaternion to a valid 90-degree rotation, while retaining identical positions, still passes the 32-step checker. This demonstrates an unobserved field, not an actual physics regression; projectile rotation can itself be physically irrelevant for a sphere. The more consequential source-level gap is the lack of orientation and velocity history comparisons for rotating fragments. The same comparison loop is used for the full wall; the full tier adds penetration checks, not these missing state comparisons.

The [snapshot checker](../../tools/diagnostics/destruction-snapshot/compare-observations.py) does compare pose and both velocities for observed moving objects, and native tests check point-velocity transfer. Thus the gap is **long-run coverage**, not total absence of rotation/velocity tests.

**Recommended change:** record accepted body/shape orientation and linear/angular velocity through continuous runs; compare them with declared physical tolerances and quaternion sign equivalence. Add zero-input rigid motion, offset-COM rotating fragments, repeated fracture and sleep/wake trajectories. Validate conservation of momentum and the appropriate energy/work balance in controlled scenes; do not require energy conservation when gravity, friction, restitution or destruction dissipation changes it.

### 2. The main cross-build checker mixes physical state with implementation identity

**Confirmed.** [compare-observations.py](../../tools/diagnostics/destruction-snapshot/compare-observations.py) requires entire observation manifests to match, including generations and array layout. It compares all arrays except derived bond forces byte-for-byte. It also requires matching island/work/contact counts and cluster labels. Repetitions are not independently high-precision physics references; the cross-build observation comparison uses observation/sample zero, while the native repeatability checks cover repeated material/topology/motion outputs.

The [checker challenges](checker-challenges.json) confirm that changing only a topology generation is rejected, and that a one-ULP surface-load difference is rejected. Bond-force roundoff within the existing bound is accepted; larger force and motion changes are rejected. Iteration counts are **not** required to match by this checker; they are recorded separately.

Some exactness is appropriate: identical saved inputs, broken/live bonds under an unchanged material policy, no missing chunks, public handle lifetime safety, and no damage applied twice. But identical internal roots, generation values, packed layouts, contact manifold counts and reduction bits are not automatically the physical contract for a different implementation. Conversely, damage differences must not be dismissed as harmless floating-point noise: accumulated health determines future fractures.

**Recommended change:** retain a strict regression mode, and add a separately qualified physical mode. Match chunks by stable authored identity, compare canonical connectivity partitions rather than internal root numbers, recompute material outcomes and validate motion. Keep different generations/contact counts as diagnostics. Changes to numerical/material tolerances need independent evidence and an explicit contract revision; this audit does not authorize a blanket tolerance increase.

### 3. Independent numerical tests exist, but the large native material-quality oracle is incomplete

**Strong existing coverage:** the [resident 3D test](../../demos/blast-stress-demo/tests/gpu_resident_stress_3d_test.cpp) uses an independent long-double CGLS reference and compares all six force channels, alongside analytic and CPU-parity tests. Hierarchy tests check independently assembled operators, symmetry, energy, forward error and dense cycle results. They are substantially better than simply comparing the implementation with itself.

**Important limit:** the 3D test's recomputed published-gradient audit prints gradient/threshold values; that audit function does not assert them. The test does assert native convergence status and force agreement. The [large native solution auditor](../../tools/scripts/audit-native-stress-solution.py) deliberately reports `audit_complete_not_quality_qualification`; it is diagnostic, not a complete material acceptance gate.

Historical evidence shows why baseline parity cannot be the only oracle. The [N24 independent equation audit](../../qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n24-equation-audit.md) independently solved 50 anchored systems from one city25 impact input, covering first and correction stress passes. Both approximate arms failed the old per-coordinate comparison against that reference, despite small global relative force norms. This does **not** establish that either simulation's destruction behavior is unacceptable, nor justify ignoring weak-bond errors. It establishes that the baseline's coordinate values are not ground truth. Large free-component generalization was not established.

**Recommended change:** make independent equilibrium/gradient and material-margin checks an acceptance layer on captured native systems, including anchored and free components, long chains and dense loops. Check the actual rounded forces consumed by damage, support/nullspace constraints, elastic/fatal boundaries, timestep-dependent health and resulting connectivity. Include bonds near thresholds so a small global error cannot hide a decisive local error. Numerical budgets should follow these outcomes, not require a particular preconditioner, recurrence or iteration count.

### 4. Good behavioral tests on older paths do not automatically protect the embedded runtime

The native material test already covers damage, tension/compression, timestep effects, no double application on retry and a rotating candidate's momentum/energy. However, its candidate preparation checks are not a comprehensive accepted collision-plus-correction energy audit.

The adapter/Rust/TypeScript suites contain valuable additional tests: heterogeneous materials, weakest links, supported stability, progressive impact damage, fragment momentum, arbitrary COM offsets, property-based split coverage and same-frame wake after settled reuse. Some are feature gated, some use Rapier/older PhysX adapters, and nine six-channel CUDA CTests target a separate backend. These cannot all be credited to the active native implementation.

**Recommended change:** port the *behavioral specifications* to ordinary native scenes, not the old algorithms or goldens. Prioritize global rigid-transform invariance with gravity/stimuli transformed consistently; equivalent chunk/bond permutations with canonical output partitions; disjoint-island independence; supported versus free motion; safe settled reuse under changed loads, support, topology, commands and material state; and cumulative near-threshold damage while equilibrium is unchanged. Some ingredients already have unit coverage—what is missing is a coherent native end-to-end acceptance matrix.

### 5. Several implementation checks should be scoped rather than deleted

| Existing check | Value | Correct scope |
|---|---|---|
| Hierarchy diagonal/sparse-row `memcmp` in [operator checks](../../demos/blast-stress-demo/tests/gpu_resident_hierarchy_operator_checks.cuh) | Detects an unintended arithmetic/order change | Exact-arithmetic experiment diagnostic; independent residual/forward-error tests decide numerical quality for a changed algorithm |
| Exactly 62 graph builds in [native resimulation test](../../demos/blast-stress-demo/tests/native_gpu_resimulation_test.cpp) | Confirms one particular graph execution strategy | Separate mechanism/performance assertion from penetration, freshness and correction acceptance |
| Exact free-list order, root labels, generation/rebuild counts | Detects mistakes in the current allocator/topology implementation | Keep for that implementation; preserve external identity/lifetime and canonical connectivity contracts across replacements |
| Bitwise no-mutation on rejected transactions | Protects atomicity and prevents partial publication | Keep as a strong correctness requirement for externally observable accepted state |
| Exact-input cache invalidation, including one-ULP changes | Prevents unsafe reuse under the current exact-match policy | Keep for exact reuse; an approximate reuse design needs a separate physical error contract |
| `max_motion_position_error == 0` in [consumer](../../demos/blast-stress-demo/tests/native_gpu_consumer_test.py) and [bombardment](../../demos/blast-stress-demo/tests/native_bombardment_contacts_test.py) wrappers | Very sensitive renderer/physics agreement check | Separate exact identity/ownership from geometric agreement; reconcile with existing native motion tolerances, with rotation and velocity coverage before loosening |
| Printed depth/divergence probe | Useful diagnosis | Do not count it as a pass/fail oracle: [solver_divergence_test.cpp](../../demos/blast-stress-demo/tests/solver_divergence_test.cpp) explicitly says it is diagnostic and has no CTest registration |

### 6. Automation is fragmented, and one CPU unit test depends on the live benchmark lock

**Observed in this audit:** 101 CPU test methods were attempted across nine scripts: **100 passed and one errored**. The failure in [test-destruction-ab.py](../../tools/scripts/test-destruction-ab.py) is its mocked foreign-GPU admission test attempting to acquire the actual `out/destruction-ab.lock`, which was held. It raises `BlockingIOError` before reaching the assertion. This is a non-isolated unit-test fixture, not a detected physics failure. The lock was not removed or bypassed, and the original failure is [preserved](test-destruction-ab.log).

**Recommended change:** use a private temporary lock for this unit test and separately test lock contention. Preserve the production exclusion lock. Run all checker tests without contacting the GPU or depending on an active optimization campaign.

CTest labels/serial properties are incomplete: **109 of 174 configured entries lack RUN_SERIAL; 109 lack labels; 108 lack both**, including GPU-consuming entries. The documented `-j1` avoids intra-CTest overlap, but labels alone cannot currently select every GPU test. CTest also cannot coordinate with independent benchmark processes without a shared external lock. Full52 snapshots, asynchronous memory checks, the continuous wall and isolated candidate oracles are additional scripted gates, not one universal CTest result. No hosted CI workflow was discovered in `.github/`.

**Recommended change:** one serial candidate-qualification entrypoint, with explicit expected test names/counts and receipts bound to the exact binaries, libraries, settings and inputs. Keep tiers distinct: CPU/checker, native focused numerical/material/causality, GPU sanitizers, light snapshots, full52, continuous trajectories, then unprofiled performance. Missing GPU, skipped tests, missing feature flags and missing artifacts must be visible as unqualified—not a green physical result. Preserve failures and avoid silently matching an obsolete test name in a broad CTest regex.

## Coverage map and disposition

This table is a contract assessment, not a fresh pass/fail result. The inventory enumerates all discovered sources in each family.

| Family / source | What it protects | Assessment and action |
|---|---|---|
| [Native resimulation/correction](../../demos/blast-stress-demo/tests/native_gpu_resimulation_test.cpp), correction-body and post-correction helpers | Current contacts, fracture response, ≤1 correction, second stress, command preservation, ancestor/lifetime validity | Strong; retain behavior, separate graph-build mechanism checks |
| Native command inputs/baseline/motion/wake | Exactly-once forces/impulses; rejected input cannot mutate state; correct velocity and wake timing | Strong; retain public semantics through CPU/GPU relocation |
| Native material and accepted properties | Thresholds, damage, crush, mass/inertia, candidate momentum/energy | Meaningful; extend accepted multi-tick material/energy cases |
| Standard-scene, compound-sleep, boundary/late-impact and kinematic tests | Ordinary API, sleep, wake, support and fresh contact response | Directly relevant; keep enabled for current mode |
| Native collision, pairs, graph, ownership, allocation and publication | Valid contacts, no stale handles, unique ownership, capacities, failure atomicity, shape/query publication | Strong safety coverage; canonicalize internal identities only at cross-implementation boundary |
| [Runtime GPU body/topology/contact tests](../../physx/source/gpudestruction/tests) | Independent flood-fill connectivity; randomized rotated inertia/COM; invalid/growing topology; lifetime exhaustion; transactional deltas | Strong local oracles, including 100k-node graph workloads and 4096 randomized body cases; not a substitute for full dynamics |
| Resident analytic/3D/parity/motion tests | Force equations, supported/free modes, changing load and topology | Strong numerical foundation; enforce independent native material-quality acceptance as above |
| Hierarchy/operator/cycle/normalization helpers | Matrix correctness, preconditioner application, schedules, live ranges, memory safety | Keep per-algorithm; do not mandate that every future solver has this hierarchy |
| Settled/history/unaffected-warm reuse helpers | Changed loads/tolerances/topology invalidate reuse; unconverged outputs never cached | Particularly valuable for removal-first optimization; extend native cumulative-damage scenarios |
| [Snapshot probe/replay](../../tools/diagnostics/destruction-snapshot/serialization-probe.cpp) and `.inl` helpers | Physical export/import, corrupt input rejection, command replay, no healing, finite state, pose/velocity repeatability, one full accepted tick | Strong codec/replay coverage; cross-build physical equivalence needs a representation-independent layer |
| Full52 and light scenario scripts | Semantic/scale breadth with frozen inputs; restore excluded; correction included | Excellent regression/performance corpus; not 52 independent physical truth oracles |
| Continuous wall/penetration | Long fracture trajectory, rear clearance/hole, motion/COM and supported wall quality | Valuable but narrow (444 chunks, one projectile); add full motion state and large/multi-impact trajectories |
| Legacy C++ adapter material/crush/quality/load-path/resim | Behavioral material response, load redistribution, multi-structure correction and energy-related outcomes | Reuse specifications on native path; keep adapter compatibility separate |
| [Stress extension tests](../../blast/source/sdk/extensions/stressgpu/test) | Stress formula and settled skip plus nine separate six-channel backend tests | Distinguish existing adapter from prototype; neither count alone qualifies native end-to-end behavior |
| [Rust solver tests](../../blast/blast-stress-solver-rs/tests), demo and embedded modules | FFI, ID layout, scenes, split continuity, momentum, structural invariants, backend parity and damage | Useful, often feature gated; publish enabled-feature matrix before calling them run |
| [TypeScript/WASM/Rapier tests](../../blast/blast-stress-solver/src/tests) | Analytic stress, boundary laws, property-based split/motion, authoring, island skip, damage and recording | Good source of outcome specifications; not the native CUDA execution path |
| JS bridge specs / [Playwright stress test](../../blast/js_stress_example/tests/stress.spec.js) | Bridge events, bindings and browser integration | Useful product smoke coverage; does not measure native physical fidelity |
| [Package consumer](../../tests/destruction/package-consumer) | Installed SDK/API smoke and small configured stress graph | Packaging contract; not broad destruction quality |
| [Archived game reference](../../tests/destruction/game-reference) / CUDA graph contexts repro | Historical fixtures/contracts / graph-context diagnostics | Not current standalone acceptance; do not count archived sources as executed tests |
| Python checker/report/profile tests | Reject missing/mismatched artifacts, wrong units, partial timings, bad physical observations and incomplete coverage | Valuable measurement integrity; one fixture-isolation failure found; these do not simulate physics |

## Scenario breadth and remaining semantic holes

The existing [28 structural states](../../tools/profiles/destruction-snapshot-suite.json) include bridge, cantilever, short/long chain, dense connectivity, buildings, ladder, panels, towers and small destruction/free-flight/contact fixtures. The [24 city states](../../tools/profiles/destruction-snapshot-large.json) span 25/64/256 buildings (**11,100 / 28,416 / 113,664 chunks**) at eight stages:

| City stage at each of three scales | Signal already covered | Additional correctness signal needed |
|---|---|---|
| Intact idle | Gravity equilibrium and intact topology | Independent load-bearing stress/material margins; settled damage invariance |
| Airborne | Commands/projectile approach | Momentum and no premature stimulus transfer |
| Initial impact | First fracture, correction, second stress | Contact-to-fracture causal test; independent threshold decisions |
| Post-impact | New ownership and post-fracture state | Full fragment rotational/velocity continuity |
| Cascading fracture | Repeated load redistribution | No lost/duplicated impulse or damage across corrections |
| Fragmented loaded | Many components and remaining load paths | Large free/anchored equilibrium and material reference |
| Late debris | Collision-heavy mixed fragments | Cumulative energy/work, support loss and wake behavior |
| Ten-second debris | Late post-destruction state | Longer motion drift; do not assume the saved scene is asleep |

All 52 are retained in the test strategy. A restored one-tick case does not validate continuous history by itself, and 20 repeats improve repeatability/timing evidence rather than create 20 independent physical oracles. Current large-city fixtures repeat a common building design; raw chunk scale alone does not cover every topology, conditioning, material mix or aspect ratio. Preserve the smaller semantic fixtures while adding independent native metamorphic and trajectory cases.

## Validation performed for this audit

[CPU test receipts](cpu-tests.json) and logs preserve **101 attempted methods: 100 passed, one errored**. Eight scripts passed completely: observation comparison (10), matched orchestration (1), attribution (16), continuous prefix (16), independent solution auditor (4), timing accounting (37), semantic suite (8), publication reporting (4). A/B provenance/admission passed four of five, with the real-lock fixture error described above. No C++/CUDA rebuild, GPU simulation, sanitizer or browser suite was run for this audit.

Seven additional [synthetic checker challenges](checker-challenges.json) behaved as predicted. They demonstrate checker sensitivity and blind spots; they are not production mutation coverage and not seven new physical scenarios. No application timing or speedup is reported.

Reproduce discovery and the bounded challenges from the repository root:

```bash
.toolchains/build-env/bin/ctest --test-dir out/destruction-sdk --show-only=json-v1 > /tmp/destruction-ctest-inventory.json
python3 reports/destruction-test-coverage-audit/inventory.py --ctest-json /tmp/destruction-ctest-inventory.json
OPENBLAS_NUM_THREADS=1 python3 reports/destruction-test-coverage-audit/challenge-checkers.py
```

Exact CPU test commands and environment are in `cpu-tests.json`. Use [OPTIMIZATION.md](../../OPTIMIZATION.md) and current ownership records for actual candidate GPU qualification; this audit does not replace those gates. Historical reported GPU passes cannot qualify a different source/library composition. In particular, the latest [N29b preparation receipt](../../qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n29b-preparation.md) reports original numerical plus 20 exact-reuse tests in isolation; it is not a new full-suite pass in this audit.

**Next work, ranked:** (1) complete native continuous motion observability; (2) independent native equilibrium/material-margin acceptance; (3) canonical cross-implementation physics comparisons while retaining strict diagnostics; (4) port high-value native metamorphic and accepted momentum/energy cases; (5) isolate the failing CPU fixture and unify serial qualification with explicit coverage receipts. These changes make ambitious optimization easier to judge without weakening destruction fidelity.
