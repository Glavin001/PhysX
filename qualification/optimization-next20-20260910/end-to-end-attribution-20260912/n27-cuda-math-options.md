# CUDA math options for the shared-factor follow-up

These are investigated implementation options, not active runtime changes or speedups. Current full-step metrics remain in [N26 confirmation](n26-confirmation.md).

The installed CUDA13.4 header `/usr/local/cuda/include/cublas_api.h` declares `CUBLAS_COMPUTE_64F_EMULATED_FIXEDPOINT`, `cublasSetEmulationStrategy` and mantissa-control APIs. NVIDIA documents FP64 fixed-point emulation using Ozaki-family methods and support including compute capability12.x. Dynamic versus fixed mantissa control affects the accuracy/cost tradeoff. [cuBLAS13.4 documentation](https://docs.nvidia.com/cuda/cublas/). Presence in the header does not prove runtime performance or quality on this card; no probe has run.

cuBLASDx0.7 documents device-callable GEMM with `RequiredMantissaBits<>` emulation descriptors. Its pipelined emulation still creates host-managed temporary storage proportional to input sizes. The preceding0.6 release added block-level triangular solves and requires a prebuilt device library with separable compilation; it also fixed applicable SM120 TMA emission. [cuBLASDx release notes](https://docs.nvidia.com/cuda/cublasdx/0.7.0/release_notes.html). No cuBLASDx headers were found in the inspected installation/toolchain paths, and no package was installed.

Neither option automatically accelerates the current handwritten sparse operator or six-variable triangular code. A plausible use is sufficiently large dense panels inside a shared sparse factorization, after measuring factor fill and panel sizes. Conversion, packing, temporary storage, numerical refinement and graph/CPU coordination must be charged. Do not copy vendor headline speedups or enable fixed low precision without the original independent force/material checks.

cuDSS is another direct-solver reference, but synchronous CPU-containing analysis requires amortization or a different native integration. Its extended `CUDSS_R_64F_64F` is double-double storage, not an FP64-emulation flag. [cuDSS types](https://docs.nvidia.com/cuda/cudss/types.html). No documented cuDSS emulation setting was found in the inspected types page; do not infer automatic use of cuBLAS emulation by cuDSS.

Next: finish the queued contact-index test; assess representative native full-factor storage, accuracy and setup/reuse cost; choose a native GPU implementation from measured panel sizes and graph/lifetime constraints. No speculative math-library switch is applied to the simulation.

The CUDA13 cuDSS0.8.0.10 vendor archive is now SHA256-verified and extracted locally at `.toolchains/cudss-0.8.0.10-cuda13/`; [receipt](n27-cudss-staging.json). No system installation or runtime/GPU test. Download and extraction completed before the N27 confirmation started.
