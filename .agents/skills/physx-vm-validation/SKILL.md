---
name: physx-vm-validation
description: Build and validate the migrated PhysX destruction SDK on vast-new RTX 5060 Ti with CUDA 13.4, and diagnose its recorded migration failures.
---

# VM build and validation

Read [AGENTS.md](../../../AGENTS.md) first for current contract/status. Commands
below run on the VM in `/root/workspace/physx-2`. Remote control from the old
machine uses `ssh vast-new`; do not assume that alias exists inside the VM.

## Build and artifact ownership

```bash
export PATH="$PWD/.toolchains/build-env/bin:/usr/local/cuda-13.4/bin:$PATH"
python tools/scripts/build-destruction-sdk.py --jobs 8 \
  --cuda /usr/local/cuda-13.4/bin/nvcc --cuda-architectures 120 \
  --cc /usr/bin/clang --cxx /usr/bin/clang++ --gpu-renderer
```

The helper builds/installs the SDK and writes `out/sdk-artifacts.json`. For narrow
edits use the affected incremental targets, then refresh install/hash evidence:

```bash
cmake --build out/sdk-release --target PhysX PhysXGpu PhysXDestructionGpuRuntime -j6
cmake --build out/destruction-sdk --target native_destruction_consumers -j6
cmake --build out/destruction-sdk --target gpu_resident_stress_test gpu_resident_stress_3d_test gpu_resident_motion_modes_test -j6
```

Cold PhysX articulation compilation took minutes in `cicc`; check its CPU activity
before calling it hung. Do not repeat full clean builds after each kernel edit.
Rebuild all ABI consumers together. The new VM has not qualified Rust/game/WASM.

| Artifact | Meaning |
|---|---|
| `physx/bin/linux.x86_64/release/libPhysXGpuActivity_64.so` | Actual PhysX GPU module name |
| `physx/bin/linux.x86_64/release/libPhysXDestructionGpuRuntime_64.so` | Integrated destruction CUDA runtime |
| `out/destruction-sdk/reference/native_destruction_demo` | Integrated demo despite historical `reference/` directory |
| `out/install/` | Installed SDK |
| `out/vm-topology/` | Eight standalone topology/lifecycle executables |
| `out/vm-runtime-build/`, `out/vm-runtime-artifacts/` | Isolated migration investigation outputs; NOT selected production libraries |

Inspect actual mapped modules during captures; `ldd` alone misses runtime-loaded
PhysX GPU libraries. Never mix diagnostic/old GPU modules and rebuilt consumers.

## Reproduce only the checks needed

No GPU test run is needed for docs-only changes. For code, select focused tests;
GPU jobs/sanitizers run sequentially, separately from builds/performance captures.

```bash
ctest --test-dir out/destruction-sdk \
  -R '^physx_native_|^destruction_gpu_|^blast_stress_gpu_resident_(analytic|3d|motion_modes)$' \
  --output-on-failure -j1
ctest --test-dir out/vm-topology --output-on-failure -j1
python tools/scripts/test-destruction-timing.py
python tools/scripts/test-native-phase-analysis.py
python tools/scripts/test-native-gpu-profile.py
```

Broad migration screen: 57/61 passed. The standalone eight and smoke six are
subsets, not additional unique passing native tests. Four failed test names:

- `physx_native_gpu_state_initcheck_accepted-properties`
- `physx_native_gpu_state_initcheck_accepted-properties-pgs`
- `physx_native_gpu_bombardment_contacts`
- `physx_native_standard_bombardment_contacts`

Use `ctest -N` to verify current names after CMake changes. Preserve failure exit
codes/logs; do not hide errors with unconditional success wrappers.

Frozen wall command, with a NEW output name each time:

```bash
python tools/scripts/run-destruction-penetration-regression.py \
  out/NEW-EXPERIMENT-wall-standard --standard-scene --sleeping 1
# Historical Direct GPU control (omit --standard-scene):
python tools/scripts/run-destruction-penetration-regression.py out/NEW-EXPERIMENT-wall-direct
```

These are 600-step / 10-second heavy audits: 444 chunks, 896 bonds, one projectile,
GPU rendering and motion readback. They are not performance qualification. Both
currently fail different gates; do not update goldens/tolerances. The ordinary
capture also has `invariants.json` from the verifier without `--golden`: that is
only the geometric/physical invariant subset, never a substitute for frozen parity.
Use `.toolchains/build-env/bin/python` (NumPy installed). Initial ordinary audit
completed its simulation but lacked NumPy for analysis; analysis was rerun on the
same capture after installing it, not recaptured.

## Known failures and evidence

[Migration report](../../../qualification/rtx5060ti-cuda134-20260910/README.md)
contains exact counts, source receipts and the standalone CUB reproducer.
All new raw outputs are in `out/vm-port-20260910/`:

- `native-tests-fixed.log`: valid 57/61 broad suite. Earlier `native-tests.log`
  had GPU loader failures before the CUDA 13 host-stub fix; do not use it as
  numerical evidence.
- `wall-standard/`, `wall-direct/`: complete original new-device wall captures.
- `pose-diagnostic.log`: first discrepancy; actor positions match while quaternion
  w differs (~0.99999994 versus 1). Cause unproved; changing to aligned transform
  arithmetic did not fix it and was reverted. No temporary logging remains.
- Valid first large captures: `/tmp/physx-bombardment-contacts-s3eh674l/capture/`
  (Direct GPU), `/tmp/physx-bombardment-contacts-r29ng8ds/capture/` (ordinary).
  `9sercd3y` / `xtzg3_q5` are the unsuccessful aligned-transform experiment.
- `scan-probe.cu` and `scan-probe-poisoned.cu`: reproduce initcheck warnings outside
  PhysX with correct CUB exclusive sums. Poisoning control removes warnings but
  proves neither full native safety nor an exact toolkit bug. No production
  initialization passes or sanitizer suppression were added.

For migration attribution compare matching API mode/settings on the old baseline,
then localize the first different input/response/verdict. GPU and toolkit changed
at once; final counts cannot identify which caused a difference. Historical
exact-wall captures are referenced in older qualification records but their raw
`out/` files may still exist only on the old host.

## Port-specific pitfalls

- Native target is `sm_120`, not old `sm_89`. Only CUDA >=13.4 is supported by this
  branch; do not silently select `/usr/bin/nvcc` (previously CUDA 11.5).
- CUDA 13 context creation uses the nullable context-parameters argument; graph
  dependency APIs gained edge-data arguments. Current installed headers are the
  authority. Do not restore obsolete signatures or CUB aliases.
- New NVCC emits `__cudaGetKernel`/`__cudaLaunchKernel`. The PhysX private wrapper
  exports rejecting host stubs because real upstream kernels use driver dispatch.
  Do not turn these into successful no-ops. Native load/solve smoke tests passed.
- Current CCCL needs C++17 in broadphase. CUDA headers are SYSTEM includes for
  CPU compilation; this does not relax native source warnings.
- Keep `libPhysXDestructionGpuRuntime` mathematical flags separate from upstream
  PhysX fast-math flags. Blanket flag changes would confound parity investigation.
- Reboot/driver repair is already complete. Do not reapply the old failed APT
  recipes or remove packages as part of ordinary validation.
