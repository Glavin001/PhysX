# Real-time destruction: review, measurements and roadmap

How the GPU stress solver (`crates/stress-gpu`) gets to real time at city scale, without
giving up the oracle's accuracy:
- **Target:** about 100 buildings of 2–3k chunks each, many impacts, 60 Hz, every complete step ≤ 8 ms, coupled with PhysX.
- **Inputs:** two colleague documents (a research compendium and "Speed-of-Light Analysis v2"), checked against the code and against measurements on this branch.
- **Ground rules:**
  - `stress-ref` is the ground truth, and strictly better methods are adopted there.
  - The GPU approximates only where the oracle measures the cost (`IMPROVEMENTS.md` protocol).
  - Every timing here is an Apple M3 Max proxy. None is an RTX 4090 qualification.

Reproduce the tables with:

```bash
target/release/stress-gpu-steps --levers <packs>                               # A1
cargo run --release -p stress-ref --example rest_utilization -- <packs>        # A2
cargo run --release -p stress-reduce --example condense_report -- <packs>      # A3
STRESS_METHODS=established target/release/stress-gpu-fps --config realtime \
  --gpu-only --town house-1story:100:4                                         # A4
```

Packs are in `blast/blast-stress-demo-rs/assets/scenes`.

## A. Measurements

### A1. What sets the explicit step (`stress-gpu-steps --levers`)

Substeps per 1/60 s frame at safety 0.9:
- **true:** power-iteration estimate plus 3%, with the top mode's damping;
- **certified:** the oracle's `true_step` bound, whose damping is the largest dashpot ratio of any bond.

Gains are ratios of substeps per frame.

| Pack | Chunks | Reference | True | Certified (undamped) | Rot. inertia ×4 | Multirate | Top mode carried by |
|---|---|---|---|---|---|---|---|
| brick-building | 248 | 738 | **179** | 205 (193) | ×1.02 | ×1.00 | uniform 240–480 kg bricks |
| house-1story | 319 | 29,491 | **1,264** | 4,730 (1,124) | ×1.44 | ×3.36 | one 66 kg timber beam (100%) |
| house-2story | 599 | 31,403 | **1,358** | 8,151 (1,292) | ×1.30 | ×3.03 | two 3.2 kg timber stair pieces (98%) |
| parking-garage | 3,177 | 12,473 | **934** | 3,139 (908) | ×1.29 | ×2.71 | three 18 kg concrete stair pieces |
| villa-savoye | 1,045 | 12,741 | **931** | 3,385 (905) | ×1.29 | ×1.90 | two 17.5 kg concrete stair pieces |
| neighbourhood | 8,877 | 31,403 | **1,360** | 17,430 (1,294) | ×1.31 | ×3.76 | 3.2 kg timber stair pieces |
| park-432 | 24,452 | 12,727 | **1,271** | 9,730 (1,205) | ×1.76 | ×2.86 | 18 kg concrete stair pieces |
| petronas | 24,766 | 55,752 | **1,369** | 2.6 M (1,287) | ×1.47 | ×2.89 | one 1.6 t steel parapet piece (97%) |
| skyline | 62,525 | 55,752 | **1,944** | 2.1 M (1,827) | ×2.03 | ×4.34 | 21.8 kg concrete stair pieces |
| minas-tirith | 49,049 | 125,502 | **6,766** | 324 M (6,023) | ×2.09 | ×18.1 | small stones beside massive blocks |

What this shows:

