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
    @align(4) statics_base_0 : u32,
    @align(16) statics_bonds_0 : u32,
    @align(4) statics_newton_0 : u32,
    @align(8) statics_cg_0 : u32,
    @align(4) statics_tol_0 : f32,
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

fn group_sum2_1( tid_1 : u32,  a_5 : ptr<function, vec4<f32>>,  b_24 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_1] = (*a_5);
    g_red_b_0[tid_1] = (*b_24);
    workgroupBarrier();
    var s_2 : u32 = u32(128);
    loop
    {
        if(s_2 > u32(0))
        {
        }
        else
        {
            break;
        }
        if(tid_1 < s_2)
        {
            var _S145 : u32 = tid_1 + s_2;
            g_red_a_0[tid_1] = g_red_a_0[tid_1] + g_red_a_0[_S145];
            g_red_b_0[tid_1] = g_red_b_0[tid_1] + g_red_b_0[_S145];
        }
        workgroupBarrier();
        s_2 = (s_2 >> (u32(1)));
    }
    (*a_5) = g_red_a_0[i32(0)];
    (*b_24) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_crush(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var ii_0 : u32 = group_0.x;
    var tid_2 : u32 = thread_0.x;
    var _S146 : bool;
    if(ii_0 >= (params_0.impactor_count_0))
    {
        _S146 = true;
    }
    else
    {
        _S146 = stopped_0();
    }
    if(_S146)
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
    var _S147 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S147;
    var unused_1 : vec4<f32> = _S147;
    var k_9 : u32 = imp_6.cand_0.x + tid_2;
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
    group_sum2_1(tid_2, &(shares_0), &(unused_1));
    if(tid_2 != u32(0))
    {
        _S146 = true;
    }
    else
    {
        _S146 = (imp_6.cand_0.z) != u32(0);
    }
    if(_S146)
    {
        return;
    }
    imp_6.geom_0 = vec4<f32>(1.0f, imp_6.crush_0.w, 0.0f, 0.0f);
    var total_1 : f32 = shares_0.x;
    if((imp_6.crush_0.x) > 0.0f)
    {
        _S146 = (imp_6.crush_0.z) < (imp_6.crush_0.y);
    }
    else
    {
        _S146 = false;
    }
    if(_S146)
    {
        _S146 = total_1 > (imp_6.crush_0.x);
    }
    else
    {
        _S146 = false;
    }
    if(_S146)
    {
        var extra_0 : f32 = (total_1 - imp_6.crush_0.x) / shares_0.y;
        imp_6.crush_0[i32(3)] = imp_6.crush_0[i32(3)] + extra_0;
        imp_6.crush_0[i32(2)] = imp_6.crush_0[i32(2)] + imp_6.crush_0.x * extra_0;
        var _S148 : f32 = imp_6.crush_0.x * extra_0;
        var _S149 : f32 = imp_6.ledger_0[i32(2)];
        var _S150 : f32 = imp_6.ledger_0[i32(3)];
        comp_add1_2(&(_S149), &(_S150), _S148);
        imp_6.ledger_0[i32(2)] = _S149;
        imp_6.ledger_0[i32(3)] = _S150;
        var _S151 : f32 = imp_6.crush_0.x * extra_0;
        var _S152 : f32 = imp_6.ledger_0[i32(0)];
        var _S153 : f32 = imp_6.ledger_0[i32(1)];
        comp_add1_2(&(_S152), &(_S153), _S151);
        imp_6.ledger_0[i32(0)] = _S152;
        imp_6.ledger_0[i32(1)] = _S153;
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
    var _S154 : vec3<f32> = abs(x_5);
    (*err_3) = (*err_3) + (select(x_5, (*sum_3), (abs((*sum_3))) >= _S154) - t_4 + select((*sum_3), x_5, (abs((*sum_3))) >= _S154));
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

fn quat_mul_0( a_6 : Quat_0,  o_0 : Quat_0) -> Quat_0
{
    var r_5 : Quat_0;
    r_5.w_0 = a_6.w_0 * o_0.w_0 - a_6.x_0 * o_0.x_0 - a_6.y_0 * o_0.y_0 - a_6.z_0 * o_0.z_0;
    r_5.x_0 = a_6.w_0 * o_0.x_0 + a_6.x_0 * o_0.w_0 + a_6.y_0 * o_0.z_0 - a_6.z_0 * o_0.y_0;
    r_5.y_0 = a_6.w_0 * o_0.y_0 - a_6.x_0 * o_0.z_0 + a_6.y_0 * o_0.w_0 + a_6.z_0 * o_0.x_0;
    r_5.z_0 = a_6.w_0 * o_0.z_0 + a_6.x_0 * o_0.y_0 - a_6.y_0 * o_0.x_0 + a_6.z_0 * o_0.w_0;
    return r_5;
}

fn normalized_0( q_12 : Quat_0) -> Quat_0
{
    var _S155 : f32 = q_12.w_0;
    var _S156 : f32 = q_12.x_0;
    var _S157 : f32 = q_12.y_0;
    var _S158 : f32 = q_12.z_0;
    var n_8 : f32 = sqrt(_S155 * _S155 + _S156 * _S156 + _S157 * _S157 + _S158 * _S158);
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
    var tid_3 : u32 = thread_1.x;
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
    var _S159 : bool;
    if((imp_7.cand_0.z) != u32(0))
    {
        _S159 = true;
    }
    else
    {
        _S159 = (((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0);
    }
    if(_S159)
    {
        _S159 = true;
    }
    else
    {
        var _S160 : u32 = islands_0[params_0.halt_index_0].info_0.y;
        if(_S160 != u32(0))
        {
            _S159 = (imp_7.cand_0.w) >= _S160;
        }
        else
        {
            _S159 = false;
        }
    }
    if(_S159)
    {
        return;
    }
    var _S161 : vec4<f32> = vec4<f32>(0.0f);
    var rf_0 : vec4<f32> = _S161;
    var rt_0 : vec4<f32> = _S161;
    var k_10 : u32 = imp_7.cand_0.x + tid_3;
    loop
    {
        if(k_10 < (imp_7.cand_0.y))
        {
        }
        else
        {
            break;
        }
        var _S162 : u32 = u32(3) * k_10;
        rf_0 = rf_0 + scratch_0[params_0.cand_base_0 + _S162 + u32(1)];
        rt_0 = rt_0 + scratch_0[params_0.cand_base_0 + _S162 + u32(2)];
        k_10 = k_10 + u32(256);
    }
    group_sum2_1(tid_3, &(rf_0), &(rt_0));
    if(tid_3 != u32(0))
    {
        return;
    }
    var dt_4 : f32 = params_0.dt_0;
    var _S163 : vec3<f32> = vec3<f32>(0.0f);
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((params_0.has_ground_0) != u32(0))
    {
        var ib_0 : Box_0 = impactor_box_0(imp_7, _S163, imp_7.half_1.xyz);
        var _S164 : vec3<f32> = imp_7.velocity_1.xyz + imp_7.velocity_err_1.xyz;
        const _S165 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var kc_2 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_7.mat_0.x, ib_0, _S165);
        var _S166 : f32 = imp_7.position_1.z - params_0.ground_hi_0 + (imp_7.position_err_1.z - params_0.ground_lo_0);
        var total_points_0 : u32;
        if((imp_7.shape_0.x) == 0.0f)
        {
            total_points_0 = u32(1);
        }
        else
        {
            total_points_0 = u32(14);
        }
        var _S167 : f32 = kc_2 / f32(min(total_points_0, u32(5)));
        var s_3 : u32 = u32(0);
        var below_0 : u32 = u32(0);
        loop
        {
            if(s_3 < total_points_0)
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
                p_10 = sample_point_0(ib_0, s_3);
            }
            if((_S166 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + u32(1);
            }
            s_3 = s_3 + u32(1);
        }
        s_3 = u32(0);
        load_f_0 = _S163;
        load_t_0 = _S163;
        loop
        {
            if(s_3 < total_points_0)
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
                p_10 = sample_point_0(ib_0, s_3);
            }
            var depth_5 : f32 = - (_S166 + p_10.z);
            if(depth_5 <= 0.0f)
            {
                s_3 = s_3 + u32(1);
                continue;
            }
            var stored_4 : f32;
            var diss_2 : f32;
            var f_3 : vec3<f32> = penalty_force_1(_S167, imp_7.mat_0.z, params_0.ground_friction_0, depth_5, _S165, _S164 + cross(imp_7.angular_velocity_1.xyz, p_10), dt_4, below_0, &(stored_4), &(diss_2));
            var load_f_1 : vec3<f32> = load_f_0 + f_3;
            var load_t_1 : vec3<f32> = load_t_0 + cross(p_10, f_3);
            var _S168 : f32 = imp_7.ledger_0[i32(0)];
            var _S169 : f32 = imp_7.ledger_0[i32(1)];
            comp_add1_2(&(_S168), &(_S169), diss_2);
            imp_7.ledger_0[i32(0)] = _S168;
            imp_7.ledger_0[i32(1)] = _S169;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_3 = s_3 + u32(1);
        }
    }
    else
    {
        load_f_0 = _S163;
        load_t_0 = _S163;
    }
    var load_f_2 : vec3<f32> = rf_0.xyz + load_f_0;
    var load_t_2 : vec3<f32> = rt_0.xyz + load_t_0;
    var m_2 : f32 = imp_7.mat_0.z;
    var vel_0 : vec3<f32> = imp_7.velocity_1.xyz;
    var vel_err_0 : vec3<f32> = imp_7.velocity_err_1.xyz;
    var _S170 : vec3<f32> = vec3<f32>(dt_4);
    comp_add_0(&(vel_0), &(vel_err_0), (load_f_2 / vec3<f32>(m_2) + params_0.gravity_0.xyz) * _S170);
    var q_15 : Quat_0 = quat_of_0(imp_7.rotation_1);
    var l_1 : vec3<f32> = world_mul_0(q_15, imp_7.inertia0_2, imp_7.inertia1_2, imp_7.inertia2_2, imp_7.angular_velocity_1.xyz) + load_t_2 * _S170;
    var w_mid_0 : vec3<f32> = world_mul_0(q_15, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_1);
    var pos_0 : vec3<f32> = imp_7.position_1.xyz;
    var pos_err_0 : vec3<f32> = imp_7.position_err_1.xyz;
    comp_add_0(&(pos_0), &(pos_err_0), (vel_0 + vel_err_0) * _S170);
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
    var b_25 : Box_0 = chunk_box_0(c_9, vec3<f32>(0.0f));
    const _S171 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S172 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_25, chunks_0[c_9].cmat_0.x, b_25, _S171);
    var _S173 : u32 = sample_count_0(b_25);
    var s_4 : u32 = u32(0);
    var n_9 : u32 = u32(0);
    loop
    {
        if(s_4 < _S173)
        {
        }
        else
        {
            break;
        }
        if((above_0 + sample_point_0(b_25, s_4).z) < 0.0f)
        {
            n_9 = n_9 + u32(1);
        }
        s_4 = s_4 + u32(1);
    }
    if(n_9 == u32(0))
    {
        return;
    }
    var vc_1 : vec3<f32>;
    var wc_1 : vec3<f32>;
    chunk_velocity_1(c_9, &(vc_1), &(wc_1));
    var ledger_2 : vec4<f32> = scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_9];
    s_4 = u32(0);
    loop
    {
        if(s_4 < _S173)
        {
        }
        else
        {
            break;
        }
        var p_11 : vec3<f32> = sample_point_0(b_25, s_4);
        var _S174 : f32 = above_0 + p_11.z;
        if(!(_S174 < 0.0f))
        {
            s_4 = s_4 + u32(1);
            continue;
        }
        var stored_5 : f32;
        var diss_3 : f32;
        var g_0 : vec3<f32> = penalty_force_1(_S172 / f32(max(n_9, u32(5))), chunks_0[c_9].center_0.w, params_0.ground_friction_0, - _S174, _S171, vc_1 + cross(wc_1, p_11), params_0.dt_0, n_9, &(stored_5), &(diss_3));
        (*f_4) = (*f_4) + g_0;
        (*t_5) = (*t_5) + cross(p_11, g_0);
        var _S175 : f32 = ledger_2[i32(1)];
        var _S176 : f32 = ledger_2[i32(2)];
        comp_add1_2(&(_S175), &(_S176), diss_3);
        ledger_2[i32(1)] = _S175;
        ledger_2[i32(2)] = _S176;
        s_4 = s_4 + u32(1);
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
    var _S177 : bool;
    if(g_1 >= (params_0.seg_count_0))
    {
        _S177 = true;
    }
    else
    {
        _S177 = stopped_0();
    }
    if(_S177)
    {
        return;
    }
    var _S178 : u32 = u32(3) * g_1;
    var _S179 : u32 = index_0[params_0.seg_index_0 + _S178];
    var begin_0 : u32 = index_0[params_0.seg_index_0 + _S178 + u32(1)];
    var _S180 : u32 = index_0[params_0.seg_index_0 + _S178 + u32(2)];
    var _S181 : vec3<f32> = vec3<f32>(0.0f);
    var f_5 : vec3<f32> = _S181;
    var t_6 : vec3<f32> = _S181;
    var e_2 : u32 = begin_0;
    loop
    {
        if(e_2 < _S180)
        {
        }
        else
        {
            break;
        }
        var entry_1 : u32 = index_0[e_2];
        if(entry_1 == u32(2147483648))
        {
            ground_contact_0(_S179, true, &(f_5), &(t_6));
            e_2 = e_2 + u32(1);
            continue;
        }
        var _S182 : u32 = u32(2) * entry_1;
        f_5 = f_5 + scratch_0[params_0.slot_base_0 + _S182].xyz;
        t_6 = t_6 + scratch_0[params_0.slot_base_0 + _S182 + u32(1)].xyz;
        e_2 = e_2 + u32(1);
    }
    var _S183 : u32 = u32(2) * g_1;
    scratch_0[params_0.seg_base_0 + _S183] = vec4<f32>(f_5, 0.0f);
    scratch_0[params_0.seg_base_0 + _S183 + u32(1)] = vec4<f32>(t_6, 0.0f);
    return;
}

fn contact_stopped_0( isl_0 : ptr<function, Island_std430_0>) -> bool
{
    var _S184 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S185 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S185 = true;
    }
    else
    {
        var _S186 : u32 = _S184.y;
        if(_S186 != u32(0))
        {
            _S185 = _S186 <= ((*isl_0).info_0.w);
        }
        else
        {
            _S185 = false;
        }
    }
    return _S185;
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
    var _S187 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S188 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S188 = true;
    }
    else
    {
        var _S189 : u32 = _S187.y;
        if(_S189 != u32(0))
        {
            _S188 = _S189 <= (isl_1.info_0.w);
        }
        else
        {
            _S188 = false;
        }
    }
    return _S188;
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
     a_7 : vec3<f32>,
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
    var _S190 : vec3<f32> = vec3<f32>(0.0f);
    rg_0.a_7 = _S190;
    rg_0.alpha_0 = _S190;
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
    var _S191 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.a_7 = _S191;
    rg_1.alpha_0 = _S191;
    return rg_1;
}

fn write_probe_0( slot_1 : u32,  k_12 : u32,  value_0 : f32)
{
    var at_4 : u32 = params_0.probe_base_0 * u32(4) + slot_1 * params_0.probe_stride_0 + k_12;
    var v_8 : vec4<f32> = scratch_0[at_4 / u32(4)];
    v_8[at_4 % u32(4)] = value_0;
    scratch_0[at_4 / u32(4)] = v_8;
    return;
}

fn record_probes_0( isl_4 : Island_0,  rg_2 : Rigid_0,  k_13 : u32)
{
    var at_5 : u32 = isl_4.probes_0.x;
    loop
    {
        if(at_5 < (isl_4.probes_0.y))
        {
        }
        else
        {
            break;
        }
        var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[at_5])));
        var a_8 : vec4<f32> = loads_0[at_5 + u32(1)];
        var b_26 : vec4<f32> = loads_0[at_5 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_5 + u32(3)];
        var kind_0 : u32 = info_2.x;
        var i_4 : u32 = info_2.y;
        var value_1 : f32;
        if(kind_0 == u32(0))
        {
            value_1 = dot(rg_2.pos_1 - b_26.xyz + (rg_2.pos_err_1 - c4_0.xyz) + rotate_0(rg_2.rot_0, chunks_0[i_4].center_0.xyz + state_0[u32(4) * i_4].xyz), a_8.xyz);
        }
        else
        {
            if(kind_0 == u32(1))
            {
                var _S192 : u32 = u32(4) * i_4;
                value_1 = dot(rg_2.vel_1 + rg_2.vel_err_1 + cross(rg_2.w_4, rotate_0(rg_2.rot_0, chunks_0[i_4].center_0.xyz + state_0[_S192].xyz - isl_4.com_0.xyz)) + rotate_0(rg_2.rot_0, state_0[_S192 + u32(2)].xyz), a_8.xyz);
            }
            else
            {
                if(kind_0 == u32(2))
                {
                    var _S193 : u32 = u32(3) * i_4;
                    var f_6 : vec3<f32> = scratch_0[_S193].xyz;
                    var _S194 : bool = (info_2.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S194)
                    {
                        mc_0 = scratch_0[_S193 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S193 + u32(2)].xyz;
                    }
                    var fc_0 : vec3<f32>;
                    if(_S194)
                    {
                        fc_0 = f_6;
                    }
                    else
                    {
                        fc_0 = (vec3<f32>(0) - f_6);
                    }
                    value_1 = dot(fc_0, a_8.xyz) + dot(mc_0, b_26.xyz);
                }
                else
                {
                    var _S195 : u32 = u32(4) * i_4;
                    value_1 = dot(rotate_0(rg_2.rot_0, vec3<f32>(state_0[_S195 + u32(1)].w, state_0[_S195 + u32(2)].w, state_0[_S195 + u32(3)].w)), a_8.xyz);
                }
            }
        }
        write_probe_0(info_2.w, k_13, value_1);
        at_5 = at_5 + u32(4);
    }
    return;
}

fn time_since_0( origin_0 : vec4<f32>,  k_14 : u32,  dt_5 : f32) -> f32
{
    return params_0.t_hi_0 - origin_0.x + (params_0.t_lo_0 - origin_0.y) + f32(k_14) * dt_5;
}

fn table_eval_0( offset_0 : u32,  count_2 : u32,  tau_0 : f32) -> f32
{
    var first_0 : vec4<f32> = loads_0[offset_0];
    if(tau_0 <= (first_0.x))
    {
        return first_0.y;
    }
    var i_5 : u32 = u32(1);
    loop
    {
        if(i_5 < count_2)
        {
        }
        else
        {
            break;
        }
        var _S196 : u32 = offset_0 + i_5;
        var b_27 : vec4<f32> = loads_0[_S196];
        var _S197 : f32 = b_27.x;
        if(tau_0 <= _S197)
        {
            var a_9 : vec4<f32> = loads_0[_S196 - u32(1)];
            var _S198 : f32 = a_9.x;
            var _S199 : f32 = a_9.y;
            return _S199 + (tau_0 - _S198) / max(_S197 - _S198, 1.00000000317107685e-30f) * (b_27.y - _S199);
        }
        i_5 = i_5 + u32(1);
    }
    return loads_0[offset_0 + count_2 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_15 : u32,  dt_6 : f32,  shift_0 : f32) -> f32
{
    var _S200 : u32 = u32(5) * term_0;
    var info_3 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S200])));
    var origin_1 : vec4<f32> = loads_0[_S200 + u32(3)];
    var p_12 : vec4<f32> = loads_0[_S200 + u32(4)];
    var kind_1 : u32 = info_3.z;
    if(kind_1 == u32(0))
    {
        return origin_1.z;
    }
    var tau_1 : f32 = time_since_0(origin_1, k_15, dt_6) + shift_0;
    var shape_1 : f32;
    if(kind_1 == u32(1))
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            var _S201 : f32 = p_12.x;
            if(tau_1 >= _S201)
            {
                shape_1 = p_12.y;
            }
            else
            {
                shape_1 = p_12.y * tau_1 / _S201;
            }
        }
        return shape_1;
    }
    var _S202 : bool;
    if(kind_1 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S202 = true;
        }
        else
        {
            _S202 = tau_1 > (p_12.x);
        }
        if(_S202)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_12.y * sin(3.14159274101257324f * tau_1 / p_12.x);
        }
        return shape_1;
    }
    if(kind_1 == u32(3))
    {
        var sn_0 : f32 = tau_1 / p_12.y;
        if(sn_0 < 0.0f)
        {
            _S202 = true;
        }
        else
        {
            _S202 = sn_0 > 1.0f;
        }
        if(_S202)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_12.x * (1.0f - sn_0) * exp(- p_12.z * sn_0);
        }
        return shape_1;
    }
    if(kind_1 == u32(4))
    {
        return table_eval_0(info_3.w, (bitcast<u32>((p_12.x))), tau_1);
    }
    if(kind_1 == u32(5))
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var sn_1 : f32 = tau_1 / p_12.x;
        if(sn_1 < 0.0f)
        {
            _S202 = true;
        }
        else
        {
            _S202 = sn_1 > 1.0f;
        }
        if(_S202)
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
        var _S203 : f32 = p_12.w;
        return (_S203 + (p_12.z - _S203) * relax_0) * shape_1;
    }
    if(kind_1 == u32(7))
    {
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var _S204 : f32 = p_12.y;
        if(tau_1 < _S204)
        {
            return p_12.x;
        }
        var s_5 : f32 = tau_1 - _S204;
        var _S205 : f32 = p_12.w;
        if(s_5 > _S205)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_12.z * sin(3.14159274101257324f * s_5 / _S205);
        }
        return shape_1;
    }
    var _S206 : f32 = p_12.x;
    if(_S206 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S206, 0.0f, 1.0f);
}

fn record_chunk_load_0( c_10 : u32,  f_7 : vec3<f32>,  t_7 : vec3<f32>)
{
    if((params_0.solve_mode_0) == u32(0))
    {
        return;
    }
    var _S207 : u32 = u32(2) * c_10;
    scratch_0[params_0.cload_base_0 + _S207] = vec4<f32>(f_7, 0.0f);
    scratch_0[params_0.cload_base_0 + _S207 + u32(1)] = vec4<f32>(t_7, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S207] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S207].xyz + f_7, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S207 + u32(1)] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S207 + u32(1)].xyz + t_7, 0.0f);
    return;
}

fn chunk_external_0( _S208 : u32,  _S209 : u32,  _S210 : Quat_0,  _S211 : u32,  _S212 : f32,  _S213 : bool,  _S214 : ptr<function, vec3<f32>>,  _S215 : ptr<function, vec3<f32>>)
{
    var _S216 : bool;
    var _S217 : vec3<f32> = vec3<f32>(0.0f);
    (*_S214) = _S217;
    (*_S215) = _S217;
    var _S218 : vec4<u32> = chunks_0[_S209].load_range_0;
    var term_1 : u32 = chunks_0[_S209].load_range_0.x;
    loop
    {
        if(term_1 < (_S218.y))
        {
        }
        else
        {
            break;
        }
        var _S219 : u32 = u32(5) * term_1;
        var _S220 : u32 = (bitcast<vec4<u32>>((loads_0[_S219]))).y;
        if(_S220 == u32(2))
        {
            term_1 = term_1 + u32(1);
            continue;
        }
        var dir_1 : vec4<f32> = loads_0[_S219 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S219 + u32(2)];
        var value_2 : f32 = eval_function_0(term_1, _S211, _S212, 0.0f);
        if(_S220 == u32(0))
        {
            _S216 = true;
        }
        else
        {
            _S216 = _S220 == u32(3);
        }
        var fw_0 : vec3<f32>;
        if(_S216)
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_2);
        }
        else
        {
            fw_0 = rotate_0(_S210, dir_1.xyz) * vec3<f32>((- value_2 * dir_1.w));
        }
        var lever_0 : vec3<f32>;
        if(_S220 == u32(3))
        {
            lever_0 = arm_0.xyz - state_0[u32(4) * _S208].xyz;
        }
        else
        {
            lever_0 = arm_0.xyz;
        }
        (*_S214) = (*_S214) + fw_0;
        (*_S215) = (*_S215) + cross(rotate_0(_S210, lever_0), fw_0);
        term_1 = term_1 + u32(1);
    }
    if(_S213)
    {
        _S216 = (chunks_0[_S209].cinfo_0.z) != u32(0);
    }
    else
    {
        _S216 = false;
    }
    if(_S216)
    {
        var _S221 : vec4<u32> = chunks_0[_S209].cinfo_0;
        var g_2 : u32 = chunks_0[_S209].cinfo_0.x;
        loop
        {
            if(g_2 < (_S221.y))
            {
            }
            else
            {
                break;
            }
            var _S222 : u32 = u32(2) * g_2;
            (*_S214) = (*_S214) + scratch_0[params_0.seg_base_0 + _S222].xyz;
            (*_S215) = (*_S215) + scratch_0[params_0.seg_base_0 + _S222 + u32(1)].xyz;
            g_2 = g_2 + u32(1);
        }
    }
    return;
}

fn settled_chunk_load_0( c_11 : u32,  rot_1 : Quat_0,  k_16 : u32,  dt_7 : f32,  contact_0 : bool) -> f32
{
    var f_8 : vec3<f32>;
    var t_8 : vec3<f32>;
    chunk_external_0(c_11, c_11, rot_1, k_16, dt_7, contact_0, &(f_8), &(t_8));
    record_chunk_load_0(c_11, f_8, t_8);
    return length(f_8);
}

