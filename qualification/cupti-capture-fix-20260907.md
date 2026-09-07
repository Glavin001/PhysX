# Full-duration GPU timing capture qualification

The full-length capture failure is fixed on the available RTX 4090 / driver 595.71.05. Physics inputs, stress convergence, correction limit, and solver code were unchanged.

## Cause and fix

The earlier CUPTI 12.8 capture failed at simulation step 364. A standalone conditional CUDA graph, with no PhysX or Blast code, reproduced an illegal-address failure under the old profiler. With CUPTI 13.2 Update 2, the same arithmetic completed correctly, but the default device-graph profiling buffer lost records. Configuring a larger buffer before CUDA context creation captured the complete known kernel census. This isolates an instrumentation failure; it does not establish that unrelated historical simulation or sanitizer failures are repaired.

The collector now uses pinned CUPTI 13.2.86 (API 130202), checks that header and loaded-library versions match, configures a 512 MiB device-graph profiling buffer per context, and records that configuration in its status file. The physics compiler/runtime remain CUDA 12.8. Host-buffer flushes alone did not resolve the failure. No extra per-step GPU synchronization was added.

Capacity is configurable through `--gpu-trace-buffer-mb` (16–4096 MiB). Larger future workloads may need more capacity. Overflow fails the capture explicitly and requires a complete retry; it never produces a passing shortened trace. The buffer is profiler-only overhead, not a production simulation allocation.

## Completed checks

- Exact conditional-graph test: **1,281,000 expected kernels**, exact symbol counts, correct arithmetic after every execution, zero dropped records and zero invalid timestamps.
- Negative control: deliberately undersized 16 MiB buffer rejects the capture while all 1,000 graph executions retain correct arithmetic.
- **Nine complete 10-second GPU captures:** three repetitions each of projectile penetration, one idle building, and 16 idle buildings. All have zero dropped records and invalid timestamps.
- Separate **60-second penetration capture:** 3,600 accepted frames, **8,698,540 activity records**, zero dropped records and invalid timestamps. Every step converged; at most one correction per step. Its first 600-frame fracture/topology signature matches the untraced reference.
- Five untraced repetitions per scene and one host-scope capture per scene provide elapsed-time baselines separate from profiler overhead.
- **23 accounting regressions pass:** interval overlap, nested scopes, file tampering, duration truncation, record loss, version mismatch, missing per-step kernel coverage, and deterministic lossless CSV storage are covered.

The report validates every captured file hash, full duration, activity-row census, kernel coverage for every accepted step, timestamp bounds, and additive interval accounting. Detailed GPU tables identify the repetition they use; the overhead table includes all three GPU repeats. Raw CSV compression runs after simulation. A report can be regenerated without rerunning physics.

## Reproduce

From the repository root:

```sh
python3 tools/scripts/fetch-destruction-cupti.py out/deps/cupti-13.2.86
# Supply this local SDK root when configuring the existing native GPU build:
cmake -S destruction -B out/destruction-sdk -DNATIVE_GPU_CUPTI=ON -DNATIVE_GPU_CUPTI_ROOT="$PWD/out/deps/cupti-13.2.86"
cmake --build out/destruction-sdk --target native_destruction_demo native_cupti_capture_test -j4
ctest --test-dir out/destruction-sdk -R 'physx_native_(cupti_|destruction_timing_accounting|profile_accounting)' --output-on-failure
python3 tools/scripts/run-destruction-timing.py out/NEW_CAPTURE --seconds 10 --trials 5 --gpu-trials 3
```

The fetch helper pins and verifies wheel SHA-256 `8fa29f15dd8336181f961764d9d95236fc6b931dd0c8fcf8cd70aab0c310b586`; no system CUDA installation is changed. Qualification used the matching manually fetched package. The helper itself was not separately network-tested in this pass.

## Evidence

- [Generated complete timing report](penetration-timing-full-20260907/report.html)
- [Qualification metadata, statuses, commands and soak hashes](cupti-capture-fix-20260907.json)
- Raw campaign: `out/penetration-timing-full-20260907/campaign.json`
- Reproduction and soak logs: `out/cupti-capture-fix-20260907/`

NVIDIA documents the device-graph buffer capacity control in the [CUPTI activity API](https://docs.nvidia.com/cupti/api/group__CUPTI__ACTIVITY__API.html) and profiling fixes in the [CUPTI release notes](https://docs.nvidia.com/cupti/release-notes/release-notes.html). The conclusions above come from the local controls and completed captures, rather than assuming a release-note issue is identical to this failure.

This qualifies capture reliability for these workloads and hardware. It is not the five-trial, 60-second scale campaign, a sub-1-ms performance result, or completion of the overall destruction SDK.
