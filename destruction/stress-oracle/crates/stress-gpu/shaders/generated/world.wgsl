struct Params_std140_0
{
    @align(16) gravity_0 : vec4<f32>,
    @align(16) dt_0 : f32,
    @align(4) fracture_0 : u32,
    @align(8) rigid_motion_loads_0 : u32,
    @align(4) step_start_0 : u32,
    @align(16) t_hi_0 : f32,
    @align(4) t_lo_0 : f32,
    @align(8) max_steps_0 : u32,
    @align(4) contact_mode_0 : u32,
    @align(16) halt_index_0 : u32,
    @align(4) chunk_count_0 : u32,
    @align(8) pair_count_0 : u32,
    @align(4) impactor_count_0 : u32,
    @align(16) cand_count_0 : u32,
    @align(4) probe_base_0 : u32,
    @align(8) probe_stride_0 : u32,
    @align(4) slot_base_0 : u32,
    @align(16) ledger_base_0 : u32,
    @align(4) record_base_0 : u32,
    @align(8) record_stride_0 : u32,
    @align(4) cand_base_0 : u32,
    @align(16) pair_index_0 : u32,
    @align(4) cand_index_0 : u32,
    @align(8) zeta_0 : f32,
    @align(4) pair_friction_0 : f32,
    @align(16) ground_hi_0 : f32,
    @align(4) ground_lo_0 : f32,
    @align(8) ground_friction_0 : f32,
    @align(4) ground_modulus_0 : f32,
    @align(16) has_ground_0 : u32,
    @align(4) wide_bond_groups_0 : u32,
    @align(8) wide_bond_table_0 : u32,
    @align(4) wide_chunk_table_0 : u32,
    @align(16) wide_base_0 : u32,
    @align(4) seg_index_0 : u32,
    @align(8) seg_count_0 : u32,
    @align(4) seg_base_0 : u32,
    @align(16) pad0_0 : u32,
    @align(4) pad1_0 : u32,
    @align(8) pad2_0 : u32,
};

@binding(0) @group(0) var<uniform> params_0 : Params_std140_0;
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

@binding(9) @group(0) var<storage, read_write> islands_0 : array<Island_std430_0>;

@binding(4) @group(0) var<storage, read> index_0 : array<u32>;

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
    @align(16) half_0 : vec4<f32>,
    @align(16) crot0_0 : vec4<f32>,
    @align(16) crot1_0 : vec4<f32>,
    @align(16) crot2_0 : vec4<f32>,
    @align(16) cmat_0 : vec4<f32>,
    @align(16) start_hi_0 : vec4<f32>,
    @align(16) start_lo_0 : vec4<f32>,
    @align(16) cinfo_0 : vec4<u32>,
};

@binding(3) @group(0) var<storage, read> chunks_0 : array<ChunkStatic_std430_0>;

@binding(6) @group(0) var<storage, read_write> state_0 : array<vec4<f32>>;

@binding(8) @group(0) var<storage, read_write> scratch_0 : array<vec4<f32>>;

@binding(11) @group(0) var<storage, read_write> contact_state_0 : array<vec4<f32>>;

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
    @align(16) mat_0 : vec4<f32>,
    @align(16) crush_0 : vec4<f32>,
    @align(16) geom_0 : vec4<f32>,
    @align(16) unused_0 : vec4<f32>,
    @align(16) ledger_0 : vec4<f32>,
    @align(16) cand_0 : vec4<u32>,
};

@binding(10) @group(0) var<storage, read_write> impactors_0 : array<Impactor_std430_0>;

@binding(5) @group(0) var<storage, read> loads_0 : array<vec4<f32>>;

struct JointBond_std430_0
{
    @align(16) geom0_0 : vec4<f32>,
    @align(16) geom1_0 : vec4<f32>,
    @align(16) stiff0_0 : vec4<f32>,
    @align(16) stiff1_0 : vec4<f32>,
    @align(16) rebar0_0 : vec4<f32>,
    @align(16) rebar1_0 : vec4<f32>,
    @align(16) ids_0 : vec4<u32>,
};

struct BondStatic_std430_0
{
    @align(16) t1_0 : vec4<f32>,
    @align(16) t2_0 : vec4<f32>,
    @align(16) normal_0 : vec4<f32>,
    @align(16) ra_0 : vec4<f32>,
    @align(16) rb_0 : vec4<f32>,
    @align(16) centroid_0 : vec4<f32>,
    @align(16) c_lin_0 : vec4<f32>,
    @align(16) c_ang_0 : vec4<f32>,
    @align(16) law_0 : JointBond_std430_0,
};

@binding(2) @group(0) var<storage, read> bonds_0 : array<BondStatic_std430_0>;

struct JointState_std430_0
{
    @align(4) damage_0 : f32,
    @align(4) crush_1 : f32,
    @align(4) kappa_0 : f32,
    @align(4) kappa_c_0 : f32,
    @align(4) ductility_0 : f32,
    @align(4) ductility_c_0 : f32,
    @align(4) fatigue_0 : f32,
    @align(4) plastic_x_0 : f32,
    @align(4) plastic_y_0 : f32,
    @align(4) plastic_t_0 : f32,
    @align(4) rebar_plastic_0 : f32,
    @align(4) rebar_slip0_0 : f32,
    @align(4) rebar_slip1_0 : f32,
    @align(4) rebar_work_0 : f32,
    @align(4) rebar_broken_0 : f32,
    @align(4) strain_rate_0 : f32,
    @align(4) governing_stress_0 : f32,
    @align(4) dissipated_0 : f32,
    @align(4) utilization_0 : f32,
    @align(4) mode_0 : u32,
};

struct BondDyn_std430_0
{
    @align(16) js_0 : JointState_std430_0,
    @align(16) force_lin_0 : vec4<f32>,
    @align(16) force_ang_0 : vec4<f32>,
    @align(16) sums_0 : vec4<f32>,
    @align(16) comps_0 : vec4<f32>,
    @align(16) events_0 : vec4<u32>,
};

@binding(7) @group(0) var<storage, read_write> bond_dyn_0 : array<BondDyn_std430_0>;

struct JointMaterial_std140_0
{
    @align(16) strength_0 : vec4<f32>,
    @align(16) energy_1 : vec4<f32>,
    @align(16) dif_0 : vec4<f32>,
    @align(16) misc_0 : vec4<f32>,
    @align(16) kind_flags_0 : vec4<u32>,
};

struct _Array_std140_JointMaterial64_0
{
    @align(16) data_0 : array<JointMaterial_std140_0, i32(64)>,
};

struct MaterialTable_std140_0
{
    @align(16) m_0 : _Array_std140_JointMaterial64_0,
};

@binding(1) @group(0) var<uniform> materials_0 : MaterialTable_std140_0;
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
    var q_4 : Quat_0 = quat_of_0(islands_0[chunks_0[c_1].info_1.y].rotation_0);
    var th_0 : vec3<f32> = state_0[u32(4) * c_1 + u32(1)].xyz;
    var hidden_0 : Quat_0 = from_axis_angle_0(th_0, length(th_0));
    var b_1 : Box_0;
    b_1.center_1 = center_2;
    b_1.axis0_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.x, chunks_0[c_1].crot1_0.x, chunks_0[c_1].crot2_0.x)));
    b_1.axis1_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.y, chunks_0[c_1].crot1_0.y, chunks_0[c_1].crot2_0.y)));
    b_1.axis2_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.z, chunks_0[c_1].crot1_0.z, chunks_0[c_1].crot2_0.z)));
    b_1.half_2 = chunks_0[c_1].half_0.xyz;
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

fn penetration_0( b_5 : Box_0,  p_0 : vec3<f32>,  depth_0 : ptr<function, f32>,  normal_1 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_0) = 0.0f;
    (*normal_1) = vec3<f32>(0.0f);
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
    (*normal_1) = box_axis_0(b_5, axis_2) * vec3<f32>(side_0);
    return true;
}

fn penetration_1( b_6 : Box_0,  p_1 : vec3<f32>,  depth_1 : ptr<function, f32>,  normal_2 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_1) = 0.0f;
    (*normal_2) = vec3<f32>(0.0f);
    var r_2 : vec3<f32> = p_1 - b_6.center_1;
    var _S19 : vec3<f32> = b_6.half_2;
    if((dot(r_2, r_2)) > (dot(_S19, _S19) * 1.00001001358032227f))
    {
        return false;
    }
    var best_1 : f32 = 1.00000001504746622e+30f;
    var axis_3 : u32 = u32(0);
    var side_1 : f32 = 1.0f;
    var k_3 : u32 = u32(0);
    loop
    {
        if(k_3 < u32(3))
        {
        }
        else
        {
            break;
        }
        var local_1 : f32 = dot(r_2, box_axis_0(b_6, k_3));
        var d_1 : f32 = comp3_0(b_6.half_2, k_3) - abs(local_1);
        if(d_1 <= 0.0f)
        {
            return false;
        }
        if(d_1 < best_1)
        {
            var _S20 : f32;
            if(local_1 >= 0.0f)
            {
                _S20 = 1.0f;
            }
            else
            {
                _S20 = -1.0f;
            }
            best_1 = d_1;
            axis_3 = k_3;
            side_1 = _S20;
        }
        k_3 = k_3 + u32(1);
    }
    (*depth_1) = best_1;
    (*normal_2) = box_axis_0(b_6, axis_3) * vec3<f32>(side_1);
    return true;
}

fn half_thickness_and_area_0( b_7 : Box_0,  d_2 : vec3<f32>) -> vec2<f32>
{
    var k_4 : u32 = u32(0);
    var h_1 : f32 = 0.0f;
    var area_0 : f32 = 0.0f;
    loop
    {
        if(k_4 < u32(3))
        {
        }
        else
        {
            break;
        }
        var c_2 : f32 = abs(dot(d_2, box_axis_0(b_7, k_4)));
        var h_2 : f32 = h_1 + c_2 * comp3_0(b_7.half_2, k_4);
        var _S21 : u32 = k_4 + u32(1);
        var area_1 : f32 = area_0 + c_2 * 4.0f * comp3_0(b_7.half_2, _S21 % u32(3)) * comp3_0(b_7.half_2, (k_4 + u32(2)) % u32(3));
        k_4 = _S21;
        h_1 = h_2;
        area_0 = area_1;
    }
    return vec2<f32>(h_1, area_0);
}

fn contact_stiffness_0( ea_0 : f32,  a_3 : Box_0,  eb_0 : f32,  b_8 : Box_0,  dir_0 : vec3<f32>) -> f32
{
    var d_3 : vec3<f32> = safe_normalize_0(dir_0);
    var ta_0 : vec2<f32> = half_thickness_and_area_0(a_3, d_3);
    var tb_0 : vec2<f32> = half_thickness_and_area_0(b_8, d_3);
    return min(ta_0.y, tb_0.y) / (ta_0.x / ea_0 + tb_0.x / eb_0);
}

fn chunk_velocity_0( c_3 : u32,  v_3 : ptr<function, vec3<f32>>,  w_2 : ptr<function, vec3<f32>>)
{
    var q_5 : Quat_0 = quat_of_0(islands_0[chunks_0[c_3].info_1.y].rotation_0);
    var _S22 : u32 = u32(4) * c_3;
    var _S23 : vec3<f32> = islands_0[chunks_0[c_3].info_1.y].angular_velocity_0.xyz;
    (*v_3) = islands_0[chunks_0[c_3].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_3].info_1.y].velocity_err_0.xyz + cross(_S23, rotate_0(q_5, chunks_0[c_3].center_0.xyz + state_0[_S22].xyz - islands_0[chunks_0[c_3].info_1.y].com_0.xyz)) + rotate_0(q_5, state_0[_S22 + u32(2)].xyz);
    (*w_2) = _S23 + rotate_0(q_5, state_0[_S22 + u32(3)].xyz);
    return;
}

fn chunk_velocity_1( c_4 : u32,  v_4 : ptr<function, vec3<f32>>,  w_3 : ptr<function, vec3<f32>>)
{
    var q_6 : Quat_0 = quat_of_0(islands_0[chunks_0[c_4].info_1.y].rotation_0);
    var _S24 : u32 = u32(4) * c_4;
    var _S25 : vec3<f32> = islands_0[chunks_0[c_4].info_1.y].angular_velocity_0.xyz;
    (*v_4) = islands_0[chunks_0[c_4].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_4].info_1.y].velocity_err_0.xyz + cross(_S25, rotate_0(q_6, chunks_0[c_4].center_0.xyz + state_0[_S24].xyz - islands_0[chunks_0[c_4].info_1.y].com_0.xyz)) + rotate_0(q_6, state_0[_S24 + u32(2)].xyz);
    (*w_3) = _S25 + rotate_0(q_6, state_0[_S24 + u32(3)].xyz);
    return;
}

fn penalty_force_0( k_5 : f32,  m_red_0 : f32,  friction_0 : f32,  depth_2 : f32,  normal_3 : vec3<f32>,  rel_velocity_0 : vec3<f32>,  dt_1 : f32,  points_0 : u32,  stored_0 : ptr<function, f32>,  dissipated_1 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_0 : f32 = 1.0f / max(f32(points_0), 10.0f) * m_red_0 / dt_1;
    var vn_0 : f32 = dot(rel_velocity_0, normal_3);
    var _S26 : f32 = k_5 * depth_2;
    var _S27 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    var _S28 : f32 = _S26 - _S27;
    var _S29 : f32 = max(_S28, 0.0f);
    var vt_0 : vec3<f32> = rel_velocity_0 - normal_3 * vec3<f32>(vn_0);
    var vt_mag_0 : f32 = length(vt_0);
    var _S30 : f32 = friction_0 * _S29;
    var _S31 : f32 = min(_S30, min(c_max_0, _S30 / 0.00100000004749745f) * vt_mag_0);
    var ft_0 : vec3<f32>;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = (vec3<f32>(0) - vt_0) * vec3<f32>((_S31 / vt_mag_0));
    }
    else
    {
        ft_0 = vec3<f32>(0.0f);
    }
    (*stored_0) = 0.5f * k_5 * depth_2 * depth_2;
    var damping_power_0 : f32;
    if(_S28 > 0.0f)
    {
        damping_power_0 = _S27 * vn_0;
    }
    else
    {
        damping_power_0 = _S26 * max(vn_0, 0.0f);
    }
    (*dissipated_1) = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * vec3<f32>(_S29) + ft_0;
}

fn penalty_force_1( k_6 : f32,  m_red_1 : f32,  friction_1 : f32,  depth_3 : f32,  normal_4 : vec3<f32>,  rel_velocity_1 : vec3<f32>,  dt_2 : f32,  points_1 : u32,  stored_1 : ptr<function, f32>,  dissipated_2 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_1 : f32 = 1.0f / max(f32(points_1), 10.0f) * m_red_1 / dt_2;
    var vn_1 : f32 = dot(rel_velocity_1, normal_4);
    var _S32 : f32 = k_6 * depth_3;
    var _S33 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_6 * m_red_1), c_max_1) * vn_1;
    var _S34 : f32 = _S32 - _S33;
    var _S35 : f32 = max(_S34, 0.0f);
    var vt_1 : vec3<f32> = rel_velocity_1 - normal_4 * vec3<f32>(vn_1);
    var vt_mag_1 : f32 = length(vt_1);
    var _S36 : f32 = friction_1 * _S35;
    var _S37 : f32 = min(_S36, min(c_max_1, _S36 / 0.00100000004749745f) * vt_mag_1);
    var ft_1 : vec3<f32>;
    if(vt_mag_1 > 0.0f)
    {
        ft_1 = (vec3<f32>(0) - vt_1) * vec3<f32>((_S37 / vt_mag_1));
    }
    else
    {
        ft_1 = vec3<f32>(0.0f);
    }
    (*stored_1) = 0.5f * k_6 * depth_3 * depth_3;
    var damping_power_1 : f32;
    if(_S34 > 0.0f)
    {
        damping_power_1 = _S33 * vn_1;
    }
    else
    {
        damping_power_1 = _S32 * max(vn_1, 0.0f);
    }
    (*dissipated_2) = (damping_power_1 + length(ft_1) * vt_mag_1) * dt_2;
    return normal_4 * vec3<f32>(_S35) + ft_1;
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

fn comp_add1_1( sum_1 : ptr<function, f32>,  err_1 : ptr<function, f32>,  x_3 : f32)
{
    var t_2 : f32 = (*sum_1) + x_3;
    if((abs((*sum_1))) >= (abs(x_3)))
    {
        (*err_1) = (*err_1) + ((*sum_1) - t_2 + x_3);
    }
    else
    {
        (*err_1) = (*err_1) + (x_3 - t_2 + (*sum_1));
    }
    (*sum_1) = t_2;
    return;
}

fn comp_add1_2( sum_2 : ptr<function, f32>,  err_2 : ptr<function, f32>,  x_4 : f32)
{
    var t_3 : f32 = (*sum_2) + x_4;
    if((abs((*sum_2))) >= (abs(x_4)))
    {
        (*err_2) = (*err_2) + ((*sum_2) - t_3 + x_4);
    }
    else
    {
        (*err_2) = (*err_2) + (x_4 - t_3 + (*sum_2));
    }
    (*sum_2) = t_3;
    return;
}

fn pair_contact_0( i_2 : u32)
{
    var at_0 : u32 = params_0.pair_index_0 + u32(6) * i_2;
    var ca_0 : u32 = index_0[at_0];
    var cb_0 : u32 = index_0[at_0 + u32(1)];
    var _S38 : u32 = index_0[at_0 + u32(3)] * u32(28);
    var _S39 : f32 = (bitcast<f32>((index_0[at_0 + u32(4)])));
    var _S40 : f32 = (bitcast<f32>((index_0[at_0 + u32(5)])));
    var _S41 : f32 = params_0.dt_0;
    var out_0 : u32 = params_0.slot_base_0 + u32(2) * index_0[at_0 + u32(2)];
    var cb_rel_0 : vec3<f32> = world_diff_0(chunk_world_0(cb_0), chunk_world_0(ca_0));
    var touching_0 : bool = !((length(cb_rel_0)) > (chunks_0[ca_0].half_0.w + chunks_0[cb_0].half_0.w));
    var ledger_1 : vec4<f32> = scratch_0[params_0.ledger_base_0 + i_2];
    var flags_0 : u32 = (bitcast<u32>((scratch_0[params_0.ledger_base_0 + i_2].w)));
    var e_0 : u32;
    var has_state_0 : bool;
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
                contact_state_0[_S38 + e_0] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                e_0 = e_0 + u32(1);
            }
        }
        if(((flags_0 & (u32(2)))) != u32(0))
        {
            e_0 = u32(0);
            loop
            {
                if(e_0 < u32(4))
                {
                }
                else
                {
                    break;
                }
                scratch_0[out_0 + e_0] = vec4<f32>(0.0f);
                e_0 = e_0 + u32(1);
            }
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
            scratch_0[params_0.ledger_base_0 + i_2] = ledger_1;
        }
        return;
    }
    var _S42 : vec3<f32> = vec3<f32>(0.0f);
    var ba_0 : Box_0 = chunk_box_0(ca_0, _S42);
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
            var p_2 : vec3<f32> = sample_point_0(ba_0, s_1);
            var d_4 : f32;
            var n_1 : vec3<f32>;
            var _S43 : bool = penetration_0(bb_0, p_2, &(d_4), &(n_1));
            if(_S43)
            {
                pts_0[count_0] = p_2;
                nrm_0[count_0] = n_1;
                dep_0[count_0] = d_4;
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
            var p_3 : vec3<f32> = sample_point_0(bb_0, s_1);
            var d_5 : f32;
            var n_2 : vec3<f32>;
            var _S44 : bool = penetration_0(ba_0, p_3, &(d_5), &(n_2));
            if(_S44)
            {
                pts_0[count_0] = p_3;
                nrm_0[count_0] = (vec3<f32>(0) - n_2);
                dep_0[count_0] = d_5;
                idx_0[count_0] = u32(14) + s_1;
                count_0 = count_0 + u32(1);
            }
            s_1 = s_1 + u32(1);
        }
        if(count_0 > u32(0))
        {
            var k_pair_0 : f32 = contact_stiffness_0(chunks_0[ca_0].cmat_0.x, ba_0, chunks_0[cb_0].cmat_0.x, bb_0, bb_0.center_1 - ba_0.center_1);
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
                var _S45 : u32 = _S38 + idx_0[j_0];
                var entry_0 : vec4<f32> = contact_state_0[_S45];
                var p_4 : vec3<f32> = pts_0[j_0];
                var n_3 : vec3<f32> = nrm_0[j_0];
                if(isnan_0(contact_state_0[_S45].x))
                {
                    has_state_0 = true;
                }
                else
                {
                    has_state_0 = (dot(entry_0.yzw, n_3)) < 0.99000000953674316f;
                }
                if(has_state_0)
                {
                    if((dep_0[j_0]) > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - bb_0.center_1)), n_3)) * _S41 + 9.99999971718068537e-10f))
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
                contact_state_0[_S45] = entry_0;
                var _S46 : f32 = dep_0[j_0] - entry_0.x;
                eff_0[j_0] = _S46;
                if(_S46 > 0.0f)
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
                    contact_state_0[_S38 + e_0] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                }
                e_0 = e_0 + u32(1);
            }
            var _S47 : f32 = k_pair_0 / max(f32(engaged_0), 10.0f);
            j_0 = u32(0);
            fa_0 = _S42;
            ta_1 = _S42;
            fb_0 = _S42;
            tb_1 = _S42;
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
                var _S48 : vec3<f32> = pts_0[j_0] - bb_0.center_1;
                var stored_2 : f32;
                var diss_0 : f32;
                var f_0 : vec3<f32> = penalty_force_0(_S47, _S39, _S40, eff_0[j_0], nrm_0[j_0], va0_0 + cross(wa0_0, pts_0[j_0]) - (vb0_0 + cross(wb0_0, _S48)), _S41, engaged_0, &(stored_2), &(diss_0));
                var fa_1 : vec3<f32> = fa_0 + f_0;
                var ta_2 : vec3<f32> = ta_1 + cross(pts_0[j_0], f_0);
                var _S49 : vec3<f32> = (vec3<f32>(0) - f_0);
                var fb_1 : vec3<f32> = fb_0 + _S49;
                var tb_2 : vec3<f32> = tb_1 + cross(_S48, _S49);
                var stored_sum_1 : f32 = stored_sum_0 + stored_2;
                var _S50 : f32 = ledger_1[i32(1)];
                var _S51 : f32 = ledger_1[i32(2)];
                comp_add1_1(&(_S50), &(_S51), diss_0);
                ledger_1[i32(1)] = _S50;
                ledger_1[i32(2)] = _S51;
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
            fa_0 = _S42;
            ta_1 = _S42;
            fb_0 = _S42;
            tb_1 = _S42;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S42;
        ta_1 = _S42;
        fb_0 = _S42;
        tb_1 = _S42;
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
            contact_state_0[_S38 + e_0] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
            e_0 = e_0 + u32(1);
        }
    }
    var _S52 : vec3<f32> = vec3<f32>(0.0f);
    if((any((fa_0 != _S52))))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((ta_1 != _S52)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((fb_0 != _S52)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((tb_1 != _S52)));
    }
    var _S53 : bool;
    if(loaded_0)
    {
        _S53 = true;
    }
    else
    {
        _S53 = ((flags_0 & (u32(2)))) != u32(0);
    }
    if(_S53)
    {
        scratch_0[out_0] = vec4<f32>(fa_0, 0.0f);
        scratch_0[out_0 + u32(1)] = vec4<f32>(ta_1, 0.0f);
        scratch_0[out_0 + u32(2)] = vec4<f32>(fb_0, 0.0f);
        scratch_0[out_0 + u32(3)] = vec4<f32>(tb_1, 0.0f);
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
    scratch_0[params_0.ledger_base_0 + i_2] = ledger_1;
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
     mat_0 : vec4<f32>,
     crush_0 : vec4<f32>,
     geom_0 : vec4<f32>,
     unused_0 : vec4<f32>,
     ledger_0 : vec4<f32>,
     cand_0 : vec4<u32>,
};

