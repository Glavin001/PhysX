# Modal GPU fan-out for destruction measurements

Build locally, push binaries, fan the GPU jobs out one container per job on Modal.
Nothing runs (or bills) while you are coding. When you want results, every independent
measurement gets its own GPU and the set finishes in the time of its longest job.

Everything lives in `tools/modal/gpu_run.py`; no existing script is modified. Inside a
container the repo is recreated at `/root/workspace/physx-2` (the same absolute path as the
reference dev box) so rpaths, ctest registrations and the plan/campaign JSONs work unchanged.

## One-time setup

```sh
.toolchains/build-env/bin/pip install modal
.toolchains/build-env/bin/modal token set --token-id ... --token-secret ...   # writes ~/.modal.toml only
export PATH="$PWD/.toolchains/build-env/bin:$PATH"
modal run tools/modal/gpu_run.py::inputs     # frozen arms + warm-window snapshots, ~760 MB, once
modal run tools/modal/gpu_run.py::smoke      # image build, driver/runtime versions, tool paths
```

Dev-box requirements for the binaries you push: Linux x86-64, glibc <= 2.39 (Ubuntu 24.04 or
older), CUDA 13.4 toolkit, `--cuda-architectures 120` (RTX PRO 6000 on Modal is sm_120, the
same SM as the RTX 5060 Ti). Build as documented in `AGENTS.md`, then also:

```sh
cmake --build out/sdk-release --target PhysXDestructionGpuWorkDiagnostic -j8   # census runtime
python3 tools/diagnostics/destruction-snapshot/build-probe.py out/probes/profile --profile   # optional profile probe
```

## Iteration loop

```sh
modal run tools/modal/gpu_run.py::push                      # hashes out/ binaries, uploads only new blobs, prints build_id
modal run tools/modal/gpu_run.py::tests --subset eleven     # 11 native GPU tests
modal run tools/modal/gpu_run.py::ab --grid 16 --seconds 3 --repeats 3 \
    --variants "BLAST_GPU_NATIVE_WOODBURY=0;BLAST_GPU_NATIVE_SOLVE_BLOCKS=3"   # one GPU per variant, control arm first in the same container
```

`push` writes `bundles/<build_id>.json` on volume `physx-builds` (path, sha256, size, mode per
file, local git SHA, dirty flag, worktree patch sha). Entry points default to the latest
pushed build; pass `--build-id` to pin one. Any earlier build id can be a control arm
(`--control <build_id>`: its libraries go on `LD_LIBRARY_PATH`, the candidate's demo is used,
exactly like `run-ab-demo.sh` does with the frozen baseline).

## Qualification

```sh
modal run tools/modal/gpu_run.py::warm                       # nine windows on nine GPUs, A0/B/A1 kept together per window
modal run tools/modal/gpu_run.py::campaign                   # idle-256 and impacts-256 on two GPUs, A-before/B/A-after kept together
modal run tools/modal/gpu_run.py::profile                    # nsys (graph nodes traced, no CPU sampling)
modal run tools/modal/gpu_run.py::census                     # component work census with the diagnostic runtime
modal run tools/modal/gpu_run.py::tests --sanitizers memcheck,initcheck,synccheck
modal run tools/modal/gpu_run.py::qualify --confirm          # all of the above at once
modal run tools/modal/gpu_run.py::fetch --run-id <run_id>    # re-download a run into out/modal/<run_id>/
```

Results land under `out/modal/<run_id>/<job>/` with the same relative layout as in the
container, so `compare_frames.py`, `summarize-warm-screen.py`, `compare-destruction-candidates.py`
and `component_census.py` can be re-run locally on them. The warm windows are merged into
`out/modal/<run_id>/warm/` in the serial-run layout.

Interactive GPU shell with the same image and volumes:

```sh
modal shell tools/modal/gpu_run.py::TimingRunner.ab
```

## How pairing is preserved

| Job | Unit on one GPU | Why |
|---|---|---|
| `ab` | control run then candidate run, per repeat | ratios are intra-container; absolute means are not comparable across hosts |
| `warm` | one window's A0, B, A1 (A1 reversed order comes free: one window) | the contract's paired checker compares B and A1 against A0 |
| `campaign` | one case's A-before, B, A-after | `compare-destruction-candidates.py` needs both A stages against B on the same GPU |
| `tests`, sanitizers, `profile`, `census` | independent | instrumented runs never share a GPU with timing runs |

Provenance (GPU name, driver, clocks, P-state, CPU model, Modal region and task id, driver and
runtime API versions) is attached to every result JSON.

## What does not work on Modal (measured 2026-09-16)

- `ncu` (no hardware counters in the sandbox). The warm plan's `*-ncu` job and the `--nsys-cpu`
  DWARF-sampling job are dropped; `nsys` runs with `--sample=none --cpuctxsw=none --cuda-graph-trace=node`.
