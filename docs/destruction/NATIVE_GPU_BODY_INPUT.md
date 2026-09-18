# Native GPU body input for destruction

The native trial now reads poses and angular velocities from PhysX's GPU body
pool in one CUDA gather. It no longer calls `getRigidDynamicData` twice inside
the destruction step or maintains a duplicate `mBodies` index array. Canonical
cluster bindings already contain the native body index. The same gather was
previously used only to observe accepted correction motion.

Contact extraction records the destruction input event. The native body-producer
stream waits for it and records that event after its existing body writes. The
destruction stream waits for this joined boundary, gathers the body frames, then
assembles loads and solves stress. This preserves the previous stream dependency
without CPU completion waits or application API calls. The gather's time is now
inside the `cuda.contactLoads` interval; earlier captures put API-gather work
before that interval.

Asset validation still rejects invalid sources and duplicate bindings when full
mass properties are supplied. Authoritative body state, principal COM frames,
load ordering, material parameters and the one-correction limit are unchanged.
This is an internal GPU data-flow change, not completion of GPU-only body-slot
registration, collision pair lifecycle, or sleep-safe correction.

The complete SDK build passes (`out/native-body-pool-input-build2.log`), followed
by all 35 focused regressions (`out/native-body-pool-input-tests.log`). Existing
independent normal/friction load, torque, virial, material, motion, allocation,
checkpoint, fracture, publication and GPU consumer assertions were retained.

The native contact fixture under Compute Sanitizer exits 99 with CUDA error 700
at `Runtime::finish` and 330 reported errors, including teardown cascades:
`out/native-body-pool-input-contact-memcheck.log`. It provides no native kernel
source attribution. Earlier native and independent conditional-graph failures
are documented in [CUDA_GRAPH_DIAGNOSTIC.md](CUDA_GRAPH_DIAGNOSTIC.md); this does
not prove that they share a cause. Native memory qualification remains open.
No conditional execution, error reporting or assertions were disabled.

The 30-second GPU-rendered large capture predates this body-input refactor. Its
source/library hashes are recorded separately; it must not be presented as a
performance measurement of this newer native input path.