fn impactor_box_0( imp_0 : Impactor_0,  center_3 : vec3<f32>,  half_3 : vec3<f32>) -> Box_0
{
    var q_7 : Quat_0 = quat_of_0(imp_0.rotation_1);
    var b_9 : Box_0;
    b_9.center_1 = center_3;
    b_9.axis0_0 = rotate_0(q_7, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_9.axis1_0 = rotate_0(q_7, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_9.axis2_0 = rotate_0(q_7, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_9.half_2 = half_3;
    return b_9;
}

fn sphere_contact_0( b_10 : Box_0,  center_4 : vec3<f32>,  radius_0 : f32,  point_0 : ptr<function, vec3<f32>>,  normal_5 : ptr<function, vec3<f32>>,  depth_4 : ptr<function, f32>) -> bool
{
    var _S54 : vec3<f32> = vec3<f32>(0.0f);
    (*point_0) = _S54;
    (*normal_5) = _S54;
    (*depth_4) = 0.0f;
    var r_3 : vec3<f32> = center_4 - b_10.center_1;
    var local_2 : vec3<f32> = vec3<f32>(dot(r_3, b_10.axis0_0), dot(r_3, b_10.axis1_0), dot(r_3, b_10.axis2_0));
    var q_8 : vec3<f32> = clamp(local_2, (vec3<f32>(0) - b_10.half_2), b_10.half_2);
    var d_6 : vec3<f32> = local_2 - q_8;
    var dist_0 : f32 = length(d_6);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        var dn_0 : vec3<f32> = d_6 / vec3<f32>(dist_0);
        (*normal_5) = b_10.axis0_0 * vec3<f32>(dn_0.x) + b_10.axis1_0 * vec3<f32>(dn_0.y) + b_10.axis2_0 * vec3<f32>(dn_0.z);
        (*point_0) = b_10.center_1 + b_10.axis0_0 * vec3<f32>(q_8.x) + b_10.axis1_0 * vec3<f32>(q_8.y) + b_10.axis2_0 * vec3<f32>(q_8.z);
        (*depth_4) = radius_0 - dist_0;
        return true;
    }
    var inside_0 : f32;
    var n_4 : vec3<f32>;
    var _S55 : bool = penetration_1(b_10, center_4, &(inside_0), &(n_4));
    if(!_S55)
    {
        return false;
    }
    (*normal_5) = n_4;
    (*point_0) = center_4 - n_4 * vec3<f32>(min(radius_0, inside_0));
    (*depth_4) = radius_0 + inside_0;
    return true;
}

fn impactor_point_0( _S56 : u32) -> WorldPoint_0
{
    var wi_0 : WorldPoint_0;
    wi_0.hi_0 = impactors_0[_S56].position_1.xyz;
    wi_0.lo_0 = impactors_0[_S56].position_err_1.xyz;
    wi_0.rel_0 = vec3<f32>(0.0f);
    return wi_0;
}

fn impactor_box_1( _S57 : u32,  _S58 : vec3<f32>,  _S59 : vec3<f32>) -> Box_0
{
    var q_9 : Quat_0 = quat_of_0(impactors_0[_S57].rotation_1);
    var b_11 : Box_0;
    b_11.center_1 = _S58;
    b_11.axis0_0 = rotate_0(q_9, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_11.axis1_0 = rotate_0(q_9, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_11.axis2_0 = rotate_0(q_9, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_11.half_2 = _S59;
    return b_11;
}

fn impactor_points_0( _S60 : u32,  _S61 : f32,  _S62 : Box_0,  _S63 : Box_0,  _S64 : ptr<function, array<vec3<f32>, i32(28)>>,  _S65 : ptr<function, array<vec3<f32>, i32(28)>>,  _S66 : ptr<function, array<f32, i32(28)>>) -> u32
{
    var _S67 : vec4<f32> = impactors_0[_S60].shape_0;
    var count_1 : u32;
    if((impactors_0[_S60].shape_0.x) == 0.0f)
    {
        var p_5 : vec3<f32>;
        var n_5 : vec3<f32>;
        var d_7 : f32;
        var _S68 : bool = sphere_contact_0(_S63, vec3<f32>(0.0f), _S67.y - _S61, &(p_5), &(n_5), &(d_7));
        if(_S68)
        {
            (*_S64)[i32(0)] = p_5;
            (*_S65)[i32(0)] = (vec3<f32>(0) - n_5);
            (*_S66)[i32(0)] = d_7;
            count_1 = u32(1);
        }
        else
        {
            count_1 = u32(0);
        }
        return count_1;
    }
    var shrunk_0 : Box_0 = _S62;
    shrunk_0.half_2 = _S62.half_2 - min(vec3<f32>(_S61), _S62.half_2 * vec3<f32>(0.5f));
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
        var p_6 : vec3<f32> = sample_point_0(_S63, s_2);
        var d_8 : f32;
        var n_6 : vec3<f32>;
        var _S69 : bool = penetration_1(shrunk_0, p_6, &(d_8), &(n_6));
        if(_S69)
        {
            (*_S64)[count_1] = p_6;
            (*_S65)[count_1] = n_6;
            (*_S66)[count_1] = d_8;
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
        var p_7 : vec3<f32> = sample_point_0(shrunk_0, s_2);
        var d_9 : f32;
        var n_7 : vec3<f32>;
        var _S70 : bool = penetration_1(_S63, p_7, &(d_9), &(n_7));
        if(_S70)
        {
            (*_S64)[count_1] = p_7;
            (*_S65)[count_1] = (vec3<f32>(0) - n_7);
            (*_S66)[count_1] = d_9;
            count_1 = count_1 + u32(1);
        }
        s_2 = s_2 + u32(1);
    }
    return count_1;
}

fn impactor_candidate_forces_0( k_7 : u32)
{
    var _S71 : u32 = u32(3) * k_7;
    var at_1 : u32 = params_0.cand_index_0 + _S71;
    var c_5 : u32 = index_0[at_1];
    var slot_0 : u32 = index_0[at_1 + u32(1)];
    var _S72 : u32 = index_0[at_1 + u32(2)];
    var imp_1 : Impactor_std430_0 = impactors_0[_S72];
    var _S73 : f32 = params_0.dt_0;
    var _S74 : vec3<f32> = vec3<f32>(0.0f);
    var data_1 : vec4<f32> = scratch_0[params_0.cand_base_0 + _S71];
    var f_sum_0 : vec3<f32>;
    var t_sum_0 : vec3<f32>;
    var imp_f_0 : vec3<f32>;
    var imp_t_0 : vec3<f32>;
    if((impactors_0[_S72].cand_0.z) == u32(0))
    {
        var rel_1 : vec3<f32> = world_diff_0(chunk_world_0(c_5), impactor_point_0(_S72));
        if(!((length(rel_1)) > (imp_1.half_1.w + chunks_0[c_5].half_0.w)))
        {
            var _S75 : Box_0 = impactor_box_1(_S72, _S74, imp_1.half_1.xyz);
            var b_12 : Box_0 = chunk_box_0(c_5, rel_1);
            var kc_0 : f32 = contact_stiffness_0(imp_1.mat_0.x, _S75, chunks_0[c_5].cmat_0.x, b_12, b_12.center_1 - _S75.center_1);
            var pts_1 : array<vec3<f32>, i32(28)>;
            var nrm_1 : array<vec3<f32>, i32(28)>;
            var dep_1 : array<f32, i32(28)>;
            var _S76 : u32 = impactor_points_0(_S72, imp_1.geom_0.y, _S75, b_12, &(pts_1), &(nrm_1), &(dep_1));
            var _S77 : bool = (imp_1.shape_0.x) == 0.0f;
            var _S78 : f32;
            if(_S77)
            {
                _S78 = kc_0;
            }
            else
            {
                _S78 = kc_0 / max(f32(_S76), 10.0f);
            }
            var _S79 : u32;
            if(_S77)
            {
                _S79 = u32(1);
            }
            else
            {
                _S79 = _S76;
            }
            var m_1 : f32 = chunks_0[c_5].center_0.w;
            var _S80 : f32 = imp_1.mat_0.z;
            var _S81 : f32 = m_1 * _S80 / (m_1 + _S80);
            var _S82 : f32;
            if((params_0.pair_friction_0) >= 0.0f)
            {
                _S82 = params_0.pair_friction_0;
            }
            else
            {
                _S82 = min(imp_1.mat_0.y, chunks_0[c_5].cmat_0.y);
            }
            var _S83 : vec3<f32> = imp_1.velocity_1.xyz + imp_1.velocity_err_1.xyz;
            var vc_0 : vec3<f32>;
            var wc_0 : vec3<f32>;
            chunk_velocity_0(c_5, &(vc_0), &(wc_0));
            var j_1 : u32 = u32(0);
            f_sum_0 = _S74;
            t_sum_0 = _S74;
            imp_f_0 = _S74;
            imp_t_0 = _S74;
            loop
            {
                if(j_1 < _S76)
                {
                }
                else
                {
                    break;
                }
                var _S84 : vec3<f32> = pts_1[j_1] - b_12.center_1;
                var stored_3 : f32;
                var diss_1 : f32;
                var f_1 : vec3<f32> = penalty_force_0(_S78, _S81, _S82, dep_1[j_1] * imp_1.geom_0.x, nrm_1[j_1], vc_0 + cross(wc_0, _S84) - (_S83 + cross(imp_1.angular_velocity_1.xyz, pts_1[j_1])), _S73, _S79, &(stored_3), &(diss_1));
                var f_sum_1 : vec3<f32> = f_sum_0 + f_1;
                var t_sum_1 : vec3<f32> = t_sum_0 + cross(_S84, f_1);
                var imp_f_1 : vec3<f32> = imp_f_0 - f_1;
                var imp_t_1 : vec3<f32> = imp_t_0 - cross(pts_1[j_1], f_1);
                var _S85 : f32 = data_1[i32(2)];
                var _S86 : f32 = data_1[i32(3)];
                comp_add1_1(&(_S85), &(_S86), diss_1);
                data_1[i32(2)] = _S85;
                data_1[i32(3)] = _S86;
                j_1 = j_1 + u32(1);
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
            }
        }
        else
        {
            f_sum_0 = _S74;
            t_sum_0 = _S74;
            imp_f_0 = _S74;
            imp_t_0 = _S74;
        }
    }
    else
    {
        f_sum_0 = _S74;
        t_sum_0 = _S74;
        imp_f_0 = _S74;
        imp_t_0 = _S74;
    }
    var _S87 : u32 = u32(2) * slot_0;
    scratch_0[params_0.slot_base_0 + _S87] = vec4<f32>(f_sum_0, 0.0f);
    scratch_0[params_0.slot_base_0 + _S87 + u32(1)] = vec4<f32>(t_sum_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S71] = data_1;
    scratch_0[params_0.cand_base_0 + _S71 + u32(1)] = vec4<f32>(imp_f_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S71 + u32(2)] = vec4<f32>(imp_t_0, 0.0f);
    return;
}

fn travel_check_0( c_6 : u32)
{
    if((chunks_0[c_6].cinfo_0.z) == u32(0))
    {
        return;
    }
    var wp_0 : WorldPoint_0 = chunk_world_0(c_6);
    if((length(wp_0.hi_0 - chunks_0[c_6].start_hi_0.xyz + (wp_0.lo_0 - chunks_0[c_6].start_lo_0.xyz) + wp_0.rel_0)) > (chunks_0[c_6].start_hi_0.w))
    {
        islands_0[params_0.halt_index_0].info_0[i32(2)] = ((islands_0[params_0.halt_index_0].info_0.z) | (u32(1)));
    }
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn contact_forces(@builtin(global_invocation_id) id_0 : vec3<u32>)
{
    var i_3 : u32 = id_0.x;
    if(stopped_0())
    {
        return;
    }
    if(i_3 < (params_0.pair_count_0))
    {
        pair_contact_0(i_3);
    }
    else
    {
        if(i_3 < (params_0.pair_count_0 + params_0.cand_count_0))
        {
            impactor_candidate_forces_0(i_3 - params_0.pair_count_0);
        }
        else
        {
            if(i_3 < (params_0.pair_count_0 + params_0.cand_count_0 + params_0.chunk_count_0))
            {
                travel_check_0(i_3 - params_0.pair_count_0 - params_0.cand_count_0);
            }
        }
    }
    return;
}

fn impactor_points_1( _S88 : u32,  _S89 : f32,  _S90 : Box_0,  _S91 : Box_0,  _S92 : ptr<function, array<vec3<f32>, i32(28)>>,  _S93 : ptr<function, array<vec3<f32>, i32(28)>>,  _S94 : ptr<function, array<f32, i32(28)>>) -> u32
{
    var _S95 : vec4<f32> = impactors_0[_S88].shape_0;
    var count_2 : u32;
    if((impactors_0[_S88].shape_0.x) == 0.0f)
    {
        var p_8 : vec3<f32>;
        var n_8 : vec3<f32>;
        var d_10 : f32;
        var _S96 : bool = sphere_contact_0(_S91, vec3<f32>(0.0f), _S95.y - _S89, &(p_8), &(n_8), &(d_10));
        if(_S96)
        {
            (*_S92)[i32(0)] = p_8;
            (*_S93)[i32(0)] = (vec3<f32>(0) - n_8);
            (*_S94)[i32(0)] = d_10;
            count_2 = u32(1);
        }
        else
        {
            count_2 = u32(0);
        }
        return count_2;
    }
    var shrunk_1 : Box_0 = _S90;
    shrunk_1.half_2 = _S90.half_2 - min(vec3<f32>(_S89), _S90.half_2 * vec3<f32>(0.5f));
    var s_3 : u32 = u32(0);
    count_2 = u32(0);
    loop
    {
        if(s_3 < u32(14))
        {
        }
        else
        {
            break;
        }
        var p_9 : vec3<f32> = sample_point_0(_S91, s_3);
        var d_11 : f32;
        var n_9 : vec3<f32>;
        var _S97 : bool = penetration_1(shrunk_1, p_9, &(d_11), &(n_9));
        if(_S97)
        {
            (*_S92)[count_2] = p_9;
            (*_S93)[count_2] = n_9;
            (*_S94)[count_2] = d_11;
            count_2 = count_2 + u32(1);
        }
        s_3 = s_3 + u32(1);
    }
    s_3 = u32(0);
    loop
    {
        if(s_3 < u32(14))
        {
        }
        else
        {
            break;
        }
        var p_10 : vec3<f32> = sample_point_0(shrunk_1, s_3);
        var d_12 : f32;
        var n_10 : vec3<f32>;
        var _S98 : bool = penetration_1(_S91, p_10, &(d_12), &(n_10));
        if(_S98)
        {
            (*_S92)[count_2] = p_10;
            (*_S93)[count_2] = (vec3<f32>(0) - n_10);
            (*_S94)[count_2] = d_12;
            count_2 = count_2 + u32(1);
        }
        s_3 = s_3 + u32(1);
    }
    return count_2;
}

@compute
@workgroup_size(64, 1, 1)
fn impactor_shares(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var k_8 : u32 = id_1.x;
    var _S99 : bool;
    if(k_8 >= (params_0.cand_count_0))
    {
        _S99 = true;
    }
    else
    {
        _S99 = stopped_0();
    }
    if(_S99)
    {
        return;
    }
    var _S100 : u32 = u32(3) * k_8;
    var at_2 : u32 = params_0.cand_index_0 + _S100;
    var c_7 : u32 = index_0[at_2];
    var _S101 : u32 = index_0[at_2 + u32(2)];
    var imp_2 : Impactor_std430_0 = impactors_0[_S101];
    if((impactors_0[_S101].cand_0.z) == u32(0))
    {
        _S99 = (imp_2.crush_0.x) > 0.0f;
    }
    else
    {
        _S99 = false;
    }
    var total_0 : f32;
    var ksum_0 : f32;
    if(_S99)
    {
        var rel_2 : vec3<f32> = world_diff_0(chunk_world_0(c_7), impactor_point_0(_S101));
        if(!((length(rel_2)) > (imp_2.half_1.w + chunks_0[c_7].half_0.w)))
        {
            var _S102 : Box_0 = impactor_box_1(_S101, vec3<f32>(0.0f), imp_2.half_1.xyz);
            var b_13 : Box_0 = chunk_box_0(c_7, rel_2);
            var kc_1 : f32 = contact_stiffness_0(imp_2.mat_0.x, _S102, chunks_0[c_7].cmat_0.x, b_13, b_13.center_1 - _S102.center_1);
            var pts_2 : array<vec3<f32>, i32(28)>;
            var nrm_2 : array<vec3<f32>, i32(28)>;
            var dep_2 : array<f32, i32(28)>;
            var _S103 : u32 = impactor_points_1(_S101, imp_2.crush_0.w, _S102, b_13, &(pts_2), &(nrm_2), &(dep_2));
            var _S104 : f32;
            if((imp_2.shape_0.x) == 0.0f)
            {
                _S104 = kc_1;
            }
            else
            {
                _S104 = kc_1 / max(f32(_S103), 10.0f);
            }
            var j_2 : u32 = u32(0);
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            loop
            {
                if(j_2 < _S103)
                {
                }
                else
                {
                    break;
                }
                var total_1 : f32 = total_0 + _S104 * dep_2[j_2];
                var ksum_1 : f32 = ksum_0 + _S104;
                j_2 = j_2 + u32(1);
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
    scratch_0[params_0.cand_base_0 + _S100] = vec4<f32>(total_0, ksum_0, scratch_0[params_0.cand_base_0 + _S100].z, scratch_0[params_0.cand_base_0 + _S100].w);
    return;
}

var<workgroup> g_red_a_0 : array<vec4<f32>, i32(256)>;

var<workgroup> g_red_b_0 : array<vec4<f32>, i32(256)>;

fn group_sum2_0( tid_0 : u32,  a_4 : ptr<function, vec4<f32>>,  b_14 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_0] = (*a_4);
    g_red_b_0[tid_0] = (*b_14);
    workgroupBarrier();
    var s_4 : u32 = u32(128);
    loop
    {
        if(s_4 > u32(0))
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_4)
        {
            var _S105 : u32 = tid_0 + s_4;
            g_red_a_0[tid_0] = g_red_a_0[tid_0] + g_red_a_0[_S105];
            g_red_b_0[tid_0] = g_red_b_0[tid_0] + g_red_b_0[_S105];
        }
        workgroupBarrier();
        s_4 = (s_4 >> (u32(1)));
    }
    (*a_4) = g_red_a_0[i32(0)];
    (*b_14) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_crush(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var ii_0 : u32 = group_0.x;
    var tid_1 : u32 = thread_0.x;
    var _S106 : bool;
    if(ii_0 >= (params_0.impactor_count_0))
    {
        _S106 = true;
    }
    else
    {
        _S106 = stopped_0();
    }
    if(_S106)
    {
        return;
    }
    var imp_3 : Impactor_0;
    imp_3.position_1 = impactors_0[ii_0].position_1;
    imp_3.position_err_1 = impactors_0[ii_0].position_err_1;
    imp_3.velocity_1 = impactors_0[ii_0].velocity_1;
    imp_3.velocity_err_1 = impactors_0[ii_0].velocity_err_1;
    imp_3.angular_velocity_1 = impactors_0[ii_0].angular_velocity_1;
    imp_3.rotation_1 = impactors_0[ii_0].rotation_1;
    imp_3.inertia0_2 = impactors_0[ii_0].inertia0_2;
    imp_3.inertia1_2 = impactors_0[ii_0].inertia1_2;
    imp_3.inertia2_2 = impactors_0[ii_0].inertia2_2;
    imp_3.inv0_2 = impactors_0[ii_0].inv0_2;
    imp_3.inv1_2 = impactors_0[ii_0].inv1_2;
    imp_3.inv2_2 = impactors_0[ii_0].inv2_2;
    imp_3.shape_0 = impactors_0[ii_0].shape_0;
    imp_3.half_1 = impactors_0[ii_0].half_1;
    imp_3.mat_0 = impactors_0[ii_0].mat_0;
    imp_3.crush_0 = impactors_0[ii_0].crush_0;
    imp_3.geom_0 = impactors_0[ii_0].geom_0;
    imp_3.unused_0 = impactors_0[ii_0].unused_0;
    imp_3.ledger_0 = impactors_0[ii_0].ledger_0;
    imp_3.cand_0 = impactors_0[ii_0].cand_0;
    var _S107 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S107;
    var unused_1 : vec4<f32> = _S107;
    var k_9 : u32 = imp_3.cand_0.x + tid_1;
    loop
    {
        if(k_9 < (imp_3.cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + scratch_0[params_0.cand_base_0 + u32(3) * k_9];
        k_9 = k_9 + u32(256);
    }
    group_sum2_0(tid_1, &(shares_0), &(unused_1));
    if(tid_1 != u32(0))
    {
        _S106 = true;
    }
    else
    {
        _S106 = (imp_3.cand_0.z) != u32(0);
    }
    if(_S106)
    {
        return;
    }
    imp_3.geom_0 = vec4<f32>(1.0f, imp_3.crush_0.w, 0.0f, 0.0f);
    var total_2 : f32 = shares_0.x;
    if((imp_3.crush_0.x) > 0.0f)
    {
        _S106 = (imp_3.crush_0.z) < (imp_3.crush_0.y);
    }
    else
    {
        _S106 = false;
    }
    if(_S106)
    {
        _S106 = total_2 > (imp_3.crush_0.x);
    }
    else
    {
        _S106 = false;
    }
    if(_S106)
    {
        var extra_0 : f32 = (total_2 - imp_3.crush_0.x) / shares_0.y;
        imp_3.crush_0[i32(3)] = imp_3.crush_0[i32(3)] + extra_0;
        imp_3.crush_0[i32(2)] = imp_3.crush_0[i32(2)] + imp_3.crush_0.x * extra_0;
        var _S108 : f32 = imp_3.crush_0.x * extra_0;
        var _S109 : f32 = imp_3.ledger_0[i32(2)];
        var _S110 : f32 = imp_3.ledger_0[i32(3)];
        comp_add1_2(&(_S109), &(_S110), _S108);
        imp_3.ledger_0[i32(2)] = _S109;
        imp_3.ledger_0[i32(3)] = _S110;
        var _S111 : f32 = imp_3.crush_0.x * extra_0;
        var _S112 : f32 = imp_3.ledger_0[i32(0)];
        var _S113 : f32 = imp_3.ledger_0[i32(1)];
        comp_add1_2(&(_S112), &(_S113), _S111);
        imp_3.ledger_0[i32(0)] = _S112;
        imp_3.ledger_0[i32(1)] = _S113;
        imp_3.geom_0[i32(0)] = imp_3.crush_0.x / total_2;
    }
    impactors_0[ii_0].position_1 = imp_3.position_1;
    impactors_0[ii_0].position_err_1 = imp_3.position_err_1;
    impactors_0[ii_0].velocity_1 = imp_3.velocity_1;
    impactors_0[ii_0].velocity_err_1 = imp_3.velocity_err_1;
    impactors_0[ii_0].angular_velocity_1 = imp_3.angular_velocity_1;
    impactors_0[ii_0].rotation_1 = imp_3.rotation_1;
    impactors_0[ii_0].inertia0_2 = imp_3.inertia0_2;
    impactors_0[ii_0].inertia1_2 = imp_3.inertia1_2;
    impactors_0[ii_0].inertia2_2 = imp_3.inertia2_2;
    impactors_0[ii_0].inv0_2 = imp_3.inv0_2;
    impactors_0[ii_0].inv1_2 = imp_3.inv1_2;
    impactors_0[ii_0].inv2_2 = imp_3.inv2_2;
    impactors_0[ii_0].shape_0 = imp_3.shape_0;
    impactors_0[ii_0].half_1 = imp_3.half_1;
    impactors_0[ii_0].mat_0 = imp_3.mat_0;
    impactors_0[ii_0].crush_0 = imp_3.crush_0;
    impactors_0[ii_0].geom_0 = imp_3.geom_0;
    impactors_0[ii_0].unused_0 = imp_3.unused_0;
    impactors_0[ii_0].ledger_0 = imp_3.ledger_0;
    impactors_0[ii_0].cand_0 = imp_3.cand_0;
    return;
}

fn comp_add_0( sum_3 : ptr<function, vec3<f32>>,  err_3 : ptr<function, vec3<f32>>,  x_5 : vec3<f32>)
{
    var t_4 : vec3<f32> = (*sum_3) + x_5;
    var _S114 : vec3<f32> = abs(x_5);
    (*err_3) = (*err_3) + (select(x_5, (*sum_3), (abs((*sum_3))) >= _S114) - t_4 + select((*sum_3), x_5, (abs((*sum_3))) >= _S114));
    (*sum_3) = t_4;
    return;
}

fn inverse_rotate_0( q_10 : Quat_0,  v_5 : vec3<f32>) -> vec3<f32>
{
    var c_8 : Quat_0;
    c_8.w_0 = q_10.w_0;
    c_8.x_1 = - q_10.x_1;
    c_8.y_0 = - q_10.y_0;
    c_8.z_0 = - q_10.z_0;
    return rotate_0(c_8, v_5);
}

fn rows_mul_0( r0_0 : vec4<f32>,  r1_0 : vec4<f32>,  r2_0 : vec4<f32>,  v_6 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r0_0.xyz, v_6), dot(r1_0.xyz, v_6), dot(r2_0.xyz, v_6));
}

fn world_mul_0( q_11 : Quat_0,  r0_1 : vec4<f32>,  r1_1 : vec4<f32>,  r2_1 : vec4<f32>,  v_7 : vec3<f32>) -> vec3<f32>
{
    return rotate_0(q_11, rows_mul_0(r0_1, r1_1, r2_1, inverse_rotate_0(q_11, v_7)));
}

fn quat_mul_0( a_5 : Quat_0,  o_0 : Quat_0) -> Quat_0
{
    var r_4 : Quat_0;
    r_4.w_0 = a_5.w_0 * o_0.w_0 - a_5.x_1 * o_0.x_1 - a_5.y_0 * o_0.y_0 - a_5.z_0 * o_0.z_0;
    r_4.x_1 = a_5.w_0 * o_0.x_1 + a_5.x_1 * o_0.w_0 + a_5.y_0 * o_0.z_0 - a_5.z_0 * o_0.y_0;
    r_4.y_0 = a_5.w_0 * o_0.y_0 - a_5.x_1 * o_0.z_0 + a_5.y_0 * o_0.w_0 + a_5.z_0 * o_0.x_1;
    r_4.z_0 = a_5.w_0 * o_0.z_0 + a_5.x_1 * o_0.y_0 - a_5.y_0 * o_0.x_1 + a_5.z_0 * o_0.w_0;
    return r_4;
}

fn normalized_0( q_12 : Quat_0) -> Quat_0
{
    var _S115 : f32 = q_12.w_0;
    var _S116 : f32 = q_12.x_1;
    var _S117 : f32 = q_12.y_0;
    var _S118 : f32 = q_12.z_0;
    var n_11 : f32 = sqrt(_S115 * _S115 + _S116 * _S116 + _S117 * _S117 + _S118 * _S118);
    var r_5 : Quat_0;
    r_5.w_0 = q_12.w_0 / n_11;
    r_5.x_1 = q_12.x_1 / n_11;
    r_5.y_0 = q_12.y_0 / n_11;
    r_5.z_0 = q_12.z_0 / n_11;
    return r_5;
}

fn integrate_rotation_0( q_13 : Quat_0,  omega_0 : vec3<f32>,  dt_3 : f32) -> Quat_0
{
    var angle_1 : f32 = length(omega_0) * dt_3;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return q_13;
    }
    return normalized_0(quat_mul_0(from_axis_angle_0(omega_0, angle_1), q_13));
}

fn quat_vec_0( q_14 : Quat_0) -> vec4<f32>
{
    return vec4<f32>(q_14.x_1, q_14.y_0, q_14.z_0, q_14.w_0);
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_integrate(@builtin(workgroup_id) group_1 : vec3<u32>, @builtin(local_invocation_id) thread_1 : vec3<u32>)
{
    var p_11 : vec3<f32>;
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
    imp_4.mat_0 = impactors_0[ii_1].mat_0;
    imp_4.crush_0 = impactors_0[ii_1].crush_0;
    imp_4.geom_0 = impactors_0[ii_1].geom_0;
    imp_4.unused_0 = impactors_0[ii_1].unused_0;
    imp_4.ledger_0 = impactors_0[ii_1].ledger_0;
    imp_4.cand_0 = impactors_0[ii_1].cand_0;
    var _S119 : bool;
    if((imp_4.cand_0.z) != u32(0))
    {
        _S119 = true;
    }
    else
    {
        _S119 = (((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0);
    }
    if(_S119)
    {
        _S119 = true;
    }
    else
    {
        var _S120 : u32 = islands_0[params_0.halt_index_0].info_0.y;
        if(_S120 != u32(0))
        {
            _S119 = (imp_4.cand_0.w) >= _S120;
        }
        else
        {
            _S119 = false;
        }
    }
    if(_S119)
    {
        return;
    }
    var _S121 : vec4<f32> = vec4<f32>(0.0f);
    var rf_0 : vec4<f32> = _S121;
    var rt_0 : vec4<f32> = _S121;
    var k_10 : u32 = imp_4.cand_0.x + tid_2;
    loop
    {
        if(k_10 < (imp_4.cand_0.y))
        {
        }
        else
        {
            break;
        }
        var _S122 : u32 = u32(3) * k_10;
        rf_0 = rf_0 + scratch_0[params_0.cand_base_0 + _S122 + u32(1)];
        rt_0 = rt_0 + scratch_0[params_0.cand_base_0 + _S122 + u32(2)];
        k_10 = k_10 + u32(256);
    }
    group_sum2_0(tid_2, &(rf_0), &(rt_0));
    if(tid_2 != u32(0))
    {
        return;
    }
    var dt_4 : f32 = params_0.dt_0;
    var _S123 : vec3<f32> = vec3<f32>(0.0f);
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((params_0.has_ground_0) != u32(0))
    {
        var ib_0 : Box_0 = impactor_box_0(imp_4, _S123, imp_4.half_1.xyz);
        var _S124 : vec3<f32> = imp_4.velocity_1.xyz + imp_4.velocity_err_1.xyz;
        const _S125 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var kc_2 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_4.mat_0.x, ib_0, _S125);
        var _S126 : f32 = imp_4.position_1.z - params_0.ground_hi_0 + (imp_4.position_err_1.z - params_0.ground_lo_0);
        var total_points_0 : u32;
        if((imp_4.shape_0.x) == 0.0f)
        {
            total_points_0 = u32(1);
        }
        else
        {
            total_points_0 = u32(14);
        }
        var _S127 : f32 = kc_2 / f32(min(total_points_0, u32(5)));
        var s_5 : u32 = u32(0);
        var below_0 : u32 = u32(0);
        loop
        {
            if(s_5 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if((imp_4.shape_0.x) == 0.0f)
            {
                p_11 = vec3<f32>(0.0f, 0.0f, - imp_4.shape_0.y);
            }
            else
            {
                p_11 = sample_point_0(ib_0, s_5);
            }
            if((_S126 + p_11.z) < 0.0f)
            {
                below_0 = below_0 + u32(1);
            }
            s_5 = s_5 + u32(1);
        }
        s_5 = u32(0);
        load_f_0 = _S123;
        load_t_0 = _S123;
        loop
        {
            if(s_5 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if((imp_4.shape_0.x) == 0.0f)
            {
                p_11 = vec3<f32>(0.0f, 0.0f, - imp_4.shape_0.y);
            }
            else
            {
                p_11 = sample_point_0(ib_0, s_5);
            }
            var depth_5 : f32 = - (_S126 + p_11.z);
            if(depth_5 <= 0.0f)
            {
                s_5 = s_5 + u32(1);
                continue;
            }
            var stored_4 : f32;
            var diss_2 : f32;
            var f_2 : vec3<f32> = penalty_force_1(_S127, imp_4.mat_0.z, params_0.ground_friction_0, depth_5, _S125, _S124 + cross(imp_4.angular_velocity_1.xyz, p_11), dt_4, below_0, &(stored_4), &(diss_2));
            var load_f_1 : vec3<f32> = load_f_0 + f_2;
            var load_t_1 : vec3<f32> = load_t_0 + cross(p_11, f_2);
            var _S128 : f32 = imp_4.ledger_0[i32(0)];
            var _S129 : f32 = imp_4.ledger_0[i32(1)];
            comp_add1_2(&(_S128), &(_S129), diss_2);
            imp_4.ledger_0[i32(0)] = _S128;
            imp_4.ledger_0[i32(1)] = _S129;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_5 = s_5 + u32(1);
        }
    }
    else
    {
        load_f_0 = _S123;
        load_t_0 = _S123;
    }
    var load_f_2 : vec3<f32> = rf_0.xyz + load_f_0;
    var load_t_2 : vec3<f32> = rt_0.xyz + load_t_0;
    var m_2 : f32 = imp_4.mat_0.z;
    var vel_0 : vec3<f32> = imp_4.velocity_1.xyz;
    var vel_err_0 : vec3<f32> = imp_4.velocity_err_1.xyz;
    var _S130 : vec3<f32> = vec3<f32>(dt_4);
    comp_add_0(&(vel_0), &(vel_err_0), (load_f_2 / vec3<f32>(m_2) + params_0.gravity_0.xyz) * _S130);
    var q_15 : Quat_0 = quat_of_0(imp_4.rotation_1);
    var l_1 : vec3<f32> = world_mul_0(q_15, imp_4.inertia0_2, imp_4.inertia1_2, imp_4.inertia2_2, imp_4.angular_velocity_1.xyz) + load_t_2 * _S130;
    var w_mid_0 : vec3<f32> = world_mul_0(q_15, imp_4.inv0_2, imp_4.inv1_2, imp_4.inv2_2, l_1);
    var pos_0 : vec3<f32> = imp_4.position_1.xyz;
    var pos_err_0 : vec3<f32> = imp_4.position_err_1.xyz;
    comp_add_0(&(pos_0), &(pos_err_0), (vel_0 + vel_err_0) * _S130);
    var q_16 : Quat_0 = integrate_rotation_0(q_15, w_mid_0, dt_4);
    imp_4.angular_velocity_1 = vec4<f32>(world_mul_0(q_16, imp_4.inv0_2, imp_4.inv1_2, imp_4.inv2_2, l_1), 0.0f);
    imp_4.rotation_1 = quat_vec_0(q_16);
    imp_4.position_1 = vec4<f32>(pos_0, 0.0f);
    imp_4.position_err_1 = vec4<f32>(pos_err_0, 0.0f);
    imp_4.velocity_1 = vec4<f32>(vel_0, 0.0f);
    imp_4.velocity_err_1 = vec4<f32>(vel_err_0, 0.0f);
    imp_4.cand_0[i32(3)] = imp_4.cand_0[i32(3)] + u32(1);
    imp_4.geom_0 = vec4<f32>(1.0f, imp_4.crush_0.w, 0.0f, 0.0f);
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
    impactors_0[ii_1].mat_0 = imp_4.mat_0;
    impactors_0[ii_1].crush_0 = imp_4.crush_0;
    impactors_0[ii_1].geom_0 = imp_4.geom_0;
    impactors_0[ii_1].unused_0 = imp_4.unused_0;
    impactors_0[ii_1].ledger_0 = imp_4.ledger_0;
    impactors_0[ii_1].cand_0 = imp_4.cand_0;
    var k_11 : u32 = imp_4.cand_0.w - u32(1) - params_0.step_start_0;
    if(k_11 < (params_0.record_stride_0))
    {
        var at_3 : u32 = params_0.record_base_0 + u32(2) * (ii_1 * params_0.record_stride_0 + k_11);
        scratch_0[at_3] = vec4<f32>(vel_0 + vel_err_0, 0.0f);
        scratch_0[at_3 + u32(1)] = vec4<f32>(pos_0 + pos_err_0, 0.0f);
    }
    return;
}

fn ground_contact_0( c_9 : u32,  account_0 : bool,  f_3 : ptr<function, vec3<f32>>,  t_5 : ptr<function, vec3<f32>>)
{
    var wp_1 : WorldPoint_0 = chunk_world_0(c_9);
    var above_0 : f32 = wp_1.hi_0.z - params_0.ground_hi_0 + (wp_1.lo_0.z - params_0.ground_lo_0) + wp_1.rel_0.z;
    if((above_0 - chunks_0[c_9].half_0.w) > 0.0f)
    {
        return;
    }
    var b_15 : Box_0 = chunk_box_0(c_9, vec3<f32>(0.0f));
    const _S131 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S132 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_15, chunks_0[c_9].cmat_0.x, b_15, _S131);
    var s_6 : u32 = u32(0);
    var n_12 : u32 = u32(0);
    loop
    {
        if(s_6 < u32(14))
        {
        }
        else
        {
            break;
        }
        if((above_0 + sample_point_0(b_15, s_6).z) < 0.0f)
        {
            n_12 = n_12 + u32(1);
        }
        s_6 = s_6 + u32(1);
    }
    if(n_12 == u32(0))
    {
        return;
    }
    var vc_1 : vec3<f32>;
    var wc_1 : vec3<f32>;
    chunk_velocity_1(c_9, &(vc_1), &(wc_1));
    var ledger_2 : vec4<f32> = scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_9];
    s_6 = u32(0);
    loop
    {
        if(s_6 < u32(14))
        {
        }
        else
        {
            break;
        }
        var p_12 : vec3<f32> = sample_point_0(b_15, s_6);
        var _S133 : f32 = above_0 + p_12.z;
        if(!(_S133 < 0.0f))
        {
            s_6 = s_6 + u32(1);
            continue;
        }
        var stored_5 : f32;
        var diss_3 : f32;
        var g_0 : vec3<f32> = penalty_force_1(_S132 / f32(max(n_12, u32(5))), chunks_0[c_9].center_0.w, params_0.ground_friction_0, - _S133, _S131, vc_1 + cross(wc_1, p_12), params_0.dt_0, n_12, &(stored_5), &(diss_3));
        (*f_3) = (*f_3) + g_0;
        (*t_5) = (*t_5) + cross(p_12, g_0);
        var _S134 : f32 = ledger_2[i32(1)];
        var _S135 : f32 = ledger_2[i32(2)];
        comp_add1_2(&(_S134), &(_S135), diss_3);
        ledger_2[i32(1)] = _S134;
        ledger_2[i32(2)] = _S135;
        s_6 = s_6 + u32(1);
    }
    if(account_0)
    {
        scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_9] = ledger_2;
    }
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn contact_sums(@builtin(global_invocation_id) id_2 : vec3<u32>)
{
    var g_1 : u32 = id_2.x;
    var _S136 : bool;
    if(g_1 >= (params_0.seg_count_0))
    {
        _S136 = true;
    }
    else
    {
        _S136 = stopped_0();
    }
    if(_S136)
    {
        return;
    }
    var _S137 : u32 = u32(3) * g_1;
    var _S138 : u32 = index_0[params_0.seg_index_0 + _S137];
    var begin_0 : u32 = index_0[params_0.seg_index_0 + _S137 + u32(1)];
    var _S139 : u32 = index_0[params_0.seg_index_0 + _S137 + u32(2)];
    var _S140 : vec3<f32> = vec3<f32>(0.0f);
    var f_4 : vec3<f32> = _S140;
    var t_6 : vec3<f32> = _S140;
    var e_1 : u32 = begin_0;
    loop
    {
        if(e_1 < _S139)
        {
        }
        else
        {
            break;
        }
        var entry_1 : u32 = index_0[e_1];
        if(entry_1 == u32(2147483648))
        {
            ground_contact_0(_S138, true, &(f_4), &(t_6));
            e_1 = e_1 + u32(1);
            continue;
        }
        var _S141 : u32 = u32(2) * entry_1;
        f_4 = f_4 + scratch_0[params_0.slot_base_0 + _S141].xyz;
        t_6 = t_6 + scratch_0[params_0.slot_base_0 + _S141 + u32(1)].xyz;
        e_1 = e_1 + u32(1);
    }
    var _S142 : u32 = u32(2) * g_1;
    scratch_0[params_0.seg_base_0 + _S142] = vec4<f32>(f_4, 0.0f);
    scratch_0[params_0.seg_base_0 + _S142 + u32(1)] = vec4<f32>(t_6, 0.0f);
    return;
}

fn contact_stopped_0( isl_0 : ptr<function, Island_std430_0>) -> bool
{
    var _S143 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S144 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S144 = true;
    }
    else
    {
        var _S145 : u32 = _S143.y;
        if(_S145 != u32(0))
        {
            _S144 = _S145 <= ((*isl_0).info_0.w);
        }
        else
        {
            _S144 = false;
        }
    }
    return _S144;
}

struct Island_0
{
     range_0 : vec4<u32>,
     info_0 : vec4<u32>,
     com_0 : vec4<f32>,
     inertia0_0 : vec4<f32>,
     inertia1_0 : vec4<f32>,
     inertia2_0 : vec4<f32>,
     inv0_0 : vec4<f32>,
     inv1_0 : vec4<f32>,
     inv2_0 : vec4<f32>,
     wcom_0 : vec4<f32>,
     winv0_0 : vec4<f32>,
     winv1_0 : vec4<f32>,
     winv2_0 : vec4<f32>,
     rotation_0 : vec4<f32>,
     position_0 : vec4<f32>,
     position_err_0 : vec4<f32>,
     velocity_0 : vec4<f32>,
     velocity_err_0 : vec4<f32>,
     angular_velocity_0 : vec4<f32>,
     done_0 : vec4<u32>,
     probes_0 : vec4<u32>,
     energy_0 : vec4<f32>,
};

fn contact_stopped_1( isl_1 : Island_0) -> bool
{
    var _S146 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S147 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S147 = true;
    }
    else
    {
        var _S148 : u32 = _S146.y;
        if(_S148 != u32(0))
        {
            _S147 = _S148 <= (isl_1.info_0.w);
        }
        else
        {
            _S147 = false;
        }
    }
    return _S147;
}

var<workgroup> g_run_0 : u32;

var<workgroup> g_halt_0 : u32;

struct Rigid_0
{
     rot_0 : Quat_0,
     pos_1 : vec3<f32>,
     pos_err_1 : vec3<f32>,
     vel_1 : vec3<f32>,
     vel_err_1 : vec3<f32>,
     w_4 : vec3<f32>,
     a_6 : vec3<f32>,
     alpha_0 : vec3<f32>,
};

fn rigid_of_0( isl_2 : ptr<function, Island_std430_0>) -> Rigid_0
{
    var rg_0 : Rigid_0;
    rg_0.rot_0 = quat_of_0((*isl_2).rotation_0);
    rg_0.pos_1 = (*isl_2).position_0.xyz;
    rg_0.pos_err_1 = (*isl_2).position_err_0.xyz;
    rg_0.vel_1 = (*isl_2).velocity_0.xyz;
    rg_0.vel_err_1 = (*isl_2).velocity_err_0.xyz;
    rg_0.w_4 = (*isl_2).angular_velocity_0.xyz;
    var _S149 : vec3<f32> = vec3<f32>(0.0f);
    rg_0.a_6 = _S149;
    rg_0.alpha_0 = _S149;
    return rg_0;
}

fn rigid_of_1( isl_3 : Island_0) -> Rigid_0
{
    var rg_1 : Rigid_0;
    rg_1.rot_0 = quat_of_0(isl_3.rotation_0);
    rg_1.pos_1 = isl_3.position_0.xyz;
    rg_1.pos_err_1 = isl_3.position_err_0.xyz;
    rg_1.vel_1 = isl_3.velocity_0.xyz;
    rg_1.vel_err_1 = isl_3.velocity_err_0.xyz;
    rg_1.w_4 = isl_3.angular_velocity_0.xyz;
    var _S150 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.a_6 = _S150;
    rg_1.alpha_0 = _S150;
    return rg_1;
}

fn time_since_0( origin_0 : vec4<f32>,  k_12 : u32,  dt_5 : f32) -> f32
{
    return params_0.t_hi_0 - origin_0.x + (params_0.t_lo_0 - origin_0.y) + f32(k_12) * dt_5;
}

fn table_eval_0( offset_0 : u32,  count_3 : u32,  tau_0 : f32) -> f32
{
    var first_0 : vec4<f32> = loads_0[offset_0];
    if(tau_0 <= (first_0.x))
    {
        return first_0.y;
    }
    var i_4 : u32 = u32(1);
    loop
    {
        if(i_4 < count_3)
        {
        }
        else
        {
            break;
        }
        var _S151 : u32 = offset_0 + i_4;
        var b_16 : vec4<f32> = loads_0[_S151];
        var _S152 : f32 = b_16.x;
        if(tau_0 <= _S152)
        {
            var a_7 : vec4<f32> = loads_0[_S151 - u32(1)];
            var _S153 : f32 = a_7.x;
            var _S154 : f32 = a_7.y;
            return _S154 + (tau_0 - _S153) / max(_S152 - _S153, 1.00000000317107685e-30f) * (b_16.y - _S154);
        }
        i_4 = i_4 + u32(1);
    }
    return loads_0[offset_0 + count_3 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_13 : u32,  dt_6 : f32,  shift_0 : f32) -> f32
{
    var _S155 : u32 = u32(5) * term_0;
    var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S155])));
    var origin_1 : vec4<f32> = loads_0[_S155 + u32(3)];
    var p_13 : vec4<f32> = loads_0[_S155 + u32(4)];
    var kind_0 : u32 = info_2.z;
    if(kind_0 == u32(0))
    {
        return origin_1.z;
    }
    var tau_1 : f32 = time_since_0(origin_1, k_13, dt_6) + shift_0;
    var shape_1 : f32;
    if(kind_0 == u32(1))
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            var _S156 : f32 = p_13.x;
            if(tau_1 >= _S156)
            {
                shape_1 = p_13.y;
            }
            else
            {
                shape_1 = p_13.y * tau_1 / _S156;
            }
        }
        return shape_1;
    }
    var _S157 : bool;
    if(kind_0 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S157 = true;
        }
        else
        {
            _S157 = tau_1 > (p_13.x);
        }
        if(_S157)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_13.y * sin(3.14159274101257324f * tau_1 / p_13.x);
        }
        return shape_1;
    }
    if(kind_0 == u32(3))
    {
        var sn_0 : f32 = tau_1 / p_13.y;
        if(sn_0 < 0.0f)
        {
            _S157 = true;
        }
        else
        {
            _S157 = sn_0 > 1.0f;
        }
        if(_S157)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_13.x * (1.0f - sn_0) * exp(- p_13.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == u32(4))
    {
        return table_eval_0(info_2.w, (bitcast<u32>((p_13.x))), tau_1);
    }
    if(kind_0 == u32(5))
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var sn_1 : f32 = tau_1 / p_13.x;
        if(sn_1 < 0.0f)
        {
            _S157 = true;
        }
        else
        {
            _S157 = sn_1 > 1.0f;
        }
        if(_S157)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- p_13.y * sn_1);
        }
        var clearing_0 : f32 = origin_1.w;
        var relax_0 : f32;
        if(clearing_0 > 0.0f)
        {
            relax_0 = max(1.0f - tau_1 / clearing_0, 0.0f);
        }
        else
        {
            relax_0 = 0.0f;
        }
        var _S158 : f32 = p_13.w;
        return (_S158 + (p_13.z - _S158) * relax_0) * shape_1;
    }
    var _S159 : f32 = p_13.x;
    if(_S159 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S159, 0.0f, 1.0f);
}

