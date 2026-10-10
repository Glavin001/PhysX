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
    @align(4) pad0_0 : u32,
    @align(8) pad1_0 : u32,
    @align(4) pad2_0 : u32,
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
                comp_add1_0(&(_S50), &(_S51), diss_0);
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
                comp_add1_0(&(_S85), &(_S86), diss_1);
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
        comp_add1_1(&(_S109), &(_S110), _S108);
        imp_3.ledger_0[i32(2)] = _S109;
        imp_3.ledger_0[i32(3)] = _S110;
        var _S111 : f32 = imp_3.crush_0.x * extra_0;
        var _S112 : f32 = imp_3.ledger_0[i32(0)];
        var _S113 : f32 = imp_3.ledger_0[i32(1)];
        comp_add1_1(&(_S112), &(_S113), _S111);
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

fn comp_add_0( sum_2 : ptr<function, vec3<f32>>,  err_2 : ptr<function, vec3<f32>>,  x_4 : vec3<f32>)
{
    var t_3 : vec3<f32> = (*sum_2) + x_4;
    var _S114 : vec3<f32> = abs(x_4);
    (*err_2) = (*err_2) + (select(x_4, (*sum_2), (abs((*sum_2))) >= _S114) - t_3 + select((*sum_2), x_4, (abs((*sum_2))) >= _S114));
    (*sum_2) = t_3;
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
            comp_add1_1(&(_S128), &(_S129), diss_2);
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

var<workgroup> g_run_0 : u32;

var<workgroup> g_halt_0 : u32;

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
        var _S131 : u32 = offset_0 + i_4;
        var b_15 : vec4<f32> = loads_0[_S131];
        var _S132 : f32 = b_15.x;
        if(tau_0 <= _S132)
        {
            var a_6 : vec4<f32> = loads_0[_S131 - u32(1)];
            var _S133 : f32 = a_6.x;
            var _S134 : f32 = a_6.y;
            return _S134 + (tau_0 - _S133) / max(_S132 - _S133, 1.00000000317107685e-30f) * (b_15.y - _S134);
        }
        i_4 = i_4 + u32(1);
    }
    return loads_0[offset_0 + count_3 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_13 : u32,  dt_6 : f32,  shift_0 : f32) -> f32
{
    var _S135 : u32 = u32(5) * term_0;
    var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S135])));
    var origin_1 : vec4<f32> = loads_0[_S135 + u32(3)];
    var p_12 : vec4<f32> = loads_0[_S135 + u32(4)];
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
            var _S136 : f32 = p_12.x;
            if(tau_1 >= _S136)
            {
                shape_1 = p_12.y;
            }
            else
            {
                shape_1 = p_12.y * tau_1 / _S136;
            }
        }
        return shape_1;
    }
    var _S137 : bool;
    if(kind_0 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S137 = true;
        }
        else
        {
            _S137 = tau_1 > (p_12.x);
        }
        if(_S137)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_12.y * sin(3.14159274101257324f * tau_1 / p_12.x);
        }
        return shape_1;
    }
    if(kind_0 == u32(3))
    {
        var sn_0 : f32 = tau_1 / p_12.y;
        if(sn_0 < 0.0f)
        {
            _S137 = true;
        }
        else
        {
            _S137 = sn_0 > 1.0f;
        }
        if(_S137)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_12.x * (1.0f - sn_0) * exp(- p_12.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == u32(4))
    {
        return table_eval_0(info_2.w, (bitcast<u32>((p_12.x))), tau_1);
    }
    if(kind_0 == u32(5))
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var sn_1 : f32 = tau_1 / p_12.x;
        if(sn_1 < 0.0f)
        {
            _S137 = true;
        }
        else
        {
            _S137 = sn_1 > 1.0f;
        }
        if(_S137)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- p_12.y * sn_1);
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
        var _S138 : f32 = p_12.w;
        return (_S138 + (p_12.z - _S138) * relax_0) * shape_1;
    }
    var _S139 : f32 = p_12.x;
    if(_S139 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S139, 0.0f, 1.0f);
}

fn ground_contact_0( c_9 : u32,  account_0 : bool,  f_3 : ptr<function, vec3<f32>>,  t_4 : ptr<function, vec3<f32>>)
{
    var wp_1 : WorldPoint_0 = chunk_world_0(c_9);
    var above_0 : f32 = wp_1.hi_0.z - params_0.ground_hi_0 + (wp_1.lo_0.z - params_0.ground_lo_0) + wp_1.rel_0.z;
    if((above_0 - chunks_0[c_9].half_0.w) > 0.0f)
    {
        return;
    }
    var b_16 : Box_0 = chunk_box_0(c_9, vec3<f32>(0.0f));
    const _S140 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S141 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_16, chunks_0[c_9].cmat_0.x, b_16, _S140);
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
        if((above_0 + sample_point_0(b_16, s_6).z) < 0.0f)
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
        var p_13 : vec3<f32> = sample_point_0(b_16, s_6);
        var _S142 : f32 = above_0 + p_13.z;
        if(!(_S142 < 0.0f))
        {
            s_6 = s_6 + u32(1);
            continue;
        }
        var stored_5 : f32;
        var diss_3 : f32;
        var g_0 : vec3<f32> = penalty_force_1(_S141 / f32(max(n_12, u32(5))), chunks_0[c_9].center_0.w, params_0.ground_friction_0, - _S142, _S140, vc_1 + cross(wc_1, p_13), params_0.dt_0, n_12, &(stored_5), &(diss_3));
        (*f_3) = (*f_3) + g_0;
        (*t_4) = (*t_4) + cross(p_13, g_0);
        var _S143 : f32 = ledger_2[i32(1)];
        var _S144 : f32 = ledger_2[i32(2)];
        comp_add1_1(&(_S143), &(_S144), diss_3);
        ledger_2[i32(1)] = _S143;
        ledger_2[i32(2)] = _S144;
        s_6 = s_6 + u32(1);
    }
    if(account_0)
    {
        scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_9] = ledger_2;
    }
    return;
}

fn group_sum3_0( tid_3 : u32,  a_7 : ptr<function, vec3<f32>>,  b_17 : ptr<function, vec3<f32>>)
{
    var x_5 : vec4<f32> = vec4<f32>((*a_7), 0.0f);
    var y_1 : vec4<f32> = vec4<f32>((*b_17), 0.0f);
    group_sum2_0(tid_3, &(x_5), &(y_1));
    (*a_7) = x_5.xyz;
    (*b_17) = y_1.xyz;
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
    var _S145 : bool;
    if((st_0.damage_0) < 1.0f)
    {
        _S145 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S145 = (st_0.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S145 = false;
        }
    }
    return _S145;
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
    var _S146 : f32 = q_lin_0.z;
    var axial_0 : f32 = _S146 / area_2;
    var bending_0 : f32 = abs(q_ang_0.x) / (*b_18).geom1_0.x + abs(q_ang_0.y) / (*b_18).geom1_0.y;
    var _S147 : f32 = q_lin_0.x;
    var _S148 : f32 = q_lin_0.y;
    var shear_1 : f32 = sqrt(_S147 * _S147 + _S148 * _S148) / area_2 + abs(q_ang_0.z) / (*b_18).geom0_0.w;
    var m_3 : Measures_0;
    m_3.tension_0 = axial_0 + bending_0;
    m_3.shear_0 = shear_1;
    var _S149 : f32 = - axial_0;
    m_3.normal_compression_0 = max(_S149, 0.0f);
    m_3.compression_0 = _S149 + bending_0;
    m_3.compressive_force_0 = max(- _S146, 0.0f);
    return m_3;
}

