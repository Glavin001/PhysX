# Native physical-load join and accurate fine residual — 10 September 2026

The private six-channel solver now consumes GPU-prepared physical loads through
the native graph mapping. The intact recorded city query passes independent
Newton–Euler load, fine force/moment, bond-response and energy checks. Impact
queries remain explicitly rejected. Production still uses the legacy solver;
this is integration and numerical progress, not a qualified performance win.

## Scope and implementation

RTX 5060 Ti 16 GB, CUDA 13.4.59, driver 615.71.09, Nsight Compute 2026.3.0,
sm_120. Frozen native captures contain 256 buildings, 113,664 chunks, 229,376
authored bonds, 97,280 unknown chunks and 16,384 supported chunks. Their source
trajectory has one 256-shot wave; ordinal 0 precedes impact. These are offline
queries, not new physics advances or an endurance campaign.

The [load join contract](../../docs/destruction/elastic-load-join-contract.md)
defines receipt, moment-origin, geometry, topology, compact mapping and motion
ownership checks. Invalid inputs flow to the solver's rejection gate. The device
component count and GPU-built RHS do not require host readback before solving.

Native loads exposed two numerical errors in the executable baseline:

1. Recursive residual refresh considered the global norm threshold even when
   stricter per-node force/moment criteria were failing. It now considers all
   three targets; the acceptance limits are unchanged.
2. Ordinary FP64 evaluation could report convergence while independent extended
   precision rejected force balance. Compensated evaluation now checks the
   original equations at the physical FP64 solution actually exported. Bond
   recovery uses the same compensated arithmetic; iteration/preconditioning
   remain FP64.

The explicit `uncalibrated-elastic-interface-v1` profile uses diagonal stiffness
1e6 N/m and 1e4 Nm/rad, zero inelastic/prescribed motion, length 1, absolute norm
limit 1e-12 plus relative 1e-10, force/moment scales 1 and local limits 1e-9,
nullspace tolerance 1e-10, and iteration cap 8192. It is a numerical probe, not a
material calibration or release accuracy policy. Complete native commands,
material history, accepted fracture/correction transactions and selective idle
work remain incomplete.

## Validation

[Nine six-channel CTests pass](verified/ctest.log). Four sanitizers each
(memcheck, initcheck, synccheck, racecheck) pass for load join, PCG and operator:
twelve focused runs. Join evidence is from `final/`; PCG/operator evidence is
from `verified/`, after the test readback correction described below.
[Exact commands, exits, maps and loaded-module hashes](verified/validation-runs.json)
and [unchanged join records](verified/unchanged-join-sanitizers.json) establish
the executable identities. No full captured-city sanitizer claim is made.

The initial query converges all 256 components, 271 maximum / 69,376 summed
iterations, 1,792 residual restarts and 11,008 checks. The independent CPU checker
uses extended precision (63 mantissa bits on this VM): maximum force error
8.64090e-10, moment error 1.02577e-10, component norm error 3.39334e-9. Load,
response and energy checks also pass. [Exact result](verified/solve-0.check.json).
All six checked plain/profiled output buffers are byte-identical:
[hashes](replay-output-equivalence.json).

Other frozen queries retain failed status under the same strict probe profile:

| Ordinal | Components | Converged | Iteration limit | Setup unsupported | Incompatible load | Maximum iterations |
|---|---:|---:|---:|---:|---:|---:|
| 82, first trial impact | 256 | 0 | 256 | 0 | 0 | 8192 |
| 83, corrected impact | 5,120 | 4,667 | 256 | 0 | 197 | 8192 |
| 130, later trial | 10,905 | 10,335 | 272 | 247 | 51 | 8192 |

All three load-adapter checks pass. Pending components still fail independent
force/moment checks; their maximum force errors are 4.74145e-7, 3.06530e-7 and
2.51255e-7 respectively. Their auxiliary solution magnitudes reach thousands in
this uncalibrated profile. Those values do not describe observed physical chunk
deformation. See [82](accurate/solve-82.check.json), [83](accurate/solve-83.check.json)
and [130](accurate/solve-130.check.json). These runs precede the compensated
recovery change, which is gated off for rejected queries. The final executable
was revalidated on ordinal 0; no final-binary all-four-query pass is claimed.

