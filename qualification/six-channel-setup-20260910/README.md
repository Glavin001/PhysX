# Persistent GPU setup — RTX 5060 Ti, 2026-09-10

Subsequent work implements the [PhysX-record load adapter](../six-channel-loads-20260910/README.md)
and its device handoff; the setup evidence below remains the recorded baseline.

Separated fine-equation setup from projected PCG recurrence. Connectedness,
scaled rigid modes and diagonal Cholesky factors now have a retained GPU
receipt. A matching producer revision reuses that setup; a stale or missing
receipt cannot enter iteration. The fine equations, FP64 arithmetic, residual
tests and material/engine integration status are unchanged.

**Standalone architecture and resource improvement, not a city-scale speedup.**
Engine-owned revision production and component repartition are still pending.
The existing PhysX destruction runtime remains unchanged and migration physical
qualification failures remain unresolved. The [contract](../../docs/destruction/elastic-operator-contract.md)
defines the admitted inputs, version obligations and output limitations.

## Verified behavior

All three registered fine-operator, PCG and setup CTests pass. The PCG and setup
targets each pass separate memcheck, initcheck, synccheck and racecheck runs:
eight sanitizer executions, no errors, race warnings or device leaks.
[Validation commands](validation.json), [CTest log](ctest-final.log).

The existing six-node dense/analytical references, 129-component batch and
137-node supported/free fixtures remain. No tolerances were relaxed. Added
checks exercise load/inelastic-reference reuse, changed stiffness/deletion/
supports, every revision field, scale and setup-policy changes, unchanged
stopping-policy changes, an invalid partition after a split and selective
rebuild of one of two components. The batch solves twice with identical
iteration counts, matching solutions and one setup per component.

These are algebra fixtures with no projectiles, physics steps or material
transactions. Current setup is keyed by caller-supplied revisions. It does not
detect an unreported producer write, construct new partitions or certify an
accepted physical result. The future engine producer must own those revisions
and phase-order every update, validation, preparation and solve.

Nontrivial components build factors on initial setup even if their first RHS
is zero. Isolated free nodes do not factor. A verified zero residual needs no
preconditioner application; numerical factor failures remain explicit when
iteration is required. Initial setup cost must remain in subsequent performance
campaigns, alongside warm-load and intact-idle measurements.

## Counter evidence

CUDA 13.4.59, driver 615.71.09, RTX 5060 Ti / sm_120; desktop graphics remained
active. One standalone batch contains 129 components, 774 nodes and 1,032 bonds
(989 live), with 65 whole-node supports. Nineteen components have zero loads;
110 iterate. Each solve uses 2,318 summed iterations, maximum 25, matching the
[combined-kernel baseline](../six-channel-pcg-20260910/README.md).

Nsight Compute collected four consecutive selected kernels: fresh preparation,
recurrence, cached preparation and recurrence. Ten kernel-replay passes per
kernel, cache flush enabled, clocks uncontrolled. The application completes
and its independent checks pass after profiling. Loaded-module maps and hashes
were recorded for that actual profiled target.

| Kernel | Registers/thread | Achieved occupancy | Profiler duration |
| --- | ---: | ---: | ---: |
| Previous combined setup/solve | 228 | 15.32% | 2.80 ms |
| Fresh preparation | 230 | 15.61% | 320.26 μs |
| New recurrence, first solve | 128 | 24.38% | 2.06 ms |
| Cached preparation | 230 | 15.81% | 10.08 μs |
| New recurrence, repeated solve | 128 | 24.38% | 2.06 ms |

Recurrence's register block limit rises from two to four resident 128-thread
blocks per SM; theoretical occupancy rises from 16.67% to 33.33%. No local or
shared spilling requests were reported in either implementation. The evidence
supports separating the setup register lifetime from iteration and retaining
unchanged setup. It does not establish a whole-step speedup.

Each batch component has only six nodes, so many lanes are idle. Do not
extrapolate its scheduling/occupancy or timings to 444-node buildings. These
are profiler kernel durations from separate replay measurements, not an
untraced complete-step comparison; do not add them into a claimed frame time.
Graph/partition validation, transfers, engine work, material recovery and
publication are outside the selected kernels. Profiler speedup estimates are
not adopted. [Full counters](counters.txt), [raw metrics](counters.csv),
[capture log](ncu.log).

## Reproduction and continuation

```bash
.toolchains/build-env/bin/cmake -S destruction -B out/destruction-sdk
.toolchains/build-env/bin/cmake --build out/destruction-sdk \
  --target stress_elastic_operator_test stress_elastic_pcg_test stress_elastic_setup_test -j 8
.toolchains/build-env/bin/ctest --test-dir out/destruction-sdk \
  -R '^blast_stress_six_channel_' --output-on-failure
```

[Receipt](receipt.json) records exact commands, source/binary hashes, loaded
modules, validation and unchanged production-runtime verification.
[Source patch](source.patch) records the complete current standalone sources
and target registration. Raw captures and the previous PCG executable remain
under `out/six-channel-setup-20260910/`. No new GPU jobs remain live.

Next, implement the engine load adapter at `prepareLoads` / `contactLoad` in
`physx/source/gpudestruction/src/PxgDestructionRuntime.cu`. The existing path
uses acceleration-style solver inputs and stores physical contact torque in
the separate surface-load channel. The new operator requires explicit physical
force/moment loads, one documented impulse interval and engine-consistent
inertial relief, with no double-counted torque or inertia. Map its angular-first
legacy records explicitly into the new translation-first vectors. Wire actual
producer revisions and topology before introducing accepted material/correction
transactions. Do not replace the engine backend using only these algebra tests.
