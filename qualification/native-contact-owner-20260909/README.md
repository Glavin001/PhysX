# C3/C4 persistent contact ownership — unqualified WIP

This implements a subset of the approved GPU lifecycle plan. It has **not passed
physical equivalence**, has no performance result, and has not been deployed.
The working implementation remains on the destruction development branch.

## Mechanism and scope

Retain eligible ShapeInteraction, contact-manager and GPU pair storage when a
chunk changes rigid owner. Update actor membership, body/core pointers, dominance,
response flags and the island edge. Use the upstream canonical endpoint-ordering
rule for both newly created and retained pairs. A stream-ordered GPU transaction
updates the pair edge and ordered inputs without consuming a new pair generation;
it clears incompatible solver output and cooperatively resets oriented PCM when
endpoints reverse. Analytic primitive buckets have no PCM and require no reset.
Broadphase rediscovery must not create a duplicate retained pair.

Reporting/filter-callback/CCD/modifiable/non-rigid pairs still require complete
reconstruction. CPU fragment allocation and compatibility metadata are still
prerequisites. C1/C2/C5/C6 are **not complete**. Host packet collection and transfer
also remain; this is not the final fully GPU-owned lifecycle.

## Correctness evidence and failed attempts

- `evidence/unit-final*.log`: 1,025 stored pair records, three sparse transactions,
  endpoint reversal and unchanged orientation, analytic and PCM-backed records,
  stable lifetime identities, output invalidation, and all-or-nothing stale-batch
  rejection. Normal execution, CUDA memcheck and initcheck pass.
- `evidence/integration-touch-transition.log`: all eleven selected native tests
  pass, including the new retained-owner GPU graph audit, reporting, material
  fracture, correction, sleep/wake and ordinary current-tick queries. These are
  focused fixtures, not large-scene qualification.
- Initial retention produced duplicate pairs on broadphase rediscovery. The
  retained-pair guard fixes the failure; the stronger graph audit remains enabled.
- A temporary canonical-order eligibility guard passed the frozen wall oracle
  only by eliminating reuse in the small reuse fixture. It was replaced with
  actual endpoint reversal; it is not retained as an optimization win.
- Endpoint reversal initially assumed every rigid bucket had PCM storage.
  Failure-only diagnostics identified an analytic primitive bucket with no PCM;
  this is fixed and temporary GPU printf diagnostics have been removed.
- Preserving trial touch state produced a different corrected interaction.
  Changed edges now require narrowphase to establish touch after restored motion.

## Remaining physical failure

The frozen penetration run uses **444 chunks, 896 bonds, one projectile, 600
steps at 1/60 s, max one correction**. This historical fixture enables Direct GPU
and disables sleeping; the focused ordinary-API tests above cover Direct GPU off
and sleeping on. It is a heavy motion/identity audit, **not a timing run**.

Latest capture: `out/native-contact-owner-20260909/wall-touch-transition`.
The strict oracle fails. Actual final output is **404 supported chunks, 40
detached, 179 broken bonds and 31 clusters**; required output is **398, 46, 199
and 43**. The topology difference is physical, not merely reassigned identities.
First projectile motion divergence occurs in corrected step 17; topology history
diverges at step 29. Every golden assertion remains unchanged.

A progress message prematurely inferred matching final counts from a hash-only
exception; those counts were not yet checked because hash validation runs first.
The values above were subsequently extracted from the actual capture and correct
that statement. No pass is claimed from the diagnostic extraction.

The next diagnostic identified a causal ordering dependency: retained CPU
contact-manager indices change accurate-island activation and solver ordering.
Restoring only the reference's first-correction event order passes the exact
frozen oracle. That diagnostic rule was removed; it is **not** a production fix.
See [the measured ordering finding](ORDERING_FINDING.md).

Next: implement separate GPU solver-registration identities/activation order and
consume the native ordered event stream without CPU pool-index reordering. The
production candidate remains unqualified. Measure independent pristine-idle and
destruction benefits only after its controlled physical gate passes.
