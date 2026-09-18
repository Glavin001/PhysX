# Fast mode-matched wall rejection — partial verification-tier implementation

The existing runner now has early (32 steps), screen (128 steps) and default full
(600 steps) tiers. The demo's new `--steps` cap preserves the original scenario
launch schedule and only truncates execution. No engine equation, contact order,
material, convergence threshold, timestep or physical oracle changed here.

## Actual runs

Both new early runs use one building, 444 chunks, 896 bonds, one projectile and
32 accepted steps at 1/60 second with at most one correction. They observe GPU
render/physics motion for quality; they are not performance screens.

- Historical Direct GPU on / sleep off: the existing candidate fails at step 17,
  with 0.003969608 m projectile error against the audited reconstruction reference.
  Process execution (including initialization and audit output) was 0.803 s;
  subsequent verification was 0.237 s.
- Ordinary API, Direct GPU off / sleep on: the existing candidate also fails at
  step 17, with 0.003969608 m projectile error against the recorded ordinary-mode
  settled-reuse reference. Process execution was 0.804 s; verification 0.227 s.

Both exceed the existing 0.001 m audit tolerance. No physical gate is declared
passed and no native simulation speedup follows from shorter diagnostic runs.
Machine-readable captures/results and loaded module hashes are attached. Full
short captures remain in `out/native-prefix-20260909`.

## Verifier checks

Nine synthetic negative/positive tests pass: unchanged observations, exact topology
identity mismatch, displaced motion, nonfinite state, duplicate/missing identities,
unconverged stress, mode mismatch, changed solver settings and an unqualified
historical reference. Synthetic records validate the checker, not physics.

The existing audited historical reference accepts its own 32/128-step prefixes.
These are archived-data checker controls, not newly simulated passing candidates.
The existing ordinary capture passed the established physical verifier without
applying the incompatible historical mode golden. Its recorded 400 supported/
44 detached chunks differ from the historical 398/46; that difference remains
unresolved and neither golden was changed.

## Remaining scope

Native GPU lifecycle/event integration and its wall failure remain open. This
change implements a prerequisite from the replacement plan's verification loop,
not its performance replacements. Still missing: online first-failure stop,
bounded diagnostic ring, subsystem dispatch, city/idle prefix orchestration,
production-equation batch replay, compiler caching and full qualification.
The complete wall gate still defaults to 600 steps. Mode-specific prefixes do
not replace full audits, matched idle/destruction screens or endurance.