fn chunk_external_0( _S160 : u32,  _S161 : u32,  _S162 : Quat_0,  _S163 : u32,  _S164 : f32,  _S165 : bool,  _S166 : ptr<function, vec3<f32>>,  _S167 : ptr<function, vec3<f32>>)
{
    var _S168 : vec3<f32> = vec3<f32>(0.0f);
    (*_S166) = _S168;
    (*_S167) = _S168;
    var _S169 : vec4<u32> = chunks_0[_S161].load_range_0;
    var term_1 : u32 = chunks_0[_S161].load_range_0.x;
    loop
    {
        if(term_1 < (_S169.y))
        {
        }
        else
        {
            break;
        }
        var _S170 : u32 = u32(5) * term_1;
        var _S171 : u32 = (bitcast<vec4<u32>>((loads_0[_S170]))).y;
        if(_S171 == u32(2))
        {
            term_1 = term_1 + u32(1);
            continue;
        }
        var dir_1 : vec4<f32> = loads_0[_S170 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S170 + u32(2)];
        var value_0 : f32 = eval_function_0(term_1, _S163, _S164, 0.0f);
        var fw_0 : vec3<f32>;
        if(_S171 == u32(0))
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_0);
        }
        else
        {
            fw_0 = rotate_0(_S162, dir_1.xyz) * vec3<f32>((- value_0 * dir_1.w));
        }
        (*_S166) = (*_S166) + fw_0;
        (*_S167) = (*_S167) + cross(rotate_0(_S162, arm_0.xyz), fw_0);
        term_1 = term_1 + u32(1);
    }
    var _S172 : bool;
    if(_S165)
    {
        _S172 = (chunks_0[_S161].cinfo_0.z) != u32(0);
    }
    else
    {
        _S172 = false;
    }
    if(_S172)
    {
        var _S173 : vec4<u32> = chunks_0[_S161].cinfo_0;
        var g_2 : u32 = chunks_0[_S161].cinfo_0.x;
        loop
        {
            if(g_2 < (_S173.y))
            {
            }
            else
            {
                break;
            }
            var _S174 : u32 = u32(2) * g_2;
            (*_S166) = (*_S166) + scratch_0[params_0.seg_base_0 + _S174].xyz;
            (*_S167) = (*_S167) + scratch_0[params_0.seg_base_0 + _S174 + u32(1)].xyz;
            g_2 = g_2 + u32(1);
        }
    }
    return;
}

