struct Camera {
    view_proj: mat4x4<f32>,
};

@group(0) @binding(0)
var<uniform> camera: Camera;

struct VertexInput {
    @location(0) position: vec3<f32>,
    @location(1) normal: vec3<f32>,
    @location(2) model_0: vec4<f32>,
    @location(3) model_1: vec4<f32>,
    @location(4) model_2: vec4<f32>,
    @location(5) model_3: vec4<f32>,
    @location(6) color: vec4<f32>,
};

struct VertexOutput {
    @builtin(position) clip_position: vec4<f32>,
    @location(0) world_normal: vec3<f32>,
    @location(1) color: vec4<f32>,
    @location(2) world_position: vec3<f32>,
};

@vertex
fn vs_main(input: VertexInput) -> VertexOutput {
    let model = mat4x4<f32>(
        input.model_0,
        input.model_1,
        input.model_2,
        input.model_3,
    );
    let world_position = model * vec4<f32>(input.position, 1.0);

    var output: VertexOutput;
    output.clip_position = camera.view_proj * world_position;
    output.world_normal = normalize((model * vec4<f32>(input.normal, 0.0)).xyz);
    output.color = input.color;
    output.world_position = world_position.xyz;
    return output;
}

@fragment
fn fs_main(input: VertexOutput) -> @location(0) vec4<f32> {
    let light_direction = normalize(vec3<f32>(0.35, 0.8, 0.45));
    let diffuse = max(dot(normalize(input.world_normal), light_direction), 0.0);
    let lighting = 0.28 + 0.72 * diffuse;
    if input.color.a < 0.0 {
        // Anti-aliased one-metre reference grid on the explicitly requested
        // render surface. This does not add any collision geometry.
        let p = input.world_position.xz;
        let derivative = max(fwidth(p), vec2<f32>(0.0001));
        let grid = abs(fract(p - 0.5) - 0.5) / derivative;
        let line = 1.0 - min(min(grid.x, grid.y), 1.0);
        return vec4<f32>(mix(input.color.rgb, input.color.rgb * 1.45, line), 1.0);
    }
    return vec4<f32>(input.color.rgb * lighting, 1.0);
}
