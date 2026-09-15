# PhysX physical load adapter — RTX 5060 Ti, 2026-09-10

Follow-up: [real native captures and adapter replay](../live-loads-20260910/README.md) now cover the first fracture trial/correction and later peak. They fix native generation-zero acceptance and exact free-singleton loads. This report retains the earlier standalone evidence.

Implemented a GPU adapter from PhysX full mass/inertia and surface-load records
to the new solver's physical force/moment RHS. It handles free-body inertial
relief, supplied engine acceleration, gravity, anisotropic spin and canonical
moment origins. Versioned interval receipts and a GPU gate reject stale or
failed loads before numerical acceptance.

**Native record integration with standalone numerical validation.** The live
scene producer does not invoke this adapter yet; existing production binaries
and material/correction behavior are unchanged. No new physical-equivalence,
real-time capacity or deployment qualification is claimed.

## Validation

All four fine-operator, PCG, setup and load-adapter CTests pass. The adapter
passes separate Compute Sanitizer memcheck (zero errors/leaks), initcheck,
synccheck and racecheck (zero errors/warnings). Tolerances were not relaxed.
The independent reference uses explicit rotation matrices and dense
Newton–Euler algebra, not host calls to device math.

| Fixture | Evidence |
| --- | --- |
| Six physical chunks | Nonzero, distinct COM/origin offsets; full anisotropic inertia; gravity, spin, surface and additional wrenches; free and supported/supplied-acceleration cases |
| Frame/origin changes | Common world rotation preserves asset-frame output; force/moment transport preserves canonical origin consistency |
| 129 motion aggregates | 774 chunks; independent per-body mass, COM, acceleration and effective-wrench comparisons |
| Larger aggregate | 137 chunks, loop work beyond one thread block's width; independent reference comparison |
| Impulse units | Offset-point impulse converted once by the producer at 1/60 and 1/120 s test intervals; adapter does not divide force again |
| Device solver handoff | GPU adapter → interval gate → fine RHS → projected PCG; original fine equations pass; an old successful receipt cannot bypass the gate |
| Rejections | Invalid mass/inertia/map, NaN torque, incomplete ledger, stale frame/input/ownership/evaluation/duration, wrong supplied acceleration, free relief on prescribed chunks |

These are algebra fixtures, not rigid-body simulation runs. The interval unit
test does not change the physical scene timestep from 1/60 s. The handoff uses
six nodes/eight bonds; standalone load fixtures do not evaluate bonds, spawn
projectiles or produce fractures.

An initial handoff correctly failed compatibility at ~2.52e-9. Device captures
showed ~1.19e-8 m disagreement between one legacy float position and the fine
solver's double position. The adapter now reads the canonical fine positions
directly and transports source torque to them. The passing test uses the same
GPU position allocation as the fine solver. [Preserved failure](test-origins.log).
This is a new boundary fix, not a claimed explanation for older migration pose
or sanitizer failures.

## Hardware counters

RTX 5060 Ti, CUDA 13.4.59, driver 615.71.09, Nsight Compute 2026.3.0. The selected
`build` kernel processes one batch of 129 free aggregates / 774 chunks with
gravity, spin, one supplied surface wrench and one additional wrench per group.
129 blocks × 128 threads; ten replay passes; cache flushing enabled and clocks
uncontrolled. Desktop graphics remained active. The application completes and
its independent comparisons pass after profiling.

| Metric | Observed |
| --- | ---: |
| Registers/thread | 116 |
| Achieved occupancy | 30.11% |
| Reported local/shared spilling requests | 0 / 0 |
| DRAM throughput, profiler peak basis | 0.85% |
| Profiler kernel duration | 70.62 μs |

This establishes the adapter's fixture resource footprint. It is not an
end-to-end scene timing, a bottleneck conclusion or a city-scale speedup.
Validation, real contact production, solver iterations, material processing and
publication are outside this selected kernel. Do not add replay time to the
untraced complete-step baseline. [Details](counters.txt), [metrics](counters.csv),
[capture log](ncu.log).

## Reproduction and remaining work

```bash
.toolchains/build-env/bin/cmake -S destruction -B out/destruction-sdk
.toolchains/build-env/bin/cmake --build out/destruction-sdk --target stress_elastic_loads_test -j 8
.toolchains/build-env/bin/ctest --test-dir out/destruction-sdk \
  -R '^blast_stress_six_channel_' --output-on-failure
/usr/local/cuda-13.4/bin/compute-sanitizer --tool initcheck --error-exitcode 99 \
  out/destruction-sdk/reference/stress_elastic_loads_test
```

GPU execution needs device access outside the restricted sandbox. The
[receipt](receipt.json) records final source/binary hashes, toolchain, individual
validation/counter commands, loaded modules and unchanged production-runtime
verification. [Source patch](source.patch) contains the current standalone
implementation and registration. Raw reports, module maps, intermediate
failures and logs remain in `out/six-channel-loads-20260910/`.

Read the [adapter contract](../../docs/destruction/elastic-load-adapter-contract.md).
Next: capture the real native producer window immediately after contact routing,
with matching motion/ownership and force-command provenance; wire device-owned
intervals, canonical geometry, partitions and mass certificates. Then qualify
trial/correction input histories and integrate accepted material transactions.
The completeness assertion does not itself prove that the live engine supplied
every load. Keep 120 Hz and 60 Hz exceedance counts, the separate 8 ms gate and
startup maxima in eventual complete-step campaigns.
