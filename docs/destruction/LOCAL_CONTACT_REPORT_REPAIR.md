# Repair reporting participants instead of refiltering the city

Native game-consumer profiling identified a destruction integration cost: any
ordinary CPU contact report vetoed GPU pair retention. Each corrected tick then
reset every active dynamic shape's filtering. A report from one projectile on the
ground could destroy/recreate unrelated rubble contact managers and island links.
The baseline diagnostic peak included 30.086 ms of refiltering inside a 104.815 ms
correction interval. GPU stress contributed another 52.047 ms across two solves;
it overlaps the measured completion wait and is not an extra addend.

The implementation now gathers persistent shape IDs from the existing reported
pairs, discards deleted IDs/static boundaries, deduplicates the active dynamic
shapes, and repairs only those shapes' reporting relationships. Unrelated GPU
pairs remain resident. The prior actor/shape report-stamp fix remains in place.
The same complete repair is retained for trigger/contact-modification state and
CPU contact-manager fallback, whose reuse is not validated here.

This is a deletion of unnecessary whole-world lifecycle work, not a translation
of stress into CPU code. CPU event-report bookkeeping remains with its actual CPU
consumer. GPU contact regeneration, friction-cache invalidation, actual impulse
loads, convergence, material equations and the one-correction/two-stress policy
are unchanged. Static ground is excluded so it does not connect the entire world
to the report repair set. Sleeping/kinematic shapes follow the complete path's
activity exclusion; refiltering must not create spurious wakes.

## Evidence

[Generated comparison](../../qualification/vibe-consumer-local-report-repair-20260908/report.md):
256 buildings, 113,664 chunks, 229,376 bonds, 768 physical rounds per 600-step /
10-second run. Direct GPU API off, native sleep on. One baseline and two untraced
candidate runs with identical command tapes and reported physical settings.

- Complete peaks: baseline 186.782 ms; candidates 151.490 / 151.405 ms, now startup.
- Fracture peaks: baseline 186.782 ms; candidates 135.903 / 147.162 ms.
- Means: baseline 94.641 ms; candidates 55.996 / 57.516 ms.
- Using the worse candidate: observed complete-peak reduction 18.9%, fracture-peak
  reduction 21.2%. This does not establish 60 Hz, endurance or superiority to the
  historical external Vibe-land solver.
- Final broken bonds: 78,046 baseline; 76,217 / 76,743 candidate. Fragment and
  corrected-step counts are also published. These chaotic trajectories diverge;
  this is not a bitwise/equal-fracture-output claim.

The candidate diagnostic replay's worst later corrected step was tick 78:
15,151 fragments / 14,850 awake, 256 projectiles present, 366,181 reported normal
contacts, 70,283 cumulative broken bonds. Correction took 20.411 ms; its refilter
scope was 0.016651 ms, including 0.001763 ms targeted report repair. These are
*different states* from the baseline peak, so they demonstrate mechanism exposure
rather than a matched per-step speedup.

[Baseline phases](../../qualification/vibe-consumer-phases-20260908/report.md) ·
[Candidate fracture-peak phases](../../qualification/vibe-consumer-local-report-fracture-20260908/report.md)

## Tests and remaining targets

Eight ordinary native scene tests passed. The reported-reuse fixture now demands
zero whole-scene fallbacks and additionally compares a sleeping control's boundary
state with/without simultaneous fracture. Contact points/normals/impulses are read
and checked, not discarded by a no-op callback. Public timestamps remain one per
tick. The frozen 444-chunk / 896-bond fixture retains exactly 398 supported chunks,
46 detached chunks, 199 broken bonds and its previous topology signature.
Both 600-step consumer runs pass event/state count agreement, duplicate-event,
pass-limit, finite-position and final-ownership checks.

The new fracture peak is the initial large split at tick 48. In its separately
instrumented replay (10,449 fragments / 10,193 awake, 216,220 normal-contact count,
57,788 cumulative broken bonds), CUDA stress is 33.479 ms; CPU fragment record
creation is 20.397 ms; correction is 51.371 ms. Across the ten worst fracture
steps, GPU completion/stress is the largest remaining interval. These are the
next measured opportunities; do not optimize the former global refilter again.
Startup's first-step initialization remains counted and is also above budget.

## Reproduce

Use the game consumer commands in [CONTACT_REPORT_CORRECTION.md](CONTACT_REPORT_CORRECTION.md).
The optional `embedded-profiling` Cargo feature installs the SDK's existing phase
collector only in the diagnostic benchmark. Production uses `embedded-destruction`
and does not enable that feature. Build profiling consumers separately and never
mix their instrumented samples into the untraced gate report.

```bash
# From vibe-land-2, with SDK/target/library environment configured:
cargo build --release -p vibe-land-destruction --features embedded-profiling --example embedded_city_bench
# Then run the same benchmark command with a fresh output directory, on an idle GPU.
# From physx-2, after the run:
python3 tools/scripts/report-vibe-consumer-phases.py CAPTURE_DIR NEW_REPORT_DIR --fracture-peak
python3 tools/scripts/compare-vibe-consumer-bench.py --baseline BASELINE_DIR \
  --candidates CANDIDATE_A_DIR CANDIDATE_B_DIR --output NEW_COMPARISON_DIR
```