fn group_sum3_0( tid_4 : u32,  a_10 : ptr<function, vec3<f32>>,  b_28 : ptr<function, vec3<f32>>)
{
    var x_6 : vec4<f32> = vec4<f32>((*a_10), 0.0f);
    var y_1 : vec4<f32> = vec4<f32>((*b_28), 0.0f);
    group_sum2_1(tid_4, &(x_6), &(y_1));
    (*a_10) = x_6.xyz;
    (*b_28) = y_1.xyz;
    return;
}

fn chunk_external_1( _S223 : u32,  _S224 : u32,  _S225 : Quat_0,  _S226 : u32,  _S227 : f32,  _S228 : bool,  _S229 : ptr<function, vec3<f32>>,  _S230 : ptr<function, vec3<f32>>)
{
    var _S231 : bool;
    var _S232 : vec3<f32> = vec3<f32>(0.0f);
    (*_S229) = _S232;
    (*_S230) = _S232;
    var _S233 : vec4<u32> = chunks_0[_S224].load_range_0;
    var term_2 : u32 = chunks_0[_S224].load_range_0.x;
    loop
    {
        if(term_2 < (_S233.y))
        {
        }
        else
        {
            break;
        }
        var _S234 : u32 = u32(5) * term_2;
        var _S235 : u32 = (bitcast<vec4<u32>>((loads_0[_S234]))).y;
        if(_S235 == u32(2))
        {
            term_2 = term_2 + u32(1);
            continue;
        }
        var dir_2 : vec4<f32> = loads_0[_S234 + u32(1)];
        var arm_1 : vec4<f32> = loads_0[_S234 + u32(2)];
        var value_3 : f32 = eval_function_0(term_2, _S226, _S227, 0.0f);
        if(_S235 == u32(0))
        {
            _S231 = true;
        }
        else
        {
            _S231 = _S235 == u32(3);
        }
        var fw_1 : vec3<f32>;
        if(_S231)
        {
            fw_1 = dir_2.xyz * vec3<f32>(value_3);
        }
        else
        {
            fw_1 = rotate_0(_S225, dir_2.xyz) * vec3<f32>((- value_3 * dir_2.w));
        }
        var lever_1 : vec3<f32>;
        if(_S235 == u32(3))
        {
            lever_1 = arm_1.xyz - state_0[u32(4) * _S223].xyz;
        }
        else
        {
            lever_1 = arm_1.xyz;
        }
        (*_S229) = (*_S229) + fw_1;
        (*_S230) = (*_S230) + cross(rotate_0(_S225, lever_1), fw_1);
        term_2 = term_2 + u32(1);
    }
    if(_S228)
    {
        _S231 = (chunks_0[_S224].cinfo_0.z) != u32(0);
    }
    else
    {
        _S231 = false;
    }
    if(_S231)
    {
        var _S236 : vec4<u32> = chunks_0[_S224].cinfo_0;
        var g_3 : u32 = chunks_0[_S224].cinfo_0.x;
        loop
        {
            if(g_3 < (_S236.y))
            {
            }
            else
            {
                break;
            }
            var _S237 : u32 = u32(2) * g_3;
            (*_S229) = (*_S229) + scratch_0[params_0.seg_base_0 + _S237].xyz;
            (*_S230) = (*_S230) + scratch_0[params_0.seg_base_0 + _S237 + u32(1)].xyz;
            g_3 = g_3 + u32(1);
        }
    }
    return;
}

fn net_load_0( c_12 : u32,  isl_5 : ptr<function, Island_std430_0>,  rg_3 : Rigid_0,  k_17 : u32,  dt_8 : f32,  contact_1 : bool,  f_9 : ptr<function, vec3<f32>>,  t_9 : ptr<function, vec3<f32>>)
{
    var fl_0 : vec3<f32>;
    var tl_0 : vec3<f32>;
    chunk_external_1(c_12, c_12, rg_3.rot_0, k_17, dt_8, contact_1, &(fl_0), &(tl_0));
    var fc_1 : vec3<f32> = fl_0 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_12].center_0.w);
    var _S238 : vec3<f32> = chunks_0[c_12].center_0.xyz;
    var _S239 : vec3<f32> = (*isl_5).com_0.xyz;
    var r_7 : vec3<f32> = rotate_0(rg_3.rot_0, _S238 + state_0[u32(4) * c_12].xyz - _S239);
    (*f_9) = (*f_9) + fc_1;
    (*t_9) = (*t_9) + (cross(r_7, fc_1) + tl_0);
    var _S240 : vec4<u32> = chunks_0[c_12].load_range_0;
    var term_3 : u32 = chunks_0[c_12].load_range_0.x;
    loop
    {
        if(term_3 < (_S240.y))
        {
        }
        else
        {
            break;
        }
        var _S241 : u32 = u32(5) * term_3;
        if(((bitcast<vec4<u32>>((loads_0[_S241]))).y) != u32(2))
        {
            term_3 = term_3 + u32(1);
            continue;
        }
        var _S242 : vec3<f32> = vec3<f32>(eval_function_0(term_3, k_17, dt_8, 0.0f));
        var fw_2 : vec3<f32> = rotate_0(rg_3.rot_0, loads_0[_S241 + u32(1)].xyz * _S242);
        (*f_9) = (*f_9) + fw_2;
        (*t_9) = (*t_9) + (cross(rotate_0(rg_3.rot_0, _S238 - _S239), fw_2) + rotate_0(rg_3.rot_0, loads_0[_S241 + u32(2)].xyz * _S242));
        term_3 = term_3 + u32(1);
    }
    return;
}

fn net_load_1( c_13 : u32,  isl_6 : Island_0,  rg_4 : Rigid_0,  k_18 : u32,  dt_9 : f32,  contact_2 : bool,  f_10 : ptr<function, vec3<f32>>,  t_10 : ptr<function, vec3<f32>>)
{
    var fl_1 : vec3<f32>;
    var tl_1 : vec3<f32>;
    chunk_external_1(c_13, c_13, rg_4.rot_0, k_18, dt_9, contact_2, &(fl_1), &(tl_1));
    var fc_2 : vec3<f32> = fl_1 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_13].center_0.w);
    var _S243 : vec3<f32> = chunks_0[c_13].center_0.xyz;
    var _S244 : vec3<f32> = isl_6.com_0.xyz;
    var r_8 : vec3<f32> = rotate_0(rg_4.rot_0, _S243 + state_0[u32(4) * c_13].xyz - _S244);
    (*f_10) = (*f_10) + fc_2;
    (*t_10) = (*t_10) + (cross(r_8, fc_2) + tl_1);
    var _S245 : vec4<u32> = chunks_0[c_13].load_range_0;
    var term_4 : u32 = chunks_0[c_13].load_range_0.x;
    loop
    {
        if(term_4 < (_S245.y))
        {
        }
        else
        {
            break;
        }
        var _S246 : u32 = u32(5) * term_4;
        if(((bitcast<vec4<u32>>((loads_0[_S246]))).y) != u32(2))
        {
            term_4 = term_4 + u32(1);
            continue;
        }
        var _S247 : vec3<f32> = vec3<f32>(eval_function_0(term_4, k_18, dt_9, 0.0f));
        var fw_3 : vec3<f32> = rotate_0(rg_4.rot_0, loads_0[_S246 + u32(1)].xyz * _S247);
        (*f_10) = (*f_10) + fw_3;
        (*t_10) = (*t_10) + (cross(rotate_0(rg_4.rot_0, _S243 - _S244), fw_3) + rotate_0(rg_4.rot_0, loads_0[_S246 + u32(2)].xyz * _S247));
        term_4 = term_4 + u32(1);
    }
    return;
}

fn rigid_acceleration_0( isl_7 : ptr<function, Island_std430_0>,  rg_5 : ptr<function, Rigid_0>,  f_11 : vec3<f32>,  t_11 : vec3<f32>)
{
    var iw_w_0 : vec3<f32> = world_mul_0((*rg_5).rot_0, (*isl_7).inertia0_0, (*isl_7).inertia1_0, (*isl_7).inertia2_0, (*rg_5).w_4);
    (*rg_5).a_7 = f_11 / vec3<f32>((*isl_7).com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_0, (*isl_7).inv0_0, (*isl_7).inv1_0, (*isl_7).inv2_0, t_11 - cross((*rg_5).w_4, iw_w_0));
    return;
}

fn rigid_acceleration_1( isl_8 : Island_0,  rg_6 : ptr<function, Rigid_0>,  f_12 : vec3<f32>,  t_12 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_6).rot_0, isl_8.inertia0_0, isl_8.inertia1_0, isl_8.inertia2_0, (*rg_6).w_4);
    (*rg_6).a_7 = f_12 / vec3<f32>(isl_8.com_0.w);
    (*rg_6).alpha_0 = world_mul_0((*rg_6).rot_0, isl_8.inv0_0, isl_8.inv1_0, isl_8.inv2_0, t_12 - cross((*rg_6).w_4, iw_w_1));
    return;
}

fn integrate_rigid_0( isl_9 : ptr<function, Island_std430_0>,  rg_7 : ptr<function, Rigid_0>,  dt_10 : f32)
{
    var iw_w_2 : vec3<f32> = world_mul_0((*rg_7).rot_0, (*isl_9).inertia0_0, (*isl_9).inertia1_0, (*isl_9).inertia2_0, (*rg_7).w_4);
    var _S248 : vec3<f32> = vec3<f32>(dt_10);
    var l_2 : vec3<f32> = iw_w_2 + (world_mul_0((*rg_7).rot_0, (*isl_9).inertia0_0, (*isl_9).inertia1_0, (*isl_9).inertia2_0, (*rg_7).alpha_0) + cross((*rg_7).w_4, iw_w_2)) * _S248;
    var _S249 : vec3<f32> = (*rg_7).a_7 * _S248;
    var _S250 : vec3<f32> = (*rg_7).vel_1;
    var _S251 : vec3<f32> = (*rg_7).vel_err_1;
    comp_add_0(&(_S250), &(_S251), _S249);
    (*rg_7).vel_1 = _S250;
    (*rg_7).vel_err_1 = _S251;
    var _S252 : vec4<f32> = (*isl_9).inv0_0;
    var _S253 : vec4<f32> = (*isl_9).inv1_0;
    var _S254 : vec4<f32> = (*isl_9).inv2_0;
    var rot1_0 : Quat_0 = integrate_rotation_0((*rg_7).rot_0, world_mul_0((*rg_7).rot_0, (*isl_9).inv0_0, (*isl_9).inv1_0, (*isl_9).inv2_0, l_2), dt_10);
    var _S255 : vec3<f32> = (*isl_9).com_0.xyz;
    var delta_0 : vec3<f32> = (_S250 + _S251) * _S248 + (rotate_0((*rg_7).rot_0, _S255) - rotate_0(rot1_0, _S255));
    var _S256 : vec3<f32> = (*rg_7).pos_1;
    var _S257 : vec3<f32> = (*rg_7).pos_err_1;
    comp_add_0(&(_S256), &(_S257), delta_0);
    (*rg_7).pos_1 = _S256;
    (*rg_7).pos_err_1 = _S257;
    (*rg_7).rot_0 = rot1_0;
    (*rg_7).w_4 = world_mul_0(rot1_0, _S252, _S253, _S254, l_2);
    return;
}

fn integrate_rigid_1( isl_10 : Island_0,  rg_8 : ptr<function, Rigid_0>,  dt_11 : f32)
{
    var iw_w_3 : vec3<f32> = world_mul_0((*rg_8).rot_0, isl_10.inertia0_0, isl_10.inertia1_0, isl_10.inertia2_0, (*rg_8).w_4);
    var _S258 : vec3<f32> = vec3<f32>(dt_11);
    var l_3 : vec3<f32> = iw_w_3 + (world_mul_0((*rg_8).rot_0, isl_10.inertia0_0, isl_10.inertia1_0, isl_10.inertia2_0, (*rg_8).alpha_0) + cross((*rg_8).w_4, iw_w_3)) * _S258;
    var _S259 : vec3<f32> = (*rg_8).a_7 * _S258;
    var _S260 : vec3<f32> = (*rg_8).vel_1;
    var _S261 : vec3<f32> = (*rg_8).vel_err_1;
    comp_add_0(&(_S260), &(_S261), _S259);
    (*rg_8).vel_1 = _S260;
    (*rg_8).vel_err_1 = _S261;
    var rot1_1 : Quat_0 = integrate_rotation_0((*rg_8).rot_0, world_mul_0((*rg_8).rot_0, isl_10.inv0_0, isl_10.inv1_0, isl_10.inv2_0, l_3), dt_11);
    var _S262 : vec3<f32> = isl_10.com_0.xyz;
    var delta_1 : vec3<f32> = (_S260 + _S261) * _S258 + (rotate_0((*rg_8).rot_0, _S262) - rotate_0(rot1_1, _S262));
    var _S263 : vec3<f32> = (*rg_8).pos_1;
    var _S264 : vec3<f32> = (*rg_8).pos_err_1;
    comp_add_0(&(_S263), &(_S264), delta_1);
    (*rg_8).pos_1 = _S263;
    (*rg_8).pos_err_1 = _S264;
    (*rg_8).rot_0 = rot1_1;
    (*rg_8).w_4 = world_mul_0(rot1_1, isl_10.inv0_0, isl_10.inv1_0, isl_10.inv2_0, l_3);
    return;
}

fn connected_0( st_0 : ptr<function, JointState_std430_0>,  has_rebar_0 : bool) -> bool
{
    var _S265 : bool;
    if(((*st_0).damage_0) < 1.0f)
    {
        _S265 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S265 = ((*st_0).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S265 = false;
        }
    }
    return _S265;
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

fn connected_1( st_1 : JointState_0,  has_rebar_1 : bool) -> bool
{
    var _S266 : bool;
    if((st_1.damage_0) < 1.0f)
    {
        _S266 = true;
    }
    else
    {
        if(has_rebar_1)
        {
            _S266 = (st_1.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S266 = false;
        }
    }
    return _S266;
}

fn fdiv_0( a_11 : f32,  b_29 : f32) -> f32
{
    return a_11 / b_29;
}

fn fsqrt_0( a_12 : f32) -> f32
{
    return sqrt(a_12);
}

struct Measures_0
{
     tension_0 : f32,
     shear_0 : f32,
     normal_compression_0 : f32,
     compression_0 : f32,
     compressive_force_0 : f32,
};

fn stress_measures_0( b_30 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_2 : f32 = (*b_30).geom0_0.x;
    var _S267 : f32 = q_lin_0.z;
    var axial_0 : f32 = fdiv_0(_S267, area_2);
    var bending_0 : f32 = fdiv_0(abs(q_ang_0.x), (*b_30).geom1_0.x) + fdiv_0(abs(q_ang_0.y), (*b_30).geom1_0.y);
    var _S268 : f32 = q_lin_0.x;
    var _S269 : f32 = q_lin_0.y;
    var shear_1 : f32 = fdiv_0(fsqrt_0(_S268 * _S268 + _S269 * _S269), area_2) + fdiv_0(abs(q_ang_0.z), (*b_30).geom0_0.w);
    var m_3 : Measures_0;
    m_3.tension_0 = axial_0 + bending_0;
    m_3.shear_0 = shear_1;
    var _S270 : f32 = - axial_0;
    m_3.normal_compression_0 = max(_S270, 0.0f);
    m_3.compression_0 = _S270 + bending_0;
    m_3.compressive_force_0 = max(- _S267, 0.0f);
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

fn fpow_0( a_13 : f32,  b_31 : f32) -> f32
{
    return pow(a_13, b_31);
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_9 : f32 = abs(strain_rate_1);
    var _S271 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_9 <= ref_0)
    {
        return 1.0f;
    }
    var _S272 : f32 = _S271.z;
    var f_13 : f32;
    if(r_9 <= _S272)
    {
        f_13 = fpow_0(fdiv_0(r_9, ref_0), _S271.y);
    }
    else
    {
        f_13 = fpow_0(fdiv_0(_S272, ref_0), _S271.y) * fpow_0(fdiv_0(r_9, _S272), _S271.w);
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

fn failure_indices_0( mat_4 : ptr<function, JointMaterial_std140_0>,  b_32 : ptr<function, JointBond_std430_0>,  m_4 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_3 : f32 = (*mat_4).strength_0.y * multiplier_0;
    var _S273 : f32 = min((*mat_4).strength_0.z * multiplier_0 + (*mat_4).strength_0.w * m_4.normal_compression_0, (*mat_4).energy_1.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(fdiv_0(m_4.tension_0, (*mat_4).strength_0.x * multiplier_0), 0.0f);
    var _S274 : f32;
    if(_S273 > 0.0f)
    {
        _S274 = fdiv_0(m_4.shear_0, _S273);
    }
    else
    {
        _S274 = infinity_0();
    }
    idx_0[i32(1)] = _S274;
    idx_0[i32(2)] = max(fdiv_0(m_4.compression_0, fc_3), 0.0f);
    var _S275 : f32 = (*b_32).stiff1_0.y;
    if(_S275 > 0.0f)
    {
        _S274 = fdiv_0(m_4.compressive_force_0, _S275);
    }
    else
    {
        _S274 = 0.0f;
    }
    idx_0[i32(3)] = _S274;
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
    var _S276 : f32 = max(damage_law_0(kind_3, lambda_0, r_11), d_old_0);
    var _S277 : bool;
    if(_S276 <= d_old_0)
    {
        _S277 = true;
    }
    else
    {
        _S277 = d_old_0 >= 1.0f;
    }
    if(_S277)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = fdiv_0(psi_0, lambda_0 * lambda_0);
    var _S278 : f32 = max(kappa_old_0, 1.0f);
    if(kind_3 == u32(0))
    {
        if(r_11 > 1.0f)
        {
            return vec2<f32>(_S276, fdiv_0(u0_0 * r_11, r_11 - 1.0f) * max(min(lambda_0, r_11) - min(_S278, r_11), 0.0f));
        }
        return vec2<f32>(_S276, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_11 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S278, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S276 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S276, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_3 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S279 : f32 = - h0_0;
    var _S280 : f32 = - h1_0;
    var _S281 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S279, _S280), vec2<f32>(h0_0, _S280), vec2<f32>(h0_0, h1_0), vec2<f32>(_S279, h1_0) );
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
        var _S282 : u32 = i_6;
        var _S283 : u32 = i_6 + u32(1);
        var _S284 : u32 = _S283 % u32(4);
        var _S285 : f32 = _S281[i_6].y;
        var _S286 : f32 = _S281[i_6].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S285 - ay_0 * _S286;
        var _S287 : f32 = _S281[_S284].y;
        var _S288 : f32 = _S281[_S284].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S287 - ay_0 * _S288;
        var _S289 : bool = fp_0 < 0.0f;
        if(_S289)
        {
            var _S290 : u32 = count_4 + u32(1);
            poly_0[count_4] = _S281[_S282];
            count_3 = _S290;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S289 != (fq_0 < 0.0f))
        {
            var t_13 : f32 = fp_0 / (fp_0 - fq_0);
            var _S291 : u32 = count_3 + u32(1);
            poly_0[count_3] = vec2<f32>(_S286 + t_13 * (_S288 - _S286), _S285 + t_13 * (_S287 - _S285));
            count_4 = _S291;
        }
        else
        {
            count_4 = count_3;
        }
        i_6 = _S283;
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
    var a_14 : f32 = 0.0f;
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
        var _S292 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_6].x - _S292;
        var _S293 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_6].y - _S293;
        var _S294 : u32 = i_6 + u32(1);
        var _S295 : u32 = _S294 % count_4;
        var x1_0 : f32 = poly_0[_S295].x - _S292;
        var y1_0 : f32 = poly_0[_S295].y - _S293;
        var _S296 : f32 = x0_0 * y1_0;
        var _S297 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S296 - _S297;
        var a_15 : f32 = a_14 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S296 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S297) * cr_0 / 24.0f;
        i_6 = _S294;
        a_14 = a_15;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_14 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_14;
    var cy_0 : f32 = sy_0 / a_14;
    (*region_0)[i32(0)] = a_14;
    (*region_0)[i32(1)] = o_1.x + cx_0;
    (*region_0)[i32(2)] = o_1.y + cy_0;
    var _S298 : f32 = a_14 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S298 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_14 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S298 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_12 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_12));
    var a_16 : f32 = r_12[i32(0)];
    if((r_12[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_19 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_4 : f32 = dz_1 + ax_1 * r_12[i32(2)] - ay_1 * r_12[i32(1)];
    var _S299 : f32 = a_16 * fc_4;
    var _S300 : f32 = - ay_1;
    return vec4<f32>(k_19 * a_16 * fc_4, k_19 * (_S299 * r_12[i32(2)] + (_S300 * r_12[i32(5)] + ax_1 * r_12[i32(4)])), - k_19 * (_S299 * r_12[i32(1)] + (_S300 * r_12[i32(3)] + ax_1 * r_12[i32(5)])), 0.5f * k_19 * (_S299 * fc_4 + ay_1 * ay_1 * r_12[i32(3)] + ax_1 * ax_1 * r_12[i32(4)] - 2.0f * ax_1 * ay_1 * r_12[i32(5)]));
}

fn signum_0( x_9 : f32) -> f32
{
    var _S301 : f32;
    if((((bitcast<u32>((x_9))) & (u32(2147483648)))) != u32(0))
    {
        _S301 = -1.0f;
    }
    else
    {
        _S301 = 1.0f;
    }
    return _S301;
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

fn contact_part_0( mat_5 : ptr<function, JointMaterial_std140_0>,  b_33 : ptr<function, JointBond_std430_0>,  crush_2 : f32,  plastic_2 : vec3<f32>,  d_lin_0 : vec3<f32>,  d_ang_0 : vec3<f32>) -> Contact_0
{
    var c_14 : Contact_0;
    var _S302 : vec3<f32> = vec3<f32>(0.0f);
    c_14.q_lin_1 = _S302;
    c_14.q_ang_1 = _S302;
    c_14.energy_2 = 0.0f;
    c_14.diss_4 = 0.0f;
    c_14.plastic_1 = plastic_2;
    var _S303 : u32 = (*mat_5).kind_flags_0.y;
    if(((_S303 & (u32(2)))) == u32(0))
    {
        return c_14;
    }
    var kn_1 : f32 = (*b_33).stiff0_0.x;
    var ks_0 : f32 = (*b_33).stiff0_0.y;
    var kt_0 : f32 = (*b_33).stiff1_0.x;
    var w0_2 : f32 = (*b_33).geom0_0.y;
    var w1_2 : f32 = (*b_33).geom0_0.z;
    var diss_5 : f32;
    var nc_sum_0 : f32;
    var m1_0 : f32;
    var m2_0 : f32;
    var energy_3 : f32;
    if(((_S303 & (u32(4)))) != u32(0))
    {
        var p_13 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S304 : f32 = p_13.y;
        var _S305 : f32 = p_13.z;
        var _S306 : f32 = p_13.w;
        nc_sum_0 = p_13.x;
        m1_0 = _S304;
        m2_0 = _S305;
        energy_3 = _S306;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S307 : f32 = d_ang_0.x;
        var _S308 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S307) * 0.4166666567325592f * w1_2 + abs(_S308) * 0.4166666567325592f * w0_2;
        var _S309 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S309) + spread_0);
        if((_S309 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S309 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S310 : f32 = ki_0 * _S307 * i2_0;
                var _S311 : f32 = ki_0 * _S308 * i1_0;
                var _S312 : f32 = 0.5f * ki_0 * (36.0f * _S309 * _S309 + _S307 * _S307 * i2_0 + _S308 * _S308 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S309;
                m1_0 = _S310;
                m2_0 = _S311;
                energy_3 = _S312;
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
                    var _S313 : f32 = ((f32(i_7) + 0.5f) / 6.0f - 0.5f) * w0_2;
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
                        var di_0 : f32 = _S309 + _S307 * s2_0 - _S308 * _S313;
                        if(di_0 < 0.0f)
                        {
                            var f_15 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_15 * s2_0;
                            var m2_2 : f32 = m2_0 - f_15 * _S313;
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
    var _S314 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S315 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var tn_0 : f32 = fsqrt_0(_S314 * _S314 + _S315 * _S315);
    var _S316 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S316 = tn_0 > 0.0f;
    }
    else
    {
        _S316 = false;
    }
    if(_S316)
    {
        var _S317 : f32 = fdiv_0(_S314, tn_0);
        var _S318 : f32 = fdiv_0(_S315, tn_0);
        var dslip_0 : f32 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        p_14[i32(0)] = p_14[i32(0)] + _S317 * dslip_0;
        p_14[i32(1)] = p_14[i32(1)] + _S318 * dslip_0;
        c_14.q_lin_1[i32(0)] = _S317 * slide_cap_0;
        c_14.q_lin_1[i32(1)] = _S318 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_14.q_lin_1[i32(0)] = _S314;
        c_14.q_lin_1[i32(1)] = _S315;
        diss_5 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_14.z, slide_cap_0 * (*b_33).geom1_0.z);
    var _S319 : f32 = tq_0.x;
    var _S320 : f32 = tq_0.y;
    var diss_6 : f32 = diss_5 + abs(_S319) * abs(_S320);
    p_14[i32(2)] = p_14[i32(2)] + _S320;
    c_14.q_ang_1[i32(2)] = _S319;
    c_14.energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0(c_14.q_lin_1.x), ks_0) + fdiv_0(sq_0(c_14.q_lin_1.y), ks_0) + fdiv_0(sq_0(_S319), kt_0));
    c_14.diss_4 = diss_6;
    c_14.plastic_1 = p_14;
    return c_14;
}

fn life_rate_0( mat_6 : ptr<function, JointMaterial_std140_0>,  s_6 : f32) -> f32
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    var _S321 : f32 = (*mat_6).misc_0.y;
    return fdiv_0((_S321 + 1.0f) * fpow_0(s_6, _S321), (*mat_6).misc_0.z);
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

fn joint_evaluate_0( mat_7 : ptr<function, JointMaterial_std140_0>,  b_34 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>,  dt_12 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_2 : f32 = (*b_34).stiff0_0.x;
    var ks_1 : f32 = (*b_34).stiff0_0.y;
    var kb1_0 : f32 = (*b_34).stiff0_0.z;
    var kb2_0 : f32 = (*b_34).stiff0_0.w;
    var _S322 : vec4<f32> = (*b_34).stiff1_0;
    var kt_1 : f32 = (*b_34).stiff1_0.x;
    var has_rebar_2 : bool = ((*b_34).stiff1_0.w) != 0.0f;
    var kind_4 : u32 = (*mat_7).kind_flags_0.x;
    var flags_1 : u32 = (*mat_7).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_2 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_1(state_2, has_rebar_2);
    var qe_lin_0 : vec3<f32> = d_lin_1 * vec3<f32>(ks_1, ks_1, kn_2);
    var qe_ang_0 : vec3<f32> = d_ang_1 * vec3<f32>(kb1_0, kb2_0, kt_1);
    var _S323 : Measures_0 = stress_measures_0(&((*b_34)), qe_lin_0, qe_ang_0);
    var _S324 : f32 = max(max(_S323.tension_0, _S323.shear_0), _S323.compression_0);
    var _S325 : bool = dt_12 > 0.0f;
    var dif_1 : f32;
    if(_S325)
    {
        var raw_0 : f32 = fdiv_0(max(fdiv_0(_S324 - st_2.governing_stress_0, dt_12), 0.0f), (*mat_7).misc_0.w);
        var tau_2 : f32 = _S322.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_12, tau_2));
        }
        else
        {
            dif_1 = min(fdiv_0(dt_12, tau_2), 1.0f);
        }
        st_2.strain_rate_0 = st_2.strain_rate_0 + (raw_0 - st_2.strain_rate_0) * dif_1;
        st_2.governing_stress_0 = _S324;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S326 : f32 = dif_factor_0(&((*mat_7)), st_2.strain_rate_0);
        dif_1 = _S326;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_34).geom1_0.w;
    var _S327 : f32 = weibull_0 * dif_1;
    var _S328 : f32 = fatigue_factor_1(&((*mat_7)), st_2.fatigue_0);
    var multiplier_1 : f32 = _S327 * _S328;
    var _S329 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_34)), _S323, multiplier_1);
    var _S330 : f32 = _S329.x;
    var _S331 : f32 = _S329.y;
    st_2.utilization_0 = max(max(_S330, _S331), max(_S329.z, _S329.w));
    var _S332 : f32 = d_lin_1.x;
    var _S333 : f32 = d_lin_1.y;
    var _S334 : f32 = ks_1 * (sq_0(_S332) + sq_0(_S333)) + kb1_0 * sq_0(d_ang_1.x) + kb2_0 * sq_0(d_ang_1.y) + kt_1 * sq_0(d_ang_1.z);
    var _S335 : f32 = d_lin_1.z;
    var _S336 : bool = _S335 > 0.0f;
    if(_S336)
    {
        dif_1 = kn_2 * sq_0(_S335);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S334 + dif_1);
    var psi_c_0 : f32;
    if(_S335 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_2 * sq_0(_S335);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    var plastic_3 : vec3<f32> = vec3<f32>(st_2.plastic_x_0, st_2.plastic_y_0, st_2.plastic_t_0);
    var diss_contact_0 : f32;
    var psi_contact_0 : f32;
    var intact_normal_0 : f32;
    var dissipated_4 : f32;
    var overshoot_1 : f32;
    var _S337 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S338 : bool = _S330 >= _S331;
        if(_S338)
        {
            diss_contact_0 = _S330;
        }
        else
        {
            diss_contact_0 = _S331;
        }
        var mode_ts_0 : u32;
        if(_S338)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_2.kappa_0))
        {
            _S337 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S337 = false;
        }
        if(_S337)
        {
            _S337 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S337 = false;
        }
        var mode_c_0 : u32;
        if(_S337)
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
                intact_normal_0 = fdiv_0(psi_contact_0 * (*b_34).geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_2.ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_4;
            }
            else
            {
                mode_c_0 = u32(0);
            }
            var inc_0 : vec2<f32> = damage_increment_0(mode_c_0, st_2.kappa_0, diss_contact_0, intact_normal_0, st_2.damage_0, psi_ts_0);
            var _S339 : f32 = inc_0.x;
            if(_S339 > (st_2.damage_0))
            {
                var _S340 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_34)), st_2.crush_1, plastic_3, d_lin_1, d_ang_1);
                var _S341 : f32 = max(_S340.energy_2 - (1.0f - st_2.crush_1) * psi_c_0, 0.0f);
                var _S342 : f32 = max(inc_0.y - _S341 * (_S339 - st_2.damage_0), 0.0f);
                var _S343 : f32 = max((psi_ts_0 - _S341) * (_S339 - st_2.damage_0) - _S342, 0.0f);
                st_2.damage_0 = _S339;
                st_2.mode_0 = mode_ts_0;
                dissipated_4 = _S342;
                overshoot_1 = _S343;
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
        st_2.kappa_0 = max(st_2.kappa_0, diss_contact_0);
        if((state_2.damage_0) > 0.0f)
        {
            var _S344 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_34)), state_2.crush_1, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_1, d_ang_1);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S344.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S345 : Measures_0 = stress_measures_0(&((*b_34)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S346 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_34)), _S345, multiplier_1);
        var _S347 : f32 = _S346.z;
        var _S348 : f32 = _S346.w;
        var _S349 : bool = _S347 >= _S348;
        if(_S349)
        {
            psi_contact_0 = _S347;
        }
        else
        {
            psi_contact_0 = _S348;
        }
        if(_S349)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_2.kappa_c_0))
        {
            _S337 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S337 = false;
        }
        if(_S337)
        {
            _S337 = psi_c_0 > 0.0f;
        }
        else
        {
            _S337 = false;
        }
        if(_S337)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0((*mat_7).energy_1.w * (*b_34).geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_2.ductility_c_0 = intact_normal_0;
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
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_2.kappa_c_0, psi_contact_0, intact_normal_0, st_2.crush_1, psi_c_0);
            var _S350 : f32 = inc_1.x;
            if(_S350 > (st_2.crush_1))
            {
                var _S351 : f32 = inc_1.y;
                var dissipated_5 : f32 = dissipated_4 + _S351;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S350 - st_2.crush_1) - _S351, 0.0f);
                st_2.crush_1 = _S350;
                st_2.mode_0 = mode_c_0;
                if(_S350 >= 1.0f)
                {
                    _S337 = (st_2.damage_0) < 1.0f;
                }
                else
                {
                    _S337 = false;
                }
                if(_S337)
                {
                    var dissipated_6 : f32 = dissipated_5 + psi_ts_0 * (1.0f - st_2.damage_0);
                    st_2.damage_0 = 1.0f;
                    dissipated_4 = dissipated_6;
                }
                else
                {
                    dissipated_4 = dissipated_5;
                }
                overshoot_1 = overshoot_2;
            }
        }
        st_2.kappa_c_0 = max(st_2.kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_4 = 0.0f;
        overshoot_1 = 0.0f;
    }
    var dmg_0 : f32 = st_2.damage_0;
    var _S352 : vec3<f32> = vec3<f32>(0.0f);
    if((st_2.damage_0) == 0.0f)
    {
        _S337 = ((flags_1 & (u32(8)))) != u32(0);
    }
    else
    {
        _S337 = false;
    }
    var qc_ang_0 : vec3<f32>;
    if(!_S337)
    {
        var _S353 : Contact_0 = contact_part_0(&((*mat_7)), &((*b_34)), st_2.crush_1, plastic_3, d_lin_1, d_ang_1);
        st_2.plastic_x_0 = _S353.plastic_1.x;
        st_2.plastic_y_0 = _S353.plastic_1.y;
        st_2.plastic_t_0 = _S353.plastic_1.z;
        diss_contact_0 = _S353.diss_4;
        qc_lin_0 = _S353.q_lin_1;
        qc_ang_0 = _S353.q_ang_1;
        psi_contact_0 = _S353.energy_2;
    }
    else
    {
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S352;
        qc_ang_0 = _S352;
        psi_contact_0 = 0.0f;
    }
    var dissipated_7 : f32 = dissipated_4 + dmg_0 * diss_contact_0;
    if(_S336)
    {
        intact_normal_0 = kn_2 * _S335;
    }
    else
    {
        intact_normal_0 = (1.0f - st_2.crush_1) * kn_2 * _S335;
    }
    var _S354 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S354 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S354 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S354 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S354) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_7 : f32 = _S354 * (psi_ts_0 + (1.0f - st_2.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_2)
    {
        _S337 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S337 = false;
    }
    var stored_8 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S337)
    {
        var k_axial_0 : f32 = (*b_34).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_34).rebar0_0.y;
        var yield_force_0 : f32 = (*b_34).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_34).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S335, st_2.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S332, st_2.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S333, st_2.rebar_slip1_0, dowel_capacity_0);
        var _S355 : f32 = nr_0.y;
        var _S356 : f32 = v1_0.y;
        var _S357 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S355) + dowel_capacity_0 * (abs(_S356) + abs(_S357));
        st_2.rebar_plastic_0 = st_2.rebar_plastic_0 + _S355;
        st_2.rebar_slip0_0 = st_2.rebar_slip0_0 + _S356;
        st_2.rebar_slip1_0 = st_2.rebar_slip1_0 + _S357;
        st_2.rebar_work_0 = st_2.rebar_work_0 + work_0;
        var dissipated_8 : f32 = dissipated_7 + work_0;
        var _S358 : f32 = nr_0.x;
        var _S359 : f32 = v1_0.x;
        var _S360 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (fdiv_0(sq_0(_S358), k_axial_0) + fdiv_0(sq_0(_S359) + sq_0(_S360), k_dowel_0));
        if(fracture_1)
        {
            _S337 = (st_2.rebar_work_0) >= ((*b_34).rebar1_0.x);
        }
        else
        {
            _S337 = false;
        }
        if(_S337)
        {
            st_2.rebar_broken_0 = 1.0f;
            var dissipated_9 : f32 = dissipated_8 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_4 = dissipated_9;
            stored_8 = stored_7;
        }
        else
        {
            var stored_9 : f32 = stored_7 + elastic_0;
            force_lin_3 = force_lin_2 + vec3<f32>(_S359, _S360, _S358);
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
        _S337 = _S325;
    }
    else
    {
        _S337 = false;
    }
    if(_S337)
    {
        _S337 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S337 = false;
    }
    if(_S337)
    {
        var _S361 : Measures_0 = stress_measures_0(&((*b_34)), force_lin_3, force_ang_2);
        var _S362 : vec4<f32> = failure_indices_0(&((*mat_7)), &((*b_34)), _S361, weibull_0);
        var _S363 : f32 = life_rate_0(&((*mat_7)), max(max(_S362.x, _S362.y), _S362.z));
        st_2.fatigue_0 = min(st_2.fatigue_0 + _S363 * dt_12, 1.0f);
    }
    st_2.dissipated_0 = st_2.dissipated_0 + dissipated_4;
    var resp_0 : JointResponse_0;
    resp_0.force_lin_1 = force_lin_3;
    resp_0.force_ang_1 = force_ang_2;
    resp_0.state_1 = st_2;
    resp_0.dissipated_3 = dissipated_4;
    resp_0.overshoot_0 = overshoot_1;
    resp_0.stored_6 = stored_8;
    if(was_connected_0)
    {
        _S337 = !connected_1(st_2, has_rebar_2);
    }
    else
    {
        _S337 = false;
    }
    resp_0.disconnected_0 = _S337;
    resp_0.measures_0 = _S323;
    return resp_0;
}

