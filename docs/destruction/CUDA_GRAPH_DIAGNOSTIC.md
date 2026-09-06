# Independent CUDA conditional-graph failure

Native correction memory qualification remains open. A standalone CUDA program
now reproduces failures without any PhysX or Blast code, while its direct-launch
and ordinary-graph controls pass. This prevents treating every observed native
CUDA error as evidence against the newly added collision/body kernels. It does
not prove that the native implementation is free of memory or ordering defects.

The diagnostic and build/run instructions are in
[`tests/destruction/cuda-graph-contexts`](../../tests/destruction/cuda-graph-contexts/README.md).
The program allocates one four-byte output, writes and verifies it three times,
then destroys the graph, allocation, stream and context in order. All operations
are checked. Its modes isolate direct launches, an ordinary graph, IF, nested IF,
and WHILE; a control can reuse a context across graph lifetimes. An explicit
invalid-write mode checks that instrumentation detects an actual out-of-bounds
access. No PhysX libraries, stress code, custom allocators, runtime preloading,
conditional execution bypasses, or error suppressions are used by this program.

## Evidence and scope

The recorded environment is RTX 4090, driver 595.71.05 and CUDA compiler 12.8.93.
The installed Compute Sanitizer is 2025.1.0.0, build 35583870. A separate,
checksum-verified NVIDIA redistribution supplies Compute Sanitizer 2026.1.0.0,
build 37182542, under `out/tooling`; the system CUDA installation is unchanged.
NVIDIA's redistribution manifest is
<https://developer.download.nvidia.com/compute/cuda/redist/redistrib_13.2.0.json>.

The original minimal nested-IF reproduction passed 256 context cycles without
instrumentation. Under both checkers it reported a four-byte write at the base
of a live four-byte allocation as out of bounds, with the same report describing
the address as inside that allocation. An otherwise equivalent ordinary graph
passed 256 cycles under the installed checker. The expanded diagnostic also
reproduced CUDA illegal-address error 700 with a WHILE graph, matching an error
class seen in native stress graph execution. The physical SDK is not needed to
trigger these failures. Failures are intermittent; a short successful run is not
an adequate control.

The [qualification record](qualification/cuda-conditional-contexts-20260906.json)
contains the expanded control matrix, exact commands, completion markers,
source/binary hashes and log hashes. The [preserved reports](baseline/cuda-conditional-contexts-20260906.log)
retain failures and completion summaries. Successful
runs must complete all requested checked writes. The intentional-fault control
is expected to fail; that failure is not a passing physical test.

| Expanded control | Installed 2025.1 checker | Local 2026.1 checker |
| --- | --- | --- |
| Direct launches, 256 contexts | Pass | Pass |
| Ordinary graph, 256 contexts | Pass | Pass |
| Single IF, 256 contexts | Pass | Pass |
| Nested IF, up to 256 contexts | Failed after 33 completed contexts | Failed after 32 completed contexts |
| WHILE, up to 256 contexts | Illegal address in first context | Illegal address in first context |
| Nested IF, 256 graph lifetimes in one context | Pass | Pass |
| Intentional invalid write | Detected | Detected |

Without instrumentation, nested IF and WHILE each completed all 256 contexts
and 768 checked writes. A separate shared-addressing-mode override did not fix
the standalone nested/WHILE failures and was not adopted, even though one
native fixture run passed under it.

## Native fault isolation

The native correction fixture also fails under the newer checker. Earlier
probes using the actual runtime, reference stress object, shared CUDA runtime,
PhysX context flags and alternative module-loading order gave a mixture of
successful and failed runs. Explicit graph upload/synchronization did not remove
the failure. Those temporary upload checks were removed and the normal runtime
was rebuilt; no physics implementation or CUDA link configuration was changed.
The restored native correction fixture passes all ten cases without instrumentation.

A newer-checker run captured `out/stress-correction.nvcudmp`. The matching NVIDIA
debugger identifies a Warp MMU Fault but then aborts internally while decoding
it. The dump has no active user-kernel records. These observations do not locate
a faulty native source line or establish the vendor-side root cause. The dump
run returned zero and printed a zero-error summary **without completing the
fixture**; it is recorded as incomplete, never as a passing memory check.

## Next native integration work

Continue the atomic native collision-owner/body transaction and one internal
resimulation, retaining the complete memory-qualification gate. Any workaround
must be validated against the standalone valid and intentional-fault controls
and the actual native path. Do not silently disable conditional execution,
weaken fracture assertions, suppress CUDA errors, or call an uninstrumented run
memory-qualified. The independent reproduction can support a vendor report;
none has been submitted.
