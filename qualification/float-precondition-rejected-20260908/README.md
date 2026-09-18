# FP32 polynomial preconditioning — rejected

Base c8405252 / 0e23ad76. This isolated candidate narrowed the cached inverse application and polynomial off-diagonal arithmetic to FP32; construction, physical operator, residual acceptance and bond recovery retained their established precision. It introduced no alternate production switch and was never deployed.

The resident analytical and 3D suites passed. The existing resident motion-mode suite failed its independent polynomial operator/symmetry check. No assertion or tolerance was changed; qualification stopped before the penetration/performance campaign. There is no measured scene speedup to report. Registers were 92 instead of 96 and stack remained 48 bytes; these are compiler resource counts, not timing or utilization.

Both source changes are reverted. The deployed FP64 runtime remains 1fb2da375e8323de3301fc2dabf06d804ffe7915c774b583de106ab1e97e7dfb. Rebuilt restored-test results are recorded separately. A future precision approach must satisfy the existing independent numerical checks as well as physical outputs; do not repeat this plain cast experiment.