fn net_load_0( c_10 : u32,  isl_4 : ptr<function, Island_std430_0>,  rg_2 : Rigid_0,  k_14 : u32,  dt_7 : f32,  contact_0 : bool,  f_5 : ptr<function, vec3<f32>>,  t_7 : ptr<function, vec3<f32>>)
{
    var fl_0 : vec3<f32>;
    var tl_0 : vec3<f32>;
    chunk_external_0(c_10, c_10, rg_2.rot_0, k_14, dt_7, contact_0, &(fl_0), &(tl_0));
    var fc_0 : vec3<f32> = fl_0 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_10].center_0.w);
    var _S175 : vec3<f32> = chunks_0[c_10].center_0.xyz;
    var _S176 : vec3<f32> = (*isl_4).com_0.xyz;
    var r_6 : vec3<f32> = rotate_0(rg_2.rot_0, _S175 + state_0[u32(4) * c_10].xyz - _S176);
    (*f_5) = (*f_5) + fc_0;
    (*t_7) = (*t_7) + (cross(r_6, fc_0) + tl_0);
    var _S177 : vec4<u32> = chunks_0[c_10].load_range_0;
    var term_2 : u32 = chunks_0[c_10].load_range_0.x;
    loop
    {
        if(term_2 < (_S177.y))
        {
        }
        else
        {
            break;
        }
        var _S178 : u32 = u32(5) * term_2;
        if(((bitcast<vec4<u32>>((loads_0[_S178]))).y) != u32(2))
        {
            term_2 = term_2 + u32(1);
            continue;
        }
        var _S179 : vec3<f32> = vec3<f32>(eval_function_0(term_2, k_14, dt_7, 0.0f));
        var fw_1 : vec3<f32> = rotate_0(rg_2.rot_0, loads_0[_S178 + u32(1)].xyz * _S179);
        (*f_5) = (*f_5) + fw_1;
        (*t_7) = (*t_7) + (cross(rotate_0(rg_2.rot_0, _S175 - _S176), fw_1) + rotate_0(rg_2.rot_0, loads_0[_S178 + u32(2)].xyz * _S179));
        term_2 = term_2 + u32(1);
    }
    return;
}

fn net_load_1( c_11 : u32,  isl_5 : Island_0,  rg_3 : Rigid_0,  k_15 : u32,  dt_8 : f32,  contact_1 : bool,  f_6 : ptr<function, vec3<f32>>,  t_8 : ptr<function, vec3<f32>>)
{
    var fl_1 : vec3<f32>;
    var tl_1 : vec3<f32>;
    chunk_external_0(c_11, c_11, rg_3.rot_0, k_15, dt_8, contact_1, &(fl_1), &(tl_1));
    var fc_1 : vec3<f32> = fl_1 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_11].center_0.w);
    var _S180 : vec3<f32> = chunks_0[c_11].center_0.xyz;
    var _S181 : vec3<f32> = isl_5.com_0.xyz;
    var r_7 : vec3<f32> = rotate_0(rg_3.rot_0, _S180 + state_0[u32(4) * c_11].xyz - _S181);
    (*f_6) = (*f_6) + fc_1;
    (*t_8) = (*t_8) + (cross(r_7, fc_1) + tl_1);
    var _S182 : vec4<u32> = chunks_0[c_11].load_range_0;
    var term_3 : u32 = chunks_0[c_11].load_range_0.x;
    loop
    {
        if(term_3 < (_S182.y))
        {
        }
        else
        {
            break;
        }
        var _S183 : u32 = u32(5) * term_3;
        if(((bitcast<vec4<u32>>((loads_0[_S183]))).y) != u32(2))
        {
            term_3 = term_3 + u32(1);
            continue;
        }
        var _S184 : vec3<f32> = vec3<f32>(eval_function_0(term_3, k_15, dt_8, 0.0f));
        var fw_2 : vec3<f32> = rotate_0(rg_3.rot_0, loads_0[_S183 + u32(1)].xyz * _S184);
        (*f_6) = (*f_6) + fw_2;
        (*t_8) = (*t_8) + (cross(rotate_0(rg_3.rot_0, _S180 - _S181), fw_2) + rotate_0(rg_3.rot_0, loads_0[_S183 + u32(2)].xyz * _S184));
        term_3 = term_3 + u32(1);
    }
    return;
}

fn group_sum3_0( tid_3 : u32,  a_8 : ptr<function, vec3<f32>>,  b_17 : ptr<function, vec3<f32>>)
{
    var x_6 : vec4<f32> = vec4<f32>((*a_8), 0.0f);
    var y_1 : vec4<f32> = vec4<f32>((*b_17), 0.0f);
    group_sum2_0(tid_3, &(x_6), &(y_1));
    (*a_8) = x_6.xyz;
    (*b_17) = y_1.xyz;
    return;
}

fn rigid_acceleration_0( isl_6 : ptr<function, Island_std430_0>,  rg_4 : ptr<function, Rigid_0>,  f_7 : vec3<f32>,  t_9 : vec3<f32>)
{
    var iw_w_0 : vec3<f32> = world_mul_0((*rg_4).rot_0, (*isl_6).inertia0_0, (*isl_6).inertia1_0, (*isl_6).inertia2_0, (*rg_4).w_4);
    (*rg_4).a_6 = f_7 / vec3<f32>((*isl_6).com_0.w);
    (*rg_4).alpha_0 = world_mul_0((*rg_4).rot_0, (*isl_6).inv0_0, (*isl_6).inv1_0, (*isl_6).inv2_0, t_9 - cross((*rg_4).w_4, iw_w_0));
    return;
}

fn rigid_acceleration_1( isl_7 : Island_0,  rg_5 : ptr<function, Rigid_0>,  f_8 : vec3<f32>,  t_10 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_5).rot_0, isl_7.inertia0_0, isl_7.inertia1_0, isl_7.inertia2_0, (*rg_5).w_4);
    (*rg_5).a_6 = f_8 / vec3<f32>(isl_7.com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_0, isl_7.inv0_0, isl_7.inv1_0, isl_7.inv2_0, t_10 - cross((*rg_5).w_4, iw_w_1));
    return;
}

struct JointState_0
{
     damage_0 : f32,
     crush_1 : f32,
     kappa_0 : f32,
     kappa_c_0 : f32,
     ductility_0 : f32,
     ductility_c_0 : f32,
     fatigue_0 : f32,
     plastic_x_0 : f32,
     plastic_y_0 : f32,
     plastic_t_0 : f32,
     rebar_plastic_0 : f32,
     rebar_slip0_0 : f32,
     rebar_slip1_0 : f32,
     rebar_work_0 : f32,
     rebar_broken_0 : f32,
     strain_rate_0 : f32,
     governing_stress_0 : f32,
     dissipated_0 : f32,
     utilization_0 : f32,
     mode_0 : u32,
};

fn connected_0( st_0 : JointState_0,  has_rebar_0 : bool) -> bool
{
    var _S185 : bool;
    if((st_0.damage_0) < 1.0f)
    {
        _S185 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S185 = (st_0.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S185 = false;
        }
    }
    return _S185;
}

struct Measures_0
{
     tension_0 : f32,
     shear_0 : f32,
     normal_compression_0 : f32,
     compression_0 : f32,
     compressive_force_0 : f32,
};

fn stress_measures_0( b_18 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_2 : f32 = (*b_18).geom0_0.x;
    var _S186 : f32 = q_lin_0.z;
    var axial_0 : f32 = _S186 / area_2;
    var bending_0 : f32 = abs(q_ang_0.x) / (*b_18).geom1_0.x + abs(q_ang_0.y) / (*b_18).geom1_0.y;
    var _S187 : f32 = q_lin_0.x;
    var _S188 : f32 = q_lin_0.y;
    var shear_1 : f32 = sqrt(_S187 * _S187 + _S188 * _S188) / area_2 + abs(q_ang_0.z) / (*b_18).geom0_0.w;
    var m_3 : Measures_0;
    m_3.tension_0 = axial_0 + bending_0;
    m_3.shear_0 = shear_1;
    var _S189 : f32 = - axial_0;
    m_3.normal_compression_0 = max(_S189, 0.0f);
    m_3.compression_0 = _S189 + bending_0;
    m_3.compressive_force_0 = max(- _S186, 0.0f);
    return m_3;
}

fn expm1_accurate_0( x_7 : f32) -> f32
{
    if((abs(x_7)) < 0.00100000004749745f)
    {
        return x_7 * (1.0f + x_7 * (0.5f + x_7 * 0.1666666716337204f));
    }
    return exp(x_7) - 1.0f;
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_8 : f32 = abs(strain_rate_1);
    var _S190 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_8 <= ref_0)
    {
        return 1.0f;
    }
    var _S191 : f32 = _S190.z;
    var f_9 : f32;
    if(r_8 <= _S191)
    {
        f_9 = pow(r_8 / ref_0, _S190.y);
    }
    else
    {
        f_9 = pow(_S191 / ref_0, _S190.y) * pow(r_8 / _S191, _S190.w);
    }
    return clamp(f_9, 1.0f, (*mat_1).misc_0.x);
}

