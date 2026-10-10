struct ContactParams_std140_0
{
    @align(16) gravity_0 : vec4<f32>,
    @align(16) dt_0 : f32,
    @align(4) zeta_0 : f32,
    @align(8) pair_friction_0 : f32,
    @align(4) halt_index_0 : u32,
    @align(16) ground_hi_0 : f32,
    @align(4) ground_lo_0 : f32,
    @align(8) ground_friction_0 : f32,
    @align(4) ground_modulus_0 : f32,
    @align(16) has_ground_0 : u32,
    @align(4) pair_count_0 : u32,
    @align(8) impactor_count_0 : u32,
    @align(4) chunk_count_0 : u32,
    @align(16) loads_base_0 : u32,
    @align(4) ledger_base_0 : u32,
    @align(8) step_start_0 : u32,
    @align(4) record_stride_0 : u32,
    @align(16) cand_begin_0 : u32,
    @align(4) cand_count_0 : u32,
    @align(8) cand_base_0 : u32,
    @align(4) pad0_0 : u32,
};

@binding(0) @group(0) var<uniform> params_0 : ContactParams_std140_0;
struct Island_std430_0
{
    @align(16) range_0 : vec4<u32>,
    @align(16) info_0 : vec4<u32>,
    @align(16) com_0 : vec4<f32>,
    @align(16) inertia0_0 : vec4<f32>,
    @align(16) inertia1_0 : vec4<f32>,
    @align(16) inertia2_0 : vec4<f32>,
    @align(16) inv0_0 : vec4<f32>,
    @align(16) inv1_0 : vec4<f32>,
    @align(16) inv2_0 : vec4<f32>,
    @align(16) wcom_0 : vec4<f32>,
    @align(16) winv0_0 : vec4<f32>,
    @align(16) winv1_0 : vec4<f32>,
    @align(16) winv2_0 : vec4<f32>,
    @align(16) rotation_0 : vec4<f32>,
    @align(16) position_0 : vec4<f32>,
    @align(16) position_err_0 : vec4<f32>,
    @align(16) velocity_0 : vec4<f32>,
    @align(16) velocity_err_0 : vec4<f32>,
    @align(16) angular_velocity_0 : vec4<f32>,
    @align(16) done_0 : vec4<u32>,
    @align(16) probes_0 : vec4<u32>,
    @align(16) energy_0 : vec4<f32>,
};

@binding(4) @group(0) var<storage, read_write> islands_0 : array<Island_std430_0>;

@binding(5) @group(0) var<storage, read> contact_static_0 : array<vec4<u32>>;

struct ChunkStatic_std430_0
{
    @align(16) center_0 : vec4<f32>,
    @align(16) inertia0_1 : vec4<f32>,
    @align(16) inertia1_1 : vec4<f32>,
    @align(16) inertia2_1 : vec4<f32>,
    @align(16) inv0_1 : vec4<f32>,
    @align(16) inv1_1 : vec4<f32>,
    @align(16) inv2_1 : vec4<f32>,
    @align(16) scale_0 : vec4<f32>,
    @align(16) info_1 : vec4<u32>,
    @align(16) load_range_0 : vec4<u32>,
};

@binding(1) @group(0) var<storage, read> chunks_0 : array<ChunkStatic_std430_0>;

@binding(3) @group(0) var<storage, read> state_0 : array<vec4<f32>>;

struct ContactChunk_std430_0
{
    @align(16) half_0 : vec4<f32>,
    @align(16) rot0_0 : vec4<f32>,
    @align(16) rot1_0 : vec4<f32>,
    @align(16) rot2_0 : vec4<f32>,
    @align(16) mat_0 : vec4<f32>,
    @align(16) start_hi_0 : vec4<f32>,
    @align(16) start_lo_0 : vec4<f32>,
    @align(16) info_2 : vec4<u32>,
};

@binding(2) @group(0) var<storage, read> contact_chunks_0 : array<ContactChunk_std430_0>;

@binding(8) @group(0) var<storage, read_write> contact_out_0 : array<vec4<f32>>;

@binding(6) @group(0) var<storage, read_write> contact_state_0 : array<vec4<f32>>;

struct Impactor_std430_0
{
    @align(16) position_1 : vec4<f32>,
    @align(16) position_err_1 : vec4<f32>,
    @align(16) velocity_1 : vec4<f32>,
    @align(16) velocity_err_1 : vec4<f32>,
    @align(16) angular_velocity_1 : vec4<f32>,
    @align(16) rotation_1 : vec4<f32>,
    @align(16) inertia0_2 : vec4<f32>,
    @align(16) inertia1_2 : vec4<f32>,
    @align(16) inertia2_2 : vec4<f32>,
    @align(16) inv0_2 : vec4<f32>,
    @align(16) inv1_2 : vec4<f32>,
    @align(16) inv2_2 : vec4<f32>,
    @align(16) shape_0 : vec4<f32>,
    @align(16) half_1 : vec4<f32>,
    @align(16) mat_1 : vec4<f32>,
    @align(16) crush_0 : vec4<f32>,
    @align(16) load_force_0 : vec4<f32>,
    @align(16) load_torque_0 : vec4<f32>,
    @align(16) ledger_0 : vec4<f32>,
    @align(16) cand_0 : vec4<u32>,
};

@binding(7) @group(0) var<storage, read_write> impactors_0 : array<Impactor_std430_0>;

fn isnan_0( x_0 : f32) -> bool
{
    var _S1 : u32 = (bitcast<u32>((x_0)));
    var _S2 : u32 = (_S1 & (u32(8388607)));
    var _S3 : bool;
    if(((((_S1 >> (u32(23)))) & (u32(255)))) == u32(255))
    {
        _S3 = _S2 != u32(0);
    }
    else
    {
        _S3 = false;
    }
    return _S3;
}

fn stopped_0() -> bool
{
    var _S4 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S5 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S5 = true;
    }
    else
    {
        _S5 = (_S4.y) != u32(0);
    }
    return _S5;
}

struct Quat_0
{
     w_0 : f32,
     x_1 : f32,
     y_0 : f32,
     z_0 : f32,
};

fn quat_of_0( q_0 : vec4<f32>) -> Quat_0
{
    var r_0 : Quat_0;
    r_0.x_1 = q_0.x;
    r_0.y_0 = q_0.y;
    r_0.z_0 = q_0.z;
    r_0.w_0 = q_0.w;
    return r_0;
}

fn rotate_0( q_1 : Quat_0,  v_0 : vec3<f32>) -> vec3<f32>
{
    var qv_0 : vec3<f32> = vec3<f32>(q_1.x_1, q_1.y_0, q_1.z_0);
    var t_0 : vec3<f32> = cross(qv_0, v_0) * vec3<f32>(2.0f);
    return v_0 + t_0 * vec3<f32>(q_1.w_0) + cross(qv_0, t_0);
}

struct WorldPoint_0
{
     hi_0 : vec3<f32>,
     lo_0 : vec3<f32>,
     rel_0 : vec3<f32>,
};

fn chunk_world_0( c_0 : u32) -> WorldPoint_0
{
    var q_2 : Quat_0 = quat_of_0(islands_0[chunks_0[c_0].info_1.y].rotation_0);
    var w_1 : WorldPoint_0;
    w_1.hi_0 = islands_0[chunks_0[c_0].info_1.y].position_0.xyz;
    w_1.lo_0 = islands_0[chunks_0[c_0].info_1.y].position_err_0.xyz;
    w_1.rel_0 = rotate_0(q_2, chunks_0[c_0].center_0.xyz + state_0[u32(4) * c_0].xyz);
    return w_1;
}

fn world_diff_0( a_0 : WorldPoint_0,  b_0 : WorldPoint_0) -> vec3<f32>
{
    return a_0.hi_0 - b_0.hi_0 + (a_0.lo_0 - b_0.lo_0) + (a_0.rel_0 - b_0.rel_0);
}

fn safe_normalize_0( v_1 : vec3<f32>) -> vec3<f32>
{
    var n_0 : f32 = length(v_1);
    var _S6 : vec3<f32>;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S6 = v_1 / vec3<f32>(n_0);
    }
    else
    {
        _S6 = vec3<f32>(0.0f);
    }
    return _S6;
}

fn from_axis_angle_0( axis_0 : vec3<f32>,  angle_0 : f32) -> Quat_0
{
    var a_1 : vec3<f32> = safe_normalize_0(axis_0);
    var _S7 : f32 = 0.5f * angle_0;
    var s_0 : f32 = sin(_S7);
    var q_3 : Quat_0;
    q_3.w_0 = cos(_S7);
    q_3.x_1 = a_1.x * s_0;
    q_3.y_0 = a_1.y * s_0;
    q_3.z_0 = a_1.z * s_0;
    return q_3;
}

struct Box_0
{
     center_1 : vec3<f32>,
     axis0_0 : vec3<f32>,
     axis1_0 : vec3<f32>,
     axis2_0 : vec3<f32>,
     half_2 : vec3<f32>,
};

