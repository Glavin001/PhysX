# GPU solver registration transaction — WIP

The standalone GPU transaction is implemented and tested. It is **not yet wired
into native contact birth/retirement, ownership changes or ordered touch-event
publication**. This does not fix the production wall regression, complete C1–C6,
or establish any performance improvement. Existing installed services are untouched.

## Responsibility

Keep persistent geometric contact lifetime separate from solver registration.
A cooperative CUDA transaction retires and assigns generation-bearing slots,
preserving ordered batch allocation. Device storage owns the live/free state;
there is no CPU allocator mirror or host decision inside the transaction.
The access adapter reads/writes native packet fields without requiring repacking.

Validation precedes canonical mutation. Stale or duplicate releases, generation
wrap, invalid state, and insufficient capacity latch an explicit failure rather
than partially publishing registrations. Capacity requests permit external arena
growth and retry with unchanged commands. Storage ownership/growth in the native
runtime is still to be implemented. Epoch claims are validation scratch and may
change on a rejected attempt; live registrations, free stack and outputs do not.

The CUDA owner must qualify cooperative residency once. Unsupported capabilities
fail explicitly; no CPU or ordinary-launch fallback is added.

## Evidence

The test compares GPU state and allocation sequence against an independent
sequential paged-allocation model across 300 deterministic mixed lifecycle batches,
with a 32,768-slot backing arena and 256-slot pages. It covers empty batches,
release/reuse, generations, aliased command/output storage, multi-block tails,
atomic stale/duplicate/capacity failures, capacity growth/retry and epoch/generation
exhaustion. These are allocator slots, **not simulated chunks, bonds or bodies**.

Normal execution and CUDA memcheck, initcheck, racecheck and synccheck pass, with
zero reported errors/hazards. Logs, commands and source/binary hashes are in
[evidence/registration](evidence/registration/receipt.json).

No production runtime source or ABI consumer links this new transaction yet;
this change adds its header/kernel and a standalone test target. The existing
600-step wall failure and its causal diagnostic remain documented in
[ORDERING_FINDING.md](ORDERING_FINDING.md). Repeating the unchanged failing scene
would not qualify this disconnected transaction.

## Next native integration

1. Give contact solver registration a persistent arena and lifecycle command
   stream at actual birth, retirement and re-owner boundaries.
2. Preserve allocation-batch ordering without tying it to CPU manager addresses.
3. Produce ordered touch/activation work on GPU and make the native consumer
   honor that order, including ordinary contacts and wake transitions.
4. Re-run native lifecycle tests and the exact frozen wall oracle before paired
   idle/destruction performance screens.

## Device batch queue extension

The allocator also consumes a producer-counted device command queue in one
cooperative launch. Later batches can read handles assigned by earlier batches
without host observation. Queue bounds are checked before payload access;
per-batch canonical atomicity is retained. An error stops subsequent batches,
while earlier internal registrations remain allocated: the containing simulation
must reject publication on the latched failure. This is not whole-queue rollback.

An additional 101-batch deterministic test covers GPU-produced handle dependencies,
producer/consumer stream event ordering, unused poisoned command capacity, empty
queues, invalid command offsets and queue-count overflow. Normal execution and all
four CUDA sanitizer modes pass. [Queue evidence](evidence/registration-queue/receipt.json)
records the exact updated source/binary hashes; the earlier receipt remains intact.

There is still no native call site or measured engine improvement from this queue.
It avoids introducing per-batch CPU decisions/launches into the planned native
registration integration. Its own potential saving has not been measured; the
larger opportunity remains persistent contact ownership and lifecycle migration.
