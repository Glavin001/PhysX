# Reference direction restart: no read before history exists

The asset-topology reference node-space direction update read the previous gradient norm before checking whether the iteration was zero. That allocation has no defined history on a first solve. The expanded CUDA initialization audit reported 116,042 uninitialized reads; after guarding the load, the full same audit reports zero errors. The native projected component solver uses a different direction update and does not execute this reference read.

The fix leaves the first beta exactly zero, and retains the existing later-iteration formula. A focused regression supplies a runtime iteration pointer and a null history pointer: first-direction formation must succeed with exact outputs without touching history. Numerical settings and physical acceptance limits are unchanged.

The before run used the polynomial candidate elsewhere in the translation unit. This reference function was identical to the recorded base revision; the reported kernel was the unpreconditioned reference specialization. The logs and source hashes preserve that distinction rather than attributing the failure to the new polynomial.