fn fatigue_factor_0( mat_2 : ptr<function, JointMaterial_std140_0>,  fatigue_1 : f32) -> f32
{
    if(((((*mat_2).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return pow(1.0f - clamp(fatigue_1, 0.0f, 1.0f), 1.0f / ((*mat_2).misc_0.y - 2.0f));
}

fn fatigue_factor_1( mat_3 : ptr<function, JointMaterial_std140_0>,  fatigue_2 : f32) -> f32
{
    if(((((*mat_3).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return pow(1.0f - clamp(fatigue_2, 0.0f, 1.0f), 1.0f / ((*mat_3).misc_0.y - 2.0f));
}

fn infinity_0() -> f32
{
    return (bitcast<f32>((u32(2139095040))));
}

fn failure_indices_0( mat_4 : ptr<function, JointMaterial_std140_0>,  b_19 : ptr<function, JointBond_std430_0>,  m_4 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_2 : f32 = (*mat_4).strength_0.y * multiplier_0;
    var _S192 : f32 = min((*mat_4).strength_0.z * multiplier_0 + (*mat_4).strength_0.w * m_4.normal_compression_0, (*mat_4).energy_1.x * multiplier_0);
    var idx_1 : vec4<f32>;
    idx_1[i32(0)] = max(m_4.tension_0 / ((*mat_4).strength_0.x * multiplier_0), 0.0f);
    var _S193 : f32;
    if(_S192 > 0.0f)
    {
        _S193 = m_4.shear_0 / _S192;
    }
    else
    {
        _S193 = infinity_0();
    }
    idx_1[i32(1)] = _S193;
    idx_1[i32(2)] = max(m_4.compression_0 / fc_2, 0.0f);
    var _S194 : f32 = (*b_19).stiff1_0.y;
    if(_S194 > 0.0f)
    {
        _S193 = m_4.compressive_force_0 / _S194;
    }
    else
    {
        _S193 = 0.0f;
    }
    idx_1[i32(3)] = _S193;
    return idx_1;
}

fn sq_0( x_8 : f32) -> f32
{
    return x_8 * x_8;
}

fn damage_law_0( kind_1 : u32,  kappa_1 : f32,  r_9 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == u32(0))
    {
        if(r_9 <= 1.0f)
        {
            return 1.0f;
        }
        return min(r_9 * (kappa_1 - 1.0f) / (kappa_1 * (r_9 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_9 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - 1.0f / kappa_1;
}

fn damage_increment_0( kind_2 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_10 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S195 : f32 = max(damage_law_0(kind_2, lambda_0, r_10), d_old_0);
    var _S196 : bool;
    if(_S195 <= d_old_0)
    {
        _S196 = true;
    }
    else
    {
        _S196 = d_old_0 >= 1.0f;
    }
    if(_S196)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = psi_0 / (lambda_0 * lambda_0);
    var _S197 : f32 = max(kappa_old_0, 1.0f);
    if(kind_2 == u32(0))
    {
        if(r_10 > 1.0f)
        {
            return vec2<f32>(_S195, u0_0 * r_10 / (r_10 - 1.0f) * max(min(lambda_0, r_10) - min(_S197, r_10), 0.0f));
        }
        return vec2<f32>(_S195, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_10 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S197, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S195 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S195, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_4 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S198 : f32 = - h0_0;
    var _S199 : f32 = - h1_0;
    var _S200 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S198, _S199), vec2<f32>(h0_0, _S199), vec2<f32>(h0_0, h1_0), vec2<f32>(_S198, h1_0) );
    var poly_0 : array<vec2<f32>, i32(8)>;
    var i_5 : u32 = u32(0);
    var count_5 : u32 = u32(0);
    loop
    {
        if(i_5 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S201 : u32 = i_5;
        var _S202 : u32 = i_5 + u32(1);
        var _S203 : u32 = _S202 % u32(4);
        var _S204 : f32 = _S200[i_5].y;
        var _S205 : f32 = _S200[i_5].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S204 - ay_0 * _S205;
        var _S206 : f32 = _S200[_S203].y;
        var _S207 : f32 = _S200[_S203].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S206 - ay_0 * _S207;
        var _S208 : bool = fp_0 < 0.0f;
        if(_S208)
        {
            var _S209 : u32 = count_5 + u32(1);
            poly_0[count_5] = _S200[_S201];
            count_4 = _S209;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S208 != (fq_0 < 0.0f))
        {
            var t_11 : f32 = fp_0 / (fp_0 - fq_0);
            var _S210 : u32 = count_4 + u32(1);
            poly_0[count_4] = vec2<f32>(_S205 + t_11 * (_S207 - _S205), _S204 + t_11 * (_S206 - _S204));
            count_5 = _S210;
        }
        else
        {
            count_5 = count_4;
        }
        i_5 = _S202;
    }
    count_4 = u32(0);
    loop
    {
        if(count_4 < u32(6))
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_4] = 0.0f;
        count_4 = count_4 + u32(1);
    }
    if(count_5 < u32(3))
    {
        return;
    }
    var o_1 : vec2<f32> = poly_0[i32(0)];
    i_5 = u32(0);
    var a_9 : f32 = 0.0f;
    var sx_0 : f32 = 0.0f;
    var sy_0 : f32 = 0.0f;
    var ixx_0 : f32 = 0.0f;
    var iyy_0 : f32 = 0.0f;
    var ixy_0 : f32 = 0.0f;
    loop
    {
        if(i_5 < count_5)
        {
        }
        else
        {
            break;
        }
        var _S211 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_5].x - _S211;
        var _S212 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_5].y - _S212;
        var _S213 : u32 = i_5 + u32(1);
        var _S214 : u32 = _S213 % count_5;
        var x1_0 : f32 = poly_0[_S214].x - _S211;
        var y1_0 : f32 = poly_0[_S214].y - _S212;
        var _S215 : f32 = x0_0 * y1_0;
        var _S216 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S215 - _S216;
        var a_10 : f32 = a_9 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S215 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S216) * cr_0 / 24.0f;
        i_5 = _S213;
        a_9 = a_10;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_9 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_9;
    var cy_0 : f32 = sy_0 / a_9;
    (*region_0)[i32(0)] = a_9;
    (*region_0)[i32(1)] = o_1.x + cx_0;
    (*region_0)[i32(2)] = o_1.y + cy_0;
    var _S217 : f32 = a_9 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S217 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_9 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S217 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_11 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_11));
    var a_11 : f32 = r_11[i32(0)];
    if((r_11[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_16 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_3 : f32 = dz_1 + ax_1 * r_11[i32(2)] - ay_1 * r_11[i32(1)];
    var _S218 : f32 = a_11 * fc_3;
    var _S219 : f32 = - ay_1;
    return vec4<f32>(k_16 * a_11 * fc_3, k_16 * (_S218 * r_11[i32(2)] + (_S219 * r_11[i32(5)] + ax_1 * r_11[i32(4)])), - k_16 * (_S218 * r_11[i32(1)] + (_S219 * r_11[i32(3)] + ax_1 * r_11[i32(5)])), 0.5f * k_16 * (_S218 * fc_3 + ay_1 * ay_1 * r_11[i32(3)] + ax_1 * ax_1 * r_11[i32(4)] - 2.0f * ax_1 * ay_1 * r_11[i32(5)]));
}

fn signum_0( x_9 : f32) -> f32
{
    var _S220 : f32;
    if((((bitcast<u32>((x_9))) & (u32(2147483648)))) != u32(0))
    {
        _S220 = -1.0f;
    }
    else
    {
        _S220 = 1.0f;
    }
    return _S220;
}

fn return_map_0( k_17 : f32,  total_3 : f32,  plastic_0 : f32,  cap_0 : f32) -> vec2<f32>
{
    var trial_0 : f32 = k_17 * (total_3 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return vec2<f32>(trial_0, 0.0f);
    }
    var f_10 : f32 = cap_0 * signum_0(trial_0);
    return vec2<f32>(f_10, (trial_0 - f_10) / k_17);
}

struct Contact_0
{
     q_lin_1 : vec3<f32>,
     q_ang_1 : vec3<f32>,
     energy_2 : f32,
     diss_4 : f32,
     plastic_1 : vec3<f32>,
};

fn contact_part_0( mat_5 : ptr<function, JointMaterial_std140_0>,  b_20 : ptr<function, JointBond_std430_0>,  crush_2 : f32,  plastic_2 : vec3<f32>,  d_lin_0 : vec3<f32>,  d_ang_0 : vec3<f32>) -> Contact_0
{
    var c_12 : Contact_0;
    var _S221 : vec3<f32> = vec3<f32>(0.0f);
    c_12.q_lin_1 = _S221;
    c_12.q_ang_1 = _S221;
    c_12.energy_2 = 0.0f;
    c_12.diss_4 = 0.0f;
    c_12.plastic_1 = plastic_2;
    var _S222 : u32 = (*mat_5).kind_flags_0.y;
    if(((_S222 & (u32(2)))) == u32(0))
    {
        return c_12;
    }
    var kn_1 : f32 = (*b_20).stiff0_0.x;
    var ks_0 : f32 = (*b_20).stiff0_0.y;
    var kt_0 : f32 = (*b_20).stiff1_0.x;
    var w0_2 : f32 = (*b_20).geom0_0.y;
    var w1_2 : f32 = (*b_20).geom0_0.z;
    var diss_5 : f32;
    var nc_sum_0 : f32;
    var m1_0 : f32;
    var m2_0 : f32;
    var energy_3 : f32;
    if(((_S222 & (u32(4)))) != u32(0))
    {
        var p_14 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S223 : f32 = p_14.y;
        var _S224 : f32 = p_14.z;
        var _S225 : f32 = p_14.w;
        nc_sum_0 = p_14.x;
        m1_0 = _S223;
        m2_0 = _S224;
        energy_3 = _S225;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S226 : f32 = d_ang_0.x;
        var _S227 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S226) * 0.4166666567325592f * w1_2 + abs(_S227) * 0.4166666567325592f * w0_2;
        var _S228 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S228) + spread_0);
        if((_S228 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S228 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S229 : f32 = ki_0 * _S226 * i2_0;
                var _S230 : f32 = ki_0 * _S227 * i1_0;
                var _S231 : f32 = 0.5f * ki_0 * (36.0f * _S228 * _S228 + _S226 * _S226 * i2_0 + _S227 * _S227 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S228;
                m1_0 = _S229;
                m2_0 = _S230;
                energy_3 = _S231;
            }
            else
            {
                var i_6 : u32 = u32(0);
                diss_5 = 0.0f;
                var m1_1 : f32 = 0.0f;
                var m2_1 : f32 = 0.0f;
                var energy_4 : f32 = 0.0f;
                loop
                {
                    if(i_6 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S232 : f32 = ((f32(i_6) + 0.5f) / 6.0f - 0.5f) * w0_2;
                    var j_3 : u32 = u32(0);
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    loop
                    {
                        if(j_3 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var s2_0 : f32 = ((f32(j_3) + 0.5f) / 6.0f - 0.5f) * w1_2;
                        var di_0 : f32 = _S228 + _S226 * s2_0 - _S227 * _S232;
                        if(di_0 < 0.0f)
                        {
                            var f_11 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_11 * s2_0;
                            var m2_2 : f32 = m2_0 - f_11 * _S232;
                            var energy_5 : f32 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_11;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_3 = j_3 + u32(1);
                    }
                    i_6 = i_6 + u32(1);
                    diss_5 = nc_sum_0;
                    m1_1 = m1_0;
                    m2_1 = m2_0;
                    energy_4 = energy_3;
                }
                nc_sum_0 = diss_5;
                m1_0 = m1_1;
                m2_0 = m2_1;
                energy_3 = energy_4;
            }
        }
    }
    var nc_0 : f32 = - nc_sum_0;
    var p_15 : vec3<f32> = plastic_2;
    c_12.q_lin_1 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_12.q_ang_1 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_5).strength_0.w * nc_0;
    var _S233 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S234 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var trial_1 : vec2<f32> = vec2<f32>(_S233, _S234);
    var tn_0 : f32 = sqrt(_S233 * _S233 + _S234 * _S234);
    var _S235 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S235 = tn_0 > 0.0f;
    }
    else
    {
        _S235 = false;
    }
    if(_S235)
    {
        var dir_2 : vec2<f32> = trial_1 / vec2<f32>(tn_0);
        var dslip_0 : f32 = (tn_0 - slide_cap_0) / ks_0;
        var _S236 : f32 = dir_2.x;
        p_15[i32(0)] = p_15[i32(0)] + _S236 * dslip_0;
        var _S237 : f32 = dir_2.y;
        p_15[i32(1)] = p_15[i32(1)] + _S237 * dslip_0;
        c_12.q_lin_1[i32(0)] = _S236 * slide_cap_0;
        c_12.q_lin_1[i32(1)] = _S237 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_12.q_lin_1[i32(0)] = _S233;
        c_12.q_lin_1[i32(1)] = _S234;
        diss_5 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_15.z, slide_cap_0 * (*b_20).geom1_0.z);
    var _S238 : f32 = tq_0.x;
    var _S239 : f32 = tq_0.y;
    var diss_6 : f32 = diss_5 + abs(_S238) * abs(_S239);
    p_15[i32(2)] = p_15[i32(2)] + _S239;
    c_12.q_ang_1[i32(2)] = _S238;
    c_12.energy_2 = energy_3 + 0.5f * (sq_0(c_12.q_lin_1.x) / ks_0 + sq_0(c_12.q_lin_1.y) / ks_0 + sq_0(_S238) / kt_0);
    c_12.diss_4 = diss_6;
    c_12.plastic_1 = p_15;
    return c_12;
}

fn life_rate_0( mat_6 : ptr<function, JointMaterial_std140_0>,  s_7 : f32) -> f32
{
    if(s_7 <= 0.0f)
    {
        return 0.0f;
    }
    var _S240 : f32 = (*mat_6).misc_0.y;
    return (_S240 + 1.0f) * pow(s_7, _S240) / (*mat_6).misc_0.z;
}

struct JointResponse_0
{
     force_lin_1 : vec3<f32>,
     force_ang_1 : vec3<f32>,
     state_1 : JointState_0,
     dissipated_3 : f32,
     overshoot_0 : f32,
     stored_6 : f32,
     disconnected_0 : bool,
     measures_0 : Measures_0,
};

fn joint_evaluate_0( mat_7 : ptr<function, JointMaterial_std140_0>,  b_21 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>,  dt_9 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_2 : f32 = (*b_21).stiff0_0.x;
    var ks_1 : f32 = (*b_21).stiff0_0.y;
    var kb1_0 : f32 = (*b_21).stiff0_0.z;
    var kb2_0 : f32 = (*b_21).stiff0_0.w;
    var _S241 : vec4<f32> = (*b_21).stiff1_0;
    var kt_1 : f32 = (*b_21).stiff1_0.x;
    var has_rebar_1 : bool = ((*b_21).stiff1_0.w) != 0.0f;
    var kind_3 : u32 = (*mat_7).kind_flags_0.x;
    var flags_1 : u32 = (*mat_7).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_1 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_0(state_2, has_rebar_1);
    var qe_lin_0 : vec3<f32> = d_lin_1 * vec3<f32>(ks_1, ks_1, kn_2);
    var qe_ang_0 : vec3<f32> = d_ang_1 * vec3<f32>(kb1_0, kb2_0, kt_1);
    var _S242 : Measures_0 = stress_measures_0(&((*b_21)), qe_lin_0, qe_ang_0);
    var _S243 : f32 = max(max(_S242.tension_0, _S242.shear_0), _S242.compression_0);
    var _S244 : bool = dt_9 > 0.0f;
    var dif_1 : f32;
    if(_S244)
    {
        var raw_0 : f32 = max((_S243 - st_1.governing_stress_0) / dt_9, 0.0f) / (*mat_7).misc_0.w;
        var tau_2 : f32 = _S241.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- dt_9 / tau_2);
        }
        else
        {
            dif_1 = min(dt_9 / tau_2, 1.0f);
        }
        st_1.strain_rate_0 = st_1.strain_rate_0 + (raw_0 - st_1.strain_rate_0) * dif_1;
        st_1.governing_stress_0 = _S243;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S245 : f32 = dif_factor_0(&((*mat_7)), st_1.strain_rate_0);
        dif_1 = _S245;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_21).geom1_0.w;
    var _S246 : f32 = weibull_0 * dif_1;
    var _S247 : f32 = fatigue_factor_1(&((*mat_7)), st_1.fatigue_0);
    var multiplier_1 : f32 = _S246 * _S247;
    var _S248 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_21)), _S242, multiplier_1);
    var _S249 : f32 = _S248.x;
    var _S250 : f32 = _S248.y;
    st_1.utilization_0 = max(max(_S249, _S250), max(_S248.z, _S248.w));
    var _S251 : f32 = d_lin_1.x;
    var _S252 : f32 = d_lin_1.y;
    var _S253 : f32 = ks_1 * (sq_0(_S251) + sq_0(_S252)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    var _S254 : f32 = d_lin_1.z;
    var _S255 : bool = _S254 > 0.0f;
    if(_S255)
    {
        dif_1 = kn_2 * sq_0(_S254);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S253 + dif_1);
    var psi_c_0 : f32;
    if(_S254 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S254);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    var plastic_3 : vec3<f32> = vec3<f32>(st_1.plastic_x_0, st_1.plastic_y_0, st_1.plastic_t_0);
    var diss_contact_0 : f32;
    var psi_contact_0 : f32;
    var intact_normal_0 : f32;
    var dissipated_4 : f32;
    var overshoot_1 : f32;
    var _S256 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S257 : bool = _S249 >= _S250;
        if(_S257)
        {
            diss_contact_0 = _S249;
        }
        else
        {
            diss_contact_0 = _S250;
        }
        var mode_ts_0 : u32;
        if(_S257)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_1.kappa_0))
        {
            _S256 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S256 = false;
        }
        if(_S256)
        {
            _S256 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S256 = false;
        }
        var mode_c_0 : u32;
        if(_S256)
        {
            if(mode_ts_0 == u32(1))
            {
                psi_contact_0 = (*mat_7).energy_1.y;
            }
            else
            {
                psi_contact_0 = (*mat_7).energy_1.z;
            }
            if(softening_0)
            {
                intact_normal_0 = psi_contact_0 * (*b_21).geom0_0.x * diss_contact_0 * diss_contact_0 / psi_ts_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_1.ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = u32(0);
            }
            var inc_0 : vec2<f32> = damage_increment_0(mode_c_0, st_1.kappa_0, diss_contact_0, intact_normal_0, st_1.damage_0, psi_ts_0);
            var _S258 : f32 = inc_0.x;
            if(_S258 > (st_1.damage_0))
            {
                var _S259 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_21)), st_1.crush_1, plastic_3, d_lin_1, d_ang_1);
                var _S260 : f32 = max(_S259.energy_2 - (1.0f - st_1.crush_1) * psi_c_0, 0.0f);
                var _S261 : f32 = max(inc_0.y - _S260 * (_S258 - st_1.damage_0), 0.0f);
                var _S262 : f32 = max((psi_ts_0 - _S260) * (_S258 - st_1.damage_0) - _S261, 0.0f);
                st_1.damage_0 = _S258;
                st_1.mode_0 = mode_ts_0;
                dissipated_4 = _S261;
                overshoot_1 = _S262;
            }
            else
            {
                dissipated_4 = 0.0f;
                overshoot_1 = 0.0f;
            }
        }
        else
        {
            dissipated_4 = 0.0f;
            overshoot_1 = 0.0f;
        }
        st_1.kappa_0 = max(st_1.kappa_0, diss_contact_0);
        if((state_2.damage_0) > 0.0f)
        {
            var _S263 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_21)), state_2.crush_1, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S263.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S264 : Measures_0 = stress_measures_0(&((*b_21)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S265 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_21)), _S264, multiplier_1);
        var _S266 : f32 = _S265.z;
        var _S267 : f32 = _S265.w;
        var _S268 : bool = _S266 >= _S267;
        if(_S268)
        {
            psi_contact_0 = _S266;
        }
        else
        {
            psi_contact_0 = _S267;
        }
        if(_S268)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_1.kappa_c_0))
        {
            _S256 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S256 = false;
        }
        if(_S256)
        {
            _S256 = psi_c_0 > 0.0f;
        }
        else
        {
            _S256 = false;
        }
        if(_S256)
        {
            if(softening_0)
            {
                intact_normal_0 = (*mat_7).energy_1.w * (*b_21).geom0_0.x * psi_contact_0 * psi_contact_0 / psi_c_0;
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_1.ductility_c_0 = intact_normal_0;
            var law_1 : u32;
            if(!softening_0)
            {
                law_1 = u32(0);
            }
            else
            {
                if(mode_c_0 == u32(4))
                {
                    mode_ts_0 = u32(1);
                }
                else
                {
                    mode_ts_0 = kind_3;
                }
                law_1 = mode_ts_0;
            }
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_1.kappa_c_0, psi_contact_0, intact_normal_0, st_1.crush_1, psi_c_0);
            var _S269 : f32 = inc_1.x;
            if(_S269 > (st_1.crush_1))
            {
                var _S270 : f32 = inc_1.y;
                var dissipated_5 : f32 = dissipated_4 + _S270;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S269 - st_1.crush_1) - _S270, 0.0f);
                st_1.crush_1 = _S269;
                st_1.mode_0 = mode_c_0;
                if(_S269 >= 1.0f)
                {
                    _S256 = (st_1.damage_0) < 1.0f;
                }
                else
                {
                    _S256 = false;
                }
                if(_S256)
                {
                    var dissipated_6 : f32 = dissipated_5 + psi_ts_0 * (1.0f - st_1.damage_0);
                    st_1.damage_0 = 1.0f;
                    dissipated_4 = dissipated_6;
                }
                else
                {
                    dissipated_4 = dissipated_5;
                }
                overshoot_1 = overshoot_2;
            }
        }
        st_1.kappa_c_0 = max(st_1.kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_4 = 0.0f;
        overshoot_1 = 0.0f;
    }
    var dmg_0 : f32 = st_1.damage_0;
    var _S271 : vec3<f32> = vec3<f32>(0.0f);
    if((st_1.damage_0) == 0.0f)
    {
        _S256 = ((flags_1 & (u32(8)))) != u32(0);
    }
    else
    {
        _S256 = false;
    }
    var qc_ang_0 : vec3<f32>;
    if(!_S256)
    {
        var _S272 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_21)), st_1.crush_1, plastic_3, d_lin_1, d_ang_1);
        st_1.plastic_x_0 = _S272.plastic_1.x;
        st_1.plastic_y_0 = _S272.plastic_1.y;
        st_1.plastic_t_0 = _S272.plastic_1.z;
        diss_contact_0 = _S272.diss_4;
        qc_lin_0 = _S272.q_lin_1;
        qc_ang_0 = _S272.q_ang_1;
        psi_contact_0 = _S272.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S271;
        qc_ang_0 = _S271;
        psi_contact_0 = 0.0f;
    }
    var dissipated_7 : f32 = dissipated_4 + dmg_0 * diss_contact_0;
    if(_S255)
    {
        intact_normal_0 = kn_2 * _S254;
    }
    else
    {
        intact_normal_0 = (1.0f - st_1.crush_1) * kn_2 * _S254;
    }
    var _S273 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S273 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S273 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S273 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S273) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_7 : f32 = _S273 * (psi_ts_0 + (1.0f - st_1.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S256 = (st_1.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S256 = false;
    }
    var stored_8 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S256)
    {
        var k_axial_0 : f32 = (*b_21).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_21).rebar0_0.y;
        var yield_force_0 : f32 = (*b_21).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_21).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S254, st_1.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S251, st_1.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S252, st_1.rebar_slip1_0, dowel_capacity_0);
        var _S274 : f32 = nr_0.y;
        var _S275 : f32 = v1_0.y;
        var _S276 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S274) + dowel_capacity_0 * (abs(_S275) + abs(_S276));
        st_1.rebar_plastic_0 = st_1.rebar_plastic_0 + _S274;
        st_1.rebar_slip0_0 = st_1.rebar_slip0_0 + _S275;
        st_1.rebar_slip1_0 = st_1.rebar_slip1_0 + _S276;
        st_1.rebar_work_0 = st_1.rebar_work_0 + work_0;
        var dissipated_8 : f32 = dissipated_7 + work_0;
        var _S277 : f32 = nr_0.x;
        var _S278 : f32 = v1_0.x;
        var _S279 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (sq_0(_S277) / k_axial_0 + (sq_0(_S278) + sq_0(_S279)) / k_dowel_0);
        if(fracture_1)
        {
            _S256 = (st_1.rebar_work_0) >= ((*b_21).rebar1_0.x);
        }
        else
        {
            _S256 = false;
        }
        if(_S256)
        {
            st_1.rebar_broken_0 = 1.0f;
            var dissipated_9 : f32 = dissipated_8 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_4 = dissipated_9;
            stored_8 = stored_7;
        }
        else
        {
            var stored_9 : f32 = stored_7 + elastic_0;
            force_lin_3 = force_lin_2 + vec3<f32>(_S278, _S279, _S277);
            dissipated_4 = dissipated_8;
            stored_8 = stored_9;
        }
    }
    else
    {
        force_lin_3 = force_lin_2;
        dissipated_4 = dissipated_7;
        stored_8 = stored_7;
    }
    if(fracture_1)
    {
        _S256 = _S244;
    }
    else
    {
        _S256 = false;
    }
    if(_S256)
    {
        _S256 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S256 = false;
    }
    if(_S256)
    {
        var _S280 : Measures_0 = stress_measures_0(&((*b_21)), force_lin_3, force_ang_2);
        var _S281 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_21)), _S280, weibull_0);
        var _S282 : f32 = life_rate_0(&((*mat_7)), max(max(_S281.x, _S281.y), _S281.z));
        st_1.fatigue_0 = min(st_1.fatigue_0 + _S282 * dt_9, 1.0f);
    }
    st_1.dissipated_0 = st_1.dissipated_0 + dissipated_4;
    var resp_0 : JointResponse_0;
    resp_0.force_lin_1 = force_lin_3;
    resp_0.force_ang_1 = force_ang_2;
    resp_0.state_1 = st_1;
    resp_0.dissipated_3 = dissipated_4;
    resp_0.overshoot_0 = overshoot_1;
    resp_0.stored_6 = stored_8;
    if(was_connected_0)
    {
        _S256 = !connected_0(st_1, has_rebar_1);
    }
    else
    {
        _S256 = false;
    }
    resp_0.disconnected_0 = _S256;
    resp_0.measures_0 = _S242;
    return resp_0;
}

