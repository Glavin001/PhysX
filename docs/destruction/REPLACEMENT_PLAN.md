# ⚡ GPU destruction: replacement architecture and quantified opportunities

**Objective: the fastest maintainable, physically equivalent destruction implementation on this RTX 4090.** Achieving 8 ms or 16.67 ms is a milestone; optimization continues beyond either threshold.

Build toward the final GPU-owned architecture. Use fast, targeted verification to reject incorrect or unpromising implementations before investing in complete scenario qualification.

## 1. 🎯 Contract and measured opportunities

### Fixed implementation contract

- **Hardware:** RTX 4090, `sm_89`, qualified CUDA 12.8 toolchain.
- **Physics timestep:** 1/60 second.
- **Correction:** at most one corrected physics advance; at most two stress/fracture evaluations per tick.
- **Fracture model:** actual solved contact impulses, existing stress/material equations and unchanged convergence requirements.
- **Developer interface:** `PxDestructionScene`, ordinary `simulate`/`fetchResults`, **Direct GPU disabled**, sleeping enabled, current-tick actor access and scene queries.
- **Production:** one integrated CUDA implementation. Reference implementations and experiments remain separate test artifacts.
- **Workspace:** implementation stays in `physx-2`; source sibling repositories remain read-only. Deployment and service changes are excluded.

The authoritative timer begins before recorded command application and ends when accepted motion, destruction state, mandatory status and required observations are ready. Include runtime growth, synchronization and accepted CPU compatibility work. Exclude asset preparation, initial context creation, rendering, encoding and report generation; report initialization separately.

Keep every measured step, including first-step and allocation spikes.

### Existing diagnostic

The main capture ran **256 buildings, 113,664 chunks, 229,376 bonds and a 768-projectile command sequence over 600 steps / 10 simulated seconds**, with Direct GPU disabled, sleeping enabled and correction limited to one.

| Step | Complete advance | Fragment bodies / awake | Net new fragments | New broken bonds | Fragment creation + ownership | GPU stress |
|---|---:|---:|---:|---:|---:|---:|
| 48 | **142.946 ms** | 10,449 / 10,193 | 6,344 | 28,530 | **32.183 ms** | **31.004 ms** |
| 49 | 104.377 ms | 11,366 / 11,110 | 917 | 4,174 | 4.342 ms | **37.245 ms** |
| 52 | 56.885 ms | 11,401 / 11,145 | 2 | 2 | 0.164 ms | **35.839 ms** |
| 76 | 92.249 ms | 14,342 / 14,056 | 1,008 | 2,519 | 6.499 ms | **45.794 ms** |

These instrumented results identify opportunities; they are not untraced deadline qualification. The same run’s first step took **160.416 ms**, with no projectiles or fragments. Existing attribution does not establish that destruction initialization caused that entire spike. [Generated timing report](/root/workspace/physx-2/qualification/native-chunk-index-20260909/baseline-phases/report.md)

### Ranked replacements

**Legend:** 🚚 migrate ownership · 🔁 replace implementation · 🗑️ delete unnecessary work · ⚡ optimize necessary computation · 🛡️ verify.

The savings below are **conditional calculations, not forecasts**. Replacement computation, synchronization, validation and mandatory CPU publication must be included.