fn expm1_accurate_0( x_6 : f32) -> f32
{
    if((abs(x_6)) < 0.00100000004749745f)
    {
        return x_6 * (1.0f + x_6 * (0.5f + x_6 * 0.1666666716337204f));
    }
    return exp(x_6) - 1.0f;
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_6 : f32 = abs(strain_rate_1);
    var _S150 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    var _S151 : f32 = _S150.z;
    var f_4 : f32;
    if(r_6 <= _S151)
    {
        f_4 = pow(r_6 / ref_0, _S150.y);
    }
    else
    {
        f_4 = pow(_S151 / ref_0, _S150.y) * pow(r_6 / _S151, _S150.w);
    }
    return clamp(f_4, 1.0f, (*mat_1).misc_0.x);
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
    var fc_0 : f32 = (*mat_4).strength_0.y * multiplier_0;
    var _S152 : f32 = min((*mat_4).strength_0.z * multiplier_0 + (*mat_4).strength_0.w * m_4.normal_compression_0, (*mat_4).energy_1.x * multiplier_0);
    var idx_1 : vec4<f32>;
    idx_1[i32(0)] = max(m_4.tension_0 / ((*mat_4).strength_0.x * multiplier_0), 0.0f);
    var _S153 : f32;
    if(_S152 > 0.0f)
    {
        _S153 = m_4.shear_0 / _S152;
    }
    else
    {
        _S153 = infinity_0();
    }
    idx_1[i32(1)] = _S153;
    idx_1[i32(2)] = max(m_4.compression_0 / fc_0, 0.0f);
    var _S154 : f32 = (*b_19).stiff1_0.y;
    if(_S154 > 0.0f)
    {
        _S153 = m_4.compressive_force_0 / _S154;
    }
    else
    {
        _S153 = 0.0f;
    }
    idx_1[i32(3)] = _S153;
    return idx_1;
}

fn sq_0( x_7 : f32) -> f32
{
    return x_7 * x_7;
}

