# Asynchronous memory-check follow-up

No production change is retained. The current-mode 600-tick wall gate and all
52×20 restored-tick repeatability checks remain passing. This follow-up does not
claim a performance improvement or close the asynchronous memory-check failure.

1. Explicit device bounds checks were added to an isolated topology module. The
   ordinary initial-impact replay passes two restores; memcheck fails before the
   checked union code, at the fixed cluster-count field read, eight bytes into
   a 24-byte live status allocation (11,265 errors total). No bounds trap was
   observed, but the earlier kernel termination means that is not proof that
   every later checked access executed. See native-results.json.
2. A synchronization limit of 1,000,000 changes the checker's API tracking without
   forcing per-kernel serialization in the bounded rendezvous control. Native
   first-impact memcheck still fails (114 errors). This is not a fix.
3. A CUDA-only constant-offset read through the same nested graph shape passes
   all four plain/checked/host-wait/flat controls. It does not reproduce the
   native failure. Source and commands are in fixed-read/.
4. Repeated CUDA-only union controls show the diagnostic is intermittent even
   without PhysX or snapshot state. Both plain controls pass; the high-limit
   checker fails once with 1,971 in-allocation atomic reports. Earlier default
   failures are retained. The initial high-limit pass must not be interpreted
   as solving the reduced test.

The union/load/conditional restructuring hypotheses have been reassessed; more
blind kernel changes are not justified. The next useful external diagnostic is
the self-contained [vendor reproducer draft](vendor-reproducer/README.md). It is
not submitted and does not establish which vendor component is faulty.
The complete optimization acceptance gate remains incomplete.

[NVIDIA's documentation](https://docs.nvidia.com/compute-sanitizer/ComputeSanitizer/index.html)
describes the synchronization-limit and API-serialization interaction. Actual
concurrency is tested in high-sync-limit/concurrency.cu, not inferred from the
option name. Tool timings are excluded from all performance tables.

Application measurements are unchanged: [all 52 scenarios, phases, scale, mean,
maximum and budget misses](../../snapshot-fixes-20260911/timings.md). Restore and
validation remain outside complete_step_ms.
