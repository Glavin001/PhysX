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
    @align(4) pc_steps_0 : u32,
    @align(8) pc_base_0 : u32,
    @align(4) pi_base_0 : u32,
    @align(16) bond_count_0 : u32,
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
    @align(16) start_vel_0 : vec4<f32>,
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

fn group_sum3_1( tid_3 : u32,  a_3 : ptr<function, vec3<f32>>,  b_3 : ptr<function, vec3<f32>>)
{
    var x_1 : vec4<f32> = vec4<f32>((*a_3), 0.0f);
    var y_1 : vec4<f32> = vec4<f32>((*b_3), 0.0f);
    group_sum2_1(tid_3, &(x_1), &(y_1));
    (*a_3) = x_1.xyz;
    (*b_3) = y_1.xyz;
    return;
}

fn group_sum2_2( tid_4 : u32,  a_4 : ptr<function, vec4<f32>>,  b_4 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_4] = (*a_4);
    g_red_b_0[tid_4] = (*b_4);
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
        if(tid_4 < s_2)
        {
            var _S3 : u32 = tid_4 + s_2;
            g_red_a_0[tid_4] = g_red_a_0[tid_4] + g_red_a_0[_S3];
            g_red_b_0[tid_4] = g_red_b_0[tid_4] + g_red_b_0[_S3];
        }
        workgroupBarrier();
        s_2 = (s_2 >> (u32(1)));
    }
    (*a_4) = g_red_a_0[i32(0)];
    (*b_4) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

fn group_sum2_3( tid_5 : u32,  a_5 : ptr<function, vec4<f32>>,  b_5 : ptr<function, vec4<f32>>)
{
    g_red_a_0[tid_5] = (*a_5);
    g_red_b_0[tid_5] = (*b_5);
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
        if(tid_5 < s_3)
        {
            var _S4 : u32 = tid_5 + s_3;
            g_red_a_0[tid_5] = g_red_a_0[tid_5] + g_red_a_0[_S4];
            g_red_b_0[tid_5] = g_red_b_0[tid_5] + g_red_b_0[_S4];
        }
        workgroupBarrier();
        s_3 = (s_3 >> (u32(1)));
    }
    (*a_5) = g_red_a_0[i32(0)];
    (*b_5) = g_red_b_0[i32(0)];
    workgroupBarrier();
    return;
}

fn pair_lane_count_0() -> u32
{
    return u32(1);
}

fn stopped_0() -> bool
{
    var _S5 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S6 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S6 = true;
    }
    else
    {
        _S6 = (_S5.y) != u32(0);
    }
    return _S6;
}

fn pair_any_0( x_2 : bool,  lanes_0 : u32) -> bool
{
    return x_2;
}

struct Quat_0
{
     w_0 : f32,
     x_3 : f32,
     y_2 : f32,
     z_0 : f32,
};

fn quat_of_0( q_0 : vec4<f32>) -> Quat_0
{
    var r_0 : Quat_0;
    r_0.x_3 = q_0.x;
    r_0.y_2 = q_0.y;
    r_0.z_0 = q_0.z;
    r_0.w_0 = q_0.w;
    return r_0;
}

fn rotate_0( q_1 : Quat_0,  v_0 : vec3<f32>) -> vec3<f32>
{
    var qv_0 : vec3<f32> = vec3<f32>(q_1.x_3, q_1.y_2, q_1.z_0);
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

fn world_diff_0( a_6 : WorldPoint_0,  b_6 : WorldPoint_0) -> vec3<f32>
{
    return a_6.hi_0 - b_6.hi_0 + (a_6.lo_0 - b_6.lo_0) + (a_6.rel_0 - b_6.rel_0);
}

fn safe_normalize_0( v_1 : vec3<f32>) -> vec3<f32>
{
    var n_0 : f32 = length(v_1);
    var _S7 : vec3<f32>;
    if(n_0 > 1.00000000317107685e-30f)
    {
        _S7 = v_1 / vec3<f32>(n_0);
    }
    else
    {
        _S7 = vec3<f32>(0.0f);
    }
    return _S7;
}

fn from_axis_angle_0( axis_0 : vec3<f32>,  angle_0 : f32) -> Quat_0
{
    var a_7 : vec3<f32> = safe_normalize_0(axis_0);
    var _S8 : f32 = 0.5f * angle_0;
    var s_4 : f32 = sin(_S8);
    var q_3 : Quat_0;
    q_3.w_0 = cos(_S8);
    q_3.x_3 = a_7.x * s_4;
    q_3.y_2 = a_7.y * s_4;
    q_3.z_0 = a_7.z * s_4;
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
    var b_7 : Box_0;
    b_7.center_1 = center_2;
    b_7.axis0_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.x, chunks_0[c_1].crot1_0.x, chunks_0[c_1].crot2_0.x)));
    b_7.axis1_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.y, chunks_0[c_1].crot1_0.y, chunks_0[c_1].crot2_0.y)));
    b_7.axis2_0 = rotate_0(q_4, rotate_0(hidden_0, vec3<f32>(chunks_0[c_1].crot0_0.z, chunks_0[c_1].crot1_0.z, chunks_0[c_1].crot2_0.z)));
    b_7.half_2 = chunks_0[c_1].half_0.xyz;
    b_7.hull_at_0 = (bitcast<u32>((chunks_0[c_1].cmat_0.z)));
    var _S9 : u32 = (bitcast<u32>((chunks_0[c_1].cmat_0.w)));
    b_7.hull_v_0 = (_S9 & (u32(255)));
    b_7.hull_f_0 = (_S9 >> (u32(8)));
    return b_7;
}

fn sample_count_0( b_8 : Box_0) -> u32
{
    var _S10 : u32;
    if((b_8.hull_v_0) == u32(0))
    {
        _S10 = u32(14);
    }
    else
    {
        _S10 = b_8.hull_v_0 + b_8.hull_f_0;
    }
    return _S10;
}

fn may_overlap_0( a_8 : Box_0,  b_9 : Box_0) -> bool
{
    var _S11 : vec3<f32> = b_9.center_1 - a_8.center_1;
    var _S12 : f32 = 0.00000999999974738f * (length(a_8.half_2) + length(b_9.half_2));
    var _S13 : array<vec3<f32>, i32(6)> = array<vec3<f32>, i32(6)>( a_8.axis0_0, a_8.axis1_0, a_8.axis2_0, b_9.axis0_0, b_9.axis1_0, b_9.axis2_0 );
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
            l_0 = _S13[i_0];
        }
        else
        {
            var _S14 : u32 = i_0 - u32(6);
            l_0 = cross(_S13[_S14 / u32(3)], _S13[u32(3) + _S14 % u32(3)]);
        }
        var len_0 : f32 = length(l_0);
        if(len_0 <= 9.99999997475242708e-07f)
        {
            i_0 = i_0 + u32(1);
            continue;
        }
        if((abs(dot(_S11, l_0))) > (a_8.half_2.x * abs(dot(a_8.axis0_0, l_0)) + a_8.half_2.y * abs(dot(a_8.axis1_0, l_0)) + a_8.half_2.z * abs(dot(a_8.axis2_0, l_0)) + (b_9.half_2.x * abs(dot(b_9.axis0_0, l_0)) + b_9.half_2.y * abs(dot(b_9.axis1_0, l_0)) + b_9.half_2.z * abs(dot(b_9.axis2_0, l_0))) + _S12 * len_0))
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
    var _S15 : u32 = u32(4) * c_2;
    var _S16 : vec3<f32> = islands_0[chunks_0[c_2].info_1.y].angular_velocity_0.xyz;
    (*v_2) = islands_0[chunks_0[c_2].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_2].info_1.y].velocity_err_0.xyz + cross(_S16, rotate_0(q_5, chunks_0[c_2].center_0.xyz + state_0[_S15].xyz - islands_0[chunks_0[c_2].info_1.y].com_0.xyz)) + rotate_0(q_5, state_0[_S15 + u32(2)].xyz);
    (*w_2) = _S16 + rotate_0(q_5, state_0[_S15 + u32(3)].xyz);
    return;
}

fn chunk_velocity_1( c_3 : u32,  v_3 : ptr<function, vec3<f32>>,  w_3 : ptr<function, vec3<f32>>)
{
    var q_6 : Quat_0 = quat_of_0(islands_0[chunks_0[c_3].info_1.y].rotation_0);
    var _S17 : u32 = u32(4) * c_3;
    var _S18 : vec3<f32> = islands_0[chunks_0[c_3].info_1.y].angular_velocity_0.xyz;
    (*v_3) = islands_0[chunks_0[c_3].info_1.y].velocity_0.xyz + islands_0[chunks_0[c_3].info_1.y].velocity_err_0.xyz + cross(_S18, rotate_0(q_6, chunks_0[c_3].center_0.xyz + state_0[_S17].xyz - islands_0[chunks_0[c_3].info_1.y].com_0.xyz)) + rotate_0(q_6, state_0[_S17 + u32(2)].xyz);
    (*w_3) = _S18 + rotate_0(q_6, state_0[_S17 + u32(3)].xyz);
    return;
}

fn box_to_world_0( b_10 : Box_0,  local_0 : vec3<f32>) -> vec3<f32>
{
    return b_10.axis0_0 * vec3<f32>(local_0.x) + b_10.axis1_0 * vec3<f32>(local_0.y) + b_10.axis2_0 * vec3<f32>(local_0.z);
}

fn box_axis_0( b_11 : Box_0,  k_0 : u32) -> vec3<f32>
{
    var _S19 : vec3<f32>;
    if(k_0 == u32(0))
    {
        _S19 = b_11.axis0_0;
    }
    else
    {
        if(k_0 == u32(1))
        {
            _S19 = b_11.axis1_0;
        }
        else
        {
            _S19 = b_11.axis2_0;
        }
    }
    return _S19;
}

fn comp3_0( v_4 : vec3<f32>,  k_1 : u32) -> f32
{
    var _S20 : f32;
    if(k_1 == u32(0))
    {
        _S20 = v_4.x;
    }
    else
    {
        if(k_1 == u32(1))
        {
            _S20 = v_4.y;
        }
        else
        {
            _S20 = v_4.z;
        }
    }
    return _S20;
}

fn sample_point_0( b_12 : Box_0,  i_1 : u32) -> vec3<f32>
{
    if((b_12.hull_v_0) != u32(0))
    {
        var local_1 : vec3<f32>;
        if(i_1 < (b_12.hull_v_0))
        {
            local_1 = loads_0[b_12.hull_at_0 + i_1].xyz * vec3<f32>(0.89999997615814209f);
        }
        else
        {
            local_1 = loads_0[b_12.hull_at_0 + b_12.hull_v_0 + b_12.hull_f_0 + (i_1 - b_12.hull_v_0)].xyz;
        }
        return b_12.center_1 + box_to_world_0(b_12, local_1);
    }
    var sign_0 : f32;
    if(i_1 < u32(8))
    {
        var h_0 : vec3<f32> = b_12.half_2 * vec3<f32>(0.89999997615814209f);
        if(((i_1 & (u32(1)))) == u32(0))
        {
            sign_0 = - h_0.x;
        }
        else
        {
            sign_0 = h_0.x;
        }
        var _S21 : f32;
        if(((i_1 & (u32(2)))) == u32(0))
        {
            _S21 = - h_0.y;
        }
        else
        {
            _S21 = h_0.y;
        }
        var _S22 : f32;
        if(((i_1 & (u32(4)))) == u32(0))
        {
            _S22 = - h_0.z;
        }
        else
        {
            _S22 = h_0.z;
        }
        return b_12.center_1 + b_12.axis0_0 * vec3<f32>(sign_0) + b_12.axis1_0 * vec3<f32>(_S21) + b_12.axis2_0 * vec3<f32>(_S22);
    }
    var _S23 : u32 = i_1 - u32(8);
    var axis_1 : u32 = _S23 / u32(2);
    if((_S23 % u32(2)) == u32(0))
    {
        sign_0 = -1.0f;
    }
    else
    {
        sign_0 = 1.0f;
    }
    return b_12.center_1 + box_axis_0(b_12, axis_1) * vec3<f32>((sign_0 * comp3_0(b_12.half_2, axis_1)));
}

fn box_to_local_0( b_13 : Box_0,  r_1 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r_1, b_13.axis0_0), dot(r_1, b_13.axis1_0), dot(r_1, b_13.axis2_0));
}

fn hull_signed_distance_0( b_14 : Box_0,  local_2 : vec3<f32>,  face_0 : ptr<function, u32>) -> f32
{
    (*face_0) = u32(0);
    var best_0 : f32 = -1.00000001504746622e+30f;
    var f_0 : u32 = u32(0);
    loop
    {
        if(f_0 < (b_14.hull_f_0))
        {
        }
        else
        {
            break;
        }
        var plane_0 : vec4<f32> = loads_0[b_14.hull_at_0 + b_14.hull_v_0 + f_0];
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

fn penetration_0( b_15 : Box_0,  p_0 : vec3<f32>,  depth_0 : ptr<function, f32>,  normal_1 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_0) = 0.0f;
    (*normal_1) = vec3<f32>(0.0f);
    var r_2 : vec3<f32> = p_0 - b_15.center_1;
    var _S24 : vec3<f32> = b_15.half_2;
    if((dot(r_2, r_2)) > (dot(_S24, _S24) * 1.00001001358032227f))
    {
        return false;
    }
    if((b_15.hull_v_0) != u32(0))
    {
        var face_1 : u32;
        var d_1 : f32 = hull_signed_distance_0(b_15, box_to_local_0(b_15, r_2), &(face_1));
        if(!(d_1 < 0.0f))
        {
            return false;
        }
        (*depth_0) = - d_1;
        (*normal_1) = box_to_world_0(b_15, loads_0[b_15.hull_at_0 + b_15.hull_v_0 + face_1].xyz);
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
        var local_3 : f32 = dot(r_2, box_axis_0(b_15, k_2));
        var d_2 : f32 = comp3_0(b_15.half_2, k_2) - abs(local_3);
        if(d_2 <= 0.0f)
        {
            return false;
        }
        if(d_2 < best_1)
        {
            var _S25 : f32;
            if(local_3 >= 0.0f)
            {
                _S25 = 1.0f;
            }
            else
            {
                _S25 = -1.0f;
            }
            best_1 = d_2;
            axis_2 = k_2;
            side_0 = _S25;
        }
        k_2 = k_2 + u32(1);
    }
    (*depth_0) = best_1;
    (*normal_1) = box_axis_0(b_15, axis_2) * vec3<f32>(side_0);
    return true;
}

fn penetration_1( b_16 : Box_0,  p_1 : vec3<f32>,  depth_1 : ptr<function, f32>,  normal_2 : ptr<function, vec3<f32>>) -> bool
{
    (*depth_1) = 0.0f;
    (*normal_2) = vec3<f32>(0.0f);
    var r_3 : vec3<f32> = p_1 - b_16.center_1;
    var _S26 : vec3<f32> = b_16.half_2;
    if((dot(r_3, r_3)) > (dot(_S26, _S26) * 1.00001001358032227f))
    {
        return false;
    }
    if((b_16.hull_v_0) != u32(0))
    {
        var face_2 : u32;
        var d_3 : f32 = hull_signed_distance_0(b_16, box_to_local_0(b_16, r_3), &(face_2));
        if(!(d_3 < 0.0f))
        {
            return false;
        }
        (*depth_1) = - d_3;
        (*normal_2) = box_to_world_0(b_16, loads_0[b_16.hull_at_0 + b_16.hull_v_0 + face_2].xyz);
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
        var local_4 : f32 = dot(r_3, box_axis_0(b_16, k_3));
        var d_4 : f32 = comp3_0(b_16.half_2, k_3) - abs(local_4);
        if(d_4 <= 0.0f)
        {
            return false;
        }
        if(d_4 < best_2)
        {
            var _S27 : f32;
            if(local_4 >= 0.0f)
            {
                _S27 = 1.0f;
            }
            else
            {
                _S27 = -1.0f;
            }
            best_2 = d_4;
            axis_3 = k_3;
            side_1 = _S27;
        }
        k_3 = k_3 + u32(1);
    }
    (*depth_1) = best_2;
    (*normal_2) = box_axis_0(b_16, axis_3) * vec3<f32>(side_1);
    return true;
}

fn pair_point_0( ba_0 : Box_0,  bb_0 : Box_0,  na_0 : u32,  e_0 : u32,  p_2 : ptr<function, vec3<f32>>,  n_1 : ptr<function, vec3<f32>>,  d_5 : ptr<function, f32>) -> bool
{
    if(e_0 < na_0)
    {
        var _S28 : vec3<f32> = sample_point_0(ba_0, e_0);
        (*p_2) = _S28;
        var _S29 : bool = penetration_1(bb_0, _S28, &((*d_5)), &((*n_1)));
        return _S29;
    }
    var _S30 : vec3<f32> = sample_point_0(bb_0, e_0 - na_0);
    (*p_2) = _S30;
    var _S31 : bool = penetration_1(ba_0, _S30, &((*d_5)), &((*n_1)));
    if(!_S31)
    {
        return false;
    }
    (*n_1) = (vec3<f32>(0) - (*n_1));
    return true;
}

fn is_nan_0( x_4 : f32) -> bool
{
    return (((bitcast<u32>((x_4))) & (u32(2147483647)))) > u32(2139095040);
}

fn pair_count_sum_0( x_5 : u32,  lanes_1 : u32) -> u32
{
    return x_5;
}

fn half_thickness_and_area_0( b_17 : Box_0,  d_6 : vec3<f32>) -> vec2<f32>
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
        var c_4 : f32 = abs(dot(d_6, box_axis_0(b_17, k_4)));
        var h_2 : f32 = h_1 + c_4 * comp3_0(b_17.half_2, k_4);
        var _S32 : u32 = k_4 + u32(1);
        var area_1 : f32 = area_0 + c_4 * 4.0f * comp3_0(b_17.half_2, _S32 % u32(3)) * comp3_0(b_17.half_2, (k_4 + u32(2)) % u32(3));
        k_4 = _S32;
        h_1 = h_2;
        area_0 = area_1;
    }
    return vec2<f32>(h_1, area_0);
}

fn contact_stiffness_0( ea_0 : f32,  a_9 : Box_0,  eb_0 : f32,  b_18 : Box_0,  dir_0 : vec3<f32>) -> f32
{
    var d_7 : vec3<f32> = safe_normalize_0(dir_0);
    var ta_0 : vec2<f32> = half_thickness_and_area_0(a_9, d_7);
    var tb_0 : vec2<f32> = half_thickness_and_area_0(b_18, d_7);
    return min(ta_0.y, tb_0.y) / (ta_0.x / ea_0 + tb_0.x / eb_0);
}

fn penalty_force_0( k_5 : f32,  m_red_0 : f32,  friction_0 : f32,  depth_2 : f32,  normal_3 : vec3<f32>,  rel_velocity_0 : vec3<f32>,  dt_1 : f32,  points_0 : u32,  stored_0 : ptr<function, f32>,  dissipated_1 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_0 : f32 = 1.0f / max(f32(points_0), 10.0f) * m_red_0 / dt_1;
    var vn_0 : f32 = dot(rel_velocity_0, normal_3);
    var _S33 : f32 = k_5 * depth_2;
    var _S34 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_5 * m_red_0), c_max_0) * vn_0;
    var _S35 : f32 = _S33 - _S34;
    var _S36 : f32 = max(_S35, 0.0f);
    var vt_0 : vec3<f32> = rel_velocity_0 - normal_3 * vec3<f32>(vn_0);
    var vt_mag_0 : f32 = length(vt_0);
    var _S37 : f32 = friction_0 * _S36;
    var _S38 : f32 = min(_S37, min(c_max_0, _S37 / 0.00100000004749745f) * vt_mag_0);
    var ft_0 : vec3<f32>;
    if(vt_mag_0 > 0.0f)
    {
        ft_0 = (vec3<f32>(0) - vt_0) * vec3<f32>((_S38 / vt_mag_0));
    }
    else
    {
        ft_0 = vec3<f32>(0.0f);
    }
    (*stored_0) = 0.5f * k_5 * depth_2 * depth_2;
    var damping_power_0 : f32;
    if(_S35 > 0.0f)
    {
        damping_power_0 = _S34 * vn_0;
    }
    else
    {
        damping_power_0 = _S33 * max(vn_0, 0.0f);
    }
    (*dissipated_1) = (damping_power_0 + length(ft_0) * vt_mag_0) * dt_1;
    return normal_3 * vec3<f32>(_S36) + ft_0;
}

fn penalty_force_1( k_6 : f32,  m_red_1 : f32,  friction_1 : f32,  depth_3 : f32,  normal_4 : vec3<f32>,  rel_velocity_1 : vec3<f32>,  dt_2 : f32,  points_1 : u32,  stored_1 : ptr<function, f32>,  dissipated_2 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_1 : f32 = 1.0f / max(f32(points_1), 10.0f) * m_red_1 / dt_2;
    var vn_1 : f32 = dot(rel_velocity_1, normal_4);
    var _S39 : f32 = k_6 * depth_3;
    var _S40 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_6 * m_red_1), c_max_1) * vn_1;
    var _S41 : f32 = _S39 - _S40;
    var _S42 : f32 = max(_S41, 0.0f);
    var vt_1 : vec3<f32> = rel_velocity_1 - normal_4 * vec3<f32>(vn_1);
    var vt_mag_1 : f32 = length(vt_1);
    var _S43 : f32 = friction_1 * _S42;
    var _S44 : f32 = min(_S43, min(c_max_1, _S43 / 0.00100000004749745f) * vt_mag_1);
    var ft_1 : vec3<f32>;
    if(vt_mag_1 > 0.0f)
    {
        ft_1 = (vec3<f32>(0) - vt_1) * vec3<f32>((_S44 / vt_mag_1));
    }
    else
    {
        ft_1 = vec3<f32>(0.0f);
    }
    (*stored_1) = 0.5f * k_6 * depth_3 * depth_3;
    var damping_power_1 : f32;
    if(_S41 > 0.0f)
    {
        damping_power_1 = _S40 * vn_1;
    }
    else
    {
        damping_power_1 = _S39 * max(vn_1, 0.0f);
    }
    (*dissipated_2) = (damping_power_1 + length(ft_1) * vt_mag_1) * dt_2;
    return normal_4 * vec3<f32>(_S42) + ft_1;
}

fn penalty_force_2( k_7 : f32,  m_red_2 : f32,  friction_2 : f32,  depth_4 : f32,  normal_5 : vec3<f32>,  rel_velocity_2 : vec3<f32>,  dt_3 : f32,  points_2 : u32,  stored_2 : ptr<function, f32>,  dissipated_3 : ptr<function, f32>) -> vec3<f32>
{
    var c_max_2 : f32 = 1.0f / max(f32(points_2), 10.0f) * m_red_2 / dt_3;
    var vn_2 : f32 = dot(rel_velocity_2, normal_5);
    var _S45 : f32 = k_7 * depth_4;
    var _S46 : f32 = min(2.0f * params_0.zeta_0 * sqrt(k_7 * m_red_2), c_max_2) * vn_2;
    var _S47 : f32 = _S45 - _S46;
    var _S48 : f32 = max(_S47, 0.0f);
    var vt_2 : vec3<f32> = rel_velocity_2 - normal_5 * vec3<f32>(vn_2);
    var vt_mag_2 : f32 = length(vt_2);
    var _S49 : f32 = friction_2 * _S48;
    var _S50 : f32 = min(_S49, min(c_max_2, _S49 / 0.00100000004749745f) * vt_mag_2);
    var ft_2 : vec3<f32>;
    if(vt_mag_2 > 0.0f)
    {
        ft_2 = (vec3<f32>(0) - vt_2) * vec3<f32>((_S50 / vt_mag_2));
    }
    else
    {
        ft_2 = vec3<f32>(0.0f);
    }
    (*stored_2) = 0.5f * k_7 * depth_4 * depth_4;
    var damping_power_2 : f32;
    if(_S47 > 0.0f)
    {
        damping_power_2 = _S46 * vn_2;
    }
    else
    {
        damping_power_2 = _S45 * max(vn_2, 0.0f);
    }
    (*dissipated_3) = (damping_power_2 + length(ft_2) * vt_mag_2) * dt_3;
    return normal_5 * vec3<f32>(_S48) + ft_2;
}

fn pair_sum3_0( x_6 : vec3<f32>,  lanes_2 : u32) -> vec3<f32>
{
    return x_6;
}

fn pair_sum_0( x_7 : f32,  lanes_3 : u32) -> f32
{
    return x_7;
}

fn comp_add1_0( sum_0 : ptr<function, f32>,  err_0 : ptr<function, f32>,  x_8 : f32)
{
    var t_1 : f32 = (*sum_0) + x_8;
    if((abs((*sum_0))) >= (abs(x_8)))
    {
        (*err_0) = (*err_0) + ((*sum_0) - t_1 + x_8);
    }
    else
    {
        (*err_0) = (*err_0) + (x_8 - t_1 + (*sum_0));
    }
    (*sum_0) = t_1;
    return;
}

fn comp_add1_1( sum_1 : ptr<function, f32>,  err_1 : ptr<function, f32>,  x_9 : f32)
{
    var t_2 : f32 = (*sum_1) + x_9;
    if((abs((*sum_1))) >= (abs(x_9)))
    {
        (*err_1) = (*err_1) + ((*sum_1) - t_2 + x_9);
    }
    else
    {
        (*err_1) = (*err_1) + (x_9 - t_2 + (*sum_1));
    }
    (*sum_1) = t_2;
    return;
}

fn comp_add1_2( sum_2 : ptr<function, f32>,  err_2 : ptr<function, f32>,  x_10 : f32)
{
    var t_3 : f32 = (*sum_2) + x_10;
    if((abs((*sum_2))) >= (abs(x_10)))
    {
        (*err_2) = (*err_2) + ((*sum_2) - t_3 + x_10);
    }
    else
    {
        (*err_2) = (*err_2) + (x_10 - t_3 + (*sum_2));
    }
    (*sum_2) = t_3;
    return;
}

fn comp_add1_3( sum_3 : ptr<function, f32>,  err_3 : ptr<function, f32>,  x_11 : f32)
{
    var t_4 : f32 = (*sum_3) + x_11;
    if((abs((*sum_3))) >= (abs(x_11)))
    {
        (*err_3) = (*err_3) + ((*sum_3) - t_4 + x_11);
    }
    else
    {
        (*err_3) = (*err_3) + (x_11 - t_4 + (*sum_3));
    }
    (*sum_3) = t_4;
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
    var _S51 : u32 = index_0[at_0 + u32(3)];
    var _S52 : f32 = (bitcast<f32>((index_0[at_0 + u32(4)])));
    var _S53 : f32 = (bitcast<f32>((index_0[at_0 + u32(5)])));
    var _S54 : f32 = params_0.dt_0;
    var out_0 : u32 = params_0.slot_base_0 + u32(2) * index_0[at_0 + u32(2)];
    var cb_rel_0 : vec3<f32> = world_diff_0(chunk_world_0(cb_0), chunk_world_0(ca_0));
    var touching_0 : bool = !((length(cb_rel_0)) > (chunks_0[ca_0].half_0.w + chunks_0[cb_0].half_0.w));
    var ledger_1 : vec4<f32> = scratch_0[params_0.ledger_base_0 + i_2];
    var flags_0 : u32 = (bitcast<u32>((scratch_0[params_0.ledger_base_0 + i_2].w)));
    var _S55 : vec3<f32> = vec3<f32>(0.0f);
    var ba_1 : Box_0 = chunk_box_0(ca_0, _S55);
    var bb_1 : Box_0 = chunk_box_0(cb_0, cb_rel_0);
    var _S56 : u32 = sample_count_0(ba_1);
    var _S57 : u32 = _S56 + sample_count_0(bb_1);
    var e_1 : u32;
    var has_state_0 : bool;
    if(!touching_0)
    {
        if(((flags_0 & (u32(1)))) != u32(0))
        {
            e_1 = lane_0;
            loop
            {
                if(e_1 < _S57)
                {
                }
                else
                {
                    break;
                }
                contact_state_0[_S51 + e_1] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
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
            if(e_1 < _S57)
            {
            }
            else
            {
                break;
            }
            var p_3 : vec3<f32>;
            var n_2 : vec3<f32>;
            var d_8 : f32;
            var _S58 : bool = pair_point_0(ba_1, bb_1, _S56, e_1, &(p_3), &(n_2), &(d_8));
            if(!_S58)
            {
                var _S59 : u32 = _S51 + e_1;
                if(!is_nan_0(contact_state_0[_S59].x))
                {
                    contact_state_0[_S59] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
                }
                e_1 = e_1 + lanes_4;
                continue;
            }
            var _S60 : u32 = count_0 + u32(1);
            var _S61 : u32 = _S51 + e_1;
            var entry_0 : vec4<f32> = contact_state_0[_S61];
            if(is_nan_0(contact_state_0[_S61].x))
            {
                has_state_0 = true;
            }
            else
            {
                has_state_0 = (dot(entry_0.yzw, n_2)) < 0.99000000953674316f;
            }
            if(has_state_0)
            {
                if(d_8 > (2.0f * abs(dot(va0_0 + cross(wa0_0, p_3) - (vb0_0 + cross(wb0_0, p_3 - bb_1.center_1)), n_2)) * _S54 + 9.99999971718068537e-10f))
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
            contact_state_0[_S61] = entry_0;
            var engaged_1 : u32;
            if((d_8 - entry_0.x) > 0.0f)
            {
                engaged_1 = engaged_0 + u32(1);
            }
            else
            {
                engaged_1 = engaged_0;
            }
            count_0 = _S60;
            engaged_0 = engaged_1;
            e_1 = e_1 + lanes_4;
        }
        var engaged_2 : u32 = pair_count_sum_0(engaged_0, lanes_4);
        if((pair_count_sum_0(count_0, lanes_4)) > u32(0))
        {
            var _S62 : f32 = contact_stiffness_0(chunks_0[ca_0].cmat_0.x, ba_1, chunks_0[cb_0].cmat_0.x, bb_1, bb_1.center_1 - ba_1.center_1) / max(f32(engaged_2), 10.0f);
            e_1 = lane_0;
            fa_0 = _S55;
            ta_1 = _S55;
            fb_0 = _S55;
            tb_1 = _S55;
            stored_sum_0 = 0.0f;
            diss_sum_0 = 0.0f;
            loop
            {
                if(e_1 < _S57)
                {
                }
                else
                {
                    break;
                }
                var p_4 : vec3<f32>;
                var n_3 : vec3<f32>;
                var d_9 : f32;
                var _S63 : bool = pair_point_0(ba_1, bb_1, _S56, e_1, &(p_4), &(n_3), &(d_9));
                if(!_S63)
                {
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                var eff_0 : f32 = d_9 - contact_state_0[_S51 + e_1].x;
                if(eff_0 <= 0.0f)
                {
                    e_1 = e_1 + lanes_4;
                    continue;
                }
                var stored_3 : f32;
                var diss_0 : f32;
                var f_1 : vec3<f32> = penalty_force_1(_S62, _S52, _S53, eff_0, n_3, va0_0 + cross(wa0_0, p_4) - (vb0_0 + cross(wb0_0, p_4 - bb_1.center_1)), _S54, engaged_2, &(stored_3), &(diss_0));
                var ta_2 : vec3<f32> = ta_1 + cross(p_4, f_1);
                var _S64 : vec3<f32> = (vec3<f32>(0) - f_1);
                var fb_1 : vec3<f32> = fb_0 + _S64;
                var tb_2 : vec3<f32> = tb_1 + cross(p_4 - bb_1.center_1, _S64);
                var stored_sum_1 : f32 = stored_sum_0 + stored_3;
                var diss_sum_1 : f32 = diss_sum_0 + diss_0;
                fa_0 = fa_0 + f_1;
                ta_1 = ta_2;
                fb_0 = fb_1;
                tb_1 = tb_2;
                stored_sum_0 = stored_sum_1;
                diss_sum_0 = diss_sum_1;
                e_1 = e_1 + lanes_4;
            }
            var _S65 : vec3<f32> = pair_sum3_0(fa_0, lanes_4);
            var _S66 : vec3<f32> = pair_sum3_0(ta_1, lanes_4);
            var _S67 : vec3<f32> = pair_sum3_0(fb_0, lanes_4);
            var _S68 : vec3<f32> = pair_sum3_0(tb_1, lanes_4);
            var _S69 : f32 = pair_sum_0(stored_sum_0, lanes_4);
            var _S70 : f32 = pair_sum_0(diss_sum_0, lanes_4);
            has_state_0 = true;
            diss_sum_0 = _S70;
            fa_0 = _S65;
            ta_1 = _S66;
            fb_0 = _S67;
            tb_1 = _S68;
            stored_sum_0 = _S69;
        }
        else
        {
            has_state_0 = false;
            diss_sum_0 = 0.0f;
            fa_0 = _S55;
            ta_1 = _S55;
            fb_0 = _S55;
            tb_1 = _S55;
            stored_sum_0 = 0.0f;
        }
    }
    else
    {
        has_state_0 = false;
        diss_sum_0 = 0.0f;
        fa_0 = _S55;
        ta_1 = _S55;
        fb_0 = _S55;
        tb_1 = _S55;
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
            if(e_1 < _S57)
            {
            }
            else
            {
                break;
            }
            contact_state_0[_S51 + e_1] = vec4<f32>((bitcast<f32>((u32(2143289344)))), 0.0f, 0.0f, 0.0f);
            e_1 = e_1 + lanes_4;
        }
    }
    if(lane_0 != u32(0))
    {
        return;
    }
    if(has_state_0)
    {
        var _S71 : f32 = ledger_1[i32(1)];
        var _S72 : f32 = ledger_1[i32(2)];
        comp_add1_2(&(_S71), &(_S72), diss_sum_0);
        ledger_1[i32(1)] = _S71;
        ledger_1[i32(2)] = _S72;
    }
    var _S73 : vec3<f32> = vec3<f32>(0.0f);
    if((any((fa_0 != _S73))))
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((ta_1 != _S73)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((fb_0 != _S73)));
    }
    if(loaded_0)
    {
        loaded_0 = true;
    }
    else
    {
        loaded_0 = (any((tb_1 != _S73)));
    }
    var _S74 : bool;
    if(loaded_0)
    {
        _S74 = true;
    }
    else
    {
        _S74 = ((flags_0 & (u32(2)))) != u32(0);
    }
    if(_S74)
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
    var b_19 : Box_0;
    b_19.center_1 = center_3;
    b_19.axis0_0 = rotate_0(q_7, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_19.axis1_0 = rotate_0(q_7, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_19.axis2_0 = rotate_0(q_7, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_19.half_2 = half_3;
    b_19.hull_at_0 = u32(0);
    b_19.hull_v_0 = u32(0);
    b_19.hull_f_0 = u32(0);
    return b_19;
}

fn impactor_slots_0( imp_1 : ptr<function, Impactor_std430_0>,  b_20 : Box_0) -> u32
{
    var _S75 : u32;
    if(((*imp_1).shape_0.x) == 0.0f)
    {
        _S75 = u32(1);
    }
    else
    {
        _S75 = sample_count_0(b_20) + u32(14);
    }
    return _S75;
}

fn impactor_slots_1( imp_2 : ptr<function, Impactor_std430_0>,  b_21 : Box_0) -> u32
{
    var _S76 : u32;
    if(((*imp_2).shape_0.x) == 0.0f)
    {
        _S76 = u32(1);
    }
    else
    {
        _S76 = sample_count_0(b_21) + u32(14);
    }
    return _S76;
}

fn impactor_slots_2( imp_3 : ptr<function, Impactor_std430_0>,  b_22 : Box_0) -> u32
{
    var _S77 : u32;
    if(((*imp_3).shape_0.x) == 0.0f)
    {
        _S77 = u32(1);
    }
    else
    {
        _S77 = sample_count_0(b_22) + u32(14);
    }
    return _S77;
}

fn sphere_contact_0( b_23 : Box_0,  center_4 : vec3<f32>,  radius_0 : f32,  point_0 : ptr<function, vec3<f32>>,  normal_6 : ptr<function, vec3<f32>>,  depth_5 : ptr<function, f32>) -> bool
{
    var _S78 : vec3<f32> = vec3<f32>(0.0f);
    (*point_0) = _S78;
    (*normal_6) = _S78;
    (*depth_5) = 0.0f;
    var r_4 : vec3<f32> = center_4 - b_23.center_1;
    var local_5 : vec3<f32> = vec3<f32>(dot(r_4, b_23.axis0_0), dot(r_4, b_23.axis1_0), dot(r_4, b_23.axis2_0));
    if((b_23.hull_v_0) != u32(0))
    {
        var face_3 : u32;
        var d_10 : f32 = hull_signed_distance_0(b_23, local_5, &(face_3));
        if(d_10 >= radius_0)
        {
            return false;
        }
        var _S79 : vec3<f32> = box_to_world_0(b_23, loads_0[b_23.hull_at_0 + b_23.hull_v_0 + face_3].xyz);
        (*normal_6) = _S79;
        (*point_0) = center_4 - _S79 * vec3<f32>(max(d_10, 0.0f));
        (*depth_5) = radius_0 - d_10;
        return true;
    }
    var q_8 : vec3<f32> = clamp(local_5, (vec3<f32>(0) - b_23.half_2), b_23.half_2);
    var d_11 : vec3<f32> = local_5 - q_8;
    var dist_0 : f32 = length(d_11);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        var dn_0 : vec3<f32> = d_11 / vec3<f32>(dist_0);
        (*normal_6) = b_23.axis0_0 * vec3<f32>(dn_0.x) + b_23.axis1_0 * vec3<f32>(dn_0.y) + b_23.axis2_0 * vec3<f32>(dn_0.z);
        (*point_0) = b_23.center_1 + b_23.axis0_0 * vec3<f32>(q_8.x) + b_23.axis1_0 * vec3<f32>(q_8.y) + b_23.axis2_0 * vec3<f32>(q_8.z);
        (*depth_5) = radius_0 - dist_0;
        return true;
    }
    var inside_0 : f32;
    var n_4 : vec3<f32>;
    var _S80 : bool = penetration_0(b_23, center_4, &(inside_0), &(n_4));
    if(!_S80)
    {
        return false;
    }
    (*normal_6) = n_4;
    (*point_0) = center_4 - n_4 * vec3<f32>(min(radius_0, inside_0));
    (*depth_5) = radius_0 + inside_0;
    return true;
}

fn impactor_contact_0( imp_4 : ptr<function, Impactor_std430_0>,  crush_depth_0 : f32,  shrunk_0 : Box_0,  b_24 : Box_0,  j_0 : u32,  p_5 : ptr<function, vec3<f32>>,  n_5 : ptr<function, vec3<f32>>,  d_12 : ptr<function, f32>) -> bool
{
    var _S81 : vec3<f32> = vec3<f32>(0.0f);
    (*p_5) = _S81;
    (*n_5) = _S81;
    (*d_12) = 0.0f;
    var _S82 : vec4<f32> = (*imp_4).shape_0;
    if(((*imp_4).shape_0.x) == 0.0f)
    {
        var _S83 : bool = sphere_contact_0(b_24, _S81, _S82.y - crush_depth_0, &((*p_5)), &((*n_5)), &((*d_12)));
        if(!_S83)
        {
            return false;
        }
        (*n_5) = (vec3<f32>(0) - (*n_5));
        return true;
    }
    var cb_1 : u32 = sample_count_0(b_24);
    if(j_0 < cb_1)
    {
        var _S84 : vec3<f32> = sample_point_0(b_24, j_0);
        (*p_5) = _S84;
        var _S85 : bool = penetration_0(shrunk_0, _S84, &((*d_12)), &((*n_5)));
        return _S85;
    }
    var _S86 : vec3<f32> = sample_point_0(shrunk_0, j_0 - cb_1);
    (*p_5) = _S86;
    var _S87 : bool = penetration_0(b_24, _S86, &((*d_12)), &((*n_5)));
    if(!_S87)
    {
        return false;
    }
    (*n_5) = (vec3<f32>(0) - (*n_5));
    return true;
}

fn impactor_contact_1( imp_5 : ptr<function, Impactor_std430_0>,  crush_depth_1 : f32,  shrunk_1 : Box_0,  b_25 : Box_0,  j_1 : u32,  p_6 : ptr<function, vec3<f32>>,  n_6 : ptr<function, vec3<f32>>,  d_13 : ptr<function, f32>) -> bool
{
    var _S88 : vec3<f32> = vec3<f32>(0.0f);
    (*p_6) = _S88;
    (*n_6) = _S88;
    (*d_13) = 0.0f;
    var _S89 : vec4<f32> = (*imp_5).shape_0;
    if(((*imp_5).shape_0.x) == 0.0f)
    {
        var _S90 : bool = sphere_contact_0(b_25, _S88, _S89.y - crush_depth_1, &((*p_6)), &((*n_6)), &((*d_13)));
        if(!_S90)
        {
            return false;
        }
        (*n_6) = (vec3<f32>(0) - (*n_6));
        return true;
    }
    var cb_2 : u32 = sample_count_0(b_25);
    if(j_1 < cb_2)
    {
        var _S91 : vec3<f32> = sample_point_0(b_25, j_1);
        (*p_6) = _S91;
        var _S92 : bool = penetration_0(shrunk_1, _S91, &((*d_13)), &((*n_6)));
        return _S92;
    }
    var _S93 : vec3<f32> = sample_point_0(shrunk_1, j_1 - cb_2);
    (*p_6) = _S93;
    var _S94 : bool = penetration_0(b_25, _S93, &((*d_13)), &((*n_6)));
    if(!_S94)
    {
        return false;
    }
    (*n_6) = (vec3<f32>(0) - (*n_6));
    return true;
}

fn impactor_point_0( _S95 : u32) -> WorldPoint_0
{
    var wi_0 : WorldPoint_0;
    wi_0.hi_0 = impactors_0[_S95].position_1.xyz;
    wi_0.lo_0 = impactors_0[_S95].position_err_1.xyz;
    wi_0.rel_0 = vec3<f32>(0.0f);
    return wi_0;
}

fn impactor_box_1( _S96 : u32,  _S97 : vec3<f32>,  _S98 : vec3<f32>) -> Box_0
{
    var q_9 : Quat_0 = quat_of_0(impactors_0[_S96].rotation_1);
    var b_26 : Box_0;
    b_26.center_1 = _S97;
    b_26.axis0_0 = rotate_0(q_9, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_26.axis1_0 = rotate_0(q_9, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_26.axis2_0 = rotate_0(q_9, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_26.half_2 = _S98;
    b_26.hull_at_0 = u32(0);
    b_26.hull_v_0 = u32(0);
    b_26.hull_f_0 = u32(0);
    return b_26;
}

fn impactor_shrunk_0( _S99 : u32,  _S100 : f32,  _S101 : Box_0) -> Box_0
{
    var shrunk_2 : Box_0 = _S101;
    shrunk_2.half_2 = _S101.half_2 - min(vec3<f32>(_S100), _S101.half_2 * vec3<f32>(0.5f));
    return shrunk_2;
}

fn impactor_contact_2( _S102 : u32,  _S103 : f32,  _S104 : Box_0,  _S105 : Box_0,  _S106 : u32,  _S107 : ptr<function, vec3<f32>>,  _S108 : ptr<function, vec3<f32>>,  _S109 : ptr<function, f32>) -> bool
{
    var _S110 : Impactor_std430_0 = impactors_0[_S102];
    var _S111 : vec3<f32> = vec3<f32>(0.0f);
    (*_S107) = _S111;
    (*_S108) = _S111;
    (*_S109) = 0.0f;
    if((_S110.shape_0.x) == 0.0f)
    {
        var _S112 : bool = sphere_contact_0(_S105, _S111, _S110.shape_0.y - _S103, &((*_S107)), &((*_S108)), &((*_S109)));
        if(!_S112)
        {
            return false;
        }
        (*_S108) = (vec3<f32>(0) - (*_S108));
        return true;
    }
    var cb_3 : u32 = sample_count_0(_S105);
    if(_S106 < cb_3)
    {
        var _S113 : vec3<f32> = sample_point_0(_S105, _S106);
        (*_S107) = _S113;
        var _S114 : bool = penetration_0(_S104, _S113, &((*_S109)), &((*_S108)));
        return _S114;
    }
    var _S115 : vec3<f32> = sample_point_0(_S104, _S106 - cb_3);
    (*_S107) = _S115;
    var _S116 : bool = penetration_0(_S105, _S115, &((*_S109)), &((*_S108)));
    if(!_S116)
    {
        return false;
    }
    (*_S108) = (vec3<f32>(0) - (*_S108));
    return true;
}

fn impactor_candidate_forces_0( k_8 : u32,  lane_1 : u32,  lanes_5 : u32)
{
    var _S117 : u32;
    var _S118 : bool;
    var _S119 : u32 = u32(3) * k_8;
    var at_1 : u32 = params_0.cand_index_0 + _S119;
    var c_5 : u32 = index_0[at_1];
    var slot_0 : u32 = index_0[at_1 + u32(1)];
    var _S120 : u32 = index_0[at_1 + u32(2)];
    var _S121 : Impactor_std430_0 = impactors_0[_S120];
    var _S122 : f32 = params_0.dt_0;
    var _S123 : vec3<f32> = vec3<f32>(0.0f);
    var data_1 : vec4<f32> = scratch_0[params_0.cand_base_0 + _S119];
    var hit_0 : bool;
    var f_sum_0 : vec3<f32>;
    var t_sum_0 : vec3<f32>;
    var imp_f_0 : vec3<f32>;
    var imp_t_0 : vec3<f32>;
    if((_S121.cand_0.z) == u32(0))
    {
        var rel_1 : vec3<f32> = world_diff_0(chunk_world_0(c_5), impactor_point_0(_S120));
        var _S124 : vec4<f32> = _S121.half_1;
        if(!((length(rel_1)) > (_S121.half_1.w + chunks_0[c_5].half_0.w)))
        {
            var _S125 : Box_0 = impactor_box_1(_S120, _S123, _S124.xyz);
            var b_27 : Box_0 = chunk_box_0(c_5, rel_1);
            var _S126 : vec4<f32> = _S121.mat_0;
            var kc_0 : f32 = contact_stiffness_0(_S121.mat_0.x, _S125, chunks_0[c_5].cmat_0.x, b_27, b_27.center_1 - _S125.center_1);
            var _S127 : vec4<f32> = _S121.geom_0;
            var _S128 : f32 = _S121.geom_0.y;
            var _S129 : Box_0 = impactor_shrunk_0(_S120, _S128, _S125);
            var j_2 : u32 = lane_1;
            var n_7 : u32 = u32(0);
            loop
            {
                var _S130 : u32 = impactor_slots_0(&(_S121), b_27);
                _S117 = _S130;
                if(j_2 < _S130)
                {
                }
                else
                {
                    break;
                }
                var p_7 : vec3<f32>;
                var nrm_0 : vec3<f32>;
                var dep_0 : f32;
                if(impactor_contact_2(_S120, _S128, _S129, b_27, j_2, &(p_7), &(nrm_0), &(dep_0)))
                {
                    n_7 = n_7 + u32(1);
                }
                j_2 = j_2 + lanes_5;
            }
            var n_8 : u32 = pair_count_sum_0(n_7, lanes_5);
            var _S131 : bool = (_S121.shape_0.x) == 0.0f;
            var _S132 : f32;
            if(_S131)
            {
                _S132 = kc_0;
            }
            else
            {
                _S132 = kc_0 / max(f32(n_8), 10.0f);
            }
            if(_S131)
            {
                j_2 = u32(1);
            }
            else
            {
                j_2 = n_8;
            }
            var m_1 : f32 = chunks_0[c_5].center_0.w;
            var _S133 : f32 = _S126.z;
            var _S134 : f32 = m_1 * _S133 / (m_1 + _S133);
            var _S135 : f32;
            if((params_0.pair_friction_0) >= 0.0f)
            {
                _S135 = params_0.pair_friction_0;
            }
            else
            {
                _S135 = min(_S126.y, chunks_0[c_5].cmat_0.y);
            }
            var _S136 : vec3<f32> = _S121.velocity_1.xyz + _S121.velocity_err_1.xyz;
            var vc_0 : vec3<f32>;
            var wc_0 : vec3<f32>;
            chunk_velocity_0(c_5, &(vc_0), &(wc_0));
            hit_0 = false;
            var j_3 : u32 = lane_1;
            f_sum_0 = _S123;
            t_sum_0 = _S123;
            imp_f_0 = _S123;
            imp_t_0 = _S123;
            var diss_sum_2 : f32 = 0.0f;
            loop
            {
                var _S137 : bool = n_8 > u32(0);
                _S118 = _S137;
                var _S138 : bool;
                if(_S137)
                {
                    _S138 = j_3 < _S117;
                }
                else
                {
                    _S138 = false;
                }
                if(_S138)
                {
                }
                else
                {
                    break;
                }
                var p_8 : vec3<f32>;
                var nrm_1 : vec3<f32>;
                var dep_1 : f32;
                var _S139 : bool = impactor_contact_0(&(_S121), _S128, _S129, b_27, j_3, &(p_8), &(nrm_1), &(dep_1));
                if(!_S139)
                {
                    j_3 = j_3 + lanes_5;
                    continue;
                }
                var stored_4 : f32;
                var diss_1 : f32;
                var f_2 : vec3<f32> = penalty_force_1(_S132, _S134, _S135, dep_1 * _S127.x, nrm_1, vc_0 + cross(wc_0, p_8 - b_27.center_1) - (_S136 + cross(_S121.angular_velocity_1.xyz, p_8)), _S122, j_2, &(stored_4), &(diss_1));
                var f_sum_1 : vec3<f32> = f_sum_0 + f_2;
                var t_sum_1 : vec3<f32> = t_sum_0 + cross(p_8 - b_27.center_1, f_2);
                var imp_f_1 : vec3<f32> = imp_f_0 - f_2;
                var imp_t_1 : vec3<f32> = imp_t_0 - cross(p_8, f_2);
                var diss_sum_3 : f32 = diss_sum_2 + diss_1;
                hit_0 = true;
                f_sum_0 = f_sum_1;
                t_sum_0 = t_sum_1;
                imp_f_0 = imp_f_1;
                imp_t_0 = imp_t_1;
                diss_sum_2 = diss_sum_3;
                j_3 = j_3 + lanes_5;
            }
            var _S140 : vec3<f32> = pair_sum3_0(f_sum_0, lanes_5);
            var _S141 : vec3<f32> = pair_sum3_0(t_sum_0, lanes_5);
            var _S142 : vec3<f32> = pair_sum3_0(imp_f_0, lanes_5);
            var _S143 : vec3<f32> = pair_sum3_0(imp_t_0, lanes_5);
            var diss_sum_4 : f32 = pair_sum_0(diss_sum_2, lanes_5);
            var _S144 : bool = pair_any_0(hit_0, lanes_5);
            if(_S118)
            {
                var _S145 : f32 = data_1[i32(2)];
                var _S146 : f32 = data_1[i32(3)];
                comp_add1_2(&(_S145), &(_S146), diss_sum_4);
                data_1[i32(2)] = _S145;
                data_1[i32(3)] = _S146;
            }
            hit_0 = _S144;
            f_sum_0 = _S140;
            t_sum_0 = _S141;
            imp_f_0 = _S142;
            imp_t_0 = _S143;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S123;
            t_sum_0 = _S123;
            imp_f_0 = _S123;
            imp_t_0 = _S123;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S123;
        t_sum_0 = _S123;
        imp_f_0 = _S123;
        imp_t_0 = _S123;
    }
    if(lane_1 != u32(0))
    {
        return;
    }
    var _S147 : u32 = u32(2) * slot_0;
    scratch_0[params_0.slot_base_0 + _S147] = vec4<f32>(f_sum_0, 0.0f);
    scratch_0[params_0.slot_base_0 + _S147 + u32(1)] = vec4<f32>(t_sum_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S119] = data_1;
    scratch_0[params_0.cand_base_0 + _S119 + u32(1)] = vec4<f32>(imp_f_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S119 + u32(2)] = vec4<f32>(imp_t_0, 0.0f);
    if(hit_0)
    {
        sentinel_mark_0(u32(2));
    }
    return;
}

fn quat_mul_0( a_10 : Quat_0,  o_0 : Quat_0) -> Quat_0
{
    var r_5 : Quat_0;
    r_5.w_0 = a_10.w_0 * o_0.w_0 - a_10.x_3 * o_0.x_3 - a_10.y_2 * o_0.y_2 - a_10.z_0 * o_0.z_0;
    r_5.x_3 = a_10.w_0 * o_0.x_3 + a_10.x_3 * o_0.w_0 + a_10.y_2 * o_0.z_0 - a_10.z_0 * o_0.y_2;
    r_5.y_2 = a_10.w_0 * o_0.y_2 - a_10.x_3 * o_0.z_0 + a_10.y_2 * o_0.w_0 + a_10.z_0 * o_0.x_3;
    r_5.z_0 = a_10.w_0 * o_0.z_0 + a_10.x_3 * o_0.y_2 - a_10.y_2 * o_0.x_3 + a_10.z_0 * o_0.w_0;
    return r_5;
}

fn travel_check_0( c_6 : u32)
{
    var _S148 : vec4<u32> = chunks_0[c_6].cinfo_0;
    if((chunks_0[c_6].cinfo_0.z) == u32(0))
    {
        return;
    }
    var wp_0 : WorldPoint_0 = chunk_world_0(c_6);
    var _S149 : vec4<f32> = chunks_0[c_6].start_hi_0;
    var moved_0 : vec3<f32> = wp_0.hi_0 - chunks_0[c_6].start_hi_0.xyz + (wp_0.lo_0 - chunks_0[c_6].start_lo_0.xyz) + wp_0.rel_0;
    var _S150 : u32 = chunks_0[c_6].info_1.y;
    var _S151 : vec3<f32> = vec3<f32>((params_0.t_hi_0 - chunks_0[c_6].start_vel_0.w + (params_0.t_lo_0 - chunks_0[c_6].start_lo_0.w) + f32(islands_0[_S150].info_0.w - params_0.step_start_0) * params_0.dt_0));
    var _S152 : vec3<f32> = chunks_0[c_6].start_vel_0.xyz * _S151;
    var _S153 : u32 = _S148.w;
    var _S154 : vec3<f32>;
    if(((_S153 & (u32(2)))) != u32(0))
    {
        _S154 = vec3<f32>(0.5f) * params_0.gravity_0.xyz * _S151 * _S151;
    }
    else
    {
        _S154 = vec3<f32>(0.0f);
    }
    var travel_0 : f32 = length(moved_0 - (_S152 + _S154));
    var travel_1 : f32;
    if(((_S153 & (u32(1)))) != u32(0))
    {
        var th_1 : vec3<f32> = state_0[u32(4) * c_6 + u32(1)].xyz;
        var turn_0 : Quat_0 = quat_mul_0(quat_of_0(vec4<f32>((vec3<f32>(0) - chunks_0[c_6].start_rot_0.xyz), chunks_0[c_6].start_rot_0.w)), quat_mul_0(quat_of_0(islands_0[_S150].rotation_0), from_axis_angle_0(th_1, length(th_1))));
        travel_1 = travel_0 + 2.0f * atan2(length(vec3<f32>(turn_0.x_3, turn_0.y_2, turn_0.z_0)), abs(turn_0.w_0)) * chunks_0[c_6].half_0.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S149.w))
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
    var lanes_6 : u32 = pair_lane_count_0();
    var pair_threads_0 : u32 = params_0.pair_count_0 * lanes_6;
    if(i_3 < pair_threads_0)
    {
        if(!pair_any_0(stopped_0(), lanes_6))
        {
            var _S155 : u32 = i_3 / lanes_6;
            var _S156 : u32 = i_3 % lanes_6;
            pair_contact_0(_S155, _S156, lanes_6);
        }
        return;
    }
    var j_4 : u32 = i_3 - pair_threads_0;
    var cand_threads_0 : u32 = params_0.cand_count_0 * lanes_6;
    if(j_4 < cand_threads_0)
    {
        if(!pair_any_0(stopped_0(), lanes_6))
        {
            var _S157 : u32 = j_4 / lanes_6;
            var _S158 : u32 = j_4 % lanes_6;
            impactor_candidate_forces_0(_S157, _S158, lanes_6);
        }
        return;
    }
    var _S159 : u32 = j_4 - cand_threads_0;
    var _S160 : bool;
    if(_S159 < (params_0.chunk_count_0))
    {
        _S160 = !stopped_0();
    }
    else
    {
        _S160 = false;
    }
    if(_S160)
    {
        travel_check_0(_S159);
    }
    return;
}

fn impactor_contact_3( _S161 : u32,  _S162 : f32,  _S163 : Box_0,  _S164 : Box_0,  _S165 : u32,  _S166 : ptr<function, vec3<f32>>,  _S167 : ptr<function, vec3<f32>>,  _S168 : ptr<function, f32>) -> bool
{
    var _S169 : Impactor_std430_0 = impactors_0[_S161];
    var _S170 : vec3<f32> = vec3<f32>(0.0f);
    (*_S166) = _S170;
    (*_S167) = _S170;
    (*_S168) = 0.0f;
    if((_S169.shape_0.x) == 0.0f)
    {
        var _S171 : bool = sphere_contact_0(_S164, _S170, _S169.shape_0.y - _S162, &((*_S166)), &((*_S167)), &((*_S168)));
        if(!_S171)
        {
            return false;
        }
        (*_S167) = (vec3<f32>(0) - (*_S167));
        return true;
    }
    var cb_4 : u32 = sample_count_0(_S164);
    if(_S165 < cb_4)
    {
        var _S172 : vec3<f32> = sample_point_0(_S164, _S165);
        (*_S166) = _S172;
        var _S173 : bool = penetration_0(_S163, _S172, &((*_S168)), &((*_S167)));
        return _S173;
    }
    var _S174 : vec3<f32> = sample_point_0(_S163, _S165 - cb_4);
    (*_S166) = _S174;
    var _S175 : bool = penetration_0(_S164, _S174, &((*_S168)), &((*_S167)));
    if(!_S175)
    {
        return false;
    }
    (*_S167) = (vec3<f32>(0) - (*_S167));
    return true;
}

fn impactor_contact_count_0( _S176 : u32,  _S177 : f32,  _S178 : Box_0,  _S179 : Box_0) -> u32
{
    var _S180 : Impactor_std430_0 = impactors_0[_S176];
    var j_5 : u32 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        var _S181 : u32 = impactor_slots_1(&(_S180), _S179);
        if(j_5 < _S181)
        {
        }
        else
        {
            break;
        }
        var p_9 : vec3<f32>;
        var n_9 : vec3<f32>;
        var d_14 : f32;
        if(impactor_contact_3(_S176, _S177, _S178, _S179, j_5, &(p_9), &(n_9), &(d_14)))
        {
            count_1 = count_1 + u32(1);
        }
        j_5 = j_5 + u32(1);
    }
    return count_1;
}

@compute
@workgroup_size(64, 1, 1)
fn impactor_shares(@builtin(global_invocation_id) id_1 : vec3<u32>)
{
    var k_9 : u32 = id_1.x;
    var _S182 : bool;
    if(k_9 >= (params_0.cand_count_0))
    {
        _S182 = true;
    }
    else
    {
        _S182 = stopped_0();
    }
    if(_S182)
    {
        return;
    }
    var _S183 : u32 = u32(3) * k_9;
    var at_2 : u32 = params_0.cand_index_0 + _S183;
    var c_7 : u32 = index_0[at_2];
    var _S184 : u32 = index_0[at_2 + u32(2)];
    var _S185 : Impactor_std430_0 = impactors_0[_S184];
    if((_S185.cand_0.z) == u32(0))
    {
        _S182 = (_S185.crush_0.x) > 0.0f;
    }
    else
    {
        _S182 = false;
    }
    var total_0 : f32;
    var ksum_0 : f32;
    if(_S182)
    {
        var rel_2 : vec3<f32> = world_diff_0(chunk_world_0(c_7), impactor_point_0(_S184));
        var _S186 : vec4<f32> = _S185.half_1;
        if(!((length(rel_2)) > (_S185.half_1.w + chunks_0[c_7].half_0.w)))
        {
            var _S187 : Box_0 = impactor_box_1(_S184, vec3<f32>(0.0f), _S186.xyz);
            var b_28 : Box_0 = chunk_box_0(c_7, rel_2);
            var kc_1 : f32 = contact_stiffness_0(_S185.mat_0.x, _S187, chunks_0[c_7].cmat_0.x, b_28, b_28.center_1 - _S187.center_1);
            var _S188 : f32 = _S185.crush_0.w;
            var _S189 : Box_0 = impactor_shrunk_0(_S184, _S188, _S187);
            var _S190 : u32 = impactor_contact_count_0(_S184, _S188, _S189, b_28);
            var _S191 : f32;
            if((_S185.shape_0.x) == 0.0f)
            {
                _S191 = kc_1;
            }
            else
            {
                _S191 = kc_1 / max(f32(_S190), 10.0f);
            }
            var j_6 : u32 = u32(0);
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            loop
            {
                if(_S190 > u32(0))
                {
                    var _S192 : u32 = impactor_slots_2(&(_S185), b_28);
                    _S182 = j_6 < _S192;
                }
                else
                {
                    _S182 = false;
                }
                if(_S182)
                {
                }
                else
                {
                    break;
                }
                var p_10 : vec3<f32>;
                var nrm_2 : vec3<f32>;
                var dep_2 : f32;
                var _S193 : bool = impactor_contact_1(&(_S185), _S188, _S189, b_28, j_6, &(p_10), &(nrm_2), &(dep_2));
                if(!_S193)
                {
                    j_6 = j_6 + u32(1);
                    continue;
                }
                var ksum_1 : f32 = ksum_0 + _S191;
                total_0 = total_0 + _S191 * dep_2;
                ksum_0 = ksum_1;
                j_6 = j_6 + u32(1);
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
    scratch_0[params_0.cand_base_0 + _S183] = vec4<f32>(total_0, ksum_0, scratch_0[params_0.cand_base_0 + _S183].z, scratch_0[params_0.cand_base_0 + _S183].w);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_crush(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var ii_0 : u32 = group_0.x;
    var tid_6 : u32 = thread_0.x;
    var _S194 : bool;
    if(ii_0 >= (params_0.impactor_count_0))
    {
        _S194 = true;
    }
    else
    {
        _S194 = stopped_0();
    }
    if(_S194)
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
    var _S195 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S195;
    var unused_0 : vec4<f32> = _S195;
    var k_10 : u32 = imp_6.cand_0.x + tid_6;
    loop
    {
        if(k_10 < (imp_6.cand_0.y))
        {
        }
        else
        {
            break;
        }
        shares_0 = shares_0 + scratch_0[params_0.cand_base_0 + u32(3) * k_10];
        k_10 = k_10 + u32(256);
    }
    group_sum2_1(tid_6, &(shares_0), &(unused_0));
    if(tid_6 != u32(0))
    {
        _S194 = true;
    }
    else
    {
        _S194 = (imp_6.cand_0.z) != u32(0);
    }
    if(_S194)
    {
        return;
    }
    imp_6.geom_0 = vec4<f32>(1.0f, imp_6.crush_0.w, 0.0f, 0.0f);
    var total_1 : f32 = shares_0.x;
    if((imp_6.crush_0.x) > 0.0f)
    {
        _S194 = (imp_6.crush_0.z) < (imp_6.crush_0.y);
    }
    else
    {
        _S194 = false;
    }
    if(_S194)
    {
        _S194 = total_1 > (imp_6.crush_0.x);
    }
    else
    {
        _S194 = false;
    }
    if(_S194)
    {
        var extra_0 : f32 = (total_1 - imp_6.crush_0.x) / shares_0.y;
        imp_6.crush_0[i32(3)] = imp_6.crush_0[i32(3)] + extra_0;
        imp_6.crush_0[i32(2)] = imp_6.crush_0[i32(2)] + imp_6.crush_0.x * extra_0;
        var _S196 : f32 = imp_6.crush_0.x * extra_0;
        var _S197 : f32 = imp_6.ledger_0[i32(2)];
        var _S198 : f32 = imp_6.ledger_0[i32(3)];
        comp_add1_3(&(_S197), &(_S198), _S196);
        imp_6.ledger_0[i32(2)] = _S197;
        imp_6.ledger_0[i32(3)] = _S198;
        var _S199 : f32 = imp_6.crush_0.x * extra_0;
        var _S200 : f32 = imp_6.ledger_0[i32(0)];
        var _S201 : f32 = imp_6.ledger_0[i32(1)];
        comp_add1_3(&(_S200), &(_S201), _S199);
        imp_6.ledger_0[i32(0)] = _S200;
        imp_6.ledger_0[i32(1)] = _S201;
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

struct WideGroup_0
{
     island_2 : u32,
     begin_0 : u32,
     end_0 : u32,
     first_0 : u32,
};

fn wide_group_0( table_0 : u32,  g_0 : u32) -> WideGroup_0
{
    var w_4 : WideGroup_0;
    var _S202 : u32 = table_0 + u32(4) * g_0;
    w_4.island_2 = index_0[_S202];
    w_4.begin_0 = index_0[_S202 + u32(1)];
    w_4.end_0 = index_0[_S202 + u32(2)];
    w_4.first_0 = index_0[_S202 + u32(3)];
    return w_4;
}

var<workgroup> g_seen_0 : array<u32, i32(5)>;

fn seen_clear_0( tid_7 : u32)
{
    if(tid_7 < u32(5))
    {
        g_seen_0[tid_7] = u32(0);
    }
    return;
}

fn contact_stopped_0( isl_0 : ptr<function, Island_std430_0>) -> bool
{
    var _S203 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S204 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S204 = true;
    }
    else
    {
        var _S205 : u32 = _S203.y;
        if(_S205 != u32(0))
        {
            _S204 = _S205 <= ((*isl_0).info_0.w);
        }
        else
        {
            _S204 = false;
        }
    }
    return _S204;
}

fn contact_stopped_1( isl_1 : ptr<function, Island_std430_0>) -> bool
{
    var _S206 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S207 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S207 = true;
    }
    else
    {
        var _S208 : u32 = _S206.y;
        if(_S208 != u32(0))
        {
            _S207 = _S208 <= ((*isl_1).info_0.w);
        }
        else
        {
            _S207 = false;
        }
    }
    return _S207;
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

fn contact_stopped_2( isl_2 : Island_0) -> bool
{
    var _S209 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S210 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S210 = true;
    }
    else
    {
        var _S211 : u32 = _S209.y;
        if(_S211 != u32(0))
        {
            _S210 = _S211 <= (isl_2.info_0.w);
        }
        else
        {
            _S210 = false;
        }
    }
    return _S210;
}

fn wide_runs_0( isl_3 : ptr<function, Island_std430_0>) -> bool
{
    var _S212 : vec4<u32> = (*isl_3).info_0;
    var _S213 : bool;
    if(((((*isl_3).info_0.z) & (u32(1)))) != u32(0))
    {
        _S213 = true;
    }
    else
    {
        _S213 = (_S212.y) == u32(0);
    }
    if(_S213)
    {
        return false;
    }
    if((((_S212.x) & (u32(4)))) == u32(0))
    {
        _S213 = true;
    }
    else
    {
        var _S214 : bool = contact_stopped_0(&((*isl_3)));
        _S213 = !_S214;
    }
    return _S213;
}

fn wide_runs_1( isl_4 : ptr<function, Island_std430_0>) -> bool
{
    var _S215 : vec4<u32> = (*isl_4).info_0;
    var _S216 : bool;
    if(((((*isl_4).info_0.z) & (u32(1)))) != u32(0))
    {
        _S216 = true;
    }
    else
    {
        _S216 = (_S215.y) == u32(0);
    }
    if(_S216)
    {
        return false;
    }
    if((((_S215.x) & (u32(4)))) == u32(0))
    {
        _S216 = true;
    }
    else
    {
        var _S217 : bool = contact_stopped_1(&((*isl_4)));
        _S216 = !_S217;
    }
    return _S216;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_8 : u32,  isl_5 : ptr<function, Island_std430_0>) -> bool
{
    seen_clear_0(tid_8);
    if(tid_8 == u32(0))
    {
        var _S218 : bool = wide_runs_1(&((*isl_5)));
        var _S219 : i32;
        if(_S218)
        {
            _S219 = i32(1);
        }
        else
        {
            _S219 = i32(0);
        }
        g_wide_run_0 = u32(_S219);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

fn wide_step_0( isl_6 : ptr<function, Island_std430_0>) -> u32
{
    return (*isl_6).info_0.w - params_0.step_start_0;
}

fn wide_step_1( isl_7 : ptr<function, Island_std430_0>) -> u32
{
    return (*isl_7).info_0.w - params_0.step_start_0;
}

fn wide_step_2( isl_8 : Island_0) -> u32
{
    return isl_8.info_0.w - params_0.step_start_0;
}

fn time_since_0( origin_0 : vec4<f32>,  k_11 : u32,  dt_4 : f32) -> f32
{
    return params_0.t_hi_0 - origin_0.x + (params_0.t_lo_0 - origin_0.y) + f32(k_11) * dt_4;
}

fn table_eval_0( offset_0 : u32,  count_2 : u32,  tau_0 : f32) -> f32
{
    var first_1 : vec4<f32> = loads_0[offset_0];
    if(tau_0 <= (first_1.x))
    {
        return first_1.y;
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
        var _S220 : u32 = offset_0 + i_4;
        var b_29 : vec4<f32> = loads_0[_S220];
        var _S221 : f32 = b_29.x;
        if(tau_0 <= _S221)
        {
            var a_11 : vec4<f32> = loads_0[_S220 - u32(1)];
            var _S222 : f32 = a_11.x;
            var _S223 : f32 = a_11.y;
            return _S223 + (tau_0 - _S222) / max(_S221 - _S222, 1.00000000317107685e-30f) * (b_29.y - _S223);
        }
        i_4 = i_4 + u32(1);
    }
    return loads_0[offset_0 + count_2 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_12 : u32,  dt_5 : f32,  shift_0 : f32) -> f32
{
    var _S224 : u32 = u32(5) * term_0;
    var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S224])));
    var origin_1 : vec4<f32> = loads_0[_S224 + u32(3)];
    var p_11 : vec4<f32> = loads_0[_S224 + u32(4)];
    var kind_0 : u32 = info_2.z;
    if(kind_0 == u32(0))
    {
        return origin_1.z;
    }
    var tau_1 : f32 = time_since_0(origin_1, k_12, dt_5) + shift_0;
    var shape_1 : f32;
    if(kind_0 == u32(1))
    {
        if(tau_1 <= 0.0f)
        {
            shape_1 = 0.0f;
        }
        else
        {
            var _S225 : f32 = p_11.x;
            if(tau_1 >= _S225)
            {
                shape_1 = p_11.y;
            }
            else
            {
                shape_1 = p_11.y * tau_1 / _S225;
            }
        }
        return shape_1;
    }
    var _S226 : bool;
    if(kind_0 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S226 = true;
        }
        else
        {
            _S226 = tau_1 > (p_11.x);
        }
        if(_S226)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_11.y * sin(3.14159274101257324f * tau_1 / p_11.x);
        }
        return shape_1;
    }
    if(kind_0 == u32(3))
    {
        var sn_0 : f32 = tau_1 / p_11.y;
        if(sn_0 < 0.0f)
        {
            _S226 = true;
        }
        else
        {
            _S226 = sn_0 > 1.0f;
        }
        if(_S226)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_11.x * (1.0f - sn_0) * exp(- p_11.z * sn_0);
        }
        return shape_1;
    }
    if(kind_0 == u32(4))
    {
        return table_eval_0(info_2.w, (bitcast<u32>((p_11.x))), tau_1);
    }
    if(kind_0 == u32(5))
    {
        g_seen_0[u32(1)] = u32(1);
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var sn_1 : f32 = tau_1 / p_11.x;
        if(sn_1 < 0.0f)
        {
            _S226 = true;
        }
        else
        {
            _S226 = sn_1 > 1.0f;
        }
        if(_S226)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = (1.0f - sn_1) * exp(- p_11.y * sn_1);
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
        var _S227 : f32 = p_11.w;
        return (_S227 + (p_11.z - _S227) * relax_0) * shape_1;
    }
    if(kind_0 == u32(7))
    {
        g_seen_0[u32(2)] = u32(1);
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var _S228 : f32 = p_11.y;
        if(tau_1 < _S228)
        {
            return p_11.x;
        }
        var s_5 : f32 = tau_1 - _S228;
        var _S229 : f32 = p_11.w;
        if(s_5 > _S229)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_11.z * sin(3.14159274101257324f * s_5 / _S229);
        }
        return shape_1;
    }
    var _S230 : f32 = p_11.x;
    if(_S230 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S230, 0.0f, 1.0f);
}

fn record_chunk_load_0( c_8 : u32,  f_3 : vec3<f32>,  t_5 : vec3<f32>)
{
    if((params_0.solve_mode_0) == u32(0))
    {
        return;
    }
    var _S231 : u32 = u32(2) * c_8;
    scratch_0[params_0.cload_base_0 + _S231] = vec4<f32>(f_3, 0.0f);
    scratch_0[params_0.cload_base_0 + _S231 + u32(1)] = vec4<f32>(t_5, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S231] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S231].xyz + f_3, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S231 + u32(1)] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S231 + u32(1)].xyz + t_5, 0.0f);
    return;
}

fn chunk_loads_0( _S232 : u32,  _S233 : u32,  _S234 : Quat_0,  _S235 : u32,  _S236 : f32,  _S237 : bool,  _S238 : f32,  _S239 : ptr<function, vec3<f32>>,  _S240 : ptr<function, vec3<f32>>,  _S241 : ptr<function, vec3<f32>>,  _S242 : ptr<function, vec3<f32>>)
{
    var _S243 : bool;
    var _S244 : vec3<f32> = vec3<f32>(0.0f);
    (*_S239) = _S244;
    (*_S240) = _S244;
    (*_S241) = _S244;
    (*_S242) = _S244;
    var _S245 : vec4<u32> = chunks_0[_S233].load_range_0;
    var term_1 : u32 = chunks_0[_S233].load_range_0.x;
    loop
    {
        if(term_1 < (_S245.y))
        {
        }
        else
        {
            break;
        }
        g_seen_0[u32(0)] = u32(1);
        var _S246 : u32 = u32(5) * term_1;
        var _S247 : u32 = (bitcast<vec4<u32>>((loads_0[_S246]))).y;
        var replacement_0 : bool = _S247 == u32(2);
        var dir_1 : vec4<f32> = loads_0[_S246 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S246 + u32(2)];
        var _S248 : f32;
        if(replacement_0)
        {
            _S248 = _S238;
        }
        else
        {
            _S248 = 0.0f;
        }
        var value_0 : f32 = eval_function_0(term_1, _S235, _S236, _S248);
        if(replacement_0)
        {
            var _S249 : vec3<f32> = vec3<f32>(value_0);
            (*_S241) = (*_S241) + dir_1.xyz * _S249;
            (*_S242) = (*_S242) + arm_0.xyz * _S249;
            term_1 = term_1 + u32(1);
            continue;
        }
        if(_S247 == u32(0))
        {
            _S243 = true;
        }
        else
        {
            _S243 = _S247 == u32(3);
        }
        var fw_0 : vec3<f32>;
        if(_S243)
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_0);
        }
        else
        {
            fw_0 = rotate_0(_S234, dir_1.xyz) * vec3<f32>((- value_0 * dir_1.w));
        }
        var lever_0 : vec3<f32>;
        if(_S247 == u32(3))
        {
            lever_0 = arm_0.xyz - state_0[u32(4) * _S232].xyz;
        }
        else
        {
            lever_0 = arm_0.xyz;
        }
        (*_S239) = (*_S239) + fw_0;
        (*_S240) = (*_S240) + cross(rotate_0(_S234, lever_0), fw_0);
        term_1 = term_1 + u32(1);
    }
    if(_S237)
    {
        _S243 = (chunks_0[_S233].cinfo_0.z) != u32(0);
    }
    else
    {
        _S243 = false;
    }
    if(_S243)
    {
        var _S250 : vec4<u32> = chunks_0[_S233].cinfo_0;
        var g_1 : u32 = chunks_0[_S233].cinfo_0.x;
        loop
        {
            if(g_1 < (_S250.y))
            {
            }
            else
            {
                break;
            }
            var _S251 : u32 = u32(2) * g_1;
            (*_S239) = (*_S239) + scratch_0[params_0.seg_base_0 + _S251].xyz;
            (*_S240) = (*_S240) + scratch_0[params_0.seg_base_0 + _S251 + u32(1)].xyz;
            g_1 = g_1 + u32(1);
        }
    }
    return;
}

fn chunk_external_0( _S252 : u32,  _S253 : u32,  _S254 : Quat_0,  _S255 : u32,  _S256 : f32,  _S257 : bool,  _S258 : ptr<function, vec3<f32>>,  _S259 : ptr<function, vec3<f32>>)
{
    var rf_0 : vec3<f32>;
    var rm_0 : vec3<f32>;
    chunk_loads_0(_S252, _S253, _S254, _S255, _S256, _S257, 0.0f, &((*_S258)), &((*_S259)), &(rf_0), &(rm_0));
    return;
}

fn settled_chunk_load_0( c_9 : u32,  rot_0 : Quat_0,  k_13 : u32,  dt_6 : f32,  contact_0 : bool) -> f32
{
    var f_4 : vec3<f32>;
    var t_6 : vec3<f32>;
    chunk_external_0(c_9, c_9, rot_0, k_13, dt_6, contact_0, &(f_4), &(t_6));
    record_chunk_load_0(c_9, f_4, t_6);
    return length(f_4);
}

fn seen_bits_0() -> u32
{
    var _S260 : u32;
    if((g_seen_0[u32(0)]) != u32(0))
    {
        _S260 = u32(32768);
    }
    else
    {
        _S260 = u32(0);
    }
    var _S261 : u32;
    if((g_seen_0[u32(1)]) != u32(0))
    {
        _S261 = u32(65536);
    }
    else
    {
        _S261 = u32(0);
    }
    var _S262 : u32 = (_S260 | (_S261));
    if((g_seen_0[u32(2)]) != u32(0))
    {
        _S260 = u32(131072);
    }
    else
    {
        _S260 = u32(0);
    }
    var _S263 : u32 = (_S262 | (_S260));
    if((g_seen_0[u32(3)]) != u32(0))
    {
        _S260 = u32(32);
    }
    else
    {
        _S260 = u32(0);
    }
    var _S264 : u32 = (_S263 | (_S260));
    if((g_seen_0[u32(4)]) != u32(0))
    {
        _S260 = u32(64);
    }
    else
    {
        _S260 = u32(0);
    }
    return (_S264 | (_S260));
}

fn wide_enter_1( _S265 : u32,  _S266 : u32) -> bool
{
    var _S267 : Island_std430_0 = islands_0[_S266];
    seen_clear_0(_S265);
    if(_S265 == u32(0))
    {
        var _S268 : bool = wide_runs_0(&(_S267));
        var _S269 : i32;
        if(_S268)
        {
            _S269 = i32(1);
        }
        else
        {
            _S269 = i32(0);
        }
        g_wide_run_0 = u32(_S269);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_wake(@builtin(workgroup_id) group_1 : vec3<u32>, @builtin(local_invocation_id) thread_1 : vec3<u32>)
{
    var tid_9 : u32 = thread_1.x;
    var _S270 : u32 = group_1.x;
    var wg_0 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S270);
    if(_S270 != (wg_0.first_0))
    {
        return;
    }
    var _S271 : Island_std430_0 = islands_0[wg_0.island_2];
    var _S272 : vec4<u32> = _S271.info_0;
    var _S273 : u32 = _S271.info_0.x;
    var _S274 : bool;
    if(((_S273 & (u32(16)))) == u32(0))
    {
        _S274 = true;
    }
    else
    {
        var _S275 : bool = wide_enter_1(tid_9, wg_0.island_2);
        _S274 = !_S275;
    }
    if(_S274)
    {
        return;
    }
    var _S276 : Quat_0 = quat_of_0(_S271.rotation_0);
    var _S277 : bool = ((_S273 & (u32(4)))) != u32(0);
    var _S278 : vec3<f32> = vec3<f32>(0.0f);
    var norm_0 : vec3<f32> = _S278;
    var unused_1 : vec3<f32> = _S278;
    var _S279 : vec4<u32> = _S271.range_0;
    var c_10 : u32 = _S271.range_0.x + tid_9;
    loop
    {
        if(c_10 < (_S279.y))
        {
        }
        else
        {
            break;
        }
        var _S280 : u32 = wide_step_1(&(_S271));
        var _S281 : f32 = settled_chunk_load_0(c_10, _S276, _S280, params_0.dt_0, _S277);
        norm_0[i32(0)] = norm_0[i32(0)] + _S281;
        c_10 = c_10 + u32(256);
    }
    group_sum3_1(tid_9, &(norm_0), &(unused_1));
    if(tid_9 != u32(0))
    {
        return;
    }
    var cov_0 : u32 = (u32(1024) | ((seen_bits_0())));
    if((params_0.solve_mode_0) == u32(1))
    {
        _S274 = (abs(norm_0.x - _S271.energy_0.z)) > (_S271.energy_0.w);
    }
    else
    {
        _S274 = false;
    }
    var cov_1 : u32;
    if(_S274)
    {
        islands_0[wg_0.island_2].info_0[i32(0)] = (_S273 & (u32(4294967279)));
        islands_0[wg_0.island_2].info_0[i32(2)] = ((_S272.z) | (u32(4)));
        cov_1 = (cov_0 | (u32(2048)));
    }
    else
    {
        cov_1 = cov_0;
    }
    cov_mark_0(wg_0.island_2, _S271.coverage_0, cov_1);
    return;
}

fn is_damaged_0( st_0 : ptr<function, JointState_std430_0>) -> bool
{
    var _S282 : bool;
    if(((*st_0).damage_0) > 0.0f)
    {
        _S282 = true;
    }
    else
    {
        _S282 = ((*st_0).crush_1) > 0.0f;
    }
    return _S282;
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
    var _S283 : bool;
    if((st_1.damage_0) > 0.0f)
    {
        _S283 = true;
    }
    else
    {
        _S283 = (st_1.crush_1) > 0.0f;
    }
    return _S283;
}

fn connected_0( st_2 : ptr<function, JointState_std430_0>,  has_rebar_0 : bool) -> bool
{
    var _S284 : bool;
    if(((*st_2).damage_0) < 1.0f)
    {
        _S284 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S284 = ((*st_2).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S284 = false;
        }
    }
    return _S284;
}

fn connected_1( st_3 : ptr<function, JointState_std430_0>,  has_rebar_1 : bool) -> bool
{
    var _S285 : bool;
    if(((*st_3).damage_0) < 1.0f)
    {
        _S285 = true;
    }
    else
    {
        if(has_rebar_1)
        {
            _S285 = ((*st_3).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S285 = false;
        }
    }
    return _S285;
}

fn connected_2( st_4 : ptr<function, JointState_std430_0>,  has_rebar_2 : bool) -> bool
{
    var _S286 : bool;
    if(((*st_4).damage_0) < 1.0f)
    {
        _S286 = true;
    }
    else
    {
        if(has_rebar_2)
        {
            _S286 = ((*st_4).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S286 = false;
        }
    }
    return _S286;
}

fn connected_3( st_5 : JointState_0,  has_rebar_3 : bool) -> bool
{
    var _S287 : bool;
    if((st_5.damage_0) < 1.0f)
    {
        _S287 = true;
    }
    else
    {
        if(has_rebar_3)
        {
            _S287 = (st_5.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S287 = false;
        }
    }
    return _S287;
}

fn fdiv_0( a_12 : f32,  b_30 : f32) -> f32
{
    return a_12 / b_30;
}

fn fsqrt_0( a_13 : f32) -> f32
{
    return sqrt(a_13);
}

struct Measures_0
{
     tension_0 : f32,
     shear_0 : f32,
     normal_compression_0 : f32,
     compression_0 : f32,
     compressive_force_0 : f32,
};

fn stress_measures_0( b_31 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_2 : f32 = (*b_31).geom0_0.x;
    var _S288 : f32 = q_lin_0.z;
    var axial_0 : f32 = fdiv_0(_S288, area_2);
    var bending_0 : f32 = fdiv_0(abs(q_ang_0.x), (*b_31).geom1_0.x) + fdiv_0(abs(q_ang_0.y), (*b_31).geom1_0.y);
    var _S289 : f32 = q_lin_0.x;
    var _S290 : f32 = q_lin_0.y;
    var shear_1 : f32 = fdiv_0(fsqrt_0(_S289 * _S289 + _S290 * _S290), area_2) + fdiv_0(abs(q_ang_0.z), (*b_31).geom0_0.w);
    var m_2 : Measures_0;
    m_2.tension_0 = axial_0 + bending_0;
    m_2.shear_0 = shear_1;
    var _S291 : f32 = - axial_0;
    m_2.normal_compression_0 = max(_S291, 0.0f);
    m_2.compression_0 = _S291 + bending_0;
    m_2.compressive_force_0 = max(- _S288, 0.0f);
    return m_2;
}

fn stress_measures_1( b_32 : ptr<function, JointBond_std430_0>,  q_lin_1 : vec3<f32>,  q_ang_1 : vec3<f32>) -> Measures_0
{
    var area_3 : f32 = (*b_32).geom0_0.x;
    var _S292 : f32 = q_lin_1.z;
    var axial_1 : f32 = fdiv_0(_S292, area_3);
    var bending_1 : f32 = fdiv_0(abs(q_ang_1.x), (*b_32).geom1_0.x) + fdiv_0(abs(q_ang_1.y), (*b_32).geom1_0.y);
    var _S293 : f32 = q_lin_1.x;
    var _S294 : f32 = q_lin_1.y;
    var shear_2 : f32 = fdiv_0(fsqrt_0(_S293 * _S293 + _S294 * _S294), area_3) + fdiv_0(abs(q_ang_1.z), (*b_32).geom0_0.w);
    var m_3 : Measures_0;
    m_3.tension_0 = axial_1 + bending_1;
    m_3.shear_0 = shear_2;
    var _S295 : f32 = - axial_1;
    m_3.normal_compression_0 = max(_S295, 0.0f);
    m_3.compression_0 = _S295 + bending_1;
    m_3.compressive_force_0 = max(- _S292, 0.0f);
    return m_3;
}

fn expm1_accurate_0( x_12 : f32) -> f32
{
    if((abs(x_12)) < 0.00100000004749745f)
    {
        return x_12 * (1.0f + x_12 * (0.5f + x_12 * 0.1666666716337204f));
    }
    return exp(x_12) - 1.0f;
}

fn fpow_0( a_14 : f32,  b_33 : f32) -> f32
{
    return pow(a_14, b_33);
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_6 : f32 = abs(strain_rate_1);
    var _S296 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_6 <= ref_0)
    {
        return 1.0f;
    }
    var _S297 : f32 = _S296.z;
    var f_5 : f32;
    if(r_6 <= _S297)
    {
        f_5 = fpow_0(fdiv_0(r_6, ref_0), _S296.y);
    }
    else
    {
        f_5 = fpow_0(fdiv_0(_S297, ref_0), _S296.y) * fpow_0(fdiv_0(r_6, _S297), _S296.w);
    }
    return clamp(f_5, 1.0f, (*mat_1).misc_0.x);
}

fn dif_factor_1( mat_2 : ptr<function, JointMaterial_std140_0>,  strain_rate_2 : f32) -> f32
{
    var r_7 : f32 = abs(strain_rate_2);
    var _S298 : vec4<f32> = (*mat_2).dif_0;
    var ref_1 : f32 = (*mat_2).dif_0.x;
    if(r_7 <= ref_1)
    {
        return 1.0f;
    }
    var _S299 : f32 = _S298.z;
    var f_6 : f32;
    if(r_7 <= _S299)
    {
        f_6 = fpow_0(fdiv_0(r_7, ref_1), _S298.y);
    }
    else
    {
        f_6 = fpow_0(fdiv_0(_S299, ref_1), _S298.y) * fpow_0(fdiv_0(r_7, _S299), _S298.w);
    }
    return clamp(f_6, 1.0f, (*mat_2).misc_0.x);
}

fn fatigue_factor_0( mat_3 : ptr<function, JointMaterial_std140_0>,  life_1 : f32) -> f32
{
    if(((((*mat_3).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return fpow_0(clamp(life_1, 0.0f, 1.0f), fdiv_0(1.0f, (*mat_3).misc_0.y - 2.0f));
}

fn fatigue_factor_1( mat_4 : ptr<function, JointMaterial_std140_0>,  life_2 : f32) -> f32
{
    if(((((*mat_4).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return fpow_0(clamp(life_2, 0.0f, 1.0f), fdiv_0(1.0f, (*mat_4).misc_0.y - 2.0f));
}

fn fatigue_factor_2( mat_5 : ptr<function, JointMaterial_std140_0>,  life_3 : f32) -> f32
{
    if(((((*mat_5).kind_flags_0.y) & (u32(64)))) == u32(0))
    {
        return 1.0f;
    }
    return fpow_0(clamp(life_3, 0.0f, 1.0f), fdiv_0(1.0f, (*mat_5).misc_0.y - 2.0f));
}

fn infinity_0() -> f32
{
    return (bitcast<f32>((u32(2139095040))));
}

fn failure_indices_0( mat_6 : ptr<function, JointMaterial_std140_0>,  b_34 : ptr<function, JointBond_std430_0>,  m_4 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_0 : f32 = (*mat_6).strength_0.y * multiplier_0;
    var _S300 : f32 = min((*mat_6).strength_0.z * multiplier_0 + (*mat_6).strength_0.w * m_4.normal_compression_0, (*mat_6).energy_1.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(fdiv_0(m_4.tension_0, (*mat_6).strength_0.x * multiplier_0), 0.0f);
    var _S301 : f32;
    if(_S300 > 0.0f)
    {
        _S301 = fdiv_0(m_4.shear_0, _S300);
    }
    else
    {
        _S301 = infinity_0();
    }
    idx_0[i32(1)] = _S301;
    idx_0[i32(2)] = max(fdiv_0(m_4.compression_0, fc_0), 0.0f);
    var _S302 : f32 = (*b_34).stiff1_0.y;
    if(_S302 > 0.0f)
    {
        _S301 = fdiv_0(m_4.compressive_force_0, _S302);
    }
    else
    {
        _S301 = 0.0f;
    }
    idx_0[i32(3)] = _S301;
    return idx_0;
}

fn failure_indices_1( mat_7 : ptr<function, JointMaterial_std140_0>,  b_35 : ptr<function, JointBond_std430_0>,  m_5 : Measures_0,  multiplier_1 : f32) -> vec4<f32>
{
    var fc_1 : f32 = (*mat_7).strength_0.y * multiplier_1;
    var _S303 : f32 = min((*mat_7).strength_0.z * multiplier_1 + (*mat_7).strength_0.w * m_5.normal_compression_0, (*mat_7).energy_1.x * multiplier_1);
    var idx_1 : vec4<f32>;
    idx_1[i32(0)] = max(fdiv_0(m_5.tension_0, (*mat_7).strength_0.x * multiplier_1), 0.0f);
    var _S304 : f32;
    if(_S303 > 0.0f)
    {
        _S304 = fdiv_0(m_5.shear_0, _S303);
    }
    else
    {
        _S304 = infinity_0();
    }
    idx_1[i32(1)] = _S304;
    idx_1[i32(2)] = max(fdiv_0(m_5.compression_0, fc_1), 0.0f);
    var _S305 : f32 = (*b_35).stiff1_0.y;
    if(_S305 > 0.0f)
    {
        _S304 = fdiv_0(m_5.compressive_force_0, _S305);
    }
    else
    {
        _S304 = 0.0f;
    }
    idx_1[i32(3)] = _S304;
    return idx_1;
}

fn sq_0( x_13 : f32) -> f32
{
    return x_13 * x_13;
}

fn damage_law_0( kind_1 : u32,  kappa_1 : f32,  r_8 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_1 == u32(0))
    {
        if(r_8 <= 1.0f)
        {
            return 1.0f;
        }
        return min(fdiv_0(r_8 * (kappa_1 - 1.0f), kappa_1 * (r_8 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_8 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

fn damage_increment_0( kind_2 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_9 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S306 : f32 = max(damage_law_0(kind_2, lambda_0, r_9), d_old_0);
    var _S307 : bool;
    if(_S306 <= d_old_0)
    {
        _S307 = true;
    }
    else
    {
        _S307 = d_old_0 >= 1.0f;
    }
    if(_S307)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = fdiv_0(psi_0, lambda_0 * lambda_0);
    var _S308 : f32 = max(kappa_old_0, 1.0f);
    if(kind_2 == u32(0))
    {
        if(r_9 > 1.0f)
        {
            return vec2<f32>(_S306, fdiv_0(u0_0 * r_9, r_9 - 1.0f) * max(min(lambda_0, r_9) - min(_S308, r_9), 0.0f));
        }
        return vec2<f32>(_S306, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_9 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S308, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S306 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S306, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_3 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S309 : f32 = - h0_0;
    var _S310 : f32 = - h1_0;
    var _S311 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S309, _S310), vec2<f32>(h0_0, _S310), vec2<f32>(h0_0, h1_0), vec2<f32>(_S309, h1_0) );
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
        var _S312 : u32 = i_5;
        var _S313 : u32 = i_5 + u32(1);
        var _S314 : u32 = _S313 % u32(4);
        var _S315 : f32 = _S311[i_5].y;
        var _S316 : f32 = _S311[i_5].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S315 - ay_0 * _S316;
        var _S317 : f32 = _S311[_S314].y;
        var _S318 : f32 = _S311[_S314].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S317 - ay_0 * _S318;
        var _S319 : bool = fp_0 < 0.0f;
        if(_S319)
        {
            var _S320 : u32 = count_4 + u32(1);
            poly_0[count_4] = _S311[_S312];
            count_3 = _S320;
        }
        else
        {
            count_3 = count_4;
        }
        if(_S319 != (fq_0 < 0.0f))
        {
            var t_7 : f32 = fp_0 / (fp_0 - fq_0);
            var _S321 : u32 = count_3 + u32(1);
            poly_0[count_3] = vec2<f32>(_S316 + t_7 * (_S318 - _S316), _S315 + t_7 * (_S317 - _S315));
            count_4 = _S321;
        }
        else
        {
            count_4 = count_3;
        }
        i_5 = _S313;
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
    var a_15 : f32 = 0.0f;
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
        var _S322 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_5].x - _S322;
        var _S323 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_5].y - _S323;
        var _S324 : u32 = i_5 + u32(1);
        var _S325 : u32 = _S324 % count_4;
        var x1_0 : f32 = poly_0[_S325].x - _S322;
        var y1_0 : f32 = poly_0[_S325].y - _S323;
        var _S326 : f32 = x0_0 * y1_0;
        var _S327 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S326 - _S327;
        var a_16 : f32 = a_15 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S326 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S327) * cr_0 / 24.0f;
        i_5 = _S324;
        a_15 = a_16;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_15 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_15;
    var cy_0 : f32 = sy_0 / a_15;
    (*region_0)[i32(0)] = a_15;
    (*region_0)[i32(1)] = o_1.x + cx_0;
    (*region_0)[i32(2)] = o_1.y + cy_0;
    var _S328 : f32 = a_15 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S328 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_15 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S328 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_10 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_10));
    var a_17 : f32 = r_10[i32(0)];
    if((r_10[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_14 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_2 : f32 = dz_1 + ax_1 * r_10[i32(2)] - ay_1 * r_10[i32(1)];
    var _S329 : f32 = a_17 * fc_2;
    var _S330 : f32 = - ay_1;
    return vec4<f32>(k_14 * a_17 * fc_2, k_14 * (_S329 * r_10[i32(2)] + (_S330 * r_10[i32(5)] + ax_1 * r_10[i32(4)])), - k_14 * (_S329 * r_10[i32(1)] + (_S330 * r_10[i32(3)] + ax_1 * r_10[i32(5)])), 0.5f * k_14 * (_S329 * fc_2 + ay_1 * ay_1 * r_10[i32(3)] + ax_1 * ax_1 * r_10[i32(4)] - 2.0f * ax_1 * ay_1 * r_10[i32(5)]));
}

fn signum_0( x_14 : f32) -> f32
{
    var _S331 : f32;
    if((((bitcast<u32>((x_14))) & (u32(2147483648)))) != u32(0))
    {
        _S331 = -1.0f;
    }
    else
    {
        _S331 = 1.0f;
    }
    return _S331;
}

fn return_map_0( k_15 : f32,  total_2 : f32,  plastic_0 : f32,  cap_0 : f32) -> vec2<f32>
{
    var trial_0 : f32 = k_15 * (total_2 - plastic_0);
    if((abs(trial_0)) <= cap_0)
    {
        return vec2<f32>(trial_0, 0.0f);
    }
    var f_7 : f32 = cap_0 * signum_0(trial_0);
    return vec2<f32>(f_7, fdiv_0(trial_0 - f_7, k_15));
}

struct Contact_0
{
     q_lin_2 : vec3<f32>,
     q_ang_2 : vec3<f32>,
     energy_2 : f32,
     diss_2 : f32,
     plastic_1 : vec3<f32>,
};

fn contact_part_0( mat_8 : ptr<function, JointMaterial_std140_0>,  b_36 : ptr<function, JointBond_std430_0>,  crush_2 : f32,  plastic_2 : vec3<f32>,  d_lin_0 : vec3<f32>,  d_ang_0 : vec3<f32>) -> Contact_0
{
    var c_11 : Contact_0;
    var _S332 : vec3<f32> = vec3<f32>(0.0f);
    c_11.q_lin_2 = _S332;
    c_11.q_ang_2 = _S332;
    c_11.energy_2 = 0.0f;
    c_11.diss_2 = 0.0f;
    c_11.plastic_1 = plastic_2;
    var _S333 : u32 = (*mat_8).kind_flags_0.y;
    if(((_S333 & (u32(2)))) == u32(0))
    {
        return c_11;
    }
    var kn_1 : f32 = (*b_36).stiff0_0.x;
    var ks_0 : f32 = (*b_36).stiff0_0.y;
    var kt_0 : f32 = (*b_36).stiff1_0.x;
    var w0_2 : f32 = (*b_36).geom0_0.y;
    var w1_2 : f32 = (*b_36).geom0_0.z;
    var diss_3 : f32;
    var nc_sum_0 : f32;
    var m1_0 : f32;
    var m2_0 : f32;
    var energy_3 : f32;
    if(((_S333 & (u32(4)))) != u32(0))
    {
        var p_12 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S334 : f32 = p_12.y;
        var _S335 : f32 = p_12.z;
        var _S336 : f32 = p_12.w;
        nc_sum_0 = p_12.x;
        m1_0 = _S334;
        m2_0 = _S335;
        energy_3 = _S336;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S337 : f32 = d_ang_0.x;
        var _S338 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S337) * 0.4166666567325592f * w1_2 + abs(_S338) * 0.4166666567325592f * w0_2;
        var _S339 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S339) + spread_0);
        if((_S339 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S339 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S340 : f32 = ki_0 * _S337 * i2_0;
                var _S341 : f32 = ki_0 * _S338 * i1_0;
                var _S342 : f32 = 0.5f * ki_0 * (36.0f * _S339 * _S339 + _S337 * _S337 * i2_0 + _S338 * _S338 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S339;
                m1_0 = _S340;
                m2_0 = _S341;
                energy_3 = _S342;
            }
            else
            {
                var i_6 : u32 = u32(0);
                diss_3 = 0.0f;
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
                    var _S343 : f32 = SPRING_AT_0[i_6] * w0_2;
                    var j_7 : u32 = u32(0);
                    nc_sum_0 = diss_3;
                    m1_0 = m1_1;
                    m2_0 = m2_1;
                    energy_3 = energy_4;
                    loop
                    {
                        if(j_7 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var s2_0 : f32 = SPRING_AT_0[j_7] * w1_2;
                        var di_0 : f32 = _S339 + _S337 * s2_0 - _S338 * _S343;
                        if(di_0 < 0.0f)
                        {
                            var f_8 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_8 * s2_0;
                            var m2_2 : f32 = m2_0 - f_8 * _S343;
                            var energy_5 : f32 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_8;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_7 = j_7 + u32(1);
                    }
                    i_6 = i_6 + u32(1);
                    diss_3 = nc_sum_0;
                    m1_1 = m1_0;
                    m2_1 = m2_0;
                    energy_4 = energy_3;
                }
                nc_sum_0 = diss_3;
                m1_0 = m1_1;
                m2_0 = m2_1;
                energy_3 = energy_4;
            }
        }
    }
    var nc_0 : f32 = - nc_sum_0;
    var p_13 : vec3<f32> = plastic_2;
    c_11.q_lin_2 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_11.q_ang_2 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_8).strength_0.w * nc_0;
    var _S344 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S345 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var tn_0 : f32 = fsqrt_0(_S344 * _S344 + _S345 * _S345);
    var _S346 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S346 = tn_0 > 0.0f;
    }
    else
    {
        _S346 = false;
    }
    if(_S346)
    {
        var _S347 : f32 = fdiv_0(_S344, tn_0);
        var _S348 : f32 = fdiv_0(_S345, tn_0);
        var dslip_0 : f32 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        p_13[i32(0)] = p_13[i32(0)] + _S347 * dslip_0;
        p_13[i32(1)] = p_13[i32(1)] + _S348 * dslip_0;
        c_11.q_lin_2[i32(0)] = _S347 * slide_cap_0;
        c_11.q_lin_2[i32(1)] = _S348 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_11.q_lin_2[i32(0)] = _S344;
        c_11.q_lin_2[i32(1)] = _S345;
        diss_3 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_13.z, slide_cap_0 * (*b_36).geom1_0.z);
    var _S349 : f32 = tq_0.x;
    var _S350 : f32 = tq_0.y;
    var diss_4 : f32 = diss_3 + abs(_S349) * abs(_S350);
    p_13[i32(2)] = p_13[i32(2)] + _S350;
    c_11.q_ang_2[i32(2)] = _S349;
    c_11.energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0(c_11.q_lin_2.x), ks_0) + fdiv_0(sq_0(c_11.q_lin_2.y), ks_0) + fdiv_0(sq_0(_S349), kt_0));
    c_11.diss_2 = diss_4;
    c_11.plastic_1 = p_13;
    return c_11;
}

fn contact_part_1( mat_9 : ptr<function, JointMaterial_std140_0>,  b_37 : ptr<function, JointBond_std430_0>,  crush_3 : f32,  plastic_3 : vec3<f32>,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>) -> Contact_0
{
    var c_12 : Contact_0;
    var _S351 : vec3<f32> = vec3<f32>(0.0f);
    c_12.q_lin_2 = _S351;
    c_12.q_ang_2 = _S351;
    c_12.energy_2 = 0.0f;
    c_12.diss_2 = 0.0f;
    c_12.plastic_1 = plastic_3;
    var _S352 : u32 = (*mat_9).kind_flags_0.y;
    if(((_S352 & (u32(2)))) == u32(0))
    {
        return c_12;
    }
    var kn_2 : f32 = (*b_37).stiff0_0.x;
    var ks_1 : f32 = (*b_37).stiff0_0.y;
    var kt_1 : f32 = (*b_37).stiff1_0.x;
    var w0_3 : f32 = (*b_37).geom0_0.y;
    var w1_3 : f32 = (*b_37).geom0_0.z;
    var diss_5 : f32;
    var nc_sum_1 : f32;
    var m1_3 : f32;
    var m2_3 : f32;
    var energy_6 : f32;
    if(((_S352 & (u32(4)))) != u32(0))
    {
        var p_14 : vec4<f32> = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        var _S353 : f32 = p_14.y;
        var _S354 : f32 = p_14.z;
        var _S355 : f32 = p_14.w;
        nc_sum_1 = p_14.x;
        m1_3 = _S353;
        m2_3 = _S354;
        energy_6 = _S355;
    }
    else
    {
        var ki_1 : f32 = kn_2 * (1.0f - crush_3) / 36.0f;
        var _S356 : f32 = d_ang_1.x;
        var _S357 : f32 = d_ang_1.y;
        var spread_1 : f32 = abs(_S356) * 0.4166666567325592f * w1_3 + abs(_S357) * 0.4166666567325592f * w0_3;
        var _S358 : f32 = d_lin_1.z;
        var slack_1 : f32 = 9.99999997475242708e-07f * (abs(_S358) + spread_1);
        if((_S358 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
            m1_3 = 0.0f;
            m2_3 = 0.0f;
            energy_6 = 0.0f;
        }
        else
        {
            if((_S358 + spread_1) < (- slack_1))
            {
                var i1_1 : f32 = 2.91666650772094727f * w0_3 * w0_3;
                var i2_1 : f32 = 2.91666650772094727f * w1_3 * w1_3;
                var _S359 : f32 = ki_1 * _S356 * i2_1;
                var _S360 : f32 = ki_1 * _S357 * i1_1;
                var _S361 : f32 = 0.5f * ki_1 * (36.0f * _S358 * _S358 + _S356 * _S356 * i2_1 + _S357 * _S357 * i1_1);
                nc_sum_1 = ki_1 * 36.0f * _S358;
                m1_3 = _S359;
                m2_3 = _S360;
                energy_6 = _S361;
            }
            else
            {
                var i_7 : u32 = u32(0);
                diss_5 = 0.0f;
                var m1_4 : f32 = 0.0f;
                var m2_4 : f32 = 0.0f;
                var energy_7 : f32 = 0.0f;
                loop
                {
                    if(i_7 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S362 : f32 = SPRING_AT_0[i_7] * w0_3;
                    var j_8 : u32 = u32(0);
                    nc_sum_1 = diss_5;
                    m1_3 = m1_4;
                    m2_3 = m2_4;
                    energy_6 = energy_7;
                    loop
                    {
                        if(j_8 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var s2_1 : f32 = SPRING_AT_0[j_8] * w1_3;
                        var di_1 : f32 = _S358 + _S356 * s2_1 - _S357 * _S362;
                        if(di_1 < 0.0f)
                        {
                            var f_9 : f32 = ki_1 * di_1;
                            var m1_5 : f32 = m1_3 + f_9 * s2_1;
                            var m2_5 : f32 = m2_3 - f_9 * _S362;
                            var energy_8 : f32 = energy_6 + 0.5f * ki_1 * di_1 * di_1;
                            nc_sum_1 = nc_sum_1 + f_9;
                            m1_3 = m1_5;
                            m2_3 = m2_5;
                            energy_6 = energy_8;
                        }
                        j_8 = j_8 + u32(1);
                    }
                    i_7 = i_7 + u32(1);
                    diss_5 = nc_sum_1;
                    m1_4 = m1_3;
                    m2_4 = m2_3;
                    energy_7 = energy_6;
                }
                nc_sum_1 = diss_5;
                m1_3 = m1_4;
                m2_3 = m2_4;
                energy_6 = energy_7;
            }
        }
    }
    var nc_1 : f32 = - nc_sum_1;
    var p_15 : vec3<f32> = plastic_3;
    c_12.q_lin_2 = vec3<f32>(0.0f, 0.0f, nc_sum_1);
    c_12.q_ang_2 = vec3<f32>(m1_3, m2_3, 0.0f);
    var slide_cap_1 : f32 = (*mat_9).strength_0.w * nc_1;
    var _S363 : f32 = ks_1 * (d_lin_1.x - plastic_3.x);
    var _S364 : f32 = ks_1 * (d_lin_1.y - plastic_3.y);
    var tn_1 : f32 = fsqrt_0(_S363 * _S363 + _S364 * _S364);
    var _S365 : bool;
    if(tn_1 > slide_cap_1)
    {
        _S365 = tn_1 > 0.0f;
    }
    else
    {
        _S365 = false;
    }
    if(_S365)
    {
        var _S366 : f32 = fdiv_0(_S363, tn_1);
        var _S367 : f32 = fdiv_0(_S364, tn_1);
        var dslip_1 : f32 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        p_15[i32(0)] = p_15[i32(0)] + _S366 * dslip_1;
        p_15[i32(1)] = p_15[i32(1)] + _S367 * dslip_1;
        c_12.q_lin_2[i32(0)] = _S366 * slide_cap_1;
        c_12.q_lin_2[i32(1)] = _S367 * slide_cap_1;
        diss_5 = slide_cap_1 * dslip_1;
    }
    else
    {
        c_12.q_lin_2[i32(0)] = _S363;
        c_12.q_lin_2[i32(1)] = _S364;
        diss_5 = 0.0f;
    }
    var tq_1 : vec2<f32> = return_map_0(kt_1, d_ang_1.z, p_15.z, slide_cap_1 * (*b_37).geom1_0.z);
    var _S368 : f32 = tq_1.x;
    var _S369 : f32 = tq_1.y;
    var diss_6 : f32 = diss_5 + abs(_S368) * abs(_S369);
    p_15[i32(2)] = p_15[i32(2)] + _S369;
    c_12.q_ang_2[i32(2)] = _S368;
    c_12.energy_2 = energy_6 + 0.5f * (fdiv_0(sq_0(c_12.q_lin_2.x), ks_1) + fdiv_0(sq_0(c_12.q_lin_2.y), ks_1) + fdiv_0(sq_0(_S368), kt_1));
    c_12.diss_2 = diss_6;
    c_12.plastic_1 = p_15;
    return c_12;
}

fn contact_offsets_0( mat_10 : ptr<function, JointMaterial_std140_0>,  b_38 : ptr<function, JointBond_std430_0>,  crush_4 : f32,  plastic_4 : vec3<f32>,  d_lin_2 : vec3<f32>,  d_ang_2 : vec3<f32>) -> vec3<f32>
{
    var _S370 : u32 = (*mat_10).kind_flags_0.y;
    if(((_S370 & (u32(2)))) == u32(0))
    {
        return plastic_4;
    }
    var kn_3 : f32 = (*b_38).stiff0_0.x;
    var ks_2 : f32 = (*b_38).stiff0_0.y;
    var kt_2 : f32 = (*b_38).stiff1_0.x;
    var w0_4 : f32 = (*b_38).geom0_0.y;
    var w1_4 : f32 = (*b_38).geom0_0.z;
    var nc_sum_2 : f32;
    if(((_S370 & (u32(4)))) != u32(0))
    {
        var _S371 : vec4<f32> = no_tension_patch_0(kn_3 * (1.0f - crush_4), w0_4, w1_4, d_lin_2.z, d_ang_2.x, d_ang_2.y);
        nc_sum_2 = _S371.x;
    }
    else
    {
        var ki_2 : f32 = kn_3 * (1.0f - crush_4) / 36.0f;
        var _S372 : f32 = d_ang_2.x;
        var _S373 : f32 = d_ang_2.y;
        var spread_2 : f32 = abs(_S372) * 0.4166666567325592f * w1_4 + abs(_S373) * 0.4166666567325592f * w0_4;
        var _S374 : f32 = d_lin_2.z;
        var slack_2 : f32 = 9.99999997475242708e-07f * (abs(_S374) + spread_2);
        if((_S374 - spread_2) > slack_2)
        {
            nc_sum_2 = 0.0f;
        }
        else
        {
            if((_S374 + spread_2) < (- slack_2))
            {
                nc_sum_2 = ki_2 * 36.0f * _S374;
            }
            else
            {
                var i_8 : u32 = u32(0);
                var nc_sum_3 : f32 = 0.0f;
                loop
                {
                    if(i_8 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S375 : f32 = SPRING_AT_0[i_8] * w0_4;
                    var j_9 : u32 = u32(0);
                    nc_sum_2 = nc_sum_3;
                    loop
                    {
                        if(j_9 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var di_2 : f32 = _S374 + _S372 * (SPRING_AT_0[j_9] * w1_4) - _S373 * _S375;
                        if(di_2 < 0.0f)
                        {
                            nc_sum_2 = nc_sum_2 + ki_2 * di_2;
                        }
                        j_9 = j_9 + u32(1);
                    }
                    i_8 = i_8 + u32(1);
                    nc_sum_3 = nc_sum_2;
                }
                nc_sum_2 = nc_sum_3;
            }
        }
    }
    var nc_2 : f32 = - nc_sum_2;
    var p_16 : vec3<f32> = plastic_4;
    var slide_cap_2 : f32 = (*mat_10).strength_0.w * nc_2;
    var _S376 : f32 = ks_2 * (d_lin_2.x - plastic_4.x);
    var _S377 : f32 = ks_2 * (d_lin_2.y - plastic_4.y);
    var tn_2 : f32 = fsqrt_0(_S376 * _S376 + _S377 * _S377);
    var _S378 : bool;
    if(tn_2 > slide_cap_2)
    {
        _S378 = tn_2 > 0.0f;
    }
    else
    {
        _S378 = false;
    }
    if(_S378)
    {
        var _S379 : f32 = fdiv_0(_S377, tn_2);
        var dslip_2 : f32 = fdiv_0(tn_2 - slide_cap_2, ks_2);
        p_16[i32(0)] = p_16[i32(0)] + fdiv_0(_S376, tn_2) * dslip_2;
        p_16[i32(1)] = p_16[i32(1)] + _S379 * dslip_2;
    }
    p_16[i32(2)] = p_16[i32(2)] + return_map_0(kt_2, d_ang_2.z, p_16.z, slide_cap_2 * (*b_38).geom1_0.z).y;
    return p_16;
}

fn contact_offsets_1( mat_11 : ptr<function, JointMaterial_std140_0>,  b_39 : ptr<function, JointBond_std430_0>,  crush_5 : f32,  plastic_5 : vec3<f32>,  d_lin_3 : vec3<f32>,  d_ang_3 : vec3<f32>) -> vec3<f32>
{
    var _S380 : u32 = (*mat_11).kind_flags_0.y;
    if(((_S380 & (u32(2)))) == u32(0))
    {
        return plastic_5;
    }
    var kn_4 : f32 = (*b_39).stiff0_0.x;
    var ks_3 : f32 = (*b_39).stiff0_0.y;
    var kt_3 : f32 = (*b_39).stiff1_0.x;
    var w0_5 : f32 = (*b_39).geom0_0.y;
    var w1_5 : f32 = (*b_39).geom0_0.z;
    var nc_sum_4 : f32;
    if(((_S380 & (u32(4)))) != u32(0))
    {
        var _S381 : vec4<f32> = no_tension_patch_0(kn_4 * (1.0f - crush_5), w0_5, w1_5, d_lin_3.z, d_ang_3.x, d_ang_3.y);
        nc_sum_4 = _S381.x;
    }
    else
    {
        var ki_3 : f32 = kn_4 * (1.0f - crush_5) / 36.0f;
        var _S382 : f32 = d_ang_3.x;
        var _S383 : f32 = d_ang_3.y;
        var spread_3 : f32 = abs(_S382) * 0.4166666567325592f * w1_5 + abs(_S383) * 0.4166666567325592f * w0_5;
        var _S384 : f32 = d_lin_3.z;
        var slack_3 : f32 = 9.99999997475242708e-07f * (abs(_S384) + spread_3);
        if((_S384 - spread_3) > slack_3)
        {
            nc_sum_4 = 0.0f;
        }
        else
        {
            if((_S384 + spread_3) < (- slack_3))
            {
                nc_sum_4 = ki_3 * 36.0f * _S384;
            }
            else
            {
                var i_9 : u32 = u32(0);
                var nc_sum_5 : f32 = 0.0f;
                loop
                {
                    if(i_9 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S385 : f32 = SPRING_AT_0[i_9] * w0_5;
                    var j_10 : u32 = u32(0);
                    nc_sum_4 = nc_sum_5;
                    loop
                    {
                        if(j_10 < u32(6))
                        {
                        }
                        else
                        {
                            break;
                        }
                        var di_3 : f32 = _S384 + _S382 * (SPRING_AT_0[j_10] * w1_5) - _S383 * _S385;
                        if(di_3 < 0.0f)
                        {
                            nc_sum_4 = nc_sum_4 + ki_3 * di_3;
                        }
                        j_10 = j_10 + u32(1);
                    }
                    i_9 = i_9 + u32(1);
                    nc_sum_5 = nc_sum_4;
                }
                nc_sum_4 = nc_sum_5;
            }
        }
    }
    var nc_3 : f32 = - nc_sum_4;
    var p_17 : vec3<f32> = plastic_5;
    var slide_cap_3 : f32 = (*mat_11).strength_0.w * nc_3;
    var _S386 : f32 = ks_3 * (d_lin_3.x - plastic_5.x);
    var _S387 : f32 = ks_3 * (d_lin_3.y - plastic_5.y);
    var tn_3 : f32 = fsqrt_0(_S386 * _S386 + _S387 * _S387);
    var _S388 : bool;
    if(tn_3 > slide_cap_3)
    {
        _S388 = tn_3 > 0.0f;
    }
    else
    {
        _S388 = false;
    }
    if(_S388)
    {
        var _S389 : f32 = fdiv_0(_S387, tn_3);
        var dslip_3 : f32 = fdiv_0(tn_3 - slide_cap_3, ks_3);
        p_17[i32(0)] = p_17[i32(0)] + fdiv_0(_S386, tn_3) * dslip_3;
        p_17[i32(1)] = p_17[i32(1)] + _S389 * dslip_3;
    }
    p_17[i32(2)] = p_17[i32(2)] + return_map_0(kt_3, d_ang_3.z, p_17.z, slide_cap_3 * (*b_39).geom1_0.z).y;
    return p_17;
}

fn life_rate_0( mat_12 : ptr<function, JointMaterial_std140_0>,  s_6 : f32) -> f32
{
    if(s_6 <= 0.0f)
    {
        return 0.0f;
    }
    var _S390 : f32 = (*mat_12).misc_0.y;
    return fdiv_0((_S390 + 1.0f) * fpow_0(s_6, _S390), (*mat_12).misc_0.z);
}

fn life_rate_1( mat_13 : ptr<function, JointMaterial_std140_0>,  s_7 : f32) -> f32
{
    if(s_7 <= 0.0f)
    {
        return 0.0f;
    }
    var _S391 : f32 = (*mat_13).misc_0.y;
    return fdiv_0((_S391 + 1.0f) * fpow_0(s_7, _S391), (*mat_13).misc_0.z);
}

struct JointResponse_0
{
     force_lin_1 : vec3<f32>,
     force_ang_1 : vec3<f32>,
     state_1 : JointState_0,
     dissipated_4 : f32,
     overshoot_0 : f32,
     stored_5 : f32,
     disconnected_0 : bool,
     fatigue_before_0 : f32,
     measures_0 : Measures_0,
};

fn joint_evaluate_0( mat_14 : ptr<function, JointMaterial_std140_0>,  b_40 : ptr<function, JointBond_std430_0>,  state_2 : ptr<function, JointState_std430_0>,  d_lin_4 : vec3<f32>,  d_ang_4 : vec3<f32>,  dt_7 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_5 : f32 = (*b_40).stiff0_0.x;
    var ks_4 : f32 = (*b_40).stiff0_0.y;
    var kb1_0 : f32 = (*b_40).stiff0_0.z;
    var kb2_0 : f32 = (*b_40).stiff0_0.w;
    var _S392 : vec4<f32> = (*b_40).stiff1_0;
    var kt_4 : f32 = (*b_40).stiff1_0.x;
    var has_rebar_4 : bool = ((*b_40).stiff1_0.w) != 0.0f;
    var kind_3 : u32 = (*mat_14).kind_flags_0.x;
    var flags_1 : u32 = (*mat_14).kind_flags_0.y;
    var softening_0 : bool = ((flags_1 & (u32(1)))) != u32(0);
    var st_6 : JointState_0;
    st_6.damage_0 = (*state_2).damage_0;
    st_6.crush_1 = (*state_2).crush_1;
    st_6.kappa_0 = (*state_2).kappa_0;
    st_6.kappa_c_0 = (*state_2).kappa_c_0;
    st_6.ductility_0 = (*state_2).ductility_0;
    st_6.ductility_c_0 = (*state_2).ductility_c_0;
    st_6.life_0 = (*state_2).life_0;
    st_6.plastic_x_0 = (*state_2).plastic_x_0;
    st_6.plastic_y_0 = (*state_2).plastic_y_0;
    st_6.plastic_t_0 = (*state_2).plastic_t_0;
    st_6.rebar_plastic_0 = (*state_2).rebar_plastic_0;
    st_6.rebar_slip0_0 = (*state_2).rebar_slip0_0;
    st_6.rebar_slip1_0 = (*state_2).rebar_slip1_0;
    st_6.rebar_work_0 = (*state_2).rebar_work_0;
    st_6.rebar_broken_0 = (*state_2).rebar_broken_0;
    st_6.strain_rate_0 = (*state_2).strain_rate_0;
    st_6.governing_stress_0 = (*state_2).governing_stress_0;
    st_6.dissipated_0 = (*state_2).dissipated_0;
    st_6.utilization_0 = (*state_2).utilization_0;
    st_6.mode_0 = (*state_2).mode_0;
    var _S393 : bool = connected_0(&((*state_2)), has_rebar_4);
    var qe_lin_0 : vec3<f32> = d_lin_4 * vec3<f32>(ks_4, ks_4, kn_5);
    var qe_ang_0 : vec3<f32> = d_ang_4 * vec3<f32>(kb1_0, kb2_0, kt_4);
    var _S394 : Measures_0 = stress_measures_0(&((*b_40)), qe_lin_0, qe_ang_0);
    var _S395 : f32 = max(max(_S394.tension_0, _S394.shear_0), _S394.compression_0);
    var _S396 : bool = dt_7 > 0.0f;
    var dif_1 : f32;
    if(_S396)
    {
        var raw_0 : f32 = fdiv_0(max(fdiv_0(_S395 - st_6.governing_stress_0, dt_7), 0.0f), (*mat_14).misc_0.w);
        var tau_2 : f32 = _S392.z;
        if(((flags_1 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_7, tau_2));
        }
        else
        {
            dif_1 = min(fdiv_0(dt_7, tau_2), 1.0f);
        }
        st_6.strain_rate_0 = st_6.strain_rate_0 + (raw_0 - st_6.strain_rate_0) * dif_1;
        st_6.governing_stress_0 = _S395;
    }
    if(((flags_1 & (u32(32)))) != u32(0))
    {
        var _S397 : f32 = dif_factor_0(&((*mat_14)), st_6.strain_rate_0);
        dif_1 = _S397;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_40).geom1_0.w;
    var _S398 : f32 = fatigue_factor_1(&((*mat_14)), st_6.life_0);
    var multiplier_2 : f32 = weibull_0 * dif_1 * _S398;
    var _S399 : vec4<f32> = failure_indices_0(&((*mat_14)), &((*b_40)), _S394, multiplier_2);
    var _S400 : f32 = _S399.x;
    var _S401 : f32 = _S399.y;
    st_6.utilization_0 = max(max(_S400, _S401), max(_S399.z, _S399.w));
    var _S402 : f32 = d_lin_4.x;
    var _S403 : f32 = d_lin_4.y;
    var _S404 : f32 = ks_4 * (sq_0(_S402) + sq_0(_S403)) + kb1_0 * sq_0(d_ang_4.x) + kb2_0 * sq_0(d_ang_4.y) + kt_4 * sq_0(d_ang_4.z);
    var _S405 : f32 = d_lin_4.z;
    var _S406 : bool = _S405 > 0.0f;
    if(_S406)
    {
        dif_1 = kn_5 * sq_0(_S405);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S404 + dif_1);
    var psi_c_0 : f32;
    if(_S405 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_5 * sq_0(_S405);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    var plastic_6 : vec3<f32> = vec3<f32>(st_6.plastic_x_0, st_6.plastic_y_0, st_6.plastic_t_0);
    var diss_contact_0 : f32;
    var psi_contact_0 : f32;
    var intact_normal_0 : f32;
    var dissipated_5 : f32;
    var overshoot_1 : f32;
    var _S407 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S408 : bool = _S400 >= _S401;
        if(_S408)
        {
            diss_contact_0 = _S400;
        }
        else
        {
            diss_contact_0 = _S401;
        }
        var mode_ts_0 : u32;
        if(_S408)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_6.kappa_0))
        {
            _S407 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S407 = false;
        }
        if(_S407)
        {
            _S407 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S407 = false;
        }
        var mode_c_0 : u32;
        if(_S407)
        {
            if(mode_ts_0 == u32(1))
            {
                psi_contact_0 = (*mat_14).energy_1.y;
            }
            else
            {
                psi_contact_0 = (*mat_14).energy_1.z;
            }
            if(softening_0)
            {
                intact_normal_0 = fdiv_0(psi_contact_0 * (*b_40).geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_6.ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_3;
            }
            else
            {
                mode_c_0 = u32(0);
            }
            var inc_0 : vec2<f32> = damage_increment_0(mode_c_0, st_6.kappa_0, diss_contact_0, intact_normal_0, st_6.damage_0, psi_ts_0);
            var _S409 : f32 = inc_0.x;
            if(_S409 > (st_6.damage_0))
            {
                var _S410 : Contact_0 = contact_part_0(&((*mat_14)), &((*b_40)), st_6.crush_1, plastic_6, d_lin_4, d_ang_4);
                var _S411 : f32 = max(_S410.energy_2 - (1.0f - st_6.crush_1) * psi_c_0, 0.0f);
                var _S412 : f32 = max(inc_0.y - _S411 * (_S409 - st_6.damage_0), 0.0f);
                var _S413 : f32 = max((psi_ts_0 - _S411) * (_S409 - st_6.damage_0) - _S412, 0.0f);
                st_6.damage_0 = _S409;
                st_6.mode_0 = mode_ts_0;
                dissipated_5 = _S412;
                overshoot_1 = _S413;
            }
            else
            {
                dissipated_5 = 0.0f;
                overshoot_1 = 0.0f;
            }
        }
        else
        {
            dissipated_5 = 0.0f;
            overshoot_1 = 0.0f;
        }
        st_6.kappa_0 = max(st_6.kappa_0, diss_contact_0);
        var _S414 : f32 = (*state_2).damage_0;
        if(((*state_2).damage_0) > 0.0f)
        {
            var _S415 : Contact_0 = contact_part_0(&((*mat_14)), &((*b_40)), (*state_2).crush_1, vec3<f32>((*state_2).plastic_x_0, (*state_2).plastic_y_0, (*state_2).plastic_t_0), d_lin_4, d_ang_4);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - _S414)) + _S415.q_ang_2 * vec3<f32>(_S414);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S416 : Measures_0 = stress_measures_0(&((*b_40)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S417 : vec4<f32> = failure_indices_0(&((*mat_14)), &((*b_40)), _S416, multiplier_2);
        var _S418 : f32 = _S417.z;
        var _S419 : f32 = _S417.w;
        var _S420 : bool = _S418 >= _S419;
        if(_S420)
        {
            psi_contact_0 = _S418;
        }
        else
        {
            psi_contact_0 = _S419;
        }
        if(_S420)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_6.kappa_c_0))
        {
            _S407 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S407 = false;
        }
        if(_S407)
        {
            _S407 = psi_c_0 > 0.0f;
        }
        else
        {
            _S407 = false;
        }
        if(_S407)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0((*mat_14).energy_1.w * (*b_40).geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_6.ductility_c_0 = intact_normal_0;
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
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_6.kappa_c_0, psi_contact_0, intact_normal_0, st_6.crush_1, psi_c_0);
            var _S421 : f32 = inc_1.x;
            if(_S421 > (st_6.crush_1))
            {
                var _S422 : f32 = inc_1.y;
                var dissipated_6 : f32 = dissipated_5 + _S422;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S421 - st_6.crush_1) - _S422, 0.0f);
                st_6.crush_1 = _S421;
                st_6.mode_0 = mode_c_0;
                if(_S421 >= 1.0f)
                {
                    _S407 = (st_6.damage_0) < 1.0f;
                }
                else
                {
                    _S407 = false;
                }
                if(_S407)
                {
                    var dissipated_7 : f32 = dissipated_6 + psi_ts_0 * (1.0f - st_6.damage_0);
                    st_6.damage_0 = 1.0f;
                    dissipated_5 = dissipated_7;
                }
                else
                {
                    dissipated_5 = dissipated_6;
                }
                overshoot_1 = overshoot_2;
            }
        }
        st_6.kappa_c_0 = max(st_6.kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_5 = 0.0f;
        overshoot_1 = 0.0f;
    }
    var dmg_0 : f32 = st_6.damage_0;
    var _S423 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_0 : vec3<f32>;
    if((st_6.damage_0) == 0.0f)
    {
        if(((flags_1 & (u32(8)))) == u32(0))
        {
            var _S424 : vec3<f32> = contact_offsets_0(&((*mat_14)), &((*b_40)), st_6.crush_1, plastic_6, d_lin_4, d_ang_4);
            st_6.plastic_x_0 = _S424.x;
            st_6.plastic_y_0 = _S424.y;
            st_6.plastic_t_0 = _S424.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S423;
        qc_ang_0 = _S423;
        psi_contact_0 = 0.0f;
    }
    else
    {
        var _S425 : Contact_0 = contact_part_0(&((*mat_14)), &((*b_40)), st_6.crush_1, plastic_6, d_lin_4, d_ang_4);
        st_6.plastic_x_0 = _S425.plastic_1.x;
        st_6.plastic_y_0 = _S425.plastic_1.y;
        st_6.plastic_t_0 = _S425.plastic_1.z;
        diss_contact_0 = _S425.diss_2;
        qc_lin_0 = _S425.q_lin_2;
        qc_ang_0 = _S425.q_ang_2;
        psi_contact_0 = _S425.energy_2;
    }
    var dissipated_8 : f32 = dissipated_5 + dmg_0 * diss_contact_0;
    if(_S406)
    {
        intact_normal_0 = kn_5 * _S405;
    }
    else
    {
        intact_normal_0 = (1.0f - st_6.crush_1) * kn_5 * _S405;
    }
    var _S426 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S426 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S426 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S426 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S426) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_6 : f32 = _S426 * (psi_ts_0 + (1.0f - st_6.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_4)
    {
        _S407 = (st_6.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S407 = false;
    }
    var stored_7 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S407)
    {
        var k_axial_0 : f32 = (*b_40).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_40).rebar0_0.y;
        var yield_force_0 : f32 = (*b_40).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_40).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S405, st_6.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S402, st_6.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S403, st_6.rebar_slip1_0, dowel_capacity_0);
        var _S427 : f32 = nr_0.y;
        var _S428 : f32 = v1_0.y;
        var _S429 : f32 = v2_0.y;
        var work_0 : f32 = yield_force_0 * abs(_S427) + dowel_capacity_0 * (abs(_S428) + abs(_S429));
        st_6.rebar_plastic_0 = st_6.rebar_plastic_0 + _S427;
        st_6.rebar_slip0_0 = st_6.rebar_slip0_0 + _S428;
        st_6.rebar_slip1_0 = st_6.rebar_slip1_0 + _S429;
        st_6.rebar_work_0 = st_6.rebar_work_0 + work_0;
        var dissipated_9 : f32 = dissipated_8 + work_0;
        var _S430 : f32 = nr_0.x;
        var _S431 : f32 = v1_0.x;
        var _S432 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (fdiv_0(sq_0(_S430), k_axial_0) + fdiv_0(sq_0(_S431) + sq_0(_S432), k_dowel_0));
        if(fracture_1)
        {
            _S407 = (st_6.rebar_work_0) >= ((*b_40).rebar1_0.x);
        }
        else
        {
            _S407 = false;
        }
        if(_S407)
        {
            st_6.rebar_broken_0 = 1.0f;
            var dissipated_10 : f32 = dissipated_9 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_5 = dissipated_10;
            stored_7 = stored_6;
        }
        else
        {
            var stored_8 : f32 = stored_6 + elastic_0;
            force_lin_3 = force_lin_2 + vec3<f32>(_S431, _S432, _S430);
            dissipated_5 = dissipated_9;
            stored_7 = stored_8;
        }
    }
    else
    {
        force_lin_3 = force_lin_2;
        dissipated_5 = dissipated_8;
        stored_7 = stored_6;
    }
    if(fracture_1)
    {
        _S407 = _S396;
    }
    else
    {
        _S407 = false;
    }
    if(_S407)
    {
        _S407 = ((flags_1 & (u32(64)))) != u32(0);
    }
    else
    {
        _S407 = false;
    }
    if(_S407)
    {
        var _S433 : Measures_0 = stress_measures_0(&((*b_40)), force_lin_3, force_ang_2);
        var _S434 : vec4<f32> = failure_indices_0(&((*mat_14)), &((*b_40)), _S433, weibull_0);
        var _S435 : f32 = life_rate_0(&((*mat_14)), max(max(_S434.x, _S434.y), _S434.z));
        st_6.life_0 = max(st_6.life_0 - _S435 * dt_7, 0.0f);
    }
    st_6.dissipated_0 = st_6.dissipated_0 + dissipated_5;
    var resp_0 : JointResponse_0;
    resp_0.force_lin_1 = force_lin_3;
    resp_0.force_ang_1 = force_ang_2;
    resp_0.state_1 = st_6;
    resp_0.dissipated_4 = dissipated_5;
    resp_0.overshoot_0 = overshoot_1;
    resp_0.stored_5 = stored_7;
    if(_S393)
    {
        _S407 = !connected_3(st_6, has_rebar_4);
    }
    else
    {
        _S407 = false;
    }
    resp_0.disconnected_0 = _S407;
    resp_0.fatigue_before_0 = _S398;
    resp_0.measures_0 = _S394;
    return resp_0;
}

fn joint_evaluate_1( mat_15 : ptr<function, JointMaterial_std140_0>,  b_41 : ptr<function, JointBond_std430_0>,  state_3 : ptr<function, JointState_std430_0>,  d_lin_5 : vec3<f32>,  d_ang_5 : vec3<f32>,  dt_8 : f32,  fracture_2 : bool) -> JointResponse_0
{
    var kn_6 : f32 = (*b_41).stiff0_0.x;
    var ks_5 : f32 = (*b_41).stiff0_0.y;
    var kb1_1 : f32 = (*b_41).stiff0_0.z;
    var kb2_1 : f32 = (*b_41).stiff0_0.w;
    var _S436 : vec4<f32> = (*b_41).stiff1_0;
    var kt_5 : f32 = (*b_41).stiff1_0.x;
    var has_rebar_5 : bool = ((*b_41).stiff1_0.w) != 0.0f;
    var kind_4 : u32 = (*mat_15).kind_flags_0.x;
    var flags_2 : u32 = (*mat_15).kind_flags_0.y;
    var softening_1 : bool = ((flags_2 & (u32(1)))) != u32(0);
    var st_7 : JointState_0;
    st_7.damage_0 = (*state_3).damage_0;
    st_7.crush_1 = (*state_3).crush_1;
    st_7.kappa_0 = (*state_3).kappa_0;
    st_7.kappa_c_0 = (*state_3).kappa_c_0;
    st_7.ductility_0 = (*state_3).ductility_0;
    st_7.ductility_c_0 = (*state_3).ductility_c_0;
    st_7.life_0 = (*state_3).life_0;
    st_7.plastic_x_0 = (*state_3).plastic_x_0;
    st_7.plastic_y_0 = (*state_3).plastic_y_0;
    st_7.plastic_t_0 = (*state_3).plastic_t_0;
    st_7.rebar_plastic_0 = (*state_3).rebar_plastic_0;
    st_7.rebar_slip0_0 = (*state_3).rebar_slip0_0;
    st_7.rebar_slip1_0 = (*state_3).rebar_slip1_0;
    st_7.rebar_work_0 = (*state_3).rebar_work_0;
    st_7.rebar_broken_0 = (*state_3).rebar_broken_0;
    st_7.strain_rate_0 = (*state_3).strain_rate_0;
    st_7.governing_stress_0 = (*state_3).governing_stress_0;
    st_7.dissipated_0 = (*state_3).dissipated_0;
    st_7.utilization_0 = (*state_3).utilization_0;
    st_7.mode_0 = (*state_3).mode_0;
    var _S437 : bool = connected_2(&((*state_3)), has_rebar_5);
    var qe_lin_1 : vec3<f32> = d_lin_5 * vec3<f32>(ks_5, ks_5, kn_6);
    var qe_ang_1 : vec3<f32> = d_ang_5 * vec3<f32>(kb1_1, kb2_1, kt_5);
    var _S438 : Measures_0 = stress_measures_1(&((*b_41)), qe_lin_1, qe_ang_1);
    var _S439 : f32 = max(max(_S438.tension_0, _S438.shear_0), _S438.compression_0);
    var _S440 : bool = dt_8 > 0.0f;
    var dif_2 : f32;
    if(_S440)
    {
        var raw_1 : f32 = fdiv_0(max(fdiv_0(_S439 - st_7.governing_stress_0, dt_8), 0.0f), (*mat_15).misc_0.w);
        var tau_3 : f32 = _S436.z;
        if(((flags_2 & (u32(16)))) != u32(0))
        {
            dif_2 = - expm1_accurate_0(- fdiv_0(dt_8, tau_3));
        }
        else
        {
            dif_2 = min(fdiv_0(dt_8, tau_3), 1.0f);
        }
        st_7.strain_rate_0 = st_7.strain_rate_0 + (raw_1 - st_7.strain_rate_0) * dif_2;
        st_7.governing_stress_0 = _S439;
    }
    if(((flags_2 & (u32(32)))) != u32(0))
    {
        var _S441 : f32 = dif_factor_1(&((*mat_15)), st_7.strain_rate_0);
        dif_2 = _S441;
    }
    else
    {
        dif_2 = 1.0f;
    }
    var weibull_1 : f32 = (*b_41).geom1_0.w;
    var _S442 : f32 = fatigue_factor_2(&((*mat_15)), st_7.life_0);
    var multiplier_3 : f32 = weibull_1 * dif_2 * _S442;
    var _S443 : vec4<f32> = failure_indices_1(&((*mat_15)), &((*b_41)), _S438, multiplier_3);
    var _S444 : f32 = _S443.x;
    var _S445 : f32 = _S443.y;
    st_7.utilization_0 = max(max(_S444, _S445), max(_S443.z, _S443.w));
    var _S446 : f32 = d_lin_5.x;
    var _S447 : f32 = d_lin_5.y;
    var _S448 : f32 = ks_5 * (sq_0(_S446) + sq_0(_S447)) + kb1_1 * sq_0(d_ang_5.x) + kb2_1 * sq_0(d_ang_5.y) + kt_5 * sq_0(d_ang_5.z);
    var _S449 : f32 = d_lin_5.z;
    var _S450 : bool = _S449 > 0.0f;
    if(_S450)
    {
        dif_2 = kn_6 * sq_0(_S449);
    }
    else
    {
        dif_2 = 0.0f;
    }
    var psi_ts_1 : f32 = 0.5f * (_S448 + dif_2);
    var psi_c_1 : f32;
    if(_S449 < 0.0f)
    {
        psi_c_1 = 0.5f * kn_6 * sq_0(_S449);
    }
    else
    {
        psi_c_1 = 0.0f;
    }
    var plastic_7 : vec3<f32> = vec3<f32>(st_7.plastic_x_0, st_7.plastic_y_0, st_7.plastic_t_0);
    var diss_contact_1 : f32;
    var psi_contact_1 : f32;
    var intact_normal_1 : f32;
    var dissipated_11 : f32;
    var overshoot_3 : f32;
    var _S451 : bool;
    var qc_lin_1 : vec3<f32>;
    if(fracture_2)
    {
        var _S452 : bool = _S444 >= _S445;
        if(_S452)
        {
            diss_contact_1 = _S444;
        }
        else
        {
            diss_contact_1 = _S445;
        }
        var mode_ts_1 : u32;
        if(_S452)
        {
            mode_ts_1 = u32(1);
        }
        else
        {
            mode_ts_1 = u32(2);
        }
        if(diss_contact_1 > (st_7.kappa_0))
        {
            _S451 = diss_contact_1 > 1.0f;
        }
        else
        {
            _S451 = false;
        }
        if(_S451)
        {
            _S451 = psi_ts_1 > 0.0f;
        }
        else
        {
            _S451 = false;
        }
        var mode_c_1 : u32;
        if(_S451)
        {
            if(mode_ts_1 == u32(1))
            {
                psi_contact_1 = (*mat_15).energy_1.y;
            }
            else
            {
                psi_contact_1 = (*mat_15).energy_1.z;
            }
            if(softening_1)
            {
                intact_normal_1 = fdiv_0(psi_contact_1 * (*b_41).geom0_0.x * diss_contact_1 * diss_contact_1, psi_ts_1);
            }
            else
            {
                intact_normal_1 = 0.0f;
            }
            st_7.ductility_0 = intact_normal_1;
            if(softening_1)
            {
                mode_c_1 = kind_4;
            }
            else
            {
                mode_c_1 = u32(0);
            }
            var inc_2 : vec2<f32> = damage_increment_0(mode_c_1, st_7.kappa_0, diss_contact_1, intact_normal_1, st_7.damage_0, psi_ts_1);
            var _S453 : f32 = inc_2.x;
            if(_S453 > (st_7.damage_0))
            {
                var _S454 : Contact_0 = contact_part_1(&((*mat_15)), &((*b_41)), st_7.crush_1, plastic_7, d_lin_5, d_ang_5);
                var _S455 : f32 = max(_S454.energy_2 - (1.0f - st_7.crush_1) * psi_c_1, 0.0f);
                var _S456 : f32 = max(inc_2.y - _S455 * (_S453 - st_7.damage_0), 0.0f);
                var _S457 : f32 = max((psi_ts_1 - _S455) * (_S453 - st_7.damage_0) - _S456, 0.0f);
                st_7.damage_0 = _S453;
                st_7.mode_0 = mode_ts_1;
                dissipated_11 = _S456;
                overshoot_3 = _S457;
            }
            else
            {
                dissipated_11 = 0.0f;
                overshoot_3 = 0.0f;
            }
        }
        else
        {
            dissipated_11 = 0.0f;
            overshoot_3 = 0.0f;
        }
        st_7.kappa_0 = max(st_7.kappa_0, diss_contact_1);
        var _S458 : f32 = (*state_3).damage_0;
        if(((*state_3).damage_0) > 0.0f)
        {
            var _S459 : Contact_0 = contact_part_1(&((*mat_15)), &((*b_41)), (*state_3).crush_1, vec3<f32>((*state_3).plastic_x_0, (*state_3).plastic_y_0, (*state_3).plastic_t_0), d_lin_5, d_ang_5);
            qc_lin_1 = qe_ang_1 * vec3<f32>((1.0f - _S458)) + _S459.q_ang_2 * vec3<f32>(_S458);
        }
        else
        {
            qc_lin_1 = qe_ang_1;
        }
        var _S460 : Measures_0 = stress_measures_1(&((*b_41)), vec3<f32>(0.0f, 0.0f, min(qe_lin_1.z, 0.0f)), qc_lin_1);
        var _S461 : vec4<f32> = failure_indices_1(&((*mat_15)), &((*b_41)), _S460, multiplier_3);
        var _S462 : f32 = _S461.z;
        var _S463 : f32 = _S461.w;
        var _S464 : bool = _S462 >= _S463;
        if(_S464)
        {
            psi_contact_1 = _S462;
        }
        else
        {
            psi_contact_1 = _S463;
        }
        if(_S464)
        {
            mode_c_1 = u32(3);
        }
        else
        {
            mode_c_1 = u32(4);
        }
        if(psi_contact_1 > (st_7.kappa_c_0))
        {
            _S451 = psi_contact_1 > 1.0f;
        }
        else
        {
            _S451 = false;
        }
        if(_S451)
        {
            _S451 = psi_c_1 > 0.0f;
        }
        else
        {
            _S451 = false;
        }
        if(_S451)
        {
            if(softening_1)
            {
                intact_normal_1 = fdiv_0((*mat_15).energy_1.w * (*b_41).geom0_0.x * psi_contact_1 * psi_contact_1, psi_c_1);
            }
            else
            {
                intact_normal_1 = 0.0f;
            }
            st_7.ductility_c_0 = intact_normal_1;
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
            var inc_3 : vec2<f32> = damage_increment_0(law_2, st_7.kappa_c_0, psi_contact_1, intact_normal_1, st_7.crush_1, psi_c_1);
            var _S465 : f32 = inc_3.x;
            if(_S465 > (st_7.crush_1))
            {
                var _S466 : f32 = inc_3.y;
                var dissipated_12 : f32 = dissipated_11 + _S466;
                var overshoot_4 : f32 = overshoot_3 + max(psi_c_1 * (_S465 - st_7.crush_1) - _S466, 0.0f);
                st_7.crush_1 = _S465;
                st_7.mode_0 = mode_c_1;
                if(_S465 >= 1.0f)
                {
                    _S451 = (st_7.damage_0) < 1.0f;
                }
                else
                {
                    _S451 = false;
                }
                if(_S451)
                {
                    var dissipated_13 : f32 = dissipated_12 + psi_ts_1 * (1.0f - st_7.damage_0);
                    st_7.damage_0 = 1.0f;
                    dissipated_11 = dissipated_13;
                }
                else
                {
                    dissipated_11 = dissipated_12;
                }
                overshoot_3 = overshoot_4;
            }
        }
        st_7.kappa_c_0 = max(st_7.kappa_c_0, psi_contact_1);
    }
    else
    {
        dissipated_11 = 0.0f;
        overshoot_3 = 0.0f;
    }
    var dmg_1 : f32 = st_7.damage_0;
    var _S467 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_1 : vec3<f32>;
    if((st_7.damage_0) == 0.0f)
    {
        if(((flags_2 & (u32(8)))) == u32(0))
        {
            var _S468 : vec3<f32> = contact_offsets_1(&((*mat_15)), &((*b_41)), st_7.crush_1, plastic_7, d_lin_5, d_ang_5);
            st_7.plastic_x_0 = _S468.x;
            st_7.plastic_y_0 = _S468.y;
            st_7.plastic_t_0 = _S468.z;
        }
        diss_contact_1 = 0.0f;
        qc_lin_1 = _S467;
        qc_ang_1 = _S467;
        psi_contact_1 = 0.0f;
    }
    else
    {
        var _S469 : Contact_0 = contact_part_1(&((*mat_15)), &((*b_41)), st_7.crush_1, plastic_7, d_lin_5, d_ang_5);
        st_7.plastic_x_0 = _S469.plastic_1.x;
        st_7.plastic_y_0 = _S469.plastic_1.y;
        st_7.plastic_t_0 = _S469.plastic_1.z;
        diss_contact_1 = _S469.diss_2;
        qc_lin_1 = _S469.q_lin_2;
        qc_ang_1 = _S469.q_ang_2;
        psi_contact_1 = _S469.energy_2;
    }
    var dissipated_14 : f32 = dissipated_11 + dmg_1 * diss_contact_1;
    if(_S450)
    {
        intact_normal_1 = kn_6 * _S449;
    }
    else
    {
        intact_normal_1 = (1.0f - st_7.crush_1) * kn_6 * _S449;
    }
    var _S470 : f32 = 1.0f - dmg_1;
    var force_lin_4 : vec3<f32> = vec3<f32>(_S470 * qe_lin_1.x + dmg_1 * qc_lin_1.x, _S470 * qe_lin_1.y + dmg_1 * qc_lin_1.y, _S470 * intact_normal_1 + dmg_1 * qc_lin_1.z);
    var force_ang_3 : vec3<f32> = qe_ang_1 * vec3<f32>(_S470) + qc_ang_1 * vec3<f32>(dmg_1);
    var stored_9 : f32 = _S470 * (psi_ts_1 + (1.0f - st_7.crush_1) * psi_c_1) + dmg_1 * psi_contact_1;
    if(has_rebar_5)
    {
        _S451 = (st_7.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S451 = false;
    }
    var stored_10 : f32;
    var force_lin_5 : vec3<f32>;
    if(_S451)
    {
        var k_axial_1 : f32 = (*b_41).rebar0_0.x;
        var k_dowel_1 : f32 = (*b_41).rebar0_0.y;
        var yield_force_1 : f32 = (*b_41).rebar0_0.z;
        var dowel_capacity_1 : f32 = (*b_41).rebar0_0.w;
        var nr_1 : vec2<f32> = return_map_0(k_axial_1, _S449, st_7.rebar_plastic_0, yield_force_1);
        var v1_1 : vec2<f32> = return_map_0(k_dowel_1, _S446, st_7.rebar_slip0_0, dowel_capacity_1);
        var v2_1 : vec2<f32> = return_map_0(k_dowel_1, _S447, st_7.rebar_slip1_0, dowel_capacity_1);
        var _S471 : f32 = nr_1.y;
        var _S472 : f32 = v1_1.y;
        var _S473 : f32 = v2_1.y;
        var work_1 : f32 = yield_force_1 * abs(_S471) + dowel_capacity_1 * (abs(_S472) + abs(_S473));
        st_7.rebar_plastic_0 = st_7.rebar_plastic_0 + _S471;
        st_7.rebar_slip0_0 = st_7.rebar_slip0_0 + _S472;
        st_7.rebar_slip1_0 = st_7.rebar_slip1_0 + _S473;
        st_7.rebar_work_0 = st_7.rebar_work_0 + work_1;
        var dissipated_15 : f32 = dissipated_14 + work_1;
        var _S474 : f32 = nr_1.x;
        var _S475 : f32 = v1_1.x;
        var _S476 : f32 = v2_1.x;
        var elastic_1 : f32 = 0.5f * (fdiv_0(sq_0(_S474), k_axial_1) + fdiv_0(sq_0(_S475) + sq_0(_S476), k_dowel_1));
        if(fracture_2)
        {
            _S451 = (st_7.rebar_work_0) >= ((*b_41).rebar1_0.x);
        }
        else
        {
            _S451 = false;
        }
        if(_S451)
        {
            st_7.rebar_broken_0 = 1.0f;
            var dissipated_16 : f32 = dissipated_15 + elastic_1;
            force_lin_5 = force_lin_4;
            dissipated_11 = dissipated_16;
            stored_10 = stored_9;
        }
        else
        {
            var stored_11 : f32 = stored_9 + elastic_1;
            force_lin_5 = force_lin_4 + vec3<f32>(_S475, _S476, _S474);
            dissipated_11 = dissipated_15;
            stored_10 = stored_11;
        }
    }
    else
    {
        force_lin_5 = force_lin_4;
        dissipated_11 = dissipated_14;
        stored_10 = stored_9;
    }
    if(fracture_2)
    {
        _S451 = _S440;
    }
    else
    {
        _S451 = false;
    }
    if(_S451)
    {
        _S451 = ((flags_2 & (u32(64)))) != u32(0);
    }
    else
    {
        _S451 = false;
    }
    if(_S451)
    {
        var _S477 : Measures_0 = stress_measures_1(&((*b_41)), force_lin_5, force_ang_3);
        var _S478 : vec4<f32> = failure_indices_1(&((*mat_15)), &((*b_41)), _S477, weibull_1);
        var _S479 : f32 = life_rate_1(&((*mat_15)), max(max(_S478.x, _S478.y), _S478.z));
        st_7.life_0 = max(st_7.life_0 - _S479 * dt_8, 0.0f);
    }
    st_7.dissipated_0 = st_7.dissipated_0 + dissipated_11;
    var resp_1 : JointResponse_0;
    resp_1.force_lin_1 = force_lin_5;
    resp_1.force_ang_1 = force_ang_3;
    resp_1.state_1 = st_7;
    resp_1.dissipated_4 = dissipated_11;
    resp_1.overshoot_0 = overshoot_3;
    resp_1.stored_5 = stored_10;
    if(_S437)
    {
        _S451 = !connected_3(st_7, has_rebar_5);
    }
    else
    {
        _S451 = false;
    }
    resp_1.disconnected_0 = _S451;
    resp_1.fatigue_before_0 = _S442;
    resp_1.measures_0 = _S438;
    return resp_1;
}

fn joint_evaluate_2( mat_16 : ptr<function, JointMaterial_std140_0>,  b_42 : ptr<function, JointBond_std430_0>,  state_4 : JointState_0,  d_lin_6 : vec3<f32>,  d_ang_6 : vec3<f32>,  dt_9 : f32,  fracture_3 : bool) -> JointResponse_0
{
    var kn_7 : f32 = (*b_42).stiff0_0.x;
    var ks_6 : f32 = (*b_42).stiff0_0.y;
    var kb1_2 : f32 = (*b_42).stiff0_0.z;
    var kb2_2 : f32 = (*b_42).stiff0_0.w;
    var _S480 : vec4<f32> = (*b_42).stiff1_0;
    var kt_6 : f32 = (*b_42).stiff1_0.x;
    var has_rebar_6 : bool = ((*b_42).stiff1_0.w) != 0.0f;
    var kind_5 : u32 = (*mat_16).kind_flags_0.x;
    var flags_3 : u32 = (*mat_16).kind_flags_0.y;
    var softening_2 : bool = ((flags_3 & (u32(1)))) != u32(0);
    var st_8 : JointState_0 = state_4;
    var was_connected_0 : bool = connected_3(state_4, has_rebar_6);
    var qe_lin_2 : vec3<f32> = d_lin_6 * vec3<f32>(ks_6, ks_6, kn_7);
    var qe_ang_2 : vec3<f32> = d_ang_6 * vec3<f32>(kb1_2, kb2_2, kt_6);
    var _S481 : Measures_0 = stress_measures_1(&((*b_42)), qe_lin_2, qe_ang_2);
    var _S482 : f32 = max(max(_S481.tension_0, _S481.shear_0), _S481.compression_0);
    var _S483 : bool = dt_9 > 0.0f;
    var dif_3 : f32;
    if(_S483)
    {
        var raw_2 : f32 = fdiv_0(max(fdiv_0(_S482 - st_8.governing_stress_0, dt_9), 0.0f), (*mat_16).misc_0.w);
        var tau_4 : f32 = _S480.z;
        if(((flags_3 & (u32(16)))) != u32(0))
        {
            dif_3 = - expm1_accurate_0(- fdiv_0(dt_9, tau_4));
        }
        else
        {
            dif_3 = min(fdiv_0(dt_9, tau_4), 1.0f);
        }
        st_8.strain_rate_0 = st_8.strain_rate_0 + (raw_2 - st_8.strain_rate_0) * dif_3;
        st_8.governing_stress_0 = _S482;
    }
    if(((flags_3 & (u32(32)))) != u32(0))
    {
        var _S484 : f32 = dif_factor_1(&((*mat_16)), st_8.strain_rate_0);
        dif_3 = _S484;
    }
    else
    {
        dif_3 = 1.0f;
    }
    var weibull_2 : f32 = (*b_42).geom1_0.w;
    var _S485 : f32 = fatigue_factor_2(&((*mat_16)), st_8.life_0);
    var multiplier_4 : f32 = weibull_2 * dif_3 * _S485;
    var _S486 : vec4<f32> = failure_indices_1(&((*mat_16)), &((*b_42)), _S481, multiplier_4);
    var _S487 : f32 = _S486.x;
    var _S488 : f32 = _S486.y;
    st_8.utilization_0 = max(max(_S487, _S488), max(_S486.z, _S486.w));
    var _S489 : f32 = d_lin_6.x;
    var _S490 : f32 = d_lin_6.y;
    var _S491 : f32 = ks_6 * (sq_0(_S489) + sq_0(_S490)) + kb1_2 * sq_0(d_ang_6.x) + kb2_2 * sq_0(d_ang_6.y) + kt_6 * sq_0(d_ang_6.z);
    var _S492 : f32 = d_lin_6.z;
    var _S493 : bool = _S492 > 0.0f;
    if(_S493)
    {
        dif_3 = kn_7 * sq_0(_S492);
    }
    else
    {
        dif_3 = 0.0f;
    }
    var psi_ts_2 : f32 = 0.5f * (_S491 + dif_3);
    var psi_c_2 : f32;
    if(_S492 < 0.0f)
    {
        psi_c_2 = 0.5f * kn_7 * sq_0(_S492);
    }
    else
    {
        psi_c_2 = 0.0f;
    }
    var plastic_8 : vec3<f32> = vec3<f32>(st_8.plastic_x_0, st_8.plastic_y_0, st_8.plastic_t_0);
    var diss_contact_2 : f32;
    var psi_contact_2 : f32;
    var intact_normal_2 : f32;
    var dissipated_17 : f32;
    var overshoot_5 : f32;
    var _S494 : bool;
    var qc_lin_2 : vec3<f32>;
    if(fracture_3)
    {
        var _S495 : bool = _S487 >= _S488;
        if(_S495)
        {
            diss_contact_2 = _S487;
        }
        else
        {
            diss_contact_2 = _S488;
        }
        var mode_ts_2 : u32;
        if(_S495)
        {
            mode_ts_2 = u32(1);
        }
        else
        {
            mode_ts_2 = u32(2);
        }
        if(diss_contact_2 > (st_8.kappa_0))
        {
            _S494 = diss_contact_2 > 1.0f;
        }
        else
        {
            _S494 = false;
        }
        if(_S494)
        {
            _S494 = psi_ts_2 > 0.0f;
        }
        else
        {
            _S494 = false;
        }
        var mode_c_2 : u32;
        if(_S494)
        {
            if(mode_ts_2 == u32(1))
            {
                psi_contact_2 = (*mat_16).energy_1.y;
            }
            else
            {
                psi_contact_2 = (*mat_16).energy_1.z;
            }
            if(softening_2)
            {
                intact_normal_2 = fdiv_0(psi_contact_2 * (*b_42).geom0_0.x * diss_contact_2 * diss_contact_2, psi_ts_2);
            }
            else
            {
                intact_normal_2 = 0.0f;
            }
            st_8.ductility_0 = intact_normal_2;
            if(softening_2)
            {
                mode_c_2 = kind_5;
            }
            else
            {
                mode_c_2 = u32(0);
            }
            var inc_4 : vec2<f32> = damage_increment_0(mode_c_2, st_8.kappa_0, diss_contact_2, intact_normal_2, st_8.damage_0, psi_ts_2);
            var _S496 : f32 = inc_4.x;
            if(_S496 > (st_8.damage_0))
            {
                var _S497 : Contact_0 = contact_part_1(&((*mat_16)), &((*b_42)), st_8.crush_1, plastic_8, d_lin_6, d_ang_6);
                var _S498 : f32 = max(_S497.energy_2 - (1.0f - st_8.crush_1) * psi_c_2, 0.0f);
                var _S499 : f32 = max(inc_4.y - _S498 * (_S496 - st_8.damage_0), 0.0f);
                var _S500 : f32 = max((psi_ts_2 - _S498) * (_S496 - st_8.damage_0) - _S499, 0.0f);
                st_8.damage_0 = _S496;
                st_8.mode_0 = mode_ts_2;
                dissipated_17 = _S499;
                overshoot_5 = _S500;
            }
            else
            {
                dissipated_17 = 0.0f;
                overshoot_5 = 0.0f;
            }
        }
        else
        {
            dissipated_17 = 0.0f;
            overshoot_5 = 0.0f;
        }
        st_8.kappa_0 = max(st_8.kappa_0, diss_contact_2);
        if((state_4.damage_0) > 0.0f)
        {
            var _S501 : Contact_0 = contact_part_1(&((*mat_16)), &((*b_42)), state_4.crush_1, vec3<f32>(state_4.plastic_x_0, state_4.plastic_y_0, state_4.plastic_t_0), d_lin_6, d_ang_6);
            qc_lin_2 = qe_ang_2 * vec3<f32>((1.0f - state_4.damage_0)) + _S501.q_ang_2 * vec3<f32>(state_4.damage_0);
        }
        else
        {
            qc_lin_2 = qe_ang_2;
        }
        var _S502 : Measures_0 = stress_measures_1(&((*b_42)), vec3<f32>(0.0f, 0.0f, min(qe_lin_2.z, 0.0f)), qc_lin_2);
        var _S503 : vec4<f32> = failure_indices_1(&((*mat_16)), &((*b_42)), _S502, multiplier_4);
        var _S504 : f32 = _S503.z;
        var _S505 : f32 = _S503.w;
        var _S506 : bool = _S504 >= _S505;
        if(_S506)
        {
            psi_contact_2 = _S504;
        }
        else
        {
            psi_contact_2 = _S505;
        }
        if(_S506)
        {
            mode_c_2 = u32(3);
        }
        else
        {
            mode_c_2 = u32(4);
        }
        if(psi_contact_2 > (st_8.kappa_c_0))
        {
            _S494 = psi_contact_2 > 1.0f;
        }
        else
        {
            _S494 = false;
        }
        if(_S494)
        {
            _S494 = psi_c_2 > 0.0f;
        }
        else
        {
            _S494 = false;
        }
        if(_S494)
        {
            if(softening_2)
            {
                intact_normal_2 = fdiv_0((*mat_16).energy_1.w * (*b_42).geom0_0.x * psi_contact_2 * psi_contact_2, psi_c_2);
            }
            else
            {
                intact_normal_2 = 0.0f;
            }
            st_8.ductility_c_0 = intact_normal_2;
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
                    mode_ts_2 = kind_5;
                }
                law_3 = mode_ts_2;
            }
            var inc_5 : vec2<f32> = damage_increment_0(law_3, st_8.kappa_c_0, psi_contact_2, intact_normal_2, st_8.crush_1, psi_c_2);
            var _S507 : f32 = inc_5.x;
            if(_S507 > (st_8.crush_1))
            {
                var _S508 : f32 = inc_5.y;
                var dissipated_18 : f32 = dissipated_17 + _S508;
                var overshoot_6 : f32 = overshoot_5 + max(psi_c_2 * (_S507 - st_8.crush_1) - _S508, 0.0f);
                st_8.crush_1 = _S507;
                st_8.mode_0 = mode_c_2;
                if(_S507 >= 1.0f)
                {
                    _S494 = (st_8.damage_0) < 1.0f;
                }
                else
                {
                    _S494 = false;
                }
                if(_S494)
                {
                    var dissipated_19 : f32 = dissipated_18 + psi_ts_2 * (1.0f - st_8.damage_0);
                    st_8.damage_0 = 1.0f;
                    dissipated_17 = dissipated_19;
                }
                else
                {
                    dissipated_17 = dissipated_18;
                }
                overshoot_5 = overshoot_6;
            }
        }
        st_8.kappa_c_0 = max(st_8.kappa_c_0, psi_contact_2);
    }
    else
    {
        dissipated_17 = 0.0f;
        overshoot_5 = 0.0f;
    }
    var dmg_2 : f32 = st_8.damage_0;
    var _S509 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_2 : vec3<f32>;
    if((st_8.damage_0) == 0.0f)
    {
        if(((flags_3 & (u32(8)))) == u32(0))
        {
            var _S510 : vec3<f32> = contact_offsets_1(&((*mat_16)), &((*b_42)), st_8.crush_1, plastic_8, d_lin_6, d_ang_6);
            st_8.plastic_x_0 = _S510.x;
            st_8.plastic_y_0 = _S510.y;
            st_8.plastic_t_0 = _S510.z;
        }
        diss_contact_2 = 0.0f;
        qc_lin_2 = _S509;
        qc_ang_2 = _S509;
        psi_contact_2 = 0.0f;
    }
    else
    {
        var _S511 : Contact_0 = contact_part_1(&((*mat_16)), &((*b_42)), st_8.crush_1, plastic_8, d_lin_6, d_ang_6);
        st_8.plastic_x_0 = _S511.plastic_1.x;
        st_8.plastic_y_0 = _S511.plastic_1.y;
        st_8.plastic_t_0 = _S511.plastic_1.z;
        diss_contact_2 = _S511.diss_2;
        qc_lin_2 = _S511.q_lin_2;
        qc_ang_2 = _S511.q_ang_2;
        psi_contact_2 = _S511.energy_2;
    }
    var dissipated_20 : f32 = dissipated_17 + dmg_2 * diss_contact_2;
    if(_S493)
    {
        intact_normal_2 = kn_7 * _S492;
    }
    else
    {
        intact_normal_2 = (1.0f - st_8.crush_1) * kn_7 * _S492;
    }
    var _S512 : f32 = 1.0f - dmg_2;
    var force_lin_6 : vec3<f32> = vec3<f32>(_S512 * qe_lin_2.x + dmg_2 * qc_lin_2.x, _S512 * qe_lin_2.y + dmg_2 * qc_lin_2.y, _S512 * intact_normal_2 + dmg_2 * qc_lin_2.z);
    var force_ang_4 : vec3<f32> = qe_ang_2 * vec3<f32>(_S512) + qc_ang_2 * vec3<f32>(dmg_2);
    var stored_12 : f32 = _S512 * (psi_ts_2 + (1.0f - st_8.crush_1) * psi_c_2) + dmg_2 * psi_contact_2;
    if(has_rebar_6)
    {
        _S494 = (st_8.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S494 = false;
    }
    var stored_13 : f32;
    var force_lin_7 : vec3<f32>;
    if(_S494)
    {
        var k_axial_2 : f32 = (*b_42).rebar0_0.x;
        var k_dowel_2 : f32 = (*b_42).rebar0_0.y;
        var yield_force_2 : f32 = (*b_42).rebar0_0.z;
        var dowel_capacity_2 : f32 = (*b_42).rebar0_0.w;
        var nr_2 : vec2<f32> = return_map_0(k_axial_2, _S492, st_8.rebar_plastic_0, yield_force_2);
        var v1_2 : vec2<f32> = return_map_0(k_dowel_2, _S489, st_8.rebar_slip0_0, dowel_capacity_2);
        var v2_2 : vec2<f32> = return_map_0(k_dowel_2, _S490, st_8.rebar_slip1_0, dowel_capacity_2);
        var _S513 : f32 = nr_2.y;
        var _S514 : f32 = v1_2.y;
        var _S515 : f32 = v2_2.y;
        var work_2 : f32 = yield_force_2 * abs(_S513) + dowel_capacity_2 * (abs(_S514) + abs(_S515));
        st_8.rebar_plastic_0 = st_8.rebar_plastic_0 + _S513;
        st_8.rebar_slip0_0 = st_8.rebar_slip0_0 + _S514;
        st_8.rebar_slip1_0 = st_8.rebar_slip1_0 + _S515;
        st_8.rebar_work_0 = st_8.rebar_work_0 + work_2;
        var dissipated_21 : f32 = dissipated_20 + work_2;
        var _S516 : f32 = nr_2.x;
        var _S517 : f32 = v1_2.x;
        var _S518 : f32 = v2_2.x;
        var elastic_2 : f32 = 0.5f * (fdiv_0(sq_0(_S516), k_axial_2) + fdiv_0(sq_0(_S517) + sq_0(_S518), k_dowel_2));
        if(fracture_3)
        {
            _S494 = (st_8.rebar_work_0) >= ((*b_42).rebar1_0.x);
        }
        else
        {
            _S494 = false;
        }
        if(_S494)
        {
            st_8.rebar_broken_0 = 1.0f;
            var dissipated_22 : f32 = dissipated_21 + elastic_2;
            force_lin_7 = force_lin_6;
            dissipated_17 = dissipated_22;
            stored_13 = stored_12;
        }
        else
        {
            var stored_14 : f32 = stored_12 + elastic_2;
            force_lin_7 = force_lin_6 + vec3<f32>(_S517, _S518, _S516);
            dissipated_17 = dissipated_21;
            stored_13 = stored_14;
        }
    }
    else
    {
        force_lin_7 = force_lin_6;
        dissipated_17 = dissipated_20;
        stored_13 = stored_12;
    }
    if(fracture_3)
    {
        _S494 = _S483;
    }
    else
    {
        _S494 = false;
    }
    if(_S494)
    {
        _S494 = ((flags_3 & (u32(64)))) != u32(0);
    }
    else
    {
        _S494 = false;
    }
    if(_S494)
    {
        var _S519 : Measures_0 = stress_measures_1(&((*b_42)), force_lin_7, force_ang_4);
        var _S520 : vec4<f32> = failure_indices_1(&((*mat_16)), &((*b_42)), _S519, weibull_2);
        var _S521 : f32 = life_rate_1(&((*mat_16)), max(max(_S520.x, _S520.y), _S520.z));
        st_8.life_0 = max(st_8.life_0 - _S521 * dt_9, 0.0f);
    }
    st_8.dissipated_0 = st_8.dissipated_0 + dissipated_17;
    var resp_2 : JointResponse_0;
    resp_2.force_lin_1 = force_lin_7;
    resp_2.force_ang_1 = force_ang_4;
    resp_2.state_1 = st_8;
    resp_2.dissipated_4 = dissipated_17;
    resp_2.overshoot_0 = overshoot_5;
    resp_2.stored_5 = stored_13;
    if(was_connected_0)
    {
        _S494 = !connected_3(st_8, has_rebar_6);
    }
    else
    {
        _S494 = false;
    }
    resp_2.disconnected_0 = _S494;
    resp_2.fatigue_before_0 = _S485;
    resp_2.measures_0 = _S481;
    return resp_2;
}

fn secant_factors_0( b_43 : ptr<function, JointBond_std430_0>,  st_9 : ptr<function, JointState_std430_0>,  d_lin_7 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var _S522 : f32 = (*st_9).damage_0;
    var compressed_0 : bool = (d_lin_7.z) < 0.0f;
    var contact_1 : f32;
    if(compressed_0)
    {
        contact_1 = _S522;
    }
    else
    {
        contact_1 = 0.0f;
    }
    var _S523 : f32 = 1.0f - _S522;
    var _S524 : f32 = max(_S523 + contact_1, 9.99999997475242708e-07f);
    var normal_7 : f32;
    if(compressed_0)
    {
        normal_7 = max(1.0f - (*st_9).crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_7 = max(_S523, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S524, _S524, normal_7);
    (*f_ang_0) = vec3<f32>(_S524);
    var _S525 : bool;
    if(((*b_43).stiff1_0.w) != 0.0f)
    {
        _S525 = ((*st_9).rebar_broken_0) == 0.0f;
    }
    else
    {
        _S525 = false;
    }
    if(_S525)
    {
        var _S526 : vec4<f32> = (*b_43).rebar0_0;
        var _S527 : vec4<f32> = (*b_43).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + fdiv_0((*b_43).rebar0_0.x, (*b_43).stiff0_0.x);
        var _S528 : f32 = fdiv_0(_S526.y, _S527.y);
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S528;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S528;
    }
    return;
}

fn secant_factors_1( b_44 : ptr<function, JointBond_std430_0>,  st_10 : JointState_0,  d_lin_8 : vec3<f32>,  f_lin_1 : ptr<function, vec3<f32>>,  f_ang_1 : ptr<function, vec3<f32>>)
{
    var compressed_1 : bool = (d_lin_8.z) < 0.0f;
    var contact_2 : f32;
    if(compressed_1)
    {
        contact_2 = st_10.damage_0;
    }
    else
    {
        contact_2 = 0.0f;
    }
    var _S529 : f32 = 1.0f - st_10.damage_0;
    var _S530 : f32 = max(_S529 + contact_2, 9.99999997475242708e-07f);
    var normal_8 : f32;
    if(compressed_1)
    {
        normal_8 = max(1.0f - st_10.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_8 = max(_S529, 9.99999997475242708e-07f);
    }
    (*f_lin_1) = vec3<f32>(_S530, _S530, normal_8);
    (*f_ang_1) = vec3<f32>(_S530);
    var _S531 : bool;
    if(((*b_44).stiff1_0.w) != 0.0f)
    {
        _S531 = (st_10.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S531 = false;
    }
    if(_S531)
    {
        var _S532 : vec4<f32> = (*b_44).rebar0_0;
        var _S533 : vec4<f32> = (*b_44).stiff0_0;
        (*f_lin_1)[i32(2)] = (*f_lin_1)[i32(2)] + fdiv_0((*b_44).rebar0_0.x, (*b_44).stiff0_0.x);
        var _S534 : f32 = fdiv_0(_S532.y, _S533.y);
        (*f_lin_1)[i32(0)] = (*f_lin_1)[i32(0)] + _S534;
        (*f_lin_1)[i32(1)] = (*f_lin_1)[i32(1)] + _S534;
    }
    return;
}

fn to_local_0( _S535 : u32,  _S536 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S536, bonds_0[_S535].t1_0.xyz), dot(_S536, bonds_0[_S535].t2_0.xyz), dot(_S536, bonds_0[_S535].normal_0.xyz));
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

fn to_body_0( _S537 : u32,  _S538 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S537].t1_0.xyz * vec3<f32>(_S538.x) + bonds_0[_S537].t2_0.xyz * vec3<f32>(_S538.y) + bonds_0[_S537].normal_0.xyz * vec3<f32>(_S538.z);
}

fn bond_update_0( i_10 : u32,  dt_10 : f32,  fracture_4 : bool,  abs_step_0 : u32,  wide_0 : bool) -> bool
{
    var ra_1 : vec3<f32> = bonds_0[i_10].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_10].rb_0.xyz;
    var _S539 : u32 = u32(4) * bonds_0[i_10].law_0.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S539 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S539 + u32(3)].xyz;
    var _S540 : u32 = u32(4) * bonds_0[i_10].law_0.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S540 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S540 + u32(3)].xyz;
    var _S541 : vec3<f32> = to_local_0(i_10, state_0[_S540].xyz + cross(tb_3, rb_1) - (state_0[_S539].xyz + cross(ta_3, ra_1)));
    var _S542 : vec3<f32> = to_local_0(i_10, tb_3 - ta_3);
    var _S543 : vec3<f32> = to_local_0(i_10, state_0[_S540 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S539 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S544 : vec3<f32> = to_local_0(i_10, wb_0 - wa_0);
    var _S545 : JointMaterial_std140_0 = materials_0.m_0.data_0[bonds_0[i_10].law_0.ids_0.x];
    var _S546 : JointState_std430_0 = bond_dyn_0[i_10].js_0;
    var _S547 : bool = is_damaged_0(&(_S546));
    var _S548 : f32 = _S546.life_0;
    var _S549 : JointBond_std430_0 = bonds_0[i_10].law_0;
    var _S550 : JointResponse_0 = joint_evaluate_0(&(_S545), &(_S549), &(_S546), _S541, _S542, dt_10, fracture_4);
    var _S551 : JointState_0 = JointState_0( bond_dyn_0[i_10].js_0.damage_0, bond_dyn_0[i_10].js_0.crush_1, bond_dyn_0[i_10].js_0.kappa_0, bond_dyn_0[i_10].js_0.kappa_c_0, bond_dyn_0[i_10].js_0.ductility_0, bond_dyn_0[i_10].js_0.ductility_c_0, bond_dyn_0[i_10].js_0.life_0, bond_dyn_0[i_10].js_0.plastic_x_0, bond_dyn_0[i_10].js_0.plastic_y_0, bond_dyn_0[i_10].js_0.plastic_t_0, bond_dyn_0[i_10].js_0.rebar_plastic_0, bond_dyn_0[i_10].js_0.rebar_slip0_0, bond_dyn_0[i_10].js_0.rebar_slip1_0, bond_dyn_0[i_10].js_0.rebar_work_0, bond_dyn_0[i_10].js_0.rebar_broken_0, bond_dyn_0[i_10].js_0.strain_rate_0, bond_dyn_0[i_10].js_0.governing_stress_0, bond_dyn_0[i_10].js_0.dissipated_0, bond_dyn_0[i_10].js_0.utilization_0, bond_dyn_0[i_10].js_0.mode_0 );
    var bd_0 : BondDyn_0;
    bd_0.js_0 = _S551;
    bd_0.force_lin_0 = bond_dyn_0[i_10].force_lin_0;
    bd_0.force_ang_0 = bond_dyn_0[i_10].force_ang_0;
    bd_0.sums_0 = bond_dyn_0[i_10].sums_0;
    bd_0.comps_0 = bond_dyn_0[i_10].comps_0;
    bd_0.events_0 = bond_dyn_0[i_10].events_0;
    var ra_2 : vec3<f32> = bonds_0[i_10].ra_0.xyz;
    var rb_2 : vec3<f32> = bonds_0[i_10].rb_0.xyz;
    var _S552 : JointBond_std430_0 = bonds_0[i_10].law_0;
    var f_lin_2 : vec3<f32>;
    var f_ang_2 : vec3<f32>;
    secant_factors_1(&(_S552), _S550.state_1, _S541, &(f_lin_2), &(f_ang_2));
    var qd_lin_0 : vec3<f32> = _S543 * bonds_0[i_10].c_lin_0.xyz * f_lin_2;
    var qd_ang_0 : vec3<f32> = _S544 * bonds_0[i_10].c_ang_0.xyz * f_ang_2;
    var q_lin_3 : vec3<f32> = _S550.force_lin_1 + qd_lin_0;
    var q_ang_3 : vec3<f32> = _S550.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S543) + dot(qd_ang_0, _S544)) * dt_10;
    var _S553 : vec3<f32> = to_body_0(i_10, q_lin_3);
    var _S554 : vec3<f32> = to_body_0(i_10, q_ang_3);
    var _S555 : u32 = u32(3) * i_10;
    scratch_0[_S555] = vec4<f32>(_S553, max(_S550.measures_0.tension_0, _S550.measures_0.compression_0));
    scratch_0[_S555 + u32(1)] = vec4<f32>(_S554 + cross(ra_2, _S553), 0.0f);
    scratch_0[_S555 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S554) + cross(rb_2, (vec3<f32>(0) - _S553)), 0.0f);
    var _S556 : f32 = bd_0.sums_0[i32(0)];
    var _S557 : f32 = bd_0.comps_0[i32(0)];
    comp_add1_0(&(_S556), &(_S557), _S550.dissipated_4);
    bd_0.sums_0[i32(0)] = _S556;
    bd_0.comps_0[i32(0)] = _S557;
    var _S558 : f32 = bd_0.sums_0[i32(1)];
    var _S559 : f32 = bd_0.comps_0[i32(1)];
    comp_add1_0(&(_S558), &(_S559), _S550.overshoot_0);
    bd_0.sums_0[i32(1)] = _S558;
    bd_0.comps_0[i32(1)] = _S559;
    var _S560 : f32 = bd_0.sums_0[i32(2)];
    var _S561 : f32 = bd_0.comps_0[i32(2)];
    comp_add1_0(&(_S560), &(_S561), damped_0);
    bd_0.sums_0[i32(2)] = _S560;
    bd_0.comps_0[i32(2)] = _S561;
    bd_0.force_lin_0 = vec4<f32>(q_lin_3, _S550.stored_5);
    bd_0.force_ang_0 = vec4<f32>(q_ang_3, max(bd_0.force_ang_0.w, _S550.state_1.utilization_0));
    var _S562 : bool;
    if(!_S547)
    {
        _S562 = is_damaged_1(_S550.state_1);
    }
    else
    {
        _S562 = false;
    }
    if(_S562)
    {
        _S562 = (bd_0.events_0.x) == u32(0);
    }
    else
    {
        _S562 = false;
    }
    if(_S562)
    {
        bd_0.events_0[i32(0)] = abs_step_0;
        bd_0.events_0[i32(3)] = _S550.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S552.ids_0.w, u32(32));
        }
        else
        {
            g_seen_0[u32(3)] = u32(1);
        }
    }
    if((bd_0.events_0.y) == u32(0))
    {
        _S562 = (_S550.state_1.life_0) != _S548;
    }
    else
    {
        _S562 = false;
    }
    if(_S562)
    {
        _S562 = (_S550.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S562 = false;
    }
    if(_S562)
    {
        var _S563 : f32 = fatigue_factor_0(&(_S545), _S550.state_1.life_0);
        _S562 = _S563 <= 0.99000000953674316f;
    }
    else
    {
        _S562 = false;
    }
    if(_S562)
    {
        bd_0.events_0[i32(1)] = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S552.ids_0.w, u32(64));
        }
        else
        {
            g_seen_0[u32(4)] = u32(1);
        }
    }
    if(_S550.disconnected_0)
    {
        bd_0.events_0[i32(2)] = abs_step_0;
    }
    bd_0.js_0 = _S550.state_1;
    bond_dyn_0[i_10].js_0.damage_0 = bd_0.js_0.damage_0;
    bond_dyn_0[i_10].js_0.crush_1 = bd_0.js_0.crush_1;
    bond_dyn_0[i_10].js_0.kappa_0 = bd_0.js_0.kappa_0;
    bond_dyn_0[i_10].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
    bond_dyn_0[i_10].js_0.ductility_0 = bd_0.js_0.ductility_0;
    bond_dyn_0[i_10].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
    bond_dyn_0[i_10].js_0.life_0 = bd_0.js_0.life_0;
    bond_dyn_0[i_10].js_0.plastic_x_0 = bd_0.js_0.plastic_x_0;
    bond_dyn_0[i_10].js_0.plastic_y_0 = bd_0.js_0.plastic_y_0;
    bond_dyn_0[i_10].js_0.plastic_t_0 = bd_0.js_0.plastic_t_0;
    bond_dyn_0[i_10].js_0.rebar_plastic_0 = bd_0.js_0.rebar_plastic_0;
    bond_dyn_0[i_10].js_0.rebar_slip0_0 = bd_0.js_0.rebar_slip0_0;
    bond_dyn_0[i_10].js_0.rebar_slip1_0 = bd_0.js_0.rebar_slip1_0;
    bond_dyn_0[i_10].js_0.rebar_work_0 = bd_0.js_0.rebar_work_0;
    bond_dyn_0[i_10].js_0.rebar_broken_0 = bd_0.js_0.rebar_broken_0;
    bond_dyn_0[i_10].js_0.strain_rate_0 = bd_0.js_0.strain_rate_0;
    bond_dyn_0[i_10].js_0.governing_stress_0 = bd_0.js_0.governing_stress_0;
    bond_dyn_0[i_10].js_0.dissipated_0 = bd_0.js_0.dissipated_0;
    bond_dyn_0[i_10].js_0.utilization_0 = bd_0.js_0.utilization_0;
    bond_dyn_0[i_10].js_0.mode_0 = bd_0.js_0.mode_0;
    bond_dyn_0[i_10].force_lin_0 = bd_0.force_lin_0;
    bond_dyn_0[i_10].force_ang_0 = bd_0.force_ang_0;
    bond_dyn_0[i_10].sums_0 = bd_0.sums_0;
    bond_dyn_0[i_10].comps_0 = bd_0.comps_0;
    bond_dyn_0[i_10].events_0 = bd_0.events_0;
    return _S550.disconnected_0;
}

struct Rigid_0
{
     rot_1 : Quat_0,
     rot_err_0 : vec4<f32>,
     pos_0 : vec3<f32>,
     pos_err_0 : vec3<f32>,
     vel_0 : vec3<f32>,
     vel_err_0 : vec3<f32>,
     w_5 : vec3<f32>,
     l_1 : vec3<f32>,
     l_err_0 : vec3<f32>,
     torque_0 : vec3<f32>,
     a_18 : vec3<f32>,
     alpha_0 : vec3<f32>,
};

fn rigid_of_0( isl_9 : ptr<function, Island_std430_0>) -> Rigid_0
{
    var rg_0 : Rigid_0;
    rg_0.rot_1 = quat_of_0((*isl_9).rotation_0);
    rg_0.rot_err_0 = (*isl_9).rotation_err_0;
    rg_0.pos_0 = (*isl_9).position_0.xyz;
    rg_0.pos_err_0 = (*isl_9).position_err_0.xyz;
    rg_0.vel_0 = (*isl_9).velocity_0.xyz;
    rg_0.vel_err_0 = (*isl_9).velocity_err_0.xyz;
    rg_0.w_5 = (*isl_9).angular_velocity_0.xyz;
    rg_0.l_1 = (*isl_9).momentum_0.xyz;
    rg_0.l_err_0 = (*isl_9).momentum_err_0.xyz;
    var _S564 : vec3<f32> = vec3<f32>(0.0f);
    rg_0.torque_0 = _S564;
    rg_0.a_18 = _S564;
    rg_0.alpha_0 = _S564;
    return rg_0;
}

fn rigid_of_1( isl_10 : ptr<function, Island_std430_0>) -> Rigid_0
{
    var rg_1 : Rigid_0;
    rg_1.rot_1 = quat_of_0((*isl_10).rotation_0);
    rg_1.rot_err_0 = (*isl_10).rotation_err_0;
    rg_1.pos_0 = (*isl_10).position_0.xyz;
    rg_1.pos_err_0 = (*isl_10).position_err_0.xyz;
    rg_1.vel_0 = (*isl_10).velocity_0.xyz;
    rg_1.vel_err_0 = (*isl_10).velocity_err_0.xyz;
    rg_1.w_5 = (*isl_10).angular_velocity_0.xyz;
    rg_1.l_1 = (*isl_10).momentum_0.xyz;
    rg_1.l_err_0 = (*isl_10).momentum_err_0.xyz;
    var _S565 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.torque_0 = _S565;
    rg_1.a_18 = _S565;
    rg_1.alpha_0 = _S565;
    return rg_1;
}

fn rigid_of_2( isl_11 : Island_0) -> Rigid_0
{
    var rg_2 : Rigid_0;
    rg_2.rot_1 = quat_of_0(isl_11.rotation_0);
    rg_2.rot_err_0 = isl_11.rotation_err_0;
    rg_2.pos_0 = isl_11.position_0.xyz;
    rg_2.pos_err_0 = isl_11.position_err_0.xyz;
    rg_2.vel_0 = isl_11.velocity_0.xyz;
    rg_2.vel_err_0 = isl_11.velocity_err_0.xyz;
    rg_2.w_5 = isl_11.angular_velocity_0.xyz;
    rg_2.l_1 = isl_11.momentum_0.xyz;
    rg_2.l_err_0 = isl_11.momentum_err_0.xyz;
    var _S566 : vec3<f32> = vec3<f32>(0.0f);
    rg_2.torque_0 = _S566;
    rg_2.a_18 = _S566;
    rg_2.alpha_0 = _S566;
    return rg_2;
}

fn net_load_0( c_13 : u32,  isl_12 : ptr<function, Island_std430_0>,  rg_3 : Rigid_0,  k_16 : u32,  dt_11 : f32,  contact_3 : bool,  f_10 : ptr<function, vec3<f32>>,  t_8 : ptr<function, vec3<f32>>)
{
    var fl_0 : vec3<f32>;
    var tl_0 : vec3<f32>;
    var rep_f_0 : vec3<f32>;
    var rep_m_0 : vec3<f32>;
    chunk_loads_0(c_13, c_13, rg_3.rot_1, k_16, dt_11, contact_3, 0.0f, &(fl_0), &(tl_0), &(rep_f_0), &(rep_m_0));
    var fc_3 : vec3<f32> = fl_0 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_13].center_0.w);
    var _S567 : vec3<f32> = chunks_0[c_13].center_0.xyz;
    var _S568 : vec3<f32> = (*isl_12).com_0.xyz;
    var r_11 : vec3<f32> = rotate_0(rg_3.rot_1, _S567 + state_0[u32(4) * c_13].xyz - _S568);
    (*f_10) = (*f_10) + fc_3;
    (*t_8) = (*t_8) + (cross(r_11, fc_3) + tl_0);
    if((chunks_0[c_13].load_range_0.y) > (chunks_0[c_13].load_range_0.x))
    {
        var fw_1 : vec3<f32> = rotate_0(rg_3.rot_1, rep_f_0);
        (*f_10) = (*f_10) + fw_1;
        (*t_8) = (*t_8) + (cross(rotate_0(rg_3.rot_1, _S567 - _S568), fw_1) + rotate_0(rg_3.rot_1, rep_m_0));
    }
    return;
}

fn net_load_1( c_14 : u32,  isl_13 : Island_0,  rg_4 : Rigid_0,  k_17 : u32,  dt_12 : f32,  contact_4 : bool,  f_11 : ptr<function, vec3<f32>>,  t_9 : ptr<function, vec3<f32>>)
{
    var fl_1 : vec3<f32>;
    var tl_1 : vec3<f32>;
    var rep_f_1 : vec3<f32>;
    var rep_m_1 : vec3<f32>;
    chunk_loads_0(c_14, c_14, rg_4.rot_1, k_17, dt_12, contact_4, 0.0f, &(fl_1), &(tl_1), &(rep_f_1), &(rep_m_1));
    var fc_4 : vec3<f32> = fl_1 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_14].center_0.w);
    var _S569 : vec3<f32> = chunks_0[c_14].center_0.xyz;
    var _S570 : vec3<f32> = isl_13.com_0.xyz;
    var r_12 : vec3<f32> = rotate_0(rg_4.rot_1, _S569 + state_0[u32(4) * c_14].xyz - _S570);
    (*f_11) = (*f_11) + fc_4;
    (*t_9) = (*t_9) + (cross(r_12, fc_4) + tl_1);
    if((chunks_0[c_14].load_range_0.y) > (chunks_0[c_14].load_range_0.x))
    {
        var fw_2 : vec3<f32> = rotate_0(rg_4.rot_1, rep_f_1);
        (*f_11) = (*f_11) + fw_2;
        (*t_9) = (*t_9) + (cross(rotate_0(rg_4.rot_1, _S569 - _S570), fw_2) + rotate_0(rg_4.rot_1, rep_m_1));
    }
    return;
}

fn wide_store_0( slot_1 : u32,  p_18 : u32,  a_19 : vec3<f32>,  b_45 : vec3<f32>)
{
    var _S571 : u32 = u32(8) * slot_1;
    scratch_0[params_0.wide_base_0 + _S571 + p_18] = vec4<f32>(a_19, 0.0f);
    scratch_0[params_0.wide_base_0 + _S571 + p_18 + u32(1)] = vec4<f32>(b_45, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var tid_10 : u32 = thread_2.x;
    var _S572 : u32 = group_2.x;
    var bond_group_0 : bool = _S572 < (params_0.wide_bond_groups_0);
    var wg_1 : WideGroup_0;
    if(bond_group_0)
    {
        wg_1 = wide_group_0(params_0.wide_bond_table_0, _S572);
    }
    else
    {
        wg_1 = wide_group_0(params_0.wide_chunk_table_0, _S572 - params_0.wide_bond_groups_0);
    }
    var _S573 : WideGroup_0 = wg_1;
    var _S574 : Island_std430_0 = islands_0[wg_1.island_2];
    var _S575 : bool = wide_enter_1(tid_10, wg_1.island_2);
    if(!_S575)
    {
        return;
    }
    var _S576 : u32 = wide_step_1(&(_S574));
    if(bond_group_0)
    {
        var _S577 : vec4<u32> = _S574.info_0;
        if((((_S574.info_0.x) & (u32(16)))) != u32(0))
        {
            return;
        }
        var i_11 : u32 = wg_1.begin_0 + tid_10;
        var _S578 : bool;
        if(i_11 < (wg_1.end_0))
        {
            var _S579 : bool = bond_update_0(i_11, params_0.dt_0, (params_0.fracture_0) != u32(0), _S577.w + u32(1), true);
            _S578 = _S579;
        }
        else
        {
            _S578 = false;
        }
        if(_S578)
        {
            islands_0[_S573.island_2].info_0[i32(2)] = ((_S577.z) | (u32(2)));
        }
        return;
    }
    var _S580 : u32 = _S574.info_0.x;
    if(((_S580 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S581 : vec3<f32> = vec3<f32>(0.0f);
    var f_12 : vec3<f32> = _S581;
    var t_10 : vec3<f32> = _S581;
    var c_15 : u32 = wg_1.begin_0 + tid_10;
    if(c_15 < (wg_1.end_0))
    {
        var _S582 : Rigid_0 = rigid_of_1(&(_S574));
        net_load_0(c_15, &(_S574), _S582, _S576, params_0.dt_0, ((_S580 & (u32(4)))) != u32(0), &(f_12), &(t_10));
    }
    group_sum3_1(tid_10, &(f_12), &(t_10));
    if(tid_10 == u32(0))
    {
        wide_store_0(_S572 - params_0.wide_bond_groups_0, u32(0), f_12, t_10);
    }
    return;
}

fn wide_partials_0( tid_11 : u32,  first_2 : u32,  count_5 : u32,  p_19 : u32,  a_20 : ptr<function, vec3<f32>>,  b_46 : ptr<function, vec3<f32>>)
{
    var _S583 : vec4<f32> = vec4<f32>(0.0f);
    var x_15 : vec4<f32> = _S583;
    var y_3 : vec4<f32> = _S583;
    var s_8 : u32 = tid_11;
    loop
    {
        if(s_8 < count_5)
        {
        }
        else
        {
            break;
        }
        var _S584 : u32 = u32(8) * (first_2 + s_8);
        x_15 = x_15 + scratch_0[params_0.wide_base_0 + _S584 + p_19];
        y_3 = y_3 + scratch_0[params_0.wide_base_0 + _S584 + p_19 + u32(1)];
        s_8 = s_8 + u32(256);
    }
    group_sum2_0(tid_11, &(x_15), &(y_3));
    (*a_20) = x_15.xyz;
    (*b_46) = y_3.xyz;
    return;
}

fn wide_partials_1( tid_12 : u32,  first_3 : u32,  count_6 : u32,  p_20 : u32,  a_21 : ptr<function, vec3<f32>>,  b_47 : ptr<function, vec3<f32>>)
{
    var _S585 : vec4<f32> = vec4<f32>(0.0f);
    var x_16 : vec4<f32> = _S585;
    var y_4 : vec4<f32> = _S585;
    var s_9 : u32 = tid_12;
    loop
    {
        if(s_9 < count_6)
        {
        }
        else
        {
            break;
        }
        var _S586 : u32 = u32(8) * (first_3 + s_9);
        x_16 = x_16 + scratch_0[params_0.wide_base_0 + _S586 + p_20];
        y_4 = y_4 + scratch_0[params_0.wide_base_0 + _S586 + p_20 + u32(1)];
        s_9 = s_9 + u32(256);
    }
    group_sum2_1(tid_12, &(x_16), &(y_4));
    (*a_21) = x_16.xyz;
    (*b_47) = y_4.xyz;
    return;
}

fn rows_mul_0( r0_0 : vec4<f32>,  r1_0 : vec4<f32>,  r2_0 : vec4<f32>,  v_5 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r0_0.xyz, v_5), dot(r1_0.xyz, v_5), dot(r2_0.xyz, v_5));
}

fn drift_angular_0( c_16 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_13 : vec3<f32> = chunks_0[c_16].center_0.xyz - wcom_1;
    var _S587 : u32 = u32(4) * c_16;
    var _S588 : vec3<f32> = vec3<f32>(chunks_0[c_16].center_0.w);
    var _S589 : vec4<f32> = chunks_0[c_16].inertia0_1;
    var _S590 : vec4<f32> = chunks_0[c_16].inertia1_1;
    var _S591 : vec4<f32> = chunks_0[c_16].inertia2_1;
    var _S592 : vec3<f32> = vec3<f32>(chunks_0[c_16].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_13, state_0[_S587].xyz - tr_0) * _S588 + rows_mul_0(chunks_0[c_16].inertia0_1, chunks_0[c_16].inertia1_1, chunks_0[c_16].inertia2_1, state_0[_S587 + u32(1)].xyz)) * _S592;
    (*lv_0) = (*lv_0) + (cross(r_13, state_0[_S587 + u32(2)].xyz - dv_0) * _S588 + rows_mul_0(_S589, _S590, _S591, state_0[_S587 + u32(3)].xyz)) * _S592;
    return;
}

fn drift_angular_1( c_17 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  dv_1 : vec3<f32>,  lu_1 : ptr<function, vec3<f32>>,  lv_1 : ptr<function, vec3<f32>>)
{
    var r_14 : vec3<f32> = chunks_0[c_17].center_0.xyz - wcom_2;
    var _S593 : u32 = u32(4) * c_17;
    var _S594 : vec3<f32> = vec3<f32>(chunks_0[c_17].center_0.w);
    var _S595 : vec4<f32> = chunks_0[c_17].inertia0_1;
    var _S596 : vec4<f32> = chunks_0[c_17].inertia1_1;
    var _S597 : vec4<f32> = chunks_0[c_17].inertia2_1;
    var _S598 : vec3<f32> = vec3<f32>(chunks_0[c_17].scale_0.x);
    (*lu_1) = (*lu_1) + (cross(r_14, state_0[_S593].xyz - tr_1) * _S594 + rows_mul_0(chunks_0[c_17].inertia0_1, chunks_0[c_17].inertia1_1, chunks_0[c_17].inertia2_1, state_0[_S593 + u32(1)].xyz)) * _S598;
    (*lv_1) = (*lv_1) + (cross(r_14, state_0[_S593 + u32(2)].xyz - dv_1) * _S594 + rows_mul_0(_S595, _S596, _S597, state_0[_S593 + u32(3)].xyz)) * _S598;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_13 : u32 = thread_3.x;
    var _S599 : u32 = group_3.x;
    var wg_2 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S599);
    var isl_14 : Island_std430_0 = islands_0[wg_2.island_2];
    var _S600 : bool;
    if((((islands_0[wg_2.island_2].info_0.x) & (u32(17)))) != u32(0))
    {
        _S600 = true;
    }
    else
    {
        var _S601 : bool = wide_enter_1(tid_13, wg_2.island_2);
        _S600 = !_S601;
    }
    if(_S600)
    {
        return;
    }
    var tu_0 : vec3<f32>;
    var pv_0 : vec3<f32>;
    wide_partials_1(tid_13, wg_2.first_0, isl_14.wide_groups_0, u32(2), &(tu_0), &(pv_0));
    var _S602 : vec3<f32> = vec3<f32>(isl_14.wcom_0.w);
    var tr_2 : vec3<f32> = tu_0 / _S602;
    var dv_2 : vec3<f32> = pv_0 / _S602;
    var _S603 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S603;
    var lv_2 : vec3<f32> = _S603;
    var c_18 : u32 = wg_2.begin_0 + tid_13;
    if(c_18 < (wg_2.end_0))
    {
        drift_angular_1(c_18, isl_14.wcom_0.xyz, tr_2, dv_2, &(lu_2), &(lv_2));
    }
    group_sum3_1(tid_13, &(lu_2), &(lv_2));
    if(tid_13 == u32(0))
    {
        wide_store_0(_S599, u32(4), lu_2, lv_2);
    }
    return;
}

fn inverse_rotate_0( q_10 : Quat_0,  v_6 : vec3<f32>) -> vec3<f32>
{
    var c_19 : Quat_0;
    c_19.w_0 = q_10.w_0;
    c_19.x_3 = - q_10.x_3;
    c_19.y_2 = - q_10.y_2;
    c_19.z_0 = - q_10.z_0;
    return rotate_0(c_19, v_6);
}

fn world_mul_0( q_11 : Quat_0,  r0_1 : vec4<f32>,  r1_1 : vec4<f32>,  r2_1 : vec4<f32>,  v_7 : vec3<f32>) -> vec3<f32>
{
    return rotate_0(q_11, rows_mul_0(r0_1, r1_1, r2_1, inverse_rotate_0(q_11, v_7)));
}

fn rigid_acceleration_0( isl_15 : ptr<function, Island_std430_0>,  rg_5 : ptr<function, Rigid_0>,  f_13 : vec3<f32>,  t_11 : vec3<f32>)
{
    var iw_w_0 : vec3<f32> = world_mul_0((*rg_5).rot_1, (*isl_15).inertia0_0, (*isl_15).inertia1_0, (*isl_15).inertia2_0, (*rg_5).w_5);
    (*rg_5).a_18 = f_13 / vec3<f32>((*isl_15).com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_1, (*isl_15).inv0_0, (*isl_15).inv1_0, (*isl_15).inv2_0, t_11 - cross((*rg_5).w_5, iw_w_0));
    (*rg_5).torque_0 = t_11;
    return;
}

fn rigid_acceleration_1( isl_16 : ptr<function, Island_std430_0>,  rg_6 : ptr<function, Rigid_0>,  f_14 : vec3<f32>,  t_12 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_6).rot_1, (*isl_16).inertia0_0, (*isl_16).inertia1_0, (*isl_16).inertia2_0, (*rg_6).w_5);
    (*rg_6).a_18 = f_14 / vec3<f32>((*isl_16).com_0.w);
    (*rg_6).alpha_0 = world_mul_0((*rg_6).rot_1, (*isl_16).inv0_0, (*isl_16).inv1_0, (*isl_16).inv2_0, t_12 - cross((*rg_6).w_5, iw_w_1));
    (*rg_6).torque_0 = t_12;
    return;
}

fn rigid_acceleration_2( isl_17 : Island_0,  rg_7 : ptr<function, Rigid_0>,  f_15 : vec3<f32>,  t_13 : vec3<f32>)
{
    var iw_w_2 : vec3<f32> = world_mul_0((*rg_7).rot_1, isl_17.inertia0_0, isl_17.inertia1_0, isl_17.inertia2_0, (*rg_7).w_5);
    (*rg_7).a_18 = f_15 / vec3<f32>(isl_17.com_0.w);
    (*rg_7).alpha_0 = world_mul_0((*rg_7).rot_1, isl_17.inv0_0, isl_17.inv1_0, isl_17.inv2_0, t_13 - cross((*rg_7).w_5, iw_w_2));
    (*rg_7).torque_0 = t_13;
    return;
}

fn wide_rigid_frame_0( tid_14 : u32,  isl_18 : ptr<function, Island_std430_0>,  wg_3 : WideGroup_0) -> Rigid_0
{
    var _S604 : Rigid_0 = rigid_of_0(&((*isl_18)));
    var rg_8 : Rigid_0 = _S604;
    if(((((*isl_18).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_16 : vec3<f32>;
        var t_14 : vec3<f32>;
        wide_partials_0(tid_14, wg_3.first_0, (*isl_18).wide_groups_0, u32(0), &(f_16), &(t_14));
        rigid_acceleration_0(&((*isl_18)), &(rg_8), f_16, t_14);
    }
    return rg_8;
}

fn wide_rigid_frame_1( tid_15 : u32,  isl_19 : ptr<function, Island_std430_0>,  wg_4 : WideGroup_0) -> Rigid_0
{
    var _S605 : Rigid_0 = rigid_of_1(&((*isl_19)));
    var rg_9 : Rigid_0 = _S605;
    if(((((*isl_19).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_17 : vec3<f32>;
        var t_15 : vec3<f32>;
        wide_partials_1(tid_15, wg_4.first_0, (*isl_19).wide_groups_0, u32(0), &(f_17), &(t_15));
        rigid_acceleration_1(&((*isl_19)), &(rg_9), f_17, t_15);
    }
    return rg_9;
}

fn comp_add_0( sum_4 : ptr<function, vec3<f32>>,  err_4 : ptr<function, vec3<f32>>,  x_17 : vec3<f32>)
{
    var t_16 : vec3<f32> = (*sum_4) + x_17;
    var _S606 : vec3<f32> = abs(x_17);
    (*err_4) = (*err_4) + (select(x_17, (*sum_4), (abs((*sum_4))) >= _S606) - t_16 + select((*sum_4), x_17, (abs((*sum_4))) >= _S606));
    (*sum_4) = t_16;
    return;
}

fn comp_add_1( sum_5 : ptr<function, vec3<f32>>,  err_5 : ptr<function, vec3<f32>>,  x_18 : vec3<f32>)
{
    var t_17 : vec3<f32> = (*sum_5) + x_18;
    var _S607 : vec3<f32> = abs(x_18);
    (*err_5) = (*err_5) + (select(x_18, (*sum_5), (abs((*sum_5))) >= _S607) - t_17 + select((*sum_5), x_18, (abs((*sum_5))) >= _S607));
    (*sum_5) = t_17;
    return;
}

fn turn_difference_0( omega_0 : vec3<f32>,  dt_13 : f32,  v_8 : vec3<f32>) -> vec3<f32>
{
    var _S608 : f32 = length(omega_0);
    var angle_1 : f32 = _S608 * dt_13;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return vec3<f32>(0.0f);
    }
    var a_22 : vec3<f32> = omega_0 / vec3<f32>(_S608);
    var s_10 : f32 = sin(0.5f * angle_1);
    var av_0 : vec3<f32> = cross(a_22, v_8);
    return av_0 * vec3<f32>(sin(angle_1)) + cross(a_22, av_0) * vec3<f32>((2.0f * s_10 * s_10));
}

fn turn_minus_one_0( axis_4 : vec3<f32>,  angle_2 : f32) -> vec4<f32>
{
    var s_11 : f32 = sin(0.25f * angle_2);
    return vec4<f32>(axis_4 * vec3<f32>(sin(0.5f * angle_2)), -2.0f * s_11 * s_11);
}

fn quat_vec_0( q_12 : Quat_0) -> vec4<f32>
{
    return vec4<f32>(q_12.x_3, q_12.y_2, q_12.z_0, q_12.w_0);
}

fn comp_add4_0( sum_6 : ptr<function, vec4<f32>>,  err_6 : ptr<function, vec4<f32>>,  x_19 : vec4<f32>)
{
    var t_18 : vec4<f32> = (*sum_6) + x_19;
    var _S609 : vec4<f32> = abs(x_19);
    (*err_6) = (*err_6) + (select(x_19, (*sum_6), (abs((*sum_6))) >= _S609) - t_18 + select((*sum_6), x_19, (abs((*sum_6))) >= _S609));
    (*sum_6) = t_18;
    return;
}

fn quat_accumulate_0( hi_1 : ptr<function, Quat_0>,  lo_1 : ptr<function, vec4<f32>>,  x_20 : vec4<f32>)
{
    var sum_7 : vec4<f32> = quat_vec_0((*hi_1));
    comp_add4_0(&(sum_7), &((*lo_1)), x_20);
    var t_19 : vec4<f32> = sum_7 + (*lo_1);
    (*lo_1) = (*lo_1) - (t_19 - sum_7);
    (*hi_1) = quat_of_0(t_19);
    return;
}

fn turn_left_0( hi_2 : ptr<function, Quat_0>,  lo_2 : ptr<function, vec4<f32>>,  omega_1 : vec3<f32>,  dt_14 : f32)
{
    var _S610 : f32 = length(omega_1);
    var angle_3 : f32 = _S610 * dt_14;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_15 : vec4<f32> = turn_minus_one_0(omega_1 / vec3<f32>(_S610), angle_3);
    var dq_0 : Quat_0;
    dq_0.x_3 = d_15.x;
    dq_0.y_2 = d_15.y;
    dq_0.z_0 = d_15.z;
    dq_0.w_0 = d_15.w;
    quat_accumulate_0(&((*hi_2)), &((*lo_2)), quat_vec_0(quat_mul_0(dq_0, (*hi_2))));
    return;
}

fn turn_left_1( hi_3 : ptr<function, Quat_0>,  lo_3 : ptr<function, vec4<f32>>,  omega_2 : vec3<f32>,  dt_15 : f32)
{
    var _S611 : f32 = length(omega_2);
    var angle_4 : f32 = _S611 * dt_15;
    if(angle_4 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_16 : vec4<f32> = turn_minus_one_0(omega_2 / vec3<f32>(_S611), angle_4);
    var dq_1 : Quat_0;
    dq_1.x_3 = d_16.x;
    dq_1.y_2 = d_16.y;
    dq_1.z_0 = d_16.z;
    dq_1.w_0 = d_16.w;
    quat_accumulate_0(&((*hi_3)), &((*lo_3)), quat_vec_0(quat_mul_0(dq_1, (*hi_3))));
    return;
}

fn integrate_rigid_0( isl_20 : ptr<function, Island_std430_0>,  rg_10 : ptr<function, Rigid_0>,  dt_16 : f32)
{
    var _S612 : vec3<f32> = vec3<f32>(dt_16);
    var _S613 : vec3<f32> = (*rg_10).torque_0 * _S612;
    var _S614 : vec3<f32> = (*rg_10).l_1;
    var _S615 : vec3<f32> = (*rg_10).l_err_0;
    comp_add_1(&(_S614), &(_S615), _S613);
    (*rg_10).l_1 = _S614;
    (*rg_10).l_err_0 = _S615;
    var l_2 : vec3<f32> = _S614 + _S615;
    var _S616 : vec3<f32> = (*rg_10).a_18 * _S612;
    var _S617 : vec3<f32> = (*rg_10).vel_0;
    var _S618 : vec3<f32> = (*rg_10).vel_err_0;
    comp_add_1(&(_S617), &(_S618), _S616);
    (*rg_10).vel_0 = _S617;
    (*rg_10).vel_err_0 = _S618;
    var _S619 : vec4<f32> = (*isl_20).inv0_0;
    var _S620 : vec4<f32> = (*isl_20).inv1_0;
    var _S621 : vec4<f32> = (*isl_20).inv2_0;
    var w_mid_0 : vec3<f32> = world_mul_0((*rg_10).rot_1, (*isl_20).inv0_0, (*isl_20).inv1_0, (*isl_20).inv2_0, l_2);
    var delta_0 : vec3<f32> = (_S617 + _S618) * _S612 - turn_difference_0(w_mid_0, dt_16, rotate_0((*rg_10).rot_1, (*isl_20).com_0.xyz));
    var _S622 : vec3<f32> = (*rg_10).pos_0;
    var _S623 : vec3<f32> = (*rg_10).pos_err_0;
    comp_add_1(&(_S622), &(_S623), delta_0);
    (*rg_10).pos_0 = _S622;
    (*rg_10).pos_err_0 = _S623;
    var _S624 : Quat_0 = (*rg_10).rot_1;
    var _S625 : vec4<f32> = (*rg_10).rot_err_0;
    turn_left_1(&(_S624), &(_S625), w_mid_0, dt_16);
    (*rg_10).rot_1 = _S624;
    (*rg_10).rot_err_0 = _S625;
    (*rg_10).w_5 = world_mul_0(_S624, _S619, _S620, _S621, l_2);
    return;
}

fn integrate_rigid_1( isl_21 : Island_0,  rg_11 : ptr<function, Rigid_0>,  dt_17 : f32)
{
    var _S626 : vec3<f32> = vec3<f32>(dt_17);
    var _S627 : vec3<f32> = (*rg_11).torque_0 * _S626;
    var _S628 : vec3<f32> = (*rg_11).l_1;
    var _S629 : vec3<f32> = (*rg_11).l_err_0;
    comp_add_1(&(_S628), &(_S629), _S627);
    (*rg_11).l_1 = _S628;
    (*rg_11).l_err_0 = _S629;
    var l_3 : vec3<f32> = _S628 + _S629;
    var _S630 : vec3<f32> = (*rg_11).a_18 * _S626;
    var _S631 : vec3<f32> = (*rg_11).vel_0;
    var _S632 : vec3<f32> = (*rg_11).vel_err_0;
    comp_add_1(&(_S631), &(_S632), _S630);
    (*rg_11).vel_0 = _S631;
    (*rg_11).vel_err_0 = _S632;
    var w_mid_1 : vec3<f32> = world_mul_0((*rg_11).rot_1, isl_21.inv0_0, isl_21.inv1_0, isl_21.inv2_0, l_3);
    var delta_1 : vec3<f32> = (_S631 + _S632) * _S626 - turn_difference_0(w_mid_1, dt_17, rotate_0((*rg_11).rot_1, isl_21.com_0.xyz));
    var _S633 : vec3<f32> = (*rg_11).pos_0;
    var _S634 : vec3<f32> = (*rg_11).pos_err_0;
    comp_add_1(&(_S633), &(_S634), delta_1);
    (*rg_11).pos_0 = _S633;
    (*rg_11).pos_err_0 = _S634;
    var _S635 : Quat_0 = (*rg_11).rot_1;
    var _S636 : vec4<f32> = (*rg_11).rot_err_0;
    turn_left_1(&(_S635), &(_S636), w_mid_1, dt_17);
    (*rg_11).rot_1 = _S635;
    (*rg_11).rot_err_0 = _S636;
    (*rg_11).w_5 = world_mul_0(_S635, isl_21.inv0_0, isl_21.inv1_0, isl_21.inv2_0, l_3);
    return;
}

fn integrate_rigid_2( isl_22 : Island_0,  rg_12 : ptr<function, Rigid_0>,  dt_18 : f32)
{
    var _S637 : vec3<f32> = vec3<f32>(dt_18);
    var _S638 : vec3<f32> = (*rg_12).torque_0 * _S637;
    var _S639 : vec3<f32> = (*rg_12).l_1;
    var _S640 : vec3<f32> = (*rg_12).l_err_0;
    comp_add_1(&(_S639), &(_S640), _S638);
    (*rg_12).l_1 = _S639;
    (*rg_12).l_err_0 = _S640;
    var l_4 : vec3<f32> = _S639 + _S640;
    var _S641 : vec3<f32> = (*rg_12).a_18 * _S637;
    var _S642 : vec3<f32> = (*rg_12).vel_0;
    var _S643 : vec3<f32> = (*rg_12).vel_err_0;
    comp_add_1(&(_S642), &(_S643), _S641);
    (*rg_12).vel_0 = _S642;
    (*rg_12).vel_err_0 = _S643;
    var w_mid_2 : vec3<f32> = world_mul_0((*rg_12).rot_1, isl_22.inv0_0, isl_22.inv1_0, isl_22.inv2_0, l_4);
    var delta_2 : vec3<f32> = (_S642 + _S643) * _S637 - turn_difference_0(w_mid_2, dt_18, rotate_0((*rg_12).rot_1, isl_22.com_0.xyz));
    var _S644 : vec3<f32> = (*rg_12).pos_0;
    var _S645 : vec3<f32> = (*rg_12).pos_err_0;
    comp_add_1(&(_S644), &(_S645), delta_2);
    (*rg_12).pos_0 = _S644;
    (*rg_12).pos_err_0 = _S645;
    var _S646 : Quat_0 = (*rg_12).rot_1;
    var _S647 : vec4<f32> = (*rg_12).rot_err_0;
    turn_left_1(&(_S646), &(_S647), w_mid_2, dt_18);
    (*rg_12).rot_1 = _S646;
    (*rg_12).rot_err_0 = _S647;
    (*rg_12).w_5 = world_mul_0(_S646, isl_22.inv0_0, isl_22.inv1_0, isl_22.inv2_0, l_4);
    return;
}

fn drift_apply_0( c_20 : u32,  wcom_3 : vec3<f32>,  tr_3 : vec3<f32>,  phi_0 : vec3<f32>,  dv_3 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_15 : vec3<f32> = chunks_0[c_20].center_0.xyz - wcom_3;
    var _S648 : u32 = u32(4) * c_20;
    state_0[_S648] = vec4<f32>(state_0[_S648].xyz - (tr_3 + cross(phi_0, r_15)), state_0[_S648].w);
    var _S649 : u32 = _S648 + u32(1);
    state_0[_S649] = vec4<f32>(state_0[_S649].xyz - phi_0, state_0[_S649].w);
    var _S650 : u32 = _S648 + u32(2);
    state_0[_S650] = vec4<f32>(state_0[_S650].xyz - (dv_3 + cross(dw_0, r_15)), state_0[_S650].w);
    var _S651 : u32 = _S648 + u32(3);
    state_0[_S651] = vec4<f32>(state_0[_S651].xyz - dw_0, state_0[_S651].w);
    return;
}

fn turn_right_0( hi_4 : ptr<function, Quat_0>,  lo_4 : ptr<function, vec4<f32>>,  phi_1 : vec3<f32>)
{
    var angle_5 : f32 = length(phi_1);
    if(angle_5 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_17 : vec4<f32> = turn_minus_one_0(phi_1 / vec3<f32>(angle_5), angle_5);
    var dq_2 : Quat_0;
    dq_2.x_3 = d_17.x;
    dq_2.y_2 = d_17.y;
    dq_2.z_0 = d_17.z;
    dq_2.w_0 = d_17.w;
    quat_accumulate_0(&((*hi_4)), &((*lo_4)), quat_vec_0(quat_mul_0((*hi_4), dq_2)));
    return;
}

fn drift_rigid_0( isl_23 : ptr<function, Island_std430_0>,  rg_13 : ptr<function, Rigid_0>,  tr_4 : vec3<f32>,  phi_2 : vec3<f32>,  dv_4 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = (*isl_23).wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_13).rot_1;
    var _S652 : vec3<f32> = rotate_0((*rg_13).rot_1, tr_4 - cross(phi_2, wcom_4));
    var _S653 : vec3<f32> = (*rg_13).pos_0;
    var _S654 : vec3<f32> = (*rg_13).pos_err_0;
    comp_add_1(&(_S653), &(_S654), _S652);
    (*rg_13).pos_0 = _S653;
    (*rg_13).pos_err_0 = _S654;
    var b_48 : vec3<f32> = inverse_rotate_0((*rg_13).rot_1, (*rg_13).w_5);
    var _S655 : vec4<f32> = (*isl_23).inertia0_0;
    var _S656 : vec4<f32> = (*isl_23).inertia1_0;
    var _S657 : vec4<f32> = (*isl_23).inertia2_0;
    var dl_turn_0 : vec3<f32> = rotate_0((*rg_13).rot_1, cross(phi_2, rows_mul_0((*isl_23).inertia0_0, (*isl_23).inertia1_0, (*isl_23).inertia2_0, b_48)) - rows_mul_0((*isl_23).inertia0_0, (*isl_23).inertia1_0, (*isl_23).inertia2_0, cross(phi_2, b_48)));
    var _S658 : Quat_0 = (*rg_13).rot_1;
    var _S659 : vec4<f32> = (*rg_13).rot_err_0;
    turn_right_0(&(_S658), &(_S659), phi_2);
    (*rg_13).rot_1 = _S658;
    (*rg_13).rot_err_0 = _S659;
    var _S660 : vec3<f32> = rotate_0(rot_2, dv_4 + cross(dw_1, (*isl_23).com_0.xyz - wcom_4));
    var _S661 : vec3<f32> = (*rg_13).vel_0;
    var _S662 : vec3<f32> = (*rg_13).vel_err_0;
    comp_add_1(&(_S661), &(_S662), _S660);
    (*rg_13).vel_0 = _S661;
    (*rg_13).vel_err_0 = _S662;
    var _S663 : vec3<f32> = rotate_0(rot_2, dw_1);
    (*rg_13).w_5 = (*rg_13).w_5 + _S663;
    var _S664 : vec3<f32> = dl_turn_0 + world_mul_0(_S658, _S655, _S656, _S657, _S663);
    var _S665 : vec3<f32> = (*rg_13).l_1;
    var _S666 : vec3<f32> = (*rg_13).l_err_0;
    comp_add_1(&(_S665), &(_S666), _S664);
    (*rg_13).l_1 = _S665;
    (*rg_13).l_err_0 = _S666;
    return;
}

fn drift_rigid_1( isl_24 : Island_0,  rg_14 : ptr<function, Rigid_0>,  tr_5 : vec3<f32>,  phi_3 : vec3<f32>,  dv_5 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_5 : vec3<f32> = isl_24.wcom_0.xyz;
    var rot_3 : Quat_0 = (*rg_14).rot_1;
    var _S667 : vec3<f32> = rotate_0((*rg_14).rot_1, tr_5 - cross(phi_3, wcom_5));
    var _S668 : vec3<f32> = (*rg_14).pos_0;
    var _S669 : vec3<f32> = (*rg_14).pos_err_0;
    comp_add_1(&(_S668), &(_S669), _S667);
    (*rg_14).pos_0 = _S668;
    (*rg_14).pos_err_0 = _S669;
    var b_49 : vec3<f32> = inverse_rotate_0((*rg_14).rot_1, (*rg_14).w_5);
    var dl_turn_1 : vec3<f32> = rotate_0((*rg_14).rot_1, cross(phi_3, rows_mul_0(isl_24.inertia0_0, isl_24.inertia1_0, isl_24.inertia2_0, b_49)) - rows_mul_0(isl_24.inertia0_0, isl_24.inertia1_0, isl_24.inertia2_0, cross(phi_3, b_49)));
    var _S670 : Quat_0 = (*rg_14).rot_1;
    var _S671 : vec4<f32> = (*rg_14).rot_err_0;
    turn_right_0(&(_S670), &(_S671), phi_3);
    (*rg_14).rot_1 = _S670;
    (*rg_14).rot_err_0 = _S671;
    var _S672 : vec3<f32> = rotate_0(rot_3, dv_5 + cross(dw_2, isl_24.com_0.xyz - wcom_5));
    var _S673 : vec3<f32> = (*rg_14).vel_0;
    var _S674 : vec3<f32> = (*rg_14).vel_err_0;
    comp_add_1(&(_S673), &(_S674), _S672);
    (*rg_14).vel_0 = _S673;
    (*rg_14).vel_err_0 = _S674;
    var _S675 : vec3<f32> = rotate_0(rot_3, dw_2);
    (*rg_14).w_5 = (*rg_14).w_5 + _S675;
    var _S676 : vec3<f32> = dl_turn_1 + world_mul_0(_S670, isl_24.inertia0_0, isl_24.inertia1_0, isl_24.inertia2_0, _S675);
    var _S677 : vec3<f32> = (*rg_14).l_1;
    var _S678 : vec3<f32> = (*rg_14).l_err_0;
    comp_add_1(&(_S677), &(_S678), _S676);
    (*rg_14).l_1 = _S677;
    (*rg_14).l_err_0 = _S678;
    return;
}

fn drift_rigid_2( isl_25 : Island_0,  rg_15 : ptr<function, Rigid_0>,  tr_6 : vec3<f32>,  phi_4 : vec3<f32>,  dv_6 : vec3<f32>,  dw_3 : vec3<f32>)
{
    var wcom_6 : vec3<f32> = isl_25.wcom_0.xyz;
    var rot_4 : Quat_0 = (*rg_15).rot_1;
    var _S679 : vec3<f32> = rotate_0((*rg_15).rot_1, tr_6 - cross(phi_4, wcom_6));
    var _S680 : vec3<f32> = (*rg_15).pos_0;
    var _S681 : vec3<f32> = (*rg_15).pos_err_0;
    comp_add_1(&(_S680), &(_S681), _S679);
    (*rg_15).pos_0 = _S680;
    (*rg_15).pos_err_0 = _S681;
    var b_50 : vec3<f32> = inverse_rotate_0((*rg_15).rot_1, (*rg_15).w_5);
    var dl_turn_2 : vec3<f32> = rotate_0((*rg_15).rot_1, cross(phi_4, rows_mul_0(isl_25.inertia0_0, isl_25.inertia1_0, isl_25.inertia2_0, b_50)) - rows_mul_0(isl_25.inertia0_0, isl_25.inertia1_0, isl_25.inertia2_0, cross(phi_4, b_50)));
    var _S682 : Quat_0 = (*rg_15).rot_1;
    var _S683 : vec4<f32> = (*rg_15).rot_err_0;
    turn_right_0(&(_S682), &(_S683), phi_4);
    (*rg_15).rot_1 = _S682;
    (*rg_15).rot_err_0 = _S683;
    var _S684 : vec3<f32> = rotate_0(rot_4, dv_6 + cross(dw_3, isl_25.com_0.xyz - wcom_6));
    var _S685 : vec3<f32> = (*rg_15).vel_0;
    var _S686 : vec3<f32> = (*rg_15).vel_err_0;
    comp_add_1(&(_S685), &(_S686), _S684);
    (*rg_15).vel_0 = _S685;
    (*rg_15).vel_err_0 = _S686;
    var _S687 : vec3<f32> = rotate_0(rot_4, dw_3);
    (*rg_15).w_5 = (*rg_15).w_5 + _S687;
    var _S688 : vec3<f32> = dl_turn_2 + world_mul_0(_S682, isl_25.inertia0_0, isl_25.inertia1_0, isl_25.inertia2_0, _S687);
    var _S689 : vec3<f32> = (*rg_15).l_1;
    var _S690 : vec3<f32> = (*rg_15).l_err_0;
    comp_add_1(&(_S689), &(_S690), _S688);
    (*rg_15).l_1 = _S689;
    (*rg_15).l_err_0 = _S690;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_16 : u32 = thread_4.x;
    var _S691 : u32 = group_4.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S691);
    var _S692 : Island_std430_0 = islands_0[wg_5.island_2];
    var _S693 : u32 = _S692.info_0.x;
    var _S694 : bool;
    if(((_S693 & (u32(1)))) != u32(0))
    {
        _S694 = true;
    }
    else
    {
        var _S695 : bool = wide_enter_1(tid_16, wg_5.island_2);
        _S694 = !_S695;
    }
    if(_S694)
    {
        return;
    }
    if(((_S693 & (u32(16)))) != u32(0))
    {
        if(_S691 != (wg_5.first_0))
        {
            return;
        }
        var _S696 : Rigid_0 = wide_rigid_frame_1(tid_16, &(_S692), wg_5);
        var rs_0 : Rigid_0 = _S696;
        if(tid_16 != u32(0))
        {
            _S694 = true;
        }
        else
        {
            _S694 = ((_S693 & (u32(2)))) != u32(0);
        }
        if(_S694)
        {
            return;
        }
        integrate_rigid_0(&(_S692), &(rs_0), params_0.dt_0);
        islands_0[wg_5.island_2].rotation_0 = quat_vec_0(rs_0.rot_1);
        islands_0[wg_5.island_2].rotation_err_0 = rs_0.rot_err_0;
        islands_0[wg_5.island_2].position_0 = vec4<f32>(rs_0.pos_0, 0.0f);
        islands_0[wg_5.island_2].position_err_0 = vec4<f32>(rs_0.pos_err_0, 0.0f);
        islands_0[wg_5.island_2].velocity_0 = vec4<f32>(rs_0.vel_0, 0.0f);
        islands_0[wg_5.island_2].velocity_err_0 = vec4<f32>(rs_0.vel_err_0, 0.0f);
        islands_0[wg_5.island_2].angular_velocity_0 = vec4<f32>(rs_0.w_5, 0.0f);
        islands_0[wg_5.island_2].momentum_0 = vec4<f32>(rs_0.l_1, 0.0f);
        islands_0[wg_5.island_2].momentum_err_0 = vec4<f32>(rs_0.l_err_0, 0.0f);
        return;
    }
    var tu_1 : vec3<f32>;
    var pv_1 : vec3<f32>;
    wide_partials_1(tid_16, wg_5.first_0, _S692.wide_groups_0, u32(2), &(tu_1), &(pv_1));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_1(tid_16, wg_5.first_0, _S692.wide_groups_0, u32(4), &(lu_3), &(lv_3));
    var _S697 : vec4<f32> = _S692.wcom_0;
    var _S698 : vec3<f32> = vec3<f32>(_S692.wcom_0.w);
    var tr_7 : vec3<f32> = tu_1 / _S698;
    var dv_7 : vec3<f32> = pv_1 / _S698;
    var phi_5 : vec3<f32> = rows_mul_0(_S692.winv0_0, _S692.winv1_0, _S692.winv2_0, lu_3);
    var dw_4 : vec3<f32> = rows_mul_0(_S692.winv0_0, _S692.winv1_0, _S692.winv2_0, lv_3);
    var c_21 : u32 = wg_5.begin_0 + tid_16;
    if(c_21 < (wg_5.end_0))
    {
        drift_apply_0(c_21, _S697.xyz, tr_7, phi_5, dv_7, dw_4);
    }
    if(_S691 != (wg_5.first_0))
    {
        return;
    }
    var _S699 : Rigid_0 = wide_rigid_frame_1(tid_16, &(_S692), wg_5);
    var rg_16 : Rigid_0 = _S699;
    if(tid_16 != u32(0))
    {
        return;
    }
    if(!(((_S693 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S692), &(rg_16), params_0.dt_0);
        drift_rigid_0(&(_S692), &(rg_16), tr_7, phi_5, dv_7, dw_4);
    }
    islands_0[wg_5.island_2].rotation_0 = quat_vec_0(rg_16.rot_1);
    islands_0[wg_5.island_2].rotation_err_0 = rg_16.rot_err_0;
    islands_0[wg_5.island_2].position_0 = vec4<f32>(rg_16.pos_0, 0.0f);
    islands_0[wg_5.island_2].position_err_0 = vec4<f32>(rg_16.pos_err_0, 0.0f);
    islands_0[wg_5.island_2].velocity_0 = vec4<f32>(rg_16.vel_0, 0.0f);
    islands_0[wg_5.island_2].velocity_err_0 = vec4<f32>(rg_16.vel_err_0, 0.0f);
    islands_0[wg_5.island_2].angular_velocity_0 = vec4<f32>(rg_16.w_5, 0.0f);
    islands_0[wg_5.island_2].momentum_0 = vec4<f32>(rg_16.l_1, 0.0f);
    islands_0[wg_5.island_2].momentum_err_0 = vec4<f32>(rg_16.l_err_0, 0.0f);
    return;
}

var<workgroup> g_label_0 : array<u32, i32(4096)>;

var<workgroup> g_changed_0 : u32;

fn island_connected_0( tid_17 : u32,  isl_26 : Island_0) -> bool
{
    var _S700 : u32 = isl_26.range_0.x;
    var n_10 : u32 = isl_26.range_0.y - _S700;
    if(n_10 > u32(4096))
    {
        return false;
    }
    var c_22 : u32 = tid_17;
    loop
    {
        if(c_22 < n_10)
        {
        }
        else
        {
            break;
        }
        g_label_0[c_22] = c_22;
        c_22 = c_22 + u32(256);
    }
    workgroupBarrier();
    var converged_0 : bool = false;
    var pass_0 : u32 = u32(0);
    loop
    {
        if(pass_0 <= n_10)
        {
        }
        else
        {
            break;
        }
        if(tid_17 == u32(0))
        {
            g_changed_0 = u32(0);
        }
        workgroupBarrier();
        c_22 = tid_17;
        loop
        {
            if(c_22 < n_10)
            {
            }
            else
            {
                break;
            }
            var gc_0 : u32 = _S700 + c_22;
            var _S701 : u32 = index_0[gc_0];
            var l_5 : u32 = g_label_0[c_22];
            var e_2 : u32 = _S701;
            loop
            {
                if(e_2 < index_0[gc_0 + u32(1)])
                {
                }
                else
                {
                    break;
                }
                var entry_1 : u32 = index_0[e_2];
                var bond_0 : u32 = (entry_1 >> (u32(1)));
                var _S702 : JointState_std430_0 = bond_dyn_0[bond_0].js_0;
                var _S703 : bool = connected_1(&(_S702), (bonds_0[bond_0].law_0.stiff1_0.w) != 0.0f);
                if(!_S703)
                {
                    e_2 = e_2 + u32(1);
                    continue;
                }
                var other_0 : u32;
                if(((entry_1 & (u32(1)))) == u32(0))
                {
                    other_0 = bonds_0[bond_0].law_0.ids_0.z;
                }
                else
                {
                    other_0 = bonds_0[bond_0].law_0.ids_0.y;
                }
                l_5 = min(l_5, g_label_0[other_0 - _S700]);
                e_2 = e_2 + u32(1);
            }
            var _S704 : u32 = min(l_5, g_label_0[l_5]);
            if(_S704 < (g_label_0[c_22]))
            {
                g_label_0[c_22] = _S704;
                g_changed_0 = u32(1);
            }
            c_22 = c_22 + u32(256);
        }
        workgroupBarrier();
        var converged_1 : bool = g_changed_0 == u32(0);
        workgroupBarrier();
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        var _S705 : u32 = pass_0 + u32(1);
        converged_0 = converged_1;
        pass_0 = _S705;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_17 == u32(0))
    {
        g_changed_0 = u32(0);
    }
    workgroupBarrier();
    c_22 = tid_17;
    loop
    {
        if(c_22 < n_10)
        {
        }
        else
        {
            break;
        }
        if((g_label_0[c_22]) != u32(0))
        {
            g_changed_0 = u32(1);
        }
        c_22 = c_22 + u32(256);
    }
    workgroupBarrier();
    return g_changed_0 == u32(0);
}

fn write_probe_0( slot_2 : u32,  k_18 : u32,  value_1 : f32)
{
    var at_3 : u32 = params_0.probe_base_0 * u32(4) + slot_2 * params_0.probe_stride_0 + k_18;
    var v_9 : vec4<f32> = scratch_0[at_3 / u32(4)];
    v_9[at_3 % u32(4)] = value_1;
    scratch_0[at_3 / u32(4)] = v_9;
    return;
}

fn record_probes_0( isl_27 : Island_0,  rg_17 : Rigid_0,  k_19 : u32)
{
    var at_4 : u32 = isl_27.probes_0.x;
    loop
    {
        if(at_4 < (isl_27.probes_0.y))
        {
        }
        else
        {
            break;
        }
        var info_3 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[at_4])));
        var a_23 : vec4<f32> = loads_0[at_4 + u32(1)];
        var b_51 : vec4<f32> = loads_0[at_4 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_4 + u32(3)];
        var kind_6 : u32 = info_3.x;
        var i_12 : u32 = info_3.y;
        var value_2 : f32;
        if(kind_6 == u32(0))
        {
            value_2 = dot(rg_17.pos_0 - b_51.xyz + rotate_0(rg_17.rot_1, chunks_0[i_12].center_0.xyz) + (rg_17.pos_err_0 - c4_0.xyz + rotate_0(rg_17.rot_1, state_0[u32(4) * i_12].xyz + vec3<f32>(a_23.w, b_51.w, c4_0.w))), a_23.xyz);
        }
        else
        {
            if(kind_6 == u32(1))
            {
                var _S706 : u32 = u32(4) * i_12;
                value_2 = dot(rg_17.vel_0 + rg_17.vel_err_0 + cross(rg_17.w_5, rotate_0(rg_17.rot_1, chunks_0[i_12].center_0.xyz + state_0[_S706].xyz - isl_27.com_0.xyz)) + rotate_0(rg_17.rot_1, state_0[_S706 + u32(2)].xyz), a_23.xyz);
            }
            else
            {
                if(kind_6 == u32(2))
                {
                    var _S707 : u32 = u32(3) * i_12;
                    var f_18 : vec3<f32> = scratch_0[_S707].xyz;
                    var _S708 : bool = (info_3.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S708)
                    {
                        mc_0 = scratch_0[_S707 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S707 + u32(2)].xyz;
                    }
                    var fc_5 : vec3<f32>;
                    if(_S708)
                    {
                        fc_5 = f_18;
                    }
                    else
                    {
                        fc_5 = (vec3<f32>(0) - f_18);
                    }
                    value_2 = dot(fc_5, a_23.xyz) + dot(mc_0, b_51.xyz);
                }
                else
                {
                    var _S709 : u32 = u32(4) * i_12;
                    value_2 = dot(rotate_0(rg_17.rot_1, vec3<f32>(state_0[_S709 + u32(1)].w, state_0[_S709 + u32(2)].w, state_0[_S709 + u32(3)].w)), a_23.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_19, value_2);
        at_4 = at_4 + u32(4);
    }
    return;
}

fn contact_split_at_0( at_5 : u32)
{
    var previous_0 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S710 : u32;
    if(previous_0 == u32(0))
    {
        _S710 = at_5;
    }
    else
    {
        _S710 = min(previous_0, at_5);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S710;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_end(@builtin(workgroup_id) group_5 : vec3<u32>, @builtin(local_invocation_id) thread_5 : vec3<u32>)
{
    var tid_18 : u32 = thread_5.x;
    var _S711 : u32 = group_5.x;
    var wg_6 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S711);
    if(_S711 != (wg_6.first_0))
    {
        return;
    }
    var _S712 : Island_std430_0 = islands_0[wg_6.island_2];
    var isl_28 : Island_0;
    isl_28.range_0 = _S712.range_0;
    isl_28.info_0 = _S712.info_0;
    isl_28.com_0 = _S712.com_0;
    isl_28.inertia0_0 = _S712.inertia0_0;
    isl_28.inertia1_0 = _S712.inertia1_0;
    isl_28.inertia2_0 = _S712.inertia2_0;
    isl_28.inv0_0 = _S712.inv0_0;
    isl_28.inv1_0 = _S712.inv1_0;
    isl_28.inv2_0 = _S712.inv2_0;
    isl_28.wcom_0 = _S712.wcom_0;
    isl_28.winv0_0 = _S712.winv0_0;
    isl_28.winv1_0 = _S712.winv1_0;
    isl_28.winv2_0 = _S712.winv2_0;
    isl_28.rotation_0 = _S712.rotation_0;
    isl_28.position_0 = _S712.position_0;
    isl_28.position_err_0 = _S712.position_err_0;
    isl_28.velocity_0 = _S712.velocity_0;
    isl_28.velocity_err_0 = _S712.velocity_err_0;
    isl_28.angular_velocity_0 = _S712.angular_velocity_0;
    isl_28.done_0 = _S712.done_0;
    isl_28.coverage_0 = _S712.coverage_0;
    isl_28.wide_groups_0 = _S712.wide_groups_0;
    isl_28.done_pad_0 = _S712.done_pad_0;
    isl_28.probes_0 = _S712.probes_0;
    isl_28.energy_0 = _S712.energy_0;
    isl_28.rotation_err_0 = _S712.rotation_err_0;
    isl_28.momentum_0 = _S712.momentum_0;
    isl_28.momentum_err_0 = _S712.momentum_err_0;
    var _S713 : bool = wide_enter_0(tid_18, &(_S712));
    if(!_S713)
    {
        return;
    }
    var work_3 : vec3<f32>;
    var flags_4 : vec3<f32>;
    wide_partials_1(tid_18, wg_6.first_0, isl_28.wide_groups_0, u32(6), &(work_3), &(flags_4));
    var halt_0 : bool = (((isl_28.info_0.z) & (u32(2)))) != u32(0);
    var whole_0 : bool;
    if(halt_0)
    {
        var _S714 : bool = island_connected_0(tid_18, isl_28);
        whole_0 = _S714;
    }
    else
    {
        whole_0 = false;
    }
    if(tid_18 != u32(0))
    {
        return;
    }
    var halt_1 : bool;
    if(whole_0)
    {
        isl_28.info_0[i32(2)] = ((isl_28.info_0[i32(2)]) & (u32(4294967293)));
        isl_28.coverage_0 = ((isl_28.coverage_0) | (u32(128)));
        halt_1 = false;
    }
    else
    {
        halt_1 = halt_0;
    }
    var k_20 : u32 = wide_step_2(isl_28);
    if((isl_28.probes_0.y) > (isl_28.probes_0.x))
    {
        record_probes_0(isl_28, rigid_of_2(isl_28), k_20);
    }
    if(halt_1)
    {
        whole_0 = (((isl_28.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        whole_0 = false;
    }
    if(whole_0)
    {
        contact_split_at_0(isl_28.info_0.w + u32(1));
    }
    var _S715 : f32 = work_3.x;
    var _S716 : f32 = isl_28.energy_0[i32(0)];
    var _S717 : f32 = isl_28.energy_0[i32(1)];
    comp_add1_3(&(_S716), &(_S717), _S715);
    isl_28.energy_0[i32(0)] = _S716;
    isl_28.energy_0[i32(1)] = _S717 + work_3.y;
    isl_28.done_0 = isl_28.done_0 + u32(1);
    isl_28.info_0[i32(1)] = isl_28.info_0[i32(1)] - u32(1);
    isl_28.info_0[i32(3)] = isl_28.info_0[i32(3)] + u32(1);
    if(halt_1)
    {
        isl_28.info_0[i32(2)] = ((((isl_28.info_0.z) & (u32(4294967293)))) | (u32(1)));
    }
    var _S718 : u32;
    if(halt_1)
    {
        _S718 = u32(128);
    }
    else
    {
        _S718 = u32(0);
    }
    var _S719 : u32 = (u32(256) | (_S718));
    if((isl_28.probes_0.y) > (isl_28.probes_0.x))
    {
        _S718 = u32(262144);
    }
    else
    {
        _S718 = u32(0);
    }
    var _S720 : u32 = (_S719 | (_S718));
    if((((isl_28.info_0.x) & (u32(4)))) != u32(0))
    {
        _S718 = u32(524288);
    }
    else
    {
        _S718 = u32(0);
    }
    var _S721 : u32 = (_S720 | (_S718));
    if((flags_4.x) > 0.0f)
    {
        _S718 = u32(32768);
    }
    else
    {
        _S718 = u32(0);
    }
    var _S722 : u32 = (_S721 | (_S718));
    if((flags_4.y) > 0.0f)
    {
        _S718 = u32(65536);
    }
    else
    {
        _S718 = u32(0);
    }
    var _S723 : u32 = (_S722 | (_S718));
    if((flags_4.z) > 0.0f)
    {
        _S718 = u32(131072);
    }
    else
    {
        _S718 = u32(0);
    }
    isl_28.coverage_0 = ((isl_28.coverage_0) | (((_S723 | (_S718)))));
    islands_0[wg_6.island_2].range_0 = isl_28.range_0;
    islands_0[wg_6.island_2].info_0 = isl_28.info_0;
    islands_0[wg_6.island_2].com_0 = isl_28.com_0;
    islands_0[wg_6.island_2].inertia0_0 = isl_28.inertia0_0;
    islands_0[wg_6.island_2].inertia1_0 = isl_28.inertia1_0;
    islands_0[wg_6.island_2].inertia2_0 = isl_28.inertia2_0;
    islands_0[wg_6.island_2].inv0_0 = isl_28.inv0_0;
    islands_0[wg_6.island_2].inv1_0 = isl_28.inv1_0;
    islands_0[wg_6.island_2].inv2_0 = isl_28.inv2_0;
    islands_0[wg_6.island_2].wcom_0 = isl_28.wcom_0;
    islands_0[wg_6.island_2].winv0_0 = isl_28.winv0_0;
    islands_0[wg_6.island_2].winv1_0 = isl_28.winv1_0;
    islands_0[wg_6.island_2].winv2_0 = isl_28.winv2_0;
    islands_0[wg_6.island_2].rotation_0 = isl_28.rotation_0;
    islands_0[wg_6.island_2].position_0 = isl_28.position_0;
    islands_0[wg_6.island_2].position_err_0 = isl_28.position_err_0;
    islands_0[wg_6.island_2].velocity_0 = isl_28.velocity_0;
    islands_0[wg_6.island_2].velocity_err_0 = isl_28.velocity_err_0;
    islands_0[wg_6.island_2].angular_velocity_0 = isl_28.angular_velocity_0;
    islands_0[wg_6.island_2].done_0 = isl_28.done_0;
    islands_0[wg_6.island_2].coverage_0 = isl_28.coverage_0;
    islands_0[wg_6.island_2].wide_groups_0 = isl_28.wide_groups_0;
    islands_0[wg_6.island_2].done_pad_0 = isl_28.done_pad_0;
    islands_0[wg_6.island_2].probes_0 = isl_28.probes_0;
    islands_0[wg_6.island_2].energy_0 = isl_28.energy_0;
    islands_0[wg_6.island_2].rotation_err_0 = isl_28.rotation_err_0;
    islands_0[wg_6.island_2].momentum_0 = isl_28.momentum_0;
    islands_0[wg_6.island_2].momentum_err_0 = isl_28.momentum_err_0;
    return;
}

fn sv_0( c_23 : u32,  slot_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * c_23 + slot_3;
}

fn project_load_slot_0( tid_19 : u32,  isl_29 : ptr<function, Island_std430_0>,  slot_4 : u32)
{
    var _S724 : u32;
    var _S725 : vec3<f32> = vec3<f32>(0.0f);
    var net_f_0 : vec3<f32> = _S725;
    var net_m_0 : vec3<f32> = _S725;
    var _S726 : vec4<u32> = (*isl_29).range_0;
    var _S727 : u32 = (*isl_29).range_0.x + tid_19;
    var c_24 : u32 = _S727;
    loop
    {
        var _S728 : u32 = _S726.y;
        _S724 = _S728;
        if(c_24 < _S728)
        {
        }
        else
        {
            break;
        }
        var fi_0 : vec3<f32> = scratch_0[sv_0(c_24, slot_4)].xyz;
        net_f_0 = net_f_0 + fi_0;
        net_m_0 = net_m_0 + (cross(chunks_0[c_24].center_0.xyz - (*isl_29).com_0.xyz, fi_0) + scratch_0[sv_0(c_24, slot_4 + u32(1))].xyz);
        c_24 = c_24 + u32(256);
    }
    group_sum3_1(tid_19, &(net_f_0), &(net_m_0));
    var _S729 : vec4<f32> = (*isl_29).com_0;
    var _S730 : vec3<f32> = net_f_0 / vec3<f32>((*isl_29).com_0.w);
    var _S731 : vec3<f32> = rows_mul_0((*isl_29).inv0_0, (*isl_29).inv1_0, (*isl_29).inv2_0, net_m_0);
    c_24 = _S727;
    loop
    {
        if(c_24 < _S724)
        {
        }
        else
        {
            break;
        }
        var _S732 : u32 = sv_0(c_24, slot_4);
        scratch_0[_S732] = vec4<f32>(scratch_0[_S732].xyz - (_S730 + cross(_S731, chunks_0[c_24].center_0.xyz - _S729.xyz)) * vec3<f32>(chunks_0[c_24].center_0.w), 0.0f);
        var _S733 : u32 = sv_0(c_24, slot_4 + u32(1));
        scratch_0[_S733] = vec4<f32>(scratch_0[_S733].xyz - rows_mul_0(chunks_0[c_24].inertia0_1, chunks_0[c_24].inertia1_1, chunks_0[c_24].inertia2_1, _S731), 0.0f);
        c_24 = c_24 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn island_dot_0( tid_20 : u32,  c0_0 : u32,  c1_0 : u32,  sa_0 : u32,  sb_0 : u32) -> f32
{
    var _S734 : vec4<f32> = vec4<f32>(0.0f);
    var acc_0 : vec4<f32> = _S734;
    var unused_2 : vec4<f32> = _S734;
    var c_25 : u32 = c0_0 + tid_20;
    loop
    {
        if(c_25 < c1_0)
        {
        }
        else
        {
            break;
        }
        acc_0[i32(0)] = acc_0[i32(0)] + (dot(scratch_0[sv_0(c_25, sa_0)].xyz, scratch_0[sv_0(c_25, sb_0)].xyz) + dot(scratch_0[sv_0(c_25, sa_0 + u32(1))].xyz, scratch_0[sv_0(c_25, sb_0 + u32(1))].xyz));
        c_25 = c_25 + u32(256);
    }
    group_sum2_2(tid_20, &(acc_0), &(unused_2));
    return acc_0.x;
}

fn static_kinematics_0( _S735 : u32,  _S736 : ptr<function, vec3<f32>>,  _S737 : ptr<function, vec3<f32>>)
{
    var ca_1 : u32 = bonds_0[_S735].law_0.ids_0.y;
    var cb_5 : u32 = bonds_0[_S735].law_0.ids_0.z;
    var _S738 : u32 = u32(4) * cb_5;
    var _S739 : u32 = u32(4) * ca_1;
    var _S740 : u32 = _S738 + u32(1);
    var _S741 : u32 = _S739 + u32(1);
    var _S742 : u32 = sv_0(cb_5, u32(22));
    var _S743 : u32 = sv_0(ca_1, u32(22));
    var dth_0 : vec3<f32> = state_0[_S740].xyz - state_0[_S741].xyz + (scratch_0[_S742].xyz - scratch_0[_S743].xyz);
    (*_S736) = to_local_0(_S735, state_0[_S738].xyz - state_0[_S739].xyz + (scratch_0[sv_0(cb_5, u32(21))].xyz - scratch_0[sv_0(ca_1, u32(21))].xyz) + (cross(state_0[_S740].xyz + scratch_0[_S742].xyz, bonds_0[_S735].rb_0.xyz) - cross(state_0[_S741].xyz + scratch_0[_S743].xyz, bonds_0[_S735].ra_0.xyz)));
    (*_S737) = to_local_0(_S735, dth_0);
    return;
}

fn static_response_0( i_13 : u32) -> JointResponse_0
{
    var d_lin_9 : vec3<f32>;
    var d_ang_7 : vec3<f32>;
    static_kinematics_0(i_13, &(d_lin_9), &(d_ang_7));
    var _S744 : JointBond_std430_0 = bonds_0[i_13].law_0;
    var _S745 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S744.ids_0.x];
    var _S746 : JointState_std430_0 = bond_dyn_0[i_13].js_0;
    var _S747 : JointResponse_0 = joint_evaluate_1(&(_S745), &(_S744), &(_S746), d_lin_9, d_ang_7, 0.0f, false);
    return _S747;
}

fn gather_loads_0( c_26 : u32,  fi_1 : ptr<function, vec3<f32>>,  mi_0 : ptr<function, vec3<f32>>)
{
    var _S748 : vec3<f32> = vec3<f32>(0.0f);
    (*fi_1) = _S748;
    (*mi_0) = _S748;
    var e_3 : u32 = index_0[c_26];
    loop
    {
        if(e_3 < index_0[c_26 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_2 : u32 = index_0[e_3];
        var bond_1 : u32 = (entry_2 >> (u32(1)));
        if(((entry_2 & (u32(1)))) == u32(0))
        {
            var _S749 : u32 = u32(3) * bond_1;
            (*fi_1) = (*fi_1) + scratch_0[_S749].xyz;
            (*mi_0) = (*mi_0) + scratch_0[_S749 + u32(1)].xyz;
        }
        else
        {
            var _S750 : u32 = u32(3) * bond_1;
            (*fi_1) = (*fi_1) - scratch_0[_S750].xyz;
            (*mi_0) = (*mi_0) + scratch_0[_S750 + u32(2)].xyz;
        }
        e_3 = e_3 + u32(1);
    }
    return;
}

fn bond_load_magnitude2_0( c_27 : u32) -> f32
{
    var e_4 : u32 = index_0[c_27];
    var m_6 : f32 = 0.0f;
    loop
    {
        if(e_4 < index_0[c_27 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_3 : u32 = index_0[e_4];
        var _S751 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var f_19 : vec3<f32> = scratch_0[_S751].xyz;
        var t_20 : vec3<f32>;
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            t_20 = scratch_0[_S751 + u32(1)].xyz;
        }
        else
        {
            t_20 = scratch_0[_S751 + u32(2)].xyz;
        }
        var m_7 : f32 = m_6 + (dot(f_19, f_19) + dot(t_20, t_20));
        e_4 = e_4 + u32(1);
        m_6 = m_7;
    }
    return m_6;
}

fn fixed_mask_0( c_28 : u32) -> u32
{
    var support_0 : u32 = chunks_0[c_28].info_1.x;
    var _S752 : u32;
    if(support_0 == u32(1))
    {
        _S752 = u32(63);
    }
    else
    {
        if(support_0 == u32(2))
        {
            _S752 = u32(7);
        }
        else
        {
            _S752 = u32(0);
        }
    }
    return _S752;
}

fn hold_0( mask_0 : u32,  lin_0 : ptr<function, vec4<f32>>,  ang_0 : ptr<function, vec4<f32>>,  keep_lin_0 : vec4<f32>,  keep_ang_0 : vec4<f32>)
{
    var d_18 : u32 = u32(0);
    loop
    {
        if(d_18 < u32(3))
        {
        }
        else
        {
            break;
        }
        if(((mask_0 & (((u32(1) << (d_18)))))) != u32(0))
        {
            (*lin_0)[d_18] = keep_lin_0[d_18];
        }
        if(((mask_0 & (((u32(1) << ((d_18 + u32(3)))))))) != u32(0))
        {
            (*ang_0)[d_18] = keep_ang_0[d_18];
        }
        d_18 = d_18 + u32(1);
    }
    return;
}

fn statics_bond_slot_0( i_14 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * i_14;
}

fn store_inverse_0( c_29 : u32,  a_24 : array<f32, i32(36)>)
{
    var j_11 : u32;
    var sum_8 : f32;
    var l_6 : array<f32, i32(36)>;
    var k_21 : u32 = u32(0);
    loop
    {
        if(k_21 < u32(36))
        {
        }
        else
        {
            break;
        }
        l_6[k_21] = 0.0f;
        k_21 = k_21 + u32(1);
    }
    var spd_0 : bool = true;
    var i_15 : u32 = u32(0);
    loop
    {
        var _S753 : bool;
        if(i_15 < u32(6))
        {
            _S753 = spd_0;
        }
        else
        {
            _S753 = false;
        }
        if(_S753)
        {
        }
        else
        {
            break;
        }
        j_11 = u32(0);
        loop
        {
            if(j_11 <= i_15)
            {
            }
            else
            {
                break;
            }
            var _S754 : u32 = i_15 * u32(6);
            var _S755 : u32 = _S754 + j_11;
            k_21 = u32(0);
            sum_8 = a_24[_S755];
            loop
            {
                if(k_21 < j_11)
                {
                }
                else
                {
                    break;
                }
                var sum_9 : f32 = sum_8 - l_6[_S754 + k_21] * l_6[j_11 * u32(6) + k_21];
                k_21 = k_21 + u32(1);
                sum_8 = sum_9;
            }
            if(i_15 == j_11)
            {
                if(sum_8 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_6[_S754 + i_15] = sqrt(sum_8);
            }
            else
            {
                l_6[_S755] = sum_8 / l_6[j_11 * u32(6) + j_11];
            }
            j_11 = j_11 + u32(1);
        }
        i_15 = i_15 + u32(1);
    }
    var inv_0 : array<f32, i32(36)>;
    if(!spd_0)
    {
        k_21 = u32(0);
        loop
        {
            if(k_21 < u32(36))
            {
            }
            else
            {
                break;
            }
            inv_0[k_21] = 0.0f;
            k_21 = k_21 + u32(1);
        }
        k_21 = u32(0);
        loop
        {
            if(k_21 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S756 : u32 = k_21 * u32(6) + k_21;
            if((a_24[_S756]) > 0.0f)
            {
                sum_8 = 1.0f / a_24[_S756];
            }
            else
            {
                sum_8 = 0.0f;
            }
            inv_0[_S756] = sum_8;
            k_21 = k_21 + u32(1);
        }
    }
    else
    {
        j_11 = u32(0);
        loop
        {
            if(j_11 < u32(6))
            {
            }
            else
            {
                break;
            }
            var y_5 : array<f32, i32(6)>;
            y_5[i32(0)] = 0.0f;
            y_5[i32(1)] = 0.0f;
            y_5[i32(2)] = 0.0f;
            y_5[i32(3)] = 0.0f;
            y_5[i32(4)] = 0.0f;
            y_5[i32(5)] = 0.0f;
            i_15 = u32(0);
            loop
            {
                if(i_15 < u32(6))
                {
                }
                else
                {
                    break;
                }
                if(i_15 == j_11)
                {
                    sum_8 = 1.0f;
                }
                else
                {
                    sum_8 = 0.0f;
                }
                k_21 = u32(0);
                var s_12 : f32 = sum_8;
                loop
                {
                    if(k_21 < i_15)
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_13 : f32 = s_12 - l_6[i_15 * u32(6) + k_21] * y_5[k_21];
                    k_21 = k_21 + u32(1);
                    s_12 = s_13;
                }
                y_5[i_15] = s_12 / l_6[i_15 * u32(6) + i_15];
                i_15 = i_15 + u32(1);
            }
            var x_21 : array<f32, i32(6)>;
            x_21[i32(0)] = 0.0f;
            x_21[i32(1)] = 0.0f;
            x_21[i32(2)] = 0.0f;
            x_21[i32(3)] = 0.0f;
            x_21[i32(4)] = 0.0f;
            x_21[i32(5)] = 0.0f;
            var ii_1 : u32 = u32(0);
            loop
            {
                if(ii_1 < u32(6))
                {
                }
                else
                {
                    break;
                }
                var i_16 : u32 = u32(5) - ii_1;
                k_21 = i_16 + u32(1);
                sum_8 = y_5[i_16];
                loop
                {
                    if(k_21 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_14 : f32 = sum_8 - l_6[k_21 * u32(6) + i_16] * x_21[k_21];
                    k_21 = k_21 + u32(1);
                    sum_8 = s_14;
                }
                x_21[i_16] = sum_8 / l_6[i_16 * u32(6) + i_16];
                ii_1 = ii_1 + u32(1);
            }
            var i_17 : u32 = u32(0);
            loop
            {
                if(i_17 < u32(6))
                {
                }
                else
                {
                    break;
                }
                inv_0[i_17 * u32(6) + j_11] = x_21[i_17];
                i_17 = i_17 + u32(1);
            }
            j_11 = j_11 + u32(1);
        }
    }
    j_11 = u32(0);
    loop
    {
        if(j_11 < u32(9))
        {
        }
        else
        {
            break;
        }
        var _S757 : u32 = u32(4) * j_11;
        scratch_0[sv_0(c_29, u32(12) + j_11)] = vec4<f32>(inv_0[_S757], inv_0[_S757 + u32(1)], inv_0[_S757 + u32(2)], inv_0[_S757 + u32(3)]);
        j_11 = j_11 + u32(1);
    }
    return;
}

fn assemble_block_0( c_30 : u32)
{
    var p_21 : u32;
    var r_16 : u32;
    var a_25 : array<f32, i32(36)>;
    var k_22 : u32 = u32(0);
    loop
    {
        if(k_22 < u32(36))
        {
        }
        else
        {
            break;
        }
        a_25[k_22] = 0.0f;
        k_22 = k_22 + u32(1);
    }
    var e_5 : u32 = index_0[c_30];
    loop
    {
        if(e_5 < index_0[c_30 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_4 : u32 = index_0[e_5];
        var i_18 : u32 = (entry_4 >> (u32(1)));
        var _S758 : bool = ((entry_4 & (u32(1)))) != u32(0);
        var _S759 : u32 = statics_bond_slot_0(i_18);
        var _S760 : vec4<f32> = scratch_0[_S759];
        var _S761 : vec4<f32> = scratch_0[_S759 + u32(1)];
        p_21 = u32(0);
        loop
        {
            if(p_21 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S762 : u32 = p_21 % u32(3);
            var t_21 : vec3<f32>;
            if(_S762 == u32(0))
            {
                t_21 = bonds_0[i_18].t1_0.xyz;
            }
            else
            {
                if(_S762 == u32(1))
                {
                    t_21 = bonds_0[i_18].t2_0.xyz;
                }
                else
                {
                    t_21 = bonds_0[i_18].normal_0.xyz;
                }
            }
            var _S763 : bool = p_21 < u32(3);
            var row_u_0 : vec3<f32>;
            var row_t_0 : vec3<f32>;
            if(_S763)
            {
                if(_S758)
                {
                    row_u_0 = t_21;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_21);
                }
                if(_S758)
                {
                    row_t_0 = cross(bonds_0[i_18].rb_0.xyz, t_21);
                }
                else
                {
                    row_t_0 = (vec3<f32>(0) - cross(bonds_0[i_18].ra_0.xyz, t_21));
                }
            }
            else
            {
                var _S764 : vec3<f32> = vec3<f32>(0.0f);
                if(_S758)
                {
                    row_u_0 = t_21;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_21);
                }
                var _S765 : vec3<f32> = row_u_0;
                row_u_0 = _S764;
                row_t_0 = _S765;
            }
            var kp_0 : f32;
            if(_S763)
            {
                kp_0 = _S760[p_21];
            }
            else
            {
                kp_0 = _S761[p_21 - u32(3)];
            }
            if(kp_0 == 0.0f)
            {
                p_21 = p_21 + u32(1);
                continue;
            }
            var _S766 : array<f32, i32(6)> = array<f32, i32(6)>( row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z );
            r_16 = u32(0);
            loop
            {
                if(r_16 < u32(6))
                {
                }
                else
                {
                    break;
                }
                var q_13 : u32 = u32(0);
                loop
                {
                    if(q_13 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    a_25[r_16 * u32(6) + q_13] = a_25[r_16 * u32(6) + q_13] + kp_0 * _S766[r_16] * _S766[q_13];
                    q_13 = q_13 + u32(1);
                }
                r_16 = r_16 + u32(1);
            }
            p_21 = p_21 + u32(1);
        }
        e_5 = e_5 + u32(1);
    }
    var _S767 : u32 = fixed_mask_0(c_30);
    p_21 = u32(0);
    loop
    {
        if(p_21 < u32(6))
        {
        }
        else
        {
            break;
        }
        if(((_S767 & (((u32(1) << (p_21)))))) != u32(0))
        {
            r_16 = u32(0);
            loop
            {
                if(r_16 < u32(6))
                {
                }
                else
                {
                    break;
                }
                a_25[p_21 * u32(6) + r_16] = 0.0f;
                a_25[r_16 * u32(6) + p_21] = 0.0f;
                r_16 = r_16 + u32(1);
            }
            a_25[p_21 * u32(6) + p_21] = 1.0f;
        }
        p_21 = p_21 + u32(1);
    }
    p_21 = u32(0);
    loop
    {
        if(p_21 < u32(6))
        {
        }
        else
        {
            break;
        }
        if((a_25[p_21 * u32(6) + p_21]) == 0.0f)
        {
            a_25[p_21 * u32(6) + p_21] = 1.0f;
        }
        p_21 = p_21 + u32(1);
    }
    store_inverse_0(c_30, a_25);
    return;
}

fn block_get_0( c_31 : u32,  i_19 : u32,  j_12 : u32) -> f32
{
    var k_23 : u32 = i_19 * u32(6) + j_12;
    return scratch_0[sv_0(c_31, u32(12) + k_23 / u32(4))][k_23 % u32(4)];
}

fn precondition_0( c_32 : u32)
{
    var _S768 : array<f32, i32(6)> = array<f32, i32(6)>( scratch_0[sv_0(c_32, u32(4))].x, scratch_0[sv_0(c_32, u32(4))].y, scratch_0[sv_0(c_32, u32(4))].z, scratch_0[sv_0(c_32, u32(5))].x, scratch_0[sv_0(c_32, u32(5))].y, scratch_0[sv_0(c_32, u32(5))].z );
    var z_1 : array<f32, i32(6)>;
    var i_20 : u32 = u32(0);
    loop
    {
        if(i_20 < u32(6))
        {
        }
        else
        {
            break;
        }
        var j_13 : u32 = u32(0);
        var s_15 : f32 = 0.0f;
        loop
        {
            if(j_13 < u32(6))
            {
            }
            else
            {
                break;
            }
            var s_16 : f32 = s_15 + block_get_0(c_32, i_20, j_13) * _S768[j_13];
            j_13 = j_13 + u32(1);
            s_15 = s_16;
        }
        z_1[i_20] = s_15;
        i_20 = i_20 + u32(1);
    }
    scratch_0[sv_0(c_32, u32(6))] = vec4<f32>(z_1[i32(0)], z_1[i32(1)], z_1[i32(2)], 0.0f);
    scratch_0[sv_0(c_32, u32(7))] = vec4<f32>(z_1[i32(3)], z_1[i32(4)], z_1[i32(5)], 0.0f);
    return;
}

fn project_displacement_slot_0( tid_21 : u32,  isl_30 : ptr<function, Island_std430_0>,  slot_5 : u32)
{
    var _S769 : u32;
    var _S770 : vec3<f32> = vec3<f32>(0.0f);
    var p_22 : vec3<f32> = _S770;
    var l_7 : vec3<f32> = _S770;
    var _S771 : vec4<u32> = (*isl_30).range_0;
    var _S772 : u32 = (*isl_30).range_0.x + tid_21;
    var c_33 : u32 = _S772;
    loop
    {
        var _S773 : u32 = _S771.y;
        _S769 = _S773;
        if(c_33 < _S773)
        {
        }
        else
        {
            break;
        }
        var u_0 : vec3<f32> = scratch_0[sv_0(c_33, slot_5)].xyz;
        var th_2 : vec3<f32> = scratch_0[sv_0(c_33, slot_5 + u32(1))].xyz;
        var r_17 : vec3<f32> = chunks_0[c_33].center_0.xyz - (*isl_30).com_0.xyz;
        var _S774 : vec3<f32> = vec3<f32>(chunks_0[c_33].center_0.w);
        p_22 = p_22 + u_0 * _S774;
        l_7 = l_7 + (cross(r_17, u_0) * _S774 + rows_mul_0(chunks_0[c_33].inertia0_1, chunks_0[c_33].inertia1_1, chunks_0[c_33].inertia2_1, th_2));
        c_33 = c_33 + u32(256);
    }
    group_sum3_1(tid_21, &(p_22), &(l_7));
    var _S775 : vec4<f32> = (*isl_30).com_0;
    var _S776 : vec3<f32> = p_22 / vec3<f32>((*isl_30).com_0.w);
    var _S777 : vec3<f32> = rows_mul_0((*isl_30).inv0_0, (*isl_30).inv1_0, (*isl_30).inv2_0, l_7);
    c_33 = _S772;
    loop
    {
        if(c_33 < _S769)
        {
        }
        else
        {
            break;
        }
        var _S778 : u32 = sv_0(c_33, slot_5);
        scratch_0[_S778] = vec4<f32>(scratch_0[_S778].xyz - _S776 - cross(_S777, chunks_0[c_33].center_0.xyz - _S775.xyz), 0.0f);
        var _S779 : u32 = sv_0(c_33, slot_5 + u32(1));
        scratch_0[_S779] = vec4<f32>(scratch_0[_S779].xyz - _S777, 0.0f);
        c_33 = c_33 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn statics_result_slot_0( island_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * params_0.statics_bonds_0 + island_3;
}

fn write_bond_loads_0( _S780 : u32,  _S781 : u32,  _S782 : vec3<f32>,  _S783 : vec3<f32>,  _S784 : f32)
{
    var _S785 : vec3<f32> = to_body_0(_S781, _S782);
    var _S786 : vec3<f32> = to_body_0(_S781, _S783);
    var _S787 : u32 = u32(3) * _S780;
    scratch_0[_S787] = vec4<f32>(_S785, _S784);
    scratch_0[_S787 + u32(1)] = vec4<f32>(_S786 + cross(bonds_0[_S781].ra_0.xyz, _S785), 0.0f);
    scratch_0[_S787 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S786) + cross(bonds_0[_S781].rb_0.xyz, (vec3<f32>(0) - _S785)), 0.0f);
    return;
}

fn static_kinematics_1( _S788 : u32,  _S789 : ptr<function, vec3<f32>>,  _S790 : ptr<function, vec3<f32>>)
{
    var ca_2 : u32 = bonds_0[_S788].law_0.ids_0.y;
    var cb_6 : u32 = bonds_0[_S788].law_0.ids_0.z;
    var _S791 : u32 = u32(4) * cb_6;
    var _S792 : u32 = u32(4) * ca_2;
    var _S793 : u32 = _S791 + u32(1);
    var _S794 : u32 = _S792 + u32(1);
    var _S795 : u32 = sv_0(cb_6, u32(22));
    var _S796 : u32 = sv_0(ca_2, u32(22));
    var dth_1 : vec3<f32> = state_0[_S793].xyz - state_0[_S794].xyz + (scratch_0[_S795].xyz - scratch_0[_S796].xyz);
    (*_S789) = to_local_0(_S788, state_0[_S791].xyz - state_0[_S792].xyz + (scratch_0[sv_0(cb_6, u32(21))].xyz - scratch_0[sv_0(ca_2, u32(21))].xyz) + (cross(state_0[_S793].xyz + scratch_0[_S795].xyz, bonds_0[_S788].rb_0.xyz) - cross(state_0[_S794].xyz + scratch_0[_S796].xyz, bonds_0[_S788].ra_0.xyz)));
    (*_S790) = to_local_0(_S788, dth_1);
    return;
}

fn bond_kinematics_0( _S797 : u32,  _S798 : vec3<f32>,  _S799 : vec3<f32>,  _S800 : vec3<f32>,  _S801 : vec3<f32>,  _S802 : ptr<function, vec3<f32>>,  _S803 : ptr<function, vec3<f32>>)
{
    (*_S802) = to_local_0(_S797, _S800 + cross(_S801, bonds_0[_S797].rb_0.xyz) - (_S798 + cross(_S799, bonds_0[_S797].ra_0.xyz)));
    (*_S803) = to_local_0(_S797, _S801 - _S799);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_statics(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var i_21 : u32;
    var converged_2 : bool;
    var c_34 : u32;
    var tid_22 : u32 = thread_6.x;
    var _S804 : u32 = group_6.x;
    var _S805 : Island_std430_0 = islands_0[_S804];
    var _S806 : vec4<u32> = _S805.info_0;
    var _S807 : u32 = _S805.info_0.z;
    if(((_S807 & (u32(8)))) == u32(0))
    {
        return;
    }
    var free_0 : bool = (((_S806.x) & (u32(1)))) == u32(0);
    var c0_1 : u32 = _S805.range_0.x;
    var c1_1 : u32 = _S805.range_0.y;
    var b0_0 : u32 = _S805.range_0.z;
    var _S808 : u32 = _S805.range_0.w;
    var _S809 : u32 = c0_1 + tid_22;
    var c_35 : u32 = _S809;
    loop
    {
        if(c_35 < c1_1)
        {
        }
        else
        {
            break;
        }
        var _S810 : vec4<f32> = vec4<f32>(0.0f);
        scratch_0[sv_0(c_35, u32(21))] = _S810;
        scratch_0[sv_0(c_35, u32(22))] = _S810;
        c_35 = c_35 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    if(free_0)
    {
        project_load_slot_0(tid_22, &(_S805), u32(0));
    }
    var _S811 : f32 = island_dot_0(tid_22, c0_1, c1_1, u32(0), u32(0));
    var _S812 : f32 = max(sqrt(_S811), 1.00000000317107685e-30f);
    var _S813 : f32 = params_0.statics_tol_0;
    var _S814 : u32 = min(params_0.statics_cg_0, u32(20) * (c1_1 - c0_1) * u32(6) + u32(200));
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
            converged_2 = false;
            break;
        }
        var _S815 : u32 = b0_0 + tid_22;
        i_21 = _S815;
        loop
        {
            if(i_21 < _S808)
            {
            }
            else
            {
                break;
            }
            var resp_3 : JointResponse_0 = static_response_0(i_21);
            write_bond_loads_0(i_21, i_21, resp_3.force_lin_1, resp_3.force_ang_1, 0.0f);
            i_21 = i_21 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S816 : vec4<f32> = vec4<f32>(0.0f);
        var magnitude_0 : vec4<f32> = _S816;
        var unused_m_0 : vec4<f32> = _S816;
        c_35 = _S809;
        loop
        {
            if(c_35 < c1_1)
            {
            }
            else
            {
                break;
            }
            var fi_2 : vec3<f32>;
            var mi_1 : vec3<f32>;
            gather_loads_0(c_35, &(fi_2), &(mi_1));
            magnitude_0[i32(0)] = magnitude_0[i32(0)] + bond_load_magnitude2_0(c_35);
            var r_lin_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_35, u32(0))].xyz + fi_2, 0.0f);
            var r_ang_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_35, u32(1))].xyz + mi_1, 0.0f);
            hold_0(fixed_mask_0(c_35), &(r_lin_0), &(r_ang_0), _S816, _S816);
            scratch_0[sv_0(c_35, u32(4))] = r_lin_0;
            scratch_0[sv_0(c_35, u32(5))] = r_ang_0;
            c_35 = c_35 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        group_sum2_1(tid_22, &(magnitude_0), &(unused_m_0));
        if(free_0)
        {
            project_load_slot_0(tid_22, &(_S805), u32(4));
        }
        var _S817 : f32 = island_dot_0(tid_22, c0_1, c1_1, u32(4), u32(4));
        var residual_1 : f32 = sqrt(_S817) / _S812;
        var _S818 : f32 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S812);
        if(residual_1 <= _S813)
        {
            converged_2 = true;
        }
        else
        {
            if(residual_1 <= _S818)
            {
                converged_2 = residual_1 > (0.5f * previous_1);
            }
            else
            {
                converged_2 = false;
            }
        }
        if(converged_2)
        {
            residual_0 = residual_1;
            converged_2 = true;
            break;
        }
        var i_22 : u32 = _S815;
        loop
        {
            if(i_22 < _S808)
            {
            }
            else
            {
                break;
            }
            var d_lin_10 : vec3<f32>;
            var d_ang_8 : vec3<f32>;
            static_kinematics_1(i_22, &(d_lin_10), &(d_ang_8));
            var _S819 : JointBond_std430_0 = bonds_0[i_22].law_0;
            var _S820 : JointState_std430_0 = bond_dyn_0[i_22].js_0;
            var f_lin_3 : vec3<f32>;
            var f_ang_3 : vec3<f32>;
            secant_factors_0(&(_S819), &(_S820), d_lin_10, &(f_lin_3), &(f_ang_3));
            var _S821 : u32 = statics_bond_slot_0(i_22);
            var _S822 : f32 = _S819.stiff0_0.y;
            scratch_0[_S821] = vec4<f32>(_S822 * f_lin_3.x, _S822 * f_lin_3.y, _S819.stiff0_0.x * f_lin_3.z, 0.0f);
            scratch_0[_S821 + u32(1)] = vec4<f32>(_S819.stiff0_0.z * f_ang_3.x, _S819.stiff0_0.w * f_ang_3.y, _S819.stiff1_0.x * f_ang_3.z, 0.0f);
            i_22 = i_22 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_36 : u32 = _S809;
        loop
        {
            if(c_36 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_36);
            scratch_0[sv_0(c_36, u32(2))] = _S816;
            scratch_0[sv_0(c_36, u32(3))] = _S816;
            c_36 = c_36 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_37 : u32 = _S809;
        loop
        {
            if(c_37 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_37);
            c_37 = c_37 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(free_0)
        {
            project_displacement_slot_0(tid_22, &(_S805), u32(6));
        }
        var c_38 : u32 = _S809;
        loop
        {
            if(c_38 < c1_1)
            {
            }
            else
            {
                break;
            }
            scratch_0[sv_0(c_38, u32(8))] = scratch_0[sv_0(c_38, u32(6))];
            scratch_0[sv_0(c_38, u32(9))] = scratch_0[sv_0(c_38, u32(7))];
            c_38 = c_38 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S823 : f32 = island_dot_0(tid_22, c0_1, c1_1, u32(4), u32(6));
        var _S824 : f32 = island_dot_0(tid_22, c0_1, c1_1, u32(4), u32(4));
        var _S825 : f32 = sqrt(_S824);
        var rz_0 : f32 = _S823;
        var k_24 : u32 = u32(0);
        var cg_total_1 : u32 = cg_total_0;
        loop
        {
            var _S826 : bool;
            if(k_24 < _S814)
            {
                _S826 = _S825 > 0.0f;
            }
            else
            {
                _S826 = false;
            }
            if(_S826)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            var i_23 : u32 = _S815;
            loop
            {
                if(i_23 < _S808)
                {
                }
                else
                {
                    break;
                }
                var ca_3 : u32 = bonds_0[i_23].law_0.ids_0.y;
                var cb_7 : u32 = bonds_0[i_23].law_0.ids_0.z;
                var d_lin_11 : vec3<f32>;
                var d_ang_9 : vec3<f32>;
                bond_kinematics_0(i_23, scratch_0[sv_0(ca_3, u32(8))].xyz, scratch_0[sv_0(ca_3, u32(9))].xyz, scratch_0[sv_0(cb_7, u32(8))].xyz, scratch_0[sv_0(cb_7, u32(9))].xyz, &(d_lin_11), &(d_ang_9));
                var _S827 : u32 = statics_bond_slot_0(i_23);
                write_bond_loads_0(i_23, i_23, d_lin_11 * scratch_0[_S827].xyz, d_ang_9 * scratch_0[_S827 + u32(1)].xyz, 0.0f);
                i_23 = i_23 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_34 = _S809;
            loop
            {
                if(c_34 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var fi_3 : vec3<f32>;
                var mi_2 : vec3<f32>;
                gather_loads_0(c_34, &(fi_3), &(mi_2));
                var ap_lin_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - fi_3), 0.0f);
                var ap_ang_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - mi_2), 0.0f);
                hold_0(fixed_mask_0(c_34), &(ap_lin_0), &(ap_ang_0), scratch_0[sv_0(c_34, u32(8))], scratch_0[sv_0(c_34, u32(9))]);
                scratch_0[sv_0(c_34, u32(10))] = ap_lin_0;
                scratch_0[sv_0(c_34, u32(11))] = ap_ang_0;
                c_34 = c_34 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var pap_0 : f32 = island_dot_0(tid_22, c0_1, c1_1, u32(8), u32(10));
            var _S828 : u32 = cg_total_1 + u32(1);
            if(pap_0 <= 0.0f)
            {
                cg_total_0 = _S828;
                break;
            }
            var _S829 : f32 = rz_0 / pap_0;
            var c_39 : u32 = _S809;
            loop
            {
                if(c_39 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S830 : u32 = sv_0(c_39, u32(2));
                var _S831 : vec3<f32> = vec3<f32>(_S829);
                scratch_0[_S830] = vec4<f32>(scratch_0[_S830].xyz + _S831 * scratch_0[sv_0(c_39, u32(8))].xyz, 0.0f);
                var _S832 : u32 = sv_0(c_39, u32(3));
                scratch_0[_S832] = vec4<f32>(scratch_0[_S832].xyz + _S831 * scratch_0[sv_0(c_39, u32(9))].xyz, 0.0f);
                var _S833 : u32 = sv_0(c_39, u32(4));
                scratch_0[_S833] = vec4<f32>(scratch_0[_S833].xyz - _S831 * scratch_0[sv_0(c_39, u32(10))].xyz, 0.0f);
                var _S834 : u32 = sv_0(c_39, u32(5));
                scratch_0[_S834] = vec4<f32>(scratch_0[_S834].xyz - _S831 * scratch_0[sv_0(c_39, u32(11))].xyz, 0.0f);
                c_39 = c_39 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S835 : f32 = island_dot_0(tid_22, c0_1, c1_1, u32(4), u32(4));
            if((sqrt(_S835)) <= (0.00009999999747379f * _S825))
            {
                cg_total_0 = _S828;
                break;
            }
            var c_40 : u32 = _S809;
            loop
            {
                if(c_40 < c1_1)
                {
                }
                else
                {
                    break;
                }
                precondition_0(c_40);
                c_40 = c_40 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            if(free_0)
            {
                project_displacement_slot_0(tid_22, &(_S805), u32(6));
            }
            var rz_new_0 : f32 = island_dot_0(tid_22, c0_1, c1_1, u32(4), u32(6));
            var _S836 : f32 = rz_new_0 / rz_0;
            var c_41 : u32 = _S809;
            loop
            {
                if(c_41 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S837 : u32 = sv_0(c_41, u32(8));
                var _S838 : vec3<f32> = vec3<f32>(_S836);
                scratch_0[_S837] = vec4<f32>(scratch_0[sv_0(c_41, u32(6))].xyz + _S838 * scratch_0[_S837].xyz, 0.0f);
                var _S839 : u32 = sv_0(c_41, u32(9));
                scratch_0[_S839] = vec4<f32>(scratch_0[sv_0(c_41, u32(7))].xyz + _S838 * scratch_0[_S839].xyz, 0.0f);
                c_41 = c_41 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S840 : u32 = k_24 + u32(1);
            rz_0 = rz_new_0;
            k_24 = _S840;
            cg_total_1 = _S828;
        }
        c_34 = _S809;
        loop
        {
            if(c_34 < c1_1)
            {
            }
            else
            {
                break;
            }
            var _S841 : u32 = u32(4) * c_34;
            var u_1 : vec3<f32> = state_0[_S841].xyz;
            var _S842 : u32 = sv_0(c_34, u32(21));
            var u_lo_0 : vec3<f32> = scratch_0[_S842].xyz;
            var _S843 : u32 = _S841 + u32(1);
            var th_3 : vec3<f32> = state_0[_S843].xyz;
            var _S844 : u32 = sv_0(c_34, u32(22));
            var th_lo_0 : vec3<f32> = scratch_0[_S844].xyz;
            comp_add_1(&(u_1), &(u_lo_0), scratch_0[sv_0(c_34, u32(2))].xyz);
            comp_add_1(&(th_3), &(th_lo_0), scratch_0[sv_0(c_34, u32(3))].xyz);
            state_0[_S841] = vec4<f32>(u_1, state_0[_S841].w);
            state_0[_S843] = vec4<f32>(th_3, state_0[_S843].w);
            scratch_0[_S842] = vec4<f32>(u_lo_0, 0.0f);
            scratch_0[_S844] = vec4<f32>(th_lo_0, 0.0f);
            c_34 = c_34 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S845 : u32 = newton_0 + u32(1);
        previous_1 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S845;
    }
    i_21 = b0_0 + tid_22;
    loop
    {
        if(i_21 < _S808)
        {
        }
        else
        {
            break;
        }
        var resp_4 : JointResponse_0 = static_response_0(i_21);
        var _S846 : JointState_0 = JointState_0( bond_dyn_0[i_21].js_0.damage_0, bond_dyn_0[i_21].js_0.crush_1, bond_dyn_0[i_21].js_0.kappa_0, bond_dyn_0[i_21].js_0.kappa_c_0, bond_dyn_0[i_21].js_0.ductility_0, bond_dyn_0[i_21].js_0.ductility_c_0, bond_dyn_0[i_21].js_0.life_0, bond_dyn_0[i_21].js_0.plastic_x_0, bond_dyn_0[i_21].js_0.plastic_y_0, bond_dyn_0[i_21].js_0.plastic_t_0, bond_dyn_0[i_21].js_0.rebar_plastic_0, bond_dyn_0[i_21].js_0.rebar_slip0_0, bond_dyn_0[i_21].js_0.rebar_slip1_0, bond_dyn_0[i_21].js_0.rebar_work_0, bond_dyn_0[i_21].js_0.rebar_broken_0, bond_dyn_0[i_21].js_0.strain_rate_0, bond_dyn_0[i_21].js_0.governing_stress_0, bond_dyn_0[i_21].js_0.dissipated_0, bond_dyn_0[i_21].js_0.utilization_0, bond_dyn_0[i_21].js_0.mode_0 );
        var bd_1 : BondDyn_0;
        bd_1.js_0 = _S846;
        bd_1.force_lin_0 = bond_dyn_0[i_21].force_lin_0;
        bd_1.force_ang_0 = bond_dyn_0[i_21].force_ang_0;
        bd_1.sums_0 = bond_dyn_0[i_21].sums_0;
        bd_1.comps_0 = bond_dyn_0[i_21].comps_0;
        bd_1.events_0 = bond_dyn_0[i_21].events_0;
        bd_1.force_lin_0 = vec4<f32>(resp_4.force_lin_1, resp_4.stored_5);
        bd_1.force_ang_0 = vec4<f32>(resp_4.force_ang_1, bd_1.force_ang_0.w);
        bond_dyn_0[i_21].js_0.damage_0 = bd_1.js_0.damage_0;
        bond_dyn_0[i_21].js_0.crush_1 = bd_1.js_0.crush_1;
        bond_dyn_0[i_21].js_0.kappa_0 = bd_1.js_0.kappa_0;
        bond_dyn_0[i_21].js_0.kappa_c_0 = bd_1.js_0.kappa_c_0;
        bond_dyn_0[i_21].js_0.ductility_0 = bd_1.js_0.ductility_0;
        bond_dyn_0[i_21].js_0.ductility_c_0 = bd_1.js_0.ductility_c_0;
        bond_dyn_0[i_21].js_0.life_0 = bd_1.js_0.life_0;
        bond_dyn_0[i_21].js_0.plastic_x_0 = bd_1.js_0.plastic_x_0;
        bond_dyn_0[i_21].js_0.plastic_y_0 = bd_1.js_0.plastic_y_0;
        bond_dyn_0[i_21].js_0.plastic_t_0 = bd_1.js_0.plastic_t_0;
        bond_dyn_0[i_21].js_0.rebar_plastic_0 = bd_1.js_0.rebar_plastic_0;
        bond_dyn_0[i_21].js_0.rebar_slip0_0 = bd_1.js_0.rebar_slip0_0;
        bond_dyn_0[i_21].js_0.rebar_slip1_0 = bd_1.js_0.rebar_slip1_0;
        bond_dyn_0[i_21].js_0.rebar_work_0 = bd_1.js_0.rebar_work_0;
        bond_dyn_0[i_21].js_0.rebar_broken_0 = bd_1.js_0.rebar_broken_0;
        bond_dyn_0[i_21].js_0.strain_rate_0 = bd_1.js_0.strain_rate_0;
        bond_dyn_0[i_21].js_0.governing_stress_0 = bd_1.js_0.governing_stress_0;
        bond_dyn_0[i_21].js_0.dissipated_0 = bd_1.js_0.dissipated_0;
        bond_dyn_0[i_21].js_0.utilization_0 = bd_1.js_0.utilization_0;
        bond_dyn_0[i_21].js_0.mode_0 = bd_1.js_0.mode_0;
        bond_dyn_0[i_21].force_lin_0 = bd_1.force_lin_0;
        bond_dyn_0[i_21].force_ang_0 = bd_1.force_ang_0;
        bond_dyn_0[i_21].sums_0 = bd_1.sums_0;
        bond_dyn_0[i_21].comps_0 = bd_1.comps_0;
        bond_dyn_0[i_21].events_0 = bd_1.events_0;
        write_bond_loads_0(i_21, i_21, resp_4.force_lin_1, resp_4.force_ang_1, max(resp_4.measures_0.tension_0, resp_4.measures_0.compression_0));
        i_21 = i_21 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    c_35 = _S809;
    loop
    {
        if(c_35 < c1_1)
        {
        }
        else
        {
            break;
        }
        var fi_4 : vec3<f32>;
        var mi_3 : vec3<f32>;
        gather_loads_0(c_35, &(fi_4), &(mi_3));
        var reaction_0 : vec3<f32>;
        if((fixed_mask_0(c_35)) != u32(0))
        {
            reaction_0 = (vec3<f32>(0) - (scratch_0[sv_0(c_35, u32(0))].xyz + fi_4));
        }
        else
        {
            var _S847 : u32 = u32(4) * c_35;
            reaction_0 = vec3<f32>(state_0[_S847 + u32(1)].w, state_0[_S847 + u32(2)].w, state_0[_S847 + u32(3)].w);
        }
        var _S848 : u32 = u32(4) * c_35;
        var _S849 : u32 = _S848 + u32(1);
        state_0[_S849] = vec4<f32>(state_0[_S849].xyz, reaction_0.x);
        state_0[_S848 + u32(2)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_0.y);
        state_0[_S848 + u32(3)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_0.z);
        c_35 = c_35 + u32(256);
    }
    if(tid_22 == u32(0))
    {
        var _S850 : f32 = (bitcast<f32>((newton_0)));
        var _S851 : f32 = (bitcast<f32>((cg_total_0)));
        if(converged_2)
        {
            previous_1 = 1.0f;
        }
        else
        {
            previous_1 = 0.0f;
        }
        scratch_0[statics_result_slot_0(_S804)] = vec4<f32>(residual_0, _S850, _S851, previous_1);
        islands_0[_S804].info_0[i32(2)] = (_S807 & (u32(4294967287)));
    }
    return;
}

var<workgroup> g_halt_0 : u32;

var<workgroup> g_run_0 : u32;

@compute
@workgroup_size(256, 1, 1)
fn settled_fatigue(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    var tid_23 : u32 = thread_7.x;
    var _S852 : u32 = group_7.x;
    var isl_31 : Island_std430_0 = islands_0[_S852];
    var _S853 : bool;
    if((((islands_0[_S852].info_0.x) & (u32(16)))) == u32(0))
    {
        _S853 = true;
    }
    else
    {
        _S853 = (isl_31.range_0.w) == (isl_31.range_0.z);
    }
    if(_S853)
    {
        return;
    }
    seen_clear_0(tid_23);
    if(tid_23 == u32(0))
    {
        g_halt_0 = u32(0);
        g_run_0 = u32(0);
    }
    workgroupBarrier();
    var _S854 : u32 = isl_31.info_0.w;
    var i_24 : u32 = isl_31.range_0.z + tid_23;
    loop
    {
        if(i_24 < (isl_31.range_0.w))
        {
        }
        else
        {
            break;
        }
        var _S855 : JointState_0 = JointState_0( bond_dyn_0[i_24].js_0.damage_0, bond_dyn_0[i_24].js_0.crush_1, bond_dyn_0[i_24].js_0.kappa_0, bond_dyn_0[i_24].js_0.kappa_c_0, bond_dyn_0[i_24].js_0.ductility_0, bond_dyn_0[i_24].js_0.ductility_c_0, bond_dyn_0[i_24].js_0.life_0, bond_dyn_0[i_24].js_0.plastic_x_0, bond_dyn_0[i_24].js_0.plastic_y_0, bond_dyn_0[i_24].js_0.plastic_t_0, bond_dyn_0[i_24].js_0.rebar_plastic_0, bond_dyn_0[i_24].js_0.rebar_slip0_0, bond_dyn_0[i_24].js_0.rebar_slip1_0, bond_dyn_0[i_24].js_0.rebar_work_0, bond_dyn_0[i_24].js_0.rebar_broken_0, bond_dyn_0[i_24].js_0.strain_rate_0, bond_dyn_0[i_24].js_0.governing_stress_0, bond_dyn_0[i_24].js_0.dissipated_0, bond_dyn_0[i_24].js_0.utilization_0, bond_dyn_0[i_24].js_0.mode_0 );
        var bd_2 : BondDyn_0;
        bd_2.js_0 = _S855;
        bd_2.force_lin_0 = bond_dyn_0[i_24].force_lin_0;
        bd_2.force_ang_0 = bond_dyn_0[i_24].force_ang_0;
        bd_2.sums_0 = bond_dyn_0[i_24].sums_0;
        bd_2.comps_0 = bond_dyn_0[i_24].comps_0;
        bd_2.events_0 = bond_dyn_0[i_24].events_0;
        var _S856 : JointBond_std430_0 = bonds_0[i_24].law_0;
        var _S857 : u32 = u32(4) * _S856.ids_0.y;
        var _S858 : u32 = u32(4) * _S856.ids_0.z;
        var d_lin_12 : vec3<f32>;
        var d_ang_10 : vec3<f32>;
        bond_kinematics_0(i_24, state_0[_S857].xyz, state_0[_S857 + u32(1)].xyz, state_0[_S858].xyz, state_0[_S858 + u32(1)].xyz, &(d_lin_12), &(d_ang_10));
        var _S859 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S856.ids_0.x];
        var previous_2 : JointState_0 = bd_2.js_0;
        var _S860 : JointResponse_0 = joint_evaluate_2(&(_S859), &(_S856), bd_2.js_0, d_lin_12, d_ang_10, params_0.dt_0, (params_0.fracture_0) != u32(0));
        if((_S860.state_1.damage_0) > (bd_2.js_0.damage_0 + 9.99999971718068537e-10f))
        {
            _S853 = true;
        }
        else
        {
            _S853 = (_S860.state_1.crush_1) > (previous_2.crush_1 + 9.99999971718068537e-10f);
        }
        var flags_5 : u32;
        if(_S853)
        {
            flags_5 = u32(16);
        }
        else
        {
            flags_5 = u32(0);
        }
        var _S861 : f32 = bd_2.sums_0[i32(0)];
        var _S862 : f32 = bd_2.comps_0[i32(0)];
        comp_add1_3(&(_S861), &(_S862), _S860.dissipated_4);
        bd_2.sums_0[i32(0)] = _S861;
        bd_2.comps_0[i32(0)] = _S862;
        var _S863 : f32 = bd_2.sums_0[i32(1)];
        var _S864 : f32 = bd_2.comps_0[i32(1)];
        comp_add1_3(&(_S863), &(_S864), _S860.overshoot_0);
        bd_2.sums_0[i32(1)] = _S863;
        bd_2.comps_0[i32(1)] = _S864;
        bd_2.force_lin_0 = vec4<f32>(_S860.force_lin_1, _S860.stored_5);
        bd_2.force_ang_0 = vec4<f32>(_S860.force_ang_1, max(bd_2.force_ang_0.w, _S860.state_1.utilization_0));
        var _S865 : bool;
        if(!is_damaged_1(previous_2))
        {
            _S865 = is_damaged_1(_S860.state_1);
        }
        else
        {
            _S865 = false;
        }
        var _S866 : bool;
        if(_S865)
        {
            _S866 = (bd_2.events_0.x) == u32(0);
        }
        else
        {
            _S866 = false;
        }
        if(_S866)
        {
            bd_2.events_0[i32(0)] = _S854;
            bd_2.events_0[i32(3)] = _S860.state_1.mode_0;
            g_seen_0[u32(3)] = u32(1);
        }
        var _S867 : bool;
        if((bd_2.events_0.y) == u32(0))
        {
            _S867 = (_S860.state_1.life_0) != (previous_2.life_0);
        }
        else
        {
            _S867 = false;
        }
        var _S868 : bool;
        if(_S867)
        {
            _S868 = (_S860.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S868 = false;
        }
        var _S869 : bool;
        if(_S868)
        {
            var _S870 : f32 = fatigue_factor_2(&(_S859), _S860.state_1.life_0);
            _S869 = _S870 <= 0.99000000953674316f;
        }
        else
        {
            _S869 = false;
        }
        if(_S869)
        {
            bd_2.events_0[i32(1)] = _S854;
            g_seen_0[u32(4)] = u32(1);
        }
        var flags_6 : u32;
        if(_S860.disconnected_0)
        {
            bd_2.events_0[i32(2)] = _S854;
            flags_6 = (flags_5 | (u32(32)));
        }
        else
        {
            flags_6 = flags_5;
        }
        bd_2.js_0 = _S860.state_1;
        bond_dyn_0[i_24].js_0.damage_0 = bd_2.js_0.damage_0;
        bond_dyn_0[i_24].js_0.crush_1 = bd_2.js_0.crush_1;
        bond_dyn_0[i_24].js_0.kappa_0 = bd_2.js_0.kappa_0;
        bond_dyn_0[i_24].js_0.kappa_c_0 = bd_2.js_0.kappa_c_0;
        bond_dyn_0[i_24].js_0.ductility_0 = bd_2.js_0.ductility_0;
        bond_dyn_0[i_24].js_0.ductility_c_0 = bd_2.js_0.ductility_c_0;
        bond_dyn_0[i_24].js_0.life_0 = bd_2.js_0.life_0;
        bond_dyn_0[i_24].js_0.plastic_x_0 = bd_2.js_0.plastic_x_0;
        bond_dyn_0[i_24].js_0.plastic_y_0 = bd_2.js_0.plastic_y_0;
        bond_dyn_0[i_24].js_0.plastic_t_0 = bd_2.js_0.plastic_t_0;
        bond_dyn_0[i_24].js_0.rebar_plastic_0 = bd_2.js_0.rebar_plastic_0;
        bond_dyn_0[i_24].js_0.rebar_slip0_0 = bd_2.js_0.rebar_slip0_0;
        bond_dyn_0[i_24].js_0.rebar_slip1_0 = bd_2.js_0.rebar_slip1_0;
        bond_dyn_0[i_24].js_0.rebar_work_0 = bd_2.js_0.rebar_work_0;
        bond_dyn_0[i_24].js_0.rebar_broken_0 = bd_2.js_0.rebar_broken_0;
        bond_dyn_0[i_24].js_0.strain_rate_0 = bd_2.js_0.strain_rate_0;
        bond_dyn_0[i_24].js_0.governing_stress_0 = bd_2.js_0.governing_stress_0;
        bond_dyn_0[i_24].js_0.dissipated_0 = bd_2.js_0.dissipated_0;
        bond_dyn_0[i_24].js_0.utilization_0 = bd_2.js_0.utilization_0;
        bond_dyn_0[i_24].js_0.mode_0 = bd_2.js_0.mode_0;
        bond_dyn_0[i_24].force_lin_0 = bd_2.force_lin_0;
        bond_dyn_0[i_24].force_ang_0 = bd_2.force_ang_0;
        bond_dyn_0[i_24].sums_0 = bd_2.sums_0;
        bond_dyn_0[i_24].comps_0 = bd_2.comps_0;
        bond_dyn_0[i_24].events_0 = bd_2.events_0;
        write_bond_loads_0(i_24, i_24, _S860.force_lin_1, _S860.force_ang_1, max(_S860.measures_0.tension_0, _S860.measures_0.compression_0));
        if(((flags_6 & (u32(16)))) != u32(0))
        {
            g_halt_0 = u32(1);
        }
        if(((flags_6 & (u32(32)))) != u32(0))
        {
            g_run_0 = u32(1);
        }
        i_24 = i_24 + u32(256);
    }
    workgroupBarrier();
    if(tid_23 != u32(0))
    {
        return;
    }
    if(((g_halt_0 | (g_run_0))) != u32(0))
    {
        var _S871 : u32 = isl_31.info_0.z;
        if(g_halt_0 != u32(0))
        {
            i_24 = u32(16);
        }
        else
        {
            i_24 = u32(0);
        }
        var _S872 : u32 = (_S871 | (i_24));
        if(g_run_0 != u32(0))
        {
            i_24 = u32(32);
        }
        else
        {
            i_24 = u32(0);
        }
        islands_0[_S852].info_0[i32(2)] = (_S872 | (i_24));
    }
    var _S873 : u32 = ((((isl_31.coverage_0) | (u32(16384)))) | ((seen_bits_0())));
    if(g_run_0 != u32(0))
    {
        i_24 = u32(128);
    }
    else
    {
        i_24 = u32(0);
    }
    islands_0[_S852].coverage_0 = (_S873 | (i_24));
    return;
}

fn impactor_integrate_at_0( ii_2 : u32,  tid_24 : u32)
{
    var p_23 : vec3<f32>;
    if(ii_2 >= (params_0.impactor_count_0))
    {
        return;
    }
    var imp_7 : Impactor_0;
    imp_7.position_1 = impactors_0[ii_2].position_1;
    imp_7.position_err_1 = impactors_0[ii_2].position_err_1;
    imp_7.velocity_1 = impactors_0[ii_2].velocity_1;
    imp_7.velocity_err_1 = impactors_0[ii_2].velocity_err_1;
    imp_7.angular_velocity_1 = impactors_0[ii_2].angular_velocity_1;
    imp_7.rotation_1 = impactors_0[ii_2].rotation_1;
    imp_7.inertia0_2 = impactors_0[ii_2].inertia0_2;
    imp_7.inertia1_2 = impactors_0[ii_2].inertia1_2;
    imp_7.inertia2_2 = impactors_0[ii_2].inertia2_2;
    imp_7.inv0_2 = impactors_0[ii_2].inv0_2;
    imp_7.inv1_2 = impactors_0[ii_2].inv1_2;
    imp_7.inv2_2 = impactors_0[ii_2].inv2_2;
    imp_7.shape_0 = impactors_0[ii_2].shape_0;
    imp_7.half_1 = impactors_0[ii_2].half_1;
    imp_7.mat_0 = impactors_0[ii_2].mat_0;
    imp_7.crush_0 = impactors_0[ii_2].crush_0;
    imp_7.geom_0 = impactors_0[ii_2].geom_0;
    imp_7.rotation_err_1 = impactors_0[ii_2].rotation_err_1;
    imp_7.ledger_0 = impactors_0[ii_2].ledger_0;
    imp_7.cand_0 = impactors_0[ii_2].cand_0;
    imp_7.momentum_1 = impactors_0[ii_2].momentum_1;
    imp_7.momentum_err_1 = impactors_0[ii_2].momentum_err_1;
    var _S874 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S875 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S875 = true;
    }
    else
    {
        var _S876 : u32 = _S874.y;
        if(_S876 != u32(0))
        {
            _S875 = (imp_7.cand_0.w) >= _S876;
        }
        else
        {
            _S875 = false;
        }
    }
    if(_S875)
    {
        return;
    }
    if((imp_7.cand_0.z) != u32(0))
    {
        if(tid_24 == u32(0))
        {
            impactors_0[ii_2].cand_0[i32(3)] = imp_7.cand_0.w + u32(1);
        }
        return;
    }
    var _S877 : vec4<f32> = vec4<f32>(0.0f);
    var rf_1 : vec4<f32> = _S877;
    var rt_0 : vec4<f32> = _S877;
    var k_25 : u32 = imp_7.cand_0.x + tid_24;
    loop
    {
        if(k_25 < (imp_7.cand_0.y))
        {
        }
        else
        {
            break;
        }
        var _S878 : u32 = u32(3) * k_25;
        rf_1 = rf_1 + scratch_0[params_0.cand_base_0 + _S878 + u32(1)];
        rt_0 = rt_0 + scratch_0[params_0.cand_base_0 + _S878 + u32(2)];
        k_25 = k_25 + u32(256);
    }
    group_sum2_3(tid_24, &(rf_1), &(rt_0));
    if(tid_24 != u32(0))
    {
        return;
    }
    var dt_19 : f32 = params_0.dt_0;
    var _S879 : vec3<f32> = vec3<f32>(0.0f);
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((params_0.has_ground_0) != u32(0))
    {
        var ib_0 : Box_0 = impactor_box_0(imp_7, _S879, imp_7.half_1.xyz);
        var _S880 : vec3<f32> = imp_7.velocity_1.xyz + imp_7.velocity_err_1.xyz;
        const _S881 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var kc_2 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_7.mat_0.x, ib_0, _S881);
        var _S882 : f32 = imp_7.position_1.z - params_0.ground_hi_0 + (imp_7.position_err_1.z - params_0.ground_lo_0);
        var total_points_0 : u32;
        if((imp_7.shape_0.x) == 0.0f)
        {
            total_points_0 = u32(1);
        }
        else
        {
            total_points_0 = u32(14);
        }
        var _S883 : f32 = kc_2 / f32(min(total_points_0, u32(5)));
        var s_17 : u32 = u32(0);
        var below_0 : u32 = u32(0);
        loop
        {
            if(s_17 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if((imp_7.shape_0.x) == 0.0f)
            {
                p_23 = vec3<f32>(0.0f, 0.0f, - imp_7.shape_0.y);
            }
            else
            {
                p_23 = sample_point_0(ib_0, s_17);
            }
            if((_S882 + p_23.z) < 0.0f)
            {
                below_0 = below_0 + u32(1);
            }
            s_17 = s_17 + u32(1);
        }
        if(below_0 > u32(0))
        {
            sentinel_mark_0(u32(8));
        }
        s_17 = u32(0);
        load_f_0 = _S879;
        load_t_0 = _S879;
        loop
        {
            if(s_17 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if((imp_7.shape_0.x) == 0.0f)
            {
                p_23 = vec3<f32>(0.0f, 0.0f, - imp_7.shape_0.y);
            }
            else
            {
                p_23 = sample_point_0(ib_0, s_17);
            }
            var depth_6 : f32 = - (_S882 + p_23.z);
            if(depth_6 <= 0.0f)
            {
                s_17 = s_17 + u32(1);
                continue;
            }
            var stored_15 : f32;
            var diss_7 : f32;
            var f_20 : vec3<f32> = penalty_force_0(_S883, imp_7.mat_0.z, params_0.ground_friction_0, depth_6, _S881, _S880 + cross(imp_7.angular_velocity_1.xyz, p_23), dt_19, below_0, &(stored_15), &(diss_7));
            var load_f_1 : vec3<f32> = load_f_0 + f_20;
            var load_t_1 : vec3<f32> = load_t_0 + cross(p_23, f_20);
            var _S884 : f32 = imp_7.ledger_0[i32(0)];
            var _S885 : f32 = imp_7.ledger_0[i32(1)];
            comp_add1_1(&(_S884), &(_S885), diss_7);
            imp_7.ledger_0[i32(0)] = _S884;
            imp_7.ledger_0[i32(1)] = _S885;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_17 = s_17 + u32(1);
        }
    }
    else
    {
        load_f_0 = _S879;
        load_t_0 = _S879;
    }
    var load_f_2 : vec3<f32> = rf_1.xyz + load_f_0;
    var load_t_2 : vec3<f32> = rt_0.xyz + load_t_0;
    var m_8 : f32 = imp_7.mat_0.z;
    var vel_1 : vec3<f32> = imp_7.velocity_1.xyz;
    var vel_err_1 : vec3<f32> = imp_7.velocity_err_1.xyz;
    var _S886 : vec3<f32> = vec3<f32>(dt_19);
    comp_add_0(&(vel_1), &(vel_err_1), (load_f_2 / vec3<f32>(m_8) + params_0.gravity_0.xyz) * _S886);
    var _S887 : Quat_0 = quat_of_0(imp_7.rotation_1);
    var q_14 : Quat_0 = _S887;
    var q_err_0 : vec4<f32> = imp_7.rotation_err_1;
    var l_hi_0 : vec3<f32> = imp_7.momentum_1.xyz;
    var l_err_1 : vec3<f32> = imp_7.momentum_err_1.xyz;
    comp_add_0(&(l_hi_0), &(l_err_1), load_t_2 * _S886);
    var l_8 : vec3<f32> = l_hi_0 + l_err_1;
    var w_mid_3 : vec3<f32> = world_mul_0(_S887, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_8);
    var pos_1 : vec3<f32> = imp_7.position_1.xyz;
    var pos_err_1 : vec3<f32> = imp_7.position_err_1.xyz;
    comp_add_0(&(pos_1), &(pos_err_1), (vel_1 + vel_err_1) * _S886);
    turn_left_0(&(q_14), &(q_err_0), w_mid_3, dt_19);
    imp_7.angular_velocity_1 = vec4<f32>(world_mul_0(q_14, imp_7.inv0_2, imp_7.inv1_2, imp_7.inv2_2, l_8), 0.0f);
    imp_7.rotation_1 = quat_vec_0(q_14);
    imp_7.rotation_err_1 = q_err_0;
    imp_7.momentum_1 = vec4<f32>(l_hi_0, 0.0f);
    imp_7.momentum_err_1 = vec4<f32>(l_err_1, 0.0f);
    imp_7.position_1 = vec4<f32>(pos_1, 0.0f);
    imp_7.position_err_1 = vec4<f32>(pos_err_1, 0.0f);
    imp_7.velocity_1 = vec4<f32>(vel_1, 0.0f);
    imp_7.velocity_err_1 = vec4<f32>(vel_err_1, 0.0f);
    imp_7.cand_0[i32(3)] = imp_7.cand_0[i32(3)] + u32(1);
    imp_7.geom_0 = vec4<f32>(1.0f, imp_7.crush_0.w, 0.0f, 0.0f);
    impactors_0[ii_2].position_1 = imp_7.position_1;
    impactors_0[ii_2].position_err_1 = imp_7.position_err_1;
    impactors_0[ii_2].velocity_1 = imp_7.velocity_1;
    impactors_0[ii_2].velocity_err_1 = imp_7.velocity_err_1;
    impactors_0[ii_2].angular_velocity_1 = imp_7.angular_velocity_1;
    impactors_0[ii_2].rotation_1 = imp_7.rotation_1;
    impactors_0[ii_2].inertia0_2 = imp_7.inertia0_2;
    impactors_0[ii_2].inertia1_2 = imp_7.inertia1_2;
    impactors_0[ii_2].inertia2_2 = imp_7.inertia2_2;
    impactors_0[ii_2].inv0_2 = imp_7.inv0_2;
    impactors_0[ii_2].inv1_2 = imp_7.inv1_2;
    impactors_0[ii_2].inv2_2 = imp_7.inv2_2;
    impactors_0[ii_2].shape_0 = imp_7.shape_0;
    impactors_0[ii_2].half_1 = imp_7.half_1;
    impactors_0[ii_2].mat_0 = imp_7.mat_0;
    impactors_0[ii_2].crush_0 = imp_7.crush_0;
    impactors_0[ii_2].geom_0 = imp_7.geom_0;
    impactors_0[ii_2].rotation_err_1 = imp_7.rotation_err_1;
    impactors_0[ii_2].ledger_0 = imp_7.ledger_0;
    impactors_0[ii_2].cand_0 = imp_7.cand_0;
    impactors_0[ii_2].momentum_1 = imp_7.momentum_1;
    impactors_0[ii_2].momentum_err_1 = imp_7.momentum_err_1;
    var k_26 : u32 = imp_7.cand_0.w - u32(1) - params_0.step_start_0;
    if(k_26 < (params_0.record_stride_0))
    {
        var at_6 : u32 = params_0.record_base_0 + u32(2) * (ii_2 * params_0.record_stride_0 + k_26);
        scratch_0[at_6] = vec4<f32>(vel_1 + vel_err_1, 0.0f);
        scratch_0[at_6 + u32(1)] = vec4<f32>(pos_1 + pos_err_1, 0.0f);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_integrate(@builtin(workgroup_id) group_8 : vec3<u32>, @builtin(local_invocation_id) thread_8 : vec3<u32>)
{
    impactor_integrate_at_0(group_8.x, thread_8.x);
    return;
}

fn ground_contact_0( c_42 : u32,  account_0 : bool,  f_21 : ptr<function, vec3<f32>>,  t_22 : ptr<function, vec3<f32>>)
{
    var wp_1 : WorldPoint_0 = chunk_world_0(c_42);
    var above_0 : f32 = wp_1.hi_0.z - params_0.ground_hi_0 + (wp_1.lo_0.z - params_0.ground_lo_0) + wp_1.rel_0.z;
    if((above_0 - chunks_0[c_42].half_0.w) > 0.0f)
    {
        return;
    }
    var b_52 : Box_0 = chunk_box_0(c_42, vec3<f32>(0.0f));
    const _S888 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S889 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_52, chunks_0[c_42].cmat_0.x, b_52, _S888);
    var _S890 : u32 = sample_count_0(b_52);
    var s_18 : u32 = u32(0);
    var n_11 : u32 = u32(0);
    loop
    {
        if(s_18 < _S890)
        {
        }
        else
        {
            break;
        }
        if((above_0 + sample_point_0(b_52, s_18).z) < 0.0f)
        {
            n_11 = n_11 + u32(1);
        }
        s_18 = s_18 + u32(1);
    }
    if(n_11 == u32(0))
    {
        return;
    }
    sentinel_mark_0(u32(4));
    var vc_1 : vec3<f32>;
    var wc_1 : vec3<f32>;
    chunk_velocity_1(c_42, &(vc_1), &(wc_1));
    var ledger_2 : vec4<f32> = scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_42];
    s_18 = u32(0);
    loop
    {
        if(s_18 < _S890)
        {
        }
        else
        {
            break;
        }
        var p_24 : vec3<f32> = sample_point_0(b_52, s_18);
        var _S891 : f32 = above_0 + p_24.z;
        if(!(_S891 < 0.0f))
        {
            s_18 = s_18 + u32(1);
            continue;
        }
        var stored_16 : f32;
        var diss_8 : f32;
        var g_2 : vec3<f32> = penalty_force_2(_S889 / f32(max(n_11, u32(5))), chunks_0[c_42].center_0.w, params_0.ground_friction_0, - _S891, _S888, vc_1 + cross(wc_1, p_24), params_0.dt_0, n_11, &(stored_16), &(diss_8));
        (*f_21) = (*f_21) + g_2;
        (*t_22) = (*t_22) + cross(p_24, g_2);
        var _S892 : f32 = ledger_2[i32(1)];
        var _S893 : f32 = ledger_2[i32(2)];
        comp_add1_3(&(_S892), &(_S893), diss_8);
        ledger_2[i32(1)] = _S892;
        ledger_2[i32(2)] = _S893;
        s_18 = s_18 + u32(1);
    }
    if(account_0)
    {
        scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_42] = ledger_2;
    }
    return;
}

fn contact_sum_at_0( g_3 : u32)
{
    var _S894 : bool;
    if(g_3 >= (params_0.seg_count_0))
    {
        _S894 = true;
    }
    else
    {
        _S894 = stopped_0();
    }
    if(_S894)
    {
        return;
    }
    var _S895 : u32 = u32(3) * g_3;
    var _S896 : u32 = index_0[params_0.seg_index_0 + _S895];
    var begin_1 : u32 = index_0[params_0.seg_index_0 + _S895 + u32(1)];
    var _S897 : u32 = index_0[params_0.seg_index_0 + _S895 + u32(2)];
    var _S898 : vec3<f32> = vec3<f32>(0.0f);
    var f_22 : vec3<f32> = _S898;
    var t_23 : vec3<f32> = _S898;
    var e_6 : u32 = begin_1;
    loop
    {
        if(e_6 < _S897)
        {
        }
        else
        {
            break;
        }
        var entry_5 : u32 = index_0[e_6];
        if(entry_5 == u32(2147483648))
        {
            ground_contact_0(_S896, true, &(f_22), &(t_23));
            e_6 = e_6 + u32(1);
            continue;
        }
        var _S899 : u32 = u32(2) * entry_5;
        f_22 = f_22 + scratch_0[params_0.slot_base_0 + _S899].xyz;
        t_23 = t_23 + scratch_0[params_0.slot_base_0 + _S899 + u32(1)].xyz;
        e_6 = e_6 + u32(1);
    }
    var _S900 : u32 = u32(2) * g_3;
    scratch_0[params_0.seg_base_0 + _S900] = vec4<f32>(f_22, 0.0f);
    scratch_0[params_0.seg_base_0 + _S900 + u32(1)] = vec4<f32>(t_23, 0.0f);
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn contact_sums(@builtin(global_invocation_id) id_2 : vec3<u32>)
{
    contact_sum_at_0(id_2.x);
    return;
}

fn chunk_update_0( c_43 : u32,  isl_32 : ptr<function, Island_std430_0>,  rg_18 : Rigid_0,  dt_20 : f32,  rml_0 : bool,  step_0 : u32,  contact_5 : bool,  work_4 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S901 : vec3<f32> = vec3<f32>(0.0f);
    var _S902 : u32 = index_0[c_43];
    var peak_0 : f32 = 0.0f;
    var e_7 : u32 = _S902;
    var fi_5 : vec3<f32> = _S901;
    var mi_4 : vec3<f32> = _S901;
    loop
    {
        if(e_7 < index_0[c_43 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_6 : u32 = index_0[e_7];
        var _S903 : u32 = u32(3) * ((entry_6 >> (u32(1))));
        var fa_1 : vec4<f32> = scratch_0[_S903];
        if(((entry_6 & (u32(1)))) == u32(0))
        {
            var mi_5 : vec3<f32> = mi_4 + scratch_0[_S903 + u32(1)].xyz;
            fi_5 = fi_5 + fa_1.xyz;
            mi_4 = mi_5;
        }
        else
        {
            var mi_6 : vec3<f32> = mi_4 + scratch_0[_S903 + u32(2)].xyz;
            fi_5 = fi_5 + (vec3<f32>(0) - fa_1.xyz);
            mi_4 = mi_6;
        }
        var _S904 : f32 = max(peak_0, fa_1.w);
        var _S905 : u32 = e_7 + u32(1);
        peak_0 = _S904;
        e_7 = _S905;
    }
    var _S906 : u32 = u32(4) * c_43;
    var u_2 : vec3<f32> = state_0[_S906].xyz;
    var _S907 : u32 = _S906 + u32(1);
    var th_4 : vec3<f32> = state_0[_S907].xyz;
    var _S908 : u32 = _S906 + u32(2);
    var v_10 : vec3<f32> = state_0[_S908].xyz;
    var _S909 : u32 = _S906 + u32(3);
    var w_6 : vec3<f32> = state_0[_S909].xyz;
    var mass_0 : f32 = chunks_0[c_43].center_0.w;
    var _S910 : vec3<f32> = chunks_0[c_43].center_0.xyz;
    var _S911 : vec3<f32> = (*isl_32).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_18.rot_1, _S910 + u_2 - _S911);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    var rep_f_2 : vec3<f32>;
    var rep_m_2 : vec3<f32>;
    chunk_loads_0(c_43, c_43, rg_18.rot_1, step_0, dt_20, contact_5, dt_20, &(f_load_0), &(t_load_0), &(rep_f_2), &(rep_m_2));
    record_chunk_load_0(c_43, f_load_0, t_load_0);
    var _S912 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S912;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_18.rot_1, chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, rg_18.alpha_0) + cross(rg_18.w_5, world_mul_0(rg_18.rot_1, chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, rg_18.w_5)));
        f_world_1 = f_world_0 - (rg_18.a_18 + cross(rg_18.alpha_0, r_world_0) + cross(rg_18.w_5, cross(rg_18.w_5, r_world_0))) * _S912;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    var f_ext_0 : vec3<f32> = inverse_rotate_0(rg_18.rot_1, f_world_1);
    var m_ext_0 : vec3<f32> = inverse_rotate_0(rg_18.rot_1, t_world_1);
    var f_ext_1 : vec3<f32>;
    var m_ext_1 : vec3<f32>;
    if(rml_0)
    {
        var wb_1 : vec3<f32> = inverse_rotate_0(rg_18.rot_1, rg_18.w_5);
        var i_w_0 : vec3<f32> = rows_mul_0(chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, w_6);
        var m_ext_2 : vec3<f32> = m_ext_0 - (cross(wb_1, i_w_0) + cross(w_6, rows_mul_0(chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, wb_1)) + cross(w_6, i_w_0));
        f_ext_1 = f_ext_0 - cross(wb_1, v_10) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var f_23 : vec3<f32> = f_ext_1 + rep_f_2 + fi_5;
    var m_9 : vec3<f32> = m_ext_1 + rep_m_2 + mi_4;
    var support_1 : u32 = chunks_0[c_43].info_1.x;
    var _S913 : vec3<f32> = vec3<f32>(state_0[_S907].w, state_0[_S908].w, state_0[_S909].w);
    var reaction_1 : vec3<f32>;
    var u_3 : vec3<f32>;
    var th_5 : vec3<f32>;
    var v_11 : vec3<f32>;
    var w_7 : vec3<f32>;
    if(support_1 == u32(1))
    {
        reaction_1 = (vec3<f32>(0) - f_23);
        u_3 = u_2;
        th_5 = th_4;
        v_11 = _S901;
        w_7 = _S901;
    }
    else
    {
        var _S914 : vec4<f32> = chunks_0[c_43].scale_0;
        var w_8 : vec3<f32> = w_6 + rows_mul_0(chunks_0[c_43].inv0_1, chunks_0[c_43].inv1_1, chunks_0[c_43].inv2_1, m_9) * vec3<f32>((dt_20 * chunks_0[c_43].scale_0.z));
        var _S915 : vec3<f32> = vec3<f32>(dt_20);
        var th_6 : vec3<f32> = th_4 + w_8 * _S915;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_23);
            u_3 = u_2;
            th_5 = _S901;
        }
        else
        {
            var v_12 : vec3<f32> = v_10 + f_23 * vec3<f32>((dt_20 * _S914.y));
            var u_4 : vec3<f32> = u_2 + v_12 * _S915;
            reaction_1 = _S913;
            u_3 = u_4;
            th_5 = v_12;
        }
        var _S916 : vec3<f32> = th_5;
        th_5 = th_6;
        v_11 = _S916;
        w_7 = w_8;
    }
    state_0[_S906] = vec4<f32>(u_3, peak_0);
    state_0[_S907] = vec4<f32>(th_5, reaction_1.x);
    state_0[_S908] = vec4<f32>(v_11, reaction_1.y);
    state_0[_S909] = vec4<f32>(w_7, reaction_1.z);
    comp_add1_3(&((*work_4)), &((*work_err_0)), (dot(f_load_0, rg_18.vel_0 + rg_18.vel_err_0 + cross(rg_18.w_5, rotate_0(rg_18.rot_1, _S910 + u_3 - _S911)) + rotate_0(rg_18.rot_1, v_11)) + dot(t_load_0, rg_18.w_5 + rotate_0(rg_18.rot_1, w_7))) * dt_20);
    return;
}

fn chunk_update_1( c_44 : u32,  isl_33 : Island_0,  rg_19 : Rigid_0,  dt_21 : f32,  rml_1 : bool,  step_1 : u32,  contact_6 : bool,  work_5 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S917 : vec3<f32> = vec3<f32>(0.0f);
    var _S918 : u32 = index_0[c_44];
    var peak_1 : f32 = 0.0f;
    var e_8 : u32 = _S918;
    var fi_6 : vec3<f32> = _S917;
    var mi_7 : vec3<f32> = _S917;
    loop
    {
        if(e_8 < index_0[c_44 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_7 : u32 = index_0[e_8];
        var _S919 : u32 = u32(3) * ((entry_7 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S919];
        if(((entry_7 & (u32(1)))) == u32(0))
        {
            var mi_8 : vec3<f32> = mi_7 + scratch_0[_S919 + u32(1)].xyz;
            fi_6 = fi_6 + fa_2.xyz;
            mi_7 = mi_8;
        }
        else
        {
            var mi_9 : vec3<f32> = mi_7 + scratch_0[_S919 + u32(2)].xyz;
            fi_6 = fi_6 + (vec3<f32>(0) - fa_2.xyz);
            mi_7 = mi_9;
        }
        var _S920 : f32 = max(peak_1, fa_2.w);
        var _S921 : u32 = e_8 + u32(1);
        peak_1 = _S920;
        e_8 = _S921;
    }
    var _S922 : u32 = u32(4) * c_44;
    var u_5 : vec3<f32> = state_0[_S922].xyz;
    var _S923 : u32 = _S922 + u32(1);
    var th_7 : vec3<f32> = state_0[_S923].xyz;
    var _S924 : u32 = _S922 + u32(2);
    var v_13 : vec3<f32> = state_0[_S924].xyz;
    var _S925 : u32 = _S922 + u32(3);
    var w_9 : vec3<f32> = state_0[_S925].xyz;
    var mass_1 : f32 = chunks_0[c_44].center_0.w;
    var _S926 : vec3<f32> = chunks_0[c_44].center_0.xyz;
    var _S927 : vec3<f32> = isl_33.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_19.rot_1, _S926 + u_5 - _S927);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    var rep_f_3 : vec3<f32>;
    var rep_m_3 : vec3<f32>;
    chunk_loads_0(c_44, c_44, rg_19.rot_1, step_1, dt_21, contact_6, dt_21, &(f_load_1), &(t_load_1), &(rep_f_3), &(rep_m_3));
    record_chunk_load_0(c_44, f_load_1, t_load_1);
    var _S928 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S928;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_19.rot_1, chunks_0[c_44].inertia0_1, chunks_0[c_44].inertia1_1, chunks_0[c_44].inertia2_1, rg_19.alpha_0) + cross(rg_19.w_5, world_mul_0(rg_19.rot_1, chunks_0[c_44].inertia0_1, chunks_0[c_44].inertia1_1, chunks_0[c_44].inertia2_1, rg_19.w_5)));
        f_world_3 = f_world_2 - (rg_19.a_18 + cross(rg_19.alpha_0, r_world_1) + cross(rg_19.w_5, cross(rg_19.w_5, r_world_1))) * _S928;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_3 = f_world_2;
        t_world_4 = t_world_3;
    }
    var f_ext_2 : vec3<f32> = inverse_rotate_0(rg_19.rot_1, f_world_3);
    var m_ext_3 : vec3<f32> = inverse_rotate_0(rg_19.rot_1, t_world_4);
    var f_ext_3 : vec3<f32>;
    var m_ext_4 : vec3<f32>;
    if(rml_1)
    {
        var wb_2 : vec3<f32> = inverse_rotate_0(rg_19.rot_1, rg_19.w_5);
        var i_w_1 : vec3<f32> = rows_mul_0(chunks_0[c_44].inertia0_1, chunks_0[c_44].inertia1_1, chunks_0[c_44].inertia2_1, w_9);
        var m_ext_5 : vec3<f32> = m_ext_3 - (cross(wb_2, i_w_1) + cross(w_9, rows_mul_0(chunks_0[c_44].inertia0_1, chunks_0[c_44].inertia1_1, chunks_0[c_44].inertia2_1, wb_2)) + cross(w_9, i_w_1));
        f_ext_3 = f_ext_2 - cross(wb_2, v_13) * vec3<f32>((2.0f * mass_1));
        m_ext_4 = m_ext_5;
    }
    else
    {
        f_ext_3 = f_ext_2;
        m_ext_4 = m_ext_3;
    }
    var f_24 : vec3<f32> = f_ext_3 + rep_f_3 + fi_6;
    var m_10 : vec3<f32> = m_ext_4 + rep_m_3 + mi_7;
    var support_2 : u32 = chunks_0[c_44].info_1.x;
    var _S929 : vec3<f32> = vec3<f32>(state_0[_S923].w, state_0[_S924].w, state_0[_S925].w);
    var reaction_2 : vec3<f32>;
    var u_6 : vec3<f32>;
    var th_8 : vec3<f32>;
    var v_14 : vec3<f32>;
    var w_10 : vec3<f32>;
    if(support_2 == u32(1))
    {
        reaction_2 = (vec3<f32>(0) - f_24);
        u_6 = u_5;
        th_8 = th_7;
        v_14 = _S917;
        w_10 = _S917;
    }
    else
    {
        var _S930 : vec4<f32> = chunks_0[c_44].scale_0;
        var w_11 : vec3<f32> = w_9 + rows_mul_0(chunks_0[c_44].inv0_1, chunks_0[c_44].inv1_1, chunks_0[c_44].inv2_1, m_10) * vec3<f32>((dt_21 * chunks_0[c_44].scale_0.z));
        var _S931 : vec3<f32> = vec3<f32>(dt_21);
        var th_9 : vec3<f32> = th_7 + w_11 * _S931;
        if(support_2 == u32(2))
        {
            reaction_2 = (vec3<f32>(0) - f_24);
            u_6 = u_5;
            th_8 = _S917;
        }
        else
        {
            var v_15 : vec3<f32> = v_13 + f_24 * vec3<f32>((dt_21 * _S930.y));
            var u_7 : vec3<f32> = u_5 + v_15 * _S931;
            reaction_2 = _S929;
            u_6 = u_7;
            th_8 = v_15;
        }
        var _S932 : vec3<f32> = th_8;
        th_8 = th_9;
        v_14 = _S932;
        w_10 = w_11;
    }
    state_0[_S922] = vec4<f32>(u_6, peak_1);
    state_0[_S923] = vec4<f32>(th_8, reaction_2.x);
    state_0[_S924] = vec4<f32>(v_14, reaction_2.y);
    state_0[_S925] = vec4<f32>(w_10, reaction_2.z);
    comp_add1_3(&((*work_5)), &((*work_err_1)), (dot(f_load_1, rg_19.vel_0 + rg_19.vel_err_0 + cross(rg_19.w_5, rotate_0(rg_19.rot_1, _S926 + u_6 - _S927)) + rotate_0(rg_19.rot_1, v_14)) + dot(t_load_1, rg_19.w_5 + rotate_0(rg_19.rot_1, w_10))) * dt_21);
    return;
}

fn drift_moments_0( c_45 : u32,  tu_2 : ptr<function, vec3<f32>>,  pv_2 : ptr<function, vec3<f32>>)
{
    var _S933 : u32 = u32(4) * c_45;
    var _S934 : vec3<f32> = vec3<f32>((chunks_0[c_45].center_0.w * chunks_0[c_45].scale_0.x));
    (*tu_2) = (*tu_2) + state_0[_S933].xyz * _S934;
    (*pv_2) = (*pv_2) + state_0[_S933 + u32(2)].xyz * _S934;
    return;
}

fn drift_moments_1( c_46 : u32,  tu_3 : ptr<function, vec3<f32>>,  pv_3 : ptr<function, vec3<f32>>)
{
    var _S935 : u32 = u32(4) * c_46;
    var _S936 : vec3<f32> = vec3<f32>((chunks_0[c_46].center_0.w * chunks_0[c_46].scale_0.x));
    (*tu_3) = (*tu_3) + state_0[_S935].xyz * _S936;
    (*pv_3) = (*pv_3) + state_0[_S935 + u32(2)].xyz * _S936;
    return;
}

fn island_frame_at_0( gi_0 : u32,  tid_25 : u32)
{
    var woke_0 : bool;
    var isl_34 : Island_0;
    isl_34.range_0 = islands_0[gi_0].range_0;
    isl_34.info_0 = islands_0[gi_0].info_0;
    isl_34.com_0 = islands_0[gi_0].com_0;
    isl_34.inertia0_0 = islands_0[gi_0].inertia0_0;
    isl_34.inertia1_0 = islands_0[gi_0].inertia1_0;
    isl_34.inertia2_0 = islands_0[gi_0].inertia2_0;
    isl_34.inv0_0 = islands_0[gi_0].inv0_0;
    isl_34.inv1_0 = islands_0[gi_0].inv1_0;
    isl_34.inv2_0 = islands_0[gi_0].inv2_0;
    isl_34.wcom_0 = islands_0[gi_0].wcom_0;
    isl_34.winv0_0 = islands_0[gi_0].winv0_0;
    isl_34.winv1_0 = islands_0[gi_0].winv1_0;
    isl_34.winv2_0 = islands_0[gi_0].winv2_0;
    isl_34.rotation_0 = islands_0[gi_0].rotation_0;
    isl_34.position_0 = islands_0[gi_0].position_0;
    isl_34.position_err_0 = islands_0[gi_0].position_err_0;
    isl_34.velocity_0 = islands_0[gi_0].velocity_0;
    isl_34.velocity_err_0 = islands_0[gi_0].velocity_err_0;
    isl_34.angular_velocity_0 = islands_0[gi_0].angular_velocity_0;
    isl_34.done_0 = islands_0[gi_0].done_0;
    isl_34.coverage_0 = islands_0[gi_0].coverage_0;
    isl_34.wide_groups_0 = islands_0[gi_0].wide_groups_0;
    isl_34.done_pad_0 = islands_0[gi_0].done_pad_0;
    isl_34.probes_0 = islands_0[gi_0].probes_0;
    isl_34.energy_0 = islands_0[gi_0].energy_0;
    isl_34.rotation_err_0 = islands_0[gi_0].rotation_err_0;
    isl_34.momentum_0 = islands_0[gi_0].momentum_0;
    isl_34.momentum_err_0 = islands_0[gi_0].momentum_err_0;
    var driven_0 : bool = (((isl_34.info_0.x) & (u32(2)))) != u32(0);
    var _S937 : bool = !((((isl_34.info_0.x) & (u32(1)))) != u32(0));
    var _S938 : bool;
    if(_S937)
    {
        _S938 = !driven_0;
    }
    else
    {
        _S938 = false;
    }
    var contact_island_0 : bool = (((isl_34.info_0.x) & (u32(4)))) != u32(0);
    var _S939 : bool = (((isl_34.info_0.x) & (u32(16)))) != u32(0);
    seen_clear_0(tid_25);
    var _S940 : bool = tid_25 == u32(0);
    var settled_0 : bool;
    var cov_2 : u32;
    if(_S940)
    {
        if(contact_island_0 != ((params_0.contact_mode_0) == u32(1)))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((isl_34.info_0.x) & (u32(8)))) != u32(0);
        }
        if(settled_0)
        {
            cov_2 = u32(0);
        }
        else
        {
            cov_2 = u32(1);
        }
        if(contact_island_0)
        {
            settled_0 = contact_stopped_2(isl_34);
        }
        else
        {
            settled_0 = false;
        }
        if(settled_0)
        {
            cov_2 = u32(0);
        }
        g_run_0 = cov_2;
        g_halt_0 = u32(0);
    }
    workgroupBarrier();
    if((((isl_34.info_0.z) & (u32(1)))) != u32(0))
    {
        settled_0 = true;
    }
    else
    {
        settled_0 = g_run_0 == u32(0);
    }
    if(settled_0)
    {
        cov_2 = u32(0);
    }
    else
    {
        cov_2 = min(isl_34.info_0.y, params_0.max_steps_0);
    }
    var _S941 : f32 = params_0.dt_0;
    var _S942 : bool = (params_0.fracture_0) != u32(0);
    var _S943 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_20 : Rigid_0 = rigid_of_2(isl_34);
    var work_6 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    settled_0 = _S939;
    var done_1 : u32 = u32(0);
    var woke_1 : bool = false;
    loop
    {
        if(done_1 < cov_2)
        {
        }
        else
        {
            woke_0 = woke_1;
            break;
        }
        var abs_step_1 : u32 = isl_34.info_0.w + done_1 + u32(1);
        var k_27 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var quiet_0 : bool = (((isl_34.info_0.x) & (u32(32)))) != u32(0);
        var _S944 : bool;
        if(settled_0)
        {
            _S944 = !quiet_0;
        }
        else
        {
            _S944 = false;
        }
        var _S945 : bool;
        var explicit_step_0 : bool;
        var c_47 : u32;
        if(_S944)
        {
            var _S946 : vec3<f32> = vec3<f32>(0.0f);
            var norm_1 : vec3<f32> = _S946;
            var unused0_0 : vec3<f32> = _S946;
            c_47 = isl_34.range_0.x + tid_25;
            loop
            {
                if(c_47 < (isl_34.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S947 : f32 = settled_chunk_load_0(c_47, rg_20.rot_1, k_27, _S941, contact_island_0);
                norm_1[i32(0)] = norm_1[i32(0)] + _S947;
                c_47 = c_47 + u32(256);
            }
            group_sum3_0(tid_25, &(norm_1), &(unused0_0));
            if((params_0.solve_mode_0) == u32(1))
            {
                _S945 = (abs(norm_1.x - isl_34.energy_0.z)) > (isl_34.energy_0.w);
            }
            else
            {
                _S945 = false;
            }
            if(_S945)
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
        if(_S937)
        {
            _S945 = !quiet_0;
        }
        else
        {
            _S945 = false;
        }
        if(_S945)
        {
            var _S948 : vec3<f32> = vec3<f32>(0.0f);
            var f_25 : vec3<f32> = _S948;
            var t_24 : vec3<f32> = _S948;
            c_47 = isl_34.range_0.x + tid_25;
            loop
            {
                if(c_47 < (isl_34.range_0.y))
                {
                }
                else
                {
                    break;
                }
                net_load_1(c_47, isl_34, rg_20, k_27, _S941, contact_island_0, &(f_25), &(t_24));
                c_47 = c_47 + u32(256);
            }
            group_sum3_0(tid_25, &(f_25), &(t_24));
            rigid_acceleration_2(isl_34, &(rg_20), f_25, t_24);
        }
        if(!settled_0)
        {
            explicit_step_0 = !quiet_0;
        }
        else
        {
            explicit_step_0 = false;
        }
        var c_48 : u32;
        if(explicit_step_0)
        {
            c_47 = isl_34.range_0.z + tid_25;
            loop
            {
                if(c_47 < (isl_34.range_0.w))
                {
                }
                else
                {
                    break;
                }
                var _S949 : bool = bond_update_0(c_47, _S941, _S942, abs_step_1, false);
                if(_S949)
                {
                    g_halt_0 = u32(1);
                }
                c_47 = c_47 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_48 = isl_34.range_0.x + tid_25;
            loop
            {
                if(c_48 < (isl_34.range_0.y))
                {
                }
                else
                {
                    break;
                }
                chunk_update_1(c_48, isl_34, rg_20, _S941, _S943, k_27, contact_island_0, &(work_6), &(work_err_2));
                c_48 = c_48 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        var _S950 : bool;
        if(_S938)
        {
            _S950 = !quiet_0;
        }
        else
        {
            _S950 = false;
        }
        if(_S950)
        {
            integrate_rigid_1(isl_34, &(rg_20), _S941);
        }
        var _S951 : bool;
        if(_S937)
        {
            _S951 = explicit_step_0;
        }
        else
        {
            _S951 = false;
        }
        if(_S951)
        {
            var _S952 : vec3<f32> = isl_34.wcom_0.xyz;
            var _S953 : vec3<f32> = vec3<f32>(0.0f);
            var tu_4 : vec3<f32> = _S953;
            var pv_4 : vec3<f32> = _S953;
            c_47 = isl_34.range_0.x + tid_25;
            loop
            {
                if(c_47 < (isl_34.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_47, &(tu_4), &(pv_4));
                c_47 = c_47 + u32(256);
            }
            group_sum3_0(tid_25, &(tu_4), &(pv_4));
            var tr_8 : vec3<f32> = tu_4 / vec3<f32>(isl_34.wcom_0.w);
            var dv_8 : vec3<f32> = pv_4 / vec3<f32>(isl_34.wcom_0.w);
            var lu_4 : vec3<f32> = _S953;
            var lv_4 : vec3<f32> = _S953;
            c_48 = isl_34.range_0.x + tid_25;
            loop
            {
                if(c_48 < (isl_34.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_48, _S952, tr_8, dv_8, &(lu_4), &(lv_4));
                c_48 = c_48 + u32(256);
            }
            group_sum3_0(tid_25, &(lu_4), &(lv_4));
            var phi_6 : vec3<f32> = rows_mul_0(isl_34.winv0_0, isl_34.winv1_0, isl_34.winv2_0, lu_4);
            var dw_5 : vec3<f32> = rows_mul_0(isl_34.winv0_0, isl_34.winv1_0, isl_34.winv2_0, lv_4);
            var c_49 : u32 = isl_34.range_0.x + tid_25;
            loop
            {
                if(c_49 < (isl_34.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_49, _S952, tr_8, phi_6, dv_8, dw_5);
                c_49 = c_49 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_34, &(rg_20), tr_8, phi_6, dv_8, dw_5);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        var _S954 : bool;
        if(_S940)
        {
            _S954 = (isl_34.probes_0.y) > (isl_34.probes_0.x);
        }
        else
        {
            _S954 = false;
        }
        if(_S954)
        {
            record_probes_0(isl_34, rg_20, k_27);
        }
        var _S955 : u32 = done_1 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S955;
            break;
        }
        done_1 = _S955;
        woke_1 = woke_0;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_6, work_err_2, 0.0f);
    var unused_3 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_25, &(wsum_0), &(unused_3));
    if(_S940)
    {
        isl_34.rotation_0 = quat_vec_0(rg_20.rot_1);
        isl_34.rotation_err_0 = rg_20.rot_err_0;
        isl_34.position_0 = vec4<f32>(rg_20.pos_0, 0.0f);
        isl_34.position_err_0 = vec4<f32>(rg_20.pos_err_0, 0.0f);
        isl_34.velocity_0 = vec4<f32>(rg_20.vel_0, 0.0f);
        isl_34.velocity_err_0 = vec4<f32>(rg_20.vel_err_0, 0.0f);
        isl_34.angular_velocity_0 = vec4<f32>(rg_20.w_5, 0.0f);
        isl_34.momentum_0 = vec4<f32>(rg_20.l_1, 0.0f);
        isl_34.momentum_err_0 = vec4<f32>(rg_20.l_err_0, 0.0f);
        isl_34.done_0 = done_1;
        isl_34.info_0[i32(1)] = isl_34.info_0[i32(1)] - done_1;
        if(g_halt_0 != u32(0))
        {
            _S938 = contact_island_0;
        }
        else
        {
            _S938 = false;
        }
        if(_S938)
        {
            contact_split_at_0(isl_34.info_0.w + done_1);
        }
        var _S956 : f32 = wsum_0.x;
        var _S957 : f32 = isl_34.energy_0[i32(0)];
        var _S958 : f32 = isl_34.energy_0[i32(1)];
        comp_add1_2(&(_S957), &(_S958), _S956);
        isl_34.energy_0[i32(0)] = _S957;
        isl_34.energy_0[i32(1)] = _S958 + wsum_0.y;
        isl_34.info_0[i32(3)] = isl_34.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_34.info_0[i32(2)] = ((isl_34.info_0[i32(2)]) | (u32(1)));
        }
        var _S959 : u32 = seen_bits_0();
        if(g_halt_0 != u32(0))
        {
            cov_2 = u32(128);
        }
        else
        {
            cov_2 = u32(0);
        }
        var _S960 : u32 = (_S959 | (cov_2));
        if(woke_0)
        {
            cov_2 = u32(2048);
        }
        else
        {
            cov_2 = u32(0);
        }
        var cov_3 : u32 = (_S960 | (cov_2));
        if(done_1 > u32(0))
        {
            var quiet_1 : bool = (((isl_34.info_0.x) & (u32(32)))) != u32(0);
            if(quiet_1)
            {
                cov_2 = u32(4096);
            }
            else
            {
                cov_2 = u32(0);
            }
            var cov_4 : u32 = (cov_3 | (cov_2));
            if((((isl_34.info_0.x) & (u32(16)))) != u32(0))
            {
                _S938 = !quiet_1;
            }
            else
            {
                _S938 = false;
            }
            if(_S938)
            {
                cov_2 = u32(512);
            }
            else
            {
                cov_2 = u32(0);
            }
            var cov_5 : u32 = (cov_4 | (cov_2));
            if((params_0.contact_mode_0) == u32(1))
            {
                cov_2 = u32(524288);
            }
            else
            {
                cov_2 = u32(0);
            }
            var cov_6 : u32 = (cov_5 | (cov_2));
            if((isl_34.probes_0.y) > (isl_34.probes_0.x))
            {
                cov_2 = u32(262144);
            }
            else
            {
                cov_2 = u32(0);
            }
            cov_2 = (cov_6 | (cov_2));
        }
        else
        {
            cov_2 = cov_3;
        }
        isl_34.coverage_0 = ((isl_34.coverage_0) | (cov_2));
        if(woke_0)
        {
            isl_34.info_0[i32(0)] = ((isl_34.info_0[i32(0)]) & (u32(4294967279)));
            isl_34.info_0[i32(2)] = ((isl_34.info_0[i32(2)]) | (u32(4)));
        }
        islands_0[gi_0].range_0 = isl_34.range_0;
        islands_0[gi_0].info_0 = isl_34.info_0;
        islands_0[gi_0].com_0 = isl_34.com_0;
        islands_0[gi_0].inertia0_0 = isl_34.inertia0_0;
        islands_0[gi_0].inertia1_0 = isl_34.inertia1_0;
        islands_0[gi_0].inertia2_0 = isl_34.inertia2_0;
        islands_0[gi_0].inv0_0 = isl_34.inv0_0;
        islands_0[gi_0].inv1_0 = isl_34.inv1_0;
        islands_0[gi_0].inv2_0 = isl_34.inv2_0;
        islands_0[gi_0].wcom_0 = isl_34.wcom_0;
        islands_0[gi_0].winv0_0 = isl_34.winv0_0;
        islands_0[gi_0].winv1_0 = isl_34.winv1_0;
        islands_0[gi_0].winv2_0 = isl_34.winv2_0;
        islands_0[gi_0].rotation_0 = isl_34.rotation_0;
        islands_0[gi_0].position_0 = isl_34.position_0;
        islands_0[gi_0].position_err_0 = isl_34.position_err_0;
        islands_0[gi_0].velocity_0 = isl_34.velocity_0;
        islands_0[gi_0].velocity_err_0 = isl_34.velocity_err_0;
        islands_0[gi_0].angular_velocity_0 = isl_34.angular_velocity_0;
        islands_0[gi_0].done_0 = isl_34.done_0;
        islands_0[gi_0].coverage_0 = isl_34.coverage_0;
        islands_0[gi_0].wide_groups_0 = isl_34.wide_groups_0;
        islands_0[gi_0].done_pad_0 = isl_34.done_pad_0;
        islands_0[gi_0].probes_0 = isl_34.probes_0;
        islands_0[gi_0].energy_0 = isl_34.energy_0;
        islands_0[gi_0].rotation_err_0 = isl_34.rotation_err_0;
        islands_0[gi_0].momentum_0 = isl_34.momentum_0;
        islands_0[gi_0].momentum_err_0 = isl_34.momentum_err_0;
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_9 : vec3<u32>, @builtin(local_invocation_id) thread_9 : vec3<u32>)
{
    island_frame_at_0(group_9.x, thread_9.x);
    return;
}

fn wide_chunks_at_0( gx_0 : u32,  tid_26 : u32)
{
    var wg_7 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, gx_0);
    var _S961 : Island_std430_0 = islands_0[wg_7.island_2];
    var _S962 : bool = wide_enter_1(tid_26, wg_7.island_2);
    if(!_S962)
    {
        return;
    }
    var _S963 : u32 = _S961.info_0.x;
    var anchored_0 : bool = ((_S963 & (u32(1)))) != u32(0);
    if(((_S963 & (u32(16)))) != u32(0))
    {
        if(tid_26 == u32(0))
        {
            scratch_0[params_0.wide_base_0 + u32(8) * gx_0 + u32(6)] = vec4<f32>(0.0f);
        }
        return;
    }
    var _S964 : Rigid_0 = wide_rigid_frame_0(tid_26, &(_S961), wg_7);
    var work_7 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S965 : vec3<f32> = vec3<f32>(0.0f);
    var tu_5 : vec3<f32> = _S965;
    var pv_5 : vec3<f32> = _S965;
    var c_50 : u32 = wg_7.begin_0 + tid_26;
    if(c_50 < (wg_7.end_0))
    {
        var _S966 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S967 : u32 = wide_step_0(&(_S961));
        chunk_update_0(c_50, &(_S961), _S964, params_0.dt_0, _S966, _S967, ((_S963 & (u32(4)))) != u32(0), &(work_7), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_50, &(tu_5), &(pv_5));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_7, work_err_3, 0.0f);
    var unused_4 : vec3<f32> = _S965;
    group_sum3_0(tid_26, &(wsum_1), &(unused_4));
    var _S968 : bool = !anchored_0;
    if(_S968)
    {
        group_sum3_0(tid_26, &(tu_5), &(pv_5));
    }
    if(tid_26 == u32(0))
    {
        var _S969 : u32 = u32(8) * gx_0;
        scratch_0[params_0.wide_base_0 + _S969 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S968)
        {
            wide_store_0(gx_0, u32(2), tu_5, pv_5);
        }
        scratch_0[params_0.wide_base_0 + _S969 + u32(7)] = vec4<f32>(f32(g_seen_0[u32(0)]), f32(g_seen_0[u32(1)]), f32(g_seen_0[u32(2)]), 0.0f);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_chunks(@builtin(workgroup_id) group_10 : vec3<u32>, @builtin(local_invocation_id) thread_10 : vec3<u32>)
{
    wide_chunks_at_0(group_10.x, thread_10.x);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn sums_and_impactors(@builtin(workgroup_id) group_11 : vec3<u32>, @builtin(local_invocation_id) thread_11 : vec3<u32>)
{
    var sums_groups_0 : u32 = (params_0.seg_count_0 + u32(255)) / u32(256);
    var _S970 : u32 = group_11.x;
    if(_S970 < sums_groups_0)
    {
        contact_sum_at_0(_S970 * u32(256) + thread_11.x);
    }
    else
    {
        impactor_integrate_at_0(_S970 - sums_groups_0, thread_11.x);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn islands_and_wide_chunks(@builtin(workgroup_id) group_12 : vec3<u32>, @builtin(local_invocation_id) thread_12 : vec3<u32>)
{
    var _S971 : u32 = group_12.x;
    if(_S971 < (params_0.halt_index_0))
    {
        island_frame_at_0(_S971, thread_12.x);
    }
    else
    {
        wide_chunks_at_0(_S971 - params_0.halt_index_0, thread_12.x);
    }
    return;
}

var<workgroup> g_flag_0 : u32;

var<workgroup> g_mode_0 : array<u32, i32(1024)>;

fn pc_k_0( isl_35 : Island_0) -> u32
{
    return isl_35.info_0.w - params_0.step_start_0;
}

fn pc_store_rigid_0( i_25 : u32,  rg_21 : Rigid_0)
{
    var at_7 : u32 = params_0.pi_base_0 + u32(16) * i_25;
    scratch_0[at_7] = quat_vec_0(rg_21.rot_1);
    scratch_0[at_7 + u32(1)] = rg_21.rot_err_0;
    scratch_0[at_7 + u32(2)] = vec4<f32>(rg_21.pos_0, 0.0f);
    scratch_0[at_7 + u32(3)] = vec4<f32>(rg_21.pos_err_0, 0.0f);
    scratch_0[at_7 + u32(4)] = vec4<f32>(rg_21.vel_0, 0.0f);
    scratch_0[at_7 + u32(5)] = vec4<f32>(rg_21.vel_err_0, 0.0f);
    scratch_0[at_7 + u32(6)] = vec4<f32>(rg_21.w_5, 0.0f);
    scratch_0[at_7 + u32(7)] = vec4<f32>(rg_21.l_1, 0.0f);
    scratch_0[at_7 + u32(8)] = vec4<f32>(rg_21.l_err_0, 0.0f);
    scratch_0[at_7 + u32(9)] = vec4<f32>(rg_21.torque_0, 0.0f);
    scratch_0[at_7 + u32(10)] = vec4<f32>(rg_21.a_18, 0.0f);
    scratch_0[at_7 + u32(11)] = vec4<f32>(rg_21.alpha_0, 0.0f);
    return;
}

fn pc_load_rigid_0( i_26 : u32) -> Rigid_0
{
    var at_8 : u32 = params_0.pi_base_0 + u32(16) * i_26;
    var rg_22 : Rigid_0;
    rg_22.rot_1 = quat_of_0(scratch_0[at_8]);
    rg_22.rot_err_0 = scratch_0[at_8 + u32(1)];
    rg_22.pos_0 = scratch_0[at_8 + u32(2)].xyz;
    rg_22.pos_err_0 = scratch_0[at_8 + u32(3)].xyz;
    rg_22.vel_0 = scratch_0[at_8 + u32(4)].xyz;
    rg_22.vel_err_0 = scratch_0[at_8 + u32(5)].xyz;
    rg_22.w_5 = scratch_0[at_8 + u32(6)].xyz;
    rg_22.l_1 = scratch_0[at_8 + u32(7)].xyz;
    rg_22.l_err_0 = scratch_0[at_8 + u32(8)].xyz;
    rg_22.torque_0 = scratch_0[at_8 + u32(9)].xyz;
    rg_22.a_18 = scratch_0[at_8 + u32(10)].xyz;
    rg_22.alpha_0 = scratch_0[at_8 + u32(11)].xyz;
    return rg_22;
}

fn contact_stopped_3( _S972 : u32) -> bool
{
    var _S973 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S974 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S974 = true;
    }
    else
    {
        var _S975 : u32 = _S973.y;
        if(_S975 != u32(0))
        {
            _S974 = _S975 <= (islands_0[_S972].info_0.w);
        }
        else
        {
            _S974 = false;
        }
    }
    return _S974;
}

fn pc_k_1( _S976 : u32) -> u32
{
    return islands_0[_S976].info_0.w - params_0.step_start_0;
}

fn pc_sum_0( _S977 : u32,  _S978 : ptr<function, vec3<f32>>,  _S979 : ptr<function, vec3<f32>>)
{
    var _S980 : vec4<u32> = islands_0[_S977].range_0;
    var c_51 : u32 = islands_0[_S977].range_0.x;
    loop
    {
        if(c_51 < (_S980.y))
        {
        }
        else
        {
            break;
        }
        var _S981 : u32 = u32(2) * c_51;
        (*_S978) = (*_S978) + scratch_0[params_0.pc_base_0 + _S981].xyz;
        (*_S979) = (*_S979) + scratch_0[params_0.pc_base_0 + _S981 + u32(1)].xyz;
        c_51 = c_51 + u32(1);
    }
    return;
}

fn rigid_of_3( _S982 : u32) -> Rigid_0
{
    var rg_23 : Rigid_0;
    rg_23.rot_1 = quat_of_0(islands_0[_S982].rotation_0);
    rg_23.rot_err_0 = islands_0[_S982].rotation_err_0;
    rg_23.pos_0 = islands_0[_S982].position_0.xyz;
    rg_23.pos_err_0 = islands_0[_S982].position_err_0.xyz;
    rg_23.vel_0 = islands_0[_S982].velocity_0.xyz;
    rg_23.vel_err_0 = islands_0[_S982].velocity_err_0.xyz;
    rg_23.w_5 = islands_0[_S982].angular_velocity_0.xyz;
    rg_23.l_1 = islands_0[_S982].momentum_0.xyz;
    rg_23.l_err_0 = islands_0[_S982].momentum_err_0.xyz;
    var _S983 : vec3<f32> = vec3<f32>(0.0f);
    rg_23.torque_0 = _S983;
    rg_23.a_18 = _S983;
    rg_23.alpha_0 = _S983;
    return rg_23;
}

fn net_load_2( _S984 : u32,  _S985 : u32,  _S986 : Rigid_0,  _S987 : u32,  _S988 : f32,  _S989 : bool,  _S990 : ptr<function, vec3<f32>>,  _S991 : ptr<function, vec3<f32>>)
{
    var fl_2 : vec3<f32>;
    var tl_2 : vec3<f32>;
    var rep_f_4 : vec3<f32>;
    var rep_m_4 : vec3<f32>;
    chunk_loads_0(_S984, _S984, _S986.rot_1, _S987, _S988, _S989, 0.0f, &(fl_2), &(tl_2), &(rep_f_4), &(rep_m_4));
    var fc_6 : vec3<f32> = fl_2 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[_S984].center_0.w);
    var _S992 : vec3<f32> = chunks_0[_S984].center_0.xyz;
    var _S993 : vec3<f32> = islands_0[_S985].com_0.xyz;
    var r_18 : vec3<f32> = rotate_0(_S986.rot_1, _S992 + state_0[u32(4) * _S984].xyz - _S993);
    (*_S990) = (*_S990) + fc_6;
    (*_S991) = (*_S991) + (cross(r_18, fc_6) + tl_2);
    if((chunks_0[_S984].load_range_0.y) > (chunks_0[_S984].load_range_0.x))
    {
        var fw_3 : vec3<f32> = rotate_0(_S986.rot_1, rep_f_4);
        (*_S990) = (*_S990) + fw_3;
        (*_S991) = (*_S991) + (cross(rotate_0(_S986.rot_1, _S992 - _S993), fw_3) + rotate_0(_S986.rot_1, rep_m_4));
    }
    return;
}

fn chunk_update_2( _S994 : u32,  _S995 : u32,  _S996 : Rigid_0,  _S997 : f32,  _S998 : bool,  _S999 : u32,  _S1000 : bool,  _S1001 : ptr<function, f32>,  _S1002 : ptr<function, f32>)
{
    var _S1003 : vec3<f32> = vec3<f32>(0.0f);
    var _S1004 : u32 = index_0[_S994];
    var peak_2 : f32 = 0.0f;
    var e_9 : u32 = _S1004;
    var fi_7 : vec3<f32> = _S1003;
    var mi_10 : vec3<f32> = _S1003;
    loop
    {
        if(e_9 < index_0[_S994 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_8 : u32 = index_0[e_9];
        var _S1005 : u32 = u32(3) * ((entry_8 >> (u32(1))));
        var fa_3 : vec4<f32> = scratch_0[_S1005];
        if(((entry_8 & (u32(1)))) == u32(0))
        {
            var mi_11 : vec3<f32> = mi_10 + scratch_0[_S1005 + u32(1)].xyz;
            fi_7 = fi_7 + fa_3.xyz;
            mi_10 = mi_11;
        }
        else
        {
            var mi_12 : vec3<f32> = mi_10 + scratch_0[_S1005 + u32(2)].xyz;
            fi_7 = fi_7 + (vec3<f32>(0) - fa_3.xyz);
            mi_10 = mi_12;
        }
        var _S1006 : f32 = max(peak_2, fa_3.w);
        var _S1007 : u32 = e_9 + u32(1);
        peak_2 = _S1006;
        e_9 = _S1007;
    }
    var _S1008 : u32 = u32(4) * _S994;
    var u_8 : vec3<f32> = state_0[_S1008].xyz;
    var _S1009 : u32 = _S1008 + u32(1);
    var th_10 : vec3<f32> = state_0[_S1009].xyz;
    var _S1010 : u32 = _S1008 + u32(2);
    var v_16 : vec3<f32> = state_0[_S1010].xyz;
    var _S1011 : u32 = _S1008 + u32(3);
    var w_12 : vec3<f32> = state_0[_S1011].xyz;
    var mass_2 : f32 = chunks_0[_S994].center_0.w;
    var _S1012 : vec3<f32> = chunks_0[_S994].center_0.xyz;
    var _S1013 : vec3<f32> = islands_0[_S995].com_0.xyz;
    var r_world_2 : vec3<f32> = rotate_0(_S996.rot_1, _S1012 + u_8 - _S1013);
    var f_load_2 : vec3<f32>;
    var t_load_2 : vec3<f32>;
    var rep_f_5 : vec3<f32>;
    var rep_m_5 : vec3<f32>;
    chunk_loads_0(_S994, _S994, _S996.rot_1, _S999, _S997, _S1000, _S997, &(f_load_2), &(t_load_2), &(rep_f_5), &(rep_m_5));
    record_chunk_load_0(_S994, f_load_2, t_load_2);
    var _S1014 : vec3<f32> = vec3<f32>(mass_2);
    var f_world_4 : vec3<f32> = f_load_2 + params_0.gravity_0.xyz * _S1014;
    var t_world_6 : vec3<f32> = t_load_2;
    var f_world_5 : vec3<f32>;
    var t_world_7 : vec3<f32>;
    if(_S998)
    {
        var t_world_8 : vec3<f32> = t_world_6 - (world_mul_0(_S996.rot_1, chunks_0[_S994].inertia0_1, chunks_0[_S994].inertia1_1, chunks_0[_S994].inertia2_1, _S996.alpha_0) + cross(_S996.w_5, world_mul_0(_S996.rot_1, chunks_0[_S994].inertia0_1, chunks_0[_S994].inertia1_1, chunks_0[_S994].inertia2_1, _S996.w_5)));
        f_world_5 = f_world_4 - (_S996.a_18 + cross(_S996.alpha_0, r_world_2) + cross(_S996.w_5, cross(_S996.w_5, r_world_2))) * _S1014;
        t_world_7 = t_world_8;
    }
    else
    {
        f_world_5 = f_world_4;
        t_world_7 = t_world_6;
    }
    var f_ext_4 : vec3<f32> = inverse_rotate_0(_S996.rot_1, f_world_5);
    var m_ext_6 : vec3<f32> = inverse_rotate_0(_S996.rot_1, t_world_7);
    var f_ext_5 : vec3<f32>;
    var m_ext_7 : vec3<f32>;
    if(_S998)
    {
        var wb_3 : vec3<f32> = inverse_rotate_0(_S996.rot_1, _S996.w_5);
        var i_w_2 : vec3<f32> = rows_mul_0(chunks_0[_S994].inertia0_1, chunks_0[_S994].inertia1_1, chunks_0[_S994].inertia2_1, w_12);
        var m_ext_8 : vec3<f32> = m_ext_6 - (cross(wb_3, i_w_2) + cross(w_12, rows_mul_0(chunks_0[_S994].inertia0_1, chunks_0[_S994].inertia1_1, chunks_0[_S994].inertia2_1, wb_3)) + cross(w_12, i_w_2));
        f_ext_5 = f_ext_4 - cross(wb_3, v_16) * vec3<f32>((2.0f * mass_2));
        m_ext_7 = m_ext_8;
    }
    else
    {
        f_ext_5 = f_ext_4;
        m_ext_7 = m_ext_6;
    }
    var f_26 : vec3<f32> = f_ext_5 + rep_f_5 + fi_7;
    var m_11 : vec3<f32> = m_ext_7 + rep_m_5 + mi_10;
    var support_3 : u32 = chunks_0[_S994].info_1.x;
    var _S1015 : vec3<f32> = vec3<f32>(state_0[_S1009].w, state_0[_S1010].w, state_0[_S1011].w);
    var reaction_3 : vec3<f32>;
    var u_9 : vec3<f32>;
    var th_11 : vec3<f32>;
    var v_17 : vec3<f32>;
    var w_13 : vec3<f32>;
    if(support_3 == u32(1))
    {
        reaction_3 = (vec3<f32>(0) - f_26);
        u_9 = u_8;
        th_11 = th_10;
        v_17 = _S1003;
        w_13 = _S1003;
    }
    else
    {
        var _S1016 : vec4<f32> = chunks_0[_S994].scale_0;
        var w_14 : vec3<f32> = w_12 + rows_mul_0(chunks_0[_S994].inv0_1, chunks_0[_S994].inv1_1, chunks_0[_S994].inv2_1, m_11) * vec3<f32>((_S997 * chunks_0[_S994].scale_0.z));
        var _S1017 : vec3<f32> = vec3<f32>(_S997);
        var th_12 : vec3<f32> = th_10 + w_14 * _S1017;
        if(support_3 == u32(2))
        {
            reaction_3 = (vec3<f32>(0) - f_26);
            u_9 = u_8;
            th_11 = _S1003;
        }
        else
        {
            var v_18 : vec3<f32> = v_16 + f_26 * vec3<f32>((_S997 * _S1016.y));
            var u_10 : vec3<f32> = u_8 + v_18 * _S1017;
            reaction_3 = _S1015;
            u_9 = u_10;
            th_11 = v_18;
        }
        var _S1018 : vec3<f32> = th_11;
        th_11 = th_12;
        v_17 = _S1018;
        w_13 = w_14;
    }
    state_0[_S1008] = vec4<f32>(u_9, peak_2);
    state_0[_S1009] = vec4<f32>(th_11, reaction_3.x);
    state_0[_S1010] = vec4<f32>(v_17, reaction_3.y);
    state_0[_S1011] = vec4<f32>(w_13, reaction_3.z);
    comp_add1_3(&((*_S1001)), &((*_S1002)), (dot(f_load_2, _S996.vel_0 + _S996.vel_err_0 + cross(_S996.w_5, rotate_0(_S996.rot_1, _S1012 + u_9 - _S1013)) + rotate_0(_S996.rot_1, v_17)) + dot(t_load_2, _S996.w_5 + rotate_0(_S996.rot_1, w_13))) * _S997);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn contact_frames(@builtin(workgroup_id) group_13 : vec3<u32>, @builtin(local_invocation_id) thread_13 : vec3<u32>)
{
    var mode_1 : u32;
    var mode_2 : u32;
    var mode_3 : u32;
    var contact_7 : bool;
    var _S1019 : bool;
    var c_52 : u32;
    var _S1020 : u32 = thread_13.x;
    var _S1021 : u32 = params_0.halt_index_0;
    var _S1022 : f32 = params_0.dt_0;
    var _S1023 : bool = (params_0.fracture_0) != u32(0);
    var _S1024 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var _S1025 : bool = (params_0.solve_mode_0) == u32(1);
    var s_19 : u32 = u32(0);
    loop
    {
        if(s_19 < (params_0.pc_steps_0))
        {
        }
        else
        {
            break;
        }
        seen_clear_0(_S1020);
        var _S1026 : bool = _S1020 == u32(0);
        if(_S1026)
        {
            g_flag_0 = u32(0);
        }
        workgroupBarrier();
        var i_27 : u32 = _S1020;
        loop
        {
            if(i_27 < _S1021)
            {
            }
            else
            {
                break;
            }
            var _S1027 : vec4<u32> = islands_0[i_27].info_0;
            var x_22 : u32 = islands_0[i_27].info_0.x;
            if(((x_22 & (u32(4)))) != u32(0))
            {
                contact_7 = ((x_22 & (u32(2)))) == u32(0);
            }
            else
            {
                contact_7 = false;
            }
            if(contact_7)
            {
                _S1019 = (((_S1027.z) & (u32(1)))) == u32(0);
            }
            else
            {
                _S1019 = false;
            }
            var _S1028 : bool;
            if(_S1019)
            {
                _S1028 = (_S1027.y) > u32(0);
            }
            else
            {
                _S1028 = false;
            }
            var _S1029 : bool;
            if(_S1028)
            {
                _S1029 = !contact_stopped_3(i_27);
            }
            else
            {
                _S1029 = false;
            }
            if(_S1029)
            {
                var quiet_2 : bool = ((x_22 & (u32(32)))) != u32(0);
                var settled_1 : bool = ((x_22 & (u32(16)))) != u32(0);
                var _S1030 : bool;
                if(!(((x_22 & (u32(1)))) != u32(0)))
                {
                    _S1030 = !quiet_2;
                }
                else
                {
                    _S1030 = false;
                }
                if(_S1030)
                {
                    mode_1 = u32(13);
                }
                else
                {
                    mode_1 = u32(1);
                }
                var _S1031 : bool;
                if(!settled_1)
                {
                    _S1031 = !quiet_2;
                }
                else
                {
                    _S1031 = false;
                }
                if(_S1031)
                {
                    mode_2 = (mode_1 | (u32(2)));
                }
                else
                {
                    mode_2 = mode_1;
                }
                var _S1032 : bool;
                if(settled_1)
                {
                    _S1032 = !quiet_2;
                }
                else
                {
                    _S1032 = false;
                }
                if(_S1032)
                {
                    mode_3 = (mode_2 | (u32(128)));
                }
                else
                {
                    mode_3 = mode_2;
                }
                g_flag_0 = u32(1);
                mode_1 = mode_3;
            }
            else
            {
                mode_1 = u32(0);
            }
            g_mode_0[i_27] = mode_1;
            i_27 = i_27 + u32(256);
        }
        workgroupBarrier();
        if(g_flag_0 == u32(0))
        {
            break;
        }
        var _S1033 : u32 = _S1020 % u32(32);
        mode_1 = _S1020 / u32(32);
        loop
        {
            if(mode_1 < (params_0.pair_count_0))
            {
            }
            else
            {
                break;
            }
            if(!pair_any_0(stopped_0(), u32(32)))
            {
                pair_contact_0(mode_1, _S1033, u32(32));
            }
            mode_1 = mode_1 + u32(8);
        }
        mode_2 = _S1020 / u32(32);
        loop
        {
            if(mode_2 < (params_0.cand_count_0))
            {
            }
            else
            {
                break;
            }
            if(!pair_any_0(stopped_0(), u32(32)))
            {
                impactor_candidate_forces_0(mode_2, _S1033, u32(32));
            }
            mode_2 = mode_2 + u32(8);
        }
        mode_3 = _S1020;
        loop
        {
            if(mode_3 < (params_0.chunk_count_0))
            {
            }
            else
            {
                break;
            }
            travel_check_0(mode_3);
            mode_3 = mode_3 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
        {
            break;
        }
        var g_4 : u32 = _S1020;
        loop
        {
            if(g_4 < (params_0.seg_count_0))
            {
            }
            else
            {
                break;
            }
            contact_sum_at_0(g_4);
            g_4 = g_4 + u32(256);
        }
        var ii_3 : u32 = u32(0);
        loop
        {
            if(ii_3 < (params_0.impactor_count_0))
            {
            }
            else
            {
                break;
            }
            impactor_integrate_at_0(ii_3, _S1020);
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            ii_3 = ii_3 + u32(1);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_53 : u32 = _S1020;
        loop
        {
            if(c_53 < (params_0.chunk_count_0))
            {
            }
            else
            {
                break;
            }
            var i_28 : u32 = chunks_0[c_53].info_1.y;
            if((((g_mode_0[i_28]) & (u32(128)))) == u32(0))
            {
                c_53 = c_53 + u32(256);
                continue;
            }
            var norm_2 : f32 = settled_chunk_load_0(c_53, quat_of_0(islands_0[i_28].rotation_0), pc_k_1(i_28), _S1022, true);
            var _S1034 : u32 = u32(2) * c_53;
            scratch_0[params_0.pc_base_0 + _S1034] = vec4<f32>(norm_2, 0.0f, 0.0f, 0.0f);
            scratch_0[params_0.pc_base_0 + _S1034 + u32(1)] = vec4<f32>(0.0f);
            c_53 = c_53 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var i_29 : u32 = _S1020;
        loop
        {
            if(i_29 < _S1021)
            {
            }
            else
            {
                break;
            }
            var mode_4 : u32 = g_mode_0[i_29];
            if((((g_mode_0[i_29]) & (u32(128)))) == u32(0))
            {
                i_29 = i_29 + u32(256);
                continue;
            }
            var isl_36 : Island_std430_0 = islands_0[i_29];
            var _S1035 : vec3<f32> = vec3<f32>(0.0f);
            var norm_3 : vec3<f32> = _S1035;
            var unused_5 : vec3<f32> = _S1035;
            pc_sum_0(i_29, &(norm_3), &(unused_5));
            if(_S1025)
            {
                contact_7 = (abs(norm_3.x - isl_36.energy_0.z)) > (isl_36.energy_0.w);
            }
            else
            {
                contact_7 = false;
            }
            if(contact_7)
            {
                g_mode_0[i_29] = (((mode_4 | (u32(2)))) | (u32(64)));
            }
            i_29 = i_29 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_54 : u32 = _S1020;
        loop
        {
            if(c_54 < (params_0.chunk_count_0))
            {
            }
            else
            {
                break;
            }
            var i_30 : u32 = chunks_0[c_54].info_1.y;
            if((((g_mode_0[i_30]) & (u32(4)))) == u32(0))
            {
                c_54 = c_54 + u32(256);
                continue;
            }
            var _S1036 : vec3<f32> = vec3<f32>(0.0f);
            var f_27 : vec3<f32> = _S1036;
            var t_25 : vec3<f32> = _S1036;
            net_load_2(c_54, i_30, rigid_of_3(i_30), pc_k_1(i_30), _S1022, true, &(f_27), &(t_25));
            var _S1037 : u32 = u32(2) * c_54;
            scratch_0[params_0.pc_base_0 + _S1037] = vec4<f32>(f_27, 0.0f);
            scratch_0[params_0.pc_base_0 + _S1037 + u32(1)] = vec4<f32>(t_25, 0.0f);
            c_54 = c_54 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var i_31 : u32 = _S1020;
        loop
        {
            if(i_31 < _S1021)
            {
            }
            else
            {
                break;
            }
            var mode_5 : u32 = g_mode_0[i_31];
            if((((g_mode_0[i_31]) & (u32(1)))) == u32(0))
            {
                i_31 = i_31 + u32(256);
                continue;
            }
            var _S1038 : Island_std430_0 = islands_0[i_31];
            var rg_24 : Rigid_0 = rigid_of_3(i_31);
            if(((mode_5 & (u32(4)))) != u32(0))
            {
                var _S1039 : vec3<f32> = vec3<f32>(0.0f);
                var f_28 : vec3<f32> = _S1039;
                var t_26 : vec3<f32> = _S1039;
                pc_sum_0(i_31, &(f_28), &(t_26));
                rigid_acceleration_1(&(_S1038), &(rg_24), f_28, t_26);
            }
            pc_store_rigid_0(i_31, rg_24);
            if(((mode_5 & (u32(6)))) == u32(6))
            {
                g_mode_0[i_31] = (mode_5 | (u32(16)));
            }
            i_31 = i_31 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var b_53 : u32 = _S1020;
        loop
        {
            if(b_53 < (params_0.bond_count_0))
            {
            }
            else
            {
                break;
            }
            var i_32 : u32 = bonds_0[b_53].law_0.ids_0.w;
            var mode_6 : u32 = g_mode_0[i_32];
            if((((g_mode_0[i_32]) & (u32(2)))) == u32(0))
            {
                b_53 = b_53 + u32(256);
                continue;
            }
            var _S1040 : bool = bond_update_0(b_53, _S1022, _S1023, islands_0[i_32].info_0.w + u32(1), (((islands_0[i_32].info_0.x) & (u32(8)))) != u32(0));
            if(_S1040)
            {
                g_mode_0[i_32] = (mode_6 | (u32(32)));
            }
            b_53 = b_53 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_55 : u32 = _S1020;
        loop
        {
            if(c_55 < (params_0.chunk_count_0))
            {
            }
            else
            {
                break;
            }
            var i_33 : u32 = chunks_0[c_55].info_1.y;
            if((((g_mode_0[i_33]) & (u32(2)))) == u32(0))
            {
                c_55 = c_55 + u32(256);
                continue;
            }
            var work_8 : f32 = 0.0f;
            var work_err_4 : f32 = 0.0f;
            chunk_update_2(c_55, i_33, pc_load_rigid_0(i_33), _S1022, _S1024, pc_k_1(i_33), true, &(work_8), &(work_err_4));
            var _S1041 : u32 = u32(2) * c_55;
            scratch_0[params_0.pc_base_0 + _S1041] = vec4<f32>(work_8, work_err_4, 0.0f, 0.0f);
            scratch_0[params_0.pc_base_0 + _S1041 + u32(1)] = vec4<f32>(0.0f);
            c_55 = c_55 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var i_34 : u32 = _S1020;
        loop
        {
            if(i_34 < _S1021)
            {
            }
            else
            {
                break;
            }
            var mode_7 : u32 = g_mode_0[i_34];
            if((((g_mode_0[i_34]) & (u32(1)))) == u32(0))
            {
                i_34 = i_34 + u32(256);
                continue;
            }
            var isl_37 : Island_0;
            isl_37.range_0 = islands_0[i_34].range_0;
            isl_37.info_0 = islands_0[i_34].info_0;
            isl_37.com_0 = islands_0[i_34].com_0;
            isl_37.inertia0_0 = islands_0[i_34].inertia0_0;
            isl_37.inertia1_0 = islands_0[i_34].inertia1_0;
            isl_37.inertia2_0 = islands_0[i_34].inertia2_0;
            isl_37.inv0_0 = islands_0[i_34].inv0_0;
            isl_37.inv1_0 = islands_0[i_34].inv1_0;
            isl_37.inv2_0 = islands_0[i_34].inv2_0;
            isl_37.wcom_0 = islands_0[i_34].wcom_0;
            isl_37.winv0_0 = islands_0[i_34].winv0_0;
            isl_37.winv1_0 = islands_0[i_34].winv1_0;
            isl_37.winv2_0 = islands_0[i_34].winv2_0;
            isl_37.rotation_0 = islands_0[i_34].rotation_0;
            isl_37.position_0 = islands_0[i_34].position_0;
            isl_37.position_err_0 = islands_0[i_34].position_err_0;
            isl_37.velocity_0 = islands_0[i_34].velocity_0;
            isl_37.velocity_err_0 = islands_0[i_34].velocity_err_0;
            isl_37.angular_velocity_0 = islands_0[i_34].angular_velocity_0;
            isl_37.done_0 = islands_0[i_34].done_0;
            isl_37.coverage_0 = islands_0[i_34].coverage_0;
            isl_37.wide_groups_0 = islands_0[i_34].wide_groups_0;
            isl_37.done_pad_0 = islands_0[i_34].done_pad_0;
            isl_37.probes_0 = islands_0[i_34].probes_0;
            isl_37.energy_0 = islands_0[i_34].energy_0;
            isl_37.rotation_err_0 = islands_0[i_34].rotation_err_0;
            isl_37.momentum_0 = islands_0[i_34].momentum_0;
            isl_37.momentum_err_0 = islands_0[i_34].momentum_err_0;
            var rg_25 : Rigid_0 = pc_load_rigid_0(i_34);
            if(((mode_7 & (u32(2)))) != u32(0))
            {
                var work_9 : f32 = 0.0f;
                var work_err_5 : f32 = 0.0f;
                c_52 = isl_37.range_0.x;
                loop
                {
                    if(c_52 < (isl_37.range_0.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    comp_add1_3(&(work_9), &(work_err_5), scratch_0[params_0.pc_base_0 + u32(2) * c_52].x);
                    work_err_5 = work_err_5 + scratch_0[params_0.pc_base_0 + u32(2) * c_52].y;
                    c_52 = c_52 + u32(1);
                }
                var _S1042 : f32 = isl_37.energy_0[i32(0)];
                var _S1043 : f32 = isl_37.energy_0[i32(1)];
                comp_add1_3(&(_S1042), &(_S1043), work_9);
                isl_37.energy_0[i32(0)] = _S1042;
                isl_37.energy_0[i32(1)] = _S1043 + work_err_5;
                islands_0[i_34].energy_0 = isl_37.energy_0;
            }
            if(((mode_7 & (u32(8)))) != u32(0))
            {
                integrate_rigid_2(isl_37, &(rg_25), _S1022);
            }
            pc_store_rigid_0(i_34, rg_25);
            i_34 = i_34 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        c_52 = _S1020;
        loop
        {
            if(c_52 < (params_0.chunk_count_0))
            {
            }
            else
            {
                break;
            }
            if((((g_mode_0[chunks_0[c_52].info_1.y]) & (u32(16)))) == u32(0))
            {
                c_52 = c_52 + u32(256);
                continue;
            }
            var _S1044 : vec3<f32> = vec3<f32>(0.0f);
            var tu_6 : vec3<f32> = _S1044;
            var pv_6 : vec3<f32> = _S1044;
            drift_moments_1(c_52, &(tu_6), &(pv_6));
            var _S1045 : u32 = u32(2) * c_52;
            scratch_0[params_0.pc_base_0 + _S1045] = vec4<f32>(tu_6, 0.0f);
            scratch_0[params_0.pc_base_0 + _S1045 + u32(1)] = vec4<f32>(pv_6, 0.0f);
            c_52 = c_52 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var i_35 : u32 = _S1020;
        loop
        {
            if(i_35 < _S1021)
            {
            }
            else
            {
                break;
            }
            if((((g_mode_0[i_35]) & (u32(16)))) == u32(0))
            {
                i_35 = i_35 + u32(256);
                continue;
            }
            var _S1046 : vec3<f32> = vec3<f32>(0.0f);
            var tu_7 : vec3<f32> = _S1046;
            var pv_7 : vec3<f32> = _S1046;
            pc_sum_0(i_35, &(tu_7), &(pv_7));
            var _S1047 : u32 = u32(16) * i_35;
            var _S1048 : vec3<f32> = vec3<f32>(islands_0[i_35].wcom_0.w);
            scratch_0[params_0.pi_base_0 + _S1047 + u32(12)] = vec4<f32>(tu_7 / _S1048, 0.0f);
            scratch_0[params_0.pi_base_0 + _S1047 + u32(13)] = vec4<f32>(pv_7 / _S1048, 0.0f);
            i_35 = i_35 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_56 : u32 = _S1020;
        loop
        {
            if(c_56 < (params_0.chunk_count_0))
            {
            }
            else
            {
                break;
            }
            var i_36 : u32 = chunks_0[c_56].info_1.y;
            if((((g_mode_0[i_36]) & (u32(16)))) == u32(0))
            {
                c_56 = c_56 + u32(256);
                continue;
            }
            var _S1049 : vec3<f32> = vec3<f32>(0.0f);
            var lu_5 : vec3<f32> = _S1049;
            var lv_5 : vec3<f32> = _S1049;
            var _S1050 : u32 = u32(16) * i_36;
            drift_angular_1(c_56, islands_0[i_36].wcom_0.xyz, scratch_0[params_0.pi_base_0 + _S1050 + u32(12)].xyz, scratch_0[params_0.pi_base_0 + _S1050 + u32(13)].xyz, &(lu_5), &(lv_5));
            var _S1051 : u32 = u32(2) * c_56;
            scratch_0[params_0.pc_base_0 + _S1051] = vec4<f32>(lu_5, 0.0f);
            scratch_0[params_0.pc_base_0 + _S1051 + u32(1)] = vec4<f32>(lv_5, 0.0f);
            c_56 = c_56 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var i_37 : u32 = _S1020;
        loop
        {
            if(i_37 < _S1021)
            {
            }
            else
            {
                break;
            }
            if((((g_mode_0[i_37]) & (u32(16)))) == u32(0))
            {
                i_37 = i_37 + u32(256);
                continue;
            }
            var isl_38 : Island_std430_0 = islands_0[i_37];
            var _S1052 : vec3<f32> = vec3<f32>(0.0f);
            var lu_6 : vec3<f32> = _S1052;
            var lv_6 : vec3<f32> = _S1052;
            pc_sum_0(i_37, &(lu_6), &(lv_6));
            var _S1053 : u32 = u32(16) * i_37;
            scratch_0[params_0.pi_base_0 + _S1053 + u32(14)] = vec4<f32>(rows_mul_0(islands_0[i_37].winv0_0, islands_0[i_37].winv1_0, islands_0[i_37].winv2_0, lu_6), 0.0f);
            scratch_0[params_0.pi_base_0 + _S1053 + u32(15)] = vec4<f32>(rows_mul_0(isl_38.winv0_0, isl_38.winv1_0, isl_38.winv2_0, lv_6), 0.0f);
            i_37 = i_37 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_57 : u32 = _S1020;
        loop
        {
            if(c_57 < (params_0.chunk_count_0))
            {
            }
            else
            {
                break;
            }
            var i_38 : u32 = chunks_0[c_57].info_1.y;
            if((((g_mode_0[i_38]) & (u32(16)))) == u32(0))
            {
                c_57 = c_57 + u32(256);
                continue;
            }
            var at_9 : u32 = params_0.pi_base_0 + u32(16) * i_38;
            drift_apply_0(c_57, islands_0[i_38].wcom_0.xyz, scratch_0[at_9 + u32(12)].xyz, scratch_0[at_9 + u32(14)].xyz, scratch_0[at_9 + u32(13)].xyz, scratch_0[at_9 + u32(15)].xyz);
            c_57 = c_57 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(_S1026)
        {
            g_flag_0 = u32(0);
        }
        workgroupBarrier();
        var i_39 : u32 = _S1020;
        loop
        {
            if(i_39 < _S1021)
            {
            }
            else
            {
                break;
            }
            if((((g_mode_0[i_39]) & (u32(32)))) != u32(0))
            {
                g_flag_0 = u32(1);
            }
            i_39 = i_39 + u32(256);
        }
        workgroupBarrier();
        var c_58 : u32;
        var pass_1 : u32;
        var i_40 : u32;
        var c_59 : u32;
        var e_10 : u32;
        var other_1 : u32;
        if(g_flag_0 != u32(0))
        {
            c_58 = _S1020;
            loop
            {
                if(c_58 < (params_0.chunk_count_0))
                {
                }
                else
                {
                    break;
                }
                if((((g_mode_0[chunks_0[c_58].info_1.y]) & (u32(32)))) != u32(0))
                {
                    scratch_0[params_0.pc_base_0 + u32(2) * c_58] = vec4<f32>((bitcast<f32>((c_58))), 0.0f, 0.0f, 0.0f);
                }
                c_58 = c_58 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            pass_1 = u32(0);
            loop
            {
                if(pass_1 <= (params_0.chunk_count_0))
                {
                }
                else
                {
                    break;
                }
                if(_S1026)
                {
                    g_flag_0 = u32(0);
                }
                storageBarrier(); textureBarrier(); workgroupBarrier();;
                i_40 = _S1020;
                loop
                {
                    if(i_40 < (params_0.chunk_count_0))
                    {
                    }
                    else
                    {
                        break;
                    }
                    if((((g_mode_0[chunks_0[i_40].info_1.y]) & (u32(32)))) == u32(0))
                    {
                        i_40 = i_40 + u32(256);
                        continue;
                    }
                    var _S1054 : u32 = u32(2) * i_40;
                    var _S1055 : u32 = index_0[i_40];
                    c_59 = (bitcast<u32>((scratch_0[params_0.pc_base_0 + _S1054].x)));
                    e_10 = _S1055;
                    loop
                    {
                        if(e_10 < index_0[i_40 + u32(1)])
                        {
                        }
                        else
                        {
                            break;
                        }
                        var entry_9 : u32 = index_0[e_10];
                        var bond_2 : u32 = (entry_9 >> (u32(1)));
                        var _S1056 : JointState_std430_0 = bond_dyn_0[bond_2].js_0;
                        var _S1057 : bool = connected_2(&(_S1056), (bonds_0[bond_2].law_0.stiff1_0.w) != 0.0f);
                        if(!_S1057)
                        {
                            e_10 = e_10 + u32(1);
                            continue;
                        }
                        if(((entry_9 & (u32(1)))) == u32(0))
                        {
                            other_1 = bonds_0[bond_2].law_0.ids_0.z;
                        }
                        else
                        {
                            other_1 = bonds_0[bond_2].law_0.ids_0.y;
                        }
                        c_59 = min(c_59, (bitcast<u32>((scratch_0[params_0.pc_base_0 + u32(2) * other_1].x))));
                        e_10 = e_10 + u32(1);
                    }
                    var _S1058 : u32 = min(c_59, (bitcast<u32>((scratch_0[params_0.pc_base_0 + u32(2) * c_59].x))));
                    if(_S1058 < (bitcast<u32>((scratch_0[params_0.pc_base_0 + _S1054].x))))
                    {
                        scratch_0[params_0.pc_base_0 + _S1054] = vec4<f32>((bitcast<f32>((_S1058))), 0.0f, 0.0f, 0.0f);
                        g_flag_0 = u32(1);
                    }
                    i_40 = i_40 + u32(256);
                }
                storageBarrier(); textureBarrier(); workgroupBarrier();;
                var changed_0 : bool = g_flag_0 != u32(0);
                storageBarrier(); textureBarrier(); workgroupBarrier();;
                if(!changed_0)
                {
                    break;
                }
                pass_1 = pass_1 + u32(1);
            }
            i_40 = _S1020;
            loop
            {
                if(i_40 < _S1021)
                {
                }
                else
                {
                    break;
                }
                if((((g_mode_0[i_40]) & (u32(32)))) == u32(0))
                {
                    i_40 = i_40 + u32(256);
                    continue;
                }
                var _S1059 : vec4<u32> = islands_0[i_40].range_0;
                var _S1060 : u32 = islands_0[i_40].range_0.x;
                contact_7 = true;
                c_59 = _S1060;
                loop
                {
                    if(c_59 < (_S1059.y))
                    {
                    }
                    else
                    {
                        break;
                    }
                    if(contact_7)
                    {
                        contact_7 = (bitcast<u32>((scratch_0[params_0.pc_base_0 + u32(2) * c_59].x))) == _S1060;
                    }
                    else
                    {
                        contact_7 = false;
                    }
                    c_59 = c_59 + u32(1);
                }
                if(!contact_7)
                {
                    g_mode_0[i_40] = ((g_mode_0[i_40]) | (u32(256)));
                }
                i_40 = i_40 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        if(_S1026)
        {
            g_flag_0 = u32(0);
        }
        workgroupBarrier();
        var _S1061 : u32 = seen_bits_0();
        i_40 = _S1020;
        loop
        {
            if(i_40 < _S1021)
            {
            }
            else
            {
                break;
            }
            var mode_8 : u32 = g_mode_0[i_40];
            if((((g_mode_0[i_40]) & (u32(1)))) == u32(0))
            {
                i_40 = i_40 + u32(256);
                continue;
            }
            var isl_39 : Island_0;
            isl_39.range_0 = islands_0[i_40].range_0;
            isl_39.info_0 = islands_0[i_40].info_0;
            isl_39.com_0 = islands_0[i_40].com_0;
            isl_39.inertia0_0 = islands_0[i_40].inertia0_0;
            isl_39.inertia1_0 = islands_0[i_40].inertia1_0;
            isl_39.inertia2_0 = islands_0[i_40].inertia2_0;
            isl_39.inv0_0 = islands_0[i_40].inv0_0;
            isl_39.inv1_0 = islands_0[i_40].inv1_0;
            isl_39.inv2_0 = islands_0[i_40].inv2_0;
            isl_39.wcom_0 = islands_0[i_40].wcom_0;
            isl_39.winv0_0 = islands_0[i_40].winv0_0;
            isl_39.winv1_0 = islands_0[i_40].winv1_0;
            isl_39.winv2_0 = islands_0[i_40].winv2_0;
            isl_39.rotation_0 = islands_0[i_40].rotation_0;
            isl_39.position_0 = islands_0[i_40].position_0;
            isl_39.position_err_0 = islands_0[i_40].position_err_0;
            isl_39.velocity_0 = islands_0[i_40].velocity_0;
            isl_39.velocity_err_0 = islands_0[i_40].velocity_err_0;
            isl_39.angular_velocity_0 = islands_0[i_40].angular_velocity_0;
            isl_39.done_0 = islands_0[i_40].done_0;
            isl_39.coverage_0 = islands_0[i_40].coverage_0;
            isl_39.wide_groups_0 = islands_0[i_40].wide_groups_0;
            isl_39.done_pad_0 = islands_0[i_40].done_pad_0;
            isl_39.probes_0 = islands_0[i_40].probes_0;
            isl_39.energy_0 = islands_0[i_40].energy_0;
            isl_39.rotation_err_0 = islands_0[i_40].rotation_err_0;
            isl_39.momentum_0 = islands_0[i_40].momentum_0;
            isl_39.momentum_err_0 = islands_0[i_40].momentum_err_0;
            var rg_26 : Rigid_0 = pc_load_rigid_0(i_40);
            if(((mode_8 & (u32(16)))) != u32(0))
            {
                contact_7 = (((isl_39.info_0.x) & (u32(2)))) == u32(0);
            }
            else
            {
                contact_7 = false;
            }
            if(contact_7)
            {
                var at_10 : u32 = params_0.pi_base_0 + u32(16) * i_40;
                drift_rigid_2(isl_39, &(rg_26), scratch_0[at_10 + u32(12)].xyz, scratch_0[at_10 + u32(14)].xyz, scratch_0[at_10 + u32(13)].xyz, scratch_0[at_10 + u32(15)].xyz);
            }
            isl_39.rotation_0 = quat_vec_0(rg_26.rot_1);
            isl_39.rotation_err_0 = rg_26.rot_err_0;
            isl_39.position_0 = vec4<f32>(rg_26.pos_0, 0.0f);
            isl_39.position_err_0 = vec4<f32>(rg_26.pos_err_0, 0.0f);
            isl_39.velocity_0 = vec4<f32>(rg_26.vel_0, 0.0f);
            isl_39.velocity_err_0 = vec4<f32>(rg_26.vel_err_0, 0.0f);
            isl_39.angular_velocity_0 = vec4<f32>(rg_26.w_5, 0.0f);
            isl_39.momentum_0 = vec4<f32>(rg_26.l_1, 0.0f);
            isl_39.momentum_err_0 = vec4<f32>(rg_26.l_err_0, 0.0f);
            if((isl_39.probes_0.y) > (isl_39.probes_0.x))
            {
                record_probes_0(isl_39, rg_26, pc_k_0(isl_39));
            }
            isl_39.done_0 = isl_39.done_0 + u32(1);
            isl_39.info_0[i32(1)] = isl_39.info_0[i32(1)] - u32(1);
            isl_39.info_0[i32(3)] = isl_39.info_0[i32(3)] + u32(1);
            var quiet_3 : bool = (((isl_39.info_0.x) & (u32(32)))) != u32(0);
            var _S1062 : u32 = (_S1061 | (u32(524288)));
            if((((isl_39.info_0.x) & (u32(8)))) != u32(0))
            {
                c_58 = u32(256);
            }
            else
            {
                c_58 = u32(0);
            }
            var _S1063 : u32 = (_S1062 | (c_58));
            if((isl_39.probes_0.y) > (isl_39.probes_0.x))
            {
                pass_1 = u32(262144);
            }
            else
            {
                pass_1 = u32(0);
            }
            var _S1064 : u32 = (_S1063 | (pass_1));
            if(quiet_3)
            {
                c_59 = u32(4096);
            }
            else
            {
                c_59 = u32(0);
            }
            var _S1065 : u32 = (_S1064 | (c_59));
            if(((mode_8 & (u32(128)))) != u32(0))
            {
                _S1019 = ((mode_8 & (u32(64)))) == u32(0);
            }
            else
            {
                _S1019 = false;
            }
            if(_S1019)
            {
                e_10 = u32(512);
            }
            else
            {
                e_10 = u32(0);
            }
            var _S1066 : u32 = (_S1065 | (e_10));
            if(((mode_8 & (u32(32)))) != u32(0))
            {
                other_1 = u32(128);
            }
            else
            {
                other_1 = u32(0);
            }
            var _S1067 : u32 = (_S1066 | (other_1));
            var _S1068 : bool = ((mode_8 & (u32(64)))) != u32(0);
            var _S1069 : u32;
            if(_S1068)
            {
                _S1069 = u32(2048);
            }
            else
            {
                _S1069 = u32(0);
            }
            isl_39.coverage_0 = ((isl_39.coverage_0) | (((_S1067 | (_S1069)))));
            if(_S1068)
            {
                isl_39.info_0[i32(0)] = ((isl_39.info_0[i32(0)]) & (u32(4294967279)));
                isl_39.info_0[i32(2)] = ((isl_39.info_0[i32(2)]) | (u32(4)));
            }
            if(((mode_8 & (u32(256)))) != u32(0))
            {
                contact_split_at_0(isl_39.info_0.w);
                isl_39.info_0[i32(2)] = ((isl_39.info_0[i32(2)]) | (u32(1)));
                g_flag_0 = u32(1);
            }
            islands_0[i_40].range_0 = isl_39.range_0;
            islands_0[i_40].info_0 = isl_39.info_0;
            islands_0[i_40].com_0 = isl_39.com_0;
            islands_0[i_40].inertia0_0 = isl_39.inertia0_0;
            islands_0[i_40].inertia1_0 = isl_39.inertia1_0;
            islands_0[i_40].inertia2_0 = isl_39.inertia2_0;
            islands_0[i_40].inv0_0 = isl_39.inv0_0;
            islands_0[i_40].inv1_0 = isl_39.inv1_0;
            islands_0[i_40].inv2_0 = isl_39.inv2_0;
            islands_0[i_40].wcom_0 = isl_39.wcom_0;
            islands_0[i_40].winv0_0 = isl_39.winv0_0;
            islands_0[i_40].winv1_0 = isl_39.winv1_0;
            islands_0[i_40].winv2_0 = isl_39.winv2_0;
            islands_0[i_40].rotation_0 = isl_39.rotation_0;
            islands_0[i_40].position_0 = isl_39.position_0;
            islands_0[i_40].position_err_0 = isl_39.position_err_0;
            islands_0[i_40].velocity_0 = isl_39.velocity_0;
            islands_0[i_40].velocity_err_0 = isl_39.velocity_err_0;
            islands_0[i_40].angular_velocity_0 = isl_39.angular_velocity_0;
            islands_0[i_40].done_0 = isl_39.done_0;
            islands_0[i_40].coverage_0 = isl_39.coverage_0;
            islands_0[i_40].wide_groups_0 = isl_39.wide_groups_0;
            islands_0[i_40].done_pad_0 = isl_39.done_pad_0;
            islands_0[i_40].probes_0 = isl_39.probes_0;
            islands_0[i_40].energy_0 = isl_39.energy_0;
            islands_0[i_40].rotation_err_0 = isl_39.rotation_err_0;
            islands_0[i_40].momentum_0 = isl_39.momentum_0;
            islands_0[i_40].momentum_err_0 = isl_39.momentum_err_0;
            i_40 = i_40 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(g_flag_0 != u32(0))
        {
            break;
        }
        s_19 = s_19 + u32(1);
    }
    return;
}

