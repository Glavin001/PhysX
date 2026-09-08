# Preserve GPU connectivity through node-storage growth

Accepted as a GPU ownership improvement after the checks below. The complete SDK and 8 ms peak/endurance gates remain unfinished.

The previous allocation path discarded current/previous node rosters during growth, required a complete CPU node snapshot, and invalidated the GPU connectivity certificate. The replacement moves both rosters device-to-device into one aligned slab and preserves the prior certificate. Only newly introduced handle holes are initialized; current lifecycle deltas still apply. Output labels/support counts are regenerated rather than copied. Growth synchronizes exceptionally before freeing old storage; that cost remains inside complete-step timing.

This does not eliminate CPU lifecycle deltas, initial bootstrap, actor reservation, shape/query registration, or full correction replay. No physical settings, damage rules, residual tolerance, or correction limit changed.

## Evidence

- Five focused solver-metadata, pre-solve island/contact/support and connectivity-owner tests pass. New growth test adds 1,047 ordinary bodies to a node domain of 1,030, producing 2,077 slots; removal/reuse and independent GPU roster/component checks pass under PGS and TGS. The fixture also contains 1,025 chunk shapes, zero bonds and quiet ordinary actors.
- An old transfer-policy assertion expected growth to force a full CPU upload. That assertion was changed for the resident path to require GPU metadata without another full upload. Physical/oracle checks were retained. The original failed run is preserved in `obsolete-growth-expectation.log`; the updated tests pass in `metadata-tests.log`.
- Connectivity-owner memory check: zero errors (`memcheck.log`). This exercises forced fallback and sleeping compatibility cases as well as the resident path; its total fallback count is not the benchmark's steady-state count.
- Frozen penetration: 444 chunks, 896 bonds, one projectile, 10 simulated seconds. Both-wall clearance and exact topology signature pass; 398 retained chunks, 46 detached, 199 broken bonds, at most one correction per step (`wall-quality.json`).
- Independent bombardment audit: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles, 180 steps. 514 boundary audits, zero failures, zero host connectivity restores. Pre-solve node/label/support checks execute separately from performance capture (`island-audit-*`). This is not a full motion-trajectory audit.
- Two candidate timing runs followed by two fresh baseline control runs, each three simulated seconds. All complete-step samples are retained. Body/contact/fracture/convergence histories match; some iteration counts differ. The initial warm-up and separate instrumented replay are recorded, but only the plain runs determine reported performance.
- Comparison-generator integrity check rejects corrupted archived raw samples (`report-integrity-test.log`).

## Automated comparison

[Open generated report](comparison.html), [Markdown](comparison.md), [machine-readable results](comparison.json).

The report compares both overall peaks and the same peak steps from either version, includes explicit CPU/GPU phase ownership, and records whole-run connectivity transfers. Raw sample hashes are checked against the capture manifests. It does not convert a failed deadline into a pass using percentiles or discarded spikes.

Regenerate from the repository root:

```sh
python3 tools/scripts/compare-destruction-candidates.py --baseline qualification/presolve-resident-growth-baseline-control/report.json.gz --candidate qualification/presolve-resident-growth-impacts-256/report.json.gz --output qualification/presolve-resident-growth
```

The generic comparison command can be reused for subsequent single-workload candidates. Archive samples and reports are sufficient for regeneration; no GPU run is needed. `validation.json` records source, runtime and evidence hashes. The saved baseline runtime contains polynomial preconditioning, unaffected warm starts and exact local inverse retention; the candidate adds only pre-solve storage preservation.

## Next opportunity

The former peak at step 103 loses CPU connectivity restoration work. First large fracture at step 82 remains expensive: fragment lifecycle/ownership and correction dominate that step. Focus on device ownership and correction scheduling there. General settled-island reuse remains missing but will not remove the changing impact loads in this simultaneous-bombardment fixture. Short-screen acceptance is not 60 Hz, the 8 ms campaign, or lifecycle endurance qualification.
