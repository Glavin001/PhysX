# GPU pre-solve static support

The opt-in native path `--gpu-pre-solve-support 1` derives local static-support
counts from GPU contact records and supplies those counts directly to the
pre-solve component reduction. It requires `--gpu-pre-solve-contacts 1
--gpu-pre-solve-islands 1 --gpu-island-repair 1`. The native producer remains
available as a reference and as fallback for unsupported scenes.

## Inputs and phase semantics

Persistent device storage holds one support count per motion node. At the
post-partitioning boundary, CUDA counts response-enabled contacts with exactly
one true static endpoint and one live dynamic node. A contact contributes once
if it currently touches or has actual previous contact patches. Previous patches
preserve the native deferred lost-touch semantics at this boundary; they are
not a prediction of future contact. Kinematic boundaries do not count as static
support. Retired managers are masked before geometry access.

Managerless inserted static edges have no narrowphase record and still arrive
through the CPU retained-edge bridge. Invalid endpoints trigger an incomplete
step rather than dropping physical work. The ordinary dynamic connectivity
producer and one-resimulation limit are unchanged.

In this mode, resident node update records carry zero in their old native
support field. Support-only changes no longer dirty or upload those records.
Node lifecycle changes still do. The solver consumes the separately produced
GPU counts. Mode changes and fallback transitions force the appropriate full
refresh; native metadata remains available when GPU production is ineligible.

## Verification

Independent diagnostics compare every live GPU node support count with a native
pre-solve snapshot, as well as component membership and aggregate support.
They separately verify that the resident native-support placeholder is zero.
The focused suite passed 30 tests, followed by kernel and native-fixture CUDA
memory checks with zero reported errors. PGS and TGS coverage includes moving
support away and back, supported dynamic/kinematic transitions, support-producer
switches, lifecycle reuse, growth and sleeping fallback. Repeated impacts compare
fracture decisions and all 720 trajectory samples at the unchanged tolerance.

Expanded transition coverage exposed a pre-existing native bookkeeping defect.
That fix and its standalone CPU/GPU regression were committed separately in
`e20568c9`; see [native kinematic support](NATIVE_KINEMATIC_SUPPORT.md).

## Remaining CPU work and timing scope

Native support counters are still maintained for the compatibility registry
and reference diagnostics. This change removes their use as GPU solver inputs;
it does not remove all CPU island maintenance. Node lifecycle commands,
managerless-edge lifecycle, interaction registration and component readback
remain CPU bridges. Full GPU lifecycle ownership and selective correction are
still open.

Audited captures include host validation and run on a shared GPU. The phase
report distinguishes additive outer intervals from overlapping task scopes.
It does not identify individual CUDA stress, collision or rigid-solver kernel
durations, and it is not an isolated performance or whole-game qualification.
Earlier unexplained native-crash and real-fracture sanitizer failures remain
open; the focused memory checks do not resolve those separate failures.

## Audited captures

Both captures completed with all stress solves converged, zero recorded motion
error, no registry mismatch fallback and no contact-boundary audit failures.
Source and library hashes, commands, counters and test evidence are in the
[qualification record](qualification/device-pre-solve-support-20260906.json).
The [full timing report](qualification/device-pre-solve-support-timing-20260906.md)
lists minimum, average and maximum for every recorded scope.

| Workload | 64 buildings | 256 buildings |
| --- | ---: | ---: |
| Chunks / bonds | 28,416 / 57,344 | 113,664 / 229,376 |
| Accepted steps | 600 | 1,800 |
| Steps with one resimulation | 104 | 385 |
| GPU contact records processed | 73,819,445 | 860,460,843 |
| Pre-solve producer H2D payload | 1,358,640 B | 5,463,168 B |
| Simulation min / mean / max | 0.64 / 60.78 / 425.94 ms | 1.03 / 226.15 / 1616.30 ms |
| Real-time factor | 0.274x | 0.074x |
| Steps exceeding 16.67 ms | 502 | 1,706 |

These producer payloads contain node updates; managerless bridge and retirement
payloads were zero in these particular workloads. Other uploads, compatibility
readbacks and diagnostic observations are additional. These separate chaotic
runs on a shared GPU cannot establish speedup against earlier captures.
