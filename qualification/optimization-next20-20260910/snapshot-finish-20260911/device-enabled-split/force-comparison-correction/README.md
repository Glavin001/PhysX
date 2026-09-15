# Derived-force checker correction

The first matched campaign stopped after 36 successful replay processes at
`dense12-cold` because the newly added comparison required identical force bytes.
All existing repeatability, material/topology, rigid motion, convergence and
correction checks passed. The **unchanged baseline differed from itself**:

| A0 compared with | Different force scalars | Max absolute difference | Max scaled component difference | Relative L2 |
|---|---:|---:|---:|---:|
| candidate B | 25,642 | 7.62939453125e-6 | 7.125966931198491e-6 | 4.497717320921206e-8 |
| unchanged A1 | 25,650 | 1.52587890625e-5 | 9.328360931704083e-6 | 4.812523776496515e-8 |

Each run uses 34 stress iterations, no fracture, one cluster and one evaluation.
Loads, accelerations, health, active bonds, chunk ownership and crush state match
exactly. Rechecked rigid outputs pass the unchanged motion bounds. This is not
candidate evidence of lost physical quality; bitwise derived-force equality was
an additional unsupported requirement introduced by the new diagnostic wrapper.

The comparator now uses the existing `2e-4` scaled component force bound from
`demos/blast-stress-demo/tests/gpu_resident_stress_test.cu::unevenComponents`.
It requires finite values and reports maximum absolute/scaled errors, relative
L2, changed scalar count and both force hashes. Persistent physical arrays and
load inputs remain exact. Body mass/inertia/COM and identity remain exact;
position/velocity/orientation bounds and solver tolerances are unchanged.
No simulation code, material law, final convergence requirement or historical
golden was relaxed. This correction is explicit, not a suppressed mismatch.
Nine comparator tests cover force roundoff, excess force error, NaNs, material
health changes, body mass/pose changes and missing observations.

All 12 completed A0/B/A1 cohorts pass reanalysis with this checker. Their raw
measurements are reused in `out/snapshot-finish-20260911/split-matched-prefix-rechecked/`;
the original failed report remains untouched. The remaining 40 scenarios run
separately with the same frozen runtime/probe and a recorded checker hash.
Independent force-equilibrium validation is still supplied by the existing
numerical tests; A/B closeness alone is not such a proof.
