struct StepParams_std140_0
{
    @align(16) chunk_count_0 : u32,
    @align(4) bond_count_0 : u32,
    @align(8) dt_0 : f32,
    @align(4) pad_0 : u32,
};

@binding(0) @group(0) var<uniform> params_0 : StepParams_std140_0;
struct Bond_std430_0
{
    @align(16) chunks_0 : vec4<u32>,
    @align(16) t1_0 : vec4<f32>,
    @align(16) t2_0 : vec4<f32>,
    @align(16) normal_0 : vec4<f32>,
    @align(16) ra_0 : vec4<f32>,
    @align(16) rb_0 : vec4<f32>,
    @align(16) k_lin_0 : vec4<f32>,
    @align(16) k_ang_0 : vec4<f32>,
    @align(16) c_lin_0 : vec4<f32>,
    @align(16) c_ang_0 : vec4<f32>,
    @align(16) section_0 : vec4<f32>,
};

@binding(1) @group(0) var<storage, read> bonds_0 : array<Bond_std430_0>;

@binding(5) @group(0) var<storage, read_write> state_0 : array<vec4<f32>>;

@binding(6) @group(0) var<storage, read_write> bond_loads_0 : array<vec4<f32>>;

struct Chunk_std430_0
{
    @align(16) inv_inertia0_0 : vec4<f32>,
    @align(16) inv_inertia1_0 : vec4<f32>,
    @align(16) inv_inertia2_0 : vec4<f32>,
    @align(16) force_0 : vec4<f32>,
    @align(16) moment_0 : vec4<f32>,
    @align(16) support_0 : vec4<u32>,
};

@binding(2) @group(0) var<storage, read> chunks_1 : array<Chunk_std430_0>;

@binding(3) @group(0) var<storage, read> chunk_bond_start_0 : array<u32>;

@binding(4) @group(0) var<storage, read> chunk_bonds_0 : array<u32>;

fn get_0( chunk_0 : u32,  field_0 : u32) -> vec3<f32>
{
    return state_0[u32(4) * chunk_0 + field_0].xyz;
}

fn to_local_0( _S1 : u32,  _S2 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S2, bonds_0[_S1].t1_0.xyz), dot(_S2, bonds_0[_S1].t2_0.xyz), dot(_S2, bonds_0[_S1].normal_0.xyz));
}

fn to_body_0( _S3 : u32,  _S4 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S3].t1_0.xyz * vec3<f32>(_S4.x) + bonds_0[_S3].t2_0.xyz * vec3<f32>(_S4.y) + bonds_0[_S3].normal_0.xyz * vec3<f32>(_S4.z);
}

