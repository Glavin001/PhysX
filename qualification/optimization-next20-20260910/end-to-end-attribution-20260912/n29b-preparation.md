# N29b: reject unique loads before full equivalence work

Isolated commit `c2644fa00b64f6a3f34ca8ced02b5825803bd860`, parent N29
`91c27a12b5ea5ec308cfe9187a40a84f1b978bd6`; measured control stays the selected
N13+N20 composition `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`.
Runtime and all oracle consumers build successfully. Original analytical/3D/motion and20 exact-reuse/rejection cases, focused asynchronous memory and120 matched light ticks pass. [Continuous7,200-tick work/history checks](n29b-warm.md) pass; full52 matched qualification is running, with a queued city64 impact regression repeat. Full52 memory and wall trajectory gates remain pending.
No source/runtime/SDK promotion. Main index and unrelated edits are preserved.

## Hypothesis and expected scope

N29's exact matcher finds useful idle duplication, but spends2.559 profiler
milliseconds matching large-debris inputs with almost no numerical work saved.
Its full-step debris regression is13.913ms against pooled controls; **the trace
does not explain all of that difference**. The two-chunk regression likewise was
not reproduced under tracing. Removing expensive unsuccessful matching is a
concrete refinement, not a promise to erase every observed regression.

The retained18-capture census shows an inexpensive key over node inertia,
original RHS, current residual and threshold can reject100% of eligible
first-pass debris nodes and99.99% after correction. It retains all256 idle
components as potential matches. City25 first impact rejects100% and correction
44%; larger impact/correction cases retain their actual matching subsets.
These are byte-equality/work counts, not elapsed-time predictions.

Estimated application benefit relative to N29:0–3ms in debris, low confidence
until unprofiled confirmation, preserving rather than adding its idle benefit.
Expected small-scene benefit is unquantified. Candidate cost: one isolated
runtime/consumer build, original and20 exact-reuse tests, asynchronous memory
gates and matched seven-case light screen. A finalist still requires all52 and
continuous ordinary/sleeping qualification.

Support: unchanged physical/convergence gates, reduced fingerprint/selection
durations and no renewed full-step debris/small-scene regressions. Refute: poor
key discrimination, overhead exceeds rejection benefit, any physical mismatch,
or regression persists outside profiler. No threshold sweep or relaxed solver
quality is part of this experiment.

## Ownership and ordering proof to test

- Fuse the cheap key into existing ordinal initialization: no extra launch or
  allocation. Preserve every node ordinal and original self-leader default.
- Use existing per-component `verification` scratch for the immutable32-bit key.
  No original consumer reads it between ordinal initialization and the original
  component solver. The original solver resets every non-follower's flag before
  use; ordered scatter publishes the leader's final flag for every follower
  before the cooperative stage. Large/inactive/settled paths retain the reset.
- Full fingerprinting first scans immutable cheap keys cooperatively. If no
  other component matches, leave the full hash zero and execute the original
  solve, including its normal lazy inverse construction.
- Potential matches retain N29's complete operator/private-cache fingerprint and
  full bitwise comparison. Hash collisions only cause extra comparisons; neither
 32-bit nor64-bit equality authorizes aliasing by itself.
- Do not overwrite the cheap key with the full hash: that would race other
  blocks reading keys. Separate existing storage preserves the phase boundary.

Two additional tests require unique current inputs and a single eligible
component to leave every full fingerprint zero. The original18 mismatch,
collision, nonfinite and scatter tests remain. The unchanged numerical recurrence
and per-component force/material evaluation follow. Physical save/restore never
serializes this temporary scratch.

## Commands and evidence

`out/n29b-cheap-rejection-20260913/build.py`, `build-oracles.py`, then
`run-exclusive-screen.py` reuse existing builders/oracles and matched full-tick
wrappers. The exclusive runner temporarily stops the authorized unused desktop
and restores it in `finally`; it propagates a failed screen's exit code.
Inspect live sessions/manifests before running anything again. Existing outputs
are never overwritten.

[Source hashes](n29b-preparation.json), [cheap-key census](n29-cheap-key-census.json),
[N29 confirmation and profiling evidence](n29-result.json).
