//! End-to-end demo: a chunk lattice (a cantilever of chunks joined by linear springs)
//! stepped by Slang compute kernels and drawn by Slang vertex/fragment shaders. It
//! proves the toolchain (Slang -> Metal library -> wgpu -> window) and carries the
//! patterns the stress solver builds on: CSR gathers, batched substeps in one submission.

use crate::gpu::{Binding, Gpu, Kernel};
use crate::shaders;

/// Uniforms of `lattice_step.slang` (`StepParams`).
#[repr(C)]
#[derive(Clone, Copy, Debug, bytemuck::Pod, bytemuck::Zeroable)]
pub struct StepParams {
    pub count: u32,
    pub dt: f32,
    pub stiffness: f32,
    pub damping: f32,
    pub gravity: [f32; 4],
    pub spacing: f32,
    pub pad: [u32; 3],
}

/// A box of `n[0] x n[1] x n[2]` chunks at `spacing`, 6-connected, its `x = 0` face fixed.
#[derive(Clone, Debug)]
pub struct LatticeDesc {
    pub n: [usize; 3],
    pub spacing: f32,
    pub params: StepParams,
}

impl LatticeDesc {
    /// A cantilever that sags visibly under gravity (tip deflection ~ g L^2 / 2k).
    pub fn cantilever() -> LatticeDesc {
        let n = [24, 4, 4];
        let spacing = 0.5;
        LatticeDesc {
            n,
            spacing,
            params: StepParams {
                count: (n[0] * n[1] * n[2]) as u32,
                dt: 1e-3,
                stiffness: 5000.0,
                damping: 1.5,
                gravity: [0.0, 0.0, -9.81, 0.0],
                spacing,
                pad: [0; 3],
            },
        }
    }

    pub fn count(&self) -> usize {
        self.n[0] * self.n[1] * self.n[2]
    }

    fn index(&self, i: usize, j: usize, k: usize) -> usize {
        (i * self.n[1] + j) * self.n[2] + k
    }

    /// Rest positions (centred on y and z, the fixed face at x = 0).
    pub fn rest(&self) -> Vec<[f32; 4]> {
        let mut out = vec![[0.0; 4]; self.count()];
        for i in 0..self.n[0] {
            for j in 0..self.n[1] {
                for k in 0..self.n[2] {
                    let s = self.spacing;
                    out[self.index(i, j, k)] =
                        [i as f32 * s, (j as f32 - (self.n[1] - 1) as f32 / 2.0) * s, (k as f32 - (self.n[2] - 1) as f32 / 2.0) * s, 0.0];
                }
            }
        }
        out
    }

    /// CSR adjacency: (start offsets, neighbour indices), neighbours in -x,+x,-y,+y,-z,+z order.
    pub fn adjacency(&self) -> (Vec<u32>, Vec<u32>) {
        let mut start = vec![0u32];
        let mut list = Vec::new();
        for i in 0..self.n[0] {
            for j in 0..self.n[1] {
                for k in 0..self.n[2] {
                    let (i, j, k) = (i as isize, j as isize, k as isize);
                    for (di, dj, dk) in [(-1, 0, 0), (1, 0, 0), (0, -1, 0), (0, 1, 0), (0, 0, -1), (0, 0, 1)] {
                        let (a, b, c) = (i + di, j + dj, k + dk);
                        if a >= 0 && b >= 0 && c >= 0 && (a as usize) < self.n[0] && (b as usize) < self.n[1] && (c as usize) < self.n[2] {
                            list.push(self.index(a as usize, b as usize, c as usize) as u32);
                        }
                    }
                    start.push(list.len() as u32);
                }
            }
        }
        (start, list)
    }

    pub fn fixed(&self) -> Vec<u32> {
        (0..self.count()).map(|c| u32::from(c / (self.n[1] * self.n[2]) == 0)).collect()
    }
}

/// The lattice's GPU state and its two substep kernels.
pub struct Lattice {
    pub desc: LatticeDesc,
    pub params: wgpu::Buffer,
    pub rest: wgpu::Buffer,
    pub displacement: wgpu::Buffer,
    pub velocity: wgpu::Buffer,
    pub strain: wgpu::Buffer,
    forces: Kernel,
    positions: Kernel,
    bind_forces: wgpu::BindGroup,
    bind_positions: wgpu::BindGroup,
}

