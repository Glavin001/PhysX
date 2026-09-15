# N26 ordered validated binding plan

**Built and tested; closed without promotion, batch20/20. [Outcome and all measurements](n26-result.md). Historical preparation follows.**

Commit `e827d0e3382f7c5543e13a090c5d5f659aeec684` preserves the original validation pass, scheduler order and per-shape rebind calls. It retains validated source/target/shape pointers only for the current transaction, removing one repeated body resolution per scheduled body and two per binding during mutation. Plan allocation and writes are part of the full tick. No numerical/GPU runtime code changes.

The existing scopes expose1.601ms validation,0.586ms scheduling and13.893ms migration at first large fracture. Migration includes required work and instrumentation; those13.893ms are not a removal budget. Estimated direct benefit is0–0.8ms at a fracture-heavy tick and0–0.15ms heavy mean, with low confidence before A/B. The architectural benefit is a complete ordered migration plan for a future per-source contact index. That index is not implemented or credited here.

Body/shape storage remains live throughout this call: scheduling changes metadata, contact retirement releases pairs, and rebind moves existing shape ownership. The original `NpShapeManager::rebindShapeInternal` validation remains intact at mutation. No pointer persists across calls, no PhysX actor/contact ordering changes, and no cache is added to snapshot state.

The confirmed live counter390717 is completing city256 cascading-fracture,48/52 ordinary cases complete. N26 coordinator738816/session91345 waits for its completed pause boundary, then builds both CPU consumers from frozen libraries and runs the existing29-case correction regression plain/memcheck, three both-arm restored memory/physical cases, and the seven-case120-tick light A/B/A. CUDA activity/runtime binaries remain byte-identical between arms. No CPU build or second GPU job overlaps the capture. Restoration watcher338813 remains live.

[Exact source hashes, build/test recipes, hypothesis and stage evidence](n26-preparation.json). [Prior seven-case control timings and complete accounting](n25-screen.md) are historical reference only; no N26 measurement yet. Main source/index and installed SDK are unchanged.
