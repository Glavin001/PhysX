# Correct native support counts across prescribed-motion changes

When a supported dynamic body became kinematic, `IslandSim::setKinematic()`
removed its node from the dynamic island but retained that node's static-support
contribution in the island total. Its local count also survived, even though
switching back to dynamic reinserted the static edges. This could leave the
aggregate inconsistent with live dynamic membership and count support twice.

The transition now subtracts the departing node's contribution and clears its
local count. Later dynamic insertion rebuilds it from the actual static edges.
This is a separate native correctness fix, not a tolerance change or a CUDA-only
approximation. It applies to ordinary CPU and GPU PhysX operation.

`native_kinematic_support_test` configures no destruction stress or GPU connectivity
producer. Two touching dynamic bodies each contact one floor. It requires native
island totals to equal the sum of live-node counts immediately after a body becomes
kinematic, and checks the analytic sequence 2 -> 1 -> 2 over three cycles, followed
by zero support after floor removal. It runs CPU/GPU with PGS/TGS.

Before the fix this independent regression failed with `native island retained a
removed body's static support` (`out/native-kinematic-support-before.log`). After
the fix it and all pre-solve producer/kernel/fracture parity checks passed: six
CTest entries in `out/native-gpu-support-corrected-tests.log`. The complete SDK
build passed (`out/native-kinematic-support-fixed-build.log`). The strengthened
GPU fixture also moves the floor away/back and changes motion mode while the
floor remains in contact; its exact native and CUDA count comparisons now pass.

Reproduce with:

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 4
ctest --test-dir out/destruction-sdk -R '^physx_native_gpu_kinematic_support$' --output-on-failure
```
