# Single-verdict reference replay

The standalone demo and recorder now default to one resimulation per timestep.
This is an explicit reference algorithm change, separate from native GPU engine
integration. The imported `ExtStressPhysXResimOptions` retains its old default;
the demo sets `evaluateStressOnFinalPass=false` and `maxPasses=1`.

## Sequence and meaning

1. Capture the timestep's reference motion checkpoint.
2. Simulate the intact interaction and evaluate its actual solved contact loads.
3. Apply the complete stress/material verdict. If collision topology changes,
   restore motion with the new topology and simulate once more.
4. Reissue the selected verdict's reference crush-energy charges invalidated
   by the motion restore. Consume replay contact observations, retaining
   explicit wake requests, without another stress/material update.

No contact load is predicted, no fracture verdict is truncated, and the final
collision solve still includes the ordinary scene actors. A nonfracturing step
needs no replay. The final replay's contacts do not become extra material time
or stale loads in the next timestep. Body/shape snapshots read corrected PhysX
state directly. Stress diagnostics describe the verdict-producing trial.
Crush resistance retains the imported post-fetch impulse timing: those deferred
impulses take effect on the following simulate. This is not yet the final native
energy-transaction design.

This deliberately differs from the previous loop, which applied a second
verdict on the last replay and could leave that new fracture uncorrected.
`--legacy-resim-fracture` selects that behavior for comparisons. Its exhausted
pass limit remains an explicit incomplete status; assertions are not weakened.
Historical video manifests remain evidence of their original configuration.

## Configurable additional rounds

Both CLI entry points accept `--resim-passes N`. With a value above one, an
intermediate replay may evaluate another verdict and request another rewind;
the final permitted replay remains motion-only. This preserves the ability to
experiment with additional rounds later. Their repeated material-time accounting
still follows the imported reference and is not qualified as a numerical retry
of a single material interval. The current setting is one.

The recording manifest and validation report include the requested limit,
maximum actual per-step count, total count, and final-pass policy. Validation
requires the per-step sum to match the total and rejects a count above the
selected limit. All scenes use the same selected limit; the recorder no longer
silently inserts eight or 64 passes.

## Scope and verification

The policy tests inject a controlled load in the trial and a second lethal load
only after the rewind. CPU and CUDA runs verify a single verdict, contact queue
lifetime, complete versus explicitly incomplete outcomes, and an opt-in
configuration with two actual rewinds. They require the GPU stress solver to
be active in CUDA cases. The existing real-projectile punchthrough test runs
both policies with its original forward-speed and tear-window assertions.
An isolated payer test verifies that the selected partial-crush work survives
motion rollback, that finishing twice does not charge it twice, and that the
resulting speed matches `sqrt(v^2 - 2*work/mass)` within `1e-4 m/s`. Both CPU
and CUDA runs retain the same damage values and stress-tick count.

The full suite is **37/42 passing**. The four previously recorded failures remain,
and `blast_stress_crush_wall_bite` now fails its unchanged `0.015` minimum crush
fraction: three of 216 chunks crush (`0.0139`), while the minimum requires four.
The identical fixture with `--legacy-resim-fracture` passes. This is a new
single-verdict behavior gap, not a pre-existing failure or a qualified parity
result. No material input, load, or assertion was changed to make it pass.

A separate GPU wall capture using the recorder's existing wall parameters
completes **600 steps**, with two fracture-replay timesteps, at most one replay
per timestep, 15 crushed chunks, zero incomplete steps, and validated continuity.
The existing `1e-3` position/point-velocity tolerance is unchanged. This capture
uses different projectile parameters from the failing CPU wall-bite fixture;
its success does not resolve that failure. No new video was rendered.

Evidence is in `out/single-resim-regression.log`,
`out/destruction-sdk/single-resim-regression.xml`, and
`out/single-resim-probes/` (commands, raw GPU states, frame CSV and validation).

This does not finish native collision rebinding or internal GPU correction.
The external reference still uses CPU fracture/replay orchestration. Its
ordinary-body checkpoint does not capture the entire PhysX constraint/contact
cache, and repeated-round damage and crush-energy rollback remain fidelity work.
No 60 Hz or large-scene performance improvement is claimed from this change.
