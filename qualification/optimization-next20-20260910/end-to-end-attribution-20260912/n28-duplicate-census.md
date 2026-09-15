# Exact duplicate solve exposure across scales

Four new native capture/reference comparisons pass: 16 full ticks, plus reused
city25 captures. No implementation change or measured speedup. All full ticks
include current physics, stress and the required correction/second stress;
restore and validation are excluded. Diagnostic capture timings are not used.

## Captured work

| Scenario | Chunks / authored bonds | First stress pass duplicate iteration-node work | Correction duplicate work |
|---|---:|---:|---:|
| city25-initial-impact | 11,100 / 22,400 | 0.0% | 51.2% |
| city64-initial-impact | 28,416 / 57,344 | 1.6–3.1% | 35.2–38.4% |
| city256-intact-idle | 113,664 / 229,376 | 99.6% | Not required |
| city256-initial-impact | 113,664 / 229,376 | 4.3–11.7% | 63.5% |
| city256-late-debris | 113,664 / 229,376 | <0.001% | <0.001% |

The percentages count iterations × nodes, not elapsed time or predicted savings.
Exact captured input groups have bit-identical normalized force outputs in both
restores. Initial-pass groups vary between independent restores, so runtime
grouping must check actual current values. More components does not imply more
saved wall time; existing independent component scheduling already runs work in
parallel. Late debris has no useful expensive exact duplicates.

This is cross-component current-input reuse, separate from reusing settled state
across ticks. Both require physical validity. The capture excludes some private
numerical caches. Four tiny correction groups in late debris differ in authored
CSR references to dead bonds; all already take zero iterations and are excluded.
Production reuse must establish complete numerical/order equivalence. A hash
alone is insufficient. Each component still requires its own damage/material
verdict and accepted physical publication.

## Plain reference tick context

Two samples per case only: these are observed full-step scopes, not statistically
qualified baselines or candidate comparisons. All impact/debris cases took one
correction/two stress passes; intact idle took zero correction/one stress pass.
Complete sample/stage/setup records are in the structured report.

| Scenario | Full-step mean / max ms | 60 Hz misses |
|---|---:|---:|
| city64-initial-impact | 75.700 / 81.105 | 2/2 |
| city256-intact-idle | 69.590 / 74.624 | 2/2 |
| city256-initial-impact | 228.980 / 229.198 | 2/2 |
| city256-late-debris | 367.751 / 380.688 | 2/2 |

## Reproduction and next experiment

The existing diagnostic module is isolated commit
`b289d68854621a17f4444d6e818b8ed59765c3b0`; no rebuild was needed. Exact binary,
module and snapshot hashes, invocation commands, physical comparisons and logs:
`out/n28-duplicate-census-20260912/campaign.json`. The frozen run script is
`out/n28-duplicate-census-20260912/run.py`; do not overwrite its outputs.

Offline census (choose a new output path to preserve results):

```bash
python3 tools/scripts/audit-native-duplicate-work.py \
  out/n28-duplicate-census-20260912/audit-manifest.json \
  /tmp/native-duplicate-audit.json
```

Next implement only after auditing original solver input/cache/order dependencies:
GPU exact leader selection, original retained solver once per equivalent anchored
problem, and ordered scatter before normal force recovery/material evaluation.
Charge equality, grouping, scatter and all setup in matched full-tick A/B/A.
Keep the untouched leader recurrence and original convergence/force/health gates.
Screen all seven light scenarios, then full52, async memory and warm trajectories.
For late debris, investigate shared operators with different loads separately;
the fresh-factor library route remains too expensive for naive on-demand city25.
Tile is an optional implementation of remaining regular work, not a substitute
for these removal and correctness decisions.

[Structured metrics and source hashes](n28-duplicate-census.json).

All new captures and offline audits are terminal/reviewed. The exclusive pause was released to collector390717 for its final ordinary case (51/52 already complete), preserving restoration watcher338813. Do not overlap a new build/GPU job. Receipt: `out/n28-duplicate-census-20260912/counter-resume.json`.
