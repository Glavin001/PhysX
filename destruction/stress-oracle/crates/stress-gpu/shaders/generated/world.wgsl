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
    @align(16) pair_lanes_0 : u32,
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
    @align(16) done_0 : u32,
    @align(4) coverage_0 : u32,
    @align(8) wide_groups_0 : u32,
    @align(4) done_pad_0 : u32,
    @align(16) probes_0 : vec4<u32>,
    @align(16) energy_0 : vec4<f32>,
    @align(16) rotation_err_0 : vec4<f32>,
    @align(16) momentum_0 : vec4<f32>,
    @align(16) momentum_err_0 : vec4<f32>,
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
    @align(16) start_rot_0 : vec4<f32>,
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
    @align(16) rotation_err_1 : vec4<f32>,
    @align(16) ledger_0 : vec4<f32>,
    @align(16) cand_0 : vec4<u32>,
    @align(16) momentum_1 : vec4<f32>,
    @align(16) momentum_err_1 : vec4<f32>,
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
struct JointState_std430_0
{
    @align(4) damage_0 : f32,
    @align(4) crush_1 : f32,
    @align(4) kappa_0 : f32,
    @align(4) kappa_c_0 : f32,
    @align(4) ductility_0 : f32,
    @align(4) ductility_c_0 : f32,
    @align(4) life_0 : f32,
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

fn pair_lane_count_0() -> u32
{
    return u32(1);
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

fn pair_any_0( x_1 : bool,  lanes_0 : u32) -> bool
{
    return x_1;
}

struct Quat_0
{
     w_0 : f32,
     x_2 : f32,
     y_1 : f32,
     z_0 : f32,
};

fn quat_of_0( q_0 : vec4<f32>) -> Quat_0
{
    var r_0 : Quat_0;
    r_0.x_2 = q_0.x;
    r_0.y_1 = q_0.y;
    r_0.z_0 = q_0.z;
    r_0.w_0 = q_0.w;
    return r_0;
}

fn rotate_0( q_1 : Quat_0,  v_0 : vec3<f32>) -> vec3<f32>
{
    var qv_0 : vec3<f32> = vec3<f32>(q_1.x_2, q_1.y_1, q_1.z_0);
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
    q_3.x_2 = a_4.x * s_2;
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

fn is_nan_0( x_3 : f32) -> bool
{
    return (((bitcast<u32>((x_3))) & (u32(2147483647)))) > u32(2139095040);
}

fn pair_count_sum_0( x_4 : u32,  lanes_1 : u32) -> u32
{
    return x_4;
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

fn pair_sum3_0( x_5 : vec3<f32>,  lanes_2 : u32) -> vec3<f32>
{
    return x_5;
}

fn pair_sum_0( x_6 : f32,  lanes_3 : u32) -> f32
{
    return x_6;
}

fn comp_add1_0( sum_0 : ptr<function, f32>,  err_0 : ptr<function, f32>,  x_7 : f32)
{
    var t_1 : f32 = (*sum_0) + x_7;
    if((abs((*sum_0))) >= (abs(x_7)))
    {
        (*err_0) = (*err_0) + ((*sum_0) - t_1 + x_7);
    }
    else
    {
        (*err_0) = (*err_0) + (x_7 - t_1 + (*sum_0));
    }
    (*sum_0) = t_1;
    return;
}

fn comp_add1_1( sum_1 : ptr<function, f32>,  err_1 : ptr<function, f32>,  x_8 : f32)
{
    var t_2 : f32 = (*sum_1) + x_8;
    if((abs((*sum_1))) >= (abs(x_8)))
    {
        (*err_1) = (*err_1) + ((*sum_1) - t_2 + x_8);
    }
    else
    {
        (*err_1) = (*err_1) + (x_8 - t_2 + (*sum_1));
    }
    (*sum_1) = t_2;
    return;
}

fn comp_add1_2( sum_2 : ptr<function, f32>,  err_2 : ptr<function, f32>,  x_9 : f32)
{
    var t_3 : f32 = (*sum_2) + x_9;
    if((abs((*sum_2))) >= (abs(x_9)))
    {
        (*err_2) = (*err_2) + ((*sum_2) - t_3 + x_9);
    }
    else
    {
        (*err_2) = (*err_2) + (x_9 - t_3 + (*sum_2));
    }
    (*sum_2) = t_3;
    return;
}

fn cov_or_0( island_0 : u32,  bits_0 : u32)
{
    islands_0[island_0].coverage_0 = ((islands_0[island_0].coverage_0) | (bits_0));
    return;
}

fn cov_mark_0( island_1 : u32,  seen_0 : u32,  bits_1 : u32)
{
    if(((bits_1 & ((~seen_0)))) != u32(0))
    {
        cov_or_0(island_1, bits_1);
    }
    return;
}

fn sentinel_mark_0( bits_2 : u32)
{
    cov_mark_0(params_0.halt_index_0, islands_0[params_0.halt_index_0].coverage_0, bits_2);
    return;
}

fn pair_contact_0( i_2 : u32,  lane_0 : u32,  lanes_4 : u32)
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
            e_1 = lane_0;
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
                e_1 = e_1 + lanes_4;
            }
        }
        if(lane_0 == u32(0))
        {
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
        }
        return;
    }
    var count_0 : u32;
    var fa_0 : vec3<f32>;
    var ta_1 : vec3<f32>;
    var fb_0 : vec3<f32>;
    var tb_1 : vec3<f32>;
    var stored_sum_0 : f32;
    var diss_sum_0 : f32;
    if(may_overlap_0(ba_1, bb_1))
    {
        var va0_0 : vec3<f32>;
        var wa0_0 : vec3<f32>;
        chunk_velocity_0(ca_0, &(va0_0), &(wa0_0));
        var vb0_0 : vec3<f32>;
        var wb0_0 : vec3<f32>;
        chunk_velocity_0(cb_0, &(vb0_0), &(wb0_0));
        e_1 = lane_0;
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
                e_1 = e_1 + lanes_4;
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
            e_1 = e_1 + lanes_4;
        }
        var engaged_2 : u32 = pair_count_sum_0(engaged_0, lanes_4);
        if((pair_count_sum_0(count_0, lanes_4)) > u32(0))
        {
            var _S54 : f32 = contact_stiffness_0(chunks_0[ca_0].cmat_0.x, ba_1, chunks_0[cb_0].cmat_0.x, bb_1, bb_1.center_1 - ba_1.center_1) / max(f32(engaged_2), 10.0f);
            e_1 = lane_0;
            fa_0 = _S47;
            ta_1 = _S47;
            fb_0 = _S47;
            tb_1 = _S47;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
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
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                var eff_0 : f32 = d_9 - contact_state_0[_S43 + e_1].x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                var stored_2 : f32;
                var diss_0 : f32;
                var f_1 : vec3<f32> = penalty_force_0(_S54, _S44, _S45, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - bb_1.center_1)), _S46, engaged_2, &(stored_2), &(diss_0));
                var ta_2 : vec3<f32> = ta_1 + cross(p_4, f_1);
                var _S56 : vec3<f32> = (vec3<f32>(0) - f_1);
                var fb_1 : vec3<f32> = fb_0 + _S56;
                var tb_2 : vec3<f32> = tb_1 + cross(p_4 - bb_1.center_1, _S56);
                var stored_sum_1 : f32 = stored_sum_0 + stored_2;
                var diss_sum_1 : f32 = diss_sum_0 + diss_0;
                fa_0 = fa_0 + f_1;
                ta_1 = ta_2;
                fb_0 = fb_1;
                tb_1 = tb_2;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                e_1 = e_1 + lanes_4;
            }
            var _S57 : vec3<f32> = pair_sum3_0(fa_0, lanes_4);
            var _S58 : vec3<f32> = pair_sum3_0(ta_1, lanes_4);
            var _S59 : vec3<f32> = pair_sum3_0(fb_0, lanes_4);
            var _S60 : vec3<f32> = pair_sum3_0(tb_1, lanes_4);
            var _S61 : f32 = pair_sum_0(stored_sum_0, lanes_4);
            var _S62 : f32 = pair_sum_0(diss_sum_0, lanes_4);
            has_state_0 = true;
            diss_sum_0 = _S62;
            fa_0 = _S57;
            ta_1 = _S58;
            fb_0 = _S59;
            tb_1 = _S60;
            stored_sum_0 = _S61;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
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
        diss_sum_0 = 0.0f;
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
        e_1 = lane_0;
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
            e_1 = e_1 + lanes_4;
        }
    }
    if(lane_0 != u32(0))
    {
        return;
    }
    if(has_state_0)
    {
        var _S63 : f32 = ledger_1[i32(1)];
        var _S64 : f32 = ledger_1[i32(2)];
        comp_add1_1(&(_S63), &(_S64), diss_sum_0);
        ledger_1[i32(1)] = _S63;
        ledger_1[i32(2)] = _S64;
    }
    var _S65 : vec3<f32> = vec3<f32>(0.0f);
    if((any((fa_0 != _S65))))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((ta_1 != _S65)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((fb_0 != _S65)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((tb_1 != _S65)));
    }
    var _S66 : bool;
    if(loaded_0)
    {
        _S66 = true;
    }
    else
    {
        _S66 = ((flags_0 & (u32(2)))) != u32(0);
    }
    if(_S66)
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
    if(loaded_0)
    {
        sentinel_mark_0(u32(1));
    }
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
     rotation_err_1 : vec4<f32>,
     ledger_0 : vec4<f32>,
     cand_0 : vec4<u32>,
     momentum_1 : vec4<f32>,
     momentum_err_1 : vec4<f32>,
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
    var _S67 : u32;
    if(((*imp_1).shape_0.x) == 0.0f)
    {
        _S67 = u32(1);
    }
    else
    {
        _S67 = sample_count_0(b_17) + u32(14);
    }
    return _S67;
}

fn impactor_slots_1( imp_2 : ptr<function, Impactor_std430_0>,  b_18 : Box_0) -> u32
{
    var _S68 : u32;
    if(((*imp_2).shape_0.x) == 0.0f)
    {
        _S68 = u32(1);
    }
    else
    {
        _S68 = sample_count_0(b_18) + u32(14);
    }
    return _S68;
}

fn impactor_slots_2( imp_3 : ptr<function, Impactor_std430_0>,  b_19 : Box_0) -> u32
{
    var _S69 : u32;
    if(((*imp_3).shape_0.x) == 0.0f)
    {
        _S69 = u32(1);
    }
    else
    {
        _S69 = sample_count_0(b_19) + u32(14);
    }
    return _S69;
}

fn sphere_contact_0( b_20 : Box_0,  center_4 : vec3<f32>,  radius_0 : f32,  point_0 : ptr<function, vec3<f32>>,  normal_5 : ptr<function, vec3<f32>>,  depth_4 : ptr<function, f32>) -> bool
{
    var _S70 : vec3<f32> = vec3<f32>(0.0f);
    (*point_0) = _S70;
    (*normal_5) = _S70;
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
        var _S71 : vec3<f32> = box_to_world_0(b_20, loads_0[b_20.hull_at_0 + b_20.hull_v_0 + face_3].xyz);
        (*normal_5) = _S71;
        (*point_0) = center_4 - _S71 * vec3<f32>(max(d_10, 0.0f));
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
    var _S72 : bool = penetration_0(b_20, center_4, &(inside_0), &(n_4));
    if(!_S72)
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
    var _S73 : vec3<f32> = vec3<f32>(0.0f);
    (*p_5) = _S73;
    (*n_5) = _S73;
    (*d_12) = 0.0f;
    var _S74 : vec4<f32> = (*imp_4).shape_0;
    if(((*imp_4).shape_0.x) == 0.0f)
    {
        var _S75 : bool = sphere_contact_0(b_21, _S73, _S74.y - crush_depth_0, &((*p_5)), &((*n_5)), &((*d_12)));
        if(!_S75)
        {
            return false;
        }
        (*n_5) = (vec3<f32>(0) - (*n_5));
        return true;
    }
    var cb_1 : u32 = sample_count_0(b_21);
    if(j_0 < cb_1)
    {
        var _S76 : vec3<f32> = sample_point_0(b_21, j_0);
        (*p_5) = _S76;
        var _S77 : bool = penetration_0(shrunk_0, _S76, &((*d_12)), &((*n_5)));
        return _S77;
    }
    var _S78 : vec3<f32> = sample_point_0(shrunk_0, j_0 - cb_1);
    (*p_5) = _S78;
    var _S79 : bool = penetration_0(b_21, _S78, &((*d_12)), &((*n_5)));
    if(!_S79)
    {
        return false;
    }
    (*n_5) = (vec3<f32>(0) - (*n_5));
    return true;
}

fn impactor_contact_1( imp_5 : ptr<function, Impactor_std430_0>,  crush_depth_1 : f32,  shrunk_1 : Box_0,  b_22 : Box_0,  j_1 : u32,  p_6 : ptr<function, vec3<f32>>,  n_6 : ptr<function, vec3<f32>>,  d_13 : ptr<function, f32>) -> bool
{
    var _S80 : vec3<f32> = vec3<f32>(0.0f);
    (*p_6) = _S80;
    (*n_6) = _S80;
    (*d_13) = 0.0f;
    var _S81 : vec4<f32> = (*imp_5).shape_0;
    if(((*imp_5).shape_0.x) == 0.0f)
    {
        var _S82 : bool = sphere_contact_0(b_22, _S80, _S81.y - crush_depth_1, &((*p_6)), &((*n_6)), &((*d_13)));
        if(!_S82)
        {
            return false;
        }
        (*n_6) = (vec3<f32>(0) - (*n_6));
        return true;
    }
    var cb_2 : u32 = sample_count_0(b_22);
    if(j_1 < cb_2)
    {
        var _S83 : vec3<f32> = sample_point_0(b_22, j_1);
        (*p_6) = _S83;
        var _S84 : bool = penetration_0(shrunk_1, _S83, &((*d_13)), &((*n_6)));
        return _S84;
    }
    var _S85 : vec3<f32> = sample_point_0(shrunk_1, j_1 - cb_2);
    (*p_6) = _S85;
    var _S86 : bool = penetration_0(b_22, _S85, &((*d_13)), &((*n_6)));
    if(!_S86)
    {
        return false;
    }
    (*n_6) = (vec3<f32>(0) - (*n_6));
    return true;
}

fn impactor_point_0( _S87 : u32) -> WorldPoint_0
{
    var wi_0 : WorldPoint_0;
    wi_0.hi_0 = impactors_0[_S87].position_1.xyz;
    wi_0.lo_0 = impactors_0[_S87].position_err_1.xyz;
    wi_0.rel_0 = vec3<f32>(0.0f);
    return wi_0;
}