fn chunk_box_0( c_1 : u32,  center_2 : vec3<f32>) -> Box_0
{
    var cc_0 : ContactChunk_std430_0 = contact_chunks_0[c_1];
    var q_4 : Quat_0 = quat_of_0(islands_0[chunks_0[c_1].info_1.y].rotation_0);
    var th_0 : vec3<f32> = state_0[u32(4) * c_1 + u32(1)].xyz;
    var hidden_0 : Quat_0 = from_axis_angle_0(th_0, length(th_0));
    var b_1 : Box_0;
    b_1.center_1 = center_2;
    b_1.axis0_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(cc_0.rot0_0.x, cc_0.rot1_0.x, cc_0.rot2_0.x)));
    b_1.axis1_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(cc_0.rot0_0.y, cc_0.rot1_0.y, cc_0.rot2_0.y)));
    b_1.axis2_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(cc_0.rot0_0.z, cc_0.rot1_0.z, cc_0.rot2_0.z)));
    b_1.half_2 = cc_0.half_0.xyz;
    return b_1;
}

fn may_overlap_0( a_2 : Box_0,  b_2 : Box_0) -> bool
{
    var _S8 : vec3<f32> = b_2.center_1 - a_2.center_1;
    var _S9 : f32 = 0.00000999999974738f * (length(a_2.half_2) + length(b_2.half_2));
    var _S10 : array<vec3<f32>, i32(6)> = array<vec3<f32>, i32(6)>( a_2.axis0_0, a_2.axis1_0, a_2.axis2_0, b_2.axis0_0, b_2.axis1_0, b_2.axis2_0 );
    var i_0 : u32 = u32(0);
    loop
    {
        if(i_0 < u32(15))
        {
        }
        else
        {
            break;
        }
        var l_0 : vec3<f32>;
        if(i_0 < u32(6))
        {
            l_0 = _S10[i_0];
        }
        else
        {
            var _S11 : u32 = i_0 - u32(6);
            l_0 = cross(_S10[_S11 / u32(3)], _S10[u32(3) + _S11 % u32(3)]);
        }
        var len_0 : f32 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + u32(1);
            continue;
        }
        if((abs(dot(_S8, l_0))) > (a_2.half_2.x * abs(dot(a_2.axis0_0, l_0)) + a_2.half_2.y * abs(dot(a_2.axis1_0, l_0)) + a_2.half_2.z * abs(dot(a_2.axis2_0, l_0)) + (b_2.half_2.x * abs(dot(b_2.axis0_0, l_0)) + b_2.half_2.y * abs(dot(b_2.axis1_0, l_0)) + b_2.half_2.z * abs(dot(b_2.axis2_0, l_0))) + _S9 * len_0))
        {
            return false;
        }
        i_0 = i_0 + u32(1);
    }
    return true;
}

fn box_axis_0( b_3 : Box_0,  k_0 : u32) -> vec3<f32>
{
    var _S12 : vec3<f32>;
    if(k_0 == u32(0))
    {
        _S12 = b_3.axis0_0;
    }
    else
    {
        if(k_0 == u32(1))
        {
            _S12 = b_3.axis1_0;
        }
        else
        {
            _S12 = b_3.axis2_0;
        }
    }
    return _S12;
}

fn comp3_0( v_2 : vec3<f32>,  k_1 : u32) -> f32
{
    var _S13 : f32;
    if(k_1 == u32(0))
    {
        _S13 = v_2.x;
    }
    else
    {
        if(k_1 == u32(1))
        {
            _S13 = v_2.y;
        }
        else
        {
            _S13 = v_2.z;
        }
    }
    return _S13;
}

fn sample_point_0( b_4 : Box_0,  i_1 : u32) -> vec3<f32>
{
    var sign_0 : f32;
    if(i_1 < u32(8))
    {
        var h_0 : vec3<f32> = b_4.half_2 * vec3<f32>(0.89999997615814209f);
        if(((i_1 & (u32(1)))) == u32(0))
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        var _S14 : f32;
        if(((i_1 & (u32(2)))) == u32(0))
        {
            _S14 = - h_0.y;
        }
        else
        {
            _S14 = h_0.y;
        }
        var _S15 : f32;
        if(((i_1 & (u32(4)))) == u32(0))
        {
            _S15 = - h_0.z;
        }
        else
        {
            _S15 = h_0.z;
        }
        return b_4.center_1 + b_4.axis0_0 * vec3<f32>(sign_0) + b_4.axis1_0 * vec3<f32>(_S14) + b_4.axis2_0 * vec3<f32>(_S15);
    }
    var _S16 : u32 = i_1 - u32(8);
    var axis_1 : u32 = _S16 / u32(2);
    if((_S16 % u32(2)) == u32(0))
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    return b_4.center_1 + box_axis_0(b_4, axis_1) * vec3<f32>((sign_0 * comp3_0(b_4.half_2, axis_1)));
}

fn penetration_0( b_5 : Box_0,  p_0 : vec3<f32>,  depth_0 : ptr<function, f32>,  normal_0 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_0) = 0.0f;
    (*normal_0) = vec3<f32>(0.0f);
    var r_1 : vec3<f32> = p_0 - b_5.center_1;
    var _S17 : vec3<f32> = b_5.half_2;
    if((dot(r_1, r_1)) > (dot(_S17, _S17) * 1.00001001358032227f))
    {
        return false;
    }
    var best_0 : f32 = 1.00000001504746622e+30f;
    var axis_2 : u32 = u32(0);
    var side_0 : f32 = 1.0f;
    var k_2 : u32 = u32(0);
    loop
    {
        if(k_2 < u32(3))
        {
        }
        else
        {
            break;
        }
        var local_0 : f32 = dot(r_1, box_axis_0(b_5, k_2));
        var d_0 : f32 = comp3_0(b_5.half_2, k_2) - abs(local_0);
        if(d_0 <= 0.0f)
        {
            return false;
        }
        if(d_0 < best_0)
        {
            var _S18 : f32;
            if(local_0 >= 0.0f)
            {
                _S18 = 1.0f;
            }
            else
            {
                _S18 = -1.0f;
            }
            best_0 = d_0;
            axis_2 = k_2;
            side_0 = _S18;
        }
        k_2 = k_2 + u32(1);
    }
    (*depth_0) = best_0;
    (*normal_0) = box_axis_0(b_5, axis_2) * vec3<f32>(side_0);
    return true;
}

fn half_thickness_and_area_0( b_6 : Box_0,  d_1 : vec3<f32>) -> vec2<f32>
{
    var k_3 : u32 = u32(0);
    var h_1 : f32 = 0.0f;
    var area_0 : f32 = 0.0f;
    loop
    {
        if(k_3 < u32(3))
        {
        }
        else
        {
            break;
        }
        var c_2 : f32 = abs(dot(d_1, box_axis_0(b_6, k_3)));
        var h_2 : f32 = h_1 + c_2 * comp3_0(b_6.half_2, k_3);
        var _S19 : u32 = k_3 + u32(1);
        var area_1 : f32 = area_0 + c_2 * 4.0f * comp3_0(b_6.half_2, _S19 % u32(3)) * comp3_0(b_6.half_2, (k_3 + u32(2)) % u32(3));
        k_3 = _S19;
        h_1 = h_2;
        area_0 = area_1;
    }
    return vec2<f32>(h_1, area_0);
}

fn contact_stiffness_0( ea_0 : f32,  a_3 : Box_0,  eb_0 : f32,  b_7 : Box_0,  dir_0 : vec3<f32>) -> f32
{
    var d_2 : vec3<f32> = safe_normalize_0(dir_0);
    var ta_0 : vec2<f32> = half_thickness_and_area_0(a_3, d_2);
    var tb_0 : vec2<f32> = half_thickness_and_area_0(b_7, d_2);
    return min(ta_0.y, tb_0.y) / (ta_0.x / ea_0 + tb_0.x / eb_0);
}

fn chunk_velocity_0( c_3 : u32,  v_3 : ptr<function, vec3<f32>>,  w_2 : ptr<function, vec3<f32>>)
{
    var q_5 : Quat_0 = quat_of_0(islands_0[chunks_0[c_3].info_1.y].rotation_0);
    var _S20 : u32 = u32(4) * c_3;
    var _S21 : vec3<f32> = islands_0[chunks_0[c_3].info_1.y].angular_velocity_0.xyz;
    (*v_3) = islands_0[chunks_0[c_3].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_3].info_1.y].velocity_err_0.xyz + cross(_S21, rotate_0(q_5, chunks_0[c_3].center_0.xyz + state_0[_S20].xyz - islands_0[chunks_0[c_3].info_1.y].com_0.xyz)) + rotate_0(q_5, state_0[_S20 + u32(2)].xyz);
    (*w_2) = _S21 + rotate_0(q_5, state_0[_S20 + u32(3)].xyz);
    return;
}

