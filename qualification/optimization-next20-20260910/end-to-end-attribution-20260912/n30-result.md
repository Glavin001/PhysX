# N30: local medium-component solve — rejected, 2026-09-13

Source `8634c43c975029148b7117bd5cbff6eb763f8fda`, control `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`. The runtime and all oracle consumers build, but the candidate fails the existing3D convergence gate before application timing. No implementation retained or speedup credited.

| Numerical scenario | Control result | Candidate result |
|---|---|---|
| Original analytic columns, mixed sizes, load/topology/settled tests | Previously qualified identical binary | Pass |
|1,058-node /2,553-bond3D free component, amplitude0.5 | Converges103 iterations | Fails at256-iteration cap |
|1,058-node /2,553-bond3D supported component, amplitude0.5 | Converges149 iterations | Fails at256-iteration cap |
| New12/4,096/4,100-node mixed components, contiguous/permuted IDs | Pass analytic forces, cap rejection, subnormal checks | Pass same checks |
| New4,112-node component →2,056→1,028-node fragments | Pass twelve quiet/load transitions and exact settled output | Pass same checks |

The changed algorithm loses necessary convergence effectiveness on the3D fixtures. Routing/storage boundary examples pass, but that does not establish memory safety; sanitizer stages were not reached. The original control passes the same3D test on this GPU. Raw independent-gradient printouts are preserved; passing the existing control force/convergence test is not a claim that every printed gradient is below its nominal unrounded threshold.

No full-step idle/heavy/tower/dense candidate timings exist: numerical rejection stopped the benchmark stage. The proposed40–90ms tower and10–20ms dense savings remain refuted as an acceptable implementation, not measured gains. Previous qualifying N20 scenario timings used only to select the hypothesis were tower108.434/111.349ms, dense31.329/33.495ms, city256 idle65.998/79.530ms, initial impact240.893/288.232ms and debris382.883/452.158ms (mean/max). They are a separate cohort, not N30 measurements.

Preserve multilevel convergence on these cases; do not expand the threshold or raise iteration caps to bypass this failure. A future connected-component approach needs stronger global coupling at lower synchronization cost, or a different direct/structural method. The next queued experiment instead returns to removing provably useless equivalence-search work for a single component. That is not implemented yet; two variants of that family are already closed without promotion, so a third failure requires reassessment/research and a different approach.

[Exact commands and device admission](n30-screen.json), [control and boundary diagnostic commands](n30-diagnosis.json), [source/log hashes and outcome](n30-result.json), [preparation proof](n30-preparation.md). All build/GPU jobs terminal; desktop restored, main source/index and installed SDK unchanged.
