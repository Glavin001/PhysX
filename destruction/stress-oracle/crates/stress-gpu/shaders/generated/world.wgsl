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
    @align(16) solve_mode_0 : u32,
    @align(4) cload_base_0 : u32,
    @align(8) cframe_base_0 : u32,
    @align(4) pad0_0 : u32,
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

@binding(5) @group(0) var<storage, read> loads_0 : array<vec4<f32>>;

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
fn stopped_0() -> bool
{
    var _S1 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S2 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S2 = true;
    }
    else
    {
        _S2 = (_S1.y) != u32(0);
    }
    return _S2;
}

struct Quat_0
{
     w_0 : f32,
     x_0 : f32,
     y_0 : f32,
     z_0 : f32,
};

fn quat_of_0( q_0 : vec4<f32>) -> Quat_0
{
    var r_0 : Quat_0;
    r_0.x_0 = q_0.x;
    r_0.y_0 = q_0.y;
    r_0.z_0 = q_0.z;
    r_0.w_0 = q_0.w;
    return r_0;
}

fn rotate_0( q_1 : Quat_0,  v_0 : vec3<f32>) -> vec3<f32>
{
    var qv_0 : vec3<f32> = vec3<f32>(q_1.x_0, q_1.y_0, q_1.z_0);
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
    var _S3 : vec3<f32>;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S3 = v_1 / vec3<f32>(n_0);
    }
    else
    {
        _S3 = vec3<f32>(0.0f);
    }
    return _S3;
}

fn from_axis_angle_0( axis_0 : vec3<f32>,  angle_0 : f32) -> Quat_0
{
    var a_1 : vec3<f32> = safe_normalize_0(axis_0);
    var _S4 : f32 = 0.5f * angle_0;
    var s_0 : f32 = sin(_S4);
    var q_3 : Quat_0;
    q_3.w_0 = cos(_S4);
    q_3.x_0 = a_1.x * s_0;
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
     hull_at_0 : u32,
     hull_v_0 : u32,
     hull_f_0 : u32,
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
    b_1.hull_at_0 = (bitcast<u32>((chunks_0[c_1].cmat_0.z)));
    var _S5 : u32 = (bitcast<u32>((chunks_0[c_1].cmat_0.w)));
    b_1.hull_v_0 = (_S5 & (u32(255)));
    b_1.hull_f_0 = (_S5 >> (u32(8)));
    return b_1;
}

fn sample_count_0( b_2 : Box_0) -> u32
{
    var _S6 : u32;
    if((b_2.hull_v_0) == u32(0))
    {
        _S6 = u32(14);
    }
    else
    {
        _S6 = b_2.hull_v_0 + b_2.hull_f_0;
    }
    return _S6;
}

fn may_overlap_0( a_2 : Box_0,  b_3 : Box_0) -> bool
{
    var _S7 : vec3<f32> = b_3.center_1 - a_2.center_1;
    var _S8 : f32 = 0.00000999999974738f * (length(a_2.half_2) + length(b_3.half_2));
    var _S9 : array<vec3<f32>, i32(6)> = array<vec3<f32>, i32(6)>( a_2.axis0_0, a_2.axis1_0, a_2.axis2_0, b_3.axis0_0, b_3.axis1_0, b_3.axis2_0 );
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
            l_0 = _S9[i_0];
        }
        else
        {
            var _S10 : u32 = i_0 - u32(6);
            l_0 = cross(_S9[_S10 / u32(3)], _S9[u32(3) + _S10 % u32(3)]);
        }
        var len_0 : f32 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + u32(1);
            continue;
        }
        if((abs(dot(_S7, l_0))) > (a_2.half_2.x * abs(dot(a_2.axis0_0, l_0)) + a_2.half_2.y * abs(dot(a_2.axis1_0, l_0)) + a_2.half_2.z * abs(dot(a_2.axis2_0, l_0)) + (b_3.half_2.x * abs(dot(b_3.axis0_0, l_0)) + b_3.half_2.y * abs(dot(b_3.axis1_0, l_0)) + b_3.half_2.z * abs(dot(b_3.axis2_0, l_0))) + _S8 * len_0))
        {
            return false;
        }
        i_0 = i_0 + u32(1);
    }
    return true;
}

fn chunk_velocity_0( c_2 : u32,  v_2 : ptr<function, vec3<f32>>,  w_2 : ptr<function, vec3<f32>>)
{
    var q_5 : Quat_0 = quat_of_0(islands_0[chunks_0[c_2].info_1.y].rotation_0);
    var _S11 : u32 = u32(4) * c_2;
    var _S12 : vec3<f32> = islands_0[chunks_0[c_2].info_1.y].angular_velocity_0.xyz;
    (*v_2) = islands_0[chunks_0[c_2].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_2].info_1.y].velocity_err_0.xyz + cross(_S12, rotate_0(q_5, chunks_0[c_2].center_0.xyz + state_0[_S11].xyz - islands_0[chunks_0[c_2].info_1.y].com_0.xyz)) + rotate_0(q_5, state_0[_S11 + u32(2)].xyz);
    (*w_2) = _S12 + rotate_0(q_5, state_0[_S11 + u32(3)].xyz);
    return;
}

fn chunk_velocity_1( c_3 : u32,  v_3 : ptr<function, vec3<f32>>,  w_3 : ptr<function, vec3<f32>>)
{
    var q_6 : Quat_0 = quat_of_0(islands_0[chunks_0[c_3].info_1.y].rotation_0);
    var _S13 : u32 = u32(4) * c_3;
    var _S14 : vec3<f32> = islands_0[chunks_0[c_3].info_1.y].angular_velocity_0.xyz;
    (*v_3) = islands_0[chunks_0[c_3].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_3].info_1.y].velocity_err_0.xyz + cross(_S14, rotate_0(q_6, chunks_0[c_3].center_0.xyz + state_0[_S13].xyz - islands_0[chunks_0[c_3].info_1.y].com_0.xyz)) + rotate_0(q_6, state_0[_S13 + u32(2)].xyz);
    (*w_3) = _S14 + rotate_0(q_6, state_0[_S13 + u32(3)].xyz);
    return;
}

fn box_to_world_0( b_4 : Box_0,  local_0 : vec3<f32>) -> vec3<f32>
{
    return b_4.axis0_0 * vec3<f32>(local_0.x) + b_4.axis1_0 * vec3<f32>(local_0.y) + b_4.axis2_0 * vec3<f32>(local_0.z);
}

fn box_axis_0( b_5 : Box_0,  k_0 : u32) -> vec3<f32>
{
    var _S15 : vec3<f32>;
    if(k_0 == u32(0))
    {
        _S15 = b_5.axis0_0;
    }
    else
    {
        if(k_0 == u32(1))
        {
            _S15 = b_5.axis1_0;
        }
        else
        {
            _S15 = b_5.axis2_0;
        }
    }
    return _S15;
}

fn comp3_0( v_4 : vec3<f32>,  k_1 : u32) -> f32
{
    var _S16 : f32;
    if(k_1 == u32(0))
    {
        _S16 = v_4.x;
    }
    else
    {
        if(k_1 == u32(1))
        {
            _S16 = v_4.y;
        }
        else
        {
            _S16 = v_4.z;
        }
    }
    return _S16;
}

fn sample_point_0( b_6 : Box_0,  i_1 : u32) -> vec3<f32>
{
    if((b_6.hull_v_0) != u32(0))
    {
        var local_1 : vec3<f32>;
        if(i_1 < (b_6.hull_v_0))
        {
            local_1 = loads_0[b_6.hull_at_0 + i_1].xyz * vec3<f32>(0.89999997615814209f);
        }
        else
        {
            local_1 = loads_0[b_6.hull_at_0 + b_6.hull_v_0 + b_6.hull_f_0 + (i_1 - b_6.hull_v_0)].xyz;
        }
        return b_6.center_1 + box_to_world_0(b_6, local_1);
    }
    var sign_0 : f32;
    if(i_1 < u32(8))
    {
        var h_0 : vec3<f32> = b_6.half_2 * vec3<f32>(0.89999997615814209f);
        if(((i_1 & (u32(1)))) == u32(0))
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        var _S17 : f32;
        if(((i_1 & (u32(2)))) == u32(0))
        {
            _S17 = - h_0.y;
        }
        else
        {
            _S17 = h_0.y;
        }
        var _S18 : f32;
        if(((i_1 & (u32(4)))) == u32(0))
        {
            _S18 = - h_0.z;
        }
        else
        {
            _S18 = h_0.z;
        }
        return b_6.center_1 + b_6.axis0_0 * vec3<f32>(sign_0) + b_6.axis1_0 * vec3<f32>(_S17) + b_6.axis2_0 * vec3<f32>(_S18);
    }
    var _S19 : u32 = i_1 - u32(8);
    var axis_1 : u32 = _S19 / u32(2);
    if((_S19 % u32(2)) == u32(0))
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    return b_6.center_1 + box_axis_0(b_6, axis_1) * vec3<f32>((sign_0 * comp3_0(b_6.half_2, axis_1)));
}

fn box_to_local_0( b_7 : Box_0,  r_1 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r_1, b_7.axis0_0), dot(r_1, b_7.axis1_0), dot(r_1, b_7.axis2_0));
}

fn hull_signed_distance_0( b_8 : Box_0,  local_2 : vec3<f32>,  face_0 : ptr<function, u32>) -> f32
{
    (*face_0) = u32(0);
    var best_0 : f32 = -1.00000001504746622e+30f;
    var f_0 : u32 = u32(0);
    loop
    {
        if(f_0 < (b_8.hull_f_0))
        {
        }
        else
        {
            break;
        }
        var plane_0 : vec4<f32> = loads_0[b_8.hull_at_0 + b_8.hull_v_0 + f_0];
        var d_0 : f32 = dot(plane_0.xyz, local_2) - plane_0.w;
        if(d_0 > best_0)
        {
            (*face_0) = f_0;
            best_0 = d_0;
        }
        f_0 = f_0 + u32(1);
    }
    return best_0;
}

fn penetration_0( b_9 : Box_0,  p_0 : vec3<f32>,  depth_0 : ptr<function, f32>,  normal_1 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_0) = 0.0f;
    (*normal_1) = vec3<f32>(0.0f);
    var r_2 : vec3<f32> = p_0 - b_9.center_1;
    var _S20 : vec3<f32> = b_9.half_2;
    if((dot(r_2, r_2)) > (dot(_S20, _S20) * 1.00001001358032227f))
    {
        return false;
    }
    if((b_9.hull_v_0) != u32(0))
    {
        var face_1 : u32;
        var d_1 : f32 = hull_signed_distance_0(b_9, box_to_local_0(b_9, r_2), &(face_1));
        if(!(d_1 < 0.0f))
        {
            return false;
        }
        (*depth_0) = - d_1;
        (*normal_1) = box_to_world_0(b_9, loads_0[b_9.hull_at_0 + b_9.hull_v_0 + face_1].xyz);
        return true;
    }
    var best_1 : f32 = 1.00000001504746622e+30f;
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
        var local_3 : f32 = dot(r_2, box_axis_0(b_9, k_2));
        var d_2 : f32 = comp3_0(b_9.half_2, k_2) - abs(local_3);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_1)
        {
            var _S21 : f32;
            if(local_3 >= 0.0f)
            {
                _S21 = 1.0f;
            }
            else
            {
                _S21 = -1.0f;
            }
            best_1 = d_2;
            axis_2 = k_2;
            side_0 = _S21;
        }
        k_2 = k_2 + u32(1);
    }
    (*depth_0) = best_1;
    (*normal_1) = box_axis_0(b_9, axis_2) * vec3<f32>(side_0);
    return true;
}

fn penetration_1( b_10 : Box_0,  p_1 : vec3<f32>,  depth_1 : ptr<function, f32>,  normal_2 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_1) = 0.0f;
    (*normal_2) = vec3<f32>(0.0f);
    var r_3 : vec3<f32> = p_1 - b_10.center_1;
    var _S22 : vec3<f32> = b_10.half_2;
    if((dot(r_3, r_3)) > (dot(_S22, _S22) * 1.00001001358032227f))
    {
        return false;
    }
    if((b_10.hull_v_0) != u32(0))
    {
        var face_2 : u32;
        var d_3 : f32 = hull_signed_distance_0(b_10, box_to_local_0(b_10, r_3), &(face_2));
        if(!(d_3 < 0.0f))
        {
            return false;
        }
        (*depth_1) = - d_3;
        (*normal_2) = box_to_world_0(b_10, loads_0[b_10.hull_at_0 + b_10.hull_v_0 + face_2].xyz);
        return true;
    }
    var best_2 : f32 = 1.00000001504746622e+30f;
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
        var local_4 : f32 = dot(r_3, box_axis_0(b_10, k_3));
        var d_4 : f32 = comp3_0(b_10.half_2, k_3) - abs(local_4);
        if(d_4 <= 0.0f)
        {
            return false;
        }
        if(d_4 < best_2)
        {
            var _S23 : f32;
            if(local_4 >= 0.0f)
            {
                _S23 = 1.0f;
            }
            else
            {
                _S23 = -1.0f;
            }
            best_2 = d_4;
            axis_3 = k_3;
            side_1 = _S23;
        }
        k_3 = k_3 + u32(1);
    }
    (*depth_1) = best_2;
    (*normal_2) = box_axis_0(b_10, axis_3) * vec3<f32>(side_1);
    return true;
}

fn pair_point_0( ba_0 : Box_0,  bb_0 : Box_0,  na_0 : u32,  e_0 : u32,  p_2 : ptr<function, vec3<f32>>,  n_1 : ptr<function, vec3<f32>>,  d_5 : ptr<function, f32>) -> bool
{
    if(e_0 < na_0)
    {
        var _S24 : vec3<f32> = sample_point_0(ba_0, e_0);
        (*p_2) = _S24;
        var _S25 : bool = penetration_1(bb_0, _S24, &((*d_5)), &((*n_1)));
        return _S25;
    }
    var _S26 : vec3<f32> = sample_point_0(bb_0, e_0 - na_0);
    (*p_2) = _S26;
    var _S27 : bool = penetration_1(ba_0, _S26, &((*d_5)), &((*n_1)));
    if(!_S27)
    {
        return false;
    }
    (*n_1) = (vec3<f32>(0) - (*n_1));
    return true;
}

fn is_nan_0( x_1 : f32) -> bool
{
    return (((bitcast<u32>((x_1))) & (u32(2147483647)))) > u32(2139095040);
}

fn half_thickness_and_area_0( b_11 : Box_0,  d_6 : vec3<f32>) -> vec2<f32>
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
        var c_4 : f32 = abs(dot(d_6, box_axis_0(b_11, k_4)));
        var h_2 : f32 = h_1 + c_4 * comp3_0(b_11.half_2, k_4);
        var _S28 : u32 = k_4 + u32(1);
        var area_1 : f32 = area_0 + c_4 * 4.0f * comp3_0(b_11.half_2, _S28 % u32(3)) * comp3_0(b_11.half_2, (k_4 + u32(2)) % u32(3));
        k_4 = _S28;
        h_1 = h_2;
        area_0 = area_1;
    }
    return vec2<f32>(h_1, area_0);
}

fn contact_stiffness_0( ea_0 : f32,  a_3 : Box_0,  eb_0 : f32,  b_12 : Box_0,  dir_0 : vec3<f32>) -> f32
{
    var d_7 : vec3<f32> = safe_normalize_0(dir_0);
    var ta_0 : vec2<f32> = half_thickness_and_area_0(a_3, d_7);
    var tb_0 : vec2<f32> = half_thickness_and_area_0(b_12, d_7);
    return min(ta_0.y, tb_0.y) / (ta_0.x / ea_0 + tb_0.x / eb_0);
}

fn penalty_force_0( k_5 : f32,  m_red_0 : f32,  friction_0 : f32,  depth_2 : f32,  normal_3 : vec3<f32>,  rel_velocity_0 : vec3<f32>,  dt_1 : f32,  points_0 : u32,  stored_0 : ptr<function, f32>,  dissipated_1 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_0 : f32 = 1.0f / max(f32(points_0), 10.0f) * m_red_0 / dt_1;
    var vn_0 : f32 = dot(rel_velocity_0, normal_3);
    var _S29 : f32 = k_5 * depth_2;
    var _S30 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    var _S31 : f32 = _S29 - _S30;
    var _S32 : f32 = max(_S31, 0.0f);
    var vt_0 : vec3<f32> = rel_velocity_0 - normal_3 * vec3<f32>(vn_0);
    var vt_mag_0 : f32 = length(vt_0);
    var _S33 : f32 = friction_0 * _S32;
    var _S34 : f32 = min(_S33, min(c_max_0, _S33 / 0.00100000004749745f) * vt_mag_0);
    var ft_0 : vec3<f32>;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = (vec3<f32>(0) - vt_0) * vec3<f32>((_S34 / vt_mag_0));
    }
    else
    {
        ft_0 = vec3<f32>(0.0f);
    }
    (*stored_0) = 0.5f * k_5 * depth_2 * depth_2;
    var damping_power_0 : f32;
    if(_S31 > 0.0f)
    {
        damping_power_0 = _S30 * vn_0;
    }
    else
    {
        damping_power_0 = _S29 * max(vn_0, 0.0f);
    }
    (*dissipated_1) = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * vec3<f32>(_S32) + ft_0;
}