fn impactor_box_1( _S88 : u32,  _S89 : vec3<f32>,  _S90 : vec3<f32>) -> Box_0
{
    var q_9 : Quat_0 = quat_of_0(impactors_0[_S88].rotation_1);
    var b_23 : Box_0;
    b_23.center_1 = _S89;
    b_23.axis0_0 = rotate_0(q_9, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_23.axis1_0 = rotate_0(q_9, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_23.axis2_0 = rotate_0(q_9, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_23.half_2 = _S90;
    b_23.hull_at_0 = u32(0);
    b_23.hull_v_0 = u32(0);
    b_23.hull_f_0 = u32(0);
    return b_23;
}

fn impactor_shrunk_0( _S91 : u32,  _S92 : f32,  _S93 : Box_0) -> Box_0
{
    var shrunk_2 : Box_0 = _S93;
    shrunk_2.half_2 = _S93.half_2 - min(vec3<f32>(_S92), _S93.half_2 * vec3<f32>(0.5f));
    return shrunk_2;
}

fn impactor_contact_2( _S94 : u32,  _S95 : f32,  _S96 : Box_0,  _S97 : Box_0,  _S98 : u32,  _S99 : ptr<function, vec3<f32>>,  _S100 : ptr<function, vec3<f32>>,  _S101 : ptr<function, f32>) -> bool
{
    var _S102 : Impactor_std430_0 = impactors_0[_S94];
    var _S103 : vec3<f32> = vec3<f32>(0.0f);
    (*_S99) = _S103;
    (*_S100) = _S103;
    (*_S101) = 0.0f;
    if((_S102.shape_0.x) == 0.0f)
    {
        var _S104 : bool = sphere_contact_0(_S97, _S103, _S102.shape_0.y - _S95, &((*_S99)), &((*_S100)), &((*_S101)));
        if(!_S104)
        {
            return false;
        }
        (*_S100) = (vec3<f32>(0) - (*_S100));
        return true;
    }
    var cb_3 : u32 = sample_count_0(_S97);
    if(_S98 < cb_3)
    {
        var _S105 : vec3<f32> = sample_point_0(_S97, _S98);
        (*_S99) = _S105;
        var _S106 : bool = penetration_0(_S96, _S105, &((*_S101)), &((*_S100)));
        return _S106;
    }
    var _S107 : vec3<f32> = sample_point_0(_S96, _S98 - cb_3);
    (*_S99) = _S107;
    var _S108 : bool = penetration_0(_S97, _S107, &((*_S101)), &((*_S100)));
    if(!_S108)
    {
        return false;
    }
    (*_S100) = (vec3<f32>(0) - (*_S100));
    return true;
}

fn impactor_contact_count_0( _S109 : u32,  _S110 : f32,  _S111 : Box_0,  _S112 : Box_0) -> u32
{
    var _S113 : Impactor_std430_0 = impactors_0[_S109];
    var j_2 : u32 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        var _S114 : u32 = impactor_slots_0(&(_S113), _S112);
        if(j_2 < _S114)
        {
        }
        else
        {
            break;
        }
        var p_7 : vec3<f32>;
        var n_7 : vec3<f32>;
        var d_14 : f32;
        if(impactor_contact_2(_S109, _S110, _S111, _S112, j_2, &(p_7), &(n_7), &(d_14)))
        {
            count_1 = count_1 + u32(1);
        }
        j_2 = j_2 + u32(1);
    }
    return count_1;
}

fn impactor_candidate_forces_0( k_7 : u32)
{
    var _S115 : u32 = u32(3) * k_7;
    var at_1 : u32 = params_0.cand_index_0 + _S115;
    var c_5 : u32 = index_0[at_1];
    var slot_0 : u32 = index_0[at_1 + u32(1)];
    var _S116 : u32 = index_0[at_1 + u32(2)];
    var _S117 : Impactor_std430_0 = impactors_0[_S116];
    var _S118 : f32 = params_0.dt_0;
    var _S119 : vec3<f32> = vec3<f32>(0.0f);
    var data_1 : vec4<f32> = scratch_0[params_0.cand_base_0 + _S115];
    var hit_0 : bool;
    var f_sum_0 : vec3<f32>;
    var t_sum_0 : vec3<f32>;
    var imp_f_0 : vec3<f32>;
    var imp_t_0 : vec3<f32>;
    if((_S117.cand_0.z) == u32(0))
    {
        var rel_1 : vec3<f32> = world_diff_0(chunk_world_0(c_5), impactor_point_0(_S116));
        var _S120 : vec4<f32> = _S117.half_1;
        if(!((length(rel_1)) > (_S117.half_1.w + chunks_0[c_5].half_0.w)))
        {
            var _S121 : Box_0 = impactor_box_1(_S116, _S119, _S120.xyz);
            var b_24 : Box_0 = chunk_box_0(c_5, rel_1);
            var _S122 : vec4<f32> = _S117.mat_0;
            var kc_0 : f32 = contact_stiffness_0(_S117.mat_0.x, _S121, chunks_0[c_5].cmat_0.x, b_24, b_24.center_1 - _S121.center_1);
            var _S123 : vec4<f32> = _S117.geom_0;
            var _S124 : f32 = _S117.geom_0.y;
            var _S125 : Box_0 = impactor_shrunk_0(_S116, _S124, _S121);
            var _S126 : u32 = impactor_contact_count_0(_S116, _S124, _S125, b_24);
            var _S127 : bool = (_S117.shape_0.x) == 0.0f;
            var _S128 : f32;
            if(_S127)
            {
                _S128 = kc_0;
            }
            else
            {
                _S128 = kc_0 / max(f32(_S126), 10.0f);
            }
            var _S129 : u32;
            if(_S127)
            {
                _S129 = u32(1);
            }
            else
            {
                _S129 = _S126;
            }
            var m_1 : f32 = chunks_0[c_5].center_0.w;
            var _S130 : f32 = _S122.z;
            var _S131 : f32 = m_1 * _S130 / (m_1 + _S130);
            var _S132 : f32;
            if((params_0.pair_friction_0) >= 0.0f)
            {
                _S132 = params_0.pair_friction_0;
            }
            else
            {
                _S132 = min(_S122.y, chunks_0[c_5].cmat_0.y);
            }
            var _S133 : vec3<f32> = _S117.velocity_1.xyz + _S117.velocity_err_1.xyz;
            var vc_0 : vec3<f32>;
            var wc_0 : vec3<f32>;
            chunk_velocity_0(c_5, &(vc_0), &(wc_0));
            hit_0 = false;
            var j_3 : u32 = u32(0);
            f_sum_0 = _S119;
            t_sum_0 = _S119;
            imp_f_0 = _S119;
            imp_t_0 = _S119;
            loop
            {
                var _S134 : bool;
                if(_S126 > u32(0))
                {
                    var _S135 : u32 = impactor_slots_1(&(_S117), b_24);
                    _S134 = j_3 < _S135;
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
                var p_8 : vec3<f32>;
                var nrm_0 : vec3<f32>;
                var dep_0 : f32;
                var _S136 : bool = impactor_contact_0(&(_S117), _S124, _S125, b_24, j_3, &(p_8), &(nrm_0), &(dep_0));
                if(!_S136)
                {
                    j_3 = j_3 + u32(1);
                    continue;
                }
                var stored_3 : f32;
                var diss_1 : f32;
                var f_2 : vec3<f32> = penalty_force_0(_S128, _S131, _S132, dep_0 * _S123.x, nrm_0, vc_0 + cross(wc_0, p_8 - b_24.center_1) - (_S133 + cross(_S117.angular_velocity_1.xyz, p_8)), _S118, _S129, &(stored_3), &(diss_1));
                var f_sum_1 : vec3<f32> = f_sum_0 + f_2;
                var t_sum_1 : vec3<f32> = t_sum_0 + cross(p_8 - b_24.center_1, f_2);
                var imp_f_1 : vec3<f32> = imp_f_0 - f_2;
                var imp_t_1 : vec3<f32> = imp_t_0 - cross(p_8, f_2);
                var _S137 : f32 = data_1[i32(2)];
                var _S138 : f32 = data_1[i32(3)];
                comp_add1_1(&(_S137), &(_S138), diss_1);
                data_1[i32(2)] = _S137;
                data_1[i32(3)] = _S138;
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                j_3 = j_3 + u32(1);
            }
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S119;
            t_sum_0 = _S119;
            imp_f_0 = _S119;
            imp_t_0 = _S119;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S119;
        t_sum_0 = _S119;
        imp_f_0 = _S119;
        imp_t_0 = _S119;
    }
    var _S139 : u32 = u32(2) * slot_0;
    scratch_0[params_0.slot_base_0 + _S139] = vec4<f32>(f_sum_0, 0.0f);
    scratch_0[params_0.slot_base_0 + _S139 + u32(1)] = vec4<f32>(t_sum_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S115] = data_1;
    scratch_0[params_0.cand_base_0 + _S115 + u32(1)] = vec4<f32>(imp_f_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S115 + u32(2)] = vec4<f32>(imp_t_0, 0.0f);
    if(hit_0)
    {
        sentinel_mark_0(u32(2));
    }
    return;
}

fn quat_mul_0( a_7 : Quat_0,  o_0 : Quat_0) -> Quat_0
{
    var r_5 : Quat_0;
    r_5.w_0 = a_7.w_0 * o_0.w_0 - a_7.x_2 * o_0.x_2 - a_7.y_1 * o_0.y_1 - a_7.z_0 * o_0.z_0;
    r_5.x_2 = a_7.w_0 * o_0.x_2 + a_7.x_2 * o_0.w_0 + a_7.y_1 * o_0.z_0 - a_7.z_0 * o_0.y_1;
    r_5.y_1 = a_7.w_0 * o_0.y_1 - a_7.x_2 * o_0.z_0 + a_7.y_1 * o_0.w_0 + a_7.z_0 * o_0.x_2;
    r_5.z_0 = a_7.w_0 * o_0.z_0 + a_7.x_2 * o_0.y_1 - a_7.y_1 * o_0.x_2 + a_7.z_0 * o_0.w_0;
    return r_5;
}

fn travel_check_0( c_6 : u32)
{
    var _S140 : vec4<u32> = chunks_0[c_6].cinfo_0;
    if((chunks_0[c_6].cinfo_0.z) == u32(0))
    {
        return;
    }
    var wp_0 : WorldPoint_0 = chunk_world_0(c_6);
    var _S141 : vec4<f32> = chunks_0[c_6].start_hi_0;
    var travel_0 : f32 = length(wp_0.hi_0 - chunks_0[c_6].start_hi_0.xyz + (wp_0.lo_0 - chunks_0[c_6].start_lo_0.xyz) + wp_0.rel_0);
    var travel_1 : f32;
    if((_S140.w) != u32(0))
    {
        var th_1 : vec3<f32> = state_0[u32(4) * c_6 + u32(1)].xyz;
        var turn_0 : Quat_0 = quat_mul_0(quat_of_0(vec4<f32>((vec3<f32>(0) - chunks_0[c_6].start_rot_0.xyz), chunks_0[c_6].start_rot_0.w)), quat_mul_0(quat_of_0(islands_0[chunks_0[c_6].info_1.y].rotation_0), from_axis_angle_0(th_1, length(th_1))));
        travel_1 = travel_0 + 2.0f * atan2(length(vec3<f32>(turn_0.x_2, turn_0.y_1, turn_0.z_0)), abs(turn_0.w_0)) * chunks_0[c_6].half_0.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S141.w))
    {
        islands_0[params_0.halt_index_0].info_0[i32(2)] = ((islands_0[params_0.halt_index_0].info_0.z) | (u32(1)));
        sentinel_mark_0(u32(1048576));
    }
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn contact_forces(@builtin(global_invocation_id) id_0 : vec3<u32>)
{
    var i_3 : u32 = id_0.x;
    var lanes_5 : u32 = pair_lane_count_0();
    var pair_threads_0 : u32 = params_0.pair_count_0 * lanes_5;
    if(i_3 < pair_threads_0)
    {
        if(!pair_any_0(stopped_0(), lanes_5))
        {
            var _S142 : u32 = i_3 / lanes_5;
            var _S143 : u32 = i_3 % lanes_5;
            pair_contact_0(_S142, _S143, lanes_5);
        }
        return;
    }
    if(stopped_0())
    {
        return;
    }
    var j_4 : u32 = i_3 - pair_threads_0;
    if(j_4 < (params_0.cand_count_0))
    {
        impactor_candidate_forces_0(j_4);
    }
    else
    {
        if(j_4 < (params_0.cand_count_0 + params_0.chunk_count_0))
        {
            travel_check_0(j_4 - params_0.cand_count_0);
        }
    }
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn impactor_shares(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var k_8 : u32 = id_1.x;
    var _S144 : bool;
    if(k_8 >= (params_0.cand_count_0))
    {
        _S144 = true;
    }
    else
    {
        _S144 = stopped_0();
    }
    if(_S144)
    {
        return;
    }
    var _S145 : u32 = u32(3) * k_8;
    var at_2 : u32 = params_0.cand_index_0 + _S145;
    var c_7 : u32 = index_0[at_2];
    var _S146 : u32 = index_0[at_2 + u32(2)];
    var _S147 : Impactor_std430_0 = impactors_0[_S146];
    if((_S147.cand_0.z) == u32(0))
    {
        _S144 = (_S147.crush_0.x) > 0.0f;
    }
    else
    {
        _S144 = false;
    }
    var total_0 : f32;
    var ksum_0 : f32;
    if(_S144)
    {
        var rel_2 : vec3<f32> = world_diff_0(chunk_world_0(c_7), impactor_point_0(_S146));
        var _S148 : vec4<f32> = _S147.half_1;
        if(!((length(rel_2)) > (_S147.half_1.w + chunks_0[c_7].half_0.w)))
        {
            var _S149 : Box_0 = impactor_box_1(_S146, vec3<f32>(0.0f), _S148.xyz);
            var b_25 : Box_0 = chunk_box_0(c_7, rel_2);
            var kc_1 : f32 = contact_stiffness_0(_S147.mat_0.x, _S149, chunks_0[c_7].cmat_0.x, b_25, b_25.center_1 - _S149.center_1);
            var _S150 : f32 = _S147.crush_0.w;
            var _S151 : Box_0 = impactor_shrunk_0(_S146, _S150, _S149);
            var _S152 : u32 = impactor_contact_count_0(_S146, _S150, _S151, b_25);
            var _S153 : f32;
            if((_S147.shape_0.x) == 0.0f)
            {
                _S153 = kc_1;
            }
            else
            {
                _S153 = kc_1 / max(f32(_S152), 10.0f);
            }
            var j_5 : u32 = u32(0);
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            loop
            {
                if(_S152 > u32(0))
                {
                    var _S154 : u32 = impactor_slots_2(&(_S147), b_25);
                    _S144 = j_5 < _S154;
                }
                else
                {
                    _S144 = false;
                }
                if(_S144)
                {
                }
                else
                {
                    break;
                }
                var p_9 : vec3<f32>;
                var nrm_1 : vec3<f32>;
                var dep_1 : f32;
                var _S155 : bool = impactor_contact_1(&(_S147), _S150, _S151, b_25, j_5, &(p_9), &(nrm_1), &(dep_1));
                if(!_S155)
                {
                    j_5 = j_5 + u32(1);
                    continue;
                }
                var ksum_1 : f32 = ksum_0 + _S153;
                total_0 = total_0 + _S153 * dep_1;
                ksum_0 = ksum_1;
                j_5 = j_5 + u32(1);
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
    scratch_0[params_0.cand_base_0 + _S145] = vec4<f32>(total_0, ksum_0, scratch_0[params_0.cand_base_0 + _S145].z, scratch_0[params_0.cand_base_0 + _S145].w);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_crush(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var ii_0 : u32 = group_0.x;
    var tid_3 : u32 = thread_0.x;
    var _S156 : bool;
    if(ii_0 >= (params_0.impactor_count_0))
    {
        _S156 = true;
    }
    else
    {
        _S156 = stopped_0();
    }
    if(_S156)
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
    imp_6.rotation_err_1 = impactors_0[ii_0].rotation_err_1;
    imp_6.ledger_0 = impactors_0[ii_0].ledger_0;
    imp_6.cand_0 = impactors_0[ii_0].cand_0;
    imp_6.momentum_1 = impactors_0[ii_0].momentum_1;
    imp_6.momentum_err_1 = impactors_0[ii_0].momentum_err_1;
    var _S157 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S157;
    var unused_0 : vec4<f32> = _S157;
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
    group_sum2_0(tid_3, &(shares_0), &(unused_0));
    if(tid_3 != u32(0))
    {
        _S156 = true;
    }
    else
    {
        _S156 = (imp_6.cand_0.z) != u32(0);
    }
    if(_S156)
    {
        return;
    }
    imp_6.geom_0 = vec4<f32>(1.0f, imp_6.crush_0.w, 0.0f, 0.0f);
    var total_1 : f32 = shares_0.x;
    if((imp_6.crush_0.x) > 0.0f)
    {
        _S156 = (imp_6.crush_0.z) < (imp_6.crush_0.y);
    }
    else
    {
        _S156 = false;
    }
    if(_S156)
    {
        _S156 = total_1 > (imp_6.crush_0.x);
    }
    else
    {
        _S156 = false;
    }
    if(_S156)
    {
        var extra_0 : f32 = (total_1 - imp_6.crush_0.x) / shares_0.y;
        imp_6.crush_0[i32(3)] = imp_6.crush_0[i32(3)] + extra_0;
        imp_6.crush_0[i32(2)] = imp_6.crush_0[i32(2)] + imp_6.crush_0.x * extra_0;
        var _S158 : f32 = imp_6.crush_0.x * extra_0;
        var _S159 : f32 = imp_6.ledger_0[i32(2)];
        var _S160 : f32 = imp_6.ledger_0[i32(3)];
        comp_add1_2(&(_S159), &(_S160), _S158);
        imp_6.ledger_0[i32(2)] = _S159;
        imp_6.ledger_0[i32(3)] = _S160;
        var _S161 : f32 = imp_6.crush_0.x * extra_0;
        var _S162 : f32 = imp_6.ledger_0[i32(0)];
        var _S163 : f32 = imp_6.ledger_0[i32(1)];
        comp_add1_2(&(_S162), &(_S163), _S161);
        imp_6.ledger_0[i32(0)] = _S162;
        imp_6.ledger_0[i32(1)] = _S163;
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
    impactors_0[ii_0].rotation_err_1 = imp_6.rotation_err_1;
    impactors_0[ii_0].ledger_0 = imp_6.ledger_0;
    impactors_0[ii_0].cand_0 = imp_6.cand_0;
    impactors_0[ii_0].momentum_1 = imp_6.momentum_1;
    impactors_0[ii_0].momentum_err_1 = imp_6.momentum_err_1;
    return;
}

fn comp_add_0( sum_3 : ptr<function, vec3<f32>>,  err_3 : ptr<function, vec3<f32>>,  x_10 : vec3<f32>)
{
    var t_4 : vec3<f32> = (*sum_3) + x_10;
    var _S164 : vec3<f32> = abs(x_10);
    (*err_3) = (*err_3) + (select(x_10, (*sum_3), (abs((*sum_3))) >= _S164) - t_4 + select((*sum_3), x_10, (abs((*sum_3))) >= _S164));
    (*sum_3) = t_4;
    return;
}

fn inverse_rotate_0( q_10 : Quat_0,  v_5 : vec3<f32>) -> vec3<f32>
{
    var c_8 : Quat_0;
    c_8.w_0 = q_10.w_0;
    c_8.x_2 = - q_10.x_2;
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

fn turn_minus_one_0( axis_4 : vec3<f32>,  angle_1 : f32) -> vec4<f32>
{
    var s_3 : f32 = sin(0.25f * angle_1);
    return vec4<f32>(axis_4 * vec3<f32>(sin(0.5f * angle_1)), -2.0f * s_3 * s_3);
}

fn quat_vec_0( q_12 : Quat_0) -> vec4<f32>
{
    return vec4<f32>(q_12.x_2, q_12.y_1, q_12.z_0, q_12.w_0);
}

fn comp_add4_0( sum_4 : ptr<function, vec4<f32>>,  err_4 : ptr<function, vec4<f32>>,  x_11 : vec4<f32>)
{
    var t_5 : vec4<f32> = (*sum_4) + x_11;
    var _S165 : vec4<f32> = abs(x_11);
    (*err_4) = (*err_4) + (select(x_11, (*sum_4), (abs((*sum_4))) >= _S165) - t_5 + select((*sum_4), x_11, (abs((*sum_4))) >= _S165));
    (*sum_4) = t_5;
    return;
}

fn quat_accumulate_0( hi_1 : ptr<function, Quat_0>,  lo_1 : ptr<function, vec4<f32>>,  x_12 : vec4<f32>)
{
    var sum_5 : vec4<f32> = quat_vec_0((*hi_1));
    comp_add4_0(&(sum_5), &((*lo_1)), x_12);
    var t_6 : vec4<f32> = sum_5 + (*lo_1);
    (*lo_1) = (*lo_1) - (t_6 - sum_5);
    (*hi_1) = quat_of_0(t_6);
    return;
}

fn turn_left_0( hi_2 : ptr<function, Quat_0>,  lo_2 : ptr<function, vec4<f32>>,  omega_0 : vec3<f32>,  dt_3 : f32)
{
    var _S166 : f32 = length(omega_0);
    var angle_2 : f32 = _S166 * dt_3;
    if(angle_2 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_15 : vec4<f32> = turn_minus_one_0(omega_0 / vec3<f32>(_S166), angle_2);
    var dq_0 : Quat_0;
    dq_0.x_2 = d_15.x;
    dq_0.y_1 = d_15.y;
    dq_0.z_0 = d_15.z;
    dq_0.w_0 = d_15.w;
    quat_accumulate_0(&((*hi_2)), &((*lo_2)), quat_vec_0(quat_mul_0(dq_0, (*hi_2))));
    return;
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
    imp_7.rotation_err_1 = impactors_0[ii_1].rotation_err_1;
    imp_7.ledger_0 = impactors_0[ii_1].ledger_0;
    imp_7.cand_0 = impactors_0[ii_1].cand_0;
    imp_7.momentum_1 = impactors_0[ii_1].momentum_1;
    imp_7.momentum_err_1 = impactors_0[ii_1].momentum_err_1;
    var _S167 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S168 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S168 = true;
    }
    else
    {
        var _S169 : u32 = _S167.y;
        if(_S169 != u32(0))
        {
            _S168 = (imp_7.cand_0.w) >= _S169;
        }
        else
        {
            _S168 = false;
        }
    }
    if(_S168)
    {
        return;
    }
    if((imp_7.cand_0.z) != u32(0))
    {
        if(tid_4 == u32(0))
        {
            impactors_0[ii_1].cand_0[i32(3)] = imp_7.cand_0.w + u32(1);
        }
        return;
    }
    var _S170 : vec4<f32> = vec4<f32>(0.0f);
    var rf_0 : vec4<f32> = _S170;
    var rt_0 : vec4<f32> = _S170;
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
        var _S171 : u32 = u32(3) * k_10;
        rf_0 = rf_0 + scratch_0[params_0.cand_base_0 + _S171 + u32(1)];
        rt_0 = rt_0 + scratch_0[params_0.cand_base_0 + _S171 + u32(2)];
        k_10 = k_10 + u32(256);
    }
    group_sum2_0(tid_4, &(rf_0), &(rt_0));
    if(tid_4 != u32(0))
    {
        return;
    }
    var dt_4 : f32 = params_0.dt_0;
    var _S172 : vec3<f32> = vec3<f32>(0.0f);
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((params_0.has_ground_0) != u32(0))
    {
        var ib_0 : Box_0 = impactor_box_0(imp_7, _S172, imp_7.half_1.xyz);
        var _S173 : vec3<f32> = imp_7.velocity_1.xyz + imp_7.velocity_err_1.xyz;
        const _S174 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var kc_2 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_7.mat_0.x, ib_0, _S174);
        var _S175 : f32 = imp_7.position_1.z - params_0.ground_hi_0 + (imp_7.position_err_1.z - params_0.ground_lo_0);
        var total_points_0 : u32;
        if((imp_7.shape_0.x) == 0.0f)
        {
            total_points_0 = u32(1);
        }
        else
        {
            total_points_0 = u32(14);
        }
        var _S176 : f32 = kc_2 / f32(min(total_points_0, u32(5)));
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
            if((imp_7.shape_0.x) == 0.0f)
            {
                p_10 = vec3<f32>(0.0f, 0.0f, - imp_7.shape_0.y);
            }
            else
            {
                p_10 = sample_point_0(ib_0, s_4);
            }
            if((_S175 + p_10.z) < 0.0f)
            {
                below_0 = below_0 + u32(1);
            }
            s_4 = s_4 + u32(1);
        }
        if(below_0 > u32(0))
        {
            sentinel_mark_0(u32(8));
        }
        s_4 = u32(0);
        load_f_0 = _S172;
        load_t_0 = _S172;
        loop
        {
            if(s_4 < total_points_0)
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
                p_10 = sample_point_0(ib_0, s_4);
            }
            var depth_5 : f32 = - (_S175 + p_10.z);
            if(depth_5 <= 0.0f)
            {
                s_4 = s_4 + u32(1);
                continue;
            }
            var stored_4 : f32;
            var diss_2 : f32;
            var f_3 : vec3<f32> = penalty_force_1(_S176, imp_7.mat_0.z, params_0.ground_friction_0, depth_5, _S174, _S173 + cross(imp_7.angular_velocity_1.xyz, p_10), dt_4, below_0, &(stored_4), &(diss_2));
            var load_f_1 : vec3<f32> = load_f_0 + f_3;
            var load_t_1 : vec3<f32> = load_t_0 + cross(p_10, f_3);
            var _S177 : f32 = imp_7.ledger_0[i32(0)];
            var _S178 : f32 = imp_7.ledger_0[i32(1)];
            comp_add1_2(&(_S177), &(_S178), diss_2);
            imp_7.ledger_0[i32(0)] = _S177;
            imp_7.ledger_0[i32(1)] = _S178;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_4 = s_4 + u32(1);
        }
    }
    else
    {
        load_f_0 = _S172;
        load_t_0 = _S172;
    }
    var load_f_2 : vec3<f32> = rf_0.xyz + load_f_0;
    var load_t_2 : vec3<f32> = rt_0.xyz + load_t_0;
    var m_2 : f32 = imp_7.mat_0.z;
    var vel_0 : vec3<f32> = imp_7.velocity_1.xyz;
    var vel_err_0 : vec3<f32> = imp_7.velocity_err_1.xyz;
    var _S179 : vec3<f32> = vec3<f32>(dt_4);
    comp_add_0(&(vel_0), &(vel_err_0), (load_f_2 / vec3<f32>(m_2) + params_0.gravity_0.xyz) * _S179);
    var _S180 : Quat_0 = quat_of_0(imp_7.rotation_1);
    var q_13 : Quat_0 = _S180;
    var q_err_0 : vec4<f32> = imp_7.rotation_err_1;
    var l_hi_0 : vec3<f32> = imp_7.momentum_1.xyz;
    var l_err_0 : vec3<f32> = imp_7.momentum_err_1.xyz;
    comp_add_0(&(l_hi_0), &(l_err_0), load_t_2 * _S179);
    var l_1 : vec3<f32> = l_hi_0 + l_err_0;
    var w_mid_0 : vec3<f32> = world_mul_0(_S180, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_1);
    var pos_0 : vec3<f32> = imp_7.position_1.xyz;
    var pos_err_0 : vec3<f32> = imp_7.position_err_1.xyz;
    comp_add_0(&(pos_0), &(pos_err_0), (vel_0 + vel_err_0) * _S179);
    turn_left_0(&(q_13), &(q_err_0), w_mid_0, dt_4);
    imp_7.angular_velocity_1 = vec4<f32>(world_mul_0(q_13, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_1), 0.0f);
    imp_7.rotation_1 = quat_vec_0(q_13);
    imp_7.rotation_err_1 = q_err_0;
    imp_7.momentum_1 = vec4<f32>(l_hi_0, 0.0f);
    imp_7.momentum_err_1 = vec4<f32>(l_err_0, 0.0f);
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
    impactors_0[ii_1].rotation_err_1 = imp_7.rotation_err_1;
    impactors_0[ii_1].ledger_0 = imp_7.ledger_0;
    impactors_0[ii_1].cand_0 = imp_7.cand_0;
    impactors_0[ii_1].momentum_1 = imp_7.momentum_1;
    impactors_0[ii_1].momentum_err_1 = imp_7.momentum_err_1;
    var k_11 : u32 = imp_7.cand_0.w - u32(1) - params_0.step_start_0;
    if(k_11 < (params_0.record_stride_0))
    {
        var at_3 : u32 = params_0.record_base_0 + u32(2) * (ii_1 * params_0.record_stride_0 + k_11);
        scratch_0[at_3] = vec4<f32>(vel_0 + vel_err_0, 0.0f);
        scratch_0[at_3 + u32(1)] = vec4<f32>(pos_0 + pos_err_0, 0.0f);
    }
    return;
}

fn ground_contact_0( c_9 : u32,  account_0 : bool,  f_4 : ptr<function, vec3<f32>>,  t_7 : ptr<function, vec3<f32>>)
{
    var wp_1 : WorldPoint_0 = chunk_world_0(c_9);
    var above_0 : f32 = wp_1.hi_0.z - params_0.ground_hi_0 + (wp_1.lo_0.z - params_0.ground_lo_0) + wp_1.rel_0.z;
    if((above_0 - chunks_0[c_9].half_0.w) > 0.0f)
    {
        return;
    }
    var b_26 : Box_0 = chunk_box_0(c_9, vec3<f32>(0.0f));
    const _S181 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S182 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_26, chunks_0[c_9].cmat_0.x, b_26, _S181);
    var _S183 : u32 = sample_count_0(b_26);
    var s_5 : u32 = u32(0);
    var n_8 : u32 = u32(0);
    loop
    {
        if(s_5 < _S183)
        {
        }
        else
        {
            break;
        }
        if((above_0 + sample_point_0(b_26, s_5).z) < 0.0f)
        {
            n_8 = n_8 + u32(1);
        }
        s_5 = s_5 + u32(1);
    }
    if(n_8 == u32(0))
    {
        return;
    }
    sentinel_mark_0(u32(4));
    var vc_1 : vec3<f32>;
    var wc_1 : vec3<f32>;
    chunk_velocity_1(c_9, &(vc_1), &(wc_1));
    var ledger_2 : vec4<f32> = scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_9];
    s_5 = u32(0);
    loop
    {
        if(s_5 < _S183)
        {
        }
        else
        {
            break;
        }
        var p_11 : vec3<f32> = sample_point_0(b_26, s_5);
        var _S184 : f32 = above_0 + p_11.z;
        if(!(_S184 < 0.0f))
        {
            s_5 = s_5 + u32(1);
            continue;
        }
        var stored_5 : f32;
        var diss_3 : f32;
        var g_0 : vec3<f32> = penalty_force_1(_S182 / f32(max(n_8, u32(5))), chunks_0[c_9].center_0.w, params_0.ground_friction_0, - _S184, _S181, vc_1 + cross(wc_1, p_11), params_0.dt_0, n_8, &(stored_5), &(diss_3));
        (*f_4) = (*f_4) + g_0;
        (*t_7) = (*t_7) + cross(p_11, g_0);
        var _S185 : f32 = ledger_2[i32(1)];
        var _S186 : f32 = ledger_2[i32(2)];
        comp_add1_2(&(_S185), &(_S186), diss_3);
        ledger_2[i32(1)] = _S185;
        ledger_2[i32(2)] = _S186;
        s_5 = s_5 + u32(1);
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
    var _S187 : bool;
    if(g_1 >= (params_0.seg_count_0))
    {
        _S187 = true;
    }
    else
    {
        _S187 = stopped_0();
    }
    if(_S187)
    {
        return;
    }
    var _S188 : u32 = u32(3) * g_1;
    var _S189 : u32 = index_0[params_0.seg_index_0 + _S188];
    var begin_0 : u32 = index_0[params_0.seg_index_0 + _S188 + u32(1)];
    var _S190 : u32 = index_0[params_0.seg_index_0 + _S188 + u32(2)];
    var _S191 : vec3<f32> = vec3<f32>(0.0f);
    var f_5 : vec3<f32> = _S191;
    var t_8 : vec3<f32> = _S191;
    var e_2 : u32 = begin_0;
    loop
    {
        if(e_2 < _S190)
        {
        }
        else
        {
            break;
        }
        var entry_1 : u32 = index_0[e_2];
        if(entry_1 == u32(2147483648))
        {
            ground_contact_0(_S189, true, &(f_5), &(t_8));
            e_2 = e_2 + u32(1);
            continue;
        }
        var _S192 : u32 = u32(2) * entry_1;
        f_5 = f_5 + scratch_0[params_0.slot_base_0 + _S192].xyz;
        t_8 = t_8 + scratch_0[params_0.slot_base_0 + _S192 + u32(1)].xyz;
        e_2 = e_2 + u32(1);
    }
    var _S193 : u32 = u32(2) * g_1;
    scratch_0[params_0.seg_base_0 + _S193] = vec4<f32>(f_5, 0.0f);
    scratch_0[params_0.seg_base_0 + _S193 + u32(1)] = vec4<f32>(t_8, 0.0f);
    return;
}

var<workgroup> g_seen_0 : array<u32, i32(5)>;

fn seen_clear_0( tid_5 : u32)
{
    if(tid_5 < u32(5))
    {
        g_seen_0[tid_5] = u32(0);
    }
    return;
}

fn contact_stopped_0( isl_0 : ptr<function, Island_std430_0>) -> bool
{
    var _S194 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S195 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S195 = true;
    }
    else
    {
        var _S196 : u32 = _S194.y;
        if(_S196 != u32(0))
        {
            _S195 = _S196 <= ((*isl_0).info_0.w);
        }
        else
        {
            _S195 = false;
        }
    }
    return _S195;
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
     done_0 : u32,
     coverage_0 : u32,
     wide_groups_0 : u32,
     done_pad_0 : u32,
     probes_0 : vec4<u32>,
     energy_0 : vec4<f32>,
     rotation_err_0 : vec4<f32>,
     momentum_0 : vec4<f32>,
     momentum_err_0 : vec4<f32>,
};

fn contact_stopped_1( isl_1 : Island_0) -> bool
{
    var _S197 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S198 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S198 = true;
    }
    else
    {
        var _S199 : u32 = _S197.y;
        if(_S199 != u32(0))
        {
            _S198 = _S199 <= (isl_1.info_0.w);
        }
        else
        {
            _S198 = false;
        }
    }
    return _S198;
}

var<workgroup> g_run_0 : u32;

var<workgroup> g_halt_0 : u32;

struct Rigid_0
{
     rot_0 : Quat_0,
     rot_err_0 : vec4<f32>,
     pos_1 : vec3<f32>,
     pos_err_1 : vec3<f32>,
     vel_1 : vec3<f32>,
     vel_err_1 : vec3<f32>,
     w_4 : vec3<f32>,
     l_2 : vec3<f32>,
     l_err_1 : vec3<f32>,
     torque_0 : vec3<f32>,
     a_8 : vec3<f32>,
     alpha_0 : vec3<f32>,
};

fn rigid_of_0( isl_2 : ptr<function, Island_std430_0>) -> Rigid_0
{
    var rg_0 : Rigid_0;
    rg_0.rot_0 = quat_of_0((*isl_2).rotation_0);
    rg_0.rot_err_0 = (*isl_2).rotation_err_0;
    rg_0.pos_1 = (*isl_2).position_0.xyz;
    rg_0.pos_err_1 = (*isl_2).position_err_0.xyz;
    rg_0.vel_1 = (*isl_2).velocity_0.xyz;
    rg_0.vel_err_1 = (*isl_2).velocity_err_0.xyz;
    rg_0.w_4 = (*isl_2).angular_velocity_0.xyz;
    rg_0.l_2 = (*isl_2).momentum_0.xyz;
    rg_0.l_err_1 = (*isl_2).momentum_err_0.xyz;
    var _S200 : vec3<f32> = vec3<f32>(0.0f);
    rg_0.torque_0 = _S200;
    rg_0.a_8 = _S200;
    rg_0.alpha_0 = _S200;
    return rg_0;
}

fn rigid_of_1( isl_3 : Island_0) -> Rigid_0
{
    var rg_1 : Rigid_0;
    rg_1.rot_0 = quat_of_0(isl_3.rotation_0);
    rg_1.rot_err_0 = isl_3.rotation_err_0;
    rg_1.pos_1 = isl_3.position_0.xyz;
    rg_1.pos_err_1 = isl_3.position_err_0.xyz;
    rg_1.vel_1 = isl_3.velocity_0.xyz;
    rg_1.vel_err_1 = isl_3.velocity_err_0.xyz;
    rg_1.w_4 = isl_3.angular_velocity_0.xyz;
    rg_1.l_2 = isl_3.momentum_0.xyz;
    rg_1.l_err_1 = isl_3.momentum_err_0.xyz;
    var _S201 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.torque_0 = _S201;
    rg_1.a_8 = _S201;
    rg_1.alpha_0 = _S201;
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
        var _S202 : u32 = offset_0 + i_4;
        var b_27 : vec4<f32> = loads_0[_S202];
        var _S203 : f32 = b_27.x;
        if(tau_0 <= _S203)
        {
            var a_9 : vec4<f32> = loads_0[_S202 - u32(1)];
            var _S204 : f32 = a_9.x;
            var _S205 : f32 = a_9.y;
            return _S205 + (tau_0 - _S204) / max(_S203 - _S204, 1.00000000317107685e-30f) * (b_27.y - _S205);
        }
        i_4 = i_4 + u32(1);
    }
    return loads_0[offset_0 + count_2 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_13 : u32,  dt_6 : f32,  shift_0 : f32) -> f32
{
    var _S206 : u32 = u32(5) * term_0;
    var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S206])));
    var origin_1 : vec4<f32> = loads_0[_S206 + u32(3)];
    var p_12 : vec4<f32> = loads_0[_S206 + u32(4)];
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
            var _S207 : f32 = p_12.x;
            if(tau_1 >= _S207)
            {
                shape_1 = p_12.y;
            }
            else
            {
                shape_1 = p_12.y * tau_1 / _S207;
            }
        }
        return shape_1;
    }
    var _S208 : bool;
    if(kind_0 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S208 = true;
        }
        else
        {
            _S208 = tau_1 > (p_12.x);
        }
        if(_S208)
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
            _S208 = true;
        }
        else
        {
            _S208 = sn_0 > 1.0f;
        }
        if(_S208)
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
        g_seen_0[u32(1)] = u32(1);
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var sn_1 : f32 = tau_1 / p_12.x;
        if(sn_1 < 0.0f)
        {
            _S208 = true;
        }
        else
        {
            _S208 = sn_1 > 1.0f;
        }
        if(_S208)
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
        var _S209 : f32 = p_12.w;
        return (_S209 + (p_12.z - _S209) * relax_0) * shape_1;
    }
    if(kind_0 == u32(7))
    {
        g_seen_0[u32(2)] = u32(1);
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var _S210 : f32 = p_12.y;
        if(tau_1 < _S210)
        {
            return p_12.x;
        }
        var s_6 : f32 = tau_1 - _S210;
        var _S211 : f32 = p_12.w;
        if(s_6 > _S211)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_12.z * sin(3.14159274101257324f * s_6 / _S211);
        }
        return shape_1;
    }
    var _S212 : f32 = p_12.x;
    if(_S212 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S212, 0.0f, 1.0f);
}

fn record_chunk_load_0( c_10 : u32,  f_6 : vec3<f32>,  t_9 : vec3<f32>)
{
    if((params_0.solve_mode_0) == u32(0))
    {
        return;
    }
    var _S213 : u32 = u32(2) * c_10;
    scratch_0[params_0.cload_base_0 + _S213] = vec4<f32>(f_6, 0.0f);
    scratch_0[params_0.cload_base_0 + _S213 + u32(1)] = vec4<f32>(t_9, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S213] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S213].xyz + f_6, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S213 + u32(1)] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S213 + u32(1)].xyz + t_9, 0.0f);
    return;
}

fn chunk_loads_0( _S214 : u32,  _S215 : u32,  _S216 : Quat_0,  _S217 : u32,  _S218 : f32,  _S219 : bool,  _S220 : f32,  _S221 : ptr<function, vec3<f32>>,  _S222 : ptr<function, vec3<f32>>,  _S223 : ptr<function, vec3<f32>>,  _S224 : ptr<function, vec3<f32>>)
{
    var _S225 : bool;
    var _S226 : vec3<f32> = vec3<f32>(0.0f);
    (*_S221) = _S226;
    (*_S222) = _S226;
    (*_S223) = _S226;
    (*_S224) = _S226;
    var _S227 : vec4<u32> = chunks_0[_S215].load_range_0;
    var term_1 : u32 = chunks_0[_S215].load_range_0.x;
    loop
    {
        if(term_1 < (_S227.y))
        {
        }
        else
        {
            break;
        }
        g_seen_0[u32(0)] = u32(1);
        var _S228 : u32 = u32(5) * term_1;
        var _S229 : u32 = (bitcast<vec4<u32>>((loads_0[_S228]))).y;
        var replacement_0 : bool = _S229 == u32(2);
        var dir_1 : vec4<f32> = loads_0[_S228 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S228 + u32(2)];
        var _S230 : f32;
        if(replacement_0)
        {
            _S230 = _S220;
        }
        else
        {
            _S230 = 0.0f;
        }
        var value_0 : f32 = eval_function_0(term_1, _S217, _S218, _S230);
        if(replacement_0)
        {
            var _S231 : vec3<f32> = vec3<f32>(value_0);
            (*_S223) = (*_S223) + dir_1.xyz * _S231;
            (*_S224) = (*_S224) + arm_0.xyz * _S231;
            term_1 = term_1 + u32(1);
            continue;
        }
        if(_S229 == u32(0))
        {
            _S225 = true;
        }
        else
        {
            _S225 = _S229 == u32(3);
        }
        var fw_0 : vec3<f32>;
        if(_S225)
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_0);
        }
        else
        {
            fw_0 = rotate_0(_S216, dir_1.xyz) * vec3<f32>((- value_0 * dir_1.w));
        }
        var lever_0 : vec3<f32>;
        if(_S229 == u32(3))
        {
            lever_0 = arm_0.xyz - state_0[u32(4) * _S214].xyz;
        }
        else
        {
            lever_0 = arm_0.xyz;
        }
        (*_S221) = (*_S221) + fw_0;
        (*_S222) = (*_S222) + cross(rotate_0(_S216, lever_0), fw_0);
        term_1 = term_1 + u32(1);
    }
    if(_S219)
    {
        _S225 = (chunks_0[_S215].cinfo_0.z) != u32(0);
    }
    else
    {
        _S225 = false;
    }
    if(_S225)
    {
        var _S232 : vec4<u32> = chunks_0[_S215].cinfo_0;
        var g_2 : u32 = chunks_0[_S215].cinfo_0.x;
        loop
        {
            if(g_2 < (_S232.y))
            {
            }
            else
            {
                break;
            }
            var _S233 : u32 = u32(2) * g_2;
            (*_S221) = (*_S221) + scratch_0[params_0.seg_base_0 + _S233].xyz;
            (*_S222) = (*_S222) + scratch_0[params_0.seg_base_0 + _S233 + u32(1)].xyz;
            g_2 = g_2 + u32(1);
        }
    }
    return;
}

fn chunk_external_0( _S234 : u32,  _S235 : u32,  _S236 : Quat_0,  _S237 : u32,  _S238 : f32,  _S239 : bool,  _S240 : ptr<function, vec3<f32>>,  _S241 : ptr<function, vec3<f32>>)
{
    var rf_1 : vec3<f32>;
    var rm_0 : vec3<f32>;
    chunk_loads_0(_S234, _S235, _S236, _S237, _S238, _S239, 0.0f, &((*_S240)), &((*_S241)), &(rf_1), &(rm_0));
    return;
}

fn settled_chunk_load_0( c_11 : u32,  rot_1 : Quat_0,  k_14 : u32,  dt_7 : f32,  contact_0 : bool) -> f32
{
    var f_7 : vec3<f32>;
    var t_10 : vec3<f32>;
    chunk_external_0(c_11, c_11, rot_1, k_14, dt_7, contact_0, &(f_7), &(t_10));
    record_chunk_load_0(c_11, f_7, t_10);
    return length(f_7);
}

fn net_load_0( c_12 : u32,  isl_4 : ptr<function, Island_std430_0>,  rg_2 : Rigid_0,  k_15 : u32,  dt_8 : f32,  contact_1 : bool,  f_8 : ptr<function, vec3<f32>>,  t_11 : ptr<function, vec3<f32>>)
{
    var fl_0 : vec3<f32>;
    var tl_0 : vec3<f32>;
    var rep_f_0 : vec3<f32>;
    var rep_m_0 : vec3<f32>;
    chunk_loads_0(c_12, c_12, rg_2.rot_0, k_15, dt_8, contact_1, 0.0f, &(fl_0), &(tl_0), &(rep_f_0), &(rep_m_0));
    var fc_0 : vec3<f32> = fl_0 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_12].center_0.w);
    var _S242 : vec3<f32> = chunks_0[c_12].center_0.xyz;
    var _S243 : vec3<f32> = (*isl_4).com_0.xyz;
    var r_6 : vec3<f32> = rotate_0(rg_2.rot_0, _S242 + state_0[u32(4) * c_12].xyz - _S243);
    (*f_8) = (*f_8) + fc_0;
    (*t_11) = (*t_11) + (cross(r_6, fc_0) + tl_0);
    if((chunks_0[c_12].load_range_0.y) > (chunks_0[c_12].load_range_0.x))
    {
        var fw_1 : vec3<f32> = rotate_0(rg_2.rot_0, rep_f_0);
        (*f_8) = (*f_8) + fw_1;
        (*t_11) = (*t_11) + (cross(rotate_0(rg_2.rot_0, _S242 - _S243), fw_1) + rotate_0(rg_2.rot_0, rep_m_0));
    }
    return;
}

