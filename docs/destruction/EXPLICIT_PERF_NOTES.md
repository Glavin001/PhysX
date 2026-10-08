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

**8. A cheaper build.** The bound's products read their iterate from threadgroup
memory, with each slot's other end precomputed. The rows' bodies and ends live in
threadgroup memory, and `prepareRow` runs on every thread. Same results; the lab
build is about 1.6 -> 0.9-1.2 ms.

**9. Smaller fixed costs.**
- Patches of up to 672 nodes take the threadgroup-memory path (`EX_SMALL`).
- There is no host readback between the build and the window
  (`Settings::explicitSync`; `IMPACT_EXPLICIT_SYNC=1` restores it to time the
  build and the window apart). On CuMetal a sync round trip costs about 0.12 ms.
- Contact rows are packed as float4 records.

Lab distributions, base `feat/impact-capacity` -> be8c29439 (merged, SDK-gated).
Min of 3 runs per capture, one process each, keep-alive, shared GPU. Times in ms:

| Run | Evaluation mean | Evaluation p95 | Evaluation max | Longest dispatch max | Substeps median |
|---|---|---|---|---|---|
| Cannonball (`all/cannonball-framed-house-r1`, 403 captures) | 13.8 -> 4.9 | 19.2 -> 7.5 | 21.5 -> 8.4 | 20.0 -> 8.1 | 323 -> 243 |
| Truck (`tc/framed-house-r1`, 400 captures) | 14.0 -> 5.2 | 21.1 -> 8.6 | 25.3 -> 15.1 (one outlier; median 4.8) | 21.1 -> 12.9 | 340 -> 270 |

Measured and not kept:
- **Several threadgroups per patch** (branch `exp/explicit-grid`). It is
  bit-identical, and its per-patch device barrier costs 0.6 us. But the
  1,919-joint patch only goes 6.67 -> 6.2 ms at G 4-8, and smaller patches get
  slower.
- **Two joints interleaved per thread:** 1.5x slower, because of registers.
- **float2/float4 records for the gathers:** no gain.
- **CuMetal honouring `__launch_bounds__`** (cuda-metal cdeb329: pipelines report
  512 threads): no gain, so registers were not spilling.
- **Diagonal rotational-inertia scaling** (`explicit-step.py --rotation-rule`):
  - Scaling every chunk gives 271 -> 180 substeps, but the impactor's dp moves
    +35%, the Jaccard falls to 0.776 and the added KE is 21%. It fails the gate.
  - Exempting the rows' chunks keeps the result inside the reference's h vs h/2
    spread (Jaccard 0.890 against 0.895, the same dp), but saves only 9%.
  - True SMS (rigid-exact) needs a solve every substep, which costs more than it
    saves.
- **Combined both-ends B^T v and wrench (fewer FLOPs):** no gain.
- **Independent patches in one launch already run concurrently.**
  `ex_patch_scaling` on 1 / 2 / 4 / 8 copies of the full island gives
  8.5 / 8.8 / 8.8 / 9.6 ms.

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

The substep is latency-bound. More threads, more cores, fewer FLOPs and a larger
register budget have each been measured and do not help. What remains is the
substep count.

1. **Multi-rate (asynchronous) steps.** Sized with `IMPACT_EXPLICIT_LOCAL=1` on 90
   lab patches:
   - Only 7% of joints (p90 8.5%) have an element frequency above omega/2.
   - Power-of-two levels do 0.27 of the joint updates.
   - Projection: window about 4.2 -> 1.7 ms, evaluation about 2.5-3 ms.

   It needs a stability argument first (AVI resonances, Fong, Darve & Lew 2008;
   subcycling interface conditions, Belytschko et al. 1985). It also needs the
   fidelity gate, because slow joints' break times are quantised to their period.
2. **The stiff set may be authoring.** Long, light members (about 2 kg, arms about
   1 m) on short stiff joints: k_l 4.5e7 N/m on 0.004 m^2, against 6.3e6 N/m on
   0.027 m^2 for the rest. Softening them to their material's stiffness would
   raise h with no kernel work.

## Multi-rate design (held until the house's stiff set is re-authored)

**Status.** Main's decision: hold. The stiff set looks like fastened timber
connections given the wood's E instead of the fastener slip modulus K_ser
(EN 1995-1-1). The house-authoring agent is checking that. Measure omega with
`IMPACT_EXPLICIT_LOCAL=1` before and after; revisit this design only if a stiff
set remains once the authoring is fixed.

