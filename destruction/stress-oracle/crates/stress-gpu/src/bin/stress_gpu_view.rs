//! Native window demo of the end-to-end path: Slang kernels (compiled to a Metal
//! library) step a chunk lattice on the GPU every frame, and Slang vertex/fragment
//! shaders draw it, coloured by strain, in a macOS window through wgpu.
//!
//!   stress-gpu-view                                  interactive (Esc quits)
//!   stress-gpu-view --frames 240 --screenshot f.ppm  capture frame 240 as presented, then exit
//!   STRESS_GPU_SHADERS=wgsl stress-gpu-view          same, through WGSL instead of Metal

use std::sync::Arc;
use std::time::Instant;

use stress_gpu::gpu::{Binding, Gpu};
use stress_gpu::lattice::{Lattice, LatticeDesc};
use stress_gpu::shaders;
use winit::application::ApplicationHandler;
use winit::event::{ElementState, KeyEvent, WindowEvent};
use winit::event_loop::{ActiveEventLoop, EventLoop};
use winit::keyboard::{Key, NamedKey};
use winit::window::{Window, WindowId};

/// Uniforms of `lattice_render.slang` (`Camera`).
#[repr(C)]
#[derive(Clone, Copy, bytemuck::Pod, bytemuck::Zeroable)]
struct Camera {
    view_proj: [[f32; 4]; 4],
    light: [f32; 4],
    half_size: f32,
    exaggerate: f32,
    strain_max: f32,
    pad: f32,
}

/// Simulated seconds per displayed frame, and the cycle after which the lattice restarts.
const FRAME_DT: f32 = 1.0 / 60.0;
const CYCLE: f32 = 6.0;

struct Options {
    frames: Option<u64>,
    screenshot: Option<String>,
}

struct View {
    window: Arc<Window>,
    surface: wgpu::Surface<'static>,
    config: wgpu::SurfaceConfiguration,
    gpu: Gpu,
    lattice: Lattice,
    camera: wgpu::Buffer,
    pipeline: wgpu::RenderPipeline,
    bind: wgpu::BindGroup,
    depth: wgpu::TextureView,
    frame: u64,
    sim_time: f32,
    started: Instant,
}

struct App {
    options: Options,
    view: Option<View>,
}

fn main() {
    let mut options = Options { frames: None, screenshot: None };
    let mut args = std::env::args().skip(1);
    while let Some(a) = args.next() {
        match a.as_str() {
            "--frames" => options.frames = Some(args.next().and_then(|v| v.parse().ok()).expect("--frames N")),
            "--screenshot" => options.screenshot = Some(args.next().expect("--screenshot PATH.ppm")),
            other => panic!("unknown argument {other}"),
        }
    }
    let event_loop = EventLoop::new().expect("event loop");
    let mut app = App { options, view: None };
    event_loop.run_app(&mut app).expect("run");
}

impl ApplicationHandler for App {
    fn resumed(&mut self, event_loop: &ActiveEventLoop) {
        if self.view.is_some() {
            return;
        }
        let attrs = Window::default_attributes().with_title("stress-gpu: Slang -> Metal -> wgpu").with_inner_size(winit::dpi::LogicalSize::new(1100.0, 700.0));
        let window = Arc::new(event_loop.create_window(attrs).expect("window"));
        self.view = Some(View::new(window));
    }

    fn window_event(&mut self, event_loop: &ActiveEventLoop, _id: WindowId, event: WindowEvent) {
        let Some(view) = self.view.as_mut() else { return };
        match event {
            WindowEvent::CloseRequested
            | WindowEvent::KeyboardInput { event: KeyEvent { logical_key: Key::Named(NamedKey::Escape), state: ElementState::Pressed, .. }, .. } => event_loop.exit(),
            WindowEvent::Resized(size) => view.resize(size.width, size.height),
            WindowEvent::RedrawRequested => {
                let capture = self.options.frames == Some(view.frame + 1);
                let shot = if capture { self.options.screenshot.as_deref() } else { None };
                view.draw(shot);
                if capture {
                    event_loop.exit();
                }
            }
            _ => {}
        }
    }

    fn about_to_wait(&mut self, _event_loop: &ActiveEventLoop) {
        if let Some(view) = &self.view {
            view.window.request_redraw();
        }
    }
}

