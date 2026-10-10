//! Single-precision GPU stress solver, diffed against the f64 reference (`stress-ref`).
//!
//! Kernels are written in Slang (`shaders/*.slang`) and compiled by
//! `scripts/compile_shaders.sh` (pinned Slang in Docker) to Metal Shading Language and
//! WGSL, both checked in. wgpu runs them: on macOS the Metal library goes straight to
//! the driver (`build.rs` builds it with Xcode), in a browser the WGSL goes to WebGPU.
//! Everything on the GPU is f32; accuracy against the reference is measured, not assumed.

pub mod gpu;
pub mod contacts;
pub mod joint;
pub mod loads;

/// The generated shaders of one Slang file, in every form the runtime can load.
#[derive(Clone, Copy, Debug)]
pub struct ShaderSet {
    pub name: &'static str,
    pub wgsl: &'static str,
    pub msl: &'static str,
    /// Built from `msl` by `build.rs` (empty when Xcode was unavailable).
    pub metallib: &'static [u8],
    /// Entry points and their workgroup sizes (render stages: `(1, 1, 1)`).
    pub entries: &'static [(&'static str, (u32, u32, u32))],
}

macro_rules! shader_set {
    ($name:literal, [$(($entry:literal, $size:expr)),* $(,)?]) => {
        ShaderSet {
            name: $name,
            wgsl: include_str!(concat!("../shaders/generated/", $name, ".wgsl")),
            msl: include_str!(concat!("../shaders/generated/", $name, ".metal")),
            metallib: include_bytes!(concat!(env!("OUT_DIR"), "/", $name, ".metallib")),
            entries: &[$(($entry, $size)),*],
        }
    };
}

/// Every Slang file's generated shaders.
pub mod shaders {
    use super::ShaderSet;
    pub const SMOKE: ShaderSet = shader_set!("smoke", [("smoke", (64, 1, 1))]);
    pub const STRESS_STEP: ShaderSet = shader_set!("stress_step", [("bond_forces", (64, 1, 1)), ("chunk_integrate", (64, 1, 1)), ("island_substeps", (256, 1, 1)), ("island_shared_substeps", (256, 1, 1))]);
    pub const JOINT_TEST: ShaderSet = shader_set!("joint_test", [("joint_eval_test", (64, 1, 1))]);
    pub const STRESS_ISLAND: ShaderSet = shader_set!("stress_island", [("island_frame", (256, 1, 1))]);
    pub const CONTACT: ShaderSet =
        shader_set!("contact", [
            ("contact_pairs", (64, 1, 1)),
            ("impactor_candidates", (64, 1, 1)),
            ("contact_impactors", (256, 1, 1)),
            ("impactor_forces", (64, 1, 1)),
            ("contact_gather", (64, 1, 1)),
            ("impactor_integrate", (256, 1, 1)),
        ]);
    pub const STRESS_RENDER: ShaderSet = shader_set!("stress_render", [("stress_vs", (1, 1, 1)), ("stress_fs", (1, 1, 1))]);
}

pub mod scenes;
pub mod solver;
pub mod world;
pub mod stress;