fn secant_factors_0( b_22 : ptr<function, JointBond_std430_0>,  st_2 : JointState_0,  d_lin_2 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var compressed_0 : bool = (d_lin_2.z) < 0.0f;
    var contact_2 : f32;
    if(compressed_0)
    {
        contact_2 = st_2.damage_0;
    }
    else
    {
        contact_2 = 0.0f;
    }
    var _S283 : f32 = 1.0f - st_2.damage_0;
    var _S284 : f32 = max(_S283 + contact_2, 9.99999997475242708e-07f);
    var normal_6 : f32;
    if(compressed_0)
    {
        normal_6 = max(1.0f - st_2.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_6 = max(_S283, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S284, _S284, normal_6);
    (*f_ang_0) = vec3<f32>(_S284);
    var _S285 : bool;
    if(((*b_22).stiff1_0.w) != 0.0f)
    {
        _S285 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S285 = false;
    }
    if(_S285)
    {
        var _S286 : vec4<f32> = (*b_22).rebar0_0;
        var _S287 : vec4<f32> = (*b_22).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + (*b_22).rebar0_0.x / (*b_22).stiff0_0.x;
        var _S288 : f32 = _S286.y;
        var _S289 : f32 = _S287.y;
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S288 / _S289;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S288 / _S289;
    }
    return;
}

fn is_damaged_0( st_3 : JointState_0) -> bool
{
    var _S290 : bool;
    if((st_3.damage_0) > 0.0f)
    {
        _S290 = true;
    }
    else
    {
        _S290 = (st_3.crush_1) > 0.0f;
    }
    return _S290;
}

struct BondDyn_0
{
     js_0 : JointState_0,
     force_lin_0 : vec4<f32>,
     force_ang_0 : vec4<f32>,
     sums_0 : vec4<f32>,
     comps_0 : vec4<f32>,
     events_0 : vec4<u32>,
};

fn to_local_0( _S291 : u32,  _S292 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S292, bonds_0[_S291].t1_0.xyz), dot(_S292, bonds_0[_S291].t2_0.xyz), dot(_S292, bonds_0[_S291].normal_0.xyz));
}

fn to_body_0( _S293 : u32,  _S294 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S293].t1_0.xyz * vec3<f32>(_S294.x) + bonds_0[_S293].t2_0.xyz * vec3<f32>(_S294.y) + bonds_0[_S293].normal_0.xyz * vec3<f32>(_S294.z);
}

fn bond_update_0( i_7 : u32,  dt_10 : f32,  fracture_2 : bool,  abs_step_0 : u32) -> bool
{
    var _S295 : JointState_0 = JointState_0( bond_dyn_0[i_7].js_0.damage_0, bond_dyn_0[i_7].js_0.crush_1, bond_dyn_0[i_7].js_0.kappa_0, bond_dyn_0[i_7].js_0.kappa_c_0, bond_dyn_0[i_7].js_0.ductility_0, bond_dyn_0[i_7].js_0.ductility_c_0, bond_dyn_0[i_7].js_0.fatigue_0, bond_dyn_0[i_7].js_0.plastic_x_0, bond_dyn_0[i_7].js_0.plastic_y_0, bond_dyn_0[i_7].js_0.plastic_t_0, bond_dyn_0[i_7].js_0.rebar_plastic_0, bond_dyn_0[i_7].js_0.rebar_slip0_0, bond_dyn_0[i_7].js_0.rebar_slip1_0, bond_dyn_0[i_7].js_0.rebar_work_0, bond_dyn_0[i_7].js_0.rebar_broken_0, bond_dyn_0[i_7].js_0.strain_rate_0, bond_dyn_0[i_7].js_0.governing_stress_0, bond_dyn_0[i_7].js_0.dissipated_0, bond_dyn_0[i_7].js_0.utilization_0, bond_dyn_0[i_7].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S295;
    bd_0.force_lin_0 = bond_dyn_0[i_7].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_7].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_7].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_7].comps_0;
    bd_0.events_0 = bond_dyn_0[i_7].events_0;
    var _S296 : JointBond_std430_0 = bonds_0[i_7].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_7].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_7].rb_0.xyz;
    var _S297 : u32 = u32(4) * _S296.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S297 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S297 + u32(3)].xyz;
    var _S298 : u32 = u32(4) * _S296.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S298 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S298 + u32(3)].xyz;
    var _S299 : vec3<f32> = to_local_0(i_7, state_0[_S298].xyz + cross(tb_3, rb_1) - (state_0[_S297].xyz + cross(ta_3, ra_1)));
    var _S300 : vec3<f32> = to_local_0(i_7, tb_3 - ta_3);
    var _S301 : vec3<f32> = to_local_0(i_7, state_0[_S298 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S297 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S302 : vec3<f32> = to_local_0(i_7, wb_0 - wa_0);
    var _S303 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S296.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S304 : JointResponse_0 = joint_evaluate_0(&(_S303), &(_S296), bd_0.js_0, _S299, _S300, dt_10, fracture_2);
    var f_lin_1 : vec3<f32>;
    var f_ang_1 : vec3<f32>;
    secant_factors_0(&(_S296), _S304.state_1, _S299, &(f_lin_1), &(f_ang_1));
    var qd_lin_0 : vec3<f32> = _S301 * bonds_0[i_7].c_lin_0.xyz * f_lin_1;
    var qd_ang_0 : vec3<f32> = _S302 * bonds_0[i_7].c_ang_0.xyz * f_ang_1;
    var q_lin_2 : vec3<f32> = _S304.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S304.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S301) + dot(qd_ang_0, _S302)) * dt_10;
    var _S305 : vec3<f32> = to_body_0(i_7, q_lin_2);
    var _S306 : vec3<f32> = to_body_0(i_7, q_ang_2);
    var _S307 : u32 = u32(3) * i_7;
    scratch_0[_S307] = vec4<f32>(_S305, max(_S304.measures_0.tension_0, _S304.measures_0.compression_0));
    scratch_0[_S307 + u32(1)] = vec4<f32>(_S306 + cross(ra_1, _S305), 0.0f);
    scratch_0[_S307 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S306) + cross(rb_1, (vec3<f32>(0) - _S305)), 0.0f);
    var _S308 : f32 = bd_0.sums_0[i32(0)];
    var _S309 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S308), &(_S309), _S304.dissipated_3);
    bd_0.sums_0[i32(0)] = _S308;
    bd_0.comps_0[i32(0)] = _S309;
    var _S310 : f32 = bd_0.sums_0[i32(1)];
    var _S311 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S310), &(_S311), _S304.overshoot_0);
    bd_0.sums_0[i32(1)] = _S310;
    bd_0.comps_0[i32(1)] = _S311;
    var _S312 : f32 = bd_0.sums_0[i32(2)];
    var _S313 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S312), &(_S313), damped_0);
    bd_0.sums_0[i32(2)] = _S312;
    bd_0.comps_0[i32(2)] = _S313;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S304.stored_6);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S304.state_1.utilization_0));
    var _S314 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S314 = is_damaged_0(_S304.state_1);
    }
    else
    {
        _S314 = false;
    }
    if(_S314)
    {
        _S314 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S314 = false;
    }
    if(_S314)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S304.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S315 : f32 = fatigue_factor_0(&(_S303), previous_0.fatigue_0);
        _S314 = _S315 > 0.99000000953674316f;
    }
    else
    {
        _S314 = false;
    }
    if(_S314)
    {
        var _S316 : f32 = fatigue_factor_0(&(_S303), _S304.state_1.fatigue_0);
        _S314 = _S316 <= 0.99000000953674316f;
    }
    else
    {
        _S314 = false;
    }
    if(_S314)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S304.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
    }
    bd_0.js_0 = _S304.state_1;
    bond_dyn_0[i_7].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_7].js_0.crush_1 = bd_0.js_0.crush_1;
    bond_dyn_0[i_7].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_7].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_7].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_7].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_7].js_0.fatigue_0 = bd_0.js_0.fatigue_0;
    bond_dyn_0[i_7].js_0.plastic_x_0 = bd_0.js_0.plastic_x_0;
    bond_dyn_0[i_7].js_0.plastic_y_0 = bd_0.js_0.plastic_y_0;
    bond_dyn_0[i_7].js_0.plastic_t_0 = bd_0.js_0.plastic_t_0;
    bond_dyn_0[i_7].js_0.rebar_plastic_0 = bd_0.js_0.rebar_plastic_0;
    bond_dyn_0[i_7].js_0.rebar_slip0_0 = bd_0.js_0.rebar_slip0_0;
    bond_dyn_0[i_7].js_0.rebar_slip1_0 = bd_0.js_0.rebar_slip1_0;
    bond_dyn_0[i_7].js_0.rebar_work_0 = bd_0.js_0.rebar_work_0;
    bond_dyn_0[i_7].js_0.rebar_broken_0 = bd_0.js_0.rebar_broken_0;
    bond_dyn_0[i_7].js_0.strain_rate_0 = bd_0.js_0.strain_rate_0;
    bond_dyn_0[i_7].js_0.governing_stress_0 = bd_0.js_0.governing_stress_0;
    bond_dyn_0[i_7].js_0.dissipated_0 = bd_0.js_0.dissipated_0;
    bond_dyn_0[i_7].js_0.utilization_0 = bd_0.js_0.utilization_0;
    bond_dyn_0[i_7].js_0.mode_0 = bd_0.js_0.mode_0;
    bond_dyn_0[i_7].force_lin_0 = bd_0.force_lin_0;
    bond_dyn_0[i_7].force_ang_0 = bd_0.force_ang_0;
    bond_dyn_0[i_7].sums_0 = bd_0.sums_0;
    bond_dyn_0[i_7].comps_0 = bd_0.comps_0;
    bond_dyn_0[i_7].events_0 = bd_0.events_0;
    return _S304.disconnected_0;
}

fn chunk_update_0( c_13 : u32,  isl_8 : ptr<function, Island_std430_0>,  rg_6 : Rigid_0,  dt_11 : f32,  rml_0 : bool,  step_0 : u32,  contact_3 : bool,  work_1 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S317 : vec3<f32> = vec3<f32>(0.0f);
    var _S318 : u32 = index_0[c_13];
    var peak_0 : f32 = 0.0f;
    var e_2 : u32 = _S318;
    var fi_0 : vec3<f32> = _S317;
    var mi_0 : vec3<f32> = _S317;
    loop
    {
        if(e_2 < index_0[c_13 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_2 : u32 = index_0[e_2];
        var _S319 : u32 = u32(3) * ((entry_2 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S319];
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + scratch_0[_S319 + u32(1)].xyz;
            fi_0 = fi_0 + fa_2.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + scratch_0[_S319 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_2.xyz);
            mi_0 = mi_2;
        }
        var _S320 : f32 = max(peak_0, fa_2.w);
        var _S321 : u32 = e_2 + u32(1);
        peak_0 = _S320;
        e_2 = _S321;
    }
    var _S322 : u32 = u32(4) * c_13;
    var u_0 : vec3<f32> = state_0[_S322].xyz;
    var _S323 : u32 = _S322 + u32(1);
    var th_1 : vec3<f32> = state_0[_S323].xyz;
    var _S324 : u32 = _S322 + u32(2);
    var v_8 : vec3<f32> = state_0[_S324].xyz;
    var _S325 : u32 = _S322 + u32(3);
    var w_5 : vec3<f32> = state_0[_S325].xyz;
    var mass_0 : f32 = chunks_0[c_13].center_0.w;
    var _S326 : vec3<f32> = chunks_0[c_13].center_0.xyz;
    var _S327 : vec3<f32> = (*isl_8).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_6.rot_0, _S326 + u_0 - _S327);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    chunk_external_0(c_13, c_13, rg_6.rot_0, step_0, dt_11, contact_3, &(f_load_0), &(t_load_0));
    var _S328 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S328;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_6.rot_0, chunks_0[c_13].inertia0_1, chunks_0[c_13].inertia1_1, chunks_0[c_13].inertia2_1, rg_6.alpha_0) + cross(rg_6.w_4, world_mul_0(rg_6.rot_0, chunks_0[c_13].inertia0_1, chunks_0[c_13].inertia1_1, chunks_0[c_13].inertia2_1, rg_6.w_4)));
        f_world_1 = f_world_0 - (rg_6.a_6 + cross(rg_6.alpha_0, r_world_0) + cross(rg_6.w_4, cross(rg_6.w_4, r_world_0))) * _S328;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    var f_ext_0 : vec3<f32> = inverse_rotate_0(rg_6.rot_0, f_world_1);
    var m_ext_0 : vec3<f32> = inverse_rotate_0(rg_6.rot_0, t_world_1);
    var f_ext_1 : vec3<f32>;
    var m_ext_1 : vec3<f32>;
    if(rml_0)
    {
        var wb_1 : vec3<f32> = inverse_rotate_0(rg_6.rot_0, rg_6.w_4);
        var i_w_0 : vec3<f32> = rows_mul_0(chunks_0[c_13].inertia0_1, chunks_0[c_13].inertia1_1, chunks_0[c_13].inertia2_1, w_5);
        var m_ext_2 : vec3<f32> = m_ext_0 - (cross(wb_1, i_w_0) + cross(w_5, rows_mul_0(chunks_0[c_13].inertia0_1, chunks_0[c_13].inertia1_1, chunks_0[c_13].inertia2_1, wb_1)) + cross(w_5, i_w_0));
        f_ext_1 = f_ext_0 - cross(wb_1, v_8) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var _S329 : vec4<u32> = chunks_0[c_13].load_range_0;
    var term_4 : u32 = chunks_0[c_13].load_range_0.x;
    loop
    {
        if(term_4 < (_S329.y))
        {
        }
        else
        {
            break;
        }
        var _S330 : u32 = u32(5) * term_4;
        if(((bitcast<vec4<u32>>((loads_0[_S330]))).y) != u32(2))
        {
            term_4 = term_4 + u32(1);
            continue;
        }
        var _S331 : vec3<f32> = vec3<f32>(eval_function_0(term_4, step_0, dt_11, dt_11));
        var m_ext_3 : vec3<f32> = m_ext_1 + loads_0[_S330 + u32(2)].xyz * _S331;
        f_ext_1 = f_ext_1 + loads_0[_S330 + u32(1)].xyz * _S331;
        m_ext_1 = m_ext_3;
        term_4 = term_4 + u32(1);
    }
    var f_12 : vec3<f32> = f_ext_1 + fi_0;
    var m_5 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_13].info_1.x;
    var _S332 : vec3<f32> = vec3<f32>(state_0[_S323].w, state_0[_S324].w, state_0[_S325].w);
    var reaction_0 : vec3<f32>;
    var u_1 : vec3<f32>;
    var th_2 : vec3<f32>;
    var v_9 : vec3<f32>;
    var w_6 : vec3<f32>;
    if(support_0 == u32(1))
    {
        reaction_0 = (vec3<f32>(0) - f_12);
        u_1 = u_0;
        th_2 = th_1;
        v_9 = _S317;
        w_6 = _S317;
    }
    else
    {
        var _S333 : vec4<f32> = chunks_0[c_13].scale_0;
        var w_7 : vec3<f32> = w_5 + rows_mul_0(chunks_0[c_13].inv0_1, chunks_0[c_13].inv1_1, chunks_0[c_13].inv2_1, m_5) * vec3<f32>((dt_11 * chunks_0[c_13].scale_0.z));
        var _S334 : vec3<f32> = vec3<f32>(dt_11);
        var th_3 : vec3<f32> = th_1 + w_7 * _S334;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_12);
            u_1 = u_0;
            th_2 = _S317;
        }
        else
        {
            var v_10 : vec3<f32> = v_8 + f_12 * vec3<f32>((dt_11 * _S333.y));
            var u_2 : vec3<f32> = u_0 + v_10 * _S334;
            reaction_0 = _S332;
            u_1 = u_2;
            th_2 = v_10;
        }
        var _S335 : vec3<f32> = th_2;
        th_2 = th_3;
        v_9 = _S335;
        w_6 = w_7;
    }
    state_0[_S322] = vec4<f32>(u_1, peak_0);
    state_0[_S323] = vec4<f32>(th_2, reaction_0.x);
    state_0[_S324] = vec4<f32>(v_9, reaction_0.y);
    state_0[_S325] = vec4<f32>(w_6, reaction_0.z);
    comp_add1_2(&((*work_1)), &((*work_err_0)), (dot(f_load_0, rg_6.vel_1 + rg_6.vel_err_1 + cross(rg_6.w_4, rotate_0(rg_6.rot_0, _S326 + u_1 - _S327)) + rotate_0(rg_6.rot_0, v_9)) + dot(t_load_0, rg_6.w_4 + rotate_0(rg_6.rot_0, w_6))) * dt_11);
    return;
}

fn chunk_update_1( c_14 : u32,  isl_9 : Island_0,  rg_7 : Rigid_0,  dt_12 : f32,  rml_1 : bool,  step_1 : u32,  contact_4 : bool,  work_2 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S336 : vec3<f32> = vec3<f32>(0.0f);
    var _S337 : u32 = index_0[c_14];
    var peak_1 : f32 = 0.0f;
    var e_3 : u32 = _S337;
    var fi_1 : vec3<f32> = _S336;
    var mi_3 : vec3<f32> = _S336;
    loop
    {
        if(e_3 < index_0[c_14 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_3 : u32 = index_0[e_3];
        var _S338 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var fa_3 : vec4<f32> = scratch_0[_S338];
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            var mi_4 : vec3<f32> = mi_3 + scratch_0[_S338 + u32(1)].xyz;
            fi_1 = fi_1 + fa_3.xyz;
            mi_3 = mi_4;
        }
        else
        {
            var mi_5 : vec3<f32> = mi_3 + scratch_0[_S338 + u32(2)].xyz;
            fi_1 = fi_1 + (vec3<f32>(0) - fa_3.xyz);
            mi_3 = mi_5;
        }
        var _S339 : f32 = max(peak_1, fa_3.w);
        var _S340 : u32 = e_3 + u32(1);
        peak_1 = _S339;
        e_3 = _S340;
    }
    var _S341 : u32 = u32(4) * c_14;
    var u_3 : vec3<f32> = state_0[_S341].xyz;
    var _S342 : u32 = _S341 + u32(1);
    var th_4 : vec3<f32> = state_0[_S342].xyz;
    var _S343 : u32 = _S341 + u32(2);
    var v_11 : vec3<f32> = state_0[_S343].xyz;
    var _S344 : u32 = _S341 + u32(3);
    var w_8 : vec3<f32> = state_0[_S344].xyz;
    var mass_1 : f32 = chunks_0[c_14].center_0.w;
    var _S345 : vec3<f32> = chunks_0[c_14].center_0.xyz;
    var _S346 : vec3<f32> = isl_9.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_7.rot_0, _S345 + u_3 - _S346);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    chunk_external_0(c_14, c_14, rg_7.rot_0, step_1, dt_12, contact_4, &(f_load_1), &(t_load_1));
    var _S347 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S347;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_7.rot_0, chunks_0[c_14].inertia0_1, chunks_0[c_14].inertia1_1, chunks_0[c_14].inertia2_1, rg_7.alpha_0) + cross(rg_7.w_4, world_mul_0(rg_7.rot_0, chunks_0[c_14].inertia0_1, chunks_0[c_14].inertia1_1, chunks_0[c_14].inertia2_1, rg_7.w_4)));
        f_world_3 = f_world_2 - (rg_7.a_6 + cross(rg_7.alpha_0, r_world_1) + cross(rg_7.w_4, cross(rg_7.w_4, r_world_1))) * _S347;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_3 = f_world_2;
        t_world_4 = t_world_3;
    }
    var f_ext_2 : vec3<f32> = inverse_rotate_0(rg_7.rot_0, f_world_3);
    var m_ext_4 : vec3<f32> = inverse_rotate_0(rg_7.rot_0, t_world_4);
    var f_ext_3 : vec3<f32>;
    var m_ext_5 : vec3<f32>;
    if(rml_1)
    {
        var wb_2 : vec3<f32> = inverse_rotate_0(rg_7.rot_0, rg_7.w_4);
        var i_w_1 : vec3<f32> = rows_mul_0(chunks_0[c_14].inertia0_1, chunks_0[c_14].inertia1_1, chunks_0[c_14].inertia2_1, w_8);
        var m_ext_6 : vec3<f32> = m_ext_4 - (cross(wb_2, i_w_1) + cross(w_8, rows_mul_0(chunks_0[c_14].inertia0_1, chunks_0[c_14].inertia1_1, chunks_0[c_14].inertia2_1, wb_2)) + cross(w_8, i_w_1));
        f_ext_3 = f_ext_2 - cross(wb_2, v_11) * vec3<f32>((2.0f * mass_1));
        m_ext_5 = m_ext_6;
    }
    else
    {
        f_ext_3 = f_ext_2;
        m_ext_5 = m_ext_4;
    }
    var _S348 : vec4<u32> = chunks_0[c_14].load_range_0;
    var term_5 : u32 = chunks_0[c_14].load_range_0.x;
    loop
    {
        if(term_5 < (_S348.y))
        {
        }
        else
        {
            break;
        }
        var _S349 : u32 = u32(5) * term_5;
        if(((bitcast<vec4<u32>>((loads_0[_S349]))).y) != u32(2))
        {
            term_5 = term_5 + u32(1);
            continue;
        }
        var _S350 : vec3<f32> = vec3<f32>(eval_function_0(term_5, step_1, dt_12, dt_12));
        var m_ext_7 : vec3<f32> = m_ext_5 + loads_0[_S349 + u32(2)].xyz * _S350;
        f_ext_3 = f_ext_3 + loads_0[_S349 + u32(1)].xyz * _S350;
        m_ext_5 = m_ext_7;
        term_5 = term_5 + u32(1);
    }
    var f_13 : vec3<f32> = f_ext_3 + fi_1;
    var m_6 : vec3<f32> = m_ext_5 + mi_3;
    var support_1 : u32 = chunks_0[c_14].info_1.x;
    var _S351 : vec3<f32> = vec3<f32>(state_0[_S342].w, state_0[_S343].w, state_0[_S344].w);
    var reaction_1 : vec3<f32>;
    var u_4 : vec3<f32>;
    var th_5 : vec3<f32>;
    var v_12 : vec3<f32>;
    var w_9 : vec3<f32>;
    if(support_1 == u32(1))
    {
        reaction_1 = (vec3<f32>(0) - f_13);
        u_4 = u_3;
        th_5 = th_4;
        v_12 = _S336;
        w_9 = _S336;
    }
    else
    {
        var _S352 : vec4<f32> = chunks_0[c_14].scale_0;
        var w_10 : vec3<f32> = w_8 + rows_mul_0(chunks_0[c_14].inv0_1, chunks_0[c_14].inv1_1, chunks_0[c_14].inv2_1, m_6) * vec3<f32>((dt_12 * chunks_0[c_14].scale_0.z));
        var _S353 : vec3<f32> = vec3<f32>(dt_12);
        var th_6 : vec3<f32> = th_4 + w_10 * _S353;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_13);
            u_4 = u_3;
            th_5 = _S336;
        }
        else
        {
            var v_13 : vec3<f32> = v_11 + f_13 * vec3<f32>((dt_12 * _S352.y));
            var u_5 : vec3<f32> = u_3 + v_13 * _S353;
            reaction_1 = _S351;
            u_4 = u_5;
            th_5 = v_13;
        }
        var _S354 : vec3<f32> = th_5;
        th_5 = th_6;
        v_12 = _S354;
        w_9 = w_10;
    }
    state_0[_S341] = vec4<f32>(u_4, peak_1);
    state_0[_S342] = vec4<f32>(th_5, reaction_1.x);
    state_0[_S343] = vec4<f32>(v_12, reaction_1.y);
    state_0[_S344] = vec4<f32>(w_9, reaction_1.z);
    comp_add1_2(&((*work_2)), &((*work_err_1)), (dot(f_load_1, rg_7.vel_1 + rg_7.vel_err_1 + cross(rg_7.w_4, rotate_0(rg_7.rot_0, _S345 + u_4 - _S346)) + rotate_0(rg_7.rot_0, v_12)) + dot(t_load_1, rg_7.w_4 + rotate_0(rg_7.rot_0, w_9))) * dt_12);
    return;
}

