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

fn comp_add1_4( sum_4 : ptr<function, f32>,  err_4 : ptr<function, f32>,  x_12 : f32)
{
    var t_5 : f32 = (*sum_4) + x_12;
    if((abs((*sum_4))) >= (abs(x_12)))
    {
        (*err_4) = (*err_4) + ((*sum_4) - t_5 + x_12);
    }
    else
    {
        (*err_4) = (*err_4) + (x_12 - t_5 + (*sum_4));
    }
    (*sum_4) = t_5;
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
        comp_add1_3(&(_S71), &(_S72), diss_sum_0);
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

fn sphere_contact_0( b_22 : Box_0,  center_4 : vec3<f32>,  radius_0 : f32,  point_0 : ptr<function, vec3<f32>>,  normal_6 : ptr<function, vec3<f32>>,  depth_5 : ptr<function, f32>) -> bool
{
    var _S77 : vec3<f32> = vec3<f32>(0.0f);
    (*point_0) = _S77;
    (*normal_6) = _S77;
    (*depth_5) = 0.0f;
    var r_4 : vec3<f32> = center_4 - b_22.center_1;
    var local_5 : vec3<f32> = vec3<f32>(dot(r_4, b_22.axis0_0), dot(r_4, b_22.axis1_0), dot(r_4, b_22.axis2_0));
    if((b_22.hull_v_0) != u32(0))
    {
        var face_3 : u32;
        var d_10 : f32 = hull_signed_distance_0(b_22, local_5, &(face_3));
        if(d_10 >= radius_0)
        {
            return false;
        }
        var _S78 : vec3<f32> = box_to_world_0(b_22, loads_0[b_22.hull_at_0 + b_22.hull_v_0 + face_3].xyz);
        (*normal_6) = _S78;
        (*point_0) = center_4 - _S78 * vec3<f32>(max(d_10, 0.0f));
        (*depth_5) = radius_0 - d_10;
        return true;
    }
    var q_8 : vec3<f32> = clamp(local_5, (vec3<f32>(0) - b_22.half_2), b_22.half_2);
    var d_11 : vec3<f32> = local_5 - q_8;
    var dist_0 : f32 = length(d_11);
    if(dist_0 > 9.999999960041972e-13f)
    {
        if(dist_0 >= radius_0)
        {
            return false;
        }
        var dn_0 : vec3<f32> = d_11 / vec3<f32>(dist_0);
        (*normal_6) = b_22.axis0_0 * vec3<f32>(dn_0.x) + b_22.axis1_0 * vec3<f32>(dn_0.y) + b_22.axis2_0 * vec3<f32>(dn_0.z);
        (*point_0) = b_22.center_1 + b_22.axis0_0 * vec3<f32>(q_8.x) + b_22.axis1_0 * vec3<f32>(q_8.y) + b_22.axis2_0 * vec3<f32>(q_8.z);
        (*depth_5) = radius_0 - dist_0;
        return true;
    }
    var inside_0 : f32;
    var n_4 : vec3<f32>;
    var _S79 : bool = penetration_0(b_22, center_4, &(inside_0), &(n_4));
    if(!_S79)
    {
        return false;
    }
    (*normal_6) = n_4;
    (*point_0) = center_4 - n_4 * vec3<f32>(min(radius_0, inside_0));
    (*depth_5) = radius_0 + inside_0;
    return true;
}

fn impactor_contact_0( imp_3 : ptr<function, Impactor_std430_0>,  crush_depth_0 : f32,  shrunk_0 : Box_0,  b_23 : Box_0,  j_0 : u32,  p_5 : ptr<function, vec3<f32>>,  n_5 : ptr<function, vec3<f32>>,  d_12 : ptr<function, f32>) -> bool
{
    var _S80 : vec3<f32> = vec3<f32>(0.0f);
    (*p_5) = _S80;
    (*n_5) = _S80;
    (*d_12) = 0.0f;
    var _S81 : vec4<f32> = (*imp_3).shape_0;
    if(((*imp_3).shape_0.x) == 0.0f)
    {
        var _S82 : bool = sphere_contact_0(b_23, _S80, _S81.y - crush_depth_0, &((*p_5)), &((*n_5)), &((*d_12)));
        if(!_S82)
        {
            return false;
        }
        (*n_5) = (vec3<f32>(0) - (*n_5));
        return true;
    }
    var cb_1 : u32 = sample_count_0(b_23);
    if(j_0 < cb_1)
    {
        var _S83 : vec3<f32> = sample_point_0(b_23, j_0);
        (*p_5) = _S83;
        var _S84 : bool = penetration_0(shrunk_0, _S83, &((*d_12)), &((*n_5)));
        return _S84;
    }
    var _S85 : vec3<f32> = sample_point_0(shrunk_0, j_0 - cb_1);
    (*p_5) = _S85;
    var _S86 : bool = penetration_0(b_23, _S85, &((*d_12)), &((*n_5)));
    if(!_S86)
    {
        return false;
    }
    (*n_5) = (vec3<f32>(0) - (*n_5));
    return true;
}

fn impactor_contact_1( imp_4 : ptr<function, Impactor_std430_0>,  crush_depth_1 : f32,  shrunk_1 : Box_0,  b_24 : Box_0,  j_1 : u32,  p_6 : ptr<function, vec3<f32>>,  n_6 : ptr<function, vec3<f32>>,  d_13 : ptr<function, f32>) -> bool
{
    var _S87 : vec3<f32> = vec3<f32>(0.0f);
    (*p_6) = _S87;
    (*n_6) = _S87;
    (*d_13) = 0.0f;
    var _S88 : vec4<f32> = (*imp_4).shape_0;
    if(((*imp_4).shape_0.x) == 0.0f)
    {
        var _S89 : bool = sphere_contact_0(b_24, _S87, _S88.y - crush_depth_1, &((*p_6)), &((*n_6)), &((*d_13)));
        if(!_S89)
        {
            return false;
        }
        (*n_6) = (vec3<f32>(0) - (*n_6));
        return true;
    }
    var cb_2 : u32 = sample_count_0(b_24);
    if(j_1 < cb_2)
    {
        var _S90 : vec3<f32> = sample_point_0(b_24, j_1);
        (*p_6) = _S90;
        var _S91 : bool = penetration_0(shrunk_1, _S90, &((*d_13)), &((*n_6)));
        return _S91;
    }
    var _S92 : vec3<f32> = sample_point_0(shrunk_1, j_1 - cb_2);
    (*p_6) = _S92;
    var _S93 : bool = penetration_0(b_24, _S92, &((*d_13)), &((*n_6)));
    if(!_S93)
    {
        return false;
    }
    (*n_6) = (vec3<f32>(0) - (*n_6));
    return true;
}

fn impactor_point_0( _S94 : u32) -> WorldPoint_0
{
    var wi_0 : WorldPoint_0;
    wi_0.hi_0 = impactors_0[_S94].position_1.xyz;
    wi_0.lo_0 = impactors_0[_S94].position_err_1.xyz;
    wi_0.rel_0 = vec3<f32>(0.0f);
    return wi_0;
}

fn impactor_box_1( _S95 : u32,  _S96 : vec3<f32>,  _S97 : vec3<f32>) -> Box_0
{
    var q_9 : Quat_0 = quat_of_0(impactors_0[_S95].rotation_1);
    var b_25 : Box_0;
    b_25.center_1 = _S96;
    b_25.axis0_0 = rotate_0(q_9, vec3<f32>(1.0f, 0.0f, 0.0f));
    b_25.axis1_0 = rotate_0(q_9, vec3<f32>(0.0f, 1.0f, 0.0f));
    b_25.axis2_0 = rotate_0(q_9, vec3<f32>(0.0f, 0.0f, 1.0f));
    b_25.half_2 = _S97;
    b_25.hull_at_0 = u32(0);
    b_25.hull_v_0 = u32(0);
    b_25.hull_f_0 = u32(0);
    return b_25;
}

fn impactor_shrunk_0( _S98 : u32,  _S99 : f32,  _S100 : Box_0) -> Box_0
{
    var shrunk_2 : Box_0 = _S100;
    shrunk_2.half_2 = _S100.half_2 - min(vec3<f32>(_S99), _S100.half_2 * vec3<f32>(0.5f));
    return shrunk_2;
}

fn impactor_contact_2( _S101 : u32,  _S102 : f32,  _S103 : Box_0,  _S104 : Box_0,  _S105 : u32,  _S106 : ptr<function, vec3<f32>>,  _S107 : ptr<function, vec3<f32>>,  _S108 : ptr<function, f32>) -> bool
{
    var _S109 : Impactor_std430_0 = impactors_0[_S101];
    var _S110 : vec3<f32> = vec3<f32>(0.0f);
    (*_S106) = _S110;
    (*_S107) = _S110;
    (*_S108) = 0.0f;
    if((_S109.shape_0.x) == 0.0f)
    {
        var _S111 : bool = sphere_contact_0(_S104, _S110, _S109.shape_0.y - _S102, &((*_S106)), &((*_S107)), &((*_S108)));
        if(!_S111)
        {
            return false;
        }
        (*_S107) = (vec3<f32>(0) - (*_S107));
        return true;
    }
    var cb_3 : u32 = sample_count_0(_S104);
    if(_S105 < cb_3)
    {
        var _S112 : vec3<f32> = sample_point_0(_S104, _S105);
        (*_S106) = _S112;
        var _S113 : bool = penetration_0(_S103, _S112, &((*_S108)), &((*_S107)));
        return _S113;
    }
    var _S114 : vec3<f32> = sample_point_0(_S103, _S105 - cb_3);
    (*_S106) = _S114;
    var _S115 : bool = penetration_0(_S104, _S114, &((*_S108)), &((*_S107)));
    if(!_S115)
    {
        return false;
    }
    (*_S107) = (vec3<f32>(0) - (*_S107));
    return true;
}

fn impactor_candidate_forces_0( k_8 : u32,  lane_1 : u32,  lanes_5 : u32)
{
    var _S116 : u32;
    var _S117 : bool;
    var _S118 : u32 = u32(3) * k_8;
    var at_1 : u32 = params_0.cand_index_0 + _S118;
    var c_5 : u32 = index_0[at_1];
    var slot_0 : u32 = index_0[at_1 + u32(1)];
    var _S119 : u32 = index_0[at_1 + u32(2)];
    var _S120 : Impactor_std430_0 = impactors_0[_S119];
    var _S121 : f32 = params_0.dt_0;
    var _S122 : vec3<f32> = vec3<f32>(0.0f);
    var data_1 : vec4<f32> = scratch_0[params_0.cand_base_0 + _S118];
    var hit_0 : bool;
    var f_sum_0 : vec3<f32>;
    var t_sum_0 : vec3<f32>;
    var imp_f_0 : vec3<f32>;
    var imp_t_0 : vec3<f32>;
    if((_S120.cand_0.z) == u32(0))
    {
        var rel_1 : vec3<f32> = world_diff_0(chunk_world_0(c_5), impactor_point_0(_S119));
        var _S123 : vec4<f32> = _S120.half_1;
        if(!((length(rel_1)) > (_S120.half_1.w + chunks_0[c_5].half_0.w)))
        {
            var _S124 : Box_0 = impactor_box_1(_S119, _S122, _S123.xyz);
            var b_26 : Box_0 = chunk_box_0(c_5, rel_1);
            var _S125 : vec4<f32> = _S120.mat_0;
            var kc_0 : f32 = contact_stiffness_0(_S120.mat_0.x, _S124, chunks_0[c_5].cmat_0.x, b_26, b_26.center_1 - _S124.center_1);
            var _S126 : vec4<f32> = _S120.geom_0;
            var _S127 : f32 = _S120.geom_0.y;
            var _S128 : Box_0 = impactor_shrunk_0(_S119, _S127, _S124);
            var j_2 : u32 = lane_1;
            var n_7 : u32 = u32(0);
            loop
            {
                var _S129 : u32 = impactor_slots_0(&(_S120), b_26);
                _S116 = _S129;
                if(j_2 < _S129)
                {
                }
                else
                {
                    break;
                }
                var p_7 : vec3<f32>;
                var nrm_0 : vec3<f32>;
                var dep_0 : f32;
                if(impactor_contact_2(_S119, _S127, _S128, b_26, j_2, &(p_7), &(nrm_0), &(dep_0)))
                {
                    n_7 = n_7 + u32(1);
                }
                j_2 = j_2 + lanes_5;
            }
            var n_8 : u32 = pair_count_sum_0(n_7, lanes_5);
            var _S130 : bool = (_S120.shape_0.x) == 0.0f;
            var _S131 : f32;
            if(_S130)
            {
                _S131 = kc_0;
            }
            else
            {
                _S131 = kc_0 / max(f32(n_8), 10.0f);
            }
            if(_S130)
            {
                j_2 = u32(1);
            }
            else
            {
                j_2 = n_8;
            }
            var m_1 : f32 = chunks_0[c_5].center_0.w;
            var _S132 : f32 = _S125.z;
            var _S133 : f32 = m_1 * _S132 / (m_1 + _S132);
            var _S134 : f32;
            if((params_0.pair_friction_0) >= 0.0f)
            {
                _S134 = params_0.pair_friction_0;
            }
            else
            {
                _S134 = min(_S125.y, chunks_0[c_5].cmat_0.y);
            }
            var _S135 : vec3<f32> = _S120.velocity_1.xyz + _S120.velocity_err_1.xyz;
            var vc_0 : vec3<f32>;
            var wc_0 : vec3<f32>;
            chunk_velocity_0(c_5, &(vc_0), &(wc_0));
            hit_0 = false;
            var j_3 : u32 = lane_1;
            f_sum_0 = _S122;
            t_sum_0 = _S122;
            imp_f_0 = _S122;
            imp_t_0 = _S122;
            var diss_sum_2 : f32 = 0.0f;
            loop
            {
                var _S136 : bool = n_8 > u32(0);
                _S117 = _S136;
                var _S137 : bool;
                if(_S136)
                {
                    _S137 = j_3 < _S116;
                }
                else
                {
                    _S137 = false;
                }
                if(_S137)
                {
                }
                else
                {
                    break;
                }
                var p_8 : vec3<f32>;
                var nrm_1 : vec3<f32>;
                var dep_1 : f32;
                var _S138 : bool = impactor_contact_0(&(_S120), _S127, _S128, b_26, j_3, &(p_8), &(nrm_1), &(dep_1));
                if(!_S138)
                {
                    j_3 = j_3 + lanes_5;
                    continue;
                }
                var stored_4 : f32;
                var diss_1 : f32;
                var f_2 : vec3<f32> = penalty_force_1(_S131, _S133, _S134, dep_1 * _S126.x, nrm_1, vc_0 + cross(wc_0, p_8 - b_26.center_1) - (_S135 + cross(_S120.angular_velocity_1.xyz, p_8)), _S121, j_2, &(stored_4), &(diss_1));
                var f_sum_1 : vec3<f32> = f_sum_0 + f_2;
                var t_sum_1 : vec3<f32> = t_sum_0 + cross(p_8 - b_26.center_1, f_2);
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
            var _S139 : vec3<f32> = pair_sum3_0(f_sum_0, lanes_5);
            var _S140 : vec3<f32> = pair_sum3_0(t_sum_0, lanes_5);
            var _S141 : vec3<f32> = pair_sum3_0(imp_f_0, lanes_5);
            var _S142 : vec3<f32> = pair_sum3_0(imp_t_0, lanes_5);
            var diss_sum_4 : f32 = pair_sum_0(diss_sum_2, lanes_5);
            var _S143 : bool = pair_any_0(hit_0, lanes_5);
            if(_S117)
            {
                var _S144 : f32 = data_1[i32(2)];
                var _S145 : f32 = data_1[i32(3)];
                comp_add1_3(&(_S144), &(_S145), diss_sum_4);
                data_1[i32(2)] = _S144;
                data_1[i32(3)] = _S145;
            }
            hit_0 = _S143;
            f_sum_0 = _S139;
            t_sum_0 = _S140;
            imp_f_0 = _S141;
            imp_t_0 = _S142;
        }
        else
        {
            hit_0 = false;
            f_sum_0 = _S122;
            t_sum_0 = _S122;
            imp_f_0 = _S122;
            imp_t_0 = _S122;
        }
    }
    else
    {
        hit_0 = false;
        f_sum_0 = _S122;
        t_sum_0 = _S122;
        imp_f_0 = _S122;
        imp_t_0 = _S122;
    }
    if(lane_1 != u32(0))
    {
        return;
    }
    var _S146 : u32 = u32(2) * slot_0;
    scratch_0[params_0.slot_base_0 + _S146] = vec4<f32>(f_sum_0, 0.0f);
    scratch_0[params_0.slot_base_0 + _S146 + u32(1)] = vec4<f32>(t_sum_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S118] = data_1;
    scratch_0[params_0.cand_base_0 + _S118 + u32(1)] = vec4<f32>(imp_f_0, 0.0f);
    scratch_0[params_0.cand_base_0 + _S118 + u32(2)] = vec4<f32>(imp_t_0, 0.0f);
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
    var _S147 : vec4<u32> = chunks_0[c_6].cinfo_0;
    if((chunks_0[c_6].cinfo_0.z) == u32(0))
    {
        return;
    }
    var wp_0 : WorldPoint_0 = chunk_world_0(c_6);
    var _S148 : vec4<f32> = chunks_0[c_6].start_hi_0;
    var moved_0 : vec3<f32> = wp_0.hi_0 - chunks_0[c_6].start_hi_0.xyz + (wp_0.lo_0 - chunks_0[c_6].start_lo_0.xyz) + wp_0.rel_0;
    var _S149 : u32 = chunks_0[c_6].info_1.y;
    var _S150 : vec3<f32> = vec3<f32>((params_0.t_hi_0 - chunks_0[c_6].start_vel_0.w + (params_0.t_lo_0 - chunks_0[c_6].start_lo_0.w) + f32(islands_0[_S149].info_0.w - params_0.step_start_0) * params_0.dt_0));
    var _S151 : vec3<f32> = chunks_0[c_6].start_vel_0.xyz * _S150;
    var _S152 : u32 = _S147.w;
    var _S153 : vec3<f32>;
    if(((_S152 & (u32(2)))) != u32(0))
    {
        _S153 = vec3<f32>(0.5f) * params_0.gravity_0.xyz * _S150 * _S150;
    }
    else
    {
        _S153 = vec3<f32>(0.0f);
    }
    var travel_0 : f32 = length(moved_0 - (_S151 + _S153));
    var travel_1 : f32;
    if(((_S152 & (u32(1)))) != u32(0))
    {
        var th_1 : vec3<f32> = state_0[u32(4) * c_6 + u32(1)].xyz;
        var turn_0 : Quat_0 = quat_mul_0(quat_of_0(vec4<f32>((vec3<f32>(0) - chunks_0[c_6].start_rot_0.xyz), chunks_0[c_6].start_rot_0.w)), quat_mul_0(quat_of_0(islands_0[_S149].rotation_0), from_axis_angle_0(th_1, length(th_1))));
        travel_1 = travel_0 + 2.0f * atan2(length(vec3<f32>(turn_0.x_3, turn_0.y_2, turn_0.z_0)), abs(turn_0.w_0)) * chunks_0[c_6].half_0.w;
    }
    else
    {
        travel_1 = travel_0;
    }
    if(travel_1 > (_S148.w))
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
            var _S154 : u32 = i_3 / lanes_6;
            var _S155 : u32 = i_3 % lanes_6;
            pair_contact_0(_S154, _S155, lanes_6);
        }
        return;
    }
    var j_4 : u32 = i_3 - pair_threads_0;
    var cand_threads_0 : u32 = params_0.cand_count_0 * lanes_6;
    if(j_4 < cand_threads_0)
    {
        if(!pair_any_0(stopped_0(), lanes_6))
        {
            var _S156 : u32 = j_4 / lanes_6;
            var _S157 : u32 = j_4 % lanes_6;
            impactor_candidate_forces_0(_S156, _S157, lanes_6);
        }
        return;
    }
    var _S158 : u32 = j_4 - cand_threads_0;
    var _S159 : bool;
    if(_S158 < (params_0.chunk_count_0))
    {
        _S159 = !stopped_0();
    }
    else
    {
        _S159 = false;
    }
    if(_S159)
    {
        travel_check_0(_S158);
    }
    return;
}

fn impactor_contact_count_0( _S160 : u32,  _S161 : f32,  _S162 : Box_0,  _S163 : Box_0) -> u32
{
    var _S164 : Impactor_std430_0 = impactors_0[_S160];
    var j_5 : u32 = u32(0);
    var count_1 : u32 = u32(0);
    loop
    {
        var _S165 : u32 = impactor_slots_0(&(_S164), _S163);
        if(j_5 < _S165)
        {
        }
        else
        {
            break;
        }
        var p_9 : vec3<f32>;
        var n_9 : vec3<f32>;
        var d_14 : f32;
        if(impactor_contact_2(_S160, _S161, _S162, _S163, j_5, &(p_9), &(n_9), &(d_14)))
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
    var _S166 : bool;
    if(k_9 >= (params_0.cand_count_0))
    {
        _S166 = true;
    }
    else
    {
        _S166 = stopped_0();
    }
    if(_S166)
    {
        return;
    }
    var _S167 : u32 = u32(3) * k_9;
    var at_2 : u32 = params_0.cand_index_0 + _S167;
    var c_7 : u32 = index_0[at_2];
    var _S168 : u32 = index_0[at_2 + u32(2)];
    var _S169 : Impactor_std430_0 = impactors_0[_S168];
    if((_S169.cand_0.z) == u32(0))
    {
        _S166 = (_S169.crush_0.x) > 0.0f;
    }
    else
    {
        _S166 = false;
    }
    var total_0 : f32;
    var ksum_0 : f32;
    if(_S166)
    {
        var rel_2 : vec3<f32> = world_diff_0(chunk_world_0(c_7), impactor_point_0(_S168));
        var _S170 : vec4<f32> = _S169.half_1;
        if(!((length(rel_2)) > (_S169.half_1.w + chunks_0[c_7].half_0.w)))
        {
            var _S171 : Box_0 = impactor_box_1(_S168, vec3<f32>(0.0f), _S170.xyz);
            var b_27 : Box_0 = chunk_box_0(c_7, rel_2);
            var kc_1 : f32 = contact_stiffness_0(_S169.mat_0.x, _S171, chunks_0[c_7].cmat_0.x, b_27, b_27.center_1 - _S171.center_1);
            var _S172 : f32 = _S169.crush_0.w;
            var _S173 : Box_0 = impactor_shrunk_0(_S168, _S172, _S171);
            var _S174 : u32 = impactor_contact_count_0(_S168, _S172, _S173, b_27);
            var _S175 : f32;
            if((_S169.shape_0.x) == 0.0f)
            {
                _S175 = kc_1;
            }
            else
            {
                _S175 = kc_1 / max(f32(_S174), 10.0f);
            }
            var j_6 : u32 = u32(0);
            total_0 = 0.0f;
            ksum_0 = 0.0f;
            loop
            {
                if(_S174 > u32(0))
                {
                    var _S176 : u32 = impactor_slots_1(&(_S169), b_27);
                    _S166 = j_6 < _S176;
                }
                else
                {
                    _S166 = false;
                }
                if(_S166)
                {
                }
                else
                {
                    break;
                }
                var p_10 : vec3<f32>;
                var nrm_2 : vec3<f32>;
                var dep_2 : f32;
                var _S177 : bool = impactor_contact_1(&(_S169), _S172, _S173, b_27, j_6, &(p_10), &(nrm_2), &(dep_2));
                if(!_S177)
                {
                    j_6 = j_6 + u32(1);
                    continue;
                }
                var ksum_1 : f32 = ksum_0 + _S175;
                total_0 = total_0 + _S175 * dep_2;
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
    scratch_0[params_0.cand_base_0 + _S167] = vec4<f32>(total_0, ksum_0, scratch_0[params_0.cand_base_0 + _S167].z, scratch_0[params_0.cand_base_0 + _S167].w);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_crush(@builtin(workgroup_id) group_0 : vec3<u32>, @builtin(local_invocation_id) thread_0 : vec3<u32>)
{
    var ii_0 : u32 = group_0.x;
    var tid_6 : u32 = thread_0.x;
    var _S178 : bool;
    if(ii_0 >= (params_0.impactor_count_0))
    {
        _S178 = true;
    }
    else
    {
        _S178 = stopped_0();
    }
    if(_S178)
    {
        return;
    }
    var imp_5 : Impactor_0;
    imp_5.position_1 = impactors_0[ii_0].position_1;
    imp_5.position_err_1 = impactors_0[ii_0].position_err_1;
    imp_5.velocity_1 = impactors_0[ii_0].velocity_1;
    imp_5.velocity_err_1 = impactors_0[ii_0].velocity_err_1;
    imp_5.angular_velocity_1 = impactors_0[ii_0].angular_velocity_1;
    imp_5.rotation_1 = impactors_0[ii_0].rotation_1;
    imp_5.inertia0_2 = impactors_0[ii_0].inertia0_2;
    imp_5.inertia1_2 = impactors_0[ii_0].inertia1_2;
    imp_5.inertia2_2 = impactors_0[ii_0].inertia2_2;
    imp_5.inv0_2 = impactors_0[ii_0].inv0_2;
    imp_5.inv1_2 = impactors_0[ii_0].inv1_2;
    imp_5.inv2_2 = impactors_0[ii_0].inv2_2;
    imp_5.shape_0 = impactors_0[ii_0].shape_0;
    imp_5.half_1 = impactors_0[ii_0].half_1;
    imp_5.mat_0 = impactors_0[ii_0].mat_0;
    imp_5.crush_0 = impactors_0[ii_0].crush_0;
    imp_5.geom_0 = impactors_0[ii_0].geom_0;
    imp_5.rotation_err_1 = impactors_0[ii_0].rotation_err_1;
    imp_5.ledger_0 = impactors_0[ii_0].ledger_0;
    imp_5.cand_0 = impactors_0[ii_0].cand_0;
    imp_5.momentum_1 = impactors_0[ii_0].momentum_1;
    imp_5.momentum_err_1 = impactors_0[ii_0].momentum_err_1;
    var _S179 : vec4<f32> = vec4<f32>(0.0f);
    var shares_0 : vec4<f32> = _S179;
    var unused_0 : vec4<f32> = _S179;
    var k_10 : u32 = imp_5.cand_0.x + tid_6;
    loop
    {
        if(k_10 < (imp_5.cand_0.y))
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
        _S178 = true;
    }
    else
    {
        _S178 = (imp_5.cand_0.z) != u32(0);
    }
    if(_S178)
    {
        return;
    }
    imp_5.geom_0 = vec4<f32>(1.0f, imp_5.crush_0.w, 0.0f, 0.0f);
    var total_1 : f32 = shares_0.x;
    if((imp_5.crush_0.x) > 0.0f)
    {
        _S178 = (imp_5.crush_0.z) < (imp_5.crush_0.y);
    }
    else
    {
        _S178 = false;
    }
    if(_S178)
    {
        _S178 = total_1 > (imp_5.crush_0.x);
    }
    else
    {
        _S178 = false;
    }
    if(_S178)
    {
        var extra_0 : f32 = (total_1 - imp_5.crush_0.x) / shares_0.y;
        imp_5.crush_0[i32(3)] = imp_5.crush_0[i32(3)] + extra_0;
        imp_5.crush_0[i32(2)] = imp_5.crush_0[i32(2)] + imp_5.crush_0.x * extra_0;
        var _S180 : f32 = imp_5.crush_0.x * extra_0;
        var _S181 : f32 = imp_5.ledger_0[i32(2)];
        var _S182 : f32 = imp_5.ledger_0[i32(3)];
        comp_add1_4(&(_S181), &(_S182), _S180);
        imp_5.ledger_0[i32(2)] = _S181;
        imp_5.ledger_0[i32(3)] = _S182;
        var _S183 : f32 = imp_5.crush_0.x * extra_0;
        var _S184 : f32 = imp_5.ledger_0[i32(0)];
        var _S185 : f32 = imp_5.ledger_0[i32(1)];
        comp_add1_4(&(_S184), &(_S185), _S183);
        imp_5.ledger_0[i32(0)] = _S184;
        imp_5.ledger_0[i32(1)] = _S185;
        imp_5.geom_0[i32(0)] = imp_5.crush_0.x / total_1;
    }
    impactors_0[ii_0].position_1 = imp_5.position_1;
    impactors_0[ii_0].position_err_1 = imp_5.position_err_1;
    impactors_0[ii_0].velocity_1 = imp_5.velocity_1;
    impactors_0[ii_0].velocity_err_1 = imp_5.velocity_err_1;
    impactors_0[ii_0].angular_velocity_1 = imp_5.angular_velocity_1;
    impactors_0[ii_0].rotation_1 = imp_5.rotation_1;
    impactors_0[ii_0].inertia0_2 = imp_5.inertia0_2;
    impactors_0[ii_0].inertia1_2 = imp_5.inertia1_2;
    impactors_0[ii_0].inertia2_2 = imp_5.inertia2_2;
    impactors_0[ii_0].inv0_2 = imp_5.inv0_2;
    impactors_0[ii_0].inv1_2 = imp_5.inv1_2;
    impactors_0[ii_0].inv2_2 = imp_5.inv2_2;
    impactors_0[ii_0].shape_0 = imp_5.shape_0;
    impactors_0[ii_0].half_1 = imp_5.half_1;
    impactors_0[ii_0].mat_0 = imp_5.mat_0;
    impactors_0[ii_0].crush_0 = imp_5.crush_0;
    impactors_0[ii_0].geom_0 = imp_5.geom_0;
    impactors_0[ii_0].rotation_err_1 = imp_5.rotation_err_1;
    impactors_0[ii_0].ledger_0 = imp_5.ledger_0;
    impactors_0[ii_0].cand_0 = imp_5.cand_0;
    impactors_0[ii_0].momentum_1 = imp_5.momentum_1;
    impactors_0[ii_0].momentum_err_1 = imp_5.momentum_err_1;
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
    var _S186 : u32 = table_0 + u32(4) * g_0;
    w_4.island_2 = index_0[_S186];
    w_4.begin_0 = index_0[_S186 + u32(1)];
    w_4.end_0 = index_0[_S186 + u32(2)];
    w_4.first_0 = index_0[_S186 + u32(3)];
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
            _S188 = _S189 <= ((*isl_0).info_0.w);
        }
        else
        {
            _S188 = false;
        }
    }
    return _S188;
}

fn contact_stopped_1( isl_1 : ptr<function, Island_std430_0>) -> bool
{
    var _S190 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S191 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S191 = true;
    }
    else
    {
        var _S192 : u32 = _S190.y;
        if(_S192 != u32(0))
        {
            _S191 = _S192 <= ((*isl_1).info_0.w);
        }
        else
        {
            _S191 = false;
        }
    }
    return _S191;
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
    var _S193 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S194 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S194 = true;
    }
    else
    {
        var _S195 : u32 = _S193.y;
        if(_S195 != u32(0))
        {
            _S194 = _S195 <= (isl_2.info_0.w);
        }
        else
        {
            _S194 = false;
        }
    }
    return _S194;
}

fn wide_runs_0( isl_3 : ptr<function, Island_std430_0>) -> bool
{
    var _S196 : vec4<u32> = (*isl_3).info_0;
    var _S197 : bool;
    if(((((*isl_3).info_0.z) & (u32(1)))) != u32(0))
    {
        _S197 = true;
    }
    else
    {
        _S197 = (_S196.y) == u32(0);
    }
    if(_S197)
    {
        return false;
    }
    if((((_S196.x) & (u32(4)))) == u32(0))
    {
        _S197 = true;
    }
    else
    {
        var _S198 : bool = contact_stopped_0(&((*isl_3)));
        _S197 = !_S198;
    }
    return _S197;
}

fn wide_runs_1( isl_4 : ptr<function, Island_std430_0>) -> bool
{
    var _S199 : vec4<u32> = (*isl_4).info_0;
    var _S200 : bool;
    if(((((*isl_4).info_0.z) & (u32(1)))) != u32(0))
    {
        _S200 = true;
    }
    else
    {
        _S200 = (_S199.y) == u32(0);
    }
    if(_S200)
    {
        return false;
    }
    if((((_S199.x) & (u32(4)))) == u32(0))
    {
        _S200 = true;
    }
    else
    {
        var _S201 : bool = contact_stopped_1(&((*isl_4)));
        _S200 = !_S201;
    }
    return _S200;
}

var<workgroup> g_wide_run_0 : u32;

fn wide_enter_0( tid_8 : u32,  isl_5 : ptr<function, Island_std430_0>) -> bool
{
    seen_clear_0(tid_8);
    if(tid_8 == u32(0))
    {
        var _S202 : bool = wide_runs_1(&((*isl_5)));
        var _S203 : i32;
        if(_S202)
        {
            _S203 = i32(1);
        }
        else
        {
            _S203 = i32(0);
        }
        g_wide_run_0 = u32(_S203);
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
        var _S204 : u32 = offset_0 + i_4;
        var b_28 : vec4<f32> = loads_0[_S204];
        var _S205 : f32 = b_28.x;
        if(tau_0 <= _S205)
        {
            var a_11 : vec4<f32> = loads_0[_S204 - u32(1)];
            var _S206 : f32 = a_11.x;
            var _S207 : f32 = a_11.y;
            return _S207 + (tau_0 - _S206) / max(_S205 - _S206, 1.00000000317107685e-30f) * (b_28.y - _S207);
        }
        i_4 = i_4 + u32(1);
    }
    return loads_0[offset_0 + count_2 - u32(1)].y;
}

fn eval_function_0( term_0 : u32,  k_12 : u32,  dt_5 : f32,  shift_0 : f32) -> f32
{
    var _S208 : u32 = u32(5) * term_0;
    var info_2 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[_S208])));
    var origin_1 : vec4<f32> = loads_0[_S208 + u32(3)];
    var p_11 : vec4<f32> = loads_0[_S208 + u32(4)];
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
            var _S209 : f32 = p_11.x;
            if(tau_1 >= _S209)
            {
                shape_1 = p_11.y;
            }
            else
            {
                shape_1 = p_11.y * tau_1 / _S209;
            }
        }
        return shape_1;
    }
    var _S210 : bool;
    if(kind_0 == u32(2))
    {
        if(tau_1 < 0.0f)
        {
            _S210 = true;
        }
        else
        {
            _S210 = tau_1 > (p_11.x);
        }
        if(_S210)
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
            _S210 = true;
        }
        else
        {
            _S210 = sn_0 > 1.0f;
        }
        if(_S210)
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
            _S210 = true;
        }
        else
        {
            _S210 = sn_1 > 1.0f;
        }
        if(_S210)
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
        var _S211 : f32 = p_11.w;
        return (_S211 + (p_11.z - _S211) * relax_0) * shape_1;
    }
    if(kind_0 == u32(7))
    {
        g_seen_0[u32(2)] = u32(1);
        if(tau_1 < 0.0f)
        {
            return 0.0f;
        }
        var _S212 : f32 = p_11.y;
        if(tau_1 < _S212)
        {
            return p_11.x;
        }
        var s_5 : f32 = tau_1 - _S212;
        var _S213 : f32 = p_11.w;
        if(s_5 > _S213)
        {
            shape_1 = 0.0f;
        }
        else
        {
            shape_1 = p_11.z * sin(3.14159274101257324f * s_5 / _S213);
        }
        return shape_1;
    }
    var _S214 : f32 = p_11.x;
    if(_S214 <= 0.0f)
    {
        return 0.0f;
    }
    return clamp(1.0f - tau_1 / _S214, 0.0f, 1.0f);
}

fn record_chunk_load_0( c_8 : u32,  f_3 : vec3<f32>,  t_6 : vec3<f32>)
{
    if((params_0.solve_mode_0) == u32(0))
    {
        return;
    }
    var _S215 : u32 = u32(2) * c_8;
    scratch_0[params_0.cload_base_0 + _S215] = vec4<f32>(f_3, 0.0f);
    scratch_0[params_0.cload_base_0 + _S215 + u32(1)] = vec4<f32>(t_6, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S215] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S215].xyz + f_3, 0.0f);
    scratch_0[params_0.cframe_base_0 + _S215 + u32(1)] = vec4<f32>(scratch_0[params_0.cframe_base_0 + _S215 + u32(1)].xyz + t_6, 0.0f);
    return;
}

fn chunk_loads_0( _S216 : u32,  _S217 : u32,  _S218 : Quat_0,  _S219 : u32,  _S220 : f32,  _S221 : bool,  _S222 : f32,  _S223 : ptr<function, vec3<f32>>,  _S224 : ptr<function, vec3<f32>>,  _S225 : ptr<function, vec3<f32>>,  _S226 : ptr<function, vec3<f32>>)
{
    var _S227 : bool;
    var _S228 : vec3<f32> = vec3<f32>(0.0f);
    (*_S223) = _S228;
    (*_S224) = _S228;
    (*_S225) = _S228;
    (*_S226) = _S228;
    var _S229 : vec4<u32> = chunks_0[_S217].load_range_0;
    var term_1 : u32 = chunks_0[_S217].load_range_0.x;
    loop
    {
        if(term_1 < (_S229.y))
        {
        }
        else
        {
            break;
        }
        g_seen_0[u32(0)] = u32(1);
        var _S230 : u32 = u32(5) * term_1;
        var _S231 : u32 = (bitcast<vec4<u32>>((loads_0[_S230]))).y;
        var replacement_0 : bool = _S231 == u32(2);
        var dir_1 : vec4<f32> = loads_0[_S230 + u32(1)];
        var arm_0 : vec4<f32> = loads_0[_S230 + u32(2)];
        var _S232 : f32;
        if(replacement_0)
        {
            _S232 = _S222;
        }
        else
        {
            _S232 = 0.0f;
        }
        var value_0 : f32 = eval_function_0(term_1, _S219, _S220, _S232);
        if(replacement_0)
        {
            var _S233 : vec3<f32> = vec3<f32>(value_0);
            (*_S225) = (*_S225) + dir_1.xyz * _S233;
            (*_S226) = (*_S226) + arm_0.xyz * _S233;
            term_1 = term_1 + u32(1);
            continue;
        }
        if(_S231 == u32(0))
        {
            _S227 = true;
        }
        else
        {
            _S227 = _S231 == u32(3);
        }
        var fw_0 : vec3<f32>;
        if(_S227)
        {
            fw_0 = dir_1.xyz * vec3<f32>(value_0);
        }
        else
        {
            fw_0 = rotate_0(_S218, dir_1.xyz) * vec3<f32>((- value_0 * dir_1.w));
        }
        var lever_0 : vec3<f32>;
        if(_S231 == u32(3))
        {
            lever_0 = arm_0.xyz - state_0[u32(4) * _S216].xyz;
        }
        else
        {
            lever_0 = arm_0.xyz;
        }
        (*_S223) = (*_S223) + fw_0;
        (*_S224) = (*_S224) + cross(rotate_0(_S218, lever_0), fw_0);
        term_1 = term_1 + u32(1);
    }
    if(_S221)
    {
        _S227 = (chunks_0[_S217].cinfo_0.z) != u32(0);
    }
    else
    {
        _S227 = false;
    }
    if(_S227)
    {
        var _S234 : vec4<u32> = chunks_0[_S217].cinfo_0;
        var g_1 : u32 = chunks_0[_S217].cinfo_0.x;
        loop
        {
            if(g_1 < (_S234.y))
            {
            }
            else
            {
                break;
            }
            var _S235 : u32 = u32(2) * g_1;
            (*_S223) = (*_S223) + scratch_0[params_0.seg_base_0 + _S235].xyz;
            (*_S224) = (*_S224) + scratch_0[params_0.seg_base_0 + _S235 + u32(1)].xyz;
            g_1 = g_1 + u32(1);
        }
    }
    return;
}

