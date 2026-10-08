# Explicit impact step: performance handoff

Branch `perf/explicit-step` (this worktree), on `feat/impact-capacity` 8e9006545.
Goal: <= 2 ms per impact evaluation (the owner's target), every dispatch < 100 ms,
FP32, no change to the physics: the dump parity, energy and hash tests below must
still pass bit-for-bit or within their derived tolerances.

## The kernel

`physx/source/gpudestruction/src/PxgDestructionImpactExplicit.cuh`: one threadgroup
(kExThreads) per patch; symplectic Euler over rigid chunk nodes and joints (RBSM),
substep h = 0.9 * 2 / omega (Gershgorin), the window is one tick (16.7 ms).
Per substep, four `__syncthreads` phases: joint gather -> contact rows (Jacobi,
mass split, Coulomb cone exCone) -> row gather -> joints (trial, fracture /
radial return, wrench write).

## State of this branch

- `exRunT<bool Small>`: node velocities in threadgroup memory always; for
  patches of <= kExSmall (512) nodes also each node's inverse mass, per-axis
  inverse inertia (3 floats) and CSR ranges (`exRunSmall`; the host picks it
  when every patch fits).
- Each row is one thread (kExRows <= kExThreads): its ends and running total
  in registers; per-row impulse wrenches precomputed into `t.rwr`
  ([P][kExRows][12]) so the node gather reads six floats per row instead of
  rebuilding the wrench from the bond.
- The dead load's work is counted in the joint phase (-sum J0 . B^T v).
- **CuMetal miscompile workaround**: W (3x3) computed in registers and passed
  by pointer to `exCone` produced wrong impulses (impactor dp 557 vs 2204 N s
  on the dump; first substep identical, divergence from substep 2). Storing
  W / W^-1 in global `rows[r].W/Winv` and passing `rows[threadIdx.x].W`
  restores parity (Jaccard 1.000, dp 0.00%). W^-1 is still read from
  registers (works). Worth a minimal reproducer for cuda-metal
  (a __device__ taking `const float*` to a 9-float local array, called in a
  loop after a `__syncthreads`), and recording in docs/CUMETAL_COMPATIBILITY.md.
- Also fixed here: chunks' inverse inertia is per axis (Iinv[0..2]); an
  earlier draft used Iinv[0] for all three.
- The earlier "1.9x faster" figure was measured on the miscompiled kernel and
  does not stand. Current measurement (shared GPU, 12 runs, cannon-first.impc):

  | SDK | build | window | evaluation |
  |---|---|---|---|
  | impact-e (8e9006545) | 0.54 / 0.57 ms | 9.45 / 9.48 ms | 10.20 / 10.30 ms |
  | perf/explicit-step | 0.56 / 0.63 ms | 9.25 / 9.32 ms | 10.10 / 10.20 ms |

  (min / median). Essentially no gain yet.

## Phase profile (what the numbers say)

cannon-first.impc: 2 patches in one launch; the big one is 220 nodes, 735
joints, 17 rows, 332 substeps of 50.3 us. Window 9.2 ms / 332 substeps =
**~28 us per substep** for ~1k items of work: the substep cost is latency
(four barriers, global loads of bonds/links per joint per substep, atomics),
not arithmetic. The dump fixture (997 nodes, 3053 joints, 13 rows, 521
substeps of 32 us, non-small path) takes ~27-31 ms: ~55 us per substep.
A lab cannonball run is 397 evaluations, mean 14-15 ms, longest dispatch ~20 ms.

## Next ideas (in the order I would try them)

1. Fewer substeps for the same physics: omega is the Gershgorin bound of
   M^-1 K; a tighter bound (power iteration on the patch, a few matvecs in
   exFinish) gives a larger stable h. Keep 0.9 safety. Must be derived, not tuned.
2. Joint state in registers/threadgroup memory across substeps: each thread
   owns ceil(nl / kExThreads) joints; keep J, J0, k, state, a/b in registers
   (735 joints / 256 threads = 3 each) instead of reloading `links[l]` and
   `bonds[l]` from global every substep. Write back once at the end.
3. Merge phases: the row phase and its gather could be fused with the joint
   gather of the next substep (one barrier fewer); joint wrench gather via
   threadgroup memory instead of `wr` in global.
4. More threads per patch for big patches (EX_THREADS 512/1024 builds exist
   in scratch: impact_capture_replay-t512/-t1024) and multiple substeps per
   launch already happen (budget); check occupancy.
5. Only then: subcycling (inactive regions stepped at a coarser h) -- needs a
   physics argument (stability per region), not a heuristic.

## How to test and time

Scratch tools /private/tmp/claude-501/-Users-glavin-Development-vibe-land/01c57f95-820d-4c9e-bc1a-a10f13215bce/scratchpad/impact-e-harness (copy them if that directory is gone):
- `W=<this worktree> OUT=<dir> build-tool2.sh impact_explicit_replay` (and
  `impact_capture_replay`): compiles one test as ctest does (cumetalc).
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
