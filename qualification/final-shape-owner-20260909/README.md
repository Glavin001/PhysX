# Final CPU shape ownership publication — controlled qualification

Partial ranked replacement **1**. GPU tracks final changed shape owners; public
actor shape arrays and built-in query ownership update once, after both stress
verdicts and accepted physical-property publication. This removes public
shape/query ownership as a prerequisite for the corrected interaction.
**CPU simulation registration and contact retirement still precede correction.**
This is not completed GPU lifecycle, selective correction or a measured speedup.

## Implementation and costs

- Existing GPU owner installation stamps a per-chunk frame epoch and final body
  target. The second pass overwrites a target for a repeated migration; epochs
  retain the union of changes from either pass.
- Final CUDA selection preserves authored chunk order and gathers a bounded
  observation payload. Its count shares mandatory completion readback; there is
  no additional count-read/wait/resubmit boundary.
- CPU uses each shape's previous accepted public actor as the publication source,
  rather than assuming it equals the second pass's simulation owner.
- Adds 12 bytes per allocated chunk (64-bit epoch, 32-bit target), a final
  full-chunk selection when migration occurred, a gather and an ownership
  payload readback. Existing intermediate simulation-registration readback
  remains. These are disclosed costs, not eliminated by describing the change
  as architectural progress.
- Reuses private raw binding scratch. The first draft incorrectly reused the
  compact trial buffer still exposed by `getDeviceView`; the new negative
  oracle demonstrated that overwrite, and the fixed implementation preserves
  the exposed count/records. No extra allocation/kernel was needed for this fix.
- Publication overflow now reports collision-ownership error 1024, instead of
  the unrelated contact-lifetime exhaustion bit 8192. Required work is never
  truncated; the step fails. A pre-existing stage error leaves payload zeroed.
- Public ABI remains 15; the private allocator interface/factory was V6 in the initial tests; the
  combined response-validity implementation is V7.
  Rebuild CPU/static consumers and GPU modules together. V5 baseline consumers
  cannot load the V6 implementation interchangeably.

## Correctness evidence and historical failure

The fixed scratch implementation passed all 44 affected native tests, including
ordinary APIs, PGS/TGS final-property boundary checks, two-pass ownership union,
sleep/query/publication checks and timing accounting. The four-chunk/two-bond,
two-column plus ordinary-sentinel fixture proves two fracture verdicts, one
correction and one final shape publication. Its CUDA memcheck reports zero errors.

Historical wall: 444 chunks, 896 bonds, one projectile, 600 steps; Direct GPU on,
sleeping off. Exact frozen identity gate passed with 398 supported chunks,
46 detached and 199 broken bonds. Ordinary wall: same asset/projectile, Direct
GPU off, sleeping on, 128 steps; fixed build passed the unchanged mode-matched
reference. The ordinary reference remains distinct from the historical golden.
These observations are heavy correctness audits, not performance results.

**Do not discard this failure:** the original WIP ordinary capture failed at
step 84 (one extra reported broken bond); stress iterations first differed at
step 82. Every recorded chunk-motion field matched through all 128 steps, but
that does not prove identical bond health, equations or contact loads. Three
unchanged WIP reruns and eight matching committed-baseline controls passed the
original reference. The original extra-bond verdict was not reproduced by those baseline controls.
Subsequent output-poisoning experiments expose stale/unwritten contact loads at
step 82 in both V5 baseline and V6 WIP. The V7 producer-stamp fix passes the
poison diagnostic, both original wall gates and the affected suite. This identifies
a real baseline defect at that boundary; it does not causally reproduce the exact
original one-bond outlier. See [response-validity receipt](../contact-response-20260909/README.md).

The baseline control was linked with committed 965803d8 CPU sources and its
archived V5 GPU/runtime tuple. Candidate source bytes and static library were
saved and restored, with provenance under
`out/final-shape-owner-20260909/baseline-control`. The candidate tuple used V6.
All three initial baseline controls show stress iteration differences from the
reference near step 82. Thus numerical variability is measured at baseline,
but it has not reproduced the failed bond verdict. See the
[counter comparison](evidence/counter-repeat-diagnostic.json).

Original captures, failed and successful, remain under
`out/final-shape-owner-20260909`; see [repeat diagnostic](evidence/ordinary-repeat-diagnostic.json).

The added four-record CUDA contract fixture covers final owner selection after
repeated migration, both-pass union, stable order, old epochs, initialized tails
and explicit capacity failure. Its overflow oracle failed against the original
wrong error category. The corrected contract test passed, and CUDA memcheck reported zero errors.
The final runtime was rebuilt; all five focused ownership/accounting tests
passed against it, followed by fresh frozen600 and ordinary128 audits, both
passing at unchanged tolerances. Their final artifact hashes are in the
`wall-final-*` capture receipts. These focused tests do not erase the earlier wall failure.

## Remaining, in order

1. Retain the original intermittent outlier and the identified baseline stale-response
   defect as separate evidence; neither reference nor tolerance changed.
2. Completed short idle/destruction and real phase-accounting screens are in the
   response-validity receipt. They establish no peak speedup or full qualification.
3. Move simulation registration, activity/iteration metadata and shape/contact
   lifecycle prerequisites to GPU, preserving ordinary queries and sleeping.
4. Continue ranked replacements 2–7 in the approved order. None is completed by
   this publication change.

No source-sibling edits, deployment or service changes. Controlled tests and short paired screens qualify this partial architectural
change; general GPU lifecycle and endurance remain unfinished.