**Sizing (be8c29439, 90 lab patches of >= 200 joints).**
- Element frequency per joint: omega_j^2 = lambda_max(k^1/2 (W_a + W_b) k^1/2),
  with W_e = B_e^T M_e^-1 B_e for each of the joint's two chunks.
- Fractions of joints:

  | Element frequency | Fraction of joints |
  |---|---|
  | omega_j > omega/2 | 7.1% (p90 8.5%) |
  | omega_j > omega/4 | 29.5% |
  | omega_j <= omega/8 | about 50% |

- The fastest element is about 0.82 of the window's bound.

**Levels.**
- Level L_j is the largest L with omega_j <= omega / 2^L (capped). Joint j steps
  at h_j = 2^L_j h, where h = 0.9 x 2 / omega_level0.
- omega_level0 is the bound recomputed on level 0's subsystem. The finest step
  must be stable for the stiff joints and their nodes.
- Finest step n (1-based) runs the joints with 2^L_j dividing n, i.e.
  L_j <= ctz(n). Each level has a list, built once per window as `t.jl` is
  today.
- Joint updates per window are Sum_j 2^-L_j against N: 0.27 of uniform (p10-p90
  0.25-0.30).

**The accumulator form**, which keeps the RBSM J form exact for the elastic part:
- Each node keeps a displacement accumulator u (6 floats). Every finest step
  does `u += h v` after its velocity update.
- When joint j fires at step n, it takes its relative displacement since its
  last firing:

      d    = B_j^T (u_now - u_at_last_fire)
      J   -= k d
      then fracture or radial return, as today

- It stores `u_at_last_fire` per end in its packed record (12 floats more).
- Its force acts on its nodes over its whole period, as the impulse
  `2^L_j h B_j (J - J0)`, written to `wr` when it fires.
- Nodes update every finest step from the impulses that fired at that step.
  Applying a slow joint's impulse as h B (J - J0) on each of its 2^L finest
  steps is the subcycling (Belytschko) form; once per period is the AVI form.
  Choose one with the stability argument.
- Rows (contacts) run every finest step, on the struck chunks' velocities.
- The dead load's work is counted per firing, as h_j J0 . d.

**Stability: the condition to settle before writing kernel code.**
- Asynchronous variational integrators (Lew, Marsden, Ortiz & West 2003) are
  symplectic per element. They have resonance instabilities when element steps
  are commensurate (Fong, Darve & Lew, "Stability of asynchronous variational
  integrators", J. Comput. Phys. 2008). Power-of-two levels are exactly
  commensurate, so the growth rate must be bounded for this spectrum, or the
  method changed.
- Nodal subcycling (Belytschko, Smolinski & Liu 1985, "Stability of
  multi-time step partitioned integrators for first-order finite element
  systems"; and Belytschko & Lu for second order) is stable when each
  partition meets its own CFL and the interface nodes step at the finer rate.
- With the node partition chosen as "a node steps at its fastest joint's rate",
  this condition reduces to the per-level bound above. That is the argument the
  harness should verify on the lab captures first: no energy growth over the
  window, and the energy books closing.

**Fracture timing.**
- A slow joint can only detect its capacity at its firing times, so its break is
  quantised to 2^L_j h: up to about 0.5 ms at L = 3. A level-0 joint still
  breaks on the substep, as today.
- The fidelity gate is the one used for mass scaling. Against the uniform-step
  reference, the result must stay within that reference's own h vs h/2 spread:
  - Jaccard on broken joints (0.895 on the cannonball dump);
  - the impactor's dp;
  - energy closure;
  - locality.
- A joint near its capacity could be promoted to level 0. That needs a derived
  promotion criterion: its utilisation growth bounded over its period by the
  energy its nodes can carry, as in the early-end analysis. A tuned band is not
  acceptable.

**Projection.**
- Cost model: about 2.5 us plus 5.2 us per joint per thread, per finest step
  (fitted to the 1,273- and 1,919-joint lab patches).
- Per finest step: the 1,919-joint patch about 25 -> 8.5 us, the 1,273-joint
  patch about 15 -> 6.5 us.
- Lab window mean about 4.2 -> 1.7 ms; evaluation about 2.5-3 ms with today's
  fixed costs.

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
