# Ownership and scheduling implementation

2026-09-15. User authorized implementation of the focused ownership/scheduling
plan. Selected source13b11af2/runtime d5770a80 remains the control. No candidate
is promoted. Sources are isolated under `out/ownership-scheduling-20260915/`;
unrelated working-tree changes are preserved. Raw evidence remains ignored.

## Current implementation result

| Change | Verified mechanism | Application result | Retention |
|---|---|---|---|
| E1 batch interaction search | First large migration17,408 actual visits vs358,400 inferred legacy visits; retirement order preserved | Nine warm cases pass; no meaningful full-tick gain | Keep isolated prototype; no promotion |
| E2 ordered sleep commit | One device operation replaces four generic setters, with ordered pose rollback | Nine warm cases pass; no verified gain; existing initialization failures reproduced | Keep isolated prototype; no promotion |
| E3 unified ownership observation | One pinned packet/join per pass; no GPU work in CPU binding | Nine-case screen, independent four-case repeat and full52 physical checks pass; modest timing signals, no large-city real-time breakthrough | Retain as a tested architectural prototype; full52 and continuous checks below; no promotion |

The selected implementation is still the baseline. The complete plan is **not
implemented**: CPU contact/body registration still precedes corrected physics;
GPU-owned sleeping/activity and the removal of its eligibility restriction are
unfinished. E3 establishes one explicit observation boundary for that migration,
but does not remove those internal CPU consumers. No stale-contact overlap,
sleeping disablement, solver tolerance change or extra correction is introduced.

## Stages

1. Batch lifecycle search/retirement with unchanged physical semantics.
2. Device contact/body registration consumers.
3. Device island activity and sleeping, then removal of the sleeping restriction.
4. Remove CPU compatibility construction from corrected-physics prerequisites.
5. Coalesced observations/events, capacity/failure checks and full qualification.

Keep current physics → stress/material → optional correction → second stress →
publication, ordinary APIs, sleeping and existing physical quality. Publication
and growth remain in full-step cost. Runtime promotion requires warm52, cold
companions, numerical/memory checks and continuous physical qualification.

## E1: remove repeated compound interaction searches — no meaningful timing win

Source inspection refines the diagnosis: each interaction is already retired
only once, but `ElementSim::getElemInteractionsReverse()` scans the **entire actor
interaction list for each migrating shape**. Batch the search once per source
actor, assign each pair to its first migrating endpoint, and recover the current
reverse actor-index retirement order before each shape. This preserves the
baseline's lost-touch endpoint, wake behavior and pair lifetime while removing
repeated searches. No contact response/manifold reuse is introduced.

Primary cases: city25/64/256 first impact. Hypothesized full-tick saving0–10ms,
low timing confidence. Support requires fewer actual search visits and shorter
normal complete ticks. Added preparation/sorting can refute the performance
hypothesis. GPU contact/island ownership is not implemented by this stage.

All prior scenario measurements remain in the
[warm ownership audit](../destruction-cpu-gpu-boundaries-20260914/README.md).
The compiled candidate passes the unchanged warm physical contract in all nine
windows. It has no meaningful application-level timing win and is **not
promoted**. Saved as a batch-lifecycle prototype, not a selected runtime change.
At the first city256 migration, actual actor-list visits fall to17,408 from an
inferred358,400 baseline iterator visits;1,024 pairs retire. The diagnostic checks
the exact baseline reverse-iterator order immediately before every retirement.
Baseline visits are inferred from the original iterator's current list length;
they are not an independent baseline PMU measurement. The candidate still retires
all physically invalid contacts. Added grouping and sorting offset potential
benefit, or the removed searches were too cheap; the result does not distinguish
those explanations.

