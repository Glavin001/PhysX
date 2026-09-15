# Reassessment after the first rejected work-removal candidates

E5 trailing-barrier deletion, E6 deferred inverse setup and E4 residual-pass
fusion did not establish an application gain. They address different boundaries,
but collectively refute the assumption that small preconditioner work deletions
will automatically improve complete-step peaks. Do not continue that family by
cycling arbitrary barriers, launch bounds or cache sizes.

The matching native NCU reports still show substantial FP64 pipeline activity,
low eligible-warps counts and little DRAM utilization. CPU lifecycle and
correction remain large separate complete-step costs. E3 tests a distinct producer
lifetime reuse mechanism; E8 tests CPU/GPU coordination. Then test algorithmic
work balance and row decomposition, with original quality requirements.

Relevant primary implementations/research reviewed:

- [Bell and Garland, NVIDIA, Efficient Sparse Matrix-Vector Multiplication on CUDA](https://www.nvidia.com/docs/io/66889/nvr-2008-004.pdf)
  compares scalar and cooperative row methods and emphasizes matrix structure and
  irregularity. It motivates E9's row-decomposition experiment. Its scalar SpMV
  bandwidth diagnosis and 2008 hardware speedups do not describe our implicit
  six-channel operator or this GPU; no predicted multiplier is transferred.
- [PETSc point-block Jacobi](https://petsc.org/release/manualpages/PC/PCPBJACOBI/)
  provides a fixed-size dense-block preconditioner with factorization failure
  detection. E10 keeps our already qualified six-channel block inverse and
  examines removing the polynomial traversal. This reference establishes a
  concrete alternative, not its suitability or speed here. Compare total time
  to the original equation residual, not preconditioner cost or iteration count.

The prior repository degree-four polynomial rejection is also retained:
`qualification/polynomial-four/README.md`. Increasing preconditioner work reduced
iterations but lost application time. E10 explores the opposite tradeoff; it may
lose as well. No tolerance, iteration cap or material/physics setting changes.
