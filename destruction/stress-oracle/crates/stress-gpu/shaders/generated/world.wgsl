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
var<private> SPRING_AT_0 : array<f32, i32(6)> = array<f32, i32(6)>( -0.4166666567325592f, -0.25f, -0.0833333358168602f, 0.0833333358168602f, 0.25f, 0.4166666567325592f );
var<workgroup> g_red_a_0 : array<vec4<f32>, i32(256)>;

var<workgroup> g_red_b_0 : array<vec4<f32>, i32(256)>;

fn group_sum2_0( tid_0 : u32,  a_0 : ptr<function, vec4<f32>>,  b_0 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_0] = (*a_0);
    g_red_b_0[tid_0] = (*b_0);
    workgroupBarrier();
    var s_0 : u32 = u32(128);
    loop
    {
        if(s_0 > u32(0))
        {
        }
        else
        {
            break;
        }
        if(tid_0 < s_0)
        {
            var _S1 : u32 = tid_0 + s_0;
            g_red_a_0[tid_0] = g_red_a_0[tid_0] + g_red_a_0[_S1];
            g_red_b_0[tid_0] = g_red_b_0[tid_0] + g_red_b_0[_S1];
        }
        workgroupBarrier();
        s_0 = (s_0 >> (u32(1)));
    }
    (*a_0) = g_red_a_0[i32(0)];
    (*b_0) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

fn group_sum3_0( tid_1 : u32,  a_1 : ptr<function, vec3<f32>>,  b_1 : ptr<function, vec3<f32>>)
{
    var x_0 : vec4<f32> = vec4<f32>((*a_1), 0.0f);
    var y_0 : vec4<f32> = vec4<f32>((*b_1), 0.0f);
    group_sum2_0(tid_1, &(x_0), &(y_0));
    (*a_1) = x_0.xyz;
    (*b_1) = y_0.xyz;
    return;
}

fn group_sum2_1( tid_2 : u32,  a_2 : ptr<function, vec4<f32>>,  b_2 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_2] = (*a_2);
    g_red_b_0[tid_2] = (*b_2);
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
        if(tid_2 < s_1)
        {
            var _S2 : u32 = tid_2 + s_1;
            g_red_a_0[tid_2] = g_red_a_0[tid_2] + g_red_a_0[_S2];
            g_red_b_0[tid_2] = g_red_b_0[tid_2] + g_red_b_0[_S2];
        }
        workgroupBarrier();
        s_1 = (s_1 >> (u32(1)));
    }
    (*a_2) = g_red_a_0[i32(0)];
    (*b_2) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

fn stopped_0() -> bool
{
    var _S3 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S4 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S4 = true;
    }
    else
    {
        _S4 = (_S3.y) != u32(0);
    }
    return _S4;
}

struct Quat_0
{
     w_0 : f32,
     x_1 : f32,
     y_1 : f32,
     z_0 : f32,
};

fn quat_of_0( q_0 : vec4<f32>) -> Quat_0
{
    var r_0 : Quat_0;
    r_0.x_1 = q_0.x;
    r_0.y_1 = q_0.y;
    r_0.z_0 = q_0.z;
    r_0.w_0 = q_0.w;
    return r_0;
}

fn rotate_0( q_1 : Quat_0,  v_0 : vec3<f32>) -> vec3<f32>
{
    var qv_0 : vec3<f32> = vec3<f32>(q_1.x_1, q_1.y_1, q_1.z_0);
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

fn world_diff_0( a_3 : WorldPoint_0,  b_3 : WorldPoint_0) -> vec3<f32>
{
    return a_3.hi_0 - b_3.hi_0 + (a_3.lo_0 - b_3.lo_0) + (a_3.rel_0 - b_3.rel_0);
}

fn safe_normalize_0( v_1 : vec3<f32>) -> vec3<f32>
{
    var n_0 : f32 = length(v_1);
    var _S5 : vec3<f32>;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S5 = v_1 / vec3<f32>(n_0);
    }
    else
    {
        _S5 = vec3<f32>(0.0f);
    }
    return _S5;
}

fn from_axis_angle_0( axis_0 : vec3<f32>,  angle_0 : f32) -> Quat_0
{
    var a_4 : vec3<f32> = safe_normalize_0(axis_0);
    var _S6 : f32 = 0.5f * angle_0;
    var s_2 : f32 = sin(_S6);
    var q_3 : Quat_0;
    q_3.w_0 = cos(_S6);
    q_3.x_1 = a_4.x * s_2;
    q_3.y_1 = a_4.y * s_2;
    q_3.z_0 = a_4.z * s_2;
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
    var b_4 : Box_0;
    b_4.center_1 = center_2;
    b_4.axis0_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.x, chunks_0[c_1].crot1_0.x, chunks_0[c_1].crot2_0.x)));
    b_4.axis1_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.y, chunks_0[c_1].crot1_0.y, chunks_0[c_1].crot2_0.y)));
    b_4.axis2_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.z, chunks_0[c_1].crot1_0.z, chunks_0[c_1].crot2_0.z)));
    b_4.half_2 = chunks_0[c_1].half_0.xyz;
    b_4.hull_at_0 = (bitcast<u32>((chunks_0[c_1].cmat_0.z)));
    var _S7 : u32 = (bitcast<u32>((chunks_0[c_1].cmat_0.w)));
    b_4.hull_v_0 = (_S7 & (u32(255)));
    b_4.hull_f_0 = (_S7 >> (u32(8)));
    return b_4;
}

fn sample_count_0( b_5 : Box_0) -> u32
{
    var _S8 : u32;
    if((b_5.hull_v_0) == u32(0))
    {
        _S8 = u32(14);
    }
    else
    {
        _S8 = b_5.hull_v_0 + b_5.hull_f_0;
    }
    return _S8;
}

fn may_overlap_0( a_5 : Box_0,  b_6 : Box_0) -> bool
{
    var _S9 : vec3<f32> = b_6.center_1 - a_5.center_1;
    var _S10 : f32 = 0.00000999999974738f * (length(a_5.half_2) + length(b_6.half_2));
    var _S11 : array<vec3<f32>, i32(6)> = array<vec3<f32>, i32(6)>( a_5.axis0_0, a_5.axis1_0, a_5.axis2_0, b_6.axis0_0, b_6.axis1_0, b_6.axis2_0 );
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
            l_0 = _S11[i_0];
        }
        else
        {
            var _S12 : u32 = i_0 - u32(6);
            l_0 = cross(_S11[_S12 / u32(3)], _S11[u32(3) + _S12 % u32(3)]);
        }
        var len_0 : f32 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + u32(1);
            continue;
        }
        if((abs(dot(_S9, l_0))) > (a_5.half_2.x * abs(dot(a_5.axis0_0, l_0)) + a_5.half_2.y * abs(dot(a_5.axis1_0, l_0)) + a_5.half_2.z * abs(dot(a_5.axis2_0, l_0)) + (b_6.half_2.x * abs(dot(b_6.axis0_0, l_0)) + b_6.half_2.y * abs(dot(b_6.axis1_0, l_0)) + b_6.half_2.z * abs(dot(b_6.axis2_0, l_0))) + _S10 * len_0))
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
    var _S13 : u32 = u32(4) * c_2;
    var _S14 : vec3<f32> = islands_0[chunks_0[c_2].info_1.y].angular_velocity_0.xyz;
    (*v_2) = islands_0[chunks_0[c_2].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_2].info_1.y].velocity_err_0.xyz + cross(_S14, rotate_0(q_5, chunks_0[c_2].center_0.xyz + state_0[_S13].xyz - islands_0[chunks_0[c_2].info_1.y].com_0.xyz)) + rotate_0(q_5, state_0[_S13 + u32(2)].xyz);
    (*w_2) = _S14 + rotate_0(q_5, state_0[_S13 + u32(3)].xyz);
    return;
}

fn chunk_velocity_1( c_3 : u32,  v_3 : ptr<function, vec3<f32>>,  w_3 : ptr<function, vec3<f32>>)
{
    var q_6 : Quat_0 = quat_of_0(islands_0[chunks_0[c_3].info_1.y].rotation_0);
    var _S15 : u32 = u32(4) * c_3;
    var _S16 : vec3<f32> = islands_0[chunks_0[c_3].info_1.y].angular_velocity_0.xyz;
    (*v_3) = islands_0[chunks_0[c_3].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_3].info_1.y].velocity_err_0.xyz + cross(_S16, rotate_0(q_6, chunks_0[c_3].center_0.xyz + state_0[_S15].xyz - islands_0[chunks_0[c_3].info_1.y].com_0.xyz)) + rotate_0(q_6, state_0[_S15 + u32(2)].xyz);
    (*w_3) = _S16 + rotate_0(q_6, state_0[_S15 + u32(3)].xyz);
    return;
}

fn box_to_world_0( b_7 : Box_0,  local_0 : vec3<f32>) -> vec3<f32>
{
    return b_7.axis0_0 * vec3<f32>(local_0.x) + b_7.axis1_0 * vec3<f32>(local_0.y) + b_7.axis2_0 * vec3<f32>(local_0.z);
}

fn box_axis_0( b_8 : Box_0,  k_0 : u32) -> vec3<f32>
{
    var _S17 : vec3<f32>;
    if(k_0 == u32(0))
    {
        _S17 = b_8.axis0_0;
    }
    else
    {
        if(k_0 == u32(1))
        {
            _S17 = b_8.axis1_0;
        }
        else
        {
            _S17 = b_8.axis2_0;
        }
    }
    return _S17;
}

fn comp3_0( v_4 : vec3<f32>,  k_1 : u32) -> f32
{
    var _S18 : f32;
    if(k_1 == u32(0))
    {
        _S18 = v_4.x;
    }
    else
    {
        if(k_1 == u32(1))
        {
            _S18 = v_4.y;
        }
        else
        {
            _S18 = v_4.z;
        }
    }
    return _S18;
}

fn sample_point_0( b_9 : Box_0,  i_1 : u32) -> vec3<f32>
{
    if((b_9.hull_v_0) != u32(0))
    {
        var local_1 : vec3<f32>;
        if(i_1 < (b_9.hull_v_0))
        {
            local_1 = loads_0[b_9.hull_at_0 + i_1].xyz * vec3<f32>(0.89999997615814209f);
        }
        else
        {
            local_1 = loads_0[b_9.hull_at_0 + b_9.hull_v_0 + b_9.hull_f_0 + (i_1 - b_9.hull_v_0)].xyz;
        }
        return b_9.center_1 + box_to_world_0(b_9, local_1);
    }
    var sign_0 : f32;
    if(i_1 < u32(8))
    {
        var h_0 : vec3<f32> = b_9.half_2 * vec3<f32>(0.89999997615814209f);
        if(((i_1 & (u32(1)))) == u32(0))
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        var _S19 : f32;
        if(((i_1 & (u32(2)))) == u32(0))
        {
            _S19 = - h_0.y;
        }
        else
        {
            _S19 = h_0.y;
        }
        var _S20 : f32;
        if(((i_1 & (u32(4)))) == u32(0))
        {
            _S20 = - h_0.z;
        }
        else
        {
            _S20 = h_0.z;
        }
        return b_9.center_1 + b_9.axis0_0 * vec3<f32>(sign_0) + b_9.axis1_0 * vec3<f32>(_S19) + b_9.axis2_0 * vec3<f32>(_S20);
    }
    var _S21 : u32 = i_1 - u32(8);
    var axis_1 : u32 = _S21 / u32(2);
    if((_S21 % u32(2)) == u32(0))
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    return b_9.center_1 + box_axis_0(b_9, axis_1) * vec3<f32>((sign_0 * comp3_0(b_9.half_2, axis_1)));
}

fn box_to_local_0( b_10 : Box_0,  r_1 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r_1, b_10.axis0_0), dot(r_1, b_10.axis1_0), dot(r_1, b_10.axis2_0));
}

fn hull_signed_distance_0( b_11 : Box_0,  local_2 : vec3<f32>,  face_0 : ptr<function, u32>) -> f32
{
    (*face_0) = u32(0);
    var best_0 : f32 = -1.00000001504746622e+30f;
    var f_0 : u32 = u32(0);
    loop
    {
        if(f_0 < (b_11.hull_f_0))
        {
        }
        else
        {
            break;
        }
        var plane_0 : vec4<f32> = loads_0[b_11.hull_at_0 + b_11.hull_v_0 + f_0];
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

fn penetration_0( b_12 : Box_0,  p_0 : vec3<f32>,  depth_0 : ptr<function, f32>,  normal_1 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_0) = 0.0f;
    (*normal_1) = vec3<f32>(0.0f);
    var r_2 : vec3<f32> = p_0 - b_12.center_1;
    var _S22 : vec3<f32> = b_12.half_2;
    if((dot(r_2, r_2)) > (dot(_S22, _S22) * 1.00001001358032227f))
    {
        return false;
    }
    if((b_12.hull_v_0) != u32(0))
    {
        var face_1 : u32;
        var d_1 : f32 = hull_signed_distance_0(b_12, box_to_local_0(b_12, r_2), &(face_1));
        if(!(d_1 < 0.0f))
        {
            return false;
        }
        (*depth_0) = - d_1;
        (*normal_1) = box_to_world_0(b_12, loads_0[b_12.hull_at_0 + b_12.hull_v_0 + face_1].xyz);
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
        var local_3 : f32 = dot(r_2, box_axis_0(b_12, k_2));
        var d_2 : f32 = comp3_0(b_12.half_2, k_2) - abs(local_3);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_1)
        {
            var _S23 : f32;
            if(local_3 >= 0.0f)
            {
                _S23 = 1.0f;
            }
            else
            {
                _S23 = -1.0f;
            }
            best_1 = d_2;
            axis_2 = k_2;
            side_0 = _S23;
        }
        k_2 = k_2 + u32(1);
    }
    (*depth_0) = best_1;
    (*normal_1) = box_axis_0(b_12, axis_2) * vec3<f32>(side_0);
    return true;
}

fn penetration_1( b_13 : Box_0,  p_1 : vec3<f32>,  depth_1 : ptr<function, f32>,  normal_2 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_1) = 0.0f;
    (*normal_2) = vec3<f32>(0.0f);
    var r_3 : vec3<f32> = p_1 - b_13.center_1;
    var _S24 : vec3<f32> = b_13.half_2;
    if((dot(r_3, r_3)) > (dot(_S24, _S24) * 1.00001001358032227f))
    {
        return false;
    }
    if((b_13.hull_v_0) != u32(0))
    {
        var face_2 : u32;
        var d_3 : f32 = hull_signed_distance_0(b_13, box_to_local_0(b_13, r_3), &(face_2));
        if(!(d_3 < 0.0f))
        {
            return false;
        }
        (*depth_1) = - d_3;
        (*normal_2) = box_to_world_0(b_13, loads_0[b_13.hull_at_0 + b_13.hull_v_0 + face_2].xyz);
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
        var local_4 : f32 = dot(r_3, box_axis_0(b_13, k_3));
        var d_4 : f32 = comp3_0(b_13.half_2, k_3) - abs(local_4);
        if(d_4 <= 0.0f)
        {
            return false;
        }
        if(d_4 < best_2)
        {
            var _S25 : f32;
            if(local_4 >= 0.0f)
            {
                _S25 = 1.0f;
            }
            else
            {
                _S25 = -1.0f;
            }
            best_2 = d_4;
            axis_3 = k_3;
            side_1 = _S25;
        }
        k_3 = k_3 + u32(1);
    }
    (*depth_1) = best_2;
    (*normal_2) = box_axis_0(b_13, axis_3) * vec3<f32>(side_1);
    return true;
}

fn pair_point_0( ba_0 : Box_0,  bb_0 : Box_0,  na_0 : u32,  e_0 : u32,  p_2 : ptr<function, vec3<f32>>,  n_1 : ptr<function, vec3<f32>>,  d_5 : ptr<function, f32>) -> bool
{
    if(e_0 < na_0)
    {
        var _S26 : vec3<f32> = sample_point_0(ba_0, e_0);
        (*p_2) = _S26;
        var _S27 : bool = penetration_1(bb_0, _S26, &((*d_5)), &((*n_1)));
        return _S27;
    }
    var _S28 : vec3<f32> = sample_point_0(bb_0, e_0 - na_0);
    (*p_2) = _S28;
    var _S29 : bool = penetration_1(ba_0, _S28, &((*d_5)), &((*n_1)));
    if(!_S29)
    {
        return false;
    }
    (*n_1) = (vec3<f32>(0) - (*n_1));
    return true;
}

fn is_nan_0( x_2 : f32) -> bool
{
    return (((bitcast<u32>((x_2))) & (u32(2147483647)))) > u32(2139095040);
}

fn half_thickness_and_area_0( b_14 : Box_0,  d_6 : vec3<f32>) -> vec2<f32>
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
        var c_4 : f32 = abs(dot(d_6, box_axis_0(b_14, k_4)));
        var h_2 : f32 = h_1 + c_4 * comp3_0(b_14.half_2, k_4);
        var _S30 : u32 = k_4 + u32(1);
        var area_1 : f32 = area_0 + c_4 * 4.0f * comp3_0(b_14.half_2, _S30 % u32(3)) * comp3_0(b_14.half_2, (k_4 + u32(2)) % u32(3));
        k_4 = _S30;
        h_1 = h_2;
        area_0 = area_1;
    }
    return vec2<f32>(h_1, area_0);
}

fn contact_stiffness_0( ea_0 : f32,  a_6 : Box_0,  eb_0 : f32,  b_15 : Box_0,  dir_0 : vec3<f32>) -> f32
{
    var d_7 : vec3<f32> = safe_normalize_0(dir_0);
    var ta_0 : vec2<f32> = half_thickness_and_area_0(a_6, d_7);
    var tb_0 : vec2<f32> = half_thickness_and_area_0(b_15, d_7);
    return min(ta_0.y, tb_0.y) / (ta_0.x / ea_0 + tb_0.x / eb_0);
}

fn penalty_force_0( k_5 : f32,  m_red_0 : f32,  friction_0 : f32,  depth_2 : f32,  normal_3 : vec3<f32>,  rel_velocity_0 : vec3<f32>,  dt_1 : f32,  points_0 : u32,  stored_0 : ptr<function, f32>,  dissipated_1 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_0 : f32 = 1.0f / max(f32(points_0), 10.0f) * m_red_0 / dt_1;
    var vn_0 : f32 = dot(rel_velocity_0, normal_3);
    var _S31 : f32 = k_5 * depth_2;
    var _S32 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    var _S33 : f32 = _S31 - _S32;
    var _S34 : f32 = max(_S33, 0.0f);
    var vt_0 : vec3<f32> = rel_velocity_0 - normal_3 * vec3<f32>(vn_0);
    var vt_mag_0 : f32 = length(vt_0);
    var _S35 : f32 = friction_0 * _S34;
    var _S36 : f32 = min(_S35, min(c_max_0, _S35 / 0.00100000004749745f) * vt_mag_0);
    var ft_0 : vec3<f32>;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = (vec3<f32>(0) - vt_0) * vec3<f32>((_S36 / vt_mag_0));
    }
    else
    {
        ft_0 = vec3<f32>(0.0f);
    }
    (*stored_0) = 0.5f * k_5 * depth_2 * depth_2;
    var damping_power_0 : f32;
    if(_S33 > 0.0f)
    {
        damping_power_0 = _S32 * vn_0;
    }
    else
    {
        damping_power_0 = _S31 * max(vn_0, 0.0f);
    }
    (*dissipated_1) = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * vec3<f32>(_S34) + ft_0;
}

fn penalty_force_1( k_6 : f32,  m_red_1 : f32,  friction_1 : f32,  depth_3 : f32,  normal_4 : vec3<f32>,  rel_velocity_1 : vec3<f32>,  dt_2 : f32,  points_1 : u32,  stored_1 : ptr<function, f32>,  dissipated_2 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_1 : f32 = 1.0f / max(f32(points_1), 10.0f) * m_red_1 / dt_2;
    var vn_1 : f32 = dot(rel_velocity_1, normal_4);
    var _S37 : f32 = k_6 * depth_3;
    var _S38 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_6 * m_red_1), c_max_1) * vn_1;
    var _S39 : f32 = _S37 - _S38;
    var _S40 : f32 = max(_S39, 0.0f);
    var vt_1 : vec3<f32> = rel_velocity_1 - normal_4 * vec3<f32>(vn_1);
    var vt_mag_1 : f32 = length(vt_1);
    var _S41 : f32 = friction_1 * _S40;
    var _S42 : f32 = min(_S41, min(c_max_1, _S41 / 0.00100000004749745f) * vt_mag_1);
    var ft_1 : vec3<f32>;
    if(vt_mag_1 > 0.0f)
    {
        ft_1 = (vec3<f32>(0) - vt_1) * vec3<f32>((_S42 / vt_mag_1));
    }
    else
    {
        ft_1 = vec3<f32>(0.0f);
    }
    (*stored_1) = 0.5f * k_6 * depth_3 * depth_3;
    var damping_power_1 : f32;
    if(_S39 > 0.0f)
    {
        damping_power_1 = _S38 * vn_1;
    }
    else
    {
        damping_power_1 = _S37 * max(vn_1, 0.0f);
    }
    (*dissipated_2) = (damping_power_1 + length(ft_1) * vt_mag_1) * dt_2;
    return normal_4 * vec3<f32>(_S40) + ft_1;
}

fn comp_add1_0( sum_0 : ptr<function, f32>,  err_0 : ptr<function, f32>,  x_3 : f32)
{
    var t_1 : f32 = (*sum_0) + x_3;
    if((abs((*sum_0))) >= (abs(x_3)))
    {
        (*err_0) = (*err_0) + ((*sum_0) - t_1 + x_3);
    }
    else
    {
        (*err_0) = (*err_0) + (x_3 - t_1 + (*sum_0));
    }
    (*sum_0) = t_1;
    return;
}

fn comp_add1_1( sum_1 : ptr<function, f32>,  err_1 : ptr<function, f32>,  x_4 : f32)
{
    var t_2 : f32 = (*sum_1) + x_4;
    if((abs((*sum_1))) >= (abs(x_4)))
    {
        (*err_1) = (*err_1) + ((*sum_1) - t_2 + x_4);
    }
    else
    {
        (*err_1) = (*err_1) + (x_4 - t_2 + (*sum_1));
    }
    (*sum_1) = t_2;
    return;
}

fn comp_add1_2( sum_2 : ptr<function, f32>,  err_2 : ptr<function, f32>,  x_5 : f32)
{
    var t_3 : f32 = (*sum_2) + x_5;
    if((abs((*sum_2))) >= (abs(x_5)))
    {
        (*err_2) = (*err_2) + ((*sum_2) - t_3 + x_5);
    }
    else
    {
        (*err_2) = (*err_2) + (x_5 - t_3 + (*sum_2));
    }
    (*sum_2) = t_3;
    return;
}