- Nsight Systems 2026.3.2 (the CUDA 13.4 package) runs but records no CUDA kernel data in the sandbox; the CUDA 13.0 package's `nsys` (`/usr/local/cuda-13.0/bin/nsys`) traces kernels and graph nodes correctly, so the harness uses that one. Tracing under the genuine 580 library crashes the traced process with either version.
- `compute-sanitizer`: every tool answers `Device not supported` on the RTX PRO 6000 inside the
  gVisor sandbox, with both the 13.4 and the 13.0 sanitizer and with either driver library.
  `tests --sanitizers ...` therefore fails fast; run sanitizers on bare metal.
- Clock locking. Use paired ratios and repeats; treat the first Modal numbers as a new baseline.
- The desktop/screen-locker logic in the local scripts is inert: `systemctl`/`journalctl`
  exist in the image but report nothing.

## Toolkit versus driver (measured 2026-09-16)

Modal hosts run driver 580.95.05 (kernel side). The `cuda-compat-13-4` package in the image
installs the 615.71.09 forward-compatibility `libcuda.so.1`, which the NVIDIA base image's
loader config picks up automatically, so processes see driver API 13.4 and `cuInit` succeeds
(the RTX PRO 6000 Blackwell Server Edition is a supported server SKU). The genuine 580 library
(`libcuda.so.580.95.05`, driver API 13.0) also runs our CUDA 13.4 binaries under minor-version
compatibility: the conditional-graph repro passes in plain/IF/WHILE modes with both libraries
(`adhoc --driver 580` selects the 580 one). All 8 GPU topology tests and the 9 six-channel
kernel tests pass on Modal.

## Device gate

