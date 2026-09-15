# Stable uniform-gravity cancellation — 10 September 2026

The private physical-load adapter now cancels uniform gravity analytically for
complete free aggregates. It removes 248 false compatibility rejections across
two frozen native captures without changing solver tolerances or discarding
small forces, moments or spin. Production stress remains legacy; impact solves
and the material/precision envelope remain unqualified.

## Failure and correction

The previous adapter accumulated weight into the applied force and then
subtracted rounded translational inertia. In free fall, those rounded terms
could leave about 1.82e-12 N per node despite the exact internal load being zero.
Rounded COM arithmetic could also create a gravity couple. The numerical
compatibility test correctly rejected the resulting incompatible RHS.

Of 197 corrected-impact compatibility failures, all had zero surface loads and
172 had exactly zero spin. All 51 later-state failures also had zero surface
loads, with 49 exactly nonspinning. A native-mass three-node regression reproduces
the fictitious force: [before](before/regression.log).

For `CompleteFreeWrench`, use the nongravitational applied wrench to compute
`a_relative = sum(F_other)/M` and the Euler angular acceleration about COM. The
physical acceleration receipt remains `a = gravity + a_relative`. Compute
internal nodal force/moment using `a_relative`, tangential/centrifugal terms and
intrinsic rotational inertia. Uniform gravity then cancels before rounding.
The singleton path likewise excludes gravity from COM torque transport.
`EngineAcceleration` and supported-body calculations retain their prior path.

The balance-test scales remain sums of **physical** external/inertial wrench
magnitudes, including gravity. The first candidate accidentally changed those
scales along with the arithmetic: later aggregate 5324 then failed at a moment
defect of 1.56126e-11. Its failed [log](after/solve-130.log) and executable/source
remain in the raw `after/` directory. The final patch restores the original
physical scale definition; all absolute/relative policy constants are unchanged.
No sanitizer suppression, numerical cutoff or tolerance adjustment was added.

## Matched captured checks

RTX 5060 Ti 16 GB, CUDA 13.4.59, driver 615.71.09, sm_120. Inputs come from the
existing ordinary/sleeping 256-building trajectory: 113,664 chunks, 229,376
authored bonds, 97,280 numerical unknowns, one 256-shot wave. No new physics
trajectory was run. Ordinals 83 and 130 are respectively tick 83/correction and
tick 109/trial. The same explicit uncalibrated stiffness/accuracy profile is used.

`--fine-check` sets the diagnostic iteration cap to zero and retains setup,
compatibility and original-equation initial-residual checks. A nonzero residual
returns pending; this does not establish a completed solve. It avoids repeating
the already-recorded 8192-iteration failures merely to inspect their inputs.

| Capture | Components | Before: initial check passes / pending / unsupported / incompatible | Final: initial check passes / pending / unsupported / incompatible |
|---|---:|---:|---:|
| 0, intact | 256 | 0 / 256 / 0 / 0 | 0 / 256 / 0 / 0 |
| 83, corrected impact | 5,120 | 4,612 / 311 / 0 / 197 | 4,787 / 333 / 0 / 0 |
| 130, later trial | 10,905 | 9,174 / 1,538 / 142 / 51 | 9,224 / 1,539 / 142 / 0 |

Some small spin loads previously lost precision when subtracting weight now
correctly require iterations. They are not zeroed to make the table pass. The
142 genuinely failed represented null bases remain unsupported. The aggregate
load checks pass on all three final captures under the existing independent
Newton–Euler comparisons. [Initial](final/solve-0.compatibility.json),
[corrected](final/solve-83.compatibility.json),
[later](final/solve-130.compatibility.json).

The intact query was also run with the full 8192 iteration cap: all 256 components
converge, 271 maximum / 69,376 total iterations. Independent load, fine-equation,
response and energy checks pass. Six output buffers match the previous verified
initial query byte for byte. [Result](final/initial-full.check.json),
[comparison hashes](output-equivalence.json). This initial-query result does not
qualify full impact/correction solves or new material verdicts.

## Tests and counters

All [nine six-channel CTests](final/ctest.log) and four load-test sanitizers pass:
memcheck, initcheck, synccheck and racecheck. New checks require exactly zero
free-fall internal loads at native mass, preserve 1e-9-scale applied forces and
moments, and require identical internal response when uniform gravity changes,
with zero/small/finite spin. Singleton angular acceleration must also be gravity
independent. Existing supported, engine-acceleration, input rejection, offset,
rotation and GPU-to-solver tests pass.

One selected load `build<DeviceGroups>` kernel per version, ordinal 83, 5,120
aggregates / 113,664 chunks. Hardware-only Nsight Compute collection completes;
the target intentionally exits 1 because the zero-iteration numerical query is
pending. Profiler exports match each version's plain outputs byte for byte.

| Metric | Before | Final |
|---|---:|---:|
| Profiled load-kernel duration | 899.488 µs | 930.016 µs |
| FP64 pipe utilization | 82.535% | 80.584% |
| Achieved occupancy | 25.962% | 26.135% |
| Eligible warps / scheduler | 0.04293 | 0.04184 |
| DRAM throughput | 7.919% | 7.572% |

[Exact counters](final/counter-summary.json). This is a correctness improvement,
with a slightly slower single diagnostic sample; no speedup is claimed. Clocks
are unlocked, cache flushing enabled, existing desktop retained. The timer is
one profiled kernel, not an untraced complete step. Iterative stress and setup
remain much larger measured costs than this load kernel in the supplied probes.

## Reproduction and remaining work

[Final commands, exits, maps and loaded modules](final/validation-runs.json),
[baseline commands](before/validation-runs.json),
[build command](final/build-command.json), [source/binary hashes](sha256.json).
Raw files and a final source snapshot are under
`out/elastic-gravity-cancellation-20260910/`. All build/GPU jobs are terminal.
Production runtime and native-demo hashes are unchanged. The stage records its
own rebuilt test/replay identities; the older SDK-wide source attestation is
not a qualification of these private numerical sources.

Next resolve the G02/G05 material/precision envelope and actual nonzero residual
failures, with structural acceleration measured including setup/recovery.
Complete native command/material transactions and zero-idle lifecycle joining
remain required. Preserve the frozen migration gates and the existing untraced
120/60 Hz complete-step miss reports.
