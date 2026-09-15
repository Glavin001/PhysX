# Original-command baseline join and child replay — 10 September 2026

The GPU baseline consumer now joins original command history, authored-chunk
ancestry and current partition membership, then produces child velocities before
spatial command replay. The command-motion transaction accepts this verified
baseline for corrected evaluation only. This is an executable device chain;
**installed runtime V14 does not invoke it yet**. V14's native history capture is
unchanged, and production stress/correction still use the existing guarded path.

## Join and motion semantics

An epoch-stamped body index maps valid sparse upload records to original body
IDs. Initialize index storage once (and newly grown capacity); per-query work
clears/indexes selected command IDs only. Untouched entries from an older input
generation are ignored. Duplicate body records, invalid input receipts and
nonfinite captured values reject.

One 128-thread block validates every chunk of a current child against the same
original body/root/slot/generation. Native fracture may split an original body;
joining different original bodies is rejected. The matching original checkpoint
provides its world COM. If an ordinary additive-command record exists, the saved
pre-addition velocities replace the post-command values. Otherwise the matching
original checkpoint supplies the baseline. This is not proof that other command
channels were absent.

For rewound child COM C and original COM O:

`v_child = v_before + omega_before × (C - O)`; `omega_child = omega_before`.

The transfer uses FP64 intermediates and stores native float velocities. The
command-motion consumer verifies baseline readiness, original input generation,
current topology generation and group count before producing any native write.
It retains the target body's inverse mass and other metadata. Invalid intermediate
baseline output is unusable even if some groups wrote successfully.

## Validation and limits

Nine focused CTests pass: six numerical tests plus command capture, command
motion and baseline. Both changed baseline/motion kernels pass all four CUDA
sanitizers. After strengthening the baseline fixture's parent/child impulse
consistency, its CTest and four sanitizers were rerun and pass. Unchanged motion
and capture binary hashes match the earlier successful runs; these are not extra
unique tests.

The default transfer fixture has 774 authored chunks, six children and three
original parents; a separate 258-chunk rejection fixture checks mixed ancestry,
changed original slot generation, duplicate command records, stale generations,
nonfinite centers and an empty new input generation. Uncommanded parents use the
checkpoint; commanded parents use saved pre-addition velocities, including a
large rounded addition that cannot be inverted by subtraction. Independent rigid
transfer and total linear/angular momentum checks use native-float error limit
`2e-6 (1+|expected|)`. Existing tests, tolerances and goldens were not changed.

The complete device chain uses two mass-2 children with unit inertia, symmetric
COM offsets (-.5,-.25,.1) and (.5,.25,-.1) about the original parent. Canonical
chunk positions, physical mass/COM data and native child poses are aligned. The
parent's captured trial delta corresponds to force 12 N at the first child's COM
over 1/60 second, including its angular impulse about the parent. Its inertia is
computed independently from the two children and their offsets.

The chain runs baseline join → actual chunk-command evaluator → native velocity
transaction. Both children start from the verified original rigid velocity field;
only the commanded child receives the new force increment. Total momentum change
is (0.2,0,0) and moment change about the parent COM is (0,0.02,0.05). Per-child
velocities, angular velocities, duplicate suppression and stale-baseline rejection
pass. This is a synthetic corrected-input transaction, not a native scene fracture
or a complete producer-owned material/command ledger.

## Hardware counters

Nsight Compute 2026.3.0, RTX 5060 Ti/sm_120, CUDA 13.4.59, driver 615.71.09;
cache flush enabled, clocks unlocked, desktop graphics active. One `resolve`
launch, ten replay passes, 512 blocks × 128 threads. The fixture has 113,664
authored chunks, 512 current children, 256 original parents, 513 native slots
and 256 upload rows (171 additive-command rows). It runs no rigid simulation,
projectiles, contacts or fracture bonds.

| Duration | Registers/thread | Achieved occupancy | DRAM / peak | Local/shared spills |
| ---: | ---: | ---: | ---: | ---: |
| 27.01 µs | 38 | 84.80% | 61.71% | 0 / 0 |

The 16,384 output bytes match profiled/unprofiled. This scope excludes index
preparation, receipt kernels, command evaluation, native writes and simulation.
It establishes no city-step speedup. The existing complete-step deadlines
(>8 ms, exact >1000/120 ms and >1000/60 ms) and all startup steps remain.
Native production modules match the V14 qualification hashes, so no redundant
wall campaign was run. The V14 wall invariant subset/topology match and historical
golden mismatch remain the latest native physical evidence.

## Evidence and next integration

[receipt.json](receipt.json), [source.patch](source.patch), [validation-runs.json](validation-runs.json),
[prior-validation-runs.json](prior-validation-runs.json), [counters.txt](counters.txt)
and [identity.json](identity.json) record final sources, commands, modules and results.
Raw: `out/elastic-command-baseline-20260910/`; `final/` contains the final matched
impulse fixture. All owned jobs completed.

Next connect explicit spatial command submission and the verified device chain
at the native input/correction boundaries. The producer must establish that
spatial commands and captured deltas describe the same interval and original
commands; matching receipt numbers alone cannot prove that. New explicit GPU
commands need an authoritative before-image too, not subtraction from their
post-command checkpoint. Unknown body-level loads remain guarded. Full ledger,
material publication, live correction qualification and city performance remain
unfinished.
