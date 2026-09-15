# Native contact retirement: measured traversal exposure

All seven cases pass physical comparisons against the exact N26 B parent, two independent one-tick restores each. Instrumented times are excluded from performance claims. The original runner stopped on optional city metadata after four passed structural cases; city continuation completes the other three.

Counts below sum both ticks and all nonempty transactions. An index is not implemented.

| Scenario | Actor-list visits | One scan/source/transaction | Retired pairs | Bindings without retirement |
|---|---:|---:|---:|---:|
| bridge64-cold | 0 | 0 | 0 | 0 |
| chain256-cold | 0 | 0 | 0 | 0 |
| dense12-cold | 0 | 0 | 0 | 0 |
| destruction-stimulus | 0 | 0 | 0 | 0 |
| city25-initial-impact | 85118 | 5958 | 200 | 1040 |
| city256-intact-idle | 0 | 0 | 0 | 0 |
| city256-late-debris | 3788264 | 127606 | 16758 | 7318 |

Late debris exposes29.69x more traversal than a once-per-source index; first impact14.29x. These are **visit ratios, not speedups**. The actual index must pay allocation, assignment and sorting costs and preserve the exact existing release sequence. A no-fracture chain has no nonempty transaction, weakening attribution of its N26 timing difference to lookup deletion.

[Order-preserving design and native assumptions](n26-contact-order-design.md). [Every transaction, physical report and raw hashes](n26-native-census.json).

Next bounded hypothesis: build a transaction-local per-source interaction index after scheduler changes, assign each pair to its earliest migrating endpoint, then use current descending actor index immediately before each original shape rebind. Keep all original release flags, callbacks and ownership publication order. Estimated0–2ms fracture-heavy tick,0–0.3ms heavy mean,0idle; low confidence until phase and unprofiled measurements. Existing profiled retirement scopes are1.66–1.81ms at earlier heavy peaks, not the whole13.89ms migration range. Costs: private CPU integration changes, exact-order shadow diagnostics, normal asynchronous memory/physical gates, light then all52/warm if qualified. Reject on any order/output discrepancy, index overhead dominating, or no repeatable full-step benefit.
