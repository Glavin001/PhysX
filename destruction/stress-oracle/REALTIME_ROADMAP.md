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

## D. Roadmap

| Phase | Content | Gate |
|---|---|---|
| 0 | Baselines and blockers: done here (A1–A4, import fix) | |
| 1 | `patch_after_damage` and `exact_rate_filter` A/B; frame-level class A skip; intact kernel with escalation; per-island n_i | Intact floor ≤ 1 µs and 100 houses ≤ 3 ms → explicit plus sleeping |
| 1b | Sliver elimination (A3) on the GPU's step | Step gain at bounded fidelity cost |
| 2 | GPU impact islands; GPU connectivity and splits | The `tier2_velocity` cases through the GPU path |
| 3 | E_safe and settling certificates (shadow first) | Never contradicted |
| 4 | Proven methods on the GPU (layer contact with bounded cohorts) | GPU gate against `proven` |
| 5 | Impact router (critical speed / P–I maps) | `fidelity.py` |
| 6 | Multigrid; HHT; GPU implicit | |
| 7 | IMEX windows; cascade screens; corotational | |
| 8 | CUDA host at `PxgDestructionRuntime`; 4090 qualification | AGENTS.md idle plus peak complete-step rules |
