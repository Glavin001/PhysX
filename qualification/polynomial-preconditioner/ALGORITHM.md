# Resident two-stage polynomial preconditioner

The selected candidate changes only numerical preconditioning for the native
small-component solve. The physical matrix L, loads, convergence tolerance,
original residual verification, material verdicts and one-correction limit remain
unchanged. Iteration zero retains the previous steepest-descent initialization;
iteration one restarts PCG with this fixed preconditioner.

Let D be the exact six-variable block diagonal already factored by native setup,
M its cached inverse, and E=L-D. Two weighted Jacobi updates starting from zero
produce P=(a+b)M-abMLM. Substitution gives P=(a+b-ab)M-abMEM. The implementation
therefore needs one sparse traversal of cross-endpoint coupling E, rather than
re-evaluating the diagonal and storing an intermediate full matrix product.
Each thread computes independent node outputs into the existing other scratch
vector. The caller consumes that vector directly; there is no copy back.

The weights a=0.5779388123770052 and b=2.6335678180143502 are the two Chebyshev
roots for the normalized interval [0.1,2.01]. Every physical bond has at most two
dynamic endpoints. The inequality |u+v|² <= 2|u|²+2|v|² gives L <= 2D, so the
normalized eigenvalues lie in [0,2]. The resulting linear polynomial
q(t)=a+b-ab*t is positive over that interval, including at zero. The lower
interval endpoint does not cut off modes. Existing free-body projection remains
necessary and unchanged. The integrated asset validator rejects self-bonds.

The cache is finite-precision FP64, so the identity M D = I is not bit exact.
The independent long-double test assembles the original physical matrix from
bond columns, inverts node blocks independently, and applies the original two
Jacobi updates for every basis vector. It checks the CUDA result, symmetry and
positive definiteness on supported and free graphs. Existing final-force and
true-residual oracles retain their prior thresholds.

The precursor four-stage polynomial passed numerical checks and reduced outer
iterations, but added too much operator work in the intact-building probe. Its
patch is archived only as experimental evidence. A direct two-stage evaluation
was then reduced to the equivalent off-diagonal expression above. Production has
one fixed selected implementation; no polynomial-degree runtime switch exists.

Work-accounting interpretation: the existing outer-operator counter does not
count preconditioner traversals. The two-stage candidate adds one E traversal
for each preconditioned update after iteration zero, and applies M twice during
that update. Those costs are included in the preconditioner CUDA phase and in
complete-step wall time. Reduced outer iterations alone are not a speed claim.
The source/report audit must not use outer visits alone as total sparse work.

Additional owned storage: none. Existing inverse, topology and cycle scratch are
reused. All application and dependency handling remains inside the resident
component kernel. No CPU assembly, host decision, extra simulation pass or new
host transfer is introduced.
