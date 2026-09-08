# 🎯 Ranked destruction optimization review

**Recommendation: prioritize GPU-native fragment motion/shape ownership, then the stress recurrence. Develop GPU contact lifecycle as part of completing that ownership architecture.** Selective correction has a large measured parent phase but an unproven reusable fraction in simultaneous bombardment.

## Evidence and scope

Reviewed source: `ab30a85b410603c284255f562f92f7733ab5ad8e`; runtime SHA-256 `c9e09e4d05f9077928428137311cf665774e053e40c4a12d03d2c7a2790f1511`. Read-only code review plus regeneration of existing measurements; **no new performance simulation was run for this report**. This is a frozen baseline review, not a qualification of later working-tree changes. Restored-baseline native analytic, 3D and motion suites passed. Source hashes and links refer to the recorded revision; local line positions can move as development continues.

Fixture: **256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles**, two untraced runs of **180 steps / 3 simulated seconds** each, plus a separate instrumented replay. Physics timestep 1/60 s; maximum one correction per step; sleeping disabled; crushing material disabled. Grid layout, aerial launch path, projectile mass 18,000 kg, material strength scale 24 and frame strength scale 40. Complete advance includes commands, physics, destruction, correction, synchronization and runtime growth; excludes initialization, rendering and report generation. This is not long-run qualification.

Untraced mean across both runs: **16.717 ms**; worst **53.603 ms**. The peak is still about 3.2 times the 60 Hz budget.

| Step | Untraced min–max ms | Awake bodies | Contact load count | Active stress nodes / bonds | Stress islands | Max iterations | Bonds broken this step | Corrections |
|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 82 | 51.774–53.174 | 5,376 | 1,024 | 92,672 / 172,544 | 512 | 95 | 28160 | 1 |
| 102 | 48.326–49.159 | 10,521 | 92,758 | 88,621 / 151,280 | 1606 | 282 | 7025 | 1 |
| 103 | 52.497–53.603 | 12,072 | 109,383 | 87,306 / 143,980 | 1842 | 276 | 7300 | 1 |

Contact count is the demo’s `normalContacts` load counter, not independently measured solver rows or unique broad-phase pairs. Stress topology counters are committed observations, not exact per-iteration work. Max iterations is not the sum of component iterations. Step 102 is included because improving only steps 82/103 can expose its 49 ms cost as the next peak.

| Separate instrumented elapsed scope | Step 82 ms | Step 102 ms | Step 103 ms |
|---|---:|---:|---:|
| 🚚 Ownership/lifecycle | 16.072 | 7.795 | 8.650 |
| ⏪ Correction | 26.473 | 15.112 | 19.870 |
| 🧮 Stress submission/completion dependency | 8.254 | 19.022 | 19.445 |
| 📤 Accepted-state work | 2.363 | 2.332 | 2.295 |
| 🟰 Trial physics + unassigned tasks | 3.110 | 6.173 | 8.032 |

The host scopes above are disjoint apart from recorded timestamp bookends. They include GPU waits. CUDA stress intervals are nested, and cannot be added again. Other small groups are retained in JSON. Instrumented timings are not substituted for untraced peaks.

## Ranking and estimate rules

**Every savings estimate below is a conditional engineering scenario, not a measured speedup, probability interval or guaranteed lower bound. Actual savings may be zero or negative.** Measured phase costs bound opportunity; the percentage of that cost removable is an explicitly stated judgment requiring an experiment. No hardware bandwidth, occupancy or compute-saturation claim is made.

Rank uses the lower end of the conditional reduction in the worst observed complete advance, with the upper end breaking ties. The calculation subtracts estimated savings only at steps 82/102/103 from both untraced runs, leaves every other measured step unchanged, then takes the new maximum. This accounts for the bottleneck moving. It transfers scoped exposure to untraced runs as an approximation; it cannot predict new stalls or allocation peaks. Fractions are screening assumptions, not evidence.

