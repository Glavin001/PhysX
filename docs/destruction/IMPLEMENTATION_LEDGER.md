# Exhaustive destruction implementation ledger

This is a status index, not a completion claim. Historical rejected experiments remain in OPTIMIZATION_INDEX.json. The current candidate receipt contains actual tests and paired measurements.

| ID | Status | Responsibility | Current implementation / review entry point |
|---|---|---|---|
| A1 | ✅ Retained | Persistent assets | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| A2 | ⬜ Remaining | Share repeated asset data | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| A3 | ⬜ Remaining | Separate hot and cold data | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| A4 | ⬜ Remaining | Capacity and scratch management | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| A5 | ⬜ Remaining | Commands | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| A6 | ⬜ Remaining | First-step invariant setup | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| A7 | ⬜ Remaining | Production legacy code | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| S1 | ⬜ Remaining | Dirty load preparation | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S2 | 🚧 In progress | Settled-result reuse | [StressNativeSettled.cuh](../../blast/source/sdk/extensions/stressgpu/detail/StressNativeSettled.cuh) |
| S3 | 🛡️ Required | Damage during reuse | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| S4 | ⬜ Remaining | Global preparation passes | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S5 | ✅ Retained | Existing resident iteration | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S6 | ⬜ Remaining | Component size specialization | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S7 | ⬜ Remaining | Work scheduling | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S8 | ⬜ Remaining | Complete iterative-state locality | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S9 | ⬜ Remaining | Sparse operator representation | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S10 | ⬜ Remaining | Fuse necessary traversals | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S11 | ✅ Retained | Local inverse preservation | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S12 | 🚧 In progress | Component-local hierarchy invalidation | [NvBlastExtStressGpuTopology.cuh](../../blast/source/sdk/extensions/stressgpu/NvBlastExtStressGpuTopology.cuh) |
| S13 | ⬜ Remaining | Large-component reductions | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S14 | ⬜ Remaining | Large-component scheduling | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S15 | ⬜ Remaining | Stronger preconditioning | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S16 | ⬜ Remaining | Repeated-operator batching | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S17 | 🛡️ Required | Authoritative residual checks | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S18 | ⬜ Remaining | Precision and dense kernels | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| S19 | ⬜ Remaining | Separate force-export pass | [StressSolveSubmission.inl](../../blast/source/sdk/extensions/stressgpu/detail/StressSolveSubmission.inl) |
| L1 | ✅ Retained | Borrow solved contact buffers | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L2 | ⬜ Remaining | Shape-to-chunk lookup | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L3 | ⬜ Remaining | Contact work mapping | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L4 | ⬜ Remaining | Load accumulation | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L5 | ⬜ Remaining | Immutable material arithmetic | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L6 | ⬜ Remaining | Material work lists | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L7 | ⬜ Remaining | Fuse verdict production | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L8 | ⬜ Remaining | Redundant validation scans | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| L9 | 🛡️ Required | Diagnostic separation | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| T1 | ✅ Retained | Unchanged-topology bypass | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T2 | ⬜ Remaining | Affected-component connectivity | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T3 | ⬜ Remaining | Whole-world transaction copies | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T4 | ⬜ Remaining | Sparse fracture frontiers | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T5 | ⬜ Remaining | Mass/inertia scope | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T6 | ⬜ Remaining | Mass reduction mapping | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T7 | ⬜ Remaining | Repeated principal-frame work | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T8 | ⬜ Remaining | Ownership indexing | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| T9 | ⬜ Remaining | Sparse committed events | [PxgDestructionCommittedChanges.cuh](../../physx/source/gpudestruction/src/PxgDestructionCommittedChanges.cuh) |
| T10 | 🛡️ Required | Storage lifetime | [PxgDestructionTransaction.cuh](../../physx/source/gpudestruction/src/PxgDestructionTransaction.cuh) |
| C1 | ⬜ Remaining | Motion-slot lifecycle | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| C2 | ⬜ Remaining | Fragment simulation metadata | [NpDestructionBodyAllocator.h](../../physx/source/physx/src/NpDestructionBodyAllocator.h) |
| C3 | ⬜ Remaining | Persistent contact ownership | [ScShapeInteraction.cpp](../../physx/source/simulationcontroller/src/ScShapeInteraction.cpp) |
| C4 | ⬜ Remaining | Migration-driven contact churn | [ScShapeSimBase.cpp](../../physx/source/simulationcontroller/src/ScShapeSimBase.cpp) |
| C5 | ⬜ Remaining | Shape ownership transactions | [NpShapeManager.cpp](../../physx/source/physx/src/NpShapeManager.cpp) |
| C6 | ⬜ Remaining | Intermediate host decisions | [PxgDestructionRuntime.cu](../../physx/source/gpudestruction/src/PxgDestructionRuntime.cu) |
| C7 | ⬜ Remaining | Checkpoint work selection | [PxgSimulationController.cpp](../../physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp) |
| C8 | ⬜ Remaining | Correction work sets | [PxgSimulationController.cpp](../../physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp) |
| C9 | ⬜ Remaining | Collision/solver reuse | [PxgSimulationController.cpp](../../physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp) |
| C10 | ⬜ Remaining | Duplicate trial side effects | [PxgSimulationController.cpp](../../physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp) |
| C11 | ⬜ Remaining | Rigid-cluster collision hierarchy | [PxgSimulationController.cpp](../../physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp) |
| C12 | 🛡️ Required | Correction semantics | [PxgSimulationController.cpp](../../physx/source/gpusimulationcontroller/src/PxgSimulationController.cpp) |
| O1 | 🚧 In progress | Structural activity | [StressNativeSettled.cuh](../../blast/source/sdk/extensions/stressgpu/detail/StressNativeSettled.cuh) |
| O2 | ⬜ Remaining | Sleeping-body scans | [ScPipeline.cpp](../../physx/source/simulationcontroller/src/ScPipeline.cpp) |
| O3 | ⬜ Remaining | Unconsumed graph products | [ScPipeline.cpp](../../physx/source/simulationcontroller/src/ScPipeline.cpp) |
| O4 | ⬜ Remaining | Accepted CPU compatibility | [NpDestructionBodyAllocator.h](../../physx/source/physx/src/NpDestructionBodyAllocator.h) |
| O5 | ✅ Retained | Committed event consumers | [ScPipeline.cpp](../../physx/source/simulationcontroller/src/ScPipeline.cpp) |
| O6 | ✅ Retained | GPU rendering boundary | [ScPipeline.cpp](../../physx/source/simulationcontroller/src/ScPipeline.cpp) |

The three in-progress entries overlap: S2 implements exact-input reuse; S12 preserves only eligible certificates across unrelated topology changes, not the entire hierarchy; O1 has no complete producer-owned dirty-work system yet. No item is marked optimized merely because a CUDA kernel exists.

C1–C6 remain the leading architectural work. Merely retaining a contact manager while its ActorSim references, island edge, work-unit pointers or reporting owner remain stale is incorrect. GPU slot allocation currently selects CPU-granted indices and waits for CPU compatibility construction.

Evidence: [candidate receipt](../../qualification/native-settled-local-20260909/README.md), [idle](../../qualification/native-settled-local-20260909/idle/report.md), [bombardment](../../qualification/native-settled-local-20260909/shots/report.md).
