# Experimental soft-body midphase frontend inlining hint

`--cumetal-softbody-inline-threshold N` sets `PX_CUMETAL_SOFTBODY_INLINE_THRESHOLD`.
The default is empty/disabled. Values are decimal integers from 0 through
2147483647; explicit zero opts into the alternate frontend with a zero cost
threshold. Omitting the helper option clears a previously cached setting. The
helper and both public configuration entry points reject its use with CUDA.

Only the resolved translation unit
`physx/source/gpunarrowphase/src/CUDA/softbodySoftbodyMidPhase.cu` receives
`--cuda-inline-threshold N`. Other sources, including a same-basename file in
another directory, retain their ordinary commands. The particle inlining hint
is independent. This changes frontend inlining only: shared equations, physical
work, precision, tolerances, launch geometry and public ABI are unchanged.

The existing isolated source-first native AOT compile with threshold 500 passed;
evidence is `cuda-metal/out/tests/pointer-tuples/agent-softbody-inline-probe.json`
(native entry, compiler SHA256
`0ecfd59cda02248e984d0f79b5bdf6658c75850c167f1c07fbc6217705bd7dcc`, artifact SHA256
`039e5accd56a7e1e0bbbe29ef1d2c10d3aa0e23b29f55fc0e9e3e1976b79066d`).
The separate LLVM inspection attempt in that report was rejected by the CLI;
it is not additional qualification. The host-only unused-argument warning does
not mean the separate native device compile omitted the threshold. This hint
exposes private pointer provenance through the existing cost-based inlining
path; it is not evidence of numerical correctness or improved performance.
The complete narrowphase and full GPU scenes still require their own build and
numerical validation.

Inspect the local build plan from the PhysX root:

```sh
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage gpu --generator "Unix Makefiles" --target PhysXNarrowphaseGpu --cumetal-particle-inline-threshold 500 --cumetal-softbody-inline-threshold 500 --dry-run
```

Remove only `--dry-run` to build the narrowphase archive. Tests and installation
remain separate explicit actions. Repository-local outputs, temporary files and
caches retain the normal helper confinement. No toolchain upgrade is requested.
The manifest records the selected threshold, exact translation-unit scope and
experimental compilation-only status. Linux CUDA defaults stay unchanged and
can only be qualified by execution on a CUDA-capable Linux machine.

Focused CPU helper tests cover bounds, backend rejection, plan/manifest data,
direct CMake validation, independent particle flags, same-basename exclusion,
and enabled-to-disabled reconfiguration. They inspect generated commands without
building or executing GPU kernels.
