# Ordinary command correction guard — 10 September 2026

This fixes a demonstrated ordinary-API load-guard bypass in the installed native
runtime. It does not implement spatial command replay or establish a speedup.
The private factory ABI remains V14. Production stress still uses the legacy
backend; the new six-channel solver and command-motion chain remain unfinished.

## Reproduction and change

Before this change, a rotating two-chunk parent with ordinary `addForce` and
`addTorque` fractured and accepted its correction (`accepted=1`, stage error 0).
The existing guard examined checkpoint external accelerations, but this native
mode applies ordinary commands as GPU velocity deltas before the checkpoint.
Its accumulators were zero. Original sparse command history already contained
these deltas, but correction preparation did not consume it.

The native capture now marks each body receiving a nonzero additive command with
its original input generation. Both graph and explicit correction preparation
combine that mark with accumulator loads and count each affected source once.
Nonzero unknown body-level loads reject installation until an authoritative
spatial ledger can redistribute them. Zero commands and commands on unrelated
bodies do not prevent a fracture correction. Bad/stale history rejects preparation
with error bit 64; it cannot masquerade as an empty load.

The stamp buffer uses eight bytes per native capacity slot, grows geometrically,
and is zeroed only on allocation. The existing sparse capture kernel marks only
commanded IDs; the existing source inspector reads one stamp per affected source.
There is no new per-step full-pool clearing or command-by-cluster scan. GPU streams
and the original checkpoint ready event order production and consumption.

An initial focused suite caught a missing producer case: Direct GPU mode without
host access skips ordinary velocity upload. That path now explicitly publishes
an empty ordinary-command generation. Direct GPU accumulator checks remain.
The failed attempt is preserved in raw `attempt-1/`; frozen tests were not loosened.

## Validation scope

The expanded native correction fixture has 16 ordinary cases: TGS/PGS × optional
acceleration buffers off/on × force-and-torque, force-only, torque-only or zero
parent load. An unrelated ordinary body receives force in every case. Each case
uses three authored chunks, one bond, zero projectiles, three initial actors,
one setup advance and one attempted fracture advance at dt 1/60. The four zero
parent-load controls must accept exactly one correction. Twelve nonzero cases
must reject; both preparation paths count the source once, and corrupting the
original receipt must reject without changing native body bytes. Thirteen
pre-existing Direct GPU correction cases retain their checks and tolerance.

The standalone capture fixture checks sparse epoch marking, untouched body slots,
zero commands, empty later generations, invalid IDs and nonfinite history. Its
large case has 113,664 uploads and 227,329 native slots, with no physics, bonds or
projectiles. It checks the complete stamp array and exact pre-addition records.

Nine focused CTests pass (44.18 seconds total). Native correction memcheck and
all four standalone capture sanitizers pass with no findings. Loaded runtime
and PhysX GPU module hashes match the installed SDK. Commands, source patch,
module observations and hashes are indexed in [receipt.json](receipt.json).
The original bypass and failed intermediate Direct GPU case remain preserved.

## Hardware counters and Nsight limitation

One standalone capture launch, 113,664 uploads / 227,329 slots, 888 blocks × 128
threads, ten replay passes on RTX 5060 Ti / CUDA 13.4:

| Profiler duration | Registers/thread | Achieved occupancy | DRAM throughput | Spilling requests |
| ---: | ---: | ---: | ---: | ---: |
| 79.62 µs | 26 | 87.57% | 50.84% | 0 |

[Counter details](producer-counters.txt). Cache flushing was enabled, clocks were
unlocked, and desktop graphics remained active. All 7,274,496 captured record
bytes match both the unprofiled run and the prior V14 producer fixture. Both
runs also validate every stamp. This isolated synthetic kernel does not establish
complete-step cost or an implementation speedup; the added guard is necessary
correctness work, not a demonstrated optimization.

Profiling `inspectCorrectionSourceLoads` in the actual native fracture fixture
fails with stage status **1288**, rather than its expected loaded-source status
8. [Collection-disabled attachment](ncu-native-collection-off.log) fails the same
way before any counters are collected. Plain execution and memcheck pass all
29 fixture configurations. This provides a three-chunk/one-bond reproducer of
the existing attachment problem. The generated native counter report is retained
as **unqualified**; it is not used for bottleneck claims. It does not establish a
root cause or fix for the profiler's graph interaction.

Reproduce from the repository root with the rebuilt SDK:

```bash
out/destruction-sdk/reference/native_gpu_correction_body_test
/usr/local/cuda-13.4/bin/ncu --profile-from-start off \
  out/destruction-sdk/reference/native_gpu_correction_body_test
```

## Frozen ordinary wall

600 steps / 10 simulated seconds, 444 chunks, 896 bonds, one projectile, ordinary
API, sleeping enabled, dt 1/60, at most one correction. The simulation completes;
its geometric/invariant subset passes. Relative to the previous V14 capture,
topology identity, fracture/correction steps and projectile clearance match:
400 supported, 44 detached, 182 broken bonds, 39 clusters. See
[comparison](wall-comparison.json) and [invariants](wall-invariants.json).
The historical golden remains different (398/46/199/43); the full frozen wrapper
still exits 1. No golden or tolerance changed. This is a physical regression
check, not a new untraced city timing campaign. Exact 120 Hz and 60 Hz all-step
budget counts remain required for future performance qualification.

## Remaining work

Join explicit spatial command submission, authoritative before-images, GPU
trial/corrected application, complete contact/load accounting and accepted
material transactions. Removing this guard requires that physical replay to be
qualified. A body resultant does not specify its distribution among chunks.
This fix does not settle the migration's physical-equivalence failures or the
large-workload Nsight graph interaction.