| Priority | Replacement | Measured exposure at step 48 | Mechanism and conditional saving |
|---|---|---|---|
| **1 — 🚚 GPU fragment lifecycle** | GPU motion allocation, simulation registration and ownership transactions | **10.786 ms** creating fragment records plus **21.397 ms** updating ownership; **10,376 shape migrations** | Remove CPU lifecycle prerequisites and per-object traversal between GPU stages. Halving the combined cost, including replacement and accepted publication, saves **16.09 ms**. |
| **2 — 🔁 Structural solving** | Reusable factored substructures, interface solving and component-local execution | **31.004 ms** across two evaluations; **45.794 ms** at step 76 | Reduce repeated sparse traversals and sequential iterations. A qualified **2× total solve speedup**, including setup, saves **15.50 ms** and **22.90 ms**, respectively. |
| **3 — 🔁 Persistent contacts** | Preserve eligible geometric pair storage; rebuild motion-dependent registrations and rows | Selected allocation/registration scopes occupy a **13.367 ms elapsed union inside correction** | Owner migration should not recreate unchanged geometric relationships. Removing half the exposure offers **6.68 ms gross opportunity**, before replacement cost and parallel-task overlap. |
| **4 — 🔁 Cluster-level publication** | Separate cluster-frame changes from actual chunk membership changes | **93,488 chunk observation rows**, **2.358 MB** of topology observations; **11.894 ms** accepted-observation scope | A retained cluster’s COM change should produce a cluster update. If half the scope scales with expanded rows, removing 80% of those rows saves approximately **4.76 ms**, before replacement overhead. Both fractions require verification. |
| **5 — 🔁 Selective correction** | Correct the actual contact/constraint dependency closure | **53.663 ms** for the complete corrected interaction | Preserve independent accepted work. No defensible positive savings estimate yet for simultaneous bombardment: its affected closure may be large. Contact-lifecycle savings above overlap this scope. |
| **6 — 🚚 Local activity and topology** | Producer-maintained dirty work, exact reuse and affected-component rebuilding | Connectivity/mass/candidates total **0.952 ms** | Halving this stage saves **0.48 ms here**. Larger benefits should appear in idle and localized destruction as total world size grows. |
| **7 — ⚡ Remaining passes** | Contact/material fusion, mass specialization and redundant-pass deletion | Loads **0.279 ms**, materials **0.140 ms**, GPU rewind copies **0.014 ms** | Halving loads and materials saves approximately **0.21 ms**. Rewind-copy tuning cannot solve the large peaks. |

Accounting rules:

- The **32.255 ms host wait contains the 31.004 ms GPU stress work**. They are not separate savings.
- Correction includes collision, solving and lifecycle work. Do not credit lifecycle savings and then claim the entire correction duration again.
- Moving CPU work after correction changes a dependency; it does not automatically reduce complete-step time.
- Parallel task durations are not additive. Their elapsed union is not proof that every millisecond lies on the critical path.

Even granting an optimistic **4× reduction** in fragment creation/ownership, selected contact-registration exposure and stress, step 48 would remain approximately **85.5 ms** if everything else stayed unchanged. This is a generous accounting exercise, not a hardware floor. It explains why the replacement must also address correction scope, destruction-imposed collision organization and accepted-state consumption.

## 2. 🧱 Declarative end state

### Persistent representations

| Representation | Required responsibility |
|---|---|
| **Chunks** | Immutable authored identity, geometry and local properties, independent of motion |
| **Bonds** | Mutable connectivity, damage and material state |
| **Rigid clusters** | One active motion state and mass frame per connected rigid group |
| **Geometric contacts** | Persistent shape-pair identity and reusable geometric information |
| **Solver registrations** | Separately versioned motion references, activation order, constraint rows and warm-start validity |
| **Stress components** | Equation partitions with reusable operators, factors and convergence certificates |
| **Correction work sets** | Contact/constraint dependency closures, distinct from structural components |
| **Observations** | Committed cluster changes, actual membership deltas and active motion |

Use generation-bearing handles and persistent growable storage. Capacity is not active work: spare storage must not create independently simulated bodies.

The bond graph remains connectivity truth. Preserve minimum-ID component labels, stable chunk ordering, authored identities and creation ancestry.

### One integrated advance

1. Apply commands exactly once and checkpoint required mutable state on the GPU.
2. Execute ordinary PhysX trial collision and rigid-body solving.
3. Consume solved normal/friction impulses internally, preserving application points, torque and support evidence.
4. Evaluate stress and material fracture.
5. Update affected connectivity, cluster mass, motion ownership and solver registrations on the GPU.
6. If required, restore the relevant participants and execute **one** corrected physics advance.
7. Evaluate stress/fracture again, apply final-split semantics and publish accepted state once.

Preserve damage and energy accounting across legitimate evaluations; numerical retries must not duplicate commands, damage or events.