fn penalty_force_1( k_6 : f32,  m_red_1 : f32,  friction_1 : f32,  depth_3 : f32,  normal_4 : vec3<f32>,  rel_velocity_1 : vec3<f32>,  dt_2 : f32,  points_1 : u32,  stored_1 : ptr<function, f32>,  dissipated_2 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_1 : f32 = 1.0f / max(f32(points_1), 10.0f) * m_red_1 / dt_2;
    var vn_1 : f32 = dot(rel_velocity_1, normal_4);
    var _S35 : f32 = k_6 * depth_3;
    var _S36 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_6 * m_red_1), c_max_1) * vn_1;
    var _S37 : f32 = _S35 - _S36;
    var _S38 : f32 = max(_S37, 0.0f);
    var vt_1 : vec3<f32> = rel_velocity_1 - normal_4 * vec3<f32>(vn_1);
    var vt_mag_1 : f32 = length(vt_1);
    var _S39 : f32 = friction_1 * _S38;
    var _S40 : f32 = min(_S39, min(c_max_1, _S39 / 0.00100000004749745f) * vt_mag_1);
    var ft_1 : vec3<f32>;
    if(vt_mag_1 > 0.0f)
    {
        ft_1 = (vec3<f32>(0) - vt_1) * vec3<f32>((_S40 / vt_mag_1));
    }
    else
    {
        ft_1 = vec3<f32>(0.0f);
    }
    (*stored_1) = 0.5f * k_6 * depth_3 * depth_3;
    var damping_power_1 : f32;
    if(_S37 > 0.0f)
    {
        damping_power_1 = _S36 * vn_1;
    }
    else
    {
        damping_power_1 = _S35 * max(vn_1, 0.0f);
    }
    (*dissipated_2) = (damping_power_1 + length(ft_1) * vt_mag_1) * dt_2;
    return normal_4 * vec3<f32>(_S38) + ft_1;
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
    var _S41 : u32 = index_0[at_0 + u32(3)];
    var _S42 : f32 = (bitcast<f32>((index_0[at_0 + u32(4)])));
    var _S43 : f32 = (bitcast<f32>((index_0[at_0 + u32(5)])));
    var _S44 : f32 = params_0.dt_0;
    var out_0 : u32 = params_0.slot_base_0 + u32(2) * index_0[at_0 + u32(2)];
    var cb_rel_0 : vec3<f32> = world_diff_0(chunk_world_0(cb_0), chunk_world_0(ca_0));
    var touching_0 : bool = !((length(cb_rel_0)) > (chunks_0[ca_0].half_0.w + chunks_0[cb_0].half_0.w));
    var ledger_1 : vec4<f32> = scratch_0[params_0.ledger_base_0 + i_2];
    var flags_0 : u32 = (bitcast<u32>((scratch_0[params_0.ledger_base_0 + i_2].w)));
    var _S45 : vec3<f32> = vec3<f32>(0.0f);
    var ba_1 : Box_0 = chunk_box_0(ca_0, _S45);
    var bb_1 : Box_0 = chunk_box_0(cb_0, cb_rel_0);
    var _S46 : u32 = sample_count_0(ba_1);
    var _S47 : u32 = _S46 + sample_count_0(bb_1);
    var e_1 : u32;
    var has_state_0 : bool;
    if(!touching_0)
    {
        if(((flags_0 & (u32(1)))) != u32(0))
        {
            e_1 = u32(0);
            loop
            {
                if(e_1 < _S47)
                {
                }
                else
                {
                    break;
                }
                contact_state_0[_S41 + e_1] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                e_1 = e_1 + u32(1);
            }
        }
        if(((flags_0 & (u32(2)))) != u32(0))
        {
            e_1 = u32(0);
            loop
            {
                if(e_1 < u32(4))
                {
                }
                else
                {
                    break;
                }
                scratch_0[out_0 + e_1] = vec4<f32>(0.0f);
                e_1 = e_1 + u32(1);
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
    var count_0 : u32;
    var fa_0 : vec3<f32>;
    var ta_1 : vec3<f32>;
    var fb_0 : vec3<f32>;
    var tb_1 : vec3<f32>;
    var stored_sum_0 : f32;
    if(may_overlap_0(ba_1, bb_1))
    {
        var va0_0 : vec3<f32>;
        var wa0_0 : vec3<f32>;
        chunk_velocity_0(ca_0, &(va0_0), &(wa0_0));
        var vb0_0 : vec3<f32>;
        var wb0_0 : vec3<f32>;
        chunk_velocity_0(cb_0, &(vb0_0), &(wb0_0));
        e_1 = u32(0);
        count_0 = u32(0);
        var engaged_0 : u32 = u32(0);
        loop
        {
            if(e_1 < _S47)
            {
            }
            else
            {
                break;
            }
            var p_3 : vec3<f32>;
            var n_2 : vec3<f32>;
            var d_8 : f32;
            var _S48 : bool = pair_point_0(ba_1, bb_1, _S46, e_1, &(p_3), &(n_2), &(d_8));
            if(!_S48)
            {
                var _S49 : u32 = _S41 + e_1;
                if(!is_nan_0(contact_state_0[_S49].x))
                {
                    contact_state_0[_S49] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                }
                e_1 = e_1 + u32(1);
                continue;
            }
            var _S50 : u32 = count_0 + u32(1);
            var _S51 : u32 = _S41 + e_1;
            var entry_0 : vec4<f32> = contact_state_0[_S51];
            if(is_nan_0(contact_state_0[_S51].x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_8 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - bb_1.center_1)), n_2)) * _S44 + 9.99999971718068537e-10f))
                {
                    stored_sum_0 = d_8;
                }
                else
                {
                    stored_sum_0 = 0.0f;
                }
                entry_0 = vec4<f32>(stored_sum_0, n_2);
            }
            entry_0[i32(0)] = min(entry_0.x, d_8);
            contact_state_0[_S51] = entry_0;
            var engaged_1 : u32;
            if((d_8 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + u32(1);
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S50;
            engaged_0 = engaged_1;
            e_1 = e_1 + u32(1);
        }
        if(count_0 > u32(0))
        {
            var _S52 : f32 = contact_stiffness_0(chunks_0[ca_0].cmat_0.x, ba_1, chunks_0[cb_0].cmat_0.x, bb_1, bb_1.center_1 - ba_1.center_1) / max(f32(engaged_0), 10.0f);
            e_1 = u32(0);
            fa_0 = _S45;
            ta_1 = _S45;
            fb_0 = _S45;
            tb_1 = _S45;
            stored_sum_0 = 0.0f;
            loop
            {
                if(e_1 < _S47)
                {
                }
                else
                {
                    break;
                }
                var p_4 : vec3<f32>;
                var n_3 : vec3<f32>;
                var d_9 : f32;
                var _S53 : bool = pair_point_0(ba_1, bb_1, _S46, e_1, &(p_4), &(n_3), &(d_9));
                if(!_S53)
                {
                    e_1 = e_1 + u32(1);
                    continue;
                }
                var eff_0 : f32 = d_9 - contact_state_0[_S41 + e_1].x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + u32(1);
                    continue;
                }
                var stored_2 : f32;
                var diss_0 : f32;
                var f_1 : vec3<f32> = penalty_force_0(_S52, _S42, _S43, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - bb_1.center_1)), _S44, engaged_0, &(stored_2), &(diss_0));
                var fa_1 : vec3<f32> = fa_0 + f_1;
                var ta_2 : vec3<f32> = ta_1 + cross(p_4, f_1);
                var _S54 : vec3<f32> = (vec3<f32>(0) - f_1);
                var fb_1 : vec3<f32> = fb_0 + _S54;
                var tb_2 : vec3<f32> = tb_1 + cross(p_4 - bb_1.center_1, _S54);
                var stored_sum_1 : f32 = stored_sum_0 + stored_2;
                var _S55 : f32 = ledger_1[i32(1)];
                var _S56 : f32 = ledger_1[i32(2)];
                comp_add1_1(&(_S55), &(_S56), diss_0);
                ledger_1[i32(1)] = _S55;
                ledger_1[i32(2)] = _S56;
                fa_0 = fa_1;
                ta_1 = ta_2;
                fb_0 = fb_1;
                tb_1 = tb_2;
                stored_sum_0 = stored_sum_1;
                e_1 = e_1 + u32(1);
            }
            has_state_0 = true;
        }
        else
        {
            has_state_0 = false;
            fa_0 = _S45;
            ta_1 = _S45;
            fb_0 = _S45;
            tb_1 = _S45;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S45;
        ta_1 = _S45;
        fb_0 = _S45;
        tb_1 = _S45;
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
        e_1 = u32(0);
        loop
        {
            if(e_1 < _S47)
            {
            }
            else
            {
                break;
            }
            contact_state_0[_S41 + e_1] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
            e_1 = e_1 + u32(1);
        }
    }
    var _S57 : vec3<f32> = vec3<f32>(0.0f);
    if((any((fa_0 != _S57))))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((ta_1 != _S57)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((fb_0 != _S57)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((tb_1 != _S57)));
    }
    var _S58 : bool;
    if(loaded_0)
    {
        _S58 = true;
    }
    else
    {
        _S58 = ((flags_0 & (u32(2)))) != u32(0);
    }
    if(_S58)
    {
        scratch_0[out_0] = vec4<f32>(fa_0, 0.0f);
        scratch_0[out_0 + u32(1)] = vec4<f32>(ta_1, 0.0f);
        scratch_0[out_0 + u32(2)] = vec4<f32>(fb_0, 0.0f);
        scratch_0[out_0 + u32(3)] = vec4<f32>(tb_1, 0.0f);
    }
    ledger_1[i32(0)] = stored_sum_0;
    if(has_state_0)
    {
        e_1 = u32(1);
    }
    else
    {
        e_1 = u32(0);
    }
    if(loaded_0)
    {
        count_0 = u32(2);
    }
    else
    {
        count_0 = u32(0);
    }
    ledger_1[i32(3)] = (bitcast<f32>(((e_1 | (count_0)))));
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
    var b_13 : Box_0;
    b_13.center_1 = center_3;
    b_13.axis0_0 = rotate_0(q_7, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_13.axis1_0 = rotate_0(q_7, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_13.axis2_0 = rotate_0(q_7, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_13.half_2 = half_3;
    b_13.hull_at_0 = u32(0);
    b_13.hull_v_0 = u32(0);
    b_13.hull_f_0 = u32(0);
    return b_13;
}

fn impactor_slots_0( imp_1 : ptr<function, Impactor_std430_0>,  b_14 : Box_0) -> u32
{
    var _S59 : u32;
    if(((*imp_1).shape_0.x) == 0.0f)
    {
        _S59 = u32(1);
    }
    else
    {
        _S59 = sample_count_0(b_14) + u32(14);
    }
    return _S59;
}

fn impactor_slots_1( imp_2 : ptr<function, Impactor_std430_0>,  b_15 : Box_0) -> u32
{
    var _S60 : u32;
    if(((*imp_2).shape_0.x) == 0.0f)
    {
        _S60 = u32(1);
    }
    else
    {
        _S60 = sample_count_0(b_15) + u32(14);
    }
    return _S60;
}

fn impactor_slots_2( imp_3 : ptr<function, Impactor_std430_0>,  b_16 : Box_0) -> u32
{
    var _S61 : u32;
    if(((*imp_3).shape_0.x) == 0.0f)
    {
        _S61 = u32(1);
    }
    else
    {
        _S61 = sample_count_0(b_16) + u32(14);
    }
    return _S61;
}

fn sphere_contact_0( b_17 : Box_0,  center_4 : vec3<f32>,  radius_0 : f32,  point_0 : ptr<function, vec3<f32>>,  normal_5 : ptr<function, vec3<f32>>,  depth_4 : ptr<function, f32>) -> bool
{
    var _S62 : vec3<f32> = vec3<f32>(0.0f);
    (*point_0) = _S62;
    (*normal_5) = _S62;
    (*depth_4) = 0.0f;
    var r_4 : vec3<f32> = center_4 - b_17.center_1;
    var local_5 : vec3<f32> = vec3<f32>(dot(r_4, b_17.axis0_0), dot(r_4, b_17.axis1_0), dot(r_4, b_17.axis2_0));
    if((b_17.hull_v_0) != u32(0))
    {
        var face_3 : u32;
        var d_10 : f32 = hull_signed_distance_0(b_17, local_5, &(face_3));
        if(d_10 >= radius_0)
        {
            return false;
        }
        var _S63 : vec3<f32> = box_to_world_0(b_17, loads_0[b_17.hull_at_0 + b_17.hull_v_0 + face_3].xyz);
        (*normal_5) = _S63;
        (*point_0) = center_4 - _S63 * vec3<f32>(max(d_10, 0.0f));
        (*depth_4) = radius_0 - d_10;
        return true;
    }
    var q_8 : vec3<f32> = clamp(local_5, (vec3<f32>(0) - b_17.half_2), b_17.half_2);
    var d_11 : vec3<f32> = local_5 - q_8;
    var dist_0 : f32 = length(d_11);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        var dn_0 : vec3<f32> = d_11 / vec3<f32>(dist_0);
        (*normal_5) = b_17.axis0_0 * vec3<f32>(dn_0.x) + b_17.axis1_0 * vec3<f32>(dn_0.y) + b_17.axis2_0 * vec3<f32>(dn_0.z);
        (*point_0) = b_17.center_1 + b_17.axis0_0 * vec3<f32>(q_8.x) + b_17.axis1_0 * vec3<f32>(q_8.y) + b_17.axis2_0 * vec3<f32>(q_8.z);
        (*depth_4) = radius_0 - dist_0;
        return true;
    }
    var inside_0 : f32;
    var n_4 : vec3<f32>;
    var _S64 : bool = penetration_0(b_17, center_4, &(inside_0), &(n_4));
    if(!_S64)
    {
        return false;
    }
    (*normal_5) = n_4;
    (*point_0) = center_4 - n_4 * vec3<f32>(min(radius_0, inside_0));
    (*depth_4) = radius_0 + inside_0;
    return true;
}

fn impactor_contact_0( imp_4 : ptr<function, Impactor_std430_0>,  crush_depth_0 : f32,  shrunk_0 : Box_0,  b_18 : Box_0,  j_0 : u32,  p_5 : ptr<function, vec3<f32>>,  n_5 : ptr<function, vec3<f32>>,  d_12 : ptr<function, f32>) -> bool
{
    var _S65 : vec3<f32> = vec3<f32>(0.0f);
    (*p_5) = _S65;
    (*n_5) = _S65;
    (*d_12) = 0.0f;
    var _S66 : vec4<f32> = (*imp_4).shape_0;
    if(((*imp_4).shape_0.x) == 0.0f)
    {
        var _S67 : bool = sphere_contact_0(b_18, _S65, _S66.y - crush_depth_0, &((*p_5)), &((*n_5)), &((*d_12)));
        if(!_S67)
        {
            return false;
        }
        (*n_5) = (vec3<f32>(0) - (*n_5));
        return true;
    }
    var cb_1 : u32 = sample_count_0(b_18);
    if(j_0 < cb_1)
    {
        var _S68 : vec3<f32> = sample_point_0(b_18, j_0);
        (*p_5) = _S68;
        var _S69 : bool = penetration_0(shrunk_0, _S68, &((*d_12)), &((*n_5)));
        return _S69;
    }
    var _S70 : vec3<f32> = sample_point_0(shrunk_0, j_0 - cb_1);
    (*p_5) = _S70;
    var _S71 : bool = penetration_0(b_18, _S70, &((*d_12)), &((*n_5)));
    if(!_S71)
    {
        return false;
    }
    (*n_5) = (vec3<f32>(0) - (*n_5));
    return true;
}

fn impactor_contact_1( imp_5 : ptr<function, Impactor_std430_0>,  crush_depth_1 : f32,  shrunk_1 : Box_0,  b_19 : Box_0,  j_1 : u32,  p_6 : ptr<function, vec3<f32>>,  n_6 : ptr<function, vec3<f32>>,  d_13 : ptr<function, f32>) -> bool
{
    var _S72 : vec3<f32> = vec3<f32>(0.0f);
    (*p_6) = _S72;
    (*n_6) = _S72;
    (*d_13) = 0.0f;
    var _S73 : vec4<f32> = (*imp_5).shape_0;
    if(((*imp_5).shape_0.x) == 0.0f)
    {
        var _S74 : bool = sphere_contact_0(b_19, _S72, _S73.y - crush_depth_1, &((*p_6)), &((*n_6)), &((*d_13)));
        if(!_S74)
        {
            return false;
        }
        (*n_6) = (vec3<f32>(0) - (*n_6));
        return true;
    }
    var cb_2 : u32 = sample_count_0(b_19);
    if(j_1 < cb_2)
    {
        var _S75 : vec3<f32> = sample_point_0(b_19, j_1);
        (*p_6) = _S75;
        var _S76 : bool = penetration_0(shrunk_1, _S75, &((*d_13)), &((*n_6)));
        return _S76;
    }
    var _S77 : vec3<f32> = sample_point_0(shrunk_1, j_1 - cb_2);
    (*p_6) = _S77;
    var _S78 : bool = penetration_0(b_19, _S77, &((*d_13)), &((*n_6)));
    if(!_S78)
    {
        return false;
    }
    (*n_6) = (vec3<f32>(0) - (*n_6));
    return true;
}

fn impactor_point_0( _S79 : u32) -> WorldPoint_0
{
    var wi_0 : WorldPoint_0;
    wi_0.hi_0 = impactors_0[_S79].position_1.xyz;
    wi_0.lo_0 = impactors_0[_S79].position_err_1.xyz;
    wi_0.rel_0 = vec3<f32>(0.0f);
    return wi_0;
}

fn impactor_box_1( _S80 : u32,  _S81 : vec3<f32>,  _S82 : vec3<f32>) -> Box_0
{
    var q_9 : Quat_0 = quat_of_0(impactors_0[_S80].rotation_1);
    var b_20 : Box_0;
    b_20.center_1 = _S81;
    b_20.axis0_0 = rotate_0(q_9, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_20.axis1_0 = rotate_0(q_9, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_20.axis2_0 = rotate_0(q_9, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_20.half_2 = _S82;
    b_20.hull_at_0 = u32(0);
    b_20.hull_v_0 = u32(0);
    b_20.hull_f_0 = u32(0);
    return b_20;
}

fn impactor_shrunk_0( _S83 : u32,  _S84 : f32,  _S85 : Box_0) -> Box_0
{
    var shrunk_2 : Box_0 = _S85;
    shrunk_2.half_2 = _S85.half_2 - min(vec3<f32>(_S84), _S85.half_2 * vec3<f32>(0.5f));
    return shrunk_2;
}

fn impactor_contact_2( _S86 : u32,  _S87 : f32,  _S88 : Box_0,  _S89 : Box_0,  _S90 : u32,  _S91 : ptr<function, vec3<f32>>,  _S92 : ptr<function, vec3<f32>>,  _S93 : ptr<function, f32>) -> bool
{
    var _S94 : Impactor_std430_0 = impactors_0[_S86];
    var _S95 : vec3<f32> = vec3<f32>(0.0f);
    (*_S91) = _S95;
    (*_S92) = _S95;
    (*_S93) = 0.0f;
    if((_S94.shape_0.x) == 0.0f)
    {
        var _S96 : bool = sphere_contact_0(_S89, _S95, _S94.shape_0.y - _S87, &((*_S91)), &((*_S92)), &((*_S93)));
        if(!_S96)
        {
            return false;
        }
        (*_S92) = (vec3<f32>(0) - (*_S92));
        return true;
    }
    var cb_3 : u32 = sample_count_0(_S89);
    if(_S90 < cb_3)
    {
        var _S97 : vec3<f32> = sample_point_0(_S89, _S90);
        (*_S91) = _S97;
        var _S98 : bool = penetration_0(_S88, _S97, &((*_S93)), &((*_S92)));
        return _S98;
    }
    var _S99 : vec3<f32> = sample_point_0(_S88, _S90 - cb_3);
    (*_S91) = _S99;
    var _S100 : bool = penetration_0(_S89, _S99, &((*_S93)), &((*_S92)));
    if(!_S100)
    {
        return false;
    }
    (*_S92) = (vec3<f32>(0) - (*_S92));
    return true;
}

fn impactor_contact_count_0( _S101 : u32,  _S102 : f32,  _S103 : Box_0,  _S104 : Box_0) -> u32
{
    var _S105 : Impactor_std430_0 = impactors_0[_S101];
    var j_2 : u32 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        var _S106 : u32 = impactor_slots_0(&(_S105), _S104);
        if(j_2 < _S106)
        {
        }
        else
        {
            break;
        }
        var p_7 : vec3<f32>;
        var n_7 : vec3<f32>;
        var d_14 : f32;
        if(impactor_contact_2(_S101, _S102, _S103, _S104, j_2, &(p_7), &(n_7), &(d_14)))
        {
            count_1 = count_1 + u32(1);
        }
        j_2 = j_2 + u32(1);
    }
    return count_1;
}

fn impactor_candidate_forces_0( k_7 : u32)
{
    var _S107 : u32 = u32(3) * k_7;
    var at_1 : u32 = params_0.cand_index_0 + _S107;
    var c_5 : u32 = index_0[at_1];
    var slot_0 : u32 = index_0[at_1 + u32(1)];
    var _S108 : u32 = index_0[at_1 + u32(2)];
    var _S109 : Impactor_std430_0 = impactors_0[_S108];
    var _S110 : f32 = params_0.dt_0;
    var _S111 : vec3<f32> = vec3<f32>(0.0f);
    var data_1 : vec4<f32> = scratch_0[params_0.cand_base_0 + _S107];
    var f_sum_0 : vec3<f32>;
    var t_sum_0 : vec3<f32>;
    var imp_f_0 : vec3<f32>;
    var imp_t_0 : vec3<f32>;
    if((_S109.cand_0.z) == u32(0))
    {
        var rel_1 : vec3<f32> = world_diff_0(chunk_world_0(c_5), impactor_point_0(_S108));
        var _S112 : vec4<f32> = _S109.half_1;
        if(!((length(rel_1)) > (_S109.half_1.w + chunks_0[c_5].half_0.w)))
        {
            var _S113 : Box_0 = impactor_box_1(_S108, _S111, _S112.xyz);
            var b_21 : Box_0 = chunk_box_0(c_5, rel_1);
            var _S114 : vec4<f32> = _S109.mat_0;
            var kc_0 : f32 = contact_stiffness_0(_S109.mat_0.x, _S113, chunks_0[c_5].cmat_0.x, b_21, b_21.center_1 - _S113.center_1);
            var _S115 : vec4<f32> = _S109.geom_0;
            var _S116 : f32 = _S109.geom_0.y;
            var _S117 : Box_0 = impactor_shrunk_0(_S108, _S116, _S113);
            var _S118 : u32 = impactor_contact_count_0(_S108, _S116, _S117, b_21);
            var _S119 : bool = (_S109.shape_0.x) == 0.0f;
            var _S120 : f32;
            if(_S119)
            {
                _S120 = kc_0;
            }
            else
            {
                _S120 = kc_0 / max(f32(_S118), 10.0f);
            }
            var _S121 : u32;
            if(_S119)
            {
                _S121 = u32(1);
            }
            else
            {
                _S121 = _S118;
            }
            var m_1 : f32 = chunks_0[c_5].center_0.w;
            var _S122 : f32 = _S114.z;
            var _S123 : f32 = m_1 * _S122 / (m_1 + _S122);
            var _S124 : f32;
            if((params_0.pair_friction_0) >= 0.0f)
            {
                _S124 = params_0.pair_friction_0;
            }
            else
            {
                _S124 = min(_S114.y, chunks_0[c_5].cmat_0.y);
            }
            var _S125 : vec3<f32> = _S109.velocity_1.xyz + _S109.velocity_err_1.xyz;
            var vc_0 : vec3<f32>;
            var wc_0 : vec3<f32>;
            chunk_velocity_0(c_5, &(vc_0), &(wc_0));
            var j_3 : u32 = u32(0);
            f_sum_0 = _S111;
            t_sum_0 = _S111;
            imp_f_0 = _S111;
            imp_t_0 = _S111;
            loop
            {
                var _S126 : bool;
                if(_S118 > u32(0))
                {
                    var _S127 : u32 = impactor_slots_1(&(_S109), b_21);
                    _S126 = j_3 < _S127;
                }
                else
                {
                    _S126 = false;
                }
                if(_S126)
                {
                }
                else
                {
                    break;
                }
                var p_8 : vec3<f32>;
                var nrm_0 : vec3<f32>;
                var dep_0 : f32;
                var _S128 : bool = impactor_contact_0(&(_S109), _S116, _S117, b_21, j_3, &(p_8), &(nrm_0), &(dep_0));
                if(!_S128)
                {
                    j_3 = j_3 + u32(1);
                    continue;
                }
                var stored_3 : f32;
                var diss_1 : f32;
                var f_2 : vec3<f32> = penalty_force_0(_S120, _S123, _S124, dep_0 * _S115.x, nrm_0, vc_0 + cross(wc_0, p_8 - b_21.center_1) - (_S125 + cross(_S109.angular_velocity_1.xyz, p_8)), _S110, _S121, &(stored_3), &(diss_1));
                var f_sum_1 : vec3<f32> = f_sum_0 + f_2;
                var t_sum_1 : vec3<f32> = t_sum_0 + cross(p_8 - b_21.center_1, f_2);
                var imp_f_1 : vec3<f32> = imp_f_0 - f_2;
                var imp_t_1 : vec3<f32> = imp_t_0 - cross(p_8, f_2);
                var _S129 : f32 = data_1[i32(2)];
                var _S130 : f32 = data_1[i32(3)];
                comp_add1_1(&(_S129), &(_S130), diss_1);
                data_1[i32(2)] = _S129;
                data_1[i32(3)] = _S130;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_3 = j_3 + u32(1);
            }
        }
        else
        {
            f_sum_0 = _S111;
            t_sum_0 = _S111;
            imp_f_0 = _S111;
            imp_t_0 = _S111;
        }
    }
    else
    {
        f_sum_0 = _S111;
        t_sum_0 = _S111;
        imp_f_0 = _S111;
        imp_t_0 = _S111;
    }
    var _S131 : u32 = u32(2) * slot_0;
    scratch_0[params_0.slot_base_0 + _S131] = vec4<f32>(f_sum_0, 0.0f);
    scratch_0[params_0.slot_base_0 + _S131 + u32(1)] = vec4<f32>(t_sum_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S107] = data_1;
    scratch_0[params_0.cand_base_0 + _S107 + u32(1)] = vec4<f32>(imp_f_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S107 + u32(2)] = vec4<f32>(imp_t_0, 0.0f);
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

@compute
@workgroup_size(64, 1, 1)
fn impactor_shares(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var k_8 : u32 = id_1.x;
    var _S132 : bool;
    if(k_8 >= (params_0.cand_count_0))
    {
        _S132 = true;
    }
    else
    {
        _S132 = stopped_0();
    }
    if(_S132)
    {
        return;
    }
    var _S133 : u32 = u32(3) * k_8;
    var at_2 : u32 = params_0.cand_index_0 + _S133;
    var c_7 : u32 = index_0[at_2];
    var _S134 : u32 = index_0[at_2 + u32(2)];
    var _S135 : Impactor_std430_0 = impactors_0[_S134];
    if((_S135.cand_0.z) == u32(0))
    {
        _S132 = (_S135.crush_0.x) > 0.0f;
    }
    else
    {
        _S132 = false;
    }
    var total_0 : f32;
    var ksum_0 : f32;
    if(_S132)
    {
        var rel_2 : vec3<f32> = world_diff_0(chunk_world_0(c_7), impactor_point_0(_S134));
        var _S136 : vec4<f32> = _S135.half_1;
        if(!((length(rel_2)) > (_S135.half_1.w + chunks_0[c_7].half_0.w)))
        {
            var _S137 : Box_0 = impactor_box_1(_S134, vec3<f32>(0.0f), _S136.xyz);
            var b_22 : Box_0 = chunk_box_0(c_7, rel_2);
            var kc_1 : f32 = contact_stiffness_0(_S135.mat_0.x, _S137, chunks_0[c_7].cmat_0.x, b_22, b_22.center_1 - _S137.center_1);
            var _S138 : f32 = _S135.crush_0.w;
            var _S139 : Box_0 = impactor_shrunk_0(_S134, _S138, _S137);
            var _S140 : u32 = impactor_contact_count_0(_S134, _S138, _S139, b_22);
            var _S141 : f32;
            if((_S135.shape_0.x) == 0.0f)
            {
                _S141 = kc_1;
            }
            else
            {
                _S141 = kc_1 / max(f32(_S140), 10.0f);
            }
            var j_4 : u32 = u32(0);
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            loop
            {
                if(_S140 > u32(0))
                {
                    var _S142 : u32 = impactor_slots_2(&(_S135), b_22);
                    _S132 = j_4 < _S142;
                }
                else
                {
                    _S132 = false;
                }
                if(_S132)
                {
                }
                else
                {
                    break;
                }
                var p_9 : vec3<f32>;
                var nrm_1 : vec3<f32>;
                var dep_1 : f32;
                var _S143 : bool = impactor_contact_1(&(_S135), _S138, _S139, b_22, j_4, &(p_9), &(nrm_1), &(dep_1));
                if(!_S143)
                {
                    j_4 = j_4 + u32(1);
                    continue;
                }
                var ksum_1 : f32 = ksum_0 + _S141;
                total_0 = total_0 + _S141 * dep_1;
                ksum_0 = ksum_1;
                j_4 = j_4 + u32(1);
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
    scratch_0[params_0.cand_base_0 + _S133] = vec4<f32>(total_0, ksum_0, scratch_0[params_0.cand_base_0 + _S133].z, scratch_0[params_0.cand_base_0 + _S133].w);
    return;
}

var<workgroup> g_red_a_0 : array<vec4<f32>, i32(256)>;

var<workgroup> g_red_b_0 : array<vec4<f32>, i32(256)>;

fn group_sum2_0( tid_0 : u32,  a_4 : ptr<function, vec4<f32>>,  b_23 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_0] = (*a_4);
    g_red_b_0[tid_0] = (*b_23);
    workgroupBarrier();
    var s_1 : u32 = u32(128);
    loop
    {
        if(s_1 > u32(0))
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_1)
        {
            var _S144 : u32 = tid_0 + s_1;
            g_red_a_0[tid_0] = g_red_a_0[tid_0] + g_red_a_0[_S144];
            g_red_b_0[tid_0] = g_red_b_0[tid_0] + g_red_b_0[_S144];
        }
        workgroupBarrier();
        s_1 = (s_1 >> (u32(1)));
    }
    (*a_4) = g_red_a_0[i32(0)];
    (*b_23) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_crush(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var ii_0 : u32 = group_0.x;
    var tid_1 : u32 = thread_0.x;
    var _S145 : bool;
    if(ii_0 >= (params_0.impactor_count_0))
    {
        _S145 = true;
    }
    else
    {
        _S145 = stopped_0();
    }
    if(_S145)
    {
        return;
    }
    var imp_6 : Impactor_0;
    imp_6.position_1 = impactors_0[ii_0].position_1;
    imp_6.position_err_1 = impactors_0[ii_0].position_err_1;
    imp_6.velocity_1 = impactors_0[ii_0].velocity_1;
    imp_6.velocity_err_1 = impactors_0[ii_0].velocity_err_1;
    imp_6.angular_velocity_1 = impactors_0[ii_0].angular_velocity_1;
    imp_6.rotation_1 = impactors_0[ii_0].rotation_1;
    imp_6.inertia0_2 = impactors_0[ii_0].inertia0_2;
    imp_6.inertia1_2 = impactors_0[ii_0].inertia1_2;
    imp_6.inertia2_2 = impactors_0[ii_0].inertia2_2;
    imp_6.inv0_2 = impactors_0[ii_0].inv0_2;
    imp_6.inv1_2 = impactors_0[ii_0].inv1_2;
    imp_6.inv2_2 = impactors_0[ii_0].inv2_2;
    imp_6.shape_0 = impactors_0[ii_0].shape_0;
    imp_6.half_1 = impactors_0[ii_0].half_1;
    imp_6.mat_0 = impactors_0[ii_0].mat_0;
    imp_6.crush_0 = impactors_0[ii_0].crush_0;
    imp_6.geom_0 = impactors_0[ii_0].geom_0;
    imp_6.unused_0 = impactors_0[ii_0].unused_0;
    imp_6.ledger_0 = impactors_0[ii_0].ledger_0;
    imp_6.cand_0 = impactors_0[ii_0].cand_0;
    var _S146 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S146;
    var unused_1 : vec4<f32> = _S146;
    var k_9 : u32 = imp_6.cand_0.x + tid_1;
    loop
    {
        if(k_9 < (imp_6.cand_0.y))
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
        _S145 = true;
    }
    else
    {
        _S145 = (imp_6.cand_0.z) != u32(0);
    }
    if(_S145)
    {
        return;
    }
    imp_6.geom_0 = vec4<f32>(1.0f, imp_6.crush_0.w, 0.0f, 0.0f);
    var total_1 : f32 = shares_0.x;
    if((imp_6.crush_0.x) > 0.0f)
    {
        _S145 = (imp_6.crush_0.z) < (imp_6.crush_0.y);
    }
    else
    {
        _S145 = false;
    }
    if(_S145)
    {
        _S145 = total_1 > (imp_6.crush_0.x);
    }
    else
    {
        _S145 = false;
    }
    if(_S145)
    {
        var extra_0 : f32 = (total_1 - imp_6.crush_0.x) / shares_0.y;
        imp_6.crush_0[i32(3)] = imp_6.crush_0[i32(3)] + extra_0;
        imp_6.crush_0[i32(2)] = imp_6.crush_0[i32(2)] + imp_6.crush_0.x * extra_0;
        var _S147 : f32 = imp_6.crush_0.x * extra_0;
        var _S148 : f32 = imp_6.ledger_0[i32(2)];
        var _S149 : f32 = imp_6.ledger_0[i32(3)];
        comp_add1_2(&(_S148), &(_S149), _S147);
        imp_6.ledger_0[i32(2)] = _S148;
        imp_6.ledger_0[i32(3)] = _S149;
        var _S150 : f32 = imp_6.crush_0.x * extra_0;
        var _S151 : f32 = imp_6.ledger_0[i32(0)];
        var _S152 : f32 = imp_6.ledger_0[i32(1)];
        comp_add1_2(&(_S151), &(_S152), _S150);
        imp_6.ledger_0[i32(0)] = _S151;
        imp_6.ledger_0[i32(1)] = _S152;
        imp_6.geom_0[i32(0)] = imp_6.crush_0.x / total_1;
    }
    impactors_0[ii_0].position_1 = imp_6.position_1;
    impactors_0[ii_0].position_err_1 = imp_6.position_err_1;
    impactors_0[ii_0].velocity_1 = imp_6.velocity_1;
    impactors_0[ii_0].velocity_err_1 = imp_6.velocity_err_1;
    impactors_0[ii_0].angular_velocity_1 = imp_6.angular_velocity_1;
    impactors_0[ii_0].rotation_1 = imp_6.rotation_1;
    impactors_0[ii_0].inertia0_2 = imp_6.inertia0_2;
    impactors_0[ii_0].inertia1_2 = imp_6.inertia1_2;
    impactors_0[ii_0].inertia2_2 = imp_6.inertia2_2;
    impactors_0[ii_0].inv0_2 = imp_6.inv0_2;
    impactors_0[ii_0].inv1_2 = imp_6.inv1_2;
    impactors_0[ii_0].inv2_2 = imp_6.inv2_2;
    impactors_0[ii_0].shape_0 = imp_6.shape_0;
    impactors_0[ii_0].half_1 = imp_6.half_1;
    impactors_0[ii_0].mat_0 = imp_6.mat_0;
    impactors_0[ii_0].crush_0 = imp_6.crush_0;
    impactors_0[ii_0].geom_0 = imp_6.geom_0;
    impactors_0[ii_0].unused_0 = imp_6.unused_0;
    impactors_0[ii_0].ledger_0 = imp_6.ledger_0;
    impactors_0[ii_0].cand_0 = imp_6.cand_0;
    return;
}

fn comp_add_0( sum_3 : ptr<function, vec3<f32>>,  err_3 : ptr<function, vec3<f32>>,  x_5 : vec3<f32>)
{
    var t_4 : vec3<f32> = (*sum_3) + x_5;
    var _S153 : vec3<f32> = abs(x_5);
    (*err_3) = (*err_3) + (select(x_5, (*sum_3), (abs((*sum_3))) >= _S153) - t_4 + select((*sum_3), x_5, (abs((*sum_3))) >= _S153));
    (*sum_3) = t_4;
    return;
}

fn inverse_rotate_0( q_10 : Quat_0,  v_5 : vec3<f32>) -> vec3<f32>
{
    var c_8 : Quat_0;
    c_8.w_0 = q_10.w_0;
    c_8.x_0 = - q_10.x_0;
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
    var r_5 : Quat_0;
    r_5.w_0 = a_5.w_0 * o_0.w_0 - a_5.x_0 * o_0.x_0 - a_5.y_0 * o_0.y_0 - a_5.z_0 * o_0.z_0;
    r_5.x_0 = a_5.w_0 * o_0.x_0 + a_5.x_0 * o_0.w_0 + a_5.y_0 * o_0.z_0 - a_5.z_0 * o_0.y_0;
    r_5.y_0 = a_5.w_0 * o_0.y_0 - a_5.x_0 * o_0.z_0 + a_5.y_0 * o_0.w_0 + a_5.z_0 * o_0.x_0;
    r_5.z_0 = a_5.w_0 * o_0.z_0 + a_5.x_0 * o_0.y_0 - a_5.y_0 * o_0.x_0 + a_5.z_0 * o_0.w_0;
    return r_5;
}

fn normalized_0( q_12 : Quat_0) -> Quat_0
{
    var _S154 : f32 = q_12.w_0;
    var _S155 : f32 = q_12.x_0;
    var _S156 : f32 = q_12.y_0;
    var _S157 : f32 = q_12.z_0;
    var n_8 : f32 = sqrt(_S154 * _S154 + _S155 * _S155 + _S156 * _S156 + _S157 * _S157);
    var r_6 : Quat_0;
    r_6.w_0 = q_12.w_0 / n_8;
    r_6.x_0 = q_12.x_0 / n_8;
    r_6.y_0 = q_12.y_0 / n_8;
    r_6.z_0 = q_12.z_0 / n_8;
    return r_6;
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
    return vec4<f32>(q_14.x_0, q_14.y_0, q_14.z_0, q_14.w_0);
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_integrate(@builtin(workgroup_id) group_1 : vec3<u32>, @builtin(local_invocation_id) thread_1 : vec3<u32>)
{
    var p_10 : vec3<f32>;
    var ii_1 : u32 = group_1.x;
    var tid_2 : u32 = thread_1.x;
    if(ii_1 >= (params_0.impactor_count_0))
    {
        return;
    }
    var imp_7 : Impactor_0;
    imp_7.position_1 = impactors_0[ii_1].position_1;
    imp_7.position_err_1 = impactors_0[ii_1].position_err_1;
    imp_7.velocity_1 = impactors_0[ii_1].velocity_1;
    imp_7.velocity_err_1 = impactors_0[ii_1].velocity_err_1;
    imp_7.angular_velocity_1 = impactors_0[ii_1].angular_velocity_1;
    imp_7.rotation_1 = impactors_0[ii_1].rotation_1;
    imp_7.inertia0_2 = impactors_0[ii_1].inertia0_2;
    imp_7.inertia1_2 = impactors_0[ii_1].inertia1_2;
    imp_7.inertia2_2 = impactors_0[ii_1].inertia2_2;
    imp_7.inv0_2 = impactors_0[ii_1].inv0_2;
    imp_7.inv1_2 = impactors_0[ii_1].inv1_2;
    imp_7.inv2_2 = impactors_0[ii_1].inv2_2;
    imp_7.shape_0 = impactors_0[ii_1].shape_0;
    imp_7.half_1 = impactors_0[ii_1].half_1;
    imp_7.mat_0 = impactors_0[ii_1].mat_0;
    imp_7.crush_0 = impactors_0[ii_1].crush_0;
    imp_7.geom_0 = impactors_0[ii_1].geom_0;
    imp_7.unused_0 = impactors_0[ii_1].unused_0;
    imp_7.ledger_0 = impactors_0[ii_1].ledger_0;
    imp_7.cand_0 = impactors_0[ii_1].cand_0;
    var _S158 : bool;
    if((imp_7.cand_0.z) != u32(0))
    {
        _S158 = true;
    }
    else
    {
        _S158 = (((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0);
    }
    if(_S158)
    {
        _S158 = true;
    }
    else
    {
        var _S159 : u32 = islands_0[params_0.halt_index_0].info_0.y;
        if(_S159 != u32(0))
        {
            _S158 = (imp_7.cand_0.w) >= _S159;
        }
        else
        {
            _S158 = false;
        }
    }
    if(_S158)
    {
        return;
    }
    var _S160 : vec4<f32> = vec4<f32>(0.0f);
    var rf_0 : vec4<f32> = _S160;
    var rt_0 : vec4<f32> = _S160;
    var k_10 : u32 = imp_7.cand_0.x + tid_2;
    loop
    {
        if(k_10 < (imp_7.cand_0.y))
        {
        }
        else
        {
            break;
        }
        var _S161 : u32 = u32(3) * k_10;
        rf_0 = rf_0 + scratch_0[params_0.cand_base_0 + _S161 + u32(1)];
        rt_0 = rt_0 + scratch_0[params_0.cand_base_0 + _S161 + u32(2)];
        k_10 = k_10 + u32(256);
    }
    group_sum2_0(tid_2, &(rf_0), &(rt_0));
    if(tid_2 != u32(0))
    {
        return;
    }
    var dt_4 : f32 = params_0.dt_0;
    var _S162 : vec3<f32> = vec3<f32>(0.0f);
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((params_0.has_ground_0) != u32(0))
    {
        var ib_0 : Box_0 = impactor_box_0(imp_7, _S162, imp_7.half_1.xyz);
        var _S163 : vec3<f32> = imp_7.velocity_1.xyz + imp_7.velocity_err_1.xyz;
        const _S164 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var kc_2 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_7.mat_0.x, ib_0, _S164);
        var _S165 : f32 = imp_7.position_1.z - params_0.ground_hi_0 + (imp_7.position_err_1.z - params_0.ground_lo_0);
        var total_points_0 : u32;
        if((imp_7.shape_0.x) == 0.0f)
        {
            total_points_0 = u32(1);
        }
        else
        {
            total_points_0 = u32(14);
        }
        var _S166 : f32 = kc_2 / f32(min(total_points_0, u32(5)));
        var s_2 : u32 = u32(0);
        var below_0 : u32 = u32(0);
        loop
        {
            if(s_2 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if((imp_7.shape_0.x) == 0.0f)
            {
                p_10 = vec3<f32>(0.0f, 0.0f, - imp_7.shape_0.y);
            }
            else
            {
                p_10 = sample_point_0(ib_0, s_2);
            }
            if((_S165 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + u32(1);
            }
            s_2 = s_2 + u32(1);
        }
        s_2 = u32(0);
        load_f_0 = _S162;
        load_t_0 = _S162;
        loop
        {
            if(s_2 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if((imp_7.shape_0.x) == 0.0f)
            {
                p_10 = vec3<f32>(0.0f, 0.0f, - imp_7.shape_0.y);
            }
            else
            {
                p_10 = sample_point_0(ib_0, s_2);
            }
            var depth_5 : f32 = - (_S165 + p_10.z);
            if(depth_5 <= 0.0f)
            {
                s_2 = s_2 + u32(1);
                continue;
            }
            var stored_4 : f32;
            var diss_2 : f32;
            var f_3 : vec3<f32> = penalty_force_1(_S166, imp_7.mat_0.z, params_0.ground_friction_0, depth_5, _S164, _S163 + cross(imp_7.angular_velocity_1.xyz, p_10), dt_4, below_0, &(stored_4), &(diss_2));
            var load_f_1 : vec3<f32> = load_f_0 + f_3;
            var load_t_1 : vec3<f32> = load_t_0 + cross(p_10, f_3);
            var _S167 : f32 = imp_7.ledger_0[i32(0)];
            var _S168 : f32 = imp_7.ledger_0[i32(1)];
            comp_add1_2(&(_S167), &(_S168), diss_2);
            imp_7.ledger_0[i32(0)] = _S167;
            imp_7.ledger_0[i32(1)] = _S168;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_2 = s_2 + u32(1);
        }
    }
    else
    {
        load_f_0 = _S162;
        load_t_0 = _S162;
    }
    var load_f_2 : vec3<f32> = rf_0.xyz + load_f_0;
    var load_t_2 : vec3<f32> = rt_0.xyz + load_t_0;
    var m_2 : f32 = imp_7.mat_0.z;
    var vel_0 : vec3<f32> = imp_7.velocity_1.xyz;
    var vel_err_0 : vec3<f32> = imp_7.velocity_err_1.xyz;
    var _S169 : vec3<f32> = vec3<f32>(dt_4);
    comp_add_0(&(vel_0), &(vel_err_0), (load_f_2 / vec3<f32>(m_2) + params_0.gravity_0.xyz) * _S169);
    var q_15 : Quat_0 = quat_of_0(imp_7.rotation_1);
    var l_1 : vec3<f32> = world_mul_0(q_15, imp_7.inertia0_2, imp_7.inertia1_2, imp_7.inertia2_2, imp_7.angular_velocity_1.xyz) + load_t_2 * _S169;
    var w_mid_0 : vec3<f32> = world_mul_0(q_15, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_1);
    var pos_0 : vec3<f32> = imp_7.position_1.xyz;
    var pos_err_0 : vec3<f32> = imp_7.position_err_1.xyz;
    comp_add_0(&(pos_0), &(pos_err_0), (vel_0 + vel_err_0) * _S169);
    var q_16 : Quat_0 = integrate_rotation_0(q_15, w_mid_0, dt_4);
    imp_7.angular_velocity_1 = vec4<f32>(world_mul_0(q_16, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_1), 0.0f);
    imp_7.rotation_1 = quat_vec_0(q_16);
    imp_7.position_1 = vec4<f32>(pos_0, 0.0f);
    imp_7.position_err_1 = vec4<f32>(pos_err_0, 0.0f);
    imp_7.velocity_1 = vec4<f32>(vel_0, 0.0f);
    imp_7.velocity_err_1 = vec4<f32>(vel_err_0, 0.0f);
    imp_7.cand_0[i32(3)] = imp_7.cand_0[i32(3)] + u32(1);
    imp_7.geom_0 = vec4<f32>(1.0f, imp_7.crush_0.w, 0.0f, 0.0f);
    impactors_0[ii_1].position_1 = imp_7.position_1;
    impactors_0[ii_1].position_err_1 = imp_7.position_err_1;
    impactors_0[ii_1].velocity_1 = imp_7.velocity_1;
    impactors_0[ii_1].velocity_err_1 = imp_7.velocity_err_1;
    impactors_0[ii_1].angular_velocity_1 = imp_7.angular_velocity_1;
    impactors_0[ii_1].rotation_1 = imp_7.rotation_1;
    impactors_0[ii_1].inertia0_2 = imp_7.inertia0_2;
    impactors_0[ii_1].inertia1_2 = imp_7.inertia1_2;
    impactors_0[ii_1].inertia2_2 = imp_7.inertia2_2;
    impactors_0[ii_1].inv0_2 = imp_7.inv0_2;
    impactors_0[ii_1].inv1_2 = imp_7.inv1_2;
    impactors_0[ii_1].inv2_2 = imp_7.inv2_2;
    impactors_0[ii_1].shape_0 = imp_7.shape_0;
    impactors_0[ii_1].half_1 = imp_7.half_1;
    impactors_0[ii_1].mat_0 = imp_7.mat_0;
    impactors_0[ii_1].crush_0 = imp_7.crush_0;
    impactors_0[ii_1].geom_0 = imp_7.geom_0;
    impactors_0[ii_1].unused_0 = imp_7.unused_0;
    impactors_0[ii_1].ledger_0 = imp_7.ledger_0;
    impactors_0[ii_1].cand_0 = imp_7.cand_0;
    var k_11 : u32 = imp_7.cand_0.w - u32(1) - params_0.step_start_0;
    if(k_11 < (params_0.record_stride_0))
    {
        var at_3 : u32 = params_0.record_base_0 + u32(2) * (ii_1 * params_0.record_stride_0 + k_11);
        scratch_0[at_3] = vec4<f32>(vel_0 + vel_err_0, 0.0f);
        scratch_0[at_3 + u32(1)] = vec4<f32>(pos_0 + pos_err_0, 0.0f);
    }
    return;
}

fn ground_contact_0( c_9 : u32,  account_0 : bool,  f_4 : ptr<function, vec3<f32>>,  t_5 : ptr<function, vec3<f32>>)
{
    var wp_1 : WorldPoint_0 = chunk_world_0(c_9);
    var above_0 : f32 = wp_1.hi_0.z - params_0.ground_hi_0 + (wp_1.lo_0.z - params_0.ground_lo_0) + wp_1.rel_0.z;
    if((above_0 - chunks_0[c_9].half_0.w) > 0.0f)
    {
        return;
    }
    var b_24 : Box_0 = chunk_box_0(c_9, vec3<f32>(0.0f));
    const _S170 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S171 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_24, chunks_0[c_9].cmat_0.x, b_24, _S170);
    var _S172 : u32 = sample_count_0(b_24);
    var s_3 : u32 = u32(0);
    var n_9 : u32 = u32(0);
    loop
    {
        if(s_3 < _S172)
        {
        }
        else
        {
            break;
        }
        if((above_0 + sample_point_0(b_24, s_3).z) < 0.0f)
        {
            n_9 = n_9 + u32(1);
        }
        s_3 = s_3 + u32(1);
    }
    if(n_9 == u32(0))
    {
        return;
    }
    var vc_1 : vec3<f32>;
    var wc_1 : vec3<f32>;
    chunk_velocity_1(c_9, &(vc_1), &(wc_1));
    var ledger_2 : vec4<f32> = scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_9];
    s_3 = u32(0);
    loop
    {
        if(s_3 < _S172)
        {
        }
        else
        {
            break;
        }
        var p_11 : vec3<f32> = sample_point_0(b_24, s_3);
        var _S173 : f32 = above_0 + p_11.z;
        if(!(_S173 < 0.0f))
        {
            s_3 = s_3 + u32(1);
            continue;
        }
        var stored_5 : f32;
        var diss_3 : f32;
        var g_0 : vec3<f32> = penalty_force_1(_S171 / f32(max(n_9, u32(5))), chunks_0[c_9].center_0.w, params_0.ground_friction_0, - _S173, _S170, vc_1 + cross(wc_1, p_11), params_0.dt_0, n_9, &(stored_5), &(diss_3));
        (*f_4) = (*f_4) + g_0;
        (*t_5) = (*t_5) + cross(p_11, g_0);
        var _S174 : f32 = ledger_2[i32(1)];
        var _S175 : f32 = ledger_2[i32(2)];
        comp_add1_2(&(_S174), &(_S175), diss_3);
        ledger_2[i32(1)] = _S174;
        ledger_2[i32(2)] = _S175;
        s_3 = s_3 + u32(1);
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
    var _S176 : bool;
    if(g_1 >= (params_0.seg_count_0))
    {
        _S176 = true;
    }
    else
    {
        _S176 = stopped_0();
    }
    if(_S176)
    {
        return;
    }
    var _S177 : u32 = u32(3) * g_1;
    var _S178 : u32 = index_0[params_0.seg_index_0 + _S177];
    var begin_0 : u32 = index_0[params_0.seg_index_0 + _S177 + u32(1)];
    var _S179 : u32 = index_0[params_0.seg_index_0 + _S177 + u32(2)];
    var _S180 : vec3<f32> = vec3<f32>(0.0f);
    var f_5 : vec3<f32> = _S180;
    var t_6 : vec3<f32> = _S180;
    var e_2 : u32 = begin_0;
    loop
    {
        if(e_2 < _S179)
        {
        }
        else
        {
            break;
        }
        var entry_1 : u32 = index_0[e_2];
        if(entry_1 == u32(2147483648))
        {
            ground_contact_0(_S178, true, &(f_5), &(t_6));
            e_2 = e_2 + u32(1);
            continue;
        }
        var _S181 : u32 = u32(2) * entry_1;
        f_5 = f_5 + scratch_0[params_0.slot_base_0 + _S181].xyz;
        t_6 = t_6 + scratch_0[params_0.slot_base_0 + _S181 + u32(1)].xyz;
        e_2 = e_2 + u32(1);
    }
    var _S182 : u32 = u32(2) * g_1;
    scratch_0[params_0.seg_base_0 + _S182] = vec4<f32>(f_5, 0.0f);
    scratch_0[params_0.seg_base_0 + _S182 + u32(1)] = vec4<f32>(t_6, 0.0f);
    return;
}

fn contact_stopped_0( isl_0 : ptr<function, Island_std430_0>) -> bool
{
    var _S183 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S184 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S184 = true;
    }
    else
    {
        var _S185 : u32 = _S183.y;
        if(_S185 != u32(0))
        {
            _S184 = _S185 <= ((*isl_0).info_0.w);
        }
        else
        {
            _S184 = false;
        }
    }
    return _S184;
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
    var _S186 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S187 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S187 = true;
    }
    else
    {
        var _S188 : u32 = _S186.y;
        if(_S188 != u32(0))
        {
            _S187 = _S188 <= (isl_1.info_0.w);
        }
        else
        {
            _S187 = false;
        }
    }
    return _S187;
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
    var _S189 : vec3<f32> = vec3<f32>(0.0f);
    rg_0.a_6 = _S189;
    rg_0.alpha_0 = _S189;
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
    var _S190 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.a_6 = _S190;
    rg_1.alpha_0 = _S190;
    return rg_1;
}

fn time_since_0( origin_0 : vec4<f32>,  k_12 : u32,  dt_5 : f32) -> f32
{
    return params_0.t_hi_0 - origin_0.x + (params_0.t_lo_0 - origin_0.y) + f32(k_12) * dt_5;
}

fn table_eval_0( offset_0 : u32,  count_2 : u32,  tau_0 : f32) -> f32
{
    var first_0 : vec4<f32> = loads_0[offset_0];
    if(tau_0 <= (first_0.x))
    {
        return first_0.y;
    }
    var i_4 : u32 = u32(1);
    loop
    {
        if(i_4 < count_2)
        {
        }
        else
        {
            break;
        }
        var _S191 : u32 = offset_0 + i_4;
        var b_25 : vec4<f32> = loads_0[_S191];
        var _S192 : f32 = b_25.x;
        if(tau_0 <= _S192)
        {
            var a_7 : vec4<f32> = loads_0[_S191 - u32(1)];
            var _S193 : f32 = a_7.x;
            var _S194 : f32 = a_7.y;
            return _S194 + (tau_0 - _S193) / max(_S192 - _S193, 1.00000000317107685e-30f) * (b_25.y - _S194);
        }
        i_4 = i_4 + u32(1);
    }
    return loads_0[offset_0 + count_2 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_13 : u32,  dt_6 : f32,  shift_0 : f32) -> f32
{
    var _S195 : u32 = u32(5) * term_0;
    var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S195])));
    var origin_1 : vec4<f32> = loads_0[_S195 + u32(3)];
    var p_12 : vec4<f32> = loads_0[_S195 + u32(4)];
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
            var _S196 : f32 = p_12.x;
            if(tau_1 >= _S196)
            {
                shape_1 = p_12.y;
            }
            else
            {
                shape_1 = p_12.y * tau_1 / _S196;
            }
        }
        return shape_1;
    }
    var _S197 : bool;
    if(kind_0 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S197 = true;
        }
        else
        {
            _S197 = tau_1 > (p_12.x);
        }
        if(_S197)
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
            _S197 = true;
        }
        else
        {
            _S197 = sn_0 > 1.0f;
        }
        if(_S197)
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
            _S197 = true;
        }
        else
        {
            _S197 = sn_1 > 1.0f;
        }
        if(_S197)
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
        var _S198 : f32 = p_12.w;
        return (_S198 + (p_12.z - _S198) * relax_0) * shape_1;
    }
    var _S199 : f32 = p_12.x;
    if(_S199 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S199, 0.0f, 1.0f);
}

