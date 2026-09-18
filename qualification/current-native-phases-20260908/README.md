# Current native peak exposure

[Mass-fracture diagnostic](fracture/report.md) and [pristine-idle diagnostic](idle/report.md) use current API-v15 consumer/GPU modules and the accepted shared-normalization solver. The independent untraced results remain [here](../shared-normalization-20260908/repeated/report.md). No profiler result replaces the deadline measurement. Three restored-source numerical suites pass before capture.

256 buildings / 113,664 chunks / 229,376 bonds / 768 physical rounds / 600 steps. Tick 48 has 10,449 fragments (10,193 awake), 216,220 normal contacts and 57,788 broken bonds. Complete diagnostic advance 151.620 ms: 30.929 ms CUDA stress overlaps 32.180 ms host destruction wait; CPU fragment compatibility creation 21.146 ms; correction 52.336 ms; CPU ownership operations remain substantial. These values are exposure, not an additive promise of savings. Actual GPU rewind copies cost only 0.019 ms.

Next architectural investigation: contact/interaction lifecycle and fragment compatibility creation. ShapeSimBase::rebindRigidOwner unconditionally calls onVolumeRemoved; preserving geometry alone does not currently preserve contact-manager/interaction records. A safe change must distinguish genuinely new fragment pairs from valid old shape pairs and update actor/island/report ownership plus invalidate solver state. Do not assume all correction/contact-allocation cost is avoidable: many post-fracture pairs are new. Current Interaction stores actor references; simply skipping release would leave stale references. No lifecycle change has been made by this report.

The shader register-budget and local multilevel candidates are reverted. Changing ordinary NVIDIA collision equations or removing contacts is outside the optimization. The historical external baseline remains physically unmatched; superiority and real-time performance are unproven.

Follow-up: the nested sleepCommit union (4.929 ms) contains 6,345 mostly empty placeholder calls; it is not a single GPU sleep transaction. See [rejected fusion and call-count analysis](../native-sleep-commit-20260908/README.md).
