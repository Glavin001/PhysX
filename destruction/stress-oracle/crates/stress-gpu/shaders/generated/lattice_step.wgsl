struct StepParams_std140_0
{
    @align(16) count_0 : u32,
    @align(4) dt_0 : f32,
    @align(8) stiffness_0 : f32,
    @align(4) damping_0 : f32,
    @align(16) gravity_0 : vec4<f32>,
    @align(16) spacing_0 : f32,
    @align(4) pad0_0 : u32,
    @align(8) pad1_0 : u32,
    @align(4) pad2_0 : u32,
};

@binding(0) @group(0) var<uniform> params_0 : StepParams_std140_0;
@binding(4) @group(0) var<storage, read_write> displacement_0 : array<vec4<f32>>;

@binding(1) @group(0) var<storage, read> adjacency_start_0 : array<u32>;

@binding(2) @group(0) var<storage, read> adjacency_0 : array<u32>;

@binding(6) @group(0) var<storage, read_write> strain_0 : array<f32>;

@binding(3) @group(0) var<storage, read> fixed_0 : array<u32>;

@binding(5) @group(0) var<storage, read_write> velocity_0 : array<vec4<f32>>;

@compute
@workgroup_size(64, 1, 1)
fn lattice_forces(@builtin(global_invocation_id) id_0 : vec3<u32>)
{
    var i_0 : u32 = id_0.x;
    if(i_0 >= (params_0.count_0))
    {
        return;
    }
    var _S1 : vec3<f32> = displacement_0[i_0].xyz;
    var _S2 : vec3<f32> = vec3<f32>(0.0f);
    var _S3 : u32 = adjacency_start_0[i_0];
    var largest_0 : f32 = 0.0f;
    var k_0 : u32 = _S3;
    var force_0 : vec3<f32> = _S2;
    loop
    {
        if(k_0 < adjacency_start_0[i_0 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var stretch_0 : vec3<f32> = displacement_0[adjacency_0[k_0]].xyz - _S1;
        var force_1 : vec3<f32> = force_0 + stretch_0 * vec3<f32>(params_0.stiffness_0);
        var _S4 : f32 = max(largest_0, length(stretch_0) / params_0.spacing_0);
        var _S5 : u32 = k_0 + u32(1);
        largest_0 = _S4;
        k_0 = _S5;
        force_0 = force_1;
    }
    strain_0[i_0] = largest_0;
    if(fixed_0[i_0] != u32(0))
    {
        velocity_0[i_0] = vec4<f32>(0.0f);
        return;
    }
    var v_0 : vec3<f32> = velocity_0[i_0].xyz;
    velocity_0[i_0] = vec4<f32>(v_0 + (force_0 + params_0.gravity_0.xyz - v_0 * vec3<f32>(params_0.damping_0)) * vec3<f32>(params_0.dt_0), 0.0f);
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn lattice_positions(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var i_1 : u32 = id_1.x;
    if(i_1 >= (params_0.count_0))
    {
        return;
    }
    displacement_0[i_1] = vec4<f32>(displacement_0[i_1].xyz + velocity_0[i_1].xyz * vec3<f32>(params_0.dt_0), 0.0f);
    return;
}