- **One to three light chunks set the step of every mixed building.** On most packs they are stair pieces. Damping is not the limit: switching it off gains 1.02–1.09×.
- **The certified frequency is tight** (undamped column within 2–10% of the estimate).
- **Its damping term is not.** The largest β of any bond, times ω_max, gives 3–6× too many substeps on houses and millions on the steel and stone packs (v2's "worst β × worst ω" pathology). A certified bound on ρ(M⁻¹C) instead of β_max·ω would recover it. **Open, for the oracle.**
- skyline, minas-tirith and petronas now import: bonds whose shared face has no width are left out, 16, 8 and 11 of them.

### A2. Utilization at rest (`rest_utilization`)

Each bond's failure index at the gravity prestress, evaluated without committing:

| Pack | Bonds | > 0.4 | > 1 | Max (where) |
|---|---|---|---|---|
| brick-building | 494 | 0% | 0 | 0.09 |
| house-1story | 877 | 0% | 0 | 0.37 (timber post–wall) |
| comp-wall-bay | 109 | 0% | 0 | 0.01 |
| rig-portal | 39 | 2.6% | 0 | 0.54 |
| house-2story | 1,652 | 1.6% | 7 | 2.22 (mortar under the steel rails) |
| villa-savoye | 2,464 | 15.6% | 37 | 3.92 (concrete stair) |
| parking-garage | 9,194 | 14.3% | 309 | 4.15 (concrete beam–slab) |
| neighbourhood | 23,581 | 12.2% | 311 | 2.98 (concrete slab–core) |
| park-432 | 78,196 | 5.2% | 134 | 1.60 (concrete slab–beam) |

- **Small buildings are well below strength at rest,** so a v2 energy certificate (E_safe, bonds ≤ 0.4) can work there.
- **Every multi-storey reinforced-concrete pack has bonds over strength under its own weight.** These are calibration or authoring issues (the assets were authored for the older Blast model).
- **Effect:**
  - They crack at rest in the truth.
  - They block island-level energy certificates on those buildings until the assets or materials are fixed.
  - A location-aware bound (influence lines) can still certify loads far from the overloaded joints.

### A3. Static condensation on our own partitions (`stress-reduce`)

The network assembled from the oracle's bonds reproduces the oracle's gravity equilibrium to between 2e-14 and 1e-11 (`tests/condensation.rs`). Condensation plus recovery equals the full solve to round-off.

**house-1story** (1,794 free DOFs; full gravity PCG 769 iterations):

| Parts of | DOFs kept | Storage (f32) | Gravity PCG | Explicit step gain |
|---|---|---|---|---|
| 8 | 100% | 0.2 MB | 773 | ×1.00 |
| 32 | 65% | 0.5 MB | 661 | ×1.00 |
| 128 | 25% | 1.2 MB | 519 | ×1.00 |
| 256 | 14% | 3.2 MB | 323 | ×1.00 |

- **Partitioning shrinks the static system** (86% of DOFs gone at 256-chunk parts).
- **It gives no explicit-step gain:** the chunk that sets the step is a boundary chunk. Results by pack:
  - house-1story ×1.00 at every part size;
  - house-2story ×1.04 up to parts of 128, ×1.25 at 256;
  - brick-building ×1.00.

**Sliver elimination.** The study greedily eliminates the retained chunk carrying most of the current top mode, then reports the Guyan step gain:

| Pack | 1 | 2 | 4 | 8 | 16 chunks eliminated | First eliminated |
|---|---|---|---|---|---|---|
| house-1story (319 chunks) | ×1.00 | ×1.33 | ×1.34 | ×1.48 | **×4.51** | 66–67 kg timber beams, then 16 kg timber posts |
| house-2story (599 chunks) | ×1.00 | ×1.03 | ×1.04 | ×1.04 | ×1.66 | 3.2–3.4 kg timber stair pieces |
| brick-building (248 chunks) | ×1.00 | ×1.00 | ×1.00 | ×1.01 | ×1.02 | uniform bricks: nothing to gain |

- **On house-1story, 5% of the chunks are worth ×4.5 in the explicit step.**
- **What the eliminated chunks lose:**
  - They follow their neighbours quasi-statically. Their own vibration, at 15–20 kHz, has no gameplay meaning.
  - Their bonds' forces are recovered exactly in the static limit.
  - Their inertia moves to the retained neighbours (`M~`).
- **Status:** a step and model change, so it must be proven as an oracle switch against explicit (`fidelity.py`) before the GPU uses it. Queued as Phase 1b.

### A6. Cost of an intact-only kernel per substep (`stress-gpu-bench`)

Both kernels run the whole segment in one dispatch (narrow islands), or one round of dispatches per substep (wide), whichever is faster. Packs are timed with rebar stripped, because the intact kernel has no rebar and on an intact bond rebar is only added stiffness.

| Scene | Chunks / bonds | Full model (`GpuSolver`) | Intact kernel (`GpuStress`) | Gain |
|---|---|---|---|---|
| slab 12×6×2 | 144 / 324 | 14.4 µs | 2.4 µs | ×6.0 |
| slab 16×8×2 | 256 / 592 | 22.8 µs | 5.8 µs | ×3.9 |
| brick-building | 248 / 494 | 23.0 µs | 5.8 µs | ×4.0 |
| house-1story | 319 / 877 | 24.9 µs | 9.4 µs | ×2.6 |
| house-2story | 599 / 1,652 | 25.4 µs | 10.0 µs | ×2.5 |
| villa-savoye | 1,045 / 2,464 | 23.5 µs | 7.8 µs | ×3.0 |

- **The full model sits at a ~24 µs floor for every pack size.** That is latency (code size, spills, A2), not work.
- **An intact-only path gains ×2.5–6.**
- **Even the intact kernel is latency-bound on Metal:**
  - one threadgroup is too narrow above ~250 chunks;
  - a dispatch per substep costs ~1 µs each, plus a device-memory exchange.
- **Per awake house-1story on M3:**
  - today: 1,264 substeps × 25 µs = 32 ms;
  - intact kernel: × 9.4 µs ≈ 12 ms;
  - intact kernel plus sliver elimination (÷4.5): **≈ 2.6 ms**.
- **Phase 1 gate** (intact floor ≤ 1 µs): **not met** on Metal with this kernel. The architecture there is therefore:
  - a few awake explicit buildings per frame;
  - everything else asleep or quasi-static behind certificates;
  - slivers eliminated.

### A4. GPU frame times on pack towns (M3 Max, true step, adaptive mode)

Run with `stress-gpu-fps --config realtime --gpu-only --frames 30 --town house-1story:N:RAMS` under `STRESS_METHODS=established`. The GPU world does not run layer contact yet.
- **Idle:** the fresh intact town under gravity only.
- **Destruction:** the first RAMS houses each rammed by a 400 kg box at 12 m/s.
- Frame times are complete `GpuWorld::step_frame` calls, host included.

| Town | Chunks / bonds | Regime | First frame | Median | Worst | Broken bonds | Substeps per frame |
|---|---|---|---|---|---|---|---|
| 16 houses | 5,104 / 14,032 | idle | 15.7 ms | 2.0 ms | 3.7 ms | 0 | 434 |
| 16 houses | | 1 rammed | 42 ms | **306 ms** | **4.5 s** | 733 | 831 |
| 64 houses | 20,416 / 56,128 | idle | 51 ms | 2.2 ms | 3.7 ms | 0 | 434 |
| 64 houses | | 4 rammed | 94 ms | **2.3 s** | **40 s** | 3,249 | 956 |
| 100 houses | 31,900 / 87,700 | idle | 93 ms | 3.4 ms | 5.3 ms | 0 | 434 |

- **Idle is already cheap.** 100 intact houses cost 3.4 ms median, with sleeping and quiet islands, but the startup frame is 93 ms.
- **Destruction is 2–3 orders of magnitude over budget,** and it scales with the number of struck buildings. One rammed house among 16 takes a 4.5 s worst frame. The breakdown is in A5.
- **100 houses, 4 rammed:** 5.8 s median, 94 s worst frame (5,311 bonds broken).
- **parking-garage ×4 is not an idle scene.** Over strength at rest (A2), it collapses under self-weight: 6,328 bonds broken, 1.1 s median, 22 s worst frame. Its rammed run then **crashes** with a 4.87 GB `contact state` buffer, over wgpu's 4 GB limit (debris pair state grows without bound).

### A5. Where destruction frames go

**Standalone GPU world, one rammed house** (`STRESS_GPU_TIMING=1`, 30 frames: 10.3 s in all, 8.7 s of it GPU):

| Kernel | GPU time | Per dispatch |
|---|---|---|
| `contact_forces` (debris pairs, up to 6,808) | 2.7 s | 89 µs |
| `island_frame` (one substep per dispatch inside the contact pipeline) | 2.4 s | 78 µs |
| `impactor_integrate` + `contact_sums` | 0.8 s | |

Host side: 225 splits (+106 resumed), 0.7 s split, 0.3 s readback.

- In the standalone world the stress solver resolves every debris–debris contact at the stress substep, about 830 times per frame. That is the oracle's ground-truth mode, not the real-time architecture.
- In production PhysX owns debris contact, and the stress solver substeps contacts only inside impact islands.

**Engine-coupled GPU solver** (`stress-gpu-coupled-fps --gpu-only`; contacts are the engine's impulses; ram on frames 0–2, then a push):

| Scene | Regime | Stress step | Median | Worst | Substeps per frame |
|---|---|---|---|---|---|
| house-1story | idle | reference | 919 ms | 942 ms | 37,484 |
| house-1story | idle | true | 32.5 ms | 33.0 ms | 1,264 |
| house-1story | idle | true + sleep | 1.6 ms | 1.9 ms | 1 |
| house-1story | destruction | true | 33.2 ms | 35.5 ms | 1,264 |
| house-1story | destruction | true + sleep | 36.1 ms | 40.3 ms | 1,264 |
| wall 16×2×8 | destruction | true | 15.1 ms | 16.8 ms | 452 |
| wall 40×2×20 | destruction | true | 17.3 ms | 18.7 ms | 453 |

- **One awake house costs about 33 ms per frame:** 1,264 true substeps × about 25 µs. That is the per-substep latency floor (A2), whatever the house's work.
- **The levers that close it multiply:**
  - per-substep latency (intact kernel, target ≤ 5 µs);
  - substeps per frame (slivers, ×2–4 by A1);
  - how many buildings are awake (sleeping already brings idle to 1.6 ms).
- **Debris contact must stay with PhysX:** impact islands only (Phase 2).

### A7. A Shardwright building with a real L0/L1/L2 hierarchy

The compendium's example is the 1,182-chunk two-storey building from Shardwright:
- 48 L0 components, 618 L1 fragments, 1,182 L2 chunks;
- 3,657 L2 bonds, 23 of them anchors.

**Import.**
- The `.fracphys` file is exported to `shardwright-stress/1` JSON by a small converter on Shardwright's `frac-io`: fragments of levels 0–2 with their parents, and L2 bonds with area, frame, second moments, joint kind and rebar.
- `stress-ref/src/shardwright.rs` reads it, and `scene_pack::import` dispatches to it.
- Each chunk keeps its ancestry as groups: `member:<L0>`, `l1:<id>`, and its role.
- 80% of the L2 fragments are compounds of 2–16 convex hulls (non-convex chunks), while an oracle chunk holds one hull. Chunks are therefore equivalent-inertia boxes: the asset's centre of mass, principal axes and principal moments per unit mass.
- In production the stress solver needs only mass, inertia and bonds, because PhysX owns the compound shapes and contact. Compound chunks in the oracle (for its standalone world) are a separate task.
- The asset's L2 mass, 115.6 t, matches the reference solve's anchor reactions: 1.136 MN against a weight of 1.134 MN.

**Found while importing:** the oracle's `ConvexHull::new` is not robust to f32-coplanar input. A clean 12-point Shardwright hull re-hulled after a translation alternates between 15 and 14 faces, with volumes differing by 2.6%. Separate task.

**Measurements:**

| | Value |
|---|---|
| True step | 570 substeps per frame (reference: 2,212), set by a 1.4 kg brick wall sliver (100% of the top mode) |
| Utilization at rest | max 0.50; 0.1% of bonds above 0.4; none above 1. Well calibrated: certificates can pass here. |
| Condensation by L0 members (48) | 62% of DOFs kept, gravity PCG 1,816 → 1,491 iterations, 4.3 MB, explicit step ×1.00 |
| Condensation by L1 (618) | 96% kept, ×1.00 |
| Coordinate bisection, parts of 64 / 256 | 57% / 34% kept, step ×1.30 |
| Slivers eliminated: 8 / 16 / 32 | step ×1.34 / ×1.45 / ×1.63 |

- **With a real member hierarchy, member condensation is exact but modest:** it removes 38% of DOFs. Walls and slabs are bonded to their neighbours along whole edges, so most of their chunks are boundary.
- **It does not raise the explicit step.** Its value is precomputed intact statics and location-aware bounds, not dynamics.

### A8. `patch_after_damage` A/B (prerequisite of an exact cold-bond path)

The full entry is in `IMPROVEMENTS.md`.
- 87/91 gated metrics both ways, with no regression.
- Catalogue wall time 178 → 156 s.
- Broken bonds move by under 4% except on b8_frame_sudden (23 → 11), a chaotic collapse whose reference ensemble already admits 17–29.
- Adoption is a model change awaiting review.

### A9. Null results: the mechanism, and when to revisit

A change that shows no gain is not rejected until the reason is known. It may act on
something that is not yet on the longest path, and becomes worth having once other
costs fall. Each null or negative result here, from this branch or others:

| Idea | Result | Mechanism (measured) | Revisit when |
|---|---|---|---|
| Partition / member condensation for the explicit step | step ×1.00 (packs, Shardwright members) | It eliminates 0 of the top-mode carriers (0/2 house-1story, 0/1 Shardwright): those slivers are always boundary chunks | **Already pays after sliver elimination:** house-1story 16 slivers ×4.51; + parts of 32–128 ×5.22; + parts of 256 ×7.65 (12% of DOFs kept). On the Shardwright building the gain stays at ×1.48: the next carriers (column pieces) are boundary too |
| Member condensation for statics | Gravity PCG 1,816 → 1,491 iterations (Shardwright); 769 → 323 (house, parts of 256) | Keeps the boundary graph's diameter, which sets block-Jacobi PCG's count | When the quasi-static tier (T1) and influence bounds are on the path: condensed intact statics as a precomputed GEMV |
| Eliminating one sliver | ×1.00 (house-1story, Shardwright ×1.01) | The top of the spectrum is a cluster: house-1story needs about 16 chunks treated for ×4.5. This reconciles `8c2851e` (mass scaling: "top mode spread") with A1 (one beam carries 100% of the top mode): the next modes are nearly equal | Any per-chunk lever (mass scaling, multirate, elimination) must treat the cluster, not the top chunk |
| Per-island stepping | ×1.00 on single-island packs | One island, one step | It pays on multi-island scenes: neighbourhood ×1.37, skyline ×1.29, skyline-stable ×1.09; more in towns that mix assets (brick-building 179 against a house's 1,264 substeps) |
| Damping off | ×1.02–1.09 | The top mode's own damping ratio is 0.02–0.09 | The *certified* step's damping (β_max · ω) costs ×3–6 on houses and ×1000+ on steel and stone packs (A1); a certified ρ(M⁻¹C) recovers it |
| Rotational inertia ×4 | ×1.0–2.1 | Top modes are partly rotational on slivers | After sliver elimination, re-measure (the remaining top modes may be translational) |
| Intact kernel, whole segment in one threadgroup | slower than a dispatch per substep above ~250 chunks (house-1story 12.4 against 9.4 µs) | One 256-thread group runs every bond: about 3.4 bonds per thread in series | A multi-group intact kernel, or CUDA cooperative launch (one SM per partition) |
| Cold-bond exact variant on the CPU oracle (`perf/oracle-runtime`) | 11% slower | CPU: an extra branch on a bond evaluation that is already about 100 ns | GPU: the cost is latency and code size (A2), and the intact-only path gains ×2.5–6 (A6). Not rejected for the GPU |
| Influence-line wake test (`perf/oracle-runtime`) | not pursued | No catalogue scene runs adaptive, so the oracle has no idle cost to save | GPU T0/T1 tiers (Phase 3) |
| Reduction cadence for free islands (`perf/oracle-runtime`) | < 1.5% of the oracle's time | The oracle has no barriers | GPU: each reduction is a barrier (about 110–130 ns) per substep on Metal |
| `frame_contact_step` (`perf/oracle-runtime`) | 7–20× *more* substeps | Its Gershgorin contact bound is looser than the global lattice bound | Not a lever: in the engine-coupled path the stress step has no contact term outside impact islands |
| Class A frame-level skip of quiet islands | Deferred | Profiled, 100 intact houses idle (60 frames, ~5 ms median): GPU 1.3 ms per frame, of which `island_frame` (quiet islands counting 434 substeps) is 0.65 ms; host motion download (`sync_motion` after every step, ~2 MB) 2.0–2.3 ms; frame tails (settled fatigue, settle countdown) 1.2–1.5 ms; readback 0.3 ms. The skip removes at most the 0.65 ms | After the host work goes: no motion readback without a consumer (the coupled path needs only fractures and events), settled fatigue only on watch-listed bonds. The skip is then the largest idle term |
| Coupled "true + sleep" in destruction | 36 ms median against 33 ms for "true"; sleeping saves nothing while loaded | Traced frame by frame: (1) the push changes the loads every frame, so the house stays active; the earlier 60-frame run's cheap half was the timer settle (`active_time` 0.5 s) firing at frame 30. (2) Adaptive mode dispatched `wide_wake` on every wide substep, but no wide island is ever settled (settled islands are built narrow; the micro tier lists `SETTLED_WIDE` as uncovered): an empty dispatch, about 3 µs per substep | **Fixed:** `wide_wake` only when a wide island is settled. 35.8 → 33.6 ms, bit-identical (quick gate 13/13; micro-tier GPU snapshots unchanged). The remaining +4% (0.9 µs per substep) is the per-chunk load recording that wake decisions need. A settling *certificate* (Phase 3) is what lets a loaded-but-safe building sleep before 0.5 s |

## B. Review of the two documents

### Compendium

| Idea | Verdict | Why |
|---|---|---|
| Regime split by time scales | Principle adopted; rule replaced | The oracle's regime map: `t_c ≤ T_w` misses punch-through, which is a critical impact speed per wall type (10–20 m/s). |
| Guyan condensation | Exact statics; no explicit-step gain by partitions (A3) | Useful for GEMM-shaped intact solves and over-size islands. Sliver elimination is the dynamic variant worth having. |
| Craig–Bampton, mode acceleration, Ritz | Deferred | Only if condensed dynamics pay. |
| Influence-line / modal "definitely safe" bounds | After E_safe | Location-aware; still certifies on buildings with overloaded joints (A2). |
| SMW reanalysis, VDM | Deferred | f32-fragile. The oracle's quasi-static cascades already use direct solves. |
| Sequentially linear cascades | Deferred | A model change in cascade order, to be judged with `fidelity.py`. |
| Energy-balance sudden loss; limit analysis | Screens only, later | |
| P–I / SDOF | **Tier router, never the damage result** | The oracle's speed sweeps are an empirical P–I boundary. |
| HHT-α | Oracle switch; GPU tier after multigrid | κ improves only about 40× at 1/60 s; f32 residual about 6%. |
| VBD / AVBD / XPBD | Rejected for stress | Bond forces are unconverged multipliers. |
| Multirate | Asset or sliver treatment first (A1: ×1.9–4.3) | IMEX interface is research. |
| Corotational bonds | Fidelity track | Catenary arrest. |

### Speed-of-Light v2

| Idea | Status | Verdict |
|---|---|---|
| True step per island | GPU: global, estimated | Per-island n_i; certified damping bound (A1) |
| Persistent on-chip blocks | Narrow islands in device memory | **Intact on-chip kernel first:** the 8.4 µs per-substep floor × about 1,300 substeps ≈ 11 ms is the binding cost on Metal |
| Cold/hot bonds | Not done | Needs `patch_after_damage` and `exact_rate_filter` adopted |
| Neighbour-flag partitions, cooperative launch | Impossible on macOS 14.4 | CUDA phase |
| Certificates A/B/C | Heuristics today | Class A frame skip; E_safe where A2 allows it |
| Smoothed-aggregation multigrid | Not done | Needed for big quasi-static islands and any GPU implicit |
| GPU connectivity | Host mirror | Moved up: host round trips sit on every cascade |
| Scene fixes | Import fixed (A1) | Calibration open (A2) |

### What both miss

- **The GPU is gated against `established` contact while the oracle's truth is `proven`.** The GPU world rejects `layer_contact` scenes.
- **The engine handover.** Through PhysX (one correction), no configuration punches through (`14352f570`). Only stress-owned impact islands reproduce fast-versus-slow loading, and the GPU coupled solver has none yet.
- Host round trips per split.
- The GPU clock ramp after idle.
- Chaotic outcomes need ensemble gates.
- Layer contact's unbounded LIFO cohorts are hostile to the GPU.

## C. Target architecture

| Tier | When | Method |
|---|---|---|
| T0 asleep | Certified: class A unchanged inputs, class B fatigue schedule, class C E_safe or influence bounds | Zero work |
| T1 quasi-static | Slow and sustained loads, settling | GPU PCG (small), multigrid (big), offline f64 prestress |
| T2 structural dynamics | Below the calibrated critical impact speed, support loss, sway | Explicit intact kernel at the true step |
| T3 explicit full law | Hot bonds, damage, punch-through and spall | Full-law island kernel; local windows later |

## D. Roadmap, revised by the measurements

What the measurements (A1–A8) change:

- **Destruction frames in the standalone GPU world are dominated by debris contact at the stress substep (A5).** In production that contact is PhysX's. The real-time path is therefore the engine-coupled solver, and its missing piece is stress-owned impact islands. That piece is also what makes fast loading (punch-through) right (`tier2_velocity`).
- **The cost of one awake building is its true substeps times the per-substep latency** (A5, A6): 1,264 × 25 µs ≈ 32 ms for house-1story on M3. Three measured levers multiply:

  | Lever | Factor | Status |
  |---|---|---|
  | Intact-only kernel | ×2.5–6 | measured with the existing intact kernel |
  | Sliver elimination | ×1.6–4.5 | a step and model change to prove in the oracle |
  | Per-island step | ×1 on single buildings; pays in mixed towns | |

  Together they bring an awake house to about 2–4 ms. So a few awake buildings fit per frame on M3, and everything else must sleep or be quasi-static.
- **Idle is already cheap** (100 intact houses 3.4 ms median, one coupled house 1.6 ms), apart from the startup frame (93 ms).
- **Certificates can pass on well-calibrated buildings:** the small packs and the Shardwright building (max 0.50 at rest). The multi-storey packs are over strength at rest and need their calibration fixed first. Shardwright's own fix is a design check that reinforces bonds to 2× their self-weight load.
- **Member condensation is exact but gives no explicit-step gain** (A3, A7). It moves to later, as an intact-statics and bounds tool.

| Phase | Content | Gate |
|---|---|---|
| 0 | Baselines and blockers | done: A1–A8, import fix, tools |
| 1 | **GPU impact islands in the coupled solver** (port `world_coupling` `select_islands` and stress-owned contacts), with debris contact left to the engine | b5/b7 speed sweeps through the GPU coupled path reproduce push-over against punch-through (`tier2_velocity` cases); destruction frame time measured idle and at peak |
| 2 | **Awake-building cost:** adopt `patch_after_damage` (review); intact island kernel with escalation to the full law; sliver elimination as an oracle switch, then on the GPU; per-island step | `fidelity.py` on the switch; one awake house ≤ 4 ms on M3 |
| 3 | Faithful sleeping: class A frame skip, E_safe and settling certificates (shadow first); the startup frame | Never contradicted in shadow; first frame visible and bounded |
| 4 | Asset calibration: a design check for the packs (as Shardwright's), or their materials | No bond over strength at rest |
| 5 | GPU connectivity and splits (no host mirror inside a frame); contact-state memory bounded (the 4.87 GB crash) | Cascades with no host round trip |
| 6 | Proven oracle methods on the GPU (contact crushing, layer contact with bounded cohorts) | GPU gate against `proven` |
| 7 | Impact router (critical speed / P–I maps); multigrid; HHT; condensed intact statics and influence bounds | Each by its IMPROVEMENTS class |
| 8 | CUDA host at `PxgDestructionRuntime`; 4090 qualification | AGENTS.md idle plus peak complete-step rules |

**Open bugs found here** (separate tasks):
- micro tier: `coupled_impulse` and `coupled_sleeping` fail on the integration base itself (GPU 4 fractures against the reference's 1), before any change here;
- the oracle's convex hull is not robust to f32-coplanar input (A7);
- GPU `contact state` buffer overflow on collapse (A4);
- the certified step's damping term (A1).