fn damage_law_0( kind_1 : u32,  kappa_1 : f32,  r_7 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == u32(0))
    {
        if(r_7 <= 1.0f)
        {
            return 1.0f;
        }
        return min(r_7 * (kappa_1 - 1.0f) / (kappa_1 * (r_7 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_7 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - 1.0f / kappa_1;
}

fn damage_increment_0( kind_2 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_8 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S155 : f32 = max(damage_law_0(kind_2, lambda_0, r_8), d_old_0);
    var _S156 : bool;
    if(_S155 <= d_old_0)
    {
        _S156 = true;
    }
    else
    {
        _S156 = d_old_0 >= 1.0f;
    }
    if(_S156)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = psi_0 / (lambda_0 * lambda_0);
    var _S157 : f32 = max(kappa_old_0, 1.0f);
    if(kind_2 == u32(0))
    {
        if(r_8 > 1.0f)
        {
            return vec2<f32>(_S155, u0_0 * r_8 / (r_8 - 1.0f) * max(min(lambda_0, r_8) - min(_S157, r_8), 0.0f));
        }
        return vec2<f32>(_S155, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_8 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S157, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S155 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S155, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_4 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S158 : f32 = - h0_0;
    var _S159 : f32 = - h1_0;
    var _S160 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S158, _S159), vec2<f32>(h0_0, _S159), vec2<f32>(h0_0, h1_0), vec2<f32>(_S158, h1_0) );
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
        var _S161 : u32 = i_5;
        var _S162 : u32 = i_5 + u32(1);
        var _S163 : u32 = _S162 % u32(4);
        var _S164 : f32 = _S160[i_5].y;
        var _S165 : f32 = _S160[i_5].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S164 - ay_0 * _S165;
        var _S166 : f32 = _S160[_S163].y;
        var _S167 : f32 = _S160[_S163].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S166 - ay_0 * _S167;
        var _S168 : bool = fp_0 < 0.0f;
        if(_S168)
        {
            var _S169 : u32 = count_5 + u32(1);
            poly_0[count_5] = _S160[_S161];
            count_4 = _S169;
        }
        else
        {
            count_4 = count_5;
        }
        if(_S168 != (fq_0 < 0.0f))
        {
            var t_5 : f32 = fp_0 / (fp_0 - fq_0);
            var _S170 : u32 = count_4 + u32(1);
            poly_0[count_4] = vec2<f32>(_S165 + t_5 * (_S167 - _S165), _S164 + t_5 * (_S166 - _S164));
            count_5 = _S170;
        }
        else
        {
            count_5 = count_4;
        }
        i_5 = _S162;
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
    var a_8 : f32 = 0.0f;
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
        var _S171 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_5].x - _S171;
        var _S172 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_5].y - _S172;
        var _S173 : u32 = i_5 + u32(1);
        var _S174 : u32 = _S173 % count_5;
        var x1_0 : f32 = poly_0[_S174].x - _S171;
        var y1_0 : f32 = poly_0[_S174].y - _S172;
        var _S175 : f32 = x0_0 * y1_0;
        var _S176 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S175 - _S176;
        var a_9 : f32 = a_8 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S175 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S176) * cr_0 / 24.0f;
        i_5 = _S173;
        a_8 = a_9;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_8 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_8;
    var cy_0 : f32 = sy_0 / a_8;
    (*region_0)[i32(0)] = a_8;
    (*region_0)[i32(1)] = o_1.x + cx_0;
    (*region_0)[i32(2)] = o_1.y + cy_0;
    var _S177 : f32 = a_8 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S177 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_8 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S177 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_9 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_9));
    var a_10 : f32 = r_9[i32(0)];
    if((r_9[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_14 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_1 : f32 = dz_1 + ax_1 * r_9[i32(2)] - ay_1 * r_9[i32(1)];
    var _S178 : f32 = a_10 * fc_1;
    var _S179 : f32 = - ay_1;
    return vec4<f32>(k_14 * a_10 * fc_1, k_14 * (_S178 * r_9[i32(2)] + (_S179 * r_9[i32(5)] + ax_1 * r_9[i32(4)])), - k_14 * (_S178 * r_9[i32(1)] + (_S179 * r_9[i32(3)] + ax_1 * r_9[i32(5)])), 0.5f * k_14 * (_S178 * fc_1 + ay_1 * ay_1 * r_9[i32(3)] + ax_1 * ax_1 * r_9[i32(4)] - 2.0f * ax_1 * ay_1 * r_9[i32(5)]));
}

fn signum_0( x_8 : f32) -> f32
{
    var _S180 : f32;
    if((((bitcast<u32>((x_8))) & (u32(2147483648)))) != u32(0))
    {
        _S180 = -1.0f;
    }
    else
    {
        _S180 = 1.0f;
    }
    return _S180;
}

fn return_map_0( k_15 : f32,  total_3 : f32,  plastic_0 : f32,  cap_0 : f32) -> vec2<f32>
{
    var trial_0 : f32 = k_15 * (total_3 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return vec2<f32>(trial_0, 0.0f);
    }
    var f_5 : f32 = cap_0 * signum_0(trial_0);
    return vec2<f32>(f_5, (trial_0 - f_5) / k_15);
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
    var c_10 : Contact_0;
    var _S181 : vec3<f32> = vec3<f32>(0.0f);
    c_10.q_lin_1 = _S181;
    c_10.q_ang_1 = _S181;
    c_10.energy_2 = 0.0f;
    c_10.diss_4 = 0.0f;
    c_10.plastic_1 = plastic_2;
    var _S182 : u32 = (*mat_5).kind_flags_0.y;
    if(((_S182 & (u32(2)))) == u32(0))
    {
        return c_10;
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
    if(((_S182 & (u32(4)))) != u32(0))
    {
        var p_14 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S183 : f32 = p_14.y;
        var _S184 : f32 = p_14.z;
        var _S185 : f32 = p_14.w;
        nc_sum_0 = p_14.x;
        m1_0 = _S183;
        m2_0 = _S184;
        energy_3 = _S185;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S186 : f32 = d_ang_0.x;
        var _S187 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S186) * 0.4166666567325592f * w1_2 + abs(_S187) * 0.4166666567325592f * w0_2;
        var _S188 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S188) + spread_0);
        if((_S188 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S188 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S189 : f32 = ki_0 * _S186 * i2_0;
                var _S190 : f32 = ki_0 * _S187 * i1_0;
                var _S191 : f32 = 0.5f * ki_0 * (36.0f * _S188 * _S188 + _S186 * _S186 * i2_0 + _S187 * _S187 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S188;
                m1_0 = _S189;
                m2_0 = _S190;
                energy_3 = _S191;
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
                    var _S192 : f32 = ((f32(i_6) + 0.5f) / 6.0f - 0.5f) * w0_2;
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
                        var di_0 : f32 = _S188 + _S186 * s2_0 - _S187 * _S192;
                        if(di_0 < 0.0f)
                        {
                            var f_6 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_6 * s2_0;
                            var m2_2 : f32 = m2_0 - f_6 * _S192;
                            var energy_5 : f32 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_6;
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
    c_10.q_lin_1 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_10.q_ang_1 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_5).strength_0.w * nc_0;
    var _S193 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S194 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var trial_1 : vec2<f32> = vec2<f32>(_S193, _S194);
    var tn_0 : f32 = sqrt(_S193 * _S193 + _S194 * _S194);
    var _S195 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S195 = tn_0 > 0.0f;
    }
    else
    {
        _S195 = false;
    }
    if(_S195)
    {
        var dir_1 : vec2<f32> = trial_1 / vec2<f32>(tn_0);
        var dslip_0 : f32 = (tn_0 - slide_cap_0) / ks_0;
        var _S196 : f32 = dir_1.x;
        p_15[i32(0)] = p_15[i32(0)] + _S196 * dslip_0;
        var _S197 : f32 = dir_1.y;
        p_15[i32(1)] = p_15[i32(1)] + _S197 * dslip_0;
        c_10.q_lin_1[i32(0)] = _S196 * slide_cap_0;
        c_10.q_lin_1[i32(1)] = _S197 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_10.q_lin_1[i32(0)] = _S193;
        c_10.q_lin_1[i32(1)] = _S194;
        diss_5 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_15.z, slide_cap_0 * (*b_20).geom1_0.z);
    var _S198 : f32 = tq_0.x;
    var _S199 : f32 = tq_0.y;
    var diss_6 : f32 = diss_5 + abs(_S198) * abs(_S199);
    p_15[i32(2)] = p_15[i32(2)] + _S199;
    c_10.q_ang_1[i32(2)] = _S198;
    c_10.energy_2 = energy_3 + 0.5f * (sq_0(c_10.q_lin_1.x) / ks_0 + sq_0(c_10.q_lin_1.y) / ks_0 + sq_0(_S198) / kt_0);
    c_10.diss_4 = diss_6;
    c_10.plastic_1 = p_15;
    return c_10;
}

fn life_rate_0( mat_6 : ptr<function, JointMaterial_std140_0>,  s_7 : f32) -> f32
{
    if(s_7 <= 0.0f)
    {
        return 0.0f;
    }
    var _S200 : f32 = (*mat_6).misc_0.y;
    return (_S200 + 1.0f) * pow(s_7, _S200) / (*mat_6).misc_0.z;
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

fn joint_evaluate_0( mat_7 : ptr<function, JointMaterial_std140_0>,  b_21 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>,  dt_7 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_2 : f32 = (*b_21).stiff0_0.x;
    var ks_1 : f32 = (*b_21).stiff0_0.y;
    var kb1_0 : f32 = (*b_21).stiff0_0.z;
    var kb2_0 : f32 = (*b_21).stiff0_0.w;
    var _S201 : vec4<f32> = (*b_21).stiff1_0;
    var kt_1 : f32 = (*b_21).stiff1_0.x;
    var has_rebar_1 : bool = ((*b_21).stiff1_0.w) != 0.0f;
    var kind_3 : u32 = (*mat_7).kind_flags_0.x;
    var flags_1 : u32 = (*mat_7).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_1 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_0(state_2, has_rebar_1);
    var qe_lin_0 : vec3<f32> = d_lin_1 * vec3<f32>(ks_1, ks_1, kn_2);
    var qe_ang_0 : vec3<f32> = d_ang_1 * vec3<f32>(kb1_0, kb2_0, kt_1);
    var _S202 : Measures_0 = stress_measures_0(&((*b_21)), qe_lin_0, qe_ang_0);
    var _S203 : f32 = max(max(_S202.tension_0, _S202.shear_0), _S202.compression_0);
    var _S204 : bool = dt_7 > 0.0f;
    var dif_1 : f32;
    if(_S204)
    {
        var raw_0 : f32 = max((_S203 - st_1.governing_stress_0) / dt_7, 0.0f) / (*mat_7).misc_0.w;
        var tau_2 : f32 = _S201.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- dt_7 / tau_2);
        }
        else
        {
            dif_1 = min(dt_7 / tau_2, 1.0f);
        }
        st_1.strain_rate_0 = st_1.strain_rate_0 + (raw_0 - st_1.strain_rate_0) * dif_1;
        st_1.governing_stress_0 = _S203;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S205 : f32 = dif_factor_0(&((*mat_7)), st_1.strain_rate_0);
        dif_1 = _S205;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_21).geom1_0.w;
    var _S206 : f32 = weibull_0 * dif_1;
    var _S207 : f32 = fatigue_factor_1(&((*mat_7)), st_1.fatigue_0);
    var multiplier_1 : f32 = _S206 * _S207;
    var _S208 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_21)), _S202, multiplier_1);
    var _S209 : f32 = _S208.x;
    var _S210 : f32 = _S208.y;
    st_1.utilization_0 = max(max(_S209, _S210), max(_S208.z, _S208.w));
    var _S211 : f32 = d_lin_1.x;
    var _S212 : f32 = d_lin_1.y;
    var _S213 : f32 = ks_1 * (sq_0(_S211) + sq_0(_S212)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    var _S214 : f32 = d_lin_1.z;
    var _S215 : bool = _S214 > 0.0f;
    if(_S215)
    {
        dif_1 = kn_2 * sq_0(_S214);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S213 + dif_1);
    var psi_c_0 : f32;
    if(_S214 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S214);
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
    var _S216 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S217 : bool = _S209 >= _S210;
        if(_S217)
        {
            diss_contact_0 = _S209;
        }
        else
        {
            diss_contact_0 = _S210;
        }
        var mode_ts_0 : u32;
        if(_S217)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_1.kappa_0))
        {
            _S216 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S216 = false;
        }
        if(_S216)
        {
            _S216 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S216 = false;
        }
        var mode_c_0 : u32;
        if(_S216)
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
            var _S218 : f32 = inc_0.x;
            if(_S218 > (st_1.damage_0))
            {
                var _S219 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_21)), st_1.crush_1, plastic_3, d_lin_1, d_ang_1);
                var _S220 : f32 = max(_S219.energy_2 - (1.0f - st_1.crush_1) * psi_c_0, 0.0f);
                var _S221 : f32 = max(inc_0.y - _S220 * (_S218 - st_1.damage_0), 0.0f);
                var _S222 : f32 = max((psi_ts_0 - _S220) * (_S218 - st_1.damage_0) - _S221, 0.0f);
                st_1.damage_0 = _S218;
                st_1.mode_0 = mode_ts_0;
                dissipated_4 = _S221;
                overshoot_1 = _S222;
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
            var _S223 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_21)), state_2.crush_1, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S223.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S224 : Measures_0 = stress_measures_0(&((*b_21)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S225 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_21)), _S224, multiplier_1);
        var _S226 : f32 = _S225.z;
        var _S227 : f32 = _S225.w;
        var _S228 : bool = _S226 >= _S227;
        if(_S228)
        {
            psi_contact_0 = _S226;
        }
        else
        {
            psi_contact_0 = _S227;
        }
        if(_S228)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_1.kappa_c_0))
        {
            _S216 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S216 = false;
        }
        if(_S216)
        {
            _S216 = psi_c_0 > 0.0f;
        }
        else
        {
            _S216 = false;
        }
        if(_S216)
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
            var _S229 : f32 = inc_1.x;
            if(_S229 > (st_1.crush_1))
            {
                var _S230 : f32 = inc_1.y;
                var dissipated_5 : f32 = dissipated_4 + _S230;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S229 - st_1.crush_1) - _S230, 0.0f);
                st_1.crush_1 = _S229;
                st_1.mode_0 = mode_c_0;
                if(_S229 >= 1.0f)
                {
                    _S216 = (st_1.damage_0) < 1.0f;
                }
                else
                {
                    _S216 = false;
                }
                if(_S216)
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
    var _S231 : vec3<f32> = vec3<f32>(0.0f);
    if((st_1.damage_0) == 0.0f)
    {
        _S216 = ((flags_1 & (u32(8)))) != u32(0);
    }
    else
    {
        _S216 = false;
    }
    var qc_ang_0 : vec3<f32>;
    if(!_S216)
    {
        var _S232 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_21)), st_1.crush_1, plastic_3, d_lin_1, d_ang_1);
        st_1.plastic_x_0 = _S232.plastic_1.x;
        st_1.plastic_y_0 = _S232.plastic_1.y;
        st_1.plastic_t_0 = _S232.plastic_1.z;
        diss_contact_0 = _S232.diss_4;
        qc_lin_0 = _S232.q_lin_1;
        qc_ang_0 = _S232.q_ang_1;
        psi_contact_0 = _S232.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S231;
        qc_ang_0 = _S231;
        psi_contact_0 = 0.0f;
    }
    var dissipated_7 : f32 = dissipated_4 + dmg_0 * diss_contact_0;
    if(_S215)
    {
        intact_normal_0 = kn_2 * _S214;
    }
    else
    {
        intact_normal_0 = (1.0f - st_1.crush_1) * kn_2 * _S214;
    }
    var _S233 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S233 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S233 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S233 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S233) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_7 : f32 = _S233 * (psi_ts_0 + (1.0f - st_1.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S216 = (st_1.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S216 = false;
    }
    var stored_8 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S216)
    {
        var k_axial_0 : f32 = (*b_21).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_21).rebar0_0.y;
        var yield_force_0 : f32 = (*b_21).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_21).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S214, st_1.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S211, st_1.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S212, st_1.rebar_slip1_0, dowel_capacity_0);
        var _S234 : f32 = nr_0.y;
        var _S235 : f32 = v1_0.y;
        var _S236 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S234) + dowel_capacity_0 * (abs(_S235) + abs(_S236));
        st_1.rebar_plastic_0 = st_1.rebar_plastic_0 + _S234;
        st_1.rebar_slip0_0 = st_1.rebar_slip0_0 + _S235;
        st_1.rebar_slip1_0 = st_1.rebar_slip1_0 + _S236;
        st_1.rebar_work_0 = st_1.rebar_work_0 + work_0;
        var dissipated_8 : f32 = dissipated_7 + work_0;
        var _S237 : f32 = nr_0.x;
        var _S238 : f32 = v1_0.x;
        var _S239 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (sq_0(_S237) / k_axial_0 + (sq_0(_S238) + sq_0(_S239)) / k_dowel_0);
        if(fracture_1)
        {
            _S216 = (st_1.rebar_work_0) >= ((*b_21).rebar1_0.x);
        }
        else
        {
            _S216 = false;
        }
        if(_S216)
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
            force_lin_3 = force_lin_2 + vec3<f32>(_S238, _S239, _S237);
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
        _S216 = _S204;
    }
    else
    {
        _S216 = false;
    }
    if(_S216)
    {
        _S216 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S216 = false;
    }
    if(_S216)
    {
        var _S240 : Measures_0 = stress_measures_0(&((*b_21)), force_lin_3, force_ang_2);
        var _S241 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_21)), _S240, weibull_0);
        var _S242 : f32 = life_rate_0(&((*mat_7)), max(max(_S241.x, _S241.y), _S241.z));
        st_1.fatigue_0 = min(st_1.fatigue_0 + _S242 * dt_7, 1.0f);
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
        _S216 = !connected_0(st_1, has_rebar_1);
    }
    else
    {
        _S216 = false;
    }
    resp_0.disconnected_0 = _S216;
    resp_0.measures_0 = _S202;
    return resp_0;
}