impl View {
    fn new(window: Arc<Window>) -> View {
        let instance = wgpu::Instance::new(wgpu::InstanceDescriptor::new_without_display_handle());
        let surface = instance.create_surface(window.clone()).expect("surface");
        let gpu = pollster::block_on(Gpu::with_instance(&instance, Some(&surface))).expect("GPU");
        let size = window.inner_size();
        let mut config = surface.get_default_config(&gpu.adapter, size.width.max(1), size.height.max(1)).expect("surface config");
        // Readable for screenshots of exactly what is presented.
        if surface.get_capabilities(&gpu.adapter).usages.contains(wgpu::TextureUsages::COPY_SRC) {
            config.usage |= wgpu::TextureUsages::COPY_SRC;
        }
        surface.configure(&gpu.device, &config);
        eprintln!(
            "adapter {} ({:?}); shaders: {:?}; surface {:?} {}x{}",
            gpu.adapter_info.name, gpu.adapter_info.backend, gpu.shader_path, config.format, config.width, config.height
        );

        let lattice = Lattice::new(&gpu, LatticeDesc::cantilever());
        let camera = gpu.uniform("camera", &Camera::zeroed());
        let bindings = [Binding::Uniform, Binding::Storage, Binding::Storage, Binding::Storage];
        let (group, layout) = gpu.layout("lattice render", &bindings, wgpu::ShaderStages::VERTEX | wgpu::ShaderStages::FRAGMENT);
        let module = gpu.module(&shaders::LATTICE_RENDER);
        let pipeline = gpu.device.create_render_pipeline(&wgpu::RenderPipelineDescriptor {
            label: Some("lattice render"),
            layout: Some(&layout),
            vertex: wgpu::VertexState { module: &module, entry_point: Some("lattice_vs"), compilation_options: Default::default(), buffers: &[] },
            primitive: wgpu::PrimitiveState { topology: wgpu::PrimitiveTopology::TriangleList, cull_mode: None, ..Default::default() },
            depth_stencil: Some(wgpu::DepthStencilState {
                format: wgpu::TextureFormat::Depth32Float,
                depth_write_enabled: Some(true),
                depth_compare: Some(wgpu::CompareFunction::Less),
                stencil: Default::default(),
                bias: Default::default(),
            }),
            multisample: Default::default(),
            fragment: Some(wgpu::FragmentState {
                module: &module,
                entry_point: Some("lattice_fs"),
                compilation_options: Default::default(),
                targets: &[Some(config.format.into())],
            }),
            multiview_mask: None,
            cache: None,
        });
        let bind = gpu.bind(&group, &[&camera, &lattice.rest, &lattice.displacement, &lattice.strain]);
        let depth = depth_view(&gpu, config.width, config.height);
        View { window, surface, config, gpu, lattice, camera, pipeline, bind, depth, frame: 0, sim_time: 0.0, started: Instant::now() }
    }

    fn resize(&mut self, width: u32, height: u32) {
        if width == 0 || height == 0 {
            return;
        }
        self.config.width = width;
        self.config.height = height;
        self.surface.configure(&self.gpu.device, &self.config);
        self.depth = depth_view(&self.gpu, width, height);
    }

    fn draw(&mut self, screenshot: Option<&str>) {
        let frame = match self.surface.get_current_texture() {
            wgpu::CurrentSurfaceTexture::Success(t) | wgpu::CurrentSurfaceTexture::Suboptimal(t) => t,
            _ => {
                self.surface.configure(&self.gpu.device, &self.config);
                return;
            }
        };
        if self.sim_time >= CYCLE {
            self.lattice.reset(&self.gpu);
            self.sim_time = 0.0;
        }
        let substeps = (FRAME_DT / self.lattice.desc.params.dt).round() as usize;
        self.sim_time += substeps as f32 * self.lattice.desc.params.dt;
        let aspect = self.config.width as f32 / self.config.height as f32;
        let orbit = self.started.elapsed().as_secs_f32() * 0.15;
        let cam = Camera {
            view_proj: view_projection(orbit, aspect),
            light: [0.4, -0.6, 0.8, 0.0],
            half_size: self.lattice.desc.spacing * 0.45,
            exaggerate: 1.0,
            strain_max: 0.1,
            pad: 0.0,
        };
        self.gpu.queue.write_buffer(&self.camera, 0, bytemuck::bytes_of(&cam));

        let target = frame.texture.create_view(&Default::default());
        let mut encoder = self.gpu.device.create_command_encoder(&Default::default());
        self.lattice.record(&mut encoder, substeps);
        {
            let mut pass = encoder.begin_render_pass(&wgpu::RenderPassDescriptor {
                label: Some("lattice"),
                color_attachments: &[Some(wgpu::RenderPassColorAttachment {
                    view: &target,
                    depth_slice: None,
                    resolve_target: None,
                    ops: wgpu::Operations { load: wgpu::LoadOp::Clear(wgpu::Color { r: 0.05, g: 0.06, b: 0.08, a: 1.0 }), store: wgpu::StoreOp::Store },
                })],
                depth_stencil_attachment: Some(wgpu::RenderPassDepthStencilAttachment {
                    view: &self.depth,
                    depth_ops: Some(wgpu::Operations { load: wgpu::LoadOp::Clear(1.0), store: wgpu::StoreOp::Discard }),
                    stencil_ops: None,
                }),
                timestamp_writes: None,
                occlusion_query_set: None,
                multiview_mask: None,
            });
            pass.set_pipeline(&self.pipeline);
            pass.set_bind_group(0, &self.bind, &[]);
            pass.draw(0..36, 0..self.lattice.desc.count() as u32);
        }
        let readback = screenshot.map(|_| copy_to_buffer(&self.gpu, &mut encoder, &frame.texture));
        self.gpu.queue.submit([encoder.finish()]);
        if let (Some(path), Some((buffer, row))) = (screenshot, readback) {
            save_ppm(&self.gpu, &buffer, row, self.config.width, self.config.height, self.config.format, path);
            eprintln!("frame {} (t = {:.2} s simulated): wrote {path}", self.frame + 1, self.sim_time);
        }
        self.window.pre_present_notify();
        frame.present();
        self.frame += 1;
        if self.frame % 120 == 0 {
            let fps = self.frame as f64 / self.started.elapsed().as_secs_f64();
            self.window.set_title(&format!("stress-gpu: Slang -> {:?} -> wgpu | {} chunks, {substeps} substeps/frame, {fps:.0} fps", self.gpu.shader_path, self.lattice.desc.count()));
        }
    }
}