fn net_load_1( c_13 : u32,  isl_5 : Island_0,  rg_3 : Rigid_0,  k_16 : u32,  dt_9 : f32,  contact_2 : bool,  f_9 : ptr<function, vec3<f32>>,  t_12 : ptr<function, vec3<f32>>)
{
    var fl_1 : vec3<f32>;
    var tl_1 : vec3<f32>;
    var rep_f_1 : vec3<f32>;
    var rep_m_1 : vec3<f32>;
    chunk_loads_0(c_13, c_13, rg_3.rot_0, k_16, dt_9, contact_2, 0.0f, &(fl_1), &(tl_1), &(rep_f_1), &(rep_m_1));
    var fc_1 : vec3<f32> = fl_1 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_13].center_0.w);
    var _S244 : vec3<f32> = chunks_0[c_13].center_0.xyz;
    var _S245 : vec3<f32> = isl_5.com_0.xyz;
    var r_7 : vec3<f32> = rotate_0(rg_3.rot_0, _S244 + state_0[u32(4) * c_13].xyz - _S245);
    (*f_9) = (*f_9) + fc_1;
    (*t_12) = (*t_12) + (cross(r_7, fc_1) + tl_1);
    if((chunks_0[c_13].load_range_0.y) > (chunks_0[c_13].load_range_0.x))
    {
        var fw_2 : vec3<f32> = rotate_0(rg_3.rot_0, rep_f_1);
        (*f_9) = (*f_9) + fw_2;
        (*t_12) = (*t_12) + (cross(rotate_0(rg_3.rot_0, _S244 - _S245), fw_2) + rotate_0(rg_3.rot_0, rep_m_1));
    }
    return;
}

fn rigid_acceleration_0( isl_6 : ptr<function, Island_std430_0>,  rg_4 : ptr<function, Rigid_0>,  f_10 : vec3<f32>,  t_13 : vec3<f32>)
{
    var iw_w_0 : vec3<f32> = world_mul_0((*rg_4).rot_0, (*isl_6).inertia0_0, (*isl_6).inertia1_0, (*isl_6).inertia2_0, (*rg_4).w_4);
    (*rg_4).a_8 = f_10 / vec3<f32>((*isl_6).com_0.w);
    (*rg_4).alpha_0 = world_mul_0((*rg_4).rot_0, (*isl_6).inv0_0, (*isl_6).inv1_0, (*isl_6).inv2_0, t_13 - cross((*rg_4).w_4, iw_w_0));
    (*rg_4).torque_0 = t_13;
    return;
}

fn rigid_acceleration_1( isl_7 : Island_0,  rg_5 : ptr<function, Rigid_0>,  f_11 : vec3<f32>,  t_14 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_5).rot_0, isl_7.inertia0_0, isl_7.inertia1_0, isl_7.inertia2_0, (*rg_5).w_4);
    (*rg_5).a_8 = f_11 / vec3<f32>(isl_7.com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_0, isl_7.inv0_0, isl_7.inv1_0, isl_7.inv2_0, t_14 - cross((*rg_5).w_4, iw_w_1));
    (*rg_5).torque_0 = t_14;
    return;
}

fn is_damaged_0( st_0 : ptr<function, JointState_std430_0>) -> bool
{
    var _S246 : bool;
    if(((*st_0).damage_0) > 0.0f)
    {
        _S246 = true;
    }
    else
    {
        _S246 = ((*st_0).crush_1) > 0.0f;
    }
    return _S246;
}

struct JointState_0
{
     damage_0 : f32,
     crush_1 : f32,
     kappa_0 : f32,
     kappa_c_0 : f32,
     ductility_0 : f32,
     ductility_c_0 : f32,
     life_0 : f32,
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

fn is_damaged_1( st_1 : JointState_0) -> bool
{
    var _S247 : bool;
    if((st_1.damage_0) > 0.0f)
    {
        _S247 = true;
    }
    else
    {
        _S247 = (st_1.crush_1) > 0.0f;
    }
    return _S247;
}

fn connected_0( st_2 : ptr<function, JointState_std430_0>,  has_rebar_0 : bool) -> bool
{
    var _S248 : bool;
    if(((*st_2).damage_0) < 1.0f)
    {
        _S248 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S248 = ((*st_2).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S248 = false;
        }
    }
    return _S248;
}

fn connected_1( st_3 : JointState_0,  has_rebar_1 : bool) -> bool
{
    var _S249 : bool;
    if((st_3.damage_0) < 1.0f)
    {
        _S249 = true;
    }
    else
    {
        if(has_rebar_1)
        {
            _S249 = (st_3.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S249 = false;
        }
    }
    return _S249;
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
    var _S250 : f32 = q_lin_0.z;
    var axial_0 : f32 = fdiv_0(_S250, area_2);
    var bending_0 : f32 = fdiv_0(abs(q_ang_0.x), (*b_29).geom1_0.x) + fdiv_0(abs(q_ang_0.y), (*b_29).geom1_0.y);
    var _S251 : f32 = q_lin_0.x;
    var _S252 : f32 = q_lin_0.y;
    var shear_1 : f32 = fdiv_0(fsqrt_0(_S251 * _S251 + _S252 * _S252), area_2) + fdiv_0(abs(q_ang_0.z), (*b_29).geom0_0.w);
    var m_3 : Measures_0;
    m_3.tension_0 = axial_0 + bending_0;
    m_3.shear_0 = shear_1;
    var _S253 : f32 = - axial_0;
    m_3.normal_compression_0 = max(_S253, 0.0f);
    m_3.compression_0 = _S253 + bending_0;
    m_3.compressive_force_0 = max(- _S250, 0.0f);
    return m_3;
}

fn expm1_accurate_0( x_13 : f32) -> f32
{
    if((abs(x_13)) < 0.00100000004749745f)
    {
        return x_13 * (1.0f + x_13 * (0.5f + x_13 * 0.1666666716337204f));
    }
    return exp(x_13) - 1.0f;
}

fn fpow_0( a_12 : f32,  b_30 : f32) -> f32
{
    return pow(a_12, b_30);
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_8 : f32 = abs(strain_rate_1);
    var _S254 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_8 <= ref_0)
    {
        return 1.0f;
    }
    var _S255 : f32 = _S254.z;
    var f_12 : f32;
    if(r_8 <= _S255)
    {
        f_12 = fpow_0(fdiv_0(r_8, ref_0), _S254.y);
    }
    else
    {
        f_12 = fpow_0(fdiv_0(_S255, ref_0), _S254.y) * fpow_0(fdiv_0(r_8, _S255), _S254.w);
    }
    return clamp(f_12, 1.0f, (*mat_1).misc_0.x);
}

fn fatigue_factor_0( mat_2 : ptr<function, JointMaterial_std140_0>,  life_1 : f32) -> f32
{
    if(((((*mat_2).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return fpow_0(clamp(life_1, 0.0f, 1.0f), fdiv_0(1.0f, (*mat_2).misc_0.y - 2.0f));
}

fn fatigue_factor_1( mat_3 : ptr<function, JointMaterial_std140_0>,  life_2 : f32) -> f32
{
    if(((((*mat_3).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return fpow_0(clamp(life_2, 0.0f, 1.0f), fdiv_0(1.0f, (*mat_3).misc_0.y - 2.0f));
}

fn infinity_0() -> f32
{
    return (bitcast<f32>((u32(2139095040))));
}

fn failure_indices_0( mat_4 : ptr<function, JointMaterial_std140_0>,  b_31 : ptr<function, JointBond_std430_0>,  m_4 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_2 : f32 = (*mat_4).strength_0.y * multiplier_0;
    var _S256 : f32 = min((*mat_4).strength_0.z * multiplier_0 + (*mat_4).strength_0.w * m_4.normal_compression_0, (*mat_4).energy_1.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(fdiv_0(m_4.tension_0, (*mat_4).strength_0.x * multiplier_0), 0.0f);
    var _S257 : f32;
    if(_S256 > 0.0f)
    {
        _S257 = fdiv_0(m_4.shear_0, _S256);
    }
    else
    {
        _S257 = infinity_0();
    }
    idx_0[i32(1)] = _S257;
    idx_0[i32(2)] = max(fdiv_0(m_4.compression_0, fc_2), 0.0f);
    var _S258 : f32 = (*b_31).stiff1_0.y;
    if(_S258 > 0.0f)
    {
        _S257 = fdiv_0(m_4.compressive_force_0, _S258);
    }
    else
    {
        _S257 = 0.0f;
    }
    idx_0[i32(3)] = _S257;
    return idx_0;
}

fn sq_0( x_14 : f32) -> f32
{
    return x_14 * x_14;
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
        return min(fdiv_0(r_9 * (kappa_1 - 1.0f), kappa_1 * (r_9 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_9 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

fn damage_increment_0( kind_2 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_10 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S259 : f32 = max(damage_law_0(kind_2, lambda_0, r_10), d_old_0);
    var _S260 : bool;
    if(_S259 <= d_old_0)
    {
        _S260 = true;
    }
    else
    {
        _S260 = d_old_0 >= 1.0f;
    }
    if(_S260)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = fdiv_0(psi_0, lambda_0 * lambda_0);
    var _S261 : f32 = max(kappa_old_0, 1.0f);
    if(kind_2 == u32(0))
    {
        if(r_10 > 1.0f)
        {
            return vec2<f32>(_S259, fdiv_0(u0_0 * r_10, r_10 - 1.0f) * max(min(lambda_0, r_10) - min(_S261, r_10), 0.0f));
        }
        return vec2<f32>(_S259, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_10 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S261, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S259 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S259, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_3 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S262 : f32 = - h0_0;
    var _S263 : f32 = - h1_0;
    var _S264 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S262, _S263), vec2<f32>(h0_0, _S263), vec2<f32>(h0_0, h1_0), vec2<f32>(_S262, h1_0) );
    var poly_0 : array<vec2<f32>, i32(8)>;
    var i_5 : u32 = u32(0);
    var count_4 : u32 = u32(0);
    loop
    {
        if(i_5 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S265 : u32 = i_5;
        var _S266 : u32 = i_5 + u32(1);
        var _S267 : u32 = _S266 % u32(4);
        var _S268 : f32 = _S264[i_5].y;
        var _S269 : f32 = _S264[i_5].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S268 - ay_0 * _S269;
        var _S270 : f32 = _S264[_S267].y;
        var _S271 : f32 = _S264[_S267].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S270 - ay_0 * _S271;
        var _S272 : bool = fp_0 < 0.0f;
        if(_S272)
        {
            var _S273 : u32 = count_4 + u32(1);
            poly_0[count_4] = _S264[_S265];
            count_3 = _S273;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S272 != (fq_0 < 0.0f))
        {
            var t_15 : f32 = fp_0 / (fp_0 - fq_0);
            var _S274 : u32 = count_3 + u32(1);
            poly_0[count_3] = vec2<f32>(_S269 + t_15 * (_S271 - _S269), _S268 + t_15 * (_S270 - _S268));
            count_4 = _S274;
        }
        else
        {
            count_4 = count_3;
        }
        i_5 = _S266;
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
    i_5 = u32(0);
    var a_13 : f32 = 0.0f;
    var sx_0 : f32 = 0.0f;
    var sy_0 : f32 = 0.0f;
    var ixx_0 : f32 = 0.0f;
    var iyy_0 : f32 = 0.0f;
    var ixy_0 : f32 = 0.0f;
    loop
    {
        if(i_5 < count_4)
        {
        }
        else
        {
            break;
        }
        var _S275 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_5].x - _S275;
        var _S276 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_5].y - _S276;
        var _S277 : u32 = i_5 + u32(1);
        var _S278 : u32 = _S277 % count_4;
        var x1_0 : f32 = poly_0[_S278].x - _S275;
        var y1_0 : f32 = poly_0[_S278].y - _S276;
        var _S279 : f32 = x0_0 * y1_0;
        var _S280 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S279 - _S280;
        var a_14 : f32 = a_13 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S279 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S280) * cr_0 / 24.0f;
        i_5 = _S277;
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
    var _S281 : f32 = a_13 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S281 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_13 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S281 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_11 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_11));
    var a_15 : f32 = r_11[i32(0)];
    if((r_11[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_17 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_3 : f32 = dz_1 + ax_1 * r_11[i32(2)] - ay_1 * r_11[i32(1)];
    var _S282 : f32 = a_15 * fc_3;
    var _S283 : f32 = - ay_1;
    return vec4<f32>(k_17 * a_15 * fc_3, k_17 * (_S282 * r_11[i32(2)] + (_S283 * r_11[i32(5)] + ax_1 * r_11[i32(4)])), - k_17 * (_S282 * r_11[i32(1)] + (_S283 * r_11[i32(3)] + ax_1 * r_11[i32(5)])), 0.5f * k_17 * (_S282 * fc_3 + ay_1 * ay_1 * r_11[i32(3)] + ax_1 * ax_1 * r_11[i32(4)] - 2.0f * ax_1 * ay_1 * r_11[i32(5)]));
}

fn signum_0( x_15 : f32) -> f32
{
    var _S284 : f32;
    if((((bitcast<u32>((x_15))) & (u32(2147483648)))) != u32(0))
    {
        _S284 = -1.0f;
    }
    else
    {
        _S284 = 1.0f;
    }
    return _S284;
}

fn return_map_0( k_18 : f32,  total_2 : f32,  plastic_0 : f32,  cap_0 : f32) -> vec2<f32>
{
    var trial_0 : f32 = k_18 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return vec2<f32>(trial_0, 0.0f);
    }
    var f_13 : f32 = cap_0 * signum_0(trial_0);
    return vec2<f32>(f_13, fdiv_0(trial_0 - f_13, k_18));
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
    var _S285 : vec3<f32> = vec3<f32>(0.0f);
    c_14.q_lin_1 = _S285;
    c_14.q_ang_1 = _S285;
    c_14.energy_2 = 0.0f;
    c_14.diss_4 = 0.0f;
    c_14.plastic_1 = plastic_2;
    var _S286 : u32 = (*mat_5).kind_flags_0.y;
    if(((_S286 & (u32(2)))) == u32(0))
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
    if(((_S286 & (u32(4)))) != u32(0))
    {
        var p_13 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S287 : f32 = p_13.y;
        var _S288 : f32 = p_13.z;
        var _S289 : f32 = p_13.w;
        nc_sum_0 = p_13.x;
        m1_0 = _S287;
        m2_0 = _S288;
        energy_3 = _S289;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S290 : f32 = d_ang_0.x;
        var _S291 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S290) * 0.4166666567325592f * w1_2 + abs(_S291) * 0.4166666567325592f * w0_2;
        var _S292 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S292) + spread_0);
        if((_S292 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S292 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S293 : f32 = ki_0 * _S290 * i2_0;
                var _S294 : f32 = ki_0 * _S291 * i1_0;
                var _S295 : f32 = 0.5f * ki_0 * (36.0f * _S292 * _S292 + _S290 * _S290 * i2_0 + _S291 * _S291 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S292;
                m1_0 = _S293;
                m2_0 = _S294;
                energy_3 = _S295;
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
                    var _S296 : f32 = SPRING_AT_0[i_6] * w0_2;
                    var j_6 : u32 = u32(0);
                    nc_sum_0 = diss_5;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    loop
                    {
                        if(j_6 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var s2_0 : f32 = SPRING_AT_0[j_6] * w1_2;
                        var di_0 : f32 = _S292 + _S290 * s2_0 - _S291 * _S296;
                        if(di_0 < 0.0f)
                        {
                            var f_14 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_14 * s2_0;
                            var m2_2 : f32 = m2_0 - f_14 * _S296;
                            var energy_5 : f32 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_14;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_6 = j_6 + u32(1);
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
    var p_14 : vec3<f32> = plastic_2;
    c_14.q_lin_1 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_14.q_ang_1 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_5).strength_0.w * nc_0;
    var _S297 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S298 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var tn_0 : f32 = fsqrt_0(_S297 * _S297 + _S298 * _S298);
    var _S299 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S299 = tn_0 > 0.0f;
    }
    else
    {
        _S299 = false;
    }
    if(_S299)
    {
        var _S300 : f32 = fdiv_0(_S297, tn_0);
        var _S301 : f32 = fdiv_0(_S298, tn_0);
        var dslip_0 : f32 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        p_14[i32(0)] = p_14[i32(0)] + _S300 * dslip_0;
        p_14[i32(1)] = p_14[i32(1)] + _S301 * dslip_0;
        c_14.q_lin_1[i32(0)] = _S300 * slide_cap_0;
        c_14.q_lin_1[i32(1)] = _S301 * slide_cap_0;
        diss_5 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_14.q_lin_1[i32(0)] = _S297;
        c_14.q_lin_1[i32(1)] = _S298;
        diss_5 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_14.z, slide_cap_0 * (*b_32).geom1_0.z);
    var _S302 : f32 = tq_0.x;
    var _S303 : f32 = tq_0.y;
    var diss_6 : f32 = diss_5 + abs(_S302) * abs(_S303);
    p_14[i32(2)] = p_14[i32(2)] + _S303;
    c_14.q_ang_1[i32(2)] = _S302;
    c_14.energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0(c_14.q_lin_1.x), ks_0) + fdiv_0(sq_0(c_14.q_lin_1.y), ks_0) + fdiv_0(sq_0(_S302), kt_0));
    c_14.diss_4 = diss_6;
    c_14.plastic_1 = p_14;
    return c_14;
}

fn contact_offsets_0( mat_6 : ptr<function, JointMaterial_std140_0>,  b_33 : ptr<function, JointBond_std430_0>,  crush_3 : f32,  plastic_3 : vec3<f32>,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>) -> vec3<f32>
{
    var _S304 : u32 = (*mat_6).kind_flags_0.y;
    if(((_S304 & (u32(2)))) == u32(0))
    {
        return plastic_3;
    }
    var kn_2 : f32 = (*b_33).stiff0_0.x;
    var ks_1 : f32 = (*b_33).stiff0_0.y;
    var kt_1 : f32 = (*b_33).stiff1_0.x;
    var w0_3 : f32 = (*b_33).geom0_0.y;
    var w1_3 : f32 = (*b_33).geom0_0.z;
    var nc_sum_1 : f32;
    if(((_S304 & (u32(4)))) != u32(0))
    {
        var _S305 : vec4<f32> = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        nc_sum_1 = _S305.x;
    }
    else
    {
        var ki_1 : f32 = kn_2 * (1.0f - crush_3) / 36.0f;
        var _S306 : f32 = d_ang_1.x;
        var _S307 : f32 = d_ang_1.y;
        var spread_1 : f32 = abs(_S306) * 0.4166666567325592f * w1_3 + abs(_S307) * 0.4166666567325592f * w0_3;
        var _S308 : f32 = d_lin_1.z;
        var slack_1 : f32 = 9.99999997475242708e-07f * (abs(_S308) + spread_1);
        if((_S308 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
        }
        else
        {
            if((_S308 + spread_1) < (- slack_1))
            {
                nc_sum_1 = ki_1 * 36.0f * _S308;
            }
            else
            {
                var i_7 : u32 = u32(0);
                var nc_sum_2 : f32 = 0.0f;
                loop
                {
                    if(i_7 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S309 : f32 = SPRING_AT_0[i_7] * w0_3;
                    var j_7 : u32 = u32(0);
                    nc_sum_1 = nc_sum_2;
                    loop
                    {
                        if(j_7 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var di_1 : f32 = _S308 + _S306 * (SPRING_AT_0[j_7] * w1_3) - _S307 * _S309;
                        if(di_1 < 0.0f)
                        {
                            nc_sum_1 = nc_sum_1 + ki_1 * di_1;
                        }
                        j_7 = j_7 + u32(1);
                    }
                    i_7 = i_7 + u32(1);
                    nc_sum_2 = nc_sum_1;
                }
                nc_sum_1 = nc_sum_2;
            }
        }
    }
    var nc_1 : f32 = - nc_sum_1;
    var p_15 : vec3<f32> = plastic_3;
    var slide_cap_1 : f32 = (*mat_6).strength_0.w * nc_1;
    var _S310 : f32 = ks_1 * (d_lin_1.x - plastic_3.x);
    var _S311 : f32 = ks_1 * (d_lin_1.y - plastic_3.y);
    var tn_1 : f32 = fsqrt_0(_S310 * _S310 + _S311 * _S311);
    var _S312 : bool;
    if(tn_1 > slide_cap_1)
    {
        _S312 = tn_1 > 0.0f;
    }
    else
    {
        _S312 = false;
    }
    if(_S312)
    {
        var _S313 : f32 = fdiv_0(_S311, tn_1);
        var dslip_1 : f32 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        p_15[i32(0)] = p_15[i32(0)] + fdiv_0(_S310, tn_1) * dslip_1;
        p_15[i32(1)] = p_15[i32(1)] + _S313 * dslip_1;
    }
    p_15[i32(2)] = p_15[i32(2)] + return_map_0(kt_1, d_ang_1.z, p_15.z, slide_cap_1 * (*b_33).geom1_0.z).y;
    return p_15;
}

fn life_rate_0( mat_7 : ptr<function, JointMaterial_std140_0>,  s_7 : f32) -> f32
{
    if(s_7 <= 0.0f)
    {
        return 0.0f;
    }
    var _S314 : f32 = (*mat_7).misc_0.y;
    return fdiv_0((_S314 + 1.0f) * fpow_0(s_7, _S314), (*mat_7).misc_0.z);
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
     fatigue_before_0 : f32,
     measures_0 : Measures_0,
};

fn joint_evaluate_0( mat_8 : ptr<function, JointMaterial_std140_0>,  b_34 : ptr<function, JointBond_std430_0>,  state_2 : ptr<function, JointState_std430_0>,  d_lin_2 : vec3<f32>,  d_ang_2 : vec3<f32>,  dt_10 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_3 : f32 = (*b_34).stiff0_0.x;
    var ks_2 : f32 = (*b_34).stiff0_0.y;
    var kb1_0 : f32 = (*b_34).stiff0_0.z;
    var kb2_0 : f32 = (*b_34).stiff0_0.w;
    var _S315 : vec4<f32> = (*b_34).stiff1_0;
    var kt_2 : f32 = (*b_34).stiff1_0.x;
    var has_rebar_2 : bool = ((*b_34).stiff1_0.w) != 0.0f;
    var kind_3 : u32 = (*mat_8).kind_flags_0.x;
    var flags_1 : u32 = (*mat_8).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_4 : JointState_0;
    st_4.damage_0 = (*state_2).damage_0;
    st_4.crush_1 = (*state_2).crush_1;
    st_4.kappa_0 = (*state_2).kappa_0;
    st_4.kappa_c_0 = (*state_2).kappa_c_0;
    st_4.ductility_0 = (*state_2).ductility_0;
    st_4.ductility_c_0 = (*state_2).ductility_c_0;
    st_4.life_0 = (*state_2).life_0;
    st_4.plastic_x_0 = (*state_2).plastic_x_0;
    st_4.plastic_y_0 = (*state_2).plastic_y_0;
    st_4.plastic_t_0 = (*state_2).plastic_t_0;
    st_4.rebar_plastic_0 = (*state_2).rebar_plastic_0;
    st_4.rebar_slip0_0 = (*state_2).rebar_slip0_0;
    st_4.rebar_slip1_0 = (*state_2).rebar_slip1_0;
    st_4.rebar_work_0 = (*state_2).rebar_work_0;
    st_4.rebar_broken_0 = (*state_2).rebar_broken_0;
    st_4.strain_rate_0 = (*state_2).strain_rate_0;
    st_4.governing_stress_0 = (*state_2).governing_stress_0;
    st_4.dissipated_0 = (*state_2).dissipated_0;
    st_4.utilization_0 = (*state_2).utilization_0;
    st_4.mode_0 = (*state_2).mode_0;
    var _S316 : bool = connected_0(&((*state_2)), has_rebar_2);
    var qe_lin_0 : vec3<f32> = d_lin_2 * vec3<f32>(ks_2, ks_2, kn_3);
    var qe_ang_0 : vec3<f32> = d_ang_2 * vec3<f32>(kb1_0, kb2_0, kt_2);
    var _S317 : Measures_0 = stress_measures_0(&((*b_34)), qe_lin_0, qe_ang_0);
    var _S318 : f32 = max(max(_S317.tension_0, _S317.shear_0), _S317.compression_0);
    var _S319 : bool = dt_10 > 0.0f;
    var dif_1 : f32;
    if(_S319)
    {
        var raw_0 : f32 = fdiv_0(max(fdiv_0(_S318 - st_4.governing_stress_0, dt_10), 0.0f), (*mat_8).misc_0.w);
        var tau_2 : f32 = _S315.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_10, tau_2));
        }
        else
        {
            dif_1 = min(fdiv_0(dt_10, tau_2), 1.0f);
        }
        st_4.strain_rate_0 = st_4.strain_rate_0 + (raw_0 - st_4.strain_rate_0) * dif_1;
        st_4.governing_stress_0 = _S318;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S320 : f32 = dif_factor_0(&((*mat_8)), st_4.strain_rate_0);
        dif_1 = _S320;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_34).geom1_0.w;
    var _S321 : f32 = fatigue_factor_1(&((*mat_8)), st_4.life_0);
    var multiplier_1 : f32 = weibull_0 * dif_1 * _S321;
    var _S322 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_34)), _S317, multiplier_1);
    var _S323 : f32 = _S322.x;
    var _S324 : f32 = _S322.y;
    st_4.utilization_0 = max(max(_S323, _S324), max(_S322.z, _S322.w));
    var _S325 : f32 = d_lin_2.x;
    var _S326 : f32 = d_lin_2.y;
    var _S327 : f32 = ks_2 * (sq_0(_S325) + sq_0(_S326)) + kb1_0 * sq_0(d_ang_2.x) + kb2_0 * sq_0(d_ang_2.y) + kt_2 * sq_0(d_ang_2.z);
    var _S328 : f32 = d_lin_2.z;
    var _S329 : bool = _S328 > 0.0f;
    if(_S329)
    {
        dif_1 = kn_3 * sq_0(_S328);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S327 + dif_1);
    var psi_c_0 : f32;
    if(_S328 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_3 * sq_0(_S328);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    var plastic_4 : vec3<f32> = vec3<f32>(st_4.plastic_x_0, st_4.plastic_y_0, st_4.plastic_t_0);
    var diss_contact_0 : f32;
    var psi_contact_0 : f32;
    var intact_normal_0 : f32;
    var dissipated_4 : f32;
    var overshoot_1 : f32;
    var _S330 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S331 : bool = _S323 >= _S324;
        if(_S331)
        {
            diss_contact_0 = _S323;
        }
        else
        {
            diss_contact_0 = _S324;
        }
        var mode_ts_0 : u32;
        if(_S331)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_4.kappa_0))
        {
            _S330 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S330 = false;
        }
        if(_S330)
        {
            _S330 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S330 = false;
        }
        var mode_c_0 : u32;
        if(_S330)
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
                intact_normal_0 = fdiv_0(psi_contact_0 * (*b_34).geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_4.ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = u32(0);
            }
            var inc_0 : vec2<f32> = damage_increment_0(mode_c_0, st_4.kappa_0, diss_contact_0, intact_normal_0, st_4.damage_0, psi_ts_0);
            var _S332 : f32 = inc_0.x;
            if(_S332 > (st_4.damage_0))
            {
                var _S333 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_34)), st_4.crush_1, plastic_4, d_lin_2, d_ang_2);
                var _S334 : f32 = max(_S333.energy_2 - (1.0f - st_4.crush_1) * psi_c_0, 0.0f);
                var _S335 : f32 = max(inc_0.y - _S334 * (_S332 - st_4.damage_0), 0.0f);
                var _S336 : f32 = max((psi_ts_0 - _S334) * (_S332 - st_4.damage_0) - _S335, 0.0f);
                st_4.damage_0 = _S332;
                st_4.mode_0 = mode_ts_0;
                dissipated_4 = _S335;
                overshoot_1 = _S336;
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
        st_4.kappa_0 = max(st_4.kappa_0, diss_contact_0);
        var _S337 : f32 = (*state_2).damage_0;
        if(((*state_2).damage_0) > 0.0f)
        {
            var _S338 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_34)), (*state_2).crush_1, vec3<f32>((*state_2).plastic_x_0, (*state_2).plastic_y_0, (*state_2).plastic_t_0), d_lin_2, d_ang_2);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - _S337)) + _S338.q_ang_1 * vec3<f32>(_S337);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S339 : Measures_0 = stress_measures_0(&((*b_34)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S340 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_34)), _S339, multiplier_1);
        var _S341 : f32 = _S340.z;
        var _S342 : f32 = _S340.w;
        var _S343 : bool = _S341 >= _S342;
        if(_S343)
        {
            psi_contact_0 = _S341;
        }
        else
        {
            psi_contact_0 = _S342;
        }
        if(_S343)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_4.kappa_c_0))
        {
            _S330 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S330 = false;
        }
        if(_S330)
        {
            _S330 = psi_c_0 > 0.0f;
        }
        else
        {
            _S330 = false;
        }
        if(_S330)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0((*mat_8).energy_1.w * (*b_34).geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_4.ductility_c_0 = intact_normal_0;
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
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_4.kappa_c_0, psi_contact_0, intact_normal_0, st_4.crush_1, psi_c_0);
            var _S344 : f32 = inc_1.x;
            if(_S344 > (st_4.crush_1))
            {
                var _S345 : f32 = inc_1.y;
                var dissipated_5 : f32 = dissipated_4 + _S345;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S344 - st_4.crush_1) - _S345, 0.0f);
                st_4.crush_1 = _S344;
                st_4.mode_0 = mode_c_0;
                if(_S344 >= 1.0f)
                {
                    _S330 = (st_4.damage_0) < 1.0f;
                }
                else
                {
                    _S330 = false;
                }
                if(_S330)
                {
                    var dissipated_6 : f32 = dissipated_5 + psi_ts_0 * (1.0f - st_4.damage_0);
                    st_4.damage_0 = 1.0f;
                    dissipated_4 = dissipated_6;
                }
                else
                {
                    dissipated_4 = dissipated_5;
                }
                overshoot_1 = overshoot_2;
            }
        }
        st_4.kappa_c_0 = max(st_4.kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_4 = 0.0f;
        overshoot_1 = 0.0f;
    }
    var dmg_0 : f32 = st_4.damage_0;
    var _S346 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_0 : vec3<f32>;
    if((st_4.damage_0) == 0.0f)
    {
        if(((flags_1 & (u32(8)))) == u32(0))
        {
            var _S347 : vec3<f32> = contact_offsets_0(&((*mat_8)), &((*b_34)), st_4.crush_1, plastic_4, d_lin_2, d_ang_2);
            st_4.plastic_x_0 = _S347.x;
            st_4.plastic_y_0 = _S347.y;
            st_4.plastic_t_0 = _S347.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S346;
        qc_ang_0 = _S346;
        psi_contact_0 = 0.0f;
    }
    else
    {
        var _S348 : Contact_0 = contact_part_0(&((*mat_8)), &((*b_34)), st_4.crush_1, plastic_4, d_lin_2, d_ang_2);
        st_4.plastic_x_0 = _S348.plastic_1.x;
        st_4.plastic_y_0 = _S348.plastic_1.y;
        st_4.plastic_t_0 = _S348.plastic_1.z;
        diss_contact_0 = _S348.diss_4;
        qc_lin_0 = _S348.q_lin_1;
        qc_ang_0 = _S348.q_ang_1;
        psi_contact_0 = _S348.energy_2;
    }
    var dissipated_7 : f32 = dissipated_4 + dmg_0 * diss_contact_0;
    if(_S329)
    {
        intact_normal_0 = kn_3 * _S328;
    }
    else
    {
        intact_normal_0 = (1.0f - st_4.crush_1) * kn_3 * _S328;
    }
    var _S349 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S349 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S349 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S349 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S349) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_7 : f32 = _S349 * (psi_ts_0 + (1.0f - st_4.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_2)
    {
        _S330 = (st_4.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S330 = false;
    }
    var stored_8 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S330)
    {
        var k_axial_0 : f32 = (*b_34).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_34).rebar0_0.y;
        var yield_force_0 : f32 = (*b_34).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_34).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S328, st_4.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S325, st_4.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S326, st_4.rebar_slip1_0, dowel_capacity_0);
        var _S350 : f32 = nr_0.y;
        var _S351 : f32 = v1_0.y;
        var _S352 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S350) + dowel_capacity_0 * (abs(_S351) + abs(_S352));
        st_4.rebar_plastic_0 = st_4.rebar_plastic_0 + _S350;
        st_4.rebar_slip0_0 = st_4.rebar_slip0_0 + _S351;
        st_4.rebar_slip1_0 = st_4.rebar_slip1_0 + _S352;
        st_4.rebar_work_0 = st_4.rebar_work_0 + work_0;
        var dissipated_8 : f32 = dissipated_7 + work_0;
        var _S353 : f32 = nr_0.x;
        var _S354 : f32 = v1_0.x;
        var _S355 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (fdiv_0(sq_0(_S353), k_axial_0) + fdiv_0(sq_0(_S354) + sq_0(_S355), k_dowel_0));
        if(fracture_1)
        {
            _S330 = (st_4.rebar_work_0) >= ((*b_34).rebar1_0.x);
        }
        else
        {
            _S330 = false;
        }
        if(_S330)
        {
            st_4.rebar_broken_0 = 1.0f;
            var dissipated_9 : f32 = dissipated_8 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_4 = dissipated_9;
            stored_8 = stored_7;
        }
        else
        {
            var stored_9 : f32 = stored_7 + elastic_0;
            force_lin_3 = force_lin_2 + vec3<f32>(_S354, _S355, _S353);
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
        _S330 = _S319;
    }
    else
    {
        _S330 = false;
    }
    if(_S330)
    {
        _S330 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S330 = false;
    }
    if(_S330)
    {
        var _S356 : Measures_0 = stress_measures_0(&((*b_34)), force_lin_3, force_ang_2);
        var _S357 : vec4<f32> = failure_indices_0(&((*mat_8)), &((*b_34)), _S356, weibull_0);
        var _S358 : f32 = life_rate_0(&((*mat_8)), max(max(_S357.x, _S357.y), _S357.z));
        st_4.life_0 = max(st_4.life_0 - _S358 * dt_10, 0.0f);
    }
    st_4.dissipated_0 = st_4.dissipated_0 + dissipated_4;
    var resp_0 : JointResponse_0;
    resp_0.force_lin_1 = force_lin_3;
    resp_0.force_ang_1 = force_ang_2;
    resp_0.state_1 = st_4;
    resp_0.dissipated_3 = dissipated_4;
    resp_0.overshoot_0 = overshoot_1;
    resp_0.stored_6 = stored_8;
    if(_S316)
    {
        _S330 = !connected_1(st_4, has_rebar_2);
    }
    else
    {
        _S330 = false;
    }
    resp_0.disconnected_0 = _S330;
    resp_0.fatigue_before_0 = _S321;
    resp_0.measures_0 = _S317;
    return resp_0;
}