fn integrate_rigid_0( isl_10 : ptr<function, Island_std430_0>,  rg_8 : ptr<function, Rigid_0>,  dt_13 : f32)
{
    var iw_w_2 : vec3<f32> = world_mul_0((*rg_8).rot_0, (*isl_10).inertia0_0, (*isl_10).inertia1_0, (*isl_10).inertia2_0, (*rg_8).w_4);
    var _S355 : vec3<f32> = vec3<f32>(dt_13);
    var l_2 : vec3<f32> = iw_w_2 + (world_mul_0((*rg_8).rot_0, (*isl_10).inertia0_0, (*isl_10).inertia1_0, (*isl_10).inertia2_0, (*rg_8).alpha_0) + cross((*rg_8).w_4, iw_w_2)) * _S355;
    var _S356 : vec3<f32> = (*rg_8).a_6 * _S355;
    var _S357 : vec3<f32> = (*rg_8).vel_1;
    var _S358 : vec3<f32> = (*rg_8).vel_err_1;
    comp_add_0(&(_S357), &(_S358), _S356);
    (*rg_8).vel_1 = _S357;
    (*rg_8).vel_err_1 = _S358;
    var _S359 : vec4<f32> = (*isl_10).inv0_0;
    var _S360 : vec4<f32> = (*isl_10).inv1_0;
    var _S361 : vec4<f32> = (*isl_10).inv2_0;
    var rot1_0 : Quat_0 = integrate_rotation_0((*rg_8).rot_0, world_mul_0((*rg_8).rot_0, (*isl_10).inv0_0, (*isl_10).inv1_0, (*isl_10).inv2_0, l_2), dt_13);
    var _S362 : vec3<f32> = (*isl_10).com_0.xyz;
    var delta_0 : vec3<f32> = (_S357 + _S358) * _S355 + (rotate_0((*rg_8).rot_0, _S362) - rotate_0(rot1_0, _S362));
    var _S363 : vec3<f32> = (*rg_8).pos_1;
    var _S364 : vec3<f32> = (*rg_8).pos_err_1;
    comp_add_0(&(_S363), &(_S364), delta_0);
    (*rg_8).pos_1 = _S363;
    (*rg_8).pos_err_1 = _S364;
    (*rg_8).rot_0 = rot1_0;
    (*rg_8).w_4 = world_mul_0(rot1_0, _S359, _S360, _S361, l_2);
    return;
}

fn integrate_rigid_1( isl_11 : Island_0,  rg_9 : ptr<function, Rigid_0>,  dt_14 : f32)
{
    var iw_w_3 : vec3<f32> = world_mul_0((*rg_9).rot_0, isl_11.inertia0_0, isl_11.inertia1_0, isl_11.inertia2_0, (*rg_9).w_4);
    var _S365 : vec3<f32> = vec3<f32>(dt_14);
    var l_3 : vec3<f32> = iw_w_3 + (world_mul_0((*rg_9).rot_0, isl_11.inertia0_0, isl_11.inertia1_0, isl_11.inertia2_0, (*rg_9).alpha_0) + cross((*rg_9).w_4, iw_w_3)) * _S365;
    var _S366 : vec3<f32> = (*rg_9).a_6 * _S365;
    var _S367 : vec3<f32> = (*rg_9).vel_1;
    var _S368 : vec3<f32> = (*rg_9).vel_err_1;
    comp_add_0(&(_S367), &(_S368), _S366);
    (*rg_9).vel_1 = _S367;
    (*rg_9).vel_err_1 = _S368;
    var rot1_1 : Quat_0 = integrate_rotation_0((*rg_9).rot_0, world_mul_0((*rg_9).rot_0, isl_11.inv0_0, isl_11.inv1_0, isl_11.inv2_0, l_3), dt_14);
    var _S369 : vec3<f32> = isl_11.com_0.xyz;
    var delta_1 : vec3<f32> = (_S367 + _S368) * _S365 + (rotate_0((*rg_9).rot_0, _S369) - rotate_0(rot1_1, _S369));
    var _S370 : vec3<f32> = (*rg_9).pos_1;
    var _S371 : vec3<f32> = (*rg_9).pos_err_1;
    comp_add_0(&(_S370), &(_S371), delta_1);
    (*rg_9).pos_1 = _S370;
    (*rg_9).pos_err_1 = _S371;
    (*rg_9).rot_0 = rot1_1;
    (*rg_9).w_4 = world_mul_0(rot1_1, isl_11.inv0_0, isl_11.inv1_0, isl_11.inv2_0, l_3);
    return;
}

fn drift_moments_0( c_15 : u32,  tu_0 : ptr<function, vec3<f32>>,  pv_0 : ptr<function, vec3<f32>>)
{
    var _S372 : u32 = u32(4) * c_15;
    var _S373 : vec3<f32> = vec3<f32>((chunks_0[c_15].center_0.w * chunks_0[c_15].scale_0.x));
    (*tu_0) = (*tu_0) + state_0[_S372].xyz * _S373;
    (*pv_0) = (*pv_0) + state_0[_S372 + u32(2)].xyz * _S373;
    return;
}

fn drift_angular_0( c_16 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_12 : vec3<f32> = chunks_0[c_16].center_0.xyz - wcom_1;
    var _S374 : u32 = u32(4) * c_16;
    var _S375 : vec3<f32> = vec3<f32>(chunks_0[c_16].center_0.w);
    var _S376 : vec4<f32> = chunks_0[c_16].inertia0_1;
    var _S377 : vec4<f32> = chunks_0[c_16].inertia1_1;
    var _S378 : vec4<f32> = chunks_0[c_16].inertia2_1;
    var _S379 : vec3<f32> = vec3<f32>(chunks_0[c_16].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_12, state_0[_S374].xyz - tr_0) * _S375 + rows_mul_0(chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, state_0[_S374 + u32(1)].xyz)) * _S379;
    (*lv_0) = (*lv_0) + (cross(r_12, state_0[_S374 + u32(2)].xyz - dv_0) * _S375 + rows_mul_0(_S376, _S377, _S378, state_0[_S374 + u32(3)].xyz)) * _S379;
    return;
}

fn drift_apply_0( c_17 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  phi_0 : vec3<f32>,  dv_1 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_13 : vec3<f32> = chunks_0[c_17].center_0.xyz - wcom_2;
    var _S380 : u32 = u32(4) * c_17;
    state_0[_S380] = vec4<f32>(state_0[_S380].xyz - (tr_1 + cross(phi_0, r_13)), state_0[_S380].w);
    var _S381 : u32 = _S380 + u32(1);
    state_0[_S381] = vec4<f32>(state_0[_S381].xyz - phi_0, state_0[_S381].w);
    var _S382 : u32 = _S380 + u32(2);
    state_0[_S382] = vec4<f32>(state_0[_S382].xyz - (dv_1 + cross(dw_0, r_13)), state_0[_S382].w);
    var _S383 : u32 = _S380 + u32(3);
    state_0[_S383] = vec4<f32>(state_0[_S383].xyz - dw_0, state_0[_S383].w);
    return;
}

fn drift_rigid_0( isl_12 : ptr<function, Island_std430_0>,  rg_10 : ptr<function, Rigid_0>,  tr_2 : vec3<f32>,  phi_1 : vec3<f32>,  dv_2 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_3 : vec3<f32> = (*isl_12).wcom_0.xyz;
    var rot_1 : Quat_0 = (*rg_10).rot_0;
    var _S384 : vec3<f32> = rotate_0((*rg_10).rot_0, tr_2 - cross(phi_1, wcom_3));
    var _S385 : vec3<f32> = (*rg_10).pos_1;
    var _S386 : vec3<f32> = (*rg_10).pos_err_1;
    comp_add_0(&(_S385), &(_S386), _S384);
    (*rg_10).pos_1 = _S385;
    (*rg_10).pos_err_1 = _S386;
    (*rg_10).rot_0 = normalized_0(quat_mul_0((*rg_10).rot_0, from_axis_angle_0(phi_1, length(phi_1))));
    var _S387 : vec3<f32> = rotate_0(rot_1, dv_2 + cross(dw_1, (*isl_12).com_0.xyz - wcom_3));
    var _S388 : vec3<f32> = (*rg_10).vel_1;
    var _S389 : vec3<f32> = (*rg_10).vel_err_1;
    comp_add_0(&(_S388), &(_S389), _S387);
    (*rg_10).vel_1 = _S388;
    (*rg_10).vel_err_1 = _S389;
    (*rg_10).w_4 = (*rg_10).w_4 + rotate_0(rot_1, dw_1);
    return;
}

fn drift_rigid_1( isl_13 : Island_0,  rg_11 : ptr<function, Rigid_0>,  tr_3 : vec3<f32>,  phi_2 : vec3<f32>,  dv_3 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = isl_13.wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_11).rot_0;
    var _S390 : vec3<f32> = rotate_0((*rg_11).rot_0, tr_3 - cross(phi_2, wcom_4));
    var _S391 : vec3<f32> = (*rg_11).pos_1;
    var _S392 : vec3<f32> = (*rg_11).pos_err_1;
    comp_add_0(&(_S391), &(_S392), _S390);
    (*rg_11).pos_1 = _S391;
    (*rg_11).pos_err_1 = _S392;
    (*rg_11).rot_0 = normalized_0(quat_mul_0((*rg_11).rot_0, from_axis_angle_0(phi_2, length(phi_2))));
    var _S393 : vec3<f32> = rotate_0(rot_2, dv_3 + cross(dw_2, isl_13.com_0.xyz - wcom_4));
    var _S394 : vec3<f32> = (*rg_11).vel_1;
    var _S395 : vec3<f32> = (*rg_11).vel_err_1;
    comp_add_0(&(_S394), &(_S395), _S393);
    (*rg_11).vel_1 = _S394;
    (*rg_11).vel_err_1 = _S395;
    (*rg_11).w_4 = (*rg_11).w_4 + rotate_0(rot_2, dw_2);
    return;
}

fn write_probe_0( slot_1 : u32,  k_18 : u32,  value_1 : f32)
{
    var at_4 : u32 = params_0.probe_base_0 * u32(4) + slot_1 * params_0.probe_stride_0 + k_18;
    var v_14 : vec4<f32> = scratch_0[at_4 / u32(4)];
    v_14[at_4 % u32(4)] = value_1;
    scratch_0[at_4 / u32(4)] = v_14;
    return;
}

fn record_probes_0( isl_14 : Island_0,  rg_12 : Rigid_0,  k_19 : u32)
{
    var at_5 : u32 = isl_14.probes_0.x;
    loop
    {
        if(at_5 < (isl_14.probes_0.y))
        {
        }
        else
        {
            break;
        }
        var info_3 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[at_5])));
        var a_12 : vec4<f32> = loads_0[at_5 + u32(1)];
        var b_23 : vec4<f32> = loads_0[at_5 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_5 + u32(3)];
        var kind_4 : u32 = info_3.x;
        var i_8 : u32 = info_3.y;
        var value_2 : f32;
        if(kind_4 == u32(0))
        {
            value_2 = dot(rg_12.pos_1 - b_23.xyz + (rg_12.pos_err_1 - c4_0.xyz) + rotate_0(rg_12.rot_0, chunks_0[i_8].center_0.xyz + state_0[u32(4) * i_8].xyz), a_12.xyz);
        }
        else
        {
            if(kind_4 == u32(1))
            {
                var _S396 : u32 = u32(4) * i_8;
                value_2 = dot(rg_12.vel_1 + rg_12.vel_err_1 + cross(rg_12.w_4, rotate_0(rg_12.rot_0, chunks_0[i_8].center_0.xyz + state_0[_S396].xyz - isl_14.com_0.xyz)) + rotate_0(rg_12.rot_0, state_0[_S396 + u32(2)].xyz), a_12.xyz);
            }
            else
            {
                if(kind_4 == u32(2))
                {
                    var _S397 : u32 = u32(3) * i_8;
                    var f_14 : vec3<f32> = scratch_0[_S397].xyz;
                    var _S398 : bool = (info_3.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S398)
                    {
                        mc_0 = scratch_0[_S397 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S397 + u32(2)].xyz;
                    }
                    var fc_4 : vec3<f32>;
                    if(_S398)
                    {
                        fc_4 = f_14;
                    }
                    else
                    {
                        fc_4 = (vec3<f32>(0) - f_14);
                    }
                    value_2 = dot(fc_4, a_12.xyz) + dot(mc_0, b_23.xyz);
                }
                else
                {
                    var _S399 : u32 = u32(4) * i_8;
                    value_2 = dot(rotate_0(rg_12.rot_0, vec3<f32>(state_0[_S399 + u32(1)].w, state_0[_S399 + u32(2)].w, state_0[_S399 + u32(3)].w)), a_12.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_19, value_2);
        at_5 = at_5 + u32(4);
    }
    return;
}

fn contact_split_at_0( at_6 : u32)
{
    var previous_1 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S400 : u32;
    if(previous_1 == u32(0))
    {
        _S400 = at_6;
    }
    else
    {
        _S400 = min(previous_1, at_6);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S400;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var tid_4 : u32 = thread_2.x;
    var _S401 : u32 = group_2.x;
    var isl_15 : Island_0;
    isl_15.range_0 = islands_0[_S401].range_0;
    isl_15.info_0 = islands_0[_S401].info_0;
    isl_15.com_0 = islands_0[_S401].com_0;
    isl_15.inertia0_0 = islands_0[_S401].inertia0_0;
    isl_15.inertia1_0 = islands_0[_S401].inertia1_0;
    isl_15.inertia2_0 = islands_0[_S401].inertia2_0;
    isl_15.inv0_0 = islands_0[_S401].inv0_0;
    isl_15.inv1_0 = islands_0[_S401].inv1_0;
    isl_15.inv2_0 = islands_0[_S401].inv2_0;
    isl_15.wcom_0 = islands_0[_S401].wcom_0;
    isl_15.winv0_0 = islands_0[_S401].winv0_0;
    isl_15.winv1_0 = islands_0[_S401].winv1_0;
    isl_15.winv2_0 = islands_0[_S401].winv2_0;
    isl_15.rotation_0 = islands_0[_S401].rotation_0;
    isl_15.position_0 = islands_0[_S401].position_0;
    isl_15.position_err_0 = islands_0[_S401].position_err_0;
    isl_15.velocity_0 = islands_0[_S401].velocity_0;
    isl_15.velocity_err_0 = islands_0[_S401].velocity_err_0;
    isl_15.angular_velocity_0 = islands_0[_S401].angular_velocity_0;
    isl_15.done_0 = islands_0[_S401].done_0;
    isl_15.probes_0 = islands_0[_S401].probes_0;
    isl_15.energy_0 = islands_0[_S401].energy_0;
    var driven_0 : bool = (((isl_15.info_0.x) & (u32(2)))) != u32(0);
    var _S402 : bool = !((((isl_15.info_0.x) & (u32(1)))) != u32(0));
    var _S403 : bool;
    if(_S402)
    {
        _S403 = !driven_0;
    }
    else
    {
        _S403 = false;
    }
    var contact_island_0 : bool = (((isl_15.info_0.x) & (u32(4)))) != u32(0);
    var _S404 : bool = tid_4 == u32(0);
    var _S405 : bool;
    var run_0 : u32;
    if(_S404)
    {
        if(contact_island_0 != ((params_0.contact_mode_0) == u32(1)))
        {
            _S405 = true;
        }
        else
        {
            _S405 = (((isl_15.info_0.x) & (u32(8)))) != u32(0);
        }
        if(_S405)
        {
            run_0 = u32(0);
        }
        else
        {
            run_0 = u32(1);
        }
        if(contact_island_0)
        {
            _S405 = contact_stopped_1(isl_15);
        }
        else
        {
            _S405 = false;
        }
        if(_S405)
        {
            run_0 = u32(0);
        }
        g_run_0 = run_0;
        g_halt_0 = u32(0);
    }
    workgroupBarrier();
    if((((isl_15.info_0.z) & (u32(1)))) != u32(0))
    {
        _S405 = true;
    }
    else
    {
        _S405 = g_run_0 == u32(0);
    }
    if(_S405)
    {
        run_0 = u32(0);
    }
    else
    {
        run_0 = min(isl_15.info_0.y, params_0.max_steps_0);
    }
    var _S406 : f32 = params_0.dt_0;
    var _S407 : bool = (params_0.fracture_0) != u32(0);
    var _S408 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_13 : Rigid_0 = rigid_of_1(isl_15);
    var work_3 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    var done_1 : u32 = u32(0);
    loop
    {
        if(done_1 < run_0)
        {
        }
        else
        {
            break;
        }
        var abs_step_1 : u32 = isl_15.info_0.w + done_1 + u32(1);
        var k_20 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var i_9 : u32;
        if(_S402)
        {
            var _S409 : vec3<f32> = vec3<f32>(0.0f);
            var f_15 : vec3<f32> = _S409;
            var t_12 : vec3<f32> = _S409;
            i_9 = isl_15.range_0.x + tid_4;
            loop
            {
                if(i_9 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                net_load_1(i_9, isl_15, rg_13, k_20, _S406, contact_island_0, &(f_15), &(t_12));
                i_9 = i_9 + u32(256);
            }
            group_sum3_0(tid_4, &(f_15), &(t_12));
            rigid_acceleration_1(isl_15, &(rg_13), f_15, t_12);
        }
        i_9 = isl_15.range_0.z + tid_4;
        loop
        {
            if(i_9 < (isl_15.range_0.w))
            {
            }
            else
            {
                break;
            }
            var _S410 : bool = bond_update_0(i_9, _S406, _S407, abs_step_1);
            if(_S410)
            {
                g_halt_0 = u32(1);
            }
            i_9 = i_9 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_18 : u32 = isl_15.range_0.x + tid_4;
        loop
        {
            if(c_18 < (isl_15.range_0.y))
            {
            }
            else
            {
                break;
            }
            chunk_update_1(c_18, isl_15, rg_13, _S406, _S408, k_20, contact_island_0, &(work_3), &(work_err_2));
            c_18 = c_18 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S403)
        {
            integrate_rigid_1(isl_15, &(rg_13), _S406);
        }
        if(_S402)
        {
            var _S411 : vec3<f32> = isl_15.wcom_0.xyz;
            var _S412 : vec3<f32> = vec3<f32>(0.0f);
            var tu_1 : vec3<f32> = _S412;
            var pv_1 : vec3<f32> = _S412;
            var c_19 : u32 = isl_15.range_0.x + tid_4;
            loop
            {
                if(c_19 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_19, &(tu_1), &(pv_1));
                c_19 = c_19 + u32(256);
            }
            group_sum3_0(tid_4, &(tu_1), &(pv_1));
            var tr_4 : vec3<f32> = tu_1 / vec3<f32>(isl_15.wcom_0.w);
            var dv_4 : vec3<f32> = pv_1 / vec3<f32>(isl_15.wcom_0.w);
            var lu_1 : vec3<f32> = _S412;
            var lv_1 : vec3<f32> = _S412;
            var c_20 : u32 = isl_15.range_0.x + tid_4;
            loop
            {
                if(c_20 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_20, _S411, tr_4, dv_4, &(lu_1), &(lv_1));
                c_20 = c_20 + u32(256);
            }
            group_sum3_0(tid_4, &(lu_1), &(lv_1));
            var phi_3 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lu_1);
            var dw_3 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lv_1);
            var c_21 : u32 = isl_15.range_0.x + tid_4;
            loop
            {
                if(c_21 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_21, _S411, tr_4, phi_3, dv_4, dw_3);
                c_21 = c_21 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_15, &(rg_13), tr_4, phi_3, dv_4, dw_3);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S404)
        {
            _S405 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
        }
        else
        {
            _S405 = false;
        }
        if(_S405)
        {
            record_probes_0(isl_15, rg_13, k_20);
        }
        var _S413 : u32 = done_1 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S413;
            break;
        }
        done_1 = _S413;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_3, work_err_2, 0.0f);
    var unused_2 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_4, &(wsum_0), &(unused_2));
    if(_S404)
    {
        isl_15.rotation_0 = quat_vec_0(rg_13.rot_0);
        isl_15.position_0 = vec4<f32>(rg_13.pos_1, 0.0f);
        isl_15.position_err_0 = vec4<f32>(rg_13.pos_err_1, 0.0f);
        isl_15.velocity_0 = vec4<f32>(rg_13.vel_1, 0.0f);
        isl_15.velocity_err_0 = vec4<f32>(rg_13.vel_err_1, 0.0f);
        isl_15.angular_velocity_0 = vec4<f32>(rg_13.w_4, 0.0f);
        isl_15.done_0[i32(0)] = done_1;
        isl_15.info_0[i32(1)] = isl_15.info_0[i32(1)] - done_1;
        if(g_halt_0 != u32(0))
        {
            _S403 = contact_island_0;
        }
        else
        {
            _S403 = false;
        }
        if(_S403)
        {
            contact_split_at_0(isl_15.info_0.w + done_1);
        }
        var _S414 : f32 = wsum_0.x;
        var _S415 : f32 = isl_15.energy_0[i32(0)];
        var _S416 : f32 = isl_15.energy_0[i32(1)];
        comp_add1_2(&(_S415), &(_S416), _S414);
        isl_15.energy_0[i32(0)] = _S415;
        isl_15.energy_0[i32(1)] = _S416 + wsum_0.y;
        isl_15.info_0[i32(3)] = isl_15.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_15.info_0[i32(2)] = ((isl_15.info_0[i32(2)]) | (u32(1)));
        }
        islands_0[_S401].range_0 = isl_15.range_0;
        islands_0[_S401].info_0 = isl_15.info_0;
        islands_0[_S401].com_0 = isl_15.com_0;
        islands_0[_S401].inertia0_0 = isl_15.inertia0_0;
        islands_0[_S401].inertia1_0 = isl_15.inertia1_0;
        islands_0[_S401].inertia2_0 = isl_15.inertia2_0;
        islands_0[_S401].inv0_0 = isl_15.inv0_0;
        islands_0[_S401].inv1_0 = isl_15.inv1_0;
        islands_0[_S401].inv2_0 = isl_15.inv2_0;
        islands_0[_S401].wcom_0 = isl_15.wcom_0;
        islands_0[_S401].winv0_0 = isl_15.winv0_0;
        islands_0[_S401].winv1_0 = isl_15.winv1_0;
        islands_0[_S401].winv2_0 = isl_15.winv2_0;
        islands_0[_S401].rotation_0 = isl_15.rotation_0;
        islands_0[_S401].position_0 = isl_15.position_0;
        islands_0[_S401].position_err_0 = isl_15.position_err_0;
        islands_0[_S401].velocity_0 = isl_15.velocity_0;
        islands_0[_S401].velocity_err_0 = isl_15.velocity_err_0;
        islands_0[_S401].angular_velocity_0 = isl_15.angular_velocity_0;
        islands_0[_S401].done_0 = isl_15.done_0;
        islands_0[_S401].probes_0 = isl_15.probes_0;
        islands_0[_S401].energy_0 = isl_15.energy_0;
    }
    return;
}

