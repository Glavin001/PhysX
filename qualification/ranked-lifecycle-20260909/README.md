# Ranked lifecycle replacement work — 2026-09-09

## Restore the qualified starting path

The user requires the **Ranked replacements** order, starting with GPU fragment
lifecycle, then structural solving, then persistent contacts. The production
contact-retention prototype from `baed87a9` is deferred because it changes motion
at wall step 17 and fails the full frozen physical oracle. That original commit,
ordering experiments and standalone GPU ownership/registration fixtures remain.
The later incomplete registration-feed draft is archived under
`../native-contact-owner-20260909/deferred-registration-feed.patch` and is not
compiled or linked.

Restored 18 production/consumer files to the qualified pre-prototype version
(with whitespace cleanup only). Rebuilt PhysX, PhysXGpu, destruction runtime and
native demo/material/collision/ordinary-scene consumers against the matching ABI.
No live service or deployed binary changed.

One building, 444 chunks, 896 bonds, one projectile, dt=1/60, max one correction:

- Historical Direct GPU on / sleeping off: 32-step prefix passes, exact motion
  and topology versus the archived mode-matched reference.
- Ordinary Direct GPU off / sleeping on: 32-step prefix passes, exact motion
  and topology versus the archived mode-matched reference.
- Full historical 600-step / 10-second physical audit passes the existing golden.
  See the quality receipts for identities, holes and trajectory invariants.

These are correctness runs, not performance claims or full replacement
qualification. Raw captures and motion are in `out/ranked-lifecycle-20260909`;
committed receipts include actual binary hashes and reference provenance.

## Remaining

Priority 1 still requires GPU allocation, simulation metadata and shape-owner
transactions to cease depending on CPU compatibility objects before correction.
The CPU preparation and rebinding bridge is still active. Priorities 2–7 are
not completed by this restoration. See `docs/destruction/IMPLEMENTATION_LEDGER.md`.
