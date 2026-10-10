# stress-gpu plan

The goal is a GPU stress solver with the same model and features as `stress-ref`. It must match the reference's accuracy, run in real time at massive scale, and use f32 throughout.

The kernels are written in Slang. They run on Metal natively and on WebGPU through WGSL. CUDA is not a target.

The design follows the colleague's speed-of-light analysis ("GPU Stress Solver: Speed-of-Light Analysis v2"). It is adapted where Metal and WebGPU differ from an RTX 4090. Each adaptation is listed under "Departures from the analysis" with its reason.

## Accuracy contract

| Gate | Check | Pass |
| --- | --- | --- |
| P1 kernel parity | Every GPU kernel against the f64 reference function, from identical random inputs (intact, cracked, crushed, sliding, rebar, buckling) | Within a bound derived from f32 rounding of that function's operations |
| P2 trajectory | Same scene, same substep, same substep count: GPU against `ReferenceSolver`/`World` in f64 | State within the f32 propagation bound; identical events (kind, bond) |
| P3 oracle | `stress-ref compare` on the GPU's `stress-observation/1`, against analytic values and goldens | Every gate the reference passes |
| P4 determinism | Repeated runs on the same device | Bit-identical state and events. There are no float atomics. |
| P5 behaviour | The showcase assertions | All pass |

**Two step modes:**

- **Reference step:** the reference's own `substep_dt`. Use it for P2 and P3 parity.
- **True step (real time):** each island's step is set from λ_max of M⁻¹K, its damping ratio and a safety factor of 0.9. This is a step change, judged by the reference's own refinement at the GPU's step: the reference can run at any dt, so the comparison stays like for like.

## Architecture on Metal and WebGPU

- **Island kernel.** One threadgroup per island, where an island is a cluster or a contact-coupled group of clusters. It runs every substep of a segment inside one dispatch, with threadgroup barriers between phases. That removes the 1.5–3.5 µs a dispatch costs per substep. The reference's per-substep cluster reductions become threadgroup reductions: net load, rigid acceleration, drift removal.
- **Substep phases:**
  1. Bonds: evaluate the joint law and write the 9-float body-frame loads.
  2. Chunks: fixed-order CSR gather, external and frame loads, then the central-difference update by support type.
  3. Cluster: rigid integration and drift removal.
- **Deterministic.** There are no float atomics. Sum orders are fixed: CSR in bond order, and reductions on a fixed tree.
- **Hot and cold bonds.** An intact bond below the utilization threshold takes the linear path, which is exact when nothing can change. Damaged bonds and bonds near the threshold take the full joint law.
- **Segments.** The host advances in segments: frame ends, sample times, scripted-event times, and early stops when a bond disconnects (a split is due). Loads that vary over time come from per-substep tables (scripted loads, blasts) evaluated on the GPU.
- **Topology on the host first.** The host keeps a `ReferenceSolver` mirror of clusters, bonds and structures. Rare operations reuse the oracle's exact code on the mirror, after the GPU state is downloaded into it: `split_cluster`, removals, refinement, static solves. They move to the GPU (union-find, segmented reductions) once they are correct.
- **Big islands.** Metal has no cooperative launch and no grid-wide barrier. So a big island runs in one large threadgroup with device-memory state, or with a dispatch per substep, whichever measures faster. Cross-threadgroup spin barriers are a measured experiment only, because forward progress is not guaranteed.
- **Quiet islands are skipped** behind certificates, not timers: settled with unchanged inputs (class A), closed-form fatigue (class B) and energy bounds (class C).

## Milestones

| # | Milestone | Gate |
| --- | --- | --- |
| G0 | Toolchain, intact explicit substep, native viewer | Done: displacement error under 1e-5 relative to f64 over 4,000 substeps |
| G1 | Island kernel: all substeps of a segment in one dispatch; benchmark against a dispatch per substep | P2 unchanged; substeps per second measured on growing scenes |
| G2 | Full joint law on the GPU (damage, crushing, contact patch, friction, rebar, DIF, fatigue, Weibull, buckling); events | P1 on random states; P2 on scenes with fracture and no splits |
| G3 | Free clusters (rigid motion, frame loads, drift removal); splits through the host mirror | P2 on splitting scenes: same events and fragments |
| G4 | World loads: point forces, pressure, blasts, supports, removal events, replacement loads; probes; observation output | P3 on every benchmark without contact |
| G5 | Contacts: impactors, ground, chunk pairs (penalty contact, then layer contact) | P3 on the impact benchmarks and showcases |
| G6 | Solve modes: quasi-static, implicit and adaptive on the GPU (block PCG for small islands, smoothed aggregation for big ones) | P3 in every mode |
| G7 | True step, per island; certificates for sleeping and waking | Step-change bar; idle scenes cost zero substeps |
| G8 | Scale: scene packs (house, garage, park, skyline), town scenes, GPU topology | Real time at measured bounds; accuracy gates still pass |

## Departures from the analysis

- **No cooperative launch or grid barrier on Metal or WebGPU.** That rules out the analysis's multi-SM neighbour-flag partitions as a correctness-safe design. Big islands are measured on single-threadgroup and dispatch-per-substep designs first.
- **Threadgroup memory is 32 KB on Apple GPUs, and 16 KB by default on WebGPU.** On-chip state is reserved for small islands. Larger ones rely on the device cache, which is large on Apple silicon.
- **Fast math is disabled in the parity builds** (Metal compiles with fast math by default), and the production build is measured against them.
- **The reference step stays available** so every parity gate compares like for like. The true step is a separate, validated mode.
