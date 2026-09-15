# Optimization stopped — 2026-09-13

User instruction: **stop and save**. Do not resume builds, tests, profiling or optimization without a new user instruction. All owned build/GPU jobs are terminal; no coordinator is pending. Desktop services were restored after the preceding diagnostics. Other clients are untouched.

## Saved implementation state

- N29c source WIP: `441140978c5544fcaeb73749c4842728568ec240`, branch `codex/n29c-conditional-reuse-20260913`, parent N29b `c2644fa00b64f6a3f34ca8ced02b5825803bd860`. **Unbuilt, unreviewed, untested; no gain claimed.**
- Workspace: `out/n29c-conditional-reuse-20260913/`; preparation manifest is also archived in the qualification directory as `n29c-preparation.json`.
- Hypothesis: skip exact-problem matching when the current GPU component count is at most one, through one CUDA graph IF/ELSE. The false branch invokes the original component solver with a null reuse-leader pointer. No CPU readback or numerical-policy change intended.
- Next authorized work would first review/compile graph API signatures, branch tests and copied build dependencies. No screen runner or frozen-checker runner is prepared. Nothing in this WIP is qualified.
- Selected isolated control remains `13b11af2e0aeabf4e0070931fbd8a060f383dfaf` (N13 numerical policy, retained N20 CPU capacity and corrected snapshot substrate). Broad final composition qualification is still incomplete.
- Main source/local runtime remains the prior N14/snapshot work; isolated candidates were not applied. Installed SDK remains original A. Main index and unrelated user changes are preserved.

## Last completed experiments

N29b is closed without promotion: all 52 restored scenarios passed physical comparison over 3,120 full ticks, but ladder128-warm regressed again in the separate repeat (control/candidate/control means 4.909/5.699/4.998 ms). Continuous heavy means stayed around 51 ms and all runs missed 60 Hz on 519/600 ticks; improved observed peaks did not justify promotion. Full scenario means/maxima/stages and raw evidence are in [the report](../../reports/destruction-exact-solve-reuse/README.md). Full-suite asynchronous memory and extended wall trajectory qualification were not pursued.

N30 (`8634c43c975029148b7117bd5cbff6eb763f8fda`) is rejected: expanding the component-local solve threshold to 4096 failed the existing 3D convergence gate. Candidate reached 256 iterations unconverged; controls converged in 103/149 iterations. No application timings or speedup credited. See [N30 result](../../qualification/optimization-next20-20260910/end-to-end-attribution-20260912/n30-result.md).

## Preserve provenance

Concurrent edits to `compare-observations.py`, `test-compare-observations.py` and `tools/scripts/destruction_physics_contract.py` belong to other ongoing work. Do not reset or sweep them into this candidate. N29b used archived `reports/destruction-exact-solve-reuse/evidence/physical-checker.py`, SHA256 `6f256f04de9fd87774593cba6ef1dc5455bfbb5cbbd909779ec9e3afb0bbab31`. Do not silently substitute a changed checker mid-campaign.

The original next-20 batch is complete; subsequent candidates are separate experiments. No final optimum, overall composition gain or completed optimization goal is claimed. If N29c eventually fails, reassess the matching family before another local variant.