fn pair_contact_0( i_2 : u32)
{
    var at_0 : u32 = params_0.pair_index_0 + u32(6) * i_2;
    var ca_0 : u32 = index_0[at_0];
    var cb_0 : u32 = index_0[at_0 + u32(1)];
    var _S43 : u32 = index_0[at_0 + u32(3)];
    var _S44 : f32 = (bitcast<f32>((index_0[at_0 + u32(4)])));
    var _S45 : f32 = (bitcast<f32>((index_0[at_0 + u32(5)])));
    var _S46 : f32 = params_0.dt_0;
    var out_0 : u32 = params_0.slot_base_0 + u32(2) * index_0[at_0 + u32(2)];
    var cb_rel_0 : vec3<f32> = world_diff_0(chunk_world_0(cb_0), chunk_world_0(ca_0));
    var touching_0 : bool = !((length(cb_rel_0)) > (chunks_0[ca_0].half_0.w + chunks_0[cb_0].half_0.w));
    var ledger_1 : vec4<f32> = scratch_0[params_0.ledger_base_0 + i_2];
    var flags_0 : u32 = (bitcast<u32>((scratch_0[params_0.ledger_base_0 + i_2].w)));
    var _S47 : vec3<f32> = vec3<f32>(0.0f);
    var ba_1 : Box_0 = chunk_box_0(ca_0, _S47);
    var bb_1 : Box_0 = chunk_box_0(cb_0, cb_rel_0);
    var _S48 : u32 = sample_count_0(ba_1);
    var _S49 : u32 = _S48 + sample_count_0(bb_1);
    var e_1 : u32;
    var has_state_0 : bool;
    if(!touching_0)
    {
        if(((flags_0 & (u32(1)))) != u32(0))
        {
            e_1 = u32(0);
            loop
            {
                if(e_1 < _S49)
                {
                }
                else
                {
                    break;
                }
                contact_state_0[_S43 + e_1] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
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
            if(e_1 < _S49)
            {
            }
            else
            {
                break;
            }
            var p_3 : vec3<f32>;
            var n_2 : vec3<f32>;
            var d_8 : f32;
            var _S50 : bool = pair_point_0(ba_1, bb_1, _S48, e_1, &(p_3), &(n_2), &(d_8));
            if(!_S50)
            {
                var _S51 : u32 = _S43 + e_1;
                if(!is_nan_0(contact_state_0[_S51].x))
                {
                    contact_state_0[_S51] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                }
                e_1 = e_1 + u32(1);
                continue;
            }
            var _S52 : u32 = count_0 + u32(1);
            var _S53 : u32 = _S43 + e_1;
            var entry_0 : vec4<f32> = contact_state_0[_S53];
            if(is_nan_0(contact_state_0[_S53].x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_8 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - bb_1.center_1)), n_2)) * _S46 + 9.99999971718068537e-10f))
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
            contact_state_0[_S53] = entry_0;
            var engaged_1 : u32;
            if((d_8 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + u32(1);
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S52;
            engaged_0 = engaged_1;
            e_1 = e_1 + u32(1);
        }
        if(count_0 > u32(0))
        {
            var _S54 : f32 = contact_stiffness_0(chunks_0[ca_0].cmat_0.x, ba_1, chunks_0[cb_0].cmat_0.x, bb_1, bb_1.center_1 - ba_1.center_1) / max(f32(engaged_0), 10.0f);
            e_1 = u32(0);
            fa_0 = _S47;
            ta_1 = _S47;
            fb_0 = _S47;
            tb_1 = _S47;
            stored_sum_0 = 0.0f;
            loop
            {
                if(e_1 < _S49)
                {
                }
                else
                {
                    break;
                }
                var p_4 : vec3<f32>;
                var n_3 : vec3<f32>;
                var d_9 : f32;
                var _S55 : bool = pair_point_0(ba_1, bb_1, _S48, e_1, &(p_4), &(n_3), &(d_9));
                if(!_S55)
                {
                    e_1 = e_1 + u32(1);
                    continue;
                }
                var eff_0 : f32 = d_9 - contact_state_0[_S43 + e_1].x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + u32(1);
                    continue;
                }
                var stored_2 : f32;
                var diss_0 : f32;
                var f_1 : vec3<f32> = penalty_force_0(_S54, _S44, _S45, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - bb_1.center_1)), _S46, engaged_0, &(stored_2), &(diss_0));
                var fa_1 : vec3<f32> = fa_0 + f_1;
                var ta_2 : vec3<f32> = ta_1 + cross(p_4, f_1);
                var _S56 : vec3<f32> = (vec3<f32>(0) - f_1);
                var fb_1 : vec3<f32> = fb_0 + _S56;
                var tb_2 : vec3<f32> = tb_1 + cross(p_4 - bb_1.center_1, _S56);
                var stored_sum_1 : f32 = stored_sum_0 + stored_2;
                var _S57 : f32 = ledger_1[i32(1)];
                var _S58 : f32 = ledger_1[i32(2)];
                comp_add1_1(&(_S57), &(_S58), diss_0);
                ledger_1[i32(1)] = _S57;
                ledger_1[i32(2)] = _S58;
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
            fa_0 = _S47;
            ta_1 = _S47;
            fb_0 = _S47;
            tb_1 = _S47;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        fa_0 = _S47;
        ta_1 = _S47;
        fb_0 = _S47;
        tb_1 = _S47;
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
            if(e_1 < _S49)
            {
            }
            else
            {
                break;
            }
            contact_state_0[_S43 + e_1] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
            e_1 = e_1 + u32(1);
        }
    }
    var _S59 : vec3<f32> = vec3<f32>(0.0f);
    if((any((fa_0 != _S59))))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((ta_1 != _S59)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((fb_0 != _S59)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((tb_1 != _S59)));
    }
    var _S60 : bool;
    if(loaded_0)
    {
        _S60 = true;
    }
    else
    {
        _S60 = ((flags_0 & (u32(2)))) != u32(0);
    }
    if(_S60)
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
    var b_16 : Box_0;
    b_16.center_1 = center_3;
    b_16.axis0_0 = rotate_0(q_7, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_16.axis1_0 = rotate_0(q_7, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_16.axis2_0 = rotate_0(q_7, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_16.half_2 = half_3;
    b_16.hull_at_0 = u32(0);
    b_16.hull_v_0 = u32(0);
    b_16.hull_f_0 = u32(0);
    return b_16;
}

fn impactor_slots_0( imp_1 : ptr<function, Impactor_std430_0>,  b_17 : Box_0) -> u32
{
    var _S61 : u32;
    if(((*imp_1).shape_0.x) == 0.0f)
    {
        _S61 = u32(1);
    }
    else
    {
        _S61 = sample_count_0(b_17) + u32(14);
    }
    return _S61;
}

fn impactor_slots_1( imp_2 : ptr<function, Impactor_std430_0>,  b_18 : Box_0) -> u32
{
    var _S62 : u32;
    if(((*imp_2).shape_0.x) == 0.0f)
    {
        _S62 = u32(1);
    }
    else
    {
        _S62 = sample_count_0(b_18) + u32(14);
    }
    return _S62;
}

fn impactor_slots_2( imp_3 : ptr<function, Impactor_std430_0>,  b_19 : Box_0) -> u32
{
    var _S63 : u32;
    if(((*imp_3).shape_0.x) == 0.0f)
    {
        _S63 = u32(1);
    }
    else
    {
        _S63 = sample_count_0(b_19) + u32(14);
    }
    return _S63;
}

fn sphere_contact_0( b_20 : Box_0,  center_4 : vec3<f32>,  radius_0 : f32,  point_0 : ptr<function, vec3<f32>>,  normal_5 : ptr<function, vec3<f32>>,  depth_4 : ptr<function, f32>) -> bool
{
    var _S64 : vec3<f32> = vec3<f32>(0.0f);
    (*point_0) = _S64;
    (*normal_5) = _S64;
    (*depth_4) = 0.0f;
    var r_4 : vec3<f32> = center_4 - b_20.center_1;
    var local_5 : vec3<f32> = vec3<f32>(dot(r_4, b_20.axis0_0), dot(r_4, b_20.axis1_0), dot(r_4, b_20.axis2_0));
    if((b_20.hull_v_0) != u32(0))
    {
        var face_3 : u32;
        var d_10 : f32 = hull_signed_distance_0(b_20, local_5, &(face_3));
        if(d_10 >= radius_0)
        {
            return false;
        }
        var _S65 : vec3<f32> = box_to_world_0(b_20, loads_0[b_20.hull_at_0 + b_20.hull_v_0 + face_3].xyz);
        (*normal_5) = _S65;
        (*point_0) = center_4 - _S65 * vec3<f32>(max(d_10, 0.0f));
        (*depth_4) = radius_0 - d_10;
        return true;
    }
    var q_8 : vec3<f32> = clamp(local_5, (vec3<f32>(0) - b_20.half_2), b_20.half_2);
    var d_11 : vec3<f32> = local_5 - q_8;
    var dist_0 : f32 = length(d_11);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        var dn_0 : vec3<f32> = d_11 / vec3<f32>(dist_0);
        (*normal_5) = b_20.axis0_0 * vec3<f32>(dn_0.x) + b_20.axis1_0 * vec3<f32>(dn_0.y) + b_20.axis2_0 * vec3<f32>(dn_0.z);
        (*point_0) = b_20.center_1 + b_20.axis0_0 * vec3<f32>(q_8.x) + b_20.axis1_0 * vec3<f32>(q_8.y) + b_20.axis2_0 * vec3<f32>(q_8.z);
        (*depth_4) = radius_0 - dist_0;
        return true;
    }
    var inside_0 : f32;
    var n_4 : vec3<f32>;
    var _S66 : bool = penetration_0(b_20, center_4, &(inside_0), &(n_4));
    if(!_S66)
    {
        return false;
    }
    (*normal_5) = n_4;
    (*point_0) = center_4 - n_4 * vec3<f32>(min(radius_0, inside_0));
    (*depth_4) = radius_0 + inside_0;
    return true;
}

fn impactor_contact_0( imp_4 : ptr<function, Impactor_std430_0>,  crush_depth_0 : f32,  shrunk_0 : Box_0,  b_21 : Box_0,  j_0 : u32,  p_5 : ptr<function, vec3<f32>>,  n_5 : ptr<function, vec3<f32>>,  d_12 : ptr<function, f32>) -> bool
{
    var _S67 : vec3<f32> = vec3<f32>(0.0f);
    (*p_5) = _S67;
    (*n_5) = _S67;
    (*d_12) = 0.0f;
    var _S68 : vec4<f32> = (*imp_4).shape_0;
    if(((*imp_4).shape_0.x) == 0.0f)
    {
        var _S69 : bool = sphere_contact_0(b_21, _S67, _S68.y - crush_depth_0, &((*p_5)), &((*n_5)), &((*d_12)));
        if(!_S69)
        {
            return false;
        }
        (*n_5) = (vec3<f32>(0) - (*n_5));
        return true;
    }
    var cb_1 : u32 = sample_count_0(b_21);
    if(j_0 < cb_1)
    {
        var _S70 : vec3<f32> = sample_point_0(b_21, j_0);
        (*p_5) = _S70;
        var _S71 : bool = penetration_0(shrunk_0, _S70, &((*d_12)), &((*n_5)));
        return _S71;
    }
    var _S72 : vec3<f32> = sample_point_0(shrunk_0, j_0 - cb_1);
    (*p_5) = _S72;
    var _S73 : bool = penetration_0(b_21, _S72, &((*d_12)), &((*n_5)));
    if(!_S73)
    {
        return false;
    }
    (*n_5) = (vec3<f32>(0) - (*n_5));
    return true;
}

fn impactor_contact_1( imp_5 : ptr<function, Impactor_std430_0>,  crush_depth_1 : f32,  shrunk_1 : Box_0,  b_22 : Box_0,  j_1 : u32,  p_6 : ptr<function, vec3<f32>>,  n_6 : ptr<function, vec3<f32>>,  d_13 : ptr<function, f32>) -> bool
{
    var _S74 : vec3<f32> = vec3<f32>(0.0f);
    (*p_6) = _S74;
    (*n_6) = _S74;
    (*d_13) = 0.0f;
    var _S75 : vec4<f32> = (*imp_5).shape_0;
    if(((*imp_5).shape_0.x) == 0.0f)
    {
        var _S76 : bool = sphere_contact_0(b_22, _S74, _S75.y - crush_depth_1, &((*p_6)), &((*n_6)), &((*d_13)));
        if(!_S76)
        {
            return false;
        }
        (*n_6) = (vec3<f32>(0) - (*n_6));
        return true;
    }
    var cb_2 : u32 = sample_count_0(b_22);
    if(j_1 < cb_2)
    {
        var _S77 : vec3<f32> = sample_point_0(b_22, j_1);
        (*p_6) = _S77;
        var _S78 : bool = penetration_0(shrunk_1, _S77, &((*d_13)), &((*n_6)));
        return _S78;
    }
    var _S79 : vec3<f32> = sample_point_0(shrunk_1, j_1 - cb_2);
    (*p_6) = _S79;
    var _S80 : bool = penetration_0(b_22, _S79, &((*d_13)), &((*n_6)));
    if(!_S80)
    {
        return false;
    }
    (*n_6) = (vec3<f32>(0) - (*n_6));
    return true;
}

fn impactor_point_0( _S81 : u32) -> WorldPoint_0
{
    var wi_0 : WorldPoint_0;
    wi_0.hi_0 = impactors_0[_S81].position_1.xyz;
    wi_0.lo_0 = impactors_0[_S81].position_err_1.xyz;
    wi_0.rel_0 = vec3<f32>(0.0f);
    return wi_0;
}

fn impactor_box_1( _S82 : u32,  _S83 : vec3<f32>,  _S84 : vec3<f32>) -> Box_0
{
    var q_9 : Quat_0 = quat_of_0(impactors_0[_S82].rotation_1);
    var b_23 : Box_0;
    b_23.center_1 = _S83;
    b_23.axis0_0 = rotate_0(q_9, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_23.axis1_0 = rotate_0(q_9, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_23.axis2_0 = rotate_0(q_9, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_23.half_2 = _S84;
    b_23.hull_at_0 = u32(0);
    b_23.hull_v_0 = u32(0);
    b_23.hull_f_0 = u32(0);
    return b_23;
}

fn impactor_shrunk_0( _S85 : u32,  _S86 : f32,  _S87 : Box_0) -> Box_0
{
    var shrunk_2 : Box_0 = _S87;
    shrunk_2.half_2 = _S87.half_2 - min(vec3<f32>(_S86), _S87.half_2 * vec3<f32>(0.5f));
    return shrunk_2;
}

fn impactor_contact_2( _S88 : u32,  _S89 : f32,  _S90 : Box_0,  _S91 : Box_0,  _S92 : u32,  _S93 : ptr<function, vec3<f32>>,  _S94 : ptr<function, vec3<f32>>,  _S95 : ptr<function, f32>) -> bool
{
    var _S96 : Impactor_std430_0 = impactors_0[_S88];
    var _S97 : vec3<f32> = vec3<f32>(0.0f);
    (*_S93) = _S97;
    (*_S94) = _S97;
    (*_S95) = 0.0f;
    if((_S96.shape_0.x) == 0.0f)
    {
        var _S98 : bool = sphere_contact_0(_S91, _S97, _S96.shape_0.y - _S89, &((*_S93)), &((*_S94)), &((*_S95)));
        if(!_S98)
        {
            return false;
        }
        (*_S94) = (vec3<f32>(0) - (*_S94));
        return true;
    }
    var cb_3 : u32 = sample_count_0(_S91);
    if(_S92 < cb_3)
    {
        var _S99 : vec3<f32> = sample_point_0(_S91, _S92);
        (*_S93) = _S99;
        var _S100 : bool = penetration_0(_S90, _S99, &((*_S95)), &((*_S94)));
        return _S100;
    }
    var _S101 : vec3<f32> = sample_point_0(_S90, _S92 - cb_3);
    (*_S93) = _S101;
    var _S102 : bool = penetration_0(_S91, _S101, &((*_S95)), &((*_S94)));
    if(!_S102)
    {
        return false;
    }
    (*_S94) = (vec3<f32>(0) - (*_S94));
    return true;
}

fn impactor_contact_count_0( _S103 : u32,  _S104 : f32,  _S105 : Box_0,  _S106 : Box_0) -> u32
{
    var _S107 : Impactor_std430_0 = impactors_0[_S103];
    var j_2 : u32 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        var _S108 : u32 = impactor_slots_0(&(_S107), _S106);
        if(j_2 < _S108)
        {
        }
        else
        {
            break;
        }
        var p_7 : vec3<f32>;
        var n_7 : vec3<f32>;
        var d_14 : f32;
        if(impactor_contact_2(_S103, _S104, _S105, _S106, j_2, &(p_7), &(n_7), &(d_14)))
        {
            count_1 = count_1 + u32(1);
        }
        j_2 = j_2 + u32(1);
    }
    return count_1;
}

fn impactor_candidate_forces_0( k_7 : u32)
{
    var _S109 : u32 = u32(3) * k_7;
    var at_1 : u32 = params_0.cand_index_0 + _S109;
    var c_5 : u32 = index_0[at_1];
    var slot_0 : u32 = index_0[at_1 + u32(1)];
    var _S110 : u32 = index_0[at_1 + u32(2)];
    var _S111 : Impactor_std430_0 = impactors_0[_S110];
    var _S112 : f32 = params_0.dt_0;
    var _S113 : vec3<f32> = vec3<f32>(0.0f);
    var data_1 : vec4<f32> = scratch_0[params_0.cand_base_0 + _S109];
    var f_sum_0 : vec3<f32>;
    var t_sum_0 : vec3<f32>;
    var imp_f_0 : vec3<f32>;
    var imp_t_0 : vec3<f32>;
    if((_S111.cand_0.z) == u32(0))
    {
        var rel_1 : vec3<f32> = world_diff_0(chunk_world_0(c_5), impactor_point_0(_S110));
        var _S114 : vec4<f32> = _S111.half_1;
        if(!((length(rel_1)) > (_S111.half_1.w + chunks_0[c_5].half_0.w)))
        {
            var _S115 : Box_0 = impactor_box_1(_S110, _S113, _S114.xyz);
            var b_24 : Box_0 = chunk_box_0(c_5, rel_1);
            var _S116 : vec4<f32> = _S111.mat_0;
            var kc_0 : f32 = contact_stiffness_0(_S111.mat_0.x, _S115, chunks_0[c_5].cmat_0.x, b_24, b_24.center_1 - _S115.center_1);
            var _S117 : vec4<f32> = _S111.geom_0;
            var _S118 : f32 = _S111.geom_0.y;
            var _S119 : Box_0 = impactor_shrunk_0(_S110, _S118, _S115);
            var _S120 : u32 = impactor_contact_count_0(_S110, _S118, _S119, b_24);
            var _S121 : bool = (_S111.shape_0.x) == 0.0f;
            var _S122 : f32;
            if(_S121)
            {
                _S122 = kc_0;
            }
            else
            {
                _S122 = kc_0 / max(f32(_S120), 10.0f);
            }
            var _S123 : u32;
            if(_S121)
            {
                _S123 = u32(1);
            }
            else
            {
                _S123 = _S120;
            }
            var m_1 : f32 = chunks_0[c_5].center_0.w;
            var _S124 : f32 = _S116.z;
            var _S125 : f32 = m_1 * _S124 / (m_1 + _S124);
            var _S126 : f32;
            if((params_0.pair_friction_0) >= 0.0f)
            {
                _S126 = params_0.pair_friction_0;
            }
            else
            {
                _S126 = min(_S116.y, chunks_0[c_5].cmat_0.y);
            }
            var _S127 : vec3<f32> = _S111.velocity_1.xyz + _S111.velocity_err_1.xyz;
            var vc_0 : vec3<f32>;
            var wc_0 : vec3<f32>;
            chunk_velocity_0(c_5, &(vc_0), &(wc_0));
            var j_3 : u32 = u32(0);
            f_sum_0 = _S113;
            t_sum_0 = _S113;
            imp_f_0 = _S113;
            imp_t_0 = _S113;
            loop
            {
                var _S128 : bool;
                if(_S120 > u32(0))
                {
                    var _S129 : u32 = impactor_slots_1(&(_S111), b_24);
                    _S128 = j_3 < _S129;
                }
                else
                {
                    _S128 = false;
                }
                if(_S128)
                {
                }
                else
                {
                    break;
                }
                var p_8 : vec3<f32>;
                var nrm_0 : vec3<f32>;
                var dep_0 : f32;
                var _S130 : bool = impactor_contact_0(&(_S111), _S118, _S119, b_24, j_3, &(p_8), &(nrm_0), &(dep_0));
                if(!_S130)
                {
                    j_3 = j_3 + u32(1);
                    continue;
                }
                var stored_3 : f32;
                var diss_1 : f32;
                var f_2 : vec3<f32> = penalty_force_0(_S122, _S125, _S126, dep_0 * _S117.x, nrm_0, vc_0 + cross(wc_0, p_8 - b_24.center_1) - (_S127 + cross(_S111.angular_velocity_1.xyz, p_8)), _S112, _S123, &(stored_3), &(diss_1));
                var f_sum_1 : vec3<f32> = f_sum_0 + f_2;
                var t_sum_1 : vec3<f32> = t_sum_0 + cross(p_8 - b_24.center_1, f_2);
                var imp_f_1 : vec3<f32> = imp_f_0 - f_2;
                var imp_t_1 : vec3<f32> = imp_t_0 - cross(p_8, f_2);
                var _S131 : f32 = data_1[i32(2)];
                var _S132 : f32 = data_1[i32(3)];
                comp_add1_1(&(_S131), &(_S132), diss_1);
                data_1[i32(2)] = _S131;
                data_1[i32(3)] = _S132;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_3 = j_3 + u32(1);
            }
        }
        else
        {
            f_sum_0 = _S113;
            t_sum_0 = _S113;
            imp_f_0 = _S113;
            imp_t_0 = _S113;
        }
    }
    else
    {
        f_sum_0 = _S113;
        t_sum_0 = _S113;
        imp_f_0 = _S113;
        imp_t_0 = _S113;
    }
    var _S133 : u32 = u32(2) * slot_0;
    scratch_0[params_0.slot_base_0 + _S133] = vec4<f32>(f_sum_0, 0.0f);
    scratch_0[params_0.slot_base_0 + _S133 + u32(1)] = vec4<f32>(t_sum_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S109] = data_1;
    scratch_0[params_0.cand_base_0 + _S109 + u32(1)] = vec4<f32>(imp_f_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S109 + u32(2)] = vec4<f32>(imp_t_0, 0.0f);
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
    var _S134 : bool;
    if(k_8 >= (params_0.cand_count_0))
    {
        _S134 = true;
    }
    else
    {
        _S134 = stopped_0();
    }
    if(_S134)
    {
        return;
    }
    var _S135 : u32 = u32(3) * k_8;
    var at_2 : u32 = params_0.cand_index_0 + _S135;
    var c_7 : u32 = index_0[at_2];
    var _S136 : u32 = index_0[at_2 + u32(2)];
    var _S137 : Impactor_std430_0 = impactors_0[_S136];
    if((_S137.cand_0.z) == u32(0))
    {
        _S134 = (_S137.crush_0.x) > 0.0f;
    }
    else
    {
        _S134 = false;
    }
    var total_0 : f32;
    var ksum_0 : f32;
    if(_S134)
    {
        var rel_2 : vec3<f32> = world_diff_0(chunk_world_0(c_7), impactor_point_0(_S136));
        var _S138 : vec4<f32> = _S137.half_1;
        if(!((length(rel_2)) > (_S137.half_1.w + chunks_0[c_7].half_0.w)))
        {
            var _S139 : Box_0 = impactor_box_1(_S136, vec3<f32>(0.0f), _S138.xyz);
            var b_25 : Box_0 = chunk_box_0(c_7, rel_2);
            var kc_1 : f32 = contact_stiffness_0(_S137.mat_0.x, _S139, chunks_0[c_7].cmat_0.x, b_25, b_25.center_1 - _S139.center_1);
            var _S140 : f32 = _S137.crush_0.w;
            var _S141 : Box_0 = impactor_shrunk_0(_S136, _S140, _S139);
            var _S142 : u32 = impactor_contact_count_0(_S136, _S140, _S141, b_25);
            var _S143 : f32;
            if((_S137.shape_0.x) == 0.0f)
            {
                _S143 = kc_1;
            }
            else
            {
                _S143 = kc_1 / max(f32(_S142), 10.0f);
            }
            var j_4 : u32 = u32(0);
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            loop
            {
                if(_S142 > u32(0))
                {
                    var _S144 : u32 = impactor_slots_2(&(_S137), b_25);
                    _S134 = j_4 < _S144;
                }
                else
                {
                    _S134 = false;
                }
                if(_S134)
                {
                }
                else
                {
                    break;
                }
                var p_9 : vec3<f32>;
                var nrm_1 : vec3<f32>;
                var dep_1 : f32;
                var _S145 : bool = impactor_contact_1(&(_S137), _S140, _S141, b_25, j_4, &(p_9), &(nrm_1), &(dep_1));
                if(!_S145)
                {
                    j_4 = j_4 + u32(1);
                    continue;
                }
                var ksum_1 : f32 = ksum_0 + _S143;
                total_0 = total_0 + _S143 * dep_1;
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
    scratch_0[params_0.cand_base_0 + _S135] = vec4<f32>(total_0, ksum_0, scratch_0[params_0.cand_base_0 + _S135].z, scratch_0[params_0.cand_base_0 + _S135].w);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_crush(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var ii_0 : u32 = group_0.x;
    var tid_3 : u32 = thread_0.x;
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
    var k_9 : u32 = imp_6.cand_0.x + tid_3;
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
    group_sum2_0(tid_3, &(shares_0), &(unused_1));
    if(tid_3 != u32(0))
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

fn comp_add_0( sum_3 : ptr<function, vec3<f32>>,  err_3 : ptr<function, vec3<f32>>,  x_6 : vec3<f32>)
{
    var t_4 : vec3<f32> = (*sum_3) + x_6;
    var _S154 : vec3<f32> = abs(x_6);
    (*err_3) = (*err_3) + (select(x_6, (*sum_3), (abs((*sum_3))) >= _S154) - t_4 + select((*sum_3), x_6, (abs((*sum_3))) >= _S154));
    (*sum_3) = t_4;
    return;
}

fn inverse_rotate_0( q_10 : Quat_0,  v_5 : vec3<f32>) -> vec3<f32>
{
    var c_8 : Quat_0;
    c_8.w_0 = q_10.w_0;
    c_8.x_1 = - q_10.x_1;
    c_8.y_1 = - q_10.y_1;
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

fn quat_mul_0( a_7 : Quat_0,  o_0 : Quat_0) -> Quat_0
{
    var r_5 : Quat_0;
    r_5.w_0 = a_7.w_0 * o_0.w_0 - a_7.x_1 * o_0.x_1 - a_7.y_1 * o_0.y_1 - a_7.z_0 * o_0.z_0;
    r_5.x_1 = a_7.w_0 * o_0.x_1 + a_7.x_1 * o_0.w_0 + a_7.y_1 * o_0.z_0 - a_7.z_0 * o_0.y_1;
    r_5.y_1 = a_7.w_0 * o_0.y_1 - a_7.x_1 * o_0.z_0 + a_7.y_1 * o_0.w_0 + a_7.z_0 * o_0.x_1;
    r_5.z_0 = a_7.w_0 * o_0.z_0 + a_7.x_1 * o_0.y_1 - a_7.y_1 * o_0.x_1 + a_7.z_0 * o_0.w_0;
    return r_5;
}

fn normalized_0( q_12 : Quat_0) -> Quat_0
{
    var _S155 : f32 = q_12.w_0;
    var _S156 : f32 = q_12.x_1;
    var _S157 : f32 = q_12.y_1;
    var _S158 : f32 = q_12.z_0;
    var n_8 : f32 = sqrt(_S155 * _S155 + _S156 * _S156 + _S157 * _S157 + _S158 * _S158);
    var r_6 : Quat_0;
    r_6.w_0 = q_12.w_0 / n_8;
    r_6.x_1 = q_12.x_1 / n_8;
    r_6.y_1 = q_12.y_1 / n_8;
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
    return vec4<f32>(q_14.x_1, q_14.y_1, q_14.z_0, q_14.w_0);
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_integrate(@builtin(workgroup_id) group_1 : vec3<u32>, @builtin(local_invocation_id) thread_1 : vec3<u32>)
{
    var p_10 : vec3<f32>;
    var ii_1 : u32 = group_1.x;
    var tid_4 : u32 = thread_1.x;
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
    var k_10 : u32 = imp_7.cand_0.x + tid_4;
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
    group_sum2_0(tid_4, &(rf_0), &(rt_0));
    if(tid_4 != u32(0))
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
    var b_26 : Box_0 = chunk_box_0(c_9, vec3<f32>(0.0f));
    const _S171 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S172 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_26, chunks_0[c_9].cmat_0.x, b_26, _S171);
    var _S173 : u32 = sample_count_0(b_26);
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
        if((above_0 + sample_point_0(b_26, s_4).z) < 0.0f)
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
        var p_11 : vec3<f32> = sample_point_0(b_26, s_4);
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
     a_8 : vec3<f32>,
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
    rg_0.a_8 = _S190;
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
    rg_1.a_8 = _S191;
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
        var a_9 : vec4<f32> = loads_0[at_5 + u32(1)];
        var b_27 : vec4<f32> = loads_0[at_5 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_5 + u32(3)];
        var kind_0 : u32 = info_2.x;
        var i_4 : u32 = info_2.y;
        var value_1 : f32;
        if(kind_0 == u32(0))
        {
            value_1 = dot(rg_2.pos_1 - b_27.xyz + (rg_2.pos_err_1 - c4_0.xyz) + rotate_0(rg_2.rot_0, chunks_0[i_4].center_0.xyz + state_0[u32(4) * i_4].xyz), a_9.xyz);
        }
        else
        {
            if(kind_0 == u32(1))
            {
                var _S192 : u32 = u32(4) * i_4;
                value_1 = dot(rg_2.vel_1 + rg_2.vel_err_1 + cross(rg_2.w_4, rotate_0(rg_2.rot_0, chunks_0[i_4].center_0.xyz + state_0[_S192].xyz - isl_4.com_0.xyz)) + rotate_0(rg_2.rot_0, state_0[_S192 + u32(2)].xyz), a_9.xyz);
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
                    value_1 = dot(fc_0, a_9.xyz) + dot(mc_0, b_27.xyz);
                }
                else
                {
                    var _S195 : u32 = u32(4) * i_4;
                    value_1 = dot(rotate_0(rg_2.rot_0, vec3<f32>(state_0[_S195 + u32(1)].w, state_0[_S195 + u32(2)].w, state_0[_S195 + u32(3)].w)), a_9.xyz);
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
        var b_28 : vec4<f32> = loads_0[_S196];
        var _S197 : f32 = b_28.x;
        if(tau_0 <= _S197)
        {
            var a_10 : vec4<f32> = loads_0[_S196 - u32(1)];
            var _S198 : f32 = a_10.x;
            var _S199 : f32 = a_10.y;
            return _S199 + (tau_0 - _S198) / max(_S197 - _S198, 1.00000000317107685e-30f) * (b_28.y - _S199);
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
    (*rg_5).a_8 = f_11 / vec3<f32>((*isl_7).com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_0, (*isl_7).inv0_0, (*isl_7).inv1_0, (*isl_7).inv2_0, t_11 - cross((*rg_5).w_4, iw_w_0));
    return;
}

fn rigid_acceleration_1( isl_8 : Island_0,  rg_6 : ptr<function, Rigid_0>,  f_12 : vec3<f32>,  t_12 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_6).rot_0, isl_8.inertia0_0, isl_8.inertia1_0, isl_8.inertia2_0, (*rg_6).w_4);
    (*rg_6).a_8 = f_12 / vec3<f32>(isl_8.com_0.w);
    (*rg_6).alpha_0 = world_mul_0((*rg_6).rot_0, isl_8.inv0_0, isl_8.inv1_0, isl_8.inv2_0, t_12 - cross((*rg_6).w_4, iw_w_1));
    return;
}

fn integrate_rigid_0( isl_9 : ptr<function, Island_std430_0>,  rg_7 : ptr<function, Rigid_0>,  dt_10 : f32)
{
    var iw_w_2 : vec3<f32> = world_mul_0((*rg_7).rot_0, (*isl_9).inertia0_0, (*isl_9).inertia1_0, (*isl_9).inertia2_0, (*rg_7).w_4);
    var _S248 : vec3<f32> = vec3<f32>(dt_10);
    var l_2 : vec3<f32> = iw_w_2 + (world_mul_0((*rg_7).rot_0, (*isl_9).inertia0_0, (*isl_9).inertia1_0, (*isl_9).inertia2_0, (*rg_7).alpha_0) + cross((*rg_7).w_4, iw_w_2)) * _S248;
    var _S249 : vec3<f32> = (*rg_7).a_8 * _S248;
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
    var _S259 : vec3<f32> = (*rg_8).a_8 * _S258;
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
                    var _S313 : f32 = SPRING_AT_0[i_7] * w0_2;
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
                        var s2_0 : f32 = SPRING_AT_0[j_5] * w1_2;
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

fn contact_offsets_0( mat_6 : ptr<function, JointMaterial_std140_0>,  b_34 : ptr<function, JointBond_std430_0>,  crush_3 : f32,  plastic_3 : vec3<f32>,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>) -> vec3<f32>
{
    var _S321 : u32 = (*mat_6).kind_flags_0.y;
    if(((_S321 & (u32(2)))) == u32(0))
    {
        return plastic_3;
    }
    var kn_2 : f32 = (*b_34).stiff0_0.x;
    var ks_1 : f32 = (*b_34).stiff0_0.y;
    var kt_1 : f32 = (*b_34).stiff1_0.x;
    var w0_3 : f32 = (*b_34).geom0_0.y;
    var w1_3 : f32 = (*b_34).geom0_0.z;
    var nc_sum_1 : f32;
    if(((_S321 & (u32(4)))) != u32(0))
    {
        var _S322 : vec4<f32> = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S322.x;
    }
    else
    {
        var ki_1 : f32 = kn_2 * (1.0f - crush_3) / 36.0f;
        var _S323 : f32 = d_ang_1.x;
        var _S324 : f32 = d_ang_1.y;
        var spread_1 : f32 = abs(_S323) * 0.4166666567325592f * w1_3 + abs(_S324) * 0.4166666567325592f * w0_3;
        var _S325 : f32 = d_lin_1.z;
        var slack_1 : f32 = 9.99999997475242708e-07f * (abs(_S325) + spread_1);
        if((_S325 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S325 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S325;
            }
            else
            {
                var i_8 : u32 = u32(0);
                var nc_sum_2 : f32 = 0.0f;
                loop
                {
                    if(i_8 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S326 : f32 = SPRING_AT_0[i_8] * w0_3;
                    var j_6 : u32 = u32(0);
                    nc_sum_1 = nc_sum_2;
                    loop
                    {
                        if(j_6 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var di_1 : f32 = _S325 + _S323 * (SPRING_AT_0[j_6] * w1_3) - _S324 * _S326;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_6 = j_6 + u32(1);
                    }
                    i_8 = i_8 + u32(1);
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    var nc_1 : f32 = - nc_sum_1;
    var p_15 : vec3<f32> = plastic_3;
    var slide_cap_1 : f32 = (*mat_6).strength_0.w * nc_1;
    var _S327 : f32 = ks_1 * (d_lin_1.x - plastic_3.x);
    var _S328 : f32 = ks_1 * (d_lin_1.y - plastic_3.y);
    var tn_1 : f32 = fsqrt_0(_S327 * _S327 + _S328 * _S328);
    var _S329 : bool;
    if(tn_1 > slide_cap_1)
    {
        _S329 = tn_1 > 0.0f;
    }
    else
    {
        _S329 = false;
    }
    if(_S329)
    {
        var _S330 : f32 = fdiv_0(_S328, tn_1);
        var dslip_1 : f32 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        p_15[i32(0)] = p_15[i32(0)] + fdiv_0(_S327, tn_1) * dslip_1;
        p_15[i32(1)] = p_15[i32(1)] + _S330 * dslip_1;
    }
    p_15[i32(2)] = p_15[i32(2)] + return_map_0(kt_1, d_ang_1.z, p_15.z, slide_cap_1 * (*b_34).geom1_0.z).y;
    return p_15;
}

fn life_rate_0( mat_7 : ptr<function, JointMaterial_std140_0>,  s_6 : f32) -> f32
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    var _S331 : f32 = (*mat_7).misc_0.y;
    return fdiv_0((_S331 + 1.0f) * fpow_0(s_6, _S331), (*mat_7).misc_0.z);
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

fn joint_evaluate_0( mat_8 : ptr<function, JointMaterial_std140_0>,  b_35 : ptr<function, JointBond_std430_0>,  state_2 : JointState_0,  d_lin_2 : vec3<f32>,  d_ang_2 : vec3<f32>,  dt_12 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_3 : f32 = (*b_35).stiff0_0.x;
    var ks_2 : f32 = (*b_35).stiff0_0.y;
    var kb1_0 : f32 = (*b_35).stiff0_0.z;
    var kb2_0 : f32 = (*b_35).stiff0_0.w;
    var _S332 : vec4<f32> = (*b_35).stiff1_0;
    var kt_2 : f32 = (*b_35).stiff1_0.x;
    var has_rebar_2 : bool = ((*b_35).stiff1_0.w) != 0.0f;
    var kind_4 : u32 = (*mat_8).kind_flags_0.x;
    var flags_1 : u32 = (*mat_8).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_2 : JointState_0 = state_2;
    var was_connected_0 : bool = connected_1(state_2, has_rebar_2);
    var qe_lin_0 : vec3<f32> = d_lin_2 * vec3<f32>(ks_2, ks_2, kn_3);
    var qe_ang_0 : vec3<f32> = d_ang_2 * vec3<f32>(kb1_0, kb2_0, kt_2);
    var _S333 : Measures_0 = stress_measures_0(&((*b_35)), qe_lin_0, qe_ang_0);
    var _S334 : f32 = max(max(_S333.tension_0, _S333.shear_0), _S333.compression_0);
    var _S335 : bool = dt_12 > 0.0f;
    var dif_1 : f32;
    if(_S335)
    {
        var raw_0 : f32 = fdiv_0(max(fdiv_0(_S334 - st_2.governing_stress_0, dt_12), 0.0f), (*mat_8).misc_0.w);
        var tau_2 : f32 = _S332.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_12, tau_2));
        }
        else
        {
            dif_1 = min(fdiv_0(dt_12, tau_2), 1.0f);
        }
        st_2.strain_rate_0 = st_2.strain_rate_0 + (raw_0 - st_2.strain_rate_0) * dif_1;
        st_2.governing_stress_0 = _S334;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S336 : f32 = dif_factor_0(&((*mat_8)), st_2.strain_rate_0);
        dif_1 = _S336;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_35).geom1_0.w;
    var _S337 : f32 = weibull_0 * dif_1;
    var _S338 : f32 = fatigue_factor_1(&((*mat_8)), st_2.fatigue_0);
    var multiplier_1 : f32 = _S337 * _S338;
    var _S339 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S333, multiplier_1);
    var _S340 : f32 = _S339.x;
    var _S341 : f32 = _S339.y;
    st_2.utilization_0 = max(max(_S340, _S341), max(_S339.z, _S339.w));
    var _S342 : f32 = d_lin_2.x;
    var _S343 : f32 = d_lin_2.y;
    var _S344 : f32 = ks_2 * (sq_0(_S342) + sq_0(_S343)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    var _S345 : f32 = d_lin_2.z;
    var _S346 : bool = _S345 > 0.0f;
    if(_S346)
    {
        dif_1 = kn_3 * sq_0(_S345);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S344 + dif_1);
    var psi_c_0 : f32;
    if(_S345 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S345);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    var plastic_4 : vec3<f32> = vec3<f32>(st_2.plastic_x_0, st_2.plastic_y_0, st_2.plastic_t_0);
    var diss_contact_0 : f32;
    var psi_contact_0 : f32;
    var intact_normal_0 : f32;
    var dissipated_4 : f32;
    var overshoot_1 : f32;
    var _S347 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S348 : bool = _S340 >= _S341;
        if(_S348)
        {
            diss_contact_0 = _S340;
        }
        else
        {
            diss_contact_0 = _S341;
        }
        var mode_ts_0 : u32;
        if(_S348)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_2.kappa_0))
        {
            _S347 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S347 = false;
        }
        if(_S347)
        {
            _S347 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S347 = false;
        }
        var mode_c_0 : u32;
        if(_S347)
        {
            if(mode_ts_0 == u32(1))
            {
                psi_contact_0 = (*mat_8).energy_1.y;
            }
            else
            {
                psi_contact_0 = (*mat_8).energy_1.z;
            }
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(psi_contact_0 * (*b_35).geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
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
            var _S349 : f32 = inc_0.x;
            if(_S349 > (st_2.damage_0))
            {
                var _S350 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), st_2.crush_1, plastic_4, d_lin_2, d_ang_2);
                var _S351 : f32 = max(_S350.energy_2 - (1.0f - st_2.crush_1) * psi_c_0, 0.0f);
                var _S352 : f32 = max(inc_0.y - _S351 * (_S349 - st_2.damage_0), 0.0f);
                var _S353 : f32 = max((psi_ts_0 - _S351) * (_S349 - st_2.damage_0) - _S352, 0.0f);
                st_2.damage_0 = _S349;
                st_2.mode_0 = mode_ts_0;
                dissipated_4 = _S352;
                overshoot_1 = _S353;
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
            var _S354 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), state_2.crush_1, vec3<f32>(state_2.plastic_x_0, state_2.plastic_y_0, state_2.plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - state_2.damage_0)) + _S354.q_ang_1 * vec3<f32>(state_2.damage_0);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S355 : Measures_0 = stress_measures_0(&((*b_35)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S356 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S355, multiplier_1);
        var _S357 : f32 = _S356.z;
        var _S358 : f32 = _S356.w;
        var _S359 : bool = _S357 >= _S358;
        if(_S359)
        {
            psi_contact_0 = _S357;
        }
        else
        {
            psi_contact_0 = _S358;
        }
        if(_S359)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_2.kappa_c_0))
        {
            _S347 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S347 = false;
        }
        if(_S347)
        {
            _S347 = psi_c_0 > 0.0f;
        }
        else
        {
            _S347 = false;
        }
        if(_S347)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0((*mat_8).energy_1.w * (*b_35).geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
            var _S360 : f32 = inc_1.x;
            if(_S360 > (st_2.crush_1))
            {
                var _S361 : f32 = inc_1.y;
                var dissipated_5 : f32 = dissipated_4 + _S361;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S360 - st_2.crush_1) - _S361, 0.0f);
                st_2.crush_1 = _S360;
                st_2.mode_0 = mode_c_0;
                if(_S360 >= 1.0f)
                {
                    _S347 = (st_2.damage_0) < 1.0f;
                }
                else
                {
                    _S347 = false;
                }
                if(_S347)
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
    var _S362 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_0 : vec3<f32>;
    if((st_2.damage_0) == 0.0f)
    {
        if(((flags_1 & (u32(8)))) == u32(0))
        {
            var _S363 : vec3<f32> = contact_offsets_0(&((*mat_8)), &((*b_35)), st_2.crush_1, plastic_4, d_lin_2, d_ang_2);
            st_2.plastic_x_0 = _S363.x;
            st_2.plastic_y_0 = _S363.y;
            st_2.plastic_t_0 = _S363.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S362;
        qc_ang_0 = _S362;
        psi_contact_0 = 0.0f;
    }
    else
    {
        var _S364 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_35)), st_2.crush_1, plastic_4, d_lin_2, d_ang_2);
        st_2.plastic_x_0 = _S364.plastic_1.x;
        st_2.plastic_y_0 = _S364.plastic_1.y;
        st_2.plastic_t_0 = _S364.plastic_1.z;
        diss_contact_0 = _S364.diss_4;
        qc_lin_0 = _S364.q_lin_1;
        qc_ang_0 = _S364.q_ang_1;
        psi_contact_0 = _S364.energy_2;
    }
    var dissipated_7 : f32 = dissipated_4 + dmg_0 * diss_contact_0;
    if(_S346)
    {
        intact_normal_0 = kn_3 * _S345;
    }
    else
    {
        intact_normal_0 = (1.0f - st_2.crush_1) * kn_3 * _S345;
    }
    var _S365 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S365 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S365 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S365 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S365) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_7 : f32 = _S365 * (psi_ts_0 + (1.0f - st_2.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_2)
    {
        _S347 = (st_2.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S347 = false;
    }
    var stored_8 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S347)
    {
        var k_axial_0 : f32 = (*b_35).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_35).rebar0_0.y;
        var yield_force_0 : f32 = (*b_35).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_35).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S345, st_2.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S342, st_2.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S343, st_2.rebar_slip1_0, dowel_capacity_0);
        var _S366 : f32 = nr_0.y;
        var _S367 : f32 = v1_0.y;
        var _S368 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S366) + dowel_capacity_0 * (abs(_S367) + abs(_S368));
        st_2.rebar_plastic_0 = st_2.rebar_plastic_0 + _S366;
        st_2.rebar_slip0_0 = st_2.rebar_slip0_0 + _S367;
        st_2.rebar_slip1_0 = st_2.rebar_slip1_0 + _S368;
        st_2.rebar_work_0 = st_2.rebar_work_0 + work_0;
        var dissipated_8 : f32 = dissipated_7 + work_0;
        var _S369 : f32 = nr_0.x;
        var _S370 : f32 = v1_0.x;
        var _S371 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (fdiv_0(sq_0(_S369), k_axial_0) + fdiv_0(sq_0(_S370) + sq_0(_S371), k_dowel_0));
        if(fracture_1)
        {
            _S347 = (st_2.rebar_work_0) >= ((*b_35).rebar1_0.x);
        }
        else
        {
            _S347 = false;
        }
        if(_S347)
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
            force_lin_3 = force_lin_2 + vec3<f32>(_S370, _S371, _S369);
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
        _S347 = _S335;
    }
    else
    {
        _S347 = false;
    }
    if(_S347)
    {
        _S347 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S347 = false;
    }
    if(_S347)
    {
        var _S372 : Measures_0 = stress_measures_0(&((*b_35)), force_lin_3, force_ang_2);
        var _S373 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_35)), _S372, weibull_0);
        var _S374 : f32 = life_rate_0(&((*mat_8)), max(max(_S373.x, _S373.y), _S373.z));
        st_2.fatigue_0 = min(st_2.fatigue_0 + _S374 * dt_12, 1.0f);
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
        _S347 = !connected_1(st_2, has_rebar_2);
    }
    else
    {
        _S347 = false;
    }
    resp_0.disconnected_0 = _S347;
    resp_0.measures_0 = _S333;
    return resp_0;
}

fn joint_evaluate_1( mat_9 : ptr<function, JointMaterial_std140_0>,  b_36 : ptr<function, JointBond_std430_0>,  state_3 : JointState_0,  d_lin_3 : vec3<f32>,  d_ang_3 : vec3<f32>,  dt_13 : f32,  fracture_2 : bool) -> JointResponse_0
{
    var kn_4 : f32 = (*b_36).stiff0_0.x;
    var ks_3 : f32 = (*b_36).stiff0_0.y;
    var kb1_1 : f32 = (*b_36).stiff0_0.z;
    var kb2_1 : f32 = (*b_36).stiff0_0.w;
    var _S375 : vec4<f32> = (*b_36).stiff1_0;
    var kt_3 : f32 = (*b_36).stiff1_0.x;
    var has_rebar_3 : bool = ((*b_36).stiff1_0.w) != 0.0f;
    var kind_5 : u32 = (*mat_9).kind_flags_0.x;
    var flags_2 : u32 = (*mat_9).kind_flags_0.y;
    var softening_1 : bool = ((flags_2 & (u32(1)))) != u32(0);
    var st_3 : JointState_0 = state_3;
    var was_connected_1 : bool = connected_1(state_3, has_rebar_3);
    var qe_lin_1 : vec3<f32> = d_lin_3 * vec3<f32>(ks_3, ks_3, kn_4);
    var qe_ang_1 : vec3<f32> = d_ang_3 * vec3<f32>(kb1_1, kb2_1, kt_3);
    var _S376 : Measures_0 = stress_measures_0(&((*b_36)), qe_lin_1, qe_ang_1);
    var _S377 : f32 = max(max(_S376.tension_0, _S376.shear_0), _S376.compression_0);
    var _S378 : bool = dt_13 > 0.0f;
    var dif_2 : f32;
    if(_S378)
    {
        var raw_1 : f32 = fdiv_0(max(fdiv_0(_S377 - st_3.governing_stress_0, dt_13), 0.0f), (*mat_9).misc_0.w);
        var tau_3 : f32 = _S375.z;
        if(((flags_2 & (u32(16)))) != u32(0))
        {
            dif_2 = - expm1_accurate_0(- fdiv_0(dt_13, tau_3));
        }
        else
        {
            dif_2 = min(fdiv_0(dt_13, tau_3), 1.0f);
        }
        st_3.strain_rate_0 = st_3.strain_rate_0 + (raw_1 - st_3.strain_rate_0) * dif_2;
        st_3.governing_stress_0 = _S377;
    }
    if(((flags_2 & (u32(32)))) != u32(0))
    {
        var _S379 : f32 = dif_factor_0(&((*mat_9)), st_3.strain_rate_0);
        dif_2 = _S379;
    }
    else
    {
        dif_2 = 1.0f;
    }
    var weibull_1 : f32 = (*b_36).geom1_0.w;
    var _S380 : f32 = weibull_1 * dif_2;
    var _S381 : f32 = fatigue_factor_1(&((*mat_9)), st_3.fatigue_0);
    var multiplier_2 : f32 = _S380 * _S381;
    var _S382 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S376, multiplier_2);
    var _S383 : f32 = _S382.x;
    var _S384 : f32 = _S382.y;
    st_3.utilization_0 = max(max(_S383, _S384), max(_S382.z, _S382.w));
    var _S385 : f32 = d_lin_3.x;
    var _S386 : f32 = d_lin_3.y;
    var _S387 : f32 = ks_3 * (sq_0(_S385) + sq_0(_S386)) + kb1_1 * sq_0(d_ang_3.x) + kb2_1 * sq_0(d_ang_3.y) + kt_3 * sq_0(d_ang_3.z);
    var _S388 : f32 = d_lin_3.z;
    var _S389 : bool = _S388 > 0.0f;
    if(_S389)
    {
        dif_2 = kn_4 * sq_0(_S388);
    }
    else
    {
        dif_2 = 0.0f;
    }
    var psi_ts_1 : f32 = 0.5f * (_S387 + dif_2);
    var psi_c_1 : f32;
    if(_S388 < 0.0f)
    {
        psi_c_1 = 0.5f * kn_4 * sq_0(_S388);
    }
    else
    {
        psi_c_1 = 0.0f;
    }
    var plastic_5 : vec3<f32> = vec3<f32>(st_3.plastic_x_0, st_3.plastic_y_0, st_3.plastic_t_0);
    var diss_contact_1 : f32;
    var psi_contact_1 : f32;
    var intact_normal_1 : f32;
    var dissipated_10 : f32;
    var overshoot_3 : f32;
    var _S390 : bool;
    var qc_lin_1 : vec3<f32>;
    if(fracture_2)
    {
        var _S391 : bool = _S383 >= _S384;
        if(_S391)
        {
            diss_contact_1 = _S383;
        }
        else
        {
            diss_contact_1 = _S384;
        }
        var mode_ts_1 : u32;
        if(_S391)
        {
            mode_ts_1 = u32(1);
        }
        else
        {
            mode_ts_1 = u32(2);
        }
        if(diss_contact_1 > (st_3.kappa_0))
        {
            _S390 = diss_contact_1 > 1.0f;
        }
        else
        {
            _S390 = false;
        }
        if(_S390)
        {
            _S390 = psi_ts_1 > 0.0f;
        }
        else
        {
            _S390 = false;
        }
        var mode_c_1 : u32;
        if(_S390)
        {
            if(mode_ts_1 == u32(1))
            {
                psi_contact_1 = (*mat_9).energy_1.y;
            }
            else
            {
                psi_contact_1 = (*mat_9).energy_1.z;
            }
            if(softening_1)
            {
                intact_normal_1 = fdiv_0(psi_contact_1 * (*b_36).geom0_0.x * diss_contact_1 * diss_contact_1, psi_ts_1);
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
            var _S392 : f32 = inc_2.x;
            if(_S392 > (st_3.damage_0))
            {
                var _S393 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), st_3.crush_1, plastic_5, d_lin_3, d_ang_3);
                var _S394 : f32 = max(_S393.energy_2 - (1.0f - st_3.crush_1) * psi_c_1, 0.0f);
                var _S395 : f32 = max(inc_2.y - _S394 * (_S392 - st_3.damage_0), 0.0f);
                var _S396 : f32 = max((psi_ts_1 - _S394) * (_S392 - st_3.damage_0) - _S395, 0.0f);
                st_3.damage_0 = _S392;
                st_3.mode_0 = mode_ts_1;
                dissipated_10 = _S395;
                overshoot_3 = _S396;
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
            var _S397 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), state_3.crush_1, vec3<f32>(state_3.plastic_x_0, state_3.plastic_y_0, state_3.plastic_t_0), d_lin_3, d_ang_3);
            qc_lin_1 = qe_ang_1 * vec3<f32>((1.0f - state_3.damage_0)) + _S397.q_ang_1 * vec3<f32>(state_3.damage_0);
        }
        else
        {
            qc_lin_1 = qe_ang_1;
        }
        var _S398 : Measures_0 = stress_measures_0(&((*b_36)), vec3<f32>(0.0f, 0.0f, min(qe_lin_1.z, 0.0f)), qc_lin_1);
        var _S399 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S398, multiplier_2);
        var _S400 : f32 = _S399.z;
        var _S401 : f32 = _S399.w;
        var _S402 : bool = _S400 >= _S401;
        if(_S402)
        {
            psi_contact_1 = _S400;
        }
        else
        {
            psi_contact_1 = _S401;
        }
        if(_S402)
        {
            mode_c_1 = u32(3);
        }
        else
        {
            mode_c_1 = u32(4);
        }
        if(psi_contact_1 > (st_3.kappa_c_0))
        {
            _S390 = psi_contact_1 > 1.0f;
        }
        else
        {
            _S390 = false;
        }
        if(_S390)
        {
            _S390 = psi_c_1 > 0.0f;
        }
        else
        {
            _S390 = false;
        }
        if(_S390)
        {
            if(softening_1)
            {
                intact_normal_1 = fdiv_0((*mat_9).energy_1.w * (*b_36).geom0_0.x * psi_contact_1 * psi_contact_1, psi_c_1);
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
            var _S403 : f32 = inc_3.x;
            if(_S403 > (st_3.crush_1))
            {
                var _S404 : f32 = inc_3.y;
                var dissipated_11 : f32 = dissipated_10 + _S404;
                var overshoot_4 : f32 = overshoot_3 + max(psi_c_1 * (_S403 - st_3.crush_1) - _S404, 0.0f);
                st_3.crush_1 = _S403;
                st_3.mode_0 = mode_c_1;
                if(_S403 >= 1.0f)
                {
                    _S390 = (st_3.damage_0) < 1.0f;
                }
                else
                {
                    _S390 = false;
                }
                if(_S390)
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
    var _S405 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_1 : vec3<f32>;
    if((st_3.damage_0) == 0.0f)
    {
        if(((flags_2 & (u32(8)))) == u32(0))
        {
            var _S406 : vec3<f32> = contact_offsets_0(&((*mat_9)), &((*b_36)), st_3.crush_1, plastic_5, d_lin_3, d_ang_3);
            st_3.plastic_x_0 = _S406.x;
            st_3.plastic_y_0 = _S406.y;
            st_3.plastic_t_0 = _S406.z;
        }
        diss_contact_1 = 0.0f;
        qc_lin_1 = _S405;
        qc_ang_1 = _S405;
        psi_contact_1 = 0.0f;
    }
    else
    {
        var _S407 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_36)), st_3.crush_1, plastic_5, d_lin_3, d_ang_3);
        st_3.plastic_x_0 = _S407.plastic_1.x;
        st_3.plastic_y_0 = _S407.plastic_1.y;
        st_3.plastic_t_0 = _S407.plastic_1.z;
        diss_contact_1 = _S407.diss_4;
        qc_lin_1 = _S407.q_lin_1;
        qc_ang_1 = _S407.q_ang_1;
        psi_contact_1 = _S407.energy_2;
    }
    var dissipated_13 : f32 = dissipated_10 + dmg_1 * diss_contact_1;
    if(_S389)
    {
        intact_normal_1 = kn_4 * _S388;
    }
    else
    {
        intact_normal_1 = (1.0f - st_3.crush_1) * kn_4 * _S388;
    }
    var _S408 : f32 = 1.0f - dmg_1;
    var force_lin_4 : vec3<f32> = vec3<f32>(_S408 * qe_lin_1.x + dmg_1 * qc_lin_1.x, _S408 * qe_lin_1.y + dmg_1 * qc_lin_1.y, _S408 * intact_normal_1 + dmg_1 * qc_lin_1.z);
    var force_ang_3 : vec3<f32> = qe_ang_1 * vec3<f32>(_S408) + qc_ang_1 * vec3<f32>(dmg_1);
    var stored_10 : f32 = _S408 * (psi_ts_1 + (1.0f - st_3.crush_1) * psi_c_1) + dmg_1 * psi_contact_1;
    if(has_rebar_3)
    {
        _S390 = (st_3.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S390 = false;
    }
    var stored_11 : f32;
    var force_lin_5 : vec3<f32>;
    if(_S390)
    {
        var k_axial_1 : f32 = (*b_36).rebar0_0.x;
        var k_dowel_1 : f32 = (*b_36).rebar0_0.y;
        var yield_force_1 : f32 = (*b_36).rebar0_0.z;
        var dowel_capacity_1 : f32 = (*b_36).rebar0_0.w;
        var nr_1 : vec2<f32> = return_map_0(k_axial_1, _S388, st_3.rebar_plastic_0, yield_force_1);
        var v1_1 : vec2<f32> = return_map_0(k_dowel_1, _S385, st_3.rebar_slip0_0, dowel_capacity_1);
        var v2_1 : vec2<f32> = return_map_0(k_dowel_1, _S386, st_3.rebar_slip1_0, dowel_capacity_1);
        var _S409 : f32 = nr_1.y;
        var _S410 : f32 = v1_1.y;
        var _S411 : f32 = v2_1.y;
        var work_1 : f32 = yield_force_1 * abs(_S409) + dowel_capacity_1 * (abs(_S410) + abs(_S411));
        st_3.rebar_plastic_0 = st_3.rebar_plastic_0 + _S409;
        st_3.rebar_slip0_0 = st_3.rebar_slip0_0 + _S410;
        st_3.rebar_slip1_0 = st_3.rebar_slip1_0 + _S411;
        st_3.rebar_work_0 = st_3.rebar_work_0 + work_1;
        var dissipated_14 : f32 = dissipated_13 + work_1;
        var _S412 : f32 = nr_1.x;
        var _S413 : f32 = v1_1.x;
        var _S414 : f32 = v2_1.x;
        var elastic_1 : f32 = 0.5f * (fdiv_0(sq_0(_S412), k_axial_1) + fdiv_0(sq_0(_S413) + sq_0(_S414), k_dowel_1));
        if(fracture_2)
        {
            _S390 = (st_3.rebar_work_0) >= ((*b_36).rebar1_0.x);
        }
        else
        {
            _S390 = false;
        }
        if(_S390)
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
            force_lin_5 = force_lin_4 + vec3<f32>(_S413, _S414, _S412);
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
        _S390 = _S378;
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        _S390 = ((flags_2 & (u32(64)))) != u32(0);
    }
    else
    {
        _S390 = false;
    }
    if(_S390)
    {
        var _S415 : Measures_0 = stress_measures_0(&((*b_36)), force_lin_5, force_ang_3);
        var _S416 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_36)), _S415, weibull_1);
        var _S417 : f32 = life_rate_0(&((*mat_9)), max(max(_S416.x, _S416.y), _S416.z));
        st_3.fatigue_0 = min(st_3.fatigue_0 + _S417 * dt_13, 1.0f);
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
        _S390 = !connected_1(st_3, has_rebar_3);
    }
    else
    {
        _S390 = false;
    }
    resp_1.disconnected_0 = _S390;
    resp_1.measures_0 = _S376;
    return resp_1;
}