| Rank | Idea / action | Conditional savings at 82 / 102 / 103 (ms) | Conditional reduction of worst complete step (ms) | Confidence |
|---|---|---|---:|---|
| 1 | A: 🚚 GPU-native fragment motion and shape ownership | 5.63–9.64 / 2.73–4.68 / 3.03–5.19 | 3.03–5.19 | Low for savings; strong evidence of CPU work |
| 2 | B: ⚡ Reduce full resident stress iteration cost | 1.14–2.28 / 2.74–5.48 / 2.80–5.60 | 1.57–2.71 | Low |
| 3 | C: 🚚 GPU admission and lifecycle for new contact pairs | 1.72–3.43 / 0.55–1.10 / 0.47–0.93 | 0.47–0.93 | Low |
| 4 | D: 🗑️ Rebuild only changed stress setup; omit unused motion-mode work | 0.35–0.83 / 0.35–0.82 / 0.34–0.80 | 0.34–0.80 | Low |
| 5 | E: 🗑️ Remove intermediate host decisions and resubmission | 0.09–0.18 / 0.08–0.15 / 0.08–0.15 | 0.08–0.15 | Low |
| 6 | F: ⚡ Fuse contact-load and material preparation where inputs permit | 0.02–0.04 / 0.03–0.06 / 0.03–0.06 | 0.03–0.06 | Low |
| 7 | G: 🎯 Selective correction with exact dependency closure | 0.00–1.32 / 0.00–0.76 / 0.00–0.99 | 0.00–0.99 | Very low for this workload |

**Do not sum rows.** E is already inside A. G overlaps C. B’s layout and preconditioner alternatives overlap each other. A and C need coordinated integration even though their measured host scopes differ. These estimates do not establish a path to 8 ms by arithmetic alone.

## 1. 🚚 GPU-native fragment motion and shape ownership

**Change:** Replace per-fragment NpRigidDynamic/BodySim construction and per-shape host rebinding with GPU motion slots, generation-bearing ownership transactions and explicit query observations. Keep immutable collision geometry and identities.

**Measured/code basis:** The disjoint ownership group is 16.072 ms at step 82 and 8.650 ms at step 103. Body reservation alone is 6.079 / 3.355 ms; shape-migration remainder is 4.690 / 1.659 ms. These are concrete host lifecycle operations, not the physical stress solve.

**Estimate model:** Scenario removes 35–60% of the measured ownership group NET of replacement GPU work. This is a planning assumption, not measured CUDA throughput. It deliberately leaves 40–65% for necessary allocation, validation, ownership, filtering and observation costs.

**Adversarial assessment:** Cannot delete CPU records independently: existing contact managers, actor interaction lists, teardown and query ownership refer to them. A partial change that keeps the same CPU bridge may save almost nothing. GPU slot exhaustion, ordinary-body interaction and handle reuse must remain correct.

**First falsifiable gate:** Qualify one GPU-owned fragment lifecycle through collision, correction, query observation, removal and reuse; then measure removed CPU records/rebindings and complete-step peaks. No preallocated independently simulated body per intact chunk.

**Implementation effort:** Large; requires contact-lifecycle integration. **Overlap:** Owns all ownership savings, including query deferral and relevant handoffs. Do not add those sub-ideas separately.

**Code:** [NpDestructionBodyAllocator.h](/root/workspace/physx-2/physx/source/physx/src/NpDestructionBodyAllocator.h:93); [ScShapeSimBase.cpp](/root/workspace/physx-2/physx/source/simulationcontroller/src/ScShapeSimBase.cpp:93); [NpShapeManager.cpp](/root/workspace/physx-2/physx/source/physx/src/NpShapeManager.cpp:184).

## 2. ⚡ Reduce full resident stress iteration cost

**Change:** Investigate a component-local layout for the ENTIRE hot recurrence, with persistent local node mapping and shared/register scratch across residual, preconditioner, direction and solution stages. Alternatively qualify a mathematically stronger component preconditioner; these are competing experiments, not additive benefits.

**Measured/code basis:** Current componentStressSolve already runs iterations inside one CTA and retires components independently. Its hot vectors still live in global arrays and the polynomial adds a sparse traversal. Current stress intervals are 7.606 / 18.270 / 18.668 ms at steps 82 / 102 / 103.

