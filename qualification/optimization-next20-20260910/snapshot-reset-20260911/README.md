# Reusable snapshot workspace

The 52-case suite now takes **388.529 s (6m29s)** summed process harness time,
versus 1051.101 s (17m31s) for the previous qualified workflow: 63.0% less time.
Restore accounts for **127.149 s**, versus 579.412 s previously: 78.1% less.
The same 1,040 full ticks account for **58.473 s**, versus 58.688 s previously.
These are separate shared-GPU cohorts; no game-step speedup is claimed.
All first loads, repeated restores, validation and teardown are accounted for.
[All 52 scenario means, maxima, deadline misses and stages](scenarios.md).

The changes retain pinned host allocation capacity, reuse aligned PhysX object
backing storage, reuse an exactly matched decoded physical input, and batch active
cluster motion transfers. Every sample still constructs clean physical bindings,
re-exports and byte-compares its imported state, then checks the complete tick and
its physical output. No contact history, numerical guesses or solver certificates
survive into the next restore. Ordinary APIs, sleeping on, fixed 1/60 timestep,
one correction maximum, original material laws and all tolerances are preserved.
API16/privateV20/schema7 are unchanged. Installed SDK remains untouched.

## Measurements

| Cost, all 52 scenarios ×20 | Seconds |
|---|---:|
| Complete ticks | 58.473 |
| Restore (including first load) | 127.149 |
| Pre/post physical validation | 75.340 |
| Per-sample teardown | 42.766 |
| Per-case context/file setup | 40.560 |
| Other process/wrapper overhead and final cleanup | 44.242 |
| Total harness | 388.529 |

| Scenario | Full tick mean / max ms | Repeated restore mean ms | First restore ms |
|---|---:|---:|---:|
| Bridge64 cold | 8.753 / 10.257 | 10.842 | 220.371 |
| 11,100-chunk idle | 9.601 / 15.944 | 44.912 | 376.016 |
| 113,664-chunk idle | 59.200 / 73.979 | 370.612 | 1868.813 |
| 113,664-chunk initial impact | 236.880 / 254.511 | 372.699 | 1838.402 |
| 113,664-chunk late debris | 394.491 / 458.203 | 468.164 | 1987.419 |

All three listed city256 cases miss both 60 and 120 Hz on 20/20 ticks. Cold restored
workloads differ from warm continuous gameplay. The latest continuous idle/heavy
measurements remain the previous flat-topology campaign; this change has not
established another continuous application performance gain.

The tick timer includes input commands, integrated physics/stress simulate/fetch,
completion synchronization and compact completion transfers. It excludes restore,
validation and teardown. `simulate_fetch_ms` is integrated physics and destruction,
not a stock-PhysX-only measurement. All raw samples are retained; reports include
minimum, median and standard deviation, not only averages. Twenty shared-GPU
samples are useful for a large setup reduction, not sufficient evidence for a
small optimization win without balanced repeated controls.

## Correctness and rejected work

- Frozen R4: **52/52 scenarios ×20 independent full ticks**, including exact import
  re-export and repeated physical checks. All 52 also pass comparisons against the
  previously qualified physical outputs, using the existing scaled2e-4 derived
  force gate and unchanged exact material/topology/load checks and motion gates.
- Frozen R4: **52/52 default asynchronous memcheck cases**, 104 ticks, 483.76 s
  harness; zero reported errors. No blocking-launch option or suppression.
- Final hardening: 28 structural/continuation/negative-input round trips pass;
  bridge64, city256idle and city256late each pass two asynchronous memcheck ticks.
  Cache replacement is transactional, and pinned cleanup holds the owning CUDA
  context and is checked before success is reported.
- Final hardening: 600-tick ordinary/sleeping wall passes the pinned physical
  reference, including exact fracture/topology/correction history and zero
  measured position difference. This instrumented audit is not a timing result.