No predicted breakage, per-chunk intact motion states, external contact/load round trip, provisional per-shape CPU rebinding or unconditional full-state readback belongs in the finished path.

### GPU and CPU ownership

**GPU owns:** structural state, numerical solving, activity certificates, fragment allocation, collision ownership transactions, correction scheduling and accepted device publication.

**CPU owns:** asset preparation, command submission, exceptional capacity management and accepted compatibility/query publication.

Ordinary actor commands and current-tick queries must work after `fetchResults`. CPU compatibility objects represent accepted state; they must cease being prerequisites for the corrected GPU interaction. Their necessary publication cost remains measured.

### Structural solving

The proposed numerical replacement is **factorized substructures with an interface solve**, using the existing equations:

- Partition components into compact local substructures.
- Factor local interiors and eliminate them algebraically into interface equations.
- Solve the projected interface problem and recover original bond responses.
- Preserve free-body null spaces, warm-start/self-stress semantics and authoritative residual checks.
- Retain factors while their exact operator remains unchanged.
- Invalidate affected factors after topology, support or coefficient changes.
- Share immutable operators/factors between instances only when coefficients and boundary conditions are equivalent.
- Use bounded local dense work where appropriate; never construct a dense world-sized inverse.

This is an **unproven candidate**, chosen because it attacks repeated work and dependency depth. Existing captured equations provide its first rejection gate.

At the corresponding step 48, a separate intrusive census of the same city workload recorded:

| Work across both stress evaluations | Count |
|---|---:|
| Component evaluations | 2,823 |
| Summed component iterations | **107,090** |
| Outer-operator live adjacency visits | **242,473,931** |
| Polynomial-preconditioner live adjacency visits | **119,113,158** |
| Cached 6×6 inverse applications | **69,385,024** |

Anchored structures account for **99.990%** of counted live adjacency visits. These are mathematical operations, not kernel launches or physics replays. The solver already iterates inside resident kernels. [Stress work census](/root/workspace/physx-2/qualification/vibe-component-work-accepted-20260908/report.md)

Evaluate replacements using:

\[
T_{\mathrm{new}}
=
T_{\mathrm{setup,new}}
+
T_{\mathrm{iterations,old}}
\frac{I_{\mathrm{new}}}{I_{\mathrm{old}}}
\frac{C_{\mathrm{new}}}{C_{\mathrm{old}}}
+
T_{\mathrm{verification,new}}
\]

Fewer iterations alone are insufficient. Factor setup, application cost, verification and invalidation must produce a net improvement.

### Activity, topology, collision and publication

- Producers maintain dirty component queues. Reuse stress only under validated effective inputs, operator, settings and previous convergence.
- Continue required material evolution independently; rigid sleep alone is not a reuse certificate.
- Rebuild affected old components and recompute changed cluster mass frames.
- Preserve geometric contacts where valid, while invalidating incompatible rows, impulses and filtering state.
- Discover newly eligible fragment pairs after splitting.
- Build correction closure through contacts and supported constraints, including ordinary bodies. Fixed boundaries must not unnecessarily connect the whole world.
- Use complete required correction whenever selective reuse validity is unproven.
- Use cluster bounds and persistent local chunk hierarchies to reduce destruction-imposed collision bookkeeping. Retain NVIDIA’s numerical foundation.
- Publish retained cluster-frame changes separately from actual chunk migrations, created/removed clusters and broken bonds.

The current publication producer marks all members of affected source clusters. The replacement must remove that expansion while preserving COM and render/collision agreement.

## 3. 🛠️ Implementation order and execution strategy

Implement complete responsibilities in their final ownership. Avoid improving CPU bridges that the architecture removes.