**Estimate model:** Scenario achieves 15–30% net reduction in the stress stream interval with unchanged equations, tolerances and required physical work. No present experiment proves this reduction. The percentage includes all replacement costs and may be unattainable.

**Adversarial assessment:** Two limited shared caches and a four-stage polynomial already failed complete-peak screens. More shared memory/registers can reduce concurrency; stronger preconditioning can increase time despite fewer iterations. Historical component-cycle shares predate the current runtime and are not current millisecond attribution. Refresh diagnostics before another variant.

**First falsifiable gate:** Capture current component work and phase cycles; prove the proposed layout eliminates a measured repeated cost. Run an independent operator/residual oracle, then matched complete bombardment. Reject isolated-kernel wins that do not reduce peaks.

**Implementation effort:** Medium–large; first isolate current per-iteration costs. **Overlap:** Layout, preconditioning, batching and mixed precision compete for the same stress interval. Never sum their estimates.

**Code:** [StressComponentIteration.cuh](/root/workspace/physx-2/blast/source/sdk/extensions/stressgpu/detail/StressComponentIteration.cuh:25); [StressNativePreconditioner.cuh](/root/workspace/physx-2/blast/source/sdk/extensions/stressgpu/detail/StressNativePreconditioner.cuh:20); [StressNativePolynomial.cuh](/root/workspace/physx-2/blast/source/sdk/extensions/stressgpu/detail/StressNativePolynomial.cuh:27).

## 3. 🚚 GPU admission and lifecycle for new contact pairs

**Change:** Consume PhysX GPU broad-phase pair output directly into GPU contact-manager slots and descriptors. Preserve NVIDIA narrow-phase and solver kernels; remove our native path’s need to reconstruct CPU ShapeInteraction/contact-manager/edge records for every new fragment pair.

**Measured/code basis:** Correction currently runs CPU contact preallocation followed by parallel registration/island tasks. We use preallocation plus the LONGEST registration task as a limited exposure proxy, not the sum of all tasks or the whole correction duration.

**Estimate model:** Scenario removes 25–50% of that limited proxy, net of GPU pool/filter/descriptor work. The proxy is not an exact critical-path measurement: worker start offsets and other dependencies can change realizable savings. No credit is assigned to broad-phase wait.

**Adversarial assessment:** GPU contact inputs exist already, but CPU contact records still carry lifetimes, reports and edge references. New fragment/ordinary-body pairs, filtering, friction caches, lost touch and capacity growth must survive. Moving only descriptor construction leaves most of this cost.

**First falsifiable gate:** Count newly allocated/retired/reused pairs and measure the actual registration critical path. Qualify native pair lifetime, newly eligible pairs and ordinary participants before deleting CPU lifecycle consumers.

**Implementation effort:** Large; coupled to A. **Overlap:** Correction portion only; excludes A’s shape retirement/ownership time. A and C share implementation prerequisites, so joint savings still require measurement.

**Code:** [PxgNarrowphaseCore.cpp](/root/workspace/physx-2/physx/source/gpunarrowphase/src/PxgNarrowphaseCore.cpp:8258); [ScPipeline.cpp](/root/workspace/physx-2/physx/source/simulationcontroller/src/ScPipeline.cpp:1019).

## 4. 🗑️ Rebuild only changed stress setup; omit unused motion-mode work

**Change:** Retain valid fine topology/motion-mode state per component, rebuild affected ranges, and avoid constructing null-motion data that anchored components do not consume. Preserve all graph validation and support-transition correctness.

**Measured/code basis:** Unchanged generations and unused recursive hierarchy tails are already skipped. Changed stress generations still rebuild global labels/order and run motion forest/tour construction; anchored factors return early only later. Accepted-state scope is about 2.3 ms at these peaks.

**Estimate model:** Scenario saves 15–35% of the accepted-state scope (roughly 0.35–0.83 ms). That entire scope is only a loose ceiling: it also contains mandatory commit/publication and waits. The setup-only share is not separately measured in this control.