- **R1 live-scene remove/reinsert is rejected.** Late debris changes observed
  mass/inertia/COM/role; idle tick grows to 293–298 ms due to work deferred into the
  measured step. No live-scene reset path is retained. Its failed source/results
  remain in its separate experiment commit.
- A wall wrapper attempt failed before launching simulation because its driver
  log occupied the capture log filename. Preserved as a harness failure; the
  corrected final wall run above passes.

Code experiments and hashes are recorded in [commits.json](commits.json), with
hypotheses, evidence, expected savings and decisions in [queue.json](queue.json).
R4 full-suite artifacts are frozen under `out/snapshot-reset-20260911/prepared-*`.
Final hardening is commit `38112ec7123fc63da56d651660b9bdd5f25b16d4` on the isolated
`codex/snapshot-reset-20260911` branch. The main working index and unrelated source
changes are preserved. Snapshot work is not another N-series experiment; that
batch remains 11/20 and best N13 is unchanged.

## Profile and memory tradeoff

Nsight Systems reports 33 pinned host allocations consuming 3.860 s and 33 frees
consuming 1.346 s in the two-repeat large-idle baseline, together 85.8% of cumulative
CUDA API time. This is API attribution, not an additive full-step profile.
Capture: `out/snapshot-reset-20260911/timeline-qualified/large-idle.nsys-rep`;
SQL export and CUDA API CSV are alongside it. Commands and the failed earlier
missing-input capture are preserved in the raw directory. This diagnosis calls
for removing allocation/transfer calls; no kernel-counter speedup is claimed.

The existing PhysX pinned allocator callback now supports a benchmark-owned pool
matching exact allocation size and flags. It retains at most 8 GiB of unused
capacity, synchronizes before recycling leases, and frees capacity before context
shutdown. City256idle recorded 2.771 GB peak retained storage and 209 reuse hits.
The per-thread decoded-input cache holds one payload up to 64 MiB plus its decoded
representation, with exact byte matching. Larger payloads are not cached. It stores
no runtime/GPU pointers; live binding and configuration validation runs again.
A new entry is fully prepared before replacing the old entry, releasing old
capacities rather than accumulating caches across differently shaped inputs.

## Remaining work

Restore is **not yet cheaper than the tick across the large suite**. Steady scene
creation is now 2.3–2.4 ms; city256 object insertion costs 76.5–127.1 ms and destruction
import 265.7–310.3 ms. Teardown adds 133.7–199.5 ms, separately measured. The next
ranked targets are immutable destruction-asset preparation and reusable runtime
allocations with an explicit fresh-state reset. Attribute those costs first;
never transfer reconstruction work into the measured tick or reuse stale solver
state to manufacture a setup improvement.

## Adopted local build

The guarded source adoption and normal runtime/demo/probe rebuild completed. All
four local checks below pass 20 independent full ticks and physical comparisons
against the frozen full-suite outputs. Runtime SHA256:
`4e1318cb17b5620b833f137e44f9fd924e31c0df0f1763af886500e9884dc786`.
These are a final-build screen, not another interleaved speedup claim.

| Scenario | Full tick mean / max ms | Repeated restore mean ms |
|---|---:|---:|
| bridge64-cold | 8.974 / 12.810 | 11.189 |
| city256-intact-idle | 70.271 / 81.293 | 369.618 |
| city256-initial-impact | 236.600 / 276.418 | 380.843 |
| city256-late-debris | 413.774 / 445.146 | 515.451 |

All owned jobs ended. Raw commands/receipts: `out/snapshot-reset-20260911/`;
local adoption verification: `local-verification.json`. No SDK installation.

The initial adopted-build idle mean70.271 ms prompted a balanced20/20/20
frozen-control/local/control repeat. Means are67.835 /61.275 /61.061 ms;
maxima81.756 /72.188 /74.640 ms, with physical A/B and A/A comparisons passing.
The initial idle increase does not persist against adjacent controls. This does
not establish a speedup; keep the shared-GPU variability in view. See
`idle-check.json` and its physical comparison receipts. All owned jobs ended.