fn penalty_force_0( k_4 : f32,  m_red_0 : f32,  friction_0 : f32,  depth_1 : f32,  normal_1 : vec3<f32>,  rel_velocity_0 : vec3<f32>,  dt_1 : f32,  points_0 : u32,  stored_0 : ptr<function, f32>,  dissipated_0 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_0 : f32 = 1.0f / max(f32(points_0), 10.0f) * m_red_0 / dt_1;
    var vn_0 : f32 = dot(rel_velocity_0, normal_1);
    var _S22 : f32 = k_4 * depth_1;
    var _S23 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_4 * m_red_0), c_max_0) * vn_0;
    var _S24 : f32 = _S22 - _S23;
    var _S25 : f32 = max(_S24, 0.0f);
    var vt_0 : vec3<f32> = rel_velocity_0 - normal_1 * vec3<f32>(vn_0);
    var vt_mag_0 : f32 = length(vt_0);
    var _S26 : f32 = friction_0 * _S25;
    var _S27 : f32 = min(_S26, min(c_max_0, _S26 / 0.00100000004749745f) * vt_mag_0);
    var ft_0 : vec3<f32>;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = (vec3<f32>(0) - vt_0) * vec3<f32>((_S27 / vt_mag_0));
    }
    else
    {
        ft_0 = vec3<f32>(0.0f);
    }
    (*stored_0) = 0.5f * k_4 * depth_1 * depth_1;
    var damping_power_0 : f32;
    if(_S24 > 0.0f)
    {
        damping_power_0 = _S23 * vn_0;
    }
    else
    {
        damping_power_0 = _S22 * max(vn_0, 0.0f);
    }
    (*dissipated_0) = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_1 * vec3<f32>(_S25) + ft_0;
}

fn comp_add1_0( sum_0 : ptr<function, f32>,  err_0 : ptr<function, f32>,  x_2 : f32)
{
    var t_1 : f32 = (*sum_0) + x_2;
    if((abs((*sum_0))) >= (abs(x_2)))
    {
        (*err_0) = (*err_0) + ((*sum_0) - t_1 + x_2);
    }
    else
    {
        (*err_0) = (*err_0) + (x_2 - t_1 + (*sum_0));
    }
    (*sum_0) = t_1;
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn contact_pairs(@builtin(global_invocation_id) id_0 : vec3<u32>)
{
    var i_2 : u32 = id_0.x;
    var has_state_0 : bool;
    if(i_2 >= (params_0.pair_count_0))
    {
        has_state_0 = true;
    }
    else
    {
        has_state_0 = stopped_0();
    }
    if(has_state_0)
    {
        return;
    }
    var _S28 : u32 = u32(2) * i_2;
    var ids_0 : vec4<u32> = contact_static_0[_S28];
    var law_0 : vec4<f32> = (bitcast<vec4<f32>>((contact_static_0[_S28 + u32(1)])));
    var ca_0 : u32 = ids_0.x;
    var cb_0 : u32 = ids_0.y;
    var slot_0 : u32 = ids_0.z;
    var _S29 : u32 = ids_0.w * u32(28);
    var _S30 : f32 = law_0.x;
    var _S31 : f32 = law_0.y;
    var _S32 : f32 = params_0.dt_0;
    var cb_rel_0 : vec3<f32> = world_diff_0(chunk_world_0(cb_0), chunk_world_0(ca_0));
    var touching_0 : bool = !((length(cb_rel_0)) > (contact_chunks_0[ca_0].half_0.w + contact_chunks_0[cb_0].half_0.w));
    var ledger_1 : vec4<f32> = contact_out_0[params_0.ledger_base_0 + i_2];
    var flags_0 : u32 = (bitcast<u32>((contact_out_0[params_0.ledger_base_0 + i_2].w)));
    var e_0 : u32;
    if(!touching_0)
    {
        if(((flags_0 & (u32(1)))) != u32(0))
        {
            e_0 = u32(0);
            loop
            {
                if(e_0 < u32(28))
                {
                }
                else
                {
                    break;
                }
                contact_state_0[_S29 + e_0] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                e_0 = e_0 + u32(1);
            }
        }
        if(((flags_0 & (u32(2)))) != u32(0))
        {
            var _S33 : u32 = u32(2) * slot_0;
            var _S34 : vec4<f32> = vec4<f32>(0.0f);
            contact_out_0[_S33] = _S34;
            contact_out_0[_S33 + u32(1)] = _S34;
            contact_out_0[_S33 + u32(2)] = _S34;
            contact_out_0[_S33 + u32(3)] = _S34;
        }
        if(flags_0 != u32(0))
        {
            has_state_0 = true;
        }
        else
        {
            has_state_0 = (ledger_1.x) != 0.0f;
        }
        if(has_state_0)
        {
            ledger_1[i32(0)] = 0.0f;
            ledger_1[i32(3)] = (bitcast<f32>((u32(0))));
            contact_out_0[params_0.ledger_base_0 + i_2] = ledger_1;
        }
        return;
    }
    var _S35 : vec3<f32> = vec3<f32>(0.0f);
    var ba_0 : Box_0 = chunk_box_0(ca_0, _S35);
    var bb_0 : Box_0 = chunk_box_0(cb_0, cb_rel_0);
    var s_1 : u32;
    var count_0 : u32;
    var fa_0 : vec3<f32>;
    var ta_1 : vec3<f32>;
    var fb_0 : vec3<f32>;
    var tb_1 : vec3<f32>;
    var stored_sum_0 : f32;
    if(may_overlap_0(ba_0, bb_0))
    {
        var pts_0 : array<vec3<f32>, i32(28)>;
        var nrm_0 : array<vec3<f32>, i32(28)>;
        var dep_0 : array<f32, i32(28)>;
        var idx_0 : array<u32, i32(28)>;
        s_1 = u32(0);
        count_0 = u32(0);
        loop
        {
            if(s_1 < u32(14))
            {
            }
            else
            {
                break;
            }
            var p_1 : vec3<f32> = sample_point_0(ba_0, s_1);
            var d_3 : f32;
            var n_1 : vec3<f32>;
            var _S36 : bool = penetration_0(bb_0, p_1, &(d_3), &(n_1));
            if(_S36)
            {
                pts_0[count_0] = p_1;
                nrm_0[count_0] = n_1;
                dep_0[count_0] = d_3;
                idx_0[count_0] = s_1;
                count_0 = count_0 + u32(1);
            }
            s_1 = s_1 + u32(1);
        }
        s_1 = u32(0);
        loop
        {
            if(s_1 < u32(14))
            {
            }
            else
            {
                break;
            }
            var p_2 : vec3<f32> = sample_point_0(bb_0, s_1);
            var d_4 : f32;
            var n_2 : vec3<f32>;
            var _S37 : bool = penetration_0(ba_0, p_2, &(d_4), &(n_2));
            if(_S37)
            {
                pts_0[count_0] = p_2;
                nrm_0[count_0] = (vec3<f32>(0) - n_2);
                dep_0[count_0] = d_4;
                idx_0[count_0] = u32(14) + s_1;
                count_0 = count_0 + u32(1);
            }
            s_1 = s_1 + u32(1);
        }
        if(count_0 > u32(0))
        {
            var k_pair_0 : f32 = contact_stiffness_0(contact_chunks_0[ca_0].mat_0.x, ba_0, contact_chunks_0[cb_0].mat_0.x, bb_0, bb_0.center_1 - ba_0.center_1);
            var va0_0 : vec3<f32>;
            var wa0_0 : vec3<f32>;
            chunk_velocity_0(ca_0, &(va0_0), &(wa0_0));
            var vb0_0 : vec3<f32>;
            var wb0_0 : vec3<f32>;
            chunk_velocity_0(cb_0, &(vb0_0), &(wb0_0));
            var eff_0 : array<f32, i32(28)>;
            var j_0 : u32 = u32(0);
            var inside_mask_0 : u32 = u32(0);
            var engaged_0 : u32 = u32(0);
            loop
            {
                if(j_0 < count_0)
                {
                }
                else
                {
                    break;
                }
                var inside_mask_1 : u32 = (inside_mask_0 | (((u32(1) << ((idx_0[j_0]))))));
                var _S38 : u32 = _S29 + idx_0[j_0];
                var entry_0 : vec4<f32> = contact_state_0[_S38];
                var p_3 : vec3<f32> = pts_0[j_0];
                var n_3 : vec3<f32> = nrm_0[j_0];
                if(isnan_0(contact_state_0[_S38].x))
                {
                    has_state_0 = true;
                }
                else
                {
                    has_state_0 = (dot(entry_0.yzw, n_3)) < 0.99000000953674316f;
                }
                if(has_state_0)
                {
                    if((dep_0[j_0]) > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - bb_0.center_1)), n_3)) * _S32 + 9.99999971718068537e-10f))
                    {
                        stored_sum_0 = dep_0[j_0];
                    }
                    else
                    {
                        stored_sum_0 = 0.0f;
                    }
                    entry_0 = vec4<f32>(stored_sum_0, n_3);
                }
                entry_0[i32(0)] = min(entry_0.x, dep_0[j_0]);
                contact_state_0[_S38] = entry_0;
                var _S39 : f32 = dep_0[j_0] - entry_0.x;
                eff_0[j_0] = _S39;
                if(_S39 > 0.0f)
                {
                    engaged_0 = engaged_0 + u32(1);
                }
                j_0 = j_0 + u32(1);
                inside_mask_0 = inside_mask_1;
            }
            e_0 = u32(0);
            loop
            {
                if(e_0 < u32(28))
                {
                }
                else
                {
                    break;
                }
                if(((inside_mask_0 & (((u32(1) << (e_0)))))) == u32(0))
                {
                    contact_state_0[_S29 + e_0] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                }
                e_0 = e_0 + u32(1);
            }
            var _S40 : f32 = k_pair_0 / max(f32(engaged_0), 10.0f);
            j_0 = u32(0);
            fa_0 = _S35;
            ta_1 = _S35;
            fb_0 = _S35;
            tb_1 = _S35;
            stored_sum_0 = 0.0f;
            loop
            {
                if(j_0 < count_0)
                {
                }
                else
                {
                    break;
                }
                if((eff_0[j_0]) <= 0.0f)
                {
                    j_0 = j_0 + u32(1);
                    continue;
                }
                var _S41 : vec3<f32> = pts_0[j_0] - bb_0.center_1;
                var stored_1 : f32;
                var diss_0 : f32;
                var f_0 : vec3<f32> = penalty_force_0(_S40, _S30, _S31, eff_0[j_0], nrm_0[j_0], va0_0 + cross(wa0_0, pts_0[j_0]) - (vb0_0 + cross(wb0_0, _S41)), _S32, engaged_0, &(stored_1), &(diss_0));
                var fa_1 : vec3<f32> = fa_0 + f_0;
                var ta_2 : vec3<f32> = ta_1 + cross(pts_0[j_0], f_0);
                var _S42 : vec3<f32> = (vec3<f32>(0) - f_0);
                var fb_1 : vec3<f32> = fb_0 + _S42;
                var tb_2 : vec3<f32> = tb_1 + cross(_S41, _S42);
                var stored_sum_1 : f32 = stored_sum_0 + stored_1;
                var _S43 : f32 = ledger_1[i32(1)];
                var _S44 : f32 = ledger_1[i32(2)];
                comp_add1_0(&(_S43), &(_S44), diss_0);
                ledger_1[i32(1)] = _S43;
                ledger_1[i32(2)] = _S44;
                fa_0 = fa_1;
                ta_1 = ta_2;
                fb_0 = fb_1;
                tb_1 = tb_2;
                stored_sum_0 = stored_sum_1;
                j_0 = j_0 + u32(1);
            }
            has_state_0 = true;
        }
        else
        {
            has_state_0 = false;
            fa_0 = _S35;
            ta_1 = _S35;
            fb_0 = _S35;
            tb_1 = _S35;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S35;
        ta_1 = _S35;
        fb_0 = _S35;
        tb_1 = _S35;
        stored_sum_0 = 0.0f;
    }
    var loaded_0 : bool;
    if(!has_state_0)
    {
        loaded_0 = ((flags_0 & (u32(1)))) != u32(0);
    }
    else
    {
        loaded_0 = false;
    }
    if(loaded_0)
    {
        e_0 = u32(0);
        loop
        {
            if(e_0 < u32(28))
            {
            }
            else
            {
                break;
            }
            contact_state_0[_S29 + e_0] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
            e_0 = e_0 + u32(1);
        }
    }
    var _S45 : vec3<f32> = vec3<f32>(0.0f);
    if((any((fa_0 != _S45))))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((ta_1 != _S45)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((fb_0 != _S45)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((tb_1 != _S45)));
    }
    var _S46 : bool;
    if(loaded_0)
    {
        _S46 = true;
    }
    else
    {
        _S46 = ((flags_0 & (u32(2)))) != u32(0);
    }
    if(_S46)
    {
        var _S47 : u32 = u32(2) * slot_0;
        contact_out_0[_S47] = vec4<f32>(fa_0, 0.0f);
        contact_out_0[_S47 + u32(1)] = vec4<f32>(ta_1, 0.0f);
        contact_out_0[_S47 + u32(2)] = vec4<f32>(fb_0, 0.0f);
        contact_out_0[_S47 + u32(3)] = vec4<f32>(tb_1, 0.0f);
    }
    ledger_1[i32(0)] = stored_sum_0;
    if(has_state_0)
    {
        s_1 = u32(1);
    }
    else
    {
        s_1 = u32(0);
    }
    if(loaded_0)
    {
        count_0 = u32(2);
    }
    else
    {
        count_0 = u32(0);
    }
    ledger_1[i32(3)] = (bitcast<f32>(((s_1 | (count_0)))));
    contact_out_0[params_0.ledger_base_0 + i_2] = ledger_1;
    return;
}

