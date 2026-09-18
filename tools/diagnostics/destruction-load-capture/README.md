# Native load capture and adapter replay

See the [capture evidence and commands](../../../qualification/live-loads-20260910/README.md).
The [current GPU-partition follow-up](../../../qualification/elastic-partition-20260910/README.md)
adds native mapping reuse/rebuild receipts and device-count load consumption.

`build.py` injects `Capture.cuh` into an isolated copy of the native runtime,
using the existing build's compile/link settings. `run.py` executes the matched
256-building workload and retains actual loaded-module provenance. It records
four post-contact/pre-stress evaluations, including both sides of the first
fracture. Installed SDK libraries are not overwritten.

`analyze.py` validates recorded ownership/mass and independently reconstructs
surface loads from recorded impulses. `Replay.cu` consumes those real inputs as
an explicitly defined surface-plus-gravity numerical case; it does not certify
all native force commands or publish fractures. `check_replay.py` independently
checks Newton–Euler equations. `validate.py` runs replay checks, focused CTests,
four CUDA sanitizers and one selected hardware-counter capture into a fresh
directory. Inspect GPU availability before starting it.

Optional `--fine` after the replay output prefix joins those loads into the
six-channel graph, performs setup/solve and gates bond recovery on convergence.
`check_fine.py CAPTURE PREFIX` independently checks the exported fine equations,
loads, responses and energy. Its explicit stiffness/accuracy profile is an
uncalibrated numerical probe, not a material or native-physics qualification.

`--fine-setup` instead stops before solving and exports component setup, bases
and the last tested mode/action. `check_setup.py CAPTURE PREFIX` compares that
action with extended precision to investigate free-fragment setup rejection.
It does not waive failed setup or solve criteria. See the
[load join evidence](../../../qualification/elastic-load-join-20260910/README.md)
for exact build/run commands, failures and hardware counters.

`--fine-check` runs setup, load compatibility and the initial fine-residual check
with zero numerical iterations. Nonconverged components remain pending. Use
`inspect_compatibility.py CAPTURE PREFIX` to attribute incompatible RHS values
to captured contact/spin inputs without repeating capped solves. This diagnostic
does not qualify a completed stress/material query. See the
[gravity-cancellation follow-up](../../../qualification/elastic-gravity-cancellation-20260910/README.md).

Binary records use the captured native ABI. Each capture manifest records count
and stride; the Python readers reject mismatches. Receipts retain actual float
input duration, device tick, trial/correction evaluation and topology generation.
The source-patch/SDK/source hashes belong with the capture; do not treat these
files as a stable public serialization API.
