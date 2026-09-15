# Six-channel projected GPU iteration — RTX 5060 Ti, 2026-09-10

Historical combined-kernel baseline. The subsequent
[persistent-setup implementation](../six-channel-setup-20260910/README.md)
preserves its equations and checks while separating reusable setup from iteration.

The new private solver now performs scaled, projected block-PCG on the GPU.
It validates connected component descriptions, constructs all six free rigid
modes, rejects incompatible loads before projection, and checks the original
fine equations and per-node force/torque balance before reporting linear
convergence. Component reductions and stopping decisions are independent.

**Standalone numerical foundation; production engine integration is pending.**
The current PhysX destruction runtime remains unchanged. These results do not
resolve the migration's physical-equivalence failures or establish a performance
improvement. See the [contract](../../docs/destruction/elastic-operator-contract.md)
for equations, explicit test tolerances, failure states and remaining work.

## Validation

CUDA 13.4.59, driver 615.71.09, RTX 5060 Ti / sm_120. One execution of each
registered test after the final build: both pass. The projected solver also
passes separate Compute Sanitizer memcheck (zero errors/leaks), initcheck,
synccheck and racecheck (zero errors/warnings). These sanitizer executions are
correctness checks, not timing samples.

| Fixture | Scope and independent evidence |
| --- | --- |
| Coupled cyclic graph | Six nodes, eight bonds; supported/free variants; scales 0.25, 1 and 4; nonzero prescribed/inelastic RHS; dense CPU solution/original equations; one non-bridge deletion |
| Free rigid modes | Large translated/rotated warm start; independent scaled gauge and interface-response uniqueness; each incompatible force/moment channel rejected |
| Mixed batch | 129 components, 774 nodes, 1,032 bonds (989 live), 65 whole-node supports; 19 zero-load components; 110 iterating components, 2,318 summed iterations, maximum 25 |
| Larger components | Separate supported/free 137-node stars, 136 bonds each; CPU sparse endpoint-matrix oracle; supported block-diagonal problem converges in one iteration |
| Input/numerical boundaries | Fully prescribed and isolated nodes, stale/disconnected partition, cross-component live edges, arbitrary valid permutation, invalid map, NaN/overflow, invalid scale/profile, exact warm start, zero/one iteration limits |

There are no projectiles, rigid-body simulation steps, material decisions or
physics durations in these fixtures. Node count is not a destruction-capacity
claim. Independent host dense/sparse math is test-only; no engine CPU fallback
was added. Test tolerances are supplied explicitly and are not release settings.

An initial initcheck attempt found uninitialized padding in the 48-byte solver
receipt copied to the host: three 32-bit fields left a four-byte alignment gap
before the doubles. That gap is now an initialized true-residual-check counter,
and a layout assertion verifies that every transferred byte is a named field.
The corrected executable passes initcheck without zeroing workspaces to hide
reads or suppressing checks. The earlier 190-error log is preserved at
`out/six-channel-pcg-20260910/initcheck-final.log`. This finding is separate from
the unresolved production CUB/migration initcheck investigation.

## Hardware counter scope

Nsight Compute successfully runs the batch-only fixture through completion,
using one selected `solveComponents` launch, ten kernel-replay passes, cache
flushing enabled and clock control disabled. The batch's independent CPU checks
pass and its summed/max iteration counts match the unprofiled execution.
Actual loaded-module maps are captured for both ordinary test executions and
the final profiled target. Existing desktop graphics remained active.

| Final batch counter | Value |
| --- | ---: |
| Registers/thread | 228 |
| Resident block limit from registers | 2 |
| Theoretical / achieved occupancy | 16.67% / 15.32% |
| Eligible warps per scheduler | 0.05 |
| Reported local / shared spilling requests | 0 / 0 |
| DRAM throughput, profiler peak basis | 0.06% |
| Profiler kernel duration | 2.80 ms |

See [counter details](counters.txt) and [raw metrics](counters.csv). This launch
has 129 blocks × 128 threads, but only six nodes per component; idle lanes and
this fixture's synchronization costs do not represent 444-node buildings. The
register footprint is useful implementation evidence. Kernel replay duration
and profiler speedup estimates are not accepted complete-step timing or city
capacity forecasts. The production conditional-graph Nsight issue remains
unresolved; this standalone target does not execute those graphs.

## Reproduction and next work

All commands run at the repository root; GPU commands require device access
outside the restricted sandbox. Existing SDK build caches are retained.

```bash
.toolchains/build-env/bin/cmake -S destruction -B out/destruction-sdk
.toolchains/build-env/bin/cmake --build out/destruction-sdk \
  --target stress_elastic_operator_test stress_elastic_pcg_test -j 8
.toolchains/build-env/bin/ctest --test-dir out/destruction-sdk \
  -R '^blast_stress_six_channel_(operator|pcg)$' --output-on-failure
/usr/local/cuda-13.4/bin/compute-sanitizer --tool initcheck --error-exitcode 99 \
  out/destruction-sdk/reference/stress_elastic_pcg_test
```

[Receipt](receipt.json) includes exact source and executable hashes, selected
counter command, loaded modules, toolchain and individual validation commands.
[Source patch](source.patch) records the implementation and target registration.
Raw logs, maps, failed attempts and counter report remain in
`out/six-channel-pcg-20260910/`. The SDK's production attestation is unchanged;
the standalone test binaries have this separate receipt.

Next: separate persistent setup from recurrence where counters justify it,
connect GPU-owned component topology and load packets, and qualify the engine
adapter's impulse interval, inertia, free-spin and support conventions. Then
integrate trial/accepted material and correction transactions. Structural
acceleration must retain the current fine equations and acceptance checks.
Every eventual whole-step campaign must report both >1000/120 ms and >1000/60 ms
exceedances, alongside the separate 8 ms gate and all startup peaks.