@compute
@workgroup_size(64, 1, 1)
fn bond_forces(@builtin(global_invocation_id) id_0 : vec3<u32>)
{
    var i_0 : u32 = id_0.x;
    if(i_0 >= (params_0.bond_count_0))
    {
        return;
    }
    var ca_0 : u32 = bonds_0[i_0].chunks_0.x;
    var cb_0 : u32 = bonds_0[i_0].chunks_0.y;
    var ra_1 : vec3<f32> = bonds_0[i_0].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_0].rb_0.xyz;
    var _S5 : vec3<f32> = bonds_0[i_0].k_lin_0.xyz * to_local_0(i_0, get_0(cb_0, u32(0)) + cross(get_0(cb_0, u32(1)), rb_1) - (get_0(ca_0, u32(0)) + cross(get_0(ca_0, u32(1)), ra_1)));
    var _S6 : vec3<f32> = bonds_0[i_0].k_ang_0.xyz * to_local_0(i_0, get_0(cb_0, u32(1)) - get_0(ca_0, u32(1)));
    var _S7 : vec3<f32> = to_body_0(i_0, _S5 + bonds_0[i_0].c_lin_0.xyz * to_local_0(i_0, get_0(cb_0, u32(2)) + cross(get_0(cb_0, u32(3)), rb_1) - (get_0(ca_0, u32(2)) + cross(get_0(ca_0, u32(3)), ra_1))));
    var _S8 : vec3<f32> = to_body_0(i_0, _S6 + bonds_0[i_0].c_ang_0.xyz * to_local_0(i_0, get_0(cb_0, u32(3)) - get_0(ca_0, u32(3))));
    var _S9 : u32 = u32(4) * i_0;
    bond_loads_0[_S9] = vec4<f32>(_S7, abs(_S5.z) / bonds_0[i_0].section_0.x + abs(_S6.x) / bonds_0[i_0].section_0.y + abs(_S6.y) / bonds_0[i_0].section_0.z);
    bond_loads_0[_S9 + u32(1)] = vec4<f32>(_S8 + cross(ra_1, _S7), 0.0f);
    var _S10 : vec3<f32> = (vec3<f32>(0) - _S7);
    bond_loads_0[_S9 + u32(2)] = vec4<f32>(_S10, 0.0f);
    bond_loads_0[_S9 + u32(3)] = vec4<f32>((vec3<f32>(0) - _S8) + cross(rb_1, _S10), 0.0f);
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn chunk_integrate(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var c_0 : u32 = id_1.x;
    if(c_0 >= (params_0.chunk_count_0))
    {
        return;
    }
    var ch_0 : Chunk_std430_0 = chunks_1[c_0];
    var _S11 : vec3<f32> = vec3<f32>(0.0f);
    var _S12 : u32 = chunk_bond_start_0[c_0];
    var stress_0 : f32 = 0.0f;
    var k_0 : u32 = _S12;
    var fi_0 : vec3<f32> = _S11;
    var mi_0 : vec3<f32> = _S11;
    loop
    {
        if(k_0 < chunk_bond_start_0[c_0 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var e_0 : u32 = chunk_bonds_0[k_0];
        var _S13 : u32 = u32(4) * ((e_0 >> (u32(1))));
        var _S14 : u32 = _S13 + u32(2) * ((e_0 & (u32(1))));
        var fi_1 : vec3<f32> = fi_0 + bond_loads_0[_S14].xyz;
        var mi_1 : vec3<f32> = mi_0 + bond_loads_0[_S14 + u32(1)].xyz;
        var _S15 : f32 = max(stress_0, bond_loads_0[_S13].w);
        var _S16 : u32 = k_0 + u32(1);
        stress_0 = _S15;
        k_0 = _S16;
        fi_0 = fi_1;
        mi_0 = mi_1;
    }
    var f_0 : vec3<f32> = ch_0.force_0.xyz + fi_0;
    var m_0 : vec3<f32> = ch_0.moment_0.xyz + mi_0;
    var dt_1 : f32 = params_0.dt_0;
    var alpha_0 : vec3<f32> = vec3<f32>(dot(ch_0.inv_inertia0_0.xyz, m_0), dot(ch_0.inv_inertia1_0.xyz, m_0), dot(ch_0.inv_inertia2_0.xyz, m_0)) * vec3<f32>(ch_0.moment_0.w);
    var uc_0 : vec3<f32> = get_0(c_0, u32(0));
    var tc_0 : vec3<f32> = get_0(c_0, u32(1));
    var vc_0 : vec3<f32> = get_0(c_0, u32(2));
    var wc_0 : vec3<f32> = get_0(c_0, u32(3));
    var support_1 : u32 = ch_0.support_0.x;
    var uc_1 : vec3<f32>;
    var tc_1 : vec3<f32>;
    var vc_1 : vec3<f32>;
    var wc_1 : vec3<f32>;
    if(support_1 == u32(1))
    {
        uc_1 = uc_0;
        tc_1 = tc_0;
        vc_1 = _S11;
        wc_1 = _S11;
    }
    else
    {
        var _S17 : vec3<f32> = vec3<f32>(dt_1);
        var wc_2 : vec3<f32> = wc_0 + alpha_0 * _S17;
        var tc_2 : vec3<f32> = tc_0 + wc_2 * _S17;
        if(support_1 == u32(2))
        {
            uc_1 = uc_0;
            tc_1 = _S11;
        }
        else
        {
            var vc_2 : vec3<f32> = vc_0 + f_0 * vec3<f32>((dt_1 * ch_0.force_0.w));
            uc_1 = uc_0 + vc_2 * _S17;
            tc_1 = vc_2;
        }
        var _S18 : vec3<f32> = tc_1;
        tc_1 = tc_2;
        vc_1 = _S18;
        wc_1 = wc_2;
    }
    var _S19 : u32 = u32(4) * c_0;
    state_0[_S19] = vec4<f32>(uc_1, stress_0);
    state_0[_S19 + u32(1)] = vec4<f32>(tc_1, 0.0f);
    state_0[_S19 + u32(2)] = vec4<f32>(vc_1, 0.0f);
    state_0[_S19 + u32(3)] = vec4<f32>(wc_1, 0.0f);
    return;
}