struct Impactor_0
{
     position_1 : vec4<f32>,
     position_err_1 : vec4<f32>,
     velocity_1 : vec4<f32>,
     velocity_err_1 : vec4<f32>,
     angular_velocity_1 : vec4<f32>,
     rotation_1 : vec4<f32>,
     inertia0_2 : vec4<f32>,
     inertia1_2 : vec4<f32>,
     inertia2_2 : vec4<f32>,
     inv0_2 : vec4<f32>,
     inv1_2 : vec4<f32>,
     inv2_2 : vec4<f32>,
     shape_0 : vec4<f32>,
     half_1 : vec4<f32>,
     mat_1 : vec4<f32>,
     crush_0 : vec4<f32>,
     load_force_0 : vec4<f32>,
     load_torque_0 : vec4<f32>,
     ledger_0 : vec4<f32>,
     cand_0 : vec4<u32>,
};

fn impactor_box_0( imp_0 : Impactor_0,  center_3 : vec3<f32>,  half_3 : vec3<f32>) -> Box_0
{
    var q_6 : Quat_0 = quat_of_0(imp_0.rotation_1);
    var b_8 : Box_0;
    b_8.center_1 = center_3;
    b_8.axis0_0 = rotate_0(q_6, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_8.axis1_0 = rotate_0(q_6, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_8.axis2_0 = rotate_0(q_6, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_8.half_2 = half_3;
    return b_8;
}

fn sphere_contact_0( b_9 : Box_0,  center_4 : vec3<f32>,  radius_0 : f32,  point_0 : ptr<function, vec3<f32>>,  normal_2 : ptr<function, vec3<f32>>,  depth_2 : ptr<function, f32>) -> bool
{
    var _S48 : vec3<f32> = vec3<f32>(0.0f);
    (*point_0) = _S48;
    (*normal_2) = _S48;
    (*depth_2) = 0.0f;
    var r_2 : vec3<f32> = center_4 - b_9.center_1;
    var local_1 : vec3<f32> = vec3<f32>(dot(r_2, b_9.axis0_0), dot(r_2, b_9.axis1_0), dot(r_2, b_9.axis2_0));
    var q_7 : vec3<f32> = clamp(local_1, (vec3<f32>(0) - b_9.half_2), b_9.half_2);
    var d_5 : vec3<f32> = local_1 - q_7;
    var dist_0 : f32 = length(d_5);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        var dn_0 : vec3<f32> = d_5 / vec3<f32>(dist_0);
        (*normal_2) = b_9.axis0_0 * vec3<f32>(dn_0.x) + b_9.axis1_0 * vec3<f32>(dn_0.y) + b_9.axis2_0 * vec3<f32>(dn_0.z);
        (*point_0) = b_9.center_1 + b_9.axis0_0 * vec3<f32>(q_7.x) + b_9.axis1_0 * vec3<f32>(q_7.y) + b_9.axis2_0 * vec3<f32>(q_7.z);
        (*depth_2) = radius_0 - dist_0;
        return true;
    }
    var inside_0 : f32;
    var n_4 : vec3<f32>;
    var _S49 : bool = penetration_0(b_9, center_4, &(inside_0), &(n_4));
    if(!_S49)
    {
        return false;
    }
    (*normal_2) = n_4;
    (*point_0) = center_4 - n_4 * vec3<f32>(min(radius_0, inside_0));
    (*depth_2) = radius_0 + inside_0;
    return true;
}

fn impactor_point_0( _S50 : u32) -> WorldPoint_0
{
    var wi_0 : WorldPoint_0;
    wi_0.hi_0 = impactors_0[_S50].position_1.xyz;
    wi_0.lo_0 = impactors_0[_S50].position_err_1.xyz;
    wi_0.rel_0 = vec3<f32>(0.0f);
    return wi_0;
}

fn impactor_box_1( _S51 : u32,  _S52 : vec3<f32>,  _S53 : vec3<f32>) -> Box_0
{
    var q_8 : Quat_0 = quat_of_0(impactors_0[_S51].rotation_1);
    var b_10 : Box_0;
    b_10.center_1 = _S52;
    b_10.axis0_0 = rotate_0(q_8, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_10.axis1_0 = rotate_0(q_8, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_10.axis2_0 = rotate_0(q_8, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_10.half_2 = _S53;
    return b_10;
}

fn impactor_points_0( _S54 : u32,  _S55 : f32,  _S56 : Box_0,  _S57 : Box_0,  _S58 : ptr<function, array<vec3<f32>, i32(28)>>,  _S59 : ptr<function, array<vec3<f32>, i32(28)>>,  _S60 : ptr<function, array<f32, i32(28)>>) -> u32
{
    var _S61 : vec4<f32> = impactors_0[_S54].shape_0;
    var count_1 : u32;
    if((impactors_0[_S54].shape_0.x) == 0.0f)
    {
        var p_4 : vec3<f32>;
        var n_5 : vec3<f32>;
        var d_6 : f32;
        var _S62 : bool = sphere_contact_0(_S57, vec3<f32>(0.0f), _S61.y - _S55, &(p_4), &(n_5), &(d_6));
        if(_S62)
        {
            (*_S58)[i32(0)] = p_4;
            (*_S59)[i32(0)] = (vec3<f32>(0) - n_5);
            (*_S60)[i32(0)] = d_6;
            count_1 = u32(1);
        }
        else
        {
            count_1 = u32(0);
        }
        return count_1;
    }
    var shrunk_0 : Box_0 = _S56;
    shrunk_0.half_2 = _S56.half_2 - min(vec3<f32>(_S55), _S56.half_2 * vec3<f32>(0.5f));
    var s_2 : u32 = u32(0);
    count_1 = u32(0);
    loop
    {
        if(s_2 < u32(14))
        {
        }
        else
        {
            break;
        }
        var p_5 : vec3<f32> = sample_point_0(_S57, s_2);
        var d_7 : f32;
        var n_6 : vec3<f32>;
        var _S63 : bool = penetration_0(shrunk_0, p_5, &(d_7), &(n_6));
        if(_S63)
        {
            (*_S58)[count_1] = p_5;
            (*_S59)[count_1] = n_6;
            (*_S60)[count_1] = d_7;
            count_1 = count_1 + u32(1);
        }
        s_2 = s_2 + u32(1);
    }
    s_2 = u32(0);
    loop
    {
        if(s_2 < u32(14))
        {
        }
        else
        {
            break;
        }
        var p_6 : vec3<f32> = sample_point_0(shrunk_0, s_2);
        var d_8 : f32;
        var n_7 : vec3<f32>;
        var _S64 : bool = penetration_0(_S57, p_6, &(d_8), &(n_7));
        if(_S64)
        {
            (*_S58)[count_1] = p_6;
            (*_S59)[count_1] = (vec3<f32>(0) - n_7);
            (*_S60)[count_1] = d_8;
            count_1 = count_1 + u32(1);
        }
        s_2 = s_2 + u32(1);
    }
    return count_1;
}

@compute
@workgroup_size(64, 1, 1)
fn impactor_candidates(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var _S65 : u32 = id_1.x;
    var _S66 : bool;
    if(_S65 >= (params_0.cand_count_0))
    {
        _S66 = true;
    }
    else
    {
        _S66 = stopped_0();
    }
    if(_S66)
    {
        return;
    }
    var entry_1 : vec4<u32> = contact_static_0[params_0.cand_begin_0 + _S65];
    var c_4 : u32 = entry_1.x;
    var _S67 : u32 = entry_1.z;
    var imp_1 : Impactor_std430_0 = impactors_0[_S67];
    var total_0 : f32;
    var ksum_0 : f32;
    if((impactors_0[_S67].cand_0.z) == u32(0))
    {
        var rel_1 : vec3<f32> = world_diff_0(chunk_world_0(c_4), impactor_point_0(_S67));
        if(!((length(rel_1)) > (imp_1.half_1.w + contact_chunks_0[c_4].half_0.w)))
        {
            var _S68 : Box_0 = impactor_box_1(_S67, vec3<f32>(0.0f), imp_1.half_1.xyz);
            var b_11 : Box_0 = chunk_box_0(c_4, rel_1);
            var kc_0 : f32 = contact_stiffness_0(imp_1.mat_1.x, _S68, contact_chunks_0[c_4].mat_0.x, b_11, b_11.center_1 - _S68.center_1);
            var pts_1 : array<vec3<f32>, i32(28)>;
            var nrm_1 : array<vec3<f32>, i32(28)>;
            var dep_1 : array<f32, i32(28)>;
            var _S69 : u32 = impactor_points_0(_S67, imp_1.crush_0.w, _S68, b_11, &(pts_1), &(nrm_1), &(dep_1));
            var _S70 : f32;
            if((imp_1.shape_0.x) == 0.0f)
            {
                _S70 = kc_0;
            }
            else
            {
                _S70 = kc_0 / max(f32(_S69), 10.0f);
            }
            var j_1 : u32 = u32(0);
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            loop
            {
                if(j_1 < _S69)
                {
                }
                else
                {
                    break;
                }
                var total_1 : f32 = total_0 + _S70 * dep_1[j_1];
                var ksum_1 : f32 = ksum_0 + _S70;
                j_1 = j_1 + u32(1);
                total_0 = total_1;
                ksum_0 = ksum_1;
            }
        }
        else
        {
            total_0 = 0.0f;
            ksum_0 = 0.0f;
        }
    }
    else
    {
        total_0 = 0.0f;
        ksum_0 = 0.0f;
    }
    var _S71 : u32 = u32(3) * _S65;
    contact_out_0[params_0.cand_base_0 + _S71] = vec4<f32>(total_0, ksum_0, contact_out_0[params_0.cand_base_0 + _S71].z, contact_out_0[params_0.cand_base_0 + _S71].w);
    return;
}

var<workgroup> g_red_a_0 : array<vec4<f32>, i32(256)>;

var<workgroup> g_red_b_0 : array<vec4<f32>, i32(256)>;

fn group_sum2_0( tid_0 : u32,  a_4 : ptr<function, vec4<f32>>,  b_12 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_0] = (*a_4);
    g_red_b_0[tid_0] = (*b_12);
    workgroupBarrier();
    var s_3 : u32 = u32(128);
    loop
    {
        if(s_3 > u32(0))
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_3)
        {
            var _S72 : u32 = tid_0 + s_3;
            g_red_a_0[tid_0] = g_red_a_0[tid_0] + g_red_a_0[_S72];
            g_red_b_0[tid_0] = g_red_b_0[tid_0] + g_red_b_0[_S72];
        }
        workgroupBarrier();
        s_3 = (s_3 >> (u32(1)));
    }
    (*a_4) = g_red_a_0[i32(0)];
    (*b_12) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn contact_impactors(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var p_7 : vec3<f32>;
    var ii_0 : u32 = group_0.x;
    var tid_1 : u32 = thread_0.x;
    var _S73 : bool;
    if(ii_0 >= (params_0.impactor_count_0))
    {
        _S73 = true;
    }
    else
    {
        _S73 = stopped_0();
    }
    if(_S73)
    {
        return;
    }
    var imp_2 : Impactor_0;
    imp_2.position_1 = impactors_0[ii_0].position_1;
    imp_2.position_err_1 = impactors_0[ii_0].position_err_1;
    imp_2.velocity_1 = impactors_0[ii_0].velocity_1;
    imp_2.velocity_err_1 = impactors_0[ii_0].velocity_err_1;
    imp_2.angular_velocity_1 = impactors_0[ii_0].angular_velocity_1;
    imp_2.rotation_1 = impactors_0[ii_0].rotation_1;
    imp_2.inertia0_2 = impactors_0[ii_0].inertia0_2;
    imp_2.inertia1_2 = impactors_0[ii_0].inertia1_2;
    imp_2.inertia2_2 = impactors_0[ii_0].inertia2_2;
    imp_2.inv0_2 = impactors_0[ii_0].inv0_2;
    imp_2.inv1_2 = impactors_0[ii_0].inv1_2;
    imp_2.inv2_2 = impactors_0[ii_0].inv2_2;
    imp_2.shape_0 = impactors_0[ii_0].shape_0;
    imp_2.half_1 = impactors_0[ii_0].half_1;
    imp_2.mat_1 = impactors_0[ii_0].mat_1;
    imp_2.crush_0 = impactors_0[ii_0].crush_0;
    imp_2.load_force_0 = impactors_0[ii_0].load_force_0;
    imp_2.load_torque_0 = impactors_0[ii_0].load_torque_0;
    imp_2.ledger_0 = impactors_0[ii_0].ledger_0;
    imp_2.cand_0 = impactors_0[ii_0].cand_0;
    var _S74 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S74;
    var unused_0 : vec4<f32> = _S74;
    var e_1 : u32 = imp_2.cand_0.x + tid_1;
    loop
    {
        if(e_1 < (imp_2.cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + contact_out_0[params_0.cand_base_0 + u32(3) * (e_1 - params_0.cand_begin_0)];
        e_1 = e_1 + u32(256);
    }
    group_sum2_0(tid_1, &(shares_0), &(unused_0));
    if(tid_1 != u32(0))
    {
        return;
    }
    var _S75 : f32 = params_0.dt_0;
    var _S76 : vec3<f32> = vec3<f32>(0.0f);
    var depth_at_start_0 : f32 = imp_2.crush_0.w;
    var crush_factor_0 : f32;
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((imp_2.cand_0.z) == u32(0))
    {
        var total_2 : f32 = shares_0.x;
        var ksum_2 : f32 = shares_0.y;
        if((imp_2.crush_0.x) > 0.0f)
        {
            _S73 = (imp_2.crush_0.z) < (imp_2.crush_0.y);
        }
        else
        {
            _S73 = false;
        }
        if(_S73)
        {
            _S73 = total_2 > (imp_2.crush_0.x);
        }
        else
        {
            _S73 = false;
        }
        if(_S73)
        {
            var extra_0 : f32 = (total_2 - imp_2.crush_0.x) / ksum_2;
            imp_2.crush_0[i32(3)] = imp_2.crush_0[i32(3)] + extra_0;
            imp_2.crush_0[i32(2)] = imp_2.crush_0[i32(2)] + imp_2.crush_0.x * extra_0;
            var _S77 : f32 = imp_2.crush_0.x * extra_0;
            var _S78 : f32 = imp_2.ledger_0[i32(2)];
            var _S79 : f32 = imp_2.ledger_0[i32(3)];
            comp_add1_0(&(_S78), &(_S79), _S77);
            imp_2.ledger_0[i32(2)] = _S78;
            imp_2.ledger_0[i32(3)] = _S79;
            var _S80 : f32 = imp_2.crush_0.x * extra_0;
            var _S81 : f32 = imp_2.ledger_0[i32(0)];
            var _S82 : f32 = imp_2.ledger_0[i32(1)];
            comp_add1_0(&(_S81), &(_S82), _S80);
            imp_2.ledger_0[i32(0)] = _S81;
            imp_2.ledger_0[i32(1)] = _S82;
            crush_factor_0 = imp_2.crush_0.x / total_2;
        }
        else
        {
            crush_factor_0 = 1.0f;
        }
        if((params_0.has_ground_0) != u32(0))
        {
            var ib_0 : Box_0 = impactor_box_0(imp_2, _S76, imp_2.half_1.xyz);
            var _S83 : vec3<f32> = imp_2.velocity_1.xyz + imp_2.velocity_err_1.xyz;
            const _S84 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
            var kc_1 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_2.mat_1.x, ib_0, _S84);
            var _S85 : f32 = imp_2.position_1.z - params_0.ground_hi_0 + (imp_2.position_err_1.z - params_0.ground_lo_0);
            var total_points_0 : u32;
            if((imp_2.shape_0.x) == 0.0f)
            {
                total_points_0 = u32(1);
            }
            else
            {
                total_points_0 = u32(14);
            }
            var _S86 : f32 = kc_1 / f32(min(total_points_0, u32(5)));
            var s_4 : u32 = u32(0);
            var below_0 : u32 = u32(0);
            loop
            {
                if(s_4 < total_points_0)
                {
                }
                else
                {
                    break;
                }
                if((imp_2.shape_0.x) == 0.0f)
                {
                    p_7 = vec3<f32>(0.0f, 0.0f, - imp_2.shape_0.y);
                }
                else
                {
                    p_7 = sample_point_0(ib_0, s_4);
                }
                if((_S85 + p_7.z) < 0.0f)
                {
                    below_0 = below_0 + u32(1);
                }
                s_4 = s_4 + u32(1);
            }
            s_4 = u32(0);
            load_f_0 = _S76;
            load_t_0 = _S76;
            loop
            {
                if(s_4 < total_points_0)
                {
                }
                else
                {
                    break;
                }
                if((imp_2.shape_0.x) == 0.0f)
                {
                    p_7 = vec3<f32>(0.0f, 0.0f, - imp_2.shape_0.y);
                }
                else
                {
                    p_7 = sample_point_0(ib_0, s_4);
                }
                var depth_3 : f32 = - (_S85 + p_7.z);
                if(depth_3 <= 0.0f)
                {
                    s_4 = s_4 + u32(1);
                    continue;
                }
                var stored_2 : f32;
                var diss_1 : f32;
                var f_1 : vec3<f32> = penalty_force_0(_S86, imp_2.mat_1.z, params_0.ground_friction_0, depth_3, _S84, _S83 + cross(imp_2.angular_velocity_1.xyz, p_7), _S75, below_0, &(stored_2), &(diss_1));
                var load_f_1 : vec3<f32> = load_f_0 + f_1;
                var load_t_1 : vec3<f32> = load_t_0 + cross(p_7, f_1);
                var _S87 : f32 = imp_2.ledger_0[i32(0)];
                var _S88 : f32 = imp_2.ledger_0[i32(1)];
                comp_add1_0(&(_S87), &(_S88), diss_1);
                imp_2.ledger_0[i32(0)] = _S87;
                imp_2.ledger_0[i32(1)] = _S88;
                load_f_0 = load_f_1;
                load_t_0 = load_t_1;
                s_4 = s_4 + u32(1);
            }
        }
        else
        {
            load_f_0 = _S76;
            load_t_0 = _S76;
        }
    }
    else
    {
        crush_factor_0 = 1.0f;
        load_f_0 = _S76;
        load_t_0 = _S76;
    }
    imp_2.load_force_0 = vec4<f32>(load_f_0, crush_factor_0);
    imp_2.load_torque_0 = vec4<f32>(load_t_0, depth_at_start_0);
    impactors_0[ii_0].position_1 = imp_2.position_1;
    impactors_0[ii_0].position_err_1 = imp_2.position_err_1;
    impactors_0[ii_0].velocity_1 = imp_2.velocity_1;
    impactors_0[ii_0].velocity_err_1 = imp_2.velocity_err_1;
    impactors_0[ii_0].angular_velocity_1 = imp_2.angular_velocity_1;
    impactors_0[ii_0].rotation_1 = imp_2.rotation_1;
    impactors_0[ii_0].inertia0_2 = imp_2.inertia0_2;
    impactors_0[ii_0].inertia1_2 = imp_2.inertia1_2;
    impactors_0[ii_0].inertia2_2 = imp_2.inertia2_2;
    impactors_0[ii_0].inv0_2 = imp_2.inv0_2;
    impactors_0[ii_0].inv1_2 = imp_2.inv1_2;
    impactors_0[ii_0].inv2_2 = imp_2.inv2_2;
    impactors_0[ii_0].shape_0 = imp_2.shape_0;
    impactors_0[ii_0].half_1 = imp_2.half_1;
    impactors_0[ii_0].mat_1 = imp_2.mat_1;
    impactors_0[ii_0].crush_0 = imp_2.crush_0;
    impactors_0[ii_0].load_force_0 = imp_2.load_force_0;
    impactors_0[ii_0].load_torque_0 = imp_2.load_torque_0;
    impactors_0[ii_0].ledger_0 = imp_2.ledger_0;
    impactors_0[ii_0].cand_0 = imp_2.cand_0;
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn impactor_forces(@builtin(global_invocation_id) id_2 : vec3<u32>)
{
    var _S89 : u32 = id_2.x;
    var _S90 : bool;
    if(_S89 >= (params_0.cand_count_0))
    {
        _S90 = true;
    }
    else
    {
        _S90 = stopped_0();
    }
    if(_S90)
    {
        return;
    }
    var entry_2 : vec4<u32> = contact_static_0[params_0.cand_begin_0 + _S89];
    var c_5 : u32 = entry_2.x;
    var slot_1 : u32 = entry_2.y;
    var _S91 : u32 = entry_2.z;
    var imp_3 : Impactor_std430_0 = impactors_0[_S91];
    var _S92 : f32 = params_0.dt_0;
    var _S93 : vec3<f32> = vec3<f32>(0.0f);
    var _S94 : u32 = u32(3) * _S89;
    var scratch_0 : vec4<f32> = contact_out_0[params_0.cand_base_0 + _S94];
    var f_sum_0 : vec3<f32>;
    var t_sum_0 : vec3<f32>;
    var imp_f_0 : vec3<f32>;
    var imp_t_0 : vec3<f32>;
    if((impactors_0[_S91].cand_0.z) == u32(0))
    {
        var rel_2 : vec3<f32> = world_diff_0(chunk_world_0(c_5), impactor_point_0(_S91));
        if(!((length(rel_2)) > (imp_3.half_1.w + contact_chunks_0[c_5].half_0.w)))
        {
            var _S95 : Box_0 = impactor_box_1(_S91, _S93, imp_3.half_1.xyz);
            var b_13 : Box_0 = chunk_box_0(c_5, rel_2);
            var kc_2 : f32 = contact_stiffness_0(imp_3.mat_1.x, _S95, contact_chunks_0[c_5].mat_0.x, b_13, b_13.center_1 - _S95.center_1);
            var pts_2 : array<vec3<f32>, i32(28)>;
            var nrm_2 : array<vec3<f32>, i32(28)>;
            var dep_2 : array<f32, i32(28)>;
            var _S96 : u32 = impactor_points_0(_S91, imp_3.load_torque_0.w, _S95, b_13, &(pts_2), &(nrm_2), &(dep_2));
            var _S97 : bool = (imp_3.shape_0.x) == 0.0f;
            var _S98 : f32;
            if(_S97)
            {
                _S98 = kc_2;
            }
            else
            {
                _S98 = kc_2 / max(f32(_S96), 10.0f);
            }
            var _S99 : u32;
            if(_S97)
            {
                _S99 = u32(1);
            }
            else
            {
                _S99 = _S96;
            }
            var m_0 : f32 = contact_chunks_0[c_5].mat_0.z;
            var _S100 : f32 = imp_3.mat_1.z;
            var _S101 : f32 = m_0 * _S100 / (m_0 + _S100);
            var _S102 : f32;
            if((params_0.pair_friction_0) >= 0.0f)
            {
                _S102 = params_0.pair_friction_0;
            }
            else
            {
                _S102 = min(imp_3.mat_1.y, contact_chunks_0[c_5].mat_0.y);
            }
            var _S103 : vec3<f32> = imp_3.velocity_1.xyz + imp_3.velocity_err_1.xyz;
            var _S104 : f32 = imp_3.load_force_0.w;
            var vc_0 : vec3<f32>;
            var wc_0 : vec3<f32>;
            chunk_velocity_0(c_5, &(vc_0), &(wc_0));
            var j_2 : u32 = u32(0);
            f_sum_0 = _S93;
            t_sum_0 = _S93;
            imp_f_0 = _S93;
            imp_t_0 = _S93;
            loop
            {
                if(j_2 < _S96)
                {
                }
                else
                {
                    break;
                }
                var _S105 : vec3<f32> = pts_2[j_2] - b_13.center_1;
                var stored_3 : f32;
                var diss_2 : f32;
                var f_2 : vec3<f32> = penalty_force_0(_S98, _S101, _S102, dep_2[j_2] * _S104, nrm_2[j_2], vc_0 + cross(wc_0, _S105) - (_S103 + cross(imp_3.angular_velocity_1.xyz, pts_2[j_2])), _S92, _S99, &(stored_3), &(diss_2));
                var f_sum_1 : vec3<f32> = f_sum_0 + f_2;
                var t_sum_1 : vec3<f32> = t_sum_0 + cross(_S105, f_2);
                var imp_f_1 : vec3<f32> = imp_f_0 - f_2;
                var imp_t_1 : vec3<f32> = imp_t_0 - cross(pts_2[j_2], f_2);
                var _S106 : f32 = scratch_0[i32(2)];
                var _S107 : f32 = scratch_0[i32(3)];
                comp_add1_0(&(_S106), &(_S107), diss_2);
                scratch_0[i32(2)] = _S106;
                scratch_0[i32(3)] = _S107;
                j_2 = j_2 + u32(1);
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
            }
        }
        else
        {
            f_sum_0 = _S93;
            t_sum_0 = _S93;
            imp_f_0 = _S93;
            imp_t_0 = _S93;
        }
    }
    else
    {
        f_sum_0 = _S93;
        t_sum_0 = _S93;
        imp_f_0 = _S93;
        imp_t_0 = _S93;
    }
    var _S108 : u32 = u32(2) * slot_1;
    contact_out_0[_S108] = vec4<f32>(f_sum_0, 0.0f);
    contact_out_0[_S108 + u32(1)] = vec4<f32>(t_sum_0, 0.0f);
    contact_out_0[params_0.cand_base_0 + _S94] = scratch_0;
    contact_out_0[params_0.cand_base_0 + _S94 + u32(1)] = vec4<f32>(imp_f_0, 0.0f);
    contact_out_0[params_0.cand_base_0 + _S94 + u32(2)] = vec4<f32>(imp_t_0, 0.0f);
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn contact_gather(@builtin(global_invocation_id) id_3 : vec3<u32>)
{
    var c_6 : u32 = id_3.x;
    var _S109 : bool;
    if(c_6 >= (params_0.chunk_count_0))
    {
        _S109 = true;
    }
    else
    {
        _S109 = stopped_0();
    }
    if(_S109)
    {
        return;
    }
    var cc_1 : ContactChunk_std430_0 = contact_chunks_0[c_6];
    if((((cc_1.info_2.z) & (u32(1)))) == u32(0))
    {
        return;
    }
    var wp_0 : WorldPoint_0 = chunk_world_0(c_6);
    if((length(wp_0.hi_0 - cc_1.start_hi_0.xyz + (wp_0.lo_0 - cc_1.start_lo_0.xyz) + wp_0.rel_0)) > (cc_1.start_hi_0.w))
    {
        islands_0[params_0.halt_index_0].info_0[i32(2)] = ((islands_0[params_0.halt_index_0].info_0.z) | (u32(1)));
        return;
    }
    var _S110 : vec3<f32> = vec3<f32>(0.0f);
    var ledger_2 : vec4<f32> = contact_out_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_6];
    var _S111 : f32 = params_0.dt_0;
    var e_2 : u32 = cc_1.info_2.x;
    var f_3 : vec3<f32> = _S110;
    var t_2 : vec3<f32> = _S110;
    loop
    {
        if(e_2 < (cc_1.info_2.y))
        {
        }
        else
        {
            break;
        }
        var entry_3 : vec4<u32> = contact_static_0[e_2];
        var f_4 : vec3<f32>;
        var t_3 : vec3<f32>;
        if((entry_3.x) == u32(0))
        {
            var _S112 : u32 = u32(2) * entry_3.y;
            var t_4 : vec3<f32> = t_2 + contact_out_0[_S112 + u32(1)].xyz;
            f_4 = f_3 + contact_out_0[_S112].xyz;
            t_3 = t_4;
            e_2 = e_2 + u32(1);
            f_3 = f_4;
            t_2 = t_3;
            continue;
        }
        var above_0 : f32 = wp_0.hi_0.z - params_0.ground_hi_0 + (wp_0.lo_0.z - params_0.ground_lo_0) + wp_0.rel_0.z;
        if((above_0 - cc_1.half_0.w) > 0.0f)
        {
            f_4 = f_3;
            t_3 = t_2;
            e_2 = e_2 + u32(1);
            f_3 = f_4;
            t_2 = t_3;
            continue;
        }
        var b_14 : Box_0 = chunk_box_0(c_6, _S110);
        const _S113 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var _S114 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_14, cc_1.mat_0.x, b_14, _S113);
        var s_5 : u32 = u32(0);
        var n_8 : u32 = u32(0);
        loop
        {
            if(s_5 < u32(14))
            {
            }
            else
            {
                break;
            }
            if((above_0 + sample_point_0(b_14, s_5).z) < 0.0f)
            {
                n_8 = n_8 + u32(1);
            }
            s_5 = s_5 + u32(1);
        }
        var vc_1 : vec3<f32>;
        var wc_1 : vec3<f32>;
        chunk_velocity_0(c_6, &(vc_1), &(wc_1));
        var s_6 : u32 = u32(0);
        f_4 = f_3;
        t_3 = t_2;
        loop
        {
            if(s_6 < u32(14))
            {
            }
            else
            {
                break;
            }
            var p_8 : vec3<f32> = sample_point_0(b_14, s_6);
            var _S115 : f32 = above_0 + p_8.z;
            var depth_4 : f32 = - _S115;
            if(!(_S115 < 0.0f))
            {
                s_6 = s_6 + u32(1);
                continue;
            }
            var stored_4 : f32;
            var diss_3 : f32;
            var g_0 : vec3<f32> = penalty_force_0(_S114 / f32(max(n_8, u32(5))), cc_1.mat_0.z, params_0.ground_friction_0, depth_4, _S113, vc_1 + cross(wc_1, p_8), _S111, n_8, &(stored_4), &(diss_3));
            var f_5 : vec3<f32> = f_4 + g_0;
            var t_5 : vec3<f32> = t_3 + cross(p_8, g_0);
            var _S116 : f32 = ledger_2[i32(1)];
            var _S117 : f32 = ledger_2[i32(2)];
            comp_add1_0(&(_S116), &(_S117), diss_3);
            ledger_2[i32(1)] = _S116;
            ledger_2[i32(2)] = _S117;
            f_4 = f_5;
            t_3 = t_5;
            s_6 = s_6 + u32(1);
        }
        e_2 = e_2 + u32(1);
        f_3 = f_4;
        t_2 = t_3;
    }
    contact_out_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_6] = ledger_2;
    var _S118 : u32 = u32(2) * c_6;
    contact_out_0[params_0.loads_base_0 + _S118] = vec4<f32>(f_3, 0.0f);
    contact_out_0[params_0.loads_base_0 + _S118 + u32(1)] = vec4<f32>(t_2, 0.0f);
    return;
}

fn comp_add_0( sum_1 : ptr<function, vec3<f32>>,  err_1 : ptr<function, vec3<f32>>,  x_3 : vec3<f32>)
{
    var t_6 : vec3<f32> = (*sum_1) + x_3;
    var _S119 : vec3<f32> = abs(x_3);
    (*err_1) = (*err_1) + (select(x_3, (*sum_1), (abs((*sum_1))) >= _S119) - t_6 + select((*sum_1), x_3, (abs((*sum_1))) >= _S119));
    (*sum_1) = t_6;
    return;
}

fn inverse_rotate_0( q_9 : Quat_0,  v_4 : vec3<f32>) -> vec3<f32>
{
    var c_7 : Quat_0;
    c_7.w_0 = q_9.w_0;
    c_7.x_1 = - q_9.x_1;
    c_7.y_0 = - q_9.y_0;
    c_7.z_0 = - q_9.z_0;
    return rotate_0(c_7, v_4);
}

fn rows_mul_0( r0_0 : vec4<f32>,  r1_0 : vec4<f32>,  r2_0 : vec4<f32>,  v_5 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r0_0.xyz, v_5), dot(r1_0.xyz, v_5), dot(r2_0.xyz, v_5));
}

fn world_mul_0( q_10 : Quat_0,  r0_1 : vec4<f32>,  r1_1 : vec4<f32>,  r2_1 : vec4<f32>,  v_6 : vec3<f32>) -> vec3<f32>
{
    return rotate_0(q_10, rows_mul_0(r0_1, r1_1, r2_1, inverse_rotate_0(q_10, v_6)));
}

fn quat_mul_0( a_5 : Quat_0,  o_0 : Quat_0) -> Quat_0
{
    var r_3 : Quat_0;
    r_3.w_0 = a_5.w_0 * o_0.w_0 - a_5.x_1 * o_0.x_1 - a_5.y_0 * o_0.y_0 - a_5.z_0 * o_0.z_0;
    r_3.x_1 = a_5.w_0 * o_0.x_1 + a_5.x_1 * o_0.w_0 + a_5.y_0 * o_0.z_0 - a_5.z_0 * o_0.y_0;
    r_3.y_0 = a_5.w_0 * o_0.y_0 - a_5.x_1 * o_0.z_0 + a_5.y_0 * o_0.w_0 + a_5.z_0 * o_0.x_1;
    r_3.z_0 = a_5.w_0 * o_0.z_0 + a_5.x_1 * o_0.y_0 - a_5.y_0 * o_0.x_1 + a_5.z_0 * o_0.w_0;
    return r_3;
}

fn normalized_0( q_11 : Quat_0) -> Quat_0
{
    var _S120 : f32 = q_11.w_0;
    var _S121 : f32 = q_11.x_1;
    var _S122 : f32 = q_11.y_0;
    var _S123 : f32 = q_11.z_0;
    var n_9 : f32 = sqrt(_S120 * _S120 + _S121 * _S121 + _S122 * _S122 + _S123 * _S123);
    var r_4 : Quat_0;
    r_4.w_0 = q_11.w_0 / n_9;
    r_4.x_1 = q_11.x_1 / n_9;
    r_4.y_0 = q_11.y_0 / n_9;
    r_4.z_0 = q_11.z_0 / n_9;
    return r_4;
}

fn integrate_rotation_0( q_12 : Quat_0,  omega_0 : vec3<f32>,  dt_2 : f32) -> Quat_0
{
    var angle_1 : f32 = length(omega_0) * dt_2;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return q_12;
    }
    return normalized_0(quat_mul_0(from_axis_angle_0(omega_0, angle_1), q_12));
}

fn quat_vec_0( q_13 : Quat_0) -> vec4<f32>
{
    return vec4<f32>(q_13.x_1, q_13.y_0, q_13.z_0, q_13.w_0);
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_integrate(@builtin(workgroup_id) group_1 : vec3<u32>, @builtin(local_invocation_id) thread_1 : vec3<u32>)
{
    var ii_1 : u32 = group_1.x;
    var tid_2 : u32 = thread_1.x;
    if(ii_1 >= (params_0.impactor_count_0))
    {
        return;
    }
    var imp_4 : Impactor_0;
    imp_4.position_1 = impactors_0[ii_1].position_1;
    imp_4.position_err_1 = impactors_0[ii_1].position_err_1;
    imp_4.velocity_1 = impactors_0[ii_1].velocity_1;
    imp_4.velocity_err_1 = impactors_0[ii_1].velocity_err_1;
    imp_4.angular_velocity_1 = impactors_0[ii_1].angular_velocity_1;
    imp_4.rotation_1 = impactors_0[ii_1].rotation_1;
    imp_4.inertia0_2 = impactors_0[ii_1].inertia0_2;
    imp_4.inertia1_2 = impactors_0[ii_1].inertia1_2;
    imp_4.inertia2_2 = impactors_0[ii_1].inertia2_2;
    imp_4.inv0_2 = impactors_0[ii_1].inv0_2;
    imp_4.inv1_2 = impactors_0[ii_1].inv1_2;
    imp_4.inv2_2 = impactors_0[ii_1].inv2_2;
    imp_4.shape_0 = impactors_0[ii_1].shape_0;
    imp_4.half_1 = impactors_0[ii_1].half_1;
    imp_4.mat_1 = impactors_0[ii_1].mat_1;
    imp_4.crush_0 = impactors_0[ii_1].crush_0;
    imp_4.load_force_0 = impactors_0[ii_1].load_force_0;
    imp_4.load_torque_0 = impactors_0[ii_1].load_torque_0;
    imp_4.ledger_0 = impactors_0[ii_1].ledger_0;
    imp_4.cand_0 = impactors_0[ii_1].cand_0;
    var _S124 : bool;
    if((imp_4.cand_0.z) != u32(0))
    {
        _S124 = true;
    }
    else
    {
        _S124 = (((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0);
    }
    if(_S124)
    {
        _S124 = true;
    }
    else
    {
        var _S125 : u32 = islands_0[params_0.halt_index_0].info_0.y;
        if(_S125 != u32(0))
        {
            _S124 = (imp_4.cand_0.w) >= _S125;
        }
        else
        {
            _S124 = false;
        }
    }
    if(_S124)
    {
        return;
    }
    var _S126 : vec4<f32> = vec4<f32>(0.0f);
    var rf_0 : vec4<f32> = _S126;
    var rt_0 : vec4<f32> = _S126;
    var e_3 : u32 = imp_4.cand_0.x + tid_2;
    loop
    {
        if(e_3 < (imp_4.cand_0.y))
        {
        }
        else
        {
            break;
        }
        var _S127 : u32 = u32(3) * (e_3 - params_0.cand_begin_0);
        rf_0 = rf_0 + contact_out_0[params_0.cand_base_0 + _S127 + u32(1)];
        rt_0 = rt_0 + contact_out_0[params_0.cand_base_0 + _S127 + u32(2)];
        e_3 = e_3 + u32(256);
    }
    group_sum2_0(tid_2, &(rf_0), &(rt_0));
    if(tid_2 != u32(0))
    {
        return;
    }
    imp_4.cand_0[i32(3)] = imp_4.cand_0[i32(3)] + u32(1);
    var m_1 : f32 = imp_4.mat_1.z;
    var vel_0 : vec3<f32> = imp_4.velocity_1.xyz;
    var vel_err_0 : vec3<f32> = imp_4.velocity_err_1.xyz;
    var load_t_2 : vec3<f32> = rt_0.xyz + imp_4.load_torque_0.xyz;
    var _S128 : vec3<f32> = vec3<f32>(params_0.dt_0);
    comp_add_0(&(vel_0), &(vel_err_0), ((rf_0.xyz + imp_4.load_force_0.xyz) / vec3<f32>(m_1) + params_0.gravity_0.xyz) * _S128);
    var q_14 : Quat_0 = quat_of_0(imp_4.rotation_1);
    var l_1 : vec3<f32> = world_mul_0(q_14, imp_4.inertia0_2, imp_4.inertia1_2, imp_4.inertia2_2, imp_4.angular_velocity_1.xyz) + load_t_2 * _S128;
    var w_mid_0 : vec3<f32> = world_mul_0(q_14, imp_4.inv0_2, imp_4.inv1_2, imp_4.inv2_2, l_1);
    var pos_0 : vec3<f32> = imp_4.position_1.xyz;
    var pos_err_0 : vec3<f32> = imp_4.position_err_1.xyz;
    comp_add_0(&(pos_0), &(pos_err_0), (vel_0 + vel_err_0) * _S128);
    var q_15 : Quat_0 = integrate_rotation_0(q_14, w_mid_0, params_0.dt_0);
    imp_4.angular_velocity_1 = vec4<f32>(world_mul_0(q_15, imp_4.inv0_2, imp_4.inv1_2, imp_4.inv2_2, l_1), 0.0f);
    imp_4.rotation_1 = quat_vec_0(q_15);
    imp_4.position_1 = vec4<f32>(pos_0, 0.0f);
    imp_4.position_err_1 = vec4<f32>(pos_err_0, 0.0f);
    imp_4.velocity_1 = vec4<f32>(vel_0, 0.0f);
    imp_4.velocity_err_1 = vec4<f32>(vel_err_0, 0.0f);
    impactors_0[ii_1].position_1 = imp_4.position_1;
    impactors_0[ii_1].position_err_1 = imp_4.position_err_1;
    impactors_0[ii_1].velocity_1 = imp_4.velocity_1;
    impactors_0[ii_1].velocity_err_1 = imp_4.velocity_err_1;
    impactors_0[ii_1].angular_velocity_1 = imp_4.angular_velocity_1;
    impactors_0[ii_1].rotation_1 = imp_4.rotation_1;
    impactors_0[ii_1].inertia0_2 = imp_4.inertia0_2;
    impactors_0[ii_1].inertia1_2 = imp_4.inertia1_2;
    impactors_0[ii_1].inertia2_2 = imp_4.inertia2_2;
    impactors_0[ii_1].inv0_2 = imp_4.inv0_2;
    impactors_0[ii_1].inv1_2 = imp_4.inv1_2;
    impactors_0[ii_1].inv2_2 = imp_4.inv2_2;
    impactors_0[ii_1].shape_0 = imp_4.shape_0;
    impactors_0[ii_1].half_1 = imp_4.half_1;
    impactors_0[ii_1].mat_1 = imp_4.mat_1;
    impactors_0[ii_1].crush_0 = imp_4.crush_0;
    impactors_0[ii_1].load_force_0 = imp_4.load_force_0;
    impactors_0[ii_1].load_torque_0 = imp_4.load_torque_0;
    impactors_0[ii_1].ledger_0 = imp_4.ledger_0;
    impactors_0[ii_1].cand_0 = imp_4.cand_0;
    var k_5 : u32 = imp_4.cand_0.w - u32(1) - params_0.step_start_0;
    if(k_5 < (params_0.record_stride_0))
    {
        var at_0 : u32 = params_0.loads_base_0 + u32(2) * params_0.chunk_count_0 + u32(2) * (ii_1 * params_0.record_stride_0 + k_5);
        contact_out_0[at_0] = vec4<f32>(vel_0 + vel_err_0, 0.0f);
        contact_out_0[at_0 + u32(1)] = vec4<f32>(pos_0 + pos_err_0, 0.0f);
    }
    return;
}