| Order | Deliverable | First fast proof | Acceptance concern |
|---|---|---|---|
| **1** | GPU fragment lifecycle and persistent contact registration | Allocation/reuse transactions; owner-change contact fixture; 32-step wall prefix | Correct registration order, ordinary participants, wake propagation and no stale ownership |
| **2** | Cluster-frame publication and component-local storage/activity | Two-commit publication fixture; retained COM changes; single-input invalidation tests | No missing/duplicate events, valid reuse and current-tick queries |
| **3** | Replacement structural solver | Production-CUDA replay of archived hard equations and component batches | Original residuals, bond responses, setup cost and complete trajectory equivalence |
| **4** | Selective correction and cluster collision organization | Small contact/joint chains and newly eligible fragment contacts | Complete dependency closure and equality with complete correction |
| **5** | Remaining computation and cleanup | Focused producer/material/mass/storage tests | Actual end-to-end benefit without lost physical work |

The current contact-retention prototype is unqualified. A recorded experiment traced its failure to changed activation/constraint ordering caused by retained CPU pool indices. Restoring reference event order made the controlled oracle pass. The production solution must separate geometric storage lifetime from numerical registration order and make consumers honor the native ordered activation stream. Do not preserve a fixture-specific ordering table or introduce a permanent CPU allocator emulation. [Ordering experiment](/root/workspace/physx-2/qualification/native-contact-owner-20260909/ORDERING_FINDING.md)

### CUDA execution

- Keep component-local vectors and adjacency contiguous; separate hot numerical state from lifecycle metadata.
- Use warp/block work for small components and tiled cooperative execution for large components.
- Use device work queues, independent convergence retirement and scheduling that reduces completion tails.
- Producers overwrite owned reduction partials; avoid unnecessary clearing passes.
- Reuse scan/sort/reduction scratch and distinguish capacity from valid work.
- Establish legal CUDA 12.8 graph/task boundaries after moving lifecycle ownership. Graphs cannot simply encapsulate existing CPU lifecycle work.
- Qualify shared-memory staging, asynchronous movement and Tensor Core preconditioning against total solve cost and unchanged physical acceptance.
- Keep one qualified production implementation per necessary workload specialization; remove rejected experimental branches.

Preserve the public scene API and Rust consumer semantics. Version changed descriptors and rebuild every affected ABI consumer.

## 4. ⚡ Verification designed for rapid iteration

**Working loop: edit → incremental build → targeted proof → early integration → short matched screen → full regression for survivors.**

### Verification tiers

| Tier | When | Execution | Meaning of a pass |
|---|---|---|---|
| **⚡ 1 — Local rejection** | Every relevant edit | Affected numerical/lifecycle fixtures and production-kernel replay | Continue experimenting |
| **🔎 2 — Early integration** | After local checks pass | **32-step wall prefix** with intermediate reference comparisons | Known early collision/fracture behavior remains correct |
| **📈 3 — Short screen** | Candidate has a plausible mechanism | **128-step penetration**, **96-step city destruction prefix**, matched pristine idle and affected connected-component fixtures | Initial physical confidence and evidence of the intended improvement |
| **🧱 4 — Complete regression** | Before accepting a replacement or accumulating dependent changes | Existing **600-step wall audit**, complete city/idle comparisons, connected downtown and affected sanitizers | Broader integration and later behavior remain correct |
| **🏁 5 — Promotion** | Stable subsystem milestone or release candidate | Five 60-second trials per qualifying workload and ten-minute lifecycle endurance | Full sustained qualification |

Target useful Tier 1 feedback within approximately **5–20 seconds after compilation**, depending on subsystem. This is an engineering target, not a measured promise.

The short cases preserve physical inputs:

- The recent ownership failure changed motion at step 17 and topology at step 29; the 32-step wall prefix targets that failure.
- The 128-step wall includes the existing two-second hole checks.
- The 96-step city prefix includes known peaks at steps 48, 49, 52 and 76. It uses **256 buildings, 113,664 chunks and 229,376 bonds**, replaying the beginning of the unchanged 768-shot tape. Report the shots actually executed.
- Reducing 600 steps to 96 removes **84% of simulated steps per run**, not necessarily 84% of wall time.

These prefixes are rejection tools, not substitutes for late destruction, settling or endurance.

### Production-kernel replay

Complete a reusable CUDA replay harness using existing captured structural equations:

- Invoke the production implementation rather than duplicating it in a test solver.
- Restore identical RHS, warm state and topology before repetitions.
- Distinguish changed-operator setup from valid-factor reuse.
- Check independent residuals and recovered physical responses.
- Include representative batches, not only isolated components.
- Count reset/setup appropriately and never benchmark accidental convergence reuse.

Do not build a general PhysX checkpoint/restore framework merely to accelerate testing. Structural snapshots are not complete collision, contact-cache, sleep and solver checkpoints. Use fresh recorded-command prefixes for integration.

### Fail early and capture only what answers the question

- Check finite state, convergence, ownership and publication consistency during execution.
- Compare controlled topology identities at each accepted step and motion using existing tolerances.
- Stop on the first correctness failure.
- Keep a bounded diagnostic buffer around that failure instead of recording full trajectories by default.
- Reserve full render/motion audits for Tier 4; require them for ownership/frame/consumer changes before acceptance.
- Separate correctness probes, untraced performance screens and intrusive diagnostics.
- Start performance screening with a matched rejection pair; use alternating repeated comparisons for candidates worth pursuing.
- Repeat ambiguous timing results rather than treating one noisy sample as proof.
- Label interrupted screens incomplete and preserve their samples.

### Builds and evidence reuse

- Incrementally rebuild affected targets and all required ABI consumers.
- Keep baseline and candidate artifacts immutable and separate.
- Keep production and diagnostic builds distinct.
- Record compilation, linking, execution and report-generation time separately.
- Add qualified compiler caching for repeated builds and reversions; do not expect it to eliminate compilation of new CUDA code.
- Reuse correctness results only when relevant artifacts, dependencies, fixtures, settings and validation versions match.
- Use fresh matched controls for performance claims.
- Run GPU measurements sequentially and isolated from builds, rendering and sanitizers.

Extend the existing runner with tiers and subsystem selection. Preserve its reports and artifact attestations rather than creating another benchmark framework. Every newly discovered regression should add a small reproducer to the appropriate fast suite.

## 5. 🛡️ Qualification and completion

Track benefits independently for **pristine idle, active destruction, settling, sleeping rubble, reactivation and initialization/growth**. An idle improvement is valuable without a destruction-peak gain; it must not be presented as one.

Required scenarios:

| Scenario | Required coverage |
|---|---|
| **Single penetration:** 444 chunks, 896 bonds, one projectile | Actual entry/exit holes, approximately 90% retained structure, correction behavior, identities and motion continuity |
| **256-building bombardment:** 113,664 chunks, 229,376 bonds, unchanged 768-shot tape | Simultaneous destruction, fragment/contact lifecycle and later rubble |
| **Connected downtown:** 24,105 chunks, 74,543 bonds | Long structural load paths and large-component execution |
| **Fresh idle counterparts** | Unnecessary background work, spontaneous fracture and first-step costs |
| **Controlled lifecycle fixtures** | Supports, force couples, COM changes, ordinary bodies/joints, sleep/wake, current queries, capacity and handle reuse |

Preserve existing mode-specific regression gates and resolve the recorded historical/ordinary-mode difference explicitly. Do not redefine golden outputs or loosen tolerances to accept a replacement.

Before promotion:

- Run five 60-second trials per proposed passing workload, retaining every complete-step maximum.
- Run ten-minute endurance that actually exercises repeated impacts, support changes, settling, wakeup, removal/reinsertion and handle reuse. Extending an otherwise idle scenario is insufficient.
- Report 8 ms and 16.67 ms separately, alongside distributions and missed deadlines.
- Attest loaded binaries and preserve machine-readable samples.
- Compare historical external implementations only under matched physical settings and workload.
- Give every optimization-ledger responsibility a tested disposition: retained, eliminated, replaced and qualified, or rejected with evidence.

For every candidate, report **before/after work counts, targeted phase cost, replacement overhead, complete-step peak movement, physical results and independent regime outcomes**. Recompute the maximum across the run so improvements at one peak do not hide the next bottleneck.

**Completion means the final GPU-owned architecture, qualified physical behavior and more verified destruction per complete advance. Fast tests accelerate decisions; full qualification establishes acceptance.**