fn chunk_external_0( _S236 : u32,  _S237 : u32,  _S238 : Quat_0,  _S239 : u32,  _S240 : f32,  _S241 : bool,  _S242 : ptr<function, vec3<f32>>,  _S243 : ptr<function, vec3<f32>>)
{
    var rf_0 : vec3<f32>;
    var rm_0 : vec3<f32>;
    chunk_loads_0(_S236, _S237, _S238, _S239, _S240, _S241, 0.0f, &((*_S242)), &((*_S243)), &(rf_0), &(rm_0));
    return;
}

fn settled_chunk_load_0( c_9 : u32,  rot_0 : Quat_0,  k_13 : u32,  dt_6 : f32,  contact_0 : bool) -> f32
{
    var f_4 : vec3<f32>;
    var t_7 : vec3<f32>;
    chunk_external_0(c_9, c_9, rot_0, k_13, dt_6, contact_0, &(f_4), &(t_7));
    record_chunk_load_0(c_9, f_4, t_7);
    return length(f_4);
}

fn seen_bits_0() -> u32
{
    var _S244 : u32;
    if((g_seen_0[u32(0)]) != u32(0))
    {
        _S244 = u32(32768);
    }
    else
    {
        _S244 = u32(0);
    }
    var _S245 : u32;
    if((g_seen_0[u32(1)]) != u32(0))
    {
        _S245 = u32(65536);
    }
    else
    {
        _S245 = u32(0);
    }
    var _S246 : u32 = (_S244 | (_S245));
    if((g_seen_0[u32(2)]) != u32(0))
    {
        _S244 = u32(131072);
    }
    else
    {
        _S244 = u32(0);
    }
    var _S247 : u32 = (_S246 | (_S244));
    if((g_seen_0[u32(3)]) != u32(0))
    {
        _S244 = u32(32);
    }
    else
    {
        _S244 = u32(0);
    }
    var _S248 : u32 = (_S247 | (_S244));
    if((g_seen_0[u32(4)]) != u32(0))
    {
        _S244 = u32(64);
    }
    else
    {
        _S244 = u32(0);
    }
    return (_S248 | (_S244));
}

fn wide_enter_1( _S249 : u32,  _S250 : u32) -> bool
{
    var _S251 : Island_std430_0 = islands_0[_S250];
    seen_clear_0(_S249);
    if(_S249 == u32(0))
    {
        var _S252 : bool = wide_runs_0(&(_S251));
        var _S253 : i32;
        if(_S252)
        {
            _S253 = i32(1);
        }
        else
        {
            _S253 = i32(0);
        }
        g_wide_run_0 = u32(_S253);
    }
    workgroupBarrier();
    return g_wide_run_0 != u32(0);
}

@compute
@workgroup_size(256, 1, 1)
fn wide_wake(@builtin(workgroup_id) group_1 : vec3<u32>, @builtin(local_invocation_id) thread_1 : vec3<u32>)
{
    var tid_9 : u32 = thread_1.x;
    var _S254 : u32 = group_1.x;
    var wg_0 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S254);
    if(_S254 != (wg_0.first_0))
    {
        return;
    }
    var _S255 : Island_std430_0 = islands_0[wg_0.island_2];
    var _S256 : vec4<u32> = _S255.info_0;
    var _S257 : u32 = _S255.info_0.x;
    var _S258 : bool;
    if(((_S257 & (u32(16)))) == u32(0))
    {
        _S258 = true;
    }
    else
    {
        var _S259 : bool = wide_enter_1(tid_9, wg_0.island_2);
        _S258 = !_S259;
    }
    if(_S258)
    {
        return;
    }
    var _S260 : Quat_0 = quat_of_0(_S255.rotation_0);
    var _S261 : bool = ((_S257 & (u32(4)))) != u32(0);
    var _S262 : vec3<f32> = vec3<f32>(0.0f);
    var norm_0 : vec3<f32> = _S262;
    var unused_1 : vec3<f32> = _S262;
    var _S263 : vec4<u32> = _S255.range_0;
    var c_10 : u32 = _S255.range_0.x + tid_9;
    loop
    {
        if(c_10 < (_S263.y))
        {
        }
        else
        {
            break;
        }
        var _S264 : u32 = wide_step_1(&(_S255));
        var _S265 : f32 = settled_chunk_load_0(c_10, _S260, _S264, params_0.dt_0, _S261);
        norm_0[i32(0)] = norm_0[i32(0)] + _S265;
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
        _S258 = (abs(norm_0.x - _S255.energy_0.z)) > (_S255.energy_0.w);
    }
    else
    {
        _S258 = false;
    }
    var cov_1 : u32;
    if(_S258)
    {
        islands_0[wg_0.island_2].info_0[i32(0)] = (_S257 & (u32(4294967279)));
        islands_0[wg_0.island_2].info_0[i32(2)] = ((_S256.z) | (u32(4)));
        cov_1 = (cov_0 | (u32(2048)));
    }
    else
    {
        cov_1 = cov_0;
    }
    cov_mark_0(wg_0.island_2, _S255.coverage_0, cov_1);
    return;
}

fn wide_partials_0( tid_10 : u32,  first_2 : u32,  count_3 : u32,  p_12 : u32,  a_12 : ptr<function, vec3<f32>>,  b_29 : ptr<function, vec3<f32>>)
{
    var _S266 : vec4<f32> = vec4<f32>(0.0f);
    var x_13 : vec4<f32> = _S266;
    var y_3 : vec4<f32> = _S266;
    var s_6 : u32 = tid_10;
    loop
    {
        if(s_6 < count_3)
        {
        }
        else
        {
            break;
        }
        var _S267 : u32 = u32(8) * (first_2 + s_6);
        x_13 = x_13 + scratch_0[params_0.wide_base_0 + _S267 + p_12];
        y_3 = y_3 + scratch_0[params_0.wide_base_0 + _S267 + p_12 + u32(1)];
        s_6 = s_6 + u32(256);
    }
    group_sum2_0(tid_10, &(x_13), &(y_3));
    (*a_12) = x_13.xyz;
    (*b_29) = y_3.xyz;
    return;
}

fn wide_partials_1( tid_11 : u32,  first_3 : u32,  count_4 : u32,  p_13 : u32,  a_13 : ptr<function, vec3<f32>>,  b_30 : ptr<function, vec3<f32>>)
{
    var _S268 : vec4<f32> = vec4<f32>(0.0f);
    var x_14 : vec4<f32> = _S268;
    var y_4 : vec4<f32> = _S268;
    var s_7 : u32 = tid_11;
    loop
    {
        if(s_7 < count_4)
        {
        }
        else
        {
            break;
        }
        var _S269 : u32 = u32(8) * (first_3 + s_7);
        x_14 = x_14 + scratch_0[params_0.wide_base_0 + _S269 + p_13];
        y_4 = y_4 + scratch_0[params_0.wide_base_0 + _S269 + p_13 + u32(1)];
        s_7 = s_7 + u32(256);
    }
    group_sum2_1(tid_11, &(x_14), &(y_4));
    (*a_13) = x_14.xyz;
    (*b_30) = y_4.xyz;
    return;
}

fn rows_mul_0( r0_0 : vec4<f32>,  r1_0 : vec4<f32>,  r2_0 : vec4<f32>,  v_5 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(r0_0.xyz, v_5), dot(r1_0.xyz, v_5), dot(r2_0.xyz, v_5));
}

fn drift_angular_0( c_11 : u32,  wcom_1 : vec3<f32>,  tr_0 : vec3<f32>,  dv_0 : vec3<f32>,  lu_0 : ptr<function, vec3<f32>>,  lv_0 : ptr<function, vec3<f32>>)
{
    var r_6 : vec3<f32> = chunks_0[c_11].center_0.xyz - wcom_1;
    var _S270 : u32 = u32(4) * c_11;
    var _S271 : vec3<f32> = vec3<f32>(chunks_0[c_11].center_0.w);
    var _S272 : vec4<f32> = chunks_0[c_11].inertia0_1;
    var _S273 : vec4<f32> = chunks_0[c_11].inertia1_1;
    var _S274 : vec4<f32> = chunks_0[c_11].inertia2_1;
    var _S275 : vec3<f32> = vec3<f32>(chunks_0[c_11].scale_0.x);
    (*lu_0) = (*lu_0) + (cross(r_6, state_0[_S270].xyz - tr_0) * _S271 + rows_mul_0(chunks_0[c_11].inertia0_1, chunks_0[c_11].inertia1_1, chunks_0[c_11].inertia2_1, state_0[_S270 + u32(1)].xyz)) * _S275;
    (*lv_0) = (*lv_0) + (cross(r_6, state_0[_S270 + u32(2)].xyz - dv_0) * _S271 + rows_mul_0(_S272, _S273, _S274, state_0[_S270 + u32(3)].xyz)) * _S275;
    return;
}

fn drift_angular_1( c_12 : u32,  wcom_2 : vec3<f32>,  tr_1 : vec3<f32>,  dv_1 : vec3<f32>,  lu_1 : ptr<function, vec3<f32>>,  lv_1 : ptr<function, vec3<f32>>)
{
    var r_7 : vec3<f32> = chunks_0[c_12].center_0.xyz - wcom_2;
    var _S276 : u32 = u32(4) * c_12;
    var _S277 : vec3<f32> = vec3<f32>(chunks_0[c_12].center_0.w);
    var _S278 : vec4<f32> = chunks_0[c_12].inertia0_1;
    var _S279 : vec4<f32> = chunks_0[c_12].inertia1_1;
    var _S280 : vec4<f32> = chunks_0[c_12].inertia2_1;
    var _S281 : vec3<f32> = vec3<f32>(chunks_0[c_12].scale_0.x);
    (*lu_1) = (*lu_1) + (cross(r_7, state_0[_S276].xyz - tr_1) * _S277 + rows_mul_0(chunks_0[c_12].inertia0_1, chunks_0[c_12].inertia1_1, chunks_0[c_12].inertia2_1, state_0[_S276 + u32(1)].xyz)) * _S281;
    (*lv_1) = (*lv_1) + (cross(r_7, state_0[_S276 + u32(2)].xyz - dv_1) * _S277 + rows_mul_0(_S278, _S279, _S280, state_0[_S276 + u32(3)].xyz)) * _S281;
    return;
}

fn wide_store_0( slot_1 : u32,  p_14 : u32,  a_14 : vec3<f32>,  b_31 : vec3<f32>)
{
    var _S282 : u32 = u32(8) * slot_1;
    scratch_0[params_0.wide_base_0 + _S282 + p_14] = vec4<f32>(a_14, 0.0f);
    scratch_0[params_0.wide_base_0 + _S282 + p_14 + u32(1)] = vec4<f32>(b_31, 0.0f);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_drift(@builtin(workgroup_id) group_2 : vec3<u32>, @builtin(local_invocation_id) thread_2 : vec3<u32>)
{
    var tid_12 : u32 = thread_2.x;
    var _S283 : u32 = group_2.x;
    var wg_1 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S283);
    var isl_9 : Island_std430_0 = islands_0[wg_1.island_2];
    var _S284 : bool;
    if((((islands_0[wg_1.island_2].info_0.x) & (u32(17)))) != u32(0))
    {
        _S284 = true;
    }
    else
    {
        var _S285 : bool = wide_enter_1(tid_12, wg_1.island_2);
        _S284 = !_S285;
    }
    if(_S284)
    {
        return;
    }
    var tu_0 : vec3<f32>;
    var pv_0 : vec3<f32>;
    wide_partials_1(tid_12, wg_1.first_0, isl_9.wide_groups_0, u32(2), &(tu_0), &(pv_0));
    var _S286 : vec3<f32> = vec3<f32>(isl_9.wcom_0.w);
    var tr_2 : vec3<f32> = tu_0 / _S286;
    var dv_2 : vec3<f32> = pv_0 / _S286;
    var _S287 : vec3<f32> = vec3<f32>(0.0f);
    var lu_2 : vec3<f32> = _S287;
    var lv_2 : vec3<f32> = _S287;
    var c_13 : u32 = wg_1.begin_0 + tid_12;
    if(c_13 < (wg_1.end_0))
    {
        drift_angular_1(c_13, isl_9.wcom_0.xyz, tr_2, dv_2, &(lu_2), &(lv_2));
    }
    group_sum3_1(tid_12, &(lu_2), &(lv_2));
    if(tid_12 == u32(0))
    {
        wide_store_0(_S283, u32(4), lu_2, lv_2);
    }
    return;
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
     a_15 : vec3<f32>,
     alpha_0 : vec3<f32>,
};

fn rigid_of_0( isl_10 : ptr<function, Island_std430_0>) -> Rigid_0
{
    var rg_0 : Rigid_0;
    rg_0.rot_1 = quat_of_0((*isl_10).rotation_0);
    rg_0.rot_err_0 = (*isl_10).rotation_err_0;
    rg_0.pos_0 = (*isl_10).position_0.xyz;
    rg_0.pos_err_0 = (*isl_10).position_err_0.xyz;
    rg_0.vel_0 = (*isl_10).velocity_0.xyz;
    rg_0.vel_err_0 = (*isl_10).velocity_err_0.xyz;
    rg_0.w_5 = (*isl_10).angular_velocity_0.xyz;
    rg_0.l_1 = (*isl_10).momentum_0.xyz;
    rg_0.l_err_0 = (*isl_10).momentum_err_0.xyz;
    var _S288 : vec3<f32> = vec3<f32>(0.0f);
    rg_0.torque_0 = _S288;
    rg_0.a_15 = _S288;
    rg_0.alpha_0 = _S288;
    return rg_0;
}

fn rigid_of_1( isl_11 : ptr<function, Island_std430_0>) -> Rigid_0
{
    var rg_1 : Rigid_0;
    rg_1.rot_1 = quat_of_0((*isl_11).rotation_0);
    rg_1.rot_err_0 = (*isl_11).rotation_err_0;
    rg_1.pos_0 = (*isl_11).position_0.xyz;
    rg_1.pos_err_0 = (*isl_11).position_err_0.xyz;
    rg_1.vel_0 = (*isl_11).velocity_0.xyz;
    rg_1.vel_err_0 = (*isl_11).velocity_err_0.xyz;
    rg_1.w_5 = (*isl_11).angular_velocity_0.xyz;
    rg_1.l_1 = (*isl_11).momentum_0.xyz;
    rg_1.l_err_0 = (*isl_11).momentum_err_0.xyz;
    var _S289 : vec3<f32> = vec3<f32>(0.0f);
    rg_1.torque_0 = _S289;
    rg_1.a_15 = _S289;
    rg_1.alpha_0 = _S289;
    return rg_1;
}

fn rigid_of_2( isl_12 : ptr<function, Island_std430_0>) -> Rigid_0
{
    var rg_2 : Rigid_0;
    rg_2.rot_1 = quat_of_0((*isl_12).rotation_0);
    rg_2.rot_err_0 = (*isl_12).rotation_err_0;
    rg_2.pos_0 = (*isl_12).position_0.xyz;
    rg_2.pos_err_0 = (*isl_12).position_err_0.xyz;
    rg_2.vel_0 = (*isl_12).velocity_0.xyz;
    rg_2.vel_err_0 = (*isl_12).velocity_err_0.xyz;
    rg_2.w_5 = (*isl_12).angular_velocity_0.xyz;
    rg_2.l_1 = (*isl_12).momentum_0.xyz;
    rg_2.l_err_0 = (*isl_12).momentum_err_0.xyz;
    var _S290 : vec3<f32> = vec3<f32>(0.0f);
    rg_2.torque_0 = _S290;
    rg_2.a_15 = _S290;
    rg_2.alpha_0 = _S290;
    return rg_2;
}

fn rigid_of_3( isl_13 : Island_0) -> Rigid_0
{
    var rg_3 : Rigid_0;
    rg_3.rot_1 = quat_of_0(isl_13.rotation_0);
    rg_3.rot_err_0 = isl_13.rotation_err_0;
    rg_3.pos_0 = isl_13.position_0.xyz;
    rg_3.pos_err_0 = isl_13.position_err_0.xyz;
    rg_3.vel_0 = isl_13.velocity_0.xyz;
    rg_3.vel_err_0 = isl_13.velocity_err_0.xyz;
    rg_3.w_5 = isl_13.angular_velocity_0.xyz;
    rg_3.l_1 = isl_13.momentum_0.xyz;
    rg_3.l_err_0 = isl_13.momentum_err_0.xyz;
    var _S291 : vec3<f32> = vec3<f32>(0.0f);
    rg_3.torque_0 = _S291;
    rg_3.a_15 = _S291;
    rg_3.alpha_0 = _S291;
    return rg_3;
}

fn inverse_rotate_0( q_10 : Quat_0,  v_6 : vec3<f32>) -> vec3<f32>
{
    var c_14 : Quat_0;
    c_14.w_0 = q_10.w_0;
    c_14.x_3 = - q_10.x_3;
    c_14.y_2 = - q_10.y_2;
    c_14.z_0 = - q_10.z_0;
    return rotate_0(c_14, v_6);
}

fn world_mul_0( q_11 : Quat_0,  r0_1 : vec4<f32>,  r1_1 : vec4<f32>,  r2_1 : vec4<f32>,  v_7 : vec3<f32>) -> vec3<f32>
{
    return rotate_0(q_11, rows_mul_0(r0_1, r1_1, r2_1, inverse_rotate_0(q_11, v_7)));
}

fn rigid_acceleration_0( isl_14 : ptr<function, Island_std430_0>,  rg_4 : ptr<function, Rigid_0>,  f_5 : vec3<f32>,  t_8 : vec3<f32>)
{
    var iw_w_0 : vec3<f32> = world_mul_0((*rg_4).rot_1, (*isl_14).inertia0_0, (*isl_14).inertia1_0, (*isl_14).inertia2_0, (*rg_4).w_5);
    (*rg_4).a_15 = f_5 / vec3<f32>((*isl_14).com_0.w);
    (*rg_4).alpha_0 = world_mul_0((*rg_4).rot_1, (*isl_14).inv0_0, (*isl_14).inv1_0, (*isl_14).inv2_0, t_8 - cross((*rg_4).w_5, iw_w_0));
    (*rg_4).torque_0 = t_8;
    return;
}

fn rigid_acceleration_1( isl_15 : ptr<function, Island_std430_0>,  rg_5 : ptr<function, Rigid_0>,  f_6 : vec3<f32>,  t_9 : vec3<f32>)
{
    var iw_w_1 : vec3<f32> = world_mul_0((*rg_5).rot_1, (*isl_15).inertia0_0, (*isl_15).inertia1_0, (*isl_15).inertia2_0, (*rg_5).w_5);
    (*rg_5).a_15 = f_6 / vec3<f32>((*isl_15).com_0.w);
    (*rg_5).alpha_0 = world_mul_0((*rg_5).rot_1, (*isl_15).inv0_0, (*isl_15).inv1_0, (*isl_15).inv2_0, t_9 - cross((*rg_5).w_5, iw_w_1));
    (*rg_5).torque_0 = t_9;
    return;
}

fn rigid_acceleration_2( isl_16 : Island_0,  rg_6 : ptr<function, Rigid_0>,  f_7 : vec3<f32>,  t_10 : vec3<f32>)
{
    var iw_w_2 : vec3<f32> = world_mul_0((*rg_6).rot_1, isl_16.inertia0_0, isl_16.inertia1_0, isl_16.inertia2_0, (*rg_6).w_5);
    (*rg_6).a_15 = f_7 / vec3<f32>(isl_16.com_0.w);
    (*rg_6).alpha_0 = world_mul_0((*rg_6).rot_1, isl_16.inv0_0, isl_16.inv1_0, isl_16.inv2_0, t_10 - cross((*rg_6).w_5, iw_w_2));
    (*rg_6).torque_0 = t_10;
    return;
}

