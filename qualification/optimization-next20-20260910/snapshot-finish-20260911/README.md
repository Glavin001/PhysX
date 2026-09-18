# Snapshot qualification fixes

The flat-graph fix passes **52/52 normal asynchronous memory checks (104 ticks)**,
the 29-case native correction regression plain/memcheck, allocation memory and
synchronization checks, and the 600-tick ordinary/sleeping wall. The native demo
now defaults to ordinary APIs with sleeping enabled. The complete matched suite
passes **52/52 scenarios, 2,080 full ticks**, including 113,664-chunk city states.
Restore and validation are excluded from all reported tick measurements.

- [Implementation and exact gate evidence](device-enabled-split/README.md)
- [All 52 scenarios, means, maxima, budgets and stages](device-enabled-split/matched/report.md)
- [Continuous 600-tick idle/heavy controls](device-enabled-split/warm/README.md)
- [Derived-force checker correction and unchanged A/A differences](device-enabled-split/force-comparison-correction/README.md)
- [Ordinary/sleeping demo default verification](device-enabled-split/ordinary-demo-default/README.md)

Implementation commit: `8589185e659c8316b1828b7847b8780eb0f11006`.
Continuous heavy means are 54.596–54.990 ms versus controls 54.765–55.136 ms;
peaks 178.072–184.494 versus 177.557–207.905 ms. Every heavy run misses 60 Hz
on 519/600 ticks. Idle means are 1.694–1.830 versus 1.544–1.769 ms; zero
60 Hz misses. No speedup or peak improvement is established. The possible small
idle cost is documented, not hidden as a proven wash. Retention is for fixing
asynchronous diagnostics and enabling further structural optimization.

The source fix is applied; the normal local runtime rebuilt successfully and
passes the 29-case asynchronous correction memcheck and four restored physical
comparisons. See [local build verification](device-enabled-split/local-build/README.md). Installed SDK and best N13 artifacts remain
unchanged; unrelated N14 WIP remains unaccepted. Historical cross-GPU physical
equivalence and the broader 20-experiment batch are separate unfinished work.

## Historical investigation

The retained contact-order fix still has 52/52 passing unprofiled scenarios,
20 independent single-tick restores each. This continuation addresses the
remaining memory-check diagnostics and historical wall comparison. It does not
claim a runtime improvement or change material/convergence tolerances.

## Conditional-graph memory checks

Two isolated source hypotheses failed and are not retained:

- Remove the outer conditional graph: plain initial impact passes; memcheck
  still reports invalid accesses inside live label storage.
- Replace atomic add-zero reads with relaxed atomic loads: plain passes;
  memcheck fails with CUDA error 716 (misaligned address).

Both patches, build commands, module hashes, exact test commands and outcomes
are in [experiments.json](experiments.json). Production topology code is unchanged.
The bounds-checked CUDA-only nested and flat controls both pass 20 iterations in
this cohort; they do not explain the earlier unguarded failure. Both installed
sanitizer versions (2025.1 and 2026.3) detect an intentional out-of-bounds write.
The old version also reproduces the unguarded nested-graph failure. No version
change solves it. [Control commands and outcomes](controls.json).

The current tool's documented `--force-blocking-launches` mode passes the native
25-building initial-impact case with zero errors: two restored ticks, 3,412
broken bonds, 537 output clusters, one correction and two stress evaluations
each. This is a diagnostic execution mode, not a production synchronization
change. Its serialization can hide ordering defects, so it is not proof that
the original asynchronous run is memory-safe. The original failure remains open.
The full blocking diagnostic now passes **52/52 cases, 104 restored ticks** in
652.24 seconds of summed harness time. Every receipt loads the frozen rebuilt
runtime, all logs report zero memory errors, and all repeatability/correction
gates pass. [Audited per-scenario results](blocking-mem-verification.json).
An intentional invalid-write control still fails with exit 97 in this mode;
[control receipt](blocking-invalid-control.json). This checks tool operation,
not asynchronous scheduling correctness.

The wrapper now records sanitizer version/hash and the selected launch mode.
The unprofiled timing reporter rejects sanitizer captures, preventing their
milliseconds from entering performance comparisons. Tool documentation:
[NVIDIA Compute Sanitizer](https://docs.nvidia.com/compute-sanitizer/ComputeSanitizer/index.html).
No suppression or disabled memory check is used.

## Wall comparison

The archived historical golden used Direct GPU mode. An archived ordinary-mode
control already differed on the old GPU: 400 supported / 44 detached / 199 broken
bonds / 41 clusters, versus the historical 398 / 46 / 199 / 43. Current ordinary
mode gives 400 / 44 / 182 / 39. Its physical invariants pass, but an additional
old-versus-current ordinary-mode difference remains. See the complete archived
and current outputs in [wall-reference-evidence.json](wall-reference-evidence.json).
The user confirmed ordinary APIs with sleeping enabled as the target. The wall
wrapper now defaults to that mode and checks a hash-pinned **pre-snapshot ordinary
reference on this GPU/toolchain**, not the historical Direct GPU golden. It
compares all 600 ticks, exact fracture/topology/correction history, trajectories
at the existing 1 mm limit, and the existing penetration/convergence/COM checks
on both runs. The complete default-command run passes with **0 measured position
difference**, 400 supported / 44 detached / 182 broken / 39 clusters.
[End-to-end verification](ordinary-wall-default-verification.json). The 13 CPU
verifier tests pass, including rejection of mode mismatches, short runs, and
a position error at tick 599. No historical golden or numerical tolerance changed.

This resolves the active same-mode wall regression gate. It does not explain or
qualify the remaining old-GPU versus current-GPU ordinary-mode differences.
The historical Direct GPU audit remains available explicitly through
`--historical-direct-gpu`; it is not the default target.

## Current scope

The outstanding blocker is the default asynchronous memory-check failure. Neither
failed topology patch is retained. There is no new application speedup. The
52-case unprofiled benchmark remains [the prior verified measurement](../snapshot-fixes-20260911/timings.md):
20 samples per scenario, restore/validation excluded. Selected mean/max full-tick
ms by scale are:

| Chunks | Intact idle | Initial impact | Late debris |
|---:|---:|---:|---:|
| 11,100 | 9.782 / 12.846 | 40.391 / 50.071 | 70.379 / 90.692 |
| 28,416 | 15.999 / 19.102 | 64.118 / 80.362 | 134.623 / 171.881 |
| 113,664 | 62.324 / 82.158 | 242.483 / 278.238 | 403.159 / 502.157 |

These shared-GPU restored timings include all CPU/GPU work and correction. They
are not warm continuous-play timings or an A/B speedup claim. No sanitizer or
wall-observer times enter this table.

Further asynchronous investigation, rejected hypotheses, repeated CUDA-only controls,
and a prepared but unsent vendor reproducer are in
[the follow-up](asynchronous-followup/README.md). No async qualification is claimed.
