# Diagnostic per-component sparse work

The native small-component solver now has compile-time-only records for each component: dynamic rows, CSR entries and live directed references per sweep, residual/verification/direction sweeps, numerical iterations, convergence, CTA owner and local elapsed cycles. All component records are retained; insufficient capacity raises an explicit diagnostic error. Larger cooperative components are marked unmeasured, never silently included as zero work.

These records count the node-space matrix operator, not all memory operations or all floating-point instructions. The graph is immutable within a solve, so one adjacency census is multiplied by actual active sweeps. Directed references count a dynamic/dynamic bond twice and a dynamic/static bond once. CSR tombstones count as visits but not live contributions. Residual reconstruction, preconditioner and hierarchy work are separate and are not included in these operator visit totals. CTA cycles include diagnostic overhead and are not additive GPU milliseconds or hardware utilization.

## Validation

- Independent graph enumeration: intact building has 444 chunks, 896 bonds, 380 dynamic stress nodes and 1,540 directed dynamic adjacency references per sweep.
- One and 256-building stress-only gravity fixtures pass the registered CTest checks. No rigid-body physics, projectiles, damage or correction occur in these fixtures.
- Each cold component executes 86 updates, 87 residual sweeps, one verification sweep and 86 direction sweeps. For 256 buildings (113,664 chunks, 229,376 bonds), that totals 22,016 component updates, 16,926,720 node visits and 68,597,760 directed adjacency visits.
- Each unchanged warm solve performs zero updates but still checks/verifies the residual: 194,560 node visits and 788,480 adjacency visits across the 256 buildings. Zero numerical iterations does not mean zero work.
- CUDA memcheck and synccheck pass on the one-building recorder. The recorded fixture asserts expected component and graph counts, update/iteration agreement, convergence and capacity validity.
- Normal-build preprocessed component-kernel tokens are identical to the committed baseline; all new symbols, counters and clock reads compile out. Production timing is not inferred from instrumented fixture timings.
- Frozen ten-second penetration quality passes: 444 chunks, 896 bonds, 398 supported, 46 detached, 199 broken bonds, exact topology identity and correction maximum one.

## Reproduce

```sh
cmake --build out/destruction-sdk --target gpu_resident_stress_phase_probe -j 4
ctest --test-dir out/destruction-sdk -R '^blast_stress_component_work_' --output-on-failure
out/destruction-sdk/reference/gpu_resident_stress_phase_probe 256
```

The JSONL output includes all component records and totals. Compressed raw fixture captures and machine-readable totals are retained here. This validates the recorder; it does not measure the 256-building bombardment peaks. Connecting diagnostic observation to that full scene and instrumenting the large-component path remain necessary. The production iteration/convergence policy is unchanged.
