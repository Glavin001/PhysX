# Stopped WIP handoff — 10 September 2026

**Stopped at the user's request. Do not start more experiments until the user
resumes the work. No owned experiment jobs remain live at handoff.** The most
recent timing runner terminated its own target after another project's GPU
process appeared. No foreign process was stopped.

## Goal and latest direction

Improve the existing embedded PhysX GPU destruction engine for city-scale,
physically equivalent destruction at 60–120 Hz on consumer GPUs. CUDA 13.4 and
hardware counters are available. The user explicitly corrected the workflow:
**iterate on the integrated engine with matched A/B tests**. Large replacements
are allowed, but developing a separate solver indefinitely is not the deliverable.

A is the preserved current engine, B an actual modification of that engine.
Compare identical commands, physics/material settings and physical outputs;
then untraced complete-step peaks, means and exact 120/60 Hz deadline misses.
Hardware-counter runs are separate diagnostic evidence. Keep or revert a change
based on these results. Do not count standalone kernel gains as engine speedups.
“Production” in older notes means the benchmarked implementation, not a deployed
product. No deployment, push, driver change, reboot or foreign-service stop is
requested or authorized.

Preserve ordinary `PxDestructionScene`, Direct GPU off, sleeping on, dt 1/60,
at most one correction / two physics-and-stress evaluations per tick. Preserve
current contact impulses, force/torque, convergence, material verdicts, motion
correction and exactly-once commands/events. No tolerance loosening, omitted
fragments or unfinished convergence spread across ticks. CPU fragment/contact
registration is still incomplete; do not claim the final GPU-owned lifecycle.

## Authoritative workspace and artifact state

- Repository `/root/workspace/physx-2`, branch `codex/rtx5060ti-cuda134`, HEAD
  `1155b7ffb60d4d65853f448b00485c21cfd06b99`; many earlier tracked and untracked
  changes are retained. No new commit was made. Recheck Git before resuming.
- RTX 5060 Ti 16 GB / sm_120, CUDA 13.4.59, driver 615.71.09, Nsight Compute
  2026.3.0 and Systems 2026.3.2. Other users' desktop and services remain running.
- **Current source and `physx/bin/...` runtime contain candidate B**, which has
  not been accepted. The source change is only the trailing barrier removal in
  `blast/source/sdk/extensions/stressgpu/detail/StressNativePolynomial.cuh`.
- `out/install/lib/libPhysXDestructionGpuRuntime_64.so` still contains A.
  `out/sdk-artifacts.json` predates B and must not attest the current bin runtime.
  Do not assume the default executable selects A. Use an explicit arm library
  path and verify `/proc/PID/maps` as the existing runners do.
- A runtime hash: `93846c918089a61d5883790fd101199f08ffae701599d715eedf7c247961a126`.
  B runtime hash: `295c1e994322319e6933a3d4918cc46e92170168b1f8e17a33be3186835a2151`.
- Native executable unchanged:
  `6779e48efc808e7f8d6c6edc7539bf405388831580cf260de251d897517e054e`.
- Isolated, preserved binaries/modules: `out/integrated-polynomial-barrier-20260910/A/`
  and `B/`. A also preserves the original header and three original solver test
  executables. The corresponding B test executables are currently under
  `out/destruction-sdk/reference/`.
- [Stop-state hashes/process observation](../../out/integrated-polynomial-barrier-20260910/stop-state.json),
  [initial worktree patch](../../out/integrated-polynomial-barrier-20260910/initial-worktree.patch),
  [one-file candidate patch](../../out/integrated-polynomial-barrier-20260910/candidate.patch).
  Preserve unrelated `docs/destruction/visual-audit-20260909/` and other user WIP.
  `vibe-land-4` and `blast-stress-solver-2` remain read-only.

## Current integrated A/B candidate

[Experiment report](../../qualification/integrated-polynomial-barrier-20260910/README.md).
B deletes one trailing block barrier from the native polynomial preconditioner.
Its immediate consumers read their own thread's rows; free-mode projection and
normalization reduce with barriers before cross-thread consumption. The earlier
barrier for neighboring-node gathers remains. Arithmetic and acceptance are
unchanged. Compiled kernel resources are unchanged (110 registers, 48-byte stack,
1600 shared bytes from cuobjdump); static barrier instructions fall 45→44.
This is a dependency argument and compiled-code observation, not a speed result.