fn record_chunk_load_0( c_10 : u32,  f_6 : vec3<f32>,  t_7 : vec3<f32>)
{
    if((params_0.solve_mode_0) == u32(0))
    {
        return;
    }
    var _S200 : u32 = u32(2) * c_10;
    scratch_0[params_0.cload_base_0 + _S200] = vec4<f32>(f_6, 0.0f);
    scratch_0[params_0.cload_base_0 + _S200 + u32(1)] = vec4<f32>(t_7, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S200] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S200].xyz + f_6, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S200 + u32(1)] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S200 + u32(1)].xyz + t_7, 0.0f);
    return;
}

fn chunk_external_0( _S201 : u32,  _S202 : u32,  _S203 : Quat_0,  _S204 : u32,  _S205 : f32,  _S206 : bool,  _S207 : ptr<function, vec3<f32>>,  _S208 : ptr<function, vec3<f32>>)
{
    var _S209 : vec3<f32> = vec3<f32>(0.0f);
    (*_S207) = _S209;
    (*_S208) = _S209;
    var _S210 : vec4<u32> = chunks_0[_S202].load_range_0;
    var term_1 : u32 = chunks_0[_S202].load_range_0.x;
    loop
    {
        if(term_1 < (_S210.y))
        {
        }
        else
        {
            break;
        }
        var _S211 : u32 = u32(5) * term_1;
        var _S212 : u32 = (bitcast<vec4<u32>>((loads_0[_S211]))).y;
        if(_S212 == u32(2))
        {
            term_1 = term_1 + u32(1);
            continue;
        }
        var dir_1 : vec4<f32> = loads_0[_S211 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S211 + u32(2)];
        var value_0 : f32 = eval_function_0(term_1, _S204, _S205, 0.0f);
        var fw_0 : vec3<f32>;
        if(_S212 == u32(0))
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_0);
        }
        else
        {
            fw_0 = rotate_0(_S203, dir_1.xyz) * vec3<f32>((- value_0 * dir_1.w));
        }
        (*_S207) = (*_S207) + fw_0;
        (*_S208) = (*_S208) + cross(rotate_0(_S203, arm_0.xyz), fw_0);
        term_1 = term_1 + u32(1);
    }
    var _S213 : bool;
    if(_S206)
    {
        _S213 = (chunks_0[_S202].cinfo_0.z) != u32(0);
    }
    else
    {
        _S213 = false;
    }
    if(_S213)
    {
        var _S214 : vec4<u32> = chunks_0[_S202].cinfo_0;
        var g_2 : u32 = chunks_0[_S202].cinfo_0.x;
        loop
        {
            if(g_2 < (_S214.y))
            {
            }
            else
            {
                break;
            }
            var _S215 : u32 = u32(2) * g_2;
            (*_S207) = (*_S207) + scratch_0[params_0.seg_base_0 + _S215].xyz;
            (*_S208) = (*_S208) + scratch_0[params_0.seg_base_0 + _S215 + u32(1)].xyz;
            g_2 = g_2 + u32(1);
        }
    }
    return;
}

