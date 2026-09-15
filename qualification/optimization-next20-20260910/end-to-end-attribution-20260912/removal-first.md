# Removal before kernel tuning — 2026-09-12

**Superseded ranking:** the [current work census](removal-work-census.md) now places reducing dominant anchored-component iterations first. The estimates and initial audit below are preserved as history.

The next priority is to avoid processing unchanged physical state and to remove
redundant fragment lifecycle work. Arithmetic experiments N21/N22/N11 are paused;
17/20 experiments are closed. This audit adds no completed experiment or speedup.
N13 remains the selected numerical policy. N20 is a separately retained CPU
capacity improvement; their compatible composition still needs qualification.

## What is already implemented

- Native contact input, stress, material verdicts and topology run on the GPU.
  The stress solver borrows solved contact views and joins producer streams;
  there is no CPU stress-input round trip to remove.
- Rigid clusters own motions; intact chunks are not separate simulated bodies.
  Shape geometry persists through fragmentation.
- Ordinary actor/query publication is already deferred and combined across
  correction. CPU body/contact registration still has to precede corrected
  collisions. Moving those calls to a GPU kernel alone cannot satisfy their
  CPU object and scheduling dependencies.
- No-live-bond components already bypass stiffness solving. Factors and some
  topology-independent inverses are reused. Topology rebuild is already gated
  on actual changes.
- Exact-input settled certificates already skip component iteration. They are
  independent of PhysX sleeping, which is enabled.

These are existing features, not new optimization proposals. Failed N19 mapped
publication and N18 handshake changes also rule out simply assuming fewer copies
or waits must improve the step.

## The opportunity around unchanged islands

`StressNativeSettled.cuh` accepts a reusable result only after a zero-update warm
solve verifies the stored, rounded bond forces at the required tolerance. It
checks topology generation, tolerance, iteration cap, and every node's six input
float bit patterns. Unaffected old components can preserve certificates through
a topology update. This is a stronger proof than merely observing no fracture.

However, `PxgDestructionRuntime::advance` prepares chunk loads and routes contacts
before that comparison. The solve submission still enters initialization,
reduction and status phases; individual kernels have skip guards. Material and
transaction preparation also follow. A zero iteration count therefore does not
mean zero destruction work. Kernel presence alone does not establish that every
thread performs useful work: measure guarded execution and launch overhead.

The proposed architecture is GPU-owned lists of components requiring work,
with separate validity for equilibrium, materials and topology. Producers should
record exact dependency changes while already writing inputs. An all-clean
conditional graph can then avoid entire phases, and mixed worlds can process
only affected components. Avoid adding a CPU scan or another full-world GPU
comparison to discover what the producer already knows.

The dependency contract must cover disappearing contacts as well as new ones;
changed gravity, orientation, angular velocity, mass/COM, ownership, topology,
material parameters, solver settings and timestep; and new inputs from the
correction pass. Chunk load preparation uses local gravity and centrifugal
acceleration, so translation alone does not necessarily change these loads.
Surface torque, virial and contact rate can change even when the solver's net
force input does not. They require their own material invalidation.

**Equilibrium reuse does not authorize skipping damage.** Bond health and chunk
crush may advance under constant stress. Initially skip material work only with
a proof of zero increment and unchanged dependencies. Reusing an invariant stress
measure while still integrating damage is a separate, potentially useful path.
Do not extrapolate a future fracture tick or change rounding/threshold crossing
without separate physical qualification.

## Ranked experiments

The companion `removal-first.json` records evidence, mechanism, scenario coverage,
estimated whole-step milliseconds, confidence, cost and support/refutation tests.
All ranges below are low-confidence planning hypotheses, not measured savings;
they overlap and must not be added.