## Hardware counters

One selected `solveComponents` launch per version, kernel replay, cache flush
enabled, clocks unlocked, existing desktop active. Hardware-only collection
works and the corrected query completes after three replay passes.

| Metric | Original rejected query | Corrected accepted initial query |
|---|---:|---:|
| Profiled kernel duration | 5,566.905 ms | 795.894 ms |
| FP64 pipe, elapsed-cycle basis | 80.274% | 75.704% |
| Achieved occupancy | 30.119% | 22.434% |
| Eligible warps / scheduler | 0.03770 | 0.02088 |
| DRAM throughput, peak basis | 46.730% | 6.216% |

Raw [original counters](counter-hardware/counters.csv) and
[corrected counters](verified/counters.csv). Different convergence outcomes
prevent a physically equivalent speedup claim. Even the accepted initial probe
is far outside the real-time budget. The FP64 exposure supports reducing
unnecessary numerical work and adding qualified structural acceleration; low
DRAM utilization alone does not identify the remaining cause. These metrics
do not measure spilling. Kernel profiler duration is not complete-step timing.

A broader section capture failed with CUDA 702 during `SW Counters::1`.
[Preserved profiler diagnostic](software-counter-timeout.log) identifies a launch
timeout during software-instrumented replay. Hardware-only metrics succeed on
the same saved baseline executable. This is separate from the previously
isolated [cross-thread conditional-graph issue](../nsight-cross-thread-20260910/README.md).
No driver, timeout setting or desktop process was changed.

## Retained failed attempts and next work

Raw evidence is under `out/elastic-load-join-20260910/`:

- `attempt-1/`: old recurrence policy; all initial components break down after
  4,561 iterations. Inputs, old headers and executable retained.
- `refresh/`: fixed recurrence, ordinary FP64 residual falsely accepts initial
  force balance; independent maximum 1.11389e-9 exceeds 1e-9.
- `accurate/`: compensated residual passes initial equations, ordinary recovery
  fails near-zero response comparisons. Rejected impact queries retained.
- `final/`: compensated recovery; first PCG initcheck fails on host copying 64
  omitted, unwritten prescribed rows in the new test. The corrected test uses
  authored prescribed values and copies only the 380 solved rows. No device
  zeroing or sanitizer suppression was introduced; failed binary/source retained.
- `verified/`: final nine tests, eight PCG/operator sanitizer runs, initial replay,
  independent checks and working hardware counters. Unchanged join sanitizer
  records are included separately.

[Initial-verification source and artifact hashes](sha256.json) retain the private V14
runtime and native-demo identities. Production runtime and demo are unchanged.
Free-component setup was then investigated below. The material/precision envelope
(G02/G05), structural acceleration and accepted native lifecycle integration remain
incomplete. Existing migration parity gates remain unresolved.

## Follow-up: free-fragment setup accuracy

The new `--fine-setup` replay stops after setup and exports states, the basis and
the last mode/action tested. At ordinal 130, all 247 setup rejections are free
components. Every rejected last mode is normalized; every ordinary GPU action
exceeds the configured 1e-10 nullspace limit. Independent extended precision
finds 107 of those last-mode defects below the limit and 140 above it.
[Original attribution](setup-diagnostic/summary.json).

Setup now evaluates the represented mode using the compensated fine-row action,
with unchanged scaling and acceptance criteria. It accepts 105 previously
rejected components; two of the 107 encounter a genuine defect on a later mode.
No previously accepted component is rejected. Setup now has 10,763 ready / 142
rejected components. All 142 rejections independently exceed the limit.
Every mode of every accepted free component is independently checked: 63,042
modes over 10,507 components, zero failures, maximum defect 9.85081e-11.
[Full attribution summary](setup-accurate/summary.json).

A four-chunk, three-live-bond chain extracted from native component 211
reproduces the original failure and passes with compensated evaluation. Its
maximum independent mode defect is 6.20634e-11. A tighter 1e-12 request still
rejects this represented basis. [Before](setup-accurate/regression-before.log),
[after](setup-accurate/first-regression.log). Nine CTests and four setup
sanitizers pass. The intact full query still matches all six earlier verified
output buffers byte for byte. [Commands and loaded modules](setup-accurate/validation-runs.json).