**Adversarial assessment:** Simultaneous impacts may dirty most main components, limiting caching. Anchoring cannot justify omitting topology validation or free-body nullspace work after support loss. Existing unchanged local inverse retention and hierarchy-tail skips must not be counted again.

**First falsifiable gate:** Measure setup subphases and changed-component fractions first. Test support removal, free/anchored transitions, invalid incidence, stable ordering and unchanged-component certificates.

**Implementation effort:** Medium. **Overlap:** Shares accepted-state exposure with buffer swapping or copy elimination; those are alternatives within this budget.

**Code:** [NvBlastExtStressGpuTopology.cuh](/root/workspace/physx-2/blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpuTopology.cuh:281); [StressMotionModes.cuh](/root/workspace/physx-2/blast/source/sdk/extensions/stressgpu/detail/StressMotionModes.cuh:61); [PxgDestructionTransaction.cuh](/root/workspace/physx-2/physx/source/gpudestruction/src/PxgDestructionTransaction.cuh:130).

## 5. 🗑️ Remove intermediate host decisions and resubmission

**Change:** GPU dependencies select fracture/no-fracture, allocate within resident capacity, install ownership and publish completion. Keep the final application completion boundary and exceptional growth/retry.

**Measured/code basis:** The current code still reads preparation verdicts and waits before the CPU ownership bridge. The model counts only request-readback, preparation-completion and reservation-publication scopes, not the 8–19 ms wait containing necessary stress computation.

**Estimate model:** Scenario removes 25–50% of the small observed handoff proxy. It is a dependency of final architecture, not a separate multi-millisecond win.

**Adversarial assessment:** Deleting a wait does not delete its preceding kernels. Critical dependencies remain, and ordinary PhysX host task scheduling cannot simply be captured into a CUDA graph. A/C may already absorb all benefit.

**First falsifiable gate:** Show no host verdict between these stages and retain exactly-once commands, damage and events. Compare task/event dependencies, not just the count of synchronization calls.

**Implementation effort:** Coupled to A/C. **Overlap:** Fully nested within A’s ownership estimate. Do not add to A.

**Code:** [PxgDestructionRuntime.cu](/root/workspace/physx-2/physx/source/gpudestruction/src/PxgDestructionRuntime.cu:1460).

## 6. ⚡ Fuse contact-load and material preparation where inputs permit

**Change:** Fuse compatible producer/consumer stages or compact known active work, retaining normal/friction impulses, torque, support evidence and once-only damage.

**Measured/code basis:** Contact-load plus material CUDA intervals total only about 0.13–0.21 ms at these peaks. Stress equations and verdicts remain necessary.

**Estimate model:** Scenario saves 15–30% of these two intervals. Their full combined duration is the absolute local ceiling before dependency effects.

**Adversarial assessment:** Contact accumulation and bond material evaluation have different ownership/reduction patterns. Fusion may increase contention or registers and lose performance. This is not the route from 53 ms to real time.

**First falsifiable gate:** Prove complete work/energy equivalence and a repeatable peak change larger than run noise before retaining extra complexity.

**Implementation effort:** Small–medium. **Overlap:** Nested within destruction submission/completion, but separate from B’s measured stress interval.

**Code:** [PxgDestructionRuntime.cu](/root/workspace/physx-2/physx/source/gpudestruction/src/PxgDestructionRuntime.cu:1157).

## 7. 🎯 Selective correction with exact dependency closure

**Change:** Build GPU affected sets through contacts/constraints, preserve accepted independent work and rediscover newly eligible pairs. Recompute the complete interaction whenever reuse cannot be proven.

**Measured/code basis:** Correction spans 26.473 / 15.112 / 19.870 ms, but these include necessary collision and response. All 256 buildings receive impacts together; many interactions are actually affected. Existing unchanged-pair reuse is already enabled.

**Estimate model:** Credit only 0–5% of correction for this simultaneous-impact screen until affected-participant and reusable-pair counts prove more. No assumption that one correction can be removed.

**Adversarial assessment:** A single-step dependency component is not automatically a safe replay partition. New contacts and moved ordinary participants expand closure. Could cost more than complete replay here; likely more valuable for localized impacts in a larger idle city.