| Priority | Work to remove | Initial savings hypothesis | Decisive next evidence |
|---|---|---|---|
| 1 | Repeated CPU body/shape resolution and registration preparation within one validated fracture transaction | 0–20 ms at a large fracture peak; 0–5 ms heavy mean | Count duplicate resolution, allocation, retirement and migration calls; preserve required contact registration and compare complete fracture ticks |
| 2 | Load preparation, comparisons and solve setup for exactly unchanged certified components | 0–1 ms warm idle; 0–10 ms mixed active/settled steps | Count valid/invalid certificates and actual visited nodes per first/correction pass; demonstrate producer-side dirty detection avoids more work than it adds |
| 3 | Whole-world topology/hierarchy rebuild when only a few old components change | 0–15 ms localized fracture; little benefit under simultaneous world-wide changes | Compare affected old nodes/bonds against nodes/bonds visited by rebuild at each scale |
| 4 | Repeated material geometry and zero-damage evaluation | 0–5 ms large active/settled steps | Separate immutable geometry, stress evaluation and damage integration; measure zero-damage coverage and unchanged fracture tick/health/crush |
| 5 | Repeated numerical factor construction across identical authored structures | 0–10 ms large cold/initial-impact steps; possibly zero warm benefit | Identify exactly equal operators and boundary conditions, account for lookup/storage and copy-on-change |
| 6 | Tune the remaining regular active arithmetic with Tile C++ | Unestimated until the surviving arithmetic budget and packing cost are measured | Integrated application A/B, original equilibrium/material gates, graph/correction compatibility and complete-step timings |

Priority 1 has the strongest current application evidence. Priorities 2–4 need a
work census before their savings can be ranked numerically with confidence.
The architectural benefit of separate equilibrium/material/topology validity is
also explicit: it enables independent removal without conflating stable forces
with stable damage. A performance-neutral change may be retained for that
concrete benefit after quality and regression checks; call it architecture work.

## Measurement evidence and limits

N20 proves one unnecessary CPU copy was significant in a cold fragmented scene.
The node lifetime array now reserves to the existing node capacity. On the large
restored late-debris case, whole-step mean is **382.883 ms**, versus
**422.663/426.525 ms** before/after controls: 9.82% versus their pooled mean in
that cohort. CPU lifetime-array recreation samples drop 225/220 to zero; GPU
union time stays approximately 118 ms in separate diagnostic captures.
This does not imply that all fragment CPU work is removable.

| Workload | Control before / N20 / control after mean ms | Interpretation |
|---|---:|---|
| Restored bridge64 cold | 8.811 / 8.745 / 8.895 | Small structural control |
| Restored dense12 cold | 31.128 / 31.329 / 31.284 | No improvement |
| Restored tower64 cold | 108.358 / 108.434 / 108.486 | Numerical work remains dominant candidate target |
| Restored city256 intact idle | 63.720 / 65.998 / 67.906 | Drift; no idle gain established |
| Restored city256 initial impact | 247.735 / 240.893 / 251.125 | Modest event result; inspect full repeated evidence |
| Restored city256 post impact | 145.589 / 145.421 / 150.555 | Mixed/small effect |
| Restored city256 cascade | 197.209 / 197.229 / 198.858 | No material gain |
| Restored city256 fragmented loaded | 306.688 / 292.395 / 308.063 | Fragment lifecycle exposure |
| Restored city256 late debris | 422.663 / 382.883 / 426.525 | Repeated verified cold-scenario benefit |

Each restored arm has 20 full ticks. All 52 scenario means, maxima, deadline
misses, command/physics-plus-destruction/completion stages and excluded restore
costs are in [N20 final qualification](n20-final.md). Cities contain 11,100,
28,416 or 113,664 chunks at 25/64/256 buildings, up to 229,376 bonds.

Continuous 600-tick heavy means are 54.378–54.444 ms for N20 versus
54.466–54.517 ms controls, with **519/600 60 Hz misses in every run**. Candidate
heavy maxima are 189.448/194.894 ms versus control maxima 192.537–216.550 ms;
there is no consistent peak gain. Idle means are 1.457–1.541 ms versus
1.481–1.612 ms controls. Detailed idle maxima, setup and stage evidence remain
in [the warm report](n20-followup.md). Cold and warm results are separate workloads.

The warm first-fracture profile exposes roughly 34.88 ms instrumented allocation
thread CPU and 13.888 ms lower-rate migration thread CPU. These overlap other
scopes and include instrumentation: they are not subtractable wall-time budgets.
Heavy GPU-to-CPU traffic grows from 7.74 MB / 16 copies at step 81 to 24.52 MB /
78 copies at step 82 and 35.39 MB / 110 copies at step 179. Sleeping idle has
only 1,288 bytes / four copies at the examined steps. The source and consumer
audit must explain each retained transfer; volume alone did not make N19 a win.
See [dataflow evidence](dataflow.json) and [N19 rejection](n19-result.md).

