# Persistent GPU chunk index: tested, not promoted

**Standalone candidate rejected for production and reverted.** It replaces two
scene-wide binary searches per solved contact with a persistent paged GPU index,
and skips ordinary-only pairs before loading destruction metadata. Correctness
checks pass, but matched whole-step screens do not establish a useful performance
improvement. No live runtime, service or source sibling was changed.

This is a disposition for the tested L2 implementation, not a claim that all
shape identity work is optimal. Sharing identity with the final GPU ownership
representation remains a different possible implementation; do not repeat this
standalone table experiment unchanged.

## Matched measurements

Baseline is the exact settled-reuse predecessor (69f601ad...), not the older
live runtime. Both arms use Direct GPU OFF, sleeping ON, dt=1/60, at most one
correction and two stress evaluations. Complete-step timing includes commands,
physics, destruction, correction and accepted consumer events/snapshots; it
excludes rendering/networking. First-step spikes remain in every run.

**256 buildings, 113,664 chunks, 229,376 bonds; zero-shot intact idle and 768-shot
bombardment.** Two runs per arm/regime, 600 steps / 10 simulated seconds each,
in baseline/candidate/candidate/baseline order with attested modules and no
concurrent GPU work:

| Metric | Baseline ms | Candidate ms | Finding |
|---|---:|---:|---|
| Intact-idle p50 | 0.431–0.439 | 0.413–0.421 | Small observed difference; no extra idle mechanism established |
| Bombardment fracture peak | 134.671–138.395 | 134.923–135.188 | Overlapping ranges; no robust peak improvement |
| Bombardment complete mean | 43.833–45.048 | 43.782–46.080 | No consistent improvement |
| Bombardment all-step peak | 160.178–162.722 | 163.168–164.848 | Candidate worst peak higher; startup retained |

[Generated idle comparison](idle/report.md) · [Generated bombardment comparison](shots/report.md).
Do not combine the incidental idle difference with the earlier independently
measured settled-reuse benefit. Settling, sleeping-rubble and reactivation are
not independently qualified by these runs. No five-run/endurance/60 Hz claim.

A **separate instrumented pair**, same city and 768-shot/600-step workload,
selects fracture tick 48 in both arms: 10,449 fragments, 10,193 awake, 216,220
reported normal contacts, 57,788 cumulative broken bonds and one correction.
The contact-load interval (including preparation, both stress evaluations)
changes **0.278528 → 0.271360 ms**; across all 600 steps its mean changes
**0.251930 → 0.244214 ms**. This single diagnostic pair does not isolate the
lookup kernel from the rest of load preparation or establish statistical
significance. Complete diagnostic advances are 142.946 → 143.295 ms; stress
intervals are 31.004 → 32.313 ms. These intervals overlap and are not additive.

[Baseline phases](baseline-phases/report.md) · [Candidate phases](candidate-phases/report.md).
The observed load-stage difference is small compared with the remaining lifecycle
and active-stress exposure. A simpler-looking kernel alone is not a qualified
whole-step win. The candidate is archived rather than left as another production
branch or unpromoted implementation.

## Correctness evidence

- Focused GPU identity test passes: empty mapping, page boundaries, sparse and
  full-width IDs, missing/ordinary endpoints, replaced mappings/recycled IDs,
  duplicate/invalid input rejection and untouched output guards.
- Scale fixture: 113,664 identities, 340,992 queries, independent CPU dictionary
  oracle. CUDA memcheck and initcheck report zero errors. This is an indexing
  fixture, not a rigid-body or destruction performance benchmark.
- Ten integrated material, contact-reporting, correction and ordinary sleep/wake
  regressions pass with the candidate library selected.
- Historical penetration: 444 chunks, 896 bonds, one projectile, 600 steps;
  exact unchanged topology signature, 398 supported chunks, 46 detached,
  199 broken bonds, 43 clusters, real entry/exit clearance and max correction one.
  This historical fixture uses Direct GPU mode; it does not resolve the known
  ordinary-mode/historical-golden difference.
- In the large screen, the first counted-state divergence is tick 74 for both
  baseline-versus-baseline and candidate-versus-baseline comparisons. Identical
  peak counts alone are not a complete physical-equivalence oracle.

## Reproduce and inspect

[Candidate patch](candidate.patch) contains the implementation and independent
test target. Apply it to the recorded predecessor source to rebuild; no alternate
production switch remains. Existing isolated binaries and captures are under
`out/native-chunk-index-20260909`. [Evidence](evidence/) retains build/test logs,
module hashes, attestation, controlled quality output and command receipts.

The existing paired runner now accepts `--baseline-runtime` and `--title`:

```sh
python3 qualification/native-settled-20260909/run-screen.py \
  --capture NEW_CAPTURE --reports NEW_REPORTS \
  --baseline-runtime out/native-settled-local-20260909/candidate/libPhysXDestructionGpuRuntime_64.so \
  --title 'Persistent GPU chunk identity index'
```

Place the archived candidate runtime in `NEW_CAPTURE/candidate/` first. The
separate [phase runner](profile-pair.py) uses fixed archived paths and refuses
an existing output or occupied GPU. Neither runner controls services.
