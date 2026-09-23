# Building the destruction SDK

For the repository-contained CUDA/CuMetal qualification, see the
[current compatibility inventory](../CUMETAL_COMPATIBILITY.md) and the
[paused current handoff](../CUMETAL_HANDOFF.md). The restricted native macOS
destruction demo now builds and runs, but its wall collision correctness is
unresolved and the complete SDK is not qualified. The handoff records current
commands and newer evidence that supersede older status statements below.

For the current RTX 4090 optimization loop, use the
[performance playbook](PERFORMANCE_PLAYBOOK.md); this document also covers
historical reference/package consumers outside that loop.

This checkout builds the PhysX GPU engine, imported destruction reference SDK,
new GPU topology/motion primitives, and a native scene GPU stress stage. The
engine-integrated destruction backend is still under implementation; the initial
`PxDestructionScene` stress API is described in [NATIVE_GPU_STRESS.md](NATIVE_GPU_STRESS.md)
and has since gained configurable internal rigid corrections and versioned
warm-start import/export; current support and
remaining restrictions are documented in [NATIVE_MVP.md](NATIVE_MVP.md).

Linux prerequisites: CMake >= 3.24, a C++ compiler, CUDA >= 12.8, NVIDIA driver,
and Ninja (default) or an explicitly selected installed Make generator.
CuMetal requires macOS Apple Silicon, CMake >= 3.28, installed CUDA-capable
LLVM, and Apple Metal tools. No NVIDIA toolkit is discovered in that branch.
The current qualification target is the RTX 4090 (CUDA architecture 89).
The Linux x86-64 build entrypoint explicitly sets `PX_OUTPUT_ARCH=x86` so
required `_64` library names are reproducible without a pre-existing CMake cache.

```sh
python3 -B tools/scripts/build-destruction-sdk.py --preset linux-cuda --dry-run
python3 -B tools/scripts/build-destruction-sdk.py --preset linux-cuda --check
python3 -B tools/scripts/build-destruction-sdk.py --preset linux-cuda --jobs 6
# Explicit execution/staging; neither happens on an ordinary build:
python3 -B tools/scripts/build-destruction-sdk.py --preset linux-cuda --test --install
```

The command builds this checkout's sources; it never downloads dependencies or
uses Packman. Ordinary builds do not install. Missing prerequisites produce a
report without creating output directories. Dry runs only inspect paths and
print commands. Override `--cuda`, `--cc` and `--cxx` for installed toolchains.

Outputs are isolated under `out/build/<preset>/<configuration>/<stage>`;
PhysX staging is `out/install/<preset>/<configuration>`. The build tree contains
`sdk-artifacts.json`, per-command logs, source hashes/revisions, tool versions,
selected numerical policy, completed commands and artifact hashes. Generated
`PxConfig.h` is local to that build. The sibling CuMetal repository is discovered
by default; `--cumetal-root` may select a checkout inside the approved roots.

```sh
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --check
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage host --generator 'Unix Makefiles'
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage gpu --target PhysXCommonGpu --generator 'Unix Makefiles'
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage gpu --target PhysXCuMetalNativePairsTest --test --generator 'Unix Makefiles'
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage compiler --generator 'Unix Makefiles' --test --install
```

The compiler gate builds/tests CuMetal and stages it beneath **CuMetal's own**
`out/install`. With both `--test --install`, it also relocates that staged package
inside a repository-owned test directory and builds/runs an external CMake
consumer. This does not install a PhysX destruction SDK. The default macOS SDK
gate reports the remaining GPU integration work explicitly.
On macOS 14.4 / Xcode 15.4, the standalone-fence regression currently fails, so
`--test --install` stops before installation. An explicitly requested separate
`--install` stages a development package without claiming test qualification.

`--stage gpu --target` compiles selected components of the production GPU tree.
Only named component test targets accept `--test`; the manifest records that
scope as a partial build. These targets cannot install or certify the complete
SDK. `PhysXCuMetalNativePairsTest` links the actual `broadphase.cu` object and
tests its native pair sort/merge/unique/scan/scatter pipeline on Apple GPU.

The CuMetal GPU workflow enables `CUMETAL_USE_METAL_DEVICE_ADDRESSES=1` in its
child processes because PhysX stores nested pointers in device descriptors.
The current runtime marks every live allocation read-write resident in this
mode, limiting cross-stream concurrency. This is a recorded correctness choice,
not a performance result or forced per-kernel synchronization. The host-only
and compiler gates do not enable it. The GPU module loader sets it too, before
the module is opened, unless the environment already sets it, so an external
consumer needs no setting of its own.

### macOS package for external consumers

`--stage sdk --install` on CuMetal packages an existing `--stage gpu` engine for
the rigid-demo profile (articulation and diffuse-particle kernels excluded); the
full profile stays blocked. Pass the same CuMetal options the GPU engine was
configured with: the stage compares them with that engine's CMake cache and
refuses a mismatch. It builds only the host archives (including
`PhysXCharacterKinematic`) and the package's own libraries, never relinking the
GPU module, then installs to `out/install/macos-cumetal/release`:

```sh
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage sdk --install \
  --generator 'Unix Makefiles' --cumetal-rigid-demo <the --stage gpu CuMetal options>
```

`tools/scripts/relocate-macos-sdk.py` runs last. It copies `libcumetal.dylib` into
`lib/` and CuMetal's clean-room CUDA headers into `include/cumetal/`, replaces
absolute rpaths with `@loader_path` (re-signing ad hoc), and writes
`out/sdk-artifacts.json` (`source_revision`, `source_dirty`, and a sha256 per
library). That is the same manifest shape the Linux SDK build records.
It then runs `cumetal-warm --strict` over every metallib embedded in the
packaged GPU module and fails the install if any kernel cannot build a Metal
pipeline (for example over the 32 KB threadgroup limit). The manifest's
`metal_pipeline_gate` records the metallib and kernel counts, and the warmed
cache removes the long first-run pipeline compile.