The stress solver only accepts GPUs by exact name ("NVIDIA GeForce RTX 4090" and "NVIDIA GeForce
RTX 5060 Ti"), so Modal's sm_120 part was rejected with
`Integrated destruction requires RTX 4090 sm_89 or RTX 5060 Ti sm_120 with cooperative CUDA execution`.
`tools/modal/patches/device-gate-sm120.patch` (applied 2026-09-16 to
`blast/source/sdk/extensions/stressgpu/detail/StressSolverLifetime.inl`) admits any CC 12.0 device
when `PHYSX_DESTRUCTION_DEVICE_GATE=sm120`; the image sets that variable for every container and the
default behaviour on the dev box is unchanged. Binaries pushed without the patch fail every GPU job.

## Ad hoc runs and diagnostics

```sh
modal run tools/modal/gpu_run.py::adhoc --binary out/modal/diag/repro --args "plain;if;while"          # upload a local binary, run it per arg set
modal run tools/modal/gpu_run.py::adhoc --build-id <id> --binary out/destruction-sdk/reference/gpu_resident_stress_test \
    --lib-dir physx/bin/linux.x86_64/release --preload out/modal/diag/throwtrace.so                       # a bundle binary with LD_PRELOAD
```

`out/modal/diag/throwtrace.cpp` (build: `g++ -shared -fPIC -o throwtrace.so throwtrace.cpp -ldl`)
prints the message of every C++ exception at throw time; it is how the device-gate message was
recovered from a `catch (...)`. `out/modal/diag/repro.cu` is the repo's conditional-graph repro
with the CUDA 13 `cudaGraphAddNode` signature (`nvcc -std=c++17 -arch=sm_120 -lineinfo`).

## Budget (RTX PRO 6000 at $0.000842/s plus 4 cores and 16 GiB: about $0.056 per GPU-minute)

| Item | Wall | Cost |
|---|---|---|
| `push` after a runtime-only change | seconds (11 MB) | $0 |
| iteration: `ab` 3 repeats + 11 tests, 2 containers | ~5-6 min | ~$0.40 |
| variant sweep, 4 variants x 3 repeats | ~3 min | ~$1.70 |
| warm screen, 9 windows | ~4 min | ~$1.40 |
| campaign, 2 cases | 10-14 min | ~$2.70 |
| `qualify` (~22 containers) | ~12-15 min | ~$5-6 |
| idle while coding | - | $0 |

`qualify` prints an estimate first and refuses above $10 without `--confirm`.

## Known pre-existing failures (allow-listed in `tests`)

`physx_native_gpu_{body_allocation,node_births,rigid_checkpoint}` (failed locally on the 2026-09-15 tree; pass on
Modal with the 2026-09-16 tree), `physx_native_gpu_state_initcheck_accepted-properties{,-pgs}` (sanitizer; cannot
run on Modal), `physx_native_gpu_bombardment_contacts`. `tests` reports unexpected failures and unexpected passes
relative to that list; edit `KNOWN_FAILURES` in `gpu_run.py` when the tree changes.

## Sandbox shims baked into the image

- `/usr/local/bin/nvidia-smi` strips `<process_info>` entries from `nvidia-smi -q -x`: gVisor reports GPU processes
  with host-namespace PIDs, which `run-probe.py`'s ownership check rejects; with no processes listed the scripts
  inspect their own child (containers are single-tenant, so nothing is hidden that matters).
- `PHYSX_DESTRUCTION_DEVICE_GATE=sm120` in the environment (device gate, above).
- The loader config lists `/usr/local/cuda-13.4/targets/x86_64-linux/lib` so `libcudart.so.13` resolves even when
  a script replaces `LD_LIBRARY_PATH`.

## Troubleshooting

| Symptom | Cause / fix |
|---|---|
| `no pushed bundle` | run `push` first |
| `input set missing on volume physx-inputs` | run `inputs` |
| `This campaign requires exactly one visible physical GPU` | `nvidia-smi -q -x` returned 0 or >1 GPUs; check `smoke` output |
| warm window jobs fail in under a second with `/proc/locks` in the log | expected in the sandbox; the runner switches to direct mode automatically (no lease protocol), `--direct true` forces it |
| collision/allocation/checkpoint tests segfault in `Fixture::Fixture` | ABI skew in the bundle, see above; rebuild consistently and push again |
| `cudaErrorCallRequiresNewerDriver` | see Toolkit versus driver |
| `Output exists` | run ids are unique per invocation; never reuse `--tag` within one second |
| `Campaign budget exhausted` | raise the budget in `WarmRunner.window` (900 s default) |

## Control arms on Modal

The frozen arms (`out/destruction-baseline-20260913/artifacts`, `out/direct-ab-arms/{A,B}`) were built
before the device-gate patch and therefore cannot start on the RTX PRO 6000. Every entrypoint defaults to
`--control self` (same libraries in each arm: a calibration that must give identical histories and a ratio
near 1). For a real control arm, push a control build once (checkout the baseline commit, apply the gate
patch, build, `push --note control`) and pass its build id: `--control <build_id>` puts that build's
libraries on `LD_LIBRARY_PATH` under the candidate's demo, exactly like `run-ab-demo.sh` does locally.
Env-flag variants (`ab --variants ...`) are paired against the unmodified candidate in the same container.

## ABI skew guard

Statically linked tests (`native_gpu_collision_test`, `native_gpu_allocation_test`, `native_gpu_checkpoint_test`,
...) read GPU controller internals by header layout. If the shipped modules and the test binaries were built
against different headers (a partial rebuild in a moving tree), those tests segfault in their fixture
constructor while the demo still runs. `push` prints a WARNING listing sources newer than the oldest shipped
binary and records the same in the bundle manifest (`skew`). Push only after a consistent build.

## Modal baseline (2026-09-16, RTX PRO 6000 Blackwell Server Edition, driver 580.95.05, build 20260916T070028)

| Measurement | Modal RTX PRO 6000 | Local RTX 5060 Ti (for orientation only) |
|---|---|---|
| city256 bombardment, 3 s, defaults, complete-step mean | 15.0 / 15.7 / 16.2 ms (3 repeats) | ~30 ms |
| same with `BLAST_GPU_NATIVE_DIRECT=0` | 25.8 / 26.7 / 27.4 ms; paired ratio 1.707; histories identical | direct on/off ratio ~0.55 |
| grid 4 calibration (same libs both arms) | ratio 1.016, histories identical | - |
| 600-tick impacts-256, 2 trials, A-before / B / A-after means | 13.47 / 13.64 / 13.39 ms; median peak ~135 ms; 0 counter diffs; 100 s wall | ~54 ms mean, 519/600 misses (pre-R1) |
| nsys kernel totals, 3 s city256 | factorNativeDirect 690 ms / 678 launches, componentStressSolve 355 ms / 267 | 694 ms / 678, 987 ms / 267 |
| 11 native GPU tests | 11/11 pass (the three locally known failures pass here) | 8/11 |
| warm windows (A0 / B / A1 means, control=self) | bridge64 0.61/0.63/0.62; city25-impact 14.5/13.9/14.5; city256-idle 0.73/0.72/0.71; city256-impact 36.4/33.4/33.4 ms, all checks passed | city25 impact 16.4, city256 impact 69.8, idle 1.8 ms |
| city256-debris window | fails in the restored step ("Native GPU destruction stage failed") | fails identically on the 5060 Ti with the same tree (build 20260916T073633): a tree regression, not a Modal issue |

Whole-GPU throughput is roughly 2x the 5060 Ti (188 vs 36 SMs, same SM design); per-SM residency findings
transfer, absolute tick means do not. Compare only against Modal-measured controls.

Observed capacity: seven concurrent RTX PRO 6000 requests queued for several minutes with "waiting to be
scheduled on a GPU_RTX_PRO_6000 worker"; plan fan-out width accordingly or use `L4`/`L40S` for correctness jobs.

Filled in after the first `ab --grid 16 --seconds 3 --repeats 3` on RTX PRO 6000 (see the
qualification record in `reports/destruction-realtime-ranking-20260915/warm-screen.md`).
