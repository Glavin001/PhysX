# Stress GPU implementation structure

- Target **200–500 lines** for new implementation files. Treat 500 lines as a
  review threshold, not a build failure. Group by responsibility and preserve
  complete functions; do not create arbitrary fragments to satisfy a count.
- Document a brief reason when a file exceeds the target. Existing large files
  are not a reason for unrelated rewrites; split cohesive sections as they are
  worked on, in separate behavior-preserving changes.
- Keep CUDA implementation fragments private and included by the owning `.cu`
  compilation unit. Moving hot device functions across separately compiled
  units or changing inlining/linkage requires independent qualification.
- Keep structural refactors separate from changes to equations, precision,
  iteration order, memory layout, kernel scheduling or public interfaces.
- For a mechanical extraction, verify expanded source equivalence, rebuild both
  native and reference consumers, and run numerical parity and the frozen
  10-second penetration regression. Do not weaken tolerances or update the
  golden fixture just to make a refactor pass.

Current size exception: `NvBlastExtStressGpu.cu` still contains the established
host solver class and lifecycle methods. Preserve its control flow while
extracting cohesive sections. Do not hide arbitrary slices of a class in
numbered include files simply to bring its line count below 500.