fn secant_factors_0( b_22 : ptr<function, JointBond_std430_0>,  st_2 : JointState_0,  d_lin_2 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var compressed_0 : bool = (d_lin_2.z) < 0.0f;
    var contact_0 : f32;
    if(compressed_0)
    {
        contact_0 = st_2.damage_0;
    }
    else
    {
        contact_0 = 0.0f;
    }
    var _S243 : f32 = 1.0f - st_2.damage_0;
    var _S244 : f32 = max(_S243 + contact_0, 9.99999997475242708e-07f);
    var normal_6 : f32;
    if(compressed_0)
    {
        normal_6 = max(1.0f - st_2.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_6 = max(_S243, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S244, _S244, normal_6);
    (*f_ang_0) = vec3<f32>(_S244);
    var _S245 : bool;
    if(((*b_22).stiff1_0.w) != 0.0f)
    {
        _S245 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S245 = false;
    }
    if(_S245)
    {
        var _S246 : vec4<f32> = (*b_22).rebar0_0;
        var _S247 : vec4<f32> = (*b_22).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + (*b_22).rebar0_0.x / (*b_22).stiff0_0.x;
        var _S248 : f32 = _S246.y;
        var _S249 : f32 = _S247.y;
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S248 / _S249;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S248 / _S249;
    }
    return;
}

fn is_damaged_0( st_3 : JointState_0) -> bool
{
    var _S250 : bool;
    if((st_3.damage_0) > 0.0f)
    {
        _S250 = true;
    }
    else
    {
        _S250 = (st_3.crush_1) > 0.0f;
    }
    return _S250;
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

fn to_local_0( _S251 : u32,  _S252 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S252, bonds_0[_S251].t1_0.xyz), dot(_S252, bonds_0[_S251].t2_0.xyz), dot(_S252, bonds_0[_S251].normal_0.xyz));
}

fn to_body_0( _S253 : u32,  _S254 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S253].t1_0.xyz * vec3<f32>(_S254.x) + bonds_0[_S253].t2_0.xyz * vec3<f32>(_S254.y) + bonds_0[_S253].normal_0.xyz * vec3<f32>(_S254.z);
}

fn bond_update_0( i_7 : u32,  dt_8 : f32,  fracture_2 : bool,  abs_step_0 : u32)
{
    var _S255 : JointState_0 = JointState_0( bond_dyn_0[i_7].js_0.damage_0, bond_dyn_0[i_7].js_0.crush_1, bond_dyn_0[i_7].js_0.kappa_0, bond_dyn_0[i_7].js_0.kappa_c_0, bond_dyn_0[i_7].js_0.ductility_0, bond_dyn_0[i_7].js_0.ductility_c_0, bond_dyn_0[i_7].js_0.fatigue_0, bond_dyn_0[i_7].js_0.plastic_x_0, bond_dyn_0[i_7].js_0.plastic_y_0, bond_dyn_0[i_7].js_0.plastic_t_0, bond_dyn_0[i_7].js_0.rebar_plastic_0, bond_dyn_0[i_7].js_0.rebar_slip0_0, bond_dyn_0[i_7].js_0.rebar_slip1_0, bond_dyn_0[i_7].js_0.rebar_work_0, bond_dyn_0[i_7].js_0.rebar_broken_0, bond_dyn_0[i_7].js_0.strain_rate_0, bond_dyn_0[i_7].js_0.governing_stress_0, bond_dyn_0[i_7].js_0.dissipated_0, bond_dyn_0[i_7].js_0.utilization_0, bond_dyn_0[i_7].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S255;
    bd_0.force_lin_0 = bond_dyn_0[i_7].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_7].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_7].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_7].comps_0;
    bd_0.events_0 = bond_dyn_0[i_7].events_0;
    var _S256 : JointBond_std430_0 = bonds_0[i_7].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_7].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_7].rb_0.xyz;
    var _S257 : u32 = u32(4) * _S256.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S257 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S257 + u32(3)].xyz;
    var _S258 : u32 = u32(4) * _S256.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S258 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S258 + u32(3)].xyz;
    var _S259 : vec3<f32> = to_local_0(i_7, state_0[_S258].xyz + cross(tb_3, rb_1) - (state_0[_S257].xyz + cross(ta_3, ra_1)));
    var _S260 : vec3<f32> = to_local_0(i_7, tb_3 - ta_3);
    var _S261 : vec3<f32> = to_local_0(i_7, state_0[_S258 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S257 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S262 : vec3<f32> = to_local_0(i_7, wb_0 - wa_0);
    var _S263 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S256.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S264 : JointResponse_0 = joint_evaluate_0(&(_S263), &(_S256), bd_0.js_0, _S259, _S260, dt_8, fracture_2);
    var f_lin_1 : vec3<f32>;
    var f_ang_1 : vec3<f32>;
    secant_factors_0(&(_S256), _S264.state_1, _S259, &(f_lin_1), &(f_ang_1));
    var qd_lin_0 : vec3<f32> = _S261 * bonds_0[i_7].c_lin_0.xyz * f_lin_1;
    var qd_ang_0 : vec3<f32> = _S262 * bonds_0[i_7].c_ang_0.xyz * f_ang_1;
    var q_lin_2 : vec3<f32> = _S264.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S264.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S261) + dot(qd_ang_0, _S262)) * dt_8;
    var _S265 : vec3<f32> = to_body_0(i_7, q_lin_2);
    var _S266 : vec3<f32> = to_body_0(i_7, q_ang_2);
    var _S267 : u32 = u32(3) * i_7;
    scratch_0[_S267] = vec4<f32>(_S265, max(_S264.measures_0.tension_0, _S264.measures_0.compression_0));
    scratch_0[_S267 + u32(1)] = vec4<f32>(_S266 + cross(ra_1, _S265), 0.0f);
    scratch_0[_S267 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S266) + cross(rb_1, (vec3<f32>(0) - _S265)), 0.0f);
    var _S268 : f32 = bd_0.sums_0[i32(0)];
    var _S269 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S268), &(_S269), _S264.dissipated_3);
    bd_0.sums_0[i32(0)] = _S268;
    bd_0.comps_0[i32(0)] = _S269;
    var _S270 : f32 = bd_0.sums_0[i32(1)];
    var _S271 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S270), &(_S271), _S264.overshoot_0);
    bd_0.sums_0[i32(1)] = _S270;
    bd_0.comps_0[i32(1)] = _S271;
    var _S272 : f32 = bd_0.sums_0[i32(2)];
    var _S273 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S272), &(_S273), damped_0);
    bd_0.sums_0[i32(2)] = _S272;
    bd_0.comps_0[i32(2)] = _S273;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S264.stored_6);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S264.state_1.utilization_0));
    var _S274 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S274 = is_damaged_0(_S264.state_1);
    }
    else
    {
        _S274 = false;
    }
    if(_S274)
    {
        _S274 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S274 = false;
    }
    if(_S274)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S264.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S275 : f32 = fatigue_factor_0(&(_S263), previous_0.fatigue_0);
        _S274 = _S275 > 0.99000000953674316f;
    }
    else
    {
        _S274 = false;
    }
    if(_S274)
    {
        var _S276 : f32 = fatigue_factor_0(&(_S263), _S264.state_1.fatigue_0);
        _S274 = _S276 <= 0.99000000953674316f;
    }
    else
    {
        _S274 = false;
    }
    if(_S274)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S264.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
        g_halt_0 = u32(1);
    }
    bd_0.js_0 = _S264.state_1;
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
    return;
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

