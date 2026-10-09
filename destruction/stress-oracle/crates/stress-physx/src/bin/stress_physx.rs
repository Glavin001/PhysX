//! `stress-physx`: the `stress-ref` command line (see `stress_ref::cli`) with every scene
//! run in the world coupled to PhysX CPU as its rigid-body engine. `check` therefore
//! compares the PhysX-coupled runs against the analytic expectations and the oracle
//! goldens.

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
    stress_ref::cli::main(&coupled, std::env::args().skip(1).collect())
}