fn joint_evaluate_1( mat_8 : ptr<function, JointMaterial_std140_0>,  b_35 : ptr<function, JointBond_std430_0>,  state_3 : JointState_0,  d_lin_2 : vec3<f32>,  d_ang_2 : vec3<f32>,  dt_13 : f32,  fracture_2 : bool) -> JointResponse_0
{
    var kn_3 : f32 = (*b_35).stiff0_0.x;
    var ks_2 : f32 = (*b_35).stiff0_0.y;
    var kb1_1 : f32 = (*b_35).stiff0_0.z;
    var kb2_1 : f32 = (*b_35).stiff0_0.w;
    var _S364 : vec4<f32> = (*b_35).stiff1_0;
    var kt_2 : f32 = (*b_35).stiff1_0.x;
    var has_rebar_3 : bool = ((*b_35).stiff1_0.w) != 0.0f;
    var kind_5 : u32 = (*mat_8).kind_flags_0.x;
    var flags_2 : u32 = (*mat_8).kind_flags_0.y;
    var softening_1 : bool = ((flags_2 & (u32(1)))) != u32(0);
    var st_3 : JointState_0 = state_3;
    var was_connected_1 : bool = connected_1(state_3, has_rebar_3);
    var qe_lin_1 : vec3<f32> = d_lin_2 * vec3<f32>(ks_2, ks_2, kn_3);
    var qe_ang_1 : vec3<f32> = d_ang_2 * vec3<f32>(kb1_1, kb2_1, kt_2);
    var _S365 : Measures_0 = stress_measures_0(&((*b_35)), qe_lin_1, qe_ang_1);
    var _S366 : f32 = max(max(_S365.tension_0, _S365.shear_0), _S365.compression_0);
    var _S367 : bool = dt_13 > 0.0f;
    var dif_2 : f32;
    if(_S367)
    {
        var raw_1 : f32 = fdiv_0(max(fdiv_0(_S366 - st_3.governing_stress_0, dt_13), 0.0f), (*mat_8).misc_0.w);
        var tau_3 : f32 = _S364.z;
        if(((flags_2 & (u32(16)))) != u32(0))
        {
            dif_2 = - expm1_accurate_0(- fdiv_0(dt_13, tau_3));
        }
        else
        {
            dif_2 = min(fdiv_0(dt_13, tau_3), 1.0f);
        }
        st_3.strain_rate_0 = st_3.strain_rate_0 + (raw_1 - st_3.strain_rate_0) * dif_2;
        st_3.governing_stress_0 = _S366;
    }
    if(((flags_2 & (u32(32)))) != u32(0))
    {
        var _S368 : f32 = dif_factor_0(&((*mat_8)), st_3.strain_rate_0);
        dif_2 = _S368;
    }
    else
    {
        dif_2 = 1.0f;
    }
    var weibull_1 : f32 = (*b_35).geom1_0.w;
    var _S369 : f32 = weibull_1 * dif_2;
    var _S370 : f32 = fatigue_factor_1(&((*mat_8)), st_3.fatigue_0);
    var multiplier_2 : f32 = _S369 * _S370;
    var _S371 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S365, multiplier_2);
    var _S372 : f32 = _S371.x;
    var _S373 : f32 = _S371.y;
    st_3.utilization_0 = max(max(_S372, _S373), max(_S371.z, _S371.w));
    var _S374 : f32 = d_lin_2.x;
    var _S375 : f32 = d_lin_2.y;
    var _S376 : f32 = ks_2 * (sq_0(_S374) + sq_0(_S375)) + kb1_1 * sq_0(d_ang_2.x) + kb2_1 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    var _S377 : f32 = d_lin_2.z;
    var _S378 : bool = _S377 > 0.0f;
    if(_S378)
    {
        dif_2 = kn_3 * sq_0(_S377);
    }
    else
    {
        dif_2 = 0.0f;
    }
    var psi_ts_1 : f32 = 0.5f * (_S376 + dif_2);
    var psi_c_1 : f32;
    if(_S377 < 0.0f)
    {
        psi_c_1 = 0.5f * kn_3 * sq_0(_S377);
    }
    else
    {
        psi_c_1 = 0.0f;
    }
    var plastic_4 : vec3<f32> = vec3<f32>(st_3.plastic_x_0, st_3.plastic_y_0, st_3.plastic_t_0);
    var diss_contact_1 : f32;
    var psi_contact_1 : f32;
    var intact_normal_1 : f32;
    var dissipated_10 : f32;
    var overshoot_3 : f32;
    var _S379 : bool;
    var qc_lin_1 : vec3<f32>;
    if(fracture_2)
    {
        var _S380 : bool = _S372 >= _S373;
        if(_S380)
        {
            diss_contact_1 = _S372;
        }
        else
        {
            diss_contact_1 = _S373;
        }
        var mode_ts_1 : u32;
        if(_S380)
        {
            mode_ts_1 = u32(1);
        }
        else
        {
            mode_ts_1 = u32(2);
        }
        if(diss_contact_1 > (st_3.kappa_0))
        {
            _S379 = diss_contact_1 > 1.0f;
        }
        else
        {
            _S379 = false;
        }
        if(_S379)
        {
            _S379 = psi_ts_1 > 0.0f;
        }
        else
        {
            _S379 = false;
        }
        var mode_c_1 : u32;
        if(_S379)
        {
            if(mode_ts_1 == u32(1))
            {
                psi_contact_1 = (*mat_8).energy_1.y;
            }
            else
            {
                psi_contact_1 = (*mat_8).energy_1.z;
            }
            if(softening_1)
            {
                intact_normal_1 = fdiv_0(psi_contact_1 * (*b_35).geom0_0.x * diss_contact_1 * diss_contact_1, psi_ts_1);
            }
            else
            {
                intact_normal_1 = 0.0f;
            }
            st_3.ductility_0 = intact_normal_1;
            if(softening_1)
            {
                mode_c_1 = kind_5;
            }
            else
            {
                mode_c_1 = u32(0);
            }
            var inc_2 : vec2<f32> = damage_increment_0(mode_c_1, st_3.kappa_0, diss_contact_1, intact_normal_1, st_3.damage_0, psi_ts_1);
            var _S381 : f32 = inc_2.x;
            if(_S381 > (st_3.damage_0))
            {
                var _S382 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), st_3.crush_1, plastic_4, d_lin_2, d_ang_2);
                var _S383 : f32 = max(_S382.energy_2 - (1.0f - st_3.crush_1) * psi_c_1, 0.0f);
                var _S384 : f32 = max(inc_2.y - _S383 * (_S381 - st_3.damage_0), 0.0f);
                var _S385 : f32 = max((psi_ts_1 - _S383) * (_S381 - st_3.damage_0) - _S384, 0.0f);
                st_3.damage_0 = _S381;
                st_3.mode_0 = mode_ts_1;
                dissipated_10 = _S384;
                overshoot_3 = _S385;
            }
            else
            {
                dissipated_10 = 0.0f;
                overshoot_3 = 0.0f;
            }
        }
        else
        {
            dissipated_10 = 0.0f;
            overshoot_3 = 0.0f;
        }
        st_3.kappa_0 = max(st_3.kappa_0, diss_contact_1);
        if((state_3.damage_0) > 0.0f)
        {
            var _S386 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), state_3.crush_1, vec3<f32>(state_3.plastic_x_0, state_3.plastic_y_0, state_3.plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_1 = qe_ang_1 * vec3<f32>((1.0f - state_3.damage_0)) + _S386.q_ang_1 * vec3<f32>(state_3.damage_0);
        }
        else
        {
            qc_lin_1 = qe_ang_1;
        }
        var _S387 : Measures_0 = stress_measures_0(&((*b_35)), vec3<f32>(0.0f, 0.0f, min(qe_lin_1.z, 0.0f)), qc_lin_1);
        var _S388 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S387, multiplier_2);
        var _S389 : f32 = _S388.z;
        var _S390 : f32 = _S388.w;
        var _S391 : bool = _S389 >= _S390;
        if(_S391)
        {
            psi_contact_1 = _S389;
        }
        else
        {
            psi_contact_1 = _S390;
        }
        if(_S391)
        {
            mode_c_1 = u32(3);
        }
        else
        {
            mode_c_1 = u32(4);
        }
        if(psi_contact_1 > (st_3.kappa_c_0))
        {
            _S379 = psi_contact_1 > 1.0f;
        }
        else
        {
            _S379 = false;
        }
        if(_S379)
        {
            _S379 = psi_c_1 > 0.0f;
        }
        else
        {
            _S379 = false;
        }
        if(_S379)
        {
            if(softening_1)
            {
                intact_normal_1 = fdiv_0((*mat_8).energy_1.w * (*b_35).geom0_0.x * psi_contact_1 * psi_contact_1, psi_c_1);
            }
            else
            {
                intact_normal_1 = 0.0f;
            }
            st_3.ductility_c_0 = intact_normal_1;
            var law_2 : u32;
            if(!softening_1)
            {
                law_2 = u32(0);
            }
            else
            {
                if(mode_c_1 == u32(4))
                {
                    mode_ts_1 = u32(1);
                }
                else
                {
                    mode_ts_1 = kind_5;
                }
                law_2 = mode_ts_1;
            }
            var inc_3 : vec2<f32> = damage_increment_0(law_2, st_3.kappa_c_0, psi_contact_1, intact_normal_1, st_3.crush_1, psi_c_1);
            var _S392 : f32 = inc_3.x;
            if(_S392 > (st_3.crush_1))
            {
                var _S393 : f32 = inc_3.y;
                var dissipated_11 : f32 = dissipated_10 + _S393;
                var overshoot_4 : f32 = overshoot_3 + max(psi_c_1 * (_S392 - st_3.crush_1) - _S393, 0.0f);
                st_3.crush_1 = _S392;
                st_3.mode_0 = mode_c_1;
                if(_S392 >= 1.0f)
                {
                    _S379 = (st_3.damage_0) < 1.0f;
                }
                else
                {
                    _S379 = false;
                }
                if(_S379)
                {
                    var dissipated_12 : f32 = dissipated_11 + psi_ts_1 * (1.0f - st_3.damage_0);
                    st_3.damage_0 = 1.0f;
                    dissipated_10 = dissipated_12;
                }
                else
                {
                    dissipated_10 = dissipated_11;
                }
                overshoot_3 = overshoot_4;
            }
        }
        st_3.kappa_c_0 = max(st_3.kappa_c_0, psi_contact_1);
    }
    else
    {
        dissipated_10 = 0.0f;
        overshoot_3 = 0.0f;
    }
    var dmg_1 : f32 = st_3.damage_0;
    var _S394 : vec3<f32> = vec3<f32>(0.0f);
    if((st_3.damage_0) == 0.0f)
    {
        _S379 = ((flags_2 & (u32(8)))) != u32(0);
    }
    else
    {
        _S379 = false;
    }
    var qc_ang_1 : vec3<f32>;
    if(!_S379)
    {
        var _S395 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), st_3.crush_1, plastic_4, d_lin_2, d_ang_2);
        st_3.plastic_x_0 = _S395.plastic_1.x;
        st_3.plastic_y_0 = _S395.plastic_1.y;
        st_3.plastic_t_0 = _S395.plastic_1.z;
        diss_contact_1 = _S395.diss_4;
        qc_lin_1 = _S395.q_lin_1;
        qc_ang_1 = _S395.q_ang_1;
        psi_contact_1 = _S395.energy_2;
    }
    else
    {
        diss_contact_1 = 0.0f;
        qc_lin_1 = _S394;
        qc_ang_1 = _S394;
        psi_contact_1 = 0.0f;
    }
    var dissipated_13 : f32 = dissipated_10 + dmg_1 * diss_contact_1;
    if(_S378)
    {
        intact_normal_1 = kn_3 * _S377;
    }
    else
    {
        intact_normal_1 = (1.0f - st_3.crush_1) * kn_3 * _S377;
    }
    var _S396 : f32 = 1.0f - dmg_1;
    var force_lin_4 : vec3<f32> = vec3<f32>(_S396 * qe_lin_1.x + dmg_1 * qc_lin_1.x, _S396 * qe_lin_1.y + dmg_1 * qc_lin_1.y, _S396 * intact_normal_1 + dmg_1 * qc_lin_1.z);
    var force_ang_3 : vec3<f32> = qe_ang_1 * vec3<f32>(_S396) + qc_ang_1 * vec3<f32>(dmg_1);
    var stored_10 : f32 = _S396 * (psi_ts_1 + (1.0f - st_3.crush_1) * psi_c_1) + dmg_1 * psi_contact_1;
    if(has_rebar_3)
    {
        _S379 = (st_3.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S379 = false;
    }
    var stored_11 : f32;
    var force_lin_5 : vec3<f32>;
    if(_S379)
    {
        var k_axial_1 : f32 = (*b_35).rebar0_0.x;
        var k_dowel_1 : f32 = (*b_35).rebar0_0.y;
        var yield_force_1 : f32 = (*b_35).rebar0_0.z;
        var dowel_capacity_1 : f32 = (*b_35).rebar0_0.w;
        var nr_1 : vec2<f32> = return_map_0(k_axial_1, _S377, st_3.rebar_plastic_0, yield_force_1);
        var v1_1 : vec2<f32> = return_map_0(k_dowel_1, _S374, st_3.rebar_slip0_0, dowel_capacity_1);
        var v2_1 : vec2<f32> = return_map_0(k_dowel_1, _S375, st_3.rebar_slip1_0, dowel_capacity_1);
        var _S397 : f32 = nr_1.y;
        var _S398 : f32 = v1_1.y;
        var _S399 : f32 = v2_1.y;
        var work_1 : f32 = yield_force_1 * abs(_S397) + dowel_capacity_1 * (abs(_S398) + abs(_S399));
        st_3.rebar_plastic_0 = st_3.rebar_plastic_0 + _S397;
        st_3.rebar_slip0_0 = st_3.rebar_slip0_0 + _S398;
        st_3.rebar_slip1_0 = st_3.rebar_slip1_0 + _S399;
        st_3.rebar_work_0 = st_3.rebar_work_0 + work_1;
        var dissipated_14 : f32 = dissipated_13 + work_1;
        var _S400 : f32 = nr_1.x;
        var _S401 : f32 = v1_1.x;
        var _S402 : f32 = v2_1.x;
        var elastic_1 : f32 = 0.5f * (fdiv_0(sq_0(_S400), k_axial_1) + fdiv_0(sq_0(_S401) + sq_0(_S402), k_dowel_1));
        if(fracture_2)
        {
            _S379 = (st_3.rebar_work_0) >= ((*b_35).rebar1_0.x);
        }
        else
        {
            _S379 = false;
        }
        if(_S379)
        {
            st_3.rebar_broken_0 = 1.0f;
            var dissipated_15 : f32 = dissipated_14 + elastic_1;
            force_lin_5 = force_lin_4;
            dissipated_10 = dissipated_15;
            stored_11 = stored_10;
        }
        else
        {
            var stored_12 : f32 = stored_10 + elastic_1;
            force_lin_5 = force_lin_4 + vec3<f32>(_S401, _S402, _S400);
            dissipated_10 = dissipated_14;
            stored_11 = stored_12;
        }
    }
    else
    {
        force_lin_5 = force_lin_4;
        dissipated_10 = dissipated_13;
        stored_11 = stored_10;
    }
    if(fracture_2)
    {
        _S379 = _S367;
    }
    else
    {
        _S379 = false;
    }
    if(_S379)
    {
        _S379 = ((flags_2 & (u32(64)))) != u32(0);
    }
    else
    {
        _S379 = false;
    }
    if(_S379)
    {
        var _S403 : Measures_0 = stress_measures_0(&((*b_35)), force_lin_5, force_ang_3);
        var _S404 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S403, weibull_1);
        var _S405 : f32 = life_rate_0(&((*mat_8)), max(max(_S404.x, _S404.y), _S404.z));
        st_3.fatigue_0 = min(st_3.fatigue_0 + _S405 * dt_13, 1.0f);
    }
    st_3.dissipated_0 = st_3.dissipated_0 + dissipated_10;
    var resp_1 : JointResponse_0;
    resp_1.force_lin_1 = force_lin_5;
    resp_1.force_ang_1 = force_ang_3;
    resp_1.state_1 = st_3;
    resp_1.dissipated_3 = dissipated_10;
    resp_1.overshoot_0 = overshoot_3;
    resp_1.stored_6 = stored_11;
    if(was_connected_1)
    {
        _S379 = !connected_1(st_3, has_rebar_3);
    }
    else
    {
        _S379 = false;
    }
    resp_1.disconnected_0 = _S379;
    resp_1.measures_0 = _S365;
    return resp_1;
}