fn settled_chunk_load_0( c_11 : u32,  rot_1 : Quat_0,  k_14 : u32,  dt_7 : f32,  contact_0 : bool) -> f32
{
    var f_7 : vec3<f32>;
    var t_8 : vec3<f32>;
    chunk_external_0(c_11, c_11, rot_1, k_14, dt_7, contact_0, &(f_7), &(t_8));
    record_chunk_load_0(c_11, f_7, t_8);
    return length(f_7);
}

fn group_sum3_0( tid_3 : u32,  a_8 : ptr<function, vec3<f32>>,  b_26 : ptr<function, vec3<f32>>)
{
    var x_6 : vec4<f32> = vec4<f32>((*a_8), 0.0f);
    var y_1 : vec4<f32> = vec4<f32>((*b_26), 0.0f);
    group_sum2_0(tid_3, &(x_6), &(y_1));
    (*a_8) = x_6.xyz;
    (*b_26) = y_1.xyz;
    return;
}

fn chunk_external_1( _S216 : u32,  _S217 : u32,  _S218 : Quat_0,  _S219 : u32,  _S220 : f32,  _S221 : bool,  _S222 : ptr<function, vec3<f32>>,  _S223 : ptr<function, vec3<f32>>)
{
    var _S224 : vec3<f32> = vec3<f32>(0.0f);
    (*_S222) = _S224;
    (*_S223) = _S224;
    var _S225 : vec4<u32> = chunks_0[_S217].load_range_0;
    var term_2 : u32 = chunks_0[_S217].load_range_0.x;
    loop
    {
        if(term_2 < (_S225.y))
        {
        }
        else
        {
            break;
        }
        var _S226 : u32 = u32(5) * term_2;
        var _S227 : u32 = (bitcast<vec4<u32>>((loads_0[_S226]))).y;
        if(_S227 == u32(2))
        {
            term_2 = term_2 + u32(1);
            continue;
        }
        var dir_2 : vec4<f32> = loads_0[_S226 + u32(1)];
        var arm_1 : vec4<f32> = loads_0[_S226 + u32(2)];
        var value_1 : f32 = eval_function_0(term_2, _S219, _S220, 0.0f);
        var fw_1 : vec3<f32>;
        if(_S227 == u32(0))
        {
            fw_1 = dir_2.xyz * vec3<f32>(value_1);
        }
        else
        {
            fw_1 = rotate_0(_S218, dir_2.xyz) * vec3<f32>((- value_1 * dir_2.w));
        }
        (*_S222) = (*_S222) + fw_1;
        (*_S223) = (*_S223) + cross(rotate_0(_S218, arm_1.xyz), fw_1);
        term_2 = term_2 + u32(1);
    }
    var _S228 : bool;
    if(_S221)
    {
        _S228 = (chunks_0[_S217].cinfo_0.z) != u32(0);
    }
    else
    {
        _S228 = false;
    }
    if(_S228)
    {
        var _S229 : vec4<u32> = chunks_0[_S217].cinfo_0;
        var g_3 : u32 = chunks_0[_S217].cinfo_0.x;
        loop
        {
            if(g_3 < (_S229.y))
            {
            }
            else
            {
                break;
            }
            var _S230 : u32 = u32(2) * g_3;
            (*_S222) = (*_S222) + scratch_0[params_0.seg_base_0 + _S230].xyz;
            (*_S223) = (*_S223) + scratch_0[params_0.seg_base_0 + _S230 + u32(1)].xyz;
            g_3 = g_3 + u32(1);
        }
    }
    return;
}

fn net_load_0( c_12 : u32,  isl_4 : ptr<function, Island_std430_0>,  rg_2 : Rigid_0,  k_15 : u32,  dt_8 : f32,  contact_1 : bool,  f_8 : ptr<function, vec3<f32>>,  t_9 : ptr<function, vec3<f32>>)
{
    var fl_0 : vec3<f32>;
    var tl_0 : vec3<f32>;
    chunk_external_1(c_12, c_12, rg_2.rot_0, k_15, dt_8, contact_1, &(fl_0), &(tl_0));
    var fc_0 : vec3<f32> = fl_0 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_12].center_0.w);
    var _S231 : vec3<f32> = chunks_0[c_12].center_0.xyz;
    var _S232 : vec3<f32> = (*isl_4).com_0.xyz;
    var r_7 : vec3<f32> = rotate_0(rg_2.rot_0, _S231 + state_0[u32(4) * c_12].xyz - _S232);
    (*f_8) = (*f_8) + fc_0;
    (*t_9) = (*t_9) + (cross(r_7, fc_0) + tl_0);
    var _S233 : vec4<u32> = chunks_0[c_12].load_range_0;
    var term_3 : u32 = chunks_0[c_12].load_range_0.x;
    loop
    {
        if(term_3 < (_S233.y))
        {
        }
        else
        {
            break;
        }
        var _S234 : u32 = u32(5) * term_3;
        if(((bitcast<vec4<u32>>((loads_0[_S234]))).y) != u32(2))
        {
            term_3 = term_3 + u32(1);
            continue;
        }
        var _S235 : vec3<f32> = vec3<f32>(eval_function_0(term_3, k_15, dt_8, 0.0f));
        var fw_2 : vec3<f32> = rotate_0(rg_2.rot_0, loads_0[_S234 + u32(1)].xyz * _S235);
        (*f_8) = (*f_8) + fw_2;
        (*t_9) = (*t_9) + (cross(rotate_0(rg_2.rot_0, _S231 - _S232), fw_2) + rotate_0(rg_2.rot_0, loads_0[_S234 + u32(2)].xyz * _S235));
        term_3 = term_3 + u32(1);
    }
    return;
}

fn net_load_1( c_13 : u32,  isl_5 : Island_0,  rg_3 : Rigid_0,  k_16 : u32,  dt_9 : f32,  contact_2 : bool,  f_9 : ptr<function, vec3<f32>>,  t_10 : ptr<function, vec3<f32>>)
{
    var fl_1 : vec3<f32>;
    var tl_1 : vec3<f32>;
    chunk_external_1(c_13, c_13, rg_3.rot_0, k_16, dt_9, contact_2, &(fl_1), &(tl_1));
    var fc_1 : vec3<f32> = fl_1 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_13].center_0.w);
    var _S236 : vec3<f32> = chunks_0[c_13].center_0.xyz;
    var _S237 : vec3<f32> = isl_5.com_0.xyz;
    var r_8 : vec3<f32> = rotate_0(rg_3.rot_0, _S236 + state_0[u32(4) * c_13].xyz - _S237);
    (*f_9) = (*f_9) + fc_1;
    (*t_10) = (*t_10) + (cross(r_8, fc_1) + tl_1);
    var _S238 : vec4<u32> = chunks_0[c_13].load_range_0;
    var term_4 : u32 = chunks_0[c_13].load_range_0.x;
    loop
    {
        if(term_4 < (_S238.y))
        {
        }
        else
        {
            break;
        }
        var _S239 : u32 = u32(5) * term_4;
        if(((bitcast<vec4<u32>>((loads_0[_S239]))).y) != u32(2))
        {
            term_4 = term_4 + u32(1);
            continue;
        }
        var _S240 : vec3<f32> = vec3<f32>(eval_function_0(term_4, k_16, dt_9, 0.0f));
        var fw_3 : vec3<f32> = rotate_0(rg_3.rot_0, loads_0[_S239 + u32(1)].xyz * _S240);
        (*f_9) = (*f_9) + fw_3;
        (*t_10) = (*t_10) + (cross(rotate_0(rg_3.rot_0, _S236 - _S237), fw_3) + rotate_0(rg_3.rot_0, loads_0[_S239 + u32(2)].xyz * _S240));
        term_4 = term_4 + u32(1);
    }
    return;
}

fn rigid_acceleration_0( isl_6 : ptr<function, Island_std430_0>,  rg_4 : ptr<function, Rigid_0>,  f_10 : vec3<f32>,  t_11 : vec3<f32>)
{
    var iw_w_0 : vec3<f32> = world_mul_0((*rg_4).rot_0, (*isl_6).inertia0_0, (*isl_6).inertia1_0, (*isl_6).inertia2_0, (*rg_4).w_4);
    (*rg_4).a_6 = f_10 / vec3<f32>((*isl_6).com_0.w);
    (*rg_4).alpha_0 = world_mul_0((*rg_4).rot_0, (*isl_6).inv0_0, (*isl_6).inv1_0, (*isl_6).inv2_0, t_11 - cross((*rg_4).w_4, iw_w_0));
    return;
}

fn rigid_acceleration_1( isl_7 : Island_0,  rg_5 : ptr<function, Rigid_0>,  f_11 : vec3<f32>,  t_12 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_5).rot_0, isl_7.inertia0_0, isl_7.inertia1_0, isl_7.inertia2_0, (*rg_5).w_4);
    (*rg_5).a_6 = f_11 / vec3<f32>(isl_7.com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_0, isl_7.inv0_0, isl_7.inv1_0, isl_7.inv2_0, t_12 - cross((*rg_5).w_4, iw_w_1));
    return;
}

fn integrate_rigid_0( isl_8 : ptr<function, Island_std430_0>,  rg_6 : ptr<function, Rigid_0>,  dt_10 : f32)
{
    var iw_w_2 : vec3<f32> = world_mul_0((*rg_6).rot_0, (*isl_8).inertia0_0, (*isl_8).inertia1_0, (*isl_8).inertia2_0, (*rg_6).w_4);
    var _S241 : vec3<f32> = vec3<f32>(dt_10);
    var l_2 : vec3<f32> = iw_w_2 + (world_mul_0((*rg_6).rot_0, (*isl_8).inertia0_0, (*isl_8).inertia1_0, (*isl_8).inertia2_0, (*rg_6).alpha_0) + cross((*rg_6).w_4, iw_w_2)) * _S241;
    var _S242 : vec3<f32> = (*rg_6).a_6 * _S241;
    var _S243 : vec3<f32> = (*rg_6).vel_1;
    var _S244 : vec3<f32> = (*rg_6).vel_err_1;
    comp_add_0(&(_S243), &(_S244), _S242);
    (*rg_6).vel_1 = _S243;
    (*rg_6).vel_err_1 = _S244;
    var _S245 : vec4<f32> = (*isl_8).inv0_0;
    var _S246 : vec4<f32> = (*isl_8).inv1_0;
    var _S247 : vec4<f32> = (*isl_8).inv2_0;
    var rot1_0 : Quat_0 = integrate_rotation_0((*rg_6).rot_0, world_mul_0((*rg_6).rot_0, (*isl_8).inv0_0, (*isl_8).inv1_0, (*isl_8).inv2_0, l_2), dt_10);
    var _S248 : vec3<f32> = (*isl_8).com_0.xyz;
    var delta_0 : vec3<f32> = (_S243 + _S244) * _S241 + (rotate_0((*rg_6).rot_0, _S248) - rotate_0(rot1_0, _S248));
    var _S249 : vec3<f32> = (*rg_6).pos_1;
    var _S250 : vec3<f32> = (*rg_6).pos_err_1;
    comp_add_0(&(_S249), &(_S250), delta_0);
    (*rg_6).pos_1 = _S249;
    (*rg_6).pos_err_1 = _S250;
    (*rg_6).rot_0 = rot1_0;
    (*rg_6).w_4 = world_mul_0(rot1_0, _S245, _S246, _S247, l_2);
    return;
}

fn integrate_rigid_1( isl_9 : Island_0,  rg_7 : ptr<function, Rigid_0>,  dt_11 : f32)
{
    var iw_w_3 : vec3<f32> = world_mul_0((*rg_7).rot_0, isl_9.inertia0_0, isl_9.inertia1_0, isl_9.inertia2_0, (*rg_7).w_4);
    var _S251 : vec3<f32> = vec3<f32>(dt_11);
    var l_3 : vec3<f32> = iw_w_3 + (world_mul_0((*rg_7).rot_0, isl_9.inertia0_0, isl_9.inertia1_0, isl_9.inertia2_0, (*rg_7).alpha_0) + cross((*rg_7).w_4, iw_w_3)) * _S251;
    var _S252 : vec3<f32> = (*rg_7).a_6 * _S251;
    var _S253 : vec3<f32> = (*rg_7).vel_1;
    var _S254 : vec3<f32> = (*rg_7).vel_err_1;
    comp_add_0(&(_S253), &(_S254), _S252);
    (*rg_7).vel_1 = _S253;
    (*rg_7).vel_err_1 = _S254;
    var rot1_1 : Quat_0 = integrate_rotation_0((*rg_7).rot_0, world_mul_0((*rg_7).rot_0, isl_9.inv0_0, isl_9.inv1_0, isl_9.inv2_0, l_3), dt_11);
    var _S255 : vec3<f32> = isl_9.com_0.xyz;
    var delta_1 : vec3<f32> = (_S253 + _S254) * _S251 + (rotate_0((*rg_7).rot_0, _S255) - rotate_0(rot1_1, _S255));
    var _S256 : vec3<f32> = (*rg_7).pos_1;
    var _S257 : vec3<f32> = (*rg_7).pos_err_1;
    comp_add_0(&(_S256), &(_S257), delta_1);
    (*rg_7).pos_1 = _S256;
    (*rg_7).pos_err_1 = _S257;
    (*rg_7).rot_0 = rot1_1;
    (*rg_7).w_4 = world_mul_0(rot1_1, isl_9.inv0_0, isl_9.inv1_0, isl_9.inv2_0, l_3);
    return;
}

