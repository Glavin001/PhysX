# Repeated-structure factors: a structural solver hypothesis

The large cities repeat the same authored building pattern: 444 chunks and896
bonds per building. Current loaded stress kernels remain expensive, while the
local operator-neighbor and mass-scaled-vector caches from N10 already exist.
The next algorithmic question is whether a reusable factor can eliminate much
of the repeated iterative work across instances.

Two experiments must remain separate:

1. **Exact operator sharing.** Identify instances whose actual operator, support
   constraints and material/health values match under a verified permutation or
   basis transform. Share one factor and apply it to each current load. Repeated
   geometry alone is insufficient evidence of operator identity.
2. **Reference-factor preconditioning.** For sufficiently large components, use
   a shared positive-definite reference inverse as a preconditioner for the
   current damaged operator. The current contacts, matrix, nullspace projection
   and final physical residual remain authoritative. This may remain useful
   after exact operator sharing stops matching.

For the second idea, a restriction of an SPD inverse remains SPD on the selected
coordinates. Projection onto the current admissible subspace can then define a
preconditioner on that subspace. That is an algebraic starting point, not proof
that this engine's coordinate scaling, supports, finite precision or material
states satisfy the necessary conditions. Verify symmetry/positivity independently,
keep the preconditioner fixed within each recurrence, and preserve the original
true-residual, force, damage, motion and correction checks. Any regularization
belongs only to the preconditioner; the solved physical equation stays unchanged.

First census current component sizes, weighted iteration work, support/mode
dimensions and exact operator-equivalence classes. Then measure factor memory,
construction, current-load packing, triangular applications and remaining
iterations. Applying a whole444-node reference factor separately to thousands
of tiny fragments could cost more than the existing solve; eligibility and
batching are essential. Original tree-work evidence already warns that high
fragment counts need not mean high solver work.

NVIDIA cuDSS exposes separate analysis, numerical factorization and solve phases,
with multiple right-hand sides and batching. These capabilities provide an
implementation to evaluate, not a selected dependency or a measured advantage.
Its analysis phase is synchronous; graph capture of later phases has allocator
and execution-mode restrictions. Account for that CPU/GPU coordination and all
setup rather than assuming a drop-in persistent-kernel replacement.
[NVIDIA overview](https://docs.nvidia.com/cuda/cudss/),
[execution and graph restrictions](https://docs.nvidia.com/cuda/cudss/general.html),
[phase workflow](https://docs.nvidia.com/cuda/cudss/getting_started.html).

No library was installed and no factor experiment has run. A provisional
5–20ms loaded-step saving is a low-confidence hypothesis, contingent on the
weighted census and application measurements. Reject it if factor construction,
fill, per-component scatter/gather, synchronization or small-component expansion
erases the iteration reduction. Include cold restored ticks, initialization and
continuous ordinary/sleeping destruction; keep all physical inputs and quality
gates fixed.

The post-tick [physical census](physical-traits.md) gives a first filter, not
an operator certificate. At256 buildings, intact states share one health pattern;
initial impact has59 patterns, and fragmented/late states have256 distinct
patterns. Partial health alone does **not** prove different linear operators:
`StressNodeOperator.cuh` tests health for live/dead membership and uses a separate
compliance scale. Compare actual coefficients and live masks before accepting or
rejecting factor sharing. Damage state must still remain distinct for material
evaluation even when numerical operators can share storage.