**First falsifiable gate:** Record affected body/shape/contact counts, closure expansion and valid-reuse fraction. Differential tests must include incoming new contacts, ordinary bodies and supported joints. Current correction excludes joints/sleep/CCD, so these remain explicit architecture gaps.

**Implementation effort:** Very large. **Overlap:** Contains C’s contact work. Do not add full correction savings to C; jointly measure.

**Code:** [ScPipeline.cpp](/root/workspace/physx-2/physx/source/simulationcontroller/src/ScPipeline.cpp:2917).

## Work not credited as a new peak saving

| Status | Idea | Assessment |
|---|---|---|
| ✅ Already present | Resident component iteration, independent convergence retirement, dynamic CTA work queue | Do not propose replacing thousands of per-iteration launches: this path already loops inside the component kernel. |
| ✅ Already present | Direct solved-contact consumption, unchanged generation skip, unchanged local inverse/warm-start retention, unused hierarchy-tail skip, GPU connectivity through growth | Preserve these gains; they are in the measured baseline. |
| ❌ Tried/reverted | Four-stage polynomial, limited unscaled/scaled shared polynomial caches | No established whole-peak gain. Scaled cache passes frozen penetration but worsens worst short-screen peak; a kernel-local win is insufficient. |
| ❌ Previously rejected | Colored sweeps, adjacency compaction, compensated FP32 inverse, exact-zero inverse bypass | Consult recorded qualification before revisiting; require a new mechanism/evidence. |
| ⏸️ Other workload | General settled-stress reuse / sleep | Important for large mostly idle cities. Sleeping is disabled in this frozen control, and impacts change inputs; assign zero peak savings until valid reusable work is measured. CPU API currently rejects general settled/unconverged skip flags. |
| ⏸️ Unmeasured subphase | Swap committed/trial device views instead of copying capacity-sized topology arrays | Code contains those copies, but no isolated copy-duration evidence supports a material gain. Fits the final architecture; establish copy cost and pointer/event lifetime safety before prioritizing. Do not equate all 2.3 ms acceptance time with copies. |
| 🚫 Changes fidelity | Cap iterations to the source’s cross-frame policy; suppress contacts/debris; freeze rubble | Separate behavior changes, not equal-work performance improvements under this gate. |
| 🚫 Not justified | Convert the whole sparse stress operator to dense GEMM / Tensor Cores | Sparse bond coupling and independent component sizes matter. Dense work can increase operations substantially. Small dense coarse blocks may be useful, but require an operator and precision proof. |
| ⏸️ Small current peak exposure | Checkpoint compaction / GPU command application | Checkpoint host elapsed is 0.009 / 0.264 / 0.009 ms at the reviewed steps; CUDA copy execution can overlap other scopes. Commands are absent at these impact steps but projectile insertion remains inside the first-step timer. Final device command ownership is required, without crediting it as a current destruction-peak win. |
| 🟰 Keep NVIDIA foundation | Rewrite ordinary broad/narrow-phase or rigid solve | Outside optimization focus. Improve destruction ownership/work selection at their interfaces. |

## The remaining deadline gap

Reducing the observed 53.603 ms worst step to 16.667 ms needs about **36.94 ms (69%)** removed; reaching 8 ms needs about **45.60 ms (85%)**. None of these individual estimates closes that gap. Their overlap prevents adding them into a promised total. A more complete architecture change may eventually exceed these screening scenarios, but that is unverified.

For perspective, even making the current 7.606 ms stress interval free at the first-impact step would leave roughly **45.57 ms** in the slower untraced step-82 run, under the same scoped-to-untraced approximation. Stress-only optimization cannot meet the deadline. Conversely, moving host bookkeeping to CUDA does not remove its physical or dependency obligations. The final architecture must address both ownership/correction and stress, and be measured again.

## Concrete next sequence

