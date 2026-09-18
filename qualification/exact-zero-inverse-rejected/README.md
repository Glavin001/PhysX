# Exact-zero cached inverse evaluation — rejected

🧪 Not retained in production. The candidate skipped only exactly zero cached FP64 inverse coefficients. No nonzero term, equation or convergence tolerance was removed.

## Outcome

- Existing native analytic and 3D physical suites passed.
- The motion-mode test failed during its independent polynomial oracle (12 nodes / 20 bonds). GPU memcheck reported an out-of-bounds eight-byte read in the second cached-inverse application.
- Changing the descriptor from pass-by-value to const reference did not resolve it. A final isolation using only the matrix pointer and stride also failed. The last form is archived in candidate.patch, based on commit 22aa605f.
- The root cause is not established. These observations do not prove a CUDA compiler bug or an error in the underlying mathematical identity.
- No frozen wall run or full-scene performance campaign was attempted after the correctness failure. There is no candidate simulation timing or speedup claim.
- All candidate production and test-source changes were restored. The active runtime is the previously qualified affected-component warm-start runtime, SHA-256 481eab6a7fca0d8c22aef03152bd685d84cdbe7369e7ffa3e0e9846de45b43f4.

## Reproduce the failure

Apply candidate.patch to the recorded revision in an isolated checkout, build gpu_resident_motion_modes_test in the destruction SDK build, then run:

```sh
compute-sanitizer --tool memcheck --error-exitcode 99 out/destruction-sdk/reference/gpu_resident_motion_modes_test small
```

The raw failing logs are preserved. Restored baseline checks are recorded separately; assertions and tolerances are unchanged. This candidate must not be enabled merely because the other physical tests pass.