fn write_probe_0( slot_1 : u32,  k_17 : u32,  value_2 : f32)
{
    var at_4 : u32 = params_0.probe_base_0 * u32(4) + slot_1 * params_0.probe_stride_0 + k_17;
    var v_8 : vec4<f32> = scratch_0[at_4 / u32(4)];
    v_8[at_4 % u32(4)] = value_2;
    scratch_0[at_4 / u32(4)] = v_8;
    return;
}

fn record_probes_0( isl_10 : Island_0,  rg_8 : Rigid_0,  k_18 : u32)
{
    var at_5 : u32 = isl_10.probes_0.x;
    loop
    {
        if(at_5 < (isl_10.probes_0.y))
        {
        }
        else
        {
            break;
        }
        var info_3 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[at_5])));
        var a_9 : vec4<f32> = loads_0[at_5 + u32(1)];
        var b_27 : vec4<f32> = loads_0[at_5 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_5 + u32(3)];
        var kind_1 : u32 = info_3.x;
        var i_5 : u32 = info_3.y;
        var value_3 : f32;
        if(kind_1 == u32(0))
        {
            value_3 = dot(rg_8.pos_1 - b_27.xyz + (rg_8.pos_err_1 - c4_0.xyz) + rotate_0(rg_8.rot_0, chunks_0[i_5].center_0.xyz + state_0[u32(4) * i_5].xyz), a_9.xyz);
        }
        else
        {
            if(kind_1 == u32(1))
            {
                var _S258 : u32 = u32(4) * i_5;
                value_3 = dot(rg_8.vel_1 + rg_8.vel_err_1 + cross(rg_8.w_4, rotate_0(rg_8.rot_0, chunks_0[i_5].center_0.xyz + state_0[_S258].xyz - isl_10.com_0.xyz)) + rotate_0(rg_8.rot_0, state_0[_S258 + u32(2)].xyz), a_9.xyz);
            }
            else
            {
                if(kind_1 == u32(2))
                {
                    var _S259 : u32 = u32(3) * i_5;
                    var f_12 : vec3<f32> = scratch_0[_S259].xyz;
                    var _S260 : bool = (info_3.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S260)
                    {
                        mc_0 = scratch_0[_S259 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S259 + u32(2)].xyz;
                    }
                    var fc_2 : vec3<f32>;
                    if(_S260)
                    {
                        fc_2 = f_12;
                    }
                    else
                    {
                        fc_2 = (vec3<f32>(0) - f_12);
                    }
                    value_3 = dot(fc_2, a_9.xyz) + dot(mc_0, b_27.xyz);
                }
                else
                {
                    var _S261 : u32 = u32(4) * i_5;
                    value_3 = dot(rotate_0(rg_8.rot_0, vec3<f32>(state_0[_S261 + u32(1)].w, state_0[_S261 + u32(2)].w, state_0[_S261 + u32(3)].w)), a_9.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_18, value_3);
        at_5 = at_5 + u32(4);
    }
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
    var _S262 : bool;
    if((st_0.damage_0) < 1.0f)
    {
        _S262 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S262 = (st_0.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S262 = false;
        }
    }
    return _S262;
}

fn fdiv_0( a_10 : f32,  b_28 : f32) -> f32
{
    return a_10 / b_28;
}

fn fsqrt_0( a_11 : f32) -> f32
{
    return sqrt(a_11);
}

struct Measures_0
{
     tension_0 : f32,
     shear_0 : f32,
     normal_compression_0 : f32,
     compression_0 : f32,
     compressive_force_0 : f32,
};

fn stress_measures_0( b_29 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_2 : f32 = (*b_29).geom0_0.x;
    var _S263 : f32 = q_lin_0.z;
    var axial_0 : f32 = fdiv_0(_S263, area_2);
    var bending_0 : f32 = fdiv_0(abs(q_ang_0.x), (*b_29).geom1_0.x) + fdiv_0(abs(q_ang_0.y), (*b_29).geom1_0.y);
    var _S264 : f32 = q_lin_0.x;
    var _S265 : f32 = q_lin_0.y;
    var shear_1 : f32 = fdiv_0(fsqrt_0(_S264 * _S264 + _S265 * _S265), area_2) + fdiv_0(abs(q_ang_0.z), (*b_29).geom0_0.w);
    var m_3 : Measures_0;
    m_3.tension_0 = axial_0 + bending_0;
    m_3.shear_0 = shear_1;
    var _S266 : f32 = - axial_0;
    m_3.normal_compression_0 = max(_S266, 0.0f);
    m_3.compression_0 = _S266 + bending_0;
    m_3.compressive_force_0 = max(- _S263, 0.0f);
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

fn fpow_0( a_12 : f32,  b_30 : f32) -> f32
{
    return pow(a_12, b_30);
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_9 : f32 = abs(strain_rate_1);
    var _S267 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_9 <= ref_0)
    {
        return 1.0f;
    }
    var _S268 : f32 = _S267.z;
    var f_13 : f32;
    if(r_9 <= _S268)
    {
        f_13 = fpow_0(fdiv_0(r_9, ref_0), _S267.y);
    }
    else
    {
        f_13 = fpow_0(fdiv_0(_S268, ref_0), _S267.y) * fpow_0(fdiv_0(r_9, _S268), _S267.w);
    }
    return clamp(f_13, 1.0f, (*mat_1).misc_0.x);
}

fn fatigue_factor_0( mat_2 : ptr<function, JointMaterial_std140_0>,  fatigue_1 : f32) -> f32
{
    if(((((*mat_2).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return fpow_0(1.0f - clamp(fatigue_1, 0.0f, 1.0f), fdiv_0(1.0f, (*mat_2).misc_0.y - 2.0f));
}

fn fatigue_factor_1( mat_3 : ptr<function, JointMaterial_std140_0>,  fatigue_2 : f32) -> f32
{
    if(((((*mat_3).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return fpow_0(1.0f - clamp(fatigue_2, 0.0f, 1.0f), fdiv_0(1.0f, (*mat_3).misc_0.y - 2.0f));
}

fn infinity_0() -> f32
{
    return (bitcast<f32>((u32(2139095040))));
}

fn failure_indices_0( mat_4 : ptr<function, JointMaterial_std140_0>,  b_31 : ptr<function, JointBond_std430_0>,  m_4 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_3 : f32 = (*mat_4).strength_0.y * multiplier_0;
    var _S269 : f32 = min((*mat_4).strength_0.z * multiplier_0 + (*mat_4).strength_0.w * m_4.normal_compression_0, (*mat_4).energy_1.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(fdiv_0(m_4.tension_0, (*mat_4).strength_0.x * multiplier_0), 0.0f);
    var _S270 : f32;
    if(_S269 > 0.0f)
    {
        _S270 = fdiv_0(m_4.shear_0, _S269);
    }
    else
    {
        _S270 = infinity_0();
    }
    idx_0[i32(1)] = _S270;
    idx_0[i32(2)] = max(fdiv_0(m_4.compression_0, fc_3), 0.0f);
    var _S271 : f32 = (*b_31).stiff1_0.y;
    if(_S271 > 0.0f)
    {
        _S270 = fdiv_0(m_4.compressive_force_0, _S271);
    }
    else
    {
        _S270 = 0.0f;
    }
    idx_0[i32(3)] = _S270;
    return idx_0;
}

fn sq_0( x_8 : f32) -> f32
{
    return x_8 * x_8;
}

fn damage_law_0( kind_2 : u32,  kappa_1 : f32,  r_10 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == u32(0))
    {
        if(r_10 <= 1.0f)
        {
            return 1.0f;
        }
        return min(fdiv_0(r_10 * (kappa_1 - 1.0f), kappa_1 * (r_10 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_10 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

fn damage_increment_0( kind_3 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_11 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S272 : f32 = max(damage_law_0(kind_3, lambda_0, r_11), d_old_0);
    var _S273 : bool;
    if(_S272 <= d_old_0)
    {
        _S273 = true;
    }
    else
    {
        _S273 = d_old_0 >= 1.0f;
    }
    if(_S273)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = fdiv_0(psi_0, lambda_0 * lambda_0);
    var _S274 : f32 = max(kappa_old_0, 1.0f);
    if(kind_3 == u32(0))
    {
        if(r_11 > 1.0f)
        {
            return vec2<f32>(_S272, fdiv_0(u0_0 * r_11, r_11 - 1.0f) * max(min(lambda_0, r_11) - min(_S274, r_11), 0.0f));
        }
        return vec2<f32>(_S272, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_11 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S274, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S272 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S272, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_3 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S275 : f32 = - h0_0;
    var _S276 : f32 = - h1_0;
    var _S277 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S275, _S276), vec2<f32>(h0_0, _S276), vec2<f32>(h0_0, h1_0), vec2<f32>(_S275, h1_0) );
    var poly_0 : array<vec2<f32>, i32(8)>;
    var i_6 : u32 = u32(0);
    var count_4 : u32 = u32(0);
    loop
    {
        if(i_6 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S278 : u32 = i_6;
        var _S279 : u32 = i_6 + u32(1);
        var _S280 : u32 = _S279 % u32(4);
        var _S281 : f32 = _S277[i_6].y;
        var _S282 : f32 = _S277[i_6].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S281 - ay_0 * _S282;
        var _S283 : f32 = _S277[_S280].y;
        var _S284 : f32 = _S277[_S280].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S283 - ay_0 * _S284;
        var _S285 : bool = fp_0 < 0.0f;
        if(_S285)
        {
            var _S286 : u32 = count_4 + u32(1);
            poly_0[count_4] = _S277[_S278];
            count_3 = _S286;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S285 != (fq_0 < 0.0f))
        {
            var t_13 : f32 = fp_0 / (fp_0 - fq_0);
            var _S287 : u32 = count_3 + u32(1);
            poly_0[count_3] = vec2<f32>(_S282 + t_13 * (_S284 - _S282), _S281 + t_13 * (_S283 - _S281));
            count_4 = _S287;
        }
        else
        {
            count_4 = count_3;
        }
        i_6 = _S279;
    }
    count_3 = u32(0);
    loop
    {
        if(count_3 < u32(6))
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_3] = 0.0f;
        count_3 = count_3 + u32(1);
    }
    if(count_4 < u32(3))
    {
        return;
    }
    var o_1 : vec2<f32> = poly_0[i32(0)];
    i_6 = u32(0);
    var a_13 : f32 = 0.0f;
    var sx_0 : f32 = 0.0f;
    var sy_0 : f32 = 0.0f;
    var ixx_0 : f32 = 0.0f;
    var iyy_0 : f32 = 0.0f;
    var ixy_0 : f32 = 0.0f;
    loop
    {
        if(i_6 < count_4)
        {
        }
        else
        {
            break;
        }
        var _S288 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_6].x - _S288;
        var _S289 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_6].y - _S289;
        var _S290 : u32 = i_6 + u32(1);
        var _S291 : u32 = _S290 % count_4;
        var x1_0 : f32 = poly_0[_S291].x - _S288;
        var y1_0 : f32 = poly_0[_S291].y - _S289;
        var _S292 : f32 = x0_0 * y1_0;
        var _S293 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S292 - _S293;
        var a_14 : f32 = a_13 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S292 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S293) * cr_0 / 24.0f;
        i_6 = _S290;
        a_13 = a_14;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_13 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_13;
    var cy_0 : f32 = sy_0 / a_13;
    (*region_0)[i32(0)] = a_13;
    (*region_0)[i32(1)] = o_1.x + cx_0;
    (*region_0)[i32(2)] = o_1.y + cy_0;
    var _S294 : f32 = a_13 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S294 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_13 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S294 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_12 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_12));
    var a_15 : f32 = r_12[i32(0)];
    if((r_12[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_19 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_4 : f32 = dz_1 + ax_1 * r_12[i32(2)] - ay_1 * r_12[i32(1)];
    var _S295 : f32 = a_15 * fc_4;
    var _S296 : f32 = - ay_1;
    return vec4<f32>(k_19 * a_15 * fc_4, k_19 * (_S295 * r_12[i32(2)] + (_S296 * r_12[i32(5)] + ax_1 * r_12[i32(4)])), - k_19 * (_S295 * r_12[i32(1)] + (_S296 * r_12[i32(3)] + ax_1 * r_12[i32(5)])), 0.5f * k_19 * (_S295 * fc_4 + ay_1 * ay_1 * r_12[i32(3)] + ax_1 * ax_1 * r_12[i32(4)] - 2.0f * ax_1 * ay_1 * r_12[i32(5)]));
}

fn signum_0( x_9 : f32) -> f32
{
    var _S297 : f32;
    if((((bitcast<u32>((x_9))) & (u32(2147483648)))) != u32(0))
    {
        _S297 = -1.0f;
    }
    else
    {
        _S297 = 1.0f;
    }
    return _S297;
}

fn return_map_0( k_20 : f32,  total_2 : f32,  plastic_0 : f32,  cap_0 : f32) -> vec2<f32>
{
    var trial_0 : f32 = k_20 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return vec2<f32>(trial_0, 0.0f);
    }
    var f_14 : f32 = cap_0 * signum_0(trial_0);
    return vec2<f32>(f_14, fdiv_0(trial_0 - f_14, k_20));
}

struct Contact_0
{
     q_lin_1 : vec3<f32>,
     q_ang_1 : vec3<f32>,
     energy_2 : f32,
     diss_4 : f32,
     plastic_1 : vec3<f32>,
};

fn contact_part_0( mat_5 : ptr<function, JointMaterial_std140_0>,  b_32 : ptr<function, JointBond_std430_0>,  crush_2 : f32,  plastic_2 : vec3<f32>,  d_lin_0 : vec3<f32>,  d_ang_0 : vec3<f32>) -> Contact_0
{
    var c_14 : Contact_0;
    var _S298 : vec3<f32> = vec3<f32>(0.0f);
    c_14.q_lin_1 = _S298;
    c_14.q_ang_1 = _S298;
    c_14.energy_2 = 0.0f;
    c_14.diss_4 = 0.0f;
    c_14.plastic_1 = plastic_2;
    var _S299 : u32 = (*mat_5).kind_flags_0.y;
    if(((_S299 & (u32(2)))) == u32(0))
    {
        return c_14;
    }
    var kn_1 : f32 = (*b_32).stiff0_0.x;
    var ks_0 : f32 = (*b_32).stiff0_0.y;
    var kt_0 : f32 = (*b_32).stiff1_0.x;
    var w0_2 : f32 = (*b_32).geom0_0.y;
    var w1_2 : f32 = (*b_32).geom0_0.z;
    var diss_5 : f32;
    var nc_sum_0 : f32;
    var m1_0 : f32;
    var m2_0 : f32;
    var energy_3 : f32;
    if(((_S299 & (u32(4)))) != u32(0))
    {
        var p_13 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S300 : f32 = p_13.y;
        var _S301 : f32 = p_13.z;
        var _S302 : f32 = p_13.w;
        nc_sum_0 = p_13.x;
        m1_0 = _S300;
        m2_0 = _S301;
        energy_3 = _S302;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S303 : f32 = d_ang_0.x;
        var _S304 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S303) * 0.4166666567325592f * w1_2 + abs(_S304) * 0.4166666567325592f * w0_2;
        var _S305 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S305) + spread_0);
        if((_S305 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S305 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S306 : f32 = ki_0 * _S303 * i2_0;
                var _S307 : f32 = ki_0 * _S304 * i1_0;
                var _S308 : f32 = 0.5f * ki_0 * (36.0f * _S305 * _S305 + _S303 * _S303 * i2_0 + _S304 * _S304 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S305;
                m1_0 = _S306;
                m2_0 = _S307;
                energy_3 = _S308;
            }
            else
            {
                var i_7 : u32 = u32(0);
                diss_5 = 0.0f;
                var m1_1 : f32 = 0.0f;
                var m2_1 : f32 = 0.0f;
                var energy_4 : f32 = 0.0f;
                loop
                {
                    if(i_7 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S309 : f32 = ((f32(i_7) + 0.5f) / 6.0f - 0.5f) * w0_2;
                    var j_5 : u32 = u32(0);
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    loop
                    {
                        if(j_5 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var s2_0 : f32 = ((f32(j_5) + 0.5f) / 6.0f - 0.5f) * w1_2;
                        var di_0 : f32 = _S305 + _S303 * s2_0 - _S304 * _S309;
                        if(di_0 < 0.0f)
                        {
                            var f_15 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_15 * s2_0;
                            var m2_2 : f32 = m2_0 - f_15 * _S309;
                            var energy_5 : f32 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_15;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_5 = j_5 + u32(1);
                    }
                    i_7 = i_7 + u32(1);
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
    var p_14 : vec3<f32> = plastic_2;
    c_14.q_lin_1 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_14.q_ang_1 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_5).strength_0.w * nc_0;
    var _S310 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S311 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var tn_0 : f32 = fsqrt_0(_S310 * _S310 + _S311 * _S311);
    var _S312 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S312 = tn_0 > 0.0f;
    }
    else
    {
        _S312 = false;
    }
    if(_S312)
    {
        var _S313 : f32 = fdiv_0(_S310, tn_0);
        var _S314 : f32 = fdiv_0(_S311, tn_0);
        var dslip_0 : f32 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        p_14[i32(0)] = p_14[i32(0)] + _S313 * dslip_0;
        p_14[i32(1)] = p_14[i32(1)] + _S314 * dslip_0;
        c_14.q_lin_1[i32(0)] = _S313 * slide_cap_0;
        c_14.q_lin_1[i32(1)] = _S314 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_14.q_lin_1[i32(0)] = _S310;
        c_14.q_lin_1[i32(1)] = _S311;
        diss_5 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_14.z, slide_cap_0 * (*b_32).geom1_0.z);
    var _S315 : f32 = tq_0.x;
    var _S316 : f32 = tq_0.y;
    var diss_6 : f32 = diss_5 + abs(_S315) * abs(_S316);
    p_14[i32(2)] = p_14[i32(2)] + _S316;
    c_14.q_ang_1[i32(2)] = _S315;
    c_14.energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0(c_14.q_lin_1.x), ks_0) + fdiv_0(sq_0(c_14.q_lin_1.y), ks_0) + fdiv_0(sq_0(_S315), kt_0));
    c_14.diss_4 = diss_6;
    c_14.plastic_1 = p_14;
    return c_14;
}

fn life_rate_0( mat_6 : ptr<function, JointMaterial_std140_0>,  s_4 : f32) -> f32
{
    if(s_4 <= 0.0f)
    {
        return 0.0f;
    }
    var _S317 : f32 = (*mat_6).misc_0.y;
    return fdiv_0((_S317 + 1.0f) * fpow_0(s_4, _S317), (*mat_6).misc_0.z);
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

fn joint_evaluate_0( mat_7 : ptr<function, JointMaterial_std140_0>,  b_33 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>,  dt_12 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_2 : f32 = (*b_33).stiff0_0.x;
    var ks_1 : f32 = (*b_33).stiff0_0.y;
    var kb1_0 : f32 = (*b_33).stiff0_0.z;
    var kb2_0 : f32 = (*b_33).stiff0_0.w;
    var _S318 : vec4<f32> = (*b_33).stiff1_0;
    var kt_1 : f32 = (*b_33).stiff1_0.x;
    var has_rebar_1 : bool = ((*b_33).stiff1_0.w) != 0.0f;
    var kind_4 : u32 = (*mat_7).kind_flags_0.x;
    var flags_1 : u32 = (*mat_7).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_1 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_0(state_2, has_rebar_1);
    var qe_lin_0 : vec3<f32> = d_lin_1 * vec3<f32>(ks_1, ks_1, kn_2);
    var qe_ang_0 : vec3<f32> = d_ang_1 * vec3<f32>(kb1_0, kb2_0, kt_1);
    var _S319 : Measures_0 = stress_measures_0(&((*b_33)), qe_lin_0, qe_ang_0);
    var _S320 : f32 = max(max(_S319.tension_0, _S319.shear_0), _S319.compression_0);
    var _S321 : bool = dt_12 > 0.0f;
    var dif_1 : f32;
    if(_S321)
    {
        var raw_0 : f32 = fdiv_0(max(fdiv_0(_S320 - st_1.governing_stress_0, dt_12), 0.0f), (*mat_7).misc_0.w);
        var tau_2 : f32 = _S318.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_12, tau_2));
        }
        else
        {
            dif_1 = min(fdiv_0(dt_12, tau_2), 1.0f);
        }
        st_1.strain_rate_0 = st_1.strain_rate_0 + (raw_0 - st_1.strain_rate_0) * dif_1;
        st_1.governing_stress_0 = _S320;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S322 : f32 = dif_factor_0(&((*mat_7)), st_1.strain_rate_0);
        dif_1 = _S322;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_33).geom1_0.w;
    var _S323 : f32 = weibull_0 * dif_1;
    var _S324 : f32 = fatigue_factor_1(&((*mat_7)), st_1.fatigue_0);
    var multiplier_1 : f32 = _S323 * _S324;
    var _S325 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_33)), _S319, multiplier_1);
    var _S326 : f32 = _S325.x;
    var _S327 : f32 = _S325.y;
    st_1.utilization_0 = max(max(_S326, _S327), max(_S325.z, _S325.w));
    var _S328 : f32 = d_lin_1.x;
    var _S329 : f32 = d_lin_1.y;
    var _S330 : f32 = ks_1 * (sq_0(_S328) + sq_0(_S329)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    var _S331 : f32 = d_lin_1.z;
    var _S332 : bool = _S331 > 0.0f;
    if(_S332)
    {
        dif_1 = kn_2 * sq_0(_S331);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S330 + dif_1);
    var psi_c_0 : f32;
    if(_S331 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S331);
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
    var _S333 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S334 : bool = _S326 >= _S327;
        if(_S334)
        {
            diss_contact_0 = _S326;
        }
        else
        {
            diss_contact_0 = _S327;
        }
        var mode_ts_0 : u32;
        if(_S334)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_1.kappa_0))
        {
            _S333 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S333 = false;
        }
        if(_S333)
        {
            _S333 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S333 = false;
        }
        var mode_c_0 : u32;
        if(_S333)
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
                intact_normal_0 = fdiv_0(psi_contact_0 * (*b_33).geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_1.ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_4;
            }
            else
            {
                mode_c_0 = u32(0);
            }
            var inc_0 : vec2<f32> = damage_increment_0(mode_c_0, st_1.kappa_0, diss_contact_0, intact_normal_0, st_1.damage_0, psi_ts_0);
            var _S335 : f32 = inc_0.x;
            if(_S335 > (st_1.damage_0))
            {
                var _S336 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_33)), st_1.crush_1, plastic_3, d_lin_1, d_ang_1);
                var _S337 : f32 = max(_S336.energy_2 - (1.0f - st_1.crush_1) * psi_c_0, 0.0f);
                var _S338 : f32 = max(inc_0.y - _S337 * (_S335 - st_1.damage_0), 0.0f);
                var _S339 : f32 = max((psi_ts_0 - _S337) * (_S335 - st_1.damage_0) - _S338, 0.0f);
                st_1.damage_0 = _S335;
                st_1.mode_0 = mode_ts_0;
                dissipated_4 = _S338;
                overshoot_1 = _S339;
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
            var _S340 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_33)), state_2.crush_1, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S340.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S341 : Measures_0 = stress_measures_0(&((*b_33)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S342 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_33)), _S341, multiplier_1);
        var _S343 : f32 = _S342.z;
        var _S344 : f32 = _S342.w;
        var _S345 : bool = _S343 >= _S344;
        if(_S345)
        {
            psi_contact_0 = _S343;
        }
        else
        {
            psi_contact_0 = _S344;
        }
        if(_S345)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_1.kappa_c_0))
        {
            _S333 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S333 = false;
        }
        if(_S333)
        {
            _S333 = psi_c_0 > 0.0f;
        }
        else
        {
            _S333 = false;
        }
        if(_S333)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0((*mat_7).energy_1.w * (*b_33).geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
                    mode_ts_0 = kind_4;
                }
                law_1 = mode_ts_0;
            }
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_1.kappa_c_0, psi_contact_0, intact_normal_0, st_1.crush_1, psi_c_0);
            var _S346 : f32 = inc_1.x;
            if(_S346 > (st_1.crush_1))
            {
                var _S347 : f32 = inc_1.y;
                var dissipated_5 : f32 = dissipated_4 + _S347;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S346 - st_1.crush_1) - _S347, 0.0f);
                st_1.crush_1 = _S346;
                st_1.mode_0 = mode_c_0;
                if(_S346 >= 1.0f)
                {
                    _S333 = (st_1.damage_0) < 1.0f;
                }
                else
                {
                    _S333 = false;
                }
                if(_S333)
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
    var _S348 : vec3<f32> = vec3<f32>(0.0f);
    if((st_1.damage_0) == 0.0f)
    {
        _S333 = ((flags_1 & (u32(8)))) != u32(0);
    }
    else
    {
        _S333 = false;
    }
    var qc_ang_0 : vec3<f32>;
    if(!_S333)
    {
        var _S349 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_33)), st_1.crush_1, plastic_3, d_lin_1, d_ang_1);
        st_1.plastic_x_0 = _S349.plastic_1.x;
        st_1.plastic_y_0 = _S349.plastic_1.y;
        st_1.plastic_t_0 = _S349.plastic_1.z;
        diss_contact_0 = _S349.diss_4;
        qc_lin_0 = _S349.q_lin_1;
        qc_ang_0 = _S349.q_ang_1;
        psi_contact_0 = _S349.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S348;
        qc_ang_0 = _S348;
        psi_contact_0 = 0.0f;
    }
    var dissipated_7 : f32 = dissipated_4 + dmg_0 * diss_contact_0;
    if(_S332)
    {
        intact_normal_0 = kn_2 * _S331;
    }
    else
    {
        intact_normal_0 = (1.0f - st_1.crush_1) * kn_2 * _S331;
    }
    var _S350 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S350 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S350 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S350 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S350) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_7 : f32 = _S350 * (psi_ts_0 + (1.0f - st_1.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_1)
    {
        _S333 = (st_1.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S333 = false;
    }
    var stored_8 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S333)
    {
        var k_axial_0 : f32 = (*b_33).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_33).rebar0_0.y;
        var yield_force_0 : f32 = (*b_33).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_33).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S331, st_1.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S328, st_1.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S329, st_1.rebar_slip1_0, dowel_capacity_0);
        var _S351 : f32 = nr_0.y;
        var _S352 : f32 = v1_0.y;
        var _S353 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S351) + dowel_capacity_0 * (abs(_S352) + abs(_S353));
        st_1.rebar_plastic_0 = st_1.rebar_plastic_0 + _S351;
        st_1.rebar_slip0_0 = st_1.rebar_slip0_0 + _S352;
        st_1.rebar_slip1_0 = st_1.rebar_slip1_0 + _S353;
        st_1.rebar_work_0 = st_1.rebar_work_0 + work_0;
        var dissipated_8 : f32 = dissipated_7 + work_0;
        var _S354 : f32 = nr_0.x;
        var _S355 : f32 = v1_0.x;
        var _S356 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (fdiv_0(sq_0(_S354), k_axial_0) + fdiv_0(sq_0(_S355) + sq_0(_S356), k_dowel_0));
        if(fracture_1)
        {
            _S333 = (st_1.rebar_work_0) >= ((*b_33).rebar1_0.x);
        }
        else
        {
            _S333 = false;
        }
        if(_S333)
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
            force_lin_3 = force_lin_2 + vec3<f32>(_S355, _S356, _S354);
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
        _S333 = _S321;
    }
    else
    {
        _S333 = false;
    }
    if(_S333)
    {
        _S333 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S333 = false;
    }
    if(_S333)
    {
        var _S357 : Measures_0 = stress_measures_0(&((*b_33)), force_lin_3, force_ang_2);
        var _S358 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_33)), _S357, weibull_0);
        var _S359 : f32 = life_rate_0(&((*mat_7)), max(max(_S358.x, _S358.y), _S358.z));
        st_1.fatigue_0 = min(st_1.fatigue_0 + _S359 * dt_12, 1.0f);
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
        _S333 = !connected_0(st_1, has_rebar_1);
    }
    else
    {
        _S333 = false;
    }
    resp_0.disconnected_0 = _S333;
    resp_0.measures_0 = _S319;
    return resp_0;
}