1. Map and test the GPU-owned fragment/contact lifecycle across allocation, ownership, pair creation, solver input, committed queries and teardown. This is A/C’s prerequisite, not a faster CPU rebind loop.
2. Establish A/C counters: created CPU records, migrated shapes, created/retired/reused contact managers, and registration critical-path intervals. Current broad parent timers cannot prove how much contact work is removable.
3. Refresh the stress component diagnostic on this exact runtime before another B experiment. Existing historical work attribution shows retained buildings dominate, but its preconditioner and iteration counts differ from today’s implementation.
4. Keep a short rejection screen, then physical regression, then five 60-second performance runs and 10-minute endurance for qualifying candidates. Run interleaved controls and retain all peaks.
5. Re-rank after every accepted implementation change. A faster second peak alone does not improve the first peak; validate the whole impact window.

## Limits and reproduction

No measured theoretical hardware floor is available. A valid model needs per-component node/bond iterations, actual sparse traversal/precision costs, new contact and ownership counts, and the dependency critical path. Peak GPU specifications or bytes divided by advertised bandwidth would only give optimistic lower bounds. The current trial-plus-unassigned scope also contains our integration, so it is not a clean PhysX-only floor.

Generated numeric analysis and judgments are in [review.json](review.json). Regenerate with `python3 qualification/peak-investment-review/generate.py` from the repository. The script validates complete-timer closure, verifies the workload and records source/data hashes. It reads reviewed source from the captured Git revision and runtime hashes from the captured manifest, never from a newer local build. Estimates remain human judgments. It does not rerun physics.

[Existing generated A/B report](/root/workspace/physx-2/qualification/polynomial-shared-scaled-fresh/comparison.md). [Full optimization inventory](/root/workspace/physx-2/docs/destruction/OPTIMIZATION_INDEX.md). [Restored native test result](/root/workspace/physx-2/qualification/polynomial-shared-scaled/restored-native-tests.log).


## Adversarial check: a second control capture

Same 256-building / 113,664-chunk / 229,376-bond / 256-projectile fixture; two more untraced 180-step / 3-second runs plus a separate instrumented replay. Captured demo, PhysX GPU and destruction runtime hashes match the earlier control. No new simulation was run to generate this analysis.

The second control peaks at **58.579 ms**. Reapplying the same speculative removable fractions produces the following sensitivity result. The fractions remain unvalidated; matching binaries does not establish identical GPU conditions.

| Idea | Earlier rank | Second-control rank | Earlier modeled peak saving ms | Second-control modeled peak saving ms |
|---|---:|---:|---:|---:|
| A: 🚚 GPU-native fragment motion and shape ownership | 1 | 1 | 3.03–5.19 | 5.78–9.91 |
| C: 🚚 GPU admission and lifecycle for new contact pairs | 3 | 2 | 0.47–0.93 | 1.64–3.28 |
| B: ⚡ Reduce full resident stress iteration cost | 2 | 3 | 1.57–2.71 | 1.14–2.29 |
| D: 🗑️ Rebuild only changed stress setup; omit unused motion-mode work | 4 | 4 | 0.34–0.80 | 0.34–0.80 |
| E: 🗑️ Remove intermediate host decisions and resubmission | 5 | 5 | 0.08–0.15 | 0.10–0.19 |
| F: ⚡ Fuse contact-load and material preparation where inputs permit | 6 | 6 | 0.03–0.06 | 0.02–0.04 |
| G: 🎯 Selective correction with exact dependency closure | 7 | 7 | 0.00–0.99 | 0.00–1.32 |

**Decision:** use the ranking to choose experiments, not as a stable forecast. Ownership remains the leading architectural candidate; the relative order of stress and contact lifecycle depends on which impact step dominates. The earlier table does not prove that a sub-millisecond change is distinguishable from run variation.

The initial contact-property migration comparison also does not establish a speedup: on this same fixture its two short candidate runs had a 58.068 ms worst advance versus 58.579 ms for these controls, while the second impact step became slower. This was an earlier WIP version, not the final guard revision. It removes one metadata dependency; it is not completion of GPU-owned contact or fragment lifecycle. See the [archived comparison](/root/workspace/physx-2/qualification/native-contact-properties-initial-comparison/comparison.md).
