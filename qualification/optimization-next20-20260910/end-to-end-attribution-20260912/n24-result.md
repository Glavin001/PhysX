# N24: current physical gate failed

Native impact memcheck passes, but live-bond scaled force difference0.920084 exceeds unchanged2e-4 gate;3116 health scalars differ, max5.96e-7. Inputs/contact surfaces/broken mask/ownership/crush/objects match exactly. Iterations304 to64. No performance campaign or promotion. Independent equation audit will determine actual error in both arms before any quality-policy decision.

Commit `c96626dfd43123e667ba0241ef3028c9e37a5c5e`. Both arms pass existing numerical/3D/motion oracles and three3D sanitizers. Control passes flying, city25 initial impact and city256 late-debris native memcheck/physical checks. Candidate flying passes; candidate city25 impact has zero memcheck errors but fails saved physical comparison. The candidate large-debris case and seven-case timings were therefore not run.

The largest force differences are on live bonds, not stale broken-bond outputs. Aggregate relative L2 force difference is1.12257e-6; this does not replace the unchanged fieldwise2e-4 gate. No claim about which solution is more accurate is justified yet. A separate diagnostic build captures the actual equations and each solved force field for an independent direct reference.

No new application timings or gains. [Current multi-scale full-step controls and work census](removal-work-census.md) remain the reference; no failed-quality timing is treated as a speedup.
