//! `stress-ref`: the double-precision CPU reference solver for elastodynamic
//! destruction stress, and the harness that compares it against external oracles.
//!
//! Layering (see `README.md` of the workspace for the full picture):
//! * [`scene`] — the shared scene format every solver and oracle exporter reads;
//! * [`material`], [`bond`], [`joint`] — material laws, bond stiffness and the
//!   damageable joint (failure surface, softening, cracked-joint contact);
//! * [`solver`], [`statics`] — clusters in a floating frame, explicit substeps,
//!   quasi-static solves, fracture and splitting;
//! * [`world`] — a standalone rigid world (impactors, ground, contact, blast,
//!   scripted loads and events) that drives the solver for reference runs;
//! * [`observation`], [`metrics`] — solver-independent results and the metrics
//!   computed identically from ours and every oracle's observation;
//! * [`api`] — the engine-facing trait for swapping stress-solver implementations.

pub mod api;
pub mod blast;
pub mod bond;
pub mod builders;
pub mod contact;
pub mod joint;
pub mod material;
pub mod math;
pub mod metrics;
pub mod observation;
pub mod refine;
pub mod rng;
pub mod scene;
pub mod showcases;
pub mod solver;
pub mod statics;
pub mod structure;
pub mod world;