fn secant_factors_0( b_34 : ptr<function, JointBond_std430_0>,  st_2 : JointState_0,  d_lin_2 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var compressed_0 : bool = (d_lin_2.z) < 0.0f;
    var contact_3 : f32;
    if(compressed_0)
    {
        contact_3 = st_2.damage_0;
    }
    else
    {
        contact_3 = 0.0f;
    }
    var _S360 : f32 = 1.0f - st_2.damage_0;
    var _S361 : f32 = max(_S360 + contact_3, 9.99999997475242708e-07f);
    var normal_6 : f32;
    if(compressed_0)
    {
        normal_6 = max(1.0f - st_2.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_6 = max(_S360, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S361, _S361, normal_6);
    (*f_ang_0) = vec3<f32>(_S361);
    var _S362 : bool;
    if(((*b_34).stiff1_0.w) != 0.0f)
    {
        _S362 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S362 = false;
    }
    if(_S362)
    {
        var _S363 : vec4<f32> = (*b_34).rebar0_0;
        var _S364 : vec4<f32> = (*b_34).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + fdiv_0((*b_34).rebar0_0.x, (*b_34).stiff0_0.x);
        var _S365 : f32 = fdiv_0(_S363.y, _S364.y);
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S365;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S365;
    }
    return;
}

fn is_damaged_0( st_3 : JointState_0) -> bool
{
    var _S366 : bool;
    if((st_3.damage_0) > 0.0f)
    {
        _S366 = true;
    }
    else
    {
        _S366 = (st_3.crush_1) > 0.0f;
    }
    return _S366;
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

fn to_local_0( _S367 : u32,  _S368 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S368, bonds_0[_S367].t1_0.xyz), dot(_S368, bonds_0[_S367].t2_0.xyz), dot(_S368, bonds_0[_S367].normal_0.xyz));
}

fn to_body_0( _S369 : u32,  _S370 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S369].t1_0.xyz * vec3<f32>(_S370.x) + bonds_0[_S369].t2_0.xyz * vec3<f32>(_S370.y) + bonds_0[_S369].normal_0.xyz * vec3<f32>(_S370.z);
}

fn bond_update_0( i_8 : u32,  dt_13 : f32,  fracture_2 : bool,  abs_step_0 : u32) -> bool
{
    var _S371 : JointState_0 = JointState_0( bond_dyn_0[i_8].js_0.damage_0, bond_dyn_0[i_8].js_0.crush_1, bond_dyn_0[i_8].js_0.kappa_0, bond_dyn_0[i_8].js_0.kappa_c_0, bond_dyn_0[i_8].js_0.ductility_0, bond_dyn_0[i_8].js_0.ductility_c_0, bond_dyn_0[i_8].js_0.fatigue_0, bond_dyn_0[i_8].js_0.plastic_x_0, bond_dyn_0[i_8].js_0.plastic_y_0, bond_dyn_0[i_8].js_0.plastic_t_0, bond_dyn_0[i_8].js_0.rebar_plastic_0, bond_dyn_0[i_8].js_0.rebar_slip0_0, bond_dyn_0[i_8].js_0.rebar_slip1_0, bond_dyn_0[i_8].js_0.rebar_work_0, bond_dyn_0[i_8].js_0.rebar_broken_0, bond_dyn_0[i_8].js_0.strain_rate_0, bond_dyn_0[i_8].js_0.governing_stress_0, bond_dyn_0[i_8].js_0.dissipated_0, bond_dyn_0[i_8].js_0.utilization_0, bond_dyn_0[i_8].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S371;
    bd_0.force_lin_0 = bond_dyn_0[i_8].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_8].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_8].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_8].comps_0;
    bd_0.events_0 = bond_dyn_0[i_8].events_0;
    var _S372 : JointBond_std430_0 = bonds_0[i_8].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_8].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_8].rb_0.xyz;
    var _S373 : u32 = u32(4) * _S372.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S373 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S373 + u32(3)].xyz;
    var _S374 : u32 = u32(4) * _S372.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S374 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S374 + u32(3)].xyz;
    var _S375 : vec3<f32> = to_local_0(i_8, state_0[_S374].xyz + cross(tb_3, rb_1) - (state_0[_S373].xyz + cross(ta_3, ra_1)));
    var _S376 : vec3<f32> = to_local_0(i_8, tb_3 - ta_3);
    var _S377 : vec3<f32> = to_local_0(i_8, state_0[_S374 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S373 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S378 : vec3<f32> = to_local_0(i_8, wb_0 - wa_0);
    var _S379 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S372.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S380 : JointResponse_0 = joint_evaluate_0(&(_S379), &(_S372), bd_0.js_0, _S375, _S376, dt_13, fracture_2);
    var f_lin_1 : vec3<f32>;
    var f_ang_1 : vec3<f32>;
    secant_factors_0(&(_S372), _S380.state_1, _S375, &(f_lin_1), &(f_ang_1));
    var qd_lin_0 : vec3<f32> = _S377 * bonds_0[i_8].c_lin_0.xyz * f_lin_1;
    var qd_ang_0 : vec3<f32> = _S378 * bonds_0[i_8].c_ang_0.xyz * f_ang_1;
    var q_lin_2 : vec3<f32> = _S380.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S380.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S377) + dot(qd_ang_0, _S378)) * dt_13;
    var _S381 : vec3<f32> = to_body_0(i_8, q_lin_2);
    var _S382 : vec3<f32> = to_body_0(i_8, q_ang_2);
    var _S383 : u32 = u32(3) * i_8;
    scratch_0[_S383] = vec4<f32>(_S381, max(_S380.measures_0.tension_0, _S380.measures_0.compression_0));
    scratch_0[_S383 + u32(1)] = vec4<f32>(_S382 + cross(ra_1, _S381), 0.0f);
    scratch_0[_S383 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S382) + cross(rb_1, (vec3<f32>(0) - _S381)), 0.0f);
    var _S384 : f32 = bd_0.sums_0[i32(0)];
    var _S385 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S384), &(_S385), _S380.dissipated_3);
    bd_0.sums_0[i32(0)] = _S384;
    bd_0.comps_0[i32(0)] = _S385;
    var _S386 : f32 = bd_0.sums_0[i32(1)];
    var _S387 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S386), &(_S387), _S380.overshoot_0);
    bd_0.sums_0[i32(1)] = _S386;
    bd_0.comps_0[i32(1)] = _S387;
    var _S388 : f32 = bd_0.sums_0[i32(2)];
    var _S389 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S388), &(_S389), damped_0);
    bd_0.sums_0[i32(2)] = _S388;
    bd_0.comps_0[i32(2)] = _S389;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S380.stored_6);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S380.state_1.utilization_0));
    var _S390 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S390 = is_damaged_0(_S380.state_1);
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        _S390 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S380.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S391 : f32 = fatigue_factor_0(&(_S379), previous_0.fatigue_0);
        _S390 = _S391 > 0.99000000953674316f;
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        var _S392 : f32 = fatigue_factor_0(&(_S379), _S380.state_1.fatigue_0);
        _S390 = _S392 <= 0.99000000953674316f;
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S380.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
    }
    bd_0.js_0 = _S380.state_1;
    bond_dyn_0[i_8].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_8].js_0.crush_1 = bd_0.js_0.crush_1;
    bond_dyn_0[i_8].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_8].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_8].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_8].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_8].js_0.fatigue_0 = bd_0.js_0.fatigue_0;
    bond_dyn_0[i_8].js_0.plastic_x_0 = bd_0.js_0.plastic_x_0;
    bond_dyn_0[i_8].js_0.plastic_y_0 = bd_0.js_0.plastic_y_0;
    bond_dyn_0[i_8].js_0.plastic_t_0 = bd_0.js_0.plastic_t_0;
    bond_dyn_0[i_8].js_0.rebar_plastic_0 = bd_0.js_0.rebar_plastic_0;
    bond_dyn_0[i_8].js_0.rebar_slip0_0 = bd_0.js_0.rebar_slip0_0;
    bond_dyn_0[i_8].js_0.rebar_slip1_0 = bd_0.js_0.rebar_slip1_0;
    bond_dyn_0[i_8].js_0.rebar_work_0 = bd_0.js_0.rebar_work_0;
    bond_dyn_0[i_8].js_0.rebar_broken_0 = bd_0.js_0.rebar_broken_0;
    bond_dyn_0[i_8].js_0.strain_rate_0 = bd_0.js_0.strain_rate_0;
    bond_dyn_0[i_8].js_0.governing_stress_0 = bd_0.js_0.governing_stress_0;
    bond_dyn_0[i_8].js_0.dissipated_0 = bd_0.js_0.dissipated_0;
    bond_dyn_0[i_8].js_0.utilization_0 = bd_0.js_0.utilization_0;
    bond_dyn_0[i_8].js_0.mode_0 = bd_0.js_0.mode_0;
    bond_dyn_0[i_8].force_lin_0 = bd_0.force_lin_0;
    bond_dyn_0[i_8].force_ang_0 = bd_0.force_ang_0;
    bond_dyn_0[i_8].sums_0 = bd_0.sums_0;
    bond_dyn_0[i_8].comps_0 = bd_0.comps_0;
    bond_dyn_0[i_8].events_0 = bd_0.events_0;
    return _S380.disconnected_0;
}

fn chunk_update_0( c_15 : u32,  isl_11 : ptr<function, Island_std430_0>,  rg_9 : Rigid_0,  dt_14 : f32,  rml_0 : bool,  step_0 : u32,  contact_4 : bool,  work_1 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S393 : vec3<f32> = vec3<f32>(0.0f);
    var _S394 : u32 = index_0[c_15];
    var peak_0 : f32 = 0.0f;
    var e_3 : u32 = _S394;
    var fi_0 : vec3<f32> = _S393;
    var mi_0 : vec3<f32> = _S393;
    loop
    {
        if(e_3 < index_0[c_15 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_2 : u32 = index_0[e_3];
        var _S395 : u32 = u32(3) * ((entry_2 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S395];
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + scratch_0[_S395 + u32(1)].xyz;
            fi_0 = fi_0 + fa_2.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + scratch_0[_S395 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_2.xyz);
            mi_0 = mi_2;
        }
        var _S396 : f32 = max(peak_0, fa_2.w);
        var _S397 : u32 = e_3 + u32(1);
        peak_0 = _S396;
        e_3 = _S397;
    }
    var _S398 : u32 = u32(4) * c_15;
    var u_0 : vec3<f32> = state_0[_S398].xyz;
    var _S399 : u32 = _S398 + u32(1);
    var th_1 : vec3<f32> = state_0[_S399].xyz;
    var _S400 : u32 = _S398 + u32(2);
    var v_9 : vec3<f32> = state_0[_S400].xyz;
    var _S401 : u32 = _S398 + u32(3);
    var w_5 : vec3<f32> = state_0[_S401].xyz;
    var mass_0 : f32 = chunks_0[c_15].center_0.w;
    var _S402 : vec3<f32> = chunks_0[c_15].center_0.xyz;
    var _S403 : vec3<f32> = (*isl_11).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_9.rot_0, _S402 + u_0 - _S403);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    chunk_external_1(c_15, c_15, rg_9.rot_0, step_0, dt_14, contact_4, &(f_load_0), &(t_load_0));
    record_chunk_load_0(c_15, f_load_0, t_load_0);
    var _S404 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S404;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.alpha_0) + cross(rg_9.w_4, world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.w_4)));
        f_world_1 = f_world_0 - (rg_9.a_6 + cross(rg_9.alpha_0, r_world_0) + cross(rg_9.w_4, cross(rg_9.w_4, r_world_0))) * _S404;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    var f_ext_0 : vec3<f32> = inverse_rotate_0(rg_9.rot_0, f_world_1);
    var m_ext_0 : vec3<f32> = inverse_rotate_0(rg_9.rot_0, t_world_1);
    var f_ext_1 : vec3<f32>;
    var m_ext_1 : vec3<f32>;
    if(rml_0)
    {
        var wb_1 : vec3<f32> = inverse_rotate_0(rg_9.rot_0, rg_9.w_4);
        var i_w_0 : vec3<f32> = rows_mul_0(chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, w_5);
        var m_ext_2 : vec3<f32> = m_ext_0 - (cross(wb_1, i_w_0) + cross(w_5, rows_mul_0(chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, wb_1)) + cross(w_5, i_w_0));
        f_ext_1 = f_ext_0 - cross(wb_1, v_9) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var _S405 : vec4<u32> = chunks_0[c_15].load_range_0;
    var term_5 : u32 = chunks_0[c_15].load_range_0.x;
    loop
    {
        if(term_5 < (_S405.y))
        {
        }
        else
        {
            break;
        }
        var _S406 : u32 = u32(5) * term_5;
        if(((bitcast<vec4<u32>>((loads_0[_S406]))).y) != u32(2))
        {
            term_5 = term_5 + u32(1);
            continue;
        }
        var _S407 : vec3<f32> = vec3<f32>(eval_function_0(term_5, step_0, dt_14, dt_14));
        var m_ext_3 : vec3<f32> = m_ext_1 + loads_0[_S406 + u32(2)].xyz * _S407;
        f_ext_1 = f_ext_1 + loads_0[_S406 + u32(1)].xyz * _S407;
        m_ext_1 = m_ext_3;
        term_5 = term_5 + u32(1);
    }
    var f_16 : vec3<f32> = f_ext_1 + fi_0;
    var m_5 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_15].info_1.x;
    var _S408 : vec3<f32> = vec3<f32>(state_0[_S399].w, state_0[_S400].w, state_0[_S401].w);
    var reaction_0 : vec3<f32>;
    var u_1 : vec3<f32>;
    var th_2 : vec3<f32>;
    var v_10 : vec3<f32>;
    var w_6 : vec3<f32>;
    if(support_0 == u32(1))
    {
        reaction_0 = (vec3<f32>(0) - f_16);
        u_1 = u_0;
        th_2 = th_1;
        v_10 = _S393;
        w_6 = _S393;
    }
    else
    {
        var _S409 : vec4<f32> = chunks_0[c_15].scale_0;
        var w_7 : vec3<f32> = w_5 + rows_mul_0(chunks_0[c_15].inv0_1, chunks_0[c_15].inv1_1, chunks_0[c_15].inv2_1, m_5) * vec3<f32>((dt_14 * chunks_0[c_15].scale_0.z));
        var _S410 : vec3<f32> = vec3<f32>(dt_14);
        var th_3 : vec3<f32> = th_1 + w_7 * _S410;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_16);
            u_1 = u_0;
            th_2 = _S393;
        }
        else
        {
            var v_11 : vec3<f32> = v_9 + f_16 * vec3<f32>((dt_14 * _S409.y));
            var u_2 : vec3<f32> = u_0 + v_11 * _S410;
            reaction_0 = _S408;
            u_1 = u_2;
            th_2 = v_11;
        }
        var _S411 : vec3<f32> = th_2;
        th_2 = th_3;
        v_10 = _S411;
        w_6 = w_7;
    }
    state_0[_S398] = vec4<f32>(u_1, peak_0);
    state_0[_S399] = vec4<f32>(th_2, reaction_0.x);
    state_0[_S400] = vec4<f32>(v_10, reaction_0.y);
    state_0[_S401] = vec4<f32>(w_6, reaction_0.z);
    comp_add1_2(&((*work_1)), &((*work_err_0)), (dot(f_load_0, rg_9.vel_1 + rg_9.vel_err_1 + cross(rg_9.w_4, rotate_0(rg_9.rot_0, _S402 + u_1 - _S403)) + rotate_0(rg_9.rot_0, v_10)) + dot(t_load_0, rg_9.w_4 + rotate_0(rg_9.rot_0, w_6))) * dt_14);
    return;
}