fn joint_evaluate_2( mat_9 : ptr<function, JointMaterial_std140_0>,  b_36 : ptr<function, JointBond_std430_0>,  state_4 : ptr<function, JointState_std430_0>,  d_lin_3 : vec3<f32>,  d_ang_3 : vec3<f32>,  dt_14 : f32,  fracture_3 : bool) -> JointResponse_0
{
    var kn_4 : f32 = (*b_36).stiff0_0.x;
    var ks_3 : f32 = (*b_36).stiff0_0.y;
    var kb1_2 : f32 = (*b_36).stiff0_0.z;
    var kb2_2 : f32 = (*b_36).stiff0_0.w;
    var _S406 : vec4<f32> = (*b_36).stiff1_0;
    var kt_3 : f32 = (*b_36).stiff1_0.x;
    var has_rebar_4 : bool = ((*b_36).stiff1_0.w) != 0.0f;
    var kind_6 : u32 = (*mat_9).kind_flags_0.x;
    var flags_3 : u32 = (*mat_9).kind_flags_0.y;
    var softening_2 : bool = ((flags_3 & (u32(1)))) != u32(0);
    var st_4 : JointState_0;
    st_4.damage_0 = (*state_4).damage_0;
    st_4.crush_1 = (*state_4).crush_1;
    st_4.kappa_0 = (*state_4).kappa_0;
    st_4.kappa_c_0 = (*state_4).kappa_c_0;
    st_4.ductility_0 = (*state_4).ductility_0;
    st_4.ductility_c_0 = (*state_4).ductility_c_0;
    st_4.fatigue_0 = (*state_4).fatigue_0;
    st_4.plastic_x_0 = (*state_4).plastic_x_0;
    st_4.plastic_y_0 = (*state_4).plastic_y_0;
    st_4.plastic_t_0 = (*state_4).plastic_t_0;
    st_4.rebar_plastic_0 = (*state_4).rebar_plastic_0;
    st_4.rebar_slip0_0 = (*state_4).rebar_slip0_0;
    st_4.rebar_slip1_0 = (*state_4).rebar_slip1_0;
    st_4.rebar_work_0 = (*state_4).rebar_work_0;
    st_4.rebar_broken_0 = (*state_4).rebar_broken_0;
    st_4.strain_rate_0 = (*state_4).strain_rate_0;
    st_4.governing_stress_0 = (*state_4).governing_stress_0;
    st_4.dissipated_0 = (*state_4).dissipated_0;
    st_4.utilization_0 = (*state_4).utilization_0;
    st_4.mode_0 = (*state_4).mode_0;
    var _S407 : bool = connected_0(&((*state_4)), has_rebar_4);
    var qe_lin_2 : vec3<f32> = d_lin_3 * vec3<f32>(ks_3, ks_3, kn_4);
    var qe_ang_2 : vec3<f32> = d_ang_3 * vec3<f32>(kb1_2, kb2_2, kt_3);
    var _S408 : Measures_0 = stress_measures_0(&((*b_36)), qe_lin_2, qe_ang_2);
    var _S409 : f32 = max(max(_S408.tension_0, _S408.shear_0), _S408.compression_0);
    var _S410 : bool = dt_14 > 0.0f;
    var dif_3 : f32;
    if(_S410)
    {
        var raw_2 : f32 = fdiv_0(max(fdiv_0(_S409 - st_4.governing_stress_0, dt_14), 0.0f), (*mat_9).misc_0.w);
        var tau_4 : f32 = _S406.z;
        if(((flags_3 & (u32(16)))) != u32(0))
        {
            dif_3 = - expm1_accurate_0(- fdiv_0(dt_14, tau_4));
        }
        else
        {
            dif_3 = min(fdiv_0(dt_14, tau_4), 1.0f);
        }
        st_4.strain_rate_0 = st_4.strain_rate_0 + (raw_2 - st_4.strain_rate_0) * dif_3;
        st_4.governing_stress_0 = _S409;
    }
    if(((flags_3 & (u32(32)))) != u32(0))
    {
        var _S411 : f32 = dif_factor_0(&((*mat_9)), st_4.strain_rate_0);
        dif_3 = _S411;
    }
    else
    {
        dif_3 = 1.0f;
    }
    var weibull_2 : f32 = (*b_36).geom1_0.w;
    var _S412 : f32 = weibull_2 * dif_3;
    var _S413 : f32 = fatigue_factor_1(&((*mat_9)), st_4.fatigue_0);
    var multiplier_3 : f32 = _S412 * _S413;
    var _S414 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S408, multiplier_3);
    var _S415 : f32 = _S414.x;
    var _S416 : f32 = _S414.y;
    st_4.utilization_0 = max(max(_S415, _S416), max(_S414.z, _S414.w));
    var _S417 : f32 = d_lin_3.x;
    var _S418 : f32 = d_lin_3.y;
    var _S419 : f32 = ks_3 * (sq_0(_S417) + sq_0(_S418)) + kb1_2 * sq_0(d_ang_3.x) + kb2_2 * sq_0(d_ang_3.y) + kt_3 * sq_0(d_ang_3.z);
    var _S420 : f32 = d_lin_3.z;
    var _S421 : bool = _S420 > 0.0f;
    if(_S421)
    {
        dif_3 = kn_4 * sq_0(_S420);
    }
    else
    {
        dif_3 = 0.0f;
    }
    var psi_ts_2 : f32 = 0.5f * (_S419 + dif_3);
    var psi_c_2 : f32;
    if(_S420 < 0.0f)
    {
        psi_c_2 = 0.5f * kn_4 * sq_0(_S420);
    }
    else
    {
        psi_c_2 = 0.0f;
    }
    var plastic_5 : vec3<f32> = vec3<f32>(st_4.plastic_x_0, st_4.plastic_y_0, st_4.plastic_t_0);
    var diss_contact_2 : f32;
    var psi_contact_2 : f32;
    var intact_normal_2 : f32;
    var dissipated_16 : f32;
    var overshoot_5 : f32;
    var _S422 : bool;
    var qc_lin_2 : vec3<f32>;
    if(fracture_3)
    {
        var _S423 : bool = _S415 >= _S416;
        if(_S423)
        {
            diss_contact_2 = _S415;
        }
        else
        {
            diss_contact_2 = _S416;
        }
        var mode_ts_2 : u32;
        if(_S423)
        {
            mode_ts_2 = u32(1);
        }
        else
        {
            mode_ts_2 = u32(2);
        }
        if(diss_contact_2 > (st_4.kappa_0))
        {
            _S422 = diss_contact_2 > 1.0f;
        }
        else
        {
            _S422 = false;
        }
        if(_S422)
        {
            _S422 = psi_ts_2 > 0.0f;
        }
        else
        {
            _S422 = false;
        }
        var mode_c_2 : u32;
        if(_S422)
        {
            if(mode_ts_2 == u32(1))
            {
                psi_contact_2 = (*mat_9).energy_1.y;
            }
            else
            {
                psi_contact_2 = (*mat_9).energy_1.z;
            }
            if(softening_2)
            {
                intact_normal_2 = fdiv_0(psi_contact_2 * (*b_36).geom0_0.x * diss_contact_2 * diss_contact_2, psi_ts_2);
            }
            else
            {
                intact_normal_2 = 0.0f;
            }
            st_4.ductility_0 = intact_normal_2;
            if(softening_2)
            {
                mode_c_2 = kind_6;
            }
            else
            {
                mode_c_2 = u32(0);
            }
            var inc_4 : vec2<f32> = damage_increment_0(mode_c_2, st_4.kappa_0, diss_contact_2, intact_normal_2, st_4.damage_0, psi_ts_2);
            var _S424 : f32 = inc_4.x;
            if(_S424 > (st_4.damage_0))
            {
                var _S425 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), st_4.crush_1, plastic_5, d_lin_3, d_ang_3);
                var _S426 : f32 = max(_S425.energy_2 - (1.0f - st_4.crush_1) * psi_c_2, 0.0f);
                var _S427 : f32 = max(inc_4.y - _S426 * (_S424 - st_4.damage_0), 0.0f);
                var _S428 : f32 = max((psi_ts_2 - _S426) * (_S424 - st_4.damage_0) - _S427, 0.0f);
                st_4.damage_0 = _S424;
                st_4.mode_0 = mode_ts_2;
                dissipated_16 = _S427;
                overshoot_5 = _S428;
            }
            else
            {
                dissipated_16 = 0.0f;
                overshoot_5 = 0.0f;
            }
        }
        else
        {
            dissipated_16 = 0.0f;
            overshoot_5 = 0.0f;
        }
        st_4.kappa_0 = max(st_4.kappa_0, diss_contact_2);
        var _S429 : f32 = (*state_4).damage_0;
        if(((*state_4).damage_0) > 0.0f)
        {
            var _S430 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), (*state_4).crush_1, vec3<f32>((*state_4).plastic_x_0, (*state_4).plastic_y_0, (*state_4).plastic_t_0), d_lin_3, d_ang_3);
            qc_lin_2 = qe_ang_2 * vec3<f32>((1.0f - _S429)) + _S430.q_ang_1 * vec3<f32>(_S429);
        }
        else
        {
            qc_lin_2 = qe_ang_2;
        }
        var _S431 : Measures_0 = stress_measures_0(&((*b_36)), vec3<f32>(0.0f, 0.0f, min(qe_lin_2.z, 0.0f)), qc_lin_2);
        var _S432 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S431, multiplier_3);
        var _S433 : f32 = _S432.z;
        var _S434 : f32 = _S432.w;
        var _S435 : bool = _S433 >= _S434;
        if(_S435)
        {
            psi_contact_2 = _S433;
        }
        else
        {
            psi_contact_2 = _S434;
        }
        if(_S435)
        {
            mode_c_2 = u32(3);
        }
        else
        {
            mode_c_2 = u32(4);
        }
        if(psi_contact_2 > (st_4.kappa_c_0))
        {
            _S422 = psi_contact_2 > 1.0f;
        }
        else
        {
            _S422 = false;
        }
        if(_S422)
        {
            _S422 = psi_c_2 > 0.0f;
        }
        else
        {
            _S422 = false;
        }
        if(_S422)
        {
            if(softening_2)
            {
                intact_normal_2 = fdiv_0((*mat_9).energy_1.w * (*b_36).geom0_0.x * psi_contact_2 * psi_contact_2, psi_c_2);
            }
            else
            {
                intact_normal_2 = 0.0f;
            }
            st_4.ductility_c_0 = intact_normal_2;
            var law_3 : u32;
            if(!softening_2)
            {
                law_3 = u32(0);
            }
            else
            {
                if(mode_c_2 == u32(4))
                {
                    mode_ts_2 = u32(1);
                }
                else
                {
                    mode_ts_2 = kind_6;
                }
                law_3 = mode_ts_2;
            }
            var inc_5 : vec2<f32> = damage_increment_0(law_3, st_4.kappa_c_0, psi_contact_2, intact_normal_2, st_4.crush_1, psi_c_2);
            var _S436 : f32 = inc_5.x;
            if(_S436 > (st_4.crush_1))
            {
                var _S437 : f32 = inc_5.y;
                var dissipated_17 : f32 = dissipated_16 + _S437;
                var overshoot_6 : f32 = overshoot_5 + max(psi_c_2 * (_S436 - st_4.crush_1) - _S437, 0.0f);
                st_4.crush_1 = _S436;
                st_4.mode_0 = mode_c_2;
                if(_S436 >= 1.0f)
                {
                    _S422 = (st_4.damage_0) < 1.0f;
                }
                else
                {
                    _S422 = false;
                }
                if(_S422)
                {
                    var dissipated_18 : f32 = dissipated_17 + psi_ts_2 * (1.0f - st_4.damage_0);
                    st_4.damage_0 = 1.0f;
                    dissipated_16 = dissipated_18;
                }
                else
                {
                    dissipated_16 = dissipated_17;
                }
                overshoot_5 = overshoot_6;
            }
        }
        st_4.kappa_c_0 = max(st_4.kappa_c_0, psi_contact_2);
    }
    else
    {
        dissipated_16 = 0.0f;
        overshoot_5 = 0.0f;
    }
    var dmg_2 : f32 = st_4.damage_0;
    var _S438 : vec3<f32> = vec3<f32>(0.0f);
    if((st_4.damage_0) == 0.0f)
    {
        _S422 = ((flags_3 & (u32(8)))) != u32(0);
    }
    else
    {
        _S422 = false;
    }
    var qc_ang_2 : vec3<f32>;
    if(!_S422)
    {
        var _S439 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), st_4.crush_1, plastic_5, d_lin_3, d_ang_3);
        st_4.plastic_x_0 = _S439.plastic_1.x;
        st_4.plastic_y_0 = _S439.plastic_1.y;
        st_4.plastic_t_0 = _S439.plastic_1.z;
        diss_contact_2 = _S439.diss_4;
        qc_lin_2 = _S439.q_lin_1;
        qc_ang_2 = _S439.q_ang_1;
        psi_contact_2 = _S439.energy_2;
    }
    else
    {
        diss_contact_2 = 0.0f;
        qc_lin_2 = _S438;
        qc_ang_2 = _S438;
        psi_contact_2 = 0.0f;
    }
    var dissipated_19 : f32 = dissipated_16 + dmg_2 * diss_contact_2;
    if(_S421)
    {
        intact_normal_2 = kn_4 * _S420;
    }
    else
    {
        intact_normal_2 = (1.0f - st_4.crush_1) * kn_4 * _S420;
    }
    var _S440 : f32 = 1.0f - dmg_2;
    var force_lin_6 : vec3<f32> = vec3<f32>(_S440 * qe_lin_2.x + dmg_2 * qc_lin_2.x, _S440 * qe_lin_2.y + dmg_2 * qc_lin_2.y, _S440 * intact_normal_2 + dmg_2 * qc_lin_2.z);
    var force_ang_4 : vec3<f32> = qe_ang_2 * vec3<f32>(_S440) + qc_ang_2 * vec3<f32>(dmg_2);
    var stored_13 : f32 = _S440 * (psi_ts_2 + (1.0f - st_4.crush_1) * psi_c_2) + dmg_2 * psi_contact_2;
    if(has_rebar_4)
    {
        _S422 = (st_4.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S422 = false;
    }
    var stored_14 : f32;
    var force_lin_7 : vec3<f32>;
    if(_S422)
    {
        var k_axial_2 : f32 = (*b_36).rebar0_0.x;
        var k_dowel_2 : f32 = (*b_36).rebar0_0.y;
        var yield_force_2 : f32 = (*b_36).rebar0_0.z;
        var dowel_capacity_2 : f32 = (*b_36).rebar0_0.w;
        var nr_2 : vec2<f32> = return_map_0(k_axial_2, _S420, st_4.rebar_plastic_0, yield_force_2);
        var v1_2 : vec2<f32> = return_map_0(k_dowel_2, _S417, st_4.rebar_slip0_0, dowel_capacity_2);
        var v2_2 : vec2<f32> = return_map_0(k_dowel_2, _S418, st_4.rebar_slip1_0, dowel_capacity_2);
        var _S441 : f32 = nr_2.y;
        var _S442 : f32 = v1_2.y;
        var _S443 : f32 = v2_2.y;
        var work_2 : f32 = yield_force_2 * abs(_S441) + dowel_capacity_2 * (abs(_S442) + abs(_S443));
        st_4.rebar_plastic_0 = st_4.rebar_plastic_0 + _S441;
        st_4.rebar_slip0_0 = st_4.rebar_slip0_0 + _S442;
        st_4.rebar_slip1_0 = st_4.rebar_slip1_0 + _S443;
        st_4.rebar_work_0 = st_4.rebar_work_0 + work_2;
        var dissipated_20 : f32 = dissipated_19 + work_2;
        var _S444 : f32 = nr_2.x;
        var _S445 : f32 = v1_2.x;
        var _S446 : f32 = v2_2.x;
        var elastic_2 : f32 = 0.5f * (fdiv_0(sq_0(_S444), k_axial_2) + fdiv_0(sq_0(_S445) + sq_0(_S446), k_dowel_2));
        if(fracture_3)
        {
            _S422 = (st_4.rebar_work_0) >= ((*b_36).rebar1_0.x);
        }
        else
        {
            _S422 = false;
        }
        if(_S422)
        {
            st_4.rebar_broken_0 = 1.0f;
            var dissipated_21 : f32 = dissipated_20 + elastic_2;
            force_lin_7 = force_lin_6;
            dissipated_16 = dissipated_21;
            stored_14 = stored_13;
        }
        else
        {
            var stored_15 : f32 = stored_13 + elastic_2;
            force_lin_7 = force_lin_6 + vec3<f32>(_S445, _S446, _S444);
            dissipated_16 = dissipated_20;
            stored_14 = stored_15;
        }
    }
    else
    {
        force_lin_7 = force_lin_6;
        dissipated_16 = dissipated_19;
        stored_14 = stored_13;
    }
    if(fracture_3)
    {
        _S422 = _S410;
    }
    else
    {
        _S422 = false;
    }
    if(_S422)
    {
        _S422 = ((flags_3 & (u32(64)))) != u32(0);
    }
    else
    {
        _S422 = false;
    }
    if(_S422)
    {
        var _S447 : Measures_0 = stress_measures_0(&((*b_36)), force_lin_7, force_ang_4);
        var _S448 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S447, weibull_2);
        var _S449 : f32 = life_rate_0(&((*mat_9)), max(max(_S448.x, _S448.y), _S448.z));
        st_4.fatigue_0 = min(st_4.fatigue_0 + _S449 * dt_14, 1.0f);
    }
    st_4.dissipated_0 = st_4.dissipated_0 + dissipated_16;
    var resp_2 : JointResponse_0;
    resp_2.force_lin_1 = force_lin_7;
    resp_2.force_ang_1 = force_ang_4;
    resp_2.state_1 = st_4;
    resp_2.dissipated_3 = dissipated_16;
    resp_2.overshoot_0 = overshoot_5;
    resp_2.stored_6 = stored_14;
    if(_S407)
    {
        _S422 = !connected_1(st_4, has_rebar_4);
    }
    else
    {
        _S422 = false;
    }
    resp_2.disconnected_0 = _S422;
    resp_2.measures_0 = _S408;
    return resp_2;
}

fn secant_factors_0( b_37 : ptr<function, JointBond_std430_0>,  st_5 : ptr<function, JointState_std430_0>,  d_lin_4 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var _S450 : f32 = (*st_5).damage_0;
    var compressed_0 : bool = (d_lin_4.z) < 0.0f;
    var contact_3 : f32;
    if(compressed_0)
    {
        contact_3 = _S450;
    }
    else
    {
        contact_3 = 0.0f;
    }
    var _S451 : f32 = 1.0f - _S450;
    var _S452 : f32 = max(_S451 + contact_3, 9.99999997475242708e-07f);
    var normal_6 : f32;
    if(compressed_0)
    {
        normal_6 = max(1.0f - (*st_5).crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_6 = max(_S451, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S452, _S452, normal_6);
    (*f_ang_0) = vec3<f32>(_S452);
    var _S453 : bool;
    if(((*b_37).stiff1_0.w) != 0.0f)
    {
        _S453 = ((*st_5).rebar_broken_0) == 0.0f;
    }
    else
    {
        _S453 = false;
    }
    if(_S453)
    {
        var _S454 : vec4<f32> = (*b_37).rebar0_0;
        var _S455 : vec4<f32> = (*b_37).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + fdiv_0((*b_37).rebar0_0.x, (*b_37).stiff0_0.x);
        var _S456 : f32 = fdiv_0(_S454.y, _S455.y);
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S456;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S456;
    }
    return;
}

fn secant_factors_1( b_38 : ptr<function, JointBond_std430_0>,  st_6 : JointState_0,  d_lin_5 : vec3<f32>,  f_lin_1 : ptr<function, vec3<f32>>,  f_ang_1 : ptr<function, vec3<f32>>)
{
    var compressed_1 : bool = (d_lin_5.z) < 0.0f;
    var contact_4 : f32;
    if(compressed_1)
    {
        contact_4 = st_6.damage_0;
    }
    else
    {
        contact_4 = 0.0f;
    }
    var _S457 : f32 = 1.0f - st_6.damage_0;
    var _S458 : f32 = max(_S457 + contact_4, 9.99999997475242708e-07f);
    var normal_7 : f32;
    if(compressed_1)
    {
        normal_7 = max(1.0f - st_6.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_7 = max(_S457, 9.99999997475242708e-07f);
    }
    (*f_lin_1) = vec3<f32>(_S458, _S458, normal_7);
    (*f_ang_1) = vec3<f32>(_S458);
    var _S459 : bool;
    if(((*b_38).stiff1_0.w) != 0.0f)
    {
        _S459 = (st_6.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S459 = false;
    }
    if(_S459)
    {
        var _S460 : vec4<f32> = (*b_38).rebar0_0;
        var _S461 : vec4<f32> = (*b_38).stiff0_0;
        (*f_lin_1)[i32(2)] = (*f_lin_1)[i32(2)] + fdiv_0((*b_38).rebar0_0.x, (*b_38).stiff0_0.x);
        var _S462 : f32 = fdiv_0(_S460.y, _S461.y);
        (*f_lin_1)[i32(0)] = (*f_lin_1)[i32(0)] + _S462;
        (*f_lin_1)[i32(1)] = (*f_lin_1)[i32(1)] + _S462;
    }
    return;
}

fn is_damaged_0( st_7 : JointState_0) -> bool
{
    var _S463 : bool;
    if((st_7.damage_0) > 0.0f)
    {
        _S463 = true;
    }
    else
    {
        _S463 = (st_7.crush_1) > 0.0f;
    }
    return _S463;
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

fn to_local_0( _S464 : u32,  _S465 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S465, bonds_0[_S464].t1_0.xyz), dot(_S465, bonds_0[_S464].t2_0.xyz), dot(_S465, bonds_0[_S464].normal_0.xyz));
}

fn to_body_0( _S466 : u32,  _S467 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S466].t1_0.xyz * vec3<f32>(_S467.x) + bonds_0[_S466].t2_0.xyz * vec3<f32>(_S467.y) + bonds_0[_S466].normal_0.xyz * vec3<f32>(_S467.z);
}

fn bond_update_0( i_8 : u32,  dt_15 : f32,  fracture_4 : bool,  abs_step_0 : u32) -> bool
{
    var _S468 : JointState_0 = JointState_0( bond_dyn_0[i_8].js_0.damage_0, bond_dyn_0[i_8].js_0.crush_1, bond_dyn_0[i_8].js_0.kappa_0, bond_dyn_0[i_8].js_0.kappa_c_0, bond_dyn_0[i_8].js_0.ductility_0, bond_dyn_0[i_8].js_0.ductility_c_0, bond_dyn_0[i_8].js_0.fatigue_0, bond_dyn_0[i_8].js_0.plastic_x_0, bond_dyn_0[i_8].js_0.plastic_y_0, bond_dyn_0[i_8].js_0.plastic_t_0, bond_dyn_0[i_8].js_0.rebar_plastic_0, bond_dyn_0[i_8].js_0.rebar_slip0_0, bond_dyn_0[i_8].js_0.rebar_slip1_0, bond_dyn_0[i_8].js_0.rebar_work_0, bond_dyn_0[i_8].js_0.rebar_broken_0, bond_dyn_0[i_8].js_0.strain_rate_0, bond_dyn_0[i_8].js_0.governing_stress_0, bond_dyn_0[i_8].js_0.dissipated_0, bond_dyn_0[i_8].js_0.utilization_0, bond_dyn_0[i_8].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S468;
    bd_0.force_lin_0 = bond_dyn_0[i_8].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_8].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_8].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_8].comps_0;
    bd_0.events_0 = bond_dyn_0[i_8].events_0;
    var _S469 : JointBond_std430_0 = bonds_0[i_8].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_8].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_8].rb_0.xyz;
    var _S470 : u32 = u32(4) * _S469.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S470 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S470 + u32(3)].xyz;
    var _S471 : u32 = u32(4) * _S469.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S471 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S471 + u32(3)].xyz;
    var _S472 : vec3<f32> = to_local_0(i_8, state_0[_S471].xyz + cross(tb_3, rb_1) - (state_0[_S470].xyz + cross(ta_3, ra_1)));
    var _S473 : vec3<f32> = to_local_0(i_8, tb_3 - ta_3);
    var _S474 : vec3<f32> = to_local_0(i_8, state_0[_S471 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S470 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S475 : vec3<f32> = to_local_0(i_8, wb_0 - wa_0);
    var _S476 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S469.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S477 : JointResponse_0 = joint_evaluate_0(&(_S476), &(_S469), bd_0.js_0, _S472, _S473, dt_15, fracture_4);
    var f_lin_2 : vec3<f32>;
    var f_ang_2 : vec3<f32>;
    secant_factors_1(&(_S469), _S477.state_1, _S472, &(f_lin_2), &(f_ang_2));
    var qd_lin_0 : vec3<f32> = _S474 * bonds_0[i_8].c_lin_0.xyz * f_lin_2;
    var qd_ang_0 : vec3<f32> = _S475 * bonds_0[i_8].c_ang_0.xyz * f_ang_2;
    var q_lin_2 : vec3<f32> = _S477.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S477.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S474) + dot(qd_ang_0, _S475)) * dt_15;
    var _S478 : vec3<f32> = to_body_0(i_8, q_lin_2);
    var _S479 : vec3<f32> = to_body_0(i_8, q_ang_2);
    var _S480 : u32 = u32(3) * i_8;
    scratch_0[_S480] = vec4<f32>(_S478, max(_S477.measures_0.tension_0, _S477.measures_0.compression_0));
    scratch_0[_S480 + u32(1)] = vec4<f32>(_S479 + cross(ra_1, _S478), 0.0f);
    scratch_0[_S480 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S479) + cross(rb_1, (vec3<f32>(0) - _S478)), 0.0f);
    var _S481 : f32 = bd_0.sums_0[i32(0)];
    var _S482 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S481), &(_S482), _S477.dissipated_3);
    bd_0.sums_0[i32(0)] = _S481;
    bd_0.comps_0[i32(0)] = _S482;
    var _S483 : f32 = bd_0.sums_0[i32(1)];
    var _S484 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S483), &(_S484), _S477.overshoot_0);
    bd_0.sums_0[i32(1)] = _S483;
    bd_0.comps_0[i32(1)] = _S484;
    var _S485 : f32 = bd_0.sums_0[i32(2)];
    var _S486 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S485), &(_S486), damped_0);
    bd_0.sums_0[i32(2)] = _S485;
    bd_0.comps_0[i32(2)] = _S486;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S477.stored_6);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S477.state_1.utilization_0));
    var _S487 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S487 = is_damaged_0(_S477.state_1);
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        _S487 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S477.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S488 : f32 = fatigue_factor_0(&(_S476), previous_0.fatigue_0);
        _S487 = _S488 > 0.99000000953674316f;
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        var _S489 : f32 = fatigue_factor_0(&(_S476), _S477.state_1.fatigue_0);
        _S487 = _S489 <= 0.99000000953674316f;
    }
    else
    {
        _S487 = false;
    }
    if(_S487)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S477.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
    }
    bd_0.js_0 = _S477.state_1;
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
    return _S477.disconnected_0;
}

