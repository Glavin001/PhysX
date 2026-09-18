# Rejected residual-vector caches

Both coordinate-separated and packed shared-memory residual caches were slower than the existing component-local solver on the identical 256-building, 113,664-chunk / 229,376-bond / one-projectile fixture (two ten-second runs each). Their source snapshots are archived here solely for reproducing the rejected experiments. They are not included by any build target, and no cache switch or alternate production kernel remains.

The accepted change stores only reduction partials locally and replaces atomics with producer-owned warp sums. It leaves hot residual vectors in their previous persistent GPU storage.

See [generated comparison](../producer-norm-layout-comparison/report.html). The rejected timing captures remain in `qualification/shared-residual-world-256`, `qualification/shared-residual-impacts-256`, and `qualification/packed-residual-world-256`; exact recorded commands and binary hashes remain in their referenced capture manifests.