const STEP_BINDINGS: [Binding; 7] =
    [Binding::Uniform, Binding::Storage, Binding::Storage, Binding::Storage, Binding::StorageRw, Binding::StorageRw, Binding::StorageRw];

impl Lattice {
    pub fn new(gpu: &Gpu, desc: LatticeDesc) -> Lattice {
        let n = desc.count();
        let (start, list) = desc.adjacency();
        let params = gpu.uniform("step params", &desc.params);
        let start = gpu.storage("adjacency start", &start);
        let list = gpu.storage("adjacency", &list);
        let fixed = gpu.storage("fixed", &desc.fixed());
        let rest = gpu.storage("rest", &desc.rest());
        let displacement = gpu.storage("displacement", &vec![[0f32; 4]; n]);
        let velocity = gpu.storage("velocity", &vec![[0f32; 4]; n]);
        let strain = gpu.storage("strain", &vec![0f32; n]);
        // Both entry points share one module and the same binding list.
        let forces = gpu.compute(&shaders::LATTICE_STEP, "lattice_forces", &STEP_BINDINGS);
        let positions = gpu.compute(&shaders::LATTICE_STEP, "lattice_positions", &STEP_BINDINGS);
        let buffers = [&params, &start, &list, &fixed, &displacement, &velocity, &strain];
        let bind_forces = gpu.bind(&forces.group, &buffers);
        let bind_positions = gpu.bind(&positions.group, &buffers);
        Lattice { desc, params, rest, displacement, velocity, strain, forces, positions, bind_forces, bind_positions }
    }

    /// Record `substeps` substeps (two dispatches each) into one compute pass.
    pub fn record(&self, encoder: &mut wgpu::CommandEncoder, substeps: usize) {
        let mut pass = encoder.begin_compute_pass(&wgpu::ComputePassDescriptor { label: Some("lattice substeps"), timestamp_writes: None });
        let n = self.desc.count();
        for _ in 0..substeps {
            self.forces.dispatch(&mut pass, &self.bind_forces, n);
            self.positions.dispatch(&mut pass, &self.bind_positions, n);
        }
    }

    /// Back to rest.
    pub fn reset(&self, gpu: &Gpu) {
        let zero = vec![0u8; self.displacement.size() as usize];
        gpu.queue.write_buffer(&self.displacement, 0, &zero);
        gpu.queue.write_buffer(&self.velocity, 0, &zero);
    }
}

/// The same substep on the CPU in f32, operation for operation, to check the kernels.
pub fn cpu_substeps(desc: &LatticeDesc, substeps: usize) -> (Vec<[f32; 3]>, Vec<[f32; 3]>, Vec<f32>) {
    let n = desc.count();
    let (start, list) = desc.adjacency();
    let fixed = desc.fixed();
    let p = desc.params;
    let mut u = vec![[0f32; 3]; n];
    let mut v = vec![[0f32; 3]; n];
    let mut strain = vec![0f32; n];
    for _ in 0..substeps {
        for i in 0..n {
            let mut f = [0f32; 3];
            let mut largest = 0f32;
            for &nb in &list[start[i] as usize..start[i + 1] as usize] {
                let s: [f32; 3] = std::array::from_fn(|d| u[nb as usize][d] - u[i][d]);
                for d in 0..3 {
                    f[d] += s[d] * p.stiffness;
                }
                largest = largest.max((s[0] * s[0] + s[1] * s[1] + s[2] * s[2]).sqrt() / p.spacing);
            }
            strain[i] = largest;
            if fixed[i] != 0 {
                v[i] = [0.0; 3];
            } else {
                for d in 0..3 {
                    v[i][d] += (f[d] + p.gravity[d] - v[i][d] * p.damping) * p.dt;
                }
            }
        }
        for i in 0..n {
            for d in 0..3 {
                u[i][d] += v[i][d] * p.dt;
            }
        }
    }
    (u, v, strain)
}