Completed:

- A screen: two untraced 180-step / 3-simulated-second repeats per regime, plus
  discarded warmups. Both have 256 buildings / 113,664 chunks / 229,376 bonds;
  intact idle has 0 projectiles, bombardment one 256-projectile wave.
  Idle means 1.655/1.668 ms, peaks 16.185/16.360 ms (startup).
  Bombardment means 70.990/70.383 ms, peaks 228.195/226.602 ms (step 82).
  Each idle run misses 120 Hz once and 60 Hz zero times; each bombardment run
  misses both budgets on 99/180 steps. Exact thresholds are 1000/120 and 1000/60.
  [Generated report](../../out/integrated-polynomial-barrier-20260910/A-screen/report/report.md).
  Exit 2 means the completed capture failed the deadline gate.
- A and B full penetration: 600 steps / 10 simulated seconds, 444 chunks,
  896 bonds, one projectile. Recorded poses, decompressed chunk motion, launch
  tape and body-state words are byte-identical. Both pass physical hole,
  clearance and motion/COM checks. Both retain 400 supported / 44 detached,
  182 broken bonds, 39 clusters. Both still fail the unchanged historical golden
  identity. [Exact equality](../../out/integrated-polynomial-barrier-20260910/wall-equality.json).
- Three rebuilt native numerical CTests pass: analytic, 3D, motion modes (which
  includes the independent polynomial/inverse checks). B 3D memcheck, initcheck,
  synccheck pass. B polynomial/motion racecheck passes with zero hazards.
- Broad 3D racecheck is unresolved: B target exits 11 without displayed hazards;
  unchanged A exits 6 with host `free(): invalid pointer`, also no displayed
  hazards. Neither is a sanitizer pass; these controls do not prove the cause.
  [Test runs](../../out/integrated-polynomial-barrier-20260910/B-tests.json),
  [racecheck controls](../../out/integrated-polynomial-barrier-20260910/racecheck-controls.json).

**Incomplete / interrupted:**

- B screen failed during `impacts-256-plain-1` when foreign compute appeared:
  PID 435374, `/root/workspace/vibe-land-4/target/release/web-fps-server`.
  Owned target PID 435275 was terminated by the runner. Both warmups, the first
  measured pair and second measured idle finished beforehand. The campaign is
  incomplete and cannot establish an A/B performance improvement.
  [Failed campaign](../../out/integrated-polynomial-barrier-20260910/B-screen/campaign.json),
  [driver log](../../out/integrated-polynomial-barrier-20260910/B-screen.log).
- No post-B A bracket was run. No new A/B counter captures or B city pose capture
  were started. `capture.py` and `compare-poses.py` in the experiment directory
  are prepared helpers, not executed results.
- Build sessions 1858/70041, A screen 64946, walls 36134/2036, focused checks
  33156/94706 and B screen 78831 are terminal. No live job needs waiting on.

## Next steps, only after the user resumes

1. Recheck Git, artifact hashes and live GPU jobs. Never stop the foreign server
   to get an isolated measurement. Wait for availability or coordinate with the
   user. Keep the failed B attempt. Use a fresh output directory: the interrupted
   last run lacks `exit_code`, which the runner's current `--resume` path assumes.
2. Complete B's same short timing screen and a following A bracket. Do not turn
   the partial B data into a win. Example B command from the repository root:

   ```sh
   LD_LIBRARY_PATH="$PWD/out/integrated-polynomial-barrier-20260910/B" \
     python3 tools/scripts/run-destruction-timing.py out/NEW-B-screen \
       --binary out/integrated-polynomial-barrier-20260910/B/native_destruction_demo \
       --config out/integrated-polynomial-barrier-20260910/config.json \
       --trials 2 --seconds 3 --gate-only --allow-existing-graphics
   ```

   Use arm A and a fresh output for the bracket. Separate profiles from these
   untraced runs; keep startup and every measured step. The shared desktop means
   diagnostic scope, not isolated hardware qualification.
