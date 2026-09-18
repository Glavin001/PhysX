# Ranked replacement 1: GPU motion initialization before CPU compatibility

**Partial architectural progress, not a demonstrated performance win and not completion of replacement 1.** Source changes belong to the final CUDA-owned lifecycle. CPU simulation registration, actor compatibility construction and per-shape rebinding are still on the correction prerequisite path. Replacements 2–7 have not started in this sequence.

## What changed

The device-controlled allocation transaction now validates candidate identity and storage bounds and initializes actual PhysX GPU body state in the same cooperative kernel. All validation precedes writes to canonical motion/owner storage. It retains the existing GPU-source settings, mass/inertia, COM, motion, previous velocities and force-command clearing formulas.

The producer supplies a borrowed body-storage view and an exceptional growth callback. CUDA assigns/initializes selected addresses before CPU compatibility objects exist. Growth returns memory only, refreshes the producer view and retries allocation without repeating physics/stress/damage. Storage capacity is separate from the resident body traversal/acceleration-observation range. Ordinary advances do not copy an unchanged storage descriptor. The successful CPU construction path no longer dispatches an empty GPU status kernel.

PhysX's normal scene path no longer invokes the old host-count initialization sequence. Its validation entry point remains for the existing targeted correction fixture; it is not an alternate production dispatch path. The physical formula is shared in a small internal header. CPU metadata clearing is measured as `publishReservedMetadata`, distinct from historical `initializeReserved` captures. GPU allocation timing includes initialization; timing reports do not add it to overlapping host waits.

Private factory symbol is versioned to `PxCreateDestructionRuntimeV2`: the producer/runtime advance signature changed. Both mixed-library directions fail symbol resolution before simulation. The public scene/Rust consumer ABI is unchanged. All native executable consumers were rebuilt together.

## Separate dispositions

| Dimension | Disposition |
|---|---|
| Correctness | Full historical wall passed; ordinary prefix and focused lifecycle/correction tests passed. All four CUDA sanitizer tools pass the expanded production-kernel allocation/initialization oracle. Five broader baseline audit failures remain unresolved. |
| Architecture | GPU motion initialization no longer requires CPU actor construction. Raw capacity does not create actors or enlarge live work. Registration/shape ownership remain CPU prerequisites. |
| Maintainability | Shared physical formula, explicit storage owner and private ABI, one normal scene execution path. Legacy validation-only fixture entry remains an identified cleanup item. |
| Performance | Short paired idle/destruction screen is inconclusive. No significant win or reliable regression established; no deadline/endurance claim. |

## Workload and measurements

The generated [idle](idle/report.md) and [destruction](shots/report.md) reports use 256 buildings, 113664 chunks, 229376 bonds, 96 steps / 1.6 simulated seconds per run; idle has zero projectiles and destruction executes the first 256 shots of the existing 768-shot tape. Two runs per arm/regime, ABBA ordering, isolated GPU, immutable matched producer/runtime pairs, same consumer and commands. Direct GPU disabled, sleeping enabled, dt1/60, max1 correction/max2 stress evaluations.

Complete time includes commands, physics, destruction, growth and accepted observations; rendering/networking are excluded. Candidate fracture peaks136.918/140.537ms overlap baseline141.562/136.445ms. Idle medians candidate.447/.449ms versus baseline.459/.450ms. Startup peaks around158–160ms remain visible. The first counted-state divergence is step73 in baseline/baseline and candidate/baseline. Counts are not a substitute for physical equivalence.

The screen predates the final diagnostic scope rename, private-symbol versioning and explicit initialization-error classification. Those later edits were checked by focused tests and a final exact wall prefix; the screen hashes are preserved separately from final-build hashes. No performance measurement is attributed to an unmeasured binary.

## Validation detail and known failures

- Historical wall:444 chunks/896 bonds/one projectile,600 steps;398 supported,46 detached,199 broken bonds and exact original topology signature. Ordinary32-step prefix matches its distinct mode-specific reference. Final32-step historical prefix also passes after the interface/error-reporting changes.
- Allocation oracle capacities1,127,128,129,444,4099,113664; stable device selection, valid pending retries, growth, commit once, retained owners, rejected mappings, candidate mismatch, insufficient physical storage, no partial canonical writes, correct physical initialization and previous velocity state. The fixture creates no CPU BodySim objects.
- Native allocation fixture verifies spare GPU capacity does not create actors or expand acceleration observations. A first draft incorrectly compared GPU-resident range against CPU actors added after the last step; the test now checks actual resident IDs and an exact first-split traversal bound. No pre-existing assertion was removed.
- Full native run37/43 passed initially. Five failures reproduce on the restored baseline: connectivity-fracture host-restore assertion; consumer/renderer pre-solve live-node coverage; retained-contact rows; bombardment-contact rows. The sixth failure was the fault injector targeting the removed initialization phase. It was migrated to the ordered pre-initialization capacity retry and now passes, along with allocation/correction fixtures. It still corrupts the candidate, requires rejection, unchanged geometry/material/topology and now additionally zero constructed compatibility bodies. Downstream preparation stays untouched because rejection happens earlier.
- Reporting tests9 phase-accounting and31 timing-accounting pass. Sanitizer logs, precise quality receipts, module hashes and mixed-ABI rejections are under evidence/.

## Next in strict rank order

Complete #1 by replacing CPU simulation registration and ownership prerequisites with GPU-produced scheduling/ownership state, followed by accepted CPU compatibility publication. Preserve ordinary contacts/joints and current-tick queries; do not start #2 just because allocation/initialization works. Then #2 factored structural solving, #3 persistent contacts, #4 cluster publication, #5 selective correction, #6 local activity/topology, #7 remaining passes.