fn joint_evaluate_2( mat_10 : ptr<function, JointMaterial_std140_0>,  b_37 : ptr<function, JointBond_std430_0>,  state_4 : ptr<function, JointState_std430_0>,  d_lin_4 : vec3<f32>,  d_ang_4 : vec3<f32>,  dt_14 : f32,  fracture_3 : bool) -> JointResponse_0
{
    var kn_5 : f32 = (*b_37).stiff0_0.x;
    var ks_4 : f32 = (*b_37).stiff0_0.y;
    var kb1_2 : f32 = (*b_37).stiff0_0.z;
    var kb2_2 : f32 = (*b_37).stiff0_0.w;
    var _S418 : vec4<f32> = (*b_37).stiff1_0;
    var kt_4 : f32 = (*b_37).stiff1_0.x;
    var has_rebar_4 : bool = ((*b_37).stiff1_0.w) != 0.0f;
    var kind_6 : u32 = (*mat_10).kind_flags_0.x;
    var flags_3 : u32 = (*mat_10).kind_flags_0.y;
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
    var _S419 : bool = connected_0(&((*state_4)), has_rebar_4);
    var qe_lin_2 : vec3<f32> = d_lin_4 * vec3<f32>(ks_4, ks_4, kn_5);
    var qe_ang_2 : vec3<f32> = d_ang_4 * vec3<f32>(kb1_2, kb2_2, kt_4);
    var _S420 : Measures_0 = stress_measures_0(&((*b_37)), qe_lin_2, qe_ang_2);
    var _S421 : f32 = max(max(_S420.tension_0, _S420.shear_0), _S420.compression_0);
    var _S422 : bool = dt_14 > 0.0f;
    var dif_3 : f32;
    if(_S422)
    {
        var raw_2 : f32 = fdiv_0(max(fdiv_0(_S421 - st_4.governing_stress_0, dt_14), 0.0f), (*mat_10).misc_0.w);
        var tau_4 : f32 = _S418.z;
        if(((flags_3 & (u32(16)))) != u32(0))
        {
            dif_3 = - expm1_accurate_0(- fdiv_0(dt_14, tau_4));
        }
        else
        {
            dif_3 = min(fdiv_0(dt_14, tau_4), 1.0f);
        }
        st_4.strain_rate_0 = st_4.strain_rate_0 + (raw_2 - st_4.strain_rate_0) * dif_3;
        st_4.governing_stress_0 = _S421;
    }
    if(((flags_3 & (u32(32)))) != u32(0))
    {
        var _S423 : f32 = dif_factor_0(&((*mat_10)), st_4.strain_rate_0);
        dif_3 = _S423;
    }
    else
    {
        dif_3 = 1.0f;
    }
    var weibull_2 : f32 = (*b_37).geom1_0.w;
    var _S424 : f32 = weibull_2 * dif_3;
    var _S425 : f32 = fatigue_factor_1(&((*mat_10)), st_4.fatigue_0);
    var multiplier_3 : f32 = _S424 * _S425;
    var _S426 : vec4<f32> = failure_indices_0(&((*mat_10)), &((*b_37)), _S420, multiplier_3);
    var _S427 : f32 = _S426.x;
    var _S428 : f32 = _S426.y;
    st_4.utilization_0 = max(max(_S427, _S428), max(_S426.z, _S426.w));
    var _S429 : f32 = d_lin_4.x;
    var _S430 : f32 = d_lin_4.y;
    var _S431 : f32 = ks_4 * (sq_0(_S429) + sq_0(_S430)) + kb1_2 * sq_0(d_ang_4.x) + kb2_2 * sq_0(d_ang_4.y) + kt_4 * sq_0(d_ang_4.z);
    var _S432 : f32 = d_lin_4.z;
    var _S433 : bool = _S432 > 0.0f;
    if(_S433)
    {
        dif_3 = kn_5 * sq_0(_S432);
    }
    else
    {
        dif_3 = 0.0f;
    }
    var psi_ts_2 : f32 = 0.5f * (_S431 + dif_3);
    var psi_c_2 : f32;
    if(_S432 < 0.0f)
    {
        psi_c_2 = 0.5f * kn_5 * sq_0(_S432);
    }
    else
    {
        psi_c_2 = 0.0f;
    }
    var plastic_6 : vec3<f32> = vec3<f32>(st_4.plastic_x_0, st_4.plastic_y_0, st_4.plastic_t_0);
    var diss_contact_2 : f32;
    var psi_contact_2 : f32;
    var intact_normal_2 : f32;
    var dissipated_16 : f32;
    var overshoot_5 : f32;
    var _S434 : bool;
    var qc_lin_2 : vec3<f32>;
    if(fracture_3)
    {
        var _S435 : bool = _S427 >= _S428;
        if(_S435)
        {
            diss_contact_2 = _S427;
        }
        else
        {
            diss_contact_2 = _S428;
        }
        var mode_ts_2 : u32;
        if(_S435)
        {
            mode_ts_2 = u32(1);
        }
        else
        {
            mode_ts_2 = u32(2);
        }
        if(diss_contact_2 > (st_4.kappa_0))
        {
            _S434 = diss_contact_2 > 1.0f;
        }
        else
        {
            _S434 = false;
        }
        if(_S434)
        {
            _S434 = psi_ts_2 > 0.0f;
        }
        else
        {
            _S434 = false;
        }
        var mode_c_2 : u32;
        if(_S434)
        {
            if(mode_ts_2 == u32(1))
            {
                psi_contact_2 = (*mat_10).energy_1.y;
            }
            else
            {
                psi_contact_2 = (*mat_10).energy_1.z;
            }
            if(softening_2)
            {
                intact_normal_2 = fdiv_0(psi_contact_2 * (*b_37).geom0_0.x * diss_contact_2 * diss_contact_2, psi_ts_2);
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
            var _S436 : f32 = inc_4.x;
            if(_S436 > (st_4.damage_0))
            {
                var _S437 : Contact_0 = contact_part_0(&((*mat_10)), &((*b_37)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
                var _S438 : f32 = max(_S437.energy_2 - (1.0f - st_4.crush_1) * psi_c_2, 0.0f);
                var _S439 : f32 = max(inc_4.y - _S438 * (_S436 - st_4.damage_0), 0.0f);
                var _S440 : f32 = max((psi_ts_2 - _S438) * (_S436 - st_4.damage_0) - _S439, 0.0f);
                st_4.damage_0 = _S436;
                st_4.mode_0 = mode_ts_2;
                dissipated_16 = _S439;
                overshoot_5 = _S440;
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
        var _S441 : f32 = (*state_4).damage_0;
        if(((*state_4).damage_0) > 0.0f)
        {
            var _S442 : Contact_0 = contact_part_0(&((*mat_10)), &((*b_37)), (*state_4).crush_1, vec3<f32>((*state_4).plastic_x_0, (*state_4).plastic_y_0, (*state_4).plastic_t_0), d_lin_4, d_ang_4);
            qc_lin_2 = qe_ang_2 * vec3<f32>((1.0f - _S441)) + _S442.q_ang_1 * vec3<f32>(_S441);
        }
        else
        {
            qc_lin_2 = qe_ang_2;
        }
        var _S443 : Measures_0 = stress_measures_0(&((*b_37)), vec3<f32>(0.0f, 0.0f, min(qe_lin_2.z, 0.0f)), qc_lin_2);
        var _S444 : vec4<f32> = failure_indices_0(&((*mat_10)), &((*b_37)), _S443, multiplier_3);
        var _S445 : f32 = _S444.z;
        var _S446 : f32 = _S444.w;
        var _S447 : bool = _S445 >= _S446;
        if(_S447)
        {
            psi_contact_2 = _S445;
        }
        else
        {
            psi_contact_2 = _S446;
        }
        if(_S447)
        {
            mode_c_2 = u32(3);
        }
        else
        {
            mode_c_2 = u32(4);
        }
        if(psi_contact_2 > (st_4.kappa_c_0))
        {
            _S434 = psi_contact_2 > 1.0f;
        }
        else
        {
            _S434 = false;
        }
        if(_S434)
        {
            _S434 = psi_c_2 > 0.0f;
        }
        else
        {
            _S434 = false;
        }
        if(_S434)
        {
            if(softening_2)
            {
                intact_normal_2 = fdiv_0((*mat_10).energy_1.w * (*b_37).geom0_0.x * psi_contact_2 * psi_contact_2, psi_c_2);
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
            var _S448 : f32 = inc_5.x;
            if(_S448 > (st_4.crush_1))
            {
                var _S449 : f32 = inc_5.y;
                var dissipated_17 : f32 = dissipated_16 + _S449;
                var overshoot_6 : f32 = overshoot_5 + max(psi_c_2 * (_S448 - st_4.crush_1) - _S449, 0.0f);
                st_4.crush_1 = _S448;
                st_4.mode_0 = mode_c_2;
                if(_S448 >= 1.0f)
                {
                    _S434 = (st_4.damage_0) < 1.0f;
                }
                else
                {
                    _S434 = false;
                }
                if(_S434)
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
    var _S450 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_2 : vec3<f32>;
    if((st_4.damage_0) == 0.0f)
    {
        if(((flags_3 & (u32(8)))) == u32(0))
        {
            var _S451 : vec3<f32> = contact_offsets_0(&((*mat_10)), &((*b_37)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
            st_4.plastic_x_0 = _S451.x;
            st_4.plastic_y_0 = _S451.y;
            st_4.plastic_t_0 = _S451.z;
        }
        diss_contact_2 = 0.0f;
        qc_lin_2 = _S450;
        qc_ang_2 = _S450;
        psi_contact_2 = 0.0f;
    }
    else
    {
        var _S452 : Contact_0 = contact_part_0(&((*mat_10)), &((*b_37)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
        st_4.plastic_x_0 = _S452.plastic_1.x;
        st_4.plastic_y_0 = _S452.plastic_1.y;
        st_4.plastic_t_0 = _S452.plastic_1.z;
        diss_contact_2 = _S452.diss_4;
        qc_lin_2 = _S452.q_lin_1;
        qc_ang_2 = _S452.q_ang_1;
        psi_contact_2 = _S452.energy_2;
    }
    var dissipated_19 : f32 = dissipated_16 + dmg_2 * diss_contact_2;
    if(_S433)
    {
        intact_normal_2 = kn_5 * _S432;
    }
    else
    {
        intact_normal_2 = (1.0f - st_4.crush_1) * kn_5 * _S432;
    }
    var _S453 : f32 = 1.0f - dmg_2;
    var force_lin_6 : vec3<f32> = vec3<f32>(_S453 * qe_lin_2.x + dmg_2 * qc_lin_2.x, _S453 * qe_lin_2.y + dmg_2 * qc_lin_2.y, _S453 * intact_normal_2 + dmg_2 * qc_lin_2.z);
    var force_ang_4 : vec3<f32> = qe_ang_2 * vec3<f32>(_S453) + qc_ang_2 * vec3<f32>(dmg_2);
    var stored_13 : f32 = _S453 * (psi_ts_2 + (1.0f - st_4.crush_1) * psi_c_2) + dmg_2 * psi_contact_2;
    if(has_rebar_4)
    {
        _S434 = (st_4.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S434 = false;
    }
    var stored_14 : f32;
    var force_lin_7 : vec3<f32>;
    if(_S434)
    {
        var k_axial_2 : f32 = (*b_37).rebar0_0.x;
        var k_dowel_2 : f32 = (*b_37).rebar0_0.y;
        var yield_force_2 : f32 = (*b_37).rebar0_0.z;
        var dowel_capacity_2 : f32 = (*b_37).rebar0_0.w;
        var nr_2 : vec2<f32> = return_map_0(k_axial_2, _S432, st_4.rebar_plastic_0, yield_force_2);
        var v1_2 : vec2<f32> = return_map_0(k_dowel_2, _S429, st_4.rebar_slip0_0, dowel_capacity_2);
        var v2_2 : vec2<f32> = return_map_0(k_dowel_2, _S430, st_4.rebar_slip1_0, dowel_capacity_2);
        var _S454 : f32 = nr_2.y;
        var _S455 : f32 = v1_2.y;
        var _S456 : f32 = v2_2.y;
        var work_2 : f32 = yield_force_2 * abs(_S454) + dowel_capacity_2 * (abs(_S455) + abs(_S456));
        st_4.rebar_plastic_0 = st_4.rebar_plastic_0 + _S454;
        st_4.rebar_slip0_0 = st_4.rebar_slip0_0 + _S455;
        st_4.rebar_slip1_0 = st_4.rebar_slip1_0 + _S456;
        st_4.rebar_work_0 = st_4.rebar_work_0 + work_2;
        var dissipated_20 : f32 = dissipated_19 + work_2;
        var _S457 : f32 = nr_2.x;
        var _S458 : f32 = v1_2.x;
        var _S459 : f32 = v2_2.x;
        var elastic_2 : f32 = 0.5f * (fdiv_0(sq_0(_S457), k_axial_2) + fdiv_0(sq_0(_S458) + sq_0(_S459), k_dowel_2));
        if(fracture_3)
        {
            _S434 = (st_4.rebar_work_0) >= ((*b_37).rebar1_0.x);
        }
        else
        {
            _S434 = false;
        }
        if(_S434)
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
            force_lin_7 = force_lin_6 + vec3<f32>(_S458, _S459, _S457);
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
        _S434 = _S422;
    }
    else
    {
        _S434 = false;
    }
    if(_S434)
    {
        _S434 = ((flags_3 & (u32(64)))) != u32(0);
    }
    else
    {
        _S434 = false;
    }
    if(_S434)
    {
        var _S460 : Measures_0 = stress_measures_0(&((*b_37)), force_lin_7, force_ang_4);
        var _S461 : vec4<f32> = failure_indices_0(&((*mat_10)), &((*b_37)), _S460, weibull_2);
        var _S462 : f32 = life_rate_0(&((*mat_10)), max(max(_S461.x, _S461.y), _S461.z));
        st_4.fatigue_0 = min(st_4.fatigue_0 + _S462 * dt_14, 1.0f);
    }
    st_4.dissipated_0 = st_4.dissipated_0 + dissipated_16;
    var resp_2 : JointResponse_0;
    resp_2.force_lin_1 = force_lin_7;
    resp_2.force_ang_1 = force_ang_4;
    resp_2.state_1 = st_4;
    resp_2.dissipated_3 = dissipated_16;
    resp_2.overshoot_0 = overshoot_5;
    resp_2.stored_6 = stored_14;
    if(_S419)
    {
        _S434 = !connected_1(st_4, has_rebar_4);
    }
    else
    {
        _S434 = false;
    }
    resp_2.disconnected_0 = _S434;
    resp_2.measures_0 = _S420;
    return resp_2;
}

fn secant_factors_0( b_38 : ptr<function, JointBond_std430_0>,  st_5 : ptr<function, JointState_std430_0>,  d_lin_5 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var _S463 : f32 = (*st_5).damage_0;
    var compressed_0 : bool = (d_lin_5.z) < 0.0f;
    var contact_3 : f32;
    if(compressed_0)
    {
        contact_3 = _S463;
    }
    else
    {
        contact_3 = 0.0f;
    }
    var _S464 : f32 = 1.0f - _S463;
    var _S465 : f32 = max(_S464 + contact_3, 9.99999997475242708e-07f);
    var normal_6 : f32;
    if(compressed_0)
    {
        normal_6 = max(1.0f - (*st_5).crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_6 = max(_S464, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S465, _S465, normal_6);
    (*f_ang_0) = vec3<f32>(_S465);
    var _S466 : bool;
    if(((*b_38).stiff1_0.w) != 0.0f)
    {
        _S466 = ((*st_5).rebar_broken_0) == 0.0f;
    }
    else
    {
        _S466 = false;
    }
    if(_S466)
    {
        var _S467 : vec4<f32> = (*b_38).rebar0_0;
        var _S468 : vec4<f32> = (*b_38).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + fdiv_0((*b_38).rebar0_0.x, (*b_38).stiff0_0.x);
        var _S469 : f32 = fdiv_0(_S467.y, _S468.y);
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S469;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S469;
    }
    return;
}

fn secant_factors_1( b_39 : ptr<function, JointBond_std430_0>,  st_6 : JointState_0,  d_lin_6 : vec3<f32>,  f_lin_1 : ptr<function, vec3<f32>>,  f_ang_1 : ptr<function, vec3<f32>>)
{
    var compressed_1 : bool = (d_lin_6.z) < 0.0f;
    var contact_4 : f32;
    if(compressed_1)
    {
        contact_4 = st_6.damage_0;
    }
    else
    {
        contact_4 = 0.0f;
    }
    var _S470 : f32 = 1.0f - st_6.damage_0;
    var _S471 : f32 = max(_S470 + contact_4, 9.99999997475242708e-07f);
    var normal_7 : f32;
    if(compressed_1)
    {
        normal_7 = max(1.0f - st_6.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_7 = max(_S470, 9.99999997475242708e-07f);
    }
    (*f_lin_1) = vec3<f32>(_S471, _S471, normal_7);
    (*f_ang_1) = vec3<f32>(_S471);
    var _S472 : bool;
    if(((*b_39).stiff1_0.w) != 0.0f)
    {
        _S472 = (st_6.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S472 = false;
    }
    if(_S472)
    {
        var _S473 : vec4<f32> = (*b_39).rebar0_0;
        var _S474 : vec4<f32> = (*b_39).stiff0_0;
        (*f_lin_1)[i32(2)] = (*f_lin_1)[i32(2)] + fdiv_0((*b_39).rebar0_0.x, (*b_39).stiff0_0.x);
        var _S475 : f32 = fdiv_0(_S473.y, _S474.y);
        (*f_lin_1)[i32(0)] = (*f_lin_1)[i32(0)] + _S475;
        (*f_lin_1)[i32(1)] = (*f_lin_1)[i32(1)] + _S475;
    }
    return;
}

fn is_damaged_0( st_7 : JointState_0) -> bool
{
    var _S476 : bool;
    if((st_7.damage_0) > 0.0f)
    {
        _S476 = true;
    }
    else
    {
        _S476 = (st_7.crush_1) > 0.0f;
    }
    return _S476;
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

fn to_local_0( _S477 : u32,  _S478 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S478, bonds_0[_S477].t1_0.xyz), dot(_S478, bonds_0[_S477].t2_0.xyz), dot(_S478, bonds_0[_S477].normal_0.xyz));
}

fn to_body_0( _S479 : u32,  _S480 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S479].t1_0.xyz * vec3<f32>(_S480.x) + bonds_0[_S479].t2_0.xyz * vec3<f32>(_S480.y) + bonds_0[_S479].normal_0.xyz * vec3<f32>(_S480.z);
}

fn bond_update_0( i_9 : u32,  dt_15 : f32,  fracture_4 : bool,  abs_step_0 : u32) -> bool
{
    var _S481 : JointState_0 = JointState_0( bond_dyn_0[i_9].js_0.damage_0, bond_dyn_0[i_9].js_0.crush_1, bond_dyn_0[i_9].js_0.kappa_0, bond_dyn_0[i_9].js_0.kappa_c_0, bond_dyn_0[i_9].js_0.ductility_0, bond_dyn_0[i_9].js_0.ductility_c_0, bond_dyn_0[i_9].js_0.fatigue_0, bond_dyn_0[i_9].js_0.plastic_x_0, bond_dyn_0[i_9].js_0.plastic_y_0, bond_dyn_0[i_9].js_0.plastic_t_0, bond_dyn_0[i_9].js_0.rebar_plastic_0, bond_dyn_0[i_9].js_0.rebar_slip0_0, bond_dyn_0[i_9].js_0.rebar_slip1_0, bond_dyn_0[i_9].js_0.rebar_work_0, bond_dyn_0[i_9].js_0.rebar_broken_0, bond_dyn_0[i_9].js_0.strain_rate_0, bond_dyn_0[i_9].js_0.governing_stress_0, bond_dyn_0[i_9].js_0.dissipated_0, bond_dyn_0[i_9].js_0.utilization_0, bond_dyn_0[i_9].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S481;
    bd_0.force_lin_0 = bond_dyn_0[i_9].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_9].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_9].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_9].comps_0;
    bd_0.events_0 = bond_dyn_0[i_9].events_0;
    var _S482 : JointBond_std430_0 = bonds_0[i_9].law_0;
    var ra_1 : vec3<f32> = bonds_0[i_9].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_9].rb_0.xyz;
    var _S483 : u32 = u32(4) * _S482.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S483 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S483 + u32(3)].xyz;
    var _S484 : u32 = u32(4) * _S482.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S484 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S484 + u32(3)].xyz;
    var _S485 : vec3<f32> = to_local_0(i_9, state_0[_S484].xyz + cross(tb_3, rb_1) - (state_0[_S483].xyz + cross(ta_3, ra_1)));
    var _S486 : vec3<f32> = to_local_0(i_9, tb_3 - ta_3);
    var _S487 : vec3<f32> = to_local_0(i_9, state_0[_S484 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S483 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S488 : vec3<f32> = to_local_0(i_9, wb_0 - wa_0);
    var _S489 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S482.ids_0.x];
    var previous_0 : JointState_0 = bd_0.js_0;
    var _S490 : JointResponse_0 = joint_evaluate_0(&(_S489), &(_S482), bd_0.js_0, _S485, _S486, dt_15, fracture_4);
    var f_lin_2 : vec3<f32>;
    var f_ang_2 : vec3<f32>;
    secant_factors_1(&(_S482), _S490.state_1, _S485, &(f_lin_2), &(f_ang_2));
    var qd_lin_0 : vec3<f32> = _S487 * bonds_0[i_9].c_lin_0.xyz * f_lin_2;
    var qd_ang_0 : vec3<f32> = _S488 * bonds_0[i_9].c_ang_0.xyz * f_ang_2;
    var q_lin_2 : vec3<f32> = _S490.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S490.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S487) + dot(qd_ang_0, _S488)) * dt_15;
    var _S491 : vec3<f32> = to_body_0(i_9, q_lin_2);
    var _S492 : vec3<f32> = to_body_0(i_9, q_ang_2);
    var _S493 : u32 = u32(3) * i_9;
    scratch_0[_S493] = vec4<f32>(_S491, max(_S490.measures_0.tension_0, _S490.measures_0.compression_0));
    scratch_0[_S493 + u32(1)] = vec4<f32>(_S492 + cross(ra_1, _S491), 0.0f);
    scratch_0[_S493 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S492) + cross(rb_1, (vec3<f32>(0) - _S491)), 0.0f);
    var _S494 : f32 = bd_0.sums_0[i32(0)];
    var _S495 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S494), &(_S495), _S490.dissipated_3);
    bd_0.sums_0[i32(0)] = _S494;
    bd_0.comps_0[i32(0)] = _S495;
    var _S496 : f32 = bd_0.sums_0[i32(1)];
    var _S497 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S496), &(_S497), _S490.overshoot_0);
    bd_0.sums_0[i32(1)] = _S496;
    bd_0.comps_0[i32(1)] = _S497;
    var _S498 : f32 = bd_0.sums_0[i32(2)];
    var _S499 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S498), &(_S499), damped_0);
    bd_0.sums_0[i32(2)] = _S498;
    bd_0.comps_0[i32(2)] = _S499;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S490.stored_6);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S490.state_1.utilization_0));
    var _S500 : bool;
    if(!is_damaged_0(bd_0.js_0))
    {
        _S500 = is_damaged_0(_S490.state_1);
    }
    else
    {
        _S500 = false;
    }
    if(_S500)
    {
        _S500 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S500 = false;
    }
    if(_S500)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S490.state_1.mode_0;
    }
    if((bd_0.events_0.y) == u32(0))
    {
        var _S501 : f32 = fatigue_factor_0(&(_S489), previous_0.fatigue_0);
        _S500 = _S501 > 0.99000000953674316f;
    }
    else
    {
        _S500 = false;
    }
    if(_S500)
    {
        var _S502 : f32 = fatigue_factor_0(&(_S489), _S490.state_1.fatigue_0);
        _S500 = _S502 <= 0.99000000953674316f;
    }
    else
    {
        _S500 = false;
    }
    if(_S500)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
    }
    if(_S490.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
    }
    bd_0.js_0 = _S490.state_1;
    bond_dyn_0[i_9].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_9].js_0.crush_1 = bd_0.js_0.crush_1;
    bond_dyn_0[i_9].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_9].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_9].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_9].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_9].js_0.fatigue_0 = bd_0.js_0.fatigue_0;
    bond_dyn_0[i_9].js_0.plastic_x_0 = bd_0.js_0.plastic_x_0;
    bond_dyn_0[i_9].js_0.plastic_y_0 = bd_0.js_0.plastic_y_0;
    bond_dyn_0[i_9].js_0.plastic_t_0 = bd_0.js_0.plastic_t_0;
    bond_dyn_0[i_9].js_0.rebar_plastic_0 = bd_0.js_0.rebar_plastic_0;
    bond_dyn_0[i_9].js_0.rebar_slip0_0 = bd_0.js_0.rebar_slip0_0;
    bond_dyn_0[i_9].js_0.rebar_slip1_0 = bd_0.js_0.rebar_slip1_0;
    bond_dyn_0[i_9].js_0.rebar_work_0 = bd_0.js_0.rebar_work_0;
    bond_dyn_0[i_9].js_0.rebar_broken_0 = bd_0.js_0.rebar_broken_0;
    bond_dyn_0[i_9].js_0.strain_rate_0 = bd_0.js_0.strain_rate_0;
    bond_dyn_0[i_9].js_0.governing_stress_0 = bd_0.js_0.governing_stress_0;
    bond_dyn_0[i_9].js_0.dissipated_0 = bd_0.js_0.dissipated_0;
    bond_dyn_0[i_9].js_0.utilization_0 = bd_0.js_0.utilization_0;
    bond_dyn_0[i_9].js_0.mode_0 = bd_0.js_0.mode_0;
    bond_dyn_0[i_9].force_lin_0 = bd_0.force_lin_0;
    bond_dyn_0[i_9].force_ang_0 = bd_0.force_ang_0;
    bond_dyn_0[i_9].sums_0 = bd_0.sums_0;
    bond_dyn_0[i_9].comps_0 = bd_0.comps_0;
    bond_dyn_0[i_9].events_0 = bd_0.events_0;
    return _S490.disconnected_0;
}