fn wide_rigid_frame_0( tid_13 : u32,  isl_17 : ptr<function, Island_std430_0>,  wg_2 : WideGroup_0) -> Rigid_0
{
    var _S292 : Rigid_0 = rigid_of_1(&((*isl_17)));
    var rg_7 : Rigid_0 = _S292;
    if(((((*isl_17).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_8 : vec3<f32>;
        var t_11 : vec3<f32>;
        wide_partials_0(tid_13, wg_2.first_0, (*isl_17).wide_groups_0, u32(0), &(f_8), &(t_11));
        rigid_acceleration_0(&((*isl_17)), &(rg_7), f_8, t_11);
    }
    return rg_7;
}

fn wide_rigid_frame_1( tid_14 : u32,  isl_18 : ptr<function, Island_std430_0>,  wg_3 : WideGroup_0) -> Rigid_0
{
    var _S293 : Rigid_0 = rigid_of_2(&((*isl_18)));
    var rg_8 : Rigid_0 = _S293;
    if(((((*isl_18).info_0.x) & (u32(1)))) == u32(0))
    {
        var f_9 : vec3<f32>;
        var t_12 : vec3<f32>;
        wide_partials_1(tid_14, wg_3.first_0, (*isl_18).wide_groups_0, u32(0), &(f_9), &(t_12));
        rigid_acceleration_1(&((*isl_18)), &(rg_8), f_9, t_12);
    }
    return rg_8;
}

fn comp_add_0( sum_5 : ptr<function, vec3<f32>>,  err_5 : ptr<function, vec3<f32>>,  x_15 : vec3<f32>)
{
    var t_13 : vec3<f32> = (*sum_5) + x_15;
    var _S294 : vec3<f32> = abs(x_15);
    (*err_5) = (*err_5) + (select(x_15, (*sum_5), (abs((*sum_5))) >= _S294) - t_13 + select((*sum_5), x_15, (abs((*sum_5))) >= _S294));
    (*sum_5) = t_13;
    return;
}

fn comp_add_1( sum_6 : ptr<function, vec3<f32>>,  err_6 : ptr<function, vec3<f32>>,  x_16 : vec3<f32>)
{
    var t_14 : vec3<f32> = (*sum_6) + x_16;
    var _S295 : vec3<f32> = abs(x_16);
    (*err_6) = (*err_6) + (select(x_16, (*sum_6), (abs((*sum_6))) >= _S295) - t_14 + select((*sum_6), x_16, (abs((*sum_6))) >= _S295));
    (*sum_6) = t_14;
    return;
}

fn turn_difference_0( omega_0 : vec3<f32>,  dt_7 : f32,  v_8 : vec3<f32>) -> vec3<f32>
{
    var _S296 : f32 = length(omega_0);
    var angle_1 : f32 = _S296 * dt_7;
    if(angle_1 < 1.00000000317107685e-30f)
    {
        return vec3<f32>(0.0f);
    }
    var a_16 : vec3<f32> = omega_0 / vec3<f32>(_S296);
    var s_8 : f32 = sin(0.5f * angle_1);
    var av_0 : vec3<f32> = cross(a_16, v_8);
    return av_0 * vec3<f32>(sin(angle_1)) + cross(a_16, av_0) * vec3<f32>((2.0f * s_8 * s_8));
}

fn turn_minus_one_0( axis_4 : vec3<f32>,  angle_2 : f32) -> vec4<f32>
{
    var s_9 : f32 = sin(0.25f * angle_2);
    return vec4<f32>(axis_4 * vec3<f32>(sin(0.5f * angle_2)), -2.0f * s_9 * s_9);
}

fn quat_vec_0( q_12 : Quat_0) -> vec4<f32>
{
    return vec4<f32>(q_12.x_3, q_12.y_2, q_12.z_0, q_12.w_0);
}

fn comp_add4_0( sum_7 : ptr<function, vec4<f32>>,  err_7 : ptr<function, vec4<f32>>,  x_17 : vec4<f32>)
{
    var t_15 : vec4<f32> = (*sum_7) + x_17;
    var _S297 : vec4<f32> = abs(x_17);
    (*err_7) = (*err_7) + (select(x_17, (*sum_7), (abs((*sum_7))) >= _S297) - t_15 + select((*sum_7), x_17, (abs((*sum_7))) >= _S297));
    (*sum_7) = t_15;
    return;
}

fn quat_accumulate_0( hi_1 : ptr<function, Quat_0>,  lo_1 : ptr<function, vec4<f32>>,  x_18 : vec4<f32>)
{
    var sum_8 : vec4<f32> = quat_vec_0((*hi_1));
    comp_add4_0(&(sum_8), &((*lo_1)), x_18);
    var t_16 : vec4<f32> = sum_8 + (*lo_1);
    (*lo_1) = (*lo_1) - (t_16 - sum_8);
    (*hi_1) = quat_of_0(t_16);
    return;
}

fn turn_left_0( hi_2 : ptr<function, Quat_0>,  lo_2 : ptr<function, vec4<f32>>,  omega_1 : vec3<f32>,  dt_8 : f32)
{
    var _S298 : f32 = length(omega_1);
    var angle_3 : f32 = _S298 * dt_8;
    if(angle_3 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_15 : vec4<f32> = turn_minus_one_0(omega_1 / vec3<f32>(_S298), angle_3);
    var dq_0 : Quat_0;
    dq_0.x_3 = d_15.x;
    dq_0.y_2 = d_15.y;
    dq_0.z_0 = d_15.z;
    dq_0.w_0 = d_15.w;
    quat_accumulate_0(&((*hi_2)), &((*lo_2)), quat_vec_0(quat_mul_0(dq_0, (*hi_2))));
    return;
}

fn turn_left_1( hi_3 : ptr<function, Quat_0>,  lo_3 : ptr<function, vec4<f32>>,  omega_2 : vec3<f32>,  dt_9 : f32)
{
    var _S299 : f32 = length(omega_2);
    var angle_4 : f32 = _S299 * dt_9;
    if(angle_4 < 1.00000000317107685e-30f)
    {
        return;
    }
    var d_16 : vec4<f32> = turn_minus_one_0(omega_2 / vec3<f32>(_S299), angle_4);
    var dq_1 : Quat_0;
    dq_1.x_3 = d_16.x;
    dq_1.y_2 = d_16.y;
    dq_1.z_0 = d_16.z;
    dq_1.w_0 = d_16.w;
    quat_accumulate_0(&((*hi_3)), &((*lo_3)), quat_vec_0(quat_mul_0(dq_1, (*hi_3))));
    return;
}

fn integrate_rigid_0( isl_19 : ptr<function, Island_std430_0>,  rg_9 : ptr<function, Rigid_0>,  dt_10 : f32)
{
    var _S300 : vec3<f32> = vec3<f32>(dt_10);
    var _S301 : vec3<f32> = (*rg_9).torque_0 * _S300;
    var _S302 : vec3<f32> = (*rg_9).l_1;
    var _S303 : vec3<f32> = (*rg_9).l_err_0;
    comp_add_1(&(_S302), &(_S303), _S301);
    (*rg_9).l_1 = _S302;
    (*rg_9).l_err_0 = _S303;
    var l_2 : vec3<f32> = _S302 + _S303;
    var _S304 : vec3<f32> = (*rg_9).a_15 * _S300;
    var _S305 : vec3<f32> = (*rg_9).vel_0;
    var _S306 : vec3<f32> = (*rg_9).vel_err_0;
    comp_add_1(&(_S305), &(_S306), _S304);
    (*rg_9).vel_0 = _S305;
    (*rg_9).vel_err_0 = _S306;
    var _S307 : vec4<f32> = (*isl_19).inv0_0;
    var _S308 : vec4<f32> = (*isl_19).inv1_0;
    var _S309 : vec4<f32> = (*isl_19).inv2_0;
    var w_mid_0 : vec3<f32> = world_mul_0((*rg_9).rot_1, (*isl_19).inv0_0, (*isl_19).inv1_0, (*isl_19).inv2_0, l_2);
    var delta_0 : vec3<f32> = (_S305 + _S306) * _S300 - turn_difference_0(w_mid_0, dt_10, rotate_0((*rg_9).rot_1, (*isl_19).com_0.xyz));
    var _S310 : vec3<f32> = (*rg_9).pos_0;
    var _S311 : vec3<f32> = (*rg_9).pos_err_0;
    comp_add_1(&(_S310), &(_S311), delta_0);
    (*rg_9).pos_0 = _S310;
    (*rg_9).pos_err_0 = _S311;
    var _S312 : Quat_0 = (*rg_9).rot_1;
    var _S313 : vec4<f32> = (*rg_9).rot_err_0;
    turn_left_1(&(_S312), &(_S313), w_mid_0, dt_10);
    (*rg_9).rot_1 = _S312;
    (*rg_9).rot_err_0 = _S313;
    (*rg_9).w_5 = world_mul_0(_S312, _S307, _S308, _S309, l_2);
    return;
}

fn integrate_rigid_1( isl_20 : Island_0,  rg_10 : ptr<function, Rigid_0>,  dt_11 : f32)
{
    var _S314 : vec3<f32> = vec3<f32>(dt_11);
    var _S315 : vec3<f32> = (*rg_10).torque_0 * _S314;
    var _S316 : vec3<f32> = (*rg_10).l_1;
    var _S317 : vec3<f32> = (*rg_10).l_err_0;
    comp_add_1(&(_S316), &(_S317), _S315);
    (*rg_10).l_1 = _S316;
    (*rg_10).l_err_0 = _S317;
    var l_3 : vec3<f32> = _S316 + _S317;
    var _S318 : vec3<f32> = (*rg_10).a_15 * _S314;
    var _S319 : vec3<f32> = (*rg_10).vel_0;
    var _S320 : vec3<f32> = (*rg_10).vel_err_0;
    comp_add_1(&(_S319), &(_S320), _S318);
    (*rg_10).vel_0 = _S319;
    (*rg_10).vel_err_0 = _S320;
    var w_mid_1 : vec3<f32> = world_mul_0((*rg_10).rot_1, isl_20.inv0_0, isl_20.inv1_0, isl_20.inv2_0, l_3);
    var delta_1 : vec3<f32> = (_S319 + _S320) * _S314 - turn_difference_0(w_mid_1, dt_11, rotate_0((*rg_10).rot_1, isl_20.com_0.xyz));
    var _S321 : vec3<f32> = (*rg_10).pos_0;
    var _S322 : vec3<f32> = (*rg_10).pos_err_0;
    comp_add_1(&(_S321), &(_S322), delta_1);
    (*rg_10).pos_0 = _S321;
    (*rg_10).pos_err_0 = _S322;
    var _S323 : Quat_0 = (*rg_10).rot_1;
    var _S324 : vec4<f32> = (*rg_10).rot_err_0;
    turn_left_1(&(_S323), &(_S324), w_mid_1, dt_11);
    (*rg_10).rot_1 = _S323;
    (*rg_10).rot_err_0 = _S324;
    (*rg_10).w_5 = world_mul_0(_S323, isl_20.inv0_0, isl_20.inv1_0, isl_20.inv2_0, l_3);
    return;
}

fn drift_apply_0( c_15 : u32,  wcom_3 : vec3<f32>,  tr_3 : vec3<f32>,  phi_0 : vec3<f32>,  dv_3 : vec3<f32>,  dw_0 : vec3<f32>)
{
    var r_8 : vec3<f32> = chunks_0[c_15].center_0.xyz - wcom_3;
    var _S325 : u32 = u32(4) * c_15;
    state_0[_S325] = vec4<f32>(state_0[_S325].xyz - (tr_3 + cross(phi_0, r_8)), state_0[_S325].w);
    var _S326 : u32 = _S325 + u32(1);
    state_0[_S326] = vec4<f32>(state_0[_S326].xyz - phi_0, state_0[_S326].w);
    var _S327 : u32 = _S325 + u32(2);
    state_0[_S327] = vec4<f32>(state_0[_S327].xyz - (dv_3 + cross(dw_0, r_8)), state_0[_S327].w);
    var _S328 : u32 = _S325 + u32(3);
    state_0[_S328] = vec4<f32>(state_0[_S328].xyz - dw_0, state_0[_S328].w);
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

fn drift_rigid_0( isl_21 : ptr<function, Island_std430_0>,  rg_11 : ptr<function, Rigid_0>,  tr_4 : vec3<f32>,  phi_2 : vec3<f32>,  dv_4 : vec3<f32>,  dw_1 : vec3<f32>)
{
    var wcom_4 : vec3<f32> = (*isl_21).wcom_0.xyz;
    var rot_2 : Quat_0 = (*rg_11).rot_1;
    var _S329 : vec3<f32> = rotate_0((*rg_11).rot_1, tr_4 - cross(phi_2, wcom_4));
    var _S330 : vec3<f32> = (*rg_11).pos_0;
    var _S331 : vec3<f32> = (*rg_11).pos_err_0;
    comp_add_1(&(_S330), &(_S331), _S329);
    (*rg_11).pos_0 = _S330;
    (*rg_11).pos_err_0 = _S331;
    var b_32 : vec3<f32> = inverse_rotate_0((*rg_11).rot_1, (*rg_11).w_5);
    var _S332 : vec4<f32> = (*isl_21).inertia0_0;
    var _S333 : vec4<f32> = (*isl_21).inertia1_0;
    var _S334 : vec4<f32> = (*isl_21).inertia2_0;
    var dl_turn_0 : vec3<f32> = rotate_0((*rg_11).rot_1, cross(phi_2, rows_mul_0((*isl_21).inertia0_0, (*isl_21).inertia1_0, (*isl_21).inertia2_0, b_32)) - rows_mul_0((*isl_21).inertia0_0, (*isl_21).inertia1_0, (*isl_21).inertia2_0, cross(phi_2, b_32)));
    var _S335 : Quat_0 = (*rg_11).rot_1;
    var _S336 : vec4<f32> = (*rg_11).rot_err_0;
    turn_right_0(&(_S335), &(_S336), phi_2);
    (*rg_11).rot_1 = _S335;
    (*rg_11).rot_err_0 = _S336;
    var _S337 : vec3<f32> = rotate_0(rot_2, dv_4 + cross(dw_1, (*isl_21).com_0.xyz - wcom_4));
    var _S338 : vec3<f32> = (*rg_11).vel_0;
    var _S339 : vec3<f32> = (*rg_11).vel_err_0;
    comp_add_1(&(_S338), &(_S339), _S337);
    (*rg_11).vel_0 = _S338;
    (*rg_11).vel_err_0 = _S339;
    var _S340 : vec3<f32> = rotate_0(rot_2, dw_1);
    (*rg_11).w_5 = (*rg_11).w_5 + _S340;
    var _S341 : vec3<f32> = dl_turn_0 + world_mul_0(_S335, _S332, _S333, _S334, _S340);
    var _S342 : vec3<f32> = (*rg_11).l_1;
    var _S343 : vec3<f32> = (*rg_11).l_err_0;
    comp_add_1(&(_S342), &(_S343), _S341);
    (*rg_11).l_1 = _S342;
    (*rg_11).l_err_0 = _S343;
    return;
}

fn drift_rigid_1( isl_22 : Island_0,  rg_12 : ptr<function, Rigid_0>,  tr_5 : vec3<f32>,  phi_3 : vec3<f32>,  dv_5 : vec3<f32>,  dw_2 : vec3<f32>)
{
    var wcom_5 : vec3<f32> = isl_22.wcom_0.xyz;
    var rot_3 : Quat_0 = (*rg_12).rot_1;
    var _S344 : vec3<f32> = rotate_0((*rg_12).rot_1, tr_5 - cross(phi_3, wcom_5));
    var _S345 : vec3<f32> = (*rg_12).pos_0;
    var _S346 : vec3<f32> = (*rg_12).pos_err_0;
    comp_add_1(&(_S345), &(_S346), _S344);
    (*rg_12).pos_0 = _S345;
    (*rg_12).pos_err_0 = _S346;
    var b_33 : vec3<f32> = inverse_rotate_0((*rg_12).rot_1, (*rg_12).w_5);
    var dl_turn_1 : vec3<f32> = rotate_0((*rg_12).rot_1, cross(phi_3, rows_mul_0(isl_22.inertia0_0, isl_22.inertia1_0, isl_22.inertia2_0, b_33)) - rows_mul_0(isl_22.inertia0_0, isl_22.inertia1_0, isl_22.inertia2_0, cross(phi_3, b_33)));
    var _S347 : Quat_0 = (*rg_12).rot_1;
    var _S348 : vec4<f32> = (*rg_12).rot_err_0;
    turn_right_0(&(_S347), &(_S348), phi_3);
    (*rg_12).rot_1 = _S347;
    (*rg_12).rot_err_0 = _S348;
    var _S349 : vec3<f32> = rotate_0(rot_3, dv_5 + cross(dw_2, isl_22.com_0.xyz - wcom_5));
    var _S350 : vec3<f32> = (*rg_12).vel_0;
    var _S351 : vec3<f32> = (*rg_12).vel_err_0;
    comp_add_1(&(_S350), &(_S351), _S349);
    (*rg_12).vel_0 = _S350;
    (*rg_12).vel_err_0 = _S351;
    var _S352 : vec3<f32> = rotate_0(rot_3, dw_2);
    (*rg_12).w_5 = (*rg_12).w_5 + _S352;
    var _S353 : vec3<f32> = dl_turn_1 + world_mul_0(_S347, isl_22.inertia0_0, isl_22.inertia1_0, isl_22.inertia2_0, _S352);
    var _S354 : vec3<f32> = (*rg_12).l_1;
    var _S355 : vec3<f32> = (*rg_12).l_err_0;
    comp_add_1(&(_S354), &(_S355), _S353);
    (*rg_12).l_1 = _S354;
    (*rg_12).l_err_0 = _S355;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_rigid(@builtin(workgroup_id) group_3 : vec3<u32>, @builtin(local_invocation_id) thread_3 : vec3<u32>)
{
    var tid_15 : u32 = thread_3.x;
    var _S356 : u32 = group_3.x;
    var wg_4 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S356);
    var _S357 : Island_std430_0 = islands_0[wg_4.island_2];
    var _S358 : u32 = _S357.info_0.x;
    var _S359 : bool;
    if(((_S358 & (u32(1)))) != u32(0))
    {
        _S359 = true;
    }
    else
    {
        var _S360 : bool = wide_enter_1(tid_15, wg_4.island_2);
        _S359 = !_S360;
    }
    if(_S359)
    {
        return;
    }
    if(((_S358 & (u32(16)))) != u32(0))
    {
        if(_S356 != (wg_4.first_0))
        {
            return;
        }
        var _S361 : Rigid_0 = wide_rigid_frame_1(tid_15, &(_S357), wg_4);
        var rs_0 : Rigid_0 = _S361;
        if(tid_15 != u32(0))
        {
            _S359 = true;
        }
        else
        {
            _S359 = ((_S358 & (u32(2)))) != u32(0);
        }
        if(_S359)
        {
            return;
        }
        integrate_rigid_0(&(_S357), &(rs_0), params_0.dt_0);
        islands_0[wg_4.island_2].rotation_0 = quat_vec_0(rs_0.rot_1);
        islands_0[wg_4.island_2].rotation_err_0 = rs_0.rot_err_0;
        islands_0[wg_4.island_2].position_0 = vec4<f32>(rs_0.pos_0, 0.0f);
        islands_0[wg_4.island_2].position_err_0 = vec4<f32>(rs_0.pos_err_0, 0.0f);
        islands_0[wg_4.island_2].velocity_0 = vec4<f32>(rs_0.vel_0, 0.0f);
        islands_0[wg_4.island_2].velocity_err_0 = vec4<f32>(rs_0.vel_err_0, 0.0f);
        islands_0[wg_4.island_2].angular_velocity_0 = vec4<f32>(rs_0.w_5, 0.0f);
        islands_0[wg_4.island_2].momentum_0 = vec4<f32>(rs_0.l_1, 0.0f);
        islands_0[wg_4.island_2].momentum_err_0 = vec4<f32>(rs_0.l_err_0, 0.0f);
        return;
    }
    var tu_1 : vec3<f32>;
    var pv_1 : vec3<f32>;
    wide_partials_1(tid_15, wg_4.first_0, _S357.wide_groups_0, u32(2), &(tu_1), &(pv_1));
    var lu_3 : vec3<f32>;
    var lv_3 : vec3<f32>;
    wide_partials_1(tid_15, wg_4.first_0, _S357.wide_groups_0, u32(4), &(lu_3), &(lv_3));
    var _S362 : vec4<f32> = _S357.wcom_0;
    var _S363 : vec3<f32> = vec3<f32>(_S357.wcom_0.w);
    var tr_6 : vec3<f32> = tu_1 / _S363;
    var dv_6 : vec3<f32> = pv_1 / _S363;
    var phi_4 : vec3<f32> = rows_mul_0(_S357.winv0_0, _S357.winv1_0, _S357.winv2_0, lu_3);
    var dw_3 : vec3<f32> = rows_mul_0(_S357.winv0_0, _S357.winv1_0, _S357.winv2_0, lv_3);
    var c_16 : u32 = wg_4.begin_0 + tid_15;
    if(c_16 < (wg_4.end_0))
    {
        drift_apply_0(c_16, _S362.xyz, tr_6, phi_4, dv_6, dw_3);
    }
    if(_S356 != (wg_4.first_0))
    {
        return;
    }
    var _S364 : Rigid_0 = wide_rigid_frame_1(tid_15, &(_S357), wg_4);
    var rg_13 : Rigid_0 = _S364;
    if(tid_15 != u32(0))
    {
        return;
    }
    if(!(((_S358 & (u32(2)))) != u32(0)))
    {
        integrate_rigid_0(&(_S357), &(rg_13), params_0.dt_0);
        drift_rigid_0(&(_S357), &(rg_13), tr_6, phi_4, dv_6, dw_3);
    }
    islands_0[wg_4.island_2].rotation_0 = quat_vec_0(rg_13.rot_1);
    islands_0[wg_4.island_2].rotation_err_0 = rg_13.rot_err_0;
    islands_0[wg_4.island_2].position_0 = vec4<f32>(rg_13.pos_0, 0.0f);
    islands_0[wg_4.island_2].position_err_0 = vec4<f32>(rg_13.pos_err_0, 0.0f);
    islands_0[wg_4.island_2].velocity_0 = vec4<f32>(rg_13.vel_0, 0.0f);
    islands_0[wg_4.island_2].velocity_err_0 = vec4<f32>(rg_13.vel_err_0, 0.0f);
    islands_0[wg_4.island_2].angular_velocity_0 = vec4<f32>(rg_13.w_5, 0.0f);
    islands_0[wg_4.island_2].momentum_0 = vec4<f32>(rg_13.l_1, 0.0f);
    islands_0[wg_4.island_2].momentum_err_0 = vec4<f32>(rg_13.l_err_0, 0.0f);
    return;
}

var<workgroup> g_label_0 : array<u32, i32(4096)>;

var<workgroup> g_changed_0 : u32;

fn connected_0( st_0 : ptr<function, JointState_std430_0>,  has_rebar_0 : bool) -> bool
{
    var _S365 : bool;
    if(((*st_0).damage_0) < 1.0f)
    {
        _S365 = true;
    }
    else
    {
        if(has_rebar_0)
        {
            _S365 = ((*st_0).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S365 = false;
        }
    }
    return _S365;
}

fn connected_1( st_1 : ptr<function, JointState_std430_0>,  has_rebar_1 : bool) -> bool
{
    var _S366 : bool;
    if(((*st_1).damage_0) < 1.0f)
    {
        _S366 = true;
    }
    else
    {
        if(has_rebar_1)
        {
            _S366 = ((*st_1).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S366 = false;
        }
    }
    return _S366;
}

fn connected_2( st_2 : ptr<function, JointState_std430_0>,  has_rebar_2 : bool) -> bool
{
    var _S367 : bool;
    if(((*st_2).damage_0) < 1.0f)
    {
        _S367 = true;
    }
    else
    {
        if(has_rebar_2)
        {
            _S367 = ((*st_2).rebar_broken_0) == 0.0f;
        }
        else
        {
            _S367 = false;
        }
    }
    return _S367;
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

fn connected_3( st_3 : JointState_0,  has_rebar_3 : bool) -> bool
{
    var _S368 : bool;
    if((st_3.damage_0) < 1.0f)
    {
        _S368 = true;
    }
    else
    {
        if(has_rebar_3)
        {
            _S368 = (st_3.rebar_broken_0) == 0.0f;
        }
        else
        {
            _S368 = false;
        }
    }
    return _S368;
}

fn island_connected_0( tid_16 : u32,  isl_23 : Island_0) -> bool
{
    var _S369 : u32 = isl_23.range_0.x;
    var n_10 : u32 = isl_23.range_0.y - _S369;
    if(n_10 > u32(4096))
    {
        return false;
    }
    var c_17 : u32 = tid_16;
    loop
    {
        if(c_17 < n_10)
        {
        }
        else
        {
            break;
        }
        g_label_0[c_17] = c_17;
        c_17 = c_17 + u32(256);
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
        if(tid_16 == u32(0))
        {
            g_changed_0 = u32(0);
        }
        workgroupBarrier();
        c_17 = tid_16;
        loop
        {
            if(c_17 < n_10)
            {
            }
            else
            {
                break;
            }
            var gc_0 : u32 = _S369 + c_17;
            var _S370 : u32 = index_0[gc_0];
            var l_4 : u32 = g_label_0[c_17];
            var e_2 : u32 = _S370;
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
                var _S371 : JointState_std430_0 = bond_dyn_0[bond_0].js_0;
                var _S372 : bool = connected_1(&(_S371), (bonds_0[bond_0].law_0.stiff1_0.w) != 0.0f);
                if(!_S372)
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
                l_4 = min(l_4, g_label_0[other_0 - _S369]);
                e_2 = e_2 + u32(1);
            }
            var _S373 : u32 = min(l_4, g_label_0[l_4]);
            if(_S373 < (g_label_0[c_17]))
            {
                g_label_0[c_17] = _S373;
                g_changed_0 = u32(1);
            }
            c_17 = c_17 + u32(256);
        }
        workgroupBarrier();
        var converged_1 : bool = g_changed_0 == u32(0);
        workgroupBarrier();
        if(converged_1)
        {
            converged_0 = converged_1;
            break;
        }
        var _S374 : u32 = pass_0 + u32(1);
        converged_0 = converged_1;
        pass_0 = _S374;
    }
    if(!converged_0)
    {
        return false;
    }
    if(tid_16 == u32(0))
    {
        g_changed_0 = u32(0);
    }
    workgroupBarrier();
    c_17 = tid_16;
    loop
    {
        if(c_17 < n_10)
        {
        }
        else
        {
            break;
        }
        if((g_label_0[c_17]) != u32(0))
        {
            g_changed_0 = u32(1);
        }
        c_17 = c_17 + u32(256);
    }
    workgroupBarrier();
    return g_changed_0 == u32(0);
}

fn write_probe_0( slot_2 : u32,  k_14 : u32,  value_1 : f32)
{
    var at_3 : u32 = params_0.probe_base_0 * u32(4) + slot_2 * params_0.probe_stride_0 + k_14;
    var v_9 : vec4<f32> = scratch_0[at_3 / u32(4)];
    v_9[at_3 % u32(4)] = value_1;
    scratch_0[at_3 / u32(4)] = v_9;
    return;
}

fn record_probes_0( isl_24 : Island_0,  rg_14 : Rigid_0,  k_15 : u32)
{
    var at_4 : u32 = isl_24.probes_0.x;
    loop
    {
        if(at_4 < (isl_24.probes_0.y))
        {
        }
        else
        {
            break;
        }
        var info_3 : vec4<u32> = (bitcast<vec4<u32>>((loads_0[at_4])));
        var a_17 : vec4<f32> = loads_0[at_4 + u32(1)];
        var b_34 : vec4<f32> = loads_0[at_4 + u32(2)];
        var c4_0 : vec4<f32> = loads_0[at_4 + u32(3)];
        var kind_1 : u32 = info_3.x;
        var i_5 : u32 = info_3.y;
        var value_2 : f32;
        if(kind_1 == u32(0))
        {
            value_2 = dot(rg_14.pos_0 - b_34.xyz + rotate_0(rg_14.rot_1, chunks_0[i_5].center_0.xyz) + (rg_14.pos_err_0 - c4_0.xyz + rotate_0(rg_14.rot_1, state_0[u32(4) * i_5].xyz + vec3<f32>(a_17.w, b_34.w, c4_0.w))), a_17.xyz);
        }
        else
        {
            if(kind_1 == u32(1))
            {
                var _S375 : u32 = u32(4) * i_5;
                value_2 = dot(rg_14.vel_0 + rg_14.vel_err_0 + cross(rg_14.w_5, rotate_0(rg_14.rot_1, chunks_0[i_5].center_0.xyz + state_0[_S375].xyz - isl_24.com_0.xyz)) + rotate_0(rg_14.rot_1, state_0[_S375 + u32(2)].xyz), a_17.xyz);
            }
            else
            {
                if(kind_1 == u32(2))
                {
                    var _S376 : u32 = u32(3) * i_5;
                    var f_10 : vec3<f32> = scratch_0[_S376].xyz;
                    var _S377 : bool = (info_3.z) == u32(0);
                    var mc_0 : vec3<f32>;
                    if(_S377)
                    {
                        mc_0 = scratch_0[_S376 + u32(1)].xyz;
                    }
                    else
                    {
                        mc_0 = scratch_0[_S376 + u32(2)].xyz;
                    }
                    var fc_0 : vec3<f32>;
                    if(_S377)
                    {
                        fc_0 = f_10;
                    }
                    else
                    {
                        fc_0 = (vec3<f32>(0) - f_10);
                    }
                    value_2 = dot(fc_0, a_17.xyz) + dot(mc_0, b_34.xyz);
                }
                else
                {
                    var _S378 : u32 = u32(4) * i_5;
                    value_2 = dot(rotate_0(rg_14.rot_1, vec3<f32>(state_0[_S378 + u32(1)].w, state_0[_S378 + u32(2)].w, state_0[_S378 + u32(3)].w)), a_17.xyz);
                }
            }
        }
        write_probe_0(info_3.w, k_15, value_2);
        at_4 = at_4 + u32(4);
    }
    return;
}

fn contact_split_at_0( at_5 : u32)
{
    var previous_0 : u32 = islands_0[params_0.halt_index_0].info_0.y;
    var _S379 : u32;
    if(previous_0 == u32(0))
    {
        _S379 = at_5;
    }
    else
    {
        _S379 = min(previous_0, at_5);
    }
    islands_0[params_0.halt_index_0].info_0[i32(1)] = _S379;
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_end(@builtin(workgroup_id) group_4 : vec3<u32>, @builtin(local_invocation_id) thread_4 : vec3<u32>)
{
    var tid_17 : u32 = thread_4.x;
    var _S380 : u32 = group_4.x;
    var wg_5 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, _S380);
    if(_S380 != (wg_5.first_0))
    {
        return;
    }
    var _S381 : Island_std430_0 = islands_0[wg_5.island_2];
    var isl_25 : Island_0;
    isl_25.range_0 = _S381.range_0;
    isl_25.info_0 = _S381.info_0;
    isl_25.com_0 = _S381.com_0;
    isl_25.inertia0_0 = _S381.inertia0_0;
    isl_25.inertia1_0 = _S381.inertia1_0;
    isl_25.inertia2_0 = _S381.inertia2_0;
    isl_25.inv0_0 = _S381.inv0_0;
    isl_25.inv1_0 = _S381.inv1_0;
    isl_25.inv2_0 = _S381.inv2_0;
    isl_25.wcom_0 = _S381.wcom_0;
    isl_25.winv0_0 = _S381.winv0_0;
    isl_25.winv1_0 = _S381.winv1_0;
    isl_25.winv2_0 = _S381.winv2_0;
    isl_25.rotation_0 = _S381.rotation_0;
    isl_25.position_0 = _S381.position_0;
    isl_25.position_err_0 = _S381.position_err_0;
    isl_25.velocity_0 = _S381.velocity_0;
    isl_25.velocity_err_0 = _S381.velocity_err_0;
    isl_25.angular_velocity_0 = _S381.angular_velocity_0;
    isl_25.done_0 = _S381.done_0;
    isl_25.coverage_0 = _S381.coverage_0;
    isl_25.wide_groups_0 = _S381.wide_groups_0;
    isl_25.done_pad_0 = _S381.done_pad_0;
    isl_25.probes_0 = _S381.probes_0;
    isl_25.energy_0 = _S381.energy_0;
    isl_25.rotation_err_0 = _S381.rotation_err_0;
    isl_25.momentum_0 = _S381.momentum_0;
    isl_25.momentum_err_0 = _S381.momentum_err_0;
    var _S382 : bool = wide_enter_0(tid_17, &(_S381));
    if(!_S382)
    {
        return;
    }
    var work_0 : vec3<f32>;
    var flags_1 : vec3<f32>;
    wide_partials_1(tid_17, wg_5.first_0, isl_25.wide_groups_0, u32(6), &(work_0), &(flags_1));
    var halt_0 : bool = (((isl_25.info_0.z) & (u32(2)))) != u32(0);
    var whole_0 : bool;
    if(halt_0)
    {
        var _S383 : bool = island_connected_0(tid_17, isl_25);
        whole_0 = _S383;
    }
    else
    {
        whole_0 = false;
    }
    if(tid_17 != u32(0))
    {
        return;
    }
    var halt_1 : bool;
    if(whole_0)
    {
        isl_25.info_0[i32(2)] = ((isl_25.info_0[i32(2)]) & (u32(4294967293)));
        isl_25.coverage_0 = ((isl_25.coverage_0) | (u32(128)));
        halt_1 = false;
    }
    else
    {
        halt_1 = halt_0;
    }
    var k_16 : u32 = wide_step_2(isl_25);
    if((isl_25.probes_0.y) > (isl_25.probes_0.x))
    {
        record_probes_0(isl_25, rigid_of_3(isl_25), k_16);
    }
    if(halt_1)
    {
        whole_0 = (((isl_25.info_0.x) & (u32(4)))) != u32(0);
    }
    else
    {
        whole_0 = false;
    }
    if(whole_0)
    {
        contact_split_at_0(isl_25.info_0.w + u32(1));
    }
    var _S384 : f32 = work_0.x;
    var _S385 : f32 = isl_25.energy_0[i32(0)];
    var _S386 : f32 = isl_25.energy_0[i32(1)];
    comp_add1_4(&(_S385), &(_S386), _S384);
    isl_25.energy_0[i32(0)] = _S385;
    isl_25.energy_0[i32(1)] = _S386 + work_0.y;
    isl_25.done_0 = isl_25.done_0 + u32(1);
    isl_25.info_0[i32(1)] = isl_25.info_0[i32(1)] - u32(1);
    isl_25.info_0[i32(3)] = isl_25.info_0[i32(3)] + u32(1);
    if(halt_1)
    {
        isl_25.info_0[i32(2)] = ((((isl_25.info_0.z) & (u32(4294967293)))) | (u32(1)));
    }
    var _S387 : u32;
    if(halt_1)
    {
        _S387 = u32(128);
    }
    else
    {
        _S387 = u32(0);
    }
    var _S388 : u32 = (u32(256) | (_S387));
    if((isl_25.probes_0.y) > (isl_25.probes_0.x))
    {
        _S387 = u32(262144);
    }
    else
    {
        _S387 = u32(0);
    }
    var _S389 : u32 = (_S388 | (_S387));
    if((((isl_25.info_0.x) & (u32(4)))) != u32(0))
    {
        _S387 = u32(524288);
    }
    else
    {
        _S387 = u32(0);
    }
    var _S390 : u32 = (_S389 | (_S387));
    if((flags_1.x) > 0.0f)
    {
        _S387 = u32(32768);
    }
    else
    {
        _S387 = u32(0);
    }
    var _S391 : u32 = (_S390 | (_S387));
    if((flags_1.y) > 0.0f)
    {
        _S387 = u32(65536);
    }
    else
    {
        _S387 = u32(0);
    }
    var _S392 : u32 = (_S391 | (_S387));
    if((flags_1.z) > 0.0f)
    {
        _S387 = u32(131072);
    }
    else
    {
        _S387 = u32(0);
    }
    isl_25.coverage_0 = ((isl_25.coverage_0) | (((_S392 | (_S387)))));
    islands_0[wg_5.island_2].range_0 = isl_25.range_0;
    islands_0[wg_5.island_2].info_0 = isl_25.info_0;
    islands_0[wg_5.island_2].com_0 = isl_25.com_0;
    islands_0[wg_5.island_2].inertia0_0 = isl_25.inertia0_0;
    islands_0[wg_5.island_2].inertia1_0 = isl_25.inertia1_0;
    islands_0[wg_5.island_2].inertia2_0 = isl_25.inertia2_0;
    islands_0[wg_5.island_2].inv0_0 = isl_25.inv0_0;
    islands_0[wg_5.island_2].inv1_0 = isl_25.inv1_0;
    islands_0[wg_5.island_2].inv2_0 = isl_25.inv2_0;
    islands_0[wg_5.island_2].wcom_0 = isl_25.wcom_0;
    islands_0[wg_5.island_2].winv0_0 = isl_25.winv0_0;
    islands_0[wg_5.island_2].winv1_0 = isl_25.winv1_0;
    islands_0[wg_5.island_2].winv2_0 = isl_25.winv2_0;
    islands_0[wg_5.island_2].rotation_0 = isl_25.rotation_0;
    islands_0[wg_5.island_2].position_0 = isl_25.position_0;
    islands_0[wg_5.island_2].position_err_0 = isl_25.position_err_0;
    islands_0[wg_5.island_2].velocity_0 = isl_25.velocity_0;
    islands_0[wg_5.island_2].velocity_err_0 = isl_25.velocity_err_0;
    islands_0[wg_5.island_2].angular_velocity_0 = isl_25.angular_velocity_0;
    islands_0[wg_5.island_2].done_0 = isl_25.done_0;
    islands_0[wg_5.island_2].coverage_0 = isl_25.coverage_0;
    islands_0[wg_5.island_2].wide_groups_0 = isl_25.wide_groups_0;
    islands_0[wg_5.island_2].done_pad_0 = isl_25.done_pad_0;
    islands_0[wg_5.island_2].probes_0 = isl_25.probes_0;
    islands_0[wg_5.island_2].energy_0 = isl_25.energy_0;
    islands_0[wg_5.island_2].rotation_err_0 = isl_25.rotation_err_0;
    islands_0[wg_5.island_2].momentum_0 = isl_25.momentum_0;
    islands_0[wg_5.island_2].momentum_err_0 = isl_25.momentum_err_0;
    return;
}

fn sv_0( c_18 : u32,  slot_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * c_18 + slot_3;
}

fn project_load_slot_0( tid_18 : u32,  isl_26 : ptr<function, Island_std430_0>,  slot_4 : u32)
{
    var _S393 : u32;
    var _S394 : vec3<f32> = vec3<f32>(0.0f);
    var net_f_0 : vec3<f32> = _S394;
    var net_m_0 : vec3<f32> = _S394;
    var _S395 : vec4<u32> = (*isl_26).range_0;
    var _S396 : u32 = (*isl_26).range_0.x + tid_18;
    var c_19 : u32 = _S396;
    loop
    {
        var _S397 : u32 = _S395.y;
        _S393 = _S397;
        if(c_19 < _S397)
        {
        }
        else
        {
            break;
        }
        var fi_0 : vec3<f32> = scratch_0[sv_0(c_19, slot_4)].xyz;
        net_f_0 = net_f_0 + fi_0;
        net_m_0 = net_m_0 + (cross(chunks_0[c_19].center_0.xyz - (*isl_26).com_0.xyz, fi_0) + scratch_0[sv_0(c_19, slot_4 + u32(1))].xyz);
        c_19 = c_19 + u32(256);
    }
    group_sum3_1(tid_18, &(net_f_0), &(net_m_0));
    var _S398 : vec4<f32> = (*isl_26).com_0;
    var _S399 : vec3<f32> = net_f_0 / vec3<f32>((*isl_26).com_0.w);
    var _S400 : vec3<f32> = rows_mul_0((*isl_26).inv0_0, (*isl_26).inv1_0, (*isl_26).inv2_0, net_m_0);
    c_19 = _S396;
    loop
    {
        if(c_19 < _S393)
        {
        }
        else
        {
            break;
        }
        var _S401 : u32 = sv_0(c_19, slot_4);
        scratch_0[_S401] = vec4<f32>(scratch_0[_S401].xyz - (_S399 + cross(_S400, chunks_0[c_19].center_0.xyz - _S398.xyz)) * vec3<f32>(chunks_0[c_19].center_0.w), 0.0f);
        var _S402 : u32 = sv_0(c_19, slot_4 + u32(1));
        scratch_0[_S402] = vec4<f32>(scratch_0[_S402].xyz - rows_mul_0(chunks_0[c_19].inertia0_1, chunks_0[c_19].inertia1_1, chunks_0[c_19].inertia2_1, _S400), 0.0f);
        c_19 = c_19 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn island_dot_0( tid_19 : u32,  c0_0 : u32,  c1_0 : u32,  sa_0 : u32,  sb_0 : u32) -> f32
{
    var _S403 : vec4<f32> = vec4<f32>(0.0f);
    var acc_0 : vec4<f32> = _S403;
    var unused_2 : vec4<f32> = _S403;
    var c_20 : u32 = c0_0 + tid_19;
    loop
    {
        if(c_20 < c1_0)
        {
        }
        else
        {
            break;
        }
        acc_0[i32(0)] = acc_0[i32(0)] + (dot(scratch_0[sv_0(c_20, sa_0)].xyz, scratch_0[sv_0(c_20, sb_0)].xyz) + dot(scratch_0[sv_0(c_20, sa_0 + u32(1))].xyz, scratch_0[sv_0(c_20, sb_0 + u32(1))].xyz));
        c_20 = c_20 + u32(256);
    }
    group_sum2_2(tid_19, &(acc_0), &(unused_2));
    return acc_0.x;
}

fn fdiv_0( a_18 : f32,  b_35 : f32) -> f32
{
    return a_18 / b_35;
}

fn fsqrt_0( a_19 : f32) -> f32
{
    return sqrt(a_19);
}

struct Measures_0
{
     tension_0 : f32,
     shear_0 : f32,
     normal_compression_0 : f32,
     compression_0 : f32,
     compressive_force_0 : f32,
};

fn stress_measures_0( b_36 : ptr<function, JointBond_std430_0>,  q_lin_0 : vec3<f32>,  q_ang_0 : vec3<f32>) -> Measures_0
{
    var area_2 : f32 = (*b_36).geom0_0.x;
    var _S404 : f32 = q_lin_0.z;
    var axial_0 : f32 = fdiv_0(_S404, area_2);
    var bending_0 : f32 = fdiv_0(abs(q_ang_0.x), (*b_36).geom1_0.x) + fdiv_0(abs(q_ang_0.y), (*b_36).geom1_0.y);
    var _S405 : f32 = q_lin_0.x;
    var _S406 : f32 = q_lin_0.y;
    var shear_1 : f32 = fdiv_0(fsqrt_0(_S405 * _S405 + _S406 * _S406), area_2) + fdiv_0(abs(q_ang_0.z), (*b_36).geom0_0.w);
    var m_2 : Measures_0;
    m_2.tension_0 = axial_0 + bending_0;
    m_2.shear_0 = shear_1;
    var _S407 : f32 = - axial_0;
    m_2.normal_compression_0 = max(_S407, 0.0f);
    m_2.compression_0 = _S407 + bending_0;
    m_2.compressive_force_0 = max(- _S404, 0.0f);
    return m_2;
}

fn stress_measures_1( b_37 : ptr<function, JointBond_std430_0>,  q_lin_1 : vec3<f32>,  q_ang_1 : vec3<f32>) -> Measures_0
{
    var area_3 : f32 = (*b_37).geom0_0.x;
    var _S408 : f32 = q_lin_1.z;
    var axial_1 : f32 = fdiv_0(_S408, area_3);
    var bending_1 : f32 = fdiv_0(abs(q_ang_1.x), (*b_37).geom1_0.x) + fdiv_0(abs(q_ang_1.y), (*b_37).geom1_0.y);
    var _S409 : f32 = q_lin_1.x;
    var _S410 : f32 = q_lin_1.y;
    var shear_2 : f32 = fdiv_0(fsqrt_0(_S409 * _S409 + _S410 * _S410), area_3) + fdiv_0(abs(q_ang_1.z), (*b_37).geom0_0.w);
    var m_3 : Measures_0;
    m_3.tension_0 = axial_1 + bending_1;
    m_3.shear_0 = shear_2;
    var _S411 : f32 = - axial_1;
    m_3.normal_compression_0 = max(_S411, 0.0f);
    m_3.compression_0 = _S411 + bending_1;
    m_3.compressive_force_0 = max(- _S408, 0.0f);
    return m_3;
}

fn expm1_accurate_0( x_19 : f32) -> f32
{
    if((abs(x_19)) < 0.00100000004749745f)
    {
        return x_19 * (1.0f + x_19 * (0.5f + x_19 * 0.1666666716337204f));
    }
    return exp(x_19) - 1.0f;
}

fn fpow_0( a_20 : f32,  b_38 : f32) -> f32
{
    return pow(a_20, b_38);
}

fn dif_factor_0( mat_1 : ptr<function, JointMaterial_std140_0>,  strain_rate_1 : f32) -> f32
{
    var r_9 : f32 = abs(strain_rate_1);
    var _S412 : vec4<f32> = (*mat_1).dif_0;
    var ref_0 : f32 = (*mat_1).dif_0.x;
    if(r_9 <= ref_0)
    {
        return 1.0f;
    }
    var _S413 : f32 = _S412.z;
    var f_11 : f32;
    if(r_9 <= _S413)
    {
        f_11 = fpow_0(fdiv_0(r_9, ref_0), _S412.y);
    }
    else
    {
        f_11 = fpow_0(fdiv_0(_S413, ref_0), _S412.y) * fpow_0(fdiv_0(r_9, _S413), _S412.w);
    }
    return clamp(f_11, 1.0f, (*mat_1).misc_0.x);
}

fn dif_factor_1( mat_2 : ptr<function, JointMaterial_std140_0>,  strain_rate_2 : f32) -> f32
{
    var r_10 : f32 = abs(strain_rate_2);
    var _S414 : vec4<f32> = (*mat_2).dif_0;
    var ref_1 : f32 = (*mat_2).dif_0.x;
    if(r_10 <= ref_1)
    {
        return 1.0f;
    }
    var _S415 : f32 = _S414.z;
    var f_12 : f32;
    if(r_10 <= _S415)
    {
        f_12 = fpow_0(fdiv_0(r_10, ref_1), _S414.y);
    }
    else
    {
        f_12 = fpow_0(fdiv_0(_S415, ref_1), _S414.y) * fpow_0(fdiv_0(r_10, _S415), _S414.w);
    }
    return clamp(f_12, 1.0f, (*mat_2).misc_0.x);
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

fn failure_indices_0( mat_6 : ptr<function, JointMaterial_std140_0>,  b_39 : ptr<function, JointBond_std430_0>,  m_4 : Measures_0,  multiplier_0 : f32) -> vec4<f32>
{
    var fc_1 : f32 = (*mat_6).strength_0.y * multiplier_0;
    var _S416 : f32 = min((*mat_6).strength_0.z * multiplier_0 + (*mat_6).strength_0.w * m_4.normal_compression_0, (*mat_6).energy_1.x * multiplier_0);
    var idx_0 : vec4<f32>;
    idx_0[i32(0)] = max(fdiv_0(m_4.tension_0, (*mat_6).strength_0.x * multiplier_0), 0.0f);
    var _S417 : f32;
    if(_S416 > 0.0f)
    {
        _S417 = fdiv_0(m_4.shear_0, _S416);
    }
    else
    {
        _S417 = infinity_0();
    }
    idx_0[i32(1)] = _S417;
    idx_0[i32(2)] = max(fdiv_0(m_4.compression_0, fc_1), 0.0f);
    var _S418 : f32 = (*b_39).stiff1_0.y;
    if(_S418 > 0.0f)
    {
        _S417 = fdiv_0(m_4.compressive_force_0, _S418);
    }
    else
    {
        _S417 = 0.0f;
    }
    idx_0[i32(3)] = _S417;
    return idx_0;
}

fn failure_indices_1( mat_7 : ptr<function, JointMaterial_std140_0>,  b_40 : ptr<function, JointBond_std430_0>,  m_5 : Measures_0,  multiplier_1 : f32) -> vec4<f32>
{
    var fc_2 : f32 = (*mat_7).strength_0.y * multiplier_1;
    var _S419 : f32 = min((*mat_7).strength_0.z * multiplier_1 + (*mat_7).strength_0.w * m_5.normal_compression_0, (*mat_7).energy_1.x * multiplier_1);
    var idx_1 : vec4<f32>;
    idx_1[i32(0)] = max(fdiv_0(m_5.tension_0, (*mat_7).strength_0.x * multiplier_1), 0.0f);
    var _S420 : f32;
    if(_S419 > 0.0f)
    {
        _S420 = fdiv_0(m_5.shear_0, _S419);
    }
    else
    {
        _S420 = infinity_0();
    }
    idx_1[i32(1)] = _S420;
    idx_1[i32(2)] = max(fdiv_0(m_5.compression_0, fc_2), 0.0f);
    var _S421 : f32 = (*b_40).stiff1_0.y;
    if(_S421 > 0.0f)
    {
        _S420 = fdiv_0(m_5.compressive_force_0, _S421);
    }
    else
    {
        _S420 = 0.0f;
    }
    idx_1[i32(3)] = _S420;
    return idx_1;
}

fn sq_0( x_20 : f32) -> f32
{
    return x_20 * x_20;
}

fn damage_law_0( kind_2 : u32,  kappa_1 : f32,  r_11 : f32) -> f32
{
    if(kappa_1 <= 1.0f)
    {
        return 0.0f;
    }
    if(kind_2 == u32(0))
    {
        if(r_11 <= 1.0f)
        {
            return 1.0f;
        }
        return min(fdiv_0(r_11 * (kappa_1 - 1.0f), kappa_1 * (r_11 - 1.0f)), 1.0f);
    }
    if(kappa_1 >= (0.5f * (r_11 + 1.0f)))
    {
        return 1.0f;
    }
    return 1.0f - fdiv_0(1.0f, kappa_1);
}

fn damage_increment_0( kind_3 : u32,  kappa_old_0 : f32,  lambda_0 : f32,  r_12 : f32,  d_old_0 : f32,  psi_0 : f32) -> vec2<f32>
{
    var _S422 : f32 = max(damage_law_0(kind_3, lambda_0, r_12), d_old_0);
    var _S423 : bool;
    if(_S422 <= d_old_0)
    {
        _S423 = true;
    }
    else
    {
        _S423 = d_old_0 >= 1.0f;
    }
    if(_S423)
    {
        return vec2<f32>(d_old_0, 0.0f);
    }
    var u0_0 : f32 = fdiv_0(psi_0, lambda_0 * lambda_0);
    var _S424 : f32 = max(kappa_old_0, 1.0f);
    if(kind_3 == u32(0))
    {
        if(r_12 > 1.0f)
        {
            return vec2<f32>(_S422, fdiv_0(u0_0 * r_12, r_12 - 1.0f) * max(min(lambda_0, r_12) - min(_S424, r_12), 0.0f));
        }
        return vec2<f32>(_S422, (1.0f - d_old_0) * psi_0);
    }
    var ku_0 : f32 = 0.5f * (r_12 + 1.0f);
    var plateau_0 : f32 = u0_0 * max(min(lambda_0, ku_0) - min(_S424, ku_0), 0.0f);
    var snap_0 : f32;
    if(_S422 >= 1.0f)
    {
        snap_0 = u0_0 * ku_0;
    }
    else
    {
        snap_0 = 0.0f;
    }
    return vec2<f32>(_S422, plateau_0 + snap_0);
}

fn compressed_region_0( w0_0 : f32,  w1_0 : f32,  dz_0 : f32,  ax_0 : f32,  ay_0 : f32,  region_0 : ptr<function, array<f32, i32(6)>>)
{
    var count_5 : u32;
    var h0_0 : f32 = 0.5f * w0_0;
    var h1_0 : f32 = 0.5f * w1_0;
    var _S425 : f32 = - h0_0;
    var _S426 : f32 = - h1_0;
    var _S427 : array<vec2<f32>, i32(4)> = array<vec2<f32>, i32(4)>( vec2<f32>(_S425, _S426), vec2<f32>(h0_0, _S426), vec2<f32>(h0_0, h1_0), vec2<f32>(_S425, h1_0) );
    var poly_0 : array<vec2<f32>, i32(8)>;
    var i_6 : u32 = u32(0);
    var count_6 : u32 = u32(0);
    loop
    {
        if(i_6 < u32(4))
        {
        }
        else
        {
            break;
        }
        var _S428 : u32 = i_6;
        var _S429 : u32 = i_6 + u32(1);
        var _S430 : u32 = _S429 % u32(4);
        var _S431 : f32 = _S427[i_6].y;
        var _S432 : f32 = _S427[i_6].x;
        var fp_0 : f32 = dz_0 + ax_0 * _S431 - ay_0 * _S432;
        var _S433 : f32 = _S427[_S430].y;
        var _S434 : f32 = _S427[_S430].x;
        var fq_0 : f32 = dz_0 + ax_0 * _S433 - ay_0 * _S434;
        var _S435 : bool = fp_0 < 0.0f;
        if(_S435)
        {
            var _S436 : u32 = count_6 + u32(1);
            poly_0[count_6] = _S427[_S428];
            count_5 = _S436;
        }
        else
        {
            count_5 = count_6;
        }
        if(_S435 != (fq_0 < 0.0f))
        {
            var t_17 : f32 = fp_0 / (fp_0 - fq_0);
            var _S437 : u32 = count_5 + u32(1);
            poly_0[count_5] = vec2<f32>(_S432 + t_17 * (_S434 - _S432), _S431 + t_17 * (_S433 - _S431));
            count_6 = _S437;
        }
        else
        {
            count_6 = count_5;
        }
        i_6 = _S429;
    }
    count_5 = u32(0);
    loop
    {
        if(count_5 < u32(6))
        {
        }
        else
        {
            break;
        }
        (*region_0)[count_5] = 0.0f;
        count_5 = count_5 + u32(1);
    }
    if(count_6 < u32(3))
    {
        return;
    }
    var o_1 : vec2<f32> = poly_0[i32(0)];
    i_6 = u32(0);
    var a_21 : f32 = 0.0f;
    var sx_0 : f32 = 0.0f;
    var sy_0 : f32 = 0.0f;
    var ixx_0 : f32 = 0.0f;
    var iyy_0 : f32 = 0.0f;
    var ixy_0 : f32 = 0.0f;
    loop
    {
        if(i_6 < count_6)
        {
        }
        else
        {
            break;
        }
        var _S438 : f32 = o_1.x;
        var x0_0 : f32 = poly_0[i_6].x - _S438;
        var _S439 : f32 = o_1.y;
        var y0_0 : f32 = poly_0[i_6].y - _S439;
        var _S440 : u32 = i_6 + u32(1);
        var _S441 : u32 = _S440 % count_6;
        var x1_0 : f32 = poly_0[_S441].x - _S438;
        var y1_0 : f32 = poly_0[_S441].y - _S439;
        var _S442 : f32 = x0_0 * y1_0;
        var _S443 : f32 = x1_0 * y0_0;
        var cr_0 : f32 = _S442 - _S443;
        var a_22 : f32 = a_21 + cr_0 / 2.0f;
        var sx_1 : f32 = sx_0 + (x0_0 + x1_0) * cr_0 / 6.0f;
        var sy_1 : f32 = sy_0 + (y0_0 + y1_0) * cr_0 / 6.0f;
        var ixx_1 : f32 = ixx_0 + (x0_0 * x0_0 + x0_0 * x1_0 + x1_0 * x1_0) * cr_0 / 12.0f;
        var iyy_1 : f32 = iyy_0 + (y0_0 * y0_0 + y0_0 * y1_0 + y1_0 * y1_0) * cr_0 / 12.0f;
        var ixy_1 : f32 = ixy_0 + (_S442 + 2.0f * x0_0 * y0_0 + 2.0f * x1_0 * y1_0 + _S443) * cr_0 / 24.0f;
        i_6 = _S440;
        a_21 = a_22;
        sx_0 = sx_1;
        sy_0 = sy_1;
        ixx_0 = ixx_1;
        iyy_0 = iyy_1;
        ixy_0 = ixy_1;
    }
    if(a_21 <= 0.0f)
    {
        return;
    }
    var cx_0 : f32 = sx_0 / a_21;
    var cy_0 : f32 = sy_0 / a_21;
    (*region_0)[i32(0)] = a_21;
    (*region_0)[i32(1)] = o_1.x + cx_0;
    (*region_0)[i32(2)] = o_1.y + cy_0;
    var _S444 : f32 = a_21 * cx_0;
    (*region_0)[i32(3)] = ixx_0 - _S444 * cx_0;
    (*region_0)[i32(4)] = iyy_0 - a_21 * cy_0 * cy_0;
    (*region_0)[i32(5)] = ixy_0 - _S444 * cy_0;
    return;
}

fn no_tension_patch_0( kn_0 : f32,  w0_1 : f32,  w1_1 : f32,  dz_1 : f32,  ax_1 : f32,  ay_1 : f32) -> vec4<f32>
{
    var r_13 : array<f32, i32(6)>;
    compressed_region_0(w0_1, w1_1, dz_1, ax_1, ay_1, &(r_13));
    var a_23 : f32 = r_13[i32(0)];
    if((r_13[i32(0)]) == 0.0f)
    {
        return vec4<f32>(0.0f);
    }
    var k_17 : f32 = kn_0 / (w0_1 * w1_1);
    var fc_3 : f32 = dz_1 + ax_1 * r_13[i32(2)] - ay_1 * r_13[i32(1)];
    var _S445 : f32 = a_23 * fc_3;
    var _S446 : f32 = - ay_1;
    return vec4<f32>(k_17 * a_23 * fc_3, k_17 * (_S445 * r_13[i32(2)] + (_S446 * r_13[i32(5)] + ax_1 * r_13[i32(4)])), - k_17 * (_S445 * r_13[i32(1)] + (_S446 * r_13[i32(3)] + ax_1 * r_13[i32(5)])), 0.5f * k_17 * (_S445 * fc_3 + ay_1 * ay_1 * r_13[i32(3)] + ax_1 * ax_1 * r_13[i32(4)] - 2.0f * ax_1 * ay_1 * r_13[i32(5)]));
}

fn signum_0( x_21 : f32) -> f32
{
    var _S447 : f32;
    if((((bitcast<u32>((x_21))) & (u32(2147483648)))) != u32(0))
    {
        _S447 = -1.0f;
    }
    else
    {
        _S447 = 1.0f;
    }
    return _S447;
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
     q_lin_2 : vec3<f32>,
     q_ang_2 : vec3<f32>,
     energy_2 : f32,
     diss_2 : f32,
     plastic_1 : vec3<f32>,
};

fn contact_part_0( mat_8 : ptr<function, JointMaterial_std140_0>,  b_41 : ptr<function, JointBond_std430_0>,  crush_2 : f32,  plastic_2 : vec3<f32>,  d_lin_0 : vec3<f32>,  d_ang_0 : vec3<f32>) -> Contact_0
{
    var c_21 : Contact_0;
    var _S448 : vec3<f32> = vec3<f32>(0.0f);
    c_21.q_lin_2 = _S448;
    c_21.q_ang_2 = _S448;
    c_21.energy_2 = 0.0f;
    c_21.diss_2 = 0.0f;
    c_21.plastic_1 = plastic_2;
    var _S449 : u32 = (*mat_8).kind_flags_0.y;
    if(((_S449 & (u32(2)))) == u32(0))
    {
        return c_21;
    }
    var kn_1 : f32 = (*b_41).stiff0_0.x;
    var ks_0 : f32 = (*b_41).stiff0_0.y;
    var kt_0 : f32 = (*b_41).stiff1_0.x;
    var w0_2 : f32 = (*b_41).geom0_0.y;
    var w1_2 : f32 = (*b_41).geom0_0.z;
    var diss_3 : f32;
    var nc_sum_0 : f32;
    var m1_0 : f32;
    var m2_0 : f32;
    var energy_3 : f32;
    if(((_S449 & (u32(4)))) != u32(0))
    {
        var p_15 : vec4<f32> = no_tension_patch_0(kn_1 * (1.0f - crush_2), w0_2, w1_2, d_lin_0.z, d_ang_0.x, d_ang_0.y);
        var _S450 : f32 = p_15.y;
        var _S451 : f32 = p_15.z;
        var _S452 : f32 = p_15.w;
        nc_sum_0 = p_15.x;
        m1_0 = _S450;
        m2_0 = _S451;
        energy_3 = _S452;
    }
    else
    {
        var ki_0 : f32 = kn_1 * (1.0f - crush_2) / 36.0f;
        var _S453 : f32 = d_ang_0.x;
        var _S454 : f32 = d_ang_0.y;
        var spread_0 : f32 = abs(_S453) * 0.4166666567325592f * w1_2 + abs(_S454) * 0.4166666567325592f * w0_2;
        var _S455 : f32 = d_lin_0.z;
        var slack_0 : f32 = 9.99999997475242708e-07f * (abs(_S455) + spread_0);
        if((_S455 - spread_0) > slack_0)
        {
            nc_sum_0 = 0.0f;
            m1_0 = 0.0f;
            m2_0 = 0.0f;
            energy_3 = 0.0f;
        }
        else
        {
            if((_S455 + spread_0) < (- slack_0))
            {
                var i1_0 : f32 = 2.91666650772094727f * w0_2 * w0_2;
                var i2_0 : f32 = 2.91666650772094727f * w1_2 * w1_2;
                var _S456 : f32 = ki_0 * _S453 * i2_0;
                var _S457 : f32 = ki_0 * _S454 * i1_0;
                var _S458 : f32 = 0.5f * ki_0 * (36.0f * _S455 * _S455 + _S453 * _S453 * i2_0 + _S454 * _S454 * i1_0);
                nc_sum_0 = ki_0 * 36.0f * _S455;
                m1_0 = _S456;
                m2_0 = _S457;
                energy_3 = _S458;
            }
            else
            {
                var i_7 : u32 = u32(0);
                diss_3 = 0.0f;
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
                    var _S459 : f32 = SPRING_AT_0[i_7] * w0_2;
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
                        var di_0 : f32 = _S455 + _S453 * s2_0 - _S454 * _S459;
                        if(di_0 < 0.0f)
                        {
                            var f_14 : f32 = ki_0 * di_0;
                            var m1_2 : f32 = m1_0 + f_14 * s2_0;
                            var m2_2 : f32 = m2_0 - f_14 * _S459;
                            var energy_5 : f32 = energy_3 + 0.5f * ki_0 * di_0 * di_0;
                            nc_sum_0 = nc_sum_0 + f_14;
                            m1_0 = m1_2;
                            m2_0 = m2_2;
                            energy_3 = energy_5;
                        }
                        j_7 = j_7 + u32(1);
                    }
                    i_7 = i_7 + u32(1);
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
    var p_16 : vec3<f32> = plastic_2;
    c_21.q_lin_2 = vec3<f32>(0.0f, 0.0f, nc_sum_0);
    c_21.q_ang_2 = vec3<f32>(m1_0, m2_0, 0.0f);
    var slide_cap_0 : f32 = (*mat_8).strength_0.w * nc_0;
    var _S460 : f32 = ks_0 * (d_lin_0.x - plastic_2.x);
    var _S461 : f32 = ks_0 * (d_lin_0.y - plastic_2.y);
    var tn_0 : f32 = fsqrt_0(_S460 * _S460 + _S461 * _S461);
    var _S462 : bool;
    if(tn_0 > slide_cap_0)
    {
        _S462 = tn_0 > 0.0f;
    }
    else
    {
        _S462 = false;
    }
    if(_S462)
    {
        var _S463 : f32 = fdiv_0(_S460, tn_0);
        var _S464 : f32 = fdiv_0(_S461, tn_0);
        var dslip_0 : f32 = fdiv_0(tn_0 - slide_cap_0, ks_0);
        p_16[i32(0)] = p_16[i32(0)] + _S463 * dslip_0;
        p_16[i32(1)] = p_16[i32(1)] + _S464 * dslip_0;
        c_21.q_lin_2[i32(0)] = _S463 * slide_cap_0;
        c_21.q_lin_2[i32(1)] = _S464 * slide_cap_0;
        diss_3 = slide_cap_0 * dslip_0;
    }
    else
    {
        c_21.q_lin_2[i32(0)] = _S460;
        c_21.q_lin_2[i32(1)] = _S461;
        diss_3 = 0.0f;
    }
    var tq_0 : vec2<f32> = return_map_0(kt_0, d_ang_0.z, p_16.z, slide_cap_0 * (*b_41).geom1_0.z);
    var _S465 : f32 = tq_0.x;
    var _S466 : f32 = tq_0.y;
    var diss_4 : f32 = diss_3 + abs(_S465) * abs(_S466);
    p_16[i32(2)] = p_16[i32(2)] + _S466;
    c_21.q_ang_2[i32(2)] = _S465;
    c_21.energy_2 = energy_3 + 0.5f * (fdiv_0(sq_0(c_21.q_lin_2.x), ks_0) + fdiv_0(sq_0(c_21.q_lin_2.y), ks_0) + fdiv_0(sq_0(_S465), kt_0));
    c_21.diss_2 = diss_4;
    c_21.plastic_1 = p_16;
    return c_21;
}

fn contact_part_1( mat_9 : ptr<function, JointMaterial_std140_0>,  b_42 : ptr<function, JointBond_std430_0>,  crush_3 : f32,  plastic_3 : vec3<f32>,  d_lin_1 : vec3<f32>,  d_ang_1 : vec3<f32>) -> Contact_0
{
    var c_22 : Contact_0;
    var _S467 : vec3<f32> = vec3<f32>(0.0f);
    c_22.q_lin_2 = _S467;
    c_22.q_ang_2 = _S467;
    c_22.energy_2 = 0.0f;
    c_22.diss_2 = 0.0f;
    c_22.plastic_1 = plastic_3;
    var _S468 : u32 = (*mat_9).kind_flags_0.y;
    if(((_S468 & (u32(2)))) == u32(0))
    {
        return c_22;
    }
    var kn_2 : f32 = (*b_42).stiff0_0.x;
    var ks_1 : f32 = (*b_42).stiff0_0.y;
    var kt_1 : f32 = (*b_42).stiff1_0.x;
    var w0_3 : f32 = (*b_42).geom0_0.y;
    var w1_3 : f32 = (*b_42).geom0_0.z;
    var diss_5 : f32;
    var nc_sum_1 : f32;
    var m1_3 : f32;
    var m2_3 : f32;
    var energy_6 : f32;
    if(((_S468 & (u32(4)))) != u32(0))
    {
        var p_17 : vec4<f32> = no_tension_patch_0(kn_2 * (1.0f - crush_3), w0_3, w1_3, d_lin_1.z, d_ang_1.x, d_ang_1.y);
        var _S469 : f32 = p_17.y;
        var _S470 : f32 = p_17.z;
        var _S471 : f32 = p_17.w;
        nc_sum_1 = p_17.x;
        m1_3 = _S469;
        m2_3 = _S470;
        energy_6 = _S471;
    }
    else
    {
        var ki_1 : f32 = kn_2 * (1.0f - crush_3) / 36.0f;
        var _S472 : f32 = d_ang_1.x;
        var _S473 : f32 = d_ang_1.y;
        var spread_1 : f32 = abs(_S472) * 0.4166666567325592f * w1_3 + abs(_S473) * 0.4166666567325592f * w0_3;
        var _S474 : f32 = d_lin_1.z;
        var slack_1 : f32 = 9.99999997475242708e-07f * (abs(_S474) + spread_1);
        if((_S474 - spread_1) > slack_1)
        {
            nc_sum_1 = 0.0f;
            m1_3 = 0.0f;
            m2_3 = 0.0f;
            energy_6 = 0.0f;
        }
        else
        {
            if((_S474 + spread_1) < (- slack_1))
            {
                var i1_1 : f32 = 2.91666650772094727f * w0_3 * w0_3;
                var i2_1 : f32 = 2.91666650772094727f * w1_3 * w1_3;
                var _S475 : f32 = ki_1 * _S472 * i2_1;
                var _S476 : f32 = ki_1 * _S473 * i1_1;
                var _S477 : f32 = 0.5f * ki_1 * (36.0f * _S474 * _S474 + _S472 * _S472 * i2_1 + _S473 * _S473 * i1_1);
                nc_sum_1 = ki_1 * 36.0f * _S474;
                m1_3 = _S475;
                m2_3 = _S476;
                energy_6 = _S477;
            }
            else
            {
                var i_8 : u32 = u32(0);
                diss_5 = 0.0f;
                var m1_4 : f32 = 0.0f;
                var m2_4 : f32 = 0.0f;
                var energy_7 : f32 = 0.0f;
                loop
                {
                    if(i_8 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S478 : f32 = SPRING_AT_0[i_8] * w0_3;
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
                        var di_1 : f32 = _S474 + _S472 * s2_1 - _S473 * _S478;
                        if(di_1 < 0.0f)
                        {
                            var f_15 : f32 = ki_1 * di_1;
                            var m1_5 : f32 = m1_3 + f_15 * s2_1;
                            var m2_5 : f32 = m2_3 - f_15 * _S478;
                            var energy_8 : f32 = energy_6 + 0.5f * ki_1 * di_1 * di_1;
                            nc_sum_1 = nc_sum_1 + f_15;
                            m1_3 = m1_5;
                            m2_3 = m2_5;
                            energy_6 = energy_8;
                        }
                        j_8 = j_8 + u32(1);
                    }
                    i_8 = i_8 + u32(1);
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
    var p_18 : vec3<f32> = plastic_3;
    c_22.q_lin_2 = vec3<f32>(0.0f, 0.0f, nc_sum_1);
    c_22.q_ang_2 = vec3<f32>(m1_3, m2_3, 0.0f);
    var slide_cap_1 : f32 = (*mat_9).strength_0.w * nc_1;
    var _S479 : f32 = ks_1 * (d_lin_1.x - plastic_3.x);
    var _S480 : f32 = ks_1 * (d_lin_1.y - plastic_3.y);
    var tn_1 : f32 = fsqrt_0(_S479 * _S479 + _S480 * _S480);
    var _S481 : bool;
    if(tn_1 > slide_cap_1)
    {
        _S481 = tn_1 > 0.0f;
    }
    else
    {
        _S481 = false;
    }
    if(_S481)
    {
        var _S482 : f32 = fdiv_0(_S479, tn_1);
        var _S483 : f32 = fdiv_0(_S480, tn_1);
        var dslip_1 : f32 = fdiv_0(tn_1 - slide_cap_1, ks_1);
        p_18[i32(0)] = p_18[i32(0)] + _S482 * dslip_1;
        p_18[i32(1)] = p_18[i32(1)] + _S483 * dslip_1;
        c_22.q_lin_2[i32(0)] = _S482 * slide_cap_1;
        c_22.q_lin_2[i32(1)] = _S483 * slide_cap_1;
        diss_5 = slide_cap_1 * dslip_1;
    }
    else
    {
        c_22.q_lin_2[i32(0)] = _S479;
        c_22.q_lin_2[i32(1)] = _S480;
        diss_5 = 0.0f;
    }
    var tq_1 : vec2<f32> = return_map_0(kt_1, d_ang_1.z, p_18.z, slide_cap_1 * (*b_42).geom1_0.z);
    var _S484 : f32 = tq_1.x;
    var _S485 : f32 = tq_1.y;
    var diss_6 : f32 = diss_5 + abs(_S484) * abs(_S485);
    p_18[i32(2)] = p_18[i32(2)] + _S485;
    c_22.q_ang_2[i32(2)] = _S484;
    c_22.energy_2 = energy_6 + 0.5f * (fdiv_0(sq_0(c_22.q_lin_2.x), ks_1) + fdiv_0(sq_0(c_22.q_lin_2.y), ks_1) + fdiv_0(sq_0(_S484), kt_1));
    c_22.diss_2 = diss_6;
    c_22.plastic_1 = p_18;
    return c_22;
}

fn contact_offsets_0( mat_10 : ptr<function, JointMaterial_std140_0>,  b_43 : ptr<function, JointBond_std430_0>,  crush_4 : f32,  plastic_4 : vec3<f32>,  d_lin_2 : vec3<f32>,  d_ang_2 : vec3<f32>) -> vec3<f32>
{
    var _S486 : u32 = (*mat_10).kind_flags_0.y;
    if(((_S486 & (u32(2)))) == u32(0))
    {
        return plastic_4;
    }
    var kn_3 : f32 = (*b_43).stiff0_0.x;
    var ks_2 : f32 = (*b_43).stiff0_0.y;
    var kt_2 : f32 = (*b_43).stiff1_0.x;
    var w0_4 : f32 = (*b_43).geom0_0.y;
    var w1_4 : f32 = (*b_43).geom0_0.z;
    var nc_sum_2 : f32;
    if(((_S486 & (u32(4)))) != u32(0))
    {
        var _S487 : vec4<f32> = no_tension_patch_0(kn_3 * (1.0f - crush_4), w0_4, w1_4, d_lin_2.z, d_ang_2.x, d_ang_2.y);
        nc_sum_2 = _S487.x;
    }
    else
    {
        var ki_2 : f32 = kn_3 * (1.0f - crush_4) / 36.0f;
        var _S488 : f32 = d_ang_2.x;
        var _S489 : f32 = d_ang_2.y;
        var spread_2 : f32 = abs(_S488) * 0.4166666567325592f * w1_4 + abs(_S489) * 0.4166666567325592f * w0_4;
        var _S490 : f32 = d_lin_2.z;
        var slack_2 : f32 = 9.99999997475242708e-07f * (abs(_S490) + spread_2);
        if((_S490 - spread_2) > slack_2)
        {
            nc_sum_2 = 0.0f;
        }
        else
        {
            if((_S490 + spread_2) < (- slack_2))
            {
                nc_sum_2 = ki_2 * 36.0f * _S490;
            }
            else
            {
                var i_9 : u32 = u32(0);
                var nc_sum_3 : f32 = 0.0f;
                loop
                {
                    if(i_9 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S491 : f32 = SPRING_AT_0[i_9] * w0_4;
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
                        var di_2 : f32 = _S490 + _S488 * (SPRING_AT_0[j_9] * w1_4) - _S489 * _S491;
                        if(di_2 < 0.0f)
                        {
                            nc_sum_2 = nc_sum_2 + ki_2 * di_2;
                        }
                        j_9 = j_9 + u32(1);
                    }
                    i_9 = i_9 + u32(1);
                    nc_sum_3 = nc_sum_2;
                }
                nc_sum_2 = nc_sum_3;
            }
        }
    }
    var nc_2 : f32 = - nc_sum_2;
    var p_19 : vec3<f32> = plastic_4;
    var slide_cap_2 : f32 = (*mat_10).strength_0.w * nc_2;
    var _S492 : f32 = ks_2 * (d_lin_2.x - plastic_4.x);
    var _S493 : f32 = ks_2 * (d_lin_2.y - plastic_4.y);
    var tn_2 : f32 = fsqrt_0(_S492 * _S492 + _S493 * _S493);
    var _S494 : bool;
    if(tn_2 > slide_cap_2)
    {
        _S494 = tn_2 > 0.0f;
    }
    else
    {
        _S494 = false;
    }
    if(_S494)
    {
        var _S495 : f32 = fdiv_0(_S493, tn_2);
        var dslip_2 : f32 = fdiv_0(tn_2 - slide_cap_2, ks_2);
        p_19[i32(0)] = p_19[i32(0)] + fdiv_0(_S492, tn_2) * dslip_2;
        p_19[i32(1)] = p_19[i32(1)] + _S495 * dslip_2;
    }
    p_19[i32(2)] = p_19[i32(2)] + return_map_0(kt_2, d_ang_2.z, p_19.z, slide_cap_2 * (*b_43).geom1_0.z).y;
    return p_19;
}

fn contact_offsets_1( mat_11 : ptr<function, JointMaterial_std140_0>,  b_44 : ptr<function, JointBond_std430_0>,  crush_5 : f32,  plastic_5 : vec3<f32>,  d_lin_3 : vec3<f32>,  d_ang_3 : vec3<f32>) -> vec3<f32>
{
    var _S496 : u32 = (*mat_11).kind_flags_0.y;
    if(((_S496 & (u32(2)))) == u32(0))
    {
        return plastic_5;
    }
    var kn_4 : f32 = (*b_44).stiff0_0.x;
    var ks_3 : f32 = (*b_44).stiff0_0.y;
    var kt_3 : f32 = (*b_44).stiff1_0.x;
    var w0_5 : f32 = (*b_44).geom0_0.y;
    var w1_5 : f32 = (*b_44).geom0_0.z;
    var nc_sum_4 : f32;
    if(((_S496 & (u32(4)))) != u32(0))
    {
        var _S497 : vec4<f32> = no_tension_patch_0(kn_4 * (1.0f - crush_5), w0_5, w1_5, d_lin_3.z, d_ang_3.x, d_ang_3.y);
        nc_sum_4 = _S497.x;
    }
    else
    {
        var ki_3 : f32 = kn_4 * (1.0f - crush_5) / 36.0f;
        var _S498 : f32 = d_ang_3.x;
        var _S499 : f32 = d_ang_3.y;
        var spread_3 : f32 = abs(_S498) * 0.4166666567325592f * w1_5 + abs(_S499) * 0.4166666567325592f * w0_5;
        var _S500 : f32 = d_lin_3.z;
        var slack_3 : f32 = 9.99999997475242708e-07f * (abs(_S500) + spread_3);
        if((_S500 - spread_3) > slack_3)
        {
            nc_sum_4 = 0.0f;
        }
        else
        {
            if((_S500 + spread_3) < (- slack_3))
            {
                nc_sum_4 = ki_3 * 36.0f * _S500;
            }
            else
            {
                var i_10 : u32 = u32(0);
                var nc_sum_5 : f32 = 0.0f;
                loop
                {
                    if(i_10 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var _S501 : f32 = SPRING_AT_0[i_10] * w0_5;
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
                        var di_3 : f32 = _S500 + _S498 * (SPRING_AT_0[j_10] * w1_5) - _S499 * _S501;
                        if(di_3 < 0.0f)
                        {
                            nc_sum_4 = nc_sum_4 + ki_3 * di_3;
                        }
                        j_10 = j_10 + u32(1);
                    }
                    i_10 = i_10 + u32(1);
                    nc_sum_5 = nc_sum_4;
                }
                nc_sum_4 = nc_sum_5;
            }
        }
    }
    var nc_3 : f32 = - nc_sum_4;
    var p_20 : vec3<f32> = plastic_5;
    var slide_cap_3 : f32 = (*mat_11).strength_0.w * nc_3;
    var _S502 : f32 = ks_3 * (d_lin_3.x - plastic_5.x);
    var _S503 : f32 = ks_3 * (d_lin_3.y - plastic_5.y);
    var tn_3 : f32 = fsqrt_0(_S502 * _S502 + _S503 * _S503);
    var _S504 : bool;
    if(tn_3 > slide_cap_3)
    {
        _S504 = tn_3 > 0.0f;
    }
    else
    {
        _S504 = false;
    }
    if(_S504)
    {
        var _S505 : f32 = fdiv_0(_S503, tn_3);
        var dslip_3 : f32 = fdiv_0(tn_3 - slide_cap_3, ks_3);
        p_20[i32(0)] = p_20[i32(0)] + fdiv_0(_S502, tn_3) * dslip_3;
        p_20[i32(1)] = p_20[i32(1)] + _S505 * dslip_3;
    }
    p_20[i32(2)] = p_20[i32(2)] + return_map_0(kt_3, d_ang_3.z, p_20.z, slide_cap_3 * (*b_44).geom1_0.z).y;
    return p_20;
}

fn life_rate_0( mat_12 : ptr<function, JointMaterial_std140_0>,  s_10 : f32) -> f32
{
    if(s_10 <= 0.0f)
    {
        return 0.0f;
    }
    var _S506 : f32 = (*mat_12).misc_0.y;
    return fdiv_0((_S506 + 1.0f) * fpow_0(s_10, _S506), (*mat_12).misc_0.z);
}

fn life_rate_1( mat_13 : ptr<function, JointMaterial_std140_0>,  s_11 : f32) -> f32
{
    if(s_11 <= 0.0f)
    {
        return 0.0f;
    }
    var _S507 : f32 = (*mat_13).misc_0.y;
    return fdiv_0((_S507 + 1.0f) * fpow_0(s_11, _S507), (*mat_13).misc_0.z);
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

fn joint_evaluate_0( mat_14 : ptr<function, JointMaterial_std140_0>,  b_45 : ptr<function, JointBond_std430_0>,  state_2 : ptr<function, JointState_std430_0>,  d_lin_4 : vec3<f32>,  d_ang_4 : vec3<f32>,  dt_12 : f32,  fracture_1 : bool) -> JointResponse_0
{
    var kn_5 : f32 = (*b_45).stiff0_0.x;
    var ks_4 : f32 = (*b_45).stiff0_0.y;
    var kb1_0 : f32 = (*b_45).stiff0_0.z;
    var kb2_0 : f32 = (*b_45).stiff0_0.w;
    var _S508 : vec4<f32> = (*b_45).stiff1_0;
    var kt_4 : f32 = (*b_45).stiff1_0.x;
    var has_rebar_4 : bool = ((*b_45).stiff1_0.w) != 0.0f;
    var kind_4 : u32 = (*mat_14).kind_flags_0.x;
    var flags_2 : u32 = (*mat_14).kind_flags_0.y;
    var softening_0 : bool = ((flags_2 & (u32(1)))) != u32(0);
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
    var _S509 : bool = connected_0(&((*state_2)), has_rebar_4);
    var qe_lin_0 : vec3<f32> = d_lin_4 * vec3<f32>(ks_4, ks_4, kn_5);
    var qe_ang_0 : vec3<f32> = d_ang_4 * vec3<f32>(kb1_0, kb2_0, kt_4);
    var _S510 : Measures_0 = stress_measures_0(&((*b_45)), qe_lin_0, qe_ang_0);
    var _S511 : f32 = max(max(_S510.tension_0, _S510.shear_0), _S510.compression_0);
    var _S512 : bool = dt_12 > 0.0f;
    var dif_1 : f32;
    if(_S512)
    {
        var raw_0 : f32 = fdiv_0(max(fdiv_0(_S511 - st_4.governing_stress_0, dt_12), 0.0f), (*mat_14).misc_0.w);
        var tau_2 : f32 = _S508.z;
        if(((flags_2 & (u32(16)))) != u32(0))
        {
            dif_1 = - expm1_accurate_0(- fdiv_0(dt_12, tau_2));
        }
        else
        {
            dif_1 = min(fdiv_0(dt_12, tau_2), 1.0f);
        }
        st_4.strain_rate_0 = st_4.strain_rate_0 + (raw_0 - st_4.strain_rate_0) * dif_1;
        st_4.governing_stress_0 = _S511;
    }
    if(((flags_2 & (u32(32)))) != u32(0))
    {
        var _S513 : f32 = dif_factor_0(&((*mat_14)), st_4.strain_rate_0);
        dif_1 = _S513;
    }
    else
    {
        dif_1 = 1.0f;
    }
    var weibull_0 : f32 = (*b_45).geom1_0.w;
    var _S514 : f32 = fatigue_factor_1(&((*mat_14)), st_4.life_0);
    var multiplier_2 : f32 = weibull_0 * dif_1 * _S514;
    var _S515 : vec4<f32> = failure_indices_0(&((*mat_14)), &((*b_45)), _S510, multiplier_2);
    var _S516 : f32 = _S515.x;
    var _S517 : f32 = _S515.y;
    st_4.utilization_0 = max(max(_S516, _S517), max(_S515.z, _S515.w));
    var _S518 : f32 = d_lin_4.x;
    var _S519 : f32 = d_lin_4.y;
    var _S520 : f32 = ks_4 * (sq_0(_S518) + sq_0(_S519)) + kb1_0 * sq_0(d_ang_4.x) + kb2_0 * sq_0(d_ang_4.y) + kt_4 * sq_0(d_ang_4.z);
    var _S521 : f32 = d_lin_4.z;
    var _S522 : bool = _S521 > 0.0f;
    if(_S522)
    {
        dif_1 = kn_5 * sq_0(_S521);
    }
    else
    {
        dif_1 = 0.0f;
    }
    var psi_ts_0 : f32 = 0.5f * (_S520 + dif_1);
    var psi_c_0 : f32;
    if(_S521 < 0.0f)
    {
        psi_c_0 = 0.5f * kn_5 * sq_0(_S521);
    }
    else
    {
        psi_c_0 = 0.0f;
    }
    var plastic_6 : vec3<f32> = vec3<f32>(st_4.plastic_x_0, st_4.plastic_y_0, st_4.plastic_t_0);
    var diss_contact_0 : f32;
    var psi_contact_0 : f32;
    var intact_normal_0 : f32;
    var dissipated_5 : f32;
    var overshoot_1 : f32;
    var _S523 : bool;
    var qc_lin_0 : vec3<f32>;
    if(fracture_1)
    {
        var _S524 : bool = _S516 >= _S517;
        if(_S524)
        {
            diss_contact_0 = _S516;
        }
        else
        {
            diss_contact_0 = _S517;
        }
        var mode_ts_0 : u32;
        if(_S524)
        {
            mode_ts_0 = u32(1);
        }
        else
        {
            mode_ts_0 = u32(2);
        }
        if(diss_contact_0 > (st_4.kappa_0))
        {
            _S523 = diss_contact_0 > 1.0f;
        }
        else
        {
            _S523 = false;
        }
        if(_S523)
        {
            _S523 = psi_ts_0 > 0.0f;
        }
        else
        {
            _S523 = false;
        }
        var mode_c_0 : u32;
        if(_S523)
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
                intact_normal_0 = fdiv_0(psi_contact_0 * (*b_45).geom0_0.x * diss_contact_0 * diss_contact_0, psi_ts_0);
            }
            else
            {
                intact_normal_0 = 0.0f;
            }
            st_4.ductility_0 = intact_normal_0;
            if(softening_0)
            {
                mode_c_0 = kind_4;
            }
            else
            {
                mode_c_0 = u32(0);
            }
            var inc_0 : vec2<f32> = damage_increment_0(mode_c_0, st_4.kappa_0, diss_contact_0, intact_normal_0, st_4.damage_0, psi_ts_0);
            var _S525 : f32 = inc_0.x;
            if(_S525 > (st_4.damage_0))
            {
                var _S526 : Contact_0 = contact_part_0(&((*mat_14)), &((*b_45)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
                var _S527 : f32 = max(_S526.energy_2 - (1.0f - st_4.crush_1) * psi_c_0, 0.0f);
                var _S528 : f32 = max(inc_0.y - _S527 * (_S525 - st_4.damage_0), 0.0f);
                var _S529 : f32 = max((psi_ts_0 - _S527) * (_S525 - st_4.damage_0) - _S528, 0.0f);
                st_4.damage_0 = _S525;
                st_4.mode_0 = mode_ts_0;
                dissipated_5 = _S528;
                overshoot_1 = _S529;
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
        st_4.kappa_0 = max(st_4.kappa_0, diss_contact_0);
        var _S530 : f32 = (*state_2).damage_0;
        if(((*state_2).damage_0) > 0.0f)
        {
            var _S531 : Contact_0 = contact_part_0(&((*mat_14)), &((*b_45)), (*state_2).crush_1, vec3<f32>((*state_2).plastic_x_0, (*state_2).plastic_y_0, (*state_2).plastic_t_0), d_lin_4, d_ang_4);
            qc_lin_0 = qe_ang_0 * vec3<f32>((1.0f - _S530)) + _S531.q_ang_2 * vec3<f32>(_S530);
        }
        else
        {
            qc_lin_0 = qe_ang_0;
        }
        var _S532 : Measures_0 = stress_measures_0(&((*b_45)), vec3<f32>(0.0f, 0.0f, min(qe_lin_0.z, 0.0f)), qc_lin_0);
        var _S533 : vec4<f32> = failure_indices_0(&((*mat_14)), &((*b_45)), _S532, multiplier_2);
        var _S534 : f32 = _S533.z;
        var _S535 : f32 = _S533.w;
        var _S536 : bool = _S534 >= _S535;
        if(_S536)
        {
            psi_contact_0 = _S534;
        }
        else
        {
            psi_contact_0 = _S535;
        }
        if(_S536)
        {
            mode_c_0 = u32(3);
        }
        else
        {
            mode_c_0 = u32(4);
        }
        if(psi_contact_0 > (st_4.kappa_c_0))
        {
            _S523 = psi_contact_0 > 1.0f;
        }
        else
        {
            _S523 = false;
        }
        if(_S523)
        {
            _S523 = psi_c_0 > 0.0f;
        }
        else
        {
            _S523 = false;
        }
        if(_S523)
        {
            if(softening_0)
            {
                intact_normal_0 = fdiv_0((*mat_14).energy_1.w * (*b_45).geom0_0.x * psi_contact_0 * psi_contact_0, psi_c_0);
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
                    mode_ts_0 = kind_4;
                }
                law_1 = mode_ts_0;
            }
            var inc_1 : vec2<f32> = damage_increment_0(law_1, st_4.kappa_c_0, psi_contact_0, intact_normal_0, st_4.crush_1, psi_c_0);
            var _S537 : f32 = inc_1.x;
            if(_S537 > (st_4.crush_1))
            {
                var _S538 : f32 = inc_1.y;
                var dissipated_6 : f32 = dissipated_5 + _S538;
                var overshoot_2 : f32 = overshoot_1 + max(psi_c_0 * (_S537 - st_4.crush_1) - _S538, 0.0f);
                st_4.crush_1 = _S537;
                st_4.mode_0 = mode_c_0;
                if(_S537 >= 1.0f)
                {
                    _S523 = (st_4.damage_0) < 1.0f;
                }
                else
                {
                    _S523 = false;
                }
                if(_S523)
                {
                    var dissipated_7 : f32 = dissipated_6 + psi_ts_0 * (1.0f - st_4.damage_0);
                    st_4.damage_0 = 1.0f;
                    dissipated_5 = dissipated_7;
                }
                else
                {
                    dissipated_5 = dissipated_6;
                }
                overshoot_1 = overshoot_2;
            }
        }
        st_4.kappa_c_0 = max(st_4.kappa_c_0, psi_contact_0);
    }
    else
    {
        dissipated_5 = 0.0f;
        overshoot_1 = 0.0f;
    }
    var dmg_0 : f32 = st_4.damage_0;
    var _S539 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_0 : vec3<f32>;
    if((st_4.damage_0) == 0.0f)
    {
        if(((flags_2 & (u32(8)))) == u32(0))
        {
            var _S540 : vec3<f32> = contact_offsets_0(&((*mat_14)), &((*b_45)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
            st_4.plastic_x_0 = _S540.x;
            st_4.plastic_y_0 = _S540.y;
            st_4.plastic_t_0 = _S540.z;
        }
        diss_contact_0 = 0.0f;
        qc_lin_0 = _S539;
        qc_ang_0 = _S539;
        psi_contact_0 = 0.0f;
    }
    else
    {
        var _S541 : Contact_0 = contact_part_0(&((*mat_14)), &((*b_45)), st_4.crush_1, plastic_6, d_lin_4, d_ang_4);
        st_4.plastic_x_0 = _S541.plastic_1.x;
        st_4.plastic_y_0 = _S541.plastic_1.y;
        st_4.plastic_t_0 = _S541.plastic_1.z;
        diss_contact_0 = _S541.diss_2;
        qc_lin_0 = _S541.q_lin_2;
        qc_ang_0 = _S541.q_ang_2;
        psi_contact_0 = _S541.energy_2;
    }
    var dissipated_8 : f32 = dissipated_5 + dmg_0 * diss_contact_0;
    if(_S522)
    {
        intact_normal_0 = kn_5 * _S521;
    }
    else
    {
        intact_normal_0 = (1.0f - st_4.crush_1) * kn_5 * _S521;
    }
    var _S542 : f32 = 1.0f - dmg_0;
    var force_lin_2 : vec3<f32> = vec3<f32>(_S542 * qe_lin_0.x + dmg_0 * qc_lin_0.x, _S542 * qe_lin_0.y + dmg_0 * qc_lin_0.y, _S542 * intact_normal_0 + dmg_0 * qc_lin_0.z);
    var force_ang_2 : vec3<f32> = qe_ang_0 * vec3<f32>(_S542) + qc_ang_0 * vec3<f32>(dmg_0);
    var stored_6 : f32 = _S542 * (psi_ts_0 + (1.0f - st_4.crush_1) * psi_c_0) + dmg_0 * psi_contact_0;
    if(has_rebar_4)
    {
        _S523 = (st_4.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S523 = false;
    }
    var stored_7 : f32;
    var force_lin_3 : vec3<f32>;
    if(_S523)
    {
        var k_axial_0 : f32 = (*b_45).rebar0_0.x;
        var k_dowel_0 : f32 = (*b_45).rebar0_0.y;
        var yield_force_0 : f32 = (*b_45).rebar0_0.z;
        var dowel_capacity_0 : f32 = (*b_45).rebar0_0.w;
        var nr_0 : vec2<f32> = return_map_0(k_axial_0, _S521, st_4.rebar_plastic_0, yield_force_0);
        var v1_0 : vec2<f32> = return_map_0(k_dowel_0, _S518, st_4.rebar_slip0_0, dowel_capacity_0);
        var v2_0 : vec2<f32> = return_map_0(k_dowel_0, _S519, st_4.rebar_slip1_0, dowel_capacity_0);
        var _S543 : f32 = nr_0.y;
        var _S544 : f32 = v1_0.y;
        var _S545 : f32 = v2_0.y;
        var work_1 : f32 = yield_force_0 * abs(_S543) + dowel_capacity_0 * (abs(_S544) + abs(_S545));
        st_4.rebar_plastic_0 = st_4.rebar_plastic_0 + _S543;
        st_4.rebar_slip0_0 = st_4.rebar_slip0_0 + _S544;
        st_4.rebar_slip1_0 = st_4.rebar_slip1_0 + _S545;
        st_4.rebar_work_0 = st_4.rebar_work_0 + work_1;
        var dissipated_9 : f32 = dissipated_8 + work_1;
        var _S546 : f32 = nr_0.x;
        var _S547 : f32 = v1_0.x;
        var _S548 : f32 = v2_0.x;
        var elastic_0 : f32 = 0.5f * (fdiv_0(sq_0(_S546), k_axial_0) + fdiv_0(sq_0(_S547) + sq_0(_S548), k_dowel_0));
        if(fracture_1)
        {
            _S523 = (st_4.rebar_work_0) >= ((*b_45).rebar1_0.x);
        }
        else
        {
            _S523 = false;
        }
        if(_S523)
        {
            st_4.rebar_broken_0 = 1.0f;
            var dissipated_10 : f32 = dissipated_9 + elastic_0;
            force_lin_3 = force_lin_2;
            dissipated_5 = dissipated_10;
            stored_7 = stored_6;
        }
        else
        {
            var stored_8 : f32 = stored_6 + elastic_0;
            force_lin_3 = force_lin_2 + vec3<f32>(_S547, _S548, _S546);
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
        _S523 = _S512;
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        _S523 = ((flags_2 & (u32(64)))) != u32(0);
    }
    else
    {
        _S523 = false;
    }
    if(_S523)
    {
        var _S549 : Measures_0 = stress_measures_0(&((*b_45)), force_lin_3, force_ang_2);
        var _S550 : vec4<f32> = failure_indices_0(&((*mat_14)), &((*b_45)), _S549, weibull_0);
        var _S551 : f32 = life_rate_0(&((*mat_14)), max(max(_S550.x, _S550.y), _S550.z));
        st_4.life_0 = max(st_4.life_0 - _S551 * dt_12, 0.0f);
    }
    st_4.dissipated_0 = st_4.dissipated_0 + dissipated_5;
    var resp_0 : JointResponse_0;
    resp_0.force_lin_1 = force_lin_3;
    resp_0.force_ang_1 = force_ang_2;
    resp_0.state_1 = st_4;
    resp_0.dissipated_4 = dissipated_5;
    resp_0.overshoot_0 = overshoot_1;
    resp_0.stored_5 = stored_7;
    if(_S509)
    {
        _S523 = !connected_3(st_4, has_rebar_4);
    }
    else
    {
        _S523 = false;
    }
    resp_0.disconnected_0 = _S523;
    resp_0.fatigue_before_0 = _S514;
    resp_0.measures_0 = _S510;
    return resp_0;
}

fn joint_evaluate_1( mat_15 : ptr<function, JointMaterial_std140_0>,  b_46 : ptr<function, JointBond_std430_0>,  state_3 : ptr<function, JointState_std430_0>,  d_lin_5 : vec3<f32>,  d_ang_5 : vec3<f32>,  dt_13 : f32,  fracture_2 : bool) -> JointResponse_0
{
    var kn_6 : f32 = (*b_46).stiff0_0.x;
    var ks_5 : f32 = (*b_46).stiff0_0.y;
    var kb1_1 : f32 = (*b_46).stiff0_0.z;
    var kb2_1 : f32 = (*b_46).stiff0_0.w;
    var _S552 : vec4<f32> = (*b_46).stiff1_0;
    var kt_5 : f32 = (*b_46).stiff1_0.x;
    var has_rebar_5 : bool = ((*b_46).stiff1_0.w) != 0.0f;
    var kind_5 : u32 = (*mat_15).kind_flags_0.x;
    var flags_3 : u32 = (*mat_15).kind_flags_0.y;
    var softening_1 : bool = ((flags_3 & (u32(1)))) != u32(0);
    var st_5 : JointState_0;
    st_5.damage_0 = (*state_3).damage_0;
    st_5.crush_1 = (*state_3).crush_1;
    st_5.kappa_0 = (*state_3).kappa_0;
    st_5.kappa_c_0 = (*state_3).kappa_c_0;
    st_5.ductility_0 = (*state_3).ductility_0;
    st_5.ductility_c_0 = (*state_3).ductility_c_0;
    st_5.life_0 = (*state_3).life_0;
    st_5.plastic_x_0 = (*state_3).plastic_x_0;
    st_5.plastic_y_0 = (*state_3).plastic_y_0;
    st_5.plastic_t_0 = (*state_3).plastic_t_0;
    st_5.rebar_plastic_0 = (*state_3).rebar_plastic_0;
    st_5.rebar_slip0_0 = (*state_3).rebar_slip0_0;
    st_5.rebar_slip1_0 = (*state_3).rebar_slip1_0;
    st_5.rebar_work_0 = (*state_3).rebar_work_0;
    st_5.rebar_broken_0 = (*state_3).rebar_broken_0;
    st_5.strain_rate_0 = (*state_3).strain_rate_0;
    st_5.governing_stress_0 = (*state_3).governing_stress_0;
    st_5.dissipated_0 = (*state_3).dissipated_0;
    st_5.utilization_0 = (*state_3).utilization_0;
    st_5.mode_0 = (*state_3).mode_0;
    var _S553 : bool = connected_2(&((*state_3)), has_rebar_5);
    var qe_lin_1 : vec3<f32> = d_lin_5 * vec3<f32>(ks_5, ks_5, kn_6);
    var qe_ang_1 : vec3<f32> = d_ang_5 * vec3<f32>(kb1_1, kb2_1, kt_5);
    var _S554 : Measures_0 = stress_measures_1(&((*b_46)), qe_lin_1, qe_ang_1);
    var _S555 : f32 = max(max(_S554.tension_0, _S554.shear_0), _S554.compression_0);
    var _S556 : bool = dt_13 > 0.0f;
    var dif_2 : f32;
    if(_S556)
    {
        var raw_1 : f32 = fdiv_0(max(fdiv_0(_S555 - st_5.governing_stress_0, dt_13), 0.0f), (*mat_15).misc_0.w);
        var tau_3 : f32 = _S552.z;
        if(((flags_3 & (u32(16)))) != u32(0))
        {
            dif_2 = - expm1_accurate_0(- fdiv_0(dt_13, tau_3));
        }
        else
        {
            dif_2 = min(fdiv_0(dt_13, tau_3), 1.0f);
        }
        st_5.strain_rate_0 = st_5.strain_rate_0 + (raw_1 - st_5.strain_rate_0) * dif_2;
        st_5.governing_stress_0 = _S555;
    }
    if(((flags_3 & (u32(32)))) != u32(0))
    {
        var _S557 : f32 = dif_factor_1(&((*mat_15)), st_5.strain_rate_0);
        dif_2 = _S557;
    }
    else
    {
        dif_2 = 1.0f;
    }
    var weibull_1 : f32 = (*b_46).geom1_0.w;
    var _S558 : f32 = fatigue_factor_2(&((*mat_15)), st_5.life_0);
    var multiplier_3 : f32 = weibull_1 * dif_2 * _S558;
    var _S559 : vec4<f32> = failure_indices_1(&((*mat_15)), &((*b_46)), _S554, multiplier_3);
    var _S560 : f32 = _S559.x;
    var _S561 : f32 = _S559.y;
    st_5.utilization_0 = max(max(_S560, _S561), max(_S559.z, _S559.w));
    var _S562 : f32 = d_lin_5.x;
    var _S563 : f32 = d_lin_5.y;
    var _S564 : f32 = ks_5 * (sq_0(_S562) + sq_0(_S563)) + kb1_1 * sq_0(d_ang_5.x) + kb2_1 * sq_0(d_ang_5.y) + kt_5 * sq_0(d_ang_5.z);
    var _S565 : f32 = d_lin_5.z;
    var _S566 : bool = _S565 > 0.0f;
    if(_S566)
    {
        dif_2 = kn_6 * sq_0(_S565);
    }
    else
    {
        dif_2 = 0.0f;
    }
    var psi_ts_1 : f32 = 0.5f * (_S564 + dif_2);
    var psi_c_1 : f32;
    if(_S565 < 0.0f)
    {
        psi_c_1 = 0.5f * kn_6 * sq_0(_S565);
    }
    else
    {
        psi_c_1 = 0.0f;
    }
    var plastic_7 : vec3<f32> = vec3<f32>(st_5.plastic_x_0, st_5.plastic_y_0, st_5.plastic_t_0);
    var diss_contact_1 : f32;
    var psi_contact_1 : f32;
    var intact_normal_1 : f32;
    var dissipated_11 : f32;
    var overshoot_3 : f32;
    var _S567 : bool;
    var qc_lin_1 : vec3<f32>;
    if(fracture_2)
    {
        var _S568 : bool = _S560 >= _S561;
        if(_S568)
        {
            diss_contact_1 = _S560;
        }
        else
        {
            diss_contact_1 = _S561;
        }
        var mode_ts_1 : u32;
        if(_S568)
        {
            mode_ts_1 = u32(1);
        }
        else
        {
            mode_ts_1 = u32(2);
        }
        if(diss_contact_1 > (st_5.kappa_0))
        {
            _S567 = diss_contact_1 > 1.0f;
        }
        else
        {
            _S567 = false;
        }
        if(_S567)
        {
            _S567 = psi_ts_1 > 0.0f;
        }
        else
        {
            _S567 = false;
        }
        var mode_c_1 : u32;
        if(_S567)
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
                intact_normal_1 = fdiv_0(psi_contact_1 * (*b_46).geom0_0.x * diss_contact_1 * diss_contact_1, psi_ts_1);
            }
            else
            {
                intact_normal_1 = 0.0f;
            }
            st_5.ductility_0 = intact_normal_1;
            if(softening_1)
            {
                mode_c_1 = kind_5;
            }
            else
            {
                mode_c_1 = u32(0);
            }
            var inc_2 : vec2<f32> = damage_increment_0(mode_c_1, st_5.kappa_0, diss_contact_1, intact_normal_1, st_5.damage_0, psi_ts_1);
            var _S569 : f32 = inc_2.x;
            if(_S569 > (st_5.damage_0))
            {
                var _S570 : Contact_0 = contact_part_1(&((*mat_15)), &((*b_46)), st_5.crush_1, plastic_7, d_lin_5, d_ang_5);
                var _S571 : f32 = max(_S570.energy_2 - (1.0f - st_5.crush_1) * psi_c_1, 0.0f);
                var _S572 : f32 = max(inc_2.y - _S571 * (_S569 - st_5.damage_0), 0.0f);
                var _S573 : f32 = max((psi_ts_1 - _S571) * (_S569 - st_5.damage_0) - _S572, 0.0f);
                st_5.damage_0 = _S569;
                st_5.mode_0 = mode_ts_1;
                dissipated_11 = _S572;
                overshoot_3 = _S573;
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
        st_5.kappa_0 = max(st_5.kappa_0, diss_contact_1);
        var _S574 : f32 = (*state_3).damage_0;
        if(((*state_3).damage_0) > 0.0f)
        {
            var _S575 : Contact_0 = contact_part_1(&((*mat_15)), &((*b_46)), (*state_3).crush_1, vec3<f32>((*state_3).plastic_x_0, (*state_3).plastic_y_0, (*state_3).plastic_t_0), d_lin_5, d_ang_5);
            qc_lin_1 = qe_ang_1 * vec3<f32>((1.0f - _S574)) + _S575.q_ang_2 * vec3<f32>(_S574);
        }
        else
        {
            qc_lin_1 = qe_ang_1;
        }
        var _S576 : Measures_0 = stress_measures_1(&((*b_46)), vec3<f32>(0.0f, 0.0f, min(qe_lin_1.z, 0.0f)), qc_lin_1);
        var _S577 : vec4<f32> = failure_indices_1(&((*mat_15)), &((*b_46)), _S576, multiplier_3);
        var _S578 : f32 = _S577.z;
        var _S579 : f32 = _S577.w;
        var _S580 : bool = _S578 >= _S579;
        if(_S580)
        {
            psi_contact_1 = _S578;
        }
        else
        {
            psi_contact_1 = _S579;
        }
        if(_S580)
        {
            mode_c_1 = u32(3);
        }
        else
        {
            mode_c_1 = u32(4);
        }
        if(psi_contact_1 > (st_5.kappa_c_0))
        {
            _S567 = psi_contact_1 > 1.0f;
        }
        else
        {
            _S567 = false;
        }
        if(_S567)
        {
            _S567 = psi_c_1 > 0.0f;
        }
        else
        {
            _S567 = false;
        }
        if(_S567)
        {
            if(softening_1)
            {
                intact_normal_1 = fdiv_0((*mat_15).energy_1.w * (*b_46).geom0_0.x * psi_contact_1 * psi_contact_1, psi_c_1);
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
                    mode_ts_1 = kind_5;
                }
                law_2 = mode_ts_1;
            }
            var inc_3 : vec2<f32> = damage_increment_0(law_2, st_5.kappa_c_0, psi_contact_1, intact_normal_1, st_5.crush_1, psi_c_1);
            var _S581 : f32 = inc_3.x;
            if(_S581 > (st_5.crush_1))
            {
                var _S582 : f32 = inc_3.y;
                var dissipated_12 : f32 = dissipated_11 + _S582;
                var overshoot_4 : f32 = overshoot_3 + max(psi_c_1 * (_S581 - st_5.crush_1) - _S582, 0.0f);
                st_5.crush_1 = _S581;
                st_5.mode_0 = mode_c_1;
                if(_S581 >= 1.0f)
                {
                    _S567 = (st_5.damage_0) < 1.0f;
                }
                else
                {
                    _S567 = false;
                }
                if(_S567)
                {
                    var dissipated_13 : f32 = dissipated_12 + psi_ts_1 * (1.0f - st_5.damage_0);
                    st_5.damage_0 = 1.0f;
                    dissipated_11 = dissipated_13;
                }
                else
                {
                    dissipated_11 = dissipated_12;
                }
                overshoot_3 = overshoot_4;
            }
        }
        st_5.kappa_c_0 = max(st_5.kappa_c_0, psi_contact_1);
    }
    else
    {
        dissipated_11 = 0.0f;
        overshoot_3 = 0.0f;
    }
    var dmg_1 : f32 = st_5.damage_0;
    var _S583 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_1 : vec3<f32>;
    if((st_5.damage_0) == 0.0f)
    {
        if(((flags_3 & (u32(8)))) == u32(0))
        {
            var _S584 : vec3<f32> = contact_offsets_1(&((*mat_15)), &((*b_46)), st_5.crush_1, plastic_7, d_lin_5, d_ang_5);
            st_5.plastic_x_0 = _S584.x;
            st_5.plastic_y_0 = _S584.y;
            st_5.plastic_t_0 = _S584.z;
        }
        diss_contact_1 = 0.0f;
        qc_lin_1 = _S583;
        qc_ang_1 = _S583;
        psi_contact_1 = 0.0f;
    }
    else
    {
        var _S585 : Contact_0 = contact_part_1(&((*mat_15)), &((*b_46)), st_5.crush_1, plastic_7, d_lin_5, d_ang_5);
        st_5.plastic_x_0 = _S585.plastic_1.x;
        st_5.plastic_y_0 = _S585.plastic_1.y;
        st_5.plastic_t_0 = _S585.plastic_1.z;
        diss_contact_1 = _S585.diss_2;
        qc_lin_1 = _S585.q_lin_2;
        qc_ang_1 = _S585.q_ang_2;
        psi_contact_1 = _S585.energy_2;
    }
    var dissipated_14 : f32 = dissipated_11 + dmg_1 * diss_contact_1;
    if(_S566)
    {
        intact_normal_1 = kn_6 * _S565;
    }
    else
    {
        intact_normal_1 = (1.0f - st_5.crush_1) * kn_6 * _S565;
    }
    var _S586 : f32 = 1.0f - dmg_1;
    var force_lin_4 : vec3<f32> = vec3<f32>(_S586 * qe_lin_1.x + dmg_1 * qc_lin_1.x, _S586 * qe_lin_1.y + dmg_1 * qc_lin_1.y, _S586 * intact_normal_1 + dmg_1 * qc_lin_1.z);
    var force_ang_3 : vec3<f32> = qe_ang_1 * vec3<f32>(_S586) + qc_ang_1 * vec3<f32>(dmg_1);
    var stored_9 : f32 = _S586 * (psi_ts_1 + (1.0f - st_5.crush_1) * psi_c_1) + dmg_1 * psi_contact_1;
    if(has_rebar_5)
    {
        _S567 = (st_5.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S567 = false;
    }
    var stored_10 : f32;
    var force_lin_5 : vec3<f32>;
    if(_S567)
    {
        var k_axial_1 : f32 = (*b_46).rebar0_0.x;
        var k_dowel_1 : f32 = (*b_46).rebar0_0.y;
        var yield_force_1 : f32 = (*b_46).rebar0_0.z;
        var dowel_capacity_1 : f32 = (*b_46).rebar0_0.w;
        var nr_1 : vec2<f32> = return_map_0(k_axial_1, _S565, st_5.rebar_plastic_0, yield_force_1);
        var v1_1 : vec2<f32> = return_map_0(k_dowel_1, _S562, st_5.rebar_slip0_0, dowel_capacity_1);
        var v2_1 : vec2<f32> = return_map_0(k_dowel_1, _S563, st_5.rebar_slip1_0, dowel_capacity_1);
        var _S587 : f32 = nr_1.y;
        var _S588 : f32 = v1_1.y;
        var _S589 : f32 = v2_1.y;
        var work_2 : f32 = yield_force_1 * abs(_S587) + dowel_capacity_1 * (abs(_S588) + abs(_S589));
        st_5.rebar_plastic_0 = st_5.rebar_plastic_0 + _S587;
        st_5.rebar_slip0_0 = st_5.rebar_slip0_0 + _S588;
        st_5.rebar_slip1_0 = st_5.rebar_slip1_0 + _S589;
        st_5.rebar_work_0 = st_5.rebar_work_0 + work_2;
        var dissipated_15 : f32 = dissipated_14 + work_2;
        var _S590 : f32 = nr_1.x;
        var _S591 : f32 = v1_1.x;
        var _S592 : f32 = v2_1.x;
        var elastic_1 : f32 = 0.5f * (fdiv_0(sq_0(_S590), k_axial_1) + fdiv_0(sq_0(_S591) + sq_0(_S592), k_dowel_1));
        if(fracture_2)
        {
            _S567 = (st_5.rebar_work_0) >= ((*b_46).rebar1_0.x);
        }
        else
        {
            _S567 = false;
        }
        if(_S567)
        {
            st_5.rebar_broken_0 = 1.0f;
            var dissipated_16 : f32 = dissipated_15 + elastic_1;
            force_lin_5 = force_lin_4;
            dissipated_11 = dissipated_16;
            stored_10 = stored_9;
        }
        else
        {
            var stored_11 : f32 = stored_9 + elastic_1;
            force_lin_5 = force_lin_4 + vec3<f32>(_S591, _S592, _S590);
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
        _S567 = _S556;
    }
    else
    {
        _S567 = false;
    }
    if(_S567)
    {
        _S567 = ((flags_3 & (u32(64)))) != u32(0);
    }
    else
    {
        _S567 = false;
    }
    if(_S567)
    {
        var _S593 : Measures_0 = stress_measures_1(&((*b_46)), force_lin_5, force_ang_3);
        var _S594 : vec4<f32> = failure_indices_1(&((*mat_15)), &((*b_46)), _S593, weibull_1);
        var _S595 : f32 = life_rate_1(&((*mat_15)), max(max(_S594.x, _S594.y), _S594.z));
        st_5.life_0 = max(st_5.life_0 - _S595 * dt_13, 0.0f);
    }
    st_5.dissipated_0 = st_5.dissipated_0 + dissipated_11;
    var resp_1 : JointResponse_0;
    resp_1.force_lin_1 = force_lin_5;
    resp_1.force_ang_1 = force_ang_3;
    resp_1.state_1 = st_5;
    resp_1.dissipated_4 = dissipated_11;
    resp_1.overshoot_0 = overshoot_3;
    resp_1.stored_5 = stored_10;
    if(_S553)
    {
        _S567 = !connected_3(st_5, has_rebar_5);
    }
    else
    {
        _S567 = false;
    }
    resp_1.disconnected_0 = _S567;
    resp_1.fatigue_before_0 = _S558;
    resp_1.measures_0 = _S554;
    return resp_1;
}

fn joint_evaluate_2( mat_16 : ptr<function, JointMaterial_std140_0>,  b_47 : ptr<function, JointBond_std430_0>,  state_4 : JointState_0,  d_lin_6 : vec3<f32>,  d_ang_6 : vec3<f32>,  dt_14 : f32,  fracture_3 : bool) -> JointResponse_0
{
    var kn_7 : f32 = (*b_47).stiff0_0.x;
    var ks_6 : f32 = (*b_47).stiff0_0.y;
    var kb1_2 : f32 = (*b_47).stiff0_0.z;
    var kb2_2 : f32 = (*b_47).stiff0_0.w;
    var _S596 : vec4<f32> = (*b_47).stiff1_0;
    var kt_6 : f32 = (*b_47).stiff1_0.x;
    var has_rebar_6 : bool = ((*b_47).stiff1_0.w) != 0.0f;
    var kind_6 : u32 = (*mat_16).kind_flags_0.x;
    var flags_4 : u32 = (*mat_16).kind_flags_0.y;
    var softening_2 : bool = ((flags_4 & (u32(1)))) != u32(0);
    var st_6 : JointState_0 = state_4;
    var was_connected_0 : bool = connected_3(state_4, has_rebar_6);
    var qe_lin_2 : vec3<f32> = d_lin_6 * vec3<f32>(ks_6, ks_6, kn_7);
    var qe_ang_2 : vec3<f32> = d_ang_6 * vec3<f32>(kb1_2, kb2_2, kt_6);
    var _S597 : Measures_0 = stress_measures_1(&((*b_47)), qe_lin_2, qe_ang_2);
    var _S598 : f32 = max(max(_S597.tension_0, _S597.shear_0), _S597.compression_0);
    var _S599 : bool = dt_14 > 0.0f;
    var dif_3 : f32;
    if(_S599)
    {
        var raw_2 : f32 = fdiv_0(max(fdiv_0(_S598 - st_6.governing_stress_0, dt_14), 0.0f), (*mat_16).misc_0.w);
        var tau_4 : f32 = _S596.z;
        if(((flags_4 & (u32(16)))) != u32(0))
        {
            dif_3 = - expm1_accurate_0(- fdiv_0(dt_14, tau_4));
        }
        else
        {
            dif_3 = min(fdiv_0(dt_14, tau_4), 1.0f);
        }
        st_6.strain_rate_0 = st_6.strain_rate_0 + (raw_2 - st_6.strain_rate_0) * dif_3;
        st_6.governing_stress_0 = _S598;
    }
    if(((flags_4 & (u32(32)))) != u32(0))
    {
        var _S600 : f32 = dif_factor_1(&((*mat_16)), st_6.strain_rate_0);
        dif_3 = _S600;
    }
    else
    {
        dif_3 = 1.0f;
    }
    var weibull_2 : f32 = (*b_47).geom1_0.w;
    var _S601 : f32 = fatigue_factor_2(&((*mat_16)), st_6.life_0);
    var multiplier_4 : f32 = weibull_2 * dif_3 * _S601;
    var _S602 : vec4<f32> = failure_indices_1(&((*mat_16)), &((*b_47)), _S597, multiplier_4);
    var _S603 : f32 = _S602.x;
    var _S604 : f32 = _S602.y;
    st_6.utilization_0 = max(max(_S603, _S604), max(_S602.z, _S602.w));
    var _S605 : f32 = d_lin_6.x;
    var _S606 : f32 = d_lin_6.y;
    var _S607 : f32 = ks_6 * (sq_0(_S605) + sq_0(_S606)) + kb1_2 * sq_0(d_ang_6.x) + kb2_2 * sq_0(d_ang_6.y) + kt_6 * sq_0(d_ang_6.z);
    var _S608 : f32 = d_lin_6.z;
    var _S609 : bool = _S608 > 0.0f;
    if(_S609)
    {
        dif_3 = kn_7 * sq_0(_S608);
    }
    else
    {
        dif_3 = 0.0f;
    }
    var psi_ts_2 : f32 = 0.5f * (_S607 + dif_3);
    var psi_c_2 : f32;
    if(_S608 < 0.0f)
    {
        psi_c_2 = 0.5f * kn_7 * sq_0(_S608);
    }
    else
    {
        psi_c_2 = 0.0f;
    }
    var plastic_8 : vec3<f32> = vec3<f32>(st_6.plastic_x_0, st_6.plastic_y_0, st_6.plastic_t_0);
    var diss_contact_2 : f32;
    var psi_contact_2 : f32;
    var intact_normal_2 : f32;
    var dissipated_17 : f32;
    var overshoot_5 : f32;
    var _S610 : bool;
    var qc_lin_2 : vec3<f32>;
    if(fracture_3)
    {
        var _S611 : bool = _S603 >= _S604;
        if(_S611)
        {
            diss_contact_2 = _S603;
        }
        else
        {
            diss_contact_2 = _S604;
        }
        var mode_ts_2 : u32;
        if(_S611)
        {
            mode_ts_2 = u32(1);
        }
        else
        {
            mode_ts_2 = u32(2);
        }
        if(diss_contact_2 > (st_6.kappa_0))
        {
            _S610 = diss_contact_2 > 1.0f;
        }
        else
        {
            _S610 = false;
        }
        if(_S610)
        {
            _S610 = psi_ts_2 > 0.0f;
        }
        else
        {
            _S610 = false;
        }
        var mode_c_2 : u32;
        if(_S610)
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
                intact_normal_2 = fdiv_0(psi_contact_2 * (*b_47).geom0_0.x * diss_contact_2 * diss_contact_2, psi_ts_2);
            }
            else
            {
                intact_normal_2 = 0.0f;
            }
            st_6.ductility_0 = intact_normal_2;
            if(softening_2)
            {
                mode_c_2 = kind_6;
            }
            else
            {
                mode_c_2 = u32(0);
            }
            var inc_4 : vec2<f32> = damage_increment_0(mode_c_2, st_6.kappa_0, diss_contact_2, intact_normal_2, st_6.damage_0, psi_ts_2);
            var _S612 : f32 = inc_4.x;
            if(_S612 > (st_6.damage_0))
            {
                var _S613 : Contact_0 = contact_part_1(&((*mat_16)), &((*b_47)), st_6.crush_1, plastic_8, d_lin_6, d_ang_6);
                var _S614 : f32 = max(_S613.energy_2 - (1.0f - st_6.crush_1) * psi_c_2, 0.0f);
                var _S615 : f32 = max(inc_4.y - _S614 * (_S612 - st_6.damage_0), 0.0f);
                var _S616 : f32 = max((psi_ts_2 - _S614) * (_S612 - st_6.damage_0) - _S615, 0.0f);
                st_6.damage_0 = _S612;
                st_6.mode_0 = mode_ts_2;
                dissipated_17 = _S615;
                overshoot_5 = _S616;
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
        st_6.kappa_0 = max(st_6.kappa_0, diss_contact_2);
        if((state_4.damage_0) > 0.0f)
        {
            var _S617 : Contact_0 = contact_part_1(&((*mat_16)), &((*b_47)), state_4.crush_1, vec3<f32>(state_4.plastic_x_0, state_4.plastic_y_0, state_4.plastic_t_0), d_lin_6, d_ang_6);
            qc_lin_2 = qe_ang_2 * vec3<f32>((1.0f - state_4.damage_0)) + _S617.q_ang_2 * vec3<f32>(state_4.damage_0);
        }
        else
        {
            qc_lin_2 = qe_ang_2;
        }
        var _S618 : Measures_0 = stress_measures_1(&((*b_47)), vec3<f32>(0.0f, 0.0f, min(qe_lin_2.z, 0.0f)), qc_lin_2);
        var _S619 : vec4<f32> = failure_indices_1(&((*mat_16)), &((*b_47)), _S618, multiplier_4);
        var _S620 : f32 = _S619.z;
        var _S621 : f32 = _S619.w;
        var _S622 : bool = _S620 >= _S621;
        if(_S622)
        {
            psi_contact_2 = _S620;
        }
        else
        {
            psi_contact_2 = _S621;
        }
        if(_S622)
        {
            mode_c_2 = u32(3);
        }
        else
        {
            mode_c_2 = u32(4);
        }
        if(psi_contact_2 > (st_6.kappa_c_0))
        {
            _S610 = psi_contact_2 > 1.0f;
        }
        else
        {
            _S610 = false;
        }
        if(_S610)
        {
            _S610 = psi_c_2 > 0.0f;
        }
        else
        {
            _S610 = false;
        }
        if(_S610)
        {
            if(softening_2)
            {
                intact_normal_2 = fdiv_0((*mat_16).energy_1.w * (*b_47).geom0_0.x * psi_contact_2 * psi_contact_2, psi_c_2);
            }
            else
            {
                intact_normal_2 = 0.0f;
            }
            st_6.ductility_c_0 = intact_normal_2;
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
            var inc_5 : vec2<f32> = damage_increment_0(law_3, st_6.kappa_c_0, psi_contact_2, intact_normal_2, st_6.crush_1, psi_c_2);
            var _S623 : f32 = inc_5.x;
            if(_S623 > (st_6.crush_1))
            {
                var _S624 : f32 = inc_5.y;
                var dissipated_18 : f32 = dissipated_17 + _S624;
                var overshoot_6 : f32 = overshoot_5 + max(psi_c_2 * (_S623 - st_6.crush_1) - _S624, 0.0f);
                st_6.crush_1 = _S623;
                st_6.mode_0 = mode_c_2;
                if(_S623 >= 1.0f)
                {
                    _S610 = (st_6.damage_0) < 1.0f;
                }
                else
                {
                    _S610 = false;
                }
                if(_S610)
                {
                    var dissipated_19 : f32 = dissipated_18 + psi_ts_2 * (1.0f - st_6.damage_0);
                    st_6.damage_0 = 1.0f;
                    dissipated_17 = dissipated_19;
                }
                else
                {
                    dissipated_17 = dissipated_18;
                }
                overshoot_5 = overshoot_6;
            }
        }
        st_6.kappa_c_0 = max(st_6.kappa_c_0, psi_contact_2);
    }
    else
    {
        dissipated_17 = 0.0f;
        overshoot_5 = 0.0f;
    }
    var dmg_2 : f32 = st_6.damage_0;
    var _S625 : vec3<f32> = vec3<f32>(0.0f);
    var qc_ang_2 : vec3<f32>;
    if((st_6.damage_0) == 0.0f)
    {
        if(((flags_4 & (u32(8)))) == u32(0))
        {
            var _S626 : vec3<f32> = contact_offsets_1(&((*mat_16)), &((*b_47)), st_6.crush_1, plastic_8, d_lin_6, d_ang_6);
            st_6.plastic_x_0 = _S626.x;
            st_6.plastic_y_0 = _S626.y;
            st_6.plastic_t_0 = _S626.z;
        }
        diss_contact_2 = 0.0f;
        qc_lin_2 = _S625;
        qc_ang_2 = _S625;
        psi_contact_2 = 0.0f;
    }
    else
    {
        var _S627 : Contact_0 = contact_part_1(&((*mat_16)), &((*b_47)), st_6.crush_1, plastic_8, d_lin_6, d_ang_6);
        st_6.plastic_x_0 = _S627.plastic_1.x;
        st_6.plastic_y_0 = _S627.plastic_1.y;
        st_6.plastic_t_0 = _S627.plastic_1.z;
        diss_contact_2 = _S627.diss_2;
        qc_lin_2 = _S627.q_lin_2;
        qc_ang_2 = _S627.q_ang_2;
        psi_contact_2 = _S627.energy_2;
    }
    var dissipated_20 : f32 = dissipated_17 + dmg_2 * diss_contact_2;
    if(_S609)
    {
        intact_normal_2 = kn_7 * _S608;
    }
    else
    {
        intact_normal_2 = (1.0f - st_6.crush_1) * kn_7 * _S608;
    }
    var _S628 : f32 = 1.0f - dmg_2;
    var force_lin_6 : vec3<f32> = vec3<f32>(_S628 * qe_lin_2.x + dmg_2 * qc_lin_2.x, _S628 * qe_lin_2.y + dmg_2 * qc_lin_2.y, _S628 * intact_normal_2 + dmg_2 * qc_lin_2.z);
    var force_ang_4 : vec3<f32> = qe_ang_2 * vec3<f32>(_S628) + qc_ang_2 * vec3<f32>(dmg_2);
    var stored_12 : f32 = _S628 * (psi_ts_2 + (1.0f - st_6.crush_1) * psi_c_2) + dmg_2 * psi_contact_2;
    if(has_rebar_6)
    {
        _S610 = (st_6.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S610 = false;
    }
    var stored_13 : f32;
    var force_lin_7 : vec3<f32>;
    if(_S610)
    {
        var k_axial_2 : f32 = (*b_47).rebar0_0.x;
        var k_dowel_2 : f32 = (*b_47).rebar0_0.y;
        var yield_force_2 : f32 = (*b_47).rebar0_0.z;
        var dowel_capacity_2 : f32 = (*b_47).rebar0_0.w;
        var nr_2 : vec2<f32> = return_map_0(k_axial_2, _S608, st_6.rebar_plastic_0, yield_force_2);
        var v1_2 : vec2<f32> = return_map_0(k_dowel_2, _S605, st_6.rebar_slip0_0, dowel_capacity_2);
        var v2_2 : vec2<f32> = return_map_0(k_dowel_2, _S606, st_6.rebar_slip1_0, dowel_capacity_2);
        var _S629 : f32 = nr_2.y;
        var _S630 : f32 = v1_2.y;
        var _S631 : f32 = v2_2.y;
        var work_3 : f32 = yield_force_2 * abs(_S629) + dowel_capacity_2 * (abs(_S630) + abs(_S631));
        st_6.rebar_plastic_0 = st_6.rebar_plastic_0 + _S629;
        st_6.rebar_slip0_0 = st_6.rebar_slip0_0 + _S630;
        st_6.rebar_slip1_0 = st_6.rebar_slip1_0 + _S631;
        st_6.rebar_work_0 = st_6.rebar_work_0 + work_3;
        var dissipated_21 : f32 = dissipated_20 + work_3;
        var _S632 : f32 = nr_2.x;
        var _S633 : f32 = v1_2.x;
        var _S634 : f32 = v2_2.x;
        var elastic_2 : f32 = 0.5f * (fdiv_0(sq_0(_S632), k_axial_2) + fdiv_0(sq_0(_S633) + sq_0(_S634), k_dowel_2));
        if(fracture_3)
        {
            _S610 = (st_6.rebar_work_0) >= ((*b_47).rebar1_0.x);
        }
        else
        {
            _S610 = false;
        }
        if(_S610)
        {
            st_6.rebar_broken_0 = 1.0f;
            var dissipated_22 : f32 = dissipated_21 + elastic_2;
            force_lin_7 = force_lin_6;
            dissipated_17 = dissipated_22;
            stored_13 = stored_12;
        }
        else
        {
            var stored_14 : f32 = stored_12 + elastic_2;
            force_lin_7 = force_lin_6 + vec3<f32>(_S633, _S634, _S632);
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
        _S610 = _S599;
    }
    else
    {
        _S610 = false;
    }
    if(_S610)
    {
        _S610 = ((flags_4 & (u32(64)))) != u32(0);
    }
    else
    {
        _S610 = false;
    }
    if(_S610)
    {
        var _S635 : Measures_0 = stress_measures_1(&((*b_47)), force_lin_7, force_ang_4);
        var _S636 : vec4<f32> = failure_indices_1(&((*mat_16)), &((*b_47)), _S635, weibull_2);
        var _S637 : f32 = life_rate_1(&((*mat_16)), max(max(_S636.x, _S636.y), _S636.z));
        st_6.life_0 = max(st_6.life_0 - _S637 * dt_14, 0.0f);
    }
    st_6.dissipated_0 = st_6.dissipated_0 + dissipated_17;
    var resp_2 : JointResponse_0;
    resp_2.force_lin_1 = force_lin_7;
    resp_2.force_ang_1 = force_ang_4;
    resp_2.state_1 = st_6;
    resp_2.dissipated_4 = dissipated_17;
    resp_2.overshoot_0 = overshoot_5;
    resp_2.stored_5 = stored_13;
    if(was_connected_0)
    {
        _S610 = !connected_3(st_6, has_rebar_6);
    }
    else
    {
        _S610 = false;
    }
    resp_2.disconnected_0 = _S610;
    resp_2.fatigue_before_0 = _S601;
    resp_2.measures_0 = _S597;
    return resp_2;
}

fn to_local_0( _S638 : u32,  _S639 : vec3<f32>) -> vec3<f32>
{
    return vec3<f32>(dot(_S639, bonds_0[_S638].t1_0.xyz), dot(_S639, bonds_0[_S638].t2_0.xyz), dot(_S639, bonds_0[_S638].normal_0.xyz));
}

fn static_kinematics_0( _S640 : u32,  _S641 : ptr<function, vec3<f32>>,  _S642 : ptr<function, vec3<f32>>)
{
    var ca_1 : u32 = bonds_0[_S640].law_0.ids_0.y;
    var cb_4 : u32 = bonds_0[_S640].law_0.ids_0.z;
    var _S643 : u32 = u32(4) * cb_4;
    var _S644 : u32 = u32(4) * ca_1;
    var _S645 : u32 = _S643 + u32(1);
    var _S646 : u32 = _S644 + u32(1);
    var _S647 : u32 = sv_0(cb_4, u32(22));
    var _S648 : u32 = sv_0(ca_1, u32(22));
    var dth_0 : vec3<f32> = state_0[_S645].xyz - state_0[_S646].xyz + (scratch_0[_S647].xyz - scratch_0[_S648].xyz);
    (*_S641) = to_local_0(_S640, state_0[_S643].xyz - state_0[_S644].xyz + (scratch_0[sv_0(cb_4, u32(21))].xyz - scratch_0[sv_0(ca_1, u32(21))].xyz) + (cross(state_0[_S645].xyz + scratch_0[_S647].xyz, bonds_0[_S640].rb_0.xyz) - cross(state_0[_S646].xyz + scratch_0[_S648].xyz, bonds_0[_S640].ra_0.xyz)));
    (*_S642) = to_local_0(_S640, dth_0);
    return;
}

fn static_response_0( i_11 : u32) -> JointResponse_0
{
    var d_lin_7 : vec3<f32>;
    var d_ang_7 : vec3<f32>;
    static_kinematics_0(i_11, &(d_lin_7), &(d_ang_7));
    var _S649 : JointBond_std430_0 = bonds_0[i_11].law_0;
    var _S650 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S649.ids_0.x];
    var _S651 : JointState_std430_0 = bond_dyn_0[i_11].js_0;
    var _S652 : JointResponse_0 = joint_evaluate_1(&(_S650), &(_S649), &(_S651), d_lin_7, d_ang_7, 0.0f, false);
    return _S652;
}

fn gather_loads_0( c_23 : u32,  fi_1 : ptr<function, vec3<f32>>,  mi_0 : ptr<function, vec3<f32>>)
{
    var _S653 : vec3<f32> = vec3<f32>(0.0f);
    (*fi_1) = _S653;
    (*mi_0) = _S653;
    var e_3 : u32 = index_0[c_23];
    loop
    {
        if(e_3 < index_0[c_23 + u32(1)])
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
            var _S654 : u32 = u32(3) * bond_1;
            (*fi_1) = (*fi_1) + scratch_0[_S654].xyz;
            (*mi_0) = (*mi_0) + scratch_0[_S654 + u32(1)].xyz;
        }
        else
        {
            var _S655 : u32 = u32(3) * bond_1;
            (*fi_1) = (*fi_1) - scratch_0[_S655].xyz;
            (*mi_0) = (*mi_0) + scratch_0[_S655 + u32(2)].xyz;
        }
        e_3 = e_3 + u32(1);
    }
    return;
}

fn bond_load_magnitude2_0( c_24 : u32) -> f32
{
    var e_4 : u32 = index_0[c_24];
    var m_6 : f32 = 0.0f;
    loop
    {
        if(e_4 < index_0[c_24 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_3 : u32 = index_0[e_4];
        var _S656 : u32 = u32(3) * ((entry_3 >> (u32(1))));
        var f_16 : vec3<f32> = scratch_0[_S656].xyz;
        var t_18 : vec3<f32>;
        if(((entry_3 & (u32(1)))) == u32(0))
        {
            t_18 = scratch_0[_S656 + u32(1)].xyz;
        }
        else
        {
            t_18 = scratch_0[_S656 + u32(2)].xyz;
        }
        var m_7 : f32 = m_6 + (dot(f_16, f_16) + dot(t_18, t_18));
        e_4 = e_4 + u32(1);
        m_6 = m_7;
    }
    return m_6;
}

fn fixed_mask_0( c_25 : u32) -> u32
{
    var support_0 : u32 = chunks_0[c_25].info_1.x;
    var _S657 : u32;
    if(support_0 == u32(1))
    {
        _S657 = u32(63);
    }
    else
    {
        if(support_0 == u32(2))
        {
            _S657 = u32(7);
        }
        else
        {
            _S657 = u32(0);
        }
    }
    return _S657;
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

fn secant_factors_0( b_48 : ptr<function, JointBond_std430_0>,  st_7 : ptr<function, JointState_std430_0>,  d_lin_8 : vec3<f32>,  f_lin_0 : ptr<function, vec3<f32>>,  f_ang_0 : ptr<function, vec3<f32>>)
{
    var _S658 : f32 = (*st_7).damage_0;
    var compressed_0 : bool = (d_lin_8.z) < 0.0f;
    var contact_1 : f32;
    if(compressed_0)
    {
        contact_1 = _S658;
    }
    else
    {
        contact_1 = 0.0f;
    }
    var _S659 : f32 = 1.0f - _S658;
    var _S660 : f32 = max(_S659 + contact_1, 9.99999997475242708e-07f);
    var normal_7 : f32;
    if(compressed_0)
    {
        normal_7 = max(1.0f - (*st_7).crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_7 = max(_S659, 9.99999997475242708e-07f);
    }
    (*f_lin_0) = vec3<f32>(_S660, _S660, normal_7);
    (*f_ang_0) = vec3<f32>(_S660);
    var _S661 : bool;
    if(((*b_48).stiff1_0.w) != 0.0f)
    {
        _S661 = ((*st_7).rebar_broken_0) == 0.0f;
    }
    else
    {
        _S661 = false;
    }
    if(_S661)
    {
        var _S662 : vec4<f32> = (*b_48).rebar0_0;
        var _S663 : vec4<f32> = (*b_48).stiff0_0;
        (*f_lin_0)[i32(2)] = (*f_lin_0)[i32(2)] + fdiv_0((*b_48).rebar0_0.x, (*b_48).stiff0_0.x);
        var _S664 : f32 = fdiv_0(_S662.y, _S663.y);
        (*f_lin_0)[i32(0)] = (*f_lin_0)[i32(0)] + _S664;
        (*f_lin_0)[i32(1)] = (*f_lin_0)[i32(1)] + _S664;
    }
    return;
}

fn secant_factors_1( b_49 : ptr<function, JointBond_std430_0>,  st_8 : JointState_0,  d_lin_9 : vec3<f32>,  f_lin_1 : ptr<function, vec3<f32>>,  f_ang_1 : ptr<function, vec3<f32>>)
{
    var compressed_1 : bool = (d_lin_9.z) < 0.0f;
    var contact_2 : f32;
    if(compressed_1)
    {
        contact_2 = st_8.damage_0;
    }
    else
    {
        contact_2 = 0.0f;
    }
    var _S665 : f32 = 1.0f - st_8.damage_0;
    var _S666 : f32 = max(_S665 + contact_2, 9.99999997475242708e-07f);
    var normal_8 : f32;
    if(compressed_1)
    {
        normal_8 = max(1.0f - st_8.crush_1, 9.99999997475242708e-07f);
    }
    else
    {
        normal_8 = max(_S665, 9.99999997475242708e-07f);
    }
    (*f_lin_1) = vec3<f32>(_S666, _S666, normal_8);
    (*f_ang_1) = vec3<f32>(_S666);
    var _S667 : bool;
    if(((*b_49).stiff1_0.w) != 0.0f)
    {
        _S667 = (st_8.rebar_broken_0) == 0.0f;
    }
    else
    {
        _S667 = false;
    }
    if(_S667)
    {
        var _S668 : vec4<f32> = (*b_49).rebar0_0;
        var _S669 : vec4<f32> = (*b_49).stiff0_0;
        (*f_lin_1)[i32(2)] = (*f_lin_1)[i32(2)] + fdiv_0((*b_49).rebar0_0.x, (*b_49).stiff0_0.x);
        var _S670 : f32 = fdiv_0(_S668.y, _S669.y);
        (*f_lin_1)[i32(0)] = (*f_lin_1)[i32(0)] + _S670;
        (*f_lin_1)[i32(1)] = (*f_lin_1)[i32(1)] + _S670;
    }
    return;
}

fn statics_bond_slot_0( i_12 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * i_12;
}

fn store_inverse_0( c_26 : u32,  a_24 : array<f32, i32(36)>)
{
    var j_11 : u32;
    var sum_9 : f32;
    var l_5 : array<f32, i32(36)>;
    var k_19 : u32 = u32(0);
    loop
    {
        if(k_19 < u32(36))
        {
        }
        else
        {
            break;
        }
        l_5[k_19] = 0.0f;
        k_19 = k_19 + u32(1);
    }
    var spd_0 : bool = true;
    var i_13 : u32 = u32(0);
    loop
    {
        var _S671 : bool;
        if(i_13 < u32(6))
        {
            _S671 = spd_0;
        }
        else
        {
            _S671 = false;
        }
        if(_S671)
        {
        }
        else
        {
            break;
        }
        j_11 = u32(0);
        loop
        {
            if(j_11 <= i_13)
            {
            }
            else
            {
                break;
            }
            var _S672 : u32 = i_13 * u32(6);
            var _S673 : u32 = _S672 + j_11;
            k_19 = u32(0);
            sum_9 = a_24[_S673];
            loop
            {
                if(k_19 < j_11)
                {
                }
                else
                {
                    break;
                }
                var sum_10 : f32 = sum_9 - l_5[_S672 + k_19] * l_5[j_11 * u32(6) + k_19];
                k_19 = k_19 + u32(1);
                sum_9 = sum_10;
            }
            if(i_13 == j_11)
            {
                if(sum_9 <= 0.0f)
                {
                    spd_0 = false;
                    break;
                }
                l_5[_S672 + i_13] = sqrt(sum_9);
            }
            else
            {
                l_5[_S673] = sum_9 / l_5[j_11 * u32(6) + j_11];
            }
            j_11 = j_11 + u32(1);
        }
        i_13 = i_13 + u32(1);
    }
    var inv_0 : array<f32, i32(36)>;
    if(!spd_0)
    {
        k_19 = u32(0);
        loop
        {
            if(k_19 < u32(36))
            {
            }
            else
            {
                break;
            }
            inv_0[k_19] = 0.0f;
            k_19 = k_19 + u32(1);
        }
        k_19 = u32(0);
        loop
        {
            if(k_19 < u32(6))
            {
            }
            else
            {
                break;
            }
            var _S674 : u32 = k_19 * u32(6) + k_19;
            if((a_24[_S674]) > 0.0f)
            {
                sum_9 = 1.0f / a_24[_S674];
            }
            else
            {
                sum_9 = 0.0f;
            }
            inv_0[_S674] = sum_9;
            k_19 = k_19 + u32(1);
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
                if(i_13 == j_11)
                {
                    sum_9 = 1.0f;
                }
                else
                {
                    sum_9 = 0.0f;
                }
                k_19 = u32(0);
                var s_12 : f32 = sum_9;
                loop
                {
                    if(k_19 < i_13)
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_13 : f32 = s_12 - l_5[i_13 * u32(6) + k_19] * y_5[k_19];
                    k_19 = k_19 + u32(1);
                    s_12 = s_13;
                }
                y_5[i_13] = s_12 / l_5[i_13 * u32(6) + i_13];
                i_13 = i_13 + u32(1);
            }
            var x_22 : array<f32, i32(6)>;
            x_22[i32(0)] = 0.0f;
            x_22[i32(1)] = 0.0f;
            x_22[i32(2)] = 0.0f;
            x_22[i32(3)] = 0.0f;
            x_22[i32(4)] = 0.0f;
            x_22[i32(5)] = 0.0f;
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
                var i_14 : u32 = u32(5) - ii_1;
                k_19 = i_14 + u32(1);
                sum_9 = y_5[i_14];
                loop
                {
                    if(k_19 < u32(6))
                    {
                    }
                    else
                    {
                        break;
                    }
                    var s_14 : f32 = sum_9 - l_5[k_19 * u32(6) + i_14] * x_22[k_19];
                    k_19 = k_19 + u32(1);
                    sum_9 = s_14;
                }
                x_22[i_14] = sum_9 / l_5[i_14 * u32(6) + i_14];
                ii_1 = ii_1 + u32(1);
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
                inv_0[i_15 * u32(6) + j_11] = x_22[i_15];
                i_15 = i_15 + u32(1);
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
        var _S675 : u32 = u32(4) * j_11;
        scratch_0[sv_0(c_26, u32(12) + j_11)] = vec4<f32>(inv_0[_S675], inv_0[_S675 + u32(1)], inv_0[_S675 + u32(2)], inv_0[_S675 + u32(3)]);
        j_11 = j_11 + u32(1);
    }
    return;
}

fn assemble_block_0( c_27 : u32)
{
    var p_21 : u32;
    var r_14 : u32;
    var a_25 : array<f32, i32(36)>;
    var k_20 : u32 = u32(0);
    loop
    {
        if(k_20 < u32(36))
        {
        }
        else
        {
            break;
        }
        a_25[k_20] = 0.0f;
        k_20 = k_20 + u32(1);
    }
    var e_5 : u32 = index_0[c_27];
    loop
    {
        if(e_5 < index_0[c_27 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_4 : u32 = index_0[e_5];
        var i_16 : u32 = (entry_4 >> (u32(1)));
        var _S676 : bool = ((entry_4 & (u32(1)))) != u32(0);
        var _S677 : u32 = statics_bond_slot_0(i_16);
        var _S678 : vec4<f32> = scratch_0[_S677];
        var _S679 : vec4<f32> = scratch_0[_S677 + u32(1)];
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
            var _S680 : u32 = p_21 % u32(3);
            var t_19 : vec3<f32>;
            if(_S680 == u32(0))
            {
                t_19 = bonds_0[i_16].t1_0.xyz;
            }
            else
            {
                if(_S680 == u32(1))
                {
                    t_19 = bonds_0[i_16].t2_0.xyz;
                }
                else
                {
                    t_19 = bonds_0[i_16].normal_0.xyz;
                }
            }
            var _S681 : bool = p_21 < u32(3);
            var row_u_0 : vec3<f32>;
            var row_t_0 : vec3<f32>;
            if(_S681)
            {
                if(_S676)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_19);
                }
                if(_S676)
                {
                    row_t_0 = cross(bonds_0[i_16].rb_0.xyz, t_19);
                }
                else
                {
                    row_t_0 = (vec3<f32>(0) - cross(bonds_0[i_16].ra_0.xyz, t_19));
                }
            }
            else
            {
                var _S682 : vec3<f32> = vec3<f32>(0.0f);
                if(_S676)
                {
                    row_u_0 = t_19;
                }
                else
                {
                    row_u_0 = (vec3<f32>(0) - t_19);
                }
                var _S683 : vec3<f32> = row_u_0;
                row_u_0 = _S682;
                row_t_0 = _S683;
            }
            var kp_0 : f32;
            if(_S681)
            {
                kp_0 = _S678[p_21];
            }
            else
            {
                kp_0 = _S679[p_21 - u32(3)];
            }
            if(kp_0 == 0.0f)
            {
                p_21 = p_21 + u32(1);
                continue;
            }
            var _S684 : array<f32, i32(6)> = array<f32, i32(6)>( row_u_0.x, row_u_0.y, row_u_0.z, row_t_0.x, row_t_0.y, row_t_0.z );
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
                    a_25[r_14 * u32(6) + q_13] = a_25[r_14 * u32(6) + q_13] + kp_0 * _S684[r_14] * _S684[q_13];
                    q_13 = q_13 + u32(1);
                }
                r_14 = r_14 + u32(1);
            }
            p_21 = p_21 + u32(1);
        }
        e_5 = e_5 + u32(1);
    }
    var _S685 : u32 = fixed_mask_0(c_27);
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
        if(((_S685 & (((u32(1) << (p_21)))))) != u32(0))
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
                a_25[p_21 * u32(6) + r_14] = 0.0f;
                a_25[r_14 * u32(6) + p_21] = 0.0f;
                r_14 = r_14 + u32(1);
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
    store_inverse_0(c_27, a_25);
    return;
}

fn block_get_0( c_28 : u32,  i_17 : u32,  j_12 : u32) -> f32
{
    var k_21 : u32 = i_17 * u32(6) + j_12;
    return scratch_0[sv_0(c_28, u32(12) + k_21 / u32(4))][k_21 % u32(4)];
}

fn precondition_0( c_29 : u32)
{
    var _S686 : array<f32, i32(6)> = array<f32, i32(6)>( scratch_0[sv_0(c_29, u32(4))].x, scratch_0[sv_0(c_29, u32(4))].y, scratch_0[sv_0(c_29, u32(4))].z, scratch_0[sv_0(c_29, u32(5))].x, scratch_0[sv_0(c_29, u32(5))].y, scratch_0[sv_0(c_29, u32(5))].z );
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
            var s_16 : f32 = s_15 + block_get_0(c_29, i_18, j_13) * _S686[j_13];
            j_13 = j_13 + u32(1);
            s_15 = s_16;
        }
        z_1[i_18] = s_15;
        i_18 = i_18 + u32(1);
    }
    scratch_0[sv_0(c_29, u32(6))] = vec4<f32>(z_1[i32(0)], z_1[i32(1)], z_1[i32(2)], 0.0f);
    scratch_0[sv_0(c_29, u32(7))] = vec4<f32>(z_1[i32(3)], z_1[i32(4)], z_1[i32(5)], 0.0f);
    return;
}

fn project_displacement_slot_0( tid_20 : u32,  isl_27 : ptr<function, Island_std430_0>,  slot_5 : u32)
{
    var _S687 : u32;
    var _S688 : vec3<f32> = vec3<f32>(0.0f);
    var p_22 : vec3<f32> = _S688;
    var l_6 : vec3<f32> = _S688;
    var _S689 : vec4<u32> = (*isl_27).range_0;
    var _S690 : u32 = (*isl_27).range_0.x + tid_20;
    var c_30 : u32 = _S690;
    loop
    {
        var _S691 : u32 = _S689.y;
        _S687 = _S691;
        if(c_30 < _S691)
        {
        }
        else
        {
            break;
        }
        var u_0 : vec3<f32> = scratch_0[sv_0(c_30, slot_5)].xyz;
        var th_2 : vec3<f32> = scratch_0[sv_0(c_30, slot_5 + u32(1))].xyz;
        var r_15 : vec3<f32> = chunks_0[c_30].center_0.xyz - (*isl_27).com_0.xyz;
        var _S692 : vec3<f32> = vec3<f32>(chunks_0[c_30].center_0.w);
        p_22 = p_22 + u_0 * _S692;
        l_6 = l_6 + (cross(r_15, u_0) * _S692 + rows_mul_0(chunks_0[c_30].inertia0_1, chunks_0[c_30].inertia1_1, chunks_0[c_30].inertia2_1, th_2));
        c_30 = c_30 + u32(256);
    }
    group_sum3_1(tid_20, &(p_22), &(l_6));
    var _S693 : vec4<f32> = (*isl_27).com_0;
    var _S694 : vec3<f32> = p_22 / vec3<f32>((*isl_27).com_0.w);
    var _S695 : vec3<f32> = rows_mul_0((*isl_27).inv0_0, (*isl_27).inv1_0, (*isl_27).inv2_0, l_6);
    c_30 = _S690;
    loop
    {
        if(c_30 < _S687)
        {
        }
        else
        {
            break;
        }
        var _S696 : u32 = sv_0(c_30, slot_5);
        scratch_0[_S696] = vec4<f32>(scratch_0[_S696].xyz - _S694 - cross(_S695, chunks_0[c_30].center_0.xyz - _S693.xyz), 0.0f);
        var _S697 : u32 = sv_0(c_30, slot_5 + u32(1));
        scratch_0[_S697] = vec4<f32>(scratch_0[_S697].xyz - _S695, 0.0f);
        c_30 = c_30 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    return;
}

fn statics_result_slot_0( island_3 : u32) -> u32
{
    return params_0.statics_base_0 + u32(23) * params_0.chunk_count_0 + u32(2) * params_0.statics_bonds_0 + island_3;
}

fn to_body_0( _S698 : u32,  _S699 : vec3<f32>) -> vec3<f32>
{
    return bonds_0[_S698].t1_0.xyz * vec3<f32>(_S699.x) + bonds_0[_S698].t2_0.xyz * vec3<f32>(_S699.y) + bonds_0[_S698].normal_0.xyz * vec3<f32>(_S699.z);
}

fn write_bond_loads_0( _S700 : u32,  _S701 : u32,  _S702 : vec3<f32>,  _S703 : vec3<f32>,  _S704 : f32)
{
    var _S705 : vec3<f32> = to_body_0(_S701, _S702);
    var _S706 : vec3<f32> = to_body_0(_S701, _S703);
    var _S707 : u32 = u32(3) * _S700;
    scratch_0[_S707] = vec4<f32>(_S705, _S704);
    scratch_0[_S707 + u32(1)] = vec4<f32>(_S706 + cross(bonds_0[_S701].ra_0.xyz, _S705), 0.0f);
    scratch_0[_S707 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S706) + cross(bonds_0[_S701].rb_0.xyz, (vec3<f32>(0) - _S705)), 0.0f);
    return;
}

fn static_kinematics_1( _S708 : u32,  _S709 : ptr<function, vec3<f32>>,  _S710 : ptr<function, vec3<f32>>)
{
    var ca_2 : u32 = bonds_0[_S708].law_0.ids_0.y;
    var cb_5 : u32 = bonds_0[_S708].law_0.ids_0.z;
    var _S711 : u32 = u32(4) * cb_5;
    var _S712 : u32 = u32(4) * ca_2;
    var _S713 : u32 = _S711 + u32(1);
    var _S714 : u32 = _S712 + u32(1);
    var _S715 : u32 = sv_0(cb_5, u32(22));
    var _S716 : u32 = sv_0(ca_2, u32(22));
    var dth_1 : vec3<f32> = state_0[_S713].xyz - state_0[_S714].xyz + (scratch_0[_S715].xyz - scratch_0[_S716].xyz);
    (*_S709) = to_local_0(_S708, state_0[_S711].xyz - state_0[_S712].xyz + (scratch_0[sv_0(cb_5, u32(21))].xyz - scratch_0[sv_0(ca_2, u32(21))].xyz) + (cross(state_0[_S713].xyz + scratch_0[_S715].xyz, bonds_0[_S708].rb_0.xyz) - cross(state_0[_S714].xyz + scratch_0[_S716].xyz, bonds_0[_S708].ra_0.xyz)));
    (*_S710) = to_local_0(_S708, dth_1);
    return;
}

fn bond_kinematics_0( _S717 : u32,  _S718 : vec3<f32>,  _S719 : vec3<f32>,  _S720 : vec3<f32>,  _S721 : vec3<f32>,  _S722 : ptr<function, vec3<f32>>,  _S723 : ptr<function, vec3<f32>>)
{
    (*_S722) = to_local_0(_S717, _S720 + cross(_S721, bonds_0[_S717].rb_0.xyz) - (_S718 + cross(_S719, bonds_0[_S717].ra_0.xyz)));
    (*_S723) = to_local_0(_S717, _S721 - _S719);
    return;
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

@compute
@workgroup_size(256, 1, 1)
fn island_statics(@builtin(workgroup_id) group_5 : vec3<u32>, @builtin(local_invocation_id) thread_5 : vec3<u32>)
{
    var i_19 : u32;
    var converged_2 : bool;
    var c_31 : u32;
    var tid_21 : u32 = thread_5.x;
    var _S724 : u32 = group_5.x;
    var _S725 : Island_std430_0 = islands_0[_S724];
    var _S726 : vec4<u32> = _S725.info_0;
    var _S727 : u32 = _S725.info_0.z;
    if(((_S727 & (u32(8)))) == u32(0))
    {
        return;
    }
    var free_0 : bool = (((_S726.x) & (u32(1)))) == u32(0);
    var c0_1 : u32 = _S725.range_0.x;
    var c1_1 : u32 = _S725.range_0.y;
    var b0_0 : u32 = _S725.range_0.z;
    var _S728 : u32 = _S725.range_0.w;
    var _S729 : u32 = c0_1 + tid_21;
    var c_32 : u32 = _S729;
    loop
    {
        if(c_32 < c1_1)
        {
        }
        else
        {
            break;
        }
        var _S730 : vec4<f32> = vec4<f32>(0.0f);
        scratch_0[sv_0(c_32, u32(21))] = _S730;
        scratch_0[sv_0(c_32, u32(22))] = _S730;
        c_32 = c_32 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    if(free_0)
    {
        project_load_slot_0(tid_21, &(_S725), u32(0));
    }
    var _S731 : f32 = island_dot_0(tid_21, c0_1, c1_1, u32(0), u32(0));
    var _S732 : f32 = max(sqrt(_S731), 1.00000000317107685e-30f);
    var _S733 : f32 = params_0.statics_tol_0;
    var _S734 : u32 = min(params_0.statics_cg_0, u32(20) * (c1_1 - c0_1) * u32(6) + u32(200));
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
        var _S735 : u32 = b0_0 + tid_21;
        i_19 = _S735;
        loop
        {
            if(i_19 < _S728)
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
        var _S736 : vec4<f32> = vec4<f32>(0.0f);
        var magnitude_0 : vec4<f32> = _S736;
        var unused_m_0 : vec4<f32> = _S736;
        c_32 = _S729;
        loop
        {
            if(c_32 < c1_1)
            {
            }
            else
            {
                break;
            }
            var fi_2 : vec3<f32>;
            var mi_1 : vec3<f32>;
            gather_loads_0(c_32, &(fi_2), &(mi_1));
            magnitude_0[i32(0)] = magnitude_0[i32(0)] + bond_load_magnitude2_0(c_32);
            var r_lin_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_32, u32(0))].xyz + fi_2, 0.0f);
            var r_ang_0 : vec4<f32> = vec4<f32>(scratch_0[sv_0(c_32, u32(1))].xyz + mi_1, 0.0f);
            hold_0(fixed_mask_0(c_32), &(r_lin_0), &(r_ang_0), _S736, _S736);
            scratch_0[sv_0(c_32, u32(4))] = r_lin_0;
            scratch_0[sv_0(c_32, u32(5))] = r_ang_0;
            c_32 = c_32 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        group_sum2_1(tid_21, &(magnitude_0), &(unused_m_0));
        if(free_0)
        {
            project_load_slot_0(tid_21, &(_S725), u32(4));
        }
        var _S737 : f32 = island_dot_0(tid_21, c0_1, c1_1, u32(4), u32(4));
        var residual_1 : f32 = sqrt(_S737) / _S732;
        var _S738 : f32 = max(0.00100000004749745f, 3.83999986297567375e-06f * sqrt(magnitude_0.x) / _S732);
        if(residual_1 <= _S733)
        {
            converged_2 = true;
        }
        else
        {
            if(residual_1 <= _S738)
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
        var i_20 : u32 = _S735;
        loop
        {
            if(i_20 < _S728)
            {
            }
            else
            {
                break;
            }
            var d_lin_10 : vec3<f32>;
            var d_ang_8 : vec3<f32>;
            static_kinematics_1(i_20, &(d_lin_10), &(d_ang_8));
            var _S739 : JointBond_std430_0 = bonds_0[i_20].law_0;
            var _S740 : JointState_std430_0 = bond_dyn_0[i_20].js_0;
            var f_lin_2 : vec3<f32>;
            var f_ang_2 : vec3<f32>;
            secant_factors_0(&(_S739), &(_S740), d_lin_10, &(f_lin_2), &(f_ang_2));
            var _S741 : u32 = statics_bond_slot_0(i_20);
            var _S742 : f32 = _S739.stiff0_0.y;
            scratch_0[_S741] = vec4<f32>(_S742 * f_lin_2.x, _S742 * f_lin_2.y, _S739.stiff0_0.x * f_lin_2.z, 0.0f);
            scratch_0[_S741 + u32(1)] = vec4<f32>(_S739.stiff0_0.z * f_ang_2.x, _S739.stiff0_0.w * f_ang_2.y, _S739.stiff1_0.x * f_ang_2.z, 0.0f);
            i_20 = i_20 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_33 : u32 = _S729;
        loop
        {
            if(c_33 < c1_1)
            {
            }
            else
            {
                break;
            }
            assemble_block_0(c_33);
            scratch_0[sv_0(c_33, u32(2))] = _S736;
            scratch_0[sv_0(c_33, u32(3))] = _S736;
            c_33 = c_33 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var c_34 : u32 = _S729;
        loop
        {
            if(c_34 < c1_1)
            {
            }
            else
            {
                break;
            }
            precondition_0(c_34);
            c_34 = c_34 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        if(free_0)
        {
            project_displacement_slot_0(tid_21, &(_S725), u32(6));
        }
        var c_35 : u32 = _S729;
        loop
        {
            if(c_35 < c1_1)
            {
            }
            else
            {
                break;
            }
            scratch_0[sv_0(c_35, u32(8))] = scratch_0[sv_0(c_35, u32(6))];
            scratch_0[sv_0(c_35, u32(9))] = scratch_0[sv_0(c_35, u32(7))];
            c_35 = c_35 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S743 : f32 = island_dot_0(tid_21, c0_1, c1_1, u32(4), u32(6));
        var _S744 : f32 = island_dot_0(tid_21, c0_1, c1_1, u32(4), u32(4));
        var _S745 : f32 = sqrt(_S744);
        var rz_0 : f32 = _S743;
        var k_22 : u32 = u32(0);
        var cg_total_1 : u32 = cg_total_0;
        loop
        {
            var _S746 : bool;
            if(k_22 < _S734)
            {
                _S746 = _S745 > 0.0f;
            }
            else
            {
                _S746 = false;
            }
            if(_S746)
            {
            }
            else
            {
                cg_total_0 = cg_total_1;
                break;
            }
            var i_21 : u32 = _S735;
            loop
            {
                if(i_21 < _S728)
                {
                }
                else
                {
                    break;
                }
                var ca_3 : u32 = bonds_0[i_21].law_0.ids_0.y;
                var cb_6 : u32 = bonds_0[i_21].law_0.ids_0.z;
                var d_lin_11 : vec3<f32>;
                var d_ang_9 : vec3<f32>;
                bond_kinematics_0(i_21, scratch_0[sv_0(ca_3, u32(8))].xyz, scratch_0[sv_0(ca_3, u32(9))].xyz, scratch_0[sv_0(cb_6, u32(8))].xyz, scratch_0[sv_0(cb_6, u32(9))].xyz, &(d_lin_11), &(d_ang_9));
                var _S747 : u32 = statics_bond_slot_0(i_21);
                write_bond_loads_0(i_21, i_21, d_lin_11 * scratch_0[_S747].xyz, d_ang_9 * scratch_0[_S747 + u32(1)].xyz, 0.0f);
                i_21 = i_21 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_31 = _S729;
            loop
            {
                if(c_31 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var fi_3 : vec3<f32>;
                var mi_2 : vec3<f32>;
                gather_loads_0(c_31, &(fi_3), &(mi_2));
                var ap_lin_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - fi_3), 0.0f);
                var ap_ang_0 : vec4<f32> = vec4<f32>((vec3<f32>(0) - mi_2), 0.0f);
                hold_0(fixed_mask_0(c_31), &(ap_lin_0), &(ap_ang_0), scratch_0[sv_0(c_31, u32(8))], scratch_0[sv_0(c_31, u32(9))]);
                scratch_0[sv_0(c_31, u32(10))] = ap_lin_0;
                scratch_0[sv_0(c_31, u32(11))] = ap_ang_0;
                c_31 = c_31 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var pap_0 : f32 = island_dot_0(tid_21, c0_1, c1_1, u32(8), u32(10));
            var _S748 : u32 = cg_total_1 + u32(1);
            if(pap_0 <= 0.0f)
            {
                cg_total_0 = _S748;
                break;
            }
            var _S749 : f32 = rz_0 / pap_0;
            var c_36 : u32 = _S729;
            loop
            {
                if(c_36 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S750 : u32 = sv_0(c_36, u32(2));
                var _S751 : vec3<f32> = vec3<f32>(_S749);
                scratch_0[_S750] = vec4<f32>(scratch_0[_S750].xyz + _S751 * scratch_0[sv_0(c_36, u32(8))].xyz, 0.0f);
                var _S752 : u32 = sv_0(c_36, u32(3));
                scratch_0[_S752] = vec4<f32>(scratch_0[_S752].xyz + _S751 * scratch_0[sv_0(c_36, u32(9))].xyz, 0.0f);
                var _S753 : u32 = sv_0(c_36, u32(4));
                scratch_0[_S753] = vec4<f32>(scratch_0[_S753].xyz - _S751 * scratch_0[sv_0(c_36, u32(10))].xyz, 0.0f);
                var _S754 : u32 = sv_0(c_36, u32(5));
                scratch_0[_S754] = vec4<f32>(scratch_0[_S754].xyz - _S751 * scratch_0[sv_0(c_36, u32(11))].xyz, 0.0f);
                c_36 = c_36 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S755 : f32 = island_dot_0(tid_21, c0_1, c1_1, u32(4), u32(4));
            if((sqrt(_S755)) <= (0.00009999999747379f * _S745))
            {
                cg_total_0 = _S748;
                break;
            }
            var c_37 : u32 = _S729;
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
                project_displacement_slot_0(tid_21, &(_S725), u32(6));
            }
            var rz_new_0 : f32 = island_dot_0(tid_21, c0_1, c1_1, u32(4), u32(6));
            var _S756 : f32 = rz_new_0 / rz_0;
            var c_38 : u32 = _S729;
            loop
            {
                if(c_38 < c1_1)
                {
                }
                else
                {
                    break;
                }
                var _S757 : u32 = sv_0(c_38, u32(8));
                var _S758 : vec3<f32> = vec3<f32>(_S756);
                scratch_0[_S757] = vec4<f32>(scratch_0[sv_0(c_38, u32(6))].xyz + _S758 * scratch_0[_S757].xyz, 0.0f);
                var _S759 : u32 = sv_0(c_38, u32(9));
                scratch_0[_S759] = vec4<f32>(scratch_0[sv_0(c_38, u32(7))].xyz + _S758 * scratch_0[_S759].xyz, 0.0f);
                c_38 = c_38 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            var _S760 : u32 = k_22 + u32(1);
            rz_0 = rz_new_0;
            k_22 = _S760;
            cg_total_1 = _S748;
        }
        c_31 = _S729;
        loop
        {
            if(c_31 < c1_1)
            {
            }
            else
            {
                break;
            }
            var _S761 : u32 = u32(4) * c_31;
            var u_1 : vec3<f32> = state_0[_S761].xyz;
            var _S762 : u32 = sv_0(c_31, u32(21));
            var u_lo_0 : vec3<f32> = scratch_0[_S762].xyz;
            var _S763 : u32 = _S761 + u32(1);
            var th_3 : vec3<f32> = state_0[_S763].xyz;
            var _S764 : u32 = sv_0(c_31, u32(22));
            var th_lo_0 : vec3<f32> = scratch_0[_S764].xyz;
            comp_add_1(&(u_1), &(u_lo_0), scratch_0[sv_0(c_31, u32(2))].xyz);
            comp_add_1(&(th_3), &(th_lo_0), scratch_0[sv_0(c_31, u32(3))].xyz);
            state_0[_S761] = vec4<f32>(u_1, state_0[_S761].w);
            state_0[_S763] = vec4<f32>(th_3, state_0[_S763].w);
            scratch_0[_S762] = vec4<f32>(u_lo_0, 0.0f);
            scratch_0[_S764] = vec4<f32>(th_lo_0, 0.0f);
            c_31 = c_31 + u32(256);
        }
        storageBarrier(); textureBarrier(); workgroupBarrier();;
        var _S765 : u32 = newton_0 + u32(1);
        previous_1 = residual_1;
        residual_0 = residual_1;
        newton_0 = _S765;
    }
    i_19 = b0_0 + tid_21;
    loop
    {
        if(i_19 < _S728)
        {
        }
        else
        {
            break;
        }
        var resp_4 : JointResponse_0 = static_response_0(i_19);
        var _S766 : JointState_0 = JointState_0( bond_dyn_0[i_19].js_0.damage_0, bond_dyn_0[i_19].js_0.crush_1, bond_dyn_0[i_19].js_0.kappa_0, bond_dyn_0[i_19].js_0.kappa_c_0, bond_dyn_0[i_19].js_0.ductility_0, bond_dyn_0[i_19].js_0.ductility_c_0, bond_dyn_0[i_19].js_0.life_0, bond_dyn_0[i_19].js_0.plastic_x_0, bond_dyn_0[i_19].js_0.plastic_y_0, bond_dyn_0[i_19].js_0.plastic_t_0, bond_dyn_0[i_19].js_0.rebar_plastic_0, bond_dyn_0[i_19].js_0.rebar_slip0_0, bond_dyn_0[i_19].js_0.rebar_slip1_0, bond_dyn_0[i_19].js_0.rebar_work_0, bond_dyn_0[i_19].js_0.rebar_broken_0, bond_dyn_0[i_19].js_0.strain_rate_0, bond_dyn_0[i_19].js_0.governing_stress_0, bond_dyn_0[i_19].js_0.dissipated_0, bond_dyn_0[i_19].js_0.utilization_0, bond_dyn_0[i_19].js_0.mode_0 );
        var bd_0 : BondDyn_0;
        bd_0.js_0 = _S766;
        bd_0.force_lin_0 = bond_dyn_0[i_19].force_lin_0;
        bd_0.force_ang_0 = bond_dyn_0[i_19].force_ang_0;
        bd_0.sums_0 = bond_dyn_0[i_19].sums_0;
        bd_0.comps_0 = bond_dyn_0[i_19].comps_0;
        bd_0.events_0 = bond_dyn_0[i_19].events_0;
        bd_0.force_lin_0 = vec4<f32>(resp_4.force_lin_1, resp_4.stored_5);
        bd_0.force_ang_0 = vec4<f32>(resp_4.force_ang_1, bd_0.force_ang_0.w);
        bond_dyn_0[i_19].js_0.damage_0 = bd_0.js_0.damage_0;
        bond_dyn_0[i_19].js_0.crush_1 = bd_0.js_0.crush_1;
        bond_dyn_0[i_19].js_0.kappa_0 = bd_0.js_0.kappa_0;
        bond_dyn_0[i_19].js_0.kappa_c_0 = bd_0.js_0.kappa_c_0;
        bond_dyn_0[i_19].js_0.ductility_0 = bd_0.js_0.ductility_0;
        bond_dyn_0[i_19].js_0.ductility_c_0 = bd_0.js_0.ductility_c_0;
        bond_dyn_0[i_19].js_0.life_0 = bd_0.js_0.life_0;
        bond_dyn_0[i_19].js_0.plastic_x_0 = bd_0.js_0.plastic_x_0;
        bond_dyn_0[i_19].js_0.plastic_y_0 = bd_0.js_0.plastic_y_0;
        bond_dyn_0[i_19].js_0.plastic_t_0 = bd_0.js_0.plastic_t_0;
        bond_dyn_0[i_19].js_0.rebar_plastic_0 = bd_0.js_0.rebar_plastic_0;
        bond_dyn_0[i_19].js_0.rebar_slip0_0 = bd_0.js_0.rebar_slip0_0;
        bond_dyn_0[i_19].js_0.rebar_slip1_0 = bd_0.js_0.rebar_slip1_0;
        bond_dyn_0[i_19].js_0.rebar_work_0 = bd_0.js_0.rebar_work_0;
        bond_dyn_0[i_19].js_0.rebar_broken_0 = bd_0.js_0.rebar_broken_0;
        bond_dyn_0[i_19].js_0.strain_rate_0 = bd_0.js_0.strain_rate_0;
        bond_dyn_0[i_19].js_0.governing_stress_0 = bd_0.js_0.governing_stress_0;
        bond_dyn_0[i_19].js_0.dissipated_0 = bd_0.js_0.dissipated_0;
        bond_dyn_0[i_19].js_0.utilization_0 = bd_0.js_0.utilization_0;
        bond_dyn_0[i_19].js_0.mode_0 = bd_0.js_0.mode_0;
        bond_dyn_0[i_19].force_lin_0 = bd_0.force_lin_0;
        bond_dyn_0[i_19].force_ang_0 = bd_0.force_ang_0;
        bond_dyn_0[i_19].sums_0 = bd_0.sums_0;
        bond_dyn_0[i_19].comps_0 = bd_0.comps_0;
        bond_dyn_0[i_19].events_0 = bd_0.events_0;
        write_bond_loads_0(i_19, i_19, resp_4.force_lin_1, resp_4.force_ang_1, max(resp_4.measures_0.tension_0, resp_4.measures_0.compression_0));
        i_19 = i_19 + u32(256);
    }
    storageBarrier(); textureBarrier(); workgroupBarrier();;
    c_32 = _S729;
    loop
    {
        if(c_32 < c1_1)
        {
        }
        else
        {
            break;
        }
        var fi_4 : vec3<f32>;
        var mi_3 : vec3<f32>;
        gather_loads_0(c_32, &(fi_4), &(mi_3));
        var reaction_0 : vec3<f32>;
        if((fixed_mask_0(c_32)) != u32(0))
        {
            reaction_0 = (vec3<f32>(0) - (scratch_0[sv_0(c_32, u32(0))].xyz + fi_4));
        }
        else
        {
            var _S767 : u32 = u32(4) * c_32;
            reaction_0 = vec3<f32>(state_0[_S767 + u32(1)].w, state_0[_S767 + u32(2)].w, state_0[_S767 + u32(3)].w);
        }
        var _S768 : u32 = u32(4) * c_32;
        var _S769 : u32 = _S768 + u32(1);
        state_0[_S769] = vec4<f32>(state_0[_S769].xyz, reaction_0.x);
        state_0[_S768 + u32(2)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_0.y);
        state_0[_S768 + u32(3)] = vec4<f32>(0.0f, 0.0f, 0.0f, reaction_0.z);
        c_32 = c_32 + u32(256);
    }
    if(tid_21 == u32(0))
    {
        var _S770 : f32 = (bitcast<f32>((newton_0)));
        var _S771 : f32 = (bitcast<f32>((cg_total_0)));
        if(converged_2)
        {
            previous_1 = 1.0f;
        }
        else
        {
            previous_1 = 0.0f;
        }
        scratch_0[statics_result_slot_0(_S724)] = vec4<f32>(residual_0, _S770, _S771, previous_1);
        islands_0[_S724].info_0[i32(2)] = (_S727 & (u32(4294967287)));
    }
    return;
}

var<workgroup> g_halt_0 : u32;

var<workgroup> g_run_0 : u32;

fn is_damaged_0( st_9 : ptr<function, JointState_std430_0>) -> bool
{
    var _S772 : bool;
    if(((*st_9).damage_0) > 0.0f)
    {
        _S772 = true;
    }
    else
    {
        _S772 = ((*st_9).crush_1) > 0.0f;
    }
    return _S772;
}

fn is_damaged_1( st_10 : JointState_0) -> bool
{
    var _S773 : bool;
    if((st_10.damage_0) > 0.0f)
    {
        _S773 = true;
    }
    else
    {
        _S773 = (st_10.crush_1) > 0.0f;
    }
    return _S773;
}

@compute
@workgroup_size(256, 1, 1)
fn settled_fatigue(@builtin(workgroup_id) group_6 : vec3<u32>, @builtin(local_invocation_id) thread_6 : vec3<u32>)
{
    var tid_22 : u32 = thread_6.x;
    var _S774 : u32 = group_6.x;
    var isl_28 : Island_std430_0 = islands_0[_S774];
    var _S775 : bool;
    if((((islands_0[_S774].info_0.x) & (u32(16)))) == u32(0))
    {
        _S775 = true;
    }
    else
    {
        _S775 = (isl_28.range_0.w) == (isl_28.range_0.z);
    }
    if(_S775)
    {
        return;
    }
    seen_clear_0(tid_22);
    if(tid_22 == u32(0))
    {
        g_halt_0 = u32(0);
        g_run_0 = u32(0);
    }
    workgroupBarrier();
    var _S776 : u32 = isl_28.info_0.w;
    var i_22 : u32 = isl_28.range_0.z + tid_22;
    loop
    {
        if(i_22 < (isl_28.range_0.w))
        {
        }
        else
        {
            break;
        }
        var _S777 : JointState_0 = JointState_0( bond_dyn_0[i_22].js_0.damage_0, bond_dyn_0[i_22].js_0.crush_1, bond_dyn_0[i_22].js_0.kappa_0, bond_dyn_0[i_22].js_0.kappa_c_0, bond_dyn_0[i_22].js_0.ductility_0, bond_dyn_0[i_22].js_0.ductility_c_0, bond_dyn_0[i_22].js_0.life_0, bond_dyn_0[i_22].js_0.plastic_x_0, bond_dyn_0[i_22].js_0.plastic_y_0, bond_dyn_0[i_22].js_0.plastic_t_0, bond_dyn_0[i_22].js_0.rebar_plastic_0, bond_dyn_0[i_22].js_0.rebar_slip0_0, bond_dyn_0[i_22].js_0.rebar_slip1_0, bond_dyn_0[i_22].js_0.rebar_work_0, bond_dyn_0[i_22].js_0.rebar_broken_0, bond_dyn_0[i_22].js_0.strain_rate_0, bond_dyn_0[i_22].js_0.governing_stress_0, bond_dyn_0[i_22].js_0.dissipated_0, bond_dyn_0[i_22].js_0.utilization_0, bond_dyn_0[i_22].js_0.mode_0 );
        var bd_1 : BondDyn_0;
        bd_1.js_0 = _S777;
        bd_1.force_lin_0 = bond_dyn_0[i_22].force_lin_0;
        bd_1.force_ang_0 = bond_dyn_0[i_22].force_ang_0;
        bd_1.sums_0 = bond_dyn_0[i_22].sums_0;
        bd_1.comps_0 = bond_dyn_0[i_22].comps_0;
        bd_1.events_0 = bond_dyn_0[i_22].events_0;
        var _S778 : JointBond_std430_0 = bonds_0[i_22].law_0;
        var _S779 : u32 = u32(4) * _S778.ids_0.y;
        var _S780 : u32 = u32(4) * _S778.ids_0.z;
        var d_lin_12 : vec3<f32>;
        var d_ang_10 : vec3<f32>;
        bond_kinematics_0(i_22, state_0[_S779].xyz, state_0[_S779 + u32(1)].xyz, state_0[_S780].xyz, state_0[_S780 + u32(1)].xyz, &(d_lin_12), &(d_ang_10));
        var _S781 : JointMaterial_std140_0 = materials_0.m_0.data_0[_S778.ids_0.x];
        var previous_2 : JointState_0 = bd_1.js_0;
        var _S782 : JointResponse_0 = joint_evaluate_2(&(_S781), &(_S778), bd_1.js_0, d_lin_12, d_ang_10, params_0.dt_0, (params_0.fracture_0) != u32(0));
        if((_S782.state_1.damage_0) > (bd_1.js_0.damage_0 + 9.99999971718068537e-10f))
        {
            _S775 = true;
        }
        else
        {
            _S775 = (_S782.state_1.crush_1) > (previous_2.crush_1 + 9.99999971718068537e-10f);
        }
        var flags_5 : u32;
        if(_S775)
        {
            flags_5 = u32(16);
        }
        else
        {
            flags_5 = u32(0);
        }
        var _S783 : f32 = bd_1.sums_0[i32(0)];
        var _S784 : f32 = bd_1.comps_0[i32(0)];
        comp_add1_4(&(_S783), &(_S784), _S782.dissipated_4);
        bd_1.sums_0[i32(0)] = _S783;
        bd_1.comps_0[i32(0)] = _S784;
        var _S785 : f32 = bd_1.sums_0[i32(1)];
        var _S786 : f32 = bd_1.comps_0[i32(1)];
        comp_add1_4(&(_S785), &(_S786), _S782.overshoot_0);
        bd_1.sums_0[i32(1)] = _S785;
        bd_1.comps_0[i32(1)] = _S786;
        bd_1.force_lin_0 = vec4<f32>(_S782.force_lin_1, _S782.stored_5);
        bd_1.force_ang_0 = vec4<f32>(_S782.force_ang_1, max(bd_1.force_ang_0.w, _S782.state_1.utilization_0));
        var _S787 : bool;
        if(!is_damaged_1(previous_2))
        {
            _S787 = is_damaged_1(_S782.state_1);
        }
        else
        {
            _S787 = false;
        }
        var _S788 : bool;
        if(_S787)
        {
            _S788 = (bd_1.events_0.x) == u32(0);
        }
        else
        {
            _S788 = false;
        }
        if(_S788)
        {
            bd_1.events_0[i32(0)] = _S776;
            bd_1.events_0[i32(3)] = _S782.state_1.mode_0;
            g_seen_0[u32(3)] = u32(1);
        }
        var _S789 : bool;
        if((bd_1.events_0.y) == u32(0))
        {
            _S789 = (_S782.state_1.life_0) != (previous_2.life_0);
        }
        else
        {
            _S789 = false;
        }
        var _S790 : bool;
        if(_S789)
        {
            _S790 = (_S782.fatigue_before_0) > 0.99000000953674316f;
        }
        else
        {
            _S790 = false;
        }
        var _S791 : bool;
        if(_S790)
        {
            var _S792 : f32 = fatigue_factor_2(&(_S781), _S782.state_1.life_0);
            _S791 = _S792 <= 0.99000000953674316f;
        }
        else
        {
            _S791 = false;
        }
        if(_S791)
        {
            bd_1.events_0[i32(1)] = _S776;
            g_seen_0[u32(4)] = u32(1);
        }
        var flags_6 : u32;
        if(_S782.disconnected_0)
        {
            bd_1.events_0[i32(2)] = _S776;
            flags_6 = (flags_5 | (u32(32)));
        }
        else
        {
            flags_6 = flags_5;
        }
        bd_1.js_0 = _S782.state_1;
        bond_dyn_0[i_22].js_0.damage_0 = bd_1.js_0.damage_0;
        bond_dyn_0[i_22].js_0.crush_1 = bd_1.js_0.crush_1;
        bond_dyn_0[i_22].js_0.kappa_0 = bd_1.js_0.kappa_0;
        bond_dyn_0[i_22].js_0.kappa_c_0 = bd_1.js_0.kappa_c_0;
        bond_dyn_0[i_22].js_0.ductility_0 = bd_1.js_0.ductility_0;
        bond_dyn_0[i_22].js_0.ductility_c_0 = bd_1.js_0.ductility_c_0;
        bond_dyn_0[i_22].js_0.life_0 = bd_1.js_0.life_0;
        bond_dyn_0[i_22].js_0.plastic_x_0 = bd_1.js_0.plastic_x_0;
        bond_dyn_0[i_22].js_0.plastic_y_0 = bd_1.js_0.plastic_y_0;
        bond_dyn_0[i_22].js_0.plastic_t_0 = bd_1.js_0.plastic_t_0;
        bond_dyn_0[i_22].js_0.rebar_plastic_0 = bd_1.js_0.rebar_plastic_0;
        bond_dyn_0[i_22].js_0.rebar_slip0_0 = bd_1.js_0.rebar_slip0_0;
        bond_dyn_0[i_22].js_0.rebar_slip1_0 = bd_1.js_0.rebar_slip1_0;
        bond_dyn_0[i_22].js_0.rebar_work_0 = bd_1.js_0.rebar_work_0;
        bond_dyn_0[i_22].js_0.rebar_broken_0 = bd_1.js_0.rebar_broken_0;
        bond_dyn_0[i_22].js_0.strain_rate_0 = bd_1.js_0.strain_rate_0;
        bond_dyn_0[i_22].js_0.governing_stress_0 = bd_1.js_0.governing_stress_0;
        bond_dyn_0[i_22].js_0.dissipated_0 = bd_1.js_0.dissipated_0;
        bond_dyn_0[i_22].js_0.utilization_0 = bd_1.js_0.utilization_0;
        bond_dyn_0[i_22].js_0.mode_0 = bd_1.js_0.mode_0;
        bond_dyn_0[i_22].force_lin_0 = bd_1.force_lin_0;
        bond_dyn_0[i_22].force_ang_0 = bd_1.force_ang_0;
        bond_dyn_0[i_22].sums_0 = bd_1.sums_0;
        bond_dyn_0[i_22].comps_0 = bd_1.comps_0;
        bond_dyn_0[i_22].events_0 = bd_1.events_0;
        write_bond_loads_0(i_22, i_22, _S782.force_lin_1, _S782.force_ang_1, max(_S782.measures_0.tension_0, _S782.measures_0.compression_0));
        if(((flags_6 & (u32(16)))) != u32(0))
        {
            g_halt_0 = u32(1);
        }
        if(((flags_6 & (u32(32)))) != u32(0))
        {
            g_run_0 = u32(1);
        }
        i_22 = i_22 + u32(256);
    }
    workgroupBarrier();
    if(tid_22 != u32(0))
    {
        return;
    }
    if(((g_halt_0 | (g_run_0))) != u32(0))
    {
        var _S793 : u32 = isl_28.info_0.z;
        if(g_halt_0 != u32(0))
        {
            i_22 = u32(16);
        }
        else
        {
            i_22 = u32(0);
        }
        var _S794 : u32 = (_S793 | (i_22));
        if(g_run_0 != u32(0))
        {
            i_22 = u32(32);
        }
        else
        {
            i_22 = u32(0);
        }
        islands_0[_S774].info_0[i32(2)] = (_S794 | (i_22));
    }
    var _S795 : u32 = ((((isl_28.coverage_0) | (u32(16384)))) | ((seen_bits_0())));
    if(g_run_0 != u32(0))
    {
        i_22 = u32(128);
    }
    else
    {
        i_22 = u32(0);
    }
    islands_0[_S774].coverage_0 = (_S795 | (i_22));
    return;
}

fn impactor_integrate_at_0( ii_2 : u32,  tid_23 : u32)
{
    var p_23 : vec3<f32>;
    if(ii_2 >= (params_0.impactor_count_0))
    {
        return;
    }
    var imp_6 : Impactor_0;
    imp_6.position_1 = impactors_0[ii_2].position_1;
    imp_6.position_err_1 = impactors_0[ii_2].position_err_1;
    imp_6.velocity_1 = impactors_0[ii_2].velocity_1;
    imp_6.velocity_err_1 = impactors_0[ii_2].velocity_err_1;
    imp_6.angular_velocity_1 = impactors_0[ii_2].angular_velocity_1;
    imp_6.rotation_1 = impactors_0[ii_2].rotation_1;
    imp_6.inertia0_2 = impactors_0[ii_2].inertia0_2;
    imp_6.inertia1_2 = impactors_0[ii_2].inertia1_2;
    imp_6.inertia2_2 = impactors_0[ii_2].inertia2_2;
    imp_6.inv0_2 = impactors_0[ii_2].inv0_2;
    imp_6.inv1_2 = impactors_0[ii_2].inv1_2;
    imp_6.inv2_2 = impactors_0[ii_2].inv2_2;
    imp_6.shape_0 = impactors_0[ii_2].shape_0;
    imp_6.half_1 = impactors_0[ii_2].half_1;
    imp_6.mat_0 = impactors_0[ii_2].mat_0;
    imp_6.crush_0 = impactors_0[ii_2].crush_0;
    imp_6.geom_0 = impactors_0[ii_2].geom_0;
    imp_6.rotation_err_1 = impactors_0[ii_2].rotation_err_1;
    imp_6.ledger_0 = impactors_0[ii_2].ledger_0;
    imp_6.cand_0 = impactors_0[ii_2].cand_0;
    imp_6.momentum_1 = impactors_0[ii_2].momentum_1;
    imp_6.momentum_err_1 = impactors_0[ii_2].momentum_err_1;
    var _S796 : vec4<u32> = islands_0[params_0.halt_index_0].info_0;
    var _S797 : bool;
    if((((islands_0[params_0.halt_index_0].info_0.z) & (u32(1)))) != u32(0))
    {
        _S797 = true;
    }
    else
    {
        var _S798 : u32 = _S796.y;
        if(_S798 != u32(0))
        {
            _S797 = (imp_6.cand_0.w) >= _S798;
        }
        else
        {
            _S797 = false;
        }
    }
    if(_S797)
    {
        return;
    }
    if((imp_6.cand_0.z) != u32(0))
    {
        if(tid_23 == u32(0))
        {
            impactors_0[ii_2].cand_0[i32(3)] = imp_6.cand_0.w + u32(1);
        }
        return;
    }
    var _S799 : vec4<f32> = vec4<f32>(0.0f);
    var rf_1 : vec4<f32> = _S799;
    var rt_0 : vec4<f32> = _S799;
    var k_23 : u32 = imp_6.cand_0.x + tid_23;
    loop
    {
        if(k_23 < (imp_6.cand_0.y))
        {
        }
        else
        {
            break;
        }
        var _S800 : u32 = u32(3) * k_23;
        rf_1 = rf_1 + scratch_0[params_0.cand_base_0 + _S800 + u32(1)];
        rt_0 = rt_0 + scratch_0[params_0.cand_base_0 + _S800 + u32(2)];
        k_23 = k_23 + u32(256);
    }
    group_sum2_3(tid_23, &(rf_1), &(rt_0));
    if(tid_23 != u32(0))
    {
        return;
    }
    var dt_15 : f32 = params_0.dt_0;
    var _S801 : vec3<f32> = vec3<f32>(0.0f);
    var load_f_0 : vec3<f32>;
    var load_t_0 : vec3<f32>;
    if((params_0.has_ground_0) != u32(0))
    {
        var ib_0 : Box_0 = impactor_box_0(imp_6, _S801, imp_6.half_1.xyz);
        var _S802 : vec3<f32> = imp_6.velocity_1.xyz + imp_6.velocity_err_1.xyz;
        const _S803 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
        var kc_2 : f32 = contact_stiffness_0(params_0.ground_modulus_0, ib_0, imp_6.mat_0.x, ib_0, _S803);
        var _S804 : f32 = imp_6.position_1.z - params_0.ground_hi_0 + (imp_6.position_err_1.z - params_0.ground_lo_0);
        var total_points_0 : u32;
        if((imp_6.shape_0.x) == 0.0f)
        {
            total_points_0 = u32(1);
        }
        else
        {
            total_points_0 = u32(14);
        }
        var _S805 : f32 = kc_2 / f32(min(total_points_0, u32(5)));
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
            if((imp_6.shape_0.x) == 0.0f)
            {
                p_23 = vec3<f32>(0.0f, 0.0f, - imp_6.shape_0.y);
            }
            else
            {
                p_23 = sample_point_0(ib_0, s_17);
            }
            if((_S804 + p_23.z) < 0.0f)
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
        load_f_0 = _S801;
        load_t_0 = _S801;
        loop
        {
            if(s_17 < total_points_0)
            {
            }
            else
            {
                break;
            }
            if((imp_6.shape_0.x) == 0.0f)
            {
                p_23 = vec3<f32>(0.0f, 0.0f, - imp_6.shape_0.y);
            }
            else
            {
                p_23 = sample_point_0(ib_0, s_17);
            }
            var depth_6 : f32 = - (_S804 + p_23.z);
            if(depth_6 <= 0.0f)
            {
                s_17 = s_17 + u32(1);
                continue;
            }
            var stored_15 : f32;
            var diss_7 : f32;
            var f_17 : vec3<f32> = penalty_force_0(_S805, imp_6.mat_0.z, params_0.ground_friction_0, depth_6, _S803, _S802 + cross(imp_6.angular_velocity_1.xyz, p_23), dt_15, below_0, &(stored_15), &(diss_7));
            var load_f_1 : vec3<f32> = load_f_0 + f_17;
            var load_t_1 : vec3<f32> = load_t_0 + cross(p_23, f_17);
            var _S806 : f32 = imp_6.ledger_0[i32(0)];
            var _S807 : f32 = imp_6.ledger_0[i32(1)];
            comp_add1_1(&(_S806), &(_S807), diss_7);
            imp_6.ledger_0[i32(0)] = _S806;
            imp_6.ledger_0[i32(1)] = _S807;
            load_f_0 = load_f_1;
            load_t_0 = load_t_1;
            s_17 = s_17 + u32(1);
        }
    }
    else
    {
        load_f_0 = _S801;
        load_t_0 = _S801;
    }
    var load_f_2 : vec3<f32> = rf_1.xyz + load_f_0;
    var load_t_2 : vec3<f32> = rt_0.xyz + load_t_0;
    var m_8 : f32 = imp_6.mat_0.z;
    var vel_1 : vec3<f32> = imp_6.velocity_1.xyz;
    var vel_err_1 : vec3<f32> = imp_6.velocity_err_1.xyz;
    var _S808 : vec3<f32> = vec3<f32>(dt_15);
    comp_add_0(&(vel_1), &(vel_err_1), (load_f_2 / vec3<f32>(m_8) + params_0.gravity_0.xyz) * _S808);
    var _S809 : Quat_0 = quat_of_0(imp_6.rotation_1);
    var q_14 : Quat_0 = _S809;
    var q_err_0 : vec4<f32> = imp_6.rotation_err_1;
    var l_hi_0 : vec3<f32> = imp_6.momentum_1.xyz;
    var l_err_1 : vec3<f32> = imp_6.momentum_err_1.xyz;
    comp_add_0(&(l_hi_0), &(l_err_1), load_t_2 * _S808);
    var l_7 : vec3<f32> = l_hi_0 + l_err_1;
    var w_mid_2 : vec3<f32> = world_mul_0(_S809, imp_6.inv0_2, imp_6.inv1_2, imp_6.inv2_2, l_7);
    var pos_1 : vec3<f32> = imp_6.position_1.xyz;
    var pos_err_1 : vec3<f32> = imp_6.position_err_1.xyz;
    comp_add_0(&(pos_1), &(pos_err_1), (vel_1 + vel_err_1) * _S808);
    turn_left_0(&(q_14), &(q_err_0), w_mid_2, dt_15);
    imp_6.angular_velocity_1 = vec4<f32>(world_mul_0(q_14, imp_6.inv0_2, imp_6.inv1_2, imp_6.inv2_2, l_7), 0.0f);
    imp_6.rotation_1 = quat_vec_0(q_14);
    imp_6.rotation_err_1 = q_err_0;
    imp_6.momentum_1 = vec4<f32>(l_hi_0, 0.0f);
    imp_6.momentum_err_1 = vec4<f32>(l_err_1, 0.0f);
    imp_6.position_1 = vec4<f32>(pos_1, 0.0f);
    imp_6.position_err_1 = vec4<f32>(pos_err_1, 0.0f);
    imp_6.velocity_1 = vec4<f32>(vel_1, 0.0f);
    imp_6.velocity_err_1 = vec4<f32>(vel_err_1, 0.0f);
    imp_6.cand_0[i32(3)] = imp_6.cand_0[i32(3)] + u32(1);
    imp_6.geom_0 = vec4<f32>(1.0f, imp_6.crush_0.w, 0.0f, 0.0f);
    impactors_0[ii_2].position_1 = imp_6.position_1;
    impactors_0[ii_2].position_err_1 = imp_6.position_err_1;
    impactors_0[ii_2].velocity_1 = imp_6.velocity_1;
    impactors_0[ii_2].velocity_err_1 = imp_6.velocity_err_1;
    impactors_0[ii_2].angular_velocity_1 = imp_6.angular_velocity_1;
    impactors_0[ii_2].rotation_1 = imp_6.rotation_1;
    impactors_0[ii_2].inertia0_2 = imp_6.inertia0_2;
    impactors_0[ii_2].inertia1_2 = imp_6.inertia1_2;
    impactors_0[ii_2].inertia2_2 = imp_6.inertia2_2;
    impactors_0[ii_2].inv0_2 = imp_6.inv0_2;
    impactors_0[ii_2].inv1_2 = imp_6.inv1_2;
    impactors_0[ii_2].inv2_2 = imp_6.inv2_2;
    impactors_0[ii_2].shape_0 = imp_6.shape_0;
    impactors_0[ii_2].half_1 = imp_6.half_1;
    impactors_0[ii_2].mat_0 = imp_6.mat_0;
    impactors_0[ii_2].crush_0 = imp_6.crush_0;
    impactors_0[ii_2].geom_0 = imp_6.geom_0;
    impactors_0[ii_2].rotation_err_1 = imp_6.rotation_err_1;
    impactors_0[ii_2].ledger_0 = imp_6.ledger_0;
    impactors_0[ii_2].cand_0 = imp_6.cand_0;
    impactors_0[ii_2].momentum_1 = imp_6.momentum_1;
    impactors_0[ii_2].momentum_err_1 = imp_6.momentum_err_1;
    var k_24 : u32 = imp_6.cand_0.w - u32(1) - params_0.step_start_0;
    if(k_24 < (params_0.record_stride_0))
    {
        var at_6 : u32 = params_0.record_base_0 + u32(2) * (ii_2 * params_0.record_stride_0 + k_24);
        scratch_0[at_6] = vec4<f32>(vel_1 + vel_err_1, 0.0f);
        scratch_0[at_6 + u32(1)] = vec4<f32>(pos_1 + pos_err_1, 0.0f);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn impactor_integrate(@builtin(workgroup_id) group_7 : vec3<u32>, @builtin(local_invocation_id) thread_7 : vec3<u32>)
{
    impactor_integrate_at_0(group_7.x, thread_7.x);
    return;
}

fn ground_contact_0( c_39 : u32,  account_0 : bool,  f_18 : ptr<function, vec3<f32>>,  t_20 : ptr<function, vec3<f32>>)
{
    var wp_1 : WorldPoint_0 = chunk_world_0(c_39);
    var above_0 : f32 = wp_1.hi_0.z - params_0.ground_hi_0 + (wp_1.lo_0.z - params_0.ground_lo_0) + wp_1.rel_0.z;
    if((above_0 - chunks_0[c_39].half_0.w) > 0.0f)
    {
        return;
    }
    var b_50 : Box_0 = chunk_box_0(c_39, vec3<f32>(0.0f));
    const _S810 : vec3<f32> = vec3<f32>(0.0f, 0.0f, 1.0f);
    var _S811 : f32 = contact_stiffness_0(params_0.ground_modulus_0, b_50, chunks_0[c_39].cmat_0.x, b_50, _S810);
    var _S812 : u32 = sample_count_0(b_50);
    var s_18 : u32 = u32(0);
    var n_11 : u32 = u32(0);
    loop
    {
        if(s_18 < _S812)
        {
        }
        else
        {
            break;
        }
        if((above_0 + sample_point_0(b_50, s_18).z) < 0.0f)
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
    chunk_velocity_1(c_39, &(vc_1), &(wc_1));
    var ledger_2 : vec4<f32> = scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_39];
    s_18 = u32(0);
    loop
    {
        if(s_18 < _S812)
        {
        }
        else
        {
            break;
        }
        var p_24 : vec3<f32> = sample_point_0(b_50, s_18);
        var _S813 : f32 = above_0 + p_24.z;
        if(!(_S813 < 0.0f))
        {
            s_18 = s_18 + u32(1);
            continue;
        }
        var stored_16 : f32;
        var diss_8 : f32;
        var g_2 : vec3<f32> = penalty_force_2(_S811 / f32(max(n_11, u32(5))), chunks_0[c_39].center_0.w, params_0.ground_friction_0, - _S813, _S810, vc_1 + cross(wc_1, p_24), params_0.dt_0, n_11, &(stored_16), &(diss_8));
        (*f_18) = (*f_18) + g_2;
        (*t_20) = (*t_20) + cross(p_24, g_2);
        var _S814 : f32 = ledger_2[i32(1)];
        var _S815 : f32 = ledger_2[i32(2)];
        comp_add1_4(&(_S814), &(_S815), diss_8);
        ledger_2[i32(1)] = _S814;
        ledger_2[i32(2)] = _S815;
        s_18 = s_18 + u32(1);
    }
    if(account_0)
    {
        scratch_0[params_0.ledger_base_0 + params_0.pair_count_0 + c_39] = ledger_2;
    }
    return;
}

fn contact_sum_at_0( g_3 : u32)
{
    var _S816 : bool;
    if(g_3 >= (params_0.seg_count_0))
    {
        _S816 = true;
    }
    else
    {
        _S816 = stopped_0();
    }
    if(_S816)
    {
        return;
    }
    var _S817 : u32 = u32(3) * g_3;
    var _S818 : u32 = index_0[params_0.seg_index_0 + _S817];
    var begin_1 : u32 = index_0[params_0.seg_index_0 + _S817 + u32(1)];
    var _S819 : u32 = index_0[params_0.seg_index_0 + _S817 + u32(2)];
    var _S820 : vec3<f32> = vec3<f32>(0.0f);
    var f_19 : vec3<f32> = _S820;
    var t_21 : vec3<f32> = _S820;
    var e_6 : u32 = begin_1;
    loop
    {
        if(e_6 < _S819)
        {
        }
        else
        {
            break;
        }
        var entry_5 : u32 = index_0[e_6];
        if(entry_5 == u32(2147483648))
        {
            ground_contact_0(_S818, true, &(f_19), &(t_21));
            e_6 = e_6 + u32(1);
            continue;
        }
        var _S821 : u32 = u32(2) * entry_5;
        f_19 = f_19 + scratch_0[params_0.slot_base_0 + _S821].xyz;
        t_21 = t_21 + scratch_0[params_0.slot_base_0 + _S821 + u32(1)].xyz;
        e_6 = e_6 + u32(1);
    }
    var _S822 : u32 = u32(2) * g_3;
    scratch_0[params_0.seg_base_0 + _S822] = vec4<f32>(f_19, 0.0f);
    scratch_0[params_0.seg_base_0 + _S822 + u32(1)] = vec4<f32>(t_21, 0.0f);
    return;
}

@compute
@workgroup_size(64, 1, 1)
fn contact_sums(@builtin(global_invocation_id) id_2 : vec3<u32>)
{
    contact_sum_at_0(id_2.x);
    return;
}

fn chunk_loads_1( _S823 : u32,  _S824 : u32,  _S825 : Quat_0,  _S826 : u32,  _S827 : f32,  _S828 : bool,  _S829 : f32,  _S830 : ptr<function, vec3<f32>>,  _S831 : ptr<function, vec3<f32>>,  _S832 : ptr<function, vec3<f32>>,  _S833 : ptr<function, vec3<f32>>)
{
    var _S834 : bool;
    var _S835 : vec3<f32> = vec3<f32>(0.0f);
    (*_S830) = _S835;
    (*_S831) = _S835;
    (*_S832) = _S835;
    (*_S833) = _S835;
    var _S836 : vec4<u32> = chunks_0[_S824].load_range_0;
    var term_2 : u32 = chunks_0[_S824].load_range_0.x;
    loop
    {
        if(term_2 < (_S836.y))
        {
        }
        else
        {
            break;
        }
        g_seen_0[u32(0)] = u32(1);
        var _S837 : u32 = u32(5) * term_2;
        var _S838 : u32 = (bitcast<vec4<u32>>((loads_0[_S837]))).y;
        var replacement_1 : bool = _S838 == u32(2);
        var dir_2 : vec4<f32> = loads_0[_S837 + u32(1)];
        var arm_1 : vec4<f32> = loads_0[_S837 + u32(2)];
        var _S839 : f32;
        if(replacement_1)
        {
            _S839 = _S829;
        }
        else
        {
            _S839 = 0.0f;
        }
        var value_3 : f32 = eval_function_0(term_2, _S826, _S827, _S839);
        if(replacement_1)
        {
            var _S840 : vec3<f32> = vec3<f32>(value_3);
            (*_S832) = (*_S832) + dir_2.xyz * _S840;
            (*_S833) = (*_S833) + arm_1.xyz * _S840;
            term_2 = term_2 + u32(1);
            continue;
        }
        if(_S838 == u32(0))
        {
            _S834 = true;
        }
        else
        {
            _S834 = _S838 == u32(3);
        }
        var fw_1 : vec3<f32>;
        if(_S834)
        {
            fw_1 = dir_2.xyz * vec3<f32>(value_3);
        }
        else
        {
            fw_1 = rotate_0(_S825, dir_2.xyz) * vec3<f32>((- value_3 * dir_2.w));
        }
        var lever_1 : vec3<f32>;
        if(_S838 == u32(3))
        {
            lever_1 = arm_1.xyz - state_0[u32(4) * _S823].xyz;
        }
        else
        {
            lever_1 = arm_1.xyz;
        }
        (*_S830) = (*_S830) + fw_1;
        (*_S831) = (*_S831) + cross(rotate_0(_S825, lever_1), fw_1);
        term_2 = term_2 + u32(1);
    }
    if(_S828)
    {
        _S834 = (chunks_0[_S824].cinfo_0.z) != u32(0);
    }
    else
    {
        _S834 = false;
    }
    if(_S834)
    {
        var _S841 : vec4<u32> = chunks_0[_S824].cinfo_0;
        var g_4 : u32 = chunks_0[_S824].cinfo_0.x;
        loop
        {
            if(g_4 < (_S841.y))
            {
            }
            else
            {
                break;
            }
            var _S842 : u32 = u32(2) * g_4;
            (*_S830) = (*_S830) + scratch_0[params_0.seg_base_0 + _S842].xyz;
            (*_S831) = (*_S831) + scratch_0[params_0.seg_base_0 + _S842 + u32(1)].xyz;
            g_4 = g_4 + u32(1);
        }
    }
    return;
}

fn net_load_0( c_40 : u32,  isl_29 : ptr<function, Island_std430_0>,  rg_15 : Rigid_0,  k_25 : u32,  dt_16 : f32,  contact_3 : bool,  f_20 : ptr<function, vec3<f32>>,  t_22 : ptr<function, vec3<f32>>)
{
    var fl_0 : vec3<f32>;
    var tl_0 : vec3<f32>;
    var rep_f_0 : vec3<f32>;
    var rep_m_0 : vec3<f32>;
    chunk_loads_1(c_40, c_40, rg_15.rot_1, k_25, dt_16, contact_3, 0.0f, &(fl_0), &(tl_0), &(rep_f_0), &(rep_m_0));
    var fc_4 : vec3<f32> = fl_0 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_40].center_0.w);
    var _S843 : vec3<f32> = chunks_0[c_40].center_0.xyz;
    var _S844 : vec3<f32> = (*isl_29).com_0.xyz;
    var r_16 : vec3<f32> = rotate_0(rg_15.rot_1, _S843 + state_0[u32(4) * c_40].xyz - _S844);
    (*f_20) = (*f_20) + fc_4;
    (*t_22) = (*t_22) + (cross(r_16, fc_4) + tl_0);
    if((chunks_0[c_40].load_range_0.y) > (chunks_0[c_40].load_range_0.x))
    {
        var fw_2 : vec3<f32> = rotate_0(rg_15.rot_1, rep_f_0);
        (*f_20) = (*f_20) + fw_2;
        (*t_22) = (*t_22) + (cross(rotate_0(rg_15.rot_1, _S843 - _S844), fw_2) + rotate_0(rg_15.rot_1, rep_m_0));
    }
    return;
}

fn net_load_1( c_41 : u32,  isl_30 : Island_0,  rg_16 : Rigid_0,  k_26 : u32,  dt_17 : f32,  contact_4 : bool,  f_21 : ptr<function, vec3<f32>>,  t_23 : ptr<function, vec3<f32>>)
{
    var fl_1 : vec3<f32>;
    var tl_1 : vec3<f32>;
    var rep_f_1 : vec3<f32>;
    var rep_m_1 : vec3<f32>;
    chunk_loads_1(c_41, c_41, rg_16.rot_1, k_26, dt_17, contact_4, 0.0f, &(fl_1), &(tl_1), &(rep_f_1), &(rep_m_1));
    var fc_5 : vec3<f32> = fl_1 + params_0.gravity_0.xyz * vec3<f32>(chunks_0[c_41].center_0.w);
    var _S845 : vec3<f32> = chunks_0[c_41].center_0.xyz;
    var _S846 : vec3<f32> = isl_30.com_0.xyz;
    var r_17 : vec3<f32> = rotate_0(rg_16.rot_1, _S845 + state_0[u32(4) * c_41].xyz - _S846);
    (*f_21) = (*f_21) + fc_5;
    (*t_23) = (*t_23) + (cross(r_17, fc_5) + tl_1);
    if((chunks_0[c_41].load_range_0.y) > (chunks_0[c_41].load_range_0.x))
    {
        var fw_3 : vec3<f32> = rotate_0(rg_16.rot_1, rep_f_1);
        (*f_21) = (*f_21) + fw_3;
        (*t_23) = (*t_23) + (cross(rotate_0(rg_16.rot_1, _S845 - _S846), fw_3) + rotate_0(rg_16.rot_1, rep_m_1));
    }
    return;
}

fn bond_update_0( i_23 : u32,  dt_18 : f32,  fracture_4 : bool,  abs_step_0 : u32,  wide_0 : bool) -> bool
{
    var ra_1 : vec3<f32> = bonds_0[i_23].ra_0.xyz;
    var rb_1 : vec3<f32> = bonds_0[i_23].rb_0.xyz;
    var _S847 : u32 = u32(4) * bonds_0[i_23].law_0.ids_0.y;
    var ta_3 : vec3<f32> = state_0[_S847 + u32(1)].xyz;
    var wa_0 : vec3<f32> = state_0[_S847 + u32(3)].xyz;
    var _S848 : u32 = u32(4) * bonds_0[i_23].law_0.ids_0.z;
    var tb_3 : vec3<f32> = state_0[_S848 + u32(1)].xyz;
    var wb_0 : vec3<f32> = state_0[_S848 + u32(3)].xyz;
    var _S849 : vec3<f32> = to_local_0(i_23, state_0[_S848].xyz + cross(tb_3, rb_1) - (state_0[_S847].xyz + cross(ta_3, ra_1)));
    var _S850 : vec3<f32> = to_local_0(i_23, tb_3 - ta_3);
    var _S851 : vec3<f32> = to_local_0(i_23, state_0[_S848 + u32(2)].xyz + cross(wb_0, rb_1) - (state_0[_S847 + u32(2)].xyz + cross(wa_0, ra_1)));
    var _S852 : vec3<f32> = to_local_0(i_23, wb_0 - wa_0);
    var _S853 : JointMaterial_std140_0 = materials_0.m_0.data_0[bonds_0[i_23].law_0.ids_0.x];
    var _S854 : JointState_std430_0 = bond_dyn_0[i_23].js_0;
    var _S855 : bool = is_damaged_0(&(_S854));
    var _S856 : f32 = _S854.life_0;
    var _S857 : JointBond_std430_0 = bonds_0[i_23].law_0;
    var _S858 : JointResponse_0 = joint_evaluate_0(&(_S853), &(_S857), &(_S854), _S849, _S850, dt_18, fracture_4);
    var _S859 : JointState_0 = JointState_0( bond_dyn_0[i_23].js_0.damage_0, bond_dyn_0[i_23].js_0.crush_1, bond_dyn_0[i_23].js_0.kappa_0, bond_dyn_0[i_23].js_0.kappa_c_0, bond_dyn_0[i_23].js_0.ductility_0, bond_dyn_0[i_23].js_0.ductility_c_0, bond_dyn_0[i_23].js_0.life_0, bond_dyn_0[i_23].js_0.plastic_x_0, bond_dyn_0[i_23].js_0.plastic_y_0, bond_dyn_0[i_23].js_0.plastic_t_0, bond_dyn_0[i_23].js_0.rebar_plastic_0, bond_dyn_0[i_23].js_0.rebar_slip0_0, bond_dyn_0[i_23].js_0.rebar_slip1_0, bond_dyn_0[i_23].js_0.rebar_work_0, bond_dyn_0[i_23].js_0.rebar_broken_0, bond_dyn_0[i_23].js_0.strain_rate_0, bond_dyn_0[i_23].js_0.governing_stress_0, bond_dyn_0[i_23].js_0.dissipated_0, bond_dyn_0[i_23].js_0.utilization_0, bond_dyn_0[i_23].js_0.mode_0 );
    var bd_2 : BondDyn_0;
    bd_2.js_0 = _S859;
    bd_2.force_lin_0 = bond_dyn_0[i_23].force_lin_0;
    bd_2.force_ang_0 = bond_dyn_0[i_23].force_ang_0;
    bd_2.sums_0 = bond_dyn_0[i_23].sums_0;
    bd_2.comps_0 = bond_dyn_0[i_23].comps_0;
    bd_2.events_0 = bond_dyn_0[i_23].events_0;
    var ra_2 : vec3<f32> = bonds_0[i_23].ra_0.xyz;
    var rb_2 : vec3<f32> = bonds_0[i_23].rb_0.xyz;
    var _S860 : JointBond_std430_0 = bonds_0[i_23].law_0;
    var f_lin_3 : vec3<f32>;
    var f_ang_3 : vec3<f32>;
    secant_factors_1(&(_S860), _S858.state_1, _S849, &(f_lin_3), &(f_ang_3));
    var qd_lin_0 : vec3<f32> = _S851 * bonds_0[i_23].c_lin_0.xyz * f_lin_3;
    var qd_ang_0 : vec3<f32> = _S852 * bonds_0[i_23].c_ang_0.xyz * f_ang_3;
    var q_lin_3 : vec3<f32> = _S858.force_lin_1 + qd_lin_0;
    var q_ang_3 : vec3<f32> = _S858.force_ang_1 + qd_ang_0;
    var damped_0 : f32 = (dot(qd_lin_0, _S851) + dot(qd_ang_0, _S852)) * dt_18;
    var _S861 : vec3<f32> = to_body_0(i_23, q_lin_3);
    var _S862 : vec3<f32> = to_body_0(i_23, q_ang_3);
    var _S863 : u32 = u32(3) * i_23;
    scratch_0[_S863] = vec4<f32>(_S861, max(_S858.measures_0.tension_0, _S858.measures_0.compression_0));
    scratch_0[_S863 + u32(1)] = vec4<f32>(_S862 + cross(ra_2, _S861), 0.0f);
    scratch_0[_S863 + u32(2)] = vec4<f32>((vec3<f32>(0) - _S862) + cross(rb_2, (vec3<f32>(0) - _S861)), 0.0f);
    var _S864 : f32 = bd_2.sums_0[i32(0)];
    var _S865 : f32 = bd_2.comps_0[i32(0)];
    comp_add1_0(&(_S864), &(_S865), _S858.dissipated_4);
    bd_2.sums_0[i32(0)] = _S864;
    bd_2.comps_0[i32(0)] = _S865;
    var _S866 : f32 = bd_2.sums_0[i32(1)];
    var _S867 : f32 = bd_2.comps_0[i32(1)];
    comp_add1_0(&(_S866), &(_S867), _S858.overshoot_0);
    bd_2.sums_0[i32(1)] = _S866;
    bd_2.comps_0[i32(1)] = _S867;
    var _S868 : f32 = bd_2.sums_0[i32(2)];
    var _S869 : f32 = bd_2.comps_0[i32(2)];
    comp_add1_0(&(_S868), &(_S869), damped_0);
    bd_2.sums_0[i32(2)] = _S868;
    bd_2.comps_0[i32(2)] = _S869;
    bd_2.force_lin_0 = vec4<f32>(q_lin_3, _S858.stored_5);
    bd_2.force_ang_0 = vec4<f32>(q_ang_3, max(bd_2.force_ang_0.w, _S858.state_1.utilization_0));
    var _S870 : bool;
    if(!_S855)
    {
        _S870 = is_damaged_1(_S858.state_1);
    }
    else
    {
        _S870 = false;
    }
    if(_S870)
    {
        _S870 = (bd_2.events_0.x) == u32(0);
    }
    else
    {
        _S870 = false;
    }
    if(_S870)
    {
        bd_2.events_0[i32(0)] = abs_step_0;
        bd_2.events_0[i32(3)] = _S858.state_1.mode_0;
        if(wide_0)
        {
            cov_or_0(_S860.ids_0.w, u32(32));
        }
        else
        {
            g_seen_0[u32(3)] = u32(1);
        }
    }
    if((bd_2.events_0.y) == u32(0))
    {
        _S870 = (_S858.state_1.life_0) != _S856;
    }
    else
    {
        _S870 = false;
    }
    if(_S870)
    {
        _S870 = (_S858.fatigue_before_0) > 0.99000000953674316f;
    }
    else
    {
        _S870 = false;
    }
    if(_S870)
    {
        var _S871 : f32 = fatigue_factor_0(&(_S853), _S858.state_1.life_0);
        _S870 = _S871 <= 0.99000000953674316f;
    }
    else
    {
        _S870 = false;
    }
    if(_S870)
    {
        bd_2.events_0[i32(1)] = abs_step_0;
        if(wide_0)
        {
            cov_or_0(_S860.ids_0.w, u32(64));
        }
        else
        {
            g_seen_0[u32(4)] = u32(1);
        }
    }
    if(_S858.disconnected_0)
    {
        bd_2.events_0[i32(2)] = abs_step_0;
    }
    bd_2.js_0 = _S858.state_1;
    bond_dyn_0[i_23].js_0.damage_0 = bd_2.js_0.damage_0;
    bond_dyn_0[i_23].js_0.crush_1 = bd_2.js_0.crush_1;
    bond_dyn_0[i_23].js_0.kappa_0 = bd_2.js_0.kappa_0;
    bond_dyn_0[i_23].js_0.kappa_c_0 = bd_2.js_0.kappa_c_0;
    bond_dyn_0[i_23].js_0.ductility_0 = bd_2.js_0.ductility_0;
    bond_dyn_0[i_23].js_0.ductility_c_0 = bd_2.js_0.ductility_c_0;
    bond_dyn_0[i_23].js_0.life_0 = bd_2.js_0.life_0;
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
    return _S858.disconnected_0;
}

fn chunk_update_0( c_42 : u32,  isl_31 : ptr<function, Island_std430_0>,  rg_17 : Rigid_0,  dt_19 : f32,  rml_0 : bool,  step_0 : u32,  contact_5 : bool,  work_4 : ptr<function, f32>,  work_err_0 : ptr<function, f32>)
{
    var _S872 : vec3<f32> = vec3<f32>(0.0f);
    var _S873 : u32 = index_0[c_42];
    var peak_0 : f32 = 0.0f;
    var e_7 : u32 = _S873;
    var fi_5 : vec3<f32> = _S872;
    var mi_4 : vec3<f32> = _S872;
    loop
    {
        if(e_7 < index_0[c_42 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_6 : u32 = index_0[e_7];
        var _S874 : u32 = u32(3) * ((entry_6 >> (u32(1))));
        var fa_1 : vec4<f32> = scratch_0[_S874];
        if(((entry_6 & (u32(1)))) == u32(0))
        {
            var mi_5 : vec3<f32> = mi_4 + scratch_0[_S874 + u32(1)].xyz;
            fi_5 = fi_5 + fa_1.xyz;
            mi_4 = mi_5;
        }
        else
        {
            var mi_6 : vec3<f32> = mi_4 + scratch_0[_S874 + u32(2)].xyz;
            fi_5 = fi_5 + (vec3<f32>(0) - fa_1.xyz);
            mi_4 = mi_6;
        }
        var _S875 : f32 = max(peak_0, fa_1.w);
        var _S876 : u32 = e_7 + u32(1);
        peak_0 = _S875;
        e_7 = _S876;
    }
    var _S877 : u32 = u32(4) * c_42;
    var u_2 : vec3<f32> = state_0[_S877].xyz;
    var _S878 : u32 = _S877 + u32(1);
    var th_4 : vec3<f32> = state_0[_S878].xyz;
    var _S879 : u32 = _S877 + u32(2);
    var v_10 : vec3<f32> = state_0[_S879].xyz;
    var _S880 : u32 = _S877 + u32(3);
    var w_6 : vec3<f32> = state_0[_S880].xyz;
    var mass_0 : f32 = chunks_0[c_42].center_0.w;
    var _S881 : vec3<f32> = chunks_0[c_42].center_0.xyz;
    var _S882 : vec3<f32> = (*isl_31).com_0.xyz;
    var r_world_0 : vec3<f32> = rotate_0(rg_17.rot_1, _S881 + u_2 - _S882);
    var f_load_0 : vec3<f32>;
    var t_load_0 : vec3<f32>;
    var rep_f_2 : vec3<f32>;
    var rep_m_2 : vec3<f32>;
    chunk_loads_1(c_42, c_42, rg_17.rot_1, step_0, dt_19, contact_5, dt_19, &(f_load_0), &(t_load_0), &(rep_f_2), &(rep_m_2));
    record_chunk_load_0(c_42, f_load_0, t_load_0);
    var _S883 : vec3<f32> = vec3<f32>(mass_0);
    var f_world_0 : vec3<f32> = f_load_0 + params_0.gravity_0.xyz * _S883;
    var t_world_0 : vec3<f32> = t_load_0;
    var f_world_1 : vec3<f32>;
    var t_world_1 : vec3<f32>;
    if(rml_0)
    {
        var t_world_2 : vec3<f32> = t_world_0 - (world_mul_0(rg_17.rot_1, chunks_0[c_42].inertia0_1, chunks_0[c_42].inertia1_1, chunks_0[c_42].inertia2_1, rg_17.alpha_0) + cross(rg_17.w_5, world_mul_0(rg_17.rot_1, chunks_0[c_42].inertia0_1, chunks_0[c_42].inertia1_1, chunks_0[c_42].inertia2_1, rg_17.w_5)));
        f_world_1 = f_world_0 - (rg_17.a_15 + cross(rg_17.alpha_0, r_world_0) + cross(rg_17.w_5, cross(rg_17.w_5, r_world_0))) * _S883;
        t_world_1 = t_world_2;
    }
    else
    {
        f_world_1 = f_world_0;
        t_world_1 = t_world_0;
    }
    var f_ext_0 : vec3<f32> = inverse_rotate_0(rg_17.rot_1, f_world_1);
    var m_ext_0 : vec3<f32> = inverse_rotate_0(rg_17.rot_1, t_world_1);
    var f_ext_1 : vec3<f32>;
    var m_ext_1 : vec3<f32>;
    if(rml_0)
    {
        var wb_1 : vec3<f32> = inverse_rotate_0(rg_17.rot_1, rg_17.w_5);
        var i_w_0 : vec3<f32> = rows_mul_0(chunks_0[c_42].inertia0_1, chunks_0[c_42].inertia1_1, chunks_0[c_42].inertia2_1, w_6);
        var m_ext_2 : vec3<f32> = m_ext_0 - (cross(wb_1, i_w_0) + cross(w_6, rows_mul_0(chunks_0[c_42].inertia0_1, chunks_0[c_42].inertia1_1, chunks_0[c_42].inertia2_1, wb_1)) + cross(w_6, i_w_0));
        f_ext_1 = f_ext_0 - cross(wb_1, v_10) * vec3<f32>((2.0f * mass_0));
        m_ext_1 = m_ext_2;
    }
    else
    {
        f_ext_1 = f_ext_0;
        m_ext_1 = m_ext_0;
    }
    var f_22 : vec3<f32> = f_ext_1 + rep_f_2 + fi_5;
    var m_9 : vec3<f32> = m_ext_1 + rep_m_2 + mi_4;
    var support_1 : u32 = chunks_0[c_42].info_1.x;
    var _S884 : vec3<f32> = vec3<f32>(state_0[_S878].w, state_0[_S879].w, state_0[_S880].w);
    var reaction_1 : vec3<f32>;
    var u_3 : vec3<f32>;
    var th_5 : vec3<f32>;
    var v_11 : vec3<f32>;
    var w_7 : vec3<f32>;
    if(support_1 == u32(1))
    {
        reaction_1 = (vec3<f32>(0) - f_22);
        u_3 = u_2;
        th_5 = th_4;
        v_11 = _S872;
        w_7 = _S872;
    }
    else
    {
        var _S885 : vec4<f32> = chunks_0[c_42].scale_0;
        var w_8 : vec3<f32> = w_6 + rows_mul_0(chunks_0[c_42].inv0_1, chunks_0[c_42].inv1_1, chunks_0[c_42].inv2_1, m_9) * vec3<f32>((dt_19 * chunks_0[c_42].scale_0.z));
        var _S886 : vec3<f32> = vec3<f32>(dt_19);
        var th_6 : vec3<f32> = th_4 + w_8 * _S886;
        if(support_1 == u32(2))
        {
            reaction_1 = (vec3<f32>(0) - f_22);
            u_3 = u_2;
            th_5 = _S872;
        }
        else
        {
            var v_12 : vec3<f32> = v_10 + f_22 * vec3<f32>((dt_19 * _S885.y));
            var u_4 : vec3<f32> = u_2 + v_12 * _S886;
            reaction_1 = _S884;
            u_3 = u_4;
            th_5 = v_12;
        }
        var _S887 : vec3<f32> = th_5;
        th_5 = th_6;
        v_11 = _S887;
        w_7 = w_8;
    }
    state_0[_S877] = vec4<f32>(u_3, peak_0);
    state_0[_S878] = vec4<f32>(th_5, reaction_1.x);
    state_0[_S879] = vec4<f32>(v_11, reaction_1.y);
    state_0[_S880] = vec4<f32>(w_7, reaction_1.z);
    comp_add1_4(&((*work_4)), &((*work_err_0)), (dot(f_load_0, rg_17.vel_0 + rg_17.vel_err_0 + cross(rg_17.w_5, rotate_0(rg_17.rot_1, _S881 + u_3 - _S882)) + rotate_0(rg_17.rot_1, v_11)) + dot(t_load_0, rg_17.w_5 + rotate_0(rg_17.rot_1, w_7))) * dt_19);
    return;
}

fn chunk_update_1( c_43 : u32,  isl_32 : Island_0,  rg_18 : Rigid_0,  dt_20 : f32,  rml_1 : bool,  step_1 : u32,  contact_6 : bool,  work_5 : ptr<function, f32>,  work_err_1 : ptr<function, f32>)
{
    var _S888 : vec3<f32> = vec3<f32>(0.0f);
    var _S889 : u32 = index_0[c_43];
    var peak_1 : f32 = 0.0f;
    var e_8 : u32 = _S889;
    var fi_6 : vec3<f32> = _S888;
    var mi_7 : vec3<f32> = _S888;
    loop
    {
        if(e_8 < index_0[c_43 + u32(1)])
        {
        }
        else
        {
            break;
        }
        var entry_7 : u32 = index_0[e_8];
        var _S890 : u32 = u32(3) * ((entry_7 >> (u32(1))));
        var fa_2 : vec4<f32> = scratch_0[_S890];
        if(((entry_7 & (u32(1)))) == u32(0))
        {
            var mi_8 : vec3<f32> = mi_7 + scratch_0[_S890 + u32(1)].xyz;
            fi_6 = fi_6 + fa_2.xyz;
            mi_7 = mi_8;
        }
        else
        {
            var mi_9 : vec3<f32> = mi_7 + scratch_0[_S890 + u32(2)].xyz;
            fi_6 = fi_6 + (vec3<f32>(0) - fa_2.xyz);
            mi_7 = mi_9;
        }
        var _S891 : f32 = max(peak_1, fa_2.w);
        var _S892 : u32 = e_8 + u32(1);
        peak_1 = _S891;
        e_8 = _S892;
    }
    var _S893 : u32 = u32(4) * c_43;
    var u_5 : vec3<f32> = state_0[_S893].xyz;
    var _S894 : u32 = _S893 + u32(1);
    var th_7 : vec3<f32> = state_0[_S894].xyz;
    var _S895 : u32 = _S893 + u32(2);
    var v_13 : vec3<f32> = state_0[_S895].xyz;
    var _S896 : u32 = _S893 + u32(3);
    var w_9 : vec3<f32> = state_0[_S896].xyz;
    var mass_1 : f32 = chunks_0[c_43].center_0.w;
    var _S897 : vec3<f32> = chunks_0[c_43].center_0.xyz;
    var _S898 : vec3<f32> = isl_32.com_0.xyz;
    var r_world_1 : vec3<f32> = rotate_0(rg_18.rot_1, _S897 + u_5 - _S898);
    var f_load_1 : vec3<f32>;
    var t_load_1 : vec3<f32>;
    var rep_f_3 : vec3<f32>;
    var rep_m_3 : vec3<f32>;
    chunk_loads_1(c_43, c_43, rg_18.rot_1, step_1, dt_20, contact_6, dt_20, &(f_load_1), &(t_load_1), &(rep_f_3), &(rep_m_3));
    record_chunk_load_0(c_43, f_load_1, t_load_1);
    var _S899 : vec3<f32> = vec3<f32>(mass_1);
    var f_world_2 : vec3<f32> = f_load_1 + params_0.gravity_0.xyz * _S899;
    var t_world_3 : vec3<f32> = t_load_1;
    var f_world_3 : vec3<f32>;
    var t_world_4 : vec3<f32>;
    if(rml_1)
    {
        var t_world_5 : vec3<f32> = t_world_3 - (world_mul_0(rg_18.rot_1, chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, rg_18.alpha_0) + cross(rg_18.w_5, world_mul_0(rg_18.rot_1, chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, rg_18.w_5)));
        f_world_3 = f_world_2 - (rg_18.a_15 + cross(rg_18.alpha_0, r_world_1) + cross(rg_18.w_5, cross(rg_18.w_5, r_world_1))) * _S899;
        t_world_4 = t_world_5;
    }
    else
    {
        f_world_3 = f_world_2;
        t_world_4 = t_world_3;
    }
    var f_ext_2 : vec3<f32> = inverse_rotate_0(rg_18.rot_1, f_world_3);
    var m_ext_3 : vec3<f32> = inverse_rotate_0(rg_18.rot_1, t_world_4);
    var f_ext_3 : vec3<f32>;
    var m_ext_4 : vec3<f32>;
    if(rml_1)
    {
        var wb_2 : vec3<f32> = inverse_rotate_0(rg_18.rot_1, rg_18.w_5);
        var i_w_1 : vec3<f32> = rows_mul_0(chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, w_9);
        var m_ext_5 : vec3<f32> = m_ext_3 - (cross(wb_2, i_w_1) + cross(w_9, rows_mul_0(chunks_0[c_43].inertia0_1, chunks_0[c_43].inertia1_1, chunks_0[c_43].inertia2_1, wb_2)) + cross(w_9, i_w_1));
        f_ext_3 = f_ext_2 - cross(wb_2, v_13) * vec3<f32>((2.0f * mass_1));
        m_ext_4 = m_ext_5;
    }
    else
    {
        f_ext_3 = f_ext_2;
        m_ext_4 = m_ext_3;
    }
    var f_23 : vec3<f32> = f_ext_3 + rep_f_3 + fi_6;
    var m_10 : vec3<f32> = m_ext_4 + rep_m_3 + mi_7;
    var support_2 : u32 = chunks_0[c_43].info_1.x;
    var _S900 : vec3<f32> = vec3<f32>(state_0[_S894].w, state_0[_S895].w, state_0[_S896].w);
    var reaction_2 : vec3<f32>;
    var u_6 : vec3<f32>;
    var th_8 : vec3<f32>;
    var v_14 : vec3<f32>;
    var w_10 : vec3<f32>;
    if(support_2 == u32(1))
    {
        reaction_2 = (vec3<f32>(0) - f_23);
        u_6 = u_5;
        th_8 = th_7;
        v_14 = _S888;
        w_10 = _S888;
    }
    else
    {
        var _S901 : vec4<f32> = chunks_0[c_43].scale_0;
        var w_11 : vec3<f32> = w_9 + rows_mul_0(chunks_0[c_43].inv0_1, chunks_0[c_43].inv1_1, chunks_0[c_43].inv2_1, m_10) * vec3<f32>((dt_20 * chunks_0[c_43].scale_0.z));
        var _S902 : vec3<f32> = vec3<f32>(dt_20);
        var th_9 : vec3<f32> = th_7 + w_11 * _S902;
        if(support_2 == u32(2))
        {
            reaction_2 = (vec3<f32>(0) - f_23);
            u_6 = u_5;
            th_8 = _S888;
        }
        else
        {
            var v_15 : vec3<f32> = v_13 + f_23 * vec3<f32>((dt_20 * _S901.y));
            var u_7 : vec3<f32> = u_5 + v_15 * _S902;
            reaction_2 = _S900;
            u_6 = u_7;
            th_8 = v_15;
        }
        var _S903 : vec3<f32> = th_8;
        th_8 = th_9;
        v_14 = _S903;
        w_10 = w_11;
    }
    state_0[_S893] = vec4<f32>(u_6, peak_1);
    state_0[_S894] = vec4<f32>(th_8, reaction_2.x);
    state_0[_S895] = vec4<f32>(v_14, reaction_2.y);
    state_0[_S896] = vec4<f32>(w_10, reaction_2.z);
    comp_add1_4(&((*work_5)), &((*work_err_1)), (dot(f_load_1, rg_18.vel_0 + rg_18.vel_err_0 + cross(rg_18.w_5, rotate_0(rg_18.rot_1, _S897 + u_6 - _S898)) + rotate_0(rg_18.rot_1, v_14)) + dot(t_load_1, rg_18.w_5 + rotate_0(rg_18.rot_1, w_10))) * dt_20);
    return;
}

fn drift_moments_0( c_44 : u32,  tu_2 : ptr<function, vec3<f32>>,  pv_2 : ptr<function, vec3<f32>>)
{
    var _S904 : u32 = u32(4) * c_44;
    var _S905 : vec3<f32> = vec3<f32>((chunks_0[c_44].center_0.w * chunks_0[c_44].scale_0.x));
    (*tu_2) = (*tu_2) + state_0[_S904].xyz * _S905;
    (*pv_2) = (*pv_2) + state_0[_S904 + u32(2)].xyz * _S905;
    return;
}

fn island_frame_at_0( gi_0 : u32,  tid_24 : u32)
{
    var woke_0 : bool;
    var isl_33 : Island_0;
    isl_33.range_0 = islands_0[gi_0].range_0;
    isl_33.info_0 = islands_0[gi_0].info_0;
    isl_33.com_0 = islands_0[gi_0].com_0;
    isl_33.inertia0_0 = islands_0[gi_0].inertia0_0;
    isl_33.inertia1_0 = islands_0[gi_0].inertia1_0;
    isl_33.inertia2_0 = islands_0[gi_0].inertia2_0;
    isl_33.inv0_0 = islands_0[gi_0].inv0_0;
    isl_33.inv1_0 = islands_0[gi_0].inv1_0;
    isl_33.inv2_0 = islands_0[gi_0].inv2_0;
    isl_33.wcom_0 = islands_0[gi_0].wcom_0;
    isl_33.winv0_0 = islands_0[gi_0].winv0_0;
    isl_33.winv1_0 = islands_0[gi_0].winv1_0;
    isl_33.winv2_0 = islands_0[gi_0].winv2_0;
    isl_33.rotation_0 = islands_0[gi_0].rotation_0;
    isl_33.position_0 = islands_0[gi_0].position_0;
    isl_33.position_err_0 = islands_0[gi_0].position_err_0;
    isl_33.velocity_0 = islands_0[gi_0].velocity_0;
    isl_33.velocity_err_0 = islands_0[gi_0].velocity_err_0;
    isl_33.angular_velocity_0 = islands_0[gi_0].angular_velocity_0;
    isl_33.done_0 = islands_0[gi_0].done_0;
    isl_33.coverage_0 = islands_0[gi_0].coverage_0;
    isl_33.wide_groups_0 = islands_0[gi_0].wide_groups_0;
    isl_33.done_pad_0 = islands_0[gi_0].done_pad_0;
    isl_33.probes_0 = islands_0[gi_0].probes_0;
    isl_33.energy_0 = islands_0[gi_0].energy_0;
    isl_33.rotation_err_0 = islands_0[gi_0].rotation_err_0;
    isl_33.momentum_0 = islands_0[gi_0].momentum_0;
    isl_33.momentum_err_0 = islands_0[gi_0].momentum_err_0;
    var driven_0 : bool = (((isl_33.info_0.x) & (u32(2)))) != u32(0);
    var _S906 : bool = !((((isl_33.info_0.x) & (u32(1)))) != u32(0));
    var _S907 : bool;
    if(_S906)
    {
        _S907 = !driven_0;
    }
    else
    {
        _S907 = false;
    }
    var contact_island_0 : bool = (((isl_33.info_0.x) & (u32(4)))) != u32(0);
    var _S908 : bool = (((isl_33.info_0.x) & (u32(16)))) != u32(0);
    seen_clear_0(tid_24);
    var _S909 : bool = tid_24 == u32(0);
    var settled_0 : bool;
    var cov_2 : u32;
    if(_S909)
    {
        if(contact_island_0 != ((params_0.contact_mode_0) == u32(1)))
        {
            settled_0 = true;
        }
        else
        {
            settled_0 = (((isl_33.info_0.x) & (u32(8)))) != u32(0);
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
            settled_0 = contact_stopped_2(isl_33);
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
    if((((isl_33.info_0.z) & (u32(1)))) != u32(0))
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
        cov_2 = min(isl_33.info_0.y, params_0.max_steps_0);
    }
    var _S910 : f32 = params_0.dt_0;
    var _S911 : bool = (params_0.fracture_0) != u32(0);
    var _S912 : bool = (params_0.rigid_motion_loads_0) != u32(0);
    var rg_19 : Rigid_0 = rigid_of_3(isl_33);
    var work_6 : f32 = 0.0f;
    var work_err_2 : f32 = 0.0f;
    settled_0 = _S908;
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
        var abs_step_1 : u32 = isl_33.info_0.w + done_1 + u32(1);
        var k_27 : u32 = abs_step_1 - u32(1) - params_0.step_start_0;
        var quiet_0 : bool = (((isl_33.info_0.x) & (u32(32)))) != u32(0);
        var _S913 : bool;
        if(settled_0)
        {
            _S913 = !quiet_0;
        }
        else
        {
            _S913 = false;
        }
        var _S914 : bool;
        var explicit_step_0 : bool;
        var c_45 : u32;
        if(_S913)
        {
            var _S915 : vec3<f32> = vec3<f32>(0.0f);
            var norm_1 : vec3<f32> = _S915;
            var unused0_0 : vec3<f32> = _S915;
            c_45 = isl_33.range_0.x + tid_24;
            loop
            {
                if(c_45 < (isl_33.range_0.y))
                {
                }
                else
                {
                    break;
                }
                var _S916 : f32 = settled_chunk_load_0(c_45, rg_19.rot_1, k_27, _S910, contact_island_0);
                norm_1[i32(0)] = norm_1[i32(0)] + _S916;
                c_45 = c_45 + u32(256);
            }
            group_sum3_0(tid_24, &(norm_1), &(unused0_0));
            if((params_0.solve_mode_0) == u32(1))
            {
                _S914 = (abs(norm_1.x - isl_33.energy_0.z)) > (isl_33.energy_0.w);
            }
            else
            {
                _S914 = false;
            }
            if(_S914)
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
        if(_S906)
        {
            _S914 = !quiet_0;
        }
        else
        {
            _S914 = false;
        }
        if(_S914)
        {
            var _S917 : vec3<f32> = vec3<f32>(0.0f);
            var f_24 : vec3<f32> = _S917;
            var t_24 : vec3<f32> = _S917;
            c_45 = isl_33.range_0.x + tid_24;
            loop
            {
                if(c_45 < (isl_33.range_0.y))
                {
                }
                else
                {
                    break;
                }
                net_load_1(c_45, isl_33, rg_19, k_27, _S910, contact_island_0, &(f_24), &(t_24));
                c_45 = c_45 + u32(256);
            }
            group_sum3_0(tid_24, &(f_24), &(t_24));
            rigid_acceleration_2(isl_33, &(rg_19), f_24, t_24);
        }
        if(!settled_0)
        {
            explicit_step_0 = !quiet_0;
        }
        else
        {
            explicit_step_0 = false;
        }
        var c_46 : u32;
        if(explicit_step_0)
        {
            c_45 = isl_33.range_0.z + tid_24;
            loop
            {
                if(c_45 < (isl_33.range_0.w))
                {
                }
                else
                {
                    break;
                }
                var _S918 : bool = bond_update_0(c_45, _S910, _S911, abs_step_1, false);
                if(_S918)
                {
                    g_halt_0 = u32(1);
                }
                c_45 = c_45 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
            c_46 = isl_33.range_0.x + tid_24;
            loop
            {
                if(c_46 < (isl_33.range_0.y))
                {
                }
                else
                {
                    break;
                }
                chunk_update_1(c_46, isl_33, rg_19, _S910, _S912, k_27, contact_island_0, &(work_6), &(work_err_2));
                c_46 = c_46 + u32(256);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        var _S919 : bool;
        if(_S907)
        {
            _S919 = !quiet_0;
        }
        else
        {
            _S919 = false;
        }
        if(_S919)
        {
            integrate_rigid_1(isl_33, &(rg_19), _S910);
        }
        var _S920 : bool;
        if(_S906)
        {
            _S920 = explicit_step_0;
        }
        else
        {
            _S920 = false;
        }
        if(_S920)
        {
            var _S921 : vec3<f32> = isl_33.wcom_0.xyz;
            var _S922 : vec3<f32> = vec3<f32>(0.0f);
            var tu_3 : vec3<f32> = _S922;
            var pv_3 : vec3<f32> = _S922;
            c_45 = isl_33.range_0.x + tid_24;
            loop
            {
                if(c_45 < (isl_33.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_moments_0(c_45, &(tu_3), &(pv_3));
                c_45 = c_45 + u32(256);
            }
            group_sum3_0(tid_24, &(tu_3), &(pv_3));
            var tr_7 : vec3<f32> = tu_3 / vec3<f32>(isl_33.wcom_0.w);
            var dv_7 : vec3<f32> = pv_3 / vec3<f32>(isl_33.wcom_0.w);
            var lu_4 : vec3<f32> = _S922;
            var lv_4 : vec3<f32> = _S922;
            c_46 = isl_33.range_0.x + tid_24;
            loop
            {
                if(c_46 < (isl_33.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_angular_0(c_46, _S921, tr_7, dv_7, &(lu_4), &(lv_4));
                c_46 = c_46 + u32(256);
            }
            group_sum3_0(tid_24, &(lu_4), &(lv_4));
            var phi_5 : vec3<f32> = rows_mul_0(isl_33.winv0_0, isl_33.winv1_0, isl_33.winv2_0, lu_4);
            var dw_4 : vec3<f32> = rows_mul_0(isl_33.winv0_0, isl_33.winv1_0, isl_33.winv2_0, lv_4);
            var c_47 : u32 = isl_33.range_0.x + tid_24;
            loop
            {
                if(c_47 < (isl_33.range_0.y))
                {
                }
                else
                {
                    break;
                }
                drift_apply_0(c_47, _S921, tr_7, phi_5, dv_7, dw_4);
                c_47 = c_47 + u32(256);
            }
            if(!driven_0)
            {
                drift_rigid_1(isl_33, &(rg_19), tr_7, phi_5, dv_7, dw_4);
            }
            storageBarrier(); textureBarrier(); workgroupBarrier();;
        }
        var _S923 : bool;
        if(_S909)
        {
            _S923 = (isl_33.probes_0.y) > (isl_33.probes_0.x);
        }
        else
        {
            _S923 = false;
        }
        if(_S923)
        {
            record_probes_0(isl_33, rg_19, k_27);
        }
        var _S924 : u32 = done_1 + u32(1);
        if(g_halt_0 != u32(0))
        {
            done_1 = _S924;
            break;
        }
        done_1 = _S924;
        woke_1 = woke_0;
    }
    var wsum_0 : vec3<f32> = vec3<f32>(work_6, work_err_2, 0.0f);
    var unused_3 : vec3<f32> = vec3<f32>(0.0f);
    group_sum3_0(tid_24, &(wsum_0), &(unused_3));
    if(_S909)
    {
        isl_33.rotation_0 = quat_vec_0(rg_19.rot_1);
        isl_33.rotation_err_0 = rg_19.rot_err_0;
        isl_33.position_0 = vec4<f32>(rg_19.pos_0, 0.0f);
        isl_33.position_err_0 = vec4<f32>(rg_19.pos_err_0, 0.0f);
        isl_33.velocity_0 = vec4<f32>(rg_19.vel_0, 0.0f);
        isl_33.velocity_err_0 = vec4<f32>(rg_19.vel_err_0, 0.0f);
        isl_33.angular_velocity_0 = vec4<f32>(rg_19.w_5, 0.0f);
        isl_33.momentum_0 = vec4<f32>(rg_19.l_1, 0.0f);
        isl_33.momentum_err_0 = vec4<f32>(rg_19.l_err_0, 0.0f);
        isl_33.done_0 = done_1;
        isl_33.info_0[i32(1)] = isl_33.info_0[i32(1)] - done_1;
        if(g_halt_0 != u32(0))
        {
            _S907 = contact_island_0;
        }
        else
        {
            _S907 = false;
        }
        if(_S907)
        {
            contact_split_at_0(isl_33.info_0.w + done_1);
        }
        var _S925 : f32 = wsum_0.x;
        var _S926 : f32 = isl_33.energy_0[i32(0)];
        var _S927 : f32 = isl_33.energy_0[i32(1)];
        comp_add1_2(&(_S926), &(_S927), _S925);
        isl_33.energy_0[i32(0)] = _S926;
        isl_33.energy_0[i32(1)] = _S927 + wsum_0.y;
        isl_33.info_0[i32(3)] = isl_33.info_0[i32(3)] + done_1;
        if(g_halt_0 != u32(0))
        {
            isl_33.info_0[i32(2)] = ((isl_33.info_0[i32(2)]) | (u32(1)));
        }
        var _S928 : u32 = seen_bits_0();
        if(g_halt_0 != u32(0))
        {
            cov_2 = u32(128);
        }
        else
        {
            cov_2 = u32(0);
        }
        var _S929 : u32 = (_S928 | (cov_2));
        if(woke_0)
        {
            cov_2 = u32(2048);
        }
        else
        {
            cov_2 = u32(0);
        }
        var cov_3 : u32 = (_S929 | (cov_2));
        if(done_1 > u32(0))
        {
            var quiet_1 : bool = (((isl_33.info_0.x) & (u32(32)))) != u32(0);
            if(quiet_1)
            {
                cov_2 = u32(4096);
            }
            else
            {
                cov_2 = u32(0);
            }
            var cov_4 : u32 = (cov_3 | (cov_2));
            if((((isl_33.info_0.x) & (u32(16)))) != u32(0))
            {
                _S907 = !quiet_1;
            }
            else
            {
                _S907 = false;
            }
            if(_S907)
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
            if((isl_33.probes_0.y) > (isl_33.probes_0.x))
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
        isl_33.coverage_0 = ((isl_33.coverage_0) | (cov_2));
        if(woke_0)
        {
            isl_33.info_0[i32(0)] = ((isl_33.info_0[i32(0)]) & (u32(4294967279)));
            isl_33.info_0[i32(2)] = ((isl_33.info_0[i32(2)]) | (u32(4)));
        }
        islands_0[gi_0].range_0 = isl_33.range_0;
        islands_0[gi_0].info_0 = isl_33.info_0;
        islands_0[gi_0].com_0 = isl_33.com_0;
        islands_0[gi_0].inertia0_0 = isl_33.inertia0_0;
        islands_0[gi_0].inertia1_0 = isl_33.inertia1_0;
        islands_0[gi_0].inertia2_0 = isl_33.inertia2_0;
        islands_0[gi_0].inv0_0 = isl_33.inv0_0;
        islands_0[gi_0].inv1_0 = isl_33.inv1_0;
        islands_0[gi_0].inv2_0 = isl_33.inv2_0;
        islands_0[gi_0].wcom_0 = isl_33.wcom_0;
        islands_0[gi_0].winv0_0 = isl_33.winv0_0;
        islands_0[gi_0].winv1_0 = isl_33.winv1_0;
        islands_0[gi_0].winv2_0 = isl_33.winv2_0;
        islands_0[gi_0].rotation_0 = isl_33.rotation_0;
        islands_0[gi_0].position_0 = isl_33.position_0;
        islands_0[gi_0].position_err_0 = isl_33.position_err_0;
        islands_0[gi_0].velocity_0 = isl_33.velocity_0;
        islands_0[gi_0].velocity_err_0 = isl_33.velocity_err_0;
        islands_0[gi_0].angular_velocity_0 = isl_33.angular_velocity_0;
        islands_0[gi_0].done_0 = isl_33.done_0;
        islands_0[gi_0].coverage_0 = isl_33.coverage_0;
        islands_0[gi_0].wide_groups_0 = isl_33.wide_groups_0;
        islands_0[gi_0].done_pad_0 = isl_33.done_pad_0;
        islands_0[gi_0].probes_0 = isl_33.probes_0;
        islands_0[gi_0].energy_0 = isl_33.energy_0;
        islands_0[gi_0].rotation_err_0 = isl_33.rotation_err_0;
        islands_0[gi_0].momentum_0 = isl_33.momentum_0;
        islands_0[gi_0].momentum_err_0 = isl_33.momentum_err_0;
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn island_frame(@builtin(workgroup_id) group_8 : vec3<u32>, @builtin(local_invocation_id) thread_8 : vec3<u32>)
{
    island_frame_at_0(group_8.x, thread_8.x);
    return;
}

fn wide_chunks_at_0( gx_0 : u32,  tid_25 : u32)
{
    var wg_6 : WideGroup_0 = wide_group_0(params_0.wide_chunk_table_0, gx_0);
    var _S930 : Island_std430_0 = islands_0[wg_6.island_2];
    var _S931 : bool = wide_enter_1(tid_25, wg_6.island_2);
    if(!_S931)
    {
        return;
    }
    var _S932 : u32 = _S930.info_0.x;
    var anchored_0 : bool = ((_S932 & (u32(1)))) != u32(0);
    if(((_S932 & (u32(16)))) != u32(0))
    {
        if(tid_25 == u32(0))
        {
            scratch_0[params_0.wide_base_0 + u32(8) * gx_0 + u32(6)] = vec4<f32>(0.0f);
        }
        return;
    }
    var _S933 : Rigid_0 = wide_rigid_frame_0(tid_25, &(_S930), wg_6);
    var work_7 : f32 = 0.0f;
    var work_err_3 : f32 = 0.0f;
    var _S934 : vec3<f32> = vec3<f32>(0.0f);
    var tu_4 : vec3<f32> = _S934;
    var pv_4 : vec3<f32> = _S934;
    var c_48 : u32 = wg_6.begin_0 + tid_25;
    if(c_48 < (wg_6.end_0))
    {
        var _S935 : bool = (params_0.rigid_motion_loads_0) != u32(0);
        var _S936 : u32 = wide_step_0(&(_S930));
        chunk_update_0(c_48, &(_S930), _S933, params_0.dt_0, _S935, _S936, ((_S932 & (u32(4)))) != u32(0), &(work_7), &(work_err_3));
        if(!anchored_0)
        {
            drift_moments_0(c_48, &(tu_4), &(pv_4));
        }
    }
    var wsum_1 : vec3<f32> = vec3<f32>(work_7, work_err_3, 0.0f);
    var unused_4 : vec3<f32> = _S934;
    group_sum3_0(tid_25, &(wsum_1), &(unused_4));
    var _S937 : bool = !anchored_0;
    if(_S937)
    {
        group_sum3_0(tid_25, &(tu_4), &(pv_4));
    }
    if(tid_25 == u32(0))
    {
        var _S938 : u32 = u32(8) * gx_0;
        scratch_0[params_0.wide_base_0 + _S938 + u32(6)] = vec4<f32>(wsum_1, 0.0f);
        if(_S937)
        {
            wide_store_0(gx_0, u32(2), tu_4, pv_4);
        }
        scratch_0[params_0.wide_base_0 + _S938 + u32(7)] = vec4<f32>(f32(g_seen_0[u32(0)]), f32(g_seen_0[u32(1)]), f32(g_seen_0[u32(2)]), 0.0f);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_chunks(@builtin(workgroup_id) group_9 : vec3<u32>, @builtin(local_invocation_id) thread_9 : vec3<u32>)
{
    wide_chunks_at_0(group_9.x, thread_9.x);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn sums_and_impactors(@builtin(workgroup_id) group_10 : vec3<u32>, @builtin(local_invocation_id) thread_10 : vec3<u32>)
{
    var sums_groups_0 : u32 = (params_0.seg_count_0 + u32(255)) / u32(256);
    var _S939 : u32 = group_10.x;
    if(_S939 < sums_groups_0)
    {
        contact_sum_at_0(_S939 * u32(256) + thread_10.x);
    }
    else
    {
        impactor_integrate_at_0(_S939 - sums_groups_0, thread_10.x);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn islands_and_wide_chunks(@builtin(workgroup_id) group_11 : vec3<u32>, @builtin(local_invocation_id) thread_11 : vec3<u32>)
{
    var _S940 : u32 = group_11.x;
    if(_S940 < (params_0.halt_index_0))
    {
        island_frame_at_0(_S940, thread_11.x);
    }
    else
    {
        wide_chunks_at_0(_S940 - params_0.halt_index_0, thread_11.x);
    }
    return;
}

fn wide_bonds_at_0( gx_1 : u32,  tid_26 : u32)
{
    var bond_group_0 : bool = gx_1 < (params_0.wide_bond_groups_0);
    var wg_7 : WideGroup_0;
    if(bond_group_0)
    {
        wg_7 = wide_group_0(params_0.wide_bond_table_0, gx_1);
    }
    else
    {
        wg_7 = wide_group_0(params_0.wide_chunk_table_0, gx_1 - params_0.wide_bond_groups_0);
    }
    var _S941 : WideGroup_0 = wg_7;
    var _S942 : Island_std430_0 = islands_0[wg_7.island_2];
    var _S943 : bool = wide_enter_1(tid_26, wg_7.island_2);
    if(!_S943)
    {
        return;
    }
    var _S944 : u32 = wide_step_0(&(_S942));
    if(bond_group_0)
    {
        var _S945 : vec4<u32> = _S942.info_0;
        if((((_S942.info_0.x) & (u32(16)))) != u32(0))
        {
            return;
        }
        var i_24 : u32 = wg_7.begin_0 + tid_26;
        var _S946 : bool;
        if(i_24 < (wg_7.end_0))
        {
            var _S947 : bool = bond_update_0(i_24, params_0.dt_0, (params_0.fracture_0) != u32(0), _S945.w + u32(1), true);
            _S946 = _S947;
        }
        else
        {
            _S946 = false;
        }
        if(_S946)
        {
            islands_0[_S941.island_2].info_0[i32(2)] = ((_S945.z) | (u32(2)));
        }
        return;
    }
    var _S948 : u32 = _S942.info_0.x;
    if(((_S948 & (u32(1)))) != u32(0))
    {
        return;
    }
    var _S949 : vec3<f32> = vec3<f32>(0.0f);
    var f_25 : vec3<f32> = _S949;
    var t_25 : vec3<f32> = _S949;
    var c_49 : u32 = wg_7.begin_0 + tid_26;
    if(c_49 < (wg_7.end_0))
    {
        var _S950 : Rigid_0 = rigid_of_0(&(_S942));
        net_load_0(c_49, &(_S942), _S950, _S944, params_0.dt_0, ((_S948 & (u32(4)))) != u32(0), &(f_25), &(t_25));
    }
    group_sum3_0(tid_26, &(f_25), &(t_25));
    if(tid_26 == u32(0))
    {
        wide_store_0(gx_1 - params_0.wide_bond_groups_0, u32(0), f_25, t_25);
    }
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn wide_bonds(@builtin(workgroup_id) group_12 : vec3<u32>, @builtin(local_invocation_id) thread_12 : vec3<u32>)
{
    wide_bonds_at_0(group_12.x, thread_12.x);
    return;
}

@compute
@workgroup_size(256, 1, 1)
fn sums_impactors_bonds(@builtin(workgroup_id) group_13 : vec3<u32>, @builtin(local_invocation_id) thread_13 : vec3<u32>)
{
    var sums_groups_1 : u32 = (params_0.seg_count_0 + u32(255)) / u32(256);
    var _S951 : u32 = max(params_0.impactor_count_0, u32(1));
    var _S952 : u32 = group_13.x;
    if(_S952 < sums_groups_1)
    {
        contact_sum_at_0(_S952 * u32(256) + thread_13.x);
    }
    else
    {
        if(_S952 < (sums_groups_1 + _S951))
        {
            impactor_integrate_at_0(_S952 - sums_groups_1, thread_13.x);
        }
        else
        {
            wide_bonds_at_0(_S952 - sums_groups_1 - _S951, thread_13.x);
        }
    }
    return;
}