struct Rigid_0
{
     rot_0 : Quat_0,
     pos_1 : vec3<f32>,
     pos_err_1 : vec3<f32>,
     vel_1 : vec3<f32>,
     vel_err_1 : vec3<f32>,
     w_4 : vec3<f32>,
     a_11 : vec3<f32>,
     alpha_0 : vec3<f32>,
};

fn chunk_external_0( _S277 : u32,  _S278 : u32,  _S279 : Quat_0,  _S280 : u32,  _S281 : f32,  _S282 : bool,  _S283 : bool,  _S284 : ptr<function, vec3<f32>>,  _S285 : ptr<function, vec3<f32>>)
{
    var _S286 : vec3<f32> = vec3<f32>(0.0f);
    (*_S284) = _S286;
    (*_S285) = _S286;
    var _S287 : vec4<u32> = chunks_0[_S278].load_range_0;
    var term_1 : u32 = chunks_0[_S278].load_range_0.x;
    loop
    {
        if(term_1 < (_S287.y))
        {
        }
        else
        {
            break;
        }
        var _S288 : u32 = u32(5) * term_1;
        var _S289 : u32 = (bitcast<vec4<u32>>((loads_0[_S288]))).y;
        if(_S289 == u32(2))
        {
            term_1 = term_1 + u32(1);
            continue;
        }
        var dir_2 : vec4<f32> = loads_0[_S288 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S288 + u32(2)];
        var value_0 : f32 = eval_function_0(term_1, _S280, _S281, 0.0f);
        var fw_0 : vec3<f32>;
        if(_S289 == u32(0))
        {
            fw_0 = dir_2.xyz * vec3<f32>(value_0);
        }
        else
        {
            fw_0 = rotate_0(_S279, dir_2.xyz) * vec3<f32>((- value_0 * dir_2.w));
        }
        (*_S284) = (*_S284) + fw_0;
        (*_S285) = (*_S285) + cross(rotate_0(_S279, arm_0.xyz), fw_0);
        term_1 = term_1 + u32(1);
    }
    var _S290 : bool;
    if(_S282)
    {
        _S290 = (chunks_0[_S278].cinfo_0.z) != u32(0);
    }
    else
    {
        _S290 = false;
    }
    if(_S290)
    {
        var _S291 : vec4<u32> = chunks_0[_S278].cinfo_0;
        var e_1 : u32 = chunks_0[_S278].cinfo_0.x;
        loop
        {
            if(e_1 < (_S291.y))
            {
            }
            else
            {
                break;
            }
            var entry_1 : u32 = index_0[e_1];
            if(entry_1 == u32(2147483648))
            {
                ground_contact_0(_S277, _S283, &((*_S284)), &((*_S285)));
                e_1 = e_1 + u32(1);
                continue;
            }
            var _S292 : u32 = u32(2) * entry_1;
            (*_S284) = (*_S284) + scratch_0[params_0.slot_base_0 + _S292].xyz;
            (*_S285) = (*_S285) + scratch_0[params_0.slot_base_0 + _S292 + u32(1)].xyz;
            e_1 = e_1 + u32(1);
        }
    }
    return;
}