fn chunk_update_0( c_15 : u32,  isl_11 : ptr<function, Island_std430_0>,  rg_9 : Rigid_0,  dt_16 : f32,  rml_0 : bool,  step_0 : u32,  contact_5 : bool,  work_3 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S503 : vec3<f32> = vec3<f32>(0.0f);
    var _S504 : u32 = index_0[c_15];
    var peak_0 : f32 = 0.0f;
    var e_3 : u32 = _S504;
    var fi_0 : vec3<f32> = _S503;
    var mi_0 : vec3<f32> = _S503;
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
        var _S505 : u32 = u32(3) * ((entry_2 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S505];
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + scratch_0[_S505 + u32(1)].xyz;
            fi_0 = fi_0 + fa_2.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + scratch_0[_S505 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_2.xyz);
            mi_0 = mi_2;
        }
        var _S506 : f32 = max(peak_0, fa_2.w);
        var _S507 : u32 = e_3 + u32(1);
        peak_0 = _S506;
        e_3 = _S507;
    }
    var _S508 : u32 = u32(4) * c_15;
    var u_0 : vec3<f32> = state_0[_S508].xyz;
    var _S509 : u32 = _S508 + u32(1);
    var th_1 : vec3<f32> = state_0[_S509].xyz;
    var _S510 : u32 = _S508 + u32(2);
    var v_9 : vec3<f32> = state_0[_S510].xyz;
    var _S511 : u32 = _S508 + u32(3);
    var w_5 : vec3<f32> = state_0[_S511].xyz;
    var mass_0 : f32 = chunks_0[c_15].center_0.w;
    var _S512 : vec3<f32> = chunks_0[c_15].center_0.xyz;
    var _S513 : vec3<f32> = (*isl_11).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_9.rot_0, _S512 + u_0 - _S513);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    chunk_external_1(c_15, c_15, rg_9.rot_0, step_0, dt_16, contact_5, &(f_load_0), &(t_load_0));
    record_chunk_load_0(c_15, f_load_0, t_load_0);
    var _S514 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S514;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.alpha_0) + cross(rg_9.w_4, world_mul_0(rg_9.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_9.w_4)));
        f_world_1 = f_world_0 - (rg_9.a_8 + cross(rg_9.alpha_0, r_world_0) + cross(rg_9.w_4, cross(rg_9.w_4, r_world_0))) * _S514;
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
    var _S515 : vec4<u32> = chunks_0[c_15].load_range_0;
    var term_5 : u32 = chunks_0[c_15].load_range_0.x;
    loop
    {
        if(term_5 < (_S515.y))
        {
        }
        else
        {
            break;
        }
        var _S516 : u32 = u32(5) * term_5;
        if(((bitcast<vec4<u32>>((loads_0[_S516]))).y) != u32(2))
        {
            term_5 = term_5 + u32(1);
            continue;
        }
        var _S517 : vec3<f32> = vec3<f32>(eval_function_0(term_5, step_0, dt_16, dt_16));
        var m_ext_3 : vec3<f32> = m_ext_1 + loads_0[_S516 + u32(2)].xyz * _S517;
        f_ext_1 = f_ext_1 + loads_0[_S516 + u32(1)].xyz * _S517;
        m_ext_1 = m_ext_3;
        term_5 = term_5 + u32(1);
    }
    var f_16 : vec3<f32> = f_ext_1 + fi_0;
    var m_5 : vec3<f32> = m_ext_1 + mi_0;
    var support_0 : u32 = chunks_0[c_15].info_1.x;
    var _S518 : vec3<f32> = vec3<f32>(state_0[_S509].w, state_0[_S510].w, state_0[_S511].w);
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
        v_10 = _S503;
        w_6 = _S503;
    }
    else
    {
        var _S519 : vec4<f32> = chunks_0[c_15].scale_0;
        var w_7 : vec3<f32> = w_5 + rows_mul_0(chunks_0[c_15].inv0_1, chunks_0[c_15].inv1_1, chunks_0[c_15].inv2_1, m_5) * vec3<f32>((dt_16 * chunks_0[c_15].scale_0.z));
        var _S520 : vec3<f32> = vec3<f32>(dt_16);
        var th_3 : vec3<f32> = th_1 + w_7 * _S520;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_16);
            u_1 = u_0;
            th_2 = _S503;
        }
        else
        {
            var v_11 : vec3<f32> = v_9 + f_16 * vec3<f32>((dt_16 * _S519.y));
            var u_2 : vec3<f32> = u_0 + v_11 * _S520;
            reaction_0 = _S518;
            u_1 = u_2;
            th_2 = v_11;
        }
        var _S521 : vec3<f32> = th_2;
        th_2 = th_3;
        v_10 = _S521;
        w_6 = w_7;
    }
    state_0[_S508] = vec4<f32>(u_1, peak_0);
    state_0[_S509] = vec4<f32>(th_2, reaction_0.x);
    state_0[_S510] = vec4<f32>(v_10, reaction_0.y);
    state_0[_S511] = vec4<f32>(w_6, reaction_0.z);
    comp_add1_2(&((*work_3)), &((*work_err_0)), (dot(f_load_0, rg_9.vel_1 + rg_9.vel_err_1 + cross(rg_9.w_4, rotate_0(rg_9.rot_0, _S512 + u_1 - _S513)) + rotate_0(rg_9.rot_0, v_10)) + dot(t_load_0, rg_9.w_4 + rotate_0(rg_9.rot_0, w_6))) * dt_16);
    return;
}

