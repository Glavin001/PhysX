# Explicit impact step: performance handoff

Branch `perf/explicit-step` (worktree impact-perf), on `feat/impact-capacity`.
Goal: <= 2 ms per impact evaluation (the owner's target), every dispatch < 100 ms,
FP32, no change to the physics: the dump parity, energy and hash tests below must
still pass bit-for-bit or within their derived tolerances.

## The kernel

`physx/source/gpudestruction/src/PxgDestructionImpactExplicit.cuh`. Each patch is
one threadgroup of 512 threads (`EX_THREADS`), integrated by symplectic Euler over
rigid chunk nodes and joints (RBSM). The window is one tick (16.7 ms). A substep
runs four `__syncthreads` phases:

1. Joint gather.
2. Contact rows, with the joints away from rows running beside them.
3. Row gather.
4. The joints at rows' nodes.

## What was done (perf/explicit-step, 2026-10-08), and what each bought

Cannonball first contact, window on a shared GPU: 9.47 ms -> about 2.75 ms.
Lab distributions are at the end of this section.

**1. Substep from a rigorous Collatz-Wielandt bound.** `exFinish` replaced Gershgorin
with lambda_max(S) <= rho(|S|) <= max_i (L x)_i / x_i, where L >= |S| entrywise:
- each node's diagonal block is assembled before taking absolute values;
- the off-diagonal joint blocks are taken in absolute value;
- each node is lumped to translation and rotation.

8 power-iteration products start from x = 1, which is the Gershgorin bound. Every
iterate is a valid bound, and the 0.9 safety factor is kept. The joint blocks are in
closed form, because the force stiffness is isotropic. Effect:
- Cannonball full island: omega 3.69e4 -> 2.92e4 rad/s; rho(|S|) is 2.89e4 and
  the true value 2.80e4.
- h 50 -> 62 us: about 20% fewer substeps.
- The harness mirrors it: `explicit-step.py --omega bound`.

**2. Contact cone without trigonometry or repeats.**
- A polar test returns P = 0 when Ps is in the polar.
- The 16-direction scan uses a rotation table, compares N^2/D crosswise and does
  no divisions.
- The best direction is refined by safeguarded Newton on F = 2 N' D - N D' instead
  of 24 golden-section steps. This finds the same minimiser to float precision
  in about 4 evaluations; the harness does the same.
- Before this the contacts cost 8.4 of 20 us per substep: one thread running
  about 70 sincos evaluations.

**3. Joints away from contact rows run beside the rows**, on the simdgroups the
rows don't use. Rows take ceil(nr/32) simdgroups. Same arithmetic.

**4. Gathers load four indices, then their records, then sum** (`EX_GATHER`). Same
order, bit-identical; the gathers are latency-bound.

**5. Joints packed per window into 11 float4s** (`t.jp`): the constants, then J, the
state and slip. They are read and written in vector loads. A simdgroup's scalar
loads of the 164-byte Bond cost about 3x as much (`ex_floor_bench`). The live
joints are walked from lists (`t.jl`) instead of scanning every joint's state.

**6. A row's W^-1 and running impulse are read from device memory** instead of
held in registers. Fewer live registers measured 8% faster.

**7. 512 threads per patch.** Measured with the clock held (see the keep-alive
note below), this is as fast or faster at every patch size from 7 to 2,011 joints.
1,024 threads is slower.

Lab distributions, base `feat/impact-capacity` -> 93536eda8, one process per
capture, keep-alive, shared GPU:

| Run | Mean per evaluation | p95 | Window mean | Longest dispatch max |
|---|---|---|---|---|
| Cannonball (`all/cannonball-framed-house-r1`, 403 captures) | 15.2 -> 7.2 ms | 21.4 -> 12.3 | 12.8 -> 4.6 ms | 20.2 -> 9.5 ms |
| Truck (`tc/framed-house-r1`, 400 captures) | 13.8 -> 7.6 ms | 19.9 -> 13.3 | 12.7 -> 4.8 ms | |

## What the measurements say (read before optimising further)

- **Hold the clock.** Apple's GPU drops its clock between short evaluations, and a
  small patch then reads up to 3x slower. `bench.sh` and `lab-dist.sh` set
  `CUMETAL_GPU_KEEPALIVE_BUSY=1`, as the game does. Without it, 512 threads looked
  3x slower on small patches.
- **Phase cost.** `EX_PROF_DUP` computes a phase a second time into a dummy, so the
  physics is unchanged and the added time is that phase's. `EX_PROF_SKIP`
  skips a phase, but that changes the physics, so its numbers are confounded.
  `EX_BUILD_STOP` times the build's stages.
- **The floor on this GPU** (`ex_floor_bench`):
  - `__syncthreads`: 0.05 us.
  - A dependent L1 load: 0.06 us.
  - `grid.sync` across 2-8 threadgroups (cooperative launch): 1.1-1.4 us.
  - A core's scalar loads: about 4-10 per ns. Vector loads are about 3x better.
  - ALU: about 245 FMA per ns per core.
- **Lab patches** are 450-700 nodes and 1,200-1,900 joints, with 36 rows and 28
  debris impactors. A substep costs 16-26 us there, and the joint phase is the
  largest part (about 13 us on 1,919 joints).
- **Early end (explicitWindow 1, heuristic) barely helps.** It cut mean substeps
  only 304 -> 274 on the lab run: resting debris keeps pushing. A rigorous
  criterion can only end later, so early end is not the lever.

## Next levers

1. Spread a patch over several threadgroups (cores) with `grid.sync`.
2. Reuse the build (the bound's blocks and h) while a patch's topology is
   unchanged since the last tick.
3. Reduce joint-phase work further.

## How to test and time

Tools: `physx/source/gpudestruction/tests/tools/` (path-independent; `env.sh` finds the
checkout, a configured garage build -- PHYSX_BUILD -- and cuda-metal from its CMake cache;
built tools go to `out/tools/`):
- `build-tool.sh impact_explicit_replay` (and `impact_capture_replay`): compiles one
  test as ctest does (cumetalc). `run-tests.sh`: the parity and energy gates (ALL=1: the
  handoff and held-over-capacity regressions too).
- Parity (must pass): `IMPACT_EXPLICIT_DT_US=32 impact_explicit_replay
  tests/fixtures/impact-level/cannon-level5.bin .../cannon-level5.explicit.txt`
  -> "Jaccard 1.000, dp 0.00%" (ctest destruction_gpu_impact_explicit_cannon).
  Note: this test launches `exRun` (non-small) directly.
- Energy: ctest destruction_gpu_impact_explicit_energy (cannon-fragments.impc,
  IMPACT_ENERGY_CHECK=1): energy deficits 0.
- Repeatability: `IMPACT_HASH=1` on impact_capture_replay; compare the hash
  against the impact-e build on the same capture.
- Timing: `bench.sh <tool> [RUNS] [ENV...]` on
  tests/fixtures/impact-handoff/cannon-first.impc (IMPACT_METHOD=2
  IMPACT_ROUTE=1 IMPACT_BOUND_IMPACTOR=1 IMPACT_STEP_LOG=1); prints min/median
  of build, window, evaluation, discarding the first (pipeline build) run.
  Shared GPU by default (VIBE_GPU_SHARED=1 through scripts/perf/gpu-run.sh);
  `EXCL=1` takes the exclusive lock -- brief runs only.
- Lab captures for more cases: vibe-land impact-e worktree,
  target/impact-capture/h3/{cannonball,framed-house}-framed-house-r*/ (403
  captures per cannonball run).

Rules: FP32; no change to the physics without the parity/energy tests;
merge into feat/impact-capacity only between lab batches (an SDK commit
mid-run makes the run stale); rebuild the garage-impact SDK and run
scripts/fidelity/provenance.sh before any lab run.
