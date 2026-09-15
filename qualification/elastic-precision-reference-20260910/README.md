# Impact solution precision — 10 September 2026

The captured anchored impact components expose a solution-representation problem
in the private six-channel probe. An independent 80-digit reference converges,
but rounding that reference to ordinary FP64 fails the unchanged local force
limit. Retaining two FP64 words passes. This motivates a GPU precision route;
it does not qualify material coefficients, the full impact trajectory or speed.

## Input and independent reference

The source is the existing ordinary/sleeping 256-building trajectory, 113,664
chunks, 229,376 authored bonds and one 256-shot wave. These are three isolated
numerical components, selected as the largest unknown component in each captured
query, not three new city simulations. Supported neighbors have explicit zero
prescribed motion; inelastic interface motion is zero. The probe's diagonal
stiffness remains 1e6 N/m and 1e4 Nm/rad, with unit force/moment scales and 1e-9
local tolerances. This is the uncalibrated profile, not a release accuracy policy.

`reference_component.py` assembles GᵀDG with 80-digit Decimal arithmetic and uses
SciPy 1.15.3 sparse FP64 LU only for correction solves. The accumulated reference
retains 80 digits. Three corrections reduce the selected corrected-impact
residual norm below 1e-30. A separate bond-form action verifies the assembled
operator, force/moment balance, response and energy. The fixture records exact
FP64 input values, supported nodes, bonds, RHS, matrix, reference and input hashes.
This CPU path is a diagnostic oracle and is never called by the native runtime.

| Query ordinal | Unknown chunks | Live interfaces | Max force error after FP64 rounding | Max force error with two words |
|---|---:|---:|---:|---:|
| 82, first impact trial | 380 | 784 | 3.411e-7 | 2.694e-23 |
| 83, corrected impact | 359 | 672 | 3.719e-7 | 9.947e-24 |
| 130, later trial | 353 | 642 | 3.115e-8 | 6.063e-25 |

All three references pass before rounding. Ordinary nearest FP64 rounding fails
by 31–372 times the local force limit. This is evidence against spending more
iterations on that representation; it is not a proof that every possible FP64
vector must fail. No tolerance, stiffness or small-force cutoff was changed.

## GPU candidate

The explicit `solveComponentsExtended` route retains FP64 Krylov vectors,
operator products and block-Jacobi preconditioning. It accumulates solution
updates in two words, evaluates the original equations at that representation,
and preserves both words through physical scaling and bond recovery. All
iteration, refresh and acceptance decisions remain on the GPU. It currently
supports anchored components only; free-component gauge projection explicitly
returns unsupported. Missing low-word storage returns invalid input.

A matched one-component corrected-impact control still reaches 8192 iterations
with max force error 9.879e-8. Initial candidate samples converge in 658, 1162 and
1736 iterations respectively. The initial corrected-impact result passes the
independent 80-digit check at max force 8.361e-10 and moment 3.027e-10.
Final recovery-enabled samples retain these iteration counts. All three and a
length-0.25 corrected-impact control pass independent 80-digit force/moment,
response and energy checks. Nine rebuilt six-channel CTests pass, including
scaled anchored, deleted-bond, warm-start and explicit unsupported/invalid-route
checks. Four captured-component sanitizers pass (memcheck, initcheck, synccheck,
racecheck). The matched ordinary-FP64 control remains rejected; its gated zero
responses are deliberately not reported as physical response success.

Per the user's subsequent correction, disconnected prototype expansion stops
here. No new counter capture was started and no speedup is claimed. Work returns
to matched A/B changes in the existing integrated engine. The partial two-word
route remains unqualified diagnostic source, outside the installed runtime.

Production still uses the legacy stress backend. There is no complete-step
performance result in this experiment. Free-component precision/setup, material
calibration, structural acceleration, native transactions and the migration
physical-equivalence gates remain open.

Raw data: `out/elastic-precision-reference-20260910/`. The initial binary and
outputs are retained separately from the `final/` recovery-enabled build.