fn joint_evaluate_1( mat_9 : ptr<function, JointMaterial_std140_0>,  b_35 : ptr<function, JointBond_std430_0>,  state_3 : JointState_0,  d_lin_3 : vec3<f32>,  d_ang_3 : vec3<f32>,  dt_11 : f32,  fracture_2 : bool) -> JointResponse_0
{
    var kn_4 : f32 = (*b_35).stiff0_0.x;
    var ks_3 : f32 = (*b_35).stiff0_0.y;
    var kb1_1 : f32 = (*b_35).stiff0_0.z;
    var kb2_1 : f32 = (*b_35).stiff0_0.w;
    var _S359 : vec4<f32> = (*b_35).stiff1_0;
    var kt_3 : f32 = (*b_35).stiff1_0.x;
    var has_rebar_3 : bool = ((*b_35).stiff1_0.w) != 0.0f;
    var kind_4 : u32 = (*mat_9).kind_flags_0.x;
    var flags_2 : u32 = (*mat_9).kind_flags_0.y;
    var softening_1 : bool = ((flags_2 & (u32(1)))) != u32(0);
    var st_5 : JointState_0 = state_3;
    var was_connected_0 : bool = connected_1(state_3, has_rebar_3);
    var qe_lin_1 : vec3<f32> = d_lin_3 * vec3<f32>(ks_3, ks_3, kn_4);
    var qe_ang_1 : vec3<f32> = d_ang_3 * vec3<f32>(kb1_1, kb2_1, kt_3);
    var _S360 : Measures_0 = stress_measures_0(&((*b_35)), qe_lin_1, qe_ang_1);
    var _S361 : f32 = max(max(_S360.tension_0, _S360.shear_0), _S360.compression_0);
    var _S362 : bool = dt_11 > 0.0f;
    var dif_2 : f32;
    if(_S362)
    {
        var raw_1 : f32 = fdiv_0(max(fdiv_0(_S361 - st_5.governing_stress_0, dt_11), 0.0f), (*mat_9).misc_0.w);
        var tau_3 : f32 = _S359.z;
        if(((flags_2 & (u32(16)))) != u32(0))
        {
            dif_2 = - expm1_accurate_0(- fdiv_0(dt_11, tau_3));
        }
        else
        {
            dif_2 = min(fdiv_0(dt_11, tau_3), 1.0f);
        }
        st_5.strain_rate_0 = st_5.strain_rate_0 + (raw_1 - st_5.strain_rate_0) * dif_2;
        st_5.governing_stress_0 = _S361;
    }
    if(((flags_2 & (u32(32)))) != u32(0))
    {
        var _S363 : f32 = dif_factor_0(&((*mat_9)), st_5.strain_rate_0);
        dif_2 = _S363;
    }
    else
    {
        dif_2 = 1.0f;
    }
    var weibull_1 : f32 = (*b_35).geom1_0.w;
    var _S364 : f32 = fatigue_factor_1(&((*mat_9)), st_5.life_0);
    var multiplier_2 : f32 = weibull_1 * dif_2 * _S364;
    var _S365 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_35)), _S360, multiplier_2);
    var _S366 : f32 = _S365.x;
    var _S367 : f32 = _S365.y;
    st_5.utilization_0 = max(max(_S366, _S367), max(_S365.z, _S365.w));
    var _S368 : f32 = d_lin_3.x;
    var _S369 : f32 = d_lin_3.y;
    var _S370 : f32 = ks_3 * (sq_0(_S368) + sq_0(_S369)) + kb1_1 * sq_0(d_ang_3.x) + kb2_1 * sq_0(d_ang_3.y) + kt_3 * sq_0(d_ang_3.z);
    var _S371 : f32 = d_lin_3.z;
    var _S372 : bool = _S371 > 0.0f;
    if(_S372)
    {
        dif_2 = kn_4 * sq_0(_S371);
    }
    else
    {
        dif_2 = 0.0f;
    }
    var psi_ts_1 : f32 = 0.5f * (_S370 + dif_2);
    var psi_c_1 : f32;
    if(_S371 < 0.0f)
    {
        psi_c_1 = 0.5f * kn_4 * sq_0(_S371);
    }
    else
    {
        psi_c_1 = 0.0f;
    }
    var plastic_5 : vec3<f32> = vec3<f32>(st_5.plastic_x_0, st_5.plastic_y_0, st_5.plastic_t_0);
    var diss_contact_1 : f32;
    var psi_contact_1 : f32;
    var intact_normal_1 : f32;
    var dissipated_10 : f32;
    var overshoot_3 : f32;
    var _S373 : bool;
    var qc_lin_1 : vec3<f32>;
    if(fracture_2)
    {
        var _S374 : bool = _S366 >= _S367;
        if(_S374)
        {
            diss_contact_1 = _S366;
        }
        else
        {
            diss_contact_1 = _S367;
        }
        var mode_ts_1 : u32;
        if(_S374)
        {
            mode_ts_1 = u32(1);
        }
        else
        {
            mode_ts_1 = u32(2);
        }
        if(diss_contact_1 > (st_5.kappa_0))
        {
            _S373 = diss_contact_1 > 1.0f;
        }
        else
        {
            _S373 = false;
        }
        if(_S373)
        {
            _S373 = psi_ts_1 > 0.0f;
        }
        else
        {
            _S373 = false;
        }
        var mode_c_1 : u32;
        if(_S373)
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
                intact_normal_1 = fdiv_0(psi_contact_1 * (*b_35).geom0_0.x * diss_contact_1 * diss_contact_1, psi_ts_1);
            }
            else
            {
                intact_normal_1 = 0.0f;
            }
            st_5.ductility_0 = intact_normal_1;
            if(softening_1)
            {
                mode_c_1 = kind_4;
            }
            else
            {
                mode_c_1 = u32(0);
            }
            var inc_2 : vec2<f32> = damage_increment_0(mode_c_1, st_5.kappa_0, diss_contact_1, intact_normal_1, st_5.damage_0, psi_ts_1);
            var _S375 : f32 = inc_2.x;
            if(_S375 > (st_5.damage_0))
            {
                var _S376 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_35)), st_5.crush_1, plastic_5, d_lin_3, d_ang_3);
                var _S377 : f32 = max(_S376.energy_2 - (1.0f - st_5.crush_1) * psi_c_1, 0.0f);
                var _S378 : f32 = max(inc_2.y - _S377 * (_S375 - st_5.damage_0), 0.0f);
                var _S379 : f32 = max((psi_ts_1 - _S377) * (_S375 - st_5.damage_0) - _S378, 0.0f);
                st_5.damage_0 = _S375;
                st_5.mode_0 = mode_ts_1;
                dissipated_10 = _S378;
                overshoot_3 = _S379;
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
        st_5.kappa_0 = max(st_5.kappa_0, diss_contact_1);
        if((state_3.damage_0) > 0.0f)
        {
            var _S380 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_35)), state_3.crush_1, vec3<f32>(state_3.plastic_x_0, state_3.plastic_y_0, state_3.plastic_t_0), d_lin_3, d_ang_3);
            qc_lin_1 = qe_ang_1 * vec3<f32>((1.0f - state_3.damage_0)) + _S380.q_ang_1 * vec3<f32>(state_3.damage_0);
        }
        else
        {
            qc_lin_1 = qe_ang_1;
        }
        var _S381 : Measures_0 = stress_measures_0(&((*b_35)), vec3<f32>(0.0f, 0.0f, min(qe_lin_1.z, 0.0f)), qc_lin_1);
        var _S382 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_35)), _S381, multiplier_2);
        var _S383 : f32 = _S382.z;
        var _S384 : f32 = _S382.w;
        var _S385 : bool = _S383 >= _S384;
        if(_S385)
        {
            psi_contact_1 = _S383;
        }
        else
        {
            psi_contact_1 = _S384;
        }
        if(_S385)
        {
            mode_c_1 = u32(3);
        }
        else
        {
            mode_c_1 = u32(4);
        }
        if(psi_contact_1 > (st_5.kappa_c_0))
        {
            _S373 = psi_contact_1 > 1.0f;
        }
        else
        {
            _S373 = false;
        }
        if(_S373)
        {
            _S373 = psi_c_1 > 0.0f;
        }
        else
        {
            _S373 = false;
        }
        if(_S373)
        {
            if(softening_1)
            {
                intact_normal_1 = fdiv_0((*mat_9).energy_1.w * (*b_35).geom0_0.x * psi_contact_1 * psi_contact_1, psi_c_1);
            }
            else
            {
                intact_normal_1 = 0.0f;
            }
            st_5.ductility_c_0 = intact_normal_1;
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
                    mode_ts_1 = kind_4;
                }
                law_2 = mode_ts_1;
            }
            var inc_3 : vec2<f32> = damage_increment_0(law_2, st_5.kappa_c_0, psi_contact_1, intact_normal_1, st_5.crush_1, psi_c_1);
            var _S386 : f32 = inc_3.x;
            if(_S386 > (st_5.crush_1))
            {
                var _S387 : f32 = inc_3.y;
                var dissipated_11 : f32 = dissipated_10 + _S387;
                var overshoot_4 : f32 = overshoot_3 + max(psi_c_1 * (_S386 - st_5.crush_1) - _S387, 0.0f);
                st_5.crush_1 = _S386;
                st_5.mode_0 = mode_c_1;
                if(_S386 >= 1.0f)
                {
                    _S373 = (st_5.damage_0) < 1.0f;
                }
                else
                {
                    _S373 = false;
                }
                if(_S373)
                {
                    var dissipated_12 : f32 = dissipated_11 + psi_ts_1 * (1.0f - st_5.damage_0);
                    st_5.damage_0 = 1.0f;
                    dissipated_10 = dissipated_12;
                }
                else
                {
                    dissipated_10 = dissipated_11;
                }
                overshoot_3 = overshoot_4;
            }
        }
        st_5.kappa_c_0 = max(st_5.kappa_c_0, psi_contact_1);
    }
    else
    {
        dissipated_10 = 0.0f;
        overshoot_3 = 0.0f;
    }
    var dmg_1 : f32 = st_5.damage_0;
    var _S388 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_1 : vec3<f32>;
    if((st_5.damage_0) == 0.0f)
    {
        if(((flags_2 & (u32(8)))) == u32(0))
        {
            var _S389 : vec3<f32> = contact_offsets_0(&((*mat_9)), &((*b_35)), st_5.crush_1, plastic_5, d_lin_3, d_ang_3);
            st_5.plastic_x_0 = _S389.x;
            st_5.plastic_y_0 = _S389.y;
            st_5.plastic_t_0 = _S389.z;
        }
        diss_contact_1 = 0.0f;
        qc_lin_1 = _S388;
        qc_ang_1 = _S388;
        psi_contact_1 = 0.0f;
    }
    else
    {
        var _S390 : Contact_0 = contact_part_0(&((*mat_9)), &((*b_35)), st_5.crush_1, plastic_5, d_lin_3, d_ang_3);
        st_5.plastic_x_0 = _S390.plastic_1.x;
        st_5.plastic_y_0 = _S390.plastic_1.y;
        st_5.plastic_t_0 = _S390.plastic_1.z;
        diss_contact_1 = _S390.diss_4;
        qc_lin_1 = _S390.q_lin_1;
        qc_ang_1 = _S390.q_ang_1;
        psi_contact_1 = _S390.energy_2;
    }
    var dissipated_13 : f32 = dissipated_10 + dmg_1 * diss_contact_1;
    if(_S372)
    {
        intact_normal_1 = kn_4 * _S371;
    }
    else
    {
        intact_normal_1 = (1.0f - st_5.crush_1) * kn_4 * _S371;
    }
    var _S391 : f32 = 1.0f - dmg_1;
    var force_lin_4 : vec3<f32> = vec3<f32>(_S391 * qe_lin_1.x + dmg_1 * qc_lin_1.x, _S391 * qe_lin_1.y + dmg_1 * qc_lin_1.y, _S391 * intact_normal_1 + dmg_1 * qc_lin_1.z);
    var force_ang_3 : vec3<f32> = qe_ang_1 * vec3<f32>(_S391) + qc_ang_1 * vec3<f32>(dmg_1);
    var stored_10 : f32 = _S391 * (psi_ts_1 + (1.0f - st_5.crush_1) * psi_c_1) + dmg_1 * psi_contact_1;
    if(has_rebar_3)
    {
        _S373 = (st_5.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S373 = false;
    }
    var stored_11 : f32;
    var force_lin_5 : vec3<f32>;
    if(_S373)
    {
        var k_axial_1 : f32 = (*b_35).rebar0_0.x;
        var k_dowel_1 : f32 = (*b_35).rebar0_0.y;
        var yield_force_1 : f32 = (*b_35).rebar0_0.z;
        var dowel_capacity_1 : f32 = (*b_35).rebar0_0.w;
        var nr_1 : vec2<f32> = return_map_0(k_axial_1, _S371, st_5.rebar_plastic_0, yield_force_1);
        var v1_1 : vec2<f32> = return_map_0(k_dowel_1, _S368, st_5.rebar_slip0_0, dowel_capacity_1);
        var v2_1 : vec2<f32> = return_map_0(k_dowel_1, _S369, st_5.rebar_slip1_0, dowel_capacity_1);
        var _S392 : f32 = nr_1.y;
        var _S393 : f32 = v1_1.y;
        var _S394 : f32 = v2_1.y;
        var work_1 : f32 = yield_force_1 * abs(_S392) + dowel_capacity_1 * (abs(_S393) + abs(_S394));
        st_5.rebar_plastic_0 = st_5.rebar_plastic_0 + _S392;
        st_5.rebar_slip0_0 = st_5.rebar_slip0_0 + _S393;
        st_5.rebar_slip1_0 = st_5.rebar_slip1_0 + _S394;
        st_5.rebar_work_0 = st_5.rebar_work_0 + work_1;
        var dissipated_14 : f32 = dissipated_13 + work_1;
        var _S395 : f32 = nr_1.x;
        var _S396 : f32 = v1_1.x;
        var _S397 : f32 = v2_1.x;
        var elastic_1 : f32 = 0.5f * (fdiv_0(sq_0(_S395), k_axial_1) + fdiv_0(sq_0(_S396) + sq_0(_S397), k_dowel_1));
        if(fracture_2)
        {
            _S373 = (st_5.rebar_work_0) >= ((*b_35).rebar1_0.x);
        }
        else
        {
            _S373 = false;
        }
        if(_S373)
        {
            st_5.rebar_broken_0 = 1.0f;
            var dissipated_15 : f32 = dissipated_14 + elastic_1;
            force_lin_5 = force_lin_4;
            dissipated_10 = dissipated_15;
            stored_11 = stored_10;
        }
        else
        {
            var stored_12 : f32 = stored_10 + elastic_1;
            force_lin_5 = force_lin_4 + vec3<f32>(_S396, _S397, _S395);
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
        _S373 = _S362;
    }
    else
    {
        _S373 = false;
    }
    if(_S373)
    {
        _S373 = ((flags_2 & (u32(64)))) != u32(0);
    }
    else
    {
        _S373 = false;
    }
    if(_S373)
    {
        var _S398 : Measures_0 = stress_measures_0(&((*b_35)), force_lin_5, force_ang_3);
        var _S399 : vec4<f32> = failure_indices_0(&((*mat_9)), &((*b_35)), _S398, weibull_1);
        var _S400 : f32 = life_rate_0(&((*mat_9)), max(max(_S399.x, _S399.y), _S399.z));
        st_5.life_0 = max(st_5.life_0 - _S400 * dt_11, 0.0f);
    }
    st_5.dissipated_0 = st_5.dissipated_0 + dissipated_10;
    var resp_1 : JointResponse_0;
    resp_1.force_lin_1 = force_lin_5;
    resp_1.force_ang_1 = force_ang_3;
    resp_1.state_1 = st_5;
    resp_1.dissipated_3 = dissipated_10;
    resp_1.overshoot_0 = overshoot_3;
    resp_1.stored_6 = stored_11;
    if(was_connected_0)
    {
        _S373 = !connected_1(st_5, has_rebar_3);
    }
    else
    {
        _S373 = false;
    }
    resp_1.disconnected_0 = _S373;
    resp_1.fatigue_before_0 = _S364;
    resp_1.measures_0 = _S360;
    return resp_1;
}

fn secant_factors_0( b_36 : ptr<function, JointBond_std430_0>,  st_6 : ptr<function, JointState_std430_0>,  d_lin_4 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var _S401 : f32 = (*st_6).damage_0;
    var compressed_0 : bool = (d_lin_4.z) < 0.0f;
    var contact_3 : f32;
    if(compressed_0)
    {
        contact_3 = _S401;
    }
    else
    {
        contact_3 = 0.0f;
    }
    var _S402 : f32 = 1.0f - _S401;
    var _S403 : f32 = max(_S402 + contact_3, 9.99999997475242708e-07f);
    var normal_6 : f32;
    if(compressed_0)
    {
        normal_6 = max(1.0f - (*st_6).crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_6 = max(_S402, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S403, _S403, normal_6);
    (*f_ang_0) = vec3<f32>(_S403);
    var _S404 : bool;
    if(((*b_36).stiff1_0.w) != 0.0f)
    {
        _S404 = ((*st_6).rebar_broken_0) == 0.0f;
    }
    else
    {
        _S404 = false;
    }
    if(_S404)
    {
        var _S405 : vec4<f32> = (*b_36).rebar0_0;
        var _S406 : vec4<f32> = (*b_36).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + fdiv_0((*b_36).rebar0_0.x, (*b_36).stiff0_0.x);
        var _S407 : f32 = fdiv_0(_S405.y, _S406.y);
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S407;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S407;
    }
    return;
}

fn secant_factors_1( b_37 : ptr<function, JointBond_std430_0>,  st_7 : JointState_0,  d_lin_5 : vec3<f32>,  f_lin_1 : ptr<function, vec3<f32>>,  f_ang_1 : ptr<function, vec3<f32>>)
{
    var compressed_1 : bool = (d_lin_5.z) < 0.0f;
    var contact_4 : f32;
    if(compressed_1)
    {
        contact_4 = st_7.damage_0;
    }
    else
    {
        contact_4 = 0.0f;
    }
    var _S408 : f32 = 1.0f - st_7.damage_0;
    var _S409 : f32 = max(_S408 + contact_4, 9.99999997475242708e-07f);
    var normal_7 : f32;
    if(compressed_1)
    {
        normal_7 = max(1.0f - st_7.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_7 = max(_S408, 9.99999997475242708e-07f);
    }
    (*f_lin_1) = vec3<f32>(_S409, _S409, normal_7);
    (*f_ang_1) = vec3<f32>(_S409);
    var _S410 : bool;
    if(((*b_37).stiff1_0.w) != 0.0f)
    {
        _S410 = (st_7.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S410 = false;
    }
    if(_S410)
    {
        var _S411 : vec4<f32> = (*b_37).rebar0_0;
        var _S412 : vec4<f32> = (*b_37).stiff0_0;
        (*f_lin_1)[i32(2)] = (*f_lin_1)[i32(2)] + fdiv_0((*b_37).rebar0_0.x, (*b_37).stiff0_0.x);
        var _S413 : f32 = fdiv_0(_S411.y, _S412.y);
        (*f_lin_1)[i32(0)] = (*f_lin_1)[i32(0)] + _S413;
        (*f_lin_1)[i32(1)] = (*f_lin_1)[i32(1)] + _S413;
    }
    return;
}

fn to_local_0( _S414 : u32,  _S415 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S415, bonds_0[_S414].t1_0.xyz), dot(_S415, bonds_0[_S414].t2_0.xyz), dot(_S415, bonds_0[_S414].normal_0.xyz));
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

fn to_body_0( _S416 : u32,  _S417 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S416].t1_0.xyz * vec3<f32>(_S417.x) + bonds_0[_S416].t2_0.xyz * vec3<f32>(_S417.y) + bonds_0[_S416].normal_0.xyz * vec3<f32>(_S417.z);
}

fn bond_update_0( i_8 : u32,  dt_12 : f32,  fracture_3 : bool,  abs_step_0 : u32,  wide_0 : bool) -> bool
{
    var ra_1 : vec3<f32> = bonds_0[i_8].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_8].rb_0.xyz;
    var _S418 : u32 = u32(4) * bonds_0[i_8].law_0.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S418 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S418 + u32(3)].xyz;
    var _S419 : u32 = u32(4) * bonds_0[i_8].law_0.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S419 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S419 + u32(3)].xyz;
    var _S420 : vec3<f32> = to_local_0(i_8, state_0[_S419].xyz + cross(tb_3, rb_1) - (state_0[_S418].xyz + cross(ta_3, ra_1)));
    var _S421 : vec3<f32> = to_local_0(i_8, tb_3 - ta_3);
    var _S422 : vec3<f32> = to_local_0(i_8, state_0[_S419 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S418 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S423 : vec3<f32> = to_local_0(i_8, wb_0 - wa_0);
    var _S424 : JointMaterial_std140_0 = materials_0.m_0.data_0[bonds_0[i_8].law_0.ids_0.x];
    var _S425 : JointState_std430_0 = bond_dyn_0[i_8].js_0;
    var _S426 : bool = is_damaged_0(&(_S425));
    var _S427 : f32 = _S425.life_0;
    var _S428 : JointBond_std430_0 = bonds_0[i_8].law_0;
    var _S429 : JointResponse_0 = joint_evaluate_0(&(_S424), &(_S428), &(_S425), _S420, _S421, dt_12, fracture_3);
    var _S430 : JointState_0 = JointState_0( bond_dyn_0[i_8].js_0.damage_0, bond_dyn_0[i_8].js_0.crush_1, bond_dyn_0[i_8].js_0.kappa_0, bond_dyn_0[i_8].js_0.kappa_c_0, bond_dyn_0[i_8].js_0.ductility_0, bond_dyn_0[i_8].js_0.ductility_c_0, bond_dyn_0[i_8].js_0.life_0, bond_dyn_0[i_8].js_0.plastic_x_0, bond_dyn_0[i_8].js_0.plastic_y_0, bond_dyn_0[i_8].js_0.plastic_t_0, bond_dyn_0[i_8].js_0.rebar_plastic_0, bond_dyn_0[i_8].js_0.rebar_slip0_0, bond_dyn_0[i_8].js_0.rebar_slip1_0, bond_dyn_0[i_8].js_0.rebar_work_0, bond_dyn_0[i_8].js_0.rebar_broken_0, bond_dyn_0[i_8].js_0.strain_rate_0, bond_dyn_0[i_8].js_0.governing_stress_0, bond_dyn_0[i_8].js_0.dissipated_0, bond_dyn_0[i_8].js_0.utilization_0, bond_dyn_0[i_8].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S430;
    bd_0.force_lin_0 = bond_dyn_0[i_8].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_8].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_8].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_8].comps_0;
    bd_0.events_0 = bond_dyn_0[i_8].events_0;
    var ra_2 : vec3<f32> = bonds_0[i_8].ra_0.xyz;
    var rb_2 : vec3<f32> = bonds_0[i_8].rb_0.xyz;
    var _S431 : JointBond_std430_0 = bonds_0[i_8].law_0;
    var f_lin_2 : vec3<f32>;
    var f_ang_2 : vec3<f32>;
    secant_factors_1(&(_S431), _S429.state_1, _S420, &(f_lin_2), &(f_ang_2));
    var qd_lin_0 : vec3<f32> = _S422 * bonds_0[i_8].c_lin_0.xyz * f_lin_2;
    var qd_ang_0 : vec3<f32> = _S423 * bonds_0[i_8].c_ang_0.xyz * f_ang_2;
    var q_lin_2 : vec3<f32> = _S429.force_lin_1 + qd_lin_0;
    var q_ang_2 : vec3<f32> = _S429.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S422) + dot(qd_ang_0, _S423)) * dt_12;
    var _S432 : vec3<f32> = to_body_0(i_8, q_lin_2);
    var _S433 : vec3<f32> = to_body_0(i_8, q_ang_2);
    var _S434 : u32 = u32(3) * i_8;
    scratch_0[_S434] = vec4<f32>(_S432, max(_S429.measures_0.tension_0, _S429.measures_0.compression_0));
    scratch_0[_S434 + u32(1)] = vec4<f32>(_S433 + cross(ra_2, _S432), 0.0f);
    scratch_0[_S434 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S433) + cross(rb_2, (vec3<f32>(0) - _S432)), 0.0f);
    var _S435 : f32 = bd_0.sums_0[i32(0)];
    var _S436 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S435), &(_S436), _S429.dissipated_3);
    bd_0.sums_0[i32(0)] = _S435;
    bd_0.comps_0[i32(0)] = _S436;
    var _S437 : f32 = bd_0.sums_0[i32(1)];
    var _S438 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S437), &(_S438), _S429.overshoot_0);
    bd_0.sums_0[i32(1)] = _S437;
    bd_0.comps_0[i32(1)] = _S438;
    var _S439 : f32 = bd_0.sums_0[i32(2)];
    var _S440 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S439), &(_S440), damped_0);
    bd_0.sums_0[i32(2)] = _S439;
    bd_0.comps_0[i32(2)] = _S440;
    bd_0.force_lin_0 = vec4<f32>(q_lin_2, _S429.stored_6);
    bd_0.force_ang_0 = vec4<f32>(q_ang_2, max(bd_0.force_ang_0.w, _S429.state_1.utilization_0));
    var _S441 : bool;
    if(!_S426)
    {
        _S441 = is_damaged_1(_S429.state_1);
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        _S441 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S429.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S431.ids_0.w, u32(32));
        }
        else
        {
            g_seen_0[u32(3)] = u32(1);
        }
    }
    if((bd_0.events_0.y) == u32(0))
    {
        _S441 = (_S429.state_1.life_0) != _S427;
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        _S441 = (_S429.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        var _S442 : f32 = fatigue_factor_0(&(_S424), _S429.state_1.life_0);
        _S441 = _S442 <= 0.99000000953674316f;
    }
    else
    {
        _S441 = false;
    }
    if(_S441)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S431.ids_0.w, u32(64));
        }
        else
        {
            g_seen_0[u32(4)] = u32(1);
        }
    }
    if(_S429.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
    }
    bd_0.js_0 = _S429.state_1;
    bond_dyn_0[i_8].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_8].js_0.crush_1 = bd_0.js_0.crush_1;
    bond_dyn_0[i_8].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_8].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_8].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_8].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_8].js_0.life_0 = bd_0.js_0.life_0;
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
    return _S429.disconnected_0;
}