fn chunk_update_0( c_15 : u32,  isl_11 : ptr<function, Island_std430_0>,  rg_9 : Rigid_0,  dt_16 : f32,  rml_0 : bool,  step_0 : u32,  contact_5 : bool,  work_3 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S490 : vec3<f32> = vec3<f32>(0.0f);
    var _S491 : u32 = index_0[c_15];
    var peak_0 : f32 = 0.0f;
    var e_3 : u32 = _S491;
    var fi_0 : vec3<f32> = _S490;
    var mi_0 : vec3<f32> = _S490;
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
        var _S492 : u32 = u32(3) * ((entry_2 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S492];
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + scratch_0[_S492 + u32(1)].xyz;
            fi_0 = fi_0 + fa_2.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + scratch_0[_S492 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_2.xyz);
            mi_0 = mi_2;
        }
        var _S493 : f32 = max(peak_0, fa_2.w);
        var _S494 : u32 = e_3 + u32(1);
        peak_0 = _S493;
        e_3 = _S494;
    }
    var _S495 : u32 = u32(4) * c_15;
    var u_0 : vec3<f32> = state_0[_S495].xyz;
    var _S496 : u32 = _S495 + u32(1);
    var th_1 : vec3<f32> = state_0[_S496].xyz;
    var _S497 : u32 = _S495 + u32(2);
    var v_9 : vec3<f32> = state_0[_S497].xyz;
    var _S498 : u32 = _S495 + u32(3);
    var w_5 : vec3<f32> = state_0[_S498].xyz;
    var mass_0 : f32 = chunks_0[c_15].center_0.w;
    var _S499 : vec3<f32> = chunks_0[c_15].center_0.xyz;
    var _S500 : vec3<f32> = (*isl_11).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_9.rot_0, _S499 + u_0 - _S500);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    chunk_external_1(c_15, c_15, rg_9.rot_0, step_0, dt_16, contact_5, &(f_load_0), &(t_load_0));
    record_chunk_load_0(c_15, f_load_0, t_load_0);
    var _S501 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S501;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.alpha_0) + cross(rg_9.w_4, world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.w_4)));
        f_world_1 = f_world_0 - (rg_9.a_7 + cross(rg_9.alpha_0, r_world_0) + cross(rg_9.w_4, cross(rg_9.w_4, r_world_0))) * _S501;
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
    var _S502 : vec4<u32> = chunks_0[c_15].load_range_0;
    var term_5 : u32 = chunks_0[c_15].load_range_0.x;
    loop
    {
        if(term_5 < (_S502.y))
        {
        }
        else
        {
            break;
        }
        var _S503 : u32 = u32(5) * term_5;
        if(((bitcast<vec4<u32>>((loads_0[_S503]))).y) != u32(2))
        {
            term_5 = term_5 + u32(1);
            continue;
        }
        var _S504 : vec3<f32> = vec3<f32>(eval_function_0(term_5, step_0, dt_16, dt_16));
        var m_ext_3 : vec3<f32> = m_ext_1 + loads_0[_S503 + u32(2)].xyz * _S504;
        f_ext_1 = f_ext_1 + loads_0[_S503 + u32(1)].xyz * _S504;
        m_ext_1 = m_ext_3;
        term_5 = term_5 + u32(1);
    }
    var f_16 : vec3<f32> = f_ext_1 + fi_0;
    var m_5 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_15].info_1.x;
    var _S505 : vec3<f32> = vec3<f32>(state_0[_S496].w, state_0[_S497].w, state_0[_S498].w);
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
        v_10 = _S490;
        w_6 = _S490;
    }
    else
    {
        var _S506 : vec4<f32> = chunks_0[c_15].scale_0;
        var w_7 : vec3<f32> = w_5 + rows_mul_0(chunks_0[c_15].inv0_1, chunks_0[c_15].inv1_1, chunks_0[c_15].inv2_1, m_5) * vec3<f32>((dt_16 * chunks_0[c_15].scale_0.z));
        var _S507 : vec3<f32> = vec3<f32>(dt_16);
        var th_3 : vec3<f32> = th_1 + w_7 * _S507;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_16);
            u_1 = u_0;
            th_2 = _S490;
        }
        else
        {
            var v_11 : vec3<f32> = v_9 + f_16 * vec3<f32>((dt_16 * _S506.y));
            var u_2 : vec3<f32> = u_0 + v_11 * _S507;
            reaction_0 = _S505;
            u_1 = u_2;
            th_2 = v_11;
        }
        var _S508 : vec3<f32> = th_2;
        th_2 = th_3;
        v_10 = _S508;
        w_6 = w_7;
    }
    state_0[_S495] = vec4<f32>(u_1, peak_0);
    state_0[_S496] = vec4<f32>(th_2, reaction_0.x);
    state_0[_S497] = vec4<f32>(v_10, reaction_0.y);
    state_0[_S498] = vec4<f32>(w_6, reaction_0.z);
    comp_add1_2(&((*work_3)), &((*work_err_0)), (dot(f_load_0, rg_9.vel_1 + rg_9.vel_err_1 + cross(rg_9.w_4, rotate_0(rg_9.rot_0, _S499 + u_1 - _S500)) + rotate_0(rg_9.rot_0, v_10)) + dot(t_load_0, rg_9.w_4 + rotate_0(rg_9.rot_0, w_6))) * dt_16);
    return;
}

fn chunk_update_1( c_16 : u32,  isl_12 : Island_0,  rg_10 : Rigid_0,  dt_17 : f32,  rml_1 : bool,  step_1 : u32,  contact_6 : bool,  work_4 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S509 : vec3<f32> = vec3<f32>(0.0f);
    var _S510 : u32 = index_0[c_16];
    var peak_1 : f32 = 0.0f;
    var e_4 : u32 = _S510;
    var fi_1 : vec3<f32> = _S509;
    var mi_3 : vec3<f32> = _S509;
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
        var _S511 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var fa_3 : vec4<f32> = scratch_0[_S511];
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            var mi_4 : vec3<f32> = mi_3 + scratch_0[_S511 + u32(1)].xyz;
            fi_1 = fi_1 + fa_3.xyz;
            mi_3 = mi_4;
        }
        else
        {
            var mi_5 : vec3<f32> = mi_3 + scratch_0[_S511 + u32(2)].xyz;
            fi_1 = fi_1 + (vec3<f32>(0) - fa_3.xyz);
            mi_3 = mi_5;
        }
        var _S512 : f32 = max(peak_1, fa_3.w);
        var _S513 : u32 = e_4 + u32(1);
        peak_1 = _S512;
        e_4 = _S513;
    }
    var _S514 : u32 = u32(4) * c_16;
    var u_3 : vec3<f32> = state_0[_S514].xyz;
    var _S515 : u32 = _S514 + u32(1);
    var th_4 : vec3<f32> = state_0[_S515].xyz;
    var _S516 : u32 = _S514 + u32(2);
    var v_12 : vec3<f32> = state_0[_S516].xyz;
    var _S517 : u32 = _S514 + u32(3);
    var w_8 : vec3<f32> = state_0[_S517].xyz;
    var mass_1 : f32 = chunks_0[c_16].center_0.w;
    var _S518 : vec3<f32> = chunks_0[c_16].center_0.xyz;
    var _S519 : vec3<f32> = isl_12.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_10.rot_0, _S518 + u_3 - _S519);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    chunk_external_1(c_16, c_16, rg_10.rot_0, step_1, dt_17, contact_6, &(f_load_1), &(t_load_1));
    record_chunk_load_0(c_16, f_load_1, t_load_1);
    var _S520 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S520;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.alpha_0) + cross(rg_10.w_4, world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.w_4)));
        f_world_3 = f_world_2 - (rg_10.a_7 + cross(rg_10.alpha_0, r_world_1) + cross(rg_10.w_4, cross(rg_10.w_4, r_world_1))) * _S520;
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
    var _S521 : vec4<u32> = chunks_0[c_16].load_range_0;
    var term_6 : u32 = chunks_0[c_16].load_range_0.x;
    loop
    {
        if(term_6 < (_S521.y))
        {
        }
        else
        {
            break;
        }
        var _S522 : u32 = u32(5) * term_6;
        if(((bitcast<vec4<u32>>((loads_0[_S522]))).y) != u32(2))
        {
            term_6 = term_6 + u32(1);
            continue;
        }
        var _S523 : vec3<f32> = vec3<f32>(eval_function_0(term_6, step_1, dt_17, dt_17));
        var m_ext_7 : vec3<f32> = m_ext_5 + loads_0[_S522 + u32(2)].xyz * _S523;
        f_ext_3 = f_ext_3 + loads_0[_S522 + u32(1)].xyz * _S523;
        m_ext_5 = m_ext_7;
        term_6 = term_6 + u32(1);
    }
    var f_17 : vec3<f32> = f_ext_3 + fi_1;
    var m_6 : vec3<f32> = m_ext_5 + mi_3;
    var support_1 : u32 = chunks_0[c_16].info_1.x;
    var _S524 : vec3<f32> = vec3<f32>(state_0[_S515].w, state_0[_S516].w, state_0[_S517].w);
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
        v_13 = _S509;
        w_9 = _S509;
    }
    else
    {
        var _S525 : vec4<f32> = chunks_0[c_16].scale_0;
        var w_10 : vec3<f32> = w_8 + rows_mul_0(chunks_0[c_16].inv0_1, chunks_0[c_16].inv1_1, chunks_0[c_16].inv2_1, m_6) * vec3<f32>((dt_17 * chunks_0[c_16].scale_0.z));
        var _S526 : vec3<f32> = vec3<f32>(dt_17);
        var th_6 : vec3<f32> = th_4 + w_10 * _S526;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_17);
            u_4 = u_3;
            th_5 = _S509;
        }
        else
        {
            var v_14 : vec3<f32> = v_12 + f_17 * vec3<f32>((dt_17 * _S525.y));
            var u_5 : vec3<f32> = u_3 + v_14 * _S526;
            reaction_1 = _S524;
            u_4 = u_5;
            th_5 = v_14;
        }
        var _S527 : vec3<f32> = th_5;
        th_5 = th_6;
        v_13 = _S527;
        w_9 = w_10;
    }
    state_0[_S514] = vec4<f32>(u_4, peak_1);
    state_0[_S515] = vec4<f32>(th_5, reaction_1.x);
    state_0[_S516] = vec4<f32>(v_13, reaction_1.y);
    state_0[_S517] = vec4<f32>(w_9, reaction_1.z);
    comp_add1_2(&((*work_4)), &((*work_err_1)), (dot(f_load_1, rg_10.vel_1 + rg_10.vel_err_1 + cross(rg_10.w_4, rotate_0(rg_10.rot_0, _S518 + u_4 - _S519)) + rotate_0(rg_10.rot_0, v_13)) + dot(t_load_1, rg_10.w_4 + rotate_0(rg_10.rot_0, w_9))) * dt_17);
    return;
}

fn drift_moments_0( c_17 : u32,  tu_0 : ptr<function, vec3<f32>>,  pv_0 : ptr<function, vec3<f32>>)
{
    var _S528 : u32 = u32(4) * c_17;
    var _S529 : vec3<f32> = vec3<f32>((chunks_0[c_17].center_0.w * chunks_0[c_17].scale_0.x));
    (*tu_0) = (*tu_0) + state_0[_S528].xyz * _S529;
    (*pv_0) = (*pv_0) + state_0[_S528 + u32(2)].xyz * _S529;
    return;
}

fn drift_angular_0( c_18 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_13 : vec3<f32> = chunks_0[c_18].center_0.xyz - wcom_1;
    var _S530 : u32 = u32(4) * c_18;
    var _S531 : vec3<f32> = vec3<f32>(chunks_0[c_18].center_0.w);
    var _S532 : vec4<f32> = chunks_0[c_18].inertia0_1;
    var _S533 : vec4<f32> = chunks_0[c_18].inertia1_1;
    var _S534 : vec4<f32> = chunks_0[c_18].inertia2_1;
    var _S535 : vec3<f32> = vec3<f32>(chunks_0[c_18].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_13, state_0[_S530].xyz - tr_0) * _S531 + rows_mul_0(chunks_0[c_18].inertia0_1, chunks_0[c_18].inertia1_1, chunks_0[c_18].inertia2_1, state_0[_S530 + u32(1)].xyz)) * _S535;
    (*lv_0) = (*lv_0) + (cross(r_13, state_0[_S530 + u32(2)].xyz - dv_0) * _S531 + rows_mul_0(_S532, _S533, _S534, state_0[_S530 + u32(3)].xyz)) * _S535;
    return;
}

fn drift_apply_0( c_19 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  phi_0 : vec3<f32>,  dv_1 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_14 : vec3<f32> = chunks_0[c_19].center_0.xyz - wcom_2;
    var _S536 : u32 = u32(4) * c_19;
    state_0[_S536] = vec4<f32>(state_0[_S536].xyz - (tr_1 + cross(phi_0, r_14)), state_0[_S536].w);
    var _S537 : u32 = _S536 + u32(1);
    state_0[_S537] = vec4<f32>(state_0[_S537].xyz - phi_0, state_0[_S537].w);
    var _S538 : u32 = _S536 + u32(2);
    state_0[_S538] = vec4<f32>(state_0[_S538].xyz - (dv_1 + cross(dw_0, r_14)), state_0[_S538].w);
    var _S539 : u32 = _S536 + u32(3);
    state_0[_S539] = vec4<f32>(state_0[_S539].xyz - dw_0, state_0[_S539].w);
    return;
}

fn drift_rigid_0( isl_13 : ptr<function, Island_std430_0>,  rg_11 : ptr<function, Rigid_0>,  tr_2 : vec3<f32>,  phi_1 : vec3<f32>,  dv_2 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_3 : vec3<f32> = (*isl_13).wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_11).rot_0;
    var _S540 : vec3<f32> = rotate_0((*rg_11).rot_0, tr_2 - cross(phi_1, wcom_3));
    var _S541 : vec3<f32> = (*rg_11).pos_1;
    var _S542 : vec3<f32> = (*rg_11).pos_err_1;
    comp_add_0(&(_S541), &(_S542), _S540);
    (*rg_11).pos_1 = _S541;
    (*rg_11).pos_err_1 = _S542;
    (*rg_11).rot_0 = normalized_0(quat_mul_0((*rg_11).rot_0, from_axis_angle_0(phi_1, length(phi_1))));
    var _S543 : vec3<f32> = rotate_0(rot_2, dv_2 + cross(dw_1, (*isl_13).com_0.xyz - wcom_3));
    var _S544 : vec3<f32> = (*rg_11).vel_1;
    var _S545 : vec3<f32> = (*rg_11).vel_err_1;
    comp_add_0(&(_S544), &(_S545), _S543);
    (*rg_11).vel_1 = _S544;
    (*rg_11).vel_err_1 = _S545;
    (*rg_11).w_4 = (*rg_11).w_4 + rotate_0(rot_2, dw_1);
    return;
}

fn drift_rigid_1( isl_14 : Island_0,  rg_12 : ptr<function, Rigid_0>,  tr_3 : vec3<f32>,  phi_2 : vec3<f32>,  dv_3 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = isl_14.wcom_0.xyz;
    var rot_3 : Quat_0 = (*rg_12).rot_0;
    var _S546 : vec3<f32> = rotate_0((*rg_12).rot_0, tr_3 - cross(phi_2, wcom_4));
    var _S547 : vec3<f32> = (*rg_12).pos_1;
    var _S548 : vec3<f32> = (*rg_12).pos_err_1;
    comp_add_0(&(_S547), &(_S548), _S546);
    (*rg_12).pos_1 = _S547;
    (*rg_12).pos_err_1 = _S548;
    (*rg_12).rot_0 = normalized_0(quat_mul_0((*rg_12).rot_0, from_axis_angle_0(phi_2, length(phi_2))));
    var _S549 : vec3<f32> = rotate_0(rot_3, dv_3 + cross(dw_2, isl_14.com_0.xyz - wcom_4));
    var _S550 : vec3<f32> = (*rg_12).vel_1;
    var _S551 : vec3<f32> = (*rg_12).vel_err_1;
    comp_add_0(&(_S550), &(_S551), _S549);
    (*rg_12).vel_1 = _S550;
    (*rg_12).vel_err_1 = _S551;
    (*rg_12).w_4 = (*rg_12).w_4 + rotate_0(rot_3, dw_2);
    return;
}

fn contact_split_at_0( at_6 : u32)
{
    var previous_1 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S552 : u32;
    if(previous_1 == u32(0))
    {
        _S552 = at_6;
    }
    else
    {
        _S552 = min(previous_1, at_6);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S552;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var woke_0 : bool;
    var tid_5 : u32 = thread_2.x;
    var _S553 : u32 = group_2.x;
    var isl_15 : Island_0;
    isl_15.range_0 = islands_0[_S553].range_0;
    isl_15.info_0 = islands_0[_S553].info_0;
    isl_15.com_0 = islands_0[_S553].com_0;
    isl_15.inertia0_0 = islands_0[_S553].inertia0_0;
    isl_15.inertia1_0 = islands_0[_S553].inertia1_0;
    isl_15.inertia2_0 = islands_0[_S553].inertia2_0;
    isl_15.inv0_0 = islands_0[_S553].inv0_0;
    isl_15.inv1_0 = islands_0[_S553].inv1_0;
    isl_15.inv2_0 = islands_0[_S553].inv2_0;
    isl_15.wcom_0 = islands_0[_S553].wcom_0;
    isl_15.winv0_0 = islands_0[_S553].winv0_0;
    isl_15.winv1_0 = islands_0[_S553].winv1_0;
    isl_15.winv2_0 = islands_0[_S553].winv2_0;
    isl_15.rotation_0 = islands_0[_S553].rotation_0;
    isl_15.position_0 = islands_0[_S553].position_0;
    isl_15.position_err_0 = islands_0[_S553].position_err_0;
    isl_15.velocity_0 = islands_0[_S553].velocity_0;
    isl_15.velocity_err_0 = islands_0[_S553].velocity_err_0;
    isl_15.angular_velocity_0 = islands_0[_S553].angular_velocity_0;
    isl_15.done_0 = islands_0[_S553].done_0;
    isl_15.probes_0 = islands_0[_S553].probes_0;
    isl_15.energy_0 = islands_0[_S553].energy_0;
    var driven_0 : bool = (((isl_15.info_0.x) & (u32(2)))) != u32(0);
    var _S554 : bool = !((((isl_15.info_0.x) & (u32(1)))) != u32(0));
    var _S555 : bool;
    if(_S554)
    {
        _S555 = !driven_0;
    }
    else
    {
        _S555 = false;
    }
    var contact_island_0 : bool = (((isl_15.info_0.x) & (u32(4)))) != u32(0);
    var _S556 : bool = (((isl_15.info_0.x) & (u32(16)))) != u32(0);
    var _S557 : bool = tid_5 == u32(0);
    var settled_0 : bool;
    var run_0 : u32;
    if(_S557)
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
    var _S558 : f32 = params_0.dt_0;
    var _S559 : bool = (params_0.fracture_0) != u32(0);
    var _S560 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_13 : Rigid_0 = rigid_of_1(isl_15);
    var work_5 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    settled_0 = _S556;
    var done_1 : u32 = u32(0);
    var woke_1 : bool = false;
    var s_7 : u32 = u32(0);
    loop
    {
        if(s_7 < run_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        var abs_step_1 : u32 = isl_15.info_0.w + s_7 + u32(1);
        var k_21 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var _S561 : bool;
        var settled_1 : bool;
        if((((isl_15.info_0.x) & (u32(32)))) != u32(0))
        {
            if(_S557)
            {
                _S561 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
            }
            else
            {
                _S561 = false;
            }
            if(_S561)
            {
                record_probes_0(isl_15, rg_13, k_21);
            }
            var _S562 : u32 = s_7 + u32(1);
            settled_1 = settled_0;
            done_1 = _S562;
            woke_0 = woke_1;
            var _S563 : u32 = s_7 + u32(1);
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S563;
            continue;
        }
        var i_9 : u32;
        if(settled_0)
        {
            var _S564 : vec3<f32> = vec3<f32>(0.0f);
            var norm_0 : vec3<f32> = _S564;
            var unused0_0 : vec3<f32> = _S564;
            i_9 = isl_15.range_0.x + tid_5;
            loop
            {
                if(i_9 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S565 : f32 = settled_chunk_load_0(i_9, rg_13.rot_0, k_21, _S558, contact_island_0);
                norm_0[i32(0)] = norm_0[i32(0)] + _S565;
                i_9 = i_9 + u32(256);
            }
            group_sum3_0(tid_5, &(norm_0), &(unused0_0));
            if((params_0.solve_mode_0) == u32(1))
            {
                _S561 = (abs(norm_0.x - isl_15.energy_0.z)) > (isl_15.energy_0.w);
            }
            else
            {
                _S561 = false;
            }
            if(_S561)
            {
                settled_1 = false;
                woke_0 = true;
            }
            else
            {
                settled_1 = settled_0;
                woke_0 = woke_1;
            }
        }
        else
        {
            settled_1 = settled_0;
            woke_0 = woke_1;
        }
        if(_S554)
        {
            var _S566 : vec3<f32> = vec3<f32>(0.0f);
            var f_18 : vec3<f32> = _S566;
            var t_14 : vec3<f32> = _S566;
            i_9 = isl_15.range_0.x + tid_5;
            loop
            {
                if(i_9 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                net_load_1(i_9, isl_15, rg_13, k_21, _S558, contact_island_0, &(f_18), &(t_14));
                i_9 = i_9 + u32(256);
            }
            group_sum3_0(tid_5, &(f_18), &(t_14));
            rigid_acceleration_1(isl_15, &(rg_13), f_18, t_14);
        }
        if(settled_1)
        {
            if(_S555)
            {
                integrate_rigid_1(isl_15, &(rg_13), _S558);
            }
            if(_S557)
            {
                _S561 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
            }
            else
            {
                _S561 = false;
            }
            if(_S561)
            {
                record_probes_0(isl_15, rg_13, k_21);
            }
            done_1 = s_7 + u32(1);
            var _S563 : u32 = s_7 + u32(1);
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S563;
            continue;
        }
        i_9 = isl_15.range_0.z + tid_5;
        loop
        {
            if(i_9 < (isl_15.range_0.w))
            {
            }
            else
            {
                break;
            }
            var _S567 : bool = bond_update_0(i_9, _S558, _S559, abs_step_1);
            if(_S567)
            {
                g_halt_0 = u32(1);
            }
            i_9 = i_9 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_20 : u32 = isl_15.range_0.x + tid_5;
        loop
        {
            if(c_20 < (isl_15.range_0.y))
            {
            }
            else
            {
                break;
            }
            chunk_update_1(c_20, isl_15, rg_13, _S558, _S560, k_21, contact_island_0, &(work_5), &(work_err_2));
            c_20 = c_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S555)
        {
            integrate_rigid_1(isl_15, &(rg_13), _S558);
        }
        if(_S554)
        {
            var _S568 : vec3<f32> = isl_15.wcom_0.xyz;
            var _S569 : vec3<f32> = vec3<f32>(0.0f);
            var tu_1 : vec3<f32> = _S569;
            var pv_1 : vec3<f32> = _S569;
            var c_21 : u32 = isl_15.range_0.x + tid_5;
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
            group_sum3_0(tid_5, &(tu_1), &(pv_1));
            var tr_4 : vec3<f32> = tu_1 / vec3<f32>(isl_15.wcom_0.w);
            var dv_4 : vec3<f32> = pv_1 / vec3<f32>(isl_15.wcom_0.w);
            var lu_1 : vec3<f32> = _S569;
            var lv_1 : vec3<f32> = _S569;
            var c_22 : u32 = isl_15.range_0.x + tid_5;
            loop
            {
                if(c_22 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_22, _S568, tr_4, dv_4, &(lu_1), &(lv_1));
                c_22 = c_22 + u32(256);
            }
            group_sum3_0(tid_5, &(lu_1), &(lv_1));
            var phi_3 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lu_1);
            var dw_3 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lv_1);
            var c_23 : u32 = isl_15.range_0.x + tid_5;
            loop
            {
                if(c_23 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_23, _S568, tr_4, phi_3, dv_4, dw_3);
                c_23 = c_23 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_15, &(rg_13), tr_4, phi_3, dv_4, dw_3);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S557)
        {
            _S561 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
        }
        else
        {
            _S561 = false;
        }
        if(_S561)
        {
            record_probes_0(isl_15, rg_13, k_21);
        }
        var _S570 : u32 = s_7 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S570;
            break;
        }
        done_1 = _S570;
        var _S563 : u32 = s_7 + u32(1);
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_7 = _S563;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_5, work_err_2, 0.0f);
    var unused_2 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_5, &(wsum_0), &(unused_2));
    if(_S557)
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
            _S555 = contact_island_0;
        }
        else
        {
            _S555 = false;
        }
        if(_S555)
        {
            contact_split_at_0(isl_15.info_0.w + done_1);
        }
        var _S571 : f32 = wsum_0.x;
        var _S572 : f32 = isl_15.energy_0[i32(0)];
        var _S573 : f32 = isl_15.energy_0[i32(1)];
        comp_add1_2(&(_S572), &(_S573), _S571);
        isl_15.energy_0[i32(0)] = _S572;
        isl_15.energy_0[i32(1)] = _S573 + wsum_0.y;
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
        islands_0[_S553].range_0 = isl_15.range_0;
        islands_0[_S553].info_0 = isl_15.info_0;
        islands_0[_S553].com_0 = isl_15.com_0;
        islands_0[_S553].inertia0_0 = isl_15.inertia0_0;
        islands_0[_S553].inertia1_0 = isl_15.inertia1_0;
        islands_0[_S553].inertia2_0 = isl_15.inertia2_0;
        islands_0[_S553].inv0_0 = isl_15.inv0_0;
        islands_0[_S553].inv1_0 = isl_15.inv1_0;
        islands_0[_S553].inv2_0 = isl_15.inv2_0;
        islands_0[_S553].wcom_0 = isl_15.wcom_0;
        islands_0[_S553].winv0_0 = isl_15.winv0_0;
        islands_0[_S553].winv1_0 = isl_15.winv1_0;
        islands_0[_S553].winv2_0 = isl_15.winv2_0;
        islands_0[_S553].rotation_0 = isl_15.rotation_0;
        islands_0[_S553].position_0 = isl_15.position_0;
        islands_0[_S553].position_err_0 = isl_15.position_err_0;
        islands_0[_S553].velocity_0 = isl_15.velocity_0;
        islands_0[_S553].velocity_err_0 = isl_15.velocity_err_0;
        islands_0[_S553].angular_velocity_0 = isl_15.angular_velocity_0;
        islands_0[_S553].done_0 = isl_15.done_0;
        islands_0[_S553].probes_0 = isl_15.probes_0;
        islands_0[_S553].energy_0 = isl_15.energy_0;
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
    var _S574 : u32 = table_0 + u32(4) * g_4;
    w_11.island_0 = index_0[_S574];
    w_11.begin_1 = index_0[_S574 + u32(1)];
    w_11.end_0 = index_0[_S574 + u32(2)];
    w_11.first_1 = index_0[_S574 + u32(3)];
    return w_11;
}

