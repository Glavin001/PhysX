# Skip recursive stress preparation when no component consumes it

Accepted as a removal of unnecessary GPU work. The complete SDK, real-time peak and endurance gates remain incomplete.

## Change

The exact fine factors, nullspace construction and fine-level validation still run. A CUDA conditional inspects the current component partition after fine-level terminal selection. When every component uses the existing block solver (at most 1,024 nodes), the captured recursive packing, coarse construction, terminal and smoother work is bypassed. Larger components activate the original recursive path. No host readback, new compatibility implementation, changed equation, precision change or iteration-budget reduction was added.

Fine-only readiness is published only after checking the fine status, generation and each live component's retirement certificate. Errors remain errors. A later large-component generation refreshes recursive state before it can be consumed. The production block solver consumes only the fine input/factors and its separate motion modes; cooperative iteration is bypassed when its large-component count is zero.

This removes execution, not reserved capacity: recursive storage and graph descriptors are still allocated. Fine topology/motion-mode rebuilding and affected-only caching remain separate opportunities.

## Validation

- Focused 1,034-node / 1,032-bond test compares exact fine factors byte-for-byte against the original producer. Both mixed-to-small-to-mixed and initially-small-to-mixed-to-small transitions pass. Coarse build statuses must remain unchanged when no component consumes them, and refresh when required again. Invalid bond indices, endpoint incidence and CSR bounds are rejected; recovery passes.
- The old test expected unused coarse counts to be zeroed. It now requires the skipped producers not to run and required producers to refresh. Numerical and connectivity assertions are retained.
- An initialization audit exposed the test downloading unwritten terminal-kind slots outside live component IDs. The test now observes only defined live outputs. Original failure evidence is preserved in `fine-only-initcheck.log`; the corrected audit and memory check report zero errors. Production storage was not zero-filled to satisfy the test.
- Rebuilt native analytic, 3D and motion suites pass existing tolerances. Full native analytic initialization check reports zero errors, including quiet/load transitions and split components.
- Frozen penetration: 444 chunks, 896 bonds, one projectile, ten simulated seconds; both-wall clearance, exact topology signature, 398 retained chunks, 46 detached and 199 broken bonds pass, with at most one correction per step.
- Timed bombardment: 256 buildings, 113,664 chunks, 229,376 bonds, 256 projectiles, 180 steps per run. Physical body/contact/fracture/convergence histories match; iteration counts can differ. This is not bit-identical trajectory proof.

## Performance evidence and limits

[Generated comparison](comparison.html) includes complete-step peaks, same-step phases, raw sample hashes and transfer counts. The accepted comparison uses two clean candidate runs followed by two baseline control runs. Every measured step is retained. A preceding exploratory screen overlapped a CPU test build and is retained separately in `qualification/hierarchy-tail-demand-impacts-256`; it is not acceptance evidence.

The separately instrumented acceptance phase decreases by roughly half a millisecond. Mean whole-step cost improves slightly. Peak timing varies substantially in other phases, so the larger difference between these short runs must not be attributed entirely to this change. Neither the 8 ms goal nor 60 Hz is achieved. Five 60-second runs and ten-minute endurance are still outstanding.

Regenerate from the repository root:

```sh
python3 tools/scripts/compare-destruction-candidates.py --baseline qualification/hierarchy-tail-demand-baseline-control/report.json.gz --candidate qualification/hierarchy-tail-demand-isolated/report.json.gz --output qualification/hierarchy-tail-demand
```

`validation.json` records the exact candidate source, test/runtime binaries and evidence. The baseline is commit `d4bb32d9`, including GPU-preserving pre-solve roster growth. No earlier arithmetic experiments or runtime fallback switches were reintroduced.
