# Rejected partial shared-memory polynomial cache

Base: ab30a85b; the default runtime was restored to SHA-256 c9e09e4d05f9077928428137311cf665774e053e40c4a12d03d2c7a2790f1511 before subsequent work.

Both experiments preserve the two-stage polynomial and existing convergence/physical equations. They cache one preconditioner vector for components up to 512 nodes; larger components keep the existing mathematical specialization. They do not make the complete stress recurrence block-local.

The first variant caches unscaled values and looks up component-local neighbor indices during traversal. Compiler resource usage increases shared storage from 560 to 25,136 bytes per block; registers remain 96. Native analytic, 3D and operator/motion tests pass. Its two 3-second bombardment runs show no established complete-step improvement; the mean is worse. No candidate frozen-wall/endurance qualification was run for this variant. `first-candidate.patch` preserves the rejected change.

The revised variant precomputes CSR-local neighbor indices and stores scaled vectors. It needs 2,289,664 additional bytes for the fixture and increases compiled registers from 96 to 128. These are compiler resource counts, not measured occupancy. Native suites and the frozen 10-second penetration regression pass; its exact 398-retained / 46-detached / 199-broken signature is preserved.

Authoritative revised comparison: `../polynomial-shared-scaled-fresh/comparison.md`, against fresh controls. Fixture: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles; two 180-step / 3-second runs per arm; timestep 1/60, one correction maximum, sleeping disabled. Complete advance includes commands through committed completion. Baseline mean/worst: 16.717 / 53.603 ms. Candidate mean/worst: 16.755 / 56.664 ms. Physical counter histories match, but counts are not a trajectory proof. Neither variant established a complete-peak gain and neither is in production.

`../polynomial-shared-scaled/comparison.md` uses an older control. It is not the fresh-control result; the archive hash guard correctly rejected overwriting that comparison with different samples. No candidate memory/init sanitizer audit or long performance/endurance qualification is claimed. Restored native analytic, 3D and motion suites pass (`../polynomial-shared-scaled/restored-native-tests.log`).