fn chunk_update_1( c_16 : u32,  isl_12 : Island_0,  rg_10 : Rigid_0,  dt_17 : f32,  rml_1 : bool,  step_1 : u32,  contact_6 : bool,  work_4 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S522 : vec3<f32> = vec3<f32>(0.0f);
    var _S523 : u32 = index_0[c_16];
    var peak_1 : f32 = 0.0f;
    var e_4 : u32 = _S523;
    var fi_1 : vec3<f32> = _S522;
    var mi_3 : vec3<f32> = _S522;
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
        var _S524 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var fa_3 : vec4<f32> = scratch_0[_S524];
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            var mi_4 : vec3<f32> = mi_3 + scratch_0[_S524 + u32(1)].xyz;
            fi_1 = fi_1 + fa_3.xyz;
            mi_3 = mi_4;
        }
        else
        {
            var mi_5 : vec3<f32> = mi_3 + scratch_0[_S524 + u32(2)].xyz;
            fi_1 = fi_1 + (vec3<f32>(0) - fa_3.xyz);
            mi_3 = mi_5;
        }
        var _S525 : f32 = max(peak_1, fa_3.w);
        var _S526 : u32 = e_4 + u32(1);
        peak_1 = _S525;
        e_4 = _S526;
    }
    var _S527 : u32 = u32(4) * c_16;
    var u_3 : vec3<f32> = state_0[_S527].xyz;
    var _S528 : u32 = _S527 + u32(1);
    var th_4 : vec3<f32> = state_0[_S528].xyz;
    var _S529 : u32 = _S527 + u32(2);
    var v_12 : vec3<f32> = state_0[_S529].xyz;
    var _S530 : u32 = _S527 + u32(3);
    var w_8 : vec3<f32> = state_0[_S530].xyz;
    var mass_1 : f32 = chunks_0[c_16].center_0.w;
    var _S531 : vec3<f32> = chunks_0[c_16].center_0.xyz;
    var _S532 : vec3<f32> = isl_12.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_10.rot_0, _S531 + u_3 - _S532);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    chunk_external_1(c_16, c_16, rg_10.rot_0, step_1, dt_17, contact_6, &(f_load_1), &(t_load_1));
    record_chunk_load_0(c_16, f_load_1, t_load_1);
    var _S533 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S533;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.alpha_0) + cross(rg_10.w_4, world_mul_0(rg_10.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_10.w_4)));
        f_world_3 = f_world_2 - (rg_10.a_8 + cross(rg_10.alpha_0, r_world_1) + cross(rg_10.w_4, cross(rg_10.w_4, r_world_1))) * _S533;
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
    var _S534 : vec4<u32> = chunks_0[c_16].load_range_0;
    var term_6 : u32 = chunks_0[c_16].load_range_0.x;
    loop
    {
        if(term_6 < (_S534.y))
        {
        }
        else
        {
            break;
        }
        var _S535 : u32 = u32(5) * term_6;
        if(((bitcast<vec4<u32>>((loads_0[_S535]))).y) != u32(2))
        {
            term_6 = term_6 + u32(1);
            continue;
        }
        var _S536 : vec3<f32> = vec3<f32>(eval_function_0(term_6, step_1, dt_17, dt_17));
        var m_ext_7 : vec3<f32> = m_ext_5 + loads_0[_S535 + u32(2)].xyz * _S536;
        f_ext_3 = f_ext_3 + loads_0[_S535 + u32(1)].xyz * _S536;
        m_ext_5 = m_ext_7;
        term_6 = term_6 + u32(1);
    }
    var f_17 : vec3<f32> = f_ext_3 + fi_1;
    var m_6 : vec3<f32> = m_ext_5 + mi_3;
    var support_1 : u32 = chunks_0[c_16].info_1.x;
    var _S537 : vec3<f32> = vec3<f32>(state_0[_S528].w, state_0[_S529].w, state_0[_S530].w);
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
        v_13 = _S522;
        w_9 = _S522;
    }
    else
    {
        var _S538 : vec4<f32> = chunks_0[c_16].scale_0;
        var w_10 : vec3<f32> = w_8 + rows_mul_0(chunks_0[c_16].inv0_1, chunks_0[c_16].inv1_1, chunks_0[c_16].inv2_1, m_6) * vec3<f32>((dt_17 * chunks_0[c_16].scale_0.z));
        var _S539 : vec3<f32> = vec3<f32>(dt_17);
        var th_6 : vec3<f32> = th_4 + w_10 * _S539;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_17);
            u_4 = u_3;
            th_5 = _S522;
        }
        else
        {
            var v_14 : vec3<f32> = v_12 + f_17 * vec3<f32>((dt_17 * _S538.y));
            var u_5 : vec3<f32> = u_3 + v_14 * _S539;
            reaction_1 = _S537;
            u_4 = u_5;
            th_5 = v_14;
        }
        var _S540 : vec3<f32> = th_5;
        th_5 = th_6;
        v_13 = _S540;
        w_9 = w_10;
    }
    state_0[_S527] = vec4<f32>(u_4, peak_1);
    state_0[_S528] = vec4<f32>(th_5, reaction_1.x);
    state_0[_S529] = vec4<f32>(v_13, reaction_1.y);
    state_0[_S530] = vec4<f32>(w_9, reaction_1.z);
    comp_add1_2(&((*work_4)), &((*work_err_1)), (dot(f_load_1, rg_10.vel_1 + rg_10.vel_err_1 + cross(rg_10.w_4, rotate_0(rg_10.rot_0, _S531 + u_4 - _S532)) + rotate_0(rg_10.rot_0, v_13)) + dot(t_load_1, rg_10.w_4 + rotate_0(rg_10.rot_0, w_9))) * dt_17);
    return;
}

fn drift_moments_0( c_17 : u32,  tu_0 : ptr<function, vec3<f32>>,  pv_0 : ptr<function, vec3<f32>>)
{
    var _S541 : u32 = u32(4) * c_17;
    var _S542 : vec3<f32> = vec3<f32>((chunks_0[c_17].center_0.w * chunks_0[c_17].scale_0.x));
    (*tu_0) = (*tu_0) + state_0[_S541].xyz * _S542;
    (*pv_0) = (*pv_0) + state_0[_S541 + u32(2)].xyz * _S542;
    return;
}

fn drift_angular_0( c_18 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_13 : vec3<f32> = chunks_0[c_18].center_0.xyz - wcom_1;
    var _S543 : u32 = u32(4) * c_18;
    var _S544 : vec3<f32> = vec3<f32>(chunks_0[c_18].center_0.w);
    var _S545 : vec4<f32> = chunks_0[c_18].inertia0_1;
    var _S546 : vec4<f32> = chunks_0[c_18].inertia1_1;
    var _S547 : vec4<f32> = chunks_0[c_18].inertia2_1;
    var _S548 : vec3<f32> = vec3<f32>(chunks_0[c_18].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_13, state_0[_S543].xyz - tr_0) * _S544 + rows_mul_0(chunks_0[c_18].inertia0_1, chunks_0[c_18].inertia1_1, chunks_0[c_18].inertia2_1, state_0[_S543 + u32(1)].xyz)) * _S548;
    (*lv_0) = (*lv_0) + (cross(r_13, state_0[_S543 + u32(2)].xyz - dv_0) * _S544 + rows_mul_0(_S545, _S546, _S547, state_0[_S543 + u32(3)].xyz)) * _S548;
    return;
}

fn drift_apply_0( c_19 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  phi_0 : vec3<f32>,  dv_1 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_14 : vec3<f32> = chunks_0[c_19].center_0.xyz - wcom_2;
    var _S549 : u32 = u32(4) * c_19;
    state_0[_S549] = vec4<f32>(state_0[_S549].xyz - (tr_1 + cross(phi_0, r_14)), state_0[_S549].w);
    var _S550 : u32 = _S549 + u32(1);
    state_0[_S550] = vec4<f32>(state_0[_S550].xyz - phi_0, state_0[_S550].w);
    var _S551 : u32 = _S549 + u32(2);
    state_0[_S551] = vec4<f32>(state_0[_S551].xyz - (dv_1 + cross(dw_0, r_14)), state_0[_S551].w);
    var _S552 : u32 = _S549 + u32(3);
    state_0[_S552] = vec4<f32>(state_0[_S552].xyz - dw_0, state_0[_S552].w);
    return;
}

fn drift_rigid_0( isl_13 : ptr<function, Island_std430_0>,  rg_11 : ptr<function, Rigid_0>,  tr_2 : vec3<f32>,  phi_1 : vec3<f32>,  dv_2 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_3 : vec3<f32> = (*isl_13).wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_11).rot_0;
    var _S553 : vec3<f32> = rotate_0((*rg_11).rot_0, tr_2 - cross(phi_1, wcom_3));
    var _S554 : vec3<f32> = (*rg_11).pos_1;
    var _S555 : vec3<f32> = (*rg_11).pos_err_1;
    comp_add_0(&(_S554), &(_S555), _S553);
    (*rg_11).pos_1 = _S554;
    (*rg_11).pos_err_1 = _S555;
    (*rg_11).rot_0 = normalized_0(quat_mul_0((*rg_11).rot_0, from_axis_angle_0(phi_1, length(phi_1))));
    var _S556 : vec3<f32> = rotate_0(rot_2, dv_2 + cross(dw_1, (*isl_13).com_0.xyz - wcom_3));
    var _S557 : vec3<f32> = (*rg_11).vel_1;
    var _S558 : vec3<f32> = (*rg_11).vel_err_1;
    comp_add_0(&(_S557), &(_S558), _S556);
    (*rg_11).vel_1 = _S557;
    (*rg_11).vel_err_1 = _S558;
    (*rg_11).w_4 = (*rg_11).w_4 + rotate_0(rot_2, dw_1);
    return;
}

