//! The showcase behaviours (`stress-ref/tests/shared/showcases.rs`) with PhysX CPU as
//! the rigid-body engine: the same assertions must hold.

use stress_physx::PhysxEngine;
use stress_ref::math::Vec3;
use stress_ref::scene::Scene;
use stress_ref::world::World;

fn make_world(scene: &Scene) -> World {
    let engine = PhysxEngine::boxed(Vec3::from_array(scene.gravity)).expect("PhysX CPU scene");
    World::with_engine(scene, engine)
}

#[path = "../../stress-ref/tests/shared/showcases.rs"]
mod cases;