fn depth_view(gpu: &Gpu, width: u32, height: u32) -> wgpu::TextureView {
    gpu.device
        .create_texture(&wgpu::TextureDescriptor {
            label: Some("depth"),
            size: wgpu::Extent3d { width, height, depth_or_array_layers: 1 },
            mip_level_count: 1,
            sample_count: 1,
            dimension: wgpu::TextureDimension::D2,
            format: wgpu::TextureFormat::Depth32Float,
            usage: wgpu::TextureUsages::RENDER_ATTACHMENT,
            view_formats: &[],
        })
        .create_view(&Default::default())
}

/// Column-major view-projection (depth 0..1), orbiting the cantilever (z up).
fn view_projection(orbit: f32, aspect: f32) -> [[f32; 4]; 4] {
    let target = [5.75f32, 0.0, -0.6];
    let (r, h) = (13.0f32, 4.5f32);
    let eye = [target[0] + r * (orbit - 1.2).cos(), target[1] + r * (orbit - 1.2).sin(), target[2] + h];
    let sub = |a: [f32; 3], b: [f32; 3]| [a[0] - b[0], a[1] - b[1], a[2] - b[2]];
    let dot = |a: [f32; 3], b: [f32; 3]| a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
    let cross = |a: [f32; 3], b: [f32; 3]| [a[1] * b[2] - a[2] * b[1], a[2] * b[0] - a[0] * b[2], a[0] * b[1] - a[1] * b[0]];
    let norm = |a: [f32; 3]| {
        let l = dot(a, a).sqrt();
        [a[0] / l, a[1] / l, a[2] / l]
    };
    let f = norm(sub(target, eye));
    let s = norm(cross(f, [0.0, 0.0, 1.0]));
    let u = cross(s, f);
    // View rows: s, u, -f; translation -R eye.
    let view = [[s[0], u[0], -f[0], 0.0], [s[1], u[1], -f[1], 0.0], [s[2], u[2], -f[2], 0.0], [-dot(s, eye), -dot(u, eye), dot(f, eye), 1.0]];
    let (near, far) = (0.1f32, 100.0f32);
    let t = 1.0 / (40f32.to_radians() / 2.0).tan();
    let proj = [[t / aspect, 0.0, 0.0, 0.0], [0.0, t, 0.0, 0.0], [0.0, 0.0, far / (near - far), -1.0], [0.0, 0.0, near * far / (near - far), 0.0]];
    // proj * view, column-major.
    std::array::from_fn(|c| std::array::from_fn(|r| (0..4).map(|k| proj[k][r] * view[c][k]).sum()))
}

fn copy_to_buffer(gpu: &Gpu, encoder: &mut wgpu::CommandEncoder, texture: &wgpu::Texture) -> (wgpu::Buffer, u32) {
    let (w, h) = (texture.width(), texture.height());
    let row = (w * 4).div_ceil(256) * 256;
    let buffer = gpu.device.create_buffer(&wgpu::BufferDescriptor {
        label: Some("screenshot"),
        size: (row * h) as u64,
        usage: wgpu::BufferUsages::COPY_DST | wgpu::BufferUsages::MAP_READ,
        mapped_at_creation: false,
    });
    encoder.copy_texture_to_buffer(
        texture.as_image_copy(),
        wgpu::TexelCopyBufferInfo { buffer: &buffer, layout: wgpu::TexelCopyBufferLayout { offset: 0, bytes_per_row: Some(row), rows_per_image: Some(h) } },
        wgpu::Extent3d { width: w, height: h, depth_or_array_layers: 1 },
    );
    (buffer, row)
}

fn save_ppm(gpu: &Gpu, buffer: &wgpu::Buffer, row: u32, w: u32, h: u32, format: wgpu::TextureFormat, path: &str) {
    buffer.map_async(wgpu::MapMode::Read, .., |r| r.expect("map screenshot"));
    gpu.device.poll(wgpu::PollType::wait_indefinitely()).expect("poll");
    let data = buffer.get_mapped_range(..).expect("mapped screenshot");
    let bgra = matches!(format, wgpu::TextureFormat::Bgra8Unorm | wgpu::TextureFormat::Bgra8UnormSrgb);
    let mut out = format!("P6\n{w} {h}\n255\n").into_bytes();
    for y in 0..h {
        for x in 0..w {
            let p = &data[(y * row + x * 4) as usize..][..4];
            out.extend_from_slice(&if bgra { [p[2], p[1], p[0]] } else { [p[0], p[1], p[2]] });
        }
    }
    std::fs::write(path, out).expect("write screenshot");
}
