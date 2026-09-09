# Device-controlled allocation and preparation

**Accepted as partial ranked-replacement 1 architecture; not lifecycle completion or a qualified speedup.**

## Responsibility moved

Production submits collision binding and corrected-motion preparation inside the
allocation graph. Successful device allocation enables its continuation; the host
no longer observes an allocation verdict and then submits these preparation stages.
No fracture bypasses the branch. Exceptional capacity exhaustion grows raw storage
and retries allocation/preparation without replaying stress, damage or physics.
GPU-initialized motion and prepared collision/correction inputs precede CPU actor
construction. CPU simulation registration and shape rebinding still precede the
corrected interaction. They are the next lifecycle owners to replace; ranked 2–7
remain pending.

The first revision introduced separate descriptor/status transfers and a consistent
idle penalty. It is superseded, not selected as a performance implementation.
Canonical completion records now occupy one persistent device allocation with a
matching pinned host observation. Producers retain their distinct device views;
the ordinary completion copies all required verdicts once instead of five separate
copies. This removes transfer overhead without suppressing validation or fracture
work. A small pointer/input descriptor upload remains; it is not a host verdict.

The private producer/runtime factory is V4; mixed V3/V4 pairs fail symbol resolution.
Public scene/Rust ABI 15 and physical equations/settings remain unchanged. Explicit
manual preparation entry points remain only for diagnostic fixtures; there is one
production dispatch. Reporting recognizes the new combined CUDA allocation and
preparation scope and rejects missing stress-pass measurements. Old host preparation
scopes are absent in the new capture, not assigned fabricated zero GPU cost.

## Separate dispositions

| Dimension | Evidence / limits |
|---|---|
| Correctness | 41 affected native, ordinary, sleep, correction and report tests pass; full historical wall and ordinary prefix pass; memory-access check passes. Broader synchronization/initialization audits remain unresolved as below. |
| Architecture | Removed host allocation-verdict/resubmission dependency. Device preparation no longer requires CPU fragment construction. Next consumer: GPU simulation registration and ownership installation. |
| Maintainability | One preparation graph and one canonical completion record; no new backend or duplicate physical state. Runtime-only record layout; explicit private module version. |
| Performance | Superseded revision's idle penalty addressed. Final short paired results do not establish a robust end-to-end speedup, real-time capability or endurance. |

## Measured workload and results

Both screens: 256 buildings, 113,664 chunks, 229,376 bonds; 256-projectile prefix
of the existing 768-shot tape, and independent zero-projectile pristine idle.
96 steps / 1.6 simulated seconds per run, two runs per arm/regime in ABBA order.
Direct GPU off, sleeping on, dt 1/60, maximum one correction and two stress solves.
Complete command-to-accepted-state/observations timer includes first steps and
runtime growth; rendering/networking excluded. Initialization is separate.

Final [destruction report](packed/shots/report.md) and [idle report](packed/idle/report.md):
baseline fracture peaks 135.394/138.131 ms; candidate 129.874/134.105 ms. Complete
loaded means 37.392/37.397 versus 36.894/37.693 ms. Loaded all-step peaks remain
startup: 157.356/158.719 versus 156.912/160.295 ms. Idle median baseline .465/.452
versus candidate .427/.462 ms. Every measured step remains in the reports.
At candidate tick48: 10,449 fragment bodies, 10,193 awake, 216,220 reported normal
contacts, one correction/two stress evaluations; 129.874 ms includes 11.936 ms of
accepted game observation/events. These are observed counters, not all independent
rigid-body solver rows. Later chaotic count divergence is preserved in the reports.

The [initial separate-transfer idle screen](idle/report.md) had medians .508/.511
versus baseline .434/.426 ms; its [destruction screen](shots/report.md) did not
establish a peak improvement. These are separate paired campaigns, not an isolated
kernel attribution experiment.

Baseline is immutable `out/prepare-before-cpu-20260909/candidate` (e500e32f
implementation); final candidate is `out/device-preparation-packed-20260909/candidate`.
Receipts attest actual mapped modules and the fixed consumer. Neither was deployed.
Five 60-second runs and endurance have not been performed for this partial change.

## Verification scope

- Production ordering fixture: six chunks, three bonds plus one ordinary body.
  Two load levels cause growth followed by a fracture without growth. Actual GPU
  preparation is inspected before host completion/construction. Each step has one
  correction and two stress evaluations. Candidate passes; immutable baseline is
  rejected with the expected host-wait/resubmission diagnostic.
- Full frozen penetration: 444 chunks, 896 bonds, one projectile, 600 steps/10 s;
  exact unchanged topology, 398 retained chunks, 46 detached and 199 broken bonds.
  Historical Direct GPU on / sleeping off. Mode-matched ordinary API, sleeping-on
  128-step prefix separately passes; it does not substitute that historical golden.
- Real 64-step wall phase capture: disjoint complete accounting closes; compatibility
  construction follows preparation, old host preparation scopes absent, each stress
  evaluation has the combined CUDA interval. Ten analyzer and 32 accounting tests pass.
- New allocation fixture passes memcheck, initcheck, synccheck and racecheck. Final
  integrated ordering fixture passes memcheck. This is not an engine-wide clean
  sanitizer claim.

## Unresolved sanitizer findings

Unfiltered integrated initcheck reports `mergeChangedAABBMgrHandlesLaunch` and
full-capacity topology commit copies. Synccheck reports CUB single-tile radix-sort
barriers inside the topology conditional graph. Racecheck reports shared-memory
hazards across massProperties/CUB scan instrumentation. The immutable baseline
reproduces all these locations. The baseline ordering test stops after its first
fracture; candidate covers both, so different error totals are not a matched full
trajectory comparison. No suppression or assertion weakening was added.
See the existing [conditional CUB investigation](../component-stress-cub-synccheck/README.md).
These findings remain unresolved, not waived or counted as passing checks.

## Reproduction

Build using the repository performance playbook. `verify-phase-capture.py` captures
the new phase protocol and checks both existing analyzers. The existing
`qualification/native-settled-20260909/run-screen.py` produces both paired reports;
exact arguments, mapped hashes and raw sample paths are in evidence/ and reports.
Sanitizer/test logs are losslessly compressed as .log.gz, preserving original bytes.
The isolated final captures remain under `out/device-preparation-packed-20260909`.
No services, deployment or read-only source repositories were changed.
