# Accepted query membership for ordinary native scenes

Native GPU freeze/unfreeze lists now enqueue changed shape identities for the
CPU query observer. The scene reconciles those identities once, after the last
stress/fracture evaluation and accepted ownership transaction. It uses the
current body's active/frozen state, not the rejected trial's transition verdict.
The ordinary non-destruction PhysX path is unchanged.

The two physics passes produce delta lists. A shape that changed in the trial
but does not appear in the correction list must still be reconciled. A retained
bitmap deduplicates IDs, while a sparse touched-ID list avoids scanning sleeping
geometry or clearing the full bitmap each step. Only touched bits are cleared.
These buffers belong to the CPU query observer, not the physics/stress solver.
Shapes/IDs remain stable during native ownership transactions; removal/reuse
outside the step is observed through the ordinary scene lifecycle. Failed scene
steps discard pending observer work and remain explicitly incomplete.

This deletes the callback's provisional query-tree membership changes. It does
not yet delete shape-state DMA, CPU wake/sleep status tasks, activity checkpoint
or rollback, or CPU ownership lifecycle. Ownership changes and normal actor
activation can also update query membership internally; this change does not
claim to defer every CPU query operation. The complete GPU provisional-activity
migration remains unfinished.

Code:

- `ScScene.cpp`: the GPU callback queues frozen/unfrozen identities rather than
  editing query membership before fracture evaluation.
- `ScPipeline.cpp`: `publishDestructionQueryMembership` reconciles accepted
  activity after `advanceDestruction` finishes without another correction.
- `native_query_publication_check.h`: audit run inside the standard sleeping,
  later-impact fixture; requires queued transitions, at most one membership
  publication per tick, and accepted destruction status at publication. Existing
  fixture checks immediate raycasts, sweeps, overlaps and GPU/CPU motion.
- `report-native-cpu-sync.py`: validates a single final membership receipt when
  queues exist and rejects membership publication before replay completes.

Qualification evidence is recorded in `qualification/native-query-publish/`.
The frozen 10-second penetration golden remains unchanged. Large-scene profiling
checks the placement of observer work; it is not a matched untraced speedup test.

The two-run 12-second 256-building performance screen does not show a peak win:
baseline 118.007 ms worst versus candidate 124.409 ms. Mean is 59.420 versus
57.481 ms; the mean does not satisfy the peak objective. Physical histories in
this chaotic workload differ and are preserved by the comparator (exit 1).
See `qualification/native-query-publish-comparison/comparison.md`. Retained as
an accepted-observation data-flow change with controlled tests, not a qualified
performance improvement. Further GPU activity/stress work remains required.
