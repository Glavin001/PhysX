# Final-only CPU physical observation — lifecycle replacement continuation

**Partial ranked replacement 1. GPU body/shape simulation registration remains
unfinished; replacements 2–7 have not started.**

## Final ownership change

The destruction path no longer publishes its fitted physical-property batch between the
corrected physics advance and its second stress/fracture evaluation. Both GPU
evaluations complete before one final CPU property batch is applied. Ordinary
current-tick actor getters and scene queries remain available after fetchResults.
The existing GPU motion and mass-frame representations supply the observation;
there is no second persistent physical-state mirror. Ordinary PhysX still performs
its existing pose/sleep synchronization; this removes destruction-specific
publication, not every CPU observation in the ordinary physics engine.

Changed surviving roots receive the current tick epoch inside the existing
chunk-ownership commit kernel. There is one writer per root, and epochs union
both fracture passes without per-tick clearing. Final GPU selection visits the
active cluster list only on corrected ticks. It reuses correction selection
scratch, owner-index storage and uncompacted observation output; public borrowed
compact correction inputs remain unchanged. Epoch storage adds eight bytes per
authored chunk. Capacity remains separate from independently simulated bodies.

The CPU already knows an upper bound from its remaining registration bridge.
The final payload is bounded by the summed affected counts and the final cluster
count; CUDA computes the actual unique count. The initialized unused payload tail
may be copied to avoid a count-read/wait/resubmit dependency. Count is packed into
the existing mandatory completion transfer. Overflow fails the step explicitly;
no contacts, fragments, material work or observations are silently truncated.

CPU actor construction, scheduler settings, simulation registration and shape
rebinding still precede correction. Only physical mass/COM/inertia/motion
publication has moved to final acceptance. Native PGS/TGS continue to consume GPU
kinematic inputs from the preceding committed change. No equations, solver
settings, timestep, convergence or correction budget changed. Public ABI15 and
private V4 descriptor interfaces are unchanged; the internal completion record
layout is runtime-owned and all device pointers are bound from that owner.

## Tests and evidence

- Final build:43 affected native/ordinary/sleep/correction/report tests pass.
- Strengthened boundary oracle:6 chunks,3 bonds,one ordinary body,Direct GPU off,
  sleeping on; PGS and TGS require no physical CPU publication before the second
  stress submission, then verify final GPU/CPU agreement and the following tick.
  The immutable b16951ca runtime fails with the intended second-stress boundary
  diagnostic. This is a discriminating negative control, not a speed comparison.
- Two-fracture fixture:4 chunks,2 bonds,two columns,one ordinary sentinel. One
  bond breaks per stress evaluation. Final mass/COM and GPU/CPU state are checked
  for original owners and fragments from both passes, plus current queries and
  single integration of the ordinary body. It runs with reports enabled/disabled.
- Frozen wall:444 chunks,896 bonds,one projectile,600 steps/10 seconds; historical
  Direct GPU on/sleep off. Exact identities,398 retained,46 detached,199 broken
  bonds,both-wall clearance and at most one correction pass.
- Ordinary wall:the same authored asset with Direct GPU off/sleep on;128-step
  prefix matches its full audited ordinary reference with zero position error.
- Final boundary fixture passes CUDA memcheck with zero errors. Broader existing
  initialization/CUB synchronization findings remain unresolved; no engine-wide
  sanitizer-clean claim.
- Existing reports now attribute `finalPublication` explicitly:GPU owner selection,
  final state gathering,required transfer/completion and CPU property publication.
  It is disjoint from acceptance of the corrected physics and subsequent stress.
  The accounting test rejects overlaps; historical reports remain supported.

## Performance qualification

[Destruction report](shots/report.md) and [pristine idle report](idle/report.md):
256 buildings,113664 chunks,229376 bonds;256-shot prefix of the768-shot tape or
zero-shot idle.96 steps/1.6 seconds per run,two runs per arm/regime,ABBA order,
isolated GPU. Direct GPU off,sleeping on,dt1/60,max one correction/two stress
solves. Complete command-to-accepted-observation/event time includes startup and
runtime growth; rendering/networking are excluded.

Baseline fracture peaks133.345/133.305ms; candidate134.398/134.690ms. Both candidate
peaks are higher in this screen (worst-versus-worst about1%). This is an observed
cost, not a gain, and is not dismissed as proven noise. Loaded means37.546/37.152
versus37.342/37.172ms are close. Loaded startup peaks157.075/161.053 versus
156.389/158.454ms remain the all-step maxima. Idle medians .467/.445 versus
.447/.454ms overlap. First later counted-state differences occur at baseline
repeat tick77 and candidate comparison ticks73/74; all are after the main peak.

Retain as physically tested architectural progress: the next GPU lifecycle
consumer can run both stress evaluations without this intermediate destruction
property readback/publication, and duplicate per-transaction physical publication
is removed. Costs include one final active-cluster selection,8 bytes of epoch
metadata per authored chunk,and bounded payload-tail transfer. At this scene size
the epoch metadata is909312 bytes. The screen does not isolate the cause of the
observed peak difference. No reliable speedup,real-time pass,five60-second
qualification or endurance claim. CPU registration/ownership remains unfinished.

Immutable baseline modules/consumer are under
`out/accepted-properties-final-20260909/candidate` (b16951ca implementation).
Candidate modules and the identical CPU consumer are under
`out/final-properties-20260909/candidate`. Actual hashes,mapped binaries,commands,
raw samples,negative control and final tests are archived in `evidence/` and the
generated reports. A tool approval-review timeout delayed the original combined
run command before any process started; separate retry succeeded. No deployment
or service changes.

## Remaining ranked work

Replacement1 still requires GPU simulation registration and collision ownership
consumers to stop depending on CPU BodySim/island/shape changes before correction.
CPU compatibility must follow accepted GPU lifecycle rather than construct its
prerequisites. Retain numerical activation order and current-tick ordinary queries.
Then implement structural solving2,persistent contacts3,cluster publication4,
selective correction5,local activity/topology6 and remaining passes7.
