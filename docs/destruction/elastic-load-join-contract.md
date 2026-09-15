# Physical loads into the native six-channel graph

`PxgDestructionElasticLoadJoin.cuh` joins the compact physical motion partition
and its load-adapter output to the authored numerical graph. The new solver can
then consume the GPU-built RHS without a load-vector or active-count readback.
This is a private integration component; production still uses legacy stress.

## Required inputs and publication

The motion partition, native graph and load inputs belong to the same frozen
evaluation. The join checks scene/geometry identity, native topology generation,
the exact tick/input-generation/evaluation/seconds receipt, support flags and
canonical moment origins. It verifies both directions of the compact-to-authored
map. Every live bond must remain within one physical motion aggregate, although
eliminated supports may separate that aggregate into multiple unknown systems.

The source load arrays must be the compact arrays named by the prepared motion
partition. Loads are copied back to authored order without changing force/torque
values or transporting them to a different origin. A changed moment origin is an
error requiring a correctly prepared load, not permission to reinterpret its torque.
Inactive chunks have no compact load entry and contribute zero output.

The caller first orders native graph/motion/load preparation and their error gates
on the stream. `build` snapshots the prior error into immutable `inputError`,
then validates and maps rows while accumulating a separate error word. `finish`
publishes readiness. The caller must check host submission errors and feed the
join's `error` to RHS, setup and solve. Zero rows on rejection are not a successful
zero-load query. Material/recovery publication must also require converged solve
receipts; an iteration-limit result is never accepted.

All source arrays and their producer versions remain frozen until consumers
finish. Output storage must be disjoint from inputs, maps and state. The owner
must provide stream/event lifetime management and schedule this work on affected
evaluations. This baseline maps the whole supplied graph; it is not yet the final
selective-event/zero-idle runtime owner.

## Fine residual accuracy

Recorded native loads exposed a mismatch between the recursive stopping target
and the actual acceptance criteria. PCG now uses the sufficient recurrence target

`min(absolute + relative * ||scaled_rhs||, forceScale * forceTolerance,
     torqueScale * torqueTolerance / length)`.

It uses that same target when deciding whether true-residual drift requires
replacement. Periodic checks still apply the original global and per-node tests;
no acceptance tolerance is loosened. This prevents a loose global norm threshold
from hiding drift while the local force or moment criterion still fails.

`StressElasticAccurate.cuh` evaluates original-equation residuals with compensated
two-word arithmetic, including endpoint transforms and row accumulation. Iteration
and preconditioning remain FP64. The accurate path evaluates the physical FP64
solution actually exported, including rotational length scaling. It does not add
stiffness, change loads, project away a failed force balance or silently raise the
tolerance. Compensated bond recovery preserves the same arithmetic at the numerical
response boundary. NVIDIA documents the underlying FMA rounding behavior in its
[floating-point guide](https://docs.nvidia.com/cuda/archive/13.2.1/cuda-programming-guide/05-appendices/mathematical-functions.html);
the implementation is qualified by independent equations, not by that reference alone.

Setup uses that same compensated fine-row evaluation to check each represented
rigid mode before accepting a free-component nullspace. Iteration still uses its
ordinary FP64 action. Native free-fragment captures demonstrated false setup
rejections from cancellation in the ordinary action; the configured nullspace
limit is unchanged, and modes that truly exceed it still reject setup.

An isolated free chunk has an exactly zero operator. After checking that its
adjacency contains no live interface, setup supplies the identity null basis
directly and avoids general connectivity, orthogonalization and operator checks.
It keeps all six free modes and requires load compatibility; this is not an
artificial support or stiffness. A live interface contradicting the singleton
partition rejects. Nontrivial and supported components retain general setup.

This is not a general precision-escalation policy or a proof that every FP64
solution can meet every requested absolute tolerance. Coefficient scaling,
nullspace accuracy, representable iterates and physically calibrated acceptance
profiles remain part of G05. The new native-shell regression retains the strict
force/moment limits and independently checks them using CPU extended precision.

## Recorded-load diagnostic

`tools/diagnostics/destruction-load-capture/Replay.cu` accepts `--fine` after its
existing arguments. It constructs the numerical graph, joins actual GPU adapter
outputs, builds components and RHS, prepares and solves on the GPU, then gates
recovery on every solve receipt. Its explicit `uncalibrated-elastic-interface-v1`
profile has diagonal translational stiffness 1e6 N/m, rotational stiffness 1e4
Nm/rad, zero inelastic/prescribed motion and the strict standalone residual limits.
The iteration cap is 8192; it does not change convergence criteria. This profile
is a numerical probe, not a release material calibration or native-physics parity.

The diagnostic exports exact input bonds/profile, mapped loads, RHS, iterates,
solutions, component ownership, receipts, responses and energy. `check_fine.py`
reconstructs the fine equations using independent NumPy extended-precision
arithmetic and runs the existing Newton–Euler load check. Failed queries retain
their rejected status and raw outputs. The recorded native command ledger remains
incomplete; the replay's completeness applies only to its explicit surface-plus-
gravity case. There is no material history advance or new fracture publication.

See [validation and hardware evidence](../../qualification/elastic-load-join-20260910/README.md).
The separate `--fine-setup` diagnostic stops after setup and exports states,
bases and the last tested mode/action. `check_setup.py` reconstructs that action
in extended precision, distinguishing arithmetic error from a represented mode
that actually fails the configured limit. It performs no solve or recovery and
never changes a failed setup status.

`--fine-check` instead runs setup, compatibility and the initial residual check
with zero iterations, retaining pending status for nonzero residuals. The
[uniform-gravity follow-up](../../qualification/elastic-gravity-cancellation-20260910/README.md)
used it to remove false incompatibility caused by rounded weight/inertia
subtraction in free aggregates. This input check does not qualify full impact
solves or change the numerical/material acceptance policy.

Next qualify the material/precision envelope, supported and free-component
acceptance, full native commands and accepted/correction transactions before
replacing production stress. Structural acceleration remains necessary for the
real-time target; a converged numerical probe is not a city performance win.