fn drift_rigid_1( isl_14 : Island_0,  rg_12 : ptr<function, Rigid_0>,  tr_3 : vec3<f32>,  phi_2 : vec3<f32>,  dv_3 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = isl_14.wcom_0.xyz;
    var rot_3 : Quat_0 = (*rg_12).rot_0;
    var _S559 : vec3<f32> = rotate_0((*rg_12).rot_0, tr_3 - cross(phi_2, wcom_4));
    var _S560 : vec3<f32> = (*rg_12).pos_1;
    var _S561 : vec3<f32> = (*rg_12).pos_err_1;
    comp_add_0(&(_S560), &(_S561), _S559);
    (*rg_12).pos_1 = _S560;
    (*rg_12).pos_err_1 = _S561;
    (*rg_12).rot_0 = normalized_0(quat_mul_0((*rg_12).rot_0, from_axis_angle_0(phi_2, length(phi_2))));
    var _S562 : vec3<f32> = rotate_0(rot_3, dv_3 + cross(dw_2, isl_14.com_0.xyz - wcom_4));
    var _S563 : vec3<f32> = (*rg_12).vel_1;
    var _S564 : vec3<f32> = (*rg_12).vel_err_1;
    comp_add_0(&(_S563), &(_S564), _S562);
    (*rg_12).vel_1 = _S563;
    (*rg_12).vel_err_1 = _S564;
    (*rg_12).w_4 = (*rg_12).w_4 + rotate_0(rot_3, dw_2);
    return;
}

fn contact_split_at_0( at_6 : u32)
{
    var previous_1 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S565 : u32;
    if(previous_1 == u32(0))
    {
        _S565 = at_6;
    }
    else
    {
        _S565 = min(previous_1, at_6);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S565;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var woke_0 : bool;
    var tid_5 : u32 = thread_2.x;
    var _S566 : u32 = group_2.x;
    var isl_15 : Island_0;
    isl_15.range_0 = islands_0[_S566].range_0;
    isl_15.info_0 = islands_0[_S566].info_0;
    isl_15.com_0 = islands_0[_S566].com_0;
    isl_15.inertia0_0 = islands_0[_S566].inertia0_0;
    isl_15.inertia1_0 = islands_0[_S566].inertia1_0;
    isl_15.inertia2_0 = islands_0[_S566].inertia2_0;
    isl_15.inv0_0 = islands_0[_S566].inv0_0;
    isl_15.inv1_0 = islands_0[_S566].inv1_0;
    isl_15.inv2_0 = islands_0[_S566].inv2_0;
    isl_15.wcom_0 = islands_0[_S566].wcom_0;
    isl_15.winv0_0 = islands_0[_S566].winv0_0;
    isl_15.winv1_0 = islands_0[_S566].winv1_0;
    isl_15.winv2_0 = islands_0[_S566].winv2_0;
    isl_15.rotation_0 = islands_0[_S566].rotation_0;
    isl_15.position_0 = islands_0[_S566].position_0;
    isl_15.position_err_0 = islands_0[_S566].position_err_0;
    isl_15.velocity_0 = islands_0[_S566].velocity_0;
    isl_15.velocity_err_0 = islands_0[_S566].velocity_err_0;
    isl_15.angular_velocity_0 = islands_0[_S566].angular_velocity_0;
    isl_15.done_0 = islands_0[_S566].done_0;
    isl_15.probes_0 = islands_0[_S566].probes_0;
    isl_15.energy_0 = islands_0[_S566].energy_0;
    var driven_0 : bool = (((isl_15.info_0.x) & (u32(2)))) != u32(0);
    var _S567 : bool = !((((isl_15.info_0.x) & (u32(1)))) != u32(0));
    var _S568 : bool;
    if(_S567)
    {
        _S568 = !driven_0;
    }
    else
    {
        _S568 = false;
    }
    var contact_island_0 : bool = (((isl_15.info_0.x) & (u32(4)))) != u32(0);
    var _S569 : bool = (((isl_15.info_0.x) & (u32(16)))) != u32(0);
    var _S570 : bool = tid_5 == u32(0);
    var settled_0 : bool;
    var run_0 : u32;
    if(_S570)
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
    var _S571 : f32 = params_0.dt_0;
    var _S572 : bool = (params_0.fracture_0) != u32(0);
    var _S573 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_13 : Rigid_0 = rigid_of_1(isl_15);
    var work_5 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    settled_0 = _S569;
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
        var _S574 : bool;
        var settled_1 : bool;
        if((((isl_15.info_0.x) & (u32(32)))) != u32(0))
        {
            if(_S570)
            {
                _S574 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
            }
            else
            {
                _S574 = false;
            }
            if(_S574)
            {
                record_probes_0(isl_15, rg_13, k_21);
            }
            var _S575 : u32 = s_7 + u32(1);
            settled_1 = settled_0;
            done_1 = _S575;
            woke_0 = woke_1;
            var _S576 : u32 = s_7 + u32(1);
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S576;
            continue;
        }
        var i_10 : u32;
        if(settled_0)
        {
            var _S577 : vec3<f32> = vec3<f32>(0.0f);
            var norm_0 : vec3<f32> = _S577;
            var unused0_0 : vec3<f32> = _S577;
            i_10 = isl_15.range_0.x + tid_5;
            loop
            {
                if(i_10 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S578 : f32 = settled_chunk_load_0(i_10, rg_13.rot_0, k_21, _S571, contact_island_0);
                norm_0[i32(0)] = norm_0[i32(0)] + _S578;
                i_10 = i_10 + u32(256);
            }
            group_sum3_0(tid_5, &(norm_0), &(unused0_0));
            if((params_0.solve_mode_0) == u32(1))
            {
                _S574 = (abs(norm_0.x - isl_15.energy_0.z)) > (isl_15.energy_0.w);
            }
            else
            {
                _S574 = false;
            }
            if(_S574)
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
        if(_S567)
        {
            var _S579 : vec3<f32> = vec3<f32>(0.0f);
            var f_18 : vec3<f32> = _S579;
            var t_14 : vec3<f32> = _S579;
            i_10 = isl_15.range_0.x + tid_5;
            loop
            {
                if(i_10 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                net_load_1(i_10, isl_15, rg_13, k_21, _S571, contact_island_0, &(f_18), &(t_14));
                i_10 = i_10 + u32(256);
            }
            group_sum3_0(tid_5, &(f_18), &(t_14));
            rigid_acceleration_1(isl_15, &(rg_13), f_18, t_14);
        }
        if(settled_1)
        {
            if(_S568)
            {
                integrate_rigid_1(isl_15, &(rg_13), _S571);
            }
            if(_S570)
            {
                _S574 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
            }
            else
            {
                _S574 = false;
            }
            if(_S574)
            {
                record_probes_0(isl_15, rg_13, k_21);
            }
            done_1 = s_7 + u32(1);
            var _S576 : u32 = s_7 + u32(1);
            settled_0 = settled_1;
            woke_1 = woke_0;
            s_7 = _S576;
            continue;
        }
        i_10 = isl_15.range_0.z + tid_5;
        loop
        {
            if(i_10 < (isl_15.range_0.w))
            {
            }
            else
            {
                break;
            }
            var _S580 : bool = bond_update_0(i_10, _S571, _S572, abs_step_1);
            if(_S580)
            {
                g_halt_0 = u32(1);
            }
            i_10 = i_10 + u32(256);
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
            chunk_update_1(c_20, isl_15, rg_13, _S571, _S573, k_21, contact_island_0, &(work_5), &(work_err_2));
            c_20 = c_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S568)
        {
            integrate_rigid_1(isl_15, &(rg_13), _S571);
        }
        if(_S567)
        {
            var _S581 : vec3<f32> = isl_15.wcom_0.xyz;
            var _S582 : vec3<f32> = vec3<f32>(0.0f);
            var tu_1 : vec3<f32> = _S582;
            var pv_1 : vec3<f32> = _S582;
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
            var lu_1 : vec3<f32> = _S582;
            var lv_1 : vec3<f32> = _S582;
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
                drift_angular_0(c_22, _S581, tr_4, dv_4, &(lu_1), &(lv_1));
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
                drift_apply_0(c_23, _S581, tr_4, phi_3, dv_4, dw_3);
                c_23 = c_23 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_15, &(rg_13), tr_4, phi_3, dv_4, dw_3);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S570)
        {
            _S574 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
        }
        else
        {
            _S574 = false;
        }
        if(_S574)
        {
            record_probes_0(isl_15, rg_13, k_21);
        }
        var _S583 : u32 = s_7 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S583;
            break;
        }
        done_1 = _S583;
        var _S576 : u32 = s_7 + u32(1);
        settled_0 = settled_1;
        woke_1 = woke_0;
        s_7 = _S576;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_5, work_err_2, 0.0f);
    var unused_2 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_5, &(wsum_0), &(unused_2));
    if(_S570)
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
            _S568 = contact_island_0;
        }
        else
        {
            _S568 = false;
        }
        if(_S568)
        {
            contact_split_at_0(isl_15.info_0.w + done_1);
        }
        var _S584 : f32 = wsum_0.x;
        var _S585 : f32 = isl_15.energy_0[i32(0)];
        var _S586 : f32 = isl_15.energy_0[i32(1)];
        comp_add1_2(&(_S585), &(_S586), _S584);
        isl_15.energy_0[i32(0)] = _S585;
        isl_15.energy_0[i32(1)] = _S586 + wsum_0.y;
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
        islands_0[_S566].range_0 = isl_15.range_0;
        islands_0[_S566].info_0 = isl_15.info_0;
        islands_0[_S566].com_0 = isl_15.com_0;
        islands_0[_S566].inertia0_0 = isl_15.inertia0_0;
        islands_0[_S566].inertia1_0 = isl_15.inertia1_0;
        islands_0[_S566].inertia2_0 = isl_15.inertia2_0;
        islands_0[_S566].inv0_0 = isl_15.inv0_0;
        islands_0[_S566].inv1_0 = isl_15.inv1_0;
        islands_0[_S566].inv2_0 = isl_15.inv2_0;
        islands_0[_S566].wcom_0 = isl_15.wcom_0;
        islands_0[_S566].winv0_0 = isl_15.winv0_0;
        islands_0[_S566].winv1_0 = isl_15.winv1_0;
        islands_0[_S566].winv2_0 = isl_15.winv2_0;
        islands_0[_S566].rotation_0 = isl_15.rotation_0;
        islands_0[_S566].position_0 = isl_15.position_0;
        islands_0[_S566].position_err_0 = isl_15.position_err_0;
        islands_0[_S566].velocity_0 = isl_15.velocity_0;
        islands_0[_S566].velocity_err_0 = isl_15.velocity_err_0;
        islands_0[_S566].angular_velocity_0 = isl_15.angular_velocity_0;
        islands_0[_S566].done_0 = isl_15.done_0;
        islands_0[_S566].probes_0 = isl_15.probes_0;
        islands_0[_S566].energy_0 = isl_15.energy_0;
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
    var _S587 : u32 = table_0 + u32(4) * g_4;
    w_11.island_0 = index_0[_S587];
    w_11.begin_1 = index_0[_S587 + u32(1)];
    w_11.end_0 = index_0[_S587 + u32(2)];
    w_11.first_1 = index_0[_S587 + u32(3)];
    return w_11;
}