fn chunk_update_0( c_15 : u32,  isl_8 : ptr<function, Island_std430_0>,  rg_6 : Rigid_0,  dt_13 : f32,  rml_0 : bool,  step_0 : u32,  contact_5 : bool,  work_2 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S443 : vec3<f32> = vec3<f32>(0.0f);
    var _S444 : u32 = index_0[c_15];
    var peak_0 : f32 = 0.0f;
    var e_3 : u32 = _S444;
    var fi_0 : vec3<f32> = _S443;
    var mi_0 : vec3<f32> = _S443;
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
        var _S445 : u32 = u32(3) * ((entry_2 >> (u32(1))));
        var fa_1 : vec4<f32> = scratch_0[_S445];
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var mi_1 : vec3<f32> = mi_0 + scratch_0[_S445 + u32(1)].xyz;
            fi_0 = fi_0 + fa_1.xyz;
            mi_0 = mi_1;
        }
        else
        {
            var mi_2 : vec3<f32> = mi_0 + scratch_0[_S445 + u32(2)].xyz;
            fi_0 = fi_0 + (vec3<f32>(0) - fa_1.xyz);
            mi_0 = mi_2;
        }
        var _S446 : f32 = max(peak_0, fa_1.w);
        var _S447 : u32 = e_3 + u32(1);
        peak_0 = _S446;
        e_3 = _S447;
    }
    var _S448 : u32 = u32(4) * c_15;
    var u_0 : vec3<f32> = state_0[_S448].xyz;
    var _S449 : u32 = _S448 + u32(1);
    var th_2 : vec3<f32> = state_0[_S449].xyz;
    var _S450 : u32 = _S448 + u32(2);
    var v_8 : vec3<f32> = state_0[_S450].xyz;
    var _S451 : u32 = _S448 + u32(3);
    var w_5 : vec3<f32> = state_0[_S451].xyz;
    var mass_0 : f32 = chunks_0[c_15].center_0.w;
    var _S452 : vec3<f32> = chunks_0[c_15].center_0.xyz;
    var _S453 : vec3<f32> = (*isl_8).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_6.rot_0, _S452 + u_0 - _S453);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    var rep_f_2 : vec3<f32>;
    var rep_m_2 : vec3<f32>;
    chunk_loads_0(c_15, c_15, rg_6.rot_0, step_0, dt_13, contact_5, dt_13, &(f_load_0), &(t_load_0), &(rep_f_2), &(rep_m_2));
    record_chunk_load_0(c_15, f_load_0, t_load_0);
    var _S454 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S454;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_6.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_6.alpha_0) + cross(rg_6.w_4, world_mul_0(rg_6.rot_0, chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, rg_6.w_4)));
        f_world_1 = f_world_0 - (rg_6.a_8 + cross(rg_6.alpha_0, r_world_0) + cross(rg_6.w_4, cross(rg_6.w_4, r_world_0))) * _S454;
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
        var i_w_0 : vec3<f32> = rows_mul_0(chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, w_5);
        var m_ext_2 : vec3<f32> = m_ext_0 - (cross(wb_1, i_w_0) + cross(w_5, rows_mul_0(chunks_0[c_15].inertia0_1, chunks_0[c_15].inertia1_1, chunks_0[c_15].inertia2_1, wb_1)) + cross(w_5, i_w_0));
        f_ext_1 = f_ext_0 - cross(wb_1, v_8) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var f_15 : vec3<f32> = f_ext_1 + rep_f_2 + fi_0;
    var m_5 : vec3<f32> = m_ext_1 + rep_m_2 + mi_0;
    var support_0 : u32 = chunks_0[c_15].info_1.x;
    var _S455 : vec3<f32> = vec3<f32>(state_0[_S449].w, state_0[_S450].w, state_0[_S451].w);
    var reaction_0 : vec3<f32>;
    var u_1 : vec3<f32>;
    var th_3 : vec3<f32>;
    var v_9 : vec3<f32>;
    var w_6 : vec3<f32>;
    if(support_0 == u32(1))
    {
        reaction_0 = (vec3<f32>(0) - f_15);
        u_1 = u_0;
        th_3 = th_2;
        v_9 = _S443;
        w_6 = _S443;
    }
    else
    {
        var _S456 : vec4<f32> = chunks_0[c_15].scale_0;
        var w_7 : vec3<f32> = w_5 + rows_mul_0(chunks_0[c_15].inv0_1, chunks_0[c_15].inv1_1, chunks_0[c_15].inv2_1, m_5) * vec3<f32>((dt_13 * chunks_0[c_15].scale_0.z));
        var _S457 : vec3<f32> = vec3<f32>(dt_13);
        var th_4 : vec3<f32> = th_2 + w_7 * _S457;
        if(support_0 == u32(2))
        {
            reaction_0 = (vec3<f32>(0) - f_15);
            u_1 = u_0;
            th_3 = _S443;
        }
        else
        {
            var v_10 : vec3<f32> = v_8 + f_15 * vec3<f32>((dt_13 * _S456.y));
            var u_2 : vec3<f32> = u_0 + v_10 * _S457;
            reaction_0 = _S455;
            u_1 = u_2;
            th_3 = v_10;
        }
        var _S458 : vec3<f32> = th_3;
        th_3 = th_4;
        v_9 = _S458;
        w_6 = w_7;
    }
    state_0[_S448] = vec4<f32>(u_1, peak_0);
    state_0[_S449] = vec4<f32>(th_3, reaction_0.x);
    state_0[_S450] = vec4<f32>(v_9, reaction_0.y);
    state_0[_S451] = vec4<f32>(w_6, reaction_0.z);
    comp_add1_2(&((*work_2)), &((*work_err_0)), (dot(f_load_0, rg_6.vel_1 + rg_6.vel_err_1 + cross(rg_6.w_4, rotate_0(rg_6.rot_0, _S452 + u_1 - _S453)) + rotate_0(rg_6.rot_0, v_9)) + dot(t_load_0, rg_6.w_4 + rotate_0(rg_6.rot_0, w_6))) * dt_13);
    return;
}

fn chunk_update_1( c_16 : u32,  isl_9 : Island_0,  rg_7 : Rigid_0,  dt_14 : f32,  rml_1 : bool,  step_1 : u32,  contact_6 : bool,  work_3 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S459 : vec3<f32> = vec3<f32>(0.0f);
    var _S460 : u32 = index_0[c_16];
    var peak_1 : f32 = 0.0f;
    var e_4 : u32 = _S460;
    var fi_1 : vec3<f32> = _S459;
    var mi_3 : vec3<f32> = _S459;
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
        var _S461 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S461];
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            var mi_4 : vec3<f32> = mi_3 + scratch_0[_S461 + u32(1)].xyz;
            fi_1 = fi_1 + fa_2.xyz;
            mi_3 = mi_4;
        }
        else
        {
            var mi_5 : vec3<f32> = mi_3 + scratch_0[_S461 + u32(2)].xyz;
            fi_1 = fi_1 + (vec3<f32>(0) - fa_2.xyz);
            mi_3 = mi_5;
        }
        var _S462 : f32 = max(peak_1, fa_2.w);
        var _S463 : u32 = e_4 + u32(1);
        peak_1 = _S462;
        e_4 = _S463;
    }
    var _S464 : u32 = u32(4) * c_16;
    var u_3 : vec3<f32> = state_0[_S464].xyz;
    var _S465 : u32 = _S464 + u32(1);
    var th_5 : vec3<f32> = state_0[_S465].xyz;
    var _S466 : u32 = _S464 + u32(2);
    var v_11 : vec3<f32> = state_0[_S466].xyz;
    var _S467 : u32 = _S464 + u32(3);
    var w_8 : vec3<f32> = state_0[_S467].xyz;
    var mass_1 : f32 = chunks_0[c_16].center_0.w;
    var _S468 : vec3<f32> = chunks_0[c_16].center_0.xyz;
    var _S469 : vec3<f32> = isl_9.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_7.rot_0, _S468 + u_3 - _S469);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    var rep_f_3 : vec3<f32>;
    var rep_m_3 : vec3<f32>;
    chunk_loads_0(c_16, c_16, rg_7.rot_0, step_1, dt_14, contact_6, dt_14, &(f_load_1), &(t_load_1), &(rep_f_3), &(rep_m_3));
    record_chunk_load_0(c_16, f_load_1, t_load_1);
    var _S470 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S470;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_7.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_7.alpha_0) + cross(rg_7.w_4, world_mul_0(rg_7.rot_0, chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, rg_7.w_4)));
        f_world_3 = f_world_2 - (rg_7.a_8 + cross(rg_7.alpha_0, r_world_1) + cross(rg_7.w_4, cross(rg_7.w_4, r_world_1))) * _S470;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_3 = f_world_2;
        t_world_4 = t_world_3;
    }
    var f_ext_2 : vec3<f32> = inverse_rotate_0(rg_7.rot_0, f_world_3);
    var m_ext_3 : vec3<f32> = inverse_rotate_0(rg_7.rot_0, t_world_4);
    var f_ext_3 : vec3<f32>;
    var m_ext_4 : vec3<f32>;
    if(rml_1)
    {
        var wb_2 : vec3<f32> = inverse_rotate_0(rg_7.rot_0, rg_7.w_4);
        var i_w_1 : vec3<f32> = rows_mul_0(chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, w_8);
        var m_ext_5 : vec3<f32> = m_ext_3 - (cross(wb_2, i_w_1) + cross(w_8, rows_mul_0(chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, wb_2)) + cross(w_8, i_w_1));
        f_ext_3 = f_ext_2 - cross(wb_2, v_11) * vec3<f32>((2.0f * mass_1));
        m_ext_4 = m_ext_5;
    }
    else
    {
        f_ext_3 = f_ext_2;
        m_ext_4 = m_ext_3;
    }
    var f_16 : vec3<f32> = f_ext_3 + rep_f_3 + fi_1;
    var m_6 : vec3<f32> = m_ext_4 + rep_m_3 + mi_3;
    var support_1 : u32 = chunks_0[c_16].info_1.x;
    var _S471 : vec3<f32> = vec3<f32>(state_0[_S465].w, state_0[_S466].w, state_0[_S467].w);
    var reaction_1 : vec3<f32>;
    var u_4 : vec3<f32>;
    var th_6 : vec3<f32>;
    var v_12 : vec3<f32>;
    var w_9 : vec3<f32>;
    if(support_1 == u32(1))
    {
        reaction_1 = (vec3<f32>(0) - f_16);
        u_4 = u_3;
        th_6 = th_5;
        v_12 = _S459;
        w_9 = _S459;
    }
    else
    {
        var _S472 : vec4<f32> = chunks_0[c_16].scale_0;
        var w_10 : vec3<f32> = w_8 + rows_mul_0(chunks_0[c_16].inv0_1, chunks_0[c_16].inv1_1, chunks_0[c_16].inv2_1, m_6) * vec3<f32>((dt_14 * chunks_0[c_16].scale_0.z));
        var _S473 : vec3<f32> = vec3<f32>(dt_14);
        var th_7 : vec3<f32> = th_5 + w_10 * _S473;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_16);
            u_4 = u_3;
            th_6 = _S459;
        }
        else
        {
            var v_13 : vec3<f32> = v_11 + f_16 * vec3<f32>((dt_14 * _S472.y));
            var u_5 : vec3<f32> = u_3 + v_13 * _S473;
            reaction_1 = _S471;
            u_4 = u_5;
            th_6 = v_13;
        }
        var _S474 : vec3<f32> = th_6;
        th_6 = th_7;
        v_12 = _S474;
        w_9 = w_10;
    }
    state_0[_S464] = vec4<f32>(u_4, peak_1);
    state_0[_S465] = vec4<f32>(th_6, reaction_1.x);
    state_0[_S466] = vec4<f32>(v_12, reaction_1.y);
    state_0[_S467] = vec4<f32>(w_9, reaction_1.z);
    comp_add1_2(&((*work_3)), &((*work_err_1)), (dot(f_load_1, rg_7.vel_1 + rg_7.vel_err_1 + cross(rg_7.w_4, rotate_0(rg_7.rot_0, _S468 + u_4 - _S469)) + rotate_0(rg_7.rot_0, v_12)) + dot(t_load_1, rg_7.w_4 + rotate_0(rg_7.rot_0, w_9))) * dt_14);
    return;
}

fn turn_difference_0( omega_1 : vec3<f32>,  dt_15 : f32,  v_14 : vec3<f32>) -> vec3<f32>
{
    var _S475 : f32 = length(omega_1);
    var angle_3 : f32 = _S475 * dt_15;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return vec3<f32>(0.0f);
    }
    var a_16 : vec3<f32> = omega_1 / vec3<f32>(_S475);
    var s_8 : f32 = sin(0.5f * angle_3);
    var av_0 : vec3<f32> = cross(a_16, v_14);
    return av_0 * vec3<f32>(sin(angle_3)) + cross(a_16, av_0) * vec3<f32>((2.0f * s_8 * s_8));
}

fn integrate_rigid_0( isl_10 : ptr<function, Island_std430_0>,  rg_8 : ptr<function, Rigid_0>,  dt_16 : f32)
{
    var _S476 : vec3<f32> = vec3<f32>(dt_16);
    var _S477 : vec3<f32> = (*rg_8).torque_0 * _S476;
    var _S478 : vec3<f32> = (*rg_8).l_2;
    var _S479 : vec3<f32> = (*rg_8).l_err_1;
    comp_add_0(&(_S478), &(_S479), _S477);
    (*rg_8).l_2 = _S478;
    (*rg_8).l_err_1 = _S479;
    var l_3 : vec3<f32> = _S478 + _S479;
    var _S480 : vec3<f32> = (*rg_8).a_8 * _S476;
    var _S481 : vec3<f32> = (*rg_8).vel_1;
    var _S482 : vec3<f32> = (*rg_8).vel_err_1;
    comp_add_0(&(_S481), &(_S482), _S480);
    (*rg_8).vel_1 = _S481;
    (*rg_8).vel_err_1 = _S482;
    var _S483 : vec4<f32> = (*isl_10).inv0_0;
    var _S484 : vec4<f32> = (*isl_10).inv1_0;
    var _S485 : vec4<f32> = (*isl_10).inv2_0;
    var w_mid_1 : vec3<f32> = world_mul_0((*rg_8).rot_0, (*isl_10).inv0_0, (*isl_10).inv1_0, (*isl_10).inv2_0, l_3);
    var delta_0 : vec3<f32> = (_S481 + _S482) * _S476 - turn_difference_0(w_mid_1, dt_16, rotate_0((*rg_8).rot_0, (*isl_10).com_0.xyz));
    var _S486 : vec3<f32> = (*rg_8).pos_1;
    var _S487 : vec3<f32> = (*rg_8).pos_err_1;
    comp_add_0(&(_S486), &(_S487), delta_0);
    (*rg_8).pos_1 = _S486;
    (*rg_8).pos_err_1 = _S487;
    var _S488 : Quat_0 = (*rg_8).rot_0;
    var _S489 : vec4<f32> = (*rg_8).rot_err_0;
    turn_left_0(&(_S488), &(_S489), w_mid_1, dt_16);
    (*rg_8).rot_0 = _S488;
    (*rg_8).rot_err_0 = _S489;
    (*rg_8).w_4 = world_mul_0(_S488, _S483, _S484, _S485, l_3);
    return;
}

fn integrate_rigid_1( isl_11 : Island_0,  rg_9 : ptr<function, Rigid_0>,  dt_17 : f32)
{
    var _S490 : vec3<f32> = vec3<f32>(dt_17);
    var _S491 : vec3<f32> = (*rg_9).torque_0 * _S490;
    var _S492 : vec3<f32> = (*rg_9).l_2;
    var _S493 : vec3<f32> = (*rg_9).l_err_1;
    comp_add_0(&(_S492), &(_S493), _S491);
    (*rg_9).l_2 = _S492;
    (*rg_9).l_err_1 = _S493;
    var l_4 : vec3<f32> = _S492 + _S493;
    var _S494 : vec3<f32> = (*rg_9).a_8 * _S490;
    var _S495 : vec3<f32> = (*rg_9).vel_1;
    var _S496 : vec3<f32> = (*rg_9).vel_err_1;
    comp_add_0(&(_S495), &(_S496), _S494);
    (*rg_9).vel_1 = _S495;
    (*rg_9).vel_err_1 = _S496;
    var w_mid_2 : vec3<f32> = world_mul_0((*rg_9).rot_0, isl_11.inv0_0, isl_11.inv1_0, isl_11.inv2_0, l_4);
    var delta_1 : vec3<f32> = (_S495 + _S496) * _S490 - turn_difference_0(w_mid_2, dt_17, rotate_0((*rg_9).rot_0, isl_11.com_0.xyz));
    var _S497 : vec3<f32> = (*rg_9).pos_1;
    var _S498 : vec3<f32> = (*rg_9).pos_err_1;
    comp_add_0(&(_S497), &(_S498), delta_1);
    (*rg_9).pos_1 = _S497;
    (*rg_9).pos_err_1 = _S498;
    var _S499 : Quat_0 = (*rg_9).rot_0;
    var _S500 : vec4<f32> = (*rg_9).rot_err_0;
    turn_left_0(&(_S499), &(_S500), w_mid_2, dt_17);
    (*rg_9).rot_0 = _S499;
    (*rg_9).rot_err_0 = _S500;
    (*rg_9).w_4 = world_mul_0(_S499, isl_11.inv0_0, isl_11.inv1_0, isl_11.inv2_0, l_4);
    return;
}

fn drift_moments_0( c_17 : u32,  tu_0 : ptr<function, vec3<f32>>,  pv_0 : ptr<function, vec3<f32>>)
{
    var _S501 : u32 = u32(4) * c_17;
    var _S502 : vec3<f32> = vec3<f32>((chunks_0[c_17].center_0.w * chunks_0[c_17].scale_0.x));
    (*tu_0) = (*tu_0) + state_0[_S501].xyz * _S502;
    (*pv_0) = (*pv_0) + state_0[_S501 + u32(2)].xyz * _S502;
    return;
}

fn drift_angular_0( c_18 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_12 : vec3<f32> = chunks_0[c_18].center_0.xyz - wcom_1;
    var _S503 : u32 = u32(4) * c_18;
    var _S504 : vec3<f32> = vec3<f32>(chunks_0[c_18].center_0.w);
    var _S505 : vec4<f32> = chunks_0[c_18].inertia0_1;
    var _S506 : vec4<f32> = chunks_0[c_18].inertia1_1;
    var _S507 : vec4<f32> = chunks_0[c_18].inertia2_1;
    var _S508 : vec3<f32> = vec3<f32>(chunks_0[c_18].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_12, state_0[_S503].xyz - tr_0) * _S504 + rows_mul_0(chunks_0[c_18].inertia0_1, chunks_0[c_18].inertia1_1, chunks_0[c_18].inertia2_1, state_0[_S503 + u32(1)].xyz)) * _S508;
    (*lv_0) = (*lv_0) + (cross(r_12, state_0[_S503 + u32(2)].xyz - dv_0) * _S504 + rows_mul_0(_S505, _S506, _S507, state_0[_S503 + u32(3)].xyz)) * _S508;
    return;
}

fn drift_apply_0( c_19 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  phi_0 : vec3<f32>,  dv_1 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_13 : vec3<f32> = chunks_0[c_19].center_0.xyz - wcom_2;
    var _S509 : u32 = u32(4) * c_19;
    state_0[_S509] = vec4<f32>(state_0[_S509].xyz - (tr_1 + cross(phi_0, r_13)), state_0[_S509].w);
    var _S510 : u32 = _S509 + u32(1);
    state_0[_S510] = vec4<f32>(state_0[_S510].xyz - phi_0, state_0[_S510].w);
    var _S511 : u32 = _S509 + u32(2);
    state_0[_S511] = vec4<f32>(state_0[_S511].xyz - (dv_1 + cross(dw_0, r_13)), state_0[_S511].w);
    var _S512 : u32 = _S509 + u32(3);
    state_0[_S512] = vec4<f32>(state_0[_S512].xyz - dw_0, state_0[_S512].w);
    return;
}

fn turn_right_0( hi_3 : ptr<function, Quat_0>,  lo_3 : ptr<function, vec4<f32>>,  phi_1 : vec3<f32>)
{
    var angle_4 : f32 = length(phi_1);
    if(angle_4 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_16 : vec4<f32> = turn_minus_one_0(phi_1 / vec3<f32>(angle_4), angle_4);
    var dq_1 : Quat_0;
    dq_1.x_2 = d_16.x;
    dq_1.y_1 = d_16.y;
    dq_1.z_0 = d_16.z;
    dq_1.w_0 = d_16.w;
    quat_accumulate_0(&((*hi_3)), &((*lo_3)), quat_vec_0(quat_mul_0((*hi_3), dq_1)));
    return;
}

fn drift_rigid_0( isl_12 : ptr<function, Island_std430_0>,  rg_10 : ptr<function, Rigid_0>,  tr_2 : vec3<f32>,  phi_2 : vec3<f32>,  dv_2 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_3 : vec3<f32> = (*isl_12).wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_10).rot_0;
    var _S513 : vec3<f32> = rotate_0((*rg_10).rot_0, tr_2 - cross(phi_2, wcom_3));
    var _S514 : vec3<f32> = (*rg_10).pos_1;
    var _S515 : vec3<f32> = (*rg_10).pos_err_1;
    comp_add_0(&(_S514), &(_S515), _S513);
    (*rg_10).pos_1 = _S514;
    (*rg_10).pos_err_1 = _S515;
    var b_38 : vec3<f32> = inverse_rotate_0((*rg_10).rot_0, (*rg_10).w_4);
    var _S516 : vec4<f32> = (*isl_12).inertia0_0;
    var _S517 : vec4<f32> = (*isl_12).inertia1_0;
    var _S518 : vec4<f32> = (*isl_12).inertia2_0;
    var dl_turn_0 : vec3<f32> = rotate_0((*rg_10).rot_0, cross(phi_2, rows_mul_0((*isl_12).inertia0_0, (*isl_12).inertia1_0, (*isl_12).inertia2_0, b_38)) - rows_mul_0((*isl_12).inertia0_0, (*isl_12).inertia1_0, (*isl_12).inertia2_0, cross(phi_2, b_38)));
    var _S519 : Quat_0 = (*rg_10).rot_0;
    var _S520 : vec4<f32> = (*rg_10).rot_err_0;
    turn_right_0(&(_S519), &(_S520), phi_2);
    (*rg_10).rot_0 = _S519;
    (*rg_10).rot_err_0 = _S520;
    var _S521 : vec3<f32> = rotate_0(rot_2, dv_2 + cross(dw_1, (*isl_12).com_0.xyz - wcom_3));
    var _S522 : vec3<f32> = (*rg_10).vel_1;
    var _S523 : vec3<f32> = (*rg_10).vel_err_1;
    comp_add_0(&(_S522), &(_S523), _S521);
    (*rg_10).vel_1 = _S522;
    (*rg_10).vel_err_1 = _S523;
    var _S524 : vec3<f32> = rotate_0(rot_2, dw_1);
    (*rg_10).w_4 = (*rg_10).w_4 + _S524;
    var _S525 : vec3<f32> = dl_turn_0 + world_mul_0(_S519, _S516, _S517, _S518, _S524);
    var _S526 : vec3<f32> = (*rg_10).l_2;
    var _S527 : vec3<f32> = (*rg_10).l_err_1;
    comp_add_0(&(_S526), &(_S527), _S525);
    (*rg_10).l_2 = _S526;
    (*rg_10).l_err_1 = _S527;
    return;
}

fn drift_rigid_1( isl_13 : Island_0,  rg_11 : ptr<function, Rigid_0>,  tr_3 : vec3<f32>,  phi_3 : vec3<f32>,  dv_3 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = isl_13.wcom_0.xyz;
    var rot_3 : Quat_0 = (*rg_11).rot_0;
    var _S528 : vec3<f32> = rotate_0((*rg_11).rot_0, tr_3 - cross(phi_3, wcom_4));
    var _S529 : vec3<f32> = (*rg_11).pos_1;
    var _S530 : vec3<f32> = (*rg_11).pos_err_1;
    comp_add_0(&(_S529), &(_S530), _S528);
    (*rg_11).pos_1 = _S529;
    (*rg_11).pos_err_1 = _S530;
    var b_39 : vec3<f32> = inverse_rotate_0((*rg_11).rot_0, (*rg_11).w_4);
    var dl_turn_1 : vec3<f32> = rotate_0((*rg_11).rot_0, cross(phi_3, rows_mul_0(isl_13.inertia0_0, isl_13.inertia1_0, isl_13.inertia2_0, b_39)) - rows_mul_0(isl_13.inertia0_0, isl_13.inertia1_0, isl_13.inertia2_0, cross(phi_3, b_39)));
    var _S531 : Quat_0 = (*rg_11).rot_0;
    var _S532 : vec4<f32> = (*rg_11).rot_err_0;
    turn_right_0(&(_S531), &(_S532), phi_3);
    (*rg_11).rot_0 = _S531;
    (*rg_11).rot_err_0 = _S532;
    var _S533 : vec3<f32> = rotate_0(rot_3, dv_3 + cross(dw_2, isl_13.com_0.xyz - wcom_4));
    var _S534 : vec3<f32> = (*rg_11).vel_1;
    var _S535 : vec3<f32> = (*rg_11).vel_err_1;
    comp_add_0(&(_S534), &(_S535), _S533);
    (*rg_11).vel_1 = _S534;
    (*rg_11).vel_err_1 = _S535;
    var _S536 : vec3<f32> = rotate_0(rot_3, dw_2);
    (*rg_11).w_4 = (*rg_11).w_4 + _S536;
    var _S537 : vec3<f32> = dl_turn_1 + world_mul_0(_S531, isl_13.inertia0_0, isl_13.inertia1_0, isl_13.inertia2_0, _S536);
    var _S538 : vec3<f32> = (*rg_11).l_2;
    var _S539 : vec3<f32> = (*rg_11).l_err_1;
    comp_add_0(&(_S538), &(_S539), _S537);
    (*rg_11).l_2 = _S538;
    (*rg_11).l_err_1 = _S539;
    return;
}

fn write_probe_0( slot_1 : u32,  k_19 : u32,  value_1 : f32)
{
    var at_4 : u32 = params_0.probe_base_0 * u32(4) + slot_1 * params_0.probe_stride_0 + k_19;
    var v_15 : vec4<f32> = scratch_0[at_4 / u32(4)];
    v_15[at_4 % u32(4)] = value_1;
    scratch_0[at_4 / u32(4)] = v_15;
    return;
}