The 52 physical snapshots deliberately discard disposable solver certificates.
Their labels ending in `warm` describe the saved physical scene, not a restored
warm execution cache. Keep them as cold reconstruction/quality tests. Add work
census to ordinary continuous trajectories for unchanged-island reuse; never
hide a priming solve outside the tick timer and claim the same workload improved.

For each first/correction pass, record total/affected/visited components, nodes
and bonds; certificate hit/miss reason; material recompute/damage-only/zero-damage
counts; topology affected-old versus rebuilt counts; and CPU allocated,
migrated, published and repeatedly resolved objects. Cover idle, first impact,
removed contact, reawakening, sustained damage, localized fracture among intact
neighbors, many small islands, and mixed-size debris. These counters are a next
diagnostic implementation, not already collected evidence.

## CUDA Tile availability and fit

The installed `nvcc` and `tileiras` are 13.4.59. An isolated FP64 Tile C++ kernel
**compiles successfully for sm_120** with the exact command and hashes in
`out/end-to-end-attribution-20260912/tile-availability/receipt.json`:

```bash
/usr/local/cuda-13.4/bin/nvcc --enable-tile -std=c++20 -arch=sm_120 \
  -ccbin /usr/bin/g++-12 -c \
  out/end-to-end-attribution-20260912/tile-availability/probe.cu \
  -o out/end-to-end-attribution-20260912/tile-availability/probe.o
```

This is compile-only, not GPU execution or solver qualification. The ongoing
counter collector retains exclusive GPU use. A source/build scan found no
`__tile_global__`, `cuda_tile.h` or `--enable-tile` in production CUDA/build files.

Tile IR is the intermediate representation; Tile C++ is a native frontend we
can use. The compiler maps tile operations onto threads and suitable hardware.
CUDA supports Tile and conventional SIMT together, with C++20 required for the
Tile header. A separate helper translation unit can leave the engine's C++17
code alone. Current Tile device code cannot reference definitions outside its
translation unit, even with relocatable compilation enabled.
[NVIDIA compilation documentation](https://docs.nvidia.com/cuda/cuda-compiler-driver-nvcc/tile-compilation-in-cuda.html)
and [Tile C++ API](https://docs.nvidia.com/cuda/cuda-tile-cpp-api-reference/index.html).

NVIDIA's [Tile optimization guide](https://docs.nvidia.com/cuda/tile-ir/latest/sections/optimization_guide.html) confirms compiler-controlled instruction selection, pipelining and resource allocation, with advisory target-specific hints. Its [programming model](https://docs.nvidia.com/cuda/tile-ir/latest/sections/prog_model.html) also supports pointer-based gather/scatter; irregular topology is not by itself a reason to exclude Tile. We still need to measure the cost of expressing our small blocks, topology traversal and convergence control in that model.

Tile does not automatically rewrite the existing solver or infer physical input
invalidation, CPU object ownership or damage semantics. Our assessment is to
first remove unused work, then test Tile for regular batches such as local block
operator applications. Sparse gathers, variable iteration counts, small 6×6
blocks and packing overhead may limit benefit; this is a hypothesis to test,
not a reason to reject Tile without measurement.

sm_120 and FP64 are supported. That does not guarantee Tensor Core acceleration
for our chosen operations. NVIDIA documents fallback implementations for tile
shapes and numerical changes with compiler, target or matrix accumulation
configuration. Preserve force/moment, equilibrium, damage, motion and fracture
quality gates, and measure time to the required convergence including all data
preparation and packing. [NVIDIA Tile compatibility and numerical guarantees](https://docs.nvidia.com/cuda/tile-ir/13.4/sections/stability.html).

## Preserved unfinished work

N21's revised hierarchy checker passes its independent numerical comparisons,
but the unchanged control fails hierarchy-cycle initcheck with 406,228 findings
in diagnostic device-to-host reads. The original bit-comparison failure and the
new control failure remain preserved; neither is waived. N22/N11 are built but
unrun. Counter parent 390717 has resumed; coordinator 490321 is terminal.
CPU and graph attribution qualify 52/52, while ordinary significant-kernel
counters currently qualify 41/52 and continue. Do not call expanded ordinary
counter coverage complete. No runtime or installed SDK change accompanies this
audit or the Tile capability probe.
