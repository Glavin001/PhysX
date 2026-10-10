//! The Slang -> {Metal library, MSL, WGSL} -> wgpu path runs and computes what the CPU
//! computes, through every shader form the device can load.

use stress_gpu::gpu::{Binding, Gpu, ShaderPath};
use stress_gpu::lattice::{cpu_substeps, Lattice, LatticeDesc};

#[repr(C)]
#[derive(Clone, Copy, bytemuck::Pod, bytemuck::Zeroable)]
struct SmokeParams {
    count: u32,
    scale: f32,
    _pad: [u32; 2],
}

const PATHS: [ShaderPath; 3] = [ShaderPath::MetalLib, ShaderPath::MetalSource, ShaderPath::Wgsl];

fn gpus() -> Vec<Gpu> {
    PATHS
        .iter()
        .filter_map(|&p| {
            let mut gpu = Gpu::new().expect("GPU");
            gpu.set_shader_path(p).then_some(gpu)
        })
        .collect()
}

#[test]
fn smoke_kernel_matches_the_cpu() {
    for gpu in gpus() {
        eprintln!("adapter: {} ({:?}), shaders: {:?}", gpu.adapter_info.name, gpu.adapter_info.backend, gpu.shader_path);
        let n = 1000;
        let a: Vec<[f32; 4]> = (0..n).map(|i| [i as f32 * 0.5, 1.0, -(i as f32), 0.0]).collect();
        let b: Vec<[f32; 4]> = (0..n).map(|i| [2.0, i as f32 * 0.25, 3.0, 0.0]).collect();
        let scale = 1.5f32;
        let params = gpu.uniform("params", &SmokeParams { count: n as u32, scale, _pad: [0; 2] });
        let (ba, bb) = (gpu.storage("a", &a), gpu.storage("b", &b));
        let out = gpu.storage("out", &vec![[0f32; 4]; n]);
        let kernel = gpu.compute(&stress_gpu::shaders::SMOKE, "smoke", &[Binding::Uniform, Binding::Storage, Binding::Storage, Binding::StorageRw]);
        let bind = gpu.bind(&kernel.group, &[&params, &ba, &bb, &out]);
        let mut encoder = gpu.device.create_command_encoder(&Default::default());
        {
            let mut pass = encoder.begin_compute_pass(&Default::default());
            kernel.dispatch(&mut pass, &bind, n);
        }
        gpu.queue.submit([encoder.finish()]);
        let got: Vec<[f32; 4]> = gpu.read(&out);
        for i in 0..n {
            let (x, y) = (a[i], b[i]);
            let c = [(x[1] * y[2] - x[2] * y[1]) * scale, (x[2] * y[0] - x[0] * y[2]) * scale, (x[0] * y[1] - x[1] * y[0]) * scale];
            let norm = (c[0] * c[0] + c[1] * c[1] + c[2] * c[2]).sqrt();
            for k in 0..3 {
                assert!((got[i][k] - c[k]).abs() <= 1e-6 * c[k].abs().max(1.0), "{:?} {i}.{k}: {} vs {}", gpu.shader_path, got[i][k], c[k]);
            }
            assert!((got[i][3] - norm).abs() <= 1e-6 * norm.max(1.0), "{:?} {i}: norm {} vs {}", gpu.shader_path, got[i][3], norm);
        }
    }
}

/// 2000 batched lattice substeps on the GPU against the same f32 arithmetic on the CPU.
/// The kernels may contract `a * b + c` into fused multiply-adds, so the bound is a few
/// f32 roundings per operation relative to the response, not bit identity.
#[test]
fn lattice_substeps_match_the_cpu() {
    let substeps = 2000;
    let desc = LatticeDesc::cantilever();
    let (u_cpu, _, strain_cpu) = cpu_substeps(&desc, substeps);
    let scale = u_cpu.iter().flat_map(|u| u.iter()).fold(0f32, |m, x| m.max(x.abs()));
    assert!(scale > 0.01, "the lattice moved: {scale}");
    for gpu in gpus() {
        let lattice = Lattice::new(&gpu, desc.clone());
        let mut encoder = gpu.device.create_command_encoder(&Default::default());
        lattice.record(&mut encoder, substeps);
        gpu.queue.submit([encoder.finish()]);
        let u: Vec<[f32; 4]> = gpu.read(&lattice.displacement);
        let strain: Vec<f32> = gpu.read(&lattice.strain);
        let worst = (0..desc.count()).flat_map(|i| (0..3).map(move |d| (i, d))).map(|(i, d)| (u[i][d] - u_cpu[i][d]).abs()).fold(0f32, f32::max);
        let worst_strain = (0..desc.count()).map(|i| (strain[i] - strain_cpu[i]).abs()).fold(0f32, f32::max);
        eprintln!("{:?}: max |u_gpu - u_cpu| = {worst:e} m of {scale} m; strain {worst_strain:e}", gpu.shader_path);
        assert!(worst <= 1e-4 * scale, "{:?}: displacement differs by {worst}", gpu.shader_path);
        assert!(worst_strain <= 1e-4 * strain_cpu.iter().fold(0f32, |m, &x| m.max(x)), "{:?}: strain differs by {worst_strain}", gpu.shader_path);
    }
}
