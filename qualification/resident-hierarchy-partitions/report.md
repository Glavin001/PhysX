# Resident component layout — qualification

✅ Packing now consumes the native GPU partition contract and carries component ranges through compaction. Coarse rows are contiguous by component; no additional component sort or CPU grouping is required. Mathematical coefficients, authored ancestry, and physical topology are preserved.

✅ Independent original-equation and compact-transfer tests pass at the existing 2e-12 scaled tolerance. Coverage includes empty/fixed/parallel/self-edge fixtures and a 100,000-node / 199,997-bond graph through eight recursive levels and six topology transitions. Exact component ranges and counts are checked against an independent oracle.

✅ Missing views fail explicitly. Invalid counts, duplicate/out-of-range nodes, bad ranges, and a false empty partition hiding retained roots produce error 64; valid input recovers. CUDA memory/leak, synchronization, and race audits pass without suppressions or changed timeouts.

✅ Frozen wall quality passes: 10 simulated seconds, 444 chunks, 896 bonds, one projectile, dt 1/60, correction limit one. Exactly 398 supported chunks, 46 detached chunks, and 199 broken bonds; frozen topology identity, projectile clearance/holes, convergence, and render/collision checks pass. Production artifact hashes are unchanged.

🚧 The hierarchy is still independently qualified, not production-integrated. Terminal factors, coarse smoothers, V-cycle and native CGLS binding remain. This report makes no simulation speedup or deadline claim. Incidental physics_ms in wall-quality.json is not the authoritative full-step performance campaign.

Evidence: [validation](validation.json), [correctness](correctness.log), [CUDA safety](safety.log), [wall quality](wall-quality.json).