fn chunk_update_1( c_16 : u32,  isl_12 : Island_0,  rg_10 : Rigid_0,  dt_15 : f32,  rml_1 : bool,  step_1 : u32,  contact_5 : bool,  work_2 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S412 : vec3<f32> = vec3<f32>(0.0f);
    var _S413 : u32 = index_0[c_16];
    var peak_1 : f32 = 0.0f;
    var e_4 : u32 = _S413;
    var fi_1 : vec3<f32> = _S412;
    var mi_3 : vec3<f32> = _S412;
    loop
    {
        if(e_4 < index_0[c_16 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_3 : u32 = index_0[e_4];
        var _S414 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var fa_3 : vec4<f32> = scratch_0[_S414];
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            var mi_4 : vec3<f32> = mi_3 + scratch_0[_S414 + u32(1)].xyz;
            fi_1 = fi_1 + fa_3.xyz;
            mi_3 = mi_4;
        }
        else
        {
            var mi_5 : vec3<f32> = mi_3 + scratch_0[_S414 + u32(2)].xyz;
            fi_1 = fi_1 + (vec3<f32>(0) - fa_3.xyz);
            mi_3 = mi_5;
        }
        var _S415 : f32 = max(peak_1, fa_3.w);
        var _S416 : u32 = e_4 + u32(1);
        peak_1 = _S415;
        e_4 = _S416;
    }
    var _S417 : u32 = u32(4) * c_16;
    var u_3 : vec3<f32> = state_0[_S417].xyz;
    var _S418 : u32 = _S417 + u32(1);
    var th_4 : vec3<f32> = state_0[_S418].xyz;
    var _S419 : u32 = _S417 + u32(2);
    var v_12 : vec3<f32> = state_0[_S419].xyz;
    var _S420 : u32 = _S417 + u32(3);
    var w_8 : vec3<f32> = state_0[_S420].xyz;
    var mass_1 : f32 = chunks_0[c_16].center_0.w;
    var _S421 : vec3<f32> = chunks_0[c_16].center_0.xyz;
    var _S422 : vec3<f32> = isl_12.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_10.rot_0, _S421 + u_3 - _S422);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    chunk_external_1(c_16, c_16, rg_10.rot_0, step_1, dt_15, contact_5, &(f_load_1), &(t_load_1));
    record_chunk_load_0(c_16, f_load_1, t_load_1);
    var _S423 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S423;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.alpha_0) + cross(rg_10.w_4, world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.w_4)));
        f_world_3 = f_world_2 - (rg_10.a_6 + cross(rg_10.alpha_0, r_world_1) + cross(rg_10.w_4, cross(rg_10.w_4, r_world_1))) * _S423;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_3 = f_world_2;
        t_world_4 = t_world_3;
    }
    var f_ext_2 : vec3<f32> = inverse_rotate_0(rg_10.rot_0, f_world_3);
    var m_ext_4 : vec3<f32> = inverse_rotate_0(rg_10.rot_0, t_world_4);
    var f_ext_3 : vec3<f32>;
    var m_ext_5 : vec3<f32>;
    if(rml_1)
    {
        var wb_2 : vec3<f32> = inverse_rotate_0(rg_10.rot_0, rg_10.w_4);
        var i_w_1 : vec3<f32> = rows_mul_0(chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, w_8);
        var m_ext_6 : vec3<f32> = m_ext_4 - (cross(wb_2, i_w_1) + cross(w_8, rows_mul_0(chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, wb_2)) + cross(w_8, i_w_1));
        f_ext_3 = f_ext_2 - cross(wb_2, v_12) * vec3<f32>((2.0f * mass_1));
        m_ext_5 = m_ext_6;
    }
    else
    {
        f_ext_3 = f_ext_2;
        m_ext_5 = m_ext_4;
    }
    var _S424 : vec4<u32> = chunks_0[c_16].load_range_0;
    var term_6 : u32 = chunks_0[c_16].load_range_0.x;
    loop
    {
        if(term_6 < (_S424.y))
        {
        }
        else
        {
            break;
        }
        var _S425 : u32 = u32(5) * term_6;
        if(((bitcast<vec4<u32>>((loads_0[_S425]))).y) != u32(2))
        {
            term_6 = term_6 + u32(1);
            continue;
        }
        var _S426 : vec3<f32> = vec3<f32>(eval_function_0(term_6, step_1, dt_15, dt_15));
        var m_ext_7 : vec3<f32> = m_ext_5 + loads_0[_S425 + u32(2)].xyz * _S426;
        f_ext_3 = f_ext_3 + loads_0[_S425 + u32(1)].xyz * _S426;
        m_ext_5 = m_ext_7;
        term_6 = term_6 + u32(1);
    }
    var f_17 : vec3<f32> = f_ext_3 + fi_1;
    var m_6 : vec3<f32> = m_ext_5 + mi_3;
    var support_1 : u32 = chunks_0[c_16].info_1.x;
    var _S427 : vec3<f32> = vec3<f32>(state_0[_S418].w, state_0[_S419].w, state_0[_S420].w);
    var reaction_1 : vec3<f32>;
    var u_4 : vec3<f32>;
    var th_5 : vec3<f32>;
    var v_13 : vec3<f32>;
    var w_9 : vec3<f32>;
    if(support_1 == u32(1))
    {
        reaction_1 = (vec3<f32>(0) - f_17);
        u_4 = u_3;
        th_5 = th_4;
        v_13 = _S412;
        w_9 = _S412;
    }
    else
    {
        var _S428 : vec4<f32> = chunks_0[c_16].scale_0;
        var w_10 : vec3<f32> = w_8 + rows_mul_0(chunks_0[c_16].inv0_1, chunks_0[c_16].inv1_1, chunks_0[c_16].inv2_1, m_6) * vec3<f32>((dt_15 * chunks_0[c_16].scale_0.z));
        var _S429 : vec3<f32> = vec3<f32>(dt_15);
        var th_6 : vec3<f32> = th_4 + w_10 * _S429;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_17);
            u_4 = u_3;
            th_5 = _S412;
        }
        else
        {
            var v_14 : vec3<f32> = v_12 + f_17 * vec3<f32>((dt_15 * _S428.y));
            var u_5 : vec3<f32> = u_3 + v_14 * _S429;
            reaction_1 = _S427;
            u_4 = u_5;
            th_5 = v_14;
        }
        var _S430 : vec3<f32> = th_5;
        th_5 = th_6;
        v_13 = _S430;
        w_9 = w_10;
    }
    state_0[_S417] = vec4<f32>(u_4, peak_1);
    state_0[_S418] = vec4<f32>(th_5, reaction_1.x);
    state_0[_S419] = vec4<f32>(v_13, reaction_1.y);
    state_0[_S420] = vec4<f32>(w_9, reaction_1.z);
    comp_add1_2(&((*work_2)), &((*work_err_1)), (dot(f_load_1, rg_10.vel_1 + rg_10.vel_err_1 + cross(rg_10.w_4, rotate_0(rg_10.rot_0, _S421 + u_4 - _S422)) + rotate_0(rg_10.rot_0, v_13)) + dot(t_load_1, rg_10.w_4 + rotate_0(rg_10.rot_0, w_9))) * dt_15);
    return;
}

fn drift_moments_0( c_17 : u32,  tu_0 : ptr<function, vec3<f32>>,  pv_0 : ptr<function, vec3<f32>>)
{
    var _S431 : u32 = u32(4) * c_17;
    var _S432 : vec3<f32> = vec3<f32>((chunks_0[c_17].center_0.w * chunks_0[c_17].scale_0.x));
    (*tu_0) = (*tu_0) + state_0[_S431].xyz * _S432;
    (*pv_0) = (*pv_0) + state_0[_S431 + u32(2)].xyz * _S432;
    return;
}

fn drift_angular_0( c_18 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_13 : vec3<f32> = chunks_0[c_18].center_0.xyz - wcom_1;
    var _S433 : u32 = u32(4) * c_18;
    var _S434 : vec3<f32> = vec3<f32>(chunks_0[c_18].center_0.w);
    var _S435 : vec4<f32> = chunks_0[c_18].inertia0_1;
    var _S436 : vec4<f32> = chunks_0[c_18].inertia1_1;
    var _S437 : vec4<f32> = chunks_0[c_18].inertia2_1;
    var _S438 : vec3<f32> = vec3<f32>(chunks_0[c_18].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_13, state_0[_S433].xyz - tr_0) * _S434 + rows_mul_0(chunks_0[c_18].inertia0_1, chunks_0[c_18].inertia1_1, chunks_0[c_18].inertia2_1, state_0[_S433 + u32(1)].xyz)) * _S438;
    (*lv_0) = (*lv_0) + (cross(r_13, state_0[_S433 + u32(2)].xyz - dv_0) * _S434 + rows_mul_0(_S435, _S436, _S437, state_0[_S433 + u32(3)].xyz)) * _S438;
    return;
}

fn drift_apply_0( c_19 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  phi_0 : vec3<f32>,  dv_1 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_14 : vec3<f32> = chunks_0[c_19].center_0.xyz - wcom_2;
    var _S439 : u32 = u32(4) * c_19;
    state_0[_S439] = vec4<f32>(state_0[_S439].xyz - (tr_1 + cross(phi_0, r_14)), state_0[_S439].w);
    var _S440 : u32 = _S439 + u32(1);
    state_0[_S440] = vec4<f32>(state_0[_S440].xyz - phi_0, state_0[_S440].w);
    var _S441 : u32 = _S439 + u32(2);
    state_0[_S441] = vec4<f32>(state_0[_S441].xyz - (dv_1 + cross(dw_0, r_14)), state_0[_S441].w);
    var _S442 : u32 = _S439 + u32(3);
    state_0[_S442] = vec4<f32>(state_0[_S442].xyz - dw_0, state_0[_S442].w);
    return;
}

fn drift_rigid_0( isl_13 : ptr<function, Island_std430_0>,  rg_11 : ptr<function, Rigid_0>,  tr_2 : vec3<f32>,  phi_1 : vec3<f32>,  dv_2 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_3 : vec3<f32> = (*isl_13).wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_11).rot_0;
    var _S443 : vec3<f32> = rotate_0((*rg_11).rot_0, tr_2 - cross(phi_1, wcom_3));
    var _S444 : vec3<f32> = (*rg_11).pos_1;
    var _S445 : vec3<f32> = (*rg_11).pos_err_1;
    comp_add_0(&(_S444), &(_S445), _S443);
    (*rg_11).pos_1 = _S444;
    (*rg_11).pos_err_1 = _S445;
    (*rg_11).rot_0 = normalized_0(quat_mul_0((*rg_11).rot_0, from_axis_angle_0(phi_1, length(phi_1))));
    var _S446 : vec3<f32> = rotate_0(rot_2, dv_2 + cross(dw_1, (*isl_13).com_0.xyz - wcom_3));
    var _S447 : vec3<f32> = (*rg_11).vel_1;
    var _S448 : vec3<f32> = (*rg_11).vel_err_1;
    comp_add_0(&(_S447), &(_S448), _S446);
    (*rg_11).vel_1 = _S447;
    (*rg_11).vel_err_1 = _S448;
    (*rg_11).w_4 = (*rg_11).w_4 + rotate_0(rot_2, dw_1);
    return;
}

fn drift_rigid_1( isl_14 : Island_0,  rg_12 : ptr<function, Rigid_0>,  tr_3 : vec3<f32>,  phi_2 : vec3<f32>,  dv_3 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = isl_14.wcom_0.xyz;
    var rot_3 : Quat_0 = (*rg_12).rot_0;
    var _S449 : vec3<f32> = rotate_0((*rg_12).rot_0, tr_3 - cross(phi_2, wcom_4));
    var _S450 : vec3<f32> = (*rg_12).pos_1;
    var _S451 : vec3<f32> = (*rg_12).pos_err_1;
    comp_add_0(&(_S450), &(_S451), _S449);
    (*rg_12).pos_1 = _S450;
    (*rg_12).pos_err_1 = _S451;
    (*rg_12).rot_0 = normalized_0(quat_mul_0((*rg_12).rot_0, from_axis_angle_0(phi_2, length(phi_2))));
    var _S452 : vec3<f32> = rotate_0(rot_3, dv_3 + cross(dw_2, isl_14.com_0.xyz - wcom_4));
    var _S453 : vec3<f32> = (*rg_12).vel_1;
    var _S454 : vec3<f32> = (*rg_12).vel_err_1;
    comp_add_0(&(_S453), &(_S454), _S452);
    (*rg_12).vel_1 = _S453;
    (*rg_12).vel_err_1 = _S454;
    (*rg_12).w_4 = (*rg_12).w_4 + rotate_0(rot_3, dw_2);
    return;
}

fn contact_split_at_0( at_6 : u32)
{
    var previous_1 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S455 : u32;
    if(previous_1 == u32(0))
    {
        _S455 = at_6;
    }
    else
    {
        _S455 = min(previous_1, at_6);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S455;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var woke_0 : bool;
    var tid_4 : u32 = thread_2.x;
    var _S456 : u32 = group_2.x;
    var isl_15 : Island_0;
    isl_15.range_0 = islands_0[_S456].range_0;
    isl_15.info_0 = islands_0[_S456].info_0;
    isl_15.com_0 = islands_0[_S456].com_0;
    isl_15.inertia0_0 = islands_0[_S456].inertia0_0;
    isl_15.inertia1_0 = islands_0[_S456].inertia1_0;
    isl_15.inertia2_0 = islands_0[_S456].inertia2_0;
    isl_15.inv0_0 = islands_0[_S456].inv0_0;
    isl_15.inv1_0 = islands_0[_S456].inv1_0;
    isl_15.inv2_0 = islands_0[_S456].inv2_0;
    isl_15.wcom_0 = islands_0[_S456].wcom_0;
    isl_15.winv0_0 = islands_0[_S456].winv0_0;
    isl_15.winv1_0 = islands_0[_S456].winv1_0;
    isl_15.winv2_0 = islands_0[_S456].winv2_0;
    isl_15.rotation_0 = islands_0[_S456].rotation_0;
    isl_15.position_0 = islands_0[_S456].position_0;
    isl_15.position_err_0 = islands_0[_S456].position_err_0;
    isl_15.velocity_0 = islands_0[_S456].velocity_0;
    isl_15.velocity_err_0 = islands_0[_S456].velocity_err_0;
    isl_15.angular_velocity_0 = islands_0[_S456].angular_velocity_0;
    isl_15.done_0 = islands_0[_S456].done_0;
    isl_15.probes_0 = islands_0[_S456].probes_0;
    isl_15.energy_0 = islands_0[_S456].energy_0;
    var driven_0 : bool = (((isl_15.info_0.x) & (u32(2)))) != u32(0);
    var _S457 : bool = !((((isl_15.info_0.x) & (u32(1)))) != u32(0));
    var _S458 : bool;
    if(_S457)
    {
        _S458 = !driven_0;
    }
    else
    {
        _S458 = false;
    }
    var contact_island_0 : bool = (((isl_15.info_0.x) & (u32(4)))) != u32(0);
    var _S459 : bool = (((isl_15.info_0.x) & (u32(16)))) != u32(0);
    var _S460 : bool = tid_4 == u32(0);
    var settled_0 : bool;
    var run_0 : u32;
    if(_S460)
    {
        if(contact_island_0 != ((params_0.contact_mode_0) == u32(1)))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((isl_15.info_0.x) & (u32(8)))) != u32(0);
        }
        if(settled_0)
        {
            run_0 = u32(0);
        }
        else
        {
            run_0 = u32(1);
        }
        if(contact_island_0)
        {
            settled_0 = contact_stopped_1(isl_15);
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            run_0 = u32(0);
        }
        g_run_0 = run_0;
        g_halt_0 = u32(0);
    }
    workgroupBarrier();
    if((((isl_15.info_0.z) & (u32(1)))) != u32(0))
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = g_run_0 == u32(0);
    }
    if(settled_0)
    {
        run_0 = u32(0);
    }
    else
    {
        run_0 = min(isl_15.info_0.y, params_0.max_steps_0);
    }
    var _S461 : f32 = params_0.dt_0;
    var _S462 : bool = (params_0.fracture_0) != u32(0);
    var _S463 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_13 : Rigid_0 = rigid_of_1(isl_15);
    var work_3 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    settled_0 = _S459;
    var done_1 : u32 = u32(0);
    var woke_1 : bool = false;
    var s_5 : u32 = u32(0);
    loop
    {
        if(s_5 < run_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        var abs_step_1 : u32 = isl_15.info_0.w + s_5 + u32(1);
        var k_21 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var _S464 : bool;
        var i_9 : u32;
        if(settled_0)
        {
            var _S465 : vec3<f32> = vec3<f32>(0.0f);
            var norm_0 : vec3<f32> = _S465;
            var unused0_0 : vec3<f32> = _S465;
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
                var _S466 : f32 = settled_chunk_load_0(i_9, rg_13.rot_0, k_21, _S461, contact_island_0);
                norm_0[i32(0)] = norm_0[i32(0)] + _S466;
                i_9 = i_9 + u32(256);
            }
            group_sum3_0(tid_4, &(norm_0), &(unused0_0));
            if((params_0.solve_mode_0) == u32(1))
            {
                _S464 = (abs(norm_0.x - isl_15.energy_0.z)) > (isl_15.energy_0.w);
            }
            else
            {
                _S464 = false;
            }
            var settled_1 : bool;
            if(_S464)
            {
                settled_1 = false;
                woke_0 = true;
            }
            else
            {
                settled_1 = settled_0;
                woke_0 = woke_1;
            }
            settled_0 = settled_1;
        }
        else
        {
            woke_0 = woke_1;
        }
        if(_S457)
        {
            var _S467 : vec3<f32> = vec3<f32>(0.0f);
            var f_18 : vec3<f32> = _S467;
            var t_14 : vec3<f32> = _S467;
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
                net_load_1(i_9, isl_15, rg_13, k_21, _S461, contact_island_0, &(f_18), &(t_14));
                i_9 = i_9 + u32(256);
            }
            group_sum3_0(tid_4, &(f_18), &(t_14));
            rigid_acceleration_1(isl_15, &(rg_13), f_18, t_14);
        }
        if(settled_0)
        {
            if(_S458)
            {
                integrate_rigid_1(isl_15, &(rg_13), _S461);
            }
            if(_S460)
            {
                _S464 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
            }
            else
            {
                _S464 = false;
            }
            if(_S464)
            {
                record_probes_0(isl_15, rg_13, k_21);
            }
            done_1 = s_5 + u32(1);
            var _S468 : u32 = s_5 + u32(1);
            woke_1 = woke_0;
            s_5 = _S468;
            continue;
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
            var _S469 : bool = bond_update_0(i_9, _S461, _S462, abs_step_1);
            if(_S469)
            {
                g_halt_0 = u32(1);
            }
            i_9 = i_9 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
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
            chunk_update_1(c_20, isl_15, rg_13, _S461, _S463, k_21, contact_island_0, &(work_3), &(work_err_2));
            c_20 = c_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S458)
        {
            integrate_rigid_1(isl_15, &(rg_13), _S461);
        }
        if(_S457)
        {
            var _S470 : vec3<f32> = isl_15.wcom_0.xyz;
            var _S471 : vec3<f32> = vec3<f32>(0.0f);
            var tu_1 : vec3<f32> = _S471;
            var pv_1 : vec3<f32> = _S471;
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
                drift_moments_0(c_21, &(tu_1), &(pv_1));
                c_21 = c_21 + u32(256);
            }
            group_sum3_0(tid_4, &(tu_1), &(pv_1));
            var tr_4 : vec3<f32> = tu_1 / vec3<f32>(isl_15.wcom_0.w);
            var dv_4 : vec3<f32> = pv_1 / vec3<f32>(isl_15.wcom_0.w);
            var lu_1 : vec3<f32> = _S471;
            var lv_1 : vec3<f32> = _S471;
            var c_22 : u32 = isl_15.range_0.x + tid_4;
            loop
            {
                if(c_22 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_22, _S470, tr_4, dv_4, &(lu_1), &(lv_1));
                c_22 = c_22 + u32(256);
            }
            group_sum3_0(tid_4, &(lu_1), &(lv_1));
            var phi_3 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lu_1);
            var dw_3 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lv_1);
            var c_23 : u32 = isl_15.range_0.x + tid_4;
            loop
            {
                if(c_23 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_23, _S470, tr_4, phi_3, dv_4, dw_3);
                c_23 = c_23 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_15, &(rg_13), tr_4, phi_3, dv_4, dw_3);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S460)
        {
            _S464 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
        }
        else
        {
            _S464 = false;
        }
        if(_S464)
        {
            record_probes_0(isl_15, rg_13, k_21);
        }
        var _S472 : u32 = s_5 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S472;
            break;
        }
        done_1 = _S472;
        var _S468 : u32 = s_5 + u32(1);
        woke_1 = woke_0;
        s_5 = _S468;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_3, work_err_2, 0.0f);
    var unused_2 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_4, &(wsum_0), &(unused_2));
    if(_S460)
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
            _S458 = contact_island_0;
        }
        else
        {
            _S458 = false;
        }
        if(_S458)
        {
            contact_split_at_0(isl_15.info_0.w + done_1);
        }
        var _S473 : f32 = wsum_0.x;
        var _S474 : f32 = isl_15.energy_0[i32(0)];
        var _S475 : f32 = isl_15.energy_0[i32(1)];
        comp_add1_2(&(_S474), &(_S475), _S473);
        isl_15.energy_0[i32(0)] = _S474;
        isl_15.energy_0[i32(1)] = _S475 + wsum_0.y;
        isl_15.info_0[i32(3)] = isl_15.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_15.info_0[i32(2)] = ((isl_15.info_0[i32(2)]) | (u32(1)));
        }
        if(woke_0)
        {
            isl_15.info_0[i32(0)] = ((isl_15.info_0[i32(0)]) & (u32(4294967279)));
            isl_15.info_0[i32(2)] = ((isl_15.info_0[i32(2)]) | (u32(4)));
        }
        islands_0[_S456].range_0 = isl_15.range_0;
        islands_0[_S456].info_0 = isl_15.info_0;
        islands_0[_S456].com_0 = isl_15.com_0;
        islands_0[_S456].inertia0_0 = isl_15.inertia0_0;
        islands_0[_S456].inertia1_0 = isl_15.inertia1_0;
        islands_0[_S456].inertia2_0 = isl_15.inertia2_0;
        islands_0[_S456].inv0_0 = isl_15.inv0_0;
        islands_0[_S456].inv1_0 = isl_15.inv1_0;
        islands_0[_S456].inv2_0 = isl_15.inv2_0;
        islands_0[_S456].wcom_0 = isl_15.wcom_0;
        islands_0[_S456].winv0_0 = isl_15.winv0_0;
        islands_0[_S456].winv1_0 = isl_15.winv1_0;
        islands_0[_S456].winv2_0 = isl_15.winv2_0;
        islands_0[_S456].rotation_0 = isl_15.rotation_0;
        islands_0[_S456].position_0 = isl_15.position_0;
        islands_0[_S456].position_err_0 = isl_15.position_err_0;
        islands_0[_S456].velocity_0 = isl_15.velocity_0;
        islands_0[_S456].velocity_err_0 = isl_15.velocity_err_0;
        islands_0[_S456].angular_velocity_0 = isl_15.angular_velocity_0;
        islands_0[_S456].done_0 = isl_15.done_0;
        islands_0[_S456].probes_0 = isl_15.probes_0;
        islands_0[_S456].energy_0 = isl_15.energy_0;
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

