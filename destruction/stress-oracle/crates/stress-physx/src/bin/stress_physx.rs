//! `stress-physx`: the `stress-ref` command line (see `stress_ref::cli`) with every scene
//! run in the world coupled to PhysX CPU as its rigid-body engine. This is an
//! alternative to the standalone oracle, not a replacement: `run` and `check` gate the
//! PhysX-coupled run against the analytic expectations, the oracle goldens, and the
//! standalone reference world's run of the same scene.

use std::process::ExitCode;

use stress_physx::PhysxEngine;
use stress_ref::math::Vec3;
use stress_ref::scene::Scene;
use stress_ref::world::World;

fn coupled(scene: &Scene) -> World {
    let engine = PhysxEngine::boxed(Vec3::from_array(scene.gravity)).expect("PhysX CPU scene");
    World::with_engine(scene, engine)
}

fn main() -> ExitCode {
    stress_ref::cli::main(&coupled, Some(&World::new), std::env::args().skip(1).collect())
}
