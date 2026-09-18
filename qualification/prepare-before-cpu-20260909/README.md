# GPU preparation before CPU compatibility

**Accepted as partial architectural progress in ranked replacement 1. Not completion, not a robust measured speedup.**

## Removed dependency

Previously `finish()` constructed CPU fragment actors before GPU collision binding and corrected-motion preparation. Now it completes device allocation and exceptional storage growth only. GPU preparation validates real allocated storage before CPU compatibility objects exist. Combined preparation completion constructs the compact compatibility batch only after those GPU verdicts pass. CPU metadata publication then follows construction. Source masses, motion fitting, equations, commands and fracture ordering are unchanged.

No duplicate execution path or extra persistent physical representation was added. The existing normal path was reordered. Invalid collision input now rejects without constructing CPU candidates. Exceptional raw capacity remains distinct from registered/traversed bodies. The diagnostic manual-install test supplies actual allocated storage extent while retaining undersized-storage rejection and every force/momentum/COM assertion.

Private producer/runtime factory is V3 so mixed module pairs explicitly fail symbol resolution. Public scene/Rust ABI remains unchanged. Native consumers were rebuilt together. The timing schema separately attributes compatibility readback/construction under preparation completion; legacy captures still parse with their original hierarchy.

## Separate dispositions

| Dimension | Evidence |
|---|---|
| Correctness | 41 affected native/ordinary/sleep/correction/report tests pass. Full frozen historical penetration and mode-matched ordinary prefix pass. Production-boundary ordering oracle passes candidate and rejects baseline. Memcheck reports zero errors. |
| Architecture | Native initialized motion and complete collision/correction inputs precede CPU fragment construction. This enables moving GPU ownership installation and registration without a CPU constructor prerequisite for preparation. |
| Maintainability | Existing responsibility moved; no alternate backend or duplicate registry. Explicit storage bound and phase contract; private mixed-module rejection. |
| Performance | Short idle/destruction screen below; modest observed peak difference, no robust saving or deadline/endurance claim. |

## Workload and measurements

[Generated destruction report](shots/report.md) and [fresh idle report](idle/report.md): 256 buildings, 113664 chunks, 229376 bonds; 256-shot prefix of the existing 768-shot tape, or zero-shot pristine idle. 96 steps / 1.6 simulated seconds, two runs per arm/regime, ABBA ordering, isolated GPU and fixed attested consumer. Direct GPU disabled, sleeping enabled, dt1/60, max one correction/two stress evaluations. Complete command-to-accepted-observation time includes growth; rendering/networking excluded. Every first-step spike remains.

Baseline fracture peaks137.794/136.278ms; candidate135.083/134.795ms. Complete loaded means overlap37.139/37.414 versus37.586/37.223ms. Loaded all-step peaks158.305/162.506 versus159.717/158.845ms occur at startup. Idle p50 baseline.432/.436ms versuscandidate.438/.423ms. Do not label this a proven speedup: short screens, run variation and shifted later fracture trajectories limit inference. First counted-state divergence is tick74 baseline/baseline and tick77 or74 candidate/baseline.

The baseline is the immutable `out/ranked-storage-20260909/candidate` GPU-initialization pair, measured previously and preserved before final diagnostic/private-factory/error-label changes. It is not claimed to be a fresh exact build of parentfc9dd2b1. Those differences and this ordering change contain no physical-equation change; module hashes and actual mappings are in the receipt. Candidate modules are immutable under `out/prepare-before-cpu-20260909/candidate`.

## Validation scope

- Ordering fixture:6 chunks,3 bonds,one ordinary body; actual GPU allocation initializes3 new motions, collision preparation identifies3 migrations and corrected-motion preparation contains4 affected owners before any CPU candidates. One correction/two stress evaluations. No test allocator or substitute CUDA kernel.
- Rejected shape/remap fixtures additionally require no CPU candidate construction; generation, uncommitted geometry/damage and failure checks remain.
- Historical penetration:444chunks896bonds1projectile600steps/10simulatedseconds;398retained46detached199broken with exact unchanged topology and wall clearance. Direct GPU enabled/sleeping disabled historical oracle.
- Ordinary penetration: same authored scene,128-step mode-matched prefix with Direct GPU disabled/sleeping enabled. Compared with its established ordinary reference, not the different historical golden.
- Large contact audit in the41-test suite:256buildings113664chunks229376bonds256shots180steps; diagnostic-only, separate from untraced timing.
- Real phase capture:444chunks896bonds1projectile64steps. Existing parser verifies every disjoint interval and new CPU child scopes. Not a performance claim. Reproduction script and accounting receipt included.
- 32 timing-accounting tests and12 opportunity-ranking tests pass; legacy and moved compatibility scopes retain correct attribution without overlap.
- Both mixed private module pairs fail at load time; memcheck passes ordering fixture.

## Next in the required order

Replacement1 remains unfinished. CPU simulation registration, activation/contact bookkeeping and shape rebinding still precede corrected physics. Next remove the remaining host decision/submission boundary for GPU preparation and supply device-owned registration/ownership to the actual PhysX scheduling consumers. CPU compatibility should ultimately follow accepted state, not merely preparation. Do not start structural replacement2 or persistent-contact replacement3 before completing1. No deployment or service changes.
