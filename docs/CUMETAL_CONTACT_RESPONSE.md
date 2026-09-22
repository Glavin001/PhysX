# Response stamp protocol audit

This records source ordering and focused GPU tests, not integrated scene acceptance.

`PxgContactResponse.cuh` is invoked after actual PGS/TGS writeback. All writers
load `desc.nativeResponseEpoch` from the same stable solver descriptor. A
manager can have multiple patches; every writer in a pass stamps the same
64-bit value. No code uses the stamp as a ready flag.

`PxgNarrowphaseCore.cpp:1825` advances the epoch once per NP pass and aborts
on maximum exhaustion. `PxgSolverCore.cpp:479` transfers it to the solver
descriptor. `PxgTGSCudaSolverCore::writeBackBlock` launches on `mStream`.
`PxgSimulationCore::update` joins the solver stream into the simulation stream
via `synchronizeStreams(... stream, mStream, mEvent)` before body update work.
`PxgSimulationController.cpp:842` hands this simulation stream to destruction
`advance`. `PxgDestructionRuntime.cu:1359-61` joins the borrowed NP preparation
and that final body writer into the destruction stream before `routeContacts`.
`routeContacts` reads the whole 64-bit epoch only after that dependency.
`PxgSimulationController.cpp:844-852` finishes destruction before buffers can be
recycled or the scene published; the next corrected/simulation pass cannot
change the stamp while these readers are active.

For `PX_CUMETAL_SPLIT_RESPONSE_STAMP`, each word is atomic under simultaneous
same-epoch writers. Joining every writer yields exactly the epoch in both
words, regardless of interleaving. Different epochs and readers MUST NOT
overlap. This is a protocol-specific optimization, not a general replacement
for 64-bit atomic exchange or a fence. Layout and all 64 bits are unchanged.

The native fixture uses actual PGS/TGS headers and the actual helper: 1024
patch threads per kernel, 32 writers per manager, four epochs, zero-normal and
invalid-force skips, sentinel bytes throughout contact records, three queued
graph replays, and two producer streams joined by events in the last pass.
CuMetal raw device-address mode serializes resource hazards, so this is not
evidence of hardware overlap between streams. Event dependencies are explicit
and also valid on CUDA. Linux NVIDIA execution has not been performed.
