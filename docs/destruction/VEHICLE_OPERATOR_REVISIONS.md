# Vehicle operator revisions — isolated prerequisite

2026-09-26. This change separates solver cache identity from fracture identity.
It does not yet add moving suspension geometry, change a public structure's
layout, or install a replacement garage/city runtime.

`ExtStressGpuDeviceTopologyStatus.generation` continues to identify committed
connectivity. `solvedGeneration` continues to report the connectivity used by
the last submitted solve. The existing `rebuilds` counter identifies the
operator used by hierarchy, motion modes, local inverses, warm-range provenance
and settled-input certificates. Geometry updates will need to advance this
operator revision while preserving connectivity and broken-bond health.

Surviving local inverses and unchanged-component settled certificates advance
to the next operator revision during a validated connectivity transaction.
Unknown/stale caches never gain validity. The hierarchy and motion-mode status
publishers compare their revisions with the operator counter. Material
strengths, equations, precision defaults, convergence thresholds, and scheduling
are unchanged by the production patch.

## Tests and limits

`gpu_resident_stress_test epochs` passes on local CuMetal with explicitly
selected FP64. It covers skipped connectivity generations 17/41/90, repeated
updates, removed-bond zero output, changed loads, warm-state preservation,
bit-exact settled reuse, one-ULP invalidation, settings changes, partial splits,
and refusal to cache an unconverged solve. The analytic 12-node/9-bond column
error is 5.29819e-7; two 64-node/62-bond fixtures test independent structures.

`gpu_resident_operator_epoch_test` directly checks independent revision
readiness/publication, six incident-cut cache cases, warm-range invalidation,
and 771 physical six-variable inverse blocks against the triangular oracle.
In the initial run, the first three groups pass; the inverse error is 4.4408921e-15. The
warm-retirement group fails its existing subnormal-input case (scenario 7,
9.9999461e-41): a float comparison incorrectly classifies the stored nonzero
load as zero on CuMetal. A separate six-value probe reproduces that distinction
between float comparison and bitwise zero classification. This failure is
preserved, not waived; correcting the exact-zero predicate is a separate change.
Results are recorded in the Vibeland operator-epochs evidence report.
The full motion-mode test is retained, but its legacy dense-reference helper
currently fails CuMetal pointer lowering. Do not report that full suite as
passed. Both targets explicitly select FP64 because their independent oracles
use double-precision buffers and tolerances.

The focused inverse test uses an immutable descriptor root and a separate
read-only triangular-oracle launch. This changes only the test's private launch
interface; both calculations and all numerical assertions are preserved.

The package build must match the qualified local runtime's explicit hierarchy,
motion and aggregate descriptor roots, block-voted traps, and packed bond
stress settings. No compiler source was changed. The initial integration-test
wait was sampled inside Apple's Metal shader compilation during graph setup,
not treated as convergence or performance evidence.

This is functional evidence only. Complete native vehicle regression,
full moving-geometry integration, frozen penetration, operating-load endurance,
idle/impact performance, and NVIDIA CUDA execution remain unqualified for this
patch. The previously qualified runtime and live ABI 18 installation remain
untouched. Vast validation is still deferred.

## Exact-zero follow-up

The follow-up correction classifies load components by their stored IEEE bits,
masking only the sign bit. Both signed zeros remain zero; subnormal and
nonfinite values cannot certify zero input. It does not change loads, material
strengths, solver tolerances, or warm-state eligibility for ordinary values.

Both focused GPU targets pass after the correction. Direct coverage includes
72 input cases across all six wrench components, all 18 block/cooperative
retirement cases, six status-readiness cases, six local inverse-lifetime cases,
and 771 inverse blocks (maximum scaled error 4.4408921e-15). The integration
suite's physical-force, topology, settled-state and nonconvergence checks pass
again. The original failure remains in the evidence report. Full-suite,
complete native runtime, moving-geometry, penetration and performance limits
above still apply.
