# Ordered contact-retirement design

**Host ordering model passed; native batching is not implemented or qualified. No application speedup or experiment credit.**

The current reverse iterator scans all actor interactions for each migrating shape, filtering for that shape. Actor unregister removes a pair using replace-with-last, updating the moved pair's actor index. A naive once-per-actor reverse release changes the order across shapes and can affect later allocation/contact history.

A preserving design is:

1. After all scheduler/type changes, index the still-live pairs for the complete ordered migration plan. Visit each distinct source actor once.
2. Assign a pair to its earliest migrating endpoint. Record it only while visiting that endpoint's actor; this avoids duplicate or later dangling references when both endpoints migrate.
3. Immediately before each existing shape rebind, sort only its assigned pairs by their **current** actor-array index, descending. Earlier bindings may have changed these indices.
4. Invoke the original release operation in that order, with the same removed element, wake/lost-touch flags and output view. Keep refilter, ownership registration and publication order.

The model checks exact release event sequence, remaining actor arrays and index maps across2,961 exhaustive/random/compound cases, including non-element constraints and both migrating endpoints. The synthetic300-shape/1,176-pair compound cases reduce actor-list visits from82,289–118,296 to1,176–2,352. These counts are not a native timing estimate or physical validation. [All evidence and raw-result hash](n26-contact-order-design.json).

The critical native prerequisites are no unrelated interaction creation/deletion during the migration loop, stable validated bodies/shapes, and unchanged callback/report semantics. `releaseElementPair` does call filter-pair lost callbacks; preserve API write restrictions and audit those paths before introducing an index. Build the index after scheduler changes, since flag changes can affect existing interactions.

The diagnostic header is now built and all seven native cases pass14 restored physical ticks. [Measured visits and qualification limits](n26-native-census.md). Allocation/logging cost is not application timing evidence; the proposed index is still unimplemented.

Reproduce the host model without the GPU:

```bash
python3 tools/diagnostics/destruction-snapshot/check-contact-retirement-order.py \
  out/native-contact-retirement-design-20260912/order-model-recheck.json
```