fn wide_runs_0( isl_16 : ptr<function, Island_std430_0>) -> bool
{
    var _S588 : vec4<u32> = (*isl_16).info_0;
    var _S589 : bool;
    if(((((*isl_16).info_0.z) & (u32(1)))) != u32(0))
    {
        _S589 = true;
    }
    else
    {
        _S589 = (_S588.y) == u32(0);
    }
    if(_S589)
    {
        return false;
    }
    if((((_S588.x) & (u32(4)))) == u32(0))
    {
        _S589 = true;
    }
    else
    {
        var _S590 : bool = contact_stopped_0(&((*isl_16)));
        _S589 = !_S590;
    }
    return _S589;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_6 : u32,  isl_17 : ptr<function, Island_std430_0>) -> bool
{
    if(tid_6 == u32(0))
    {
        var _S591 : bool = wide_runs_0(&((*isl_17)));
        var _S592 : i32;
        if(_S591)
        {
            _S592 = i32(1);
        }
        else
        {
            _S592 = i32(0);
        }
        g_wide_run_0 = u32(_S592);
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

fn contact_stopped_2( _S593 : u32) -> bool
{
    var _S594 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S595 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S595 = true;
    }
    else
    {
        var _S596 : u32 = _S594.y;
        if(_S596 != u32(0))
        {
            _S595 = _S596 <= (islands_0[_S593].info_0.w);
        }
        else
        {
            _S595 = false;
        }
    }
    return _S595;
}

fn wide_runs_1( _S597 : u32) -> bool
{
    var _S598 : vec4<u32> = islands_0[_S597].info_0;
    var _S599 : bool;
    if((((islands_0[_S597].info_0.z) & (u32(1)))) != u32(0))
    {
        _S599 = true;
    }
    else
    {
        _S599 = (_S598.y) == u32(0);
    }
    if(_S599)
    {
        return false;
    }
    if((((_S598.x) & (u32(4)))) == u32(0))
    {
        _S599 = true;
    }
    else
    {
        _S599 = !contact_stopped_2(_S597);
    }
    return _S599;
}

fn wide_enter_1( _S600 : u32,  _S601 : u32) -> bool
{
    if(_S600 == u32(0))
    {
        var _S602 : i32;
        if(wide_runs_1(_S601))
        {
            _S602 = i32(1);
        }
        else
        {
            _S602 = i32(0);
        }
        g_wide_run_0 = u32(_S602);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_wake(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_7 : u32 = thread_3.x;
    var _S603 : u32 = group_3.x;
    var wg_0 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S603);
    if(_S603 != (wg_0.first_1))
    {
        return;
    }
    var _S604 : Island_std430_0 = islands_0[wg_0.island_0];
    var _S605 : vec4<u32> = _S604.info_0;
    var _S606 : u32 = _S604.info_0.x;
    var _S607 : bool;
    if(((_S606 & (u32(16)))) == u32(0))
    {
        _S607 = true;
    }
    else
    {
        var _S608 : bool = wide_enter_1(tid_7, wg_0.island_0);
        _S607 = !_S608;
    }
    if(_S607)
    {
        return;
    }
    var _S609 : Quat_0 = quat_of_0(_S604.rotation_0);
    var _S610 : bool = ((_S606 & (u32(4)))) != u32(0);
    var _S611 : vec3<f32> = vec3<f32>(0.0f);
    var norm_1 : vec3<f32> = _S611;
    var unused_3 : vec3<f32> = _S611;
    var _S612 : vec4<u32> = _S604.range_0;
    var c_24 : u32 = _S604.range_0.x + tid_7;
    loop
    {
        if(c_24 < (_S612.y))
        {
        }
        else
        {
            break;
        }
        var _S613 : u32 = wide_step_0(&(_S604));
        var _S614 : f32 = settled_chunk_load_0(c_24, _S609, _S613, params_0.dt_0, _S610);
        norm_1[i32(0)] = norm_1[i32(0)] + _S614;
        c_24 = c_24 + u32(256);
    }
    group_sum3_0(tid_7, &(norm_1), &(unused_3));
    if(tid_7 == u32(0))
    {
        _S607 = (params_0.solve_mode_0) == u32(1);
    }
    else
    {
        _S607 = false;
    }
    if(_S607)
    {
        _S607 = (abs(norm_1.x - _S604.energy_0.z)) > (_S604.energy_0.w);
    }
    else
    {
        _S607 = false;
    }
    if(_S607)
    {
        islands_0[wg_0.island_0].info_0[i32(0)] = (_S606 & (u32(4294967279)));
        islands_0[wg_0.island_0].info_0[i32(2)] = ((_S605.z) | (u32(4)));
    }
    return;
}

fn wide_store_0( slot_2 : u32,  p_16 : u32,  a_17 : vec3<f32>,  b_40 : vec3<f32>)
{
    var _S615 : u32 = u32(8) * slot_2;
    scratch_0[params_0.wide_base_0 + _S615 + p_16] = vec4<f32>(a_17, 0.0f);
    scratch_0[params_0.wide_base_0 + _S615 + p_16 + u32(1)] = vec4<f32>(b_40, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_8 : u32 = thread_4.x;
    var _S616 : u32 = group_4.x;
    var bond_group_0 : bool = _S616 < (params_0.wide_bond_groups_0);
    var wg_1 : WideGroup_0;
    if(bond_group_0)
    {
        wg_1 = wide_group_0(params_0.wide_bond_table_0, _S616);
    }
    else
    {
        wg_1 = wide_group_0(params_0.wide_chunk_table_0, _S616 - params_0.wide_bond_groups_0);
    }
    var _S617 : WideGroup_0 = wg_1;
    var _S618 : Island_std430_0 = islands_0[wg_1.island_0];
    var _S619 : bool = wide_enter_1(tid_8, wg_1.island_0);
    if(!_S619)
    {
        return;
    }
    var _S620 : u32 = wide_step_0(&(_S618));
    if(bond_group_0)
    {
        var _S621 : vec4<u32> = _S618.info_0;
        if((((_S618.info_0.x) & (u32(16)))) != u32(0))
        {
            return;
        }
        var i_11 : u32 = wg_1.begin_1 + tid_8;
        var _S622 : bool;
        if(i_11 < (wg_1.end_0))
        {
            var _S623 : bool = bond_update_0(i_11, params_0.dt_0, (params_0.fracture_0) != u32(0), _S621.w + u32(1));
            _S622 = _S623;
        }
        else
        {
            _S622 = false;
        }
        if(_S622)
        {
            islands_0[_S617.island_0].info_0[i32(2)] = ((_S621.z) | (u32(2)));
        }
        return;
    }
    var _S624 : u32 = _S618.info_0.x;
    if(((_S624 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S625 : vec3<f32> = vec3<f32>(0.0f);
    var f_19 : vec3<f32> = _S625;
    var t_15 : vec3<f32> = _S625;
    var c_25 : u32 = wg_1.begin_1 + tid_8;
    if(c_25 < (wg_1.end_0))
    {
        var _S626 : Rigid_0 = rigid_of_0(&(_S618));
        net_load_0(c_25, &(_S618), _S626, _S620, params_0.dt_0, ((_S624 & (u32(4)))) != u32(0), &(f_19), &(t_15));
    }
    group_sum3_0(tid_8, &(f_19), &(t_15));
    if(tid_8 == u32(0))
    {
        wide_store_0(_S616 - params_0.wide_bond_groups_0, u32(0), f_19, t_15);
    }
    return;
}

fn wide_partials_0( tid_9 : u32,  first_2 : u32,  count_5 : u32,  p_17 : u32,  a_18 : ptr<function, vec3<f32>>,  b_41 : ptr<function, vec3<f32>>)
{
    var _S627 : vec4<f32> = vec4<f32>(0.0f);
    var x_10 : vec4<f32> = _S627;
    var y_2 : vec4<f32> = _S627;
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
        var _S628 : u32 = u32(8) * (first_2 + s_8);
        x_10 = x_10 + scratch_0[params_0.wide_base_0 + _S628 + p_17];
        y_2 = y_2 + scratch_0[params_0.wide_base_0 + _S628 + p_17 + u32(1)];
        s_8 = s_8 + u32(256);
    }
    group_sum2_0(tid_9, &(x_10), &(y_2));
    (*a_18) = x_10.xyz;
    (*b_41) = y_2.xyz;
    return;
}

fn wide_rigid_frame_0( tid_10 : u32,  isl_20 : ptr<function, Island_std430_0>,  wg_2 : WideGroup_0) -> Rigid_0
{
    var _S629 : Rigid_0 = rigid_of_0(&((*isl_20)));
    var rg_14 : Rigid_0 = _S629;
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
    var _S630 : u32 = group_5.x;
    var wg_3 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S630);
    var _S631 : Island_std430_0 = islands_0[wg_3.island_0];
    var _S632 : bool = wide_enter_1(tid_11, wg_3.island_0);
    if(!_S632)
    {
        return;
    }
    var _S633 : u32 = _S631.info_0.x;
    var anchored_0 : bool = ((_S633 & (u32(1)))) != u32(0);
    if(((_S633 & (u32(16)))) != u32(0))
    {
        if(tid_11 == u32(0))
        {
            scratch_0[params_0.wide_base_0 + u32(8) * _S630 + u32(6)] = vec4<f32>(0.0f);
        }
        return;
    }
    var _S634 : Rigid_0 = wide_rigid_frame_0(tid_11, &(_S631), wg_3);
    var work_6 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S635 : vec3<f32> = vec3<f32>(0.0f);
    var tu_2 : vec3<f32> = _S635;
    var pv_2 : vec3<f32> = _S635;
    var c_26 : u32 = wg_3.begin_1 + tid_11;
    if(c_26 < (wg_3.end_0))
    {
        var _S636 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S637 : u32 = wide_step_0(&(_S631));
        chunk_update_0(c_26, &(_S631), _S634, params_0.dt_0, _S636, _S637, ((_S633 & (u32(4)))) != u32(0), &(work_6), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_26, &(tu_2), &(pv_2));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_6, work_err_3, 0.0f);
    var unused_4 : vec3<f32> = _S635;
    group_sum3_0(tid_11, &(wsum_1), &(unused_4));
    var _S638 : bool = !anchored_0;
    if(_S638)
    {
        group_sum3_0(tid_11, &(tu_2), &(pv_2));
    }
    if(tid_11 == u32(0))
    {
        scratch_0[params_0.wide_base_0 + u32(8) * _S630 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S638)
        {
            wide_store_0(_S630, u32(2), tu_2, pv_2);
        }
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var tid_12 : u32 = thread_6.x;
    var _S639 : u32 = group_6.x;
    var wg_4 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S639);
    var isl_21 : Island_std430_0 = islands_0[wg_4.island_0];
    var _S640 : bool;
    if((((islands_0[wg_4.island_0].info_0.x) & (u32(17)))) != u32(0))
    {
        _S640 = true;
    }
    else
    {
        var _S641 : bool = wide_enter_1(tid_12, wg_4.island_0);
        _S640 = !_S641;
    }
    if(_S640)
    {
        return;
    }
    var tu_3 : vec3<f32>;
    var pv_3 : vec3<f32>;
    wide_partials_0(tid_12, wg_4.first_1, isl_21.done_0.z, u32(2), &(tu_3), &(pv_3));
    var _S642 : vec3<f32> = vec3<f32>(isl_21.wcom_0.w);
    var tr_5 : vec3<f32> = tu_3 / _S642;
    var dv_5 : vec3<f32> = pv_3 / _S642;
    var _S643 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S643;
    var lv_2 : vec3<f32> = _S643;
    var c_27 : u32 = wg_4.begin_1 + tid_12;
    if(c_27 < (wg_4.end_0))
    {
        drift_angular_0(c_27, isl_21.wcom_0.xyz, tr_5, dv_5, &(lu_2), &(lv_2));
    }
    group_sum3_0(tid_12, &(lu_2), &(lv_2));
    if(tid_12 == u32(0))
    {
        wide_store_0(_S639, u32(4), lu_2, lv_2);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    var tid_13 : u32 = thread_7.x;
    var _S644 : u32 = group_7.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S644);
    var _S645 : Island_std430_0 = islands_0[wg_5.island_0];
    var _S646 : u32 = _S645.info_0.x;
    var _S647 : bool;
    if(((_S646 & (u32(1)))) != u32(0))
    {
        _S647 = true;
    }
    else
    {
        var _S648 : bool = wide_enter_1(tid_13, wg_5.island_0);
        _S647 = !_S648;
    }
    if(_S647)
    {
        return;
    }
    if(((_S646 & (u32(16)))) != u32(0))
    {
        if(_S644 != (wg_5.first_1))
        {
            return;
        }
        var _S649 : Rigid_0 = wide_rigid_frame_0(tid_13, &(_S645), wg_5);
        var rs_0 : Rigid_0 = _S649;
        if(tid_13 != u32(0))
        {
            _S647 = true;
        }
        else
        {
            _S647 = ((_S646 & (u32(2)))) != u32(0);
        }
        if(_S647)
        {
            return;
        }
        integrate_rigid_0(&(_S645), &(rs_0), params_0.dt_0);
        islands_0[wg_5.island_0].rotation_0 = quat_vec_0(rs_0.rot_0);
        islands_0[wg_5.island_0].position_0 = vec4<f32>(rs_0.pos_1, 0.0f);
        islands_0[wg_5.island_0].position_err_0 = vec4<f32>(rs_0.pos_err_1, 0.0f);
        islands_0[wg_5.island_0].velocity_0 = vec4<f32>(rs_0.vel_1, 0.0f);
        islands_0[wg_5.island_0].velocity_err_0 = vec4<f32>(rs_0.vel_err_1, 0.0f);
        islands_0[wg_5.island_0].angular_velocity_0 = vec4<f32>(rs_0.w_4, 0.0f);
        return;
    }
    var _S650 : u32 = _S645.done_0.z;
    var tu_4 : vec3<f32>;
    var pv_4 : vec3<f32>;
    wide_partials_0(tid_13, wg_5.first_1, _S650, u32(2), &(tu_4), &(pv_4));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_0(tid_13, wg_5.first_1, _S650, u32(4), &(lu_3), &(lv_3));
    var _S651 : vec4<f32> = _S645.wcom_0;
    var _S652 : vec3<f32> = vec3<f32>(_S645.wcom_0.w);
    var tr_6 : vec3<f32> = tu_4 / _S652;
    var dv_6 : vec3<f32> = pv_4 / _S652;
    var phi_4 : vec3<f32> = rows_mul_0(_S645.winv0_0, _S645.winv1_0, _S645.winv2_0, lu_3);
    var dw_4 : vec3<f32> = rows_mul_0(_S645.winv0_0, _S645.winv1_0, _S645.winv2_0, lv_3);
    var c_28 : u32 = wg_5.begin_1 + tid_13;
    if(c_28 < (wg_5.end_0))
    {
        drift_apply_0(c_28, _S651.xyz, tr_6, phi_4, dv_6, dw_4);
    }
    if(_S644 != (wg_5.first_1))
    {
        return;
    }
    var _S653 : Rigid_0 = wide_rigid_frame_0(tid_13, &(_S645), wg_5);
    var rg_15 : Rigid_0 = _S653;
    if(tid_13 != u32(0))
    {
        return;
    }
    if(!(((_S646 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S645), &(rg_15), params_0.dt_0);
        drift_rigid_0(&(_S645), &(rg_15), tr_6, phi_4, dv_6, dw_4);
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
    var _S654 : u32 = group_8.x;
    var wg_6 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S654);
    if(_S654 != (wg_6.first_1))
    {
        return;
    }
    var _S655 : Island_std430_0 = islands_0[wg_6.island_0];
    var isl_22 : Island_0;
    isl_22.range_0 = _S655.range_0;
    isl_22.info_0 = _S655.info_0;
    isl_22.com_0 = _S655.com_0;
    isl_22.inertia0_0 = _S655.inertia0_0;
    isl_22.inertia1_0 = _S655.inertia1_0;
    isl_22.inertia2_0 = _S655.inertia2_0;
    isl_22.inv0_0 = _S655.inv0_0;
    isl_22.inv1_0 = _S655.inv1_0;
    isl_22.inv2_0 = _S655.inv2_0;
    isl_22.wcom_0 = _S655.wcom_0;
    isl_22.winv0_0 = _S655.winv0_0;
    isl_22.winv1_0 = _S655.winv1_0;
    isl_22.winv2_0 = _S655.winv2_0;
    isl_22.rotation_0 = _S655.rotation_0;
    isl_22.position_0 = _S655.position_0;
    isl_22.position_err_0 = _S655.position_err_0;
    isl_22.velocity_0 = _S655.velocity_0;
    isl_22.velocity_err_0 = _S655.velocity_err_0;
    isl_22.angular_velocity_0 = _S655.angular_velocity_0;
    isl_22.done_0 = _S655.done_0;
    isl_22.probes_0 = _S655.probes_0;
    isl_22.energy_0 = _S655.energy_0;
    var _S656 : bool = wide_enter_0(tid_14, &(_S655));
    if(!_S656)
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
    var _S657 : bool;
    if(halt_0)
    {
        _S657 = (((isl_22.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        _S657 = false;
    }
    if(_S657)
    {
        contact_split_at_0(isl_22.info_0.w + u32(1));
    }
    var _S658 : f32 = work_7.x;
    var _S659 : f32 = isl_22.energy_0[i32(0)];
    var _S660 : f32 = isl_22.energy_0[i32(1)];
    comp_add1_2(&(_S659), &(_S660), _S658);
    isl_22.energy_0[i32(0)] = _S659;
    isl_22.energy_0[i32(1)] = _S660 + work_7.y;
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
    var _S661 : u32;
    var _S662 : vec3<f32> = vec3<f32>(0.0f);
    var net_f_0 : vec3<f32> = _S662;
    var net_m_0 : vec3<f32> = _S662;
    var _S663 : vec4<u32> = (*isl_23).range_0;
    var _S664 : u32 = (*isl_23).range_0.x + tid_15;
    var c_30 : u32 = _S664;
    loop
    {
        var _S665 : u32 = _S663.y;
        _S661 = _S665;
        if(c_30 < _S665)
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
    var _S666 : vec4<f32> = (*isl_23).com_0;
    var _S667 : vec3<f32> = net_f_0 / vec3<f32>((*isl_23).com_0.w);
    var _S668 : vec3<f32> = rows_mul_0((*isl_23).inv0_0, (*isl_23).inv1_0, (*isl_23).inv2_0, net_m_0);
    c_30 = _S664;
    loop
    {
        if(c_30 < _S661)
        {
        }
        else
        {
            break;
        }
        var _S669 : u32 = sv_0(c_30, slot_4);
        scratch_0[_S669] = vec4<f32>(scratch_0[_S669].xyz - (_S667 + cross(_S668, chunks_0[c_30].center_0.xyz - _S666.xyz)) * vec3<f32>(chunks_0[c_30].center_0.w), 0.0f);
        var _S670 : u32 = sv_0(c_30, slot_4 + u32(1));
        scratch_0[_S670] = vec4<f32>(scratch_0[_S670].xyz - rows_mul_0(chunks_0[c_30].inertia0_1, chunks_0[c_30].inertia1_1, chunks_0[c_30].inertia2_1, _S668), 0.0f);
        c_30 = c_30 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn island_dot_0( tid_16 : u32,  c0_0 : u32,  c1_0 : u32,  sa_0 : u32,  sb_0 : u32) -> f32
{
    var _S671 : vec4<f32> = vec4<f32>(0.0f);
    var acc_0 : vec4<f32> = _S671;
    var unused_6 : vec4<f32> = _S671;
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
    group_sum2_1(tid_16, &(acc_0), &(unused_6));
    return acc_0.x;
}

fn static_kinematics_0( _S672 : u32,  _S673 : ptr<function, vec3<f32>>,  _S674 : ptr<function, vec3<f32>>)
{
    var ca_1 : u32 = bonds_0[_S672].law_0.ids_0.y;
    var cb_4 : u32 = bonds_0[_S672].law_0.ids_0.z;
    var _S675 : u32 = u32(4) * cb_4;
    var _S676 : u32 = u32(4) * ca_1;
    var _S677 : u32 = _S675 + u32(1);
    var _S678 : u32 = _S676 + u32(1);
    var _S679 : u32 = sv_0(cb_4, u32(22));
    var _S680 : u32 = sv_0(ca_1, u32(22));
    var dth_0 : vec3<f32> = state_0[_S677].xyz - state_0[_S678].xyz + (scratch_0[_S679].xyz - scratch_0[_S680].xyz);
    (*_S673) = to_local_0(_S672, state_0[_S675].xyz - state_0[_S676].xyz + (scratch_0[sv_0(cb_4, u32(21))].xyz - scratch_0[sv_0(ca_1, u32(21))].xyz) + (cross(state_0[_S677].xyz + scratch_0[_S679].xyz, bonds_0[_S672].rb_0.xyz) - cross(state_0[_S678].xyz + scratch_0[_S680].xyz, bonds_0[_S672].ra_0.xyz)));
    (*_S674) = to_local_0(_S672, dth_0);
    return;
}

fn static_response_0( i_12 : u32) -> JointResponse_0
{
    var d_lin_7 : vec3<f32>;
    var d_ang_5 : vec3<f32>;
    static_kinematics_0(i_12, &(d_lin_7), &(d_ang_5));
    var _S681 : JointBond_std430_0 = bonds_0[i_12].law_0;
    var _S682 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S681.ids_0.x];
    var _S683 : JointState_std430_0 = bond_dyn_0[i_12].js_0;
    var _S684 : JointResponse_0 = joint_evaluate_2(&(_S682), &(_S681), &(_S683), d_lin_7, d_ang_5, 0.0f, false);
    return _S684;
}

fn gather_loads_0( c_32 : u32,  fi_3 : ptr<function, vec3<f32>>,  mi_6 : ptr<function, vec3<f32>>)
{
    var _S685 : vec3<f32> = vec3<f32>(0.0f);
    (*fi_3) = _S685;
    (*mi_6) = _S685;
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
            var _S686 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) + scratch_0[_S686].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S686 + u32(1)].xyz;
        }
        else
        {
            var _S687 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) - scratch_0[_S687].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S687 + u32(2)].xyz;
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
        var _S688 : u32 = u32(3) * ((entry_5 >> (u32(1))));
        var f_21 : vec3<f32> = scratch_0[_S688].xyz;
        var t_17 : vec3<f32>;
        if(((entry_5 & (u32(1)))) == u32(0))
        {
            t_17 = scratch_0[_S688 + u32(1)].xyz;
        }
        else
        {
            t_17 = scratch_0[_S688 + u32(2)].xyz;
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
    var _S689 : u32;
    if(support_2 == u32(1))
    {
        _S689 = u32(63);
    }
    else
    {
        if(support_2 == u32(2))
        {
            _S689 = u32(7);
        }
        else
        {
            _S689 = u32(0);
        }
    }
    return _S689;
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

fn statics_bond_slot_0( i_13 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * i_13;
}

fn store_inverse_0( c_35 : u32,  a_19 : array<f32, i32(36)>)
{
    var j_7 : u32;
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
    var i_14 : u32 = u32(0);
    loop
    {
        var _S690 : bool;
        if(i_14 < u32(6))
        {
            _S690 = spd_0;
        }
        else
        {
            _S690 = false;
        }
        if(_S690)
        {
        }
        else
        {
            break;
        }
        j_7 = u32(0);
        loop
        {
            if(j_7 <= i_14)
            {
            }
            else
            {
                break;
            }
            var _S691 : u32 = i_14 * u32(6);
            var _S692 : u32 = _S691 + j_7;
            k_23 = u32(0);
            sum_4 = a_19[_S692];
            loop
            {
                if(k_23 < j_7)
                {
                }
                else
                {
                    break;
                }
                var sum_5 : f32 = sum_4 - l_4[_S691 + k_23] * l_4[j_7 * u32(6) + k_23];
                k_23 = k_23 + u32(1);
                sum_4 = sum_5;
            }
            if(i_14 == j_7)
            {
                if(sum_4 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_4[_S691 + i_14] = sqrt(sum_4);
            }
            else
            {
                l_4[_S692] = sum_4 / l_4[j_7 * u32(6) + j_7];
            }
            j_7 = j_7 + u32(1);
        }
        i_14 = i_14 + u32(1);
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
            var _S693 : u32 = k_23 * u32(6) + k_23;
            if((a_19[_S693]) > 0.0f)
            {
                sum_4 = 1.0f / a_19[_S693];
            }
            else
            {
                sum_4 = 0.0f;
            }
            inv_0[_S693] = sum_4;
            k_23 = k_23 + u32(1);
        }
    }
    else
    {
        j_7 = u32(0);
        loop
        {
            if(j_7 < u32(6))
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
            i_14 = u32(0);
            loop
            {
                if(i_14 < u32(6))
                {
                }
                else
                {
                    break;
                }
                if(i_14 == j_7)
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
                    if(k_23 < i_14)
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_10 : f32 = s_9 - l_4[i_14 * u32(6) + k_23] * y_3[k_23];
                    k_23 = k_23 + u32(1);
                    s_9 = s_10;
                }
                y_3[i_14] = s_9 / l_4[i_14 * u32(6) + i_14];
                i_14 = i_14 + u32(1);
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
                var i_15 : u32 = u32(5) - ii_2;
                k_23 = i_15 + u32(1);
                sum_4 = y_3[i_15];
                loop
                {
                    if(k_23 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_11 : f32 = sum_4 - l_4[k_23 * u32(6) + i_15] * x_11[k_23];
                    k_23 = k_23 + u32(1);
                    sum_4 = s_11;
                }
                x_11[i_15] = sum_4 / l_4[i_15 * u32(6) + i_15];
                ii_2 = ii_2 + u32(1);
            }
            var i_16 : u32 = u32(0);
            loop
            {
                if(i_16 < u32(6))
                {
                }
                else
                {
                    break;
                }
                inv_0[i_16 * u32(6) + j_7] = x_11[i_16];
                i_16 = i_16 + u32(1);
            }
            j_7 = j_7 + u32(1);
        }
    }
    j_7 = u32(0);
    loop
    {
        if(j_7 < u32(9))
        {
        }
        else
        {
            break;
        }
        var _S694 : u32 = u32(4) * j_7;
        scratch_0[sv_0(c_35, u32(12) + j_7)] = vec4<f32>(inv_0[_S694], inv_0[_S694 + u32(1)], inv_0[_S694 + u32(2)], inv_0[_S694 + u32(3)]);
        j_7 = j_7 + u32(1);
    }
    return;
}

fn assemble_block_0( c_36 : u32)
{
    var p_18 : u32;
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
        var i_17 : u32 = (entry_6 >> (u32(1)));
        var _S695 : bool = ((entry_6 & (u32(1)))) != u32(0);
        var _S696 : u32 = statics_bond_slot_0(i_17);
        var _S697 : vec4<f32> = scratch_0[_S696];
        var _S698 : vec4<f32> = scratch_0[_S696 + u32(1)];
        p_18 = u32(0);
        loop
        {
            if(p_18 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S699 : u32 = p_18 % u32(3);
            var t_18 : vec3<f32>;
            if(_S699 == u32(0))
            {
                t_18 = bonds_0[i_17].t1_0.xyz;
            }
            else
            {
                if(_S699 == u32(1))
                {
                    t_18 = bonds_0[i_17].t2_0.xyz;
                }
                else
                {
                    t_18 = bonds_0[i_17].normal_0.xyz;
                }
            }
            var _S700 : bool = p_18 < u32(3);
            var row_u_0 : vec3<f32>;
            var row_t_0 : vec3<f32>;
            if(_S700)
            {
                if(_S695)
                {
                    row_u_0 = t_18;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_18);
                }
                if(_S695)
                {
                    row_t_0 = cross(bonds_0[i_17].rb_0.xyz, t_18);
                }
                else
                {
                    row_t_0 = (vec3<f32>(0) - cross(bonds_0[i_17].ra_0.xyz, t_18));
                }
            }
            else
            {
                var _S701 : vec3<f32> = vec3<f32>(0.0f);
                if(_S695)
                {
                    row_u_0 = t_18;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_18);
                }
                var _S702 : vec3<f32> = row_u_0;
                row_u_0 = _S701;
                row_t_0 = _S702;
            }
            var kp_0 : f32;
            if(_S700)
            {
                kp_0 = _S697[p_18];
            }
            else
            {
                kp_0 = _S698[p_18 - u32(3)];
            }
            if(kp_0 == 0.0f)
            {
                p_18 = p_18 + u32(1);
                continue;
            }
            var _S703 : array<f32, i32(6)> = array<f32, i32(6)>( row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z );
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
                    a_20[r_15 * u32(6) + q_17] = a_20[r_15 * u32(6) + q_17] + kp_0 * _S703[r_15] * _S703[q_17];
                    q_17 = q_17 + u32(1);
                }
                r_15 = r_15 + u32(1);
            }
            p_18 = p_18 + u32(1);
        }
        e_7 = e_7 + u32(1);
    }
    var _S704 : u32 = fixed_mask_0(c_36);
    p_18 = u32(0);
    loop
    {
        if(p_18 < u32(6))
        {
        }
        else
        {
            break;
        }
        if(((_S704 & (((u32(1) << (p_18)))))) != u32(0))
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
                a_20[p_18 * u32(6) + r_15] = 0.0f;
                a_20[r_15 * u32(6) + p_18] = 0.0f;
                r_15 = r_15 + u32(1);
            }
            a_20[p_18 * u32(6) + p_18] = 1.0f;
        }
        p_18 = p_18 + u32(1);
    }
    p_18 = u32(0);
    loop
    {
        if(p_18 < u32(6))
        {
        }
        else
        {
            break;
        }
        if((a_20[p_18 * u32(6) + p_18]) == 0.0f)
        {
            a_20[p_18 * u32(6) + p_18] = 1.0f;
        }
        p_18 = p_18 + u32(1);
    }
    store_inverse_0(c_36, a_20);
    return;
}

fn block_get_0( c_37 : u32,  i_18 : u32,  j_8 : u32) -> f32
{
    var k_25 : u32 = i_18 * u32(6) + j_8;
    return scratch_0[sv_0(c_37, u32(12) + k_25 / u32(4))][k_25 % u32(4)];
}

fn precondition_0( c_38 : u32)
{
    var _S705 : array<f32, i32(6)> = array<f32, i32(6)>( scratch_0[sv_0(c_38, u32(4))].x, scratch_0[sv_0(c_38, u32(4))].y, scratch_0[sv_0(c_38, u32(4))].z, scratch_0[sv_0(c_38, u32(5))].x, scratch_0[sv_0(c_38, u32(5))].y, scratch_0[sv_0(c_38, u32(5))].z );
    var z_1 : array<f32, i32(6)>;
    var i_19 : u32 = u32(0);
    loop
    {
        if(i_19 < u32(6))
        {
        }
        else
        {
            break;
        }
        var j_9 : u32 = u32(0);
        var s_12 : f32 = 0.0f;
        loop
        {
            if(j_9 < u32(6))
            {
            }
            else
            {
                break;
            }
            var s_13 : f32 = s_12 + block_get_0(c_38, i_19, j_9) * _S705[j_9];
            j_9 = j_9 + u32(1);
            s_12 = s_13;
        }
        z_1[i_19] = s_12;
        i_19 = i_19 + u32(1);
    }
    scratch_0[sv_0(c_38, u32(6))] = vec4<f32>(z_1[i32(0)], z_1[i32(1)], z_1[i32(2)], 0.0f);
    scratch_0[sv_0(c_38, u32(7))] = vec4<f32>(z_1[i32(3)], z_1[i32(4)], z_1[i32(5)], 0.0f);
    return;
}

fn project_displacement_slot_0( tid_17 : u32,  isl_24 : ptr<function, Island_std430_0>,  slot_5 : u32)
{
    var _S706 : u32;
    var _S707 : vec3<f32> = vec3<f32>(0.0f);
    var p_19 : vec3<f32> = _S707;
    var l_5 : vec3<f32> = _S707;
    var _S708 : vec4<u32> = (*isl_24).range_0;
    var _S709 : u32 = (*isl_24).range_0.x + tid_17;
    var c_39 : u32 = _S709;
    loop
    {
        var _S710 : u32 = _S708.y;
        _S706 = _S710;
        if(c_39 < _S710)
        {
        }
        else
        {
            break;
        }
        var u_6 : vec3<f32> = scratch_0[sv_0(c_39, slot_5)].xyz;
        var th_7 : vec3<f32> = scratch_0[sv_0(c_39, slot_5 + u32(1))].xyz;
        var r_16 : vec3<f32> = chunks_0[c_39].center_0.xyz - (*isl_24).com_0.xyz;
        var _S711 : vec3<f32> = vec3<f32>(chunks_0[c_39].center_0.w);
        p_19 = p_19 + u_6 * _S711;
        l_5 = l_5 + (cross(r_16, u_6) * _S711 + rows_mul_0(chunks_0[c_39].inertia0_1, chunks_0[c_39].inertia1_1, chunks_0[c_39].inertia2_1, th_7));
        c_39 = c_39 + u32(256);
    }
    group_sum3_0(tid_17, &(p_19), &(l_5));
    var _S712 : vec4<f32> = (*isl_24).com_0;
    var _S713 : vec3<f32> = p_19 / vec3<f32>((*isl_24).com_0.w);
    var _S714 : vec3<f32> = rows_mul_0((*isl_24).inv0_0, (*isl_24).inv1_0, (*isl_24).inv2_0, l_5);
    c_39 = _S709;
    loop
    {
        if(c_39 < _S706)
        {
        }
        else
        {
            break;
        }
        var _S715 : u32 = sv_0(c_39, slot_5);
        scratch_0[_S715] = vec4<f32>(scratch_0[_S715].xyz - _S713 - cross(_S714, chunks_0[c_39].center_0.xyz - _S712.xyz), 0.0f);
        var _S716 : u32 = sv_0(c_39, slot_5 + u32(1));
        scratch_0[_S716] = vec4<f32>(scratch_0[_S716].xyz - _S714, 0.0f);
        c_39 = c_39 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn statics_result_slot_0( island_1 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * params_0.statics_bonds_0 + island_1;
}

fn write_bond_loads_0( _S717 : u32,  _S718 : u32,  _S719 : vec3<f32>,  _S720 : vec3<f32>,  _S721 : f32)
{
    var _S722 : vec3<f32> = to_body_0(_S718, _S719);
    var _S723 : vec3<f32> = to_body_0(_S718, _S720);
    var _S724 : u32 = u32(3) * _S717;
    scratch_0[_S724] = vec4<f32>(_S722, _S721);
    scratch_0[_S724 + u32(1)] = vec4<f32>(_S723 + cross(bonds_0[_S718].ra_0.xyz, _S722), 0.0f);
    scratch_0[_S724 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S723) + cross(bonds_0[_S718].rb_0.xyz, (vec3<f32>(0) - _S722)), 0.0f);
    return;
}

fn static_kinematics_1( _S725 : u32,  _S726 : ptr<function, vec3<f32>>,  _S727 : ptr<function, vec3<f32>>)
{
    var ca_2 : u32 = bonds_0[_S725].law_0.ids_0.y;
    var cb_5 : u32 = bonds_0[_S725].law_0.ids_0.z;
    var _S728 : u32 = u32(4) * cb_5;
    var _S729 : u32 = u32(4) * ca_2;
    var _S730 : u32 = _S728 + u32(1);
    var _S731 : u32 = _S729 + u32(1);
    var _S732 : u32 = sv_0(cb_5, u32(22));
    var _S733 : u32 = sv_0(ca_2, u32(22));
    var dth_1 : vec3<f32> = state_0[_S730].xyz - state_0[_S731].xyz + (scratch_0[_S732].xyz - scratch_0[_S733].xyz);
    (*_S726) = to_local_0(_S725, state_0[_S728].xyz - state_0[_S729].xyz + (scratch_0[sv_0(cb_5, u32(21))].xyz - scratch_0[sv_0(ca_2, u32(21))].xyz) + (cross(state_0[_S730].xyz + scratch_0[_S732].xyz, bonds_0[_S725].rb_0.xyz) - cross(state_0[_S731].xyz + scratch_0[_S733].xyz, bonds_0[_S725].ra_0.xyz)));
    (*_S727) = to_local_0(_S725, dth_1);
    return;
}

fn bond_kinematics_0( _S734 : u32,  _S735 : vec3<f32>,  _S736 : vec3<f32>,  _S737 : vec3<f32>,  _S738 : vec3<f32>,  _S739 : ptr<function, vec3<f32>>,  _S740 : ptr<function, vec3<f32>>)
{
    (*_S739) = to_local_0(_S734, _S737 + cross(_S738, bonds_0[_S734].rb_0.xyz) - (_S735 + cross(_S736, bonds_0[_S734].ra_0.xyz)));
    (*_S740) = to_local_0(_S734, _S738 - _S736);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_statics(@builtin(workgroup_id) group_9 : vec3<u32>, @builtin(local_invocation_id) thread_9 : vec3<u32>)
{
    var i_20 : u32;
    var converged_0 : bool;
    var c_40 : u32;
    var tid_18 : u32 = thread_9.x;
    var _S741 : u32 = group_9.x;
    var _S742 : Island_std430_0 = islands_0[_S741];
    var _S743 : vec4<u32> = _S742.info_0;
    var _S744 : u32 = _S742.info_0.z;
    if(((_S744 & (u32(8)))) == u32(0))
    {
        return;
    }
    var free_0 : bool = (((_S743.x) & (u32(1)))) == u32(0);
    var c0_1 : u32 = _S742.range_0.x;
    var c1_1 : u32 = _S742.range_0.y;
    var b0_0 : u32 = _S742.range_0.z;
    var _S745 : u32 = _S742.range_0.w;
    var _S746 : u32 = c0_1 + tid_18;
    var c_41 : u32 = _S746;
    loop
    {
        if(c_41 < c1_1)
        {
        }
        else
        {
            break;
        }
        var _S747 : vec4<f32> = vec4<f32>(0.0f);
        scratch_0[sv_0(c_41, u32(21))] = _S747;
        scratch_0[sv_0(c_41, u32(22))] = _S747;
        c_41 = c_41 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    if(free_0)
    {
        project_load_slot_0(tid_18, &(_S742), u32(0));
    }
    var _S748 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(0), u32(0));
    var _S749 : f32 = max(sqrt(_S748), 1.00000000317107685e-30f);
    var _S750 : f32 = params_0.statics_tol_0;
    var _S751 : u32 = min(params_0.statics_cg_0, u32(20) * (c1_1 - c0_1) * u32(6) + u32(200));
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
        var _S752 : u32 = b0_0 + tid_18;
        i_20 = _S752;
        loop
        {
            if(i_20 < _S745)
            {
            }
            else
            {
                break;
            }
            var resp_3 : JointResponse_0 = static_response_0(i_20);
            write_bond_loads_0(i_20, i_20, resp_3.force_lin_1, resp_3.force_ang_1, 0.0f);
            i_20 = i_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S753 : vec4<f32> = vec4<f32>(0.0f);
        var magnitude_0 : vec4<f32> = _S753;
        var unused_m_0 : vec4<f32> = _S753;
        c_41 = _S746;
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
            hold_0(fixed_mask_0(c_41), &(r_lin_0), &(r_ang_0), _S753, _S753);
            scratch_0[sv_0(c_41, u32(4))] = r_lin_0;
            scratch_0[sv_0(c_41, u32(5))] = r_ang_0;
            c_41 = c_41 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        group_sum2_0(tid_18, &(magnitude_0), &(unused_m_0));
        if(free_0)
        {
            project_load_slot_0(tid_18, &(_S742), u32(4));
        }
        var _S754 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
        var residual_1 : f32 = sqrt(_S754) / _S749;
        var _S755 : f32 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S749);
        if(residual_1 <= _S750)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S755)
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
        var i_21 : u32 = _S752;
        loop
        {
            if(i_21 < _S745)
            {
            }
            else
            {
                break;
            }
            var d_lin_8 : vec3<f32>;
            var d_ang_6 : vec3<f32>;
            static_kinematics_1(i_21, &(d_lin_8), &(d_ang_6));
            var _S756 : JointBond_std430_0 = bonds_0[i_21].law_0;
            var _S757 : JointState_std430_0 = bond_dyn_0[i_21].js_0;
            var f_lin_3 : vec3<f32>;
            var f_ang_3 : vec3<f32>;
            secant_factors_0(&(_S756), &(_S757), d_lin_8, &(f_lin_3), &(f_ang_3));
            var _S758 : u32 = statics_bond_slot_0(i_21);
            var _S759 : f32 = _S756.stiff0_0.y;
            scratch_0[_S758] = vec4<f32>(_S759 * f_lin_3.x, _S759 * f_lin_3.y, _S756.stiff0_0.x * f_lin_3.z, 0.0f);
            scratch_0[_S758 + u32(1)] = vec4<f32>(_S756.stiff0_0.z * f_ang_3.x, _S756.stiff0_0.w * f_ang_3.y, _S756.stiff1_0.x * f_ang_3.z, 0.0f);
            i_21 = i_21 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_42 : u32 = _S746;
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
            scratch_0[sv_0(c_42, u32(2))] = _S753;
            scratch_0[sv_0(c_42, u32(3))] = _S753;
            c_42 = c_42 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_43 : u32 = _S746;
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
            project_displacement_slot_0(tid_18, &(_S742), u32(6));
        }
        var c_44 : u32 = _S746;
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
        var _S760 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(6));
        var _S761 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
        var _S762 : f32 = sqrt(_S761);
        var rz_0 : f32 = _S760;
        var k_26 : u32 = u32(0);
        var cg_total_1 : u32 = cg_total_0;
        loop
        {
            var _S763 : bool;
            if(k_26 < _S751)
            {
                _S763 = _S762 > 0.0f;
            }
            else
            {
                _S763 = false;
            }
            if(_S763)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            var i_22 : u32 = _S752;
            loop
            {
                if(i_22 < _S745)
                {
                }
                else
                {
                    break;
                }
                var ca_3 : u32 = bonds_0[i_22].law_0.ids_0.y;
                var cb_6 : u32 = bonds_0[i_22].law_0.ids_0.z;
                var d_lin_9 : vec3<f32>;
                var d_ang_7 : vec3<f32>;
                bond_kinematics_0(i_22, scratch_0[sv_0(ca_3, u32(8))].xyz, scratch_0[sv_0(ca_3, u32(9))].xyz, scratch_0[sv_0(cb_6, u32(8))].xyz, scratch_0[sv_0(cb_6, u32(9))].xyz, &(d_lin_9), &(d_ang_7));
                var _S764 : u32 = statics_bond_slot_0(i_22);
                write_bond_loads_0(i_22, i_22, d_lin_9 * scratch_0[_S764].xyz, d_ang_7 * scratch_0[_S764 + u32(1)].xyz, 0.0f);
                i_22 = i_22 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_40 = _S746;
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
            var _S765 : u32 = cg_total_1 + u32(1);
            if(pap_0 <= 0.0f)
            {
                cg_total_0 = _S765;
                break;
            }
            var _S766 : f32 = rz_0 / pap_0;
            var c_45 : u32 = _S746;
            loop
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S767 : u32 = sv_0(c_45, u32(2));
                var _S768 : vec3<f32> = vec3<f32>(_S766);
                scratch_0[_S767] = vec4<f32>(scratch_0[_S767].xyz + _S768 * scratch_0[sv_0(c_45, u32(8))].xyz, 0.0f);
                var _S769 : u32 = sv_0(c_45, u32(3));
                scratch_0[_S769] = vec4<f32>(scratch_0[_S769].xyz + _S768 * scratch_0[sv_0(c_45, u32(9))].xyz, 0.0f);
                var _S770 : u32 = sv_0(c_45, u32(4));
                scratch_0[_S770] = vec4<f32>(scratch_0[_S770].xyz - _S768 * scratch_0[sv_0(c_45, u32(10))].xyz, 0.0f);
                var _S771 : u32 = sv_0(c_45, u32(5));
                scratch_0[_S771] = vec4<f32>(scratch_0[_S771].xyz - _S768 * scratch_0[sv_0(c_45, u32(11))].xyz, 0.0f);
                c_45 = c_45 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S772 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(4));
            if((sqrt(_S772)) <= (0.00009999999747379f * _S762))
            {
                cg_total_0 = _S765;
                break;
            }
            var c_46 : u32 = _S746;
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
                project_displacement_slot_0(tid_18, &(_S742), u32(6));
            }
            var rz_new_0 : f32 = island_dot_0(tid_18, c0_1, c1_1, u32(4), u32(6));
            var _S773 : f32 = rz_new_0 / rz_0;
            var c_47 : u32 = _S746;
            loop
            {
                if(c_47 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S774 : u32 = sv_0(c_47, u32(8));
                var _S775 : vec3<f32> = vec3<f32>(_S773);
                scratch_0[_S774] = vec4<f32>(scratch_0[sv_0(c_47, u32(6))].xyz + _S775 * scratch_0[_S774].xyz, 0.0f);
                var _S776 : u32 = sv_0(c_47, u32(9));
                scratch_0[_S776] = vec4<f32>(scratch_0[sv_0(c_47, u32(7))].xyz + _S775 * scratch_0[_S776].xyz, 0.0f);
                c_47 = c_47 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S777 : u32 = k_26 + u32(1);
            rz_0 = rz_new_0;
            k_26 = _S777;
            cg_total_1 = _S765;
        }
        c_40 = _S746;
        loop
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            var _S778 : u32 = u32(4) * c_40;
            var u_7 : vec3<f32> = state_0[_S778].xyz;
            var _S779 : u32 = sv_0(c_40, u32(21));
            var u_lo_0 : vec3<f32> = scratch_0[_S779].xyz;
            var _S780 : u32 = _S778 + u32(1);
            var th_8 : vec3<f32> = state_0[_S780].xyz;
            var _S781 : u32 = sv_0(c_40, u32(22));
            var th_lo_0 : vec3<f32> = scratch_0[_S781].xyz;
            comp_add_0(&(u_7), &(u_lo_0), scratch_0[sv_0(c_40, u32(2))].xyz);
            comp_add_0(&(th_8), &(th_lo_0), scratch_0[sv_0(c_40, u32(3))].xyz);
            state_0[_S778] = vec4<f32>(u_7, state_0[_S778].w);
            state_0[_S780] = vec4<f32>(th_8, state_0[_S780].w);
            scratch_0[_S779] = vec4<f32>(u_lo_0, 0.0f);
            scratch_0[_S781] = vec4<f32>(th_lo_0, 0.0f);
            c_40 = c_40 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S782 : u32 = newton_0 + u32(1);
        previous_2 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S782;
    }
    i_20 = b0_0 + tid_18;
    loop
    {
        if(i_20 < _S745)
        {
        }
        else
        {
            break;
        }
        var resp_4 : JointResponse_0 = static_response_0(i_20);
        var _S783 : JointState_0 = JointState_0( bond_dyn_0[i_20].js_0.damage_0, bond_dyn_0[i_20].js_0.crush_1, bond_dyn_0[i_20].js_0.kappa_0, bond_dyn_0[i_20].js_0.kappa_c_0, bond_dyn_0[i_20].js_0.ductility_0, bond_dyn_0[i_20].js_0.ductility_c_0, bond_dyn_0[i_20].js_0.fatigue_0, bond_dyn_0[i_20].js_0.plastic_x_0, bond_dyn_0[i_20].js_0.plastic_y_0, bond_dyn_0[i_20].js_0.plastic_t_0, bond_dyn_0[i_20].js_0.rebar_plastic_0, bond_dyn_0[i_20].js_0.rebar_slip0_0, bond_dyn_0[i_20].js_0.rebar_slip1_0, bond_dyn_0[i_20].js_0.rebar_work_0, bond_dyn_0[i_20].js_0.rebar_broken_0, bond_dyn_0[i_20].js_0.strain_rate_0, bond_dyn_0[i_20].js_0.governing_stress_0, bond_dyn_0[i_20].js_0.dissipated_0, bond_dyn_0[i_20].js_0.utilization_0, bond_dyn_0[i_20].js_0.mode_0 );
        var bd_1 : BondDyn_0;
        bd_1.js_0 = _S783;
        bd_1.force_lin_0 = bond_dyn_0[i_20].force_lin_0;
        bd_1.force_ang_0 = bond_dyn_0[i_20].force_ang_0;
        bd_1.sums_0 = bond_dyn_0[i_20].sums_0;
        bd_1.comps_0 = bond_dyn_0[i_20].comps_0;
        bd_1.events_0 = bond_dyn_0[i_20].events_0;
        bd_1.force_lin_0 = vec4<f32>(resp_4.force_lin_1, resp_4.stored_6);
        bd_1.force_ang_0 = vec4<f32>(resp_4.force_ang_1, bd_1.force_ang_0.w);
        bond_dyn_0[i_20].js_0.damage_0 = bd_1.js_0.damage_0;
        bond_dyn_0[i_20].js_0.crush_1 = bd_1.js_0.crush_1;
        bond_dyn_0[i_20].js_0.kappa_0 = bd_1.js_0.kappa_0;
        bond_dyn_0[i_20].js_0.kappa_c_0 = bd_1.js_0.kappa_c_0;
        bond_dyn_0[i_20].js_0.ductility_0 = bd_1.js_0.ductility_0;
        bond_dyn_0[i_20].js_0.ductility_c_0 = bd_1.js_0.ductility_c_0;
        bond_dyn_0[i_20].js_0.fatigue_0 = bd_1.js_0.fatigue_0;
        bond_dyn_0[i_20].js_0.plastic_x_0 = bd_1.js_0.plastic_x_0;
        bond_dyn_0[i_20].js_0.plastic_y_0 = bd_1.js_0.plastic_y_0;
        bond_dyn_0[i_20].js_0.plastic_t_0 = bd_1.js_0.plastic_t_0;
        bond_dyn_0[i_20].js_0.rebar_plastic_0 = bd_1.js_0.rebar_plastic_0;
        bond_dyn_0[i_20].js_0.rebar_slip0_0 = bd_1.js_0.rebar_slip0_0;
        bond_dyn_0[i_20].js_0.rebar_slip1_0 = bd_1.js_0.rebar_slip1_0;
        bond_dyn_0[i_20].js_0.rebar_work_0 = bd_1.js_0.rebar_work_0;
        bond_dyn_0[i_20].js_0.rebar_broken_0 = bd_1.js_0.rebar_broken_0;
        bond_dyn_0[i_20].js_0.strain_rate_0 = bd_1.js_0.strain_rate_0;
        bond_dyn_0[i_20].js_0.governing_stress_0 = bd_1.js_0.governing_stress_0;
        bond_dyn_0[i_20].js_0.dissipated_0 = bd_1.js_0.dissipated_0;
        bond_dyn_0[i_20].js_0.utilization_0 = bd_1.js_0.utilization_0;
        bond_dyn_0[i_20].js_0.mode_0 = bd_1.js_0.mode_0;
        bond_dyn_0[i_20].force_lin_0 = bd_1.force_lin_0;
        bond_dyn_0[i_20].force_ang_0 = bd_1.force_ang_0;
        bond_dyn_0[i_20].sums_0 = bd_1.sums_0;
        bond_dyn_0[i_20].comps_0 = bd_1.comps_0;
        bond_dyn_0[i_20].events_0 = bd_1.events_0;
        write_bond_loads_0(i_20, i_20, resp_4.force_lin_1, resp_4.force_ang_1, max(resp_4.measures_0.tension_0, resp_4.measures_0.compression_0));
        i_20 = i_20 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    c_41 = _S746;
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
            var _S784 : u32 = u32(4) * c_41;
            reaction_2 = vec3<f32>(state_0[_S784 + u32(1)].w, state_0[_S784 + u32(2)].w, state_0[_S784 + u32(3)].w);
        }
        var _S785 : u32 = u32(4) * c_41;
        var _S786 : u32 = _S785 + u32(1);
        state_0[_S786] = vec4<f32>(state_0[_S786].xyz, reaction_2.x);
        state_0[_S785 + u32(2)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.y);
        state_0[_S785 + u32(3)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.z);
        c_41 = c_41 + u32(256);
    }
    if(tid_18 == u32(0))
    {
        var _S787 : f32 = (bitcast<f32>((newton_0)));
        var _S788 : f32 = (bitcast<f32>((cg_total_0)));
        if(converged_0)
        {
            previous_2 = 1.0f;
        }
        else
        {
            previous_2 = 0.0f;
        }
        scratch_0[statics_result_slot_0(_S741)] = vec4<f32>(residual_0, _S787, _S788, previous_2);
        islands_0[_S741].info_0[i32(2)] = (_S744 & (u32(4294967287)));
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn settled_fatigue(@builtin(workgroup_id) group_10 : vec3<u32>, @builtin(local_invocation_id) thread_10 : vec3<u32>)
{
    var tid_19 : u32 = thread_10.x;
    var _S789 : u32 = group_10.x;
    var isl_25 : Island_std430_0 = islands_0[_S789];
    var _S790 : bool;
    if((((islands_0[_S789].info_0.x) & (u32(16)))) == u32(0))
    {
        _S790 = true;
    }
    else
    {
        _S790 = (isl_25.range_0.w) == (isl_25.range_0.z);
    }
    if(_S790)
    {
        return;
    }
    var _S791 : bool = tid_19 == u32(0);
    if(_S791)
    {
        g_halt_0 = u32(0);
        g_run_0 = u32(0);
    }
    workgroupBarrier();
    var _S792 : u32 = isl_25.info_0.w;
    var i_23 : u32 = isl_25.range_0.z + tid_19;
    loop
    {
        if(i_23 < (isl_25.range_0.w))
        {
        }
        else
        {
            break;
        }
        var _S793 : JointState_0 = JointState_0( bond_dyn_0[i_23].js_0.damage_0, bond_dyn_0[i_23].js_0.crush_1, bond_dyn_0[i_23].js_0.kappa_0, bond_dyn_0[i_23].js_0.kappa_c_0, bond_dyn_0[i_23].js_0.ductility_0, bond_dyn_0[i_23].js_0.ductility_c_0, bond_dyn_0[i_23].js_0.fatigue_0, bond_dyn_0[i_23].js_0.plastic_x_0, bond_dyn_0[i_23].js_0.plastic_y_0, bond_dyn_0[i_23].js_0.plastic_t_0, bond_dyn_0[i_23].js_0.rebar_plastic_0, bond_dyn_0[i_23].js_0.rebar_slip0_0, bond_dyn_0[i_23].js_0.rebar_slip1_0, bond_dyn_0[i_23].js_0.rebar_work_0, bond_dyn_0[i_23].js_0.rebar_broken_0, bond_dyn_0[i_23].js_0.strain_rate_0, bond_dyn_0[i_23].js_0.governing_stress_0, bond_dyn_0[i_23].js_0.dissipated_0, bond_dyn_0[i_23].js_0.utilization_0, bond_dyn_0[i_23].js_0.mode_0 );
        var bd_2 : BondDyn_0;
        bd_2.js_0 = _S793;
        bd_2.force_lin_0 = bond_dyn_0[i_23].force_lin_0;
        bd_2.force_ang_0 = bond_dyn_0[i_23].force_ang_0;
        bd_2.sums_0 = bond_dyn_0[i_23].sums_0;
        bd_2.comps_0 = bond_dyn_0[i_23].comps_0;
        bd_2.events_0 = bond_dyn_0[i_23].events_0;
        var _S794 : JointBond_std430_0 = bonds_0[i_23].law_0;
        var _S795 : u32 = u32(4) * _S794.ids_0.y;
        var _S796 : u32 = u32(4) * _S794.ids_0.z;
        var d_lin_10 : vec3<f32>;
        var d_ang_8 : vec3<f32>;
        bond_kinematics_0(i_23, state_0[_S795].xyz, state_0[_S795 + u32(1)].xyz, state_0[_S796].xyz, state_0[_S796 + u32(1)].xyz, &(d_lin_10), &(d_ang_8));
        var _S797 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S794.ids_0.x];
        var previous_3 : JointState_0 = bd_2.js_0;
        var _S798 : JointResponse_0 = joint_evaluate_1(&(_S797), &(_S794), bd_2.js_0, d_lin_10, d_ang_8, params_0.dt_0, (params_0.fracture_0) != u32(0));
        if((_S798.state_1.damage_0) > (bd_2.js_0.damage_0 + 9.99999971718068537e-10f))
        {
            _S790 = true;
        }
        else
        {
            _S790 = (_S798.state_1.crush_1) > (previous_3.crush_1 + 9.99999971718068537e-10f);
        }
        var flags_4 : u32;
        if(_S790)
        {
            flags_4 = u32(16);
        }
        else
        {
            flags_4 = u32(0);
        }
        var _S799 : f32 = bd_2.sums_0[i32(0)];
        var _S800 : f32 = bd_2.comps_0[i32(0)];
        comp_add1_2(&(_S799), &(_S800), _S798.dissipated_3);
        bd_2.sums_0[i32(0)] = _S799;
        bd_2.comps_0[i32(0)] = _S800;
        var _S801 : f32 = bd_2.sums_0[i32(1)];
        var _S802 : f32 = bd_2.comps_0[i32(1)];
        comp_add1_2(&(_S801), &(_S802), _S798.overshoot_0);
        bd_2.sums_0[i32(1)] = _S801;
        bd_2.comps_0[i32(1)] = _S802;
        bd_2.force_lin_0 = vec4<f32>(_S798.force_lin_1, _S798.stored_6);
        bd_2.force_ang_0 = vec4<f32>(_S798.force_ang_1, max(bd_2.force_ang_0.w, _S798.state_1.utilization_0));
        var _S803 : bool;
        if(!is_damaged_0(previous_3))
        {
            _S803 = is_damaged_0(_S798.state_1);
        }
        else
        {
            _S803 = false;
        }
        var _S804 : bool;
        if(_S803)
        {
            _S804 = (bd_2.events_0.x) == u32(0);
        }
        else
        {
            _S804 = false;
        }
        if(_S804)
        {
            bd_2.events_0[i32(0)] = _S792;
            bd_2.events_0[i32(3)] = _S798.state_1.mode_0;
        }
        var _S805 : bool;
        if((bd_2.events_0.y) == u32(0))
        {
            var _S806 : f32 = fatigue_factor_1(&(_S797), previous_3.fatigue_0);
            _S805 = _S806 > 0.99000000953674316f;
        }
        else
        {
            _S805 = false;
        }
        var _S807 : bool;
        if(_S805)
        {
            var _S808 : f32 = fatigue_factor_1(&(_S797), _S798.state_1.fatigue_0);
            _S807 = _S808 <= 0.99000000953674316f;
        }
        else
        {
            _S807 = false;
        }
        if(_S807)
        {
            bd_2.events_0[i32(1)] = _S792;
        }
        var flags_5 : u32;
        if(_S798.disconnected_0)
        {
            bd_2.events_0[i32(2)] = _S792;
            flags_5 = (flags_4 | (u32(32)));
        }
        else
        {
            flags_5 = flags_4;
        }
        bd_2.js_0 = _S798.state_1;
        bond_dyn_0[i_23].js_0.damage_0 = bd_2.js_0.damage_0;
        bond_dyn_0[i_23].js_0.crush_1 = bd_2.js_0.crush_1;
        bond_dyn_0[i_23].js_0.kappa_0 = bd_2.js_0.kappa_0;
        bond_dyn_0[i_23].js_0.kappa_c_0 = bd_2.js_0.kappa_c_0;
        bond_dyn_0[i_23].js_0.ductility_0 = bd_2.js_0.ductility_0;
        bond_dyn_0[i_23].js_0.ductility_c_0 = bd_2.js_0.ductility_c_0;
        bond_dyn_0[i_23].js_0.fatigue_0 = bd_2.js_0.fatigue_0;
        bond_dyn_0[i_23].js_0.plastic_x_0 = bd_2.js_0.plastic_x_0;
        bond_dyn_0[i_23].js_0.plastic_y_0 = bd_2.js_0.plastic_y_0;
        bond_dyn_0[i_23].js_0.plastic_t_0 = bd_2.js_0.plastic_t_0;
        bond_dyn_0[i_23].js_0.rebar_plastic_0 = bd_2.js_0.rebar_plastic_0;
        bond_dyn_0[i_23].js_0.rebar_slip0_0 = bd_2.js_0.rebar_slip0_0;
        bond_dyn_0[i_23].js_0.rebar_slip1_0 = bd_2.js_0.rebar_slip1_0;
        bond_dyn_0[i_23].js_0.rebar_work_0 = bd_2.js_0.rebar_work_0;
        bond_dyn_0[i_23].js_0.rebar_broken_0 = bd_2.js_0.rebar_broken_0;
        bond_dyn_0[i_23].js_0.strain_rate_0 = bd_2.js_0.strain_rate_0;
        bond_dyn_0[i_23].js_0.governing_stress_0 = bd_2.js_0.governing_stress_0;
        bond_dyn_0[i_23].js_0.dissipated_0 = bd_2.js_0.dissipated_0;
        bond_dyn_0[i_23].js_0.utilization_0 = bd_2.js_0.utilization_0;
        bond_dyn_0[i_23].js_0.mode_0 = bd_2.js_0.mode_0;
        bond_dyn_0[i_23].force_lin_0 = bd_2.force_lin_0;
        bond_dyn_0[i_23].force_ang_0 = bd_2.force_ang_0;
        bond_dyn_0[i_23].sums_0 = bd_2.sums_0;
        bond_dyn_0[i_23].comps_0 = bd_2.comps_0;
        bond_dyn_0[i_23].events_0 = bd_2.events_0;
        write_bond_loads_0(i_23, i_23, _S798.force_lin_1, _S798.force_ang_1, max(_S798.measures_0.tension_0, _S798.measures_0.compression_0));
        if(((flags_5 & (u32(16)))) != u32(0))
        {
            g_halt_0 = u32(1);
        }
        if(((flags_5 & (u32(32)))) != u32(0))
        {
            g_run_0 = u32(1);
        }
        i_23 = i_23 + u32(256);
    }
    workgroupBarrier();
    if(_S791)
    {
        _S790 = ((g_halt_0 | (g_run_0))) != u32(0);
    }
    else
    {
        _S790 = false;
    }
    if(_S790)
    {
        var _S809 : u32 = isl_25.info_0.z;
        if(g_halt_0 != u32(0))
        {
            i_23 = u32(16);
        }
        else
        {
            i_23 = u32(0);
        }
        var _S810 : u32 = (_S809 | (i_23));
        if(g_run_0 != u32(0))
        {
            i_23 = u32(32);
        }
        else
        {
            i_23 = u32(0);
        }
        islands_0[_S789].info_0[i32(2)] = (_S810 | (i_23));
    }
    return;
}

