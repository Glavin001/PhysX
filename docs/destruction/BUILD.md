# Building the destruction SDK

This checkout builds the PhysX GPU engine, imported destruction reference SDK,
new GPU topology/motion primitives, and a native scene GPU stress stage. The
engine-integrated destruction backend is still under implementation; the initial
`PxDestructionScene` stress API is described in [NATIVE_GPU_STRESS.md](NATIVE_GPU_STRESS.md)
and does not yet commit fractures or perform internal correction.

Linux prerequisites: CMake >= 3.24, a C++ compiler, CUDA toolkit, NVIDIA driver.
The current qualification target is the RTX 4090 (CUDA architecture 89).

```sh
python3 tools/scripts/build-destruction-sdk.py --jobs 6 --cuda-architectures 89
```

The command requires CUDA and fails if its compiler is missing. It builds this
checkout's PhysX sources, installs headers/libraries/assets into `out/install`,
and records source content hashes, compiler versions and library hashes in
`out/sdk-artifacts.json`. It does not use either source checkout or an old PhysX
installation. Override `--cuda`, `--cc` and `--cxx` for other installed toolchains.

An external CMake consumer can use:

```cmake
find_package(PhysXDestruction CONFIG REQUIRED)
target_link_libraries(my_app PRIVATE PhysXDestruction::Sdk)
```

Native scene applications can link `PhysXDestruction::NativeScene` to use
`PxScene::getDestructionScene()` without the external Blast adapter or application
CUDA runtime. The complete SDK/reference target above remains compatible.

Configure with `-DCMAKE_PREFIX_PATH=/path/to/sdk/install`. CPU and GPU consumer
execution is covered by `tests/destruction/package-consumer`; both have been
validated from a relocated install prefix. The GPU topology target is separately
available as `PhysX::PhysXDestructionTopologyGpu` from the same package.

Run the native reference and new GPU tests:

```sh
ctest --test-dir out/destruction-sdk --output-on-failure
```

Current failures are recorded in `IMPLEMENTATION.md`; adding `--test` to the
build command propagates their nonzero exit status. Nothing masks known failures.

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
