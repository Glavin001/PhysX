@binding(1) @group(0) var<storage, read> rest_0 : array<vec4<f32>>;

@binding(2) @group(0) var<storage, read> displacement_0 : array<vec4<f32>>;

struct Camera_std140_0
{
    @align(16) view_proj_0 : array<vec4<f32>, i32(4)>,
    @align(16) light_0 : vec4<f32>,
    @align(16) half_size_0 : f32,
    @align(4) exaggerate_0 : f32,
    @align(8) strain_max_0 : f32,
    @align(4) pad_0 : f32,
};

@binding(0) @group(0) var<uniform> camera_0 : Camera_std140_0;
@binding(3) @group(0) var<storage, read> strain_0 : array<f32>;

fn ramp_0( t_0 : f32) -> vec3<f32>
{
    const c0_0 : vec3<f32> = vec3<f32>(0.15000000596046448f, 0.25f, 0.85000002384185791f);
    const c1_0 : vec3<f32> = vec3<f32>(0.10000000149011612f, 0.75f, 0.85000002384185791f);
    const c2_0 : vec3<f32> = vec3<f32>(0.25f, 0.80000001192092896f, 0.30000001192092896f);
    const c3_0 : vec3<f32> = vec3<f32>(0.94999998807907104f, 0.85000002384185791f, 0.20000000298023224f);
    const c4_0 : vec3<f32> = vec3<f32>(0.89999997615814209f, 0.20000000298023224f, 0.15000000596046448f);
    var s_0 : f32 = saturate(t_0) * 4.0f;
    if(s_0 < 1.0f)
    {
        return mix(c0_0, c1_0, vec3<f32>(s_0));
    }
    if(s_0 < 2.0f)
    {
        return mix(c1_0, c2_0, vec3<f32>((s_0 - 1.0f)));
    }
    if(s_0 < 3.0f)
    {
        return mix(c2_0, c3_0, vec3<f32>((s_0 - 2.0f)));
    }
    return mix(c3_0, c4_0, vec3<f32>((s_0 - 3.0f)));
}

struct VertexOut_0
{
    @builtin(position) position_0 : vec4<f32>,
    @location(0) normal_0 : vec3<f32>,
    @location(1) color_0 : vec3<f32>,
};

@vertex
fn lattice_vs(@builtin(vertex_index) vertex_0 : u32, @builtin(instance_index) instance_0 : u32) -> VertexOut_0
{
    var face_0 : u32 = vertex_0 / u32(6);
    var corner_0 : u32 = vertex_0 % u32(6);
    var axis_0 : u32 = face_0 / u32(2);
    var sign_0 : f32;
    if((face_0 % u32(2)) == u32(0))
    {
        sign_0 = 1.0f;
    }
    else
    {
        sign_0 = -1.0f;
    }
    const _S1 : vec2<f32> = vec2<f32>(-1.0f, -1.0f);
    const _S2 : vec2<f32> = vec2<f32>(1.0f, 1.0f);
    var quad_0 : array<vec2<f32>, i32(6)> = array<vec2<f32>, i32(6)>( _S1, vec2<f32>(1.0f, -1.0f), _S2, _S1, _S2, vec2<f32>(-1.0f, 1.0f) );
    var st_0 : vec2<f32> = quad_0[corner_0];
    if(sign_0 < 0.0f)
    {
        st_0[i32(0)] = - st_0.x;
    }
    var p_0 : vec3<f32>;
    var n_0 : vec3<f32>;
    if(axis_0 == u32(0))
    {
        var _S3 : vec3<f32> = vec3<f32>(sign_0, 0.0f, 0.0f);
        p_0 = vec3<f32>(sign_0, st_0.x, st_0.y);
        n_0 = _S3;
    }
    else
    {
        if(axis_0 == u32(1))
        {
            var _S4 : vec3<f32> = vec3<f32>(0.0f, sign_0, 0.0f);
            p_0 = vec3<f32>(st_0.y, sign_0, st_0.x);
            n_0 = _S4;
        }
        else
        {
            var _S5 : vec3<f32> = vec3<f32>(0.0f, 0.0f, sign_0);
            p_0 = vec3<f32>(st_0.x, st_0.y, sign_0);
            n_0 = _S5;
        }
    }
    var world_0 : vec3<f32> = rest_0[instance_0].xyz + displacement_0[instance_0].xyz * vec3<f32>(camera_0.exaggerate_0) + p_0 * vec3<f32>(camera_0.half_size_0);
    var o_0 : VertexOut_0;
    o_0.position_0 = camera_0.view_proj_0[i32(0)] * vec4<f32>(world_0.x) + camera_0.view_proj_0[i32(1)] * vec4<f32>(world_0.y) + camera_0.view_proj_0[i32(2)] * vec4<f32>(world_0.z) + camera_0.view_proj_0[i32(3)];
    o_0.normal_0 = n_0;
    o_0.color_0 = ramp_0(strain_0[instance_0] / camera_0.strain_max_0);
    return o_0;
}

struct pixelOutput_0
{
    @location(0) output_0 : vec4<f32>,
};

struct pixelInput_0
{
    @location(0) normal_1 : vec3<f32>,
    @location(1) color_1 : vec3<f32>,
};

@fragment
fn lattice_fs( _S6 : pixelInput_0, @builtin(position) position_1 : vec4<f32>) -> pixelOutput_0
{
    var _S7 : pixelOutput_0 = pixelOutput_0( vec4<f32>(_S6.color_1 * vec3<f32>((0.34999999403953552f + 0.64999997615814209f * max(dot(normalize(_S6.normal_1), normalize(camera_0.light_0.xyz)), 0.0f))), 1.0f) );
    return _S7;
}

