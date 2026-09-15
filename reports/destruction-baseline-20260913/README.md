[Current approved optimization procedure](../../docs/destruction/REMOVAL_FIRST_WORKFLOW.md): prioritize substantial work removal, ownership and algorithm changes; validate intermediate mechanisms with counters, then confirm completed bets with full-step timing. This supersedes any suggestion that every edit must resolve a tiny timing difference.

[Measured nine-scenario profiled protocol and decision precision](measured-experiment-protocol.md): **284.09s (4m44s)** for the complete GPU-exclusive pipeline with Systems and checked counters, plus separately measured1.30–1.40s preflight. Additional six-pair calibration **416.49s (6m56s)** quantifies idle/heavy/debris uncertainty. All jobs terminal; desktop restored. No implementation change or speedup. Earlier proposals and cutoff attempts below are historical.

[Recommended representative five-minute suite and noise policy](representative-suite.md): nine core scenarios, predeclared primary cases, balanced independent repeats and selected profiles. This expanded policy is proposed; the existing seven-case timing+Systems implementation is the measured164-second result.

[Measured fast profiled loop: all scenarios,134-second timing screen and164-second timing+Systems result](fast-calibration.md). All owned jobs are now terminal; desktop restored. The180-second NCU cutoff remains explicit. No new optimization.

Latest direction: [fast profiled experiments and measured calibration](fast-profiled-loop.md). The queued hours-long expansion and report finalizer are stopped. CPU52/52 and graph48/52 are qualified; continuous200 is deferred. Existing continuous180/600 baselines remain. Historical progress statements below describe the earlier collection plan.

# Selected destruction baseline: analysis campaign

Started 2026-09-13. **Exhaustive collection stopped at the user’s time budget. Available evidence is preserved; full counter coverage is incomplete.**

[Review checkpoint: completed metrics, full continuous simulations and remaining collection](review-checkpoint.md).

The frozen control is selected N13+N20, source `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`, destruction runtime SHA256 `d5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354`. Rejected N29b and N30 are excluded. All 52 physical inputs and the prior strict checker are frozen. Concurrent checker/source changes in the main workspace are preserved.

The previous 52-case profile campaign used runtime `4e1318cb…`; it remains historical evidence, not an exact profile of this control. Existing selected-control A0/A1 timings (40 samples per scenario) are retained in [the source comparison](evidence/selected-control-full52-source.json). Its rejected candidate rows are historical context, not the baseline. Full-step measurement includes current physics, stress/material/topology, transfers, waits, required CPU registration, at most one correction and final publication; restore and observation export are excluded.

New analysis runs, exports and per-case receipts are stored under `out/destruction-baseline-20260913/`. [Artifact/harness provenance](provenance.json) identifies the isolated copies. The coordinator writes [live status](campaign-status.json), serializes GPU captures, and restores the temporarily stopped desktop on completion/failure. No other GPU workload or build may overlap this campaign.

Planned capture order: seven-case CPU/GPU pilot, seven-case graph counters, full 52 CPU/GPU attribution, continuous idle/heavy attribution with separate plain controls, full graph counters, then significant ordinary-kernel configurations across all 52. All supported full metric sections are preserved. Conditional graph counters remain aggregates; unavailable node/source metrics and invalid ratios must stay explicit.

The retained strict checker proves regression agreement within its scope. It does not close the independent material-margin or full long-run orientation/velocity gaps documented in the test-coverage audit. No quality policy or runtime optimization changes in this campaign.

Reproduce only into a new campaign or explicitly resume the existing one after reviewing its terminal receipts:

```bash
python3 out/destruction-baseline-20260913/run-analysis.py
# On an inspected, terminal, interrupted campaign:
python3 out/destruction-baseline-20260913/run-analysis.py --resume
```

Updated findings, data-flow and timing plots, work/transfer ledgers, and the revised optimization queue will be added from completed measurements. Setup moved to asset loading remains visible in initialization and memory accounting; runtime growth remains inside the tick.

[All 52 selected-control timing measurements](all-scenarios.md) and [all 2,080 raw control samples](data/unprofiled-samples.csv) have been recomputed and checked. See the [analysis and provisional optimization plan](analysis-plan.md) for hypotheses, expected benefit ranges, failed approaches and the evidence required before changing the runtime. Native phase-only diagnostics are queued after the primary counter campaign to measure CPU bookkeeping without Nsight injection.

[Continuous controls](continuous-controls.md) preserve another 4,800 unprofiled ticks: idle means1.271–1.704ms, heavy51.028–51.676ms, all heavy runs519/600 60Hz misses. These remain separate from restored snapshots.

The full CPU expansion initially passed40/52 then hit an Xid120 GSP store fault in the CUPTI worker at city64-cascading-fracture teardown. That capture is quarantined even though both ticks completed. A reversible PCI function-level reset and driver reload recovered the GPU without reboot; original services were restored. Ordinary GPU reset was unsupported. Private restart state is excluded from this report. Pending CPU captures now record only the marked full tick; successful retries are evidence for a workaround, not proof of the precise fault cause. All original failed receipts remain under the raw campaign archive.

CPU attribution now passes52/52:104 checked restored ticks,22,134 CPU samples,91,538 native scopes and18,376 GPU launches. Position and linear/angular velocity differences are zero; maximum orientation-dot difference5.234e-7 passes the unchanged checker. [CPU completion audit](evidence/campaign/cpu-completion-audit.json).

Fresh180-tick continuous controls also pass exact work/iteration comparison with their profiles: idle mean1.780/peak14.139ms,0/180 deadline misses; heavy mean54.861/peak182.351ms,99/180 misses. These3-second runs are separate from the historical600-tick cohorts. [Continuous capture receipt](evidence/campaign/warm-campaign.json). The full graph/ordinary counter expansion and supplemental phase/allocation work remain in progress or queued; this is not yet a complete cross-tier baseline.

The native frame CSV writes a legacy `stress_solve_ms=0` placeholder (selected source, `native_destruction_main.cpp:396`); it is not evidence of zero stress work. Only command, integrated simulate/fetch and completion form the published unprofiled stage partition. Detailed stress/physics/CPU attribution comes from the separately labeled diagnostics.

The user requested several full continuous destruction trajectories as well. Seven existing fixtures are queued at the boundary before ordinary counters: idle256, bombardment16/256, wall1, localized impact256, bridge64 and tower64. Each runs200 ticks in three independent unprofiled processes plus separate native-phase and Systems diagnostic processes. This adds4,200 production-timed ticks and2,800 diagnostic ticks, with zero restores. Per-frame work histories must match; full body/force trajectory equivalence remains a separate qualification. After baseline collection and the completed report, optimization will remain paused for user review.
