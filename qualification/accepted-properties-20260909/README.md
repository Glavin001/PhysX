# Accepted GPU physical properties — partial lifecycle replacement

**Architectural progress, not lifecycle completion or a proven speedup.**
Ranked replacement 1 remains active. Replacements 2–7 remain pending.

## Dependency removed

The ordinary native path no longer copies fitted mass, COM, inertia, pose and
velocities to CPU actors before corrected physics. GPU correction consumes its
prepared motion directly. CPU compatibility receives physical properties after
GPU topology/correction acceptance, on the existing completion boundary. The
accepted gather reuses the uncompacted correction workspace; it adds no device
allocation or idle kernel, and leaves borrowed compact correction inputs intact.

A previously hidden prerequisite was the ordinary kinematic solver setup:
`PxgContext::copyToSolverBodyStaticAndKinematic` uploaded CPU mass-frame fields.
Native supported clusters now overwrite those solver fields from authoritative
`PxgBodySim` in the existing `initStaticKinematics` GPU kernel. Both PGS and TGS
pass its device pointer; non-native actors keep their ordinary command inputs.
The historical Direct GPU reference mode remains unchanged. This is a producer
integration, not a second solver or an alternate production backend.

CPU scheduler settings (iteration counts, damping/limits, type, wake metadata)
still must be inherited before correction. Their existing equations were moved
from physical publication to the scheduler bridge, not deleted or weakened.
Public ABI15 and private runtime V4 descriptor layouts are unchanged. The PhysX
CPU library, GPU module, runtime and consumers were rebuilt together; the paired
screen uses separately preserved baseline and candidate CPU executables.

**Limits:** CPU BodySim/node registration, actor construction and shape rebinding
still precede corrected physics. Physical publication currently happens after
each accepted topology/correction transaction; after the first correction it
still precedes the second stress evaluation. This is not yet one final CPU
publication after all GPU stages, nor a fully GPU-owned simulation lifecycle.

## Validation and failed intermediate work

- 42 affected native/ordinary/sleep/correction/report tests pass. A separately
  added PGS version of the new boundary fixture also passes.
- New boundary fixture: six chunks, three bonds and one ordinary body, Direct
  GPU disabled and sleeping enabled. Both solver types verify fitted COM is
  installed on GPU while CPU COM remains unchanged before corrected physics;
  accepted actor properties agree with GPU afterward, inherited settings remain,
  and the following ordinary tick succeeds. One correction/two stress evaluations.
- The old immutable GPU/runtime pair is rejected by that boundary oracle with
  the exact pre-correction CPU COM diagnostic. This is a negative boundary
  control using the new fixture/CPU library, not a full baseline qualification.
- New integrated boundary fixture passes CUDA memcheck with zero errors.
  Existing broader baseline initialization/CUB synchronization findings remain
  unresolved; this is not an engine-wide clean sanitizer claim.
- Historical wall: 444 chunks, 896 bonds, one projectile, 600 steps/10 seconds.
  Exact frozen signature and physical audit pass: 398 retained, 46 detached,
  199 broken bonds, both-wall clearance, maximum one correction. This historical
  reference uses Direct GPU on/sleep off; its capture is not a timing run.
- Ordinary wall: same asset, Direct GPU off/sleep on, 128-step mode-matched
  prefix passes with zero position difference. It uses the full audited ordinary
  reference, not the distinct historical golden.
- Initial publication deferral failed that strict ordinary prefix because CPU
  kinematic solver input remained stale. Preserving CPU postsolve poses did not
  fix it. Moving native kinematic inputs into the existing GPU producer restored
  exact parity. That ineffective pose branch was removed; all tolerances and
  physical settings stayed unchanged. Failed and passing captures are archived.
- Real 64-step ordinary wall phase capture passes the existing disjoint timing
  accounting. Accepted gather/readback/publication is included in acceptance;
  no separate isolated-kernel saving is claimed. The unchanged Rust benchmark
  was rebuilt against the new native CPU library; game sources were not edited.

## Paired short screen

[Destruction report](shots/report.md) and [pristine idle report](idle/report.md):
256 buildings, 113664 chunks, 229376 bonds, 256-projectile prefix of the existing
768-shot tape or zero-shot idle; 96 steps/1.6 seconds per run, two runs per arm
and regime, ABBA order on an isolated GPU. Direct GPU off, sleep on, dt1/60,
maximum one correction/two stress evaluations. Complete command-to-accepted
observations/events time includes runtime growth and startup; rendering and
networking are excluded. No service was changed.

Baseline fracture peaks138.270/134.832ms; candidate135.515/129.892ms. Loaded means
37.382/37.304 versus37.899/37.096ms overlap. Loaded all-step startup peaks are
157.187/159.400 versus159.807/159.958ms. Idle medians .462/.442 versus .430/.450ms.
These short results establish neither a robust gain nor a reliable regression.
No real-time, five60-second qualification or endurance claim. Later chaotic
count differences appear in both baseline repetitions and candidate comparisons;
controlled physical fixtures, not count equality, establish the narrow parity.

Baseline module pair: `out/device-preparation-packed-20260909/candidate`.
Baseline CPU executable: `out/accepted-properties-20260909/baseline/embedded_city_bench`.
Candidate modules/executable: `out/accepted-properties-final-20260909/candidate`.
Actual hashes, mapped paths, raw samples, failed controls and tests are recorded
in the generated reports and `evidence/`. The existing screen runner now supports
an independently attested baseline CPU executable and rejects changes between arms.

## Next in rank order

Complete replacement1's actual GPU simulation registration and shape-ownership
consumers. `bindNativeNodeHandle`, CPU active/island settings, contact retirement
and `NpShapeManager::rebindShapeInternal` remain correction prerequisites. Delay
CPU compatibility to final accepted observations, including the union of both
fracture evaluations. Preserve numerical activation order and current-tick
queries; the archived contact-retention regression is not an acceptable base.
Then proceed to structural replacement2, persistent contacts3, publication4,
selective correction5, local activity/topology6 and remaining passes7.
