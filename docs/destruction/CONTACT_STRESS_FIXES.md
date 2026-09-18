# Contact stress and correction fixes

These are fidelity corrections after the imported reference snapshot at
`e0a93ea7`, not behavior-preserving migration or completed GPU integration.
No material limits, timestep, contact gain, or existing test assertions were
changed to produce passing results.

## Fixed

- A singleton contact was discarded as useless bond work even when the chunk's
  material could crush. Both the adapter and its host-side skip predicate now
  retain contacts for crushable chunks.
- The stress core erased the external contact virial immediately before adding
  bond contributions. It now consumes both contributions and then clears their
  inputs. Diagnostic stress and accumulated damage remain available.
- Splitting creates a new PhysX body origin, while the stress graph retains its
  authored coordinates. A cached transform **per rigid cluster** now maps contact
  application points and forces into that frame, including the snapshot-based
  load path. It introduces no additional per-chunk motion state.
- Removal of a crushed chunk triggers reference correction even without a new
  split event. `ExtStressPhysXFrameStats::correctionStatus` reports an exhausted
  pass budget or missing checkpoint. The demo's `--require-complete-correction`
  rejects such a capture rather than silently accepting it.

`Complete` means the final collision topology has received an interaction solve.
It does **not** certify convergence of the stress solver, transactional damage or
energy accounting across retries, joint-state rollback, or committed-only trial
events. The external reference still needs the full internal transaction in the
implementation plan. A reported incomplete frame has already mutated the scene;
callers must not blindly retry it as an atomic operation.

## Evidence and remaining failure

`chunk_crush_test` first separates a chunk through gravity-driven bond failure,
then applies a surface load. CPU and GPU scene variants verify:

- Pressure of 2/3 MPa and deviatoric stress of 2 MPa from a 4 MN force with a
  0.5 m application lever arm on a 1 m³ chunk.
- One damage increment of 0.0216, and no stale stress/damage on an unloaded step.
- Crushing without another split event, correction completion, and an explicit
  incomplete status when the correction budget is zero.
- An ordinary scene actor advances exactly once through the correction.

The native suite is **30/34 passing**. The three recorded baseline failures remain.
A previously passing fixture, `blast_stress_reference_building_crush_ordinary_impact`,
now fails its unchanged zero-crushing assertion: four drywall chunks crush under
its repeated impacts. That material/interaction expectation remains unresolved;
it must not be hidden by dropping contact stress again. Full SDK fidelity is
therefore not qualified. The complete log is `baseline/native-demo.log`.

The strict demo rejection path was also exercised with a real GPU wall impact
and zero correction passes; it exits with an incomplete-correction error at step
134. This prevents a disabled correction path from producing a validated video.
Rust high-rise failures with the generated scene were independently reproduced
on `e0a93ea7`, with identical failure metrics; see `baseline/high-rise-reference.log`.
