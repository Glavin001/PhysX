# CuMetal handoff — paused 2026-09-22

The current handoff is maintained in the sibling CuMetal repository:

[PhysX / CuMetal current state, evidence, build/test commands, and next steps](../../cuda-metal/docs/PHYSX_METAL_HANDOFF.md).

Implementation is paused at the user's request. All owned build, simulation, and rendering jobs have ended. The restricted native Metal destruction executable builds and runs, but the wall overlap bug is **not fixed**. Latest evidence narrows the investigation to missing post-fracture contact interactions; ordinary GPU resolution of the captured box poses passes.

The linked handoff supersedes older blanket statements that native macOS cannot build, while preserving the distinction between the restricted demo and full SDK acceptance. The source checkpoint branches are `codex/cumetal-destruction` here and `codex/physx-metal-integration` in CuMetal. Generated build and recording evidence remains ignored under `out/` and must be copied separately for takeover on another machine.

A subsequent fresh 240-frame wall recording (CuMetal command 1073) still detached all 20 unsupported chunks, broke 35/40 bonds, and reached 0.96265 m box penetration. The captioned 1080p/60 WIP video passed full decode; no overlap fix is claimed. See the latest checkpoint section of the linked handoff for timings and artifact paths.
