# Hardware sampling without target injection

This Linux diagnostic uses CUDA 13.4 CUPTI PM sampling from a separate process.
It launches the requested program normally and samples device-wide counters at
100 microsecond intervals. It neither replays kernels nor changes PhysX graph
execution. Desktop graphics and other contexts contribute to these counters.

Build and run from the repository root:

```sh
.toolchains/build-env/bin/python tools/diagnostics/destruction-pm-sampling/build.py out/pm-collector
out/pm-collector/collect out/NEW-PM-COUNTERS \
  gpu__time_duration.sum,sm__warps_active_realtime.avg.pct_of_peak_sustained_elapsed,sm__inst_executed_realtime.avg.per_cycle_elapsed,dram__bytes.sum \
  -- PROGRAM PROGRAM_ARGUMENTS
```

The counter output directory must be new. Use the existing destruction capture
workflow to record exact scene arguments, loaded engine modules, GPU processes,
binary hashes and separate untraced timing. The collector's 120-second watchdog
is for short diagnostic runs. It terminates only its spawned process group on
failure or cancellation. Do not run another compute workload during collection.

`samples.csv` retains every decoded sample and flags invalid timestamps. The
first sample is always flagged: CUPTI documents an initial outlier limitation.
Occasional overlapping timestamps also occur on this installation. They are
retained, counted and excluded from kernel attribution. Hardware-buffer overflow
and incomplete final draining fail the capture. There is no kernel replay, cache
flush or clock adjustment. The collector requires a single-pass configuration
and rejects multipass metrics before launching the target.

`sampling.json` records interval, capacities, chip and CUPTI version; `clock.csv`
brackets CUPTI timestamps with the host steady clock; `result.json` records
completion, sample count, timestamp anomalies and target exit status. Metrics
are in the CSV header. A missing result or nonzero target exit is not a qualified
capture. `config.bin` preserves CUPTI's counter scheduling configuration.

For a same-run kernel timeline, launch `nsys profile --trace=cuda,nvtx
--sample=none --cpuctxsw=none --cuda-graph-trace=node --output TRACE PROGRAM ...`
as the collector's child. Export the resulting report to SQLite. Our combined
capture layout is `counters/`, `scene/native.frames.csv`, and `trace.sqlite`:

```sh
.toolchains/build-env/bin/python tools/diagnostics/destruction-pm-sampling/analyze.py \
  out/CAPTURE --output out/CAPTURE/analysis.json
```

The analyzer verifies stress launch counts against per-step evaluations and
checks every launch belongs to its expected simulation interval. It excludes
flagged records and uses only samples fully inside kernel boundaries, with one
sampling period plus measured clock-anchor discrepancy as a margin. It reports
coverage and overlap with other traced kernels. Device-wide metrics cannot
exclude other graphics contexts, and short kernels may have no usable samples.
Resident warp percentage is not eligible-warp count or issue efficiency.

FP64 pipeline counters enumerate successfully but required three passes on this
installation, even when requested alone. They cannot be collected by this
single-pass PM path. Do not substitute FMA activity or an instruction-rate
counter and label it FP64 utilization. Source/PC stall attribution remains a
separate diagnostic task.

References: [CUPTI PM sampling](https://docs.nvidia.com/cupti/main/main.html#cupti-pm-sampling-api),
[API reference](https://docs.nvidia.com/cupti/api/group__CUPTI__PM__SAMPLING__API.html).
Current results: [RTX 5060 Ti evidence](../../../qualification/pm-sampling-rtx5060ti-20260910/README.md).