fn record_probes_0( isl_14 : Island_0,  rg_12 : Rigid_0,  k_20 : u32)
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
        var a_17 : vec4<f32> = loads_0[at_5 + u32(1)];
        var b_40 : vec4<f32> = loads_0[at_5 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_5 + u32(3)];
        var kind_5 : u32 = info_3.x;
        var i_9 : u32 = info_3.y;
        var value_2 : f32;
        if(kind_5 == u32(0))
        {
            value_2 = dot(rg_12.pos_1 - b_40.xyz + rotate_0(rg_12.rot_0, chunks_0[i_9].center_0.xyz) + (rg_12.pos_err_1 - c4_0.xyz + rotate_0(rg_12.rot_0, state_0[u32(4) * i_9].xyz + vec3<f32>(a_17.w, b_40.w, c4_0.w))), a_17.xyz);
        }
        else
        {
            if(kind_5 == u32(1))
            {
                var _S540 : u32 = u32(4) * i_9;
                value_2 = dot(rg_12.vel_1 + rg_12.vel_err_1 + cross(rg_12.w_4, rotate_0(rg_12.rot_0, chunks_0[i_9].center_0.xyz + state_0[_S540].xyz - isl_14.com_0.xyz)) + rotate_0(rg_12.rot_0, state_0[_S540 + u32(2)].xyz), a_17.xyz);
            }
            else
            {
                if(kind_5 == u32(2))
                {
                    var _S541 : u32 = u32(3) * i_9;
                    var f_17 : vec3<f32> = scratch_0[_S541].xyz;
                    var _S542 : bool = (info_3.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S542)
                    {
                        mc_0 = scratch_0[_S541 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S541 + u32(2)].xyz;
                    }
                    var fc_4 : vec3<f32>;
                    if(_S542)
                    {
                        fc_4 = f_17;
                    }
                    else
                    {
                        fc_4 = (vec3<f32>(0) - f_17);
                    }
                    value_2 = dot(fc_4, a_17.xyz) + dot(mc_0, b_40.xyz);
                }
                else
                {
                    var _S543 : u32 = u32(4) * i_9;
                    value_2 = dot(rotate_0(rg_12.rot_0, vec3<f32>(state_0[_S543 + u32(1)].w, state_0[_S543 + u32(2)].w, state_0[_S543 + u32(3)].w)), a_17.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_20, value_2);
        at_5 = at_5 + u32(4);
    }
    return;
}

fn contact_split_at_0( at_6 : u32)
{
    var previous_0 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S544 : u32;
    if(previous_0 == u32(0))
    {
        _S544 = at_6;
    }
    else
    {
        _S544 = min(previous_0, at_6);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S544;
    return;
}

fn seen_bits_0() -> u32
{
    var _S545 : u32;
    if((g_seen_0[u32(0)]) != u32(0))
    {
        _S545 = u32(32768);
    }
    else
    {
        _S545 = u32(0);
    }
    var _S546 : u32;
    if((g_seen_0[u32(1)]) != u32(0))
    {
        _S546 = u32(65536);
    }
    else
    {
        _S546 = u32(0);
    }
    var _S547 : u32 = (_S545 | (_S546));
    if((g_seen_0[u32(2)]) != u32(0))
    {
        _S545 = u32(131072);
    }
    else
    {
        _S545 = u32(0);
    }
    var _S548 : u32 = (_S547 | (_S545));
    if((g_seen_0[u32(3)]) != u32(0))
    {
        _S545 = u32(32);
    }
    else
    {
        _S545 = u32(0);
    }
    var _S549 : u32 = (_S548 | (_S545));
    if((g_seen_0[u32(4)]) != u32(0))
    {
        _S545 = u32(64);
    }
    else
    {
        _S545 = u32(0);
    }
    return (_S549 | (_S545));
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var woke_0 : bool;
    var tid_6 : u32 = thread_2.x;
    var _S550 : u32 = group_2.x;
    var isl_15 : Island_0;
    isl_15.range_0 = islands_0[_S550].range_0;
    isl_15.info_0 = islands_0[_S550].info_0;
    isl_15.com_0 = islands_0[_S550].com_0;
    isl_15.inertia0_0 = islands_0[_S550].inertia0_0;
    isl_15.inertia1_0 = islands_0[_S550].inertia1_0;
    isl_15.inertia2_0 = islands_0[_S550].inertia2_0;
    isl_15.inv0_0 = islands_0[_S550].inv0_0;
    isl_15.inv1_0 = islands_0[_S550].inv1_0;
    isl_15.inv2_0 = islands_0[_S550].inv2_0;
    isl_15.wcom_0 = islands_0[_S550].wcom_0;
    isl_15.winv0_0 = islands_0[_S550].winv0_0;
    isl_15.winv1_0 = islands_0[_S550].winv1_0;
    isl_15.winv2_0 = islands_0[_S550].winv2_0;
    isl_15.rotation_0 = islands_0[_S550].rotation_0;
    isl_15.position_0 = islands_0[_S550].position_0;
    isl_15.position_err_0 = islands_0[_S550].position_err_0;
    isl_15.velocity_0 = islands_0[_S550].velocity_0;
    isl_15.velocity_err_0 = islands_0[_S550].velocity_err_0;
    isl_15.angular_velocity_0 = islands_0[_S550].angular_velocity_0;
    isl_15.done_0 = islands_0[_S550].done_0;
    isl_15.coverage_0 = islands_0[_S550].coverage_0;
    isl_15.wide_groups_0 = islands_0[_S550].wide_groups_0;
    isl_15.done_pad_0 = islands_0[_S550].done_pad_0;
    isl_15.probes_0 = islands_0[_S550].probes_0;
    isl_15.energy_0 = islands_0[_S550].energy_0;
    isl_15.rotation_err_0 = islands_0[_S550].rotation_err_0;
    isl_15.momentum_0 = islands_0[_S550].momentum_0;
    isl_15.momentum_err_0 = islands_0[_S550].momentum_err_0;
    var driven_0 : bool = (((isl_15.info_0.x) & (u32(2)))) != u32(0);
    var _S551 : bool = !((((isl_15.info_0.x) & (u32(1)))) != u32(0));
    var _S552 : bool;
    if(_S551)
    {
        _S552 = !driven_0;
    }
    else
    {
        _S552 = false;
    }
    var contact_island_0 : bool = (((isl_15.info_0.x) & (u32(4)))) != u32(0);
    var _S553 : bool = (((isl_15.info_0.x) & (u32(16)))) != u32(0);
    seen_clear_0(tid_6);
    var _S554 : bool = tid_6 == u32(0);
    var settled_0 : bool;
    var cov_0 : u32;
    if(_S554)
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
            cov_0 = u32(0);
        }
        else
        {
            cov_0 = u32(1);
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
            cov_0 = u32(0);
        }
        g_run_0 = cov_0;
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
        cov_0 = u32(0);
    }
    else
    {
        cov_0 = min(isl_15.info_0.y, params_0.max_steps_0);
    }
    var _S555 : f32 = params_0.dt_0;
    var _S556 : bool = (params_0.fracture_0) != u32(0);
    var _S557 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_13 : Rigid_0 = rigid_of_1(isl_15);
    var work_4 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    settled_0 = _S553;
    var done_1 : u32 = u32(0);
    var woke_1 : bool = false;
    loop
    {
        if(done_1 < cov_0)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        var abs_step_1 : u32 = isl_15.info_0.w + done_1 + u32(1);
        var k_21 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var quiet_0 : bool = (((isl_15.info_0.x) & (u32(32)))) != u32(0);
        var _S558 : bool;
        if(settled_0)
        {
            _S558 = !quiet_0;
        }
        else
        {
            _S558 = false;
        }
        var _S559 : bool;
        var explicit_step_0 : bool;
        var c_20 : u32;
        if(_S558)
        {
            var _S560 : vec3<f32> = vec3<f32>(0.0f);
            var norm_0 : vec3<f32> = _S560;
            var unused0_0 : vec3<f32> = _S560;
            c_20 = isl_15.range_0.x + tid_6;
            loop
            {
                if(c_20 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S561 : f32 = settled_chunk_load_0(c_20, rg_13.rot_0, k_21, _S555, contact_island_0);
                norm_0[i32(0)] = norm_0[i32(0)] + _S561;
                c_20 = c_20 + u32(256);
            }
            group_sum3_0(tid_6, &(norm_0), &(unused0_0));
            if((params_0.solve_mode_0) == u32(1))
            {
                _S559 = (abs(norm_0.x - isl_15.energy_0.z)) > (isl_15.energy_0.w);
            }
            else
            {
                _S559 = false;
            }
            if(_S559)
            {
                explicit_step_0 = false;
                woke_0 = true;
            }
            else
            {
                explicit_step_0 = settled_0;
                woke_0 = woke_1;
            }
            settled_0 = explicit_step_0;
        }
        else
        {
            woke_0 = woke_1;
        }
        if(_S551)
        {
            _S559 = !quiet_0;
        }
        else
        {
            _S559 = false;
        }
        if(_S559)
        {
            var _S562 : vec3<f32> = vec3<f32>(0.0f);
            var f_18 : vec3<f32> = _S562;
            var t_16 : vec3<f32> = _S562;
            c_20 = isl_15.range_0.x + tid_6;
            loop
            {
                if(c_20 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                net_load_1(c_20, isl_15, rg_13, k_21, _S555, contact_island_0, &(f_18), &(t_16));
                c_20 = c_20 + u32(256);
            }
            group_sum3_0(tid_6, &(f_18), &(t_16));
            rigid_acceleration_1(isl_15, &(rg_13), f_18, t_16);
        }
        if(!settled_0)
        {
            explicit_step_0 = !quiet_0;
        }
        else
        {
            explicit_step_0 = false;
        }
        var c_21 : u32;
        if(explicit_step_0)
        {
            c_20 = isl_15.range_0.z + tid_6;
            loop
            {
                if(c_20 < (isl_15.range_0.w))
                {
                }
                else
                {
                    break;
                }
                var _S563 : bool = bond_update_0(c_20, _S555, _S556, abs_step_1, false);
                if(_S563)
                {
                    g_halt_0 = u32(1);
                }
                c_20 = c_20 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_21 = isl_15.range_0.x + tid_6;
            loop
            {
                if(c_21 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                chunk_update_1(c_21, isl_15, rg_13, _S555, _S557, k_21, contact_island_0, &(work_4), &(work_err_2));
                c_21 = c_21 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        var _S564 : bool;
        if(_S552)
        {
            _S564 = !quiet_0;
        }
        else
        {
            _S564 = false;
        }
        if(_S564)
        {
            integrate_rigid_1(isl_15, &(rg_13), _S555);
        }
        var _S565 : bool;
        if(_S551)
        {
            _S565 = explicit_step_0;
        }
        else
        {
            _S565 = false;
        }
        if(_S565)
        {
            var _S566 : vec3<f32> = isl_15.wcom_0.xyz;
            var _S567 : vec3<f32> = vec3<f32>(0.0f);
            var tu_1 : vec3<f32> = _S567;
            var pv_1 : vec3<f32> = _S567;
            c_20 = isl_15.range_0.x + tid_6;
            loop
            {
                if(c_20 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_20, &(tu_1), &(pv_1));
                c_20 = c_20 + u32(256);
            }
            group_sum3_0(tid_6, &(tu_1), &(pv_1));
            var tr_4 : vec3<f32> = tu_1 / vec3<f32>(isl_15.wcom_0.w);
            var dv_4 : vec3<f32> = pv_1 / vec3<f32>(isl_15.wcom_0.w);
            var lu_1 : vec3<f32> = _S567;
            var lv_1 : vec3<f32> = _S567;
            c_21 = isl_15.range_0.x + tid_6;
            loop
            {
                if(c_21 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_21, _S566, tr_4, dv_4, &(lu_1), &(lv_1));
                c_21 = c_21 + u32(256);
            }
            group_sum3_0(tid_6, &(lu_1), &(lv_1));
            var phi_4 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lu_1);
            var dw_3 : vec3<f32> = rows_mul_0(isl_15.winv0_0, isl_15.winv1_0, isl_15.winv2_0, lv_1);
            var c_22 : u32 = isl_15.range_0.x + tid_6;
            loop
            {
                if(c_22 < (isl_15.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_22, _S566, tr_4, phi_4, dv_4, dw_3);
                c_22 = c_22 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_15, &(rg_13), tr_4, phi_4, dv_4, dw_3);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        var _S568 : bool;
        if(_S554)
        {
            _S568 = (isl_15.probes_0.y) > (isl_15.probes_0.x);
        }
        else
        {
            _S568 = false;
        }
        if(_S568)
        {
            record_probes_0(isl_15, rg_13, k_21);
        }
        var _S569 : u32 = done_1 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S569;
            break;
        }
        done_1 = _S569;
        woke_1 = woke_0;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_4, work_err_2, 0.0f);
    var unused_1 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_6, &(wsum_0), &(unused_1));
    if(_S554)
    {
        isl_15.rotation_0 = quat_vec_0(rg_13.rot_0);
        isl_15.rotation_err_0 = rg_13.rot_err_0;
        isl_15.position_0 = vec4<f32>(rg_13.pos_1, 0.0f);
        isl_15.position_err_0 = vec4<f32>(rg_13.pos_err_1, 0.0f);
        isl_15.velocity_0 = vec4<f32>(rg_13.vel_1, 0.0f);
        isl_15.velocity_err_0 = vec4<f32>(rg_13.vel_err_1, 0.0f);
        isl_15.angular_velocity_0 = vec4<f32>(rg_13.w_4, 0.0f);
        isl_15.momentum_0 = vec4<f32>(rg_13.l_2, 0.0f);
        isl_15.momentum_err_0 = vec4<f32>(rg_13.l_err_1, 0.0f);
        isl_15.done_0 = done_1;
        isl_15.info_0[i32(1)] = isl_15.info_0[i32(1)] - done_1;
        if(g_halt_0 != u32(0))
        {
            _S552 = contact_island_0;
        }
        else
        {
            _S552 = false;
        }
        if(_S552)
        {
            contact_split_at_0(isl_15.info_0.w + done_1);
        }
        var _S570 : f32 = wsum_0.x;
        var _S571 : f32 = isl_15.energy_0[i32(0)];
        var _S572 : f32 = isl_15.energy_0[i32(1)];
        comp_add1_2(&(_S571), &(_S572), _S570);
        isl_15.energy_0[i32(0)] = _S571;
        isl_15.energy_0[i32(1)] = _S572 + wsum_0.y;
        isl_15.info_0[i32(3)] = isl_15.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_15.info_0[i32(2)] = ((isl_15.info_0[i32(2)]) | (u32(1)));
        }
        var _S573 : u32 = seen_bits_0();
        if(g_halt_0 != u32(0))
        {
            cov_0 = u32(128);
        }
        else
        {
            cov_0 = u32(0);
        }
        var _S574 : u32 = (_S573 | (cov_0));
        if(woke_0)
        {
            cov_0 = u32(2048);
        }
        else
        {
            cov_0 = u32(0);
        }
        var cov_1 : u32 = (_S574 | (cov_0));
        if(done_1 > u32(0))
        {
            var quiet_1 : bool = (((isl_15.info_0.x) & (u32(32)))) != u32(0);
            if(quiet_1)
            {
                cov_0 = u32(4096);
            }
            else
            {
                cov_0 = u32(0);
            }
            var cov_2 : u32 = (cov_1 | (cov_0));
            if((((isl_15.info_0.x) & (u32(16)))) != u32(0))
            {
                _S552 = !quiet_1;
            }
            else
            {
                _S552 = false;
            }
            if(_S552)
            {
                cov_0 = u32(512);
            }
            else
            {
                cov_0 = u32(0);
            }
            var cov_3 : u32 = (cov_2 | (cov_0));
            if((params_0.contact_mode_0) == u32(1))
            {
                cov_0 = u32(524288);
            }
            else
            {
                cov_0 = u32(0);
            }
            var cov_4 : u32 = (cov_3 | (cov_0));
            if((isl_15.probes_0.y) > (isl_15.probes_0.x))
            {
                cov_0 = u32(262144);
            }
            else
            {
                cov_0 = u32(0);
            }
            cov_0 = (cov_4 | (cov_0));
        }
        else
        {
            cov_0 = cov_1;
        }
        isl_15.coverage_0 = ((isl_15.coverage_0) | (cov_0));
        if(woke_0)
        {
            isl_15.info_0[i32(0)] = ((isl_15.info_0[i32(0)]) & (u32(4294967279)));
            isl_15.info_0[i32(2)] = ((isl_15.info_0[i32(2)]) | (u32(4)));
        }
        islands_0[_S550].range_0 = isl_15.range_0;
        islands_0[_S550].info_0 = isl_15.info_0;
        islands_0[_S550].com_0 = isl_15.com_0;
        islands_0[_S550].inertia0_0 = isl_15.inertia0_0;
        islands_0[_S550].inertia1_0 = isl_15.inertia1_0;
        islands_0[_S550].inertia2_0 = isl_15.inertia2_0;
        islands_0[_S550].inv0_0 = isl_15.inv0_0;
        islands_0[_S550].inv1_0 = isl_15.inv1_0;
        islands_0[_S550].inv2_0 = isl_15.inv2_0;
        islands_0[_S550].wcom_0 = isl_15.wcom_0;
        islands_0[_S550].winv0_0 = isl_15.winv0_0;
        islands_0[_S550].winv1_0 = isl_15.winv1_0;
        islands_0[_S550].winv2_0 = isl_15.winv2_0;
        islands_0[_S550].rotation_0 = isl_15.rotation_0;
        islands_0[_S550].position_0 = isl_15.position_0;
        islands_0[_S550].position_err_0 = isl_15.position_err_0;
        islands_0[_S550].velocity_0 = isl_15.velocity_0;
        islands_0[_S550].velocity_err_0 = isl_15.velocity_err_0;
        islands_0[_S550].angular_velocity_0 = isl_15.angular_velocity_0;
        islands_0[_S550].done_0 = isl_15.done_0;
        islands_0[_S550].coverage_0 = isl_15.coverage_0;
        islands_0[_S550].wide_groups_0 = isl_15.wide_groups_0;
        islands_0[_S550].done_pad_0 = isl_15.done_pad_0;
        islands_0[_S550].probes_0 = isl_15.probes_0;
        islands_0[_S550].energy_0 = isl_15.energy_0;
        islands_0[_S550].rotation_err_0 = isl_15.rotation_err_0;
        islands_0[_S550].momentum_0 = isl_15.momentum_0;
        islands_0[_S550].momentum_err_0 = isl_15.momentum_err_0;
    }
    return;
}

struct WideGroup_0
{
     island_2 : u32,
     begin_1 : u32,
     end_0 : u32,
     first_1 : u32,
};

fn wide_group_0( table_0 : u32,  g_3 : u32) -> WideGroup_0
{
    var w_11 : WideGroup_0;
    var _S575 : u32 = table_0 + u32(4) * g_3;
    w_11.island_2 = index_0[_S575];
    w_11.begin_1 = index_0[_S575 + u32(1)];
    w_11.end_0 = index_0[_S575 + u32(2)];
    w_11.first_1 = index_0[_S575 + u32(3)];
    return w_11;
}

fn wide_runs_0( isl_16 : ptr<function, Island_std430_0>) -> bool
{
    var _S576 : vec4<u32> = (*isl_16).info_0;
    var _S577 : bool;
    if(((((*isl_16).info_0.z) & (u32(1)))) != u32(0))
    {
        _S577 = true;
    }
    else
    {
        _S577 = (_S576.y) == u32(0);
    }
    if(_S577)
    {
        return false;
    }
    if((((_S576.x) & (u32(4)))) == u32(0))
    {
        _S577 = true;
    }
    else
    {
        var _S578 : bool = contact_stopped_0(&((*isl_16)));
        _S577 = !_S578;
    }
    return _S577;
}

fn wide_runs_1( isl_17 : ptr<function, Island_std430_0>) -> bool
{
    var _S579 : vec4<u32> = (*isl_17).info_0;
    var _S580 : bool;
    if(((((*isl_17).info_0.z) & (u32(1)))) != u32(0))
    {
        _S580 = true;
    }
    else
    {
        _S580 = (_S579.y) == u32(0);
    }
    if(_S580)
    {
        return false;
    }
    if((((_S579.x) & (u32(4)))) == u32(0))
    {
        _S580 = true;
    }
    else
    {
        var _S581 : bool = contact_stopped_0(&((*isl_17)));
        _S580 = !_S581;
    }
    return _S580;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_7 : u32,  isl_18 : ptr<function, Island_std430_0>) -> bool
{
    seen_clear_0(tid_7);
    if(tid_7 == u32(0))
    {
        var _S582 : bool = wide_runs_1(&((*isl_18)));
        var _S583 : i32;
        if(_S582)
        {
            _S583 = i32(1);
        }
        else
        {
            _S583 = i32(0);
        }
        g_wide_run_0 = u32(_S583);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

fn wide_step_0( isl_19 : ptr<function, Island_std430_0>) -> u32
{
    return (*isl_19).info_0.w - params_0.step_start_0;
}

fn wide_step_1( isl_20 : Island_0) -> u32
{
    return isl_20.info_0.w - params_0.step_start_0;
}

fn wide_enter_1( _S584 : u32,  _S585 : u32) -> bool
{
    var _S586 : Island_std430_0 = islands_0[_S585];
    seen_clear_0(_S584);
    if(_S584 == u32(0))
    {
        var _S587 : bool = wide_runs_0(&(_S586));
        var _S588 : i32;
        if(_S587)
        {
            _S588 = i32(1);
        }
        else
        {
            _S588 = i32(0);
        }
        g_wide_run_0 = u32(_S588);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_wake(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_8 : u32 = thread_3.x;
    var _S589 : u32 = group_3.x;
    var wg_0 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S589);
    if(_S589 != (wg_0.first_1))
    {
        return;
    }
    var _S590 : Island_std430_0 = islands_0[wg_0.island_2];
    var _S591 : vec4<u32> = _S590.info_0;
    var _S592 : u32 = _S590.info_0.x;
    var _S593 : bool;
    if(((_S592 & (u32(16)))) == u32(0))
    {
        _S593 = true;
    }
    else
    {
        var _S594 : bool = wide_enter_1(tid_8, wg_0.island_2);
        _S593 = !_S594;
    }
    if(_S593)
    {
        return;
    }
    var _S595 : Quat_0 = quat_of_0(_S590.rotation_0);
    var _S596 : bool = ((_S592 & (u32(4)))) != u32(0);
    var _S597 : vec3<f32> = vec3<f32>(0.0f);
    var norm_1 : vec3<f32> = _S597;
    var unused_2 : vec3<f32> = _S597;
    var _S598 : vec4<u32> = _S590.range_0;
    var c_23 : u32 = _S590.range_0.x + tid_8;
    loop
    {
        if(c_23 < (_S598.y))
        {
        }
        else
        {
            break;
        }
        var _S599 : u32 = wide_step_0(&(_S590));
        var _S600 : f32 = settled_chunk_load_0(c_23, _S595, _S599, params_0.dt_0, _S596);
        norm_1[i32(0)] = norm_1[i32(0)] + _S600;
        c_23 = c_23 + u32(256);
    }
    group_sum3_0(tid_8, &(norm_1), &(unused_2));
    if(tid_8 != u32(0))
    {
        return;
    }
    var cov_5 : u32 = (u32(1024) | ((seen_bits_0())));
    if((params_0.solve_mode_0) == u32(1))
    {
        _S593 = (abs(norm_1.x - _S590.energy_0.z)) > (_S590.energy_0.w);
    }
    else
    {
        _S593 = false;
    }
    var cov_6 : u32;
    if(_S593)
    {
        islands_0[wg_0.island_2].info_0[i32(0)] = (_S592 & (u32(4294967279)));
        islands_0[wg_0.island_2].info_0[i32(2)] = ((_S591.z) | (u32(4)));
        cov_6 = (cov_5 | (u32(2048)));
    }
    else
    {
        cov_6 = cov_5;
    }
    cov_mark_0(wg_0.island_2, _S590.coverage_0, cov_6);
    return;
}

fn wide_store_0( slot_2 : u32,  p_16 : u32,  a_18 : vec3<f32>,  b_41 : vec3<f32>)
{
    var _S601 : u32 = u32(8) * slot_2;
    scratch_0[params_0.wide_base_0 + _S601 + p_16] = vec4<f32>(a_18, 0.0f);
    scratch_0[params_0.wide_base_0 + _S601 + p_16 + u32(1)] = vec4<f32>(b_41, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_9 : u32 = thread_4.x;
    var _S602 : u32 = group_4.x;
    var bond_group_0 : bool = _S602 < (params_0.wide_bond_groups_0);
    var wg_1 : WideGroup_0;
    if(bond_group_0)
    {
        wg_1 = wide_group_0(params_0.wide_bond_table_0, _S602);
    }
    else
    {
        wg_1 = wide_group_0(params_0.wide_chunk_table_0, _S602 - params_0.wide_bond_groups_0);
    }
    var _S603 : WideGroup_0 = wg_1;
    var _S604 : Island_std430_0 = islands_0[wg_1.island_2];
    var _S605 : bool = wide_enter_1(tid_9, wg_1.island_2);
    if(!_S605)
    {
        return;
    }
    var _S606 : u32 = wide_step_0(&(_S604));
    if(bond_group_0)
    {
        var _S607 : vec4<u32> = _S604.info_0;
        if((((_S604.info_0.x) & (u32(16)))) != u32(0))
        {
            return;
        }
        var i_10 : u32 = wg_1.begin_1 + tid_9;
        var _S608 : bool;
        if(i_10 < (wg_1.end_0))
        {
            var _S609 : bool = bond_update_0(i_10, params_0.dt_0, (params_0.fracture_0) != u32(0), _S607.w + u32(1), true);
            _S608 = _S609;
        }
        else
        {
            _S608 = false;
        }
        if(_S608)
        {
            islands_0[_S603.island_2].info_0[i32(2)] = ((_S607.z) | (u32(2)));
        }
        return;
    }
    var _S610 : u32 = _S604.info_0.x;
    if(((_S610 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S611 : vec3<f32> = vec3<f32>(0.0f);
    var f_19 : vec3<f32> = _S611;
    var t_17 : vec3<f32> = _S611;
    var c_24 : u32 = wg_1.begin_1 + tid_9;
    if(c_24 < (wg_1.end_0))
    {
        var _S612 : Rigid_0 = rigid_of_0(&(_S604));
        net_load_0(c_24, &(_S604), _S612, _S606, params_0.dt_0, ((_S610 & (u32(4)))) != u32(0), &(f_19), &(t_17));
    }
    group_sum3_0(tid_9, &(f_19), &(t_17));
    if(tid_9 == u32(0))
    {
        wide_store_0(_S602 - params_0.wide_bond_groups_0, u32(0), f_19, t_17);
    }
    return;
}

fn wide_partials_0( tid_10 : u32,  first_2 : u32,  count_5 : u32,  p_17 : u32,  a_19 : ptr<function, vec3<f32>>,  b_42 : ptr<function, vec3<f32>>)
{
    var _S613 : vec4<f32> = vec4<f32>(0.0f);
    var x_16 : vec4<f32> = _S613;
    var y_2 : vec4<f32> = _S613;
    var s_9 : u32 = tid_10;
    loop
    {
        if(s_9 < count_5)
        {
        }
        else
        {
            break;
        }
        var _S614 : u32 = u32(8) * (first_2 + s_9);
        x_16 = x_16 + scratch_0[params_0.wide_base_0 + _S614 + p_17];
        y_2 = y_2 + scratch_0[params_0.wide_base_0 + _S614 + p_17 + u32(1)];
        s_9 = s_9 + u32(256);
    }
    group_sum2_0(tid_10, &(x_16), &(y_2));
    (*a_19) = x_16.xyz;
    (*b_42) = y_2.xyz;
    return;
}

fn wide_rigid_frame_0( tid_11 : u32,  isl_21 : ptr<function, Island_std430_0>,  wg_2 : WideGroup_0) -> Rigid_0
{
    var _S615 : Rigid_0 = rigid_of_0(&((*isl_21)));
    var rg_14 : Rigid_0 = _S615;
    if(((((*isl_21).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_20 : vec3<f32>;
        var t_18 : vec3<f32>;
        wide_partials_0(tid_11, wg_2.first_1, (*isl_21).wide_groups_0, u32(0), &(f_20), &(t_18));
        rigid_acceleration_0(&((*isl_21)), &(rg_14), f_20, t_18);
    }
    return rg_14;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_chunks(@builtin(workgroup_id) group_5 : vec3<u32>, @builtin(local_invocation_id) thread_5 : vec3<u32>)
{
    var tid_12 : u32 = thread_5.x;
    var _S616 : u32 = group_5.x;
    var wg_3 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S616);
    var _S617 : Island_std430_0 = islands_0[wg_3.island_2];
    var _S618 : bool = wide_enter_1(tid_12, wg_3.island_2);
    if(!_S618)
    {
        return;
    }
    var _S619 : u32 = _S617.info_0.x;
    var anchored_0 : bool = ((_S619 & (u32(1)))) != u32(0);
    if(((_S619 & (u32(16)))) != u32(0))
    {
        if(tid_12 == u32(0))
        {
            scratch_0[params_0.wide_base_0 + u32(8) * _S616 + u32(6)] = vec4<f32>(0.0f);
        }
        return;
    }
    var _S620 : Rigid_0 = wide_rigid_frame_0(tid_12, &(_S617), wg_3);
    var work_5 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S621 : vec3<f32> = vec3<f32>(0.0f);
    var tu_2 : vec3<f32> = _S621;
    var pv_2 : vec3<f32> = _S621;
    var c_25 : u32 = wg_3.begin_1 + tid_12;
    if(c_25 < (wg_3.end_0))
    {
        var _S622 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S623 : u32 = wide_step_0(&(_S617));
        chunk_update_0(c_25, &(_S617), _S620, params_0.dt_0, _S622, _S623, ((_S619 & (u32(4)))) != u32(0), &(work_5), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_25, &(tu_2), &(pv_2));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_5, work_err_3, 0.0f);
    var unused_3 : vec3<f32> = _S621;
    group_sum3_0(tid_12, &(wsum_1), &(unused_3));
    var _S624 : bool = !anchored_0;
    if(_S624)
    {
        group_sum3_0(tid_12, &(tu_2), &(pv_2));
    }
    if(tid_12 == u32(0))
    {
        var _S625 : u32 = u32(8) * _S616;
        scratch_0[params_0.wide_base_0 + _S625 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S624)
        {
            wide_store_0(_S616, u32(2), tu_2, pv_2);
        }
        scratch_0[params_0.wide_base_0 + _S625 + u32(7)] = vec4<f32>(f32(g_seen_0[u32(0)]), f32(g_seen_0[u32(1)]), f32(g_seen_0[u32(2)]), 0.0f);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var tid_13 : u32 = thread_6.x;
    var _S626 : u32 = group_6.x;
    var wg_4 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S626);
    var isl_22 : Island_std430_0 = islands_0[wg_4.island_2];
    var _S627 : bool;
    if((((islands_0[wg_4.island_2].info_0.x) & (u32(17)))) != u32(0))
    {
        _S627 = true;
    }
    else
    {
        var _S628 : bool = wide_enter_1(tid_13, wg_4.island_2);
        _S627 = !_S628;
    }
    if(_S627)
    {
        return;
    }
    var tu_3 : vec3<f32>;
    var pv_3 : vec3<f32>;
    wide_partials_0(tid_13, wg_4.first_1, isl_22.wide_groups_0, u32(2), &(tu_3), &(pv_3));
    var _S629 : vec3<f32> = vec3<f32>(isl_22.wcom_0.w);
    var tr_5 : vec3<f32> = tu_3 / _S629;
    var dv_5 : vec3<f32> = pv_3 / _S629;
    var _S630 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S630;
    var lv_2 : vec3<f32> = _S630;
    var c_26 : u32 = wg_4.begin_1 + tid_13;
    if(c_26 < (wg_4.end_0))
    {
        drift_angular_0(c_26, isl_22.wcom_0.xyz, tr_5, dv_5, &(lu_2), &(lv_2));
    }
    group_sum3_0(tid_13, &(lu_2), &(lv_2));
    if(tid_13 == u32(0))
    {
        wide_store_0(_S626, u32(4), lu_2, lv_2);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    var tid_14 : u32 = thread_7.x;
    var _S631 : u32 = group_7.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S631);
    var _S632 : Island_std430_0 = islands_0[wg_5.island_2];
    var _S633 : u32 = _S632.info_0.x;
    var _S634 : bool;
    if(((_S633 & (u32(1)))) != u32(0))
    {
        _S634 = true;
    }
    else
    {
        var _S635 : bool = wide_enter_1(tid_14, wg_5.island_2);
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
        var _S636 : Rigid_0 = wide_rigid_frame_0(tid_14, &(_S632), wg_5);
        var rs_0 : Rigid_0 = _S636;
        if(tid_14 != u32(0))
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
        islands_0[wg_5.island_2].rotation_0 = quat_vec_0(rs_0.rot_0);
        islands_0[wg_5.island_2].rotation_err_0 = rs_0.rot_err_0;
        islands_0[wg_5.island_2].position_0 = vec4<f32>(rs_0.pos_1, 0.0f);
        islands_0[wg_5.island_2].position_err_0 = vec4<f32>(rs_0.pos_err_1, 0.0f);
        islands_0[wg_5.island_2].velocity_0 = vec4<f32>(rs_0.vel_1, 0.0f);
        islands_0[wg_5.island_2].velocity_err_0 = vec4<f32>(rs_0.vel_err_1, 0.0f);
        islands_0[wg_5.island_2].angular_velocity_0 = vec4<f32>(rs_0.w_4, 0.0f);
        islands_0[wg_5.island_2].momentum_0 = vec4<f32>(rs_0.l_2, 0.0f);
        islands_0[wg_5.island_2].momentum_err_0 = vec4<f32>(rs_0.l_err_1, 0.0f);
        return;
    }
    var tu_4 : vec3<f32>;
    var pv_4 : vec3<f32>;
    wide_partials_0(tid_14, wg_5.first_1, _S632.wide_groups_0, u32(2), &(tu_4), &(pv_4));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_0(tid_14, wg_5.first_1, _S632.wide_groups_0, u32(4), &(lu_3), &(lv_3));
    var _S637 : vec4<f32> = _S632.wcom_0;
    var _S638 : vec3<f32> = vec3<f32>(_S632.wcom_0.w);
    var tr_6 : vec3<f32> = tu_4 / _S638;
    var dv_6 : vec3<f32> = pv_4 / _S638;
    var phi_5 : vec3<f32> = rows_mul_0(_S632.winv0_0, _S632.winv1_0, _S632.winv2_0, lu_3);
    var dw_4 : vec3<f32> = rows_mul_0(_S632.winv0_0, _S632.winv1_0, _S632.winv2_0, lv_3);
    var c_27 : u32 = wg_5.begin_1 + tid_14;
    if(c_27 < (wg_5.end_0))
    {
        drift_apply_0(c_27, _S637.xyz, tr_6, phi_5, dv_6, dw_4);
    }
    if(_S631 != (wg_5.first_1))
    {
        return;
    }
    var _S639 : Rigid_0 = wide_rigid_frame_0(tid_14, &(_S632), wg_5);
    var rg_15 : Rigid_0 = _S639;
    if(tid_14 != u32(0))
    {
        return;
    }
    if(!(((_S633 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S632), &(rg_15), params_0.dt_0);
        drift_rigid_0(&(_S632), &(rg_15), tr_6, phi_5, dv_6, dw_4);
    }
    islands_0[wg_5.island_2].rotation_0 = quat_vec_0(rg_15.rot_0);
    islands_0[wg_5.island_2].rotation_err_0 = rg_15.rot_err_0;
    islands_0[wg_5.island_2].position_0 = vec4<f32>(rg_15.pos_1, 0.0f);
    islands_0[wg_5.island_2].position_err_0 = vec4<f32>(rg_15.pos_err_1, 0.0f);
    islands_0[wg_5.island_2].velocity_0 = vec4<f32>(rg_15.vel_1, 0.0f);
    islands_0[wg_5.island_2].velocity_err_0 = vec4<f32>(rg_15.vel_err_1, 0.0f);
    islands_0[wg_5.island_2].angular_velocity_0 = vec4<f32>(rg_15.w_4, 0.0f);
    islands_0[wg_5.island_2].momentum_0 = vec4<f32>(rg_15.l_2, 0.0f);
    islands_0[wg_5.island_2].momentum_err_0 = vec4<f32>(rg_15.l_err_1, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_end(@builtin(workgroup_id) group_8 : vec3<u32>, @builtin(local_invocation_id) thread_8 : vec3<u32>)
{
    var tid_15 : u32 = thread_8.x;
    var _S640 : u32 = group_8.x;
    var wg_6 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S640);
    if(_S640 != (wg_6.first_1))
    {
        return;
    }
    var _S641 : Island_std430_0 = islands_0[wg_6.island_2];
    var isl_23 : Island_0;
    isl_23.range_0 = _S641.range_0;
    isl_23.info_0 = _S641.info_0;
    isl_23.com_0 = _S641.com_0;
    isl_23.inertia0_0 = _S641.inertia0_0;
    isl_23.inertia1_0 = _S641.inertia1_0;
    isl_23.inertia2_0 = _S641.inertia2_0;
    isl_23.inv0_0 = _S641.inv0_0;
    isl_23.inv1_0 = _S641.inv1_0;
    isl_23.inv2_0 = _S641.inv2_0;
    isl_23.wcom_0 = _S641.wcom_0;
    isl_23.winv0_0 = _S641.winv0_0;
    isl_23.winv1_0 = _S641.winv1_0;
    isl_23.winv2_0 = _S641.winv2_0;
    isl_23.rotation_0 = _S641.rotation_0;
    isl_23.position_0 = _S641.position_0;
    isl_23.position_err_0 = _S641.position_err_0;
    isl_23.velocity_0 = _S641.velocity_0;
    isl_23.velocity_err_0 = _S641.velocity_err_0;
    isl_23.angular_velocity_0 = _S641.angular_velocity_0;
    isl_23.done_0 = _S641.done_0;
    isl_23.coverage_0 = _S641.coverage_0;
    isl_23.wide_groups_0 = _S641.wide_groups_0;
    isl_23.done_pad_0 = _S641.done_pad_0;
    isl_23.probes_0 = _S641.probes_0;
    isl_23.energy_0 = _S641.energy_0;
    isl_23.rotation_err_0 = _S641.rotation_err_0;
    isl_23.momentum_0 = _S641.momentum_0;
    isl_23.momentum_err_0 = _S641.momentum_err_0;
    var _S642 : bool = wide_enter_0(tid_15, &(_S641));
    if(!_S642)
    {
        return;
    }
    var work_6 : vec3<f32>;
    var flags_3 : vec3<f32>;
    wide_partials_0(tid_15, wg_6.first_1, isl_23.wide_groups_0, u32(6), &(work_6), &(flags_3));
    if(tid_15 != u32(0))
    {
        return;
    }
    var k_22 : u32 = wide_step_1(isl_23);
    if((isl_23.probes_0.y) > (isl_23.probes_0.x))
    {
        record_probes_0(isl_23, rigid_of_1(isl_23), k_22);
    }
    var halt_0 : bool = (((isl_23.info_0.z) & (u32(2)))) != u32(0);
    var _S643 : bool;
    if(halt_0)
    {
        _S643 = (((isl_23.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        _S643 = false;
    }
    if(_S643)
    {
        contact_split_at_0(isl_23.info_0.w + u32(1));
    }
    var _S644 : f32 = work_6.x;
    var _S645 : f32 = isl_23.energy_0[i32(0)];
    var _S646 : f32 = isl_23.energy_0[i32(1)];
    comp_add1_2(&(_S645), &(_S646), _S644);
    isl_23.energy_0[i32(0)] = _S645;
    isl_23.energy_0[i32(1)] = _S646 + work_6.y;
    isl_23.done_0 = isl_23.done_0 + u32(1);
    isl_23.info_0[i32(1)] = isl_23.info_0[i32(1)] - u32(1);
    isl_23.info_0[i32(3)] = isl_23.info_0[i32(3)] + u32(1);
    if(halt_0)
    {
        isl_23.info_0[i32(2)] = ((((isl_23.info_0.z) & (u32(4294967293)))) | (u32(1)));
    }
    var _S647 : u32;
    if(halt_0)
    {
        _S647 = u32(128);
    }
    else
    {
        _S647 = u32(0);
    }
    var _S648 : u32 = (u32(256) | (_S647));
    if((isl_23.probes_0.y) > (isl_23.probes_0.x))
    {
        _S647 = u32(262144);
    }
    else
    {
        _S647 = u32(0);
    }
    var _S649 : u32 = (_S648 | (_S647));
    if((((isl_23.info_0.x) & (u32(4)))) != u32(0))
    {
        _S647 = u32(524288);
    }
    else
    {
        _S647 = u32(0);
    }
    var _S650 : u32 = (_S649 | (_S647));
    if((flags_3.x) > 0.0f)
    {
        _S647 = u32(32768);
    }
    else
    {
        _S647 = u32(0);
    }
    var _S651 : u32 = (_S650 | (_S647));
    if((flags_3.y) > 0.0f)
    {
        _S647 = u32(65536);
    }
    else
    {
        _S647 = u32(0);
    }
    var _S652 : u32 = (_S651 | (_S647));
    if((flags_3.z) > 0.0f)
    {
        _S647 = u32(131072);
    }
    else
    {
        _S647 = u32(0);
    }
    isl_23.coverage_0 = ((isl_23.coverage_0) | (((_S652 | (_S647)))));
    islands_0[wg_6.island_2].range_0 = isl_23.range_0;
    islands_0[wg_6.island_2].info_0 = isl_23.info_0;
    islands_0[wg_6.island_2].com_0 = isl_23.com_0;
    islands_0[wg_6.island_2].inertia0_0 = isl_23.inertia0_0;
    islands_0[wg_6.island_2].inertia1_0 = isl_23.inertia1_0;
    islands_0[wg_6.island_2].inertia2_0 = isl_23.inertia2_0;
    islands_0[wg_6.island_2].inv0_0 = isl_23.inv0_0;
    islands_0[wg_6.island_2].inv1_0 = isl_23.inv1_0;
    islands_0[wg_6.island_2].inv2_0 = isl_23.inv2_0;
    islands_0[wg_6.island_2].wcom_0 = isl_23.wcom_0;
    islands_0[wg_6.island_2].winv0_0 = isl_23.winv0_0;
    islands_0[wg_6.island_2].winv1_0 = isl_23.winv1_0;
    islands_0[wg_6.island_2].winv2_0 = isl_23.winv2_0;
    islands_0[wg_6.island_2].rotation_0 = isl_23.rotation_0;
    islands_0[wg_6.island_2].position_0 = isl_23.position_0;
    islands_0[wg_6.island_2].position_err_0 = isl_23.position_err_0;
    islands_0[wg_6.island_2].velocity_0 = isl_23.velocity_0;
    islands_0[wg_6.island_2].velocity_err_0 = isl_23.velocity_err_0;
    islands_0[wg_6.island_2].angular_velocity_0 = isl_23.angular_velocity_0;
    islands_0[wg_6.island_2].done_0 = isl_23.done_0;
    islands_0[wg_6.island_2].coverage_0 = isl_23.coverage_0;
    islands_0[wg_6.island_2].wide_groups_0 = isl_23.wide_groups_0;
    islands_0[wg_6.island_2].done_pad_0 = isl_23.done_pad_0;
    islands_0[wg_6.island_2].probes_0 = isl_23.probes_0;
    islands_0[wg_6.island_2].energy_0 = isl_23.energy_0;
    islands_0[wg_6.island_2].rotation_err_0 = isl_23.rotation_err_0;
    islands_0[wg_6.island_2].momentum_0 = isl_23.momentum_0;
    islands_0[wg_6.island_2].momentum_err_0 = isl_23.momentum_err_0;
    return;
}

fn sv_0( c_28 : u32,  slot_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * c_28 + slot_3;
}

fn project_load_slot_0( tid_16 : u32,  isl_24 : ptr<function, Island_std430_0>,  slot_4 : u32)
{
    var _S653 : u32;
    var _S654 : vec3<f32> = vec3<f32>(0.0f);
    var net_f_0 : vec3<f32> = _S654;
    var net_m_0 : vec3<f32> = _S654;
    var _S655 : vec4<u32> = (*isl_24).range_0;
    var _S656 : u32 = (*isl_24).range_0.x + tid_16;
    var c_29 : u32 = _S656;
    loop
    {
        var _S657 : u32 = _S655.y;
        _S653 = _S657;
        if(c_29 < _S657)
        {
        }
        else
        {
            break;
        }
        var fi_2 : vec3<f32> = scratch_0[sv_0(c_29, slot_4)].xyz;
        net_f_0 = net_f_0 + fi_2;
        net_m_0 = net_m_0 + (cross(chunks_0[c_29].center_0.xyz - (*isl_24).com_0.xyz, fi_2) + scratch_0[sv_0(c_29, slot_4 + u32(1))].xyz);
        c_29 = c_29 + u32(256);
    }
    group_sum3_0(tid_16, &(net_f_0), &(net_m_0));
    var _S658 : vec4<f32> = (*isl_24).com_0;
    var _S659 : vec3<f32> = net_f_0 / vec3<f32>((*isl_24).com_0.w);
    var _S660 : vec3<f32> = rows_mul_0((*isl_24).inv0_0, (*isl_24).inv1_0, (*isl_24).inv2_0, net_m_0);
    c_29 = _S656;
    loop
    {
        if(c_29 < _S653)
        {
        }
        else
        {
            break;
        }
        var _S661 : u32 = sv_0(c_29, slot_4);
        scratch_0[_S661] = vec4<f32>(scratch_0[_S661].xyz - (_S659 + cross(_S660, chunks_0[c_29].center_0.xyz - _S658.xyz)) * vec3<f32>(chunks_0[c_29].center_0.w), 0.0f);
        var _S662 : u32 = sv_0(c_29, slot_4 + u32(1));
        scratch_0[_S662] = vec4<f32>(scratch_0[_S662].xyz - rows_mul_0(chunks_0[c_29].inertia0_1, chunks_0[c_29].inertia1_1, chunks_0[c_29].inertia2_1, _S660), 0.0f);
        c_29 = c_29 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn island_dot_0( tid_17 : u32,  c0_0 : u32,  c1_0 : u32,  sa_0 : u32,  sb_0 : u32) -> f32
{
    var _S663 : vec4<f32> = vec4<f32>(0.0f);
    var acc_0 : vec4<f32> = _S663;
    var unused_4 : vec4<f32> = _S663;
    var c_30 : u32 = c0_0 + tid_17;
    loop
    {
        if(c_30 < c1_0)
        {
        }
        else
        {
            break;
        }
        acc_0[i32(0)] = acc_0[i32(0)] + (dot(scratch_0[sv_0(c_30, sa_0)].xyz, scratch_0[sv_0(c_30, sb_0)].xyz) + dot(scratch_0[sv_0(c_30, sa_0 + u32(1))].xyz, scratch_0[sv_0(c_30, sb_0 + u32(1))].xyz));
        c_30 = c_30 + u32(256);
    }
    group_sum2_1(tid_17, &(acc_0), &(unused_4));
    return acc_0.x;
}

fn static_kinematics_0( _S664 : u32,  _S665 : ptr<function, vec3<f32>>,  _S666 : ptr<function, vec3<f32>>)
{
    var ca_1 : u32 = bonds_0[_S664].law_0.ids_0.y;
    var cb_4 : u32 = bonds_0[_S664].law_0.ids_0.z;
    var _S667 : u32 = u32(4) * cb_4;
    var _S668 : u32 = u32(4) * ca_1;
    var _S669 : u32 = _S667 + u32(1);
    var _S670 : u32 = _S668 + u32(1);
    var _S671 : u32 = sv_0(cb_4, u32(22));
    var _S672 : u32 = sv_0(ca_1, u32(22));
    var dth_0 : vec3<f32> = state_0[_S669].xyz - state_0[_S670].xyz + (scratch_0[_S671].xyz - scratch_0[_S672].xyz);
    (*_S665) = to_local_0(_S664, state_0[_S667].xyz - state_0[_S668].xyz + (scratch_0[sv_0(cb_4, u32(21))].xyz - scratch_0[sv_0(ca_1, u32(21))].xyz) + (cross(state_0[_S669].xyz + scratch_0[_S671].xyz, bonds_0[_S664].rb_0.xyz) - cross(state_0[_S670].xyz + scratch_0[_S672].xyz, bonds_0[_S664].ra_0.xyz)));
    (*_S666) = to_local_0(_S664, dth_0);
    return;
}

fn static_response_0( i_11 : u32) -> JointResponse_0
{
    var d_lin_6 : vec3<f32>;
    var d_ang_4 : vec3<f32>;
    static_kinematics_0(i_11, &(d_lin_6), &(d_ang_4));
    var _S673 : JointBond_std430_0 = bonds_0[i_11].law_0;
    var _S674 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S673.ids_0.x];
    var _S675 : JointState_std430_0 = bond_dyn_0[i_11].js_0;
    var _S676 : JointResponse_0 = joint_evaluate_0(&(_S674), &(_S673), &(_S675), d_lin_6, d_ang_4, 0.0f, false);
    return _S676;
}

fn gather_loads_0( c_31 : u32,  fi_3 : ptr<function, vec3<f32>>,  mi_6 : ptr<function, vec3<f32>>)
{
    var _S677 : vec3<f32> = vec3<f32>(0.0f);
    (*fi_3) = _S677;
    (*mi_6) = _S677;
    var e_5 : u32 = index_0[c_31];
    loop
    {
        if(e_5 < index_0[c_31 + u32(1)])
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
            var _S678 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) + scratch_0[_S678].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S678 + u32(1)].xyz;
        }
        else
        {
            var _S679 : u32 = u32(3) * bond_0;
            (*fi_3) = (*fi_3) - scratch_0[_S679].xyz;
            (*mi_6) = (*mi_6) + scratch_0[_S679 + u32(2)].xyz;
        }
        e_5 = e_5 + u32(1);
    }
    return;
}

fn bond_load_magnitude2_0( c_32 : u32) -> f32
{
    var e_6 : u32 = index_0[c_32];
    var m_7 : f32 = 0.0f;
    loop
    {
        if(e_6 < index_0[c_32 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_5 : u32 = index_0[e_6];
        var _S680 : u32 = u32(3) * ((entry_5 >> (u32(1))));
        var f_21 : vec3<f32> = scratch_0[_S680].xyz;
        var t_19 : vec3<f32>;
        if(((entry_5 & (u32(1)))) == u32(0))
        {
            t_19 = scratch_0[_S680 + u32(1)].xyz;
        }
        else
        {
            t_19 = scratch_0[_S680 + u32(2)].xyz;
        }
        var m_8 : f32 = m_7 + (dot(f_21, f_21) + dot(t_19, t_19));
        e_6 = e_6 + u32(1);
        m_7 = m_8;
    }
    return m_7;
}

fn fixed_mask_0( c_33 : u32) -> u32
{
    var support_2 : u32 = chunks_0[c_33].info_1.x;
    var _S681 : u32;
    if(support_2 == u32(1))
    {
        _S681 = u32(63);
    }
    else
    {
        if(support_2 == u32(2))
        {
            _S681 = u32(7);
        }
        else
        {
            _S681 = u32(0);
        }
    }
    return _S681;
}

fn hold_0( mask_0 : u32,  lin_0 : ptr<function, vec4<f32>>,  ang_0 : ptr<function, vec4<f32>>,  keep_lin_0 : vec4<f32>,  keep_ang_0 : vec4<f32>)
{
    var d_17 : u32 = u32(0);
    loop
    {
        if(d_17 < u32(3))
        {
        }
        else
        {
            break;
        }
        if(((mask_0 & (((u32(1) << (d_17)))))) != u32(0))
        {
            (*lin_0)[d_17] = keep_lin_0[d_17];
        }
        if(((mask_0 & (((u32(1) << ((d_17 + u32(3)))))))) != u32(0))
        {
            (*ang_0)[d_17] = keep_ang_0[d_17];
        }
        d_17 = d_17 + u32(1);
    }
    return;
}

fn statics_bond_slot_0( i_12 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * i_12;
}

fn store_inverse_0( c_34 : u32,  a_20 : array<f32, i32(36)>)
{
    var j_8 : u32;
    var sum_6 : f32;
    var l_5 : array<f32, i32(36)>;
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
        l_5[k_23] = 0.0f;
        k_23 = k_23 + u32(1);
    }
    var spd_0 : bool = true;
    var i_13 : u32 = u32(0);
    loop
    {
        var _S682 : bool;
        if(i_13 < u32(6))
        {
            _S682 = spd_0;
        }
        else
        {
            _S682 = false;
        }
        if(_S682)
        {
        }
        else
        {
            break;
        }
        j_8 = u32(0);
        loop
        {
            if(j_8 <= i_13)
            {
            }
            else
            {
                break;
            }
            var _S683 : u32 = i_13 * u32(6);
            var _S684 : u32 = _S683 + j_8;
            k_23 = u32(0);
            sum_6 = a_20[_S684];
            loop
            {
                if(k_23 < j_8)
                {
                }
                else
                {
                    break;
                }
                var sum_7 : f32 = sum_6 - l_5[_S683 + k_23] * l_5[j_8 * u32(6) + k_23];
                k_23 = k_23 + u32(1);
                sum_6 = sum_7;
            }
            if(i_13 == j_8)
            {
                if(sum_6 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S683 + i_13] = sqrt(sum_6);
            }
            else
            {
                l_5[_S684] = sum_6 / l_5[j_8 * u32(6) + j_8];
            }
            j_8 = j_8 + u32(1);
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
            var _S685 : u32 = k_23 * u32(6) + k_23;
            if((a_20[_S685]) > 0.0f)
            {
                sum_6 = 1.0f / a_20[_S685];
            }
            else
            {
                sum_6 = 0.0f;
            }
            inv_0[_S685] = sum_6;
            k_23 = k_23 + u32(1);
        }
    }
    else
    {
        j_8 = u32(0);
        loop
        {
            if(j_8 < u32(6))
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
                if(i_13 == j_8)
                {
                    sum_6 = 1.0f;
                }
                else
                {
                    sum_6 = 0.0f;
                }
                k_23 = u32(0);
                var s_10 : f32 = sum_6;
                loop
                {
                    if(k_23 < i_13)
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_11 : f32 = s_10 - l_5[i_13 * u32(6) + k_23] * y_3[k_23];
                    k_23 = k_23 + u32(1);
                    s_10 = s_11;
                }
                y_3[i_13] = s_10 / l_5[i_13 * u32(6) + i_13];
                i_13 = i_13 + u32(1);
            }
            var x_17 : array<f32, i32(6)>;
            x_17[i32(0)] = 0.0f;
            x_17[i32(1)] = 0.0f;
            x_17[i32(2)] = 0.0f;
            x_17[i32(3)] = 0.0f;
            x_17[i32(4)] = 0.0f;
            x_17[i32(5)] = 0.0f;
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
                sum_6 = y_3[i_14];
                loop
                {
                    if(k_23 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_12 : f32 = sum_6 - l_5[k_23 * u32(6) + i_14] * x_17[k_23];
                    k_23 = k_23 + u32(1);
                    sum_6 = s_12;
                }
                x_17[i_14] = sum_6 / l_5[i_14 * u32(6) + i_14];
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
                inv_0[i_15 * u32(6) + j_8] = x_17[i_15];
                i_15 = i_15 + u32(1);
            }
            j_8 = j_8 + u32(1);
        }
    }
    j_8 = u32(0);
    loop
    {
        if(j_8 < u32(9))
        {
        }
        else
        {
            break;
        }
        var _S686 : u32 = u32(4) * j_8;
        scratch_0[sv_0(c_34, u32(12) + j_8)] = vec4<f32>(inv_0[_S686], inv_0[_S686 + u32(1)], inv_0[_S686 + u32(2)], inv_0[_S686 + u32(3)]);
        j_8 = j_8 + u32(1);
    }
    return;
}

fn assemble_block_0( c_35 : u32)
{
    var p_18 : u32;
    var r_14 : u32;
    var a_21 : array<f32, i32(36)>;
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
        a_21[k_24] = 0.0f;
        k_24 = k_24 + u32(1);
    }
    var e_7 : u32 = index_0[c_35];
    loop
    {
        if(e_7 < index_0[c_35 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_6 : u32 = index_0[e_7];
        var i_16 : u32 = (entry_6 >> (u32(1)));
        var _S687 : bool = ((entry_6 & (u32(1)))) != u32(0);
        var _S688 : u32 = statics_bond_slot_0(i_16);
        var _S689 : vec4<f32> = scratch_0[_S688];
        var _S690 : vec4<f32> = scratch_0[_S688 + u32(1)];
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
            var _S691 : u32 = p_18 % u32(3);
            var t_20 : vec3<f32>;
            if(_S691 == u32(0))
            {
                t_20 = bonds_0[i_16].t1_0.xyz;
            }
            else
            {
                if(_S691 == u32(1))
                {
                    t_20 = bonds_0[i_16].t2_0.xyz;
                }
                else
                {
                    t_20 = bonds_0[i_16].normal_0.xyz;
                }
            }
            var _S692 : bool = p_18 < u32(3);
            var row_u_0 : vec3<f32>;
            var row_t_0 : vec3<f32>;
            if(_S692)
            {
                if(_S687)
                {
                    row_u_0 = t_20;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_20);
                }
                if(_S687)
                {
                    row_t_0 = cross(bonds_0[i_16].rb_0.xyz, t_20);
                }
                else
                {
                    row_t_0 = (vec3<f32>(0) - cross(bonds_0[i_16].ra_0.xyz, t_20));
                }
            }
            else
            {
                var _S693 : vec3<f32> = vec3<f32>(0.0f);
                if(_S687)
                {
                    row_u_0 = t_20;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_20);
                }
                var _S694 : vec3<f32> = row_u_0;
                row_u_0 = _S693;
                row_t_0 = _S694;
            }
            var kp_0 : f32;
            if(_S692)
            {
                kp_0 = _S689[p_18];
            }
            else
            {
                kp_0 = _S690[p_18 - u32(3)];
            }
            if(kp_0 == 0.0f)
            {
                p_18 = p_18 + u32(1);
                continue;
            }
            var _S695 : array<f32, i32(6)> = array<f32, i32(6)>( row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z );
            r_14 = u32(0);
            loop
            {
                if(r_14 < u32(6))
                {
                }
                else
                {
                    break;
                }
                var q_14 : u32 = u32(0);
                loop
                {
                    if(q_14 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_21[r_14 * u32(6) + q_14] = a_21[r_14 * u32(6) + q_14] + kp_0 * _S695[r_14] * _S695[q_14];
                    q_14 = q_14 + u32(1);
                }
                r_14 = r_14 + u32(1);
            }
            p_18 = p_18 + u32(1);
        }
        e_7 = e_7 + u32(1);
    }
    var _S696 : u32 = fixed_mask_0(c_35);
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
        if(((_S696 & (((u32(1) << (p_18)))))) != u32(0))
        {
            r_14 = u32(0);
            loop
            {
                if(r_14 < u32(6))
                {
                }
                else
                {
                    break;
                }
                a_21[p_18 * u32(6) + r_14] = 0.0f;
                a_21[r_14 * u32(6) + p_18] = 0.0f;
                r_14 = r_14 + u32(1);
            }
            a_21[p_18 * u32(6) + p_18] = 1.0f;
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
        if((a_21[p_18 * u32(6) + p_18]) == 0.0f)
        {
            a_21[p_18 * u32(6) + p_18] = 1.0f;
        }
        p_18 = p_18 + u32(1);
    }
    store_inverse_0(c_35, a_21);
    return;
}

fn block_get_0( c_36 : u32,  i_17 : u32,  j_9 : u32) -> f32
{
    var k_25 : u32 = i_17 * u32(6) + j_9;
    return scratch_0[sv_0(c_36, u32(12) + k_25 / u32(4))][k_25 % u32(4)];
}

fn precondition_0( c_37 : u32)
{
    var _S697 : array<f32, i32(6)> = array<f32, i32(6)>( scratch_0[sv_0(c_37, u32(4))].x, scratch_0[sv_0(c_37, u32(4))].y, scratch_0[sv_0(c_37, u32(4))].z, scratch_0[sv_0(c_37, u32(5))].x, scratch_0[sv_0(c_37, u32(5))].y, scratch_0[sv_0(c_37, u32(5))].z );
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
        var j_10 : u32 = u32(0);
        var s_13 : f32 = 0.0f;
        loop
        {
            if(j_10 < u32(6))
            {
            }
            else
            {
                break;
            }
            var s_14 : f32 = s_13 + block_get_0(c_37, i_18, j_10) * _S697[j_10];
            j_10 = j_10 + u32(1);
            s_13 = s_14;
        }
        z_1[i_18] = s_13;
        i_18 = i_18 + u32(1);
    }
    scratch_0[sv_0(c_37, u32(6))] = vec4<f32>(z_1[i32(0)], z_1[i32(1)], z_1[i32(2)], 0.0f);
    scratch_0[sv_0(c_37, u32(7))] = vec4<f32>(z_1[i32(3)], z_1[i32(4)], z_1[i32(5)], 0.0f);
    return;
}

fn project_displacement_slot_0( tid_18 : u32,  isl_25 : ptr<function, Island_std430_0>,  slot_5 : u32)
{
    var _S698 : u32;
    var _S699 : vec3<f32> = vec3<f32>(0.0f);
    var p_19 : vec3<f32> = _S699;
    var l_6 : vec3<f32> = _S699;
    var _S700 : vec4<u32> = (*isl_25).range_0;
    var _S701 : u32 = (*isl_25).range_0.x + tid_18;
    var c_38 : u32 = _S701;
    loop
    {
        var _S702 : u32 = _S700.y;
        _S698 = _S702;
        if(c_38 < _S702)
        {
        }
        else
        {
            break;
        }
        var u_6 : vec3<f32> = scratch_0[sv_0(c_38, slot_5)].xyz;
        var th_8 : vec3<f32> = scratch_0[sv_0(c_38, slot_5 + u32(1))].xyz;
        var r_15 : vec3<f32> = chunks_0[c_38].center_0.xyz - (*isl_25).com_0.xyz;
        var _S703 : vec3<f32> = vec3<f32>(chunks_0[c_38].center_0.w);
        p_19 = p_19 + u_6 * _S703;
        l_6 = l_6 + (cross(r_15, u_6) * _S703 + rows_mul_0(chunks_0[c_38].inertia0_1, chunks_0[c_38].inertia1_1, chunks_0[c_38].inertia2_1, th_8));
        c_38 = c_38 + u32(256);
    }
    group_sum3_0(tid_18, &(p_19), &(l_6));
    var _S704 : vec4<f32> = (*isl_25).com_0;
    var _S705 : vec3<f32> = p_19 / vec3<f32>((*isl_25).com_0.w);
    var _S706 : vec3<f32> = rows_mul_0((*isl_25).inv0_0, (*isl_25).inv1_0, (*isl_25).inv2_0, l_6);
    c_38 = _S701;
    loop
    {
        if(c_38 < _S698)
        {
        }
        else
        {
            break;
        }
        var _S707 : u32 = sv_0(c_38, slot_5);
        scratch_0[_S707] = vec4<f32>(scratch_0[_S707].xyz - _S705 - cross(_S706, chunks_0[c_38].center_0.xyz - _S704.xyz), 0.0f);
        var _S708 : u32 = sv_0(c_38, slot_5 + u32(1));
        scratch_0[_S708] = vec4<f32>(scratch_0[_S708].xyz - _S706, 0.0f);
        c_38 = c_38 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn statics_result_slot_0( island_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * params_0.statics_bonds_0 + island_3;
}

fn write_bond_loads_0( _S709 : u32,  _S710 : u32,  _S711 : vec3<f32>,  _S712 : vec3<f32>,  _S713 : f32)
{
    var _S714 : vec3<f32> = to_body_0(_S710, _S711);
    var _S715 : vec3<f32> = to_body_0(_S710, _S712);
    var _S716 : u32 = u32(3) * _S709;
    scratch_0[_S716] = vec4<f32>(_S714, _S713);
    scratch_0[_S716 + u32(1)] = vec4<f32>(_S715 + cross(bonds_0[_S710].ra_0.xyz, _S714), 0.0f);
    scratch_0[_S716 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S715) + cross(bonds_0[_S710].rb_0.xyz, (vec3<f32>(0) - _S714)), 0.0f);
    return;
}

fn static_kinematics_1( _S717 : u32,  _S718 : ptr<function, vec3<f32>>,  _S719 : ptr<function, vec3<f32>>)
{
    var ca_2 : u32 = bonds_0[_S717].law_0.ids_0.y;
    var cb_5 : u32 = bonds_0[_S717].law_0.ids_0.z;
    var _S720 : u32 = u32(4) * cb_5;
    var _S721 : u32 = u32(4) * ca_2;
    var _S722 : u32 = _S720 + u32(1);
    var _S723 : u32 = _S721 + u32(1);
    var _S724 : u32 = sv_0(cb_5, u32(22));
    var _S725 : u32 = sv_0(ca_2, u32(22));
    var dth_1 : vec3<f32> = state_0[_S722].xyz - state_0[_S723].xyz + (scratch_0[_S724].xyz - scratch_0[_S725].xyz);
    (*_S718) = to_local_0(_S717, state_0[_S720].xyz - state_0[_S721].xyz + (scratch_0[sv_0(cb_5, u32(21))].xyz - scratch_0[sv_0(ca_2, u32(21))].xyz) + (cross(state_0[_S722].xyz + scratch_0[_S724].xyz, bonds_0[_S717].rb_0.xyz) - cross(state_0[_S723].xyz + scratch_0[_S725].xyz, bonds_0[_S717].ra_0.xyz)));
    (*_S719) = to_local_0(_S717, dth_1);
    return;
}

fn bond_kinematics_0( _S726 : u32,  _S727 : vec3<f32>,  _S728 : vec3<f32>,  _S729 : vec3<f32>,  _S730 : vec3<f32>,  _S731 : ptr<function, vec3<f32>>,  _S732 : ptr<function, vec3<f32>>)
{
    (*_S731) = to_local_0(_S726, _S729 + cross(_S730, bonds_0[_S726].rb_0.xyz) - (_S727 + cross(_S728, bonds_0[_S726].ra_0.xyz)));
    (*_S732) = to_local_0(_S726, _S730 - _S728);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_statics(@builtin(workgroup_id) group_9 : vec3<u32>, @builtin(local_invocation_id) thread_9 : vec3<u32>)
{
    var i_19 : u32;
    var converged_0 : bool;
    var c_39 : u32;
    var tid_19 : u32 = thread_9.x;
    var _S733 : u32 = group_9.x;
    var _S734 : Island_std430_0 = islands_0[_S733];
    var _S735 : vec4<u32> = _S734.info_0;
    var _S736 : u32 = _S734.info_0.z;
    if(((_S736 & (u32(8)))) == u32(0))
    {
        return;
    }
    var free_0 : bool = (((_S735.x) & (u32(1)))) == u32(0);
    var c0_1 : u32 = _S734.range_0.x;
    var c1_1 : u32 = _S734.range_0.y;
    var b0_0 : u32 = _S734.range_0.z;
    var _S737 : u32 = _S734.range_0.w;
    var _S738 : u32 = c0_1 + tid_19;
    var c_40 : u32 = _S738;
    loop
    {
        if(c_40 < c1_1)
        {
        }
        else
        {
            break;
        }
        var _S739 : vec4<f32> = vec4<f32>(0.0f);
        scratch_0[sv_0(c_40, u32(21))] = _S739;
        scratch_0[sv_0(c_40, u32(22))] = _S739;
        c_40 = c_40 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    if(free_0)
    {
        project_load_slot_0(tid_19, &(_S734), u32(0));
    }
    var _S740 : f32 = island_dot_0(tid_19, c0_1, c1_1, u32(0), u32(0));
    var _S741 : f32 = max(sqrt(_S740), 1.00000000317107685e-30f);
    var _S742 : f32 = params_0.statics_tol_0;
    var _S743 : u32 = min(params_0.statics_cg_0, u32(20) * (c1_1 - c0_1) * u32(6) + u32(200));
    var previous_1 : f32 = 1.00000001504746622e+30f;
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
        var _S744 : u32 = b0_0 + tid_19;
        i_19 = _S744;
        loop
        {
            if(i_19 < _S737)
            {
            }
            else
            {
                break;
            }
            var resp_2 : JointResponse_0 = static_response_0(i_19);
            write_bond_loads_0(i_19, i_19, resp_2.force_lin_1, resp_2.force_ang_1, 0.0f);
            i_19 = i_19 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S745 : vec4<f32> = vec4<f32>(0.0f);
        var magnitude_0 : vec4<f32> = _S745;
        var unused_m_0 : vec4<f32> = _S745;
        c_40 = _S738;
        loop
        {
            if(c_40 < c1_1)
            {
            }
            else
            {
                break;
            }
            var fi_4 : vec3<f32>;
            var mi_7 : vec3<f32>;
            gather_loads_0(c_40, &(fi_4), &(mi_7));
            magnitude_0[i32(0)] = magnitude_0[i32(0)] + bond_load_magnitude2_0(c_40);
            var r_lin_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_40, u32(0))].xyz + fi_4, 0.0f);
            var r_ang_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_40, u32(1))].xyz + mi_7, 0.0f);
            hold_0(fixed_mask_0(c_40), &(r_lin_0), &(r_ang_0), _S745, _S745);
            scratch_0[sv_0(c_40, u32(4))] = r_lin_0;
            scratch_0[sv_0(c_40, u32(5))] = r_ang_0;
            c_40 = c_40 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        group_sum2_0(tid_19, &(magnitude_0), &(unused_m_0));
        if(free_0)
        {
            project_load_slot_0(tid_19, &(_S734), u32(4));
        }
        var _S746 : f32 = island_dot_0(tid_19, c0_1, c1_1, u32(4), u32(4));
        var residual_1 : f32 = sqrt(_S746) / _S741;
        var _S747 : f32 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S741);
        if(residual_1 <= _S742)
        {
            converged_0 = true;
        }
        else
        {
            if(residual_1 <= _S747)
            {
                converged_0 = residual_1 > (0.5f * previous_1);
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
        var i_20 : u32 = _S744;
        loop
        {
            if(i_20 < _S737)
            {
            }
            else
            {
                break;
            }
            var d_lin_7 : vec3<f32>;
            var d_ang_5 : vec3<f32>;
            static_kinematics_1(i_20, &(d_lin_7), &(d_ang_5));
            var _S748 : JointBond_std430_0 = bonds_0[i_20].law_0;
            var _S749 : JointState_std430_0 = bond_dyn_0[i_20].js_0;
            var f_lin_3 : vec3<f32>;
            var f_ang_3 : vec3<f32>;
            secant_factors_0(&(_S748), &(_S749), d_lin_7, &(f_lin_3), &(f_ang_3));
            var _S750 : u32 = statics_bond_slot_0(i_20);
            var _S751 : f32 = _S748.stiff0_0.y;
            scratch_0[_S750] = vec4<f32>(_S751 * f_lin_3.x, _S751 * f_lin_3.y, _S748.stiff0_0.x * f_lin_3.z, 0.0f);
            scratch_0[_S750 + u32(1)] = vec4<f32>(_S748.stiff0_0.z * f_ang_3.x, _S748.stiff0_0.w * f_ang_3.y, _S748.stiff1_0.x * f_ang_3.z, 0.0f);
            i_20 = i_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_41 : u32 = _S738;
        loop
        {
            if(c_41 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_41);
            scratch_0[sv_0(c_41, u32(2))] = _S745;
            scratch_0[sv_0(c_41, u32(3))] = _S745;
            c_41 = c_41 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_42 : u32 = _S738;
        loop
        {
            if(c_42 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_42);
            c_42 = c_42 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(free_0)
        {
            project_displacement_slot_0(tid_19, &(_S734), u32(6));
        }
        var c_43 : u32 = _S738;
        loop
        {
            if(c_43 < c1_1)
            {
            }
            else
            {
                break;
            }
            scratch_0[sv_0(c_43, u32(8))] = scratch_0[sv_0(c_43, u32(6))];
            scratch_0[sv_0(c_43, u32(9))] = scratch_0[sv_0(c_43, u32(7))];
            c_43 = c_43 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S752 : f32 = island_dot_0(tid_19, c0_1, c1_1, u32(4), u32(6));
        var _S753 : f32 = island_dot_0(tid_19, c0_1, c1_1, u32(4), u32(4));
        var _S754 : f32 = sqrt(_S753);
        var rz_0 : f32 = _S752;
        var k_26 : u32 = u32(0);
        var cg_total_1 : u32 = cg_total_0;
        loop
        {
            var _S755 : bool;
            if(k_26 < _S743)
            {
                _S755 = _S754 > 0.0f;
            }
            else
            {
                _S755 = false;
            }
            if(_S755)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            var i_21 : u32 = _S744;
            loop
            {
                if(i_21 < _S737)
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
                var _S756 : u32 = statics_bond_slot_0(i_21);
                write_bond_loads_0(i_21, i_21, d_lin_8 * scratch_0[_S756].xyz, d_ang_6 * scratch_0[_S756 + u32(1)].xyz, 0.0f);
                i_21 = i_21 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_39 = _S738;
            loop
            {
                if(c_39 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var fi_5 : vec3<f32>;
                var mi_8 : vec3<f32>;
                gather_loads_0(c_39, &(fi_5), &(mi_8));
                var ap_lin_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - fi_5), 0.0f);
                var ap_ang_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - mi_8), 0.0f);
                hold_0(fixed_mask_0(c_39), &(ap_lin_0), &(ap_ang_0), scratch_0[sv_0(c_39, u32(8))], scratch_0[sv_0(c_39, u32(9))]);
                scratch_0[sv_0(c_39, u32(10))] = ap_lin_0;
                scratch_0[sv_0(c_39, u32(11))] = ap_ang_0;
                c_39 = c_39 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var pap_0 : f32 = island_dot_0(tid_19, c0_1, c1_1, u32(8), u32(10));
            var _S757 : u32 = cg_total_1 + u32(1);
            if(pap_0 <= 0.0f)
            {
                cg_total_0 = _S757;
                break;
            }
            var _S758 : f32 = rz_0 / pap_0;
            var c_44 : u32 = _S738;
            loop
            {
                if(c_44 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S759 : u32 = sv_0(c_44, u32(2));
                var _S760 : vec3<f32> = vec3<f32>(_S758);
                scratch_0[_S759] = vec4<f32>(scratch_0[_S759].xyz + _S760 * scratch_0[sv_0(c_44, u32(8))].xyz, 0.0f);
                var _S761 : u32 = sv_0(c_44, u32(3));
                scratch_0[_S761] = vec4<f32>(scratch_0[_S761].xyz + _S760 * scratch_0[sv_0(c_44, u32(9))].xyz, 0.0f);
                var _S762 : u32 = sv_0(c_44, u32(4));
                scratch_0[_S762] = vec4<f32>(scratch_0[_S762].xyz - _S760 * scratch_0[sv_0(c_44, u32(10))].xyz, 0.0f);
                var _S763 : u32 = sv_0(c_44, u32(5));
                scratch_0[_S763] = vec4<f32>(scratch_0[_S763].xyz - _S760 * scratch_0[sv_0(c_44, u32(11))].xyz, 0.0f);
                c_44 = c_44 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S764 : f32 = island_dot_0(tid_19, c0_1, c1_1, u32(4), u32(4));
            if((sqrt(_S764)) <= (0.00009999999747379f * _S754))
            {
                cg_total_0 = _S757;
                break;
            }
            var c_45 : u32 = _S738;
            loop
            {
                if(c_45 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_45);
                c_45 = c_45 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            if(free_0)
            {
                project_displacement_slot_0(tid_19, &(_S734), u32(6));
            }
            var rz_new_0 : f32 = island_dot_0(tid_19, c0_1, c1_1, u32(4), u32(6));
            var _S765 : f32 = rz_new_0 / rz_0;
            var c_46 : u32 = _S738;
            loop
            {
                if(c_46 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S766 : u32 = sv_0(c_46, u32(8));
                var _S767 : vec3<f32> = vec3<f32>(_S765);
                scratch_0[_S766] = vec4<f32>(scratch_0[sv_0(c_46, u32(6))].xyz + _S767 * scratch_0[_S766].xyz, 0.0f);
                var _S768 : u32 = sv_0(c_46, u32(9));
                scratch_0[_S768] = vec4<f32>(scratch_0[sv_0(c_46, u32(7))].xyz + _S767 * scratch_0[_S768].xyz, 0.0f);
                c_46 = c_46 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S769 : u32 = k_26 + u32(1);
            rz_0 = rz_new_0;
            k_26 = _S769;
            cg_total_1 = _S757;
        }
        c_39 = _S738;
        loop
        {
            if(c_39 < c1_1)
            {
            }
            else
            {
                break;
            }
            var _S770 : u32 = u32(4) * c_39;
            var u_7 : vec3<f32> = state_0[_S770].xyz;
            var _S771 : u32 = sv_0(c_39, u32(21));
            var u_lo_0 : vec3<f32> = scratch_0[_S771].xyz;
            var _S772 : u32 = _S770 + u32(1);
            var th_9 : vec3<f32> = state_0[_S772].xyz;
            var _S773 : u32 = sv_0(c_39, u32(22));
            var th_lo_0 : vec3<f32> = scratch_0[_S773].xyz;
            comp_add_0(&(u_7), &(u_lo_0), scratch_0[sv_0(c_39, u32(2))].xyz);
            comp_add_0(&(th_9), &(th_lo_0), scratch_0[sv_0(c_39, u32(3))].xyz);
            state_0[_S770] = vec4<f32>(u_7, state_0[_S770].w);
            state_0[_S772] = vec4<f32>(th_9, state_0[_S772].w);
            scratch_0[_S771] = vec4<f32>(u_lo_0, 0.0f);
            scratch_0[_S773] = vec4<f32>(th_lo_0, 0.0f);
            c_39 = c_39 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S774 : u32 = newton_0 + u32(1);
        previous_1 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S774;
    }
    i_19 = b0_0 + tid_19;
    loop
    {
        if(i_19 < _S737)
        {
        }
        else
        {
            break;
        }
        var resp_3 : JointResponse_0 = static_response_0(i_19);
        var _S775 : JointState_0 = JointState_0( bond_dyn_0[i_19].js_0.damage_0, bond_dyn_0[i_19].js_0.crush_1, bond_dyn_0[i_19].js_0.kappa_0, bond_dyn_0[i_19].js_0.kappa_c_0, bond_dyn_0[i_19].js_0.ductility_0, bond_dyn_0[i_19].js_0.ductility_c_0, bond_dyn_0[i_19].js_0.life_0, bond_dyn_0[i_19].js_0.plastic_x_0, bond_dyn_0[i_19].js_0.plastic_y_0, bond_dyn_0[i_19].js_0.plastic_t_0, bond_dyn_0[i_19].js_0.rebar_plastic_0, bond_dyn_0[i_19].js_0.rebar_slip0_0, bond_dyn_0[i_19].js_0.rebar_slip1_0, bond_dyn_0[i_19].js_0.rebar_work_0, bond_dyn_0[i_19].js_0.rebar_broken_0, bond_dyn_0[i_19].js_0.strain_rate_0, bond_dyn_0[i_19].js_0.governing_stress_0, bond_dyn_0[i_19].js_0.dissipated_0, bond_dyn_0[i_19].js_0.utilization_0, bond_dyn_0[i_19].js_0.mode_0 );
        var bd_1 : BondDyn_0;
        bd_1.js_0 = _S775;
        bd_1.force_lin_0 = bond_dyn_0[i_19].force_lin_0;
        bd_1.force_ang_0 = bond_dyn_0[i_19].force_ang_0;
        bd_1.sums_0 = bond_dyn_0[i_19].sums_0;
        bd_1.comps_0 = bond_dyn_0[i_19].comps_0;
        bd_1.events_0 = bond_dyn_0[i_19].events_0;
        bd_1.force_lin_0 = vec4<f32>(resp_3.force_lin_1, resp_3.stored_6);
        bd_1.force_ang_0 = vec4<f32>(resp_3.force_ang_1, bd_1.force_ang_0.w);
        bond_dyn_0[i_19].js_0.damage_0 = bd_1.js_0.damage_0;
        bond_dyn_0[i_19].js_0.crush_1 = bd_1.js_0.crush_1;
        bond_dyn_0[i_19].js_0.kappa_0 = bd_1.js_0.kappa_0;
        bond_dyn_0[i_19].js_0.kappa_c_0 = bd_1.js_0.kappa_c_0;
        bond_dyn_0[i_19].js_0.ductility_0 = bd_1.js_0.ductility_0;
        bond_dyn_0[i_19].js_0.ductility_c_0 = bd_1.js_0.ductility_c_0;
        bond_dyn_0[i_19].js_0.life_0 = bd_1.js_0.life_0;
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
        write_bond_loads_0(i_19, i_19, resp_3.force_lin_1, resp_3.force_ang_1, max(resp_3.measures_0.tension_0, resp_3.measures_0.compression_0));
        i_19 = i_19 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    c_40 = _S738;
    loop
    {
        if(c_40 < c1_1)
        {
        }
        else
        {
            break;
        }
        var fi_6 : vec3<f32>;
        var mi_9 : vec3<f32>;
        gather_loads_0(c_40, &(fi_6), &(mi_9));
        var reaction_2 : vec3<f32>;
        if((fixed_mask_0(c_40)) != u32(0))
        {
            reaction_2 = (vec3<f32>(0) - (scratch_0[sv_0(c_40, u32(0))].xyz + fi_6));
        }
        else
        {
            var _S776 : u32 = u32(4) * c_40;
            reaction_2 = vec3<f32>(state_0[_S776 + u32(1)].w, state_0[_S776 + u32(2)].w, state_0[_S776 + u32(3)].w);
        }
        var _S777 : u32 = u32(4) * c_40;
        var _S778 : u32 = _S777 + u32(1);
        state_0[_S778] = vec4<f32>(state_0[_S778].xyz, reaction_2.x);
        state_0[_S777 + u32(2)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.y);
        state_0[_S777 + u32(3)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_2.z);
        c_40 = c_40 + u32(256);
    }
    if(tid_19 == u32(0))
    {
        var _S779 : f32 = (bitcast<f32>((newton_0)));
        var _S780 : f32 = (bitcast<f32>((cg_total_0)));
        if(converged_0)
        {
            previous_1 = 1.0f;
        }
        else
        {
            previous_1 = 0.0f;
        }
        scratch_0[statics_result_slot_0(_S733)] = vec4<f32>(residual_0, _S779, _S780, previous_1);
        islands_0[_S733].info_0[i32(2)] = (_S736 & (u32(4294967287)));
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn settled_fatigue(@builtin(workgroup_id) group_10 : vec3<u32>, @builtin(local_invocation_id) thread_10 : vec3<u32>)
{
    var tid_20 : u32 = thread_10.x;
    var _S781 : u32 = group_10.x;
    var isl_26 : Island_std430_0 = islands_0[_S781];
    var _S782 : bool;
    if((((islands_0[_S781].info_0.x) & (u32(16)))) == u32(0))
    {
        _S782 = true;
    }
    else
    {
        _S782 = (isl_26.range_0.w) == (isl_26.range_0.z);
    }
    if(_S782)
    {
        return;
    }
    seen_clear_0(tid_20);
    if(tid_20 == u32(0))
    {
        g_halt_0 = u32(0);
        g_run_0 = u32(0);
    }
    workgroupBarrier();
    var _S783 : u32 = isl_26.info_0.w;
    var i_22 : u32 = isl_26.range_0.z + tid_20;
    loop
    {
        if(i_22 < (isl_26.range_0.w))
        {
        }
        else
        {
            break;
        }
        var _S784 : JointState_0 = JointState_0( bond_dyn_0[i_22].js_0.damage_0, bond_dyn_0[i_22].js_0.crush_1, bond_dyn_0[i_22].js_0.kappa_0, bond_dyn_0[i_22].js_0.kappa_c_0, bond_dyn_0[i_22].js_0.ductility_0, bond_dyn_0[i_22].js_0.ductility_c_0, bond_dyn_0[i_22].js_0.life_0, bond_dyn_0[i_22].js_0.plastic_x_0, bond_dyn_0[i_22].js_0.plastic_y_0, bond_dyn_0[i_22].js_0.plastic_t_0, bond_dyn_0[i_22].js_0.rebar_plastic_0, bond_dyn_0[i_22].js_0.rebar_slip0_0, bond_dyn_0[i_22].js_0.rebar_slip1_0, bond_dyn_0[i_22].js_0.rebar_work_0, bond_dyn_0[i_22].js_0.rebar_broken_0, bond_dyn_0[i_22].js_0.strain_rate_0, bond_dyn_0[i_22].js_0.governing_stress_0, bond_dyn_0[i_22].js_0.dissipated_0, bond_dyn_0[i_22].js_0.utilization_0, bond_dyn_0[i_22].js_0.mode_0 );
        var bd_2 : BondDyn_0;
        bd_2.js_0 = _S784;
        bd_2.force_lin_0 = bond_dyn_0[i_22].force_lin_0;
        bd_2.force_ang_0 = bond_dyn_0[i_22].force_ang_0;
        bd_2.sums_0 = bond_dyn_0[i_22].sums_0;
        bd_2.comps_0 = bond_dyn_0[i_22].comps_0;
        bd_2.events_0 = bond_dyn_0[i_22].events_0;
        var _S785 : JointBond_std430_0 = bonds_0[i_22].law_0;
        var _S786 : u32 = u32(4) * _S785.ids_0.y;
        var _S787 : u32 = u32(4) * _S785.ids_0.z;
        var d_lin_9 : vec3<f32>;
        var d_ang_7 : vec3<f32>;
        bond_kinematics_0(i_22, state_0[_S786].xyz, state_0[_S786 + u32(1)].xyz, state_0[_S787].xyz, state_0[_S787 + u32(1)].xyz, &(d_lin_9), &(d_ang_7));
        var _S788 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S785.ids_0.x];
        var previous_2 : JointState_0 = bd_2.js_0;
        var _S789 : JointResponse_0 = joint_evaluate_1(&(_S788), &(_S785), bd_2.js_0, d_lin_9, d_ang_7, params_0.dt_0, (params_0.fracture_0) != u32(0));
        if((_S789.state_1.damage_0) > (bd_2.js_0.damage_0 + 9.99999971718068537e-10f))
        {
            _S782 = true;
        }
        else
        {
            _S782 = (_S789.state_1.crush_1) > (previous_2.crush_1 + 9.99999971718068537e-10f);
        }
        var flags_4 : u32;
        if(_S782)
        {
            flags_4 = u32(16);
        }
        else
        {
            flags_4 = u32(0);
        }
        var _S790 : f32 = bd_2.sums_0[i32(0)];
        var _S791 : f32 = bd_2.comps_0[i32(0)];
        comp_add1_2(&(_S790), &(_S791), _S789.dissipated_3);
        bd_2.sums_0[i32(0)] = _S790;
        bd_2.comps_0[i32(0)] = _S791;
        var _S792 : f32 = bd_2.sums_0[i32(1)];
        var _S793 : f32 = bd_2.comps_0[i32(1)];
        comp_add1_2(&(_S792), &(_S793), _S789.overshoot_0);
        bd_2.sums_0[i32(1)] = _S792;
        bd_2.comps_0[i32(1)] = _S793;
        bd_2.force_lin_0 = vec4<f32>(_S789.force_lin_1, _S789.stored_6);
        bd_2.force_ang_0 = vec4<f32>(_S789.force_ang_1, max(bd_2.force_ang_0.w, _S789.state_1.utilization_0));
        var _S794 : bool;
        if(!is_damaged_1(previous_2))
        {
            _S794 = is_damaged_1(_S789.state_1);
        }
        else
        {
            _S794 = false;
        }
        var _S795 : bool;
        if(_S794)
        {
            _S795 = (bd_2.events_0.x) == u32(0);
        }
        else
        {
            _S795 = false;
        }
        if(_S795)
        {
            bd_2.events_0[i32(0)] = _S783;
            bd_2.events_0[i32(3)] = _S789.state_1.mode_0;
            g_seen_0[u32(3)] = u32(1);
        }
        var _S796 : bool;
        if((bd_2.events_0.y) == u32(0))
        {
            _S796 = (_S789.state_1.life_0) != (previous_2.life_0);
        }
        else
        {
            _S796 = false;
        }
        var _S797 : bool;
        if(_S796)
        {
            _S797 = (_S789.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S797 = false;
        }
        var _S798 : bool;
        if(_S797)
        {
            var _S799 : f32 = fatigue_factor_1(&(_S788), _S789.state_1.life_0);
            _S798 = _S799 <= 0.99000000953674316f;
        }
        else
        {
            _S798 = false;
        }
        if(_S798)
        {
            bd_2.events_0[i32(1)] = _S783;
            g_seen_0[u32(4)] = u32(1);
        }
        var flags_5 : u32;
        if(_S789.disconnected_0)
        {
            bd_2.events_0[i32(2)] = _S783;
            flags_5 = (flags_4 | (u32(32)));
        }
        else
        {
            flags_5 = flags_4;
        }
        bd_2.js_0 = _S789.state_1;
        bond_dyn_0[i_22].js_0.damage_0 = bd_2.js_0.damage_0;
        bond_dyn_0[i_22].js_0.crush_1 = bd_2.js_0.crush_1;
        bond_dyn_0[i_22].js_0.kappa_0 = bd_2.js_0.kappa_0;
        bond_dyn_0[i_22].js_0.kappa_c_0 = bd_2.js_0.kappa_c_0;
        bond_dyn_0[i_22].js_0.ductility_0 = bd_2.js_0.ductility_0;
        bond_dyn_0[i_22].js_0.ductility_c_0 = bd_2.js_0.ductility_c_0;
        bond_dyn_0[i_22].js_0.life_0 = bd_2.js_0.life_0;
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
        write_bond_loads_0(i_22, i_22, _S789.force_lin_1, _S789.force_ang_1, max(_S789.measures_0.tension_0, _S789.measures_0.compression_0));
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
    if(tid_20 != u32(0))
    {
        return;
    }
    if(((g_halt_0 | (g_run_0))) != u32(0))
    {
        var _S800 : u32 = isl_26.info_0.z;
        if(g_halt_0 != u32(0))
        {
            i_22 = u32(16);
        }
        else
        {
            i_22 = u32(0);
        }
        var _S801 : u32 = (_S800 | (i_22));
        if(g_run_0 != u32(0))
        {
            i_22 = u32(32);
        }
        else
        {
            i_22 = u32(0);
        }
        islands_0[_S781].info_0[i32(2)] = (_S801 | (i_22));
    }
    var _S802 : u32 = ((((isl_26.coverage_0) | (u32(16384)))) | ((seen_bits_0())));
    if(g_run_0 != u32(0))
    {
        i_22 = u32(128);
    }
    else
    {
        i_22 = u32(0);
    }
    islands_0[_S781].coverage_0 = (_S802 | (i_22));
    return;
}