fn chunk_update_0( c_11 : u32,  isl_0 : Island_0,  rg_0 : Rigid_0,  dt_9 : f32,  rml_0 : bool,  step_0 : u32,  contact_1 : bool,  work_1 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S293 : vec3<f32> = vec3<f32>(0.0f);
    var _S294 : u32 = index_0[c_11];
    var peak_0 : f32 = 0.0f;
    var e_2 : u32 = _S294;
    var fi_0 : vec3<f32> = _S293;
    var mi_0 : vec3<f32> = _S293;
    loop
    {
        if(e_2 < index_0[c_11 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_2 : u32 = index_0[e_2];
        var _S295 : u32 = u32(3) * ((entry_2 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S295];
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + scratch_0[_S295 + u32(1)].xyz;
            fi_0 = fi_0 + fa_2.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + scratch_0[_S295 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_2.xyz);
            mi_0 = mi_2;
        }
        var _S296 : f32 = max(peak_0, fa_2.w);
        var _S297 : u32 = e_2 + u32(1);
        peak_0 = _S296;
        e_2 = _S297;
    }
    var _S298 : u32 = u32(4) * c_11;
    var u_0 : vec3<f32> = state_0[_S298].xyz;
    var _S299 : u32 = _S298 + u32(1);
    var th_1 : vec3<f32> = state_0[_S299].xyz;
    var _S300 : u32 = _S298 + u32(2);
    var v_8 : vec3<f32> = state_0[_S300].xyz;
    var _S301 : u32 = _S298 + u32(3);
    var w_5 : vec3<f32> = state_0[_S301].xyz;
    var mass_0 : f32 = chunks_0[c_11].center_0.w;
    var _S302 : vec3<f32> = chunks_0[c_11].center_0.xyz;
    var _S303 : vec3<f32> = isl_0.com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_0.rot_0, _S302 + u_0 - _S303);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    chunk_external_0(c_11, c_11, rg_0.rot_0, step_0, dt_9, contact_1, true, &(f_load_0), &(t_load_0));
    var _S304 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S304;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_0.rot_0, chunks_0[c_11].inertia0_1, chunks_0[c_11].inertia1_1, chunks_0[c_11].inertia2_1, rg_0.alpha_0) + cross(rg_0.w_4, world_mul_0(rg_0.rot_0, chunks_0[c_11].inertia0_1, chunks_0[c_11].inertia1_1, chunks_0[c_11].inertia2_1, rg_0.w_4)));
        f_world_1 = f_world_0 - (rg_0.a_11 + cross(rg_0.alpha_0, r_world_0) + cross(rg_0.w_4, cross(rg_0.w_4, r_world_0))) * _S304;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    var f_ext_0 : vec3<f32> = inverse_rotate_0(rg_0.rot_0, f_world_1);
    var m_ext_0 : vec3<f32> = inverse_rotate_0(rg_0.rot_0, t_world_1);
    var f_ext_1 : vec3<f32>;
    var m_ext_1 : vec3<f32>;
    if(rml_0)
    {
        var wb_1 : vec3<f32> = inverse_rotate_0(rg_0.rot_0, rg_0.w_4);
        var i_w_0 : vec3<f32> = rows_mul_0(chunks_0[c_11].inertia0_1, chunks_0[c_11].inertia1_1, chunks_0[c_11].inertia2_1, w_5);
        var m_ext_2 : vec3<f32> = m_ext_0 - (cross(wb_1, i_w_0) + cross(w_5, rows_mul_0(chunks_0[c_11].inertia0_1, chunks_0[c_11].inertia1_1, chunks_0[c_11].inertia2_1, wb_1)) + cross(w_5, i_w_0));
        f_ext_1 = f_ext_0 - cross(wb_1, v_8) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var _S305 : vec4<u32> = chunks_0[c_11].load_range_0;
    var term_2 : u32 = chunks_0[c_11].load_range_0.x;
    loop
    {
        if(term_2 < (_S305.y))
        {
        }
        else
        {
            break;
        }
        var _S306 : u32 = u32(5) * term_2;
        if(((bitcast<vec4<u32>>((loads_0[_S306]))).y) != u32(2))
        {
            term_2 = term_2 + u32(1);
            continue;
        }
        var _S307 : vec3<f32> = vec3<f32>(eval_function_0(term_2, step_0, dt_9, dt_9));
        var m_ext_3 : vec3<f32> = m_ext_1 + loads_0[_S306 + u32(2)].xyz * _S307;
        f_ext_1 = f_ext_1 + loads_0[_S306 + u32(1)].xyz * _S307;
        m_ext_1 = m_ext_3;
        term_2 = term_2 + u32(1);
    }
    var f_7 : vec3<f32> = f_ext_1 + fi_0;
    var m_5 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_11].info_1.x;
    var _S308 : vec3<f32> = vec3<f32>(state_0[_S299].w, state_0[_S300].w, state_0[_S301].w);
    var reaction_0 : vec3<f32>;
    var u_1 : vec3<f32>;
    var th_2 : vec3<f32>;
    var v_9 : vec3<f32>;
    var w_6 : vec3<f32>;
    if(support_0 == u32(1))
    {
        reaction_0 = (vec3<f32>(0) - f_7);
        u_1 = u_0;
        th_2 = th_1;
        v_9 = _S293;
        w_6 = _S293;
    }
    else
    {
        var _S309 : vec4<f32> = chunks_0[c_11].scale_0;
        var w_7 : vec3<f32> = w_5 + rows_mul_0(chunks_0[c_11].inv0_1, chunks_0[c_11].inv1_1, chunks_0[c_11].inv2_1, m_5) * vec3<f32>((dt_9 * chunks_0[c_11].scale_0.z));
        var _S310 : vec3<f32> = vec3<f32>(dt_9);
        var th_3 : vec3<f32> = th_1 + w_7 * _S310;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_7);
            u_1 = u_0;
            th_2 = _S293;
        }
        else
        {
            var v_10 : vec3<f32> = v_8 + f_7 * vec3<f32>((dt_9 * _S309.y));
            var u_2 : vec3<f32> = u_0 + v_10 * _S310;
            reaction_0 = _S308;
            u_1 = u_2;
            th_2 = v_10;
        }
        var _S311 : vec3<f32> = th_2;
        th_2 = th_3;
        v_9 = _S311;
        w_6 = w_7;
    }
    state_0[_S298] = vec4<f32>(u_1, peak_0);
    state_0[_S299] = vec4<f32>(th_2, reaction_0.x);
    state_0[_S300] = vec4<f32>(v_9, reaction_0.y);
    state_0[_S301] = vec4<f32>(w_6, reaction_0.z);
    comp_add1_1(&((*work_1)), &((*work_err_0)), (dot(f_load_0, rg_0.vel_1 + rg_0.vel_err_1 + cross(rg_0.w_4, rotate_0(rg_0.rot_0, _S302 + u_1 - _S303)) + rotate_0(rg_0.rot_0, v_9)) + dot(t_load_0, rg_0.w_4 + rotate_0(rg_0.rot_0, w_6))) * dt_9);
    return;
}

fn write_probe_0( slot_1 : u32,  k_16 : u32,  value_1 : f32)
{
    var at_4 : u32 = params_0.probe_base_0 * u32(4) + slot_1 * params_0.probe_stride_0 + k_16;
    var v_11 : vec4<f32> = scratch_0[at_4 / u32(4)];
    v_11[at_4 % u32(4)] = value_1;
    scratch_0[at_4 / u32(4)] = v_11;
    return;
}