fn wide_group_0( table_0 : u32,  g_4 : u32) -> WideGroup_0
{
    var w_11 : WideGroup_0;
    var _S476 : u32 = table_0 + u32(4) * g_4;
    w_11.island_0 = index_0[_S476];
    w_11.begin_1 = index_0[_S476 + u32(1)];
    w_11.end_0 = index_0[_S476 + u32(2)];
    w_11.first_1 = index_0[_S476 + u32(3)];
    return w_11;
}

fn wide_runs_0( isl_16 : ptr<function, Island_std430_0>) -> bool
{
    var _S477 : vec4<u32> = (*isl_16).info_0;
    var _S478 : bool;
    if(((((*isl_16).info_0.z) & (u32(1)))) != u32(0))
    {
        _S478 = true;
    }
    else
    {
        _S478 = (_S477.y) == u32(0);
    }
    if(_S478)
    {
        return false;
    }
    if((((_S477.x) & (u32(4)))) == u32(0))
    {
        _S478 = true;
    }
    else
    {
        var _S479 : bool = contact_stopped_0(&((*isl_16)));
        _S478 = !_S479;
    }
    return _S478;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_5 : u32,  isl_17 : ptr<function, Island_std430_0>) -> bool
{
    if(tid_5 == u32(0))
    {
        var _S480 : bool = wide_runs_0(&((*isl_17)));
        var _S481 : i32;
        if(_S480)
        {
            _S481 = i32(1);
        }
        else
        {
            _S481 = i32(0);
        }
        g_wide_run_0 = u32(_S481);
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

fn contact_stopped_2( _S482 : u32) -> bool
{
    var _S483 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S484 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S484 = true;
    }
    else
    {
        var _S485 : u32 = _S483.y;
        if(_S485 != u32(0))
        {
            _S484 = _S485 <= (islands_0[_S482].info_0.w);
        }
        else
        {
            _S484 = false;
        }
    }
    return _S484;
}

fn wide_runs_1( _S486 : u32) -> bool
{
    var _S487 : vec4<u32> = islands_0[_S486].info_0;
    var _S488 : bool;
    if((((islands_0[_S486].info_0.z) & (u32(1)))) != u32(0))
    {
        _S488 = true;
    }
    else
    {
        _S488 = (_S487.y) == u32(0);
    }
    if(_S488)
    {
        return false;
    }
    if((((_S487.x) & (u32(4)))) == u32(0))
    {
        _S488 = true;
    }
    else
    {
        _S488 = !contact_stopped_2(_S486);
    }
    return _S488;
}

fn wide_enter_1( _S489 : u32,  _S490 : u32) -> bool
{
    if(_S489 == u32(0))
    {
        var _S491 : i32;
        if(wide_runs_1(_S490))
        {
            _S491 = i32(1);
        }
        else
        {
            _S491 = i32(0);
        }
        g_wide_run_0 = u32(_S491);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_wake(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_6 : u32 = thread_3.x;
    var _S492 : u32 = group_3.x;
    var wg_0 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S492);
    if(_S492 != (wg_0.first_1))
    {
        return;
    }
    var _S493 : Island_std430_0 = islands_0[wg_0.island_0];
    var _S494 : vec4<u32> = _S493.info_0;
    var _S495 : u32 = _S493.info_0.x;
    var _S496 : bool;
    if(((_S495 & (u32(16)))) == u32(0))
    {
        _S496 = true;
    }
    else
    {
        var _S497 : bool = wide_enter_1(tid_6, wg_0.island_0);
        _S496 = !_S497;
    }
    if(_S496)
    {
        return;
    }
    var _S498 : Quat_0 = quat_of_0(_S493.rotation_0);
    var _S499 : bool = ((_S495 & (u32(4)))) != u32(0);
    var _S500 : vec3<f32> = vec3<f32>(0.0f);
    var norm_1 : vec3<f32> = _S500;
    var unused_3 : vec3<f32> = _S500;
    var _S501 : vec4<u32> = _S493.range_0;
    var c_24 : u32 = _S493.range_0.x + tid_6;
    loop
    {
        if(c_24 < (_S501.y))
        {
        }
        else
        {
            break;
        }
        var _S502 : u32 = wide_step_0(&(_S493));
        var _S503 : f32 = settled_chunk_load_0(c_24, _S498, _S502, params_0.dt_0, _S499);
        norm_1[i32(0)] = norm_1[i32(0)] + _S503;
        c_24 = c_24 + u32(256);
    }
    group_sum3_0(tid_6, &(norm_1), &(unused_3));
    if(tid_6 == u32(0))
    {
        _S496 = (params_0.solve_mode_0) == u32(1);
    }
    else
    {
        _S496 = false;
    }
    if(_S496)
    {
        _S496 = (abs(norm_1.x - _S493.energy_0.z)) > (_S493.energy_0.w);
    }
    else
    {
        _S496 = false;
    }
    if(_S496)
    {
        islands_0[wg_0.island_0].info_0[i32(0)] = (_S495 & (u32(4294967279)));
        islands_0[wg_0.island_0].info_0[i32(2)] = ((_S494.z) | (u32(4)));
    }
    return;
}

fn wide_store_0( slot_2 : u32,  p_15 : u32,  a_16 : vec3<f32>,  b_35 : vec3<f32>)
{
    var _S504 : u32 = u32(8) * slot_2;
    scratch_0[params_0.wide_base_0 + _S504 + p_15] = vec4<f32>(a_16, 0.0f);
    scratch_0[params_0.wide_base_0 + _S504 + p_15 + u32(1)] = vec4<f32>(b_35, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_7 : u32 = thread_4.x;
    var _S505 : u32 = group_4.x;
    var bond_group_0 : bool = _S505 < (params_0.wide_bond_groups_0);
    var wg_1 : WideGroup_0;
    if(bond_group_0)
    {
        wg_1 = wide_group_0(params_0.wide_bond_table_0, _S505);
    }
    else
    {
        wg_1 = wide_group_0(params_0.wide_chunk_table_0, _S505 - params_0.wide_bond_groups_0);
    }
    var _S506 : WideGroup_0 = wg_1;
    var _S507 : Island_std430_0 = islands_0[wg_1.island_0];
    var _S508 : bool = wide_enter_1(tid_7, wg_1.island_0);
    if(!_S508)
    {
        return;
    }
    var _S509 : u32 = wide_step_0(&(_S507));
    if(bond_group_0)
    {
        var _S510 : vec4<u32> = _S507.info_0;
        if((((_S507.info_0.x) & (u32(16)))) != u32(0))
        {
            return;
        }
        var i_10 : u32 = wg_1.begin_1 + tid_7;
        var _S511 : bool;
        if(i_10 < (wg_1.end_0))
        {
            var _S512 : bool = bond_update_0(i_10, params_0.dt_0, (params_0.fracture_0) != u32(0), _S510.w + u32(1));
            _S511 = _S512;
        }
        else
        {
            _S511 = false;
        }
        if(_S511)
        {
            islands_0[_S506.island_0].info_0[i32(2)] = ((_S510.z) | (u32(2)));
        }
        return;
    }
    var _S513 : u32 = _S507.info_0.x;
    if(((_S513 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S514 : vec3<f32> = vec3<f32>(0.0f);
    var f_19 : vec3<f32> = _S514;
    var t_15 : vec3<f32> = _S514;
    var c_25 : u32 = wg_1.begin_1 + tid_7;
    if(c_25 < (wg_1.end_0))
    {
        var _S515 : Rigid_0 = rigid_of_0(&(_S507));
        net_load_0(c_25, &(_S507), _S515, _S509, params_0.dt_0, ((_S513 & (u32(4)))) != u32(0), &(f_19), &(t_15));
    }
    group_sum3_0(tid_7, &(f_19), &(t_15));
    if(tid_7 == u32(0))
    {
        wide_store_0(_S505 - params_0.wide_bond_groups_0, u32(0), f_19, t_15);
    }
    return;
}

fn wide_partials_0( tid_8 : u32,  first_2 : u32,  count_5 : u32,  p_16 : u32,  a_17 : ptr<function, vec3<f32>>,  b_36 : ptr<function, vec3<f32>>)
{
    var _S516 : vec4<f32> = vec4<f32>(0.0f);
    var x_10 : vec4<f32> = _S516;
    var y_2 : vec4<f32> = _S516;
    var s_6 : u32 = tid_8;
    loop
    {
        if(s_6 < count_5)
        {
        }
        else
        {
            break;
        }
        var _S517 : u32 = u32(8) * (first_2 + s_6);
        x_10 = x_10 + scratch_0[params_0.wide_base_0 + _S517 + p_16];
        y_2 = y_2 + scratch_0[params_0.wide_base_0 + _S517 + p_16 + u32(1)];
        s_6 = s_6 + u32(256);
    }
    group_sum2_0(tid_8, &(x_10), &(y_2));
    (*a_17) = x_10.xyz;
    (*b_36) = y_2.xyz;
    return;
}

fn wide_rigid_frame_0( tid_9 : u32,  isl_20 : ptr<function, Island_std430_0>,  wg_2 : WideGroup_0) -> Rigid_0
{
    var _S518 : Rigid_0 = rigid_of_0(&((*isl_20)));
    var rg_14 : Rigid_0 = _S518;
    if(((((*isl_20).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_20 : vec3<f32>;
        var t_16 : vec3<f32>;
        wide_partials_0(tid_9, wg_2.first_1, (*isl_20).done_0.z, u32(0), &(f_20), &(t_16));
        rigid_acceleration_0(&((*isl_20)), &(rg_14), f_20, t_16);
    }
    return rg_14;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_chunks(@builtin(workgroup_id) group_5 : vec3<u32>, @builtin(local_invocation_id) thread_5 : vec3<u32>)
{
    var tid_10 : u32 = thread_5.x;
    var _S519 : u32 = group_5.x;
    var wg_3 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S519);
    var _S520 : Island_std430_0 = islands_0[wg_3.island_0];
    var _S521 : bool = wide_enter_1(tid_10, wg_3.island_0);
    if(!_S521)
    {
        return;
    }
    var _S522 : u32 = _S520.info_0.x;
    var anchored_0 : bool = ((_S522 & (u32(1)))) != u32(0);
    if(((_S522 & (u32(16)))) != u32(0))
    {
        if(tid_10 == u32(0))
        {
            scratch_0[params_0.wide_base_0 + u32(8) * _S519 + u32(6)] = vec4<f32>(0.0f);
        }
        return;
    }
    var _S523 : Rigid_0 = wide_rigid_frame_0(tid_10, &(_S520), wg_3);
    var work_4 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S524 : vec3<f32> = vec3<f32>(0.0f);
    var tu_2 : vec3<f32> = _S524;
    var pv_2 : vec3<f32> = _S524;
    var c_26 : u32 = wg_3.begin_1 + tid_10;
    if(c_26 < (wg_3.end_0))
    {
        var _S525 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S526 : u32 = wide_step_0(&(_S520));
        chunk_update_0(c_26, &(_S520), _S523, params_0.dt_0, _S525, _S526, ((_S522 & (u32(4)))) != u32(0), &(work_4), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_26, &(tu_2), &(pv_2));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_4, work_err_3, 0.0f);
    var unused_4 : vec3<f32> = _S524;
    group_sum3_0(tid_10, &(wsum_1), &(unused_4));
    var _S527 : bool = !anchored_0;
    if(_S527)
    {
        group_sum3_0(tid_10, &(tu_2), &(pv_2));
    }
    if(tid_10 == u32(0))
    {
        scratch_0[params_0.wide_base_0 + u32(8) * _S519 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S527)
        {
            wide_store_0(_S519, u32(2), tu_2, pv_2);
        }
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var tid_11 : u32 = thread_6.x;
    var _S528 : u32 = group_6.x;
    var wg_4 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S528);
    var isl_21 : Island_std430_0 = islands_0[wg_4.island_0];
    var _S529 : bool;
    if((((islands_0[wg_4.island_0].info_0.x) & (u32(17)))) != u32(0))
    {
        _S529 = true;
    }
    else
    {
        var _S530 : bool = wide_enter_1(tid_11, wg_4.island_0);
        _S529 = !_S530;
    }
    if(_S529)
    {
        return;
    }
    var tu_3 : vec3<f32>;
    var pv_3 : vec3<f32>;
    wide_partials_0(tid_11, wg_4.first_1, isl_21.done_0.z, u32(2), &(tu_3), &(pv_3));
    var _S531 : vec3<f32> = vec3<f32>(isl_21.wcom_0.w);
    var tr_5 : vec3<f32> = tu_3 / _S531;
    var dv_5 : vec3<f32> = pv_3 / _S531;
    var _S532 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S532;
    var lv_2 : vec3<f32> = _S532;
    var c_27 : u32 = wg_4.begin_1 + tid_11;
    if(c_27 < (wg_4.end_0))
    {
        drift_angular_0(c_27, isl_21.wcom_0.xyz, tr_5, dv_5, &(lu_2), &(lv_2));
    }
    group_sum3_0(tid_11, &(lu_2), &(lv_2));
    if(tid_11 == u32(0))
    {
        wide_store_0(_S528, u32(4), lu_2, lv_2);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    var tid_12 : u32 = thread_7.x;
    var _S533 : u32 = group_7.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S533);
    var _S534 : Island_std430_0 = islands_0[wg_5.island_0];
    var _S535 : u32 = _S534.info_0.x;
    var _S536 : bool;
    if(((_S535 & (u32(1)))) != u32(0))
    {
        _S536 = true;
    }
    else
    {
        var _S537 : bool = wide_enter_1(tid_12, wg_5.island_0);
        _S536 = !_S537;
    }
    if(_S536)
    {
        return;
    }
    if(((_S535 & (u32(16)))) != u32(0))
    {
        if(_S533 != (wg_5.first_1))
        {
            return;
        }
        var _S538 : Rigid_0 = wide_rigid_frame_0(tid_12, &(_S534), wg_5);
        var rs_0 : Rigid_0 = _S538;
        if(tid_12 != u32(0))
        {
            _S536 = true;
        }
        else
        {
            _S536 = ((_S535 & (u32(2)))) != u32(0);
        }
        if(_S536)
        {
            return;
        }
        integrate_rigid_0(&(_S534), &(rs_0), params_0.dt_0);
        islands_0[wg_5.island_0].rotation_0 = quat_vec_0(rs_0.rot_0);
        islands_0[wg_5.island_0].position_0 = vec4<f32>(rs_0.pos_1, 0.0f);
        islands_0[wg_5.island_0].position_err_0 = vec4<f32>(rs_0.pos_err_1, 0.0f);
        islands_0[wg_5.island_0].velocity_0 = vec4<f32>(rs_0.vel_1, 0.0f);
        islands_0[wg_5.island_0].velocity_err_0 = vec4<f32>(rs_0.vel_err_1, 0.0f);
        islands_0[wg_5.island_0].angular_velocity_0 = vec4<f32>(rs_0.w_4, 0.0f);
        return;
    }
    var _S539 : u32 = _S534.done_0.z;
    var tu_4 : vec3<f32>;
    var pv_4 : vec3<f32>;
    wide_partials_0(tid_12, wg_5.first_1, _S539, u32(2), &(tu_4), &(pv_4));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_0(tid_12, wg_5.first_1, _S539, u32(4), &(lu_3), &(lv_3));
    var _S540 : vec4<f32> = _S534.wcom_0;
    var _S541 : vec3<f32> = vec3<f32>(_S534.wcom_0.w);
    var tr_6 : vec3<f32> = tu_4 / _S541;
    var dv_6 : vec3<f32> = pv_4 / _S541;
    var phi_4 : vec3<f32> = rows_mul_0(_S534.winv0_0, _S534.winv1_0, _S534.winv2_0, lu_3);
    var dw_4 : vec3<f32> = rows_mul_0(_S534.winv0_0, _S534.winv1_0, _S534.winv2_0, lv_3);
    var c_28 : u32 = wg_5.begin_1 + tid_12;
    if(c_28 < (wg_5.end_0))
    {
        drift_apply_0(c_28, _S540.xyz, tr_6, phi_4, dv_6, dw_4);
    }
    if(_S533 != (wg_5.first_1))
    {
        return;
    }
    var _S542 : Rigid_0 = wide_rigid_frame_0(tid_12, &(_S534), wg_5);
    var rg_15 : Rigid_0 = _S542;
    if(tid_12 != u32(0))
    {
        return;
    }
    if(!(((_S535 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S534), &(rg_15), params_0.dt_0);
        drift_rigid_0(&(_S534), &(rg_15), tr_6, phi_4, dv_6, dw_4);
    }
    islands_0[wg_5.island_0].rotation_0 = quat_vec_0(rg_15.rot_0);
    islands_0[wg_5.island_0].position_0 = vec4<f32>(rg_15.pos_1, 0.0f);
    islands_0[wg_5.island_0].position_err_0 = vec4<f32>(rg_15.pos_err_1, 0.0f);
    islands_0[wg_5.island_0].velocity_0 = vec4<f32>(rg_15.vel_1, 0.0f);
    islands_0[wg_5.island_0].velocity_err_0 = vec4<f32>(rg_15.vel_err_1, 0.0f);
    islands_0[wg_5.island_0].angular_velocity_0 = vec4<f32>(rg_15.w_4, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_end(@builtin(workgroup_id) group_8 : vec3<u32>, @builtin(local_invocation_id) thread_8 : vec3<u32>)
{
    var tid_13 : u32 = thread_8.x;
    var _S543 : u32 = group_8.x;
    var wg_6 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S543);
    if(_S543 != (wg_6.first_1))
    {
        return;
    }
    var _S544 : Island_std430_0 = islands_0[wg_6.island_0];
    var isl_22 : Island_0;
    isl_22.range_0 = _S544.range_0;
    isl_22.info_0 = _S544.info_0;
    isl_22.com_0 = _S544.com_0;
    isl_22.inertia0_0 = _S544.inertia0_0;
    isl_22.inertia1_0 = _S544.inertia1_0;
    isl_22.inertia2_0 = _S544.inertia2_0;
    isl_22.inv0_0 = _S544.inv0_0;
    isl_22.inv1_0 = _S544.inv1_0;
    isl_22.inv2_0 = _S544.inv2_0;
    isl_22.wcom_0 = _S544.wcom_0;
    isl_22.winv0_0 = _S544.winv0_0;
    isl_22.winv1_0 = _S544.winv1_0;
    isl_22.winv2_0 = _S544.winv2_0;
    isl_22.rotation_0 = _S544.rotation_0;
    isl_22.position_0 = _S544.position_0;
    isl_22.position_err_0 = _S544.position_err_0;
    isl_22.velocity_0 = _S544.velocity_0;
    isl_22.velocity_err_0 = _S544.velocity_err_0;
    isl_22.angular_velocity_0 = _S544.angular_velocity_0;
    isl_22.done_0 = _S544.done_0;
    isl_22.probes_0 = _S544.probes_0;
    isl_22.energy_0 = _S544.energy_0;
    var _S545 : bool = wide_enter_0(tid_13, &(_S544));
    if(!_S545)
    {
        return;
    }
    var work_5 : vec3<f32>;
    var unused_5 : vec3<f32>;
    wide_partials_0(tid_13, wg_6.first_1, isl_22.done_0.z, u32(6), &(work_5), &(unused_5));
    if(tid_13 != u32(0))
    {
        return;
    }
    var k_22 : u32 = wide_step_1(isl_22);
    if((isl_22.probes_0.y) > (isl_22.probes_0.x))
    {
        record_probes_0(isl_22, rigid_of_1(isl_22), k_22);
    }
    var halt_0 : bool = (((isl_22.info_0.z) & (u32(2)))) != u32(0);
    var _S546 : bool;
    if(halt_0)
    {
        _S546 = (((isl_22.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        _S546 = false;
    }
    if(_S546)
    {
        contact_split_at_0(isl_22.info_0.w + u32(1));
    }
    var _S547 : f32 = work_5.x;
    var _S548 : f32 = isl_22.energy_0[i32(0)];
    var _S549 : f32 = isl_22.energy_0[i32(1)];
    comp_add1_2(&(_S548), &(_S549), _S547);
    isl_22.energy_0[i32(0)] = _S548;
    isl_22.energy_0[i32(1)] = _S549 + work_5.y;
    isl_22.done_0[i32(0)] = isl_22.done_0[i32(0)] + u32(1);
    isl_22.info_0[i32(1)] = isl_22.info_0[i32(1)] - u32(1);
    isl_22.info_0[i32(3)] = isl_22.info_0[i32(3)] + u32(1);
    if(halt_0)
    {
        isl_22.info_0[i32(2)] = ((((isl_22.info_0.z) & (u32(4294967293)))) | (u32(1)));
    }
    islands_0[wg_6.island_0].range_0 = isl_22.range_0;
    islands_0[wg_6.island_0].info_0 = isl_22.info_0;
    islands_0[wg_6.island_0].com_0 = isl_22.com_0;
    islands_0[wg_6.island_0].inertia0_0 = isl_22.inertia0_0;
    islands_0[wg_6.island_0].inertia1_0 = isl_22.inertia1_0;
    islands_0[wg_6.island_0].inertia2_0 = isl_22.inertia2_0;
    islands_0[wg_6.island_0].inv0_0 = isl_22.inv0_0;
    islands_0[wg_6.island_0].inv1_0 = isl_22.inv1_0;
    islands_0[wg_6.island_0].inv2_0 = isl_22.inv2_0;
    islands_0[wg_6.island_0].wcom_0 = isl_22.wcom_0;
    islands_0[wg_6.island_0].winv0_0 = isl_22.winv0_0;
    islands_0[wg_6.island_0].winv1_0 = isl_22.winv1_0;
    islands_0[wg_6.island_0].winv2_0 = isl_22.winv2_0;
    islands_0[wg_6.island_0].rotation_0 = isl_22.rotation_0;
    islands_0[wg_6.island_0].position_0 = isl_22.position_0;
    islands_0[wg_6.island_0].position_err_0 = isl_22.position_err_0;
    islands_0[wg_6.island_0].velocity_0 = isl_22.velocity_0;
    islands_0[wg_6.island_0].velocity_err_0 = isl_22.velocity_err_0;
    islands_0[wg_6.island_0].angular_velocity_0 = isl_22.angular_velocity_0;
    islands_0[wg_6.island_0].done_0 = isl_22.done_0;
    islands_0[wg_6.island_0].probes_0 = isl_22.probes_0;
    islands_0[wg_6.island_0].energy_0 = isl_22.energy_0;
    return;
}