| Warm scenario | Control A0/A1 mean, ms | Candidate mean, ms | Control max / candidate max, ms | Control misses / candidate misses |
|---|---:|---:|---:|---:|
| Bridge64 | 1.128 / 1.431 | 1.057 | 1.592 / 1.253 | 0/32 / 0/16 |
| Chain256 | 1.449 / 1.449 | 1.433 | 1.796 / 1.569 | 0/32 / 0/16 |
| Dense12 | 1.172 / 1.537 | 1.456 | 1.671 / 1.535 | 0/32 / 0/16 |
| Tower64 | 1.819 / 1.353 | 1.477 | 4.170 / 1.565 | 0/32 / 0/16 |
| City25 impact | 22.750 / 22.517 | 22.871 | 37.713 / 38.386 | 20/32 / 10/16 |
| City256 idle | 1.407 / 1.580 | 1.644 | 2.309 / 2.004 | 0/64 / 0/32 |
| City256 impact | 88.393 / 88.541 | 88.854 | 185.844 / 180.724 | 32/32 / 16/16 |
| City256 cascade | 104.506 / 103.856 | 103.625 | 144.193 / 140.045 | 32/32 / 16/16 |
| City256 debris | 123.566 / 124.185 | 123.680 | 129.248 / 126.784 | 32/32 / 16/16 |

