# WIP handoff: GPU ownership migration is incomplete

The user requested a branch checkpoint for another engineer to take over.
This commit archives the current source, tests, tools, skills and readable
reports. It supersedes the previous summary-only commit restriction for this
checkpoint. It is **not** a runtime promotion or a claim that the combined
branch compiles, passes every test, or improves performance.

## Immediate answer: what compiles and passes?

| Scope | Build | Tests / qualification |
|---|---|---|
| Isolated ownership transaction V3 | Runtime, GPU module and native transaction fixture compile and link | 11 focused candidate invocations pass, including one memcheck and one synccheck |
| Earlier transaction V1 | Runtime and GPU module compile and link | Five control and five candidate invocations pass |
| Entire mixed branch saved by this commit | Not rebuilt as a combined implementation | Not qualified; do not infer a full-suite pass |
| Initialization checking | Existing selected/candidate failures remain | Historical full check: 2,174 errors; separately scoped device-read check: 91 errors; unresolved |
| Main GPU ownership migration | Not implemented end to end | No mechanism acceptance, nine-case performance qualification, full52 qualification, or application speedup |

The V3 checks cover ordinary/native preparation order, invalid storage and stale
generation rejection without mutation, duplicate submission, clear, growth and
no-growth fractures, contact response, retained contacts, initialization
rejection, slot exhaustion, accepted properties, correction bodies and
checkpoints. Some invocations contain multiple cases. There are 21 passing
invocations across V1 and V3; they are not 21 performance scenarios.

V2's added fixture failed to link against a frozen scene object with an older
constructor. V3 compiles matching frozen scene source and fixes that test-build
problem. The failed attempt is retained locally. No fresh GPU run or whole-branch
build was performed merely to save this checkpoint; saved module/source hashes
and passing receipts were verified again.

## What the ownership implementation actually changes

The private runtime now exposes a resident transaction with current prepared
body inputs, shape assignments, native node records, generations and readiness.
The controller uses one validated commit to restore rigid state and install
body/shape changes. It rejects invalid storage and duplicate/stale submissions
before writes and uses one completion boundary. The private factory advances
from V20 to V21. Public behavior and physics quality settings are unchanged.

**The CPU dependency is still present:**

GPU fracture → ownership transaction → CPU fragment construction and shape/contact
registration → CPU active-body indexing and contact partitions → corrected GPU
physics → second stress → final publication.

The main task is to replace those contact/solver registration consumers for
affected contact islands, including ordinary-body participants, readiness and
sleep/wake. Another readback or event-count reduction does not complete it.
Do not remove the sleeping eligibility guard, use stale contacts, or schedule
more than one correction. Preserve CPU actor/query/callback visibility before
returning the complete tick.

Read the [scope and acceptance contract](../../reports/destruction-gpu-ownership-hypothesis-20260915/README.md),
[live checklist](../../reports/destruction-gpu-ownership-hypothesis-20260915/PLAN.md),
and [source-level consumer audit and results](../../reports/destruction-gpu-ownership-hypothesis-20260915/IMPLEMENTATION.md).
The target remains an independently confirmed 10 ms saving in the fixed City256
impact window, with unchanged physical quality and regression gates. No such
gain has been established.

## Three source identities: keep them separate

1. **Selected control:** source `13b11af2e0aeabf4e0070931fbd8a060f383dfaf`,
   runtime SHA256 `d5770a80c2f4686b0ad311edcbfc8e128d14baee64653bf5e032305c12cf9354`.
   Local artifacts: `out/destruction-baseline-20260913/artifacts`.
2. **Tested transaction candidate:** `out/ownership-migration-20260915/source`,
   artifacts `out/ownership-migration-20260915/transaction-build-v3`.
   Runtime SHA256 `f60093d477b13a4f8ac292009aa733e5648c6eadc5e677b506609057e2b2fa40`;
   GPU module SHA256 `425403041926897f4aff24de8ef593268d2e3a525574e1801c2ad8aee50a1d08`.
   No E1/E2/E3 prototype composition. All 143 reused GPU link inputs match the
   earlier selected-module attestation.
3. **Main source saved in this branch:** a broader mixed development state,
   including earlier stress, snapshot and diagnostic work. It is not identical
   to either tested source above. Existing convergence-policy work is preserved
   as a separate experiment; do not attribute its changed-quality results to
   ownership migration.

## Portable candidate source

The tested candidate lived under ignored `out/`. Its four changed files are now
saved as [ownership-transaction-v3.patch](../../reports/destruction-gpu-ownership-hypothesis-20260915/ownership-transaction-v3.patch),
with exact hashes and validation summary in
[source-provenance.json](../../reports/destruction-gpu-ownership-hypothesis-20260915/source-provenance.json).
Applying the patch was checked to reproduce every tested changed-file hash.

The selected baseline commit is on a separate local branch. To avoid depending
on that branch being transferred, this checkpoint also includes
[selected-source-from-b481d3b5.patch](../../reports/destruction-gpu-ownership-hypothesis-20260915/selected-source-from-b481d3b5.patch).
It reconstructs the selected PhysX/Blast/demo source from the reachable ancestor
`b481d3b5`. All 89 changed baseline files were checked byte-for-byte.

From this repository, reconstruct into a new temporary source directory:

```bash
repo=$(pwd)
ownership_source=$(mktemp -d /tmp/physx-ownership-v3.XXXXXX)
git archive b481d3b5 physx blast demos/blast-stress-demo | tar -x -C "$ownership_source"
git -C "$ownership_source" apply "$repo/reports/destruction-gpu-ownership-hypothesis-20260915/selected-source-from-b481d3b5.patch"
git -C "$ownership_source" apply "$repo/reports/destruction-gpu-ownership-hypothesis-20260915/ownership-transaction-v3.patch"
```

This reconstructs source, not binaries. The local incremental build tool
`tools/diagnostics/destruction-ownership/build-migration.py` depends on frozen
local build recipes and objects under `out/`; it is not a standalone fresh-clone
build script. See `OPTIMIZATION.md` for repository build prerequisites/commands.

## Evidence, tools and next work

Local receipts are under `out/ownership-migration-20260915/`:

- `transaction-build-v3/build.json`: commands, dependencies and module hashes.
- `native-v1/campaign.json`: earlier selected/candidate comparisons.
- `native-v3/campaign.json`: transaction rejection and focused sanitizers.
- `native-v3-regression/campaign.json`: seven final native regressions.
- `checkpoint.json`: terminal jobs, free lease, no compute clients, restored
  desktop/persistence services and unchanged selected artifacts at the checkpoint.

Raw profiler captures, binaries, snapshot payloads and timing logs remain local
and ignored. A fresh clone does not contain them. The saved reports distinguish
historical cohorts and evidence locations; do not reuse a profile as if it
measured a different source/workload.

Continue from the actual incomplete contact/solver consumers in the checklist.
Use focused correctness/work checks while implementing. Once a complete
mechanism exists, use the nine-case warm screen, selected profiling and independent
confirmation, then full52 and continuous physical qualification for finalists.
Keep restore and fixed warmup outside full-tick timing, all recurring work inside.
Do not spend another full52 campaign qualifying only this transaction foundation.

Checkpoint audit: staged raw/build-payload scan passes. The general whitespace
check reports only preserved patch context and generated SVG whitespace (178
patch findings; 15,141 SVG findings). It reports no source/prose/tool whitespace
findings. Patch bytes are preserved because their reconstruction hashes matter.
