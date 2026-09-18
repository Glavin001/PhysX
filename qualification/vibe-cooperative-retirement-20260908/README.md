# Cooperative converged-grid retirement: WIP

The deployed large-component solver enters the multilevel preconditioner after the true-residual convergence check, even when every selected component is now inactive. The candidate takes a grid-uniform exit based on the already-published integer active counts and preserves final status, iteration, gamma, normalizer, energy and reduction-scratch writes. It does not change a physical solution or skip an active component.

The actual helper passes a focused GPU test with two CTAs, sparse component IDs, an active component, all-retired components, empty selection and prior-converged status. Memcheck reports zero errors. The full translation unit compiles. This is **not yet full solver/penetration parity, performance or deployment qualification**. No milliseconds saved are claimed.

The live demo remains on the qualified 45ae3488 runtime. The user is testing it; do not restart it or run a competing full benchmark. The source candidate includes the earlier structured inverse (fccdaf8c); isolate that baseline when testing this new change.

Next: build an isolated candidate runtime, run the full solver and frozen penetration gates, then compare/profile the real downtown idle workload. The game consumer now accepts an explicit scene for zero-wave captures. Separate benchmarks are prepared; none were run during user gameplay.