[Every arm's stage, preparation and work measurements](e1-all-scenarios.md).
This screen uses the fixed nine-window W/M histories; its cascade W55 differs
from the full52 W47 window. First-use measured ticks remain. Restore and actual
warmup are excluded; command, simulate/fetch and completion are included.
Means/peaks are descriptive; no tiny difference or equivalence is asserted.
The 48-tick initial smoke also checks rebuilt A and diagnostic B against the
unchanged selected executable. Physical checks cover complete work histories
and endpoint observations, not all physical arrays on every intermediate tick.

The nine-window A0/B/A1 screen plus selected first-impact Systems/NCU captures
completed in278.991s, exports in1.650s.480 normal measured ticks plus two16-tick
profiled runs; all gates pass. Targeted counter captures remain diagnostic,
not production timing or exhaustive coverage. Original warning receipts remain.
No full52 or uninterrupted final qualification was launched for this result.

Local reproduction/evidence:

```bash
python3 tools/diagnostics/destruction-ownership/build-batch.py build-v1
python3 tools/diagnostics/destruction-snapshot/run-warm-suite.py \
  out/ownership-scheduling-20260915/screen-plan.json \
  out/ownership-scheduling-20260915/screen-v1 \
  --manage-desktop --budget-seconds 360 --contract-version 2
python3 tools/diagnostics/destruction-snapshot/export-warm-profiles.py \
  out/ownership-scheduling-20260915/screen-v1
```

These are completed-run commands; use fresh output names, never overwrite them.
`build-v1/build.json` records source13b11af2, the exact candidate patch/hash,
compiler/link commands, every reused input and compiled dependency. Source/tools
remain uncommitted. The selected SDK is unchanged. `smoke-v1/campaign.json` and
`screen-v1/{campaign,exports}.json` retain checks, loaded-module identities and
desktop restoration. Raw data requires the local ignored `out/` tree.

Reusable lesson: a20× reduction in actor-list search visits does not establish a
full-tick win. Do not tune this search further without new evidence; address
the ownership consumers and actual registration work.

## E2: ordered device sleep commit — no verified application win

One CUDA operation replaces four generic velocity/force/torque setters. It
preserves inverse mass, penetration limit, previous velocities and all unrelated
state, while clearing current velocities and retained accelerations. Optional
solver-pose rollback still uses the original transform/bounds update, with an
event dependency in place of its host join. One final stream completion precedes
public completion and later wake commands. This does **not** move sleep decisions
to the GPU or enable the device island ownership guard yet.

The non-OmniPVD native build drops zero-buffer allocation/upload and four setter
kernels. OmniPVD builds preserve their original property notifications. CPU
island membership/activity remains authoritative. Expected full-step benefit
is0–0.1ms in late debris, low confidence; the primary value is a single device
transition primitive for the later activity-owner migration. Support requires
unchanged sleep/wake/correction outputs, fewer launches/joins and no warm-suite
regression. Standalone timing of the new kernel cannot establish application gain.

`sleep-build-v2/build.json` contains the successful C++/CUDA build. The original
v1 attestation attempt is preserved: relinking changed metadata and initially
retained a shell escape in `$ORIGIN`. V2 corrects direct-argv RPATH handling and
verifies every loaded code/data/dynamic section against the selected library;
only compiler `.comment` and build-ID metadata differ. No numerical or timing
gate was relaxed. Both unchanged and candidate translation units are rebuilt.
Twenty ordinary native invocations pass across both arms, including600-tick
sleep/wake/contact trajectories, compound sleeping, post-correction, reuse and
reported reuse, checkpoints and correction-body checks. Source fixtures contain
multiple subcases, so20 invocations is not20 ticks. The compound fixture checks
both rollback modes, retained accelerations, previous velocity, mass/limits and
all513 offset/rotated shape bounds.

Memory access and synchronization checks pass on this compound fixture.
**Full initialization checking fails for both the candidate and the exact
selected runtime:2,174 errors each.** The first100 printed reports concern
backing-buffer API copies; this is not proof that every error is a harmless
capacity tail. A separate, explicitly scoped device-read check disables API-copy
checking and still reports91 errors for both rebuilt control and candidate:
8 topology motion-slot reads and83 ordinary GPU radix-sort reads. All91 are
printed; none names the new sleep kernel. No initialization pass or full
qualification is claimed, and the existing defects are not waived.

The original1,200-tick sleep-boundary memcheck hit its90-second watchdog without
a reported access error. It is incomplete. Its sanitizer child outlived the
launcher and caused the next admission failure. The verified owned process
group was terminated, with no driver Xid. The new native wrapper now cleans up
the entire job process group before releasing the GPU lease. All failed attempts
remain saved; the focused fixture replaces only the unfinished sanitizer scope,
not the ordinary600-tick physical checks that already passed.

Receipts under `out/ownership-scheduling-20260915/`:

- `sleep-checks-v1/campaign.json`:20 ordinary invocations pass; broad memcheck timeout.
- `sleep-sanitizers-v2/campaign.json`:admission rejected; no test executed.
- `sleep-sanitizer-cleanup.json`:verified owned descendants stopped.
- `sleep-sanitizers-v3/campaign.json`:memcheck passes; full initcheck fails.
- `sleep-initcheck-control/campaign.json`:selected runtime has matching total errors.
- `sleep-device-sanitizers/campaign.json`:control has91 device-read errors.
- `sleep-device-sanitizer-continuation/campaign.json`:candidate has the same91;
  independent synccheck passes. Campaign correctly remains failed.

This stage is not yet qualified or promoted. The remaining ownership migration
is not implemented: no sleeping guard removal and no stale-physics overlap.

The nine-window A0/B/A1 warm screen and rebuilt-control comparison pass all
physical gates in306.791s; exports take1.506s. [Every scenario, arm, peak,
deadline miss, stage and preparation cost](e2-all-scenarios.md). City256 impact
is87.957ms versus86.708/86.409 controls; cascade104.663 versus103.315/103.749;
debris123.804 versus125.084/123.939. These are mixed descriptive differences,
not a verified win. No promotion or full52 finalist run. Candidate Systems and
targeted `commitNativeSleep` counters are in `sleep-screen-v1`; unchanged control
traces remain separate. The simple independent CUB scratch/scan diagnostic passes
initialization checking; it does not explain the native initialization failures.

## E3: one ownership observation before CPU construction — full52 and continuous checks pass

New-body metadata and changed-owner binding metadata are already complete before
CPU body construction. Gather both then, copy them into one reusable pinned
packet, and join at its first CPU consumer. Binding reads the same packet with
frame/checkpoint/preparation-generation and count checks. Remove its second
GPU gather and synchronization; retain five field copies, original CPU object
construction/registration, mandatory current ownership and correction ordering.
Pinned capacity grows geometrically and is included in full-step cost when used.
The original ID-vector views retain their lifetimes. Packet validity ends on
new/resubmitted preparation and teardown. Separate candidate from E1 and E2.

Low-confidence saving hypothesis0–0.3ms on fracture ticks; stronger value is a
single explicit CPU observation boundary for migrating internal consumers later.
Support requires identical retry/failure/current-tick outputs, removal of the
second GPU handoff, and no material full-step regression. This does not claim to
remove the much larger CPU registration predecessor. Source/patch/build receipts
are under `out/ownership-scheduling-20260915/observation-*`.

E3 v1 builds against the selected frozen topology/stress objects; all18 native
invocations pass in65.991s. The nine-window warm screen plus rebuilt control and
selected Systems/NCU pass in293.910s (exports1.610s). [Complete measurements for
every arm](e3-all-scenarios.md). City25 impact21.826ms versus22.799/22.808;
City256 impact88.274 versus88.237/86.182; cascade104.180 versus103.089/104.255;
debris123.798 versus123.178/123.655. No verified application improvement yet.

The selected two-pass first-impact trace has exactly five logical field copies,
one metadata gather and one event join per ownership observation. There are
**no recorded CUDA API calls inside either CPU applyBindings scope**. Raw API
aliases repeat rows and must not be counted as additional copies. The trace is
322.284ms, with NVTX/CUDA/OS boundary warnings and95 sampling-throttle events;
it is not a production timing or exhaustive attribution claim. Full tick and
physical-gate evidence remains the ordinary run.

```mermaid
sequenceDiagram
    participant G as GPU current ownership preparation
    participant H as Owned pinned observation
    participant C as CPU registry
    participant P as Corrected physics
    G->>H: Gather metadata; queue five field copies
    H->>C: One completion join
    C->>C: Construct required bodies
    C->>C: Bind/register shapes using the same packet
    C->>P: Registry ready; retain current-tick ordering
```

Review added a v2 exceptional-teardown guard: if any copy/event submission fails
before recording completion, drain the owned readback stream before freeing its
pinned destination. Normal execution has no added wait. V1 source/binary/evidence
is preserved; v2 is independently frozen and its qualification follows below. All three
standalone CUB scratch-lifecycle probes
passed and did not reproduce the native failure. No baseline defect is waived.

V2's9 focused native invocations and readback memcheck pass in37.875s. Independent
four-window A/B/B/A confirmation passes in222.688s: [all arms and stages](e3-confirmation.md).
The first-control City25 51.016ms peak and all other first-use/outlier samples
remain included.

| Warm confirmation | Controls mean range, ms | Candidate mean range, ms | Controls observed peak, ms | Candidate observed peak, ms |
|---|---:|---:|---:|---:|
| City25 impact | 22.724–24.087 | 22.270–22.292 | 51.016 | 37.718 |
| City256 impact | 89.606–89.858 | 88.316–88.627 | 189.953 | 183.495 |
| City256 cascade (W55) | 104.271–105.282 | 102.425–103.907 | 144.856 | 140.738 |
| City256 late debris | 124.454–125.069 | 123.404–124.041 | 130.163 | 127.211 |

Each arm has two restored trajectories ×8 measured ticks. City25 misses10/16;
each listed City256 arm misses16/16. These independent repeats are encouraging,
but no broad statistical speedup or equivalence is established. Do not pool
the two-restored tick samples as independent experiments or erase the prior
mixed v1 screen. The mechanism changes CPU observation, not solver quality.

Full52 v2 **passes52/52** in293.719s:848 measured ticks and1,496 physical warmup
ticks match the accepted controls' work history and endpoint observations.
[All52 candidate means, peaks, misses, stages, setup and work](e3-full52.md).
The preserved controls are hash-checked historical trajectories, so this is a
physical coverage result, not a paired full52 speed comparison. Seventeen
candidate scenario means remain above16.667ms;225/848 measured ticks miss.
Large-debris mean123.010ms/peak125.943ms and first-impact mean87.934ms/peak180.840ms
show that the principal real-time problem remains. W47 full52 cascade differs
from the W55 confirmation window. Cold52 remains a separate companion.

Three standalone CUB scans (basic, sort/select/scan sequence, unsigned-count
specialization) all pass and do not reproduce the native initialization failure.
That narrow diagnosis is exhausted; the next investigation must instrument the
native producer/consumer boundary or verify its compiled/link context. Do not add
blanket zero fills or classify the failures as a proved CUB bug.

Uninterrupted600-tick city256 idle/heavy A/B/B/A checks pass all4,800 ticks in161.638s; receipt:
`observation-continuous-v2/campaign.json`. These check exact work/iteration and
convergence histories; they do not capture every physical array each tick.
No selected runtime/SDK promotion or completed device-island migration is claimed.

[All uninterrupted process timings, peaks, misses, stages, initialization and
work](e3-continuous.md). Heavy means50.518/50.527ms versus51.011/50.808ms controls;
peaks185.709/179.420ms versus184.139/176.412ms; every heavy process misses519/600.
Idle means1.438/1.671ms versus1.430/1.712ms controls, with0/600 misses each.
These are modest signals, not a substantial real-time gain. No full52 paired
speedup, cold52 v2 requalification, complete physical-array600-tick trajectory
or clean full initcheck is claimed. Preserve the selected baseline.

## Reproduce the final observation prototype

Use fresh names; the commands intentionally refuse to overwrite evidence.
The preparation script was checked to reproduce the tested v2 source byte for
byte. Its parent is source13b11af2, with no candidate commit under the current
local/uncommitted policy. The build receipt records dependency, reused-object,
compiler/link and loaded-module identities. This needs the local frozen inputs.

```bash
python3 tools/diagnostics/destruction-ownership/prepare-observation.py --name NEW-observation
python3 tools/diagnostics/destruction-ownership/build-observation.py NEW-build \
  --preparation out/ownership-scheduling-20260915/NEW-observation-preparation.json
```

The tested source is `out/ownership-scheduling-20260915/observation-source-v2/physx/source/gpudestruction/src/PxgDestructionRuntime.cu`;
its patch is `out/ownership-scheduling-20260915/observation-v2.patch`.
The E1/E2 source trees, all failed attempts and every raw profiler/sanitizer
receipt remain alongside it. Source, tools and detailed reports are uncommitted;
raw evidence is ignored. The full implementation plan remains incomplete.

## Next implementation work

1. Migrate contact/body registration consumers to stable GPU ownership records.
   CPU filtering, pair lifetime and solver-edge consumers must be handled before
   moving compatibility construction after corrected physics. This is the main
   first-impact target; the readback packet alone cannot remove it.
2. Give device activity separate graph/readiness/wake generations. CPU lost-touch
   handling can reset readiness concurrently with solver output; include that
   producer and ordinary commands before enabling sleeping with device ownership.
   Do not remove the sleeping eligibility predicate in isolation.
3. Diagnose the existing native initialization failures at their actual producer
   boundary. Three standalone scratch hypotheses did not reproduce them. Avoid
   more standalone variants, blanket zeroing, or a claim of a proved library bug.

The experiment family of small lifecycle/search/handoff changes produced useful
mechanisms but no major application gain. Further parameter tuning of those
mechanisms is not the next priority. There are no automatic jobs queued after
this validation batch; all remaining architectural changes are explicitly above.

Final receipt: `out/ownership-scheduling-20260915/terminal.json`. All owned jobs
are terminal, shared lease free, no GPU compute clients, desktop/persistence
services active. Selected artifact hashes are unchanged. The implementation
campaign did not promote a runtime or complete the larger ownership migration.