3. Capture actual peak stress counters for A/B, including the later expensive
   launch. Existing [counter workflow](../../.agent/skills/physx-destruction-profiling/SKILL.md)
   explains the cross-thread conditional-graph Nsight failure and the qualified
   diagnostic inline dispatcher. The reusable binary is
   `out/ncu-city-20260910/inline-build/native_destruction_demo-ncu-inline`;
   source/ABI is unchanged for this one-header candidate. Verify its actual
   loaded arm modules and compare recorded city poses against the ordinary
   control. Existing launch targets are 82/83 (first trial/correction) and 130
   (later trial). Do not add profiler times to CPU scopes or claim an inline
   dispatcher timing is normal-engine wall time.
4. If the candidate has no convincing complete-step gain, preserve evidence and
   revert this candidate alone. Restore the header contents from A **with a new
   modification time**, so future builds do not silently reuse B object files.
   Restore/rebuild matching runtime/tests; retain other WIP. If promising, broaden
   to matched 600-step repeats, settle fidelity concerns and refresh SDK install
   and attestation only after acceptance. Do not add a permanent A/B runtime switch.
5. Use real peak counters to select the next integrated structural-work reduction.
   The barrier candidate is a bounded test, not an assertion that microtuning can
   close the current ~200 ms destruction peak. Review failed experiments before
   repeating shared inverse caching, forced occupancy, FP32 preconditioning or
   other already-rejected approaches.

## Earlier WIP and evidence to retain, not restart

There is **no demonstrated complete-step speedup from this session yet**.
The longer [baseline](../../qualification/baseline-rtx5060ti-20260910/README.md)
is 3×600 steps per regime: bombardment means 63.859–64.192 ms and peaks
195.116–223.327 ms; 1557/1800 steps miss both budgets. Idle means 1.630–1.679 ms,
peaks 15.324–16.426 ms, 3/1800 miss 120 Hz and none miss 60 Hz. Do not mix this
10-second regime with the shorter current 3-second screen.

The separate six-channel work is retained but is no longer the main workstream:
`StressElastic*.cuh` and their tests under Blast, `PxgDestructionElastic*.cuh`
adapters, and `tools/diagnostics/destruction-load-capture/`. It is not installed
as the engine's stress backend. It covers component mapping, numerical setup,
loads and partial commands; materials, accepted runtime transactions and free
component precision are unfinished. Reports:

- [Component mapping](../../qualification/elastic-components-20260910/README.md):
  isolated parent-walk improvements, not an engine speedup.
- [Load join/setup](../../qualification/elastic-load-join-20260910/README.md):
  accurate acceptance and singleton setup; 46→34.8 ms profiled setup improvement
  after accuracy first increased its cost from 18.4 ms. Impact queries unqualified.
- [Gravity cancellation](../../qualification/elastic-gravity-cancellation-20260910/README.md):
  248 false incompatibilities removed; correctness, no speedup.
- [Final precision experiment](../../qualification/elastic-precision-reference-20260910/README.md):
  independent 80-digit references show ordinary FP64 rounding fails the probe's
  unchanged tolerance for three captured anchored components. Explicit two-word
  GPU accumulation converges in 658/1162/1736 iterations with independent force,
  moment, response and energy checks; matched FP64 control remains capped at
  8192. Nine CTests/four captured-component sanitizers pass. The route explicitly
  rejects free components and is not engine-integrated. No counter/performance
  claim; all jobs terminal. Dependencies are local to
  `out/elastic-precision-reference-20260910/python` (SciPy 1.15.3, NumPy 2.2.6).
- [Actual city counters](../../qualification/ncu-city-20260910/README.md):
  23–47 ms stress kernels, FP64/dependency/barrier exposure, low DRAM throughput;
  source attribution available. No need to restart the Nsight investigation.

Migration failures in AGENTS.md remain: historical penetration identity, Direct
GPU wall behavior, two large exact-pose audits and accepted-properties initchecks.
No golden changes or sanitizer exemptions were added. The old aligned-transform
experiment was already reverted; do not repeat it unchanged.