struct WideGroup_0
{
     island_0 : u32,
     begin_1 : u32,
     end_0 : u32,
     first_1 : u32,
};

fn wide_group_0( table_0 : u32,  g_3 : u32) -> WideGroup_0
{
    var w_11 : WideGroup_0;
    var _S417 : u32 = table_0 + u32(4) * g_3;
    w_11.island_0 = index_0[_S417];
    w_11.begin_1 = index_0[_S417 + u32(1)];
    w_11.end_0 = index_0[_S417 + u32(2)];
    w_11.first_1 = index_0[_S417 + u32(3)];
    return w_11;
}

fn wide_runs_0( isl_16 : ptr<function, Island_std430_0>) -> bool
{
    var _S418 : vec4<u32> = (*isl_16).info_0;
    var _S419 : bool;
    if(((((*isl_16).info_0.z) & (u32(1)))) != u32(0))
    {
        _S419 = true;
    }
    else
    {
        _S419 = (_S418.y) == u32(0);
    }
    if(_S419)
    {
        return false;
    }
    if((((_S418.x) & (u32(4)))) == u32(0))
    {
        _S419 = true;
    }
    else
    {
        var _S420 : bool = contact_stopped_0(&((*isl_16)));
        _S419 = !_S420;
    }
    return _S419;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_5 : u32,  isl_17 : ptr<function, Island_std430_0>) -> bool
{
    if(tid_5 == u32(0))
    {
        var _S421 : bool = wide_runs_0(&((*isl_17)));
        var _S422 : i32;
        if(_S421)
        {
            _S422 = i32(1);
        }
        else
        {
            _S422 = i32(0);
        }
        g_wide_run_0 = u32(_S422);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

fn wide_step_0( isl_18 : ptr<function, Island_std430_0>) -> u32
{
    return (*isl_18).info_0.w - params_0.step_start_0;
}

fn wide_step_1( isl_19 : Island_0) -> u32
{
    return isl_19.info_0.w - params_0.step_start_0;
}

fn wide_store_0( slot_2 : u32,  p_16 : u32,  a_13 : vec3<f32>,  b_24 : vec3<f32>)
{
    var _S423 : u32 = u32(8) * slot_2;
    scratch_0[params_0.wide_base_0 + _S423 + p_16] = vec4<f32>(a_13, 0.0f);
    scratch_0[params_0.wide_base_0 + _S423 + p_16 + u32(1)] = vec4<f32>(b_24, 0.0f);
    return;
}

fn contact_stopped_2( _S424 : u32) -> bool
{
    var _S425 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S426 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S426 = true;
    }
    else
    {
        var _S427 : u32 = _S425.y;
        if(_S427 != u32(0))
        {
            _S426 = _S427 <= (islands_0[_S424].info_0.w);
        }
        else
        {
            _S426 = false;
        }
    }
    return _S426;
}

fn wide_runs_1( _S428 : u32) -> bool
{
    var _S429 : vec4<u32> = islands_0[_S428].info_0;
    var _S430 : bool;
    if((((islands_0[_S428].info_0.z) & (u32(1)))) != u32(0))
    {
        _S430 = true;
    }
    else
    {
        _S430 = (_S429.y) == u32(0);
    }
    if(_S430)
    {
        return false;
    }
    if((((_S429.x) & (u32(4)))) == u32(0))
    {
        _S430 = true;
    }
    else
    {
        _S430 = !contact_stopped_2(_S428);
    }
    return _S430;
}

fn wide_enter_1( _S431 : u32,  _S432 : u32) -> bool
{
    if(_S431 == u32(0))
    {
        var _S433 : i32;
        if(wide_runs_1(_S432))
        {
            _S433 = i32(1);
        }
        else
        {
            _S433 = i32(0);
        }
        g_wide_run_0 = u32(_S433);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_6 : u32 = thread_3.x;
    var _S434 : u32 = group_3.x;
    var bond_group_0 : bool = _S434 < (params_0.wide_bond_groups_0);
    var wg_0 : WideGroup_0;
    if(bond_group_0)
    {
        wg_0 = wide_group_0(params_0.wide_bond_table_0, _S434);
    }
    else
    {
        wg_0 = wide_group_0(params_0.wide_chunk_table_0, _S434 - params_0.wide_bond_groups_0);
    }
    var _S435 : WideGroup_0 = wg_0;
    var _S436 : Island_std430_0 = islands_0[wg_0.island_0];
    var _S437 : bool = wide_enter_1(tid_6, wg_0.island_0);
    if(!_S437)
    {
        return;
    }
    var _S438 : u32 = wide_step_0(&(_S436));
    if(bond_group_0)
    {
        var i_10 : u32 = wg_0.begin_1 + tid_6;
        var _S439 : bool;
        if(i_10 < (wg_0.end_0))
        {
            var _S440 : bool = bond_update_0(i_10, params_0.dt_0, (params_0.fracture_0) != u32(0), _S436.info_0.w + u32(1));
            _S439 = _S440;
        }
        else
        {
            _S439 = false;
        }
        if(_S439)
        {
            islands_0[_S435.island_0].info_0[i32(2)] = ((_S436.info_0.z) | (u32(2)));
        }
        return;
    }
    var _S441 : u32 = _S436.info_0.x;
    if(((_S441 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S442 : vec3<f32> = vec3<f32>(0.0f);
    var f_16 : vec3<f32> = _S442;
    var t_13 : vec3<f32> = _S442;
    var c_22 : u32 = wg_0.begin_1 + tid_6;
    if(c_22 < (wg_0.end_0))
    {
        var _S443 : Rigid_0 = rigid_of_0(&(_S436));
        net_load_0(c_22, &(_S436), _S443, _S438, params_0.dt_0, ((_S441 & (u32(4)))) != u32(0), &(f_16), &(t_13));
    }
    group_sum3_0(tid_6, &(f_16), &(t_13));
    if(tid_6 == u32(0))
    {
        wide_store_0(_S434 - params_0.wide_bond_groups_0, u32(0), f_16, t_13);
    }
    return;
}

fn wide_partials_0( tid_7 : u32,  first_2 : u32,  count_6 : u32,  p_17 : u32,  a_14 : ptr<function, vec3<f32>>,  b_25 : ptr<function, vec3<f32>>)
{
    var _S444 : vec4<f32> = vec4<f32>(0.0f);
    var x_10 : vec4<f32> = _S444;
    var y_2 : vec4<f32> = _S444;
    var s_8 : u32 = tid_7;
    loop
    {
        if(s_8 < count_6)
        {
        }
        else
        {
            break;
        }
        var _S445 : u32 = u32(8) * (first_2 + s_8);
        x_10 = x_10 + scratch_0[params_0.wide_base_0 + _S445 + p_17];
        y_2 = y_2 + scratch_0[params_0.wide_base_0 + _S445 + p_17 + u32(1)];
        s_8 = s_8 + u32(256);
    }
    group_sum2_0(tid_7, &(x_10), &(y_2));
    (*a_14) = x_10.xyz;
    (*b_25) = y_2.xyz;
    return;
}

fn wide_rigid_frame_0( tid_8 : u32,  isl_20 : ptr<function, Island_std430_0>,  wg_1 : WideGroup_0) -> Rigid_0
{
    var _S446 : Rigid_0 = rigid_of_0(&((*isl_20)));
    var rg_14 : Rigid_0 = _S446;
    if(((((*isl_20).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_17 : vec3<f32>;
        var t_14 : vec3<f32>;
        wide_partials_0(tid_8, wg_1.first_1, (*isl_20).done_0.z, u32(0), &(f_17), &(t_14));
        rigid_acceleration_0(&((*isl_20)), &(rg_14), f_17, t_14);
    }
    return rg_14;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_chunks(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_9 : u32 = thread_4.x;
    var _S447 : u32 = group_4.x;
    var wg_2 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S447);
    var _S448 : Island_std430_0 = islands_0[wg_2.island_0];
    var _S449 : bool = wide_enter_1(tid_9, wg_2.island_0);
    if(!_S449)
    {
        return;
    }
    var _S450 : u32 = _S448.info_0.x;
    var anchored_0 : bool = ((_S450 & (u32(1)))) != u32(0);
    var _S451 : Rigid_0 = wide_rigid_frame_0(tid_9, &(_S448), wg_2);
    var work_4 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S452 : vec3<f32> = vec3<f32>(0.0f);
    var tu_2 : vec3<f32> = _S452;
    var pv_2 : vec3<f32> = _S452;
    var c_23 : u32 = wg_2.begin_1 + tid_9;
    if(c_23 < (wg_2.end_0))
    {
        var _S453 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S454 : u32 = wide_step_0(&(_S448));
        chunk_update_0(c_23, &(_S448), _S451, params_0.dt_0, _S453, _S454, ((_S450 & (u32(4)))) != u32(0), &(work_4), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_23, &(tu_2), &(pv_2));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_4, work_err_3, 0.0f);
    var unused_3 : vec3<f32> = _S452;
    group_sum3_0(tid_9, &(wsum_1), &(unused_3));
    var _S455 : bool = !anchored_0;
    if(_S455)
    {
        group_sum3_0(tid_9, &(tu_2), &(pv_2));
    }
    if(tid_9 == u32(0))
    {
        scratch_0[params_0.wide_base_0 + u32(8) * _S447 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S455)
        {
            wide_store_0(_S447, u32(2), tu_2, pv_2);
        }
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_5 : vec3<u32>, @builtin(local_invocation_id) thread_5 : vec3<u32>)
{
    var tid_10 : u32 = thread_5.x;
    var _S456 : u32 = group_5.x;
    var wg_3 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S456);
    var isl_21 : Island_std430_0 = islands_0[wg_3.island_0];
    var _S457 : bool;
    if((((islands_0[wg_3.island_0].info_0.x) & (u32(1)))) != u32(0))
    {
        _S457 = true;
    }
    else
    {
        var _S458 : bool = wide_enter_1(tid_10, wg_3.island_0);
        _S457 = !_S458;
    }
    if(_S457)
    {
        return;
    }
    var tu_3 : vec3<f32>;
    var pv_3 : vec3<f32>;
    wide_partials_0(tid_10, wg_3.first_1, isl_21.done_0.z, u32(2), &(tu_3), &(pv_3));
    var _S459 : vec3<f32> = vec3<f32>(isl_21.wcom_0.w);
    var tr_5 : vec3<f32> = tu_3 / _S459;
    var dv_5 : vec3<f32> = pv_3 / _S459;
    var _S460 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S460;
    var lv_2 : vec3<f32> = _S460;
    var c_24 : u32 = wg_3.begin_1 + tid_10;
    if(c_24 < (wg_3.end_0))
    {
        drift_angular_0(c_24, isl_21.wcom_0.xyz, tr_5, dv_5, &(lu_2), &(lv_2));
    }
    group_sum3_0(tid_10, &(lu_2), &(lv_2));
    if(tid_10 == u32(0))
    {
        wide_store_0(_S456, u32(4), lu_2, lv_2);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var tid_11 : u32 = thread_6.x;
    var _S461 : u32 = group_6.x;
    var wg_4 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S461);
    var _S462 : Island_std430_0 = islands_0[wg_4.island_0];
    var _S463 : u32 = _S462.info_0.x;
    var _S464 : bool;
    if(((_S463 & (u32(1)))) != u32(0))
    {
        _S464 = true;
    }
    else
    {
        var _S465 : bool = wide_enter_1(tid_11, wg_4.island_0);
        _S464 = !_S465;
    }
    if(_S464)
    {
        return;
    }
    var _S466 : u32 = _S462.done_0.z;
    var tu_4 : vec3<f32>;
    var pv_4 : vec3<f32>;
    wide_partials_0(tid_11, wg_4.first_1, _S466, u32(2), &(tu_4), &(pv_4));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_0(tid_11, wg_4.first_1, _S466, u32(4), &(lu_3), &(lv_3));
    var _S467 : vec4<f32> = _S462.wcom_0;
    var _S468 : vec3<f32> = vec3<f32>(_S462.wcom_0.w);
    var tr_6 : vec3<f32> = tu_4 / _S468;
    var dv_6 : vec3<f32> = pv_4 / _S468;
    var phi_4 : vec3<f32> = rows_mul_0(_S462.winv0_0, _S462.winv1_0, _S462.winv2_0, lu_3);
    var dw_4 : vec3<f32> = rows_mul_0(_S462.winv0_0, _S462.winv1_0, _S462.winv2_0, lv_3);
    var c_25 : u32 = wg_4.begin_1 + tid_11;
    if(c_25 < (wg_4.end_0))
    {
        drift_apply_0(c_25, _S467.xyz, tr_6, phi_4, dv_6, dw_4);
    }
    if(_S461 != (wg_4.first_1))
    {
        return;
    }
    var _S469 : Rigid_0 = wide_rigid_frame_0(tid_11, &(_S462), wg_4);
    var rg_15 : Rigid_0 = _S469;
    if(tid_11 != u32(0))
    {
        return;
    }
    if(!(((_S463 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S462), &(rg_15), params_0.dt_0);
        drift_rigid_0(&(_S462), &(rg_15), tr_6, phi_4, dv_6, dw_4);
    }
    islands_0[wg_4.island_0].rotation_0 = quat_vec_0(rg_15.rot_0);
    islands_0[wg_4.island_0].position_0 = vec4<f32>(rg_15.pos_1, 0.0f);
    islands_0[wg_4.island_0].position_err_0 = vec4<f32>(rg_15.pos_err_1, 0.0f);
    islands_0[wg_4.island_0].velocity_0 = vec4<f32>(rg_15.vel_1, 0.0f);
    islands_0[wg_4.island_0].velocity_err_0 = vec4<f32>(rg_15.vel_err_1, 0.0f);
    islands_0[wg_4.island_0].angular_velocity_0 = vec4<f32>(rg_15.w_4, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_end(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    var tid_12 : u32 = thread_7.x;
    var _S470 : u32 = group_7.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S470);
    if(_S470 != (wg_5.first_1))
    {
        return;
    }
    var _S471 : Island_std430_0 = islands_0[wg_5.island_0];
    var isl_22 : Island_0;
    isl_22.range_0 = _S471.range_0;
    isl_22.info_0 = _S471.info_0;
    isl_22.com_0 = _S471.com_0;
    isl_22.inertia0_0 = _S471.inertia0_0;
    isl_22.inertia1_0 = _S471.inertia1_0;
    isl_22.inertia2_0 = _S471.inertia2_0;
    isl_22.inv0_0 = _S471.inv0_0;
    isl_22.inv1_0 = _S471.inv1_0;
    isl_22.inv2_0 = _S471.inv2_0;
    isl_22.wcom_0 = _S471.wcom_0;
    isl_22.winv0_0 = _S471.winv0_0;
    isl_22.winv1_0 = _S471.winv1_0;
    isl_22.winv2_0 = _S471.winv2_0;
    isl_22.rotation_0 = _S471.rotation_0;
    isl_22.position_0 = _S471.position_0;
    isl_22.position_err_0 = _S471.position_err_0;
    isl_22.velocity_0 = _S471.velocity_0;
    isl_22.velocity_err_0 = _S471.velocity_err_0;
    isl_22.angular_velocity_0 = _S471.angular_velocity_0;
    isl_22.done_0 = _S471.done_0;
    isl_22.probes_0 = _S471.probes_0;
    isl_22.energy_0 = _S471.energy_0;
    var _S472 : bool = wide_enter_0(tid_12, &(_S471));
    if(!_S472)
    {
        return;
    }
    var work_5 : vec3<f32>;
    var unused_4 : vec3<f32>;
    wide_partials_0(tid_12, wg_5.first_1, isl_22.done_0.z, u32(6), &(work_5), &(unused_4));
    if(tid_12 != u32(0))
    {
        return;
    }
    var k_21 : u32 = wide_step_1(isl_22);
    if((isl_22.probes_0.y) > (isl_22.probes_0.x))
    {
        record_probes_0(isl_22, rigid_of_1(isl_22), k_21);
    }
    var halt_0 : bool = (((isl_22.info_0.z) & (u32(2)))) != u32(0);
    var _S473 : bool;
    if(halt_0)
    {
        _S473 = (((isl_22.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        _S473 = false;
    }
    if(_S473)
    {
        contact_split_at_0(isl_22.info_0.w + u32(1));
    }
    var _S474 : f32 = work_5.x;
    var _S475 : f32 = isl_22.energy_0[i32(0)];
    var _S476 : f32 = isl_22.energy_0[i32(1)];
    comp_add1_2(&(_S475), &(_S476), _S474);
    isl_22.energy_0[i32(0)] = _S475;
    isl_22.energy_0[i32(1)] = _S476 + work_5.y;
    isl_22.done_0[i32(0)] = isl_22.done_0[i32(0)] + u32(1);
    isl_22.info_0[i32(1)] = isl_22.info_0[i32(1)] - u32(1);
    isl_22.info_0[i32(3)] = isl_22.info_0[i32(3)] + u32(1);
    if(halt_0)
    {
        isl_22.info_0[i32(2)] = ((((isl_22.info_0.z) & (u32(4294967293)))) | (u32(1)));
    }
    islands_0[wg_5.island_0].range_0 = isl_22.range_0;
    islands_0[wg_5.island_0].info_0 = isl_22.info_0;
    islands_0[wg_5.island_0].com_0 = isl_22.com_0;
    islands_0[wg_5.island_0].inertia0_0 = isl_22.inertia0_0;
    islands_0[wg_5.island_0].inertia1_0 = isl_22.inertia1_0;
    islands_0[wg_5.island_0].inertia2_0 = isl_22.inertia2_0;
    islands_0[wg_5.island_0].inv0_0 = isl_22.inv0_0;
    islands_0[wg_5.island_0].inv1_0 = isl_22.inv1_0;
    islands_0[wg_5.island_0].inv2_0 = isl_22.inv2_0;
    islands_0[wg_5.island_0].wcom_0 = isl_22.wcom_0;
    islands_0[wg_5.island_0].winv0_0 = isl_22.winv0_0;
    islands_0[wg_5.island_0].winv1_0 = isl_22.winv1_0;
    islands_0[wg_5.island_0].winv2_0 = isl_22.winv2_0;
    islands_0[wg_5.island_0].rotation_0 = isl_22.rotation_0;
    islands_0[wg_5.island_0].position_0 = isl_22.position_0;
    islands_0[wg_5.island_0].position_err_0 = isl_22.position_err_0;
    islands_0[wg_5.island_0].velocity_0 = isl_22.velocity_0;
    islands_0[wg_5.island_0].velocity_err_0 = isl_22.velocity_err_0;
    islands_0[wg_5.island_0].angular_velocity_0 = isl_22.angular_velocity_0;
    islands_0[wg_5.island_0].done_0 = isl_22.done_0;
    islands_0[wg_5.island_0].probes_0 = isl_22.probes_0;
    islands_0[wg_5.island_0].energy_0 = isl_22.energy_0;
    return;
}

