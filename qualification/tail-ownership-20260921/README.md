# Final-pass collision ownership notification

The engine fix is implemented and the focused regression is verified. This is
not full Bayline destruction or performance qualification, and is not deployed.

## Defect and lifecycle

A split installed after the last allowed corrected solve changes the owners of
persistent collision shapes without scheduling another collision traversal.
`updateBoundsAndShapes` previously forwarded the ownership generation only during
correction, so the next ordinary traversal missed that notification. The later
`prepareFrame(0)` discarded it. Already overlapping shapes that previously shared
an owner could consequently lack contacts after becoming separate bodies.

The controller now forwards any pending installed generation, joins its GPU
producer before consuming the remap, and refreshes bounds for installed owners.
`prepareFrame` clears the consumed generation after **each** collision traversal,
ordinary or corrected. Only new splits publish another generation. No API/ABI,
correction budget, material, gravity, damping or freezing changes are involved.

The initial controller-only experiment also forwarded already consumed changes
on the following ordinary pass. It changed the frozen wall result (194 instead
of 199 broken bonds). That experiment is not the final fix. Clearing consumed
generations after corrected traversals restores exact frozen-wall identity while
preserving final-pass notifications.

## Regression evidence

`native_post_correction_check.h` already produced two loaded columns: one bond
breaks on the first evaluation, the second only after the corrected solve. With
correction limit 1, the second fragment is installed at the end-of-tick pose.
Previously the test checked identity and only one subsequent tick. It now follows
180 ordinary ticks and requires the late fragment to remain at y=5 (+/- 2 cm),
supported by its former same-body base, without further fractures/corrections.

- Original engine: fails `final-pass fragment lost collision support from its
  former same-body base` (`out/tail-ownership-20260921/baseline.log`).
- Final engine: passes with contact reporting on/off, and the existing higher
  correction-limit fixtures also pass. Eleven selected native tests pass, covering both PGS and TGS, contact reports
  on/off, and correction limits 1/2/3. The support test also requires natural sleep.
- Frozen 600-step rendered wall audit passes unchanged: 444 chunks / 896 bonds /
  1 projectile, 199 broken bonds, 398 supported and 46 detached chunks, 43 final
  clusters, all stress steps converged. Exact topology identity matches the
  checked-in golden and the matched original-engine capture.
- Audit reader needed support for the writer's existing TWSTATE v3 rendering
  group field. Added a v3-versus-v2 stream-alignment check; all 11 parser/verifier
  tests pass. The golden and physical assertions are unchanged.

Detailed source/library hashes and results are in [evidence.json](evidence.json).
Raw captures are in `out/tail-ownership-20260921/`. The first audit attempt used
an executable without EGL; the recorded audit uses the existing EGL-enabled
`vibe-land-4/structures/town-kit/out/sdk-render-review/native_destruction_demo`.
The full audit verified actual loaded GPU module/runtime hashes.

## Bayline follow-up and remaining limits

Replayed the same 1411-chunk / 2964-bond bungalow asset and production projectiles.
All completed damage cases first pass 30 simulated seconds of intact gravity
stability. Correction limit stays 1, stress iterations 16, tolerance .001,
gravity 9.81, dt 1/60. No diagnostic refilter hook, damping, forced sleep,
freezing, stabilization or depenetration assist was enabled.

The old harness escape condition incorrectly used a 500 m horizontal cutoff,
although its production-matched ground has half-extent 2000 m. The meteor's
reported escaped fragment was at (170.503, .08, -505.163), sliding ON the ground.
The review harness now uses the actual ground half-extent and rejects nonfinite
positions; two tests cover this recorded false alarm plus real boundary/below-
ground failures. This does not change the simulation. Body snapshots here are
COM positions (see the bridge), not arbitrary actor reference origins.

- Meteor at original 4/1 contact iterations: a 62-second observation passes,
  zero escaped bodies, all asleep, 133 consecutive converged rest ticks. The
  earlier 60-second sample ended just after equilibrium and was too short to
  supply the required rest observation. No earlier failed result was overwritten.
- Cannonball at 4/1 contact iterations: still fails after **120 seconds**, zero
  escaped bodies but 39 awake and stress unconverged. This is not fixed merely
  by observing longer; do not call the default town configuration qualified.
- Same cannonball at 8/2 contact position/velocity iterations: passes within the
  original 30-second duration, zero escaped, all asleep, 700 converged rest ticks.
- Same cannonball at 16/4: also passes within 30 seconds, 988 converged rest ticks.
  These are actual additional contact-solver iterations, not relaxed gates or
  artificial damping. They were applied to parent actors via the public PhysX
  API before intact observation and inherited by fragments. They have NOT been
  made global engine defaults or deployed to the public town.
- Raising *stress* iterations to 32 or 64 instead fails the first intact tick
  with spontaneous furniture bond breaks. Those settings are rejected.

Controlled diagnostic builds separated bounds refresh from pair refiltering:
with the old generation lifetime, refilter-only reproduced the broad probe's
passing cannonball result; bounds-only did not (six escaped bodies). This
isolates the earlier probe's effective change but does not establish that
reprocessing already-consumed generations is a correct production solution.
The final implementation retains consumed-generation clearing and passes the
unchanged frozen wall gate. Do not deploy the broad experiment.

Detailed follow-up reports and hashes are in [evidence.json](evidence.json).
The collision handoff bug is regression-proven. The full town at its current
4/1 contact settings remains unqualified; the higher-contact-accuracy cases
are successful calibration evidence, not an automatic production setting.
GPU jobs ran sequentially; exclusive ownership was not established. No
performance speedup/deadline or full-town qualification is claimed. Public
services and scene selection were not changed.

## Reproduce engine checks

```sh
cmake --build out/sdk-release --target PhysXGpu -j2
cmake --build out/destruction-sdk --target native_standard_scene_test -j2
LD_LIBRARY_PATH="$PWD/physx/bin/linux.x86_64/release" \
  ctest --test-dir out/destruction-sdk -j1 --output-on-failure \
  -R 'post_correction|chained_fracture|native_gpu_collision_preparation|native_standard_(reuse|reported_reuse|sleep|awake)|native_gpu_contact_response'
python3 tools/scripts/test-native-prefix.py
```

Run the playbook's full penetration audit with an EGL-enabled demo and a fresh
output path; do not replace its frozen golden. The final successful capture is
`out/tail-ownership-20260921/penetration-final/quality.json`.
