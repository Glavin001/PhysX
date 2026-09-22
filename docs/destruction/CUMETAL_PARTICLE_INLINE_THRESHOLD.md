# Experimental particle frontend inlining hint

`--cumetal-particle-inline-threshold N` sets `PX_CUMETAL_PARTICLE_INLINE_THRESHOLD`. The default is empty/disabled. Values are decimal integers from 0 through 2147483647; explicit zero enables the alternate frontend with a zero cost threshold. The helper clears a previously cached setting when the option is omitted. CUDA backend use is rejected by the helper and both public configuration entry points.

Only the resolved `physx/source/gpunarrowphase/src/CUDA/cudaParticleSystem.cu` receives `--cuda-inline-threshold N`. Other files, including another file with the same basename, use their normal command. Existing shared CUDA source, equations, precision policy, launch geometry, tolerances and public ABI are unchanged.

The CuMetal option selects its source-first O1 device frontend with LLVM passes disabled, followed by explicit normalization and standard cost-based inlining. It exposes sufficient private pointer provenance for the current particle compilation. This is an experimental compiler configuration, not a source algorithm fork or a numerical qualification. The matched native AOT particle compile with threshold 500 succeeded in cuda-metal evidence `out/tests/pointer-tuples/command-756.log`; this establishes only compilation of that artifact. No performance improvement, numerical result or complete PhysX/destruction acceptance follows from it. Host-only unused-argument warnings are not evidence that device inlining was skipped; CuMetal forwards the threshold into its separate native device compile.

Inspect the local plan before building, for example from the PhysX root:

```sh
python3 -B tools/scripts/build-destruction-sdk.py --preset macos-cumetal --stage gpu --target PhysXNarrowphaseGpu --cumetal-particle-inline-threshold 500 --dry-run
```

Normal build/test/install separation and repository-local caches/output rules remain in force. The build manifest records the selected threshold (null when disabled), exact source scope and experimental compile-only qualification status. Rebuild the affected native object and consumers before numerical tests; keep existing exact/tolerance oracles and batch/stream checks unchanged. Linux CUDA remains the independent shared-source baseline and requires actual Linux execution for validation.

Focused helper tests cover option bounds/backend rejection/manifest, direct CMake rejection, and generated commands for the canonical particle source, an unrelated source, and a same-basename source outside the target directory. Those tests configure isolated repository-local fixtures; they do not build or execute the fixture kernels.

## Focused numerical evidence

The normal helper built `PhysXCuMetalParticleTailsTest` with threshold500 and
passed both normal and batched execution in run `20260921T235839.796848Z-95701`.
The shared primitive/diffuse production entry points cover dense/sparse/empty
and genuine carry-overflow batches, PGS/TGS, output guards and three queued
replays. Distinct analytic plane distances check exactly-once ordinary work.
This qualifies those component cases only. The full narrowphase archive still
fails a separate soft-body pointer proof; full GPU scenes remain unqualified.