fn record_probes_0( isl_1 : Island_0,  rg_1 : Rigid_0,  k_17 : u32)
{
    var at_5 : u32 = isl_1.probes_0.x;
    loop
    {
        if(at_5 < (isl_1.probes_0.y))
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
            value_2 = dot(rg_1.pos_1 - b_23.xyz + (rg_1.pos_err_1 - c4_0.xyz) + rotate_0(rg_1.rot_0, chunks_0[i_8].center_0.xyz + state_0[u32(4) * i_8].xyz), a_12.xyz);
        }
        else
        {
            if(kind_4 == u32(1))
            {
                var _S312 : u32 = u32(4) * i_8;
                value_2 = dot(rg_1.vel_1 + rg_1.vel_err_1 + cross(rg_1.w_4, rotate_0(rg_1.rot_0, chunks_0[i_8].center_0.xyz + state_0[_S312].xyz - isl_1.com_0.xyz)) + rotate_0(rg_1.rot_0, state_0[_S312 + u32(2)].xyz), a_12.xyz);
            }
            else
            {
                if(kind_4 == u32(2))
                {
                    var _S313 : u32 = u32(3) * i_8;
                    var f_8 : vec3<f32> = scratch_0[_S313].xyz;
                    var _S314 : bool = (info_3.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S314)
                    {
                        mc_0 = scratch_0[_S313 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S313 + u32(2)].xyz;
                    }
                    var fc_2 : vec3<f32>;
                    if(_S314)
                    {
                        fc_2 = f_8;
                    }
                    else
                    {
                        fc_2 = (vec3<f32>(0) - f_8);
                    }
                    value_2 = dot(fc_2, a_12.xyz) + dot(mc_0, b_23.xyz);
                }
                else
                {
                    var _S315 : u32 = u32(4) * i_8;
                    value_2 = dot(rotate_0(rg_1.rot_0, vec3<f32>(state_0[_S315 + u32(1)].w, state_0[_S315 + u32(2)].w, state_0[_S315 + u32(3)].w)), a_12.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_17, value_2);
        at_5 = at_5 + u32(4);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var tid_4 : u32 = thread_2.x;
    var _S316 : u32 = group_2.x;
    var isl_2 : Island_0;
    isl_2.range_0 = islands_0[_S316].range_0;
    isl_2.info_0 = islands_0[_S316].info_0;
    isl_2.com_0 = islands_0[_S316].com_0;
    isl_2.inertia0_0 = islands_0[_S316].inertia0_0;
    isl_2.inertia1_0 = islands_0[_S316].inertia1_0;
    isl_2.inertia2_0 = islands_0[_S316].inertia2_0;
    isl_2.inv0_0 = islands_0[_S316].inv0_0;
    isl_2.inv1_0 = islands_0[_S316].inv1_0;
    isl_2.inv2_0 = islands_0[_S316].inv2_0;
    isl_2.wcom_0 = islands_0[_S316].wcom_0;
    isl_2.winv0_0 = islands_0[_S316].winv0_0;
    isl_2.winv1_0 = islands_0[_S316].winv1_0;
    isl_2.winv2_0 = islands_0[_S316].winv2_0;
    isl_2.rotation_0 = islands_0[_S316].rotation_0;
    isl_2.position_0 = islands_0[_S316].position_0;
    isl_2.position_err_0 = islands_0[_S316].position_err_0;
    isl_2.velocity_0 = islands_0[_S316].velocity_0;
    isl_2.velocity_err_0 = islands_0[_S316].velocity_err_0;
    isl_2.angular_velocity_0 = islands_0[_S316].angular_velocity_0;
    isl_2.done_0 = islands_0[_S316].done_0;
    isl_2.probes_0 = islands_0[_S316].probes_0;
    isl_2.energy_0 = islands_0[_S316].energy_0;
    var driven_0 : bool = (((isl_2.info_0.x) & (u32(2)))) != u32(0);
    var _S317 : bool = !((((isl_2.info_0.x) & (u32(1)))) != u32(0));
    var _S318 : bool;
    if(_S317)
    {
        _S318 = !driven_0;
    }
    else
    {
        _S318 = false;
    }
    var contact_island_0 : bool = (((isl_2.info_0.x) & (u32(4)))) != u32(0);
    var _S319 : bool = tid_4 == u32(0);
    var _S320 : bool;
    var run_0 : u32;
    if(_S319)
    {
        if(contact_island_0 != ((params_0.contact_mode_0) == u32(1)))
        {
            run_0 = u32(0);
        }
        else
        {
            run_0 = u32(1);
        }
        if(contact_island_0)
        {
            var _S321 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
            if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
            {
                _S320 = true;
            }
            else
            {
                var _S322 : u32 = _S321.y;
                if(_S322 != u32(0))
                {
                    _S320 = _S322 <= (isl_2.info_0.w);
                }
                else
                {
                    _S320 = false;
                }
            }
        }
        else
        {
            _S320 = false;
        }
        if(_S320)
        {
            run_0 = u32(0);
        }
        g_run_0 = run_0;
        g_halt_0 = u32(0);
    }
    workgroupBarrier();
    if((((isl_2.info_0.z) & (u32(1)))) != u32(0))
    {
        _S320 = true;
    }
    else
    {
        _S320 = g_run_0 == u32(0);
    }
    if(_S320)
    {
        run_0 = u32(0);
    }
    else
    {
        run_0 = min(isl_2.info_0.y, params_0.max_steps_0);
    }
    var _S323 : f32 = params_0.dt_0;
    var _S324 : bool = (params_0.fracture_0) != u32(0);
    var _S325 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var _S326 : vec3<f32> = params_0.gravity_0.xyz;
    var _S327 : f32 = isl_2.com_0.w;
    var rg_2 : Rigid_0;
    rg_2.rot_0 = quat_of_0(isl_2.rotation_0);
    rg_2.pos_1 = isl_2.position_0.xyz;
    rg_2.pos_err_1 = isl_2.position_err_0.xyz;
    rg_2.vel_1 = isl_2.velocity_0.xyz;
    rg_2.vel_err_1 = isl_2.velocity_err_0.xyz;
    rg_2.w_4 = isl_2.angular_velocity_0.xyz;
    var _S328 : vec3<f32> = vec3<f32>(0.0f);
    rg_2.a_11 = _S328;
    rg_2.alpha_0 = _S328;
    var work_2 : f32 = 0.0f;
    var work_err_1 : f32 = 0.0f;
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
        var abs_step_1 : u32 = isl_2.info_0.w + done_1 + u32(1);
        var k_18 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var i_9 : u32;
        var c_12 : u32;
        if(_S317)
        {
            var f_9 : vec3<f32> = _S328;
            var t_6 : vec3<f32> = _S328;
            i_9 = isl_2.range_0.x + tid_4;
            loop
            {
                if(i_9 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var fl_0 : vec3<f32>;
                var tl_0 : vec3<f32>;
                chunk_external_0(i_9, i_9, rg_2.rot_0, k_18, _S323, contact_island_0, false, &(fl_0), &(tl_0));
                var fc_3 : vec3<f32> = fl_0 + _S326 * vec3<f32>(chunks_0[i_9].center_0.w);
                var _S329 : vec3<f32> = chunks_0[i_9].center_0.xyz;
                var r_10 : vec3<f32> = rotate_0(rg_2.rot_0, _S329 + state_0[u32(4) * i_9].xyz - isl_2.com_0.xyz);
                f_9 = f_9 + fc_3;
                t_6 = t_6 + (cross(r_10, fc_3) + tl_0);
                var _S330 : vec4<u32> = chunks_0[i_9].load_range_0;
                c_12 = chunks_0[i_9].load_range_0.x;
                loop
                {
                    if(c_12 < (_S330.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S331 : u32 = u32(5) * c_12;
                    if(((bitcast<vec4<u32>>((loads_0[_S331]))).y) != u32(2))
                    {
                        c_12 = c_12 + u32(1);
                        continue;
                    }
                    var _S332 : vec3<f32> = vec3<f32>(eval_function_0(c_12, k_18, _S323, 0.0f));
                    var fw_1 : vec3<f32> = rotate_0(rg_2.rot_0, loads_0[_S331 + u32(1)].xyz * _S332);
                    f_9 = f_9 + fw_1;
                    t_6 = t_6 + (cross(rotate_0(rg_2.rot_0, _S329 - isl_2.com_0.xyz), fw_1) + rotate_0(rg_2.rot_0, loads_0[_S331 + u32(2)].xyz * _S332));
                    c_12 = c_12 + u32(1);
                }
                i_9 = i_9 + u32(256);
            }
            group_sum3_0(tid_4, &(f_9), &(t_6));
            var iw_w_0 : vec3<f32> = world_mul_0(rg_2.rot_0, isl_2.inertia0_0, isl_2.inertia1_0, isl_2.inertia2_0, rg_2.w_4);
            rg_2.a_11 = f_9 / vec3<f32>(_S327);
            rg_2.alpha_0 = world_mul_0(rg_2.rot_0, isl_2.inv0_0, isl_2.inv1_0, isl_2.inv2_0, t_6 - cross(rg_2.w_4, iw_w_0));
        }
        i_9 = isl_2.range_0.z + tid_4;
        loop
        {
            if(i_9 < (isl_2.range_0.w))
            {
            }
            else
            {
                break;
            }
            bond_update_0(i_9, _S323, _S324, abs_step_1);
            i_9 = i_9 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        c_12 = isl_2.range_0.x + tid_4;
        loop
        {
            if(c_12 < (isl_2.range_0.y))
            {
            }
            else
            {
                break;
            }
            chunk_update_0(c_12, isl_2, rg_2, _S323, _S325, k_18, contact_island_0, &(work_2), &(work_err_1));
            c_12 = c_12 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S318)
        {
            var iw_w_1 : vec3<f32> = world_mul_0(rg_2.rot_0, isl_2.inertia0_0, isl_2.inertia1_0, isl_2.inertia2_0, rg_2.w_4);
            var _S333 : vec3<f32> = vec3<f32>(_S323);
            var l_2 : vec3<f32> = iw_w_1 + (world_mul_0(rg_2.rot_0, isl_2.inertia0_0, isl_2.inertia1_0, isl_2.inertia2_0, rg_2.alpha_0) + cross(rg_2.w_4, iw_w_1)) * _S333;
            var _S334 : vec3<f32> = rg_2.a_11 * _S333;
            var _S335 : vec3<f32> = rg_2.vel_1;
            var _S336 : vec3<f32> = rg_2.vel_err_1;
            comp_add_0(&(_S335), &(_S336), _S334);
            rg_2.vel_1 = _S335;
            rg_2.vel_err_1 = _S336;
            var rot1_0 : Quat_0 = integrate_rotation_0(rg_2.rot_0, world_mul_0(rg_2.rot_0, isl_2.inv0_0, isl_2.inv1_0, isl_2.inv2_0, l_2), _S323);
            var delta_0 : vec3<f32> = (_S335 + _S336) * _S333 + (rotate_0(rg_2.rot_0, isl_2.com_0.xyz) - rotate_0(rot1_0, isl_2.com_0.xyz));
            var _S337 : vec3<f32> = rg_2.pos_1;
            var _S338 : vec3<f32> = rg_2.pos_err_1;
            comp_add_0(&(_S337), &(_S338), delta_0);
            rg_2.pos_1 = _S337;
            rg_2.pos_err_1 = _S338;
            rg_2.rot_0 = rot1_0;
            rg_2.w_4 = world_mul_0(rot1_0, isl_2.inv0_0, isl_2.inv1_0, isl_2.inv2_0, l_2);
        }
        if(_S317)
        {
            var wcom_1 : vec3<f32> = isl_2.wcom_0.xyz;
            var wmass_0 : f32 = isl_2.wcom_0.w;
            var tu_0 : vec3<f32> = _S328;
            var pv_0 : vec3<f32> = _S328;
            var c_13 : u32 = isl_2.range_0.x + tid_4;
            loop
            {
                if(c_13 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S339 : u32 = u32(4) * c_13;
                var _S340 : vec3<f32> = vec3<f32>((chunks_0[c_13].center_0.w * chunks_0[c_13].scale_0.x));
                tu_0 = tu_0 + state_0[_S339].xyz * _S340;
                pv_0 = pv_0 + state_0[_S339 + u32(2)].xyz * _S340;
                c_13 = c_13 + u32(256);
            }
            group_sum3_0(tid_4, &(tu_0), &(pv_0));
            var _S341 : vec3<f32> = vec3<f32>(wmass_0);
            var tr_0 : vec3<f32> = tu_0 / _S341;
            var dv_0 : vec3<f32> = pv_0 / _S341;
            var lu_0 : vec3<f32> = _S328;
            var lv_0 : vec3<f32> = _S328;
            var c_14 : u32 = isl_2.range_0.x + tid_4;
            loop
            {
                if(c_14 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var r_11 : vec3<f32> = chunks_0[c_14].center_0.xyz - wcom_1;
                var _S342 : u32 = u32(4) * c_14;
                var _S343 : vec3<f32> = vec3<f32>(chunks_0[c_14].center_0.w);
                var _S344 : vec3<f32> = vec3<f32>(chunks_0[c_14].scale_0.x);
                lu_0 = lu_0 + (cross(r_11, state_0[_S342].xyz - tr_0) * _S343 + rows_mul_0(chunks_0[c_14].inertia0_1, chunks_0[c_14].inertia1_1, chunks_0[c_14].inertia2_1, state_0[_S342 + u32(1)].xyz)) * _S344;
                lv_0 = lv_0 + (cross(r_11, state_0[_S342 + u32(2)].xyz - dv_0) * _S343 + rows_mul_0(chunks_0[c_14].inertia0_1, chunks_0[c_14].inertia1_1, chunks_0[c_14].inertia2_1, state_0[_S342 + u32(3)].xyz)) * _S344;
                c_14 = c_14 + u32(256);
            }
            group_sum3_0(tid_4, &(lu_0), &(lv_0));
            var phi_0 : vec3<f32> = rows_mul_0(isl_2.winv0_0, isl_2.winv1_0, isl_2.winv2_0, lu_0);
            var dw_0 : vec3<f32> = rows_mul_0(isl_2.winv0_0, isl_2.winv1_0, isl_2.winv2_0, lv_0);
            var c_15 : u32 = isl_2.range_0.x + tid_4;
            loop
            {
                if(c_15 < (isl_2.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var r_12 : vec3<f32> = chunks_0[c_15].center_0.xyz - wcom_1;
                var _S345 : u32 = u32(4) * c_15;
                state_0[_S345] = vec4<f32>(state_0[_S345].xyz - (tr_0 + cross(phi_0, r_12)), state_0[_S345].w);
                var _S346 : u32 = _S345 + u32(1);
                state_0[_S346] = vec4<f32>(state_0[_S346].xyz - phi_0, state_0[_S346].w);
                var _S347 : u32 = _S345 + u32(2);
                state_0[_S347] = vec4<f32>(state_0[_S347].xyz - (dv_0 + cross(dw_0, r_12)), state_0[_S347].w);
                var _S348 : u32 = _S345 + u32(3);
                state_0[_S348] = vec4<f32>(state_0[_S348].xyz - dw_0, state_0[_S348].w);
                c_15 = c_15 + u32(256);
            }
            if(!driven_0)
            {
                var rot_1 : Quat_0 = rg_2.rot_0;
                var _S349 : vec3<f32> = rotate_0(rg_2.rot_0, tr_0 - cross(phi_0, wcom_1));
                var _S350 : vec3<f32> = rg_2.pos_1;
                var _S351 : vec3<f32> = rg_2.pos_err_1;
                comp_add_0(&(_S350), &(_S351), _S349);
                rg_2.pos_1 = _S350;
                rg_2.pos_err_1 = _S351;
                rg_2.rot_0 = normalized_0(quat_mul_0(rg_2.rot_0, from_axis_angle_0(phi_0, length(phi_0))));
                var _S352 : vec3<f32> = rotate_0(rot_1, dv_0 + cross(dw_0, isl_2.com_0.xyz - wcom_1));
                var _S353 : vec3<f32> = rg_2.vel_1;
                var _S354 : vec3<f32> = rg_2.vel_err_1;
                comp_add_0(&(_S353), &(_S354), _S352);
                rg_2.vel_1 = _S353;
                rg_2.vel_err_1 = _S354;
                rg_2.w_4 = rg_2.w_4 + rotate_0(rot_1, dw_0);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S319)
        {
            _S320 = (isl_2.probes_0.y) > (isl_2.probes_0.x);
        }
        else
        {
            _S320 = false;
        }
        if(_S320)
        {
            record_probes_0(isl_2, rg_2, k_18);
        }
        var _S355 : u32 = done_1 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S355;
            break;
        }
        done_1 = _S355;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_2, work_err_1, 0.0f);
    var unused_2 : vec3<f32> = _S328;
    group_sum3_0(tid_4, &(wsum_0), &(unused_2));
    if(_S319)
    {
        isl_2.rotation_0 = quat_vec_0(rg_2.rot_0);
        isl_2.position_0 = vec4<f32>(rg_2.pos_1, 0.0f);
        isl_2.position_err_0 = vec4<f32>(rg_2.pos_err_1, 0.0f);
        isl_2.velocity_0 = vec4<f32>(rg_2.vel_1, 0.0f);
        isl_2.velocity_err_0 = vec4<f32>(rg_2.vel_err_1, 0.0f);
        isl_2.angular_velocity_0 = vec4<f32>(rg_2.w_4, 0.0f);
        isl_2.done_0[i32(0)] = done_1;
        isl_2.info_0[i32(1)] = isl_2.info_0[i32(1)] - done_1;
        if(g_halt_0 != u32(0))
        {
            _S318 = contact_island_0;
        }
        else
        {
            _S318 = false;
        }
        if(_S318)
        {
            var at_6 : u32 = isl_2.info_0.w + done_1;
            var previous_1 : u32 = islands_0[params_0.halt_index_0].info_0.y;
            if(previous_1 == u32(0))
            {
                run_0 = at_6;
            }
            else
            {
                run_0 = min(previous_1, at_6);
            }
            islands_0[params_0.halt_index_0].info_0[i32(1)] = run_0;
        }
        var _S356 : f32 = wsum_0.x;
        var _S357 : f32 = isl_2.energy_0[i32(0)];
        var _S358 : f32 = isl_2.energy_0[i32(1)];
        comp_add1_1(&(_S357), &(_S358), _S356);
        isl_2.energy_0[i32(0)] = _S357;
        isl_2.energy_0[i32(1)] = _S358 + wsum_0.y;
        isl_2.info_0[i32(3)] = isl_2.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_2.info_0[i32(2)] = ((isl_2.info_0[i32(2)]) | (u32(1)));
        }
        islands_0[_S316].range_0 = isl_2.range_0;
        islands_0[_S316].info_0 = isl_2.info_0;
        islands_0[_S316].com_0 = isl_2.com_0;
        islands_0[_S316].inertia0_0 = isl_2.inertia0_0;
        islands_0[_S316].inertia1_0 = isl_2.inertia1_0;
        islands_0[_S316].inertia2_0 = isl_2.inertia2_0;
        islands_0[_S316].inv0_0 = isl_2.inv0_0;
        islands_0[_S316].inv1_0 = isl_2.inv1_0;
        islands_0[_S316].inv2_0 = isl_2.inv2_0;
        islands_0[_S316].wcom_0 = isl_2.wcom_0;
        islands_0[_S316].winv0_0 = isl_2.winv0_0;
        islands_0[_S316].winv1_0 = isl_2.winv1_0;
        islands_0[_S316].winv2_0 = isl_2.winv2_0;
        islands_0[_S316].rotation_0 = isl_2.rotation_0;
        islands_0[_S316].position_0 = isl_2.position_0;
        islands_0[_S316].position_err_0 = isl_2.position_err_0;
        islands_0[_S316].velocity_0 = isl_2.velocity_0;
        islands_0[_S316].velocity_err_0 = isl_2.velocity_err_0;
        islands_0[_S316].angular_velocity_0 = isl_2.angular_velocity_0;
        islands_0[_S316].done_0 = isl_2.done_0;
        islands_0[_S316].probes_0 = isl_2.probes_0;
        islands_0[_S316].energy_0 = isl_2.energy_0;
    }
    return;
}