fn wide_runs_0( isl_16 : ptr<function, Island_std430_0>) -> bool
{
    var _S575 : vec4<u32> = (*isl_16).info_0;
    var _S576 : bool;
    if(((((*isl_16).info_0.z) & (u32(1)))) != u32(0))
    {
        _S576 = true;
    }
    else
    {
        _S576 = (_S575.y) == u32(0);
    }
    if(_S576)
    {
        return false;
    }
    if((((_S575.x) & (u32(4)))) == u32(0))
    {
        _S576 = true;
    }
    else
    {
        var _S577 : bool = contact_stopped_0(&((*isl_16)));
        _S576 = !_S577;
    }
    return _S576;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_6 : u32,  isl_17 : ptr<function, Island_std430_0>) -> bool
{
    if(tid_6 == u32(0))
    {
        var _S578 : bool = wide_runs_0(&((*isl_17)));
        var _S579 : i32;
        if(_S578)
        {
            _S579 = i32(1);
        }
        else
        {
            _S579 = i32(0);
        }
        g_wide_run_0 = u32(_S579);
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

fn contact_stopped_2( _S580 : u32) -> bool
{
    var _S581 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S582 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S582 = true;
    }
    else
    {
        var _S583 : u32 = _S581.y;
        if(_S583 != u32(0))
        {
            _S582 = _S583 <= (islands_0[_S580].info_0.w);
        }
        else
        {
            _S582 = false;
        }
    }
    return _S582;
}

fn wide_runs_1( _S584 : u32) -> bool
{
    var _S585 : vec4<u32> = islands_0[_S584].info_0;
    var _S586 : bool;
    if((((islands_0[_S584].info_0.z) & (u32(1)))) != u32(0))
    {
        _S586 = true;
    }
    else
    {
        _S586 = (_S585.y) == u32(0);
    }
    if(_S586)
    {
        return false;
    }
    if((((_S585.x) & (u32(4)))) == u32(0))
    {
        _S586 = true;
    }
    else
    {
        _S586 = !contact_stopped_2(_S584);
    }
    return _S586;
}

fn wide_enter_1( _S587 : u32,  _S588 : u32) -> bool
{
    if(_S587 == u32(0))
    {
        var _S589 : i32;
        if(wide_runs_1(_S588))
        {
            _S589 = i32(1);
        }
        else
        {
            _S589 = i32(0);
        }
        g_wide_run_0 = u32(_S589);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_wake(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_7 : u32 = thread_3.x;
    var _S590 : u32 = group_3.x;
    var wg_0 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S590);
    if(_S590 != (wg_0.first_1))
    {
        return;
    }
    var _S591 : Island_std430_0 = islands_0[wg_0.island_0];
    var _S592 : vec4<u32> = _S591.info_0;
    var _S593 : u32 = _S591.info_0.x;
    var _S594 : bool;
    if(((_S593 & (u32(16)))) == u32(0))
    {
        _S594 = true;
    }
    else
    {
        var _S595 : bool = wide_enter_1(tid_7, wg_0.island_0);
        _S594 = !_S595;
    }
    if(_S594)
    {
        return;
    }
    var _S596 : Quat_0 = quat_of_0(_S591.rotation_0);
    var _S597 : bool = ((_S593 & (u32(4)))) != u32(0);
    var _S598 : vec3<f32> = vec3<f32>(0.0f);
    var norm_1 : vec3<f32> = _S598;
    var unused_3 : vec3<f32> = _S598;
    var _S599 : vec4<u32> = _S591.range_0;
    var c_24 : u32 = _S591.range_0.x + tid_7;
    loop
    {
        if(c_24 < (_S599.y))
        {
        }
        else
        {
            break;
        }
        var _S600 : u32 = wide_step_0(&(_S591));
        var _S601 : f32 = settled_chunk_load_0(c_24, _S596, _S600, params_0.dt_0, _S597);
        norm_1[i32(0)] = norm_1[i32(0)] + _S601;
        c_24 = c_24 + u32(256);
    }
    group_sum3_0(tid_7, &(norm_1), &(unused_3));
    if(tid_7 == u32(0))
    {
        _S594 = (params_0.solve_mode_0) == u32(1);
    }
    else
    {
        _S594 = false;
    }
    if(_S594)
    {
        _S594 = (abs(norm_1.x - _S591.energy_0.z)) > (_S591.energy_0.w);
    }
    else
    {
        _S594 = false;
    }
    if(_S594)
    {
        islands_0[wg_0.island_0].info_0[i32(0)] = (_S593 & (u32(4294967279)));
        islands_0[wg_0.island_0].info_0[i32(2)] = ((_S592.z) | (u32(4)));
    }
    return;
}

fn wide_store_0( slot_2 : u32,  p_15 : u32,  a_17 : vec3<f32>,  b_39 : vec3<f32>)
{
    var _S602 : u32 = u32(8) * slot_2;
    scratch_0[params_0.wide_base_0 + _S602 + p_15] = vec4<f32>(a_17, 0.0f);
    scratch_0[params_0.wide_base_0 + _S602 + p_15 + u32(1)] = vec4<f32>(b_39, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_8 : u32 = thread_4.x;
    var _S603 : u32 = group_4.x;
    var bond_group_0 : bool = _S603 < (params_0.wide_bond_groups_0);
    var wg_1 : WideGroup_0;
    if(bond_group_0)
    {
        wg_1 = wide_group_0(params_0.wide_bond_table_0, _S603);
    }
    else
    {
        wg_1 = wide_group_0(params_0.wide_chunk_table_0, _S603 - params_0.wide_bond_groups_0);
    }
    var _S604 : WideGroup_0 = wg_1;
    var _S605 : Island_std430_0 = islands_0[wg_1.island_0];
    var _S606 : bool = wide_enter_1(tid_8, wg_1.island_0);
    if(!_S606)
    {
        return;
    }
    var _S607 : u32 = wide_step_0(&(_S605));
    if(bond_group_0)
    {
        var _S608 : vec4<u32> = _S605.info_0;
        if((((_S605.info_0.x) & (u32(16)))) != u32(0))
        {
            return;
        }
        var i_10 : u32 = wg_1.begin_1 + tid_8;
        var _S609 : bool;
        if(i_10 < (wg_1.end_0))
        {
            var _S610 : bool = bond_update_0(i_10, params_0.dt_0, (params_0.fracture_0) != u32(0), _S608.w + u32(1));
            _S609 = _S610;
        }
        else
        {
            _S609 = false;
        }
        if(_S609)
        {
            islands_0[_S604.island_0].info_0[i32(2)] = ((_S608.z) | (u32(2)));
        }
        return;
    }
    var _S611 : u32 = _S605.info_0.x;
    if(((_S611 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S612 : vec3<f32> = vec3<f32>(0.0f);
    var f_19 : vec3<f32> = _S612;
    var t_15 : vec3<f32> = _S612;
    var c_25 : u32 = wg_1.begin_1 + tid_8;
    if(c_25 < (wg_1.end_0))
    {
        var _S613 : Rigid_0 = rigid_of_0(&(_S605));
        net_load_0(c_25, &(_S605), _S613, _S607, params_0.dt_0, ((_S611 & (u32(4)))) != u32(0), &(f_19), &(t_15));
    }
    group_sum3_0(tid_8, &(f_19), &(t_15));
    if(tid_8 == u32(0))
    {
        wide_store_0(_S603 - params_0.wide_bond_groups_0, u32(0), f_19, t_15);
    }
    return;
}

fn wide_partials_0( tid_9 : u32,  first_2 : u32,  count_5 : u32,  p_16 : u32,  a_18 : ptr<function, vec3<f32>>,  b_40 : ptr<function, vec3<f32>>)
{
    var _S614 : vec4<f32> = vec4<f32>(0.0f);
    var x_10 : vec4<f32> = _S614;
    var y_2 : vec4<f32> = _S614;
    var s_8 : u32 = tid_9;
    loop
    {
        if(s_8 < count_5)
        {
        }
        else
        {
            break;
        }
        var _S615 : u32 = u32(8) * (first_2 + s_8);
        x_10 = x_10 + scratch_0[params_0.wide_base_0 + _S615 + p_16];
        y_2 = y_2 + scratch_0[params_0.wide_base_0 + _S615 + p_16 + u32(1)];
        s_8 = s_8 + u32(256);
    }
    group_sum2_1(tid_9, &(x_10), &(y_2));
    (*a_18) = x_10.xyz;
    (*b_40) = y_2.xyz;
    return;
}

fn wide_rigid_frame_0( tid_10 : u32,  isl_20 : ptr<function, Island_std430_0>,  wg_2 : WideGroup_0) -> Rigid_0
{
    var _S616 : Rigid_0 = rigid_of_0(&((*isl_20)));
    var rg_14 : Rigid_0 = _S616;
    if(((((*isl_20).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_20 : vec3<f32>;
        var t_16 : vec3<f32>;
        wide_partials_0(tid_10, wg_2.first_1, (*isl_20).done_0.z, u32(0), &(f_20), &(t_16));
        rigid_acceleration_0(&((*isl_20)), &(rg_14), f_20, t_16);
    }
    return rg_14;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_chunks(@builtin(workgroup_id) group_5 : vec3<u32>, @builtin(local_invocation_id) thread_5 : vec3<u32>)
{
    var tid_11 : u32 = thread_5.x;
    var _S617 : u32 = group_5.x;
    var wg_3 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S617);
    var _S618 : Island_std430_0 = islands_0[wg_3.island_0];
    var _S619 : bool = wide_enter_1(tid_11, wg_3.island_0);
    if(!_S619)
    {
        return;
    }
    var _S620 : u32 = _S618.info_0.x;
    var anchored_0 : bool = ((_S620 & (u32(1)))) != u32(0);
    if(((_S620 & (u32(16)))) != u32(0))
    {
        if(tid_11 == u32(0))
        {
            scratch_0[params_0.wide_base_0 + u32(8) * _S617 + u32(6)] = vec4<f32>(0.0f);
        }
        return;
    }
    var _S621 : Rigid_0 = wide_rigid_frame_0(tid_11, &(_S618), wg_3);
    var work_6 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S622 : vec3<f32> = vec3<f32>(0.0f);
    var tu_2 : vec3<f32> = _S622;
    var pv_2 : vec3<f32> = _S622;
    var c_26 : u32 = wg_3.begin_1 + tid_11;
    if(c_26 < (wg_3.end_0))
    {
        var _S623 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S624 : u32 = wide_step_0(&(_S618));
        chunk_update_0(c_26, &(_S618), _S621, params_0.dt_0, _S623, _S624, ((_S620 & (u32(4)))) != u32(0), &(work_6), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_26, &(tu_2), &(pv_2));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_6, work_err_3, 0.0f);
    var unused_4 : vec3<f32> = _S622;
    group_sum3_0(tid_11, &(wsum_1), &(unused_4));
    var _S625 : bool = !anchored_0;
    if(_S625)
    {
        group_sum3_0(tid_11, &(tu_2), &(pv_2));
    }
    if(tid_11 == u32(0))
    {
        scratch_0[params_0.wide_base_0 + u32(8) * _S617 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S625)
        {
            wide_store_0(_S617, u32(2), tu_2, pv_2);
        }
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var tid_12 : u32 = thread_6.x;
    var _S626 : u32 = group_6.x;
    var wg_4 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S626);
    var isl_21 : Island_std430_0 = islands_0[wg_4.island_0];
    var _S627 : bool;
    if((((islands_0[wg_4.island_0].info_0.x) & (u32(17)))) != u32(0))
    {
        _S627 = true;
    }
    else
    {
        var _S628 : bool = wide_enter_1(tid_12, wg_4.island_0);
        _S627 = !_S628;
    }
    if(_S627)
    {
        return;
    }
    var tu_3 : vec3<f32>;
    var pv_3 : vec3<f32>;
    wide_partials_0(tid_12, wg_4.first_1, isl_21.done_0.z, u32(2), &(tu_3), &(pv_3));
    var _S629 : vec3<f32> = vec3<f32>(isl_21.wcom_0.w);
    var tr_5 : vec3<f32> = tu_3 / _S629;
    var dv_5 : vec3<f32> = pv_3 / _S629;
    var _S630 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S630;
    var lv_2 : vec3<f32> = _S630;
    var c_27 : u32 = wg_4.begin_1 + tid_12;
    if(c_27 < (wg_4.end_0))
    {
        drift_angular_0(c_27, isl_21.wcom_0.xyz, tr_5, dv_5, &(lu_2), &(lv_2));
    }
    group_sum3_0(tid_12, &(lu_2), &(lv_2));
    if(tid_12 == u32(0))
    {
        wide_store_0(_S626, u32(4), lu_2, lv_2);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    var tid_13 : u32 = thread_7.x;
    var _S631 : u32 = group_7.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S631);
    var _S632 : Island_std430_0 = islands_0[wg_5.island_0];
    var _S633 : u32 = _S632.info_0.x;
    var _S634 : bool;
    if(((_S633 & (u32(1)))) != u32(0))
    {
        _S634 = true;
    }
    else
    {
        var _S635 : bool = wide_enter_1(tid_13, wg_5.island_0);
        _S634 = !_S635;
    }
    if(_S634)
    {
        return;
    }
    if(((_S633 & (u32(16)))) != u32(0))
    {
        if(_S631 != (wg_5.first_1))
        {
            return;
        }
        var _S636 : Rigid_0 = wide_rigid_frame_0(tid_13, &(_S632), wg_5);
        var rs_0 : Rigid_0 = _S636;
        if(tid_13 != u32(0))
        {
            _S634 = true;
        }
        else
        {
            _S634 = ((_S633 & (u32(2)))) != u32(0);
        }
        if(_S634)
        {
            return;
        }
        integrate_rigid_0(&(_S632), &(rs_0), params_0.dt_0);
        islands_0[wg_5.island_0].rotation_0 = quat_vec_0(rs_0.rot_0);
        islands_0[wg_5.island_0].position_0 = vec4<f32>(rs_0.pos_1, 0.0f);
        islands_0[wg_5.island_0].position_err_0 = vec4<f32>(rs_0.pos_err_1, 0.0f);
        islands_0[wg_5.island_0].velocity_0 = vec4<f32>(rs_0.vel_1, 0.0f);
        islands_0[wg_5.island_0].velocity_err_0 = vec4<f32>(rs_0.vel_err_1, 0.0f);
        islands_0[wg_5.island_0].angular_velocity_0 = vec4<f32>(rs_0.w_4, 0.0f);
        return;
    }
    var _S637 : u32 = _S632.done_0.z;
    var tu_4 : vec3<f32>;
    var pv_4 : vec3<f32>;
    wide_partials_0(tid_13, wg_5.first_1, _S637, u32(2), &(tu_4), &(pv_4));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_0(tid_13, wg_5.first_1, _S637, u32(4), &(lu_3), &(lv_3));
    var _S638 : vec4<f32> = _S632.wcom_0;
    var _S639 : vec3<f32> = vec3<f32>(_S632.wcom_0.w);
    var tr_6 : vec3<f32> = tu_4 / _S639;
    var dv_6 : vec3<f32> = pv_4 / _S639;
    var phi_4 : vec3<f32> = rows_mul_0(_S632.winv0_0, _S632.winv1_0, _S632.winv2_0, lu_3);
    var dw_4 : vec3<f32> = rows_mul_0(_S632.winv0_0, _S632.winv1_0, _S632.winv2_0, lv_3);
    var c_28 : u32 = wg_5.begin_1 + tid_13;
    if(c_28 < (wg_5.end_0))
    {
        drift_apply_0(c_28, _S638.xyz, tr_6, phi_4, dv_6, dw_4);
    }
    if(_S631 != (wg_5.first_1))
    {
        return;
    }
    var _S640 : Rigid_0 = wide_rigid_frame_0(tid_13, &(_S632), wg_5);
    var rg_15 : Rigid_0 = _S640;
    if(tid_13 != u32(0))
    {
        return;
    }
    if(!(((_S633 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S632), &(rg_15), params_0.dt_0);
        drift_rigid_0(&(_S632), &(rg_15), tr_6, phi_4, dv_6, dw_4);
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
    var tid_14 : u32 = thread_8.x;
    var _S641 : u32 = group_8.x;
    var wg_6 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S641);
    if(_S641 != (wg_6.first_1))
    {
        return;
    }
    var _S642 : Island_std430_0 = islands_0[wg_6.island_0];
    var isl_22 : Island_0;
    isl_22.range_0 = _S642.range_0;
    isl_22.info_0 = _S642.info_0;
    isl_22.com_0 = _S642.com_0;
    isl_22.inertia0_0 = _S642.inertia0_0;
    isl_22.inertia1_0 = _S642.inertia1_0;
    isl_22.inertia2_0 = _S642.inertia2_0;
    isl_22.inv0_0 = _S642.inv0_0;
    isl_22.inv1_0 = _S642.inv1_0;
    isl_22.inv2_0 = _S642.inv2_0;
    isl_22.wcom_0 = _S642.wcom_0;
    isl_22.winv0_0 = _S642.winv0_0;
    isl_22.winv1_0 = _S642.winv1_0;
    isl_22.winv2_0 = _S642.winv2_0;
    isl_22.rotation_0 = _S642.rotation_0;
    isl_22.position_0 = _S642.position_0;
    isl_22.position_err_0 = _S642.position_err_0;
    isl_22.velocity_0 = _S642.velocity_0;
    isl_22.velocity_err_0 = _S642.velocity_err_0;
    isl_22.angular_velocity_0 = _S642.angular_velocity_0;
    isl_22.done_0 = _S642.done_0;
    isl_22.probes_0 = _S642.probes_0;
    isl_22.energy_0 = _S642.energy_0;
    var _S643 : bool = wide_enter_0(tid_14, &(_S642));
    if(!_S643)
    {
        return;
    }
    var work_7 : vec3<f32>;
    var unused_5 : vec3<f32>;
    wide_partials_0(tid_14, wg_6.first_1, isl_22.done_0.z, u32(6), &(work_7), &(unused_5));
    if(tid_14 != u32(0))
    {
        return;
    }
    var k_22 : u32 = wide_step_1(isl_22);
    if((isl_22.probes_0.y) > (isl_22.probes_0.x))
    {
        record_probes_0(isl_22, rigid_of_1(isl_22), k_22);
    }
    var halt_0 : bool = (((isl_22.info_0.z) & (u32(2)))) != u32(0);
    var _S644 : bool;
    if(halt_0)
    {
        _S644 = (((isl_22.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        _S644 = false;
    }
    if(_S644)
    {
        contact_split_at_0(isl_22.info_0.w + u32(1));
    }
    var _S645 : f32 = work_7.x;
    var _S646 : f32 = isl_22.energy_0[i32(0)];
    var _S647 : f32 = isl_22.energy_0[i32(1)];
    comp_add1_2(&(_S646), &(_S647), _S645);
    isl_22.energy_0[i32(0)] = _S646;
    isl_22.energy_0[i32(1)] = _S647 + work_7.y;
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

fn sv_0( c_29 : u32,  slot_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * c_29 + slot_3;
}

fn project_load_slot_0( tid_15 : u32,  isl_23 : ptr<function, Island_std430_0>,  slot_4 : u32)
{
    var _S648 : u32;
    var _S649 : vec3<f32> = vec3<f32>(0.0f);
    var net_f_0 : vec3<f32> = _S649;
    var net_m_0 : vec3<f32> = _S649;
    var _S650 : vec4<u32> = (*isl_23).range_0;
    var _S651 : u32 = (*isl_23).range_0.x + tid_15;
    var c_30 : u32 = _S651;
    loop
    {
        var _S652 : u32 = _S650.y;
        _S648 = _S652;
        if(c_30 < _S652)
        {
        }
        else
        {
            break;
        }
        var fi_2 : vec3<f32> = scratch_0[sv_0(c_30, slot_4)].xyz;
        net_f_0 = net_f_0 + fi_2;
        net_m_0 = net_m_0 + (cross(chunks_0[c_30].center_0.xyz - (*isl_23).com_0.xyz, fi_2) + scratch_0[sv_0(c_30, slot_4 + u32(1))].xyz);
        c_30 = c_30 + u32(256);
    }
    group_sum3_0(tid_15, &(net_f_0), &(net_m_0));
    var _S653 : vec4<f32> = (*isl_23).com_0;
    var _S654 : vec3<f32> = net_f_0 / vec3<f32>((*isl_23).com_0.w);
    var _S655 : vec3<f32> = rows_mul_0((*isl_23).inv0_0, (*isl_23).inv1_0, (*isl_23).inv2_0, net_m_0);
    c_30 = _S651;
    loop
    {
        if(c_30 < _S648)
        {
        }
        else
        {
            break;
        }
        var _S656 : u32 = sv_0(c_30, slot_4);
        scratch_0[_S656] = vec4<f32>(scratch_0[_S656].xyz - (_S654 + cross(_S655, chunks_0[c_30].center_0.xyz - _S653.xyz)) * vec3<f32>(chunks_0[c_30].center_0.w), 0.0f);
        var _S657 : u32 = sv_0(c_30, slot_4 + u32(1));
        scratch_0[_S657] = vec4<f32>(scratch_0[_S657].xyz - rows_mul_0(chunks_0[c_30].inertia0_1, chunks_0[c_30].inertia1_1, chunks_0[c_30].inertia2_1, _S655), 0.0f);
        c_30 = c_30 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn island_dot_0( tid_16 : u32,  c0_0 : u32,  c1_0 : u32,  sa_0 : u32,  sb_0 : u32) -> f32
{
    var _S658 : vec4<f32> = vec4<f32>(0.0f);
    var acc_0 : vec4<f32> = _S658;
    var unused_6 : vec4<f32> = _S658;
    var c_31 : u32 = c0_0 + tid_16;
    loop
    {
        if(c_31 < c1_0)
        {
        }
        else
        {
            break;
        }
        acc_0[i32(0)] = acc_0[i32(0)] + (dot(scratch_0[sv_0(c_31, sa_0)].xyz, scratch_0[sv_0(c_31, sb_0)].xyz) + dot(scratch_0[sv_0(c_31, sa_0 + u32(1))].xyz, scratch_0[sv_0(c_31, sb_0 + u32(1))].xyz));
        c_31 = c_31 + u32(256);
    }
    group_sum2_0(tid_16, &(acc_0), &(unused_6));
    return acc_0.x;
}

fn static_kinematics_0( _S659 : u32,  _S660 : ptr<function, vec3<f32>>,  _S661 : ptr<function, vec3<f32>>)
{
    var ca_1 : u32 = bonds_0[_S659].law_0.ids_0.y;
    var cb_4 : u32 = bonds_0[_S659].law_0.ids_0.z;
    var _S662 : u32 = u32(4) * cb_4;
    var _S663 : u32 = u32(4) * ca_1;
    var _S664 : u32 = _S662 + u32(1);
    var _S665 : u32 = _S663 + u32(1);
    var _S666 : u32 = sv_0(cb_4, u32(22));
    var _S667 : u32 = sv_0(ca_1, u32(22));
    var dth_0 : vec3<f32> = state_0[_S664].xyz - state_0[_S665].xyz + (scratch_0[_S666].xyz - scratch_0[_S667].xyz);
    (*_S660) = to_local_0(_S659, state_0[_S662].xyz - state_0[_S663].xyz + (scratch_0[sv_0(cb_4, u32(21))].xyz - scratch_0[sv_0(ca_1, u32(21))].xyz) + (cross(state_0[_S664].xyz + scratch_0[_S666].xyz, bonds_0[_S659].rb_0.xyz) - cross(state_0[_S665].xyz + scratch_0[_S667].xyz, bonds_0[_S659].ra_0.xyz)));
    (*_S661) = to_local_0(_S659, dth_0);
    return;
}

fn static_response_0( i_11 : u32) -> JointResponse_0
{
    var d_lin_6 : vec3<f32>;
    var d_ang_4 : vec3<f32>;
    static_kinematics_0(i_11, &(d_lin_6), &(d_ang_4));
    var _S668 : JointBond_std430_0 = bonds_0[i_11].law_0;
    var _S669 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S668.ids_0.x];
    var _S670 : JointState_std430_0 = bond_dyn_0[i_11].js_0;
    var _S671 : JointResponse_0 = joint_evaluate_2(&(_S669), &(_S668), &(_S670), d_lin_6, d_ang_4, 0.0f, false);
    return _S671;
}

fn gather_loads_0( c_32 : u32,  fi_3 : ptr<function, vec3<f32>>,  mi_6 : ptr<function, vec3<f32>>)
{
    var _S672 : vec3<f32> = vec3<f32>(0.0f);
    (*fi_3) = _S672;
    (*mi_6) = _S672;
    var e_5 : u32 = index_0[c_32];
    loop
    {
        if(e_5 < index_0[c_32 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_4 : u32 = index_0[e_5];
        var bond_0 : u32 = (entry_4 >> (u32(1)));
        if(((entry_4 & (u32(1)))) == u32(0))
        {
            var _S673 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) + scratch_0[_S673].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S673 + u32(1)].xyz;
        }
        else
        {
            var _S674 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) - scratch_0[_S674].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S674 + u32(2)].xyz;
        }
        e_5 = e_5 + u32(1);
    }
    return;
}

fn bond_load_magnitude2_0( c_33 : u32) -> f32
{
    var e_6 : u32 = index_0[c_33];
    var m_7 : f32 = 0.0f;
    loop
    {
        if(e_6 < index_0[c_33 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_5 : u32 = index_0[e_6];
        var _S675 : u32 = u32(3) * ((entry_5 >> (u32(1))));
        var f_21 : vec3<f32> = scratch_0[_S675].xyz;
        var t_17 : vec3<f32>;
        if(((entry_5 & (u32(1)))) == u32(0))
        {
            t_17 = scratch_0[_S675 + u32(1)].xyz;
        }
        else
        {
            t_17 = scratch_0[_S675 + u32(2)].xyz;
        }
        var m_8 : f32 = m_7 + (dot(f_21, f_21) + dot(t_17, t_17));
        e_6 = e_6 + u32(1);
        m_7 = m_8;
    }
    return m_7;
}

fn fixed_mask_0( c_34 : u32) -> u32
{
    var support_2 : u32 = chunks_0[c_34].info_1.x;
    var _S676 : u32;
    if(support_2 == u32(1))
    {
        _S676 = u32(63);
    }
    else
    {
        if(support_2 == u32(2))
        {
            _S676 = u32(7);
        }
        else
        {
            _S676 = u32(0);
        }
    }
    return _S676;
}

fn hold_0( mask_0 : u32,  lin_0 : ptr<function, vec4<f32>>,  ang_0 : ptr<function, vec4<f32>>,  keep_lin_0 : vec4<f32>,  keep_ang_0 : vec4<f32>)
{
    var d_15 : u32 = u32(0);
    loop
    {
        if(d_15 < u32(3))
        {
        }
        else
        {
            break;
        }
        if(((mask_0 & (((u32(1) << (d_15)))))) != u32(0))
        {
            (*lin_0)[d_15] = keep_lin_0[d_15];
        }
        if(((mask_0 & (((u32(1) << ((d_15 + u32(3)))))))) != u32(0))
        {
            (*ang_0)[d_15] = keep_ang_0[d_15];
        }
        d_15 = d_15 + u32(1);
    }
    return;
}

fn statics_bond_slot_0( i_12 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * i_12;
}

fn store_inverse_0( c_35 : u32,  a_19 : array<f32, i32(36)>)
{
    var j_6 : u32;
    var sum_4 : f32;
    var l_4 : array<f32, i32(36)>;
    var k_23 : u32 = u32(0);
    loop
    {
        if(k_23 < u32(36))
        {
        }
        else
        {
            break;
        }
        l_4[k_23] = 0.0f;
        k_23 = k_23 + u32(1);
    }
    var spd_0 : bool = true;
    var i_13 : u32 = u32(0);
    loop
    {
        var _S677 : bool;
        if(i_13 < u32(6))
        {
            _S677 = spd_0;
        }
        else
        {
            _S677 = false;
        }
        if(_S677)
        {
        }
        else
        {
            break;
        }
        j_6 = u32(0);
        loop
        {
            if(j_6 <= i_13)
            {
            }
            else
            {
                break;
            }
            var _S678 : u32 = i_13 * u32(6);
            var _S679 : u32 = _S678 + j_6;
            k_23 = u32(0);
            sum_4 = a_19[_S679];
            loop
            {
                if(k_23 < j_6)
                {
                }
                else
                {
                    break;
                }
                var sum_5 : f32 = sum_4 - l_4[_S678 + k_23] * l_4[j_6 * u32(6) + k_23];
                k_23 = k_23 + u32(1);
                sum_4 = sum_5;
            }
            if(i_13 == j_6)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S678 + i_13] = sqrt(sum_4);
            }
            else
            {
                l_4[_S679] = sum_4 / l_4[j_6 * u32(6) + j_6];
            }
            j_6 = j_6 + u32(1);
        }
        i_13 = i_13 + u32(1);
    }
    var inv_0 : array<f32, i32(36)>;
    if(!spd_0)
    {
        k_23 = u32(0);
        loop
        {
            if(k_23 < u32(36))
            {
            }
            else
            {
                break;
            }
            inv_0[k_23] = 0.0f;
            k_23 = k_23 + u32(1);
        }
        k_23 = u32(0);
        loop
        {
            if(k_23 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S680 : u32 = k_23 * u32(6) + k_23;
            if((a_19[_S680]) > 0.0f)
            {
                sum_4 = 1.0f / a_19[_S680];
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S680] = sum_4;
            k_23 = k_23 + u32(1);
        }
    }
    else
    {
        j_6 = u32(0);
        loop
        {
            if(j_6 < u32(6))
            {
            }
            else
            {
                break;
            }
            var y_3 : array<f32, i32(6)>;
            y_3[i32(0)] = 0.0f;
            y_3[i32(1)] = 0.0f;
            y_3[i32(2)] = 0.0f;
            y_3[i32(3)] = 0.0f;
            y_3[i32(4)] = 0.0f;
            y_3[i32(5)] = 0.0f;
            i_13 = u32(0);
            loop
            {
                if(i_13 < u32(6))
                {
                }
                else
                {
                    break;
                }
                if(i_13 == j_6)
                {
                    sum_4 = 1.0f;
                }
                else
                {
                    sum_4 = 0.0f;
                }
                k_23 = u32(0);
                var s_9 : f32 = sum_4;
                loop
                {
                    if(k_23 < i_13)
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_10 : f32 = s_9 - l_4[i_13 * u32(6) + k_23] * y_3[k_23];
                    k_23 = k_23 + u32(1);
                    s_9 = s_10;
                }
                y_3[i_13] = s_9 / l_4[i_13 * u32(6) + i_13];
                i_13 = i_13 + u32(1);
            }
            var x_11 : array<f32, i32(6)>;
            x_11[i32(0)] = 0.0f;
            x_11[i32(1)] = 0.0f;
            x_11[i32(2)] = 0.0f;
            x_11[i32(3)] = 0.0f;
            x_11[i32(4)] = 0.0f;
            x_11[i32(5)] = 0.0f;
            var ii_2 : u32 = u32(0);
            loop
            {
                if(ii_2 < u32(6))
                {
                }
                else
                {
                    break;
                }
                var i_14 : u32 = u32(5) - ii_2;
                k_23 = i_14 + u32(1);
                sum_4 = y_3[i_14];
                loop
                {
                    if(k_23 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_11 : f32 = sum_4 - l_4[k_23 * u32(6) + i_14] * x_11[k_23];
                    k_23 = k_23 + u32(1);
                    sum_4 = s_11;
                }
                x_11[i_14] = sum_4 / l_4[i_14 * u32(6) + i_14];
                ii_2 = ii_2 + u32(1);
            }
            var i_15 : u32 = u32(0);
            loop
            {
                if(i_15 < u32(6))
                {
                }
                else
                {
                    break;
                }
                inv_0[i_15 * u32(6) + j_6] = x_11[i_15];
                i_15 = i_15 + u32(1);
            }
            j_6 = j_6 + u32(1);
        }
    }
    j_6 = u32(0);
    loop
    {
        if(j_6 < u32(9))
        {
        }
        else
        {
            break;
        }
        var _S681 : u32 = u32(4) * j_6;
        scratch_0[sv_0(c_35, u32(12) + j_6)] = vec4<f32>(inv_0[_S681], inv_0[_S681 + u32(1)], inv_0[_S681 + u32(2)], inv_0[_S681 + u32(3)]);
        j_6 = j_6 + u32(1);
    }
    return;
}

fn assemble_block_0( c_36 : u32)
{
    var p_17 : u32;
    var r_15 : u32;
    var a_20 : array<f32, i32(36)>;
    var k_24 : u32 = u32(0);
    loop
    {
        if(k_24 < u32(36))
        {
        }
        else
        {
            break;
        }
        a_20[k_24] = 0.0f;
        k_24 = k_24 + u32(1);
    }
    var e_7 : u32 = index_0[c_36];
    loop
    {
        if(e_7 < index_0[c_36 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_6 : u32 = index_0[e_7];
        var i_16 : u32 = (entry_6 >> (u32(1)));
        var _S682 : bool = ((entry_6 & (u32(1)))) != u32(0);
        var _S683 : u32 = statics_bond_slot_0(i_16);
        var _S684 : vec4<f32> = scratch_0[_S683];
        var _S685 : vec4<f32> = scratch_0[_S683 + u32(1)];
        p_17 = u32(0);
        loop
        {
            if(p_17 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S686 : u32 = p_17 % u32(3);
            var t_18 : vec3<f32>;
            if(_S686 == u32(0))
            {
                t_18 = bonds_0[i_16].t1_0.xyz;
            }
            else
            {
                if(_S686 == u32(1))
                {
                    t_18 = bonds_0[i_16].t2_0.xyz;
                }
                else
                {
                    t_18 = bonds_0[i_16].normal_0.xyz;
                }
            }
            var _S687 : bool = p_17 < u32(3);
            var row_u_0 : vec3<f32>;
            var row_t_0 : vec3<f32>;
            if(_S687)
            {
                if(_S682)
                {
                    row_u_0 = t_18;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_18);
                }
                if(_S682)
                {
                    row_t_0 = cross(bonds_0[i_16].rb_0.xyz, t_18);
                }
                else
                {
                    row_t_0 = (vec3<f32>(0) - cross(bonds_0[i_16].ra_0.xyz, t_18));
                }
            }
            else
            {
                var _S688 : vec3<f32> = vec3<f32>(0.0f);
                if(_S682)
                {
                    row_u_0 = t_18;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_18);
                }
                var _S689 : vec3<f32> = row_u_0;
                row_u_0 = _S688;
                row_t_0 = _S689;
            }
            var kp_0 : f32;
            if(_S687)
            {
                kp_0 = _S684[p_17];
            }
            else
            {
                kp_0 = _S685[p_17 - u32(3)];
            }
            if(kp_0 == 0.0f)
            {
                p_17 = p_17 + u32(1);
                continue;
            }
            var _S690 : array<f32, i32(6)> = array<f32, i32(6)>( row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z );
            r_15 = u32(0);
            loop
            {
                if(r_15 < u32(6))
                {
                }
                else
                {
                    break;
                }
                var q_17 : u32 = u32(0);
                loop
                {
                    if(q_17 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_20[r_15 * u32(6) + q_17] = a_20[r_15 * u32(6) + q_17] + kp_0 * _S690[r_15] * _S690[q_17];
                    q_17 = q_17 + u32(1);
                }
                r_15 = r_15 + u32(1);
            }
            p_17 = p_17 + u32(1);
        }
        e_7 = e_7 + u32(1);
    }
    var _S691 : u32 = fixed_mask_0(c_36);
    p_17 = u32(0);
    loop
    {
        if(p_17 < u32(6))
        {
        }
        else
        {
            break;
        }
        if(((_S691 & (((u32(1) << (p_17)))))) != u32(0))
        {
            r_15 = u32(0);
            loop
            {
                if(r_15 < u32(6))
                {
                }
                else
                {
                    break;
                }
                a_20[p_17 * u32(6) + r_15] = 0.0f;
                a_20[r_15 * u32(6) + p_17] = 0.0f;
                r_15 = r_15 + u32(1);
            }
            a_20[p_17 * u32(6) + p_17] = 1.0f;
        }
        p_17 = p_17 + u32(1);
    }
    p_17 = u32(0);
    loop
    {
        if(p_17 < u32(6))
        {
        }
        else
        {
            break;
        }
        if((a_20[p_17 * u32(6) + p_17]) == 0.0f)
        {
            a_20[p_17 * u32(6) + p_17] = 1.0f;
        }
        p_17 = p_17 + u32(1);
    }
    store_inverse_0(c_36, a_20);
    return;
}

fn block_get_0( c_37 : u32,  i_17 : u32,  j_7 : u32) -> f32
{
    var k_25 : u32 = i_17 * u32(6) + j_7;
    return scratch_0[sv_0(c_37, u32(12) + k_25 / u32(4))][k_25 % u32(4)];
}

fn precondition_0( c_38 : u32)
{
    var _S692 : array<f32, i32(6)> = array<f32, i32(6)>( scratch_0[sv_0(c_38, u32(4))].x, scratch_0[sv_0(c_38, u32(4))].y, scratch_0[sv_0(c_38, u32(4))].z, scratch_0[sv_0(c_38, u32(5))].x, scratch_0[sv_0(c_38, u32(5))].y, scratch_0[sv_0(c_38, u32(5))].z );
    var z_1 : array<f32, i32(6)>;
    var i_18 : u32 = u32(0);
    loop
    {
        if(i_18 < u32(6))
        {
        }
        else
        {
            break;
        }
        var j_8 : u32 = u32(0);
        var s_12 : f32 = 0.0f;
        loop
        {
            if(j_8 < u32(6))
            {
            }
            else
            {
                break;
            }
            var s_13 : f32 = s_12 + block_get_0(c_38, i_18, j_8) * _S692[j_8];
            j_8 = j_8 + u32(1);
            s_12 = s_13;
        }
        z_1[i_18] = s_12;
        i_18 = i_18 + u32(1);
    }
    scratch_0[sv_0(c_38, u32(6))] = vec4<f32>(z_1[i32(0)], z_1[i32(1)], z_1[i32(2)], 0.0f);
    scratch_0[sv_0(c_38, u32(7))] = vec4<f32>(z_1[i32(3)], z_1[i32(4)], z_1[i32(5)], 0.0f);
    return;
}

fn project_displacement_slot_0( tid_17 : u32,  isl_24 : ptr<function, Island_std430_0>,  slot_5 : u32)
{
    var _S693 : u32;
    var _S694 : vec3<f32> = vec3<f32>(0.0f);
    var p_18 : vec3<f32> = _S694;
    var l_5 : vec3<f32> = _S694;
    var _S695 : vec4<u32> = (*isl_24).range_0;
    var _S696 : u32 = (*isl_24).range_0.x + tid_17;
    var c_39 : u32 = _S696;
    loop
    {
        var _S697 : u32 = _S695.y;
        _S693 = _S697;
        if(c_39 < _S697)
        {
        }
        else
        {
            break;
        }
        var u_6 : vec3<f32> = scratch_0[sv_0(c_39, slot_5)].xyz;
        var th_7 : vec3<f32> = scratch_0[sv_0(c_39, slot_5 + u32(1))].xyz;
        var r_16 : vec3<f32> = chunks_0[c_39].center_0.xyz - (*isl_24).com_0.xyz;
        var _S698 : vec3<f32> = vec3<f32>(chunks_0[c_39].center_0.w);
        p_18 = p_18 + u_6 * _S698;
        l_5 = l_5 + (cross(r_16, u_6) * _S698 + rows_mul_0(chunks_0[c_39].inertia0_1, chunks_0[c_39].inertia1_1, chunks_0[c_39].inertia2_1, th_7));
        c_39 = c_39 + u32(256);
    }
    group_sum3_0(tid_17, &(p_18), &(l_5));
    var _S699 : vec4<f32> = (*isl_24).com_0;
    var _S700 : vec3<f32> = p_18 / vec3<f32>((*isl_24).com_0.w);
    var _S701 : vec3<f32> = rows_mul_0((*isl_24).inv0_0, (*isl_24).inv1_0, (*isl_24).inv2_0, l_5);
    c_39 = _S696;
    loop
    {
        if(c_39 < _S693)
        {
        }
        else
        {
            break;
        }
        var _S702 : u32 = sv_0(c_39, slot_5);
        scratch_0[_S702] = vec4<f32>(scratch_0[_S702].xyz - _S700 - cross(_S701, chunks_0[c_39].center_0.xyz - _S699.xyz), 0.0f);
        var _S703 : u32 = sv_0(c_39, slot_5 + u32(1));
        scratch_0[_S703] = vec4<f32>(scratch_0[_S703].xyz - _S701, 0.0f);
        c_39 = c_39 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn statics_result_slot_0( island_1 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * params_0.statics_bonds_0 + island_1;
}

fn write_bond_loads_0( _S704 : u32,  _S705 : u32,  _S706 : vec3<f32>,  _S707 : vec3<f32>,  _S708 : f32)
{
    var _S709 : vec3<f32> = to_body_0(_S705, _S706);
    var _S710 : vec3<f32> = to_body_0(_S705, _S707);
    var _S711 : u32 = u32(3) * _S704;
    scratch_0[_S711] = vec4<f32>(_S709, _S708);
    scratch_0[_S711 + u32(1)] = vec4<f32>(_S710 + cross(bonds_0[_S705].ra_0.xyz, _S709), 0.0f);
    scratch_0[_S711 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S710) + cross(bonds_0[_S705].rb_0.xyz, (vec3<f32>(0) - _S709)), 0.0f);
    return;
}

fn static_kinematics_1( _S712 : u32,  _S713 : ptr<function, vec3<f32>>,  _S714 : ptr<function, vec3<f32>>)
{
    var ca_2 : u32 = bonds_0[_S712].law_0.ids_0.y;
    var cb_5 : u32 = bonds_0[_S712].law_0.ids_0.z;
    var _S715 : u32 = u32(4) * cb_5;
    var _S716 : u32 = u32(4) * ca_2;
    var _S717 : u32 = _S715 + u32(1);
    var _S718 : u32 = _S716 + u32(1);
    var _S719 : u32 = sv_0(cb_5, u32(22));
    var _S720 : u32 = sv_0(ca_2, u32(22));
    var dth_1 : vec3<f32> = state_0[_S717].xyz - state_0[_S718].xyz + (scratch_0[_S719].xyz - scratch_0[_S720].xyz);
    (*_S713) = to_local_0(_S712, state_0[_S715].xyz - state_0[_S716].xyz + (scratch_0[sv_0(cb_5, u32(21))].xyz - scratch_0[sv_0(ca_2, u32(21))].xyz) + (cross(state_0[_S717].xyz + scratch_0[_S719].xyz, bonds_0[_S712].rb_0.xyz) - cross(state_0[_S718].xyz + scratch_0[_S720].xyz, bonds_0[_S712].ra_0.xyz)));
    (*_S714) = to_local_0(_S712, dth_1);
    return;
}

fn bond_kinematics_0( _S721 : u32,  _S722 : vec3<f32>,  _S723 : vec3<f32>,  _S724 : vec3<f32>,  _S725 : vec3<f32>,  _S726 : ptr<function, vec3<f32>>,  _S727 : ptr<function, vec3<f32>>)
{
    (*_S726) = to_local_0(_S721, _S724 + cross(_S725, bonds_0[_S721].rb_0.xyz) - (_S722 + cross(_S723, bonds_0[_S721].ra_0.xyz)));
    (*_S727) = to_local_0(_S721, _S725 - _S723);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_statics(@builtin(workgroup_id) group_9 : vec3<u32>, @builtin(local_invocation_id) thread_9 : vec3<u32>)
{
    var i_19 : u32;
    var converged_0 : bool;
    var c_40 : u32;
    var tid_18 : u32 = thread_9.x;
    var _S728 : u32 = group_9.x;
    var _S729 : Island_std430_0 = islands_0[_S728];
    var _S730 : vec4<u32> = _S729.info_0;
    var _S731 : u32 = _S729.info_0.z;
    if(((_S731 & (u32(8)))) == u32(0))
    {
        return;
    }
    var free_0 : bool = (((_S730.x) & (u32(1)))) == u32(0);
    var c0_1 : u32 = _S729.range_0.x;
    var c1_1 : u32 = _S729.range_0.y;
    var b0_0 : u32 = _S729.range_0.z;
    var _S732 : u32 = _S729.range_0.w;
    var _S733 : u32 = c0_1 + tid_18;
    var c_41 : u32 = _S733;
    loop
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        var _S734 : vec4<f32> = vec4<f32>(0.0f);
        scratch_0[sv_0(c_41, u32(21))] = _S734;
        scratch_0[sv_0(c_41, u32(22))] = _S734;
        c_41 = c_41 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    if(free_0)
    {
        project_load_slot_0(tid_18, &(_S729), u32(0));
    }
    var _S735 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(0), u32(0));
    var _S736 : f32 = max(sqrt(_S735), 1.00000000317107685e-30f);
    var _S737 : f32 = params_0.statics_tol_0;
    var _S738 : u32 = min(params_0.statics_cg_0, u32(20) * (c1_1 - c0_1) * u32(6) + u32(200));
    var previous_2 : f32 = 1.00000001504746622e+30f;
    var residual_0 : f32 = 0.0f;
    var newton_0 : u32 = u32(0);
    var cg_total_0 : u32 = u32(0);
    loop
    {
        if(newton_0 < (params_0.statics_newton_0))
        {
        }
        else
        {
            converged_0 = false;
            break;
        }
        var _S739 : u32 = b0_0 + tid_18;
        i_19 = _S739;
        loop
        {
            if(i_19 < _S732)
            {
            }
            else
            {
                break;
            }
            var resp_3 : JointResponse_0 = static_response_0(i_19);
            write_bond_loads_0(i_19, i_19, resp_3.force_lin_1, resp_3.force_ang_1, 0.0f);
            i_19 = i_19 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S740 : vec4<f32> = vec4<f32>(0.0f);
        var magnitude_0 : vec4<f32> = _S740;
        var unused_m_0 : vec4<f32> = _S740;
        c_41 = _S733;
        loop
        {
            if(c_41 < c1_1)
            {
            }
            else
            {
                break;
            }
            var fi_4 : vec3<f32>;
            var mi_7 : vec3<f32>;
            gather_loads_0(c_41, &(fi_4), &(mi_7));
            magnitude_0[i32(0)] = magnitude_0[i32(0)] + bond_load_magnitude2_0(c_41);
            var r_lin_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_41, u32(0))].xyz + fi_4, 0.0f);
            var r_ang_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_41, u32(1))].xyz + mi_7, 0.0f);
            hold_0(fixed_mask_0(c_41), &(r_lin_0), &(r_ang_0), _S740, _S740);
            scratch_0[sv_0(c_41, u32(4))] = r_lin_0;
            scratch_0[sv_0(c_41, u32(5))] = r_ang_0;
            c_41 = c_41 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        group_sum2_1(tid_18, &(magnitude_0), &(unused_m_0));
        if(free_0)
        {
            project_load_slot_0(tid_18, &(_S729), u32(4));
        }
        var _S741 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
        var residual_1 : f32 = sqrt(_S741) / _S736;
        var _S742 : f32 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S736);
        if(residual_1 <= _S737)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S742)
            {
                converged_0 = residual_1 > (0.5f * previous_2);
            }
            else
            {
                converged_0 = false;
            }
        }
        if(converged_0)
        {
            residual_0 = residual_1;
            converged_0 = true;
            break;
        }
        var i_20 : u32 = _S739;
        loop
        {
            if(i_20 < _S732)
            {
            }
            else
            {
                break;
            }
            var d_lin_7 : vec3<f32>;
            var d_ang_5 : vec3<f32>;
            static_kinematics_1(i_20, &(d_lin_7), &(d_ang_5));
            var _S743 : JointBond_std430_0 = bonds_0[i_20].law_0;
            var _S744 : JointState_std430_0 = bond_dyn_0[i_20].js_0;
            var f_lin_3 : vec3<f32>;
            var f_ang_3 : vec3<f32>;
            secant_factors_0(&(_S743), &(_S744), d_lin_7, &(f_lin_3), &(f_ang_3));
            var _S745 : u32 = statics_bond_slot_0(i_20);
            var _S746 : f32 = _S743.stiff0_0.y;
            scratch_0[_S745] = vec4<f32>(_S746 * f_lin_3.x, _S746 * f_lin_3.y, _S743.stiff0_0.x * f_lin_3.z, 0.0f);
            scratch_0[_S745 + u32(1)] = vec4<f32>(_S743.stiff0_0.z * f_ang_3.x, _S743.stiff0_0.w * f_ang_3.y, _S743.stiff1_0.x * f_ang_3.z, 0.0f);
            i_20 = i_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_42 : u32 = _S733;
        loop
        {
            if(c_42 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_42);
            scratch_0[sv_0(c_42, u32(2))] = _S740;
            scratch_0[sv_0(c_42, u32(3))] = _S740;
            c_42 = c_42 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_43 : u32 = _S733;
        loop
        {
            if(c_43 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_43);
            c_43 = c_43 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(free_0)
        {
            project_displacement_slot_0(tid_18, &(_S729), u32(6));
        }
        var c_44 : u32 = _S733;
        loop
        {
            if(c_44 < c1_1)
            {
            }
            else
            {
                break;
            }
            scratch_0[sv_0(c_44, u32(8))] = scratch_0[sv_0(c_44, u32(6))];
            scratch_0[sv_0(c_44, u32(9))] = scratch_0[sv_0(c_44, u32(7))];
            c_44 = c_44 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S747 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(6));
        var _S748 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
        var _S749 : f32 = sqrt(_S748);
        var rz_0 : f32 = _S747;
        var k_26 : u32 = u32(0);
        var cg_total_1 : u32 = cg_total_0;
        loop
        {
            var _S750 : bool;
            if(k_26 < _S738)
            {
                _S750 = _S749 > 0.0f;
            }
            else
            {
                _S750 = false;
            }
            if(_S750)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            var i_21 : u32 = _S739;
            loop
            {
                if(i_21 < _S732)
                {
                }
                else
                {
                    break;
                }
                var ca_3 : u32 = bonds_0[i_21].law_0.ids_0.y;
                var cb_6 : u32 = bonds_0[i_21].law_0.ids_0.z;
                var d_lin_8 : vec3<f32>;
                var d_ang_6 : vec3<f32>;
                bond_kinematics_0(i_21, scratch_0[sv_0(ca_3, u32(8))].xyz, scratch_0[sv_0(ca_3, u32(9))].xyz, scratch_0[sv_0(cb_6, u32(8))].xyz, scratch_0[sv_0(cb_6, u32(9))].xyz, &(d_lin_8), &(d_ang_6));
                var _S751 : u32 = statics_bond_slot_0(i_21);
                write_bond_loads_0(i_21, i_21, d_lin_8 * scratch_0[_S751].xyz, d_ang_6 * scratch_0[_S751 + u32(1)].xyz, 0.0f);
                i_21 = i_21 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_40 = _S733;
            loop
            {
                if(c_40 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var fi_5 : vec3<f32>;
                var mi_8 : vec3<f32>;
                gather_loads_0(c_40, &(fi_5), &(mi_8));
                var ap_lin_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - fi_5), 0.0f);
                var ap_ang_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - mi_8), 0.0f);
                hold_0(fixed_mask_0(c_40), &(ap_lin_0), &(ap_ang_0), scratch_0[sv_0(c_40, u32(8))], scratch_0[sv_0(c_40, u32(9))]);
                scratch_0[sv_0(c_40, u32(10))] = ap_lin_0;
                scratch_0[sv_0(c_40, u32(11))] = ap_ang_0;
                c_40 = c_40 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var pap_0 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(8), u32(10));
            var _S752 : u32 = cg_total_1 + u32(1);
            if(pap_0 <= 0.0f)
            {
                cg_total_0 = _S752;
                break;
            }
            var _S753 : f32 = rz_0 / pap_0;
            var c_45 : u32 = _S733;
            loop
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S754 : u32 = sv_0(c_45, u32(2));
                var _S755 : vec3<f32> = vec3<f32>(_S753);
                scratch_0[_S754] = vec4<f32>(scratch_0[_S754].xyz + _S755 * scratch_0[sv_0(c_45, u32(8))].xyz, 0.0f);
                var _S756 : u32 = sv_0(c_45, u32(3));
                scratch_0[_S756] = vec4<f32>(scratch_0[_S756].xyz + _S755 * scratch_0[sv_0(c_45, u32(9))].xyz, 0.0f);
                var _S757 : u32 = sv_0(c_45, u32(4));
                scratch_0[_S757] = vec4<f32>(scratch_0[_S757].xyz - _S755 * scratch_0[sv_0(c_45, u32(10))].xyz, 0.0f);
                var _S758 : u32 = sv_0(c_45, u32(5));
                scratch_0[_S758] = vec4<f32>(scratch_0[_S758].xyz - _S755 * scratch_0[sv_0(c_45, u32(11))].xyz, 0.0f);
                c_45 = c_45 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S759 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
            if((sqrt(_S759)) <= (0.00009999999747379f * _S749))
            {
                cg_total_0 = _S752;
                break;
            }
            var c_46 : u32 = _S733;
            loop
            {
                if(c_46 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_46);
                c_46 = c_46 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            if(free_0)
            {
                project_displacement_slot_0(tid_18, &(_S729), u32(6));
            }
            var rz_new_0 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(6));
            var _S760 : f32 = rz_new_0 / rz_0;
            var c_47 : u32 = _S733;
            loop
            {
                if(c_47 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S761 : u32 = sv_0(c_47, u32(8));
                var _S762 : vec3<f32> = vec3<f32>(_S760);
                scratch_0[_S761] = vec4<f32>(scratch_0[sv_0(c_47, u32(6))].xyz + _S762 * scratch_0[_S761].xyz, 0.0f);
                var _S763 : u32 = sv_0(c_47, u32(9));
                scratch_0[_S763] = vec4<f32>(scratch_0[sv_0(c_47, u32(7))].xyz + _S762 * scratch_0[_S763].xyz, 0.0f);
                c_47 = c_47 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S764 : u32 = k_26 + u32(1);
            rz_0 = rz_new_0;
            k_26 = _S764;
            cg_total_1 = _S752;
        }
        c_40 = _S733;
        loop
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            var _S765 : u32 = u32(4) * c_40;
            var u_7 : vec3<f32> = state_0[_S765].xyz;
            var _S766 : u32 = sv_0(c_40, u32(21));
            var u_lo_0 : vec3<f32> = scratch_0[_S766].xyz;
            var _S767 : u32 = _S765 + u32(1);
            var th_8 : vec3<f32> = state_0[_S767].xyz;
            var _S768 : u32 = sv_0(c_40, u32(22));
            var th_lo_0 : vec3<f32> = scratch_0[_S768].xyz;
            comp_add_0(&(u_7), &(u_lo_0), scratch_0[sv_0(c_40, u32(2))].xyz);
            comp_add_0(&(th_8), &(th_lo_0), scratch_0[sv_0(c_40, u32(3))].xyz);
            state_0[_S765] = vec4<f32>(u_7, state_0[_S765].w);
            state_0[_S767] = vec4<f32>(th_8, state_0[_S767].w);
            scratch_0[_S766] = vec4<f32>(u_lo_0, 0.0f);
            scratch_0[_S768] = vec4<f32>(th_lo_0, 0.0f);
            c_40 = c_40 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S769 : u32 = newton_0 + u32(1);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S769;
    }
    i_19 = b0_0 + tid_18;
    loop
    {
        if(i_19 < _S732)
        {
        }
        else
        {
            break;
        }
        var resp_4 : JointResponse_0 = static_response_0(i_19);
        var _S770 : JointState_0 = JointState_0( bond_dyn_0[i_19].js_0.damage_0, bond_dyn_0[i_19].js_0.crush_1, bond_dyn_0[i_19].js_0.kappa_0, bond_dyn_0[i_19].js_0.kappa_c_0, bond_dyn_0[i_19].js_0.ductility_0, bond_dyn_0[i_19].js_0.ductility_c_0, bond_dyn_0[i_19].js_0.fatigue_0, bond_dyn_0[i_19].js_0.plastic_x_0, bond_dyn_0[i_19].js_0.plastic_y_0, bond_dyn_0[i_19].js_0.plastic_t_0, bond_dyn_0[i_19].js_0.rebar_plastic_0, bond_dyn_0[i_19].js_0.rebar_slip0_0, bond_dyn_0[i_19].js_0.rebar_slip1_0, bond_dyn_0[i_19].js_0.rebar_work_0, bond_dyn_0[i_19].js_0.rebar_broken_0, bond_dyn_0[i_19].js_0.strain_rate_0, bond_dyn_0[i_19].js_0.governing_stress_0, bond_dyn_0[i_19].js_0.dissipated_0, bond_dyn_0[i_19].js_0.utilization_0, bond_dyn_0[i_19].js_0.mode_0 );
        var bd_1 : BondDyn_0;
        bd_1.js_0 = _S770;
        bd_1.force_lin_0 = bond_dyn_0[i_19].force_lin_0;
        bd_1.force_ang_0 = bond_dyn_0[i_19].force_ang_0;
        bd_1.sums_0 = bond_dyn_0[i_19].sums_0;
        bd_1.comps_0 = bond_dyn_0[i_19].comps_0;
        bd_1.events_0 = bond_dyn_0[i_19].events_0;
        bd_1.force_lin_0 = vec4<f32>(resp_4.force_lin_1, resp_4.stored_6);
        bd_1.force_ang_0 = vec4<f32>(resp_4.force_ang_1, bd_1.force_ang_0.w);
        bond_dyn_0[i_19].js_0.damage_0 = bd_1.js_0.damage_0;
        bond_dyn_0[i_19].js_0.crush_1 = bd_1.js_0.crush_1;
        bond_dyn_0[i_19].js_0.kappa_0 = bd_1.js_0.kappa_0;
        bond_dyn_0[i_19].js_0.kappa_c_0 = bd_1.js_0.kappa_c_0;
        bond_dyn_0[i_19].js_0.ductility_0 = bd_1.js_0.ductility_0;
        bond_dyn_0[i_19].js_0.ductility_c_0 = bd_1.js_0.ductility_c_0;
        bond_dyn_0[i_19].js_0.fatigue_0 = bd_1.js_0.fatigue_0;
        bond_dyn_0[i_19].js_0.plastic_x_0 = bd_1.js_0.plastic_x_0;
        bond_dyn_0[i_19].js_0.plastic_y_0 = bd_1.js_0.plastic_y_0;
        bond_dyn_0[i_19].js_0.plastic_t_0 = bd_1.js_0.plastic_t_0;
        bond_dyn_0[i_19].js_0.rebar_plastic_0 = bd_1.js_0.rebar_plastic_0;
        bond_dyn_0[i_19].js_0.rebar_slip0_0 = bd_1.js_0.rebar_slip0_0;
        bond_dyn_0[i_19].js_0.rebar_slip1_0 = bd_1.js_0.rebar_slip1_0;
        bond_dyn_0[i_19].js_0.rebar_work_0 = bd_1.js_0.rebar_work_0;
        bond_dyn_0[i_19].js_0.rebar_broken_0 = bd_1.js_0.rebar_broken_0;
        bond_dyn_0[i_19].js_0.strain_rate_0 = bd_1.js_0.strain_rate_0;
        bond_dyn_0[i_19].js_0.governing_stress_0 = bd_1.js_0.governing_stress_0;
        bond_dyn_0[i_19].js_0.dissipated_0 = bd_1.js_0.dissipated_0;
        bond_dyn_0[i_19].js_0.utilization_0 = bd_1.js_0.utilization_0;
        bond_dyn_0[i_19].js_0.mode_0 = bd_1.js_0.mode_0;
        bond_dyn_0[i_19].force_lin_0 = bd_1.force_lin_0;
        bond_dyn_0[i_19].force_ang_0 = bd_1.force_ang_0;
        bond_dyn_0[i_19].sums_0 = bd_1.sums_0;
        bond_dyn_0[i_19].comps_0 = bd_1.comps_0;
        bond_dyn_0[i_19].events_0 = bd_1.events_0;
        write_bond_loads_0(i_19, i_19, resp_4.force_lin_1, resp_4.force_ang_1, max(resp_4.measures_0.tension_0, resp_4.measures_0.compression_0));
        i_19 = i_19 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    c_41 = _S733;
    loop
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        var fi_6 : vec3<f32>;
        var mi_9 : vec3<f32>;
        gather_loads_0(c_41, &(fi_6), &(mi_9));
        var reaction_2 : vec3<f32>;
        if((fixed_mask_0(c_41)) != u32(0))
        {
            reaction_2 = (vec3<f32>(0) - (scratch_0[sv_0(c_41, u32(0))].xyz + fi_6));
        }
        else
        {
            var _S771 : u32 = u32(4) * c_41;
            reaction_2 = vec3<f32>(state_0[_S771 + u32(1)].w, state_0[_S771 + u32(2)].w, state_0[_S771 + u32(3)].w);
        }
        var _S772 : u32 = u32(4) * c_41;
        var _S773 : u32 = _S772 + u32(1);
        state_0[_S773] = vec4<f32>(state_0[_S773].xyz, reaction_2.x);
        state_0[_S772 + u32(2)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.y);
        state_0[_S772 + u32(3)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.z);
        c_41 = c_41 + u32(256);
    }
    if(tid_18 == u32(0))
    {
        var _S774 : f32 = (bitcast<f32>((newton_0)));
        var _S775 : f32 = (bitcast<f32>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        scratch_0[statics_result_slot_0(_S728)] = vec4<f32>(residual_0, _S774, _S775, previous_2);
        islands_0[_S728].info_0[i32(2)] = (_S731 & (u32(4294967287)));
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn settled_fatigue(@builtin(workgroup_id) group_10 : vec3<u32>, @builtin(local_invocation_id) thread_10 : vec3<u32>)
{
    var tid_19 : u32 = thread_10.x;
    var _S776 : u32 = group_10.x;
    var isl_25 : Island_std430_0 = islands_0[_S776];
    var _S777 : bool;
    if((((islands_0[_S776].info_0.x) & (u32(16)))) == u32(0))
    {
        _S777 = true;
    }
    else
    {
        _S777 = (isl_25.range_0.w) == (isl_25.range_0.z);
    }
    if(_S777)
    {
        return;
    }
    var _S778 : bool = tid_19 == u32(0);
    if(_S778)
    {
        g_halt_0 = u32(0);
        g_run_0 = u32(0);
    }
    workgroupBarrier();
    var _S779 : u32 = isl_25.info_0.w;
    var i_22 : u32 = isl_25.range_0.z + tid_19;
    loop
    {
        if(i_22 < (isl_25.range_0.w))
        {
        }
        else
        {
            break;
        }
        var _S780 : JointState_0 = JointState_0( bond_dyn_0[i_22].js_0.damage_0, bond_dyn_0[i_22].js_0.crush_1, bond_dyn_0[i_22].js_0.kappa_0, bond_dyn_0[i_22].js_0.kappa_c_0, bond_dyn_0[i_22].js_0.ductility_0, bond_dyn_0[i_22].js_0.ductility_c_0, bond_dyn_0[i_22].js_0.fatigue_0, bond_dyn_0[i_22].js_0.plastic_x_0, bond_dyn_0[i_22].js_0.plastic_y_0, bond_dyn_0[i_22].js_0.plastic_t_0, bond_dyn_0[i_22].js_0.rebar_plastic_0, bond_dyn_0[i_22].js_0.rebar_slip0_0, bond_dyn_0[i_22].js_0.rebar_slip1_0, bond_dyn_0[i_22].js_0.rebar_work_0, bond_dyn_0[i_22].js_0.rebar_broken_0, bond_dyn_0[i_22].js_0.strain_rate_0, bond_dyn_0[i_22].js_0.governing_stress_0, bond_dyn_0[i_22].js_0.dissipated_0, bond_dyn_0[i_22].js_0.utilization_0, bond_dyn_0[i_22].js_0.mode_0 );
        var bd_2 : BondDyn_0;
        bd_2.js_0 = _S780;
        bd_2.force_lin_0 = bond_dyn_0[i_22].force_lin_0;
        bd_2.force_ang_0 = bond_dyn_0[i_22].force_ang_0;
        bd_2.sums_0 = bond_dyn_0[i_22].sums_0;
        bd_2.comps_0 = bond_dyn_0[i_22].comps_0;
        bd_2.events_0 = bond_dyn_0[i_22].events_0;
        var _S781 : JointBond_std430_0 = bonds_0[i_22].law_0;
        var _S782 : u32 = u32(4) * _S781.ids_0.y;
        var _S783 : u32 = u32(4) * _S781.ids_0.z;
        var d_lin_9 : vec3<f32>;
        var d_ang_7 : vec3<f32>;
        bond_kinematics_0(i_22, state_0[_S782].xyz, state_0[_S782 + u32(1)].xyz, state_0[_S783].xyz, state_0[_S783 + u32(1)].xyz, &(d_lin_9), &(d_ang_7));
        var _S784 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S781.ids_0.x];
        var previous_3 : JointState_0 = bd_2.js_0;
        var _S785 : JointResponse_0 = joint_evaluate_1(&(_S784), &(_S781), bd_2.js_0, d_lin_9, d_ang_7, params_0.dt_0, (params_0.fracture_0) != u32(0));
        if((_S785.state_1.damage_0) > (bd_2.js_0.damage_0 + 9.99999971718068537e-10f))
        {
            _S777 = true;
        }
        else
        {
            _S777 = (_S785.state_1.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        var flags_4 : u32;
        if(_S777)
        {
            flags_4 = u32(16);
        }
        else
        {
            flags_4 = u32(0);
        }
        var _S786 : f32 = bd_2.sums_0[i32(0)];
        var _S787 : f32 = bd_2.comps_0[i32(0)];
        comp_add1_2(&(_S786), &(_S787), _S785.dissipated_3);
        bd_2.sums_0[i32(0)] = _S786;
        bd_2.comps_0[i32(0)] = _S787;
        var _S788 : f32 = bd_2.sums_0[i32(1)];
        var _S789 : f32 = bd_2.comps_0[i32(1)];
        comp_add1_2(&(_S788), &(_S789), _S785.overshoot_0);
        bd_2.sums_0[i32(1)] = _S788;
        bd_2.comps_0[i32(1)] = _S789;
        bd_2.force_lin_0 = vec4<f32>(_S785.force_lin_1, _S785.stored_6);
        bd_2.force_ang_0 = vec4<f32>(_S785.force_ang_1, max(bd_2.force_ang_0.w, _S785.state_1.utilization_0));
        var _S790 : bool;
        if(!is_damaged_0(previous_3))
        {
            _S790 = is_damaged_0(_S785.state_1);
        }
        else
        {
            _S790 = false;
        }
        var _S791 : bool;
        if(_S790)
        {
            _S791 = (bd_2.events_0.x) == u32(0);
        }
        else
        {
            _S791 = false;
        }
        if(_S791)
        {
            bd_2.events_0[i32(0)] = _S779;
            bd_2.events_0[i32(3)] = _S785.state_1.mode_0;
        }
        var _S792 : bool;
        if((bd_2.events_0.y) == u32(0))
        {
            var _S793 : f32 = fatigue_factor_1(&(_S784), previous_3.fatigue_0);
            _S792 = _S793 > 0.99000000953674316f;
        }
        else
        {
            _S792 = false;
        }
        var _S794 : bool;
        if(_S792)
        {
            var _S795 : f32 = fatigue_factor_1(&(_S784), _S785.state_1.fatigue_0);
            _S794 = _S795 <= 0.99000000953674316f;
        }
        else
        {
            _S794 = false;
        }
        if(_S794)
        {
            bd_2.events_0[i32(1)] = _S779;
        }
        var flags_5 : u32;
        if(_S785.disconnected_0)
        {
            bd_2.events_0[i32(2)] = _S779;
            flags_5 = (flags_4 | (u32(32)));
        }
        else
        {
            flags_5 = flags_4;
        }
        bd_2.js_0 = _S785.state_1;
        bond_dyn_0[i_22].js_0.damage_0 = bd_2.js_0.damage_0;
        bond_dyn_0[i_22].js_0.crush_1 = bd_2.js_0.crush_1;
        bond_dyn_0[i_22].js_0.kappa_0 = bd_2.js_0.kappa_0;
        bond_dyn_0[i_22].js_0.kappa_c_0 = bd_2.js_0.kappa_c_0;
        bond_dyn_0[i_22].js_0.ductility_0 = bd_2.js_0.ductility_0;
        bond_dyn_0[i_22].js_0.ductility_c_0 = bd_2.js_0.ductility_c_0;
        bond_dyn_0[i_22].js_0.fatigue_0 = bd_2.js_0.fatigue_0;
        bond_dyn_0[i_22].js_0.plastic_x_0 = bd_2.js_0.plastic_x_0;
        bond_dyn_0[i_22].js_0.plastic_y_0 = bd_2.js_0.plastic_y_0;
        bond_dyn_0[i_22].js_0.plastic_t_0 = bd_2.js_0.plastic_t_0;
        bond_dyn_0[i_22].js_0.rebar_plastic_0 = bd_2.js_0.rebar_plastic_0;
        bond_dyn_0[i_22].js_0.rebar_slip0_0 = bd_2.js_0.rebar_slip0_0;
        bond_dyn_0[i_22].js_0.rebar_slip1_0 = bd_2.js_0.rebar_slip1_0;
        bond_dyn_0[i_22].js_0.rebar_work_0 = bd_2.js_0.rebar_work_0;
        bond_dyn_0[i_22].js_0.rebar_broken_0 = bd_2.js_0.rebar_broken_0;
        bond_dyn_0[i_22].js_0.strain_rate_0 = bd_2.js_0.strain_rate_0;
        bond_dyn_0[i_22].js_0.governing_stress_0 = bd_2.js_0.governing_stress_0;
        bond_dyn_0[i_22].js_0.dissipated_0 = bd_2.js_0.dissipated_0;
        bond_dyn_0[i_22].js_0.utilization_0 = bd_2.js_0.utilization_0;
        bond_dyn_0[i_22].js_0.mode_0 = bd_2.js_0.mode_0;
        bond_dyn_0[i_22].force_lin_0 = bd_2.force_lin_0;
        bond_dyn_0[i_22].force_ang_0 = bd_2.force_ang_0;
        bond_dyn_0[i_22].sums_0 = bd_2.sums_0;
        bond_dyn_0[i_22].comps_0 = bd_2.comps_0;
        bond_dyn_0[i_22].events_0 = bd_2.events_0;
        write_bond_loads_0(i_22, i_22, _S785.force_lin_1, _S785.force_ang_1, max(_S785.measures_0.tension_0, _S785.measures_0.compression_0));
        if(((flags_5 & (u32(16)))) != u32(0))
        {
            g_halt_0 = u32(1);
        }
        if(((flags_5 & (u32(32)))) != u32(0))
        {
            g_run_0 = u32(1);
        }
        i_22 = i_22 + u32(256);
    }
    workgroupBarrier();
    if(_S778)
    {
        _S777 = ((g_halt_0 | (g_run_0))) != u32(0);
    }
    else
    {
        _S777 = false;
    }
    if(_S777)
    {
        var _S796 : u32 = isl_25.info_0.z;
        if(g_halt_0 != u32(0))
        {
            i_22 = u32(16);
        }
        else
        {
            i_22 = u32(0);
        }
        var _S797 : u32 = (_S796 | (i_22));
        if(g_run_0 != u32(0))
        {
            i_22 = u32(32);
        }
        else
        {
            i_22 = u32(0);
        }
        islands_0[_S776].info_0[i32(2)] = (_S797 | (i_22));
    }
    return;
}