`native_feature_reference_test` (`ctest -R physx_native_feature_reference` in
the reference build) runs the features vibe-land relies on under the CPU and
GPU pipelines and requires the GPU to match: a sphere, box, capsule and convex
hull at rest on a heightfield, and the Vehicle2 suspension-limit and sticky-tyre
constraint rows (a hard landing and a parked car). It passes on Metal. It is
a CPU-vs-GPU comparison, not qualification of the rest of the GPU feature set.
Consumers compile with `PX_CUMETAL=1`, which exposes the GPU API in
`PxPreprocessor.h`. `PhysXDestruction::NativeScene` and `::Sdk` export it.
vibe-land's `physx-bridge` finds this prefix in a sibling checkout by itself.

Resolved output paths, symlinks and existing CMake output/install cache entries
must stay inside the repositories. Temporary directories, CuMetal/NVIDIA/module
caches and logs are local. macOS child processes also run in a write-confining
sandbox; failure to enter it is an error, never an unconfined retry. Tool-managed
external writes are blocked. No shell profiles, package registries, system
toolchains, global loader settings or active Xcode selection are changed.

An external CMake consumer can use:

```cmake
find_package(PhysXDestruction CONFIG REQUIRED)
target_link_libraries(my_app PRIVATE PhysXDestruction::Sdk)
```

Native scene applications can link `PhysXDestruction::NativeScene` to use
`PxScene::getDestructionScene()` without the external Blast adapter or application
CUDA runtime. The complete SDK/reference target above remains compatible.

Configure with `-DCMAKE_PREFIX_PATH=/path/to/sdk/install`. CPU and GPU consumer
execution is covered by `tests/destruction/package-consumer`; historical CUDA
relocation results must be requalified on this checkout. They have not been
executed on Linux during the current CuMetal work. The macOS package is
relocatable as described above. The GPU topology target is separately
available as `PhysX::PhysXDestructionTopologyGpu` from the same package.

Run the native reference and new GPU tests:

```sh
python3 -B tools/scripts/build-destruction-sdk.py --preset linux-cuda --test
```

Current failures are recorded in `IMPLEMENTATION.md`; adding `--test` to the
build command propagates their nonzero exit status. Nothing masks known failures.

A standalone CUDA conditional-graph/context diagnostic isolates the current
memory-checking failure without linking PhysX or Blast. Its separate build and
control commands are in [CUDA_GRAPH_DIAGNOSTIC.md](CUDA_GRAPH_DIAGNOSTIC.md). It
does not replace native memory qualification.

The Rust CPU/Rapier interface continues to build without a PhysX/CUDA SDK:

```sh
cargo test --manifest-path blast/blast-stress-solver-rs/Cargo.toml \
  --features rapier,scenarios --tests --no-fail-fast
```

The `physx` feature defaults to this checkout's built `physx/` directory.
`PHYSX_ROOT` can point to another built SDK or to the relocatable `out/install`;
`PHYSX_LIB_DIR` explicitly overrides its library directory.

The TypeScript/WASM package retains its existing build/test entry points:

```sh
npm --prefix blast/blast-stress-solver ci --ignore-scripts
# Activate Emscripten 3.1.51 in this shell first.
npm --prefix blast/blast-stress-solver test
```

The local Emscripten installation is ignored under `.toolchains/emsdk`; no shell
startup files or system toolchains were changed. These tests also have recorded
baseline failures. Native Rust `wasm-smoke`, Bevy/demo suites, and complete game
qualification have not yet all been run.

The integration game's branch uses this SDK's reference path. Its native bridge
resolves `../../physx-2` relative to its manifest; `PHYSX_DESTRUCTION_SDK` overrides
that checkout location. `PHYSX_ROOT` and `BLAST_ROOT` remain supported explicit
overrides. No server or client service needs to run for the smoke suites.

The standalone demo/video pipeline is documented in [DEMO.md](DEMO.md).
`python3 tools/scripts/record-destruction-demo.py --build` builds the SDK and
recorder, runs the GPU captures with strict checks, and writes a local MP4 plus
reproducibility evidence. It never starts or modifies a game service.

The direct CUDA/OpenGL demo consumer is built with `--gpu-renderer`. Its
[GPU rendering instructions](GPU_RENDER_CONSUMER.md) cover event ordering,
optional CPU observations and measured-timing video annotation.

The CuMetal GPU component gates can be run together with
`--stage gpu --target PhysXCuMetalNativePairsTest --target PhysXCuMetalNativeAggregatesTest --test`.
The aggregate gate executes the production aggregate collision object, including
multi-warp pairs, 2/17/35-child aggregates, authoritative owner filtering and
bounded reports. These partial gates do not qualify full TGS or destruction.
Successful GPU provenance is retained in the per-run verbose CTest log. Builds
without `--test` do not execute these tests; neither component gate installs.

The additional contact qualification gate is
`--stage gpu --target PhysXCuMetalReferenceGjkTest --test`. It compares the shared
PhysX GJK/EPA equations with CPU results for separation, penetration, rotations,
points and normals, at `1e-4`, and captured replay in asynchronous/batched modes.
It is currently blocked by nested pointer provenance: an initial Apple GPU run
returned an incorrect distance, and the compiler now rejects the unresolved
reference explicitly. Do not use it as a passing contact or video qualification.
See [the compatibility ledger](../CUMETAL_COMPATIBILITY.md) for exact evidence.
The CuMetal-only `PX_CUMETAL_INLINE_REF_GJK_EPA` hint changes inlining annotations
only; the helper selects and records it without changing CUDA's annotations.
