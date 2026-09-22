# CuMetal SDK backend configuration probe

This fixture performs CMake configuration/export checks only. It does not build
or execute a kernel, install a package, or establish numerical SDK acceptance.
It uses the actual topology source and repository-local CuMetal artifacts, not
mock CUDA headers or substitute kernels. Executed results are recorded below;
configuration success is not complete SDK linkage or installation.

## Executed evidence (2026-09-21)

The coordinating agent ran six isolated configure probes through the repository-
confined runner. `../cuda-metal/out/tests/pointer-tuples/command-675.log`
records all six expected outcomes. Individual logs in that same directory show:

| Probe / log | Observed result |
|---|---|
| `sdk-config-positive.log` | Exit 0; configuration and export generation completed in `PhysX/out/tests/backend-config/positive`. The probe's native-object, CXX-linker, no-NVIDIA-compiler and relocatable runtime-target assertions passed. |
| `sdk-config-missing_compiler.log` | Expected exit 1; rejected missing repository-local `CUMETALC_EXECUTABLE` at `cuda-metal/out/no-such-cumetalc`, with a manual-prerequisite report. |
| `sdk-config-invalid_backend.log` | Expected exit 1; rejected a backend other than CUDA/CUMETAL. |
| `sdk-config-capacity_0.log` | Expected exit 1; rejected capacity below the valid 1–944 range. |
| `sdk-config-capacity_945.log` | Expected exit 1; rejected capacity above the valid 1–944 range. |
| `sdk-config-capacity_abc.log` | Expected exit 1; rejected a noninteger capacity. |

The positive log identifies AppleClang 15.0.0.15000309 and successful CMake
configuration/generation. These probes did not build project targets, execute
GPU kernels or install packages; CMake's ordinary compiler/ABI checks are part
of configuration. Unused registry/fetch-option notices do not indicate that a
package was downloaded or installed.

Additional, separately scoped execution:

- `command-679.log`: the **real destruction SDK project** configured and
  generated successfully at `PhysX/out/tests/sdk-config/macos-cumetal`, using
  the same-configuration GPU-enabled host archives, `PX_GPU_BACKEND=CUMETAL`,
  real CuMetal artifacts, renderer OFF and CUPTI OFF. This proves configuration
  beyond the small probe. It does not prove every generated target links.
- `command-680.log`: built the actual `PhysXDestructionTopologyGpu` static
  archive and `destruction_rigid_iteration_limits_test` through the generated
  source-first native-AOT rules.
- `command-681.log`: the single CTest `destruction_gpu_rigid_iteration_limits`
  passed in 0.28 s with Apple M3 Max kernel-launch provenance. It checked
  active rigid iteration limits for 0, 1, 257, 4,099 and 113,664 bodies, explicitly
  **with no bonds**. This is iteration-limit reduction coverage, not a stress,
  fracture, complete topology-suite or full-scene qualification.

Complete production GPU dylib linkage/loading, the full SDK target build,
explicit staged installation, relocated `PhysXDestruction::NativeScene`
consumer execution and integrated destruction remain unproved by these logs.
No Linux CUDA execution or NVIDIA sanitizer result is claimed.

## Reproduction

Paths below are relative to the PhysX repository root and assume a sibling
CuMetal checkout named `cuda-metal`; adjust that sibling path if needed.
Resolve the roots in the current shell before passing paths to CMake:

```sh
PHYSX_ROOT="$(pwd -P)"
CUMETAL_ROOT="$(cd ../cuda-metal && pwd -P)"
```

Run through the existing repository-confined command runner, in an isolated
repository-owned output directory, with the installed Apple compiler/SDK and
these arguments (the coordinating agent chooses a fresh command log ID):

```text
cmake -S "${PHYSX_ROOT}/destruction/tests/backend-config"
      -B "${PHYSX_ROOT}/out/tests/backend-config/cumetal"
      -G "Unix Makefiles"
      -DPX_GPU_BACKEND=CUMETAL
      -DCUMETAL_ROOT_DIR="${CUMETAL_ROOT}"
      -DCUMETALC_EXECUTABLE="${CUMETAL_ROOT}/out/build/macos-cumetal/release/cumetalc"
      -DCUMETAL_LIBRARY="${CUMETAL_ROOT}/out/build/macos-cumetal/release/libcumetal.dylib"
      -DCUMETAL_CUDA_CLANG=/opt/homebrew/opt/llvm@21/bin/clang++
      -DCMAKE_EXPORT_PACKAGE_REGISTRY=OFF
      -DCMAKE_FIND_USE_PACKAGE_REGISTRY=OFF
      -DCMAKE_FIND_USE_SYSTEM_PACKAGE_REGISTRY=OFF
      -DFETCHCONTENT_FULLY_DISCONNECTED=ON
```

The probe checks that no NVIDIA language/compiler was discovered; one native
AOT object was generated for the real topology translation unit; the link uses
CXX; and the exported dependency uses CuMetal::Runtime without embedding the
absolute build-tree runtime filename. Real export generation also validates
usage requirements. A missing prerequisite or invalid backend/capacity must
produce a configure error without invoking any installer.

Negative configuration checks may override CUMETALC_EXECUTABLE with a missing
repository-local path, PX_GPU_BACKEND with an invalid value, or
PX_CUMETAL_TGS_WHOLE_ISLAND_MAX_BODIES with 0/945/noninteger values; use separate
output trees. The six results above are already executed evidence; any new
configuration or negative case must be executed before it is reported as passed.

The normal SDK workflow remains tools/scripts/build-destruction-sdk.py. Its
explicit CuMetal SDK acceptance guard remains in place while the production
runtime, complete scene and numerical/package qualification remain unfinished.
NVIDIA compute-sanitizer tests are not registered under CuMetal; that is an
unavailable qualification, not a passing sanitizer result. Requesting the old
NVIDIA EGL renderer or CUPTI under CuMetal fails explicitly. A native Metal
rendering consumer still needs implementation.
