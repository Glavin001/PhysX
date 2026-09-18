# Accurate native warm residual — qualified short screen

✅ Native warm initialization now uses the same FP64 physical force/couple sum as final verification. The adapter FP32 multiply/subtract pair is absent from the native launch sequence. Cold starts retain their initialized RHS. No new allocation or CPU readback; convergence, timestep, materials and correction policy remain unchanged.

🗑️ Norm-only operator visits no longer calculate the duplicate endpoint contribution. Matrix-vector products still visit both endpoints; fixed-to-dynamic boundary ownership is retained. This deletion alone did not demonstrate a robust peak win.

✅ Three native numerical suites pass, including a new independent long-double cancellation oracle (19 nodes, 35 bonds, non-unit mass/scales, removed bonds, cold-start no-op and exact zero-correction verification agreement). Eight ordinary-scene sleep/wake/reuse/query tests pass. Both frozen 600-step wall captures retain 398 supported / 46 detached chunks and 199 broken bonds from 444 chunks / 896 bonds / one projectile. Runtime mapping is checked by the runner. Archived wall CSVs are gzip-compressed.

📈 Downtown: one 600-step pristine-idle capture and one three-shot capture per candidate, 27 buildings / 24,105 chunks / 74,543 bonds. The deployed narrow-inverse idle mean was 2.469 ms, accurate-warm candidate 1.000 ms; reported per-step maximum-iteration sums decreased from 1,947 to 152 (not a count of total component work). Idle startup remains 209.173 ms and fails both deadlines. Destruction peaks overlap; no meaningful destruction-peak win established.

❌ The 256-building / 113,664-chunk / 229,376-bond / 768-projectile / 600-step bombardment remains slow. The accurate-warm complete peak is 157.891 ms and loaded peak 142.666 ms versus deployed 158.065 / 140.393 ms. Chaotic histories differ. No scale superiority, 60 Hz, endurance or historical external-backend parity claim. Both paired scale reports preserve all steps.

The report compares embedded implementations. The isolated historical external downtown reference fractured spontaneously at idle and is not an equal-fidelity passing comparator; that mismatch still needs resolution.