One hardware-only counter capture per version on the same later-state setup:

| Setup metric | Ordinary action | Compensated action |
|---|---:|---:|
| Selected kernel duration | 18.368 ms | 46.053 ms |
| FP64 pipe utilization | 50.425% | 56.623% |
| Achieved occupancy | 16.374% | 15.820% |
| Eligible warps / scheduler | 0.05003 | 0.02783 |
| DRAM throughput | 1.234% | 0.511% |

[Before counters](setup-accurate/counters-before.csv),
[after counters](setup-accurate/counters-after.csv). This is a correctness fix
with measured diagnostic overhead. Each profiler run intentionally returns the
same rejected-query exit 1 as its plain run; the counter collection itself
completes, and all seven setup export buffers match the respective plain run.
No complete-step or physical-parity claim follows from these setup captures.

## Follow-up: remove general setup for isolated free chunks

The later-state query has 9,114 isolated free chunks among 10,905 components.
For a singleton, setup now verifies that no live interface remains, then writes
the exact six-coordinate basis and zero factor/action. Its operator is exactly
zero, so connectivity propagation, Gram–Schmidt and six general fine-operator
checks are unnecessary. Nonzero net force/moment still fails compatibility;
an unclosed partition with a live interface still rejects. Supported components
and nontrivial free components retain the general setup path.

All nine CTests and four setup sanitizers pass on the final code. Tests include
lengths 0.25, 1, 4 and 1e-6, incompatible force and moment inputs, invalid live
singleton partitions, the native four-chunk accuracy regression, and the existing
cache/revision/rebuild checks. The initial full query still matches all six
previously verified buffers byte for byte. The later query's setup state and
ownership buffers are byte-identical to general compensated setup; bases and
last modes are numerically identical, with only negative zero becoming positive
zero in isolated entries. No tolerance was used for that comparison.
[Exact comparison](setup-isolated/setup-equivalence.json).

Independent checking still passes all 63,042 modes in the same 10,507 accepted
free components. The same 142 represented bases still fail; none is waived.
[Final check](setup-isolated/summary.json),
[tests](setup-isolated/ctest.log),
[commands, exit dispositions and loaded-module hashes](setup-isolated/validation-runs.json).

Three interleaved before/after hardware-only captures select `prepareComponents`
on the same ordinal-130 query (one setup per process; no physics advances):

| Pair | General compensated setup | Isolated-chunk path |
|---|---:|---:|
| 1 | 46.031 ms | 34.859 ms |
| 2 | 46.034 ms | 34.805 ms |
| 3 | 46.050 ms | 34.813 ms |

This removes approximately 11.2 ms / 24% of this profiled setup kernel. FP64
pipeline utilization rises from 56.63–56.65% to 59.55–59.64%; occupancy is
15.78–15.85% versus 15.387–15.393%; eligible warps/scheduler fall from
0.02778–0.02786 to 0.01798–0.01799. DRAM throughput remains below 0.74%.
Those counters are consistent with deleting synchronization-heavy zero-operator
work; they do not establish the cause of every remaining stall.
[Exact counter values](setup-isolated/counter-summary.json).

Clock control is disabled, cache flush enabled, three profiler replay passes per
launch, shared desktop retained. Every profiled export matches its own plain
version byte for byte: [hashes](setup-isolated/profile-output-sha256.json).
This validates removal of redundant setup work with a diagnostic kernel reduction.
It does not measure
untraced complete-step improvement or change the pending physical/material gates.

Final source/test/replay/production identities are in
[the final manifest](setup-isolated/sha256.json); the matching source snapshot is
`out/elastic-load-join-20260910/setup-isolated/source-snapshot/`. Build and GPU jobs
are terminal. No production SDK runtime or native-demo binary changed, and no
new full native simulation was run in this stage. The next work is the G02/G05
material/precision envelope and structural acceleration, then accepted native
transactions. Preserve the already-recorded capped impact failures.
