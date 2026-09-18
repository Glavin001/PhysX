# CUDA graph/context diagnostic

This program contains no PhysX or Blast code. It isolates a memory-checking
failure observed while qualifying native GPU destruction on the RTX 4090.
It is a diagnostic executable, not an exemption from the native qualification
suite and not a replacement stress solver.

Each iteration allocates one `unsigned` in a CUDA driver context, then writes
and verifies `42` three times. Every write is stream-ordered after initialization;
the stream is synchronized before observation, graph destruction, freeing the
allocation, and context destruction. The default recreates the context each
iteration. `--reuse-context` keeps the context and recreates its graph/storage.

```sh
cmake -S tests/destruction/cuda-graph-contexts -B out/cuda-graph-contexts \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_CUDA_ARCHITECTURES=89
cmake --build out/cuda-graph-contexts --parallel 4
out/cuda-graph-contexts/cuda_graph_contexts nested 256
compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/cuda-graph-contexts/cuda_graph_contexts nested 256
```

Modes are `direct` (ordinary kernel launches), `graph` (no conditional nodes),
`if`, `nested` (two nested IF bodies), and `while` (one iteration, terminated by
a device condition update). All modes must produce the same checked writes.
For example:

```sh
compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/cuda-graph-contexts/cuda_graph_contexts graph 256
compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/cuda-graph-contexts/cuda_graph_contexts nested 256 --reuse-context
```

The explicit `--fault` switch writes 4,096 bytes past the allocation's base. It
must fail and lets a diagnostic check that instrumentation remains active:

```sh
compute-sanitizer --tool memcheck --error-exitcode 99 \
  out/cuda-graph-contexts/cuda_graph_contexts nested 1 --fault
```

A valid run requires exit code zero **and** the final `PASS` marker for the
requested number of iterations. In particular, do not interpret a sanitizer
core-dump run's exit code or `ERROR SUMMARY: 0 errors` as a successful test when
the application did not complete. Observed failures are intermittent; preserve
both successful and failed runs and record the checker/compiler/driver versions.
The reproduction's source, binary and logs should be hashed with the results.
