# Resimulation terminology and the single-rewind target

A correction pass is an extra physics simulation after restoring the timestep's
checkpoint. It is the same operation the user calls resimulation or resim.
It is not a stress-solver iteration, a CUDA kernel launch, or one operation per
broken bond.

The earlier 16-building capture reported **103 extra simulations across 720
timesteps**, with this distribution from
`out/bombardment-probes/grid4.frames.csv` (`resim_passes`):

| Extra simulations in one timestep | Timesteps |
| --- | ---: |
| 0 | 640 |
| 1 | 63 |
| 2 | 11 |
| 3 | 6 |

Thus 80 timesteps were replayed, and 17 were replayed more than once. The
validation report is `out/bombardment-probes/grid4.validation.json`. The total
was not 103 resimulations of one timestep, but the multi-pass behavior was still
a departure from the user's single-rewind design. Later eight/64-pass demo
settings are historical reference configurations, not a native engine contract.

The user subsequently clarified that multiple resimulations may be supported,
with a configurable count, but the current setting should be **one per timestep**.
Additional passes are for later optimization/validation, not the current default.

The current target sequence is:

1. Checkpoint the state needed for the supported resimulation.
2. Solve the intact interaction and evaluate its actual impulses with the
   existing stress/material model.
3. Apply that fracture verdict, restore the appropriate motion state, and
   simulate the changed interaction once.
4. Publish accepted motion and events, accounting for damage and commands once.

Additional physics/stress/fracture correction rounds may be supported as an
explicitly selected mode. They change the single-resim reference behavior. A maximum-pass setting of one on the current multi-pass
adapter is not sufficient to implement the intended algorithm: it can merely
turn later fracture into an incomplete-step error. Native integration must
implement the single-rewind lifecycle deliberately and compare against the
original reference behavior.

GPU stress iterations and graph connectivity iterations may still run within
this sequence. Multiple broken bonds can be processed together in one fracture
verdict. Neither implies multiple physics resimulations. The number of resident
chunks and bonds also does not imply a rewind per chunk or bond.

Current native status is documented in [NATIVE_GPU_STRESS.md](NATIVE_GPU_STRESS.md).
The native contact/stress/material stage is implemented; native collision
rebinding and motion correction are not. Its explicit incomplete-step response
to fracture-requiring verdicts is a temporary boundary, not a finished
single-rewind destruction simulator or a 100k-chunk performance result.
